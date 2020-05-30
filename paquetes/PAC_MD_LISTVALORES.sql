CREATE OR REPLACE PACKAGE pac_md_listvalores AS
   /******************************************************************************
      NOMBRE:       PAC_MD_LISTVALORES
      PROP?SITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor  Descripci?n
      ---------  ----------  ------  ------------------------------------
      1.0        25/01/2008   ACC    1. Creaci?n del package.
                 04/04/2008   JRH    Tarea ESTPERSONAS
                 11/02/2009   FAL    Cobradores, delegaciones. Bug: 0007657
                 11/02/2009   FAL    Tipos de apunte, Estado apunte, en/de la agenda. Bug: 0008748
                 12/02/2009   AMC    Siniestros de baja. Bug: 9025
                 06/03/2009   JSP    Agenda de poliza. Bug: 0009208
      2.0        27/02/2009   RSC    Adaptaci?n iAxis a productos colectivos con certificados
      3.0        11/03/2009   RSC    An?lisis adaptaci?n productos indexados
      5.0        11/03/2009   SBG    Nou par?m. p_tmode funci? p_ompledadesdireccions (Bug 7624)
      6.0        24/04/2009   AMC    Bug 9585 Se a?ade el pcempres a la funci?n f_get_ramos
      7.0        06/05/2009   ICV    009940: IAX - Pantalla para lanzar maps
      8.0        11/05/2009   ICV    0009784: IAX - An?lisis y desarrollo de Rehabilitaciones
      9.0        23/04/2009   FAL    Parametrizar tipos de anulaci?n de poliza en funci?n de la configuraci?n de acciones del usuario y del producto. Bug 9686.
     10.0        01/10/2009   JRB    0011196: CRE - Gesti?n de propuestas retenidas
     11.0        07/10/2009   ICV    0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
     12.0        15/12/2009   JTS      10831: CRE - Estado de p?lizas vigentes con fecha de efecto futura
     13.0        18/02/2010   JMF    0012679 CEM - Treure la taula MOVRECIBOI
     14.0        22/03/2010   JTS    0013477: CRE205 - Nueva pantalla de Gesti?n Pagos Rentas
     15.0        10/05/2010   RSC    0011735: APR - suplemento de modificaci?n de capital /prima
     16.0        04/06/2010   PFA    14588: CRT001 - A?adir campo compa?ia productos
     17.0        18/06/2010   AMC    Bug 15148 - Se a?aden nuevas funciones
     18.0        21/06/2010   AMC    Bug 15149 - Se a?aden nuevas funciones
     19.0        09/08/2010   AVT    15638: CRE998 - Multiregistre cercador de p?lisses (Asegurat)
     20.0        20/09/2010   JRH    20. 0015869: CIV401 - Renta vital?cia: incidencias 12/08/2010
     21.0        06/10/2010   ICV    0015106: AGA003 - mantenimiento para la gesti?n de cobradores
     22.0        17/08/2010   PFA    Bug 15006: MDP003 - Incluir nuevos campos en b?squeda siniestros
     23.0        25/08/2011   DRA    0019169: LCOL_C001 - Campos nuevos a a?adir para Agentes.
     24.0        30/06/2011   LCF    Bug 18855: LCOL003 - Permitir seleccionar el c?digo de agente en simulaciones
     25.0        02/09/2011   DRA    0018752: LCOL_P001 - PER - An?lisis. Mostrar los tipos de documento en funci?n del tipo de persona.
     26.0        20/09/2011   JMP    0019130: LCOL_T002-Agrupacion productos - Productos Brechas 01
     27.0        22/09/2011   JMP    0019197: LCOL_A001-Liquidacion de comisiones para colombia: sucursal/ADN y corte de cuentas (por el liquido)
     28.0        03/10/2011   APD    0018319: LCOL_A002- Pantalla de mantenimiento del contrato de reaseguro
     29.0        03/10/2011   ETM    BUG 0017383: ENSA101 - Prestacions i altes.Cobrador bancari
     30.0        26/09/2011   DRA    0019069: LCOL_C001 - Co-corretaje
     31.0        08/11/2011   JGR    0019985  LCOL_A001-Control de las matriculas (prenotificaciones)
     32.0        11/11/2011   APD    0019169: LCOL_C001 - Campos nuevos a a?adir para Agentes.
     33.0        10/02/2012   JGR    0020735: LCOL_A001-ADM - Introduccion de cuenta bancaria. Nota:0103205 f_get_lsttipcc
     34.0        17/01/2012   JGR    0020735 - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
     35.0        06/06/2012   APD    0021682: MDP - COM - Transiciones de estado de agente.
     36.0        25/07/2012   JGR    0022082: LCOL_A003-Mantenimiento de matriculas
     37.0        14/08/2012   DCG    0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
     38.0        30/10/2012   XVM    0024058: LCOL_T010-LCOL - Parametrizaci?n de productos Vida Grupo
     39.0        20/12/2012   MDS    0024717: (POSPG600)-Parametrizacion-Tecnico-Descripcion en listas Tipos Beneficiarios RV - Cambiar descripcion en listas Tipos Beneficiar
     68.0        18/02/2013   MMS    0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza Ã¢â‚¬Ëœhasta edadÃ¢â‚¬â„¢ y edades permitidas por producto. AÃƒÂ±adir f_get_lstedadesprod
     41.0        04/03/2013   AEG    0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
     42.0        22/08/2013   DEV    0026443: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 76 -XL capacidad prioridad dependiente del producto (Fase3)
     43.0        19/12/2013   DCT    0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
     44.0        07/02/2014   AGG    0030057: POSPG400-Env?o de Indicadores de compa??as a SAP
     45.0        21/05/2014   FAL    0029035: TRQ000 - Mesa CROSS (personas, usuarios, perfiles)
     46.0        22/09/2014   CASANCHEZ  0032668: COLM004-Trapaso entre Bancos (cobrador bancario) manteniendo la nÃƒÂ³mina
     47.0        17/02/2015   XBA    0034603: Recupera la Lista de las causas para las pignoraciones
     48.0        12/09/2016   ASDQ   CONF-209-GAP_GTEC50 - Productos multimoneda
     49.0        03/05/2018   VCG    QT-0001704: Listado de Ramos para Convenios
     50.0        14/01/2019    WAJ   Listado de tipos de vinculos y tipos de compañias
     51.0        27/02/2019   ACL    TCS_827 Se agrega la función f_get_ramo_contrag.
     52.0        30/09/2019   JMJRR  IAXIS-5378. Se crea función para retornar detvalores ajustado a parametro de perfilamiento
     53.0        28/10/2019   SGM    IAXIS-6149: Realizar consulta de personas publicas		
   ******************************************************************************/

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la informaci?n de valores seg?n la clave
      param in clave     : clave a recuperar detalles
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalores(clave IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la informaci?n de valores seg?n la clave y la condici?n
      param in clave     : clave a recuperar detalles
      param in cond      : condici?n de la consulta (sin where ni and)
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalorescond(clave IN NUMBER, cond IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recupera la informaci??n de valores seg??n la clave y la condici??n
      param in clave     : clave a recuperar detalles
      param in cond      : condici??n de la consulta
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalorescond_fil(
      clave IN NUMBER,
      cond IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera descripci?n de detvalores
      param in clave        : c?digo de la tabla
      param in valor        : c?digo del valor a recuperar
      param in out mensajes : mesajes de error
      return                : descripci?n del valor
   *************************************************************************/
   FUNCTION f_getdescripvalores(
      clave IN NUMBER,
      valor IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera el campo de la sentencia
      param in squery       : sentencia sql
      param in out mensajes : mesajes de error
      return                : descripci?n del valor
   *************************************************************************/
   FUNCTION f_getdescripvalor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera la Lista de distintos ramos, devuelve un ref cursor
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- AMC-Bug9585-24/04/2009- Se a?ade el pcempres
   FUNCTION f_get_ramosagente(
      pcagente IN NUMBER,
      p_tipo IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de distintos ramos, devuelve un ref cursor
      param in tipo : codigo de tipo agente
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- AMC-Bug9585-24/04/2009- Se a?ade el pcempres
   FUNCTION f_get_ramos(p_tipo IN VARCHAR2, pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los productos pertenecientes al ramo
      param in pcramo    : c?digo de ramo
      param in pctermfin : 1=los productos contratables des Front-Office / 0=todos
      param out mensajes : mensajes de error
      param in pcagente  : codigo de agente
      param in pcmodali  : codigo de modalidad
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramproductos(
      p_tipo IN VARCHAR2,
      pcramo NUMBER,
      pctermfin IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcagente IN NUMBER DEFAULT NULL,
      pcmodali IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de domicilios de la persona
      param in sperson   : c?digo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstdomiperson(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los estados de la persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcestper(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los tipos de vinculos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipovinculos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los tipos de comisi?n
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcomision(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Recupera la lista de idiomas seleccionables
   -- param out mensajes : mensajes de error
   -- return             : ref cursor
   FUNCTION f_get_lstidiomas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera lista de comisiones permitidas por p?liza
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcomisiones(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de agentes seg?n los criterios
      Recupera la lista de agentes seg?n los criterios
      param in numide : numero documento persona
      param in nombre : texto que incluye nombre + apellidos
   *************************************************************************/
   FUNCTION f_get_lstagentes(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      pcagente IN NUMBER,
      pformato IN NUMBER,
      pctipage IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      Recupera las monedas sin validar visali
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/-- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_monedas_todas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de valores del desplegable sexo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipsexo(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de productos contractables
      param in p_tipo    : Tipo de productos requeridos:
                           'TF'         ---> Contratables des de Front-Office
                           'REEMB'      ---> Productos de salud
                           'APOR_EXTRA' ---> Con aportaciones extra
                           'SIMUL'      ---> Que puedan tener simulaci?n
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
   FUNCTION f_get_productos(
      p_tipo IN VARCHAR2,
      p_cempres IN NUMBER,
      p_cramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcagente IN NUMBER DEFAULT NULL,
      pcmodali IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera lista de situaciones p?liza
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_sitpoliza(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera lista tipos cuentas bancarias
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipccc(
      mensajes IN OUT t_iax_mensajes,
      pctipocc NUMBER
            DEFAULT NULL   -- 08/11/2011 0019985 LCOL_A001-Control de las matriculas (prenotificaciones)
                        )
      RETURN sys_refcursor;

--Ini BUG 14588 - PFA -  CRT001 - A?adir campo compa?ia productos
/*************************************************************************
      Recupera lista cias productos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ciaproductos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

--Fin BUG 14588 - PFA -  CRT001 - A?adir campo compa?ia productos
-- Bug 15869 - 20/09/2010 - JRH - Rentas CIV 2 cabezas
   /*************************************************************************
      Recupera lista con los motivos de siniestros
      param in ccausa   : c?digo causa de siniestro
      param in cramo   : ramo
       param in psproduc   : Producto
      param in psseguro   : Seguro
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_motivossini(
      ccausa IN NUMBER,
      cramo IN NUMBER,
      psproduc IN NUMBER,
      psseguro NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fi Bug 15869 - 20/09/2010 - JRH
   /*************************************************************************
      Recupera la lista con las causas de siniestros
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_causassini(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista con los motivos de retencion
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_gstpolretmot(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de responsabilidad de siniestros
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_responsabilidasini(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los tipus de anulaci?n de p?lizas (VF 553)
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipanulpol(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las causas de anulacion
      param in psproduc  : c?digo de producto
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_causaanulpol(
      psproduc IN NUMBER,
      pctipbaja IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recupera los motivos de anulacion
      param in pcmotmov  : c?digo de causa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_motanulpol(pcmotmov IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG 9686 - 23/04/2009 - FAL - A?adir par?metro psproduc
      /*************************************************************************
         Recupera los tipus de anulaci?n de p?lizas (VF 553)
         param in psproduc  : c?digo de producto
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
   FUNCTION f_get_tipanulpol(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- FI BUG 9686 - 23/04/2009 - FAL

   --BUG 0024058: XVM :30/10/2012--INI. AÃƒÂ±adir psproduc
   /*************************************************************************
      Recupera los tipus cobro de la poliza (VF 552) o los que tenga por defecto
      param in psproduc  : cÃƒÂ³digo de producto
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipocobro(mensajes IN OUT t_iax_mensajes, psproduc IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los sub agentes del agente de la p?liza
      param in cagente   : c?digo agente principal de la p?liza
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_subagentes(cagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera el nombre del tomador de la p?liza seg?n el orden
      param in sseguro   : c?digo seguro
      param in nordtom   : orden tomador
      return             : nombre tomador
   *************************************************************************/
   FUNCTION f_get_nametomador(sseguro IN NUMBER, nordtom IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera el nnumide del tomador de la p?liza seg?n el orden
      param in sseguro   : c?digo seguro
      param in nordtom   : orden tomador
      return             : nombre tomador
   *************************************************************************/
-- 15638 AVT 08-09-2010
   FUNCTION f_get_nameasegurado(sseguro IN NUMBER, nordtom IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera el nnumide del asegurado de la p?liza seg?n el orden
      param in sseguro   : c?digo seguro
      param in nordtom   : orden asegurado
      return             : nombre asegurado
   *************************************************************************/
   FUNCTION f_get_numidetomador(psseguro IN NUMBER, pnordtom IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera la situaci?n de la p?liza
      param in sseguro   : c?digo seguro
      return             : situaci?n
   *************************************************************************/
   FUNCTION f_get_situacionpoliza(psseguro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera la estado de la p?liza (retenida)
      param in creteni   : c?digo de retenci?n
      return             : situaci?n
   *************************************************************************/
   FUNCTION f_get_retencionpoliza(creteni IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Motivos de rechazo de la p?liza
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_motivosrechazopol
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar tipos de documentos VF 672
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipdocum(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar tipos de personas VF 85
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipperson(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar estados de un siniestro (VF. 6)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_estadossini(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar subestados de un siniestro (VF. 665)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_subestadossini(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar estados de un reembolso (VF. 891)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_estadosreemb(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG 7624 - 20/04/2009 - SBG - S'afegeix par?m. p_tmode
   /***********************************************************************
      Dado un identificativo de domicilio llena el objeto direcciones
      param in sperson       : c?digo de persona
      param in cdomici       : c?digo de domicilio
      param in p_tmode       : modo (EST/POL)
      param in out obdirecc  : objeto direcciones
      param in out mensajes  : mensajes de error
   ***********************************************************************/
   PROCEDURE p_ompledadesdireccions(
      sperson IN NUMBER,
      cdomici IN NUMBER,
      p_tmode IN VARCHAR2 DEFAULT 'POL',
      obdirecc IN OUT ob_iax_direcciones,
      mensajes IN OUT t_iax_mensajes);

   -- FINAL BUG 7624 - 20/04/2009 - SBG

   /***********************************************************************
      Devuelve la descripci?n del vinculo
      param in pcvincle       : c?digo vinculo
      param in out mensajes  : mensajes de error
   ***********************************************************************/
   FUNCTION f_getdescvincle(pcvincle IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve la descripci?n del tipo de cuenta bancaria
      param in psperson      : c?digo persona
      param in pcbancar      : cuenta bancaria
      param in out mensajes  : mensajes de error
   ***********************************************************************/
   FUNCTION f_gettipban(
      psperson IN NUMBER,
      pcbancar IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recuperar la lista de empresas
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstempresas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de agrupaciones de productos
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagrupprod(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de los posibles valores del campo productos.cactivo
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstactivo(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctermfin
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstterfinanciero(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctiprie
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipriesgo(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

     -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en b?squeda siniestros
    /*************************************************************************
      Recuperar la lista de posibles valores del campo tiporiesgo
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tiporiesgo(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

     --Fi Bug 15006 - PFA - 16/08/2010 - nuevos campos en b?squeda siniestros
   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctiprie
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcobjase(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.csubpro
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcsubpro(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cprprod
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcprprod(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cdivisa
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstdivisa(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cduraci
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcduraci(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctempor
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctempor(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctempor
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcdurmin(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcdurmax(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipefe(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcrevali(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctarman(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstsino(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcreteni(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcprorra(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcprimin(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstformulas(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ctipges
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipges(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos creccob
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcreccob(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ctipreb
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipreb(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ccalcom
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccalcom(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ctippag
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctippag(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de garant?a (VF 33)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipgar(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de capital garant?a (VF 34)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipcapgar(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de capital m?ximo garant?a  (VF 35)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcapmaxgar(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de tarifas garant?a  (VF 48)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttiptargar(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de reaseguro de garant?a  (VF 134)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstreagar(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de revalorizaciones de garant?a  (VF 279)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstrevalgar(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
       /*************************************************************************
          Recupera los paises
          param out mensajes : mensajes de error
          return             : ref cursor
       *************************************************************************/
   FUNCTION f_get_lstpaises(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
     /*************************************************************************
          Recupera las profesiones
           param in mensajes : mensajes de error
          return            : ref cursor
       *************************************************************************/
   FUNCTION f_get_lstprofesiones(mensajes IN OUT t_iax_mensajes, cocupacion IN  NUMBER DEFAULT 0)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
     /*************************************************************************
          Recupera los tipos de cuents
           param in mensajes : mensajes de error
          return            : ref cursor
       *************************************************************************/
   FUNCTION f_get_lsttipocuenta(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
     /*************************************************************************
          Recupera los tipos de direcci?n
           param in mensajes : mensajes de error
          return            : ref cursor
       *************************************************************************/
   FUNCTION f_get_lsttipodireccion(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
     /*************************************************************************
          Recupera los tipos de v?a
           param in mensajes : mensajes de error
          return            : ref cursor
       *************************************************************************/
   FUNCTION f_get_lsttipovia(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
       /*************************************************************************
          Recupera la consulta de pobl., provin.
          param out mensajes : mensajes de error
          return             : ref cursor
       *************************************************************************/
   FUNCTION f_get_consulta(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --SGM IAXIS-6149 28/10/2019
       /*************************************************************************
          Recupera la consulta de personas publicas
          param out mensajes : mensajes de error
          return             : ref cursor
       *************************************************************************/
   FUNCTION f_get_publicinfo(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
   /*************************************************************************
      Recupera los diferentes niveles que hay de intereses o gastos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstnivel(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los diferentes cuadros que existen a d?a de hoy
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstncodint(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los diferentes tipos de inter?s que puede tener un cuadro de inter?s.
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipinteres(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los diferentes conceptos de tramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ctramtip(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera los LITERALES
          param IN pcidioma : Filtrado por IDIOMA
          param out MSJ : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_literales(pcidioma IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera los Tipos de recibo
          (Detvalores.cvalor=8)
          param out mensajes : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctiprec(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera los Estados de recibo
          (Detvalores.cvalor=1)
          param out mensajes : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstestadorecibo(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera los c?digos y la descripciones de los tipos de IVA definidos.
          param out MSJ : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipoiva(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera c?digo y la descripci?n de los tipos de retenci?n definidos
          param out MSJ : mensajes de error
          return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstretencion(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera c?digo de estado de agente y descripci?n.
          param out MSJ : mensajes de error
          return : ref cursor
   *************************************************************************/
   -- Bug 19169 - APD - 15/09/2011 - se a?ade al parametro pcempres, pcvalor, pcatribu
   -- Bug 21682 - APD - 24/04/2012 - se a?ade al parametro pctipage (sustituye a pcatribu), pcactivo
   FUNCTION f_get_lstestadoagente(
      pcempres IN NUMBER,
      pcvalor IN NUMBER,
--      pcatribu IN NUMBER,
      pctipage IN NUMBER,
      pcactivo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera c?digo de tipo de agente y descripci?n.
          param out MSJ : mensajes de error
          return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipoagente(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera c?digo y descripci?n de las diferentes comisiones definidas para los agentes.
          param out MSJ : mensajes de error
          return : ref cursor
   *************************************************************************/
   -- Bug 19169 - APD - 15/09/2011 - se a?ade al parametro pctipo
   FUNCTION f_get_lstagecomision(pctipo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de los meses del a?o, devuelve un ref cursor
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmeses(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***************NUEVAS JGM 27-08-2008**********************************************************/

   /*Esta funci?n tendr? un par?metro de salida t_iax_mensajes con los posibles mensajes de error y
   nos devolver? un sys_refcursor con el c?digo del tipo de cierre activo y su descripci?n.
        param IN pcempres : Filtrado por empresa
        param IN OUT msj : mensajes de error
        return             : ref cursor
   */
   FUNCTION f_get_lsttipocierre(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*Esta funci?n tendr? un par?metro de entrada PPREVIO y un par?metro de salida t_iax_mensajes con los posibles
   mensajes de error y nos devolver? un sys_refcursor con los diferentes c?digo de estado de cierre activo y su descripci?n.
      param IN previo : par?metro para mostrar o no el estado PREVIO PROGRAMADO
      param IN OUT msj : mensajes de error
      return             : ref cursor
   */
   FUNCTION f_get_lstestadocierre(pprevio IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*Esta funci?n tendr? un par?metro de entrada PPREVIO y un par?metro de salida t_iax_mensajes con los posibles
   mensajes de error y nos devolver? un sys_refcursor con los diferentes c?digo de estado de cierre activo y su descripci?n.
   no sacar? los estados CERRADO y PENDIENTE
      param IN previo : par?metro para mostrar o no el estado PREVIO PROGRAMADO
      param IN OUT msj : mensajes de error
      return             : ref cursor
   */
   FUNCTION f_get_lstestadocierre_nuevo(pprevio IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- ini t.7661
   /*************************************************************************
      Recupera la Lista de compa??as de reaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcia_rea(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de los tipos de reaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipo_rea(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de las agrupaciones de reaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagr_rea(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- fin t.7661

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   /*************************************************************************
      Recupera la Lista de compa??as de coaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_coaseguradoras(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fin Bug 0023183

   /*************************************************************************
      Recupera los ramos con su descripcion por empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cramo_emp(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los productos con su descripcion por ramo
      param in pcramo    : ramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_productos_cramo(pcramo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las actividades con su descripcion por producto
      param in psproduc  : id. interno de producto
      param in pcramo    : ramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cactivi(psproduc IN NUMBER, pcramo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las garantias con su descripcion por producto y actividad
      param in psproduc  : id. interno de producto
      param in pcramo    : ramo
      param in pcactivi  : actividad
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cgarant(
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las garantias con su descripcion por poliza
      param in p_npoliza : numero de poliza
      param out mensajes : mensajes de error
      return             : ref cursor

   *************************************************************************/
   FUNCTION f_get_cgarant_pol(p_npoliza IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las garantias con su descripcion por siniestro
      param in p_nsinies: numero de siniestro
      param out mensajes : mensajes de error
      return             : ref cursor

   *************************************************************************/
   FUNCTION f_get_cgarant_sin(p_nsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la descripci?n de una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_desempresa(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera lista de c?digo+descripci?n cuenta contable.
      param out msj : mensajes de error
      return        : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcuentacontable(msj IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de tipo de concepto contable y su descripci?n.
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstconceptocontable(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera lista de c?digo+descripci?n asiento contable.
      param in p_empresa : c?digo de empresa
      param out msj      : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstasiento(p_empresa IN NUMBER, msj IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los cobradores y cuentas de domiciliaci?n vigentes para una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor

      11/02/2009   FAL                Cobradores, delegaciones. Bug: 0007657
   *************************************************************************/
   FUNCTION f_get_lstcobradores(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las delegaciones de una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor

      11/02/2009   FAL                Cobradores, delegaciones. Bug: 0007657
   *************************************************************************/
   FUNCTION f_get_lstdelegaciones(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera c?digo de tipo de apunte en la agenda y descripci?n.
          param out mensajes : mensajes de error
          return : ref cursor

             11/02/2009   FAL                Tipos de apunte en agenda. Bug: 0008748
   *************************************************************************/
   FUNCTION f_get_lsttipoapuntesagenda(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera estados de apunte en la agenda y descripci?n.
          param out mensajes : mensajes de error
          return : ref cursor

             11/02/2009   FAL                Tipos de apunte en agenda. Bug: 0008748
   *************************************************************************/
   FUNCTION f_get_lstestadosapunteagenda(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera los conceptos de apunte en la agenda y descripci?n.
          param out mensajes : mensajes de error
          return : ref cursor

             06/03/2009   JSP                Conceptos de apunte en agenda. Bug: 0009208
   *************************************************************************/
   FUNCTION f_get_lstconceptosapunteagenda(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera usuarios de la agenda y descripci?n.
          param out mensajes : mensajes de error
          return : ref cursor

             06/03/2009   JSP                Conceptos de apunte en agenda. Bug: 0009208
   *************************************************************************/
   FUNCTION f_get_lstusuariosagenda(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera els graus de minusvalia
          param out mensajes : mensajes de error
          return : ref cursor

             16/03/2009   XPL                Mant. Pers. IRPF. Bug: 0007730
   *************************************************************************/
   FUNCTION f_get_lstgradominusvalia(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera les situacions familiars
          param out mensajes : mensajes de error
          return : ref cursor

             16/03/2009   XPL                Mant. Pers. IRPF. Bug: 0007730
   *************************************************************************/
   FUNCTION f_get_lstsitfam(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera el nombre del tomador de la p?liza seg?n el orden
       param in sseguro   : c?digo seguro
       param in nordtom   : orden tomador
       return             : nombre tomador
    *************************************************************************/-- Bug 8745 - 27/02/2009 - RSC - Adaptaci?n iAxis a productos colectivos con certificados
   FUNCTION f_get_nametomadorcero(psseguro IN NUMBER, nordtom IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera los perfiles de inversi?n de un producto.
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   -- Bug 9031 - 11/03/2009 - RSC - An?lisis adaptaci?n productos indexados
   FUNCTION f_get_perfiles(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los fondos de inversi?n asociados a una empresa.
      param in pcempres  : Empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   -- Bug 9031 - 11/03/2009 - RSC - An?lisis adaptaci?n productos indexados
   FUNCTION f_get_fondosinversion(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera las actividades profesionales
       param out mensajes : mensajes de error
       return : ref cursor

          30/03/2009   XPL                 Sinistres.  Bug: 9020
   *************************************************************************/
   FUNCTION f_get_lstcactprof(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera c?digo del map y su descripci?n
      param out mensajes : mensajes de error
      return             : ref cursor

          06/05/2009   ICV                 Maps.  Bug: 9940
   *************************************************************************/
   FUNCTION f_get_ficheros(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera c?digo del motivo de rehabilitaci?n y la descripci?n del motivo.
      param in  psproduc : Identificador del producto.
      param out mensajes : mensajes de error
      return             : ref cursor

          11/05/2009   ICV                 Maps.  Bug: 9784
   *************************************************************************/
   FUNCTION f_get_motivosrehab(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de distintas agrupacions por producto pasandole la empresa, devuelve un ref cursor
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- XPL -Bug10317-29/06/2009- Se a?ade el pcempres
   FUNCTION f_get_agrupaciones(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de distintos ramos filtrado por agrupacion, devuelve un ref cursor
      param in pcempres : codigo de empresa
      param in pcagrupacion : codigo de agrupacion
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- XPL -Bug10317-29/06/2009- Se a?ade funci?n
   FUNCTION f_get_ramosagrupacion(
      pcempres IN NUMBER,
      pcagrupacion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista del codigo de concepto y descripci?n de las cuentas tecnicas
      param out : mensajes de error
      return    : ref cursor
       -- XPL -Bug10671-09/07/2009- Se a?ade funci?n
   *************************************************************************/
   FUNCTION f_get_lstconcep_cta(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las posibles ubicaciones (debe/haber) d?nde imputar el importe del asiento
      del concepto recibido por par?metro de la cuenta y su descripci?n.
      param in pcconcepto: concepto
      param out mensajes : mensajes de error
      return    : ref cursor
       -- XPL -Bug10671-09/07/2009- Se a?ade funci?n
   *************************************************************************/
   FUNCTION f_get_lsttipo_cta(pcconcepto IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los procesos de liquidaci?n pendientes de cerrar seg?n la empresa seleccionada
      param in pcempres: codi empresa
      param out mensajes : mensajes de error
      return    : ref cursor
       -- XPL -Bug10672-15/07/2009- Se a?ade funci?n
   *************************************************************************/
   FUNCTION f_get_liqspendientes(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*BUG 10487 - 03/07/2009 - ETM - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
    /*************************************************************************
         Obtine los posibles estados del cuadro facultativo
          param out mensajes: mensajes de error
         return            : ref cursor
      *************************************************************************/
   FUNCTION f_get_lstestado_fac(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*FIN BUG 10487 - 03/07/2009 - ETM */

   /*************************************************************************
    FUNCTION f_get_lstccobban_rec
        Obtine los posibles cobradores bancarios del recibo
        param in pnrecibo : N. recibo
        param out mensajes: mensajes de error
        return            : ref cursor
    --BUG 10529 - 04/09/2009 - JTS
   *************************************************************************/
   FUNCTION f_get_lstccobban_rec(pnrecibo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los procesos de cierres de tipo 17 seg?n la empresa seleccionada
      param in pcempres: codi empresa
      param out mensajes : mensajes de error
      return    : ref cursor
       -- JGM -Bug10684-14/08/2009- Se a?ade funci?n
   *************************************************************************/
   FUNCTION f_get_cieres_tipo17(
      pcempres IN NUMBER,
      pagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*FIN BUG 10684 - 14/08/2009 - JGM */

   /*************************************************************************
      Recupera la lista con los estados de gesti?n
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_gstcestgest(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*BUG 10487 - 07/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
        Obtine las diferentes descripciones de comsisiones de contratos
         param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcomis_rea(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Obtine las diferentes descripciones de los intereses
         param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstinteres_rea(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*FIN BUG 10487 - 07/10/2009 - ICV */

   /*************************************************************************
      Recupera la situaci?n de la p?liza (con estado e incidencias) Bug 10831
      param in sseguro   : c?digo seguro
      return             : situaci?n
      --BUG 10831
   *************************************************************************/
   FUNCTION f_get_sit_pol_detalle(psseguro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
          Recupera los Estados de recibo mv
          (Detvalores.cvalor=1)
          param out mensajes : mensajes de error
          return             : ref cursor
          -- Bug 0012679 - 18/02/2010 - JMF
   *************************************************************************/
   FUNCTION f_get_lstestadorecibo_mv(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    FUNCTION F_GET_AGRPRODUCTOS
        param in pagrupacion
        param in pcempres
        param out mensajes: mensajes de error
        return            : ref cursor
    --BUG 13477 - 22/03/2010 - JTS
   *************************************************************************/
   FUNCTION f_get_agrproductos(
      pagrupacion IN NUMBER,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    FUNCTION F_GET_ESTPAGOREN
        param in pcestado
        param out mensajes: mensajes de error
        return            : ref cursor
    --BUG 13477 - 22/03/2010 - JTS
   *************************************************************************/
   FUNCTION f_get_estpagosren(pcestado IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Obtine las garant?as dependientes
        param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   -- Bug 11735 - RSC - 10/05/2010 - APR - suplemento de modificaci?n de capital /prima
   FUNCTION f_get_garanprodep(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Funci?n que devuelve conceptos de una garantia
        param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   -- Bug 14607: - XPL - 27/05/2010 -  AGA004 - Conceptos de pago a nivel de detalle del pago de un siniestro
   FUNCTION f_get_concepgaran(pcgarant IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Obtine los diferentes ramos de la DGS
         param out mensajes: mensajes de error
        return            : ref cursor

        Bug 15148 - 18/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lstramosdgs(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
        Obtine las diferentes tablas de mortalidad
         param out mensajes: mensajes de error
        return            : ref cursor

        Bug 15148 - 18/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lsttmortalidad(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera los elementos
       param in  pcutili  : tipo de utilidad
       param out mensajes : mensajes de error
       return : ref cursor

       Bug 15149 - 21/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lstcodcampo(pcutili IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      Recupera la lista de bancos seg?n los criterios
      param in cbanco : C?digo del banco
      param in tbanco : Descripci?n del banco
   *************************************************************************/
   FUNCTION f_get_lstbancos(
      pcbanco IN NUMBER,
      ptbanco IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Recupera la lista de bancos segÃƒÂºn los criterios
        param out mensajes : mensajes de error
        return             : ref cursor
        Autor: JOHN BENITEZ ALEMAN
        FECHA: ABRIL 2015 - FACTORY COLOMBIA
     *************************************************************************/
   FUNCTION f_get_bancos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recupera la lista de domicilios de la persona
      param in sperson   : c?digo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   -- Bug 16106 - RSC - 23/09/2010 - APR - Ajustes e implementaci?n para el alta de colectivos
   FUNCTION f_get_codreglas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Fin Bug 16106

   /*************************************************************************
      Recupera los agentes
      param in pctipage  : tipo de agente
      param in pcidioma  : idioma
      param out mensajes : mensajes de error
      param in pcpadre  : c?digo de agente padre

      return : ref cursor

      Bug 16529 - 23/11/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_agentestipo(
      pctipage IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcpadre IN NUMBER DEFAULT NULL)   -- BUG 19197 - 22/09/2011 - JMP
      RETURN sys_refcursor;
    
   /*************************************************************************
      Recupera los agentes de tipo 2 y 3 
      param in pctipage  : tipo de agente
      param in pcidioma  : idioma
      param in pcpadre   : codigo de agente padre
      param out mensajes : mensajes de error

      return : ref cursor

      12/07/2019 - UST
   *************************************************************************/
    FUNCTION f_get_agentestipos(
      pctipage IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcpadre IN NUMBER DEFAULT NULL)   -- BUG 19197 - 22/09/2011 - JMP
      RETURN sys_refcursor;
   /*************************************************************************
      Recupera los negocios
      param in pcnegocio : numero negocio
      param in pcidioma  : idioma
      param in pcempresa : codigo de empresa
      param in psproduc  : codigo de producto
      param out mensajes : mensajes de error

      return : ref cursor

      Bug 16529 - 23/11/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_negocio(
      pcnegocio IN NUMBER,
      pcidioma IN NUMBER,
      pcempresa IN NUMBER,
      psproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recupera la Lista de distintos productos  filtrado por compa?ia, devuelve un ref cursor
      param in pccompani : codigo de compa?ia
      param out : mensajes de error
      return    : ref cursor
       -- JBN -bUG16310-20/12/2010- Se a?ade funci?n
   *************************************************************************/
   FUNCTION f_get_productoscompania(
      pccompani IN NUMBER,
      pcramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de distintos ramos filtrado por compa?ia, devuelve un ref cursor
      param in pccompani : codigo de compa?ia
      param out : mensajes de error
      return    : ref cursor
       -- JBN -bUG16310-20/12/2010- Se a?ade funci?n
   *************************************************************************/
   FUNCTION f_get_ramoscompania(pccompani IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera el tipo de pago manual de recibos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_recibo_pagmanual(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      Recupera el tipo de r?gimen fiscal
      param in ctipper : tipo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
      Bug.: 18942
   *************************************************************************/
   FUNCTION f_get_regimenfiscal(pctipper IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
       Recupera la informaci?n de los atributos seg?n el valor, en funci?n del
       valor y atributo del cual depende
       param in cempres     : codigo de la empresa
       param in cvalor     : C?digo del valor del cual existe una dependencia
       param in catribu     : C?digo del atributo del cual existe una dependencia
       param in cvalordep     : C?digo del valor dependiente
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   -- Bug 19169 - APD - 01/08/2011 - se crea la funcion
   FUNCTION f_detvalores_dep(
      pcempres IN NUMBER,
      pcvalor IN NUMBER,
      pcatribu IN NUMBER,
      pcvalordep IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG18752:DRA:02/09/2011:Inici
   /*************************************************************************
      Recuperar tipos de documentos VF 672 seg?n el tipo de persona
      param in ctipper  : tipo de persona (VF-85)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipdocum_tipper(
      pcempres IN NUMBER,
      pctipper IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
  
  --INI IAXIS-5378
  /*************************************************************************
      Recuperar tipos de documentos VF 672 seg?n el tipo de persona y rol
      param in ctipper  : tipo de persona (VF-85)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipdocum_tipper_rol(
      pcempres IN NUMBER,
      pctipper IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
    --FIN IAXIS-5378
    
-- BUG18752:DRA:02/09/2011:Fi

   -- BUG 19130 - 20/09/2011 - JMP
   /*************************************************************************
      FUNCI?N F_GET_LSTMODALI

      Recupera la Lista de modalidades, devuelve un ref cursor
      param in pcramo : c?digo de ramo
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- AMC-Bug9585-24/04/2009- Se a?ade el pcempres
   FUNCTION f_get_lstmodali(pcramo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- FIN BUG 19130 - 20/09/2011 - JMP

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   -- Bug 18319 - APD - 20/09/2011 - se crea la funcion
   FUNCTION f_get_lstformulas_utili(pcutili IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
        Recupera los cobradores y descripcion que esten vigentes para una empresa
        param in pcempres  : empresa
        param out mensajes : mensajes de error
        return             : ref cursor

        03/10/2011   ETM          DESCRIPCION   Cobradores bancarios. Bug: 17383
   *************************************************************************/
   FUNCTION f_get_lstdesccobradores(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Recupera los cobradores y descripcion para una empresa
        param in pcempres  : empresa
        param out mensajes : mensajes de error
        return             : ref cursor

        03/10/2011   ETM          DESCRIPCION   Cobradores bancarios. Bug: 17383
   *************************************************************************/
   FUNCTION f_get_lstdesccobradores_all(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la descripci?n de los cobradores bancarios en funci?n del producto
      param in clave     : clave a recuperar detalles
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_descobradores_ramo(
      psproduc IN NUMBER,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG19069:DRA:26/09/2011:Inici
   FUNCTION f_get_lstcondiciones(
      pcempres IN NUMBER,
      pcuser IN VARCHAR2,
      pccondicion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   FUNCTION f_get_lstagentes_cond(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      pcagente IN NUMBER,
      pformato IN NUMBER,
      cond IN VARCHAR2,
      pctipage IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      ppartner IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

      /*************************************************************************
      Recupera las monedas sin validar visaliza y con condicion
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/-- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_monedas_todas_cond(cond IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de agentes seg?n los criterios
      param in numide : numero documento persona
      param in nombre : texto que incluye nombre + apellidos
   *************************************************************************/
   FUNCTION f_get_lstagentes_dat(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      pcagente IN NUMBER,
      pformato IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- BUG19069:DRA:26/09/2011:Fi

   -- 41.0 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Inici
   /*************************************************************************
      Recupera los estados de las matr?culas de la cuentas bancarias de
      persona en la tabla per_ccc
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcvalida(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- 41.0 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Fi
-- BUG19069:DRA:26/09/2011:Fi
-- BUG20589:XPL:20/12/2011:Ini
   /*************************************************************************
      Recupera las monedas que se pueden visualizar, devuelve cdigo y descripcin
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_monedas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

         /*************************************************************************
      Recupera la descripcion de una moneda
      param in cmoneda : cdigo moneda
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tmoneda(
      pcmoneda IN NUMBER,
      pcmonint OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

-- BUG20589:XPL:20/12/2011:fi

   -- 33.0 10/02/2012 JGR 20735/0103205 LCOL_A001-LCOL_A001-ADM - Introduccion de cuenta bancaria - Inici
   /*************************************************************************
      Recupera los tipos de cuenta para TIPOS_CUENTA.CTIPCC (tarjetas, cuentas corrientes, etc.)
      parametros:
            ptipocta = "1" Cuenta corriente, "2" Tarjetas, "Otro valor" Todos los tipos
            out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipcc(
      ptipocta NUMBER DEFAULT NULL,   -- 46 20735 - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- 33.0 10/02/2012 JGR 20735/0103205 LCOL_A001-LCOL_A001-ADM - Introduccion de cuenta bancaria - Fi

   /*************************************************************************
      Recupera los estados finales permitidos para un agente
      param in pcempres : codigo de la empresa
      param in pctipage : c?digo de tipo de agente
      param in pcestant : c?digo de estado de agente
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   -- Bug 21682 - APD - 24/04/2012 - se crea la funcion
   FUNCTION f_get_lstestadoagente_trans(
      pcempres IN NUMBER,
      pctipage IN NUMBER,
      pcestant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
          Recupera c?digo y descripci?n de las diferentes descuentos definidas para los agentes.
          param out MSJ : mensajes de error
          return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagedescuento(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- bfp bug 21524 ini
/*************************************************************************
         F_GET_TRAMITADORES
      Obt? els tramits d'un ramo
      param in pcramo                : codi del ramo
      param in pctramte                : codi del tr?mit
      param out t_iax_mensajes         : mensajes de error
      return                           : el cursor
   *************************************************************************/
   FUNCTION f_get_tramitadores(
      pcramo IN NUMBER,
      pctramte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
   FUNCTION f_get_lista_tramitadores(
      pcramo IN NUMBER,
      pctramte IN NUMBER,
      pcempres IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
         F_GET_LISTA_PROFESIONALES
      Obt? els tramits d'un ramo
      param in ptipoprof               : codi del tipus de professi?
      param out t_iax_mensajes         : mensajes de error
      return                           : el cursor
   *************************************************************************/
   FUNCTION f_get_lista_profesionales(ptipoprof IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- bfp bug 21524 fi

   -- 36.0 25/07/2012 JGR 0022082: LCOL_A003-Mantenimiento de matriculas - Inici
   /*************************************************************************
      Lista de los tipos de negocio, este campo no estÃƒÂ¡ en la base de datos
      correponde a producciÃƒÂ³n (nanuali=1) o cartera (nanuali>1).
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcnegoci(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- 36.0 25/07/2012 JGR 0022082: LCOL_A003-Mantenimiento de matriculas - Inici

   /*************************************************************************
      Recupera lista de cias de un tipo
      param out mensajes : mensajes de error
      return             : ref cursor

      BUG  23830/161685 - 18/12/2013 - DCT
      Bug 23963/125448 - 15/10/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_companias(
      psproduc IN NUMBER,
      pctipcom IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      paxisrea037 IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   -- Ini Bug 24717 - MDS - 20/12/2012
   /*************************************************************************
      Lista de los tipos de beneficiario
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lst_tipobeneficiario(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Lista de los tipos de parentesco
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lst_tipoparentesco(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fin Bug 24717 - MDS - 20/12/2012

   -- Incio Bug 0025584 - MMS - 18/02/2013
   /*************************************************************************
      Recupera la lista de Edades por Producto seleccionables
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstedadesprod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fin Bug 0025584 - MMS - 18/02/2013
 /*************************************************************************
      bug 24685 AEG 2013-02-05 preimpresos
      Recupera los tipos de asignacion preimpresos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstpreimpresos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fin Bug 0027650 - MMS - 01/08/2013
 /*************************************************************************
      bug 0027650 Generador de Informes
      Recupera los gestores
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_gestorescompania(pccompani IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

        -- Fin Bug 0027650 - MMS - 01/08/2013
   /*************************************************************************
        bug 0027650 Generador de Informes
        Recupera los formatos
        param out mensajes : mensajes de error
        return             : ref cursor
     *************************************************************************/
   FUNCTION f_get_formatosgestor(pgestor IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      bug 0027650 Generador de Informes
      Recupera la lista para visualizar error
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstprocesoerr(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de los dias del mes, devuelve un ref cursor
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstdias(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de los posibles valores donde aplica un indicador de compaÃƒÂ±ia
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_caplicaindicadorcia(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de bancos seg?n los criterios
      param in cbanco : C?digo del banco
      param in tbanco : Descripci?n del banco
   *************************************************************************/
   FUNCTION f_get_lstbancos_pagos(
      pcbanco IN NUMBER,
      ptbanco IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pcforpag IN NUMBER DEFAULT NULL   --Bug 29224/166661:NSS:24-02-2014
                                     )
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de municipios
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_municipios_pagos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- BUG 0029035 - FAL - 21/05/2014
/*************************************************************************
      Recupera el tipo de persona relacionada
      param in pctipper : tipo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipo_persona_rel(pctipper IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- FI BUG 0029035 - FAL - 21/05/2014

   FUNCTION f_get_tipo_persona_rel_des(pctipper IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG34603:XBA:17/02/2015:Inici
   /*************************************************************************
      Recupera la Lista de los rankings utilizados para las pignoraciones, devuelve un ref cursor
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_rank_pledge(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG34603:XBA:17/02/2015:Inici
   /*************************************************************************
      Recupera la Lista de las causas para las pignoraciones, devuelve un ref cursor
      param in pcmotmov  : cÃƒÂ³digo de causa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipo_causa(pcmotmov IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

      -- BUG34603:33886/199827
   /*************************************************************************
      Recupera la Lista de las causas montos para desembolsos MSV
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmonto(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de las causas reembolsosos MSV
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstreembolso(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

        /*************************************************************************
      Recupera la Lista de estados de reembolsos MSV
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lststatus(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- 34866/209952
   FUNCTION f_get_lst_tipocontingencias(clave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
FUNCTION f_get_lstprodproyp(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstproyprovis(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

        FUNCTION f_get_lstcampana(pccodigo IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN sys_refcursor;


    /*************************************************************************
       Recupera la lista de ciiu
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_ciiu(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;


      /*************************************************************************
       Recupera la lista de actividades por grupo
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
       FUNCTION f_get_activigrupo(PCGRUPO IN VARCHAR, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

       /*************************************************************************
      Recupera la lista de domicilios de la persona
      param in sperson   : c?digo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_agrupaciones_consorcios(psperson IN NUMBER, pmodo IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
  -- Ini-QT-1704
  /*************************************************************************
      Recupera los ramos con su descripcion para convenios CONF
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
  FUNCTION f_get_cramo_conv(pcempres IN NUMBER, Mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
  -- Fin-QT-1704
  --INI WAJ
  /*************************************************************************
      Recupera los tipos de vinculos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstvinculos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
  /*************************************************************************
      Recupera los tipos de vinculos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipcomp(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
      --FIN WAJ

	-- Ini  TCS_827 - ACL - 17/02/2019
	/*************************************************************************
      Recupera el ramo cumplimiento devuelve un ref cursor
      param in tipo : codigo de tipo agente
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
    *************************************************************************/
    FUNCTION f_get_ramo_contrag(p_tipo IN VARCHAR2, pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
    -- Fin  TCS_827 - ACL - 17/02/2019
    --INI IAXIS-2085 18/03/2019 AP
    /*************************************************************************
      Recupera la Lista de agrupaciones, devuelve un ref cursor
      param in pcagente : codigo de agente
      param out : mensajes de error
      return    : ref cursor
    *************************************************************************/
    FUNCTION f_get_agrupa_consorcios(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
    --FIN IAXIS-2085 18/03/2019 AP 
    FUNCTION f_get_prodactividad (pcramo IN activiprod.cramo%TYPE, pcactivi IN activiprod.cactivi%TYPE, mensajes OUT t_iax_mensajes) 
        RETURN SYS_REFCURSOR;
END pac_md_listvalores;
/