CREATE OR REPLACE PACKAGE BODY "PAC_AVISOS"
AS
   /******************************************************************************
    NOMBRE:      pac_avisos
    PROP¿SITO:   Package de avisos

    REVISIONES:
    Ver        Fecha        Autor             Descripci¿n
    ---------  ----------  ---------------  ------------------------------------
    1.0        --/--/----   ---                1. Creaci¿n del package.
    2.0        19/10/2011   RSC                2. 0019412: LCOL_T004: Completar parametrizaci¿n de los productos de Vida Individual
    3.0        10/04/2011   ETM                3.0019412: LCOL_T004: Completar parametrizaci¿n de los productos de Vida Individual
    4.0        22/11/2011   RSC                4.0020241: LCOL_T004-Parametrizaci¿n de Rescates (retiros)
    5.0        26/06/2012   DRA                5.0021927: MDP - TEC - Parametrizaci¿n producto de Hogar (MHG) - Nueva producci¿n
    6.0        28/06/2012   FAL                6.0021905: MDP - TEC - Parametrizaci¿n de productos del ramo de Accidentes - Nueva producci¿n
    7.0        04/10/2012   MDS                7.0023822: MDP_S001-SIN - Aviso de referencia externa (Id=23696)
    8.0        26/09/2012   JGR                8.0022346: LCOL_A003-Cobro parcial de los recibos Fase 2
    9.0        17/10/2012   MDS                9.0024091: MDP_S001-SIN - Aviso referencia externa repetida - Alta siniestro
    10.0       27/12/2012   ECP               10.0024972: LCOL_T001-QT -5184: No permiti? hacer una anulaci?n inmediata teniendo recibos pendientes desde la fecha del primer recibo pendi  LCOL_T001-QT -5184: No permiti? hacer una anulaci?n inmediata teniendo recibos pendientes desde la fecha del primer recibo pendiente
    11.0       14/01/2013   MDS               11.0025684: MDP_S001-SIN - Referencia externa y presiniestros (Id=24967)
    12.0       23/01/2013   ETM               12.0024745: (POSPG600)-Parametrizacion-Tecnico-Baja de un amparo afectado por un siniestro (PAC_AVISOS)
    13.0       02/07/2013   DCT               13.0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
    14.0       09/09/2013   DCT               14.0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
    15.0       24/07/2013   APD               14.0027539/149064: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
    16.0       13/01/2015   YDA               16.0039787: Se modifica la funci¿n f_valida_bene_accepted para que valide el campo pctipben
    17.0       23/08/2019   JLTS              17.IAXIS-5100: Se adiciona la función f_valida_rango_dian_rc_rd
   ******************************************************************************/
   FUNCTION f_oficinagestion(psseguro IN NUMBER)
      RETURN NUMBER
   IS
      --Devuelve 0 si la oficina de gesti¿n no coincide con la del seguro
      --Devuelve 1 si la oficina de gesti¿n coincide con la del seguro
      vagentseguro    NUMBER;
      vagentgestion   NUMBER;
      vgestion        NUMBER;
   BEGIN
      SELECT cagente
        INTO vagentseguro
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT cagente
        INTO vagentgestion
        FROM usuarios u, agentes a
       WHERE a.cagente = u.cdelega AND u.cusuari = f_user;

      IF vagentseguro = vagentgestion
      THEN
         vgestion := 1;
      ELSE
         vgestion := 0;
      END IF;

      RETURN vgestion;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 111715;               --Error en la definici¿n de la consulta
   END f_oficinagestion;

   FUNCTION f_benefirrevocable(
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcpregun   IN   NUMBER,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      --Devuelve 0 no tiene beneficiario irrevocable
      --Devuelve 1 tiene beneficiario irrevocable
      vbenef        NUMBER;
      vmovimiento   NUMBER;
   BEGIN
      IF NVL (pnmovimi, 0) = 0
      THEN
         SELECT MAX (nmovimi)
           INTO vmovimiento
           FROM pregunseg
          WHERE sseguro = psseguro AND nriesgo = pnriesgo;
      ELSE
         vmovimiento := pnmovimi;
      END IF;

      SELECT crespue
        INTO vbenef
        FROM pregunseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cpregun = pcpregun
         AND nmovimi = vmovimiento;

      RETURN vbenef;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 111715;
   END f_benefirrevocable;

--   MSR 2007/06/01   Ref 1880. Modificar funci¿ F_ACCION per incloure cmotmov=306 com motiu d'anul¿laci¿
   FUNCTION f_accion(
      pscorreo    IN   NUMBER,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pcidioma    IN   NUMBER,
      paccion     IN   VARCHAR2,
      pcmotmov    IN   NUMBER,
      pcpregun    IN   NUMBER,
      pcoficina   IN   VARCHAR2,
      pcterm      IN   VARCHAR2,
      pnmovimi    IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err         NUMBER          := 0;
      verror          VARCHAR2 (1000);
      vmail           VARCHAR2 (4000);              -- BUG9423:DRA:03-04-2009
      vasunto         VARCHAR2 (250);
      vfrom           VARCHAR2 (200);
      vto             VARCHAR2 (200);
      vto2            VARCHAR2 (200);
      vlog            NUMBER          := 0;
      vusurecep       VARCHAR2 (100);
      v_es_anulacio   BOOLEAN         := FALSE;
   BEGIN
      --   MSR 2007/06/01   Ref 1880
      -- Obtenir si el codi ¿s d'anul¿laci¿
      FOR r IN (SELECT cmovseg
                  FROM codimotmov
                 WHERE cmotmov = pcmotmov)
      LOOP
         v_es_anulacio := (r.cmovseg = 3);
         EXIT;
      END LOOP;

      --Miramos el movimiento
      IF v_es_anulacio
      THEN                                   --Anulaci¿n : 221, 301, 306, ....
         IF f_benefirrevocable (psseguro, pnriesgo, pcpregun, pnmovimi) = 1
         THEN
            --Sea o no sea la oficina de gesti¿n se ha de enviar correo
            --a la oficina de gesti¿n
            num_err :=
               pac_correo.f_mail (pscorreo,
                                  psseguro,
                                  pnriesgo,
                                  pcidioma,
                                  paccion,
                                  vmail,
                                  vasunto,
                                  vfrom,
                                  vto,
                                  vto2,
                                  verror,
                                  NULL,
                                  pcmotmov,
                                  1
                                 );
            vlog := 1;
         ELSE                                  --Si no tiene benef irrevocable
            IF f_oficinagestion (psseguro) = 0
            THEN
               --Y no es la oficina de gesti¿n
               --se envia correo a la oficina de gesti¿n
               num_err :=
                  pac_correo.f_mail (pscorreo,
                                     psseguro,
                                     pnriesgo,
                                     pcidioma,
                                     paccion,
                                     vmail,
                                     vasunto,
                                     vfrom,
                                     vto,
                                     vto2,
                                     verror,
                                     NULL,
                                     pcmotmov,
                                     1
                                    );
               vlog := 1;
            END IF;
         END IF;
      ELSIF pcmotmov IN (820, 281)
      THEN                           -- 820 -> Cambio beneficiario irrevocable
         -- 281 -> Cambio de capitales
         IF f_benefirrevocable (psseguro, pnriesgo, pcpregun, pnmovimi) = 1
         THEN
            --Enviar correo a la oficina de gesti¿n
            num_err :=
               pac_correo.f_mail (pscorreo,
                                  psseguro,
                                  pnriesgo,
                                  pcidioma,
                                  paccion,
                                  vmail,
                                  vasunto,
                                  vfrom,
                                  vto,
                                  vto2,
                                  verror,
                                  NULL,
                                  pcmotmov,
                                  1
                                 );
            vlog := 1;
         END IF;
      ELSIF pcmotmov = 225
      THEN                                      --Cambio de oficina de gesti¿n
         IF f_oficinagestion (psseguro) = 0
         THEN
            --Enviar correo a la oficina de gesti¿n
            num_err :=
               pac_correo.f_mail (pscorreo,
                                  psseguro,
                                  pnriesgo,
                                  pcidioma,
                                  paccion,
                                  vmail,
                                  vasunto,
                                  vfrom,
                                  vto,
                                  vto2,
                                  verror,
                                  NULL,
                                  pcmotmov,
                                  1
                                 );
            vlog := 1;
         END IF;
      END IF;

      IF vlog = 1
      THEN
         IF (num_err <> 0) AND (verror IS NULL)
         THEN
            verror := f_axis_literales (num_err, 2);
         END IF;

         BEGIN
            --Inserci¿n en la tabla de LOG, aunque haya
            --habido error al enviar el correo
            INSERT INTO log_correo
                        (seqlogcorreo, fevento, cmailrecep, asunto,
                         error, coficina, cterm, cusuenvio
                        )
                 VALUES (seqlogcorreo.NEXTVAL, f_sysdate, vto, vasunto,
                         verror, pcoficina, pcterm, f_user
                        );
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 103869;                 --Error al insertar en la tabla
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_avisos.f_accion',
                         'pscorreo:'
                      || pscorreo
                      || ' psseguro:'
                      || psseguro
                      || ' pnriesgo:'
                      || pnriesgo
                      || ' pcidioma:'
                      || pcidioma
                      || ' paccion:'
                      || paccion
                      || ' pcmotmov:'
                      || pcmotmov
                      || ' pcpregun:'
                      || pcpregun
                      || ' pcoficina:'
                      || pcoficina
                      || ' pcterm:'
                      || pcterm
                      || ' pnmovimi:'
                      || pnmovimi,
                      1,
                      SQLERRM
                     );
         -- Per versi¿ 10 es pot posar aix¿
         -- p_tab_error (f_sysdate,    F_USER,   'pac_avisos.f_accion',   1,  ,SUBSTR(DBMS_UTILITY.FORMAT_ERROR_STACK||CHR(10)|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,2500));
         RETURN 140999;
   END f_accion;

   PROCEDURE p_preanulacion_solicitudes(
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pfecha     IN       DATE,
      psproces   OUT      NUMBER
   )
   IS
/** **********************************************************************************************************************************
    5-4-2006. YIL. Proceso que env¿a una mail de aviso a las oficinas de gesti¿n de las solicitudes con una
   antig¿edad de 2 meses, es decir, que les falta un mes para su cancelaci¿n
***********************************************************************************************************************************/
      /*CURSOR solicitudes(p_sseguro IN NUMBER, p_sproduc IN NUMBER, p_fcancel IN DATE) IS
         SELECT   s.sseguro, NVL(m.nsuplem, 0) nsuplem, s.npoliza npoliza, s.ncertif ncertif,
                  s.sproduc sproduc, s.nsolici, s.fcancel
             FROM seguros s, movseguro m
            WHERE m.sseguro = s.sseguro
              AND s.sseguro = NVL(p_sseguro, s.sseguro)
              AND s.sproduc = NVL(p_sproduc, s.sproduc)
              AND s.csituac = 4
              AND s.creteni NOT IN(3, 4)
              AND s.fcancel IS NOT NULL
              AND s.fcancel <= ADD_MONTHS(p_fcancel, 1)
              AND NOT EXISTS(SELECT sagenda
                               FROM agensegu
                              WHERE sseguro = s.sseguro
                                AND ctipreg = 30   -- env¿o mail
                                AND csubtip = 20   -- aviso pre anulaci¿n solicitud
                                AND fagenda >
                                      ADD_MONTHS
                                              (fcancel,
                                               -(NVL(f_parproductos_v(sproduc,
                                                                      'MESES_PROPOST_VALIDA'),
                                                     3))))   -- por si se ha modificado (alargado) la fcancel
         ORDER BY sproduc;
*/
      num_err      NUMBER          := 0;
      verror       VARCHAR2 (1000);
      vmail        VARCHAR2 (4000);                 -- BUG9423:DRA:03-04-2009
      vasunto      VARCHAR2 (250);
      vfrom        VARCHAR2 (200);
      vto          VARCHAR2 (200);
      vto2         VARCHAR2 (200);
      vlog         NUMBER          := 0;
      vusurecep    VARCHAR2 (100);
      empresa      NUMBER;
      error        NUMBER;
      v_nprolin    NUMBER;
      cont_malos   NUMBER          := 0;
      err          NUMBER;
      texto        VARCHAR2 (100);
      perror       VARCHAR2 (1000);
   BEGIN
      /*
      reservamos el numero de proceso para la anulacion
      */
      BEGIN
         SELECT cempres
           INTO empresa
           FROM usuarios
          WHERE cusuari = f_user;
      END;

      error :=
         f_procesini (f_user,
                      empresa,
                      'pac_avisos',
                      'Pre-aviso cancelaci¿n solicitudes',
                      psproces
                     );
/*      FOR aux IN solicitudes(psseguro, psproduc, pfecha) LOOP
         num_err := pac_correo.f_mail(20, aux.sseguro, 1, 2, 'REAL', vmail, vasunto, vfrom,
                                      vto, vto2, verror, NULL, NULL, 1);

         IF (num_err <> 0)
            AND(verror IS NULL) THEN
            verror := f_axis_literales(num_err, 2);
         END IF;

         IF verror = 0 THEN
            COMMIT;
            error := f_proceslin(psproces, 'Mail enviado:  ' || aux.nsolici, num_err,
                                 v_nprolin, 4);   -- Correcto
         ELSE
            ROLLBACK;
            error := f_proceslin(psproces, 'Mail err¿neo ' || aux.nsolici, aux.sseguro,
                                 v_nprolin, 1);   -- error
            cont_malos := cont_malos + 1;
         END IF;

         BEGIN
            --Inserci¿n en la tabla de LOG, aunque haya
            --habido error al enviar el correo
            INSERT INTO log_correo
                        (seqlogcorreo, fevento, cmailrecep, asunto, error, coficina,
                         cterm, cusuenvio)
                 VALUES (seqlogcorreo.NEXTVAL, f_sysdate, vto, vasunto, verror, 'DPTO',
                         'DPTO', f_user);
         EXCEPTION
            WHEN OTHERS THEN
               err := 103869;   --Error al insertar en la tabla
               perror := SQLERRM;
               p_tab_error(f_sysdate, f_user, 'correo', NULL, '{INVALID MAL222}', SQLERRM);
         END;

         IF err IS NULL THEN
            COMMIT;
         ELSE
            ROLLBACK;
            texto := f_axis_literales(err, 1);
            error := f_proceslin(psproces,
                                 'Error log_correo' || texto || 'sol. ' || aux.nsolici, err,
                                 v_nprolin, 1);   -- Error
            cont_malos := cont_malos + 1;
         END IF;
      END LOOP;
*/
      error := f_procesfin (psproces, cont_malos);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_avisos.p_preanulacion_solicitudes',
                      NULL,
                      'error al enviar mail',
                      SQLERRM
                     );
   END p_preanulacion_solicitudes;

   /*************************************************************************
        Devuelve la lista de los avisos a ejecutar
        param in pcempres     : Empresa
        param in pcform     : Formulario
        param in pcmodo     : Modo
        param in pccfgavis     : Perfil del usuario para ver los avisos
        param in pcramo     : ramo
        param in psproduc     : producto
        param in pcidioma     : idioma
        param out pquery  : Query con los avisos
        return                : 0/1 OK/KO
     *************************************************************************/
   FUNCTION f_get_avisos(
      pcempres     IN       NUMBER,
      pcform       IN       VARCHAR2,
      pcmodo       IN       VARCHAR2,
      pccfgavis    IN       VARCHAR2,
      pcramo       IN       NUMBER,
      psproduc     IN       NUMBER,
      pcidioma     IN       NUMBER,
      pcmsgwinfo   IN       VARCHAR2,
      psquery      OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos.f_get_aviso';
      vparam        VARCHAR2 (1000)
         :=    'par¿metros - pcempres :'
            || pcempres
            || ',pcform :'
            || pcform
            || ',pcmodo :'
            || pcmodo
            || ',pcidioma :'
            || pcidioma
            || ',pccfgavis :'
            || pccfgavis
            || ',pcramo :'
            || pcramo
            || ',psproduc :'
            || psproduc;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vcconobs      NUMBER;
      vcform        VARCHAR2 (50);
      vcramo        NUMBER;
      vsproduc      NUMBER;
      vcmodo        VARCHAR2 (50);
      vquants       NUMBER;
   BEGIN
      IF pccfgavis IS NULL OR pcempres IS NULL
      THEN
         RETURN 9901934;                                  --faltan parametres
      END IF;

      IF pcmodo IS NULL
      THEN            --Si el mode no ve informat, obtenim el mode per defecte
         SELECT c.cmodo
           INTO vcmodo
           FROM cfg_cod_modo c
          WHERE c.cdefecto = 1;
      ELSE
         vcmodo := pcmodo;
      END IF;

      vcform := pcform;

      IF pcform IS NULL
      THEN
         vcform := 'GENERAL';
      END IF;

      vsproduc := NVL (psproduc, 0);
      vcramo := NVL (pcramo, 0);

      IF psproduc IS NOT NULL AND psproduc != 0
      THEN
         SELECT cramo
           INTO vcramo
           FROM productos
          WHERE sproduc = psproduc;
      END IF;

      SELECT COUNT (1)
        INTO vquants
        FROM cfg_avisos ca, cfg_rel_avisos cra
       WHERE ca.cform = UPPER (pcform)
         AND ca.cmodo = vcmodo
         AND ca.ccfgavis = pccfgavis
         AND ca.cramo = vcramo
         AND ca.sproduc = vsproduc
         AND ca.cempres = pcempres
         AND ca.cempres = cra.cempres
         AND ca.cidrel = cra.cidrel;

      IF psproduc IS NULL OR vquants = 0
      THEN
         --Si el producte no ve informat, o no t¿ configuraci¿ espec¿fica, recuperem la parametritzaci¿ independent de producte.
         vsproduc := 0;

         IF vcramo IS NOT NULL
         THEN
            SELECT COUNT (1)
              INTO vquants
              FROM cfg_avisos ca, cfg_rel_avisos cra
             WHERE ca.cform = UPPER (pcform)
               AND ca.cmodo = vcmodo
               AND ca.ccfgavis = pccfgavis
               AND ca.cramo = vcramo
               AND ca.sproduc = vsproduc
               AND ca.cempres = pcempres
               AND ca.cempres = cra.cempres
               AND ca.cidrel = cra.cidrel;

            IF vquants = 0
            THEN
               vcramo := 0;
            END IF;
         ELSE
            vcramo := 0;
         END IF;
      END IF;

      psquery :=
            '  SELECT av.CAVISO,f_axis_literales(av.slitera,'
         || pcidioma
         || ') taviso,av.ctipaviso, FF_DESVALORFIJO(800033,'
         || pcidioma
         || ',av.ctipaviso)'
         || 'ttipaviso,tfunc,cra.cbloqueo '
         || 'FROM cfg_avisos ca, cfg_rel_avisos cra, avisos av '
         || 'WHERE ca.cform = UPPER('''
         || pcform
         || ''') '
         || ' AND ca.cmodo = '''
         || vcmodo
         || ''' AND ca.ccfgavis = '''
         || pccfgavis
         || ''' AND ca.cramo = '
         || vcramo
         || ' AND ca.sproduc = '
         || vsproduc
         || ' AND ca.cempres = '
         || pcempres
         || ' AND ca.cempres = cra.cempres '
         || ' AND ca.cidrel = cra.cidrel '
         || ' AND cRA.cempres = Av.cempres '
         || ' AND CRA.caviso = av.caviso '
         || ' AND av.cactivo = 1 ';

      --
      IF pcmsgwinfo IS NOT NULL
      THEN
         --
         psquery := psquery || ' AND CRA.cbloqueo = 1 ';
      --
      END IF;

      --
      psquery := psquery || ' order by cra.norden asc, av.caviso asc';
      --
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 108520;
   END f_get_avisos;

/*
   Cl¿usulas especiales (segundas hojas): Cuando una p¿liza tenga cl¿usulas especiales
que afectan a la cobertura (el aviso se mostrar¿ siempre que la p¿liza tenga cl¿usulas de este tipo)
deber¿ mostrarse aviso de su existencia para que el tramitador pueda consultar dichas cl¿usulas
RETURN 0(ok),1(error)
*/
   FUNCTION f_aviso_clausuesp(
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pnriesgo    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos.f_aviso_clausuesp';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vnriesgo      NUMBER;
   BEGIN
      vnriesgo := NVL (pnriesgo, 1);

      IF pnriesgo IS NULL AND pnsinies IS NOT NULL
      THEN
         SELECT nriesgo
           INTO vnriesgo
           FROM sin_siniestro
          WHERE nsinies = pnsinies;
      END IF;

      IF psseguro IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vquants
           FROM clausuesp
          WHERE sseguro = psseguro AND nriesgo = vnriesgo;

         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9002180, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_clausuesp;

      /*
      P¿liza anulada al efecto [SIN-294]: Cuando se da un parte para una p¿liza vigente
         y posteriormente esta p¿liza se anula a fecha efecto, el sistema deber¿ generar un
         aviso al tramitador global conforme se ha anulado la p¿liza con fecha anterior a la
          fecha del siniestro y deber¿ quedar registrado en la cabecera de avisos. (aviso de p¿liza)
   RETURN 0(ok),1(error)
   */
   FUNCTION f_aviso_polanulefecto(
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos.f_aviso_polanulefecto';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vnriesgo      NUMBER;
      vfefecto      DATE;
   BEGIN
      IF psseguro IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vquants
           FROM seguros
          WHERE sseguro = psseguro AND csituac = 2;

         IF vquants > 0
         THEN
            SELECT s.fefecto
              INTO vfefecto
              FROM movseguro ms, seguros s
             WHERE s.sseguro = psseguro
               AND ms.nmovimi = (SELECT MAX (mm.nmovimi)
                                   FROM movseguro mm
                                  WHERE mm.sseguro = psseguro)
               AND cmotmov = 306
               AND ms.sseguro = s.sseguro;

            SELECT COUNT (1)
              INTO vquants
              FROM sin_siniestro
             WHERE nsinies = pnsinies AND fsinies <= vfefecto;
         END IF;

         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902106, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_polanulefecto;

   /*
    Mostrar un aviso de si hay +/- N d¿as entre la fecha ocurrencia del
    siniestro y la fecha efecto de p¿liza (siniestros prematuros).
    RETURN 0(ok),1(error)
    */
   FUNCTION f_aviso_carencia(
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pndias      IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos.f_aviso_carencia';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vok           NUMBER;
      vfefecto      DATE;
      vfsinies      DATE;
      vndias        NUMBER          := 7;
   BEGIN
      IF psseguro IS NOT NULL AND pnsinies IS NOT NULL
      THEN
         IF pndias IS NOT NULL
         THEN
            vndias := pndias;
         END IF;

         SELECT fefecto
           INTO vfefecto
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT fsinies
           INTO vfsinies
           FROM sin_siniestro
          WHERE nsinies = pnsinies;

         SELECT COUNT (1)
           INTO vok
           FROM DUAL
          WHERE vfefecto BETWEEN vfsinies - vndias AND vfsinies + vndias;

         IF vok > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902108, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_carencia;

   /*
      Ocurrencia anterior a fecha de grabaci¿n de p¿liza.(aviso de p¿liza)
      RETURN 0(ok),1(error)
      */
   FUNCTION f_aviso_sini_ant_a_emision(
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500) := 'PAC_avisos.f_aviso_sini_ant_a_emision';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vfemisio      DATE;
      vfsinies      DATE;
   BEGIN
      IF psseguro IS NOT NULL AND pnsinies IS NOT NULL
      THEN
         SELECT femisio
           INTO vfemisio
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT fsinies
           INTO vfsinies
           FROM sin_siniestro
          WHERE nsinies = pnsinies;

         IF vfsinies < vfemisio
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902110, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_sini_ant_a_emision;

   /*
      En la apertura y la consulta de siniestros, el sistema deber¿ informar
      en el apartado de avisos de cabecera que existen aperturas rechazadas
      en los 3 meses anteriores. (aviso de p¿liza)
      RETURN 0(ok),1(error)
      */
   FUNCTION f_aviso_aperturas_rechazadas(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)
                                 := 'PAC_avisos.f_aviso_aperturas_rechazadas';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
   BEGIN
      IF psseguro IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vquants
           FROM seguros s, sin_siniestro ss, sin_movsiniestro sm
          WHERE s.sseguro = ss.sseguro
            AND s.sseguro = psseguro
            AND sm.nsinies = ss.nsinies
            AND sm.festsin BETWEEN ADD_MONTHS (f_sysdate, -3) AND f_sysdate
            AND sm.nmovsin = (SELECT MAX (ssm.nmovsin)
                                FROM sin_movsiniestro ssm
                               WHERE ssm.nsinies = ss.nsinies)
            AND sm.cestsin = 3;

--36000096
         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902111, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_aperturas_rechazadas;

   /*
        Aviso de duplicidad de siniestros por fecha, causa y p¿liza
        RETURN 0(ok),1(error)
        */
   FUNCTION f_aviso_duplicidad_sini(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos.f_aviso_duplicidad_sini';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vfsinies      DATE;
      vccausin      NUMBER;
      vsseguro      NUMBER;
   BEGIN
      IF pnsinies IS NOT NULL
      THEN
         SELECT fsinies, ccausin, sseguro
           INTO vfsinies, vccausin, vsseguro
           FROM sin_siniestro ss
          WHERE nsinies = pnsinies;

         SELECT COUNT (1)
           INTO vquants
           FROM sin_siniestro ss, sin_movsiniestro sm
          WHERE ss.sseguro = vsseguro
            AND ss.ccausin = vccausin
            AND TRUNC (fsinies) = vfsinies   --BUG 30935/172357:NSS:10/04/2014
            AND ss.nsinies <> pnsinies
            AND sm.nsinies = ss.nsinies
            AND sm.nmovsin = (SELECT MAX (ssm.nmovsin)
                                FROM sin_movsiniestro ssm
                               WHERE ssm.nsinies = ss.nsinies)
            AND sm.cestsin NOT IN (2, 3);    --BUG 30935/172357:NSS:10/04/2014

         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902112, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_duplicidad_sini;

   /*
        Se mostrar¿ un aviso cuando la p¿liza es coasegurada (Aviso de p¿liza)
        RETURN 0(ok),1(error)
        */
   FUNCTION f_aviso_pol_es_coasegurada(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500) := 'PAC_avisos.f_aviso_pol_es_coasegurada';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vfsinies      DATE;
      vccausin      NUMBER;
      vsseguro      NUMBER;
   BEGIN
      IF psseguro IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vquants
           FROM seguros
          WHERE sseguro = psseguro AND ctipcoa <> 0;

         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902113, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_pol_es_coasegurada;

   /*
       Siniestro anterior rehabilitaci¿n de p¿liza (aviso de p¿liza)
       RETURN 0(ok),1(error)
       */
   FUNCTION f_aviso_pol_rehabilitacion(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500) := 'PAC_avisos.f_aviso_pol_rehabilitacion';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vsproduc      NUMBER;
      vfmovimi      DATE;
      vfsinies      DATE;
      psseguro      NUMBER;
   BEGIN
      IF pnsinies IS NOT NULL
      THEN
         SELECT fsinies, sseguro
           INTO vfsinies, psseguro
           FROM sin_siniestro
          WHERE nsinies = pnsinies;

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT fmovimi
              INTO vfmovimi
              FROM movseguro
             WHERE sseguro = psseguro
               AND cmotmov IN (
                      SELECT cmotmov
                        FROM motmovseg
                       WHERE cidioma = pcidioma
                         AND cmotmov IN (
                                SELECT cmotmov
                                  FROM codimotmov
                                 WHERE cactivo = 1
                                   AND cgesmov = 0
                                   AND cmovseg = 4)
                         AND cmotmov IN (SELECT cmotmov
                                           FROM prodmotmov
                                          WHERE sproduc = vsproduc))
               AND nmovimi =
                      (SELECT MAX (mm.nmovimi)
                         FROM movseguro mm
                        WHERE mm.sseguro = psseguro
                          AND cmotmov IN (
                                 SELECT cmotmov
                                   FROM motmovseg
                                  WHERE cidioma = pcidioma
                                    AND cmotmov IN (
                                           SELECT cmotmov
                                             FROM codimotmov
                                            WHERE cactivo = 1
                                              AND cgesmov = 0
                                              AND cmovseg = 4)
                                    AND cmotmov IN (SELECT cmotmov
                                                      FROM prodmotmov
                                                     WHERE sproduc = vsproduc)));
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vfmovimi := NULL;
         END;

         IF vfmovimi IS NOT NULL AND vfsinies < vfmovimi
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902117, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_pol_rehabilitacion;

/*
        Prima pendiente para el periodo
        RETURN 0(ok),1(error)
        */
   FUNCTION f_aviso_prima_pendiente(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos.f_aviso_prima_pendiente';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vfsinies      DATE;
      vccausin      NUMBER;
      vsseguro      NUMBER;
   BEGIN
      IF pnsinies IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vquants
           FROM sin_siniestro ss, recibos r, vdetrecibos v, movrecibo mr
          WHERE ss.nsinies = pnsinies
            AND ss.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.nrecibo = mr.nrecibo
            AND mr.fmovfin IS NULL
            AND mr.fmovini <= ss.fsinies
            AND mr.cestrec = 0;

         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902120, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_prima_pendiente;

   /*
   Recibo fraccionado
   RETURN 0(ok),1(error)
   */
   FUNCTION f_aviso_recibos_fraccionado(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)
                                  := 'PAC_avisos.f_aviso_recibos_fraccionado';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vfsinies      DATE;
      vccausin      NUMBER;
      vsseguro      NUMBER;
   BEGIN
      IF psseguro IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vquants
           FROM seguros
          WHERE sseguro = psseguro AND cforpag NOT IN (0, 1);

         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902121, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_recibos_fraccionado;

   /*
   se intente dar de baja un amparo afectado por un siniestro a una fecha posterior
   a la ocurrencia del siniestro, pero dentro de la misma anualidad, el sistema deber¿
   permitir tramitar la baja, sin embargo, generar¿ un aviso a siniestros
   RETURN 0(ok),1(error)
   */
   FUNCTION f_aviso_garantia_baja(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos.f_aviso_garantia_baja';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vfsinies      DATE;
      vccausin      NUMBER;
   BEGIN
      IF pnsinies IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vquants
           FROM sin_tramita_reserva str, sin_siniestro ss
          WHERE cgarant IS NOT NULL
            AND str.nsinies = pnsinies
            AND str.nsinies = ss.nsinies
            AND str.cgarant NOT IN (
                   SELECT g.cgarant
                     FROM garanseg g
                    WHERE g.sseguro = ss.sseguro
                      AND nmovimi = (SELECT MAX (nmovimi)
                                       FROM garanseg
                                      WHERE sseguro = ss.sseguro));

         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9902123, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_garantia_baja;

   /*************************************************************************
        FUNCTION f_aviso_asegurado
        Funci¿n que desde la alta de tomador, genera aviso si se cumplen unas condiciones
        pcidioma  in number: codigo idioma
        ptmensaje out: Texto de error
        RETURN 0(ok),1(error),2(warning)

   *************************************************************************/
   -- Bug 19412/95066 - RSC - 19/10/2011
   FUNCTION f_aviso_asegurado(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (500)
                             := 'pac_listarestringida_lcol.f_aviso_asegurado';
      vparam           VARCHAR2 (1000)                 := ' id=' || pcidioma;
      vpasexec         NUMBER (5)                      := 1;
      vnumerr          NUMBER (8)                      := 0;
      n_registro       NUMBER;
      v_retorno        NUMBER (8)                      := 0;
      -- datos asgurado necesarios
      v_ase_sperson    per_personas.sperson%TYPE;
      v_ase_pais       per_detper.cpais%TYPE;
      v_ase_nacional   per_nacionalidades.cpais%TYPE;
   BEGIN
      vpasexec := 100;
      v_retorno := 0;
      n_registro := 0;

      LOOP
         vpasexec := 120;
         n_registro := n_registro + 1;
         vpasexec := 130;
         vnumerr :=
            pac_call.f_get_persona_asegurado (n_registro,
                                              v_ase_sperson,
                                              v_ase_pais,
                                              v_ase_nacional
                                             );
         EXIT WHEN v_ase_sperson IS NULL;
         vpasexec := 140;

         IF v_ase_pais IS NULL OR v_ase_nacional = 0
         THEN
            IF v_ase_pais IS NULL
            THEN
               ptmensaje := f_axis_literales (9902509, pcidioma);
               RETURN 1;
            ELSE
               ptmensaje := f_axis_literales (9902507, pcidioma);
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_asegurado;

   FUNCTION f_aviso_tomador(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (500)
                               := 'pac_listarestringida_lcol.f_aviso_tomador';
      vparam           VARCHAR2 (1000)                 := ' id=' || pcidioma;
      vpasexec         NUMBER (5)                      := 1;
      vnumerr          NUMBER (8)                      := 0;
      n_registro       NUMBER;
      v_retorno        NUMBER (8)                      := 0;
      -- datos asgurado necesarios
      v_tom_sperson    per_personas.sperson%TYPE;
      v_tom_pais       per_detper.cpais%TYPE;
      v_tom_nacional   per_nacionalidades.cpais%TYPE;
      v_ptmensaje      VARCHAR2 (300);
      v_num_err        NUMBER;
      v_ase_sperson    per_personas.sperson%TYPE;
      v_ase_pais       per_detper.cpais%TYPE;
      v_ase_nacional   per_nacionalidades.cpais%TYPE;
   BEGIN
      vpasexec := 100;
      v_retorno := 0;
      n_registro := 0;

      LOOP
         vpasexec := 120;
         n_registro := n_registro + 1;
         vpasexec := 130;
         vnumerr :=
            pac_call.f_get_persona_tomador (n_registro,
                                            v_tom_sperson,
                                            v_tom_pais,
                                            v_tom_nacional
                                           );
         EXIT WHEN v_tom_sperson IS NULL;
         vpasexec := 140;

         IF v_tom_pais IS NULL
         THEN
            ptmensaje := f_axis_literales (9902510, pcidioma);
            RETURN 1;
         END IF;

         v_num_err :=
            pac_call.f_get_persona_asegurado (n_registro,
                                              v_ase_sperson,
                                              v_ase_pais,
                                              v_ase_nacional
                                             );

         IF v_ase_sperson = v_tom_sperson
         THEN
            vnumerr := pac_avisos.f_aviso_asegurado (pcidioma, v_ptmensaje);

            IF vnumerr > 0
            THEN
               ptmensaje := v_ptmensaje;
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_tomador;

-- Bug 19412/95066
   FUNCTION f_aviso_fvencim_fraccionado(
      pcforpag    IN       NUMBER,
      pcduraci    IN       NUMBER,
      pfefecto    IN       DATE,
      pfvencim    IN       DATE,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                                  := 'pac_avisos.f_aviso_fvencim_fraccionado';
      vparam        VARCHAR2 (1000)
                    := ' pcforpag=' || pcforpag || ' pcduraci = ' || pcduraci;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      n_registro    NUMBER;
      v_retorno     NUMBER (8)      := 0;
      v_meses       NUMBER;
   BEGIN
      vpasexec := 100;
      v_retorno := 0;
      n_registro := 0;

      IF pcduraci = 3 AND pcforpag <> 0
      THEN
         ptmensaje := f_axis_literales (180419, pcidioma);
         vnumerr := 1;
      END IF;

      IF pcduraci = 0 AND pcforpag = 0
      THEN
         ptmensaje := f_axis_literales (180422, pcidioma);
         vnumerr := 1;
      END IF;

      IF pcduraci = 3 AND pcforpag = 0
      THEN
         IF pfvencim IS NOT NULL
         THEN
            SELECT MONTHS_BETWEEN (pfvencim, pfefecto)
              INTO v_meses
              FROM DUAL;

            IF v_meses > 12
            THEN
               ptmensaje := f_axis_literales (9902572, pcidioma);
               vnumerr := 1;
            END IF;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_fvencim_fraccionado;

   FUNCTION f_aviso_ndurcob(
      pndurcob    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)         := 'pac_avisos.f_aviso_ndurcob';
      vparam        VARCHAR2 (1000)        := ' pndurcob = ' || pndurcob;
      vpasexec      NUMBER (5)             := 1;
      vnumerr       NUMBER (8)             := 0;
      n_registro    NUMBER;
      v_retorno     NUMBER (8)             := 0;
      v_cramo       seguros.cramo%TYPE;
      v_cmodali     seguros.cmodali%TYPE;
      v_ctipseg     seguros.ctipseg%TYPE;
      v_ccolect     seguros.ccolect%TYPE;
      v_dummy       NUMBER;
   BEGIN
      vpasexec := 100;
      v_retorno := 0;
      n_registro := 0;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
        FROM productos
       WHERE sproduc = pac_iax_produccion.poliza.det_poliza.sproduc;

      BEGIN
         SELECT 1
           INTO v_dummy
           FROM durcobroprod
          WHERE cramo = v_cramo
            AND cmodali = v_cmodali
            AND ctipseg = v_ctipseg
            AND ccolect = v_ccolect
            AND ndurcob = pndurcob;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ptmensaje := f_axis_literales (9902620, pcidioma);
            vnumerr := 1;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_ndurcob;

   /*************************************************************************
        FUNCTION f_aviso_ndurcob_lim
        Funci¿n de pagos limitados 70 a¿os y 80 a¿os: si NDURCOB = 1 la revalorizaci¿n no puede ser 10
        pndurcob in number
        pprevali in number
        pcidioma  in number: codigo idioma
        ptmensaje out: Texto de error
        RETURN 0(ok),RETURN 1(ko)

   *************************************************************************/
   -- Bug 19412/97521 - ETM - 10/11/2011
   FUNCTION f_aviso_ndurcob_lim(
      pprevali    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)        := 'pac_avisos.f_aviso_ndurcob_lim';
      vparam        VARCHAR2 (1000)        := ' prevali = ' || pprevali;
      vpasexec      NUMBER (5)             := 1;
      vnumerr       NUMBER (8)             := 0;
      n_registro    NUMBER;
      v_retorno     NUMBER (8)             := 0;
      v_cramo       seguros.cramo%TYPE;
      v_cmodali     seguros.cmodali%TYPE;
      v_ctipseg     seguros.ctipseg%TYPE;
      v_ccolect     seguros.ccolect%TYPE;
      v_dummy       NUMBER;
      v_ndurcob     seguros.ndurcob%TYPE;
   BEGIN
      vpasexec := 100;
      v_retorno := 0;
      n_registro := 0;

      IF NVL (pprevali, 0) IS NOT NULL
      THEN
         BEGIN
            SELECT ndurcob
              INTO v_ndurcob
              FROM estseguros
             WHERE sseguro = pac_iax_produccion.poliza.det_poliza.sseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_ndurcob := 0;
         END;

         IF NVL (pprevali, 0) = 10 AND v_ndurcob = 1
         THEN
            ptmensaje := f_axis_literales (9902657, pcidioma);
            vnumerr := 1;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_ndurcob_lim;

-- fin Bug 19412/97521 - ETM - 10/11/2011
   FUNCTION f_aviso_rec_pend(
      psseguro    IN       NUMBER,
      pfanulac    IN       DATE,
      pctipanul   IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'pac_avisos_lcol.f_aviso_rec_pend';
      vparam        VARCHAR2 (1000)
         :=    ' psseguro = '
            || psseguro
            || ', pfanulac = '
            || pfanulac
            || ', pctipanul = '
            || pctipanul
            || ', pcidioma = '
            || pcidioma;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      n_registro    NUMBER;
      v_retorno     NUMBER (8)      := 0;
      v_ctipben     NUMBER;
      v_conta_rec   NUMBER;
      vempresa      NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN                                            -- 24273:ASN:24/10/2012
         RETURN 0;
      END IF;

      vpasexec := 100;
      v_retorno := 0;
      n_registro := 0;

      SELECT cempres
        INTO vempresa
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL (pac_parametros.f_parempresa_n (vempresa, 'AVISO_ANUL_EFECTO'),
              0) = 0
      THEN
         IF pctipanul = 4
         THEN
            -- No se permite la anulaci¿n a esa fecha si tiene recibos pendientes anteriores a la fecha de anulaci¿n
            SELECT COUNT (*)
              INTO v_conta_rec
              FROM recibos a
             WHERE sseguro = psseguro
               -- 10. 0024972: LCOL_T001-QT -5184: Se cambia  AND f_cestrec(nrecibo, pfanulac) = 0 por AND f_cestrec(nrecibo, NULL) = 0
               -- debe controlar los recibos pendientes a la fecha en que se pide la anulaci¿n.
               AND f_cestrec (nrecibo, NULL) = 0
               -- 2. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
               -- Hacer el control solo sobre los recibos que NO tengan pagos parciales
               AND pac_adm_cobparcial.f_get_importe_cobro_parcial (a.nrecibo,
                                                                   NULL,
                                                                   NULL
                                                                  ) = 0
               -- 2. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
               AND fefecto < pfanulac;

            IF v_conta_rec > 0
            THEN
               ptmensaje := f_axis_literales (9902742, pcidioma);
               vnumerr := 1;
            END IF;

            --No se permite la anulaci¿n de la p¿liza si tiene recibos 'remesados' (cestrec = 3)
            SELECT COUNT (*)
              INTO v_conta_rec
              FROM recibos a
             WHERE sseguro = psseguro AND f_cestrec (nrecibo, NULL) = 3;

            IF v_conta_rec > 0
            THEN
               ptmensaje := f_axis_literales (9902743, pcidioma);
               vnumerr := 1;
            END IF;
         END IF;
      ELSE
         IF pctipanul = 1
         THEN
            --No se permite la anulaci¿n de la p¿liza si tiene recibos 'remesados' (cestrec = 3)
            SELECT COUNT (*)
              INTO v_conta_rec
              FROM recibos a
             WHERE sseguro = psseguro AND f_cestrec (nrecibo, NULL) = 3;

            IF v_conta_rec > 0
            THEN
               ptmensaje := f_axis_literales (9902743, pcidioma);
               vnumerr := 1;
            END IF;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_rec_pend;

   FUNCTION f_benefobligatori(
      pnriesgo_beneident   IN       NUMBER,
      pcidioma             IN       NUMBER,
      ptmensaje            OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      --Devuelve 0 no tiene beneficiario irrevocable
      --Devuelve 1 tiene beneficiario irrevocable
      vbenef        NUMBER;
      vreturn       NUMBER         := 1;
      vpasexec      NUMBER         := 1;
      vobjectname   VARCHAR2 (500) := 'pac_avisos_lcol.f_benefobligatori';
      vparam        VARCHAR2 (500)
                                 := 'vparam: NRIESGO: ' || pnriesgo_beneident;
   BEGIN
      vreturn := pac_call.f_valida_beneficiario (pnriesgo_beneident, vbenef);

      IF vreturn = 0 AND vbenef > 0
      THEN
         vreturn := 0;
      ELSE
         ptmensaje := f_axis_literales (120082, pcidioma);
         vreturn := 1;
      END IF;

      RETURN vreturn;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_benefobligatori;

   /*************************************************************************
        FUNCTION f_aviso_importe_reserva
        Funci¿n que valida que el importe de la reserva no sea superior a la provisi¿n de la p¿liza
        psseguro in number
        pfechasini in date
        pireserva  in number
        ptmensaje out: Texto de error
        RETURN 0(ok),RETURN 1(ko)

        Bug 20880/103300 - 12/01/2012 - AMC
   *************************************************************************/
   FUNCTION f_aviso_importe_reserva(
      psseguro    IN       NUMBER,
      pfresini    IN       DATE,
      picaprie    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER         := 1;
      vobjectname   VARCHAR2 (500) := 'pac_avisos.f_aviso_importe_reserva';
      vparam        VARCHAR2 (500)
         :=    'vparam: psseguro:'
            || psseguro
            || ' pfresini:'
            || pfresini
            || ' picaprie:'
            || picaprie
            || ' pcidioma:'
            || pcidioma;
      vprovision    NUMBER;
   BEGIN
      vprovision :=
         pac_provmat_formul.f_calcul_formulas_provi (psseguro,
                                                     NVL (pfresini, f_sysdate),
                                                     'IPROVAC'
                                                    );            -- Provisi¿n

      IF picaprie > vprovision
      THEN
         ptmensaje :=
                     f_axis_literales (9903113, pcidioma) || ' '
                     || vprovision;
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_importe_reserva;

   /*************************************************************************
        FUNCTION f_noidentifica_sistema
        Funci¿n que valida que no se selecciona un tomador con ctipide el
        identificador del sistema

        pcidioma in number
        ptmensaje out: Texto de error
        RETURN 0(ok),RETURN 1(ko)
   *************************************************************************/
   FUNCTION f_noidentifica_sistema(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (500)  := 'pac_avisos.f_noidentifica_sistema';
      vparam           VARCHAR2 (1000)             := ' id=' || pcidioma;
      vpasexec         NUMBER (5)                  := 1;
      vnumerr          NUMBER (8)                  := 0;
      v_retorno        NUMBER (8)                  := 0;
      -- datos tomador
      n_registro       NUMBER;
      v_tom_sperson    per_personas.sperson%TYPE;
      v_tom_nnumide    per_personas.nnumide%TYPE;
      v_tom_ctipper    per_personas.ctipper%TYPE;
      v_tom_ctipide    per_personas.ctipide%TYPE;
      v_tom_tapelli1   per_detper.tapelli1%TYPE;
      v_tom_tapelli2   per_detper.tapelli2%TYPE;
      v_tom_tnombre1   per_detper.tnombre1%TYPE;
      v_tom_tnombre2   per_detper.tnombre2%TYPE;
   BEGIN
      n_registro := 0;
      v_retorno := 0;
      vpasexec := 102;

      LOOP
         vpasexec := 120;
         n_registro := n_registro + 1;
         vnumerr :=
            pac_call.f_datos_tomador (n_registro,
                                      v_tom_sperson,
                                      v_tom_ctipper,
                                      v_tom_ctipide,
                                      v_tom_nnumide,
                                      v_tom_tapelli1,
                                      v_tom_tapelli2,
                                      v_tom_tnombre1,
                                      v_tom_tnombre2
                                     );
         EXIT WHEN v_tom_sperson IS NULL;
         vpasexec := 140;

         IF v_tom_ctipide = 0
         THEN
            ptmensaje := f_axis_literales (9903833, pcidioma);
            v_retorno := 1;
         END IF;
      END LOOP;

      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_noidentifica_sistema;

   FUNCTION f_validacion_psu(
      psseguro          IN       NUMBER,
      pnriesgo          IN       NUMBER,
      pnmovimi          IN       NUMBER,
      pcidioma          IN       NUMBER,
      parfix_ccontrol   IN       NUMBER,
      ptmensaje         OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)           := 'PAC_AVISOS.f_validacion_psu';
      vparam        VARCHAR2 (1000)
         :=    ' psseguro='
            || psseguro
            || ' pnriesgo='
            || pnriesgo
            || ' pnmovimi='
            || pnmovimi
            || ' pcidioma='
            || pcidioma
            || ' parfix_ccontrol='
            || parfix_ccontrol;
      vpasexec      NUMBER (5)                      := 1;
      v_ret         NUMBER;
      v_error       NUMBER;
      v_fefecto     estseguros.fefecto%TYPE;
      v_sproduc     estseguros.sproduc%TYPE;
      v_cactivi     estseguros.cactivi%TYPE;
      v_nmovimi     estgaranseg.nmovimi%TYPE;
      v_ccontrol    psu_controlpro.ccontrol%TYPE;
      v_cformula    psu_controlpro.cformula%TYPE;
      v_cgarant     psu_controlpro.cgarant%TYPE;
      v_cnivel      psu_nivel_control.cnivel%TYPE;
      v_cidioma     NUMBER    := NVL (pcidioma, pac_md_common.f_get_cxtidioma);
      v_ctratar     psu_controlpro.ctratar%TYPE;
      v_cobliga     estgaranseg.cobliga%TYPE;
   BEGIN
      vpasexec := 1;
      ptmensaje := NULL;

      SELECT e.fefecto, e.sproduc, e.cactivi
        INTO v_fefecto, v_sproduc, v_cactivi
        FROM estseguros e
       WHERE e.sseguro = psseguro;

      vpasexec := 2;

      IF pnmovimi IS NULL
      THEN
         SELECT MAX (e.nmovimi)
           INTO v_nmovimi
           FROM estgaranseg e
          WHERE e.sseguro = psseguro AND e.nriesgo = pnriesgo;
      ELSE
         v_nmovimi := pnmovimi;
      END IF;

      vpasexec := 3;
      v_ccontrol := parfix_ccontrol;

      SELECT cformula, cgarant, ctratar
        INTO v_cformula, v_cgarant, v_ctratar
        FROM psu_controlpro
       WHERE ccontrol = v_ccontrol AND sproduc = v_sproduc;

      vpasexec := 31;

      IF v_ctratar = 1 AND v_cgarant IS NOT NULL
      THEN
         SELECT cobliga
           INTO v_cobliga
           FROM estgaranseg e
          WHERE e.sseguro = psseguro
            AND e.nriesgo = pnriesgo
            AND e.nmovimi = v_nmovimi
            AND e.cgarant = v_cgarant;
      END IF;

      IF v_cobliga = 1 OR v_ctratar <> 1
      THEN
         vpasexec := 4;
         v_error :=
            pac_psu.f_trata_formulas_psu (psseguro,
                                          v_fefecto,
                                          v_sproduc,
                                          v_cactivi,
                                          pnriesgo,
                                          v_cgarant,
                                          v_ccontrol,
                                          v_cformula,
                                          v_nmovimi,
                                          v_ret
                                         );
         vpasexec := 5;

         IF v_ret IS NOT NULL
         THEN
            vpasexec := 6;

            SELECT cnivel
              INTO v_cnivel
              FROM psu_nivel_control
             WHERE ccontrol = v_ccontrol
               AND sproduc = v_sproduc
               AND v_ret BETWEEN nvalinf AND nvalsup;

            IF     v_cnivel <> 0
               AND pac_psu.f_nivel_usuari_psu (f_user, v_sproduc) < v_cnivel
            THEN
               vpasexec := 7;
               v_ret := 1;

               /* HPM 0023298: MDP - MTS 2001 - Revisi¿n Incidencias, se modifico la select
               para contemplar el nivel de autorizacion 99999*/
               SELECT DECODE (n.cnivel,
                              999999, d.tcontrol || ': ' || r.tdesniv,
                                 d.tcontrol
                              || ': '
                              || r.tdesniv
                              || ', '
                              || f_axis_literales (9903881, v_cidioma)
                              || ' '
                              || n.tnivel
                             )
                 INTO ptmensaje
                 FROM psu_desresultado r, psu_descontrol d, psu_desnivel n
                WHERE d.ccontrol = v_ccontrol
                  AND d.cidioma = v_cidioma
                  AND r.ccontrol = d.ccontrol
                  AND r.cidioma = d.cidioma
                  AND r.sproduc = v_sproduc
                  AND r.cnivel = v_cnivel
                  AND n.cnivel = r.cnivel
                  AND n.cidioma = r.cidioma;
            ELSE
               v_ret := 0;
               ptmensaje := NULL;
            END IF;
         ELSE
            p_tab_error (f_sysdate,
                         f_user,
                         vobjectname,
                         vpasexec,
                            'vobjectname :'
                         || vobjectname
                         || ' vpasexec: '
                         || vpasexec
                         || 'sseguro :'
                         || psseguro
                         || 'v_fefecto : '
                         || v_fefecto
                         || ' v_sproduc: '
                         || v_sproduc
                         || ' v_cactivi'
                         || v_cactivi
                         || ' pnriesgo : '
                         || pnriesgo
                         || ' v_cgarant : '
                         || v_cgarant
                         || ' v_ccontrol :'
                         || v_ccontrol
                         || ' v_cformula '
                         || v_cformula
                         || ' v_nmovimi '
                         || v_nmovimi
                         || ' v_ret '
                         || v_ret,
                         'ERROR: retorno de funcionde formulas en nulo'
                        );
         END IF;
      ELSE
         v_ret := 0;
         ptmensaje := NULL;
      END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || SQLERRM
                     );
         RETURN 0;
   END f_validacion_psu;

   -- BUG 21905 - FAL - 27/06/2012
   FUNCTION f_aviso_asegurado_no_mujer(
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (500)
                                   := 'pac_avisos.f_aviso_asegurado_no_mujer';
      vparam           VARCHAR2 (1000)                 := ' id=' || pcidioma;
      vpasexec         NUMBER (5)                      := 1;
      vnumerr          NUMBER (8)                      := 0;
      n_registro       NUMBER;
      v_retorno        NUMBER (8)                      := 0;
      -- datos asgurado necesarios
      v_ase_sperson    per_personas.sperson%TYPE;
      v_ase_pais       per_detper.cpais%TYPE;
      v_ase_nacional   per_nacionalidades.cpais%TYPE;
      v_ase_ctipper    per_personas.ctipper%TYPE;
      v_ase_ctipide    per_personas.ctipide%TYPE;
      v_ase_nnumide    per_personas.nnumide%TYPE;
      v_ase_tapelli1   per_detper.tapelli1%TYPE;
      v_ase_tapelli2   per_detper.tapelli2%TYPE;
      v_ase_tnombre1   per_detper.tnombre1%TYPE;
      v_ase_tnombre2   per_detper.tnombre2%TYPE;
      v_ase_csexper    per_personas.csexper%TYPE;
   BEGIN
      vpasexec := 100;
      v_retorno := 0;
      n_registro := 0;

      LOOP
         vpasexec := 120;
         n_registro := n_registro + 1;
         vpasexec := 130;
         vnumerr :=
            pac_call.f_datos_asegurado (n_registro,
                                        v_ase_sperson,
                                        v_ase_ctipper,
                                        v_ase_ctipide,
                                        v_ase_nnumide,
                                        v_ase_tapelli1,
                                        v_ase_tapelli2,
                                        v_ase_tnombre1,
                                        v_ase_tnombre2,
                                        v_ase_csexper
                                       );
         EXIT WHEN v_ase_sperson IS NULL;
         vpasexec := 140;

         IF v_ase_csexper IS NULL
         THEN
            ptmensaje := f_axis_literales (9000771, pcidioma);
            RETURN 1;
         ELSIF v_ase_csexper = 1
         THEN
            ptmensaje := f_axis_literales (9903882, pcidioma);
            RETURN 1;
         END IF;
      END LOOP;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_asegurado_no_mujer;

-- FI BUG 21905

   -- Ini Bug 23822 - MDS - 04/10/2012
   -- Incluye modificaciones del Bug 24091
   FUNCTION f_refer_externa_existe(
      pnsinies    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname            VARCHAR2 (500)
                                       := 'PAC_avisos.f_refer_externa_existe';
      vparam                 VARCHAR2 (1000)     := 'pnsinies = ' || pnsinies;
      vpasexec               NUMBER (5)                  := 0;
      vnumerr                NUMBER (8)                  := 0;
      vcempres               NUMBER;
      vquants                NUMBER;
      vreferencias           t_iax_siniestro_referencias
                                            := t_iax_siniestro_referencias
                                                                          ();
      vlista_trefext         VARCHAR2 (500)              := NULL;
      vlista_siniestros      VARCHAR2 (500)              := NULL;
      vtotlista_siniestros   VARCHAR2 (500)              := NULL;
      vnsinies               VARCHAR2 (14)               := pnsinies;
      vcount_cestsin5        NUMBER;          -- Bug 25684 - MDS - 14/01/2013
   BEGIN
      ptmensaje := NULL;
      vpasexec := 1;

      -- obtener la empresa del seguro
      IF pnsinies IS NOT NULL
      THEN
         SELECT se.cempres
           INTO vcempres
           FROM sin_siniestro si, seguros se
          WHERE si.nsinies = pnsinies AND si.sseguro = se.sseguro;

         vnsinies := pnsinies;
      ELSE
         vcempres := pac_md_common.f_get_cxtempresa;
         vnsinies := pac_iax_siniestros.vgobsiniestro.nsinies;
      END IF;

      vpasexec := 2;
      -- tanto si es ALTA como es CONSULTA/GESTI¿N, busca todas las referencias externas del siniestro (en pantalla) que existan en otros siniestros (en BBDD)
      vreferencias := pac_iax_siniestros.vgobsiniestro.referencias;

      IF vreferencias IS NOT NULL
      THEN
         IF vreferencias.COUNT > 0
         THEN
            FOR i IN vreferencias.FIRST .. vreferencias.LAST
            LOOP
               vpasexec := 3;

               -- existe la referencia en otro siniestro?
               SELECT COUNT (1)
                 INTO vquants
                 FROM sin_siniestro_referencias sr,
                      sin_siniestro si,
                      seguros se
                WHERE (vnsinies IS NULL OR sr.nsinies <> vnsinies)
                  AND sr.nsinies = si.nsinies
                  AND si.sseguro = se.sseguro
                  AND se.cempres = vcempres
                  AND UPPER (sr.trefext) = UPPER (vreferencias (i).trefext);

               vpasexec := 4;

               IF vquants > 0
               THEN
                  -- ya est¿ la referencia duplicada en otro siniestro
                  vnumerr := 1;

                  -- crear el mensaje con la lista de referencias externas duplicadas
                  IF vlista_trefext IS NULL
                  THEN
                     vlista_trefext := vreferencias (i).trefext;
                  ELSE
                     vlista_trefext :=
                            vlista_trefext || ',' || vreferencias (i).trefext;
                  END IF;

                  vpasexec := 5;
                  -- crear el mensaje con la lista de siniestros en los que se encuentra la referencia externa encontrada
                  vlista_siniestros := NULL;

                  FOR x IN (SELECT   sr.nsinies
                                FROM sin_siniestro_referencias sr,
                                     sin_siniestro si,
                                     seguros se
                               WHERE (   vnsinies IS NULL
                                      OR sr.nsinies <> vnsinies
                                     )
                                 AND sr.nsinies = si.nsinies
                                 AND si.sseguro = se.sseguro
                                 AND se.cempres = vcempres
                                 AND UPPER (sr.trefext) =
                                              UPPER (vreferencias (i).trefext)
                            ORDER BY sr.nsinies)
                  LOOP
                     -- Ini 25684 - MDS - 14/01/2013
                     -- mirar si el siniestro es un presiniestro (cestsin = 5)
                     SELECT COUNT (1)
                       INTO vcount_cestsin5
                       FROM sin_movsiniestro
                      WHERE nsinies = x.nsinies
                        AND nmovsin = (SELECT MAX (nmovsin)
                                         FROM sin_movsiniestro
                                        WHERE nsinies = x.nsinies)
                        AND cestsin = 5;

                     -- Fin 25684 - MDS - 14/01/2013
                     IF vlista_siniestros IS NULL
                     THEN
                        IF vcount_cestsin5 = 0
                        THEN
                           vlista_siniestros := x.nsinies;
                        ELSE
                           -- Bug 25684 - MDS - 14/01/2013
                           vlista_siniestros := 'P' || x.nsinies;
                        END IF;
                     ELSE
                        IF vcount_cestsin5 = 0
                        THEN
                           vlista_siniestros :=
                                        vlista_siniestros || '-' || x.nsinies;
                        ELSE
                           -- Bug 25684 - MDS - 14/01/2013
                           vlista_siniestros :=
                                 vlista_siniestros || '-' || 'P' || x.nsinies;
                        END IF;
                     END IF;
                  END LOOP;

                  vpasexec := 6;

                  -- crear el mensaje con toda la lista de siniestros
                  IF vtotlista_siniestros IS NULL
                  THEN
                     vtotlista_siniestros := vlista_siniestros;
                  ELSE
                     vtotlista_siniestros :=
                             vtotlista_siniestros || ',' || vlista_siniestros;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 7;

      -- crear el mensaje final, ya que se ha encontrado alguna referencia en alg¿n otro siniestro
      IF vnumerr = 1
      THEN
         ptmensaje := f_axis_literales (9904298, pcidioma);
         ptmensaje :=
               REPLACE (ptmensaje, '#REF_EXT#', '(' || vlista_trefext || ')');
         ptmensaje :=
            REPLACE (ptmensaje,
                     '#LISTA_SIN#',
                     '(' || vtotlista_siniestros || ')'
                    );
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_refer_externa_existe;

-- Fin Bug 23822 - MDS - 04/10/2012

   /*************************************************************************
        FUNCTION f_aviso_carta_rechazo
        Funci¿n que valida si se ha emitido una carta de rechazo en los ultimos 90 dias

        psseguro in number
        pcidioma in number
        ptmensaje out: Texto de error
       RETURN 0(ok),RETURN 1(ko)

       0024273: MDP_S001-SIN - Carta de rechazo de alta de siniestro.
   *************************************************************************/
   FUNCTION f_aviso_carta_rechazo(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'pac_avisos.f_aviso_carta_rechazo';
      vparam        VARCHAR2 (1000) := ' id=' || pcidioma;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      n_registro    NUMBER;
      v_retorno     NUMBER (8)      := 0;
      v_fichero     VARCHAR2 (1000);
      v_fecha       DATE;
      v_dias        NUMBER;
   BEGIN
      ptmensaje := NULL;
      vpasexec := 100;

      FOR i IN (SELECT *
                  FROM docummovseg
                 WHERE sseguro = psseguro)
      LOOP
         SELECT pac_axisgedox.f_get_filedoc (i.iddocgedox)
           INTO v_fichero
           FROM DUAL;

         IF INSTR (v_fichero, 'MDP0001') > 0
         THEN
            SELECT pac_axisgedox.f_get_falta (i.iddocgedox)
              INTO v_fecha
              FROM DUAL;

            SELECT f_sysdate - v_fecha
              INTO v_dias
              FROM DUAL;

            IF v_dias < 91
            THEN
               ptmensaje := f_axis_literales (9904403, pcidioma);
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_carta_rechazo;

   /*************************************************************************
        FUNCTION f_aviso_no_tramitador
        Funci¿n que valida si el siniestro no tiene tramitador asignado

        pnsinies in varchar2
        pcidioma in number
        ptmensaje out: Texto de error
       RETURN 0(ok),RETURN 1(ko)

       0024304: Aviso 'Siniestro sin tramitador'
   *************************************************************************/
   FUNCTION f_aviso_no_tramitador(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname    VARCHAR2 (500)  := 'pac_avisos.f_aviso_no_tramitador';
      vparam         VARCHAR2 (1000) := ' id=' || pcidioma;
      vpasexec       NUMBER (5)      := 1;
      vnumerr        NUMBER (8)      := 0;
      n_registro     NUMBER;
      v_retorno      NUMBER (8)      := 0;
      v_tramitador   VARCHAR2 (4);
   BEGIN
      ptmensaje := NULL;
      vpasexec := 100;

      IF pnsinies IS NULL
      THEN
         RETURN 0;
      END IF;

      SELECT ctramitad
        INTO v_tramitador
        FROM sin_movsiniestro m1
       WHERE m1.nsinies = pnsinies
         AND m1.nmovsin = (SELECT MAX (m2.nmovsin)
                             FROM sin_movsiniestro m2
                            WHERE m2.nsinies = m1.nsinies);

      IF v_tramitador = 'T000'
      THEN
         ptmensaje := f_axis_literales (9904405, pcidioma);
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_no_tramitador;

   /*************************************************************************
        FUNCTION
        Funci¿n que valida la informaci¿n introducida suplemento prorroga vigencia
        ptmensaje out: Texto de error
        RETURN 0(ok),RETURN 1(ko)
        BUG 0026035 - 18/02/2013 - JMF
   *************************************************************************/
   FUNCTION f_val_prorrogavigencia(
      psseguro    IN       NUMBER,
      pfefecto    IN       DATE,
      pcduraci    IN       NUMBER,
      pfrenova    IN       DATE,
      pcforpag    IN       NUMBER,
      pctipcob    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER         := 1;
      vobjectname   VARCHAR2 (500) := 'pac_avisos.f_val_prorrogavigencia';
      vparam        VARCHAR2 (500)
         :=    'seg='
            || psseguro
            || ' efe='
            || pfefecto
            || ' dur='
            || pcduraci
            || ' ren='
            || pfrenova
            || ' for='
            || pcforpag
            || ' cob='
            || pctipcob
            || ' idi='
            || pcidioma;
      v_fcaranu     DATE;
   BEGIN
      SELECT fcaranu
        INTO v_fcaranu
        FROM seguros
       WHERE sseguro = pac_iax_produccion.vsseguro;

      IF pfrenova IS NULL
      THEN
         -- Falta la fecha de la renovaci¿n
         ptmensaje := f_axis_literales (101826, pcidioma);
         RETURN 1;
      ELSIF pfefecto > pfrenova
      THEN
         -- La fecha de renovaci¿n no puede ser inferior a la fecha de efecto de la p¿liza
         ptmensaje := f_axis_literales (9904199, pcidioma);
         RETURN 1;
      ELSIF v_fcaranu = pfrenova
      THEN
         -- La fecha de renovaci¿n no puede ser inferior a la fecha de efecto de la p¿liza
         ptmensaje := f_axis_literales (9905119, pcidioma);
         RETURN 1;
      ELSIF v_fcaranu >= pfrenova
      THEN
         ----La actual fecha de renovaci¿n no puede ser inferior a la nueva fecha de renovaci¿n de la p¿liza
         --ptmensaje := f_axis_literales(9905127, pcidioma);
         --BUG 27539 - 02/07/2013 - DCT
         --La nueva fecha de renovaci¿n no puede ser inferior a la actual fecha de renovaci¿n.
         ptmensaje := f_axis_literales (9905742, pcidioma);
         RETURN 1;
      /*ELSIF pfrenova > ADD_MONTHS(f_sysdate, 12) THEN
         -- Fecha fuera de l¿mites
         ptmensaje := f_axis_literales(101490, pcidioma) || ' max.'
                      || ADD_MONTHS(f_sysdate, 12);
         RETURN 1;*/
      --BUG27539 - INICIO - 152419 - DCT - 09/09/2013
      ELSIF MOD (MONTHS_BETWEEN (pfrenova, v_fcaranu), 1) <> 0
      THEN
         --ELSIF MOD(MONTHS_BETWEEN(pfrenova, pfefecto), 1) <> 0 THEN
            --BUG27539 - FIN - 152419 - DCT - 09/09/2013
               -- La pr¿rroga de la vigencia, debe ser de meses enteros
         ptmensaje := f_axis_literales (9905010, pcidioma);
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      ptmensaje
                     );
         RETURN 1;
   END f_val_prorrogavigencia;

   -- Bug 24745/0135666 -- ETM --23/01/2013
/*************************************************************************
        FUNCTION f_valida_bajagaran
        Funci¿n q comprueba si se puden dar de baja garantias cuando hay siniestros en la poliza
        psseguro in number
        pnriesgo in number
        pnmovimi  in number
        pcidioma  in number
        ptmensaje out: Texto de error
        RETURN 0(ok),return 1 (ko)
   *************************************************************************/
   FUNCTION f_valida_bajagaran(
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (500)  := 'pac_avisos_pos.f_valida_bajagaran';
      vparam           VARCHAR2 (1000)
         :=    ' psseguro='
            || psseguro
            || ' pnriesgo='
            || pnriesgo
            || ' pnmovimi= '
            || pnmovimi
            || ' pcidioma='
            || pcidioma;
      vpasexec         NUMBER (5);
      v_nmovimi        NUMBER (10);
      v_ret            NUMBER                    := 0;
      v_nmovimi_real   NUMBER (10);
      v_fechasup       DATE;
      v_estsseguro     estseguros.sseguro%TYPE;
   BEGIN
      ptmensaje := NULL;

      BEGIN
         SELECT sseguro
           INTO v_estsseguro
           FROM estseguros
          WHERE ssegpol = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            vpasexec := 1;
            RETURN 1;
      END;

      IF pnmovimi IS NULL
      THEN
         SELECT MAX (p.fsuplem), MAX (nmovimi)
           INTO v_fechasup, v_nmovimi
           FROM pds_estsegurosupl p
          WHERE p.sseguro = v_estsseguro AND p.cmotmov = 239;
      ELSE
         v_nmovimi := pnmovimi;
      END IF;

      vpasexec := 2;

      BEGIN
         SELECT MAX (e.nmovimi)
           INTO v_nmovimi_real
           FROM garanseg e
          WHERE e.sseguro = psseguro AND e.nriesgo = pnriesgo;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_nmovimi_real := v_nmovimi - 1;
      END;

      vpasexec := 3;

      BEGIN
         FOR reg IN (SELECT g.cgarant
                       FROM garanseg g
                      WHERE g.sseguro = psseguro
                        AND g.nriesgo = pnriesgo
                        AND g.nmovimi = v_nmovimi_real
                        AND g.cgarant NOT IN (
                               SELECT DISTINCT e.cgarant
                                          FROM estgaranseg e
                                         WHERE e.sseguro = v_estsseguro
                                           AND e.nriesgo = pnriesgo
                                           AND e.nmovimi = v_nmovimi))
         LOOP
            vpasexec := 4;

            FOR regis IN (SELECT sn.nsinies
                            FROM sin_tramita_reserva st, sin_siniestro sn
                           WHERE sn.sseguro = psseguro
                             AND sn.nriesgo = pnriesgo
                             AND sn.nmovimi = v_nmovimi_real
                             AND sn.nsinies = st.nsinies
                             AND st.cgarant = reg.cgarant)
            LOOP
               vpasexec := 5;

               BEGIN
                  SELECT COUNT (*)
                    INTO v_ret
                    FROM sin_movsiniestro
                   WHERE nsinies = regis.nsinies
                     AND cestsin NOT IN (3, 4)
                     AND festsin >= v_fechasup;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     vpasexec := 6;
                     RETURN 1;
               END;

               vpasexec := 7;

               IF v_ret <> 0
               THEN
                  ptmensaje := f_axis_literales (9904455, pcidioma);
                  RETURN 1;
               END IF;
            END LOOP;

            vpasexec := 8;
         END LOOP;
      EXCEPTION
         WHEN OTHERS
         THEN
            vpasexec := 9;
            RETURN 1;
      END;

      vpasexec := 10;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || SQLERRM
                     );
         RETURN 1;
   END f_valida_bajagaran;

-- FIN --Bug 24745/0135666 -- ETM --23/01/2013
   /*************************************************************************
        FUNCTION
        Funci¿n que valida la informaci¿n introducida suplemento renovacion vigencia
        ptmensaje out: Texto de error
        RETURN 0(ok),RETURN 1(ko)
        BUG 0026035 - 18/02/2013 - JMF
   *************************************************************************/
   FUNCTION f_val_renovavigencia(
      psseguro    IN       NUMBER,
      pfefecto    IN       DATE,
      pcduraci    IN       NUMBER,
      pfrenova    IN       DATE,
      pcforpag    IN       NUMBER,
      pctipcob    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER         := 1;
      vobjectname   VARCHAR2 (500) := 'pac_avisos.f_val_renovavigencia';
      vparam        VARCHAR2 (500)
         :=    'seg='
            || psseguro
            || ' efe='
            || pfefecto
            || ' dur='
            || pcduraci
            || ' ren='
            || pfrenova
            || ' for='
            || pcforpag
            || ' cob='
            || pctipcob
            || ' idi='
            || pcidioma;
      v_fcaranu     DATE;
   BEGIN
      SELECT fcaranu
        INTO v_fcaranu
        FROM seguros
       WHERE sseguro = pac_iax_produccion.vsseguro;

      IF pfrenova IS NULL
      THEN
         -- Falta la fecha de la renovaci¿n
         ptmensaje := f_axis_literales (101826, pcidioma);
         RETURN 1;
      ELSIF pfefecto > pfrenova
      THEN
         -- La fecha de renovaci¿n no puede ser inferior a la fecha de efecto de la p¿liza
         ptmensaje := f_axis_literales (9904199, pcidioma);
         RETURN 1;
      ELSIF v_fcaranu = pfrenova
      THEN
         -- La fecha de renovaci¿n no puede ser inferior a la fecha de efecto de la p¿liza
         ptmensaje := f_axis_literales (9905119, pcidioma);
         RETURN 1;
      ELSIF v_fcaranu >= pfrenova
      THEN
         ----La actual fecha de renovaci¿n no puede ser inferior a la nueva fecha de renovaci¿n de la p¿liza
         --ptmensaje := f_axis_literales(9905127, pcidioma);
         --BUG 27539 - 02/07/2013 - DCT
         --La nueva fecha de renovaci¿n no puede ser inferior a la actual fecha de renovaci¿n.
         ptmensaje := f_axis_literales (9905742, pcidioma);
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      ptmensaje
                     );
         RETURN 1;
   END f_val_renovavigencia;

   -- Bug 27539/0149064 - APD - 17/07/2013
   FUNCTION f_valida_retorno(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (500)   := 'pac_avisos_lcol.f_valida_retorno';
      vparam           VARCHAR2 (1000)           := 'pcidioma = ' || pcidioma;
      vpasexec         NUMBER (5)                     := 1;
      vnumerr          NUMBER (8)                     := 0;
      v_retorno        NUMBER (8)                     := 0;
      n_registro       NUMBER;
      mensajes         t_iax_mensajes;
      v_existepreg     NUMBER;
      v_cpregun_4817   estpregunpolseg.cpregun%TYPE   := 4817;
      v_crespue_4817   estpregunpolseg.crespue%TYPE;
      v_trespue_4817   estpregunpolseg.trespue%TYPE;
      salir            EXCEPTION;
   BEGIN
      vpasexec := 1;
      v_retorno := 0;
      n_registro := 0;
      -- Se busca la respuesta actual de la pregunta
      vnumerr :=
         pac_call.f_get_preguntas (n_registro,
                                   v_cpregun_4817,
                                   v_crespue_4817,
                                   v_trespue_4817,
                                   v_existepreg
                                  );
      vpasexec := 2;

      -- Existe la pregunta
      IF v_existepreg = 1
      THEN
         vpasexec := 3;

         -- Si la respuesta es Si debe estar informado el co-corretaje
         IF NVL (v_crespue_4817, 0) = 1
         THEN
            vpasexec := 4;

            IF pac_iax_produccion.poliza.det_poliza.retorno IS NOT NULL
            THEN
               vpasexec := 5;

               IF pac_iax_produccion.poliza.det_poliza.retorno.COUNT > 0
               THEN
                  vpasexec := 6;
                  v_retorno := 0;
               ELSE
                  vpasexec := 7;
                  ptmensaje := f_axis_literales (120082, pcidioma);
                  v_retorno := 1;
               END IF;
            ELSE
               vpasexec := 8;
               ptmensaje := f_axis_literales (120082, pcidioma);
               v_retorno := 1;
            END IF;
         END IF;
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      f_axis_literales (vnumerr)
                     );
         RETURN 1;
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_valida_retorno;

   -- Bug 27539/0149064 - APD - 17/07/2013
   FUNCTION f_valida_corretaje(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (500) := 'pac_avisos_lcol.f_valida_corretaje';
      vparam           VARCHAR2 (1000)           := 'pcidioma = ' || pcidioma;
      vpasexec         NUMBER (5)                     := 1;
      vnumerr          NUMBER (8)                     := 0;
      v_retorno        NUMBER (8)                     := 0;
      n_registro       NUMBER;
      mensajes         t_iax_mensajes;
      v_existepreg     NUMBER;
      v_cpregun_4780   estpregunpolseg.cpregun%TYPE   := 4780;
      v_crespue_4780   estpregunpolseg.crespue%TYPE;
      v_trespue_4780   estpregunpolseg.trespue%TYPE;
      salir            EXCEPTION;
   BEGIN
      vpasexec := 1;
      v_retorno := 0;
      n_registro := 0;
      -- Se busca la respuesta actual de la pregunta
      vnumerr :=
         pac_call.f_get_preguntas (n_registro,
                                   v_cpregun_4780,
                                   v_crespue_4780,
                                   v_trespue_4780,
                                   v_existepreg
                                  );
      vpasexec := 2;

      -- Existe la pregunta
      IF v_existepreg = 1
      THEN
         vpasexec := 3;

         -- Si la respuesta es Si debe estar informado el co-corretaje
         IF NVL (v_crespue_4780, 0) = 1
         THEN
            vpasexec := 4;

            IF pac_iax_produccion.poliza.det_poliza.corretaje IS NOT NULL
            THEN
               vpasexec := 5;

               IF pac_iax_produccion.poliza.det_poliza.corretaje.COUNT > 0
               THEN
                  vpasexec := 6;
                  v_retorno := 0;
               ELSE
                  vpasexec := 7;
                  ptmensaje := f_axis_literales (9902397, pcidioma);
                  v_retorno := 1;
               END IF;
            ELSE
               vpasexec := 8;
               ptmensaje := f_axis_literales (9902397, pcidioma);
               v_retorno := 1;
            END IF;
         END IF;
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      f_axis_literales (vnumerr)
                     );
         RETURN 1;
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_valida_corretaje;

   -- Bug 31165 - NSS - 29/04/2014
   FUNCTION f_aviso_pol_bloqueada(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos.f_aviso_pol_bloqueada';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      IF f_bloquea_pignorada (psseguro, f_sysdate) = 1
      THEN
         vnumerr := 1;
         ptmensaje := f_axis_literales (9906733, pcidioma);
      ELSIF f_bloquea_pignorada (psseguro, f_sysdate) = 2
      THEN
         vnumerr := 1;
         ptmensaje := f_axis_literales (9906734, pcidioma);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_pol_bloqueada;

   -- Bug 31165 - NSS - 29/04/2014
   FUNCTION f_aviso_ben_oneroso(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos.f_aviso_pol_bloqueada';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO vquants
        FROM benespseg
       WHERE ctipben = 2
         AND sseguro = psseguro
         AND finiben >= f_sysdate
         AND (ffinben <= f_sysdate OR ffinben IS NULL);

      IF vquants > 0
      THEN
         vnumerr := 1;
         ptmensaje := f_axis_literales (9906735, pcidioma);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_ben_oneroso;

   /* bug 31872/177857:NSS:08/07/2014

        Se mostrar¿ un aviso cuando la p¿liza es reasegurada (Aviso de p¿liza)
        RETURN 0(ok),1(error)
        */
   FUNCTION f_aviso_pol_es_reasegurada(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500) := 'PAC_avisos.f_aviso_pol_es_reasegurada';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vfsinies      DATE;
      vccausin      NUMBER;
      vsseguro      NUMBER;
   BEGIN
      IF psseguro IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vquants
           FROM cesionesrea
          WHERE sseguro = psseguro;

         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9906851, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_pol_es_reasegurada;

   FUNCTION f_aviso_servicio(
      pcservicio   IN       VARCHAR2,
      pcidioma     IN       NUMBER,
      ptmensaje    OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'pac_avisos.f_aviso_servicio';
      vparam        VARCHAR2 (1000)
                 := ' pcservicio=' || pcservicio || '; pcidioma=' || pcidioma;
      vpasexec      NUMBER (5)      := 0;
      vnumerr       NUMBER (8)      := 0;
      v_retorno     NUMBER (8)      := 0;
   BEGIN
      vpasexec := 1;

      IF pac_iax_produccion.issimul
      THEN
         RETURN 0;
      ELSE
         IF NVL (pcservicio, 0) = 0
         THEN
            ptmensaje := f_axis_literales (9906844, pcidioma);
                                  --- no se ha informado el tipo de servicio.
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_aviso_servicio;

   FUNCTION f_hay_franquicia(
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'pac_avisos.f_hay_franquicia';
      vparam        VARCHAR2 (1000)
         :=    ' psseguro='
            || psseguro
            || '; pnriesgo='
            || pnriesgo
            || '; pnmovimi='
            || pnmovimi;
      vpasexec      NUMBER (5)      := 0;
      vnumerr       NUMBER (8)      := 0;
      v_hay_franq   NUMBER          := 0;
   BEGIN
      vpasexec := 1;
      v_hay_franq := 0;

      SELECT COUNT (*)
        INTO v_hay_franq
        FROM bf_bonfranseg f, bf_detnivel dt
       WHERE f.sseguro = psseguro
         AND f.nriesgo = pnriesgo
         AND f.nmovimi = pnmovimi
         AND dt.cgrup = f.cgrup
         AND dt.csubgrup = f.csubgrup
         AND dt.cversion = f.cversion
         AND dt.cnivel = f.cnivel
         AND NOT dt.impvalor1 = 0;

      IF v_hay_franq > 0
      THEN
         ptmensaje := f_axis_literales (9907609, pcidioma);
                                                    --- P¿liza con franquicia
         RETURN 1;
      END IF;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_hay_franquicia;

/*************************************************************************
      ini 34866/206900 -- JR -- 18/06/2015

      FUNCTION f_valida_bene_accepted
      Funci¿n que valida retorna un aviso para la pantalla AXISCTR177 / AXISCTR006
      De manera que para MSV, el valor 'Accepted' solo se puede seleccionar
      si no estamos en nueva produccion. Este aviso se parametriza unicamente
      para el modo 'ALTA_POLIZA'.

      pctipben  in  NUMBER   :
      ptmensaje out VARCHAR2 : Texto de aviso si el tipo es beneficiario aceptado
     RETURN 0(ok),RETURN 1(ko)

     206900: Aviso 'Beneficiario aceptado no se permite durante nueva producci¿n'
   *************************************************************************/
   FUNCTION f_valida_bene_accepted(
      pctipben    IN       benespseg.ctipben%TYPE,
      pcidioma    IN       idiomas.cidioma%TYPE,
      ptmensaje   OUT      axis_literales.tlitera%TYPE
   )
      RETURN NUMBER
   IS
      vresultado    NUMBER                  := 0;
      vobjectname   VARCHAR2 (500)     := 'PAC_AVISOS.f_valida_bene_accepted';
      vpasexec      NUMBER (5)              := 0;
      vcidioma      NUMBER                  := pac_md_common.f_get_cxtidioma;
      vparam        VARCHAR2 (1000)
                    := ' ptmensaje=' || ptmensaje || ' vcidioma=' || vcidioma;
      ob_iax_ben    ob_iax_beneficiarios;
      t_iax_ben     t_iax_beneidentificados;
   BEGIN
      vpasexec := 1;

      IF pctipben = 4
      THEN
         ptmensaje := f_axis_literales (9908189, vcidioma);
         RETURN 1;
      END IF;

      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_valida_bene_accepted;
-- fin 34866/206900 -- JR -- 18/06/2015

  FUNCTION f_aviso_sini_en_suspension(
    psseguro IN NUMBER,
    pnsinies IN VARCHAR2,
    pcidioma IN NUMBER,
    ptmensaje OUT VARCHAR2)
    RETURN NUMBER is
    vobjectname   VARCHAR2 (500)     := 'PAC_AVISOS.f_aviso_sini_en_suspension';
    vparam        VARCHAR2 (1000)
                    :=' psseguro=' || psseguro || ' pnsinies=' || pnsinies|| ' ptmensaje=' || ptmensaje || ' pcidioma=' || pcidioma;
    V_FSINIES DATE;
    v_suspension NUMBER;

    BEGIN
    PTMENSAJE := F_AXIS_LITERALES(9909811, PCIDIOMA);

    IF psseguro IS NULL OR pnsinies IS NULL THEN
     RETURN 0;
    END IF;

    SELECT FSINIES
     INTO V_FSINIES
    FROM SIN_SINIESTRO
     WHERE nsinies = PNSINIES;

    SELECT count(1)
     INTO v_suspension
    FROM SUSPENSIONSEG
     WHERE SSEGURO = psseguro
      AND CMOTMOV = 391
      AND v_FSINIES BETWEEN FINICIO AND NVL(FFINAL,TO_DATE('31/12/4999','DD/MM/YYYY'));

  END f_aviso_sini_en_suspension;

/*************************************************************************
      -- INI -IAXIS-5100 - JLTS - 22/08/2019

      FUNCTION f_valida_rango_dian_RC_RD
      Función que permite validar que no se puedan crear más de un registro de resoluciones
      para el Rango Dian de RC(802), grupo RD y con las misma sucursal.

		pnresol  : Resolución de la Dian
    pcramo   : Ramo 
    pCGRUPO  : Grupo
    pSUCURSAL: agente de tipo sucursal o agencia
    RETURN 0(ok),RETURN 1(ko)

    500000: Aviso 'No se puede crear más de una configuración para RC - Grupo RD - sucursal'
   *************************************************************************/

  FUNCTION f_valida_rango_dian_rc_rd(pnresol   IN rango_dian.nresol%TYPE,
                                     pcramo    IN rango_dian.cramo%TYPE,
                                     pcgrupo   IN rango_dian.cgrupo%TYPE,
                                     psucursal IN rango_dian.cagente%TYPE,
                                     pcidioma  IN idiomas.cidioma%TYPE,
                                     ptmensaje OUT VARCHAR2) RETURN NUMBER IS
    CURSOR c_rango_dian IS
      SELECT COUNT(1) contador
        FROM rango_dian ra
       WHERE ra.nresol = pnresol
         AND ra.cramo = pcramo
         AND ra.cagente = psucursal
         AND ra.cgrupo = pcgrupo
         AND ra.cgrupo = 'RD';
    c_rango_dian_r c_rango_dian%ROWTYPE;
    v_retorno      NUMBER := 0;
  BEGIN
    OPEN c_rango_dian;
    FETCH c_rango_dian
      INTO c_rango_dian_r;
    IF c_rango_dian%NOTFOUND THEN
      v_retorno := 0;
    END IF;
    IF c_rango_dian_r.contador >= 1 THEN
      ptmensaje := f_axis_literales(5000000, pcidioma);
      v_retorno := 1;
    END IF;
    IF c_rango_dian%ISOPEN THEN
      CLOSE c_rango_dian;
    END IF;
    RETURN v_retorno;
  END f_valida_rango_dian_rc_rd;
  -- FIN -IAXIS-5100 - JLTS - 22/08/2019


END pac_avisos;

/

  GRANT EXECUTE ON "AXIS"."PAC_AVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AVISOS" TO "PROGRAMADORESCSI";
