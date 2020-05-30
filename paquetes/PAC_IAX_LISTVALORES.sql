CREATE OR REPLACE PACKAGE pac_iax_listvalores AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_LISTVALORES
      PROPÃ“SITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor  Descripción
      ---------  ----------  ------  ------------------------------------
      1.0        16/11/2007   ACC    1. Creación del package.
                 19/11/2007   ACC
                 04/04/2008   JRH    Tarea ESTPERSONAS
                 11/02/2009   FAL    Cobradores, delegaciones. Bug: 0007657
                 11/02/2009   FAL    Tipos de apunte, Estado apunte, en/de la agenda. Bug: 0008748
                 12/02/2009   AMC    Siniestros de baja. Bug: 9025
                 06/03/2009   JSP    Agenda de poliza. Bug: 0009208
      2.0        27/02/2009   RSC    Adaptación iAxis a productos colectivos con certificados
      3.0        11/03/2009   RSC    AnÃ¡lisis adaptación productos indexados
      4.0        11/03/2009   SBG    Nou parÃ m. p_tmode funció p_ompledadesdireccions (Bug 7624)
      5.0        24/04/2009   AMC    Bug 9585 Se aÃ±ade el pcempres a la función f_get_ramos
      6.0        06/05/2009   ICV    009940: IAX - Pantalla para lanzar maps
      7.0        23/04/2009   FAL    Parametrizar tipos de anulación de poliza en función de la configuración de acciones del usuario y del producto. Bug 9686.
      8.0        01/10/2009   JRB    0011196: CRE - Gestión de propuestas retenidas
      9.0        07/10/2009   ICV    0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
     10.0        15/12/2009   JTS      10831: CRE - Estado de pólizas vigentes con fecha de efecto futura
     11.0        18/02/2010   JMF    0012679 CEM - Treure la taula MOVRECIBOI
     12.0        22/03/2010   JTS    0013477: CRE205 - Nueva pantalla de Gestión Pagos Rentas
     13.0        10/05/2010   RSC    0011735: APR - suplemento de modificación de capital /prima
     14.0        04/06/2010   PFA    14588: CRT001 - AÃ±adir campo compaÃ±ia productos
     15.0        18/06/2010   AMC    Bug 15148 - Se aÃ±aden nuevas funciones
     16.0        21/06/2010   AMC    Bug 15149 - Se aÃ±aden nuevas funciones
     17.0        09/08/2010   AVT    15638: CRE998 - Multiregistre cercador de pÃ²lisses (Asegurat)
     18.0        20/09/2010   JRH      18. 0015869: CIV401 - Renta vitalÃ­cia: incidencias 12/08/2010
     19.0        06/10/2010   ICV    0015106: AGA003 - mantenimiento para la gestión de cobradores
     20.0        17/08/2010   PFA    Bug 15006: MDP003 - Incluir nuevos campos en bÃºsqueda siniestros
     21.0        25/08/2011   DRA    0019169: LCOL_C001 - Campos nuevos a aÃ±adir para Agentes.
     22.0        30/06/2011   LCF    Bug 18855: LCOL003 - Permitir seleccionar el código de agente en simulaciones
     23.0        02/09/2011   DRA    0018752: LCOL_P001 - PER - AnÃ¡lisis. Mostrar los tipos de documento en función del tipo de persona.
     24.0        20/09/2011   JMP    0019130: LCOL_T002-Agrupacion productos - Productos Brechas 01
     25.0        03/10/2011   APD    0018319: LCOL_A002- Pantalla de mantenimiento del contrato de reaseguro
     26.0        03/10/2011   ETM    BUG 0017383: ENSA101 - Prestacions i altes.Cobrador bancari
     27.0        26/09/2011   DRA    0019069: LCOL_C001 - Co-corretaje
     28.0        08/11/2011   JGR    0019985  LCOL_A001-Control de las matriculas (prenotificaciones)
     29.0        11/11/2011   APD    0019169: LCOL_C001 - Campos nuevos a aÃ±adir para Agentes.
     30.0        10/02/2012   JGR    0020735: LCOL_A001-ADM - Introduccion de cuenta bancaria. Nota:0103205 f_get_lsttipcc
     31.0        17/01/2012   JGR    0020735 - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
     32.0        20/04/2012   ETM    0021924: MDP - TEC - Nuevos campos en pantalla de Gestión (Tipo de retribución, Domiciliar 1Âº recibo, Revalorización franquicia)
     33.0        29/05/2012   APD    0021682: MDP - COM - Transiciones de estado de agente.
     34.0        25/07/2012   JGR    0022082: LCOL_A003-Mantenimiento de matriculas
     35.0        14/08/2012   DCG    0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
     36.0        30/10/2012   XVM    0024058: LCOL_T010-LCOL - Parametrizaci?n de productos Vida Grupo
     37.0        20/12/2012   MDS    0024717: (POSPG600)-Parametrizacion-Tecnico-Descripcion en listas Tipos Beneficiarios RV - Cambiar descripcion en listas Tipos Beneficiar
     39.0        18/02/2013   MMS    0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza â€˜hasta edadâ€™ y edades permitidas por producto. AÃ±adir f_get_lstedadesprod
     40.0        04/03/2013   AEG    0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
     41.0        22/08/2013   DEV    0026443: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 76 -XL capacidad prioridad dependiente del producto (Fase3)
     42.0        19/12/2013   DCT    0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
     43.0        07/02/2014   AGG    0030057: POSPG400-Env?o de Indicadores de compa??as a SAP
     44.0        21/05/2014   FAL    0029035: TRQ000 - Mesa CROSS (personas, usuarios, perfiles)
     45.0        22/09/2014   CASANCHEZ  0032668: COLM004-Trapaso entre Bancos (cobrador bancario) manteniendo la nómina
     46.0        17/02/2015   XBA    0034603: Recupera la Lista de las causas para las pignoraciones
     47.0        08/09/2016   ASDQ   CONF-209-GAP_GTEC50 - Productos multimoneda
     48.0        03/05/2018   VCG    QT-0001704: Listado de Ramos para Convenios
     49.0        14/01/2019   WAJ    Listado de tipos de vinculacion y compañias
     50.0        27/02/2019   ACL    TCS_827 Se agrega la función f_get_ramo_contrag.
     51.0 	 19/07/2019   OAS    IAXIS-4764 Se agrega la funcion f_get_agentestipos
     52.0        28/10/2019   SGM    IAXIS-6149: Realizar consulta de personas publicas  
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
      Recupera la información de valores segÃºn la clave
      param in clave     : clave a recuperar detalles
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalores(clave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la información de valores segÃºn la clave y la condición
      param in clave     : clave a recuperar detalles
      param in cond      : condición de la consulta (sin where ni and)
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalorescond(clave IN NUMBER, cond IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

     /*************************************************************************
      Recupera la información de valores segÃºn la clave y la condición de LST_CONDICIONES
      param in clave     : clave a recuperar detalles
      param in cond      : Codigo de condición de LST_CONDICIONES
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalorescond2(clave IN NUMBER, cond IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera descripción de detvalores
      param in clave        : código de la tabla
      param in valor        : código del valor a recuperar
      param in out mensajes : mesajes de error
      return                : descripción del valor
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
      return                : descripción del valor
   *************************************************************************/
   FUNCTION f_getdescripvalor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera la Lista de distintos ramos, devuelve un ref cursor
      param in pcagente : codigo de agente
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- AMC-Bug9585-24/04/2009- Se aÃ±ade el pcempres
   -- LCF-Bug18855-30-06-2011 - Se aÃ±ade parÃ¡metro cagente
   FUNCTION f_get_ramosagente(
      pcagente IN NUMBER,
      p_tipo IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los productos pertenecientes al ramo segun el agente filtrado
      param in pcramo    : código de ramo
      param in pctermfin : 1=los productos contratables des Front-Office / 0=todos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramproductosagente(
      p_tipo IN VARCHAR2,
      pcramo NUMBER,
      pctermfin IN NUMBER,
      pcagente IN NUMBER,
      pcmodali IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Recupera la lista de productos contractables per l'agent filtrat
        param in p_tipo    : Tipo de productos requeridos:
                             'TF'         ---> Contratables des de Front-Office
                             'REEMB'      ---> Productos de salud
                             'APOR_EXTRA' ---> Con aportaciones extra
                             'SIMUL'      ---> Que puedan tener simulación
                             'RESCA'      ---> Que puedan tener rescates
                             'SINIS'      ---> Que puedan tener siniestros
                             null         ---> Todos los productos
        param in p_cempres : Empresa
        param in p_cramo   : Ramo
        param out mensajes : mensajes de error
        return             : ref cursor
     *************************************************************************/
   FUNCTION f_get_productosagente(
      p_tipo IN VARCHAR2,
      p_cempres IN NUMBER,
      p_cramo IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recupera la Lista de distintos ramos, devuelve un ref cursor
      param in pcagente : codigo de agente
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   -- AMC-Bug9585-24/04/2009- Se aÃ±ade el pcempres
   -- LCF-Bug18855-30-06-2011 - Se aÃ±ade parÃ¡metro cagente
   FUNCTION f_get_ramos(p_tipo IN VARCHAR2, pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los productos pertenecientes al ramo
      param in pcramo    : código de ramo
      param in pctermfin : 1=los productos contratables des Front-Office / 0=todos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramproductos(
      p_tipo IN VARCHAR2,
      pcramo NUMBER,
      pctermfin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de domicilios de la persona
      param in sperson   : código de persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstdomiperson(sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los tipos de vinculos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipovinculos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los estados de la persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcestper(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los tipos de comisión
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcomision(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Recupera la lista de idiomas seleccionables
   -- param out mensajes : mensajes de error
   -- return             : ref cursor
   FUNCTION f_get_lstidiomas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera lista de comisiones permitidas por póliza
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcomisiones(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de agentes segÃºn los criterios
      param in numide : numero documento persona
      param in nombre : texto que incluye nombre + apellidos
      param in cagente : identificador del agente
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagentes(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      cagente IN NUMBER,
      pformato IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de valores del desplegable sexo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipsexo(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de productos contractables
      param in p_tipo    : Tipo de productos requeridos:
                           'TF'         ---> Contratables des de Front-Office
                           'REEMB'      ---> Productos de salud
                           'APOR_EXTRA' ---> Con aportaciones extra
                           'SIMUL'      ---> Que puedan tener simulación
                           'RESCA'      ---> Que puedan tener rescates
                           'SINIS'      ---> Que puedan tener siniestros
                           null         ---> Todos los productos
      param in p_cempres : Empresa
      param in p_cramo   : Ramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_productos(
      p_tipo IN VARCHAR2,
      p_cempres IN NUMBER,
      p_cramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera lista de situaciones póliza
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_sitpoliza(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera lista tipos cuentas bancarias
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipccc(
      mensajes OUT t_iax_mensajes,
      pctipocc NUMBER
            DEFAULT NULL   -- 08/11/2011 0019985 LCOL_A001-Control de las matriculas (prenotificaciones)
                        )
      RETURN sys_refcursor;

   --Ini BUG 14588 - PFA -  CRT001 - AÃ±adir campo compaÃ±ia productos
   /*************************************************************************
      Recupera lista compaÃ±ias producto
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ciaproductos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --Fin BUG 14588 - PFA -  CRT001 - AÃ±adir campo compaÃ±ia productos

   -- Bug 15869 - 20/09/2010 - JRH - Rentas CIV 2 cabezas
   /*************************************************************************
      Recupera lista con los motivos de siniestros
      param in ccausa   : código causa de siniestro
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fi Bug 15869 - 20/09/2010 - JRH
   /*************************************************************************
      Recupera la lista con las causas de siniestros
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_causassini(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista con los motivos de retencion
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_gstpolretmot(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de responsabilidad de siniestros
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_responsabilidasini(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los tipus de anulación de pólizas (VF 553)
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipanulpol(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG 9686 - 23/04/2009 - FAL - AÃ±adir parÃ¡metro psproduc
      /*************************************************************************
         Recupera los tipus de anulación de pólizas (VF 553)
         param in psproduc : código de producto
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
   FUNCTION f_get_tipanulpol(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las causas de anulacion
      param in psproduc  : código de producto
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
      param in pcmotmov  : código de causa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_motanulpol(pcmotmov IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- FI BUG 9686 - 23/04/2009 - FAL

   --BUG 0024058: XVM :30/10/2012--INI. AÃ±adir psproduc
   /*************************************************************************
      Recupera los tipus cobro de la poliza (VF 552)
      param in psproduc  : Código de producto
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipocobro(mensajes OUT t_iax_mensajes, psproduc IN NUMBER DEFAULT 0)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los sub agentes del agente de la póliza
      param in cagente   : código agente principal de la póliza
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_subagentes(cagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera el nombre del tomador de la póliza segÃºn el orden
      param in sseguro   : código seguro
      param in nordtom   : orden tomador
      return             : nombre tomador
   *************************************************************************/
   FUNCTION f_get_nametomador(sseguro IN NUMBER, nordtom IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera el nnumide del tomador de la póliza segÃºn el orden
      param in sseguro   : código seguro
      param in nordtom   : orden tomador
      return             : nombre tomador
   *************************************************************************/
-- 15638 AVT 09-08-2010 -----
   FUNCTION f_get_nameasegurado(sseguro IN NUMBER, nordtom IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera el nnumide del asegurado de la póliza segÃºn el orden
      param in sseguro   : código seguro
      param in nordtom   : orden asegurado
      return             : nombre asegurado
   *************************************************************************/
   FUNCTION f_get_numidetomador(psseguro IN NUMBER, pnordtom IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera la situación de la póliza
      param in sseguro   : código seguro
      return             : situación
   *************************************************************************/
   FUNCTION f_get_situacionpoliza(psseguro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera la estado de la póliza (retenida)
      param in creteni   : código de retención
      return             : situación
   *************************************************************************/
   FUNCTION f_get_retencionpoliza(creteni IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Motivos de rechazo de la póliza
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
   FUNCTION f_get_tipdocum(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar tipos de personas VF 85
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipperson(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar estados de un siniestro (VF. 6)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_estadossini(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar subestados de un siniestro (VF. 665)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_subestadossini(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar estados de un reembolso (VF. 6)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_estadosreemb(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG 7624 - 20/04/2009 - SBG - S'afegeix parÃ m. p_tmode
   /***********************************************************************
      Dado un identificativo de domicilio llena el objeto direcciones
      param in sperson       : código de persona
      param in cdomici       : código de domicilio
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
      Devuelve la descripción del vinculo
      param in pcvincle      : código vinculo
      param in out mensajes  : mensajes de error
   ***********************************************************************/
   FUNCTION f_getdescvincle(pcvincle IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve la descripción del tipo de cuenta bancaria
      param in psperson      : código persona
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
   FUNCTION f_get_lstempresas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de agrupaciones de productos
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagrupprod(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recuperar la lista de posibles valores del campo productos.cactivo
       param in mensajes : mensajes de error
       return      : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstactivo(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctermfin
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstterfinanciero(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctiprie
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipriesgo(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃºsqueda siniestros
    /*************************************************************************
      Recuperar la lista de posibles valores del campo tiporiesgo
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tiporiesgo(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --Fi Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃºsqueda siniestros
   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctiprie
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcobjase(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.csubpro
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcsubpro(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cprprod
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcprprod(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cdivisa
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstdivisa(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.cduraci
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcduraci(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctempor
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctempor(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores del campo productos.ctempor
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcdurmin(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcdurmax(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipefe(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcrevali(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctarman(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstsino(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcreteni(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcprorra(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcprimin(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstformulas(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ctipges
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipges(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos creccob
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcreccob(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ctipreb
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipreb(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ccalcom
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccalcom(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de campo productos ctippag
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctippag(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de garantÃ­a
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipgar(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de capital garantÃ­a
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipcapgar(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de capital mÃ¡ximo garantÃ­a
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcapmaxgar(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de tipos de tarifas garantÃ­a
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttiptargar(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de reaseguro de garantÃ­a
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstreagar(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recuperar la lista de posibles valores de revalorizaciones de garantÃ­a
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstrevalgar(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
      /*************************************************************************
         Recupera la lista de paÃ­ses seleccionables
         param out mensajes : mensajes de error
         return             : ref cursor
      *************************************************************************/
   FUNCTION f_get_lstpaises(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Recupera la lista de Profesiones seleccionables
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstprofesiones(mensajes OUT t_iax_mensajes, cocupacion IN  NUMBER DEFAULT 0)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Recupera la lista de Tipos de cuentas seleccionables
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipocuenta(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Recupera la lista de Tipos de dirección
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipodireccion(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Recupera la lista de Tipos de vÃ­a
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipovia(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 04/2008 Tarea ESTPERSONAS
      /*************************************************************************
         Recupera la lista de ppoblaciones , provincias
         param out mensajes : mensajes de error
         return             : ref cursor
      *************************************************************************/
   FUNCTION f_get_consulta(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
      
   --SGM IAXIS-6149 28/10/2019 
      /*************************************************************************
         Recupera la lista de personas publicas
         return             : ref cursor
      *************************************************************************/
   FUNCTION f_get_publicinfo(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;      

   /*************************************************************************
      Recupera los diferentes niveles que hay de intereses o gastos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstnivel(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los diferentes cuadros que existen a dÃ­a de hoy
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstncodint(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recupera los diferentes tipos de interes que puede tener un cuadro de interÃ©s
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipinteres(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los diferentes conceptos del tramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ctramtip(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera los LITERALES
          param IN pcidioma : Filtrado por IDIOMA
          param out MSJ : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_literales(pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
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
          Recupera los códigos y la descripciones de los tipos de IVA definidos.
          param out MSJ : mensajes de error
          return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipoiva(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera código y la descripción de los tipos de retención definidos
          param out MSJ : mensajes de error
          return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstretencion(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera código de estado de agente y descripción.
          param out MSJ : mensajes de error
          return : ref cursor
   *************************************************************************/
   -- Bug 19169 - APD - 15/09/2011 - se aÃ±ade al parametro pcempres, pcvalor, pcatribu
   -- Bug 21682 - APD - 24/04/2012 - se aÃ±ade al parametro pctipage (sustituye a pcatribu), pcactivo
   FUNCTION f_get_lstestadoagente(
      pcempres IN NUMBER,
      pcvalor IN NUMBER,
--      pcatribu IN NUMBER,
      pctipage IN NUMBER,
      pcactivo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera código de tipo de agente y descripción.
          param out MSJ : mensajes de error
          return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipoagente(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera código y descripción de las diferentes comisiones definidas para los agentes.
          param out MSJ : mensajes de error
          return : ref cursor
   *************************************************************************/
   -- Bug 19169 - APD - 15/09/2011 - se aÃ±ade al parametro pctipo
   FUNCTION f_get_lstagecomision(pctipo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de los meses del aÃ±o, devuelve un ref cursor
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmeses(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***************NUEVAS JGM 27-08-2008**********************************************************/

   /*Esta función tendrÃ¡ un parÃ¡metro de salida t_iax_mensajes con los posibles mensajes de error y
   nos devolverÃ¡ un sys_refcursor con el código del tipo de cierre activo y su descripción.
        param IN pcempres : Filtrado por empresa
        param OUT msj : mensajes de error
        return             : ref cursor
   */
   FUNCTION f_get_lsttipocierre(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*Esta función tendrÃ¡ un parÃ¡metro de entrada PPREVIO y un parÃ¡metro de salida t_iax_mensajes con los posibles
   mensajes de error y nos devolverÃ¡ un sys_refcursor con los diferentes código de estado de cierre activo y su descripción.
      param IN previo : parÃ¡metro para mostrar o no el estado PREVIO PROGRAMADO
      param OUT msj : mensajes de error
      return             : ref cursor
   */
   FUNCTION f_get_lstestadocierre(pprevio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*Esta función tendrÃ¡ un parÃ¡metro de entrada PPREVIO y un parÃ¡metro de salida t_iax_mensajes con los posibles
   mensajes de error y nos devolverÃ¡ un sys_refcursor con los diferentes código de estado de cierre activo y su descripción.
   no sacarÃ¡ los estados CERRADO y PENDIENTE
      param IN previo : parÃ¡metro para mostrar o no el estado PREVIO PROGRAMADO
      param OUT msj : mensajes de error
      return             : ref cursor
   */
   FUNCTION f_get_lstestadocierre_nuevo(pprevio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- ini t.7661
   /*************************************************************************
      Recupera la Lista de compaÃ±Ã­as de reaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcia_rea(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de los tipos de reaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipo_rea(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de las agrupaciones de reaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagr_rea(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- fin t.7661

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   /*************************************************************************
      Recupera la Lista de compaÃ±Ã­as de coaseguro
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_coaseguradoras(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fin Bug 0023183

   /*************************************************************************
      Recupera los ramos con su descripcion por empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cramo_emp(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los productos con su descripcion por ramo
      param in pcramo    : ramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_productos_cramo(pcramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las actividades con su descripcion por producto
      param in psproduc  : id. interno de producto
      param in pcramo    : ramo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cactivi(psproduc IN NUMBER, pcramo IN NUMBER, mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

      /*************************************************************************
      Recupera las garantias con su descripcion por poliza
      param in p_npoliza : numero de poliza
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cgarant_pol(p_npoliza IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

         /*************************************************************************
      Recupera las garantias con su descripcion por sinietro
      param in p_nsinies : numero de siniestro
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cgarant_sin(p_nsinies IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la descripción de una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_desempresa(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera lista de código+descripción cuenta contable.
      param out msj      : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcuentacontable(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de tipo de concepto contable y su descripción.
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstconceptocontable(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera lista de código+descripción asiento contable.
      param in p_empresa : código de empresa
      param out msj      : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstasiento(p_empresa IN NUMBER, msj OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los cobradores y cuentas de domiciliación vigentes para una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor

         11/02/2009   FAL                Cobradores, delegaciones. Bug: 0007657
   *************************************************************************/
   FUNCTION f_get_lstcobradores(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las delegaciones de una empresa
      param in pcempres  : empresa
      param out mensajes : mensajes de error
      return             : ref cursor

         11/02/2009   FAL                Cobradores, delegaciones. Bug: 0007657
   *************************************************************************/
   FUNCTION f_get_lstdelegaciones(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera código de tipo de apunte en la agenda y descripción.
          param out mensajes : mensajes de error
          return : ref cursor

             11/02/2009   FAL                Tipos de apunte en agenda. Bug: 0008748
   *************************************************************************/
   FUNCTION f_get_lsttipoapuntesagenda(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera estados de apunte en la agenda y descripción.
          param out mensajes : mensajes de error
          return : ref cursor

             11/02/2009   FAL                Tipos de apunte en agenda. Bug: 0008748
   *************************************************************************/
   FUNCTION f_get_lstestadosapunteagenda(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera els graus de minusvalia
          param out mensajes : mensajes de error
          return : ref cursor

             16/03/2009   XPL                Mant. Pers. IRPF. Bug: 0007730
   *************************************************************************/
   FUNCTION f_get_lstgradominusvalia(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera les situacions familiars
          param out mensajes : mensajes de error
          return : ref cursor

             16/03/2009   XPL                Mant. Pers. IRPF. Bug: 0007730
   *************************************************************************/
   FUNCTION f_get_lstsitfam(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera los conceptos de apunte en la agenda y descripción.
          param out mensajes : mensajes de error
          return : ref cursor

             06/03/2009   JSP                Conceptos de apunte en agenda. Bug: 0009208
   *************************************************************************/
   FUNCTION f_get_lstconceptosapunteagenda(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera usuarios de la agenda y descripción.
          param out mensajes : mensajes de error
          return : ref cursor

             06/03/2009   JSP                Conceptos de apunte en agenda. Bug: 0009208
   *************************************************************************/
   FUNCTION f_get_lstusuariosagenda(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
         Recupera el nombre del tomador de la póliza segÃºn el orden
         param in sseguro   : código seguro
         param in nordtom   : orden tomador
         param out mensajes : mesajes de error
         return             : nombre tomador
      *************************************************************************/
   FUNCTION f_get_nametomadorcero(sseguro IN NUMBER, nordtom IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera los perfiles asociados a un producto
      param in psproduc  : producto
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_perfiles(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los fondos de inversión asociados a una empresa.
      param in pcempres  : Empresa
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_fondosinversion(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
          Recupera las actividades profesionales
          param out mensajes : mensajes de error
          return : ref cursor

             30/03/2009   XPL                 Sinistres.  Bug: 9020
   *************************************************************************/
   FUNCTION f_get_lstcactprof(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
         Recupera código del map y su descripción
         param out mensajes : mensajes de error
         return             : ref cursor

             06/05/2009   ICV                 Maps.  Bug: 9940
   *************************************************************************/
   FUNCTION f_get_ficheros(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
         Recupera código del motivo de rehabilitación y la descripción del motivo.
         param in  psproduc : Identificador del producto.
         param out mensajes : mensajes de error
         return             : ref cursor

             11/05/2009   ICV                 Maps.  Bug: 9784
   *************************************************************************/
   FUNCTION f_get_motivosrehab(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de distintas agrupacions por producto pasandole la empresa, devuelve un ref cursor
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
      -- XPL -Bug10317-29/06/2009- Se aÃ±ade función
   *************************************************************************/
   FUNCTION f_get_agrupaciones(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de distintos ramos filtrado por agrupacion, devuelve un ref cursor
      param in pcempres : codigo de empresa
      param in pcagrupacion : codigo de agrupacion
      param out : mensajes de error
      return    : ref cursor
       -- XPL -Bug10317-29/06/2009- Se aÃ±ade función
   *************************************************************************/
   FUNCTION f_get_ramosagrupacion(
      pcempres IN NUMBER,
      pcagrupacion IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista del codigo de concepto y descripción de las cuentas tecnicas
      param out : mensajes de error
      return    : ref cursor
       -- XPL -Bug10671-09/07/2009- Se aÃ±ade función
   *************************************************************************/
   FUNCTION f_get_lstconcep_cta(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las posibles ubicaciones (debe/haber) dónde imputar el importe del asiento
      del concepto recibido por parÃ¡metro de la cuenta y su descripción.
      param in pcconcepto: concepto
      param out mensajes : mensajes de error
      return    : ref cursor
       -- XPL -Bug10671-09/07/2009- Se aÃ±ade función
   *************************************************************************/
   FUNCTION f_get_lsttipo_cta(pcconcepto IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los procesos de liquidación pendientes de cerrar segÃºn la empresa seleccionada
      param in pcempres: codi empresa
      param out mensajes : mensajes de error
      return    : ref cursor
       -- XPL -Bug10672-15/07/2009- Se aÃ±ade función
   *************************************************************************/
   FUNCTION f_get_liqspendientes(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

     /*BUG 10487 - 03/07/2009 - ETM - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
        Obtine los posibles estados del cuadro facultativo
         param out mensajes: mensajes de error
        return            : ref cursor
     *************************************************************************/
   FUNCTION f_get_lstestado_fac(mensajes OUT t_iax_mensajes)
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
   FUNCTION f_get_lstccobban_rec(pnrecibo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los procesos de cierres de tipo 17 segÃºn la empresa seleccionada
      param in pcempres: codi empresa
      param out mensajes : mensajes de error
      return    : ref cursor
       -- JGM -Bug10684-14/08/2009- Se aÃ±ade función
   *************************************************************************/
   FUNCTION f_get_cieres_tipo17(
      pcempres IN NUMBER,
      pagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista con los estados de gestión
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_gstcestgest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

      /*BUG 10487 - 07/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
        Obtine las diferentes descripciones de comsisiones de contratos
         param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcomis_rea(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Obtine las diferentes descripciones de los intereses
         param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstinteres_rea(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*FIN BUG 10487 - 07/10/2009 - ICV */

   /*************************************************************************
      Recupera la situación de la póliza (con estado e incidencias)
      param in sseguro   : código seguro
      return             : situación
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    FUNCTION F_GET_ESTPAGOREN
        param in pcestado
        param out mensajes: mensajes de error
        return            : ref cursor
    --BUG 13477 - 22/03/2010 - JTS
   *************************************************************************/
   FUNCTION f_get_estpagosren(pcestado IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Obtine las garantÃ­as dependientes
        param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   -- Bug 11735 - RSC - 10/05/2010 - APR - suplemento de modificación de capital /prima
   FUNCTION f_get_garanprodep(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Función que devuelve conceptos de una garantia
        param out mensajes: mensajes de error
        return            : ref cursor
   *************************************************************************/
   -- Bug 14607: - XPL - 27/05/2010 -  AGA004 - Conceptos de pago a nivel de detalle del pago de un siniestro
   FUNCTION f_get_concepgaran(pcgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Obtine los diferentes ramos de la DGS
         param out mensajes: mensajes de error
        return            : ref cursor

        Bug 15148 - 18/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lstramosdgs(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Obtine las diferentes tablas de mortalidad
         param out mensajes: mensajes de error
        return            : ref cursor

        Bug 15148 - 18/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lsttmortalidad(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera los elementos
       param in  pcutili  : tipo de utilidad
       param out mensajes : mensajes de error
       return : ref cursor

       Bug 15149  - 21/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lstcodcampo(pcutili IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de bancos segÃºn los criterios
      param in cbanco : Código del banco
      param in tbanco : texto que descripción del banco
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstbancos(
      pcbanco IN NUMBER,
      ptbanco IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de bancos segÃºn los criterios
      param out mensajes : mensajes de error
      return             : ref cursor
      Autor: JOHN BENITEZ ALEMAN
      FECHA: ABRIL 2015 - FACTORY COLOMBIA
   *************************************************************************/
   FUNCTION f_get_bancos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recupera las reglas del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   -- Bug 16106 - RSC - 23/09/2010 - APR - Ajustes e implementación para el alta de colectivos
   FUNCTION f_get_codreglas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Fin Bug 16106

   /*************************************************************************
      Recupera los agentes
      param in pctipage  : tipo de agente
      param in pcidioma  : idioma
      param in pcpadre   : codigo de agente padre
      param out mensajes : mensajes de error

      return : ref cursor

      Bug 16529 - 23/11/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_agentestipo(
      pctipage IN NUMBER,
      pcidioma IN NUMBER,
      pcpadre IN NUMBER,   -- BUG 19197 - 22/09/2011 - JMP
      mensajes OUT t_iax_mensajes)
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
      pcpadre IN NUMBER,   -- BUG 19197 - 22/09/2011 - JMP
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de distintos productos  filtrado por compaÃ±ia, devuelve un ref cursor
      param in pccompani : codigo de compaÃ±ia
      param out : mensajes de error
      return    : ref cursor
       -- JBN -bUG16310-20/12/2010- Se aÃ±ade función
   *************************************************************************/
   FUNCTION f_get_productoscompania(
      pccompani IN NUMBER,
      pcramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de distintos ramos filtrado por compaÃ±ia, devuelve un ref cursor
      param in pccompani : codigo de compaÃ±ia
      param out : mensajes de error
      return    : ref cursor
       -- JBN -bUG16310-20/12/2010- Se aÃ±ade función
   *************************************************************************/
   FUNCTION f_get_ramoscompania(pccompani IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_ramoscompagrupa(
      pcagrpro IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la Lista de distintos agrupaciones filtrado por compaÃ±ia, devuelve un ref cursor
      param in pccompani : codigo de compaÃ±ia
      param out : mensajes de error
      return    : ref cursor
       -- XPL -bUG17257-19/01/2011- Se aÃ±ade función
   *************************************************************************/
   FUNCTION f_get_agrupcompania(pccompani IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera el tipo de pago manual de recibos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_recibo_pagmanual(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera el tipo de rÃ©gimen fiscal
       param in ctipper : tipo de persona
       param out mensajes : mensajes de error
       return             : ref cursor
       Bug.: 18942
    *************************************************************************/
   FUNCTION f_get_regimenfiscal(pctipper IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
       Recupera la información de los atributos segÃºn el valor, en función del
       valor y atributo del cual depende
       param in cempres     : codigo de la empresa
       param in cvalor     : Código del valor del cual existe una dependencia
       param in catribu     : Código del atributo del cual existe una dependencia
       param in cvalordep     : Código del valor dependiente
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   -- Bug 19169 - APD - 01/08/2011 - se crea la funcion
   FUNCTION f_detvalores_dep(
      pcempres IN NUMBER,
      pcvalor IN NUMBER,
      pcatribu IN NUMBER,
      pcvalordep IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG18752:DRA:02/09/2011:Inici
   /*************************************************************************
      Recuperar tipos de documentos VF 672 segÃºn el tipo de persona
      param in ctipper  : tipo de persona (VF-85)
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipdocum_tipper(pctipper IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
    --INI  IAXIS-5378  
   /*************************************************************************
   Recuperar tipos de documentos VF 672 segÃºn el tipo de persona y rol
   param in ctipper  : tipo de persona (VF-85)
   param in mensajes : mensajes de error
   return      : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipdocum_tipper_rol(pctipper IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
    --FIN  IAXIS-5378
    
-- BUG18752:DRA:02/09/2011:Fi
-- BUG 19130 - 20/09/2011 - JMP
   /*************************************************************************
      FUNCTION F_GET_PRODUCTOS

      Recupera la lista de productos contractables
      param in p_tipo    : Tipo de productos requeridos:
                           'TF'         ---> Contratables des de Front-Office
                           'REEMB'      ---> Productos de salud
                           'APOR_EXTRA' ---> Con aportaciones extra
                           'SIMUL'      ---> Que puedan tener simulación
                           'RESCA'      ---> Que puedan tener rescates
                           'SINIS'      ---> Que puedan tener siniestros
                           null         ---> Todos los productos
      param in p_cempres : Empresa
      param in p_cramo   : Ramo
      param in p_cmodali : Modalidad
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_productos(
      p_tipo IN VARCHAR2,
      p_cempres IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      F_GET_RAMPRODUCTOS

      Recupera los productos pertenecientes al ramo
      param in pcramo    : código de ramo
      param in pcmodali  : código de modalidad
      param in pctermfin : 1=los productos contratables des Front-Office / 0=todos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramproductos(
      p_tipo IN VARCHAR2,
      pcramo NUMBER,
      pcmodali NUMBER,
      pctermfin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        FUNCIÃ“N F_GET_LSTMODALI

        param in pcramo   : Ramo
        param out mensajes : mensajes de error
        return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmodali(pcramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- FIN BUG 19130 - 20/09/2011 - JMP

   /*************************************************************************
      Recuperar la lista de posibles valores
      param in mensajes : mensajes de error
      return      : ref cursor
   *************************************************************************/
   -- Bug 18319 - APD - 20/09/2011 - se crea la funcion
   FUNCTION f_get_lstformulas_utili(pcutili IN NUMBER, mensajes OUT t_iax_mensajes)
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
      Recupera la descripción de los cobradores bancarios en función del producto
      param in clave     : clave a recuperar detalles
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_descobradores_ramo(
      psproduc IN NUMBER,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG19069:DRA:27/09/2011:Inici
   FUNCTION f_get_lstagentes_cond(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      cagente IN NUMBER,
      pformato IN NUMBER,
      pccondicion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

--Funcion devuelve todas las monedas condicionadas
   FUNCTION f_get_monedas_cond(pccondicion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstagentes_tipage_cond(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      cagente IN NUMBER,
      pformato IN NUMBER,
      pccondicion IN VARCHAR2,
      pctipage IN NUMBER,
      mensajes OUT t_iax_mensajes,
      ppartner IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de agentes segÃºn los criterios
      param in numide : numero documento persona
      param in nombre : texto que incluye nombre + apellidos
      param in cagente : identificador del agente
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstagentes_dat(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      cagente IN NUMBER,
      pformato IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- BUG19069:DRA:27/09/2011:Fi

   -- 41.0 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Inici
   /*************************************************************************
      Recupera los estados de las matrÃ­culas de la cuentas bancarias de
      persona en la tabla per_ccc
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcvalida(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- 41.0 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Fi
-- BUG20589:XPL:20/12/2011:Ini
   /*************************************************************************
      Recupera las monedas que se pueden visualizar, devuelve cdigo y descripcin
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_monedas(mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

-- BUG20589:XPL:20/12/2011:fi

   -- 10/02/2012 JGR 20735/0103205 LCOL_A001-LCOL_A001-ADM - Introduccion de cuenta bancaria - Inici
   /*************************************************************************
      Recupera los tipos de cuenta para TIPOS_CUENTA.CTIPCC (tarjetas, cuentas corrientes, etc.)
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipcc(
      ptipocta NUMBER DEFAULT NULL,   -- 46 20735 - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- 10/02/2012 JGR 20735/0103205 LCOL_A001-LCOL_A001-ADM - Introduccion de cuenta bancaria - Inici

   -- BUG 21924 - 20/04/2012 - ETM
   FUNCTION f_get_lsttipretribu(pcagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstrevalfranq(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- fin BUG 21924 - 20/04/2012 - ETM
   /*************************************************************************
            Recupera código y descripción de las diferentes descuentos definidas para los agentes.
            param out MSJ : mensajes de error
            return : ref cursor
     *************************************************************************/
   FUNCTION f_get_lstagedescuento(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- bfp bug 21524 ini
/*************************************************************************
         F_GET_LISTA_TRAMITADORES
      ObtÃ© els tramits d'un ramo
      param in pcramo                : codi del ramo
      param in pctramte                : codi del trÃ mit
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
         F_GET_TRAMITADORES
      ObtÃ© els tramits d'un ramo
      param in pcramo                : codi del ramo
      param in pctramte                : codi del trÃ mit
      param out t_iax_mensajes         : mensajes de error
      return                           : el cursor
   *************************************************************************/
   FUNCTION f_get_tramitadores(
      pcramo IN NUMBER,
      pctramte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
           F_GET_LISTA_PROFESIONALES
        ObtÃ© els tramits d'un ramo
        param in ptipoprof               : codi del tipus de professió
        param out t_iax_mensajes         : mensajes de error
        return                           : el cursor
     *************************************************************************/
   FUNCTION f_get_lista_profesionales(ptipoprof IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- bfp bup 21524 fi

   -- 50.0 25/07/2012 JGR 0022082: LCOL_A003-Mantenimiento de matriculas - Inici
   /*************************************************************************
      Lista de los tipos de negocio, este campo no estÃ¡ en la base de datos
      correponde a producción (nanuali=1) o cartera (nanuali>1).
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcnegoci(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- 50.0 25/07/2012 JGR 0022082: LCOL_A003-Mantenimiento de matriculas - Inici

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
      mensajes OUT t_iax_mensajes,
      paxisrea037 IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   -- Ini Bug 24717 - MDS - 20/12/2012
   /*************************************************************************
      Lista de los tipos de beneficiario
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lst_tipobeneficiario(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Lista de los tipos de parentesco
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lst_tipoparentesco(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fin Bug 24717 - MDS - 20/12/2012
-- Inicio Bug 0025584 - MMS - 18/02/2013
   /*************************************************************************
      Recupera la lista de Edades por Producto seleccionables
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstedadesprod(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fin Bug 0025584 - MMS - 18/02/2013
-- Inicio Bug 24685 - AEG  -04/03/2013
  /*************************************************************************
      bug 24685 2013-feb-05 aeg preimpresos
      Recupera los tipos de asignacion preimpresos
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstpreimpresos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- fin Bug 24685 - AEG  -04/03/2013

   -- Inicio Bug 27650 -   -02/08/2013
   /*************************************************************************
       bug 27650 2013-agos-02 jmgutierrez - Jenny Gutierrez
       Recupera los gestores
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_gestorescompania(pccompani IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Inicio Bug 27650 -   -02/08/2013

   -- Inicio Bug 27650 -   -02/08/2013
   /*************************************************************************
       bug 27650 2013-agos-02 jmgutierrez - Jenny Gutierrez
       Recupera los formatos por gestor
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_formatosgestor(pgestor IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- fin Bug 27650 -   -02/08/2013

   -- Inicio Bug 27650 -   -02/08/2013
   /*************************************************************************
       bug 27650 2013-agos-02 jmgutierrez - Jenny Gutierrez
       Recupera lista fija de errores
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstprocesoerr(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- fin Bug 27650 -   -02/08/2013

   /*************************************************************************
      Recupera la Lista de los dias del mes, devuelve un ref cursor
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstdias(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de los posibles valores donde aplica un indicador de compaÃ±ia
      param out mensajes: mensajes de error
      return            : ref cursor
   *************************************************************************/
   FUNCTION f_get_caplicaindicadorcia(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

--Ini Bug 29224/166661:NSS:24-02-2014
   /*************************************************************************
      Recupera la lista de bancos segÃºn los criterios
      param in cbanco : Código del banco
      param in tbanco : texto que descripción del banco
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstbancos_pagos(
      pcbanco IN NUMBER,
      ptbanco IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pcforpag IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de municipios
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_municipios_pagos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

--Fin Bug 29224/166661:NSS:24-02-2014

   -- BUG 0029035 - FAL - 21/05/2014
   /*************************************************************************
       Recupera el tipo de persona relacionada
       param in pctipper : tipo de persona
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_tipo_persona_rel(pctipper IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- FI BUG 0029035 - FAL - 21/05/2014

   FUNCTION f_get_tipo_persona_rel_des(pctipper IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG34603:XBA:17/02/2015:Inici
   /*************************************************************************
      Recupera la Lista de los rankings utilizados para las pignoraciones, devuelve un ref cursor
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_rank_pledge(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG34603:XBA:17/02/2015:Inici
   /*************************************************************************
      Recupera la Lista de las causas para las pignoraciones, devuelve un ref cursor
      param in pcmotmov  : código de causa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipo_causa(pcmotmov IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

     --BUG: 33886/199827
      /*************************************************************************
      Recupera la Lista de las causas montos para desembolsos MSV
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmonto(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

        /*************************************************************************
      Recupera la Lista de las causas reembolsosos MSV
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstreembolso(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

      /*************************************************************************
      Recupera la Lista de estados de reembolsos MSV
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_lststatus(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- 34866/209952
   FUNCTION f_get_lst_tipocontingencias(clave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstprodproyp(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstproyprovis(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
       Recupera la lista de ciiu
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_ciiu(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      return SYS_REFCURSOR;
     /*************************************************************************
       Recupera la lista de actividades por grupo
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
       FUNCTION f_get_activigrupo(PCGRUPO IN VARCHAR, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
 /*************************************************************************
      Recupera la lista de agrupaciones consorcio
      param in sperson   : codigo de persona
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_agrupaciones_consorcios(sperson IN NUMBER, pmodo IN VARCHAR2, mensajes OUT t_iax_mensajes)
      Return Sys_Refcursor;
   Function F_Get_Cramo_Conv(Pcempres In Number, Mensajes Out T_Iax_Mensajes)
      RETURN sys_refcursor;
      --INI WAJ
   /*************************************************************************/
   FUNCTION f_get_lstvinculos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
    /*************************************************************************/
   FUNCTION f_get_lsttipcomp(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
      --FIN WAJ
	-- Ini  TCS_827 - ACL - 17/02/2019
	 /*************************************************************************
      Recupera el ramo cumplimiento, devuelve un ref cursor
      param in pcagente : codigo de agente
      param in pcempres : codigo de empresa
      param out : mensajes de error
      return    : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramo_contrag(p_tipo IN VARCHAR2, pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
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
    -- INI IAXIS-3636 JLTS 12/04/2019
    FUNCTION f_get_prodactividad (pcramo IN NUMBER, pcactivi IN NUMBER, mensajes OUT t_iax_mensajes)
    RETURN SYS_REFCURSOR;
END pac_iax_listvalores;
/