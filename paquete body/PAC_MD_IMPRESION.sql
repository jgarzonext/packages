CREATE OR REPLACE PACKAGE BODY "PAC_MD_IMPRESION"
AS
/******************************************************************************
   NOMBRE:      PAC_MD_IMPRESION
   PROPÓSITO: Funciones para la impresión de documentos

   REVISIONES:
   Ver        Fecha        Autor  Descripción
   ---------  ----------  ------  ------------------------------------
   1.1        28/04/2008   ACC    Incluir funciones de impresión
   2.0        19/03/2009   SBG    Afegir camps ICGARAC i ICFALLAC
   3.0        27/04/2009   SBG    Modifs. a f_detimprimir (v_idcat) (Bug 9472)
   4.0        13/05/2009   ICV    0010078: IAX - Adaptación impresiones (plantillas)
   5.0        20/05/2009   DRA    0010167: CRE069 - Incluir documento autorización CASS
   6.0        04/06/2009   JTS    10233: APR - cartas de impagados ( 2ª parte)
   7.0        07/10/2009   FAL    11270: APRA - Parametritzacio de les impressions
   8.0        05/02/2010   JTS    12693: PODER EXTREURE DUPLICATS DE DOCUMENACIÓ
   9.0        08/02/2010   JTS    12850: CEM210 - Estalvi: Plantilles de pignoracions i bloquejos
   10.0       23/04/2010   DRA    0014231: CRE999 - PLANTILLES: Alguns texts de plantilles i descripcions apareixen en castellà
   11.0       10/05/2010   JTS    BUG 13104 Diverses modificacions
   12.0       16/06/2010   ICV    0014837: APR710 - Incidencias impresiones
   13.0       21/06/2010   JTS    15032: CIV800 - PLANTILLA SIMULACIONS: Sempre apareix en castellà
   14.0       24/08/2010   SRA    15625: CEM - Documentación siniestros pólizas anuladas
   15.0       13/09/2010   XPL    15685: CIV998 - Preparar la aplicación para que registre campos concretos en log_actividad
   16.0       16/09/2010   RSC    0016017: CEM - Parametrizar la impresión de la plantilla de revocación de traspaso
   17.0       13/08/2010   RSC    0014775: AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
   18.0       31/12/2010   ETM    0016446: GRC - Documento de pago de siniestros
   19.0       22/02/2011   APD    0017561: AGA800 - doc. de creació de sinistres no es guarda al gedox
   20.0       05/05/2011   JTS    18463: ENSA-101-Recepción del nrecibo como parámetro por parte del modelo de impresión
   21.0       24/11/2011   ETM    0019783: LCOL_S001-SIN - Rechazo de tramitaciones
   22.0       23/04/2012   JMF    0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
   23.0       05/06/2012   JMF    0022444: MDP_S001-SIN - Carta de rechazo en alta siniestro
   24.0       24/01/2013   MLA    0025816: RSAG - Enviar un correo con datos adjuntos.
   25.0       13/01/2014   dlF    0027744: AGM900 - Producto de Explotaciones 2013
   26.0       26/02/2014   JTT    0033345: COLM - Se modifica la funcion f_detimprimir para recuperar el codigo de documento
   27.0       28/05/2015   OZEA   0035712: Tarea 0202997 se agrega validacion para enviar notificacion por renovacion de poliza.
   28.0       03/07/2015   ETM    33632: MSV0010-MSV0003 : templates quotations (protection)/NOTA 0209087--mandar mail al agente si este lo tiene informado para las plantillas de tipo 67
   29.0       15/07/2015   YDA    0033632: Se modifica la función f_get_documprod_tipo para no validar el estado de anulacion  en el tipo 71
   30.0       03.02.2016   IPH    0039715: Se adiciona parámetro parinstalación MAXDOCS que sirva para limitar la cantidad de documentos a recoger en
                                            la función f_recupera_pendientes y evitar caidas de servicio de impresión en algunos clientes (RSA
   31.0       25/08/2016    JAA     CONF-236: Parámetros de fecha archivado, eliminación y caducidad de los documentos
   32.0       29/03/2019    ACL   IAXIS-2136: Se quita condición para pólizas anuladas en la función f_get_documprod_tipo.
   33.0       15/05/2019    CES-RAB IAXIS-3088: Configuración plantilla Formato USF.
******************************************************************************/
   PROCEDURE p_recupera_error (
      psinterf     IN       int_resultado.sinterf%TYPE,
      presultado   OUT      int_resultado.cresultado%TYPE,
      perror       OUT      int_resultado.terror%TYPE,
      pnerror      OUT      int_resultado.nerror%TYPE
   )
   IS
   BEGIN
      -- Recupero el error
      SELECT r1.cresultado, r1.tcampoerror || ' ' || r1.terror, r1.nerror
        INTO presultado, perror, pnerror
        FROM int_resultado r1
       WHERE r1.sinterf = psinterf
         AND r1.smapead = (SELECT MAX (r2.smapead)
                             FROM int_resultado r2
                            WHERE r2.sinterf = psinterf);
   EXCEPTION
      WHEN OTHERS
      THEN
         presultado := NULL;
         perror := NULL;
         pnerror := NULL;
   END;

   PROCEDURE parsear (p_clob IN CLOB, p_parser IN OUT xmlparser.parser)
   IS
   BEGIN
      p_parser := xmlparser.newparser;
      xmlparser.setvalidationmode (p_parser, FALSE);

      IF DBMS_LOB.getlength (p_clob) > 32767
      THEN
         xmlparser.parseclob (p_parser, p_clob);
      ELSE
         xmlparser.parsebuffer (p_parser,
                                DBMS_LOB.SUBSTR (p_clob,
                                                 DBMS_LOB.getlength (p_clob),
                                                 1
                                                )
                               );
      END IF;
   END;

   /*************************************************************************
      Obtiene un objeto de información de impresión, inicializado con los
      valores generales del seguro pasado por parámetro.
      param in psseguro    : Código de seguro
      param in pctipo      : tipo de documento
      param in pmode       : Modo ('POL' / 'EST')
      param out mensajes   : mensajes de error
      return               : OB_INFO_IMP
      
      2.0 CES-RAB IAXIS-3088: Agregar con nsolici para usf.
   *************************************************************************/
   FUNCTION f_get_infoimppol (
      psseguro   IN       seguros.sseguro%TYPE,
      pctipo     IN       NUMBER,
      pmode      IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN ob_info_imp
   IS
      vpasexec    NUMBER (8)                := 1;
      vparam      VARCHAR2 (500)            := 'psseguro: ' || psseguro;
      vobject     VARCHAR2 (200)       := 'PAC_MD_IMPRESION.F_Get_InfoImpPol';
      vobj        ob_info_imp;
      v_cempres   NUMBER;
      -- Bug 16017 - RSC - 16/09/2010 - CEM - Parametrizar la impresión de la plantilla de revocación de traspaso
      v_stras     trasplainout.stras%TYPE;
   -- Fin Bug 16017
   BEGIN
      --Comprovació de parámetres d'entrada
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pmode = 'POL'
      THEN
         --Informació general de la pòlissa.
         SELECT s.sseguro, s.npoliza, s.ncertif, s.sproduc,
                NVL (s.cidioma, pac_md_common.f_get_cxtidioma), s.cempres, S.NSOLICI
           INTO vobj.sseguro, vobj.npoliza, vobj.ncertif, vobj.sproduc,
                vobj.cidioma, vobj.cempres, vobj.nsolici
           FROM seguros s
          WHERE s.sseguro = psseguro;

         --Número de moviment actual
         SELECT MAX (nmovimi)
           INTO vobj.nmovimi
           FROM movseguro m
          WHERE m.sseguro = psseguro;

         -- Bug 10199 - APD - 27/05/2009 - se busca el uñtimo siniestro generado
         -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         SELECT cempres
           INTO v_cempres
           FROM seguros
          WHERE sseguro = psseguro;

         IF NVL (pac_parametros.f_parempresa_n (v_cempres, 'MODULO_SINI'), 0) =
                                                                             0
         THEN
            SELECT MAX (nsinies)
              INTO vobj.nsinies
              FROM siniestros
             WHERE sseguro = psseguro;
         ELSE
            SELECT MAX (nsinies)
              INTO vobj.nsinies
              FROM sin_siniestro
             WHERE sseguro = psseguro;
         END IF;

         -- Fin BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         -- Bug 10199 - APD - 27/05/2009 - fin

         -- BUG 8290 - 19/03/2009 - SBG - Recalculem la provisió matemàtica, el capital a la
         -- mort i el capital mínim garantit, ja que no es pot cridar a la funció
         -- pac_provmat_formul.f_calcul_formulas_provi des d'una consulta.
         IF pctipo = 9
         THEN
            vobj.iprovac :=
               pac_provmat_formul.f_calcul_formulas_provi (psseguro,
                                                           f_sysdate,
                                                           'IPROVAC'
                                                          );
            vobj.iprovac := NVL (vobj.iprovac, 0);
            vobj.icgarac :=
               pac_provmat_formul.f_calcul_formulas_provi (psseguro,
                                                           f_sysdate,
                                                           'ICGARAC'
                                                          );
            vobj.icgarac := NVL (vobj.icgarac, 0);
            vobj.icfallac :=
               pac_provmat_formul.f_calcul_formulas_provi (psseguro,
                                                           f_sysdate,
                                                           'ICFALLAC'
                                                          );
            vobj.icfallac := NVL (vobj.icfallac, 0);
         END IF;
      ELSE
         --Informació general de la pòlissa.
         SELECT s.sseguro, s.npoliza, s.ncertif, s.sproduc,
                s.cidioma, 1, s.cempres, s.nsolici
           INTO vobj.sseguro, vobj.npoliza, vobj.ncertif, vobj.sproduc,
                vobj.cidioma, vobj.nmovimi, vobj.cempres, vobj.nsolici
           FROM estseguros s
          WHERE s.sseguro = psseguro;

         --Idioma de la simulació
         -- BUG 15032 - JTS - 17/06/2010
         -- Agafem l'idioma de la persona asociada si aquesta es real
         DECLARE
            v_idioma   NUMBER := vobj.cidioma;
         BEGIN
            SELECT NVL (NVL (cidioma, v_idioma),
                        pac_md_common.f_get_cxtidioma)
              INTO vobj.cidioma
              FROM estper_detper p, estper_personas ep, estassegurats a
             WHERE p.sperson = a.sperson
               AND ep.sperson = p.sperson
               AND ep.ctipide != 99
               AND a.sseguro = vobj.sseguro
               AND a.norden = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               vobj.cidioma := v_idioma;
         END;
      --Fi BUG 15032
      END IF;

      --BUG 12693 - JTS - 04/02/2010
      vobj.cduplica := NVL (f_get_cduplica (pctipo), 0);

      --Fi BUG 12693

      -- Bug 16017 - RSC - 16/09/2010 - CEM - Parametrizar la impresión de la plantilla de revocación de traspaso
      BEGIN
         SELECT stras
           INTO v_stras
           FROM trasplainout
          WHERE sseguro = vobj.sseguro
            AND cestado = 6
            AND festado = (SELECT MAX (festado)
                             FROM trasplainout t2
                            WHERE sseguro = vobj.sseguro AND cestado = 6);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      vobj.stras := v_stras;
      -- Fin Bug 16017
      RETURN vobj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_infoimppol;

   /*************************************************************************
      Función que retorna los parámetros necesarios para imprimir una determinada consulta.
      param in pidconsulta : Código de la consulta a partir de la cual se debe imprimir la plantilla
      param in pinfoimp    : Información general para inicializar los parámetros de la consulta.
      param out pparamimp  : Parámetros para la impresión de la consulta.
      return               : NUMBER
   *************************************************************************/
   FUNCTION f_get_paramimp (
      pidconsulta   IN       consultas.idconsulta%TYPE,
      pinfoimp      IN       ob_info_imp,
      pparamimp     OUT      pac_isql.vparam
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)     := 1;
      vparam       VARCHAR2 (500) := 'pidconsulta: ' || pidconsulta;
      vobject      VARCHAR2 (200) := 'PAC_MD_IMPRESION.F_Get_ParamImp';
      vconsulta    CLOB;
      vindex_i     NUMBER (8);
      vlength      NUMBER (8);
      vnparam      NUMBER (8)     := 0;               --Número de parámetros.
      vlstparam    VARCHAR2 (500);                     --Llista de parámetros
      vparam_act   VARCHAR2 (500);
      -- Bug 14775 13/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
      v_sproces    NUMBER;
   -- Fin Bug 14775
   BEGIN
      --Comprovació de parámetres d'entrada
      IF pidconsulta IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      SELECT CASE NVL (c.ctipolob, 0)
                WHEN 1
                   THEN UPPER (cconsultalob)
                ELSE TO_CLOB (UPPER (c.cconsulta))
             END
        INTO vconsulta
        FROM consultas c
       WHERE c.idconsulta = pidconsulta;

      vpasexec := 5;
      vparam := NULL;

      WHILE INSTR (vconsulta, 'PMT') > 0
      LOOP
         vpasexec := 7;
         vindex_i := INSTR (vconsulta, 'PMT');

         IF SUBSTR (vconsulta, vindex_i - 1, 1) <> '&'
         THEN
            vconsulta := SUBSTR (vconsulta, 3);
         ELSE
            vlength := INSTR (SUBSTR (vconsulta, vindex_i), ' ');

            IF vlength = 0
            THEN
               vparam_act :=
                  LTRIM (RTRIM (SUBSTR (vconsulta, vindex_i), CHR (10)),
                         CHR (10)
                        );
               vconsulta := NULL;
            ELSE
               vparam_act :=
                  LTRIM (RTRIM (SUBSTR (vconsulta, vindex_i, vlength - 1),
                                CHR (10)
                               ),
                         CHR (10)
                        );
               vconsulta := SUBSTR (vconsulta, vindex_i + vlength);
            END IF;

            IF NVL (INSTR (vparam, '&' || vparam_act || ';'), 0) = 0
            THEN
               vparam := vparam || '&' || vparam_act || ';';
               vnparam := vnparam + 1;
               vpasexec := 9;
               pparamimp (vnparam).par := vparam_act;
               vparam_act := UPPER (vparam_act);
               IF vparam_act = 'PMT_SSEGURO'
               THEN
                  pparamimp (vnparam).val := pinfoimp.sseguro;
               ELSIF vparam_act = 'PMT_NPOLIZA'
               THEN
                  pparamimp (vnparam).val := pinfoimp.npoliza;
               ELSIF vparam_act = 'PMT_NCERTIF'
               THEN
                  pparamimp (vnparam).val := pinfoimp.ncertif;
               ELSIF vparam_act = 'PMT_NMOVIMI'
               THEN
                  pparamimp (vnparam).val := pinfoimp.nmovimi;
               ELSIF vparam_act = 'PMT_NRECIBO'
               THEN
                  pparamimp (vnparam).val := pinfoimp.nrecibo;
               ELSIF vparam_act = 'PMT_IDIOMA'
               THEN
                  pparamimp (vnparam).val := pinfoimp.cidioma;
               ELSIF vparam_act = 'PMT_SPRODUC'
               THEN
                  pparamimp (vnparam).val := pinfoimp.sproduc;
               ELSIF vparam_act = 'PMT_NRIESGO'
               THEN
                  pparamimp (vnparam).val := pinfoimp.nriesgo;
               -- BUG 8290 - 19/03/2009 - SBG - Informem la provisió matemàtica, el capital
               -- a la mort i el capital mínim garantit.
               ELSIF vparam_act = 'PMT_IPROVAC'
               THEN
                  pparamimp (vnparam).val :=
                               REPLACE (TO_CHAR (pinfoimp.iprovac), ',', '.');
               ELSIF vparam_act = 'PMT_ICGARAC'
               THEN
                  pparamimp (vnparam).val :=
                               REPLACE (TO_CHAR (pinfoimp.icgarac), ',', '.');
               ELSIF vparam_act = 'PMT_ICFALLAC'
               THEN
                  pparamimp (vnparam).val :=
                              REPLACE (TO_CHAR (pinfoimp.icfallac), ',', '.');
               -- Bug 10199 - APD - 27/05/2009 - se añade el parametro NSINIES
               ELSIF vparam_act = 'PMT_NSINIES'
               THEN
                  pparamimp (vnparam).val := pinfoimp.nsinies;
               -- Bug 10199 - APD - 27/05/2009 - fin
               -- Bug 10684 - 21/12/2009 - AMC
               ELSIF vparam_act = 'PMT_CAGENTE'
               THEN
                  pparamimp (vnparam).val := pinfoimp.cagente;
               ELSIF vparam_act = 'PMT_CIDIOMA'
               THEN
                  pparamimp (vnparam).val := pinfoimp.cidioma;
               --Fi Bug 10684 - 21/12/2009 - AMC
               --BUG 12388 - JTS - 23/12/2009
               ELSIF vparam_act = 'PMT_STRAS'
               THEN
                  pparamimp (vnparam).val := pinfoimp.stras;
               --Fi BUG 12388
               --BUG 12693 - JTS - 04/02/2010
               ELSIF vparam_act = 'PMT_CDUPLICA'
               THEN
                  pparamimp (vnparam).val := pinfoimp.cduplica;
               --Fi BUG 12693
               --Bug 14775 13/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
               ELSIF vparam_act = 'PMT_SPROCES'
               THEN
                  /*IF pinfoimp.sproces IS NULL
                  THEN
                     SELECT sproces.NEXTVAL
                       INTO v_sproces
                       FROM DUAL;

                     pparamimp (vnparam).val := v_sproces;
                  ELSE*/
                     pparamimp (vnparam).val := pinfoimp.sproces;
                  --END IF;
               --BUG 16552 - JTS - 16/11/2010
               ELSIF vparam_act = 'PMT_NREEMB'
               THEN
                  pparamimp (vnparam).val := pinfoimp.nreemb;
               ELSIF vparam_act = 'PMT_NFACT'
               THEN
                  pparamimp (vnparam).val := pinfoimp.nfact;
               --Fi BUG 16552
               --bug 16446 - ETM - 31/12/2010
               ELSIF vparam_act = 'PMT_SIDEPAG'
               THEN
                  pparamimp (vnparam).val := pinfoimp.sidepag;
               ELSIF vparam_act = 'PMT_CCAUSIN'
               THEN
                  pparamimp (vnparam).val := pinfoimp.ccausin;
               ELSIF vparam_act = 'PMT_CMOTSIN'
               THEN
                  pparamimp (vnparam).val := NVL (pinfoimp.cmotsin, 0);
               --bug 19783 - ETM - 24/11/2011
               ELSIF vparam_act = 'PMT_NTRAMIT'
               THEN                                                  --ntramit
                  pparamimp (vnparam).val := NVL (pinfoimp.ntramit, 0);
               --bug 22760 - JTS - 18/07/2012
               ELSIF vparam_act = 'PMT_NDOCUME'
               THEN                                                  --ndocume
                  pparamimp (vnparam).val := NVL (pinfoimp.ndocume, 0);
               ELSIF vparam_act = 'PMT_CCOMPANI'
               THEN                                                 --ccompani
                  pparamimp (vnparam).val := pinfoimp.ccompani;
               -- bug 33886/209113 RACS inicio
               ELSIF vparam_act = 'PMT_NREFDEPOSITO'
               THEN                                   --referencia de deposito
                  pparamimp (vnparam).val := pinfoimp.refdeposito;
               -- bug 33886/209113 RACS fin
               -- CONF-578 JTS inicio
               ELSIF vparam_act = 'PMT_SPERSON'
               THEN
                  pparamimp (vnparam).val := pinfoimp.sperson;
               -- CONF-578 JTS fin
               -- INI - TCS_324B - JLTS - 11/02/2019. Se adiciona la opción PMT_CIDIOMAREP por parámetro
               ELSIF vparam_act = 'PMT_CIDIOMAREP'
               THEN
                  pparamimp (vnparam).val := pinfoimp.cidiomarep;
               -- INI - TCS_324B - JLTS - 11/02/2019.
			    -- INI - TCS_19 - ACL - 08/03/2019
               ELSIF vparam_act = 'PMT_SCONTGAR'
               THEN
                  pparamimp (vnparam).val := pinfoimp.scontgar;
               -- FIN - TCS_19 - ACL - 08/03/2019
               ELSE
                  RETURN 1000449;
               END IF;
            END IF;
         END IF;
      END LOOP;
      vpasexec := 11;

      IF pparamimp.COUNT = 0
      THEN
         pparamimp (1).par := 'PMT_VALOR';
         pparamimp (1).val := 0;
      END IF;

      --Informació general de la pòlissa.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      1000001,
                      f_axis_literales (1000001)
                     );
         RETURN 1000449;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, SQLCODE, SQLERRM || dbms_utility.format_error_backtrace);
         RETURN 1000449;
   END f_get_paramimp;

   /*************************************************************************
      Función que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      param in psseguro    : Assegurança a la que cal vincular la impressió.
      param in pnmovimi    : Moviment al que pertany la impressió.
      param in puser       : Usuari que realitza la gravació del document.
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in ptdesc      : Descripció del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error
   *************************************************************************/
   FUNCTION f_set_documgedox (
      psseguro     IN       NUMBER,
      pnmovimi     IN       NUMBER,
      puser        IN       VARCHAR2,
      ptfilename   IN       VARCHAR2,
      ptdesc       IN       VARCHAR2,
      pidcat       IN       NUMBER,
      piddoc       OUT      NUMBER,
      mensajes     IN OUT   t_iax_mensajes,
      dirpdfgdx    IN       VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
         :=    'psseguro: '
            || psseguro
            || ' - pnmovimi: '
            || pnmovimi
            || ' - puser: '
            || puser
            || ' - ptfilename: '
            || ptfilename
            || ' - ptdesc: '
            || ptdesc
            || ' - pidcat: '
            || pidcat
            || ' - dirpdfgdx: '
            || dirpdfgdx;
      vobject    VARCHAR2 (200)  := 'PAC_MD_IMPRESION.F_Set_DocumGedox';
      vterror    VARCHAR2 (1000);
      viddoc     NUMBER (8)      := 0;

      vfarchiv      date; --CONF 236 JAAB
      vfelimin      date; --CONF 236 JAAB
      vfcaduci      date; --CONF 236 JAAB

   BEGIN
      --Comprovació de parámetres d'entrada
      IF    psseguro IS NULL
         OR pnmovimi IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL
      THEN
         RAISE e_param_error;
      END IF;

        --INI JAAB CONF-236 22/08/2016
        vfarchiv := pac_md_gedox.F_CALCULA_FECHA_AEC(1);
        vfcaduci := pac_md_gedox.F_CALCULA_FECHA_AEC(2);
        vfelimin := pac_md_gedox.F_CALCULA_FECHA_AEC(3);
        --FIN JAAB CONF 236 22/08/2016

      vpasexec := 3;
      --Gravem la capçalera del document.
		--pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
		pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc, vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL OR NVL (viddoc, 0) = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fiter en qüestió.
      pac_axisgedox.actualiza_gedoxdb (ptfilename, viddoc, vterror, dirpdfgdx);

      IF vterror IS NOT NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      INSERT INTO docummovseg
                  (sseguro, nmovimi, iddocgedox
                  )
           VALUES (psseguro, pnmovimi, viddoc
                  );

      COMMIT;
      piddoc := viddoc;
      --Procés finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_documgedox;

   /*************************************************************************
      Función que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
     I inserta a la taula sin_tramita_documento amb iddoc del gedox
      param in psseguro    : Assegurança a la que cal vincular la impressió.
      param in pnmovimi    : Moviment al que pertany la impressió.
      param in puser       : Usuari que realitza la gravació del document.
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in ptdesc      : Descripció del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error
   *************************************************************************/
   -- Bug 17561 - APD - 14/02/2011 - si el documento es de siniestro, se debe
   -- guardar en la tabla SIN_TRAMITA_DOCUMENTO
   -- Para ello se crea la funcion f_set_documsinistresgedox
   FUNCTION f_set_documsinistresgedox (
      psseguro     IN       NUMBER,
      pnmovimi     IN       NUMBER,
      pnsinies     IN       NUMBER,
      pntramit     IN       NUMBER,
      pcdocume     IN       NUMBER,
      pcobliga     IN       NUMBER,
      puser        IN       VARCHAR2,
      ptfilename   IN       VARCHAR2,
      ptdesc       IN       VARCHAR2,
      pidcat       IN       NUMBER,
      piddoc       OUT      NUMBER,
      mensajes     IN OUT   t_iax_mensajes,
      dirpdfgdx    IN       VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)      := 1;
      vparam      VARCHAR2 (500)
         :=    'psseguro: '
            || psseguro
            || ' - pnmovimi: '
            || pnmovimi
            || ' - puser: '
            || puser
            || ' - ptfilename: '
            || ptfilename
            || ' - ptdesc: '
            || ptdesc
            || ' - pidcat: '
            || pidcat
            || ' - dirpdfgdx: '
            || dirpdfgdx;
      vobject     VARCHAR2 (200)
                               := 'PAC_MD_IMPRESION.F_Set_documsinistresgedox';
      vterror     VARCHAR2 (1000);
      viddoc      NUMBER (8)      := 0;
      v_ndocume   NUMBER;

      vfarchiv      date; --CONF 236 JAAB
      vfelimin      date; --CONF 236 JAAB
      vfcaduci      date; --CONF 236 JAAB
   BEGIN
      --Comprovació de parámetres d'entrada
      IF    psseguro IS NULL
         OR pnmovimi IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL
      THEN
         RAISE e_param_error;
      END IF;

        --INI JAAB CONF-236 22/08/2016
        vfarchiv := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(1);
        vfcaduci := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(2);
        vfelimin := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(3);
        --FIN JAAB CONF 236 22/08/2016

      vpasexec := 3;
      --Gravem la capçalera del document.
		--pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
		pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc, vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL OR NVL (viddoc, 0) = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fiter en qüestió.
      pac_axisgedox.actualiza_gedoxdb (ptfilename, viddoc, vterror, dirpdfgdx);

      IF vterror IS NOT NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      BEGIN
         SELECT NVL (MAX (ndocume) + 1, 0)
           INTO v_ndocume
           FROM sin_tramita_documento
          WHERE nsinies = pnsinies AND ntramit = pntramit;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_ndocume := 0;
      END;

      INSERT INTO sin_tramita_documento
                  (nsinies, ntramit, ndocume, cdocume, iddoc,
                   freclama, cobliga, corigen
                  )
           VALUES (pnsinies, pntramit, v_ndocume, pcdocume, viddoc,
                   TRUNC (f_sysdate), pcobliga, 1
                  );

      COMMIT;
      piddoc := viddoc;
      --Procés finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_documsinistresgedox;

    /*************************************************************************
      Función que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      param in psseguro    : Assegurança a la que cal vincular la impressió.
      param in pnrecibo    : Moviment al que pertany la impressió.
      param in puser       : Usuari que realitza la gravació del document.
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in ptdesc      : Descripció del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error
   *************************************************************************/
   FUNCTION f_set_documrecibogedox (
      psseguro     IN       NUMBER,
      pnrecibo     IN       NUMBER,
      puser        IN       VARCHAR2,
      ptfilename   IN       VARCHAR2,
      ptdesc       IN       VARCHAR2,
      pidcat       IN       NUMBER,
      piddoc       OUT      NUMBER,
      mensajes     IN OUT   t_iax_mensajes,
      dirpdfgdx    IN       VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
         :=    'psseguro: '
            || psseguro
            || ' - pnrecibo: '
            || pnrecibo
            || ' - puser: '
            || puser
            || ' - ptfilename: '
            || ptfilename
            || ' - ptdesc: '
            || ptdesc
            || ' - pidcat: '
            || pidcat
            || ' - dirpdfgdx: '
            || dirpdfgdx;
      vobject    VARCHAR2 (200)  := 'PAC_MD_IMPRESION.F_Set_documrecibogedox';
      vterror    VARCHAR2 (1000);
      viddoc     NUMBER (8)      := 0;

      vfarchiv      date; --CONF 236 JAAB
      vfelimin      date; --CONF 236 JAAB
      vfcaduci      date; --CONF 236 JAAB

   BEGIN
      --Comprovació de parámetres d'entrada
      IF    psseguro IS NULL
         OR pnrecibo IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL
      THEN
         RAISE e_param_error;
      END IF;

        --INI JAAB CONF-236 22/08/2016
        vfarchiv := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(1);
        vfcaduci := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(2);
        vfelimin := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(3);
        --FIN JAAB CONF 236 22/08/2016

      vpasexec := 3;
      --Gravem la capçalera del document.
		--pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
		pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc, vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL OR NVL (viddoc, 0) = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fiter en qüestió.
      pac_axisgedox.actualiza_gedoxdb (ptfilename, viddoc, vterror, dirpdfgdx);

      IF vterror IS NOT NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      INSERT INTO documrecibos
                  (sseguro, nrecibo, iddocgedox
                  )
           VALUES (psseguro, pnrecibo, viddoc
                  );

      COMMIT;
      piddoc := viddoc;
      --Procés finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_documrecibogedox;

   /*************************************************************************
      Impresión detalle documentación
      param in pcodplan    : Código plantilla
      param in pparamimp   : Parámetros de impresión de la plantilla
      param in ptfilename  : Nombre del fichero que se debe generar
      param in ncopias     : Número de copias.
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_detimprimir (
      pinfoimp     IN       ob_info_imp,
      pccodplan    IN       VARCHAR2,
      pparamimp    IN       pac_isql.vparam,
      ptfilename   IN       VARCHAR2,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN ob_iax_impresion
   IS
      vpasexec         NUMBER (8)                           := 1;
      vnumerr          NUMBER (8)                           := 0;
      vparam           VARCHAR2 (500)
                 := 'pcodplan: ' || pccodplan || ' ptfilename=' || ptfilename;
      vobject          VARCHAR2 (200)     := 'PAC_MD_IMPRESION.F_DetImprimir';
      vobj             ob_iax_impresion                := ob_iax_impresion
                                                                          ();
      vpath            VARCHAR2 (2000);
      vresult          NUMBER (10)                          := 0;
      vcodimp          NUMBER (10);
      vplantgedox      VARCHAR2 (1);
      ruta             VARCHAR2 (100);
      fichdestino      VARCHAR2 (100);
      vsinterf         NUMBER;
      vfilename        VARCHAR2 (100);
      -- BUG 9472 - 27/04/2009 - SBG - Els documents de la plantilla CRE019 s'han de cuardar a
      -- GEDOX amb la categoria "Qüestionari de salut" (categoria 2). Fins ara s'està passant
      -- sempre la categoria 1 hardcode, cal afegir una nova columna idcat a la taula codiplan-
      -- tillas i recuperar d'allà la categoria i passar-la a la crida a f_set_documgedox.
      v_idcat          NUMBER (8);
      -- BUG10167:DRA:20/05/2009:Inici
      v_cgenfich       NUMBER (1);
      v_cinforme       VARCHAR2 (100);
      v_extfich        VARCHAR2 (10);
      v_cgenpdf        NUMBER (1);
      -- BUG10167:DRA:20/05/2009:Fi
      --BUG11404 - JTS - 16/10/2009
      v_ptfilename     VARCHAR2 (100);
      v_vcinforme      VARCHAR2 (100);
      v_extfichout     VARCHAR2 (10);
      --Fi BUG11404 - JTS - 16/10/2009
      v_dirpdfgdx      VARCHAR2 (30);           --BUG17529 - JTS - 09/02/2011
      v_cdocume        sin_tramita_documento.cdocume%TYPE;
      -- Bug 17561 - APD - 14/02/2011
      v_cobliga        sin_tramita_documento.cobliga%TYPE;
      -- Bug 17561 - APD - 14/02/2011
      v_ntramit        sin_tramita_documento.ntramit%TYPE;
      -- Bug 17561 - APD - 14/02/2011
      v_ctipodoc       codiplantillas.ctipodoc%TYPE;
      -- Bug 17561 - APD - 24/02/2011 - se añade la columna ctipodoc
      w_cgenrep        NUMBER;                  --BUG19927 - JTS - 03/11/2011
      vdatasource      VARCHAR2 (250);          --BUG19927 - JTS - 03/11/2011
      vperror          VARCHAR2 (500);          --BUG19927 - JTS - 03/11/2011
      vtipodestino     VARCHAR2 (10);           --BUG19927 - JTS - 03/11/2011
      vfilename_ruta   VARCHAR2 (250);          --BUG19927 - JTS - 03/11/2011
      --BUG 21458 - JTS - 25/05/2012
      vinfo            ob_iax_info;
      vcfirma          NUMBER (1);
      vtconffirma      VARCHAR2 (100);
      w_cfdigital      VARCHAR2 (1);            --BUG21458 - JTS - 27/08/2012
      v_ndocume        NUMBER;
      v_calrecibo      recibos.nrecibo%TYPE;       --mantis 36181 nota 208582
   BEGIN
      vpasexec := 100;

      --Comprovació de parámetres d'entrada
      IF pccodplan IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 110;

      --Mirem si aquella plantilla ha d'anar al GEDOX o no, independentment del parinstalacion
      SELECT gedox, idcat, cgenfich, cgenpdf,
-- BUG10167:DRA:20/05/2009  -- BUG 11270 - 07/10/2009 - FAL - Parametritzacio de les impressions
                                             ctipodoc,
             -- Bug 17561 - APD - 24/02/2011 - se añade la columna ctipodoc
             cgenrep,                            --BUG19927 - JTS - 03/11/2011
                     UPPER (cfdigital)           --BUG21458 - JTS - 27/08/2012
        INTO vplantgedox, v_idcat, v_cgenfich, v_cgenpdf,
                                                         -- BUG10167:DRA:20/05/2009 -- FI Bug 11270 - 07/10/2009 - FAL
                                                         v_ctipodoc,
             -- Bug 17561 - APD - 24/02/2011 - se añade la columna ctipodoc
             w_cgenrep,                          --BUG19927 - JTS - 03/11/2011
                       w_cfdigital               --BUG21458 - JTS - 27/08/2012
        FROM codiplantillas
       WHERE ccodplan = pccodplan;

      vpasexec := 120;

      -- BUG14231:DRA:23/04/2010:Inici: Se quiere la descripción para GEDOX en el idioma del usuario que contrata
      -- Descripción del fichero
      SELECT dp.tdescrip
        INTO vobj.descripcion
        FROM detplantillas dp
       WHERE dp.ccodplan = pccodplan
         AND dp.cidioma =
                         NVL (pinfoimp.cidioma, pac_md_common.f_get_cxtidioma);

      vpasexec := 130;

      -- Descripción del fichero
      SELECT dp.cinforme                            -- BUG10167:DRA:20/05/2009
        INTO v_cinforme                             -- BUG10167:DRA:20/05/2009
        FROM detplantillas dp
       WHERE dp.ccodplan = pccodplan
         AND dp.cidioma =
                         NVL (pinfoimp.cidioma, pac_md_common.f_get_cxtidioma);

      --BUG 12850 - JTS - 08/02/2010 --pac_md_common.f_get_cxtidioma;
      vpasexec := 140;

--BUG21458 - JTS - 25/05/2012
      SELECT dp.cfirma, dp.tconffirma
        INTO vcfirma, vtconffirma
        FROM detplantillas dp
       WHERE dp.ccodplan = pccodplan
         AND dp.cidioma = pac_md_common.f_get_cxtidioma;

      vpasexec := 150;
      vobj.info_campos := t_iax_info ();
      vinfo := ob_iax_info ();
      vinfo.nombre_columna := 'CFIRMA';
      vinfo.valor_columna := vcfirma;
      vobj.info_campos.EXTEND;
      vobj.info_campos (vobj.info_campos.LAST) := vinfo;
      vinfo := ob_iax_info ();
      vinfo.nombre_columna := 'TCONFFIRMA';
      vinfo.valor_columna := vtconffirma;
      vobj.info_campos.EXTEND;
      vobj.info_campos (vobj.info_campos.LAST) := vinfo;
      vinfo := ob_iax_info ();
      vinfo.nombre_columna := 'CCODPLAN';
      vinfo.valor_columna := pccodplan;
      vobj.info_campos.EXTEND;
      vobj.info_campos (vobj.info_campos.LAST) := vinfo;
      vinfo := ob_iax_info ();
      vinfo.nombre_columna := 'GEDOX';
      vinfo.valor_columna := vplantgedox;
      vobj.info_campos.EXTEND;
      vobj.info_campos (vobj.info_campos.LAST) := vinfo;
      --BUG226099:FCA 29/05/2013
      vobj.info_campos.EXTEND;
      vinfo := ob_iax_info ();
      vinfo.nombre_columna := 'DIRECTORIO';
      vpasexec := 160;

      IF (v_cgenfich = 0)
      THEN
         vinfo.valor_columna :=
                           pac_md_common.f_get_parinstalacion_t ('PDFGENGDX');
      ELSE
         vinfo.valor_columna :=
                           pac_md_common.f_get_parinstalacion_t ('GEDOX_DIR');
      END IF;

      vpasexec := 170;
      vobj.info_campos (vobj.info_campos.LAST) := vinfo;
      --FIN BUG226099:FCA 29/05/2013

      --Fi BUG21458
      -- BUG14231:DRA:23/04/2010:Fi
      vpasexec := 180;
      -- BUG10167:DRA:20/05/2009:Inici
      v_extfich :=
               NVL (SUBSTR (v_cinforme, INSTR (v_cinforme, '.', -1) + 1),
                    'rtf');
      -- BUG10167:DRA:20/05/2009:Fi
      --BUG11404 - JTS - 16/10/2009
      v_vcinforme := SUBSTR (v_cinforme, 1, INSTR (v_cinforme, '.', -1) - 1);
      v_ptfilename := SUBSTR (ptfilename, 1, INSTR (ptfilename, '.', -1) - 1);
      --Fi BUG11404 - JTS - 16/10/2009
      vpasexec := 190;

      --Impresión de la plantilla
      IF v_cgenfich = 0
      THEN                                          -- BUG10167:DRA:20/05/2009
         vpasexec := 200;
         ruta := pac_md_common.f_get_parinstalacion_t ('PLANTI_C') || '\';
         vpasexec := 210;
         v_dirpdfgdx := pac_md_common.f_get_parinstalacion_t ('PDFGENGDX');
         --BUG17529 - JTS - 09/02/2011
         vfilename := v_cinforme;
      ELSE
         vpasexec := 220;

         --BUG19927 - JTS - 03/11/2011
         IF w_cgenrep = 1 OR LOWER (v_extfich) = 'csv'
         THEN
            vpasexec := 230;
            vresult :=
               pac_isql.gencon (pccodplan,
                                f_user,
                                pparamimp,
                                vcodimp,
                                1,
                                v_ptfilename
                               );
         --BUG11404 - JTS - 16/10/2009
         ELSIF w_cgenrep = 2
         THEN
            vpasexec := 240;
         ELSIF LOWER (v_extfich) = 'odt'
         THEN
            vpasexec := 250;
            vresult :=
               pac_isql.gencon (pccodplan,
                                f_user,
                                pparamimp,
                                vcodimp,
                                1,
                                v_ptfilename || '_content.xml'
                               );
         ELSE
            vpasexec := 260;
            vresult :=
               pac_isql.gencon (pccodplan,
                                f_user,
                                pparamimp,
                                vcodimp,
                                1,
                                ptfilename
                               );
         END IF;

         vpasexec := 270;

         --Fi BUG11404 - JTS - 16/10/2009
         IF vresult <> 0
         THEN
            --Registro el error producido en la impresión.
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_isql.gencon',
                         0,
                         vresult,
                         vresult
                        );
            RAISE e_object_error;
         END IF;

         vpasexec := 270;
         ruta := pac_md_common.f_get_parinstalacion_t ('INFORMES_SERV') || '\';
         --BUG19927 - JTS - 03/11/2011
         vpasexec := 280;

         IF w_cgenrep = 1 OR LOWER (v_extfich) = 'csv'
         THEN
            vfilename := v_ptfilename || '.csv';
         --BUG11404 - JTS - 16/10/2009
         ELSIF w_cgenrep = 2
         THEN
            vfilename := v_ptfilename || '.PDF';
         ELSIF LOWER (v_extfich) = 'odt'
         THEN
            vfilename := v_ptfilename || '_content.xml';
         ELSE
            vfilename := ptfilename;
         END IF;
      --Fi BUG11404 - JTS - 16/10/2009
      END IF;

      vpasexec := 290;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

      --BUG19927 - JTS - 03/11/2011
      IF w_cgenrep = 1 AND UPPER (v_extfich) != 'CSV'
      THEN
         vtipodestino := 'PDF';
         vpasexec := 300;
         vdatasource :=
               'CSV:'
            || pac_md_common.f_get_parinstalacion_t ('INFORMES_C')
            || '\'
            || vfilename;
         vpasexec := 310;
         vnumerr :=
            pac_md_listado.f_crida_llistats
                          (vsinterf,
                           -- bug 0035536 - 204090 JMF 07/05/2015 obtener empresa
                           NVL (pinfoimp.cempres,
                                pac_md_common.f_get_cxtempresa
                               ),
                           NULL,
                           NULL,
                           NULL,
                           1,
                           vtipodestino,
                              pac_md_common.f_get_parinstalacion_t ('PLANTI_C')
                           || '\'
                           || v_cinforme,
                           ruta || v_ptfilename || '.PDF',
                           vdatasource,
                           vperror,
                           mensajes
                          );

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         BEGIN
            vpasexec := 320;

            SELECT destino, nombre
              INTO vfilename_ruta, vfilename
              FROM int_detalle_doc
             WHERE sinterf = vsinterf;
         EXCEPTION
            WHEN OTHERS
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151632);
               RAISE e_object_error;
         END;
      ELSIF w_cgenrep = 2
      THEN
         vpasexec := 340;
         pac_int_online.p_inicializar_sinterf;
         vpasexec := 350;
         vsinterf := pac_int_online.f_obtener_sinterf;

         BEGIN
            IF pinfoimp.sseguro IS NOT NULL
            THEN
               vpasexec := 360;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PSSEGURO', 2, NULL, pinfoimp.sseguro, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.npoliza IS NOT NULL
            THEN
               vpasexec := 370;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNPOLIZA', 2, NULL, pinfoimp.npoliza, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.ncertif IS NOT NULL
            THEN
               vpasexec := 380;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNCERTIF', 2, NULL, pinfoimp.ncertif, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.nmovimi IS NOT NULL
            THEN
               vpasexec := 390;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNMOVIMI', 2, NULL, pinfoimp.nmovimi, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.sproduc IS NOT NULL
            THEN
               vpasexec := 400;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PSPRODUC', 2, NULL, pinfoimp.sproduc, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.nrecibo IS NOT NULL
            THEN
               vpasexec := 410;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNRECIBO', 2, NULL, pinfoimp.nrecibo, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.cidioma IS NOT NULL
            THEN
               vpasexec := 420;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PCIDIOMA', 2, NULL, pinfoimp.cidioma, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.nriesgo IS NOT NULL
            THEN
               vpasexec := 430;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNRIESGO', 2, NULL, pinfoimp.nriesgo, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.cempres IS NOT NULL
            THEN
               vpasexec := 440;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PCEMPRES', 2, NULL, pinfoimp.cempres, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.nsinies IS NOT NULL
            THEN
               vpasexec := 450;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNSINIES', 1, NULL, NULL, pinfoimp.nsinies,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.iprovac IS NOT NULL
            THEN
               vpasexec := 460;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PIPROVAC', 2, NULL, pinfoimp.iprovac, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.icgarac IS NOT NULL
            THEN
               vpasexec := 470;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PICGARAC', 2, NULL, pinfoimp.icgarac, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.icfallac IS NOT NULL
            THEN
               vpasexec := 480;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PICFALLAC', 2, NULL, pinfoimp.icfallac, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.nomfitxer IS NOT NULL
            THEN
               vpasexec := 490;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNOMFITXER', 1, NULL, NULL, pinfoimp.nomfitxer,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.stras IS NOT NULL
            THEN
               vpasexec := 500;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar, sinterf
                           )
                    VALUES ('PSTRAS', 2, NULL, pinfoimp.stras, NULL, vsinterf
                           );
            END IF;

            IF pinfoimp.cduplica IS NOT NULL
            THEN
               vpasexec := 510;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PCDUPLICA', 2, NULL, pinfoimp.cduplica, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.cagente IS NOT NULL
            THEN
               vpasexec := 520;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PCAGENTE', 2, NULL, pinfoimp.cagente, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.nreemb IS NOT NULL
            THEN
               vpasexec := 530;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNREEMB', 2, NULL, pinfoimp.nreemb, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.nfact IS NOT NULL
            THEN
               vpasexec := 540;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar, sinterf
                           )
                    VALUES ('PNFACT', 2, NULL, pinfoimp.nfact, NULL, vsinterf
                           );
            END IF;

            IF pinfoimp.sidepag IS NOT NULL
            THEN
               vpasexec := 550;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PSIDEPAG', 2, NULL, pinfoimp.sidepag, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.ccausin IS NOT NULL
            THEN
               vpasexec := 560;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PCCAUSIN', 2, NULL, pinfoimp.ccausin, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.cmotsin IS NOT NULL
            THEN
               vpasexec := 570;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PCMOTSIN', 2, NULL, pinfoimp.cmotsin, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.ntramit IS NOT NULL
            THEN
               vpasexec := 580;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNTRAMIT', 2, NULL, pinfoimp.ntramit, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.ndocume IS NOT NULL
            THEN
               vpasexec := 590;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNDOCUME', 2, NULL, pinfoimp.ndocume, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.sproces IS NOT NULL
            THEN
               vpasexec := 600;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PSPROCES', 2, NULL, pinfoimp.sproces, NULL,
                            vsinterf
                           );
            END IF;

            IF pinfoimp.ccompani IS NOT NULL
            THEN
               vpasexec := 610;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PCCOMPANI', 2, NULL, pinfoimp.ccompani, NULL,
                            vsinterf
                           );
            END IF;

            -- CONF-578
            IF pinfoimp.sperson IS NOT NULL
            THEN
               vpasexec := 610;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PSPERSON', 2, NULL, pinfoimp.sperson, NULL,
                            vsinterf
                           );
            END IF;
            -- CONF-578
            -- INI - TCS_324B - JLTS - 11/02/2019. Se adiciona la opción PMT_CIDIOMAREP por parámetro
            IF pinfoimp.cidiomarep IS NOT NULL
            THEN
               vpasexec := 620;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PCIDIOMAREP', 2, NULL, pinfoimp.cidiomarep, NULL,
                            vsinterf
                           );
            END IF;
            -- FIN - TCS_324B - JLTS - 11/02/2019. 
			-- INI - TCS_19 - ACL - 08/03/2019. Se adiciona la opción PMT_SCONTGAR por parámetro
            IF pinfoimp.scontgar IS NOT NULL
            THEN
               vpasexec := 620;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PSCONTGAR', 2, NULL, pinfoimp.scontgar, NULL,
                            vsinterf
                           );
            END IF;
            -- FIN - TCS_19 - ACL - 08/03/2019 
            			-- INI-CES-RAB IAXIS-3088
            IF pinfoimp.nsolici IS NOT NULL
            THEN
               vpasexec := 621;

               INSERT INTO lanzar_informes_params
                           (tparam, ctipo, fvalpar, nvalpar, tvalpar,
                            sinterf
                           )
                    VALUES ('PNSOLICI', 2, NULL, pinfoimp.nsolici, NULL,
                            vsinterf
                           );
            END IF;
            -- END-CES-RAB IAXIS-3088
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                            vparam,
                               'ERROR insert LANZAR_INFORMES_PARAMS'
                            || SQLCODE
                            || ' - '
                            || SQLERRM
                           );
         END;

         vpasexec := 620;
         vtipodestino := 'PDF';
         vdatasource := 'DB:';
         vpasexec := 630;
         vnumerr :=
            pac_md_listado.f_crida_llistats
                          (vsinterf,
                           pinfoimp.cempres,
                           NULL,
                           NULL,
                           NULL,
                           1,
                           vtipodestino,
                              pac_md_common.f_get_parinstalacion_t ('PLANTI_C')
                           || '\'
                           || v_cinforme,
                           ruta || v_ptfilename || '.PDF',
                           vdatasource,
                           vperror,
                           mensajes
                          );
      ELSIF UPPER (v_extfich) = 'CSV'
      THEN
         vpasexec := 640;
         vfilename_ruta :=
               pac_md_common.f_get_parinstalacion_t ('INFORMES_C')
            || '\'
            || vfilename;
         vfilename := vfilename;
         vpasexec := 650;
         v_dirpdfgdx := pac_md_common.f_get_parinstalacion_t ('INFORMES');
      --BUG11404 - JTS - 16/10/2009
      ELSIF v_cgenpdf = 1 AND UPPER (v_extfich) != 'ODT'
      THEN
         vpasexec := 660;
         fichdestino := SUBSTR (vfilename, 1, LENGTH (vfilename) - 3)
                        || 'pdf';
         -- Bug 21458/108087 - 23/02/2012 - AMC
         vpasexec := 670;
         vnumerr :=
            pac_md_con.f_convertir_documento
                                           (UPPER (v_extfich),
                                            'PDF',
                                            ruta || vfilename,
                                            ruta || fichdestino,
                                               f_parinstalacion_t ('PLANTI_C')
                                            || '\'
                                            || v_cinforme,
                                            vsinterf,
                                            w_cfdigital,
                                            NULL,
                                            NULL,
                                            NULL,
                                            mensajes
                                           );

         -- Fi Bug 21458/108087 - 23/02/2012 - AMC
         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         vfilename := fichdestino;
      ELSIF UPPER (v_extfich) = 'ODT'
      THEN
         vpasexec := 680;

         SELECT DECODE (v_cgenpdf, 1, 'PDF', 'ODT')
           INTO v_extfichout
           FROM DUAL;

         vpasexec := 690;
         fichdestino := v_ptfilename || '.' || v_extfichout;
         -- Bug 21458/108087 - 23/02/2012 - AMC
         vpasexec := 700;
         vnumerr :=
            pac_md_con.f_convertir_documento
                                            ('ODT_XML',
                                             v_extfichout,
                                             ruta || vfilename,
                                             ruta || fichdestino,
                                                f_parinstalacion_t ('PLANTI_C')
                                             || '\'
                                             || v_cinforme,
                                             vsinterf,
                                             w_cfdigital,
                                             NULL,
                                             NULL,
                                             NULL,
                                             mensajes
                                            );

         -- Fi Bug 21458/108087 - 23/02/2012 - AMC
         IF vnumerr <> 0
         THEN
            vpasexec := 10;
            RAISE e_object_error;
         END IF;

         vpasexec := 710;
         vfilename := fichdestino;
      END IF;

      --Fi BUG11404 - JTS - 16/10/2009
      vpasexec := 720;

      --Ruta de generación del fichero
      IF vfilename IS NOT NULL
      THEN
         --BUG19927 - JTS - 03/11/2011
         IF vfilename_ruta IS NOT NULL
         THEN
            vpasexec := 730;
            vobj.fichero := vfilename_ruta;
         ELSE
            vpasexec := 740;
            vobj.fichero := ruta || vfilename;
         END IF;

         IF     NVL (f_parinstalacion_t ('GEDOX_DIR'), 'X') <> 'X'
            AND pinfoimp.sseguro IS NOT NULL
            AND vplantgedox = 'S'
         THEN
            vpasexec := 750;
            -- Bug 17561 - APD - 14/02/2011 - si el documento es de siniestro, se debe
            -- guardar en la tabla SIN_TRAMITA_DOCUMENTO
            -- Para ello se crea la funcion f_set_documsinistresgedox
            vinfo := ob_iax_info ();
            vinfo.nombre_columna := 'IDDOC';

            IF v_ctipodoc = 2
            THEN
               --Pugem el document al servidor, i l'associem al sinistre.
               --Bug 33345 - JTT - 26/02/2015: Recuperem el ntramit del objecte i el codi de document (cdocume) corresponent a la plantilla.
               vpasexec := 760;
               v_ntramit := NVL (pinfoimp.ntramit, 0);

               BEGIN
                  vpasexec := 770;

                  SELECT cdocume
                    INTO v_cdocume
                    FROM doc_coddocumento
                   WHERE ccodplan = pccodplan;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  vobject,
                                  vpasexec,
                                  vparam,
                                     'Codi de document no trobat '
                                  || SQLCODE
                                  || ' - '
                                  || SQLERRM
                                 );
                     v_cdocume := 999;   -- Documento emitido desde siniestros
               END;

               v_cobliga := 0;

               -- ini Bug 0023615 - JMF - 18/09/2012
               DECLARE
                  v_aux       NUMBER;
                  v_ctramte   sin_tramite.ctramte%TYPE;
               BEGIN
                  vpasexec := 780;

                  SELECT COUNT (1)
                    INTO v_aux
                    FROM sin_tramitacion
                   WHERE nsinies = pinfoimp.nsinies AND ntramit = v_ntramit;

                  IF v_aux = 0
                  THEN
                     vpasexec := 790;

                     SELECT MIN (ntramit)
                       INTO v_ntramit
                       FROM sin_tramitacion
                      WHERE nsinies = pinfoimp.nsinies;
                  END IF;

                  v_aux := v_ntramit;

                  IF pac_sin_tramite.ff_hay_tramites (pinfoimp.nsinies) = 1
                  THEN
                     vpasexec := 800;

                     SELECT b.ctramte
                       INTO v_ctramte
                       FROM sin_tramitacion a, sin_tramite b
                      WHERE a.nsinies = pinfoimp.nsinies
                        AND a.ntramit = v_aux
                        AND b.nsinies = a.nsinies
                        AND b.ntramte = a.ntramte;

                     IF v_ctramte = 9999
                     THEN
                        vpasexec := 810;

                        -- Identificar la tramitacion del tramite convencional
                        SELECT MIN (ta.ntramit)
                          INTO v_ntramit
                          FROM sin_tramitacion ta, sin_tramite te
                         WHERE ta.nsinies = te.nsinies
                           AND ta.nsinies = pinfoimp.nsinies
                           AND ta.ntramte = te.ntramte
                           AND te.ctramte <> 9999;
                     END IF;
                  END IF;
               END;

               -- fin Bug 0023615 - JMF - 18/09/2012
               vpasexec := 820;
               vnumerr :=
                  f_set_documsinistresgedox (pinfoimp.sseguro,
                                             NVL (pinfoimp.nmovimi, 0),
                                             pinfoimp.nsinies,
                                             NVL (v_ntramit, 0),
                                             v_cdocume,
                                             v_cobliga,
                                             f_user,
                                             vfilename,
                                             vobj.descripcion,
                                             v_idcat,
                                             vinfo.valor_columna,
                                             mensajes,
                                             v_dirpdfgdx
                                            );
            ELSIF v_ctipodoc = 3
            THEN
               --Recibos
               --BUG22760 - JTS - 17/07/2012
               --Pugem el document al servidor
               vpasexec := 830;

               IF pinfoimp.nrecibo IS NOT NULL
               THEN
                  v_calrecibo := pinfoimp.nrecibo;
               ELSE
                  -- Si no tiene el recibo, asumo que viene de la emision póliza
                  vpasexec := 840;

                  SELECT MIN (nrecibo)
                    INTO v_calrecibo
                    FROM recibos
                   WHERE sseguro = pinfoimp.sseguro AND ctiprec = 0;
               END IF;

               vpasexec := 850;
               vnumerr :=
                  f_set_documrecibogedox (pinfoimp.sseguro,
                                          v_calrecibo,
                                          f_user,
                                          vfilename,
                                          vobj.descripcion,
                                          v_idcat,
                                          vinfo.valor_columna,
                                          mensajes,
                                          v_dirpdfgdx
                                         );
               vpasexec := 860;

               SELECT MAX (ndocume)
                 INTO v_ndocume
                 FROM recibo_documentos
                WHERE nrecibo = v_calrecibo AND iddoc = 0;

               IF v_ndocume IS NOT NULL
               THEN
                  vpasexec := 870;

                  UPDATE recibo_documentos
                     SET iddoc = vinfo.valor_columna
                   WHERE nrecibo = v_calrecibo AND ndocume = v_ndocume;

                  COMMIT;
               END IF;
            --Fi BUG22760
            ELSE
               -- Fin Bug 17561 - APD - 14/02/2011
               --Pugem el document al servidor, i l'associem al moviment.
               vpasexec := 880;
               vnumerr :=
                  f_set_documgedox (pinfoimp.sseguro,
                                    NVL (pinfoimp.nmovimi, 0),
                                    f_user,
                                    vfilename,
                                    vobj.descripcion,
                                    v_idcat,
                                    vinfo.valor_columna,
                                    mensajes,
                                    v_dirpdfgdx
                                   );
            -- FINAL BUG 9472 - 27/04/2009 - SBG
            END IF;

            vpasexec := 890;
            vobj.info_campos.EXTEND;
            vobj.info_campos (vobj.info_campos.LAST) := vinfo;

            IF vnumerr <> 0
            THEN
               RAISE e_object_error;
            END IF;
         END IF;
      ELSE
         vpasexec := 900;

         SELECT    f_user
                || '-'
                || TO_CHAR (NVL (MAX (i.nhasta), 0), 'fm00000000')
                || '-'
                || TO_CHAR (vcodimp, 'FM00000000')
                || '.'
                || v_extfich
           INTO vobj.fichero
           FROM informes i
          WHERE i.cusuari = f_user;
      END IF;

      RETURN vobj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_detimprimir;

   /*************************************************************************
      Impresión documentación
      param in pinfoimp    : Información para realizar la impresión
      param in pfefecto    : Fecha efecto
      param in pctipo      : Tipo documentación
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir (
      pinfoimp   IN       ob_info_imp,
      pfefecto   IN       DATE,
      pctipo     IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr       NUMBER (8)       := 0;
      vpasexec      NUMBER (8)       := 1;
      vparam        VARCHAR2 (500)
         :=    'psproduc: '
            || pinfoimp.sproduc
            || ' pfefecto: '
            || pfefecto
            || ' pctipo: '
            || pctipo;
      vobject       VARCHAR2 (200)   := 'PAC_MD_IMPRESION.F_Imprimir';
      vtfilename    VARCHAR2 (200);
      vparamimp     pac_isql.vparam;
      vt_obj        t_iax_impresion  := t_iax_impresion ();
      vobj          ob_iax_impresion := ob_iax_impresion ();
      viddoc        VARCHAR2 (100);
      vplantgedox   VARCHAR2 (1);

      CURSOR cr_imprimir (
         vcr_sproduc   IN   NUMBER,
         vcr_fefecto   IN   DATE,
         vcr_ctipo     IN   NUMBER
      )
      IS
         SELECT   p.ccodplan, cp.idconsulta, p.ccategoria, p.cdiferido
             FROM prod_plant_cab p, codiplantillas cp
            WHERE p.sproduc = vcr_sproduc
              AND vcr_fefecto BETWEEN fdesde AND NVL (fhasta, vcr_fefecto)
              AND p.ctipo = vcr_ctipo
              AND p.ccodplan = cp.ccodplan
         ORDER BY p.norden, p.ccodplan;

      v_ncopias     NUMBER;
      v_idcopia     VARCHAR2 (10);
   BEGIN
      --Comprovació de paràmetres
      IF pinfoimp.sproduc IS NULL OR pfefecto IS NULL OR pctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      FOR cr IN cr_imprimir (pinfoimp.sproduc, pfefecto, pctipo)
      LOOP
         --- BUG 10078 - 13/05/2009 - ICV - Modificación para pasar número de copias.         --Obtención del número de copias.
         v_ncopias :=
            pac_md_impresion.f_ncopias
                              (pinfoimp.sproduc,
                               pctipo,
                               cr.ccodplan,
                               pfefecto,
                               pinfoimp.sseguro,
                               pinfoimp.nmovimi, --BUG18463 - 05/05/2011 - JTS
                               pinfoimp.nrecibo, --BUG18463 - 05/05/2011 - JTS
                               pinfoimp.nsinies, --BUG18463 - 05/05/2011 - JTS
                               mensajes
                              );

         --- BUG 35540/204235 - 11/05/2015 - Mover validacion de copias al principio del for
         IF NVL (v_ncopias, 0) <> 0
         THEN
            --Obtenemos los parámetros necesarios para imprimir la plantilla.
            vnumerr := f_get_paramimp (cr.idconsulta, pinfoimp, vparamimp);
            --bug 16446 - ETM - 31/12/2010
            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            vpasexec := 5;

            --Impresión de documentación de póliza => nomenclatura específica
            IF pinfoimp.nomfitxer IS NOT NULL
            THEN
               vtfilename :=
                     pinfoimp.nomfitxer
                  || ' '
                  || cr.ccodplan
                  || '_'
                  || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
                  || '.rtf';
            ELSIF pinfoimp.npoliza IS NOT NULL
                  AND pinfoimp.nmovimi IS NOT NULL
            THEN
               vtfilename :=
                     pinfoimp.npoliza
                  || '_'
                  || pinfoimp.nmovimi
                  || '_'
                  || cr.ccodplan
                  || '_'
                  || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
                  || '.rtf';
            ELSE
               vtfilename :=
                     cr.ccodplan
                  || '_'
                  || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
                  || '.rtf';
            END IF;

            /* para cuando esten parametrizadas las plantillas de siniestros pagos por causa y motivo
             IF pinfoimp.sidepag IS NOT NULL THEN
                v_ncopias :=
                   pac_md_impresion.f_ncopias(pinfoimp.sproduc, pctipo, cr.ccodplan, pfefecto,
                                              pinfoimp.sseguro, pinfoimp.nmovimi,   --BUG18463 - 05/05/2011 - JTS
                                              pinfoimp.nrecibo,   --BUG18463 - 05/05/2011 - JTS
                                              pinfoimp.nsinies, mensajes);   --BUG18463 - 05/05/2011 - JTS

                IF NVL(v_ncopias, 0) <> 0 THEN
                   v_ncopias := pac_md_impresion.f_sinies_pago(cr.ccodplan, pinfoimp.sproduc,
                                                               pinfoimp.ccausin, pinfoimp.cmotsin,
                                                               mensajes);
                END IF;
             --ETM FIN
             ELSE*/--Impresión de la plantilla.
            vobj :=
               f_detimprimir (pinfoimp,
                              cr.ccodplan,
                              vparamimp,
                              vtfilename || v_idcopia,
                              mensajes
                             );

            -- FI BUG 10078  - 13/05/2009 – ICV
            IF vobj IS NULL
            THEN
               RAISE e_object_error;
            END IF;

            vnumerr := f_get_params (vobj, pinfoimp, pctipo, mensajes);

            IF vnumerr <> 0
            THEN
               RAISE e_object_error;
            END IF;

            vobj.ctipo := pctipo;
            vobj.ttipo :=
                  ff_desvalorfijo (317, pac_md_common.f_get_cxtidioma, pctipo);
            vobj.ccategoria := cr.ccategoria;
            vobj.cdiferido := cr.cdiferido;
            ---grabem al ob...tipus i valors
            vpasexec := 7;
            vt_obj.EXTEND;
            vt_obj (vt_obj.LAST) := vobj;
         END IF;
      --end loop;
      END LOOP;

      IF vt_obj IS NOT NULL
      THEN
         IF vt_obj.COUNT > 0
         THEN
            FOR cvt_obj IN vt_obj.FIRST .. vt_obj.LAST
            LOOP
               IF vt_obj.EXISTS (cvt_obj)
               THEN
                  vnumerr :=
                     f_obtener_valor_columna (vt_obj (cvt_obj).info_campos,
                                              'IDDOC',
                                              viddoc,
                                              mensajes
                                             );
                  vnumerr :=
                     f_obtener_valor_columna (vt_obj (cvt_obj).info_campos,
                                              'GEDOX',
                                              vplantgedox,
                                              mensajes
                                             );
               END IF;

               IF vplantgedox = 'S' AND viddoc IS NOT NULL
               THEN
                  vnumerr :=
                     pac_md_impresion.f_ins_doc (TO_NUMBER (viddoc),
                                                 vt_obj (cvt_obj).descripcion,
                                                 vt_obj (cvt_obj).fichero,
                                                 vt_obj (cvt_obj).ctipo,
                                                 vt_obj (cvt_obj).cdiferido,
                                                 vt_obj (cvt_obj).ccategoria,
                                                 pinfoimp.sseguro,
                                                 pinfoimp.nmovimi,
                                                 pinfoimp.nrecibo,
                                                 pinfoimp.nsinies,
                                                 pinfoimp.sidepag,
                                                 pinfoimp.sproces,
                                                 pinfoimp.cagente,
                                                 pinfoimp.cidioma,
                                                 NULL,
                                                 NULL,
                                                 mensajes
                                                );
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir;

/*************************************************************************
      Llena el objeto de información de impresión
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
--xpl 13092010 bug 15685
   FUNCTION f_get_params (
      pimprimir   IN OUT   ob_iax_impresion,
      pinfoimp    IN       ob_info_imp,
      pctipo      IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr      NUMBER (8)       := 0;
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (500)   := 'pctipo: ' || pctipo;
      vobject      VARCHAR2 (200)   := 'PAC_MD_IMPRESION.f_get_params';
      vtfilename   VARCHAR2 (200);
      vparamimp    pac_isql.vparam;
      vt_obj       t_iax_impresion  := t_iax_impresion ();
      vobj         ob_iax_impresion := ob_iax_impresion ();
      vinfo        ob_iax_info      := ob_iax_info ();
   BEGIN
      IF pimprimir.info_campos IS NULL
      THEN
         pimprimir.info_campos := t_iax_info ();
      END IF;

      IF pinfoimp.nrecibo IS NOT NULL
      THEN
         pimprimir.info_campos.EXTEND;
         vinfo.nombre_columna :=
                     f_axis_literales (100895, pac_md_common.f_get_cxtidioma);
         vinfo.valor_columna := pinfoimp.nrecibo;
         pimprimir.info_campos (pimprimir.info_campos.LAST) := vinfo;
      END IF;

      IF pinfoimp.npoliza IS NOT NULL
      THEN
         pimprimir.info_campos.EXTEND;
         vinfo.nombre_columna :=
                     f_axis_literales (800242, pac_md_common.f_get_cxtidioma);
         vinfo.valor_columna :=
                       pinfoimp.npoliza || ' - ' || NVL (pinfoimp.ncertif, 0);
         pimprimir.info_campos (pimprimir.info_campos.LAST) := vinfo;
      END IF;

      IF pinfoimp.stras IS NOT NULL
      THEN
         pimprimir.info_campos.EXTEND;
         vinfo.nombre_columna :=
                    f_axis_literales (9901212, pac_md_common.f_get_cxtidioma);
         vinfo.valor_columna := pinfoimp.stras;
         pimprimir.info_campos (pimprimir.info_campos.LAST) := vinfo;
      END IF;

      IF pinfoimp.nsinies IS NOT NULL
      THEN
         pimprimir.info_campos.EXTEND;
         vinfo.nombre_columna :=
                     f_axis_literales (100585, pac_md_common.f_get_cxtidioma);
         vinfo.valor_columna := pinfoimp.nsinies;
         pimprimir.info_campos (pimprimir.info_campos.LAST) := vinfo;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_params;

   /*************************************************************************
      Impresión justificante médico
      param in P_NREEMB    : Número de reembolso
      param in P_NFACT     : Número de factura
      param in P_NRIESGO   : Id. de riesgo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_factura (
      p_nreemb    IN       NUMBER,
      p_nfact     IN       NUMBER,
      p_nriesgo   IN       NUMBER,
      p_sseguro   IN       NUMBER,
      p_tipo      IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)      := 0;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (1000)
         :=    'P_NREEMB: '
            || p_nreemb
            || ' P_NFACT: '
            || p_nfact
            || ' P_NRIESGO: '
            || p_nriesgo;
      vobject        VARCHAR2 (200)  := 'PAC_MD_IMPRESION.F_Imprimir_Factura';
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
      vctipo         NUMBER;
   BEGIN
      --Comprovació de paràmetres
      IF    p_nreemb IS NULL
         OR p_nfact IS NULL
         OR p_nriesgo IS NULL
         OR p_sseguro IS NULL
         OR p_tipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vob_info_imp := f_get_infoimppol (p_sseguro, vctipo, 'POL', mensajes);
      vob_info_imp.nreemb := p_nreemb;
      vob_info_imp.nfact := p_nfact;
      vob_info_imp.nriesgo := p_nriesgo;
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);
      vpasexec := 4;

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
      --Si el reembolso está en estado GESTIÓN OFICINAS se actualizará a GESTIÓN COMPAÑÍA (sólo en este caso).
      vnumerr := pac_reembolsos.f_act_estado_reemb (p_nreemb);
      vpasexec := 6;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_factura;

   /*************************************************************************
      ImpresiÃ³n documentaciÃ³n generada en la contractaciÃ³n de una pÃ³liza
      param in psseguro    : CÃ³digo del seguro
      param in pcidioma    : CÃ³digo del idioma
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_documprod (
      psseguro   IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec           NUMBER (8)      := 1;
      vparam             VARCHAR2 (500)
                   := 'psseguro: ' || psseguro || ' - pcidioma: ' || pcidioma;
      vobject            VARCHAR2 (200) := 'PAC_MD_IMPRESION.F_Get_DocumProd';
      vestat             NUMBER (8);
      vob_info_imp       ob_info_imp;
      vt_obj             t_iax_impresion := t_iax_impresion ();
      v_emicol_propsup   NUMBER          := 0;

   BEGIN
      --ComprovaciÃ³ de parÃ¡metres d'entrada
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Comprovem l'estat en que es troba la pÃ²lissa
      vestat := f_situacion_poliza (psseguro);

	--Comprovamos si esta en propuesta de suplemento por tratarse de un colectivo
      --adminsitrado que al emitirlo crea un nuevo movimiento de apertura de suplemento
      IF vestat = 4
      THEN
         v_emicol_propsup := pac_seguros.f_emicol_propsup (psseguro);

         IF v_emicol_propsup = 1
         THEN
            vestat := 1;
         END IF;
      END IF;

      IF vestat IS NULL OR vestat = 2
      THEN
         --Comprovem que la pÃ²lissa no estigui anulÂ·lada, i que
         --no s'hagi produÃ¯t cap error al recuperar-ne l'estat
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000448);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --ObtenciÃ³ de la informaciÃ³ necessÃ ria per la impressiÃ³ (parÃ metres).
      vob_info_imp := f_get_infoimppol (psseguro, 0, 'POL', mensajes);

      IF vob_info_imp.sseguro <> psseguro
      THEN
         RAISE e_object_error;
      END IF;

      --Si se determinan especÃ­camente el idioma de la impresiÃ³n, lo aplicamos.
      --Si no se determina especÃ­ficamente, se aplicarÃ¡ el idioma de la pÃ³liza.
      IF pcidioma IS NOT NULL
      THEN
         vob_info_imp.cidioma := pcidioma;
      END IF;

      vpasexec := 7;

      --ImpressiÃ³ de la pÃ²lissa en funciÃ³ de l'estat d'aquesta.
      IF vestat = 1
      THEN
	   ----------------------------------------------------------------- conf-786 INICIO
		      v_emicol_propsup := pac_seguros.f_emicol_propsup (psseguro);
		 IF v_emicol_propsup = 141 THEN
			vt_obj := f_imprimir (vob_info_imp, f_sysdate, 107, mensajes);

		 ELSIF vob_info_imp.nmovimi = 1 OR v_emicol_propsup = 1
		 ------------------------------------------------------------------ conf-786 FIN
	  --  IF vob_info_imp.nmovimi = 1 OR v_emicol_propsup = 1
         THEN
            --PÃ²lissa Vigent => ImpressiÃ³ de la informaciÃ³ de la pÃ²lissa (Condicions Generals i Particulars).
            vt_obj := f_imprimir (vob_info_imp, f_sysdate, 0, mensajes);
         ELSE
            --PÃ²lissa Vigent => ImpressiÃ³ de la informaciÃ³ del suplement.
            vt_obj := f_imprimir (vob_info_imp, f_sysdate, 8, mensajes);
         END IF;
      ELSIF vestat = 3
      THEN
         --Proposta d'alta => ImpressiÃ³ pre-producciÃ³.
         vt_obj := f_imprimir (vob_info_imp, f_sysdate, 1, mensajes);
      ELSIF vestat = 4
      THEN
         --Proposta de suplement => ImpressiÃ³ pre-producciÃ³ suplements.
		  vt_obj := f_imprimir (vob_info_imp, f_sysdate, 12, mensajes);
		 -- Bug 16800 - 20/12/2010 - AMC
      ELSIF vestat = 5
      THEN
         vt_obj := f_imprimir (vob_info_imp, f_sysdate, 32, mensajes);
      -- Fi Bug 16800 - 20/12/2010 - AMC
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000448);
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_documprod;

   /*************************************************************************
      Visualización de un documento almacenado en GEDOX
      param in piddoc      : Id. del documento que se debe visualizar
      param out ptpath     : Ruta del fichero que se debe visualizar
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_gedox_verdoc (
      piddoc     IN       NUMBER,
      optpath    OUT      VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_MD_IMPRESION.F_Gedox_VerDoc';
      vparam        VARCHAR2 (500) := 'parámetros - piddoc: ' || piddoc;
      vpasexec      NUMBER (5)     := 0;
      vnumerr       NUMBER (8)     := 1;
      vempresa      NUMBER (8);
      vtfichero     VARCHAR2 (100);
      vtfichpath    VARCHAR2 (250);
      separator     CHAR;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF piddoc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      pac_axisgedox.verdoc (piddoc, vtfichero, vnumerr);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      pac_axisgedox.actualizacabecera_click (piddoc);
      COMMIT;
      vtfichpath := pac_md_common.f_get_parinstalacion_t ('INFORMES_SERV');
      vempresa := f_parinstalacion_n ('EMPRESADEF');
      separator := NVL (pac_md_common.f_get_parinstalacion_t ('SO_BBDD'), '\');
      vpasexec := 53;
      optpath := vtfichpath || separator || vtfichero;
      vpasexec := 55;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );
         RETURN 1;
   END f_gedox_verdoc;

       /*************************************************************************
      Impresión documentación generada en la contractación de una póliza por TIPO
      param in psseguro    : Código del seguro
      param in pctipo      : Tipo del documento
      param in pcidioma    : Código del idioma
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_documprod_tipo (
      psseguro   IN       NUMBER,
      pctipo     IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec        NUMBER (8)                   := 1;
      vparam          VARCHAR2 (500)
         :=    'psseguro: '
            || psseguro
            || ' - pctipo: '
            || TO_CHAR (pctipo)
            || ' - pcidioma: '
            || pcidioma;
      vobject         VARCHAR2 (200)
                                    := 'PAC_MD_IMPRESION.F_Get_DocumProd_tipo';
      vestat          NUMBER (8);
      vob_info_imp    ob_info_imp;
      vmail_agente    NUMBER                       := 0;
      v_mail          per_contactos.tvalcon%TYPE;
      vt_obj          t_iax_impresion              := t_iax_impresion ();
      v_res           NUMBER;
      v_retemail      NUMBER;
      v_filename      VARCHAR2 (2000);
      v_pruta         VARCHAR2 (2000);
      v_titulo_mail   VARCHAR2 (1000);
   BEGIN
      --Comprovació de parámetres d'entrada
      IF psseguro IS NULL OR pctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Comprovem l'estat en que es troba la pòlissa si no es del tipus 2 ni 3 ni 9
      -- Bug 15625 - 24/08/2010 - SRA - excluim que la validació sobre la situació de la pólissa es realitzi en cas de SINISTRE (22)
      --                                per tal que la documentació sempre s'emeti
      -- Bug 27744 - AGM900 - Producto de Explotaciones 2013 - 13-I-2014 - dlF
      -- Agragamos el tipo de ducocumento 48 - ACEPTAPROP   - Aceptación de propuesta
      -- Agregamos el tipo de documento 49 -- RECHAZARPROP --Rechazo de propuesta
      IF pctipo NOT IN (2, 3, 9, 22, 8, 37, 48, 49, 92)
      THEN
         --fin 27744 - AGM900 - Producto de Explotaciones 2013 - 13-I-2014 - dlF
         vestat := f_situacion_poliza (psseguro);

         IF (vestat IS NULL) --OR vestat = 2) -- IAXIS-2136 - ACL - 29/03/2019
				AND pctipo NOT IN (13, 72, 71)  
         THEN       -- salto la validación cuando pido un tipo ANULACION (13)
            --Comprovem que la pòlissa no estigui anul·lada, i que
            --no s'hagi produït cap error al recuperar-ne l'estat
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000448);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 5;

      --Obtenció de la informació necessària per la impressió (paràmetres).
      IF pctipo IN (3, 92)
      THEN
         vob_info_imp := f_get_infoimppol (psseguro, pctipo, 'EST', mensajes);
      ELSE
         vob_info_imp := f_get_infoimppol (psseguro, pctipo, 'POL', mensajes);
      END IF;

      IF vob_info_imp.sseguro <> psseguro
      THEN
         RAISE e_object_error;
      END IF;

      --Si se determinan especícamente el idioma de la impresión, lo aplicamos.
      --Si no se determina específicamente, se aplicará el idioma de la póliza.
      IF pcidioma IS NOT NULL AND pctipo <> 3
      THEN                                      --BUG 15032 - JTS - 21/06/2010
         vob_info_imp.cidioma := pcidioma;
      END IF;

      vpasexec := 7;

      -- JBN
      IF vestat = 4
      THEN
         --Proposta de suplement => Impressió pre-producció suplements.
         vt_obj := f_imprimir (vob_info_imp, f_sysdate, 12, mensajes);
      ELSE
         vt_obj := f_imprimir (vob_info_imp, f_sysdate, pctipo, mensajes);
      END IF;

      -- FIN -JBN

      --INI --BUG 33632/209087-- ETM  --03/07/2015--
      vmail_agente :=
         pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                        'CORREO_AGENTE'
                                       );

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            IF (pctipo = 67 AND vmail_agente = 1 AND vt_obj (i).cdiferido = 2
               )
            THEN
               v_mail := f_mail_agente (psseguro, mensajes);
               v_titulo_mail :=
                    f_axis_literales (9908270, pac_md_common.f_get_cxtidioma);
               v_res :=
                  pac_util.f_path_filename (vt_obj (i).fichero,
                                            v_pruta,
                                            v_filename
                                           );
               v_retemail :=
                  pac_md_informes.f_enviar_mail (NULL,
                                                 v_mail,
                                                 NULL,
                                                 v_filename,
                                                 v_titulo_mail,
                                                 NULL,
                                                 NULL,
                                                 NULL
                                                );
            END IF;
         END LOOP;
      END IF;

      --FIN --BUG 33632/209087-- ETM  --03/07/2015--
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_documprod_tipo;

   /*************************************************************************
      Impresión del cuestionario de salud por SSEGURO y NRIESGO
      param in psseguro   : Código interno del seguro
      param in pnriesgo   : Número del riesgo
      param in pnomfitxer : Nombre del fichero
      param in pmodo      : Modo EST o POL
      param out mensajes  : mensajes de error
      return              : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_questsalud (
      psseguro     IN       NUMBER,
      pnriesgo     IN       NUMBER,
      pnomfitxer   IN       VARCHAR2,
      pmodo        IN       VARCHAR2,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (500)
         :=    'psseguro: '
            || psseguro
            || ', pnriesgo: '
            || pnriesgo
            || ' pnomfitxer:'
            || pnomfitxer
            || ' pmodo:'
            || pmodo;
      vobject        VARCHAR2 (200)  := 'PAC_MD_IMPRESION.F_Get_QuestSalud';
      vestat         NUMBER (8);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion := t_iax_impresion ();
   BEGIN
      --Comprovació de parámetres d'entrada
      IF psseguro IS NULL OR pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vob_info_imp := f_get_infoimppol (psseguro, 2, pmodo, mensajes);
      vpasexec := 3;
      vob_info_imp.nomfitxer := pnomfitxer;
      vob_info_imp.nriesgo := pnriesgo;
      vpasexec := 4;
      vt_obj := f_imprimir (vob_info_imp, f_sysdate, 2, mensajes);
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_questsalud;

    /*************************************************************************
      Devuelve el número de copias a generar.
      param in psproduc    : Código del producto
      param in pctipo      : Tipo de impresion
      param in pccodplan   : Código de plantilla
      param in pfdesde     : Fecha de vigencia
      param in psseguro    : Código de seguro
      param out mensajes   : mensajes de error
      return               : Número de copias en caso de error retorna 1 y el mensaje de error en el objeto mensajes.

       -- BUG 10078 - 13/05/2009 - ICV - 0010078: IAX - Adaptación impresiones (plantillas)
   *************************************************************************/
   FUNCTION f_ncopias (
      psproduc    IN       NUMBER,
      pctipo      IN       NUMBER,
      pccodplan   IN       VARCHAR2,
      pfdesde     IN       DATE,
      psseguro    IN       NUMBER,
      pnmovimi    IN       NUMBER,               --BUG18463 - 05/05/2011 - JTS
      pnrecibo    IN       NUMBER,               --BUG18463 - 05/05/2011 - JTS
      pnsinies    IN       NUMBER,               --BUG18463 - 05/05/2011 - JTS
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec       NUMBER                        := 1;
      vparam         VARCHAR2 (1000)
         :=    'psproduc: '
            || psproduc
            || ', pctipo: '
            || pctipo
            || ' pccodplan:'
            || pccodplan
            || ' pfdesde:'
            || pfdesde
            || ' psseguro: '
            || psseguro
            || ' pnmovimi: '
            || pnmovimi
            || ' pnrecibo: '
            || pnrecibo
            || ' pnsinies: '
            || pnsinies;
      vobject        VARCHAR2 (200)            := 'PAC_MD_IMPRESION.F_ncopias';
      vestat         NUMBER;
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion               := t_iax_impresion ();
      vnumero        NUMBER;
      lsentencia     VARCHAR2 (400);
      v_tcopias      prod_plant_cab.tcopias%TYPE;
   BEGIN
      --Comprovació de parámetres d'entrada
      IF    psproduc IS NULL
         OR pctipo IS NULL
         OR pccodplan IS NULL
         OR pfdesde IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         SELECT tcopias
           INTO v_tcopias
           FROM prod_plant_cab
          WHERE sproduc = psproduc
            AND ctipo = pctipo
            AND ccodplan = pccodplan
            AND (pfdesde >= fdesde AND (fhasta IS NULL OR pfdesde <= fhasta)
                );
      EXCEPTION
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 107810);
            RAISE e_object_error;
      END;

      BEGIN
         IF v_tcopias IS NULL
         THEN
            RETURN 1;
         ELSE
            vnumero := TO_NUMBER (v_tcopias);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            lsentencia :=
                  'begin :vnumero:= '
               || v_tcopias
               || ' ('
               || psproduc
               || ','
               || pctipo
               || ','''
               || pccodplan
               || ''','''
               || pfdesde
               || ''','
               || psseguro
               || ','
               || NVL (TO_CHAR (pnmovimi), 'null')
               || ','
               || NVL (TO_CHAR (pnrecibo), 'null')
               || ','
               || NVL (TO_CHAR (pnsinies), 'null')
               || '); end;';

            EXECUTE IMMEDIATE lsentencia
                        USING OUT vnumero;
      END;

      RETURN vnumero;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_ncopias;

   --BUG 10233 - JTS - 04/06/2009
   /*************************************************************************
      Impresión carta de impago
      param in P_SGESCARTA : ID. de la carta
      param in p_sdevolu   : ID. devolucion
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
      -- Bug 0022030 - 23/04/2012 - JMF
   *************************************************************************/
   FUNCTION f_imprimir_carta (
      p_sgescarta   IN       NUMBER,
      p_sdevolu     IN       NUMBER,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)       := 0;
      vpasexec       NUMBER (8)       := 1;
      vparam         VARCHAR2 (500)
              := 'p_sgescarta: ' || p_sgescarta || ' p_sdevolu=' || p_sdevolu;
      vobject        VARCHAR2 (200)   := 'PAC_MD_IMPRESION.F_Imprimir_Carta';
      v_ccodplan     VARCHAR2 (20);
      vtfilename     VARCHAR2 (200);
      vparamimp      pac_isql.vparam;
      vt_obj         t_iax_impresion  := t_iax_impresion ();
      vobj           ob_iax_impresion := ob_iax_impresion ();
      vcount         NUMBER           := 0;
      vob_info_imp   ob_info_imp;
      pinfo          t_iax_info;
      v_idgedox      NUMBER;

      CURSOR c1
      IS
         SELECT DISTINCT p.ccodplan, tc.ctipcar, s.cempres, s.sseguro,
                         gc.nrecibo, gc.sgescarta, gc.sdevolu
                    FROM prod_plant_cab p,
                         codiplantillas cp,
                         seguros s,
                         gescartas gc,
                         tiposcarta tc
                   WHERE (   (    p_sgescarta IS NOT NULL
                              AND gc.sgescarta = p_sgescarta
                             )
                          OR (p_sdevolu IS NOT NULL AND gc.sdevolu = p_sdevolu
                             )
                         )
                     AND s.sseguro = gc.sseguro
                     AND gc.ctipcar = tc.ctipcar
                     AND tc.ccodplan = p.ccodplan
                     AND p.sproduc = s.sproduc
                     AND f_sysdate BETWEEN fdesde AND NVL (fhasta, f_sysdate)
                     AND p.ctipo = 20
                     AND p.ccodplan = cp.ccodplan
                     AND gc.cestado <> 3;
   BEGIN
      vpasexec := 2;
      vpasexec := 3;

      FOR f1 IN c1
      LOOP
         --Obtenemos los parámetros necesarios para imprimir la plantilla.
         vparamimp (1).par := 'PMT_SGESCARTA';
         vparamimp (1).val := f1.sgescarta;
         -- Bug 0022030 - 23/04/2012 - JMF
         vparamimp (2).par := 'PMT_SDEVOLU';
         vparamimp (2).val := f1.sdevolu;
         v_ccodplan := f1.ccodplan;
         vparamimp (3).par := 'PMT_CTIPCAR';
         vparamimp (3).val := f1.ctipcar;
         --Impresión de la carta
         vtfilename :=
               p_sgescarta
            || '_'
            || p_sdevolu
            || '_'
            || v_ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '.rtf';
         vpasexec := 4;
         -- bug 0035536 - 204090 JMF 07/05/2015 obtener empresa
         -- Informacion necesaria para impresion y para gedox
         vob_info_imp.cempres := f1.cempres;
         vob_info_imp.sseguro := f1.sseguro;
         vob_info_imp.nrecibo := f1.nrecibo;
         --Impresión de la plantilla.
         vpasexec := 5;
         vobj :=
            f_detimprimir (vob_info_imp,
                           v_ccodplan,
                           vparamimp,
                           vtfilename,
                           mensajes
                          );

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         pinfo := vobj.info_campos;

         FOR vinfo IN pinfo.FIRST .. pinfo.LAST
         LOOP
            IF pinfo.EXISTS (vinfo)
            THEN
               IF UPPER (pinfo (vinfo).nombre_columna) = 'IDDOC'
               THEN
                  v_idgedox := pinfo (vinfo).valor_columna;
               END IF;
            END IF;
         END LOOP;

         IF (v_idgedox <> 0)
         THEN
            UPDATE gescartas
               SET iddocgedox = v_idgedox
             WHERE sgescarta = f1.sgescarta;
         END IF;

         vpasexec := 7;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
         vcount := vcount + 1;
      END LOOP;

      IF vcount = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9904597);
         RAISE e_object_error;
      END IF;

      vpasexec := 8;
      --Si todo ok se marca la carta como impresa
      vnumerr :=
               pac_cartas_impagados.f_marcar_gescarta (p_sgescarta, p_sdevolu);
      vpasexec := 9;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_carta;

--Fi BUG 10233 - JTS - 04/06/2009

   --BUG 10729 - JTS - 12/08/2009
   /*************************************************************************
      Impresión recibos
      param in P_SPROIMP   : ID. del lote de recibos a imprimir
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_recibos (
      p_sproimp   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr      NUMBER (8)       := 0;
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (500)   := 'p_sproimp: ' || p_sproimp;
      vobject      VARCHAR2 (200)   := 'PAC_MD_IMPRESION.F_Imprimir_Recibos';
      v_ccodplan   VARCHAR2 (20)    := 'APRA009';
      vtfilename   VARCHAR2 (200);
      vparamimp    pac_isql.vparam;
      vt_obj       t_iax_impresion  := t_iax_impresion ();
      vobj         ob_iax_impresion := ob_iax_impresion ();

      CURSOR c1
      IS                                     --Bug.: 14837 - 16/06/2010 - ICV
         SELECT DISTINCT s.cidioma
                    FROM tmp_recgestion tr, recibos r, seguros s
                   WHERE tr.sproimp = p_sproimp
                     AND tr.cestado = 1
                     AND tr.nrecibo = r.nrecibo
                     AND r.sseguro = s.sseguro;
   BEGIN
      vpasexec := 2;
      --Obtenemos los parámetros necesarios para imprimir la plantilla.
      vparamimp (1).par := 'PMT_SPROIMP';
      vparamimp (1).val := p_sproimp;
      vparamimp (2).par := 'PMT_IDIOMA';

      FOR rc IN c1
      LOOP
         vparamimp (2).val := rc.cidioma;
         vpasexec := 3;
         --Impresión de la carta
         vtfilename :=
               p_sproimp
            || '_'
            || v_ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '_'
            || rc.cidioma
            || '.rtf';
         --Impresión de la plantilla.
         vobj :=
             f_detimprimir (NULL, v_ccodplan, vparamimp, vtfilename, mensajes);

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
         vpasexec := 8;
      END LOOP;

      --Si todo ok se marcan los recibos como impresos
      vnumerr :=
         pac_gestion_rec.f_impresion_recibos_man
                                               (p_sproimp,
                                                pac_md_common.f_get_cxtidioma,
                                                vtfilename,
                                                0
                                               );
      vpasexec := 9;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_recibos;

--Fi BUG 10729 - JTS - 12/08/2009
   FUNCTION f_get_listcomi (
      pcempres     IN       NUMBER,
      pcproces     IN       NUMBER,
      pcagente     IN       NUMBER,
      pnomfitxer   IN       VARCHAR2,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)       := 0;
      vpasexec       NUMBER (8)       := 1;
      vparam         VARCHAR2 (500)
         :=    'pcempres: '
            || pcempres
            || ', pcproces: '
            || pcproces
            || ' pcagente:'
            || pcagente
            || ' pnomfitxer:'
            || pnomfitxer;
      vobject        VARCHAR2 (200)   := 'PAC_MD_IMPRESION.F_Get_ListComi';
      vestat         NUMBER (8);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion  := t_iax_impresion ();
      vobj           ob_iax_impresion := ob_iax_impresion ();
      v_ccodplan     VARCHAR2 (10)    := 'APRA010';
      vtfilename     VARCHAR2 (200);
      vparamimp      pac_isql.vparam;
      num_err        NUMBER;
   BEGIN
      --Comprovació de parámetres d'entrada
      IF pcempres IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vob_info_imp.nomfitxer := pnomfitxer;
      vob_info_imp.nriesgo := 0;
      vpasexec := 4;
      --vt_obj := f_imprimir_ListComi(vob_info_imp, f_sysdate, 3, mensajes);
      vpasexec := 2;
      --Obtenemos los parámetros necesarios para imprimir la plantilla.
      vparamimp (1).par := 'PMT_CEMPRES';
      vparamimp (1).val := pcempres;
      vparamimp (2).par := 'PMT_CPROCES';
      vparamimp (2).val := pcproces;
      -- Bug 10684 - 21/12/2009 - AMC
      vparamimp (3).par := 'PMT_CAGENTE';

      IF pcagente IS NULL
      THEN
         vparamimp (3).val := 'null';
      ELSE
         vparamimp (3).val := pcagente;
      END IF;

      vpasexec := 3;

      -- Si el agente es null lanzamos 2 veces el informe, uno para cada idioma
      IF pcagente IS NULL
      THEN
         --Impresión de documentación de póliza => nomenclatura específica
         vtfilename :=
               v_ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '.rtf';
         vpasexec := 4;
         vparamimp (4).par := 'PMT_CIDIOMA';
         vparamimp (4).val := 6;                                     --Frances
         --Impresión de la plantilla.
         vobj :=
             f_detimprimir (NULL, v_ccodplan, vparamimp, vtfilename, mensajes);

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
         vpasexec := 8;
         --Impresión de documentación de póliza => nomenclatura específica
         vtfilename :=
               v_ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '.rtf';
         vpasexec := 4;
         vparamimp (4).par := 'PMT_CIDIOMA';
         vparamimp (4).val := 7;                                    --Holandes
         --Impresión de la plantilla.
         vobj :=
             f_detimprimir (NULL, v_ccodplan, vparamimp, vtfilename, mensajes);

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 9;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
         vpasexec := 10;
      ELSE
         vparamimp (4).par := 'PMT_CIDIOMA';
         num_err :=
                   pac_persona.f_get_idioma_age (pcagente, vparamimp (4).val);
         vtfilename :=
               v_ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '.rtf';

         IF vparamimp (4).val IS NULL
         THEN
            vparamimp (4).val := f_usu_idioma;
         END IF;

         --Impresión de la plantilla.
         vobj :=
             f_detimprimir (NULL, v_ccodplan, vparamimp, vtfilename, mensajes);

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 11;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
         vpasexec := 12;
      END IF;

      --2do listado--
      v_ccodplan := 'APRA012';

      -- Si el agente es null lanzamos 2 veces el informe, uno para cada idioma
      IF pcagente IS NULL
      THEN
         --Impresión de documentación de póliza => nomenclatura específica
         vtfilename :=
               v_ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '.rtf';
         vpasexec := 4;
         vparamimp (4).par := 'PMT_CIDIOMA';
         vparamimp (4).val := 6;                                     --Frances
         --Impresión de la plantilla.
         vobj :=
             f_detimprimir (NULL, v_ccodplan, vparamimp, vtfilename, mensajes);

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
         vpasexec := 8;
         --Impresión de documentación de póliza => nomenclatura específica
         vtfilename :=
               v_ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '.rtf';
         vpasexec := 4;
         vparamimp (4).par := 'PMT_CIDIOMA';
         vparamimp (4).val := 7;                                    --Holandes
         --Impresión de la plantilla.
         vobj :=
             f_detimprimir (NULL, v_ccodplan, vparamimp, vtfilename, mensajes);

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 9;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
         vpasexec := 10;
      ELSE
         vtfilename :=
               v_ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '.rtf';
         vparamimp (4).par := 'PMT_CIDIOMA';
         num_err := pac_persona.f_get_idioma_age (pcagente, vparamimp (4).val);

         IF vparamimp (4).val IS NULL
         THEN
            vparamimp (4).val := f_usu_idioma;
         END IF;

         --Impresión de la plantilla.
         vobj :=
             f_detimprimir (NULL, v_ccodplan, vparamimp, vtfilename, mensajes);

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 11;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
         vpasexec := 12;
      END IF;

      --Fi Bug 10684 - 21/12/2009 - AMC
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_listcomi;

   /*************************************************************************
      --BUG12388 - JTS - 23/12/2009
      Impresión traspasos
      param in P_STRAS     : ID. del traspaso a imprimir
      param in P_SSEGURO   : ID. del seguro
      param in P_TIPO      : tipo traspaso, "TRAS/REV" (Traspaso o revocación)
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_traspas (
      p_stras     IN       NUMBER,
      p_sseguro   IN       NUMBER,
      p_tipo      IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)      := 0;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (500)
         :=    'p_stras: '
            || p_stras
            || ' p_sseguro: '
            || p_sseguro
            || ' p_tipo: '
            || p_tipo;
      vobject        VARCHAR2 (200)  := 'PAC_MD_IMPRESION.f_imprimir_traspas';
      vctipo         NUMBER (2);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vob_info_imp := f_get_infoimppol (p_sseguro, vctipo, 'POL', mensajes);
      vob_info_imp.stras := p_stras;
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_traspas;

   /*************************************************************************
      --BUG12850 - JTS - 08/02/2010
      F_GET_TIPO
      param in PTTIPO      : Tipus de la plantilla
      return               : Ctipo de la plantilla
   *************************************************************************/
   FUNCTION f_get_tipo (pttipo VARCHAR2)
      RETURN NUMBER
   IS
      vctipo   NUMBER;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM cfg_plantillas_tipos
       WHERE ttipo = pttipo;

      RETURN vctipo;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_MD_IMPRESION.f_get_tipo',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN NULL;
   END f_get_tipo;

   /*************************************************************************
      --BUG13288 - JTS - 23/02/2010
      Impresión recibo
      param in P_NRECIBO   : ID. NRECIBO
      param in P_SSEGURO   : ID. del seguro
      param in P_TIPO      : ctipo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_recibo (
      p_nrecibo   IN       NUMBER,
      p_ndocume   IN       NUMBER,
      p_sseguro   IN       NUMBER,
      p_tipo      IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)      := 0;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (500)
         :=    'p_nrecibo: '
            || p_nrecibo
            || ' p_sseguro: '
            || p_sseguro
            || ' p_tipo: '
            || p_tipo;
      vobject        VARCHAR2 (200)  := 'PAC_MD_IMPRESION.f_imprimir_recibo';
      vctipo         NUMBER (2);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vob_info_imp := f_get_infoimppol (p_sseguro, vctipo, 'POL', mensajes);
      vob_info_imp.nrecibo := p_nrecibo;
      vob_info_imp.ndocume := p_ndocume;
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'AVISOREIMPREC'
                                            ),
              0
             ) = 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9904561);
      END IF;

      --BUG24687 -JTS- 27/11/2012 Tipo de impresión con actualización de estado
      IF vctipo = 40
      THEN
         UPDATE recibos
            SET cestimp = 2
          WHERE nrecibo = p_nrecibo;

         COMMIT;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_recibo;

   /*************************************************************************
      --BUG13288 - JTS - 23/02/2010
      F_GET_CDUPLICA
      param in PCTIPO      : Tipus de la plantilla
      return               : CDUPLICA de la plantilla
   *************************************************************************/
   FUNCTION f_get_cduplica (pctipo NUMBER)
      RETURN NUMBER
   IS
      vcduplica   NUMBER;
   BEGIN
      SELECT cduplica
        INTO vcduplica
        FROM cfg_plantillas_tipos
       WHERE ctipo = pctipo;

      RETURN vcduplica;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_MD_IMPRESION.f_get_cduplica',
                      1,
                      'pctipo=' || pctipo,
                      SQLCODE || '-' || SQLERRM
                     );
         RETURN NULL;
   END f_get_cduplica;

   --BUG 16446 - ETM - 31/12/2010

   /*************************************************************************
       F_sinies_pago
       param in psproduc    : Código del producto
     param in p_ccodplan   : Código de plantilla
     param in  p_ccausin : causa del siniestro
    param in p_cmotsin : motivo del siniestro
      return               : Ctipo de la plantilla
   *************************************************************************/
   FUNCTION f_sinies_pago (
      p_ccodplan   IN       VARCHAR2,
      psproduc     IN       NUMBER,
      p_ccausin    IN       NUMBER,
      p_cmotsin    IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vccodplan   NUMBER;
   BEGIN
      IF p_ccausin = 14
      THEN
         SELECT COUNT (*)
           INTO vccodplan
           FROM plantillas_sinies_pago
          WHERE ccodplan = p_ccodplan
            AND sproduc = psproduc
            AND ccausin = p_ccausin;
      ELSE
         SELECT COUNT (*)
           INTO vccodplan
           FROM plantillas_sinies_pago
          WHERE ccodplan = p_ccodplan
            AND sproduc = psproduc
            AND ccausin = p_ccausin
            AND cmotsin = p_cmotsin;
      END IF;

      RETURN vccodplan;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_MD_IMPRESION.f_sinies_pago',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN NULL;
   END f_sinies_pago;

/*************************************************************************
   Impresión  PAGOS
   param in p_sseguro    : id de seguro
    param in P_SIDEGAP   : ID. DE PAGOS A  imprimir
    param in P_TIPO      : ctipo plantillas
    param in  p_ccausin : causa del siniestro
    param in p_cmotsin : motivo del siniestro
   param out mensajes   : mensajes de error
   return               : objeto rutas ficheros
*************************************************************************/
   FUNCTION f_imprimir_pago (
      p_sseguro   IN       NUMBER,
      p_sidepag   IN       NUMBER,
      p_tipo      IN       VARCHAR,
      p_ccausin   IN       NUMBER,
      p_cmotsin   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (1000)
         :=    'P_sseguro: '
            || p_sseguro
            || ' P_sidepag: '
            || p_sidepag
            || ' p_tipo: '
            || p_tipo
            || ' p_ccausin: '
            || p_ccausin
            || ' p_cmotsin: '
            || p_cmotsin;
      vobject        VARCHAR2 (200)  := 'PAC_MD_IMPRESION.f_imprimir_pago';
      vctipo         NUMBER (2);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN
      --Comprovació de paràmetres
      IF    p_sseguro IS NULL
         OR p_sidepag IS NULL
         OR p_tipo IS NULL
         OR p_ccausin IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vob_info_imp := f_get_infoimppol (p_sseguro, vctipo, 'POL', mensajes);
      vob_info_imp.sidepag := p_sidepag;
      vob_info_imp.ccausin := p_ccausin;
      vob_info_imp.nrecibo := p_sidepag;
--BUG21726 - JTS - 16/03/2012 - En aquest cas el document de pago es el SIDEPAG i no l'nrecibo
      vob_info_imp.cmotsin := NVL (p_cmotsin, 0);

      --- para la plantilla detallada de pagos sinistro GRC007
      SELECT MAX (nsinies)
        INTO vob_info_imp.nsinies
        FROM sin_tramita_pago
       WHERE sidepag = p_sidepag;

      --
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);
      vpasexec := 4;

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_pago;

--Fi BUG 16446 - ETM - 31/12/2010

   /*************************************************************************
    --BUG 19783 - ETM - 24/11/2011
      Impresión  TRAMITACIONES
      param in p_nsinies    : id de SINIESTRO
       param in P_ntramit   : numero de tramitacion
       param in P_cestado      : estado de la tramitacion
       PARAM in p_tipo        : tipo de plantilla
        param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_trami (
      p_nsinies   IN       VARCHAR2,
      p_ntramit   IN       NUMBER,
      p_cestado   IN       NUMBER,
      p_tipo      IN       VARCHAR,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (1000)
         :=    'P_nsinies: '
            || p_nsinies
            || ' P_ntramit: '
            || p_ntramit
            || ' p_cestado: '
            || p_cestado;
      vobject        VARCHAR2 (200)  := 'PAC_MD_IMPRESION.f_imprimir_trami';
      vctipo         NUMBER (2);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
      p_sseguro      NUMBER;
   BEGIN
      --Comprovació de paràmetres
      IF    p_nsinies IS NULL
         OR p_ntramit IS NULL
         OR p_cestado IS NULL
         OR p_tipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT sseguro
        INTO p_sseguro
        FROM sin_siniestro
       WHERE nsinies = p_nsinies;

      vpasexec := 3;
      vob_info_imp := f_get_infoimppol (p_sseguro, vctipo, 'POL', mensajes);
      vob_info_imp.nsinies := p_nsinies;
      vob_info_imp.ntramit := p_ntramit;
      -- vob_info_imp.cestado := NVL(p_cestado, 0);
      vob_info_imp.sseguro := p_sseguro;
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);
      vpasexec := 4;

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_trami;

--Fi BUG 16446 - ETM - 31/12/2010

   /*************************************************************************
      --BUG 21458 - JTS - 22/05/2012
      FUNCTION f_firmar_doc
       param in p_iddoc    : id del documento GEDOX a firmar
       param in P_firmab64 : firma en BASE64
       param out mensajes  : mensajes de error
      return               : error
   *************************************************************************/
   FUNCTION f_firmar_doc (
      p_iddoc       IN       VARCHAR2,
      p_fichero     IN       VARCHAR2,
      p_firmab64    IN       CLOB,
      p_conffirma   IN       VARCHAR2,
      p_ccodplan    IN       VARCHAR2,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)         := 0;
      vparam        VARCHAR2 (100)     := 'p_iddoc: ' || p_iddoc;
      vobject       VARCHAR2 (200)     := 'PAC_MD_IMPRESION.f_firmar_doc';
      --
      vfichero      VARCHAR2 (100);
      verror        NUMBER;
      vtfichpath    VARCHAR2 (300);
      vsinterf      NUMBER;
      v_msg         VARCHAR2 (32000);
      v_msgout      VARCHAR2 (32000);
      vparser       xmlparser.parser;
      v_domdoc      xmldom.domdocument;
      verrort       VARCHAR2 (1000);
      w_cfdigital   VARCHAR2 (1);
   BEGIN
      --Comprovació de paràmetres
      IF (p_iddoc IS NULL AND vfichero IS NULL) OR p_firmab64 IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      BEGIN
         SELECT UPPER (cfdigital)                --BUG21458 - JTS - 27/08/2012
           INTO w_cfdigital                      --BUG21458 - JTS - 27/08/2012
           FROM codiplantillas
          WHERE ccodplan = p_ccodplan;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            w_cfdigital := 'N';
      END;

      vpasexec := 2;

      IF p_fichero IS NOT NULL
      THEN
         --Ens assegurem que agafem bé el nom del fitxer, tant sigui en windows com en unix la ruta
         vfichero :=
            SUBSTR (p_fichero,
                    INSTR (p_fichero, '/', -1) + 1,
                    LENGTH (p_fichero)
                   );
         vfichero :=
             SUBSTR (vfichero, INSTR (vfichero, '\', -1) + 1,
                     LENGTH (vfichero));
         verror := 0;
      ELSE
         pac_axisgedox.verdoc (p_iddoc, vfichero, verror);
      END IF;

      IF verror <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      vtfichpath := pac_md_common.f_get_parinstalacion_t ('INFORMES_SERV');
      vpasexec := 3;
      pac_int_online.p_inicializar_sinterf;
      vsinterf := pac_int_online.f_obtener_sinterf;
      v_msg :=
            '<?xml version="1.0"?>
<conversion_out>
  <sinterf>'
         || vsinterf
         || '</sinterf>
  <tipoorigen>PDF</tipoorigen>
  <tipodestino>PDF</tipodestino>
  <ficherodestino>'
         || vtfichpath
         || '\'
         || vfichero
         || '</ficherodestino>
  <firma_digital>'
         || w_cfdigital
         || '</firma_digital>
  <firma_electronica_cliente>S</firma_electronica_cliente>
  <firma_electronica_clienteimagen>'
         || p_firmab64
         || '</firma_electronica_clienteimagen>
  <firma_electronica_clienteposicion>'
         || p_conffirma
         || '</firma_electronica_clienteposicion>
</conversion_out>';
      vpasexec := 4;
      pac_int_online.peticion_host (pac_md_common.f_get_cxtempresa,
                                    'I008',
                                    v_msg,
                                    v_msgout
                                   );
      parsear (v_msgout, vparser);
      v_domdoc := xmlparser.getdocument (vparser);
      verror := pac_xml.buscarnodotexto (v_domdoc, 'inderrpro');

      IF verror <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF p_iddoc IS NOT NULL
      THEN
         pac_axisgedox.actualiza_gedoxdb (vfichero, p_iddoc, verrort);

         IF verrort IS NOT NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, NULL, verrort);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_firmar_doc;

   /*************************************************************************
    -- ini BUG 0022444 - JMF - 05/06/2012
      Impresión carta rechazo siniestro
       param in p_sseguro : numero sseguro
       param in p_tipo    : tipo de plantilla
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cartarechazosin (
      p_sseguro   IN       NUMBER,
      p_tipo      IN       VARCHAR,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (1000)
                       := 'p_sseguro: ' || p_sseguro || ' p_tipo: ' || p_tipo;
      vobject        VARCHAR2 (200)
                             := 'PAC_MD_IMPRESION.f_imprimir_cartarechazosin';
      vctipo         NUMBER (2);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN
      --Comprovació de paràmetres
      IF p_sseguro IS NULL OR p_tipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vob_info_imp := f_get_infoimppol (p_sseguro, vctipo, 'POL', mensajes);
      vob_info_imp.sseguro := p_sseguro;
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);
      vpasexec := 4;

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_cartarechazosin;

-- fin BUG 0022444 - JMF - 05/06/2012

   /*************************************************************************
    -- ini BUG 0021765 - JTS - 19/06/2012
      Impresión cartas de preavisos
       param in p_sproces : Sproces
       param in p_tipo    : tipo de plantilla
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cartaspreavisos (
      p_sproces   IN       NUMBER,
      p_tipo      IN       VARCHAR,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr      NUMBER (8)       := 0;
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (500)
                        := 'p_sproces: ' || p_sproces || ' p_tipo=' || p_tipo;
      vobject      VARCHAR2 (200)
                             := 'PAC_MD_IMPRESION.F_Imprimir_cartaspreavisos';
      v_ccodplan   VARCHAR2 (20);
      vtfilename   VARCHAR2 (200);
      vparamimp    pac_isql.vparam;
      vt_obj       t_iax_impresion  := t_iax_impresion ();
      vobj         ob_iax_impresion := ob_iax_impresion ();
      vinfo        ob_info_imp;

      CURSOR c1
      IS
         SELECT   pr.nrecibo, s.sseguro, p.ccodplan
             FROM seguros s, prod_plant_cab p, preavisosrecibos pr
            WHERE s.sseguro = pr.sseguro
              AND p.sproduc = s.sproduc
              AND TRUNC (f_sysdate) BETWEEN fdesde
                                        AND NVL (fhasta, TRUNC (f_sysdate))
              AND p.ctipo = f_get_tipo (p_tipo)
              AND pr.sproces = p_sproces
         GROUP BY pr.nrecibo, s.sseguro, p.ccodplan;
   BEGIN
      vpasexec := 2;
      --Obtenemos los parámetros necesarios para imprimir la plantilla.
      vparamimp (1).par := 'PMT_SPROCES';
      vparamimp (1).val := p_sproces;
      vpasexec := 3;

      FOR f1 IN c1
      LOOP
         vinfo :=
            f_get_infoimppol (f1.sseguro,
                              f_get_tipo (p_tipo),
                              'POL',
                              mensajes
                             );
         --
         vparamimp (2).par := 'PMT_IDIOMA';
         vparamimp (2).val := vinfo.cidioma;
         --
         vparamimp (3).par := 'PMT_NRECIBO';
         vparamimp (3).val := f1.nrecibo;
         vinfo.nrecibo := f1.nrecibo;
         --Impresión de la carta
         vtfilename :=
               vinfo.npoliza
            || '_'
            || f1.ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '.rtf';
         vpasexec := 4;
         --Impresión de la plantilla.
         vobj :=
            f_detimprimir (vinfo, f1.ccodplan, vparamimp, vtfilename,
                           mensajes);

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
      END LOOP;

      vpasexec := 8;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_cartaspreavisos;

   FUNCTION f_get_impagrup (
      pcurcat    OUT      sys_refcursor,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (1)     := NULL;
      vobject    VARCHAR2 (200)   := 'PAC_MD_IMPRESION.F_Get_Impagrup';
      vselect    VARCHAR2 (10000);
   BEGIN
      vselect :=
            'select d.ccategoria, dc.tdescategoria from docsimpresion d, CATEGORIASIMP c, descategoriasimp dc
               where d.cestado = 0 and d.ccategoria = c.ccategoria and dc.ccategoria = d.ccategoria and
               dc.cidioma = '
         || pac_md_common.f_get_cxtidioma ()
         || ' group by d.ccategoria, dc.tdescategoria';
      pcurcat := pac_md_listvalores.f_opencursor (vselect, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF pcurcat%ISOPEN
         THEN
            CLOSE pcurcat;
         END IF;

         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF pcurcat%ISOPEN
         THEN
            CLOSE pcurcat;
         END IF;

         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF pcurcat%ISOPEN
         THEN
            CLOSE pcurcat;
         END IF;

         RETURN 1;
   END f_get_impagrup;

   FUNCTION f_get_impdet (
      pdefault      IN       NUMBER,
      pccategoria   IN       NUMBER,
      pctipo        IN       NUMBER,
      ptfich        IN       VARCHAR2,
      pfsolici      IN       DATE,
      puser         IN       VARCHAR2,
      pfult         IN       DATE,
      pusult        IN       VARCHAR2,
      pcestado      IN       NUMBER,
      psproces      IN       NUMBER,
      pnpoliza      IN       NUMBER,
      pncertif      IN       NUMBER,
      pcagente      IN       NUMBER,
      psproduc      IN       NUMBER,
      pcramo        IN       NUMBER,
      pcurdocs      OUT      sys_refcursor,
      plistzips     OUT      t_iax_impresion,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (1)     := NULL;
      vobject    VARCHAR2 (200)   := 'PAC_MD_IMPRESION.F_Get_Impdet';
      vselect    VARCHAR2 (10000);
      vobimp     ob_iax_impresion := ob_iax_impresion ();
      vtfich     VARCHAR2 (500);
   BEGIN
      IF pdefault = 1
      THEN
         vselect :=
               'SELECT d.iddocgedox, d.ccategoria, dc.tdescategoria, d.ctipo, dv.tatribu TTIPO, d.tdesc, d.tfichero, d.sproces,
                   d.cuser, d.fcrea, d.cultuserimp, d.fultimp, s.cagente, FF_DESAGENTE(s.cagente) tagente, s.sproduc,
                   f_desproducto_t (s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, pac_md_common.f_get_cxtidioma) tproduc,
                   s.npoliza, s.ncertif, d.cestado, ff_desvalorfijo(800107,pac_md_common.f_get_cxtidioma,d.cestado) testado
              FROM docsimpresion d, categoriasimp c, descategoriasimp dc, detvalores dv, seguros s,agentes_agente_pol ag
             WHERE d.cestado = 0
               AND d.ccategoria = c.ccategoria(+)
               AND dc.ccategoria(+) = d.ccategoria
               AND dc.cidioma(+) ='
            || pac_md_common.f_get_cxtidioma ()
            || ' AND d.ccategoria IS NULL
               AND dv.cvalor = 317
               AND dv.catribu = d.ctipo
               AND dv.cidioma ='
            || pac_md_common.f_get_cxtidioma ()
            || ' AND d.sseguro (+) = s.sseguro  and ag.cagente =  s.cagente and ag.cempres =  s.cempres';
      ELSE
         vselect :=
               'SELECT d.iddocgedox, d.ccategoria, dc.tdescategoria, d.ctipo, dv.tatribu TTIPO, d.tdesc, d.tfichero, d.sproces,
                   d.cuser, d.fcrea, d.cultuserimp, d.fultimp, s.cagente, FF_DESAGENTE(s.cagente) tagente, s.sproduc,
                   f_desproducto_t (s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, pac_md_common.f_get_cxtidioma) tproduc,
                   s.npoliza, s.ncertif, d.cestado, ff_desvalorfijo(800107,pac_md_common.f_get_cxtidioma,d.cestado) testado
              FROM docsimpresion d, categoriasimp c, descategoriasimp dc, detvalores dv, seguros s,agentes_agente_pol ag
             WHERE d.ccategoria = c.ccategoria(+)
               AND dc.ccategoria(+) = d.ccategoria
               AND dc.cidioma(+) ='
            || pac_md_common.f_get_cxtidioma ()
            || ' AND dv.cvalor = 317
               AND dv.catribu = d.ctipo
               AND dv.cidioma ='
            || pac_md_common.f_get_cxtidioma ()
            || ' AND d.sseguro (+) = s.sseguro and ag.cagente = s.cagente and ag.cempres =  s.cempres ';

         IF pccategoria IS NOT NULL
         THEN
            vselect := vselect || ' and d.ccategoria= ' || pccategoria;
         END IF;

         IF pctipo IS NOT NULL
         THEN
            vselect := vselect || ' and d.ctipo= ' || pctipo;
         END IF;

         IF ptfich IS NOT NULL
         THEN
            vtfich := '%' || ptfich || '%';
            vselect :=
                  vselect || ' and d.tfichero like  ''' || vtfich || CHR (39);
         END IF;

         IF pfsolici IS NOT NULL
         THEN
            vselect :=
                  vselect
               || ' AND trunc(d.fcrea)=  '
               || 'TO_DATE('''
               || TO_CHAR (pfsolici, 'DD/MM/YYYY')
               || ''', ''DD/MM/YYYY'') ';
         END IF;

         IF puser IS NOT NULL
         THEN
            vselect := vselect || ' and d.cuser= ''' || puser || CHR (39);
         END IF;

         IF pfult IS NOT NULL
         THEN
            vselect :=
                  vselect
               || ' AND trunc(d.fultimp)=  '
               || 'TO_DATE('''
               || TO_CHAR (pfult, 'DD/MM/YYYY')
               || ''', ''DD/MM/YYYY'') ';
         END IF;

         IF pusult IS NOT NULL
         THEN
            vselect :=
                    vselect || ' and d.cultuserimp= ''' || pusult || CHR (39);
         END IF;

         IF pcestado IS NOT NULL
         THEN
            vselect := vselect || ' and d.cestado= ' || pcestado;
         END IF;

         IF psproces IS NOT NULL
         THEN
            vselect :=
                  vselect
               || ' and d.iddocgedox in (select iddocgedox from procesosimp where sproces ='
               || psproces
               || ')';
         END IF;

         IF pnpoliza IS NOT NULL
         THEN
            vselect := vselect || ' and s.npoliza = ' || pnpoliza;
         END IF;

         IF pncertif IS NOT NULL
         THEN
            vselect := vselect || ' and s.ncertif = ' || pncertif;
         END IF;

         IF pcagente IS NOT NULL
         THEN
            vselect := vselect || ' and s.cagente = ' || pcagente;
         END IF;

         IF psproduc IS NOT NULL
         THEN
            vselect := vselect || ' and s.sproduc = ' || psproduc;
         END IF;

         IF pcramo IS NOT NULL
         THEN
            vselect := vselect || ' and s.cramo = ' || pcramo;
         END IF;
      END IF;

      vselect := vselect || ' order by d.fcrea,s.npoliza ';
      pcurdocs := pac_md_listvalores.f_opencursor (vselect, mensajes);

      IF psproces IS NOT NULL
      THEN
         plistzips := t_iax_impresion ();

         FOR i IN (SELECT tagrupa, estado, terror
                     FROM procesosimpagrup
                    WHERE sproces = psproces)
         LOOP
            IF i.terror IS NOT NULL
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     NULL,
                                                     i.terror
                                                    );
               pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                                  vobject,
                                                  1000006,
                                                  vpasexec,
                                                  vparam || vselect
                                                 );
            ELSE
               IF i.estado = 0
               THEN
                  plistzips.EXTEND;
                  vobimp.fichero := i.tagrupa;
                  vobimp.cdiferido := 0;
                  plistzips (plistzips.LAST) := vobimp;
               ELSE
                  plistzips.EXTEND;
                  vobimp.fichero :=
                     ff_desvalorfijo (8000898,
                                      pac_md_common.f_get_cxtidioma,
                                      i.estado
                                     );
                  vobimp.cdiferido := 1;
                  plistzips (plistzips.LAST) := vobimp;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam || vselect
                                           );

         IF pcurdocs%ISOPEN
         THEN
            CLOSE pcurdocs;
         END IF;

         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam || vselect
                                           );

         IF pcurdocs%ISOPEN
         THEN
            CLOSE pcurdocs;
         END IF;

         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF pcurdocs%ISOPEN
         THEN
            CLOSE pcurdocs;
         END IF;

         RETURN 1;
   END f_get_impdet;

   FUNCTION f_get_categorias (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (1)     := NULL;
      vobject    VARCHAR2 (200)   := 'PAC_MD_IMPRESION.F_Get_categorias';
      vselect    VARCHAR2 (10000);
      vcursor    sys_refcursor;
   BEGIN
      vselect :=
            'select c.ccategoria, dc.tdescategoria from CATEGORIASIMP c, descategoriasimp dc
               where dc.ccategoria = c.ccategoria and
               dc.cidioma = '
         || pac_md_common.f_get_cxtidioma ()
         || ' order by c.ccategoria';
      vcursor := pac_md_listvalores.f_opencursor (vselect, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN NULL;
   END f_get_categorias;

   FUNCTION f_get_impresoras (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (1)     := NULL;
      vobject    VARCHAR2 (200)   := 'PAC_MD_IMPRESION.F_Get_impresoras';
      vselect    VARCHAR2 (10000);
      vcursor    sys_refcursor;
   BEGIN
      vselect :=
         'SELECT idimpresora, talias
              FROM impresoras
              order by idimpresora';
      vcursor := pac_md_listvalores.f_opencursor (vselect, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN NULL;
   END f_get_impresoras;

   /*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Inserta el documento
       param in PIDDOCGEDOX : Identificador del documento gedox
       param in PTDESC    : descripcion
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_ins_doc (
      piddocgedox   IN       NUMBER,
      ptdesc        IN       VARCHAR2,
      ptfich        IN       VARCHAR2,
      pctipo        IN       NUMBER,
      pcdiferido    IN       NUMBER,
      pccategoria   IN       NUMBER,
      psseguro      IN       NUMBER,
      pnmovimi      IN       NUMBER,
      pnrecibo      IN       NUMBER,
      pnsinies      IN       NUMBER,
      psidepag      IN       NUMBER,
      psproces      IN       NUMBER,
      pcagente      IN       NUMBER,
      pcidioma      IN       NUMBER,
      piddocdif     IN       NUMBER,
      pnorden       IN       NUMBER,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)     := 1;
      vparam       VARCHAR2 (1)   := NULL;
      vobject      VARCHAR2 (200) := 'PAC_MD_IMPRESION.F_Ins_Doc';
      vnumerr      NUMBER;
      --
      vcount_doc   NUMBER         := 0;
      vcount_ged   NUMBER         := 0;
      viddocimp    NUMBER;
   BEGIN
      --Comprobamos los campos clave
      IF ((piddocdif IS NULL AND pnorden IS NULL) AND (piddocgedox IS NULL)
         )
      THEN
         RAISE e_param_error;
      END IF;

      --Comprobamos los campos mandatorios según que campos clave vengan informados
      IF     (piddocdif IS NOT NULL AND pnorden IS NOT NULL)
         AND (psseguro IS NULL AND pnmovimi IS NULL)
         AND pnrecibo IS NULL
         AND pnsinies IS NULL
         AND psidepag IS NULL
         AND psproces IS NULL
         AND pcagente IS NULL
      THEN
         RAISE e_param_error;
      ELSIF     piddocgedox IS NOT NULL
            AND (ptdesc IS NULL OR ptfich IS NULL OR pctipo IS NULL)
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_isql.f_ins_doc (piddocgedox,
                             ptdesc,
                             ptfich,
                             pctipo,
                             pcdiferido,
                             pccategoria,
                             psseguro,
                             pnmovimi,
                             pnrecibo,
                             pnsinies,
                             psidepag,
                             psproces,
                             pcagente,
                             pcidioma,
                             piddocdif,
                             pnorden
                            );

      IF vnumerr <> 0
      THEN
         vpasexec := 5;
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN -1;
   END f_ins_doc;

   FUNCTION f_envia_impresora (
      plistcategorias   IN       VARCHAR2,
      plistdocs         IN       VARCHAR2,
      pidimpresora      IN       NUMBER,
      mensajes          IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr        NUMBER (8)                      := 0;
      vpasexec       NUMBER (8)                      := 1;
      vparam         VARCHAR2 (1000)
         := /*'plistcategorias:' || plistcategorias || ' - plistdocs:' || plistdocs
            || */ ' - pidimpresora:' || pidimpresora;
      vobject        VARCHAR2 (200)   := 'PAC_MD_IMPRESION.f_envia_impresora';
      vsproces       NUMBER;
      vfichero       VARCHAR2 (100);
      vfichero2      VARCHAR2 (100);
      vficheros      VARCHAR2 (32000);
      dirfiles       VARCHAR2 (100);
      vlineaini      VARCHAR2 (500);
      vresultado     int_resultado.cresultado%TYPE;
      v_interficie   VARCHAR2 (100)                  := 'I023';
      vsinterf       int_resultado.sinterf%TYPE;
      verror         int_resultado.terror%TYPE;
      vnerror        int_resultado.nerror%TYPE;
      --
      v_msg          VARCHAR2 (32000);
      v_msgout       VARCHAR2 (32000);
      vparser        xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      vtfichpath     VARCHAR2 (50);
   BEGIN
      /*p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                  plistcategorias || ' - ' || plistdocs || ' - ' || pidimpresora);*/

      --IF con funcionalidad desarrollada según MDP
      IF     pidimpresora IS NOT NULL
         AND (plistcategorias IS NOT NULL OR plistdocs IS NOT NULL)
      THEN
         DECLARE
            lv_appendstring    VARCHAR2 (32000) := plistcategorias;
            lv_appendstring2   VARCHAR2 (32000) := plistdocs;
            lv_resultstring    VARCHAR2 (500);
            lv_count           NUMBER;
         BEGIN
            SELECT sproces.NEXTVAL
              INTO vsproces
              FROM DUAL;

            LOOP
               EXIT WHEN NVL (INSTR (lv_appendstring, ';'), -99) < 0;
               lv_resultstring :=
                  SUBSTR (lv_appendstring,
                          1,
                          (INSTR (lv_appendstring, ';') - 1)
                         );
               lv_count := INSTR (lv_appendstring, ';') + 1;
               lv_appendstring :=
                  SUBSTR (lv_appendstring, lv_count, LENGTH (lv_appendstring));

               FOR i IN (SELECT iddocgedox, iddocimp
                           FROM docsimpresion
                          WHERE cestado = 0 AND ccategoria = lv_resultstring)
               LOOP
                  vfichero := NULL;
                  pac_axisgedox.verdoc (i.iddocgedox, vfichero, vnumerr);
                  vpasexec := 2;
                                                         --dirfiles := '/u01/Interfases/Iota/Gedox';
                  --dirfiles := pac_md_common.f_get_parinstalacion_t('INFORMES_SERV');
                  dirfiles :=
                           pac_md_common.f_get_parinstalacion_t ('GEDOX_DIR');
                  --p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, dirfiles);
                  vpasexec := 3;

                  SELECT    REPLACE (vfichero,
                                     SUBSTR (vfichero,
                                             INSTR (vfichero, '.', 1)
                                            ),
                                     ''
                                    )
                         || '_'
                         || vsproces
                         || '_'
                         || i.iddocgedox
                         || SUBSTR (vfichero, INSTR (vfichero, '.', 1))
                    INTO vfichero2
                    FROM DUAL;

                  UTL_FILE.frename (dirfiles,
                                    vfichero,
                                    dirfiles,
                                    vfichero2,
                                    TRUE
                                   );
                  vfichero := vfichero2;
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  i.iddocgedox
                               || ' - '
                               || vfichero
                               || ' - '
                               || vnumerr
                              );

                  INSERT INTO procesosimp
                              (sproces, idimpresora, iddocgedox,
                               tfichero,
                               truta,
                               iddocimp
                              )
                       VALUES (vsproces, pidimpresora, i.iddocgedox,
                               vfichero,
                               pac_md_common.f_get_parinstalacion_t
                                                              ('INFORMES_SERV'),
                               i.iddocimp
                              );
               END LOOP;

               vpasexec := 4;

               UPDATE docsimpresion
                  SET cestado = 1,
                      cuserimp = NVL (cuserimp, f_user),
                      fimp = NVL (fimp, f_sysdate),
                      cultuserimp = f_user,
                      fultimp = f_sysdate
                WHERE cestado = 0 AND iddocgedox = lv_resultstring;

               --p_tab_error(F_Sysdate, F_User,vobject,vpasexec,vparam  ,lv_resultstring || ' - ' || lv_count || ' - ' || lv_appendstring);
               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END LOOP;

            COMMIT;

            LOOP
               EXIT WHEN NVL (INSTR (lv_appendstring2, ';'), -99) < 0;
               lv_resultstring :=
                  SUBSTR (lv_appendstring2,
                          1,
                          (INSTR (lv_appendstring2, ';') - 1)
                         );
               lv_count := INSTR (lv_appendstring2, ';') + 1;
               lv_appendstring2 :=
                  SUBSTR (lv_appendstring2,
                          lv_count,
                          LENGTH (lv_appendstring2)
                         );
               vpasexec := 5;

               FOR i IN (SELECT iddocgedox, iddocimp
                           FROM docsimpresion
                          WHERE
                                --cestado = 0
                                  --AND
                                iddocgedox = lv_resultstring)
               LOOP
                  vfichero := NULL;
                  pac_axisgedox.verdoc (i.iddocgedox, vfichero, vnumerr);
                  vpasexec := 6;
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                               dirfiles
                              );
                  dirfiles :=
                            pac_md_common.f_get_parinstalacion_t ('GEDOX_DIR');
                  vpasexec := 7;

                  SELECT    REPLACE (vfichero,
                                     SUBSTR (vfichero,
                                             INSTR (vfichero, '.', 1)
                                            ),
                                     ''
                                    )
                         || '_'
                         || vsproces
                         || '_'
                         || i.iddocgedox
                         || SUBSTR (vfichero, INSTR (vfichero, '.', 1))
                    INTO vfichero2
                    FROM DUAL;

                  UTL_FILE.frename (dirfiles,
                                    vfichero,
                                    dirfiles,
                                    vfichero2,
                                    TRUE
                                   );
                  vfichero := vfichero2;

                  INSERT INTO procesosimp
                              (sproces, idimpresora, iddocgedox,
                               tfichero,
                               truta,
                               iddocimp
                              )
                       VALUES (vsproces, pidimpresora, i.iddocgedox,
                               vfichero,
                               pac_md_common.f_get_parinstalacion_t
                                                              ('INFORMES_SERV'),
                               i.iddocimp
                              );

                  UPDATE docsimpresion
                     SET cestado = 1,
                         cuserimp = NVL (cuserimp, f_user),
                         fimp = NVL (fimp, f_sysdate),
                         cultuserimp = f_user,
                         fultimp = f_sysdate
                   WHERE iddocgedox = lv_resultstring;
               END LOOP;

               --p_tab_error(F_Sysdate, F_User,vobject,vpasexec,vparam  ,lv_resultstring || ' - ' || lv_count || ' - ' || lv_appendstring);
               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END LOOP;

            COMMIT;
         END;

         vpasexec := 8;

         FOR i IN (SELECT tfichero
                     FROM procesosimp
                    WHERE sproces = vsproces)
         LOOP
            IF vficheros IS NULL
            THEN
               vficheros := i.tfichero;
            ELSE
               vficheros := vficheros || ';' || i.tfichero;
            END IF;
         END LOOP;

         vpasexec := 9;
         --llamar al map con vficheros de linea de entrada
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      vsproces || ' - ' || vficheros
                     );
         pac_int_online.p_inicializar_sinterf;
         vsinterf := pac_int_online.f_obtener_sinterf;
         vlineaini := pidimpresora || '|' || dirfiles || '|' || vficheros;
         vresultado :=
            pac_int_online.f_int (pac_md_common.f_get_cxtempresa,
                                  vsinterf,
                                  'I023',
                                  vlineaini
                                 );

         IF vresultado <> 0
         THEN
            RETURN vresultado;
         END IF;

         -- Recupero el error
         p_recupera_error (vsinterf, vresultado, verror, vnerror);

         IF vresultado <> 0
         THEN
            RETURN vresultado;
         END IF;

         IF NVL (vnumerr, 0) <> 0
         THEN
            RETURN vnumerr;
         END IF;

         --DBMS_OUTPUT.put_line('Todo ok');
         /*FOR i IN (SELECT nrecibo, sseguro, nmovimi
                     FROM preavisosrecibos
                    WHERE fenvio IS NULL) LOOP
            --Pendiente de realizar
            --
            --Llamada al modulo de impresiones para generar los avisos
            --y proceder a su envio
            --
            --Una vez realizado en envio, se marca como realizado
            vnumerr := pac_preavisos.f_actualizapreaviso(i.nrecibo);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END LOOP;*/
         RETURN 0;
      --Elsif con funcionalidad LCOL
      ELSIF pidimpresora IS NULL AND plistdocs IS NOT NULL
      THEN
         SELECT sproces.NEXTVAL
           INTO vsproces
           FROM DUAL;

         SELECT talias
           INTO vtfichpath
           FROM impresoras
          WHERE idimpresora = 0;

         vpasexec := 3;
         pac_int_online.p_inicializar_sinterf;
         vsinterf := pac_int_online.f_obtener_sinterf;
         v_msg :=
               '<?xml version="1.0"?>
<conversion_out>
  <sinterf>'
            || vsinterf
            || '</sinterf>
  <tipoorigen>GEDOX</tipoorigen>
  <tipodestino>ZIP</tipodestino>
  <ficheroorigen>'
            || REPLACE (plistdocs, ';', ',')
            || '</ficheroorigen>
  <ficherodestino>'
            || vtfichpath
            || '\f</ficherodestino>
  <plantillaorigen>'
            || vsproces
            || '</plantillaorigen>
</conversion_out>';
         vpasexec := 4;
         pac_int_online.peticion_host (pac_md_common.f_get_cxtempresa,
                                       'I008',
                                       v_msg,
                                       v_msgout
                                      );
         parsear (v_msgout, vparser);
         v_domdoc := xmlparser.getdocument (vparser);
         verror := pac_xml.buscarnodotexto (v_domdoc, 'inderrpro');

         --
         IF verror <> 0
         THEN
            RAISE e_object_error;
         END IF;

         DECLARE
            lv_appendstring2   VARCHAR2 (32000) := plistdocs;
            lv_resultstring    VARCHAR2 (500);
            lv_count           NUMBER;
         BEGIN
            LOOP
               EXIT WHEN NVL (INSTR (lv_appendstring2, ';'), -99) < 0;
               lv_resultstring :=
                  SUBSTR (lv_appendstring2,
                          1,
                          (INSTR (lv_appendstring2, ';') - 1)
                         );
               lv_count := INSTR (lv_appendstring2, ';') + 1;
               lv_appendstring2 :=
                  SUBSTR (lv_appendstring2,
                          lv_count,
                          LENGTH (lv_appendstring2)
                         );
               vpasexec := 5;

               FOR i IN (SELECT iddocgedox, iddocimp, tfichero
                           FROM docsimpresion
                          WHERE iddocgedox = lv_resultstring)
               LOOP
                  INSERT INTO procesosimp
                              (sproces, idimpresora, iddocgedox, tfichero,
                               truta, iddocimp
                              )
                       VALUES (vsproces, 0, i.iddocgedox, i.tfichero,
                               vtfichpath, i.iddocimp
                              );

                  UPDATE docsimpresion
                     SET cestado = 1,
                         cuserimp = NVL (cuserimp, f_user),
                         fimp = NVL (fimp, f_sysdate),
                         cultuserimp = f_user,
                         fultimp = f_sysdate,
                         sproces = vsproces
                   WHERE iddocimp = i.iddocimp;
               END LOOP;
            END LOOP;
         END;

         INSERT INTO procesosimpagrup
                     (sproces, tagrupa, estado
                     )
              VALUES (vsproces, '.', 1
                     );

         --
         COMMIT;
         --
         pac_iobj_mensajes.crea_nuevo_mensaje
                            (mensajes,
                             2,
                             NULL,
                                f_axis_literales
                                                (9001242,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                             || ' '
                             || vsproces
                            );
      ELSE
         RAISE e_param_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN 1;
   END f_envia_impresora;

   FUNCTION f_obtener_valor_columna (
      pinfo             IN       t_iax_info,
      pnombre_columna   IN       VARCHAR2,
      pvalor_columna    OUT      VARCHAR2,
      mensajes          IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := 'pnombre_columna:' || pnombre_columna;
      vobject    VARCHAR2 (200) := 'PAC_MD_IMPRESION.f_obtener_valor_columna';
      vsproces   NUMBER;
   BEGIN
      IF pinfo IS NULL
      THEN
         pvalor_columna := NULL;
         RETURN 0;
      ELSE
         IF pinfo.COUNT = 0
         THEN
            pvalor_columna := NULL;
            RETURN 0;
         END IF;
      END IF;

      FOR vinfo IN pinfo.FIRST .. pinfo.LAST
      LOOP
         IF pinfo.EXISTS (vinfo)
         THEN
            IF UPPER (pinfo (vinfo).nombre_columna) = UPPER (pnombre_columna)
            THEN
               pvalor_columna := pinfo (vinfo).valor_columna;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_obtener_valor_columna;

   /*************************************************************************
      --BUG24687- JTS - 15/11/2012
      Impresión procesos
      param in PSPROCES  : ID. proceso
      param in P_TIPO      : ctipo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_sproces (
      p_sproces   IN       NUMBER,
      p_tipo      IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)      := 0;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (500)
                       := 'p_sproces: ' || p_sproces || ' p_tipo: ' || p_tipo;
      vobject        VARCHAR2 (200)  := 'PAC_MD_IMPRESION.f_imprimir_sproces';
      vctipo         NUMBER (2);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vob_info_imp.sproces := p_sproces;
      vob_info_imp.sproduc := 0;
      vob_info_imp.cidioma := pac_md_common.f_get_cxtidioma;
      vob_info_imp.cempres := pac_md_common.f_get_cxtempresa;
      vob_info_imp.cagente := pac_md_common.f_get_cxtagente;
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_sproces;

   PROCEDURE f_error_pendientes (piddocdif IN NUMBER, texto IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      UPDATE doc_diferida
         SET terror = SUBSTR (texto, 0, 4000)
       WHERE iddocdif = piddocdif;

      UPDATE docsimpresion
         SET cestado = 2
       WHERE iddocdif = piddocdif;

      COMMIT;
   END f_error_pendientes;

   FUNCTION f_recupera_pendientes
        RETURN sys_refcursor
   IS
      vcur   sys_refcursor;
   BEGIN
   --BUG 39715 sustituimos el where rownum <= 100 por el rownum <=pac_parametros.f_parinstalacion_n('MAXDOCS')
   --para evitar que en algunos clientes se caiga el servicio de impresión.

      --LOCK TABLE doc_diferida IN EXCLUSIVE MODE NOWAIT;
      UPDATE doc_diferida
         SET cestado = 99
       WHERE iddocdif IN (SELECT iddocdif
                            FROM (SELECT   iddocdif
                                      FROM doc_diferida
                                     WHERE cestado = 1
                                  ORDER BY iddocdif)
                           WHERE ROWNUM <= nvl(f_parinstalacion_n('MAXDOCS'),100) );

      COMMIT;

      OPEN vcur FOR 'select iddocdif from doc_diferida where cestado = 99';

      RETURN vcur;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_MD_IMPRESION.f_recupera_pendientes',
                      0,
                      SQLCODE,
                      SQLERRM
                     );

         IF vcur%ISOPEN
         THEN
            CLOSE vcur;
         END IF;

         ROLLBACK;
         RETURN NULL;
   END f_recupera_pendientes;

   FUNCTION f_genera_pendientes (piddocdif IN NUMBER)
      RETURN sys_refcursor
   IS
      vcur               sys_refcursor;
      vquery             VARCHAR2 (32000);
      vsseguro           NUMBER;
      vnmovimi           NUMBER;
      vnrecibo           NUMBER;
      vnsinies           NUMBER;
      vsidepag           NUMBER;
      vsproces           NUMBER;
      vcagente           NUMBER;
      vcidioma           NUMBER;
      vctipo             NUMBER;
      vcuser             VARCHAR2 (50);
      vobinfo            ob_info_imp;
      mensajes           t_iax_mensajes;
      vpasexec           NUMBER                         := 0;
      vparamimp          pac_isql.vparam;
      vnumerr            NUMBER;
      vtfilename         VARCHAR2 (200);
      vncopias           NUMBER;
      vplantgedox        VARCHAR2 (1);
      v_idcat            NUMBER (8);
      v_cgenfich         NUMBER (1);
      v_cinforme         VARCHAR2 (100);
      v_extfich          VARCHAR2 (10);
      v_cgenpdf          NUMBER (1);
      v_ctipodoc         codiplantillas.ctipodoc%TYPE;
      w_cgenrep          NUMBER;
      w_cfdigital        VARCHAR2 (1);
      vdescripcion       VARCHAR2 (150);
      vcfirma            NUMBER (1);
      vtconffirma        VARCHAR2 (100);
      v_ptfilename       VARCHAR2 (100);
      v_vcinforme        VARCHAR2 (100);
      ruta               VARCHAR2 (100);
      v_dirpdfgdx        VARCHAR2 (30);
      vfilename          VARCHAR2 (100);
      vresult            NUMBER (10)                    := 0;
      vcodimp            NUMBER (10);
      vdatasource        VARCHAR2 (250);
      vtipodestino       VARCHAR2 (10);
      vfilename_ruta     VARCHAR2 (250);
      fichdestino        VARCHAR2 (100);
      v_extfichout       VARCHAR2 (10);
      vnorden            NUMBER                         := 0;
      vint               VARCHAR2 (10);
      --
      vtipoorigen        VARCHAR2 (250);
      vficheroorigen     VARCHAR2 (250);
      vficherodestino    VARCHAR2 (250);
      vplantillaorigen   VARCHAR2 (250);
      vtotal             NUMBER;
      vdestdocs          VARCHAR2 (250);
      --
      vcomproba          NUMBER;
      vtratar            NUMBER (1);

      CURSOR cr_imprimir (
         vcr_sproduc   IN   NUMBER,
         vcr_fefecto   IN   DATE,
         vcr_ctipo     IN   NUMBER
      )
      IS
         SELECT   p.ccodplan, cp.idconsulta, p.ccategoria, p.cdiferido
             FROM prod_plant_cab p, codiplantillas cp
            WHERE p.sproduc = vcr_sproduc
              AND vcr_fefecto BETWEEN fdesde AND NVL (fhasta, vcr_fefecto)
              AND p.ctipo = vcr_ctipo
              AND p.ccodplan = cp.ccodplan
         ORDER BY p.ccodplan;
   BEGIN
      --Evitamos que se reprocese algo ya procesado
      SELECT COUNT (1)
        INTO vcomproba
        FROM doc_diferida
       WHERE iddocdif = piddocdif AND cestado = 99;

      IF vcomproba <> 1
      THEN
         RETURN NULL;
      END IF;

      --fin del anti reproceso
      UPDATE doc_diferida
         SET cestado = 98
       WHERE iddocdif = piddocdif;

      COMMIT;

      SELECT sseguro, nmovimi, nrecibo, nsinies, sidepag, sproces,
             cagente, cidioma, ctipo, cuser
        INTO vsseguro, vnmovimi, vnrecibo, vnsinies, vsidepag, vsproces,
             vcagente, vcidioma, vctipo, vcuser
        FROM doc_diferida
       WHERE iddocdif = piddocdif;

      vpasexec := 1;
      vnumerr := pac_contexto.f_inicializarctx (vcuser);
      vobinfo := f_get_infoimppol (vsseguro, vctipo, 'POL', mensajes);

      IF vnmovimi IS NOT NULL
      THEN
         vobinfo.nmovimi := vnmovimi;
      END IF;

      IF vnrecibo IS NOT NULL
      THEN
         vobinfo.nrecibo := vnrecibo;
      END IF;

      IF vnsinies IS NOT NULL
      THEN
         vobinfo.nsinies := vnsinies;
      END IF;

      IF vsidepag IS NOT NULL
      THEN
         vobinfo.sidepag := vsidepag;
      END IF;

      IF vsproces IS NOT NULL
      THEN
         vobinfo.sproces := vsproces;
      END IF;

      IF vcagente IS NOT NULL
      THEN
         vobinfo.cagente := vcagente;
      END IF;

      IF vcidioma IS NOT NULL
      THEN
         vobinfo.cidioma := vcidioma;
      END IF;

      vpasexec := 3;

      IF vobinfo.sproduc IS NULL OR vctipo IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      vdestdocs :=
                  pac_parametros.f_parproducto_t (vobinfo.sproduc, 'DESTDOCS');
      vpasexec := 4;

      FOR cr IN cr_imprimir (vobinfo.sproduc, f_sysdate, vctipo)
      LOOP
         vpasexec := 5;
         vnumerr := f_get_paramimp (cr.idconsulta, vobinfo, vparamimp);

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 6;

         IF vobinfo.nomfitxer IS NOT NULL
         THEN
            vtfilename :=
                  vobinfo.nomfitxer
               || ' '
               || cr.ccodplan
               || '_'
               || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
               || '.rtf';
         ELSIF vobinfo.npoliza IS NOT NULL AND vobinfo.nmovimi IS NOT NULL
         THEN
            vtfilename :=
                  vobinfo.npoliza
               || '_'
               || vobinfo.ncertif
               || '_'
               || vobinfo.nmovimi
               || '_'
               || cr.ccodplan
               || '_'
               || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
               || '.rtf';
         ELSE
            vtfilename :=
                  cr.ccodplan
               || '_'
               || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
               || '.rtf';
         END IF;

         vpasexec := 7;
         vncopias :=
            pac_md_impresion.f_ncopias (vobinfo.sproduc,
                                        vctipo,
                                        cr.ccodplan,
                                        f_sysdate,
                                        vobinfo.sseguro,
                                        vobinfo.nmovimi,
                                        vobinfo.nrecibo,
                                        vobinfo.nsinies,
                                        mensajes
                                       );
         vpasexec := 8;
         vtratar := 1;

         --Recuperamos el norden de la programación de doc_diferida_det
         BEGIN
            SELECT norden
              INTO vnorden
              FROM doc_diferida_det
             WHERE iddocdif = piddocdif AND ccodplan = cr.ccodplan;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vtratar := 0;
         END;

         IF vtratar = 1
         THEN
            IF NVL (vncopias, 0) <> 0
            THEN
               vpasexec := 9;

               SELECT gedox, idcat, cgenfich, cgenpdf,
                      ctipodoc, cgenrep, UPPER (cfdigital)
                 INTO vplantgedox, v_idcat, v_cgenfich, v_cgenpdf,
                      v_ctipodoc, w_cgenrep, w_cfdigital
                 FROM codiplantillas
                WHERE ccodplan = cr.ccodplan;

               vpasexec := 10;

               SELECT dp.tdescrip, dp.cinforme, dp.cfirma, dp.tconffirma
                 INTO vdescripcion, v_cinforme, vcfirma, vtconffirma
                 FROM detplantillas dp
                WHERE dp.ccodplan = cr.ccodplan
                  AND dp.cidioma =
                          NVL (vobinfo.cidioma, pac_md_common.f_get_cxtidioma);

               vpasexec := 11;
               v_extfich :=
                  NVL (SUBSTR (v_cinforme, INSTR (v_cinforme, '.', -1) + 1),
                       'rtf'
                      );
               v_vcinforme :=
                         SUBSTR (v_cinforme, 1, INSTR (v_cinforme, '.', -1)
                                  - 1);
               v_ptfilename :=
                         SUBSTR (vtfilename, 1, INSTR (vtfilename, '.', -1)
                                  - 1);
               vpasexec := 12;

               IF v_cgenfich = 0
               THEN
                  vpasexec := 13;
                  ruta :=
                      pac_md_common.f_get_parinstalacion_t ('PLANTI_C')
                      || '\';
                  v_dirpdfgdx :=
                           pac_md_common.f_get_parinstalacion_t ('PDFGENGDX');
                  vfilename := v_cinforme;
                  vficherodestino := ruta || vfilename;
               ELSE
                  vpasexec := 14;

                  IF w_cgenrep = 1 OR LOWER (v_extfich) = 'csv'
                  THEN
                     vresult :=
                        pac_isql.gencon (cr.ccodplan,
                                         f_user,
                                         vparamimp,
                                         vcodimp,
                                         1,
                                         v_ptfilename
                                        );
                  ELSIF LOWER (v_extfich) = 'odt'
                  THEN
                     vresult :=
                        pac_isql.gencon (cr.ccodplan,
                                         f_user,
                                         vparamimp,
                                         vcodimp,
                                         1,
                                         v_ptfilename || '_content.xml'
                                        );
                  ELSE
                     vresult :=
                        pac_isql.gencon (cr.ccodplan,
                                         f_user,
                                         vparamimp,
                                         vcodimp,
                                         1,
                                         vtfilename
                                        );
                  END IF;

                  vpasexec := 15;

                  IF vresult <> 0
                  THEN
                     --Registro el error producido en la impresión.
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_isql.gencon',
                                  0,
                                  vresult,
                                  vresult
                                 );
                     RAISE e_param_error;
                  END IF;

                  vpasexec := 16;
                  ruta :=
                        pac_md_common.f_get_parinstalacion_t ('INFORMES_SERV')
                     || '\';

                  IF w_cgenrep = 1 OR LOWER (v_extfich) = 'csv'
                  THEN
                     vfilename := v_ptfilename || '.csv';
                  ELSIF LOWER (v_extfich) = 'odt'
                  THEN
                     vfilename := v_ptfilename || '_content.xml';
                  ELSE
                     vfilename := vtfilename;
                  END IF;
               END IF;

               vpasexec := 17;

               IF w_cgenrep = 1 AND UPPER (v_extfich) != 'CSV'
               THEN
                  vdatasource :=
                        'CSV:'
                     || pac_md_common.f_get_parinstalacion_t ('INFORMES_C')
                     || '\'
                     || vfilename;
                  --
                  vint := 'I016';
                  vtfilename := vfilename;
                  vtipoorigen := 'JASPER';
                  vtipodestino := 'PDF';
                  vficheroorigen := vdatasource;
                  vficherodestino := ruta || v_ptfilename || '.PDF';
                  vplantillaorigen :=
                        pac_md_common.f_get_parinstalacion_t ('PLANTI_C')
                     || '\'
                     || v_cinforme;
               ELSIF UPPER (v_extfich) = 'CSV'
               THEN
                  vfilename_ruta :=
                        pac_md_common.f_get_parinstalacion_t ('INFORMES_C')
                     || '\'
                     || vfilename;
                  vfilename := vfilename;
                  --
                  vint := '';
                  vtfilename := vfilename;
                  vtipoorigen := 'CSV';
                  vtipodestino := 'CSV';
                  vficheroorigen := vfilename_ruta;
                  vficherodestino := ruta || vfilename;
                  vplantillaorigen := NULL;
               ELSIF v_cgenpdf = 1 AND UPPER (v_extfich) != 'ODT'
               THEN
                  fichdestino :=
                         SUBSTR (vfilename, 1, LENGTH (vfilename) - 3)
                         || 'pdf';
                  --
                  vint := 'I008';
                  vtfilename := vfilename;
                  vtipoorigen := 'RTF';
                  vtipodestino := 'PDF';
                  vficheroorigen := ruta || vfilename;
                  vficherodestino := ruta || fichdestino;
                  vplantillaorigen :=
                        pac_md_common.f_get_parinstalacion_t ('PLANTI_C')
                     || '\'
                     || v_cinforme;
               ELSIF UPPER (v_extfich) = 'ODT'
               THEN
                  SELECT DECODE (v_cgenpdf, 1, 'PDF', 'ODT')
                    INTO v_extfichout
                    FROM DUAL;

                  fichdestino := v_ptfilename || '.' || v_extfichout;
                  --
                  vint := 'I008';
                  vtfilename := vfilename;
                  vtipoorigen := 'ODT_XML';
                  vtipodestino := v_extfichout;
                  vficheroorigen := ruta || vfilename;
                  vficherodestino := ruta || fichdestino;
                  vplantillaorigen :=
                        pac_md_common.f_get_parinstalacion_t ('PLANTI_C')
                     || '\'
                     || v_cinforme;
               END IF;

               vpasexec := 18;

               UPDATE doc_diferida_det
                  SET tdescripcion = vdescripcion,
                      tfilename = vficherodestino,
                      ctipodoc = v_ctipodoc,
                      idcat = v_idcat,
                      cgenfich = v_cgenfich,
                      iddocgedox = NULL,
                      ccategoria = cr.ccategoria,
                      cdiferido = cr.cdiferido
                WHERE iddocdif = piddocdif AND norden = vnorden;

               --Si no ha de generar el documento, lo subimos directamente a gedox
               --y no lo añadimos al cursor que le pasaremos al DaemonReporter
               --puesto que no lo tiene que generar
               IF v_cgenfich = 0
               THEN
                  vpasexec := 19;
                  vnumerr :=
                     f_gedox_pendiente (piddocdif,
                                        vnorden,
                                        vfilename,
                                        ruta,
                                        NULL
                                       );
               ELSE
                  vpasexec := 20;
                  vquery :=
                        vquery
                     || 'select '''
                     || vtipoorigen
                     || ''' tipoorigen, '''
                     || vtipodestino
                     || ''' tipodestino , '''
                     || vficheroorigen
                     || ''' ficheroorigen, '''
                     || vficherodestino
                     || ''' ficherodestino, '''
                     || vplantillaorigen
                     || ''' plantillaorigen, '''
                     || vnorden
                     || ''' norden, '''
                     || vint
                     || ''' int, '''
                     || vdestdocs
                     || ''' destcopia from dual union ';
               END IF;
            ELSE
               --borramos el registro de doc_diferida_det si no tiene que generarse
               DELETE      doc_diferida_det
                     WHERE iddocdif = piddocdif AND norden = vnorden;

               DELETE      docsimpresion
                     WHERE iddocdif = piddocdif AND norden = vnorden;
            END IF;
         END IF;
      END LOOP;

      vquery := RTRIM (vquery, ' union ');

      IF (vquery IS NOT NULL)
      THEN
         vquery := RTRIM (vquery, ' union ');

         OPEN vcur FOR vquery;
      END IF;

      SELECT COUNT (*)
        INTO vtotal
        FROM doc_diferida_det
       WHERE iddocdif = piddocdif;

      IF (vtotal = 0)
      THEN
         UPDATE doc_diferida
            SET cestado = 0
          WHERE iddocdif = piddocdif;
      END IF;

      COMMIT;
      RETURN vcur;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_MD_IMPRESION.f_genera_pendientes',
                      vpasexec,
                      SQLCODE,
                      SQLERRM
                     );

         IF vcur%ISOPEN
         THEN
            CLOSE vcur;
         END IF;

         IF vpasexec NOT IN (4, 10)
         THEN
            f_error_pendientes (piddocdif,
                                   'f_genera_pendientes '
                                || '#'
                                || vpasexec
                                || '#'
                                || SQLCODE
                                || '#'
                                || SQLERRM
                               );
         ELSE
            f_error_pendientes
               (piddocdif,
                   'f_genera_pendientes, No hay datos en PROD_PLANT_CAB/DETPLANTILLAS'
                || '#'
                || vpasexec
               );
         END IF;

         ROLLBACK;
         RETURN NULL;
   END f_genera_pendientes;

   FUNCTION f_gedox_pendiente (
      piddocdif    IN   NUMBER,
      pnorden      IN   NUMBER,
      ptfilename   IN   VARCHAR2,
      ptruta       IN   VARCHAR2,
      pterror      IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      mensajes        t_iax_mensajes;
      vpasexec        NUMBER          := 0;
      vnumerr         NUMBER;
      --
      vtdescripcion   VARCHAR2 (250);
      vtfilename      VARCHAR2 (250);
      vctipodoc       NUMBER;
      vidcat          NUMBER;
      viddocgedox     NUMBER;
      vccategoria     NUMBER;
      vcdiferido      NUMBER;
      vsseguro        NUMBER;
      vnmovimi        NUMBER;
      vnrecibo        NUMBER;
      vnsinies        NUMBER;
      vsidepag        NUMBER;
      vsproces        NUMBER;
      vcagente        NUMBER;
      vcidioma        NUMBER;
      vctipo          NUMBER;
      v_cgenfich      NUMBER;
      --
      v_ntramit       NUMBER;
      v_cdocume       NUMBER;
      v_cobliga       NUMBER;
      --
      v_dirpdfgdx     VARCHAR2 (250);
      v_ndocume       NUMBER;
      vcount          NUMBER;
      --
      v_email         VARCHAR2 (100);
      v_subject       VARCHAR2 (250);
      v_pruta         VARCHAR2 (2000);
      v_name          VARCHAR2 (2000);
      v_res           NUMBER;
      v_retemail      NUMBER;
   BEGIN
      IF pterror IS NOT NULL
      THEN
         f_error_pendientes (piddocdif, pterror);
         COMMIT;
         RETURN 0;
      END IF;

      SELECT d.sseguro, d.nmovimi, d.nrecibo, d.nsinies, d.sidepag,
             d.sproces, d.cagente, d.cidioma, d.ctipo, dd.tdescripcion,
             dd.tfilename, dd.ctipodoc, dd.idcat, dd.cgenfich, dd.iddocgedox,
             dd.ccategoria, dd.cdiferido, d.email, d.subject
        INTO vsseguro, vnmovimi, vnrecibo, vnsinies, vsidepag,
             vsproces, vcagente, vcidioma, vctipo, vtdescripcion,
             vtfilename, vctipodoc, vidcat, v_cgenfich, viddocgedox,
             vccategoria, vcdiferido, v_email, v_subject
        FROM doc_diferida_det dd, doc_diferida d
       WHERE dd.iddocdif = piddocdif
         AND dd.norden = pnorden
         AND dd.iddocdif = d.iddocdif;

      IF v_cgenfich = 0
      THEN
         v_dirpdfgdx := pac_md_common.f_get_parinstalacion_t ('PDFGENGDX');
      ELSE
         v_dirpdfgdx := pac_md_common.f_get_parinstalacion_t ('GEDOX_DIR');
      END IF;

      vpasexec := 1;

      IF vctipodoc = 2
      THEN
         --Pugem el document al servidor, i l'associem al sinistre.
         v_ntramit := 0;
         v_cdocume := 99;
         v_cobliga := 0;
         vpasexec := 2;

         DECLARE
            v_aux       NUMBER;
            v_ctramte   sin_tramite.ctramte%TYPE;
         BEGIN
            SELECT COUNT (1)
              INTO v_aux
              FROM sin_tramitacion
             WHERE nsinies = vnsinies AND ntramit = v_ntramit;

            vpasexec := 3;

            IF v_aux = 0
            THEN
               SELECT MIN (ntramit)
                 INTO v_ntramit
                 FROM sin_tramitacion
                WHERE nsinies = vnsinies;
            END IF;

            vpasexec := 4;
            v_aux := v_ntramit;

            IF pac_sin_tramite.ff_hay_tramites (vnsinies) = 1
            THEN
               SELECT b.ctramte
                 INTO v_ctramte
                 FROM sin_tramitacion a, sin_tramite b
                WHERE a.nsinies = vnsinies
                  AND a.ntramit = v_aux
                  AND b.nsinies = a.nsinies
                  AND b.ntramte = a.ntramte;

               vpasexec := 5;

               IF v_ctramte = 9999
               THEN
                  -- Identificar la tramitacion del tramite convencional
                  SELECT MIN (ta.ntramit)
                    INTO v_ntramit
                    FROM sin_tramitacion ta, sin_tramite te
                   WHERE ta.nsinies = te.nsinies
                     AND ta.nsinies = vnsinies
                     AND ta.ntramte = te.ntramte
                     AND te.ctramte <> 9999;
               END IF;
            END IF;
         END;

         vpasexec := 6;
         vnumerr :=
            f_set_documsinistresgedox (vsseguro,
                                       NVL (vnmovimi, 0),
                                       vnsinies,
                                       NVL (v_ntramit, 0),
                                       v_cdocume,
                                       v_cobliga,
                                       f_user,
                                       ptfilename,
                                       vtdescripcion,
                                       vidcat,
                                       viddocgedox,
                                       mensajes,
                                       v_dirpdfgdx
                                      );
      ELSIF vctipodoc = 3
      THEN
         --Recibos
         --Pugem el document al servidor
         vpasexec := 7;
         vnumerr :=
            f_set_documrecibogedox (vsseguro,
                                    vnrecibo,
                                    f_user,
                                    ptfilename,
                                    vtdescripcion,
                                    vidcat,
                                    viddocgedox,
                                    mensajes,
                                    v_dirpdfgdx
                                   );

         SELECT MAX (ndocume)
           INTO v_ndocume
           FROM recibo_documentos
          WHERE nrecibo = vnrecibo AND iddoc = 0;

         vpasexec := 8;

         IF v_ndocume IS NOT NULL
         THEN
            UPDATE recibo_documentos
               SET iddoc = viddocgedox
             WHERE nrecibo = vnrecibo AND ndocume = v_ndocume;

            vpasexec := 9;
            COMMIT;
         END IF;
      ELSE
         vpasexec := 10;
         --Pugem el document al servidor, i l'associem al moviment.
         vnumerr :=
            f_set_documgedox (vsseguro,
                              NVL (vnmovimi, 0),
                              f_user,
                              ptfilename,
                              vtdescripcion,
                              vidcat,
                              viddocgedox,
                              mensajes,
                              v_dirpdfgdx
                             );
      END IF;

      vpasexec := 11;

      UPDATE doc_diferida_det
         SET iddocgedox = viddocgedox
       WHERE iddocdif = piddocdif AND norden = pnorden;

      vpasexec := 12;

      SELECT COUNT (1)
        INTO vcount
        FROM doc_diferida_det
       WHERE iddocdif = piddocdif AND iddocgedox IS NULL;

      vpasexec := 13;

      IF vcount = 0
      THEN
         UPDATE doc_diferida
            SET cestado = 0
          WHERE iddocdif = piddocdif;
      END IF;

      --Impresión diferida
      IF v_email IS NULL
      THEN
         vnumerr :=
            pac_md_impresion.f_ins_doc (viddocgedox,
                                        vtdescripcion,
                                        vtfilename,
                                        vctipo,
                                        vcdiferido,
                                        vccategoria,
                                        vsseguro,
                                        vnmovimi,
                                        vnrecibo,
                                        vnsinies,
                                        vsidepag,
                                        vsproces,
                                        vcagente,
                                        vcidioma,
                                        piddocdif,
                                        pnorden,
                                        mensajes
                                       );
      ELSE
         v_res := pac_util.f_path_filename (vtfilename, v_pruta, v_name);
         v_retemail :=
            pac_md_informes.f_enviar_mail (NULL,
                                           v_email,
                                           NULL,
                                           v_name,
                                           v_subject,
                                           NULL,
                                           NULL,
                                           NULL,
                                           v_dirpdfgdx
                                          );
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_MD_IMPRESION.f_gedox_pendiente',
                      vpasexec,
                      SQLCODE,
                      SQLERRM
                     );
         ROLLBACK;
         f_error_pendientes (piddocdif,
                                'f_gedox_pendientes '
                             || '#'
                             || vpasexec
                             || '#'
                             || SQLCODE
                             || '#'
                             || SQLERRM
                            );
         RETURN 1;
   END f_gedox_pendiente;

   FUNCTION f_set_fichzip (
      psproces   IN   NUMBER,
      ptagrupa   IN   VARCHAR2,
      pcestado   IN   NUMBER,
      pterror    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      vnumerr   NUMBER := 0;
   BEGIN
      IF pcestado = 1 OR pterror IS NOT NULL OR ptagrupa IS NULL
      THEN
         UPDATE procesosimpagrup
            SET estado = 2,
                terror =
                      f_axis_literales (151632, pac_md_common.f_get_cxtidioma)
                   || '. '
                   || pterror
          WHERE sproces = psproces;
      ELSE
         DELETE      procesosimpagrup
               WHERE sproces = psproces;

         DECLARE
            lv_appendstring2   VARCHAR2 (32000)
                                               := RTRIM (ptagrupa, ',')
                                                  || ',';
            lv_resultstring    VARCHAR2 (500);
            lv_count           NUMBER;
         BEGIN
            LOOP
               EXIT WHEN NVL (INSTR (lv_appendstring2, ','), -99) < 0;
               lv_resultstring :=
                  SUBSTR (lv_appendstring2,
                          1,
                          (INSTR (lv_appendstring2, ',') - 1)
                         );
               lv_count := INSTR (lv_appendstring2, ',') + 1;
               lv_appendstring2 :=
                  SUBSTR (lv_appendstring2,
                          lv_count,
                          LENGTH (lv_appendstring2)
                         );

               INSERT INTO procesosimpagrup
                           (sproces, estado,
                            tagrupa
                           )
                    VALUES (psproces, 0,
                               pac_md_common.f_get_parinstalacion_t
                                                              ('INFORMES_SERV')
                            || '\'
                            || lv_resultstring
                           );
            END LOOP;
         END;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_MD_IMPRESION.f_set_fichzip',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 1;
   END f_set_fichzip;

   FUNCTION f_imprimir_via_correo (
      pcempres         IN       NUMBER,
      pmodo            IN       VARCHAR2,
      ptevento         IN       VARCHAR2,
      pcidioma         IN       NUMBER,
      pdirectorio      IN       VARCHAR2,
      pdocumentos      IN       VARCHAR2,
      pmimestypes      IN       VARCHAR2,
      pdestinatarios   IN       VARCHAR2,
      psproduc         IN       VARCHAR2,
      psseguro         IN       NUMBER,
      mensajes         IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)          := 0;
      vpasexec   NUMBER (8)          := 0;
      vobject    VARCHAR2 (50)    := 'PAC_MD_IMPRESION.f_imprimir_via_correo';
      vparam     VARCHAR2 (500)
         :=    ' pcempres: '
            || pcempres
            || ' pmodo: '
            || pmodo
            || ' ptevento: '
            || ptevento
            || ' pcidioma: '
            || pcidioma
            || ' pdirectorio: '
            || pdirectorio
            || ' pdocumentos: '
            || pdocumentos
            || ' pmimestypes: '
            || pmimestypes
            || ' pdestinatarios: '
            || pdestinatarios
            || ' psproduc: '
            || psproduc;
      conn       UTL_SMTP.connection;
      vt_obj     t_iax_impresion     := t_iax_impresion ();
      vnomarch   VARCHAR2 (2000);
      vesfinal   BOOLEAN;
   BEGIN
      vpasexec := 1;
      vnumerr :=
         pac_cfg.f_enviar_mail_adjunto (pcempres,
                                        pmodo,
                                        ptevento,
                                        pcidioma,
                                        pdirectorio,
                                        pdocumentos,
                                        pmimestypes,
                                        pdestinatarios,
                                        psproduc,
                                        psseguro
                                       );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_imprimir_via_correo;

   FUNCTION f_imprimir_renovcero (
      p_sseguro   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)       := 0;
      vpasexec       NUMBER (8)       := 1;
      vparam         VARCHAR2 (500)   := ' p_sseguro: ' || p_sseguro;
      vobject        VARCHAR2 (200)
                                   := 'PAC_MD_IMPRESION.f_imprimir_renovcero';
      vctipo         NUMBER (2);
      vparamimp      pac_isql.vparam;
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion  := t_iax_impresion ();
      v_sproduc      NUMBER;
      v_fefecto      DATE;
      v_ccodplan     VARCHAR2 (20);
      vtfilename     VARCHAR2 (200);
      v_plantilla    VARCHAR2 (20);
      vobj           ob_iax_impresion := ob_iax_impresion ();
      vcount         NUMBER           := 0;

      CURSOR c1 (
         vcr_sproduc   IN   NUMBER,
         vcr_fefecto   IN   DATE,
         v_plantilla   IN   VARCHAR
      )
      IS
         SELECT   p.ccodplan, cp.idconsulta, p.ccategoria, p.cdiferido
             FROM prod_plant_cab p, codiplantillas cp
            WHERE p.sproduc = vcr_sproduc
              AND vcr_fefecto BETWEEN fdesde AND NVL (fhasta, vcr_fefecto)
              AND p.ctipo = 43
              AND p.ccodplan = cp.ccodplan
              AND p.ccodplan = NVL (v_plantilla, p.ccodplan)
         ORDER BY p.ccodplan;
   BEGIN
      vpasexec := 2;
      --Obtenemos los parámetros necesarios para imprimir la plantilla.
      vparamimp (1).par := 'PMT_SSEGURO';
      vparamimp (1).val := p_sseguro;
      vparamimp (2).par := 'PMT_IDIOMA';
      vparamimp (2).val := pac_iax_common.f_get_cxtidioma;
      vparamimp (3).par := 'PMT_CDUPLICA';
      vparamimp (3).val := NVL (f_get_cduplica (43), 0);
      -- Bug 0022030 - 23/04/2012 - JMF
      vpasexec := 3;

      SELECT sproduc, fefecto
        INTO v_sproduc, v_fefecto
        FROM seguros
       WHERE sseguro = p_sseguro;

      vob_info_imp := f_get_infoimppol (p_sseguro, 43, 'POL', mensajes);
      v_plantilla := NULL;
      v_plantilla :=
                 pac_parametros.f_parproducto_t (v_sproduc, 'PLANT_RENOVCERO');

      FOR f1 IN c1 (v_sproduc, v_fefecto, v_plantilla)
      LOOP
         v_ccodplan := f1.ccodplan;
         vtfilename :=
               p_sseguro
            || '_'
            || v_ccodplan
            || '_'
            || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
            || '.rtf';
         vpasexec := 4;
         --Impresión de la plantilla.
         vobj :=
            f_detimprimir (vob_info_imp,
                           v_ccodplan,
                           vparamimp,
                           vtfilename,
                           mensajes
                          );

         IF vobj IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         vt_obj.EXTEND;
         vt_obj (vt_obj.LAST) := vobj;
         vcount := vcount + 1;
      END LOOP;

      IF vcount = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9904597);
         RAISE e_object_error;
      END IF;

      vpasexec := 8;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_renovcero;

   FUNCTION f_imprimir_sproces_ccompani (
      p_sproces    IN       NUMBER,
      p_ccompani   IN       NUMBER,
      p_tipo       IN       VARCHAR2,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)      := 0;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (500)
         :=    'p_sproces: '
            || p_sproces
            || ' p_ccompani: '
            || p_ccompani
            || ' p_tipo: '
            || p_tipo;
      vobject        VARCHAR2 (200)
                             := 'PAC_MD_IMPRESION.f_imprimir_sproces_ccompani';
      vctipo         NUMBER (8);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vob_info_imp.sproces := p_sproces;
      vob_info_imp.ccompani := p_ccompani;
      vob_info_imp.sproduc := 0;
      vob_info_imp.cidioma := pac_md_common.f_get_cxtidioma;
      vob_info_imp.cempres := pac_md_common.f_get_cxtempresa;
      vob_info_imp.cagente := pac_md_common.f_get_cxtagente;
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_sproces_ccompani;

   FUNCTION f_imprimir_movimiento (
      p_sseguro   IN       NUMBER,
      p_nmovimi   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER                   := 0;
      vpasexec       NUMBER                   := 0;
      vobject        VARCHAR2 (50)
                                  := 'PAC_MD_IMPRESION.f_imprimir_movimiento';
      vparam         VARCHAR2 (500)
                     := ' seguro: ' || p_sseguro || ' nmovimi: ' || p_nmovimi;
      v_ctipo        NUMBER;
      v_cmotmov      movseguro.cmotmov%TYPE;
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN
      vpasexec := 1;

      --Comprovació de paràmetres
      IF p_sseguro IS NULL OR p_nmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT DECODE (cmovseg, 0, 0, 3, 13, 8, 23, 4, 37, 8), cmotmov
        INTO v_ctipo, v_cmotmov
        FROM movseguro
       WHERE sseguro = p_sseguro AND nmovimi = p_nmovimi;

      IF v_ctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF (v_ctipo = 8)
      THEN
         IF (v_cmotmov IS NULL)
         THEN
            RAISE e_param_error;
         ELSIF (v_cmotmov IN (500, 600))
         THEN
            v_ctipo := 7;
         END IF;
      END IF;

      vpasexec := 3;
      vob_info_imp := f_get_infoimppol (p_sseguro, v_ctipo, 'POL', mensajes);
      vpasexec := 4;
      vob_info_imp.nmovimi := p_nmovimi;
      vpasexec := 5;
      vt_obj :=
               f_imprimir (vob_info_imp, TRUNC (f_sysdate), v_ctipo, mensajes);

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_movimiento;

   --INI --BUG 33632/209087-- ETM  --03/07/2015--
   FUNCTION f_mail_agente (p_sseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2
   IS
      vnumerr    NUMBER                       := 0;
      vpasexec   NUMBER                       := 0;
      vobject    VARCHAR2 (50)           := 'PAC_MD_IMPRESION. f_mail_agente';
      vparam     VARCHAR2 (500)               := ' seguro: ' || p_sseguro;
      v_ctipo    NUMBER;
      v_email    per_contactos.tvalcon%TYPE;
   BEGIN
      BEGIN
         SELECT p.tvalcon
           INTO v_email
           FROM seguros s, per_contactos p, agentes a
          WHERE s.sseguro = p_sseguro
            AND s.cagente = a.cagente
            AND a.sperson = p.sperson
            AND p.ctipcon = 3
            AND p.cmodcon IN (SELECT MAX (cmodcon)
                                FROM per_contactos pp
                               WHERE pp.sperson = p.sperson);
      EXCEPTION
         WHEN OTHERS
         THEN
            vpasexec := 1;
            v_email := NULL;
      END;

      RETURN v_email;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_mail_agente;

--fin --BUG 33632/209087-- ETM --03/07/2015--

   /*************************************************************************
      Impresión  PAGOS
      param in p_sseguro    : id de seguro
       param in P_SIDEGAP   : ID. DE PAGOS A  imprimir
       param in P_TIPO      : ctipo plantillas
       param in  p_ccausin : causa del siniestro
       param in p_cmotsin : motivo del siniestro
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cashdesk (
      p_refdeposito   IN       NUMBER,
      p_tipo          IN       VARCHAR,
      mensajes        IN OUT   t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec       NUMBER (8)                     := 1;
      vparam         VARCHAR2 (1000)    := 'p_refdeposito: ' || p_refdeposito;
      vobject        VARCHAR2 (200)     := 'PAC_MD_IMPRESION.f_imprimir_pago';
      vctipo         NUMBER (2);
      vob_info_imp   ob_info_imp;
      vparamimp      pac_isql.vparam;
      vt_obj         t_iax_impresion                := t_iax_impresion ();
      vobj           ob_iax_impresion               := ob_iax_impresion ();
      registro       NUMBER;
      vtfilename     VARCHAR2 (200);
      v_movimi       NUMBER;
      v_movseg       NUMBER;
      v_error        NUMBER;
      v_errorid      NUMBER;
      vcodplan       prod_plant_cab.ccodplan%TYPE;
      vseqcaja       caja_datmedio.seqcaja%TYPE;
      vsperson       per_personas.sperson%TYPE;
      vcagente       per_personas.cagente%TYPE;
      viddocgedox    NUMBER;
      counter        NUMBER:=0;

      CURSOR c_seguros (p_nrefe NUMBER)
      IS
         SELECT DISTINCT sseguro
                    FROM caja_datmedio
                   WHERE nrefdeposito = p_nrefe;
   BEGIN
      --Comprovació de paràmetres
      IF p_refdeposito IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --vob_info_imp.refdeposito := p_refdeposito;
      vob_info_imp.sproduc := 0;
      vob_info_imp.cidioma := pac_md_common.f_get_cxtidioma;
      vob_info_imp.cempres := pac_md_common.f_get_cxtempresa;
      vob_info_imp.cagente := pac_md_common.f_get_cxtagente;
      vparamimp (1).par := 'PMT_NREFDEPOSITO';
      vparamimp (1).val := p_refdeposito;

      --
      BEGIN
         SELECT ppc.ccodplan
           INTO vcodplan
           FROM prod_plant_cab ppc
          WHERE sproduc = vob_info_imp.sproduc AND ctipo = vctipo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE e_param_error;
         WHEN TOO_MANY_ROWS
         THEN
            RAISE e_param_error;
      END;

      --
      BEGIN
         OPEN c_seguros (p_refdeposito);

         LOOP
            FETCH c_seguros
             INTO registro;

            EXIT WHEN c_seguros%NOTFOUND;
            --
            vparamimp (2).par := 'PMT_SSEGURO';
            vparamimp (2).val := registro;
            --
            vtfilename :=
                  vcodplan
               || '_' || counter || '_'
               || TO_CHAR (f_sysdate, 'yyyymmddhh24misssss')
               || '.PDF';
            counter:=counter+1;
            vobj :=
               f_detimprimir (vob_info_imp,
                              vcodplan,
                              vparamimp,
                              vtfilename,
                              mensajes
                             );

            IF vobj IS NULL
            THEN
               RAISE e_object_error;
            END IF;

            vpasexec := 7;
            vt_obj.EXTEND;
            vt_obj (vt_obj.LAST) := vobj;

            --
            IF registro = 0
            THEN
               --
               SELECT p.sperson, p.cagente
                 INTO vsperson, vcagente
                 FROM personas p
                WHERE sperson =
                         (SELECT DISTINCT cj.sperson
                                     FROM cajamov cj
                                    WHERE cj.seqcaja IN (
                                             SELECT dm.seqcaja
                                               FROM caja_datmedio dm
                                              WHERE dm.nrefdeposito =
                                                                 p_refdeposito));

               --
               v_error :=
                  pac_md_gedox.f_set_documpersgedox
                          (vsperson,
                           vcagente,
                           pac_md_common.f_get_cxtusuario (),
                           NULL,
                           f_literal (109479, pac_md_common.f_get_cxtidioma),
                           vtfilename,
                           viddocgedox,
                           pidcat        => 1,
                           ptdesc        => f_literal
                                                (109479,
                                                 pac_md_common.f_get_cxtidioma
                                                ),
                           mensajes      => mensajes
                          );
            --
            ELSE
               --
               SELECT MAX (nmovimi)
                 INTO v_movimi
                 FROM movseguro
                WHERE sseguro = registro;

               v_errorid := pac_axisgedox.f_get_secuencia (v_movseg);

               IF v_errorid IS NULL
               THEN
                  RAISE e_object_error;
               END IF;

               v_error :=
                  pac_iax_gedox.f_set_docummovseggedox
                                              (registro,
                                               v_movimi,
                                               vtfilename,
                                               NULL,
                                               f_axis_literales (152676,
                                                                 f_usu_idioma
                                                                ),
                                               1,
                                               0,
                                               mensajes
                                              );
            --
            END IF;

            --
            IF v_error IS NULL
            THEN
               RAISE e_object_error;
            END IF;
         END LOOP;

         CLOSE c_seguros;
      END;

      vpasexec := 4;

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_cashdesk;

   /*************************************************************************
      Procedimiento que repasa los documentos que estan encolados para generarse
      en la tabla doc_diferida y los genera
      param in pnumrows    : Numero de trabajos de la tabla doc_diferida que debe realizar
   *************************************************************************/
   PROCEDURE p_genera_docdiferida (pnumrows NUMBER)
   IS
      mensajes       t_iax_mensajes;
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
      vnumerr        NUMBER;
      vterror        VARCHAR2 (32000) := '';
   BEGIN
      UPDATE doc_diferida
         SET cestado = 99
       WHERE iddocdif IN (SELECT iddocdif
                            FROM (SELECT   iddocdif
                                      FROM doc_diferida
                                     WHERE cestado = 1
                                  ORDER BY iddocdif)
                           WHERE ROWNUM <= pnumrows);

      COMMIT;

      FOR i IN (SELECT   *
                    FROM doc_diferida
                   WHERE cestado = 99
                ORDER BY iddocdif)
      LOOP
         BEGIN
            UPDATE doc_diferida
               SET cestado = 98
             WHERE iddocdif = i.iddocdif;

            COMMIT;
            vnumerr := pac_contexto.f_inicializarctx (i.cuser);
            vob_info_imp :=
                        f_get_infoimppol (i.sseguro, i.ctipo, 'POL', mensajes);
            mensajes := NULL;
            vob_info_imp.nrecibo := i.nrecibo;
            vob_info_imp.nsinies := i.nsinies;
            vob_info_imp.nmovimi := i.nmovimi;
            vob_info_imp.sidepag := i.sidepag;
            vob_info_imp.sproces := i.sproces;
            vob_info_imp.cagente := i.cagente;
            vt_obj :=
               f_imprimir (vob_info_imp, TRUNC (f_sysdate), i.ctipo, mensajes);

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.COUNT > 0
               THEN
                  FOR ind IN mensajes.FIRST .. mensajes.LAST
                  LOOP
                     IF mensajes.EXISTS (ind)
                     THEN
                        vterror := vterror || ' ' || mensajes (ind).terror;
                     END IF;
                  END LOOP;
               END IF;
            END IF;

            IF vterror IS NOT NULL
            THEN
               UPDATE doc_diferida
                  SET terror =
                         NVL ((TRIM (SUBSTR (vterror, 0, 4000))),
                              'Error Connect'
                             ),
                      cusermod = f_user,
                      fmodificado = f_sysdate
                WHERE iddocdif = i.iddocdif;
            ELSE
               UPDATE doc_diferida
                  SET cestado = 0,
                      cusermod = f_user,
                      fmodificado = f_sysdate
                WHERE iddocdif = i.iddocdif;
            END IF;

            COMMIT;
            mensajes := NULL;
            vterror := '';
         EXCEPTION
            WHEN OTHERS
            THEN
               vterror := SQLCODE || ' ' || SQLERRM;

               UPDATE doc_diferida
                  SET terror = SUBSTR (vterror, 0, 4000),
                      cusermod = f_user,
                      fmodificado = f_sysdate
                WHERE iddocdif = i.iddocdif;

               COMMIT;
               mensajes := NULL;
               vterror := '';
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_MD_IMPRESION.P_GENERA_DOCDIFERIDA',
                      0,
                      SQLCODE,
                      SQLERRM
                     );
   END p_genera_docdiferida;

/*
Función que se encarga de imprimir el documento necesario para adjuntar en el envío.
*/
FUNCTION f_imprimir_ensa_mail(
	  pccodplan IN VARCHAR2,
      pinfoimp IN ob_info_imp,
      pfefecto IN DATE,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psproduc: ' || pinfoimp.sproduc || ' pfefecto: ' || pfefecto || ' pctipo: '
            || pctipo;
      vobject        VARCHAR2(200) := 'PAC_MD_IMPRESION.f_imprimir_ensa_mail';
      vtfilename     VARCHAR2(200);
      vparamimp      pac_isql.vparam;
      vt_obj         t_iax_impresion := t_iax_impresion();
      vobj           ob_iax_impresion := ob_iax_impresion();
      viddoc         VARCHAR2(100);
      vplantgedox    VARCHAR2(1);
      c_idconsulta   NUMBER;
      c_ccategoria   NUMBER;
      c_cdiferido    NUMBER;
      v_ncopias      NUMBER;
      v_idcopia      VARCHAR2(10);

   BEGIN
      --Comprovació de paràmetres
      IF pinfoimp.sproduc IS NULL
         OR pfefecto IS NULL
         OR pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

	  p_control_error('RAL', 'PAC_MD_impresion.f_imprimir_ensa_mail', 'Product: '||pinfoimp.sproduc||' pfefecto '||pfefecto||' pctipo '||pctipo);

            SELECT cp.idconsulta, p.ccategoria, p.cdiferido
             INTO c_idconsulta, c_ccategoria, c_cdiferido
             FROM prod_plant_cab p, codiplantillas cp
            WHERE p.sproduc = pinfoimp.sproduc
              AND pfefecto BETWEEN fdesde AND NVL(fhasta, pfefecto)
              AND p.ctipo = pctipo
			  AND p.ccodplan = pccodplan
              AND p.ccodplan = cp.ccodplan
            ORDER BY p.norden, p.ccodplan;

            --Obtenemos los parámetros necesarios para imprimir la plantilla.
            vnumerr := f_get_paramimp(c_idconsulta, pinfoimp, vparamimp);

            --bug 16446 - ETM - 31/12/2010
            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            vpasexec := 5;

            --Impresión de documentación de póliza => nomenclatura específica
            vtfilename := pccodplan||'_'||pinfoimp.npoliza||'-'||pinfoimp.ncertif||'_'||pinfoimp.nrecibo||'.rtf'; --Nombre que tendrá el fichero que generemos

            vobj := f_detimprimir(pinfoimp, pccodplan, vparamimp, vtfilename || v_idcopia,
                                  mensajes);

            -- FI BUG 10078  - 13/05/2009 – ICV
            IF vobj IS NULL THEN
               RAISE e_object_error;
            END IF;

            vnumerr := f_get_params(vobj, pinfoimp, pctipo, mensajes);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;

            vobj.ctipo := pctipo;
            vobj.ttipo := ff_desvalorfijo(317, pac_md_common.f_get_cxtidioma, pctipo);
            vobj.ccategoria := c_ccategoria;
            vobj.cdiferido := c_cdiferido;
            ---grabem al ob...tipus i valors
            vpasexec := 7;
            vt_obj.EXTEND;
            vt_obj(vt_obj.LAST) := vobj;

      IF vt_obj IS NOT NULL THEN
         IF vt_obj.COUNT > 0 THEN
            FOR cvt_obj IN vt_obj.FIRST .. vt_obj.LAST LOOP
               IF vt_obj.EXISTS(cvt_obj) THEN
                  vnumerr := f_obtener_valor_columna(vt_obj(cvt_obj).info_campos, 'IDDOC',
                                                     viddoc, mensajes);
                  vnumerr := f_obtener_valor_columna(vt_obj(cvt_obj).info_campos, 'GEDOX',
                                                     vplantgedox, mensajes);
               END IF;

               IF vplantgedox = 'S'
                  AND viddoc IS NOT NULL THEN
                  vnumerr := pac_md_impresion.f_ins_doc(TO_NUMBER(viddoc),
                                                        vt_obj(cvt_obj).descripcion,
                                                        vt_obj(cvt_obj).fichero,
                                                        vt_obj(cvt_obj).ctipo,
                                                        vt_obj(cvt_obj).cdiferido,
                                                        vt_obj(cvt_obj).ccategoria,
                                                        pinfoimp.sseguro, pinfoimp.nmovimi,
                                                        pinfoimp.nrecibo, pinfoimp.nsinies,
                                                        pinfoimp.sidepag, pinfoimp.sproces,
                                                        pinfoimp.cagente, pinfoimp.cidioma,
                                                        NULL, NULL, mensajes);
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN vt_obj;
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
   END f_imprimir_ensa_mail;

/*
Función que recupera toda la información de la póliza para poder crear los documentos de envío de recibo en el proceso de Maiing de Ensa.
*/
   PROCEDURE f_imprimir_recibo_ensa_mail(
      p_nrecibo IN NUMBER,
      p_ndocume IN NUMBER,
      p_sseguro IN NUMBER,
	  p_ccodplan IN VARCHAR2,
      p_tipo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes) IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'p_nrecibo: ' || p_nrecibo || ' p_sseguro: ' || p_sseguro || ' p_tipo: ' || p_tipo;
      vobject        VARCHAR2(200) := 'PAC_MD_IMPRESION.f_imprimir_recibo_ensa_mail';
      vctipo         NUMBER(2);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN

      vpasexec := 2;
      vctipo := f_get_tipo(p_tipo);

      IF vctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vob_info_imp := f_get_infoimppol(p_sseguro, vctipo, 'POL', mensajes);
      vob_info_imp.nrecibo := p_nrecibo;
      vob_info_imp.ndocume := p_ndocume;
      vt_obj := f_imprimir_ensa_mail(p_ccodplan, vob_info_imp, TRUNC(f_sysdate), vctipo, mensajes);

      IF vt_obj IS NULL THEN
         RAISE e_object_error;
      END IF;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'AVISOREIMPREC'), 0) =
                                                                                              1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9904561);
      END IF;

      --BUG24687 -JTS- 27/11/2012 Tipo de impresión con actualización de estado
      IF vctipo = 40 THEN
         UPDATE recibos
            SET cestimp = 2
          WHERE nrecibo = p_nrecibo;

         COMMIT;
      END IF;

   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END f_imprimir_recibo_ensa_mail;


      /*************************************************************************
      f_imprimir_sinies_soldoc
      pctipo IN NUMBER
      psseguro IN NUMBER
      pnsinies IN VARCHAR2
      pntramit IN NUMBER
      psidepag IN NUMBER
      mensajes OUT T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_imprimir_sinies_soldoc(
      pctipo IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      mensajes OUT T_IAX_MENSAJES)
      RETURN t_iax_impresion IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
         :=    'pctipo: '
            || pctipo
            || ' psseguro: '
            || psseguro
            || ' pnsinies: '
            || pnsinies
            || ' pntramit: '
            || pntramit
            || ' psidepag: '
            || psidepag;
      vobject    VARCHAR2 (200)  := 'PAC_MD_IMPRESION.f_imprimir_sinies_soldoc';
      vt_obj     t_iax_impresion;
      vob_info_imp   ob_info_imp;
   BEGIN

      IF pctipo IS NULL
         OR psseguro IS NULL
         OR pnsinies IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pctipo = 74 AND psidepag IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vob_info_imp := f_get_infoimppol (psseguro, pctipo, 'POL', mensajes);
      vob_info_imp.sidepag := psidepag;
      vob_info_imp.nrecibo := pnsinies;

      SELECT MAX (nsinies)
        INTO vob_info_imp.nsinies
        FROM sin_tramita_pago
       WHERE sidepag = psidepag;

      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), pctipo, mensajes);
      vpasexec := 4;

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_sinies_soldoc;

   /*************************************************************************
      --CONF578- JTS - 31/01/2017
      Impresión personas
      param in PSPERSON  : ID. persona
      param in P_TIPO      : ctipo de documento
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_sperson(
      p_sperson IN NUMBER,
      p_tipo IN VARCHAR2,
      -- INI - TCS_324B - JLTS - 11/02/2019. Se adiciona la opción idioma por parámetro
      p_cidiomarep IN NUMBER DEFAULT NULL,
      -- FIN - TCS_324B - JLTS - 11/02/2019.
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)      := 0;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (500)
                       := 'p_sperson: ' || p_sperson || ' p_tipo: ' || p_tipo;
      vobject        VARCHAR2 (200)  := 'PAC_MD_IMPRESION.f_imprimir_sperson';
      vctipo         NUMBER (3);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);

      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vob_info_imp.sperson := p_sperson;
      vob_info_imp.sproduc := 0;
      vob_info_imp.cidioma := pac_md_common.f_get_cxtidioma;
      -- INI - TCS_324B - JLTS - 08/02/2019. Se adiciona la opción de idioma por parámetro
      vob_info_imp.cidiomarep := p_cidiomarep;
      -- FIN - TCS_324B - JLTS - 08/02/2019.
      vob_info_imp.cempres := pac_md_common.f_get_cxtempresa;
      vob_info_imp.cagente := pac_md_common.f_get_cxtagente;
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_sperson;

    /*************************************************************************
      --TCS_19 - ACL - 08/03/2019
      Impresión pagare contragarantia
      param in pscontgar  : ID. contragarantia
      param in P_TIPO      : ctipo de documento
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_scontgar(
      p_scontgar IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)      := 0;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (500)
                       := 'p_scontgar: ' || p_scontgar;
      vobject        VARCHAR2 (200)  := 'PAC_MD_IMPRESION.f_imprimir_scontgar';
      vctipo         NUMBER (3);
      vob_info_imp   ob_info_imp;
      vt_obj         t_iax_impresion;
   BEGIN

      vpasexec := 2;
      vctipo := f_get_tipo (p_tipo);
      IF vctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;
	  vob_info_imp.sproduc := 0;
      vob_info_imp.scontgar := p_scontgar;
      vob_info_imp.cidioma := pac_md_common.f_get_cxtidioma;
      vt_obj := f_imprimir (vob_info_imp, TRUNC (f_sysdate), vctipo, mensajes);
      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_imprimir_scontgar;
END pac_md_impresion;
/