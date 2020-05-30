create or replace PACKAGE BODY "PAC_MD_SIMULACIONES" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_SIMULACIONES
      PROPÓSITO: Funciones para simulación en segunda capa

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        19/12/2007   ACC      1. Creación del package.
      2.0        19/05/2009   APD      2. 0010127: IAX- Consultas de pólizas, simulaciones, reembolsos y póliza reteneidas
      2.1        21/05/2009   APD      2.1 BUG10178: IAX - Vista AGENTES_AGENTE por empresa
      3.0        25/06/2009   AMC      3. Se añade la función f_actmodtom bug 9642
      4.0        05/11/2009   NMM      4. 10093: CRE - Afegir filtre per RAM en els cercadors.
      5.0        28/10/2011   APD      5. 0018946: LCOL_P001 - PER - Visibilidad en personas
      6.0        02/12/2011   AMC      6. Bug 20307/99655 - Se añaden nuevos parametros a la funcion f_grabaasegurado
      7.0        18/10/2012   XVM      7. 0023510: CALI102 - PPA i PIES - Corrección diverses
      8.0        05/09/2013   JSV      8. 0027955: LCOL_T031- QT GUI de Fase 3
      9.0        27/01/2014   JTT      9. 0027429: Persistencia simulaciones
     10.0        03/02/2014   JTT     10. 0027430: Añadir al filtro de busqueda de simulaciones el tomador y la fecha de cotizacion
   11.0    07/01/2019   SWAPNIL 11. Cambios para solicitudes múltiples
     12.0        02/07/2019   KK      12. CAMBIOS De IAXIS-4538
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Graba el asegurado como nueva persona
      param in pcsexper  : sexo de la persona
      param in pfnacimi  : fecha nacimiento
      param in pnnumnif  : número identificación persona
      param in tnombre   : nombre de la persona
      param in tnombre1   : primer nombre de la persona
      param in tnombre2   : segundo nombre de la persona
      param in tapelli1  : primer apellido
      param in tapelli2  : segundo apellido
      param in pctipide  : Tipo de identificación persona V.F. 672
      param in pctipper  : Tipo de persona V.F. 85
      param in pcagente  : código de agente
      param in osperson  : número de persona
      param out          : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error

      Bug 20307/99655 - 02/12/2011 - AMC
      Bug 23510 - XVM - 18/10/2012 Se añade parámetro cagente
   *************************************************************************/
   FUNCTION f_grabaasegurados(
      psseguro IN NUMBER,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pctipide IN NUMBER,
      pctipper IN NUMBER,
      pcagente IN NUMBER,
      osperson OUT NUMBER,
      pcocupacion IN NUMBER,
      pcestciv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsperson       NUMBER;
      vcagente       NUMBER;
      nerr           NUMBER;
      vnumnif        VARCHAR2(14);
      vctipide       NUMBER;
      vctipper       NUMBER;
      vtnombre       VARCHAR2(200);
      vperreal       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.F_GrabaAsegurados';
   BEGIN
      --BUG8644-11032009-XVM: s'afageix l'empresa i el snip (null)
      nerr := pac_persona.f_existe_persona(pac_md_common.f_get_cxtempresa, pnnumnif, pcsexper,
                                           pfnacimi, vperreal, NULL, NULL, pctipide);
      --vperreal := vsperson;
      vpasexec := 2;
      /*IF nErr = 0 THEN
          vsperson :=  nvl( vsperson, pac_persona.f_sperson);
      END IF;*/
      vpasexec := 3;

      -- BUG 9282 - 02/03/2009 - SBG - Si no s'introdueix NIF, el tipus ha de ser 99, no 0.
      IF NVL(pnnumnif, ' ') = ' ' THEN
         nerr := f_snnumnif('Z', vnumnif);
         vctipide := 99;
      ELSE
         vnumnif := pnnumnif;
      END IF;

      IF vctipide IS NULL THEN
         -- INI RLLF 20/03/2014 No graba el tipo de identificador.
          --IF NVL(pctipide, -1) = -1 THEN
         IF pctipide IS NULL
            OR pctipide = 0 THEN
            -- FIN RLLF 20/03/2014 No graba el tipo de identificador.
            vctipide := 99;
         ELSE
            vctipide := pctipide;
         END IF;
      END IF;

      IF NVL(pctipper, 0) = 0 THEN
         vctipper := 1;
      ELSE
         vctipper := pctipper;
      END IF;

      IF NVL(ptnombre, ' ') = ' ' THEN
         vtnombre := vnumnif;
      ELSE
         vtnombre := ptnombre;
      END IF;

      vpasexec := 4;
      vcagente := pcagente;
      -- BUG 5912
      nerr :=
         pac_md_persona.f_set_persona
            (psseguro,   --Psseguro      in number,
             vsperson,   -- Psperson   in out  number,
             vperreal,   --Pspereal    in number,
             vcagente,   --    in  number, --Bug 23510 - XVM - 18/10/2012 Se añade parámetro cagente
             vctipper,   --ctipper     in number, -- ¿ tipo de persona (física o jurídica)
             vctipide,   --Ctipide     in number, -- ¿ tipo de identificación de persona
             vnumnif,   --Nnumide  in varchar2, --  -- Número identificativo de la persona.
             pcsexper,   --Csexper   in number, --     -- sexo de la pesona.
             pfnacimi,   --Fnacimi    in date, --   -- Fecha de nacimiento de la persona
             NULL,   --Snip          in varchar2,--  -- snip
             99,   --Cestper     in  number,
             NULL,   --Fjubila       in date,
             NULL,   --Cmutualista in number,
             NULL,   --Fdefunc    in date,
             NULL,   --Nordide   in number,
             pac_md_common.f_get_cxtidioma,   --CIDIOMA   in  NUMBER ,---      Código idioma
             ptapelli1,   --TAPELLI1 in VARCHAR2 ,--      Primer apellido
             ptapelli2,   --TAPELLI2 in VARCHAR2 ,--      Segundo apellido
             vtnombre,   --TNOMBRE  in  VARCHAR2 ,--     Nombre de la persona
             NULL,   --TSIGLAS   in VARCHAR2 ,--     Siglas persona jurídica
             NULL,   --CPROFES  in  VARCHAR2 ,--     Código profesión
             pcestciv,   --CESTCIV  in  NUMBER ,-- Código estado civil. VALOR FIJO = 12
             pac_parametros.f_parinstalacion_n('PAIS_DEF'),   --CPAIS  in   NUMBER ,--     Código país de residencia
             'EST', 0, NULL, ptnombre1,   -- Bug 20307/99655 - 02/12/2011 - AMC
             ptnombre2,   -- Bug 20307/99655 - 02/12/2011 - AMC
             NULL,   --bug 20613/101749
             pcocupacion, 
       /* Cambios para solicitudes múltiples : Start */
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             /* Cambios para solicitudes múltiples : End */             
       mensajes   --out t_iax_mensajes
             /* CAMBIOS De IAXIS-4538 : Start */
             ,NULL,
             NULL,
             NULL,
             NULL
            /* CAMBIOS De IAXIS-4538 : End */
                                  );

      -- FIN BUG 5912
      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
         END IF;
      END IF;

      IF nerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      osperson := vsperson;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_grabaasegurados;

   /*************************************************************************
      Establece la simulación como estudio cambiando su csituac a 7 VF 61
      param in psseguro     : código de solicitud
      param in out mensajes : mensajes error
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_simulestudi(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.F_Set_SimulEstudi';
   BEGIN
      UPDATE estseguros
         SET csituac = 7
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_simulestudi;

   /*************************************************************************
       Devuelve las simulaciones que cumplan con el criterio de selección
       param in psproduc  : código de producto
       param in psolicit  : número de solicitud
       param in ptriesgo  : descripción del riesgo
      param in pnnumide     : Identificador del tomador
      param in pbuscar      : Nombre / Apellido del tomador
      param in pfcotiza     : Fecha de cotización
       param out mensajes : mensajes de error
       return             : ref cursor
   *************************************************************************/
   -- Bug 10093.NMM.05/11/2009. S'afegeixen 2 camps a la funció.
   -- Bug 27430 - 03/02/2014 - JTT: S'afegeixen els camps pnnumide, pbucar i pfcotiza a la funcio
   -- Bug 35888 - 2015/05/21 - CJMR: Realizar la substitución del upper nnumide
   FUNCTION f_consultasimul(
      psproduc IN NUMBER,
      psolicit IN NUMBER,
      pnpoliza IN NUMBER,   -- Bug 34409/196980 - 16/04/2015 - POS
      ptriesgo IN VARCHAR2,
      p_cramo IN NUMBER,
      p_filtroprod IN VARCHAR2,
      pnnumide IN VARCHAR2 DEFAULT NULL,
      pbuscar IN VARCHAR2 DEFAULT NULL,
      pfcotiza IN DATE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(2500);
      vtriesgo       VARCHAR2(1000);   -- BUG 38344/217178 - 09/11/2015 - ACL
      vnnumide       VARCHAR2(100);   -- BUG 38344/217178 - 09/11/2015 - ACL
      -- buscar   VARCHAR2(1000) := ' where rownum<=101 and csituac=7';
      -- dramon 04/12/2008: bug mantis 8359
      -- Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación
      --                                se añade la subselect con la tabla agentes_agente
      -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
      --buscar         VARCHAR2(2000)
        --                       := ' where rownum<=101 and s.csituac=7 and a.sseguro=s.sseguro';
      /*
      buscar         VARCHAR2(4000)
         := ' where rownum<= NVL('
            || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null')
            || ', rownum) ' || ' and s.csituac=7 '
            || ' and (s.cagente,s.cempres) in (select cagente, cempres from agentes_agente_pol) ';
            */
       -- Bug 27429 - 30/01/2014 - JTT: Tambe recuperem les SIMULACIONS en estat 10 (rebutjades) i en estat 4 (Proposta) que estan a la taula de Persistencia
      buscar         VARCHAR2(4000)
         := ' where s.sseguro = p.sseguro (+) AND rownum <= NVL('
            || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null')
            || ', rownum) '
            || ' and (s.csituac=7 or s.csituac = 10 or (s.csituac = 4 AND p.sseguro IS NOT NULL))'
            || ' AND s.cagente = a.cagente AND s.cempres = a.cempres ';
      -- Fi Bug 27429
      -- Bug 18946 - APD - 28/10/2011 - fin
      -- Bug 10127 - APD - 19/05/2009 - fin
      subus          VARCHAR2(500);
      subper         VARCHAR2(500);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
         := 'psproduc=' || psproduc || ' psolicit=' || psolicit || ' ptriesgo=' || ptriesgo
            || ' pnpoliza= ' || pnpoliza;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.F_ConsultaSimul';
      w_numerr       NUMBER;
      --
      v_sentence     VARCHAR2(1000);
      auxnom         VARCHAR2(200);
-----------------------------------------------------------------------------
   BEGIN
      IF NVL(psproduc, 0) <> 0 THEN
         buscar := buscar || ' and s.sproduc =' || psproduc;
      -- Bug 10093.NMM.05/11/2009.i.
      ELSE
         w_numerr := pac_productos.f_get_filtroprod(p_filtroprod, v_sentence);

         IF w_numerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         IF v_sentence IS NOT NULL THEN
            buscar := buscar || ' and s.sproduc in (select p.sproduc from productos p where'
                      || v_sentence || ' 1=1)';
         END IF;

         IF p_cramo IS NOT NULL THEN
            buscar := buscar || ' and s.sproduc in (select p.sproduc from productos p where'
                      || ' p.cramo = ' || p_cramo || ' )';
         END IF;
      -- Bug 10093.NMM.05/11/2009.f.
      END IF;

      vpasexec := 2;

      IF NVL(psolicit, 0) <> 0 THEN
         buscar := buscar || ' and s.sseguro = ' || psolicit;
      END IF;

      --javendano  Bug 34409/196980 - 16/04/2015 - POS
      IF NVL(pnpoliza, 0) <> 0 THEN
         buscar := buscar || ' and s.npoliza = ' || pnpoliza;
      END IF;

      -- dramon 16-12-2008: bug mantis 7826
      -- Validem si té accés per contractar el producte
      vpasexec := 3;
      --buscar := buscar || ' and PAC_PRODUCTOS.f_prodagente (s.sproduc,' || pac_md_common.f_get_cxtagente || ',2)=1';
      buscar := buscar || ' and ' || pac_md_common.f_get_cxtagente || ' = u.cdelega (+) '
                || ' and s.cramo = u.cramo (+) ' || ' and s.cmodali = u.cmodali (+) '
                || ' and s.ccolect = u.ccolect (+) ' || ' and s.ctipseg = u.ctipseg (+) '
                || ' and (u.emitir = 1 OR u.emitir IS NULL) ' || ' and s.cramo = t.cramo '
                || ' and s.cmodali = t.cmodali ' || ' and s.ccolect = t.ccolect '
                || ' and s.ctipseg = t.ctipseg ' || ' and t.cidioma = '
                || pac_md_common.f_get_cxtidioma;
      vpasexec := 4;

      IF ptriesgo IS NOT NULL THEN
         -- Inicio BUG 38344/217178 - 09/11/2015 - ACL
         vtriesgo := ptriesgo;
         vtriesgo := REPLACE(vtriesgo, CHR(39), CHR(39) || CHR(39));
         subus :=
            ' and s.sseguro IN (select ted.sseguro from (
                                select nvl(PAC_MD_OBTENERDATOS.F_Desriesgos(''EST'',
                                   r.sseguro,r.nriesgo),''***'') triesgo, r.sseguro
                                from estriesgos r) ted
                    where lower(nvl(ted.triesgo,''**'')) like lower(''%'
            || vtriesgo || '%'')';
         -- Fin BUG 38344/217178 - 09/11/2015 - ACL
         subus := subus || ')';
      END IF;

       /* Bug 27430 - 03/02/2014 - JTT:
         Afegim com a opcions de recerca, el Numero de identificacio i/o Nom del Tomador i la data de cotitzacio.
        La sentencia WHERE de recerca s'inspira en el cercador de polisses, PAC_MD_PRODUCCION.f_consultapoliza.
      */
      vpasexec := 10;

      IF (pnnumide IS NOT NULL
          OR pbuscar IS NOT NULL) THEN
         subper :=
            ' and s.sseguro IN (SELECT t.sseguro FROM esttomadores t,'
            || ' estper_detper dp, estper_personas pp WHERE pp.sperson = dp.sperson and t.sperson = dp.sperson AND dp.cagente = FF_AGENTE_CPERVISIO (S.CAGENTE, F_SYSDATE, S.CEMPRES)';

         IF pnnumide IS NOT NULL THEN
            -- Inicio BUG 38344/217178 - 09/11/2015 - ACL
            vnnumide := pnnumide;
            vnnumide := REPLACE(vnnumide, CHR(39), CHR(39) || CHR(39));

-- Fin BUG 38344/217178 - 09/11/2015 - ACL
            -- Bug 35888 - 2015/05/21 - CJMR D02  AD01
            --subper := subper || ' AND upper(pp.nnumide) = upper(' || CHR(39) || pnnumide
            --          || CHR(39) || ')';
            --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                 'NIF_MINUSCULAS'),
                   0) = 1 THEN
               subper := subper || ' AND UPPER(pp.nnumide) = UPPER(' || CHR(39)
                         || vnnumide   -- BUG 38344/217178 - 09/11/2015 - ACL
                                    || CHR(39) || ')';
            ELSE
               --subper := subper || ' AND pp.nnumide = ' || CHR(39) || vnnumide || CHR(39);   -- BUG 38344/217178 - 09/11/2015 - ACL
               subper := subper || ' AND pp.nnumide LIKE ''' || '%' || ff_strstd(vnnumide) || '%' || ''' ';
            END IF;
         END IF;

         IF pbuscar IS NOT NULL THEN
            w_numerr := f_strstd(pbuscar, auxnom);
            subper := subper || ' AND upper ( replace ( dp.tbuscar, ' || CHR(39) || '  '
                      || CHR(39) || ',' || CHR(39) || ' ' || CHR(39) || ' )) like upper(''%'
                      || auxnom || '%' || CHR(39) || ')';
         END IF;

         subper := subper || ')';
      END IF;

      IF pfcotiza IS NOT NULL THEN
         subper := ' and exists  (SELECT 1 FROM estgaranseg t'
                   || '   WHERE   t.sseguro = s.sseguro AND t.ftarifa = TO_DATE('''
                   || TO_CHAR(pfcotiza, 'DD/MM/YYYY') || ''' ,''DD/MM/YYYY'') )';
      END IF;

      -- Fi Bug 27430
      vpasexec := 5;
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista estseguros_agente
      -- Bug27429 - 28/01/2014 - JTT: Cridem la funcion ff_situacion_poliza per recuperar l'estat de la simulacio (EST)
      squery :=
         'select s.sseguro,
                    PAC_MD_OBTENERDATOS.F_Desriesgos(''EST'',
                                   s.sseguro, 1) triesgo,
                    t.ttitulo as tproduc,
                    PAC_SEGUROS.ff_situacion_poliza(s.sseguro, PAC_MD_COMMON.F_GET_CXTIDIOMA, 1, NULL, NULL, NULL, ''EST'') as tsituacion
                  from estseguros s, persistencia_simul p, agentes_agente_pol a, prod_usu u, titulopro t '   --, estseguros_agente a'
         || buscar || subus   -- dramon 04/12/2008: bug mantis 8359
                           || subper;   -- Bug 27430 - 03/02/2014 - JTT
      -- Bug 10127 - APD - 19/05/2009 - fin
      vpasexec := 6;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 7;

      IF pac_md_log.f_log_consultas(squery, 'PAC_MD_SIMULACIONES.F_CONSULTASIMUL', 1, 4,
                                    mensajes) <> 0 THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      vpasexec := 8;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

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
   END f_consultasimul;

   /*************************************************************************
       Devuelve el cestper de la persona
       param in psperson  : código de la persona
       param out mensajes : mensajes de error
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_devuelvecestper(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcestper       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psperson=' || psperson;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.F_DevuelveCestper';
   BEGIN
      SELECT cestper
        INTO vcestper
        FROM estper_personas
       WHERE sperson = psperson;

      RETURN vcestper;
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
   END f_devuelvecestper;

   /*************************************************************************
       Borra la persona
       param in psperson  : código de la persona
       param out mensajes : mensajes de error
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_borrapersona(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcestper       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psperson=' || psperson;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.F_BorraPersona';
   BEGIN
      BEGIN
         DELETE FROM estassegurats
               WHERE sperson = psperson;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         DELETE FROM estper_personas
               WHERE sperson = psperson;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_borrapersona;

   -- Bug 9642 - 25/06/2009 - AMC

   /*************************************************************************
       Comprueba si la persona que viene de simulacion es ficticia
       param in psperson  : código de la persona
       param in psproduc  : código del producto
       param out pficti   : indica si es ficticia
       param out mensajes : mensajes de error
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_actmodtom(
      psperson IN NUMBER,
      psproduc IN NUMBER,
      pficti OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcestper       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psperson=' || psperson || ' psproduc:' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.f_actmodtom';
      vtomsimu       NUMBER;
      vctipide       NUMBER;
   BEGIN
      vtomsimu := pac_iaxpar_productos.f_get_parproducto('TOMADOR_NUEVO_SIMUL', psproduc);

      SELECT ctipide
        INTO vctipide
        FROM estper_personas
       WHERE sperson = psperson;

      IF vtomsimu = 1
         AND vctipide = 99 THEN
         pficti := 1;
      ELSE
         pficti := 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_actmodtom;

-- Fi Bug 9642 - 25/06/2009 - AMC

   --Bug: 0027955/0152213 - JSV (05/09/2013)
   FUNCTION f_test_estdireccion(pcpoblac IN NUMBER, pcprovin IN NUMBER)
      RETURN NUMBER IS
      vcuenta        NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcuenta
        FROM poblaciones
       WHERE cpoblac = pcpoblac
         AND cprovin = pcprovin;

      RETURN vcuenta;
   END f_test_estdireccion;

   -- Bug27429 - 28/01/2014 -- JTT:
   /*************************************************************************
      Establece la simulacion como rechazada cambiando su situacion a 10 VF 61
      param in psseguro     : cdigo de solicitud
      param in out mensajes : mensajes error
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_rechazar_simul(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.F_rechazar_simul ';
   BEGIN
      UPDATE estseguros
         SET csituac = 10
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_rechazar_simul;

   /*************************************************************************
      Grabar un registro en la tabla PERSISTENCIA_SIMUL si no existe
      param in psseguro     : cdigo de solicitud
      param in out mensajes : mensajes error
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_alta_persistencia_simul(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.F_alta_persistencia_simul';
   BEGIN
      RETURN pk_simulaciones.f_alta_persistencia_simul(psseguro, mensajes);
   END f_alta_persistencia_simul;

   /*************************************************************************
      Actualiza el estado de la simulacion a 4 y borra la simulacion de la tabla de persisntecia
      param in psseguro     : cdigo de solicitud
      param in out mensajes : mensajes error
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_actualizar_persistencia(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.F_actualizar_persistencia';
   BEGIN
      RETURN pk_simulaciones.f_actualizar_persistencia(psseguro, mensajes);
   END f_actualizar_persistencia;

   /*************************************************************************
      Recuperem la situacio de la simulacio
      param in psolicit     : codigo de solicitud
      param in out mensajes : mensajes error
      return                : Situacion de la solicitud
   ***********************************************************************/
   FUNCTION f_get_situacion_simul(
      psseguro IN NUMBER,
      ptsitsimul OUT VARCHAR2,
      pcsitsimul OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      nerr           NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_SIMULACIONES.F_get_situacion_simul';
   BEGIN
      BEGIN
         SELECT csituac
           INTO pcsitsimul
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pcsitsimul := NULL;
            ptsitsimul := NULL;
            RETURN 0;
      END;

      SELECT tatribu
        INTO ptsitsimul
        FROM detvalores
       WHERE cvalor = 61
         AND catribu = pcsitsimul
         AND cidioma = pac_md_common.f_get_cxtidioma;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 101919;
   END f_get_situacion_simul;
-- Fi Bug 27429
END pac_md_simulaciones;
/