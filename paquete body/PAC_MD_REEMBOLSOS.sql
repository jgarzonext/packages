--------------------------------------------------------
--  DDL for Package Body PAC_MD_REEMBOLSOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_REEMBOLSOS" IS
   /******************************************************************************
      NOMBRE:    PAC_MD_REEMBOLSOS
      PROPÓSITO: Reemborsaments.
      REVISIONES:
      Ver   Fecha       Autor  Descripción
      ----- ----------  -----  ------------------------------------
      1.0                      Creació del package.
      2.0   04/05/2009  SBG    Diverses modificacions (Bug 8309)
      3.0   19/05/2009  APD    3.0010127: IAX- Consultas de pólizas, simulaciones, reembolsos y póliza reteneidas
      3.1   21/05/2009  APD    3.1 BUG10178: IAX - Vista AGENTES_AGENTE por empresa
      4.0   02/06/2009  ETM    4. bug 0010266: CRE - cuenta de abono en pólizas de salud y bajas
      5.0   01/06/2009  NMM    5. bug 10540: Eliminación de vistas.
      6.0   30/06/2009  DRA    6. 0010564: Cambio en la tabla CONTROLSAN
      7.0   03/07/2009  DRA    7. 0010631: CRE - Modificaciónes modulo de reembolsos
      8.0   01/07/2009  NMM    8. 10682: CRE - Modificaciones para módulo de reembolsos.
      9.0   04/07/2009  DRA    9. 0010704: CRE - Traspaso de facturas para reembolso con mismo Nº Hoja CASS
      10.0  21/07/2009  DRA    10.0010761: CRE - Reembolsos
      11.0  24/08/2009  DRA    11.0010949: CRE - Pruebas módulo reembolsos
      12.0  02/10/2009  XVM    12.0011285: CRE - Transferencias de reembolsos
      13.0  30/09/2009  DRA    13.0011183: CRE - Suplemento de alta de asegurado ya existente
      14.0  13/11/2009  DRA    14.0011551: CRE - Reembolsos. Alta de actos
      15.0  23/11/2009  DRA    15.0011552: CRE - Reembolsos. Multirregistro de pólizas en alta de reembolsos
      16.0  27/11/2009  MCA    16.0012025: CRE - Error al recuperar cuenta de abono en determinados casos
      17.0  11/03/2010  DRA    17.0012676: CRE201 - Consulta de reembolsos - Ocultar descripción de Acto y otras mejoras
      18.0  26/03/2010  DRA    18.0013927: CRE049 - Control cambio de estado reembolso
      19.0  18/05/2010  DRA    19.0013002: CRE201 - Mejorar usabilidad de entrada de reembolsos para perfil CSO
      20.0  25/11/2010  SMF    20.0016838  AGA402 - Parametrización de los reembolsos al 150%
      21.0  19/01/2011  DRA    21.0016576: AGA602 - Parametrització de reemborsaments per veterinaris
      22.0  22/02/2011  DRA    22.0017732: CRE998 - Modificacions mòdul reemborsaments
      23.0  08/06/2011  DRA    23.0018770: CRE800 - Consulta Reemborsaments
      24.0  21-10-2011  JGR    24.0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
      25.0  11-11-2011  APD    25.0018946: LCOL_P001 - PER - Visibilidad en personas
      26.0  30/05/2012  MDS    26.0022396: CRE998: Modificació vista columna en reemborsaments
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   vsmancont      NUMBER;
   n_max_reg      NUMBER := 200;

   /***********************************************************************
                     Rutina que retorna les dades dels reemborsaments que compleixin les
      condicions de cerca
      param in  pestado     : codi estat
      param in  pnreemb     : codi del reemborsament
      param in  pnpoliza    : número pòlissa
      param in  pncass      : número CASS
      param in  pnombre     : nom prenedor
      param in  pagrsalud   : agrupació salut
      param in  poficina    : codi agent
      param in  pusuario    : usuari
      param in  pnfactcli   : número de full
      param in out mensajes : T_IAX_MENSAJES
      return                : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultareemb(
      pestado IN NUMBER,
      pnreemb IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,   -- Mantis 10682.NMM.01/07/2009.
      pncass IN VARCHAR2,
      pnombre IN VARCHAR2,
      pagrsalud IN VARCHAR2,
      poficina IN NUMBER,
      pusuario IN VARCHAR2,
      -- BUG 8309 - 05/05/2009 - SBG - Nou paràmetre de cerca PNFACTCLI
      pnfactcli IN VARCHAR2,
      -- FINAL BUG 8309 - 05/05/2009 - SBG
      pfacto IN DATE,   -- BUG12676:DRA:10/03/2010
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS   -- BUG10761:DRA:21/07/2009
      --
      cur            sys_refcursor;
      --reembs         t_iax_reembfact := t_iax_reembfact();
      --reemb          ob_iax_reembfact := ob_iax_reembfact();
      squery         VARCHAR2(2000);
      -- Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación
      --                                se añade la subselect con la tabla agentes_agente
      -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol

      --Bug 21458/108087 - 23/02/2012 - AMC
      buscar         VARCHAR2(4000)
         := ' where (s.cagente,s.cempres) in (select aa.cagente, aa.cempres from agentes_agente_pol aa) ';
      --Fi Bug 21458/108087 - 23/02/2012 - AMC
      -- Bug 10127 - APD - 19/05/2009 - fin
      vcvalor        NUMBER(8) := 891;   --Estat reemborsament
      vcvalor2       NUMBER(8) := 893;   --Origen
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(250)
         := 'parámetros - pnreemb:' || pnreemb || ' - pestado:' || pestado || ' - pnpoliza:'
            || pnpoliza || ' - pncass:' || pncass || ' - ptnombre:' || pnombre
            || ' - poficina:' || poficina || ' - pagrsalud:' || pagrsalud || ' - pusuario:'
            || pusuario || ' - pnfactcli:' || pnfactcli || ' - pfacto: ' || pfacto;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Set_Consultareemb';
   BEGIN
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      buscar := buscar || ' AND e.sseguro = s.sseguro'
                || ' AND p.cagente = ff_agente_cpervisio (s.cagente, f_sysdate, s.cempres)'
                || ' AND f.nreemb = e.nreemb'   -- BUG10761:DRA:21/07/2009
                || ' AND p.sperson = e.sperson';   -- BUG16576:DRA:15/02/2011

      -- Bug 10127 - APD - 19/05/2009 - fin
      IF pnreemb IS NOT NULL THEN
         buscar := buscar || ' AND e.nreemb = ' || pnreemb;
      END IF;

      IF pestado IS NOT NULL THEN
         buscar := buscar || ' AND e.cestado = ' || pestado;
      END IF;

      IF pnpoliza IS NOT NULL THEN
         buscar := buscar || ' AND s.npoliza = ' || pnpoliza;
      END IF;

      -- Mantis 10682.NMM.01/07/2009.i.
      IF pncertif IS NOT NULL THEN
         buscar := buscar || ' AND s.ncertif = ' || pncertif;
      END IF;

      -- Mantis 10682.NMM.01/07/2009.f.
      IF pncass IS NOT NULL THEN
         buscar := buscar || ' AND f.ncass = ' || CHR(39) || pncass || CHR(39);
      END IF;

      IF pnombre IS NOT NULL THEN
         -- BUG10949:DRA:25/08/2009:Inici
         buscar := buscar
                   || ' AND REPLACE (REPLACE (p.tbuscar, '' '', ''''), '','', '''') LIKE ''%'
                   || UPPER(REPLACE(REPLACE(pnombre, ' ', ''), ',', '')) || '%''';
      -- BUG10949:DRA:25/08/2009:Fi
      END IF;

      IF pagrsalud IS NOT NULL THEN
         buscar := buscar || ' AND e.agr_salud = ''' || pagrsalud || '''';
      END IF;

      IF poficina IS NOT NULL THEN
         buscar := buscar || ' AND s.cagente = ' || poficina;
      END IF;

      -- BUG 8309 - 05/05/2009 - SBG - Nou paràmetre de cerca PNFACTCLI
      IF pnfactcli IS NOT NULL THEN
         buscar := buscar || ' AND f.nfact_cli = ' || CHR(39) || UPPER(pnfactcli) || CHR(39);
      END IF;

      -- FINAL BUG 8309 - 05/05/2009 - SBG

      -- BUG12676:DRA:11/03/2010:Inici
      IF pfacto IS NOT NULL THEN
         buscar :=
            buscar
            || ' AND EXISTS (SELECT 1 FROM reembactosfac raf WHERE raf.nreemb = f.nreemb AND raf.nfact = f.nfact AND raf.facto = TO_DATE ('
            || TO_CHAR(pfacto, 'YYYYMMDD') || ', ''YYYYMMDD''))';
      END IF;

      -- BUG12676:DRA:11/03/2010:Fi
      vpasexec := 2;
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      -- Mantis 10682.NMM.01/07/2009.Afegim ncertif.

      --Bug 21458/108087 - 23/02/2012 - AMC
      squery := 'SELECT * FROM(' || ' SELECT ff_desvalorfijo (' || vcvalor || ','
                || pac_md_common.f_get_cxtidioma || ',e.cestado) testado,'
                || ' s.npoliza npoliza, s.ncertif ncertif, e.agr_salud,'
                || ' f_nombre (p.sperson, 1,s.cagente) Nom_aseg,'   -- BUG16576:DRA:15/02/2011
                || ' e.nreemb, e.falta, f.ncass,'   -- BUG12676:DRA:11/03/2010
                || ' f.nfact_cli, f.ffactura, f.nfact,'   -- BUG10761:DRA:23/07/2009
                -- Ini Bug 22396 - MDS - 30/05/2012
                || ' f.ctipofac,' || ' ff_desvalorfijo (896,' || pac_md_common.f_get_cxtidioma
                || ',f.ctipofac) tipreemb,'
                -- Fin Bug 22396 - MDS - 30/05/2012
                || ' (row_number() over (order by f.ffactura desc)) RN'
                || ' FROM reembolsos e, per_detper p, seguros s, reembfact f ' || buscar
                || ' ORDER BY f.ffactura desc) ' || ' where  rownum<=' || n_max_reg;
      --Fi Bug 21458/108087 - 23/02/2012 - AMC
      -- Bug 10127 - APD - 19/05/2009 - fin
      vpasexec := 3;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_set_consultareemb;

   /***********************************************************************
                                    Rutina que retorna les dades dels reemborsaments que compleixin les
      condicions de cerca
      param in  pnpoliza : número pòlissa
      param in  pncass   : número CASS
      param in  ptnombre : nom prenedor
      param in  psnip    : número snip
      param in out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consulta_activi(
      pnpoliza IN NUMBER,
      pncass IN VARCHAR2,
      ptnombre IN NUMBER,
      psnip IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
      -- Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación
      --                                se añade la subselect con la tabla agentes_agente
      --buscar         VARCHAR2(1000) := ' where rownum<=101 ';
      -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
      buscar         VARCHAR2(4000)
         := ' where rownum<=' || n_max_reg
            || ' and (s.cagente, s.cempres) in (select aa.cagente, aa.cempres from agentes_agente_pol aa) ';
      -- Bug 10127 - APD - 19/05/2009 - fin
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - pnpoliza:' || pnpoliza || ' - pncass:' || pncass || ' - ptnombre:'
            || ptnombre || ' - psnip:' || psnip;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Set_Consulta_Activi';
   --
   BEGIN
      -- BUG16576:DRA:15/02/2011:Inici
      buscar :=
         buscar || ' AND a.sseguro = s.sseguro'
         || ' AND a.norden = (SELECT MIN(a1.norden) FROM asegurados a1 WHERE a1.sseguro = a.sseguro)';
      -- BUG16576:DRA:15/02/2011:Fi
      -- Bug 10540.NMM.01/06/2009.S'elimina la vista VI_REEMBOLSOS.
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      buscar := buscar
                || ' AND p.sperson = NVL (r.sperson, a.sperson)'   -- BUG16576:DRA:15/02/2011
                || ' AND s.sseguro = r.sseguro';
      -- Bug 10127 - APD - 19/05/2009 - fin
      buscar := buscar || ' AND v.sseguro = s.sseguro AND v.nreemb = re.nreemb';
      -- BUG10761:DRA:23-07-2009:Inici
      buscar := buscar
                || ' AND p.cagente = ff_agente_cpervisio (s.cagente, f_sysdate, s.cempres)';

      -- BUG10761:DRA:23-07-2009:Fi
      IF pnpoliza IS NOT NULL THEN
         buscar := buscar || ' AND s.npoliza = ' || pnpoliza;
      END IF;

      IF pncass IS NOT NULL THEN
         buscar := buscar || ' AND re.ncass = ' || CHR(39) || pncass || CHR(39);
      END IF;

      -- Bug 10540.NMM.fi.
      IF ptnombre IS NOT NULL THEN
         buscar := buscar || ' AND p.tbuscar like ''%' || ptnombre || '%''';
      END IF;

      IF psnip IS NOT NULL THEN
         buscar := buscar || ' AND v.snip = ' || psnip;
      END IF;

      vpasexec := 2;
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      -- Bug 10540.NMM.01/06/2009.S'elimina la vista VI_REEMBOLSOS.
      squery :=
         'SELECT S.npoliza npoliza, pac_md_obtenerdatos.F_Desriesgos (''POL'',r.sseguro,r.nriesgo) nom_risc, S.csituac csituac, RE.ncass ncass
                 FROM riesgos r, per_detper p, reembolsos v, seguros s, reembfact re, asegurados a '
         || buscar;
      -- Bug 10540.NMM.fi.
      -- Bug 10127 - APD - 19/05/2009 - fin
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_set_consulta_activi;

   /***********************************************************************
                                    Rutina que retorna les dades de les pòlisses amb reemborssaments que
      compleixin les condicions de cerca
      param in  pnpoliza : Codi pòlissa
      param in  psperson : Codi persona
      param in out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consulta_poliza(
      pnpoliza IN NUMBER,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
      -- Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación
      --                                se añade la subselect con la tabla agentes_agente
      --buscar         VARCHAR2(1000) := ' where rownum<=101 and sa.sseguro = r.sseguro ';
      -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
      buscar         VARCHAR2(4000)
         := ' where rownum<=' || n_max_reg
            || ' and (s.cagente,s.cempres) in (select cagente,cempres from agentes_agente_pol) ';
      -- Bug 10127 - APD - 19/05/2009 - fin
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'parámetros - pnpoliza:' || pnpoliza || ' - psperson:' || psperson;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Set_Consulta_Poliza';
   --
   BEGIN
      IF pnpoliza IS NOT NULL THEN
         buscar := buscar || ' AND r.npoliza = ' || pnpoliza;
      END IF;

      IF psperson IS NOT NULL THEN
         buscar := buscar || ' AND r.sperson = ' || psperson;
      END IF;

      vpasexec := 2;
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      --squery := 'SELECT r.* FROM vi_reembolsos r  ' || buscar;
      -- Bug 10127 - APD - 19/05/2009 - fin
      -- Bug 10540.NMM.01/06/2009.S'elimina la vista VI_REEMBOLSOS.
      squery :=
         'SELECT nreemb, agr_salud, sseguro, csituac, fefecto, cgarant, sperson, cbancar, npoliza, snip,'
         || ' tbuscar, nfact_cli, nfact, ncass, ncass_ase, ctipo, ffactura, facto, cacto, tacto,'
         || ' nacto, ipago, ctipban'
         || ' FROM (SELECT reembolsos.nreemb, reembolsos.agr_salud, reembolsos.sseguro, seguros.csituac,'
         || ' seguros.fefecto, reembolsos.cgarant, reembolsos.sperson, reembolsos.cbancar,'
         || ' seguros.npoliza, per_personas.snip, per_detper.tbuscar, reembfact.nfact_cli,'
         || ' reembfact.nfact, reembfact.ncass, reembfact.ncass_ase, reembfact.ctipo,'
         || ' reembfact.ffactura, reembactosfac.facto, reembactosfac.cacto, desactos.tacto,'
         || ' reembactosfac.nacto, reembactosfac.ipago, reembolsos.ctipban'
         || ' FROM reembolsos, seguros, per_personas, per_detper, reembfact, reembactosfac, desactos'
         || ' WHERE reembactosfac.ftrans IS NOT NULL AND desactos.cidioma = '
         || pac_md_common.f_get_cxtidioma() || ' AND reembolsos.sseguro = seguros.sseguro'
         || ' AND reembolsos.sperson = per_personas.sperson'
         || ' AND per_detper.sperson = reembolsos.sperson'
         || ' AND per_detper.cagente = ff_agente_cpervisio (seguros.cagente, f_sysdate, seguros.cempres)'   -- BUG10761:DRA:23/07/2009
         || ' AND reembfact.nreemb = reembactosfac.nreemb'
         || ' AND reembolsos.nreemb = reembfact.nreemb'
         || ' AND reembactosfac.cacto = desactos.cacto) ' || buscar;
      -- Bug 10540.NMM.fi.
      vpasexec := 3;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_set_consulta_poliza;

   /***********************************************************************
                                    Rutina que retorna les dades dels reemborsaments que compleixin les
      condicions de cerca
      param in  psseguro : número segur
      param in  pnriesgo : codi risc
      param in  psperson : identificador de personas
      param in out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consulta_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
      -- Bug 10127 - APD - 19/05/2009 - Modificar número máximo de registros
      -- mostrar por valor parinstalación añade subselect tabla agentes_agente
      --buscar         VARCHAR2(1000) := ' where rownum<=101 ';
      -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
      buscar         VARCHAR2(4000)
         := ' where rownum<=200' || n_max_reg
            || ' and (s.cagente,s.cempres) in (select cagente,cempres from agentes_agente_pol) ';
      -- Bug 10127 - APD - 19/05/2009 - fin
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - psseguro:' || psseguro || ' - pnriesgo:' || pnriesgo
            || ' - psperson:' || psperson;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Set_Consulta_Riesgo';
   BEGIN
      IF psseguro IS NOT NULL THEN
         buscar := buscar || ' AND v.sseguro  =' || psseguro;
      END IF;

      IF pnriesgo IS NOT NULL THEN
         buscar := buscar || ' AND r.nriesgo  =' || pnriesgo;
      END IF;

      IF psperson IS NOT NULL THEN
         buscar := buscar || ' AND v.sperson  =' || psperson;
      END IF;

      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      buscar := buscar || ' AND r.sseguro = v.sseguro ';
      -- Bug 10127 - APD - 19/05/2009 - fin
      -- Bug 10540.NMM.01/06/2009.S'elimina la vista VI_REEMBOLSOS.La funció
      buscar := buscar || ' AND RE.NREEMB = V.NREEMB ';
      -- Bug 10540.NMM.fi.
      vpasexec := 2;
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      /*squery :=
                                       'SELECT F_Get_NameRiesgoPersonal (r.sseguro,r.nriesgo) nom_risc, NVL(r.nriesgo,1) nriesgo, v.ncass_bene
                FROM vi_REEMBOLSOS v, RIESGOS r '
         || buscar;*/
      -- Bug 10127 - APD - 19/05/2009 - fin
      -- Bug 10540.NMM.01/06/2009.S'elimina la vista VI_REEMBOLSOS.La funció
      -- F_Get_NameRiesgoPersonal no existeix, s'elimina.
      squery :=
         'SELECT null nom_risc, NVL(r.nriesgo,1) nriesgo, RE.NCASS
                FROM REEMBOLSOS v, RIESGOS r, REEMBFACT RE '
         || buscar;
      -- Bug 10540.NMM.fi.
      vpasexec := 3;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_set_consulta_riesgo;

   /***********************************************************************
                                    Rutina que retorna les dades dels reemborsaments que compleixin les
      condicions de cerca
      param in  psseguro : número segur
      param in  pnriesgo : codi risc
      param in out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consulta_reembriesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
      -- Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación
      --                                se añade la subselect con la tabla agentes_agente
      --buscar         VARCHAR2(1000) := ' where rownum<=101 and sa.sseguro = r.sseguro ';
      -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
      buscar         VARCHAR2(4000)
         := ' where rownum<=200' || n_max_reg
            || ' and (s.cagente,s.cempres) in (select cagente,cempres from agentes_agente_pol) ';
      -- Bug 10127 - APD - 19/05/2009 - fin
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'parámetros - psseguro:' || psseguro || ' - pnriesgo:' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Set_Consulta_Reembriesgo';
   BEGIN
      IF psseguro IS NOT NULL THEN
         buscar := buscar || ' AND r.sseguro = ' || psseguro;
      END IF;

      IF pnriesgo IS NOT NULL THEN
         buscar := buscar || ' AND r.nriesgo = ' || pnriesgo;
      END IF;

      -- Bug 10540.NMM.01/06/2009.S'elimina la vista VI_REEMBOLSOS.La funció
      buscar := buscar
                || ' AND R.NREEMB = RE.NREEMB AND D.CACTO = RE.CACTO AND RE.NREEMB = REE.NREEMB ';
      -- Bug 10540.NMM.fi.
      vpasexec := 2;
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      /*squery :=
                                       'SELECT r.nreemb, r.agsalud, r.cbancar, r.ctipban, r.nfact_cli, r.nfact, r.ctipo, r.ffactura, r.tacto, r.ipago
                FROM vi_reembolsos r '
         || buscar;*/
      -- Bug 10127 - APD - 19/05/2009 - fin
      -- Bug 10540.NMM.01/06/2009.S'elimina la vista VI_REEMBOLSOS.La funció
      squery :=
         'SELECT r.nreemb, R.AGR_SALUD, r.cbancar, r.ctipban, REE.nfact_cli, REE.nfact, REE.ctipo, REE.ffactura, D.tacto, RE.ipago
          FROM reembolsos r, REEMBACTOSFAC RE, REEMBFACT REE, DESACTOS D ';
      -- Bug 10540.NMM.fi.
      vpasexec := 3;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_set_consulta_reembriesgo;

   /***********************************************************************
                                    Rutina que da d'alta un reembossament
      param in  psseguro    : codi segur
      param in  pnriesgo    : codi risc
      param in  pcgarant    : codi garantia
      param in  pcestado    : codi estat
      param in  ptobserv    : camp observació
      param in  pcbancar    : codi banc
      param in  pctipban    : codi tipus bancari
      param in  pcorigen    : codi origen
      param in/out ponreemb : codi del reembossament
      param in/out mensajes : T_IAX_MENSAJES
      return                : 0 tot correcte
                              1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_set_reembolso(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcestado IN NUMBER,
      ptobserv IN VARCHAR2,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER,
      pcorigen IN NUMBER,
      ponreemb IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_set_reembolso';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro:' || psseguro || ' - pnriesgo:' || pnriesgo
            || ' - pcgarant:' || pcgarant || ' - pcestado:' || pcestado || ' - ptobserv:'
            || ptobserv || ' - pcbancar:' || pcbancar || ' - pctipban:' || pctipban
            || ' - pcorigen:' || pcorigen;
      verror         NUMBER := 0;
      vpasexec       NUMBER;
      vcestado       NUMBER;
      vfestado       DATE;
      vcount         NUMBER;
      vorigen        NUMBER;
   BEGIN
      vpasexec := 1;

      IF verror != 0 THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      -- Comprovació pas de paràmetres
      IF pcestado IS NULL
         OR pcgarant IS NULL
         OR pcbancar IS NULL
         OR pctipban IS NULL
         OR pcorigen IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF ponreemb IS NULL THEN
         vorigen := 1;
         verror := pac_reembolsos.f_ins_reembolso(ponreemb, psseguro, pnriesgo, pcgarant,
                                                  pcestado, f_sysdate, ptobserv, pcbancar,
                                                  pctipban, vorigen);
      ELSE
         vorigen := pcorigen;
         --comprobar
         vpasexec := 3;

         SELECT cestado, festado
           INTO vcestado, vfestado
           FROM reembolsos
          WHERE nreemb = ponreemb;

         IF pcestado <> vcestado THEN
            vfestado := f_sysdate;
         END IF;

         vpasexec := 4;
         verror := pac_reembolsos.f_valida_estado_reemb(ponreemb, pcestado);

         IF verror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
            RAISE e_object_error;
         END IF;

         vpasexec := 5;
         verror := pac_reembolsos.f_ins_reembolso(ponreemb, psseguro, pnriesgo, pcgarant,
                                                  pcestado, vfestado, ptobserv, pcbancar,
                                                  pctipban, vorigen);
      END IF;

      IF verror != 0 THEN
         vpasexec := 6;
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
   END f_set_reembolso;

   /***********************************************************************
                                                   Rutina que graba los datos de las facturas
      param in pnreemb   : codi segur
      param in pnfactcli : Número factura cliente
      param in pncasase  : Número CASS titular
      param in pncass    : Número CASS asegurado
      param in pfacuse   : Fecha acuse
      param in pffactura : Fecha factura
      param in pimpfact  : Importe factura
      param in porigen   : Origen
      param in pfbaja    : Fecha baja
      param in pctipofac : Tipo centro factura
      param in pnfact    : Numero factura
      param in pnfactext  : Numero de factura externa
      param in pctractat : Tractada
      param out pnfactnew : Numero factura en alta
      param out mensajes : T_IAX_MENSAJES
      return             : 0 tot correcte
                           1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_set_reembfact(
      pnreemb IN NUMBER,
      pnfactcli IN VARCHAR2,
      pncasase IN VARCHAR2,
      pncass IN VARCHAR2,
      pfacuse IN DATE,
      pffactura IN DATE,
      pimpfact IN NUMBER,
      porigen IN NUMBER,
      pfbaja IN DATE,
      pctipofac IN NUMBER,   -- BUG10704:DRA:14/07/2009
      pnfact IN NUMBER,
      pnfactext IN VARCHAR2,   -- BUG10631:DRA:03/07/2009
      pctractat IN NUMBER,   -- BUG17732:DRA:22/02/2011
      pnfactnew OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_REEMBOLSOS.F_Set_ReembFact';
      vparam         VARCHAR2(500)
         := 'parámetros - pnreemb:' || pnreemb || ' - pnfactcli:' || pnfactcli
            || ' - pncasase:' || pncasase || ' - pncass:' || pncass || ' - pfacuse:'
            || pfacuse || ' - pffactura:' || pffactura || ' - pimpfact:' || pimpfact
            || ' - porigen:' || porigen || ' - pfbaja:' || pfbaja || ' - pctipofac:'
            || pctipofac || ' - pnfact:' || pnfact || ' - pnfactnew:' || pnfactnew
            || ' - pnfactext:' || pnfactext || ' - pctractat:' || pctractat;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vestado        NUMBER(1);
      vcount         NUMBER;
      verror         NUMBER;
      vnfact         reembfact.nfact%TYPE;
      vorigen        NUMBER;
   BEGIN
      vpasexec := 1;
      pnfactnew := pnfact;

      -- Comprovació pas de paràmetres
      IF pnreemb IS NULL
         OR pfacuse IS NULL
         OR pffactura IS NULL
         OR pimpfact IS NULL
         OR porigen IS NULL
         OR pctipofac IS NULL THEN
         RAISE e_param_error;
      ELSE
         vpasexec := 2;

         IF pfbaja IS NOT NULL THEN   --ANULAR FACTURA
            SELECT COUNT(1)
              INTO vcount
              FROM reembactosfac
             WHERE ftrans IS NOT NULL
               AND nreemb = pnreemb;

            IF vcount > 0 THEN
               --NO SE PERMITE ANULAR
               verror := 1000656;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 3;

         IF pnfact IS NOT NULL THEN   --MODIFICAR FACTURA
            vorigen := porigen;

            SELECT cestado
              INTO vestado
              FROM reembolsos
             WHERE nreemb = pnreemb;

            IF vestado = 4 THEN
               --NO SE PERMITE MODIFICAR
               vpasexec := 4;
               verror := 1000657;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
               RAISE e_object_error;
            END IF;
         ELSE
            vorigen := 1;
         END IF;

         vpasexec := 5;
         verror := pac_reembolsos.f_valida_fecha_fact(pnreemb, pffactura, pfacuse);

         IF verror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         vnfact := pnfact;
         verror := pac_reembolsos.f_ins_reemfact(vnfact, pnreemb, pnfactcli, pctipofac,
                                                 pffactura, pfacuse, pimpfact, vorigen, pfbaja,
                                                 pncasase, pncass, pnfactext, pctractat);   -- BUG10631:DRA:03/07/2009
         vpasexec := 8;
         pnfactnew := vnfact;

         IF verror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
            RAISE e_object_error;
         ELSE
            IF pfbaja IS NOT NULL THEN   --ANULAR FACTURA
               vpasexec := 9;

               --DAR DE BAJA ACTOS QUE DEPENDAN DE LA FACTURA
               UPDATE reembactosfac
                  SET fbaja = pfbaja
                WHERE nreemb = pnreemb
                  AND nfact = pnfact;
            END IF;
         END IF;
      END IF;

      -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 111313);
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
   END f_set_reembfact;

     /***********************************************************************
                                    Rutina que valida y graba la información del acto
      param in  pnreemb     : codi segur
      param in pnfact         : Numero factura
      param in pcacto       : Código de acto
      param in pnacto      : Números de acto
      param in pfacto         : Fecha de acto
      param in ppreemb     : Porcentaje
      param in pitot       : Importe total
      param in piextra     : Importe extra
      param in pipago      : Importe pago
      param in piahorro       : Importe ahorro
      param in pfbaja         : Fecha baja
      param in pnlinea        : Número línea (modificación)
      param in origen     : origen
      param in pctipo      : codigo tipo
      param in pipagocomp  : importe de pago complementario
      param in pftrans     : Fecha de transferencia
      param out pnlineanew     : Número linea (alta)
      param out ctipomsj    : Tipo mensaje error validación
      param out mensajes : T_IAX_MENSAJES
      return                : 0 tot correcte
                              1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_set_reembfactact(
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pcacto IN VARCHAR2,
      pnacto IN NUMBER,
      pfacto IN DATE,
      pitarcass IN NUMBER,
      picass IN NUMBER,
      ppreemb IN NUMBER,
      pitot IN NUMBER,
      piextra IN NUMBER,
      pipago IN NUMBER,
      piahorro IN NUMBER,
      pfbaja IN DATE,
      pnlinea IN NUMBER,
      porigen IN NUMBER,
      pctipo IN NUMBER,   -- BUG10704:DRA:14/07/2009
      pipagocomp IN NUMBER,   -- BUG10704:DRA:14/07/2009
      pftrans IN DATE,   -- BUG10761:DRA:27/07/2009
      pnlineanew OUT NUMBER,
      ctipomsj OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobject        VARCHAR2(500) := 'PAC_MD_REEMBOLSOS.F_Set_ReembFactAct';
      vparam         VARCHAR2(500)
         := 'parámetros - pnreemb:' || pnreemb || ' - pnfact:' || pnfact || ' - pcacto:'
            || pcacto || ' - pnacto:' || pnacto || ' - pfacto:' || pfacto || ' - pitarcass:'
            || pitarcass || ' - ppreemb:' || ppreemb || ' - picass:' || picass || ' - pilot:'
            || pitot || ' - piextra:' || piextra || ' - pipago:' || pipago || ' - piahorro:'
            || piahorro || ' - pfbaja:' || pfbaja || ' - pnlinea:' || pnlinea
            || ' - vsmancont:' || vsmancont || ' - pctipo:' || pctipo || ' - pipagocomp:'
            || pipagocomp || ' - pftrans:' || pftrans;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnlinea        NUMBER;
      verror         NUMBER := 0;
      vctipo         NUMBER;
      vsseguro       NUMBER;
      vnriesgo       NUMBER;
      vcgarant       NUMBER;
      vsperson       NUMBER;
      vagr_salud     NUMBER;
      vccontrol      VARCHAR2(150);
      vcerror        VARCHAR2(4);
      vbaja          NUMBER;
      vorigen        NUMBER;
      vnfact_cli     VARCHAR2(20);
      v_fbaja        DATE;   -- BUG10949:DRA:25/08/2009
      v_existe       NUMBER;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnreemb IS NULL
         OR pnfact IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnlinea := pnlinea;

      SELECT COUNT(1)
        INTO vbaja
        FROM reembfact
       WHERE nfact = pnfact
         AND nreemb = pnreemb
         AND fbaja IS NOT NULL;

      IF vbaja > 0 THEN
         vpasexec := 3;
         verror := 1000660;
         pnlineanew := vnlinea;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      IF pnlinea IS NULL THEN
         vorigen := 1;

         IF vsmancont IS NULL THEN
            SELECT smancont.NEXTVAL
              INTO vsmancont
              FROM DUAL;
         ELSE
            DELETE FROM tmp_controlsan
                  WHERE smancont = vsmancont;
         END IF;
      ELSE
         vorigen := porigen;

         SELECT cerror, fbaja   -- BUG10949:DRA:25/08/2009
           INTO vcerror, v_fbaja   -- BUG10949:DRA:25/08/2009
           FROM reembactosfac
          WHERE nreemb = pnreemb
            AND nfact = pnfact
            AND nlinea = pnlinea;

         IF vsmancont IS NULL THEN
            SELECT smancont.NEXTVAL
              INTO vsmancont
              FROM DUAL;
         END IF;

         BEGIN
            -- BUG10949:DRA:25/08/2009: Si estaba de baja no guardo el error para que vuelva a comprobarlo
            IF NOT(NVL(vcerror, 0) <> 0
                   AND v_fbaja IS NOT NULL) THEN
               INSERT INTO tmp_controlsan
                           (smancont, ccontrol)
                    VALUES (vsmancont, vcerror);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      END IF;

      vpasexec := 4;
      vnumerr := pac_reembolsos.f_ins_reembactosfac(pnreemb, pnfact, vnlinea, pcacto, pnacto,
                                                    pfacto, pitarcass, ppreemb, picass, pitot,
                                                    piextra, pipago, piahorro, 0, pftrans,   -- BUG10761:DRA:27/07/2009
                                                    vorigen, NULL, pfbaja, pctipo, pipagocomp,
                                                    NULL, NULL);   -- BUG10704:DRA:17/07/2009
      pnlineanew := vnlinea;
      vpasexec := 5;

      SELECT nfact_cli
        INTO vnfact_cli
        FROM reembfact
       WHERE nfact = pnfact
         AND nreemb = pnreemb;

      vpasexec := 6;

      SELECT sseguro, nriesgo, cgarant, sperson, agr_salud
        INTO vsseguro, vnriesgo, vcgarant, vsperson, vagr_salud
        FROM reembolsos r
       WHERE nreemb = pnreemb;

      vpasexec := 7;

      IF NVL(vcerror, 0) = 0 THEN
         DELETE FROM tmp_controlsan
               WHERE smancont = vsmancont;
      END IF;

      vpasexec := 8;
      vctipo := pctipo;   -- BUG10704:DRA:14/07/2009

      IF pfbaja IS NULL THEN   -- BUG10949:JGM:20/08/2009
         verror := pac_control_reembolso.f_validareemb(vctipo, vsseguro, vnriesgo, vcgarant,
                                                       vsperson, vagr_salud, pcacto, pnacto,
                                                       pfacto, pitot, pnreemb, pnfact,
                                                       vnlinea, vsmancont, vnfact_cli,
                                                       pftrans);   -- BUG10761:DRA:27/07/2009
         vpasexec := 9;

         IF verror <> 0 THEN
            BEGIN
               SELECT d.tcontrol, c.ctipo
                 INTO vccontrol, vctipo
                 FROM controlsan c, controlsandes d
                WHERE c.cambito = 'REEM'
                  AND c.agr_salud = vagr_salud
                  AND c.cestado = 1
                  AND c.ccontrol = verror
                  AND d.ccontrol = c.ccontrol
                  AND d.cambito = c.cambito   -- BUG10564:DRA:30/06/2009
                  AND d.agr_salud = c.agr_salud   -- BUG10564:DRA:30/06/2009
                  AND d.cidioma = pac_md_common.f_get_cxtidioma;
            EXCEPTION
               WHEN OTHERS THEN
                  --NO SE HA ENCONTRADO LA DESCRIPCION DEL ERROR AL VALIDAR UN ACTO
                  vpasexec := 10;
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000662);
            END;

            vpasexec := 11;

            IF vccontrol IS NOT NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, verror, vccontrol);
            END IF;
         ELSE
            vctipo := NULL;

            -- BUG12676:DRA:15/03/2010:Inici
            SELECT COUNT(*)
              INTO v_existe
              FROM reembactosfac
             WHERE nreemb = pnreemb
               AND fbaja IS NULL   -- BUG13927:DRA:21/04/2010
               AND cerror <> 0;

            -- Si entra aqui vol dir que s'han acceptat tots els errors i no hi ha cap pendent de revisar
            IF v_existe = 0 THEN
               UPDATE reembolsos
                  SET cestado = 2
                WHERE nreemb = pnreemb;
            END IF;
         -- BUG12676:DRA:15/03/2010:Fi
         END IF;
      ELSE
         vctipo := NULL;
         verror := NVL(vcerror, 0);   -- BUG10949:DRA:25/08/2009:Inici
      END IF;

      vpasexec := 12;
      vnumerr := pac_reembolsos.f_ins_reembactosfac(pnreemb, pnfact, vnlinea, pcacto, pnacto,
                                                    pfacto, pitarcass, ppreemb, picass, pitot,
                                                    piextra, pipago, piahorro, verror, pftrans,   -- BUG10761:DRA:27/07/2009
                                                    vorigen, NULL, pfbaja, pctipo, pipagocomp,
                                                    NULL, NULL);   -- BUG10704:DRA:17/07/2009
      pnlineanew := vnlinea;
      vpasexec := 13;

      IF vctipo = 0 THEN
         ctipomsj := 1;
      ELSIF vctipo = 1 THEN
         IF pac_md_reembolsos.f_isperfilcompany(mensajes) = 1 THEN
            ctipomsj := 2;
         ELSE
            ctipomsj := 1;
         END IF;
      ELSIF vctipo = 2 THEN
         ctipomsj := 2;
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
   END f_set_reembfactact;

   /***********************************************************************
                                                                                                                                                                                                                                                                     Rutina que neteja la taula tmp_controlsan
      param in out mensajes : T_IAX_MENSAJES
      return                : 0 tot correcte
                              1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_neteja_errors(mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_REEMBOLSOS.f_neteja_errors';
      vparam         VARCHAR2(500);
      vpasexec       NUMBER(5) := 1;
   BEGIN
      DELETE FROM tmp_controlsan
            WHERE smancont = vsmancont;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_neteja_errors;

   /***********************************************************************
                     Rutina que retorna les dades d'un reembossament
      param in  pnreeemb    : Codi reembossament
      param in/out mensajes : T_IAX_MENSAJES
      return                : objecte reembossaments
   ***********************************************************************/
   FUNCTION f_get_datos_reemb(
      pnreemb IN reembolsos.nreemb%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reembolsos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - pnreemb: ' || pnreemb;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_get_datos_reemb';
      reemb          ob_iax_reembolsos := ob_iax_reembolsos();
      numreemb       NUMBER;
   BEGIN
      IF pnreemb IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      SELECT COUNT(*)
        INTO numreemb
        FROM reembolsos
       WHERE nreemb = pnreemb;

      IF numreemb = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 120135);
      ELSE
         vpasexec := 2;
         reemb := f_get_datreemb(pnreemb, mensajes);
         reemb.facturas := t_iax_reembfact();

         FOR vfact IN (SELECT nfact
                         FROM reembfact
                        WHERE nreemb = reemb.nreemb) LOOP
            reemb.facturas.EXTEND;
            reemb.facturas(reemb.facturas.LAST) := ob_iax_reembfact();
            reemb.facturas(reemb.facturas.LAST) :=
                  pac_md_reembolsos.f_get_datos_reembfact(reemb.nreemb, vfact.nfact, mensajes);
         END LOOP;
      END IF;

      RETURN reemb;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datos_reemb;

   /***********************************************************************
                     Rutina que Recupera la descripción de la póliza producto y garantía
      param in  psseguro    : Codi seguro
      param in  pcgarant    : Codi garantia
      param in/out mensajes : T_IAX_MENSAJES
      return varchar2       : Descripción de la póliza
   ***********************************************************************/
   FUNCTION f_get_tproducto(
      psseguro IN reembolsos.sseguro%TYPE,
      pcgarant IN reembolsos.cgarant%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                     := 'parámetros - psseguro : ' || psseguro || ' - pcgarant : ' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_get_tproducto';
      vnpoliza       seguros.npoliza%TYPE;
      vcramo         seguros.cramo%TYPE;
      vcmodali       seguros.cmodali%TYPE;
      vctipseg       seguros.ctipseg%TYPE;
      vccolect       seguros.ccolect%TYPE;
      vtproducto     titulopro.ttitulo%TYPE;
      vtgarantia     garangen.tgarant%TYPE;
      vnumerr        NUMBER;
      vncertif       seguros.ncertif%TYPE;   -- Mantis 10682.NMM.01/07/2009.
      v_nombre       VARCHAR2(250);   -- BUG12676:DRA:11/03/2010
   BEGIN
      IF psseguro IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      SELECT npoliza, cramo, cmodali, ctipseg, ccolect,
             ncertif   -- Mantis 10682.NMM.01/07/2009.
        INTO vnpoliza, vcramo, vcmodali, vctipseg, vccolect,
             vncertif   -- Mantis 10682.NMM.01/07/2009.
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;
      vnumerr := f_desproducto(vcramo, vcmodali, 2, pac_md_common.f_get_cxtidioma, vtproducto,
                               vctipseg, vccolect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vnumerr := f_desgarantia(pcgarant, pac_md_common.f_get_cxtidioma, vtgarantia);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      -- BUG12676:DRA:11/03/2010:Inici
      vpasexec := 3;

      IF vncertif <> 0 THEN
         -- Si es un colectivo mostraremos el nombre del tomador del certificado 0
         BEGIN
            SELECT SUBSTR(f_nombre(t.sperson, 1, s.cagente), 1, 250)
              INTO v_nombre
              FROM seguros s, tomadores t
             WHERE s.npoliza = vnpoliza
               AND s.ncertif = 0
               AND t.sseguro = s.sseguro
               AND t.nordtom = 1;
         EXCEPTION
            WHEN OTHERS THEN
               v_nombre := '**';
         END;

         v_nombre := ' - ' || v_nombre;
      END IF;

      -- BUG12676:DRA:11/03/2010:Fi

      -- Mantis 10682.NMM.01/07/2009.Afegim ncertif.
      RETURN vnpoliza || ' - ' || vncertif || ' - ' || vtproducto || ' - ' || vtgarantia
             || v_nombre;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_tproducto;

   /***********************************************************************
                                    Rutina que retorna les factures associades a un reembossament
      param in  pnreeemb    : Codi reembossament
      param in  pnfact      : Número factura
      param in/out mensajes : T_IAX_MENSAJES
      return                : objecte factura
   ***********************************************************************/
   FUNCTION f_get_datos_reembfact(
      pnreemb IN reembactosfac.nreemb%TYPE,
      pnfact IN reembactosfac.nfact%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reembfact IS
      objfact        ob_iax_reembfact := ob_iax_reembfact();
      vparam         VARCHAR2(500)
                             := 'parámetros - pnreemb : ' || pnreemb || ' - pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_get_datos_reembfact';
      vpasexec       NUMBER;
      verror         NUMBER := 0;
      numfact        NUMBER;
      vsseguro       NUMBER;
      vnriesgo       NUMBER;
   BEGIN
      IF pnreemb IS NOT NULL
         AND pnfact IS NULL THEN
         objfact := f_inicializa_reembfact(pnreemb, mensajes);
         RETURN objfact;
      END IF;

      IF pnreemb IS NULL
         OR pnfact IS NULL THEN
         verror := 9000480;
         RAISE e_param_error;
      END IF;

      SELECT COUNT(*)
        INTO numfact
        FROM reembfact
       WHERE nreemb = pnreemb
         AND nfact = pnfact;

      IF numfact = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 120135);
      ELSE
         vpasexec := 2;

         SELECT nreemb, nfact, nfact_cli, ncass_ase,
                ncass, facuse, ffactura, fbaja,
                cusualta, impfact, ctipofac,   -- BUG10704:DRA:14/07/2009
                                            falta,
                corigen, nfactext,   -- BUG10631:DRA:03/07/2009
                                  cimpresion,   -- BUG10704:DRA:22/07/2009
                ctractat   -- BUG17732:DRA:24/02/2011
           INTO objfact.nreemb, objfact.nfact, objfact.nfact_cli, objfact.ncass_ase,
                objfact.ncass, objfact.facuse, objfact.ffactura, objfact.fbaja,
                objfact.cusualta, objfact.impfact, objfact.ctipofac,   -- BUG10704:DRA:14/07/2009
                                                                    objfact.falta,
                objfact.corigen, objfact.nfactext, objfact.cimpresion,   -- BUG10704:DRA:22/07/2009
                objfact.ctractat   -- BUG17732:DRA:24/02/2011
           FROM reembfact
          WHERE nreemb = pnreemb
            AND nfact = pnfact;

         objfact.ttipofac := pac_md_listvalores.f_getdescripvalores(896, objfact.ctipofac,
                                                                    mensajes);
         objfact.torigen := pac_md_listvalores.f_getdescripvalores(893, objfact.corigen,
                                                                   mensajes);
         ---xavier
         objfact.actos := t_iax_reembactfact();

         FOR vact IN (SELECT nlinea
                        FROM reembactosfac
                       WHERE nreemb = objfact.nreemb
                         AND nfact = objfact.nfact) LOOP
            objfact.actos.EXTEND;
            objfact.actos(objfact.actos.LAST) := ob_iax_reembactfact();
            objfact.actos(objfact.actos.LAST) :=
               pac_md_reembolsos.f_get_datos_reembactfact(objfact.nreemb, objfact.nfact,
                                                          vact.nlinea, mensajes);
         END LOOP;
      END IF;

      RETURN objfact;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datos_reembfact;

   /***********************************************************************
                                                   Rutina que retorna els actes associats a un reembossament
      param in  pnreeemb    : Codi reembossament
      param in  pnfact      : Número factura
      param in  pnlinea     : Número línia
      param in/out mensajes : T_IAX_MENSAJES
      return                : objecte acte
   ***********************************************************************/
   FUNCTION f_get_datos_reembactfact(
      pnreemb IN reembactosfac.nreemb%TYPE,
      pnfact IN reembactosfac.nfact%TYPE,
      pnlinea IN reembactosfac.nlinea%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reembactfact IS
      objacto        ob_iax_reembactfact := ob_iax_reembactfact();
      vparam         VARCHAR2(500)
         := 'parámetros - pnreemb : ' || pnreemb || ' - pnfact : ' || pnfact || ' - pnlinea :'
            || pnlinea;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_get_datos_reembactfact';
      vpasexec       NUMBER := 1;
      verror         NUMBER := 0;
      numacto        NUMBER;
      vagr_salud     VARCHAR2(20);
   BEGIN
      IF pnreemb IS NULL
         OR pnfact IS NULL
         OR pnlinea IS NULL THEN
         verror := 9000480;
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT COUNT(*)
        INTO numacto
        FROM reembactosfac
       WHERE nreemb = pnreemb
         AND nfact = pnfact
         AND nlinea = pnlinea;

      -- BUG10564:DRA:30/06/2009:Inici
      vpasexec := 3;

      SELECT agr_salud
        INTO vagr_salud
        FROM reembolsos
       WHERE nreemb = pnreemb;

      -- BUG10564:DRA:30/06/2009:Fi
      vpasexec := 4;

      IF numacto = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 120135);
      ELSE
         SELECT r.nreemb, r.nfact, r.nlinea, r.cacto, r.nacto,
                r.facto, r.itarcass, r.preemb, r.icass, r.itot,
                r.iextra, r.ipago, r.iahorro, r.cerror,
                r.fbaja, r.falta, r.ftrans, r.cusualta,
                r.corigen, f_desacto(r.cacto, pac_md_common.f_get_cxtidioma()) AS tacto,
                r.nremesa,   --BUG11285-XVM-02102009
                (SELECT c.tcontrol
                   FROM controlsandes c
                  WHERE c.ccontrol = r.cerror
                    AND c.cambito = 'REEM'   -- BUG10564:DRA:30/06/2009
                    AND c.agr_salud = vagr_salud   -- BUG10564:DRA:30/06/2009
                    AND c.cidioma = pac_md_common.f_get_cxtidioma()) AS tcontrol,
                r.ctipo, r.ipagocomp, r.ftranscomp, r.nremesacomp,   -- BUG10704:DRA:22/07/2009
                ff_desvalorfijo(895, pac_md_common.f_get_cxtidioma(), r.ctipo) AS ttipo
           INTO objacto.nreemb, objacto.nfact, objacto.nlinea, objacto.cacto, objacto.nacto,
                objacto.facto, objacto.itarcass, objacto.preemb, objacto.icass, objacto.itot,
                objacto.iextra, objacto.ipago, objacto.iahorro, objacto.cerror,
                objacto.fbaja, objacto.falta, objacto.ftrans, objacto.cusualta,
                objacto.corigen, objacto.tdesacto,
                objacto.nremesa,
                objacto.terror,
                objacto.ctipo, objacto.ipagocomp, objacto.ftranscomp, objacto.nremesacomp,
                objacto.ttipo   -- BUG10704:DRA:22/07/2009
           FROM reembactosfac r
          WHERE nreemb = pnreemb
            AND nfact = pnfact
            AND nlinea = pnlinea;

         vpasexec := 5;
         objacto.torigen := pac_md_listvalores.f_getdescripvalores(893, objacto.corigen,
                                                                   mensajes);
      END IF;

      RETURN objacto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datos_reembactfact;

   /***********************************************************************
                                                                                                                                                                 Rutina que retorna les garanties possibles d'un reembossament
      param in  psseguro  : codi del segur
      param in  pnriesgo  : codi del risc
      param in  pfreembo  : data reembossament
      param in out mensajes  : T_IAX_MENSAJES
      return              : ref cursor
   ***********************************************************************/
   FUNCTION f_get_garanreemb(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfreembo IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
      buscar         VARCHAR2(1000);
      pcpargar       VARCHAR2(20) := 'GAR_REEMB';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - psseguro:' || psseguro || ' - pnriesgo:' || pnriesgo
            || ' - pfreembo:' || pfreembo;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Get_Garanreemb';
   BEGIN
      buscar := 'WHERE g.SSEGURO = ' || psseguro || ' AND g.NRIESGO = ' || pnriesgo;
      --      buscar := buscar || ' AND g.FINIEFE < trunc(to_date('''||to_char(pfreembo, 'dd/mm/yyyy')||''', ''dd/mm/yyyy''))'
      --                       || ' AND (g.FFINEFE IS NULL OR g.FFINEFE > trunc(to_date('''||to_char(pfreembo, 'dd/mm/yyyy')||''', ''dd/mm/yyyy'')))';
      buscar := buscar || ' AND g.CGARANT = a.CGARANT AND a.CIDIOMA = '
                || pac_md_common.f_get_cxtidioma || ' AND s.SSEGURO = ' || psseguro;
      buscar :=
         buscar
         || ' AND s.CRAMO   = p.CRAMO AND s.CMODALI = p.CMODALI AND s.CTIPSEG = p.CTIPSEG AND s.CCOLECT = p.CCOLECT AND g.cgarant = p.cgarant';
      buscar :=
         buscar
         || ' AND s.CACTIVI = p.CACTIVI AND b.CGARANT = p.CGARANT AND p.CPARGAR = ''GAR_REEMB'' AND NVL(p.cVALPAR,0) = 1';
      squery :=
         'SELECT distinct a.CGARANT CGARANT, a.TGARANT TGARANT
                FROM GARANSEG g, GARANGEN a, PARGARANPRO p, GARANPRO b, SEGUROS s '
         || buscar;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_garanreemb;

   /***********************************************************************
                                    Rutina que retorna los tipos de centro de factura
      param in out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lsttipofact(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Get_LstTipoFact';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(896, mensajes);   -- BUG10704:DRA:15/07/2009
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
   END f_get_lsttipofact;

   /***********************************************************************
                                                                                                                                                                                                                                                                                                                       Rutina que retorna exclusivamente les dades d'un reembossament
      param in  pnreeemb    : Codi reembossament
      param in out mensajes : T_IAX_MENSAJES
      return                : objecte reembossaments
   ***********************************************************************/
   FUNCTION f_get_datreemb(pnreemb IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reembolsos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parámetros - pnreeemb:' || pnreemb;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Get_DatReemb';
      reemb          ob_iax_reembolsos := ob_iax_reembolsos();
      numreemb       NUMBER;
      vnriesgotitular NUMBER;
      vpregun        NUMBER;

      CURSOR c_reembolso IS
         SELECT r.nreemb, r.sseguro, r.nriesgo, r.cgarant, r.agr_salud, r.sperson, r.cestado,
                r.festado, r.tobserv, r.cbancar, r.ctipban, r.falta, r.cusualta, r.corigen,
                s.cagente, s.npoliza, s.sproduc, r.cbanhosp
           FROM reembolsos r, seguros s
          WHERE r.nreemb = pnreemb
            AND r.sseguro = s.sseguro;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnreemb IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(*)
        INTO numreemb
        FROM reembolsos
       WHERE nreemb = pnreemb;

      IF numreemb = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 120135);
      ELSE
         vpasexec := 2;

         FOR cur IN c_reembolso LOOP
            reemb.nreemb := cur.nreemb;
            reemb.sseguro := cur.sseguro;
            reemb.nriesgo := cur.nriesgo;
            reemb.cgarant := cur.cgarant;
            reemb.agr_salud := cur.agr_salud;
            reemb.sperson := cur.sperson;
            reemb.cestado := cur.cestado;
            reemb.festado := cur.festado;
            reemb.tobserv := cur.tobserv;
            reemb.cbancar := cur.cbancar;
            reemb.ctipban := cur.ctipban;
            reemb.falta := cur.falta;
            reemb.cusualta := cur.cusualta;
            reemb.corigen := cur.corigen;
            reemb.coficina := cur.cagente;
            reemb.npoliza := cur.npoliza;
            reemb.sproduc := cur.sproduc;   -- BUG16576:DRA:31/01/2011
            reemb.cbanhosp := cur.cbanhosp;   -- BUG17732:DRA:24/02/2011
            vpasexec := 3;
            reemb.torigen := pac_md_listvalores.f_getdescripvalores(893, cur.corigen,
                                                                    mensajes);
            vpasexec := 4;
            reemb.testado := pac_md_listvalores.f_getdescripvalores(891, cur.cestado,
                                                                    mensajes);
            vpasexec := 5;
            reemb.tproducto := pac_md_reembolsos.f_get_tproducto(cur.sseguro, cur.cgarant,
                                                                 mensajes);

            BEGIN
               -- BUG 8309 - 04/05/2009 - SBG - Pot haver-hi més d'un risc amb la mateixa
               -- resposta a la pregunta "Relació amb el titular". En tal cas agafarem el
               -- risc 1, que és el titular.

               -- BUG 10949  20/08/2009 - JGM
               IF cur.sproduc = 258 THEN
                  vpregun := 540;
               ELSE
                  vpregun := 505;
               END IF;

               -- FIN BUG 10949
               BEGIN
                  SELECT nriesgo
                    INTO vnriesgotitular
                    FROM pregunseg
                   WHERE cpregun = vpregun
                     AND crespue = 0
                     AND sseguro = cur.sseguro
                     AND nmovimi IN(SELECT MAX(nmovimi)
                                      FROM pregunseg
                                     WHERE cpregun = vpregun
                                       AND sseguro = cur.sseguro
                                       AND crespue = 0);
               EXCEPTION
                  WHEN TOO_MANY_ROWS THEN
                     vnriesgotitular := 1;
               END;

               -- FINAL BUG 8309 - 04/05/2009 - SBG
               SELECT trespue
                 INTO reemb.ncass_ase   --Bug 27846  MCA 17/10/2013
                 FROM pregunseg
                WHERE cpregun = 530
                  AND sseguro = cur.sseguro
                  AND nriesgo = vnriesgotitular
                  AND nmovimi IN(SELECT MAX(nmovimi)
                                   FROM pregunseg
                                  WHERE cpregun = 530
                                    AND sseguro = cur.sseguro
                                    AND nriesgo = vnriesgotitular);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  reemb.ncass_ase := NULL;
            END;

            BEGIN
               SELECT trespue
                 INTO reemb.ncass   --Bug 27846  MCA 17/10/2013
                 FROM pregunseg
                WHERE sseguro = cur.sseguro
                  AND nriesgo = cur.nriesgo
                  AND cpregun = 530
                  AND nmovimi IN(SELECT MAX(nmovimi)
                                   FROM pregunseg
                                  WHERE sseguro = cur.sseguro
                                    AND nriesgo = cur.nriesgo
                                    AND cpregun = 530);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  reemb.ncass := NULL;
            END;

            reemb.nombre_aseg := pac_md_obtenerdatos.f_desriesgos('POL', cur.sseguro,
                                                                  cur.nriesgo, mensajes);
            reemb.nombre_tom := pac_md_listvalores.f_get_nametomador(cur.sseguro, 1);

            IF reemb.agr_salud <> 0 THEN
               SELECT tvalpar
                 INTO reemb.desagr_salud
                 FROM detparpro
                WHERE cparpro = 'AGR_SALUD'
                  AND cidioma = pac_md_common.f_get_cxtidioma
                  AND cvalpar = reemb.agr_salud;
            ELSE
               reemb.desagr_salud := NULL;
            END IF;
         END LOOP;
      END IF;

      RETURN reemb;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datreemb;

   /***********************************************************************
                                                                                 Rutina que retorna la lista de actos
      param in out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstactos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
      buscar         VARCHAR2(1000);   --:= ' where rownum<=101 ';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Get_LstActos';
      ordenar        VARCHAR2(1000) := ' order by d.tacto ';
   BEGIN
      buscar := buscar || ' WHERE d.cidioma = ' || pac_md_common.f_get_cxtidioma
                || ' AND c.cacto = d.cacto ';
      squery := 'SELECT c.cacto, d.tacto
                FROM codactos c, desactos d' || buscar || ordenar;
      vpasexec := 2;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_lstactos;

    /***********************************************************************
                                                                                                                                                                           Rutina que devuelve los valores por defecto del acto
      param in  pnreemb      : código reembolso
      param in  pcacto       : Código acto
      param in  pfacto       : Fecha de acto
      param out oiextra      : Importe Extra
      param out oitotal      : Importe total
      param in out mensajes  : T_IAX_MENSAJES
      return                 : 0 tot correcte
                               1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_get_importacto(
      pnreemb IN NUMBER,
      pcacto IN VARCHAR2,
      pfacto IN DATE,
      oitarcass OUT NUMBER,
      oicass OUT NUMBER,
      opreemb OUT NUMBER,
      oiextra OUT NUMBER,
      onacto OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_REEMBOLSOS.F_Get_Importacto';
      vparam         VARCHAR2(500)
         := 'parámetros - pcacto:' || pcacto || ' - pnreemb:' || pnreemb || ' - pfacto:'
            || pfacto;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      voporcentaje   NUMBER;
      voiextra       NUMBER;
      voitotal       NUMBER;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pcacto IS NULL
         OR pfacto IS NULL THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         -- BUG 8309 - 05/05/2009 - SBG - Informem el percentatge OPREEMB amb el valor
         -- (100 - actos_garanpro.pabonado)
         SELECT a.impregalo, a.ireemb, 100 - a.pabonado
           INTO oiextra, oitarcass, opreemb
           FROM actos_garanpro a, reembolsos r
          WHERE a.cacto = pcacto
            AND TRUNC(a.fvigencia) <= TRUNC(pfacto)
            AND(TRUNC(a.ffinvig) > TRUNC(pfacto)   -- BUG11551:DRA:13/11/2009
                OR a.ffinvig IS NULL)
            AND a.agr_salud = r.agr_salud
            AND a.cgarant = r.cgarant
            AND r.nreemb = pnreemb;

         -- FINAL BUG 8309 - 05/05/2009 - SBG

         -- BUG10949:DRA:24/08/2009:Inici
         IF NVL(opreemb, 0) < 0 THEN
            opreemb := 75;
         END IF;

         -- BUG10949:DRA:24/08/2009:Fi

         --1,0 a piñon de momento
         onacto := 1;
         oicass := 0;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            oiextra := 0;
            oitarcass := 0;
            opreemb := 0;
            --1,0 a piñon de momento
            onacto := 1;
            oicass := 0;
            RETURN 0;
         WHEN TOO_MANY_ROWS THEN
            oiextra := 0;
            oitarcass := 0;
            opreemb := 0;
            --1,0 a piñon de momento
            onacto := 1;
            oicass := 0;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000658);
            RETURN 0;
      END;

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
   END f_get_importacto;

   /***********************************************************************
                                                                  Rutina que retorna las agrupaciones de producto AGR_SALUD
      param in out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstagrsalud(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      squery         VARCHAR2(1000);
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Get_LstAgrSalud';
   BEGIN
      squery :=
         'SELECT cvalpar, tvalpar
                FROM detparpro WHERE cparpro = ''AGR_SALUD'' AND cidioma = '
         || pac_md_common.f_get_cxtidioma;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_lstagrsalud;

      /***********************************************************************
                     Rutina que calcula los importes del acto
      param in  pnrremb      : número reembossament
      param in  pcacto       : Código acto
      param in  pfacto       : Fecha de acto
      param in  pnactos      : Número de actos
      param in  pitarcass    : Importe tarifa CASS
      param in  picass       : Importe cass
      param in  pipago       : Importe pago
      param in  pporcent     : Porcentaje pago
      param out oicass       : Importe CASS
      param out oipago       : Importe pago
      param out oitot        : Importe total
      param in out mensajes  : T_IAX_MENSAJES
      return                 : 0 tot correcte
                               1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_calcacto(
      pnreemb IN NUMBER,
      pcacto IN VARCHAR2,
      pfacto IN DATE,
      pnactos IN NUMBER,
      pitarcass IN NUMBER,
      picass IN NUMBER,
      pipago IN NUMBER,
      pporcent IN NUMBER,
      oicass OUT NUMBER,   -- BUG10761:DRA:22/07/2009
      oipago OUT NUMBER,
      oitot OUT NUMBER,
      oitarcass OUT NUMBER,
      oiextra OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_REEMBOLSOS.F_CalcActo';
      vparam         VARCHAR2(500)
         := 'parámetros - pnreemb:' || pnreemb || ' - pcacto:' || pcacto || ' - pfacto:'
            || pfacto || ' - pnactos:' || pnactos || ' - pitarcass:' || pitarcass
            || ' - picass:' || picass || ' - pipago:' || pipago || ' - pporcent:' || pporcent;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_ireemb       NUMBER;
      --v_pabonado     NUMBER;
      v_impregal     NUMBER;
      --- inicio  0016838
      v_porcent      NUMBER := 1;
      v_agrsalud     NUMBER;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pcacto IS NULL
         OR pfacto IS NULL
         OR pnreemb IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT NVL(a.ireemb, 0), NVL(a.impregalo, 0), r.agr_salud   --, NVL(a.pabonado, 0)
        INTO v_ireemb, v_impregal, v_agrsalud   --, v_pabonado
        FROM actos_garanpro a, reembolsos r
       WHERE a.cacto = pcacto
         AND TRUNC(a.fvigencia) <= TRUNC(pfacto)
         AND(TRUNC(a.ffinvig) > TRUNC(pfacto)   -- BUG10949:DRA:31/08/2009
             OR a.ffinvig IS NULL)
         AND a.agr_salud = r.agr_salud
         AND a.cgarant = r.cgarant
         AND r.nreemb = pnreemb;

      --BUG : 0016838
      IF NVL(v_agrsalud, 0) = 5 THEN
         v_porcent := 1.5;
      ELSE
         v_porcent := 1;
      END IF;

      -- BUG10949:DRA:01/09/2009:Inici
      IF NVL(pitarcass, 0) <> 0 THEN
         v_ireemb := pitarcass;
      ELSIF NVL(pipago, 0) <> 0 THEN
         v_ireemb := NVL(pipago, 0) * 100 /(100 - NVL(pporcent, 0));
      ELSIF NVL(v_ireemb, 0) <> 0 THEN
         v_ireemb := v_ireemb;   -- Es tonteria, pero para que quede claro
      ELSE
         v_ireemb := 0;
      END IF;

      -- BUG10949:DRA:01/09/2009:Fi
      IF NVL(pipago, 0) = 0 THEN
         -- BUG 8309 - 05/05/2009 - SBG - Es modifica el càlcul del ipago.
         -- (S'han incorporat els paràms. PPORCENT i PITARCASS). Càlcul anterior:
         -- oipago := (pnactos * v_ireemb * v_pabonado / 100) + v_impregal;
         oipago := (pnactos * v_ireemb *(100 - NVL(pporcent, 0)) / 100) + NVL(v_impregal, 0);
      -- FINAL BUG 8309 - 05/05/2009 - SBG
      ELSE
         oipago := pipago + NVL(v_impregal, 0);
      END IF;

      -- BUG10761:DRA:22/07/2009:Inici
      -- BUG10949:DRA:01/09/2009: Ara sempre es calcula el Import CASS
      -- IF NVL(picass, 0) = 0 THEN
      oicass := v_ireemb -(oipago - NVL(v_impregal, 0));

      IF oicass < 0 THEN
         oicass := 0;
      END IF;

      -- --BUG : 0016838  ::::se vuelve a calcular el importe del pago para los 150% de la cass
      IF NVL(v_agrsalud, 0) = 5
         AND NVL(pipago, 0) = 0 THEN
         oipago := (pnactos * v_ireemb * v_porcent) - oicass + NVL(v_impregal, 0);
      END IF;

      -- BUG10761:DRA:22/07/2009:Fi
      oiextra := v_impregal;
      oitarcass := v_ireemb;
      oitot := oicass + oipago;
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
   END f_calcacto;

   /*************************************************************************
                                     Devuelve las pólizas que cumplan con el criterio de selección
       param in psproduc     : código de producto
       param in pnpoliza     : número de póliza
       param in pncert       : número de cerificado por defecto 0
       param in pnnumide     : número identidad persona
       param in psnip        : número identificador externo
       param in pbuscar      : nombre+apellidos a buscar de la persona
       param in ptipopersona : tipo de persona
                                1 tomador
                                2 asegurado
       param out mensajes    : mensajes de error
       return                : ref cursor
    *************************************************************************/
   FUNCTION f_consultapolizaasegurados(
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncert IN NUMBER DEFAULT -1,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      ptipopersona IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      cur            sys_refcursor;
      squery         VARCHAR2(2500);
      buscar         VARCHAR2(1000);
      subus          VARCHAR2(500);
      tabtp          VARCHAR2(10);
      auxnom         VARCHAR2(200);
      nerr           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psproduc=' || psproduc || ' pnpoliza: ' || pnpoliza || ' pncert=' || pncert
            || ' pnnumide=' || pnnumide || ' psnip=' || psnip || ' pbuscar=' || pbuscar
            || ' ptipopersona=' || ptipopersona;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_CONSULTAPOLIZAASEGURADOS';
      v_accion       NUMBER;   -- BUG10761:DRA:21/07/2009
      v_permite      NUMBER(8);   -- BUG10761:DRA:21/07/2009
   BEGIN
      IF NVL(psproduc, 0) <> 0 THEN
         buscar := buscar || ' and s.sproduc =' || psproduc;
      END IF;

      IF pnpoliza IS NOT NULL THEN
         buscar := buscar || ' and s.npoliza = ' || CHR(39) || pnpoliza || CHR(39);
      END IF;

      IF NVL(pncert, -1) <> -1 THEN
         buscar := buscar || ' and s.ncertif =' || pncert;
      END IF;

      -- buscar per personas
      IF (pnnumide IS NOT NULL
          OR NVL(psnip, ' ') <> ' '
          OR pbuscar IS NOT NULL)
         AND NVL(ptipopersona, 0) > 0 THEN
         --
         IF ptipopersona = 1 THEN   -- Prenedor
            tabtp := 'TOMADORES';
         ELSIF ptipopersona = 2 THEN   -- Assegurat
            tabtp := 'ASEGURADOS';
         END IF;

         IF tabtp IS NOT NULL THEN
            -- Bug 0012803 - 19/02/2010 - JMF: AGA - Acceso a la vista PERSONAS
            subus := ' and s.sseguro IN (SELECT a.sseguro FROM ' || tabtp
                     || ' a, per_personas p WHERE a.sperson = p.sperson';

            -- BUG11183:DRA:30/09/2009:Inici
            IF ptipopersona = 2 THEN   -- Asegurat
               subus := subus || ' AND a.ffecfin IS NULL';
            END IF;

            -- BUG11183:DRA:30/09/2009:Inici
            IF pnnumide IS NOT NULL THEN
               -- Bug 0012803 - 19/02/2010 - JMF
               -- BUG13002:DRA:18/05/2010:Inici
               -- subus := subus || ' AND p.nnumide ='|| chr(39) || pnnumide || chr(39);
               --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                    'NIF_MINUSCULAS'),
                      0) = 1 THEN
                  subus := subus || ' AND p.sperson IN (SELECT pi.sperson'
                           || ' FROM per_identificador pi WHERE UPPER(pi.nnumide) = UPPER('''
                           || pnnumide || '''))';
               ELSE
                  subus := subus || ' AND p.sperson IN (SELECT pi.sperson'
                           || ' FROM per_identificador pi WHERE ' || ' pi.nnumide = '''
                           || pnnumide || ''') ';
               END IF;
            -- BUG13002:DRA:18/05/2010:Fi
            END IF;

            IF NVL(psnip, ' ') <> ' ' THEN
               subus := subus || ' AND p.snip=' || CHR(39) || psnip || CHR(39);
            END IF;

            IF pbuscar IS NOT NULL THEN
               nerr := f_strstd(pbuscar, auxnom);
               -- ini Bug 0012803 - 19/02/2010 - JMF
               -- subus := subus || ' AND p.tbuscar like ''%' || auxnom || '%''';
               subus :=
                  subus
                  || ' AND EXISTS (select 1 from per_detper dp where dp.sperson=p.sperson'
                  || '             AND dp.cagente = ff_agente_cpervisio (s.cagente, f_sysdate, s.cempres)'
                  || '             AND dp.tbuscar like ''%' || auxnom || '%'')';
            -- fin Bug 0012803 - 19/02/2010 - JMF
            END IF;

            subus := subus || ')';
         END IF;
      END IF;

      -- BUG10761:DRA:21/07/2009:Inici
      -- Si se encuentra el registro, significa que solo debemos mostrar las VIGENTES
      v_accion := pac_cfg.f_get_user_accion_permitida(f_user, 'SOLO_VIGENTE', psproduc,
                                                      pac_md_common.f_get_cxtempresa,
                                                      v_permite);

      IF NVL(v_accion, 0) = 1 THEN
         buscar := buscar || ' AND f_vigente (s.sseguro, null, f_sysdate) = 0';
      END IF;

      -- BUG10761:DRA:21/07/2009:Fi
      -- Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación
      --                                se añade la subselect con la tabla agentes_agente
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
      squery :=
         'select * from (select s.sseguro, s.npoliza, s.ncertif, '
         || 'pac_md_listvalores.F_Get_NameTomador(s.sseguro,1) as nombre, '
         -- || 'pac_md_listvalores.F_Get_SituacionPoliza(s.sseguro) as situacion, ' -- BUG11552:DRA:23/11/2009
         || 'decode (s.csituac, 2, pac_md_listvalores.F_Get_SituacionPoliza(s.sseguro),'   -- BUG11552:DRA:23/11/2009
         || 'decode (r.fanulac, NULL, pac_md_listvalores.F_Get_SituacionPoliza(s.sseguro),'   -- BUG11552:DRA:23/11/2009
         || 'ff_desvalorfijo (61, pac_md_common.f_get_cxtidioma, 2))) as situacion, '   -- BUG11552:DRA:23/11/2009
         || 'f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,pac_md_common.f_get_cxtidioma) as desproducto, '
         || 'r.nriesgo as num_riesgo, NVL (r.sperson, a.sperson) as sperson, '
         || 'f_nombre(NVL (r.sperson, a.sperson), 1, s.cagente) as nombre_asegurado '
         || 'from seguros s, riesgos r, asegurados a where r.sseguro = s.sseguro '
         || 'AND (s.cagente,s.cempres) in (select cagente,cempres from agentes_agente_pol) '
         || 'AND a.sseguro = s.sseguro AND a.norden = (SELECT MIN (a2.norden) from asegurados a2 WHERE a2.sseguro = s.sseguro) '
         || 'AND EXISTS(select 1 from parproductos p where p.cparpro = ''AGR_SALUD'' AND p.sproduc = s.sproduc) '
         || buscar || subus || ') tablaDatos where rownum<='
         || NVL(pac_parametros.f_parinstalacion_n('N_MAX_REG'), 100);
      -- Bug 10127 - APD - 19/05/2009 - fin
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);

      IF pac_md_log.f_log_consultas(squery, 'PAC_MD_REEMBOLSOS.F_CONSULTAPOLIZAASEGURADOS', 1,
                                    2, mensajes) <> 0 THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

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
   END f_consultapolizaasegurados;

   /***********************************************************************
                                    Rutina que retorna les dades d'un reembossament
      param in  pnreeemb    : Codi reembossament
      param in/out mensajes : T_IAX_MENSAJES
      return                : objecte reembossaments
   ***********************************************************************/
   FUNCTION f_inicializa_reemb(
      psseguro IN reembolsos.sseguro%TYPE,
      pnriesgo IN reembolsos.nriesgo%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reembolsos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parámetros - psseguro: ' || psseguro || ' - riesgo: ' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_inicializa_reemb';
      vnumerr        NUMBER;
      reemb          ob_iax_reembolsos := ob_iax_reembolsos();
      numreemb       NUMBER;
      vnom_ase       VARCHAR2(100);
      vnom_tom       VARCHAR2(100);
      vncass         VARCHAR2(20);
      vncass_ase     VARCHAR2(20);
      vctipban       NUMBER;
      vcbancar       VARCHAR2(40);
      vnriesgotitular NUMBER;
      -- bug 0010266: etm : 02-06-2009--INI
      v_movimi       NUMBER(4);
      -- bug 0010266: etm : 02-06-2009--FIN
      -- Mantis 10682.NMM.01/07/2009.i.
      w_cramo        productos.cramo%TYPE;
      w_cmodali      productos.cmodali%TYPE;
      w_ctipseg      productos.ctipseg%TYPE;
      w_ccolect      productos.ccolect%TYPE;
      w_cgarant      pargaranpro.cgarant%TYPE;
      w_cactivi      seguros.cactivi%TYPE;
      w_sproduc      NUMBER(6);   -- BUG16576:DRA:31/01/2011
   --
   BEGIN
      -- BUG17732:DRA:24/02/2011:Inici
      vnumerr := pac_reembolsos.f_obtener_ccc(psseguro, NULL, vctipban, vcbancar);
      -- BUG17732:DRA:24/02/2011:Fi
      vpasexec := 2;

      BEGIN
         -- BUG 8309 - 04/05/2009 - SBG - Pot haver-hi més d'un risc amb la mateixa
         -- resposta a la pregunta "Relació amb el titular". En tal cas agafarem el
         -- risc 1, que és el titular.
         BEGIN
            SELECT nriesgo
              INTO vnriesgotitular
              FROM pregunseg
             WHERE cpregun = 505
               AND crespue = 0
               AND sseguro = psseguro
               AND nmovimi IN(SELECT MAX(nmovimi)
                                FROM pregunseg
                               WHERE cpregun = 505
                                 AND sseguro = psseguro
                                 AND crespue = 0);
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               vnriesgotitular := 1;
         END;

         -- FINAL BUG 8309 - 04/05/2009 - SBG
         SELECT trespue
           INTO vncass
           FROM pregunseg
          WHERE cpregun = 530
            AND sseguro = psseguro
            AND nriesgo = vnriesgotitular
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = 530
                              AND sseguro = psseguro
                              AND nriesgo = vnriesgotitular);
      EXCEPTION
         WHEN OTHERS THEN
            vpasexec := 3;
            vncass := NULL;
      END;

      BEGIN
         SELECT trespue
           INTO vncass_ase
           FROM pregunseg
          WHERE cpregun = 530
            AND sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = 530
                              AND sseguro = psseguro
                              AND nriesgo = pnriesgo);
      EXCEPTION
         WHEN OTHERS THEN
            vpasexec := 4;
            vncass_ase := NULL;
      END;

      reemb.sseguro := psseguro;
      reemb.nriesgo := pnriesgo;
      reemb.cestado := pac_md_reembolsos.f_isperfilcompany(mensajes);
      reemb.festado := f_sysdate;
      reemb.falta := f_sysdate;
      reemb.testado := pac_md_listvalores.f_getdescripvalores(891, reemb.cestado, mensajes);
      reemb.corigen := 1;
      reemb.torigen := pac_md_listvalores.f_getdescripvalores(893, reemb.cestado, mensajes);
      reemb.nombre_aseg := pac_md_obtenerdatos.f_desriesgos('POL', psseguro, pnriesgo,
                                                            mensajes);
      reemb.nombre_tom := pac_md_listvalores.f_get_nametomador(psseguro, 1);
      reemb.ncass := vncass;
      reemb.ncass_ase := vncass_ase;
      reemb.ctipban := vctipban;
      reemb.cbancar := vcbancar;
      reemb.cbanhosp := 0;   -- BUG17732:DRA:24/02/2011

      -- Mantis 10682.NMM.01/07/2009.i.
      SELECT cramo, cmodali, ctipseg, ccolect, cactivi, sproduc
        INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, w_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      -- BUG16576:DRA:19/01/2011:Inici
      BEGIN
         SELECT cgarant
           INTO w_cgarant
           FROM pargaranpro
          WHERE cpargar = 'GAR_REEMB'
            AND cramo = w_cramo
            AND cmodali = w_cmodali
            AND ctipseg = w_ctipseg
            AND ccolect = w_ccolect
            AND cactivi = w_cactivi;
      EXCEPTION
         WHEN OTHERS THEN
            w_cgarant := NULL;   -- Ante cualquier error que seleccionen la garantia en pantalla
      END;

      reemb.sproduc := w_sproduc;
      -- BUG16576:DRA:19/01/2011:Fi
      reemb.cgarant := w_cgarant;
      -- Mantis 10682.NMM.01/07/2009.f.
      reemb.facturas := t_iax_reembfact();
      RETURN(reemb);
   --
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_inicializa_reemb;

   /***********************************************************************
                     Rutina que retorna les dades inicialització d'una factura
      param in  pnreeemb    : Codi reembossament
      param in/out mensajes : T_IAX_MENSAJES
      return                : objecte factures de reembossaments
   ***********************************************************************/
   FUNCTION f_inicializa_reembfact(
      pnreemb IN reembolsos.nreemb%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reembfact IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - pnreeemb: ' || pnreemb;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_inicializa_reembfact';
      objfact        ob_iax_reembfact := ob_iax_reembfact();
      vsseguro       NUMBER;
      vnriesgo       NUMBER;
      vnriesgotitular NUMBER;
      vsproduc       NUMBER;
      vpregun        NUMBER;
   BEGIN
      IF pnreemb IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT sseguro, nriesgo
        INTO vsseguro, vnriesgo
        FROM reembolsos
       WHERE nreemb = pnreemb;

      -- BUG 10949
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = vsseguro;

      IF vsproduc = 258 THEN
         vpregun := 540;
      ELSE
         vpregun := 505;
      END IF;

      -- FIN BUG 10949
      BEGIN
         SELECT nriesgo
           INTO vnriesgotitular
           FROM pregunseg
          WHERE cpregun = vpregun
            AND crespue = 0
            AND sseguro = vsseguro
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = vpregun
                              AND sseguro = vsseguro
                              AND crespue = 0);
      -- BUG 8309 - 04/05/2009 - SBG - Pot haver-hi més d'un risc amb la mateixa
      -- resposta a la pregunta "Relació amb el titular". En tal cas agafarem el
      -- risc 1, que és el titular.
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            vnriesgotitular := 1;
      END;

      BEGIN
         -- FINAL BUG 8309 - 04/05/2009 - SBG
         SELECT trespue
           INTO objfact.ncass_ase
           FROM pregunseg
          WHERE cpregun = 530
            AND sseguro = vsseguro
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = 530
                              AND sseguro = vsseguro
                              AND nriesgo = vnriesgotitular)
            AND nriesgo = vnriesgotitular;
      EXCEPTION
         WHEN OTHERS THEN
            objfact.ncass_ase := NULL;
      END;

      BEGIN
         SELECT trespue
           INTO objfact.ncass
           FROM pregunseg
          WHERE cpregun = 530
            AND sseguro = vsseguro
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = 530
                              AND sseguro = vsseguro
                              AND nriesgo = vnriesgo)
            AND nriesgo = vnriesgo;
      EXCEPTION
         WHEN OTHERS THEN
            objfact.ncass := NULL;
      END;

      RETURN objfact;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_inicializa_reembfact;

   /***********************************************************************
                                                   Rutina que Devuelve el tipo de perfil para el usuario conectado a la aplicación
      param in/out mensajes : T_IAX_MENSAJES
      return                : 1 gestión compañia
                              0 gestión oficina
   ***********************************************************************/
   FUNCTION f_isperfilcompany(mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_IsperfilCompany';
      vperfil        NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vperfil
        FROM controlsan_user
       WHERE cusuari = pac_md_common.f_get_cxtusuario;

      IF vperfil > 0 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_isperfilcompany;

   /***********************************************************************
                     Valida los reembolsos de una compañia
      param in ptipo,
      param in psseguro,
      param in pnriesgo,
      param in pcgarant,
      param in psperson,
      param in pagr_salud,
      param in pcacto,
      param in pnacto,
      param in pfacto,
      param in piimporte,
      param in pnreemb,
      param in pnfact,
      param in pnlinea,
      param in psmancont,
      param in pftrans,
      param out mensajes : T_IAX_MENSAJES
      return             : 0 - correcto
                número error - incorrecto
   ***********************************************************************/
   FUNCTION f_valida_reemb(
      ptipo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      psperson IN NUMBER,
      pagr_salud IN NUMBER,
      pcacto IN VARCHAR2,
      pnacto IN NUMBER,
      pfacto IN DATE,
      piimporte IN NUMBER,
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pnlinea IN NUMBER,
      psmancont IN NUMBER,
      pftrans IN DATE,   -- BUG10761:DRA:27/07/2009
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - ptipo:' || ptipo || ' - psseguro:' || psseguro || ' - pnriesgo:'
            || pnriesgo || ' - pcgarant:' || pcgarant || ' - psperson:' || psperson
            || ' - pagr_salud:' || pagr_salud || ' - pcacto:' || pcacto || ' - pnacto:'
            || pnacto || ' - pfacto:' || pfacto || ' - piimporte:' || piimporte
            || ' - pnreemb:' || pnreemb || ' - pnfact:' || pnfact || ' - pnlinea:' || pnlinea
            || ' - psmancont:' || psmancont || ' - pftrans:' || pftrans;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Valida_reemb';
      resul          NUMBER;
      vnfact_cli     VARCHAR2(20);
      v_cerror       NUMBER;
   BEGIN
      SELECT nfact_cli
        INTO vnfact_cli
        FROM reembfact
       WHERE nfact = pnfact
         AND nreemb = pnreemb;

      -- BUG12676:DRA:15/03/2010:Inici
      BEGIN
         SELECT cerror
           INTO v_cerror
           FROM reembactosfac
          WHERE nfact = pnfact
            AND nreemb = pnreemb
            AND nlinea = pnlinea;

         IF v_cerror = 200 THEN
            -- Si entra aqui vol dir que s'ha acceptat el error 200
            UPDATE reembolsos
               SET cestado = 2
             WHERE nreemb = pnreemb;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- BUG12676:DRA:15/03/2010:Fi
      resul := pac_control_reembolso.f_validareemb(ptipo, psseguro, pnriesgo, pcgarant,
                                                   psperson, pagr_salud, pcacto, pnacto,
                                                   pfacto, piimporte, pnreemb, pnfact, pnlinea,
                                                   psmancont, vnfact_cli, pftrans);

      IF resul <> 0 THEN
         RETURN resul;
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
   END f_valida_reemb;

   -- BUG10704:DRA:15/07/2009:Inici
   /***********************************************************************
                     Función que actualizará el estado de impresión de la factura
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : Número de factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_act_factura(pnreemb IN NUMBER, pnfact IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - pnreemb:' || pnreemb || ' - pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_act_factura';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_reembolsos.f_act_factura(pnreemb, pnfact);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_act_factura;

   /***********************************************************************
                                    Función que hará el traspaso de una factura a un reembolso ya existente
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : Número de factura
      param in  pnfactcli : Número factura cliente
      param in  pnreembori: reembolso al cual tenemos que traspasar la factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_traspasar_factura(
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pnfactcli IN VARCHAR2,
      pnreembori IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pnreemb:' || pnreemb || ' - pnfact:' || pnfact || ' - pnfactcli:'
            || pnfactcli || ' - pnreembori:' || pnreembori;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_traspasar_factura';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_reembolsos.f_traspasar_factura(pnreemb, pnfact, pnfactcli, pnreembori);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_traspasar_factura;

   /***********************************************************************
                                    Función que nos dirá si se puede o no modificar la factura
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : Número de factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_modif_factura(pnreemb IN NUMBER, pnfact IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - pnreemb:' || pnreemb || ' - pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_modif_factura';
      vnumerr        NUMBER;
      v_permite      NUMBER(8);
      v_accion       NUMBER;
      v_impreso      VARCHAR2(1);
   BEGIN
      -- Primero miramos si la factura ya está imprimida
      vnumerr := pac_reembolsos.f_modif_factura(pnreemb, pnfact, v_impreso);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF NVL(v_impreso, 'N') <> 'N' THEN
         -- Si está imprimida, entonces miramos si el usuario tiene permiso
         v_accion := pac_cfg.f_get_user_accion_permitida(f_user, 'PERMITE_MODIF_FACTURA', 0,
                                                         pac_md_common.f_get_cxtempresa,
                                                         v_permite);

         IF NVL(v_accion, 0) <> 1 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001973);
            RAISE e_object_error;
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
   END f_modif_factura;

   /***********************************************************************
                                                   Función para detectar si el nº hoja CASS ya existe
      param in pnreemb    : codi del reembossament
      param in  pnfactcli : codi factura client
      param out pnreembdest  : codi del reembossament
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_existe_factcli(
      pnreemb IN NUMBER,
      pnfactcli IN VARCHAR2,
      pnreembdest OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parámetros - pnreemb: ' || pnreemb || ' -pnfactcli:' || pnfactcli;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_existe_factcli';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_reembolsos.f_existe_factcli(pnreemb, pnfactcli, pnreembdest);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_existe_factcli;

   /***********************************************************************
                                    Rutina que retorna los tipos de actos
      param in out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lsttipoactos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.F_Get_lsttipoactos';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(895, mensajes);
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
   END f_get_lsttipoactos;

   -- BUG10704:DRA:15/07/2009:Fi

   /***********************************************************************
                     Rutina que calcula el importe complementario
      param in  pitot        : Importe total
      param in  pipago       : Importe pago
      param in  picass       : Importe cass
      param out oipagocomp   : Importe pago complementario
      param out mensajes     : T_IAX_MENSAJES
      return                 : 0 tot correcte
                               1 ha hagut un error
   ***********************************************************************/
   -- BUG10761:DRA:22/07/2009:Inici
   FUNCTION f_calcomplementario(
      pitot IN NUMBER,
      pipago IN NUMBER,
      picass IN NUMBER,
      oipagocomp OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobject        VARCHAR2(500) := 'PAC_MD_REEMBOLSOS.F_calcomplementario';
      vparam         VARCHAR2(500)
         := 'parámetros - pitot:' || pitot || ' - pipago:' || pipago || ' - picass:' || picass;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      oipagocomp := NVL(pitot, 0) - NVL(pipago, 0) - NVL(picass, 0);
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
   END;

   /***********************************************************************
                                    Función para detectar si la factura es Ordinaria o Complementaria
      param in pnreemb    : codi del reembossament
      param in  pnfact    : codi factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_tipo_factura(pnreemb IN NUMBER, pnfact IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - pnreemb: ' || pnreemb || ' -pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_tipo_factura';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_reembolsos.f_tipo_factura(pnreemb, pnfact);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_tipo_factura;

   -- BUG10761:DRA:22/07/2009:Fi
   -- BUG10949:JGM:19/08/2009:Fi
   /***********************************************************************
                     Función para detectar si la factura tiene fecha de baja y cual
      param in pnreemb    : codi del reembossament
      param in  pnfact    : codi factura
      fbaja out  date    : data baixa
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_get_data_baixa(
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pfbaja OUT DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - pnreemb: ' || pnreemb || ' -pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_get_data_baixa';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_reembolsos.f_get_data_baixa(pnreemb, pnfact, pfbaja);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_get_data_baixa;

   -- BUG10949:JGM:19/08/2009:Fi

   -- BUG17732:DRA:22/02/2011:Inici
   /***********************************************************************
      Función para modificar la CCC del reembolso
      param in pnreemb    : codi del reembossament
      param in pcheck     : codi factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_modificar_ccc(pnreemb IN NUMBER, pcheck IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                             := 'parámetros - pnreemb: ' || pnreemb || ' - pcheck: ' || pcheck;
      vobject        VARCHAR2(200) := 'PAC_MD_REEMBOLSOS.f_modificar_ccc';
      vnumerr        NUMBER := 0;
      v_cbancar      seguros.cbancar%TYPE;   -- 24.0 21-10-2011 JGR 0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
      v_ctipban      seguros.ctipban%TYPE;   -- 24.0 21-10-2011 JGR 0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnreemb IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcheck = 1 THEN
         vpasexec := 2;
         v_cbancar := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'CBANCAR_HOSP');
      ELSE
         vpasexec := 3;
         vnumerr := pac_reembolsos.f_obtener_ccc(NULL, pnreemb, v_ctipban, v_cbancar);
      END IF;

      vpasexec := 4;
      vnumerr := pac_reembolsos.f_modificar_ccc(pnreemb, pcheck, v_cbancar);

      IF vnumerr <> 0 THEN
         vpasexec := 5;
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
   END f_modificar_ccc;
-- BUG17732:DRA:22/02/2011:Fi
END pac_md_reembolsos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_REEMBOLSOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_REEMBOLSOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_REEMBOLSOS" TO "PROGRAMADORESCSI";
