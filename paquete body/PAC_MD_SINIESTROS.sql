CREATE OR REPLACE PACKAGE BODY "PAC_MD_SINIESTROS"
AS
  /******************************************************************************
  NOMBRE:     PAC_MD_SINIESTROS
  PROPÓSITO:  Funciones para la gestión de siniestros.
  REVISIONES:
  Ver        Fecha        Autor             Descripción
  ---------  ----------  ---------------  ------------------------------------
  1.0        17/02/2009   XPL i XV                1. Creación del package.
  2.0        19/05/2009   APD              2. 0010127: IAX- Consultas de pólizas, simulaciones, reembolsos y póliza reteneidas
  2.1        21/05/2009   APD              2.1 BUG10178: IAX - Vista AGENTES_AGENTE por empresa
  3.0        21/05/2009   AMC              2. Se añaden nuevas funciones bug 8816
  4.0        28/09/2009   DCT              4. Bug 10393 Crear parametrización de documentacion a solicitar por producto/causa/motivo
  5.0        30/09/2009   AMC              5. Bug 11271 Se modifica la consulta para que tenga encuenta el estado del siniestro
  6.0        14/10/2009   XPL              6. bug. 11192. Alta de siniestros de Vida
  7.0        30/09/2009   DRA              7. 0011183: CRE - Suplemento de alta de asegurado ya existente
  8.0        23/11/2009   AMC              8. 0011847: AGA - Error al introducir detalle recobro en siniestro
  9.0        08/01/2010   AMC              9. 0012604: CEM - Agenda de siniestros da error
  10.0       15/01/2010   AMC              10. Bug 11945 - AGA - Crear columna Previsión Recobro para siniestros
  11.0       18/01/2010   AMC              11  Bug 12753 - CEM - Creación automática de destinatario
  12.0       20/01/2010   AMC              12. Bug 11849 - CEM - Crear botón generación pago automático en siniestros
  13.0       02/02/2010   LCF              13. Bug 10093 - CRE - Anyadir parametros busqueda siniestros
  14.0       01/02/2010   AMC              14. Bug 12207 - AGA - Introducción de reservas en productos de Baja (Salud)
  15.0       15/02/2010   AMC              15. Bug 13166 - CRE - Se crea la función f_del_mov paggar para borrar el detalle de los pagos/recobros
  16.0       24/02/2010   AMC              16. Bug 12668 - AGA - Normalización riesgo tipo dirección
  17.0       18/05/2010   AMC              17. Bug 14490 - AGA - Se añade los parametros pnmovres,psproduc,pcactivi
  18.0       31/05/2010   XPL              18. bug : 14607, AGA004 - Conceptos de pago a nivel de detalle del pago de un siniestro
  19.0       03/06/2010   AMC              19. Bug 14766 Se añaden nuevas funciones
  20.0       23/06/2010   AMC              20. Bug 15153 Se añaden nuevas funciones
  21.0       27/09/2010   ICV              21. 0016102: AGA003 - Error al mirar quan una reserva es pot eliminar o no
  22.0       23/09/2010   SRA              22. 0016040: AGA003 - generación de pagos en siniestros
  23.0       30/10/2010   JRH              23. BUG 15669 : Campos nuevos
  24.0       26/10/2010   ICV              24. 0015880: GRC - Entrada siniestros
  25.0       08/11/2010   XPL              25. 15044: AGA202 - Crear pantalla para pagos de rentas
  26.0       09/11/2010   DRA              26. 0016506: CRE - Pantallas de siniestros nuevo módulo
  21.0       13/08/2010   PFA              21. 14587: CRT001 - Añadir campo siniestro compañia
  22.0       17/08/2010   PFA              22. 15006: MDP003 - Incluir nuevos campos en búsqueda siniestros
  23.0       23/11/2010   ETM              23. 0016645: GRC - Búsqueda de siniestros
  24.0       15/12/2010   ICV              24. 0014587: CRT001 - Añadir campo siniestro compañia
  24.0       14/12/2010   DRA              24. 0016506: CRE - Pantallas de siniestros nuevo módulo
  23.0       22/12/2010   ICV              23. 0015738: ENSA101 - Duplicat en PDF pagament en capital SONANGOL
  25.0       10/01/2011   SRA              25. 0016924: GRC003 - Siniestros: estado y tipo de pago por defecto
  26.0       07/02/2011   SRA              26. 0017547: GRC003 - Siniestro en fecha de suplemento
  27.0       17/03/2011   ICV              27. 0018013: CRE800 - Pagos automáticos de Bajas
  28.0       16/03/2011   JMF              28. 0017970: ENSA101- Campos pantallas de siniestros y mejoras
  29.0       14/04/2011   APD              29. 0018263: ENSA101-Mejoras Prestaciones II
  30.0       05/05/2011   APD              30. 0018451: ENSA101-Mostrar el recibo de pago de siniestro después de enviarlo a SAP
  31.0       04/05/2011   JMP              31. 0018336: LCOL701 - Desarrollo Trámites Siniestros.
  32.0       14/06/2011   SRA              32. 0018554: LCOL701 - Desarrollo de Modificación de datos cabecera siniestro y ver histórico (BBDD).
  33.0       12/07/2011   ICV              33. 0018977: LCOL_S001 - SIN -Asignación automática de tramitadores
  34.0       21/06/2011   JMF              34. 0018812: ENSA102-Proceso de alta de prestación en forma de renta actuarial
  35.0       13/10/2011   JMC              35. 0019601: LCOL_S001-SIN - Subestado del pago
  36.0       07/11/2011   MDS              36. 0019981: LCOL_S001-SIN - ReteIVA y ReteICA en pagos
  37.0       21/10/2011   JMP              37. 0019832 LCOL_S001-SIN - Carpeta de siniestro
  38.0       21/1172011   APD              38. 0018946: LCOL_P001 - PER - Visibilidad en personas
  39.0       10/11/2011   MDS              39. 0019821: LCOL_S001-SIN - Tramitacion judicial
  40.0       28/11/2011   JMF              40. 0020138 LCOL_S001-SIN - Destinatario en listas restrictivas
  41.0       09/12/2011   JMF              41. 0020472: LCOL_TEST-SIN - Reserva añadida sobre garantía contratada (no siniestrada aún)
  42.0       05/01/2012   ETM              42. 003: LCOL_S001-SIN - Declarante del siniestro
  43.0       24/01/2012   JMP              43. 0018423: LCOL705 - Multimoneda - Resolver nota 104967
  44.0       16/02/2012   JMP              44. 21307/107043: LCOL_S001-SIN - Documentación obligatoria bloquea pagos
  45.0       02/03/2012   MDS              45. 0021172: LCOL_S001-SIN - Alta/Modificación masiva de reservas
  46.0       22/03/2012   JMF              0021781: LCOL_S001-SIN - Nuevos campos resultado búsqueda sinies.
  47.0       03/05/2012   ETM              47.0022048: LCOL_S001-SIN - Nº de juzgado cambiar tipo
  48.0       07/05/2012   MDS              48.0021855: MDP_S001-SIN - Detalle fraude
  49.0       16/05/2012   JMF              0022099: MDP_S001-SIN - Trámite de asistencia
  50.0       31/05/2015   ASN              0022108: MDP_S001-SIN - Movimiento de trámites
  51.0       22/05/2012   MDS              0021817: MDP_S001-SIN - Agente en el alta de siniestros
  52.0       28/06/2012   ASN              39. 0022670: SIN - Mensajes en alta de siniestros (y nuevo parametro)
  53.0       05/07/2012   ASN              40. 0022603: MDP_S001-Reserva global
  54.0       09/07/2012   JMF              0022490: LCOL_S001-SIN - Poder indicar que se generen los pagos como el último (Id=4604)
  55.0       18/07/2012   ASN              0022702: MDP_S001-SIN - vgobsiniestro.tramitaciones.EXISTS(i)
  56.0       19/07/2012   JMF              0022153 MDP_S001-SIN - Número de presiniestro y documentación
  57.0       31/08/2012   ASN              0023101: LCOL_S001-SIN - Apuntes de agenda automáticos
  58.0       03/10/2012   MDS              0023805: MDP_S001-SIN - Visualizar/Ocultar casilla de asistencia en la pantalla de alta de siniestros
  59.0       24/10/2012   JMF              0023536 LCOL_S001-SIN - Tramitación Otros
  60.0       24/10/2012   JMF              0023540 LCOL_S001-SIN - Tramitación lesionados
  61.0       05/11/2012   JMF              0023643: MDP_S001-SIN - Ocultar tramite global
  62.0       18/12/2012   DCT              0025149: CRT904-Incidencias varias CRT
  63.0       23/01/2013   ASN              0025812: LCOL_S010-SIN - Garantías según tramitación
  64.0       15/03/2013   ASN              0026108: LCOL_S010-SIN - LCOL Tipo de gasto en reservas
  65.0       30/10/2013   ASN              0024708: (POSPG500)- Parametrizacion - Sinestros/0157275 actualizar preguntas
  66.0       04/02/2014   FAL              0025537: RSA000 - Gestión de incidencias
  67.0       26/02/2014   NSS              0028830/0166530: (POSND500)-N. Desarrollo: Siniestros: Compensaci?n cartera vs. Siniestros
  68.0       05/03/2014   JTT              0030299/167375: Controlar els errors d'assignació el tramitador per defecte
  69.0       04/03/2014   NSS              0029224/0166661: (POSAN500)-Analisis-Siniestros-Nuevos Desarrollos
  70.0       07/03/2014   NSS              0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros
  71.0       12/03/2014   DEV              0030342: POSPG500-Modulo de Autorizaciones para pagos de Siniestros
  72.0       11/04/2014   FAL              0025537: RSA000 - Gestión de incidencias
  73.0       16/04/2014   NSS              0031040: POSPG500-Crear un nuevo tipo de destinatario para los colectivos
  74.0       22/04/2014   NSS              0029989/165377: LCOL_S001-SIN - Rechazo de tramitación única
  75.0       14/07/2014   NSS              0031872/0178559: TRQ - SIN-Parametrización Siniestros
  76.0       17/07/2014   JTT              0028830/179900: Revision del proceso de pago de compensaciones
  77.0       27/08/2014   JTT              0031294/177836: Añadir el campo idres a los objetos de reservas y pago_gar
  78.0       20/01/2014   JTT              0033544/192270: Compensación recibos pendientes al saldar/prorrogar la poliza
  79.0       24/02/2015   FRC              0033345/0193484: Generación de documentos en los eventos de siniestros.
  80.0       02/03/2015   JTT              0034622/0197860: Fecha de formalización de siniestros
  81.0       20/03/2015   JTT              0033798/0200603: Compensación de pagos vs cartera
  82.0       14/04/2015   JCP              0035102/0200437: Validacion de Innominados
  83.0       19/05/2015   JTT              0033798/0201888: Compensacion de pagos vs cartera - Recibos agrupados
  84.0       08/05/2015   VCG              0032470-0204062: Añadir la referencia externa en el buscador de siniestros
  85.0       27/05/2015   VCG              0036232/205807: POS - Implantació d'iAXIS-Modificación consulta de siniestros- f_consultasini
  86.0       16/06/2015   CJMR             0036232/207513: Añadir la referencia externa en el buscador de siniestros
  87.0       01/07/2015   IGIL             0035888/203837 quitar UPPER a NNUMNIF
  88.0       05/01/2016   JCP              0039475/222692: Modificar la select para recuperar también el nuevo campo fdeteccion de sin_siniestro
  89.0       26/05/2016   ACL              Bug 41501: Soporte. Se crea la función f_anula_pago_sin, la cual llama la función f_anula_pago.
  90.0       26/05/2016   ACL              Bug 41501: Soporte. Se modifica la función f_tratar_pagos.
  91.0       26/05/2016   ACL              Bug 41501: Soporte. Se modifica la función f_anula_pago_inicial por f_anula_pago.
  92.0       10/09/2016   JAEG             CONF-309: Desarrollo AT_CONF_SIN-07_ADAPTACION_CORE_SINIESTROS_BUSQUEDA_ANTECEDENTES
  93.0       01/12/2016   OGQ              CONF-513: Incidencia de siniestros (modificar presiniestro por comunicado).
  94.0       02/05/2017   JGONZALEZ        CONF-693: Se incluyen campos de audiencia en agenda de citaciones
  95.0       11/08/2017   JGONZALEZ        CONF-1005: Desarrollo de GAP 67 solicitud de apoyo tecnico
  96.0       24/04/2018   ACL              0000619: Se modifica la función f_consultasini para que realice búsquedas por el campo descripción.
  97.0       19/03/2019   AABC             IAXIS-2066 Se realiza la modificacion para la citacion cuando no existe datos.
  98.0       20/03/2019   SWAPNIL        Cambios de IAXIS-2069
  99.0       27/03/2019   AABC             IAXIS-2169 Adicion de fecha de alta en la consulta.
  100.0      28/03/2019   AABC             IAXIS-2067 Adicion tipo de siniestro.
  101.0      12/04/2019   AABC             IAXIS 3663 AABC 12/04/2019 Adicion campo observacion
  102.0      24/04/2019   AABC             IAXIS 3595 AABC 24/04/2019 se realizan cambios de proceso Judicial
  103.0    02/05/2019   SWAPNIL      Cambios de IAXIS-3662
  104.0      24/05/2019   AABC             IAXIS 3642-3662 cambio en tiquetes aereos y agencias 
  105.0      19/12/2019   DFRP             IAXIS-7731: LISTENER Cambio de estado del siniestro y creaci󮠤e Campos: Valor, Fecha, número de pago, que comunica SAP a IAXIS  
  106.0      20/12/2019   IRDR             IAXIS-4131: Se agrega un campo(CMONICAPRIE) a la tabla sin_tramita_amparo para la visualizacion de la moneda que corresponde al Valor asegurado (axissin006 - Listado de Amparos Afectados)
  ******************************************************************************/
  e_object_error EXCEPTION;
  e_param_error  EXCEPTION;
  e_nfactura_error  EXCEPTION;
  e_importe_error  EXCEPTION;
  -- BUG 9020 - 10/03/2009 - XPL I XV - Nou model de dades del Sinistre
  /*************************************************************************
  Devuelve los siniestros que cumplan con el criterio de selección
  param in pnpoliza     : númerod de póliza
  param in pncert       : número de cerificado por defecto 0
  param in pnsinies     : número del siniestro
  param in cestsin      : código situación del siniestro
  param in pnnumide     : número identidad persona
  param in psnip        : número identificador externo
  param in pbuscar      : nombre+apellidos a buscar de la persona
  param in ptipopersona : tipo de persona
  1 tomador
  2 asegurado
  param out mensajes    : mensajes de error
  return                : ref cursor
  *************************************************************************/
FUNCTION f_consultasini_old(
    pnpoliza  IN NUMBER,
    pncertif  IN NUMBER DEFAULT -1,
    pnsinies  IN NUMBER,
    pcestsin  IN NUMBER,
    pnnumide  IN VARCHAR2,
    psnip     IN VARCHAR2,
    pbuscar   IN VARCHAR2,
    ptipopers IN NUMBER,
    pnsubest  IN NUMBER,
    mensajes  IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.ConsultaSini_old';
  vparam      VARCHAR2(500) := 'parámetros - pnpoliza: ' || pnpoliza || ' - pncertif: ' || pncertif || ' - pnsinies: ' || pnsinies || ' - pcestsin: ' || pcestsin || ' - pnnumide: ' || pnnumide || ' - psnip: ' || psnip || ' - pbuscar: ' || pbuscar || ' - ptipopers: ' || ptipopers || ' - pnsubest:' || pnsubest;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
  vbuscar VARCHAR2(2000);
  vsubus  VARCHAR2(500);
  vtabtp  VARCHAR2(10);
  vauxnom VARCHAR2(200);
BEGIN
  vpasexec := 3;
  -- Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación
  --                                se añade la subselect con la tabla agentes_agente
  -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
  -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
  vbuscar := ' WHERE rownum <= NVL(' || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null') || ', rownum) ' || '   AND (se.cagente,se.cempres) in (select cagente,cempres from agentes_agente_pol) ' || '   AND se.sseguro = si.sseguro '
  --|| '   AND sa.sseguro = se.sseguro '   -- dra 04/12/2008: bug mantis 8359
  || '   AND si.cestsin = dv.catribu ' || '   AND dv.cvalor = 6 ' || '   AND dv.cidioma = ' || pac_md_common.f_get_cxtidioma || ' ';
  -- Bug 10127 - APD - 19/05/2009 - fin
  vpasexec    := 5;
  IF pnpoliza IS NOT NULL THEN
    vbuscar   := vbuscar || ' and se.npoliza = ' || pnpoliza;
  END IF;
  IF NVL(pncertif, -1) <> -1 THEN
    vbuscar            := vbuscar || ' and se.ncertif = ' || pncertif;
  END IF;
  IF pnsinies IS NOT NULL THEN
    vbuscar   := vbuscar || ' and si.nsinies = ' || pnsinies;
  END IF;
  IF pcestsin IS NOT NULL THEN
    vbuscar   := vbuscar || ' and si.cestsin = ' || pcestsin;
  END IF;
  IF pnsubest IS NOT NULL THEN
    vbuscar   := vbuscar || ' and si.nsubest = ' || pnsubest;
  END IF;
  vpasexec := 7;
  -- Buscar per personas
  IF (pnnumide IS NOT NULL
    -- Ini bug 16445 - ETM - 03/12/2010
    OR NVL(psnip, '0') <> '0'
    -- Fin bug 16445 - ETM - 03/12/2010
    OR pbuscar IS NOT NULL) AND NVL(ptipopers, 0) > 0 THEN
    --
    IF ptipopers    = 1 THEN -- Prenador
      vtabtp       := 'TOMADORES';
    ELSIF ptipopers = 2 THEN -- Asegurat
      vtabtp       := 'ASEGURADOS';
    END IF;
    vpasexec  := 9;
    IF vtabtp IS NOT NULL THEN
      vsubus  := ' AND se.sseguro IN (SELECT a.sseguro FROM ' || vtabtp || ' a, PERSONAS p WHERE a.sperson = p.sperson';
      -- BUG11183:DRA:30/09/2009:Inici
      IF ptipopers = 2 THEN -- Asegurat
        vsubus    := vsubus || ' AND a.ffecfin IS NULL';
      END IF;
      -- BUG11183:DRA:30/09/2009:Fi
      IF pnnumide IS NOT NULL THEN
        vsubus    := vsubus || ' AND upper(p.nnumnif) = upper(''' || pnnumide || ''')';
      END IF;
      -- Ini bug 16445 - ETM - 03/12/2010
      IF NVL(psnip, '0') <> '0' THEN
        vsubus           := vsubus || ' AND upper(p.snip)= upper(' || CHR(39) || psnip || CHR(39) || ')';
        -- Fin bug 16445 - ETM - 03/12/2010
      END IF;
      IF pbuscar IS NOT NULL THEN
        vnumerr  := f_strstd(pbuscar, vauxnom);
        vsubus   := vsubus || ' AND upper(p.tbuscar) like upper(''%' || vauxnom || '%'')';
      END IF;
      vsubus := vsubus || ')';
    END IF;
  END IF;
  vpasexec := 11;
  -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
  vsquery := ' SELECT se.sseguro, se.npoliza, se.ncertif, si.nsinies, si.nriesgo,
PAC_MD_OBTENERDATOS.F_Desriesgos(''POL'', si.sseguro, si.nriesgo) as triesgo,
dv.tatribu as testsin,
f_desproducto_t(se.cramo,se.cmodali,se.ctipseg,se.ccolect,1,PAC_MD_COMMON.F_Get_CXTIDIOMA) as tproduc
FROM seguros se, siniestros si, detvalores dv ' --, seguros_agente sa '
  || vbuscar || vsubus;                                                                                                                                                                                                                                                                                                                                                                                                                              -- dra 04/12/2008: bug mantis 8359
  -- Bug 10127 - APD - 19/05/2009 - fin
  vcursor                                                                                    := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_SINIESTROS.F_CONSULTASINI', 1, 4, mensajes) <> 0 THEN
    IF vcursor%ISOPEN THEN
      CLOSE vcursor;
    END IF;
  END IF;
  RETURN vcursor;
EXCEPTION
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_consultasini_old;
/***********************************************************************
Recupera los datos del último recibo de la póliza
param in psseguro  : código de seguro
param out mensajes : mensajes de error
return             : ref cursor
***********************************************************************/
FUNCTION f_get_pollastrecibo_old(
    psseguro IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_pollastrecibo_old';
  vparam      VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 3;
  vsquery  := 'select r.nrecibo, ' || '         to_date(to_char(fefecto,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fefecto, ' || '         to_date(to_char(fvencim,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fvencim, ' || '         itotalr as iconcep, ' || '         cestrec, ' || '         (select tatribu from detvalores where cvalor = 1 and catribu = cestrec and cidioma = ' || pac_md_common.f_get_cxtidioma || ') as testrec, ' || '         ctiprec, ' || '         (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = ' || pac_md_common.f_get_cxtidioma || ') as ttiprec  ' || ' from recibos r, movrecibo m, vdetrecibos v ' || ' where  r.sseguro = ' || psseguro || ' and r.nrecibo = m.nrecibo ' || ' and r.nrecibo = (select max(r2.nrecibo) from recibos r2   where r2.sseguro = r.sseguro) ' || ' and m.smovrec = (select max(m2.smovrec) from movrecibo m2 where m2.nrecibo = m.nrecibo) ' ||
  ' and r.nrecibo = v.nrecibo ';
  vpasexec := 5;
  vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN vcursor;
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_get_pollastrecibo_old;
/***********************************************************************
Recupera los datos de los recibos de la póliza
param in psseguro  : código de seguro
param out mensajes : mensajes de error
return             : ref cursor
***********************************************************************/
FUNCTION f_get_polrecibos_old(
    psseguro IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_polrecibos_old';
  vparam      VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 3;
  vsquery  := 'select r.nrecibo, ' || '         to_date(to_char(fefecto,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fefecto, ' || '         to_date(to_char(fvencim,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fvencim, ' || '         itotalr as iconcep, ' || '         cestrec, ' || '         (select tatribu from detvalores where cvalor = 1 and catribu = cestrec and cidioma = ' || pac_md_common.f_get_cxtidioma || ') as testrec, ' || '         ctiprec, ' || '         (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = ' || pac_md_common.f_get_cxtidioma || ') as ttiprec  ' || ' from recibos r, movrecibo m, vdetrecibos v ' || ' where  r.sseguro = ' || psseguro || ' and r.nrecibo = m.nrecibo ' || ' and m.smovrec = (select max(m2.smovrec) from movrecibo m2 where m2.nrecibo = m.nrecibo) ' || ' and r.nrecibo = v.nrecibo ' || ' order by r.fefecto desc ';
  vpasexec := 5;
  vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN vcursor;
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_get_polrecibos_old;
/***********************************************************************
Recupera las garantia vigentes de una la póliza para un determinado riesgo,
a fecha de ocurrencia del siniestro
param in psseguro  : código de seguro
param in pnriesgo  : número de riesgo
param in pfsinies  : fecha de ocurrencia del siniestro
param out mensajes : mensajes de error
return             : ref cursor
***********************************************************************/
FUNCTION f_get_polgarantias_old(
    psseguro IN NUMBER,
    pnriesgo IN NUMBER,
    pfsinies IN DATE,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_polgarantias_old';
  vparam      VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro || ' - pnriesgo: ' || pnriesgo || ' - pfsinies: ' || pfsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL OR pnriesgo IS NULL OR pfsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 3;
  --Consulta per recuperar les garanties vigents a data d'ocurrencia del sinistre.
  vsquery  := 'select distinct gs.cgarant, gg.tgarant, gs.icapital ' || ' from garanseg gs, garangen gg ' || ' where gs.sseguro = ' || psseguro || ' and gs.nriesgo =   ' || pnriesgo || ' and gs.finiefe <=  to_date(''' || TO_CHAR(pfsinies, 'dd/mm/yyyy hh24:mi:ss') || ''',''dd/mm/yyyy hh24:mi:ss'') ' || ' and (gs.ffinefe is null or gs.ffinefe > to_date(''' || TO_CHAR(pfsinies, 'dd/mm/yyyy hh24:mi:ss') || ''',''dd/mm/yyyy hh24:mi:ss'') ) ' || ' and gs.cgarant = gg.cgarant ' || ' and gg.cidioma = ' || pac_md_common.f_get_cxtidioma;
  vpasexec := 5;
  vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN vcursor;
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_get_polgarantias_old;
/***********************************************************************
Recupera los documentos necesarios para poder realizar la apertura del siniestro.
param in psseguro  : código de seguro
param out mensajes : mensajes de error
return             : ref cursor
***********************************************************************/
FUNCTION f_get_documentacion_old(
    psseguro IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_documentacion_old';
  vparam      VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  vsquery  := ' select 1 as cdocume, ''Documento nacional de identidad'' tdocume ' || ' from dual ';
  vpasexec := 3;
  vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN vcursor;
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_get_documentacion_old;
/***********************************************************************
Recupera los datos de un determinado siniestro
param in  pnsinies  : número de siniestro
param out mensajes  : mensajes de error
return              : OB_IAX_SINIESTROS con la información del siniestro
null -> Se ha producido un error
***********************************************************************/
FUNCTION f_get_siniestro(
    pcempres IN NUMBER,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pnsinies IN VARCHAR2,
    mensajes IN OUT t_iax_mensajes)
  RETURN ob_iax_siniestros
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_SINIESTRO';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pcempres=' || pcempres;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vobsini ob_iax_siniestros;
  squery   VARCHAR2(5000);
  v_index  NUMBER(5);
  v_cont   NUMBER(5);
  v_cont2  NUMBER(5);
  j        NUMBER(5);
  pcunitra VARCHAR2(100);
  pctramit VARCHAR2(100);
  ptramites t_iax_sin_tramite;
  v_ntramte sin_tramite.ntramte%TYPE;
  vsproduc NUMBER;
  vcactivi NUMBER;
BEGIN
  vobsini             := ob_iax_siniestros();
  vpasexec            := 3;
  IF vobsini.tramites IS NULL THEN
    vobsini.tramites  := t_iax_sin_tramite();
  END IF;
  IF pnsinies IS NOT NULL THEN
    --Recuperem  les dades generals del sinistre
    vpasexec   := 4;
    vnumerr    := f_get_dades_sini(pnsinies, vobsini, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec   := 5;
    vnumerr    := f_get_movsiniestros(pnsinies, vobsini.movimientos, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    --         vnumerr := f_get_listagenda(pnsinies, 0, vobsini.agenda, mensajes);
    vpasexec := 6;
    -- BUG 18336 - 04/05/2011 - JMP - Recuperamos los trámites del siniestro
    vnumerr          := pac_md_sin_tramite.f_get_tramites(pnsinies, ptramites, mensajes);
    vobsini.tramites := ptramites;
    IF vnumerr       <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec   := 7;
    vnumerr    := f_get_tramitaciones(pnsinies, vobsini.tramitaciones, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec                                                               := 8;
    IF vobsini.tramitaciones                                               IS NOT NULL AND vobsini.tramitaciones.COUNT > 0 THEN
      vobsini.agenda                                                       := vobsini.tramitaciones(vobsini.tramitaciones.FIRST).agenda;
      IF vobsini.tramitaciones(vobsini.tramitaciones.FIRST).localizaciones IS NOT NULL AND vobsini.tramitaciones(vobsini.tramitaciones.FIRST).localizaciones.COUNT > 0 THEN
        vobsini.localiza                                                   := vobsini.tramitaciones(vobsini.tramitaciones.FIRST).localizaciones (vobsini.tramitaciones(vobsini.tramitaciones.FIRST).localizaciones.FIRST);
      END IF;
    END IF;
    vpasexec := 9;
    vnumerr  := f_get_referencias(pnsinies, vobsini.referencias, mensajes);
    /*
    vobsini.referencias := t_iax_siniestro_referencias();
    vobsini.referencias.extend;
    vobsini.referencias(vobsini.referencias.last) := ob_iax_siniestro_referencias();
    vobsini.referencias(vobsini.referencias.last).nsinies := 1;*/
    --Ini Bug 25800 - NSS- 04/03/2013
    vpasexec := 10;
    -- Ini Bug 24708:NSS:31/10/2013
    IF psproduc IS NULL AND pcactivi IS NULL THEN
      vnumerr   := pac_siniestros.f_get_producto(pnsinies, vsproduc, vcactivi);
    ELSE
      vsproduc := psproduc;
      vcactivi := pcactivi;
    END IF;
    -- Fin Bug 24708:NSS:31/10/2013
    vnumerr    := f_get_preguntas(vsproduc, vcactivi, pnsinies, vobsini.preguntas, mensajes); --24708:NSS:31/10/2013
    IF vnumerr <> 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
      RAISE e_object_error;
    END IF;
    --Fin Bug 25800 - NSS - 04/03/2013
  ELSE
    vpasexec            := 2;
    vobsini.movimientos := t_iax_sin_movsiniestro();
    vobsini.movimientos.EXTEND;
    v_index                      := vobsini.movimientos.LAST;
    vobsini.movimientos(v_index) := ob_iax_sin_movsiniestro();
    vpasexec                     := 3;
    --Ini Bug.: 18977 - 12/07/2011 - ICV
    /*vnumerr := pac_siniestros.f_get_unitradefecte(pcempres, pcunitra, pctramit);*/
    -- 23101:ASN:28/08/2012 ini
    /*
    vnumerr := pac_md_siniestros.f_get_tramitador_defecto(pcempres, f_user, NULL,
    vobsini.ccausin,
    vobsini.cmotsin, pnsinies,
    NULL,   -- 22108:ASN:04/06/2012
    NULL, pcunitra, pctramit,
    mensajes);
    vpasexec := 4;
    IF NVL(vnumerr, 99999) > 1 THEN   --El error 1 es de tramitador por defecto U000
    RAISE e_object_error;
    END IF;
    */
    pcunitra := 'U000';
    pctramit := 'T000';
    -- 23101:ASN:28/08/2012 fin
    vnumerr := 0;
    --Fin Bug 18977
    --busca tramitador i unitat tramitador per crear l'objecte de moviments
    vnumerr    := f_set_objeto_movsiniestro(pnsinies, 0, v_index - 1, f_sysdate, NULL, pcunitra, pctramit, vobsini.movimientos(v_index), mensajes);
    vpasexec   := 4;
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec := 5;
    -- BUG 18336 - 04/05/2011 - JMP - Si el producto tiene trámites, inicializamos la colección de trámites con el trámite por defecto
    vnumerr    := pac_md_sin_tramite.f_inicializa_tramites(psproduc, pcactivi, pnsinies, NULL, vobsini.tramites, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec := 6;
    -- BUG 19189 - 29/08/2011 - JRB - Se añade bucle que busque entre todas las tramitaciones
    IF vobsini.tramites IS NOT NULL AND vobsini.tramites.COUNT > 0 THEN
      --v_ntramte := vobsini.tramites(vobsini.tramites.LAST).ntramte;
      FOR i IN vobsini.tramites.FIRST .. vobsini.tramites.LAST
      LOOP
        IF vobsini.tramites.EXISTS(i) THEN
          v_ntramte := vobsini.tramites(i).ntramte;
          -- BUG 18336 - 04/05/2011 - JMP - Si el producto tiene trámites, le pasamos el número de trámite por defecto
          vnumerr := f_inicializa_tramitaciones(psproduc, pcactivi, pnsinies, pcunitra, pctramit, vobsini.tramites(i).ctramte,
          -- Bug 0022099
          0,
          -- bug21196:ASN:26/03/2012 'valor = tramitacion apertura'
          v_ntramte, -- Bug 0022099
          vobsini.tramitaciones, mensajes);
          IF vnumerr <> 0 THEN
            RAISE e_object_error;
          END IF;
          /* IF mensajes IS NOT NULL THEN
          IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
          END IF;
          END IF;*/
        END IF;
      END LOOP;
    ELSE
      IF vobsini.tramites.COUNT = 0 THEN
        vnumerr                := f_inicializa_tramitaciones(psproduc, pcactivi, pnsinies, pcunitra, pctramit, 0,
        -- Bug 0022099
        0,
        -- bug21196:ASN:26/03/2012 'valor = tramitacion apertura'
        NULL, -- Bug 0022099
        vobsini.tramitaciones, mensajes);
      END IF;
    END IF;
    vpasexec := 8;
    /*         IF vobsini.tramitaciones IS NOT NULL
    AND vobsini.tramitaciones.COUNT > 0 THEN
    vpasexec := 7;
    v_index := vobsini.tramitaciones.LAST;
    vobsini.tramitaciones(v_index).movimientos := t_iax_sin_trami_movimiento();
    vobsini.tramitaciones(v_index).movimientos.EXTEND;
    j := vobsini.tramitaciones(v_index).movimientos.LAST;
    vpasexec := 8;
    vobsini.tramitaciones(v_index).movimientos(j) := ob_iax_sin_trami_movimiento();
    vpasexec := 9;
    vnumerr :=
    f_set_objeto_sinmovtramit(pnsinies, v_index - 1, j - 1, pcunitra, pctramit, 0,
    0, f_sysdate,
    vobsini.tramitaciones(v_index).movimientos(j),
    mensajes);
    vpasexec := 10;
    IF vnumerr <> 0 THEN
    RAISE e_object_error;
    END IF;
    END IF;*/
  END IF;
  vpasexec := 9;
  --Ini Bug 21855 - MDS - 08/05/2012
  vnumerr    := f_get_defraudadores(pnsinies, vobsini.defraudadores, mensajes);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  --Fin Bug 21855 - MDS - 08/05/2012
  RETURN vobsini;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN NULL;
END f_get_siniestro;
FUNCTION f_inicializa_tramitaciones(
    psproduc       IN NUMBER,
    pcactivi       IN NUMBER,
    pnsinies       IN VARCHAR2,
    pcunitra       IN VARCHAR2,
    pctramit       IN VARCHAR2,
    pctramte       IN NUMBER,              -- Bug : 0018336 - JMC - 02/05/2011
    pccauest       IN NUMBER DEFAULT NULL, -- Bug 21196
    pntramte       IN NUMBER DEFAULT NULL, -- Bug 0022099
    ttramitaciones IN OUT t_iax_sin_tramitacion,
    mensajes       IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_inicializa_tramitaciones';
  vparam      VARCHAR2(500) := 'parámetros - psproduc: ' || psproduc || ' pcactivi: ' || pcactivi || ' pnsinies: ' || pnsinies || ' pcunitra: ' || pcunitra || ' pctramit: ' || pctramit || ' pctramte: ' || pctramte || ' pntramte=' || pntramte || ' pccauest=' || pccauest;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  v_index     NUMBER(5)     := 0;
  v_cont      NUMBER(5);
  j           NUMBER(5);
  vctcausin   NUMBER;
  CURSOR cur_protramita
  IS
    SELECT ctramit,
      cinform
    FROM sin_pro_tramitacion
    WHERE sproduc = psproduc
    AND cactivi   = pcactivi
    AND cgenaut   = 1
    AND(ctramte   = pctramte
    OR pctramte  IS NULL)
  UNION
  SELECT ctramit,
    cinform
  FROM sin_pro_tramitacion
  WHERE sproduc = psproduc
  AND(ctramte   = pctramte
  OR pctramte  IS NULL
  OR pctramte   = 0)
  AND cactivi   = 0
  AND NOT EXISTS
    (SELECT 1
    FROM sin_pro_tramitacion
    WHERE sproduc = psproduc
    AND cactivi   = pcactivi
    AND(ctramte   = pctramte
    OR pctramte  IS NULL)
    )
  AND cgenaut = 1
  -- 25088:ASN:18/12/2012 ini
  UNION
  SELECT ctramit,
    cinform
  FROM sin_pro_tramitacion
  WHERE sproduc = psproduc
  AND cactivi   = pcactivi
  AND ctramte   = pctramte
  AND ctramit   =
    (SELECT ctramit
    FROM sin_prod_tramite
    WHERE sproduc = psproduc
    AND cactivi   = pcactivi
    AND ctramte   = pctramte
    )
    -- 25088:ASN:18/12/2012 fin
  ORDER BY ctramit;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psproduc IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec          := 2;
  IF ttramitaciones IS NULL THEN
    ttramitaciones  := t_iax_sin_tramitacion();
  END IF;
  vpasexec := 3;
  v_index  := ttramitaciones.LAST;
  v_cont   := ttramitaciones.COUNT;
  vpasexec := 4;
  FOR reg IN cur_protramita
  LOOP
    -- ini Bug 0022099 - 16/05/2012 - JMF: v_index
    IF ttramitaciones.LAST   IS NOT NULL THEN
      IF ttramitaciones.COUNT > 0 THEN
        v_index              := ttramitaciones(ttramitaciones.LAST).ntramit + 1;
      ELSE
        v_index := 0;
      END IF;
    ELSE
      v_index := 0;
    END IF;
    -- fin Bug 0022099 - 16/05/2012 - JMF: v_index
    vpasexec := 5;
    ttramitaciones.EXTEND;
    vpasexec                            := 6;
    ttramitaciones(ttramitaciones.LAST) := ob_iax_sin_tramitacion();
    vpasexec                            := 7;
    SELECT ctcausin
    INTO vctcausin
    FROM sin_codtramitacion
    WHERE ctramit = reg.ctramit;
    vpasexec     := 8;
    -- Bug 0022099 - 16/05/2012 - JMF: v_index
    vnumerr            := f_set_objeto_sintramitacion(pnsinies, v_index, reg.ctramit, vctcausin, reg.cinform, NULL, NULL, NULL, NULL, NULL, NULL, ttramitaciones(ttramitaciones.LAST), mensajes, pntramte);
    IF mensajes        IS NOT NULL THEN
      IF mensajes.COUNT > 0 THEN
        RETURN 1;
      END IF;
    END IF;
    vpasexec                                        := 9;
    ttramitaciones(ttramitaciones.LAST).movimientos := t_iax_sin_trami_movimiento();
    vpasexec                                        := 10;
    ttramitaciones(ttramitaciones.LAST).movimientos.EXTEND;
    vpasexec                                           := 11;
    j                                                  := ttramitaciones(ttramitaciones.LAST).movimientos.LAST;
    vpasexec                                           := 12;
    ttramitaciones(ttramitaciones.LAST).movimientos(j) := ob_iax_sin_trami_movimiento();
    vpasexec                                           := 13;
    vnumerr                                            := -- Bug 0022099 - 16/05/2012 - JMF: v_index
    f_set_objeto_sinmovtramit(pnsinies, v_index, j, pcunitra, pctramit, 0, NULL, f_sysdate, pccauest,
    -- bug 21196
    ttramitaciones(ttramitaciones.last) .movimientos(j), mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
  END LOOP;
  vpasexec := 14;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_inicializa_tramitaciones;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.tramitaciones(i).movimientos
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
nmovtra        NUMBER(3),   --Número Movimiento Tramitación
cunitra        VARCHAR2(4),   --Código Unidad Tramitación
tunitra        VARCHAR2(100),   -- desc. Unidad Tramitación
ctramitad      VARCHAR2(4),   --Código Tramitador
ttramitad      VARCHAR2(100),   --Desc. Tramitador
cesttra        NUMBER(3),   --Código Estado Tramitación
testtra        VARCHAR2(100),   --Desc. Estado Tramitación
csubtra        NUMBER(2),   --Código Subestado Tramitación
tsubtra        VARCHAR2(100),   --Desc. Subestado Tramitación
festtra        DATE,   --Fecha Estado Tramitación
cusualt        VARCHAR2(500),   --Código Usuario Alta
falta          DATE,   --Fecha Alta
*************************************************************************/
FUNCTION f_set_objeto_movsiniestro(
    pnsinies   IN VARCHAR2,
    pnmovsin   IN NUMBER,
    pcestsin   IN NUMBER,
    pfestsin   IN DATE,
    pccauest   IN NUMBER,
    pcunitra   IN VARCHAR2,
    pctramitad IN VARCHAR2,
    vmovsin    IN OUT ob_iax_sin_movsiniestro,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_set_objeto_movsiniestro';
  vparam      VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pcestsin: ' || pcestsin || ' - pnmovsin: ' || pnmovsin || ' - pcunitra: ' || pcunitra;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vtunitra    VARCHAR2(1000) := '';
  vttramitad  VARCHAR2(1000) := '';
  vtcauest    VARCHAR2(1000) := '';
  vcborrab    NUMBER(4);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnmovsin IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 5;
  BEGIN
    SELECT ttramitad
    INTO vtunitra
    FROM sin_codtramitador tram
    WHERE tram.ctramitad = pcunitra;
    SELECT ttramitad
    INTO vttramitad
    FROM sin_codtramitador tram
    WHERE tram.ctramitad = pctramitad;
  EXCEPTION
  WHEN OTHERS THEN
    vtunitra   := '';
    vttramitad := '';
  END;
  BEGIN
    SELECT tcauest
    INTO vtcauest
    FROM sin_descauest
    WHERE ccauest = pccauest
    AND cestsin   = pcestsin
    AND cidioma   = pac_md_common.f_get_cxtidioma;
  EXCEPTION
  WHEN OTHERS THEN
    vtcauest := '';
  END;
  vmovsin.nsinies   := pnsinies;
  vmovsin.nmovsin   := pnmovsin;
  vmovsin.festsin   := pfestsin;
  vmovsin.ccauest   := pccauest;
  vmovsin.tcauest   := vtcauest;
  vmovsin.cunitra   := pcunitra;
  vmovsin.tunitra   := vtunitra;
  vmovsin.ctramitad := pctramitad;
  vmovsin.ttramitad := vttramitad;
  vmovsin.cestsin   := pcestsin;
  vmovsin.testsin   := ff_desvalorfijo(6, pac_md_common.f_get_cxtidioma, pcestsin);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_movsiniestro;
/***********************************************************************
Recupera los datos generales de un determinado siniestro
param in  pnsinies  : número de siniestro
param out ob_iax_siniestros : ob_iax_siniestros
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_dades_sini(
    pnsinies IN VARCHAR2,
    pobsini  IN OUT ob_iax_siniestros,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_Dades_Sini';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  cur sys_refcursor;
  vsquery   VARCHAR2(5000);
  ptriesgo1 VARCHAR2(500);
  ptriesgo2 VARCHAR2(500);
  ptriesgo3 VARCHAR2(500);
  obpersona ob_iax_personas;
  vcagente NUMBER;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  obpersona := ob_iax_personas();
  vpasexec  := 3;
  --Recuperem les dades generals del sinistre
  vnumerr                                                                               := pac_siniestros.f_get_dades_sini(pnsinies, pac_md_common.f_get_cxtidioma, vsquery, pac_md_common.f_get_cxtagente);
  IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_SINIESTROS.F_GET_SINI', 1, 4, mensajes) = 0 THEN
    cur                                                                                 := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  END IF;
  vpasexec := 4;
  LOOP
    -- jbn 19830 sin.falta
    -- BUG 14587 - PFA - 13/08/2010 - Añadir campo siniestro compañia
    -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en búsqueda siniestros
    -- bug 19896 --ETM  -20/12/2011-- Añadir campo nombre 2 al declarante
    -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
    -- BUG17539 - JTS - 10/02/2011
    -- BUG18748 - JBN
    -- Bug 21817 - MDS - 2/05/2012
    -- BUG 0023643 - 05/11/2012 - JMF : ireserva9999
    -- BUG 0024675 - 15/11/2012 - JMF: csalvam
    FETCH cur
    INTO pobsini.nsinies,
      pobsini.sseguro,
      pobsini.nriesgo,
      pobsini.triesgo,
      pobsini.fsinies,
      pobsini.hsinies,
      pobsini.falta,
      pobsini.fnotifi,
      pobsini.ccausin,
      pobsini.nsincia,
      pobsini.ccompani,
      pobsini.tcompani,
      pobsini.npresin,
      pobsini.tcausin,
      pobsini.cmotsin,
      pobsini.tmotsin,
      pobsini.cevento,
      pobsini.tevento,
      pobsini.creclama,
      pobsini.treclama,
      pobsini.tsinies,
      pobsini.cculpab,
      pobsini.tculpab,
      pobsini.nasegur,
      pobsini.ctipdec,
      pobsini.ttipdec,
      pobsini.cmeddec,
      pobsini.tmeddec,
      pobsini.tnomdec,
      pobsini.tnom1dec,
      pobsini.tnom2dec,
      pobsini.tape1dec,
      pobsini.tape2dec,
      pobsini.tteldec,
      pobsini.tmovildec,
      pobsini.temaildec,
      pobsini.ctipide,
      pobsini.nnumide,
      pobsini.ttipide,
      pobsini.dec_sperson,
      pobsini.cnivel,
      pobsini.sperson2,
      pobsini.tnivel,
      pobsini.tperson2,
      pobsini.fechapp,
      pobsini.cpolcia,
      pobsini.iperit,
      pobsini.cfraude,
      pobsini.tfraude,
      pobsini.ccarpeta,
      pobsini.cagente,
      pobsini.ireserva9999,
      pobsini.csalvam,
      pobsini.nmovimi,
      pobsini.fdeteccion, --29786:NSS:23/01/2014
      pobsini.tdetpreten;
    -- Fin Bug 0015669 - JRH - 30/09/2010
    vnumerr         := f_desriesgo(pobsini.sseguro, pobsini.nriesgo, NULL, pac_md_common.f_get_cxtidioma, ptriesgo1, ptriesgo2, ptriesgo3);
    pobsini.triesgo := ptriesgo1 || ' ' || ptriesgo2 || ' ' || ptriesgo3;
    -- Bug 22256/122456 - AMC - 27/09/2012
    pobsini.tagente := f_desagente_t(pobsini.cagente); -- Bug 21817 - MDS - 2/05/2012
    -- Fi Bug 22256/122456 - AMC - 27/09/2012
    IF pobsini.dec_sperson IS NOT NULL THEN
      vcagente             := pac_persona.f_get_agente_detallepersona(pobsini.dec_sperson, pac_md_common.f_get_cxtagente, pac_md_common.f_get_cxtempresa);
      IF vcagente          IS NULL THEN
        vcagente           := pac_md_common.f_get_cxtagente;
      END IF;
      obpersona        := pac_md_persona.f_get_persona(pobsini.dec_sperson, vcagente, mensajes, 'POL');
      pobsini.tnomdec  := obpersona.tnombre;
      pobsini.tnom1dec := obpersona.tnombre1;
      pobsini.tnom2dec := obpersona.tnombre2;
      pobsini.tape1dec := obpersona.tapelli1;
      pobsini.tape2dec := obpersona.tapelli2;
      pobsini.nnumide  := obpersona.nnumide;
      pobsini.ctipide  := obpersona.ctipide;
      pobsini.ttipide  := obpersona.ttipide;
      pobsini.tagente  := f_desagente_t(pobsini.cagente); -- Bug 21817 - MDS - 2/05/2012
      --bug 19896 --ETM -- 20/12/2011--Añadir el campo tmovil,temail al declarante--INI
      --obpersona.contactos := t_iax_contactos();
      /*vnumerr := pac_md_persona.f_get_contactos(pobsini.dec_sperson, vcagente,
      obpersona.contactos, mensajes, 'POL');*/
      IF obpersona.contactos IS NOT NULL AND obpersona.contactos.COUNT > 0 THEN
        FOR i IN obpersona.contactos.FIRST .. obpersona.contactos.LAST
        LOOP
          --TELEFONO
          IF obpersona.contactos(i).ctipcon = 1 OR obpersona.contactos(i).ctipcon = 5 THEN
            pobsini.tteldec                := obpersona.contactos(i).tvalcon;
          END IF;
          --MOVIL
          IF obpersona.contactos(i).ctipcon = 6 OR obpersona.contactos(i).ctipcon = 8 THEN
            pobsini.tmovildec              := obpersona.contactos(i).tvalcon;
          END IF;
          --EMAIL
          IF obpersona.contactos(i).ctipcon = 3 THEN
            pobsini.temaildec              := obpersona.contactos(i).tvalcon;
          END IF;
        END LOOP;
      END IF;
      --FIN bug 19896 --ETM -- 20/12/2011--Añadir el campo tmovil,temail al declarante
    END IF;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_dades_sini;
/***********************************************************************
Recupera la colección de tramitaciones por una tramitación
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out  t_iax_sin_trami_localiza :  t_iax_sin_trami_localiza
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_localizaciones(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_localizaciones OUT t_iax_sin_trami_localiza,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_localizaciones';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_loc
  IS
    SELECT nsinies,
      ntramit,
      nlocali
    FROM sin_tramita_localiza
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_localizaciones := t_iax_sin_trami_localiza();
  FOR reg IN cur_loc
  LOOP
    t_localizaciones.EXTEND;
    t_localizaciones(t_localizaciones.LAST) := ob_iax_sin_trami_localiza();
    vnumerr                                 := f_get_localiza(pnsinies, reg.ntramit, reg.nlocali, t_localizaciones(t_localizaciones.LAST), mensajes);
    /* vnumerr := f_get_localiza(pnsinies, reg.ntramit, reg.csiglas,
    t_localizaciones(t_localizaciones.LAST), mensajes);*/
    IF mensajes        IS NOT NULL THEN
      IF mensajes.COUNT > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_localizaciones;
/***********************************************************************
Recupera los datos de una determinada localizacion
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pnlocaliza  : número de localización
param out  ob_iax_sin_trami_localiza :  ob_iax_sin_trami_localiza
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_localiza(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pnlocali IN NUMBER,
    p_oblocaliza OUT ob_iax_sin_trami_localiza,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_localiza2';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  p_oblocaliza := ob_iax_sin_trami_localiza();
  vpasexec     := 2;
  vnumerr      := pac_siniestros.f_get_localiza(pnsinies, pntramit, pnlocali, pac_md_common.f_get_cxtidioma, vsquery, pac_md_common.f_get_cxtagente);
  vpasexec     := 2;
  cur          := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec     := 3;
  LOOP
    -- Bug 20154/98048 - 15/11/2011 - AMC
    FETCH cur
    INTO p_oblocaliza.nsinies,
      p_oblocaliza.ntramit,
      p_oblocaliza.nlocali,
      p_oblocaliza.sperson,
      p_oblocaliza.tnombre,
      p_oblocaliza.csiglas,
      p_oblocaliza.tsiglas,
      p_oblocaliza.tnomvia,
      p_oblocaliza.nnumvia,
      p_oblocaliza.tcomple,
      p_oblocaliza.tlocali,
      p_oblocaliza.cpais,
      p_oblocaliza.tpais,
      p_oblocaliza.cprovin,
      p_oblocaliza.tprovin,
      p_oblocaliza.cpoblac,
      p_oblocaliza.tpoblac,
      p_oblocaliza.cpostal,
      p_oblocaliza.fbaja,
      p_oblocaliza.cviavp,
      p_oblocaliza.clitvp,
      p_oblocaliza.cbisvp,
      p_oblocaliza.corvp,
      p_oblocaliza.nviaadco,
      p_oblocaliza.clitco,
      p_oblocaliza.corco,
      p_oblocaliza.nplacaco,
      p_oblocaliza.cor2co,
      p_oblocaliza.cdet1ia,
      p_oblocaliza.tnum1ia,
      p_oblocaliza.cdet2ia,
      p_oblocaliza.tnum2ia,
      p_oblocaliza.cdet3ia,
      p_oblocaliza.tnum3ia,
      p_oblocaliza.localidad,                                                                                                                                                                                                                                                                                                                                                                                                                                                                        -- Bug 24780/130907 - 05/12/2012 - AMC
      p_oblocaliza.tviavp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                           --Bug 29889/164612:NSS:29/01/2014
    p_oblocaliza.tdomici := pac_persona.f_tdomici (p_oblocaliza.csiglas, p_oblocaliza.tnomvia, p_oblocaliza.nnumvia, p_oblocaliza.tcomple, p_oblocaliza.cviavp, p_oblocaliza.clitvp, p_oblocaliza.cbisvp, p_oblocaliza.corvp, p_oblocaliza.nviaadco, p_oblocaliza.clitco, p_oblocaliza.corco, p_oblocaliza.nplacaco, p_oblocaliza.cor2co, p_oblocaliza.cdet1ia, p_oblocaliza.tnum1ia, p_oblocaliza.cdet2ia, p_oblocaliza.tnum2ia, p_oblocaliza.cdet3ia, p_oblocaliza.tnum3ia, p_oblocaliza.localidad -- Bug 24780/130907 - 05/12/2012 - AMC
    );
    -- Fi Bug 20154/98048 - 15/11/2011 - AMC
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_localiza;
/***********************************************************************
Recupera la colección de movimientos de siniestros
param in  pnsinies  : número de siniestro
param out  t_iax_sin_movsiniestro :  t_iax_sin_movsiniestro
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_movsiniestros(
    pnsinies IN VARCHAR2,
    t_movsiniestros OUT t_iax_sin_movsiniestro,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_GET_MOVSINIESTROS';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_mov
  IS
    SELECT nsinies,
      nmovsin
    FROM sin_movsiniestro
    WHERE nsinies = pnsinies
    ORDER BY nmovsin DESC;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_movsiniestros := t_iax_sin_movsiniestro();
  FOR reg IN cur_mov
  LOOP
    t_movsiniestros.EXTEND;
    t_movsiniestros(t_movsiniestros.LAST) := ob_iax_sin_movsiniestro();
    vnumerr                               := f_get_movsiniestro(pnsinies, reg.nmovsin, t_movsiniestros(t_movsiniestros.LAST), mensajes);
    IF mensajes                           IS NOT NULL THEN
      IF mensajes.COUNT                    > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_movsiniestros;
/***********************************************************************
Recupera los datos de un determinado movimiento de siniestro
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pnmovsin  : número de movimiento
param out  ob_iax_sin_movsiniestro :  ob_iax_sin_movsiniestro
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_movsiniestro(
    pnsinies IN VARCHAR2,
    pnmovsin IN NUMBER,
    ob_movsiniestro OUT ob_iax_sin_movsiniestro,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_movsiniestro';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' nmovsin : ' || pnmovsin;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_movsiniestro := ob_iax_sin_movsiniestro();
  vnumerr         := pac_siniestros.f_get_movsiniestro(pnsinies, pnmovsin, pac_md_common.f_get_cxtidioma, vsquery);
  cur             := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec        := 4;
  LOOP
    FETCH cur
    INTO ob_movsiniestro.nsinies,
      ob_movsiniestro.nmovsin,
      ob_movsiniestro.cestsin,
      ob_movsiniestro.testsin,
      ob_movsiniestro.festsin,
      ob_movsiniestro.ccauest,
      ob_movsiniestro.tcauest,
      ob_movsiniestro.cunitra,
      ob_movsiniestro.tunitra,
      ob_movsiniestro.ctramitad,
      ob_movsiniestro.ttramitad,
      ob_movsiniestro.cusualt,
      ob_movsiniestro.falta;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_movsiniestro;
/***********************************************************************
Recupera la colección de lineas de agenda
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out  t_iax_sin_trami_agenda :  t_iax_sin_trami_agenda
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_listagenda(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_listagenda OUT t_iax_sin_trami_agenda,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_listagenda';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_age
  IS
    SELECT nsinies,
      ntramit,
      nlinage
    FROM sin_tramita_agenda
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_listagenda := t_iax_sin_trami_agenda();
  FOR reg IN cur_age
  LOOP
    t_listagenda.EXTEND;
    t_listagenda(t_listagenda.LAST) := ob_iax_sin_trami_agenda();
    vnumerr                         := f_get_agenda(pnsinies, reg.ntramit, reg.nlinage, t_listagenda(t_listagenda.LAST), mensajes);
    IF mensajes                     IS NOT NULL THEN
      IF mensajes.COUNT              > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_listagenda;
/***********************************************************************
Recupera los datos de un determinado agenda
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pnlinage  : número de linea de agenda
param out  ob_iax_sin_trami_agenda :  ob_iax_sin_trami_agenda
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_agenda(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pnlinage IN NUMBER,
    ob_agenda OUT ob_iax_sin_trami_agenda,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_agenda';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit || ' nlinage : ' || pnlinage;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_agenda := ob_iax_sin_trami_agenda();
  vnumerr   := pac_siniestros.f_get_agenda(pnsinies, pntramit, pnlinage, pac_md_common.f_get_cxtidioma, vsquery);
  cur       := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec  := 4;
  LOOP
    FETCH cur
    INTO ob_agenda.nsinies,
      ob_agenda.ntramit,
      ob_agenda.nlinage,
      ob_agenda.ctipreg,
      ob_agenda.cestage,
      ob_agenda.cmanual,
      ob_agenda.ffinage,
      ob_agenda.tlinage,
      ob_agenda.cusualt,
      ob_agenda.falta,
      ob_agenda.cusumod,
      ob_agenda.fmodifi,
      ob_agenda.ttitage,
      ob_agenda.ttipreg,
      ob_agenda.testage,
      ob_agenda.tmanual;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_agenda;
/***********************************************************************
Recupera los datos de un determinado personas relacionadas
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pnpersrel  : número de linea de spersrel
param out  ob_iax_sin_trami_personarel :  ob_iax_sin_trami_personarel
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_lista_personasrel(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_listapersrel OUT t_iax_sin_trami_personarel,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_lista_personasrel';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_per
  IS
    SELECT nsinies,
      ntramit,
      npersrel
    FROM sin_tramita_personasrel
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_listapersrel := t_iax_sin_trami_personarel();
  FOR reg IN cur_per
  LOOP
    t_listapersrel.EXTEND;
    t_listapersrel(t_listapersrel.LAST) := ob_iax_sin_trami_personarel();
    vnumerr                             := f_get_personarel(pnsinies, reg.ntramit, reg.npersrel, t_listapersrel(t_listapersrel.LAST), mensajes);
    IF mensajes                         IS NOT NULL THEN
      IF mensajes.COUNT                  > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_lista_personasrel;
/***********************************************************************
Recupera los datos de un determinado persona relacionada
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pnpersrel  : número de linea de agenda
param out  ob_iax_sin_trami_agenda :  ob_iax_sin_trami_agenda
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_personarel(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pnpersrel IN NUMBER,
    ob_persrel OUT ob_iax_sin_trami_personarel,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_personarel';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit || ' pnpersrel : ' || pnpersrel;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_persrel := ob_iax_sin_trami_personarel();
  vnumerr    := pac_siniestros.f_get_personarel(pnsinies, pntramit, pnpersrel, vsquery);
  cur        := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec   := 4;
  LOOP
    FETCH cur
    INTO ob_persrel.nsinies,
      ob_persrel.ntramit,
      ob_persrel.npersrel,
      ob_persrel.ctipide,
      ob_persrel.nnumide,
      ob_persrel.tnombre,
      ob_persrel.tapelli1,
      ob_persrel.tapelli2,
      ob_persrel.ttelefon,
      ob_persrel.sperson,
      ob_persrel.tdesc,
      -- bug 22325/115249 - 22/06/2012 - AMC
      ob_persrel.tnombre2,
      ob_persrel.tmovil,
      ob_persrel.temail,
      -- Fi bug 22325/115249 - 22/06/2012 - AMC
      -- Bug 22256/122456 - 27/09/2012 - AMC
      ob_persrel.ctiprel;
    IF ob_persrel.ctiprel IS NOT NULL THEN
      ob_persrel.ttiprel  := ff_desvalorfijo(800111, pac_md_common.f_get_cxtidioma(), ob_persrel.ctiprel);
    END IF;
    -- Fi Bug 22256/122456 - 27/09/2012 - AMC
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_personarel;
/***********************************************************************
Recupera la colección de reservas
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out  t_iax_sin_trami_reserva :  t_iax_sin_trami_reserva
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_reservas(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_reservas OUT t_iax_sin_trami_reserva,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_reservas';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  -- Bug 11847 - 23/11/2009 - AMC
  -- Bug 14490 - 14/05/2010 - AMC
  -- 26108 ini
  /*
  CURSOR cur_res IS
  SELECT   str.nsinies, str.ntramit, str.ctipres, MAX(str.nmovres) nmovres,
  str.ctipgas   --26108
  FROM sin_tramita_reserva str, sin_tramita_reserva str2
  WHERE str.nsinies = pnsinies
  AND str.ntramit = pntramit
  AND str.nsinies = str2.nsinies
  AND str.ntramit = str2.ntramit
  AND str.ctipres = str2.ctipres
  AND(str.cgarant = str2.cgarant
  OR str.cgarant IS NULL)
  AND(str.fresini = str2.fresini
  OR str.fresini IS NULL)
  AND(str.cmonres = str2.cmonres
  OR str.cmonres IS NULL)
  GROUP BY str.nsinies, str.ntramit, str.ctipres, str.cgarant, str.ctipgas,   --26108
  str.fresini,
  str.cmonres
  ORDER BY str.ctipres, str.cgarant;
  */
  -- comentamos la segunda tabla porque no entendemos para que sirve
  CURSOR cur_res
  IS
    SELECT str.nsinies,
      str.ntramit,
      str.ctipres,
      MAX(str.nmovres) nmovres,
      str.ctipgas --26108
    FROM sin_tramita_reserva str
    WHERE str.nsinies = pnsinies
    AND str.ntramit   = pntramit
    GROUP BY str.nsinies,
      str.ntramit,
      str.ctipres,
      str.cgarant,
      str.ctipgas, --26108
      str.fresini,
      fresfin,
      str.cmonres
    ORDER BY str.ctipres,
      str.cgarant,
      MAX(str.nmovres);
  -- 26108 fin
  -- Fi Bug 14490 - 14/05/2010 - AMC
  --Fi Bug 11847 - 23/11/2009 - AMC
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_reservas := t_iax_sin_trami_reserva();
  FOR reg IN cur_res
  LOOP
    t_reservas.EXTEND;
    t_reservas(t_reservas.LAST) := ob_iax_sin_trami_reserva();
    vnumerr                     := f_get_reserva(pnsinies, reg.ntramit, reg.ctipres, reg.nmovres, NULL, t_reservas(t_reservas.LAST), mensajes);
    IF mensajes                 IS NOT NULL THEN
      IF mensajes.COUNT          > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_reservas;


FUNCTION f_get_amparos(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_amparos OUT t_iax_sin_trami_amparo,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_amparos';
  vparam      VARCHAR2(500) := 'parÃ¡metros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  -- Bug 11847 - 23/11/2009 - AMC
  -- Bug 14490 - 14/05/2010 - AMC
  -- 26108 ini
  /*
  CURSOR cur_res IS
  SELECT   str.nsinies, str.ntramit, str.ctipres, MAX(str.nmovres) nmovres,
  str.ctipgas   --26108
  FROM sin_tramita_reserva str, sin_tramita_reserva str2
  WHERE str.nsinies = pnsinies
  AND str.ntramit = pntramit
  AND str.nsinies = str2.nsinies
  AND str.ntramit = str2.ntramit
  AND str.ctipres = str2.ctipres
  AND(str.cgarant = str2.cgarant
  OR str.cgarant IS NULL)
  AND(str.fresini = str2.fresini
  OR str.fresini IS NULL)
  AND(str.cmonres = str2.cmonres
  OR str.cmonres IS NULL)
  GROUP BY str.nsinies, str.ntramit, str.ctipres, str.cgarant, str.ctipgas,   --26108
  str.fresini,
  str.cmonres
  ORDER BY str.ctipres, str.cgarant;
  */
  -- comentamos la segunda tabla porque no entendemos para que sirve
  CURSOR cur_res
  IS
  SELECT str.nsinies,
      str.ntramit,

      0 ctipres,
      MAX(null) nmovres,
      str.cgarant --26108
    FROM sin_tramita_amparo str
    WHERE str.nsinies = pnsinies
    AND str.ntramit   = pntramit
    GROUP BY str.nsinies,
      str.ntramit,

      str.cgarant,

      str.cmonpreten
    ORDER BY 
      str.cgarant;

  -- 26108 fin
  -- Fi Bug 14490 - 14/05/2010 - AMC
  --Fi Bug 11847 - 23/11/2009 - AMC
BEGIN

  --ComprovaciÃ³ dels parÃ¡metres d'entrada
  IF pnsinies IS NULL THEN 
    RAISE e_param_error;
  END IF;
  t_amparos := t_iax_sin_trami_amparo();
  FOR reg IN cur_res
  LOOP
    t_amparos.EXTEND;
    t_amparos(t_amparos.LAST) := ob_iax_sin_trami_amparo();
    --vnumerr                     := f_get_reserva2(pnsinies, reg.ntramit, reg.ctipres, reg.nmovres, reg.cgarant, t_amparos(t_amparos.LAST), mensajes);
    vnumerr                     := f_get_amparo(pnsinies, reg.ntramit, reg.cgarant, t_amparos(t_amparos.LAST), mensajes);
    IF mensajes                 IS NOT NULL THEN
      IF mensajes.COUNT          > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_amparos;


/***********************************************************************
Recupera los datos de un determinado reserva
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pctipres  : número de tipo de reserva
param in  pnmovres  : número de movimiento de reserva
param out  ob_iax_sin_trami_reserva :  ob_iax_sin_trami_reserva
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
 /*************************************************************************
      FUNCTION f_get_amparo
           la tabla sin_tramita_amparo .

      param in pnsinies : Numero Siniestro		     
       param in pntramit : Numero Tramitacion Siniestro		     
       param in pcgarant : Codigo Garantia		     
       param in pnpreten : vAlor de la pretension		     
       param in picaprie : Importe Capital Riesgo		     
       param in pcmonpreten : Codigo de moneda		     
          return             : 0 -> Tot correcte
                              1 -> Se ha producido un error
   -- BUG 004131 - 2019-05-23 - EA 
   *************************************************************************/ 
FUNCTION f_get_amparo(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       ob_amparo OUT ob_iax_sin_trami_amparo,
		mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS 
        vobjectname    VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_amparo';
        vparam      VARCHAR2(500) := 'nsinies: ' || pnsinies || ' - ntramit: ' || pntramit || ' - cgarant: ' || pcgarant;
		  vpasexec       NUMBER(5) := 1;
        vnumerr        NUMBER(8) := 1;
        vsquery     VARCHAR2(5000);
  			cur sys_refcursor;

      BEGIN 


         ob_amparo := ob_iax_sin_trami_amparo();

                        vnumerr    := pac_siniestros.f_get_amparo(pnsinies, pntramit, pcgarant, vsquery);
			 cur        := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  			vpasexec   := 4;
  			LOOP
    FETCH cur
    INTO ob_amparo.nsinies,
      ob_amparo.ntramit,
      ob_amparo.cgarant,
      ob_amparo.itotret,
      ob_amparo.icaprie,
      ob_amparo.cmonres,
      ob_amparo.cusualt,
      ob_amparo.falta,
      ob_amparo.cusumod,
      ob_amparo.fmodifi,
      ob_amparo.tgarant,
      ob_amparo.ctipres,
      ob_amparo.nmovres,
      ob_amparo.finivig,
      ob_amparo.ffinvig, 
      ob_amparo.cmonicaprie;    --I.R.D   IAXIS-4131 - 03/01/2020
    EXIT
  WHEN cur%NOTFOUND;


    IF ob_amparo.cmonres IS NULL THEN
      ob_amparo.cmonres  := pac_monedas.f_cmoneda_t(pac_parametros.f_parinstalacion_n('MONEDAINST'));
    END IF;
    IF ob_amparo.cmonres   IS NOT NULL THEN
      ob_amparo.tmonres    := pac_eco_monedas.f_descripcion_moneda(ob_amparo.cmonres, pac_md_common.f_get_cxtidioma, vnumerr);
      ob_amparo.cmonresint := ob_amparo.cmonres;

    END IF;



  vpasexec   := 5;





  END LOOP;

  CLOSE cur;
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
  END f_get_amparo; 




FUNCTION f_get_reserva(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctipres IN NUMBER,
    pnmovres IN NUMBER,
    pcgarant IN NUMBER,
    ob_reserva OUT ob_iax_sin_trami_reserva,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_reserva';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit || ' ctipres : ' || pctipres || ' nmovres : ' || pnmovres;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  vcmonresint VARCHAR2(50);
  v_moncia    VARCHAR2(50);
  v_ctipcoa   NUMBER;
  v_nmovres   NUMBER;
  v_fcambio   DATE;
BEGIN
   IF pnmovres IS NULL THEN
      BEGIN
      SELECT MAX(nmovres)
        INTO v_nmovres
        FROM sin_tramita_reserva
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND ctipres = pctipres
         AND cgarant = pcgarant;
      EXCEPTION
      WHEN no_data_found THEN
      v_nmovres := NULL;
      END;
   ELSE
      v_nmovres := pnmovres;
   END IF;
  ob_reserva := ob_iax_sin_trami_reserva();
  vnumerr    := pac_siniestros.f_get_reserva(pnsinies, pntramit, pctipres, v_nmovres, pcgarant, pac_md_common.f_get_cxtidioma, vsquery);
  cur        := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec   := 4;
  -- Bug 11945 - 16/12/2009 - Se añade el parametro IPREREC
  LOOP
    FETCH cur
    INTO ob_reserva.nsinies,
      ob_reserva.ntramit,
      ob_reserva.ctipres,
      ob_reserva.nmovres,
      ob_reserva.cgarant,
      ob_reserva.ccalres,
      ob_reserva.fmovres,
      ob_reserva.cmonres,
      ob_reserva.ireserva,
      ob_reserva.ipago,
      ob_reserva.iingreso,
      ob_reserva.irecobro,
      ob_reserva.fresini,
      ob_reserva.fresfin,
      ob_reserva.sidepag,
      ob_reserva.sproces,
      ob_reserva.fcontab,
      ob_reserva.falta,
      ob_reserva.cusumod,
      ob_reserva.fmodifi,
      ob_reserva.iprerec,
      ob_reserva.ttipres,
      ob_reserva.tgarant,
      ob_reserva.tcalres,
      ob_reserva.icaprie,
      ob_reserva.ipenali,
      ob_reserva.fultpag,
      ob_reserva.ctipgas,
      ob_reserva.ttipgas,
      ob_reserva.ireserva_moncia,
      ob_reserva.ipago_moncia,
      ob_reserva.iingreso_moncia,
      ob_reserva.irecobro_moncia,
      ob_reserva.icaprie_moncia,
      ob_reserva.ipenali_moncia,
      ob_reserva.iprerec_moncia,
      ob_reserva.ifranq,
      ob_reserva.ifranq_moncia, --Bug 27059 : NSS : 05/06/2013
      ob_reserva.ndias          --Bug 27487/159742: NSS : 26/11/2013   --Bug 27059 : NSS : 05/06/2013
      ,
      ob_reserva.itotimp,
      ob_reserva.itotimp_moncia,
      ob_reserva.itotret,
      ob_reserva.itotret_moncia, -- 24637/0147756:NSS:20/03/2014
      ob_reserva.iva_ctipind,
      ob_reserva.retenc_ctipind,
      ob_reserva.reteiva_ctipind,
      ob_reserva.reteica_ctipind, -- 24637/0147756:NSS:20/03/2014
      ob_reserva.cmovres,         --0031294/0174788: NSS:26/05/2014
      ob_reserva.idres,
      ob_reserva.ttiptrans, -- Bug 31294 - 11/07/2014 - JTT
      --IAXIS 5454 AABC 12/11/2019 cambio de objeto para reexpresion 
      ob_reserva.csolidaridad, -- CONF-431 IGIL
      ob_reserva.ivalreex,
      ob_reserva.ivaltran_moncia; 
      --IAXIS 5454 AABC 12/11/2019 cambio de objeto para reexpresion
    EXIT
  WHEN cur%NOTFOUND;
    -- BUG16506:DRA:09/11/2010:Inici
    IF ob_reserva.fresini IS NOT NULL AND ob_reserva.fresfin IS NOT NULL AND ob_reserva.ndias IS NULL THEN
      --Bug 27487/159742: NSS : 26/11/2013
      ob_reserva.ndias := (ob_reserva.fresfin - ob_reserva.fresini) + 1;
    END IF;
    IF ob_reserva.cmonres IS NULL THEN
      ob_reserva.cmonres  := pac_monedas.f_cmoneda_t(pac_parametros.f_parinstalacion_n('MONEDAINST'));
    END IF;
    IF ob_reserva.cmonres   IS NOT NULL THEN
      ob_reserva.tmonres    := pac_eco_monedas.f_descripcion_moneda(ob_reserva.cmonres, pac_md_common.f_get_cxtidioma, vnumerr);
      ob_reserva.cmonresint := ob_reserva.cmonres;
      ---pac_md_listvalores.f_get_tmoneda(8, ob_reserva.cmonresint, mensajes);
    END IF;
    --

    -- BUG1404:AP:Inicio
    BEGIN
      select max(fcambio)
        into V_FCAMBIO
        from sin_tramita_reserva
      where nsinies = pnsinies
        AND ntramit = pntramit
        and ctipres = pctipres
        and cmonres = ob_reserva.cmonres;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      v_fcambio := null;
    END;
    ob_reserva.fcambio := v_fcambio;
    v_moncia               := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'MONEDAEMP'));
    ob_reserva.itasacambio := pac_eco_tipocambio.f_cambio(ob_reserva.cmonres, v_moncia, ob_reserva.fcambio);
    IF ob_reserva.itasacambio = 1 THEN
    ob_reserva.itasacambio := null;
    ob_reserva.fcambio := null;
    END IF;
    -- BUG1404:AP:Fin
  vpasexec   := 5;
    -- CONF-431 IGIL

    SELECT SEG.CTIPCOA
      INTO v_ctipcoa
      FROM SEGUROS SEG, SIN_SINIESTRO S
     WHERE SEG.SSEGURO = S.SSEGURO
       AND S.NSINIES = pnsinies;
    vpasexec   := 5;
    IF NVL(v_ctipcoa,0) <> 1 THEN
      ob_reserva.csolidaridad_modif := 0;
    ELSE
      vpasexec   := 6;
      IF NVL( pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),'MOD_SOLIDARIDAD_PAG') ,0) = 0 THEN
        IF ob_reserva.ipago > 0 THEN
          vpasexec   := 7;
          ob_reserva.csolidaridad_modif := 0;
        ELSE
          ob_reserva.csolidaridad_modif := 1;
        END IF;
      ELSIF NVL( pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),'MOD_SOLIDARIDAD_PAG') ,0) = 1 THEN
        ob_reserva.csolidaridad_modif := 1;
      END IF;
    END IF;

    --
    -- BUG16506:DRA:09/11/2010:Fi
    --ctippag = 2 pagament, ctipag = 7 recobro
    /*  vnumerr := f_get_pagrecob(ob_reserva.sidepag, 2, ob_reserva.pagos, mensajes);
    vnumerr := f_get_pagrecob(ob_reserva.sidepag, 7, ob_reserva.recobros, mensajes);
    */
  END LOOP;
  --Fi Bug 11945 - 16/12/2009 - Se añade el parametro IPREREC
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_reserva;
/***********************************************************************
Recupera la colección de referencias
param in  pnsinies  : número de siniestro
param out  t_iax_siniestro_referencias :  t_iax_siniestro_referencias
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_referencias(
    pnsinies IN VARCHAR2,
    t_referencias OUT t_iax_siniestro_referencias,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_referencias';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  -- Bug 11847 - 23/11/2009 - AMC
  -- Bug 14490 - 14/05/2010 - AMC
  CURSOR cur_res
  IS
    SELECT srefext
    FROM sin_siniestro_referencias
    WHERE nsinies = pnsinies
    ORDER BY srefext;
  -- Fi Bug 14490 - 14/05/2010 - AMC
  --Fi Bug 11847 - 23/11/2009 - AMC
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_referencias := t_iax_siniestro_referencias();
  FOR reg IN cur_res
  LOOP
    t_referencias.EXTEND;
    t_referencias(t_referencias.LAST) := ob_iax_siniestro_referencias();
    vnumerr                           := f_get_referencia(pnsinies, reg.srefext, t_referencias(t_referencias.LAST), mensajes);
    IF mensajes                       IS NOT NULL THEN
      IF mensajes.COUNT                > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_referencias;
/***********************************************************************
Recupera los datos de un determinado referencia
param in  pnsinies  : número de siniestro
param in  psrefext  : número de referencia
param out  ob_iax_siniestro_referencias :  ob_iax_siniestro_referencias
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_referencia(
    pnsinies IN VARCHAR2,
    psrefext IN NUMBER,
    ob_referencia OUT ob_iax_siniestro_referencias,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_referencia';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'psrefext ' || psrefext;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_referencia := ob_iax_siniestro_referencias();
  vnumerr       := pac_siniestros.f_get_referencia(pnsinies, psrefext, pac_md_common.f_get_cxtidioma, vsquery);
  cur           := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec      := 4;
  -- Bug 11945 - 16/12/2009 - Se añade el parametro IPREREC
  LOOP
    FETCH cur
    INTO ob_referencia.srefext,
      ob_referencia.nsinies,
      ob_referencia.ctipref,
      ob_referencia.trefext,
      ob_referencia.frefini,
      ob_referencia.freffin,
      ob_referencia.cusualt,
      ob_referencia.falta,
      ob_referencia.cusumod,
      ob_referencia.fmodifi,
      ob_referencia.ttipref;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  --Fi Bug 11945 - 16/12/2009 - Se añade el parametro IPREREC
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_referencia;
/***********************************************************************
Recupera la colección de tramitaciones
param in  pnsinies  : número de siniestro
param out  t_iax_sin_tramitacion :  t_iax_sin_tramitacion
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_tramitaciones(
    pnsinies IN VARCHAR2,
    t_tramitaciones OUT t_iax_sin_tramitacion,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_tramitaciones';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_tra
  IS
    SELECT nsinies, ntramit FROM sin_tramitacion WHERE nsinies = pnsinies;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_tramitaciones := t_iax_sin_tramitacion();
  FOR reg IN cur_tra
  LOOP
    t_tramitaciones.EXTEND;
    t_tramitaciones(t_tramitaciones.LAST) := ob_iax_sin_tramitacion();
    vnumerr                               := f_get_tramitacion(pnsinies, reg.ntramit, t_tramitaciones(t_tramitaciones.LAST), mensajes);
    IF mensajes                           IS NOT NULL THEN
      IF mensajes.COUNT                    > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_tramitaciones;
/***********************************************************************
Recupera los datos de un determinado tramitacion
param in  pnsinies  : número de siniestro
param out  ob_iax_sin_tramitacion :  ob_iax_sin_tramitacion
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_tramitacion(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    ob_tramitacion OUT ob_iax_sin_tramitacion,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_tramitacion';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_tramitacion := ob_iax_sin_tramitacion();
  vnumerr        := pac_siniestros.f_get_tramitacion(pnsinies, pntramit, pac_md_common.f_get_cxtidioma, vsquery);
  cur            := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec       := 4;
  -- BUG 0023536 - 24/10/2012 - JMF: Afegir csubtiptra
  LOOP
    FETCH cur
    INTO ob_tramitacion.nsinies,
      ob_tramitacion.ntramit,
      ob_tramitacion.ctramit,
      ob_tramitacion.ctcausin,
      ob_tramitacion.cinform,
      ob_tramitacion.cusualt,
      ob_tramitacion.falta,
      ob_tramitacion.cusumod,
      ob_tramitacion.fmodifi,
      ob_tramitacion.ttramit,
      ob_tramitacion.ttcausin,
      ob_tramitacion.tinform,
      ob_tramitacion.ctiptra,
      ob_tramitacion.ttiptra,
      ob_tramitacion.cborrab,
      ob_tramitacion.cculpab,
      ob_tramitacion.tculpab,
      ob_tramitacion.ccompani,
      ob_tramitacion.tcompani,
      ob_tramitacion.cpolcia,
      ob_tramitacion.iperit,
      ob_tramitacion.nsincia,
      ob_tramitacion.ntramte,
      ob_tramitacion.csubtiptra,
      ob_tramitacion.tsubtiptra,
      ob_tramitacion.nradica;
    EXIT
  WHEN cur%NOTFOUND;
    vpasexec   := 8;
    vnumerr    := f_get_detalltramitacio(pnsinies, ob_tramitacion.ctramit, ob_tramitacion.ntramit, ob_tramitacion.detalle, mensajes);
    vpasexec   := 9;
    vnumerr    := f_get_movtramits(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.movimientos, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec   := 10;
    vnumerr    := f_get_listagenda(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.agenda, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vnumerr    := f_get_lista_personasrel(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.personasrel, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vnumerr    := f_get_danyos(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.danyos, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vnumerr    := f_get_destinatarios(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.destinatarios, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vnumerr    := f_get_reservas(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.reservas, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
   vnumerr    := f_get_amparos(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.amparos, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vnumerr    := f_get_localizaciones(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.localizaciones, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    --ctippag = 2 pagament, ctipag = 7 recobro
    vnumerr    := f_get_pagrecobs(pnsinies, ob_tramitacion.ntramit, 2, NULL, ob_tramitacion.pagos, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vnumerr    := f_get_pagrecobs(pnsinies, ob_tramitacion.ntramit, 7, NULL, ob_tramitacion.recobros, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    --BUG 12164 - JTS - 30/11/2009
    --ctippag = 2 pagament, ctipag = 7 recobro
    vnumerr    := f_get_pagrecobs(pnsinies, ob_tramitacion.ntramit, 2, 'OFI', ob_tramitacion.pagos_ofi, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vnumerr    := f_get_pagrecobs(pnsinies, ob_tramitacion.ntramit, 7, 'OFI', ob_tramitacion.recobros_ofi, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    --Fi BUG 12164 - JTS - 30/11/2009
    vnumerr    := f_get_documentos(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.documentos, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    --jbn bug:18972
    vpasexec   := 25;
    vnumerr    := pac_iax_gestiones.f_get_gestiones(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.gestiones, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    --jbn bug:18972
    -- BUG 19821 - MDS - 11/11/2011
    vpasexec   := 15;
    vnumerr    := f_get_juzgados(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.juzgados, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    -- Bug 20340/109094 - 15/03/2012 - AMC
    vpasexec   := 16;
    vnumerr    := f_get_demands(pnsinies, ob_tramitacion.ntramit, 1, ob_tramitacion.demandantes, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec   := 17;
    vnumerr    := f_get_demands(pnsinies, ob_tramitacion.ntramit, 2, ob_tramitacion.demandados, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec   := 18;
    vnumerr    := f_get_citaciones(pnsinies, ob_tramitacion.ntramit, ob_tramitacion.citaciones, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    -- Fi Bug 20340/109094 - 15/03/2012 - AMC
    -- Fin BUG 19821 - MDS - 11/11/2011
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_tramitacion;
/***********************************************************************
Recupera los detalles de la tramitacion
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pctramit  : número de codi tramitacio
param out  ob_iax_sin_trami_detalle :  ob_iax_sin_trami_detalle
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_detalltramitacio(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctramit IN NUMBER,
    ob_detall OUT ob_iax_sin_trami_detalle,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_detalltramitacio';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit || 'pctramit ' || pctramit;
  vpasexec    NUMBER(5)     := 33;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(10000);
  cur sys_refcursor;
BEGIN
  vpasexec   := 22;
  ob_detall  := ob_iax_sin_trami_detalle();
  vpasexec   := 23;
  vnumerr    := pac_siniestros.f_get_detalltramitacio(pnsinies, pntramit, pctramit, pac_md_common.f_get_cxtidioma, vsquery, pac_md_common.f_get_cxtagente);
  vpasexec   := 2;
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec              := 3;
  vpasexec              := 4;
  IF vsquery            IS NOT NULL THEN
    cur                 := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
    vpasexec            := 4;
    vpasexec            := 5;
    ob_detall.persona   := ob_iax_personas();
    ob_detall.direccion := ob_iax_direcciones();
    vpasexec            := 6;
    -- BUG 0023540 - 24/10/2012 - JMF: Afegir IRECLAM, IINDEMN
    LOOP
      FETCH cur
      INTO ob_detall.nsinies,
        ob_detall.ntramit,
        ob_detall.ctramit,
        ob_detall.ttramit,
        ob_detall.ctiptra,
        ob_detall.ttiptra,
        ob_detall.desctramit,
        ob_detall.persona.sperson,
        ob_detall.persona.nnumide,
        ob_detall.persona.ctipide,
        ob_detall.persona.ttipide,
        ob_detall.persona.tnombre,
        ob_detall.cestper,
        ob_detall.testper,
        ob_detall.tdescdireccion,
        ob_detall.direccion.ctipdir,
        ob_detall.direccion.ttipdir,
        ob_detall.direccion.csiglas,
        ob_detall.direccion.tsiglas,
        ob_detall.direccion.tnomvia,
        ob_detall.direccion.nnumvia,
        ob_detall.direccion.tcomple,
        ob_detall.direccion.cdomici,
        ob_detall.direccion.tdomici,
        ob_detall.direccion.cpostal,
        ob_detall.direccion.cprovin,
        ob_detall.direccion.tprovin,
        ob_detall.direccion.cpoblac,
        ob_detall.direccion.tpoblac,
        ob_detall.direccion.cpais,
        ob_detall.direccion.tpais,
        ob_detall.direccion.cciudad,
        ob_detall.direccion.fgisx,
        ob_detall.direccion.fgisy,
        ob_detall.direccion.fgisz,
        ob_detall.direccion.cvalida,
        ob_detall.ctipmat,
        ob_detall.ttipmat,
        ob_detall.cmatric,
        ob_detall.cmarca,
        ob_detall.tmarca,
        ob_detall.cmodelo,
        ob_detall.tmodelo,
        ob_detall.cversion,
        ob_detall.tversion,
        ob_detall.ctipcon,
        ob_detall.ttipcon,
        ob_detall.ctipcar,
        ob_detall.ttipcar,
        ob_detall.fcarnet,
        ob_detall.calcohol,
        ob_detall.ireclam,
        ob_detall.iindemn,
        ob_detall.nanyo,
        ob_detall.codmotor,
        ob_detall.cchasis,
        ob_detall.nbastid,
        ob_detall.ccilindraje; -- 26969
      /* FETCH cur
      INTO ob_detall.nsinies, ob_detall.ntramit, ob_detall.ctramit, ob_detall.ttramit,
      ob_detall.ctiptra, ob_detall.ttiptra, ob_detall.ccompani, ob_detall.tcompani,
      ob_detall.cpolcia, ob_detall.iperit, ob_detall.desctramit, ob_detall.persona.sperson,
      ob_detall.persona.nnumide, ob_detall.persona.ctipide, ob_detall.persona.ttipide, ob_detall.persona.tnombre,
      ob_detall.cestper, ob_detall.testper, ob_detall.tdescdireccion,
      ob_detall.direccion.ctipdir, ob_detall.direccion.ttipdir, ob_detall.direccion.csiglas, ob_detall.direccion.tsiglas,
      ob_detall.direccion.tnomvia, ob_detall.direccion.nnumvia, ob_detall.direccion.tcomple,
      null cdomici, null tdomici, null cpostal, null cprovin, null tprovin, null cpoblac, null tpoblac,
      null cpais, null tpais, detv.ctipmat, null ttipmat,detv.CMATRIC, detv.CMARCA, null tmarca,
      detv.smodelo cmodelo, null tmodelo, detv.cversion, null tversion
      ob_detall.direccion.cpais,
      ob_detall.direccion.tpais, ob_detall.ctipmat, ob_detall.ttipmat, ob_detall.cmatric,
      ob_detall.cmarca, ob_detall.tmarca, ob_detall.cmodelo, ob_detall.tmodelo,
      ob_detall.cversion, ob_detall.tversion;*/
      EXIT
    WHEN cur%NOTFOUND;
    END LOOP;
    CLOSE cur;
  END IF;
  vpasexec := 6;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_detalltramitacio;
/***********************************************************************
Recupera la colección de movimientos de tramitos
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out  t_iax_sin_trami_movimiento :  t_iax_sin_trami_movimiento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_movtramits(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_movtramits OUT t_iax_sin_trami_movimiento,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_movtramits';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_tra
  IS
    SELECT nsinies,
      ntramit,
      nmovtra
    FROM sin_tramita_movimiento
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit
      ORDER BY nmovtra ASC;  -- Bug 17853 - 03/03/2011 - AMC
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_movtramits := t_iax_sin_trami_movimiento();
  FOR reg IN cur_tra
  LOOP
    t_movtramits.EXTEND;
    t_movtramits(t_movtramits.LAST) := ob_iax_sin_trami_movimiento();
    vnumerr                         := f_get_movtramit(pnsinies, reg.ntramit, reg.nmovtra, t_movtramits(t_movtramits.LAST), mensajes);
    IF mensajes                     IS NOT NULL THEN
      IF mensajes.COUNT              > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_movtramits;
/***********************************************************************
Recupera los datos de un movimiento de tramitacion
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pnmovtra  : número de movimiento de tramitacion
param out  ob_iax_sin_trami_movimiento :  ob_iax_sin_trami_movimiento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_movtramit(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pnmovtra IN NUMBER,
    ob_movtramit OUT ob_iax_sin_trami_movimiento,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_movtramit';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_movtramit := ob_iax_sin_trami_movimiento();
  vnumerr      := pac_siniestros.f_get_movtramit(pnsinies, pntramit, pnmovtra, pac_md_common.f_get_cxtidioma, vsquery);
  IF vnumerr   <> 0 THEN
    RAISE e_object_error;
  END IF;
  cur      := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec := 4;
  LOOP
    FETCH cur
    INTO ob_movtramit.nsinies,
      ob_movtramit.ntramit,
      ob_movtramit.nmovtra,
      ob_movtramit.cunitra,
      ob_movtramit.ctramitad,
      ob_movtramit.cesttra,
      ob_movtramit.csubtra,
      ob_movtramit.festtra,
      ob_movtramit.cusualt,
      ob_movtramit.falta,
      ob_movtramit.testtra,
      ob_movtramit.tsubtra,
      ob_movtramit.tunitra,
      ob_movtramit.ttramitad,
      ob_movtramit.ccauest,
      ob_movtramit.tcauest; -- 21196:ASN:26/03/2012
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_movtramit;
/***********************************************************************
Recupera la colección de danyos
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out  t_iax_sin_trami_dano :  t_iax_sin_trami_dano
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_danyos(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_danyos OUT t_iax_sin_trami_dano,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_danyos';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_danyos
  IS
    SELECT nsinies,
      ntramit,
      ndano
    FROM sin_tramita_dano
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_danyos := t_iax_sin_trami_dano();
  FOR reg IN cur_danyos
  LOOP
    t_danyos.EXTEND;
    t_danyos(t_danyos.LAST) := ob_iax_sin_trami_dano();
    vnumerr                 := f_get_danyo(pnsinies, reg.ntramit, reg.ndano, t_danyos(t_danyos.LAST), mensajes);
    IF mensajes             IS NOT NULL THEN
      IF mensajes.COUNT      > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_danyos;
/***********************************************************************
Recupera los datos de un danyo
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pndano  : número danyo
param out  ob_iax_sin_trami_dano :  ob_iax_sin_trami_dano
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_danyo(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pndano   IN NUMBER,
    ob_danyo OUT ob_iax_sin_trami_dano,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_danyos';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit || 'ndano : ' || pndano;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_danyo := ob_iax_sin_trami_dano();
  vnumerr  := pac_siniestros.f_get_danyo(pnsinies, pntramit, pndano, pac_md_common.f_get_cxtidioma, vsquery);
  cur      := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec := 4;
  LOOP
    FETCH cur
    INTO ob_danyo.nsinies,
      ob_danyo.ntramit,
      ob_danyo.ndano,
      ob_danyo.ctipinf,
      ob_danyo.ttipinf,
      ob_danyo.tdano;
    EXIT
  WHEN cur%NOTFOUND;
    vnumerr            := f_get_detdanyos(ob_danyo.nsinies, ob_danyo.ntramit, ob_danyo.ndano, ob_danyo.detalle, mensajes);
    IF mensajes        IS NOT NULL THEN
      IF mensajes.COUNT > 0 THEN
        RETURN 1;
      END IF;
    END IF;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_danyo;
/***********************************************************************
Recupera la colección de danyos
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out  t_iax_sin_trami_dano :  t_iax_sin_trami_dano
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_detdanyos(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pndano   IN NUMBER,
    t_detdanyos OUT t_iax_sin_trami_detdano,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_danyos';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_detdanyos
  IS
    SELECT nsinies,
      ntramit,
      ndano,
      ndetdano
    FROM sin_tramita_detdano
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit
    AND ndano     = pndano;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_detdanyos := t_iax_sin_trami_detdano();
  FOR reg IN cur_detdanyos
  LOOP
    t_detdanyos.EXTEND;
    t_detdanyos(t_detdanyos.LAST) := ob_iax_sin_trami_detdano();
    vnumerr                       := f_get_detdanyo(pnsinies, reg.ntramit, reg.ndano, reg.ndetdano, t_detdanyos(t_detdanyos.LAST), mensajes);
    IF mensajes                   IS NOT NULL THEN
      IF mensajes.COUNT            > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_detdanyos;
/***********************************************************************
Recupera los datos de un detdanyo
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pndano  : número danyo
param out  ob_iax_sin_trami_dano :  ob_iax_sin_trami_dano
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_detdanyo(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pndano    IN NUMBER,
    pndetdano IN NUMBER,
    ob_detdanyo OUT ob_iax_sin_trami_detdano,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_detdanyos';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit || 'ndano : ' || pndano;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_detdanyo := ob_iax_sin_trami_detdano();
  vnumerr     := pac_siniestros.f_get_detdanyo(pnsinies, pntramit, pndano, pndetdano, pac_md_common.f_get_cxtidioma, vsquery);
  cur         := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec    := 4;
  LOOP
    FETCH cur
    INTO ob_detdanyo.nsinies,
      ob_detdanyo.ntramit,
      ob_detdanyo.ndano,
      ob_detdanyo.ndetdano;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_detdanyo;
/***********************************************************************
Recupera la colección de destinatarios
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_citaciones(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_citaciones OUT t_iax_sin_trami_citaciones,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_citaciones';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit ;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_cit
  IS
    SELECT nsinies,
      ntramit,
      ncitacion
    FROM sin_tramita_citaciones
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_citaciones := t_iax_sin_trami_citaciones();
  FOR reg IN cur_cit
  LOOP
    t_citaciones.EXTEND;
    t_citaciones(t_citaciones.LAST) := ob_iax_sin_trami_citacion();
    vnumerr                         := f_get_citacion(pnsinies, reg.ntramit, reg.ncitacion, t_citaciones(t_citaciones.LAST), mensajes);
    IF mensajes                     IS NOT NULL THEN
      IF mensajes.COUNT              > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_citaciones;
/***********************************************************************
Recupera la colección de destinatarios
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_destinatarios(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_destinatarios OUT t_iax_sin_trami_destinatario,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_destinatarios';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_des
  IS
    SELECT nsinies,
      ntramit,
      sperson,
      ctipdes
    FROM sin_tramita_destinatario
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_destinatarios := t_iax_sin_trami_destinatario();
  FOR reg IN cur_des
  LOOP
    t_destinatarios.EXTEND;
    t_destinatarios(t_destinatarios.LAST) := ob_iax_sin_trami_destinatario();
    vnumerr                               := f_get_destinatario(pnsinies, reg.ntramit, reg.sperson, reg.ctipdes, t_destinatarios(t_destinatarios.LAST), mensajes);
    IF mensajes                           IS NOT NULL THEN
      IF mensajes.COUNT                    > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_destinatarios;
/***********************************************************************
Recupera los datos de una citacion
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pncitacion  : número citacion
param out  ob_iax_sin_trami_citacion :  ob_iax_sin_trami_citacion
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_citacion(
    pnsinies   IN VARCHAR2,
    pntramit   IN NUMBER,
    pncitacion IN NUMBER,
    ob_citacion OUT ob_iax_sin_trami_citacion,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_citacion';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit || 'ncitacion : ' || pncitacion;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_citacion := ob_iax_sin_trami_citacion();
  vnumerr     := pac_siniestros.f_get_citacion(pnsinies, pntramit, pncitacion, pac_md_common.f_get_cxtidioma, vsquery, pac_md_common.f_get_cxtagente);
  cur         := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec    := 4;
  LOOP
    FETCH cur
    INTO ob_citacion.nsinies,
      ob_citacion.ntramit,
      ob_citacion.persona.sperson,
      ob_citacion.persona.tnombre,
      ob_citacion.persona.tapelli1,
      ob_citacion.persona.tapelli2,
      ob_citacion.persona.nnumide,
      ob_citacion.ncitacion,
      ob_citacion.fcitacion,
      ob_citacion.hcitacion,
      ob_citacion.cpais,
      ob_citacion.tpais,
      ob_citacion.cprovin,
      ob_citacion.tprovin,
      ob_citacion.cpoblac,
      ob_citacion.tpoblac,
      ob_citacion.tlugar,
      ob_citacion.TAUDIEN,
      ob_citacion.CORAL,
      ob_citacion.CESTADO,
      ob_citacion.CRESOLU,
      ob_citacion.FNUEVA,
      ob_citacion.TRESULT,
      ob_citacion.CMEDIO,
      ob_citacion.falta,
      ob_citacion.cusualt,
      ob_citacion.fmodifi,
      ob_citacion.cusumod;
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec := 7;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_citacion;
/***********************************************************************
Recupera los datos de un destinatario
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  psperson  : número identificativo del destinatario
param in  pctipdes  : número tipo destinatario
param out  ob_iax_sin_trami_destinatario :  ob_iax_sin_trami_destinatario
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_destinatario(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    psperson IN NUMBER,
    pctipdes IN NUMBER,
    ob_destinatario OUT ob_iax_sin_trami_destinatario,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_destinatario';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit || 'sperson = ' || psperson || 'ctipdes : ' || pctipdes;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  t_prestaren t_iax_sin_prestaren;
BEGIN
  ob_destinatario := ob_iax_sin_trami_destinatario();
  vnumerr         := pac_siniestros.f_get_destinatario(pnsinies, pntramit, psperson, pctipdes, pac_md_common.f_get_cxtidioma, vsquery, pac_md_common.f_get_cxtagente);
  cur             := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec        := 4;
  LOOP
    FETCH cur
    INTO ob_destinatario.nsinies,
      ob_destinatario.ntramit,
      ob_destinatario.persona.sperson,
      ob_destinatario.persona.tnombre,
      ob_destinatario.persona.tapelli1,
      ob_destinatario.persona.tapelli2,
      ob_destinatario.ctipdes,
      ob_destinatario.cpagdes,
      ob_destinatario.cactpro,
      ob_destinatario.tactpro,
      ob_destinatario.ttipdes,
      ob_destinatario.persona.nnumide,
      ob_destinatario.pasigna,
      ob_destinatario.cpaisre,
      ob_destinatario.tpaisre,
      ob_destinatario.ctipban,
      ob_destinatario.cbancar
      -- Fi  Bug 0015669 - JRH - 30/09/2010  -- Nuevos campos
      ,
      ob_destinatario.ctipcap,
      ob_destinatario.crelase,
      ob_destinatario.ttipcap,
      ob_destinatario.trelase,
      ob_destinatario.sprofes,
      ob_destinatario.cprovin,
      ob_destinatario.tprovin; -- Bug 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros - NSS - 26/02/2014
    vpasexec   := 5;
    vnumerr    := f_get_prestaren(pnsinies, pntramit, psperson, pctipdes, t_prestaren, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec                    := 6;
    ob_destinatario.t_prestaren := t_prestaren;
    -- Fi  Bug 0015669 - JRH - 30/09/2010
    vpasexec := 7;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_destinatario;
/***********************************************************************
Recupera la colección de pagos o recobros, dependiendo del ctippag
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pctippag  : tipo pago,       ctippag = 2 --> pago
ctippag = 7 --> recobro
param out  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_pagrecobs(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctippag IN NUMBER,
    pperfil  IN VARCHAR2,
    t_pagrecobs OUT t_iax_sin_trami_pago,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_pagrecobs';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_pag
  IS
    SELECT sidepag
    FROM sin_tramita_pago
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit
    AND ctippag   = pctippag
    AND(pperfil  IS NULL
    OR(pperfil    = 'OFI'
    AND ctipdes  IN(1, 6, 7)))
    ORDER BY --cultpag DESC, sidepag ASC;   --Bug 28384:NSS:14/11/2013.
      DECODE (NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NUM_DIAS_PAGO'), 0), 0, cultpag) DESC,
      DECODE (NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NUM_DIAS_PAGO'), 0), 0, sidepag) ASC,
      DECODE (NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NUM_DIAS_PAGO'), 0), 1, fordpag, 0, f_sysdate) ASC;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_pagrecobs := t_iax_sin_trami_pago();
  FOR reg IN cur_pag
  LOOP
    t_pagrecobs.EXTEND;
    t_pagrecobs(t_pagrecobs.LAST) := ob_iax_sin_trami_pago();
    vnumerr                       := f_get_pagrecob(pnsinies, pntramit, reg.sidepag, t_pagrecobs(t_pagrecobs.LAST), mensajes);
    IF mensajes                   IS NOT NULL THEN
      IF mensajes.COUNT            > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_pagrecobs;
/***********************************************************************
Recupera los datos de un pago / recobro
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  psidepag  : número d pago
param out  ob_pagrecob :  ob_iax_sin_trami_pago
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
-- BUG 19981 - 07/11/2011 - MDS - Añadir campos ireteiva, ireteica, ireteivapag, ireteicapag, iica, iicapag en el type ob_iax_sin_trami_pago
-- Bug 22256/122456 - 28/09/2012 - AMC  - Añadir campos cagente,npersrel,cdomici y ctributa
***********************************************************************/
FUNCTION f_get_pagrecob(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    psidepag IN NUMBER,
    ob_pagrecob OUT ob_iax_sin_trami_pago,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_pagrecob';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_pagrecob := ob_iax_sin_trami_pago();
  vnumerr     := pac_siniestros.f_get_pagrecob(pnsinies, pntramit, psidepag, pac_md_common.f_get_cxtidioma, vsquery, pac_md_common.f_get_cxtagente);
  cur         := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec    := 4;
  LOOP
    FETCH cur
    INTO ob_pagrecob.sidepag,
      ob_pagrecob.nsinies,
      ob_pagrecob.ntramit,
      ob_pagrecob.destinatari.persona.sperson,
      ob_pagrecob.destinatari.ctipdes,
      ob_pagrecob.ctippag,
      ob_pagrecob.cconpag,
      ob_pagrecob.ccauind,
      ob_pagrecob.cforpag,
      ob_pagrecob.fordpag,
      ob_pagrecob.ctipban,
      ob_pagrecob.cbancar,
      ob_pagrecob.cmonres,
      ob_pagrecob.isinret,
      ob_pagrecob.iretenc,
      ob_pagrecob.iiva,
      ob_pagrecob.isuplid,
      ob_pagrecob.ifranq,
      ob_pagrecob.cmonpag,
      ob_pagrecob.isinretpag,
      ob_pagrecob.iretencpag,
      ob_pagrecob.iivapag,
      ob_pagrecob.isuplidpag,
      ob_pagrecob.ifranqpag,
      ob_pagrecob.fcambio,
      ob_pagrecob.nfacref,
      ob_pagrecob.ffacref,
      ob_pagrecob.destinatari.ttipdes,
      ob_pagrecob.ttippag,
      ob_pagrecob.tforpag,
      ob_pagrecob.ncheque,
      ob_pagrecob.ttipban,
      ob_pagrecob.tconpag,
      ob_pagrecob.tcauind,
      ob_pagrecob.destinatari.persona.tnombre,
      ob_pagrecob.destinatari.persona.tapelli1,
      ob_pagrecob.destinatari.persona.tapelli2,
      ob_pagrecob.iresred,
      ob_pagrecob.iresrcm,
      ob_pagrecob.ctransfer,
      ob_pagrecob.cultpag,
      -- BUG 19981 - 07/11/2011 - MDS
      ob_pagrecob.ireteiva,
      ob_pagrecob.ireteica,
      ob_pagrecob.ireteivapag,
      ob_pagrecob.ireteicapag,
      ob_pagrecob.iica,
      ob_pagrecob.iicapag,
      -- Bug 22256/122456 - 28/09/2012 - AMC
      ob_pagrecob.cagente,
      ob_pagrecob.npersrel,
      ob_pagrecob.cdomici,
      ob_pagrecob.ctributacion,
      ob_pagrecob.cbanco,
      ob_pagrecob.cofici,
      ob_pagrecob.destinatari.pasigna, --24708:NSS:14/10/2013
      ob_pagrecob.cciudad,             --29224:NSS:24/02/2014
      ob_pagrecob.destinatari.sprofes, --24637/147756:NSS:28/02/2014
      ob_pagrecob.presentador.sperson,
      ob_pagrecob.tobserva,
      ob_pagrecob.iotrosgas,
      ob_pagrecob.iotrosgaspag,
      ob_pagrecob.ibaseipoc,
      ob_pagrecob.ibaseipocpag,
      ob_pagrecob.iipoconsumo,
      ob_pagrecob.iipoconsumopag,
      ob_pagrecob.presentador.tnombre,
      ob_pagrecob.presentador.tapelli1,
      ob_pagrecob.presentador.tapelli2;
    ob_pagrecob.ctipdes    := ob_pagrecob.destinatari.ctipdes;
    IF ob_pagrecob.cciudad IS NOT NULL THEN
      BEGIN
        SELECT tprovin
        INTO ob_pagrecob.dciudad
        FROM provincias
        WHERE cprovin = ob_pagrecob.cciudad;
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
    END IF;
    EXIT
  WHEN cur%NOTFOUND;
    vnumerr    := f_get_movpagos(ob_pagrecob.sidepag, ob_pagrecob.movpagos, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    vnumerr    := f_get_pagogars(pnsinies, pntramit, ob_pagrecob.sidepag, ob_pagrecob.pagogar, mensajes);
    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_pagrecob;
/***********************************************************************
Recupera la colección de movimientos de pagos o recobros, dependiendo del ctippag
param in  psidepag  : número de pago
param out  t_iax_sin_trami_movpago :  t_iax_sin_trami_movpago
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_movpagos(
    psidepag IN NUMBER,
    t_movpagos OUT t_iax_sin_trami_movpago,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_movpagos';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_movpag
  IS
    SELECT sidepag,
      nmovpag
    FROM sin_tramita_movpago
    WHERE sidepag = psidepag
    ORDER BY nmovpag ASC;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psidepag IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec   := 2;
  t_movpagos := t_iax_sin_trami_movpago();
  vpasexec   := 3;
  FOR reg IN cur_movpag
  LOOP
    vpasexec := 4;
    t_movpagos.EXTEND;
    t_movpagos(t_movpagos.LAST) := ob_iax_sin_trami_movpago();
    vpasexec                    := 5;
    vnumerr                     := f_get_movpago(reg.sidepag, reg.nmovpag, t_movpagos(t_movpagos.LAST), mensajes);
    IF mensajes                 IS NOT NULL THEN
      IF mensajes.COUNT          > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_movpagos;
/***********************************************************************
Recupera los datos de movimiento de pago / recobro
param in  sidepag  : número tipo pago
param in  pnmovpag  : número tipo movimiento pago
param out  ob_iax_sin_trami_movpago :  ob_iax_sin_trami_movpago
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_movpago(
    psidepag IN NUMBER,
    pnmovpag IN NUMBER,
    ob_movpag OUT ob_iax_sin_trami_movpago,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_movpago';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag || 'pnmovpag ' || pnmovpag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_movpag := ob_iax_sin_trami_movpago();
  vnumerr   := pac_siniestros.f_get_movpago(psidepag, pnmovpag, pac_md_common.f_get_cxtidioma, vsquery);
  cur       := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec  := 4;
  LOOP
    -- Bug 13312 - 08/03/2010 - AMC
    FETCH cur
    INTO ob_movpag.sidepag,
      ob_movpag.nmovpag,
      ob_movpag.cestpag,
      ob_movpag.testpag,
      ob_movpag.fefepag,
      ob_movpag.cestval,
      ob_movpag.fcontab,
      ob_movpag.sproces,
      ob_movpag.testval,
      ob_movpag.cestpagant,
      ob_movpag.csubpag,
      ob_movpag.tsubpag,
      ob_movpag.csubpagant, --Bug:19601 - 13/10/2011 - JMC
      ob_movpag.falta,      --Bug:27323 - 14/06/2013 - NSS
      ob_movpag.cusualt,    --Bug:29804 - 30/01/2014 - NSS
      ob_movpag.ndocpag; -- IAXIS-7731 19/12/2019
    -- Fi Bug 13312 - 08/03/2010 - AMC
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_movpago;
/***********************************************************************
Recupera la colección de detalle de pagos / recobros
param in  psidepag  : número de pago
param out  t_iax_sin_trami_pago_gar :  t_iax_sin_trami_pago_gar
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_pagogars(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    psidepag IN NUMBER,
    t_pagogars OUT t_iax_sin_trami_pago_gar,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_pagogars';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || psidepag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_pagogar
  IS
    SELECT sidepag,
      ctipres,
      nmovres,
      norden
    FROM sin_tramita_pago_gar
    WHERE sidepag = psidepag
    ORDER BY norden; --bug 32977:NSS:03/10/2014
BEGIN
  vpasexec := 2;
  --Comprovació dels parámetres d'entrada
  IF psidepag IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec   := 3;
  t_pagogars := t_iax_sin_trami_pago_gar();
  vpasexec   := 4;
  FOR reg IN cur_pagogar
  LOOP
    vpasexec := 5;
    t_pagogars.EXTEND;
    t_pagogars(t_pagogars.LAST) := ob_iax_sin_trami_pago_gar();
    vpasexec                    := 6;
    vnumerr                     := f_get_pagogar(pnsinies, pntramit, reg.sidepag, reg.ctipres, reg.nmovres, reg.norden, t_pagogars(t_pagogars.LAST), mensajes);
    vpasexec                    := 7;
    IF mensajes                 IS NOT NULL THEN
      IF mensajes.COUNT          > 0 THEN
        RETURN 1;
      END IF;
    END IF;
    vpasexec := 8;
  END LOOP;
  vpasexec := 9;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_pagogars;
/***********************************************************************
Recupera los datos del detalle de pagos / recobros
param in  sidepag  : número tipo pago
param in  pnmovpag  : número tipo movimiento pago
param out  ob_pagogar :  ob_iax_sin_trami_pago_gar
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
-- BUG 19981 - 07/11/2011 - MDS - Añadir campos preteiva, preteica, ireteiva, ireteica, ireteivapag, ireteicapag, pica, iica, iicapag en el type ob_iax_sin_trami_pago_gar
***********************************************************************/
FUNCTION f_get_pagogar(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    psidepag IN NUMBER,
    pctipres IN NUMBER,
    pnmovres IN NUMBER,
    pnorden  IN NUMBER,
    ob_pagogar OUT ob_iax_sin_trami_pago_gar,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_pagogar';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag || 'pctipres ' || pctipres || ' nmovres :: ' || pnmovres;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  vctipres NUMBER;
  vnmovres NUMBER;
  vcgarant NUMBER;
  vtgarant VARCHAR2(500);
  vtipres  VARCHAR2(500);
BEGIN
  ob_pagogar := ob_iax_sin_trami_pago_gar();
  vnumerr    := pac_siniestros.f_get_pagogar(psidepag, pctipres, pnmovres, pnorden, pac_md_common.f_get_cxtidioma, vsquery);
  cur        := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec   := 4;
  -- Bug 13513 - 04/03/2010 - AMC
  LOOP
    FETCH cur
    INTO ob_pagogar.sidepag,
      vctipres,
      vnmovres,
      vcgarant,
      ob_pagogar.fperini,
      ob_pagogar.fperfin,
      ob_pagogar.cmonres,
      ob_pagogar.isinret,
      ob_pagogar.iiva,
      ob_pagogar.isuplid,
      ob_pagogar.iretenc,
      ob_pagogar.ifranq,
      ob_pagogar.iresrcm,
      ob_pagogar.iresred,
      ob_pagogar.cmonpag,
      ob_pagogar.isinretpag,
      ob_pagogar.iivapag,
      ob_pagogar.isuplidpag,
      ob_pagogar.iretencpag,
      ob_pagogar.ifranqpag,
      ob_pagogar.fcambio,
      vtipres,
      vtgarant,
      ob_pagogar.pretenc,
      ob_pagogar.piva,
      ob_pagogar.cconpag,
      ob_pagogar.tconpag,
      ob_pagogar.norden,
      -- BUG 19981 - 07/11/2011 - MDS
      ob_pagogar.preteiva,
      ob_pagogar.preteica,
      ob_pagogar.ireteiva,
      ob_pagogar.ireteica,
      ob_pagogar.ireteivapag,
      ob_pagogar.ireteicapag,
      ob_pagogar.pica,
      ob_pagogar.iica,
      ob_pagogar.iicapag,
      ob_pagogar.piva_ctipind,
      ob_pagogar.pretenc_ctipind,
      ob_pagogar.preteiva_ctipind, --bug 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros:NSS:03/03/2014
      ob_pagogar.preteica_ctipind, --bug 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros:NSS:03/03/2014
      ob_pagogar.idres             -- bug 31294 - 11/07/201/ - JTT
      ,
      ob_pagogar.iotrosgas,
      ob_pagogar.iotrosgaspag,
      ob_pagogar.ibaseipoc,
      ob_pagogar.ibaseipocpag,
      ob_pagogar.pipoconsumo,
      ob_pagogar.iipoconsumo,
      ob_pagogar.iipoconsumopag,
      ob_pagogar.pipoconsumo_tipind;
    EXIT
  WHEN cur%NOTFOUND;
    vpasexec                      := 5;
    IF NVL(ob_pagogar.isuplid, 0) <> 0 THEN
      ob_pagogar.importe          := NVL(ob_pagogar.isinret, 0) -
      NVL(ob_pagogar.isuplid, 0);
    ELSE
      ob_pagogar.importe := NVL(ob_pagogar.iresrcm, 0) -
      NVL(ob_pagogar.iresred, 0);
    END IF;
    vpasexec         := 6;
    ob_pagogar.ineta := NVL(ob_pagogar.isinret, 0) + NVL(ob_pagogar.iiva, 0) -
    NVL(ob_pagogar.iretenc, 0);
    vpasexec := 7;
    -- Fi Bug 13513 - 04/03/2010 - AMC
    vnumerr                    := f_get_reserva(pnsinies, pntramit, vctipres, vnmovres, NULL, ob_pagogar.reserva, mensajes);
    vpasexec                   := 8;
    ob_pagogar.reserva.cgarant := vcgarant;
    ob_pagogar.reserva.tgarant := vtgarant;
    --BUG19006 - JTS - 19/07/2011
    vnumerr  := pac_siniestros.f_get_pagogar_modif(ob_pagogar.sidepag, ob_pagogar.esmodif);
    vpasexec := 9;
    --Fi BUG19006
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_pagogar;
/***********************************************************************
Ens retorna la última reserva per un sinistre donat,
param in  pnsinies  : número de siniestro
param out ult_reserva  : Últim moviment de la reserva del sinistre
param IN out mensajes  : mensajes de error
return              :  0 OK!
1 -> Se ha producido un error
***********************************************************************/
FUNCTION f_get_ultimareserva(
    pnsinies IN VARCHAR2,
    ult_reserva OUT sys_refcursor,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_pagogar';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
BEGIN
  vnumerr     := pac_siniestros.f_get_ultimareserva(pnsinies, pac_md_common.f_get_cxtidioma, vsquery);
  ult_reserva := pac_md_listvalores.f_opencursor(vsquery, mensajes);
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_ultimareserva;
/***********************************************************************
Ens retorna tots els pagaments d'un sinistre idependentment de la tramitació,
param in  pnsinies  : número de siniestro
param in  pctippag  : tipo de pago 2--> pago, 7 --> recobro
param out pagosporsinistro : Capçalera del pagament
param out mensajes  : mensajes de error
return              :  0 OK!
1 -> Se ha producido un error
***********************************************************************/
FUNCTION f_get_pagosporsiniestro(
    pnsinies IN VARCHAR2,
    pctippag IN NUMBER,
    pagosporsinistro OUT sys_refcursor,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_pagosporsinistro';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
BEGIN
  vnumerr          := pac_siniestros.f_get_pagosporsiniestro(pnsinies, pctippag, pac_md_common.f_get_cxtidioma, vsquery, pac_md_common.f_get_cxtagente);
  pagosporsinistro := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_pagosporsiniestro;
/***********************************************************************
Ens retorna tots els pagaments d'una reserva i una tramitació concreta,
param in  pnsinies  : número de siniestro
param in  pctippag  : tipo de pago 2--> pago, 7 --> recobro
param out detallespagos : Capçalera del pagament
param out mensajes  : mensajes de error
return              :  0 OK!
1 -> Se ha producido un error
***********************************************************************/
FUNCTION f_get_detallespagos(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctipres IN NUMBER,
    pctippag IN NUMBER,
    pcgarant IN NUMBER,
    psidepag IN NUMBER,
    pnmovres IN NUMBER,
    detallespagos OUT sys_refcursor,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_detallespago';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
BEGIN
  vnumerr       := pac_siniestros.f_get_detallespagos(pnsinies, pntramit, pctipres, pctippag, pcgarant, psidepag, pnmovres, pac_md_common.f_get_cxtidioma, vsquery, pac_md_common.f_get_cxtagente);
  detallespagos := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_detallespagos;
/***********************************************************************
Recupera los datos del último recibo de la póliza
param in psseguro  : código de seguro
param out mensajes : mensajes de error
return             : ref cursor
***********************************************************************/
FUNCTION f_get_pollastrecibo(
    psseguro IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_PolLastRecibo';
  vparam      VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  --etm 21634/109594
  vpasexec := 3;
  vsquery  := 'select r.nrecibo, ' || '         to_date(to_char(fefecto,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fefecto, ' || '         to_date(to_char(fvencim,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fvencim, ' || '         itotalr as iconcep, ' || '         cestrec, ' || '         (select tatribu from detvalores where cvalor = 1 and catribu = cestrec and cidioma = ' || pac_md_common.f_get_cxtidioma || ') as testrec, ' || '         ctiprec, ' || '         (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = ' || pac_md_common.f_get_cxtidioma || ') as ttiprec  , ' || ' cestimp , ' || '         (select tatribu from detvalores where cvalor = 75 and catribu = cestimp and cidioma = ' || pac_md_common.f_get_cxtidioma || ') as tcestimp  ' || ' from recibos r, movrecibo m, vdetrecibos v ' || ' where  r.sseguro = ' || psseguro || ' and r.nrecibo = m.nrecibo ' ||
  ' and r.nrecibo = (select max(r2.nrecibo) from recibos r2   where r2.sseguro = r.sseguro) ' || ' and m.smovrec = (select max(m2.smovrec) from movrecibo m2 where m2.nrecibo = m.nrecibo) ' || ' and r.nrecibo = v.nrecibo ';
  vpasexec := 5;
  vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN vcursor;
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_get_pollastrecibo;
/***********************************************************************
Recupera los datos del último recibo de la póliza
param in psseguro  : código de seguro
param out mensajes : mensajes de error
return             : ref cursor
***********************************************************************/
FUNCTION f_get_pollastrecibo2(
    psseguro IN NUMBER,
    pfsinies IN DATE,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_pollastrecibo2';
  vparam      VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 3;
  vsquery  := 'select r.nrecibo, ' || '         to_date(to_char(r.fefecto,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fefecto, ' || '         to_date(to_char(r.fvencim,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fvencim, ' || '         itotalr as iconcep, ' || '         cestrec, ' || '         (select tatribu from detvalores where cvalor = 1 and catribu = cestrec and cidioma = ' || pac_md_common.f_get_cxtidioma || ') as testrec, ' || '         ctiprec, ' || '         (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = ' || pac_md_common.f_get_cxtidioma || ') as ttiprec  ' || ' from recibos r, movrecibo m, vdetrecibos v, seguros s ' || ' where  r.sseguro = ' || psseguro || ' and r.nrecibo = m.nrecibo and s.sseguro = r.sseguro ' || ' and (trunc(s.fcaranu)-(trunc(s.fcaranu)-trunc(' || pfsinies || '))-1) < trunc(r.fefecto) ' || ' and trunc(s.fcaranu) > trunc(r.fefecto) ' || ' and r.nrecibo = v.nrecibo ';
  vpasexec := 5;
  vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN vcursor;
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_get_pollastrecibo2;
/***********************************************************************
Graba los datos del siniestro en la variable global objeto del paquete
param in  psseguro  : código de seguro
param in  pnriesgo  : número de riesgo
param in  nmovimi   : Número Movimiento Seguro
param in  pfsinies  : fecha de ocurrencia del siniestro
param in  phsinies  : hora de ocurrencia del siniestro
param in  pfnotifi  : fecha de notificación del siniestro
param in  pccausin   : Código Causa Siniestro
param in  pcmotsin  : código del motivo del siniestro
param in  pcevento   : Código Evento Siniestro
param in  pcculpab  : código de la culpabilidad del siniestro
param in  pcreclama  : Código reclamación VF 200011
param in  pnasegur   : Número asegurado (producto 2 cabezas)
param in  pcmeddec   : Código Medio declaración
param in  pctipdec   : Código Tipo Declarante
param in  ptnomdec   : Nombre Declarante
param in  ptape1dec  : Primer Apellido Declarante
param in  ptape2dec  : Segundo Apellido Declarante
param in  ptteldec   : Teléfono Declarante
param in  ptsinies  : descripción del siniestro
param in  pcnivel  : Nivel Siniestro
param in  psperson2  : Persona relacionada
param in  pfechapp  : Fecha para planes pensiones
param in  pasistencia : Asistencia (0=No, 1=Si)
param out mensajes  : mensajes de error
return              : 1 -> Todo correcto
0 -> Se ha producido un error
-- Bug 0022099 - 16/05/2012 - JMF: añadir asistencia
***********************************************************************/
FUNCTION f_set_cabecera_siniestro(
    pnsinies  IN VARCHAR2,
    psseguro  IN NUMBER,
    pnriesgo  IN NUMBER,
    pnmovimi  IN NUMBER,
    pfsinies  IN DATE,
    phsinies  IN VARCHAR2,
    pfnotifi  IN DATE,
    pccausin  IN NUMBER,
    pcmotsin  IN NUMBER,
    pcevento  IN VARCHAR2,
    pcculpab  IN NUMBER,
    pcreclama IN NUMBER,
    pnasegur  IN NUMBER,
    pcmeddec  IN NUMBER,
    pctipdec  IN NUMBER,
    ptnomdec  IN VARCHAR2,
    ptnom1dec IN VARCHAR2,
    -- bug 19896 --ETM  -20/12/2011-- Añadir campo nombre 1 al declarante
    ptnom2dec IN VARCHAR2,
    -- bug 19896 --ETM  -20/12/2011-- Añadir campo nombre 2 al declarante
    ptape1dec  IN VARCHAR2,
    ptape2dec  IN VARCHAR2,
    ptteldec   IN VARCHAR2,
    ptmovildec IN VARCHAR2,
    -- bug 19896 --ETM  -20/12/2011-- Añadir campo movil al declarante
    ptemaildec IN VARCHAR2,
    -- bug 19896 --ETM  -20/12/2011-- Añadir campo email al declarante
    ptsinies     IN VARCHAR2,
    pctipide     IN NUMBER,
    pnnumide     IN VARCHAR2,
    psperson_dec IN NUMBER,
    pnsincia     IN VARCHAR2, --BUG 14587 - PFA - 13/08/2010 - Añadir campo siniestro compañia
    pccompani    IN NUMBER,
    pnpresin     IN VARCHAR2,
    -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en búsqueda siniestros
    -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
    pcnivel   IN NUMBER,
    psperson2 IN NUMBER,
    pfechapp  IN DATE,
    -- Fi Bug 0015669 - JRH - 30/09/2010
    pcpolcia    IN VARCHAR2, --BUG17539 - JTS - 10/02/2011
    piperit     IN VARCHAR2, --BUG17539 - JTS - 10/02/2011
    pcfraude    IN NUMBER,   --BUG18748 - JBN
    pccarpeta   IN NUMBER,   --BUG19832 - 21/10/2011 - JMP
    pasistencia IN NUMBER,
    pcagente    IN NUMBER, -- Bug 21817 - MDS - 2/05/2012
    pcsalvam    IN NUMBER, -- BUG 0024675 - 15/11/2012 - JMF
    --BUG 39475/222692
    pfdeteccion   IN DATE DEFAULT NULL,
    vgobsiniestro IN OUT ob_iax_siniestros,
    mensajes      IN OUT t_iax_mensajes,
  psolidaridad  IN NUMBER DEFAULT NULL, --CONF-249
  ptdetpreten     IN VARCHAR2 DEFAULT NULL)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Set_cabecera_Siniestro';
  -- Bug 17064 - 04/01/2011 -AMC
  vparam    VARCHAR2(3000) := 'parámetros - psseguro: ' || psseguro || ' - pnriesgo: ' || pnriesgo || ' - pfsinies: ' || pfsinies || ' - pfnotifi: ' || pfnotifi || ' - ptsinies: ' || ptsinies || ' pasistencia=' || pasistencia || ' pcagente=' || pcagente || ' pCSALVAM=' || pcsalvam;
  vpasexec  NUMBER(5)      := 1;
  vnumerr   NUMBER(8)      := 0;
  vcagrpro  NUMBER(2);
  vtmotsin  VARCHAR2(1000) := '';
  vtcausin  VARCHAR2(1000) := '';
  vtevento  VARCHAR2(1000) := '';
  ptriesgo1 VARCHAR2(200)  := '';
  ptriesgo2 VARCHAR2(200)  := '';
  ptriesgo3 VARCHAR2(200)  := '';
  -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
  vcagente NUMBER;
  -- Fi Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
  v_index     NUMBER;
  vtunitra    VARCHAR2(400);
  vttramitad  VARCHAR2(400);
  v_cunitra   VARCHAR2(40);
  v_ctramitad VARCHAR2(40);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL OR pnriesgo IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pccausin IS NULL THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000637);
    RETURN 1;
  END IF;
  IF pcmotsin IS NULL THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000638);
    RETURN 1;
  END IF;
  IF pfsinies IS NULL THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000640);
    RETURN 1;
  END IF;
  IF pfnotifi IS NULL THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000641);
    RETURN 1;
  END IF;
  vpasexec := 4;
  BEGIN
    SELECT tcausin
    INTO vtcausin
    FROM sin_descausa
    WHERE ccausin = pccausin
    AND cidioma   = pac_md_common.f_get_cxtidioma;
    SELECT tmotsin
    INTO vtmotsin
    FROM sin_desmotcau
    WHERE ccausin = pccausin
    AND cmotsin   = pcmotsin
    AND cidioma   = pac_md_common.f_get_cxtidioma;
  EXCEPTION
  WHEN OTHERS THEN
    vtcausin := '';
    vtmotsin := '';
  END;
  BEGIN
    SELECT ttiteve
    INTO vtevento
    FROM sin_desevento
    WHERE cevento = pcevento
    AND cidioma   = pac_md_common.f_get_cxtidioma;
  EXCEPTION
  WHEN OTHERS THEN
    vtevento := '';
  END;
  vpasexec := 5;
  --select * from tab_error order by seqerror desc
  --Ini bug.: 18977 - 13/07/2011 - ICV - Modificamos el tramitador del movimiento ya que es aqui donde tenemos el ccausin y cmotsin
  v_index := vgobsiniestro.movimientos.LAST;
  /*vnumerr := pac_siniestros.f_get_unitradefecte(pcempres, pcunitra, pctramit);*/
  -- 23101:ASN:28/08/2012 ini
  /*
  vnumerr := pac_md_siniestros.f_get_tramitador_defecto(pac_md_common.f_get_cxtempresa(),
  f_user, psseguro, pccausin,
  pcmotsin, NULL, NULL,   -- 22108:ASN:04/06/2012
  NULL, v_cunitra, v_ctramitad,
  mensajes);
  vpasexec := 51;
  IF NVL(vnumerr, 99999) > 1 THEN   --El error 1 es de tramitador por defecto U000
  RAISE e_object_error;
  END IF;
  */
  v_cunitra   := 'U000';
  v_ctramitad := 'T000';
  -- 23101:ASN:28/08/2012 fin
  vnumerr := 0;
  BEGIN
    SELECT ttramitad
    INTO vtunitra
    FROM sin_codtramitador tram
    WHERE tram.ctramitad = v_cunitra;
    SELECT ttramitad
    INTO vttramitad
    FROM sin_codtramitador tram
    WHERE tram.ctramitad = v_ctramitad;
  EXCEPTION
  WHEN OTHERS THEN
    vtunitra   := '';
    vttramitad := '';
  END;
  vgobsiniestro.movimientos(v_index).cunitra                                                                                                                             := v_cunitra;
  vgobsiniestro.movimientos(v_index).tunitra                                                                                                                             := vtunitra;
  vgobsiniestro.movimientos(v_index).ctramitad                                                                                                                           := v_ctramitad;
  vgobsiniestro.movimientos(v_index).ttramitad                                                                                                                           := vttramitad;
  IF vgobsiniestro.tramitaciones                                                                                                                                         IS NOT NULL AND vgobsiniestro.tramitaciones.COUNT > 0 THEN
    vgobsiniestro.tramitaciones(vgobsiniestro.tramitaciones.LAST).movimientos (vgobsiniestro.tramitaciones(vgobsiniestro.tramitaciones.LAST).movimientos.LAST).cunitra   := v_cunitra;
    vgobsiniestro.tramitaciones(vgobsiniestro.tramitaciones.LAST).movimientos (vgobsiniestro.tramitaciones(vgobsiniestro.tramitaciones.LAST).movimientos.LAST).tunitra   := vtunitra;
    vgobsiniestro.tramitaciones(vgobsiniestro.tramitaciones.LAST).movimientos (vgobsiniestro.tramitaciones(vgobsiniestro.tramitaciones.LAST).movimientos.LAST).ctramitad := v_ctramitad;
    vgobsiniestro.tramitaciones(vgobsiniestro.tramitaciones.LAST).movimientos (vgobsiniestro.tramitaciones(vgobsiniestro.tramitaciones.LAST).movimientos.LAST).ttramitad := vttramitad;
  END IF;
  --Fin Bug 18977
  vpasexec := 52;
  --Còpia dels paràmetres passats per paràmetre, a la variable global objecte sinistre del paquet.
  vgobsiniestro.nsinies     := pnsinies;
  vgobsiniestro.sseguro     := psseguro;
  vgobsiniestro.nriesgo     := pnriesgo;
  vgobsiniestro.nmovimi     := pnmovimi;
  vgobsiniestro.fsinies     := pfsinies;
  vgobsiniestro.hsinies     := phsinies;
  vgobsiniestro.fnotifi     := pfnotifi;
  vgobsiniestro.ccausin     := pccausin;
  vgobsiniestro.tcausin     := vtcausin;
  vgobsiniestro.cmotsin     := pcmotsin;
  vgobsiniestro.tmotsin     := vtmotsin;
  vgobsiniestro.cevento     := pcevento;
  vgobsiniestro.tevento     := vtevento;
  vgobsiniestro.cculpab     := pcculpab;
  vgobsiniestro.ctipide     := pctipide;
  vgobsiniestro.ttipide     := ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(), pctipide);
  vgobsiniestro.nnumide     := pnnumide;
  vgobsiniestro.dec_sperson := psperson_dec;
  vgobsiniestro.nsincia     := pnsincia;
  --BUG 14587 - PFA - 13/08/2010 - Añadir campo siniestro compañia
  -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en búsqueda siniestros
  vgobsiniestro.npresin    := pnpresin;
  vgobsiniestro.ccompani   := pccompani;
  vgobsiniestro.cpolcia    := pcpolcia; --BUG17539 - JTS - 10/02/2011
  vgobsiniestro.iperit     := piperit;  --BUG17539 - JTS - 10/02/2011
  vgobsiniestro.fdeteccion := pfdeteccion;
  vgobsiniestro.solidaridad := psolidaridad; -- CONF-249
  vgobsiniestro.tdetpreten := ptdetpreten;
  -- Fi Bug 15006 - PFA - 16/08/2010 - nuevos campos en búsqueda siniestros
  IF pcculpab             IS NOT NULL THEN
    vgobsiniestro.tculpab := ff_desvalorfijo(801, pac_md_common.f_get_cxtidioma, pcculpab);
  END IF;
  vpasexec                 := 9;
  vgobsiniestro.creclama   := pcreclama;
  IF pcreclama             IS NOT NULL THEN
    vgobsiniestro.treclama := ff_desvalorfijo(318, pac_md_common.f_get_cxtidioma, pcreclama);
  END IF;
  vgobsiniestro.nasegur   := pnasegur;
  vgobsiniestro.cmeddec   := pcmeddec;
  IF pcmeddec             IS NOT NULL THEN
    vgobsiniestro.tmeddec := ff_desvalorfijo(319, pac_md_common.f_get_cxtidioma, pcmeddec);
  END IF;
  IF pctipdec             IS NOT NULL THEN
    vgobsiniestro.ttipdec := ff_desvalorfijo(321, pac_md_common.f_get_cxtidioma, pctipdec);
  END IF;
  vgobsiniestro.ctipdec  := pctipdec;
  vgobsiniestro.tnomdec  := ptnomdec;
  vgobsiniestro.tnom1dec := ptnom1dec;
  --bug 19896 -ETM--20/12/2011-Añadir campo nombre1 al declarante
  vgobsiniestro.tnom2dec := ptnom2dec;
  --bug 19896 -ETM--20/12/2011-Añadir campo nombre2 al declarante
  vgobsiniestro.tape1dec  := ptape1dec;
  vgobsiniestro.tape2dec  := ptape2dec;
  vgobsiniestro.tteldec   := ptteldec;
  vgobsiniestro.tmovildec := ptmovildec;
  --bug 19896 -ETM--20/12/2011-Añadir campo movil al declarante
  vgobsiniestro.temaildec := ptemaildec;
  vgobsiniestro.solidaridad := psolidaridad; --CONF-249
  --bug 19896 -ETM--20/12/2011-Añadir campo email al declarante
  vgobsiniestro.tsinies := ptsinies;
  vnumerr               := f_desriesgo(vgobsiniestro.sseguro, vgobsiniestro.nriesgo, NULL, pac_md_common.f_get_cxtidioma, ptriesgo1, ptriesgo2, ptriesgo3);
  vgobsiniestro.triesgo := ptriesgo1 || ' ' || ptriesgo2 || ' ' || ptriesgo3;
  -- Cal mirar si l'agrupació del producte és la de Autos, i en tal cas, la culpabilitat ha de ser obligatòria
  vpasexec              := 5;
  vcagrpro              := pac_mdpar_productos.f_get_agrupacio(psseguro, mensajes);
  vgobsiniestro.cfraude := pcfraude;
  --BUG18748 - JBN
  IF pcfraude             IS NOT NULL THEN
    vgobsiniestro.tfraude := ff_desvalorfijo(1034, pac_md_common.f_get_cxtidioma(), pcfraude);
  END IF;
  -- BUG 0023643 - 05/11/2012 - JMF
  vgobsiniestro.ireserva9999 := pac_siniestros.f_ireserva_ctramte(pnsinies, 9999);
  vgobsiniestro.ccarpeta     := pccarpeta;
  vgobsiniestro.cagente      := pcagente;                -- Bug 21817 - MDS - 2/05/2012
  vgobsiniestro.tagente      := f_desagente_t(pcagente); -- Bug 21817 - MDS - 2/05/2012
  vgobsiniestro.csalvam      := pcsalvam;                -- BUG 0024675 - 15/11/2012 - JMF
  IF mensajes                IS NOT NULL THEN
    IF mensajes.COUNT         > 0 THEN
      RAISE e_object_error;
    END IF;
  END IF;
  vpasexec      := 6;
  IF vcagrpro    = 50 THEN -- Agrupació Autos
    IF pcculpab IS NULL THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000609);
      RETURN 1;
    END IF;
  END IF;
  -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
  vgobsiniestro.cnivel   := pcnivel;
  vgobsiniestro.sperson2 := psperson2;
  IF pcnivel             IS NOT NULL THEN
    vgobsiniestro.tnivel := ff_desvalorfijo(1017, pac_md_common.f_get_cxtidioma, pcnivel);
  END IF;
  IF psperson2  IS NOT NULL THEN
    vcagente    := pac_persona.f_get_agente_detallepersona(psperson2, pac_md_common.f_get_cxtagente, pac_md_common.f_get_cxtempresa);
    IF vcagente IS NULL THEN
      vcagente  := pac_md_common.f_get_cxtagente;
    END IF;
    vgobsiniestro.tperson2 := f_nombre(psperson2, 1, vcagente);
  END IF;
  vgobsiniestro.fechapp := pfechapp;
  -- Fi Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
  -- ini Bug 0022099 - 16/05/2012 - JMF
  -- ASN:28/06/2012 ini
  IF pasistencia = 1 THEN
    vpasexec    := 100;
    DECLARE
      v_sproduc seguros.sproduc%TYPE;
      v_cactivi seguros.cactivi%TYPE;
      v_ntramte sin_tramite.ntramte%TYPE;
      v_codi sin_tramite.ctramte%TYPE;
    BEGIN
      vpasexec                  := 110;
      IF vgobsiniestro.tramites IS NOT NULL AND vgobsiniestro.tramites.COUNT > 0 THEN
        vpasexec                := 120;
        FOR i IN vgobsiniestro.tramites.FIRST .. vgobsiniestro.tramites.LAST
        LOOP
          vpasexec := 121;
          IF vgobsiniestro.tramites.EXISTS(i) THEN
            IF NVL(vgobsiniestro.tramites(i).ctramte, 0) <> 9999 THEN
              IF vgobsiniestro.tramitaciones             IS NOT NULL AND vgobsiniestro.tramitaciones.COUNT > 0 THEN
                vpasexec                                 := 130;
                FOR j IN vgobsiniestro.tramitaciones.FIRST .. vgobsiniestro.tramitaciones.LAST
                LOOP
                  vpasexec                                 := 131;
                  IF vgobsiniestro.tramitaciones(j).ntramte = vgobsiniestro.tramites(i).ntramte THEN
                    vpasexec                               := 132;
                    vgobsiniestro.tramitaciones.DELETE(j);
                  END IF;
                END LOOP;
              END IF;
              vgobsiniestro.tramites.DELETE(i);
            END IF;
          END IF;
        END LOOP;
      END IF;
      vpasexec := 170;
      SELECT sproduc,
        cactivi
      INTO v_sproduc,
        v_cactivi
      FROM seguros
      WHERE sseguro = psseguro;
      vpasexec     := 180;
      vnumerr      := pac_md_sin_tramite.f_inicializa_tramites(v_sproduc, v_cactivi, pnsinies, 5, vgobsiniestro.tramites, mensajes);
      IF vnumerr   <> 0 THEN
        RAISE e_object_error;
      END IF;
      IF vgobsiniestro.tramites IS NOT NULL AND vgobsiniestro.tramites.COUNT > 0 THEN
        vpasexec                := 190;
        FOR i IN vgobsiniestro.tramites.FIRST .. vgobsiniestro.tramites.LAST
        LOOP
          IF vgobsiniestro.tramites.EXISTS(i) THEN
            IF vgobsiniestro.tramites(i).ctramte = 5 THEN
              vpasexec                          := 200;
              v_ntramte                         := vgobsiniestro.tramites(i).ntramte;
              vpasexec                          := 210;
              vnumerr                           := f_inicializa_tramitaciones(v_sproduc, v_cactivi, pnsinies, v_cunitra, v_ctramitad, vgobsiniestro.tramites(i).ctramte,
              -- Bug 0022099
              0,
              -- bug21196:ASN:26/03/2012 'valor = tramitacion apertura'
              v_ntramte, -- Bug 0022099
              vgobsiniestro.tramitaciones, mensajes);
              IF vnumerr <> 0 THEN
                RAISE e_object_error;
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END;
    vpasexec := 230;
  ELSE
    -- si no es asistencia borramos el tramite de asistencia que se habra creado automaticamente
    IF vgobsiniestro.tramites IS NOT NULL AND vgobsiniestro.tramites.COUNT > 0 THEN
      vpasexec                := 250;
      FOR i IN vgobsiniestro.tramites.FIRST .. vgobsiniestro.tramites.LAST
      LOOP
        vpasexec := 260;
        IF vgobsiniestro.tramites.EXISTS(i) THEN
          IF NVL(vgobsiniestro.tramites(i).ctramte, 0) = 5 THEN
            IF vgobsiniestro.tramitaciones            IS NOT NULL AND vgobsiniestro.tramitaciones.COUNT > 0 THEN
              vpasexec                                := 122;
              FOR j IN vgobsiniestro.tramitaciones.FIRST .. vgobsiniestro.tramitaciones.LAST
              LOOP
                vpasexec                                 := 132;
                IF vgobsiniestro.tramitaciones(j).ntramte = vgobsiniestro.tramites(i).ntramte THEN
                  vpasexec                               := 133;
                  vgobsiniestro.tramitaciones.DELETE(j);
                END IF;
              END LOOP;
            END IF;
            vgobsiniestro.tramites.DELETE(i);
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;
  -- ASN:28/06/2012 fin
  -- fin Bug 0022099 - 16/05/2012 - JMF
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_cabecera_siniestro;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
ncitacion      NUMBER(3),   --Número citacion Siniestro
sperson        NUMBER(6),   --Secuencia Persona
fcitacion        VARCHAR2(100),--fecha citacion
hcitacion        NUMBER(2),   --hora citacion
cpais        VARCHAR2(100),   --cod pais
cprovin        VARCHAR2(40),   --cod provincia
cpoblac        NUMBER(5),   --cod poblacion
tlugar       VARCHAR2(200) -- Lugar citacion
pcitacion    OUT    ob_iax_sin_trami_citacion
*************************************************************************/
FUNCTION f_set_objeto_sintramicit(
    pnsinies   IN VARCHAR2,
    pntramit   IN NUMBER,
    pncitacion IN NUMBER,
    psperson   IN NUMBER,
    pfcitacion IN DATE,
    phcitacion IN VARCHAR2,
    pcpais     IN NUMBER,
    pcprovin   IN NUMBER,
    pcpoblac   IN NUMBER,
    ptlugar    IN VARCHAR2,
    ptaudien   IN VARCHAR2,
    pcoral     IN NUMBER,
    pcestado   IN NUMBER,
    pcresolu   IN NUMBER,
    pfnueva    IN DATE,
    ptresult   IN VARCHAR2,
    pcmedio    IN NUMBER,
    pcitacion  IN OUT ob_iax_sin_trami_citacion,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_objeto_sintramicit';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pncitacion: ' || pncitacion || ' - psperson: ' || psperson    ||' - pcoral     :'||  pcoral
                                ||' - pcestado   :'||  pcestado    ||' - pcresolu   :'||  pcresolu    ||' - pfnueva    :'||  pfnueva     ||' - ptresult   :'||  ptresult     ||' - pcmedio   :'||  pcmedio;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcagente    NUMBER;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec            := 2;
  pcitacion.nsinies   := pnsinies;
  pcitacion.ntramit   := pntramit;
  pcitacion.ncitacion := pncitacion;
  vpasexec            := 3;
  IF psperson         IS NOT NULL THEN
    vcagente          := pac_persona.f_get_agente_detallepersona(psperson, pac_md_common.f_get_cxtagente, pac_md_common.f_get_cxtempresa);
    IF vcagente       IS NULL THEN
      vcagente        := pac_md_common.f_get_cxtagente;
    END IF;
    vpasexec          := 4;
    pcitacion.persona := pac_md_persona.f_get_persona(psperson, vcagente, mensajes, 'POL');
  END IF;
  vpasexec                := 5;
  pcitacion.fcitacion     := pfcitacion;
  pcitacion.hcitacion     := phcitacion;
  pcitacion.cprovin       := pcprovin;
  pcitacion.cpoblac       := pcpoblac;
  pcitacion.cpais         := pcpais;
  pcitacion.tpais         := NULL;
  pcitacion.tprovin       := NULL;
  pcitacion.tpoblac       := NULL;
  pcitacion.tlugar        := ptlugar;
  pcitacion.TAUDIEN       := ptaudien;
  pcitacion.CORAL         := pcoral;
  pcitacion.CESTADO       := pcestado;
  pcitacion.CRESOLU       := pcresolu;
  pcitacion.FNUEVA        := pfnueva;
  pcitacion.TRESULT       := ptresult;
  pcitacion.CMEDIO        := pcmedio;

  IF pcpais               IS NOT NULL THEN
    pcitacion.tpais       := ff_despais(pcpais, pac_md_common.f_get_cxtidioma);
    IF pcprovin           IS NOT NULL THEN
      pcitacion.tprovin   := f_desprovin2(pcprovin, pcpais);
      IF pcpoblac         IS NOT NULL THEN
        pcitacion.tpoblac := f_despoblac2(pcpoblac, pcprovin);
      END IF;
    END IF;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sintramicit;
/***********************************************************************
Recupera los datos de persona por defecto
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out mensajes  : mensajes de error
return              : SYS_CURSOR
***********************************************************************/
FUNCTION f_get_asiste_citacion_def(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN SYS_REFCURSOR
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_asiste_citacion_def';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
BEGIN
  vsquery :=
  'SELECT p.sperson,
       p.nnumide,
       pdp.tnombre,
       pdp.tapelli1,
       pdp.tapelli2
  FROM per_personas p,
       per_detper   pdp,
       usuarios     u
 WHERE p.sperson = pdp.sperson
   AND u.sperson = p.sperson
   AND u.cusuari =
       (SELECT cusuari
          FROM sin_tramita_movimiento stm,
               sin_codtramitador      sc
         WHERE stm.nsinies = ' || pnsinies || '
           AND stm.ntramit = ' || pntramit || '
           AND stm.ctramitad = sc.ctramitad
           AND stm.nmovtra = (SELECT MAX(nmovtra)
                                FROM sin_tramita_movimiento mv
                               WHERE mv.nsinies = stm.nsinies
                                 AND mv.ntramit = stm.ntramit))';
  vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN vcursor;
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_get_asiste_citacion_def;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.localizacion
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
nlocali        NUMBER(3),   --Número Localización Siniestro
sperson        NUMBER(6),   --Secuencia Persona
tnombre        VARCHAR2(100),--Nombre persona
csiglas        NUMBER(2),   --Código Tipo Vía
tsiglas        VARCHAR2(100),   --Des Siglas
tnomvia        VARCHAR2(40),   --Nombre Vía
nnumvia        NUMBER(5),   --Número Vía
tcomple        VARCHAR2(15),   --Descripción Complementaria
tlocali        VARCHAR2(100),   --Dirección no normalizada
cpais          NUMBER(3),   --Código País
tpais          VARCHAR2(200),   -- Desc. Pais
cprovin        NUMBER(5),   --Código Província
tprovin        VARCHAR2(200),   --Desc Provin
cpoblac        NUMBER(5),   --Código Población
tpoblac        VARCHAR2(200),   --Desc Poblacio
cpostal        VARCHAR2(30),   --Código Postal
-- Bug 20154/98048 - 15/11/2011 - AMC
param in cviavp,    -- Código de via predio - via principal
param in clitvp,    -- Código de literal predio - via principal
param in cbisvp,    -- Código BIS predio - via principal
param in corvp,     -- Código orientación predio - via principal
param in nviaadco,  -- Número de via adyacente predio - coordenada
param in clitco,    -- Código de literal predio - coordenada
param in corco,     -- Código orientación predio - coordenada
param in nplacaco,  -- Número consecutivo placa predio - ccordenada
param in cor2co,    -- Código orientación predio 2 - coordenada
param in cdet1ia,   -- Código detalle 1 - información adicional
param in tnum1ia,   -- Número predio 1 - informacion adicional
param in cdet2ia,   -- Código detalle 2 - información adicional
param in tnum2ia,   -- Número predio 2 - informacion adicional
param in cdet3ia,   -- Código detalle 3 - información adicional
param in tnum3ia    -- Número predio 3 - informacion adicional
-- Fi Bug 20154/98048- 15/11/2011 - AMC
param in plocalidad -- Descripcion de la localidad -- Bug 24780/130907 - 05/12/2012 - AMC
*************************************************************************/
FUNCTION f_set_objeto_sintramilocali(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pnlocali IN NUMBER,
    psperson IN NUMBER,
    pcsiglas IN NUMBER,
    ptnomvia IN VARCHAR2,
    pnnumvia IN NUMBER,
    ptcomple IN VARCHAR2,
    ptlocali IN VARCHAR2,
    pcpais   IN NUMBER,
    pcprovin IN NUMBER,
    pcpoblac IN NUMBER,
    pcpostal IN VARCHAR2,
    -- Bug 20154/98048 - 15/11/2011 - AMC
    pcviavp   IN NUMBER,
    pclitvp   IN NUMBER,
    pcbisvp   IN NUMBER,
    pcorvp    IN NUMBER,
    pnviaadco IN NUMBER,
    pclitco   IN NUMBER,
    pcorco    IN NUMBER,
    pnplacaco IN NUMBER,
    pcor2co   IN NUMBER,
    pcdet1ia  IN NUMBER,
    ptnum1ia  IN VARCHAR2,
    pcdet2ia  IN NUMBER,
    ptnum2ia  IN VARCHAR2,
    pcdet3ia  IN NUMBER,
    ptnum3ia  IN VARCHAR2,
    -- Fi Bug 20154/98048- 15/11/2011 - AMC
    plocalidad IN VARCHAR2, -- Bug 24780/130907 - 05/12/2012 - AMC
    vlocaliza  IN OUT ob_iax_sin_trami_localiza,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_set_objeto_sintramilocali';
  vparam      VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pnlocali: ' || pnlocali || ' - psperson: ' || psperson;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  ptsiglas    VARCHAR2(1000) := '';
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec    := 4;
  IF ptlocali IS NULL THEN -- 21009:ASN:23/01/2012
    vnumerr   := pac_propio.f_valdireccion(pcviavp, ptnomvia, pcdet1ia, ptnum1ia, pcdet2ia, ptnum2ia, pcdet3ia, ptnum3ia);
  END IF;
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_param_error;
  END IF;
  vpasexec := 5;
  --select * from tab_error order by seqerror desc
  BEGIN
    SELECT d.tdenom
    INTO ptsiglas
    FROM destipos_via d
    WHERE d.csiglas = pcsiglas
    AND d.cidioma   = pac_md_common.f_get_cxtidioma;
  EXCEPTION
  WHEN OTHERS THEN
    ptsiglas := NULL;
  END;
  --Còpia dels paràmetres passats per paràmetre, a la variable global objecte sinistre del paquet.
  vlocaliza.nsinies := pnsinies;
  vlocaliza.ntramit := pntramit;
  vlocaliza.nlocali := pnlocali;
  vlocaliza.sperson := psperson;
  vlocaliza.csiglas := pcsiglas;
  vlocaliza.tsiglas := ptsiglas;
  vlocaliza.tnomvia := ptnomvia;
  --vlocaliza.tnombre := ptnombre;
  vlocaliza.nnumvia       := pnnumvia;
  vlocaliza.tcomple       := ptcomple;
  vlocaliza.tlocali       := ptlocali;
  vlocaliza.cpais         := pcpais;
  vlocaliza.tpais         := NULL;
  vlocaliza.tprovin       := NULL;
  vlocaliza.tpoblac       := NULL;
  IF pcpais               IS NOT NULL THEN
    vlocaliza.tpais       := ff_despais(pcpais, pac_md_common.f_get_cxtidioma);
    IF pcprovin           IS NOT NULL THEN
      vlocaliza.tprovin   := f_desprovin2(pcprovin, pcpais);
      IF pcpoblac         IS NOT NULL THEN
        vlocaliza.tpoblac := f_despoblac2(pcpoblac, pcprovin);
      END IF;
    END IF;
  END IF;
  vlocaliza.cprovin := pcprovin;
  vlocaliza.cpoblac := pcpoblac;
  vlocaliza.cpostal := pcpostal;
  -- Bug 20154/98048 - 15/11/2011 - AMC
  vlocaliza.cviavp    := pcviavp;
  vlocaliza.clitvp    := pclitvp;
  vlocaliza.cbisvp    := pcbisvp;
  vlocaliza.corvp     := pcorvp;
  vlocaliza.nviaadco  := pnviaadco;
  vlocaliza.clitco    := pclitco;
  vlocaliza.corco     := pcorco;
  vlocaliza.nplacaco  := pnplacaco;
  vlocaliza.cor2co    := pcor2co;
  vlocaliza.cdet1ia   := pcdet1ia;
  vlocaliza.tnum1ia   := ptnum1ia;
  vlocaliza.cdet2ia   := pcdet2ia;
  vlocaliza.tnum2ia   := ptnum2ia;
  vlocaliza.cdet3ia   := pcdet3ia;
  vlocaliza.tnum3ia   := ptnum3ia;
  vlocaliza.localidad := plocalidad;                                                                                                                                                                                                                                                                                                                                                                                                 -- Bug 24780/130907 - 05/12/2012 - AMC
  vlocaliza.tdomici   := pac_persona.f_tdomici(vlocaliza.csiglas, vlocaliza.tnomvia, vlocaliza.nnumvia, vlocaliza.tcomple, vlocaliza.cviavp, vlocaliza.clitvp, vlocaliza.cbisvp, vlocaliza.corvp, vlocaliza.nviaadco, vlocaliza.clitco, vlocaliza.corco, vlocaliza.nplacaco, vlocaliza.cor2co, vlocaliza.cdet1ia, vlocaliza.tnum1ia, vlocaliza.cdet2ia, vlocaliza.tnum2ia, vlocaliza.cdet3ia, vlocaliza.tnum3ia, vlocaliza.localidad -- Bug 24780/130907 - 05/12/2012 - AMC
  );
  -- Fi Bug 20154/98048- 15/11/2011 - AMC
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sintramilocali;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.localizacion
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
ctramit        NUMBER(4),   --Código tipus Tramitación
ttramit        VARCHAR2(100),   --Des tipus Tramitación
ctcausin       NUMBER(2),   --Código Tipo Daño
ttcausin       VARCHAR2(100),   --Des tipo daño
cinform        NUMBER(1),   --Indicador Tramitación Informativa
tinform        VARCHAR2(100),   --Desc. INdicador tramitación Informativa
cusualt        VARCHAR2(20),   --Código Usuario Alta
falta          DATE,   --Fecha Alta
cusumod        VARCHAR2(20),   --Código Usuario Modificación
fmodifi        DATE,   --Fecha Modificación
ctiptra        NUMBER,
cborrab        NUMBER,
ttiptra        VARCHAR2(200),
detalle        ob_iax_sin_trami_detalle,-- detall de la tramitacio
-- BUG 0023536 - 24/10/2012 - JMF: Afegir csubtiptra
*************************************************************************/
FUNCTION f_set_objeto_sintramitacion(
    pnsinies     IN VARCHAR2,
    pntramit     IN NUMBER,
    pctramit     IN NUMBER,
    pctcausin    IN NUMBER,
    pcinform     IN NUMBER,
    pctiptra     IN NUMBER,
    pcculpab     IN NUMBER,
    pccompani    IN NUMBER,
    pcpolcia     IN VARCHAR2,
    piperit      IN NUMBER,
    pnsincia     IN VARCHAR2,
    vtramitacion IN OUT ob_iax_sin_tramitacion,
    mensajes     IN OUT t_iax_mensajes,
    pntramte     IN NUMBER DEFAULT NULL, -- Bug : 0018336 - JMC - 02/05/2011
    pcsubtiptra  IN NUMBER DEFAULT NULL,
    pnradica     IN VARCHAR2 DEFAULT NULL)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.F_Set_objeto_sintramitacion';
  vparam      VARCHAR2(500)  := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pctramit: ' || pctramit || ' - pctcausin: ' || pctcausin || ' inf=' || pcinform || ' pctiptra=' || pctiptra || ' cul=' || pcculpab || ' cia=' || pccompani || ' pol=' || pcpolcia || ' per=' || piperit || ' sin=' || pnsincia || ' tra=' || pntramte || ' sub=' || pcsubtiptra;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vttramit    VARCHAR2(1000) := '';
  vcborrab    NUMBER(4);
  vctiptra    NUMBER;
  vtcompani   VARCHAR2(50); --BUG17539 - JTS - 10/02/2011
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec     := 5;
  IF pccompani IS NOT NULL THEN
    SELECT tcompani
    INTO vtcompani
    FROM companias comp
    WHERE comp.ccompani = pccompani;
  END IF;
  vpasexec              := 6;
  vtramitacion.ccompani := pccompani;
  vtramitacion.cpolcia  := pcpolcia;
  vtramitacion.iperit   := piperit;
  vtramitacion.nsincia  := pnsincia;
  vtramitacion.tcompani := vtcompani;
  BEGIN
    vpasexec := 7;
    SELECT DISTINCT dest.ttramit,
      cborrab
    INTO vttramit,
      vcborrab
    FROM sin_destramitacion dest,
      sin_codtramitacion codt
    WHERE codt.ctramit = pctramit
    AND dest.ctramit   = codt.ctramit
    AND dest.cidioma   = pac_md_common.f_get_cxtidioma;
  EXCEPTION
  WHEN OTHERS THEN
    vttramit := '';
    vcborrab := NULL;
  END;
  vpasexec               := 8;
  vtramitacion.nsinies   := pnsinies;
  vtramitacion.ntramit   := pntramit;
  vtramitacion.ctramit   := pctramit;
  vtramitacion.ttramit   := vttramit;
  vtramitacion.ctcausin  := pctcausin;
  vtramitacion.ttcausin  := ff_desvalorfijo(815, pac_md_common.f_get_cxtidioma, pctcausin);
  vtramitacion.cinform   := pcinform;
  vctiptra               := pctiptra;
  vtramitacion.cculpab   := pcculpab;
  vtramitacion.nradica   := pnradica;
  IF pcculpab            IS NOT NULL THEN
    vpasexec             := 9;
    vtramitacion.tculpab := ff_desvalorfijo(801, pac_md_common.f_get_cxtidioma, pcculpab);
  END IF;
  IF pctiptra IS NULL THEN
    BEGIN
      vpasexec := 10;
      SELECT DISTINCT ctiptra
      INTO vctiptra
      FROM sin_codtramitacion codt
      WHERE codt.ctramit = pctramit;
    EXCEPTION
    WHEN OTHERS THEN
      vctiptra := NULL;
    END;
  END IF;
  vpasexec             := 11;
  vtramitacion.ctiptra := vctiptra;
  vpasexec             := 12;
  vtramitacion.ttiptra := ff_desvalorfijo(800, pac_md_common.f_get_cxtidioma, vctiptra);
  vtramitacion.cborrab := vcborrab;
  vtramitacion.ntramte := pntramte;
  vpasexec             := 13;
  -- BUG 0023536 - 24/10/2012 - JMF
  vtramitacion.csubtiptra := pcsubtiptra;
  vtramitacion.tsubtiptra := pac_siniestros.ff_get_subtipustram(vctiptra, pcsubtiptra, pac_md_common.f_get_cxtidioma);
  vpasexec                := 14;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sintramitacion;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.tramitaciones(i).movimientos
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
nmovtra        NUMBER(3),   --Número Movimiento Tramitación
cunitra        VARCHAR2(4),   --Código Unidad Tramitación
tunitra        VARCHAR2(100),   -- desc. Unidad Tramitación
ctramitad      VARCHAR2(4),   --Código Tramitador
ttramitad      VARCHAR2(100),   --Desc. Tramitador
cesttra        NUMBER(3),   --Código Estado Tramitación
testtra        VARCHAR2(100),   --Desc. Estado Tramitación
csubtra        NUMBER(2),   --Código Subestado Tramitación
tsubtra        VARCHAR2(100),   --Desc. Subestado Tramitación
festtra        DATE,   --Fecha Estado Tramitación
cusualt        VARCHAR2(500),   --Código Usuario Alta
falta          DATE,   --Fecha Alta
*************************************************************************/
FUNCTION f_set_objeto_sinmovtramit(
    pnsinies   IN VARCHAR2,
    pntramit   IN NUMBER,
    pnmovtra   IN NUMBER,
    pcunitra   IN VARCHAR2,
    pctramitad IN VARCHAR2,
    pcesttra   IN NUMBER,
    pcsubtra   IN NUMBER,
    pfesttra   IN DATE,
    pccauest   IN NUMBER, -- bug21196:ASN:26/03/2012
    vmovtramit IN OUT ob_iax_sin_trami_movimiento,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.F_Set_objeto_sinmovtramit';
  vparam      VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pnmovtra: ' || pnmovtra || ' - pcunitra: ' || pcunitra || ' -pctramitad: ' || pctramitad || ' pcesttra=' || pcesttra || ' pcsubtra=' || pcsubtra || ' pfesttra=' || pfesttra || ' pccauest=' || pccauest;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vtunitra    VARCHAR2(1000) := '';
  vttramitad  VARCHAR2(1000) := '';
  vcborrab    NUMBER(4);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 5;
  BEGIN
    SELECT ttramitad
    INTO vtunitra
    FROM sin_codtramitador tram
    WHERE tram.ctramitad = pcunitra;
    SELECT ttramitad
    INTO vttramitad
    FROM sin_codtramitador tram
    WHERE tram.ctramitad = pctramitad;
  EXCEPTION
  WHEN OTHERS THEN
    vtunitra   := '';
    vttramitad := '';
  END;
  vmovtramit.nsinies   := pnsinies;
  vmovtramit.ntramit   := pntramit;
  vmovtramit.nmovtra   := pnmovtra;
  vmovtramit.cunitra   := pcunitra;
  vmovtramit.tunitra   := vtunitra;
  vmovtramit.ctramitad := pctramitad;
  vmovtramit.ttramitad := vttramitad;
  vmovtramit.cesttra   := pcesttra;
  vmovtramit.ccauest   := pccauest; -- 21196:ASN:26/03/2012
  IF pcesttra          IS NOT NULL THEN
    vmovtramit.testtra := ff_desvalorfijo(6, pac_md_common.f_get_cxtidioma, pcesttra);
  END IF;
  vmovtramit.csubtra   := pcsubtra;
  IF pcsubtra          IS NOT NULL THEN
    vmovtramit.tsubtra := ff_desvalorfijo(665, pac_md_common.f_get_cxtidioma, pcsubtra);
  END IF;
  IF pccauest          IS NOT NULL THEN -- 21196:ASN:26/03/2012
    vmovtramit.tcauest := ff_desvalorfijo(739, pac_md_common.f_get_cxtidioma, pccauest);
  END IF;
  vmovtramit.festtra := pfesttra;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sinmovtramit;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.tramitaciones(i).movimientos
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
ctramit        NUMBER(4),   --Código tipus Tramitación
ttramit        VARCHAR2(200),   --Des tipus Tramitación
ctiptra        NUMBER(4),   --codi tipus tramitació
ttiptra        VARCHAR2(200),   --Des tipus Tramitación
ccompani       NUMBER(4),   --codi companyia
tcompani       VARCHAR2(200),   --desc. companyia
npoliza        NUMBER(8),   --num. polissa
cpolcia        NUMBER(8),   -- num.polissa contraria
iperit         NUMBER(10),   --import peritatge
desctramit     VARCHAR2(200),   --desc. tramitacio
persona        ob_iax_personas,   --persona tramitacio
--Persona
cestper        NUMBER,   --codi estat persona
testper        VARCHAR2(200),   -- Desc. estat de la persona
-- direccion
tdescdireccion VARCHAR2(200),   --descripció de la direcció
direccion      ob_iax_direcciones,   --direccio
--conductor
ctipcon        NUMBER,--tipo conductor
ttipcon        VARCHAR2(200),--desc tipo conductor
ctipcar        NUMBER,   --tipo permiso
ttipcar        VARCHAR2(200),--desc tipo permiso
fcarnet        DATE, --data permis
calcohol       NUMBER, --alcoholemia 1/0 S/N
-- vehiculo
ctipmat        NUMBER,   --codi tipus matricula
ttipmat        VARCHAR2(200),   --desc tipus matricula
cmatric        VARCHAR2(12),   --Matricula vehiculo
cmarca         NUMBER,   -- codi marca
tmarca         VARCHAR2(200),   -- desc marca
cmodelo        NUMBER,   --codi model
tmodelo        VARCHAR2(200),   -- desc. model
cversion       VARCHAR2(11),   --Código de Versión de Vehículo
tversion       VARCHAR2(200)
Bug 12668 - 16/02/2010 - AMC
cciudad       number(5),           -- código ciudad para chile
fgisx         float,               -- coordenada gis x (gps)
fgisy         float,               -- coordenada gis y (gps)
fgisz         float,               -- coordenada gis z (gps)
cvalida       number(2),           -- código validación dirección. valor fijo 1006.
Fi Bug 12668 - 16/02/2010 - AMC
-- BUG 0023540 - 24/10/2012 - JMF: Afegir IRECLAM, IINDEMN
*************************************************************************/
FUNCTION f_set_objeto_sintramidetalle(
    psseguro        IN NUMBER,
    pnsinies        IN VARCHAR2,
    pntramit        IN NUMBER,
    pctramit        IN NUMBER,
    pctiptra        IN NUMBER,
    pdesctramit     IN VARCHAR2,
    psperson        IN NUMBER,
    pcestper        IN NUMBER,
    ptdescdireccion IN VARCHAR2,
    pcdomici        IN NUMBER,
    pcpostal        IN VARCHAR2,
    pcprovin        IN NUMBER,
    pcpoblac        IN NUMBER,
    pcpais          IN NUMBER,
    pctipdir        IN NUMBER,
    pcsiglas        IN NUMBER,
    ptnomvia        IN VARCHAR2,
    pnnumvia        IN NUMBER,
    ptcomple        IN VARCHAR2,
    pcciudad        IN NUMBER,
    pfgisx          IN FLOAT,
    pfgisy          IN FLOAT,
    pfgisz          IN FLOAT,
    pcvalida        IN NUMBER,
    pctipcon        IN NUMBER,
    pctipcar        IN NUMBER,
    pfcarnet        IN DATE,
    pcalcohol       IN NUMBER,
    pctipmat        IN NUMBER,
    pcmatric        IN VARCHAR2,
    pcmarca         IN NUMBER,
    pcmodelo        IN NUMBER,
    pcversion       IN VARCHAR2,
    pnanyo          IN NUMBER, --BUG:25762-NSS-24/01/2013
    pcchasis        IN VARCHAR2,
    pcodmotor       IN VARCHAR2,
    pnbastid        IN VARCHAR2,
    pccilindraje    IN NUMBER,
    vtramidetalle   IN OUT ob_iax_sin_trami_detalle,
    mensajes        IN OUT t_iax_mensajes,
    pireclam        IN NUMBER DEFAULT NULL,
    piindemn        IN NUMBER DEFAULT NULL)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.F_Set_objeto_sintramidetalle';
  vparam      VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' IRECLAM=' || pireclam || ' IINDEMN=' || piindemn;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vttramit    VARCHAR2(1000) := '';
  --vtcompani      VARCHAR2(1000) := '';
  vtversion      VARCHAR2(1000) := '';
  vtmarca        VARCHAR2(1000) := '';
  vtmodelo       VARCHAR2(1000) := '';
  vcagente       NUMBER;
  vcagente_visio NUMBER;
  vcagente_per   NUMBER;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 1;
  /*  BEGIN
  SELECT ttramitad
  INTO vtunitra
  FROM sin_codtramitador tram
  WHERE tram.ctramitad = pcunitra;
  SELECT ttramitad
  INTO vttramitad
  FROM sin_codtramitador tram
  WHERE tram.ctramitad = pctramitad;
  EXCEPTION
  WHEN OTHERS THEN
  vtunitra := '';
  vttramitad := '';
  END;
  */
  BEGIN
    SELECT DISTINCT dest.ttramit
    INTO vttramit
    FROM sin_destramitacion dest,
      sin_codtramitacion codt
    WHERE codt.ctramit = pctramit
    AND dest.ctramit   = codt.ctramit
    AND dest.cidioma   = pac_md_common.f_get_cxtidioma;
  EXCEPTION
  WHEN OTHERS THEN
    vttramit := '';
  END;
  vpasexec := 2;
  vnumerr  := pac_seguros.f_get_cagente(psseguro, 'SEG', vcagente);
  vpasexec := 3;
  /*BEGIN
  --SELECT f_nombre(comp.sperson, 1, vcagente)
  SELECT tcompani
  INTO vtcompani
  FROM companias comp
  WHERE comp.ccompani = pccompani;
  EXCEPTION
  WHEN OTHERS THEN
  vtcompani := '';
  END;*/
  vpasexec := 4;
  -- Bug 15260 - 02/07/2010 - AMC
  IF vtramidetalle IS NULL THEN
    vtramidetalle  := ob_iax_sin_trami_detalle();
  END IF;
  -- Fi Bug 15260 - 02/07/2010 - AMC
  vpasexec                 := 5;
  vtramidetalle.nsinies    := pnsinies;
  vtramidetalle.ntramit    := pntramit;
  vtramidetalle.ctramit    := pctramit;
  vtramidetalle.ttramit    := vttramit;
  vtramidetalle.ctiptra    := pctiptra;
  vtramidetalle.ttiptra    := ff_desvalorfijo(800, pac_md_common.f_get_cxtidioma, pctiptra);
  vtramidetalle.desctramit := pdesctramit;
  /*IF psperson IS NOT NULL THEN
  vnumerr := pac_md_persona.f_get_persona_agente(psperson, vcagente, 'POL',
  vtramidetalle.persona, mensajes);
  END IF;*/
  vpasexec    := 6;
  IF psperson IS NOT NULL THEN
    --vnumerr := pac_seguros.f_get_cagente(psseguro, 'POL', vcagente);
    /*vcagente := pac_md_common.f_get_cxtagente;   --XPL#017558
    pac_persona.p_busca_agentes(psperson, vcagente, vcagente_visio, vcagente_per, 'POL');
    vcagente := vcagente_per;*/
    vcagente    := pac_persona.f_get_agente_detallepersona(psperson, pac_md_common.f_get_cxtagente, pac_md_common.f_get_cxtempresa);
    IF vcagente IS NULL THEN
      vcagente  := pac_md_common.f_get_cxtagente;
    END IF;
    vtramidetalle.persona := pac_md_persona.f_get_persona(psperson, vcagente, mensajes, 'POL');
    -- Bug 12668 - 02/03/2010 - AMC
  ELSE
    vpasexec := 61;
    -- Bug 15260 - 02/07/2010 - AMC
    IF vtramidetalle.persona IS NULL THEN
      vtramidetalle.persona  := ob_iax_personas();
    END IF;
    -- Fi Bug 15260 - 02/07/2010 - AMC
    vtramidetalle.persona.sperson := NULL;
  END IF;
  vpasexec                     := 7;
  vtramidetalle.cestper        := pcestper;
  vtramidetalle.testper        := ff_desvalorfijo(811, pac_md_common.f_get_cxtidioma, pcestper);
  vtramidetalle.tdescdireccion := ptdescdireccion;
  vtramidetalle.direccion      := ob_iax_direcciones();
  --  vtramidetalle.direccion.tlocali := ptdescdireccion;
  vtramidetalle.direccion.cdomici := pcdomici;
  vtramidetalle.direccion.cpostal := pcpostal;
  vtramidetalle.direccion.cprovin := pcprovin;
  vtramidetalle.direccion.tprovin := f_desprovin2(pcprovin, pcpais);
  vtramidetalle.direccion.cpoblac := pcpoblac;
  vtramidetalle.direccion.tpoblac := f_despoblac2(pcpoblac, pcprovin);
  vtramidetalle.direccion.cpais   := pcpais;
  vtramidetalle.direccion.tpais   := ff_despais(pcpais, pac_md_common.f_get_cxtidioma);
  vtramidetalle.direccion.ctipdir := pctipdir;
  vtramidetalle.direccion.ttipdir := ff_desvalorfijo(191, pac_md_common.f_get_cxtidioma(), pctipdir);
  vtramidetalle.direccion.tnomvia := ptnomvia;
  vtramidetalle.direccion.tcomple := ptcomple;
  vtramidetalle.direccion.nnumvia := pnnumvia;
  --Bug 12668 - 16/02/2010 - AMC
  vtramidetalle.direccion.csiglas := pcsiglas;
  vtramidetalle.direccion.cciudad := pcciudad;
  vtramidetalle.direccion.fgisx   := pfgisx;
  vtramidetalle.direccion.fgisy   := pfgisy;
  vtramidetalle.direccion.fgisz   := pfgisz;
  vtramidetalle.direccion.cvalida := pcvalida;
  -- Fi Bug 12668 - 16/02/2010 - AMC
  vtramidetalle.ctipcon  := pctipcon;
  vtramidetalle.ttipcon  := ff_desvalorfijo(806, pac_md_common.f_get_cxtidioma, pctipcon);
  vtramidetalle.ctipcar  := pctipcar;
  vtramidetalle.ttipcar  := '';
  vtramidetalle.fcarnet  := pfcarnet;
  vtramidetalle.calcohol := pcalcohol;
  vtramidetalle.ctipmat  := pctipmat;
  vtramidetalle.ttipmat  := ff_desvalorfijo(290, pac_md_common.f_get_cxtidioma, pctipmat);
  vtramidetalle.cmatric  := pcmatric;
  vpasexec               := 8;
  BEGIN
    SELECT tmarca INTO vtmarca FROM aut_marcas WHERE cmarca = pcmarca;
    SELECT tmodelo
    INTO vtmodelo
    FROM aut_modelos
    WHERE cmodelo = pcmodelo
    AND cmarca    = pcmarca;
    SELECT tversion INTO vtversion FROM aut_versiones WHERE cversion = pcversion;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  vpasexec               := 9;
  vtramidetalle.cmarca   := pcmarca;
  vtramidetalle.cmodelo  := pcmodelo;
  vtramidetalle.cversion := pcversion;
  vtramidetalle.nanyo    := pnanyo; -- BUG 25762-NSS-24/01/2013
  -- BUG 0023540 - 24/10/2012 - JMF: Afegir IRECLAM, IINDEMN
  vtramidetalle.cchasis     := pcchasis;
  vtramidetalle.codmotor    := pcodmotor;
  vtramidetalle.nbastid     := pnbastid;
  vtramidetalle.ccilindraje := pccilindraje;
  vpasexec                  := 10;
  vtramidetalle.ireclam     := pireclam;
  vtramidetalle.iindemn     := piindemn;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sintramidetalle;
 /*************************************************************************
      FUNCTION f_set_amparos
           recorre y se guarda el objeto

      param in pnsinies : Numero Siniestro		     
       param in pntramit : Numero Tramitacion Siniestro		     
       param in pcgarant : Codigo Garantia		     
       param in pnpreten : vAlor de la pretension		     
       param in picaprie : Importe Capital Riesgo		     
       param in pcmonpreten : Codigo de moneda		     
          return             : 0 -> Tot correcte
                              1 -> Se ha producido un error
   -- BUG 004131 - 2019-05-27 - EA 
   *************************************************************************/ 
FUNCTION f_set_amparos(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       pnpreten IN NUMBER,		     
       picaprie IN NUMBER,		     
       pcmonpreten IN VARCHAR2,		     

      pamparos    IN OUT t_iax_sin_trami_amparo,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS 
        vobjectname    VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_amparo';
        vparam      VARCHAR2(500) := 'nsinies: ' || pnsinies || ' - ntramit: ' || pntramit || ' - cgarant: ' || pcgarant || ' - npreten: ' || pnpreten || ' - icaprie: ' || picaprie || ' - cmonpreten: ' || pcmonpreten;
		  vpasexec       NUMBER(5) := 1;
        vnumerr        NUMBER(8) := 1;

      BEGIN 
		IF pnsinies IS NULL OR
        pntramit IS NULL OR
         pcgarant IS NULL
      THEN
        RAISE e_param_error;
      END IF;

    IF pamparos IS NOT NULL AND pamparos.COUNT > 0 THEN
    FOR i IN pamparos.FIRST .. pamparos.LAST
    LOOP
      IF pamparos.EXISTS(i) THEN
        vnumerr    := f_set_amparo(pnsinies, pntramit, pcgarant, pnpreten, picaprie, pcmonpreten, pamparos(i), mensajes);
        IF vnumerr <> 0 THEN
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
   RETURN vnumerr;
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
         RETURN NVL(vnumerr, 0);
  END f_set_amparos; 

 /*************************************************************************
      FUNCTION f_set_objeto_sintramiamparo
           graba en una variable global de la capa IAX los valores del objeto

      param in pnsinies : Numero Siniestro		     
       param in pntramit : Numero Tramitacion Siniestro		     
       param in pcgarant : Codigo Garantia		     
       param in pnpreten : vAlor de la pretension		     
       param in picaprie : Importe Capital Riesgo		     
       param in pcmonpreten : Codigo de moneda		     
          return             : 0 -> Tot correcte
                              1 -> Se ha producido un error
   -- BUG 004131 - 2019-05-27 - EA 
   *************************************************************************/ 
FUNCTION f_set_objeto_sintramiamparo(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       pnpreten IN NUMBER,		     
       picaprie IN NUMBER,		     
       pcmonpreten IN VARCHAR2,		     

      vtramiamparo    IN OUT ob_iax_sin_trami_amparo,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS 
        vobjectname    VARCHAR2(500) := 'PAC_IAX_SINIESTROS.f_set_amparo';
        vparam      VARCHAR2(500) := 'nsinies: ' || pnsinies || ' - ntramit: ' || pntramit || ' - cgarant: ' || pcgarant || ' - npreten: ' || pnpreten || ' - icaprie: ' || picaprie || ' - cmonpreten: ' || pcmonpreten;
		  vpasexec       NUMBER(5) := 1;
        vnumerr        NUMBER(8) := 0;

      BEGIN 
		IF pnsinies IS NULL OR
        pntramit IS NULL OR
         pcgarant IS NULL
      THEN
        RAISE e_param_error;
      END IF;

        vtramiamparo.nsinies := pnsinies;
        vtramiamparo.ntramit := pntramit;
        vtramiamparo.cgarant := pcgarant;
        vtramiamparo.itotret := pnpreten;
        vtramiamparo.icaprie := picaprie;
        IF pcmonpreten                IS NOT NULL THEN
    vtramiamparo.tmonres    := pac_eco_monedas.f_descripcion_moneda(vtramiamparo.cmonres, pac_md_common.f_get_cxtidioma, vnumerr);
    vtramiamparo.cmonres    := pcmonpreten;
    vtramiamparo.cmonresint := pcmonpreten;
  ELSE
    -- BUG 18423 - 24/01/2012 - JMP - Multimoneda - Resolver nota 104967
    vtramiamparo.cmonres    := pac_monedas.f_cmoneda_t(pac_oper_monedas.f_monres(pnsinies));
    IF vtramiamparo.cmonres IS NULL THEN
      --  FIN BUG 18423 - 24/01/2012 - JMP - Multimoneda - Resolver nota 104967
      vtramiamparo.cmonres := pac_monedas.f_cmoneda_t(pac_parametros.f_parinstalacion_n('MONEDAINST'));
    END IF;
    IF vtramiamparo.cmonres   IS NOT NULL THEN
      vtramiamparo.tmonres    := pac_eco_monedas.f_descripcion_moneda(vtramiamparo.cmonres, pac_md_common.f_get_cxtidioma, vnumerr);
      vtramiamparo.cmonresint := vtramiamparo.cmonres;
    END IF;
  END IF;

   RETURN NVL(vnumerr, 0);
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
         RETURN NVL(vnumerr, 0);
  END f_set_objeto_sintramiamparo; 

 /*************************************************************************
      FUNCTION f_set_amparo
           la tabla sin_tramita_amparo .

      param in pnsinies : Numero Siniestro		     
       param in pntramit : Numero Tramitacion Siniestro		     
       param in pcgarant : Codigo Garantia		     
       param in pnpreten : vAlor de la pretension		     
       param in picaprie : Importe Capital Riesgo		     
       param in pcmonpreten : Codigo de moneda		     
          return             : 0 -> Tot correcte
                              1 -> Se ha producido un error
   -- BUG 004131 - 2019-05-27 - EA 
   *************************************************************************/ 
FUNCTION f_set_amparo(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       pnpreten IN NUMBER,		     
       picaprie IN NUMBER,		     
       pcmonpreten IN VARCHAR2,		     
       pamparo IN ob_iax_sin_trami_amparo,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS 
        vobjectname    VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_amparo';
        vparam      VARCHAR2(500) := 'nsinies: ' || pnsinies || ' - ntramit: ' || pntramit || ' - cgarant: ' || pcgarant || ' - npreten: ' || pnpreten || ' - icaprie: ' || picaprie || ' - cmonpreten: ' || pcmonpreten;
		  vpasexec       NUMBER(5) := 1;
        vnumerr        NUMBER(8) := 1;

      BEGIN 
		IF pnsinies IS NULL OR
        pntramit IS NULL OR
         pcgarant IS NULL
      THEN
        RAISE e_param_error;
      END IF;

        vpasexec := 2;

        vnumerr := pac_siniestros.f_ins_amparo( pnsinies, pntramit, pcgarant, pnpreten, picaprie, pcmonpreten);
        vpasexec := 3;
        IF vnumerr = 0 THEN
              vpasexec := 4;
          COMMIT;
        END IF;

   RETURN vnumerr;
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
  END f_set_amparo; 

/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.reserva
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
ctipres        NUMBER(2),   --Código Tipo Reserva
ttipres        VARCHAR2(100),--Des tipo reserva
nmovres        NUMBER(4),   --Número Movimiento Reserva
cgarant        NUMBER(4),   --Código Garantía
tgarant        VARCHAR2(100),--Des garantia
ccalres        NUMBER(1),   --Código Cálculo Reserva (Manual/Automático)
tcalres        Varchar2(100),--des calculo reserva
fmovres        DATE,   --Fecha Movimiento Reserva
cmonres        VARCHAR2(3),   --Código Moneda Reserva
tmonres        VARCHAR2(100),--des moneda reserva
ireserva       NUMBER,   --Importe Reserva
ipago          NUMBER,   --Importe Pago
iingreso       NUMBER,   --Importe Ingreso
irecobro       NUMBER,   --Importe Recobro
icaprie        NUMBER,   --Importe capital risc
ipenali        NUMBER,   --Importe penalització
fresini        DATE,   --Fecha Inicio Reserva
fresfin        DATE,   --Fecha Fin Reserva
sidepag        NUMBER(8),   --Secuencia Identificador Pago
sproces        NUMBER(10),   --Secuencia Proceso
fcontab        DATE,   --Fecha Contabilidad
cusualt        VARCHAR2(20),   --Código Usuario Alta
falta          DATE,   --Fecha Alta
cusumod        VARCHAR2(20),   --Código Usuario Modificación
fmodifi        DATE,   --Fecha Modificación
iprerec        NUMBER  -- Importe previsión de recobro
-- Bug 11945 - 16/12/2009 - AMC - Se añade el parametro IPREREC
*************************************************************************/
FUNCTION f_set_objeto_sintramireserva(
    pnsinies         IN VARCHAR2,
    pntramit         IN NUMBER,
    pctipres         IN NUMBER,
    pttipres         IN VARCHAR2,
    pnmovres         IN NUMBER,
    pcgarant         IN NUMBER,
    pccalres         IN NUMBER,
    pfmovres         IN DATE,
    pcmonres         IN VARCHAR2,
    pireserva        IN NUMBER,
    pipago           IN NUMBER,
    piingreso        IN NUMBER,
    pirecobro        IN NUMBER,
    picaprie         IN NUMBER,
    pipenali         IN NUMBER,
    pfresini         IN DATE,
    pfresfin         IN DATE,
    pfultpag         IN DATE,
    psidepag         IN NUMBER,
    psproces         IN NUMBER,
    pfcontab         IN DATE,
    piprerec         IN NUMBER,
    pctipgas         IN NUMBER,
    vtramireserva    IN OUT ob_iax_sin_trami_reserva,
    pifranq          IN NUMBER,              --Bug 27059:NSS:03/06/2013
    pndias           IN NUMBER,              -- Bug 27487/159742:NSS:26/11/2013
    pcmovres         IN NUMBER,              --0031294/0174788: NSS:26/05/2014
    pitotimp         IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:28/11/2013
    mensajes         IN OUT t_iax_mensajes,  -- 24637/0147756:NSS:05/03/2014
    pitotret         IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
    piva_ctipind     IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
    pretenc_ctipind  IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
    preteiva_ctipind IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
    preteica_ctipind IN NUMBER DEFAULT NULL,  -- 24637/0147756:NSS:20/03/2014
    pcsolidaridad IN NUMBER DEFAULT NULL -- CONF-431 IGIL
  )
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.F_Set_objeto_sintramireserva';
  vparam      VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pntramit: ' || pntramit || ' - pnmovres: ' || pnmovres || ' - pcsolidaridad: ' || pcsolidaridad;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vtgarant    VARCHAR2(1000) := '';
  vttipgas    VARCHAR2(100)  := '';
  v_sseguro sin_siniestro.sseguro%TYPE;
  v_nriesgo sin_siniestro.nriesgo%TYPE;
  v_nmovimi sin_siniestro.nmovimi%TYPE;
  vcmonresint VARCHAR2(200);
  v_ctipcoa NUMBER;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 5;
  BEGIN
    SELECT trotgar
    INTO vtgarant
    FROM garangen
    WHERE cgarant = pcgarant
    AND cidioma   = pac_md_common.f_get_cxtidioma;
  EXCEPTION
  WHEN OTHERS THEN
    vtgarant := '';
  END;
  BEGIN
    SELECT tatribu
    INTO vttipgas
    FROM detvalores
    WHERE catribu = pctipgas
    AND cidioma   = pac_md_common.f_get_cxtidioma
    AND cvalor    = 1047;
  EXCEPTION
  WHEN OTHERS THEN
    vttipgas := '';
  END;
  vtramireserva.nsinies      := pnsinies;
  vtramireserva.ntramit      := pntramit;
  vtramireserva.ctipres      := pctipres;
  vtramireserva.ttipres      := ff_desvalorfijo(322, pac_md_common.f_get_cxtidioma, pctipres);
  vtramireserva.nmovres      := pnmovres;
  vtramireserva.cgarant      := pcgarant;
  vtramireserva.tgarant      := vtgarant;
  vtramireserva.nmovres      := pnmovres;
  vtramireserva.ccalres      := pccalres;
  vtramireserva.tcalres      := ff_desvalorfijo(693, pac_md_common.f_get_cxtidioma, pccalres);
  vtramireserva.fmovres      := pfmovres;
  vtramireserva.csolidaridad := NVL(pcsolidaridad, 0); -- CONF-431 IGIL
  IF pcmonres                IS NOT NULL THEN
    vtramireserva.tmonres    := pac_eco_monedas.f_descripcion_moneda(vtramireserva.cmonres, pac_md_common.f_get_cxtidioma, vnumerr);
    vtramireserva.cmonres    := pcmonres;
    vtramireserva.cmonresint := pcmonres;
  ELSE
    -- BUG 18423 - 24/01/2012 - JMP - Multimoneda - Resolver nota 104967
    vtramireserva.cmonres    := pac_monedas.f_cmoneda_t(pac_oper_monedas.f_monres(pnsinies));
    IF vtramireserva.cmonres IS NULL THEN
      --  FIN BUG 18423 - 24/01/2012 - JMP - Multimoneda - Resolver nota 104967
      vtramireserva.cmonres := pac_monedas.f_cmoneda_t(pac_parametros.f_parinstalacion_n('MONEDAINST'));
    END IF;
    IF vtramireserva.cmonres   IS NOT NULL THEN
      vtramireserva.tmonres    := pac_eco_monedas.f_descripcion_moneda(vtramireserva.cmonres, pac_md_common.f_get_cxtidioma, vnumerr);
      vtramireserva.cmonresint := vtramireserva.cmonres;
    END IF;
  END IF;
  vtramireserva.ireserva   := pireserva;
  vtramireserva.ipago      := pipago;
  vtramireserva.iingreso   := piingreso;
  vtramireserva.irecobro   := pirecobro;
  vtramireserva.icaprie    := picaprie;
  vtramireserva.ipenali    := pipenali;
  vtramireserva.fresini    := pfresini;
  vtramireserva.fresfin    := pfresfin;
  vtramireserva.fultpag    := pfultpag;
  vtramireserva.sidepag    := psidepag;
  vtramireserva.sproces    := psproces;
  vtramireserva.fcontab    := pfcontab;
  vtramireserva.ivalactual := (NVL(pireserva, 0) + NVL(pipago, 0)) -
  (NVL(piingreso, 0)                             + NVL(pirecobro, 0));
  -- Bug 11945 - 16/12/2009  - AMC
  vtramireserva.iprerec := piprerec;
  --Fi Bug 11945 - 16/12/2009  - AMC
  vtramireserva.ctipgas := pctipgas;
  vtramireserva.ttipgas := vttipgas;
  --RETURN vnumerr;
  vtramireserva.ifranq          := pifranq;          --Bug 27059:NSS:03/06/2013
  vtramireserva.ndias           := pndias;           --Bug 27487/159742:NSS:26/11/2013
  vtramireserva.itotimp         := pitotimp;         -- 24637/0147756:NSS:28/11/2013
  vtramireserva.itotret         := pitotret;         -- 24637/0147756:NSS:20/03/2014
  vtramireserva.iva_ctipind     := piva_ctipind;     -- 24637/0147756:NSS:20/03/2014
  vtramireserva.retenc_ctipind  := pretenc_ctipind;  -- 24637/0147756:NSS:20/03/2014
  vtramireserva.reteiva_ctipind := preteiva_ctipind; -- 24637/0147756:NSS:20/03/2014
  vtramireserva.reteica_ctipind := preteica_ctipind; -- 24637/0147756:NSS:20/03/2014
  vtramireserva.cmovres         := pcmovres;         -- 0031294/0174788: NSS:26/05/2014

  RETURN NVL(vnumerr, 0);                            -- ASN:22/03/2012 Para evitar que devuelva NULL
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sintramireserva;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.danyos
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
ndano          NUMBER(3),   --Número Daño Siniestro
tdano          VARCHAR2(5000),   --Descripción Daño
*************************************************************************/
FUNCTION f_set_objeto_sintramidanyo(
    pnsinies    IN VARCHAR2,
    pntramit    IN NUMBER,
    pndano      IN NUMBER,
    pctipinf    IN NUMBER,
    ptdano      IN VARCHAR2,
    vtramidanyo IN OUT ob_iax_sin_trami_dano,
    mensajes    IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.F_Set_objeto_sintramidanyo';
  vparam      VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - ptdano: ' || ptdano || ' - pndano: ' || pndano;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vtgarant    VARCHAR2(1000) := '';
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec            := 5;
  vtramidanyo.nsinies := pnsinies;
  vtramidanyo.ntramit := pntramit;
  vtramidanyo.ndano   := pndano;
  vtramidanyo.tdano   := ptdano;
  vtramidanyo.ctipinf := pctipinf;
  vtramidanyo.ttipinf := ff_desvalorfijo(802, pac_md_common.f_get_cxtidioma, pctipinf);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sintramidanyo;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.detdanyos
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
ndano          NUMBER(3),   --Número Daño Siniestro
tdano          VARCHAR2(5000),   --Descripción Daño
*************************************************************************/
FUNCTION f_set_objeto_sintramidetdanyo(
    pnsinies       IN VARCHAR2,
    pntramit       IN NUMBER,
    pndano         IN NUMBER,
    pndetdano      IN NUMBER,
    vtramidetdanyo IN OUT ob_iax_sin_trami_detdano,
    mensajes       IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.F_Set_objeto_sintramidetdanyo';
  vparam      VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pndetdano: ' || pndetdano || ' - pndano: ' || pndano;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vtgarant    VARCHAR2(1000) := '';
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec                := 5;
  vtramidetdanyo.nsinies  := pnsinies;
  vtramidetdanyo.ntramit  := pntramit;
  vtramidetdanyo.ndano    := pndano;
  vtramidetdanyo.ndetdano := pndetdano;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sintramidetdanyo;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.destinatario
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
--   sperson        NUMBER(6),   --NUm. identificativo destinatario
--   nnumide        VARCHAR2(14),   --Número documento
--   tdestinatario  VARCHAR2(200),   --Nombre Destinatario
ctipdes        NUMBER(2),   --Código Tipo Destinatario
ttipdes        VARCHAR2(100),   --des tipo destinatario
cpagdes        NUMBER(1),   --Indicador aceptación pagos
cactpro        NUMBER(4),   --Código Actividad Profesional
tactpro        VARCHAR2(100),   --Des Actividad Profesional
pasigna        NUMBER(5,2), --asignación
cpaisre        NUMBER(3),  --código país residencia
tpaisre        VARCHAR2(100), --descripción país
cusualt        VARCHAR2(20),   --Código Usuario Alta
falta          DATE,   --Fecha Alta
cusumod        VARCHAR2(20),   --Código Usuario Modificación
fmodifi        DATE,   --Fecha Modificación
persona        ob_iax_personas,--persona destinataria
*************************************************************************/
FUNCTION f_set_obj_sintramidestinatari(
    psseguro IN NUMBER,
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctipdes IN NUMBER,
    pcpagdes IN NUMBER,
    pcactpro IN NUMBER,
    ppasigna IN NUMBER,
    pcpaisre IN NUMBER,
    psperson IN NUMBER,
    pctipban IN NUMBER,
    pcbancar IN VARCHAR2,
    -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
    pctipcap IN NUMBER,
    pcrelase IN NUMBER,
    -- Fi Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
    psprofes           IN NUMBER, --bug 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros - NSS - 26/02/2014
    vtramidestinatario IN OUT ob_iax_sin_trami_destinatario,
    pcprovin           IN NUMBER, -- SHA -- Bug 38224/216445 --11/11/2015
    mensajes           IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname    VARCHAR2(500)  := 'PAC_MD_SINIESTROS.F_Set_objeto_sintramidestinatari';
  vparam         VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pctipdes: ' || pctipdes || ' - pcpagdes: ' || pcpagdes || ' - pcprovin: ' || pcprovin;
  vpasexec       NUMBER(5)      := 1;
  vnumerr        NUMBER(8)      := 0;
  vtactpro       VARCHAR2(1000) := '';
  vcagente       NUMBER;
  vcagente_visio NUMBER;
  vcagente_per   NUMBER;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  BEGIN
    SELECT tactpro
    INTO vtactpro
    FROM activiprof
    WHERE cactpro = pcactpro
    AND cidioma   = pac_md_common.f_get_cxtidioma;
  EXCEPTION
  WHEN OTHERS THEN
    vtactpro := '';
  END;
  vpasexec                   := 5;
  vtramidestinatario.nsinies := pnsinies;
  vtramidestinatario.ntramit := pntramit;
  vtramidestinatario.ctipdes := pctipdes;
  vtramidestinatario.ttipdes := ff_desvalorfijo(10, pac_md_common.f_get_cxtidioma, pctipdes);
  vtramidestinatario.cpagdes := pcpagdes;
  vtramidestinatario.cactpro := pcactpro;
  vtramidestinatario.tactpro := vtactpro;
  vtramidestinatario.pasigna := ppasigna;
  vtramidestinatario.cpaisre := pcpaisre;
  vtramidestinatario.cprovin := pcprovin;
  vtramidestinatario.tprovin := f_desprovin2(pcprovin, pcpaisre);
  vtramidestinatario.ctipban := pctipban;
  vtramidestinatario.cbancar := pcbancar;
  vtramidestinatario.tpaisre := ff_despais(pcpaisre, pac_md_common.f_get_cxtidioma);
  IF psperson                IS NOT NULL THEN
    vcagente                 := pac_persona.f_get_agente_detallepersona(psperson, pac_md_common.f_get_cxtagente, pac_md_common.f_get_cxtempresa);
    IF vcagente              IS NULL THEN
      vcagente               := pac_md_common.f_get_cxtagente;
    END IF;
    vtramidestinatario.persona := pac_md_persona.f_get_persona(psperson, vcagente, mensajes, 'POL');
  END IF;
  vtramidestinatario.sprofes   := psprofes; --bug 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros - NSS - 26/02/2014
  vtramidestinatario.ctipcap   := pctipcap;
  vtramidestinatario.crelase   := pcrelase;
  IF pctipcap                  IS NOT NULL THEN
    vtramidestinatario.ttipcap := ff_desvalorfijo(205, pac_md_common.f_get_cxtidioma, pctipcap);
  ELSE
    vtramidestinatario.ttipcap := NULL;
  END IF;
  IF pcrelase                  IS NOT NULL THEN
    vtramidestinatario.trelase := ff_desvalorfijo(1018, pac_md_common.f_get_cxtidioma, pcrelase);
  ELSE
    vtramidestinatario.trelase := NULL;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_obj_sintramidestinatari;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.recobros
sidepag        NUMBER(8),   --Secuencia Identificador Pago
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
ctipdes        NUMBER(2),   --Código Tipo Destinatario
ttipdes        VARCHAR2(100),   --Desc. Tipo Destinatario
ctippag        NUMBER(1),   --Código Tipo Pago
ttippag        VARCHAR2(100),   --Desc. Tipo Pago
cconpag        NUMBER(2),   --Código Concepto Pago
tconpag        VARCHAR2(100),   --Desc. COncepto Pago
ccauind        NUMBER(3),   --Código Causa Indemnización
tcauind        VARCHAR2(100),   --Desc. Causa Indemnización
cforpag        NUMBER(2),   --Código Forma Pago
tforpag        VARCHAR2(100),   --DEsc. Forma PAgo
fordpag        DATE,   --Fecha Orden Pago
ctipban        NUMBER(1),   --Código Tipo Cuenta Bancaria
ttipban        VARCHAR2(100),   --Desc. Tipo Cuenta Bancaria
cbancar        VARCHAR2(34),   --Código Cuenta Bancaria
cmonres        VARCHAR2(3),   --Código Moneda Reserva
tmonres        VARCHAR2(100),   --Desc. Moneda Reserva
isinret        NUMBER,   --Importe Sin Retención
iconret        NUMBER,   --Importe Con Retención
iretenc        NUMBER,   --Importe Retención
pretenc        NUMBER(6, 3),   --Porcentaje Retención
iiva           NUMBER,   --Importe IVA
isuplid        NUMBER,   --Importe Suplido
ifranq         NUMBER,   --Importe Franquicia Pagada
iresred        NUMBER,   --Importe Rendimiento Reducido (Vida)
iresrcm        NUMBER,   --Importe Rendimiento (Vida)
cmonpag        VARCHAR2(3),   --Código Moneda Pago
tmonpag        VARCHAR2(100),   --Desc Moneda Pago
isinretpag     NUMBER,   --Importe Sin Retención Moneda Pago
iconretpag     NUMBER,   --Importe Con Retención Moneda Pago
iretencpag     NUMBER,   --Importe Retención Moneda Pago
iivapag        NUMBER,   --Importe IVA Moneda Pago
isuplidpag     NUMBER,   --Importe Suplido Moneda Pago
ifranqpag      NUMBER,   --Importe Franquicia Moneda Pago
fcambio        DATE,   --Fecha de cambio
nfacref        VARCHAR2(100),   --Número Factura/Referencia
ffacref        DATE,   --Fecha Factura/Referencia
cusualt        VARCHAR2(20),   --Código Usuario Alta
falta          DATE,   --Fecha Alta
cusumod        VARCHAR2(20),   --Código Usuario Modificación
fmodifi        DATE,   --Fecha Modificación
sidepagtemp    NUMBER  --Indica si el sidepag es el temporal o el definitivo
destinatari    ob_iax_personas,   --destinatari
movpagos       t_iax_sin_trami_movpago,   --Coleccion movimientos de pagos
pagogar        t_iax_sin_trami_pago_gar,   --coleccion pago garantias
pcagente        NUMBER  Código del agente/mediador
pnpersrel       NUMBER  Código persona relacionada/perjudicada
Bug 11848 - 20/11/2009 - AMC - Se añade el parametro psidepagtemp
BUG 19981 - 07/11/2011 - MDS - Añadir campos ireteiva, ireteica, ireteivapag, ireteicapag, iica, iicapag en la cabecera, type ob_iax_sin_trami_pago
Bug 22256/122456 - 28/09/2012 - AMC  - Añadir campos cagente,npersrel,pcdomici y pctributacion
*************************************************************************/
FUNCTION f_set_obj_sintrami_pago_recob(
    psseguro            IN NUMBER,
    psidepag            IN NUMBER,
    pnsinies            IN VARCHAR2,
    pntramit            IN NUMBER,
    pctipdes            IN NUMBER,
    pctippag            IN NUMBER,
    pcconpag            IN NUMBER,
    pccauind            IN NUMBER,
    pcforpag            IN NUMBER,
    pfordpag            IN DATE,
    pctipban            IN NUMBER,
    pcbancar            IN VARCHAR2,
    pcmonres            IN VARCHAR2,
    pisinret            IN NUMBER,
    piconret            IN NUMBER,
    ppretenc            IN NUMBER,
    piretenc            IN NUMBER, -- ASN 24546
    piiva               IN NUMBER,
    pisuplid            IN NUMBER,
    pifranq             IN NUMBER,
    piresred            IN NUMBER,
    piresrcm            IN NUMBER,
    pcmonpag            IN VARCHAR2,
    pisinretpag         IN NUMBER,
    piconretpag         IN NUMBER,
    piretencpag         IN NUMBER,
    piivapag            IN NUMBER,
    pisuplidpag         IN NUMBER,
    pifranqpag          IN NUMBER,
    pfcambio            IN DATE,
    pnfacref            IN VARCHAR2,
    pffacref            IN DATE,
    psperson            IN NUMBER,
    psidepagtemp        IN NUMBER,
    pcultpag            IN NUMBER,
    pncheque            IN VARCHAR2,
    vtrami_pago_recobro IN OUT ob_iax_sin_trami_pago,
    mensajes            IN OUT t_iax_mensajes,
    pireteiva           IN NUMBER DEFAULT NULL,
    pireteica           IN NUMBER DEFAULT NULL,
    pireteivapag        IN NUMBER DEFAULT NULL,
    pireteicapag        IN NUMBER DEFAULT NULL,
    piica               IN NUMBER DEFAULT NULL,
    piicapag            IN NUMBER DEFAULT NULL,
    pcagente            IN NUMBER DEFAULT NULL,
    pnpersrel           IN NUMBER DEFAULT NULL,
    pcdomici            IN NUMBER DEFAULT NULL,
    pctributacion       IN NUMBER DEFAULT NULL,
    pcbanco             IN NUMBER DEFAULT NULL, --24708:NSS:10/10/2013
    pcofici             IN NUMBER DEFAULT NULL, --24708:NSS:10/10/2013
    pcciudad            IN NUMBER DEFAULT NULL, --29224:NSS:24/02/2014
    pspersonpres        IN NUMBER DEFAULT NULL,
    ptobserva           IN VARCHAR2 DEFAULT NULL,
    piotrosgas          IN NUMBER DEFAULT NULL,
    pibaseipoc          IN NUMBER DEFAULT NULL,
    piipoconsumo        IN NUMBER DEFAULT NULL,
    piotrosgaspag       IN NUMBER DEFAULT NULL,
    pibaseipocpag       IN NUMBER DEFAULT NULL,
    piipoconsumopag     IN NUMBER DEFAULT NULL)
  RETURN NUMBER
IS
  vobjectname    VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_set_obj_sintrami_pago_recob';
  vparam         VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pctipdes: ' || pctipdes || ' - pctippag: ' || pctippag;
  vpasexec       NUMBER(5)      := 1;
  vnumerr        NUMBER(8)      := 0;
  vtactpro       VARCHAR2(1000) := '';
  vcagente       NUMBER;
  vcagente_visio NUMBER;
  vcagente_per   NUMBER;
  vdciudad       VARCHAR2(1000) := '';
BEGIN
  IF pcciudad IS NOT NULL THEN
    BEGIN
      SELECT tprovin INTO vdciudad FROM provincias WHERE cprovin = pcciudad;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
  END IF;
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL OR psidepag IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec                    := 5;
  vtrami_pago_recobro.nsinies := pnsinies;
  vtrami_pago_recobro.ntramit := pntramit;
  vtrami_pago_recobro.ctipdes := pctipdes;
  vtrami_pago_recobro.sidepag := psidepag;
  -- Bug 11848 - 20/11/2009 - AMC
  vtrami_pago_recobro.sidepagtemp := psidepagtemp;
  --Fi Bug 11848 - 20/11/2009 - AMC
  vtrami_pago_recobro.destinatari.ctipdes := pctipdes;
  vtrami_pago_recobro.destinatari.ttipdes := ff_desvalorfijo(10, pac_md_common.f_get_cxtidioma, pctipdes);
  vtrami_pago_recobro.ctippag             := pctippag;
  vtrami_pago_recobro.ttippag             := ff_desvalorfijo(2, pac_md_common.f_get_cxtidioma, pctippag);
  vtrami_pago_recobro.cconpag             := pcconpag;
  vtrami_pago_recobro.tconpag             := ff_desvalorfijo(803, pac_md_common.f_get_cxtidioma, pcconpag);
  vtrami_pago_recobro.ccauind             := pccauind;
  vtrami_pago_recobro.tcauind             := ff_desvalorfijo(325, pac_md_common.f_get_cxtidioma, pccauind);
  vtrami_pago_recobro.cforpag             := pcforpag;
  vtrami_pago_recobro.tforpag             := ff_desvalorfijo(813, pac_md_common.f_get_cxtidioma, pcforpag);
  vtrami_pago_recobro.fordpag             := pfordpag;
  vtrami_pago_recobro.ctipban             := pctipban;
  vtrami_pago_recobro.ttipban             := ff_desvalorfijo(274, pac_md_common.f_get_cxtidioma, pctipban);
  vtrami_pago_recobro.cbancar             := pcbancar;
  vtrami_pago_recobro.cmonres             := pcmonres;
  vtrami_pago_recobro.tmonres             := '';
  vtrami_pago_recobro.isinret             := pisinret;
  --   vtrami_pago_recobro.iretenc := ppretenc; -- ASN 24546
  vtrami_pago_recobro.iretenc    := piretenc; -- ASN 24546
  vtrami_pago_recobro.iiva       := piiva;
  vtrami_pago_recobro.isuplid    := pisuplid;
  vtrami_pago_recobro.ifranq     := pifranq;
  vtrami_pago_recobro.iresred    := piresred;
  vtrami_pago_recobro.iresrcm    := piresrcm;
  vtrami_pago_recobro.cmonpag    := pcmonpag;
  vtrami_pago_recobro.tmonpag    := '';
  vtrami_pago_recobro.isinretpag := pisinretpag;
  vtrami_pago_recobro.iretencpag := piretencpag;
  vtrami_pago_recobro.iivapag    := piivapag;
  vtrami_pago_recobro.isuplidpag := pisuplidpag;
  vtrami_pago_recobro.ifranqpag  := pifranqpag;
  vtrami_pago_recobro.fcambio    := pfcambio;
  vtrami_pago_recobro.nfacref    := pnfacref;
  vtrami_pago_recobro.ffacref    := pffacref;
  vtrami_pago_recobro.cultpag    := pcultpag;
  vtrami_pago_recobro.ncheque    := pncheque;
  -- BUG 19981 - 07/11/2011 - MDS
  vtrami_pago_recobro.ireteiva    := pireteiva;
  vtrami_pago_recobro.ireteica    := pireteica;
  vtrami_pago_recobro.ireteivapag := pireteivapag;
  vtrami_pago_recobro.ireteicapag := pireteicapag;
  vtrami_pago_recobro.iica        := piica;
  vtrami_pago_recobro.iicapag     := piicapag;
  -- Bug 22256/122456 - 28/09/2012 - AMC
  vtrami_pago_recobro.cagente      := pcagente;
  vtrami_pago_recobro.npersrel     := pnpersrel;
  vtrami_pago_recobro.cdomici      := pcdomici;
  vtrami_pago_recobro.ctributacion := pctributacion;
  -- Fi Bug 22256/122456 - 28/09/2012 - AMC
  -- fin BUG 19981 - 07/11/2011 - MDS
  vtrami_pago_recobro.cbanco  := pcbanco;  --24708:NSS:10/10/2013
  vtrami_pago_recobro.cofici  := pcofici;  --24708:NSS:10/10/2013
  vtrami_pago_recobro.cciudad := pcciudad; --29224:NSS:24/02/2014
  vtrami_pago_recobro.dciudad := vdciudad; --36947/210499:JAL 04/08/2015
  IF psperson                 IS NOT NULL THEN
    vcagente                  := pac_persona.f_get_agente_detallepersona(psperson, pac_md_common.f_get_cxtagente, pac_md_common.f_get_cxtempresa);
    IF vcagente               IS NULL THEN
      vcagente                := pac_md_common.f_get_cxtagente;
    END IF;
    vtrami_pago_recobro.destinatari.persona := pac_md_persona.f_get_persona(psperson, vcagente, mensajes, 'POL');
  END IF;
  IF pspersonpres IS NOT NULL THEN
    vcagente      := pac_persona.f_get_agente_detallepersona(pspersonpres, pac_md_common.f_get_cxtagente, pac_md_common.f_get_cxtempresa);
    IF vcagente   IS NULL THEN
      vcagente    := pac_md_common.f_get_cxtagente;
    END IF;
    vtrami_pago_recobro.presentador := pac_md_persona.f_get_persona(pspersonpres, vcagente, mensajes, 'POL');
  END IF;
  --
  vtrami_pago_recobro.tobserva       := ptobserva;
  vtrami_pago_recobro.iotrosgas      := piotrosgas;
  vtrami_pago_recobro.iotrosgaspag   := piotrosgaspag;
  vtrami_pago_recobro.ibaseipoc      := pibaseipoc;
  vtrami_pago_recobro.ibaseipocpag   := pibaseipocpag;
  vtrami_pago_recobro.iipoconsumo    := piipoconsumo;
  vtrami_pago_recobro.iipoconsumopag := piipoconsumopag;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_obj_sintrami_pago_recob;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.tramitaciones.movpagos
sidepag        NUMBER(8),   --Secuencia Identificador Pago
nmovpag        NUMBER(4),   --Número Movimiento Pago
cestpag        NUMBER(1),   --Código Estado Pago
testpag        VARCHAR2(100),--Desc. Estado Pago
fefepag        DATE,   --Fecha Efecto Pago
cestval        NUMBER(1),   --Código Estado Validación Pago
testval        VARCHAR2(100),--Desc. Estado Validación Pago
fcontab        DATE,   --Fecha Contabilidad
cestpagant     NUMBER(1)   --Código Estado Pago anterior
Bug 13312 - 08/03/2010 - AMC - Se añade el parametro cestpagant
*************************************************************************/
FUNCTION f_set_obj_sintram_movpagrecob(
    psidepag    IN NUMBER,
    pnmovpag    IN NUMBER,
    pcestpag    IN NUMBER,
    pfefepag    IN DATE,
    pcestval    IN NUMBER,
    pfcontab    IN DATE,
    pcestpagant IN NUMBER,
    --Bug:19601 - 13/10/2011 - JMC
    pcsubpag    IN NUMBER,
    pcsubpagant IN NUMBER,
    --Fin Bug:19601 - 13/10/2011 - JMC
    vtrami_movpago_recobro IN OUT ob_iax_sin_trami_movpago,
    mensajes               IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_set_obj_sintrami_movpagrecob';
  vparam      VARCHAR2(500)  := 'parámetros - psidepag: ' || psidepag || ' - pnmovpag: ' || pnmovpag || ' - pcestpag: ' || pcestpag || ' - pfefepag: ' || pfefepag;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vtactpro    VARCHAR2(1000) := '';
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psidepag IS NULL OR pnmovpag IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec                          := 5;
  vtrami_movpago_recobro.nmovpag    := pnmovpag;
  vtrami_movpago_recobro.sidepag    := psidepag;
  vtrami_movpago_recobro.cestpag    := pcestpag;
  vtrami_movpago_recobro.cestpagant := pcestpagant;
  vtrami_movpago_recobro.testpag    := ff_desvalorfijo(3, pac_md_common.f_get_cxtidioma, pcestpag);
  IF pfefepag                       IS NULL THEN
    vtrami_movpago_recobro.fefepag  := f_sysdate;
  END IF;
  vtrami_movpago_recobro.cestval := pcestval;
  vtrami_movpago_recobro.testval := ff_desvalorfijo(324, pac_md_common.f_get_cxtidioma, pcestval);
  vtrami_movpago_recobro.fcontab := pfcontab;
  --Bug:19601 - 13/10/2011 - JMC
  vtrami_movpago_recobro.csubpag    := pcsubpag;
  vtrami_movpago_recobro.tsubpag    := ff_desvalorfijo(1051, pac_md_common.f_get_cxtidioma, pcsubpag);
  vtrami_movpago_recobro.csubpagant := pcsubpagant;
  --Fin Bug:19601 - 13/10/2011 - JMC
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_obj_sintram_movpagrecob;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.tramitaciones.movpagos
sidepag        NUMBER(8),   --Secuencia Identificador Pago
nmovpag        NUMBER(4),   --Número Movimiento Pago
cestpag        NUMBER(1),   --Código Estado Pago
testpag        VARCHAR2(100),--Desc. Estado Pago
fefepag        DATE,   --Fecha Efecto Pago
cestval        NUMBER(1),   --Código Estado Validación Pago
testval        VARCHAR2(100),--Desc. Estado Validación Pago
fcontab        DATE,   --Fecha Contabilidad
BUG 19981 - 07/11/2011 - MDS - Añadir campos preteiva, preteica, ireteiva, ireteica, ireteivapag, ireteicapag, pica, iica, iicapag en la cabecera, type ob_iax_sin_trami_pago_gar
*************************************************************************/
FUNCTION f_set_obj_sintram_pagrecob_gar(
    psidepag               IN NUMBER,
    pctipres               IN NUMBER,
    pnmovres               IN NUMBER,
    pcgarant               IN NUMBER,
    pfperini               IN DATE,
    pfperfin               IN DATE,
    pcmonres               IN VARCHAR2,
    pisinret               IN NUMBER,
    piiva                  IN NUMBER,
    pisuplid               IN NUMBER,
    piretenc               IN NUMBER,
    pifranq                IN NUMBER,
    pcmonpag               IN VARCHAR2,
    pisinretpag            IN NUMBER,
    piivapag               IN NUMBER,
    pisuplidpag            IN NUMBER,
    piretencpag            IN NUMBER,
    pifranqpag             IN NUMBER,
    pfcambio               IN DATE,
    piresrcm               IN NUMBER,
    piresred               IN NUMBER,
    ppiva                  IN NUMBER,
    ppretenc               IN NUMBER,
    pcconpag               IN NUMBER,
    pnorden                IN NUMBER,
    vtrami_pagorecobro_gar IN OUT ob_iax_sin_trami_pago_gar,
    mensajes               IN OUT t_iax_mensajes,
    ppreteiva              IN NUMBER DEFAULT NULL,
    ppreteica              IN NUMBER DEFAULT NULL,
    pireteiva              IN NUMBER DEFAULT NULL,
    pireteica              IN NUMBER DEFAULT NULL,
    pireteivapag           IN NUMBER DEFAULT NULL,
    pireteicapag           IN NUMBER DEFAULT NULL,
    ppica                  IN NUMBER DEFAULT NULL,
    piica                  IN NUMBER DEFAULT NULL,
    piicapag               IN NUMBER DEFAULT NULL,
    pciva_tipind           IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:03/03/2014
    pcretenc_tipind        IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:03/03/2014
    pcreteiva_tipind       IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:03/03/2014
    pcreteica_tipind       IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:03/03/2014
    piotrosgas             IN NUMBER DEFAULT NULL,
    pibaseipoc             IN NUMBER DEFAULT NULL,
    ppipoconsumo           IN NUMBER DEFAULT NULL,
    pctipind               IN NUMBER DEFAULT NULL,
    piipoconsumo           IN NUMBER DEFAULT NULL,
    piotrosgaspag          IN NUMBER DEFAULT NULL,
    pibaseipocpag          IN NUMBER DEFAULT NULL,
    piipoconsumopag        IN NUMBER DEFAULT NULL)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_set_obj_sintram_pagrecob_gar';
  vparam      VARCHAR2(500)  := 'parámetros - psidepag: ' || psidepag || ' - pctipres: ' || pctipres || ' - pnmovres: ' || pnmovres || ' - pcgarant: ' || pcgarant || ' - pfperini: ' || pfperini || ' - pfperfin: ' || pfperfin || ' - pcmonres: ' || pcmonres || ' - pisinret: ' || pisinret || ' - piiva: ' || piiva || ' - ppretenc: ' || ppretenc || ' - pcconpag: ' || pcconpag || ' - pnorden: ' || pnorden || ' - ppreteiva: ' || ppreteiva || ' - ppreteica: ' || ppreteica || ' - pireteiva: ' || pireteiva || ' - pireteica: ' || pireteica || ' - pireteivapag: ' || pireteivapag || ' - pireteicapag: ' || pireteicapag || ' - ppica: ' || ppica || ' - piica: ' || piica || ' - piicapag: ' || piicapag;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vtgarant    VARCHAR2(1000) := '';
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psidepag IS NULL OR pnmovres IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 5;
  BEGIN
    SELECT gar.trotgar
    INTO vtgarant
    FROM garangen gar
    WHERE gar.cgarant = pcgarant
    AND cidioma       = pac_md_common.f_get_cxtidioma;
  EXCEPTION
  WHEN OTHERS THEN
    vtgarant := '';
  END;
  vpasexec                               := 6;
  vtrami_pagorecobro_gar.reserva.ctipres := pctipres;
  vtrami_pagorecobro_gar.reserva.ttipres := ff_desvalorfijo(322, pac_md_common.f_get_cxtidioma, pctipres);
  vtrami_pagorecobro_gar.sidepag         := psidepag;
  vtrami_pagorecobro_gar.reserva.nmovres := pnmovres;
  vtrami_pagorecobro_gar.reserva.cgarant := pcgarant;
  vtrami_pagorecobro_gar.reserva.tgarant := vtgarant;
  vtrami_pagorecobro_gar.fperini         := pfperini;
  vtrami_pagorecobro_gar.fperfin         := pfperfin;
  vtrami_pagorecobro_gar.cmonres         := pcmonres;
  vtrami_pagorecobro_gar.tmonres         := 'EUR';
  vtrami_pagorecobro_gar.isinret         := pisinret;
  vtrami_pagorecobro_gar.iiva            := piiva;
  vtrami_pagorecobro_gar.iresrcm         := piresrcm;
  vtrami_pagorecobro_gar.iresred         := piresred;
  vtrami_pagorecobro_gar.iiva            := piiva;
  vtrami_pagorecobro_gar.piva            := ppiva;
  vtrami_pagorecobro_gar.pretenc         := ppretenc;
  vtrami_pagorecobro_gar.isuplid         := pisuplid;
  vtrami_pagorecobro_gar.iretenc         := piretenc;
  vtrami_pagorecobro_gar.ifranq          := pifranq;
  vtrami_pagorecobro_gar.cmonpag         := pcmonpag;
  vtrami_pagorecobro_gar.tmonpag         := 'EUR';
  vtrami_pagorecobro_gar.isinretpag      := pisinretpag;
  vtrami_pagorecobro_gar.iivapag         := piivapag;
  vtrami_pagorecobro_gar.isuplidpag      := pisuplidpag;
  vtrami_pagorecobro_gar.iretencpag      := piretencpag;
  vtrami_pagorecobro_gar.ifranqpag       := pifranqpag;
  vtrami_pagorecobro_gar.importe         := NVL(pisinret, 0) -
  NVL(pisuplid, 0);
  vtrami_pagorecobro_gar.ineta   := NVL(vtrami_pagorecobro_gar.importe, 0) + piiva + piretenc;
  vtrami_pagorecobro_gar.fcambio := pfcambio;
  vtrami_pagorecobro_gar.norden  := pnorden;
  vtrami_pagorecobro_gar.cconpag := pcconpag;
  -- BUG 19981 - 07/11/2011 - MDS
  vtrami_pagorecobro_gar.preteiva    := ppreteiva;
  vtrami_pagorecobro_gar.preteica    := ppreteica;
  vtrami_pagorecobro_gar.ireteiva    := pireteiva;
  vtrami_pagorecobro_gar.ireteica    := pireteica;
  vtrami_pagorecobro_gar.ireteivapag := pireteivapag;
  vtrami_pagorecobro_gar.ireteicapag := pireteicapag;
  vtrami_pagorecobro_gar.pica        := ppica;
  vtrami_pagorecobro_gar.iica        := piica;
  vtrami_pagorecobro_gar.iicapag     := piicapag;
  -- fin BUG 19981 - 07/11/2011 - MDS
  /***+++*/
  vtrami_pagorecobro_gar.piva_ctipind       := pciva_tipind;
  vtrami_pagorecobro_gar.pretenc_ctipind    := pcretenc_tipind;
  vtrami_pagorecobro_gar.preteiva_ctipind   := pcreteiva_tipind;
  vtrami_pagorecobro_gar.preteica_ctipind   := pcreteica_tipind;
  vtrami_pagorecobro_gar.iotrosgas          := piotrosgas;
  vtrami_pagorecobro_gar.iotrosgaspag       := piotrosgaspag;
  vtrami_pagorecobro_gar.ibaseipoc          := pibaseipoc;
  vtrami_pagorecobro_gar.ibaseipocpag       := pibaseipocpag;
  vtrami_pagorecobro_gar.pipoconsumo        := ppipoconsumo;
  vtrami_pagorecobro_gar.pipoconsumo_tipind := pctipind;
  vtrami_pagorecobro_gar.iipoconsumo        := piipoconsumo;
  vtrami_pagorecobro_gar.iipoconsumopag     := piipoconsumopag;
  IF pcconpag                               IS NOT NULL THEN
    /*
    SELECT tconpag
    INTO vtrami_pagorecobro_gar.tconpag
    FROM sin_codconpag sc, sin_desconpag sd
    WHERE sc.cgarant = sd.cgarant
    AND sc.cconpag = sd.cconpag
    AND sd.cidioma = pac_md_common.f_get_cxtidioma
    AND sc.cconpag = pcconpag;
    /*****+++**/
    IF pcconpag IS NOT NULL THEN
      SELECT ff_desvalorfijo(803, pac_md_common.f_get_cxtidioma, pcconpag) tconpag
      INTO vtrami_pagorecobro_gar.tconpag
      FROM DUAL;
    END IF;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_obj_sintram_pagrecob_gar;
/*************************************************************************
función graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.tramitacion.agenda
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
nlinage        NUMBER(6),   --Número Línea
ctipreg        NUMBER(3),   --Código Tipo Registro
ttipreg        VARCHAR2(100),   --Des Tipo Registro
cmanual        NUMBER(3),   --Código Registro Manual
tmanual        VARCHAR2(100),   --Desc Registro Manual
cestage        NUMBER(3),   --Código Estado Agenda
testage        VARCHAR2(100),   --Desc Registro Manual
ffinage        DATE,   --Fecha Finalización
ttitage        VARCHAR2(100),   --Título Anotación
tlinage        VARCHAR2(2000),   --Descripción Anotación
Bug 12604 - 08/01/2010 - AMC - Se quita el parametro pfrec
*************************************************************************/
FUNCTION f_set_objeto_sintramiagenda(
    pnsinies      IN VARCHAR2,
    pntramit      IN NUMBER,
    pnlinage      IN NUMBER,
    pctipreg      IN NUMBER,
    pcmanual      IN NUMBER,
    pcestage      IN NUMBER,
    pffinage      IN DATE,
    pttitage      IN VARCHAR2,
    ptlinage      IN VARCHAR2,
    vtrami_agenda IN OUT ob_iax_sin_trami_agenda,
    mensajes      IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_set_obj_sintram_agenda';
  vparam      VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - nlinage: ' || pnlinage || ' - ctipreg: ' || pctipreg;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vtgarant    VARCHAR2(1000) := '';
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL OR pnlinage IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec              := 5;
  vtrami_agenda.nsinies := pnsinies;
  vtrami_agenda.ntramit := pntramit;
  vtrami_agenda.nlinage := pnlinage;
  vtrami_agenda.ctipreg := pctipreg;
  vtrami_agenda.cmanual := pcmanual;
  vtrami_agenda.cestage := pcestage;
  vtrami_agenda.ffinage := pffinage;
  vtrami_agenda.ttitage := pttitage;
  vtrami_agenda.tlinage := ptlinage;
  -- Bug 12604 - 11/01/2010 - AMC - Detvalores incorrectos
  vtrami_agenda.ttipreg := ff_desvalorfijo(329, pac_md_common.f_get_cxtidioma, pctipreg);
  vtrami_agenda.testage := ff_desvalorfijo(29, pac_md_common.f_get_cxtidioma, pcestage);
  vtrami_agenda.tmanual := ff_desvalorfijo(693, pac_md_common.f_get_cxtidioma, pcmanual);
  --Fi Bug 12604 - 11/01/2010 - AMC - Detvalores incorrectos
  IF vtrami_agenda.falta IS NULL THEN
    vtrami_agenda.falta  := f_sysdate;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sintramiagenda;
/*************************************************************************
FUNCTION f_ins_personarel
Inserta a la taula SIN_TRAMITA_PERSONAREL dels paràmetres informats.
param in pnsinies     : número sinistre
param in pntramit     : número tramitació sinistre
param in pnpersrel    : número linia
param in pctipide     : codi tipus registre
param in pnnumide     : codi registre manual
param in ptnombre     : codi estat agenda
param in ptapelli1    : data finalització
param in ptapelli2    : títol anotació
param in pttelefon    : descripció anotació
param in psperson     : descripció anotació
param in ptdesc       : descripció anotació
param in ptnombre2    : segundo nombre
param in ptmovil      : telf. movil
param in ptemail      : email
return                : 0 -> Tot correcte
1 -> S'ha produit un error
Bug 22325/115249 - 05/06/2012 - AMC
-- Bug 0024690 - 13/11/2012 - JMF : añadir ctiprel
*************************************************************************/
FUNCTION f_set_sintramipersonarel(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pnpersrel IN NUMBER,
    pctipide  IN NUMBER,
    pnnumide  IN VARCHAR2,
    ptnombre  IN VARCHAR2,
    ptapelli1 IN VARCHAR2,
    ptapelli2 IN VARCHAR2,
    pttelefon IN VARCHAR2,
    psperson  IN NUMBER,
    ptdesc    IN VARCHAR2,
    ptnombre2 IN VARCHAR2,
    ptmovil   IN VARCHAR2,
    ptemail   IN VARCHAR2,
    pctiprel  IN NUMBER,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_sintramipersonarel';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  vnumerr    := pac_siniestros.f_ins_personarel(pnsinies, pntramit, pnpersrel, pctipide, pnnumide, ptnombre, ptapelli1, ptapelli2, pttelefon, psperson, ptdesc, ptnombre2, ptmovil, ptemail, pctiprel);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_sintramipersonarel;
/*************************************************************************
función borra de la tabla
ob_iax_siniestros.tramitacion.personarel
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
npersrel       NUMBER(6),   --Número Persona relacionada
Bug 12604 - 08/01/2010 - LCF - Se quita el parametro pfrec
*************************************************************************/
FUNCTION f_del_sintramipersonarel(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pnpersrel IN NUMBER,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_sintramipersonarel';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  vnumerr := pac_siniestros.f_del_personarel(pnsinies, pntramit, pnpersrel);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_sintramipersonarel;
/*************************************************************************
Devuelve las pólizas que cumplan con el criterio de selección
param in pnpoliza     : número de póliza
param in pncert       : número de cerificado por defecto 0
param in pnsinies     : número del siniestro
param in cestsin      : código situación del siniestro
param in pnnumide     : número identidad persona
param in psnip        : número identificador externo
param in pbuscar      : nombre+apellidos a buscar de la persona
param in ptipopersona : tipo de persona
1 tomador
2 asegurado
param out mensajes    : mensajes de error
return                : ref cursor
*************************************************************************/
FUNCTION f_consultasini(
    pcramo    IN NUMBER,
    psproduc  IN NUMBER,
    pnpoliza  IN NUMBER,
    pncertif  IN NUMBER DEFAULT -1,
    pnsinies  IN VARCHAR2,
    pcestsin  IN NUMBER,
    pnnumide  IN VARCHAR2,
    psnip     IN VARCHAR2,
    pbuscar   IN VARCHAR2,
    ptipopers IN NUMBER,
    pnsubest  IN NUMBER,
    pnsincia  IN VARCHAR2, --BUG 14587 - PFA - 13/08/2010 - Añadir campo siniestro compañia
    pfalta    IN DATE,     --IAXIS-2169 AABC Adicion de fecha de alta
    pccompani IN NUMBER,
    -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en búsqueda siniestros
    pnpresin  IN VARCHAR2,
    pcsiglas  IN NUMBER,
    ptnomvia  IN VARCHAR2,
    pnnumvia  IN NUMBER,
    ptcomple  IN VARCHAR2,
    pcpostal  IN VARCHAR2,
    pcpoblac  IN NUMBER,
    pcprovin  IN NUMBER,
    pfgisx    IN FLOAT,
    pfgisy    IN FLOAT,
    pfgisz    IN FLOAT,
    ptdescri  IN VARCHAR2,
    pctipmat  IN NUMBER,
    pcmatric  IN VARCHAR2,
    ptiporisc IN NUMBER,
    -- Fi Bug 15006 - PFA - 16/08/2010 - nuevos campos en búsqueda siniestros
    pcpolcia   IN VARCHAR2, --Bug.: 14587 - ICV - 14/12/2010
    pcactivi   IN NUMBER,   --Bug 18749 - 28/06/2011 - AMC
    pfiltro    IN NUMBER,
    pcagente   IN NUMBER,   -- Bug 21817 - MDS - 2/05/2012
    pcmotor    IN VARCHAR2, -- Bug 25622/134589 - 06/02/2013 -AMC
    pcchasis   IN VARCHAR2, -- Bug 25622/134589 - 06/02/2013 -AMC
    pnbastid   IN VARCHAR2, -- Bug 25622/134589 - 06/02/2013 -AMC
    ptrefext   IN VARCHAR2, --Bug 32470/204062 - 08/05/2015-VCG
    pctipref   IN NUMBER,   --Bug 32470/204062 - 08/05/2015-VCG
    ptdescrie  IN VARCHAR2, -- BUG CONF_309 - 10/09/2016 - JAEG
    pncontrato IN VARCHAR2,   --AP CONF-219
    mensajes   IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.ConsultaSini';
  vparam      VARCHAR2(500) := 'parámetros - pnpoliza: ' || pnpoliza || ' - pncertif: ' || pncertif || ' - pnsinies: ' || pnsinies || ' - pcestsin: ' || pcestsin || ' - pnnumide: ' || pnnumide || ' - psnip: ' || psnip || ' - pbuscar: ' || pbuscar || ' - ptipopers: ' || ptipopers || ' - pnsubest:' || pnsubest || ' - pcramo: ' || pcramo || ' - psproduc:' || psproduc || '- pnsincia: ' || pnsincia || '- pccompani: ' || pccompani || '- pnpresin: ' || pnpresin || '- pcsiglas: ' || pcsiglas || '- ptnomvia: ' || ptnomvia || '- pnnumvia: ' || pnnumvia || '- ptcomple: ' || ptcomple || '- pcpostal: ' || pcpostal || '- pcpoblac: ' || pcpoblac || '- pcprovin: ' || pcprovin || '- pfgisx: ' || pfgisx || '- pfgisy: ' || pfgisy || '- pfgisz: ' || pfgisz || '- ptdescri: ' || ptdescri || '- pctipmat: ' || pctipmat || '- pcmatric: ' || pcmatric || '- ptiporisc: ' || ptiporisc || '- pcpolcia : ' || pcpolcia || '- pcactivi : ' || pcactivi || '- ptdescrie: ' || ptdescrie || -- BUG CONF_309 - 10/09/2016 -
  -- JAEG
  ' pcagente=' || pcagente;
  vpasexec NUMBER(5) := 1;
  vnumerr  NUMBER(8) := 0;
  vcursor sys_refcursor;
  vsquery      VARCHAR2(5000);
  vbuscar      VARCHAR2(2000);
  vsubus       VARCHAR2(500);
  vtabtp       VARCHAR2(10);
  vauxnom      VARCHAR2(200);
  vcont        NUMBER;
  nerr         NUMBER;
  v_sentence   VARCHAR2(500);
  p_filtroprod VARCHAR2(20);
  vcobjase     NUMBER;
  vqueryfiltro VARCHAR2(1100);
  vfuncion     VARCHAR2(1000); -- BUG 38344/217178 - 29/10/2015 - ACL
  vpnnumide    VARCHAR2(100);  -- BUG 38344/217178 - 09/11/2015 - ACL
  vpsnip       VARCHAR2(100);  -- BUG 38344/217178 - 09/11/2015 - ACL
BEGIN
  vpasexec     := 3;
  nerr         := 0;
  v_sentence   := '';
  p_filtroprod := 'SINIESTRO';
  --
  vsquery := 'SELECT distinct se.sseguro, se.sproduc, se.npoliza, se.ncertif, se.cpolcia, si.nsinies, si.nriesgo,
             PAC_MD_OBTENERDATOS.F_Desriesgos(''POL'', si.sseguro, si.nriesgo) as triesgo,
             f_desproducto_t(se.cramo,se.cmodali,se.ctipseg,se.ccolect,1,PAC_MD_COMMON.F_Get_CXTIDIOMA) as tproduc,
             se.cactivi,FF_DESACTIVIDAD(se.cactivi,se.cramo,PAC_MD_COMMON.F_Get_CXTIDIOMA) as tactivi, ff_desagente(se.cagente) tagente,
             f_nombre(t.sperson, 1, se.cagente) tomador,
             f_nombre(a.sperson, 1, se.cagente) asegurado
             FROM seguros se, sin_siniestro si,tomadores t, asegurados a, riesgos r ';
  vbuscar := ' WHERE rownum <= NVL(' || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null') || ', rownum)
              AND (se.cagente,se.cempres) in (select cagente,cempres from agentes_agente_pol) 
              AND se.sseguro = si.sseguro 
              AND a.sseguro(+) = se.sseguro
              AND r.sseguro = se.sseguro
              and se.sseguro = r.sseguro
              and r.nriesgo = si.nriesgo
              AND se.sseguro = t.sseguro(+)
              AND (t.nordtom = 1 OR (NOT EXISTS( SELECT 1
                                                 FROM   tomadores
                                                 WHERE sseguro = se.sseguro)))
              AND se.sseguro = a.sseguro(+)
              AND (a.norden = 1 OR (NOT EXISTS( SELECT 1
                                                FROM asegurados
                                                WHERE sseguro = se.sseguro))) ';
  IF pnsinies IS NOT NULL THEN
    vbuscar := vbuscar || ' and si.nsinies = ' || pnsinies;
  END IF;
  IF pnpoliza IS NOT NULL THEN
    vbuscar   := vbuscar || ' and se.npoliza = ' || pnpoliza;
  END IF;
  IF NVL(pncertif, -1) <> -1 THEN
    vbuscar            := vbuscar || ' and se.ncertif = ' || pncertif;
  END IF;
  IF pcpolcia IS NOT NULL THEN
    vbuscar   := vbuscar || ' and se.cpolcia = ' || CHR(39) || pcpolcia || CHR(39);
  END IF;
  IF pccompani IS NOT NULL THEN
    vbuscar    := vbuscar || ' and se.ccompani = ' || pccompani;
  END IF;
  IF pcagente IS NOT NULL THEN
    vbuscar   := vbuscar || ' and exists (select 1 from sin_siniestro x2 where x2.sseguro=se.sseguro and x2.cagente=' || pcagente || ')';
  END IF;
  IF NVL(psproduc, 0) <> 0 THEN
    vbuscar           := vbuscar || ' and se.sproduc =' || psproduc;
  END IF;
  IF pcramo IS NOT NULL THEN
    vbuscar := vbuscar || ' and se.sproduc in (select p.sproduc from productos p where' || ' p.cramo = ' || pcramo || ' )';
  END IF;
  IF pcactivi IS NOT NULL THEN
    vbuscar   := vbuscar || ' and se.cactivi = ' || pcactivi;
  END IF;
  IF pcestsin IS NOT NULL THEN
    vsquery     := vsquery || ', sin_movsiniestro sm ';
    vbuscar := vbuscar || ' and si.sseguro = se.sseguro and sm.nsinies = si.nsinies' || ' and se.sseguro = r.sseguro and r.nriesgo = si.nriesgo' || ' and sm.NMOVSIN = (select max(nmovsin)' || ' from sin_movsiniestro s' || ' where s.NSINIES = si.NSINIES' || ' and si.SSEGURO = se.SSEGURO )' || ' and sm.cestsin = ' || pcestsin;
  END IF;
  IF pnsincia     IS NOT NULL THEN
    vbuscar := vbuscar || ' and si.nsincia = ' || CHR(39) || pnsincia || CHR(39);
  END IF;
  IF pfalta     IS NOT NULL THEN
    vbuscar := vbuscar || ' and TRUNC(si.falta) = TO_DATE( '|| ''''|| TO_CHAR(PFALTA,'DD/MM/YYYY')||''''||',''DD/MM/YYYY'')';
  END IF;
  IF pnpresin IS NOT NULL THEN
    vbuscar   := vbuscar || ' and si.npresin = ' || pnpresin;
  END IF;
  IF pccompani IS NOT NULL THEN
    vbuscar     := vbuscar || ' and se.ccompani = ' || pccompani;
  END IF;
  IF psproduc IS NOT NULL THEN
    SELECT cobjase INTO vcobjase FROM productos WHERE sproduc = psproduc;
  END IF;
  vpasexec     := 7;
  IF ptiporisc IS NOT NULL OR vcobjase IS NOT NULL THEN
    IF (ptiporisc IN(1, 3, 4)) OR(vcobjase IN(3, 4)) THEN
      IF ptdescri IS NOT NULL THEN
        vbuscar   := vbuscar || ' AND se.sseguro IN (SELECT ri.sseguro FROM riesgos ri WHERE upper(ri.tnatrie) = upper(''%' || ptdescri || '%'')) ';
      END IF;
    ELSIF (ptiporisc    = 2) OR(vcobjase IN(2)) THEN
      vsquery          := vsquery || ', sitriesgo sit ';
      vbuscar          := vbuscar || ' and sit.sseguro = se.sseguro ';
      IF (pcpostal     IS NOT NULL OR pcpoblac IS NOT NULL OR pcsiglas IS NOT NULL OR pnnumvia IS NOT NULL OR ptnomvia IS NOT NULL OR pcprovin IS NOT NULL OR ptcomple IS NOT NULL OR pfgisx IS NOT NULL OR pfgisy IS NOT NULL OR pfgisz IS NOT NULL) THEN
        IF (pcpostal   IS NOT NULL AND pcpoblac IS NOT NULL) THEN
          vbuscar      := vbuscar || ' and upper(sit.cpostal) like upper(''%' || pcpostal || '%'') and upper(sit.cpoblac) like upper(''%' || pcpoblac || '%'') ';
        ELSIF pcpostal IS NOT NULL THEN
          vbuscar      := vbuscar || ' and upper(sit.cpostal) like upper(''%' || pcpostal || '%'') ';
        ELSIF pcpoblac IS NOT NULL THEN
          vbuscar      := vbuscar || ' and upper(sit.cpoblac) like upper(''%' || pcpoblac || '%'') ';
        END IF;
        IF pcsiglas IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.csiglas) like upper(''%' || pcsiglas || '%'') ';
        END IF;
        IF ptnomvia IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.tnomvia) like upper(''%' || ptnomvia || '%'') ';
        END IF;
        IF pnnumvia IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.nnumvia) like upper(''%' || pnnumvia || '%'') ';
        END IF;
        IF pcprovin IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.cprovin) like upper(''%' || pcprovin || '%'') ';
        END IF;
        IF ptcomple IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.tcomple) like upper(''%' || ptcomple || '%'') ';
        END IF;
        IF pfgisx IS NOT NULL THEN
          vbuscar := vbuscar || ' and upper(sit.fgisx) like upper(''%' || pfgisx || '%'') ';
        END IF;
        IF pfgisy IS NOT NULL THEN
          vbuscar := vbuscar || ' and upper(sit.fgisy) like upper(''%' || pfgisy || '%'') ';
        END IF;
        IF pfgisz IS NOT NULL THEN
          vbuscar := vbuscar || ' and upper(sit.fgisz) like upper(''%' || pfgisz || '%'') ';
        END IF;
      END IF;
    ELSIF (ptiporisc    = 5) OR(vcobjase IN(2)) THEN
      vsquery          := vsquery || ', autriesgos aut ';
      vbuscar          := vbuscar || ' and aut.sseguro = se.sseguro ';
      IF (pcmatric     IS NOT NULL OR pctipmat IS NOT NULL) THEN
        IF (pcmatric   IS NOT NULL AND pctipmat IS NOT NULL) THEN
          vbuscar      := vbuscar || ' and upper(aut.cmatric) like upper(''%' || pcmatric || '%'') and upper(aut.ctipmat) like upper(''%' || pctipmat || '%'') ';
        ELSIF pcmatric IS NOT NULL THEN
          vbuscar      := vbuscar || ' and upper(aut.cmatric) like upper(''%' || pcmatric || '%'') ';
        ELSIF pctipmat IS NOT NULL THEN
          vbuscar      := vbuscar || ' and upper(aut.ctipmat) like upper(''%' || pctipmat || '%'') ';
        END IF;
      END IF;
      IF pcmotor IS NOT NULL THEN
        vbuscar  := vbuscar || ' and upper(aut.codmotor) like upper(''%' || pcmotor || '%'') ';
      END IF;
      IF pcchasis IS NOT NULL THEN
        vbuscar   := vbuscar || ' and upper(aut.cchasis) like upper(''%' || pcchasis || '%'') ';
      END IF;
      IF pnbastid IS NOT NULL THEN
        vbuscar   := vbuscar || ' and upper(aut.nbastid) like upper(''%' || pnbastid || '%'') ';
      END IF;
    END IF;
  END IF;
  IF (pnnumide IS NOT NULL OR psnip IS NOT NULL OR pbuscar IS NOT NULL OR ptipopers = 4) THEN
    vpnnumide := pnnumide;
    vpnnumide := REPLACE(vpnnumide, CHR(39), CHR(39) || CHR(39));
    vpasexec      := 9;
    IF ptipopers   = 1 THEN
      vbuscar     := vbuscar || '  AND se.sseguro IN(SELECT a.sseguro FROM tomadores a, personas p WHERE a.sperson = p.sperson';
      IF pnnumide IS NOT NULL THEN
        IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NIF_MINUSCULAS'), 0) = 1 THEN
          vbuscar := vbuscar || ' AND UPPER(p.nnumnif) = UPPER(''' ||vpnnumide|| ''')';
        ELSE
          vbuscar := vbuscar || ' AND p.nnumnif = ''' || vpnnumide || '''';
        END IF;
      END IF;
      IF psnip IS NOT NULL THEN
        vpsnip  := psnip;
        vpsnip  := REPLACE(vpsnip, CHR(39), CHR(39) || CHR(39));
        vbuscar := vbuscar || ' AND UPPER(p.snip) = UPPER(''' || vpsnip || ''')';
      END IF;
      IF pbuscar IS NOT NULL THEN
        vfuncion := pbuscar;
        vfuncion := REPLACE(vfuncion, CHR(39), CHR(39) || CHR(39));
        vbuscar  := vbuscar || ' AND p.tbuscar LIKE UPPER(''%' || vfuncion || '%'') ';
      END IF;
      vbuscar      := vbuscar || ')';
    ELSIF ptipopers = 2 THEN
      vbuscar      := vbuscar || ' AND se.sseguro IN(SELECT a.sseguro FROM asegurados a, personas p WHERE a.sperson = p.sperson AND a.ffecfin IS NULL';
      IF pnnumide  IS NOT NULL THEN
        vpnnumide := pnnumide;
        vpnnumide := REPLACE(vpnnumide, CHR(39), CHR(39) || CHR(39));
        IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NIF_MINUSCULAS'), 0) = 1 THEN
          vbuscar := vbuscar || ' AND UPPER(p.nnumnif) = UPPER(''' || vpnnumide|| ''')';
        ELSE
          vbuscar := vbuscar || ' AND p.nnumnif = ''' || vpnnumide || '''';
        END IF;
      END IF;
      IF psnip IS NOT NULL THEN
        vpsnip  := psnip;
        vpsnip  := REPLACE(vpsnip, CHR(39), CHR(39) || CHR(39));
        vbuscar := vbuscar || ' AND UPPER(p.snip) = UPPER(''' || vpsnip || ''')';
      END IF;
      IF pbuscar IS NOT NULL THEN
        vfuncion := pbuscar;
        vfuncion := REPLACE(vfuncion, CHR(39), CHR(39) || CHR(39));
        vbuscar  := vbuscar || ' AND p.tbuscar LIKE UPPER(''%' || vfuncion || '%'') ';
      END IF;
      vbuscar     := vbuscar || ' UNION SELECT s.sseguro FROM sin_siniestro s, sin_tramita_personasrel a, personas p WHERE s.nsinies = a.nsinies AND a.sperson = p.sperson AND a.ctiprel = 4';
      IF pnnumide IS NOT NULL THEN
        vpnnumide := pnnumide;
        vpnnumide := REPLACE(vpnnumide, CHR(39), CHR(39) || CHR(39));
        IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NIF_MINUSCULAS'), 0) = 1 THEN
          vbuscar := vbuscar || ' AND UPPER(p.nnumnif) = UPPER(''' || vpnnumide|| ''')';
        ELSE
          vbuscar := vbuscar || ' AND p.nnumnif = ''' || vpnnumide || '''';
        END IF;
      END IF;
      IF psnip IS NOT NULL THEN
        vpsnip  := psnip;
        vpsnip  := REPLACE(vpsnip, CHR(39), CHR(39) || CHR(39));
        vbuscar := vbuscar || ' AND UPPER(p.snip) = UPPER(''' || vpsnip || ''')';
      END IF;
      IF pbuscar IS NOT NULL THEN
        vfuncion := pbuscar;
        vfuncion := REPLACE(vfuncion, CHR(39), CHR(39) || CHR(39));
        vbuscar  := vbuscar || ' AND p.tbuscar LIKE UPPER(''%' || vfuncion || '%'') ';
      END IF;
      vbuscar      := vbuscar || ')';
    ELSIF ptipopers = 3 THEN
      vbuscar      := vbuscar || ' AND se.sseguro IN(SELECT s.sseguro FROM sin_siniestro s, sin_tramita_personasrel a, personas p WHERE s.nsinies = a.nsinies AND a.sperson = p.sperson';
      IF pnnumide  IS NOT NULL THEN
        vpnnumide := pnnumide;
        vpnnumide := REPLACE(vpnnumide, CHR(39), CHR(39) || CHR(39));
        IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NIF_MINUSCULAS'), 0) = 1 THEN
          vbuscar := vbuscar || ' AND UPPER(p.nnumnif) = UPPER(''' || vpnnumide|| ''')';
        ELSE
          vbuscar := vbuscar || ' AND p.nnumnif = ''' || vpnnumide || '''';
        END IF;
      END IF;
      IF psnip IS NOT NULL THEN
        vpsnip  := psnip;
        vpsnip  := REPLACE(vpsnip, CHR(39), CHR(39) || CHR(39));
        vbuscar := vbuscar || ' AND UPPER(p.snip) = UPPER(''' || vpsnip || ''')';
      END IF;
      IF pbuscar IS NOT NULL THEN
        vfuncion := pbuscar;
        vfuncion := REPLACE(vfuncion, CHR(39), CHR(39) || CHR(39));
        vbuscar  := vbuscar || ' AND p.tbuscar LIKE UPPER(''%' || vfuncion || '%'') ';
      END IF;
      vbuscar := vbuscar || ')';
    ELSIF ptipopers = 4 THEN
      IF ptdescrie IS NOT NULL THEN
        vbuscar   := vbuscar || ' AND se.sseguro IN (SELECT s.sseguro FROM sin_siniestro s, sin_tramita_personasrel a where s.nsinies = a.nsinies and upper(a.tdesc) LIKE upper(''%' || ptdescrie || '%'')) ';
      END IF;
    END IF;
  END IF;
  vpasexec := 10;
  IF pfiltro = 0 THEN
    IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'FILTRO_AGE'), 0) = 1 THEN
      vqueryfiltro := vqueryfiltro || ' and se.cagente in (SELECT a.cagente
FROM (SELECT     LEVEL nivel, cagente
FROM redcomercial r
WHERE
r.fmovfin is null
START WITH
r.cagente = ' || pac_md_common.f_get_cxtagente || ' AND r.cempres = ' || pac_md_common.f_get_cxtempresa ||
      ' and r.fmovfin is null
CONNECT BY PRIOR r.cagente =(r.cpadre + 0)
AND PRIOR r.cempres =(r.cempres + 0)
and r.fmovfin is null
AND r.cagente >= 0) rr,
agentes a
where rr.cagente = a.cagente) ';
    END IF;
  END IF;
  IF ptrefext IS NOT NULL THEN
    IF pctipref IS NOT NULL THEN
      vbuscar   := vbuscar || ' and si.nsinies in (SELECT nsinies
FROM SIN_SINIESTRO_REFERENCIAS
WHERE ctipref = ' || pctipref || '
AND UPPER(trefext)
like UPPER(''' || ptrefext || ''' ))';
    ELSE
      vbuscar := vbuscar || ' and si.nsinies in (SELECT nsinies
FROM SIN_SINIESTRO_REFERENCIAS
WHERE UPPER(trefext)
like UPPER(''' || ptrefext || ''' ))';
    END IF;
  END IF;
  IF pncontrato IS NOT NULL THEN
    vbuscar := vbuscar || ' AND EXISTS ( select 1 FROM PREGUNPOLSEG P WHERE p.sseguro = se.sseguro and p.nmovimi = ' || '  (select max(nmovimi)from pregunpolseg p1 where p1.sseguro = p.sseguro and p1.cpregun = p.cpregun) ' || ' and p.cpregun = 4097 AND p.trespue = '''||pncontrato|| ''') ';
  END IF;
  vbuscar                                                                                    := vbuscar || vqueryfiltro;
  vpasexec                                                                                   := 11;
  vsquery                                                                                    := vsquery || vbuscar; -- dra 04/12/2008: bug mantis 8359
  vpasexec                                                                                   := 12;
  p_tab_error(SYSDATE,f_user,vobjectname,vpasexec,vparam,vsquery);
  vcursor                                                                                    := pac_md_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec                                                                                   := 13;
  IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_SINIESTROS.F_CONSULTASINI', 1, 4, mensajes) <> 0 THEN
    IF vcursor%ISOPEN THEN
      CLOSE vcursor;
    END IF;
  END IF;
  RETURN vcursor;
EXCEPTION
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_consultasini;
/*************************************************************************
Devuelve los siniestros que cumplan con el criterio de selección
param in pnpoliza     : número de póliza
param in pncert       : número de cerificado por defecto 0
param in pnsinies     : número del siniestro1
param out mensajes    : mensajes de error
return                : ref cursor
*************************************************************************/
FUNCTION f_consulta_lstsini(
    pnpoliza IN NUMBER,
    pncertif IN NUMBER DEFAULT -1,
    pnsinies IN VARCHAR2,
    pcestsin IN NUMBER,
    -- BUG 16645 --ETM--23/11/2010--0016645: GRC - Búsqueda de siniestros
    pfiltro  IN NUMBER,
    pnriesgo IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  --nou parametre cestin faltaria
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.Consulta_lstsini';
  vparam      VARCHAR2(500) := 'parámetros - pnpoliza: ' || pnpoliza || ' - pnsinies: ' || pnsinies || ' - pncertif: ' || pncertif || ' - pcestsin: ' || pcestsin;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery      VARCHAR2(5000);
  vbuscar      VARCHAR2(2000);
  vsubus       VARCHAR2(500);
  vtabtp       VARCHAR2(10);
  vauxnom      VARCHAR2(200);
  vqueryfiltro VARCHAR2(1200);
BEGIN
  vpasexec := 3;
  --filtra x cestin
  -- Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación
  -- BUG 16645 --ETM--23/11/2010--0016645: GRC - Búsqueda de siniestros
  IF pnsinies IS NOT NULL THEN
    vbuscar   := ' WHERE si.nsinies = ' || pnsinies;
    vbuscar   := vbuscar || ' and se.sseguro = si.sseguro ';
  ELSE
    vbuscar              := ' WHERE se.npoliza = ' || pnpoliza;
    IF NVL(pncertif, -1) <> -1 THEN
      vbuscar            := vbuscar || ' and se.ncertif = ' || pncertif;
      vbuscar            := vbuscar || ' and si.nriesgo = ' || pnriesgo;
    END IF;
  END IF;
  IF pfiltro                                                                                 = 0 THEN
    IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'FILTRO_AGE'), 0) = 1 THEN
      vqueryfiltro                                                                          := vqueryfiltro || ' and se.cagente in (SELECT a.cagente
FROM (SELECT     LEVEL nivel, cagente
FROM redcomercial r
WHERE
r.fmovfin is null
START WITH
r.cagente = ' || pac_md_common.f_get_cxtagente || ' AND r.cempres = ' || pac_md_common.f_get_cxtempresa ||
      ' and r.fmovfin is null
CONNECT BY PRIOR r.cagente =(r.cpadre + 0)
AND PRIOR r.cempres =(r.cempres + 0)
and r.fmovfin is null
AND r.cagente >= 0) rr,
agentes a
where rr.cagente = a.cagente) ';
    END IF;
  END IF;
  -- Bug 10127 - APD - 19/05/2009 - fin
  --faltaria filtra per cestsin
  vbuscar  := vbuscar || ' and se.sseguro = si.sseguro and sm.nsinies = si.nsinies and sm.nmovsin = (select max(nmovsin) from sin_movsiniestro where nsinies = si.nsinies) ';
  vpasexec := 5;
  vsquery  := --BUG 14587 - PFA - 13/08/2010 - Añadir campo siniestro compañia
  ' SELECT se.sseguro, se.npoliza, se.ncertif, si.nsincia,  si.ccompani, (select tcompani from companias where ccompani = si.ccompani) tcompani, si.npresin, si.nsinies, si.nriesgo, se.sproduc, ' || ' PAC_MD_OBTENERDATOS.F_Desriesgos(''POL'', si.sseguro, si.nriesgo) as triesgo,' || ' f_desproducto_t(se.cramo,se.cmodali,se.ctipseg,se.ccolect,1,PAC_MD_COMMON.F_Get_CXTIDIOMA) as tproduc,' || ' si.fnotifi, si.FSINIES, si.tsinies, si.ccausin, se.cactivi,' || ' (select tcausin from sin_descausa where ccausin = si.ccausin and cidioma = ' || pac_md_common.f_get_cxtidioma || ') tcausin, si.cmotsin, ' || ' (select tmotsin from sin_desmotcau where ccausin = si.ccausin and cmotsin = si.cmotsin and cidioma = ' || pac_md_common.f_get_cxtidioma || ')  tmotsin,sm.cestsin, ff_desvalorfijo(6,' || pac_md_common.f_get_cxtidioma || ', sm.cestsin) testsin,si.tdetpreten FROM seguros se, sin_siniestro si, sin_movsiniestro sm ';
  -- ini--BUG 16645 --ETM--23/11/2010--0016645: GRC - Búsqueda de siniestros
  vpasexec    := 7;
  IF pcestsin IS NOT NULL THEN
    vbuscar   := vbuscar || ' and sm.cestsin = ' || pcestsin;
  END IF;
  -- fin--BUG 16645 --ETM--23/11/2010--0016645: GRC - Búsqueda de siniestros
  vpasexec := 8;
  vbuscar  := vbuscar || vqueryfiltro;
  vsquery  := vsquery || vbuscar || ' order by si.nsinies';
  -- dra 04/12/2008: bug mantis 8359
  vcursor                                                                                        := pac_md_listvalores.f_opencursor(vsquery, mensajes);
  IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_SINIESTROS.F_CONSULTA_LSTSINI', 1, 4, mensajes) <> 0 THEN
    IF vcursor%ISOPEN THEN
      CLOSE vcursor;
    END IF;
  END IF;
  RETURN vcursor;
EXCEPTION
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_consulta_lstsini;
/*************************************************************************
Recuperar la información de los asegurados
param out mensajes : mesajes de error
return             : objeto asegurados
*************************************************************************/
FUNCTION f_leeasegurados(
    psseguro IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN t_iax_asegurados
IS
  CURSOR polaseg
  IS
    SELECT * FROM asegurados WHERE sseguro = psseguro;
  aseg t_iax_asegurados := t_iax_asegurados();
  v_aseg ob_iax_asegurados;
  vcagente NUMBER;
  num_err  NUMBER;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(100) := 'psseguro :' || psseguro;
  vobject  VARCHAR2(200) := 'PAC_MD_siniestros.F_LeeAsegurados';
BEGIN
  FOR saseg IN polaseg
  LOOP
    num_err    := pac_seguros.f_get_cagente(saseg.sseguro, 'SEG', vcagente);
    IF num_err <> 0 THEN
      RAISE e_object_error;
    END IF;
    v_aseg            := ob_iax_asegurados();
    v_aseg.norden     := saseg.norden;
    v_aseg.sperson    := saseg.sperson;
    v_aseg.ffecini    := saseg.ffecini;
    v_aseg.ffecfin    := saseg.ffecfin;
    v_aseg.ffecmue    := saseg.ffecmue;
    vpasexec          := 5;
    num_err           := pac_md_persona.f_get_persona_agente(saseg.sperson, vcagente, 'POL', v_aseg, mensajes);
    IF v_aseg.cestper <> 2 AND v_aseg.fdefunc IS NULL THEN
      aseg.EXTEND;
      aseg(aseg.LAST) := v_aseg;
    END IF;
    IF num_err <> 0 THEN
      RAISE e_object_error;
    END IF;
    vpasexec := 6;
    --P_FindIsTomador(saseg.sperson);
  END LOOP;
  RETURN aseg;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN NULL;
END f_leeasegurados;
/*************************************************************************
función devuelvo las garantias de un seguro
-- Bug 11847 - 23/11/2009 - AMC
-- Bug 0020472 - JMF - 09/12/2011: porigen (0-crear siniestro, 1-crear reserva)
*************************************************************************/
FUNCTION f_get_garantias(
    psseguro IN NUMBER,
    pnriesgo IN NUMBER,
    pccausin IN NUMBER,
    pcmotsin IN NUMBER,
    pfsinies IN DATE,
    porigen  IN NUMBER DEFAULT 0,
    pctramit IN NUMBER DEFAULT NULL, -- 25812:ASN:23/01/2013
    pnsinies IN NUMBER DEFAULT NULL, -- 25812:ASN:27/05/2013
    pntramit IN NUMBER DEFAULT NULL, -- 25812:ASN:27/05/2013
    pctipres IN NUMBER DEFAULT NULL, -- 25812:ASN:27/05/2013
    mensajes IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vcagente NUMBER;
  num_err  NUMBER;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(100) := 'psseguro :' || psseguro;
  vobject  VARCHAR2(200) := 'PAC_MD_siniestros.F_get_garantias';
  vcursor sys_refcursor;
  vsquery          VARCHAR2(5000);
  vcactivi         NUMBER;
  vfefecto         DATE;
  vsproduc         NUMBER; -- Bug 0020472 - JMF - 09/12/2011
  v_sintodasgarant NUMBER; -- Bug 0020472 - JMF - 09/12/2011
  vexcepciones     NUMBER; -- 25812:ASN:23/01/2013
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 3;
  --Bug.: 15880 - ICV - 25/10/2010
  -- Bug 0020472 - JMF - 09/12/2011: sproduc
  SELECT cactivi,
    fefecto,
    sproduc
  INTO vcactivi,
    vfefecto,
    vsproduc
  FROM seguros
  WHERE sseguro = psseguro;
  IF pfsinies   < vfefecto THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 109925);
    RAISE e_param_error;
  END IF;
  --Fin Bug.
  -- Bug 0020472 - JMF - 09/12/2011
  v_sintodasgarant := NVL(f_parproductos_v(vsproduc, 'SIN_TODAS_GARANT'), 0);
  --bug. 11192. Alta de siniestros de Vida  xpl, s'afegeix a la select el camp icapital
  vsquery := 'select cgarant, tgarant, icapital from (select distinct sgc.cgarant, gg.tgarant, gs.icapital, gs.norden
from sin_gar_causa sgc, garanseg gs, seguros s, garangen gg
where sgc.cactivi = ' || vcactivi;
  -- 25812:ASN:23/01/2013 ini
  /*
  -- ini Bug 0020472 - JMF - 09/12/2011
  IF porigen = 1
  AND v_sintodasgarant = 1 THEN
  -- Mostrar todas las garantias, no filtrar por causa motivo.
  NULL;
  ELSE
  vsquery := vsquery || ' and sgc.ccausin = ' || pccausin || ' and sgc.cmotsin = '
  || pcmotsin;
  END IF;
  -- fin Bug 0020472 - JMF - 09/12/2011
  */
  IF porigen            = 1 THEN
    IF v_sintodasgarant = 1 THEN
      NULL;
    ELSE
      vsquery := vsquery || ' and sgc.ccausin = ' || pccausin || ' and sgc.cmotsin = ' || pcmotsin;
      SELECT COUNT(*)
      INTO vexcepciones
      FROM sin_gar_permitidas
      WHERE sproduc   = vsproduc
      AND cactivi     = vcactivi
      AND ctramit     = pctramit;
      IF vexcepciones > 0 THEN
        vsquery      := vsquery || ' and gs.cgarant in (select cgarant from sin_gar_permitidas where ' || 'sproduc = ' || vsproduc || ' and cactivi = ' || vcactivi || ' and ctramit = ' || pctramit || ') ';
      END IF;
    END IF;
  ELSE
    vsquery := vsquery || ' and sgc.ccausin = ' || pccausin || ' and sgc.cmotsin = ' || pcmotsin;
  END IF;
  -- 25812:ASN:23/01/2013 fin
  vsquery := vsquery || ' and sgc.cgarant =  gs.cgarant
and gs.sseguro = ' || psseguro || '
and gs.sseguro = s.sseguro
and gs.nriesgo = ' || pnriesgo || '
and sgc.sproduc = s.sproduc
and gs.finiefe <= ''' || pfsinies
  -- BUG 17547 - 07/02/2011 - SRA - añadimos una corrección para que los intérvalos de vigencia acaben un día antes de la feche de fin de efecto ffinefe
  || '''
and (gs.ffinefe is null or gs.ffinefe-1 >= ''' || pfsinies
  -- FIN BUG 17547 - 07/02/2011 - SRA
  || ''')
        And (gs.finivig is null or gs.finivig <= ''' || pfsinies  || ''')
        And (gs.ffinvig is null or gs.ffinvig-1 >= ''' || pfsinies  || ''')
and gg.cgarant = gs.cgarant
and gg.cidioma = ' || pac_md_common.f_get_cxtidioma || '
UNION
select distinct sgc.cgarant, gg.tgarant, gs.icapital, gs.norden
from sin_gar_causa sgc, garanseg gs, seguros s, garangen gg
where sgc.cactivi = 0
and NOT EXISTS (SELECT 1 FROM sin_gar_causa WHERE sproduc = sgc.sproduc AND cactivi = ' || vcactivi || ')';
  -- ini Bug 0020472 - JMF - 09/12/2011
  IF porigen = 1 AND v_sintodasgarant = 1 THEN
    -- Mostrar todas las garantias, no filtrar por causa motivo.
    NULL;
  ELSE
    vsquery := vsquery || ' and sgc.ccausin = ' || pccausin || ' and sgc.cmotsin = ' || pcmotsin;
  END IF;
  -- fin Bug 0020472 - JMF - 09/12/2011
  vsquery := vsquery || '
and sgc.cgarant =  gs.cgarant
and gs.sseguro = ' || psseguro || '
and gs.sseguro = s.sseguro
and gs.nriesgo = ' || pnriesgo || '
and sgc.sproduc = s.sproduc
and gs.finiefe <= ''' || pfsinies
  -- BUG 17547 - 07/02/2011 - SRA - añadimos una corrección para que los intérvalos de vigencia acaben un día antes de la feche de fin de efecto ffinefe
  || '''
and (gs.ffinefe is null or gs.ffinefe-1 >= ''' || pfsinies
  -- FIN BUG 17547 - 07/02/2011 - SRA
  || ''')
         And (gs.finivig is null or gs.finivig <= ''' || pfsinies  || ''')
         And (gs.ffinvig is null or gs.ffinvig-1 >= ''' || pfsinies  || ''')
and gg.cgarant = gs.cgarant
and gg.cidioma = ' || pac_md_common.f_get_cxtidioma;
  -- 25812:ASN:27/05/2013 ini
  -- a la lista de garantias, sea cual sea, se anyaden todas las garantias
  -- que tengan reserva > 0 en esa tramitacion
  IF pntramit IS NOT NULL AND pctipres IS NOT NULL THEN
    vsquery   := vsquery || '
UNION
select distinct str.cgarant, gg.tgarant, gs.icapital, gs.norden
from sin_tramita_reserva str, garanseg gs, garangen gg
where nsinies = ' || pnsinies || ' and ntramit = ' || pntramit || ' and ctipres = ' || pctipres || ' and nmovres =  (select max(nmovres) from sin_tramita_reserva st1
where st1.nsinies = str.nsinies
and st1.ntramit = str.ntramit
and st1.ctipres = str.ctipres
and NVL(st1.ctipgas, -1) = NVL(str.ctipgas, -1)
and NVL(st1.cgarant, -1) = NVL(str.cgarant, -1) )' || '
and str.cgarant =  gs.cgarant
and str.ireserva > 0
and gs.sseguro = ' || psseguro || '
and gs.nriesgo = ' || pnriesgo || '
and gs.finiefe <= ''' || pfsinies ||
    '''
 And (gs.finivig is null or gs.finivig <= ''' || pfsinies  || ''')
         And (gs.ffinvig is null or gs.ffinvig-1 >= ''' || pfsinies  || ''')
and (gs.ffinefe is null or gs.ffinefe-1 >= ''' || pfsinies || ''')
and gg.cgarant = gs.cgarant
and gg.cidioma = ' || pac_md_common.f_get_cxtidioma;
  END IF;
  vsquery := vsquery || ') order by norden';
  -- 25812:ASN:27/05/2013 fin
  vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN NULL;
END f_get_garantias;
/*************************************************************************
función devuelve la franquicia de una garantia
-- Bug 11847 - 23/11/2009 - AMC
*************************************************************************/
FUNCTION f_get_franquicia_garantia(
    psseguro IN NUMBER,
    pnriesgo IN NUMBER,
    pcgarant IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vcagente NUMBER;
  num_err  NUMBER;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(100) := 'psseguro :' || psseguro;
  vobject  VARCHAR2(200) := 'PAC_MD_siniestros.F_get_franquicia_garantia';
  vsquery  VARCHAR2(5000);
  vifranqu NUMBER(9);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  BEGIN
    SELECT ifranqu
    INTO vifranqu
    FROM garanseg
    WHERE sseguro = psseguro
    AND nriesgo   = pnriesgo
    AND cgarant   = pcgarant
    AND nmovimi   =
      (SELECT MAX(nmovimi)
      FROM garanseg
      WHERE sseguro = psseguro
      AND nriesgo   = pnriesgo
      AND cgarant   = pcgarant
      AND ffinefe  IS NULL
      )
    AND ffinefe IS NULL;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  RETURN vifranqu;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN NULL;
END f_get_franquicia_garantia;
/***********************************************************************
Recupera la colección de documentos
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param out t_iax_sin_trami_documento :  t_iax_sin_trami_documento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_documentos(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_documentos OUT t_iax_sin_trami_documento,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_documentos';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit: ' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_doc
  IS
    SELECT nsinies,
      ntramit,
      ndocume,
      cdocume,
      iddoc,
      freclama,
      frecibe,
      fcaduca,
      cobliga
    FROM sin_tramita_documento
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit
    ORDER BY ndocume ASC;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL OR pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_documentos := t_iax_sin_trami_documento();
  FOR reg IN cur_doc
  LOOP
    t_documentos.EXTEND;
    t_documentos(t_documentos.LAST) := ob_iax_sin_trami_documento();
    vnumerr                         := f_get_documento(pnsinies, reg.ntramit, reg.ndocume, t_documentos(t_documentos.LAST), mensajes);
    IF mensajes                     IS NOT NULL THEN
      IF mensajes.COUNT              > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_documentos;
/***********************************************************************
Function f_get_documento
Recupera los datos de un documento
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pndocume  : número de document
param out  ob_iax_sin_trami_documento :  ob_iax_sin_trami_documento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_documento(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pndocume IN NUMBER,
    ob_documento OUT ob_iax_sin_trami_documento,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_documento';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit || 'pndocume = ' || pndocume;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  ob_documento := ob_iax_sin_trami_documento();
  vnumerr      := pac_siniestros.f_get_documento(pnsinies, pntramit, pndocume, pac_md_common.f_get_cxtidioma, vsquery);
  cur          := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec     := 4;
  -- Bug 0022153 - 19/07/2012 - JMF: afegir camps
  -- Bug 34622 - 03/03/2015 - JTT: Afegim els camps caccion i corigen
  LOOP
    FETCH cur
    INTO ob_documento.nsinies,
      ob_documento.ntramit,
      ob_documento.ndocume,
      ob_documento.cdocume,
      ob_documento.iddoc,
      ob_documento.freclama,
      ob_documento.frecibe,
      ob_documento.fcaduca,
      ob_documento.cobliga,
      ob_documento.ttitdoc,
      ob_documento.cusualt,
      ob_documento.falta,
      ob_documento.cusumod,
      ob_documento.fmodifi,
      ob_documento.descdoc,
      ob_documento.caccion,
      ob_documento.corigen,
      ob_documento.tusualtdoc;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_documento;
/***********************************************************************
Graba el objeto siniestros a las tablas de la bbdd
param out mensajes  : mensajes de error
return              : 1 -> Todo correcto
0 -> Se ha producido un error
***********************************************************************/
FUNCTION f_grabar_siniestro(
    pobsiniestro IN OUT ob_iax_siniestros,
    mensajes     IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_grabar_siniestro';
  vparam      VARCHAR2(500) := 'parámetros ';
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  vnsinies sin_siniestro.nsinies%TYPE;
  vnmovsin NUMBER;
BEGIN
  vpasexec := 2;
  vnumerr  := f_set_dades_sinistre(pobsiniestro, vnsinies, mensajes);
  --      p_tab_error(f_sysdate, f_user, 'ini f_grabar_siniestro', NULL, '0', vnumerr);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  --      p_tab_error(f_sysdate, f_user, 'ini f_grabar_siniestro', NULL, '1', vnumerr);
  vpasexec   := 3;
  vnumerr    := f_set_movsiniestros(pobsiniestro.movimientos, vnsinies, vnmovsin, mensajes);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  -- Ini bug 16924 - SRA - 16/12/2010
  vpasexec   := 4;
  vnumerr    := pac_siniestros.f_estadotram_alta_sini(vnsinies, pobsiniestro);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  -- Fin bug 16924 - SRA - 16/12/2010
  -- BUG 18336 - JMC - 29/04/2011
  vpasexec   := 5;
  vnumerr    := pac_md_sin_tramite.f_set_tramites(pobsiniestro.tramites, vnsinies, mensajes);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  -- FIN BUG 18336 - JMC - 29/04/2011
  vpasexec   := 6;
  select count(*) INTO vnumerr from sin_tramitacion where nsinies=vnsinies;
  IF vnumerr=0 THEN
      vnumerr    := f_set_tramitaciones(pobsiniestro.tramitaciones, vnsinies, NULL, mensajes); -- BUG 25537 - FAL - 04/02/2014
      IF vnumerr <> 0 THEN
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
        RAISE e_object_error;
      END IF;
  ELSE
  vnumerr:=0;
  END IF;
  -- INI BUG 18932 - JBN
  vpasexec   := 7;
  vnumerr    := f_set_referencias(vnsinies, pobsiniestro.referencias, mensajes);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  --Ini Bug 21855 - MDS - 08/05/2012
  vpasexec     := 8;
  IF vnsinies  IS NOT NULL THEN
    vnumerr    := f_set_defraudadores(vnsinies, pobsiniestro.defraudadores, mensajes);
    IF vnumerr <> 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
      RAISE e_object_error;
    END IF;
  END IF;
  --Fin Bug 21855 - MDS - 08/05/2012
  vpasexec             := 9;
  pobsiniestro.nsinies := vnsinies;
  -- 22603:ASN:09/07/2012 ini
  /*
  vnumerr := pac_siniestros.f_post_siniestro(vnsinies);   -- bug19416:ASN:14/12/2011
  */
  -- 22603:ASN:09/07/2012 fin
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_grabar_siniestro;
/***********************************************************************
Graba la cabecera del objeto siniestros a las tablas de la bbdd
pobsiniestro IN ob_iax_siniestros
param out mensajes  : mensajes de error
return              : 1 -> Todo correcto
0 -> Se ha producido un error
***********************************************************************/
FUNCTION f_set_dades_sinistre(
    pobsiniestro IN ob_iax_siniestros,
    pnsinies     IN OUT VARCHAR2,
    mensajes     IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_dades_sinistre';
  vparam      VARCHAR2(500) := 'parámetros ';
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  vnsinies sin_siniestro.nsinies%TYPE;
  vfsinies DATE; --26962:NSS:13/06/2013
BEGIN
  pnsinies               := pobsiniestro.nsinies;
  IF pobsiniestro.nsinies < 0 THEN
    pnsinies             := NULL;
  END IF;
  vfsinies := TO_DATE(TO_CHAR(pobsiniestro.fsinies, 'dd/mm/yyyy') || pobsiniestro.hsinies, 'dd/mm/yyyy hh24:mi:ss');
  vnumerr  := pac_siniestros.f_ins_siniestro(pobsiniestro.sseguro, pobsiniestro.nriesgo, pobsiniestro.nmovimi, vfsinies,
  --26962:NSS:13/06/2013
  pobsiniestro.fnotifi, pobsiniestro.ccausin, pobsiniestro.cmotsin, pobsiniestro.cevento, pobsiniestro.cculpab, pobsiniestro.creclama, pobsiniestro.nasegur, pobsiniestro.cmeddec, pobsiniestro.ctipdec, pobsiniestro.tnomdec, pobsiniestro.tnom1dec, pobsiniestro.tnom2dec, pobsiniestro.tape1dec, pobsiniestro.tape2dec, pobsiniestro.tteldec, pobsiniestro.tmovildec, pobsiniestro.temaildec, pobsiniestro.tsinies, pobsiniestro.ctipide, pobsiniestro.nnumide, pobsiniestro.nsincia, pobsiniestro.ccompani, pobsiniestro.npresin, pnsinies, pobsiniestro.cnivel, pobsiniestro.sperson2, pobsiniestro.dec_sperson, pobsiniestro.fechapp, pobsiniestro.cpolcia, pobsiniestro.iperit, pobsiniestro.cfraude, pobsiniestro.ccarpeta, pobsiniestro.cagente,
  -- Bug 21817 - MDS - 2/05/2012
  pobsiniestro.csalvam, pobsiniestro.fdeteccion, pobsiniestro.solidaridad, pobsiniestro.tdetpreten
  -- BUG 0024675 - 15/11/2012 - JMF
  ); --BUG18748 - JBN
  --bug 19896 --ETM  -20/12/2011-- Añadir campo segundo nombre declarante,movil ,email,al declarante
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_dades_sinistre;
/***********************************************************************
Graba la los movimientos del siniestro
pmovimientos IN ob_iax_movsiniestro
param out mensajes  : mensajes de error
return              : 1 -> Todo correcto
0 -> Se ha producido un error
***********************************************************************/
FUNCTION f_set_movsiniestros(
    pmovimientos IN t_iax_sin_movsiniestro,
    pnsinies     IN OUT VARCHAR2,
    pnmovsin     IN OUT NUMBER,
    mensajes     IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_movsiniestros';
  vparam      VARCHAR2(500) := 'parámetros ';
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  vnmovsin NUMBER;
BEGIN
  FOR i IN pmovimientos.FIRST .. pmovimientos.LAST
  LOOP
    vnumerr            := f_set_movsiniestro(pmovimientos(i), pnsinies, pnmovsin, mensajes);
    IF mensajes        IS NOT NULL THEN
      IF mensajes.COUNT > 0 THEN
        RETURN vnumerr;
      END IF;
    END IF;
  END LOOP;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_movsiniestros;
/***********************************************************************
grabar los datos de un determinado movimiento de siniestro
param in  ob_iax_sin_movsiniestro :  ob_iax_sin_movsiniestro
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_movsiniestro(
    ob_movsiniestro IN ob_iax_sin_movsiniestro,
    pnsinies        IN VARCHAR2,
    pnmovsin        IN OUT NUMBER,
    mensajes        IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_movsiniestro';
  vparam      VARCHAR2(500) := 'parámetros ';
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
BEGIN
  pnmovsin := ob_movsiniestro.nmovsin;
  vnumerr  := pac_siniestros.f_ins_movsiniestro(pnsinies, ob_movsiniestro.cestsin, ob_movsiniestro.festsin, ob_movsiniestro.ccauest, ob_movsiniestro.cunitra, ob_movsiniestro.ctramitad, pnmovsin);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_movsiniestro;
/***********************************************************************
Graba la collecio de tramitacions
param out  t_iax_sin_tramitacion :  t_iax_sin_tramitacion
param in  pnsinies  : número de siniestro
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_tramitaciones(
    ptramitaciones IN t_iax_sin_tramitacion,
    pnsinies       IN VARCHAR2,
    psidepag       IN NUMBER, -- BUG 25537 - FAL - 04/02/2014
    mensajes       IN OUT t_iax_mensajes,
    pcvalida_ult   IN NUMBER DEFAULT NULL) --bug 29989/165377;NSS;13-02-2014)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_tramitaciones';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF ptramitaciones IS NOT NULL AND ptramitaciones.COUNT > 0 THEN
    FOR i IN ptramitaciones.FIRST .. ptramitaciones.LAST
    LOOP
      IF ptramitaciones.EXISTS(i) THEN
        vnumerr := f_set_tramitacion(ptramitaciones(i), pnsinies, psidepag, mensajes,
        -- BUG 25537 - FAL - 04/02/2014
        pcvalida_ult); --bug 29989/165377;NSS;13-02-2014
        IF mensajes        IS NOT NULL THEN
          IF mensajes.COUNT > 0 THEN
            RETURN vnumerr;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_tramitaciones;
/***********************************************************************
Recupera los datos de un determinado tramitacion
param in  pnsinies  : número de siniestro
param out  ob_iax_sin_tramitacion :  ob_iax_sin_tramitacion
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
-- Bug 12668 - 26/02/2010 - AMC
***********************************************************************/
FUNCTION f_set_tramitacion(
    ptramitacion IN ob_iax_sin_tramitacion,
    pnsinies     IN VARCHAR2,
    psidepag     IN NUMBER, -- BUG 25537 - FAL - 04/02/2014
    mensajes     IN OUT t_iax_mensajes,
    pcvalida_ult IN NUMBER DEFAULT NULL) --bug 29989/165377;NSS;13-02-2014)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_tramitacion';
  vparam      VARCHAR2(500) := 'parÃ¡metros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 1;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  vntramit        NUMBER;
  psidepagpago    NUMBER(10);
  psidepagrecobro NUMBER(10);
  vfiscalexiste      NUMBER;
  pntramit           NUMBER;
  vjudiexiste       NUMBER;
BEGIN
  vpasexec := 10;
  vntramit := ptramitacion.ntramit;
  vpasexec := 15;
  -- BUG 0023536 - 24/10/2012 - JMF: Afegir csubtiptra
  vnumerr    := pac_siniestros.f_ins_tramitacion(pnsinies, ptramitacion.ctramit, ptramitacion.ctcausin, ptramitacion.cinform, vntramit, ptramitacion.cculpab, ptramitacion.ccompani, ptramitacion.nsincia, ptramitacion.cpolcia, ptramitacion.iperit, ptramitacion.ntramte, ptramitacion.csubtiptra, ptramitacion.nradica);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  --ob_iax_sin_tramitacion
  vpasexec := 20;
   -- BUG 0023540 - 24/10/2012 - JMF: Afegir IRECLAM, IINDEMN
  --Inicio IAXIS 3595 AABC Insert automatico del detalle tramitacion Judicial.
  IF ptramitacion.ctramit = 20 THEN

     BEGIN
            SELECT count(ntramit)   INTO vjudiexiste FROM sin_tramita_judicial   WHERE nsinies = pnsinies  AND ntramit = vntramit;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vjudiexiste := 0;
         END;
        IF vjudiexiste = 0 THEN 
         vnumerr := pac_siniestros.f_ins_judicial(pnsinies  , vntramit , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL , NULL , NULL, NULL, NULL, NULL , NULL, NULL, NULL, NULL ,  NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL  , NULL , NULL  , NULL , NULL , NULL , NULL , NULL , NULL, NULL , NULL , NULL);
	   END IF;


 ELSE
  -- bug 4100 visualizar tabla fiscal 
        IF ptramitacion.ctramit = 21 THEN
         BEGIN
               SELECT count(ntramit)   INTO vfiscalexiste FROM sin_tramita_fiscal   WHERE nsinies = pnsinies  AND ntramit = vntramit;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vfiscalexiste := 0;
         END;   
        IF vfiscalexiste = 0 THEN 
         vnumerr := pac_siniestros.f_ins_fiscal(pnsinies,ptramitacion.ntramit,NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL, NULL ,NULL ,NULL ,NULL ,NULL ,NULL  ,NULL ,NULL  ,NULL  ,NULL  ,NULL); 
        END IF;
     END IF;

  END IF;
  --Fin IAXIS 3595 AABC Insert automatico del detalle tramitacion Judicial.
  vnumerr := pac_siniestros.f_ins_detalltramitacio(ptramitacion.ctiptra, pnsinies, ptramitacion.detalle.ntramit, ptramitacion.detalle.persona.sperson, ptramitacion.detalle.cestper, ptramitacion.detalle.desctramit, ptramitacion.detalle.direccion.csiglas, ptramitacion.detalle.direccion.tnomvia, ptramitacion.detalle.direccion.nnumvia, ptramitacion.detalle.direccion.tcomple, ptramitacion.detalle.tdescdireccion, ptramitacion.detalle.direccion.cpais, ptramitacion.detalle.direccion.cprovin, ptramitacion.detalle.direccion.cpoblac, ptramitacion.detalle.direccion.cpostal, ptramitacion.detalle.direccion.cciudad, ptramitacion.detalle.direccion.fgisx, ptramitacion.detalle.direccion.fgisy, ptramitacion.detalle.direccion.fgisz, ptramitacion.detalle.direccion.cvalida, ptramitacion.detalle.ctipcar, ptramitacion.detalle.fcarnet, ptramitacion.detalle.ctipcon, ptramitacion.detalle.calcohol, ptramitacion.detalle.ctipmat, ptramitacion.detalle.cmatric, ptramitacion.detalle.cmarca,
  ptramitacion.detalle.cmodelo, ptramitacion.detalle.cversion, ptramitacion.detalle.nanyo, ptramitacion.detalle.codmotor, ptramitacion.detalle.cchasis, ptramitacion.detalle.nbastid, ptramitacion.detalle.ccilindraje, ptramitacion.detalle.ireclam, ptramitacion.detalle.iindemn);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 25;
  vnumerr    := f_set_movtramits(pnsinies, ptramitacion.movimientos, mensajes, pcvalida_ult); --bug 29989/165377;NSS;13-02-2014
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  -- Inicio IAXIS-4955 EA
  IF ptramitacion.ctramit = 20 THEN
    UPDATE sin_tramita_judicial SET TPROCESO=(select case cesttra when 0 then 1 when 1 then 2 end from sin_tramita_movimiento where NSINIES=pnsinies and ntramit=ptramitacion.ntramit and nmovtra=(select   max(nmovtra)  from sin_tramita_movimiento where NSINIES=pnsinies and ntramit=ptramitacion.ntramit)) WHERE NSINIES=pnsinies AND NTRAMIT=ptramitacion.ntramit;
  END IF;
  IF ptramitacion.ctramit = 21 THEN
    UPDATE sin_tramita_fiscal SET TESTADO=(select   FF_DESVALORFIJO(6, pac_md_common.f_get_cxtidioma() ,cesttra)  from sin_tramita_movimiento where NSINIES=pnsinies and ntramit=ptramitacion.ntramit and nmovtra=(select   max(nmovtra)  from sin_tramita_movimiento where NSINIES=pnsinies and ntramit=ptramitacion.ntramit)) WHERE NSINIES=pnsinies AND NTRAMIT=ptramitacion.ntramit;
  END IF;
  -- Fin IAXIS-4955 EA 
  vpasexec   := 30;
  vnumerr    := f_set_agendas(pnsinies, ptramitacion.agenda, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 35;
  vnumerr    := f_set_danyos(pnsinies, ptramitacion.danyos, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 40;
  vnumerr    := f_set_localizaciones(pnsinies, ptramitacion.localizaciones, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 45;
  vnumerr    := f_set_destinatarios(pnsinies, ptramitacion.destinatarios, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 50;
  vnumerr    := f_set_reservas(pnsinies, ptramitacion.reservas, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  --ctippag = 2 pagament, ctipag = 7 recobro
  vpasexec   := 55;
  vnumerr    := f_set_pagrecobs(pnsinies, ptramitacion.pagos, psidepag, mensajes); -- BUG 25537 - FAL - 04/02/2014
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 60;
  vnumerr    := f_set_pagrecobs(pnsinies, ptramitacion.recobros, psidepag, mensajes); -- BUG 25537 - FAL - 04/02/2014
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 65;
  vnumerr    := f_set_trami_documentos(pnsinies, ptramitacion.documentos, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  -- BUG 19821 - MDS - 11/11/2011
  vpasexec   := 66;
  vnumerr    := f_set_juzgados(pnsinies, ptramitacion.juzgados, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 67;
  vnumerr    := f_set_demands(pnsinies, ptramitacion.demandantes, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 68;
  vnumerr    := f_set_demands(pnsinies, ptramitacion.demandados, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec   := 69;
  vnumerr    := f_set_citaciones(pnsinies, ptramitacion.citaciones, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  -- Fin BUG 19821 - MDS - 11/11/2011
  vpasexec := 70;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam || ' ' || vnumerr);
  RETURN vnumerr;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN vnumerr;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam || ' ' || vnumerr, NULL, SQLCODE, SQLERRM);
  RETURN vnumerr;
END f_set_tramitacion;
/***********************************************************************
grabar la colección de movimientos de tramitos
param in  pnsinies  : número de siniestro
param in  t_iax_sin_trami_movimiento :  t_iax_sin_trami_movimiento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_movtramits(
    pnsinies     IN VARCHAR2,
    pmovtramits  IN t_iax_sin_trami_movimiento,
    mensajes     IN OUT t_iax_mensajes,
    pcvalida_ult IN NUMBER DEFAULT NULL) --bug 29989/165377;NSS;13-02-2014
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_movtramits';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  -- Bug 12668 - 03/03/2010 - AMC
  IF pmovtramits        IS NOT NULL THEN
    IF pmovtramits.COUNT > 0 THEN
      FOR i IN pmovtramits.FIRST .. pmovtramits.LAST
      LOOP
        IF pmovtramits.EXISTS(i) THEN
          vnumerr            := f_set_movtramit(pmovtramits(i), pnsinies, mensajes, pcvalida_ult); --bug 29989/165377;NSS;13-02-2014
          IF mensajes        IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
              RETURN vnumerr;
            END IF;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;
  -- Fi Bug 12668 - 03/03/2010 - AMC
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_movtramits;
/***********************************************************************
graba los datos de un movimiento de tramitacion
param in  pnsinies  : número de siniestro
param in  ob_iax_sin_trami_movimiento :  ob_iax_sin_trami_movimiento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_movtramit(
    pmovtramit   IN ob_iax_sin_trami_movimiento,
    pnsinies     IN VARCHAR2,
    mensajes     IN OUT t_iax_mensajes,
    pcvalida_ult IN NUMBER DEFAULT NULL) --bug 29989/165377;NSS;13-02-2014
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_movtramit';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 1;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  vnmovtra NUMBER(10);
BEGIN
  vnmovtra := pmovtramit.nmovtra;
  vnumerr  := pac_siniestros.f_ins_tramita_movimiento(pnsinies, pmovtramit.ntramit, pmovtramit.cunitra, pmovtramit.ctramitad, pmovtramit.cesttra, pmovtramit.csubtra, pmovtramit.festtra, vnmovtra, pmovtramit.ccauest,
  -- 21196:ASN:26/03/2012
  pcvalida_ult
  --bug 29989/165377;NSS;13-02-2014
  );
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN vnumerr;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN vnumerr;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vnumerr;
END f_set_movtramit;
/***********************************************************************
graba la colección de lineas de agenda
param in  pnsinies  : número de siniestro
param out  t_iax_sin_trami_agenda :  t_iax_sin_trami_agenda
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_agendas(
    pnsinies IN VARCHAR2,
    pagendas IN t_iax_sin_trami_agenda,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_listagenda';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pagendas.COUNT > 0 THEN
    FOR i IN pagendas.FIRST .. pagendas.LAST
    LOOP
      vnumerr            := f_set_agenda(pnsinies, pagendas(i), mensajes);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_agendas;
/***********************************************************************
graba los datos de un determinado agenda
param in  pnsinies  : número de siniestro
param out  ob_iax_sin_trami_agenda :  ob_iax_sin_trami_agenda
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_agenda(
    pnsinies IN VARCHAR2,
    pagenda  IN ob_iax_sin_trami_agenda,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_agenda';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  --    vnmovtra := pmovtramit.nmovtra;
  vnumerr := pac_siniestros.f_ins_agenda(pnsinies, pagenda.ntramit, pagenda.nlinage, pagenda.ctipreg, pagenda.cmanual, pagenda.cestage, pagenda.ffinage, pagenda.ttitage, pagenda.tlinage);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_agenda;
/***********************************************************************
graba la colección de danyos
param in  pnsinies  : número de siniestro
param in  t_iax_sin_trami_dano :  t_iax_sin_trami_dano
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_danyos(
    pnsinies IN VARCHAR2,
    pdanyos  IN t_iax_sin_trami_dano,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_danyos';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pdanyos.COUNT > 0 THEN
    FOR i IN pdanyos.FIRST .. pdanyos.LAST
    LOOP
      vnumerr            := f_set_danyo(pnsinies, pdanyos(i), mensajes);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_danyos;
/***********************************************************************
graba los datos de un danyo
param in  pnsinies  : número de siniestro
param in  ob_iax_sin_trami_dano :  ob_iax_sin_trami_dano
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_danyo(
    pnsinies IN VARCHAR2,
    pdanyo   IN ob_iax_sin_trami_dano,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_danyo';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
BEGIN
  vnumerr                := pac_siniestros.f_ins_dano(pnsinies, pdanyo.ntramit, pdanyo.ndano, pdanyo.ctipinf, pdanyo.tdano);
  IF pdanyo.detalle.COUNT > 0 THEN
    FOR i IN pdanyo.detalle.FIRST .. pdanyo.detalle.LAST
    LOOP
      vnumerr            := pac_siniestros.f_ins_detdano(pnsinies, pdanyo.ntramit, pdanyo.ndano, pdanyo.detalle(i).ndetdano);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_danyo;
/***********************************************************************
graba la colección de destinatarios
param in  pnsinies  : número de siniestro
param in  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_destinatarios(
    pnsinies       IN VARCHAR2,
    pdestinatarios IN t_iax_sin_trami_destinatario,
    mensajes       IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_destinatarios';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pdestinatarios.COUNT > 0 THEN
    FOR i IN pdestinatarios.FIRST .. pdestinatarios.LAST
    LOOP
      vnumerr            := f_set_destinatario(pnsinies, pdestinatarios(i), mensajes);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_destinatarios;
/***********************************************************************
graba los datos de un destinatario
param in  pnsinies  : número de siniestro
param out  ob_iax_sin_trami_destinatario :  ob_iax_sin_trami_destintario
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_destinatario(
    pnsinies      IN VARCHAR2,
    pdestinatario IN ob_iax_sin_trami_destinatario,
    mensajes      IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_SET_destinatario';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
  vnmesextra VARCHAR2(2000);
  -- Fi Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
  v_nlocali NUMBER;
  v_cdomici sin_prof_profesionales.cdomici%TYPE;
BEGIN
  vpasexec := 10;
  vnumerr  := pac_siniestros.f_ins_destinatario(pnsinies, pdestinatario.ntramit, pdestinatario.persona.sperson, pdestinatario.cbancar, pdestinatario.ctipban, pdestinatario.pasigna, pdestinatario.cpaisre, pdestinatario.ctipdes, pdestinatario.cpagdes, pdestinatario.cactpro, pdestinatario.ctipcap, pdestinatario.crelase, pdestinatario.sprofes, pdestinatario.cprovin); -- bug 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros - NSS - 26/02/2014
  -- ini Bug 0020138 - JMF - 28/11/2011
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam);
    RETURN vnumerr;
  END IF;
  IF pdestinatario.sprofes                                                                      IS NOT NULL THEN
    IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'SIN_LOC_PROV_AUT'), 0) = 1 THEN
      --
      SELECT sp.cdomici
      INTO v_cdomici
      FROM sin_prof_profesionales sp
      WHERE sp.sprofes = pdestinatario.sprofes;
      --
      IF v_cdomici                                  IS NOT NULL THEN
        IF pdestinatario.persona.direcciones        IS NOT NULL THEN
          IF pdestinatario.persona.direcciones.count > 0 THEN
            FOR i IN pdestinatario.persona.direcciones.first .. pdestinatario.persona.direcciones.last
            LOOP
              IF pdestinatario.persona.direcciones(i) .cdomici = v_cdomici THEN
                SELECT NVL(MAX(sl.nlocali), 0) + 1
                INTO v_nlocali
                FROM sin_tramita_localiza sl
                WHERE sl.nsinies = pdestinatario.nsinies
                AND sl.ntramit   = pdestinatario.ntramit;
                --
                vnumerr := pac_siniestros.f_ins_localiza(pdestinatario.nsinies, pdestinatario.ntramit, v_nlocali, pdestinatario.persona.sperson, pdestinatario.persona.direcciones(i) .csiglas, pdestinatario.persona.direcciones(i) .tnomvia, pdestinatario.persona.direcciones(i) .nnumvia, pdestinatario.persona.direcciones(i) .tcomple, pdestinatario.persona.direcciones(i) .localidad, pdestinatario.persona.direcciones(i) .cpais, pdestinatario.persona.direcciones(i) .cprovin, pdestinatario.persona.direcciones(i) .cpoblac, pdestinatario.persona.direcciones(i) .cpostal, pdestinatario.persona.direcciones(i) .cviavp, pdestinatario.persona.direcciones(i) .clitvp, pdestinatario.persona.direcciones(i) .cbisvp, pdestinatario.persona.direcciones(i) .corvp, pdestinatario.persona.direcciones(i) .nviaadco, pdestinatario.persona.direcciones(i) .clitco, pdestinatario.persona.direcciones(i) .corco, pdestinatario.persona.direcciones(i) .nplacaco, pdestinatario.persona.direcciones(i) .cor2co,
                pdestinatario.persona.direcciones(i) .cdet1ia, pdestinatario.persona.direcciones(i) .tnum1ia, pdestinatario.persona.direcciones(i) .cdet2ia, pdestinatario.persona.direcciones(i) .tnum2ia, pdestinatario.persona.direcciones(i) .cdet3ia, pdestinatario.persona.direcciones(i) .tnum3ia, pdestinatario.persona.direcciones(i) .localidad);
              END IF;
            END LOOP;
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;
  -- fin Bug 0020138 - JMF - 28/11/2011
  vpasexec                            := 15;
  IF pdestinatario.t_prestaren        IS NOT NULL THEN
    IF pdestinatario.t_prestaren.COUNT > 0 THEN
      FOR i IN pdestinatario.t_prestaren.FIRST .. pdestinatario.t_prestaren.LAST
      LOOP
        IF pdestinatario.t_prestaren(i).nmesextra IS NOT NULL THEN
          vpasexec                                := 20;
          vnmesextra                              := pk_rentas.f_llenarnmesesextra (pdestinatario.t_prestaren(i).nmesextra.nmes1, pdestinatario.t_prestaren(i).nmesextra.nmes2, pdestinatario.t_prestaren(i).nmesextra.nmes3, pdestinatario.t_prestaren(i).nmesextra.nmes4, pdestinatario.t_prestaren(i).nmesextra.nmes5, pdestinatario.t_prestaren(i).nmesextra.nmes6, pdestinatario.t_prestaren(i).nmesextra.nmes7, pdestinatario.t_prestaren(i).nmesextra.nmes8, pdestinatario.t_prestaren(i).nmesextra.nmes9, pdestinatario.t_prestaren(i).nmesextra.nmes10, pdestinatario.t_prestaren(i).nmesextra.nmes11, pdestinatario.t_prestaren(i).nmesextra.nmes12);
        ELSE
          vnmesextra := NULL;
        END IF;
        vpasexec := 25;
        vnumerr  := pac_siniestros.f_ins_prestacion(pdestinatario.t_prestaren(i).nsinies, pdestinatario.t_prestaren(i).ntramit, pdestinatario.t_prestaren(i).sperson, pdestinatario.t_prestaren(i).ctipdes, pdestinatario.t_prestaren(i).cforpag, pdestinatario.t_prestaren(i).ibruren, pdestinatario.t_prestaren(i).f1paren, pdestinatario.t_prestaren(i).npartot, pdestinatario.t_prestaren(i).npartpend, pdestinatario.t_prestaren(i).ctipdur,
        -- Ini bug 16924 - SRA - 11/01/2011
        --pdestinatario.ob_prestaren.ffinren,
        pdestinatario.t_prestaren(i).fuparen,
        -- Fin bug 16924 - SRA - 11/01/2011
        pdestinatario.t_prestaren(i).ctipban, pdestinatario.t_prestaren(i).cbancar, pdestinatario.t_prestaren(i).crevali, pdestinatario.t_prestaren(i).prevali, pdestinatario.t_prestaren(i).irevali, vnmesextra, pdestinatario.t_prestaren(i).cestado, pdestinatario.t_prestaren(i).cmotivo, pdestinatario.t_prestaren(i).cblopag, pdestinatario.t_prestaren(i).npresta); --JRH IMP Falta mes extra
      END LOOP;
    ELSE
      vpasexec := 30;
      vnumerr  := pac_siniestros.f_del_prestaren(pnsinies, pdestinatario.ntramit, pdestinatario.persona.sperson, pdestinatario.ctipdes, NULL);
    END IF;
  END IF;
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam);
  END IF;
  vpasexec := 35;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_destinatario;
/***********************************************************************
Funció que retorna una col·lecció de reserves amb els ultims moviments de cada una
param       preservas IN t_iax_sin_trami_reserva,   : col·lecció original
param       preservcalculada OUT t_iax_sin_trami_reserva : col·lecció resultant
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_objreservas_calc(
    preservas IN t_iax_sin_trami_reserva,
    preservcalculada OUT t_iax_sin_trami_reserva,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_objreservas_calc';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ';
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  v_index     NUMBER(10);
  vtreservas t_iax_sin_trami_reserva  := t_iax_sin_trami_reserva();
  afegir BOOLEAN                      := FALSE;
  vobreserva ob_iax_sin_trami_reserva := ob_iax_sin_trami_reserva();
  cont NUMBER                         := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF preservas IS NOT NULL AND preservas.COUNT > 0 THEN
    FOR i IN preservas.FIRST .. preservas.LAST
    LOOP
      afegir        := FALSE;
      cont          := 0;
      vobreserva    := preservas(i);
      IF vtreservas IS NOT NULL AND vtreservas.COUNT > 0 THEN
        FOR j IN vtreservas.FIRST .. vtreservas.LAST
        LOOP
          IF vtreservas.EXISTS(j) THEN
            afegir                           := FALSE;
            IF NVL(vtreservas(j).ctipres, -1) = NVL(vobreserva.ctipres, -1) AND NVL(vtreservas(j).cgarant, -1) = NVL(vobreserva.cgarant, -1)
              -- Bug 14490 - 14/05/2010 - AMC
              AND vtreservas(j).fresini = vobreserva.fresini
              -- Fi Bug 14490 - 14/05/2010 - AMC
              THEN
              IF NVL(vtreservas(j).nmovres, -1) < NVL(vobreserva.nmovres, -1) THEN
                vtreservas.DELETE(j);
                afegir := TRUE;
              END IF;
            ELSE
              cont := cont + 1;
            END IF;
          END IF;
        END LOOP;
        IF afegir = TRUE OR cont = vtreservas.COUNT THEN
          vtreservas.EXTEND;
          v_index             := vtreservas.LAST;
          vtreservas(v_index) := vobreserva;
        END IF;
      ELSE
        vtreservas.EXTEND;
        v_index             := vtreservas.LAST;
        vtreservas(v_index) := vobreserva;
      END IF;
    END LOOP;
  END IF;
  preservcalculada := vtreservas;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_objreservas_calc;
/***********************************************************************
graba la colección de reservas
param in  pnsinies  : número de siniestro
param in  t_iax_sin_trami_reserva :  t_iax_sin_trami_reserva
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_reservas(
    pnsinies  IN VARCHAR2,
    preservas IN t_iax_sin_trami_reserva,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_reservas';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF preservas IS NOT NULL AND preservas.COUNT > 0 THEN
    FOR i IN preservas.FIRST .. preservas.LAST
    LOOP
      IF preservas.EXISTS(i) THEN
        vnumerr    := f_set_reserva(pnsinies, preservas(i), mensajes);
        IF vnumerr <> 0 THEN
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_reservas;
/***********************************************************************
GRABA los datos de un determinado reserva
param in  pnsinies  : número de siniestro
param IN  ob_iax_sin_trami_reserva :  ob_iax_sin_trami_reserva
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_reserva(
    pnsinies IN VARCHAR2,
    preserva IN ob_iax_sin_trami_reserva,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_SET_reserva';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  vnmovres    NUMBER(5);
  vcmonresint VARCHAR2(20);
  vtmonres    VARCHAR2(500);
BEGIN
  vnmovres    := preserva.nmovres;
  vcmonresint := preserva.cmonres;
  -- Bug 11945 - 16/12/2009 - AMC
  vnumerr := pac_siniestros.f_ins_reserva(pnsinies, preserva.ntramit, preserva.ctipres, preserva.cgarant, preserva.ccalres, preserva.fmovres, vcmonresint, preserva.ireserva, preserva.ipago, preserva.icaprie, preserva.ipenali, preserva.iingreso, preserva.irecobro, preserva.fresini, preserva.fresfin, preserva.fultpag, preserva.sidepag, preserva.iprerec, preserva.ctipgas, vnmovres, preserva.cmovres,
  --0031294/0174788:NSS:26/05/2014
  preserva.ifranq,
  --Bug 27059:
  preserva.ndias
  --Bug 27487/159742:NSS.26/11/2013
  , preserva.itotimp, preserva.itotret,
  -- 24637/0147756:NSS:20/03/2014
  preserva.iva_ctipind,
  -- 24637/0147756:NSS:20/03/2014
  preserva.retenc_ctipind,
  -- 24637/0147756:NSS:20/03/2014
  preserva.reteiva_ctipind,
  -- 24637/0147756:NSS:20/03/2014
  preserva.reteica_ctipind,-- 24637/0147756:NSS:20/03/2014
  null,
  preserva.csolidaridad -- CONF-431 IGIL
  );
  --Fi Bug 11945 - 16/12/2009 - AMC
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_reserva;
/***********************************************************************
graba la colección de reservas
param in  pnsinies  : número de siniestro
param in  t_iax_sin_trami_reserva :  t_iax_sin_trami_reserva
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_referencias(
    pnsinies     IN VARCHAR2,
    preferencias IN t_iax_siniestro_referencias,
    mensajes     IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_referencias';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF preferencias IS NOT NULL AND preferencias.COUNT > 0 THEN
    FOR i IN preferencias.FIRST .. preferencias.LAST
    LOOP
      vnumerr    := f_set_referencia(pnsinies, preferencias(i), mensajes);
      IF vnumerr <> 0 THEN
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
        RETURN vnumerr;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_referencias;
/***********************************************************************
GRABA los datos de un determinado reserva
param in  pnsinies  : número de siniestro
param IN  ob_iax_sin_trami_reserva :  ob_iax_sin_trami_reserva
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_referencia(
    pnsinies    IN VARCHAR2,
    preferencia IN ob_iax_siniestro_referencias,
    mensajes    IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_SET_referencia';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  vnmovres    NUMBER(5);
BEGIN
  vnumerr := pac_siniestros.f_ins_referencia(pnsinies, preferencia.srefext, preferencia.ctipref, preferencia.trefext, preferencia.frefini, preferencia.freffin);
  --Fi Bug 11945 - 16/12/2009 - AMC
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_referencia;
/***********************************************************************
graba la colección de citaciones por una tramitación
param in  pnsinies  : número de siniestro
param in  t_iax_sin_trami_citaciones :  t_iax_sin_trami_citaciones
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_citaciones(
    pnsinies    IN VARCHAR2,
    pcitaciones IN t_iax_sin_trami_citaciones,
    mensajes    IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_SET_citaciones';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pcitaciones.COUNT > 0 THEN
    FOR i IN pcitaciones.FIRST .. pcitaciones.LAST
    LOOP
      -- Inicio IAXIS_2066 AABC 19/03/2019 cambio de modulo de consulta de siniestros
      IF pcitaciones(i).ncitacion IS NOT NULL THEN
      vnumerr            := f_set_citacion(pnsinies, pcitaciones(i), mensajes);
      END IF;
      -- Fin IAXIS_2066 AABC 19/03/2019 cambio de modulo de consulta de siniestros
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_citaciones;
/***********************************************************************
graba los datos de una determinada citacion
param in  pnsinies  : número de siniestro
param in  ob_iax_sin_trami_citacion :  ob_iax_sin_trami_citacion
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_citacion(
    pnsinies  IN VARCHAR2,
    pcitacion IN ob_iax_sin_trami_citacion,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_citacion';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vnerror     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  v_ctipage  NUMBER;
  v_cagente  NUMBER;
  vcempres   NUMBER;
  vcidioma   NUMBER;
  vidapunte  NUMBER;
  vusuari    VARCHAR2(20);
  vctramitad VARCHAR2(20);
BEGIN
  RETURN pac_siniestros.f_ins_citacion(pnsinies   => pnsinies,
                                       pntramit   => pcitacion.ntramit,
                                       pncitacion => pcitacion.ncitacion,
                                       psperson   => pcitacion.persona.sperson,
                                       pfcitacion => pcitacion.fcitacion,
                                       phcitacion => pcitacion.hcitacion,
                                       pcpais     => pcitacion.cpais,
                                       pcprovin   => pcitacion.cprovin,
                                       pcpoblac   => pcitacion.cpoblac,
                                       ptlugar    => pcitacion.tlugar,
                                       ptaudien   => pcitacion.TAUDIEN,
                                       pcoral     => pcitacion.CORAL,
                                       pcestado   => pcitacion.CESTADO,
                                       pcresolu   => pcitacion.CRESOLU,
                                       pfnueva    => pcitacion.FNUEVA,
                                       ptresult   => pcitacion.TRESULT,
                                       pcmedio    => pcitacion.CMEDIO);
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_citacion;
/***********************************************************************
graba la colección de tramitaciones por una tramitación
param in  pnsinies  : número de siniestro
param in  t_iax_sin_trami_localiza :  t_iax_sin_trami_localiza
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_localizaciones(
    pnsinies        IN VARCHAR2,
    plocalizaciones IN t_iax_sin_trami_localiza,
    mensajes        IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_SET_localizaciones';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF plocalizaciones.COUNT > 0 THEN
    FOR i IN plocalizaciones.FIRST .. plocalizaciones.LAST
    LOOP
      vnumerr            := f_set_localiza(pnsinies, plocalizaciones(i), mensajes);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_localizaciones;
/***********************************************************************
graba los datos de una determinada localizacion
param in  pnsinies  : número de siniestro
param in  ob_iax_sin_trami_localiza :  ob_iax_sin_trami_localiza
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
-- Bug 20154/98048 - 15/11/2011 - AMC
***********************************************************************/
FUNCTION f_set_localiza(
    pnsinies  IN VARCHAR2,
    plocaliza IN ob_iax_sin_trami_localiza,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_localiza';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  --ob_iax_sin_trami_localiza
  vnumerr := pac_siniestros.f_ins_localiza (pnsinies, plocaliza.ntramit, plocaliza.nlocali, plocaliza.sperson, plocaliza.csiglas, plocaliza.tnomvia, plocaliza.nnumvia, plocaliza.tcomple, plocaliza.tlocali, plocaliza.cpais, plocaliza.cprovin, plocaliza.cpoblac, plocaliza.cpostal,
  -- Bug 20154/98048 - 15/11/2011 - AMC
  plocaliza.cviavp, plocaliza.clitvp, plocaliza.cbisvp, plocaliza.corvp, plocaliza.nviaadco, plocaliza.clitco, plocaliza.corco, plocaliza.nplacaco, plocaliza.cor2co, plocaliza.cdet1ia, plocaliza.tnum1ia, plocaliza.cdet2ia, plocaliza.tnum2ia, plocaliza.cdet3ia, plocaliza.tnum3ia,
  -- Fi Bug 20154/98048 - 15/11/2011 - AMC
  plocaliza.localidad -- Bug 24780/130907 - 10/12/2012 - AMC
  );
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_localiza;
/***********************************************************************
graba la colección de pagos o recobros, dependiendo del ctippag
param in  pnsinies  : número de siniestro
param in  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_pagrecobs(
    pnsinies   IN VARCHAR2,
    ppagrecobs IN t_iax_sin_trami_pago,
    psidepag   IN NUMBER, -- BUG 25537 - FAL - 04/02/2014
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_pagrecobs';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF ppagrecobs.COUNT > 0 THEN
    FOR i IN ppagrecobs.FIRST .. ppagrecobs.LAST
    LOOP
      IF ppagrecobs(i).sidepag = psidepag THEN -- BUG 25537 - FAL - 04/02/2014. Tratamiento único del pago. Y no de todos los pagos del siniestro.
        vnumerr               := f_set_pagrecob(pnsinies, ppagrecobs(i), mensajes);
      END IF;
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_pagrecobs;
/***********************************************************************
Recupera los datos de un pago / recobro
param in  pnsinies  : número de siniestro
param in  ppagrecob :  ob_iax_sin_trami_pago
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
-- Bug 11847 - 23/11/2009 - AMC
-- BUG 19981 - 07/11/2011 - MDS - Añadir campos ireteiva, ireteica, ireteivapag, ireteicapag, iica, iicapag en el type ob_iax_sin_trami_pago
***********************************************************************/
FUNCTION f_set_pagrecob(
    pnsinies  IN VARCHAR2,
    ppagrecob IN ob_iax_sin_trami_pago,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_pagrecob';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  vsidepag NUMBER;
  -- BUG 25537 - FAL - 11/04/2014
  v_mov_pago_procesado NUMBER := 0;
  v_pago_creado        NUMBER := 0;
  -- FI BUG 25537 - FAL - 11/04/2014
BEGIN
  vpasexec := 1;
  vsidepag := ppagrecob.sidepag;
  -- BUG 25537 - FAL - 11/04/2014 - Si pago ya creado, primero inserta movimiento. Sinó, calcularia contravalor al estado anterior
  v_mov_pago_procesado := 0;
  v_pago_creado        := 0;
  SELECT COUNT(1)
  INTO v_pago_creado
  FROM sin_tramita_pago
  WHERE sidepag    = vsidepag;
  IF v_pago_creado = 1 AND NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'CONTRAVALOR_ACTUAL'), 0) = 1 THEN
    vnumerr       := f_set_movpagos(vsidepag, ppagrecob.movpagos, mensajes);
    IF vnumerr    <> 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
      RAISE e_object_error;
    END IF;
    v_mov_pago_procesado := 1;
  END IF;
  -- FI BUG 25537 - FAL - 11/04/2014
  vpasexec := 3;
  vnumerr  := pac_siniestros.f_ins_pago (vsidepag, pnsinies, ppagrecob.ntramit, ppagrecob.destinatari.persona.sperson, ppagrecob.destinatari.ctipdes, ppagrecob.ctippag, ppagrecob.cconpag, ppagrecob.ccauind, ppagrecob.cforpag, ppagrecob.fordpag, ppagrecob.ctipban, ppagrecob.cbancar, ppagrecob.isinret, ppagrecob.iretenc, ppagrecob.iiva, ppagrecob.isuplid, ppagrecob.ifranq, ppagrecob.iresrcm, ppagrecob.iresred, ppagrecob.nfacref, ppagrecob.ffacref, ppagrecob.sidepagtemp, ppagrecob.cultpag, ppagrecob.ncheque,
  -- BUG 19981 - 07/11/2011 - MDS
  ppagrecob.ireteiva, ppagrecob.ireteica, ppagrecob.ireteivapag, ppagrecob.ireteicapag, ppagrecob.iica, ppagrecob.iicapag, ppagrecob.cmonres,
  -- BUG 18423/104212 - 03/02/2012 - JMP - Multimoneda
  ppagrecob.cagente,
  -- Bug 22256/122456 - 28/09/2012 - AMC
  ppagrecob.npersrel, ppagrecob.cdomici, ppagrecob.ctributacion, ppagrecob.cbanco,
  -- Bug 24708/155502 - 10/10/2013 - NSS
  ppagrecob.cofici,
  -- Bug 24708/155502 - 10/10/2013  - NSS
  ppagrecob.cciudad,
  -- Bug 29224/166661 - 24/02/2014 - NSS
  ppagrecob.presentador.sperson, ppagrecob.tobserva, ppagrecob.iotrosgas, ppagrecob.iotrosgaspag, ppagrecob.ibaseipoc, ppagrecob.ibaseipocpag, ppagrecob.iipoconsumo, ppagrecob.iipoconsumopag);
  -- Bug 18878 - 28/06/2011 - AMC
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  -- Fi Bug 18878 - 28/06/2011 - AMC
  vpasexec := 5;
  -- BUG 25537 - FAL - 11/04/2014 - Si movimiento no procesado, inserta movimiento pago
  IF v_mov_pago_procesado = 0 THEN
    vnumerr              := f_set_movpagos(vsidepag, ppagrecob.movpagos, mensajes);
    IF vnumerr           <> 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
      RAISE e_object_error;
    END IF;
  END IF;
  -- FI BUG 25537 - FAL - 11/04/2014
  -- BUG 25537 - FAL - 11/04/2014 - Se comenta este codigo
  /*
  -- BUG 25537 - FAL - 05/02/2014. Re-procesa pago para cálculo contravalor a fecha actual si aceptado, posterior a insertar el movimiento
  IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
  'CONTRAVALOR_ACTUAL'),
  0) = 1 THEN
  vnumerr :=
  pac_siniestros.f_ins_pago
  (vsidepag, pnsinies, ppagrecob.ntramit,
  ppagrecob.destinatari.persona.sperson, ppagrecob.destinatari.ctipdes,
  ppagrecob.ctippag, ppagrecob.cconpag, ppagrecob.ccauind,
  ppagrecob.cforpag, ppagrecob.fordpag, ppagrecob.ctipban,
  ppagrecob.cbancar, ppagrecob.isinret, ppagrecob.iretenc,
  ppagrecob.iiva, ppagrecob.isuplid, ppagrecob.ifranq,
  ppagrecob.iresrcm, ppagrecob.iresred, ppagrecob.nfacref,
  ppagrecob.ffacref, ppagrecob.sidepagtemp, ppagrecob.cultpag,
  -- BUG 19981 - 07/11/2011 - MDS
  ppagrecob.ireteiva, ppagrecob.ireteica, ppagrecob.ireteivapag,
  ppagrecob.ireteicapag, ppagrecob.iica, ppagrecob.iicapag,
  ppagrecob.cmonres,   -- BUG 18423/104212 - 03/02/2012 - JMP - Multimoneda
  ppagrecob.cagente,   -- Bug 22256/122456 - 28/09/2012 - AMC
  ppagrecob.npersrel, ppagrecob.cdomici, ppagrecob.ctributacion,
  ppagrecob.cbanco,   -- Bug 24708/155502 - 10/10/2013 - NSS
  ppagrecob.cofici,   -- Bug 24708/155502 - 10/10/2013  - NSS
  ppagrecob.cciudad   -- Bug 29224/166661 - 24/02/2014 - NSS
  );
  IF vnumerr <> 0 THEN
  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
  RAISE e_object_error;
  END IF;
  END IF;
  -- FI BUG 25537 - FAL - 05/02/2014
  */
  -- FI BUG 25537 - FAL - 11/04/2014
  vpasexec   := 7;
  vnumerr    := f_set_pagrecobs_gars(pnsinies, ppagrecob.ntramit, vsidepag, ppagrecob.pagogar, mensajes);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  vpasexec := 9;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam || ' ' || vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam || ' ' || vnumerr, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_pagrecob;
/***********************************************************************
graba la colección de pagos o recobros, dependiendo del ctippag
param in  pnsinies  : número de siniestro
param in  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_pagrecobs_gars(
    pnsinies      IN VARCHAR2,
    pntramit      IN NUMBER,
    psidepag      IN NUMBER,
    ppagrecobsgar IN t_iax_sin_trami_pago_gar,
    mensajes      IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_pagrecobs_gar';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psidepag IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF ppagrecobsgar.COUNT > 0 THEN
    FOR i IN ppagrecobsgar.FIRST .. ppagrecobsgar.LAST
    LOOP
      vnumerr            := f_set_pagrecobgar(pnsinies, pntramit, psidepag, ppagrecobsgar(i), mensajes);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_pagrecobs_gars;
/***********************************************************************
Recupera los datos de un pago / recobro
param in  pnsinies  : número de siniestro
param in  ob_iax_sin_trami_pago :  ob_iax_sin_trami_pago
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
-- BUG 19981 - 07/11/2011 - MDS - Añadir campos preteiva, preteica, ireteiva, ireteica, ireteivapag, ireteicapag, pica, iica, iicapag en el type ob_iax_sin_trami_pago_gar
***********************************************************************/
FUNCTION f_set_pagrecobgar(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    psidepag  IN NUMBER,
    ppagrecob IN ob_iax_sin_trami_pago_gar,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_pagrecob_gar';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  vsidepag NUMBER;
BEGIN
  --vsidepag := ppagrecob.sidepag;
  vnumerr := pac_siniestros.f_ins_pago_gar (pnsinies, pntramit, psidepag, ppagrecob.reserva.ctipres, ppagrecob.reserva.nmovres, ppagrecob.reserva.cgarant, ppagrecob.fperini, ppagrecob.fperfin, ppagrecob.cmonres, ppagrecob.isinret, ppagrecob.iiva, ppagrecob.isuplid, ppagrecob.iretenc, ppagrecob.ifranq, ppagrecob.iresrcm, ppagrecob.iresred, ppagrecob.pretenc, ppagrecob.piva, ppagrecob.cmonpag, ppagrecob.isinretpag, ppagrecob.iivapag, ppagrecob.isuplidpag, ppagrecob.iretencpag, ppagrecob.ifranqpag, ppagrecob.fcambio, ppagrecob.cconpag, ppagrecob.norden,
  -- BUG 19981 - 07/11/2011 - MDS
  ppagrecob.preteiva, ppagrecob.preteica, ppagrecob.ireteiva, ppagrecob.ireteica, ppagrecob.ireteivapag, ppagrecob.ireteicapag, ppagrecob.pica, ppagrecob.iica, ppagrecob.iicapag, ppagrecob.piva_ctipind,
  --bug 24637/147756:NSS:03/03/2014
  ppagrecob.pretenc_ctipind,
  --bug 24637/147756:NSS:03/03/2014
  ppagrecob.preteiva_ctipind,
  --bug 24637/147756:NSS:03/03/2014
  ppagrecob.preteica_ctipind,
  --bug 24637/147756:NSS:03/03/2014
  ppagrecob.iotrosgas, ppagrecob.iotrosgaspag, ppagrecob.ibaseipoc, ppagrecob.ibaseipocpag, ppagrecob.pipoconsumo, ppagrecob.iipoconsumo, ppagrecob.iipoconsumo);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_pagrecobgar;
/***********************************************************************
graba la colección de movimientos de pagos o recobros, dependiendo del ctippag
param in  psidepag  : número de pago
param out  t_iax_sin_trami_movpago :  t_iax_sin_trami_movpago
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_movpagos(
    psidepag  IN NUMBER,
    pmovpagos IN t_iax_sin_trami_movpago,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_movpagos';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psidepag IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pmovpagos.COUNT > 0 THEN
    FOR i IN pmovpagos.FIRST .. pmovpagos.LAST
    LOOP
      vnumerr            := f_set_movpago(psidepag, pmovpagos(i), mensajes);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_movpagos;
/***********************************************************************
graba los datos de movimiento de pago / recobro
param in  sidepag  : número tipo pago
param out  ob_iax_sin_trami_movpago :  ob_iax_sin_trami_movpago
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_movpago(
    psidepag IN NUMBER,
    pmovpag  IN ob_iax_sin_trami_movpago,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_movpago';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vnmovpag    NUMBER(8);
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  vnmovpag := pmovpag.nmovpag;
  -- Bug 13312 - 08/03/2010 - AMC
  vnumerr := pac_siniestros.f_ins_movpago(psidepag, 
                                          pmovpag.cestpag, 
                                          pmovpag.fefepag, 
                                          pmovpag.cestval, 
                                          pmovpag.fcontab, 
                                          pmovpag.sproces, 
                                          pmovpag.cestpagant, 
                                          vnmovpag, 
                                          pmovpag.csubpag, 
                                          pmovpag.csubpagant,
                                          pmovpag.ndocpag); -- IAXIS-7731 19/12/2019
  --Bug:19601 - 13/10/2011 - JMC
  -- Fi Bug 13312 - 08/03/2010 - AMC
  -- ini Bug 0018812 - 21/06/2011 - JMF
  IF vnumerr = 0 THEN
    DECLARE
      v_des VARCHAR2(500);
      v_lit VARCHAR2(500);
    BEGIN
      vnumerr  := pac_md_siniestros.f_get_mensaje_polrenta(psidepag, 2, v_des);
      IF v_des IS NOT NULL THEN
        v_lit  := pac_iobj_mensajes.f_get_descmensaje(800242, pac_md_common.f_get_cxtidioma);
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, v_lit || ' ' || v_des);
      END IF;
      vnumerr := 0;
    END;
  END IF;
  -- fin Bug 0018812 - 21/06/2011 - JMF
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_movpago;
/***********************************************************************
retorna el tramitador i la unitat tramitadora per defecte
pcempres IN  NUMBER,
pcunitra OUT VARCHAR2,
pctramit OUT VARCHAR2,
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_unitradefecte(
    pcempres IN NUMBER,
    pcunitra OUT VARCHAR2,
    pctramit OUT VARCHAR2,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_unitradefecte';
  vparam      VARCHAR2(500) := 'parámetros - pcempres: ' || pcempres;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vnmovpag    NUMBER(8);
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  vnumerr    := pac_siniestros.f_get_unitradefecte(pcempres, pcunitra, pctramit);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_unitradefecte;
/***********************************************************************
Retorna las causas de un siniestro
param  in  pcempres :  código de la empresa
param  in  pcramo  : código del ramo
param  in  psproduc   : código del producto
param  in  pccausin   : código de la causa del siniestro
param  in  pcmotsin   : código motivo de siniestro
param  in  pctipdes : código tipo destinatario
param out mensajes  : mensajes de error
return              : sys_refcursor
21/05/2009   AMC                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_get_causas_motivos(
    pcempres IN NUMBER,
    pcramo   IN NUMBER,
    psproduc IN NUMBER,
    pccausin IN NUMBER,
    pcmotsin IN NUMBER,
    pctipdes IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_get_causas_motivos';
  vparam      VARCHAR2(500)  := 'parámetros - pcempres:' || pcempres || ' pcramo:' || pcramo || ' psproduc:' || ' pccausin:' || pccausin || ' pcmotsin:' || pcmotsin || ' pctipdes:' || pctipdes;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vquery      VARCHAR2(2000) := ' and 1=1';
  vquery2     VARCHAR2(2000);
BEGIN
  IF pccausin IS NOT NULL THEN
    vquery    := ' and s.ccausin =' || pccausin;
  END IF;
  IF pcmotsin IS NOT NULL THEN
    vquery    := vquery || ' and s.CMOTSIN =' || pcmotsin;
  END IF;
  IF pctipdes IS NOT NULL THEN
    vquery    := vquery || ' and sd.CTIPDES =' || pctipdes;
  END IF;
  IF pcempres IS NOT NULL THEN
    vquery    := vquery || ' and c.CEMPRES = ' || pcempres;
  END IF;
  IF psproduc IS NOT NULL THEN
    vquery    := vquery || ' and sg.SPRODUC = ' || psproduc;
  END IF;
  IF pcramo IS NOT NULL THEN
    vquery  := vquery || ' and c.cramo = ' || pcramo;
  END IF;
  -- Bug 12753 - 18/01/2010 - AMC - Se añade el campo cdesaut
  vquery2 := 'select distinct(s.scaumot),si.TCAUSIN,s.cmotsin,sdm.TMOTSIN,' || ' s.cmotmov,(select tmotmov from motmovseg where cmotmov = s.cmotmov and cidioma = si.cidioma ) tmotmov,' || ' s.cmovimi,FF_DESVALORFIJO(83,' || pac_md_common.f_get_cxtidioma() || ',s.cmovimi) tmovimi,' || ' s.cmotfin,' || ' (select tmotmov from motmovseg where cmotmov = s.cmotfin and cidioma = si.cidioma ) tmotfin,' || ' s.cpagaut,s.CDESAUT ' || ' from sin_causa_motivo s,sin_det_causa_motivo sd,sin_descausa  si,sin_desmotcau sdm,' || ' sin_gar_causa_motivo sg,' || ' (select cr.cramo,cr.cempres,p.sproduc' || ' from codiram cr, productos p' || ' where cr.cramo = p.cramo) c' || ' where si.CCAUSIN = s.CCAUSIN  and si.CIDIOMA = ' || pac_md_common.f_get_cxtidioma() || ' and s.scaumot = sd.scaumot(+)' || ' and s.CMOTSIN = sdm.CMOTSIN    and s.CCAUSIN = sdm.CCAUSIN' || ' and sdm.CIDIOMA = si.CIDIOMA ' || ' and sg.SCAUMOT(+) = s.SCAUMOT  and c.SPRODUC(+) = sg.SPRODUC' || vquery || ' order by s.scaumot asc';
  --Fi Bug 12753 - 18/01/2010 - AMC - Se añade el campo cdesaut
  cur := pac_md_listvalores.f_opencursor(vquery2, mensajes);
  RETURN cur;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
END f_get_causas_motivos;
/***********************************************************************
Retorna los destinatarios de un siniestro
param  in  pscaumot :  código de la causa
param  in  pctipdes  : código del tipo de destinatario
param out mensajes  : mensajes de error
return              : sys_refcursor
21/05/2009   AMC                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_get_caumot_destinatario(
    pscaumot IN NUMBER,
    pctipdes IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_get_caumot_destinatario';
  vparam      VARCHAR2(500)  := 'parámetros - pscaumot:' || pscaumot || ' pctipdes:' || pctipdes;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vquery      VARCHAR2(2000) := ' where 1=1';
BEGIN
  IF pscaumot IS NOT NULL THEN
    vquery    := ' where sd.scaumot = ' || pscaumot;
  END IF;
  IF pctipdes IS NOT NULL THEN
    vquery    := vquery || ' and sd.CTIPDES = ' || pctipdes;
  END IF;
  cur := pac_md_listvalores.f_opencursor('select sd.scaumot,sd.ctipdes,' || ' FF_DESVALORFIJO(328,' || pac_md_common.f_get_cxtidioma() || ',sd.ctipdes) tctipdes,' || ' sd.cmodfis,' || ' FF_DESVALORFIJO(320,' || pac_md_common.f_get_cxtidioma() || ',sd.cmodfis) tmodfis' || ' from sin_det_causa_motivo sd ' || vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
END f_get_caumot_destinatario;
/***********************************************************************
Retorna las formulas
param  in  pscaumot :  código de la causa
param  in  pctipdes  : código del tipo de destinatario
param  in  pccampo  : código del campo
param  in  pcclave  : código de la formula
param out mensajes  : mensajes de error
return              : sys_refcursor
22/05/2009   AMC                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_get_caumot_destformula(
    pscaumot IN NUMBER,
    pctipdes IN NUMBER,
    pccampo  IN VARCHAR2,
    pcclave  IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_get_caumot_destformula';
  vparam      VARCHAR2(500)  := 'parámetros - pscaumot:' || pscaumot || ' pctipdes:' || pctipdes || ' pccampo:' || pccampo || ' pcclave:' || pcclave;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vquery      VARCHAR2(2000) := ' and 1=1 ';
BEGIN
  IF pscaumot IS NOT NULL THEN
    vquery    := ' and s.scaumot = ' || pscaumot;
  END IF;
  IF pctipdes IS NOT NULL THEN
    vquery    := vquery || ' and s.CTIPDES = ' || pctipdes;
  END IF;
  IF pccampo IS NOT NULL THEN
    vquery   := vquery || ' and s.ccampo = ' || pccampo;
  END IF;
  IF pcclave IS NOT NULL THEN
    vquery   := vquery || ' and s.cclave = ' || pcclave;
  END IF;
  cur := pac_md_listvalores.f_opencursor ('select s.scaumot,s.ctipdes,s.ccampo,s.cclave,f.DESCRIPCION,c.TCAMPO' || ' from sin_for_causa_motivo s,sgt_formulas f,codcampo c ' || 'where s.CCLAVE = f.CLAVE and c.CCAMPO = s.CCAMPO' || vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
END f_get_caumot_destformula;
/***********************************************************************
Retorna los productos
param  in  pscaumot :  código de la causa
param  in  psproduc  : código del producto
param  in  pcactivi  : código de la actividad
param  in  pcgarant  : código de la garantia
param  in  pctramit  : código de la tramitación
param out mensajes  : mensajes de error
return              : sys_refcursor
22/05/2009   AMC                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_get_caumot_producte(
    pscaumot IN NUMBER,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pcgarant IN NUMBER,
    pctramit IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_get_caumot_producte';
  vparam      VARCHAR2(500)  := 'parámetros - pscaumot:' || pscaumot || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant || ' pctramit:' || pctramit;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vquery      VARCHAR2(2000) := ' and 1=1';
BEGIN
  IF pscaumot IS NOT NULL THEN
    vquery    := ' and s.scaumot = ' || pscaumot;
  END IF;
  IF psproduc IS NOT NULL THEN
    vquery    := vquery || ' and s.SPRODUC = ' || psproduc;
  END IF;
  IF pcactivi IS NOT NULL THEN
    vquery    := vquery || ' and s.CACTIVI = ' || pcactivi;
  END IF;
  IF pctramit IS NOT NULL THEN
    vquery    := vquery || ' and s.CTRAMIT = ' || pctramit;
  END IF;
  IF psproduc IS NOT NULL THEN
    vquery    := vquery || ' and s.SPRODUC = ' || psproduc;
  END IF;
  IF pcgarant IS NOT NULL THEN
    vquery    := vquery || ' and s.CGARANT = ' || pcgarant;
  END IF;
  cur := pac_md_listvalores.f_opencursor ('select s.scaumot,s.sproduc,p.TTITULO tproducto,s.cactivi,a.TTITULO tactividad,' || ' s.cgarant,FF_DESGARANTIA(s.cgarant,a.cidioma) tgarantia,' || ' s.ctramit,t.TTRAMIT ttramitacion' || ' from sin_gar_causa_motivo s,titulopro p,activisegu a,sin_destramitacion t,productos pr' || ' where  s.SPRODUC = pr.SPRODUC' || ' and a.CIDIOMA =' || pac_md_common.f_get_cxtidioma() || ' and a.CRAMO = p.CRAMO  and a.CACTIVI = s.CACTIVI' || ' and t.CTRAMIT = s.CTRAMIT  and t.CIDIOMA = a.CIDIOMA ' || ' and pr.CRAMO = p.CRAMO and p.CCOLECT = pr.CCOLECT' || ' and p.CMODALI = pr.CMODALI and p.CTIPSEG = pr.CTIPSEG' || ' and p.CIDIOMA = a.CIDIOMA ' || vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN NULL;
END f_get_caumot_producte;
/***********************************************************************
Inserta o actualiza en sin_causa_motivo
param  in  pscaumot : código de la causa/motivo
param  in  pccausin : código de la causa del siniestro
param  in  pcmotsin : código del motivo del siniestro
param  in  pcpagaut : si los pagos son automaticos
param  in  pcmotmov : código motivo del movimiento
param  in  pcmotfin : código motivo movimiento fin
param  in  pcmovimi : código motivo movimiento inicial
param  in  pcdesaut : si genera destinatario automaticamente
param  in  pcultpag: Pago se crea marcado como último pago
param  out mensajes : mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
25/05/2009   AMC                 Sinistres.  Bug: 8816
Bug 12753     18/01/2010  AMC Se añade el parametro pcdesaut
-- Bug 0022490 - 09/07/2012 - JMF: añadir pcultpag
***********************************************************************/
FUNCTION f_set_sin_causa_motivo(
    pscaumot IN NUMBER,
    pccausin IN NUMBER,
    pcmotsin IN NUMBER,
    pcpagaut IN NUMBER,
    pcmotmov IN NUMBER,
    pcmotfin IN NUMBER,
    pcmovimi IN NUMBER,
    pcdesaut IN NUMBER,
    pcultpag IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := 'paràmetres - pscaumot: ' || pscaumot || ' pccausin:' || pccausin || ' pcmotsin:' || pcmotsin || ' pcpagaut:' || pcpagaut || ' pcmotmov:' || pcmotmov || ' pcmotfin:' || pcmotfin || ' pcmovimi:' || pcmovimi || ' pcdesaut:' || pcdesaut || ' pcultpag=' || pcultpag;
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_set_sin_causa_motivo';
  vnumerr     NUMBER(10)    := 0;
BEGIN
  -- Comprovació pas de paràmetres
  IF pscaumot IS NULL OR pccausin IS NULL OR pcmotsin IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_set_sin_causa_motivo(pscaumot, pccausin, pcmotsin, pcpagaut, pcmotmov, pcmotfin, pcmovimi, pcdesaut, pcultpag);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_sin_causa_motivo;
/***********************************************************************
Recupera un registro de sin_causa_motivo
param  in  pscaumot : código de la causa/motivo
param  out  pccausin : código de la causa del siniestro
param  out  pcmotsin : código del motivo del siniestro
param  out  pcpagaut : si los pagos son automaticos
param  out  pcmotmov : código motivo del movimiento
param  out  pcmotfin : código motivo movimiento fin
param  out  pcmovimi : código motivo movimiento inicial
param  out  pcdesaut : si genera destinatario automaticamente
param  out  pcultpag : Pago se crea marcado como último pago
return              : 0 -> Tot correcte
1 -> S'ha produit un error
26/05/2009   AMC                 Sinistres.  Bug: 8816
Bug 12753     18/01/2010  AMC Se añade el parametro pcdesaut
-- Bug 0022490 - 09/07/2012 - JMF: añadir pcultpag
***********************************************************************/
FUNCTION f_get_caumot(
    pscaumot IN NUMBER,
    pccausin OUT NUMBER,
    pcmotsin OUT NUMBER,
    pcpagaut OUT NUMBER,
    pcmotmov OUT NUMBER,
    pcmotfin OUT NUMBER,
    pcmovimi OUT NUMBER,
    pcdesaut OUT NUMBER,
    pcultpag OUT NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := 'paràmetres - pscaumot: ' || pscaumot;
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_get_caumot';
  vnumerr     NUMBER(10)    := 0;
BEGIN
  -- Comprovació pas de paràmetres
  IF pscaumot IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_get_caumot(pscaumot, pccausin, pcmotsin, pcpagaut, pcmotmov, pcmotfin, pcmovimi, pcdesaut, pcultpag);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_caumot;
/***********************************************************************
Guarda a la taula una nova conf. per el producte
param  in  pscaumot :  código de la causa
param  in  psproduc  : código del producto
param  in  pcactivi  : código de la actividad
param  in  pcgarant  : código de la garantia
param  in  pctramit  : código de la tramitación
param out mensajes  : mensajes de error
return              : NUMBER
26/05/2009   XPL                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_set_caumot_producte(
    pscaumot IN NUMBER,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pcgarant IN NUMBER,
    pctramit IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_caumot_producte';
  vparam      VARCHAR2(500) := 'parámetros - pscaumot:' || pscaumot || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant || ' pctramit:' || pctramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pscaumot IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_set_caumot_producte(pscaumot, psproduc, pcactivi, pcgarant, pctramit);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_caumot_producte;
/***********************************************************************
Eliminar de la taula una conf. del producte
param  in  pscaumot :  código de la causa
param  in  psproduc  : código del producto
param  in  pcactivi  : código de la actividad
param  in  pcgarant  : código de la garantia
param  in  pctramit  : código de la tramitación
param out mensajes  : mensajes de error
return              : NUMBER
26/05/2009   XPL                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_del_caumot_producte(
    pscaumot IN NUMBER,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pcgarant IN NUMBER,
    pctramit IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_caumot_producte';
  vparam      VARCHAR2(500) := 'parámetros - pscaumot:' || pscaumot || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant || ' pctramit:' || pctramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pscaumot IS NULL THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_caumot_producte(pscaumot, psproduc, pcactivi, pcgarant, pctramit);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_caumot_producte;
/***********************************************************************
Grabar les formulas
param  in  pscaumot :  código de la causa
param  in  pctipdes  : código del tipo de destinatario
param  in  pccampo  : código del campo
param  in  pcclave  : código de la formula
param out mensajes  : mensajes de error
return              : sys_refcursor
26/05/2009   XPL                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_set_caumot_destformula(
    pscaumot IN NUMBER,
    pctipdes IN NUMBER,
    pccampo  IN VARCHAR2,
    pcclave  IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_caumot_destformula';
  vparam      VARCHAR2(500) := 'parámetros - pscaumot:' || pscaumot || ' pctipdes:' || pctipdes || ' pccampo:' || pccampo || ' pcclave:' || pcclave;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pscaumot IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_set_caumot_destformula(pscaumot, pctipdes, pccampo, pcclave);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_caumot_destformula;
/***********************************************************************
Eliminar de la taula una conf. formula
scaumot  IN  NUMBER,
pctipdes  IN  NUMBER,
pccampo   IN  VARCHAR2,
pcclave   IN  NUMBER,
param out mensajes  : mensajes de error
return              : NUMBER
26/05/2009   XPL                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_del_caumot_destformula(
    pscaumot IN NUMBER,
    pctipdes IN NUMBER,
    pccampo  IN VARCHAR2,
    pcclave  IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_caumot_destformula';
  vparam      VARCHAR2(500) := 'parámetros - pscaumot:' || pscaumot || ' pctipdes:' || pctipdes || ' pccampo:' || pccampo || ' pcclave:' || pcclave;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pscaumot IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_caumot_destformula(pscaumot, pctipdes, pccampo, pcclave);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_caumot_destformula;
/***********************************************************************
Grabar en sin_det_causa_motivo
param  in  pscaumot : código de la causa/motivo
param  in  pctipdes : código tipo destinatario
param  in  pcmodfis : código del modelo fiscal
param  out mensajes : mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
27/05/2009   AMC                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_set_sindetcausamot(
    pscaumot IN NUMBER,
    pctipdes IN NUMBER,
    pcmodfis IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_sindetcausamot';
  vparam      VARCHAR2(500) := 'parámetros - pscaumot:' || pscaumot || ' pctipdes:' || pctipdes || ' pcmodfis:' || pcmodfis;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pscaumot IS NULL OR pctipdes IS NULL OR pcmodfis IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_set_sindetcausamot(pscaumot, pctipdes, pcmodfis);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_sindetcausamot;
/***********************************************************************
Devuelve el siguiente codigo de causa/motivo
param  out  pscaumot : Próximo código de la causa/motivo
param  out  mensajes : Mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
27/05/2009   AMC                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_get_nextscaumot(
    pscaumot OUT NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := '';
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_get_nextscaumot';
  vnumerr     NUMBER(10)    := 0;
BEGIN
  vnumerr    := pac_siniestros.f_get_nextscaumot(pscaumot);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_nextscaumot;
/***********************************************************************
Eliminar de la taula sin_det_causa_motivo
param  in  pscaumot : código de la causa/motivo
param  in  pctipdes : código tipo destinatario
param  out  mensajes : Mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
27/05/2009   AMC                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_del_caumot_destinatario(
    pscaumot IN NUMBER,
    pctipdes IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := 'parámetros - pscaumot:' || pscaumot || ' pctipdes:' || pctipdes;
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_del_caumot_destinatario';
  vnumerr     NUMBER(10)    := 0;
BEGIN
  vnumerr    := pac_siniestros.f_del_caumot_destinatario(pscaumot, pctipdes);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_caumot_destinatario;
/***********************************************************************
Eliminar de la taula sin_det_causa_motivo
param  in  pscaumot : código de la causa/motivo
param  out  mensajes : Mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
28/05/2009   AMC                 Sinistres.  Bug: 8816
***********************************************************************/
FUNCTION f_del_caumot(
    pscaumot IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := 'parámetros - pscaumot:' || pscaumot;
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_del_caumot';
  vnumerr     NUMBER(10)    := 0;
BEGIN
  vnumerr    := pac_siniestros.f_del_caumot(pscaumot);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_caumot;
/***********************************************************************
FUNCTION F_ESTADO_TRAMITACION:
Cambia el estado de una tramitación
param in pnsinies : Número siniestro
param in pntramit : Número tramitación
param in pcesttra : Código estado
return            : 0 -> Tot correcte
1 -> S'ha produit un error
***********************************************************************/
FUNCTION f_estado_tramitacion(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pcesttra IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' - pntramit:' || pntramit || ' - pcesttra:' || pcesttra;
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_estado_tramitacion';
  vnumerr     NUMBER(10)    := 0;
BEGIN
  vnumerr    := pac_siniestros.f_estado_tramitacion(pnsinies, pntramit, pcesttra);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_estado_tramitacion;
/***********************************************************************
FUNCTION F_ESTADO_SINIESTRO:
Cambia el estado de un siniestro
param in  pnsinies   : Número Siniestro
param in pcestsin    : codi estat sinistre
param in pccauest    : codi causa estat sinistre
param in pcunitra    : codi unitat tramitació
param in pctramitad  : codi tramitador
param in pcsubtra    : codi subestat tramitació
param  out  mensajes : Mensajes de error
return               : 0 -> Tot correcte
1 -> S'ha produit un error
***********************************************************************/
FUNCTION f_estado_siniestro(
    pnsinies   IN VARCHAR2,
    pcestsin   IN NUMBER,
    pccauest   IN NUMBER,
    pcunitra   IN VARCHAR2,
    pctramitad IN VARCHAR2,
    pcsubtra   IN NUMBER,
    pfsinfin   IN DATE,
    porigen    IN VARCHAR2 DEFAULT NULL,
    pobserv    IN VARCHAR2 DEFAULT NULL, --IAXIS 3663 AABC 12/04/2019 Adicion campo observacion
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' - pcestsin:' || pcestsin || ' - pccauest:' || pccauest || ' - pcunitra:' || pcunitra || ' - pctramitad:' || pctramitad || ' - pcsubtra:' || pcsubtra || ' - pfsinfin:' || pfsinfin;
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_estado_siniestro';
  vnumerr     NUMBER(10)    := 0;
BEGIN
  vnumerr    := pac_siniestros.f_estado_siniestro(pnsinies, pcestsin, pccauest, pcunitra, pctramitad, pcsubtra, pfsinfin, porigen , NULL , pobserv);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_estado_siniestro;
/***********************************************************************
FUNCTION F_INS_DOCUMENTOS:
Inserta a la taula SIN_TRAMITA_DOCUMENTO dels paràmetres informats.
param in psproduc  : Código producto
param in pcactivi  : Código actividad
param in pccausin  : Código causa
param in pcmotsin  : Código motivo
param in pcidioma  : Código idioma
param in pctramit  : Código tramitación (opcional, sinó = 0)
param  out  mensajes : Mensajes de error
return             : 0 -> Tot correcte
1 -> S'ha produit un error
***********************************************************************/
FUNCTION f_ins_documentos(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    psproduc  IN NUMBER,
    pcactivi  IN NUMBER,
    pccausin  IN NUMBER,
    pcmotsin  IN NUMBER,
    pcidioma  IN NUMBER,
    mensajes  IN OUT t_iax_mensajes,
    psseguro  IN NUMBER,
    pfreclama IN DATE)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' - psproduc:' || psproduc || ' - pcactivi:' || pcactivi || ' - pccausin:' || pccausin || ' - pcmotsin:' || pcmotsin || ' - pcidioma:' || pcidioma || ' - pntramit:' || pntramit || ' - psseguro:' || psseguro || ' - pfreclama:' || pfreclama;
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_ins_documentos';
  vnumerr     NUMBER(10)    := 0;
  vsproduc    NUMBER;
  vcactivi    NUMBER;
BEGIN
  SELECT sproduc,
    cactivi
  INTO vsproduc,
    vcactivi
  FROM seguros
  WHERE sseguro = psseguro;
  vnumerr      := pac_siniestros.f_ins_documentos(pnsinies, vsproduc, vcactivi, pccausin, pcmotsin, pcidioma, pntramit, pfreclama);
  IF vnumerr   <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_ins_documentos;
/***********************************************************************
FUNCTION F_SET_DOCUMENTOS:
Inserta a la taula SIN_TRAMITA_DOCUMENTO dels paràmetres informats.
param in psproduc  : Código producto
param in pcactivi  : Código actividad
param in pccausin  : Código causa
param in pcmotsin  : Código motivo
param in pcidioma  : Código idioma
param in pctramit  : Código tramitación (opcional, sinó = 0)
param  out  mensajes : Mensajes de error
return             : 0 -> Tot correcte
1 -> S'ha produit un error
31/07/2009   XVM                 Sinistres.  Bug: 8820
***********************************************************************/
FUNCTION f_set_documentos(
    pnsinies IN VARCHAR2,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pccausin IN NUMBER,
    pcmotsin IN NUMBER,
    pcidioma IN NUMBER,
    mensajes IN OUT t_iax_mensajes,
    pntramit IN NUMBER DEFAULT 0)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' - psproduc:' || psproduc || ' - pcactivi:' || pcactivi || ' - pccausin:' || pccausin || ' - pcmotsin:' || pcmotsin || ' - pcidioma:' || pcidioma || ' - pntramit:' || pntramit;
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_set_documentos';
  vnumerr     NUMBER(10)    := 0;
BEGIN
  vnumerr    := pac_siniestros.f_ins_documentos(pnsinies, psproduc, pcactivi, pccausin, pcmotsin, pcidioma, pntramit);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_documentos;
/***********************************************************************
F_SIN_REA:    Aquesta funció permet crear moviments d'abonament, per
part de les companyies de reassegurança, en concepte dels
pagaments de sinistres.
Busca el desglos d'un pagament en seguro/riscos/garanties
i, per cada garantia, crida a la funció F_PAGSINREA.
ALLIBREA
***********************************************************************/
FUNCTION f_sin_rea(
    psidepag IN sin_tramita_pago.sidepag%TYPE,
    pmoneda  IN VARCHAR2,
    mensajes IN OUT t_iax_mensajes,
    pnsinies IN sin_siniestro.nsinies%TYPE DEFAULT NULL,
    pctippag IN sin_tramita_pago.ctippag%TYPE DEFAULT NULL,
    pfefepag IN sin_tramita_movpago.fefepag%TYPE DEFAULT NULL,
    pcpagcoa IN NUMBER DEFAULT NULL)
  RETURN NUMBER
IS
  vpasexec    NUMBER(8)     := 1;
  vparam      VARCHAR2(500) := 'parámetros - psidepag:' || psidepag || ' - pmoneda:' || pmoneda || ' - pnsinies:' || pnsinies || ' - pctippag:' || pctippag || ' - pfefepag:' || pfefepag || ' - pcpagcoa:' || pcpagcoa;
  vobjectname VARCHAR2(50)  := 'PAC_MD_SINIESTROS.f_ins_documentos';
  vnumerr     NUMBER(10)    := 0;
BEGIN
  vnumerr    := pac_siniestros.f_sin_rea(psidepag, pmoneda, pnsinies, pctippag, pfefepag, pcpagcoa);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_sin_rea;
/***********************************************************************
FUNCTION F_SET_CAUSA:
Graba los datos de una determinada causa
param in pccauest     : Código Causa Estado
param in pcestsin     : Código Estado Siniestro
param in pcidioma     : Código Idioma
param in ptcauest     : Descripción Causa Estado
param in out mensajes : Mensajes de error
return               : 0 -> Tot correcte
1 -> S'ha produit un error
31/07/2009   XVM                 Sinistres.  Bug: 8820
***********************************************************************/
FUNCTION f_set_causa(
    pccauest IN NUMBER,
    pcestsin IN NUMBER,
    pcidioma IN NUMBER,
    ptcauest IN VARCHAR2,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_causa';
  vparam      VARCHAR2(500) := 'parámetros - pccauest: ' || pccauest || ' - pcestsin: ' || pcestsin || ' -  pcidioma:' || pcidioma || ' - ptcauest:' || ptcauest;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  vpasexec   := 2;
  vnumerr    := pac_siniestros.f_ins_causa(pccauest, pcestsin, pcidioma, ptcauest);
  IF vnumerr != 0 THEN
    vpasexec := 3;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_causa;
/***********************************************************************
FUNCTION f_get_causas
Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST las causas
param in pccauest  : Código Causa Estado
param in pcestsin  : Código Estado Siniestro
param in ptcauest  : Descripción Estado
return             : ref cursor
31/07/2009   XVM                 Sinistres.  Bug: 8820
***********************************************************************/
FUNCTION f_get_causas(
    pccauest IN NUMBER,
    pcestsin IN NUMBER,
    ptcauest IN VARCHAR2,
    mensajes IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vsquery  VARCHAR2(1000);
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(200) := 'parámetros - pccauest:' || pccauest || ' - pcestsin:' || pcestsin || ' - ptcauest:' || ptcauest;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_causas';
  vnumerr  NUMBER(10);
  --
BEGIN
  vnumerr  := pac_siniestros.f_get_causas(pccauest, pcestsin, ptcauest, pac_md_common.f_get_cxtidioma, vsquery);
  cur      := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec := 3;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_causas;
/***********************************************************************
FUNCTION f_get_causa
Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST una causa en
concreto con sus descripciones
param in pccauest : Código Causa Estado
param in pcestsin : Código Estado Siniestro
return             : ref cursor
31/07/2009   XVM                 Sinistres.  Bug: 8820
***********************************************************************/
FUNCTION f_get_causa(
    pccauest IN NUMBER,
    pcestsin IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vsquery  VARCHAR2(1000);
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(200) := 'parámetros - pccauest:' || pccauest || ' - pcestsin:' || pcestsin;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_causa';
  vnumerr  NUMBER(10);
BEGIN
  vnumerr  := pac_siniestros.f_get_causa(pccauest, pcestsin, vsquery);
  cur      := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec := 3;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_causa;
/***********************************************************************
FUNCTION f_del_causa
Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST una causa en
concreto con sus descripciones
param in pccauest : Código Causa Estado
param in pcestsin : Código Estado Siniestro
return            : 0 -> Tot correcte
1 -> S'ha produit un error
31/07/2009   XVM                 Sinistres.  Bug: 8820
***********************************************************************/
FUNCTION f_del_causa(
    pccauest IN NUMBER,
    pcestsin IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_causa';
  vparam      VARCHAR2(500) := 'parámetros - pccauest:' || pccauest || ' pcestsin:' || pcestsin;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pccauest IS NULL OR pcestsin IS NULL THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_causa(pccauest, pcestsin);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_causa;
/***********************************************************************
FUNCTION f_del_detcausa
Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST una causa en
concreto con sus descripciones
param in pccauest : Código Causa Estado
param in pcestsin : Código Estado Siniestro
param in pcidioma : Código Idioma
return            : 0 -> Tot correcte
1 -> S'ha produit un error
31/07/2009   XVM                 Sinistres.  Bug: 8820
***********************************************************************/
FUNCTION f_del_detcausa(
    pccauest IN NUMBER,
    pcestsin IN NUMBER,
    pcidioma IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_causa';
  vparam      VARCHAR2(500) := 'parámetros - pccauest:' || pccauest || ' pcestsin:' || pcestsin || ' pcidioma:' || pcidioma;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pccauest IS NULL OR pcestsin IS NULL THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_detcausa(pccauest, pcestsin, pcidioma);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_detcausa;
/*************************************************************************
función graba los datos del documento asociado a la tramitación del siniestro
ob_iax_siniestros.documentacion
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),   --Número Tramitación Siniestro
ndocume        NUMBER(6),   --Número Documento
cdocume        NUMBER(6),   --Código Documento
iddoc          NUMBER(10),  --Identificador documento GEDOX
freclama       DATE,        --Fecha reclamacion
frecibe        DATE,        --Fecha recepcion
fcaduca        DATE,        --Fecha caducidad
cobliga        NUMBER(1)    --Código obligatoriedad
descripcion    VARCHAR2     --Descripcion del usuario para el documento
param in out mensajes : Mensajes de error
return               : 0 -> Tot correcte
1 -> S'ha produit un error
*************************************************************************/
FUNCTION f_set_objeto_sintramidocumento(
    pnsinies     IN VARCHAR2,
    pntramit     IN NUMBER,
    pndocume     IN NUMBER,
    pcdocume     IN NUMBER,
    piddoc       IN NUMBER,
    pfreclama    IN DATE,
    pfrecibe     IN DATE,
    pfcaduca     IN DATE,
    pcobliga     IN NUMBER,
    pdescripcion IN VARCHAR2,
    pcaccion     IN NUMBER,
    vdocumento   IN OUT ob_iax_sin_trami_documento,
    mensajes     IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.F_Set_objeto_sintramidocumento';
  vparam      VARCHAR2(500)  := 'parámetros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pndocume: ' || pndocume || ' - pcdocume: ' || pcdocume || ' - piddoc: ' || piddoc || ' - pfreclama: ' || TO_CHAR(pfreclama, 'DD/MM/YYYY') || ' - pfrecibe: ' || TO_CHAR(pfrecibe, 'DD/MM/YYYY') || ' - pfcaduca: ' || TO_CHAR(pfcaduca, 'DD/MM/YYYY') || ' - pcobliga: ' || pcobliga || ' - pdescripcion: ' || pdescripcion;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  ptsiglas    VARCHAR2(1000) := '';
  vttitdoc doc_desdocumento.ttitdoc%TYPE;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  --Bug10393 - 06/10/2009
  SELECT ttitdoc
  INTO vttitdoc
  FROM doc_desdocumento
  WHERE cdocume = pcdocume
  AND cidioma   = pac_md_common.f_get_cxtidioma;
  vpasexec     := 5;
  --Còpia dels paràmetres passats per paràmetre, a la variable global objecte sinistre del paquet.
  vdocumento.nsinies  := pnsinies;
  vdocumento.ntramit  := pntramit;
  vdocumento.ndocume  := pndocume;
  vdocumento.cdocume  := pcdocume;
  vdocumento.iddoc    := piddoc;
  vdocumento.freclama := pfreclama;
  vdocumento.frecibe  := pfrecibe;
  vdocumento.fcaduca  := pfcaduca;
  vdocumento.cobliga  := pcobliga;
  vdocumento.ttitdoc  := vttitdoc;
  vdocumento.descdoc  := pdescripcion;
  vdocumento.caccion  := pcaccion;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_sintramidocumento;
/***********************************************************************
FUNCTION F_INS_MOVSINIESTRO
Guarda un moviment de sinistre
param  in  pnsinies    : código siniestro
param  in  pcestsin    : código estado siniestro
param  in  pfestsin    : data estado siniestro
param  in  pccauest    : código causa estado siniestro
param  in  pcunitra    : código unidad tramitación
param  in  pctramitad  : código tramitador
param out pnmovsin  : número movimiento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_ins_movsiniestro(
    pnsinies   IN VARCHAR2,
    pcestsin   IN NUMBER,
    pfestsin   IN DATE,
    pccauest   IN NUMBER,
    pcunitra   IN VARCHAR2,
    pctramitad IN VARCHAR2,
    pnmovsin OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_ins_movsiniestro';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' pcestsin:' || pcestsin || ' pfestsin:' || pfestsin || ' pccauest:' || pccauest || ' pcunitra:' || pcunitra || ' pctramitad:' || pctramitad;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  vnumerr    := pac_siniestros.f_ins_movsiniestro(pnsinies, pcestsin, pfestsin, pccauest, pcunitra, pctramitad, pnmovsin);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_ins_movsiniestro;
/***********************************************************************
graba la colección de lineas de documento
param in  pnsinies  : número de siniestro
--param out  t_iax_sin_trami_agenda :  t_iax_sin_trami_agenda
param out  t_iax_sin_trami_documento :  t_iax_sin_trami_documento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_trami_documentos(
    pnsinies IN VARCHAR2,
    --pagendas IN t_iax_sin_trami_agenda,
    pdocumentos IN t_iax_sin_trami_documento,
    mensajes    IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery VARCHAR2(5000);
  --vobjectname    VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_set_listagenda';
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_trami_documentos';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pdocumentos        IS NOT NULL THEN
    IF pdocumentos.COUNT > 0 THEN
      FOR i IN pdocumentos.FIRST .. pdocumentos.LAST
      LOOP
        vnumerr            := f_set_trami_documento(pnsinies, pdocumentos(i), mensajes);
        IF mensajes        IS NOT NULL THEN
          IF mensajes.COUNT > 0 THEN
            RETURN vnumerr;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_trami_documentos;
/***********************************************************************
graba los datos de un determinado documento
param in  pnsinies  : número de siniestro
param out  ob_iax_sin_trami_documento :  ob_iax_sin_trami_documento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_trami_documento(
    pnsinies IN VARCHAR2,
    --pagenda IN ob_iax_sin_trami_agenda,
    pdocumento IN ob_iax_sin_trami_documento,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_trami_documento';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  vnumerr := pac_siniestros.f_ins_documento(pnsinies, pdocumento.ntramit, pdocumento.ndocume, pdocumento.cdocume, pdocumento.freclama, pdocumento.frecibe, pdocumento.fcaduca, pdocumento.cobliga, pdocumento.descdoc, pdocumento.caccion);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_trami_documento;
/***********************************************************************
Recupera los datos del documento siniestro
param in pcdocume: Código del documento
param in pcidioma : Código del idioma
param out pttitdoc: Nombre identificativo Documento
param out ptdocume : Descripción Documento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_documentos(
    pcdocume IN NUMBER,
    pcidioma IN NUMBER,
    pttitdoc OUT VARCHAR2,
    ptdocume OUT VARCHAR2,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_Documentos';
  vparam      VARCHAR2(500) := 'parámetros - pcdocume: ' || pcdocume || ' - pcidioma: ' || pcidioma;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pcdocume IS NULL OR pcidioma IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 1;
  vnumerr  := pac_siniestros.f_get_documentos(pcdocume, pcidioma, pttitdoc, ptdocume);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_documentos;
/***********************************************************************
Recupera el ttitdoc de la tabla DOC_DESDOCUMENTO
param  in  pcdocume : código documento
param  out pttitdoc : Nombre identificativo documento
return              : 0 -> Tot correcte
1 -> S'ha produit un error
06/10/2009   DCT                 Sinistres.  Bug: 10393
***********************************************************************/
FUNCTION f_get_ttitdoc(
    pcdocume IN NUMBER,
    pttitdoc OUT VARCHAR,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_Get_Ttitdoc';
  vparam      VARCHAR2(500) := 'parámetros - pcdocume: ' || pcdocume;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pcdocume IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 1;
  vnumerr  := pac_siniestros.f_get_ttitdoc(pcdocume, pac_md_common.f_get_cxtidioma, pttitdoc);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_ttitdoc;
/***********************************************************************
FUNCTION F_get_unitradefecte
Obtenim descripció unitat tram i tramitador i els codis per Defecte
param  out  ptunitra    : desc unidad tramitación
param  out  pttramitad  : desc tramitador
param  out  pcunitra    : código unidad tramitación
param  out  pctramitad  : código tramitador
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_descunitradefecte(
    p_cuser   IN VARCHAR2,
    p_sseguro IN NUMBER,
    p_ccausin IN NUMBER,
    p_cmotsin IN NUMBER,
    p_nsinies IN NUMBER,
    p_ntramit IN NUMBER,
    ptunitra OUT VARCHAR2,
    pttramit OUT VARCHAR2,
    pcunitra OUT VARCHAR2,
    pctramit OUT VARCHAR2,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_desunitradefecte';
  vparam      VARCHAR2(500) := 'parÃ metres -  p_cuser: ' || p_cuser || 'p_sseguro : ' || p_sseguro || ' p_ccausin : ' || p_ccausin || 'p_cmotsin : ' || p_cmotsin || ' p_nsinies : ' || p_nsinies || 'p_ntramit : ' || p_ntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  --Bug.: 18977 - 12/07/2011 - ICV
  /*vnumerr := pac_siniestros.f_get_unitradefecte(pac_md_common.f_get_cxtempresa, pcunitra,
  pctramit);*/
  -- 22108:ASN:22/05/2012 ini
  /*
  vnumerr := pac_md_siniestros.f_get_tramitador_defecto(pac_md_common.f_get_cxtempresa,
  p_cuser, p_sseguro, p_ccausin,
  p_cmotsin, p_nsinies, p_ntramit,
  pcunitra, pctramit, mensajes);
  */
  IF p_nsinies IS NULL OR p_ntramit IS NULL THEN
    -- 23101:ASN:28/08/2012 ini
    /*
    vnumerr :=
    pac_md_siniestros.f_get_tramitador_defecto(pac_md_common.f_get_cxtempresa,
    p_cuser, p_sseguro, p_ccausin,
    p_cmotsin, p_nsinies, NULL, p_ntramit,
    pcunitra, pctramit, mensajes);
    */
    pcunitra := 'U000';
    pctramit := 'T000';
    -- 23101:ASN:28/08/2012 fin
  ELSE
    vnumerr := pac_siniestros.f_get_tramitador(p_nsinies, NULL, p_ntramit, pcunitra, pctramit);
  END IF;
  -- 22108:ASN:22/05/2012 fin
  vpasexec              := 4;
  IF NVL(vnumerr, 99999) > 1 THEN --El error 1 es de tramitador por defecto U000
    RAISE e_object_error;
  END IF;
  vnumerr := 0;
  --fi bug.: 18977
  BEGIN
    SELECT ttramitad
    INTO ptunitra
    FROM sin_codtramitador tram
    WHERE tram.ctramitad = pcunitra;
    SELECT ttramitad
    INTO pttramit
    FROM sin_codtramitador tram
    WHERE tram.ctramitad = pctramit;
  EXCEPTION
  WHEN OTHERS THEN
    ptunitra := '';
    pttramit := '';
    RAISE e_object_error;
  END;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_descunitradefecte;
/***********************************************************************
Recupera el historico de reservas por tipo
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  pctipres  : Código de tipo de reservar
param in  pcgarant  : Código de la garantia
param in  pnmovres  : Numero de movimiento de la reserva
param in  psproduc  : Código del producto
param in  pcactivi  : Código de la actividad
param out  t_iax_sin_trami_reserva :  t_iax_sin_trami_reserva
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
-- Bug 14490 - 18/05/2010 - AMC - Se añade los parametros pnmovres,psproduc,pcactivi
***********************************************************************/
FUNCTION f_get_histreservas(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctipres IN NUMBER,
    pctipgas IN NUMBER, -- 26108
    pcgarant IN NUMBER,
    pnmovres IN NUMBER,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pcmonres IN VARCHAR2,
    t_reservas OUT t_iax_sin_trami_reserva,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_histreservas';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit || ' pctipres:' || pctipres || ' pcgarant:' || pcgarant || ' pnmovres:' || pnmovres || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi || ' pcmonres:' || pcmonres;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  v_cramo     NUMBER;
  v_cmodali   NUMBER;
  v_ctipseg   NUMBER;
  v_ccolect   NUMBER;
  v_cactivi   NUMBER;
  v_es_baja   NUMBER;
  v_moncia    VARCHAR2(50);
  v_fcambio    DATE;
  ob_reserva ob_iax_sin_trami_reserva;  --IAXIS 3638 Shubhendu 03/05/2019 cambio historial de pagos
  CURSOR cur_res
  IS
    SELECT str.nsinies,
      str.ntramit,
      str.ctipres,
      str.nmovres
    FROM sin_tramita_reserva str
    WHERE str.nsinies = pnsinies
    AND str.ntramit   = pntramit
    AND str.ctipres   = pctipres
      -- 26108 ini
    AND NVL(str.ctipgas, -1) = NVL(pctipgas, -1)
    AND NVL(str.cgarant, -1) = NVL(pcgarant, -1)
    AND NVL(str.cmonres, -1) = NVL(pcmonres, -1)
      /*
      AND(str.ctipgas = pctipgas
      OR pctipgas IS NULL)
      AND(str.cgarant = pcgarant
      OR pcgarant IS NULL)
      AND(str.cmonres = pcmonres
      OR pcmonres IS NULL)
      */
      -- 26108 fin
    ORDER BY ctipres,
      cgarant,
      nmovres DESC;
  CURSOR cur_resbaja
  IS
    SELECT str.nsinies,
      str.ntramit,
      str.ctipres,
      str.nmovres
    FROM sin_tramita_reserva str
    WHERE str.nsinies        = pnsinies
    AND str.ntramit          = pntramit
    AND str.ctipres          = pctipres
    AND NVL(str.ctipgas, -1) = NVL(pctipgas, -1) -- 26108
    AND str.cgarant          = pcgarant
    AND str.cmonres          = pcmonres
    AND(str.fresini)        IN
      (SELECT str2.fresini
      FROM sin_tramita_reserva str2
      WHERE str2.nsinies       = str.nsinies
      AND str2.ntramit         = str.ntramit
      AND str2.ctipres         = str.ctipres
      AND NVL(str.ctipgas, -1) = NVL(pctipgas, -1) -- 26108
      AND(str2.cgarant         = str.cgarant)
      AND str2.nmovres         = pnmovres
      )
  ORDER BY str.ctipres,
    str.ctipgas,
    str.cgarant,
    str.nmovres DESC; -- 26108
BEGIN
    ob_reserva := ob_iax_sin_trami_reserva();   --IAXIS 3638 Shubhendu 03/05/2019 cambio historial de pagos
  --Comprovaci? dels par?metres d'entrada
  IF pnsinies IS NULL OR pntramit IS NULL OR pctipres IS NULL OR pnmovres IS NULL OR psproduc IS NULL OR pcactivi IS NULL THEN
    RAISE e_param_error;
  END IF;
  t_reservas := t_iax_sin_trami_reserva();
  vnumerr    := f_def_producto(psproduc, v_cramo, v_cmodali, v_ctipseg, v_ccolect);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  v_es_baja           := f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, pcactivi, pcgarant, 'BAJA');
  IF NVL(v_es_baja, 0) = 0 THEN
    FOR reg IN cur_res
    LOOP
      t_reservas.EXTEND;
      t_reservas(t_reservas.LAST) := ob_iax_sin_trami_reserva();
      vnumerr                     := f_get_reserva(pnsinies, reg.ntramit, reg.ctipres, reg.nmovres, NULL, t_reservas(t_reservas.LAST), mensajes);
      IF mensajes                 IS NOT NULL THEN
        IF mensajes.COUNT          > 0 THEN
          RETURN 1;
        END IF;
      END IF;
    END LOOP;
  ELSE
    FOR reg IN cur_resbaja
    LOOP
      t_reservas.EXTEND;
      t_reservas(t_reservas.LAST) := ob_iax_sin_trami_reserva();
      vnumerr                     := f_get_reserva(pnsinies, reg.ntramit, reg.ctipres, reg.nmovres, NULL, t_reservas(t_reservas.LAST), mensajes);
      IF mensajes                 IS NOT NULL THEN
        IF mensajes.COUNT          > 0 THEN
          RETURN 1;
        END IF;
      END IF;
    END LOOP;
  END IF;
  IF t_reservas        IS NOT NULL THEN
    IF t_reservas.count > 0 THEN
      FOR vresv IN t_reservas.first .. t_reservas.last
      LOOP
        IF t_reservas.exists(vresv) THEN
        -- BUG1404:AP:Inicio
        BEGIN
            SELECT fcambio
            INTO v_fcambio
            FROM sin_tramita_reserva
            WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND ctipres = pctipres
            AND cgarant = pcgarant
            AND cmonres = pcmonres
            AND nmovres = t_reservas(vresv).nmovres;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        v_fcambio := null;
        END;
        -- BUG1404:AP:Fin
          IF t_reservas.exists(vresv                                     + 1) THEN
      IF NVL(t_reservas(vresv) .irecobro, 0) = NVL(t_reservas(vresv            + 1).irecobro, 0) THEN --CONF-1051
              t_reservas(vresv).ivaltrans := t_reservas(vresv) .ireserva - t_reservas(vresv + 1) .ireserva;
              ---- Setting the value if the type is payment AXIS 3638 Shubhendu 03/05/2019 cambio historial de pagos
              IF(t_reservas(vresv).cmovres=4) THEN
                    t_reservas(vresv).ipago_moncia := abs(t_reservas(vresv) .ireserva - t_reservas(vresv + 1) .ireserva);
                ELSE
                    t_reservas(vresv).ipago_moncia := null;
              END IF;
              --IAXIS 3638 Shubhendu 03/05/2019 cambio historial de pagos
      -- BUG1404:AP:Inicio
      t_reservas(vresv).fcambio := v_fcambio;
      v_moncia := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'MONEDAEMP'));
      t_reservas(vresv).itasacambio := pac_eco_tipocambio.f_cambio(t_reservas(vresv).cmonres, v_moncia, t_reservas(vresv).fcambio);
      --Converting the value with Exchange Rate IAXIS 3638 --IAXIS 3638 Shubhendu 03/05/2019 cambio historial de pagos
      t_reservas(vresv).ipago_moncia := t_reservas(vresv).ipago_moncia*t_reservas(vresv).itasacambio;
      IF t_reservas(vresv).itasacambio = 1 THEN
      t_reservas(vresv).itasacambio := null;
      t_reservas(vresv).fcambio := null;
      END IF;
      -- BUG1404:AP:Fin
            ELSE
        t_reservas(vresv).ivaltrans := NVL(t_reservas(vresv) .irecobro, 0) - NVL(t_reservas(vresv + 1) .irecobro, 0); --CONF-1051
              -- Setting the value if the type is othe than payment IAXIS 3638 --IAXIS 3638 Shubhendu 03/05/2019 cambio historial de pagos
              t_reservas(vresv).ipago_moncia := abs(NVL(t_reservas(vresv) .irecobro, 0) - NVL(t_reservas(vresv + 1) .irecobro, 0));
              --Converting the value with Exchange Rate IAXIS 3638
              t_reservas(vresv).ipago_moncia := t_reservas(vresv).ipago_moncia*t_reservas(vresv).itasacambio;
        --IAXIS 3638 Shubhendu 03/05/2019 cambio historial de pagos
      -- BUG1404:AP:Inicio
      t_reservas(vresv).fcambio := v_fcambio;
      v_moncia := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'MONEDAEMP'));
      t_reservas(vresv).itasacambio := pac_eco_tipocambio.f_cambio(t_reservas(vresv).cmonres, v_moncia, t_reservas(vresv).fcambio);
      IF t_reservas(vresv).itasacambio = 1 THEN
      t_reservas(vresv).itasacambio := null;
      t_reservas(vresv).fcambio := null;
      END IF;
      -- BUG1404:AP:Fin
      END IF;
          ELSE
            t_reservas(vresv).ivaltrans := t_reservas(vresv) .ireserva;
            -- Setting the value to null if the typr is othe than payment
            t_reservas(vresv).ipago_moncia := null;
            --END IF;
      --IAXIS 3638 Shubhendu 03/05/2019 cambio historial de pagos
      -- BUG1404:AP:Inicio
      t_reservas(vresv).fcambio := v_fcambio;
      v_moncia := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'MONEDAEMP'));
      t_reservas(vresv).itasacambio := pac_eco_tipocambio.f_cambio(t_reservas(vresv).cmonres, v_moncia, t_reservas(vresv).fcambio);
      IF t_reservas(vresv).itasacambio = 1 THEN
      t_reservas(vresv).itasacambio := null;
      t_reservas(vresv).fcambio := null;
      END IF;
      -- BUG1404:AP:Fin
          END IF;
        END IF;
      END LOOP;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_histreservas;
/**************************************************************************
Función que genera un destinatario automatico
param in  psseguro : Numero de seguro
param in  pfsinies : Fecha siniestro
param in  pccausin : Código causa siniestro
param in  pcmotsin : Código motivo siniestro
param in  pcgarant : Código de la garantia
param out psperson : Código persona
param out pctipdes : Codigo tipo destinatario
param out pctipban : Código tipo cuenta bancaria
param out pcbancar : Cuenta bancaria
param out pcpaise  : Código País Residencia
param out pctipcap : Tipo de prestación.  Valor 205.-- Bug 0017970 - 16/03/2011 - JMF
param out mensajes : Mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
Bug 12753 - 19/01/2010 - AMC
***********************************************************************/
FUNCTION f_destina_aut(
    psseguro IN seguros.sseguro%TYPE,
    pfsinies IN sin_siniestro.fsinies%TYPE,
    pccausin IN sin_siniestro.ccausin%TYPE,
    pcmotsin IN sin_siniestro.cmotsin%TYPE,
    pcgarant IN codigaran.cgarant%TYPE,
    psperson OUT sin_tramita_destinatario.sperson%TYPE,
    pctipdes OUT sin_tramita_destinatario.ctipdes%TYPE,
    pctipban OUT sin_tramita_destinatario.ctipban%TYPE,
    pcbancar OUT sin_tramita_destinatario.cbancar%TYPE,
    pcpaisre OUT sin_tramita_destinatario.cpaisre%TYPE,
    pctipcap OUT sin_tramita_destinatario.ctipcap%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_destina_aut';
  vparam      VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro || ' pfsinies:' || pfsinies || ' pccausin:' || pccausin || ' pcmotsin:' || pcmotsin || ' pcgarant:' || pcgarant;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF psseguro IS NULL OR pfsinies IS NULL OR pccausin IS NULL OR pcmotsin IS NULL OR pcgarant IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_destina_aut(psseguro, pfsinies, pccausin, pcmotsin, pcgarant, psperson, pctipdes, pctipban, pcbancar, pcpaisre, pctipcap);
  IF vnumerr <> 0 THEN
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_destina_aut;
/**************************************************************************
Función que inserta un pago
param in  pnsinies : número de siniestro
param in  pnriesgo : núero de riesgp
param in  pntramit : número de tramitacion
param in  pctipres : código del tipo de reserva
param in  pcgarant : código de la garantia
param in  pfsinies : fecha del siniestro
param in  pfperini : fecha inicio periodo
param in  pfperfin : fecha fin periodo
param out pcpaise  : Codigo de identificafión del pago
param out mensajes : Mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
Bug 11849 - 20/01/2010 - AMC
***********************************************************************/
FUNCTION f_inserta_pago(
    pnsinies IN sin_tramita_pago.nsinies%TYPE,
    pnriesgo IN sin_siniestro.nriesgo%TYPE,
    pntramit IN sin_tramita_pago.ntramit%TYPE,
    pctipres IN sin_tramita_reserva.ctipres%TYPE,
    pctipgas IN sin_tramita_reserva.ctipgas%TYPE, -- 26108
    pcgarant IN sin_tramita_reserva.cgarant%TYPE,
    pfsinies IN sin_siniestro.fsinies%TYPE,
    pfperini IN sin_tramita_reserva.fresini%TYPE,
    pfperfin IN sin_tramita_reserva.fresfin%TYPE,
    psidepag OUT sin_tramita_pago.sidepag%TYPE,
    pipago OUT sin_tramita_pago.isinret%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_inserta_pago';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pnriesgo:' || pnriesgo || ' pntramit:' || pntramit || ' pctipres:' || pctipres || ' pcgarant:' || pcgarant || ' pfsinies:' || pfsinies || ' pfperini:' || pfperini || ' pfperfin:' || pfperfin;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pnriesgo IS NULL OR pntramit IS NULL OR pctipres IS NULL OR pcgarant IS NULL OR pfsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr := pac_siniestros.f_inserta_pago(pnsinies, pnriesgo, pntramit, pctipres, pctipgas, -- 26108
  pcgarant, pfsinies, pfperini, pfperfin, psidepag, pipago);
  IF vnumerr <> 0 THEN
    -- Bug 16040 - 23/09/2010 - SRA
    IF vnumerr <> 1 THEN
      -- BUG 21307/107043 - 16/02/2012 - JMP - Si los errores son controlados no se concatena el nombre del package
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    ELSE
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam);
    END IF;
    RETURN 1;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_inserta_pago;
/**************************************************************************
Función que inserta un pago
param in  pnsinies : número de siniestro
param in  pntramit : número de tramitacion
param in  pctipres : código del tipo de reserva
param in  pnmovres : numero de movimiento
param in  psproduc : Código de producto
param in  pcactivi : Código de la actividad
param in  pcgarant : código de la garantia
param out pfperini : fecha inicio periodo
param out mensajes : mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
Bug 12207 - 01/02/2010 - AMC
***********************************************************************/
FUNCTION f_get_fechareserva(
    pnsinies IN sin_tramita_pago.nsinies%TYPE,
    pntramit IN sin_tramita_pago.ntramit%TYPE,
    pctipres IN sin_tramita_reserva.ctipres%TYPE,
    pctipgas IN sin_tramita_reserva.ctipgas%TYPE, -- 26108
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pcgarant IN sin_tramita_reserva.cgarant%TYPE,
    pfperini OUT sin_tramita_reserva.fresini%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_fechareserva';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit || ' pctipres:' || pctipres || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pctipres IS NULL OR psproduc IS NULL OR pcactivi IS NULL OR pcgarant IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr := pac_siniestros.f_get_fechareserva(pnsinies, pntramit, pctipres, pctipgas, -- 26108
  psproduc, pcactivi, pcgarant, pfperini);
  IF vnumerr <> 0 THEN
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_fechareserva;
/**************************************************************************
Funcion  borrar amparo 
param in  pnsinies : nÃºmero de siniestro
param in  pntramit : nÃºmero de tramitacion
param in  pcgarant : cÃ³digo de la garantia
param out mensajes : mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
Bug 12207 - 01/02/2010 - AMC
***********************************************************************/
FUNCTION f_del_amparo(
    pnsinies IN sin_tramita_amparo.nsinies%TYPE,
    pntramit IN sin_tramita_amparo.ntramit%TYPE,
    pcgarant IN sin_tramita_amparo.cgarant%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_amparo';
  vparam      VARCHAR2(500) := 'parÃ¡metros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit  || ' pcgarant:' || pcgarant;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pcgarant IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr := pac_siniestros.f_del_amparo(pnsinies, pntramit,  pcgarant);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_amparo;
/**************************************************************************
Función que borrar el ultimo movimiento de una reserva si no tiene pagos
param in  pnsinies : número de siniestro
param in  pntramit : número de tramitacion
param in  pctipres : código del tipo de reserva
param in  pnmovres : Numero de movimiento
param in  pcgarant : código de la garantia
param out mensajes : mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
Bug 12207 - 01/02/2010 - AMC
***********************************************************************/
FUNCTION f_del_ultreserva(
    pnsinies IN sin_tramita_pago.nsinies%TYPE,
    pntramit IN sin_tramita_pago.ntramit%TYPE,
    pctipres IN sin_tramita_reserva.ctipres%TYPE,
    pctipgas IN sin_tramita_reserva.ctipgas%TYPE, --26108
    pnmovres IN sin_tramita_reserva.nmovres%TYPE,
    pcgarant IN sin_tramita_reserva.cgarant%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_ultreserva';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit || ' pctipres:' || pctipres || ' pnmovres:' || pnmovres || ' pcgarant:' || pcgarant;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pctipres IS NULL OR pnmovres IS NULL OR pcgarant IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr := pac_siniestros.f_del_ultreserva(pnsinies, pntramit, pctipres, pctipgas, -- 26108
  pnmovres, pcgarant);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_ultreserva;
/**************************************************************************
Función que comprueba la modificacion de la fresfin de una reserva
param in  pnsinies : número de siniestro
param in  pntramit : número de tramitacion
param in  pctipres : código del tipo de reserva
param in  pcgarant : código de la garantia
param in  pfresfin : Fecha fin de la reserva
param out pfresfin_out : Fecha permitida como fecha fin reserva
param out mensajes : Mensajes de error
return              : 0 -> Tot correcte
Codigo error -> S'ha produit un error
Bug 12207 - 03/02/2010 - AMC
***********************************************************************/
FUNCTION f_actfresfin(
    pnsinies IN sin_tramita_pago.nsinies%TYPE,
    pntramit IN sin_tramita_pago.ntramit%TYPE,
    pctipres IN sin_tramita_reserva.ctipres%TYPE,
    pcgarant IN sin_tramita_reserva.cgarant%TYPE,
    pfresfin IN sin_tramita_reserva.fresfin%TYPE,
    pfresfin_out OUT sin_tramita_reserva.fresfin%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_actfresfin';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit || ' pctipres:' || pctipres || ' pcgarant:' || pcgarant || ' pfresfin:' || pfresfin;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pctipres IS NULL OR pcgarant IS NULL OR pfresfin IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_actfresfin(pnsinies, pntramit, pctipres, pcgarant, pfresfin, pfresfin_out);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_actfresfin;
/**************************************************************************
FUNCTION f_pago_aut
Crea un pago automático
param in pdata   : fecha final de pago
param out pncobros : Numero de cobros generados
param out mensajes : Mensajes de error
return              : 0 -> Tot correcte
Codigo error -> S'ha produit un error
Bug 12207 - 03/02/2010 - AMC
***********************************************************************/
FUNCTION f_pago_aut(
    p_data     IN DATE,
    pproductos IN t_iax_info,
    pncobros OUT NUMBER,
    psproces OUT NUMBER, -- Bug 16580 - 15/11/2010 - AMC
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_pago_aut';
  vparam      VARCHAR2(500) := 'parametros - p_data: ' || p_data;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vwhere      VARCHAR2(2000);
BEGIN
  IF p_data IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pproductos IS NOT NULL AND pproductos.COUNT > 0 THEN
    FOR j IN pproductos.FIRST .. pproductos.LAST
    LOOP
      IF pproductos(j).seleccionado = 1 THEN
        IF vwhere                  IS NULL THEN
          vwhere                   := '|' || pproductos(j).valor_columna;
        ELSE
          vwhere := vwhere || '|' || pproductos(j).valor_columna;
        END IF;
      END IF;
    END LOOP;
  END IF;
  IF vwhere IS NOT NULL THEN
    vwhere  := vwhere || '|';
  END IF;
  vnumerr := pac_siniestros.f_pago_aut(p_data, pncobros, NULL, NULL, NULL, NULL, -- 26108
  vwhere, pac_md_common.f_get_cxtempresa, NULL, psproces);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_pago_aut;
/**************************************************************************
Función que borra el detalle de un pago
param in  psidepag : numero de pago
param in  pnsinies : número de siniestro
param in  pntramit : número de tramitacion
param in  pctipres : código del tipo de reserva
aram in  pcgarant : código de la garantia
param in  pnmovres : numero de movimiento
return              : 0 -> Tot correcte
Codigo error -> S'ha produit un error
Bug 13166 - 15/02/2010 - AMC
***********************************************************************/
FUNCTION f_del_movpaggar(
    psidepag IN sin_tramita_pago.sidepag%TYPE,
    pnsinies IN sin_tramita_pago.nsinies%TYPE,
    pntramit IN sin_tramita_pago.ntramit%TYPE,
    pctipres IN sin_tramita_reserva.ctipres%TYPE,
    pcgarant IN sin_tramita_reserva.cgarant%TYPE,
    pnmovres IN sin_tramita_pago_gar.nmovres%TYPE,
    pnorden  IN sin_tramita_pago_gar.norden%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_movpaggar';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag || ' pnsinies:' || pnsinies || ' pntramit:' || pntramit || ' pctipres:' || pctipres || ' pcgarant:' || pcgarant || ' pnmovres:' || pnmovres || ' pnorden:' || pnorden;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF psidepag IS NULL OR pnsinies IS NULL OR pntramit IS NULL OR pctipres IS NULL OR pnmovres IS NULL OR pnorden IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_movpaggar(psidepag, pnsinies, pntramit, pctipres, pcgarant, pnmovres, pnorden);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_movpaggar;
/***********************************************************************
Recupera los datos del riesgo de hogar
param in psseguro  : código de seguro
param in pnriesgo  : código del riesgo
param out mensajes : mensajes de error
return             : ref cursor
Bug 12668 - 24/02/2010 - AMC
***********************************************************************/
FUNCTION f_get_datsitriesgo(
    psseguro IN NUMBER,
    pnriesgo IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_datsitriesgo';
  vparam      VARCHAR2(500) := 'parámetros - psseguro:' || psseguro || ' pnriesgo:' || pnriesgo;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
BEGIN
  --Comprovació dels parámetres d'entrada
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 3;
  vsquery  := 'select s.tdomici,s.cprovin,s.cpostal,s.cpoblac,s.csiglas,s.tnomvia,s.nnumvia,' || ' s.tcomple,s.fgisx,s.fgisy,s.fgisz,s.cvalida,pr.TPROVIN,po.TPOBLAC,p.CPAIS,p.TPAIS' || ' from sitriesgo s, provincias pr, poblaciones po, paises p' || ' where sseguro =' || psseguro || ' and nriesgo =' || pnriesgo || ' and s.CPROVIN = pr.CPROVIN' || ' and s.CPOBLAC = po.CPOBLAC' || ' and s.CPROVIN = po.CPROVIN' || ' and pr.CPAIS = p.CPAIS';
  vpasexec := 5;
  vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN vcursor;
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_get_datsitriesgo;
/**************************************************************************
Función que borra una tramitacion
param in  pnsinies : número de siniestro
param in  pntramit : número de tramitacion
param in  pctiptra : numero de tipo de tramitacion
param out mensajes : mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
Bug 12668 - 03/03/2010 - AMC
***********************************************************************/
FUNCTION f_del_tramitacion(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctiptra IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_tramitacion';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' pntramit:' || pntramit || ' pctiptra:' || pctiptra;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pctiptra IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_tramitacion(pnsinies, pntramit, pctiptra);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_tramitacion;
/**************************************************************************
Función que indica si una reserva se puede modificar
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitacion
param in  pctipres  : Código del tipo de reserva
param in  pcgarant  : Código de la garantia
param in  pnmovres  : Numero de movimiento d la reserva
param in  psproduc  : Codigo del producto
param in  pcactivi  : Codigo de la actividad
param in  pmodificable : 0 - No modificable
1 - Modificable
param out mensajes  : Mensajes de error
return              : 0 -> Tot correcte
Codigo error -> S'ha produit un error
Bug 14490 - 19/05/2010 - AMC
***********************************************************************/
FUNCTION f_mov_reserva(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctipres IN NUMBER,
    pctipgas IN NUMBER, -- 26108
    pcgarant IN NUMBER,
    pnmovres IN NUMBER,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pmodificable OUT NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_mov_reserva';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' pntramit:' || pntramit || ' pctipres:' || pctipres || ' pcgarant:' || pcgarant || ' pnmovres:' || pnmovres || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pctipres IS NULL OR pcgarant IS NULL OR pnmovres IS NULL OR psproduc IS NULL OR pcactivi IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr := pac_siniestros.f_mov_reserva(pnsinies, pntramit, pctipres, pctipgas, -- 26108
  pcgarant, pnmovres, psproduc, pcactivi, pmodificable);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_mov_reserva;
/**************************************************************************
Función que devuelve si se permite borrar una reserva
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitacion
param in  pctipres  : Código del tipo de reserva
param in  pcgarant  : Código de la garantia
param in  pfresini  : Fecha de inicio de la reserva
param in  psproduc  : Codigo del producto
param in  pcactivi  : Codigo de la actividad
param out pmodificable : 0 - No modificable
1 - Modificable
param out mensajes  : Mensajes de error
return              : 0 -> Tot correcte
Codigo error -> S'ha produit un error
Bug 14490 - 20/05/2010 - AMC
***********************************************************************/
FUNCTION f_perdelreserva(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctipres IN NUMBER,
    pctipgas IN NUMBER, -- 26108
    pcgarant IN NUMBER,
    pfresini IN DATE,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pmodificable OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_perdelreserva';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' pntramit:' || pntramit || ' pctipres:' || pctipres || ' pcgarant:' || pcgarant || ' pfresini:' || pfresini || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pctipres IS NULL OR pcgarant IS NULL
    --OR pfresini IS NULL --ICV Bug.: 16102
    OR psproduc IS NULL OR pcactivi IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr := pac_siniestros.f_perdelreserva(pnsinies, pntramit, pctipres, pctipgas, -- 26108
  pcgarant, pfresini, psproduc, pcactivi, pmodificable);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_perdelreserva;
/**************************************************************************
Función que devuelve si se debe generar la reserva y el destinatario
param in  pccausin  : número de siniestro
param in  pcmotsin  : número de tramitacion
param in  pcgarant  : Código de la garantia
param in  psproduc  : Codigo del producto
param in  pcactivi  : Codigo de la actividad
param out pgenerar : 0 - No se genera
1 - Se genera
param out mensajes  : Mensajes de error
return             : 0 -> Tot correcte
Codigo error -> S'ha produit un error
Bug 14752 - 01/06/2010 - AMC
***********************************************************************/
FUNCTION f_gen_resdestinatari(
    pccausin IN NUMBER,
    pcmotsin IN NUMBER,
    pcgarant IN NUMBER,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pgenerar OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_gen_resdestinatari';
  vparam      VARCHAR2(500) := 'parámetros - pccausin:' || pccausin || ' pcmotsin:' || pcmotsin || ' pcgarant:' || pcgarant || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pccausin IS NULL OR pcmotsin IS NULL OR pcgarant IS NULL OR psproduc IS NULL OR pcactivi IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_gen_resdestinatari(pccausin, pcmotsin, pcgarant, psproduc, pcactivi, pgenerar);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_gen_resdestinatari;
/**************************************************************************
Función que devuelve el capital de una garantia
param in  pcgarant  : Código de la garantia
param in  psseguro  : Código del seguro
param in  pnsinies  : Código del siniestro
param out pcapital  : Capital de la garantia
param out mensajes  : mensajes de error
return              : 0 -> Tot correcte
Codigo error -> S'ha produit un error
Bug 14816 - 02/06/2010 - AMC
***********************************************************************/
FUNCTION f_get_capitalgar(
    pcgarant IN NUMBER,
    psseguro IN NUMBER,
    pnsinies IN VARCHAR2,
    pcapital OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_capitalgar';
  vparam      VARCHAR2(500) := 'parámetros - pcgarant:' || pcgarant || ' psseguro:' || psseguro || ' pnsinies:' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  vnumerr    := pac_siniestros.f_get_capitalgar(pcgarant, psseguro, pnsinies, pcapital);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_capitalgar;
/*************************************************************************
función borra todo el objeto citacion de tramitaciones
param in pnsinies : numero de siniestro
param in pntramit : numero de siniestro
param in pncitacion : numero de citacion
param in out mensajes : mensajes de error
*************************************************************************/
FUNCTION f_del_citacion(
    pnsinies   IN VARCHAR2,
    pntramit   IN NUMBER,
    pncitacion IN NUMBER,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(200) := ' pnsinies=' || pnsinies || 'pntramit=' || pntramit || ' pncitacion=' || pncitacion;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.F_del_citacion';
  vnumerr  NUMBER;
  trobat   NUMBER := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL OR pntramit IS NULL OR pncitacion IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_citacion(pnsinies, pntramit, pncitacion);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_del_citacion;
/*************************************************************************
función borra todo el objeto destinatario de tramitaciones
param in pnsinies : numero de siniestro
param in pntramit : numero de siniestro
param in pctipdes : tipo de destinatario
param in psperson : codigo de destinario
param in out mensajes : mensajes de error
Bug 14766 - 03/06/2010 - AMC
*************************************************************************/
FUNCTION f_del_destinatario(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctipdes IN NUMBER,
    psperson IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(200) := 'psperson=' || psperson || ' pnsinies=' || pnsinies || 'pntramit=' || pntramit || ' pctipdes=' || pctipdes;
  vobject  VARCHAR2(200) := 'PAC_IAX_persona.F_del_destinatario';
  vnumerr  NUMBER;
  trobat   NUMBER := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL OR pntramit IS NULL OR pctipdes IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_destinatario(pnsinies, pntramit, pctipdes, psperson);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_del_destinatario;
/*************************************************************************
función borra un apunte de la agenda
param in pnsinies : numero de siniestro
param in pntramit : numero de siniestro
param in pnlinage : numero de linea
param in out mensajes : mensajes de error
Bug 15153 - 23/06/2010 - AMC
*************************************************************************/
FUNCTION f_del_agenda(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pnlinage IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(200) := 'pnsinies=' || pnsinies || 'pntramit=' || pntramit || ' pnlinage=' || pnlinage;
  vobject  VARCHAR2(200) := 'PAC_IAX_persona.f_del_agenda';
  vnumerr  NUMBER;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pnlinage IS NULL THEN
    RAISE e_object_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_agenda(pnsinies, pntramit, pnlinage);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_del_agenda;
/**************************************************************************
Función que retorna los siniestros de una póliza, siendo optativo filtrar por su número de riesgo.
param in  psseguro  : código que identifica la póliza en AXIS
param in  pnriesgo  : código que identifica el riesgo de la póliza en AXIS
param out mensajes  : mensajes de error
return sys_refcursor: cursor que devuelve el listado
Bug 15965 - 10/09/2010 - SRA
***********************************************************************/
FUNCTION f_consulta_lstsini_riesgo(
    psseguro IN NUMBER,
    pnriesgo IN NUMBER,
    plstsini OUT sys_refcursor,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.CONSULTA_LSTSINI_RIESGO';
  vparam      VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro || ' - pnriesgo: ' || pnriesgo;
  vpasexec    NUMBER(5)     := 0;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  vnidioma    NUMBER;
  vnresult    NUMBER;
  vcursor sys_refcursor;
BEGIN
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec    := 2;
  vnidioma    := pac_md_common.f_get_cxtidioma;
  vpasexec    := 3;
  vnresult    := pac_siniestros.f_consulta_lstsini_riesgo(psseguro, pnriesgo, vnidioma, vsquery);
  vpasexec    := 4;
  IF vnresult <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnresult);
    RAISE e_object_error;
  END IF;
  vpasexec                                                                                           := 5;
  IF pac_md_log.f_log_consultas(vsquery, 'PAC_SINIESTROS.f_consulta_lstsini_riesgo', 1, 4, mensajes) <> 0 THEN
    IF plstsini%ISOPEN THEN
      CLOSE plstsini;
    END IF;
    RAISE e_object_error;
  END IF;
  vpasexec := 5;
  plstsini := pac_md_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec := 6;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  IF plstsini%ISOPEN THEN
    CLOSE plstsini;
  END IF;
  RETURN 1000005;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  IF plstsini%ISOPEN THEN
    CLOSE plstsini;
  END IF;
  RETURN 1000006;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  IF plstsini%ISOPEN THEN
    CLOSE plstsini;
  END IF;
  RETURN 1000001;
END f_consulta_lstsini_riesgo;
-- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
/***********************************************************************
Recupera los datos de una prestación
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  psperson  : número identificativo del destinatario
param in  pctipdes  : número tipo destinatario
param out  ob_iax_sin_trami_destinatario :  ob_iax_sin_trami_destinatario
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_get_prestaren(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    psperson IN NUMBER,
    pctipdes IN NUMBER,
    t_prestaren OUT t_iax_sin_prestaren,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_prestaren';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || 'ntramit ' || pntramit || 'sperson = ' || psperson || 'ctipdes : ' || pctipdes;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  pagas ob_iax_nmesextra := ob_iax_nmesextra();
  ob_prestaren ob_iax_sin_prestaren;
  vmesesextra VARCHAR2(200);
BEGIN
  t_prestaren  := t_iax_sin_prestaren();
  ob_prestaren := ob_iax_sin_prestaren();
  vnumerr      := pac_siniestros.f_get_prestaren(pnsinies, pntramit, psperson, pctipdes, pac_md_common.f_get_cxtidioma, vsquery);
  cur          := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec     := 4;
  LOOP
    FETCH cur
    INTO ob_prestaren.nsinies,
      ob_prestaren.ntramit,
      ob_prestaren.sperson,
      ob_prestaren.ctipdes,
      ob_prestaren.sseguro,
      ob_prestaren.f1paren,
      ob_prestaren.fuparen,
      ob_prestaren.cforpag,
      ob_prestaren.ibruren,
      ob_prestaren.ffinren,
      ob_prestaren.cestado,
      ob_prestaren.cmotivo,
      ob_prestaren.fppren,
      ob_prestaren.crevali,
      ob_prestaren.prevali,
      ob_prestaren.irevali,
      ob_prestaren.cblopag,
      ob_prestaren.ctipdur,
      ob_prestaren.npartot,
      ob_prestaren.npartpend,
      ob_prestaren.ctipban,
      ob_prestaren.cbancar,
      ob_prestaren.ttipdes,
      ob_prestaren.tsperson,
      ob_prestaren.tforpag,
      ob_prestaren.testado,
      ob_prestaren.tmotivo,
      ob_prestaren.tblopag,
      ob_prestaren.trevali,
      ob_prestaren.ttipdur,
      vmesesextra,
      ob_prestaren.npresta;
    EXIT
  WHEN cur%NOTFOUND;
    vpasexec       := 5;
    IF vmesesextra IS NOT NULL THEN
      vnumerr      := pac_prod_rentas.f_leer_nmesextra(vmesesextra, pagas.nmes1, pagas.nmes2, pagas.nmes3, pagas.nmes4, pagas.nmes5, pagas.nmes6, pagas.nmes7, pagas.nmes8, pagas.nmes9, pagas.nmes10, pagas.nmes11, pagas.nmes12);
      IF vnumerr   <> 0 THEN
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
        RETURN NULL;
      END IF;
    END IF;
    vpasexec               := 6;
    ob_prestaren.nmesextra := pagas;
    t_prestaren.EXTEND;
    t_prestaren(t_prestaren.LAST) := ob_prestaren;
    ob_prestaren                  := ob_iax_sin_prestaren();
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_prestaren;
/***********************************************************************
f_set_obj_sinprestaren
Crea un objeto prestación con los datos.
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación
param in  psperson  : número identificativo del destinatario
param in  pctipdes  : número tipo destinatario
param out  vprestaren :  ob_iax_sin_PRESTAREN
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
***********************************************************************/
FUNCTION f_set_obj_sinprestaren(
    pnsinies   IN VARCHAR2,
    pntramit   IN NUMBER,
    psperson   IN NUMBER,
    pctipdes   IN NUMBER,
    psseguro   IN NUMBER,
    pf1paren   IN DATE,
    pfuparen   IN DATE,
    pcforpag   IN NUMBER,
    pibruren   IN NUMBER,
    pcrevali   IN NUMBER,
    pprevali   IN NUMBER,
    pirevali   IN NUMBER,
    pctipdur   IN NUMBER,
    pnpartot   IN NUMBER,
    pctipban   IN NUMBER,
    pcbancar   IN VARCHAR2,
    pcestado   IN NUMBER,
    pcmotivo   IN NUMBER,
    pcblopag   IN NUMBER,
    pnmes1     IN NUMBER,
    pnmes2     IN NUMBER,
    pnmes3     IN NUMBER,
    pnmes4     IN NUMBER,
    pnmes5     IN NUMBER,
    pnmes6     IN NUMBER,
    pnmes7     IN NUMBER,
    pnmes8     IN NUMBER,
    pnmes9     IN NUMBER,
    pnmes10    IN NUMBER,
    pnmes11    IN NUMBER,
    pnmes12    IN NUMBER,
    pnpresta   IN NUMBER,
    vprestaren IN OUT t_iax_sin_prestaren,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500)  := 'PAC_MD_SINIESTROS.f_set_obj_sinprestaren';
  vparam      VARCHAR2(2000) := 'parámetros - pnsinies: ' || pnsinies || ' ntramit ' || pntramit || ' sperson = ' || psperson || ' pctipdes : ' || pctipdes || ' psseguro : ' || psseguro || ' pf1paren: ' || pf1paren || ' pfuparen: ' || pfuparen || ' pcforpag: ' || pcforpag || ' pibruren: ' || pibruren || ' pcrevali: ' || pcrevali || ' pprevali: ' || pprevali || ' pirevali: ' || pirevali || ' pctipdur: ' || pctipdur || ' pnpartot: ' || pnpartot || ' pctipban: ' || pctipban || ' pcbancar: ' || pcbancar || ' pnmes1  : ' || pnmes1 || ' pnmes2  : ' || pnmes2 || ' pnmes3  : ' || pnmes3 || ' pnmes4  : ' || pnmes4 || ' pnmes5  : ' || pnmes5 || ' pnmes6  : ' || pnmes6 || ' pnmes7  : ' || pnmes7 || ' pnmes8  : ' || pnmes8 || ' pnmes9  : ' || pnmes9 || ' pnmes10 : ' || pnmes10 || ' pnmes11 : ' || pnmes11 || ' pnmes12 : ' || pnmes12 || ' pnpresta : ' || pnpresta;
  vpasexec    NUMBER(5)      := 1;
  vnumerr     NUMBER(8)      := 0;
  vsquery     VARCHAR2(5000);
  vcagente    NUMBER;
  pagas ob_iax_nmesextra := ob_iax_nmesextra();
  vempresa empresas.cempres%TYPE; -- Bug 18263 - APD - 14/04/2011
  ob_prestaren ob_iax_sin_prestaren;
  b_prestaren BOOLEAN := FALSE;
BEGIN
  IF pnsinies IS NULL OR psperson IS NULL OR pntramit IS NULL OR pctipdes IS NULL OR pcforpag IS NULL OR pf1paren IS NULL OR pibruren IS NULL OR pctipban IS NULL OR pcbancar IS NULL OR pcestado IS NULL OR pcblopag IS NULL OR pcrevali IS NULL OR pctipdur IS NULL THEN
    RAISE e_param_error;
  END IF;
  -- Bug 18263 - APD - 14/04/2011 - los unicos posibles estados de los pagos son
  -- 0.-Pendiente de Pago, 5.-Pdte.Bloqueado, (cvalor=230)
  SELECT cempres --de momento vamos a seguros
  INTO vempresa
  FROM seguros s,
    sin_siniestro SIN
  WHERE SIN.nsinies = pnsinies
  AND s.sseguro     = SIN.sseguro;
  -- BUG 17247- 02/2011 - JRH - 0017247: Envio pagos SAP Sólo genera recibos pdtes.
  IF NVL(pac_parametros.f_parempresa_n(vempresa, 'GESTIONA_COBPAG'), 0) = 1 THEN
    IF pcblopag NOT IN(0, 5) THEN -- 0.-Pendiente de Pago, 5.-Pdte.Bloqueado, (cvalor=230)
      vnumerr := 9901159;         -- Estado del pago invalido
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr);
      RETURN 1;
    END IF;
  END IF;
  -- Fin Bug 18263 - APD - 14/04/2011
  IF vprestaren IS NULL THEN
    vprestaren  := t_iax_sin_prestaren();
    vprestaren.EXTEND;
  ELSIF vprestaren.COUNT = 0 THEN
    vprestaren.EXTEND;
  END IF;
  ob_prestaren         := ob_iax_sin_prestaren();
  vpasexec             := 1;
  ob_prestaren.nsinies := pnsinies;
  ob_prestaren.ntramit := pntramit;
  ob_prestaren.sperson := psperson;
  ob_prestaren.ctipdes := pctipdes;
  ob_prestaren.sseguro := psseguro;
  ob_prestaren.f1paren := pf1paren;
  ob_prestaren.f1paren := pf1paren;
  ob_prestaren.fuparen := pfuparen;
  ob_prestaren.cforpag := pcforpag;
  ob_prestaren.ibruren := pibruren;
  ob_prestaren.crevali := NVL(pcrevali, 0);
  ob_prestaren.prevali := NVL(pprevali, 0);
  ob_prestaren.irevali := NVL(pirevali, 0);
  ob_prestaren.ctipdur := pctipdur;
  ob_prestaren.npartot := pnpartot;
  ob_prestaren.ctipban := pctipban;
  ob_prestaren.cbancar := pcbancar;
  vpasexec             := 2;
  ob_prestaren.ttipdes := ff_desvalorfijo(10, pac_md_common.f_get_cxtidioma, pctipdes); --    Tipo destinatario
  vpasexec             := 3;
  IF psperson          IS NOT NULL THEN
    vcagente           := pac_persona.f_get_agente_detallepersona(psperson, pac_md_common.f_get_cxtagente, pac_md_common.f_get_cxtempresa);
    IF vcagente        IS NULL THEN
      vcagente         := pac_md_common.f_get_cxtagente;
    END IF;
    ob_prestaren.tsperson := f_nombre(psperson, 1, vcagente);
  END IF;
  vpasexec               := 4;
  ob_prestaren.tforpag   := ff_desvalorfijo(17, pac_md_common.f_get_cxtidioma, pcforpag); --    Tipo destinatario
  vpasexec               := 5;
  ob_prestaren.trevali   := ff_desvalorfijo(62, pac_md_common.f_get_cxtidioma, pcrevali); --    Tipo destinatario
  vpasexec               := 6;
  ob_prestaren.ttipdur   := ff_desvalorfijo(1010, pac_md_common.f_get_cxtidioma, pctipdur); --    Tipo destinatario
  vpasexec               := 7;
  ob_prestaren.cestado   := pcestado;
  ob_prestaren.cmotivo   := pcmotivo;
  ob_prestaren.cblopag   := pcblopag;
  ob_prestaren.npresta   := pnpresta;
  pagas.nmes1            := pnmes1;
  pagas.nmes2            := pnmes2;
  pagas.nmes3            := pnmes3;
  pagas.nmes4            := pnmes4;
  pagas.nmes5            := pnmes5;
  pagas.nmes6            := pnmes6;
  pagas.nmes7            := pnmes7;
  pagas.nmes8            := pnmes8;
  pagas.nmes9            := pnmes9;
  pagas.nmes10           := pnmes10;
  pagas.nmes11           := pnmes11;
  pagas.nmes12           := pnmes12;
  ob_prestaren.nmesextra := pagas;
  FOR j IN vprestaren.FIRST .. vprestaren.LAST
  LOOP
    IF vprestaren(j).npresta = pnpresta THEN
      vprestaren(j)         := ob_prestaren;
      b_prestaren           := TRUE;
    END IF;
  END LOOP;
  IF NOT b_prestaren THEN
    vprestaren(vprestaren.LAST) := ob_prestaren;
  END IF;
  --JRH IMP Valida cforpag para extras
  --SELF.TESTADO    := NULL; --   Descripción del estado de la prestación
  -- SELF.TMOTIVO  := NULL; --   Descripción del motivo del estado
  --SELF.TBLOPAG := NULL; --    Descripción del estado creación de los pagos
  vpasexec := 8;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_obj_sinprestaren;
/*************************************************************************
función borra todo el objeto destinatario de prestaciones
param in pnsinies : numero de siniestro
param in pntramit : numero de siniestro
param in pctipdes : tipo de destinatario
param in psperson : codigo de destinario
param in out mensajes : mensajes de error
*************************************************************************/
FUNCTION f_del_prestaren(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    psperson IN NUMBER,
    pctipdes IN NUMBER,
    pnpresta IN NUMBER,
    --psseguro IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(200) := 'psperson=' || psperson || ' pnsinies=' || pnsinies || ' pntramit=' || pntramit || ' pctipdes=' || pctipdes || ' pnpresta=' || pnpresta;
  vobject  VARCHAR2(200) := 'PAC_IAX_persona.F_del_destinatario';
  vnumerr  NUMBER;
  trobat   NUMBER := 0;
BEGIN
  --Comprovació dels parámetres d'entrada
  IF pntramit IS NULL OR pctipdes IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_prestaren(pnsinies, pntramit, psperson, pctipdes, pnpresta);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_del_prestaren;
-- Fi BUG 0015669 - 08/2010 - JRH
/*************************************************************************
FUNCTION f_get_productos_pagos
Nos devuelve los productos de RENTAS o BAJA
param in pcempres    : Empresa
param in idioma   : Idioma
param in pfiltro   : 1 REntas, 2 Bajas
return           : código de error
---- Bug 15044 - 08/11/2010 - XPL
*************************************************************************/
FUNCTION f_get_productos_pagos(
    pcempres IN NUMBER,
    pfiltro  IN NUMBER,
    pproductos OUT t_iax_info,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_productos_pagos';
  vparam      VARCHAR2(500) := 'parámetros - pcempres: ' || pcempres || 'pfiltro ' || pfiltro;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
  ob_info ob_iax_info;
  vcempres NUMBER := pcempres;
BEGIN
  IF pcempres IS NULL THEN
    vcempres  := pac_md_common.f_get_cxtempresa;
  END IF;
  ob_info    := ob_iax_info();
  vnumerr    := pac_siniestros.f_get_productos_pagos(vcempres, pac_md_common.f_get_cxtidioma, pfiltro, vsquery);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  cur        := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec   := 4;
  pproductos := t_iax_info();
  LOOP
    FETCH cur
    INTO ob_info.valor_columna,
      ob_info.nombre_columna,
      ob_info.seleccionado;
    EXIT
  WHEN cur%NOTFOUND;
    pproductos.EXTEND;
    pproductos(pproductos.LAST) := ob_info;
    ob_info                     := ob_iax_info();
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_productos_pagos;
FUNCTION f_pago_renta_aut(
    p_data     IN DATE,
    pproductos IN t_iax_info,
    pncobros OUT NUMBER,
    psproces OUT NUMBER, -- Bug 16580 - 15/11/2010 - AMC
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_pago_renta_aut';
  vparam      VARCHAR2(500) := 'parÃ¡metros - p_data: ' || p_data;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vwhere      VARCHAR2(2000);
BEGIN
  IF p_data IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pproductos IS NOT NULL AND pproductos.COUNT > 0 THEN
    FOR j IN pproductos.FIRST .. pproductos.LAST
    LOOP
      IF pproductos(j).seleccionado = 1 THEN
        IF vwhere                  IS NULL THEN
          vwhere                   := '|' || pproductos(j).valor_columna;
        ELSE
          vwhere := vwhere || '|' || pproductos(j).valor_columna;
        END IF;
      END IF;
    END LOOP;
  END IF;
  IF vwhere IS NOT NULL THEN
    vwhere  := vwhere || '|';
  END IF;
  vnumerr    := pac_siniestros.f_pago_renta_aut(TO_CHAR(p_data, 'MM'), TO_CHAR(p_data, 'YYYY'), NULL, pncobros, vwhere, pac_md_common.f_get_cxtempresa, psproces);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_pago_renta_aut;
-- BUG16506:DRA:14/12/2010:Inici
/*************************************************************************
FUNCTION que devuelve el tramitador y la unidad de tramitación del usuario
Si no tiene unidad de tramitación devolverá la unidad por defecto, pero
devolverá un 1 para indicar que no es el tramitador del usuario
param in p_cuser      : Fecha
param out p_cunitra   : Objeto que contiene los productos a hacer los pagos
param out p_ctramitad : Numero de cobros
return                : 0 --> OK, 1 --> No es el del usuario, NULL --> Error
*************************************************************************/
FUNCTION f_get_tramitador_defecto(
    p_cempres IN NUMBER,
    p_cuser   IN VARCHAR2,
    p_sseguro IN NUMBER,
    p_ccausin IN NUMBER,
    p_cmotsin IN NUMBER,
    p_nsinies IN VARCHAR2, -- 22108:ASN:18/05/2012
    p_ntramte IN NUMBER,   -- 22108:ASN:18/05/2012
    p_ntramit IN NUMBER,
    p_cunitra OUT VARCHAR2,
    p_ctramitad OUT VARCHAR2,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_tramitador_defecto';
  vparam      VARCHAR2(500) := 'parÃ metres - p_cempres: ' || p_cempres || ' - p_cuser: ' || p_cuser || 'p_sseguro : ' || p_sseguro || ' p_ccausin : ' || p_ccausin || 'p_cmotsin : ' || p_cmotsin || ' p_nsinies : ' || p_nsinies || 'p_ntramte : ' || p_ntramte || 'p_ntramit : ' || p_ntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF p_cempres IS NULL OR p_cuser IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 2;
  vnumerr  := pac_siniestros.f_get_tramitador_defecto(pac_md_common.f_get_cxtempresa, p_cuser, p_sseguro, p_ccausin, p_cmotsin, p_nsinies, p_ntramte,
  -- 22108:ASN:18/05/2012
  p_ntramit, p_cunitra, p_ctramitad);
  IF vnumerr > 1 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN NULL;
END f_get_tramitador_defecto;
-- BUG16506:DRA:14/12/2010:Fi
--bug.: 15738 - ICV - 21/12/2010
/*************************************************************************
Función que ejecuta el map 405 (Carta de pago)
param in  psidepag : código de pago de siniestros
param out  pnomfichero : Nombre fichero
*************************************************************************/
FUNCTION f_imprimir_pago(
    psidepag IN NUMBER,
    pcmapead IN VARCHAR2,
    pnomfichero OUT VARCHAR2,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec NUMBER(8)      := 1;
  vparam   VARCHAR2(3000) := 'psidepag=' || psidepag || ' pcmapead= ' || pcmapead;
  vobject  VARCHAR2(200)  := 'PAC_MD_SINIESTROS.f_imprimir_pago';
  num_err  NUMBER(1)      := 0;
  wpath map_cabecera.tparpath%TYPE;
  wtdesmap map_cabecera.tdesmap%TYPE;
  wruta    VARCHAR2(100);
  vfichero VARCHAR2(4000);
  v_cestpag sin_tramita_movpago.cestpag%TYPE;
BEGIN
  --Control del pago
  BEGIN
    SELECT cestpag
    INTO v_cestpag
    FROM sin_tramita_movpago stm
    WHERE stm.sidepag = psidepag
    AND stm.nmovpag   =
      (SELECT MAX(nmovpag)
      FROM sin_tramita_movpago stm2
      WHERE stm2.sidepag = stm.sidepag
      );
  EXCEPTION
  WHEN OTHERS THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901744);
    RETURN 1;
  END;
  -- Bug 18451 - APD - 05/05/2011 - se puede pedir tambien un duplicado del recibo
  -- si el estado del pago es 9.-Remesado (detvalores 3)
  IF v_cestpag NOT IN(2, 9) THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901745);
    RETURN 1;
  END IF;
  SELECT tdesmap,
    tparpath
    || '_C'
  INTO wtdesmap,
    wpath
  FROM map_cabecera
  WHERE cmapead = pcmapead;
  wruta        := f_parinstalacion_t(wpath);
  num_err      := pac_map.f_extraccion(pcmapead, psidepag, wtdesmap, vfichero);
  pnomfichero  := vfichero;
  RETURN num_err;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_imprimir_pago;
-- Ini bug 18554 - 14/06/2011 - SRA
FUNCTION f_get_hissin_siniestros(
    pnsinies IN sin_tramita_movimiento.nsinies%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vsquery VARCHAR2(2000);
  vcursor sys_refcursor;
  vnresult NUMBER;
  vpasexec NUMBER        := 0;
  vobject  VARCHAR2(200) := 'pac_md_siniestros.f_get_hissin_siniestros';
  vparam   VARCHAR2(200) := 'pnsinies: ' || pnsinies;
BEGIN
  vpasexec    := 1;
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec    := 2;
  vnresult    := pac_siniestros.f_get_hissin_siniestros(pnsinies, vsquery);
  IF vnresult <> 0 THEN
    vpasexec  := 3;
    pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnresult, vpasexec, vparam);
    RETURN vcursor;
  END IF;
  vpasexec                                                                                            := 4;
  vcursor                                                                                             := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec                                                                                            := 5;
  IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_SINIESTROS.F_GET_HISSIN_SINIESTROS', 1, 4, mensajes) <> 0 THEN
    IF vcursor%ISOPEN THEN
      CLOSE vcursor;
    END IF;
  END IF;
  vpasexec := 6;
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
  RETURN vcursor;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN vcursor;
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_get_hissin_siniestros;
-- Fin bug 18554 - 14/06/2011 - SRA
-- ini Bug 0018812 - 21/06/2011 - JMF
/*************************************************************************
Función que muestra descipción póliza de ahorro o de renta.
param in  psidepag : código de pago de siniestros
param in  ptip: 1=Ahorro, resto = Renta.
param out ptexto : descipcion
*************************************************************************/
FUNCTION f_get_mensaje_polrenta(
    psidepag IN NUMBER,
    ptip     IN NUMBER DEFAULT 2,
    ptexto   IN OUT VARCHAR2)
  RETURN NUMBER
IS
  vpasexec NUMBER(8)         := 1;
  vparam   VARCHAR2(3000)    := 'psidepag=' || psidepag;
  vobject  VARCHAR2(200)     := 'PAC_MD_SINIESTROS.f_get_mensaje_polrenta';
  num_err  NUMBER(1)         := 0;
  v_idi idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma;
BEGIN
  IF ptip = 1 THEN -- póliza de Ahorro
    SELECT MAX(SUBSTR(''
      || ' '
      || b.npoliza
      || '-'
      || b.ncertif
      || ' '
      || f_desproducto_t(b.cramo, b.cmodali, b.ctipseg, b.ccolect, 1, v_idi)
      || ' '
      || ff_desvalorfijo(61, v_idi, b.csituac)
      || ' '
      || ff_desvalorfijo(66, v_idi, b.creteni), 1, 500))
    INTO ptexto
    FROM seguros_ren_prest a,
      seguros b
    WHERE a.sidepag = psidepag
    AND b.sseguro   = a.sseguro;
  ELSE -- póliza de Renta
    SELECT MAX(SUBSTR(''
      || ' '
      || b.npoliza
      || '-'
      || b.ncertif
      || ' '
      || f_desproducto_t(b.cramo, b.cmodali, b.ctipseg, b.ccolect, 1, v_idi)
      || ' '
      || ff_desvalorfijo(61, v_idi, b.csituac)
      || ' '
      || ff_desvalorfijo(66, v_idi, b.creteni), 1, 500))
    INTO ptexto
    FROM seguros_ren_prest a,
      seguros b
    WHERE a.sidepag = psidepag
    AND b.sseguro   = a.ssegren;
  END IF;
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  ptexto := NULL;
  RETURN 1;
END f_get_mensaje_polrenta;
-- fin Bug 0018812 - 21/06/2011 - JMF
/***********************************************************************
FUNCTION f_get_juzgados
Recupera la colección de juzgados
param in pnsinies    : número del siniestro
param in pntramit    : número tramitación siniestro
param out pjuzgados  : t_iax_sin_tramita_juzgado
param out mensajes   : mensajes de error
return               : 0 OK
1 Error
Bug 19821 - 10/11/2011 - MDS
***********************************************************************/
FUNCTION f_get_juzgados(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pjuzgados OUT t_iax_sin_tramita_juzgado,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_get_juzgados';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_juz
  IS
    SELECT nsinies,
      ntramit,
      nlinjuz
    FROM sin_tramita_juzgado
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit
    ORDER BY nlinjuz ASC;
BEGIN
  -- Comprovación de los parámetros de entrada
  IF pnsinies IS NULL OR pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  pjuzgados := t_iax_sin_tramita_juzgado();
  FOR reg IN cur_juz
  LOOP
    pjuzgados.EXTEND;
    pjuzgados(pjuzgados.LAST) := ob_iax_sin_tramita_juzgado();
    vnumerr                   := f_get_juzgado(pnsinies, pntramit, reg.nlinjuz, pjuzgados(pjuzgados.LAST), mensajes);
    IF mensajes               IS NOT NULL THEN
      IF mensajes.COUNT        > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_juzgados;
/***********************************************************************
FUNCTION f_get_juzgado
Recupera un juzgado
param in pnsinies    : número del siniestro
param in pntramit    : número tramitación siniestro
param in pnlinjuz    : número de línea de juzgado
param out pjuzgado   : ob_iax_sin_tramita_juzgado
param out mensajes   : mensajes de error
return               : 0 OK
1 Error
Bug 19821 - 10/11/2011 - MDS
***********************************************************************/
FUNCTION f_get_juzgado(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pnlinjuz IN NUMBER,
    pjuzgado OUT ob_iax_sin_tramita_juzgado,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_juzgado';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit || ' pnlinjuz : ' || pnlinjuz;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  pjuzgado := ob_iax_sin_tramita_juzgado();
  vnumerr  := pac_siniestros.f_get_juzgado(pnsinies, pntramit, pnlinjuz, pac_md_common.f_get_cxtidioma, vsquery);
  cur      := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec := 2;
  LOOP
    FETCH cur
    INTO pjuzgado.nsinies,
      pjuzgado.ntramit,
      pjuzgado.corgjud,
      pjuzgado.norgjud,
      pjuzgado.trefjud,
      pjuzgado.csiglas,
      pjuzgado.tnomvia,
      pjuzgado.nnumvia,
      pjuzgado.tcomple,
      pjuzgado.tdirec,
      pjuzgado.cpais,
      pjuzgado.cprovin,
      pjuzgado.cpoblac,
      pjuzgado.cpostal,
      pjuzgado.nlinjuz,
      pjuzgado.tasunto,
      pjuzgado.nclasede,
      pjuzgado.ntipopro,
      pjuzgado.nprocedi,
      pjuzgado.fnotiase,
      pjuzgado.frecpdem,
      pjuzgado.fnoticia,
      pjuzgado.fcontase,
      pjuzgado.fcontcia,
      pjuzgado.faudprev,
      pjuzgado.fjuicio,
      pjuzgado.cmonjuz,
      pjuzgado.cpleito,
      pjuzgado.ipleito,
      pjuzgado.iallana,
      pjuzgado.isentenc,
      pjuzgado.isentcap,
      pjuzgado.isentind,
      pjuzgado.isentcos,
      pjuzgado.isentint,
      pjuzgado.isentotr,
      pjuzgado.cargudef,
      pjuzgado.cresplei,
      pjuzgado.capelant,
      pjuzgado.thipoase,
      pjuzgado.thipoter,
      pjuzgado.ttipresp,
      pjuzgado.copercob,
      pjuzgado.treasmed,
      pjuzgado.cestproc,
      pjuzgado.cetaproc,
      pjuzgado.tconcjur,
      pjuzgado.testrdef,
      pjuzgado.trecomen,
      pjuzgado.tobserv,
      pjuzgado.fcancel,
      pjuzgado.tclasede,
      pjuzgado.ttipopro,
      pjuzgado.tpleito,
      pjuzgado.targudef,
      pjuzgado.tresplei,
      pjuzgado.tapelant,
      pjuzgado.testproc,
      pjuzgado.tetaproc,
      pjuzgado.torgjud,
      pjuzgado.tprovin;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_juzgado;
/***********************************************************************
FUNCTION f_set_juzgados
Graba la colección de juzgados
param in pnsinies    : número del siniestro
param in pjuzgados   : t_iax_sin_tramita_juzgado
param out mensajes   : mensajes de error
return               : 0 OK
1 Error
Bug 19821 - 10/11/2011 - MDS
***********************************************************************/
FUNCTION f_set_juzgados(
    pnsinies  IN VARCHAR2,
    pjuzgados IN t_iax_sin_tramita_juzgado,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_juzgados';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  -- Comprovación de los parámetros de entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pjuzgados.COUNT > 0 THEN
    FOR i IN pjuzgados.FIRST .. pjuzgados.LAST
    LOOP
      vnumerr            := f_set_juzgado(pnsinies, pjuzgados(i), mensajes);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_juzgados;
/***********************************************************************
FUNCTION f_set_juzgado
Graba un juzgado
param in pnsinies    : número del siniestro
param in pjuzgado    : ob_iax_sin_tramita_juzgado
param out mensajes   : mensajes de error
return               : 0 OK
1 Error
Bug 19821 - 10/11/2011 - MDS
***********************************************************************/
FUNCTION f_set_juzgado(
    pnsinies IN VARCHAR2,
    pjuzgado IN ob_iax_sin_tramita_juzgado,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_juzgado';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  vnumerr := pac_siniestros.f_ins_juzgado(pnsinies, pjuzgado.ntramit, pjuzgado.nlinjuz, pjuzgado.corgjud, pjuzgado.norgjud, pjuzgado.trefjud, pjuzgado.csiglas, pjuzgado.tnomvia, pjuzgado.nnumvia, pjuzgado.tcomple, pjuzgado.tdirec, pjuzgado.cpais, pjuzgado.cprovin, pjuzgado.cpoblac, pjuzgado.cpostal, pjuzgado.tasunto, pjuzgado.nclasede, pjuzgado.ntipopro, pjuzgado.nprocedi, pjuzgado.fnotiase, pjuzgado.frecpdem, pjuzgado.fnoticia, pjuzgado.fcontase, pjuzgado.fcontcia, pjuzgado.faudprev, pjuzgado.fjuicio, pjuzgado.cmonjuz, pjuzgado.cpleito, pjuzgado.ipleito, pjuzgado.iallana, pjuzgado.isentenc, pjuzgado.isentcap, pjuzgado.isentind, pjuzgado.isentcos, pjuzgado.isentint, pjuzgado.isentotr, pjuzgado.cargudef, pjuzgado.cresplei, pjuzgado.capelant, pjuzgado.thipoase, pjuzgado.thipoter, pjuzgado.ttipresp, pjuzgado.copercob, pjuzgado.treasmed, pjuzgado.cestproc, pjuzgado.cetaproc, pjuzgado.tconcjur, pjuzgado.testrdef, pjuzgado.trecomen, pjuzgado.tobserv, pjuzgado.fcancel);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_juzgado;
/***********************************************************************
FUNCTION f_set_objeto_juzgado
Guarda en una variable global de la capa IAX los valores del objeto
param in pnsinies  : número del siniestro
param in pntramit  : número tramitación siniestro
param in pnlinjuz  : número de línea de juzgado
...
...
...
param out pjuzgado   : ob_iax_sin_tramita_juzgado
param out mensajes   : mensajes de error
return               : 0 -> Todo correcto
1 -> Se ha producido un error
Bug 19821 - 10/11/2011 - MDS
***********************************************************************/
FUNCTION f_set_objeto_juzgado(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pnlinjuz  IN NUMBER,
    pcorgjud  IN NUMBER,
    pnorgjud  IN VARCHAR2, --BUG 22048 --ETM --SE MODIFICA EL CAMPO DE NUMERICO A VARCHAR
    ptrefjud  IN VARCHAR2,
    pcsiglas  IN NUMBER,
    ptnomvia  IN VARCHAR2,
    pnnumvia  IN NUMBER,
    ptcomple  IN VARCHAR2,
    ptdirec   IN VARCHAR2,
    pcpais    IN NUMBER,
    pcprovin  IN NUMBER,
    pcpoblac  IN NUMBER,
    pcpostal  IN VARCHAR2,
    ptasunto  IN VARCHAR2,
    pnclasede IN NUMBER,
    pntipopro IN NUMBER,
    pnprocedi IN VARCHAR2,
    pfnotiase IN DATE,
    pfrecpdem IN DATE,
    pfnoticia IN DATE,
    pfcontase IN DATE,
    pfcontcia IN DATE,
    pfaudprev IN DATE,
    pfjuicio  IN DATE,
    pcmonjuz  IN VARCHAR2,
    pcpleito  IN NUMBER,
    pipleito  IN NUMBER,
    piallana  IN NUMBER,
    pisentenc IN NUMBER,
    pisentcap IN NUMBER,
    pisentind IN NUMBER,
    pisentcos IN NUMBER,
    pisentint IN NUMBER,
    pisentotr IN NUMBER,
    pcargudef IN NUMBER,
    pcresplei IN NUMBER,
    pcapelant IN NUMBER,
    pthipoase IN VARCHAR2,
    pthipoter IN VARCHAR2,
    pttipresp IN VARCHAR2,
    pcopercob IN NUMBER,
    ptreasmed IN VARCHAR2,
    pcestproc IN NUMBER,
    pcetaproc IN NUMBER,
    ptconcjur IN VARCHAR2,
    ptestrdef IN VARCHAR2,
    ptrecomen IN VARCHAR2,
    ptobserv  IN VARCHAR2,
    pfcancel  IN DATE,
    pjuzgado  IN OUT ob_iax_sin_tramita_juzgado,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_objeto_juzgado';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit || ' pnlinjuz : ' || pnlinjuz;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  -- Comprovación de los parámetros de entrada
  IF pntramit IS NULL OR pnlinjuz IS NULL THEN
    RAISE e_param_error;
  END IF;
  -- Comprovación de los datos del juicio
  -- 25204:ASN:19/12/2012 ini
  /*
  vnumerr := pac_validaciones_sin.f_valida_juzgado(pnsinies, pfnotiase, pfrecpdem,
  pfnoticia, pfcontase, pfcontcia,
  pfaudprev, pfjuicio, pntipopro,
  pcresplei, pnclasede);
  */
  vnumerr := pac_propio.f_valida_juicio(pnsinies, pfnotiase, pfrecpdem, pfnoticia, pfcontase, pfcontcia, pfaudprev, pfjuicio, pntipopro, pcresplei, pnclasede, pcorgjud);
  -- 25204:ASN:19/12/2012 fin
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_param_error;
  END IF;
  vpasexec          := 2;
  pjuzgado.nsinies  := pnsinies;
  pjuzgado.ntramit  := pntramit;
  pjuzgado.nlinjuz  := pnlinjuz;
  pjuzgado.corgjud  := pcorgjud;
  pjuzgado.norgjud  := pnorgjud;
  pjuzgado.trefjud  := ptrefjud;
  pjuzgado.csiglas  := pcsiglas;
  pjuzgado.tnomvia  := ptnomvia;
  pjuzgado.nnumvia  := pnnumvia;
  pjuzgado.tcomple  := ptcomple;
  pjuzgado.tdirec   := ptdirec;
  pjuzgado.cpais    := pcpais;
  pjuzgado.cprovin  := pcprovin;
  pjuzgado.cpoblac  := pcpoblac;
  pjuzgado.cpostal  := pcpostal;
  pjuzgado.tasunto  := ptasunto;
  pjuzgado.nclasede := pnclasede;
  pjuzgado.ntipopro := pntipopro;
  pjuzgado.nprocedi := pnprocedi;
  pjuzgado.fnotiase := pfnotiase;
  pjuzgado.frecpdem := pfrecpdem;
  pjuzgado.fnoticia := pfnoticia;
  pjuzgado.fcontase := pfcontase;
  pjuzgado.fcontcia := pfcontcia;
  pjuzgado.faudprev := pfaudprev;
  pjuzgado.fjuicio  := pfjuicio;
  pjuzgado.cmonjuz  := pcmonjuz;
  pjuzgado.cpleito  := pcpleito;
  pjuzgado.ipleito  := pipleito;
  pjuzgado.iallana  := piallana;
  pjuzgado.isentenc := pisentenc;
  pjuzgado.isentcap := pisentcap;
  pjuzgado.isentind := pisentind;
  pjuzgado.isentcos := pisentcos;
  pjuzgado.isentint := pisentint;
  pjuzgado.isentotr := pisentotr;
  pjuzgado.cargudef := pcargudef;
  pjuzgado.cresplei := pcresplei;
  pjuzgado.capelant := pcapelant;
  pjuzgado.thipoase := pthipoase;
  pjuzgado.thipoter := pthipoter;
  pjuzgado.ttipresp := pttipresp;
  pjuzgado.copercob := pcopercob;
  pjuzgado.treasmed := ptreasmed;
  pjuzgado.cestproc := pcestproc;
  pjuzgado.cetaproc := pcetaproc;
  pjuzgado.tconcjur := ptconcjur;
  pjuzgado.testrdef := ptestrdef;
  pjuzgado.trecomen := ptrecomen;
  pjuzgado.tobserv  := ptobserv;
  pjuzgado.fcancel  := pfcancel;
  --
  vpasexec          := 3;
  pjuzgado.tclasede := ff_desvalorfijo(800066, pac_md_common.f_get_cxtidioma, pnclasede);
  pjuzgado.ttipopro := ff_desvalorfijo(800065, pac_md_common.f_get_cxtidioma, pntipopro);
  pjuzgado.tpleito  := ff_desvalorfijo(800064, pac_md_common.f_get_cxtidioma, pcpleito);
  pjuzgado.targudef := ff_desvalorfijo(800063, pac_md_common.f_get_cxtidioma, pcargudef);
  pjuzgado.tresplei := ff_desvalorfijo(800062, pac_md_common.f_get_cxtidioma, pcresplei);
  pjuzgado.tapelant := ff_desvalorfijo(800061, pac_md_common.f_get_cxtidioma, pcapelant);
  pjuzgado.testproc := ff_desvalorfijo(800060, pac_md_common.f_get_cxtidioma, pcestproc);
  pjuzgado.tetaproc := ff_desvalorfijo(800059, pac_md_common.f_get_cxtidioma, pcetaproc);
  pjuzgado.torgjud  := ff_desvalorfijo(800059, pac_md_common.f_get_cxtidioma, pcorgjud);
  pjuzgado.tprovin  := f_desprovin2(pcprovin, pcpais);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_juzgado;
/*************************************************************************
FUNCTION f_del_juzgado
Borra un juzgado
param in pnsinies    : número del siniestro
param in pntramit    : número tramitación siniestro
param in pnlinjuz    : número de línea de juzgado
param out mensajes   : mensajes de error
return               : 0 -> Todo correcto
1 -> Se ha producido un error
Bug 19821 - 10/11/2011 - MDS
*************************************************************************/
FUNCTION f_del_juzgado(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pnlinjuz IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_juzgado';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit || ' pnlinjuz : ' || pnlinjuz;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pnlinjuz IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_juzgado(pnsinies, pntramit, pnlinjuz);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_del_juzgado;
/***********************************************************************
FUNCTION f_get_demands
Recupera la colección de demantante/demandado
param in pnsinies    : número del siniestro
param in pntramit    : número tramitación siniestro
param out pdemands   : t_iax_sin_tramita_demand
param out mensajes   : mensajes de error
return               : 0 OK
1 Error
Bug 19821 - 10/11/2011 - MDS
Bug 20340/109094 - 15/03/2012 - AMC
***********************************************************************/
FUNCTION f_get_demands(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pntipodem IN NUMBER, -- Bug 20340/109094 - 15/03/2012 - AMC
    pdemands OUT t_iax_sin_tramita_demand,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_get_demands';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_dem
  IS
    SELECT nsinies,
      ntramit,
      nlindem,
      ntipodem
    FROM sin_tramita_demand
    WHERE nsinies = pnsinies
    AND ntramit   = pntramit
    AND ntipodem  = pntipodem
    ORDER BY nlindem ASC;
BEGIN
  -- Comprovación de los parámetros de entrada
  IF pnsinies IS NULL OR pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  pdemands := t_iax_sin_tramita_demand();
  FOR reg IN cur_dem
  LOOP
    pdemands.EXTEND;
    pdemands(pdemands.LAST) := ob_iax_sin_tramita_demand();
    vnumerr                 := f_get_demand(pnsinies, pntramit, reg.nlindem, reg.ntipodem, pdemands(pdemands.LAST), mensajes);
    IF mensajes             IS NOT NULL THEN
      IF mensajes.COUNT      > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_demands;
/***********************************************************************
FUNCTION f_get_demand
Recupera un demantante/demandado
param in pnsinies    : número del siniestro
param in pntramit    : número tramitación siniestro
param in pnlindem    : número de línea de demantante/demandado
param out pdemand    : ob_iax_sin_tramita_demand
param out mensajes   : mensajes de error
return               : 0 OK
1 Error
Bug 19821 - 10/11/2011 - MDS
Bug 20340/109094 - 15/03/2012 - AMC
***********************************************************************/
FUNCTION f_get_demand(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pnlindem  IN NUMBER,
    pntipodem IN NUMBER, -- Bug 20340/109094 - 15/03/2012 - AMC
    pdemand OUT ob_iax_sin_tramita_demand,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_demand';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit || ' pnlindem : ' || pnlindem;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  pdemand  := ob_iax_sin_tramita_demand();
  vnumerr  := pac_siniestros.f_get_demand(pnsinies, pntramit, pnlindem, pntipodem, pac_md_common.f_get_cxtidioma, vsquery);
  cur      := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec := 2;
  LOOP
    FETCH cur
    INTO pdemand.nsinies,
      pdemand.ntramit,
      pdemand.nlindem,
      pdemand.sperson,
      pdemand.ntipodem,
      pdemand.ttramita,
      pdemand.sperson2,
      pdemand.nprocedi,
      pdemand.tcompani,
      pdemand.ttipodem;
    -- Bug 20340/109094 - 15/03/2012 - AMC
    IF pdemand.sperson IS NOT NULL THEN
      vnumerr          := pac_md_persona.f_get_persona_agente(pdemand.sperson, pac_md_common.f_get_cxtagente(), 'POL', pdemand.persona, mensajes);
    END IF;
    IF pdemand.sperson2 IS NOT NULL THEN
      vnumerr           := pac_md_persona.f_get_persona_agente(pdemand.sperson2, pac_md_common.f_get_cxtagente(), 'POL', pdemand.abogado, mensajes);
    END IF;
    -- Fi Bug 20340/109094 - 15/03/2012 - AMC
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_demand;
/***********************************************************************
FUNCTION f_set_demands
Graba la colección de demantante/demandado
param in pnsinies    : número del siniestro
param in pdemands    : t_iax_sin_tramita_demand
param out mensajes   : mensajes de error
return               : 0 OK
1 Error
Bug 19821 - 10/11/2011 - MDS
***********************************************************************/
FUNCTION f_set_demands(
    pnsinies IN VARCHAR2,
    pdemands IN t_iax_sin_tramita_demand,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_demands';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  -- Comprovación de los parámetros de entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pdemands.COUNT > 0 THEN
    FOR i IN pdemands.FIRST .. pdemands.LAST
    LOOP
      vnumerr            := f_set_demand(pnsinies, pdemands(i), mensajes);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_demands;
/***********************************************************************
FUNCTION f_set_demand
Graba un demantante/demandado
param in pnsinies    : número del siniestro
param in pdemand     : ob_iax_sin_tramita_demand
param out mensajes   : mensajes de error
return               : 0 OK
1 Error
Bug 19821 - 10/11/2011 - MDS
***********************************************************************/
FUNCTION f_set_demand(
    pnsinies IN VARCHAR2,
    pdemand  IN ob_iax_sin_tramita_demand,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_demand';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  vnumerr := pac_siniestros.f_ins_demand(pnsinies, pdemand.ntramit, pdemand.nlindem, pdemand.sperson, pdemand.ntipodem, pdemand.ttramita, pdemand.sperson2, pdemand.nprocedi, pdemand.tcompani);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_demand;
/***********************************************************************
FUNCTION f_set_objeto_demand
Guarda en una variable global de la capa IAX los valores del objeto
param in pnsinies  : número del siniestro
param in pntramit  : número tramitación siniestro
param in pnlindem  : número de línea de demantante/demandado
...
...
...
param out pdemand    : ob_iax_sin_tramita_demand
param out mensajes   : mensajes de error
return               : 0 -> Todo correcto
1 -> Se ha producido un error
Bug 19821 - 10/11/2011 - MDS
***********************************************************************/
FUNCTION f_set_objeto_demand(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pnlindem  IN NUMBER,
    psperson  IN NUMBER,
    pntipodem IN NUMBER,
    pttramita IN VARCHAR2,
    psperson2 IN NUMBER,
    pnprocedi IN VARCHAR2,
    ptcompani IN VARCHAR2,
    pdemand   IN OUT ob_iax_sin_tramita_demand,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_objeto_demand';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit || ' pnlindem : ' || pnlindem;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  -- Comprovación de los parámetros de entrada
  IF pntramit IS NULL OR pnlindem IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec         := 2;
  pdemand.nsinies  := pnsinies;
  pdemand.ntramit  := pntramit;
  pdemand.nlindem  := pnlindem;
  pdemand.sperson  := psperson;
  pdemand.ntipodem := pntipodem;
  pdemand.ttramita := pttramita;
  pdemand.sperson2 := psperson2;
  pdemand.nprocedi := pnprocedi;
  pdemand.tcompani := ptcompani;
  --
  vpasexec         := 3;
  pdemand.ttipodem := ff_desvalorfijo(800067, pac_md_common.f_get_cxtidioma, pntipodem);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_demand;
/*************************************************************************
FUNCTION f_del_demand
Borra un demantante/demandado
param in pnsinies    : número del siniestro
param in pntramit    : número tramitación siniestro
param in pnlindem    : número de línea de demantante/demandado
param out mensajes   : mensajes de error
return               : 0 -> Todo correcto
1 -> Se ha producido un error
Bug 19821 - 10/11/2011 - MDS
Bug 20340/109094 - 15/03/2012 - AMC
*************************************************************************/
FUNCTION f_del_demand(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pnlindem  IN NUMBER,
    pntipodem IN NUMBER,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_demand';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit : ' || pntramit || ' pnlindem : ' || pnlindem;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pnlindem IS NULL OR pntipodem IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_demand(pnsinies, pntramit, pnlindem, pntipodem);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_del_demand;
/*************************************************************************
FUNCTION f_actualiza_pago
Actualiza campos del pago
param in psidepag       : identificador del pago
param in pmediopago     : medio de pago
param in preferencia    : Número Factura/Referencia
pimp in impuestos_recibidos : impuestos
param out mensajes   : mensajes de error
return               : 0 -> Todo correcto
1 -> Se ha producido un error
*************************************************************************/
FUNCTION f_actualiza_pago(
    psidepag     IN NUMBER,
    pmediopago   IN NUMBER,
    preferencia  IN VARCHAR2,
    pfcambio     IN DATE,
    ptotal       IN NUMBER,
    piica        IN NUMBER,
    piiva        IN NUMBER,
    pireteica    IN NUMBER,
    pireteiva    IN NUMBER,
    piretenc     IN NUMBER,
    pmoneda      IN VARCHAR2 DEFAULT 'COP',
    piotrosgas   IN NUMBER,
    pibaseipoc   IN NUMBER,
    ppipoconsumo IN NUMBER,
    mensajes     IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_actualiza_pago';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag || ' pmediopago : ' || pmediopago || ' preferencia : ' || preferencia;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF psidepag IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_actualiza_pago(psidepag, pmediopago, preferencia, pfcambio, ptotal, piica, piiva, pireteica, pireteiva, piretenc, pmoneda, piotrosgas, pibaseipoc, ppipoconsumo);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_actualiza_pago;
/*************************************************************************
FUNCTION f_gestiona_cobpag
Borra un demantante/demandado
param in psidepag    : número del pago
param in pnmovpag    : número movimiento pago
param in pcestpag    : número de estado pago
param in pfefepag    : fecha efecto pago
param in pfcontab    : fecha contabilidad pago
param out mensajes   : mensajes de error
return               : 0 -> Todo correcto
1 -> Se ha producido un error
*************************************************************************/
FUNCTION f_gestiona_cobpag(
    psidepag IN NUMBER,
    pnmovpag IN NUMBER,
    pcestpag IN sin_tramita_movpago.cestpag%TYPE,
    pfefepag IN DATE,
    pfcontab IN DATE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_gestiona_cobpag';
  vparam      VARCHAR2(500) := 'parámetros - psidepag: ' || psidepag || ' pnmovpag : ' || pnmovpag || ' pcestpag : ' || pcestpag || ' pfefepag : ' || pfefepag || ' pfcontab : ' || pfcontab;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsinterf    NUMBER;
BEGIN
  IF psidepag IS NULL OR pnmovpag IS NULL OR pcestpag IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_gestiona_cobpag(psidepag, pnmovpag, pcestpag, pfefepag, pfcontab, vsinterf);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    --AÑADO EL MENSAJE DE ERROR QUE DEVUELVE EL HOST
    IF pac_con.f_tag(vsinterf, 'terror', 'TMENIN') IS NOT NULL AND vsinterf IS NOT NULL THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, pac_con.f_tag(vsinterf, 'cerror', 'TMENIN'), pac_con.f_tag(vsinterf, 'terror', 'TMENIN'));
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_gestiona_cobpag;
-- Ini Bug 21172 - MDS - 02/03/2012
/*************************************************************************
FUNCTION f_get_reserva_multiple
Devuelve las reservas efectuadas para un siniestro/trámite
param in  pnsinies : Número de siniestro
param in  pntramit : Número de trámite
param out t_iax_sin_trami_reserva_mult
param out t_iax_mensajes
return            : 0 -> Todo correcto
1 -> Se ha producido un error
*************************************************************************/
FUNCTION f_get_reserva_multiple(
    pnsinies IN sin_siniestro.nsinies%TYPE,
    pntramit IN sin_tramita_reserva.ntramit%TYPE,
    pctramit IN sin_tramitacion.ctramit%TYPE, -- 25812:ASN:23/01/2013
    t_reserva_mult OUT t_iax_sin_trami_reserva_mult,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  -- 26108 - de momento no se modifica esta funcion
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_reserva_multiple';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' ntramit: ' || pntramit;
  vpasexec    NUMBER        := 1;
  vnumerr     NUMBER        := 0;
  vtipoquery  NUMBER;
  vsquery     VARCHAR2(32000); -- BUG 0024774 - 20/11/2012 - JMF: añadir cselecc + orden
  vcvalpar    NUMBER;
  cur1 sys_refcursor;
  cur2 sys_refcursor;
  vctipres NUMBER;
  vttipres VARCHAR2(100);
  ob_reserva ob_iax_sin_trami_reserva;
  t_reserva t_iax_sin_trami_reserva;
  vireserva NUMBER;
  vsseguro  NUMBER;
  vnriesgo  NUMBER;
  v_aux     NUMBER; -- BUG 0024774 - 20/11/2012 - JMF: añadir cselecc + orden
BEGIN
  -- obtener parámetro RES_GAST_GARANT
  SELECT NVL(pac_parametros.f_parproducto_n(s.sproduc, 'RES_GAST_GARANT'), 1),
    s.sseguro,
    nriesgo
  INTO vcvalpar,
    vsseguro,
    vnriesgo
  FROM seguros s,
    sin_siniestro ss
  WHERE s.sseguro = ss.sseguro
  AND ss.nsinies  = pnsinies;
  vpasexec       := 2;
  t_reserva_mult := t_iax_sin_trami_reserva_mult();
  /* t_reserva_mult.EXTEND;
  t_reserva_mult(t_reserva_mult.LAST) := ob_iax_sin_trami_reserva_mult();
  */
  cur1 := pac_iax_listvalores_sin.f_get_lstctipres(mensajes);
  -- cursor de los diferentes tipos de reserva
  LOOP
    FETCH cur1 INTO vctipres, vttipres;
    EXIT
  WHEN cur1%NOTFOUND;
    vpasexec := 3;
    -- definir el tipo de query, en función de ctipres y vcvalpar
    IF vctipres   = 3 THEN
      IF vcvalpar = 0 THEN
        -- obtener la reserva del siniestro, y si no tiene obtener un registro con todo vacío
        vtipoquery  := 0;
      ELSIF vcvalpar = 1 THEN
        -- obtener la reserva del siniestro, y tantos registros como garantías
        vtipoquery  := 1;
      ELSIF vcvalpar = 2 THEN
        -- obtener la reserva del siniestro, y tantos registros como garantías, y un registro con todo vacío
        vtipoquery := 2;
      END IF;
    ELSE
      -- obtener la reserva del siniestro, y tantos registros como garantías
      vtipoquery := 1;
    END IF;
    -- crea un tipo de reserva nuevo
    t_reserva_mult.EXTEND;
    t_reserva_mult(t_reserva_mult.LAST) := ob_iax_sin_trami_reserva_mult();
    vireserva                           := 0;
    vpasexec                            := 4;
    vnumerr                             := pac_siniestros.f_get_reserva_multiple(vtipoquery, pnsinies, pntramit, pctramit, -- 25812:ASN:23/01/2013
    vctipres, pac_md_common.f_get_cxtidioma, vsquery);
    cur2                                        := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
    t_reserva_mult(t_reserva_mult.LAST).ctipres := vctipres;
    t_reserva_mult(t_reserva_mult.LAST).ttipres := vttipres;
    vpasexec                                    := 5;
    ob_reserva                                  := ob_iax_sin_trami_reserva();
    t_reserva                                   := t_iax_sin_trami_reserva();
    -- cursor de las reservas efectuadas para cada tipo de reserva
    -- BUG 0024774 - 20/11/2012 - JMF: añadir cselecc + orden
    LOOP
      FETCH cur2
      INTO ob_reserva.nsinies,
        ob_reserva.ntramit,
        ob_reserva.ctipres,
        ob_reserva.nmovres,
        ob_reserva.cgarant,
        ob_reserva.ccalres,
        ob_reserva.fmovres,
        ob_reserva.cmonres,
        ob_reserva.ireserva,
        ob_reserva.ipago,
        ob_reserva.iingreso,
        ob_reserva.irecobro,
        ob_reserva.fresini,
        ob_reserva.fresfin,
        ob_reserva.sidepag,
        ob_reserva.sproces,
        ob_reserva.fcontab,
        ob_reserva.falta,
        ob_reserva.cusumod,
        ob_reserva.fmodifi,
        ob_reserva.iprerec,
        ob_reserva.ttipres,
        ob_reserva.tgarant,
        ob_reserva.tcalres,
        ob_reserva.icaprie,
        ob_reserva.ipenali,
        ob_reserva.fultpag,
        ob_reserva.ctipgas,
        ob_reserva.ttipgas,
        ob_reserva.ireserva_moncia,
        ob_reserva.ipago_moncia,
        ob_reserva.iingreso_moncia,
        ob_reserva.irecobro_moncia,
        ob_reserva.icaprie_moncia,
        ob_reserva.ipenali_moncia,
        ob_reserva.iprerec_moncia,
        ob_reserva.cselecc,
        v_aux,
        ob_reserva.ndias; --BUG 27487/159742:NSS:26/11/2013
      EXIT
    WHEN cur2%NOTFOUND;
      vpasexec              := 6;
      IF ob_reserva.fresini IS NOT NULL AND ob_reserva.fresfin IS NOT NULL AND ob_reserva.ndias IS NULL THEN --BUG 27487/159742:NSS:26/11/2013
        ob_reserva.ndias    := (ob_reserva.fresfin - ob_reserva.fresini) + 1;
      END IF;
      IF ob_reserva.cmonres IS NULL THEN
        ob_reserva.cmonres  := pac_monedas.f_cmoneda_t(pac_parametros.f_parinstalacion_n('MONEDAINST'));
      END IF;
      IF ob_reserva.cmonres   IS NOT NULL THEN
        ob_reserva.tmonres    := pac_eco_monedas.f_descripcion_moneda(ob_reserva.cmonres, pac_md_common.f_get_cxtidioma, vnumerr);
        ob_reserva.cmonresint := ob_reserva.cmonres;
      END IF;
      IF ob_reserva.cgarant IS NOT NULL THEN
        BEGIN
          SELECT icapital
          INTO ob_reserva.icapgar
          FROM garanseg
          WHERE sseguro = vsseguro
          AND nriesgo   = vnriesgo
          AND cgarant   = ob_reserva.cgarant
          AND nmovimi   =
            (SELECT MAX(nmovimi)
            FROM garanseg
            WHERE sseguro = vsseguro
            AND nriesgo   = vnriesgo
            AND cgarant   = ob_reserva.cgarant
            AND ffinefe  IS NULL
            )
          AND ffinefe IS NULL;
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
      END IF;
      vpasexec := 7;
      t_reserva.EXTEND;
      t_reserva(t_reserva.LAST) := ob_reserva;
      vireserva                 := vireserva + NVL(ob_reserva.ireserva, 0);
    END LOOP;
    vpasexec := 8;
    -- guarda la información de las reservas efectuadas para el tipo de reserva
    t_reserva_mult(t_reserva_mult.LAST).reservas  := t_reserva;
    t_reserva_mult(t_reserva_mult.LAST).itotalres := vireserva;
  END LOOP;
  CLOSE cur2;
  CLOSE cur1;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_get_reserva_multiple;
/*************************************************************************
FUNCTION f_del_defraudador
Borra un defraudador
param in pnsinies  : número de siniestro
param in pndefrau  : número de defraudador
param out mensajes : mensajes de error
return             : 0 -> Todo correcto
1 -> Se ha producido un error
Bug 21855 - 07/05/2012 - MDS
*************************************************************************/
FUNCTION f_del_defraudador(
    pnsinies IN sin_defraudadores.nsinies%TYPE,
    pndefrau IN sin_defraudadores.ndefrau%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_del_defraudador';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pndefrau: ' || pndefrau;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  -- Comprobación de los parámetros de entrada
  -- pnsinies : es obligatorio
  -- pndefrau : es obligatorio
  IF pnsinies IS NULL OR pndefrau IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_defraudador(pnsinies, pndefrau);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_del_defraudador;
/***********************************************************************
FUNCTION f_set_defraudadores
Graba la colección de defraudadores
param in pnsinies         : número de siniestro
param in pdefraudadores   : t_iax_defraudadores
param out mensajes        : mensajes de error
return                    : 0 OK
1 Error
Bug 21855 - 07/05/2012 - MDS
***********************************************************************/
FUNCTION f_set_defraudadores(
    pnsinies       IN sin_defraudadores.nsinies%TYPE,
    pdefraudadores IN t_iax_defraudadores,
    mensajes       IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_defraudadores';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  -- Comprobación de los parámetros de entrada
  -- pnsinies : es obligatorio
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF pdefraudadores.COUNT > 0 THEN
    FOR i IN pdefraudadores.FIRST .. pdefraudadores.LAST
    LOOP
      vnumerr            := f_set_defraudador(pnsinies, pdefraudadores(i), mensajes);
      IF mensajes        IS NOT NULL THEN
        IF mensajes.COUNT > 0 THEN
          RETURN vnumerr;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_defraudadores;
/***********************************************************************
FUNCTION f_set_defraudador
Graba un defraudador
param in pnsinies         : número de siniestro
param in pdefraudador     : ob_iax_defraudadores
param out mensajes        : mensajes de error
return                    : 0 OK
1 Error
Bug 21855 - 07/05/2012 - MDS
***********************************************************************/
FUNCTION f_set_defraudador(
    pnsinies     IN sin_defraudadores.nsinies%TYPE,
    pdefraudador IN ob_iax_defraudadores,
    mensajes     IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_defraudador';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  vnumerr := pac_siniestros.f_ins_defraudador(pnsinies, pdefraudador.ndefrau, pdefraudador.sperson, pdefraudador.ctiprol, pdefraudador.finiefe, pdefraudador.ffinefe);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_defraudador;
/***********************************************************************
FUNCTION f_get_defraudadores
Recupera la colección de defraudadores
param in pnsinies         : número de siniestro
param out pdefraudadores  : t_iax_defraudadores
param out mensajes        : mensajes de error
return                    : 0 OK
1 Error
Bug 21855 - 07/05/2012 - MDS
***********************************************************************/
FUNCTION f_get_defraudadores(
    pnsinies IN sin_defraudadores.nsinies%TYPE,
    pdefraudadores OUT t_iax_defraudadores,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.F_get_defraudadores';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_defraud
  IS
    SELECT nsinies,
      ndefrau
    FROM sin_defraudadores
    WHERE nsinies = pnsinies
    ORDER BY ndefrau ASC;
BEGIN
  -- Comprobación de los parámetros de entrada
  -- pnsinies : puede ser NULL, ya que en el alta rápida de siniestro aún no tiene valor
  pdefraudadores := t_iax_defraudadores();
  FOR reg IN cur_defraud
  LOOP
    pdefraudadores.EXTEND;
    pdefraudadores(pdefraudadores.LAST) := ob_iax_defraudadores();
    vnumerr                             := f_get_defraudador(pnsinies, reg.ndefrau, pdefraudadores(pdefraudadores.LAST), mensajes);
    IF mensajes                         IS NOT NULL THEN
      IF mensajes.COUNT                  > 0 THEN
        RETURN 1;
      END IF;
    END IF;
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_defraudadores;
/***********************************************************************
FUNCTION f_get_defraudador
Recupera un defraudador
param in pnsinies         : número de siniestro
param in pndefrau         : número de defraudador
param out pdefraudador    : ob_iax_defraudadores
param out mensajes        : mensajes de error
return                    : 0 OK
1 Error
Bug 21855 - 07/05/2012 - MDS
***********************************************************************/
FUNCTION f_get_defraudador(
    pnsinies IN sin_defraudadores.nsinies%TYPE,
    pndefrau IN sin_defraudadores.ndefrau%TYPE,
    pdefraudador OUT ob_iax_defraudadores,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_defraudador';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pndefrau: ' || pndefrau;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vsquery     VARCHAR2(5000);
  cur sys_refcursor;
BEGIN
  pdefraudador := ob_iax_defraudadores();
  vnumerr      := pac_siniestros.f_get_defraudador(pnsinies, pndefrau, pac_md_common.f_get_cxtidioma, vsquery);
  cur          := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec     := 2;
  LOOP
    FETCH cur
    INTO pdefraudador.nsinies,
      pdefraudador.ndefrau,
      pdefraudador.sperson,
      pdefraudador.tperson,
      pdefraudador.ctiprol,
      pdefraudador.ttiprol,
      pdefraudador.finiefe,
      pdefraudador.ffinefe,
      pdefraudador.cusualt,
      pdefraudador.falta;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_defraudador;
/***********************************************************************
FUNCTION f_set_objeto_defraudador
Guarda en una variable global de la capa IAX los valores del objeto
param in pnsinies        : número de siniestro
param in pndefrau        : número de defraudador
...
...
...
param out pdefraudador   : ob_iax_defraudadores
param out mensajes       : mensajes de error
return                   : 0 -> Todo correcto
1 -> Se ha producido un error
Bug 21855 - 07/05/2012 - MDS
***********************************************************************/
FUNCTION f_set_objeto_defraudador(
    pnsinies     IN sin_defraudadores.nsinies%TYPE,
    pndefrau     IN sin_defraudadores.ndefrau%TYPE,
    psperson     IN sin_defraudadores.sperson%TYPE,
    pctiprol     IN sin_defraudadores.ctiprol%TYPE,
    pfiniefe     IN sin_defraudadores.finiefe%TYPE,
    pffinefe     IN sin_defraudadores.ffinefe%TYPE,
    pdefraudador IN OUT ob_iax_defraudadores,
    mensajes     IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_set_objeto_defraudador';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pndefrau : ' || pndefrau;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  vcagente    NUMBER        := NULL;
BEGIN
  -- Comprobación de los parámetros de entrada
  -- pnsinies : puede ser NULL, ya que en el alta rápida de siniestro aún no tiene valor
  -- pndefrau : es obligatorio
  IF pndefrau IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec             := 2;
  pdefraudador.nsinies := pnsinies;
  pdefraudador.ndefrau := pndefrau;
  pdefraudador.sperson := psperson;
  pdefraudador.ctiprol := pctiprol;
  pdefraudador.finiefe := pfiniefe;
  pdefraudador.ffinefe := pffinefe;
  vpasexec             := 3;
  IF pnsinies          IS NOT NULL THEN
    SELECT s.cagente
    INTO vcagente
    FROM seguros s,
      sin_siniestro si
    WHERE s.sseguro = si.sseguro
    AND si.nsinies  = pnsinies;
  END IF;
  pdefraudador.tperson := f_nombre(psperson, 1, vcagente);
  pdefraudador.ttiprol := ff_desvalorfijo(800084, pac_md_common.f_get_cxtidioma, pctiprol);
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_objeto_defraudador;
/***********************************************************************
FUNCTION f_get_personas_defraudadores
Recupera la lista de personas (defraudadores) relacionadas con el siniestro
param in psseguro          : número de seguro
param in pnsinies          : número de siniestro
param in pntipodefraudador : 1-Asegurado, 2-Tomador, 3-Mediador, 4-Persona relacionada
param out mensajes         : mensajes de error
return                     : sys_refcursor
Bug 21855 - 14/05/2012 - MDS
*************************************************************************/
FUNCTION f_get_personas_defraudadores(
    psseguro          IN NUMBER,
    pnsinies          IN sin_defraudadores.nsinies%TYPE,
    pntipodefraudador IN NUMBER,
    mensajes          IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vcagente NUMBER := NULL;
  num_err  NUMBER;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro || ' pnsinies: ' || pnsinies || ' pntipodefraudador: ' || pntipodefraudador;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_personas_defraudadores';
  vcursor sys_refcursor;
  vsquery VARCHAR2(5000);
BEGIN
  -- Comprobación de los parámetros de entrada
  -- pnsinies : puede ser NULL, ya que en el alta rápida de siniestro aún no tiene valor
  IF psseguro IS NULL OR pntipodefraudador IS NULL THEN
    RAISE e_param_error;
  END IF;
  -- obtener el agente del siniestro
  IF pnsinies IS NOT NULL THEN
    SELECT si.cagente
    INTO vcagente
    FROM seguros s,
      sin_siniestro si
    WHERE s.sseguro = si.sseguro
    AND si.nsinies  = pnsinies;
  END IF;
  vpasexec := 2;
  -- Asegurado
  IF pntipodefraudador = 1 THEN
    vsquery           := 'SELECT sperson, f_nombre(sperson, 1, ' || NVL(TO_CHAR(vcagente), 'NULL') || ') tperson FROM asegurados WHERE sseguro = ' || psseguro || ' ORDER BY norden';
  END IF;
  -- Tomador
  IF pntipodefraudador = 2 THEN
    vsquery           := 'SELECT sperson, f_nombre(sperson, 1, ' || NVL(TO_CHAR(vcagente), 'NULL') || ') tperson FROM tomadores WHERE sseguro = ' || psseguro || ' ORDER BY nordtom';
  END IF;
  -- Mediador
  IF pntipodefraudador = 3 THEN
    vsquery           := 'SELECT sperson, f_nombre(sperson, 1) tperson FROM agentes WHERE cagente = ' || NVL(TO_CHAR(vcagente), 'NULL');
  END IF;
  -- Perjudicado
  IF pntipodefraudador = 4 THEN
    vsquery           := 'SELECT sperson, f_nombre(sperson, 1, ' || NVL(TO_CHAR(vcagente), 'NULL') || ') tperson FROM sin_tramita_personasrel WHERE nsinies = ' || NVL(TO_CHAR(pnsinies), 'NULL');
  END IF;
  vpasexec := 3;
  vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
  RETURN vcursor;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
  RETURN NULL;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN NULL;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN NULL;
END f_get_personas_defraudadores;
/***********************************************************************
FUNCTION f_get_tramitador
Esta funcion devuelve el tramitador que toca, a la hora de dar de alta un tramite o
una tramitacion. Para ello busca en el movimiento anterior (o en el tramite si lo hay
y estamos dando de alta una tramitacion)
Cuando se trate de un alta de tramite/tramitacion invocara la funcion que obtiene automaticamente
el tramitador a partir de las condiciones parametrizadas.
p_nsinies IN numero de siniestro
p_ntramte IN numero de tramite
p_ntramit IN numero de tramitacion
p_cunitra   OUT unidad de tramitacion
p_ctramitad OUT tramitador
*************************************************************************/
FUNCTION f_get_tramitador(
    pnsinies IN NUMBER,
    pntramte IN NUMBER,
    pntramit IN NUMBER,
    pcunitra OUT VARCHAR2,
    pctramitad OUT VARCHAR2,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_IAX_SINIESTROS.f_get_tramitador';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramte:' || pntramte || ' pntramit:' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  vnumerr    := pac_siniestros.f_get_tramitador(pnsinies, pntramte, pntramit, pcunitra, pctramitad);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_tramitador;
/***********************************************************************
FUNCTION f_valida_tramitador
Compara el limite de autonomia del tramitador con la provision de la tramitacion
param in pnsinies          : número de siniestro
param in pntramit          : tramitacion
param in pctramtad         : tramitador
param in pccausin          : causa
param in pcmotsin          : motivo
param out mensajes         : mensajes de error
return                     : 0 - OK ; 1 - Error
*************************************************************************/
FUNCTION f_valida_tramitador(
    pnsinies   IN NUMBER,
    pntramit   IN NUMBER,
    pctramitad IN VARCHAR2,
    pccausin   IN NUMBER,
    pcmotsin   IN NUMBER,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  num_err  NUMBER;
  vparam   VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit || ' pctramitad:' || pctramitad || ' pccausin: ' || pccausin || ' pcmotsin: ' || pcmotsin;
  vpasexec NUMBER        := 1;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_valida_tramitador';
BEGIN
  num_err    := pac_siniestros.f_valida_tramitador(pnsinies, pntramit, pctramitad, pac_md_common.f_get_cxtempresa, pccausin, pcmotsin);
  vpasexec   := 2;
  IF num_err <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_valida_tramitador;
/***********************************************************************
FUNCTION f_tramitador_asignado
param in pctramtad         : tramitador
param out mensajes         : mensajes de error
return                     : 0 - OK ; 1 - Error
22670:ASN:28/06/2012
*************************************************************************/
FUNCTION f_tramitador_asignado(
    pctramitad IN VARCHAR2,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  tnombre VARCHAR2(100);
  literal VARCHAR2(400);
  vnumerr NUMBER;
BEGIN
  vnumerr := pac_siniestros.f_nombre_tramitador(pctramitad, tnombre);
  literal := pac_iobj_mensajes.f_get_descmensaje(9901927, pac_md_common.f_get_cxtidioma);
  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, literal || tnombre);
  RETURN vnumerr;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, 'f_tramitador_asignado', 1000001, 1, 'pctramitad=' || pctramitad, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_tramitador_asignado;
/*************************************************************************
FUNCTION f_post_siniestro
Acciones automaticas para ejecutar al dar de alta un siniestro
param in pnsinies  : número del siniestro
return             : codigo error
*************************************************************************/
FUNCTION f_post_siniestro(
    pnsinies sin_siniestro.nsinies%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_post_siniestro';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_post_siniestro(pnsinies);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN 1;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_post_siniestro;
/*************************************************************************
FUNCTION f_gestion_asignada
Crea mensaje cuando se asigna gestion automaticamente en alta de siniestro
param in pnsinies  : número del siniestro
return             : codigo error
*************************************************************************/
FUNCTION f_gestion_asignada(
    pnsinies sin_siniestro.nsinies%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  tmensaje VARCHAR2(400);
  literal  VARCHAR2(400);
  vtraza   NUMBER;
  vnumerr  NUMBER;
BEGIN
  vtraza      := 1;
  vnumerr     := pac_siniestros.f_nombre_profesional(pnsinies, pac_md_common.f_get_cxtidioma, tmensaje);
  vtraza      := 2;
  IF tmensaje IS NOT NULL THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, tmensaje);
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, 'f_gestion_asignada', 1000001, vtraza, 'pnsinies=' || pnsinies, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_gestion_asignada;
/*************************************************************************
FUNCTION f_estado_final
Cambia el estado a siniestro/presiniestro en funcion de la reserva en alta
param in pnsinies  : número del siniestro
return             : codigo error
*************************************************************************/
FUNCTION f_estado_final(
    pnsinies sin_siniestro.nsinies%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  hay_reserva NUMBER;
  vnumerr     NUMBER;
  vtmsg       VARCHAR2(4000);
  v_inform    VARCHAR2(500); -- 31872/178559:NSS:14/07/2014
  v_parempre  NUMBER;        -- CONF-513 /93.0 se adiciona v_parempre para cambiar mensaje por empresa
BEGIN
  vnumerr    := pac_siniestros.f_estado_final(pnsinies, hay_reserva);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
    RETURN vnumerr;
  END IF;
  --ini 31872/178559:NSS:14/07/2014
  vnumerr    := pac_siniestros.f_valida_carencia(pnsinies, v_inform);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
    RETURN vnumerr;
  END IF;
  IF v_inform <> 0 THEN
    vtmsg     := pac_iobj_mensajes.f_get_descmensaje(v_inform, pac_md_common.f_get_cxtidioma);
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg || pnsinies);
  ELSE
    IF hay_reserva > 0 THEN
      -- es un siniestro
      vtmsg := pac_iobj_mensajes.f_get_descmensaje(1000007, pac_md_common.f_get_cxtidioma);
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg || pnsinies);
    ELSE
      -- es un presiniestro, el mensaje es diferente
    v_parempre := pac_parametros.f_parempresa_n(f_empres(),'LIT_PRESINIESTRO');--CONF-513 /93.0 se adiciona v_parempre para cambiar mensaje por empresa
      vtmsg := pac_iobj_mensajes.f_get_descmensaje(NVL(v_parempre,9903757), pac_md_common.f_get_cxtidioma);--CONF-513 / 93.0 se adiciona v_parempre para cambiar mensaje por empresa
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg || 'C' || pnsinies);
    END IF;
  END IF;
  --fin 31872/178559:NSS:14/07/2014
  RETURN 0;
EXCEPTION
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_MD_SINIESTROS.f_estado_final', 1000006, 1, 'pmsinies=' || pnsinies);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, 'f_estado_final', 1000001, 1, 'pnsinies=' || pnsinies, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_estado_final;
/***********************************************************************
Recupera la colección de documentos de una tramitacion de siniestros
param in  pnsinies  : número de siniestro
param in  pntramit  : número de tramitación o todos si esta vacio
param out t_iax_sin_trami_documento :  t_iax_sin_trami_documento
param out mensajes  : mensajes de error
return              : 0 OK
1 Error
-- Bug 0022153 - 19/07/2012 - JMF
***********************************************************************/
FUNCTION f_get_sintradoc(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    t_docume OUT t_iax_sin_trami_documento,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  cur sys_refcursor;
  vsquery     VARCHAR2(5000);
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_sintradoc';
  vparam      VARCHAR2(500) := 'pnsinies:' || pnsinies || ' pntramit:' || pntramit;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  CURSOR cur_doc
  IS
    SELECT ntramit,
      ndocume
    FROM sin_tramita_documento
    WHERE nsinies = pnsinies
    AND(pntramit IS NULL
    OR ntramit    = pntramit)
    ORDER BY ntramit,
      ndocume ASC;
BEGIN
  vpasexec := 1;
  --Comprovació dels parámetres d'entrada
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec := 3;
  t_docume := t_iax_sin_trami_documento();
  vpasexec := 5;
  FOR reg IN cur_doc
  LOOP
    vpasexec := 7;
    t_docume.EXTEND;
    vpasexec                := 9;
    t_docume(t_docume.LAST) := ob_iax_sin_trami_documento();
    vpasexec                := 11;
    vnumerr                 := f_get_documento(pnsinies, reg.ntramit, reg.ndocume, t_docume(t_docume.LAST), mensajes);
    IF mensajes             IS NOT NULL THEN
      IF mensajes.COUNT      > 0 THEN
        RETURN 1;
      END IF;
    END IF;
  END LOOP;
  vpasexec := 13;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_sintradoc;
/***********************************************************************
FUNCTION f_set_tramitador
Graba el tramitador en el alta de siniestro
param in pnsinies          : número de siniestro
param in pcunitra          : unidad tramitacion
param in pctramtad         : tramitador
param out mensajes         : mensajes de error
return                     : 0 - OK ; 1 - Error
*************************************************************************/
FUNCTION f_set_tramitador(
    pnsinies   IN NUMBER,
    pcunitra   IN VARCHAR2,
    pctramitad IN VARCHAR2,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  num_err  NUMBER        := 0;
  vparam   VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies || ' pcunitra:' || pcunitra || ' pctramitad:' || pctramitad;
  vpasexec NUMBER        := 1;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_set_tramitador';
BEGIN
  num_err := pac_siniestros.f_set_tramitador(pnsinies, pcunitra, pctramitad);
  RETURN num_err;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_tramitador;
-- Ini Bug 23805 - MDS - 03/10/2012
/*************************************************************************
Función que indica si alguna de las garantías contratadas y
seleccionadas según pccausin, pcmotsin, pfsinies tiene asistencia.
phay_asistencia OUT --> 0 : No , >0 : Si
RETURN  0 : OK
>0 : Error
*************************************************************************/
FUNCTION f_hay_asistencia(
    psseguro IN NUMBER,
    pnriesgo IN NUMBER,
    pccausin IN NUMBER,
    pcmotsin IN NUMBER,
    pfsinies IN DATE,
    phay_asistencia OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vnumerr  NUMBER;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(100) := 'psseguro :' || psseguro || ' pnriesgo :' || pnriesgo || ' pccausin :' || pccausin || ' pcmotsin :' || pcmotsin || ' pfsinies :' || pfsinies;
  vobject  VARCHAR2(200) := 'PAC_MD_siniestros.F_hay_asistencia';
BEGIN
  vpasexec := 1;
  -- Comprobación de parámetros
  IF psseguro IS NULL OR pnriesgo IS NULL OR pccausin IS NULL OR pcmotsin IS NULL OR pfsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  vpasexec   := 2;
  vnumerr    := pac_siniestros.f_hay_asistencia(psseguro, pnriesgo, pccausin, pcmotsin, pfsinies, phay_asistencia);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_hay_asistencia;
-- Fin Bug 23805 - MDS - 03/10/2012
/*************************************************************************
FUNCTION f_repetido
Valida si hay otro siniestro con la misma causa y fecha. Mensaje informativo
param in pnsinies  : número del siniestro
return             : codigo error
24491:ASN:31/10/2012
*************************************************************************/
FUNCTION f_repetido(
    pnsinies sin_siniestro.nsinies%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_repetido';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_validaciones_sin.f_repetido(NULL, NULL, NULL, pnsinies);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_repetido;
/*************************************************************************
Devuelve los siniestros que cumplan con el criterio de selección
param in pnpoliza     : número de póliza
param in pncert       : número de cerificado por defecto 0
param in pnsinies     : número del siniestro
param in cestsin      : código situación del siniestro
param in pnnumide     : número identidad persona
param in psnip        : número identificador externo
param in pbuscar      : nombre+apellidos a buscar de la persona
param in ptipopersona : tipo de persona
1 tomador
2 asegurado
param out mensajes    : mensajes de error
return                : ref cursor
Bug 23740/123618 - 08/10/2012 - AMC
*************************************************************************/
FUNCTION f_consultasini2(
    pcramo     IN NUMBER,
    psproduc   IN NUMBER,
    pnpoliza   IN NUMBER,
    pncertif   IN NUMBER DEFAULT -1,
    pnsinies   IN VARCHAR2,
    pcestsin   IN NUMBER,
    pnnumide   IN VARCHAR2,
    psnip      IN VARCHAR2,
    pbuscar    IN VARCHAR2,
    ptipopers  IN NUMBER,
    pnsubest   IN NUMBER,
    pnsincia   IN VARCHAR2,
    pfalta     IN DATE,    --IAXIS-2169 AABC Adicion  de Fecha de Alta a la consulta de siniestro
    pccompani  IN NUMBER,
    pnpresin   IN VARCHAR2,
    pcsiglas   IN NUMBER,
    ptnomvia   IN VARCHAR2,
    pnnumvia   IN NUMBER,
    ptcomple   IN VARCHAR2,
    pcpostal   IN VARCHAR2,
    pcpoblac   IN NUMBER,
    pcprovin   IN NUMBER,
    pfgisx     IN FLOAT,
    pfgisy     IN FLOAT,
    pfgisz     IN FLOAT,
    ptdescri   IN VARCHAR2,
    pctipmat   IN NUMBER,
    pcmatric   IN VARCHAR2,
    ptiporisc  IN NUMBER,
    pcpolcia   IN VARCHAR2,
    pcactivi   IN NUMBER,
    pfiltro    IN NUMBER,
    pcagente   IN NUMBER,
    ptrefext   IN VARCHAR2, --  Bug: 0036232/207513    CJMR   16/06/2015
    pctipref   IN NUMBER,   --  Bug: 0036232/207513    CJMR   16/06/2015
    ptdescrie  IN VARCHAR2, -- BUG CONF_309 - 10/09/2016 - JAEG
    pncontrato IN VARCHAR2,   -- AP CONF-219
    mensajes   IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.ConsultaSini';
  vparam      VARCHAR2(500) := 'parámetros - pnpoliza: ' || pnpoliza || ' - pncertif: ' || pncertif || ' - pnsinies: ' || pnsinies || ' - pcestsin: ' || pcestsin || ' - pnnumide: ' || pnnumide || ' - psnip: ' || psnip || ' - pbuscar: ' || pbuscar || ' - ptipopers: ' || ptipopers || ' - pnsubest:' || pnsubest || ' - pcramo: ' || pcramo || ' - psproduc:' || psproduc || '- pnsincia: ' || pnsincia || '- pccompani: ' || pccompani || '- pnpresin: ' || pnpresin || '- pcsiglas: ' || pcsiglas || '- ptnomvia: ' || ptnomvia || '- pnnumvia: ' || pnnumvia || '- ptcomple: ' || ptcomple || '- pcpostal: ' || pcpostal || '- pcpoblac: ' || pcpoblac || '- pcprovin: ' || pcprovin || '- pfgisx: ' || pfgisx || '- pfgisy: ' || pfgisy || '- pfgisz: ' || pfgisz || '- ptdescri: ' || ptdescri || '- pctipmat: ' || pctipmat || '- pcmatric: ' || pcmatric || '- ptiporisc: ' || ptiporisc || '- pcpolcia : ' || pcpolcia || '- pcactivi : ' || pcactivi || ' pcagente=' || pcagente || '- ptrefext: ' || ptrefext ||
  '- ptdescrie: ' || ptdescrie || -- BUG CONF_309 - 10/09/2016 - JAEG
  '- pctipref: ' || pctipref;     --  Bug: 0036232/207513    CJMR   16/06/2015
  vpasexec NUMBER(5) := 1;
  vnumerr  NUMBER(8) := 0;
  vcursor sys_refcursor;
  vsquery      VARCHAR2(5000);
  vbuscar      VARCHAR2(2000);
  vsubus       VARCHAR2(500);
  vtabtp       VARCHAR2(10);
  vauxnom      VARCHAR2(200);
  vcont        NUMBER;
  nerr         NUMBER;
  v_sentence   VARCHAR2(500);
  p_filtroprod VARCHAR2(20);
  vcobjase     NUMBER;
  vqueryfiltro VARCHAR2(1100);
BEGIN
  vpasexec     := 3;
  nerr         := 0;
  v_sentence   := '';
  p_filtroprod := 'SINIESTRO';
  --IAXIS-2067 AABC 29/03/2019 Tipo de siniestro.
  vsquery      := ' SELECT se.sseguro , se.npoliza, se.ncertif, si.nsincia,  si.ccompani, (select tcompani from companias where ccompani = si.ccompani) tcompani, si.npresin, si.nsinies , si.nriesgo, se.sproduc, ' || ' PAC_MD_OBTENERDATOS.F_Desriesgos(''POL'', si.sseguro, si.nriesgo) as triesgo,' || ' f_desproducto_t(se.cramo,se.cmodali,se.ctipseg,se.ccolect,1,PAC_MD_COMMON.F_Get_CXTIDIOMA) as tproduc,' || ' si.fnotifi, si.FSINIES, si.tsinies, si.ccausin, se.cactivi,' || ' (select tcausin from sin_descausa where ccausin = si.ccausin and cidioma = ' || pac_md_common.f_get_cxtidioma || ') tcausin, si.cmotsin, ' || ' (select tmotsin from sin_desmotcau where ccausin = si.ccausin and cmotsin = si.cmotsin and cidioma = ' || pac_md_common.f_get_cxtidioma || ')  tmotsin,sm.cestsin, ff_desvalorfijo(6,' || pac_md_common.f_get_cxtidioma
  --  Bug: 0036232/207513    CJMR   16/06/2015  D01 A01
  --|| ', sm.cestsin) testsin FROM seguros se, sin_siniestro si, sin_movsiniestro sm ';
  /* Cambio de IAXIS-2069 IAXIS-2067 : Start */
  --', sm.cestsin) testsin FROM seguros se, sin_siniestro si, sin_movsiniestro sm'; --, sin_siniestro_referencias sr '; JGONZALEZ 24/10/2017
  ||
  -- INICIO IAXIS 3597 AABC 09/05/2017 CAMBIO DE CONSULTA
  ', sm.cestsin) testsin , sm.ctipsin , ff_desvalorfijo(8002010,' || pac_md_common.f_get_cxtidioma ||', sm.ctipsin) ttipsin,si.tdetpreten  FROM seguros se, sin_siniestro si, sin_movsiniestro sm ';
  --', sm.cestsin) testsin , sm.ctipsin , ff_desvalorfijo(8002010,' || pac_md_common.f_get_cxtidioma ||', sm.ctipsin) ttipsin  FROM seguros se, sin_siniestro si, sin_movsiniestro sm, sin_siniestro_referencias sr ';
  /* Cambio de IAXIS-2069 IAXIS-2067 : End */
  vbuscar := ' WHERE rownum <= NVL(' || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null') || ', rownum) ' || '   AND (se.cagente,se.cempres) in (select cagente,cempres from agentes_agente_pol) ';
  vbuscar := vbuscar || ' and se.sseguro = si.sseguro and sm.nsinies = si.nsinies ';
  vbuscar := vbuscar || '  and sm.nmovsin = (select max(nmovsin) from sin_movsiniestro where nsinies = si.nsinies) ';
 -- vbuscar := vbuscar || '  and sm.nmovsin = (select max(nmovsin) from sin_movsiniestro where nsinies = si.nsinies)  AND SI.NSINIES = SR.NSINIES(+)';
  -- FIN IAXIS 3597 AABC 09/05/2017 CAMBIO DE CONSULTA
  -- vbuscar := vbuscar || ' and exists (select 1 from sin_siniestro xx where xx.sseguro=se.sseguro)';
  --vbuscar     := vbuscar || ' and sr.nsinies (+) = si.nsinies'; --  Bug: 0036232/207513    CJMR   16/06/2015 -> JGONZALEZ 24/10/2017
  --Inicio IAXIS-2169 AABC Adicion FALTA a la consulta.
  IF pfalta     IS NOT NULL THEN
      vbuscar := vbuscar || '  and TRUNC(si.falta) = TO_DATE( '|| ''''|| TO_CHAR(PFALTA,'DD/MM/YYYY')||''''||',''DD/MM/YYYY'')';
   END IF;
  --Fin IAXIS-2169 AABC Adicion FALTA a la consulta.
  -- BUG 15006 - PFA - 17/08/2010 - Incluir nuevos campos
  vpasexec    := 5;
  IF pnsinies IS NOT NULL THEN
    vbuscar   := vbuscar || ' and si.nsinies = ' || pnsinies;
  END IF;
  IF pnpoliza IS NOT NULL THEN
    vbuscar   := vbuscar || ' and se.npoliza = ' || pnpoliza;
  END IF;
  IF NVL(pncertif, -1) <> -1 THEN
    vbuscar            := vbuscar || ' and se.ncertif = ' || pncertif;
  END IF;
  IF pcpolcia IS NOT NULL THEN
    vbuscar   := vbuscar || ' and se.cpolcia = ' || CHR(39) || pcpolcia || CHR(39);
  END IF;
  IF pccompani IS NOT NULL THEN
    vbuscar    := vbuscar || ' and se.ccompani = ' || pccompani;
  END IF;
  IF pcagente IS NOT NULL THEN
    vbuscar   := vbuscar || ' and exists (select 1 from sin_siniestro x2 where x2.sseguro=se.sseguro and x2.cagente=' || pcagente || ')';
  END IF;
  IF NVL(psproduc, 0) <> 0 THEN
    vbuscar           := vbuscar || ' and se.sproduc =' || psproduc;
  ELSE
    nerr    := pac_productos.f_get_filtroprod(p_filtroprod, v_sentence);
    IF nerr <> 0 THEN
      RAISE e_object_error;
    END IF;
    IF v_sentence IS NOT NULL THEN
      vbuscar     := vbuscar || ' and se.sproduc in (select p.sproduc from productos p where' || v_sentence || ' 1=1)';
    END IF;
    IF pcramo IS NOT NULL THEN
      vbuscar := vbuscar || ' and se.sproduc in (select p.sproduc from productos p where' || ' p.cramo = ' || pcramo || ' )';
    END IF;
  END IF;
  IF pcactivi IS NOT NULL THEN
    vbuscar   := vbuscar || ' and se.cactivi = ' || pcactivi;
  END IF;
  IF pcestsin IS NOT NULL THEN
    --IF pnsinies IS NOT NULL THEN
    vsquery := vsquery || ',  riesgos r ';
    --END IF;
    vbuscar := vbuscar || ' and si.sseguro = se.sseguro and sm.nsinies = si.nsinies' || ' and se.sseguro = r.sseguro and r.nriesgo = si.nriesgo' || ' and sm.NMOVSIN = (select max(nmovsin)' || ' from sin_movsiniestro s' || ' where s.NSINIES = si.NSINIES' || ' and si.SSEGURO = se.SSEGURO )' || ' and sm.cestsin = ' || pcestsin;
  END IF;
  IF pnsincia     IS NOT NULL THEN
    IF pcestsin   IS NULL THEN
      IF pnsinies IS NULL THEN
        --vsquery := vsquery || ', sin_siniestro si ';  -- 25/06/2015 la tabla SIN_SINIESTRO ya esta en el FROM
        NULL;
      ELSE
        vsquery := vsquery || ',  riesgos r ';
      END IF;
      vbuscar := vbuscar || ' and si.sseguro = se.sseguro and se.sseguro = r.sseguro and r.nriesgo = si.nriesgo and si.nsincia = ' || CHR(39) || pnsincia || CHR(39);
    ELSE
      vbuscar := vbuscar || ' and si.nsincia = ' || CHR(39) || pnsincia || CHR(39);
    END IF;
  END IF;
  IF (pnpresin    IS NOT NULL) THEN
    IF pnsincia   IS NULL AND pcestsin IS NULL THEN
      IF pnsinies IS NULL THEN
        --vsquery := vsquery || ', sin_siniestro si '; -- 25/06/2015 la tabla SIN_SINIESTRO ya esta en el FROM
        NULL;
      ELSE
        vsquery := vsquery || ',  riesgos r ';
      END IF;
      IF (pccompani  IS NOT NULL AND pnpresin IS NOT NULL) THEN
        vbuscar      := vbuscar || ' and si.sseguro = se.sseguro and se.sseguro = r.sseguro and r.nriesgo = si.nriesgo and se.ccompani = ' || pccompani || ' and si.npresin = ' || pnpresin;
      ELSIF pnpresin IS NOT NULL THEN
        vbuscar      := vbuscar || ' and si.sseguro = se.sseguro and se.sseguro = r.sseguro and r.nriesgo = si.nriesgo and si.npresin = ' || pnpresin;
      END IF;
    ELSE
      IF pnpresin IS NOT NULL THEN
        vbuscar   := vbuscar || ' and si.npresin = ' || pnpresin;
      END IF;
    END IF;
  END IF;
  IF psproduc IS NOT NULL THEN
    SELECT cobjase INTO vcobjase FROM productos WHERE sproduc = psproduc;
  END IF;
  vpasexec     := 7;
  IF ptiporisc IS NOT NULL OR vcobjase IS NOT NULL THEN
    IF (ptiporisc IN(1, 3, 4)) OR(vcobjase IN(3, 4)) THEN
      IF ptdescri IS NOT NULL THEN
        vbuscar   := vbuscar || ' AND se.sseguro IN (SELECT ri.sseguro FROM riesgos ri WHERE upper(ri.tnatrie) = upper(''%' || ptdescri || '%'')) ';
      END IF;
    ELSIF (ptiporisc    = 2) OR(vcobjase IN(2)) THEN
      vsquery          := vsquery || ', sitriesgo sit ';
      vbuscar          := vbuscar || ' and sit.sseguro = se.sseguro ';
      IF (pcpostal     IS NOT NULL OR pcpoblac IS NOT NULL OR pcsiglas IS NOT NULL OR pnnumvia IS NOT NULL OR ptnomvia IS NOT NULL OR pcprovin IS NOT NULL OR ptcomple IS NOT NULL OR pfgisx IS NOT NULL OR pfgisy IS NOT NULL OR pfgisz IS NOT NULL) THEN
        IF (pcpostal   IS NOT NULL AND pcpoblac IS NOT NULL) THEN
          vbuscar      := vbuscar || ' and upper(sit.cpostal) like upper(''%' || pcpostal || '%'') and upper(sit.cpoblac) like upper(''%' || pcpoblac || '%'') ';
        ELSIF pcpostal IS NOT NULL THEN
          vbuscar      := vbuscar || ' and upper(sit.cpostal) like upper(''%' || pcpostal || '%'') ';
        ELSIF pcpoblac IS NOT NULL THEN
          vbuscar      := vbuscar || ' and upper(sit.cpoblac) like upper(''%' || pcpoblac || '%'') ';
        END IF;
        IF pcsiglas IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.csiglas) like upper(''%' || pcsiglas || '%'') ';
        END IF;
        IF ptnomvia IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.tnomvia) like upper(''%' || ptnomvia || '%'') ';
        END IF;
        IF pnnumvia IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.nnumvia) like upper(''%' || pnnumvia || '%'') ';
        END IF;
        IF pcprovin IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.cprovin) like upper(''%' || pcprovin || '%'') ';
        END IF;
        IF ptcomple IS NOT NULL THEN
          vbuscar   := vbuscar || ' and upper(sit.tcomple) like upper(''%' || ptcomple || '%'') ';
        END IF;
        IF pfgisx IS NOT NULL THEN
          vbuscar := vbuscar || ' and upper(sit.fgisx) like upper(''%' || pfgisx || '%'') ';
        END IF;
        IF pfgisy IS NOT NULL THEN
          vbuscar := vbuscar || ' and upper(sit.fgisy) like upper(''%' || pfgisy || '%'') ';
        END IF;
        IF pfgisz IS NOT NULL THEN
          vbuscar := vbuscar || ' and upper(sit.fgisz) like upper(''%' || pfgisz || '%'') ';
        END IF;
      END IF;
    ELSIF (ptiporisc    = 5) OR(vcobjase IN(2)) THEN
      vsquery          := vsquery || ', autriesgos aut ';
      vbuscar          := vbuscar || ' and aut.sseguro = se.sseguro ';
      IF (pcmatric     IS NOT NULL OR pctipmat IS NOT NULL) THEN
        IF (pcmatric   IS NOT NULL AND pctipmat IS NOT NULL) THEN
          vbuscar      := vbuscar || ' and upper(aut.cmatric) like upper(''%' || pcmatric || '%'') and upper(aut.ctipmat) like upper(''%' || pctipmat || '%'') ';
        ELSIF pcmatric IS NOT NULL THEN
          vbuscar      := vbuscar || ' and upper(aut.cmatric) like upper(''%' || pcmatric || '%'') ';
        ELSIF pctipmat IS NOT NULL THEN
          vbuscar      := vbuscar || ' and upper(aut.ctipmat) like upper(''%' || pctipmat || '%'') ';
        END IF;
      END IF;
    END IF;
  END IF;
  -- INICIO Bug: 0036232/207513    CJMR   16/06/2015
  /**
  -- Buscar per personas
  IF (pnnumide IS NOT NULL
  OR NVL(psnip, '0') <> '0'
  OR pbuscar IS NOT NULL)
  AND NVL(ptipopers, 0) > 0 THEN
  --
  IF ptipopers = 1 THEN   -- Prenador
  vtabtp := 'TOMADORES';
  ELSIF ptipopers = 2 THEN   -- Asegurat
  vtabtp := 'ASEGURADOS';
  ELSIF ptipopers = 3 THEN
  vtabtp := 'SIN_TRAMITA_PERSONAREL';   --Persones relacionats
  END IF;
  vpasexec := 9;
  IF vtabtp IS NOT NULL THEN
  vsubus := ' AND se.sseguro IN (SELECT a.sseguro FROM ' || vtabtp
  || ' a, PERSONAS p WHERE a.sperson = p.sperson ';
  IF ptipopers = 2 THEN   -- Asegurat
  vsubus := vsubus || ' AND a.ffecfin IS NULL';
  END IF;
  IF pnnumide IS NOT NULL THEN
  vsubus := vsubus || ' AND upper(p.nnumnif) = upper(''' || pnnumide || ''')';
  END IF;
  IF NVL(psnip, '0') <> '0' THEN
  vsubus := vsubus || ' AND upper(p.snip)=upper(' || CHR(39) || psnip || CHR(39)
  || ')';
  END IF;
  IF pbuscar IS NOT NULL THEN
  vnumerr := f_strstd(pbuscar, vauxnom);
  vsubus := vsubus || ' AND upper(p.tbuscar) like upper(''%' || vauxnom || '%'')';
  END IF;
  vsubus := vsubus || ') ';
  vbuscar := vbuscar || vsubus;
  END IF;
  END IF;
  **/
  -- Busqueda por persona
  IF (pnnumide IS NOT NULL OR psnip IS NOT NULL OR pbuscar IS NOT NULL OR ptipopers = 4) -- BUG CONF_309 - 10/09/2016 - JAEG
    THEN
    vpasexec      := 9;
    IF ptipopers   = 1 THEN
      vbuscar     := vbuscar || ' AND se.sseguro IN(SELECT a.sseguro FROM tomadores a, personas p WHERE a.sperson = p.sperson';
      IF pnnumide IS NOT NULL THEN
        --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
        IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NIF_MINUSCULAS'), 0) = 1 THEN
          vbuscar                                                                                   := vbuscar || ' AND UPPER(p.nnumnif) = UPPER(''' || pnnumide || ''')';
        ELSE
          vbuscar := vbuscar || ' AND p.nnumnif = ''' || pnnumide || '''';
        END IF;
      END IF;
      IF psnip  IS NOT NULL THEN
        vbuscar := vbuscar || ' AND UPPER(p.snip) = UPPER(''' || psnip || ''')';
      END IF;
      IF pbuscar IS NOT NULL THEN
        vbuscar  := vbuscar || ' AND p.tbuscar LIKE UPPER(''%' || pbuscar || '%'') ';
      END IF;
      vbuscar      := vbuscar || ')';
    ELSIF ptipopers = 2 THEN
      vbuscar      := vbuscar || ' AND si.nsinies IN(SELECT s.nsinies FROM sin_siniestro s, asegurados a, personas p WHERE a.sseguro = s.sseguro AND a.sperson = p.sperson AND a.ffecfin IS NULL';
      IF pnnumide  IS NOT NULL THEN
        --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
        IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NIF_MINUSCULAS'), 0) = 1 THEN
          vbuscar                                                                                   := vbuscar || ' AND UPPER(p.nnumnif) = UPPER(''' || pnnumide || ''')';
        ELSE
          vbuscar := vbuscar || ' AND p.nnumnif = ''' || pnnumide || '''';
        END IF;
      END IF;
      IF psnip  IS NOT NULL THEN
        vbuscar := vbuscar || ' AND UPPER(p.snip) = UPPER(''' || psnip || ''')';
      END IF;
      IF pbuscar IS NOT NULL THEN
        vbuscar  := vbuscar || ' AND p.tbuscar LIKE UPPER(''%' || pbuscar || '%'') ';
      END IF;
      vbuscar     := vbuscar || ' UNION SELECT s.nsinies FROM sin_siniestro s, sin_tramita_personasrel a, personas p WHERE s.nsinies = a.nsinies AND a.sperson = p.sperson AND a.ctiprel = 4';
      IF pnnumide IS NOT NULL THEN
        --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
        IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NIF_MINUSCULAS'), 0) = 1 THEN
          vbuscar                                                                                   := vbuscar || ' AND UPPER(p.nnumnif) = UPPER(''' || pnnumide || ''')';
        ELSE
          vbuscar := vbuscar || ' AND p.nnumnif = ''' || pnnumide || '''';
        END IF;
      END IF;
      IF psnip  IS NOT NULL THEN
        vbuscar := vbuscar || ' AND UPPER(p.snip) = UPPER(''' || psnip || ''')';
      END IF;
      IF pbuscar IS NOT NULL THEN
        vbuscar  := vbuscar || ' AND p.tbuscar LIKE UPPER(''%' || pbuscar || '%'') ';
      END IF;
      vbuscar      := vbuscar || ')';
    ELSIF ptipopers = 3 THEN
      vbuscar      := vbuscar || ' AND si.nsinies IN(SELECT s.nsinies FROM sin_siniestro s, sin_tramita_personasrel a, personas p WHERE s.nsinies = a.nsinies AND a.sperson = p.sperson';
      IF pnnumide  IS NOT NULL THEN
        --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
        IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NIF_MINUSCULAS'), 0) = 1 THEN
          vbuscar                                                                                   := vbuscar || ' AND UPPER(p.nnumnif) = UPPER(''' || pnnumide || ''')';
        ELSE
          vbuscar := vbuscar || ' AND p.nnumnif = ''' || pnnumide || '''';
        END IF;
      END IF;
      IF psnip  IS NOT NULL THEN
        vbuscar := vbuscar || ' AND UPPER(p.snip) = UPPER(''' || psnip || ''')';
      END IF;
      IF pbuscar IS NOT NULL THEN
        vbuscar  := vbuscar || ' AND p.tbuscar LIKE UPPER(''%' || pbuscar || '%'') ';
      END IF;
      vbuscar := vbuscar || ')';
      -- INI BUG CONF_309 - 10/09/2016 - JAEG
    ELSIF ptipopers = 4 THEN
	 -- bug 4713 busqueda de siniestro mas espesifica con la descripcion
     IF ptdescrie IS NOT NULL THEN
       vbuscar   := vbuscar || ' AND si.nsinies IN (SELECT s.nsinies FROM sin_siniestro s, sin_tramita_personasrel a where s.nsinies = a.nsinies and upper(a.tdesc) LIKE upper(''%' || ptdescrie || '%'')) ';

      END IF;
    END IF;
  END IF;
  -- INICIO IAXIS 3597 AABC 09/05/2017 CAMBIO DE CONSULTA
  IF pctipref IS NOT NULL  OR  ptrefext IS NOT NULL THEN
    vsquery          := vsquery || ', SIN_SINIESTRO_REFERENCIAS sr ';
    vbuscar   := vbuscar || ' AND SI.NSINIES = SR.NSINIES(+)';
  IF pctipref IS NOT NULL THEN
    vbuscar   := vbuscar || ' AND sr.ctipref = ' || pctipref;
  END IF;
  IF ptrefext IS NOT NULL THEN
    vbuscar   := vbuscar || ' AND UPPER(sr.trefext) LIKE  UPPER(''%' || ptrefext || '%'')';
  END IF;
  -- FIN IAXIS 3597 AABC 09/05/2017 CAMBIO DE CONSULTA
  END IF;
  -- FIN Bug: 0036232/207513    CJMR   16/06/2015
  IF pfiltro                                                                                 = 0 THEN
    IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'FILTRO_AGE'), 0) = 1 THEN
      vqueryfiltro                                                                          := vqueryfiltro || ' and se.cagente in (SELECT a.cagente
FROM (SELECT     LEVEL nivel, cagente
FROM redcomercial r
WHERE
r.fmovfin is null
START WITH
r.cagente = ' || pac_md_common.f_get_cxtagente || ' AND r.cempres = ' || pac_md_common.f_get_cxtempresa ||
      ' and r.fmovfin is null
CONNECT BY PRIOR r.cagente =(r.cpadre + 0)
AND PRIOR r.cempres =(r.cempres + 0)
and r.fmovfin is null
AND r.cagente >= 0) rr,
agentes a
where rr.cagente = a.cagente) ';
    END IF;
  END IF;
  --Ini CONF-219 AP
  IF pncontrato IS NOT NULL THEN
    vbuscar     := vbuscar || ' AND EXISTS ( select 1 FROM PREGUNPOLSEG P WHERE p.sseguro = se.sseguro and p.nmovimi = ' || '  (select max(nmovimi)from pregunpolseg p1 where p1.sseguro = p.sseguro and p1.cpregun = p.cpregun) ' || ' and p.cpregun = 4097 AND p.trespue = '''||pncontrato|| ''') ';
  END IF;
  --Fi CONF-219 AP
  vbuscar                                                                                     := vbuscar || vqueryfiltro;
  vpasexec                                                                                    := 11;
  vsquery                                                                                     := vsquery || vbuscar;
  vpasexec                                                                                    := 12;
  vcursor                                                                                     := pac_md_listvalores.f_opencursor(vsquery, mensajes);
  vpasexec                                                                                    := 13;
  IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_SINIESTROS.F_CONSULTASINI2', 1, 4, mensajes) <> 0 THEN
    IF vcursor%ISOPEN THEN
      CLOSE vcursor;
    END IF;
  END IF;
  RETURN vcursor;
EXCEPTION
WHEN OTHERS THEN
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN vcursor;
END f_consultasini2;
/***********************************************************************
FUNCTION f_mensajes_axissin049
Pregunta si realmente quieren guardar en una variable global de la capa IAX los valores del objeto ob_iax_siniestros.tramitacion.juzgado
nsinies        VARCHAR2(14),   --Número Siniestro
ntramit        NUMBER(3),      --Número Tramitación Siniestro
nlinjuz        NUMBER(6),      --Número Línea
...
...
...
return               : 0 -> Todo correcto
1 -> Se ha producido un error
Bug 25204 - 19/12/2012 - NSS
***********************************************************************/
FUNCTION f_mensajes_axissin049(
    pnsinies  IN VARCHAR2,
    pntramit  IN NUMBER,
    pnlinjuz  IN NUMBER,
    pcorgjud  IN NUMBER,
    pnorgjud  IN VARCHAR2,
    ptrefjud  IN VARCHAR2,
    pcsiglas  IN NUMBER,
    ptnomvia  IN VARCHAR2,
    pnnumvia  IN NUMBER,
    ptcomple  IN VARCHAR2,
    ptdirec   IN VARCHAR2,
    pcpais    IN NUMBER,
    pcprovin  IN NUMBER,
    pcpoblac  IN NUMBER,
    pcpostal  IN VARCHAR2,
    ptasunto  IN VARCHAR2,
    pnclasede IN NUMBER,
    pntipopro IN NUMBER,
    pnprocedi IN VARCHAR2,
    pfnotiase IN DATE,
    pfrecpdem IN DATE,
    pfnoticia IN DATE,
    pfcontase IN DATE,
    pfcontcia IN DATE,
    pfaudprev IN DATE,
    pfjuicio  IN DATE,
    pcmonjuz  IN VARCHAR2,
    pcpleito  IN NUMBER,
    pipleito  IN NUMBER,
    piallana  IN NUMBER,
    pisentenc IN NUMBER,
    pisentcap IN NUMBER,
    pisentind IN NUMBER,
    pisentcos IN NUMBER,
    pisentint IN NUMBER,
    pisentotr IN NUMBER,
    pcargudef IN NUMBER,
    pcresplei IN NUMBER,
    pcapelant IN NUMBER,
    pthipoase IN VARCHAR2,
    pthipoter IN VARCHAR2,
    pttipresp IN VARCHAR2,
    pcopercob IN NUMBER,
    ptreasmed IN VARCHAR2,
    pcestproc IN NUMBER,
    pcetaproc IN NUMBER,
    ptconcjur IN VARCHAR2,
    ptestrdef IN VARCHAR2,
    ptrecomen IN VARCHAR2,
    ptobserv  IN VARCHAR2,
    pfcancel  IN DATE,
    otexto OUT VARCHAR2,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  numerr NUMBER := 0;
BEGIN
  numerr := pac_propio.f_mensajes_axissin049(pnsinies, pntramit, pnlinjuz, pcorgjud, pnorgjud, ptrefjud, pcsiglas, ptnomvia, pnnumvia, ptcomple, ptdirec, pcpais, pcprovin, pcpoblac, pcpostal, ptasunto, pnclasede, pntipopro, pnprocedi, pfnotiase, pfrecpdem, pfnoticia, pfcontase, pfcontcia, pfaudprev, pfjuicio, pcmonjuz, pcpleito, pipleito, piallana, pisentenc, pisentcap, pisentind, pisentcos, pisentint, pisentotr, pcargudef, pcresplei, pcapelant, pthipoase, pthipoter, pttipresp, pcopercob, ptreasmed, pcestproc, pcetaproc, ptconcjur, ptestrdef, ptrecomen, ptobserv, pfcancel, otexto);
  RETURN numerr;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_MD_SINIESTROS.f_mensajes_axissin049', 1000001, 1, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_mensajes_axissin049;
/*************************************************************************
FUNCTION f_msg_responsable
Envia mensaje al responsable de siniestros
23101:ASN:21/12/2012
*************************************************************************/
FUNCTION f_msg_responsable(
    pnsinies sin_siniestro.nsinies%TYPE,
    pntramte IN sin_tramite.ntramte%TYPE,
    pntramit IN sin_tramitacion.ntramit%TYPE,
    pcconapu IN agd_apunte.cconapu%TYPE,
    plit1    IN axis_literales.slitera%TYPE,
    plit2    IN axis_literales.slitera%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_msg_responsable';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
BEGIN
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_tramitadores.f_msg_responsable(pnsinies, pntramte, pntramit, 1, plit1, plit2);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_msg_responsable;
FUNCTION f_get_agente_npol(
    psseguro IN NUMBER,
    pcagente OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_agente_npol';
  vparam      VARCHAR2(500) := 'parámetros - psseguro:' || psseguro;
  vnumerr     NUMBER(8)     := 0;
  vpasexec    NUMBER(5)     := 1;
BEGIN
  IF psseguro IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_get_agente_npol(psseguro, pcagente);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_agente_npol;
-- BUG 25800:NSS:21/02/2013
FUNCTION f_get_preg_siniestro(
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pcgarant IN VARCHAR2,
    pccausin IN NUMBER, --27354:NSS:18/06/2013
    pcmotsin IN NUMBER, --27354:NSS:18/06/2013
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param psproduc=' || psproduc || ' pcactivi= ' || pcactivi || ' pcgarant: ' || pcgarant || 'pccausin: ' || pccausin || ' pcmotsin: ' || pcmotsin;
  vobject  VARCHAR2(200) := 'PAC_MD_PROF.F_GET_PREG_SINIESTRO';
  terror   VARCHAR2(200) := ' Error a recuperar preguntas del siniestro';
  vnerror  NUMBER;
  vquery   VARCHAR2(5000);
BEGIN
  vnerror := pac_siniestros.f_get_preg_siniestro(psproduc, pcactivi, pcgarant, pccausin, pcmotsin, --27354:NSS:18/06/2013
  pac_md_common.f_get_cxtidioma(), vquery);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_preg_siniestro;
FUNCTION f_get_resp_siniestro(
    pcpregun IN VARCHAR2,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param pcpregun=' || pcpregun;
  vobject  VARCHAR2(200) := 'PAC_MD_PROF.F_GET_resp_SINIESTRO';
  terror   VARCHAR2(200) := ' Error a recuperar respuestas del siniestro';
  vnerror  NUMBER;
  vquery   VARCHAR2(5000);
BEGIN
  vnerror    := pac_siniestros.f_get_resp_siniestro(pcpregun, pac_md_common.f_get_cxtidioma(), vquery);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_resp_siniestro;
FUNCTION f_ins_preguntas(
    ptpreguntas IN t_iax_sin_preguntas,
    psproduc    IN NUMBER,
    pcactivi    IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vparam   VARCHAR2(500) := 'param pcpregun=';
  vobject  VARCHAR2(200) := 'PAC_MD_PROF.f_ins_preguntas';
  terror   VARCHAR2(200) := ' Error insertar respuestas siniestro';
  vnumerr  NUMBER        := 0;
  vpasexec NUMBER(8)     := 1;
BEGIN
  IF ptpreguntas IS NOT NULL AND ptpreguntas.COUNT > 0 THEN
    vnumerr      := pac_siniestros.f_limpia_preguntas(ptpreguntas(ptpreguntas.FIRST).nsinies);
    FOR i IN ptpreguntas.FIRST .. ptpreguntas.LAST
    LOOP
      IF ptpreguntas.EXISTS(i) THEN
        IF ptpreguntas(i).trespuestas IS NOT NULL AND ptpreguntas(i).trespuestas.COUNT > 0 THEN
          FOR j IN ptpreguntas(i).trespuestas.FIRST .. ptpreguntas(i).trespuestas.LAST
          LOOP
            IF ptpreguntas(i).trespuestas.EXISTS(j) THEN
              vnumerr := pac_siniestros.f_ins_pregunta(ptpreguntas(i).nsinies, ptpreguntas(i).cpregun, ptpreguntas(i).trespuestas(j).crespue, ptpreguntas(i).trespuestas(j).trespue);
            END IF;
          END LOOP;
        END IF;
      END IF;
    END LOOP;
  END IF;
  vnumerr    := f_get_preguntas(psproduc, pcactivi, pac_iax_siniestros.vgobsiniestro.nsinies, pac_iax_siniestros.vgobsiniestro.preguntas, mensajes);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_ins_preguntas;
FUNCTION f_get_preguntas(
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pnsinies IN NUMBER,
    ppreguntas OUT t_iax_sin_preguntas,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_preguntas';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' psproduc: ' || psproduc || ' pcactivi: ' || pcactivi;
  vnumerr     NUMBER(8)     := 0;
  vpasexec    NUMBER(5)     := 1;
  vquery      VARCHAR2(5000);
  vpregunta ob_iax_sin_preguntas;
  vpregunta_ant ob_iax_sin_preguntas;
  vrespuesta ob_iax_sin_respuestas;
  trespuestas t_iax_sin_respuestas;
  vcont NUMBER(8) := 0;
  cur sys_refcursor;
BEGIN
  IF pnsinies IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr       := pac_siniestros.f_get_preguntas(psproduc, pcactivi, pnsinies, pac_md_common.f_get_cxtidioma(), vquery);
  vpregunta     := ob_iax_sin_preguntas();
  vpregunta_ant := ob_iax_sin_preguntas();
  vrespuesta    := ob_iax_sin_respuestas();
  trespuestas   := t_iax_sin_respuestas();
  ppreguntas    := t_iax_sin_preguntas();
  cur           := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  LOOP
    FETCH cur
    INTO vpregunta.cpregun,
      vpregunta.ctippre,
      vpregunta.cpretip,
      vpregunta.nbloque,
      vpregunta.npreord,
      vpregunta.tprefor,
      vpregunta.tpregun,
      vpregunta.timagen,
      vrespuesta.crespue,
      vrespuesta.trespue;
    IF vcont = 0 THEN
      ppreguntas.EXTEND;
      ppreguntas(ppreguntas.LAST) := vpregunta;
    END IF;
    IF vcont       > 0 AND ppreguntas(ppreguntas.LAST).cpregun <> vpregunta.cpregun THEN
      trespuestas := t_iax_sin_respuestas();
      trespuestas.EXTEND;
      trespuestas(trespuestas.LAST) := vrespuesta;
      vpregunta.nsinies             := pnsinies;
      vpregunta.trespuestas         := trespuestas;
      ppreguntas.EXTEND;
      ppreguntas(ppreguntas.LAST) := vpregunta;
    ELSE
      trespuestas.EXTEND;
      trespuestas(trespuestas.LAST)           := vrespuesta;
      ppreguntas(ppreguntas.LAST).nsinies     := pnsinies;
      ppreguntas(ppreguntas.LAST).trespuestas := trespuestas;
    END IF;
    vcont      := vcont + 1;
    vrespuesta := ob_iax_sin_respuestas();
    vpregunta  := ob_iax_sin_preguntas();
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_preguntas;
-- FIN BUG 25800:NSS:21/02/2013
FUNCTION f_get_lstlocaliza(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param pnsinies=' || pnsinies || ' pntramit= ' || pntramit;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.F_GET_LSTLOCALIZA';
  terror   VARCHAR2(200) := ' Error a recuperar localizaciones';
  vnerror  NUMBER;
  vquery   VARCHAR2(5000);
BEGIN
  vnerror    := pac_siniestros.f_get_lstlocaliza(pnsinies, pntramit, vquery);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_lstlocaliza;
FUNCTION f_get_localiza(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pnlocali IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param pnsinies=' || pnsinies || ' pntramit= ' || pntramit || ' pnlocali=' || pnlocali;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.F_GET_LOCALIZA';
  terror   VARCHAR2(200) := ' Error a recuperar localizacion';
  vnerror  NUMBER;
  vquery   VARCHAR2(5000);
BEGIN
  vnerror    := pac_siniestros.f_get_localiza(pnsinies, pntramit, pnlocali, pac_md_common.f_get_cxtidioma(), vquery, NULL);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_localiza;
FUNCTION f_get_vehiculo_asegurado(
    psseguro IN NUMBER,
    pnriesgo IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param sseguro=' || psseguro || ' pnriesgo= ' || pnriesgo;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_vehiculo_asegurado';
  terror   VARCHAR2(200) := ' Error a recuperar datos vehiculo';
  vsseguro NUMBER;
  vquery   VARCHAR2(2000);
BEGIN
  vquery := 'SELECT rie.ctipmat, rie.cmatric, rie.cversion, pac_autos.f_desversion(rie.cversion) tversion,
ver.cmarca, ver.ctipveh, ver.cmodelo, rie.anyo,
rie.triesgo, rie.codmotor, rie.cchasis, rie.nbastid, rie.ccilindraje
FROM AUTRIESGOS RIE, AUT_VERSIONES VER
WHERE sseguro= ' || psseguro || 'AND nriesgo= ' || pnriesgo || 'AND rie.cversion = ver.cversion
AND nmovimi= (SELECT MAX (nmovimi) FROM autriesgos a1
WHERE a1.sseguro = rie.sseguro
AND a1.nriesgo = rie.nriesgo)';
  cur    := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_vehiculo_asegurado;
-- Bug 27514/147806 - 04/07/2013 - AMC
FUNCTION f_get_limite_tramitador(
    pctramitad IN VARCHAR2,
    pcempres   IN NUMBER,
    pcramo     IN NUMBER,
    pccausin   IN NUMBER,
    pcmotsin   IN NUMBER,
    pilimite OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname     VARCHAR2(500) := 'pac_siniestros.f_get_limite_tramitador';
  vparam          VARCHAR2(500) := 'parámetros - pctramitad:' || pctramitad || ' pcempres: ' || pcempres || ' pcramo: ' || pcramo || ' pccausin: ' || pccausin || ' pcmotsin: ' || pcmotsin;
  vpasexec        NUMBER        := 1;
  vimporte_tramit NUMBER;
  vlimite         NUMBER;
  vnumerr         NUMBER;
BEGIN
  vnumerr := pac_siniestros.f_get_limite_tramitador(pctramitad, pcempres, pcramo, pccausin, pcmotsin, pilimite);
  -- 30299 - 05/03/2014 - JTT: Controlem si es produeix error i generem el missatge
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RETURN vnumerr;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_limite_tramitador;
--Ini Bug 24708:NSS:10/10/2013
FUNCTION f_get_lstoficinas(
    pcbanco IN NUMBER,
    pcofici IN NUMBER,
    ptofici IN VARCHAR2,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param pcbanco=' || pcbanco || ' pcofici= ' || pcofici || ' ptofici=' || ptofici;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_lstoficinas';
  terror   VARCHAR2(200) := ' Error a recuperar oficinas';
  vnerror  NUMBER;
  vquery   VARCHAR2(5000);
BEGIN
  vnerror    := pac_siniestros.f_get_lstoficinas(pcbanco, pcofici, ptofici, vquery);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_lstoficinas;
FUNCTION f_get_beneficiario_designado(
    pnsinies IN VARCHAR2,
    psseguro IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param pnsinies=' || pnsinies || ' psseguro=' || psseguro;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_beneficiario_designado';
  terror   VARCHAR2(200) := ' Error a recuperar oficinas';
  vnerror  NUMBER;
  vquery   VARCHAR2(5000);
BEGIN
  vnerror    := pac_siniestros.f_get_beneficiario_designado(pnsinies, psseguro, vquery);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_beneficiario_designado;
--Fin Bug 24708:NSS:10/10/2013
--Ini Bug 28506:NSS:16/10/2013
FUNCTION f_get_garantias_dependientes(
    pgarantias IN VARCHAR2,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param pgarantias=' || pgarantias;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_garantias_dependientes';
  terror   VARCHAR2(200) := ' Error a recuperar garantias';
  vnerror  NUMBER;
  vquery   VARCHAR2(5000);
BEGIN
  vnerror    := pac_siniestros.f_get_garantias_dependientes(pgarantias, pac_md_common.f_get_cxtempresa, vquery);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_garantias_dependientes;
--Fin Bug 28506:NSS:16/10/2013
FUNCTION f_actualiza_preguntas(
    pnsinies IN VARCHAR2,
    psseguro IN NUMBER,
    pfsinies IN DATE,
    pcmotsin IN NUMBER,
    pccausin IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'pac_md_siniestros.f_actualiza_preguntas';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' psseguro: ' || psseguro || ' pfsinies: ' || pfsinies || ' pcmotsin: ' || pcmotsin || ' pccausin: ' || pccausin;
  vpasexec    NUMBER        := 1;
  vnumerr     NUMBER;
  --30/10/2013 :ASN :0024708: (POSPG500)- Parametrizacion - Sinestros/0157275 actualizar preguntas
BEGIN
  vnumerr := pac_siniestros.f_actualiza_preguntas(pnsinies, psseguro, pfsinies, pcmotsin, pccausin, pac_md_common.f_get_cxtidioma);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_actualiza_preguntas;
--Ini Bug 28506:NSS:28/10/2013
FUNCTION f_get_inf_reaseguro(
    pnsinies IN VARCHAR2,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param pnsinies=' || pnsinies;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_inf_reaseguro';
  terror   VARCHAR2(200) := ' Error a recuperar garantias';
  vnerror  NUMBER;
  vquery   VARCHAR2(5000);
BEGIN
  vnerror    := pac_siniestros.f_get_inf_reaseguro(pnsinies, pac_md_common.f_get_cxtidioma, vquery);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_inf_reaseguro;
--Fin Bug 28506:NSS:28/10/2013
--BUG 24637/147756 - 28/08/2013 - NSS
FUNCTION f_objcalcula_imports_detpagos(
    psperson  IN NUMBER,
    pcagente  IN NUMBER,
    pfordpag  IN DATE,
    psidepag  IN NUMBER,
    pctipgas  IN NUMBER,
    pcconcep  IN NUMBER,
    pimporte  IN NUMBER,
    piretenc  IN OUT NUMBER,
    ppretenc  IN OUT NUMBER,
    piiva     IN OUT NUMBER,
    ppiva     IN OUT NUMBER,
    pineta    IN OUT NUMBER,
    piica     IN OUT NUMBER,
    ppica     IN OUT NUMBER,
    pireteiva IN OUT NUMBER,
    ppreteiva IN OUT NUMBER,
    pireteica IN OUT NUMBER,
    ppreteica IN OUT NUMBER,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname     VARCHAR2(500) := 'pac_md_siniestros.f_objcalcula_imports_detpagos';
  vparam          VARCHAR2(500) := 'parámetros - psperson:' || psperson || ' pcagente: ' || pcagente || ' pfordpag: ' || pfordpag || ' psidepag: ' || psidepag || ' pcconcep: ' || pcconcep || ' pimporte: ' || pimporte || ' piretenc: ' || piretenc || ' ppretenc: ' || ppretenc || ' piiva: ' || piiva || ' ppiva: ' || ppiva || ' pineta: ' || pineta || ' piica: ' || piica || ' ppica: ' || ppica || ' pireteiva: ' || pireteiva || ' ppreteiva: ' || ppreteiva || ' pireteica: ' || pireteica || ' ppreteica: ' || ppreteica;
  vpasexec        NUMBER        := 1;
  vimporte_tramit NUMBER;
  vlimite         NUMBER;
  vnumerr         NUMBER;
  vctipper        NUMBER(3);
  vcregfiscal     NUMBER(3);
  vsprofes        VARCHAR2(6);
  vcpais          NUMBER(3);
  vcprovin        NUMBER(3);
  vcpoblac        NUMBER(5);
  vsimplog        NUMBER;
  vtot_imp        NUMBER;
  vquery          VARCHAR2(5000);
  cur sys_refcursor;
  vccodimp NUMBER;
  vctipcal NUMBER;
  vnporcen NUMBER;
  vifijo   NUMBER;
  vnvalimp NUMBER;
  vcconcep NUMBER;
BEGIN
  vnumerr    := pac_sin_impuestos.f_destinatario(psperson, pcagente, pfordpag, NULL, vctipper, vcregfiscal, vsprofes, vcpais, vcprovin, vcpoblac);
  vpasexec   := 1;
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  vpasexec   := 2;
  vnumerr    := pac_sin_impuestos.f_get_cconcep(pcconcep, vcconcep);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  vnumerr    := pac_sin_impuestos.f_calc_tot_imp(pfordpag, psidepag, NULL, pctipgas, vcconcep, pimporte, vctipper, vcregfiscal, vsprofes, vcpais, vcprovin, vcpoblac, vsimplog, vtot_imp);
  vpasexec   := 3;
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  vnumerr  := pac_sin_impuestos.f_get_impuestos_calculados(vsimplog, vquery);
  vpasexec := 4;
  cur      := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  vpasexec := 5;
  LOOP
    FETCH cur INTO vccodimp, vctipcal, vnporcen, vifijo, vnvalimp;
    IF vccodimp = 1 --IVA
      THEN
      IF vctipcal = 2 --PORCENTAJE
        THEN
        ppiva := vnporcen;
      END IF;
      piiva := vnvalimp;
    END IF;
    vpasexec   := 6;
    IF vccodimp = 2 --RETEIVA
      THEN
      IF vctipcal = 2 --PORCENTAJE
        THEN
        ppreteiva := vnporcen;
      END IF;
      pireteiva := vnvalimp;
    END IF;
    vpasexec   := 7;
    IF vccodimp = 10 --RETENCION
      THEN
      IF vctipcal = 2 --PORCENTAJE
        THEN
        ppretenc := vnporcen;
      END IF;
      piretenc := vnvalimp;
    END IF;
    vpasexec := 8;
    EXIT
  WHEN cur%NOTFOUND;
  END LOOP;
  piretenc  := NVL(piretenc, 0);
  ppretenc  := NVL(ppretenc, 0);
  piiva     := NVL(piiva, 0);
  ppiva     := NVL(ppiva, 0);
  pineta    := NVL(pineta, 0);
  piica     := NVL(piica, 0);
  ppica     := NVL(ppica, 0);
  pireteiva := NVL(pireteiva, 0);
  ppreteiva := NVL(ppreteiva, 0);
  pireteica := NVL(pireteica, 0);
  ppreteica := NVL(ppreteica, 0);
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_objcalcula_imports_detpagos;
--Ini Bug 29177/160128:NSS:13/01/2014
FUNCTION f_ins_pago_contrato(
    psidepag  IN NUMBER,
    pcdp      IN VARCHAR2,
    ppospres  IN VARCHAR2,
    pcrp      IN VARCHAR2,
    pposcrp   IN VARCHAR2,
    pcontrato IN VARCHAR2,
    pcgestor  IN VARCHAR2,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'pac_md_siniestros.f_ins_pago_contrato';
  vparam      VARCHAR2(500) := 'parámetros - psidepag:' || psidepag || ' pcdp: ' || pcdp || ' ppospres: ' || ppospres || ' pcrp: ' || pcrp || ' pposcrp: ' || pposcrp || ' pcontrato: ' || pcontrato || ' pcgestor: ' || pcgestor;
  vpasexec    NUMBER        := 1;
  vnumerr     NUMBER;
BEGIN
  vnumerr    := pac_siniestros.f_ins_pago_contrato(psidepag, pcdp, ppospres, pcrp, pposcrp, pcontrato, pcgestor);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_ins_pago_contrato;
--Fin Bug 29177/160128:NSS:13/01/2014
-- BUG 28830:NSS:06/11/2013 - Compensación de siniestros contra cartera.
FUNCTION f_get_cartera_pendiente(
    psseguro IN seguros.sseguro%TYPE,
    pnriesgo IN sin_siniestro.nriesgo%TYPE,
    pnsinies IN sin_siniestro.nsinies%TYPE,
    psidepag IN sin_tramita_pago.sidepag%TYPE,
    ptotal OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  /*************************************************************************
  Devuelve el sumatorio de los recibos pendientes
  *************************************************************************/
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_get_cartera_pendiente';
  vparam      VARCHAR2(500) := 'parámetros - psseguro:' || psseguro || ' pnriesgo:' || pnriesgo || ' pnsinies: ' || pnsinies || ' psidepag:' || psidepag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  cur sys_refcursor;
  vnrecibo recibos.nrecibo%TYPE;
  vfefecto recibos.fefecto%TYPE;
  vccobban recibos.ccobban%TYPE;
  vcdelega recibos.cdelega%TYPE;
  vtotrec      NUMBER;
  vdias_gracia NUMBER;
  vquery       VARCHAR2(4000);
  vntramit sin_tramita_pago.ntramit%TYPE;
  vipago sin_tramita_pago.isinret%TYPE;
  vsperson sin_tramita_pago.sperson%TYPE;
  vfordpag sin_tramita_pago.fordpag%TYPE;
  vcmonpag sin_tramita_pago.cmonpag%TYPE;
  vcconpag sin_tramita_pago.cconpag%TYPE;
  vccauind sin_tramita_pago.ccauind%TYPE;
  vcbancar sin_tramita_pago.cbancar%TYPE;
  vctipdes sin_tramita_pago.ctipdes%TYPE;
  vctippag sin_tramita_pago.ctippag%TYPE;
  vcforpag sin_tramita_pago.cforpag%TYPE;
  vctipban sin_tramita_pago.ctipban%TYPE;
  vcultpag sin_tramita_pago.cultpag%TYPE;
  virestorec sin_recibos_compensados.irestorec%TYPE;
  vcestcomp sin_recibos_compensados.cestcomp%TYPE;
  vcestaux recibos.cestaux%TYPE;
  v_recunif_nrecibo recibos.nrecibo%TYPE;
  v_recunif_cestaux recibos.cestaux%TYPE;
  vcontinue BOOLEAN;
BEGIN
  vnumerr    := pac_siniestros.f_get_cartera_pendiente(psseguro, pnriesgo, vquery);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  vpasexec := 2;
  cur      := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  vpasexec := 3;
  ptotal   := 0;
  LOOP
    FETCH cur
    INTO vnrecibo,
      vfefecto,
      vccobban,
      vcdelega,
      vtotrec,
      virestorec,
      vcestcomp,
      vcestaux;
    EXIT
  WHEN cur%NOTFOUND;
    -- Bug 33798 -  JTT - 20/03/2015: Eliminamos la validación de los dias de gracia de los recibos
    vcontinue := FALSE;
    -- Bug 33798 - JTT - 19/05/2015: El campo RECIBOS.cestaux indica si el estado de envio del recibo.
    -- Si RECIBOS.cestaux = 0 --> Recibo enviado, se puede compensar
    -- Si RECIBOS.cestaux = 2 --> Recibo agrupado, consultamos si el recibo 'padre' que los agrupa ha sido enviado.
    -- Recibos con otros valores no se gestionan, no han sido enviados.
    IF vcestaux    = 0 THEN -- Recibos enviados
      vcontinue   := TRUE;
    ELSIF vcestaux = 2 THEN -- Recibos agrupados
      BEGIN
        -- Recuperamos el número de recibo 'padre' y actualizamos el num recibo a tratar (vnrecibo)
        SELECT r.nrecibo,
          r.cestaux
        INTO v_recunif_nrecibo,
          v_recunif_cestaux
        FROM adm_recunif u,
          recibos r
        WHERE r.nrecibo = u.nrecunif
        AND r.cestaux   = 0
        AND u.nrecibo   = vnrecibo;
        vcontinue      := TRUE;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;
    END IF;
    IF vcontinue THEN
      -- Acumulamos para obtener el total de los recibos
      ptotal := ptotal + vtotrec;
    END IF;
  END LOOP;
  vnumerr    := pac_siniestros.f_get_datos_pago(psidepag, vntramit, vsperson, vctipdes, vctippag, vipago, vcforpag, vfordpag, vcconpag, vccauind, vctipban, vcbancar, vcmonpag, vcultpag);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  IF ptotal > vipago THEN
    ptotal := 0;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN 1;
END f_get_cartera_pendiente;
FUNCTION f_compensa_recibos_gar(
    psseguro IN seguros.sseguro%TYPE,
    pnriesgo IN sin_siniestro.nriesgo%TYPE,
    pnsinies IN sin_siniestro.nsinies%TYPE,
    psidepag IN sin_tramita_pago.sidepag%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  /*************************************************************************************
  Por cada detalle del pago inicial se recorren los recibos pendientes para compensar
  *************************************************************************************/
  terror      VARCHAR2(200) := 'Error al recorrer detalles de pago';
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_compensa_recibos_gar';
  vparam      VARCHAR2(500) := 'parámetros - psseguro:' || psseguro || ' pnriesgo:' || pnriesgo || ' pnsinies: ' || pnsinies || ' psidepag:' || psidepag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  cur sys_refcursor;
  vntramit NUMBER;
  vipago sin_tramita_pago.isinret%TYPE;
  vsperson sin_tramita_pago.sperson%TYPE;
  vfordpag sin_tramita_pago.fordpag%TYPE;
  vcmonpag sin_tramita_pago.cmonpag%TYPE;
  vcconpag sin_tramita_pago.cconpag%TYPE;
  vccauind sin_tramita_pago.ccauind%TYPE;
  vcbancar sin_tramita_pago.cbancar%TYPE;
  vctipdes sin_tramita_pago.ctipdes%TYPE;
  vctippag sin_tramita_pago.ctippag%TYPE;
  vcforpag sin_tramita_pago.cforpag%TYPE;
  vctipban sin_tramita_pago.ctipban%TYPE;
  vcultpag sin_tramita_pago.cultpag%TYPE;
  vctipres sin_tramita_pago_gar.ctipres%TYPE;
  vnmovres sin_tramita_pago_gar.nmovres%TYPE;
  vcgarant sin_tramita_pago_gar.cgarant%TYPE;
  vfperini sin_tramita_pago_gar.fperini%TYPE;
  vfperfin sin_tramita_pago_gar.fperfin%TYPE;
  vcmonres sin_tramita_pago_gar.cmonres%TYPE;
  visinret sin_tramita_pago_gar.isinret%TYPE;
  vcmonpag_gar sin_tramita_pago_gar.cmonpag%TYPE;
  visinretpag sin_tramita_pago_gar.isinretpag%TYPE;
  vfcambio sin_tramita_pago_gar.fcambio%TYPE;
  vcconpag_gar sin_tramita_pago_gar.cconpag%TYPE;
  vnorden sin_tramita_pago_gar.norden%TYPE;
  vtotal_cartera        NUMBER := 0;
  vresto_pago           NUMBER;
  vquery                VARCHAR2(2000);
  vpago_inicial_anulado NUMBER := 0;
  vsidepag_new sin_tramita_pago.sidepag%TYPE;
  vsidepag_cab sin_tramita_pago.sidepag%TYPE;
BEGIN
  vnumerr    := pac_siniestros.f_get_datos_pago(psidepag, vntramit, vsperson, vctipdes, vctippag, vipago, vcforpag, vfordpag, vcconpag, vccauind, vctipban, vcbancar, vcmonpag, vcultpag);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  vpasexec   := 2;
  vnumerr    := pac_siniestros.f_get_datos_pago_gar(psidepag, vquery);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  vpasexec := 2;
  cur      := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  vpasexec := 3;
  LOOP
    FETCH cur
    INTO vctipres,
      vnmovres,
      vcgarant,
      vfperini,
      vfperfin,
      vcmonres,
      visinret,
      vcmonpag_gar,
      visinretpag,
      vfcambio,
      vcconpag_gar,
      vnorden;
    EXIT
  WHEN cur%NOTFOUND;
    vnumerr := pac_md_siniestros.f_compensa_recibos(psseguro, pnriesgo, pnsinies, psidepag, vntramit, vsperson, vctipdes, vctippag, vipago, vcforpag, vfordpag, vcconpag, vccauind, vctipban, vcbancar, vcmonpag, vcultpag, vctipres, vnmovres, vcgarant, vfperini, vfperfin, vcmonres, visinret, vcmonpag_gar, visinretpag, vfcambio, vcconpag_gar,
    --vnorden,
    NULL, --27062014
    vsidepag_cab, vtotal_cartera, vresto_pago, vsidepag_new, mensajes);
    vsidepag_cab := vsidepag_new;
    IF vnumerr   <> 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
      RAISE e_object_error;
    END IF;
    vpasexec := 4;
    /** Si después de compensar los recibos pendientes (vsidepag IS NOT null),
    aun queda importe de pago, se paga ese resto al asegurado **/
    IF vresto_pago > 0 AND vsidepag_cab IS NOT NULL THEN -- 33544 - JTT - 20/01/2015
      vnumerr     := pac_md_siniestros.f_pago_resto_asegurado(pnsinies, psidepag, vctipres, vnmovres, vresto_pago, vfperini, vfperfin, mensajes);
      IF vnumerr  <> 0 THEN
        RAISE e_object_error;
      END IF;
      vpasexec := 6;
    END IF;
  END LOOP;
  RETURN 0;
EXCEPTION
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN 1;
END f_compensa_recibos_gar;
FUNCTION f_compensa_recibos(
    psseguro     IN seguros.sseguro%TYPE,
    pnriesgo     IN sin_siniestro.nriesgo%TYPE,
    pnsinies     IN sin_siniestro.nsinies%TYPE,
    psidepag     IN sin_tramita_pago.sidepag%TYPE,
    pntramit     IN sin_tramita_pago.ntramit%TYPE,
    psperson     IN sin_tramita_pago.sperson%TYPE,
    pctipdes     IN sin_tramita_pago.ctipdes%TYPE,
    pctippag     IN sin_tramita_pago.ctippag%TYPE,
    pipago       IN sin_tramita_pago.isinret%TYPE,
    pcforpag     IN sin_tramita_pago.cforpag%TYPE,
    pfordpag     IN sin_tramita_pago.fordpag%TYPE,
    pcconpag     IN sin_tramita_pago.cconpag%TYPE,
    pccauind     IN sin_tramita_pago.ccauind%TYPE,
    pctipban     IN sin_tramita_pago.ctipban%TYPE,
    pcbancar     IN sin_tramita_pago.cbancar%TYPE,
    pcmonpag     IN sin_tramita_pago.cmonpag%TYPE,
    pcultpag     IN sin_tramita_pago.cultpag%TYPE,
    pctipres     IN sin_tramita_pago_gar.ctipres%TYPE,
    pnmovres     IN sin_tramita_pago_gar.nmovres%TYPE,
    pcgarant     IN sin_tramita_pago_gar.cgarant%TYPE,
    pfperini     IN sin_tramita_pago_gar.fperini%TYPE,
    pfperfin     IN sin_tramita_pago_gar.fperfin%TYPE,
    pcmonres     IN sin_tramita_pago_gar.cmonres%TYPE,
    pisinret     IN sin_tramita_pago_gar.isinret%TYPE,
    pcmonpag_gar IN sin_tramita_pago_gar.cmonpag%TYPE,
    pisinretpag  IN sin_tramita_pago_gar.isinretpag%TYPE,
    pfcambio     IN sin_tramita_pago_gar.fcambio%TYPE,
    pcconpag_gar IN sin_tramita_pago_gar.cconpag%TYPE,
    pnorden      IN sin_tramita_pago_gar.norden%TYPE,
    psidepag_cab IN sin_tramita_pago.sidepag%TYPE,
    ptotal OUT NUMBER,
    prestopag OUT NUMBER,
    psidepag_new OUT sin_tramita_pago.sidepag%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  /*************************************************************************************
  Por cada recibo pendiente, crea un pago del mismo importe con destinatario la empresa
  *************************************************************************************/
  terror      VARCHAR2(200) := 'Error al compensar recibos';
  vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_compensa_recibos';
  vparam      VARCHAR2(500) := 'parámetros - psseguro:' || psseguro || ' pnriesgo:' || pnriesgo || ' pnsinies: ' || pnsinies || ' psidepag:' || psidepag;
  vpasexec    NUMBER(5)     := 1;
  vnumerr     NUMBER(8)     := 0;
  cur sys_refcursor;
  vsperson per_personas.sperson%TYPE;
  vnrecibo NUMBER;
  vfefecto recibos.fefecto%TYPE;
  vccobban recibos.ccobban%TYPE;
  vcdelega recibos.cdelega%TYPE;
  vcestaux recibos.cestaux%TYPE;
  visinret sin_tramita_pago_gar.isinret%TYPE;
  vtotrec        NUMBER;
  vquery         VARCHAR2(2000);
  virestorec     NUMBER;
  virestorec_act NUMBER;
  vimpcomp       NUMBER;
  vcestcomp      VARCHAR2(1);
  vsidepag_cab sin_tramita_pago.sidepag%TYPE;
  vno_crear_cab_pago NUMBER;
  vnmovpag_new sin_tramita_movpago.nmovpag%TYPE;
  vno_anular_pago NUMBER;
  vcontinue       BOOLEAN;
BEGIN
  vpasexec   := 2;
  vnumerr    := pac_siniestros.f_destinatario_empresa(pnsinies, pntramit, pac_md_common.f_get_cxtempresa(), vsperson);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  vpasexec   := 3;
  vnumerr    := pac_siniestros.f_get_cartera_pendiente(psseguro, pnriesgo, vquery);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  vpasexec        := 4;
  cur             := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  vpasexec        := 5;
  ptotal          := 0;
  visinret        := pisinret; --Importe del pago
  vno_anular_pago := 0;
  LOOP
    FETCH cur
    INTO vnrecibo,
      vfefecto,
      vccobban,
      vcdelega,
      vtotrec,
      virestorec,
      vcestcomp,
      vcestaux;
    EXIT
  WHEN cur%NOTFOUND;
    vcontinue := FALSE;
    -- Bug 33798 - JTT - 19/05/2015: El campo RECIBOS.cestaux indica si el estado de envio del recibo.
    -- Si RECIBOS.cestaux = 0 --> Recibo enviado, se puede compensar
    -- Si RECIBOS.cestaux = 2 --> Recibo agrupado, consultamos si el recibo 'padre' que los agrupa ha sido enviado.
    -- Recibos con otros valores no se gestionan, no han sido enviados.
    IF vcestaux    = 0 THEN -- Recibos enviados
      vcontinue   := TRUE;
    ELSIF vcestaux = 2 THEN -- Recibos agrupados
      BEGIN
        -- Recuperamos el número de recibo 'padre' y actualizamos el num recibo a tratar (vnrecibo)
        SELECT r.nrecibo
        INTO vnrecibo
        FROM adm_recunif u,
          recibos r
        WHERE r.nrecibo = u.nrecunif
        AND r.cestaux   = 0
        AND u.nrecibo   = vnrecibo;
        vcontinue      := TRUE;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;
    END IF;
    IF vcontinue THEN
      IF visinret         = 0 --Se ha agotado este detalle de pago para compensar recibos
        OR virestorec_act > 0 --Se tiene que usar el siguiente detalle de pago para acabar de compensar el recibo actual
        THEN
        EXIT;
      END IF;
      ptotal := ptotal + vtotrec;
      /* Se comprueba si es el resto de recibo pendiente de compensar por el detalle de pago anterior*/
      IF virestorec         > 0 AND vcestcomp = 'P' THEN
        vtotrec            := virestorec;
        vno_crear_cab_pago := 1;
        vsidepag_cab       := psidepag_cab;
      ELSE
        vno_crear_cab_pago := 0;
      END IF;
      IF visinret > vtotrec THEN
        /* Si el importe del detalle del pago es superior al importe del recibo, se compensa todo el recibo*/
        vimpcomp       := vtotrec;
        visinret       := visinret - vtotrec;
        virestorec_act := 0;
      ELSE
        /* Si no, se compensará el resto de importe del recibo con el detalle del pago siguiente*/
        vimpcomp       := visinret;
        visinret       := 0;
        virestorec_act := vtotrec - vimpcomp;
      END IF;
      vpasexec          := 6;
      IF vno_anular_pago = 0 THEN -- Anulamos el pago inicial una unica vez, para el primer recibo
        vnumerr         := pac_md_siniestros.f_anula_pago(psidepag, f_sysdate, pnsinies, pntramit, pctipres, pcgarant, pcmonres, pipago, pfperini, pfperfin, mensajes);
        vno_anular_pago := 1;
      END IF;
      IF vnumerr <> 0 THEN
        RAISE e_object_error;
      END IF;
      vpasexec   := 7;
      vnumerr    := pac_siniestros.f_compensa_recibo(psseguro, pnriesgo, pnsinies, pntramit, psidepag, vsperson, vnrecibo, vfefecto, vccobban, vcdelega, vimpcomp, pfordpag, pcconpag, pccauind, pcbancar, pcmonpag, pctipres, pnmovres, pcgarant, pfperini, pfperfin, pcmonres, pisinret, pcmonpag_gar, pisinretpag, pfcambio, pcconpag_gar, pnorden, virestorec_act, vno_crear_cab_pago, vsidepag_cab, psidepag_new, vnmovpag_new);
      IF vnumerr <> 0 THEN
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
        RAISE e_object_error;
      END IF;
    END IF;
  END LOOP;
  prestopag := visinret;
  vpasexec  := 3;
  RETURN 0;
EXCEPTION
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN 1;
END f_compensa_recibos;
FUNCTION f_pago_resto_asegurado(
    pnsinies IN sin_tramita_pago.nsinies%TYPE,
    psidepag IN sin_tramita_pago.sidepag%TYPE,
    pctipres IN sin_tramita_pago_gar.ctipres%TYPE,
    pnmovres IN sin_tramita_pago_gar.nmovres%TYPE,
    pimporte IN NUMBER,
    pfperini IN sin_tramita_pago_gar.fperini%TYPE,
    pfperfin IN sin_tramita_pago_gar.fperfin%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  /***************************************************************************
  Despues de compensar los recibos pendientes, crea un pago por la diferencia
  ***************************************************************************/
  vpasexec  NUMBER(8)     := 1;
  vparam    VARCHAR2(500) := 'param psidepag=' || psidepag;
  vobject   VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_pago_resto_asegurado';
  terror    VARCHAR2(200) := ' Error al crear pago resto';
  vnerror   NUMBER;
  vquery    VARCHAR2(5000);
  vntramit  NUMBER;
  visisnret NUMBER;
  vnrecibo  NUMBER;
  vfefecto recibos.fefecto%TYPE;
  vccobban recibos.ccobban%TYPE;
  vcdelega recibos.cdelega%TYPE;
  vtotrec NUMBER;
  vsperson sin_tramita_pago.sperson%TYPE;
  vipago sin_tramita_pago.isinret%TYPE;
  vsidepag sin_tramita_pago.sidepag%TYPE;
  vctipdes sin_tramita_pago.ctipdes%TYPE;
  vctippag sin_tramita_pago.ctippag%TYPE;
  vcforpag sin_tramita_pago.cforpag%TYPE;
  vfordpag sin_tramita_pago.fordpag%TYPE;
  vcmonpag sin_tramita_pago.cmonpag%TYPE;
  vcconpag sin_tramita_pago.cconpag%TYPE;
  vccauind sin_tramita_pago.ccauind%TYPE;
  vctipban sin_tramita_pago.ctipban%TYPE;
  vcbancar sin_tramita_pago.cbancar%TYPE;
  vcultpag sin_tramita_pago.cultpag%TYPE;
  vnmovpag sin_tramita_movpago.nmovpag%TYPE := 0;
  vcgarant sin_tramita_pago_gar.cgarant%TYPE;
  vfperini sin_tramita_pago_gar.fperini%TYPE;
  vfperfin sin_tramita_pago_gar.fperfin%TYPE;
  vcmonres sin_tramita_pago_gar.cmonres%TYPE;
  visinret sin_tramita_pago_gar.isinret%TYPE;
  vcmonpag_gar sin_tramita_pago_gar.cmonpag%TYPE;
  visinretpag sin_tramita_pago_gar.isinretpag%TYPE;
  vfcambio sin_tramita_pago_gar.fcambio%TYPE;
  vcconpag_gar sin_tramita_pago_gar.cconpag%TYPE;
  vnorden sin_tramita_pago_gar.norden%TYPE;
  vnmovres sin_tramita_reserva.nmovres%TYPE;
  vccalres sin_tramita_reserva.ccalres%TYPE;
  vireserva sin_tramita_reserva.ireserva%TYPE;
  vireserva_new sin_tramita_reserva.ireserva%TYPE;
  vipago_res sin_tramita_reserva.ipago%TYPE;
  vipago_new sin_tramita_reserva.ipago%TYPE;
  vicaprie sin_tramita_reserva.icaprie%TYPE;
  vipenali sin_tramita_reserva.ipenali%TYPE;
  viingreso sin_tramita_reserva.iingreso%TYPE;
  virecobro sin_tramita_reserva.irecobro%TYPE;
  viprerec sin_tramita_reserva.iprerec%TYPE;
  vctipgas sin_tramita_reserva.ctipgas%TYPE;
  vifranq sin_tramita_reserva.ifranq%TYPE;
  vndias sin_tramita_reserva.ndias%TYPE;
  vitotimp sin_tramita_reserva.itotimp%TYPE;
  vidres sin_tramita_reserva.idres%TYPE;
  vsinterf NUMBER;
BEGIN
  vpasexec   := 1;
  vnerror    := pac_siniestros.f_get_datos_pago(psidepag, vntramit, vsperson, vctipdes, vctippag, vipago, vcforpag, vfordpag, vcconpag, vccauind, vctipban, vcbancar, vcmonpag, vcultpag);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  vpasexec   := 2;
  vnerror    := pac_siniestros.f_get_detalle_pago(psidepag, pctipres, pnmovres, vcgarant, vfperini, vfperfin, vcmonres, visinret, vcmonpag_gar, visinretpag, vfcambio, vcconpag_gar, vnorden);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  vpasexec   := 3;
  vnerror    := pac_siniestros.f_get_detalle_reserva(pnsinies, vntramit, pctipres, vcgarant, vcmonres, pfperini, pfperfin, vnmovres, vccalres, vireserva, vipago_res, vicaprie, vipenali, viingreso, virecobro, viprerec, vctipgas, vifranq, vndias, vitotimp, vidres);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  vpasexec      := 4;
  vireserva_new := vireserva  - pimporte;
  vipago_new    := vipago_res + pimporte;
  vpasexec      := 5;
  vnmovres      := NULL;
  vnerror       := pac_siniestros.f_ins_reserva(pnsinies, vntramit, pctipres, vcgarant, vccalres, f_sysdate,
  --fmovres
  vcmonres, vireserva_new, vipago_new, vicaprie, vipenali, viingreso, virecobro, pfperini, pfperfin, f_sysdate,
  --fultpag
  NULL,
  -- sidepag
  viprerec, vctipgas, vnmovres, 4,
  --cmovres --0031294/0174788: NSS:26/05/2014
  vifranq, vndias, vitotimp);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  vpasexec := 6;
  -- creamos un pago por el importe del recibo
  vnerror := pac_siniestros.f_ins_pago(vsidepag, pnsinies, vntramit, vsperson, vctipdes,
  -- ctipdes
  vctippag,
  -- ctippag
  vcconpag,
  -- cconpag
  vccauind,
  -- ccauind,
  vcforpag,
  -- cforpag,
  vfordpag,
  -- fordpag,
  vctipban,
  -- ctipban,
  vcbancar,
  -- cbancar,
  pimporte,
  -- isinret,
  0,
  -- iretenc,
  0,
  -- iiva
  0,
  -- isuplid
  0,
  -- ifranq
  0,
  -- iresrcm
  0,
  -- iresred
  NULL,
  -- nfacref
  NULL,
  -- ffacref
  1,
  -- sidepagtemp
  0,
  -- cultpag
  NULL,
  --ncheque --Segun correo recibido ell 20/08/2015 por parte de jordi torras se añade este parametro.KJSC
  0,
  -- ireteiva
  0,
  -- ireteica
  0,
  -- ireteivapag
  0,
  -- ireteicapag
  0,
  -- iica
  0,
  -- iicapag
  vcmonpag,
  -- pcmonres
  NULL,
  -- sperson_presentador
  NULL,
  -- tobserva
  NULL,
  -- piotrosgas
  NULL,
  -- pibaseipoc
  NULL,
  -- piipoconsumo
  NULL,
  -- piotrosgaspag
  NULL,
  -- pibaseipocpag
  NULL); -- piipoconsumopag
  IF vnerror <> 0 THEN
    RETURN vnerror;
  END IF;
  vpasexec := 7;
  vnmovpag := 0; -- Movimiento inicial
  vnerror  := pac_siniestros.f_ins_movpago(vsidepag, 1,
  -- cestpag
  vfordpag,
  -- fefepag
  1,
  -- cestval
  TRUNC(f_sysdate),
  -- fcontab
  NULL,
  -- sproces
  0,
  -- cestpagant
  vnmovpag, 0,
  -- csubpag
  0); -- csubpagant
  IF vnerror <> 0 THEN
    RETURN vnerror;
  END IF;
  vpasexec := 8;
  vnerror  := pac_siniestros.f_ins_pago_gar(pnsinies, vntramit, vsidepag, pctipres, vnmovres - 1,
  -- nmovres (Correspondiente al movimiento de reserva previo)
  vcgarant, vfperini, vfperfin, vcmonres, pimporte,
  --isinret
  NULL,
  --iiva
  NULL,
  --isuplid,
  NULL,
  --iretenc,
  NULL,
  --ifranq,
  NULL,
  --iresrcm,
  NULL,
  --iresred,
  NULL,
  --pretenc,
  NULL,
  --piva,
  vcmonpag_gar, pimporte,
  --isinretpag,
  NULL,
  --iivapag,
  NULL,
  --isuplidpag,
  NULL,
  --iretencpag,
  NULL,
  --ifranqpag,
  vfcambio,
  --fcambio,
  vcconpag_gar,
  --vnorden,
  NULL,
  --27062014
  NULL,
  --preteiva,
  NULL,
  --preteica,
  NULL,
  --ireteiva,
  NULL,
  --ireteica,
  NULL,
  --ireteivapag,
  NULL,
  --ireteicapag,
  NULL,
  --pica,
  NULL,
  --iica,
  NULL,
  --iicapag
  NULL,
  --piotrosgas
  NULL,
  --pibaseipoc
  NULL,
  --ppipoconsumo
  NULL,
  --piipoconsumo
  NULL,
  --piotrosgaspag
  NULL,
  --pibaseipocpag
  NULL); --piipoconsumopag
  vpasexec   := 9;
  IF vnerror <> 0 THEN
    RETURN vnerror;
  END IF;
  vpasexec := 10;
  vnerror  := pac_siniestros.f_gestiona_cobpag(vsidepag, vnmovpag, 1,
  --cestpag
  vfordpag,
  --fefepag
  TRUNC(f_sysdate),
  -- fcontab
  vsinterf);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    --AÑADO EL MENSAJE DE ERROR QUE DEVUELVE EL HOST
    IF pac_con.f_tag(vsinterf, 'terror', 'TMENIN') IS NOT NULL AND vsinterf IS NOT NULL THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, pac_con.f_tag(vsinterf, 'cerror', 'TMENIN'), pac_con.f_tag(vsinterf, 'terror', 'TMENIN'));
    END IF;
    RAISE e_object_error;
  END IF;
  vpasexec := 11;
  COMMIT;
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  RETURN 1;
END f_pago_resto_asegurado;
FUNCTION f_anula_pago(
    psidepag IN sin_tramita_pago.sidepag%TYPE,
    pfecha   IN DATE,
    pnsinies IN sin_tramita_pago.nsinies%TYPE,
    pntramit IN sin_tramita_pago.ntramit%TYPE,
    pctipres IN sin_tramita_pago_gar.ctipres%TYPE,
    pcgarant IN sin_tramita_pago_gar.cgarant%TYPE,
    pcmonres IN sin_tramita_pago_gar.cmonres%TYPE,
    pipago   IN sin_tramita_pago.isinret%TYPE,
    pfperini IN sin_tramita_pago_gar.fperini%TYPE,
    pfperfin IN sin_tramita_pago_gar.fperfin%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  /*************************************************************************
  Despues de compensar los recibos pendientes, anula el pago original
  *************************************************************************/
  vpasexec  NUMBER(8)     := 1;
  vparam    VARCHAR2(500) := 'param psidepag=' || psidepag;
  vobject   VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_anula_pago';
  terror    VARCHAR2(200) := ' Error al crear pago resto';
  vnerror   NUMBER;
  vquery    VARCHAR2(5000);
  vntramit  NUMBER;
  visisnret NUMBER;
  vsperson per_personas.sperson%TYPE;
  vnrecibo NUMBER;
  vfefecto recibos.fefecto%TYPE;
  vccobban recibos.ccobban%TYPE;
  vcdelega recibos.cdelega%TYPE;
  vtotrec NUMBER;
  visinret sin_tramita_pago.isinret%TYPE;
  vfordpag sin_tramita_pago.fordpag%TYPE;
  vcmonpag sin_tramita_pago.cmonpag%TYPE;
  vcconpag sin_tramita_pago.cconpag%TYPE;
  vccauind sin_tramita_pago.ccauind%TYPE;
  vcbancar sin_tramita_pago.cbancar%TYPE;
  vnmovpag sin_tramita_movpago.nmovpag%TYPE;
  vnmovres sin_tramita_reserva.nmovres%TYPE;
  vccalres sin_tramita_reserva.ccalres%TYPE;
  vireserva sin_tramita_reserva.ireserva%TYPE;
  vireserva_new sin_tramita_reserva.ireserva%TYPE;
  vipago_res sin_tramita_reserva.ipago%TYPE;
  vipago_new sin_tramita_reserva.ipago%TYPE;
  vicaprie sin_tramita_reserva.icaprie%TYPE;
  vipenali sin_tramita_reserva.ipenali%TYPE;
  viingreso sin_tramita_reserva.iingreso%TYPE;
  virecobro sin_tramita_reserva.irecobro%TYPE;
  viprerec sin_tramita_reserva.iprerec%TYPE;
  vctipgas sin_tramita_reserva.ctipgas%TYPE;
  vifranq sin_tramita_reserva.ifranq%TYPE;
  vndias sin_tramita_reserva.ndias%TYPE;
  vitotimp sin_tramita_reserva.itotimp%TYPE;
  vidres sin_tramita_reserva.idres%TYPE;
BEGIN
  vpasexec := 1;
  vnerror  := pac_siniestros.f_ins_movpago(psidepag, 8,
  -- cestpag
  pfecha,
  -- fefepag
  1,
  -- cestval
  TRUNC(f_sysdate),
  -- fcontab
  NULL,
  -- sproces
  0,
  -- cestpagant
  vnmovpag, 0,
  -- csubpag
  0); -- csubpagant
  IF vnerror <> 0 THEN
    RETURN vnerror;
  END IF;
  vpasexec   := 2;
  vnerror    := pac_siniestros.f_get_detalle_reserva(pnsinies, pntramit, pctipres, pcgarant, pcmonres, pfperini, pfperfin, vnmovres, vccalres, vireserva, vipago_res, vicaprie, vipenali, viingreso, virecobro, viprerec, vctipgas, vifranq, vndias, vitotimp, vidres);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  vpasexec      := 3;
  vireserva_new := vireserva  + pipago;
  vipago_new    := vipago_res - pipago;
  vpasexec      := 4;
  vnmovres      := NULL;
  vnerror       := pac_siniestros.f_ins_reserva(pnsinies, pntramit, pctipres, pcgarant, vccalres, f_sysdate,
  --fmovres
  pcmonres, vireserva_new, vipago_new, vicaprie, vipenali, viingreso, virecobro, pfperini, pfperfin, f_sysdate,
  --fultpag
  psidepag, viprerec, vctipgas, vnmovres, 5,
  --cmovres --0031294/0174788:NSS:26/05/2014
  vifranq, vndias, vitotimp);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  RETURN 1;
END f_anula_pago;
FUNCTION f_cobpag_compensados(
    pnsinies IN sin_siniestro.nsinies%TYPE,
    psidepag IN sin_tramita_pago.sidepag%TYPE,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'pac_md_siniestros.f_cobpag_compensados';
  vparam      VARCHAR2(500) := 'parámetros - psidepag:' || psidepag;
  vpasexec    NUMBER        := 1;
  vnumerr     NUMBER;
  vnmovpag    NUMBER;
BEGIN
  FOR i IN
  (SELECT sidepag_new
  FROM sin_recibos_compensados
  WHERE nsinies   = pnsinies
  AND sidepag_old = psidepag
  )
  LOOP
    vnumerr := pac_md_siniestros.f_gestiona_cobpag(i.sidepag_new,
    -- identificador pago
    0,
    -- movimiento pago
    1,
    -- estado pago
    f_sysdate,
    -- efecto pago
    f_sysdate,
    -- fecha contable  -- !!!!!!!!!!!!!!!!!!!!!
    mensajes);
    IF vnumerr <> 0 THEN
      RETURN vnumerr;
    END IF;
  END LOOP;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_cobpag_compensados;
FUNCTION f_valida_exist_res_noindem(
    psidepag IN sin_tramita_pago.sidepag%TYPE,
    pexisten OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'pac_md_siniestros.f_cobpag_compensados';
  vparam      VARCHAR2(500) := 'parámetros - psidepag:' || psidepag;
  vpasexec    NUMBER        := 1;
  vnumerr     NUMBER;
  vnmovpag    NUMBER;
BEGIN
  vnumerr    := pac_siniestros.f_valida_exist_res_noindem(psidepag, pexisten);
  IF vnumerr <> 0 THEN
    RETURN vnumerr;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_valida_exist_res_noindem;
FUNCTION f_valida_exist_recib_remesados(
    psseguro IN seguros.sseguro%TYPE,
    pexisten OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'pac_md_siniestros.f_valida_exist_recib_remesados';
  vparam      VARCHAR2(500) := 'parámetros - psseguro:' || psseguro;
  vpasexec    NUMBER        := 1;
  vnumerr     NUMBER;
  vnmovpag    NUMBER;
BEGIN
  vnumerr    := pac_siniestros.f_valida_exist_recib_remesados(psseguro, pexisten);
  IF vnumerr <> 0 THEN
    RETURN vnumerr;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_valida_exist_recib_remesados;
-- FIN BUG 28830:NSS:06/11/2013 - Compensación de siniestros contra cartera.
-- BUG 30342:DEV:12/03/2014 - Modulo de Autorizaciones para pagos de Siniestros
FUNCTION f_get_lst_pagos(
    pcramo   IN NUMBER,
    psproduc IN NUMBER,
    pnsinies IN VARCHAR2,
    psidepag IN NUMBER,
    pcconcep IN NUMBER,
    pimpmin  IN NUMBER,
    pcestval IN NUMBER,
    pcespag  IN NUMBER,
    psperson IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)      := 1;
  vparam   VARCHAR2(2000) := 'pcramo=' || pcramo || ' psproduc=' || psproduc || ' pnsinies=' || pnsinies || ' psidepag=' || psidepag || ' pcconcep=' || pcconcep || ' pimpmin=' || pimpmin || ' pcestval' || pcestval || ' pcespag=' || pcespag || ' psperson=' || psperson;
  vobject  VARCHAR2(200)  := 'PAC_MD_SINIESTROS.f_get_lst_pagos ';
  terror   VARCHAR2(200)  := ' Error recuperar lista de pagos';
  vquery   VARCHAR2(2000);
  vnerror  NUMBER;
  pselect  VARCHAR2(2000);
BEGIN
  vpasexec    := 11;
  pselect     := 'select p.nsinies, p.sidepag, d.tatribu cconpag, f_nombre(p.sperson, 1, s.cagente) destinatario,ff_desvalorfijo(3,pac_md_common.f_get_cxtidioma,m.cestpag) cestpag,ff_desvalorfijo(324,pac_md_common.f_get_cxtidioma,m.cestval) cestval, p.isinret importe, s.sseguro, s.CACTIVI
from sin_tramita_pago p, sin_tramita_movpago m, sin_siniestro si, seguros s, detvalores d
where si.sseguro = s.sseguro
and p.nsinies = si.nsinies
and m.sidepag = p.sidepag
and m.cestval = ' || pcestval || ' and m.cestpag = ' || pcespag || ' and m.nmovpag = (select max(nmovpag) from sin_tramita_movpago m1 where m1.sidepag = m.sidepag)
and d.cvalor = 803
and d.catribu = p.cconpag
and d.cidioma = pac_md_common.f_get_cxtidioma';
  IF psidepag IS NOT NULL THEN
    pselect   := pselect || ' AND p.sidepag = ' || psidepag;
  END IF;
  IF pnsinies IS NOT NULL THEN
    pselect   := pselect || ' AND p.nsinies = ' || pnsinies;
  END IF;
  IF psproduc IS NOT NULL THEN
    pselect   := pselect || ' AND s.sproduc = ' || psproduc;
  END IF;
  IF pcramo IS NOT NULL THEN
    pselect := pselect || ' AND s.cramo = ' || pcramo;
  END IF;
  IF pcconcep IS NOT NULL THEN
    pselect   := pselect || ' AND p.cconpag = ' || pcconcep;
  END IF;
  IF pimpmin IS NOT NULL THEN
    pselect  := pselect || ' AND p.isinret >= ' || pimpmin;
  END IF;
  IF psperson IS NOT NULL THEN
    pselect   := pselect || ' AND p.sperson = ' || psperson;
  END IF;
  OPEN cur FOR pselect;
  RETURN cur;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_lst_pagos;
FUNCTION f_tratar_pagos(
    ptblpago  IN VARCHAR2,
    pcestval2 IN NUMBER,
    pcestpag2 IN NUMBER,
    pcestpag1 IN NUMBER,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec  NUMBER(8)      := 1;
  vparam    VARCHAR2(2000) := 'ptblpago=' || ptblpago || ' pcestval2=' || pcestval2 || ' pcestpag2=' || pcestpag2 || ' pcestpag1=' || pcestpag1;
  vobject   VARCHAR2(200)  := 'PAC_MD_SINIESTROS.f_tratar_pagos ';
  terror    VARCHAR2(200)  := ' Error actualizar pagos';
  vquery    VARCHAR2(2000);
  w_mensaje VARCHAR2(2000);
  vnerror   NUMBER;
  v_sidepag t_linea := NEW t_linea();
  v_index  NUMBER;
  vnmovpag NUMBER := NULL;
  vsinterf NUMBER;
BEGIN
  v_sidepag := pac_fic_formatos.f_split(ptblpago, '#');
  v_index   := v_sidepag.FIRST;
  LOOP
    vnerror    := pac_validaciones_sin.f_movpago(REPLACE(v_sidepag(v_index), '#'), pcestpag2, pcestval2, NULL);
    IF vnerror <> 0 THEN
      SELECT f_axis_literales(103463, pac_md_common.f_get_cxtidioma)
        || ' '
        || REPLACE(v_sidepag(v_index), '#')
        || ' '
        || f_axis_literales(vnerror, pac_md_common.f_get_cxtidioma)
      INTO w_mensaje
      FROM DUAL;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 5, vnerror, w_mensaje);
      RETURN 1;
    END IF;
    EXIT
  WHEN v_index = v_sidepag.LAST();
    v_index   := v_sidepag.NEXT(v_index);
  END LOOP;
  v_index := v_sidepag.FIRST;
  LOOP
    vpasexec    := 10;
    IF pcestpag2 = 8 THEN
      vnerror   := pac_md_siniestros.f_anula_pago_sin (REPLACE(v_sidepag(v_index), '#'), f_sysdate, mensajes);
    ELSE
      vnerror := pac_siniestros.f_ins_movpago(REPLACE(v_sidepag(v_index), '#'), pcestpag2, f_sysdate, pcestval2, NULL, 0, pcestpag1, vnmovpag, NULL, NULL);
    END IF;
    vpasexec   := 20;
    IF vnerror <> 0 THEN
      SELECT f_axis_literales(103463, pac_md_common.f_get_cxtidioma)
        || ' '
        || REPLACE(v_sidepag(v_index), '#')
        || ' '
        || f_axis_literales(vnerror, pac_md_common.f_get_cxtidioma)
      INTO w_mensaje
      FROM DUAL;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 5, vnerror, w_mensaje);
      RETURN 1;
    END IF;
    vpasexec                                           := 30;
    IF (pcestval2                                       = 1 AND pcestpag2 = 1) OR pcestpag2 = 8 THEN
      vnerror                                          := pac_siniestros.f_gestiona_cobpag(REPLACE(v_sidepag(v_index), '#'), vnmovpag, pcestpag2, f_sysdate, NULL, vsinterf);
      IF vnerror                                       <> 0 THEN
        IF pac_con.f_tag(vsinterf, 'terror', 'TMENIN') IS NOT NULL AND vsinterf IS NOT NULL THEN
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, pac_con.f_tag(vsinterf, 'cerror', 'TMENIN'), pac_con.f_tag(vsinterf, 'terror', 'TMENIN'));
        END IF;
        RETURN 1;
      END IF;
    END IF;
    COMMIT;
    EXIT
  WHEN v_index = v_sidepag.LAST();
    v_index   := v_sidepag.NEXT(v_index);
  END LOOP;
  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 5, 109904);
  RETURN 109904;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  ROLLBACK;
  RETURN 1;
END f_tratar_pagos;
--fin BUG 30342:DEV:12/03/2014 - Modulo de Autorizaciones para pagos de Siniestros
-- BUG 31040:NSS:15/04/2014 -
FUNCTION f_get_certif_0(
    psseguro IN NUMBER,
    vcertif0 OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'pac_md_siniestros.f_get_certif_0';
  vparam      VARCHAR2(500) := 'parámetros - psseguro:' || psseguro;
  vpasexec    NUMBER        := 1;
  vnumerr     NUMBER;
  vnmovpag    NUMBER;
BEGIN
  vnumerr    := pac_siniestros.f_get_certif_0(psseguro, vcertif0);
  IF vnumerr <> 0 THEN
    RETURN vnumerr;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_certif_0;
-- FIN BUG 31040:NSS:15/04/2014
-- BUG 31294/174788: :NSS:18/06/2014 -
FUNCTION f_get_imp_ult_mov_reserva(
    pnsinies IN VARCHAR2,
    pntramit IN NUMBER,
    pctipres IN NUMBER,
    pctipgas IN NUMBER,
    pcgarant IN NUMBER,
    pfresini IN DATE,
    pfresfin IN DATE,
    pireserva OUT NUMBER,
    pipago OUT NUMBER,
    pirecobro OUT NUMBER,
    pitotimp OUT NUMBER,
    pitotret OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'pac_md_siniestros.f_get_imp_ult_mov_reserva';
  vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies || ' pntramit: ' || pntramit || ' pctipres: ' || pctipres || ' pctipgas: ' || pctipgas || ' pcgarant: ' || pcgarant || ' pfresini: ' || pfresini || ' pfresfin: ' || pfresfin;
  vpasexec    NUMBER        := 1;
  vnumerr     NUMBER;
  vnmovpag    NUMBER;
BEGIN
  vpasexec   := 3;
  vnumerr    := pac_siniestros.f_get_imp_ult_mov_reserva(pnsinies, pntramit, pctipres, pctipgas, pcgarant, pfresini, pfresfin, pireserva, pipago, pirecobro, pitotimp, pitotret);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  vpasexec := 4;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_imp_ult_mov_reserva;
-- FIN BUG 31294/174788: :NSS:18/06/2014 -
/***********************************************************************
FUNCTION F_ESTADO_SINIESTRO:
Cambia el estado de un siniestro
param in  pnsinies   : Número Siniestro
param in pcestsin    : codi estat sinistre
param in pccauest    : codi causa estat sinistre
param in pcunitra    : codi unitat tramitació
param in pctramitad  : codi tramitador
param in pcsubtra    : codi subestat tramitació
param  out  mensajes : Mensajes de error
return               : 0 -> Tot correcte
1 -> S'ha produit un error
***********************************************************************/
FUNCTION f_set_campo_plantilla(
    pnsinies  IN VARCHAR2,
    pccodplan IN VARCHAR2,
    pndocume  IN VARCHAR2,
    pccampo   IN VARCHAR2,
    ptcampo   IN VARCHAR2,
    mensajes  IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobject  VARCHAR2(200)  := 'PAC_SINIESTROS.f_set_campo_plantilla';
  vnumerr  NUMBER         := 0;
  vtraza   NUMBER         := 1;
  vparam   VARCHAR2(1000) := 'pnsinies = ' || pnsinies || ' pccodplan: ' || pccodplan || ' pndocume: ' || pndocume || ' pccampo: ' || pccampo || ' ptcampo: ' || ptcampo;
  vpasexec NUMBER         := 1;
BEGIN
  vnumerr    := pac_siniestros.f_set_campo_plantilla(pnsinies, pccodplan, pndocume, pccampo, ptcampo);
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam, vnumerr);
  RETURN vnumerr;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_set_campo_plantilla;
/***********************************************************************
FUNCTION F_GET_DOCUMENTACION_PENDIENTE:
Obtiene una lista con los nombres de los documentos pendientes de recibir (AXISSIN061)
param in pnsinies   : Número Siniestro
param in pntramit    : codi subestat tramitació
param  out  ptlisdoc : Lista de documentos
param  out  mensajes : Mensajes de error
return               : 0 -> Tot correcte
1 -> S'ha produit un error
***********************************************************************/
FUNCTION f_get_documentacion_pendiente(
    pnsinies IN sin_siniestro.nsinies%TYPE,
    pntramit IN sin_tramitacion.ntramit%TYPE,
    ptlisdoc IN OUT VARCHAR2,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobject  VARCHAR2(200)  := 'PAC_MD_SINIESTROS.f_get_documentacion_pendiente';
  vparam   VARCHAR2(1000) := 'pnsinies = ' || pnsinies || ' pntramit: ' || pntramit;
  vnumerr  NUMBER         := 0;
  vpasexec NUMBER         := 1;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_get_documentacion_pendiente(pnsinies, pntramit, ptlisdoc);
  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam, vnumerr);
  RETURN vnumerr;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_get_documentacion_pendiente;
--BUG 35102/200437
FUNCTION f_hay_lista_innominados(
    psproduc IN productos.sproduc%TYPE,
    psseguro IN seguros.sseguro%TYPE,
    pnriesgo IN riesgos.nriesgo%TYPE,
    pnasegur OUT NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobject  VARCHAR2(200)  := 'PAC_MD_SINIESTROS.f_hay_lista_innominados';
  vparam   VARCHAR2(1000) := 'sproduc = ' || psproduc || ' sseguro: ' || psseguro || ' nriesgo: ' || pnriesgo;
  vnumerr  NUMBER         := 0;
  vpasexec NUMBER         := 1;
BEGIN
  IF psproduc IS NULL OR psseguro IS NULL OR pnriesgo IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr   := pac_siniestros.f_hay_lista_innominados(psproduc, psseguro, pnriesgo, pnasegur);
  IF vnumerr > 0 THEN
    RAISE e_object_error;
  END IF;
  RETURN 0;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam, vnumerr);
  RETURN vnumerr;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_hay_lista_innominados;
/*************************************************************************
Realiza llamado a la función f_anula_pago    ACL Bug 41501 -- 20/05/2016
*************************************************************************/
FUNCTION f_anula_pago_sin(
    psidepag IN sin_tramita_pago.sidepag%TYPE,
    pfecha   IN DATE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param psidepag=' || psidepag;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_anula_pago_sin';
  terror   VARCHAR2(200) := ' Error al crear pago resto';
  vnerror  NUMBER;
  vnsinies sin_tramita_reserva.nsinies%TYPE;
  vntramit sin_tramita_reserva.ntramit%TYPE;
  vctipres sin_tramita_reserva.ctipres%TYPE;
  vcgarant sin_tramita_reserva.cgarant%TYPE;
  vcmonres sin_tramita_reserva.cmonres%TYPE;
  visinret sin_tramita_pago.isinret%TYPE;
  vfresini sin_tramita_reserva.fresini%TYPE;
  vfresfin sin_tramita_reserva.fresfin%TYPE;
BEGIN
  vpasexec := 1;
  SELECT b.nsinies,
    b.ntramit,
    b.ctipres,
    b.cgarant,
    b.cmonres,
    p.isinret,
    b.fresini,
    b.fresfin
  INTO vnsinies,
    vntramit,
    vctipres,
    vcgarant,
    vcmonres,
    visinret,
    vfresini,
    vfresfin
  FROM sin_tramita_reserva b,
    sin_tramita_pago p
  WHERE b.sidepag = psidepag
  AND b.nmovres   =
    (SELECT MAX(a.nmovres)
    FROM sin_tramita_reserva a
    WHERE a.sidepag = b.sidepag
    )
  AND p.sidepag = b.sidepag;
  vpasexec     := 2;
  vnerror      := pac_md_siniestros.f_anula_pago(psidepag, pfecha, vnsinies, vntramit, vctipres, vcgarant, vcmonres, visinret, vfresini, vfresfin, mensajes);
  IF vnerror   <> 0 THEN
    RETURN vnerror;
  END IF;
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  RETURN 1;
END f_anula_pago_sin;
FUNCTION f_del_sin_trami_doc(
    pnsinies IN sin_siniestro.nsinies%TYPE,
    pntramit IN sin_tramitacion.ntramit%TYPE,
    pndocume IN NUMBER,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vobject  VARCHAR2(200)  := 'PAC_MD_SINIESTROS.f_del_sin_trami_doc';
  vparam   VARCHAR2(1000) := 'pnsinies = ' || pnsinies || ' pntramit: ' || pntramit || ' pndocume: ' || pndocume;
  vnumerr  NUMBER         := 0;
  vpasexec NUMBER         := 1;
BEGIN
  IF pnsinies IS NULL OR pntramit IS NULL OR pndocume IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr   := pac_siniestros.f_del_sin_trami_doc(pnsinies, pntramit, pndocume);
  IF vnumerr > 0 THEN
    RAISE e_object_error;
  END IF;
  IF pac_iax_siniestros.vgobsiniestro.tramitaciones IS NOT NULL AND pac_iax_siniestros.vgobsiniestro.tramitaciones.count > 0 THEN
    FOR i IN pac_iax_siniestros.vgobsiniestro.tramitaciones.first .. pac_iax_siniestros.vgobsiniestro.tramitaciones.last
    LOOP
      vpasexec := 222;
      IF pac_iax_siniestros.vgobsiniestro.tramitaciones.exists(i) THEN
        IF pac_iax_siniestros.vgobsiniestro.tramitaciones(i) .ntramit       = pntramit THEN
          vpasexec                                                         := 4;
          IF pac_iax_siniestros.vgobsiniestro.tramitaciones(i) .documentos IS NOT NULL THEN
            FOR j IN pac_iax_siniestros.vgobsiniestro.tramitaciones(i) .documentos.first .. pac_iax_siniestros.vgobsiniestro.tramitaciones(i) .documentos.last
            LOOP
              IF pac_iax_siniestros.vgobsiniestro.tramitaciones(i).documentos(j) .ndocume = pndocume AND pac_iax_siniestros.vgobsiniestro.tramitaciones(i).documentos(j) .ntramit = pntramit THEN
                vpasexec                                                                 := 5;
                pac_iax_siniestros.vgobsiniestro.tramitaciones(i).documentos(j).iddoc    := NULL;
                pac_iax_siniestros.vgobsiniestro.tramitaciones(i).documentos(j).frecibe  := NULL;
                pac_iax_siniestros.vgobsiniestro.tramitaciones(i).documentos(j).descdoc  := NULL;
              END IF;
            END LOOP;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
  RETURN 1;
WHEN e_object_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam, vnumerr);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_del_sin_trami_doc;

   /***********************************************************************
     FUNCTION f_get_tramitaciones:
          obtiene las tramitaciones de un siniestro

   ***********************************************************************/
   FUNCTION f_get_tramitaciones(pnsinies IN VARCHAR2,
                            mensajes OUT t_iax_mensajes)
          RETURN SYS_REFCURSOR
    IS
      cur sys_refcursor;
      vpasexec NUMBER(8)     := 1;
      vparam   VARCHAR2(500);
      vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_tramitaciones';
      terror   VARCHAR2(200) := ' Error a recuperar tramitaciones';
      vnerror  NUMBER;
      vquery   VARCHAR2(5000);
    BEGIN
        vnerror    := pac_siniestros.f_get_tramitaciones(pnsinies, vquery);
          IF vnerror <> 0 THEN
              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
              RAISE e_object_error;
          END IF;
          cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
        RETURN cur;
    EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;
      RETURN cur;
  END f_get_tramitaciones;

   /***********************************************************************
     FUNCTION f_get_reservas:
          obtiene las tramitaciones de un siniestro

   ***********************************************************************/
   FUNCTION f_get_reservas(pnsinies IN VARCHAR2,
                            mensajes OUT t_iax_mensajes)
          RETURN SYS_REFCURSOR
    IS
      cur sys_refcursor;
      vpasexec NUMBER(8)     := 1;
      vparam   VARCHAR2(500);
      vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_reservas';
      terror   VARCHAR2(200) := ' Error a recuperar tramitaciones';
      vnerror  NUMBER;
      vquery   VARCHAR2(5000);
    BEGIN
        vnerror    := pac_siniestros.f_get_reservas(pnsinies, vquery);
          IF vnerror <> 0 THEN
              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
              RAISE e_object_error;
          END IF;
          cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
        RETURN cur;
    EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;
      RETURN cur;
  END f_get_reservas;


  /***********************************************************************
     FUNCTION f_pagos_avion:
          f_pagos_avion
    -- IAXIS 3642 3662 AABC 24/05/2019 cambios en tiquetes aereos y agencias 
   ***********************************************************************/
   FUNCTION f_pagos_avion(pnsinies in varchar2, -- NÚMERO DE SINIESTRO
                          pntramit in number, -- NÚMERO DE TRAMITACIÓN
                          pnmovres in number, -- NÚMERO MOVIMIENTO RESERVA
                          pctipres in number, -- CÓDIGO DE TIPO DE RESERVA
                          pctipgas in number, -- CÓDIGO DE TIPO DE GASTO
                          pcgarant in number, -- CÓDIGO DE GARANTÿA
                          pcmonres in varchar2, -- MONEDA DE LA RESERVA
                          pnnumide_agencia in varchar2, -- NÚMERO DE IDENTIFICACIÓN DE LA AGENCIA DE VIAJES
                          psperson_agencia in number,
                          pnnumide_aero in varchar2, -- NÚMERO DE IDENTIFICACIÓN DE LA COMPAÑÿA AÉREA
                          psperson_aero  in number,
                          pnfacref in varchar2,-- NÚMERO DE FACTURA
                          pffacref in date, -- FECHA DE FACTURA
                          ptobserva in varchar2, -- OBSERVACIONES
                          pisinret_aero in number, -- IMPORTE BRUTO PASAJE AÉREO
                          ppiva_aero in number, -- PORCENTAJE DE IVA PASAJE AÉREO
                          piiva_aero in number, -- IMPORTE IVA PASAJE AÉREO
                          piotrosgas_aero in number, -- IMPORTE DE OTROS GASTOS / TASA AEROPORTUARIA DEL PASAJE AÉREO
                          pineto_aero in number, -- IMPORTE NETO PASAJE AÉREO
                          pisinret_agencia in number, -- IMPORTE BRUTO AGENCIA
                          ppiva_agencia in number, -- PORCENTAJE IVA AGENCIA
                          piiva_agencia in number, -- IMPORTE IVA AGENCIA
                          pineto_agencia in number,-- IMPORTE NETO AGENCIA
                          --IAXIS 7654 AABC carga masiva pgos de tiquetes 
                          pcconpag_aero IN NUMBER,
                          pcconpag_agen IN NUMBER,
                          pcmovres IN NUMBER,
                          pidres   IN NUMBER,
                          --IAXIS 7654 AABC carga masiva pgos de tiquetes 
                          mensajes out t_iax_mensajes )
          RETURN NUMBER
    IS
      cur sys_refcursor;
      vpasexec NUMBER(8)     := 1;
      vparam   VARCHAR2(500);
      vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_pagos_avion';
      terror   VARCHAR2(200) := ' Error a recuperar tramitaciones';
      vnerror  NUMBER;
      vquery   VARCHAR2(5000);
      vpago    VARCHAR2(1);
      vsaldo   NUMBER;
      vtimporte NUMBER := 0;
      vexistetramitador VARCHAR2(1) := 'O';
      vpsidepag_agencia NUMBER;
      vpsidepag_aero NUMBER;
      vipago NUMBER;   
	  /*bug 4961 ANB*/
	  vdetvalor NUMBER;  
      --IAXIS 7655 AABC cambios para extraer el agente
      v_cagente NUMBER;
      --IAXIS 7655 AABC cambios para extraer el agente
      vpnmovres NUMBER := pnmovres;
      vpnmovpag NUMBER := 0;

    /* Cambios de IAXIS-3662 : Start */
    VCTIPRES  SIN_TRAMITA_RESERVA.CTIPRES%TYPE;
    VNMOVRES  SIN_TRAMITA_RESERVA.NMOVRES%TYPE;
    VCGARANT  SIN_TRAMITA_RESERVA.CGARANT%TYPE;
    VCCALRES  SIN_TRAMITA_RESERVA.CCALRES%TYPE;
    VFMOVRES  SIN_TRAMITA_RESERVA.FMOVRES%TYPE;
    VCMONRES  SIN_TRAMITA_RESERVA.CMONRES%TYPE;
    VIRESERVA SIN_TRAMITA_RESERVA.IRESERVA%TYPE;
    VIINGRESO SIN_TRAMITA_RESERVA.IINGRESO%TYPE;
    VIRECOBRO SIN_TRAMITA_RESERVA.IRECOBRO%TYPE;
    VICAPRIE  SIN_TRAMITA_RESERVA.ICAPRIE%TYPE;
    VIPENALI  SIN_TRAMITA_RESERVA.IPENALI%TYPE;
    VFCONTAB SIN_TRAMITA_RESERVA.FCONTAB%TYPE;
    VCMOVRES SIN_TRAMITA_RESERVA.CMOVRES%TYPE;
    VFRESINI SIN_TRAMITA_RESERVA.FRESINI%TYPE;
    VFRESFIN SIN_TRAMITA_RESERVA.FRESFIN%TYPE;
    VFULTPAG SIN_TRAMITA_RESERVA.FULTPAG%TYPE;
    Vctipgas SIN_TRAMITA_RESERVA.Ctipgas%type;
	 Vcsolidaridad SIN_TRAMITA_RESERVA.csolidaridad%type;
    /* Cambios de IAXIS-3662 : End */
    --IAXIS-5194 Cambios para la parte de reservas 
    vvalor_agen  NUMBER := null;
    vvalor_aero  NUMBER := NULL; 
    vidres       NUMBER;
    --IAXIS-5194 Cambios para la parte de reservas 
    vobsini ob_iax_siniestros := ob_iax_siniestros();
      CURSOR c_pagos IS
    /* Cambios de IAXIS-3662 : Start */
      SELECT 'X'
        FROM SIN_TRAMITA_PAGO p, sin_tramita_movpago mp
       WHERE NVL(mp.cestpag, -1) != 6
         and mp.sidepag = p.sidepag
         and p.NFACREF = pnfacref
         AND p.nsinies = pnsinies;
    /* Cambios de IAXIS-3662 : End */
      -- IAXIS 3642 cambio de saldo tiquetes aereos saldo reserva 
      CURSOR c_saldo IS
      SELECT NVL(IRESERVA, 0) SALDO
        FROM SIN_TRAMITA_RESERVA
      /* Cambios de IAXIS-3662 : Start */
       WHERE NMOVRES = (SELECT MAX(T.NMOVRES)
                          FROM SIN_TRAMITA_RESERVA T
                         WHERE T.CTIPRES = pctipres
                           AND T.NSINIES = pnsinies
                           AND t.ntramit = pntramit
                           AND t.idres   = pidres)
         AND CTIPRES = pctipres
            /* Cambios de IAXIS-3662 : End */
          AND NSINIES = pnsinies
          AND NTRAMIT = pntramit
          AND idres   = pidres;
	  --IAXIS 7654 AABC carga masiva pgos de tiquetes 

    CURSOR c_destinatario(pnsinies VARCHAR2,
                          pntramit NUMBER,
                          psperson NUMBER) IS
      SELECT 'X'
        FROM SIN_TRAMITA_DESTINATARIO
            WHERE NSINIES = pnsinies
              AND NTRAMIT = pntramit
              AND SPERSON = psperson;

    BEGIN

    IF pnsinies IS NULL OR pntramit IS NULL OR pnmovres IS NULL OR
       pctipres IS NULL OR pctipgas IS NULL OR pcgarant IS NULL OR
       pcmonres IS NULL OR pnnumide_agencia IS NULL OR
       psperson_agencia IS NULL OR pnnumide_aero IS NULL OR
       psperson_aero IS NULL OR pnfacref IS NULL OR pffacref IS NULL OR
       pisinret_aero IS NULL OR ppiva_aero IS NULL OR piiva_aero IS NULL OR
          pineto_aero IS  NULL OR

       pisinret_agencia IS NULL OR ppiva_agencia IS NULL OR
       piiva_agencia IS NULL OR pineto_agencia IS NULL THEN

          RAISE e_param_error;

       END IF;
       --IAXIS-5194 Cambios para la parte de reservas 
       vpago             := NULL;
       vsaldo            := NULL;
       vtimporte         := NULL;
       vpsidepag_agencia := NULL;
       vpsidepag_aero    := NULL;
       vpnmovres         := NULL;
       VCTIPRES          := NULL;
       VNMOVRES          := NULL; 
       VCGARANT          := NULL;
       VCCALRES          := NULL;
       VFMOVRES          := NULL;
       VCMONRES          := NULL;
       VIRESERVA         := NULL;
       VIINGRESO         := NULL;
       VIRECOBRO         := NULL;
       VICAPRIE          := NULL;
       VIPENALI          := NULL;
       VFCONTAB          := NULL;
       VCMOVRES          := NULL;
       VFRESINI          := NULL;
       VFRESFIN          := NULL;
       VFULTPAG          := NULL;
       Vctipgas          := NULL;
       vvalor_agen       := null;
       vvalor_aero       := NULL;
       vidres            := NULL;  
       --IAXIS-5194 Cambios para la parte de reservas 
       OPEN c_pagos;
    FETCH c_pagos
      INTO vpago;
       CLOSE c_pagos;

       OPEN c_saldo;
    FETCH c_saldo
      INTO vsaldo;
       CLOSE c_saldo;

       IF vpago = 'X' THEN
          RAISE e_nfactura_error;
       END IF;


       vtimporte := pineto_aero + pineto_agencia;

       IF vsaldo < vtimporte THEN
          RAISE e_importe_error;
       END IF;
       vpasexec := 2;
       OPEN c_destinatario(pnsinies, pntramit , psperson_agencia);
    FETCH c_destinatario
      INTO vexistetramitador;
       CLOSE c_destinatario;

       IF vexistetramitador != 'X' THEN

      /* Cambios de IAXIS-3662 : Start */
      vnerror := pac_siniestros.f_ins_destinatario(pnsinies,
                                                   pntramit,
                                                   psperson_agencia,
                                                   null,
                                                   null,
                                                   100,
                                                   170,
                                                   53,
                                                   0,
                                                   null);
      /* Cambios de IAXIS-3662 : Start */

          IF vnerror <> 0 THEN
              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
              RAISE e_object_error;
          END IF;

       END IF;
       vpasexec := 3;
       OPEN c_destinatario(pnsinies, pntramit , psperson_aero);
    FETCH c_destinatario
      INTO vexistetramitador;
       CLOSE c_destinatario;
       vpasexec := 4;
       IF vexistetramitador != 'X' THEN
      /* Cambios de IAXIS-3662 : Start */
      vnerror := pac_siniestros.f_ins_destinatario(pnsinies,
                                                   pntramit,
                                                   psperson_aero,
                                                   null,
                                                   null,
                                                   100,
                                                   170,
                                                   53,
                                                   0,
                                                   null);
      /* Cambios de IAXIS-3662 : Start */

          IF vnerror <> 0 THEN
              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
              RAISE e_object_error;
          END IF;

       END IF;
       vpasexec := 5;
     --IAXIS 7655 AABC cambios para extraer el agente
     BEGIN
        --
        SELECT s.cagente
          INTO v_cagente 
          FROM Sin_Siniestro sn, seguros s  
         WHERE nsinies   = pnsinies 
           AND s.sseguro = sn.sseguro;
        --
     EXCEPTION WHEN OTHERS THEN
       -- 
       v_cagente := NULL;
       --    
     END;  
     --IAXIS 7655 AABC cambios para extraer el agente 

    /* Cambios de IAXIS-3662 : Start */
    vparam := 'parametros - pnsinies:' || pnsinies || ' pntramit:' ||
              pntramit || ' psperson_agencia:' || psperson_agencia ||
              ' pctipgas:' || pctipgas || ' pnfacref:' || pnfacref ||
              ' pisinret_agencia:' || pisinret_agencia || ' piiva_agencia:' ||
              piiva_agencia || ' piiva_agencia:' || piiva_agencia ||
              ' pnfacref:' || pnfacref || ' pffacref:' || pffacref ||
              ' psperson_agencia:' || psperson_agencia;
    --IAXIS-5194 Cambios para la parte de reservas 
    SELECT CTIPRES,CGARANT,CCALRES,nmovres,FMOVRES,CMONRES,IRESERVA,IINGRESO,IRECOBRO,
           ICAPRIE,IPENALI,CMOVRES,fresini,fresfin,fultpag,ctipgas,csolidaridad,idres
      INTO VCTIPRES,VCGARANT,VCCALRES,VNMOVRES,VFMOVRES,VCMONRES,VIRESERVA,VIINGRESO,VIRECOBRO,
           VICAPRIE,VIPENALI,VCMOVRES,VFRESINI,VFRESFIN,VFULTPAG,Vctipgas,Vcsolidaridad,vidres
      from sin_tramita_reserva r
     where r.nsinies = PNSINIES
       and r.ctipres = PCTIPRES
       AND r.cgarant = pcgarant
       and r.idres = (select max(i1.idres)
                        from sin_tramita_reserva i1
                       WHERE nsinies    = r.nsinies
                         AND i1.ctipres = r.ctipres
                         AND i1.cgarant = r.cgarant 
                         AND i1.idres   = pidres)
       and r.nmovres = (select max(i2.nmovres)
                          from sin_tramita_reserva i2
                         WHERE i2.nsinies = r.nsinies
                           AND i2.ctipres = r.ctipres
                           AND i2.cgarant = r.cgarant
                           AND i2.idres   = pidres);
    --IAXIS-5194 Cambios para la parte de reservas                      
    VNERROR := PAC_IAX_SINIESTROS.F_INICIALIZASINIESTRO(NULL,NULL,PNSINIES,MENSAJES);
    if vireserva is not null then
      vvalor_agen := vireserva - pisinret_agencia;
    end if;
    --IAXIS 7654 AABC carga masiva pgos de tiquetes 
  /*IF Vcsolidaridad =1 THEN 
    vdetvalor:=339;
    ELSE
    vdetvalor:=342;
    END IF;*/
    --IAXIS 7654 AABC carga masiva pgos de tiquetes 
    VNERROR := PAC_IAX_SINIESTROS.F_SET_OBJETO_SINTRAMIRESERVA(PNSINIES,
                                                               PNTRAMIT,
                                                               pctipres,
                                                               null,
                                                               VNMOVRES,
                                                               VCGARANT,
                                                               VCCALRES,
                                                               null,
                                                               VCMONRES,
                                                               vvalor_agen,
                                                               pisinret_agencia,
                                                               null,
                                                               null,
                                                               VICAPRIE,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               Vctipgas,
                                                               'RESER',
                                                               'axissin010',
                                                               null,
                                                               null,
                                                               nvl(to_number(2),
                                                                   null),
                                                               null,
                                                               MENSAJES,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               Vcsolidaridad);
       IF vnerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
            RAISE e_object_error;
       END IF;
    /* Cambios de IAXIS-3662 : End */

    /* Cambios de IAXIS-3662 : Start */
    --IAXIS 7654 AABC carga masiva pgos de tiquetes 
    vnerror := pac_siniestros.f_ins_pago(vpsidepag_agencia,
                                         pnsinies,
                                         pntramit,
                                         psperson_agencia,
                                         53,
                                         pctipgas,
                                         pcconpag_agen,
                                         pcconpag_agen,
                                         24,
                                         f_sysdate,
                                         null,
                                         null,
                                         pisinret_agencia,
                                         0,
                                         piiva_agencia,
                                         null,
                                         null,
                                         null,
                                         null,
                                         pnfacref,
                                         pffacref,
                                         1,
                                         null,
                                         null,
                                         0,
                                         0,
                                         null,
                                         null,
                                         0,
                                         null,
                                         VCMONRES,
                                         v_cagente,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         psperson_agencia,
                                         ptobserva,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null);
    /* Cambios de IAXIS-3662 : End */
    --IAXIS-5194 Cambios para la parte de reservas 
    UPDATE sin_tramita_reserva sr 
       SET sr.sidepag = vpsidepag_agencia,
           sr.cmovres = 4,
           sr.ipago   = pisinret_agencia,
           sr.ipago_moncia = pisinret_agencia
     WHERE sr.nsinies = pnsinies
       AND sr.ntramit = pntramit
       AND sr.ctipres = pctipres
       AND sr.cgarant = VCGARANT
       and sr.idres = (select max(i1.idres)
                        from sin_tramita_reserva i1
                          WHERE i1.nsinies = sr.nsinies
                            AND i1.ctipres = sr.ctipres
                            AND i1.idres   = vidres)
       and sr.nmovres = (select max(i2.nmovres)
                          from sin_tramita_reserva i2
                          WHERE i2.nsinies = sr.nsinies
                            AND i2.ctipres = sr.ctipres
                            AND i2.idres   = sr.idres);
    --
    UPDATE sin_tramita_reservadet  sd
       SET sd.sidepag = vpsidepag_agencia
     WHERE sd.nsinies = pnsinies
       AND sd.idres   = vidres
       AND sd.nmovres = VNMOVRES + 1;
    --IAXIS-5194 Cambios para la parte de reservas                           
    IF vnerror <> 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
      RAISE e_object_error;
    END IF;
    vnerror := pac_siniestros.f_ins_movpago(vpsidepag_agencia,
                                            0,
                                            f_sysdate,
                                            1,
                                            f_sysdate,
                                            null,
                                            0,
                                            vpnmovpag,
                                            0,
                                            0);
    vpnmovpag := vpnmovpag +1;                                        
    vnerror := pac_siniestros.f_ins_movpago(vpsidepag_agencia,
                                            1,
                                            f_sysdate,
                                            1,
                                            f_sysdate,
                                            null,
                                            0,
                                            vpnmovpag ,
                                            0,
                                            0); 
    vpnmovpag := vpnmovpag +1;                                        
    vnerror := pac_siniestros.f_ins_movpago(vpsidepag_agencia,
                                            9,
                                            f_sysdate,
                                            1,
                                            f_sysdate,
                                            null,
                                            1,
                                            vpnmovpag ,
                                            null,
                                            null);

    /* Cambios de IAXIS-3662 : start */
    vnerror := pac_siniestros.f_ins_pago_gar(pnsinies,
                                             pntramit,
                                             vpsidepag_agencia,
                                             pctipres,
                                             pnmovres,
                                             pcgarant,
                                             null,
                                             null,
                                             VCMONRES,
                                             pisinret_agencia,
                                             piiva_agencia,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             ppiva_agencia,
                                             VCMONRES,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             pcconpag_agen,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null);
    /* Cambios de IAXIS-3662 : End */

       vpasexec := 6;

    /* Cambios de IAXIS-3662 : start */
    --IAXIS-5194 Cambios para la parte de reservas  
    SELECT CTIPRES,CGARANT,CCALRES,nmovres,FMOVRES,CMONRES,IRESERVA,
           IINGRESO,IRECOBRO,ICAPRIE,IPENALI,CMOVRES,FRESINI,FRESFIN,
           FULTPAG,ctipgas,csolidaridad,idres 
      INTO VCTIPRES,VCGARANT,VCCALRES,VNMOVRES,VFMOVRES,VCMONRES,VIRESERVA,
           VIINGRESO,VIRECOBRO,VICAPRIE,VIPENALI,VCMOVRES,VFRESINI,VFRESFIN,
           VFULTPAG,Vctipgas,Vcsolidaridad,vidres
      from sin_tramita_reserva r
     where r.nsinies = PNSINIES
       and r.ctipres = PCTIPRES
       AND r.cgarant = vcgarant
       and r.idres = (select max(i1.idres)
                        from sin_tramita_reserva i1
                       WHERE nsinies    = r.nsinies
                         AND i1.ctipres = r.ctipres
                         AND i1.cgarant = r.cgarant 
                         AND i1.idres   = pidres)
       and r.nmovres = (select max(i2.nmovres)
                          from sin_tramita_reserva i2
                         WHERE i2.nsinies = r.nsinies
                           AND i2.ctipres = r.ctipres
                           AND i2.cgarant = r.cgarant
                           AND i2.idres   = r.idres);
    --IAXIS-5194 Cambios para la parte de reservas 
    --IAXIS 7654 AABC carga masiva pgos de tiquetes 			   
    vipago := NULL; 
    --			   
    if vireserva is not null then
      vvalor_aero := vireserva - ( pisinret_aero + piotrosgas_aero );
      vipago := pisinret_aero + piotrosgas_aero;
    end if;

   --IAXIS 7654 AABC carga masiva pgos de tiquetes 
   /*IF Vcsolidaridad =1 THEN 
    vdetvalor:=339;
    ELSE
    vdetvalor:=342;
    END IF;*/
    --IAXIS 7654 AABC carga masiva pgos de tiquetes 
    VNERROR := PAC_IAX_SINIESTROS.F_SET_OBJETO_SINTRAMIRESERVA(PNSINIES,
                                                               PNTRAMIT,
                                                               pctipres,
                                                               null,
                                                               VNMOVRES,
                                                               VCGARANT,
                                                               VCCALRES,
                                                               null,
                                                               VCMONRES,
                                                               vvalor_aero,
                                                               vipago,
                                                               null,
                                                               null,
                                                               VICAPRIE,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               Vctipgas,
                                                               'RESER',
                                                               'axissin010',
                                                               null,
                                                               null,
                                                               nvl(to_number(2),
                                                                   null),
                                                               null,
                                                               MENSAJES,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               Vcsolidaridad);
       IF vnerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
            RAISE e_object_error;
       END IF;
    /* Cambios de IAXIS-3662 : End */
    IF vnerror <> 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
      RAISE e_object_error;
    END IF;
    /* Cambios de IAXIS-3662 : Start */
    vnerror := pac_siniestros.f_ins_pago(vpsidepag_aero,
                                         pnsinies,
                                         pntramit,
                                         psperson_aero,
                                         53,
                                         pctipgas,
                                         pcconpag_aero,
                                         pcconpag_aero,
                                         24,
                                         f_sysdate,
                                         null,
                                         null,
                                         pisinret_aero,
                                         0,
                                         piiva_aero,
                                         null,
                                         null,
                                         null,
                                         null,
                                         pnfacref,
                                         pffacref,
                                         1,
                                         null,
                                         null,
                                         0,
                                         0,
                                         null,
                                         null,
                                         0,
                                         null,
                                         VCMONRES,
                                         v_cagente,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         psperson_aero,
                                         ptobserva,
                                         piotrosgas_aero,
                                         null,
                                         null,
                                         piotrosgas_aero,
                                         null,
                                         null);
    /* Cambios de IAXIS-3662 : End */
    UPDATE sin_tramita_reserva sr 
       SET sr.sidepag = vpsidepag_aero,
           sr.cmovres = 4,
           sr.ipago   = vipago, 
           sr.ipago_moncia = vipago
     WHERE sr.nsinies = pnsinies
       AND sr.ntramit = pntramit
       AND sr.ctipres = pctipres
       AND sr.cgarant = VCGARANT
       and sr.idres = (select max(i1.idres)
                        from sin_tramita_reserva i1
                          WHERE i1.nsinies = sr.nsinies
                            AND i1.ctipres = sr.ctipres
                            AND i1.ntramit = sr.ntramit
                            AND i1.idres   = vidres)
       and sr.nmovres = (select max(i2.nmovres)
                          from sin_tramita_reserva i2
                          WHERE i2.nsinies = sr.nsinies
                            AND i2.ntramit = sr.ntramit
                            AND i2.ctipres = sr.ctipres
                            AND i2.idres   = vidres);    
    --IAXIS-5194 Cambios para la parte de reservas   
    --
    UPDATE sin_tramita_reservadet  sd
       SET sd.sidepag = vpsidepag_aero
     WHERE sd.nsinies = pnsinies
       AND sd.idres   = vidres
       AND sd.nmovres = VNMOVRES + 1;
    --IAXIS 7654 AABC carga masiva pgos de tiquetes 			   
    vpnmovpag := 0;			   
    vnerror := pac_siniestros.f_ins_movpago(vpsidepag_aero,
                                            0,
                                            f_sysdate,
                                            1,
                                            f_sysdate,
                                            null,
                                            0,
                                            vpnmovpag,
                                            0,
                                            0);
    vpnmovpag := vpnmovpag +1;                                        
    vnerror := pac_siniestros.f_ins_movpago(vpsidepag_aero,
                                            1,
                                            f_sysdate,
                                            1,
                                            f_sysdate,
                                            null,
                                            0,
                                            vpnmovpag ,
                                            0,
                                            0); 
    vpnmovpag := vpnmovpag +1;                                        
    vnerror := pac_siniestros.f_ins_movpago(vpsidepag_aero,
                                            9,
                                            f_sysdate,
                                            1,
                                            f_sysdate,
                                            null,
                                            1,
                                            vpnmovpag ,
                                            null,
                                            null);

       IF vnerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
            RAISE e_object_error;
       END IF;
       vpasexec := 7;

    /* Cambios de IAXIS-3662 : Start */

    vnerror := pac_siniestros.f_ins_pago_gar(pnsinies,
                                             pntramit,
                                             vpsidepag_aero,
                                             pctipres,
                                             pnmovres,
                                             pcgarant,
                                             null,
                                             null,
                                             VCMONRES,
                                             pisinret_aero,
                                             piiva_aero,
                                             null,
                                             null, --piiva_aero + piotrosgas_aero,
                                             null,
                                             null,
                                             null,
                                             null,
                                             ppiva_aero,
                                             VCMONRES,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             pcconpag_aero,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             piotrosgas_aero,
                                             null,
                                             null);
    /* Cambios de IAXIS-3662 : End */

         IF vnerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
            RAISE e_object_error;
       END IF;
       vpasexec := 8;
        COMMIT;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109953);
      RETURN 0;
    EXCEPTION
        WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        9000505,
                                        vpasexec,
                                        vparam);
          RETURN 1;
        WHEN e_nfactura_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        9904179,
                                        vpasexec,
                                        vparam);
          RETURN 1;
        WHEN e_importe_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        9910844,
                                        vpasexec,
                                        vparam);
          RETURN 1;
        WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
          RETURN 1;
  END f_pagos_avion;
   -- IAXIS 3642 3662 AABC 24/05/2019 cambios en tiquetes aereos y agencias 

  /***********************************************************************
    FUNCTION f_get_sin_tramita_apoyo:
         obtener los datos de una solicitud de apoyo tecnico

  ***********************************************************************/
  FUNCTION f_get_sin_tramita_apoyo (psintapoy IN NUMBER,
                                    pnsinies  IN VARCHAR2,
                                    pntramit  IN NUMBER,
                                    mensajes  OUT t_iax_mensajes)
     RETURN SYS_REFCURSOR IS
     v_cursor SYS_REFCURSOR;
     vnumerr  NUMBER(8) := 0;
     vpasexec NUMBER(8) := 1;
     vparam   VARCHAR2(500) := 'psintapoy: ' || psintapoy || 'pnsinies = ' ||
                               pnsinies || ' pntramit: ' || pntramit;
     vobject  VARCHAR2(200) := 'PAC_MD_siniestros.f_get_sin_tramita_apoyo';
  BEGIN
     v_cursor := pac_siniestros.f_get_sin_tramita_apoyo (psintapoy,
                                                            pnsinies,
                                                            pntramit,
                                                            mensajes);
     RETURN v_cursor;
  EXCEPTION
     WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                          vobject,
                                          1000001,
                                          vpasexec,
                                          vparam,
                                          psqcode  => SQLCODE,
                                          psqerrm  => SQLERRM);
        RETURN NULL;
  END f_get_sin_tramita_apoyo;

  /***********************************************************************
       FUNCTION f_set_sin_tramita_apoyo:
            guardar una solicitud de apoyo tecnico

     ***********************************************************************/
  FUNCTION f_set_sin_tramita_apoyo (psintapoy  IN NUMBER,
                                    pnsinies   IN VARCHAR2,
                                    pntramit   IN NUMBER,
                                    pnapoyo    IN NUMBER,
                                    pcunitra   IN VARCHAR2,
                                    pctramitad IN VARCHAR2,
                                    pfingreso  IN DATE,
                                    pftermino  IN DATE,
                                    pfsalida   IN DATE,
                                    ptobserva  IN VARCHAR2,
                                    ptlocali   IN VARCHAR2,
                                    pcsiglas   IN NUMBER,
                                    ptnomvia   IN VARCHAR2,
                                    pnnumvia   IN NUMBER,
                                    ptcomple   IN VARCHAR2,
                                    pcpais     IN NUMBER,
                                    pcprovin   IN NUMBER,
                                    pcpoblac   IN NUMBER,
                                    pcpostal   IN VARCHAR2,
                                    pcviavp    IN NUMBER,
                                    pclitvp    IN NUMBER,
                                    pcbisvp    IN NUMBER,
                                    pcorvp     IN NUMBER,
                                    pnviaadco  IN NUMBER,
                                    pclitco    IN NUMBER,
                                    pcorco     IN NUMBER,
                                    pnplacaco  IN NUMBER,
                                    pcor2co    IN NUMBER,
                                    pcdet1ia   IN NUMBER,
                                    ptnum1ia   IN VARCHAR2,
                                    pcdet2ia   IN NUMBER,
                                    ptnum2ia   IN VARCHAR2,
                                    pcdet3ia   IN NUMBER,
                                    ptnum3ia   IN VARCHAR2,
                                    plocalidad IN VARCHAR2,
                                    pfalta     IN DATE,
                                    pcusualt   IN VARCHAR2,
                                    pfmodifi   IN DATE,
                                    pcusumod   IN VARCHAR2,
                                    ptobserva2 IN VARCHAR2,
                                    pcagente   IN NUMBER,
                                    psperson   IN NUMBER,
                                    mensajes   OUT t_iax_mensajes)
     RETURN NUMBER IS
     vnumerr  NUMBER(8) := 0;
     vpasexec NUMBER(8) := 1;
     vparam   VARCHAR2(500) := '';
     vobject  VARCHAR2(200) := 'PAC_MD_siniestros.f_set_sin_tramita_apoyo';
     cont     NUMBER;
  BEGIN
     RETURN pac_siniestros.f_set_sin_tramita_apoyo (psintapoy,
                                                       pnsinies,
                                                       pntramit,
                                                       pnapoyo,
                                                       pcunitra,
                                                       pctramitad,
                                                       pfingreso,
                                                       pftermino,
                                                       pfsalida,
                                                       ptobserva,
                                                       ptlocali,
                                                       pcsiglas,
                                                       ptnomvia,
                                                       pnnumvia,
                                                       ptcomple,
                                                       pcpais,
                                                       pcprovin,
                                                       pcpoblac,
                                                       pcpostal,
                                                       pcviavp,
                                                       pclitvp,
                                                       pcbisvp,
                                                       pcorvp,
                                                       pnviaadco,
                                                       pclitco,
                                                       pcorco,
                                                       pnplacaco,
                                                       pcor2co,
                                                       pcdet1ia,
                                                       ptnum1ia,
                                                       pcdet2ia,
                                                       ptnum2ia,
                                                       pcdet3ia,
                                                       ptnum3ia,
                                                       plocalidad,
                                                       pfalta,
                                                       pcusualt,
                                                       pfmodifi,
                                                       pcusumod,
                                                       ptobserva2,
                                                       pcagente,
                                                       psperson,
                                                       mensajes);
  EXCEPTION
     WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                          vobject,
                                          1000001,
                                          vpasexec,
                                          vparam,
                                          psqcode  => SQLCODE,
                                          psqerrm  => SQLERRM);
        RETURN 1;
  END f_set_sin_tramita_apoyo;

  /***********************************************************************
       FUNCTION f_del_sin_tramita_apoyo:
            eliminar una solicitud de apoyo tecnico

     ***********************************************************************/
  FUNCTION f_del_sin_tramita_apoyo (psintapoy IN NUMBER,
                                    pnsinies  IN VARCHAR2,
                                    pntramit  IN NUMBER,
                                    mensajes  OUT t_iax_mensajes)
     RETURN NUMBER IS
     vnumerr  NUMBER(8) := 0;
     vpasexec NUMBER(8) := 1;
     vparam   VARCHAR2(500) := 'psintapoy: ' || psintapoy || 'pnsinies = ' ||
                               pnsinies || ' pntramit: ' || pntramit;
     vobject  VARCHAR2(200) := 'PAC_MD_siniestros.f_del_sin_tramita_apoyo';
  BEGIN
     RETURN pac_siniestros.f_del_sin_tramita_apoyo (psintapoy,
                                                       pnsinies,
                                                       pntramit,
                                                       mensajes);
  EXCEPTION
     WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                          vobject,
                                          1000001,
                                          vpasexec,
                                          vparam,
                                          psqcode  => SQLCODE,
                                          psqerrm  => SQLERRM);
        RETURN 1;
  END f_del_sin_tramita_apoyo;


  FUNCTION f_get_clasificasiniestro(
    pnsinies IN VARCHAR2,
    pnpagos  IN NUMBER,  pntramita  IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  cur sys_refcursor;
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(500) := 'param pnsinies=' || pnsinies;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_get_clasificasiniestro';
  terror   VARCHAR2(200) := ' Error a recuperar garantias';
  vnerror  NUMBER;
  vquery   VARCHAR2(5000);
  vctramit NUMBER;
BEGIN
  --IAXIS 3609 AABC se ajusta consulta para tener la tramitacion
  SELECT DISTINCT (ctramit)
    INTO vctramit  
    FROM sin_tramitacion
   WHERE nsinies = pnsinies
     AND ctramit = 20
     AND ntramit IN (SELECT ntramit
                       FROM sin_tramita_movimiento
                      WHERE nsinies = pnsinies
                        AND cesttra = 0);
  --IAXIS 3609 AABC se ajusta consulta para tener la tramitacion                                           
  IF vctramit =20 THEN
   vnerror    := pac_siniestros.f_get_clasificasiniestro(pnsinies, pnpagos, 1, vquery);
   END IF;
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;
EXCEPTION

 WHEN NO_DATA_FOUND THEN
 vnerror    := pac_siniestros.f_get_clasificasiniestro(pnsinies, pnpagos, pntramita, vquery);
  IF vnerror <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
    RAISE e_object_error;
  END IF;
  cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
  RETURN cur;

WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, terror, SQLCODE, SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF;
  RETURN cur;
END f_get_clasificasiniestro;

  /*************************************************************************
      FUNCTION f_ins_estimasini
         Inserta a la tabla sin_tramita_estsiniestro.
         param in pnsinies : numero de siniestro
         param in ntramit  : numero de tramitacion
         param in nmovimi  : numero de movimiento
         param in nmaxpp   : maxima perdida probable
         param in ncontin   : valor de la contingencia
         param in nriesgo   : valor del riesgo
         param in cobserv   : observaciones         
         param in pnclasepro valor Clase de proceso
         param in pninstproc valor Instancia del Proceso
         param in pnfallocp valor Fallo
         param in pncalmot valor Calificación Motivos
         param in pfcontingen valor Fecha
         param in ptobsfallo valor Observación de Fallo
         return            : 0 -> correcto
                             1 -> error
      IAXIS 3603 AABC 10/05/2019
   *************************************************************************/
    FUNCTION f_ins_estimasini(
      pnsinies IN NUMBER,
      pntramit  IN NUMBER,
      pnmovimi  IN NUMBER,
      pnmaxpp  IN NUMBER,
      pncontin  IN NUMBER,
      pnriesgo  IN NUMBER,
      pcobserv IN VARCHAR2
    ,pnclasepro IN NUMBER
    ,pninstproc IN NUMBER
    ,pnfallocp IN NUMBER
    ,pncalmot IN NUMBER
    ,pfcontingen IN DATE
    ,ptobsfallo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
    RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'pac_md_siniestros.f_ins_estimasini';
  vparam      VARCHAR2(500) := 'parametrosMD - pnsinies:' || pnsinies || ' pntramit: ' || pntramit || ' pnmovimi: ' || pnmovimi || ' pnmaxpp: ' || pnmaxpp || ' pncontin: ' || pncontin || ' pnriesgo: ' || pnriesgo || ' nclasepro:' || pnclasepro || ' ninstproc:' || pninstproc || ' nfallocp:' || pnfallocp || ' ncalmot:' || pncalmot || ' fcontingen:' || pfcontingen ;
  vpasexec    NUMBER        := 1;
  vnumerr     NUMBER;
BEGIN
  vnumerr    := pac_siniestros.f_ins_estimasini(pnsinies, pntramit, pnmovimi, pnmaxpp, pncontin, pnriesgo, pcobserv,pnclasepro,pninstproc,pnfallocp,pncalmot,pfcontingen,ptobsfallo);    
  IF vnumerr <> 0 THEN
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    RAISE e_object_error;
  END IF;
  RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
  RETURN 1;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
  RETURN 1;
END f_ins_estimasini;

   /*************************************************************************
    f_get_tramita_estsini
    Traspasa los valores de los parametros a los atributos del objeto f_get_tramita_estsini.
    param in pnsinies                : no de siniestro
    param in pntramte                : no de tramite
    return                           : cursor
   ************************************************************************/
FUNCTION f_get_tramita_estsini(PNSINIES IN VARCHAR2,
                               PNTRAMIT IN NUMBER,
                               MENSAJES IN OUT T_IAX_MENSAJES)
  RETURN SYS_REFCURSOR IS
  VPARAM      VARCHAR2(500) := 'pnsinies: ' || PNSINIES || ' - pntramit: ' ||
                               PNTRAMIT;
  VPASEXEC    NUMBER(5) := 1;
  VOBJECTNAME VARCHAR2(100) := 'PAC_MD_SINIESTROS.f_get_tramita_estsini';
  VNUMERR     NUMBER(8) := 1;
  VQUERY      VARCHAR2(10000) := '';
  CUR         SYS_REFCURSOR;
BEGIN
 p_tab_error(f_sysdate, f_user, 'set_pagogar22', 1, 'error1', VPARAM);
  IF PNSINIES IS NULL OR PNTRAMIT IS NULL THEN
    RAISE E_PARAM_ERROR;
  END IF;
  VQUERY := 'SELECT st.nmovimi,st.nmaxpp,ff_desvalorfijo(8002018,pac_md_common.f_get_cxtidioma,st.ncontin) ncontin ,ff_desvalorfijo(8002019,pac_md_common.f_get_cxtidioma,st.nriesgo) nriesgo ,SUBSTR(st.cobserv,0,200) cobserv ,st.cusumod,st.fmodif' ||
            '  FROM SIN_TRAMITA_ESTSINIESTRO ST  WHERE ' ||
            '   st.nsinies = ''' ||PNSINIES || '''' || 
            '   AND st.ntramit = ' || PNTRAMIT ||
            'ORDER BY st.nmovimi DESC';

  CUR    := PAC_IAX_LISTVALORES.F_OPENCURSOR(VQUERY, MENSAJES);
  RETURN CUR;
EXCEPTION
  WHEN E_PARAM_ERROR THEN
    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(MENSAJES,
                                      VOBJECTNAME,
                                      1000005,
                                      VPASEXEC,
                                      VPARAM);

    RETURN NULL;
  WHEN E_OBJECT_ERROR THEN
    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(MENSAJES,
                                      VOBJECTNAME,
                                      1000006,
                                      VPASEXEC,
                                      VPARAM);

    RETURN NULL;
  WHEN OTHERS THEN
    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(MENSAJES,
                                      VOBJECTNAME,
                                      1000001,
                                      VPASEXEC,
                                      VPARAM,
                                      NULL,
                                      SQLCODE,
                                      SQLERRM);
    IF CUR%ISOPEN THEN
      CLOSE CUR;
    END IF;

    RETURN CUR;
END f_get_tramita_estsini;

--Inico IAXIS 4184 07/06/2019 MOS Incluir Cambios Cargue Masivo para pagos

  /***********************************************************************
     FUNCTION f_cargue masivo:
          realiza el cargue masivo de pagos
          autor: Marcelo Ozawa de Sousa - 03/06/2019
   ***********************************************************************/
FUNCTION f_cargue_masivo (pnsinies in varchar2, -- NUMERO DE SINIESTRO
                          pntramit in number, -- NUMERO DE TRAMITACION
                          pnmovres in number, -- NUMERO MOVIMIENTO RESERVA
                          pctipres in number, -- CODIGO DE TIPO DE RESERVA
                          pctipgas in number, -- CODIGO DE TIPO DE GASTO                          
                          pcmonres in varchar2, -- MONEDA DE LA RESERVA            
                          pnnumide in varchar2, -- NUMERO DE IDENTIFICACION DE LA COMPANIA AEREA
                          psperson in number,
                          pnfacref in varchar2, -- NUMERO DE FACTURA
                          pffacref in date, -- FECHA DE FACTURA
                          ptobserva in varchar2, -- OBSERVACIONES
                          pisinret in number, -- IMPORTE BRUTO PASAJE AEREO
                          ppiva in number, -- PORCENTAJE DE IVA PASAJE AEREO
                          piiva in number, -- IMPORTE IVA PASAJE AEREO
                          pifranq in number, -- DEDUCIBLE
                          piotrosgas in number, -- IMPORTE DE OTROS GASTOS / TASA AEROPORTUARIA DEL PASAJE AEREO
                          pineto in number, -- IMPORTE NETO PASAJE AEREO
                          pcconpag in number, -- CONCEPTO DE PAGO
                          psproces IN NUMBER, -- NUMERO PROCESO
			 --Inicio IAXIS 4184 14/06/2019 MOS Incluir forma de pago                              
                          pcforpag in number DEFAULT NULL, -- FORMA DE PAGO
                          --Fin IAXIS 4184 14/06/2019 MOS Incluir forma de pago   
                          mensajes out t_iax_mensajes) RETURN NUMBER IS
    cur sys_refcursor;
    vpasexec            NUMBER(8) := 1;
    vparam              VARCHAR2(500);
    vobject             VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_cargue_masivo';
    terror              VARCHAR2(200) := ' Error a recuperar tramitaciones';
    vnerror             NUMBER;
    vquery              VARCHAR2(5000);
    vpago               VARCHAR2(1);
    vsaldo              NUMBER := 0;
    vgarantia           sin_tramita_reserva.cgarant%TYPE;
    vtimporte           NUMBER := 0;
    vexistetramitador   VARCHAR2(1) := 'O';
    vpsidepag           NUMBER;
    vipago              NUMBER;
    vpnmovres           NUMBER := pnmovres;
    vpnmovpag           NUMBER := 0;
    vvalor_garantia     NUMBER;
    vreserva            sin_tramita_reserva%ROWTYPE;
    vdif                NUMBER;
    vinspago            BOOLEAN := FALSE;
    vrestante           NUMBER;
    vaux                NUMBER;
    vvalor  NUMBER := null;
    vobsini ob_iax_siniestros := ob_iax_siniestros();
    CURSOR c_pagos IS 
       SELECT 'X' 
         FROM SIN_TRAMITA_PAGO p, sin_tramita_movpago mp
        WHERE NVL(mp.cestpag, -1) != 6
          AND p.nsinies  = pnsinies
        AND mp.sidepag = p.sidepag
          AND p.NFACREF  = pnfacref
          AND p.sperson  = psperson;
    CURSOR c_destinatario(pnsinies VARCHAR2,
                          pntramit NUMBER,
                          psperson NUMBER) IS 
      SELECT 'X' 
        FROM SIN_TRAMITA_DESTINATARIO
        WHERE NSINIES = pnsinies
        AND NTRAMIT = pntramit
        AND SPERSON = psperson
--Inicio IAXIS 4184 13/06/2019 MOS fix - Incluir Cambios Cargue Masivo para pagos        
        AND CTIPDES = 8;
--Fin IAXIS 4184 13/06/2019 MOS fix - Incluir Cambios Cargue Masivo para pagos        
    CURSOR c_garantias IS 
      SELECT DISTINCT(cgarant) cgarant 
        FROM sin_tramita_reserva
        WHERE nsinies = pnsinies
        AND ctipres = pctipres;
    CURSOR c_reservas IS 
    SELECT * 
      FROM sin_tramita_reserva sr
        WHERE sr.nsinies = pnsinies
        AND sr.cgarant = vgarantia
        AND sr.ctipres = pctipres
       AND sr.nmovres = (SELECT MAX(sr2.nmovres) 
                           FROM sin_tramita_reserva sr2
                            WHERE sr2.nsinies = sr.nsinies
                            AND sr2.cgarant = sr.cgarant
                            AND sr2.ntramit = sr.ntramit
                            AND sr2.ctipres = sr.ctipres);
BEGIN
    
    IF pnsinies IS NULL OR pntramit IS NULL OR pnmovres IS NULL OR
       pctipres IS NULL OR pctipgas IS NULL OR pcmonres IS NULL OR 
       pnnumide IS NULL OR psperson IS NULL OR 
       pnfacref IS NULL OR pffacref IS NULL OR pisinret IS NULL OR 
       ppiva IS NULL OR piiva IS NULL OR pineto IS NULL THEN
        RAISE e_param_error;
    END IF;
    OPEN c_pagos;
    FETCH c_pagos INTO vpago;
    CLOSE c_pagos;
    OPEN c_garantias;
    LOOP
        FETCH c_garantias INTO vgarantia;
        EXIT WHEN c_garantias%NOTFOUND;
        --
        SELECT SUM(NVL(IRESERVA, 0)) SALDO 
          INTO vvalor_garantia 
          FROM sin_tramita_reserva sr
        WHERE sr.nsinies = pnsinies
        AND sr.cgarant = vgarantia
        AND sr.ctipres = pctipres
           AND sr.nmovres = (SELECT MAX(sr2.nmovres) 
                               FROM sin_tramita_reserva sr2
                            WHERE sr2.nsinies = sr.nsinies
                            AND sr2.cgarant = sr.cgarant
                            AND sr2.ntramit = sr.ntramit
                            AND sr2.ctipres = sr.ctipres);
        --
        IF vvalor_garantia < 0 THEN
            vvalor_garantia := 0;
        END IF;
        vsaldo := vsaldo + vvalor_garantia;
    END LOOP;
    CLOSE c_garantias;
    IF vpago = 'X' THEN
        RAISE e_nfactura_error;
    END IF;
    vtimporte := (pisinret) + piotrosgas;
    vrestante := (pisinret) + piotrosgas;
    IF vsaldo < vtimporte THEN
        RAISE e_importe_error;
    END IF;
--------------------------------------------------------------------------------
    vpasexec := 2;
    OPEN c_destinatario(pnsinies, pntramit, psperson);
    FETCH c_destinatario INTO vexistetramitador;
    CLOSE c_destinatario;
    IF vexistetramitador != 'X' THEN        
        vnerror := pac_siniestros.f_ins_destinatario(pnsinies,
                                                     pntramit,
                                                     psperson,
                                                     null,
                                                     null,
                                                     100,
                                                     170,
                                                     8,
                                                     0,
                                                     null);
        IF vnerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
            RAISE e_object_error;
        END IF;
    END IF;
--------------------------------------------------------------------------------
    vpasexec := 3;
    vparam := 'parametros - pnsinies:' || pnsinies || ' pntramit:' ||
              pntramit || ' psperson:' || psperson || ' pctipgas:' || 
              pctipgas || ' pnfacref:' || pnfacref || ' pisinret:' || 
              pisinret || ' piiva:' || piiva || ' pffacref:' || pffacref;
    OPEN c_garantias;
    LOOP
        FETCH c_garantias INTO vgarantia;
        EXIT WHEN c_garantias%NOTFOUND;
        OPEN c_reservas;
        FETCH c_reservas INTO vreserva;
        EXIT WHEN c_reservas%NOTFOUND OR vrestante <= 0;
        vdif := NVL(vreserva.ireserva, 0);        
        IF vdif > 0 THEN
            vvalor := vdif;
            IF vvalor < 0 THEN
                vvalor := 0;            
            END IF;        
            IF vdif < vrestante THEN
                vaux := vdif;
            ELSE
                vaux := vrestante;
            END IF;
            vipago := NVL(vreserva.ipago, 0) + vaux;
            vvalor := vreserva.ireserva - vaux;
            VNERROR := PAC_IAX_SINIESTROS.F_INICIALIZASINIESTRO(NULL,
                                                        NULL,
                                                        PNSINIES,
                                                        MENSAJES);
            VNERROR := PAC_IAX_SINIESTROS.F_SET_OBJETO_SINTRAMIRESERVA(PNSINIES,
                                                                       PNTRAMIT,
                                                                       pctipres,
                                                                       null,
                                                                       vreserva.nmovres,
                                                                       vreserva.cgarant,
                                                                       vreserva.CCALRES,
                                                                       null,
                                                                       vreserva.CMONRES,
                                                                       vvalor,
                                                                       vaux,
                                                                       null,
                                                                       null,
                                                                       vreserva.ICAPRIE,
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       vreserva.ctipgas,
                                                                       'RESER',
                                                                       'axissin010',
                                                                       null,
                                                                       null,
                                                                       nvl(to_number(2),null),
                                                                       null,
                                                                       MENSAJES,
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       null,    
                                                                       null,
                                                                       null,
                                                                       null,
                                                                       0);
            vrestante := vrestante - vdif;            
--            
            IF vnerror <> 0 THEN                
                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
                RAISE e_object_error;
            END IF;
--            
----------------------------------------------------------------------------------            
--            
            IF NOT vinspago THEN                
                vnerror := pac_siniestros.f_ins_pago(vpsidepag,
                                                     pnsinies,
                                                     pntramit,
                                                     psperson,
                                                     8,
                                                     pctipgas,
                                                     pcconpag,
                                                     0,
                                                     --Inicio IAXIS 4184 14/06/2019 MOS Incluir forma de pago                                                         
                                                     pcforpag,
                                                     --Fin IAXIS 4184 14/06/2019 MOS Incluir forma de pago                                                         
                                                     f_sysdate,
                                                     null,
                                                     null,
                                                     pisinret,
                                                     null,
                                                     piiva,
                                                     null,
                                                     nvl(pifranq,0),
                                                     null,
                                                     null,
                                                     pnfacref,
                                                     pffacref,
                                                     1,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     pcmonres,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     psperson,
                                                     ptobserva,
--Inicio IAXIS 4184 13/06/2019 MOS fix - Incluir Cambios Cargue Masivo para pagos                                                     
                                                     piotrosgas,
--Fin IAXIS 4184 13/06/2019 MOS fix - Incluir Cambios Cargue Masivo para pagos                                                     
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null);
                IF vnerror <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
                  RAISE e_object_error;
                END IF;
                vinspago := TRUE;
                
             UPDATE sin_tramita_reserva sr 
                SET sr.sidepag = vpsidepag,
                    sr.cmovres = 4
              WHERE sr.nsinies = pnsinies
                AND sr.ntramit = pntramit
                AND sr.ctipres = pctipres
                and sr.idres = (select max(i1.idres)
                                  from sin_tramita_reserva i1
                                 where i1.nsinies = PNSINIES
                                   and i1.ctipres = PCTIPRES
			           and i1.cgarant = vreserva.cgarant)
                and sr.nmovres = (select max(i2.nmovres)
                                    from sin_tramita_reserva i2
                                   where i2.nsinies = PNSINIES
                                     and i2.ctipres = PCTIPRES
				     and i2.cgarant = vreserva.cgarant);				
               --IAXIS-5194 Cambios para la parte de reservas 
               UPDATE sin_tramita_reservadet sd
                  SET sd.sidepag = vpsidepag
                WHERE sd.nsinies = pnsinies
                  AND sd.idres   = vreserva.idres
                  AND sd.nmovres = vreserva.nmovres + 1;
               --IAXIS-5194 Cambios para la parte de reservas   
----------------------------------------------------------------------------------                
                vnerror := pac_siniestros.f_ins_movpago(vpsidepag,
                                                        0,
                                                        f_sysdate,
                                                        1,
                                                        f_sysdate,
                                                        null,
                                                        0,
                                                        vpnmovpag,
                                                        0,
                                                        0);
                vpnmovpag := vpnmovpag +1;                                        
                vnerror := pac_siniestros.f_ins_movpago(vpsidepag,
                                                        1,
                                                        f_sysdate,
                                                        1,
                                                        f_sysdate,
                                                        null,
                                                        0,
                                                        vpnmovpag ,
                                                        0,
                                                        0); 
               vpnmovpag := vpnmovpag +1;                                        
               vnerror := pac_siniestros.f_ins_movpago(vpsidepag,
                                                        9,
                                                        f_sysdate,
                                                        1,
                                                        f_sysdate,
                                                        null,
                                                        1,
                                                        vpnmovpag ,
                                                        null,
                                                        null);                                                                                                                 
            END IF;
--           
----------------------------------------------------------------------------------
--             
--        
----------------------------------------------------------------------------------
--Inicio IAXIS 4184 13/06/2019 MOS fix - Incluir Cambios Cargue Masivo para pagos
        vnerror := pac_siniestros.f_ins_pago_gar(pnsinies,
                                                 pntramit,
                                                 vpsidepag,
                                                 pctipres,
                                                 vreserva.nmovres,
                                                 vreserva.cgarant,
                                                 null,
                                                 null,
                                                 vreserva.CMONRES,
                                                 vaux,
                                                 piiva,
                                                 null,
                                                 null,
                                                 nvl(pifranq,0),
                                                 null,
                                                 null,
                                                 null,
                                                 ppiva,
                                                 vreserva.nmovres,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 piotrosgas,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null);
--Fin IAXIS 4184 13/06/2019 MOS fix - Incluir Cambios Cargue Masivo para pagos                                                 
        IF vnerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
            RAISE e_object_error;
        END IF;
        END IF;
        CLOSE c_reservas;
    END LOOP;
    CLOSE c_garantias;
    COMMIT;
    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109953);
    RETURN 0;
    EXCEPTION
        WHEN e_param_error THEN
              pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                vobject,
                                                9000505,
                                                vpasexec,
                                                vparam);
        RETURN 1;
        WHEN e_nfactura_error THEN
              pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                vobject,
                                                9904179,
                                                vpasexec,
                                                vparam);
        RETURN 1;
        WHEN e_importe_error THEN
              pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                vobject,
                                                9910844,
                                                vpasexec,
                                                vparam);
        RETURN 1;                                                
        WHEN OTHERS THEN
              pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                vobject,
                                                1000001,
                                                vpasexec,
                                                vparam,
                                                NULL,
                                                SQLCODE,
                                                SQLERRM);
        RETURN 1;        
END f_cargue_masivo;
--Fin IAXIS 4184 07/06/2019 MOS Incluir Cambios Cargue Masivo para pagos

/*************************************************************************
    f_get_max_tramita_estsini
    obtener el maximo movimiento de la tabla sin_tramita_estsiniestro de acuerdo a un siniestro
    param in pnsinies                : no de siniestro
    param in pntramte                : no de tramite
    return                           : cursor
   ************************************************************************/
   FUNCTION f_get_max_tramita_estsini(PNSINIES IN VARCHAR2,                            
                               MENSAJES IN OUT T_IAX_MENSAJES)
  RETURN SYS_REFCURSOR IS
  VPARAM      VARCHAR2(500) := 'pnsinies: ' || PNSINIES;     
  VPASEXEC    NUMBER(5) := 1;
  VOBJECTNAME VARCHAR2(100) := 'PAC_MD_SINIESTROS.f_get_max_tramita_estsini';
  VNUMERR     NUMBER(8) := 1;
  VQUERY      VARCHAR2(10000) := '';
  CUR         SYS_REFCURSOR;
BEGIN
  IF PNSINIES IS NULL  THEN
    RAISE E_PARAM_ERROR;
  END IF;   
            VQUERY := 'SELECT nmovimi,nmaxpp,ncontin ,nriesgo,cobserv,nclasepro,ninstproc,nfallocp,ncalmot,fcontingen,tobsfallo,cusumod,fmodif ' ||
             ' FROM SIN_TRAMITA_ESTSINIESTRO   WHERE' ||
             ' nsinies =  ''' ||PNSINIES || '''' ||
             ' AND nmovimi = ( SELECT max(nmovimi)  FROM SIN_TRAMITA_ESTSINIESTRO   WHERE  nsinies =  ''' ||PNSINIES || '''' ||
             ')';
             p_tab_error(f_sysdate, f_user, 'ini mpp', NULL, '1', VQUERY);

  CUR    := PAC_IAX_LISTVALORES.F_OPENCURSOR(VQUERY, MENSAJES);
  RETURN CUR;
EXCEPTION
  WHEN E_PARAM_ERROR THEN
    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(MENSAJES,
                                      VOBJECTNAME,
                                      1000005,
                                      VPASEXEC,
                                      VPARAM);

    RETURN NULL;
  WHEN E_OBJECT_ERROR THEN
    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(MENSAJES,
                                      VOBJECTNAME,
                                      1000006,
                                      VPASEXEC,
                                      VPARAM);

    RETURN NULL;
  WHEN OTHERS THEN
    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(MENSAJES,
                                      VOBJECTNAME,
                                      1000001,
                                      VPASEXEC,
                                      VPARAM,
                                      NULL,
                                      SQLCODE,
                                      SQLERRM);
    IF CUR%ISOPEN THEN
      CLOSE CUR;
    END IF;

    RETURN CUR;
END f_get_max_tramita_estsini;
/*************************************************************************
funcion borra localizacion de tramitacion
param in pnsinies : numero de siniestro
param in pntramit : numero de siniestro
param in pnlocali : numero de localizacion
param in out mensajes : mensajes de error
*************************************************************************/
FUNCTION f_del_localizacion(
    pnsinies   IN VARCHAR2,
    pntramit   IN NUMBER,
    pnlocali IN NUMBER,
    mensajes   IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec NUMBER(8)     := 1;
  vparam   VARCHAR2(200) := ' pnsinies=' || pnsinies || 'pntramit=' || pntramit || ' pnlocali=' || pnlocali;
  vobject  VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_del_localizacion';
  vnumerr  NUMBER;
  trobat   NUMBER := 0;
BEGIN
  --ComprovaciÃ³ dels parÃ¡metres d'entrada
  IF pnsinies IS NULL OR pntramit IS NULL OR pnlocali IS NULL THEN
    RAISE e_param_error;
  END IF;
  vnumerr    := pac_siniestros.f_del_localizacion(pnsinies, pntramit, pnlocali);
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
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
  RETURN 1;
END f_del_localizacion;
END pac_md_siniestros;
/