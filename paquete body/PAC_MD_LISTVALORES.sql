/* Formatted on 2019/09/04 14:39 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY pac_md_listvalores
AS
    /******************************************************************************
      NOMBRE:       PAC_MD_LISTVALORES
      PROPÓSITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor             Descripci??n
      ---------  ----------  ---------------  ------------------------------------
      1.0        25/01/2008   ACC                1. Creaci??n del package.
                 11/02/2009   FAL                Cobradores, delegaciones. Bug: 0007657
                 11/02/2009   FAL                Tipos de apunte, Estado apunte, en/de la agenda. Bug: 0008748
                 12/02/2009   AMC                Siniestros de baja. Bug: 9025
                 25/02/2009   DRA                Bug 0008875: CRE002 - Incidencias en simulaciones
                 06/03/2009   JSP                Agenda de poliza. Bug: 0009208
                 12/03/2009   FAL                Bug 0007657: Cambio en la select de f_get_lstdelegaciones
      2.0        27/02/2009   RSC                Adaptaci??n iAxis a productos colectivos con certificados
      3.0        11/03/2009   RSC                An??lisis adaptaci??n productos indexados
      4.0        01/04/2009   SBG                4. Es crida a PAC_PRODUCTOS.F_Get_FiltroProd dins de f_get_productos
      5.0        15/04/2009   DRA                BUG0009314: APR - pesonalizaci??n de la aplicacion (configuraci??n de campos)
      6.0        11/03/2009   SBG                Nou par??m. p_tmode funci?? p_ompledadesdireccions (Bug 7624)
      7.0        24/04/2009   AMC                Bug 9585 Se a??ade el pcempres a la funci??n f_get_ramos
      8.0        28/04/2009   SBG                Es modifica cursor de funci?? f_get_lstasiento (Bug 7174)
      9.0        06/05/2009   ICV                Bug 0009940: IAX - Pantalla para lanzar maps
     10.0        11/05/2009   ICV                0009784: IAX - An??lisis y desarrollo de Rehabilitaciones
     11.0        23/04/2009   FAL                Parametrizar tipos de anulaci??n de poliza en funci??n de la configuraci??n de acciones del usuario y del producto. Bug 9686.
     12.0        01/10/2009   JRB                0011196: CRE - Gesti??n de propuestas retenidas
     13.0        07/10/2009   ICV                0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
     14.0        22/10/2009   NMM                11563: CEM - B??squeda en gesti??n de retenidas.
     15.0        30/10/2009   NMM                11509: APR - Error en la vision de agentes en simulaciones.
     16.0        12/11/2009   DRA                0011618: AGA005 - Modificaci??n de red comercial y gesti??n de comisiones.
     17.0        12/11/2009   ICV                0011618: AGA005 - Modificaci??n de red comercial y gesti??n de comisiones.
     18.0        15/12/2009   JTS/NMM            10831: CRE - Estado de p??lizas vigentes con fecha de efecto futura
     19.0        01/01/2010   NMM                12712: CEM - Retencion de p??lizas, distinguir IMC de cuestionario.
     20.0        18/02/2010   JMF                0012679 CEM - Treure la taula MOVRECIBOI
     21.0        22/03/2010   JTS                0013477: CRE205 - Nueva pantalla de Gesti??n Pagos Rentas
     22.0        10/05/2010   RSC                0011735: APR - suplemento de modificaci??n de capital /prima
     23.0        04/06/2010   PFA                14588: CRT001 - A??adir campo compa??ia productos
     24.0        18/06/2010   AMC                Bug 15148 - Se a??aden nuevas funciones
     25.0        21/06/2010   AMC                Bug 15149 - Se a??aden nuevas funciones
     26.0        09/08/2010   AVT                15638: CRE998 - Multiregistre cercador de p??lisses (Asegurat)
     27.0        14/09/2010   AMC                15137: MDP Desarrollo de Cuadro Comisiones
     28.0        20/09/2010   JRH                28. 0015869: CIV401 - Renta vital??cia: incidencias 12/08/2010
     26.0        17/08/2010   PFA                Bug 15006: MDP003 - Incluir nuevos campos en b??squeda siniestros
     30.0        23/11/2010   AMC                0016529: CRT003 - An??lisis listados
     31.0        28/12/2010   JMF                0016529: CRT003 - An??lisis listados
     32.0        24/02/2011   ICV                0017718: CCAT003 - Acc??s a productes en funci?? de l'operaci??
     33.0        25/08/2011   DRA                0019169: LCOL_C001 - Campos nuevos a a??adir para Agentes.
     34.0        30/06/2011   LCF                Bug 18855: LCOL003 - Permitir seleccionar el c??digo de agente en simulaciones
     35.0        02/09/2011   DRA                0018752: LCOL_P001 - PER - An??lisis. Mostrar los tipos de documento en funci??n del tipo de persona.
     36.0        20/09/2011   JMP                0019130: LCOL_T002-Agrupacion productos - Productos Brechas 01
     37.0        22/09/2011   JMP                0019197: LCOL_A001-Liquidacion de comisiones para colombia: sucursal/ADN y corte de cuentas (por el liquido)
     38.0        03/10/2011   APD                0018319: LCOL_A002- Pantalla de mantenimiento del contrato de reaseguro
     39.0        03/10/2011   ETM                BUG 0017383: ENSA101 - Prestacions i altes.Cobrador bancari
     40.0        26/09/2011   DRA                0019069: LCOL_C001 - Co-corretaje
     41.0        08/11/2011   JGR                0019985  LCOL_A001-Control de las matriculas (prenotificaciones)
     42.0        11/11/2011   APD                0019169: LCOL_C001 - Campos nuevos a a??adir para Agentes.
     43.0        03/01/2012   JGR                0020735: LCOL_A001-ADM - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
     44.0        03/01/2011   JMP                0020806: LCOL - UAT - PER - Buscador de agentes
     45.0        10/02/2012   JGR                0020735: LCOL_A001-ADM - Introduccion de cuenta bancaria. Nota:0103205 f_get_lsttipcc
     46.0        17/01/2012   JGR                0020735 - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
     47.0        26/01/2013   JGR                0021097: LCOL_A001-Tener en cuenta el tipo de cuenta en la seleccion del cobrador bancario
     48.0        08/03/2012   JMP                0021569: CRE998 - Configurar llen?ador d'Informes per perfil
     49.0        06/06/2012   APD                0021682: MDP - COM - Transiciones de estado de agente.
     50.0        25/07/2012   JGR                0022082: LCOL_A003-Mantenimiento de matriculas
     60.0        14/08/2012   DCG                0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
     61.0        30/10/2012   XVM                0024058: LCOL_T010-LCOL - Parametrizaci?n de productos Vida Grupo
     62.0        30/10/2012   MDS                0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
     63.0        03/12/2012   JDS                0024682 / 0129504: LCOL_A003-Consulta de cobradores bancarios sin resultados-se produce error si seleccionas uno código no existente.
     64.0        19/12/2012   APD                0025177: LCOL_T031-Modificar modales de consulta con nuevos filtros
     65.0        02/01/2013   ECP                0024655: LCOL_T010-LCOL - Revision incidencias qtracker (II)
     66.0        20/12/2012   MDS                0024717: (POSPG600)-Parametrizacion-Tecnico-Descripcion en listas Tipos Beneficiarios RV - Cambiar descripcion en listas Tipos Beneficiar
     67.0        07/02/2013   DRA                0025936: LCOL: Ajuste visualizaci?n corretaje
     68.0        18/02/2013   MMS                0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza ‘hasta edad’ y edades permitidas por producto. Añadir f_get_lstedadesprod
     69.0        04/03/2013   AEG                0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
     70.0        19/06/2013   JDS                0027051:  LCOL_F2-Fase 2 - Incidencies GUI
     71.0        22/08/2013   DEV                0026443: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 76 -XL capacidad prioridad dependiente del producto (Fase3)
     72.0        16/09/2013   MMM                0028158: LCOL_A003-Listas desplegables de companyias reaseguradoras y coaseguradores no figuren las bajas - QT-9111 (40154)
     73.0        08/10/2013   MMM                0028465: LCOL999-Id. 187 - Contabilidad Cobro recibo debito
     74.0        09/10/2013   SHA                0028454: LCOL895-Añadir la compañ?a propia en la consulta y en el mantenimiento de las cuentas t?cnicas de reaseguro
     75.0        15/10/2013   MMM                0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
     76.0        19/12/2013   DCT                0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
     77.0        07/02/2014   AGG                0030057: POSPG400-Env?o de Indicadores de compa??as a SAP
     78.0        21/05/2014   FAL                0029035: TRQ000 - Mesa CROSS (personas, usuarios, perfiles)
     79.0        22/09/2014   CASANCHEZ          0032668: COLM004-Trapaso entre Bancos (cobrador bancario) manteniendo la nómina
     80.0        17/02/2015   XBA                0034603: Recupera la Lista de las causas para las pignoraciones
     81.0        21/05/2015   CJMR               0035888: Nota 205345 - Realizar la substitución del upper nnumnif o nnumide
     82.0        14/04/2016   DMCC               0041438: Nota 232128 - AMA002-Validaciones (Sin validación de retorno) ID.
     83.0        02/06/2016   VCG                0042968: Bug cliente 0042105 - axisper004 - Alta cuenta bancaria - Ordenar Combos de Bancos
     84.0        12/09/2016   ASDQ               CONF-209-GAP_GTEC50 - Productos multimoneda
     85.0        03/05/2018   VCG                QT-0001704: Listado de Ramos para Convenios
     86.0        17/01/2019   AP                 TCS 468A 17/01/2019 AP Se modifica funcion F_GET_AGRUPACIONES_CONSORCIOS Consorcios y Uniones Temporales
     87.0        14/01/2019   WAJ                Listado de tipos de vinculos y tipos de compañias
     88.0        25/02/2019   CJMR               TCS-344 Marcas: Ajustes de acuerdo a nuevo funcional de Marcas
     89.0        27/02/2019   ACL                TCS_827 Se agrega la función f_get_ramo_contrag.
     90.0        05/04/2019   CES                IAXIS-2065: Ajuste de las tablas de direcciones para traer información de la persona
     91.0        21/08/2019   JLTS               IAXSIS-5100: Ajuste de la función f_get_lstagentes_cond colocandole una condicion de pformato = 55
     92.0        03/09/2019   ECP                IAXIS-4082. Convenio Grandes Beneficiarios - RCE Derivado de Contratos
     93.0        28/10/2019   SGM                IAXIS-6149: Realizar consulta de personas publicas
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_opencursor (squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (4000) := SUBSTR (squery, 1, 1900);
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_OpenCursor';
      terror     VARCHAR2 (200)  := 'No se puede recuperar la informaci??n';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC    PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_opencursor;

   /*************************************************************************
      Recupera la informaci??n de valores seg??n la clave
      param in clave     : clave a recuperar detalles
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalores (clave IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur         sys_refcursor;
      vpasexec    NUMBER (8)      := 1;
      vparam      VARCHAR2 (2000) := 'calve =' || clave;
      vobject     VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_DetValores';
      terror      VARCHAR2 (200)
                        := 'No se puede recuperar la informaci??n de valores';
                                               --//ACC recuperar desde literales
      --//ACC recuperar desde literales
      --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
      vconsulta   VARCHAR2 (2000);            -- Bug 43060 - 30/05/2016 - AMC
   BEGIN
      -- Inicio Bug 43060 - 30/05/2016 - AMC
      vconsulta :=
            'select catribu,tatribu from detvalores '
         || ' where cidioma ='
         || pac_md_common.f_get_cxtidioma ()
         || ' and cvalor='
         || clave;

      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'ORDENAR_DETVALOR'
                                            ),
              0
             ) = 1 or INSTR(nvl(pac_parametros.f_parempresa_t (pac_md_common.f_get_cxtempresa,
                                             'ORDENAR_LST_CVALORES'
                                            ),0
                                            ),','||clave||',')>0 -- EA BUG IAXIS-13329
      THEN
         vconsulta := vconsulta || ' order by tatribu asc';
      END IF;

      -- Fin Bug 43060 - 30/05/2016 - AMC
      cur := f_opencursor (vconsulta, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_detvalores;

   /*************************************************************************
      Recupera la informaci??n de valores seg??n la clave y la condici??n
      param in clave     : clave a recuperar detalles
      param in cond      : condici??n de la consulta (sin where ni and)
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalorescond (
      clave      IN       NUMBER,
      cond       IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      wh         VARCHAR2 (1000);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'clave=' || clave || ' cond=' || cond;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_DetValoresCond';
      terror     VARCHAR2 (200)
                        := 'No se puede recuperar la informaci??n de valores';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      IF NVL (cond, ' ') <> ' '
      THEN
         wh := ' and ' || cond;
      END IF;

      cur :=
         f_opencursor (   'select catribu,tatribu from detvalores '
                       || ' where cidioma ='
                       || pac_md_common.f_get_cxtidioma ()
                       || ' and cvalor='
                       || clave
                       || wh,
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_detvalorescond;

   /*************************************************************************
      Recupera la informaci??n de valores seg??n la clave y la condici??n
      param in clave     : clave a recuperar detalles
      param in cond      : condici??n de la consulta
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalorescond_fil (
      clave      IN       NUMBER,
      cond       IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      wh         VARCHAR2 (1000);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'clave=' || clave || ' cond=' || cond;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_DetValoresCond';
      terror     VARCHAR2 (200)
                        := 'No se puede recuperar la informaci??n de valores';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur :=
         f_opencursor
                  (   'select catribu,tatribu from tramos,detvalores where '
                   || cond
                   || ' and cvalor='
                   || clave
                   || ' and cidioma ='
                   || pac_md_common.f_get_cxtidioma ()
                   || ' and catribu=ctramo',
                   mensajes
                  );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_detvalorescond_fil;

   /*************************************************************************
      Recupera descripci??n de detvalores
      param in clave        : c??digo de la tabla
      param in valor        : c??digo del valor a recuperar
      param in out mensajes : mesajes de error
      return                : descripci??n del valor
   *************************************************************************/
   FUNCTION f_getdescripvalores (
      clave      IN       NUMBER,
      valor      IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      RESULT     VARCHAR2 (100);
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'clave=' || clave || ' valor=' || valor;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_GetDescripValores';
      terror     VARCHAR2 (500) := 'Error recuperar descripci??n de un valor';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      IF valor IS NULL
      THEN
         RETURN NULL;
      END IF;

      SELECT tatribu
        INTO RESULT
        FROM detvalores
       WHERE cvalor = clave
         AND catribu = valor
         AND cidioma = pac_md_common.f_get_cxtidioma;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );
         RETURN NULL;
   END f_getdescripvalores;

   /*************************************************************************
      Recupera el campo de la sentencia
      param in squery       : sentencia sql
      param in out mensajes : mesajes de error
      return                : descripci??n del valor
   *************************************************************************/
   FUNCTION f_getdescripvalor (
      squery     IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      RESULT     VARCHAR2 (4000) := NULL;
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := SUBSTR (squery, 1, 2000);
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_GetDescripValor';
      terror     VARCHAR2 (500) := 'Error recuperar descripci??n de un valor';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_opencursor (squery, mensajes);

      FETCH cur
       INTO RESULT;

      CLOSE cur;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN RESULT;
   END f_getdescripvalor;

   /*************************************************************************
      Recupera la Lista de distintos ramos, devuelve un ref cursor
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- AMC-Bug9585-24/04/2009- Se a??ade el pcempres
   -- xpl 13-05-2009: bug mantis 0010093, se a??ade el tipo
   FUNCTION f_get_ramos (
      p_tipo     IN       VARCHAR2,
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_Ramos';
      terror     VARCHAR2 (200)  := 'Error recuperar ramos';
      vtipo      VARCHAR2 (2000);
      vempresa   VARCHAR2 (2000);
      v_squery   VARCHAR2 (2000);
      vcontrol   NUMBER;
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      -- xpl 13-05-2009: bug mantis 0010093
      IF pac_productos.f_get_filtroprod (p_tipo, vtipo) <> 0
      THEN
         RAISE e_param_error;
      END IF;

      /*v_squery := 'select distinct r.cramo, r.tramo from codiram c, ramos r, productos p '
                        || 'where r.cidioma = ' || pac_md_common.f_get_cxtidioma
                        || ' and r.cramo = p.cramo' || ' and c.CRAMO = r.CRAMO'
                        || ' and c.CEMPRES = ' || pcempres || ' and' || vtipo
                        || ' and PAC_PRODUCTOS.f_prodagente (p.sproduc,'
                        || pac_md_common.f_get_cxtagente || ',2)=1' || ' order by r.tramo';*/

      -- dra 16-11-2008: bug mantis 7826
      -- AMC-24/04/2009-Bug 9585

      --Ini bug.: 17718 - ICV - 24/02/2011
      IF p_tipo = 'TF'
      THEN
         vcontrol := 2;
--Si es nueva producci??n se ha de controlar que muestre los mensajes si est??n como emitir = 1
      ELSE
         vcontrol := 6; --Para todos los dem??s se mirara si es accesible = 1
      END IF;

      --Fin bug.: 17718
      IF p_tipo = '14'
      THEN                                                  --Nota Informativa
         cur :=
            f_opencursor
               (   'select distinct r.cramo, r.tramo from codiram c, ramos r, productos p '
                || 'where r.cidioma = '
                || pac_md_common.f_get_cxtidioma
                || ' and r.cramo = p.cramo'
                || ' and c.CRAMO = r.CRAMO'
                || ' and c.CEMPRES = '
                || pcempres
                || ' and'
                || vtipo
                || ' 1=1 '
                || ' order by r.tramo',
                mensajes
               );
      ELSE
         cur :=
            f_opencursor
               (   'select distinct r.cramo, r.tramo from codiram c, ramos r, productos p '
                || 'where r.cidioma = '
                || pac_md_common.f_get_cxtidioma
                || ' and r.cramo = p.cramo'
                || ' and c.CRAMO = r.CRAMO'
                || ' and c.CEMPRES = '
                || pcempres
                || ' and'
                || vtipo
                || ' PAC_PRODUCTOS.f_prodagente (p.sproduc,'
                || pac_md_common.f_get_cxtagente
                || ','
                || vcontrol
                || ')=1'
                || ' order by r.tramo',
                mensajes
               );
      END IF;

      --Fi AMC-24/04/2009-Bug 9585
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ramos;

      /*************************************************************************
      Recupera la Lista de distintos ramos, devuelve un ref cursor
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- AMC-Bug9585-24/04/2009- Se a??ade el pcempres
   -- xpl 13-05-2009: bug mantis 0010093, se a??ade el tipo
   FUNCTION f_get_ramosagente (
      pcagente   IN       NUMBER,
      p_tipo     IN       VARCHAR2,
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_Ramos';
      terror     VARCHAR2 (200)  := 'Error recuperar ramos';
      vtipo      VARCHAR2 (2000);
      vempresa   VARCHAR2 (2000);
      v_squery   VARCHAR2 (2000);
      vcontrol   NUMBER;
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      -- xpl 13-05-2009: bug mantis 0010093
      IF pac_productos.f_get_filtroprod (p_tipo, vtipo, pcagente) <> 0
      THEN
         RAISE e_param_error;
      END IF;

      /*v_squery := 'select distinct r.cramo, r.tramo from codiram c, ramos r, productos p '
                        || 'where r.cidioma = ' || pac_md_common.f_get_cxtidioma
                        || ' and r.cramo = p.cramo' || ' and c.CRAMO = r.CRAMO'
                        || ' and c.CEMPRES = ' || pcempres || ' and' || vtipo
                        || ' and PAC_PRODUCTOS.f_prodagente (p.sproduc,'
                        || pac_md_common.f_get_cxtagente || ',2)=1' || ' order by r.tramo';*/

      -- dra 16-11-2008: bug mantis 7826
      -- AMC-24/04/2009-Bug 9585

      --Ini bug.: 17718 - ICV - 24/02/2011
      IF p_tipo = 'TF'
      THEN
         vcontrol := 2;
--Si es nueva producci??n se ha de controlar que muestre los mensajes si est??n como emitir = 1
      ELSE
         vcontrol := 6; --Para todos los dem??s se mirara si es accesible = 1
      END IF;

      --Fin bug.: 17718
      IF p_tipo = '14'
      THEN                                                  --Nota Informativa
         cur :=
            f_opencursor
               (   'select distinct r.cramo, r.tramo from codiram c, ramos r, productos p '
                || 'where r.cidioma = '
                || pac_md_common.f_get_cxtidioma
                || ' and r.cramo = p.cramo'
                || ' and c.CRAMO = r.CRAMO'
                || ' and c.CEMPRES = '
                || pcempres
                || ' and'
                || vtipo
                || ' 1=1 '
                || ' order by r.tramo',
                mensajes
               );
      ELSE
         cur :=
            f_opencursor
               (   'select distinct r.cramo, r.tramo from codiram c, ramos r, productos p '
                || 'where r.cidioma = '
                || pac_md_common.f_get_cxtidioma
                || ' and r.cramo = p.cramo'
                || ' and c.CRAMO = r.CRAMO'
                || ' and c.CEMPRES = '
                || pcempres
                || ' and'
                || vtipo
                || ' PAC_PRODUCTOS.f_prodagente (p.sproduc,'
                || pcagente
                || ','
                || vcontrol
                || ')=1'
                || ' order by r.tramo',
                mensajes
               );
      END IF;

      --Fi AMC-24/04/2009-Bug 9585
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ramosagente;

   /*************************************************************************
      Recupera los productos pertenecientes al ramo
      param in pcramo    : c??digo de ramo
      param in pctermfin : 1=los productos contratables des Front-Office / 0=todos
      param out mensajes : mensajes de error
      param in pcagente  : codigo de agente
      param in pcmodali  : codigo de modalidad
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramproductos (
      p_tipo      IN       VARCHAR2,
      pcramo      IN       NUMBER,
      pctermfin   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes,
      pcagente    IN       NUMBER DEFAULT NULL,
      pcmodali    IN       NUMBER DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vmodali    VARCHAR2 (100);
      vtermfin   VARCHAR2 (100);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)
           := 'par??mtros: ramo: ' || pcramo || ' - pctermfin: ' || pctermfin;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_RamProductos';
      terror     VARCHAR2 (200)  := 'Error recuperar productos ramo';
      vtipo      VARCHAR2 (2000);
      vcontrol   NUMBER;
      vcagente   NUMBER          := pcagente;
   BEGIN
      IF pcramo IS NULL OR pctermfin IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pcagente IS NULL
      THEN
         vcagente := pac_md_common.f_get_cxtagente;
      END IF;

      -- xpl 13-05-2009: bug mantis 0010093
      IF pac_productos.f_get_filtroprod (p_tipo, vtipo, pcagente) <> 0
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pctermfin = 1
      THEN
         vtermfin := '       p.CTERMFIN=1 and  p.CACTIVO=1 and  ';
      END IF;

      -- INI BUG CONF-209 - 12/10/2016 - JAEG
      IF pcmodali IS NOT NULL
      THEN
         --
         vmodali :=
               ' (SELECT CMODALI FROM MODALIPRO WHERE SPRODUC = p.sproduc) = '
            || pcmodali;
         vmodali := vmodali || ' AND ';
      --
      END IF;

      -- FIN BUG CONF-209 - 12/10/2016 - JAEG

      --Ini bug.: 17718 - ICV - 24/02/2011
      IF p_tipo = 'TF'
      THEN
         vcontrol := 2;
--Si es nueva producci??n se ha de controlar que muestre los mensajes si est??n como emitir = 1
      ELSE
         vcontrol := 6; --Para todos los dem??s se mirara si es accesible = 1
      END IF;

      IF p_tipo = '14'
      THEN
         --Fin bug.: 17718
         cur :=
            f_opencursor
                    (   'select p.sproduc, t.ttitulo '
                     || ' from titulopro t, productos p '
                     || ' where t.CRAMO = p.CRAMO and  '
                     || '       t.CCOLECT=p.CCOLECT and   p.CACTIVO = 1 and'
                     || '       t.CTIPSEG =p.CTIPSEG and '
                     || '       t.CMODALI = p.CMODALI and '
                     || '       p.CRAMO = '
                     || pcramo
                     || ' and  '
                     || vmodali
                     || vtermfin
                     || '       t.cidioma = '
                     || pac_md_common.f_get_cxtidioma ()
                     || ' and'
                     || vtipo
                     || ' 1=1 '
                     || ' order by ttitulo',
                     mensajes
                    );
      ELSE
         --Fin bug.: 17718
         cur :=
            f_opencursor
                    (   'select p.sproduc, t.ttitulo '
                     || ' from titulopro t, productos p '
                     || ' where t.CRAMO = p.CRAMO and  '
                     || '       t.CCOLECT=p.CCOLECT and   p.CACTIVO = 1 and'
                     || '       t.CTIPSEG =p.CTIPSEG and '
                     || '       t.CMODALI = p.CMODALI and '
                     || '       p.CRAMO = '
                     || pcramo
                     || ' and  '
                     || vmodali
                     || vtermfin
                     || '       t.cidioma = '
                     || pac_md_common.f_get_cxtidioma ()
                     || ' and'
                     || vtipo
                     || '       PAC_PRODUCTOS.f_prodagente (p.sproduc,'
                     || vcagente
                     || ','
                     || vcontrol
                     || ')=1'
                     || ' order by ttitulo',
                     mensajes
                    );
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ramproductos;

   /*************************************************************************
      Recupera la lista de domicilios de la persona
      param in sperson   : c??digo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
     2.0      05/04/2019    CES    IAXIS-2065: Ajuste de las tablas de direcciones para traer información de la persona
   *************************************************************************/
   FUNCTION f_get_lstdomiperson (
      psperson   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'sperson= ' || psperson;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstDomiPerson';
      terror     VARCHAR2 (200) := 'Error recuperar domicilios personas';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
       -- nueva select para extraer descripcion de poblacion 20080331 JCA
       -- INI BUG CONF-441 - 14/12/2016 - JAEG
      -- INI-IAXIS-2065 CES
      IF pac_iax_produccion.vpmode = 'EST'
      THEN
         cur :=
            f_opencursor
               (   'select d.cdomici, DECODE((select talias from per_direcciones where cdomici = d.cdomici and sperson in (select spereal from estper_personas where sperson = '
                || psperson
                || ')),
                null, null, (select talias from per_direcciones where cdomici = d.cdomici and sperson in (select spereal from estper_personas where sperson = '
                || psperson
                || ')) || chr(58) || chr(32)) || d.tdomici tdomici, d.cpostal, p.tpoblac
                from estper_direcciones d, poblaciones p where d.sperson='
                || psperson
                || ' and d.cpoblac = p.cpoblac(+) and d.cprovin = p.cprovin(+)',
                mensajes
               );
      ELSE
         cur :=
            f_opencursor
               (   'select d.cdomici, DECODE(d.talias, null, null, d.talias || chr(58) || chr(32)) || d.tdomici tdomici, d.cpostal, p.tpoblac from per_direcciones d, poblaciones p where d.sperson='
                || psperson
                || ' and d.cpoblac = p.cpoblac(+) and d.cprovin = p.cprovin(+)',
                mensajes
               );
      END IF;

       -- FIN BUG CONF-441 - 14/12/2016 - JAEG
      -- END-IAXIS-2065 CES
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdomiperson;

   /*************************************************************************
      Recupera los estados de la persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcestper (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstcestper';
      terror     VARCHAR2 (200) := 'Error recuperar estdos persona';
   BEGIN
      cur := f_detvalores (13, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcestper;

   /*************************************************************************
      Recupera los tipos de vinculos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipovinculos (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_TipoVinculos';
      terror     VARCHAR2 (200) := 'Error recuperar tipo vinculos';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur :=
         f_opencursor (   'SELECT cvinclo codi, tvinclo texte, '
                       || '   tvinclo || cvinclo busqueda '
                       || '   FROM vinculos '
                       || '   WHERE cidioma = '
                       || pac_md_common.f_get_cxtidioma
                       || '   ORDER BY codi ',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipovinculos;

   /*************************************************************************
      Recupera los tipos de comisi??n
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcomision (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur           sys_refcursor;
      vpasexec      NUMBER (8)                         := 1;
      vparam        VARCHAR2 (1)                       := NULL;
      vobject       VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_LstComision';
      terror        VARCHAR2 (200)       := 'Error recuperar tipos comisi??n';
      v_cond        VARCHAR2 (2000)                    := NULL;
      v_ctipcom     prodherencia_colect.cforpag%TYPE;
      num_err       NUMBER;
      vcagente      NUMBER;
      vsperson      NUMBER;
      vsasegurado   NUMBER;
      vconvenio     NUMBER;
      vsproduc      NUMBER;
      vasegurado    NUMBER;
      vctipage      NUMBER;
      tomadores     t_iax_tomadores;
      tomador       ob_iax_tomadores;
      vfefecto      DATE;
      vriesgos      t_iax_riesgos;
      aseg          t_iax_asegurados;
       --Ini IAXIS-4082 -- ECP -- 29/08/2019
      v_cpregun_2912   preguntas.cpregun%TYPE   := 2912;
      v_trespue_2912   pregunseg.trespue%TYPE;
     
   --Fin IAXIS-4082 -- ECP -- 29/08/2019
      
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      --cur := f_detvalores(55, mensajes);
      IF     pac_mdpar_productos.f_get_parproducto
                                ('ADMITE_CERTIFICADOS',
                                 pac_iax_produccion.poliza.det_poliza.sproduc
                                ) = 1
         AND NOT pac_iax_produccion.isaltacol
      THEN
         num_err :=
            pac_productos.f_get_herencia_col
                               (pac_iax_produccion.poliza.det_poliza.sproduc,
                                13,
                                v_ctipcom
                               );

         IF NVL (v_ctipcom, 0) = 1 AND num_err = 0
         THEN
            v_cond :=
                  ' AND catribu = (select ctipcom from seguros where ncertif = 0 and npoliza = '
               || pac_iax_produccion.poliza.det_poliza.npoliza
               || ')';
         ELSE
            v_cond := NULL;
         END IF;
      ELSE
         --Bug 27327/146916 - 27/06/2013 - AMC
         -- Si el tomador o el agente no tiene comisión especial no debe cargarse el valor 92.
         vcagente := pac_iax_produccion.poliza.det_poliza.cagente;
         vsperson :=
                   pac_iax_produccion.poliza.det_poliza.tomadores (1).spereal;
         vsproduc := pac_iax_produccion.poliza.det_poliza.sproduc;
         vfefecto := pac_iax_produccion.poliza.det_poliza.gestion.fefecto;

         -- FACnuevo parametro a nivel producto que me indica si el convenio es a nivel asegurado o tomador 0= CONVENIO TOMADOR, 1= CONVENIO ASEGURADO
         -- Ini IAXIS-4082. Convenio Grandes Beneficiarios - RCE Derivado de Contratos
         IF NVL
               (pac_mdpar_productos.f_get_parproducto
                                 ('CONVENIO_TOMADOR',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ),
                0
               ) = 1
         THEN
            vsperson :=
                   pac_iax_produccion.poliza.det_poliza.tomadores (1).spereal;
         ELSE
            IF NVL
                  (pac_mdpar_productos.f_get_parproducto
                                 ('CONV_CONTRATANTE',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ),
                   0
                  ) = 0
            THEN
               vriesgos :=
                  pac_iobj_prod.f_partpolriesgos
                                       (pac_iax_produccion.poliza.det_poliza,
                                        mensajes
                                       );

               IF vriesgos IS NOT NULL
               THEN
                  IF vriesgos.COUNT > 0
                  THEN
                     FOR vrie IN vriesgos.FIRST .. vriesgos.LAST
                     LOOP
                        IF vriesgos.EXISTS (vrie)
                        THEN
                           aseg :=
                              pac_iobj_prod.f_partriesasegurado
                                                             (vriesgos (vrie),
                                                              mensajes
                                                             );

                           IF aseg IS NOT NULL
                           THEN
                              IF aseg.COUNT > 0
                              THEN
                                 FOR vaseg IN aseg.FIRST .. aseg.LAST
                                 LOOP
                                    IF aseg.EXISTS (vaseg)
                                    THEN
                                       vsperson := aseg (vaseg).spereal;
                                    END IF;
                                 END LOOP;
                              END IF;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            else
              IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
         THEN
            IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
            THEN
               FOR i IN
                  pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
               LOOP
                  --Ini IAXIS-4082 -- ECP -- 29/08/2019
                  IF v_cpregun_2912 =
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun
                  THEN
                     v_trespue_2912 :=
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).trespue;
                  END IF;
                  
               --Fin IAXIS-4082 -- ECP -- 29/08/2019
               END LOOP;
            END IF;
         END IF;

         

         
         

         --Ini IAXIS-4082 -- ECP -- 29/08/2019
         IF v_trespue_2912 IS NOT NULL
         THEN
            SELECT sperson
              INTO vsperson
              FROM per_personas
             WHERE nnumide = v_trespue_2912;

           
         END IF;

        
      
            END IF;
         END IF;

         num_err :=
            pac_iax_comisionegocio.f_get_tieneconvcomesp (vsperson,
                                                          vcagente,
                                                          vsproduc,
                                                          vfefecto,
                                                          vconvenio,
                                                          mensajes
                                                         );
         

         IF vconvenio = 0
         THEN
            v_cond := ' and catribu <> 92 ';
         END IF;
         --Fin IAXIS-4082 -- ECP -- 11/10/2019
         -- Ini IAXIS-4082. Convenio Grandes Beneficiarios - RCE Derivado de Contratos
         SELECT ctipage
           INTO vctipage
           FROM agentes
          WHERE cagente = vcagente;

         IF vctipage = 2
         THEN
            v_cond := v_cond || ' and catribu <> 90 and catribu <> 0';
         END IF;
      --Fi Bug 27327/146916 - 27/06/2013 - AMC
      END IF;

      
      cur :=
         f_opencursor (   'select catribu,tatribu from detvalores '
                       || ' where cidioma ='
                       || pac_md_common.f_get_cxtidioma ()
                       || ' and cvalor=55 '
                       || v_cond,
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcomision;

    /*************************************************************************
      Recupera la lista de idiomas seleccionables
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstidiomas (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstIdiomas';
      terror     VARCHAR2 (200) := 'Error recuperar idiomas';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur :=
         f_opencursor
                  ('select cidioma, tidioma from idiomas where cvisible = 1',
                   mensajes
                  );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstidiomas;

   /*************************************************************************
      Recupera lista de comisiones permitidas por p??liza
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcomisiones (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstComisiones';
      terror     VARCHAR2 (200) := 'Error recuperar comisiones por p??liza';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (67, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcomisiones;

   /*************************************************************************
      Recupera la lista de agentes seg??n los criterios
      param in numide : numero documento persona
      param in nombre : texto que incluye nombre + apellidos
   *************************************************************************/
   FUNCTION f_get_lstagentes (
      numide     IN       VARCHAR2,
      nombre     IN       VARCHAR2,
      pcagente   IN       NUMBER,
      pformato   IN       NUMBER,
      pctipage   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      condicion      VARCHAR2 (1000);
      cur            sys_refcursor;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (1000)
         :=    'numide= '
            || numide
            || ' nombre= '
            || nombre
            || ' pcagente= '
            || pcagente
            || ' pctipage= '
            || pctipage;
      vobject        VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_LstAgentes';
      terror         VARCHAR2 (200)  := 'Error recuperar agentes';
      no_hay_datos   EXCEPTION;
      vcodi          NUMBER;
      vnombre        VARCHAR2 (200);
      vselect        VARCHAR2 (4000);
      vwhere         VARCHAR2 (2000);
      vwherevista    VARCHAR2 (2000);
                                             --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      condicion := '%' || nombre || '%';

      IF condicion IS NOT NULL
      THEN
         vwhere :=
               ' AND (upper( F_NOMBRE (a.sperson , 1)) like UPPER ('''
            || condicion
            || ''') OR '''
            || condicion
            || ''' IS NULL) ';
      END IF;

      condicion := '%' || numide || '%';

      IF condicion IS NOT NULL
      THEN
         -- Bug 35888/205345 Realizar la substitución del upper nnumnif o nnumide - CJMR D02 A02
         --vwhere := vwhere || ' AND (upper( p.nnumide) like UPPER (''' || condicion
         --          || ''') OR ''' || condicion || ''' IS NULL) ';
         vwhere :=
               vwhere
            || ' AND ( p.nnumide like '''
            || condicion
            || ''' OR '''
            || condicion
            || ''' IS NULL) ';
      END IF;

      --BUG19533 - JTS - 29/009/2011
      /*
      IF pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'FILTRO_AGE') = 1 THEN
         vwherevista := ' AND a.cagente in (SELECT a.cagente '
                        || ' FROM (SELECT LEVEL nivel, cagente ' || ' FROM redcomercial r '
                        || ' WHERE ' || ' r.fmovfin is null ' || ' START WITH '
                        || '  r.cempres =  ' || pac_md_common.f_get_cxtempresa
                        || ' AND R.CAGENTE = ' || pac_md_common.f_get_cxtagente
                        || ' and r.fmovfin is null '
                        || ' CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
                        || ' AND PRIOR r.cempres =(r.cempres + 0) '
                        || ' and r.fmovfin is null ' || ' AND r.cagente >= 0) rr, '
                        || ' agentes a ' || ' where rr.cagente = a.cagente ) ';

         ???? AVISO SI ESTO SE ACTIVA, HAY QUE MODIFICAR TAMBIEN LA FUNCION CLONADA f_get_lstagentes_cond !!
      END IF;
       */
      --Fi bug19533
       -- Bug 21278/106713 - 08/02/2012 - AMC
       -- Bug 22802/118458 - 17/07/2012 - AMC
      IF pformato = 99
      THEN
         vselect :=
               'SELECT codi,nombre,nnumide'
            || ' from('
            || 'SELECT a.cagente codi, PAC_REDCOMERCIAL.ff_desagente (a.cagente, '
            || pac_md_common.f_get_cxtidioma
            || ', 1 '
            || ') nombre, p.NNUMIDE '
            || 'FROM agentes a,  per_personas p WHERE a.cagente =  NVL ('
            || NVL (TO_CHAR (pcagente), 'null')
            || ', a.cagente) '
            || ' AND a.SPERSON = p.SPERSON and a.ccomisi <> pac_parametros.f_parempresa_t(24,''COD_COMI_EMISION'')'
            || vwherevista
            || vwhere
            || ' )'
            || 'ORDER BY nombre';
      ELSE
         vselect :=
               'SELECT codi,nombre,nnumide'
            || ' from('
            || 'SELECT a.cagente codi, PAC_REDCOMERCIAL.ff_desagente (a.cagente, '
            || pac_md_common.f_get_cxtidioma
            || ', '
            || pformato
            || ') nombre, p.NNUMIDE '
            || 'FROM agentes a,  per_personas p, agentes_agente_pol ap WHERE a.cagente =  NVL ('
            || NVL (TO_CHAR (pcagente), 'null')
            || ', a.cagente) '
            || ' AND a.cagente = ap.cagente AND a.SPERSON = p.SPERSON and a.ccomisi <> pac_parametros.f_parempresa_t(24,''COD_COMI_EMISION'')'
            || ' AND a.ctipage = NVL('''
            || pctipage
            || ''', a.ctipage) '
            || ' AND ap.cempres = pac_md_common.f_get_cxtempresa '
            || vwherevista
            || vwhere
            /*|| ' union '
            || ' SELECT a.cagente codi, PAC_REDCOMERCIAL.ff_desagente (a.cagente, '
            || pac_md_common.f_get_cxtidioma || ', ' || pformato || ') nombre, p.NNUMIDE '
            || ' FROM agentes a, per_personas p' || ' WHERE a.cagente =  NVL ('
            || NVL(TO_CHAR(pcagente), 'null') || ', a.cagente) ' || ' AND a.ctipage = NVL('''
            || pctipage || ''', a.ctipage) ' || ' AND a.SPERSON = p.SPERSON '
            || ' AND a.cagente not in (select cagente from agentes_agente aa where aa.cagente = '
            || ' NVL (' || NVL(TO_CHAR(pcagente), 'null') || ', a.cagente))' || vwherevista
            || vwhere
            */
            || ' )'
            || 'ORDER BY nombre';
      END IF;

      -- Fi Bug 21278/106713 - 08/02/2012 - AMC
      -- Fi Bug 22802/118458 - 17/07/2012 - AMC
      cur := f_opencursor (vselect, mensajes);

      IF cur%FOUND
      THEN
         IF cur%ISOPEN
         THEN
            -- dra 12-1-09: bug mantis 8650
            FETCH cur
             INTO vcodi, vnombre;

            IF cur%NOTFOUND
            THEN
               RAISE no_hay_datos;
            END IF;

            CLOSE cur;
         END IF;
      END IF;

      -- Lo volvemos a abrir ya que el FETCH lo deja sin las filas ya consultadas
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN no_hay_datos
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000730);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstagentes;

   /*************************************************************************
      Recupera la lista de valores del desplegable sexo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipsexo (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_TipSexo';
      terror     VARCHAR2 (200) := 'Error recuperar tipos de sexo';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (11, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipsexo;

   /*************************************************************************
      Recupera la lista de productos contractables
      param in p_tipo    : Tipo de productos requeridos:
                           'TF'         ---> Contratables des de Front-Office
                           'REEMB'      ---> Productos de salud
                           'APOR_EXTRA' ---> Con aportaciones extra
                           'SIMUL'      ---> Que puedan tener simulaci??n
                           'RESCA'      ---> Que puedan tener rescates
                           'SINIS'      ---> Que puedan tener siniestros
                           null         ---> Todos los productos
      param in p_cempres : Empresa
      param in p_cramo   : Ramo
      param out mensajes : mensajes de error
      param in pcagente  : Agente
      param in pcmodali  : Modalidad
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_productos (
      p_tipo      IN       VARCHAR2,
      p_cempres   IN       NUMBER,
      p_cramo     IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes,
      pcagente    IN       NUMBER DEFAULT NULL,
      pcmodali    IN       NUMBER DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100)
         :=    'par??metros - p_tipo: '
            || p_tipo
            || ', p_cempres: '
            || p_cempres
            || ', p_cramo: '
            || p_cramo;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Productos';
      cur        sys_refcursor;
      vtipo      VARCHAR2 (500);
      vempresa   VARCHAR2 (500);
      vramo      VARCHAR2 (500);
      vmodali    VARCHAR2 (100);
      vcontrol   NUMBER;
      vcagente   NUMBER         := pcagente;
   BEGIN
      IF pcagente IS NULL
      THEN
         vcagente := pac_md_common.f_get_cxtagente;
      END IF;

      vpasexec := 1;

      -- BUG 9017 - 01/04/2009 - SBG - El filtre per tipus ara es fa cridant a
      -- PAC_PRODUCTOS.F_Get_FiltroProd, per a que pugui ser cridat tamb?? en el
      -- filtre de p??lisses (PAC_MD_PRODUCCION.f_consultapoliza)
      IF pac_productos.f_get_filtroprod (p_tipo, vtipo, pcagente) <> 0
      THEN
         RAISE e_param_error;
      END IF;

      -- FINAL BUG 9017 - 01/04/2009 - SBG
      vpasexec := 2;

      IF p_cempres IS NOT NULL
      THEN
         vempresa :=
               ' p.CRAMO IN (SELECT CRAMO FROM CODIRAM c WHERE c.CEMPRES = '
            || p_cempres
            || ') and';
      END IF;

      vpasexec := 3;

      IF p_cramo IS NOT NULL
      THEN
         vramo := ' p.CRAMO = ' || p_cramo || ' and';
      END IF;

      -- BUG 19130 - 20/09/2011 - JMP
      IF pcmodali IS NOT NULL
      THEN
         vmodali := ' p.cmodali = ' || pcmodali || ' and';
      END IF;

      -- FIN BUG 19130 - 20/09/2011 - JMP

      --Ini bug.: 17718 - ICV - 24/02/2011
      IF p_tipo = 'TF'
      THEN
         vcontrol := 2;
--Si es nueva producci??n se ha de controlar que muestre los mensajes si est??n como emitir = 1
      ELSE
         vcontrol := 6; --Para todos los dem??s se mirara si es accesible = 1
      END IF;

      --Fin bug.: 17718
      vpasexec := 4;
      cur :=
         f_opencursor (   'select p.sproduc, t.ttitulo'
                       || ' from productos p, titulopro t'
                       || ' where p.CRAMO = t.CRAMO and'
                       || ' p.CCOLECT = t.CCOLECT and  p.CACTIVO = 1 and'
                       || ' p.CMODALI = t.CMODALI and'
                       || ' p.CTIPSEG = t.ctipseg and'
                       || vtipo
                       || vempresa
                       || vramo
                       || vmodali
                       || ' t.CIDIOMA = '
                       || pac_md_common.f_get_cxtidioma
                       || ' and PAC_PRODUCTOS.f_prodagente (p.sproduc,'
                       || vcagente
                       || ','
                       || vcontrol
                       || ')=1'
                       || ' order by t.ttitulo ',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_productos;

   /*************************************************************************
      Recupera lista de situaciones p??liza
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_sitpoliza (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_SitPoliza';
      terror     VARCHAR2 (200) := 'Error recuperar situaciones p??liza';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (61, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_sitpoliza;

   /*************************************************************************
      Recupera lista tipos cuentas bancarias
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipccc (
      mensajes   IN OUT   t_iax_mensajes,
      pctipocc            NUMBER DEFAULT NULL
   -- 08/11/2011 0019985 LCOL_A001-Control de las matriculas (prenotificaciones)
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_TipCCC';
      terror     VARCHAR2 (200) := 'Error recuperar tipos de cuenta';
      vctipocc   NUMBER;
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      vctipocc := NVL (pctipocc, 1);
      -- 03/01/2012 20735 LCOL_A001-ADM - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco - Inici
      cur :=
         f_opencursor (   'select c.CTIPBAN,d.TTIPO '
                       || '  FROM tipos_cuenta c, tipos_cuentades d '
                       || ' WHERE c.ctipban = d.ctipban '
                       || '   AND d.cidioma = '
                       || pac_md_common.f_get_cxtidioma
                       || '   AND(('
                       || vctipocc
                       || ' = 1 AND NVL(c.ctipcc, 1) not in (2,4,5,6,7)) '
                       || '     OR('
                       || vctipocc
                       || ' <> 1 AND NVL(c.ctipcc, 1) in (2,4,5,6,7))) '
                       || ' ORDER BY c.norden ',
                       mensajes
                      );
--      -- 08/11/2011 0019985 LCOL_A001-Control de las matriculas (prenotificaciones) - Inici
--      cur := f_opencursor('select c.CTIPBAN,d.TTIPO '
--                          || ' from tipos_cuenta c, tipos_cuentades d '
--                          || '    where c.CTIPBAN=d.CTIPBAN and ' || '          d.CIDIOMA= '
--                          || pac_md_common.f_get_cxtidioma || ' AND ((' || vctipocc
--                          || ' = 1 AND NVL(c.ctipcc,1) = 1) ' || ' OR (' || vctipocc
--                          || ' <> 1 AND NVL(c.ctipcc,1) <> 1)) ' || '    order by c.NORDEN',
--                          mensajes);
----      cur := f_opencursor('select c.CTIPBAN,d.TTIPO '
----                          || ' from tipos_cuenta c, tipos_cuentades d '
----                          || '    where c.CTIPBAN=d.CTIPBAN and ' || '          d.CIDIOMA= '
----                          || pac_md_common.f_get_cxtidioma || '    order by c.NORDEN',
----                          mensajes);
--         -- 08/11/2011 0019985 LCOL_A001-Control de las matriculas (prenotificaciones) - Fi
      -- 03/01/2012 20735 LCOL_A001-ADM - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco - Fi
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipccc;

   /*************************************************************************
      Recupera lista con los motivos de siniestros
      param in ccausa   : c??digo causa de siniestro
      param in cramo   : ramo
      param in psproduc   : Producto
      param in psseguro   : Seguro
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_motivossini (
      ccausa     IN       NUMBER,
      cramo      IN       NUMBER,
      psproduc   IN       NUMBER,
      psseguro            NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
                               := 'ccausa= ' || ccausa || ' cramo= ' || cramo;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_MotivosSini';
      terror     VARCHAR2 (200)  := 'Error recuperar motivos siniestros';
                                               --//ACC recuperar desde literales
      --//ACC recuperar desde literales
      --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
      vn_cas     NUMBER;
      vquery     VARCHAR2 (2000);
   BEGIN
      -- Bug 15869 - 20/09/2010 - JRH - Rentas CIV 2 cabezas
      IF NVL (f_parproductos_v (psproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1
      THEN
         SELECT COUNT (1)
           INTO vn_cas
           FROM asegurados
          WHERE sseguro = psseguro AND ffecmue IS NULL;

         IF vn_cas = 1
         THEN
            -- Un assegurat, nom??s mot. 0-defunci??.
            vn_cas := 0;
         ELSIF vn_cas > 1
         THEN
            -- M??s d'un assegurat, que no surti 0-defunci??.
            vn_cas := 1;
         ELSE
            -- Altres casos no controlats.
            vn_cas := 2;
         END IF;
      ELSE
         -- Altres casos: Sortiran tots els motius.
         vn_cas := 2;
      END IF;

      IF ((ccausa <> 1) OR (vn_cas = 2))
      THEN                                                     --lo de siempre
         vquery :=
               'select c.CMOTSIN,d.TMOTSIN,c.CCAUSIN '
            || ' from codmotsini c, desmotsini d,PRODCAUMOTSIN P '
            || ' where c.CRAMO=  '
            || cramo
            || ' and c.CCAUSIN=  '
            || ccausa
            || ' and c.CRAMO= d.CRAMO '
            || ' and c.CCAUSIN= d.CCAUSIN '
            || ' and c.CMOTSIN = d.CMOTSIN '               --and c.cmotsin<>0'
            || '   AND P.CMOTSIN = C.CMOTSIN'
            || '   AND P.CCAUSIN = C.CCAUSIN'
            || '   AND P.SPRODUC = '
            || psproduc
            || ' and d.CIDIOMA = '
            || pac_md_common.f_get_cxtidioma
            || ' ORDER BY C.CMOTSIN';
         cur := f_opencursor (vquery, mensajes);
      ELSE
         IF vn_cas = 1
         THEN                                       --2 cabezas, 2 asegurados
            vquery :=
                  'select c.CMOTSIN,d.TMOTSIN,c.CCAUSIN '
               || ' from codmotsini c, desmotsini d,PRODCAUMOTSIN P '
               || ' where c.CRAMO=  '
               || cramo
               || ' and c.CCAUSIN=  '
               || ccausa
               || ' and c.CRAMO= d.CRAMO '
               || ' and c.CCAUSIN= d.CCAUSIN '
               || ' and c.CMOTSIN = d.CMOTSIN and c.cmotsin<>0'
               || '   AND P.CMOTSIN = C.CMOTSIN'
               || '   AND P.CCAUSIN = C.CCAUSIN'
               || '   AND P.SPRODUC = '
               || psproduc
               || ' and d.CIDIOMA = '
               || pac_md_common.f_get_cxtidioma
               || ' ORDER BY C.CMOTSIN';
            cur := f_opencursor (vquery, mensajes);
         ELSE
            vquery :=
                  'select c.CMOTSIN,d.TMOTSIN,c.CCAUSIN '
               || ' from codmotsini c, desmotsini d,PRODCAUMOTSIN P '
               || ' where c.CRAMO=  '
               || cramo
               || ' and c.CCAUSIN=  '
               || ccausa
               || ' and c.CRAMO= d.CRAMO '
               || ' and c.CCAUSIN= d.CCAUSIN '
               || ' and c.CMOTSIN = d.CMOTSIN and c.cmotsin not in (12,13)'
               || '   AND P.CMOTSIN = C.CMOTSIN'
               || '   AND P.CCAUSIN = C.CCAUSIN'
               || '   AND P.SPRODUC = '
               || psproduc
               || ' and d.CIDIOMA = '
               || pac_md_common.f_get_cxtidioma
               || ' ORDER BY C.CMOTSIN';
            cur := f_opencursor (vquery, mensajes);
         END IF;
      END IF;

      -- Fi Bug 15869 - 20/09/2010 - JRH
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_motivossini;

    --Ini BUG 14588 - PFA -  CRT001 - A??adir campo compa??ia productos
   /*************************************************************************
       Recupera lista de cias productos
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_ciaproductos (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_CiaProductos';
      terror     VARCHAR2 (200) := 'Error al recuperar las cias productos';
   BEGIN
      -- Bug 23963/125448 - 17/10/2012 - AMC
      cur :=
         f_opencursor
            (   'SELECT CCOMPANI, TCOMPANI
                FROM companias
                WHERE (ctipcom = 0 or ctipcom is null)'
             -- 75.0 - 15/10/2013 - MMM - 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos - Inicio
             || ' AND (fbaja IS NULL OR fbaja > f_sysdate) '
             || 
                -- 75.0 - 15/10/2013 - MMM - 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos - Fin
                'ORDER BY TCOMPANI',
             mensajes
            );
      -- Fi Bug 23963/125448 - 17/10/2012 - AMC
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ciaproductos;

--Fin BUG 14588 - PFA -  CRT001 - A??adir campo compa??ia productos

   /*************************************************************************
      Recupera la lista con las causas de siniestros
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_causassini (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_MotivosSini';
      terror     VARCHAR2 (200) := 'Error recuperar causas del sinistro';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (684, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_causassini;

   /*************************************************************************
      Recupera la lista con los motivos de retencion
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_gstpolretmot (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_GSTPolRetMot';
      terror     VARCHAR2 (200) := 'Error recuperar motivos de retencion';
   BEGIN
      cur :=
         f_opencursor
            (   'SELECT catribu,tatribu
                              FROM DETVALORES
                             WHERE cvalor = 708
                               AND cidioma = '
             || pac_md_common.f_get_cxtidioma
             || 'AND catribu NOT IN (1)',           /*Bug 12172.NMM.02/2010.*/
             mensajes
            );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_gstpolretmot;

   /*************************************************************************
      Recupera la lista de responsabilidad de siniestros
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_responsabilidasini (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_LISTVALORES.F_Get_ResponsabilidaSini';
      terror     VARCHAR2 (200)
                            := 'Error recuperar responsabilidades siniestros';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (801, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_responsabilidasini;

   /*************************************************************************
      Recupera los tipus de anulaci??n de p??lizas (VF 553)
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipanulpol (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_TipAnulPol';
      terror     VARCHAR2 (200)  := 'Error recuperar tipos anulaci??n';
      vsquery    VARCHAR2 (5000);
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      vsquery :=
            'select d.* from detvalores d, cfg_tiposbajas ct, cfg_user cu'
         || ' where d.cvalor = 553'
         || ' and d.catribu = ct.ctipbaja'
         || ' and ct.CCFGACC = cu.ccfgacc'
         || ' and d.cidioma = '
         || pac_md_common.f_get_cxtidioma ()
         || ' and cu.cuser = '''
         || pac_md_common.f_get_cxtusuario ()
         || ''' and ct.sproduc = 0'
         || ' and ct.cempres = '
         || pac_md_common.f_get_cxtempresa ();
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipanulpol;

   -- BUG 9686 - 23/04/2009 - FAL - Parametrizar tipos de anulaci??n de poliza en funci??n de la configuraci??n de acciones del usuario y del producto
      /*************************************************************************
         Recupera los tipus de anulaci??n de p??lizas (VF 553)
         param in psproduc  : c??digo de producto
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
   FUNCTION f_get_tipanulpol (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := 'psproduc: ' || psproduc;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_TipAnulPol';
      terror     VARCHAR2 (200)  := 'Error recuperar tipos anulaci??n';
      squery     VARCHAR2 (5000);
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      squery :=
            'SELECT *'
         || ' FROM (SELECT d.*'
         || ' FROM detvalores d, cfg_tiposbajas ct, cfg_user cu'
         || ' WHERE d.cvalor = 553'
         || ' AND d.catribu = ct.ctipbaja'
         || ' AND ct.ccfgacc = cu.ccfgacc'
         || ' AND d.cidioma = pac_md_common.f_get_cxtidioma()'
         || ' AND cu.cuser = pac_md_common.f_get_cxtusuario()'
         || ' AND ct.sproduc = '
         || psproduc
         || ' AND ct.cempres = pac_md_common.f_get_cxtempresa()'
         || ' UNION ALL'
         || ' SELECT d.*'
         || ' FROM detvalores d, cfg_tiposbajas ct, cfg_user cu'
         || ' WHERE d.cvalor = 553'
         || ' AND d.catribu = ct.ctipbaja'
         || ' AND ct.ccfgacc = cu.ccfgacc'
         || ' AND d.cidioma = pac_md_common.f_get_cxtidioma()'
         || ' AND cu.cuser = pac_md_common.f_get_cxtusuario()'
         || ' AND ct.sproduc = 0'
         || ' AND ct.cempres = pac_md_common.f_get_cxtempresa()'
         || ' AND NOT EXISTS(SELECT 1'
         || ' FROM detvalores d, cfg_tiposbajas ct, cfg_user cu'
         || ' WHERE d.cvalor = 553'
         || ' AND d.catribu = ct.ctipbaja'
         || ' AND ct.ccfgacc = cu.ccfgacc'
         || ' AND d.cidioma = pac_md_common.f_get_cxtidioma()'
         || ' AND cu.cuser = pac_md_common.f_get_cxtusuario()'
         || ' AND ct.sproduc = '
         || psproduc
         || ' AND ct.cempres = pac_md_common.f_get_cxtempresa()))';
      cur := f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipanulpol;

   /*************************************************************************
      Recupera las causas de anulacion
      param in psproduc  : c??digo de producto
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_causaanulpol (
      psproduc    IN       NUMBER,
      pctipbaja   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur         sys_refcursor;
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (100)
                    := 'psproduc: ' || psproduc || 'pctipbaja: ' || pctipbaja;
      vobject     VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_causaanulpol';
      squery      VARCHAR2 (500);
      vpctibaja   VARCHAR2 (100);
   BEGIN
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pctipbaja IS NULL
      THEN
         vpctibaja := '';
      ELSE
         vpctibaja :=
               ' AND cmotmov IN(SELECT cmotmov'
            || ' FROM causanul'
            || ' WHERE ctipbaja = '
            || pctipbaja
            || ' AND sproduc ='
            || psproduc
            || ')';
      END IF;

      vparam :=
         NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'FILTRO_AGE'
                                            ),
              0
             );

--Per CRT ha de fer la query tot i que no tingue ctipbaja, ja que ens mostrar? totes les causes
--del producte. XPL#24042012
      IF pctipbaja IS NOT NULL OR (pctipbaja IS NULL AND vparam = 1)
      THEN
         squery :=
               'SELECT   cmotmov ccauanula, tmotmov tcauanula'
            || ' FROM motmovseg'
            || ' WHERE cidioma = '
            || pac_md_common.f_get_cxtidioma ()
            || ' AND cmotmov IN(SELECT cmotmov'
            || ' FROM codimotmov'
            || ' WHERE cactivo = 1'
            || ' AND cgesmov = 0'
            || ' AND cmovseg = 3'
            || ' AND cmotmov IN(SELECT cmotmov'
            || ' FROM prodmotmov'
            || ' WHERE sproduc = '
            || psproduc
            || '))'
            || vpctibaja
            || ' ORDER BY cmotmov';
         cur := f_opencursor (squery, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_causaanulpol;

   /*************************************************************************
      Recupera los motivos de anulacion
      param in pcmotmov  : c??digo de causa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_motanulpol (pcmotmov IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'pcmotmov: ' || pcmotmov;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_causaanulpol';
      squery     VARCHAR2 (500);
   BEGIN
      IF pcmotmov IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      squery :=
            'SELECT cmotanu cmotanula, tmotanu tmotanula'
         || ' FROM desmotivoanul'
         || ' WHERE cidioma = '
         || pac_md_common.f_get_cxtidioma ()
         || ' AND cmotmov IN '
         || pcmotmov
         || ' ORDER BY cmotmov';
      cur := f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_motanulpol;

   -- FI BUG 9686 - 23/04/2009 - FAL

   /*************************************************************************
      Recupera los tipus cobro de la poliza (VF 552) o los que tenga por defecto
      param in psproduc  : Código de producto
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipocobro (
      mensajes   IN OUT   t_iax_mensajes,
      psproduc   IN       NUMBER DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      cur              sys_refcursor;
      vpasexec         NUMBER (8)                         := 1;
      vparam           VARCHAR2 (1)                       := NULL;
      vobject          VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_TipCobro';
      terror           VARCHAR2 (200)
                               := 'Error recuperar tipos cobro de la p??liza';
      v_hay            NUMBER (2);
      squery           VARCHAR2 (1000);
      -- Ini Bug 22839 - MDS - 30/10/2012
      v_sproduc        NUMBER := pac_iax_produccion.poliza.det_poliza.sproduc;
      v_npoliza        NUMBER := pac_iax_produccion.poliza.det_poliza.npoliza;
      v_ctipcob        prodherencia_colect.ctipcob%TYPE;
      v_cond1          VARCHAR2 (2000)                    := NULL;
      v_cond2          VARCHAR2 (2000)                    := NULL;
      num_err          NUMBER;
       -- Fin Bug 22839 - MDS - 30/10/2012
      -- Ini Bug 0041438: Nota 232128 - AMA002-Validaciones (Sin validación de retorno) ID. 10
      vnumerr          NUMBER                             := 0;
      n_registro       NUMBER;
      v_cpregun_4092   pregunpolseg.cpregun%TYPE          := 4092;
      v_crespue_4092   pregunpolseg.crespue%TYPE;
      v_trespue_4092   pregunpolseg.trespue%TYPE;
      v_existepreg     NUMBER;
      vsseguro         NUMBER;
      -- Fin Bug 0041438: Nota 232128 - AMA002-Validaciones (Sin validación de retorno) ID. 10
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      --BUG 0024058: XVM :30/10/2012--INI. Añadir psproduc
      SELECT COUNT (1)
        INTO v_hay
        FROM medcobpro m, productos p
       WHERE p.sproduc = psproduc
         AND m.cramo = p.cramo
         AND m.cmodali = p.cmodali
         AND m.ctipseg = p.ctipseg
         AND m.ccolect = p.ccolect;

      -- Ini Bug 22839 - MDS - 30/10/2012
      -- heredar el CTIPCOB de la póliza con certificado 0
      IF     pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                    v_sproduc
                                                   ) = 1
         AND NOT pac_iax_produccion.isaltacol
      THEN
         num_err :=
                  pac_productos.f_get_herencia_col (v_sproduc, 15, v_ctipcob);

         IF NVL (v_ctipcob, 0) = 1 AND num_err = 0
         THEN
            -- Ini Bug 0041438: Nota 232128 - AMA002-Validaciones (Sin validación de retorno) ID. 10
            IF pac_mdpar_productos.f_get_parproducto ('ARRASTRA_CTIPCOB',
                                                      v_sproduc
                                                     ) = 1
            THEN
               SELECT sseguro
                 INTO vsseguro
                 FROM seguros
                WHERE ncertif = 0 AND npoliza = v_npoliza;

               SELECT crespue
                 INTO v_crespue_4092
                 FROM pregunpolseg
                WHERE sseguro = vsseguro
                  AND cpregun = 4092
                  AND nmovimi IN (SELECT MAX (nmovimi)
                                    FROM pregunpolseg
                                   WHERE sseguro = vsseguro);

               IF NVL (v_crespue_4092, 0) = 2
               THEN
                  v_cond1 := NULL;
                  v_cond2 := NULL;
               ELSE
                  IF NVL (v_ctipcob, 0) = 1 AND num_err = 0
                  THEN
                     v_cond1 :=
                           ' AND d.catribu = (select ctipcob from seguros where ncertif = 0
                                     and npoliza = '
                        || v_npoliza
                        || ') ';
                     v_cond2 :=
                           'catribu = (select ctipcob from seguros where ncertif = 0 and
                                     npoliza = '
                        || v_npoliza
                        || ')';
                  ELSE
                     v_cond1 := NULL;
                     v_cond2 := NULL;
                  END IF;
               END IF;
            -- Fin Bug 0041438: Nota 232128 - AMA002-Validaciones (Sin validación de retorno) ID. 10
            ELSE
               v_cond1 :=
                     ' AND d.catribu = (select ctipcob from seguros where ncertif = 0 and npoliza = '
                  || v_npoliza
                  || ') ';
               v_cond2 :=
                     'catribu = (select ctipcob from seguros where ncertif = 0 and npoliza = '
                  || v_npoliza
                  || ')';
            END IF;
         ELSE
            v_cond1 := NULL;
            v_cond2 := NULL;
         END IF;
      END IF;

      -- Fin Bug 22839 - MDS - 30/10/2012
      IF v_hay > 0
      THEN
         squery :=
               'SELECT d.catribu , d.tatribu '
            || ' from     DETVALORES D, MEDCOBPRO F,PRODUCTOS P '
            || ' WHERE f.ccolect = p.ccolect '
            || '    AND f.ctipseg = p.ctipseg '
            || '    AND f.cmodali = p.cmodali '
            || '    AND f.cramo = p.cramo '
            || '    AND f.ctipcob = d.catribu '
            || '  AND d.cidioma =  '
            || pac_md_common.f_get_cxtidioma
            || '  AND p.sproduc =  '
            || psproduc
            || v_cond1                         -- Bug 22839 - MDS - 30/10/2012
            || '  AND d.cvalor = 552 ORDER BY d.catribu';
         cur := pac_md_listvalores.f_opencursor (squery, mensajes);
      ELSE
         --cur := f_detvalores(552, mensajes);
         -- Ini Bug 22839 - MDS - 30/10/2012
         IF v_cond2 IS NOT NULL
         THEN
            cur := f_detvalorescond (552, v_cond2, mensajes);
         ELSE
            cur := f_detvalores (552, mensajes);
         END IF;
      -- Fin Bug 22839 - MDS - 30/10/2012
      END IF;

      --BUG 0024058: XVM :30/10/2012--Fin. Añadir psproduc
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipocobro;

   /*************************************************************************
      Recupera los sub agentes del agente de la p??liza
      param in cagente   : c??digo agente principal de la p??liza
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_subagentes (cagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200) := 'cagente= ' || cagente;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_SubAgentes';
      terror     VARCHAR2 (200) := 'Error recuperar sub agentes';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      -- BUG11618:DRA:12/11/2009: Ponemos alias en el CAGENTE
      cur :=
         f_opencursor
            (   'select rd.cagente CSUBAGE, LPAD(p.nnumnif, 10, '' '')||'' '' ||p.tnombre||'' ''|| p.tapelli NOMBRE '
             || ' from redcomercial rd, personas p, agentes a  where rd.ctipage = 10 '
             --(10 = subagent)
             || ' and rd.cpadre = '
             || cagente
             || ' and rd.cempres= '
             || pac_md_common.f_get_cxtempresa
             || ' and rd.cagente=a.cagente '
             || ' and a.sperson=p.sperson',
             mensajes
            );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_subagentes;

   /*************************************************************************
      Recupera el nombre del tomador de la p??liza seg??n el orden
      param in sseguro   : c??digo seguro
      param in nordtom   : orden tomador
      param out mensajes : mesajes de error
      return             : nombre tomador
   *************************************************************************/
   FUNCTION f_get_nametomador (sseguro IN NUMBER, nordtom IN NUMBER)
      RETURN VARCHAR2
   IS
      vf         VARCHAR2 (200) := NULL;
      nerr       NUMBER;
      cidioma    NUMBER         := pac_md_common.f_get_cxtidioma;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'sseguro= ' || sseguro;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_NameTomador';
      mensajes   t_iax_mensajes := NULL;
   BEGIN
      nerr := f_tomador (sseguro, nordtom, vf, cidioma);
      RETURN vf;
   EXCEPTION
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
         RETURN vf;
   END f_get_nametomador;

   /*************************************************************************
      Recupera el nnumide del tomador de la p??liza seg??n el orden
      param in psseguro   : c??digo seguro
      param in pnordtom   : orden tomador
      return             : nombre tomador
   *************************************************************************/
-- 15638 AVT 08-09-2010
   FUNCTION f_get_nameasegurado (sseguro IN NUMBER, nordtom IN NUMBER)
      RETURN VARCHAR2
   IS
      vf         VARCHAR2 (200) := NULL;
      nerr       NUMBER;
      cidioma    NUMBER         := pac_md_common.f_get_cxtidioma;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'sseguro= ' || sseguro;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_NameAsegurado';
      mensajes   t_iax_mensajes := NULL;
   BEGIN
      nerr := f_asegurado (sseguro, nordtom, vf, cidioma);
      RETURN vf;
   EXCEPTION
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
         RETURN vf;
   END f_get_nameasegurado;

   /*************************************************************************
      Recupera el nnumide del asegurado de la p??liza seg??n el orden
      param in psseguro   : c??digo seguro
      param in pnordtom   : orden asegurado
      return             : nombre asegurado
   *************************************************************************/
   FUNCTION f_get_numidetomador (psseguro IN NUMBER, pnordtom IN NUMBER)
      RETURN VARCHAR2
   IS
      vf         VARCHAR2 (100) := NULL;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200)
                      := 'psseguro= ' || psseguro || ' pnordtom=' || pnordtom;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_NumIdeTomador';
      mensajes   t_iax_mensajes := NULL;
   BEGIN
      -- dra 13-1-08: Se modifica para que solo devuelva un valor (personas por per_personas)
      SELECT NVL (p.nnumide, '')
        INTO vf
        FROM per_personas p, tomadores t
       WHERE p.sperson = t.sperson
         AND t.nordtom = pnordtom
         AND t.sseguro = psseguro;

      RETURN vf;
   EXCEPTION
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
         RETURN vf;
   END f_get_numidetomador;

   /*************************************************************************
      Recupera la situaci??n de la p??liza
      param in sseguro   : c??digo seguro
      return             : situaci??n
   *************************************************************************/
   FUNCTION f_get_situacionpoliza (psseguro IN NUMBER)
      RETURN VARCHAR2
   IS
      vf         VARCHAR2 (200) := NULL;
      nf         NUMBER;
      mensajes   t_iax_mensajes;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'psseguro= ' || psseguro;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_SituacionPoliza';
   BEGIN
      --nf := f_situacion_poliza(sseguro);
      SELECT csituac
        INTO nf
        FROM seguros
       WHERE sseguro = psseguro;

      vf := SUBSTR (f_getdescripvalores (61, nf, mensajes), 1, 200);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN vf;
   EXCEPTION
      WHEN e_object_error
      THEN
         BEGIN
            FOR i IN mensajes.FIRST .. mensajes.LAST
            LOOP
               pac_iobj_mensajes.p_grabadberror
                                 ('PAC_MD_LISTVALORES.F_Get_SituacionPoliza',
                                  1,
                                  mensajes (i).cerror,
                                  mensajes (i).terror
                                 );
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

         RETURN vf;
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
         RETURN vf;
   END f_get_situacionpoliza;

   /*************************************************************************
      Recupera la estado de la p??liza (retenida)
      param in creteni   : c??digo de retenci??n
      return             : situaci??n
   *************************************************************************/
   FUNCTION f_get_retencionpoliza (creteni IN NUMBER)
      RETURN VARCHAR2
   IS
      vf         VARCHAR2 (200) := NULL;
      nf         NUMBER;
      mensajes   t_iax_mensajes;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'creteni= ' || creteni;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_RetencionPoliza';
   BEGIN
      vf := SUBSTR (f_getdescripvalores (66, creteni, mensajes), 1, 200);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN vf;
   EXCEPTION
      WHEN e_object_error
      THEN
         BEGIN
            FOR i IN mensajes.FIRST .. mensajes.LAST
            LOOP
               pac_iobj_mensajes.p_grabadberror
                                     ('PAC_MD_LISTVALORES.F_RetencionPoliza',
                                      1,
                                      mensajes (i).cerror,
                                      mensajes (i).terror
                                     );
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

         RETURN vf;
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
         RETURN vf;
   END f_get_retencionpoliza;

   /*************************************************************************
      Motivos de rechazo de la p??liza
      param in mensajes : mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_motivosrechazopol
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_LISTVALORES.F_Get_MotivosRechazoPol';
      mensajes   t_iax_mensajes := NULL;
   BEGIN
      OPEN cur FOR
         SELECT   m.tmotmov, c.cmotmov
             FROM codimotmov c, motmovseg m
            WHERE c.cmovseg = 52
              AND c.cmotmov = m.cmotmov
              AND m.cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY c.cmotmov;

      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_motivosrechazopol;

   /*************************************************************************
      Recuperar tipos de documentos VF 672
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipdocum (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_TipDocum';
      terror     VARCHAR2 (200) := ' Error recuperar tipos documento';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      --BUG 8948 acc 240209 cur := f_detvalores(672, mensajes);
      -- Bug 20958/104537 - 21/01/2012 - AMC
      cur :=
         f_opencursor (   'select catribu,tatribu from detvalores '
                       || ' where cidioma ='
                       || pac_md_common.f_get_cxtidioma ()
                       || ' and cvalor=672 and '
                       || ' catribu <> 99 order by tatribu',
                       mensajes
                      );                                 --BUG 8948 acc 240209
      -- Fi Bug 20958/104537 - 21/01/2012 - AMC
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipdocum;

   /*************************************************************************
      Recuperar tipos de personas VF 85
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipperson (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_TipPerson';
      terror     VARCHAR2 (200) := ' Error recuperar tipos personas';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (85, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipperson;

   /*************************************************************************
      Recuperar estados de un siniestro (VF. 6)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_estadossini (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_EstadosSini';
      terror     VARCHAR2 (200) := ' Error recuperar estados siniestros';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (6, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_estadossini;

     /*************************************************************************
      Recuperar subestados de un siniestro (VF. 665)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_subestadossini (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_SubEstadosSini';
      terror     VARCHAR2 (200) := ' Error recuperar subestados siniestros';
   BEGIN
      cur := f_detvalores (665, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_subestadossini;

   /*************************************************************************
      Recuperar estados de un reembolso (VF. 891)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_estadosreemb (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_EstadosReemb';
   BEGIN
      cur := f_detvalores (891, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_estadosreemb;

   -- BUG 7624 - 20/04/2009 - SBG - S'afegeix par??m. p_tmode
   /***********************************************************************
      Dado un identificativo de domicilio llena el objeto direcciones
      param in sperson       : c??digo de persona
      param in cdomici       : c??digo de domicilio
      param in p_tmode       : modo (EST/POL)
      param in out obdirecc  : objeto direcciones
      param in out mensajes  : mensajes de error
   ***********************************************************************/
   PROCEDURE p_ompledadesdireccions (
      sperson    IN       NUMBER,
      cdomici    IN       NUMBER,
      p_tmode    IN       VARCHAR2 DEFAULT 'POL',
      obdirecc   IN OUT   ob_iax_direcciones,
      mensajes   IN OUT   t_iax_mensajes
   )
   IS
      vpasexec   NUMBER (8)                := 1;
      vparam     VARCHAR2 (100)
                         := 'sperson= ' || sperson || ' cdomici= ' || cdomici;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_LISTVALORES.F_OmpleDadesDireccions';

      /* Bug 11509.NMM.30/10/2009.i. Es canvien les taules del cursor */
      -- INI BUG CONF-441 - 14/12/2016 - JAEG
      CURSOR c_direc (psperson IN NUMBER, pcdomici IN NUMBER)
      IS
         SELECT d.cdomici,
                   DECODE (d.talias,
                           NULL, NULL,
                           d.talias || CHR (58) || CHR (32)
                          )
                || d.tdomici tdomici,
                d.cpostal, d.cprovin, d.cpoblac,
                d.ctipdir              -- Bug 25378/138739 - 27/02/2013 - AMC
           FROM per_direcciones d
          WHERE d.sperson = psperson
            AND d.cdomici = pcdomici
            AND NVL (p_tmode, 'POL') = 'POL'
         UNION
         SELECT d.cdomici,
                   DECODE (d.talias,
                           NULL, NULL,
                           d.talias || CHR (58) || CHR (32)
                          )
                || d.tdomici tdomici,
                d.cpostal, d.cprovin, d.cpoblac,
                d.ctipdir               -- Bug 25378/138739 - 27/02/2013 - AMC
           FROM estper_direcciones d
          WHERE d.sperson = psperson
            AND d.cdomici = pcdomici
            AND NVL (p_tmode, 'POL') = 'EST';

      -- INI BUG CONF-441 - 14/12/2016 - JAEG
      /* Bug 11509.NMM.30/10/2009.f.                                          */
      -- FINAL BUG 7624 - 20/04/2009 - SBG
      dic        per_direcciones%ROWTYPE;
   BEGIN
      IF sperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF cdomici IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      FOR dic IN c_direc (sperson, cdomici)
      LOOP
         obdirecc.cdomici := dic.cdomici;
         obdirecc.tdomici := TRIM (dic.tdomici);
         obdirecc.cpostal := dic.cpostal;
         obdirecc.cprovin := dic.cprovin;
         obdirecc.cpoblac := dic.cpoblac;
         obdirecc.ctipdir := dic.ctipdir;

         -- Bug 25378/138739 - 27/02/2013 - AMC
         IF dic.cprovin IS NOT NULL
         THEN                                                  -- dra 13-1-08
            obdirecc.tprovin :=
               SUBSTR
                  (f_getdescripvalor
                      (   'SELECT trim(tprovin) FROM PROVINCIAS WHERE cprovin ='
                       || dic.cprovin,
                       mensajes
                      ),
                   1,
                   30
                  );
         ELSE
            obdirecc.tprovin := NULL;
         END IF;

         IF dic.cprovin IS NOT NULL AND dic.cpoblac IS NOT NULL
         THEN                                                   -- dra 13-1-08
            obdirecc.tpoblac :=
               SUBSTR
                  (f_getdescripvalor
                      (   'SELECT trim(tpoblac) FROM POBLACIONES WHERE cprovin = '
                       || dic.cprovin
                       || ' AND cpoblac = '
                       || dic.cpoblac,
                       mensajes
                      ),
                   1,
                   50
                  );
         ELSE
            obdirecc.tpoblac := NULL;
         END IF;

         -- BUG9314:DRA:15/04/2009: Inici
         IF obdirecc.cpostal IS NOT NULL OR obdirecc.tpoblac IS NOT NULL
         THEN
            obdirecc.tdomici :=
               obdirecc.tdomici || ', ' || dic.cpostal || ' '
               || obdirecc.tpoblac;
         END IF;
      -- BUG9314:DRA:15/04/2009: Fi
      END LOOP;
   EXCEPTION
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
   END p_ompledadesdireccions;

   /***********************************************************************
      Devuelve la descripci??n del vinculo
      param in pcvincle       : c??digo vinculo
      param in out mensajes  : mensajes de error
   ***********************************************************************/
   FUNCTION f_getdescvincle (pcvincle IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2
   IS
      RESULT     VARCHAR (500);
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'pcvincle= ' || pcvincle;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_GetDescVincle';
   BEGIN
      RESULT :=
         SUBSTR (f_getdescripvalor (   'SELECT TVINCLO FROM VINCULOS '
                                    || ' WHERE CIDIOMA='
                                    || pac_md_common.f_get_cxtidioma
                                    || ' AND cvinclo='
                                    || pcvincle,
                                    mensajes
                                   ),
                 1,
                 500
                );
      RETURN RESULT;
   EXCEPTION
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
   END f_getdescvincle;

   /***********************************************************************
      Devuelve la descripci??n del tipo de cuenta bancaria
      param in psperson      : c??digo persona
      param in pcbancar      : cuenta bancaria
      param in out mensajes  : mensajes de error
   ***********************************************************************/
   FUNCTION f_gettipban (
      psperson   IN       NUMBER,
      pcbancar   IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      RESULT     VARCHAR (5);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)
                      := 'psperson= ' || psperson || ' pcbancar=' || pcbancar;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_GetTipBan';
      sqlt       VARCHAR2 (1000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pcbancar IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      sqlt :=
            'SELECT CTIPBAN FROM '
         || ' CCC WHERE SPERSON='
         || psperson
         || ' and CBANCAR='''
         || pcbancar
         || ''' AND ROWNUM=1 '
         || 'UNION ALL '
         || 'SELECT CTIPBAN FROM '
         || ' ESTCCC WHERE SPERSON='
         || psperson
         || ' and CBANCAR='''
         || pcbancar
         || ''' AND ROWNUM=1';
      RESULT := SUBSTR (f_getdescripvalor (sqlt, mensajes), 1, 5);
      RETURN RESULT;
   EXCEPTION
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
   END f_gettipban;

   /*************************************************************************
      Recuperar la lista de empresas
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstempresas (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstEmpresas';
   BEGIN
      cur := f_opencursor ('select cempres, tempres from empresas', mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstempresas;

   /*************************************************************************
      Recuperar la lista de agrupaciones de productos
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagrupprod (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstAgrupProd';
   BEGIN
      cur := f_detvalores (283, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstagrupprod;

   /*************************************************************************
      Recuperar la lista de los posibles valores del campo productos.cactivo
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstactivo (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstActivo';
   BEGIN
      cur := f_detvalores (36, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstactivo;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctermfin
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstterfinanciero (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_LISTVALORES.F_Get_LstTerFinanciero';
   BEGIN
      cur := f_detvalores (444, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstterfinanciero;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctiprie
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipriesgo (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstTipRiesgo';
   BEGIN
      cur := f_detvalores (14, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipriesgo;

   -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en b??squeda siniestros
   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctiprie
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tiporiesgo (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_TipoRiesgo';
      vsquery    VARCHAR2 (1000);
   BEGIN
      -- Bug 25177 - APD - 19/12/2012 - se realiza la join de la tabla detvalores con tipos_riesgos
      vsquery :=
            'select catribu, tatribu from detvalores d, tipos_riesgos r '
         || ' where d.cidioma ='
         || pac_md_common.f_get_cxtidioma ()
         || ' and d.cvalor = 65'
         || ' and d.catribu = r.cobjase'
         || ' and r.cempres = '
         || pac_md_common.f_get_cxtempresa ()
         || ' and r.cactivo = 1';
      -- fin Bug 25177 - APD - 19/12/2012
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tiporiesgo;

    --Fi Bug 15006 - PFA - 16/08/2010 - nuevos campos en b??squeda siniestros
   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctiprie
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcobjase (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCobjase';
   BEGIN
      cur := f_detvalores (65, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcobjase;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.csubpro
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcsubpro (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCsubpro';
   BEGIN
      cur := f_detvalores (37, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcsubpro;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cprprod
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcprprod (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCprProd';
   BEGIN
      cur := f_detvalores (205, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcprprod;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cdivisa
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstdivisa (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstDivisa';
      terror     VARCHAR2 (200) := 'Error recuperar divisas';
   BEGIN
      cur :=
         f_opencursor (   'select cdivisa, tdivisa from '
                       || '  divisa where cidioma ='
                       || pac_md_common.f_get_cxtidioma
                       || ' order by tdivisa',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdivisa;

     /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cduraci
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcduraci (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_GET_LSTCDURACI';
      terror     VARCHAR2 (200) := 'Error recuperar tipos cduraci';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (20, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcduraci;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctempor
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctempor (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCTempor';
   BEGIN
      cur := f_detvalores (23, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctempor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctempor
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcdurmin (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCdurmin';
   BEGIN
      cur := f_detvalores (686, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcdurmin;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcdurmax (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Lstcdurmax';
   BEGIN
      cur := f_detvalores (209, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcdurmax;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipefe (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCtipefe';
   BEGIN
      cur := f_detvalores (42, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipefe;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcrevali (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCrevali';
   BEGIN
      cur := f_detvalores (62, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcrevali;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctarman (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCtarman';
   BEGIN
      cur := f_detvalores (56, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctarman;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstsino (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstSiNo';
   BEGIN
      cur := f_detvalores (108, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsino;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcreteni (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCreteni';
   BEGIN
      cur := f_detvalores (66, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcreteni;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcprorra (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCProrrao';
   BEGIN
      cur := f_detvalores (174, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcprorra;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcprimin (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCprimin';
   BEGIN
      cur := f_detvalores (685, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcprimin;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cclapri
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstformulas (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstFormulas';
      terror     VARCHAR2 (200) := 'Error recuperar formulas';
   BEGIN
      cur :=
         f_opencursor (   'select clave, formula from '
                       || 'sgt_formulas where cramo ='
                       || '( select cramo from productos where sproduc ='
                       || psproduc
                       || ') order by clave',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstformulas;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ctipges
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipges (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Lstctipges';
   BEGIN
      cur := f_detvalores (43, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipges;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos creccob
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcreccob (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Lstcreccob';
   BEGIN
      cur := f_detvalores (694, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcreccob;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ctipreb
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipreb (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCtipreb';
   BEGIN
      cur := f_detvalores (40, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipreb;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ccalcom
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccalcom (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Lstccalcom';
   BEGIN
      cur := f_detvalores (122, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstccalcom;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ctippag
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctippag (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Lstctippag';
   BEGIN
      cur := f_detvalores (39, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctippag;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de garant??a (VF 33)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipgar (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstTipGar';
   BEGIN
      cur := f_detvalores (33, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipgar;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de capital garant??a (VF 34)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipcapgar (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstTipCapGar';
   BEGIN
      cur := f_detvalores (34, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipcapgar;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de capital m??ximo garant??a (VF 35)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcapmaxgar (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCapMaxGar';
   BEGIN
      cur := f_detvalores (35, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcapmaxgar;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de tarifas garant??a (VF 48)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttiptargar (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstTipTarGar';
   BEGIN
      cur := f_detvalores (48, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttiptargar;

   /*************************************************************************
      Recuperar la lista de posibles valores de reaseguro de garant??a (VF 134)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstreagar (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstReaGar';
   BEGIN
      cur := f_detvalores (134, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstreagar;

   /*************************************************************************
      Recuperar la lista de posibles valores de revalorizaciones de garant??a (VF 279)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstrevalgar (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstRevalGar';
   BEGIN
      cur := f_detvalores (279, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstrevalgar;

   --JRH 04/2008 Tarea ESTPERSONAS
       /*************************************************************************
          Recupera los paises
          param out mensajes : mensajes de error
          return             : ref cursor
       *************************************************************************/
   FUNCTION f_get_lstpaises (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstPaises';
      terror     VARCHAR2 (200) := 'Error recuperar paises';
   BEGIN
      cur :=
         f_opencursor
                   (   ' select cpais, tpais from DESPAISES where cidioma ='
                    || pac_md_common.f_get_cxtidioma
                    || ' ORDER BY tpais',
                    mensajes
                   );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstpaises;

   --JRH 04/2008 Tarea ESTPERSONAS
     /*************************************************************************
          Recupera las profesiones
             param in mensajes : mensajes de error
          return            : ref cursor
       *************************************************************************/
   FUNCTION f_get_lstprofesiones (
      mensajes     IN OUT   t_iax_mensajes,
      cocupacion   IN       NUMBER DEFAULT 0
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstProfesiones';
      vsquery    VARCHAR2 (200);
   BEGIN
      vsquery :=
         ' SELECT p.tprofes, p.cprofes FROM profesiones p WHERE p.CIDIOMA = PAC_MD_COMMON.F_GET_CXTIDIOMA  ORDER BY p.tprofes ';

      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'PER_PROFESION'
                                            ),
              0
             ) = 0
      THEN
         vsquery :=
               ' SELECT p.tprofes, p.cprofes '
            || ' FROM profesiones p WHERE p.CIDIOMA = PAC_MD_COMMON.F_GET_CXTIDIOMA AND nvl(p.OCUPACION, 0) = '
            || cocupacion
            || ' ORDER BY p.tprofes ';
      ELSE
         vsquery :=
               'select d.tprofes, d.cprofes from codprofesionprod c, detprofesionprod d '
            || ' where c.cprofes = d.cprofes and d.cidioma = PAC_MD_COMMON.F_GET_CXTIDIOMA ORDER BY d.tprofes';
      END IF;

      cur := f_opencursor (vsquery, mensajes);
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstprofesiones;

   --JRH 04/2008 Tarea ESTPERSONAS
     /*************************************************************************
          Recupera los tipos de cuents
             param in mensajes : mensajes de error
          return            : ref cursor
       *************************************************************************/
   FUNCTION f_get_lsttipocuenta (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstTipoCuenta';
      vsquery    VARCHAR2 (200);
   BEGIN
      vsquery :=
         ' SELECT ctipban, ttipo   FROM tipos_cuentades  WHERE CIDIOMA = PAC_MD_COMMON.F_GET_CXTIDIOMA ';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipocuenta;

   --JRH 04/2008 Tarea ESTPERSONAS
     /*************************************************************************
          Recupera los tipos de direcci??n
             param in mensajes : mensajes de error
          return            : ref cursor
       *************************************************************************/
   FUNCTION f_get_lsttipodireccion (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_LISTVALORES.F_Get_LstTipoDireccion';
   BEGIN
      cur := f_detvalores (191, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipodireccion;

   --JRH 04/2008 Tarea ESTPERSONAS
     /*************************************************************************
          Recupera los tipos de v??a
             param in mensajes : mensajes de error
          return            : ref cursor
       *************************************************************************/
   FUNCTION f_get_lsttipovia (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstTipoVia';
      vsquery    VARCHAR2 (200);
   BEGIN
      vsquery :=
         ' select csiglas, TDENOM from DESTIPOS_VIA Where cidioma = PAC_MD_COMMON.F_Get_CXTIDIOMA() Order by TDENOM  ';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipovia;

   --JRH 04/2008 Tarea ESTPERSONAS
       /*************************************************************************
          Recupera la consulta de pobl., provin.
          param out mensajes : mensajes de error
          return             : ref cursor
       *************************************************************************/
   FUNCTION f_get_consulta (
      codigo      IN       VARCHAR2,
      condicion   IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Consulta';
      terror     VARCHAR2 (200) := 'Error recuperar paises';
      errores    t_ob_error;
      vnumerr    NUMBER         := 0;
   BEGIN
      cur :=
         pac_listvalores.f_get_consulta (codigo,
                                         condicion,
                                         pac_md_common.f_get_cxtidioma (),
                                         vnumerr
                                        );

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --  mensajes:=Pac_Md_persona.TraspasarErroresMensajes( Errores );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_consulta;

   ----SGM IAXIS-6149 28/10/2019
       /*************************************************************************
          Recupera la consulta de personas publicas
          param out mensajes : mensajes de error
          return             : ref cursor
       *************************************************************************/
   FUNCTION f_get_publicinfo (
      codigo      IN       VARCHAR2,
      condicion   IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_publicinfo';
      terror     VARCHAR2 (200) := 'Error recuperar paises';
      errores    t_ob_error;
      vnumerr    NUMBER         := 0;
   BEGIN
      cur :=
         pac_listvalores.f_get_publicinfo (codigo,
                                         condicion,
                                         pac_md_common.f_get_cxtidioma (),
                                         vnumerr
                                        );

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --  mensajes:=Pac_Md_persona.TraspasarErroresMensajes( Errores );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_publicinfo;

   /*************************************************************************
      Recupera los diferentes niveles que hay de intereses o gastos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstnivel (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_lstNivel';
      terror     VARCHAR2 (200)
                              := 'Error recuperar niveles intereses o gastos';
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (287, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstnivel;

   /*************************************************************************
      Recupera los diferentes cuadros que existen a d??a de hoy
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstncodint (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_lstncodint';
      vsquery    VARCHAR2 (200);
   BEGIN
      vsquery :=
         'select d.ncodint, d.ttexto from detintertec d
                  where d.cidioma = PAC_MD_COMMON.F_Get_CXTIDIOMA';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstncodint;

    /*************************************************************************
      Recupera los diferentes tipos de inter??s que puede tener un cuadro de inter??s.
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipinteres (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_TipInteres';
      terror     VARCHAR2 (200)
                              := 'Error recuperar niveles intereses o gastos';
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (848, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipinteres;

   /*************************************************************************
      Recupera los diferentes conceptos de tramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
--BUG 0024467: XVM :02/11/2012--Inicio
   FUNCTION f_get_ctramtip (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_Ctramtip';
      terror     VARCHAR2 (200)
          := 'Error recuperar los tipos de tramiteniveles intereses o gastos';
   --//ACC recuperar desde literales
   --//ACC PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur :=
         f_opencursor
            (   'select ctramte catribu, ttramite tatribu from sin_destramite '
             || ' where cidioma ='
             || pac_md_common.f_get_cxtidioma ()
             || ' and ctramte != 9999',
             mensajes
            );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ctramtip;

--BUG 0024467: XVM :02/11/2012--Fin

   /*************************************************************************
          Recupera los LITERALES
          param IN pcidioma : Filtrado por IDIOMA
          param out mensajes : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_literales (pcidioma IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'par??metros: cidioma=' || pcidioma;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Literales';
      vsquery    VARCHAR2 (400);
   BEGIN
      vsquery :=
            ' select * from AXIS_LITERALES_INSTALACION Where cidioma = '
         || pcidioma
         || ' union
                           select * from AXIS_LITERALES
                           where cidioma = '
         || pcidioma
         || ' and slitera not in (select slitera from AXIS_LITERALES_INSTALACION where cidioma = '
         || pcidioma
         || ')';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_literales;

   /*************************************************************************
          Recupera los Tipos de recibo
          (Detvalores.cvalor=8)
          param out mensajes : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctiprec (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_LstCTIPREC';
      terror     VARCHAR2 (200) := 'Error recuperar tipos recibo';
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (8, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END;

   /*************************************************************************
          Recupera los Estados de recibo
          (Detvalores.cvalor=1)
          param out mensajes : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstestadorecibo (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_LstEstadoRecibo';
      terror     VARCHAR2 (200) := 'Error recuperar estados recibo';
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (1, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END;

   /*************************************************************************
          Recupera los c??digos y la descripciones de los tipos de IVA definidos.
          param out mensajes : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipoiva (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_LstTipoIva';
      vsquery    VARCHAR2 (200);
   BEGIN
      vsquery :=
         ' SELECT ctipiva,ttipiva FROM descripcioniva
                   WHERE cidioma = PAC_MD_COMMON.F_Get_CXTIdioma ORDER BY ctipiva';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipoiva;

   /*************************************************************************
          Recupera c??digo y la descripci??n de los tipos de retenci??n definidos
          param out mensajes : mensajes de error
          return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstretencion (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_LstRetencion';
      vsquery    VARCHAR2 (200);
   BEGIN
      vsquery :=
         ' SELECT cretenc,ttipret FROM descripcionret
                    WHERE cidioma = PAC_MD_COMMON.F_Get_CXTIdioma ORDER BY cretenc';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstretencion;

   /*************************************************************************
          Recupera c??digo de estado de agente y descripci??n.
          param out mensajes : mensajes de error
          return : ref cursor
   *************************************************************************/
   -- Bug 19169 - APD - 15/09/2011 - se a??ade al parametro pcempres, pcvalor, pcatribu
   -- Bug 21682 - APD - 24/04/2012 - se a?ade al parametro pctipage (sustituye a pcatribu), pcactivo
   FUNCTION f_get_lstestadoagente (
      pcempres   IN       NUMBER,
      pcvalor    IN       NUMBER,
--      pcatribu IN NUMBER,
      pctipage   IN       NUMBER,
      pcactivo   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)                := 1;
      vparam     VARCHAR2 (100)            := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_LstEstadoAgente';
      vsquery    VARCHAR2 (200);
      vcatribu   detvalores.catribu%TYPE;
      vtatribu   detvalores.tatribu%TYPE;
   BEGIN
      -- Bug 19169 - APD - 15/09/2011 - Modificar la select para busque los valores posibles de los estados en funci??n de la dependencia.
      IF     pcempres IS NULL
         AND pcvalor IS NULL
         --AND pcatribu IS NULL
         AND pctipage IS NULL
         AND pcactivo IS NULL
      THEN
         cur := f_detvalores (31, mensajes);
      ELSE
         vpasexec := 2;
         -- Bug 21682 - APD - 24/04/2012 - primero se mira si hay parametrizacion en la
         -- tabla age_transiciones
         cur :=
            pac_md_listvalores.f_get_lstestadoagente_trans (pcempres,
                                                            pctipage,
                                                            pcactivo,
                                                            mensajes
                                                           );

         FETCH cur
          INTO vcatribu, vtatribu;

         vpasexec := 3;

         -- si no hay datos, se cierra el cursor y se mira si hay parametrizacion
         -- en la tabla detvalores_dep
         IF cur%NOTFOUND
         THEN                                                  -- No hay datos
            IF cur%ISOPEN
            THEN
               CLOSE cur;
            END IF;

            -- fin Bug 21682 - APD - 24/04/2012
            IF pcempres IS NULL OR pcvalor IS NULL
            THEN
               vpasexec := 4;
               RAISE e_param_error;
            END IF;

            cur :=
                  f_detvalores_dep (pcempres, pcvalor, pctipage, 31, mensajes);
            vpasexec := 5;

            FETCH cur
             INTO vcatribu, vtatribu;

            vpasexec := 6;

            IF cur%NOTFOUND
            THEN                                               -- No hay datos
               IF cur%ISOPEN
               THEN
                  CLOSE cur;
               END IF;

               cur := f_detvalores (31, mensajes);
            ELSE
               -- si hay datos, se debe cerrar y volver a abrir ya que se ha hecho una vez
               -- el fetch y sino no saldria el primer registro
               IF cur%ISOPEN
               THEN
                  CLOSE cur;
               END IF;

               cur :=
                  f_detvalores_dep (pcempres, pcvalor, pctipage, 31, mensajes);
            END IF;
         -- Bug 21682 - APD - 24/04/2012
         ELSE
            -- si hay datos, se debe cerrar y volver a abrir ya que se ha hecho una vez
            -- el fetch y sino no saldria el primer registro
            IF cur%ISOPEN
            THEN
               CLOSE cur;
            END IF;

            cur :=
               pac_md_listvalores.f_get_lstestadoagente_trans (pcempres,
                                                               pctipage,
                                                               pcactivo,
                                                               mensajes
                                                              );
         END IF;
      -- fin Bug 21682 - APD - 24/04/2012
      END IF;

      -- fin Bug 19169 - APD - 15/09/2011
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestadoagente;

       /*************************************************************************
          Recupera c??digo de tipo de agente y descripci??n.
          param out mensajes : mensajes de error
          return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipoagente (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_LstTipoAgente';
      vsquery    VARCHAR2 (200);
   BEGIN
      cur := pac_redcomercial.f_get_ageniveles (NULL, NULL);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipoagente;

   /*************************************************************************
          Recupera c??digo y descripci??n de las diferentes comisiones definidas para los agentes.
          param out mensajes : mensajes de error
          return : ref cursor
   *************************************************************************/
   -- Bug 19169 - APD - 15/09/2011 - se a??ade al parametro pctipo
   FUNCTION f_get_lstagecomision (
      pctipo     IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_get_LstAgeComision';
      vsquery    VARCHAR2 (2000);
   BEGIN
/*
      vsquery :=
         ' SELECT ccomisi,tcomisi FROM descomision
                   WHERE cidioma=PAC_MD_COMMON.F_Get_CXTIdioma
                   ORDER BY ccomisi';
*/
      vsquery :=
            ' SELECT d.ccomisi,d.tcomisi FROM codicomisio c, descomision d
                   WHERE c.ccomisi = d.ccomisi
                   AND (c.ctipo = NVL('
         || NVL (TO_CHAR (pctipo), 'NULL')
         || ', c.ctipo) OR '
         || NVL (TO_CHAR (pctipo), 'NULL')
         || ' IS NULL) AND c.ccomisi IN (SELECT distinct(cv.ccomisi)
                                FROM comisionvig cv
                                WHERE cv.cestado = 2)'
         || ' AND d.cidioma=PAC_MD_COMMON.F_Get_CXTIdioma
                   ORDER BY d.tcomisi';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstagecomision;

   /*************************************************************************
      Recupera la lista de valores del desplegable de meses
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmeses (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstMeses';
      terror     VARCHAR2 (200) := 'Error recuperar meses del a??o';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (54, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmeses;

   /***************NUEVAS JGM 27-08-2008**********************************************************/
   /*Esta funci??n tendr?? un par??metro de salida t_iax_mensajes con los posibles mensajes de error y
     nos devolver?? un sys_refcursor con el c??digo del tipo de cierre activo y su descripci??n.
          param IN pcempres : Filtrado por empresa
          param IN OUT msj : mensajes de error
          return             : ref cursor
     */
   FUNCTION f_get_lsttipocierre (
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (200)  := 'pcempres=' || pcempres;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_LstTipoCierre';
      squery     VARCHAR2 (1000);
   BEGIN
      IF pcempres IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      squery :=
            'select pds.CTIPO, '
         || 'Ff_Desvalorfijo (167, pac_md_common.f_get_CXTIdioma(), pds.CTIPO) tctipo '
         || 'from pds_program_cierres pds '
         || 'where pds.cempres = '
         || pcempres
         || ' and pds.CACTIVO = 1';
      cur := pac_md_listvalores.f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipocierre;

   /*Esta funci??n tendr?? un par??metro de entrada PPREVIO y un par??metro de salida t_iax_mensajes con los posibles
   mensajes de error y nos devolver?? un sys_refcursor con los diferentes c??digo de estado de cierre activo y su descripci??n.
      param IN previo : par??metro para mostrar o no el estado PREVIO PROGRAMADO
      param IN OUT msj : mensajes de error
      return             : ref cursor
   */
   FUNCTION f_get_lstestadocierre (
      pprevio    IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (200)  := 'pprevio=' || pprevio;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_LstEstadoCierre';
      squery     VARCHAR2 (1000);
   BEGIN
      IF pprevio IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pprevio = 0
      THEN
         /*cur:= F_OpenCursor('select catribu,tatribu from detvalores '||
                  ' where cidioma ='|| PAC_MD_COMMON.F_Get_CXTIdioma() ||
                  ' and cvalor= 168', mensajes);*/
         cur := f_detvalores (168, mensajes);
      ELSIF pprevio = 1
      THEN
         --AQUI NO PUEDO USAR LA FUNCION puesto que no quiero el valor 22 ni 1 --
         cur :=
            f_opencursor (   'select catribu,tatribu from detvalores '
                          || ' where cidioma ='
                          || pac_md_common.f_get_cxtidioma ()
                          || ' and cvalor= 168 and catribu <> 22',
                          mensajes
                         );
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestadocierre;

   /*Esta funci??n tendr?? un par??metro de entrada PPREVIO y un par??metro de salida t_iax_mensajes con los posibles
   mensajes de error y nos devolver?? un sys_refcursor con los diferentes c??digo de estado de cierre activo y su descripci??n.
   no sacar?? los estados CERRADO y PENDIENTE
      param IN previo : par??metro para mostrar o no el estado PREVIO PROGRAMADO
      param IN OUT msj : mensajes de error
      return             : ref cursor
   */
   FUNCTION f_get_lstestadocierre_nuevo (
      pprevio    IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (200)  := 'pprevio=' || pprevio;
      vobject    VARCHAR2 (200)
                          := 'PAC_MD_LISTVALORES.f_get_LstEstadoCierre_nuevo';
      squery     VARCHAR2 (1000);
   BEGIN
      IF pprevio IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pprevio = 0
      THEN
         --AQUI NO PUEDO USAR LA FUNCION puesto que no quiero el valor 22 --
         cur :=
            f_opencursor (   'select catribu,tatribu from detvalores '
                          || ' where cidioma ='
                          || pac_md_common.f_get_cxtidioma ()
                          || ' and cvalor= 168 and catribu NOT IN (22,1)',
                          mensajes
                         );
      ELSIF pprevio = 1
      THEN
         --AQUI NO PUEDO USAR LA FUNCION puesto que no quiero el valor 22 ni 1 --
         cur :=
            f_opencursor (   'select catribu,tatribu from detvalores '
                          || ' where cidioma ='
                          || pac_md_common.f_get_cxtidioma ()
                          || ' and cvalor= 168 and catribu NOT IN (1)',
                          mensajes
                         );
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestadocierre_nuevo;

   -- ini t.7661
   /*************************************************************************
      Recupera la Lista de compa????as de reaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcia_rea (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstCia_Rea';
      vsquery    VARCHAR2 (500);      -- Bug 25502-141163 - JLTS - 26/03/2013
   BEGIN
      -- Bug 25502-141163 - JLTS - 26/03/2013 -- Ini
      vsquery :=
         'SELECT CCOMPANI, TCOMPANI
                 FROM companias
                 WHERE (ctipcom = 0 or ctipcom is null)
                   AND (fbaja IS NULL OR fbaja > f_sysdate)
                 ORDER BY TCOMPANI';
      -- Bug 25502-141163 - JLTS - 26/03/2013 -- Ini
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcia_rea;

   /*************************************************************************
      Recupera la Lista de los tipos de reaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipo_rea (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstTipo_Rea';
   BEGIN
      cur := f_detvalores (106, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipo_rea;

   /*************************************************************************
      Recupera la Lista de las agrupaciones de reaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagr_rea (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstAgr_Rea';
      vsquery    VARCHAR2 (200);
   BEGIN
      vsquery :=
         'SELECT SCONAGR, TCONAGR
                 FROM descontratosagr
                 WHERE cidioma=PAC_MD_COMMON.F_Get_CXTIdioma
                 ORDER BY SCONAGR';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstagr_rea;

   -- fin t.7661

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   /*************************************************************************
      Recupera la Lista de compa????as de coaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_coaseguradoras (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_coaseguradoras';
      vsquery    VARCHAR2 (200);
   BEGIN
      -- Bug 23963/125448 - 17/10/2012 - AMC
      -- Bug 24655/133926 - 02/01/2013 - ECP  Se cambia WHERE (ctipcom = 0 or ctipcom is null) por WHERE ctipcom = 3
      --INI - AXIS 4406 - 14/6/2019 - AABG - SE ENVIA EL VALOR DE TIPOCOMPANIA = 2 QUE CORRESPONDE A COASEGURO
      vsquery :=
            'SELECT CCOMPANI, TCOMPANI
                 FROM companias
                 WHERE ctipcom = 2 '
         -- 72.0 -16/09/2013- MMM - 0028158: LCOL_A003-Listas desplegables de companyias - Inicio
         || ' AND (fbaja IS NULL OR fbaja > f_sysdate) '
         -- 72.0 - 16/09/2013 - MMM - 0028158: LCOL_A003-Listas desplegables de companyias - Fin
         || ' ORDER BY TCOMPANI';
      --FIN - AXIS 4406 - 14/6/2019 - AABG - SE ENVIA EL VALOR DE TIPOCOMPANIA = 2 QUE CORRESPONDE A COASEGURO
      -- Fi Bug 23963/125448 - 17/10/2012 - AMC
      -- Fi Bug 24655/133926 - 02/01/2013 - ECP
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_coaseguradoras;

-- Fin Bug 0023183

   /*************************************************************************
      Recupera los ramos con su descripcion por empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cramo_emp (pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (10)   := pcempres;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_Cramo_Emp';
      vsquery    VARCHAR2 (2000);
   BEGIN
      vsquery :=
            'select r.cramo,r.tramo
                   from ramos r, codiram c
                  where r.cidioma = '
         || pac_md_common.f_get_cxtidioma
         || ' and c.cramo = r.cramo
                    and c.cempres = '
         || NVL (TO_CHAR (pcempres), 'null')
         || ' order by r.tramo';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cramo_emp;

   /*************************************************************************
      Recupera los productos con su descripcion por ramo
      param in pcramo    : ramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_productos_cramo (
      pcramo     IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (10)   := pcramo;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Productos_Cramo';
      vsquery    VARCHAR2 (2000);
   BEGIN
      vsquery :=
            'select p.cramo,p.cmodali,p.ctipseg,p.ccolect,t.ttitulo
                   from productos p, titulopro t
                  where p.cramo = '
         || NVL (TO_CHAR (pcramo), 'null')
         || ' AND p.cramo = t.cramo
                    AND p.cmodali = t.cmodali
                    AND p.ccolect = t.ccolect
                    AND t.cidioma = pac_md_common.f_get_cxtidioma
                  order by p.cramo, t.ttitulo';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END;

   /*************************************************************************
      Recupera las actividades con su descripcion por producto
      param in psproduc  : id. interno de producto
      param in pcramo    : ramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cactivi (
      psproduc   IN       NUMBER,
      pcramo     IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur          sys_refcursor;
      vpasexec     NUMBER (8)      := 1;
      vparam       VARCHAR2 (100)
                        := ' pcramo: ' || pcramo || ' psproduc: ' || psproduc;
      vobject      VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_Cactivi';
      vsquery      VARCHAR2 (2000);
      vactivi0     NUMBER;
      vcount       NUMBER;
      vcondicion   VARCHAR2 (50);
   BEGIN
      -- Bug 16392 - 21/10/2010 - AMC
      -- Dependiendo del par_producto ACTIVI0 se incluira la actividad 0 o no,
      -- siempre que haiga mas actividdes asignadas al producto
      vactivi0 := NVL (f_parproductos_v (psproduc, 'ACTIVI0'), 0);

      IF vactivi0 = 0
      THEN
         SELECT COUNT (cactivi)
           INTO vcount
           FROM activiprod p, productos pp
          WHERE pp.sproduc = psproduc
            AND p.cramo = pp.cramo
            AND p.cmodali = pp.cmodali
            AND p.ctipseg = pp.ctipseg
            AND p.ccolect = pp.ccolect
            -- JLB  18181
            AND NVL (p.cactivo, 1) = 1
            AND p.cactivi <> 0;

         IF vcount > 0
         THEN
            vcondicion := ' and s.cactivi <> 0';
         END IF;
      END IF;

      -- Bug 18319 - APD - 28/09/2011
      -- se a??ade el distinct en la select
      -- se a??ade el parametro pcramo en la select
      vsquery :=
            'select distinct s.cactivi,s.ttitulo
                  from activisegu s, activiprod p, productos pp
                 where s.cactivi = p.cactivi
                   and s.cramo = p.cramo
                   and s.cidioma = pac_md_common.f_get_cxtidioma
                   and pp.sproduc = '
         || NVL (TO_CHAR (psproduc), 'pp.sproduc')
         || ' and pp.cramo = '
         || NVL (TO_CHAR (pcramo), 'pp.cramo')
         || ' and p.cramo = pp.cramo'
         || ' and p.cmodali =  pp.cmodali'
         || ' and p.ctipseg = pp.ctipseg'
         || ' and p.ccolect = pp.ccolect '
         -- JLB  18181
         || '  and nvl(p.cactivo,1) = 1  '
         || vcondicion
         || ' order by s.ttitulo';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cactivi;

/*************************************************************************
      Recupera las garantias con su descripcion por producto y actividad
      param in psproduc  : id. interno de producto
      param in pcramo    : ramo
      param in pcactivi  : actividad
      param out mensajes : mensajes de error
      return             : ref cursor

   *************************************************************************/
   FUNCTION f_get_cgarant (
      psproduc   IN       NUMBER,
      pcramo     IN       NUMBER,
      pcactivi   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)
         :=    ' pcramo: '
            || pcramo
            || ' psproduc: '
            || psproduc
            || ' pcactivi: '
            || pcactivi;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_Cgarant';
      vsquery    VARCHAR2 (2000);
   BEGIN
      -- Bug 15137 - 03/08/2010 - AMC
      vsquery :=
            'select distinct g.cgarant, g.tgarant
                   from garanpro p, garangen g, productos pp
                  where g.cgarant = p.cgarant
                    and g.cidioma = pac_md_common.f_get_cxtidioma
                    and pp.sproduc = NVL('
         || NVL (TO_CHAR (psproduc), 'null')
         || ',pp.sproduc)'
         || ' and pp.cramo = NVL('
         || NVL (TO_CHAR (pcramo), 'null')
         || ', pp.cramo)'
         || ' and p.cramo = pp.cramo'
         || ' and p.cmodali = pp.cmodali'
         || ' and p.ctipseg = pp.ctipseg'
         || ' and p.ccolect = pp.ccolect'
         || ' and p.cactivi = NVL('
         || NVL (TO_CHAR (pcactivi), 'null')
         || ', p.cactivi)'
         || ' order by g.tgarant';
      --Fi Bug 15137 - 03/08/2010 - AMC
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cgarant;

   /*************************************************************************
      Recupera las garantias con su descripcion por poliza
      param in p_npoliza : numero de poliza
      param out mensajes : mensajes de error
      return             : ref cursor

   *************************************************************************/
   FUNCTION f_get_cgarant_pol (
      p_npoliza   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100);
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_Cgarant';
      vsquery    VARCHAR2 (2000);
   BEGIN
      vsquery :=
            'SELECT DISTINCT par.cgarant, par.tgarant
           FROM seguros seg, movseguro mov, garanseg gar, garangen par
          WHERE seg.sseguro = mov.sseguro
            AND gar.sseguro = mov.sseguro
            AND gar.nmovimi = mov.nmovimi
            AND par.cidioma = pac_md_common.f_get_cxtidioma
            AND par.cgarant = gar.cgarant
            AND seg.npoliza = '
         || p_npoliza;
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cgarant_pol;

   /*************************************************************************
      Recupera las garantias con su descripcion por siniestro
      param in p_nsinies: numero de siniestro
      param out mensajes : mensajes de error
      return             : ref cursor

   *************************************************************************/
   FUNCTION f_get_cgarant_sin (
      p_nsinies   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100);
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_Cgarant';
      vsquery    VARCHAR2 (2000);
   BEGIN
      vsquery :=
            'SELECT DISTINCT par.cgarant, par.tgarant
           FROM sin_tramita_reserva trm, garangen par
          WHERE trm.cgarant = par.cgarant
            AND trm.nsinies = '
         || p_nsinies
         || 'AND par.cidioma = pac_md_common.f_get_cxtidioma';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cgarant_sin;

/*************************************************************************
      Recupera la descripci??n de una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_desempresa (
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      vret       VARCHAR2 (50);
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (10)  := pcempres;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Desempresa';
   BEGIN
      IF pcempres IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT tempres
        INTO vret
        FROM empresas
       WHERE cempres = pcempres;

      RETURN vret;
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
   END f_get_desempresa;

   /*************************************************************************
      Recupera lista de c??digo+descripci??n cuenta contable.
      param out msj : mensajes de error
      return        : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcuentacontable (msj IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100);
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_LISTVALORES.F_Get_LstCuentaContable';
      vsquery    VARCHAR2 (200);
   BEGIN
      -- Bug 0035181 - 12/03/2015 - JMF: Si no encuentra literal, mostramos descripción de la tabla.
      vsquery :=
         ' SELECT ccuenta,
                     decode(slitera,null,TDESCRI,F_AXIS_LITERALES(slitera,PAC_MD_COMMON.F_Get_CXTIdioma)) tcuenta';
      vsquery := vsquery || ' FROM DESCUENTA ORDER BY ccuenta';
      cur := f_opencursor (vsquery, msj);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (msj,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcuentacontable;

   /*************************************************************************
      Recupera la lista de tipo de concepto contable y su descripci??n.
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstconceptocontable (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100);
      vobject    VARCHAR2 (200)
                            := 'PAC_MD_LISTVALORES.F_Get_LstConceptoContable';
   BEGIN
      cur := f_detvalores (19, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstconceptocontable;

   /*************************************************************************
      Recupera lista de c??digo+descripci??n asiento contable.
      param in p_empresa : c??digo de empresa
      param out msj      : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstasiento (p_empresa IN NUMBER, msj IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'Param.: P_EMPRESA = ' || p_empresa;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstAsiento';
      vsquery    VARCHAR2 (250);
   BEGIN
      -- BUG 7174 - 28/04/2009 - SBG - Es modifica el cursor vsquery
      vsquery := ' SELECT DISTINCT tatribu, TO_CHAR(casient) catribu';
      vsquery := vsquery || ' FROM MODCONTA, DETVALORES';
      vsquery := vsquery || ' WHERE casient = catribu';
      vsquery :=
            vsquery
         || ' AND fini<=f_sysdate AND TRUNC(NVL(ffin,f_sysdate))>= TRUNC(f_sysdate)';
      vsquery := vsquery || ' AND cvalor = 132 AND CEMPRES = ' || p_empresa;
      vsquery := vsquery || ' AND cidioma = ' || pac_md_common.f_get_cxtidioma;
      vsquery := vsquery || ' ORDER BY casient';
      -- FINAL BUG 7174 - 28/04/2009 - SBG
      cur := f_opencursor (vsquery, msj);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (msj,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstasiento;

   /*************************************************************************
      Recupera los cobradores y cuentas de domiciliaci??n vigentes para una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor

         11/02/2009   FAL                Cobradores, delegaciones. Bug: 0007657
   *************************************************************************/
   FUNCTION f_get_lstcobradores (
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'pcempres= ' || pcempres;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_lstcobradores';
      terror     VARCHAR2 (200) := 'Error recuperar cobradores';
   BEGIN
      --INI BUG 38323-216944 KJSC Mostrar el cobrador bancario en la pantalla AXISADM018-Modificar recibo.
      IF NVL (pac_parametros.f_parempresa_n (pcempres, 'LV_LSTCCOBBAN_REC'),
              0
             ) = 1
      THEN
         cur :=
            f_opencursor
                (   'select ccobban, descripcion ||'' ''|| ncuenta tdescri '
                 || '  from cobbancario '
                 || ' where cempres = '
                 || pcempres
                 || '   and cbaja <> 1'
                 || '   and ncuenta <> ''0'' '
                 || '  ORDER BY ccobban',
                 mensajes
                );
      ELSE
         cur :=
            f_opencursor
                     (   'select ccobban, ncuenta tdescri from cobbancario '
                      || ' where cempres ='
                      || pcempres
                      || ' and cbaja <> 1 ORDER BY ccobban',
                      mensajes
                     );
      END IF;

      --FIN BUG 38323-216944 KJSC Mostrar el cobrador bancario en la pantalla AXISADM018-Modificar recibo.
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcobradores;

   /*************************************************************************
      Recupera las delegaciones de una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor

         11/02/2009   FAL                Cobradores, delegaciones. Bug: 0007657
   *************************************************************************/
   FUNCTION f_get_lstdelegaciones (
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (100) := 'pcempres= ' || pcempres;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_lstdelegaciones';
      terror     VARCHAR2 (200) := 'Error recuperar delegaciones';
   BEGIN
      /*
            cur :=
               f_opencursor
                  ('select a.cagente, NVL(LTRIM(RTRIM(d.tapelli1)) || DECODE(d.tnombre, NULL, NULL, '', ''||LTRIM(RTRIM(d.tnombre))),''**'') tnombre'
                   || ' from agentes a, redcomercial c, per_personas p, per_detper d '
                   || ' where c.cempres =' || pcempres
                   || ' and c.cagente = a.cagente and c.ctipage = 1 and a.sperson = p.sperson and p.sperson = d.sperson (+) ORDER BY a.cagente',
                   mensajes);
      */

      -- 12/03/2009. FAL. Bug 0007657: Cambio en la select de f_get_lstdelegaciones
      cur :=
         f_opencursor
            (   'select a.cagente, f_nombre(a.sperson, 1) tnombre from agentes a where a.fbajage is null and a.cactivo = 1'
             || ' and a.cagente in ( select cagente from redcomercial c where c.cempres = '
             || pcempres
             || ' and c.ctipage = 1 )'
             || ' ORDER BY a.cagente',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdelegaciones;

   /*************************************************************************
          Recupera c??digo de tipo de apunte en la agenda y descripci??n.
          param out mensajes : mensajes de error
          return : ref cursor

             11/02/2009   FAL                Tipos de apunte en agenda. Bug: 0008748
   *************************************************************************/
   FUNCTION f_get_lsttipoapuntesagenda (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := NULL;
      vobject    VARCHAR2 (200)
                           := 'PAC_MD_LISTVALORES.f_get_lsttipoapuntesagenda';
      vsquery    VARCHAR2 (200);
   BEGIN
      cur := f_detvalores (323, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipoapuntesagenda;

   /*************************************************************************
          Recupera estados de apunte en la agenda y descripci??n.
          param out mensajes : mensajes de error
          return : ref cursor

             11/02/2009   FAL                Tipos de apunte en agenda. Bug: 0008748
   *************************************************************************/
   FUNCTION f_get_lstestadosapunteagenda (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := NULL;
      vobject    VARCHAR2 (200)
                         := 'PAC_MD_LISTVALORES.F_get_lstEstadosApunteAgenda';
      vsquery    VARCHAR2 (200);
   BEGIN
      cur := f_detvalores (29, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestadosapunteagenda;

   /*************************************************************************
          Recupera los conceptos de apunte en la agenda y descripci??n.
          param out mensajes : mensajes de error
          return : ref cursor

             06/03/2009   JSP                Conceptos de apunte en agenda. Bug: 0009208
   *************************************************************************/
   FUNCTION f_get_lstconceptosapunteagenda (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := NULL;
      vobject    VARCHAR2 (200)
                       := 'PAC_MD_LISTVALORES.f_get_lstconceptosapunteagenda';
      vsquery    VARCHAR2 (200);
   BEGIN
      cur := f_detvalores (21, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstconceptosapunteagenda;

   /*************************************************************************
          Recupera usuarios de la agenda y descripci??n.
          param out mensajes : mensajes de error
          return : ref cursor

             06/03/2009   JSP                Conceptos de apunte en agenda. Bug: 0009208
   *************************************************************************/
   FUNCTION f_get_lstusuariosagenda (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_LISTVALORES.f_get_lstusuariosagenda';
      vsquery    VARCHAR2 (2000);
      vcempres   NUMBER (10);
      vcuser     VARCHAR2 (50);
      vcaccion   VARCHAR2 (50);
      vnumerr    NUMBER (10);
   BEGIN
      vcempres := pac_md_common.f_get_cxtempresa ();
      vcuser := pac_md_common.f_get_cxtusuario ();
      vnumerr := pac_cfg.f_get_user_cfgaccion (vcuser, vcempres, vcaccion);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vsquery :=
         'SELECT distinct(CUSUARI) AS CUSER,TUSUNOM AS NOMBRE FROM USUARIOS  WHERE CTIPUSU = 2  AND FBAJA IS NULL';
      vsquery :=
                vsquery || ' AND CEMPRES = ' || pac_md_common.f_get_cxtempresa;
      vsquery := vsquery || ' ORDER BY CUSUARI';
      cur := pac_md_listvalores.f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstusuariosagenda;

   /*************************************************************************
          Recupera els graus de minusvalia
          param out mensajes : mensajes de error
          return : ref cursor

             16/03/2009   XPL                Mant. Pers. IRPF. Bug: 0007730
   *************************************************************************/
   FUNCTION f_get_lstgradominusvalia (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (10)  := NULL;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_LISTVALORES.f_get_LSTGRADOMINUSVALIA';
   BEGIN
      cur := f_detvalores (688, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstgradominusvalia;

   /*************************************************************************
          Recupera les situacions familiars
          param out mensajes : mensajes de error
          return : ref cursor

             16/03/2009   XPL                Mant. Pers. IRPF. Bug: 0007730
   *************************************************************************/
   FUNCTION f_get_lstsitfam (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (10)  := NULL;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_LISTVALORES.f_get_LSTGRADOMINUSVALIA';
   BEGIN
      cur := f_detvalores (883, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsitfam;

   /*************************************************************************
      Recupera el nombre del tomador de la p??liza seg??n el orden
      param in sseguro   : c??digo seguro
      param in nordtom   : orden tomador
      param out mensajes : mesajes de error
      return             : nombre tomador
   *************************************************************************/
   -- Bug 8745 - 27/02/2009 - RSC - Adaptaci??n iAxis a productos colectivos con certificados
   FUNCTION f_get_nametomadorcero (psseguro IN NUMBER, nordtom IN NUMBER)
      RETURN VARCHAR2
   IS
      vf         VARCHAR2 (200) := NULL;
      nerr       NUMBER;
      cidioma    NUMBER         := pac_md_common.f_get_cxtidioma;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'sseguro= ' || psseguro;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_nametomadorcero';
      mensajes   t_iax_mensajes := NULL;
      -- RSC 3/03/2009
      vsseguro   NUMBER;
   BEGIN
      SELECT s1.sseguro
        INTO vsseguro
        FROM seguros s1, seguros s2
       WHERE s2.sseguro = psseguro
         AND s1.npoliza = s2.npoliza
         AND s1.ncertif = 0;

      nerr := f_tomador (vsseguro, nordtom, vf, cidioma);
      RETURN vf;
   EXCEPTION
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
         RETURN vf;
   END f_get_nametomadorcero;

--------------------------------------------------------------------------------------

   /*************************************************************************
      Recupera los perfiles de inversi??n de un producto.
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   -- Bug 9031 - 11/03/2009 - RSC - An??lisis adaptaci??n productos indexados
   FUNCTION f_get_perfiles (psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := 'psproduc= ' || psproduc;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_perfiles';
      vsquery    VARCHAR2 (2000);
   BEGIN
      vsquery :=
            'SELECT DISTINCT m.CMODINV, c.TMODINV
        FROM MODELOSINVERSION m, codimodelosinversion c, productos p
        WHERE p.sproduc = '
         || psproduc
         || 'AND m.cramo = p.cramo
          AND m.cmodali = p.cmodali
          AND m.ctipseg = p.ctipseg
          AND m.ccolect = p.ccolect
            AND m.cramo = c.cramo
            AND m.cmodali = c.cmodali
            AND m.ctipseg = c.ctipseg
            AND m.ccolect = c.ccolect
            and m.CMODINV = c.CMODINV
            and c.cidioma = '
         || pac_md_common.f_get_cxtidioma
         || ' ORDER BY m.cmodinv';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_perfiles;

      /*************************************************************************
      Recupera los perfiles de inversi??n de un producto.
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   -- Bug 9031 - 11/03/2009 - RSC - An??lisis adaptaci??n productos indexados
   FUNCTION f_get_fondosinversion (
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := 'pcempres= ' || pcempres;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_fondosinversion';
      vsquery    VARCHAR2 (2000);
   BEGIN
      IF pcempres IS NULL
      THEN
         vsquery :=
            'select ccodfon, tfonabv
              from fondos
              where ffin is null';
      ELSE
         vsquery :=
               'select ccodfon, tfonabv
              from fondos
              where cempres = '
            || pcempres
            || '   and ffin is null';
      END IF;

      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_fondosinversion;

   /*************************************************************************
        Recupera las actividades profesionales
        param out mensajes : mensajes de error
        return : ref cursor

           30/03/2009   XPL                 Sinistres.  Bug: 9020
   *************************************************************************/
   FUNCTION f_get_lstcactprof (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_lstcactprof';
      terror     VARCHAR2 (200) := 'Error recuperar lstcactprof';
   BEGIN
      cur :=
         f_opencursor
            (   'select cactpro, tactpro
                           from activiprof
                           where  cidioma = '
             || pac_md_common.f_get_cxtidioma
             || ' order by TACTPRO',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcactprof;

   /*************************************************************************
      Recupera c??digo del map y su descripci??n
      param out mensajes : mensajes de error
      return             : ref cursor

          06/05/2009   ICV                 Maps.  Bug: 9940
   *************************************************************************/
   FUNCTION f_get_ficheros (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_ficheros';
      terror     VARCHAR2 (200)  := 'Error recuperar ficheros';
      vsquery    VARCHAR2 (2000);
   BEGIN
      vsquery :=
            'SELECT   cmapead codigo, cmapead || ''.-'' || tdesmap ttitulo '
         || 'FROM map_cabecera mc '
         || 'WHERE (ttipotrat IN(''G'', ''D'') '
         || 'AND(cmanten = 1 '
         || 'OR ''DESARROLLO'' IN(SELECT crolmen '
         || 'FROM dsiusurol '
         || 'WHERE cusuari = f_user)) '
         -- BUG 21569 - 08/03/2012 - JMP -
         || 'AND NOT EXISTS(SELECT ''1'' '
         || 'FROM cfg_user '
         || 'WHERE cempres = pac_md_common.f_get_cxtempresa '
         || 'AND cuser = f_user '
         || 'AND ccfgmap IS NOT NULL)) '
         || 'OR cmapead IN(SELECT cm.cmapead '
         || 'FROM cfg_user cu, cfg_map cm '
         || 'WHERE cu.cempres = pac_md_common.f_get_cxtempresa '
         || 'AND cu.cuser = f_user '
         || 'AND cm.cempres = cu.cempres '
         || 'AND cm.ccfgmap = cu.ccfgmap) '
         || 'ORDER BY LPAD(cmapead, 5, ''0'')';
      -- FIN BUG 21569 - 08/03/2012 - JMP -
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ficheros;

   /*************************************************************************
     Recupera c??digo del motivo de rehabilitaci??n y la descripci??n del motivo.
     param in  psproduc : Identificador del producto.
     param out mensajes : mensajes de error
     return             : ref cursor

         11/05/2009   ICV                 Maps.  Bug: 9784
   *************************************************************************/
   FUNCTION f_get_motivosrehab (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_motivosrehab';
      terror     VARCHAR2 (200)  := 'Error recuperando motivosrehab';
      vsquery    VARCHAR2 (2000);
   BEGIN
      IF psproduc IS NULL
      THEN
         vsquery :=
               'SELECT cmotmov,tmotmov FROM motmovseg WHERE cidioma='
            || pac_md_common.f_get_cxtidioma
            || ' AND cmotmov IN (SELECT cmotmov FROM codimotmov WHERE cactivo = 1 AND cgesmov = 0 AND cmovseg = 4)'
            || ' ORDER BY tmotmov';
      ELSE
         vsquery :=
               'SELECT cmotmov,tmotmov FROM motmovseg WHERE cidioma='
            || pac_md_common.f_get_cxtidioma
            || ' AND cmotmov IN (SELECT cmotmov FROM codimotmov WHERE cactivo = 1 AND cgesmov = 0 AND cmovseg = 4)'
            || ' AND cmotmov in (select cmotmov from prodmotmov where sproduc ='
            || psproduc
            || ')'
            || ' ORDER BY tmotmov';
      END IF;

      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_motivosrehab;

   /*************************************************************************
      Recupera la Lista de distintas agrupacions por producto pasandole la empresa, devuelve un ref cursor
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- XPL -Bug10317-29/06/2009- Se a??ade funci??n
   FUNCTION f_get_agrupaciones (
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_agrupaciones';
      terror     VARCHAR2 (200) := 'Error recuperar agrupacions';
   BEGIN
      cur :=
         f_opencursor
            (   ' SELECT distinct a.cagrpro, tagrpro
                    FROM    AGRUPAPRO a, productos p
                    WHERE cidioma = '
             || pac_md_common.f_get_cxtidioma
             || '   and p.cagrpro = a.cagrpro
                    and p.cactivo = 1
                    and p.cramo in (SELECT CRAMO FROM CODIRAM c WHERE c.CEMPRES = '
             || pcempres
             || ')
                    ORDER BY a.cagrpro',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agrupaciones;

   /*************************************************************************
      Recupera la Lista de distintos ramos filtrado por agrupacion, devuelve un ref cursor
      param in pcempres : codigo de empresa
      param in pcagrupacion : codigo de agrupacion
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- XPL -Bug10317-29/06/2009- Se a??ade funci??n
   FUNCTION f_get_ramosagrupacion (
      pcempres       IN       NUMBER,
      pcagrupacion   IN       NUMBER,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_ramosagrupacion';
      terror     VARCHAR2 (200) := 'Error recuperar ramosagrupacion';
   BEGIN
      cur :=
         f_opencursor
            (   'select distinct r.cramo, r.tramo from codiram c, ramos r, productos p '
             || 'where r.cidioma = '
             || pac_md_common.f_get_cxtidioma
             || ' and r.cramo = p.cramo'
             || ' and c.CRAMO = r.CRAMO'
             || ' and c.CEMPRES = '
             || pcempres
             || ' and p.CAGRPRO = '
             || pcagrupacion
             || ' and PAC_PRODUCTOS.f_prodagente (p.sproduc,'
             || pac_md_common.f_get_cxtagente
             || ',2)=1'
             || ' order by r.tramo',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ramosagrupacion;

   /*************************************************************************
      Recupera la Lista del codigo de concepto y descripci??n de las cuentas tecnicas
      param out : mensajes de error
      return    : ref cursor
       -- XPL -Bug10671-09/07/2009- Se a??ade funci??n
   *************************************************************************/
   FUNCTION f_get_lstconcep_cta (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstconcep_cta';
      terror     VARCHAR2 (200) := 'Error recuperar conceptes';
   BEGIN
      cur :=
         f_opencursor
            (   'select c.cconcta, d.tcconcta
                 from desctactes d, codctactes c '
             || 'where d.cidioma = '
             || pac_md_common.f_get_cxtidioma
             || '
                 and d.cconcta = c.cconcta and c.cmanual = 0',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstconcep_cta;

   /*************************************************************************
      Recupera las posibles ubicaciones (debe/haber) d??nde imputar el importe del asiento
      del concepto recibido por par??metro de la cuenta y su descripci??n.
      param in pcconcepto: concepto
      param out mensajes : mensajes de error
      return    : ref cursor
       -- XPL -Bug10671-09/07/2009- Se a??ade funci??n
   *************************************************************************/
   FUNCTION f_get_lsttipo_cta (
      pcconcepto   IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur          sys_refcursor;
      vpasexec     NUMBER (8)     := 1;
      vparam       VARCHAR2 (1)   := NULL;
      vobject      VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstconcep_cta';
      terror       VARCHAR2 (200) := 'Error recuperar debe / haber';
      vtipconcta   NUMBER;
   BEGIN
      SELECT c.ctipconcta
        INTO vtipconcta
        FROM codctactes c
       WHERE cconcta = pcconcepto;

      cur :=
         f_opencursor
            (   ' select d.catribu , d.tatribu
        from detvalores d
        where cvalor = 19
          and d.cidioma = '
             || pac_md_common.f_get_cxtidioma
             || '
          and d.catribu = decode ('
             || vtipconcta
             || ', 3, d.catribu,'
             || vtipconcta
             || ')',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipo_cta;

   /*************************************************************************
      Recupera los procesos de liquidaci??n pendientes de cerrar seg??n la empresa seleccionada
      param in pcempres: codi empresa
      param out mensajes : mensajes de error
      return    : ref cursor
       -- XPL -Bug10672-15/07/2009- Se a??ade funci??n
   *************************************************************************/
   FUNCTION f_get_liqspendientes (
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_iax_LISTVALORES.f_get_liqspendientes';
      terror     VARCHAR2 (200) := 'Error recuperar debe / haber';
   BEGIN
      cur :=
         f_opencursor
            (   'select distinct (SMOVREC ||'' - ''|| to_char(fliquid,''YYYYMMDD'')) LIQPENDIENTES,  SMOVREC, FLIQUID
FROM LIQMOVREC
WHERE CESTLIQ = 0
AND CEMPRES = NVL('
             || pcempres
             || ',CEMPRES)
ORDER BY FLIQUID DESC',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_liqspendientes;

     /*BUG 10487 - 03/07/2009 - ETM - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
        Obtine los posibles estados del cuadro facultativo
         param out mensajes: mensajes de error
        return            : ref cursor
     *************************************************************************/
   FUNCTION f_get_lstestado_fac (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstestado_fac';
      terror     VARCHAR2 (200)
         := 'Error recuperar los estados del cuadro facultativo y su descripci??n ';
   BEGIN
      cur := f_detvalores (118, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestado_fac;

   /*FIN BUG 10487 - 03/07/2009 - ETM */

   /*************************************************************************
    FUNCTION f_get_lstccobban_rec
        Obtine los posibles cobradores bancarios del recibo
        param in pnrecibo : N. recibo
        param out mensajes: mensajes de error
        return            : ref cursor
    --BUG 10529 - 04/09/2009 - JTS
   *************************************************************************/
   FUNCTION f_get_lstccobban_rec (
      pnrecibo   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (200)  := 'pnrecibo: ' || pnrecibo;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_lstccobban_rec';
      vselect    VARCHAR2 (1000);
      verror     NUMBER;

      FUNCTION f_cobrador_rec (pnrecibo IN NUMBER, pselect OUT VARCHAR2)
         RETURN NUMBER
      IS
         v_cempres   NUMBER;
         v_ccobban   NUMBER;
         v_count     NUMBER;
         v_out       NUMBER;
         v_ret       NUMBER;
         v_paso      NUMBER := 0;

         CURSOR v_cur
         IS
            SELECT cramo, cmodali, ctipseg, ccolect, cagente, cbancar,
                   ctipban
              FROM seguros
             WHERE sseguro = (SELECT sseguro
                                FROM recibos
                               WHERE nrecibo = pnrecibo);
      BEGIN
         SELECT ccobban, cempres
           INTO v_ccobban, v_cempres
           FROM recibos
          WHERE nrecibo = pnrecibo;

         v_paso := 1;

         SELECT COUNT (*)
           INTO v_count
           FROM cobbancario
          WHERE cempres = v_cempres AND ccobban = v_ccobban AND cbaja <> 1;

         v_paso := 2;

         IF v_count > 0
         THEN
            v_paso := 3;
            pselect :=
                  'SELECT ccobban, ncuenta FROM cobbancario WHERE ccobban = '
               || v_ccobban
               || ' ORDER BY ccobban';
         ELSE
            v_paso := 4;

            FOR i IN v_cur
            LOOP
               v_ret :=
                  f_buscacobban (i.cramo,
                                 i.cmodali,
                                 i.ctipseg,
                                 i.ccolect,
                                 i.cagente,
                                 i.cbancar,
                                 i.ctipban,
                                 v_out
                                );
            END LOOP;

            v_paso := 5;

            IF v_out = 0 AND v_ret IS NOT NULL
            THEN
               pselect :=
                     'SELECT ccobban, ncuenta FROM cobbancario WHERE ccobban = '
                  || v_ret
                  || ' ORDER BY ccobban';
            ELSE
               pselect :=
                     'SELECT ccobban, ncuenta FROM cobbancario WHERE cempres = '
                  || v_cempres
                  || ' AND cbaja <> 1 ORDER BY ccobban';
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'f_cobrador_rec',
                         v_paso,
                         SQLCODE,
                         SQLERRM
                        );
            pselect :=
                  'SELECT ccobban, ncuenta FROM cobbancario WHERE cempres = '
               || ' pac_md_common.f_get_cxtempresa AND cbaja <> 1 ORDER BY ccobban';
            RETURN 1;
      END f_cobrador_rec;
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      verror := f_cobrador_rec (pnrecibo, vselect);
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstccobban_rec;

   /*************************************************************************
      Recupera los procesos de cierres de tipo 17 seg??n la empresa seleccionada
      param in pcempres: codi empresa
      param out mensajes : mensajes de error
      return    : ref cursor
       -- JGM -Bug10684-14/08/2009- Se a??ade funci??n
   *************************************************************************/
   FUNCTION f_get_cieres_tipo17 (
      pcempres   IN       NUMBER,
      pagente    IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur            sys_refcursor;
      vpasexec       NUMBER (8)     := 1;
      vparam         VARCHAR2 (1)   := NULL;
      vobject        VARCHAR2 (200)
                                 := 'PAC_iax_LISTVALORES.f_get_cieres_tipo17';
      terror         VARCHAR2 (200);
      v_hay_agente   VARCHAR2 (500) := '';
   BEGIN
      IF pagente IS NOT NULL
      THEN
         v_hay_agente := ' AND l.CAGENTE = ' || TO_CHAR (pagente) || ' ';
      END IF;

      cur :=
         f_opencursor
            (   'select distinct(C.SPROCES),to_char(C.FPERINI,''DD/MM/YYYY'') ||'' - ''|| to_char(C.FPERFIN,''DD/MM/YYYY'') PERIODO
              FROM CIERRES C,LIQMOVREC l
              WHERE C.CTIPO = 17 AND l.SPROCES = C.SPROCES AND
C.CEMPRES = NVL('
             || pcempres
             || ',C.CEMPRES) '
             || v_hay_agente
             || 'ORDER BY 1 DESC',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cieres_tipo17;

   /*************************************************************************
      Recupera la lista con los estados de gesti??n
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_gstcestgest (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_GstCestgest';
      terror     VARCHAR2 (200) := 'Error recuperar motivos de retencion';
   BEGIN
      cur :=
         f_opencursor
            (   'SELECT catribu,tatribu
                              FROM DETVALORES
                             WHERE cvalor = 800016
                               AND cidioma = '
             || pac_md_common.f_get_cxtidioma,
             mensajes
            );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_gstcestgest;

      /*BUG 10487 - 07/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
        Obtine las diferentes descripciones de comsisiones de contratos
         param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcomis_rea (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstcomis_rea';
      terror     VARCHAR2 (200) := 'Error recuperar comis_rea';
   BEGIN
      cur :=
         f_opencursor
            (   'select ccomrea, tdescri from descomisioncontra d where CIDIOMA = '
             || pac_md_common.f_get_cxtidioma
             || ' order by ccomrea',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcomis_rea;

   /*************************************************************************
        Obtine las diferentes descripciones de los intereses
         param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstinteres_rea (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstinteres_rea';
      terror     VARCHAR2 (200) := 'Error recuperar comis_rea';
   BEGIN
      cur :=
         f_opencursor ('select * from desinteresrea order by cintres',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstinteres_rea;

   /*FIN BUG 10487 - 07/10/2009 - ICV */

   /*************************************************************************
      Recupera la situaci??n de la p??liza (con estado e incidencias)
      param in sseguro   : c??digo seguro
      return             : situaci??n
      -- BUG 10831.i.
   *************************************************************************/
   FUNCTION f_get_sit_pol_detalle (psseguro IN NUMBER)
      RETURN VARCHAR2
   IS
      vf         VARCHAR2 (200) := NULL;
      nf         NUMBER;
      mensajes   t_iax_mensajes;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'psseguro= ' || psseguro;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Sit_Pol_Detalle';
   --
   BEGIN
      -- ctipo = 2 => Retorna Situaci?? i Estat.
      vf :=
         pac_seguros.ff_situacion_poliza (psseguro,
                                          pac_md_common.f_get_cxtidioma,
                                          2
                                         );
      RETURN vf;
   EXCEPTION
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
         RETURN vf;
   END f_get_sit_pol_detalle;

-- BUG 10831.f.

   -- ini Bug 0012679 - 18/02/2010 - JMF
   /*************************************************************************
          Recupera los Estados de recibo mv
          (Detvalores.cvalor=1)
          param out mensajes : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstestadorecibo_mv (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_LISTVALORES.F_get_LstEstadoRecibo_mv';
      terror     VARCHAR2 (200) := 'Error recuperar estados recibo';
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (383, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END;

-- fin Bug 0012679 - 18/02/2010 - JMF

   /*************************************************************************
    FUNCTION F_GET_AGRPRODUCTOS
        param in pagrupacion
        param in pcempres
        param out mensajes: mensajes de error
        return            : ref cursor
    --BUG 13477 - 22/03/2010 - JTS
   *************************************************************************/
   FUNCTION f_get_agrproductos (
      pagrupacion   IN       NUMBER,
      pcempres      IN       NUMBER,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200)
               := 'pagrupacion: ' || pagrupacion || ' pcempres: ' || pcempres;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_GET_AGRPRODUCTOs';
   BEGIN
      IF pagrupacion IS NULL OR pcempres IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur :=
         f_opencursor (   'select p.sproduc, t.ttitulo '
                       || ' from titulopro t, productos p, codiram cr '
                       || ' where t.CRAMO = p.CRAMO and  '
                       || '       t.CCOLECT=p.CCOLECT and '
                       || '       t.CTIPSEG =p.CTIPSEG and '
                       || '       t.CMODALI = p.CMODALI and '
                       || ' cr.cramo = p.cramo and '
                       || ' p.cagrpro = '
                       || pagrupacion
                       || ' and cr.cempres = '
                       || pcempres
                       || '       t.cidioma = '
                       || pac_md_common.f_get_cxtidioma ()
                       || ' and'
                       || '       PAC_PRODUCTOS.f_prodagente (p.sproduc,'
                       || pac_md_common.f_get_cxtagente
                       || ',2)=1'
                       || ' order by ttitulo',
                       mensajes
                      );
      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_agrproductos;

   /*************************************************************************
    FUNCTION F_GET_ESTPAGOREN
        param in pcestado
        param out mensajes: mensajes de error
        return            : ref cursor
    --BUG 13477 - 22/03/2010 - JTS
   *************************************************************************/
   FUNCTION f_get_estpagosren (
      pcestado   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200) := 'pcestado: ' || pcestado;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_GET_ESTPAGOSREN';
   BEGIN
      IF pcestado IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur :=
         f_opencursor (   'SELECT dv.catribu, dv.tatribu '
                       || ' FROM detvalores dv, cfg_valores_posibles cvp '
                       || ' WHERE dv.cvalor = 230 '
                       || ' AND cvp.cvalor_dest = dv.catribu '
                       || ' AND dv.cidioma = pac_md_common.f_get_cxtidioma '
                       || ' AND cvp.ctabla = ''MOVPAGREN'' '
                       || ' AND cvp.ccampo = ''CESTREC'' '
                       || ' AND cvp.cvalor_act = '
                       || pcestado
                       || ' order by 1',
                       mensajes
                      );
      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_estpagosren;

   /*************************************************************************
        Obtine las garant??as dependientes
        param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   -- Bug 11735 - RSC - 10/05/2010 - APR - suplemento de modificaci??n de capital /prima
   FUNCTION f_get_garanprodep (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_garanprodep';
      terror     VARCHAR2 (200) := 'Error recuperar garanpro dep';
   BEGIN
      cur :=
         f_opencursor
            (   'SELECT cgarant
                           FROM garanpro
                           WHERE cgardep = '
             || pcgarant
             || ' AND sproduc = '
             || psproduc
             || ' AND cactivi = '
             || NVL (pcactivi, 0),
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_garanprodep;

-- Fin bug 11735

   /*************************************************************************
        Funci??n que devuelve conceptos de una garantia
        param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   -- Bug 14607: - XPL - 27/05/2010 -  AGA004 - Conceptos de pago a nivel de detalle del pago de un siniestro
   FUNCTION f_get_concepgaran (
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_concepgaran';
      vquery     VARCHAR2 (500);
   BEGIN
      vquery :=
            'SELECT sc.cgarant,sd.cconpag, tconpag
                           FROM SIN_CODCONPAG sc, SIN_DESCONPAG sd
                           WHERE sc.cgarant = sd.cgarant
                           and sc.cconpag = sd.cconpag
                           and sd.cidioma = '
         || pac_md_common.f_get_cxtidioma;

      IF pcgarant IS NOT NULL
      THEN
         vquery := vquery || ' and sc.cgarant = ' || pcgarant;
      END IF;

      cur := f_opencursor (vquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_concepgaran;

   /*************************************************************************
        Obtine los diferentes ramos de la DGS
         param out mensajes: mensajes de error
        return            : ref cursor

        Bug 15148 - 18/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lstramosdgs (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstramosdgs';
      terror     VARCHAR2 (200) := 'Error recuperar ramos dgs';
   BEGIN
      cur :=
         f_opencursor
                (   'select cramdgs,tramdgs from desramodgs where cidioma ='
                 || pac_md_common.f_get_cxtidioma,
                 mensajes
                );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstramosdgs;

   /*************************************************************************
        Obtine las diferentes tablas de mortalidad
         param out mensajes: mensajes de error
        return            : ref cursor

        Bug 15148 - 18/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lsttmortalidad (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lsttmortalidad';
      terror     VARCHAR2 (200) := 'Error recuperar tablas mortalidad';
   BEGIN
      cur :=
         f_opencursor
                  ('select ctabla,ttabla from codmortalidad order by ctabla',
                   mensajes
                  );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttmortalidad;

   /*************************************************************************
        Recupera los elementos
        param in  pcutili  : tipo de utilidad
        param out mensajes : mensajes de error
        return : ref cursor

        Bug 15149 - 21/06/2010 - AMC
    *************************************************************************/
   FUNCTION f_get_lstcodcampo (
      pcutili    IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'pcutili=' || pcutili;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstcodcampo';
      terror     VARCHAR2 (200) := 'Error recuperar lstcodcampo';
   BEGIN
      cur :=
         pac_md_listvalores.f_opencursor (   'SELECT ccampo, tcampo'
                                          || ' FROM codcampo'
                                          || ' WHERE cutili ='
                                          || pcutili
                                          || ' ORDER BY ccampo',
                                          mensajes
                                         );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcodcampo;

   /*************************************************************************
      Recupera la lista de bancos seg??n los criterios
      param in cbanco : C??digo del banco
      param in tbanco : Descripci??n del banco
   *************************************************************************/
   FUNCTION f_get_lstbancos (
      pcbanco    IN       NUMBER,
      ptbanco    IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      condicion      VARCHAR2 (1000);
      cur            sys_refcursor;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (1000)
                           := 'cbanco= ' || pcbanco || ' tbanco= ' || ptbanco;
      vobject        VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_LstBancos';
      no_hay_datos   EXCEPTION;
      vbanco         NUMBER;
      vtbanco        VARCHAR2 (200);
      vselect        VARCHAR2 (2000);
   BEGIN
      IF pcbanco IS NOT NULL
      THEN
         condicion := ' b.cbanco = ' || pcbanco;
      END IF;

      IF ptbanco IS NOT NULL
      THEN
         condicion :=
            condicion || ' upper(b.tbanco) like ''%' || UPPER (ptbanco)
            || '%''';
      END IF;

      vselect := 'select b.cbanco, b.tbanco from bancos b';

      IF condicion IS NOT NULL
      THEN
         vselect := vselect || ' where ' || condicion;
      END IF;

      -- Ini Bug 042968- VCG-02/06/2016
      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'ORDER_BANCOS'
                                            ),
              0
             ) = 1
      THEN
         vselect := vselect || ' order by b.tbanco ';
      ELSE
         vselect := vselect || ' order by b.cbanco ';
      END IF;

      ---Fin Bug 042968- VCG-02/06/2016
      cur := f_opencursor (vselect, mensajes);

      IF cur%FOUND
      THEN
         IF cur%ISOPEN
         THEN
            FETCH cur
             INTO vbanco, vtbanco;

            IF cur%NOTFOUND
            THEN
               RAISE no_hay_datos;
            END IF;

            CLOSE cur;
         END IF;
      END IF;

      -- Lo volvemos a abrir ya que el FETCH lo deja sin las filas ya consultadas
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN no_hay_datos
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000254);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstbancos;

   /*************************************************************************
        Recupera la lista de bancos según los criterios
        param out mensajes : mensajes de error
        return             : ref cursor
        Autor: JOHN BENITEZ ALEMAN
        FECHA: ABRIL 2015 - FACTORY COLOMBIA
     *************************************************************************/
   FUNCTION f_get_bancos (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      condicion      VARCHAR2 (1000);
      cur            sys_refcursor;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (1000) := '';
      vobject        VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_Bancos';
      no_hay_datos   EXCEPTION;
      vbanco         NUMBER;
      vtbanco        VARCHAR2 (200);
      vselect        VARCHAR2 (2000);
   BEGIN
      vselect := 'select b.cbanco, b.tbanco from bancos b';
      vselect := vselect || ' order by b.tbanco ';
      cur := f_opencursor (vselect, mensajes);

      IF cur%FOUND
      THEN
         IF cur%ISOPEN
         THEN
            FETCH cur
             INTO vbanco, vtbanco;

            IF cur%NOTFOUND
            THEN
               RAISE no_hay_datos;
            END IF;

            CLOSE cur;
         END IF;
      END IF;

      -- Lo volvemos a abrir ya que el FETCH lo deja sin las filas ya consultadas
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN no_hay_datos
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000254);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_bancos;

   /*************************************************************************

      Recupera los elementos
      param out mensajes : mensajes de error

      return : ref cursor
   *************************************************************************/
   FUNCTION f_get_codreglas (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100);
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_codreglas';
      terror     VARCHAR2 (200) := 'Error recuperar codigos de reglas';
   BEGIN
      cur :=
         pac_md_listvalores.f_opencursor (   'SELECT cregla, tregla'
                                          || ' FROM codreglasseg'
                                          || ' WHERE 1 = 1'
                                          || ' ORDER BY cregla',
                                          mensajes
                                         );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_codreglas;

   /*************************************************************************
      Recupera los agentes
      param in pctipage  : tipo de agente
      param in pcidioma  : idioma
      param out mensajes : mensajes de error
      param in pcpadre   : codigo de agente padre

      return : ref cursor

      Bug 0016529 - 23/11/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_agentestipo (
      pctipage   IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes,
      pcpadre    IN       NUMBER DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      cur             sys_refcursor;
      vpasexec        NUMBER (8)      := 1;
      vparam          VARCHAR2 (100)
                        := 'pctipage:' || pctipage || ', pcpadre:' || pcpadre;
      vobject         VARCHAR2 (200)
                                    := 'PAC_MD_LISTVALORES.f_get_agentestipo';
      terror          VARCHAR2 (200)  := 'Error recuperar agentes';
      v_cond_cpadre   VARCHAR2 (100);
      vwherevista     VARCHAR2 (2000);
      vctipage        NUMBER;
   BEGIN
      IF pctipage IS NULL OR pcidioma IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT ctipage
        INTO vctipage
        FROM agentes
       WHERE cagente = pac_md_common.f_get_cxtagente;

      --BUG19533 - JTS - 29/009/2011
      IF pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                        'FILTRO_AGE'
                                       ) = 1
      THEN
         vwherevista :=
               ' AND ag.cagente in (SELECT a.cagente '
            || ' FROM (SELECT LEVEL nivel, cagente '
            || ' FROM redcomercial r '
            || ' WHERE '
            || ' r.fmovfin is null '
            || ' START WITH '
            || '  r.ctipage = '
            || vctipage
            || ' AND r.cempres = '
            || pac_md_common.f_get_cxtempresa
            || ' AND R.CAGENTE = '
            || pac_md_common.f_get_cxtagente
            || ' and r.fmovfin is null '
            || ' CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || ' AND PRIOR r.cempres =(r.cempres + 0) '
            || ' and r.fmovfin is null '
            || ' AND r.cagente >= 0) rr, '
            || ' agentes a '
            || ' where rr.cagente = a.cagente  ) ';
      END IF;

      --Fi bug19533

      /*  IF pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'FILTRO_AGE') = 1 THEN
          vwherevista := ' AND a.cagente in (SELECT a.cagente '
                         || ' FROM (SELECT LEVEL nivel, cagente ' || ' FROM redcomercial r '
                         || ' WHERE ' || ' r.fmovfin is null ' || ' START WITH '
                         || '  r.cempres =  '|| pac_md_common.f_get_cxtempresa || ' AND R.CAGENTE = NVL ('
                         || NVL(TO_CHAR(pcagente), 'null')
                         || ','||pac_md_common.f_get_cxtagente ||') and r.fmovfin is null '
                         || ' CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
                         || ' AND PRIOR r.cempres =(r.cempres + 0) '
                         || ' and r.fmovfin is null ' || ' AND r.cagente >= 0) rr, '
                         || ' agentes a ' || ' where rr.cagente = a.cagente ) ';
       END IF;*/

      -- BUG 19197 - 22/09/2011 - JMP
      IF pcpadre IS NOT NULL
      THEN
         v_cond_cpadre := ' AND rc.cpadre = ' || pcpadre;
      END IF;

      -- FIN BUG 19197 - 22/09/2011 - JMP
      cur :=
         pac_md_listvalores.f_opencursor
            (   'SELECT ag.cagente,'
             || ' pac_redcomercial.ff_desagente(ag.cagente,'
             || pcidioma
             || ',pac_md_common.F_GET_CXTIDIOMA) TAGENTE'
             || ' FROM redcomercial rc, agentes ag, agentes_agente_pol ap'
             || ' WHERE rc.cagente = ag.cagente AND rc.cempres = ap.cempres AND rc.cagente = ap.cagente'
             || ' AND rc.ctipage ='
             || pctipage
             || ' AND rc.cempres ='
             || pac_md_common.f_get_cxtempresa
             || ' AND rc.fmovfin is null '
             || vwherevista
             || v_cond_cpadre
             || ' order by rc.cagente ASC ',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agentestipo;

   /*************************************************************************
       Recupera los agentes de tipo 2 y 3
       param in pctipage  : tipo de agente
       param in pcidioma  : idioma
       param in pcpadre   : codigo de agente padre
       param out mensajes : mensajes de error

       return : ref cursor

       12/07/2019 - UST
    *************************************************************************/
   FUNCTION f_get_agentestipos (
      pctipage   IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes,
      pcpadre    IN       NUMBER DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      cur             sys_refcursor;
      vpasexec        NUMBER (8)      := 1;
      vparam          VARCHAR2 (100)
                        := 'pctipage:' || pctipage || ', pcpadre:' || pcpadre;
      vobject         VARCHAR2 (200)
                                   := 'PAC_MD_LISTVALORES.f_get_agentestipos';
      terror          VARCHAR2 (200)  := 'Error recuperar agentes';
      v_cond_cpadre   VARCHAR2 (100);
      vwherevista     VARCHAR2 (2000);
      vctipage        NUMBER;
   BEGIN
      IF pctipage IS NULL OR pcidioma IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT ctipage
        INTO vctipage
        FROM agentes
       WHERE cagente = pac_md_common.f_get_cxtagente;

      --BUG19533 - JTS - 29/009/2011
      IF pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                        'FILTRO_AGE'
                                       ) = 1
      THEN
         vwherevista :=
               ' AND ag.cagente in (SELECT a.cagente '
            || ' FROM (SELECT LEVEL nivel, cagente '
            || ' FROM redcomercial r '
            || ' WHERE '
            || ' r.fmovfin is null '
            || ' START WITH '
            || '  r.ctipage in (2,3) AND r.cempres = '
            || pac_md_common.f_get_cxtempresa
            || ' AND R.CAGENTE = '
            || pac_md_common.f_get_cxtagente
            || ' and r.fmovfin is null '
            || ' CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || ' AND PRIOR r.cempres =(r.cempres + 0) '
            || ' and r.fmovfin is null '
            || ' AND r.cagente >= 0) rr, '
            || ' agentes a '
            || ' where rr.cagente = a.cagente  ) ';
      END IF;

      --Fi bug19533

      /*  IF pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'FILTRO_AGE') = 1 THEN
          vwherevista := ' AND a.cagente in (SELECT a.cagente '
                         || ' FROM (SELECT LEVEL nivel, cagente ' || ' FROM redcomercial r '
                         || ' WHERE ' || ' r.fmovfin is null ' || ' START WITH '
                         || '  r.cempres =  '|| pac_md_common.f_get_cxtempresa || ' AND R.CAGENTE = NVL ('
                         || NVL(TO_CHAR(pcagente), 'null')
                         || ','||pac_md_common.f_get_cxtagente ||') and r.fmovfin is null '
                         || ' CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
                         || ' AND PRIOR r.cempres =(r.cempres + 0) '
                         || ' and r.fmovfin is null ' || ' AND r.cagente >= 0) rr, '
                         || ' agentes a ' || ' where rr.cagente = a.cagente ) ';
       END IF;*/

      -- BUG 19197 - 22/09/2011 - JMP
      IF pcpadre IS NOT NULL
      THEN
         v_cond_cpadre := ' AND rc.cpadre = ' || pcpadre;
      END IF;

      -- FIN BUG 19197 - 22/09/2011 - JMP
      cur :=
         pac_md_listvalores.f_opencursor
            (   'SELECT ag.cagente,'
             || ' pac_redcomercial.ff_desagente(ag.cagente,'
             || pcidioma
             || ',pac_md_common.F_GET_CXTIDIOMA) TAGENTE'
             || ' FROM redcomercial rc, agentes ag, agentes_agente_pol ap'
             || ' WHERE rc.cagente = ag.cagente AND rc.cempres = ap.cempres AND rc.cagente = ap.cagente'
             || ' AND rc.ctipage in (2,3) AND rc.cempres ='
             || pac_md_common.f_get_cxtempresa
             || ' AND rc.fmovfin is null '
             || vwherevista
             || v_cond_cpadre
             || ' order by rc.cagente ASC ',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agentestipos;

   /*************************************************************************
      Recupera los negocios
      param in pcnegocio : numero negocio
      param in pcidioma  : idioma
      param in pcempresa : codigo de empresa
      param in psproduc  : codigo de producto
      param out mensajes : mensajes de error

      return : ref cursor

      Bug 0016529 - 23/11/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_negocio (
      pcnegocio   IN       NUMBER,
      pcidioma    IN       NUMBER,
      pcempresa   IN       NUMBER,
      psproduc    IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'pcnegocio:' || pcnegocio;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_negocio';
      terror     VARCHAR2 (200) := 'Error recuperar negocio';
   BEGIN
      IF pcnegocio IS NULL OR pcidioma IS NULL OR pcempresa IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pcnegocio = 2
      THEN
         cur := f_detvalores (283, mensajes);
      ELSIF pcnegocio = 3
      THEN
         cur :=
            pac_md_listvalores.f_opencursor
                                (   'select r.cramo catribu,r.tramo tatribu'
                                 || ' from ramos r, codiram c'
                                 || ' where r.cidioma ='
                                 || pcidioma
                                 || ' and r.cramo = c.cramo'
                                 || ' and c.cempres ='
                                 || pcempresa,
                                 mensajes
                                );
      ELSIF pcnegocio = 4
      THEN
         -- Bug 0016529 - 28/12/2010 - JMF
         cur :=
            pac_md_listvalores.f_opencursor
                            (   'select p.sproduc catribu,t.ttitulo tatribu'
                             || ' from titulopro t,productos p, codiram c'
                             || ' where  c.cempres ='
                             || pcempresa
                             || ' and c.cramo = p.cramo'
                             || ' and t.cramo = c.cramo'
                             || ' and t.cidioma ='
                             || pcidioma
                             || ' and t.ccolect = p.ccolect'
                             || ' and t.cmodali = p.cmodali'
                             || ' and t.ctipseg = p.ctipseg'
                             || ' order by t.ttitulo',
                             mensajes
                            );
      ELSIF pcnegocio = 5
      THEN
         IF psproduc IS NULL
         THEN
            RAISE e_param_error;
         END IF;

         cur :=
            pac_md_listvalores.f_opencursor
                (   ' select s.cactivi catribu,s.ttitulo tatribu'
                 || ' from activisegu s,activiprod p, codiram c,productos pr'
                 || ' where  s.cidioma ='
                 || pcidioma
                 || ' and s.cactivi = p.cactivi'
                 || ' and s.cramo = p.cramo'
                 || ' and c.cempres ='
                 || pcempresa
                 || ' and c.cramo = s.cramo'
                 || ' and pr.cramo = c.cramo'
                 || ' and pr.ctipseg = p.ctipseg'
                 || ' and pr.ccolect = p.ccolect'
                 || ' and pr.cmodali = p.cmodali'
                 || ' and pr.cramo = p.cramo'
                 || ' and pr.sproduc ='
                 || psproduc
                 || ' order by s.cactivi',
                 mensajes
                );
      ELSIF pcnegocio = 6
      THEN
         -- Bug 23963/125448 - 17/10/2012 - AMC
         cur :=
            f_opencursor
               (   'SELECT CCOMPANI catribu, TCOMPANI tatribu
                               FROM companias
                               WHERE (ctipcom = 0 or ctipcom is null)'
                -- 75.0 - 15/10/2013 - MMM - 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos - Inicio
                || ' AND (fbaja IS NULL OR fbaja > f_sysdate) '
                || 
                   -- 75.0 - 15/10/2013 - MMM - 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos - Fin
                   'ORDER BY TCOMPANI',
                mensajes
               );
      -- Fi Bug 23963/125448 - 17/10/2012 - AMC
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_negocio;

   /*************************************************************************
        Recupera la Lista de distintos productus filtrado por compa??ia, devuelve un ref cursor
        param in pccompani : codigo de compa??ia
        param in pcramo : codigo de ramo
        param out : mensajes de error
        return    : ref cursor
         -- JBN -bUG16310-20/12/2010- Se a??ade funci??n
     *************************************************************************/
   FUNCTION f_get_productoscompania (
      pccompani   IN       NUMBER,
      pcramo      IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vtermfin   VARCHAR2 (100);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)
            := 'par??mtros: pccompani: ' || pccompani || 'pcramo: ' || pcramo;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_ramoscompania';
      terror     VARCHAR2 (200)  := 'Error recuperar ramoscompania';
      vselect    VARCHAR2 (2000);
   BEGIN
      vselect :=
            'select p.sproduc, t.ttitulo from titulopro t, productos p '
         || 'where t.CRAMO = p.CRAMO and t.CCOLECT=p.CCOLECT and '
         || 't.CTIPSEG =p.CTIPSEG and t.CMODALI = p.CMODALI and p.CRAMO = t.cramo '
         || 'and t.cidioma = '
         || pac_md_common.f_get_cxtidioma ()
         || ' ';

      IF pccompani IS NOT NULL
      THEN
         vselect := vselect || 'and p.ccompani = ' || pccompani || ' ';
      END IF;

      IF pcramo IS NOT NULL
      THEN
         vselect := vselect || 'and p.cramo = ' || pcramo || ' ';
      END IF;

      vselect := vselect || 'order by ttitulo';
      cur := f_opencursor (vselect, mensajes);
      vpasexec := 2;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_productoscompania;

   /*************************************************************************
      Recupera la Lista de distintos ramos filtrado por compa??ia, devuelve un ref cursor
      param in pccompani : codigo de compa??ia
      param out : mensajes de error
      return    : ref cursor
       -- JBN -bUG16310-20/12/2010- Se a??ade funci??n
   *************************************************************************/
   FUNCTION f_get_ramoscompania (
      pccompani   IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vtermfin   VARCHAR2 (100);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := 'par??mtros: pccompani: ' || pccompani;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_ramoscompania';
      terror     VARCHAR2 (200)  := 'Error recuperar ramoscompania';
      vselect    VARCHAR2 (2000);
   BEGIN
       -- IF pccompani IS NULL THEN
        --   RAISE e_param_error;
      --  END IF;
      vselect :=
            'select distinct r.cramo, r.tramo '
         || 'from ramos r '
         || 'where cramo in (select distinct cramo from productos where ccompani = NVL('
         || pccompani
         || ',ccompani)  ) '
         || 'and r.cidioma = '
         || pac_md_common.f_get_cxtidioma ()
         || ' '
         || 'order by  r.tramo';
      cur := f_opencursor (vselect, mensajes);
      vpasexec := 2;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ramoscompania;

   /*************************************************************************
      Recupera el tipo de pago manual de recibos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_recibo_pagmanual (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_recibo_pagmanual';
   BEGIN
      cur :=
         f_opencursor (   'select catribu,tatribu from detvalores '
                       || ' where cidioma ='
                       || pac_md_common.f_get_cxtidioma ()
                       || ' and cvalor=1026 and catribu != 1',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            NULL,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_recibo_pagmanual;

   /*************************************************************************
      Recupera el tipo de r??gimen fiscal
      param in ctipper : tipo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
      Bug.: 18942
   *************************************************************************/
   FUNCTION f_get_regimenfiscal (
      pctipper   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_regimenfiscal';
   BEGIN
      cur :=
         f_opencursor (   'select rf.cregfiscal, ff_desvalorfijo(1045,'
                       || pac_md_common.f_get_cxtidioma ()
                       || ',rf.cregfiscal) tregfiscal'
                       || ' from regimen_fiscal rf where rf.ctipper = '
                       || pctipper
                       || ' and rf.fhasta is null'
                       || ' order by cregfiscal asc',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            NULL,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_regimenfiscal;

    /*************************************************************************
       Recupera la informaci??n de los atributos seg??n el valor, en funci??n del
       valor y atributo del cual depende
       param in cempres     : codigo de la empresa
       param in cvalor     : C??digo del valor del cual existe una dependencia
       param in catribu     : C??digo del atributo del cual existe una dependencia
       param in cvalordep     : C??digo del valor dependiente
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   -- Bug 19169 - APD - 01/08/2011 - se crea la funcion
   FUNCTION f_detvalores_dep (
      pcempres     IN       NUMBER,
      pcvalor      IN       NUMBER,
      pcatribu     IN       NUMBER,
      pcvalordep   IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      --
      cur        sys_refcursor;
      vparam     VARCHAR2 (2000)
         :=    'pcempres='
            || pcempres
            || ', pcvalor='
            || pcvalor
            || ', pcatribu='
            || pcatribu
            || ', pcvalordep='
            || pcvalordep;
      vpasexec   NUMBER (8)      := 1;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_detvalores_dep';
   BEGIN
     --IAXIS 4504 AABC 09/10/2019 Cambio de orden de lista de codigos de pago   
      IF pcvalordep <> 803 THEN 
      cur :=
         f_opencursor('SELECT d.catribu, d.tatribu FROM detvalores d, detvalores_dep dd '
             || ' WHERE d.cvalor = dd.cvalordep AND d.catribu = dd.catribudep '
                      || ' AND dd.cempres = ' || pcempres || ' AND dd.cvalor = ' || pcvalor
                      || ' AND dd.catribu = ' || NVL(pcatribu, -1) || ' AND dd.cvalordep = '
                      || pcvalordep || ' AND d.cidioma = ' || pac_md_common.f_get_cxtidioma()
             || ' ORDER BY d.catribu',
                      mensajes);
      RETURN cur;
      ELSE 
      cur :=
         f_opencursor('SELECT d.catribu, d.tatribu FROM detvalores d, detvalores_dep dd '
                      || ' WHERE d.cvalor = dd.cvalordep AND d.catribu = dd.catribudep '
                      || ' AND dd.cempres = ' || pcempres || ' AND dd.cvalor = ' || pcvalor
                      || ' AND dd.catribu = ' || NVL(pcatribu, -1) || ' AND dd.cvalordep = '
                      || pcvalordep || ' AND d.cidioma = ' || pac_md_common.f_get_cxtidioma()
                      || ' ORDER BY d.tatribu',
                      mensajes);
      RETURN cur;
      END IF;   
      --IAXIS 4504 AABC 09/10/2019 Cambio de orden de lista de codigos de pago  
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_detvalores_dep;
  
   --INI IAXIS-5378
       /*************************************************************************
       Recupera la informaci??n de los atributos seg??n el valor, en funci??n del
       valor y atributo del cual depende
       param in cempres     : codigo de la empresa
       param in cvalor     : C??digo del valor del cual existe una dependencia
       param in catribu     : C??digo del atributo del cual existe una dependencia
       param in cvalordep     : C??digo del valor dependiente
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_detvalores_dep_rol (
      pcempres     IN       NUMBER,
      pcvalor      IN       NUMBER,
      pcatribu     IN       NUMBER,
      pcvalordep   IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      --
      cur        sys_refcursor;
      vparam     VARCHAR2 (2000)
         :=    'pcempres='
            || pcempres
            || ', pcvalor='
            || pcvalor
            || ', pcatribu='
            || pcatribu
            || ', pcvalordep='
            || pcvalordep;
      vpasexec   NUMBER (8)      := 1;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_detvalores_dep_rol';
      --código de parametro donde se parametrizan los tipos de identificación que pueden ver los roles diferentes al area de Analisis de Clientes
      v_cod_param    VARCHAR2(20) := 'PERF_TIPO_DOC'; 
      --cadena que contiene el conjunto de validaciones a agregar en la consulta Select en caso de que el usuario logueado no sea de ares de Analisis de Clientes
      v_and_param varchar2(1000);
      --codigo del rol del usuario logueado
      v_rol      VARCHAR2(20);
      
   BEGIN
    SELECT CROLMEN
    INTO v_rol
    FROM MENU_USERCODIROL
    WHERE CUSER = f_user;
    
    IF v_rol like '0003%' THEN
      v_and_param := '';
    ELSE 
      v_and_param := ' AND '','' || p.TVALPAR || '',''like (''%,'' ||d.catribu|| '',%'')';
    END IF;
    
      cur :=
         f_opencursor
            (   'SELECT d.catribu, d.tatribu FROM detvalores d, detvalores_dep dd, parempresas p '
             || ' WHERE d.cvalor = dd.cvalordep AND d.catribu = dd.catribudep '
             || ' AND dd.cempres = '
             || pcempres
             || ' AND dd.cvalor = '
             || pcvalor
             || ' AND dd.catribu = '
             || NVL (pcatribu, -1)
             || ' AND dd.cvalordep = '
             || pcvalordep
             || ' AND d.cidioma = '
             || pac_md_common.f_get_cxtidioma ()
             || 'AND p.CPARAM = ' || CHR(39) || v_cod_param || CHR(39)
             || v_and_param
             || ' ORDER BY d.catribu',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );
        IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_detvalores_dep_rol;
   --FIN IAXIS-5378
   
   -- BUG18752:DRA:02/09/2011:Inici
   /*************************************************************************
      Recuperar tipos de documentos VF 672 seg??n el tipo de persona
      param in ctipper  : tipo de persona (VF-85)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipdocum_tipper (
      pcempres   IN       NUMBER,
      pctipper   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      --
      cur         sys_refcursor;
      vparam      VARCHAR2 (2000)
                      := 'pcempres=' || pcempres || ', pctipper=' || pctipper;
      vpasexec    NUMBER (8)      := 1;
      vobject     VARCHAR2 (200)
                                := 'PAC_MD_LISTVALORES.f_get_tipdocum_tipper';
      v_cempres   NUMBER (2);
   BEGIN
      IF pcempres IS NULL
      THEN
         v_cempres := pac_md_common.f_get_cxtempresa;
      ELSE
         v_cempres := pcempres;
      END IF;

      IF pctipper IS NULL
      THEN
         cur := f_get_tipdocum (mensajes);
      ELSE
         cur := f_detvalores_dep (v_cempres, 85, pctipper, 672, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipdocum_tipper;
   
   --INI IAXIS-5378
   /*************************************************************************
      Recuperar tipos de documentos VF 672 seg??n el tipo de persona y rol
      param in ctipper  : tipo de persona (VF-85)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipdocum_tipper_rol (
      pcempres   IN       NUMBER,
      pctipper   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      --
      cur         sys_refcursor;
      vparam      VARCHAR2 (2000)
                      := 'pcempres=' || pcempres || ', pctipper=' || pctipper;
      vpasexec    NUMBER (8)      := 1;
      vobject     VARCHAR2 (200)
                                := 'PAC_MD_LISTVALORES.f_get_tipdocum_tipper_rol';
      v_cempres   NUMBER (2);
   BEGIN
      IF pcempres IS NULL
      THEN
         v_cempres := pac_md_common.f_get_cxtempresa;
      ELSE
         v_cempres := pcempres;
      END IF;

      IF pctipper IS NULL
      THEN
         cur := f_get_tipdocum (mensajes);
      ELSE
         cur := f_detvalores_dep_rol (v_cempres, 85, pctipper, 672, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipdocum_tipper_rol;
   --FIN IAXIS-5378

-- BUG18752:DRA:02/09/2011:Fi
   -- BUG 19130 - 20/09/2011 - JMP
   /*************************************************************************
      FUNCI??N F_GET_LSTMODALI

      Recupera la Lista de modalidades, devuelve un ref cursor
      param in pcramo : c??digo de ramo
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmodali (pcramo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'par??metros -  pcramo: ' || pcramo;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_Lstmodali';
      cur        sys_refcursor;
   BEGIN
      IF pcramo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      cur :=
         f_opencursor (   'select distinct cmodali, tmodali from desmodali '
                       || 'where cidioma = '
                       || pac_md_common.f_get_cxtidioma
                       || ' and cramo = '
                       || pcramo
                       || ' order by tmodali',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmodali;

-- FIN BUG 19130 - 20/09/2011 - JMP

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cclapri
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   -- Bug 18319 - APD - 03/10/2011 - se crea la funcion
   FUNCTION f_get_lstformulas_utili (
      pcutili    IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_LISTVALORES.F_Get_LstFormulas_utili';
      terror     VARCHAR2 (200) := 'Error recuperar formulas';
   BEGIN
      cur :=
         f_opencursor (   'select clave, codigo from '
                       || 'sgt_formulas where cutili ='
                       || pcutili
                       || ' order by clave',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstformulas_utili;

   /*************************************************************************
      Recupera los cobradores y descripcion que esten vigentes para una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor

         03/10/2011   ETM          DESCRIPCION   Cobradores bancarios. Bug: 17383
   *************************************************************************/
   FUNCTION f_get_lstdesccobradores (
      pcempres   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'pcempres= ' || pcempres;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_LISTVALORES.F_get_lstdesccobradores';
      terror     VARCHAR2 (200) := 'Error recuperar cobradores';
   BEGIN
      cur :=
         f_opencursor (   'select ccobban, descripcion from cobbancario '
                       || ' where cempres ='
                       || pcempres
                       || ' and cbaja <> 1 ORDER BY ccobban',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdesccobradores;

   --
   -- Bug 003268 Inicio - Se crea la nueva funcion f_get_lstdesccobradores_all
   --
   /*************************************************************************
      Recupera los cobradores y descripcion para una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor

         03/10/2011   ETM          DESCRIPCION   Cobradores bancarios. Bug: 17383
   *************************************************************************/
   FUNCTION f_get_lstdesccobradores_all (
      pcempres   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'pcempres= ' || pcempres;
      vobject    VARCHAR2 (200)
                          := 'PAC_MD_LISTVALORES.F_get_lstdesccobradores_all';
      terror     VARCHAR2 (200) := 'Error recuperar cobradores';
   BEGIN
      cur :=
         f_opencursor (   'select ccobban, descripcion from cobbancario '
                       || ' where cempres ='
                       || pcempres
                       || ' ORDER BY ccobban',
                       mensajes
                      );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdesccobradores_all;

   --
   -- Bug 0032668 Fin
   --

   /*************************************************************************
      Recupera la descripci??n de los cobradores bancarios en funci??n del producto
      param in clave     : clave a recuperar detalles
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_descobradores_ramo (
      psproduc   IN       NUMBER,
      pcbancar   IN       VARCHAR2,
      pctipban   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000)
         :=    'PSPRODUC ='
            || psproduc
            || ' PCBANCAR = '
            || pcbancar
            || ' pctipban = '
            || pctipban;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_LISTVALORES.f_get_descobradores_ramo';
      terror     VARCHAR2 (200)
                        := 'Error recuperar cobradores bancarios por producto';
      vcodi      NUMBER;
      vnombre    VARCHAR2 (4000);
      v_dummy    NUMBER          := 0;
   BEGIN
      SELECT COUNT ('1')
        INTO v_dummy
        FROM cobbancario cb, cobbancariosel cl, productos p
       WHERE cb.ccobban = cl.ccobban
         AND cl.cramo = p.cramo
         AND cl.ctipseg = p.ctipseg
         AND cl.ccolect = p.ccolect
         AND cl.cmodali = p.cmodali
         AND cl.cempres = pac_md_common.f_get_cxtempresa ()
         AND p.sproduc = psproduc;

      IF v_dummy <> 0
      THEN
         cur :=
            f_opencursor
                 (   'select cb.ccobban, cb.descripcion tdescri, cl.cbanco '
                  || 'from cobbancario cb, cobbancariosel cl, productos p '
                  || 'where cb.ccobban = cl.ccobban '
                  || 'and cl.cramo = p.cramo '
                  || 'and cl.ctipseg = p.ctipseg '
                  || 'and cl.ccolect = p.ccolect '
                  || 'and cl.cmodali = p.cmodali '
                  || 'and cl.cempres =  '
                  || pac_md_common.f_get_cxtempresa ()
                  || ' and p.sproduc =  '
                  || psproduc
                  || ' order by descripcion',
                  mensajes
                 );
      ELSE
         IF pcbancar IS NOT NULL AND pctipban IS NOT NULL
         THEN
            cur :=
               f_opencursor
                  (   'select cb.ccobban, cb.descripcion tdescri, cl.cbanco '
                   || ' from cobbancario cb, cobbancariosel cl, productos p, tipos_cuenta tc '
                   || 'where cb.ccobban = cl.ccobban and cl.cramo = p.cramo '
                   || 'and cl.cempres = '
                   || pac_md_common.f_get_cxtempresa ()
                   || 'and p.sproduc ='
                   || psproduc
                   || 'and to_number(substr('
                   || CHR (39)
                   || pcbancar
                   || CHR (39)
                   || ',tc.pos_entidad,tc.long_entidad)) = cl.cbanco '
                   || ' and tc.ctipban = '
                   || pctipban
                   || ' and tc.pos_entidad is not null and tc.long_entidad is not null '
                   -- 73.0 - 08/10/2013 - MMM -0028465: LCOL999-Id. 187 - Contabilidad Cobro recibo debito - Inicio
                   --|| ' and NVL(cb.ccontaban,0) = pac_ccc.f_estarjeta(tc.ctipcc, null) '   -- 47 JGR 21097: LCOL_A001-Tener en cuenta el tipo de cuenta
                   || ' and NVL(cb.ctarjeta,0) = pac_ccc.f_estarjeta(tc.ctipcc, null) '
                   -- 73.0 - 08/10/2013 - MMM -0028465: LCOL999-Id. 187 - Contabilidad Cobro recibo debito - Fin
                   || ' order by descripcion',
                   mensajes
                  );
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_descobradores_ramo;

   -- BUG19069:DRA:26/09/2011:Inici
   FUNCTION f_get_lstcondiciones (
      pcempres      IN       NUMBER,
      pcuser        IN       VARCHAR2,
      pccondicion   IN       VARCHAR2,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      --
      CURSOR c_cond (pc_ccfguser IN VARCHAR2)
      IS
         SELECT   c.tcondicion
             FROM lst_condiciones c
            WHERE c.cempres = pcempres
              AND (   (pccondicion IS NOT NULL AND c.ccondicion = pccondicion
                      )
                   OR (pccondicion IS NULL AND c.ccondicion = 'GENERAL')
                  )
              AND (c.ccfguser = pc_ccfguser OR c.ccfguser = 'DEFAULT')
         ORDER BY c.norden;

      vpasexec    NUMBER (8)       := 1;
      vparam      VARCHAR2 (1000)
         :=    ' pcempres = '
            || pcempres
            || ' pcuser = '
            || pcuser
            || ' pccondicion = '
            || pccondicion;
      vobject     VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_LstCondiciones';
      vccfgform   VARCHAR2 (200);
      condicion   VARCHAR2 (4000);
      r_cond      c_cond%ROWTYPE;
   BEGIN
      condicion := NULL;

      SELECT cu.ccfgform
        INTO vccfgform
        FROM cfg_user cu
       WHERE cu.cuser = pcuser AND cu.cempres = pcempres;

      OPEN c_cond (vccfgform);

      FETCH c_cond
       INTO r_cond;

      WHILE c_cond%FOUND
      LOOP
         condicion := condicion || ' ' || r_cond.tcondicion;

         FETCH c_cond
          INTO r_cond;
      END LOOP;

      CLOSE c_cond;

      RETURN condicion;
   EXCEPTION
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
   END f_get_lstcondiciones;

   FUNCTION f_get_lstagentes_cond (
      numide     IN       VARCHAR2,
      nombre     IN       VARCHAR2,
      pcagente   IN       NUMBER,
      pformato   IN       NUMBER,
      cond       IN       VARCHAR2,
      pctipage   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes,
      ppartner   IN       NUMBER DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      --
      condicion       VARCHAR2 (1000);
      cur             sys_refcursor;
      vpasexec        NUMBER (8)             := 1;
      vparam          VARCHAR2 (1000)
         :=    'numide= '
            || numide
            || ' nombre= '
            || nombre
            || ' pcagente= '
            || pcagente
            || ' pformato= '
            || pformato
            || ' cond= '
            || cond
            || ' pctipage= '
            || pctipage;
      vobject         VARCHAR2 (200)
                                 := 'PAC_MD_LISTVALORES.F_Get_LstAgentes_Cond';
      terror          VARCHAR2 (200)         := 'Error recuperar agentes';
      no_hay_datos    EXCEPTION;
      vcodi           NUMBER;
      vnombre         VARCHAR2 (200);
      vselect         VARCHAR2 (2000);
      vwhere          VARCHAR2 (2000);
      -- INI -IAXIS-5100 - JLTS - 21/08/2019
      vctipage_agen   agentes.ctipage%TYPE   := 3;    -- Agencias repre/Propia
   -- FIN -IAXIS-5100 - JLTS - 21/08/2019
   BEGIN
      condicion := '%' || nombre || '%';
      condicion := REPLACE (condicion, CHR (39), CHR (39) || CHR (39));
                                       -- BUG 38344/217178 - 28/10/2015 - ACL

      IF condicion IS NOT NULL
      THEN
         vwhere :=
               ' AND (upper( F_NOMBRE (a.sperson , 1)) like UPPER ('''
            || condicion
            || ''') OR '''
            || condicion
            || ''' IS NULL) ';
      END IF;

      condicion := '%' || numide || '%';
      condicion := REPLACE (condicion, CHR (39), CHR (39) || CHR (39));
                                        -- BUG 38344/217178 - 09/11/2015 - ACL

      IF condicion IS NOT NULL
      THEN
         -- Bug 35888/205345 Realizar la substitución del upper nnumnif o nnumide - CJMR D02 A02
         --vwhere := vwhere || ' AND (upper( p.nnumide) like UPPER (''' || condicion
         --          || ''') OR ''' || condicion || ''' IS NULL) ';
         vwhere :=
               vwhere
            || ' AND ( p.nnumide like '''
            || condicion
            || ''' OR '''
            || condicion
            || ''' IS NULL) ';
      END IF;

      IF ppartner IS NOT NULL
      THEN
         vwhere := vwhere || ' AND r.cpadre=' || ppartner;
      END IF;

      IF cond IS NOT NULL
      THEN
         -- BUG25936:DRA:07/02/2013:Inici
         IF INSTR (cond, 'UNION') <> 0
         THEN
            vwhere :=
                  vwhere
               || ' '
               || cond
               || vwhere
               || ' AND a.cagente = NVL ('
               || NVL (TO_CHAR (pcagente), 'null')
               || ', a.cagente) ';
         ELSE
            vwhere := vwhere || ' ' || cond;
         END IF;
      -- BUG25936:DRA:07/02/2013:Fi
      END IF;

      -- INI -IAXIS-5100 - JLTS - 21/08/2019
      IF pformato = 55
      THEN                      -- Condicion para ser utilizada por Rango Dian
         vselect :=
               'SELECT a.cagente codi, PAC_REDCOMERCIAL.ff_desagente (a.cagente, '
            || pac_md_common.f_get_cxtidioma
            || ', '
            || pformato
            || ') nombre,'
            || ' a.ccomisi, a.ctipage, r.cpadre, '
            || ' PAC_REDCOMERCIAL.ff_desagente (r.cpadre, '
            || pac_md_common.f_get_cxtidioma
            || ', 0) tsucursal, pac_persona.F_FORMAT_NIF(p.NNUMIDE,p.CTIPIDE,p.sperson,''SEG'') NNUMIDE '
            || ' FROM agentes a, redcomercial r, per_personas p, agentes_agente_pol ap WHERE a.cagente =  NVL ('
            || NVL (TO_CHAR (pcagente), 'null')
            || ', a.cagente) '
            || ' AND r.cempres = pac_md_common.f_get_cxtempresa AND a.SPERSON = p.SPERSON and a.ccomisi <> pac_parametros.f_parempresa_t(24,''COD_COMI_EMISION'')'
            || ' AND ( a.ctipage = NVL('''
            || pctipage
            || ''', a.ctipage) OR a.ctipage = NVL('''
            || vctipage_agen
            || ''', a.ctipage) )'
            || ' AND r.cagente(+) = a.cagente AND ap.cagente = a.cagente'
            || ' AND (r.fmovfin IS NULL OR TRUNC(r.fmovfin) > TRUNC (f_sysdate))  '
            || vwhere
            || ' ORDER BY 1';
      ELSE
         vselect :=
               'SELECT a.cagente codi, PAC_REDCOMERCIAL.ff_desagente (a.cagente, '
            || pac_md_common.f_get_cxtidioma
            || ', '
            || pformato
            || ') nombre,'
            || ' a.ccomisi, a.ctipage, r.cpadre, '
            || ' PAC_REDCOMERCIAL.ff_desagente (r.cpadre, '
            --         || pac_md_common.f_get_cxtidioma || ', 0) tsucursal, p.NNUMIDE '
            || pac_md_common.f_get_cxtidioma
            || ', 0) tsucursal, pac_persona.F_FORMAT_NIF(p.NNUMIDE,p.CTIPIDE,p.sperson,''SEG'') NNUMIDE '
            -- BUG 26968 - FAL - 04/07/2013
            || ' FROM agentes a, redcomercial r, per_personas p, agentes_agente_pol ap WHERE a.cagente =  NVL ('
            || NVL (TO_CHAR (pcagente), 'null')
            || ', a.cagente) '
            || ' AND r.cempres = pac_md_common.f_get_cxtempresa AND a.SPERSON = p.SPERSON and a.ccomisi <> pac_parametros.f_parempresa_t(24,''COD_COMI_EMISION'')'
            || ' AND a.ctipage = NVL('''
            || pctipage
            || ''', a.ctipage) '
            || ' AND r.cagente(+) = a.cagente AND ap.cagente = a.cagente'
            || ' AND (r.fmovfin IS NULL OR TRUNC(r.fmovfin) > TRUNC (f_sysdate))  '
            || vwhere
            || ' ORDER BY 1';                       --TCS-344 CJMR  25/02/2019
      END IF;

      -- FIN -IAXIS-5100 - JLTS - 21/08/2019
      cur := f_opencursor (vselect, mensajes);

      IF cur%FOUND
      THEN
         IF cur%ISOPEN
         THEN
            FETCH cur
             INTO vcodi, vnombre;

            IF cur%NOTFOUND
            THEN
               RAISE no_hay_datos;
            END IF;

            CLOSE cur;
         END IF;
      END IF;

      -- Lo volvemos a abrir ya que el FETCH lo deja sin las filas ya consultadas
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN no_hay_datos
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000730);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstagentes_cond;

   /*************************************************************************
      Recupera la lista de agentes seg??n los criterios
      param in numide : numero documento persona
      param in nombre : texto que incluye nombre + apellidos
   *************************************************************************/
   FUNCTION f_get_lstagentes_dat (
      numide     IN       VARCHAR2,
      nombre     IN       VARCHAR2,
      pcagente   IN       NUMBER,
      pformato   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      condicion      VARCHAR2 (1000);
      cur            sys_refcursor;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (1000)
         :=    'numide= '
            || numide
            || ' nombre= '
            || nombre
            || ' pcagente= '
            || pcagente;
      vobject        VARCHAR2 (200)
                                  := 'PAC_MD_LISTVALORES.F_Get_LstAgentes_Dat';
      terror         VARCHAR2 (200)  := 'Error recuperar agentes';
      no_hay_datos   EXCEPTION;
      vcodi          NUMBER;
      vnombre        VARCHAR2 (200);
      vselect        VARCHAR2 (2000);
      vwhere         VARCHAR2 (2000);
      vwherevista    VARCHAR2 (2000);
                                             --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      condicion := '%' || nombre || '%';

      IF condicion IS NOT NULL
      THEN
         vwhere :=
               ' AND (upper( F_NOMBRE (a.sperson , 1)) like UPPER ('''
            || condicion
            || ''') OR '''
            || condicion
            || ''' IS NULL) ';
      END IF;

      condicion := '%' || numide || '%';
      condicion := REPLACE (condicion, CHR (39), CHR (39) || CHR (39));
                                        -- BUG 38344/217178 - 09/11/2015 - ACL

      IF condicion IS NOT NULL
      THEN
         -- Bug 35888/205345 Realizar la substitución del upper nnumnif o nnumide - CJMR D02 A02
         --vwhere := vwhere || ' AND (upper( p.nnumide) like UPPER (''' || condicion
         --          || ''') OR ''' || condicion || ''' IS NULL) ';
         vwhere :=
               vwhere
            || ' AND ( p.nnumide like '''
            || condicion
            || ''' OR '''
            || condicion
            || ''' IS NULL) ';
      END IF;

      --BUG19533 - JTS - 29/009/2011
      /*
      IF pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'FILTRO_AGE') = 1 THEN
         vwherevista := ' AND a.cagente in (SELECT a.cagente '
                        || ' FROM (SELECT LEVEL nivel, cagente ' || ' FROM redcomercial r '
                        || ' WHERE ' || ' r.fmovfin is null ' || ' START WITH '
                        || '  r.cempres =  ' || pac_md_common.f_get_cxtempresa
                        || ' AND R.CAGENTE = ' || pac_md_common.f_get_cxtagente
                        || ' and r.fmovfin is null '
                        || ' CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
                        || ' AND PRIOR r.cempres =(r.cempres + 0) '
                        || ' and r.fmovfin is null ' || ' AND r.cagente >= 0) rr, '
                        || ' agentes a ' || ' where rr.cagente = a.cagente ) ';

         ???? AVISO SI ESTO SE ACTIVA, HAY QUE MODIFICAR TAMBIEN LA FUNCION CLONADA f_get_lstagentes_cond !!
      END IF;
       */
      --Fi bug19533
      vselect :=
            'SELECT a.cagente codi, PAC_REDCOMERCIAL.ff_desagente (a.cagente, '
         || pac_md_common.f_get_cxtidioma
         || ', '
         || pformato
         || ') nombre '
         || 'FROM agentes a,per_personas p WHERE  a.SPERSON = p.SPERSON and a.cagente = '
         || pcagente
         || vwherevista
         || vwhere
         || 'ORDER BY a.cagente';
      cur := f_opencursor (vselect, mensajes);

      IF cur%FOUND
      THEN
         IF cur%ISOPEN
         THEN
            -- dra 12-1-09: bug mantis 8650
            FETCH cur
             INTO vcodi, vnombre;

            IF cur%NOTFOUND
            THEN
               RAISE no_hay_datos;
            END IF;

            CLOSE cur;
         END IF;
      END IF;

      -- Lo volvemos a abrir ya que el FETCH lo deja sin las filas ya consultadas
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN no_hay_datos
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000730);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstagentes_dat;

-- BUG19069:DRA:26/09/2011:Fi

   -- 41.0 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Inici
   /*************************************************************************
      Recupera los estados de las matr??culas de la cuentas bancarias de
      persona en la tabla per_ccc
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcvalida (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstcvalida';
      terror     VARCHAR2 (200)
         := 'Error recuperar estados de las matr??culas de las cuentas bancarias de persona';
   BEGIN
      cur := f_detvalores (386, mensajes);  -- Estado matr??cula.PERSONES CCC
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcvalida;

-- 41.0 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Fi
-- BUG20589:XPL:20/12/2011:Ini
   /*************************************************************************
      Recupera las monedas que se pueden visualizar, devuelve cdigo y descripcin
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_monedas (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := '';
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_monedas';
      terror     VARCHAR2 (200)  := '';
   BEGIN
      cur :=
         f_opencursor
                (   'SELECT   m.cmoneda, ed.tmoneda, m.cmonint '
                 || ' FROM monedas m, eco_codmonedas ec, eco_desmonedas ed '
                 || ' WHERE m.cidioma = ed.cidioma '
                 || '  AND ed.cidioma =  '
                 || pac_md_common.f_get_cxtidioma
                 || '  AND ec.cmoneda = ed.cmoneda '
                 || '  AND m.cmonint = ec.cmoneda '
                 || '  AND ec.bvisualiza = 1 '
                 || ' ORDER BY m.cmoneda ASC',
                 mensajes
                );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_monedas;

   /*************************************************************************
      Recupera la descripcion de una moneda
      param in cmoneda : cdigo moneda
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tmoneda (
      pcmoneda   IN       NUMBER,
      pcmonint   OUT      VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := 'par??metros -  pcmoneda : ' || pcmoneda;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_LISTVALORES.f_get_tmoneda';
      vtmoneda   VARCHAR2 (1000);
   BEGIN
      SELECT ed.tmoneda, ec.cmoneda
        INTO vtmoneda, pcmonint
        FROM monedas m, eco_codmonedas ec, eco_desmonedas ed
       WHERE m.cidioma = ed.cidioma
         AND ed.cidioma = pac_md_common.f_get_cxtidioma
         AND ec.cmoneda = ed.cmoneda
         AND m.cmonint = ec.cmoneda
         AND m.cmoneda = pcmoneda;

      RETURN vtmoneda;
   EXCEPTION
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
         RETURN '';
   END f_get_tmoneda;

-- BUG20589:XPL:20/12/2011:Fi

   -- 45.0 10/02/2012 JGR 20735/0103205 LCOL_A001-LCOL_A001-ADM - Introduccion de cuenta bancaria - Inici
   /*************************************************************************
      Recupera los tipos de cuenta para TIPOS_CUENTA.CTIPCC (tarjetas, cuentas corrientes, etc.)
      parametros:
            ptipocta = "1" Cuenta corriente, "2" Tarjetas, "Otro valor" Todos los tipos
            out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   -- 46.0 17/01/2012 JGR 0020735 - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
   -- Se le a??ade el par??metro ptipocta para que limite el cursor en caso de venir informado.
   -- 46.0 17/01/2012 JGR 0020735 - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
   FUNCTION f_get_lsttipcc (
      ptipocta         NUMBER DEFAULT NULL,
      mensajes   OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur          sys_refcursor;
      vestarjeta   NUMBER;
      vpasexec     NUMBER (8)     := 1;
      vparam       VARCHAR2 (1)   := NULL;
      vobject      VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lsttipcc';
      terror       VARCHAR2 (200)
                             := 'Error recuperar los tipos de cuentas CTIPCC';
   BEGIN
      IF ptipocta IN (1, 2)
      THEN
         IF ptipocta = 2
         THEN
            vestarjeta := 1;
         ELSE
            vestarjeta := 0;
         END IF;

         cur :=
            f_opencursor (   ' SELECT   d.catribu, d.tatribu '
                          || ' FROM detvalores d '
                          || ' WHERE d.cvalor = 800049 '
                          || ' AND pac_ccc.f_estarjeta(catribu, NULL) = '
                          || vestarjeta
                          || ' AND d.cidioma = '
                          || pac_md_common.f_get_cxtidioma ()
                          || ' ORDER BY d.catribu',
                          mensajes
                         );
      ELSE
         cur := f_detvalores (800049, mensajes);            -- Tipo de Cuenta
      END IF;

      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipcc;

-- 45.0 10/02/2012 JGR 20735/0103205 LCOL_A001-LCOL_A001-ADM - Introduccion de cuenta bancaria - Fi

   /*************************************************************************
      Recupera los estados finales permitidos para un agente
      param in pcempres : codigo de la empresa
      param in pctipage : c?digo de tipo de agente
      param in pcestant : c?digo de estado de agente
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   -- Bug 21682 - APD - 24/04/2012 - se crea la funcion
   FUNCTION f_get_lstestadoagente_trans (
      pcempres   IN       NUMBER,
      pctipage   IN       NUMBER,
      pcestant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (2000)
         :=    'pcempres = '
            || pcempres
            || ';pctipage = '
            || pctipage
            || ';pcestant = '
            || pcestant;
      vobject    VARCHAR2 (200)
                           := 'PAC_MD_LISTVALORES.f_get_lstestadoagente_trans';
      terror     VARCHAR2 (200)   := '';
      vsquery    VARCHAR2 (10000);
      vsfrom     VARCHAR2 (10000);
      vcempres   NUMBER;
      salir      EXCEPTION;
   BEGIN
      vcempres := pcempres;

      IF vcempres IS NULL
      THEN
         vcempres := pac_md_common.f_get_cxtempresa ();
      END IF;

      vsquery :=
            'SELECT AT.CESTACT catribu, ff_desvalorfijo(31, '
         || pac_md_common.f_get_cxtidioma ()
         || ', AT.CESTACT) tatribu '
         || ' FROM   AGE_TRANSICIONES AT '
         || ' WHERE  AT.CEMPRES      = '
         || vcempres
         || ' AND AT.CTIPAGE  = NVL('
         || NVL (TO_CHAR (pctipage), 'NULL')
         || ', -1) AND (AT.CREALIZA = '
         || ' (SELECT CREALIZA FROM CFG_ACCION WHERE CACCION = ''TRANS_ESTADO_AGE'''
         || ' AND CCFGACC = (SELECT CCFGACC FROM   CFG_USER '
         || ' WHERE  CUSER = pac_md_common.f_get_cxtusuario() AND  CEMPRES = '
         || vcempres
         || ')) '
         || ' OR AT.CREALIZA is NULL) '
         || ' AND (AT.CESTANT = NVL('
         || NVL (TO_CHAR (pcestant), 'NULL')
         || ', -1) OR (AT.CESTANT is NULL AND NVL('
         || NVL (TO_CHAR (pcestant), 'NULL')
         || ', -1) = -1))';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestadoagente_trans;

   /*************************************************************************
          Recupera c??digo y descripci??n de las diferentes descuentos definidas para los agentes.
          param out mensajes : mensajes de error
          return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagedescuento (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_get_LstAgeDescuento';
      vsquery    VARCHAR2 (2000);
   BEGIN
      vsquery :=
            ' SELECT d.cdesc,d.tdesc FROM codidesc c, desdesc d
                   WHERE c.cdesc = d.cdesc
                   AND c.cdesc IN (SELECT distinct(cv.cdesc)
                                FROM descvig cv
                                WHERE cv.cestado = 2)'
         || ' AND d.cidioma=PAC_MD_COMMON.F_Get_CXTIdioma
                   ORDER BY d.cdesc';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstagedescuento;

-- bfp bug 21524 ini
/*************************************************************************
         F_GET_TRAMITADORES
      Obt? els tramits d'un ramo
      param in pcramo                : codi del ramo
      param in pctramte                : codi del tr?mit
      param out t_iax_mensajes         : mensajes de error
      return                           : el cursor
   *************************************************************************/
 --BUG 0024467: XVM :02/11/2012--Inicio
   FUNCTION f_get_tramitadores (
      pcramo     IN       NUMBER,
      pctramte   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      v_pasexec   NUMBER (8)      := 1;
      v_param     VARCHAR2 (500)
                          := 'pcramo:' || pcramo || ' pctramte: ' || pctramte;
      v_object    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_tramitadores';
      v_query     VARCHAR2 (1000)
         := 'SELECT c.ctramitad, c.ttramitad FROM sin_codtramitador c, sin_tramitadores t WHERE c.ctramitad = t.ctramitad and t.cempres = f_empres';
      v_cond      VARCHAR2 (1000);
      v_cursor    sys_refcursor;
   BEGIN
      IF (pcramo IS NOT NULL)
      THEN
         v_cond := ' AND ( t.cramo = ' || pcramo || ' OR t.cramo is null )';
      END IF;

      v_query := v_query || v_cond;
      v_pasexec := 2;

      IF (pctramte IS NOT NULL)
      THEN
         v_cond :=
                ' AND ( t.ctramte = ' || pctramte || ' or t.ctramte is null)';
      END IF;

      v_query := v_query || v_cond;
      v_pasexec := 3;
      v_query := v_query || v_cond;
      v_pasexec := 7;
      v_cursor := pac_iax_listvalores.f_opencursor (v_query, mensajes);

      IF v_cursor IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000005,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN v_cursor;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000006,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN v_cursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000001,
                                            v_pasexec,
                                            v_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF v_cursor%ISOPEN
         THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
   END f_get_tramitadores;

--BUG 0024467: XVM :02/11/2012--Fin

   /*************************************************************************
         F_GET_LISTA_TRAMITADORES
      Obt? els tramits d'un ramo
      param in pcramo                : codi del ramo
      param in pctramte                : codi del tr?mit
      param in pcempres                : codi de l'empresa
      param in pccausin                : codi de la causa del sinistre
      param in pcmotsin                : codi del motiu del sinistre
      param in pcagente                : codi agente
      param out t_iax_mensajes         : mensajes de error
      return                           : el cursor
   *************************************************************************/
   FUNCTION f_get_lista_tramitadores (
      pcramo     IN       NUMBER,
      pctramte   IN       NUMBER,
      pcempres   IN       NUMBER,
      pccausin   IN       NUMBER,
      pcmotsin   IN       NUMBER,
      pcagente   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      v_pasexec   NUMBER (8)      := 1;
      v_param     VARCHAR2 (500)
         :=    'pcramo:'
            || pcramo
            || ' pctramte: '
            || pctramte
            || ' pcempres: '
            || pcempres
            || ' pccausin: '
            || pccausin
            || ' pcmotsin: '
            || pcmotsin
            || ' pcagente: '
            || pcagente;
      v_object    VARCHAR2 (200)
                              := 'PAC_MD_LISTVALORES.f_get_lista_tramitadores';
      v_query     VARCHAR2 (1000)
         := 'SELECT c.ctramitad, c.ttramitad FROM sin_codtramitador c, sin_tramitadores t WHERE c.ctramitad = t.ctramitad ';
      v_cond      VARCHAR2 (1000);
      v_cursor    sys_refcursor;
   BEGIN
      IF (pcramo IS NOT NULL)
      THEN
         v_cond := ' AND t.cramo = ' || pcramo;
      ELSE
         v_cond := ' AND t.cramo IS NULL';
      END IF;

      v_query := v_query || v_cond;
      v_pasexec := 2;

      IF (pctramte IS NOT NULL)
      THEN
         v_cond := ' AND t.ctramte = ' || pctramte;
      ELSE
         v_cond := ' AND t.ctramte IS NULL';
      END IF;

      v_query := v_query || v_cond;
      v_pasexec := 3;

      IF (pcempres IS NOT NULL)
      THEN
         v_cond := ' AND t.cempres = ' || pcempres;
      ELSE
         --v_cond := ' AND t.cempres IS NULL';
         RAISE e_param_error;
      END IF;

      v_query := v_query || v_cond;
      v_pasexec := 4;

      IF (pccausin IS NOT NULL)
      THEN
         v_cond := ' AND t.ccausin = ' || pccausin;
      ELSE
         v_cond := '';                            --' AND t.ccausin IS NULL';
      END IF;

      v_query := v_query || v_cond;
      v_pasexec := 5;

      IF (pcmotsin IS NOT NULL)
      THEN
         v_cond := ' AND t.cmotsin = ' || pcmotsin;
      ELSE
         v_cond := '';                            --' AND t.cmotsin IS NULL';
      END IF;

      v_query := v_query || v_cond;
      v_pasexec := 6;

      IF (pcagente IS NOT NULL)
      THEN
         v_cond := ' AND t.cagente = ' || pcagente;
      ELSE
         v_cond := '';                            --' AND t.cagente IS NULL';
      END IF;

      v_query := v_query || v_cond;
      v_pasexec := 7;
      v_cursor := pac_iax_listvalores.f_opencursor (v_query, mensajes);

      IF v_cursor IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000005,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN v_cursor;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000006,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN v_cursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000001,
                                            v_pasexec,
                                            v_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF v_cursor%ISOPEN
         THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
   END f_get_lista_tramitadores;

-- bfp bug 21524 fi

   /*************************************************************************
         F_GET_LISTA_PROFESIONALES
      Obt? els tramits d'un ramo
      param in ptipoprof               : codi del tipus de professi?
      param out t_iax_mensajes         : mensajes de error
      return                           : el cursor
   *************************************************************************/
   FUNCTION f_get_lista_profesionales (
      ptipoprof   IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      v_pasexec   NUMBER (8)      := 1;
      v_param     VARCHAR2 (500)  := 'ptipoprof:' || ptipoprof;
      v_object    VARCHAR2 (200)
                            := 'PAC_MD_LISTVALORES.f_get_lista_profesionales';
      v_query     VARCHAR2 (1000)
         :=    'SELECT spp.sprofes,pp.sperson "SPERSON", f_nombre(pp.sperson, 1) "NOMBRE" FROM sin_prof_profesionales spp, sin_prof_rol spr, '
            || 'per_personas pp WHERE spr.sprofes = spp.sprofes   AND spp.sperson = pp.sperson';
      v_cond      VARCHAR2 (1000);
      v_cursor    sys_refcursor;
   BEGIN
      --tractament par?metres
      IF ptipoprof IS NULL
      THEN
         RAISE e_param_error;
      ELSE
         v_cond := ' AND spr.ctippro = ' || ptipoprof;
         v_query := v_query || v_cond;
      END IF;

      v_pasexec := 2;
      v_cursor := pac_iax_listvalores.f_opencursor (v_query, mensajes);

      IF v_cursor IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000005,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN v_cursor;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000006,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN v_cursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000001,
                                            v_pasexec,
                                            v_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF v_cursor%ISOPEN
         THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
   END f_get_lista_profesionales;

   -- 50.0 25/07/2012 JGR 0022082: LCOL_A003-Mantenimiento de matriculas - Inici
   /*************************************************************************
      Lista de los tipos de negocio, este campo no estÃ¡ en la base de datos
      correponde a producciÃ³n (nanuali=1) o cartera (nanuali>1).
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcnegoci (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstcvalida';
      terror     VARCHAR2 (200)
                               := 'Error recuperar lista de tipos de negocio';
   BEGIN
      cur := f_detvalores (800105, mensajes);
      -- Tipos de negocio (Produccion/Cartera)
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcnegoci;

-- 50.0 25/07/2012 JGR 0022082: LCOL_A003-Mantenimiento de matriculas - Fi

   /*************************************************************************
      Recupera lista de cias de un tipo
      param out mensajes : mensajes de error
      return             : ref cursor

      BUG  23830/161685 - 18/12/2013 - DCT
      Bug 23963/125448 - 15/10/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_companias (
      psproduc      IN       NUMBER,
      pctipcom      IN       NUMBER,
      mensajes      IN OUT   t_iax_mensajes,
      paxisrea037   IN       NUMBER DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      cur         sys_refcursor;
      vpasexec    NUMBER (8)      := 1;
      vparam      VARCHAR2 (1)    := NULL;
      vobject     VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_companias';
      terror      VARCHAR2 (200)  := 'Error al recuperar las cias';
      v_cond      VARCHAR2 (2000) := NULL;
      num_err     NUMBER;
      v_cforpag   NUMBER;
      -- Bug 24602 - RSC - 22/11/2012 - LCOL_T001-Companyies Vida/No Vida de LCOL
      v_cond2     VARCHAR2 (2000) := '';
      v_entra     NUMBER          := 0;
   -- Fin Bug 24602
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      --BUG  23830/161685 - 18/12/2013 - DCT
      IF paxisrea037 IS NULL
      THEN
         -- BUG 0022839 - FAL - 24/07/2012
         IF     pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                       psproduc
                                                      ) = 1
            AND NOT pac_iax_produccion.isaltacol
         THEN
            num_err :=
                    pac_productos.f_get_herencia_col (psproduc, 9, v_cforpag);

            IF NVL (v_cforpag, 0) = 1 AND num_err = 0
            THEN
               --KBR 22/10/2013 QT:6163 (Agregamos espacio en blanco entre comilla simple y AND)
               v_cond :=
                     ' AND c.ccompani = (select ccompani from seguros where ncertif = 0 and npoliza = '
                  || NVL (pac_iax_produccion.poliza.det_poliza.npoliza, 0)
                  || ')';
            ELSE
               v_cond := NULL;
            END IF;
         END IF;
      END IF;

      -- Bug 24602 - RSC - 22/11/2012 - LCOL_T001-Companyies Vida/No Vida de LCOL
      IF pctipcom = 4
      THEN
         v_cond2 := ' AND c.ccompani IN (';

         FOR regs IN (SELECT r.crespue
                        FROM respuestas r, detvalores_dep d
                       WHERE r.cpregun = 4082
                         AND r.cidioma = pac_md_common.f_get_cxtidioma ()
                         AND d.cvalor = 1091
                         AND d.catribu = 1
                         AND d.cvalordep = psproduc
                         AND r.crespue = d.catribudep)
         LOOP
            v_cond2 := v_cond2 || regs.crespue || ',';
            v_entra := 1;
         END LOOP;

         IF v_entra = 1
         THEN
            v_cond2 := SUBSTR (v_cond2, 1, LENGTH (v_cond2) - 1);
            v_cond2 := v_cond2 || ')';
         ELSE
            v_cond2 := '';
         END IF;
      END IF;

      -- Fin bug 24602
      cur :=
         pac_md_listvalores.f_opencursor
            (   'SELECT CCOMPANI, TCOMPANI
                                               FROM companias c '
             -- 72.0 -16/09/2013- MMM - 0028158: LCOL_A003-Listas desplegables de companyias reaseguradoras y coaseguradores - Inicio
             --|| ' WHERE c.ctipcom = ' || pctipcom || v_cond || v_cond2 || ' ORDER BY TCOMPANI',
             || ' WHERE (fbaja IS NULL OR fbaja>f_sysdate) AND c.ctipcom = '
             || pctipcom
             || v_cond
             || v_cond2
             || ' ORDER BY TCOMPANI',
             -- 72.0 - 16/09/2013 - MMM - 0028158: LCOL_A003-Listas desplegables de companyias reaseguradoras y coaseguradores - Fin
             mensajes
            );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_companias;

   -- Ini Bug 24717 - MDS - 20/12/2012
   /*************************************************************************
      Lista de los tipos de beneficiario
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lst_tipobeneficiario (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                           := 'PAC_MD_LISTVALORES.f_get_lst_tipobeneficiario';
      terror     VARCHAR2 (200)
                            := 'Error al recuperar los tipos de beneficiario';
   BEGIN
      -- si se trata de un producto de Tipo de beneficiario y tipo de parentesco de beneficiario especial
      IF pac_mdpar_productos.f_get_parproducto
                                ('ALTERNATIVO_BENEF',
                                 pac_iax_produccion.poliza.det_poliza.sproduc
                                ) = 1
      THEN
         -- lista de valores específica
         cur := f_detvalores (800127, mensajes);
      ELSE
         -- lista de valores genérica
         cur := f_detvalores (1053, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lst_tipobeneficiario;

   /*************************************************************************
      Lista de los tipos de parentesco
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lst_tipoparentesco (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_LISTVALORES.f_get_lst_tipoparentesco';
      terror     VARCHAR2 (200)
                              := 'Error al recuperar los tipos de parentesco';
      v_cond     VARCHAR2 (2000) := NULL;
   BEGIN
      -- si se trata de un producto de Tipo de beneficiario y tipo de parentesco de beneficiario especial
      IF pac_mdpar_productos.f_get_parproducto
                                ('ALTERNATIVO_BENEF',
                                 pac_iax_produccion.poliza.det_poliza.sproduc
                                ) = 1
      THEN
         -- lista de valores reducida
         v_cond := 'catribu IN (7, 9, 12, 18, 29, 30, 31, 32)';
         cur := f_detvalorescond (1054, v_cond, mensajes);
      ELSE
         -- lista de valores genérica
         cur := f_detvalores (1054, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lst_tipoparentesco;

-- Fin Bug 24717 - MDS - 20/12/2012

   -- Incio Bug 0025584 - MMS - 18/02/2013
   /*************************************************************************
      Recupera la lista de Edades por Producto seleccionables
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstedadesprod (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := 'psproduc= ' || psproduc;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_LstEdadesprod';
   BEGIN
      cur :=
         f_opencursor
            (   'SELECT nedamar codi, nedamar descripcion FROM edadmarprod WHERE sproduc = '
             || psproduc,
             mensajes
            );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstedadesprod;

-- Fin Bug 0025584 - MMS - 18/02/2013
 /*************************************************************************
      Bug 24685 2013-feb-05 aeg preimpresos
      Recupera los tipos de asignacion preimpresos
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstpreimpresos (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstpreimpresos';
      terror     VARCHAR2 (200) := 'Error recuperar comisiones por p??liza';
   BEGIN
      cur := f_detvalores (893, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstpreimpresos;

   /*************************************************************************
         Recupera la Lista de distintos gestores filtrado por compa??ia, devuelve un ref cursor
         param in pccompani : codigo de compa??ia
         param out : mensajes de error
         return    : ref cursor
          -- JBN -bUG27650-01/08/2013- Se a??ade funci??n
      *************************************************************************/
   FUNCTION f_get_gestorescompania (
      pccompani   IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vtermfin   VARCHAR2 (100);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := 'par??mtros: pccompani: ' || pccompani;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_LISTVALORES.F_Get_gestorescompania';
      terror     VARCHAR2 (200)  := 'Error recuperar gestorescompania';
      vselect    VARCHAR2 (2000);
   BEGIN
      vselect := 'select * from fic_gestores g ';

      IF pccompani IS NOT NULL
      THEN
         vselect := vselect || 'where g.cempres = ' || pccompani || ' ';
      END IF;

      vselect := vselect || 'order by g.tnombre';
      cur := f_opencursor (vselect, mensajes);
      vpasexec := 2;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_gestorescompania;

    /*************************************************************************
      Recupera la Lista de distintos formatos filtrado por gestor, devuelve un ref cursor
      param in pccompani : codigo de gestor
      param out : mensajes de error
      return    : ref cursor
       -- JBN -bUG27650-01/08/2013- Se a??ade funci??n
   *************************************************************************/
   FUNCTION f_get_formatosgestor (
      pgestor    IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vtermfin   VARCHAR2 (100);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := 'par??mtros: pccompani: ' || pgestor;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.F_Get_formatosgestor';
      terror     VARCHAR2 (200)  := 'Error recuperar formatosgestor';
      vselect    VARCHAR2 (2000);
   BEGIN
      vselect :=
         'select f.*, g.tperiod from fic_formatos f, fic_gestores g where g.tgestor=f.tgestor ';

      IF pgestor IS NOT NULL
      THEN
         vselect := vselect || 'and f.tgestor = ' || pgestor || ' ';
      END IF;

      vselect := vselect || 'order by f.tnombre';
      cur := f_opencursor (vselect, mensajes);
      vpasexec := 2;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_formatosgestor;

      /*************************************************************************
      Recupera la Lista fija para criterio de error, devuelve un ref cursor
      param out : mensajes de error
      return    : ref cursor
       -- JBN -bUG27650-01/08/2013- Se a??ade funci??n
   *************************************************************************/
   FUNCTION f_get_lstprocesoerr (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstprocesoerr';
      terror     VARCHAR2 (200) := 'Error recuperar listado error';
   BEGIN
      cur := f_detvalores (829, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstprocesoerr;

   /*************************************************************************
      Recupera la Lista de los dias del mes, devuelve un ref cursor
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstdias (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstdias';
      terror     VARCHAR2 (200) := 'Error recuperar los dias del mes';
                                            --//ACC recuperar desde literales
   --//ACC recuperar desde literales
   --//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);
   BEGIN
      cur := f_detvalores (8000923, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdias;

      /*************************************************************************
      Recupera las monedas
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/-- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_monedas_todas (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := '';
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_monedas';
      terror     VARCHAR2 (200)  := '';
   BEGIN
      cur :=
         f_opencursor
            (   ' select m.cmoneda, d.tmoneda
  from eco_codmonedas m, eco_desmonedas D
  where   m.CMONEDA = d.CMONEDA and cidioma = '
             || pac_md_common.f_get_cxtidioma (),
             mensajes
            );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_monedas_todas;

     /*************************************************************************
      Recupera las monedas
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/-- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_monedas_todas_cond (
      cond       IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := '';
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_monedas';
      terror     VARCHAR2 (200)  := '';
      vwhere     VARCHAR2 (2000);
   BEGIN
      vwhere := vwhere || ' ' || cond;
      cur :=
         f_opencursor
            (   ' select m.cmoneda, d.tmoneda
    from eco_codmonedas m, eco_desmonedas D
    where cidioma = '
             || pac_md_common.f_get_cxtidioma ()
             || ' and m.CMONEDA = d.CMONEDA '
             || vwhere,
             mensajes
            );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_monedas_todas_cond;

   /*************************************************************************
      Recupera la lista de los posibles valores donde aplica un indicador de compañia
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_caplicaindicadorcia (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                            := 'PAC_MD_LISTVALORES.f_get_caplicaindicadorcia';
      terror     VARCHAR2 (200)
                          := 'Error recuperar valores indicadores compañias';
   BEGIN
      cur := f_detvalores (17001, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_caplicaindicadorcia;

   /*************************************************************************
      Recupera la lista de bancos seg??n los criterios
      param in cbanco : C??digo del banco
      param in tbanco : Descripci??n del banco
   *************************************************************************/
   FUNCTION f_get_lstbancos_pagos (
      pcbanco    IN       NUMBER,
      ptbanco    IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes,
      pcforpag   IN       NUMBER DEFAULT NULL
   --Bug 29224/166661:NSS:24-02-2014
   )
      RETURN sys_refcursor
   IS
      condicion      VARCHAR2 (1000);
      cur            sys_refcursor;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (1000)
         :=    'cbanco= '
            || pcbanco
            || ' tbanco= '
            || ptbanco
            || ' pcforpag= '
            || pcforpag;
      vobject        VARCHAR2 (200)
                                 := 'PAC_MD_LISTVALORES.F_Get_LstBancos_pagos';
      no_hay_datos   EXCEPTION;
      vbanco         NUMBER;
      vtbanco        VARCHAR2 (200);
      vselect        VARCHAR2 (2000);
   BEGIN
      IF pcbanco IS NOT NULL
      THEN
         condicion := ' b.cbanco = ' || pcbanco;
      END IF;

      IF ptbanco IS NOT NULL
      THEN
         condicion :=
            condicion || ' upper(b.tbanco) like ''%' || UPPER (ptbanco)
            || '%''';
      END IF;

      --Ini Bug 29224/166661:NSS:24-02-2014
      IF pcforpag = 34
      THEN
         condicion := condicion || ' b.cgirbap = 1';
      END IF;

      --Fin Bug 29224/166661:NSS:24-02-2014
      vselect := 'select b.cbanco, b.tbanco from bancos b';

      IF condicion IS NOT NULL
      THEN
         vselect := vselect || ' where ' || condicion;
      END IF;

      vselect := vselect || ' order by b.cbanco ';
      cur := f_opencursor (vselect, mensajes);

      IF cur%FOUND
      THEN
         IF cur%ISOPEN
         THEN
            FETCH cur
             INTO vbanco, vtbanco;

            IF cur%NOTFOUND
            THEN
               RAISE no_hay_datos;
            END IF;

            CLOSE cur;
         END IF;
      END IF;

      -- Lo volvemos a abrir ya que el FETCH lo deja sin las filas ya consultadas
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN no_hay_datos
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000254);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstbancos_pagos;

   /*************************************************************************
      Recupera la lista de municipios
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_municipios_pagos (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000);
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_LISTVALORES.f_get_municipios_pagos';
      vselect    VARCHAR2 (2000);
      vnumerr    NUMBER;
   BEGIN
      vnumerr :=
         pac_propio.f_get_municipios_pagos (pac_md_common.f_get_cxtempresa,
                                            vselect
                                           );

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000254);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_municipios_pagos;

-- BUG 0029035 - FAL - 21/05/2014
/*************************************************************************
      Recupera el tipo de persona relacionada
      param in pctipper : tipo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipo_persona_rel (
      pctipper   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)                := 1;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_LISTVALORES.f_get_tipo_persona_rel';
      vcatribu   detvalores.catribu%TYPE;
      vtatribu   detvalores.tatribu%TYPE;
   BEGIN
      cur :=
         f_detvalores_dep (pac_md_common.f_get_cxtempresa,
                           85,
                           pctipper,
                           1037,
                           mensajes
                          );
      vpasexec := 5;

      FETCH cur
       INTO vcatribu, vtatribu;

      vpasexec := 6;

      IF cur%NOTFOUND
      THEN                                                     -- No hay datos
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         cur := f_detvalores (1037, mensajes);
      ELSE
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         cur :=
            f_detvalores_dep (pac_md_common.f_get_cxtempresa,
                              85,
                              pctipper,
                              1037,
                              mensajes
                             );
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            NULL,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipo_persona_rel;

-- FI BUG 0029035 - FAL - 21/05/2014

   /*************************************************************************
      Recupera el tipo de persona relacionada
      param in pctipper : tipo de persona con condicion
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipo_persona_rel_des (
      pctipper   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)                := 1;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_LISTVALORES.f_get_tipo_persona_rel';
      vcatribu   detvalores.catribu%TYPE;
      vtatribu   detvalores.tatribu%TYPE;
      v_cond     VARCHAR2 (2000)           := NULL;
   BEGIN
      cur :=
         f_detvalores_dep (pac_md_common.f_get_cxtempresa,
                           85,
                           pctipper,
                           1037,
                           mensajes
                          );
      vpasexec := 5;

      FETCH cur
       INTO vcatribu, vtatribu;

      vpasexec := 6;

      IF cur%NOTFOUND
      THEN                                                     -- No hay datos
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         v_cond := 'catribu <> 3 ';
         cur := f_detvalorescond (1037, v_cond, mensajes);
      ELSE
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         cur :=
            f_detvalores_dep (pac_md_common.f_get_cxtempresa,
                              85,
                              pctipper,
                              1037,
                              mensajes
                             );
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            NULL,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipo_persona_rel_des;

   -- BUG34603:XBA:17/02/2015:Inici
   /*************************************************************************
      Recupera la Lista de los rankings utilizados para las pignoraciones, devuelve un ref cursor
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_rank_pledge (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_rank_pledge';
      terror     VARCHAR2 (200) := 'Error recuperar el ranking';
   BEGIN
      cur := f_detvalores (8000957, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_rank_pledge;

   -- BUG34603:XBA:17/02/2015:Inici
   /*************************************************************************
      Recupera la Lista de las causas para las pignoraciones, devuelve un ref cursor
      param in pcmotmov  : código de causa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipo_causa (
      pcmotmov   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (100)  := 'pcmotmov: ' || pcmotmov;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_tipo_causa';
      terror     VARCHAR2 (200)  := 'Error al recuperar la causa';
      v_cond     VARCHAR2 (2000) := NULL;
   BEGIN
      IF pcmotmov = 261
      THEN
         --261 - Pignoración de póliza
         v_cond := 'catribu IN (0,1)';
      ELSIF pcmotmov = 262
      THEN
         --262 - Bloqueo póliza
         v_cond := 'catribu = 6';
      ELSIF pcmotmov = 264
      THEN
         --264 - Desbloqueo póliza
         v_cond := 'catribu = 5';
      ELSIF pcmotmov = 263
      THEN
         --263 - Despignoración de póliza
         v_cond := 'catribu IN (2,3)';
      --CONF-274-25/11/2016-JLTS Ini
      ELSIF pcmotmov = 141
      THEN
         --263 - Despignoración de póliza
         v_cond := 'catribu = 7';
      --CONF-274-25/11/2016-JLTS Fin
      ELSE
         --Suspensión póliza
         v_cond := 'catribu = 4';
      END IF;

      cur := f_detvalorescond (8000958, v_cond, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipo_causa;

-- BUG34603:33886/199827
   /*************************************************************************
      Recupera la Lista de las causas montos para desembolsos MSV
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmonto (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_lstmonto_msv';
      v_cond     VARCHAR2 (2000) := NULL;
   BEGIN
      --cur := f_detvalores(8001013, mensajes);
      v_cond := 'catribu in (1,2,7)';
      cur := f_detvalorescond (481, v_cond, mensajes);                  --rdd
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmonto;

   /*************************************************************************
      Recupera la Lista de las causas montos para lstreembolso MSV
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstreembolso (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_LISTVALORES.f_get_lstreembolso_msv';
      v_cond     VARCHAR2 (50);
   BEGIN
      --cur := f_detvalores(8001014, mensajes);
      v_cond := 'catribu >= 7';
      cur := f_detvalorescond (1903, v_cond, mensajes);                 --rdd
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstreembolso;

      /*************************************************************************
      Recupera la Lista de estados de reembolsos MSV
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lststatus (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lststatus_msv';
   BEGIN
      cur := f_detvalores (8001015, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lststatus;

   -- 34866/209952
   FUNCTION f_get_lst_tipocontingencias (
      clave      IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'clave = ' || clave;
      vobject    VARCHAR2 (200)
                         := 'PAC_IAX_LISTVALORES.f_get_lst_tipocontingencias';
      terror     VARCHAR2 (200)
                        := 'No se puede recuperar la información de valores';
      vsql       VARCHAR2 (512)
         :=    'SELECT catribu, tatribu '
            || CHR (10)
            || 'FROM DETVALORES '
            || CHR (10)
            || 'WHERE cidioma = pac_md_common.f_get_cxtidioma() '
            || CHR (10)
            || '  AND CVALOR  = '
            || clave
            || CHR (10)
            || '  AND catribu IN (SELECT CTIPOCON '
            || CHR (10)
            || '                  FROM BENECONTIGPROD  '
            || CHR (10)
            || '                  WHERE SPRODUC = '
            || pac_iax_produccion.poliza.det_poliza.sproduc
            || ') ';
   BEGIN
      cur := f_opencursor (vsql, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lst_tipocontingencias;

      /*************************************************************************
      Recuperar la lista de productos proyeccion provision
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstprodproyp (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lstprodproyp';
   BEGIN
      cur :=
         f_opencursor
            (   'SELECT UNIQUE p.sproduc, t.ttitulo tproduc '
             || 'FROM proy_parametros_mto_pos p, titulopro t, productos p1 '
             || 'WHERE p.sproduc = p1.sproduc '
             || '  AND t.ccolect = p1.ccolect '
             || '  AND t.cmodali = p1.cmodali '
             || '  AND t.cramo = p1.cramo '
             || '  AND t.cidioma = pac_md_common.f_get_cxtidioma '
             || '  AND t.ctipseg = p1.ctipseg',
             mensajes
            );
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstprodproyp;

   /*************************************************************************
      Recuperar la lista de proyeccion provision
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstproyprovis (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_lstprodproyp';
      vselect    VARCHAR2 (2000) := NULL;
   BEGIN
      vselect :=
            'SELECT p.sproduc, t.ttitulo tproduc ,p.cparam, ff_desvalorfijo(8001032, t.cidioma, p.cparam) tparam, p.nanyo, p.nmes, p.ivalor '
         || 'FROM proy_parametros_mto_pos p, titulopro t, productos p1 '
         || 'WHERE p.sproduc = p1.sproduc '
         || '  AND t.ccolect = p1.ccolect '
         || '  AND t.cmodali = p1.cmodali '
         || '  AND t.cramo = p1.cramo '
         || '  AND t.cidioma = pac_md_common.f_get_cxtidioma '
         || '  AND t.ctipseg = p1.ctipseg '
         || '  AND p1.sproduc = '
         || psproduc;
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstproyprovis;

   FUNCTION f_get_lstcampana (pccodigo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_LISTVALORES.f_get_lstcampana';
      vselect    VARCHAR2 (2000) := NULL;
   BEGIN
      vselect := 'SELECT CCODIGO, TDESCRIP FROM CAMPANAS';
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcampana;

   /*************************************************************************
       Recupera la lista de ciiu
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_ciiu (
      codigo      IN       VARCHAR2,
      condicion   IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_ciiu';
      terror     VARCHAR2 (200)  := 'Error recuperar ciiu';
      errores    t_ob_error;
      vnumerr    NUMBER          := 0;
      vselect    VARCHAR2 (2000) := NULL;
   BEGIN
      vselect :=
            'SELECT CCIIU, TCIIU '
         || 'FROM PER_CIIU pc '
         || 'WHERE  cidioma = pac_md_common.f_get_cxtidioma ';

      IF condicion IS NOT NULL
      THEN
         vselect :=
             vselect || ' and UPPER(pc.TCIIU) LIKE ''%' || condicion || '%''';
         vselect := vselect || '  or pc.CCIIU LIKE ''%' || condicion || '%''';
      END IF;

      vselect := vselect || 'order by 1 desc ';
      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ciiu;

---------------------------
 /*************************************************************************
      Recupera las actividades con su descripcion por producto
      param in PCGRUPO  : id. interno de grupo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_activigrupo (
      pcgrupo    IN       VARCHAR,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur          sys_refcursor;
      vpasexec     NUMBER (8)      := 1;
      vparam       VARCHAR2 (100)  := ' PCGRUPO: ' || pcgrupo;
      vobject      VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_activigrupo';
      vsquery      VARCHAR2 (2000);
      vactivi0     NUMBER;
      vcount       NUMBER;
      vcondicion   VARCHAR2 (50);
   BEGIN
      vsquery :=
            'select DISTINCT AC.CACTIVI, AC.TACTIVI from ACTIVISEGU AC, PRODUCTOS P,
DETGRUPODIAN D
where
AC.CIDIOMA = 8
and AC.CRAMO = P.CRAMO
and D.SPRODUC in P.SPRODUC
and D.CGRUPO = '''
         || pcgrupo
         || ''''
         || 'and D.CACTIVI = AC.CACTIVI'
         || ' ORDER BY AC.CACTIVI ASC';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_activigrupo;

    /*************************************************************************
      Recupera la lista de Agrupaciones consorcios
      param in sperson   : codigo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_agrupaciones_consorcios (
      psperson   IN       NUMBER,
      pmodo      IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur               sys_refcursor;
      vpasexec          NUMBER (8)     := 1;
      vparam            VARCHAR2 (100) := 'sperson= ' || psperson;
      vobject           VARCHAR2 (200)
                        := 'PAC_MD_LISTVALORES.F_Get_agrupaciones_consrocios';
      terror            VARCHAR2 (200)
                                 := 'Error recuperar agrupaciones consorcios';
      vselect           VARCHAR2 (200) := '';
      vcount            NUMBER (2)     := 0;
      vcountf           NUMBER         := 0;
      vpparticipacion   NUMBER         := 0;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO vcount
           FROM (SELECT UNIQUE pr.cagrupa, dv.catribu, dv.tatribu
                          FROM per_personas_rel pr, detvalores dv
                         WHERE sperson = psperson
                           AND dv.cvalor = 8002007
                           AND dv.catribu = pr.cagrupa);
                                                      --TCS 468A 17/01/2019 AP
      EXCEPTION
         WHEN OTHERS
         THEN
            vcount := 0;
      END;

      IF vcount IS NULL
      THEN
         vcount := 0;
      END IF;

      BEGIN
         SELECT SUM (pparticipacion)
           INTO vpparticipacion
           FROM per_personas_rel
          WHERE sperson = psperson AND cagrupa = (SELECT MAX (cagrupa)
                                                    FROM per_personas_rel
                                                   WHERE sperson = psperson);
      EXCEPTION
         WHEN OTHERS
         THEN
            vpparticipacion := 0;
      END;

      --
      IF vpparticipacion IS NULL
      THEN
         vpparticipacion := 0;
      END IF;

      IF pmodo = 'ORIGINAL'
      THEN
         vselect :=
               'SELECT * FROM DETVALORES WHERE  CVALOR = 8002007 AND CIDIOMA = 8 AND CATRIBU  <= '
            || vcount
            || '';
      ELSIF pmodo = 'VALIDACION'
      THEN
         IF vcount = 0 OR vpparticipacion = 100 AND vcount != 0
         THEN
            vcount := vcount + 1;
            vselect :=
                  'SELECT * FROM DETVALORES WHERE  CVALOR = 8002007 AND CIDIOMA = 8 AND CATRIBU  <= '
               || vcount
               || '';
         ELSE
            vselect :=
                  'SELECT * FROM DETVALORES WHERE  CVALOR = 8002007 AND CIDIOMA = 8 AND CATRIBU  <= '
               || vcount
               || '';
         END IF;
      END IF;

      cur := f_opencursor (vselect, mensajes);
      RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agrupaciones_consorcios;

     -- Ini-QT-1704
   /*************************************************************************
        Recupera los ramos con su descripcion para convenios CONF
        param in pcempres  : empresa
        param out mensajes : mensajes de error
        return             : ref cursor
     *************************************************************************/
   FUNCTION f_get_cramo_conv (
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (10)   := pcempres;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_cramo_emp_conv';
      vsquery    VARCHAR2 (2000);
   BEGIN
      vsquery :=
            'select r.cramo,r.tramo
                   from ramos r, codiram c
                  where r.cidioma = '
         || pac_md_common.f_get_cxtidioma
         || ' and c.cramo = r.cramo and r.cramo in(801,802)
                   and c.cempres = '
         || NVL (TO_CHAR (pcempres), 'null')
         || ' order by r.tramo';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cramo_conv;

   -- Fin-QT-1704
    --INI WAJ
   /*************************************************************************
      Recupera lista de tipos de vinculos
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstvinculos (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_LstVinculos';
      terror     VARCHAR2 (200) := 'Error recuperar comisiones por p??liza';
   BEGIN
      cur := f_detvalores (328, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstvinculos;

    /*************************************************************************
      Recupera lista de tipos de compañia
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipcomp (mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.f_get_lsttipcomp';
      terror     VARCHAR2 (200) := 'Error recuperar comisiones por p??liza';
   BEGIN
      cur := f_detvalores (800102, mensajes);
      RETURN cur;
   EXCEPTION
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipcomp;

   --FIN WAJ

   -- Ini  TCS_827 - ACL - 17/02/2019
    /*************************************************************************
      Recupera el ramo de cumplimiento
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramo_contrag (
      p_tipo     IN       VARCHAR2,
      pcempres   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_LISTVALORES.f_get_ramo_contrag';
      terror     VARCHAR2 (200)  := 'Error recuperar ramos';
      vtipo      VARCHAR2 (2000);
      vempresa   VARCHAR2 (2000);
      v_squery   VARCHAR2 (2000);
      vcontrol   NUMBER;
   BEGIN
      IF pac_productos.f_get_filtroprod (p_tipo, vtipo) <> 0
      THEN
         RAISE e_param_error;
      END IF;

      IF p_tipo = 'TF'
      THEN
         vcontrol := 2;
      ELSE
         vcontrol := 6;
      END IF;

      IF p_tipo = '14'
      THEN
         cur :=
            f_opencursor
               (   'select distinct r.cramo, r.tramo from codiram c, ramos r, productos p '
                || 'where r.cidioma = '
                || pac_md_common.f_get_cxtidioma
                || ' and r.cramo = p.cramo'
                || ' and c.CRAMO = r.CRAMO'
                || ' and c.CEMPRES = '
                || pcempres
                || ' and r.cramo = 801 '
                || ' and'
                || vtipo
                || ' 1=1 '
                || ' order by r.tramo',
                mensajes
               );
      ELSE
         cur :=
            f_opencursor
               (   'select distinct r.cramo, r.tramo from codiram c, ramos r, productos p '
                || 'where r.cidioma = '
                || pac_md_common.f_get_cxtidioma
                || ' and r.cramo = p.cramo'
                || ' and c.CRAMO = r.CRAMO'
                || ' and c.CEMPRES = '
                || pcempres
                || ' and r.cramo = 801 '
                || ' and'
                || vtipo
                || ' PAC_PRODUCTOS.f_prodagente (p.sproduc,'
                || pac_md_common.f_get_cxtagente
                || ','
                || vcontrol
                || ')=1'
                || ' order by r.tramo',
                mensajes
               );
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ramo_contrag;

   -- Fin  TCS_827 - ACL - 17/02/2019
   --INI IAXIS-2085 18/03/2019 AP
    /*************************************************************************
      Recupera la Lista de agrupaciones, devuelve un ref cursor
      param in pcagente : codigo de agente
      param out : mensajes de error
      return    : ref cursor
    *************************************************************************/
   FUNCTION f_get_agrupa_consorcios (
      psperson   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_LISTVALORES.f_get_agrupa_consorcios';
      terror     VARCHAR2 (200)  := 'Error recuperar ramos';
      vtipo      VARCHAR2 (2000);
      vempresa   VARCHAR2 (2000);
      vsquery    VARCHAR2 (2000);
      vcontrol   NUMBER;
   BEGIN
      vsquery :=
            'SELECT DISTINCT D.CATRIBU, D.TATRIBU, SUM(P.PPARTICIPACION) FROM PER_PERSONAS_REL P, DETVALORES D WHERE D.CATRIBU = P.CAGRUPA 
          AND D.CVALOR = 8002007 AND D.CIDIOMA = 8 AND P.CAGRUPA <>0 AND P.SPERSON = '
         || psperson
         || ' GROUP BY D.CATRIBU, D.TATRIBU
          HAVING  SUM(P.PPARTICIPACION) = 100';
      cur := f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            terror,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agrupa_consorcios;

   --FIN IAXIS-2085 18/03/2019 AP
   FUNCTION f_get_prodactividad (
      pcramo     IN       activiprod.cramo%TYPE,
      pcactivi   IN       activiprod.cactivi%TYPE,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec      NUMBER (8)      := 1;
      vparam        VARCHAR2 (300)
          := 'par??metros - pcramo: ' || pcramo || ', pcactivi: ' || pcactivi;
      vobject       VARCHAR2 (200)
                                  := 'PAC_MD_LISTVALORES.F_Get_Prodactividad';
      cur           sys_refcursor;
      v_sentencia   VARCHAR2 (5000) := NULL;
      v_cidioma     NUMBER          := pac_md_common.f_get_cxtidioma ();
   BEGIN
      -- INI - IAXIS-5100 - JLTS - 23/08/2019
      v_sentencia :=
            'SELECT DISTINCT p.cgrupo || '' - '' || s.ttitulo pre, p.cgrupo '
         || '  FROM activiprod p, activisegu s '
         || ' WHERE nvl(p.cactivo, 1) = 1 '
         || '   AND p.cactivi = s.cactivi '
         || '   AND s.cramo = s.cramo '
         || ' AND s.cidioma = '
         || v_cidioma
         || ' AND p.cramo = s.cramo '
         || ' AND  p.cgrupo is not null ';

      -- FIN - IAXIS-5100 - JLTS - 23/08/2019
      IF pcramo IS NULL
      THEN
         RAISE e_param_error;
      ELSE
         v_sentencia := v_sentencia || ' AND p.cramo =' || pcramo;
      END IF;

      IF pcactivi IS NOT NULL
      THEN
         v_sentencia := v_sentencia || ' AND s.cactivi = ' || pcactivi;
      END IF;

      v_sentencia :=
                 v_sentencia || ' ORDER BY substr(pre, 1, 2), substr(pre, 6) ';
      cur := f_opencursor (v_sentencia, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000022,
                                            vpasexec,
                                            vparam
                                           );
         RETURN cur;
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

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_prodactividad;
END pac_md_listvalores;
/
