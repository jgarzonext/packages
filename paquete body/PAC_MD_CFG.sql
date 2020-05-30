--------------------------------------------------------
--  DDL for Package Body PAC_MD_CFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CFG" AS
/******************************************************************************
   NOMBRE:      PAC_MD_CFG
   PROPÓSITO:   Funciones para la configuración de pantallas y flujos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/01/2007   JAS               1. Creación del package.
   2.0        23/03/2009   DCT               2. Creación función f_get_lst_cfgdoc
   3.0        05/05/2009   DRA               3. 0009981: IAX - Baixar l'empresa a totes les taules del model CFG
   4.0        13/05/2009   XPL               4. 14429 : AGA005 - Primes manuals pels productes de Llar
   5.0        13/10/2010   XPL               5. 16064: CRT101 - Boton enviar correo avisando de nueva solicitud
   6.0        14/10/2010   XPL/AMC           6. Bug 15743
   7.0        26/10/2010   DRA               7. 0016471: CRT - Configuracion de visibilidad/contratacion de productos a nivel de perfil
   8.0        07/01/2011   XPL               8. 17179: AGA003 - Modificación de listados de administración (filtro por fmovdia)
   9.0        15/12/2011   APD               9. 0020478: LCOL - Modo 'GENERAL' si no existe el modo en que le llega.
   10.0       07/03/2012   JMP               10. 21569: CRE998 - Configurar llençador d'Informes per perfil
   11.0       12/07/2012   APD               11. 0022871: MDP - PER - Dependencias coja el modo general.
   12.0       07/10/2013   RCL               12. 0027699: LCOL_PROD-Lllen?ar llistats per batch
   13.0       03/08/2019   JMJRR             13.IAXIS-4994: Se modifican parametros de entrada y proceso de obtener informacion usuarios
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera la configuración de navegación asociada a un usuario para un flujo determinado.
    Parámetros entrada: - pcuser    -> Usuario
                        - pcempres  -> Empresa
                        - pcmodo    -> Flujo
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - vccfgwiz  -> Configuración de navegación asociada al usuario
                          NULL      -> Error
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_user_cfgwiz(
      pcuser IN VARCHAR2,
      pcempres IN NUMBER,   -- BUG9981:DRA:15/05/2009
      pcmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_user_cfgwiz';
      vparam         VARCHAR2(500)
         := 'parámetros - pcuser: ' || pcuser || ' - pcmodo: ' || pcmodo || ' - pcempres: '
            || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vccfgwiz       VARCHAR2(50);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcuser IS NULL
         OR pcmodo IS NULL
         OR pcempres IS NULL   -- BUG9981:DRA:20/05/2009
                            THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Recupero la configuració específica de l'usuari pel fluxe.
      --Si no en té configuració específica pel fluxe, recupero la configuració per defecte de l'usuari.
      SELECT NVL(cuw.ccfgwiz, cu.ccfgwiz)
        INTO vccfgwiz
        FROM cfg_user cu, cfg_user_cfgwizard cuw
       WHERE cu.cuser = pcuser
         AND cu.cempres = pcempres   -- BUG9981:DRA:15/05/2009
         AND cuw.cuser(+) = cu.cuser
         AND cuw.cmodo(+) = pcmodo
         AND cuw.cempres(+) = cu.cempres;   -- BUG9981:DRA:05/05/2009

      --Tot ok
      RETURN vccfgwiz;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_user_cfgwiz;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera la configuración de formulario asociada a un usuario para una pantalla determinada.
    Parámetros entrada: - pcuser    -> Usuario
                        - pcempres  -> Empresa
                        - pcform    -> Pantalla
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - vccfgform -> Configuración de pantalla asociada al usuario para la pantalla
                          NULL      -> Error
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_user_cfgform(
      pcuser IN VARCHAR2,
      pcempres IN NUMBER,   -- BUG9981:DRA:15/05/2009
      pcform IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_user_cfgform';
      vparam         VARCHAR2(500)
         := 'parámetros - pcuser: ' || pcuser || ' - pcform: ' || pcform || ' - pcempres: '
            || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vccfgform      VARCHAR2(50);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcuser IS NULL
         OR pcform IS NULL
         OR pcempres IS NULL   -- BUG9981:DRA:20/05/2009
                            THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Recupero la configuració específica de l'usuari per la pantalla.
      --Si no en té configuració específica per la pantalla, recupero la configuració per defecte de l'usuari.
      SELECT NVL(cuf.ccfgform, cu.ccfgform)
        INTO vccfgform
        FROM cfg_user cu, cfg_user_cfgform cuf
       WHERE cu.cuser = pcuser
         AND cu.cempres = pcempres   -- BUG9981:DRA:15/05/2009
         AND cuf.cuser(+) = cu.cuser
         AND cuf.cform(+) = pcform
         AND cuf.cempres(+) = cu.cempres;   -- BUG9981:DRA:05/05/2009

      --Tot ok
      RETURN vccfgform;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_user_cfgform;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (04/12/2007)
    Descripción: Recupera la configuración (propiedades) de pantalla por defecto de la aplicación.
    Parámetros entrada: -
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - refcursor -> Refcursor con la configuración (propiedades de los campos)
                                        por defecto de la aplicación.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_def_form_property(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_def_form_propery';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
   BEGIN
      RETURN pac_md_listvalores.f_opencursor
               ('select catribu cprpty, decode(catribu,1,1,2,0,3,0,6,2) cvalue from detvalores where cvalor = 550 and cidioma = 1 and catribu in (1,2,3,6)',
                mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_def_form_property;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera la configuración (propiedades) de pantalla para un modo concreto y producto determinado.
    Parámetros entrada: - pcform    -> Pantalla
                        - pcmodo    -> Modo de la pantalla
                        - pccfgform -> Modo de configuración de la pantalla
                        - psproduc  -> Código de producto
                        - pcempres  -> Codigo de la empresa
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - refcursor -> Refcursor con la configuración (propiedades de los campos) de la pantalla.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_form_property(
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pccfgform IN VARCHAR2,
      psproduc IN NUMBER,
      pcempres IN NUMBER,   -- BUG9981:DRA:05/05/2009
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_form_property';
      vparam         VARCHAR2(500)
         := 'parámetros - pcform:' || pcform || ' - pmodo: ' || pcmodo || ' - pccfgform: '
            || pccfgform || ' - psproduc: ' || psproduc || ' - pcempres: ' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vrefcursor     sys_refcursor;
      vcmodo         cfg_cod_modo.cmodo%TYPE;
      vsproduc       productos.sproduc%TYPE;
      vquants        NUMBER(8);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcform IS NULL
         OR pccfgform IS NULL
         OR pcempres IS NULL   -- BUG9981:DRA:20/05/2009
                            THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcmodo IS NULL THEN   --Si el mode no ve informat, obtenim el mode per defecte
         SELECT c.cmodo
           INTO vcmodo
           FROM cfg_cod_modo c
          WHERE c.cdefecto = 1;
      ELSE
         vcmodo := pcmodo;
      END IF;

      vsproduc := NVL(psproduc, 0);
      vpasexec := 5;

      SELECT COUNT(1)
        INTO vquants
        FROM cfg_form f, cfg_form_property fp
       WHERE f.cform = UPPER(pcform)
         AND f.cmodo = vcmodo
         AND f.sproduc = vsproduc
         AND f.ccfgform = pccfgform
         AND f.cempres = pcempres   -- BUG9981:DRA:05/05/2009
         AND fp.cidcfg = f.cidcfg
         AND fp.cform = f.cform
         AND fp.cempres = f.cempres;   -- BUG9981:DRA:05/05/2009

      IF psproduc IS NULL
         OR vquants = 0 THEN
         --Si el producte no ve informat, o no té configuració específica, recuperem la parametrització independent de producte.
         vsproduc := 0;

         -- Bug 20478 - APD - 15/12/2011 - se valida si existe configuracion para el producto 0
         -- en el modo en que le llega
         -- si no existe configuracion, debe coger la configurancio por defecto (GENERAL)
         IF pcmodo IS NOT NULL THEN
            SELECT COUNT(1)
              INTO vquants
              FROM cfg_form f, cfg_form_property fp
             WHERE f.cform = UPPER(pcform)
               AND f.cmodo = vcmodo
               AND f.sproduc = vsproduc
               AND f.ccfgform = pccfgform
               AND f.cempres = pcempres   -- BUG9981:DRA:05/05/2009
               AND fp.cidcfg = f.cidcfg
               AND fp.cform = f.cform
               AND fp.cempres = f.cempres;   -- BUG9981:DRA:05/05/2009

            IF vquants = 0 THEN
               SELECT c.cmodo
                 INTO vcmodo
                 FROM cfg_cod_modo c
                WHERE c.cdefecto = 1;
            END IF;
         END IF;
      -- fin Bug 20478 - APD - 15/12/2011
      END IF;

      --Retorn del fluxe de navegació sol·licitat.
      vrefcursor :=
         pac_md_listvalores.f_opencursor
                                  ('SELECT fp.citem, fp.cprpty, fp.cvalue'
                                   || ' FROM cfg_form f, cfg_form_property fp'
                                   || ' WHERE f.cform = UPPER(''' || pcform || ''')'
                                   || '   AND f.cmodo = ''' || vcmodo || ''''
                                   || '   AND f.sproduc = ' || vsproduc
                                   || '   AND f.ccfgform = ''' || pccfgform || ''''
                                   || '   AND f.cempres = '
                                   || pcempres   -- BUG9981:DRA:05/05/2009
                                   || '   AND fp.cidcfg = f.cidcfg'
                                   || '   AND fp.cform = f.cform'
                                   || '   AND fp.cempres = f.cempres'   -- BUG9981:DRA:05/05/2009
                                   || ' UNION ALL '
                                                   -- BUG10041:DRA:19/05/2009:Inici
                                   || ' SELECT cf.citem, cf.cprpty, cf.cvalue'
                                   || ' FROM cfg_config_form cf'
                                   || ' WHERE cf.cform = UPPER(''' || pcform || ''')'
                                   -- BUG10041:DRA:19/05/2009:Fi
                                   || ' ORDER BY citem',
                                   mensajes);
      RETURN vrefcursor;
   EXCEPTION
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_form_property;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera las propiedades de dependencia de una pantalla para un modo concreto y producto determinado.
    Parámetros entrada: - pcform    -> Pantalla
                        - pcmodo    -> Modo de la pantalla
                        - pccfgform -> Modo de configuración de la pantalla
                        - psproduc  -> Código de producto
                        - pcempres  -> Codigo de la empresa
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - refcursor -> Refcursor con las dependencias entre los valores de los campos de la pantalla.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_dep_form_property(
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pccfgform IN VARCHAR2,
      psproduc IN NUMBER,
      pcempres IN NUMBER,   -- BUG9981:DRA:05/05/2009
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    tab_error.tobjeto%TYPE := 'pac_md_cfg.f_get_dep_form_property';
      vparam         tab_error.tdescrip%TYPE
         := 'parámetros - pcform:' || pcform || ' - pmodo: ' || pcmodo || ' - pccfgform: '
            || pccfgform || ' - psproduc: ' || psproduc || ' - pcempres: ' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vrefcursor     sys_refcursor;
      vcmodo         cfg_cod_modo.cmodo%TYPE;
      v_cont_ccfgdep NUMBER;
      vsproduc       productos.sproduc%TYPE;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcform IS NULL
         OR pccfgform IS NULL
         OR pcempres IS NULL   -- BUG9981:DRA:20/05/2009
                            THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcmodo IS NULL THEN   --Si el mode no ve informat, obtenim el mode per defecte
         SELECT c.cmodo
           INTO vcmodo
           FROM cfg_cod_modo c
          WHERE c.cdefecto = 1;
      ELSE
         vcmodo := pcmodo;
      END IF;

      --Si el producte no ve informat, recuperem la parametrització independent de producte.
      vpasexec := 5;
      -- BUG 9560 - 01/04/2009 LPS -- IAX - PAC_MD_CFG.f_get_dep_form_property, preparara la función para que vaya por sproduc = 0
      vsproduc := NVL(psproduc, 0);

      SELECT   COUNT(fd.ccfgdep)
          INTO v_cont_ccfgdep
          FROM cfg_form f, cfg_form_property fp, cfg_form_dep fd
         WHERE f.cform = UPPER(pcform)
           AND f.cmodo = vcmodo
           AND f.sproduc = vsproduc
           AND f.ccfgform = pccfgform
           AND f.cempres = pcempres   -- BUG9981:DRA:05/05/2009
           AND fp.cidcfg = f.cidcfg
           AND fp.cform = f.cform
           AND fp.cprpty = 4
           AND fp.cempres = f.cempres   -- BUG9981:DRA:05/05/2009
           AND fd.ccfgdep = fp.cvalue
           AND fd.cempres = fp.cempres   -- BUG9981:DRA:05/05/2009
      ORDER BY fp.citem;

      IF psproduc IS NULL
         OR v_cont_ccfgdep = 0 THEN
         --Si el producte no ve informat, o no té configuració específica, recuperem la parametrització independent de producte.
         vsproduc := 0;

         -- Bug 22871 - APD - 12/07/2012 - se valida si existe configuracion para el producto 0
         -- en el modo en que le llega
         -- si no existe configuracion, debe coger la configurancio por defecto (GENERAL)
         IF pcmodo IS NOT NULL THEN
            SELECT   COUNT(fd.ccfgdep)
                INTO v_cont_ccfgdep
                FROM cfg_form f, cfg_form_property fp, cfg_form_dep fd
               WHERE f.cform = UPPER(pcform)
                 AND f.cmodo = vcmodo
                 AND f.sproduc = vsproduc
                 AND f.ccfgform = pccfgform
                 AND f.cempres = pcempres   -- BUG9981:DRA:05/05/2009
                 AND fp.cidcfg = f.cidcfg
                 AND fp.cform = f.cform
                 AND fp.cprpty = 4
                 AND fp.cempres = f.cempres   -- BUG9981:DRA:05/05/2009
                 AND fd.ccfgdep = fp.cvalue
                 AND fd.cempres = fp.cempres   -- BUG9981:DRA:05/05/2009
            ORDER BY fp.citem;

            IF v_cont_ccfgdep = 0 THEN
               SELECT c.cmodo
                 INTO vcmodo
                 FROM cfg_cod_modo c
                WHERE c.cdefecto = 1;
            END IF;
         END IF;
      -- fin Bug 22871 - APD - 12/07/2012
      END IF;

      -- FIN BUG 9560 - 01/04/2009 LPS -- IAX - PAC_MD_CFG.f_get_dep_form_property, preparara la función para que vaya por sproduc = 0

      --Retorn de les dependències entre camps de la pantalla sol·licitada.
      vrefcursor :=
         pac_md_listvalores.f_opencursor
            ('SELECT DISTINCT fd.ccfgdep, fd.citorig, fd.tvalorig, fd.citdest, fd.cprpty, fd.tvalue'
             || ' FROM cfg_form f, cfg_form_property fp, cfg_form_dep fd'
             || ' WHERE f.cform = UPPER(''' || pcform || ''')' || '   AND f.cmodo = '''
             || vcmodo || '''' || '   AND f.sproduc = ' || vsproduc || '   AND f.ccfgform = '''
             || pccfgform || '''' || '   AND f.cempres = ' || pcempres   -- BUG9981:DRA:05/05/2009
             || '   AND fp.cidcfg = f.cidcfg' || '   AND fp.cform = f.cform'
             || '   AND fp.cprpty = 4'
             || '   AND fp.cempres = f.cempres'   -- BUG9981:DRA:05/05/2009
             || '   AND fd.ccfgdep = fp.cvalue'
             || '   AND fd.cempres = fp.cempres'   -- BUG9981:DRA:05/05/2009
             || ' ORDER BY fd.TVALORIG',   -- Bug 14865:AMC:04/06/2010
             mensajes);
      RETURN vrefcursor;
   EXCEPTION
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_dep_form_property;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera si una detrrminada pantalla de un flujo debe saltarse o debe ser mostrada.
    Parámetros entrada: - pidcfg    -> Id. del flujo
                        - pcform    -> Formulario
                        - pcempres  -> Codigo de la empresa
    Parámetros salida:  - mensajes  -> mensajes de error
    Retorno:            - 0 / 1     -> saltar o no saltar la pantalla
                          NULL      -> Error
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_skip_form_wizard(
      pcidcfg IN NUMBER,
      pcform IN VARCHAR2,
      pcempres IN NUMBER,   -- BUG9981:DRA:05/05/2009
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_CFG.f_skip_form_wizard';
      vparam         VARCHAR2(500)
         := 'parámetros - pcidcfg: ' || pcidcfg || ' - pcform: ' || pcform || ' - pcempres: '
            || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtcond         VARCHAR2(2000);
      vctipcond      VARCHAR2(2);
      vtsql          VARCHAR2(1000);
      vskip          NUMBER(8);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcidcfg IS NULL
         OR pcform IS NULL
         OR pcempres IS NULL   -- BUG9981:DRA:20/05/2009
                            THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Recupero les condicions de salt de la pantalla.
      BEGIN
         SELECT ws.tcond, ws.ctipcond
           INTO vtcond, vctipcond
           FROM cfg_wizard_skip ws
          WHERE ws.cidcfg = pcidcfg
            AND UPPER(ws.cform) = UPPER(pcform)
            AND ws.cempres = pcempres;   -- BUG9981:DRA:05/05/2009
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vtcond := NULL;
      END;

      IF vtcond IS NULL THEN
         -- Si no hi ha condició per saltar la pantalla, no es pot saltar => s'ha de mostrar.
         RETURN 0;
      END IF;

      vpasexec := 5;

      IF vctipcond = 'OP' THEN
         IF pac_iax_produccion.poliza IS NULL THEN
            vpasexec := 7;
            RAISE e_param_error;
         ELSIF pac_iax_produccion.poliza.det_poliza IS NULL THEN
            vpasexec := 9;
            RAISE e_param_error;
         END IF;

         vpasexec := 11;
         vtsql := ' DECLARE ';
         vtsql := vtsql || ' BEGIN';
         vtsql := vtsql || '   :vSkip := ' || vtcond || '(:poliza);';
         vtsql := vtsql || ' END;';

-- BUG 15509 - 10/08/2010 - JRH - 0015509: CEM - Modificaciones Rentas. Ponemos IN/OUT para el objeto póliza, así lo podremos modificar dentro
         EXECUTE IMMEDIATE vtsql
                     USING OUT vskip, IN OUT pac_iax_produccion.poliza.det_poliza;

-- Fi BUG 15509 - 10/08/2010 - JRH
         IF vskip NOT IN(0, 1) THEN
            vpasexec := 13;
            vnumerr := vskip;
            RAISE e_object_error;
         END IF;

         --Retorn de la condició d'avaluació.
         RETURN vskip;
      ELSE
         --PENDENT: Avaluar la resta de tipus de condició de salt de la pantalla.
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_skip_form_wizard;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Dado un flujo de navegació i una pantalla, retorna la anterior i siguiente pantalla
                que se debe mostrar dentro del flujo.
    Parámetros entrada: - pmodo      ->  Flujo de navegación.
                        - pccfgwiz   ->  Configuración de navegación.
                        - psproduc   ->  Código de producto.
                        - pcform     ->  Código de la pantalla actual.
                        - pccampo    ->  Campo desde el que se navega.
                        - pcempres  -> Codigo de la empresa
     Parámetros salida: - pcidcfg    ->  Id de configuración de navegación al que pertence la navegación solicitada.
                        - pcform_act ->  Formulario actual.
                        - pcform_sig ->  Siguiente formulario al que se debe navegar desde el formulario actual según la configuración.
                        - pcform_ant ->  Anterior formulario al que se debe navegar desde el formulario actual según la configuración.
                        - pcsituac   ->  Posición del formulario actual dentro del flujo (O/M/F -> Origen/Medio/Final).
                        - mensajes   ->  Mensajes de error.
    Retorno:            - NUMBER     ->    0: Valores recuperados correctamente.
                                        <> 0: Error recuperando los datos.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_form_wizard(
      pcmodo IN VARCHAR2,
      pccfgwiz IN VARCHAR2,
      psproduc IN NUMBER,
      pcform IN VARCHAR2,
      pccampo IN VARCHAR2,
      pcempres IN NUMBER,   -- BUG9981:DRA:05/05/2009
      pcidcfg OUT NUMBER,
      pcform_act OUT VARCHAR2,
      pcform_sig OUT VARCHAR2,
      pcform_ant OUT VARCHAR2,
      pcsituac OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_form_wizard';
      vparam         VARCHAR2(500)
         := 'parámetros - pmodo: ' || pcmodo || ' - pccfgwiz: ' || pccfgwiz || ' - psproduc: '
            || psproduc || ' - pcform: ' || pcform || ' - pccampo: ' || pccampo
            || ' - pcempres: ' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;

      CURSOR cur_wizard(
         vcr_cmodo VARCHAR2,
         vcr_ccfgwiz VARCHAR2,
         vcr_sproduc NUMBER,
         vcr_cform VARCHAR2,
         vcr_ccampo VARCHAR2,
         vcr_cempres NUMBER) IS
         SELECT   wf.cidcfg, wf.cform_act, wf.csituac, wf.cform_ant, wf.cform_sig,
                  DECODE(wf.ccampo_act, '*', 99, 1) norden
             FROM cfg_wizard w, cfg_wizard_forms wf
            WHERE w.cmodo = vcr_cmodo
              AND w.ccfgwiz = vcr_ccfgwiz
              AND w.sproduc = vcr_sproduc
              AND w.cempres = vcr_cempres   -- BUG9981:DRA:05/05/2009
              AND w.cidcfg = wf.cidcfg
              AND UPPER(wf.cform_act) = UPPER(NVL(vcr_cform, wf.cform_act))
              AND wf.csituac = DECODE(NVL(vcr_cform, 'O'), 'O', 'O', wf.csituac)
              AND wf.cempres = w.cempres   -- BUG9981:DRA:05/05/2009
              AND((vcr_ccampo IS NULL
                   AND wf.ccampo_act = '*')   --BUG14429:13/05/2009:XPL
                  OR(vcr_ccampo IS NOT NULL
                     AND UPPER(wf.ccampo_act) = UPPER(vcr_ccampo)))
         ORDER BY norden ASC;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcmodo IS NULL
         OR pccfgwiz IS NULL
         OR psproduc IS NULL
         OR pccampo IS NULL
         OR pcempres IS NULL   -- BUG9981:DRA:20/05/2009
                            THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      FOR cr IN cur_wizard(pcmodo, pccfgwiz, psproduc, pcform, pccampo, pcempres) LOOP   -- BUG9981:DRA:05/05/2009
         vpasexec := 5;
         pcidcfg := cr.cidcfg;
         pcform_act := cr.cform_act;
         pcform_sig := cr.cform_sig;
         pcform_ant := cr.cform_ant;
         pcsituac := cr.csituac;
         EXIT;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_form_wizard;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera el flujo de navegación de un modo concreto, para un producto y configuración determinados.
    Parámetros entrada: - pcmodo    -> Flujo de navegación
                        - psproduc  -> Código de producto
                        - pccfgwiz  -> Id de la configuración de navegación.
                        - pcempres  -> Codigo de la empresa
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - refcursor -> Refcursor con el flujo de navegación solicitado.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_wizard(
      pcmodo IN VARCHAR2,
      psproduc IN NUMBER,
      pccfgwiz IN VARCHAR2,
      pcempres IN NUMBER,   -- BUG9981:DRA:05/05/2009
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_wizard';
      vparam         VARCHAR2(500)
         := 'parámetros - pmodo: ' || pcmodo || ' - psproduc: ' || psproduc || ' - pccfgwiz: '
            || pccfgwiz || ' - pcempres: ' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vrefcursor     sys_refcursor;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcmodo IS NULL
         OR psproduc IS NULL
         OR pccfgwiz IS NULL
         OR pcempres IS NULL   -- BUG9981:DRA:20/05/2009
                            THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vrefcursor :=
         pac_md_listvalores.f_opencursor
            ('SELECT w.cmodo, w.ccfgwiz, w.sproduc, wf.cform_act, wf.ccampo_act,'
             || ' wf.cform_sig, wf.cform_ant, wf.niteracio, wf.csituac'
             || ' FROM cfg_wizard w, cfg_wizard_forms wf' || ' WHERE w.cmodo = ''' || pcmodo
             || '''' || '   AND w.ccfgwiz = ''' || pccfgwiz || '''' || '   AND w.sproduc = '
             || psproduc || '   AND w.cempres = ' || pcempres || '   AND wf.cidcfg = w.cidcfg'
             || '   AND wf.cempres = w.cempres',   -- BUG9981:DRA:05/05/2009
             mensajes);
      RETURN vrefcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_wizard;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera si una detrrminada pantalla de un flujo debe saltarse o debe ser mostrada.
    Parámetros entrada: - pidcfg    -> Id. del flujo
                        - pcform    -> Formulario
    Parámetros salida:  - mensajes  -> mensajes de error
    Retorno:            - 0 / 1     -> saltar o no saltar la pantalla
                          NULL      -> Error
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_calc_form_value(
      pccfgcalc IN NUMBER,
      pcevent IN VARCHAR2,
      psseguro IN NUMBER,
      pitorigval IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_form_calc IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_CFG.f_get_calc_form_value';
      vparam         VARCHAR2(500)
         := 'parámetros - pccfgcalc: ' || pccfgcalc || ' - pcevent: ' || pcevent
            || ' - psseguo: ' || psseguro || ' - pItOrigVal: ' || pitorigval;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;

      CURSOR cr_calc_val(vcr_ccfgcalc NUMBER, vcr_cevent VARCHAR2) IS
         SELECT fc.citdest, fc.tcalc, fc.ctipcalc, fc.ctipres
           FROM cfg_form_calc fc
          WHERE fc.ccfgcalc = vcr_ccfgcalc
            AND fc.cevent = vcr_cevent;

      vtsql          VARCHAR2(1000);
      vdateval       DATE;
      vcharval       VARCHAR2(500);
      vnumval        NUMBER(13, 2);
      vt_calcval     t_iax_form_calc := t_iax_form_calc();
      vcalcval       ob_iax_form_calc;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pccfgcalc IS NULL
         OR pcevent IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      FOR cr IN cr_calc_val(pccfgcalc, pcevent) LOOP
         --Tractament en funció del tipus de càlcul parametritzat.
         IF cr.ctipcalc = 'OP' THEN
            --Càlcul a partir de les dades de l'objecte persistent POLIZA.
            IF pac_iax_produccion.poliza IS NULL THEN
               vpasexec := 5;
               RAISE e_param_error;
            ELSIF pac_iax_produccion.poliza.det_poliza IS NULL THEN
               vpasexec := 7;
               RAISE e_param_error;
            END IF;

            vpasexec := 9;
            vtsql := ' DECLARE ';
            vtsql := vtsql || ' BEGIN';
            vtsql := vtsql || '   :vNumVal  := 0 ';
            vtsql := vtsql || '   :vCharVal := NULL ';
            vtsql := vtsql || '   :vDateVal := NULL ';

            IF cr.ctipres = 'N' THEN
               vtsql := vtsql || '   :vNumVal := ' || cr.tcalc || '(:poliza);';
            ELSIF cr.ctipres = 'A' THEN
               vtsql := vtsql || '   :vCharVal := ' || cr.tcalc || '(:poliza);';
            ELSIF cr.ctipres = 'D' THEN
               vtsql := vtsql || '   :vDateVal := ' || cr.tcalc || '(:poliza);';
            END IF;

            vtsql := vtsql || ' END;';
            vpasexec := 11;

            EXECUTE IMMEDIATE vtsql
                        USING OUT vnumval, vcharval, vdateval,
                              IN pac_iax_produccion.poliza.det_poliza;
         ELSIF cr.ctipcalc = 'F' THEN
            --Càlcul a partir d'una funció que té per defecte dos paràmetres d'entrada definits:
            --  1.- sseguro: Id de la pòlissa amb la que es vol realitzar el càlcul.
            --  2.- itOrigVal: Representa el valor de l'item origen que ha disparat el càlcul automàtic.
            --                  Aquest valor pot ser necessari per realitzar el càlcul desitjat.
            vpasexec := 15;
            vtsql := ' DECLARE ';
            vtsql := vtsql || ' BEGIN';
            vtsql := vtsql || '   :vNumVal  := 0 ';
            vtsql := vtsql || '   :vCharVal := NULL ';
            vtsql := vtsql || '   :vDateVal := NULL ';

            IF cr.ctipres = 'N' THEN
               vtsql := vtsql || '   :vNumVal  := ' || cr.tcalc
                        || '(:sseguro, TO_NUMBER(:itOrigVal));';
            ELSIF cr.ctipres = 'A' THEN
               vtsql := vtsql || '   :vCharVal := ' || cr.tcalc || '(:sseguro, :itOrigVal);';
            ELSIF cr.ctipres = 'D' THEN
               vtsql := vtsql || '   :vDateVal := ' || cr.tcalc
                        || '(:sseguro, TO_DATE(:itOrigVal,''''DD/MM/YYYY''''));';
            END IF;

            vtsql := vtsql || ' END;';
            vpasexec := 17;

            EXECUTE IMMEDIATE vtsql
                        USING OUT vnumval, vcharval, vdateval, IN psseguro, pitorigval;
         ELSE
            --PENDENT: Avaluar el càlcul parametritzat a partir d'una select.
            NULL;
         END IF;

         vpasexec := 31;
         vt_calcval.EXTEND;
         vt_calcval(vt_calcval.LAST) := ob_iax_form_calc();
         vt_calcval(vt_calcval.LAST).ccfgcalc := pccfgcalc;
         vt_calcval(vt_calcval.LAST).cevent := pcevent;
         vt_calcval(vt_calcval.LAST).citdest := cr.citdest;
         vt_calcval(vt_calcval.LAST).ctipres := cr.ctipres;
         vt_calcval(vt_calcval.LAST).numval := vnumval;
         vt_calcval(vt_calcval.LAST).charval := vcharval;
         vt_calcval(vt_calcval.LAST).dateval := vdateval;
         vpasexec := 33;
      END LOOP;

      RETURN vt_calcval;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_calc_form_value;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Recupera la configuración de la navegación.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de navegación.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgwizard(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_cfgwizard';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
   BEGIN
      RETURN pac_md_listvalores.f_opencursor
               ('select ccfgwiz codigo, tcfgwiz valor from cfg_cod_cfgwizard_det'
                || ' where cidioma =' || pac_md_common.f_get_cxtidioma || ' and cempres ='
                || pac_md_common.f_get_cxtempresa,   -- BUG9981:DRA:06/05/2009
                mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_lst_cfgwizard;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Recupera la configuración de la pantalla.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de pantalla.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgform(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_cfgform';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
   BEGIN
      RETURN pac_md_listvalores.f_opencursor
               ('select ccfgform codigo, tcfgform valor from cfg_cod_cfgform_det'
                || ' where cidioma =' || pac_md_common.f_get_cxtidioma || ' and cempres ='
                || pac_md_common.f_get_cxtempresa,   -- BUG9981:DRA:06/05/2009
                mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_lst_cfgform;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Recupera la configuración de las acciones.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de acciones.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgaccion(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_cfgaccion';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
   BEGIN
      RETURN pac_md_listvalores.f_opencursor
               ('select ccfgacc codigo, tcfgacc valor from cfg_cod_cfgaccion_det '
                || 'where cidioma =' || pac_md_common.f_get_cxtidioma || ' and cempres ='
                || pac_md_common.f_get_cxtempresa,   -- BUG9981:DRA:06/05/2009
                mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_lst_cfgaccion;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Recupera la configuración del menu.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de configuración del menu.
   ******************************************************************************************/
   FUNCTION f_get_lst_rolmenu(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_rolmenu';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
   BEGIN
      RETURN pac_md_listvalores.f_opencursor('select crolmen codigo, trolmen valor '
                                             || ' from menu_desrolmen' || ' where cidioma ='
                                             || pac_md_common.f_get_cxtidioma,
                                             mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_lst_rolmenu;

   /******************************************************************************************
     Autor: JTS (01/10/2012)
     Descripción: Recupera los roles existentes
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de roles
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgrol(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_cfgrol';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
   BEGIN
      RETURN pac_md_listvalores.f_opencursor
               ('select crd.crol, crd.trol from cfg_rol cr, cfg_rol_det crd where cr.crol = crd.crol and cr.cempres = crd.cempres '
                || ' and crd.cidioma =' || pac_md_common.f_get_cxtidioma
                || ' and crd.cempres =' || pac_md_common.f_get_cxtempresa
                || ' order by crd.trol ',
                mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_lst_cfgrol;

   /******************************************************************************************
     Autor: JTS (01/10/2012)
     Descripción: Recupera las politicas de subscripcion
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de roles
   ******************************************************************************************/
   FUNCTION f_get_lst_usuagru(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_usuagru';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
   BEGIN
      RETURN pac_md_listvalores.f_opencursor
                                          ('select cusuagru, tusuagru from psu_desusuagru'
                                           || ' where cidioma ='
                                           || pac_md_common.f_get_cxtidioma
                                           || ' order by tusuagru ',
                                           mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_lst_usuagru;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Inserta/Update un registro en la tabla CFG_USER.
     Parámetros entrada: - pcusuari -> usuario
                         - pwizard -> configuración de navegación
                         - pform -> configuración de formularios
                         - paccion -> configuración de acciones
                         - pcempres --> Empresa
                         - pcfgdoc --> configuración de documentación
     Parámetros salida:  - mensajes  -> Mensajes de error
     return:             devuelve 0 si todo bien, sino el código del error
   ******************************************************************************************/
   FUNCTION f_set_cfg_user(
      pusuario IN VARCHAR2,
      pwizard IN VARCHAR2,
      pform IN VARCHAR2,
      paccion IN VARCHAR2,
      pcempres IN NUMBER,
      pcfgdoc IN VARCHAR2,
      paccprod IN VARCHAR2,   -- BUG16471:DRA:26/10/2010
      pccfgmap IN VARCHAR2,   -- BUG 21569 - 07/03/2012 - JMP
      pcrol IN VARCHAR2,
      pareas IN VARCHAR2,  --IAXIS-4994
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_USER.F_Set_cfg_user';
      vparam         VARCHAR2(500)
         := 'parámetros - pusuario: ' || pusuario || ' pwizard:' || pwizard || ' pform:'
            || pform || ' paccion:' || paccion || ' pcempres:' || pcempres || ' pcfgdoc:'
            || pcfgdoc || ' paccprod:' || paccprod;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vmenserr       VARCHAR2(250);
      vnewpwdenc     VARCHAR2(100);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pusuario IS NULL
         OR pcempres IS NULL   -- BUG9981:DRA:20/05/2009
                            THEN
         RAISE e_param_error;
      END IF;

      --Actualitcen el terminal
      vnumerr := pac_cfg.f_set_cfg_user(pusuario, pwizard, pform, paccion, pcempres, pcfgdoc,
                                        paccprod, pccfgmap, pcrol, pareas/*IAXIS-4994*/);   -- BUG16471:DRA:26/10/2010

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_cfg_user;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Inserta/Update un registro en la tabla CFG_USER.
     Parámetros entrada: - pcusuari -> usuario
                         - pwizard -> configuración de navegación
                         - pform -> configuración de formularios
                         - paccion -> configuración de acciones
                         - pcempres --> Empresa
                         - pcfgdoc --> configuración de documentación
     Parámetros salida:  - mensajes  -> Mensajes de error
     return:             devuelve 0 si todo bien, sino el código del error
   ******************************************************************************************/
   FUNCTION f_set_cfg_userrol(
      pusuario IN VARCHAR2,
      pcempres IN NUMBER,
      pcrol IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_USER.F_Set_cfg_userrol';
      vparam         VARCHAR2(500)
         := 'parámetros - pusuario: ' || pusuario || ' pcempres:' || pcempres || ' pcrol:'
            || pcrol;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vccfgwiz       VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vccfgacc       VARCHAR2(50);
      vccfgdoc       VARCHAR2(50);
      vcaccprod      VARCHAR2(50);
      vccfgmap       VARCHAR2(50);
      vcusuagru      VARCHAR2(50);
      vcrolmen       VARCHAR2(50);
      vcconsupl      VARCHAR2(50);
      vilimite       NUMBER;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pusuario IS NULL
         OR pcempres IS NULL
         OR pcrol IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      SELECT ccfgwiz, ccfgform, ccfgacc, ccfgdoc, caccprod, ccfgmap, cusuagru,
             crolmen, cconsupl, ilimite
        INTO vccfgwiz, vccfgform, vccfgacc, vccfgdoc, vcaccprod, vccfgmap, vcusuagru,
             vcrolmen, vcconsupl, vilimite
        FROM cfg_rol
       WHERE crol = pcrol
         AND cempres = pcempres;

      vpasexec := 10;
      vnumerr := pac_md_cfg.f_set_cfg_user(pusuario, vccfgwiz, vccfgform, vccfgacc, pcempres,
                                           vccfgdoc, vcaccprod, vccfgmap, pcrol,null, mensajes);--IAXIS-4994
      vpasexec := 11;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF vcrolmen IS NOT NULL THEN
         vpasexec := 12;
         vnumerr := pac_md_cfg.f_set_cfg_menu(pusuario, vcrolmen, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF vcconsupl IS NOT NULL THEN
         vpasexec := 13;
         vnumerr := pac_md_cfg.f_set_pds_configuser(pusuario, vcconsupl, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF vcusuagru IS NOT NULL THEN
         vpasexec := 14;
         vnumerr := pac_md_cfg.f_set_psu_usuagru(pusuario, vcusuagru, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF vilimite IS NOT NULL THEN
         vpasexec := 15;

         --vnumerr := pac_md_cfg.f_set_psu_usuagru(pusuario, vilimite, mensajes);
         /*
         UPDATE sin_tramita_pago_aut
            SET ilimite = vilimite
          WHERE cusuari = pusuario;*/
         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_cfg_userrol;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Inserta/Update un registro en la tabla MENU_USERCODIROL.
     Parámetros entrada: - pcusuari -> usuario
                         - pmenu -> configuración de navegación
     Parámetros salida:  - mensajes  -> Mensajes de error
     return:             devuelve 0 si todo bien, sino el código del error
   ******************************************************************************************/
   FUNCTION f_set_cfg_menu(
      pusuario IN VARCHAR2,
      pmenu IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_USER.F_Set_cfg_menu';
      vparam         VARCHAR2(500)
                                := 'parámetros - pusuario: ' || pusuario || ' pmenu:' || pmenu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vmenserr       VARCHAR2(250);
      vnewpwdenc     VARCHAR2(100);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pusuario IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Actualitcen el terminal
      vnumerr := pac_cfg.f_set_cfg_menu(pusuario, pmenu);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_cfg_menu;

   /******************************************************************************************
     Autor: XVILA (04/12/2008)
     Descripció: Retorna la llista dels perfils de suplements
     Paràmetres entrada: -
     Paràmetres sortida: - mensajes  -> Missatges d'error
     Return:             - refcursor -> Refcursor amb els perfils de suplement
   ******************************************************************************************/
   FUNCTION f_get_lst_codsuplem(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_codsuplem';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vrefcursor     sys_refcursor;
      psqlquery      VARCHAR2(200);
   BEGIN
      vnumerr := pac_cfg.f_get_lst_codsuplem(psqlquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      RETURN pac_md_listvalores.f_opencursor(psqlquery, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_lst_codsuplem;

   /******************************************************************************************
     Autor: XVILA (04/12/2008)
     Descripció: Fa la crida a la capa de negoci de la mateixa funció per insertar a la taula PDS_CONFIG_USER
     Paràmetres entrada: - pcuser    -> id. usuari
                         - pcconsupl -> id. conf dels suplements
     Paràmetres sortida: - mensajes  -> Missatges d'error
     Return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_pds_configuser(
      pcuser IN VARCHAR2,
      pcconsupl IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_set_pds_configuser';
      vparam         VARCHAR2(500)
                         := 'parámetros - pcuser: ' || pcuser || ' - pcconsupl: ' || pcconsupl;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pcuser IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_cfg.f_set_pds_configuser(pcuser, pcconsupl);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_pds_configuser;

   /******************************************************************************************
     Autor: JTS (02/10/2012)
     Descripció: Inserta els valors passats per paràmetre a la taula PSU_USUAGRU
     Paràmetres entrada: - pcuser    -> id. usuari
                         - pcusuagru -> id. conf
     Paràmetres sortida: - mensajes  -> Missatges d'error
     Return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_psu_usuagru(
      pcuser IN VARCHAR2,
      pcusuagru IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_set_psu_usuagru';
      vparam         VARCHAR2(500)
                         := 'parámetros - pcuser: ' || pcuser || ' - pcusuagru: ' || pcusuagru;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pcuser IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_cfg.f_set_psu_usuagru(pcuser, pcusuagru);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_psu_usuagru;

    /******************************************************************************************
     Autor: DCT (23/03/2009)
     Descripción: Recupera la configuración de la documentación.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de documentación.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgdoc(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_cfgdoc';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
   BEGIN
      RETURN pac_md_listvalores.f_opencursor
                           ('select ccfgdoc codigo, tcfgdoc valor from cfg_cod_cfgdoc_det'
                            || ' where cempres =' || pac_md_common.f_get_cxtempresa
                            || ' and  cidioma =' || pac_md_common.f_get_cxtidioma,
                            mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_lst_cfgdoc;

   /************************************************************************************************
           Bug 16064: CRT101 - Boton enviar correo avisando de nueva solicitud #XPL#13/10/2010
           Descripción: Envia mail segons la taula de configuració
           Parámetros entrada: - pcempres --> Empresa
                                 pmodo    --> Mode
                                 ptevento --> Event del qual s'accedeix
                                 psproduc --> Producte
                                 psseguro --> Seguro si existia per pantalla
                                 pnriesgo --> Risc del seguro
                                 pnsinies --> Sinistre
                                 pcmotmov --> Motiu moviment
           Parámetros salida:  - mensajes
           Retorno:            - error -> 1 KO, 0 OK
       ************************************************************************************************/
   FUNCTION f_enviar_notificacion(
      pcempres IN NUMBER,
      pmodo IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnsinies IN NUMBER,
      pcmotmov IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_md_cfg.f_enviar_notificacion';
      vnumerr        NUMBER;
      vcempres       NUMBER;
   BEGIN
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vnumerr := pac_cfg.f_enviar_notificacion(vcempres, pmodo, ptevento, psproduc, psseguro,
                                               pnriesgo, pnsinies, pcmotmov,
                                               pac_md_common.f_get_cxtidioma);

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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_enviar_notificacion;

   /******************************************************************************************
     Descripción: Recupera la lista de informes que se pueden lanzar des de una pantalla
     Param in pcempres :    código de empresa
     Param in pcform :      código de pantalla
     Param in ptevento :    código de evento
     Param in psproduc :    código de producto
     Param out pcurconfigsinf : lista de listados
     Param out mensajes       : Mensajes de error
     Retorno 0 -> Ok
             1 -> Ko

     Bug 15743 - 14/10/2010 - XPL/AMC
   ******************************************************************************************/
   FUNCTION f_get_informes(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pcurconfigsinf OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_md_cfg.f_get_informes';
      num_err        NUMBER;
      vcempres       NUMBER;
      squery         VARCHAR2(3000);
      vwhere         VARCHAR2(3000);
      vccfgform      VARCHAR2(200);
      vcont          NUMBER;
      v_ccfgmap      cfg_map.ccfgmap%TYPE;
   BEGIN
      vpasexec := 1;
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vwhere := ' where cempres = ' || vcempres || ' and cform = ''' || pcform || '''';

      IF ptevento IS NOT NULL THEN
         vwhere := vwhere || ' and tevento = ''' || ptevento || '''';
      ELSE
         vwhere := vwhere || ' and tevento = ''GENERAL''';
      END IF;

      IF psproduc IS NOT NULL THEN
         vwhere := vwhere || ' and sproduc = ' || psproduc;
      ELSE
         vwhere := vwhere || ' and sproduc = 0 ';
      END IF;

      vccfgform := pac_md_cfg.f_get_user_cfgform(pac_md_common.f_get_cxtusuario, vcempres,
                                                 pcform, mensajes);

      IF vccfgform IS NULL THEN
         RAISE e_object_error;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM cfg_lanzar_informes
       WHERE cempres = vcempres
         AND cform = pcform
         AND ccfgform = vccfgform;

      IF vcont = 0 THEN
         vwhere := vwhere || ' and CCFGFORM = ''GENERAL''';
      ELSE
         vwhere := vwhere || ' and CCFGFORM = ''' || vccfgform || '''';
      END IF;

      -- BUG 21569 - 07/03/2012 - JMP -
      SELECT ccfgmap
        INTO v_ccfgmap
        FROM cfg_user
       WHERE cempres = vcempres
         AND cuser = f_user;

      IF v_ccfgmap IS NOT NULL THEN
         vwhere := vwhere || ' and cmap in (SELECT cmapead FROM cfg_map WHERE cempres = '
                   || vcempres || ' AND ccfgmap = ''' || v_ccfgmap || ''')';
      END IF;

      -- FIN BUG 21569 - 07/03/2012 - JMP -
      squery := 'select C.*, f_axis_literales(slitera,' || pac_md_common.f_get_cxtidioma
                || ') TLITERA  from CFG_LANZAR_INFORMES C' || vwhere;
      pcurconfigsinf := pac_md_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_informes;

   /******************************************************************************************
     Descripción: Monta un objeto con los parametros que se le pasan
     Param in pparams :    parametros a formatear

     Retorno lista de parametros con su valor

     Bug 15743 - 14/10/2010 - XPL/AMC
   ******************************************************************************************/
   FUNCTION f_get_params(pparams IN VARCHAR2)
      RETURN t_iax_info IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_params';
      vparam         VARCHAR2(500) := 'parámetros - pparams : ' || pparams;
      pos            NUMBER;
      tipo           VARCHAR2(2000);
      posdp          NUMBER;
      vtinfo         t_iax_info;
      vinfo          ob_iax_info;
   BEGIN
      vtinfo := t_iax_info();

      FOR i IN 1 .. LENGTH(pparams) LOOP
         pos := INSTR(pparams, '|', 1, i);
         posdp := INSTR(pparams, '|', 1, i + 1);
         tipo := SUBSTR(pparams, pos + 1,(posdp - pos) - 1);

         IF tipo IS NOT NULL THEN
            vinfo := ob_iax_info();
            vtinfo.EXTEND;
            vinfo.nombre_columna := SUBSTR(tipo, 1, INSTR(tipo, ':') - 1);
            vinfo.valor_columna := SUBSTR(tipo, INSTR(tipo, ':') + 1);
            vtinfo(vtinfo.LAST) := vinfo;
         END IF;
      END LOOP;

      RETURN vtinfo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);
         RETURN NULL;
   END f_get_params;

   /******************************************************************************************
     Descripción: Monta el objeto separando el varchar2 de entrada por el caracter ':'
     Param in pparams :    parametros a formatear
     Retorno lista de parametros con su valor
     -- Bug 17179#07/01/2011#XPL
   ******************************************************************************************/
   FUNCTION f_get_verficar_params(pparams IN VARCHAR2)
      RETURN t_iax_info IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_params';
      vparam         VARCHAR2(500) := 'parámetros - pparams : ' || pparams;
      pos            NUMBER;
      tipo           VARCHAR2(2000);
      posdp          NUMBER;
      vtinfo         t_iax_info;
      vinfo          ob_iax_info;
   BEGIN
      vtinfo := t_iax_info();

      FOR i IN 1 .. LENGTH(pparams) LOOP
         pos := INSTR(pparams, ':', 1, i);
         posdp := INSTR(pparams, ':', 1, i + 1);
         tipo := SUBSTR(pparams, pos + 1,(posdp - pos) - 2);

         IF tipo IS NOT NULL THEN
            vinfo := ob_iax_info();
            vtinfo.EXTEND;
            vinfo.nombre_columna := tipo;
            vtinfo(vtinfo.LAST) := vinfo;
         ELSIF pos > 0 THEN
            tipo := SUBSTR(pparams, pos + 1, LENGTH(pparams));
            vinfo := ob_iax_info();
            vtinfo.EXTEND;
            vinfo.nombre_columna := tipo;
            vtinfo(vtinfo.LAST) := vinfo;
         END IF;
      END LOOP;

      RETURN vtinfo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);
         RETURN NULL;
   END f_get_verficar_params;

   /******************************************************************************************
     Descripción: Ejecuta los listados que se le indican
     Param in pcempres :    código de empresa
     Param in pcform :      código de pantalla
     Param in ptevento :    código de evento
     Param in psproduc :    código de producto
     Param in pcmap :       listado de maps a ejecutar
     Param in pparans :     Listado de parametros de los maps
     Param out vtimp :      lista de listados generados
     Param out mensajes       : Mensajes de error
     Retorno 0 -> Ok
             1 -> Ko

     Bug 15743 - 14/10/2010 - XPL/AMC
   ******************************************************************************************/
   FUNCTION f_ejecutar_informe(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pcmap IN VARCHAR2,
      pparams IN VARCHAR2,
      vtimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_md_cfg.f_ejecutar_informe';
      num_err        NUMBER;
      vcempres       NUMBER;
      squery         VARCHAR2(3000);
      vwhere         VARCHAR2(3000);
      vparams        CLOB := pparams;
      vlparams       VARCHAR2(4000);
      vtinfo         t_iax_info;
      vtinfo2        t_iax_info;   -- Bug 17179#07/01/2011#XPL
      v_res          VARCHAR2(2000);
      v_ficheros     VARCHAR2(2000);
      vobimp         ob_iax_impresion := ob_iax_impresion();
      pos            NUMBER;
      vmap           VARCHAR2(200);
      posdp          NUMBER;
      vterror        VARCHAR2(200);
      vreport        VARCHAR2(200);
      vejecutarep    VARCHAR2(200);
      v_res_report   VARCHAR2(2000);
      trobat         BOOLEAN := FALSE;   -- Bug 17179#07/01/2011#XPL
      vccfgform      VARCHAR2(1000);
      vcont          NUMBER;
   BEGIN
      vtimp := t_iax_impresion();
      vpasexec := 2;
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vtinfo := f_get_params(vparams);
      vpasexec := 3;
      vccfgform := pac_md_cfg.f_get_user_cfgform(pac_md_common.f_get_cxtusuario, vcempres,
                                                 pcform, mensajes);

      IF vccfgform IS NULL THEN
         RAISE e_object_error;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM cfg_lanzar_informes
       WHERE cempres = vcempres
         AND cform = pcform
         AND ccfgform = vccfgform;

      IF vcont = 0 THEN
         vccfgform := 'GENERAL';
      END IF;

      FOR i IN 1 .. LENGTH(pcmap) LOOP
         pos := INSTR(pcmap, '|', 1, i);
         posdp := INSTR(pcmap, '|', 1, i + 1);
         vmap := SUBSTR(pcmap, pos + 1,(posdp - pos) - 1);
         vpasexec := 4;

         IF vmap IS NOT NULL THEN
            FOR cur IN (SELECT *
                          FROM cfg_lanzar_informes
                         WHERE cempres = pcempres
                           AND cform = pcform
                           AND(ptevento IS NOT NULL
                               AND tevento = ptevento
                               OR ptevento IS NULL
                                  AND tevento = 'GENERAL')
                           AND(pcmap IS NOT NULL
                               AND cmap = vmap
                               OR vmap IS NULL)
                           AND(psproduc IS NOT NULL
                               AND sproduc = psproduc
                               OR psproduc IS NULL
                                  AND sproduc = 0)
                           AND(ccfgform = vccfgform)) LOOP
               v_res := cur.lparams;
               v_res_report := cur.lparams;
               vtinfo2 := f_get_verficar_params(cur.lparams);   -- Bug 17179#07/01/2011#XPL
               vpasexec := 5;

               FOR i IN vtinfo.FIRST .. vtinfo.LAST LOOP
                  v_res := REPLACE(v_res, ':GENERA_REPORT', '0');

                  IF cur.lparams LIKE('%' || vtinfo(i).nombre_columna || '%') THEN
                     v_res := REPLACE(v_res, ':' || vtinfo(i).nombre_columna,
                                      vtinfo(i).valor_columna);
                     v_res_report := REPLACE(v_res_report, ':' || vtinfo(i).nombre_columna,
                                             vtinfo(i).valor_columna);
                  END IF;
               END LOOP;

               -- Bug 17179#07/01/2011#XPL inici
               --Si per pantalla no enviem un paràmetre necessari per crear el map.
               --Enviarem aquest paràmetre a null per tal de què funcioni, això no hauria de passar
               --ja que per pantalla s'hauria d'enviar tots els params necessaris XPL
               FOR j IN vtinfo2.FIRST .. vtinfo2.LAST LOOP
                  trobat := FALSE;

                  FOR i IN vtinfo.FIRST .. vtinfo.LAST LOOP
                     IF vtinfo(i).nombre_columna = vtinfo2(j).nombre_columna THEN
                        trobat := TRUE;
                     END IF;
                  END LOOP;

                  IF NOT trobat THEN
                     v_res := REPLACE(v_res, ':' || vtinfo2(j).nombre_columna || '|', '|');
                     v_res := REPLACE(v_res, ':' || vtinfo2(j).nombre_columna, '');
                     v_res_report := REPLACE(v_res_report,
                                             ':' || vtinfo2(j).nombre_columna || '|', '|');
                     v_res_report := REPLACE(v_res_report, ':' || vtinfo2(j).nombre_columna,
                                             '');
                  END IF;
               END LOOP;

               -- Bug 17179#07/01/2011#XPL fi
               vpasexec := 6;

               IF v_res IS NOT NULL THEN
                  vtimp.EXTEND;
                  v_ficheros := pac_md_map.f_ejecuta(cur.cmap, v_res, vejecutarep, mensajes);
                  vobimp.fichero := v_ficheros;
                  vobimp.descripcion := f_axis_literales(cur.slitera, 1);
                  vtimp(vtimp.LAST) := vobimp;

                  -- Si el map tiene un report associado lo ejecutamos
                  IF cur.genera_report IS NOT NULL
                     AND cur.genera_report = 1 THEN
                     v_ficheros := pac_md_map.f_ejecuta(cur.cmap, v_res_report, vejecutarep,
                                                        mensajes);
                     num_err := pac_md_listado.f_genera_report(NULL, pcempres, v_ficheros,
                                                               pac_md_common.f_get_cxtidioma,
                                                               cur.cmap, vterror, vreport,
                                                               mensajes);
                     vtimp.EXTEND;
                     vobimp.fichero := vreport;
                     vtimp(vtimp.LAST) := vobimp;
                  END IF;
               END IF;

               v_res := '';
            END LOOP;

            vpasexec := 7;
         END IF;
      END LOOP;

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
   END f_ejecutar_informe;

   /******************************************************************************************
     Descripción: Ejecuta los listados que se le indican en modo BACTH
     Param in pcempres :    código de empresa
     Param in pcform :      código de pantalla
     Param in ptevento :    código de evento
     Param in psproduc :    código de producto
     Param in pcmap :       listado de maps a ejecutar
     Param in pparans :     Listado de parametros de los maps
     Param in psproces:     Numero de proces
     Param out vtimp :      lista de listados generados
     Param out mensajes       : Mensajes de error
     Retorno 0 -> Ok
             1 -> Ko

     Bug 27699 - 30/07/2013 - RCL
   ******************************************************************************************/
   FUNCTION f_ejecutar_informe_batch(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pcmap IN VARCHAR2,
      pparams IN VARCHAR2,
      psproces IN NUMBER,
      vtimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 10;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_md_cfg.f_ejecutar_informe_batch';
      num_err        NUMBER;
      vcempres       NUMBER;
      vsproces       NUMBER;
      v_titulo       VARCHAR2(200);
      vidioma        NUMBER;
      v_subject      desmensaje_correo.asunto%TYPE;
      v_from         mensajes_correo.remitente%TYPE;
      v_texto        desmensaje_correo.cuerpo%TYPE;
      pscorreo       mensajes_correo.scorreo%TYPE;
      v_to           VARCHAR2(250);
      v_to2          VARCHAR2(250);
      -- JLB - 31758
      v_mail_usu     usuarios.mail_usu%type;
      v_tusunom      usuarios.tusunom%type;
      --
      v_errcor       log_correo.error%TYPE;
      v_plsql        VARCHAR2(4000);
      vconn          UTL_SMTP.connection;
      v_lob          BLOB;
      v_buffer_size  INTEGER := 57;
      v_offset       NUMBER := 1;
      v_raw          RAW(32767);
      v_length       NUMBER := 0;
      fichero        BFILE;
      v_path         VARCHAR2(2000);
      v_filename     VARCHAR2(2000);
      v_llinia       NUMBER;
      v_ttexto       procesoslin.tprolin%TYPE;
      -- jlb - i 30930
      v_directory     varchar2(300);
      -- jlb - f
   BEGIN
      v_llinia := NULL;
      vidioma := pac_md_common.f_get_cxtidioma;
      vtimp := t_iax_impresion();
      vpasexec := 20;
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      IF psproces IS NULL THEN
         num_err := 0;
         vpasexec := 30;
         v_titulo := f_axis_literales(9001551, vidioma);
         vpasexec := 40;
         v_titulo := v_titulo || ' ' || f_axis_literales(101619, vidioma) || ' ' || pcempres;
         vpasexec := 50;
         num_err := f_procesini(f_user, pcempres, 'INFORMES', v_titulo, vsproces);
         COMMIT;
         num_err := NULL;
         v_titulo := NULL;

         DECLARE
            FUNCTION f_nulos(p_camp IN VARCHAR2, p_tip IN NUMBER DEFAULT 1)
               RETURN VARCHAR2 IS
            BEGIN
               vpasexec := 60;

               IF p_camp IS NULL THEN
                  RETURN ' null';
               ELSE
                  IF p_tip = 2 THEN
                     RETURN ' to_date(' || CHR(39) || p_camp || CHR(39) || ',''ddmmyyyy'')';
                  ELSE
                     RETURN ' ' || CHR(39) || p_camp || CHR(39);
                  END IF;
               END IF;
            END;
         BEGIN
            vpasexec := 70;

            SELECT COUNT(1)
              INTO num_err
              FROM user_jobs
             WHERE UPPER(what) LIKE '%P_EJECUTAR_INFORMES%';

            IF num_err > 0 THEN
               -- Ya existe un proceso de informe activo
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905165);
               RAISE e_object_error;
            END IF;

            v_plsql := 'DECLARE num_err NUMBER; begin ' || CHR(10)
                       || 'num_err:= pac_contexto.f_inicializarctx(' || CHR(39) || f_user
                       || CHR(39) || ');' || CHR(10) || 'P_EJECUTAR_INFORMES(' || pcempres
                       || ', ' || f_nulos(pcform) || ', ' || f_nulos(ptevento) || ', '
                       || f_nulos(psproduc) || ',' || f_nulos(pcmap) || ',' || f_nulos(pparams)
                       || ',' || vsproces || ');' || CHR(10) || ' end;';
            num_err := pac_jobs.f_ejecuta_job(NULL, v_plsql, NULL);

            IF num_err > 0 THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || num_err);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, num_err);
               RETURN 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || ' men=' || num_err,
                           SQLCODE || ' ' || SQLERRM);
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                                 psqcode => SQLCODE, psqerrm => SQLERRM);
               RETURN 1;
         END;

         IF vsproces IS NOT NULL THEN
            -- Proceso diferido
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0,
                                                 f_axis_literales(9904687, vidioma) || ' '
                                                 || vsproces);
         END IF;

         RETURN 0;
      END IF;

      vpasexec := 75;
      /* Ejecucion del informe de manera habitual */
      num_err := pac_md_cfg.f_ejecutar_informe(pcempres, pcform, ptevento, psproduc, pcmap,
                                               pparams, vtimp, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);   -- error interno.
         v_ttexto := f_axis_literales(num_err, vidioma);
         num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         RAISE e_object_error;
      END IF;

      /* ************************** *
       * Inici - Enviament del mail *
       * ************************** */

      -- Obtenemos el scorreo
      vpasexec := 80;

      BEGIN
         SELECT MAX(scorreo)
           INTO pscorreo
           FROM mensajes_correo
          WHERE ctipo = 16;
      EXCEPTION
         WHEN OTHERS THEN
            v_ttexto := f_axis_literales('151425', vidioma);   --No existe ningun correo de este tipo
            num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
            RAISE e_object_error;
      END;

      -- Obtenemos el asunto
      vpasexec := 90;
      num_err := pac_correo.f_asunto(pscorreo, vidioma, v_subject, NULL, NULL, NULL);

      IF v_subject IS NULL
         OR num_err <> 0 THEN
         v_ttexto := f_axis_literales('151422', vidioma);   --No esixte ningún Subject para este tipo de correo.
         num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         RAISE e_object_error;
      END IF;

      --Obtenemos el origen
      vpasexec := 100;
      num_err := pac_correo.f_origen(pscorreo, v_from);

      IF num_err <> 0 THEN
         v_ttexto := f_axis_literales(num_err, vidioma);   --No esixte ningún correo de este tipo.
         num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         RAISE e_object_error;
      END IF;

      --Obtenemos el destinatario (usuario guardado en procesoscab en el momento de lanzar el BATCH)
      vpasexec := 110;

      SELECT cusuari
        INTO v_to
        FROM procesoscab
       WHERE sproces = psproces;

       begin
       	 select mail_usu, tusunom
       	 into v_mail_usu, v_tusunom
       	 from usuarios where cusuari  = upper(v_to);
       exception
       	 when others then
       	 	  null; -- seguimos con el v_to que hemos recuperado de procesos
       end;

    -- 31758 -- JLB
      if  v_mail_usu is null then --
        IF v_to IS NOT NULL THEN
           v_to2 := v_to;
           v_to := v_to || NVL(pac_parametros.f_parempresa_t(vcempres, 'DOM_MAIL'), '');
        ELSE
           v_to := f_user || NVL(pac_parametros.f_parempresa_t(vcempres, 'DOM_MAIL'), '');
           v_to2 := f_user;
        END IF;
      else
      	v_to := v_mail_usu;
      	v_to2 :=  v_tusunom;  --usuario
      end if;

      -- Obtenemos el cuerpo del correo
      vpasexec := 120;
      num_err := pac_correo.f_cuerpo(pscorreo, vidioma, v_texto, NULL, NULL);

      IF v_texto IS NULL
         OR num_err <> 0 THEN
         v_ttexto := f_axis_literales('152556', vidioma);   --Error en el cuerpo del mensaje
         num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         RAISE e_object_error;
      END IF;

      -- AÑADIMOS TODOS LOS DOCUMENTOS
      vpasexec := 130;
      v_texto := v_texto || CHR(10);

      FOR i IN vtimp.FIRST .. vtimp.LAST LOOP
         v_texto := v_texto || CHR(10) || vtimp(i).fichero;
      END LOOP;

      BEGIN
         -- Enviar el correo
         vpasexec := 140;
         --p_enviar_correo(v_from, v_to, v_from, v_to2, v_subject, v_texto);

         --Inici bug 27699 - 07/10/2013 - RCL
         vpasexec := 150;
         vconn := pac_send_mail.begin_mail(sender => v_from, recipients => v_to,
                                           subject => v_subject,
                                           mime_type => pac_send_mail.multipart_mime_type);
         vpasexec := 160;
         pac_send_mail.attach_text(conn => vconn, DATA => v_texto, mime_type => 'text/html');
         vpasexec := 170;

      --  JLB - I - 30930
           v_path := f_parinstalacion_t('INFORMES_C');
           v_directory := f_parinstalacion_t('INFORMES');
       --  JLB - F - 30930
         FOR i IN vtimp.FIRST .. vtimp.LAST LOOP
        --  JLB - I - 30930
           v_filename := REPLACE(vtimp(i).fichero, v_path || '\');
           pac_send_mail.attach_base64_readfile(
                       conn => vconn, -- conn IN OUT NOCOPY UTL_SMTP.connection,
                       directory => v_directory,  --DIRECTORY IN VARCHAR2,
                       filename => v_filename ,   --filename IN VARCHAR2,
                       mime_type =>'application/octet-stream', -- mime_type IN VARCHAR2 DEFAULT 'application/octet',
                       inline => FALSE, --inline IN BOOLEAN DEFAULT TRUE,
                       LAST=> FALSE --LAST IN BOOLEAN DEFAULT FALSE
                       );
           if i = vtimp.LAST then
              PAC_SEND_MAIL.END_ATTACHMENT( conn => vconn,LAST=> TRUE);
           end if;
              --  JLB - F - 30930
         END LOOP;

         vpasexec := 200;
         pac_send_mail.end_mail(conn => vconn);
         vpasexec := 210;
         --Fi bug 27699 - 07/10/2013 - RCL
         v_errcor := '0';
      EXCEPTION
         WHEN OTHERS THEN
            v_ttexto := f_axis_literales('1000610', vidioma);   --Error al enviar el fichero
            num_err := f_proceslin(psproces,
                                   SUBSTR(v_ttexto || ' SQLCODE=' || SQLCODE, 1, 120), 0,
                                   v_llinia);
            RAISE e_object_error;
      END;

      vpasexec := 220;
      pac_correo.p_log_correo(f_sysdate, v_to, f_user, v_subject, v_errcor, NULL, NULL);
      /* *********************** *
       * Fi - Enviament del mail *
       * *********************** */
      num_err := f_procesfin(psproces, 0);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         IF psproces IS NOT NULL THEN
            num_err := f_proceslin(psproces,
                                   SUBSTR('ERROR ' || vobject || ' ' || SQLCODE || '-'
                                          || num_err || '-' || vpasexec,
                                          1, 120),
                                   0, v_llinia, 2);
            num_err := f_procesfin(psproces, 1000005);
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         IF psproces IS NOT NULL THEN
            num_err := f_proceslin(psproces,
                                   SUBSTR('ERROR ' || vobject || ' ' || SQLCODE || '-'
                                          || num_err || '-' || vpasexec,
                                          1, 120),
                                   0, v_llinia, 2);
            num_err := f_procesfin(psproces, 1000006);
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         IF psproces IS NOT NULL THEN
            num_err := f_proceslin(psproces,
                                   SUBSTR('ERROR ' || vobject || ' ' || SQLCODE || '-'
                                          || num_err || '-' || vpasexec,
                                          1, 120),
                                   0, v_llinia, 2);
            num_err := f_procesfin(psproces, 1000001);
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_ejecutar_informe_batch;

   -- BUG16471:DRA:26/10/2010:Inici
   /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       Descripción: Recupera la configuración de acceso a productos asociada a un usuario
       Parámetros entrada: - pcuser    -> Usuario
                           - pcempres  -> Empresa
       Parámetros salida:  - mensajes  -> Mensajes de error
       Retorno:            - vaccprod  -> Configuración de navegación asociada al usuario
                             NULL      -> Error
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_user_caccprod(
      pcuser IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_user_caccprod';
      vparam         VARCHAR2(500)
                           := 'parámetros - pcuser: ' || pcuser || ' - pcempres: ' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcaccprod      VARCHAR2(50);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcuser IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recupero la configuració específica de l'usuari per la pantalla.
      --Si no en té configuració específica per la pantalla, recupero la configuració per defecte de l'usuari.
      vnumerr := pac_cfg.f_get_user_caccprod(pcuser, pcempres, vcaccprod);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --Tot ok
      RETURN vcaccprod;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_user_caccprod;

   /******************************************************************************************
     Descripción: Recupera la configuración del acceso de productos
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de pantalla.
   ******************************************************************************************/
   FUNCTION f_get_lst_caccprod(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_caccprod';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
   BEGIN
      RETURN pac_md_listvalores.f_opencursor
               ('select caccprod codigo, taccprod valor from cfg_cod_accprod_det'
                || ' where cidioma =' || pac_md_common.f_get_cxtidioma || ' and cempres ='
                || pac_md_common.f_get_cxtempresa,   -- BUG9981:DRA:06/05/2009
                mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_caccprod;

-- BUG16471:DRA:26/10/2010:Fi
   -- BUG 21569 - 07/03/2012 - JMP - Se añade la función
   /******************************************************************************************
     Descripción: Recupera la configuración de informes.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de documentación.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgmap(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_cfgmap';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
   BEGIN
      RETURN pac_md_listvalores.f_opencursor
                           ('select ccfgmap codigo, tcfgmap valor from cfg_cod_cfgmap_det'
                            || ' where cidioma =' || pac_md_common.f_get_cxtidioma
                            || ' and cempres =' || pac_md_common.f_get_cxtempresa,
                            mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_cfgmap;

-- FIN BUG 21569 - 07/03/2012 - JMP - Se añade la función

   /***********************************************************************
      F_NEW ROL Crea un nuevo rol
      return: devuelve 0 si todo bien, sino el código del error
    ***********************************************************************/
   FUNCTION f_new_rol(
      pcrol IN VARCHAR2,
      ptrol IN VARCHAR2,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcwizard IN VARCHAR2,
      pcform IN VARCHAR2,
      pcaccion IN VARCHAR2,
      pcmenu IN VARCHAR2,
      pcconsupl IN VARCHAR2,
      pcdocumentacio IN VARCHAR2,
      pcaccprod IN VARCHAR2,
      pcmap IN VARCHAR2,
      pcusuagru IN VARCHAR2,
      pcilimite IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_new_rol';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
   BEGIN
      vnumerr := pac_cfg.f_new_rol(pcrol, ptrol, pcidioma, pcempres, pcwizard, pcform,
                                   pcaccion, pcmenu, pcconsupl, pcdocumentacio, pcaccprod,
                                   pcmap, pcusuagru, pcilimite);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9904296);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_new_rol;

   /***********************************************************************
     F_SET_ROL Updatea un rol
     return: devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_set_rol(
      pcrol IN VARCHAR2,
      ptrol IN VARCHAR2,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcwizard IN VARCHAR2,
      pcform IN VARCHAR2,
      pcaccion IN VARCHAR2,
      pcmenu IN VARCHAR2,
      pcconsupl IN VARCHAR2,
      pcdocumentacio IN VARCHAR2,
      pcaccprod IN VARCHAR2,
      pcmap IN VARCHAR2,
      pcusuagru IN VARCHAR2,
      pcilimite IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_set_rol';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
   BEGIN
      vnumerr := pac_cfg.f_set_rol(pcrol, ptrol, pcidioma, pcempres, pcwizard, pcform,
                                   pcaccion, pcmenu, pcconsupl, pcdocumentacio, pcaccprod,
                                   pcmap, pcusuagru, pcilimite);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --Updateamos las cfg's de los usuarios con este rol
      FOR i IN (SELECT cuser
                  FROM cfg_user
                 WHERE cempres = pcempres
                   AND crol = pcrol) LOOP
         vnumerr := f_set_cfg_userrol(i.cuser, pcempres, pcrol, mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9904297);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_rol;

   /***********************************************************************
  f_get_roles
  return:
***********************************************************************/
   FUNCTION f_get_roles(pcrol IN VARCHAR2, ptrol IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_roles';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(500);
      vcur           sys_refcursor;
   BEGIN
      vsquery := pac_cfg.f_get_roles(pcrol, ptrol);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904148);
         RAISE e_object_error;
      END IF;

      vcur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_roles;

   /***********************************************************************
  f_get_rol
  return:
***********************************************************************/
   FUNCTION f_get_rol(
      pcrol IN VARCHAR2,
      pcempres IN NUMBER,
      ptrol OUT VARCHAR2,
      pcwizard OUT VARCHAR2,
      pcform OUT VARCHAR2,
      pcaccion OUT VARCHAR2,
      pcmenu OUT VARCHAR2,
      pcconsupl OUT VARCHAR2,
      pcdocumentacio OUT VARCHAR2,
      pcaccprod OUT VARCHAR2,
      pcmap OUT VARCHAR2,
      pcusuagru OUT VARCHAR2,
      pcilimite OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_rol';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_cfg.f_get_rol(pcrol, pcempres, ptrol, pcwizard, pcform, pcaccion, pcmenu,
                                   pcconsupl, pcdocumentacio, pcaccprod, pcmap, pcusuagru,
                                   pcilimite);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_rol;
END pac_md_cfg;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG" TO "PROGRAMADORESCSI";
