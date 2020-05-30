--------------------------------------------------------
--  DDL for Package Body PAC_MIG_AXIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MIG_AXIS" IS
   /***************************************************************************
      NOMBRE:       PAC_MIG_AXIS
      PROPÓSITO:    Proceso de traspaso de informacion de las tablas MIG_ a las
                    distintas tablas de AXIS
      REVISIONES:
      Ver        Fecha       Autor       Descripción
      ---------  ----------  ----------  --------------------------------------
      1.0        22-10-2008  JMC         Creación del package
      2.0        02-06-2009  JMC         Se añaden y modifican funciones para la
                                         migración de DETMOVSEGURO, DETGARANSEG
                                         y MOVRECIBO. (bug 8402)
      3.0        12-06-2009  JMC         Se añade función para la migración de la
                                         tabla MIG_COMISIGARANSEG.
                                         Se añaden mejoras en el proceso de
                                         borrado de las cargas. (bug 10395)
      4.0        30-09-2009  JMC         Se añaden procesos para la carga de las
                                         tablas SEGUROS_ULK y TABVALCES.(bug 11115)
      5.0        19-10-2009  JMC         Modificación f_migra_personas, corrección
                                         grabación PER_CCC. Modificación, la inserción
                                         de la tabla PENALISEG se cambia de f_migra_seguros
                                         a f_migra_movseguro ya que dicha tabla
                                         tiene dependencia de MOVSEGURO.
      6.0        22-10-2009  JMC         Se añade función f_mig_parpersonas (bug 10054)
      7.0        28-10-2009  APD         Bug 11301: CRE080 - FOREIGNS DE PRESTAMOSEG
      8.0        05-11-2009  JMF         bug 0011578 Incorporar proceso post-migración
                                         para la creación del último movimiento de CESIONESREA
      8.1        26-11-2009  AVT         bug: 0012030 s'ajusta la select per tal que el darrer
                                         moviment sigui d'alta o renovació de cartera.
     17.0        27-04-2010  JMC         Bug 0014172  En caso de que el tipo de pregunta sea 4 o 5 CRESPUE=0.
     18.0        11-05-2010  JMC         Bug 0014185  Se cambian las tablas MIG_RWD* por MIG_PK*. En caso de no existir la
                                                      cta de seguros en PER_CCC se migra en PER_CCC la cbancar de SEGUROS.
                                                      Se elimina la parte del modelo antiguo de SINIESTROS.
                                                      Se añade el calculo de NCERTIF para productos colectivos.
     19.0        17-05-2010  JMC         Bug 0014568  En caso de que el tipo de proceso sea Carga, no se inicializa contexto.
     20.0        04-06-2010  JMF         Bug 0014185  ENSA101 - Proceso de carga del fichero (beneficio definido)
     21.0        12-07-2010  ICV         Bug 0014867: CRT002 - Carga de polizas, recibos y siniestros de la compañia ASEFA
     22.0        28-09-2010  AFM         Bug 0014954: CRE998 - Migración módulo siniestros de OLDAXIS a NEWAXIS (tb se añaden
                                                      las tablas SIN_TRAMITA_AGENDA y SIN_TRAMITA_DESTINATARIO)
                                                      JMC - Bug 0015640: Se añade función f_migra_direcciones para la migración de la
                                                      tabla mig_direcciones en caso que la/s direccion/es no se
                                                      encuentren en mig_personas.
     23.0        10-11-2010  FAL         Bug 0016525: CRT002 - Incidencias en cargas (primera carga inicial)
     24.0        27-12-2010  JMP         Bug 0017106: AGA601 - Reaseguro: Anul·lació del detall del rebut
     25.0        15/12/2010  JMP         Bug 0017008: GRC - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nº de póliza
     26.0        01/02/2011  JMP         Bug 0017367: GRC003 - Personalización del número de siniestros
     27.0        31-01-2011  JMF         Bug 0017015: CCAT702 - Migració i parametrització de les dades referents a processos
     28.0        23/03/2011  DRA         Bug 0018054: AGM003 - Administración - Secuencia de nrecibo.
     29.0        26-04-2011  JMC         Bug 0018334: LCOL702 -  Carga pólizas.
     30.0        05-10-2011  JMC         Bug 0019689: AGM703-Incidencias puesta en marcha carga pólizas externas
     31.0        05-11-2011  JMC         Bug 0020003: LCOL001-Adaptació migració persones
     32.0        22-11-2011  JMP         Bug 0018423: LCOL000 - Multimoneda
     33.0        15-12-2011  JMP         Bug 0018423: LCOL705 - Multimoneda
     34.0        22-02-2012  APD         Bug 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
     35.0        22-02-2012  JRH         Bug 0021686: MDP701 - TEC - Migraciónn detprimas
     36.0        19/04/2012  ETM         Bug 0021924: MDP - TEC - Nuevos campos en pantalla de Gestión (Tipo de retribución, Domiciliar 1º recibo, Revalorización franquicia)
     37.0        25/05/2012  JMC         Bug 0022393: MdP - MIG - Viabilidad tarificación productos de migración de Hogar
     38.0        23/08/2012  GAG         Bug 0022666: LCOL_A002-Qtracker: 0004556: Cesion capitales en riesgo
     39.0        25/03/2013  MMS         Bug 0025584: agregar el campo nedamar al insert
     40.0        03/04/2013  JMC         Bug 0026350  LCOL: Carga de agentes red de Liberty
     41.0        30/04/2013  FAL         Bug 0026820: Errores en los productos (26/03)
     42.0        17/05/2013  DCT         Bug 0026955: LCOL: Revisi?n de la p?liza 2395
     43.0        28/08/2013  SHA         Bug 0027963: LCOL_F3BTEC-Noves taules MIG i adaptaci? de les existents
     44.0        17/09/2013  SCO         Add Funcion de migración
     45.0        17/10/2013  SCO         Add Función de migración
     46.0        21/10/2013  JMF         0028909 RSA002-Parametrizacion y ajustes Carga de siniestros RSA
     47.0        27/11/2013  JMF         0028909 RSA002-Parametrizacion y ajustes Carga de siniestros RSA
     48.0        05/12/2013  FPG         0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
                                         Si la carga tiene caso BPM asociado, ejecutar la documentación requerida
                                         y asociar los documentos del caso al seguro.
     49.0       05/05/2014   JLTS        30819_0173312 Cargue de agentes, se adiciona campo cagente en PER_PERSONAS
     50.0       22/10/2015   ETM         Bug 34776/216124: MSV0007-Migración MSV/ añadir las tablas MIG_CTASEGURO_SHADOW Y MIG_SEGDISIN2
     51.0       17/03/2016   JAEG        41143/229973: Desarrollo Diseño técnico CONF_TEC-01_VIGENCIA_AMPARO
     52.0	19/07/2019	PK	Cambio de IAXIS-4844 - Optimizar Petición Servicio I017
   ***************************************************************************/
   /**************************************************************************
        Clave MIG_PK_MIG_AXIS.PK_AXIS
   ***************************************************************************
   PER_PERSONAS             SPERSON
   PER_DETPER               SPERSON|CAGENTE
   PER_DIRECCIONES          SPERSON|CDOMICI
   PER_CCC                  SPERSON|CNORDBAN
   PER_CONTACTOS            SPERSON|CMODCON
   PER_IDENTIFICADOR        SPERSON|CAGENTE|CTIPIDE
   PER_NACIONALIDADES       SPERSON|CAGENTE|CPAIS
   PER_PARPERSONA           CPARAM|SPERSON|CAGENTE
   AGENTES                  CAGENTE
   REDCOMERCIAL             CEMPRES|CAGENTE|FMOVIMI
   CONTRATOSAGE             CEMPRES|CAGENTE
   SEGUROS                  SSEGURO
   TOMADORES                SSEGURO|SPERSON
   CNVPOLIZAS               SISTEMA|POLISSA_INI
   SEG_CBANCAR              SSEGURO|NMOVIMI
   INTERTECSEG              SSEGURO|NMOVIMI|NDESDE
   SEGUROS_AHO              SSEGURO
   SEGUROS_REN              SSEGURO
   ASEGURADOS               SSEGURO|SPERSON|NORDEN
   RIESGOS                  SSEGURO|NRIESGO
   AUTRIESGOS               SSEGURO|NRIESGO|NMOVIMI
   AUTDETRIESGOS            SSEGURO|NRIESGO|NMOVIMI|CACCESORIO
   SITRIESGO                SSEGURO|NRIESGO
   MOVSEGURO                SSEGURO|NMOVIMI
   HISTORICOSEGUROS         SSEGURO|NMOVIMI
   DETMOVSEGURO             SSEGURO|NMOVIMI|CMOTMOV|NRIESGO|CGARANT|CPREGUN
   PENALISEG                SSEGURO|NMOVIMI|CTIPMOV|NINIRAN
   PRESTAMOS                CTAPRES|FALTA
   PRESTCUADROSEG           SSEGURO|NMOVIMI|FEFECTO
   GARANSEG                 SSEGURO|NRIESGO|CGARANT|NMOVIMI|FINIEFE
   DETGARANSEG              SSEGURO|NRIESGO|CGARANT|NMOVIMI|FINIEFE|NDETGAR
   COMISIGARANSEG           SSEGURO|NRIESGO|CGARANT|NMOVIMI|FINIEFE|NDETGAR
   PREGUNSEG                SSEGURO|NRIESGO|CPREGUN|NMOVIMI
   PREGUNPOLSEG             SSEGURO|CPREGUN|NMOVIMI
   CTASEGURO                SSEGURO|FCONTAB|NNUMLIN
   CTASEGURO_LIBRETA        SSEGURO|FCONTAB|NNUMLIN
   PREGUNGARANSEG           SSEGURO|NRIESGO|CGARANT|NMOVIMI|FINIEFE|NMOVIMA|CPREGUN
   CLAUSUESP                SSEGURO|NRIESGO|CCLAESP|NMOVIMI|NORDCLA
   CLAUBENSEG               NMOVIMI|SCLABEN|SSEGURO|NRIESGO
   CLAUSUSEG                SSEGURO|NMOVIMI|SCLAGEN
   RECIBOS                  NRECIBO
   MOVRECIBO                SMOVREC
   DETRECIBOS               NRECIBO|CCONCEP|CGARANT|NRIESGO
   AGENSEGU                 SSEGURO|NLINEA
   SEGUROS_ULK              SSEGURO
   SEGDISIN2                SSEGURO|NRIESGO|NMOVIMI|CCESTA
   TABVALCES                CCESTA|FVALOR
   PRESTAMOSEG              CTAPRES|SSEGURO|NMOVIMI|NRIESGO
   SIN_SINIESTRO            NSINIES
   SIN_SINIESTRO_REFERENCIAS SREFEXT
   SIN_MOVSINIESTRO         NSINIES|NMOVSIN
   SIN_TRAMITACION          NSINIES|NTRAMIT
   SIN_TRAMITA_MOVIMIENTO   NSINIES|NTRAMIT|NMOVTRA
   SIN_TRAMITA_AGENDA       NSINIES|NTRAMIT|NLINAGE
   SIN_TRAMITA_PERSONASREL  NSINIES|NTRAMIT|NPERSREL
   SIN_TRAMITA_DESTINATARIO NSINIES|NTRAMIT|SPERSON|CTIPDES
   SIN_TRAMITA_RESERVA      NSINIES|NTRAMIT|CTIPRES|NMOVRES
   SIN_TRAMITA_PAGO         SIDEPAG
   SIN_TRAMITA_MOVPAGO      SIDEPAG|NMOVPAG
   SIN_TRAMITA_PAGO_GAR     SIDEPAG|CTIPRES|NMOVRES
   SUP_DIFERIDOSSEG         CMOTMOV|SSEGURO|ESTADO
   SUP_ACCIONES_DIF         CMOTMOV|SSEGURO|NORDEN|ESTADO
   PAGOSRENTA               SRECREN
   MOVPAGREN                SRECREN|SMOVPAG
   DEPOSITARIAS             CCODDEP
   PLANPENSIONES            CCODPLA
   FONPENSIONES             CCODFON
   GESTORAS                 CCODGES
   ASEGURADORAS             CCODASEG
   GESCARTAS                SGESCARTA
   DEVBANPRESENTADORES      SDEVOLU
   DEVBANORDENANTES         SDEVOLU|NNUMNIF|TSUFIJO|FREMESA
   DEVBANRECIBOS            SDEVOLU|NNUMNIF|TSUFIJO|FREMESA|CREFERE|NRECIBO
   COMISIONVIG_AGENTES      CAGENTE|CCOMISI|FINIVIG
   AGENTES_COMP             CAGENTE
   REPRESENTANTES           SPERSON
   EMPLEADOS                SPERSON
   PRODUCTOS_EMPLEADOS      SPERSON|SPRODUC|CAGEADN|CAGEINT
   TIPO_EMPLEADOS           SPERSON|CSEGMENTO
   GARANDETCAP              SSEGURO|NRIESGO|CGARANT|NMOVIMI|NORDEN
   **************************************************************************/

   -- ini BUG 0017015 - 31-01-2011 - JMF
   -- Creo paràmetres especifics per algunes codificacions de la migració.
   --
   -- select * from mig_codigos_emp where ccodigo like 'PARAM%'
   --
   -- fin BUG 0017015 - 31-01-2011 - JMF

   -- ini Bug 0011578 - JMF - 05-11-2009
   k_tipo_carga   VARCHAR2(10);

-- INI RLLF 18/06/2015 BUG-34959 Cambios problemas con Conmutación Pensional por no grabar en SEGUROSCOL
    -- Nueva funcion en pac_mig_axis
   -- BUG 0022839 - FAL - 24/07/2012
   FUNCTION f_act_seguroscol(psseguro IN NUMBER, mens OUT VARCHAR2)
      RETURN NUMBER IS
      vcrespue4084   pregunpolseg.crespue%TYPE;
      vcrespue4790   pregunpolseg.crespue%TYPE;
      vcrespue4794   pregunpolseg.crespue%TYPE;
      vcrespue4078   pregunpolseg.crespue%TYPE;
      vcrespue4792   pregunpolseg.trespue%TYPE;   -- BUG 0023640/0124171 - FAL - 21/09/2012
      vcrespue4793   pregunpolseg.trespue%TYPE;   -- BUG 0023640/0124171 - FAL - 21/09/2012
      vcrespue4092   pregunpolseg.crespue%TYPE;
      vcrespue4791   pregunpolseg.crespue%TYPE;
      vcrespue535    pregunpolseg.crespue%TYPE;
      -- 23074 - I - JLB - 30/07/2012
      vcrespue4093   pregunpolseg.crespue%TYPE;
      vcrespue4094   pregunpolseg.crespue%TYPE;
      vcrespue4095   pregunpolseg.crespue%TYPE;
      -- 23074 - F - JLB - 30/07/2012
      num_err        NUMBER;
   BEGIN
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4084, 'POL', vcrespue4084);   -- tipo cobro
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4790, 'POL', vcrespue4790);   -- tipo vigencia
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4794, 'POL', vcrespue4794);   -- Agrupa recibos?
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4078, 'POL', vcrespue4078);
      -- modalidad (contributiva/no)
      num_err := pac_preguntas.f_get_pregunpolseg_t(psseguro, 4792, 'POL', vcrespue4792);   -- fecha corte -- BUG 0023640/0124171 - FAL - 21/09/2012
      num_err := pac_preguntas.f_get_pregunpolseg_t(psseguro, 4793, 'POL', vcrespue4793);   -- fecha facturación -- BUG 0023640/0124171 - FAL - 21/09/2012
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4092, 'POL', vcrespue4092);   -- tipo colectivo
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4791, 'POL', vcrespue4791);
      -- Cobro a Prorrata o periodos exactos
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 535, 'POL', vcrespue535);
      -- Recibos por Tomador, Asegurado
      -- 23074 - I - JLB - 30/07/2012
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4093, 'POL', vcrespue4093);
      -- Aplica gastos de expedición
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4094, 'POL', vcrespue4094);
      -- Periodicidad de los gastos
      num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4095, 'POL', vcrespue4095);

      -- Importe de los gastos

      -- 23074 - F
      BEGIN
         INSERT INTO seguroscol
                     (sseguro, ctipcol, ctipcob, ctipvig, recpor,
                      cagrupa, prorrexa, cmodalid,
                      fcorte,
                      ffactura,   -- 23074 - I - JLB
                      cagastexp, cperiogast, iimporgast)   -- 23074 - F - JLB
              VALUES (psseguro, vcrespue4092, vcrespue4084, vcrespue4790, vcrespue535,
                      vcrespue4794, vcrespue4791, vcrespue4078,
                      TO_DATE(vcrespue4792, 'dd/mm/yyyy'),   -- BUG 0023640/0124171 - FAL - 21/09/2012
                      TO_DATE
                         (vcrespue4793, 'dd/mm/yyyy')   -- 23074 - I - JLB -- BUG 0023640/0124171 - FAL - 21/09/2012
                                                     ,
                      vcrespue4093, vcrespue4094, vcrespue4095);   -- 23074 - F
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE seguroscol
               SET ctipcol = vcrespue4092,
                   ctipcob = vcrespue4084,
                   ctipvig = vcrespue4790,
                   recpor = vcrespue535,
                   cagrupa = vcrespue4794,
                   prorrexa = vcrespue4791,
                   cmodalid = vcrespue4078,
                   fcorte = TO_DATE(vcrespue4792, 'dd/mm/yyyy'),   -- BUG 0023640/0124171 - FAL - 21/09/2012
                   ffactura =
                      TO_DATE
                         (vcrespue4793, 'dd/mm/yyyy')   -- 23074 - I - JLB -- BUG 0023640/0124171 - FAL - 21/09/2012
                                                     ,
                   cagastexp = vcrespue4093,
                   cperiogast = vcrespue4094,
                   iimporgast = vcrespue4095
             -- 23074 - F
            WHERE  sseguro = psseguro;
         WHEN OTHERS THEN
            mens := SQLERRM;
            p_tab_error(f_sysdate, f_user, 'PAC_MIG_AXIS', 1, ' f_act_seguroscol', mens);
            RETURN 1;
      END;

      RETURN 0;
   END f_act_seguroscol;

-- FIN RLLF 18/06/2015 BUG-34959 Cambios problemas con Conmutación Pensional por no grabar en SEGUROSCOL

   /***************************************************************************
      FUNCTION f_ins_mig_logs_axis
      Función para insertar registros en la tabla de Errores y Warnings del
      proceso de migración entre las tablas MIG y AXIS
         param in  pncarga:  Número de carga
         param in  pmig_pk:  valor primary key de la tabla MIG
         param in  ptipo:    Tipo Traza (E-Error,W-Warning,I-Informativo)
         param in  ptexto:   Texto de la traza
         return:             Código error
   ***************************************************************************/
   FUNCTION f_ins_mig_logs_axis(
      pncarga IN NUMBER,
      pmig_pk IN VARCHAR2,
      ptipo IN VARCHAR2,
      ptexto IN VARCHAR2)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_seq          NUMBER;
   BEGIN
      SELECT sseqlogmig2.NEXTVAL
        INTO v_seq
        FROM DUAL;

      INSERT INTO mig_logs_axis
                  (ncarga, seqlog, fecha, mig_pk, tipo, incid)
           VALUES (pncarga, v_seq, f_sysdate, pmig_pk, ptipo, ptexto);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_ins_mig_logs_axis;

   /***************************************************************************
       FUNCTION f_lanza_post
       Función que realiza las acciones post definidas en la tabla MIG_POST
          param in ptabla:    Tablas origen 'EST', 'POL'.
          param in out psseguro:  Seguro de las tablas origen. Salida, sseguro en la tabla definitiva
          param in psproduc:  Producto de la poliza
          param in pfefecto:  Fecha de efecto del movimiento
          param in pnmovimi   Numero de movimiento
          param out pmens
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_lanza_post(
      pncarga IN NUMBER,
      ptabla IN VARCHAR2,
      psseguro IN OUT seguros.sseguro%TYPE,
      psproduc productos.sproduc%TYPE,
      pfefecto DATE,
      pnmovimi IN NUMBER,
      pmens IN OUT VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'GENERAL',
      pcactivi IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      v_post         mig_post%ROWTYPE;
      nerror         NUMBER := 0;
      vprimatotal    NUMBER;
      e_error        EXCEPTION;
      vpasexec       VARCHAR2(10);
      vsolicit       estseguros.sseguro%TYPE;
      onpoliza       NUMBER;
      onmovimi       NUMBER;
      mensajes       t_iax_mensajes;
      vt_obj         t_iax_impresion := t_iax_impresion();
      v_resp         pregunseg.crespue%TYPE;
      vcidioma       idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma;
      vaccion        NUMBER(2);
      vcreteni       seguros.creteni%TYPE := 0;
      vtipo          NUMBER(3);
      vcampo         VARCHAR2(30);
      v_sseguro0     seguros.sseguro%TYPE;
      vcgarant       garangen.cgarant%TYPE;
      v_numgaranpro  NUMBER(4);
      v_numgarancont NUMBER(4);
      vctipcoa       seguros.ctipcoa%TYPE;
      vctipcom       seguros.ctipcom%TYPE;
      v_hctipcom     NUMBER;
      vresultat      NUMBER;
      v_res          NUMBER;
      -- 28263 / 160578 - FPG - 5-12-2013 - inicio
      v_cempres      NUMBER;
      v_nnumcasop    casos_bpm.nnumcasop%TYPE;
      v_nnumcaso     casos_bpm.nnumcaso%TYPE;
      v_ctipidebpm   per_personas.ctipide%TYPE;
      v_nnumidebpm   per_personas.nnumide%TYPE;
      v_cont_docsbpm NUMBER;
      v_tratar_docrequerida NUMBER;
      v_cactivi      NUMBER;
      vt_docreq      t_iax_docrequerida := t_iax_docrequerida();
      -- Herencia clausulas
      v_nordcla      clausuesp.nordcla%TYPE;
      v_hcclausu     prodherencia_colect.cclausu%TYPE;
      v_cocoretaje   prodherencia_colect.ccorret%TYPE;
      v_cretorno     prodherencia_colect.cretorno%TYPE;
      v_ccoaseguro   prodherencia_colect.ccoa%TYPE;
      v_crecfra      prodherencia_colect.recfra%TYPE;
      v_crecfra0     seguros.crecfra%TYPE;
      -- 28263 / 160578 - FPG - 5-12-2013 - final
      --
      v_isaltacol    NUMBER(1);
      v_nmovimi_cero NUMBER;   --BUG 27924/151061 - RCL - 21/03/2014
      v_ncuacoa      NUMBER;   --BUG 27924/151061 - RCL - 21/03/2014
   BEGIN
      vpasexec := 1;
      vsolicit := psseguro;

      BEGIN
         SELECT *
           INTO v_post
           FROM mig_post
          WHERE sproduc = psproduc
            AND NVL(cmodo, 'GENERAL') = pmodo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;   -- si no hay validaciones salgo ok.
      END;

      --   if ptabla <> 'EST' then --si estamos tablas POL o MIG miramos el flag de acciones masivas post mig
      IF v_post.caccposmig = 1 THEN
         nerror := f_trata_preguntas_migracion(psseguro, ptabla);

         IF nerror <> 0 THEN
            nerror := 1000001;
            pmens := f_axis_literales(nerror, f_idiomauser);
            RAISE e_error;
         END IF;
      END IF;

      --     end if;
      IF pac_iax_produccion.isaltacol THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      --
      -- Estas son validaciones obligatorias y herencias obligatorias , ya lo tengo en las est
      IF ptabla = 'EST' THEN
         pk_nueva_produccion.p_define_modo('EST');   -- para validaciones
         vpasexec := 2;

         IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', psproduc) = 1
            AND NOT pac_iax_produccion.isaltacol THEN
            SELECT sseguro, ctipcoa, ctipcom, crecfra
              INTO v_sseguro0, vctipcoa, vctipcom, v_crecfra0
              FROM seguros
             WHERE npoliza = (SELECT npoliza
                                FROM estseguros
                               WHERE sseguro = psseguro)
               AND ncertif = 0;
         END IF;

         nerror := pk_nueva_produccion.f_valida_datosgestion(psseguro, psproduc, vtipo, vcampo,
                                                             'ALTA_POLIZA');

         IF nerror <> 0 THEN
            pmens := f_axis_literales(nerror, f_idiomauser) || '- Campo: ' || vcampo;
            RAISE e_error;
         END IF;

         -- FOR reg IN (SELECT sperson, nriesgo, cdomici
         --               FROM estassegurats estase
         --              WHERE estase.sseguro = psseguro) LOOP
         FOR reg IN (SELECT ep.spereal spereal, estase.sperson sperson, estase.nriesgo nriesgo,
                            estase.cdomici cdomici, e.ssegpol ssegpol, e.sproduc sproduc
                       FROM estassegurats estase, estper_personas ep, estseguros e
                      WHERE estase.sseguro = psseguro
                        AND estase.sperson = ep.sperson
                        --    AND estase.sseguro = ep.sseguro
                        AND estase.sseguro = e.sseguro) LOOP
            nerror := pk_nueva_produccion.f_valida_estriesgo(psseguro, reg.sperson, psproduc,
                                                             reg.cdomici);
            vpasexec := 3;

            IF nerror <> 0 THEN
               --nerror := 105419;
               pmens := f_axis_literales(nerror, f_idiomauser);
               RAISE e_error;
            END IF;
         /*   nerror := pac_md_validaciones.f_valida_producto_unico(reg.sproduc, reg.spereal,
                                                                  reg.ssegpol, NULL, NULL,
                                                                  NULL, mensajes);

            IF nerror <> 0 THEN
               IF mensajes IS NOT NULL THEN
                  FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                     nerror := mensajes(i).cerror;
                     pmens := mensajes(i).terror;
                     RAISE e_error;
                  END LOOP;
               END IF;
            END IF;
         */
         END LOOP;

         --
         -- la funcion anterior estriesgo me calcula la variable isaltacol
         --
         -- Tengo en cuenta si heredo co-corretaje  y retorno
         vpasexec := 5;

         IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', psproduc) = 1
            AND NOT pac_iax_produccion.isaltacol
            AND pnmovimi = 1 THEN
            v_nmovimi_cero := pac_seguros.f_get_movimi_cero_fecha(v_sseguro0, pfefecto);
            nerror := pac_productos.f_get_herencia_col(psproduc, 8, v_cocoretaje);

            IF NVL(v_cocoretaje, 0) = 1
               AND nerror = 0 THEN
               INSERT INTO estage_corretaje
                           (sseguro, cagente, nmovimi, nordage, pcomisi, ppartici, islider)
                  SELECT psseguro, cagente, pnmovimi, nordage, pcomisi, ppartici, islider
                    FROM age_corretaje
                   WHERE sseguro = v_sseguro0
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM age_corretaje
                                     WHERE sseguro = v_sseguro0);
            END IF;   -- cocorretaje

            -- miro retorno
            nerror := pac_productos.f_get_herencia_col(psproduc, 10, v_cretorno);

            IF NVL(v_cretorno, 0) = 1
               AND nerror = 0 THEN
               INSERT INTO estrtn_convenio
                           (sseguro, sperson, nmovimi, pretorno, idconvenio)
                  SELECT psseguro, sperson, pnmovimi, pretorno, idconvenio
                    FROM rtn_convenio
                   WHERE sseguro = v_sseguro0
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM rtn_convenio
                                     WHERE sseguro = v_sseguro0);
            END IF;   -- retorno

            -- miro coaseguro
            nerror := pac_productos.f_get_herencia_col(psproduc, 14, v_ccoaseguro);

            IF NVL(v_ccoaseguro, 0) = 1
               AND nerror = 0 THEN
               BEGIN
                  SELECT ncuacoa
                    INTO v_ncuacoa
                    FROM historicoseguros
                   WHERE sseguro = v_sseguro0
                     AND nmovimi = (SELECT MAX(a2.nmovimi)
                                      FROM historicoseguros a2
                                     WHERE a2.sseguro = v_sseguro0
                                       AND a2.nmovimi <= v_nmovimi_cero);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT ncuacoa
                       INTO v_ncuacoa
                       FROM seguros
                      WHERE sseguro = v_sseguro0;
               END;

               INSERT INTO estcoacuadro
                           (sseguro, ncuacoa, finicoa, ffincoa, ploccoa, fcuacoa, ccompan,
                            npoliza)
                  SELECT psseguro, ncuacoa, finicoa, ffincoa, ploccoa, fcuacoa, ccompan,
                         npoliza
                    FROM coacuadro
                   WHERE sseguro = v_sseguro0
                     AND ncuacoa = v_ncuacoa;

               --
               IF SQL%ROWCOUNT > 0 THEN   -- si hemos insertado algun registro
                  UPDATE estseguros
                     SET ctipcoa = vctipcoa,
                         ncuacoa = v_ncuacoa
                   WHERE sseguro = psseguro;
               END IF;

               -- de estos puede no haber
               INSERT INTO estcoacedido
                           (sseguro, ncuacoa, ccompan, pcescoa, pcomcoa, pcomcon, pcomgas,
                            pcesion)
                  SELECT psseguro, ncuacoa, ccompan, pcescoa, pcomcoa, pcomcon, pcomgas,
                         pcesion
                    FROM coacedido
                   WHERE sseguro = v_sseguro0
                     AND ncuacoa = v_ncuacoa;
            --
            END IF;   -- coaseguro

            -- heredo recargo fraccionamiento
            nerror := pac_productos.f_get_herencia_col(psproduc, 3, v_crecfra);

            IF NVL(v_crecfra, 0) = 1
               AND nerror = 0 THEN
               UPDATE estseguros
                  SET crecfra = v_crecfra0
                WHERE sseguro = psseguro;
            END IF;

            --INICIO BUG26955
            nerror := pac_productos.f_get_herencia_col(psproduc, 13, v_hctipcom);

            IF NVL(v_hctipcom, 0) = 1
               AND nerror = 0 THEN
               UPDATE estseguros
                  SET ctipcom = vctipcom
                WHERE sseguro = psseguro;

               IF vctipcom IN(90, 92) THEN   -- heredamos la comisión
                  -- Bug 30642/169851 - 20/03/2014 - AMC
                  INSERT INTO estcomisionsegu
                              (sseguro, cmodcom, pcomisi, ninialt, nfinalt, nmovimi)
                     SELECT psseguro, cmodcom, pcomisi, ninialt, nfinalt, pnmovimi
                       FROM comisionsegu
                      WHERE sseguro = v_sseguro0
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM comisionsegu
                                        WHERE sseguro = v_sseguro0);
               -- Fi Bug 30642/169851 - 20/03/2014 - AMC
               END IF;
            END IF;

            --FIN BUG26955

            -- Heredo las clausulas ssegun configuracion
            nerror := pac_productos.f_get_herencia_col(psproduc, 4, v_hcclausu);

            IF NVL(v_hcclausu, 0) <> 0 THEN
               IF NVL(v_hcclausu, 0) IN(2, 3) THEN
                  -- aqui cojo las clausulas especificas que tengan riesgo 0
                  SELECT COUNT('x')
                    INTO v_nordcla
                    FROM estclausuesp
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND nriesgo = 0;

                  INSERT INTO estclausuesp
                              (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen,
                               tclaesp, ffinclau)
                     SELECT pnmovimi, psseguro, cclaesp, nordcla + v_nordcla, 0, pfefecto,
                            sclagen, tclaesp, ffinclau
                       FROM clausuesp
                      WHERE sseguro = v_sseguro0
                        AND nriesgo = 0
                        AND finiclau <= pfefecto
                        AND((ffinclau > pfefecto
                             AND ffinclau IS NOT NULL)
                            OR(ffinclau IS NULL));
               END IF;

               nerror := pac_preguntas.f_get_pregunpolseg(psseguro, 4089, 'EST', v_resp);

               FOR reg IN (SELECT nriesgo
                             FROM estriesgos
                            WHERE sseguro = psseguro) LOOP
                  --
                  IF NVL(v_hcclausu, 0) IN(2, 3) THEN
                     SELECT COUNT('x')
                       INTO v_nordcla
                       FROM estclausuesp
                      WHERE sseguro = psseguro
                        AND nmovimi = pnmovimi
                        AND nriesgo = reg.nriesgo;

                     -- aqui cojo las clausulas especificas que tengan riesgo 0
                     INSERT INTO estclausuesp
                                 (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau,
                                  sclagen, tclaesp, ffinclau)
                        SELECT pnmovimi, psseguro, cclaesp, nordcla + v_nordcla, reg.nriesgo,
                               pfefecto, sclagen, tclaesp, ffinclau
                          FROM clausuesp
                         WHERE sseguro = v_sseguro0
                           AND(nriesgo = NVL(v_resp, 1))
                           AND finiclau <= pfefecto
                           AND((ffinclau > pfefecto
                                AND ffinclau IS NOT NULL)
                               OR(ffinclau IS NULL));
                  END IF;

                  IF NVL(v_hcclausu, 0) IN(1, 2) THEN
                       -- aqui cojo las clausulas especificas que tengan riesgo 0
                     /*  INSERT INTO estclaubenseg
                                   (nmovimi, sclaben, sseguro, nriesgo, finiclau, ffinclau,
                                    cobliga)
                          SELECT pnmovimi, sclaben, psseguro, reg.nriesgo, pfefecto, ffinclau,
                                 1
                            FROM claubenseg
                           WHERE sseguro = v_sseguro0
                             AND nriesgo = NVL(v_resp, 1)
                             AND finiclau <= pfefecto
                             AND((ffinclau > pfefecto
                                  AND ffinclau IS NOT NULL)
                                 OR(ffinclau IS NULL));*/
                     FOR reg_clau IN (SELECT sclaben, ffinclau
                                        FROM claubenseg
                                       WHERE sseguro = v_sseguro0
                                         AND nriesgo = NVL(v_resp, 1)
                                         AND finiclau <= pfefecto
                                         AND((ffinclau > pfefecto
                                              AND ffinclau IS NOT NULL)
                                             OR(ffinclau IS NULL))) LOOP
                        BEGIN
                           INSERT INTO estclaubenseg
                                       (nmovimi, sclaben, sseguro, nriesgo,
                                        finiclau, ffinclau, cobliga)
                                VALUES (pnmovimi, reg_clau.sclaben, psseguro, reg.nriesgo,
                                        pfefecto, reg_clau.ffinclau, 1);
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              NULL;   -- puede ser que haya llegado por carga
                        END;
                     END LOOP;
                  END IF;
               --
               END LOOP;
            END IF;   -- herencia de clausula
         --
         END IF;

         ---
         IF v_post.cvalidacion = 1 THEN
            vpasexec := 10;
            --pasamos las validaciones del producto para el seguro
            nerror := f_mig_validacion(psseguro, ptabla, psproduc, pmens);

            IF nerror <> 0 THEN
               -- pmens := f_axis_literales(9906626, f_idiomauser) || '-'
               --          || pmens;
               pmens := f_axis_literales(nerror, f_idiomauser) || '-' || pmens;
               RAISE e_error;
            END IF;
         END IF;

         IF v_post.cpregautoma = 1 THEN
            vpasexec := 20;

            -- Calculo preguntas a nivel de póliza
            FOR reg_pregunt IN (SELECT   p.npreord, p.cpregun, p.cpretip, p.tprefor,
                                         1 nmovima, pfefecto fefecto, pc.ctippre,
                                         seg.npoliza npoliza, esccero, cresdef
                                    FROM pregunpro p, codipregun pc, estseguros seg
                                   WHERE p.sproduc = seg.sproduc
                                     --  AND p.cactivi = seg.cactivi
                                     AND seg.sseguro = vsolicit
                                     AND pc.cpregun = p.cpregun
                                     --AND   p.cpretip IN(2, 3)
                                     AND((v_isaltacol = 0
                                          AND p.cpretip IN(2, 3))   --certificado
                                         OR
--                                         ( v_isaltacol = 1 AND   p.cpretip IN(2, 3) and p.esccero = 0) --caratula 0
                                         (  v_isaltacol = 1
                                            AND p.visiblecol = 1
                                            AND(p.cpretip IN(2, 3)
                                                OR(p.cpretip = 1
                                                   AND p.esccero = 1)))   --caratula 0
                                                                       )
                                     AND p.cnivel = 'P'
                                ORDER BY npreord) LOOP
               vpasexec := 25;
               v_resp := NULL;

               IF NVL(f_parproductos_v(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                  AND reg_pregunt.esccero = 1 THEN
                  nerror := pac_albsgt.f_tprefor(reg_pregunt.tprefor, ptabla, vsolicit, NULL,   -- pnriesgo,
                                                 reg_pregunt.fefecto, pnmovimi, 0, v_resp, 1,
                                                 1, 0, reg_pregunt.npoliza);
               ELSE
                  nerror := pac_albsgt.f_tprefor(reg_pregunt.tprefor, ptabla, vsolicit, NULL,   -- pnriesgo,
                                                 reg_pregunt.fefecto, pnmovimi, 0, v_resp, 1,
                                                 1, 0);
               END IF;

               IF v_resp IS NULL   --and reg_pregunt.cpretip = 3
                                THEN
                  v_resp := reg_pregunt.cresdef;
               END IF;

               IF v_resp IS NOT NULL THEN
                  BEGIN
                     --pfiniefe X pfefecto.Adso
                     INSERT INTO estpregunpolseg   -- no updateo
                                 (sseguro, cpregun,
                                  crespue,
                                  nmovimi,
                                  trespue)
                          VALUES (psseguro, reg_pregunt.cpregun,
                                  DECODE(reg_pregunt.ctippre, 4, NULL, 5, NULL, v_resp),
                                  pnmovimi,
                                  DECODE(reg_pregunt.ctippre, 4, v_resp, 5, v_resp, NULL));
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN   -- si ya existe no la updateo
                        NULL;
                  END;
               END IF;
            END LOOP;

-- Calculo las preguntas a nivel de riesgo
            vpasexec := 30;

            FOR reg_pregunt IN (SELECT   p.npreord, p.cpregun, p.cpretip, p.tprefor, 1 nmovima,
                                         pfefecto fefecto, pc.ctippre, r.nriesgo,
                                         seg.npoliza npoliza, esccero, p.cresdef
                                    FROM pregunpro p, codipregun pc, estseguros seg,
                                         estriesgos r
                                   WHERE p.sproduc = seg.sproduc
                                     --  AND p.cactivi = seg.cactivi
                                     AND seg.sseguro = vsolicit
                                     AND r.sseguro = seg.sseguro
                                     AND r.fanulac IS NULL
                                     AND pc.cpregun = p.cpregun
                                     --      AND p.cpretip IN(2, 3)   -- automaticas i semiautomaticas
                                     AND((v_isaltacol = 0
                                          AND p.cpretip IN(2, 3))   --certificado
                                         OR
--                                         ( v_isaltacol = 1 AND   p.cpretip IN(2, 3) and p.esccero = 0) --caratula 0
                                         (  v_isaltacol = 1
                                            AND p.visiblecol = 1
                                            AND(p.cpretip IN(2, 3)
                                                OR(p.cpretip = 1
                                                   AND p.esccero = 1)))   --caratula 0
                                                                       )
                                     AND p.cnivel = 'R'
                                ORDER BY npreord) LOOP
               vpasexec := 31;
               v_resp := NULL;
               nerror := pac_albsgt.f_tprefor(reg_pregunt.tprefor, ptabla, vsolicit,
                                              reg_pregunt.nriesgo,   -- pnriesgo,
                                              reg_pregunt.fefecto, pnmovimi, 0, v_resp, 1, 1,
                                              0);

               IF v_resp IS NULL   --and reg_pregunt.cpretip = 3
                                THEN
                  v_resp := reg_pregunt.cresdef;
               END IF;

               IF v_resp IS NOT NULL THEN
                  BEGIN
                     --pfiniefe X pfefecto.Adso
                     INSERT INTO estpregunseg   -- no updateo
                                 (sseguro, nriesgo, cpregun,
                                  crespue,
                                  nmovimi,
                                  trespue)
                          VALUES (psseguro, reg_pregunt.nriesgo, reg_pregunt.cpregun,
                                  DECODE(reg_pregunt.ctippre, 4, NULL, 5, NULL, v_resp),
                                  pnmovimi,
                                  DECODE(reg_pregunt.ctippre, 4, v_resp, 5, v_resp, NULL));
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
               END IF;
            END LOOP;

-- Calculo preguntas a nivel de garantia
            vpasexec := 40;

            FOR reg_garant IN (SELECT   p.cgarant, p.npreord, p.cpregun, p.cpretip, p.tprefor,

                                        --1 nmovima,
                                        g.nmovima nmovima, pfefecto fefecto, pc.ctippre,
                                        g.nriesgo, g.nmovimi, g.finiefe, seg.npoliza npoliza,
                                        p.cresdef, esccero
                                   FROM pregunprogaran p, codipregun pc, estseguros seg,
                                        estgaranseg g, garanpro gp
                                  WHERE p.sproduc = seg.sproduc
                                    AND p.cactivi = seg.cactivi
                                    AND p.cgarant = g.cgarant
                                    AND gp.cmodali = seg.cmodali
                                    AND gp.ccolect = seg.ccolect
                                    AND gp.ctipseg = seg.ctipseg
                                    AND gp.cgarant = g.cgarant
                                    AND gp.cactivi = seg.cactivi
                                    AND gp.cramo = seg.cramo
                                    AND seg.sseguro = vsolicit
                                    AND g.sseguro = seg.sseguro
                                    AND g.nmovimi = pnmovimi
                                    AND g.cobliga = 1   --
                                    AND pc.cpregun = p.cpregun
                                    --AND p.cpretip IN(2, 3)   -- automaticas i semiautomaticas
                                    AND((v_isaltacol = 0
                                         AND p.cpretip IN(2, 3))   --certificado
                                        OR
                                          --  ( v_isaltacol = 1 AND   p.cpretip IN(2, 3) and p.esccero = 0) --caratula 0
                                        (  v_isaltacol = 1
                                           AND p.visiblecol = 1
                                           AND(p.cpretip IN(2, 3)
                                               OR(p.cpretip = 1
                                                  AND p.esccero = 1)))   --caratula 0
                                                                      )
                               ORDER BY gp.norden, npreord) LOOP
               --
               vpasexec := 41;
               v_resp := NULL;
               nerror := pac_albsgt.f_tprefor(reg_garant.tprefor, ptabla, vsolicit,
                                              reg_garant.nriesgo,   -- pnriesgo,
                                              reg_garant.fefecto, pnmovimi,
                                              reg_garant.cgarant, v_resp, 1, 1, 0);

               IF v_resp IS NULL   --and reg_garant.cpretip = 3
                                THEN
                  v_resp := reg_garant.cresdef;
               END IF;

               IF v_resp IS NOT NULL THEN
                  --
                  BEGIN
                     INSERT INTO estpregungaranseg
                                 (sseguro, nriesgo, cgarant,
                                  nmovimi, cpregun,
                                  crespue,
                                  finiefe,
                                  trespue,
                                  nmovima)
                          VALUES (psseguro, reg_garant.nriesgo, reg_garant.cgarant,
                                  reg_garant.nmovimi, reg_garant.cpregun,
                                  DECODE(reg_garant.ctippre, 4, NULL, 5, NULL, v_resp),
                                  reg_garant.finiefe,
                                  DECODE(reg_garant.ctippre, 4, v_resp, 5, v_resp, NULL),
                                  reg_garant.nmovima);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
               END IF;
            END LOOP;

            vpasexec := 42;

            -- Comprobamos para cada movimiento si la garantía existe para la póliza migrada
            FOR reg_movimientos IN (SELECT DISTINCT nmovimi, finiefe, ffinefe, nriesgo
                                               FROM estgaranseg
                                              WHERE sseguro = psseguro
                                                AND cobliga = 1
                                                AND nmovimi = pnmovimi) LOOP
               -- calulo las garantias de tipo 8, y relleno el resto para validaciones
                   -- Obtenemos las garantías obligatorias del producto de la póliza
               FOR reg_garantias IN (SELECT   cgarant, norden, ctipgar
                                         FROM garanpro gp
                                        WHERE sproduc = psproduc
                                           -- AND ctipgar = 8
                                          --  and cactivi = 0
                                          AND NOT EXISTS(
                                                SELECT 1
                                                  FROM estgaranseg eg
                                                 WHERE eg.sseguro = psseguro
                                                   AND eg.nriesgo = reg_movimientos.nriesgo
                                                   AND eg.cgarant = gp.cgarant
                                                   AND eg.nmovimi = reg_movimientos.nmovimi)
                                     ORDER BY norden) LOOP
                  /*    SELECT COUNT(cgarant)
                        INTO v_res
                        FROM estgaranseg
                       WHERE sseguro = psseguro
                         AND nriesgo = reg_movimientos.nriesgo
                         AND cgarant = reg_garantias.cgarant
                         AND nmovimi = reg_movimientos.nmovimi
                         AND cobliga = 1;
                   */

                  --       IF v_res = 0 THEN-- La garantía no existe en la póliza para el movimiento-- Creamos el registro en garanseg para la póliza con los valores a cero para la garantía y movimiento
                  BEGIN
                     INSERT INTO estgaranseg
                                 (cgarant, nriesgo,
                                  nmovimi, sseguro, finiefe,
                                  norden, crevali, ctarifa, icapital, precarg, iextrap,
                                  iprianu, ffinefe, cformul, ctipfra, ifranqu, irecarg,
                                  ipritar, pdtocom, idtocom, prevali, irevali, itarifa,
                                  itarrea, ipritot, icaptot, pdtoint, idtoint, ftarifa,
                                  feprev, fpprev, percre, crevalcar, cmatch, tdesmat,
                                  pintfin, cref, cintref, pdif, pinttec, nparben, nbns,
                                  tmgaran, cderreg, ccampanya, nversio, nmovima, cageven,
                                  nfactor, nlinea, cmotmov, finider, falta, cfranq, nfraver,
                                  ngrpfra, ngrpgara, pdtofra, ctarman, nordfra, itotanu,
                                  pdtotec, preccom, idtotec, ireccom, icaprecomend, cobliga)
                          VALUES (reg_garantias.cgarant, reg_movimientos.nriesgo,
                                  reg_movimientos.nmovimi, psseguro, reg_movimientos.finiefe,
                                  reg_garantias.norden, 0, NULL, 0, 0, 0,
                                  0, reg_movimientos.ffinefe, NULL, NULL, 0, 0,
                                  0, 0, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0, NULL,
                                  NULL, NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, 1, NULL,
                                  NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, 0, NULL, 0,
                                  0, 0, 0, 0, 0, DECODE(reg_garantias.ctipgar, 8, 1, 0));   --si tipo 8 la marcho, sino como opcional.
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
               --END IF;
               END LOOP;
            END LOOP;
         END IF;

         vpasexec := 43;

         IF v_post.cvalgaran = 1 THEN
            -- JLB - validación de preguntas
            -- valido preguntas obligatorias a nivel de póliza
            FOR reg_pregunt IN (SELECT   tvalfor, crespue, trespue, s.cactivi cactivi,
                                         estpreg.nmovimi nmovimi
                                    FROM pregunpro p, estpregunpolseg estpreg, estseguros s
                                   WHERE p.sproduc = s.sproduc
                                     --  AND p.cactivi = seg.cactivi
                                     AND s.sseguro = psseguro
                                     AND estpreg.sseguro = s.sseguro
                                     AND estpreg.cpregun = p.cpregun
                                     AND cnivel = 'P'
                                     AND p.tvalfor IS NOT NULL
                                     AND p.cpretip <> 2   -- las automaticas no las valido
                                ORDER BY npreord) LOOP
               IF reg_pregunt.trespue IS NOT NULL
                  OR reg_pregunt.crespue IS NOT NULL THEN
                  --BUG 5388 - 25/05/2009 - JRB - No se ha de tener en cuenta el tipo de pregunta sino si realmente está informada la respuesta
                  --AND prgpar(vprg).cpretip IN(1, 3) THEN
                  nerror := pac_albsgt.f_tvalfor(reg_pregunt.crespue, reg_pregunt.trespue,
                                                 reg_pregunt.tvalfor, ptabla,   -- BUG11091:DRA:21/09/2009
                                                 psseguro, reg_pregunt.cactivi, NULL,   --pnriesgo,
                                                 pfefecto, reg_pregunt.nmovimi, NULL,   --pcgarant,
                                                 vresultat, NULL);

                  IF nerror <> 0 THEN
                     --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, errnum);   --**
                     --RAISE e_object_error;
                      --nerror := 105419;
                     pmens := f_axis_literales(9001096, f_idiomauser) || ' - '
                              || f_axis_literales(nerror, f_idiomauser);
                     RAISE e_error;
                  END IF;

                  IF vresultat <> 0 THEN
                     nerror := vresultat;
                     pmens := f_axis_literales(vresultat, f_idiomauser);
                     RAISE e_error;
                  END IF;
               END IF;
            END LOOP;

            FOR reg IN (SELECT r.nriesgo, s.sproduc, s.cactivi, s.fefecto
                          FROM estriesgos r, estseguros s
                         WHERE r.sseguro = s.sseguro
                           AND r.fanulac IS NULL
                           AND s.sseguro = psseguro) LOOP
-- Una vez calculada las preguntas miro haber si hay alguna preguna obligatoria sin contestar a nivel de riesgo
               vpasexec := 44;
               nerror := pk_nueva_produccion.f_valida_estpregunseg(psseguro, reg.nriesgo,
                                                                   reg.sproduc, vtipo,   -- atipo
                                                                   pmens);

               IF nerror <> 0 THEN
                  --nerror := 105419;
                  pmens := f_axis_literales(9001096, f_idiomauser) || ' - '
                           || f_axis_literales(nerror, f_idiomauser) || ' Preg:' || pmens;
                  RAISE e_error;
               END IF;

               -- valido las garantias obligatorias
               vpasexec := 45;
               nerror := pk_nueva_produccion.f_validar_garantias_al_tarifar(psseguro,
                                                                            reg.nriesgo,
                                                                            pnmovimi,
                                                                            reg.sproduc,
                                                                            reg.cactivi, pmens);
               vpasexec := 47;

               IF nerror <> 0 THEN
                  pmens := f_axis_literales(nerror, f_idiomauser) || ' - ' || pmens;
                  RAISE e_error;
               END IF;

               FOR reg_prgpar IN (SELECT   tvalfor, crespue, trespue, s.cactivi cactivi,
                                           estpreg.nmovimi nmovimi
                                      FROM pregunpro p, estpregunseg estpreg, estseguros s
                                     WHERE p.sproduc = s.sproduc
                                       --  AND p.cactivi = seg.cactivi
                                       AND s.sseguro = psseguro
                                       AND estpreg.sseguro = s.sseguro
                                       AND estpreg.cpregun = p.cpregun
                                       AND cnivel = 'R'
                                       AND estpreg.nriesgo = reg.nriesgo
                                       AND p.tvalfor IS NOT NULL
                                       AND p.cpretip <>
                                                   2   -- las automaticas no las validoautomaticas
                                  ORDER BY npreord) LOOP
                  IF reg_prgpar.trespue IS NOT NULL
                     OR reg_prgpar.crespue IS NOT NULL THEN
                     nerror := pac_albsgt.f_tvalfor(reg_prgpar.crespue, reg_prgpar.trespue,
                                                    reg_prgpar.tvalfor, ptabla, psseguro,
                                                    reg_prgpar.cactivi, reg.nriesgo, pfefecto,
                                                    reg_prgpar.nmovimi, NULL, vresultat, NULL);

                     IF nerror <> 0 THEN
                        --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, errnum);   --**
                        --RAISE e_object_error;
                         --nerror := 105419;
                        pmens := f_axis_literales(nerror, f_idiomauser);
                        RAISE e_error;
                     END IF;

                     IF vresultat <> 0 THEN
                        nerror := vresultat;
                        pmens := f_axis_literales(vresultat, f_idiomauser);
                        RAISE e_error;
                     END IF;
                  END IF;
               END LOOP;

               -- para cada riesgo valido las preguntas de garantia
               FOR reg_prggar IN (SELECT   tvalfor, crespue, trespue, s.cactivi cactivi,
                                           estpreg.nmovimi nmovimi, estpreg.cgarant cgarant
                                      FROM pregunprogaran p, estpregungaranseg estpreg,
                                           estseguros s
                                     WHERE p.sproduc = s.sproduc
                                       --  AND p.cactivi = seg.cactivi
                                       AND estpreg.sseguro = s.sseguro
                                       AND s.sseguro = psseguro
                                       AND estpreg.cpregun = p.cpregun
                                       AND estpreg.nriesgo = reg.nriesgo
                                       AND p.tvalfor IS NOT NULL
                                       AND p.cpretip <>
                                                   2   -- las automaticas no las validoautomaticas
                                  ORDER BY npreord) LOOP
                  IF reg_prggar.trespue IS NOT NULL
                     OR reg_prggar.crespue IS NOT NULL THEN
                     nerror := pac_albsgt.f_tvalfor(reg_prggar.crespue, reg_prggar.trespue,
                                                    reg_prggar.tvalfor, ptabla, psseguro,
                                                    reg_prggar.cactivi, reg.nriesgo, pfefecto,
                                                    pnmovimi, reg_prggar.cgarant, vresultat,
                                                    NULL);

                     IF nerror <> 0 THEN
                        pmens := f_axis_literales(nerror, f_idiomauser);
                        RAISE e_error;
                     END IF;

                     IF vresultat <> 0 THEN
                        nerror := vresultat;
                        pmens := f_axis_literales(vresultat, f_idiomauser);
                        RAISE e_error;
                     END IF;
                  END IF;
               END LOOP;   -- fin de validación de preguntas garantias

               SELECT COUNT('x')
                 INTO v_numgaranpro
                 FROM garanpro
                WHERE ctipgar = 2
                  AND sproduc = reg.sproduc
                  AND cactivi = reg.cactivi;

               vpasexec := 48;

               IF v_numgaranpro = 0 THEN   -- si no hay garantias en el certificado busco en cert 0
                  SELECT COUNT('x')
                    INTO v_numgaranpro
                    FROM garanpro
                   WHERE ctipgar = 2
                     AND sproduc = reg.sproduc
                     AND cactivi = 0;
               END IF;

               vpasexec := 49;

               SELECT COUNT('x')
                 INTO v_numgarancont
                 FROM estgaranseg gar
                WHERE sseguro = psseguro
                  AND nriesgo = reg.nriesgo
                  AND nmovimi = pnmovimi
                  AND NVL(cobliga, 0) = 1
                  AND ctipgar = 2;

               IF v_numgaranpro <> v_numgarancont THEN
                  nerror := 9000639;
                  pmens := f_axis_literales(9000639, f_idiomauser) || ' - OBLIGATORIAS';
                  RAISE e_error;
               END IF;

               vpasexec := 491;

               -- Valido polizas en certidicado  si es un certificado administrado que tengas las garantias
               -- del certificado 0
               -- miro si es un colectivo que tiene que heredar garantias del certificado 0.
               IF NVL(f_parproductos_v(reg.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                  AND NVL(f_parproductos_v(reg.sproduc, 'HEREDA_GARANTIAS'), 0) IN(1, 3)
                  AND NOT pac_iax_produccion.isaltacol THEN
                  -- 4089
                  vpasexec := 492;
                  -- miro si hay pregunta de plan informado, para conocer el riesgo
                  nerror := pac_preguntas.f_get_pregunpolseg(psseguro, 4089, 'EST', v_resp);
                  vpasexec := 493;
                  --
                  vpasexec := 495;

                  BEGIN
                     SELECT cgarant
                       INTO vcgarant
                       FROM (SELECT cgarant
                               FROM estgaranseg
                              WHERE sseguro = psseguro
                                AND nriesgo = reg.nriesgo
                                AND ffinefe IS NULL
                                AND cobliga = 1
                             MINUS
                             SELECT cgarant
                               FROM garanseg
                              WHERE sseguro = v_sseguro0
                                AND nriesgo = NVL(v_resp, 1)
                                AND ffinefe IS NULL)
                      WHERE ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vcgarant := NULL;
                  END;

                  vpasexec := 4927;

                  IF vcgarant IS NOT NULL THEN
                     nerror := 9903535;
                     pmens := f_axis_literales(9903535, f_idiomauser) || '. ' || vcgarant
                              || ' - ' || ff_desgarantia(vcgarant, f_idiomauser);
                     RAISE e_error;
                  END IF;
               END IF;
            --  FIN COMPRUEBA COLECTIVO
            END LOOP;

            -- por ultimo compruebo las polizas a nivel de poliza(lo pongo aqui porque utiliza variables calculadas anteriormente)
            vpasexec := 29;
-- Una vez calculada las preguntas miro haber si hay alguna preguna obligatoria sin contestar
            nerror := pk_nueva_produccion.f_valida_pregun_poliza(psseguro, pnmovimi, psproduc,
                                                                 0,   -- actividad no se utiliza
                                                                 pmens);

            IF nerror <> 0 THEN
               --nerror := 105419;
               --pmens := f_axis_literales(nerror, f_idiomauser);
               RAISE e_error;
            END IF;
         END IF;

         IF v_post.ctarificar = 1 THEN
            vpasexec := 50;

            IF NOT pac_iax_produccion.isaltacol
               OR(pac_iax_produccion.isaltacol
                  AND NVL(pac_parametros.f_parproducto_n(psproduc, 'TARIFA_POLIZACERO'), 0) = 1) THEN
               FOR reg IN (SELECT r.nriesgo, s.sproduc, s.cactivi, s.fefecto
                             FROM estriesgos r, estseguros s
                            WHERE r.sseguro = s.sseguro
                              AND r.fanulac IS NULL
                              AND s.sseguro = psseguro) LOOP
                  vpasexec := 60;
                  nerror :=
                     pac_tarifas.f_tarifar_riesgo_tot
                                                  ('EST', psseguro, reg.nriesgo, pnmovimi,
                                                   pac_monedas.f_moneda_producto(reg.sproduc),
                                                   reg.fefecto);
                  vpasexec := 70;

                  IF nerror <> 0 THEN
                     pmens := f_axis_literales(nerror, f_idiomauser);
                     RAISE e_error;
                  END IF;

                  vpasexec := 75;
                  -- 13/11/2013 ok lanzo validaciones post tarificacion
                  nerror := pac_md_validaciones.f_validaposttarif(reg.sproduc, psseguro,
                                                                  reg.nriesgo, reg.fefecto,
                                                                  mensajes);

                  IF nerror <> 0 THEN
                     IF mensajes IS NOT NULL THEN
                        FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                           IF NVL(mensajes(i).cerror, 0) <> 0 THEN
                              nerror := mensajes(i).cerror;
                           ELSE
                              nerror := 9906626;
                           END IF;

                           pmens := mensajes(i).terror;
                           RAISE e_error;
                        END LOOP;
                     END IF;
                  END IF;
               END LOOP;
            END IF;   -- necesidad de tarificar
         END IF;

         -- 28263 / 160578 - FPG - 5-12-2013 - inicio
         v_tratar_docrequerida := 0;

         -- Comprobar si la carga tiene un caso BPM asociado y si la solicitud correspondiente
         -- al asegurado tiene documentos asociados.
         -- Si los tiene entonces ejecutaremos la función para calcular la documentacióin requerida.
         -- La función asocia también los documentos de la solcitud BPM al seguro en la tabla ESTDOCREQUERIDA.
         BEGIN
            SELECT nnumcasobpm
              INTO v_nnumcasop
              FROM int_carga_ctrl icc,
                   (SELECT SUBSTR(mig_pk, pos1 + 1, pos2 - pos1 - 1) AS sproces
                      FROM (SELECT INSTR(m.mig_pk, '/', 1, 1) AS pos1,
                                   INSTR(m.mig_pk, '/', 1, 2) AS pos2, m.*
                              FROM mig_seguros m
                             WHERE m.ncarga = pncarga)) a
             WHERE icc.sproces = a.sproces;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_nnumcasop := NULL;
         END;

         IF v_nnumcasop IS NOT NULL THEN
            SELECT p.ctipide, p.nnumide, s.cactivi, cempres
              INTO v_ctipidebpm, v_nnumidebpm, v_cactivi, v_cempres
              FROM esttomadores t, estper_personas p, estseguros s
             WHERE t.sseguro = psseguro
               AND t.sperson = p.sperson
               AND s.sseguro = t.sseguro;

            BEGIN
               SELECT nnumcaso
                 INTO v_nnumcaso
                 FROM casos_bpm
                WHERE cempres = v_cempres
                  AND nnumcasop = v_nnumcasop
                  AND ctipide = v_ctipidebpm
                  AND nnumide = v_nnumidebpm;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_nnumcaso := NULL;
            END;

            IF v_nnumcaso IS NOT NULL THEN
               SELECT COUNT(*)
                 INTO v_cont_docsbpm
                 FROM casos_bpm_doc
                WHERE cempres = v_cempres
                  AND nnumcaso = v_nnumcaso;

               IF v_cont_docsbpm > 0 THEN
                  v_tratar_docrequerida := 1;

                  INSERT INTO estcasos_bpmseg
                              (sseguro, cempres, nnumcaso, cactivo)
                       VALUES (psseguro, v_cempres, v_nnumcaso, 1);
               END IF;
            END IF;
         END IF;

         IF v_tratar_docrequerida = 1 THEN
            vt_docreq := pac_md_produccion.f_leedocrequerida(psproduc, psseguro, v_cactivi,
                                                             pnmovimi, f_idiomauser, mensajes);

            IF mensajes IS NOT NULL THEN
               FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                  nerror := mensajes(i).cerror;
                  pmens := mensajes(i).terror;
                  RAISE e_error;
               END LOOP;
            END IF;
         END IF;

         -- 28263 / 160578 - FPG - 5-12-2013 - Final
         IF v_post.cpsu = 1 THEN
            IF NVL(pac_parametros.f_parproducto_n(psproduc, 'PSU'), 0) = 1 THEN
               -- de momento solo admitimos modelo nuevo PSU
               -- 1 = Nova Producció
               -- 2 = Suplement
               -- 3 = Renovació
               IF pnmovimi = 1 THEN
                  vaccion := 1;   -- alta ...
               ELSE
                  vaccion := 2;
               END IF;

               nerror := pac_psu.f_inicia_psu('EST', vsolicit, vaccion, vcidioma, vcreteni);

               IF nerror != 0 THEN
                  vcreteni := 1;
               END IF;

               IF vcreteni <> 0 THEN
                  UPDATE estseguros
                     SET creteni = 2
                   WHERE sseguro = vsolicit;

                  -- Miro ahora si la tengo que rechazar
                  IF v_post.crechazopsu = 1 THEN
                     SELECT ssegpol
                       INTO psseguro
                       FROM estseguros
                      WHERE sseguro = vsolicit;

                     IF v_post.ctraspasar <> 2
                        AND pnmovimi = 1 THEN   -- sino esta traspasada la traspaso
                        pac_alctr126.traspaso_tablas_est(vsolicit, pfefecto, NULL, pmens,
                                                         'ALCTR126', NULL, pnmovimi, NULL);

                        IF pmens IS NOT NULL THEN
                           vpasexec := 130;
                           nerror := 105419;
                           RAISE e_error;
                        END IF;

                        v_post.ctraspasar := 2;   -- la marco como traspasada
                     END IF;

                     --
                     nerror :=
                        pac_iax_gestionpropuesta.f_rechazarpropuesta
                                      (psseguro, 1, '389', 0,
                                       'Rechazo propuesta automatica en proceso carga masiva.',
                                       NULL, NULL, mensajes);

                     IF nerror <> 0 THEN
                        IF mensajes IS NOT NULL THEN
                           FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                              nerror := mensajes(i).cerror;
                              pmens := mensajes(i).terror;
                              --RAISE e_error;
                              nerror := f_ins_mig_logs_axis(pncarga, 'PRINCIPAL', 'W',
                                                            'Aviso:' || nerror || '-' || pmens);
                              RETURN 0;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         -- A partir de aqui dejamos la poliza en
         IF v_post.ctraspasar = 1
            AND pnmovimi = 1 THEN   -- traspasamos la poliza de las est a las reales
            pac_alctr126.traspaso_tablas_est(vsolicit, pfefecto, NULL, pmens, 'ALCTR126',
                                             NULL, pnmovimi, NULL);

            IF pmens IS NOT NULL THEN
               vpasexec := 130;
               nerror := 105419;
               RAISE e_error;
            END IF;

            SELECT ssegpol
              INTO psseguro
              FROM estseguros
             WHERE sseguro = vsolicit;

            v_post.ctraspasar := 2;   -- la marco como traspasada
         END IF;

         IF pnmovimi = 1
            AND v_post.cemitir = 1
            AND NOT pac_iax_produccion.isaltacol
            AND vcreteni = 0 THEN   -- obligo a que no esta retenida por psu
            IF v_post.ctraspasar <> 2 THEN   -- sino esta traspasada la traspaso
               pac_alctr126.traspaso_tablas_est(vsolicit, pfefecto, NULL, pmens, 'ALCTR126',
                                                NULL, pnmovimi, NULL);

               IF pmens IS NOT NULL THEN
                  vpasexec := 200;
                  nerror := 105419;
                  RAISE e_error;
               END IF;

               v_post.ctraspasar := 2;   -- la marco como traspasada
            END IF;

            SELECT ssegpol   --, creteni
              INTO psseguro   --, vcreteni
              FROM estseguros
             WHERE sseguro = vsolicit;

            --pac_alctr126.borrar_tablas_est(vsolicit);
            vprimatotal := f_segprima(psseguro, pfefecto);

            UPDATE seguros
               SET iprianu = vprimatotal
             WHERE sseguro = psseguro;

            IF nerror > 0 THEN
               vpasexec := 205;
               RAISE e_error;
            END IF;

            vpasexec := 210;
            nerror := pac_md_produccion.f_emitir_propuesta(vsolicit, onpoliza, psseguro,
                                                           onmovimi, mensajes);

            IF nerror <> 0 THEN
               vpasexec := 220;

               IF mensajes IS NOT NULL THEN
                  FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                     pmens := mensajes(i).terror;
                  END LOOP;
               END IF;

               nerror := 140730;   -- da error al emitir lo marco todo como warning
               -- RAISE e_error;
               nerror := f_ins_mig_logs_axis(pncarga, 'PRINCIPAL', 'W',
                                             'Aviso:' || nerror || '-' || pmens);
               RETURN 0;
            END IF;
         ELSIF (pnmovimi > 1)
               AND NOT pac_iax_produccion.isaltacol THEN   --si es suplemento
            IF pac_seguros.f_es_col_admin(vsolicit, 'EST') <> 1
               AND vcreteni = 0
               AND v_post.cemitir = 1 THEN
               SELECT ssegpol
                 INTO psseguro
                 FROM estseguros
                WHERE sseguro = vsolicit;

               nerror := pk_suplementos.f_grabar_suplemento_poliza(vsolicit, pnmovimi);

               IF nerror <> 0 THEN
                  pmens := 'error grabar suplemento '
                           || NVL(f_axis_literales(nerror, vcidioma), nerror);
                  RAISE e_error;
               END IF;

               v_post.ctraspasar := 2;
               pac_iax_produccion.issuplem := TRUE;
               --

               --
               pac_iax_produccion.vsseguro := psseguro;
               nerror := pac_md_produccion.f_emitir_propuesta(vsolicit, onpoliza, psseguro,
                                                              onmovimi, mensajes);
               pac_iax_produccion.issuplem := FALSE;
               pac_iax_produccion.vsseguro := NULL;

               IF nerror <> 0 THEN
                  vpasexec := 220;

                  IF mensajes IS NOT NULL THEN
                     FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                        pmens := mensajes(i).terror;
                     END LOOP;
                  END IF;
               END IF;
            ELSE   -- si es col_admin o retenido la dejo en propuesta
               UPDATE estseguros e
                  SET e.csituac = 5   --,
                WHERE e.sseguro = vsolicit;

               --
               SELECT ssegpol
                 INTO psseguro
                 FROM estseguros
                WHERE sseguro = vsolicit;

               nerror := pk_suplementos.f_grabar_suplemento_poliza(vsolicit, pnmovimi);

               IF nerror <> 0 THEN
                  pmens := 'error grabar suplemento '
                           || NVL(f_axis_literales(nerror, vcidioma), nerror);
                  RAISE e_error;
               END IF;

               v_post.ctraspasar := 2;   -- para que lo borre
            END IF;
         END IF;

         -- Miro si es un colectivo y se tiene que emitir y si es administrado además abrirlo
         IF pac_iax_produccion.isaltacol THEN
            IF v_post.cemitir_colectivo = 1
               AND pnmovimi = 1
               AND vcreteni = 0 THEN   -- obligo a que no esta retenida por psu
               IF v_post.ctraspasar <> 2 THEN   -- sino esta traspasada la traspaso
                  pac_alctr126.traspaso_tablas_est(vsolicit, pfefecto, NULL, pmens,
                                                   'ALCTR126', NULL, pnmovimi, NULL);

                  IF pmens IS NOT NULL THEN
                     vpasexec := 200;
                     nerror := 105419;
                     RAISE e_error;
                  END IF;

                  v_post.ctraspasar := 2;   -- la marco como traspasada
               END IF;

               vpasexec := 810;
               pac_iax_produccion.vsseguro := psseguro;   -- por si estuviera traspasado
               nerror := pac_md_produccion.f_emitir_propuesta(vsolicit, onpoliza, psseguro,
                                                              onmovimi, mensajes);

               IF nerror <> 0 THEN
                  vpasexec := 820;

                  IF mensajes IS NOT NULL THEN
                     FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                        pmens := mensajes(i).terror;
                     END LOOP;
                  END IF;

                  nerror := 140730;   -- da error al emitir lo marco todo como warning
                  -- RAISE e_error;
                  nerror := f_ins_mig_logs_axis(pncarga, 'PRINCIPAL', 'W',
                                                'Aviso:' || nerror || '-' || pmens);
                  RETURN 0;
               END IF;
            END IF;

            --
            IF v_post.cabrir_colectivo = 1
               AND pac_seguros.f_es_col_admin(psseguro) = 1
               AND pac_seguros.f_suplem_obert(psseguro) = 0 THEN
               -- abro el suplementpo
               nerror := pac_md_produccion.f_abrir_suplemento(psseguro, mensajes);

               --
               IF nerror <> 0 THEN
                  vpasexec := 880;

                  IF mensajes IS NOT NULL THEN
                     FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                        pmens := mensajes(i).terror;
                     --nerror := mensajes(i).nerror;
                     END LOOP;
                  END IF;

                  nerror := 9904240;
                  nerror := f_ins_mig_logs_axis(pncarga, 'PRINCIPAL', 'W',
                                                'Aviso:' || nerror || '-' || pmens);
                  RETURN 0;
               END IF;
            END IF;   -- abrir colectivo
         END IF;   -- colecivo
      --
      END IF;   -- fin del 'EST'

      -- 28263 / 160578 - FPG - 5-12-2013 - Inicio
      IF v_tratar_docrequerida = 1 THEN
         nerror := pac_md_docrequerida.f_subir_docsgedox(psseguro, pnmovimi, mensajes);

         IF nerror <> 0 THEN
            pmens := 'error subir docsgedox '
                     || NVL(f_axis_literales(nerror, vcidioma), nerror);
            RAISE e_error;
         END IF;
      END IF;

      -- 28263 / 160578 - FPG - 5-12-2013 - Final
      --
      --
       -- Imprimo?
      IF v_post.cimprimir = 1   --AND pnmovimi = 1
                             THEN
         COMMIT;   -- si no imprime mal en certificado y datos
         vcidioma := pac_md_common.f_get_cxtidioma;
         vt_obj := pac_md_impresion.f_get_documprod(psseguro, vcidioma, mensajes);

         IF mensajes IS NOT NULL THEN
            FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
               nerror := mensajes(i).cerror;
               pmens := mensajes(i).terror;
               --RAISE e_error;
               nerror := f_ins_mig_logs_axis(pncarga, 'PRINCIPAL', 'W',
                                             'Aviso:' || nerror || '-' || pmens);
               RETURN 0;
            --  Si falla impresion marco el warning y salgo como correcto, no quiero hacer rollback
            END LOOP;
         END IF;
      ELSIF v_post.cimprimir = 2 THEN
         COMMIT;

         FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro)
                                                                                      nmovimi,
                            ppc.ctipo
                       FROM prod_plant_cab ppc, seguros s
                      WHERE s.sseguro = psseguro
                        AND s.sproduc = ppc.sproduc
                        AND ppc.ctipo = 41
                   GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
            pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                        i.cidioma, i.ctipo);
         END LOOP;
      END IF;

      IF v_post.ctraspasar = 2 THEN
         pac_alctr126.borrar_tablas_est(vsolicit);

         --   cur_personas
         FOR reg IN (SELECT ep.sperson
                       FROM v_personas_seguros vs, estper_personas ep
                      WHERE vs.sseguro = psseguro
                        AND ep.sseguro IS NULL
                        AND ep.spereal = vs.sperson) LOOP   -- borro las personas que forman parte de la
            pac_persona.borrar_tablas_estper(reg.sperson);
         END LOOP;
      END IF;

      --
      RETURN nerror;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MIG_AXIS.f_lanza_post', vpasexec,
                     'Parametros: psseguro =' || psseguro || ' - ' || vsolicit || '-'
                     || 'pfefecto =' || pfefecto || '-Pnmovimi:' || pnmovimi || ' psproduc ='
                     || psproduc,
                     nerror || '-' || pmens);
         RETURN nerror;   -- Error General
      WHEN OTHERS THEN
         nerror := 108190;
         pmens := SQLERRM;   -- Error no controlado
         p_tab_error(f_sysdate, f_user, 'PAC_MIG_AXIS.f_lanza_post', vpasexec,
                     'Parametros: psseguro =' || psseguro || '-' || vsolicit || '-'
                     || 'pfefecto =' || pfefecto || '-Pnmovimi:' || pnmovimi || ' psproduc ='
                     || psproduc,
                     SQLCODE);
         RETURN nerror;   -- Error General
   END f_lanza_post;

-- 23289/120321 - JLB- 19/09/2012

   /***************************************************************************
      FUNCTION f_next_carga
      Asigna número de carga
         return         : Número de carga
   ***************************************************************************/
   FUNCTION f_next_carga
      RETURN NUMBER IS
      v_seq          NUMBER;
   BEGIN
      SELECT sncarga.NEXTVAL
        INTO v_seq
        FROM DUAL;

      RETURN v_seq;
   END f_next_carga;

   -- fin Bug 0011578 - JMF - 05-11-2009

   -- ini Bug 0011578 - JMF - 05-11-2009
   /***************************************************************************
      PROCEDURE p_crea_migcargas
      Crea nuevo registro de incio carga.
         param in  p_car:  Número de carga
         param in  p_emp:  Código empresa
   ***************************************************************************/
   PROCEDURE p_crea_migcargas(p_car IN NUMBER, p_emp IN VARCHAR2) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, estorg)
           VALUES (p_car, p_emp, f_sysdate, f_sysdate, 'OK');

      COMMIT;
   END p_crea_migcargas;

   -- fin Bug 0011578 - JMF - 05-11-2009

   -- ini Bug 0011578 - JMF - 05-11-2009
   /***************************************************************************
      PROCEDURE p_crea_MIGCARGASTABMIG
      Crea nuevo registro de incio tablas de carga.
         param in  p_car:  Número de carga
         param in  p_est:  Número de tabla
         param in  p_org:  Descripción origen
         param in  p_des:  Descripción destino
   ***************************************************************************/
   PROCEDURE p_crea_migcargastabmig(
      p_car IN NUMBER,
      p_tab IN NUMBER,
      p_org IN VARCHAR2,
      p_des IN VARCHAR2) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO mig_cargas_tab_mig
                  (ncarga, ntab, tab_org, tab_des, finides, ffindes, estdes)
           VALUES (p_car, p_tab, p_org, p_des, f_sysdate, NULL, NULL);

      COMMIT;
   END p_crea_migcargastabmig;

   -- fin Bug 0011578 - JMF - 05-11-2009

   -- ini Bug 0011578 - JMF - 05-11-2009
   /***************************************************************************
      PROCEDURE p_act_MIGCARGASTABMIG
      Actualiza registro de incio tablas de carga.
         param in  p_car:  Número de carga
         param in  p_est:  Número de tabla
         param in  p_org:  Descripción origen
         param in  p_des:  Descripción destino
         param in  p_est:  Estado
   ***************************************************************************/
   PROCEDURE p_act_migcargastabmig(
      p_car IN NUMBER,
      p_tab IN NUMBER,
      p_org IN VARCHAR2,
      p_des IN VARCHAR2,
      p_est IN VARCHAR2) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = p_est
       WHERE ncarga = p_car
         AND ntab = p_tab
         AND tab_org = p_org
         AND tab_des = p_des;

      COMMIT;
   END p_act_migcargastabmig;

   -- fin Bug 0011578 - JMF - 05-11-2009

   /***************************************************************************
      FUNCTION f_codigo_axis
      Dado un valor de un código de la empresa, nos devuelve el valor del
      código en AXIS
         param in  pcempres:  Código empresa
         param in  pccodigo:  Código a convertir
         param in  pcvalemp:  Valor en empresa del código
         param out pcvalaxis: Valor en AXIS del código
         return:              Código error
   ***************************************************************************/
   FUNCTION f_codigo_axis(
      pcempres IN VARCHAR2,
      pccodigo IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      pcvalaxis OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT DECODE(cvalaxis, 'NULL', NULL, cvalaxis)
        INTO pcvalaxis
        FROM mig_codigos_emp
       WHERE ccodigo = pccodigo
         AND cempres = pcempres
         AND((cvalemp = pcvalemp
              AND pcvalemp IS NOT NULL)
             OR(pcvalemp IS NULL
                AND cvalemp = 'NULL'));

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pcvalaxis := NULL;
         RETURN SQLCODE;
   END f_codigo_axis;

--

   /*
      FUNCTION f_migra_carga(pncarga IN NUMBER, pntab IN NUMBER)
         RETURN NUMBER IS
         PRAGMA AUTONOMOUS_TRANSACTION;
      BEGIN
         UPDATE mig_cargas_tab_mig
            SET ffindes = f_sysdate,
                estdes = 'OK'
          WHERE ncarga = pncarga
            AND ntab = pntab;

         COMMIT;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN SQLCODE;
      END f_migra_carga;
   */
                                                                                                    /***************************************************************************
         FUNCTION f_ins_mig_cargas_tab_axis
         Función para insertar registros en la tabla MIG_CARGAS_TAB_AXIS
            param in  pncarga:     Número de carga
            param in  pntab:       número de tabla MIG
            param in  pntabaxis:   Número de tabla AXIS
            param in  pttabaxis:   Nombre tabla AXIS
            return:                Código error
      ***************************************************************************/
   FUNCTION f_ins_mig_cargas_tab_axis(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      pntabaxis IN NUMBER,
      pttabaxis IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO mig_cargas_tab_axis
                  (ncarga, ntab, ntabaxis, ttabaxis)
           VALUES (pncarga, pntab, pntabaxis, pttabaxis);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_ins_mig_cargas_tab_axis;

   /***************************************************************************
      FUNCTION f_trata_trigger
      Función para habilitar o deshabilitar un trigger.
         param in  pnombre:     Nombre de trigger
         param in  paccion:     'ENABLED' o 'DISABLED'
         return:                0-Correcto, 99-Error
   ***************************************************************************/
   FUNCTION f_trata_trigger(pnombre IN VARCHAR2, paccion IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      EXECUTE IMMEDIATE 'alter trigger ' || pnombre || ' ' || paccion;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 99;
   END f_trata_trigger;

   /***************************************************************************
      FUNCTION f_grabar_penalizacion
      Función que graba la penalización para cada anualidad de la póliza en PENALISEG,
      siempre y cuando haya penalización definida a nivel de producto
         param in  psproduc:     Código Producto
         param in  psseguro:     Indentificador único del seguro
         param in  pfefecto:     Fecha efecto de la póliza
         param in  pnmovimi:     Movimiento de la póliza
         param in  pmig_pk:      primary tabla origen
         param in  pncarga:      numero de carga
         param in  pntab:        numero tabla origen
         return:                0-Correcto, <>0-Error
   ***************************************************************************/
   FUNCTION f_grabar_penalizacion(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER DEFAULT 1,
      pmig_pk IN VARCHAR2,
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      CURSOR c_tipmov(psproduc IN NUMBER, pfecha IN DATE) IS
         SELECT ctipmov, niniran, nfinran
           FROM detprodtraresc d, prodtraresc p
          WHERE d.sidresc = p.sidresc
            AND p.sproduc = psproduc
            AND p.finicio <= pfecha
            AND(p.ffin > pfecha
                OR p.ffin IS NULL);

      num_err        NUMBER;
      duracion       NUMBER;
      xpenali        NUMBER;
      xtippenali     NUMBER;
      xipenali       NUMBER;
      xppenali       NUMBER;
      error          EXCEPTION;
   BEGIN
      -- Miramos si el producto tienen definido por parámetro que grabará en la tabla PENALISEG
      IF NVL(f_parproductos_v(psproduc, 'CONS_PENALI'), 0) = 1 THEN
         -- Para cada anualidad hasta la duración de la póliza grabamos la penalización parametrizada en el producto
         -- Averiguamos entonces la duración de la póliza o del periodo de interés garantizado
         duracion := pac_calc_comu.ff_get_duracion('SEG', psseguro);

         IF duracion IS NULL THEN
            RAISE error;
         END IF;

         -- Para cada anualidad hasta la duración miramos la penalización parametrizada en el producto
         FOR reg IN c_tipmov(psproduc, pfefecto) LOOP
            IF reg.niniran < duracion THEN
               num_err := f_penalizacion(reg.ctipmov, reg.nfinran, psproduc, psseguro,
                                         pfefecto, xpenali, xtippenali, 'SEG', 2);

               IF xtippenali = 1 THEN   -- importe
                  xipenali := xpenali;
                  xppenali := NULL;
               ELSIF xtippenali = 2 THEN   -- porcentaje
                  xppenali := xpenali;
                  xipenali := NULL;
               END IF;

               -- Se graba la penalización
               BEGIN
                  -- 23289/120321 - GAG - 23/08/2012
                  IF ptablas = 'EST' THEN
                     INSERT INTO estpenaliseg
                                 (sseguro, nmovimi, ctipmov, niniran, nfinran,
                                  ipenali, ppenali, clave)
                          VALUES (psseguro, pnmovimi, reg.ctipmov, reg.niniran, reg.nfinran,
                                  xipenali, xppenali, NULL);
                  ELSE
                     INSERT INTO penaliseg
                                 (sseguro, nmovimi, ctipmov, niniran, nfinran,
                                  ipenali, ppenali, clave)
                          VALUES (psseguro, pnmovimi, reg.ctipmov, reg.niniran, reg.nfinran,
                                  xipenali, xppenali, NULL);
                  END IF;

                  INSERT INTO mig_pk_mig_axis
                       VALUES (pmig_pk, pncarga, pntab, 4,
                               psseguro || '|' || pnmovimi || '|' || reg.ctipmov || '|'
                               || reg.niniran);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     -- 23289/120321 - ECP - 03/09/2012
                     IF ptablas = 'EST' THEN
                        UPDATE estpenaliseg
                           SET ipenali = xipenali,
                               ppenali = xppenali
                         WHERE sseguro = psseguro
                           AND nmovimi = pnmovimi
                           AND ctipmov = reg.ctipmov
                           AND niniran = reg.niniran;
                     ELSE
                        UPDATE penaliseg
                           SET ipenali = xipenali,
                               ppenali = xppenali
                         WHERE sseguro = psseguro
                           AND nmovimi = pnmovimi
                           AND ctipmov = reg.ctipmov
                           AND niniran = reg.niniran;
                     END IF;
               END;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_penalizacion', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pnmovimi =' || pnmovimi,
                     SQLERRM);
         RETURN 104506;   -- Error al obtener la duración del seguro.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_penalizacion', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pnmovimi =' || pnmovimi,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_penalizacion;

   /***************************************************************************
      FUNCTION f_ins_intertecseg
      Función que graba el interes tecnico de la póliza en INTERTECSEG.
         param in  psseguro:     Indentificador único del seguro
         param in  pnmovimi:     Movimiento de la póliza
         param in  pfefemov:     Fecha efecto del movimiento de la póliza
         param in  ppinttec:     Porcentaje del interes tecnico
         param in  pninttec:     Porcentaje de interés parametrizado en el momento de la inserción
         param in  pndesde:
         param in  pnhasta:
         return:                 0-Correcto, <>0-Error
   ***************************************************************************/
   FUNCTION f_ins_intertecseg(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefemov IN DATE,
      ppinttec IN NUMBER,
      pninttec IN NUMBER,
      pndesde IN NUMBER DEFAULT 0,
      pnhasta IN NUMBER DEFAULT 0,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      vndesde        NUMBER;
      vnhasta        NUMBER;
      vcmodint       NUMBER;
   BEGIN
      vndesde := NVL(pndesde, 0);
      vnhasta := NVL(pnhasta, 0);

      IF ptablas = 'EST' THEN
         SELECT cmodint
           INTO vcmodint
           FROM estseguros s, productos p
          WHERE sseguro = psseguro
            AND p.sproduc = s.sproduc;
      ELSE
         SELECT cmodint
           INTO vcmodint
           FROM seguros s, productos p
          WHERE sseguro = psseguro
            AND p.sproduc = s.sproduc;
      END IF;

      IF vcmodint = 0 THEN
         RETURN 0;
      ELSE
         BEGIN
            -- 23289/120321 - GAG - 23/08/2012
            IF ptablas = 'EST' THEN
               INSERT INTO estintertecseg
                           (sseguro, nmovimi, fefemov, fmovdia, pinttec,
                            ndesde, nhasta, ninntec)
                    VALUES (psseguro, pnmovimi, TRUNC(pfefemov), TRUNC(f_sysdate), ppinttec,
                            vndesde, vnhasta, pninttec);
            ELSE
               INSERT INTO intertecseg
                           (sseguro, nmovimi, fefemov, fmovdia, pinttec,
                            ndesde, nhasta, ninntec)
                    VALUES (psseguro, pnmovimi, TRUNC(pfefemov), TRUNC(f_sysdate), ppinttec,
                            vndesde, vnhasta, pninttec);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               -- 23289/120321 - GAG - 23/08/2012
               IF ptablas = 'EST' THEN
                  UPDATE estintertecseg
                     SET nmovimi = pnmovimi,
                         fefemov = TRUNC(pfefemov),
                         fmovdia = TRUNC(f_sysdate),
                         ndesde = vndesde,
                         nhasta = vnhasta,
                         pinttec = ppinttec,
                         ninntec = pninttec
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND ndesde = vndesde
                     AND nhasta = vnhasta;
               ELSE
                  UPDATE intertecseg
                     SET nmovimi = pnmovimi,
                         fefemov = TRUNC(pfefemov),
                         fmovdia = TRUNC(f_sysdate),
                         ndesde = vndesde,
                         nhasta = vnhasta,
                         pinttec = ppinttec,
                         ninntec = pninttec
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND ndesde = vndesde
                     AND nhasta = vnhasta;
               END IF;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104742;
   END f_ins_intertecseg;

   /***************************************************************************
      FUNCTION f_grabar_inttec2
      Función que graba el interes tecnico de la póliza en INTERTECSEG,
      siempre y cuando haya interés técnico.
      Si el parámetro PINTTEC es NULO, entonces se busca el interés parametrizado en el producto.
         param in  psproduc:     Indentificador único del producto
         param in  psseguro:     Indentificador único del seguro
         param in  pfefecto:     Fecha efecto de la póliza
         param in  pnmovimi:     Movimiento de la póliza
         param in  ppinttec:     Porcentaje del interes tecnico
         param in  pvtramoini:
         param in  pvtramofin:
         return:                 0-Correcto, <>0-Error
   ***************************************************************************/
   FUNCTION f_grabar_inttec2(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pinttec IN NUMBER DEFAULT NULL,
      pvtramoini IN NUMBER DEFAULT NULL,
      pvtramofin IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      -- Tarea 2674: Intereses para LRC.Añadimos el tramo que queremos insertar este interés.
   RETURN NUMBER IS
      v_pinttec      NUMBER;
      v_pninttec     NUMBER;
      v_codint       NUMBER;
      num_err        NUMBER;
      v_tipo         NUMBER;
      errores        EXCEPTION;
   BEGIN
      -- Miramos si el producto tienen definido un cuadro de interés técnico
      num_err := pac_inttec.f_existe_intertecprod(psproduc);

      IF num_err = 1 THEN   -- el producto sí que tiene definido intereses técnico
         IF pinttec IS NULL THEN
            --Si no informamos el interés lo buscamos según la parametrización del producto.
                     -- Si el pinttec es NULO miramos buscamos el interés parametrizado en el producto
                      -- le pasamos el modo..
            v_tipo := f_es_renova(psseguro, pfefecto);

            /*   0 SI ES CARTERA // 1 SI ES NUEVA PRODUCCIÓN)*/
            IF v_tipo = 0 THEN
               v_tipo := 2;   --Modo renovación.
            ELSE
               v_tipo := 1;   --Modo alta
            END IF;

            num_err := pac_inttec.f_int_seguro_alta_renova(ptablas, psseguro, v_tipo, pfefecto,
                                                           v_pinttec, v_pninttec, pvtramoini);

            -- Tarea 2674: Intereses para LRC.Añadimos el año (informado en el parámetro tramo) del que queremos buscar el interés en los productos LRC.
            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSE
            v_pinttec := pinttec;
         END IF;

         -- Insertamos en ESTINTERTECSEG todo el tramo con el interés que tenemos.
         num_err := f_ins_intertecseg(psseguro, pnmovimi, pfefecto, v_pinttec, v_pninttec,
                                      pvtramoini, pvtramofin, ptablas);

         -- Tarea 2674: En esta función henmos insertado también los tramos ndesde nhasta.
         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN errores THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_inttec2', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pinttec=' || pinttec,
                     'Parámetros incorrectos');
         RETURN 108190;   -- Error General
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_inttec2', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pinttec=' || pinttec,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_inttec2;

   /***************************************************************************
      FUNCTION f_grabar_inttec
      Función que graba el interes tecnico de la póliza en INTERTECSEG,
      siempre y cuando haya interés técnico.
      Si el parámetro PINTTEC es NULO, entonces se busca el interés parametrizado en el producto.
         param in  psproduc:     Indentificador único del producto
         param in  psseguro:     Indentificador único del seguro
         param in  pfefecto:     Fecha efecto de la póliza
         param in  pnmovimi:     Movimiento de la póliza
         param in  ppinttec:     Porcentaje del interes tecnico
         param in  pvtramoini:
         param in  pvtramofin:
         return:                 0-Correcto, <>0-Error
   ***************************************************************************/
   FUNCTION f_grabar_inttec(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pinttec IN NUMBER DEFAULT NULL,
      pvtramoini IN NUMBER DEFAULT NULL,
      pvtramofin IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      -- Tarea 2674: Intereses para LRC.Añadimos el tramo que queremos insertar este interés.
   RETURN NUMBER IS
      /********************************************************************************************************************
         Función que graba el interés técnico de la póliza en ESTINTERTECSEG siempre y cuando haya interés técnico
         definido a nivel de producto.

         En el caso de que se informe el importe se han añadido los tramos para el caso de LRC (periodo anualidad) a los que se refiere el importe.

          Para ramos tipo LRC en el caso de que no se informe el importe se daran de alta en las tablas de intereses a nivel de póliza
          los intereses correspondientes a todas las anualidades del periodo seleccionado (parametrizados a nivel de producto).

         En el resto de casos si el parámetro PINTTEC es NULO, entonces se busca el interés parametrizado en el producto
      ********************************************************************************************************************/
      v_pinttec      NUMBER;
      v_codint       NUMBER;
      num_err        NUMBER;
      v_tipo         NUMBER;
      errores        EXCEPTION;
      anyopol        NUMBER := 0;

      --Buscamos los tramos correspondientes al producto tipo LRC con su interés para el período contratado y los
      --insertamos en la tabla de intereses por póliza.
       /*CURSOR TramosLRC (psproduc IN Number,pctipo IN NUMBER,pfecha IN Date,durac in Number)  IS
       select id.ndesde,id.nhasta,id.ninttec
      from   intertecprod ip, intertecmov im, intertecmovdet id
      where  ip.sproduc = psproduc
      and    ip.ncodint = im.ncodint
      and    im.ctipo = pctipo
      and    im.finicio <= pfecha
      and    (im.ffin >= pfecha or im.ffin is null)
      and    im.ncodint = id.ncodint
      and    im.finicio = id.finicio
      --and    substr(TO_CHAR(id.ndesde),1,1)=durac
      and    substr(TO_CHAR(id.ndesde),1,length(id.ndesde)-3)=durac --formato dur+ 000(anual.)
      and    im.ctipo = id.ctipo;*/

      --Hasta ahora en LRC se insertaban todos los registros para una duración. Por el momento ahora sólo
      --grabaremos un registro del tipo TIR. Sólo obtendremos un registro, con lo que queda todo el tratamiento de interés a
      --nivel de póliza igual que hasta antes del tratamiento incial del producto LRC.  Como sólo obtenemos
      --un registro grabaremos 0 en los tramos.
      CURSOR tramoslrc(psproduc IN NUMBER, pctipo IN NUMBER, pfecha IN DATE, tramo IN NUMBER) IS
         SELECT 0 ndesde, 0 nhasta, ID.ninttec
           FROM intertecprod ip, intertecmov im, intertecmovdet ID
          WHERE ip.sproduc = psproduc
            AND ip.ncodint = im.ncodint
            AND im.ctipo = pctipo
            AND im.finicio <= pfecha
            AND(im.ffin >= pfecha
                OR im.ffin IS NULL)
            AND im.ncodint = ID.ncodint
            AND im.finicio = ID.finicio
            --and    substr(TO_CHAR(id.ndesde),1,1)=durac
            AND ID.ndesde = tramo   --formato dur+ 000(anual.)
            AND im.ctipo = ID.ctipo;

      pnduraci       NUMBER;
      ptipo          VARCHAR2(5);
      formpagren     NUMBER;
      num            NUMBER := 0;
      vctramtip      NUMBER;
   BEGIN
      IF pinttec IS NOT NULL THEN
         --Si el importe está informado grabamos el valor de ese tramo directamente
         num_err := f_grabar_inttec2(psproduc, psseguro, pfefecto, pnmovimi, pinttec,
                                     pvtramoini, pvtramofin, ptablas);

         IF num_err <> 0 THEN
            RAISE errores;
         END IF;
      ELSE
         BEGIN
            ptipo := f_es_renova(psseguro, pfefecto);

            /* 0: si es cartera// 1:Nueva producción */
            IF ptipo = 0 THEN
               ptipo := 4;   -- Interés Garatizado en el periodod de Renovación
            ELSE
               ptipo := 3;   --Interés Garatizado en el periodod de Alta
            END IF;

            -- Recuperamos el tipo de calculo
            SELECT ctramtip
              INTO vctramtip
              FROM intertecmov i, intertecprod p
             WHERE p.sproduc = psproduc
               AND p.ncodint = i.ncodint
               AND i.ctipo = ptipo   -- para el interes que estemos calculando
               AND i.finicio <= pfefecto
               AND(i.ffin >= pfefecto
                   OR i.ffin IS NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;   -- Si no hay interes... pues nos vamos !!
         END;

         IF vctramtip = 3 THEN   -- Tarea 2674: Tipo LRC Duración-Anualidad
            pnduraci := pac_calc_comu.ff_get_duracion('SEG', psseguro);
            formpagren := pac_calc_rentas.ff_get_formapagoren('SEG', psseguro);

            IF formpagren IS NULL THEN
               num_err := 180602;
               RAISE errores;
            END IF;

             --Hasta ahora en LRC se insertaban todos los registros para una duración. Por el momento ahora sólo
            --grabaremos un registro del tipo TIR. Sólo obtendremos un registro, con lo que queda todo el tratamiento de interés a
            --nivel de póliza igual que hasta antes del tratamiento incial del producto LRC.  Como sólo obtenemos
            --un registro grabaremos 0 en los tramos.

            --El formato del tramo es duración + anualidad + forma pago renta (formato: daaaff)
            --En formpagren tenemos la forma de pago de la renta
            --De momento para el TIR siempre tenemos la anualidad 1 y las demás valen igual
            pnduraci := pnduraci || '001' || LPAD(formpagren, 2, '0');

            --Para este caso buscamos el TIR (tipo 6)
            FOR reg IN tramoslrc(psproduc, 6, pfefecto, pnduraci) LOOP
               -- Grabamos todos los tramos periodo / anualidad (con el cambio del LRC a 01/11/2007 solo obtenemos un registro con el valor del TIR).
               num := num + 1;
               -- Pasamos ya interés, pero preferimos que lo vuelva a hacer la función f_grabar_inttec2 y comprobar que lo hace bien.
               num_err := f_grabar_inttec2(psproduc, psseguro, pfefecto, pnmovimi,
                                           reg.ninttec, reg.ndesde, reg.nhasta, ptablas);

               IF num_err <> 0 THEN
                  RAISE errores;
               END IF;
            END LOOP;

            IF num = 0 THEN
               num_err := 104742;
               RAISE errores;
            END IF;
         ELSE
-- Si no hacemos lo de siempre (un sólo valor de interés)
 ------------------------------------------------------------------------------------------------------------
  -- Grabamos el interés técnico en INTERTECSEG
 --------------------------------------------------------------------------------------------------------------
            num_err := f_grabar_inttec2(psproduc, psseguro, pfefecto, pnmovimi, NULL, NULL,
                                        NULL, ptablas);   --sss

            IF num_err <> 0 THEN
               RAISE errores;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN errores THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_inttec', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pinttec=' || pinttec || ' pnduraci:'
                     || pnduraci,
                     'Error grabando intereses');
         RETURN 108190;   -- Error General
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_inttec', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pinttec=' || pinttec,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_inttec;

--Grabar si productos.cagrpro=2 en tabla SEGUROS_AHO
--*****
--*****
   /***************************************************************************
      FUNCTION f_strstd_mig
      Función que elimina caracteres especiales y sustituye palabras acentuadas,
      sin acento para su comparación con otra cadena.
         param in  pstr:     Cadena a tratar
         return:             Cadena tratada
   ***************************************************************************/
   FUNCTION f_strstd_mig(pstr IN VARCHAR2)
      RETURN VARCHAR2 IS
      num_err        NUMBER;
      v_salida       VARCHAR2(223);
   BEGIN
      num_err := f_strstd(pstr, v_salida);

      IF num_err = 0 THEN
         v_salida := REPLACE(v_salida, 'Ç', 'C');
         v_salida := REPLACE(v_salida, '/', '');
         RETURN v_salida;
      ELSE
         RETURN NULL;
      END IF;
   END f_strstd_mig;

   /***************************************************************************
      FUNCTION f_persona_duplicada
      Función que identifica si una persona ya esta dentro de iAxis para no
      migrarla.
         param in  ptapelli1:    Primer apellido de la persona.
         param in  ptapelli2:    Segundo apellido de la persona.
         param in  ptnombre:     Nombre de la persona.
         param in  pfnacimi:     Fecha de Nacimiento
         param in  pcsexper:     Código del Sexo
         param out psperson:     Identificador único de la persona existente
         return:             0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_persona_duplicada(
      ptapelli1 IN mig_personas.tapelli1%TYPE,
      ptapelli2 IN mig_personas.tapelli2%TYPE,
      ptnombre IN mig_personas.tnombre%TYPE,
      pfnacimi IN mig_personas.fnacimi%TYPE,
      pcsexper IN mig_personas.csexper%TYPE,
      psperson OUT per_personas.sperson%TYPE)
      RETURN NUMBER IS
   BEGIN
      SELECT per.sperson
        INTO psperson
        FROM per_personas per, per_detper detper
       WHERE per.sperson = detper.sperson
         AND f_strstd_mig(detper.tapelli1) = f_strstd_mig(ptapelli1)
         AND NVL(f_strstd_mig(detper.tapelli2), '*') = NVL(f_strstd_mig(ptapelli2), '*')
         AND NVL(f_strstd_mig(detper.tnombre), '*') = NVL(f_strstd_mig(ptnombre), '*')
         AND NVL(per.csexper, 0) = NVL(pcsexper, 0)
         AND NVL(per.fnacimi, TRUNC(f_sysdate)) = NVL(pfnacimi, TRUNC(f_sysdate));

      RETURN 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

    /***************************************************************************
      FUNCTION f_persona_duplicada_cem
      Función que identifica si una persona ya esta dentro de iAxis para no (Especifica para CEM para evitar que tarde 5s cada carga)
      migrarla.
         param in  ptapelli1:    Primer apellido de la persona.
         param in  ptapelli2:    Segundo apellido de la persona.
         param in  ptnombre:     Nombre de la persona.
         param in  pfnacimi:     Fecha de Nacimiento
         param in  pcsexper:     Código del Sexo
         param out psperson:     Identificador único de la persona existente
         return:             0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_persona_duplicada_cem(
      ptapelli1 IN mig_personas.tapelli1%TYPE,
      ptapelli2 IN mig_personas.tapelli2%TYPE,
      ptnombre IN mig_personas.tnombre%TYPE,
      pfnacimi IN mig_personas.fnacimi%TYPE,
      pcsexper IN mig_personas.csexper%TYPE,
      psperson OUT per_personas.sperson%TYPE)
      RETURN NUMBER IS
   BEGIN
      SELECT per.sperson
        INTO psperson
        FROM per_personas per, per_detper detper
       WHERE per.sperson = detper.sperson
         AND UPPER(detper.tapelli1) = UPPER(ptapelli1)
         AND NVL(UPPER(detper.tapelli2), '*') = NVL(UPPER(ptapelli2), '*')
         AND NVL(UPPER(detper.tnombre), '*') = NVL(UPPER(ptnombre), '*')
         AND NVL(per.csexper, 0) = NVL(pcsexper, 0)
         AND NVL(per.fnacimi, TRUNC(f_sysdate)) = NVL(pfnacimi, TRUNC(f_sysdate));

      RETURN 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   /***************************************************************************
      FUNCTION f_ins_ageredcom
      Función que inserta el registro en la tabla AGEREDCOM una vez migrado el
      agente.
         param in  pcagente:    Código de agente.
         return:             0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_ins_ageredcom(pcagente IN NUMBER)
      RETURN NUMBER IS
      vcagente       NUMBER;
      vcempres       NUMBER;
      vctipage       NUMBER;
      vfmovini       DATE;
      vfmovfin       DATE;
      vfbaja         DATE;
      vc00           NUMBER;
      vc01           NUMBER;
      vc02           NUMBER;
      vc03           NUMBER;
      vc04           NUMBER;
      vc05           NUMBER;
      vc06           NUMBER;
      vc07           NUMBER;
      vc08           NUMBER;
      vc09           NUMBER;
      vc10           NUMBER;
      vc11           NUMBER;
      vc12           NUMBER;
      vcpervisio     NUMBER;
      vcpernivel     NUMBER;
      vcpolvisio     NUMBER;
      vcpolnivel     NUMBER;
      votro          NUMBER := 0;
      vcount         NUMBER;
      -- Bug 0024871 - 28/11/2012 - JMF
      d_calfec       ageredcom.fmovini%TYPE;
   BEGIN
      FOR c IN (SELECT a.cagente, a.fbajage, r.fmovini, r.cempres
                  FROM agentes a, redcomercial r
                 WHERE a.cagente = r.cagente
                   AND a.cagente = pcagente
                                           --          AND r.fmovfin IS NULL
              ) LOOP
         vcagente := NULL;
         vcempres := NULL;
         vctipage := NULL;
         vfmovini := NULL;
         vfmovfin := NULL;
         vfbaja := NULL;
         vc00 := 0;
         vc01 := 0;
         vc02 := 0;
         vc03 := 0;
         vc04 := 0;
         vc05 := 0;
         vc06 := 0;
         vc07 := 0;
         vc08 := 0;
         vc09 := 0;
         vc10 := 0;
         vc11 := 0;
         vc12 := 0;
         vcpervisio := NULL;
         vcpernivel := NULL;
         vcpolvisio := NULL;
         vcpolnivel := NULL;

         FOR rc IN (SELECT     cempres, cagente, fmovini, fmovfin, ctipage, cpervisio,
                               cpernivel, cpolvisio, cpolnivel
                          FROM redcomercial
                         WHERE fmovfin IS NULL
                    START WITH cagente = c.cagente
                           AND fmovini = c.fmovini
                           AND cempres = c.cempres
                    CONNECT BY (cagente = PRIOR cpadre
                                OR cagente = PRIOR cenlace)
                           AND cempres = PRIOR cempres
                                                      -- AND fmovfin IS NULL
                  ) LOOP
            IF rc.cagente = c.cagente THEN
               vcagente := rc.cagente;
               vcempres := rc.cempres;
               vfmovini := rc.fmovini;
               vfmovfin := rc.fmovfin;
               vctipage := rc.ctipage;
               vcpervisio := rc.cpervisio;
               vcpernivel := rc.cpernivel;
               vcpolvisio := rc.cpolvisio;
               vcpolnivel := rc.cpolnivel;
               vfbaja := c.fbajage;
            END IF;

            IF votro = 1 THEN
               IF rc.ctipage = 0 THEN
                  NULL;
               ELSIF rc.ctipage = 1 THEN
                  vc00 := 0;
               ELSIF rc.ctipage = 2 THEN
                  vc00 := 0;
                  vc01 := 0;
               ELSIF rc.ctipage = 3 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
               ELSIF rc.ctipage = 4 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
                  vc03 := 0;
               ELSIF rc.ctipage = 5 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
                  vc03 := 0;
                  vc04 := 0;
               ELSIF rc.ctipage = 6 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
                  vc03 := 0;
                  vc04 := 0;
                  vc05 := 0;
               ELSIF rc.ctipage = 7 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
                  vc03 := 0;
                  vc04 := 0;
                  vc05 := 0;
                  vc06 := 0;
               ELSIF rc.ctipage = 8 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
                  vc03 := 0;
                  vc04 := 0;
                  vc05 := 0;
                  vc06 := 0;
                  vc07 := 0;
               ELSIF rc.ctipage = 9 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
                  vc03 := 0;
                  vc04 := 0;
                  vc05 := 0;
                  vc06 := 0;
                  vc07 := 0;
                  vc08 := 0;
               ELSIF rc.ctipage = 10 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
                  vc03 := 0;
                  vc04 := 0;
                  vc05 := 0;
                  vc06 := 0;
                  vc07 := 0;
                  vc08 := 0;
                  vc09 := 0;
               ELSIF rc.ctipage = 11 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
                  vc03 := 0;
                  vc04 := 0;
                  vc05 := 0;
                  vc06 := 0;
                  vc07 := 0;
                  vc08 := 0;
                  vc09 := 0;
                  vc10 := 0;
               ELSIF rc.ctipage = 12 THEN
                  vc00 := 0;
                  vc01 := 0;
                  vc02 := 0;
                  vc03 := 0;
                  vc04 := 0;
                  vc05 := 0;
                  vc06 := 0;
                  vc07 := 0;
                  vc08 := 0;
                  vc09 := 0;
                  vc10 := 0;
                  vc11 := 0;
               ELSE
                  NULL;
               END IF;
            END IF;

            IF rc.fmovfin IS NOT NULL
               OR votro = 1 THEN
               vfmovini := rc.fmovini;
               vfmovfin := rc.fmovfin;
               votro := 0;
            END IF;

            IF rc.ctipage = 0 THEN
               vc00 := rc.cagente;
            ELSIF rc.ctipage = 1 THEN
               vc01 := rc.cagente;
            ELSIF rc.ctipage = 2 THEN
               vc02 := rc.cagente;
            ELSIF rc.ctipage = 3 THEN
               vc03 := rc.cagente;
            ELSIF rc.ctipage = 4 THEN
               vc04 := rc.cagente;
            ELSIF rc.ctipage = 5 THEN
               vc05 := rc.cagente;
            ELSIF rc.ctipage = 6 THEN
               vc06 := rc.cagente;
            ELSIF rc.ctipage = 7 THEN
               vc07 := rc.cagente;
            ELSIF rc.ctipage = 8 THEN
               vc08 := rc.cagente;
            ELSIF rc.ctipage = 9 THEN
               vc09 := rc.cagente;
            ELSIF rc.ctipage = 10 THEN
               vc10 := rc.cagente;
            ELSIF rc.ctipage = 11 THEN
               vc11 := rc.cagente;
            ELSIF rc.ctipage = 12 THEN
               vc12 := rc.cagente;
            ELSE
               NULL;
            END IF;
         END LOOP;

         IF vcagente IS NOT NULL
            AND vcempres IS NOT NULL
            AND vfmovini IS NOT NULL THEN
            BEGIN
               INSERT INTO ageredcom
                           (cagente, cempres, ctipage, fmovini, fmovfin, fbaja, c00,
                            c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11,
                            c12, cpervisio, cpernivel, cpolvisio, cpolnivel)
                    VALUES (vcagente, vcempres, vctipage, vfmovini, vfmovfin, vfbaja, vc00,
                            vc01, vc02, vc03, vc04, vc05, vc06, vc07, vc08, vc09, vc10, vc11,
                            vc12, vcpervisio, vcpernivel, vcpolvisio, vcpolnivel);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;

            votro := 1;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_ins_ageredcom;

   /***************************************************************************
      FUNCTION f_migra_personas
      Función que inserta las personas grabadas en MIG_PERSONAS, en las distintas
      tablas de personas de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_personas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_sperson      per_personas.sperson%TYPE;
      v_nnumide      per_personas.nnumide%TYPE;
      v_snip         per_personas.snip%TYPE;
      v_tsiglas      per_detper.tsiglas%TYPE;
      num_err        NUMBER;
      v_cmodcon      NUMBER;   --per_contactos.cmodcon%TYPE;
      v_error        BOOLEAN := FALSE;
      v_warning      BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE := NULL;
      v_1_personas   BOOLEAN := TRUE;
      v_1_detper     BOOLEAN := TRUE;
      v_1_direcciones BOOLEAN := TRUE;
      v_1_contactos  BOOLEAN := TRUE;
      v_1_ident      BOOLEAN := TRUE;
      v_1_ccc        BOOLEAN := TRUE;
      v_1_nacio      BOOLEAN := TRUE;
      v_1_antiguedad BOOLEAN := TRUE;
      v_cont         NUMBER := 0;
      v_cdomici      per_direcciones.cdomici%TYPE;
      v_existe       NUMBER;
      v_tnombre      per_detper.tnombre%TYPE;
      v_nordide      per_personas.nordide%TYPE;
      v_spersonest   estper_personas.sperson%TYPE;
      -- nuevo para controlar el digito de control
      ss             VARCHAR2(3000);
      v_propio       VARCHAR2(500);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      retorno        VARCHAR2(1);
      vdigitoide     per_personas.tdigitoide%TYPE;
      vcempres       empresas.cempres%TYPE
                      := NVL(pac_md_common.f_get_cxtempresa, f_parinstalacion_n('EMPRESADEF'));
      -- No. 49 - 05/05/2014 - JLTS - Se adiciona la variable vcagente
      vcagente       agentes.cagente%TYPE;
      ndiferido      NUMBER := 0;
   BEGIN
      --num_err := f_ins_mig_logs_axis(pncarga, NULL, 'I', 'Inicio');
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      --    COMMIT;
      FOR x IN (SELECT   a.*
                    FROM mig_personas a
                   WHERE ncarga = pncarga
                     AND cestmig = 1
                ORDER BY mig_pk) LOOP
         --IF x.nnumide <> 'Z' AND x.snip IS NOT NULL THEN
         v_cont := 0;
         v_error := FALSE;
         v_existe := 1;
         v_nordide := 0;

         -- No. 49 - 05/05/2014 - JLTS - Se adiciona el siguiente if y se iguala la variable vcagente
         IF x.swpubli = 1 THEN
            vcagente := x.cagente;
         ELSE
            vcagente := NULL;
         END IF;

-- MIRO SI LA PERSONAS YA ESTA CREADA ANTERIORMENTE en el mismo proceso de mig (ncarga) pero diferente registro y ha ido para las est
         IF ptablas = 'EST' THEN
            SELECT MIN(idperson), COUNT('x')
              INTO v_sperson, v_cont
              FROM mig_personas
             WHERE ncarga = x.ncarga
               AND NVL(ctipide, '0') = NVL(x.ctipide, '0')
               AND NVL(nnumide, '*') = NVL(x.nnumide, '*')
               AND NVL(cestper, '0') = NVL(x.cestper, '0')
               AND NVL(cpertip, '0') = NVL(x.cpertip, '0')
               AND NVL(csexper, '0') = NVL(x.csexper, '0')
               AND NVL(fnacimi, TRUNC(f_sysdate)) = NVL(x.fnacimi, TRUNC(f_sysdate))
               AND NVL(cagente, '0') = NVL(x.cagente, '0')
               AND NVL(tapelli1, '*') = NVL(x.tapelli1, '*')
               AND NVL(tapelli2, '*') = NVL(x.tapelli2, '*')
               AND NVL(tnombre, '*') = NVL(x.tnombre, '*')
               AND NVL(tnombre2, '*') = NVL(x.tnombre2, '*')
               AND mig_pk <> x.mig_pk   -- quito la nuestra
               AND NVL(idperson, 0) <> 0;
         ELSE
            v_sperson := NULL;
            v_cont := 0;
         END IF;

         IF v_sperson IS NOT NULL THEN
            v_existe := -2;

            UPDATE mig_personas
               SET idperson = v_sperson,
                   cestmig = 9 * v_existe
             WHERE mig_pk = x.mig_pk;
--            COMMIT;
         --          CONTINUE
         END IF;

         IF NOT v_existe = -2 THEN
            BEGIN
               IF v_cont = 0 THEN
                  IF x.snip IS NOT NULL THEN
                     --Se tiene que comprobar si ya existe
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_personas
                      WHERE snip = x.snip;

                     --AND csexper = x.csexper
                     --AND fnacimi = x.fnacimi;
                     IF v_cont > 0 THEN
                        --num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'W',
                          --                             'SNIP : ' || x.snip || ' ya existe en AXIS');
                         --v_warning := TRUE;
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'I',
                                                       'SNIP : ' || x.snip
                                                       || ' ya existe en AXIS');

                        SELECT MIN(sperson)   --Bug 26569/164184 - 27/01/2014 - AMC
                          INTO v_sperson
                          FROM per_personas
                         WHERE snip = x.snip;

                        UPDATE mig_personas
                           SET idperson = v_sperson
                         WHERE mig_pk = x.mig_pk;

                        v_existe := -1;
                     --               COMMIT;
                     END IF;
                  END IF;
               END IF;

               IF v_cont = 0 THEN
                  IF NVL(pac_parametros.f_parempresa_n(vcempres, 'DUP_NNUMIDE'), 0) = 1 THEN   --Permite duplicar nnumide
                             -- JLB - antes de duplicar compruebo que no exista con el mismo nombre
                     -- JLB - se elimina una select, y se recuper ya el sperson para mejor de rendimiento
                      --       SELECT COUNT('x')
                      --         INTO v_cont
                      --         FROM per_personas per, per_detper pd
                      --        WHERE ctipide = x.ctipide
                      --          AND nnumide = x.nnumide
                      --          AND nnumide <> 'Z'
                       --         AND pd.cagente = ff_agente_cpervisio(x.cagente)
                       --         AND NVL(tapelli1, '*') = NVL(x.tapelli1, '*')
                      --          AND NVL(tapelli2, '*') = NVL(x.tapelli2, '*')
                      --          AND NVL(tnombre1, '*') = NVL(x.tnombre, '*')
                     --           AND NVL(tnombre2, '*') = NVL(x.tnombre2, '*');
                     SELECT COUNT('x'), MAX(per.sperson)
                       INTO v_cont, v_sperson
                       FROM per_personas per, per_detper pd
                      WHERE ctipide = x.ctipide
                        AND nnumide = x.nnumide
                        AND nnumide <> 'Z'
                        AND pd.sperson = per.sperson   -- ojo faltaba esto
                        AND pd.cagente = ff_agente_cpervisio(x.cagente)
                        AND NVL(tapelli1, '*') = NVL(x.tapelli1, '*')
                        AND NVL(tapelli2, '*') = NVL(x.tapelli2, '*')
                        AND NVL(tnombre1, '*') = NVL(x.tnombre, '*')
                        AND NVL(tnombre2, '*') = NVL(x.tnombre2, '*')
                        AND ROWNUM = 1;

                     IF v_cont > 0 THEN
                         --    SELECT per.sperson
                        --       INTO v_sperson
                        --       FROM per_personas per, per_detper pd
                        --      WHERE ctipide = x.ctipide
                        --        AND nnumide = x.nnumide
                         --       AND nnumide <> 'Z'
                         --       AND pd.cagente = ff_agente_cpervisio(x.cagente)
                         --       AND NVL(tapelli1, '*') = NVL(x.tapelli1, '*')
                         --       AND NVL(tapelli2, '*') = NVL(x.tapelli2, '*')
                         --       AND NVL(tnombre1, '*') = NVL(x.tnombre, '*')
                         --       AND NVL(tnombre2, '*') = NVL(x.tnombre2, '*')
                         --       AND ROWNUM = 1;
                        UPDATE mig_personas
                           SET idperson = v_sperson
                         WHERE mig_pk = x.mig_pk;

                        v_existe := -1;
                     --                      COMMIT;
                     ELSE   -- sino la encuentro miro si la duplica
                        -- JLB - si ni existe la duplico

                        --Miramos si ya existe
                        SELECT COUNT('x')
                          INTO v_cont
                          FROM per_personas
                         WHERE nnumide = x.nnumide
                           AND nnumide <> 'Z';

                        --Si existe aumentar el nordide
                        IF v_cont > 0 THEN
                           SELECT MAX(NVL(nordide, 0)) + 1
                             INTO v_nordide
                             FROM per_personas
                            WHERE nnumide = x.nnumide
                              AND nnumide <> 'Z';

                           v_cont := 0;
                        END IF;
                     END IF;
                  ELSE
                     -- BUG 0020572 - FAL - 16/12/2011
                     IF pac_parametros.f_parempresa_n(vcempres, 'PER_NNUMIDE') = 1 THEN
                        SELECT COUNT(*)
                          INTO v_cont
                          FROM per_personas
                         WHERE nnumide = x.nnumide
                           AND nnumide <> 'Z';

                        IF v_cont > 0 THEN
--                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'W',
  --                                                     'Indice NNUMIDE ya existe en AXIS');
    --                    v_warning := TRUE;
    -- BUG 29553_0163699- 24/01/2014 - JLTS - Se adiciona condicion p.sperson =..
                           SELECT MIN(sperson)   --Bug 26569/164184 - 27/01/2014 - AMC
                             INTO v_sperson
                             FROM per_personas
                            WHERE nnumide = x.nnumide
                              AND nnumide <> 'Z';

                           UPDATE mig_personas
                              SET idperson = v_sperson
                            WHERE mig_pk = x.mig_pk;

                           v_existe := -1;
                        --                      COMMIT;
                        END IF;
                     -- Fi Bug 0020572
                     ELSIF NVL(pac_parametros.f_parempresa_n(vcempres, 'PER_NNUMIDE'), 0) = 2 THEN   --Permite duplicar nnumide, ctipide
                        SELECT COUNT(*)
                          INTO v_cont
                          FROM per_personas
                         WHERE nnumide = x.nnumide
                           AND ctipide = x.ctipide
                           AND nnumide <> 'Z';

                        IF v_cont > 0 THEN
--                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'W',
  --                                                     'Indice NNUMIDE ya existe en AXIS');
    --                    v_warning := TRUE;
                           SELECT MIN(sperson)   --Bug 26569/164184 - 27/01/2014 - AMC
                             INTO v_sperson
                             FROM per_personas
                            WHERE nnumide = x.nnumide
                              AND ctipide = x.ctipide
                              AND nnumide <> 'Z';

                           UPDATE mig_personas
                              SET idperson = v_sperson
                            WHERE mig_pk = x.mig_pk;

                           v_existe := -1;
--                           COMMIT;
                        END IF;
                     ELSE
                        --Se tiene que comprobar si ya existe por indice unico

                        -- FAL - error proceso carga 390628 por existir 2 personas con mismo NIF: 06254150J. Se comenta el siguiente IF f_parinstalacion_n('EMPRESADEF') <> 7 THEN
                        -- FAL - siempre recupere la persona filtrando por sexo y fnacimi, no sólo por nnumide. Se comenta el ELSE de abajo
                        --IF f_parinstalacion_n('EMPRESADEF') <> 7 THEN
                        SELECT COUNT(*)
                          INTO v_cont
                          FROM per_personas
                         WHERE nnumide = x.nnumide
                           AND nnumide <> 'Z'
                           -- Bug 0017569: CRT - Interfases y gestión personas. FAL. 02/03/2011. fnacimi y sexo pueden llegar nulo en cargas. Se añade NVL
                           AND NVL(fnacimi, TO_DATE('31/12/9999', 'dd/mm/yyyy')) =
                                            NVL(x.fnacimi, TO_DATE('31/12/9999', 'dd/mm/yyyy'))
                           AND NVL(csexper, 0) = NVL(x.csexper, 0);

                        /*
                        ELSE
                           SELECT COUNT(*)
                             INTO v_cont
                             FROM per_personas
                            WHERE nnumide = x.nnumide;
                        END IF;
                        */

                        -- Fi Bug 0017569
                        IF v_cont > 0 THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                           (pncarga, x.mig_pk, 'W',
                                            'Indice NNUMIDE+FNACIMI+CSEXPER ya existe en AXIS');
                           v_warning := TRUE;

                           -- IF f_parinstalacion_n('EMPRESADEF') <> 7 THEN   --'SOLO PARA CRT'
                           SELECT sperson
                             INTO v_sperson
                             FROM per_personas
                            WHERE nnumide = x.nnumide
                              -- Bug 0017569: CRT - Interfases y gestión personas. FAL. 02/03/2011. fnacimi y sexo pueden llegar nulo en cargas. Se añade NVL
                                  --AND fnacimi = x.fnacimi
                                  --AND csexper = x.csexper;
                              AND NVL(fnacimi, TO_DATE('31/12/9999', 'dd/mm/yyyy')) =
                                            NVL(x.fnacimi, TO_DATE('31/12/9999', 'dd/mm/yyyy'))
                              AND NVL(csexper, 0) = NVL(x.csexper, 0)
                              AND ROWNUM < 2;

                           /*
                           ELSE
                              SELECT sperson
                                INTO v_sperson
                                FROM per_personas
                               WHERE nnumide = x.nnumide;
                           END IF;
                           */
                           UPDATE mig_personas
                              SET idperson = v_sperson
                            WHERE mig_pk = x.mig_pk;

                           v_existe := -1;
--                           COMMIT;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               IF f_parinstalacion_t('TNOMCLI') IN('APRA LEVEN', 'CAIXA MANRESA')
                  AND v_cont = 0 THEN
                  IF f_parinstalacion_t('TNOMCLI') = 'CAIXA MANRESA' THEN
                     v_cont := f_persona_duplicada_cem(x.tapelli1, x.tapelli2, x.tnombre,
                                                       x.fnacimi, x.csexper, v_sperson);
                  ELSE
                     v_cont := f_persona_duplicada(x.tapelli1, x.tapelli2, x.tnombre,
                                                   x.fnacimi, x.csexper, v_sperson);
                  END IF;

                  IF v_cont <> 0 THEN
                     IF v_cont = 1 THEN
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'W',
                                                       'sperson : ' || v_sperson
                                                       || ' ya existe en AXIS');
                        v_warning := TRUE;

                        UPDATE mig_personas
                           SET idperson = v_sperson
                         WHERE mig_pk = x.mig_pk;
--                        COMMIT;
                     ELSE
                        num_err :=
                           f_ins_mig_logs_axis(pncarga, x.mig_pk, 'W',
                                               'Error en f_persona_duplicada, Error : '
                                               || v_cont);
                        v_warning := TRUE;
                        v_cont := 0;
                     END IF;
                  END IF;
               END IF;

               IF v_cont = 0
                  AND NOT v_existe < 0 THEN   --No existe cabecera con los datos de la persona. La creamos
                  -- 23289/120321 - JLB - 19/09/2012
                  IF ptablas = 'EST' THEN
                     SELECT spereal.NEXTVAL
                       INTO v_sperson
                       FROM DUAL;
                  ELSE
                     SELECT sperson.NEXTVAL
                       INTO v_sperson
                       FROM DUAL;
                  END IF;

                  -- 23289/120321 - JLB - 19/09/2012
                  IF x.nnumide = 'Z'
                     OR(x.nnumide IS NULL
                        AND x.snip IS NULL) THEN
                     --Si Z o numero identificativo es nulo y codigo terceros nulo, calculamos el numero identif.
                     v_nnumide := 'Z' || LPAD(v_sperson, 8, '0');
                  ELSIF x.nnumide IS NULL
                        AND x.snip IS NOT NULL THEN
                     --Si numero identificativo nulo y codigo terceros informado, se pone codigo terceros a numero identif.
                     v_nnumide := x.snip;
                  ELSE
                     v_nnumide := x.nnumide;
                  END IF;

                  IF x.snip IS NULL THEN
                     -- BUG 12374 - 16-12-2009 - JMC - Secuencia snip
                     --v_snip := v_sperson;
                     SELECT snip.NEXTVAL
                       INTO v_snip
                       FROM DUAL;
                  -- FIN BUG 12374 - 16-12-2009 - JMC
                  ELSE
                     v_snip := x.snip;
                  END IF;

                  IF v_1_personas THEN
                     v_1_personas := FALSE;
--                  v_1_detper := FALSE;
                     num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'PER_PERSONAS');
--                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -9, 'PER_DETPER');
--                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -6, 'PER_IDENTIFICADOR');
--                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -5, 'PER_CCC');
--                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -4,
--                                                       'PER_NACIONALIDADES');
                  END IF;

-- jlb -
                  IF x.tdigitoide IS NULL THEN
                     BEGIN
                        SELECT pac_parametros.f_parempresa_t(vcempres, 'PAC_IDE_PERSONA')
                          INTO v_propio
                          FROM DUAL;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_propio := NULL;
                     END;
                  ELSE
                     vdigitoide := x.tdigitoide;
                  END IF;

                  num_err := pac_persona.f_validanif(x.nnumide, x.ctipide, x.csexper,
                                                     x.fnacimi);

                  IF num_err <> 0 THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    f_axis_literales(num_err, f_idiomauser));
                     v_error := TRUE;
                  END IF;

                  IF v_propio IS NOT NULL
                     AND x.ctipide != 0 THEN
                     ss := 'BEGIN ' || ' :RETORNO :=  PAC_IDE_PERSONA.' || v_propio || '('
                           || x.ctipide || ', ''' || UPPER(v_nnumide) || ''')' || ';'
                           || 'END;';

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     v_cursor := DBMS_SQL.open_cursor;
                     DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
                     DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno, 20);
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     vdigitoide := retorno;
                  END IF;

                  -- BUG 0026350 - JMC - 03/04/2013
                  IF x.ctipide IN(36, 37)
                     AND x.tdigitoide IS NULL THEN
                     vdigitoide := NULL;
                  ELSE
                     IF vdigitoide IS NOT NULL
                        AND x.tdigitoide IS NOT NULL
                        AND vdigitoide <> x.tdigitoide THEN
                        num_err :=
                           f_ins_mig_logs_axis
                              (pncarga, x.mig_pk, 'E',
                               'Error en digito verificación: Enviado y calculado no coinciden'
                               || SQLCODE || '-' || SQLERRM);
                        v_error := TRUE;
                     END IF;
                  END IF;

                  -- BUG 0026350 - JMC - 03/04/2013
                  --  end if;
                  IF NOT v_error THEN
                     BEGIN
                        --Bug 29738/166356 - AMC - 21/01/2014
                        IF ptablas = 'EST' THEN
                           -- No. 49 - 05/05/2014 - JLTS
                           INSERT INTO estper_personas
                                       (sperson, nnumide, nordide, ctipide,
                                        csexper, fnacimi,
                                        cestper, fjubila, ctipper, cusuari, fmovimi,
                                        cmutualista, fdefunc, sseguro, snip, swpubli,
                                        tdigitoide, corigen, trecibido, cagente)
                                VALUES (v_sperson, v_nnumide, v_nordide, x.ctipide,
                                        DECODE(x.cpertip, 2, NULL, x.csexper), x.fnacimi,
                                        x.cestper, x.fjubila, x.cpertip, f_user, f_sysdate,
                                        NULL, x.fdefunc, NULL, v_snip, x.swpubli,
                                        vdigitoide, NULL, NULL, vcagente);

                           -- JLB - I - 18/02/2014
                           BEGIN
                              -- No. 49 - 05/05/2014 - JLTS
                              INSERT INTO estper_cargas
                                          (sperson, tipo, proceso, cagente,
                                           ccodigo, cusuari, fecha)
                                   VALUES (v_sperson, 'AP', NVL(x.proceso, 0), vcagente,
                                           NULL, f_user, f_sysdate);
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 NULL;   -- reprocesamiento
                           END;
                        ELSE
                           -- No. 49 - 05/05/2014 - JLTS
                           INSERT INTO per_personas
                                       (sperson, nnumide, nordide, ctipide,
                                        csexper, fnacimi,
                                        cestper, fjubila, ctipper, cusuari, fmovimi,
                                        cmutualista, fdefunc, snip, swpubli, tdigitoide,
                                        cagente)
                                VALUES (v_sperson, v_nnumide, v_nordide, x.ctipide,
                                        DECODE(x.cpertip, 2, NULL, x.csexper), x.fnacimi,
                                        x.cestper, x.fjubila, x.cpertip, f_user, f_sysdate,
                                        NULL, x.fdefunc, v_snip, x.swpubli, vdigitoide,
                                        vcagente);

                           -- JLB - I - 18/02/2014
                           BEGIN
                              -- No. 49 - 05/05/2014 - JLTS
                              INSERT INTO per_cargas
                                          (sperson, tipo, proceso, cagente,
                                           ccodigo, cusuari, fecha)
                                   VALUES (v_sperson, 'AP', NVL(x.proceso, 0), vcagente,
                                           NULL, f_user, f_sysdate);
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 NULL;   -- reprocesamiento
                           END;
                        END IF;

                        --Fi Bug 29738/166356 - AMC - 21/01/2014
                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -10, v_sperson);

                        UPDATE mig_personas
                           SET idperson = v_sperson,
                               nnumide = v_nnumide,
                               cestmig = 2 * v_existe
                         WHERE mig_pk = x.mig_pk;
--                     COMMIT;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                  'Error al insertar en PER_PERSONAS:'
                                                  || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;

               IF v_existe < 0 THEN   -- si la persona existia ya
                  IF x.cagente IS NULL THEN   -- miro si para la persona hay detalles el
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_detper
                      WHERE sperson = v_sperson
                        AND cagente = 1;
                  ELSE
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_detper
                      WHERE sperson = v_sperson
                        --AND ff_agente_cpervisio(cagente) = ff_agente_cpervisio(x.cagente);
                        AND cagente = x.cagente;
                  END IF;
               ELSE
                  v_cont := 0;
               END IF;

               --Detalle datos persona
               IF v_cont = 0
                  AND NOT v_error THEN
                  ---
                  IF x.cpertip = 2 THEN
                     v_tsiglas := x.tapelli1;
                  ELSE
                     v_tsiglas := NULL;
                  END IF;

                  -- BUG : 20003 - 05-11-2011 - JMC - Adaptación nombre compuesto
                  IF x.tnombre2 IS NULL THEN
                     v_tnombre := x.tnombre;
                  ELSE
                     v_tnombre := x.tnombre || ' ' || x.tnombre2;
                  END IF;

                  -- FIN BUG : 20003 - 05-11-2011 - JMC
                  IF v_1_detper THEN
                     v_1_detper := FALSE;
                     num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -9, 'PER_DETPER');
                  END IF;

                  BEGIN
                     -- Bug 29738/163540 - 21/01/2014 - AMC
                     IF ptablas = 'EST'
                        AND NOT v_existe < 0 THEN
                        INSERT INTO estper_detper
                                    (sperson, cagente, cidioma, tapelli1,
                                     tapelli2, tnombre, tsiglas, cprofes, tbuscar, cbancar,
                                     cctiban, cestciv, cpais,
                                     cusuari, fmovimi, tnombre1,
                                     tnombre2, cocupacion)
                             VALUES (v_sperson, NVL(x.cagente, '1'), x.cidioma, x.tapelli1,
                                     x.tapelli2, v_tnombre, v_tsiglas, x.cprofes, NULL, NULL,
                                     NULL, DECODE(x.cpertip, 2, NULL, x.cestciv), x.cpais,
                                     f_user, NVL(x.fultmod, f_sysdate), x.tnombre,
                                     x.tnombre2, x.cocupacion);

                        -- JLB - I - 18/02/2014
                        BEGIN
                           INSERT INTO estper_cargas
                                       (sperson, tipo, proceso, cagente, ccodigo,
                                        cusuari, fecha)
                                VALUES (v_sperson, 'ADP', NVL(x.proceso, 0), x.cagente, NULL,
                                        f_user, f_sysdate);
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              NULL;   -- reprocesamiento
                        END;
                     ELSE
                        INSERT INTO per_detper
                                    (sperson, cagente, cidioma, tapelli1,
                                     tapelli2, tnombre, tsiglas, cprofes, tbuscar,
                                     cestciv, cpais, cusuari,
                                     fmovimi, tnombre1, tnombre2,
                                     cocupacion)
                             VALUES (v_sperson, NVL(x.cagente, '1'), x.cidioma, x.tapelli1,
                                     x.tapelli2, v_tnombre, v_tsiglas, x.cprofes, NULL,
                                     DECODE(x.cpertip, 2, NULL, x.cestciv), x.cpais, f_user,
                                     NVL(x.fultmod, f_sysdate), x.tnombre, x.tnombre2,
                                     x.cocupacion);

                        -- JLB - I - 18/02/2014
                        BEGIN
                           INSERT INTO per_cargas
                                       (sperson, tipo, proceso, cagente, ccodigo,
                                        cusuari, fecha)
                                VALUES (v_sperson, 'ADP', NVL(x.proceso, 0), x.cagente, NULL,
                                        f_user, f_sysdate);
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              NULL;   -- reprocesamiento
                        END;
                     END IF;

                     -- Fi  Bug 29738/163540 - 21/01/2014 - AMC
                     INSERT INTO mig_pk_mig_axis
                          VALUES (x.mig_pk, pncarga, pntab, -9,
                                  v_sperson || '|' || NVL(x.cagente, '1'));

                     UPDATE mig_personas
                        SET cestmig = 3 * v_existe
                      WHERE mig_pk = x.mig_pk;
--                     COMMIT;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                       'Error al insertar en PER_DETPER:'
                                                       || SQLCODE || '-' || SQLERRM);
                        v_error := TRUE;
                        ROLLBACK;
                  END;
               END IF;

               -- IF x.ctipdir IS NOT NULL
                --   AND x.ctipdir2 IS NOT NULL THEN
                --   v_cont := 1;   --No vienen direcciones, v_cont=1 para que no cargue.
                --END IF;

               --v_cont := 0;
               IF x.ctipdir IS NOT NULL THEN
-- jlb - miro si la direcion ya existe antes de crearla
                  IF v_existe < 0 THEN   -- si la persona ya existia miro la direccion ya existe
                     IF NVL(pac_parametros.f_parempresa_n(vcempres, 'DUP_DIRECCION'), 1) = 1 THEN   --Permite duplicar direcciones si =0
                        v_cdomici :=
                           pac_persona.f_existe_direccion(v_sperson, NVL(x.cagente, '1'),
                                                          x.ctipdir, x.ctipvia, x.tnomvia,
                                                          x.nnumvia, x.tcomple,
                                                          pac_persona.f_tdomici(x.ctipvia,
                                                                                x.tnomvia,
                                                                                x.nnumvia,
                                                                                x.tcomple),
                                                          UPPER(x.cpostal), x.cpoblac,
                                                          x.cprovin);
                     ELSE
                        v_cdomici := NULL;
                     END IF;
                  ELSE
                     v_cdomici := NULL;
                  END IF;

                   --Direcciones
                  -- IF v_cont = 0
                  IF v_cdomici IS NULL   --jlb si no existe el domicilio
                     --      AND x.ctipdir IS NOT NULL
                     AND NOT v_error THEN
                     IF v_1_direcciones THEN
                        IF x.ctipdir IS NOT NULL THEN
                           v_1_direcciones := FALSE;
                           num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -8,
                                                                'PER_DIRECCIONES');
                        END IF;
                     END IF;

                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           ---
                           SELECT NVL(MAX(cdomici), 0) + 1
                             INTO v_cdomici
                             FROM estper_direcciones
                            WHERE sperson = v_sperson;

                           ---
                           INSERT INTO estper_direcciones
                                       (sperson, cagente, cdomici, ctipdir,
                                        csiglas, tnomvia, nnumvia, tcomple,
                                        tdomici,
                                        cpostal, cpoblac, cprovin, cusuari, fmovimi)
                                VALUES (v_sperson, NVL(x.cagente, '1'), v_cdomici, x.ctipdir,
                                        x.ctipvia, x.tnomvia, x.nnumvia, x.tcomple,
                                        pac_persona.f_tdomici(x.ctipvia, x.tnomvia, x.nnumvia,
                                                              x.tcomple),
                                        x.cpostal, x.cpoblac, x.cprovin, f_user, f_sysdate);

                           -- JLB - I - 18/02/2014
                           BEGIN
                              INSERT INTO estper_cargas
                                          (sperson, tipo, proceso, cagente,
                                           ccodigo, cusuari, fecha)
                                   VALUES (v_sperson, 'AD', NVL(x.proceso, 0), x.cagente,
                                           v_cdomici, f_user, f_sysdate);
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 NULL;   -- reprocesamiento
                           END;
                        ELSE
                           SELECT NVL(MAX(cdomici), 0) + 1
                             INTO v_cdomici
                             FROM per_direcciones
                            WHERE sperson = v_sperson;

                           ---
                           INSERT INTO per_direcciones
                                       (sperson, cagente, cdomici, ctipdir,
                                        csiglas, tnomvia, nnumvia, tcomple,
                                        tdomici,
                                        cpostal, cpoblac, cprovin, cusuari, fmovimi)
                                VALUES (v_sperson, NVL(x.cagente, '1'), v_cdomici, x.ctipdir,
                                        x.ctipvia, x.tnomvia, x.nnumvia, x.tcomple,
                                        pac_persona.f_tdomici(x.ctipvia, x.tnomvia, x.nnumvia,
                                                              x.tcomple),
                                        x.cpostal, x.cpoblac, x.cprovin, f_user, f_sysdate);

                           -- JLB - I - 18/02/2014
                           BEGIN
                              INSERT INTO per_cargas
                                          (sperson, tipo, proceso, cagente,
                                           ccodigo, cusuari, fecha)
                                   VALUES (v_sperson, 'AD', NVL(x.proceso, 0), x.cagente,
                                           v_cdomici, f_user, f_sysdate);
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 NULL;   -- reprocesamiento
                           END;
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -8,
                                     v_sperson || '|' || v_cdomici);

                        UPDATE mig_personas
                           SET cestmig = 4 * v_existe
                         WHERE mig_pk = x.mig_pk;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'E',
                                                 'Error al insertar en PER_DIRECCIONES(1):'
                                                 || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;

-- jlb guardo la direccio en la tabla de mig_seguros si existe referencia, solo pongo por defecto la primera direccion
-- la segunda la guardaria pero no la pondria como defecto
                  BEGIN
                     UPDATE mig_seguros   -- si es el tomador
                        SET cdomici = v_cdomici
                      WHERE mig_fk = x.mig_pk
                        AND ncarga = pncarga
                        AND cdomici IS NULL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;   --
                  END;

                  BEGIN
                     UPDATE mig_asegurados   -- si es el asegurado
                        SET cdomici = v_cdomici
                      WHERE mig_fk = x.mig_pk
                        AND ncarga = pncarga
                        AND cdomici IS NULL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;   --
                  END;
               END IF;   -- x.ctipdir 1

-- jlb - miro si existe la segunda direcion ya existe antes de crearla
               IF x.ctipdir2 IS NOT NULL THEN
                  IF v_existe < 0 THEN
                     IF NVL(pac_parametros.f_parempresa_n(vcempres, 'DUP_DIRECCION'), 1) = 1 THEN   --Permite duplicar direcciones si =0
                        v_cdomici :=
                           pac_persona.f_existe_direccion(v_sperson, NVL(x.cagente, '1'),
                                                          x.ctipdir2, x.ctipvia2, x.tnomvia2,
                                                          x.nnumvia2, x.tcomple2,
                                                          pac_persona.f_tdomici(x.ctipvia2,
                                                                                x.tnomvia2,
                                                                                x.nnumvia2,
                                                                                x.tcomple2),
                                                          UPPER(x.cpostal2), x.cpoblac2,
                                                          x.cprovin2);
                     ELSE
                        v_cdomici := NULL;
                     END IF;
                  ELSE
                     v_cdomici := NULL;
                  END IF;

                  -- IF v_cont = 0
                  IF v_cdomici IS NULL
                                         -- jlb si no existe la direccion la creo
                     --       AND x.ctipdir2 IS NOT NULL
                     AND NOT v_error THEN
                     IF v_1_direcciones THEN
                        IF x.ctipdir2 IS NOT NULL THEN
                           v_1_direcciones := FALSE;
                           num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -8,
                                                                'PER_DIRECCIONES');
                        END IF;
                     END IF;

                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           SELECT NVL(MAX(cdomici), 0) + 1
                             INTO v_cdomici
                             FROM estper_direcciones
                            WHERE sperson = v_sperson;

                           INSERT INTO estper_direcciones
                                       (sperson, cagente, cdomici, ctipdir,
                                        csiglas, tnomvia, nnumvia, tcomple,
                                        tdomici,
                                        cpostal, cpoblac, cprovin, cusuari, fmovimi)
                                VALUES (v_sperson, NVL(x.cagente, '1'), v_cdomici, x.ctipdir2,
                                        x.ctipvia2, x.tnomvia2, x.nnumvia2, x.tcomple2,
                                        pac_persona.f_tdomici(x.ctipvia2, x.tnomvia2,
                                                              x.nnumvia2, x.tcomple2),
                                        x.cpostal2, x.cpoblac2, x.cprovin2, f_user, f_sysdate);

                           -- JLB - I - 18/02/2014
                           BEGIN
                              INSERT INTO estper_cargas
                                          (sperson, tipo, proceso, cagente,
                                           ccodigo, cusuari, fecha)
                                   VALUES (v_sperson, 'AD', NVL(x.proceso, 0), x.cagente,
                                           v_cdomici, f_user, f_sysdate);
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 NULL;   -- reprocesamiento
                           END;
                        ELSE
                           ---
                           SELECT NVL(MAX(cdomici), 0) + 1
                             INTO v_cdomici
                             FROM per_direcciones
                            WHERE sperson = v_sperson;

                           INSERT INTO per_direcciones
                                       (sperson, cagente, cdomici, ctipdir,
                                        csiglas, tnomvia, nnumvia, tcomple,
                                        tdomici,
                                        cpostal, cpoblac, cprovin, cusuari, fmovimi)
                                VALUES (v_sperson, NVL(x.cagente, '1'), v_cdomici, x.ctipdir2,
                                        x.ctipvia2, x.tnomvia2, x.nnumvia2, x.tcomple2,
                                        pac_persona.f_tdomici(x.ctipvia2, x.tnomvia2,
                                                              x.nnumvia2, x.tcomple2),
                                        x.cpostal2, x.cpoblac2, x.cprovin2, f_user, f_sysdate);

                           BEGIN
                              INSERT INTO per_cargas
                                          (sperson, tipo, proceso, cagente,
                                           ccodigo, cusuari, fecha)
                                   VALUES (v_sperson, 'AD', NVL(x.proceso, 0), x.cagente,
                                           v_cdomici, f_user, f_sysdate);
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 NULL;   -- reprocesamiento
                           END;
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -8,
                                     v_sperson || '|' || v_cdomici);

                        UPDATE mig_personas
                           SET cestmig = 5 * v_existe
                         WHERE mig_pk = x.mig_pk;
                     --                      COMMIT;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'E',
                                                 'Error al insertar en PER_DIRECCIONES(1):'
                                                 || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;   -- x.ctipdir

               IF x.cbancar IS NOT NULL THEN
                  IF x.ctipban IS NOT NULL THEN
                     BEGIN
                        SELECT LPAD(cbanco, long_entidad, '0') || x.cbancar
                          INTO x.cbancar
                          FROM tipos_cuenta
                         WHERE ctipban = x.ctipban
                           AND cbanco IS NOT NULL
                           AND long_entidad IS NOT NULL;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;   -- sino encuenta dejo la ceutna como estaba.
                     END;
                  END IF;

                  IF v_existe < 0 THEN
                     IF x.cagente IS NULL THEN
                        SELECT COUNT(*)
                          INTO v_cont
                          FROM per_ccc
                         WHERE sperson = v_sperson
                           AND cagente = 1
                           AND ctipban = NVL(x.ctipban, ctipban)
                           AND cbancar = x.cbancar;
                     ELSE
                        SELECT COUNT(*)
                          INTO v_cont
                          FROM per_ccc
                         WHERE sperson = v_sperson
                           --AND ff_agente_cpervisio(cagente) = ff_agente_cpervisio(x.cagente);
                           AND cagente = x.cagente
                           AND ctipban = NVL(x.ctipban, ctipban)
                           AND cbancar = x.cbancar;
                     END IF;
                  ELSE
                     v_cont := 0;
                  END IF;

                  -- 23289/120321 - ECP - 05/09/2012 Fin
                  IF v_cont = 0 THEN
                     v_cont := 1;

                     IF v_1_ccc THEN
                        v_1_ccc := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -5, 'PER_CCC');
                     END IF;

                     DECLARE
                        vcnordban      per_ccc.cnordban%TYPE := 1;
                     BEGIN
                        -- Bug 29738/163540 - 21/01/2014 - AMC
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           INSERT INTO estper_ccc
                                       (sperson, cagente, ctipban, cbancar,
                                        fbaja, cdefecto, cusumov, fusumov, cnordban, fvencim)
                                VALUES (v_sperson, NVL(x.cagente, '1'), x.ctipban, x.cbancar,
                                        NULL, 1, f_user, f_sysdate, vcnordban, x.fvencim);

                           -- JLB - I - 18/02/2014
                           BEGIN
                              INSERT INTO estper_cargas
                                          (sperson, tipo, proceso,
                                           cagente, ccodigo, cusuari, fecha)
                                   VALUES (v_sperson, 'ACB', NVL(x.proceso, 0),
                                           NVL(x.cagente, '1'), vcnordban, f_user, f_sysdate);
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 NULL;   -- reprocesamiento
                           END;
                        ELSE
                           --
                           BEGIN
                              SELECT NVL(MAX(cnordban), 0) + 1
                                INTO vcnordban
                                FROM per_ccc
                               WHERE sperson = v_sperson;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 vcnordban := 1;
                           END;

                           INSERT INTO per_ccc
                                       (sperson, cagente, ctipban, cbancar,
                                        fbaja, cdefecto, cusumov, fusumov, cnordban, fvencim)
                                VALUES (v_sperson, NVL(x.cagente, '1'), x.ctipban, x.cbancar,
                                        NULL, 1, f_user, f_sysdate, vcnordban, x.fvencim);

                           -- I - JLB - 18/02/2014
                           BEGIN
                              INSERT INTO per_cargas
                                          (sperson, tipo, proceso,
                                           cagente, ccodigo, cusuari, fecha)
                                   VALUES (v_sperson, 'ACB', NVL(x.proceso, 0),
                                           NVL(x.cagente, '1'), vcnordban, f_user, f_sysdate);
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 NULL;   -- reprocesamiento
                           END;
                        END IF;

                        -- Fi Bug 29738/163540 - 21/01/2014 - AMC
                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -5, v_sperson || '|vcnordban');
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'E',
                                                 'Error al insertar en PER_DIRECCIONES(1):'
                                                 || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               --  END IF;
               END IF;   -- cbancar

               --Teléfono
               IF TRIM(x.tnumtel) IS NOT NULL
                  AND NOT v_error THEN
                  IF v_existe < 0 THEN
                     SELECT COUNT(1)
                       INTO v_cont
                       FROM per_contactos
                      WHERE sperson = v_sperson
                        AND cagente = NVL(x.cagente, 1)
                        AND ctipcon = 1
                        AND f_strstd_mig(tvalcon) = f_strstd_mig(x.tnumtel);
                  ELSE
                     v_cont := 0;
                  END IF;

                  IF v_cont = 0 THEN
                     IF v_1_contactos THEN
                        v_1_contactos := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -7,
                                                             'PER_CONTACTOS');
                     END IF;

                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM estper_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO estper_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 1,
                                           NULL, x.tnumtel, f_user, f_sysdate, 0);
                           END IF;
                        ELSE
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM per_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO per_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 1,
                                           NULL, x.tnumtel, f_user, f_sysdate, 0);
                           END IF;
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -7,
                                     v_sperson || '|' || v_cmodcon);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                            (pncarga, x.mig_pk, 'E',
                                             'Error al insertar en PER_CONTACTOS(tnumtel):'
                                             || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;

               --Fax
               IF TRIM(x.tnumfax) IS NOT NULL
                  AND NOT v_error THEN
                  IF v_existe < 0 THEN
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_contactos
                      WHERE sperson = v_sperson
                        AND cagente = NVL(x.cagente, 1)
                        AND ctipcon = 2
                        AND f_strstd_mig(tvalcon) = f_strstd_mig(x.tnumfax);
                  ELSE
                     v_cont := 0;
                  END IF;

                  IF v_cont = 0 THEN
                     IF v_1_contactos THEN
                        v_1_contactos := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -7,
                                                             'PER_CONTACTOS');
                     END IF;

                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM estper_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO estper_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 2,
                                           NULL, x.tnumfax, f_user, f_sysdate, 0);
                           END IF;
                        ELSE
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM per_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO per_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 2,
                                           NULL, x.tnumfax, f_user, f_sysdate, 0);
                           END IF;
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -7,
                                     v_sperson || '|' || v_cmodcon);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                            (pncarga, x.mig_pk, 'E',
                                             'Error al insertar en PER_CONTACTOS(tnumfax):'
                                             || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;

               --Móvil
               IF TRIM(x.tnummov) IS NOT NULL
                  AND NOT v_error THEN
                  -- Bug 0014185 - JMF - 25/05/2010
                  IF v_existe < 0 THEN
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_contactos
                      WHERE sperson = v_sperson
                        AND cagente = NVL(x.cagente, 1)
                        AND ctipcon = 5
                        AND f_strstd_mig(tvalcon) = f_strstd_mig(x.tnummov);
                  ELSE
                     v_cont := 0;
                  END IF;

                  IF v_cont = 0 THEN
                     IF v_1_contactos THEN
                        v_1_contactos := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -7,
                                                             'PER_CONTACTOS');
                     END IF;

                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM estper_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO estper_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 5,
                                           NULL, x.tnummov, f_user, f_sysdate, 0);
                           END IF;
                        ELSE
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM per_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO per_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 5,
                                           NULL, x.tnummov, f_user, f_sysdate, 0);
                           END IF;
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -7,
                                     v_sperson || '|' || v_cmodcon);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                            (pncarga, x.mig_pk, 'E',
                                             'Error al insertar en PER_CONTACTOS(tnummov):'
                                             || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;

               --Mail
               IF TRIM(x.temail) IS NOT NULL
                  AND NOT v_error THEN
                  IF v_existe < 0 THEN
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_contactos
                      WHERE sperson = v_sperson
                        AND cagente = NVL(x.cagente, 1)
                        AND ctipcon = 3
                        AND f_strstd_mig(tvalcon) = f_strstd_mig(x.temail);
                  ELSE
                     v_cont := 0;
                  END IF;

                  IF v_cont = 0 THEN
                     IF v_1_contactos THEN
                        v_1_contactos := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -7,
                                                             'PER_CONTACTOS');
                     END IF;

                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM estper_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO estper_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 3,
                                           NULL, x.temail, f_user, f_sysdate, 0);
                           END IF;
                        ELSE
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM per_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO per_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 3,
                                           NULL, x.temail, f_user, f_sysdate, 0);
                           END IF;
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -7,
                                     v_sperson || '|' || v_cmodcon);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                             (pncarga, x.mig_pk, 'E',
                                              'Error al insertar en PER_CONTACTOS(temail):'
                                              || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;

               UPDATE mig_personas
                  SET cestmig = 6 * v_existe
                WHERE mig_pk = x.mig_pk;

               --              COMMIT;

               --Identificador
               IF v_nnumide IS NOT NULL
                  AND NOT v_error THEN
                  IF v_existe < 0 THEN
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_identificador
                      WHERE sperson = v_sperson
                        AND cagente = NVL(x.cagente, 1)
                        AND ctipide = x.ctipide;
                  ELSE
                     v_cont := 0;
                  END IF;

                  IF v_cont = 0 THEN
                     IF v_1_ident THEN
                        v_1_ident := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -6,
                                                             'PER_IDENTIFICADOR');
                     END IF;

                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           INSERT INTO estper_identificador
                                       (sperson, cagente, ctipide, nnumide,
                                        swidepri, femisio, fcaduca)
                                VALUES (v_sperson, NVL(x.cagente, '1'), x.ctipide, v_nnumide,
                                        1, f_sysdate, NULL);
                        ELSE
                           INSERT INTO per_identificador
                                       (sperson, cagente, ctipide, nnumide,
                                        swidepri, femisio, fcaduca)
                                VALUES (v_sperson, NVL(x.cagente, '1'), x.ctipide, v_nnumide,
                                        1, f_sysdate, NULL);
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -6,
                                     v_sperson || '|' || NVL(x.cagente, '1') || '|'
                                     || x.ctipide);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                                 (pncarga, x.mig_pk, 'E',
                                                  'Error al insertar en PER_IDENTIFICADOR:'
                                                  || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;

               --Segundo Identificador
               IF x.ctipide2 IS NOT NULL
                  AND x.nnumide2 IS NOT NULL
                  AND NOT v_error THEN
                  IF v_existe < 0
                     OR ptablas <> 'EST' THEN
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_identificador
                      WHERE sperson = v_sperson
                        AND cagente = NVL(x.cagente, 1)
                        AND ctipide = x.ctipide2;
                  ELSE
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM estper_identificador
                      WHERE sperson = v_sperson
                        AND cagente = NVL(x.cagente, 1)
                        AND ctipide = x.ctipide2;
                  END IF;

                  IF v_cont = 0 THEN
                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           INSERT INTO estper_identificador
                                       (sperson, cagente, ctipide,
                                        nnumide, swidepri, femisio, fcaduca)
                                VALUES (v_sperson, NVL(x.cagente, '1'), x.ctipide2,
                                        x.nnumide2, 1, f_sysdate, NULL);
                        ELSE
                           INSERT INTO per_identificador
                                       (sperson, cagente, ctipide,
                                        nnumide, swidepri, femisio, fcaduca)
                                VALUES (v_sperson, NVL(x.cagente, '1'), x.ctipide2,
                                        x.nnumide2, 1, f_sysdate, NULL);
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -6,
                                     v_sperson || '|' || NVL(x.cagente, '1') || '|'
                                     || x.ctipide2);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                              (pncarga, x.mig_pk, 'E',
                                               'Error al insertar en PER_IDENTIFICADOR(2):'
                                               || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;

               IF ptablas = 'EST'
                  AND NOT v_existe < 0 THEN
                  num_err := f_migra_direcciones(pncarga, pntab, 'EST',
                                                 -- estamos en las reales
                                                 x.mig_pk);
               ELSE
                  num_err := f_migra_direcciones(pncarga, pntab, 'POL',
                                                 -- estamos en las reales
                                                 x.mig_pk);
               END IF;

               IF num_err <> 0 THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error f_migra_direcciones(PER):' || num_err
                                                 || '-' || SQLERRM);
                  v_error := TRUE;
                  ROLLBACK;
               END IF;

               --Nacionalidad
               IF x.cnacio IS NOT NULL
                  AND NOT v_error
                  AND x.cpertip <> 2 THEN
                  IF v_existe < 0 THEN
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_nacionalidades
                      WHERE sperson = v_sperson
                        AND cagente = NVL(x.cagente, 1)
                        AND cpais = x.cnacio;
                  ELSE
                     v_cont := 0;
                  END IF;

                  IF v_cont = 0 THEN
                     IF v_1_nacio THEN
                        v_1_nacio := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -4,
                                                             'PER_NACIONALIDADES');
                     END IF;

                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           INSERT INTO estper_nacionalidades
                                       (sperson, cagente, cpais, cdefecto)
                                VALUES (v_sperson, NVL(x.cagente, '1'), x.cnacio, 1);
                        ELSE
                           INSERT INTO per_nacionalidades
                                       (sperson, cagente, cpais, cdefecto)
                                VALUES (v_sperson, NVL(x.cagente, '1'), x.cnacio, 1);
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -4,
                                     v_sperson || '|' || NVL(x.cagente, '1') || '|' || x.cnacio);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                                 (pncarga, x.mig_pk, 'E',
                                                  'Error al insertar en PER_IDENTIFICADOR:'
                                                  || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;

               -- Antiguedad
               -- Bug 29738/163540 - 21/01/2014 - AMC
               IF x.fantiguedad IS NOT NULL
                  AND NOT v_error THEN
                  IF v_existe < 0 THEN
                     SELECT COUNT(*)
                       INTO v_cont
                       FROM per_antiguedad
                      WHERE sperson = v_sperson;
                  ELSE
                     v_cont := 0;
                  END IF;

                  IF v_cont = 0 THEN
                     IF v_1_antiguedad THEN
                        v_1_antiguedad := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -3,
                                                             'PER_ANTIGUEDAD');
                     END IF;

                     BEGIN
                        IF ptablas = 'EST'
                           AND NOT v_existe < 0 THEN
                           INSERT INTO estper_antiguedad
                                       (sperson, cagrupa, norden, fantiguedad, cestado)
                                VALUES (v_sperson, 1, 1, x.fantiguedad, 0);
                        ELSE
                           INSERT INTO per_antiguedad
                                       (sperson, cagrupa, norden, fantiguedad, cestado)
                                VALUES (v_sperson, 1, 1, x.fantiguedad, 0);
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -3,
                                     v_sperson || '|' || x.fantiguedad);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                  'Error al insertar en PER_ANTIGUEDAD:'
                                                  || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;
               END IF;

               -- Fi Bug 29738/163540 - 21/01/2014 - AMC
               IF NOT v_error THEN
                  UPDATE mig_personas
                     SET cestmig = 9 * v_existe
                   WHERE mig_pk = x.mig_pk;
--                  COMMIT;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error:' || SQLCODE || '-' || SQLERRM || ' linea: '|| dbms_utility.format_error_backtrace);


                  v_error := TRUE;
                  ROLLBACK;
            END;

--
  -- Lo envio a la interfaz de personas....
          -- Bug 14365. FAL. 15/11/2010
            IF ptablas NOT IN('EST', 'PER') THEN   -- si estoy en las est no envio a HOST lo hara cuando se traspasen a las reales.
                                                   -- Si estoy cargando personas masivamente no envio a host
               DECLARE
                  vcterminal     usuarios.cterminal%TYPE;
                  psinterf       NUMBER;
                  terror         VARCHAR2(300);
                  sw_envio_rut   NUMBER(1) := 0;   --siempre lo envio
               BEGIN
                  IF vdigitoide IS NOT NULL THEN
                     sw_envio_rut := 1;
                  END IF;

                  ndiferido := NVL(pac_parametros.f_parempresa_n(vcempres, 'ALTA_PERSONA_DIFE'),
                                   0);

                  IF NVL(pac_parametros.f_parempresa_n(vcempres, 'ALTA_PERSONA_HOST'), 0) = 1
                     AND NVL(pac_parametros.f_parempresa_n(vcempres, 'SIN_PERSONA_MIG'), 1) = 1
                                                                                               -- AND NVL(reg.corigen, 0) <> 'INT' -- no llega por interfaz
                                                                                                --AND waccion = 'INSERT')   -- es insert seguro
                  THEN
                     num_err := pac_user.f_get_terminal(f_user, vcterminal);
                     -- INI RLLF 15042015 Alta de personas.
					 /* Cambios de IAXIS-4844 : start */
                     num_err := pac_con.f_alta_persona(vcempres, v_sperson, vcterminal,
                                                       psinterf, terror,
                                                       NVL(pac_md_common.f_get_cxtusuario,
                                                           f_user),
                                                       1, 'ALTA', vdigitoide, NULL, ndiferido);
					/* Cambios de IAXIS-4844 : end */
                     -- FIN RLLF 15042015 Alta de personas.
                     IF num_err <> 0 THEN
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'W',
                                                       'Warning:' || terror);
                     END IF;

                     -- BUG 21270/106644 - 08/02/2012 - JMP - Grabamos otro mensaje con NNUMIDE||TDIGITOIDE
                     IF sw_envio_rut = 1 THEN
						/* Cambios de IAXIS-4844 : start */
                        num_err :=
                           pac_con.f_alta_persona(vcempres, v_sperson, vcterminal, psinterf,
                                                  terror,
                                                  NVL(pac_md_common.f_get_cxtusuario, f_user),
                                                  1, 'ALTA', vdigitoide);
						/* Cambios de IAXIS-4844 : end */

                        IF num_err <> 0 THEN
                           num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'W',
                                                          'Warning:' || terror);
                        END IF;
                     END IF;
                  -- FIN BUG 21270/106644 - 08/02/2012 - JMP -
                  END IF;
               END;
            END IF;

            --
            IF ptablas = 'EST'
               AND v_existe < 0 THEN   -- si estoy en la est y la persona ya existia la recupero de las reales
               pac_persona.traspaso_tablas_per(v_sperson, v_spersonest, NULL, x.cagente);

               UPDATE mig_personas
                  SET idperson = v_spersonest
                WHERE mig_pk = x.mig_pk;
            END IF;
-- JLB - E- traspaso la persona a las tablas est
   --         COMMIT;
         END IF;   -- not vexiste = -2

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSIF v_warning THEN
         v_estdes := 'WARNING';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_personas;

   -- BUG 10054 - 22-10-2009 - JMC - Función para la migración de la tabla PER_PARPERSONAS

   /***************************************************************************
      FUNCTION f_migra_parpersonas
      Función que inserta los registros grabados en MIG_PARPERSONAS, en la
      tabla de parametros de personas de AXIS. (PER_PARPERSONAS)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_parpersonas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      --v_sperson      per_personas.sperson%TYPE;
      --v_cdomici      agentes.cdomici%TYPE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_parper     BOOLEAN := TRUE;
      --v_cempres      mig_cargas.cempres%TYPE;
      v_nvalpar      per_parpersonas.nvalpar%TYPE;
      v_tvalpar      per_parpersonas.tvalpar%TYPE;
      v_fvalpar      per_parpersonas.fvalpar%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, p.idperson p_sperson, p.cagente
                    FROM mig_parpersonas a, mig_personas p
                   WHERE p.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_parper THEN
               v_1_parper := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'PER_PARPERSONAS');
            END IF;

            v_nvalpar := NULL;
            v_tvalpar := NULL;
            v_fvalpar := NULL;

            IF x.tipval = 1 THEN
               v_nvalpar := TO_NUMBER(x.valval);
            ELSIF x.tipval = 2 THEN
               v_tvalpar := x.valval;
            ELSIF x.tipval = 3 THEN
               v_fvalpar := TO_DATE(x.valval, 'YYYYMMDD');
            END IF;

            BEGIN
               INSERT INTO per_parpersonas
                           (cparam, sperson, cagente, nvalpar, tvalpar, fvalpar)
                    VALUES (x.cparam, x.p_sperson, x.cagente, v_nvalpar, v_tvalpar, v_fvalpar);

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, -10,
                            x.cparam || '|' || x.p_sperson || '|' || x.cagente);

               UPDATE mig_parpersonas
                  SET cestmig = 2
                WHERE mig_pk = x.mig_pk;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error:' || SQLCODE || '-' || SQLERRM);
                  v_error := TRUE;
                  ROLLBACK;
            END;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_parpersonas;

-- FIN BUG 10054 - 22-10-2009 - JMC
/***************************************************************************
      FUNCTION f_migra_agentes
      Función que inserta las personas grabadas en MIG_AGENTES, en las distintas
      tablas de agentes de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_agentes(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_sperson      per_personas.sperson%TYPE;
      --
      v_cdomici      agentes.cdomici%TYPE;
      --
      v_cagente      mig_personas.cagente%TYPE;
      v_ctipdir      mig_personas.ctipdir%TYPE;
      v_ctipvia      mig_personas.ctipvia%TYPE;
      v_tnomvia      mig_personas.tnomvia%TYPE;
      v_nnumvia      mig_personas.nnumvia%TYPE;
      v_tcomple      mig_personas.tcomple%TYPE;
      v_cpostal      mig_personas.cpostal%TYPE;
      v_cpoblac      mig_personas.cpoblac%TYPE;
      v_cprovin      mig_personas.cprovin%TYPE;
      v_ctipban      mig_personas.ctipban%TYPE;
      v_cbancar      mig_personas.cbancar%TYPE;
      --
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_agentes    BOOLEAN := TRUE;
      v_cempres      mig_cargas.cempres%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      --Obtenemos la empresa
      SELECT cempres
        INTO v_cempres
        FROM mig_cargas
       WHERE ncarga = pncarga;

      FOR x IN (SELECT   a.*
                    FROM mig_agentes a
                   WHERE ncarga = pncarga
                     AND cestmig = 1
                ORDER BY ctipage, mig_pk) LOOP
         BEGIN
            IF v_1_agentes THEN
               v_1_agentes := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'AGENTES');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 2, 'REDCOMERCIAL');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 3, 'CONTRATOSAGE');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 4, 'COMISIONVIG_AGENTE');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 5, 'AGENTES_COMP');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 6, 'AGEREDCOM');
            END IF;

            --Obtenemos el sperson
            SELECT idperson, ctipban, cbancar, ctipdir, ctipvia, tnomvia,
                   nnumvia, tcomple, cpostal, cpoblac, cprovin, cagente
              INTO v_sperson, v_ctipban, v_cbancar, v_ctipdir, v_ctipvia, v_tnomvia,
                   v_nnumvia, v_tcomple, v_cpostal, v_cpoblac, v_cprovin, v_cagente
              FROM mig_personas
             WHERE mig_pk = x.mig_fk
                                    --AND ncarga = pncarga
            ;

            BEGIN
               v_cdomici := pac_persona.f_existe_direccion(v_sperson, NVL(v_cagente, '1'),
                                                           v_ctipdir, v_ctipvia, v_tnomvia,
                                                           v_nnumvia, v_tcomple,
                                                           pac_persona.f_tdomici(v_ctipvia,
                                                                                 v_tnomvia,
                                                                                 v_nnumvia,
                                                                                 v_tcomple),
                                                           UPPER(v_cpostal), v_cpoblac,
                                                           v_cprovin);
            /*               SELECT cdomici
                            INTO v_cdomici
                            FROM per_direcciones
                           WHERE sperson = v_sperson
                             AND cdomici = 1; */
            EXCEPTION
               WHEN OTHERS THEN
                  v_cdomici := NULL;
            END;

            INSERT INTO agentes
                        (cagente, cretenc, ctipiva, sperson,
                         ccomisi, ctipage, cactivo, cdomici, cbancar, ncolegi,
                         fbajage, csoprec, cmediop, ccuacoa, tobserv, nmescob, cretliq,
                         cpseudo, ccodcon, ctipban, csobrecomisi, talias, cliquido, nregdgs)
                 VALUES (x.cagente, NVL(x.cretenc, 0), NVL(x.ctipiva, 0), v_sperson,
                         NVL(x.ccomisi, 0), x.ctipage, x.cactivo, v_cdomici, v_cbancar, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, v_ctipban, x.csobrecomisi, x.talias, x.cliquido, x.nregdgs);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, x.cagente);

            UPDATE mig_agentes
               SET idperson = v_sperson,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;

            ---
            INSERT INTO redcomercial
                        (cempres, cagente, fmovini, fmovfin, ctipage,
                         cpadre, cusualt, falta, cusumod, fmodifi, ccomindt, cpervisio,
                         cpernivel, cpolvisio, cpolnivel)
                 VALUES (TO_NUMBER(v_cempres), x.cagente, x.fmovini, NULL, x.ctipage,
                         x.cpadre, f_user, f_sysdate, f_user, f_sysdate, 0, x.cpervisio,
                         x.cpernivel, x.cpolvisio, x.cpolnivel);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 2,
                         TO_NUMBER(v_cempres) || '|' || x.cagente || '|'
                         || TO_CHAR(x.fmovini, 'yyyymmdd'));

            UPDATE mig_agentes
               SET idperson = v_sperson,
                   cestmig = 3
             WHERE mig_pk = x.mig_pk;

            ----
            INSERT INTO contratosage
                        (cempres, cagente, ncontrato, ffircon, iobjeti, ccontfir)
                 VALUES (TO_NUMBER(v_cempres), x.cagente, 0, x.fmovini, NULL, NULL);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 3, TO_NUMBER(v_cempres) || '|' || x.cagente);

            UPDATE mig_agentes
               SET idperson = v_sperson,
                   cestmig = 4
             WHERE mig_pk = x.mig_pk;

            ----
            IF x.finivig IS NOT NULL THEN
               INSERT INTO comisionvig_agente
                           (cagente, ccomisi, finivig)
                    VALUES (x.cagente, x.ccomisi, x.finivig);

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 4,
                            x.cagente || '|' || x.ccomisi || '|'
                            || TO_CHAR(x.finivig, 'yyyymmdd'));

               UPDATE mig_agentes
                  SET idperson = v_sperson,
                      cestmig = 4
                WHERE mig_pk = x.mig_pk;
            END IF;

            IF x.ctipadn IS NOT NULL
               OR x.cagedep IS NOT NULL
               OR x.ctipint IS NOT NULL
               OR x.cageclave IS NOT NULL
               OR x.cofermercan IS NOT NULL
               OR x.frecepcontra IS NOT NULL
               OR x.cidoneidad IS NOT NULL
               OR x.spercomp IS NOT NULL
               OR x.ccompani IS NOT NULL
               OR x.cofipropia IS NOT NULL
               OR x.cclasif IS NOT NULL
               OR x.nplanpago IS NOT NULL
               OR x.nnotaria IS NOT NULL
               OR x.cprovin IS NOT NULL
               OR x.cpoblac IS NOT NULL
               OR x.nescritura IS NOT NULL
               OR x.faltasoc IS NOT NULL
               OR x.tgerente IS NOT NULL
               OR x.tcamaracomercio IS NOT NULL
               OR x.csobrecomisi IS NOT NULL
               OR x.talias IS NOT NULL
               OR x.cliquido IS NOT NULL THEN
               INSERT INTO agentes_comp
                           (cagente, ctipadn, cagedep, ctipint, cageclave,
                            cofermercan, frecepcontra, cidoneidad, spercomp,
                            ccompani, cofipropia, cclasif, nplanpago, nnotaria,
                            cprovin, cpoblac, nescritura, faltasoc, tgerente,
                            tcamaracomercio)
                    VALUES (x.cagente, x.ctipadn, x.cagedep, x.ctipint, x.cageclave,
                            x.cofermercan, x.frecepcontra, x.cidoneidad, x.spercomp,
                            x.ccompani, x.cofipropia, x.cclasif, x.nplanpago, x.nnotaria,
                            x.cprovin, x.cpoblac, x.nescritura, x.faltasoc, x.tgerente,
                            x.tcamaracomercio);

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 5, x.cagente);

               UPDATE mig_agentes
                  SET idperson = v_sperson,
                      cestmig = 5
                WHERE mig_pk = x.mig_pk;
            END IF;

            num_err := f_ins_ageredcom(x.cagente);

            IF num_err <> 0 THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error al insertar en AGEREDCOM:' || num_err);
               v_error := TRUE;
               ROLLBACK;
            ELSE
               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 6, x.cagente);

               UPDATE mig_agentes
                  SET idperson = v_sperson,
                      cestmig = 9
                WHERE mig_pk = x.mig_pk;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_agentes;

/***************************************************************************
      FUNCTION f_migra_representantes
      Función que inserta las personas grabadas en MIG_REPRESENTANTES, en
      la tabla de representantes de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_representantes(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_sperson      per_personas.sperson%TYPE;
      v_sperson2     per_personas.sperson%TYPE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_agentes    BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*
                    FROM mig_representantes a
                   WHERE ncarga = pncarga
                     AND cestmig = 1
                ORDER BY mig_pk) LOOP
         BEGIN
            IF v_1_agentes THEN
               v_1_agentes := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'REPRESENTANTES');
            END IF;

            --Obtenemos el sperson
            SELECT idperson
              INTO v_sperson
              FROM mig_personas
             WHERE mig_pk = x.mig_fk
                                    --AND ncarga = pncarga
            ;

            SELECT idperson
              INTO v_sperson2
              FROM mig_personas
             WHERE mig_pk = x.mig_fk2
                                     --AND ncarga = pncarga
            ;

            INSERT INTO representantes
                        (sperson, ctipo, csubtipo, tcompania, tpuntoventa, spercoord)
                 VALUES (v_sperson, x.ctipo, x.csubtipo, x.tcompania, x.tpuntoventa, v_sperson2);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_sperson);

            UPDATE mig_representantes
               SET idperson = v_sperson,
                   cestmig = 9
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_representantes;

/***************************************************************************
      FUNCTION f_migra_empleados
      Función que inserta las personas grabadas en MIG_EMPLEADOS, en
      la tabla de empleados de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_empleados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_sperson      per_personas.sperson%TYPE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_agentes    BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*
                    FROM mig_empleados a
                   WHERE ncarga = pncarga
                     AND cestmig = 1
                ORDER BY mig_pk) LOOP
         BEGIN
            IF v_1_agentes THEN
               v_1_agentes := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'EMPLEADOS');
            END IF;

            --Obtenemos el sperson
            SELECT idperson
              INTO v_sperson
              FROM mig_personas
             WHERE mig_pk = x.mig_fk
                                    --AND ncarga = pncarga
            ;

            INSERT INTO empleados
                        (sperson, ctipo, csubtipo, ccargo, ccanal)
                 VALUES (v_sperson, x.ctipo, x.csubtipo, x.ccargo, x.ccanal);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_sperson);

            UPDATE mig_empleados
               SET idperson = v_sperson,
                   cestmig = 9
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_empleados;

/***************************************************************************
      FUNCTION f_migra_productos_empleados
      Función que inserta los empleados grabadas en MIG_PRODUCTOS_EMPLEADOS, en
      la tabla de empleados  por producto de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_productos_empleados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_sperson      per_personas.sperson%TYPE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_agentes    BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*
                    FROM mig_productos_empleados a
                   WHERE ncarga = pncarga
                     AND cestmig = 1
                ORDER BY mig_pk) LOOP
         BEGIN
            IF v_1_agentes THEN
               v_1_agentes := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'PRODUCTOS_EMPLEADOS');
            END IF;

            --Obtenemos el sperson
            SELECT idperson
              INTO v_sperson
              FROM mig_personas
             WHERE mig_pk = x.mig_fk
                                    --AND ncarga = pncarga
            ;

            INSERT INTO productos_empleados
                        (sperson, sproduc, cageadn, cageint)
                 VALUES (v_sperson, x.sproduc, x.cageadn, x.cageint);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_sperson || '|' || x.sproduc || '|' || x.cageadn || '|' || x.cageint);

            UPDATE mig_empleados
               SET idperson = v_sperson,
                   cestmig = 9
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_productos_empleados;

/***************************************************************************
      FUNCTION f_migra_tipo_empleados
      Función que inserta los tipos de empleados grabadas en MIG_PRODUCTOS_EMPLEADOS,
      en la tabla de tipos de empleados de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_tipo_empleados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_sperson      per_personas.sperson%TYPE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_agentes    BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*
                    FROM mig_tipo_empleados a
                   WHERE ncarga = pncarga
                     AND cestmig = 1
                ORDER BY mig_pk) LOOP
         BEGIN
            IF v_1_agentes THEN
               v_1_agentes := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'TIPO_EMPLEADOS');
            END IF;

            --Obtenemos el sperson
            SELECT idperson
              INTO v_sperson
              FROM mig_personas
             WHERE mig_pk = x.mig_fk
                                    --AND ncarga = pncarga
            ;

            INSERT INTO tipo_empleados
                        (sperson, csegmento)
                 VALUES (v_sperson, x.csegmento);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_sperson || '|' || x.csegmento);

            UPDATE mig_empleados
               SET idperson = v_sperson,
                   cestmig = 9
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_tipo_empleados;

/***************************************************************************
      FUNCTION f_fecha_cartera
      Función para calcular las fechas de cartera
         param in  pseguros:     Identificador de la póliza.
         param in  pproductos:   Identificador del producto.
         param out pfcaranu:     Fecha cartera anual
         param out pfcarpro:     Fecha próxima cartera
         param out pfcarant      Fecha cartera anterior
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_fecha_cartera(
      pseguros IN OUT seguros%ROWTYPE,
      pproductos IN productos%ROWTYPE,
      pfcaranu OUT DATE,
      pfcarpro OUT DATE,
      pfcarant OUT DATE)
      RETURN NUMBER IS
      v_csituac      seguros.csituac%TYPE;
      lcforpag       NUMBER;
      lmeses         NUMBER;
      dd             VARCHAR2(2);
      ddmm           VARCHAR2(4);
      lfcanua        DATE;
      lfcapro        DATE;
      lfcaant        DATE;
      fecha_aux      DATE;
      num_err        NUMBER := 0;
      vnum_err       NUMBER := 0;
      l_fefecto_1    DATE;
      lfaux          DATE;
      lfvencim       DATE;
      --lfecha_efecto  DATE := TRUNC(f_sysdate);   --pseguros.fefecto
      --jlb
      lfecha_efecto  DATE := TRUNC(pseguros.fefecto);
      --pseguros.fefecto
      vfrenova       DATE := NULL;
      vcduraci       seguros.cduraci%TYPE;
      v_cduraci      NUMBER(1);
      v_vigencia     NUMBER;
      v_hfrenova     NUMBER;
      -- Basado en pac_iax_produccion.f_set_renova
     /*
      FUNCTION f_set_frenova(pfefecto IN DATE, pcduraci IN NUMBER, pfrenova OUT DATE)
         RETURN NUMBER IS
         vpasexec       NUMBER(8) := 1;
         vparam         VARCHAR2(200) := 'pfecha=' || TO_CHAR(pfefecto, 'dd/mm/yyyy');
         vobject        VARCHAR2(200) := 'pac_mig_axis.F_SET_FRENOVA';
         num            NUMBER := 0;
         v_sproduc      NUMBER;
         v_result       NUMBER;
         v_hfrenova     NUMBER;
         vnumerr        NUMBER;
         v_vigencia     NUMBER;
      BEGIN
         v_sproduc := pseguros.sproduc;

         IF pcduraci = 6 THEN
            IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', v_sproduc) = 1
               AND NOT pac_iax_produccion.isaltacol THEN
               vnumerr := pac_seguros.f_get_tipo_vigencia(NULL, pseguros.npoliza, 'SEG',
                                                          v_vigencia);

               IF vnumerr <> 0 THEN
                  RETURN vnumerr;
               END IF;

               IF v_vigencia = 1 THEN   -- Vigencia cerrada
                  vnumerr := pac_productos.f_get_herencia_col(v_sproduc, 6, v_hfrenova);

                  IF NVL(v_hfrenova, 0) = 1
                     AND vnumerr = 0 THEN
                     vnumerr := pac_productos.f_get_frenova_col(pseguros.npoliza, pfrenova);

                     IF vnumerr <> 0 THEN
                        RETURN vnumerr;
                     END IF;
                  ELSE
                     pfrenova :=
                        ADD_MONTHS
                                  (pfefecto,
                                   NVL(pac_parametros.f_parproducto_n(v_sproduc,
                                                                      'PERIODO_POR_DEFECTO'),
                                       12));
                  END IF;
               ELSE   -- vigencia abierta
                  pfrenova :=
                     ADD_MONTHS(pfefecto,
                                NVL(pac_parametros.f_parproducto_n(v_sproduc,
                                                                   'PERIODO_POR_DEFECTO'),
                                    12));
               END IF;
            ELSE
               pfrenova :=
                  ADD_MONTHS(pfefecto,
                             NVL(pac_parametros.f_parproducto_n(v_sproduc,
                                                                'PERIODO_POR_DEFECTO'),
                                 12));
            END IF;
         ELSE
            vnumerr := pac_seguros.f_get_tipo_vigencia(NULL, pseguros.npoliza, 'SEG',
                                                       v_vigencia);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            IF v_vigencia = 1 THEN   -- Vigencia cerrada
               vnumerr := pac_productos.f_get_herencia_col(v_sproduc, 6, v_hfrenova);

               IF NVL(v_hfrenova, 0) = 1
                  AND vnumerr = 0 THEN
                  vnumerr := pac_productos.f_get_frenova_col(pseguros.npoliza, pfrenova);

                  IF vnumerr <> 0 THEN
                     RETURN vnumerr;
                  END IF;
               ELSE
                  pfrenova := NULL;
               END IF;
            ELSE
               pfrenova := NULL;
            END IF;
         END IF;

             -- BUG 26820 - 30/04/2013 - FAL
         --    IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'FRENOVA-1'), 0) = 1
          --      AND NVL(pac_parametros.f_parproducto_n(v_sproduc, 'PERIODO_POR_DEFECTO'), 0) <> 0 THEN
           --     pfrenova := pfrenova - 1;
           --  END IF;

         -- FI BUG 26820

         -- pfrenova := poliza.det_poliza.gestion.frenova;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 1000001;
      END f_set_frenova;


   */
   BEGIN
      SELECT DECODE(pseguros.csituac, 4, 0, 5, 1, pseguros.csituac)
        INTO v_csituac
        FROM DUAL;

      -- primero calculo la frenova si aplica--

      -- fim calculo frenova JLB  QT: 9172 - 9160
      IF pseguros.cduraci = 6 THEN
         IF NVL(pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', pseguros.sproduc),
                0) = 1
            AND NOT pac_iax_produccion.isaltacol THEN
            num_err := pac_seguros.f_get_tipo_vigencia(NULL, pseguros.npoliza, 'SEG',
                                                       v_vigencia);

            IF v_vigencia = 1 THEN
               -- Vigencia cerrada --
               --num_err := pac_productos.f_get_frenova_col(pseguros.npoliza, pseguros.frenova);
               num_err := pac_productos.f_get_herencia_col(pseguros.sproduc, 6, v_hfrenova);
               pseguros.cduraci := 6;   -- Temporal renovable

               IF NVL(v_hfrenova, 0) = 1
                  AND num_err = 0 THEN
                  num_err := pac_productos.f_get_frenova_col(pseguros.npoliza,
                                                             pseguros.frenova);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               ELSE
                  pseguros.frenova :=
                     ADD_MONTHS(pseguros.fefecto,
                                NVL(pac_parametros.f_parproducto_n(pseguros.sproduc,
                                                                   'PERIODO_POR_DEFECTO'),
                                    12));
               END IF;
            ELSE
               -- Vigencia abierta --
               pseguros.frenova := NULL;
               pseguros.cduraci := NVL(pseguros.cduraci, 0);   -- si es vigencia abierta, dejo la duración que tenga el producto
            END IF;
         ELSE
            IF pseguros.frenova IS NULL THEN
               pseguros.cduraci := NVL(pseguros.cduraci, 0);   -- dejo la duración que tenga el producto
            ELSE
               IF pseguros.frenova <>
                     ADD_MONTHS(pseguros.fefecto,
                                NVL(pac_parametros.f_parproducto_n(pseguros.sproduc,
                                                                   'PERIODO_POR_DEFECTO'),
                                    12)) THEN
                  pseguros.cduraci := 6;
               ELSE
                  pseguros.frenova := NULL;
                  pseguros.cduraci := NVL(pseguros.cduraci, 0);   -- dejo la duración que tenga el producto;
               END IF;
            END IF;
         END IF;
      ELSE
         IF NVL(pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', pseguros.sproduc),
                0) = 1
            AND NOT pac_iax_produccion.isaltacol THEN
            num_err := pac_seguros.f_get_tipo_vigencia(NULL, pseguros.npoliza, 'SEG',
                                                       v_vigencia);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            IF v_vigencia = 1 THEN   -- Vigencia cerrada
               num_err := pac_productos.f_get_herencia_col(pseguros.sproduc, 6, v_hfrenova);

               IF NVL(v_hfrenova, 0) = 1
                  AND num_err = 0 THEN
                  num_err := pac_productos.f_get_frenova_col(pseguros.npoliza,
                                                             pseguros.frenova);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               ELSE
                  pseguros.frenova := NULL;
               END IF;
            ELSE
               pseguros.frenova := NULL;
            END IF;
         ELSE
            pseguros.frenova := NULL;
         END IF;
      END IF;

      -- fim calculo frenova JLB  QT: 9172 - 9160

      ----------
      IF (pseguros.cforpag <> 0
          OR(pseguros.cforpag = 0
             AND pproductos.crevfpg = 1))
         AND v_csituac = 0 THEN
         IF pseguros.cforpag = 0
            AND pproductos.crevfpg = 1 THEN
            lcforpag := 1;   -- que calcule las fechas como si fuera pago anual
         ELSE
            lcforpag := pseguros.cforpag;
         END IF;

         lmeses := 12 / lcforpag;
         --  dd := SUBSTR(LPAD(pseguros.nrenova, 4, 0), 3, 2);
         --  ddmm := dd || SUBSTR(LPAD(pseguros.nrenova, 4, 0), 1, 2);
         p_control_error('CSI', 'PAC_MIG_AXIS', 'pseguros.frenova' || pseguros.frenova);
         p_control_error('CSI', 'PAC_MIG_AXIS', 'lfecha_efecto' || lfecha_efecto);

         IF pseguros.frenova IS NOT NULL THEN
            dd := TO_CHAR(pseguros.frenova, 'dd');
            -- SUBSTR(LPAD(v_pol.nrenova, 4, 0), 3, 2);
            ddmm := TO_CHAR(pseguros.frenova, 'ddmm');
         -- dd || SUBSTR(LPAD(v_pol.nrenova, 4, 0), 1, 2);
         ELSE
            -- Fin bug 23117
            -- INI RLLF 0038273: ERROR RENOVACION
            --dd := SUBSTR(LPAD(pseguros.nrenova, 4, 0), 3, 2);
            dd := NVL(SUBSTR(LPAD(pseguros.nrenova, 4, 0), 3, 2), 1);
               -- FIN RLLF 0038273: ERROR RENOVACION
            -- INI RLLF 0038273: ERROR RENOVACION
               --ddmm := dd || SUBSTR(LPAD(pseguros.nrenova, 4, 0), 1, 2);
            ddmm := dd || NVL(SUBSTR(LPAD(pseguros.nrenova, 4, 0), 1, 2), 1);
         -- FIN RLLF 0038273: ERROR RENOVACION
         -- Bug 23117 - RSC - 31/07/2012 -  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
         END IF;

         -- Bug 23117 - RSC - 31/07/2012 -  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
         IF pseguros.frenova IS NOT NULL THEN
            lfcanua := pseguros.frenova;
         ELSE
            -- Fin bug 23117
            IF TO_CHAR(lfecha_efecto, 'DDMM') = ddmm
               OR LPAD(pseguros.nrenova, 4, 0) IS NULL THEN
               IF NVL(pac_parametros.f_parempresa_n(pseguros.cempres, 'FECHA_RENOVA_ANYO'), 0) =
                                                                                             1 THEN
                  lfcanua := ADD_MONTHS(lfecha_efecto, 12);
               ELSE
                  lfcanua := f_summeses(lfecha_efecto, 12, dd);
               END IF;
            ELSE
               IF pproductos.ctipefe = 2 THEN
                  fecha_aux := ADD_MONTHS(lfecha_efecto, 13);
                  lfcanua := TO_DATE(ddmm || TO_CHAR(fecha_aux, 'YYYY'), 'DDMMYYYY');
               ELSE
                  IF NVL(pac_parametros.f_parempresa_n(pseguros.cempres, 'FECHA_RENOVA_ANYO'),
                         0) = 1 THEN
                     lfcanua := ADD_MONTHS(lfecha_efecto, 12);
                  ELSE
                     BEGIN
                        lfcanua := TO_DATE(ddmm || TO_CHAR(lfecha_efecto, 'YYYY'), 'DDMMYYYY');
                     EXCEPTION
                        WHEN OTHERS THEN
                           IF ddmm = 2902 THEN
                              ddmm := 2802;
                              lfcanua := TO_DATE(ddmm || TO_CHAR(lfecha_efecto, 'YYYY'),
                                                 'DDMMYYYY');
                           ELSE
                              RETURN 104510;
                           --Fecha de renovación (mmdd) incorrecta
                           END IF;
                     END;
                  END IF;
               END IF;

               IF lfcanua <= lfecha_efecto THEN
                  IF NVL(pac_parametros.f_parempresa_n(pseguros.cempres, 'FECHA_RENOVA_ANYO'),
                         0) = 1 THEN
                     lfcanua := ADD_MONTHS(lfecha_efecto, 12);
                  ELSE
                     lfcanua := f_summeses(lfcanua, 12, dd);
                  END IF;
               END IF;
            END IF;
         -- Bug 23117 - RSC - 31/07/2012 -  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
         END IF;

         IF pseguros.frenova IS NOT NULL
            AND lcforpag IN(0, 1) THEN
            lfcapro := pseguros.frenova;
         ELSE
            -- Se calcula la próx. cartera partiendo de la cartera de renovación (fcaranu)
            -- y restándole periodos de pago
            IF pproductos.ctipefe = 2
               AND TO_CHAR(lfecha_efecto, 'dd') <> 1
               AND lcforpag <> 12 THEN
               l_fefecto_1 := '01/' || TO_CHAR(ADD_MONTHS(lfecha_efecto, 1), 'mm/yyyy');
            ELSE
               l_fefecto_1 := lfecha_efecto;
            END IF;

            lfaux := lfcanua;

            WHILE TRUE LOOP
               lfaux := f_summeses(lfaux, -lmeses, dd);
               lfcaant := lfaux;

               IF lfaux <= l_fefecto_1 THEN
                  lfcapro := f_summeses(lfaux, lmeses, dd);
                  --lfcaant := f_summeses(lfaux,((lmeses) * -1), dd);
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         IF pproductos.ndiaspro IS NOT NULL THEN
            IF TO_NUMBER(TO_CHAR(lfecha_efecto, 'dd')) >= pproductos.ndiaspro
               AND TO_NUMBER(TO_CHAR(lfcapro, 'mm')) =
                                         TO_NUMBER(TO_CHAR(ADD_MONTHS(lfecha_efecto, 1), 'mm')) THEN
               -- es decir , que el dia sea > que el dia 15 del ultimo mes del periodo
               lfcapro := ADD_MONTHS(lfcapro, lmeses);
               lfcaant := ADD_MONTHS(lfcapro,((lmeses - 1) * -1));

               IF lfcapro > lfcanua THEN
                  lfcapro := lfcanua;
               END IF;
            END IF;
         END IF;

         IF pseguros.cforpag = 0
            AND pproductos.crevfpg = 1 THEN
            IF pseguros.frenova IS NOT NULL
               AND lcforpag IN(0, 1) THEN
               lfvencim := NVL(pseguros.frenova, lfecha_efecto + 1);
            ELSE
               lfvencim := NVL(pseguros.fvencim, lfecha_efecto + 1);
            END IF;
         ELSE
            lfvencim := lfcapro;
         END IF;
      ELSIF pseguros.cforpag <> 0
            AND v_csituac = 1 THEN   -- Suplement i forma de pagament no única
         lfcanua := pseguros.fcaranu;
         lfcapro := pseguros.fcarpro;
         lfcaant := pseguros.fcarant;
         lfvencim := lfcapro;
      ELSIF pseguros.cforpag = 0
            AND pproductos.crevfpg = 0 THEN
         --Forma de pago única y nueva producción ó suplemento
         lfcanua := pseguros.fcaranu;
         lfcapro := pseguros.fcarpro;
         lfcaant := pseguros.fcarant;
         lfvencim := NVL(pseguros.fvencim, lfecha_efecto + 1);
      ELSE
         lfcanua := pseguros.fcaranu;
         lfcapro := pseguros.fcarpro;
         lfcaant := pseguros.fcarant;

         IF pseguros.cforpag = 0
            AND pproductos.crevfpg = 1 THEN
            IF pseguros.frenova IS NOT NULL
               AND lcforpag IN(0, 1) THEN
               lfvencim := NVL(pseguros.fvencim, lfecha_efecto + 1);
            ELSE
               lfvencim := NVL(pseguros.fvencim, lfecha_efecto + 1);
            END IF;
         ELSE
            lfvencim := lfcapro;
         END IF;
      END IF;

-------------
      pfcaranu := lfcanua;
      pfcarpro := lfcapro;
      pfcarant := lfcaant;
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         pfcaranu := NULL;
         pfcarpro := NULL;
         RETURN SQLCODE;
   END f_fecha_cartera;

/***************************************************************************
      FUNCTION f_act_hisseg
      Función que inserta en la tabla historicoseguros con la
      información previa a una modificación de la tabla seguros.
         param in  psseguro:     Identificador de la póliza.
         param in  pnmovimi:     Número de movimiento de la póliza.
         param in  ptablas:      EST, POL por defecto es POL   -- 23289/120321 - ECP - 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_act_hisseg(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      lerror         NUMBER := 0;
      xf1paren       DATE := NULL;
      xfcarult       DATE := NULL;
      xttexto        VARCHAR2(50);
      xndurper       NUMBER;
      xfrevisio      DATE;
      xcgasges       NUMBER;
      xcgasred       NUMBER;
      xcmodinv       NUMBER;
      xfrevant       DATE;
      xfefecto_mov   DATE;
      v_historicoseguros historicoseguros%ROWTYPE;
      -- BUG 0022839 - FAL - 24/07/2012
      x_ctipcol      seguroscol.ctipcol%TYPE;
      x_ctipcob      seguroscol.ctipcob%TYPE;
      x_ctipvig      seguroscol.ctipvig%TYPE;
      x_recpor       seguroscol.recpor%TYPE;
      x_cagrupa      seguroscol.cagrupa%TYPE;
      x_prorrexa     seguroscol.prorrexa%TYPE;
      x_cmodalid     seguroscol.cmodalid%TYPE;
      x_fcorte       seguroscol.fcorte%TYPE;
      x_ffactura     seguroscol.ffactura%TYPE;
      -- 23074 - I - JLB - 30/07/2012
      x_cagastexp    seguroscol.cagastexp%TYPE;
      x_cperiogast   seguroscol.cperiogast%TYPE;
      x_iimporgast   seguroscol.iimporgast%TYPE;
      v_nmovimi      NUMBER;
-- BUG - F - 23074
-- 23074  F -
-- FI BUG 0022839
   BEGIN
      BEGIN
         -- 23289/120321 - ECP - 03/09/2012 Inicio
         IF ptablas = 'EST' THEN
            BEGIN
               SELECT f1paren
                 INTO xf1paren
                 FROM estseguros_ren
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xf1paren := NULL;
            END;

            BEGIN
               SELECT fcarult
                 INTO xfcarult
                 FROM estseguros_assp
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xfcarult := NULL;
            END;
         ELSE
            BEGIN
               SELECT f1paren
                 INTO xf1paren
                 FROM seguros_ren
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xf1paren := NULL;
            END;

            BEGIN
               SELECT fcarult
                 INTO xfcarult
                 FROM seguros_assp
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xfcarult := NULL;
            END;
         END IF;

         SELECT NVL(nmovimi, pnmovimi),
                fefecto   --Si no encontramos nada, que haga lo mismo que hasta ahora
           INTO v_nmovimi,
                xfefecto_mov
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM movseguro
                            WHERE sseguro = psseguro
                              AND cmovseg NOT IN(52)
                              AND nmovimi <= pnmovimi);

         -- 23289/120321 - ECP - 03/09/2012 Fin
         BEGIN
            SELECT ttexto
              INTO xttexto
              FROM bloqueoseg
             WHERE sseguro = psseguro
               AND nmovimi = v_nmovimi
               AND finicio = (SELECT MAX(finicio)
                                FROM bloqueoseg
                               WHERE sseguro = psseguro
                                 AND nmovimi = v_nmovimi);
         EXCEPTION
            WHEN OTHERS THEN
               xttexto := NULL;
         END;

         --modificació : XCG 05-01-2007 afegim el camp ndurper
         -- 23289/120321 - ECP - 03/09/2012 Inicio
         IF ptablas = 'EST' THEN
            BEGIN
               SELECT ndurper, frevisio, frevant
                 INTO xndurper, xfrevisio, xfrevant
                 FROM estseguros_aho
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xndurper := NULL;
            END;
         ELSE
            BEGIN
               SELECT ndurper, frevisio, frevant
                 INTO xndurper, xfrevisio, xfrevant
                 FROM seguros_aho
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xndurper := NULL;
            END;
         END IF;

         -- 23289/120321 - ECP - 03/09/2012 Fin
         --modificació : RSC 17-09-2007 afegim els camps de despeses de Unit Linked
         -- 23289/120321 - ECP - 03/09/2012 Inicio
         IF ptablas = 'EST' THEN
            BEGIN
               SELECT cgasges, cgasred
                 INTO xcgasges, xcgasred
                 FROM estseguros_ulk
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xcgasges := NULL;
                  xcgasred := NULL;
            END;
         ELSE
            BEGIN
               SELECT cgasges, cgasred
                 INTO xcgasges, xcgasred
                 FROM seguros_ulk
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xcgasges := NULL;
                  xcgasred := NULL;
            END;
         END IF;

         -- 23289/120321 - ECP - 03/09/2012 Fin
         --modificació : RSC 20-09-2007 afegim el camp de model d'inversió de Unit Linked
         -- 23289/120321 - ECP - 03/09/2012 Inicio
         IF ptablas = 'EST' THEN
            BEGIN
               SELECT cmodinv
                 INTO xcmodinv
                 FROM estseguros_ulk
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xcmodinv := NULL;
            END;
         ELSE
            BEGIN
               SELECT cmodinv
                 INTO xcmodinv
                 FROM seguros_ulk
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xcmodinv := NULL;
            END;
         END IF;

         -- 23289/120321 - ECP - 03/09/2012  Fin

         -- BUG 0022839 - FAL - 24/07/2012
         BEGIN
            SELECT ctipcol, ctipcob, ctipvig, recpor, cagrupa, prorrexa,
                   cmodalid, fcorte, ffactura   -- BUG 23074 - JLB - 30/07/2012
                                             ,
                   cagastexp, cperiogast, iimporgast
              -- BUG -F - 23074
            INTO   x_ctipcol, x_ctipcob, x_ctipvig, x_recpor, x_cagrupa, x_prorrexa,
                   x_cmodalid, x_fcorte, x_ffactura   -- BUG 23074 - JLB - 30/07/2012
                                                   ,
                   x_cagastexp, x_cperiogast, x_iimporgast
              -- BUG - F - 23074
            FROM   seguroscol
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               x_ctipcol := NULL;
               x_ctipcob := NULL;
               x_ctipvig := NULL;
               x_recpor := NULL;
               x_cagrupa := NULL;
               x_prorrexa := NULL;
               x_cmodalid := NULL;
               x_fcorte := NULL;
               x_ffactura := NULL;
               -- BUG 23074 - JLB - 30/07/2012
               x_cagastexp := NULL;
               x_cperiogast := NULL;
               x_iimporgast := NULL;
         -- BUG -F - 23074
         END;

         -- FI BUG 0022839
         SELECT sseguro,
                v_nmovimi,
                f_sysdate,
                casegur,
                cagente,
                nsuplem,
                fefecto,
                creafac,
                ctarman,
                cobjase,
                ctipreb,
                cactivi,
                ccobban,
                ctipcoa,
                ctiprea,
                crecman,
                creccob,
                ctipcom,
                fvencim,
                femisio,
                fanulac,
                fcancel,
                csituac,
                cbancar,
                ctipcol,
                fcarant,
                fcarpro,
                fcaranu,
                cduraci,
                nduraci,
                --nanuali,
                NVL(TRUNC((xfefecto_mov - fefecto) / 365), 0) + 1 nanuali,
                iprianu,
                cidioma,
                nfracci,
                cforpag,
                pdtoord,
                nrenova,
                crecfra,
                tasegur,
                creteni,
                ndurcob,
                sciacoa,
                pparcoa,
                npolcoa,
                nsupcoa,
                tnatrie,
                pdtocom,
                prevali,
                irevali,
                ncuacoa,
                nedamed,
                crevali,
                cempres,
                cagrpro,
                nsolici,
                xf1paren,
                xfcarult,
                xttexto,
                ccompani,
                NULL,
                NULL,
                xndurper,
                xfrevisio,
                xcgasges,
                xcgasred,
                xcmodinv,
                ctipban,
                ctipcob,
                xfrevant,
                sprodtar,
                ncuotar,   -- BUG 21924 - 16/04/2012 - ETM--aqui
                ctipretr,
                cindrevfran,
                precarg,
                pdtotec,
                preccom,   -- FIN BUG 21924 - 16/04/2012 - ETM
                           -- BUG 0022839 - FAL - 24/07/2012
                x_ctipcol,
                x_ctipcob,
                x_ctipvig,
                x_recpor,
                x_cagrupa,
                x_prorrexa,
                x_cmodalid,   -- BUG 23074 - JLB - 30/07/2012
                x_cagastexp,
                x_cperiogast,
                x_iimporgast,   -- BUG 23074
                x_fcorte,
                x_ffactura,   -- FI BUG 0022839
                frenova,   -- BUG 23117 - FAL - 31/07/2012
                fefeplazo, -- BUG 41143/229973 - 17/03/2016 - JAEG
                fvencplazo -- BUG 41143/229973 - 17/03/2016 - JAEG
                -- fin rllf 10/05/2016
           INTO v_historicoseguros
           FROM seguros
          WHERE sseguro = psseguro;

         -- BUG 0020761 - 03/01/2012 - JMF: afegir ncuotar
         INSERT INTO historicoseguros
              VALUES v_historicoseguros;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, '{f_act_hisseg}' || psseguro, 1,
                        psseguro || pnmovimi || xf1paren || xfcarult || xttexto, SQLERRM);
            -- Error a l'insertar a la taula historicoseguros
            lerror := 109383;
      END;

      RETURN lerror;
   END f_act_hisseg;

/***************************************************************************
      FUNCTION f_migra_seguros
      Función que inserta las pólizas grabadas en MIG_SEGUROS, en las distintas
      tablas de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_seguros(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_seguros    BOOLEAN := TRUE;
      v_1_seguros_aho BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      --v_propietario  BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_seguros      seguros%ROWTYPE;
      reg_productos  productos%ROWTYPE;
      v_movseguro    movseguro%ROWTYPE;
      v_seguros_aho  seguros_aho%ROWTYPE;
      --   dtpoliza       ob_iax_detpoliza;
       --  t_mensajes     t_iax_mensajes;
      v_sperson      per_personas.sperson%TYPE;
      v_cdomici      per_direcciones.cdomici%TYPE;
      v_fvencim      seguros.fvencim%TYPE;
      v_cont         NUMBER := 0;
      v_cempres      empresas.cempres%TYPE;
      v_bancob       BOOLEAN := FALSE;
      v_mig_seg      mig_seguros%ROWTYPE;
      v_traza        VARCHAR2(10);
      v_ssegpol      estseguros.ssegpol%TYPE;
      vcduraci       seguros.cduraci%TYPE;
      v_cduraci      NUMBER(1);
      v_sperson_2    per_personas.sperson%TYPE;
      v_cdomici_2    per_direcciones.cdomici%TYPE;

      -- BUG 14185 - 11-05-2010 - JMC - Función para la migración de la cuenta bancaria de SEGURO en PER_CCC en caso de que no exista.
      PROCEDURE p_migra_per_ccc(pmig_pk IN VARCHAR2, psproces IN NUMBER) IS
         v_cont         NUMBER;
         v_per_ccc      per_ccc%ROWTYPE;
         v_traza        VARCHAR2(10);
      BEGIN
         v_traza := '1';

         -- 23289/120321 - ECP - 03/09/2012  Inicio
         IF ptablas = 'EST' THEN
            SELECT COUNT(*)
              INTO v_cont
              FROM estper_ccc
             WHERE sperson = v_sperson
               AND cbancar = v_seguros.cbancar;
         ELSE
            SELECT COUNT(*)
              INTO v_cont
              FROM per_ccc
             WHERE sperson = v_sperson
               AND cbancar = v_seguros.cbancar;
         END IF;

         -- 23289/120321 - ECP - 03/09/2012  Fin
         v_traza := '2';

         IF v_cont = 0 THEN   --No existe la cuenta, la damos de alta
            BEGIN
               v_traza := '3';

               SELECT ncarga
                 INTO v_cont
                 FROM mig_cargas_tab_axis
                WHERE ncarga = pncarga
                  AND ntab = pntab
                  AND ntabaxis = 4
                  AND ttabaxis = 'PER_CCC';

               v_traza := '4';
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -7, 'PER_CCC');
            END;

            v_traza := '5';

            -- 23289/120321 - ECP - 03/09/2012  Inicio
            IF ptablas = 'EST' THEN
               SELECT NVL(MAX(cnordban), 0) + 1
                 INTO v_cont
                 FROM estper_ccc
                WHERE sperson = v_sperson;
            ELSE
               SELECT NVL(MAX(cnordban), 0) + 1
                 INTO v_cont
                 FROM per_ccc
                WHERE sperson = v_sperson;
            END IF;

            -- 23289/120321 - ECP - 03/09/2012  Fin
            IF v_cont < 100 THEN   -- no permitimos mas de 100
               v_traza := '6';
               v_per_ccc := NULL;
               v_per_ccc.sperson := v_sperson;
               v_per_ccc.cagente := ff_agente_cpervisio(v_seguros.cagente, f_sysdate,
                                                        v_seguros.cempres);
               v_traza := '7';
               v_per_ccc.ctipban := v_seguros.ctipban;
               v_traza := '8';
               v_per_ccc.cbancar := v_seguros.cbancar;
               v_traza := '9';

               --  JMC 18/05/2011
               --Si es la primera cuenta de la persona, la ponemos por defecto,
               --ya que obligatoriamente tiene que tener una por defecto para que
               --iAXIS funcione correctamente.
               IF v_cont = 1 THEN
                  v_per_ccc.cdefecto := 1;
               ELSE
                  v_per_ccc.cdefecto := 0;
               END IF;

               v_traza := '10';
               v_per_ccc.cusumov := f_user;
               v_traza := '11';
               v_per_ccc.fusumov := f_sysdate;
               v_traza := '12';
               v_per_ccc.cnordban := v_cont;
               v_traza := '13';

               BEGIN
                  -- 23289/120321 - ECP - 03/09/2012 Inicio
                  IF ptablas = 'EST' THEN
                     INSERT INTO estper_ccc
                                 (sperson, cagente, ctipban,
                                  cbancar, fbaja, cdefecto,
                                  cusumov, fusumov, cnordban,
                                  corigen, cvalida, cpagsin,
                                  fvencim, tseguri, falta,
                                  cusualta)
                          VALUES (v_per_ccc.sperson, v_per_ccc.cagente, v_per_ccc.ctipban,
                                  v_per_ccc.cbancar, v_per_ccc.fbaja, v_per_ccc.cdefecto,
                                  v_per_ccc.cusumov, v_per_ccc.fusumov, v_per_ccc.cnordban,
                                  NULL, v_per_ccc.cvalida, v_per_ccc.cpagsin,
                                  v_per_ccc.fvencim, v_per_ccc.tseguri, v_per_ccc.falta,
                                  v_per_ccc.cusualta);

                     BEGIN
                        INSERT INTO estper_cargas
                                    (sperson, tipo, proceso,
                                     cagente, ccodigo, cusuari, fecha)
                             VALUES (v_per_ccc.sperson, 'ACB', NVL(psproces, 0),
                                     v_per_ccc.cagente, v_per_ccc.cnordban, f_user, f_sysdate);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           NULL;   -- reprocesamiento
                     END;
                  ELSE
                     INSERT INTO per_ccc
                          VALUES v_per_ccc;

                     BEGIN
                        INSERT INTO per_cargas
                                    (sperson, tipo, proceso,
                                     cagente, ccodigo, cusuari, fecha)
                             VALUES (v_per_ccc.sperson, 'ACB', NVL(psproces, 0),
                                     v_per_ccc.cagente, v_per_ccc.cnordban, f_user, f_sysdate);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           NULL;   -- reprocesamiento
                     END;
                  END IF;

                  -- 23289/120321 - ECP - 03/09/2012 Fin
                  INSERT INTO mig_pk_mig_axis
                       VALUES (pmig_pk, pncarga, pntab, -7, v_sperson || '|' || v_cont);
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, pmig_pk, 'E',
                                                    'Error al insertar PER_CCC :' || SQLCODE
                                                    || '-' || SQLERRM);
                     v_error := TRUE;
               END;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := f_ins_mig_logs_axis(pncarga, pmig_pk, 'E',
                                           'Error p_migra_per_ccc :' || v_traza || '-'
                                           || v_sperson || '-' || SQLCODE || '-' || SQLERRM);
            v_error := TRUE;
      END p_migra_per_ccc;
-- FIN BUG 14185 - 11-05-2010 - JMC
   BEGIN
      v_traza := '1';

      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;
      v_traza := '2';

      --Averiguamos la empresa de la carga
      SELECT TO_NUMBER(cempres)
        INTO v_cempres
        FROM mig_cargas
       WHERE ncarga = pncarga;

      v_traza := '3';

      --Averiguamos si tenemos que grabar cuenta cargo
      BEGIN
         v_traza := '4';

         SELECT nvalpar
           INTO num_err
           FROM parempresas
          WHERE cparam = 'CBANCOB'
            AND cempres = v_cempres;

         v_traza := '5';

         IF num_err = 0 THEN
            v_bancob := FALSE;
         ELSIF num_err = 1 THEN
            v_bancob := TRUE;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            v_bancob := FALSE;
      END;

      v_traza := '6';
-- JLB - I -  08/07/2013
--      SELECT COUNT(*)
--        INTO num_err
--        FROM user_objects
--       WHERE object_name = 'ACTUALIZ_SEGUREDCOM';
      v_traza := '7';
-- JLB - I -  08/07/2013
--      IF num_err = 0 THEN
      --v_propietario := FALSE;
      --     ELSE
      --        v_propietario := TRUE;
      --     END IF;
      v_traza := '8';

-- JLB - I -  08/07/2013
--      IF v_propietario THEN
--         num_err := f_trata_trigger('ACTUALIZ_SEGUREDCOM', 'DISABLE');
--      END IF;

      --      IF num_err = 99
--         AND v_propietario THEN
--         num_err := f_ins_mig_logs_axis(pncarga, 'TRIGGER', 'E',
 --                                       'Error al deshabilitar trigger ACTUALIZ_SEGUREDCOM ');
 --        v_error := TRUE;
 --   ELSE
         --Tratamos cada una de las polizas.
      FOR x IN (SELECT   a.*
                    FROM mig_seguros a
                   WHERE a.ncarga = pncarga
                     AND a.cestmig = 1
                ---ORDER BY a.mig_pk) LOOP
                ORDER BY a.npoliza, a.ncertif) LOOP   -- OJO con rendimiento, realmente deberia ser por mig_pk, pero sino con colectivos con certificado 0 tebemos probelmas
         BEGIN
            v_traza := '9';

            IF v_1_seguros THEN
               v_1_seguros := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SEGUROS');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 2, 'TOMADORES');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 3, 'CNVPOLIZAS');
               v_traza := '11';

               -- num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 4, 'PENALISEG');
               IF v_bancob THEN
                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 5, 'SEG_CBANCAR');
               END IF;
            END IF;

            IF ptablas = 'POL' THEN   -- si es carga directa...migración
               IF NVL(pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', x.sproduc),
                      0) = 1
                  AND NVL(x.ncertif, 0) = 0 THEN   -- parece un certificado 0 de migración
                  -- ademas me aseguro que realmente sea la primera póliza
                  SELECT COUNT('x')
                    INTO v_cont
                    FROM seguros
                   WHERE npoliza = x.npoliza;

                  IF v_cont = 0 THEN
                     pac_iax_produccion.isaltacol := TRUE;
                  ELSE
                     pac_iax_produccion.isaltacol := FALSE;
                  END IF;
               ELSE
                  pac_iax_produccion.isaltacol := FALSE;
               END IF;
            END IF;

            BEGIN   --Proceso migración SEGUROS.
               v_traza := '12';
               v_error := FALSE;
               v_seguros := NULL;
               --Obtenemos los datos de MIG_SEGUROS
               v_seguros.casegur := x.casegur;
               v_seguros.cagente := x.cagente;
               v_seguros.npoliza := x.npoliza;
               v_seguros.ncertif := x.ncertif;
               v_seguros.nsuplem := x.nsuplem;
               v_seguros.fefecto := x.fefecto;
               v_seguros.creafac := x.creafac;
               v_traza := '15';
               v_seguros.cactivi := x.cactivi;
               v_seguros.ccobban := x.ccobban;
               v_seguros.ctipcoa := x.ctipcoa;
               v_seguros.ctiprea := x.ctiprea;
               v_seguros.crecman := 0;
               --Este campo parece que no se utiliza.
               v_seguros.ctipcom := x.ctipcom;
               v_seguros.fvencim := x.fvencim;
               v_seguros.femisio := x.femisio;
               v_seguros.fanulac := x.fanulac;
               v_seguros.fcancel := x.fcancel;
               v_seguros.csituac := x.csituac;
               v_seguros.frenova := x.frenova;
               v_traza := '20';

               IF f_parinstalacion_t('TNOMCLI') = 'APRA LEVEN'
                  AND x.cbancob IS NOT NULL THEN
                  v_seguros.cbancar := x.cbancob;
                  v_seguros.ctipban := 4;
               ELSE
                  v_seguros.cbancar := x.cbancar;
                  v_seguros.ctipban := x.ctipban;
               END IF;

               v_traza := '21';
               v_seguros.ctipcol := 1;
               v_seguros.iprianu := x.iprianu;
               v_seguros.cidioma := x.cidioma;
               v_seguros.cforpag := x.cforpag;
               v_seguros.sciacoa := x.sciacoa;
               v_seguros.pparcoa := x.pparcoa;
               v_seguros.npolcoa := x.npolcoa;
               v_seguros.nsupcoa := x.nsupcoa;
               v_seguros.pdtocom := x.pdtocom;
               v_traza := '22';
               v_seguros.ncuacoa := x.ncuacoa;
               v_seguros.cempres := x.cempres;
               v_seguros.sproduc := x.sproduc;
               v_seguros.ccompani := x.ccompani;
               v_traza := '23';
               --v_seguros.ctipban := x.ctipban;
               v_seguros.ctipcob := x.ctipcob;
               v_seguros.creteni := NVL(x.creteni, 0);

               --v_seguros.nanuali := 1;
               BEGIN
                  SELECT NVL(TRUNC((MAX(fefecto) - x.fefecto) / 365), 0) + 1
                    INTO v_seguros.nanuali
                    FROM mig_movseguro
                   WHERE ncarga = pncarga
                     AND mig_fk = x.mig_pk
                     AND cmotmov IN(404, 407);
               EXCEPTION
                  WHEN OTHERS THEN
                     v_seguros.nanuali := 1;   -- realmente no deberia pasar
               END;

               --
               -- BUG 21924 - 16/04/2012 - ETM--aqui
               v_seguros.ctipretr := x.ctipretr;
               v_seguros.cindrevfran := x.cindrevfran;
               v_seguros.precarg := x.precarg;
               v_seguros.pdtotec := x.pdtotec;
               v_seguros.preccom := x.preccom;
               -- FIN BUG 21924 - 16/04/2012 - ETM
               v_seguros.cpolcia := x.cpolcia;
               -- Bug 25584/0135342 - MMS - 25/03/2013
               v_seguros.nedamar := x.nedamar;
               v_traza := '24';

               --Obtenemos los datos del producto
               BEGIN
                  SELECT *
                    INTO reg_productos
                    FROM productos
                   WHERE sproduc = x.sproduc;

                  v_traza := '25';
                  v_seguros.cramo := reg_productos.cramo;
                  v_seguros.cmodali := reg_productos.cmodali;
                  v_seguros.ctipseg := reg_productos.ctipseg;
                  v_seguros.ccolect := reg_productos.ccolect;
                  v_seguros.ctarman := reg_productos.ctarman;

                  IF NVL(pac_parametros.f_parproducto_n(x.sproduc, 'ALTACERO_DESCRIPCION'), 0) =
                                                                                              1
                     AND pac_iax_produccion.isaltacol THEN
                     v_seguros.cobjase := 3;
                  ELSE
                     v_seguros.cobjase := reg_productos.cobjase;
                  END IF;

                  v_seguros.ctipreb := reg_productos.ctipreb;
                  v_seguros.creccob := reg_productos.creccob;
                  v_traza := '30';

                  -- ok tengo en cuenta los parameros de entrada para calcular el vencimiento
                  IF v_seguros.fvencim IS NOT NULL
                     AND NVL(reg_productos.ctempor, 0) = 1 THEN
                     v_seguros.cduraci := 3;   -- hasta vencimiento
                  ELSE
                     IF NVL(pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS',
                                                                  x.sproduc),
                            0) = 1
                        AND NOT pac_iax_produccion.isaltacol
                        AND x.ncertif <> 0 THEN
                        num_err := pac_productos.f_get_herencia_col(x.sproduc, 7, v_cduraci);

                        IF NVL(v_cduraci, 0) IN(1, 2)
                           AND num_err = 0 THEN
                           IF v_cduraci = 1 THEN
                              num_err := pac_seguros.f_get_tipo_duracion_cero(NULL, x.npoliza,
                                                                              'SEG', vcduraci);

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           ELSIF v_cduraci = 2 THEN
                              vcduraci := 6;
                           END IF;

                           v_seguros.cduraci := vcduraci;
                        ELSE
                           v_seguros.cduraci := reg_productos.cduraci;
                        END IF;
                     ELSE
                        v_seguros.cduraci := reg_productos.cduraci;
                     END IF;
                  END IF;

                  --
                  v_seguros.crecfra := reg_productos.crecfra;
                  v_seguros.prevali := reg_productos.prevali;
                  v_seguros.irevali := reg_productos.irevali;
                  v_seguros.crevali := reg_productos.crevali;
                  v_seguros.cagrpro := reg_productos.cagrpro;
                  v_traza := '31';

                  --crevali,irevali y prevali si no viene informado crevali,
                  --valores definidos a nivel de producto
                  IF x.crevali IS NULL THEN
                     v_seguros.prevali := reg_productos.prevali;
                     v_seguros.irevali := reg_productos.irevali;
                     v_seguros.crevali := reg_productos.crevali;
                  ELSE
                     v_seguros.prevali := x.prevali;
                     v_seguros.irevali := x.irevali;
                     v_seguros.crevali := x.crevali;
                  END IF;

                  v_traza := '35';
                  v_seguros.ndurcob := NVL(x.ndurcob, reg_productos.ndurcob);

                  --Obtenemos sseguro
                                  -- JLB - 23289/120321
                  IF ptablas = 'EST' THEN
                     SELECT sestudi.NEXTVAL
                       INTO v_seguros.sseguro
                       FROM DUAL;

                     SELECT sseguro.NEXTVAL
                       INTO v_ssegpol
                       FROM DUAL;
                  ELSE   -- pol
                     SELECT sseguro.NEXTVAL
                       INTO v_seguros.sseguro
                       FROM DUAL;
                  END IF;

                  IF v_seguros.npoliza = 0 THEN
                     IF ptablas <> 'EST' THEN
                        -- BUG 17008 - 15/12/2010 - JMP - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nº de póliza
                        -- v_seguros.npoliza := f_contador('02', v_seguros.cramo);
                        v_seguros.npoliza := pac_propio.f_contador2(v_seguros.cempres, '02',
                                                                    v_seguros.cramo);

                        IF NVL(f_parproductos_v(v_seguros.sproduc, 'NPOLIZA_EN_EMISION'), 0) =
                                                                                             0 THEN
                           DECLARE
                              v_numaddpoliza NUMBER;
                           BEGIN
                              v_numaddpoliza :=
                                 pac_parametros.f_parempresa_n(v_seguros.cempres,
                                                               'NUMADDPOLIZA');
                              v_seguros.npoliza := v_seguros.npoliza + NVL(v_numaddpoliza, 0);
                           END;
                        END IF;
                     ELSE
                        -- v_seguros.npoliza := v_seguros.sseguro;
                          -- Si el npoliza se asigan en la emisión, se graba el número de solicitud
                        IF NVL(f_parproductos_v(v_seguros.sproduc, 'NPOLIZA_EN_EMISION'), 0) =
                                                                                             1 THEN
                           v_seguros.nsolici := pac_propio.f_numero_solici(v_seguros.cempres,
                                                                           v_seguros.cramo);
                           v_seguros.npoliza :=
                              pac_parametros.f_parempresa_n(v_seguros.cempres, 'NUMADDPOLIZA')
                              + v_seguros.sseguro;
                        END IF;
                     END IF;
                  END IF;

                  v_traza := '36';

                  IF reg_productos.cpagdef = 1 THEN
                     v_seguros.nfracci := 0;
                  ELSE
                     v_seguros.nfracci := 1;
                  END IF;

                  v_traza := '38';

                  IF x.crecfra IS NOT NULL THEN
                     v_seguros.crecfra := x.crecfra;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error al obtener producto : ' || SQLCODE
                                                    || '-' || SQLERRM);
                     v_error := TRUE;
                     ROLLBACK;
               END;

               v_traza := '40';

               -- BUG 14185 - 11-05-2010 - JMC - En caso de producto colectivo, calculamos el ncertif.
               IF NOT v_error
                  AND((reg_productos.csubpro = 3
                       OR(NVL(f_parproductos_v(v_seguros.sproduc, 'ADMITE_CERTIFICADOS'), 0) =
                                                                                              1))
                      AND NOT pac_iax_produccion.isaltacol)
                  AND x.ncertif = 0 THEN
                  BEGIN   -- 23289/120321 - JLB  - 03/09/2012  Fin
                     SELECT NVL(MAX(ncertif), 0) + 1
                       INTO v_seguros.ncertif
                       FROM seguros
                      WHERE npoliza = v_seguros.npoliza;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                       'Error al obtener ncertif : '
                                                       || SQLCODE || '-' || SQLERRM);
                        v_error := TRUE;
                        ROLLBACK;
                  END;
               ELSIF NVL(f_parproductos_v(v_seguros.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                     AND NOT pac_iax_produccion.isaltacol
                     AND x.ncertif <> 0 THEN
                  NULL;   -- dejo el certificado que me llega.
               ELSE
                  v_seguros.ncertif := 0;
               END IF;

               --Calculamos el nduraci
               v_traza := '100';
               v_fvencim := v_seguros.fvencim;
               v_traza := '110';
               num_err := pac_calc_comu.f_calcula_fvencim_nduraci(v_seguros.sproduc,
                                                                  v_seguros.fefecto,
                                                                  v_seguros.fefecto,
                                                                  v_seguros.cduraci,
                                                                  v_seguros.nduraci, v_fvencim,
                                                                  NULL, NULL,
                                                                  v_seguros.nedamar);   -- Bug 0025584 - MMS - 25/03/2013
               v_traza := '120';

               IF num_err <> 0 THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'W',
                                                 'Error al obtener nduraci : ' || num_err);
                  v_seguros.nduraci := 0;
               END IF;

                -- BUG 0025537 - JMF - 19/08/2013 : Para este bug necesitamos calculo frenova en propuesta alta
                -- JLB -- debo calcular siempre el nrenova
               /*

                IF (v_seguros.csituac = 0)   -- si la dejo como vigente si que debo calcular las fechas
                   OR(NVL(pac_parametros.f_parempresa_n(v_cempres, 'MIG_SITFECCAR'), 0) = 1
                      AND v_seguros.csituac IN(0, 4)) THEN
                   -- IF v_seguros.csituac = 0 THEN   -- si la dejo como vigente si que debo calcular las fechas
                   -- fin BUG 0025537 - JMF - 19/08/2013
                   IF x.fcarpro IS NULL
                      AND x.fcarant IS NULL
                      AND x.fcaranu IS NULL THEN
                      --Obtenemos fechas de cartera
                      num_err := f_fecha_cartera(v_seguros, reg_productos, v_seguros.fcaranu,
                                                 v_seguros.fcarpro, v_seguros.fcarant);

                      IF num_err <> 0 THEN
                         num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                        'Error al obtener fecha cartera : '
                                                        || num_err);
                         v_error := TRUE;
                         ROLLBACK;
                      END IF;
                   END IF;
                END IF;   --
               */
               num_err := f_fecha_cartera(v_seguros, reg_productos, v_seguros.fcaranu,
                                          v_seguros.fcarpro, v_seguros.fcarant);

               IF num_err <> 0 THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error al obtener fecha cartera : '
                                                 || num_err);
                  v_error := TRUE;
                  ROLLBACK;
               END IF;

               IF (NVL(pac_parametros.f_parempresa_n(v_cempres, 'MIG_SITFECCAR'), 0) = 0
                   AND v_seguros.csituac IN(4, 7)) THEN
                  v_seguros.fcaranu := NULL;
                  v_seguros.fcarpro := NULL;
                  v_seguros.fcarant := NULL;
               END IF;

               -- fin de necesidad de calcular el nrenova y el frenova siempre, respetando cambio de joan miramunt
               IF x.fcarant IS NOT NULL THEN
                  v_seguros.fcarant := x.fcarant;
               END IF;

               IF x.fcarpro IS NOT NULL THEN
                  v_seguros.fcarpro := x.fcarpro;
               END IF;

               IF x.fcaranu IS NOT NULL THEN
                  v_seguros.fcaranu := x.fcaranu;
               END IF;

               IF x.nduraci IS NOT NULL THEN
                  v_seguros.nduraci := x.nduraci;
               END IF;

               v_traza := '41';

               -- FIN BUG 14185 - 11-05-2010 - JMC
               --Obtenemos el nrenova
               BEGIN
                  --    dtpoliza := ob_iax_detpoliza();
                    --  num_err := pac_md_produccion.f_calcula_nrenova(v_seguros.sproduc,
                      --                                               NVL(v_seguros.fefecto,
                        --                                                 f_sysdate),
                          --                                           dtpoliza, t_mensajes);
                  --calculamos la nrenova a partir de la fcaranu
                  num_err :=
                     pac_calc_comu.f_calcula_nrenova(v_seguros.sproduc,
                                                     NVL(NVL(NVL(v_seguros.fcaranu,
                                                                 v_seguros.fcarant),
                                                             v_seguros.fefecto),
                                                         f_sysdate),
                                                     v_seguros.nrenova);

                  IF num_err <> 0 THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'f_calcula_nrenova : ' || num_err);
                     v_error := TRUE;
                  --   ELSE
                    --    v_seguros.nrenova := dtpoliza.nrenova;
                  END IF;
               -- FI BUG 25583/0136619
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error al obtener nrenova : ' || SQLCODE
                                                    || '-' || SQLERRM);
                     v_error := TRUE;
                     ROLLBACK;
               END;

               -- BUG 26050- FAL - 26/08/2013
               IF v_seguros.frenova IS NOT NULL THEN
                  v_seguros.nrenova := TO_CHAR(v_seguros.frenova, 'mmdd');
               END IF;

               -- 24818 -- Indico proceso
               v_seguros.procesocarga := NVL(x.proceso, 0);

               IF NOT v_error THEN
                  -- JLB 23289/120321
                  --Insertamos registro en SEGUROS
                  BEGIN
                     -- 23289/120321 - GAG - 23/08/2012
                     IF ptablas = 'EST' THEN
                        INSERT INTO estseguros
                                    (sseguro, cmodali, ccolect,
                                     ctipseg, casegur, cagente,
                                     cramo, npoliza, ncertif,
                                     nsuplem, fefecto, creafac,
                                     ctarman, cobjase, ctipreb,
                                     cactivi, ccobban, ctipcoa,
                                     ctiprea, crecman, creccob,
                                     ctipcom, fvencim, femisio,
                                     fanulac, fcancel, csituac,
                                     cbancar, ctipcol, fcarant, fcarpro, fcaranu,
                                     cduraci, nduraci, nanuali,
                                     iprianu, cidioma, nfracci,
                                     cforpag, pdtoord, nrenova,
                                     crecfra, tasegur, creteni,
                                     ndurcob, sciacoa, pparcoa,
                                     npolcoa, nsupcoa, tnatrie,
                                     pdtocom, prevali, irevali,
                                     ncuacoa, nedamed, crevali,
                                     cempres, cagrpro, ssegpol, ctipest,
                                     ccompani, nparben, nbns,
                                     ctramo, cindext, pdispri,
                                     idispri, cimpase, sproduc,
                                     intpres, nmescob,
                                     cnotibaja, ccartera,
                                     cagencorr, nsolici,
                                     fimpsol, ctipban, ctipcob,
                                     sprodtar, polissa_ini, csubage,
                                     cpolcia, cpromotor,
                                     cmoneda, ncuotar,
                                     ctipretr, cindrevfran,
                                     precarg, pdtotec, preccom,
                                     cdomper, frenova, nedamar,
                                     -- 24818 -- Indico proceso
                                     procesocarga)   -- Bug 25584/0135342 - MMS - 25/03/2013
                             VALUES (v_seguros.sseguro, v_seguros.cmodali, v_seguros.ccolect,
                                     v_seguros.ctipseg, v_seguros.casegur, v_seguros.cagente,
                                     v_seguros.cramo, v_seguros.npoliza, v_seguros.ncertif,
                                     v_seguros.nsuplem, v_seguros.fefecto, v_seguros.creafac,
                                     v_seguros.ctarman, v_seguros.cobjase, v_seguros.ctipreb,
                                     v_seguros.cactivi, v_seguros.ccobban, v_seguros.ctipcoa,
                                     v_seguros.ctiprea, v_seguros.crecman, v_seguros.creccob,
                                     v_seguros.ctipcom, v_seguros.fvencim, v_seguros.femisio,
                                     v_seguros.fanulac, v_seguros.fcancel, v_seguros.csituac,
                                     v_seguros.cbancar, v_seguros.ctipcol, NULL,
                                                                                -- v_seguros.fcarant,
                                     NULL, NULL,
                                     --v_seguros.fcarpro, v_seguros.fcaranu,
                                     v_seguros.cduraci, v_seguros.nduraci, v_seguros.nanuali,
                                     v_seguros.iprianu, v_seguros.cidioma, v_seguros.nfracci,
                                     v_seguros.cforpag, v_seguros.pdtoord, v_seguros.nrenova,
                                     v_seguros.crecfra, v_seguros.tasegur, v_seguros.creteni,
                                     v_seguros.ndurcob, v_seguros.sciacoa, v_seguros.pparcoa,
                                     v_seguros.npolcoa, v_seguros.nsupcoa, v_seguros.tnatrie,
                                     v_seguros.pdtocom, v_seguros.prevali, v_seguros.irevali,
                                     v_seguros.ncuacoa, v_seguros.nedamed, v_seguros.crevali,
                                     v_seguros.cempres, v_seguros.cagrpro, v_ssegpol, NULL,
                                     v_seguros.ccompani, v_seguros.nparben, v_seguros.nbns,
                                     v_seguros.ctramo, v_seguros.cindext, v_seguros.pdispri,
                                     v_seguros.idispri, v_seguros.cimpase, v_seguros.sproduc,
                                     v_seguros.intpres, v_seguros.nmescob,
                                     v_seguros.cnotibaja, v_seguros.ccartera,
                                     v_seguros.cagencorr, v_seguros.nsolici,
                                     v_seguros.fimpsol, v_seguros.ctipban, v_seguros.ctipcob,
                                     v_seguros.sprodtar, NULL, v_seguros.csubage,
                                     v_seguros.cpolcia, v_seguros.cpromotor,
                                     v_seguros.cmoneda, v_seguros.ncuotar,
                                     v_seguros.ctipretr, v_seguros.cindrevfran,
                                     v_seguros.precarg, v_seguros.pdtotec, v_seguros.preccom,
                                     NULL, v_seguros.frenova, v_seguros.nedamar,
                                     -- 24818 -- Indico proceso
                                     v_seguros.procesocarga);   -- Bug 25584/0135342 - MMS - 25/03/2013
                     ELSE
                        INSERT INTO seguros
                             VALUES v_seguros;
                     END IF;

                     INSERT INTO mig_pk_mig_axis
                          VALUES (x.mig_pk, pncarga, pntab, 1, v_seguros.sseguro);

                     UPDATE mig_seguros
                        SET sseguro = v_seguros.sseguro,
                            cestmig = 2
                      WHERE mig_pk = x.mig_pk;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err :=
                           f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                               SUBSTR('Error(seguros) 1:' || SQLERRM
                                                      || CHR(10)
                                                      || DBMS_UTILITY.format_error_backtrace,
                                                      1, 500));
                        v_error := TRUE;
                        ROLLBACK;
                  END;

                  /*                IF ptablas <> 'EST' THEN
                                 IF v_propietario THEN
                                      --Insertamos en SEGUREDCOM, solo si somos el propietario del
                                      --Trigger ACTUALIZ_SEGUREDCOM, ya que si no lo somos este trigger
                                      --estara activo y ya habra hecho el Insert
                                      BEGIN
                                         num_err := pac_redcomercial.calcul_redcomseg(v_seguros.cempres,
                                                                                      v_seguros.cagente,
                                                                                      v_seguros.sseguro,
                                                                                      v_seguros.fefecto,
                                                                                      NULL);

                                         IF num_err <> 0 THEN
                                            num_err :=
                                               f_ins_mig_logs_axis
                                                               (pncarga, x.mig_pk, 'E',
                                                                'Error(seguredcom), parámetros: cempres='
                                                                || v_seguros.cempres || ', cagente='
                                                                || v_seguros.cagente || ', sseguro='
                                                                || v_seguros.sseguro || ', fefecto='
                                                                || v_seguros.fefecto || ', num_err='
                                                                || num_err);
                                            v_error := TRUE;
                                            ROLLBACK;
                                         END IF;
                                      EXCEPTION
                                         WHEN OTHERS THEN
                                            num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                                           'Error(seguredcom):' || SQLCODE
                                                                           || '-' || SQLERRM);
                                            v_error := TRUE;
                                            ROLLBACK;
                                      END;
                                   END IF;
                                END IF; */

                  --Obtenemos la persona que es el tomador
                  BEGIN
                     SELECT idperson
                       INTO v_sperson
                       FROM mig_personas
                      WHERE mig_pk = x.mig_fk
                                             --AND ncarga = pncarga
                     ;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                       'Error al obtener el Tomador :'
                                                       || SQLCODE || '-' || SQLERRM);
                        v_error := TRUE;
                  END;

                  --INI -- ETM --BUG 34776/202076--
                  v_sperson_2 := NULL;

                  --Obtenemos la persona que es el tomador 2
                  IF x.mig_fk2 IS NOT NULL THEN
                     BEGIN
                        SELECT idperson
                          INTO v_sperson_2
                          FROM mig_personas
                         WHERE mig_pk = x.mig_fk2
                                                 --AND ncarga = pncarga
                        ;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                  'Error al obtener el Tomador  2 :'
                                                  || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                     END;
                  END IF;

                  --FIN -- ETM --BUG 34776/202076--
                  v_traza := '200';

                  IF NOT v_error
                     AND x.cbancar IS NOT NULL THEN
                     p_migra_per_ccc(x.mig_pk, x.proceso);
                  END IF;

                  v_traza := '220';

                  IF NOT v_error THEN
                     --Insertamos registro en la tabla TOMADORES
                     -- 23289/120321 - ECP - 03/09/2012 Inicio
                     IF ptablas = 'EST' THEN
                        SELECT COUNT('*')
                          INTO v_cdomici
                          FROM estper_direcciones
                         WHERE sperson = v_sperson
                           AND cdomici = x.cdomici;

                        v_traza := '230';

                        IF v_cdomici = 0 THEN
                           SELECT MIN(cdomici)
                             INTO v_cdomici
                             FROM estper_direcciones
                            WHERE sperson = v_sperson;
                        ELSE
                           v_cdomici := x.cdomici;
                        END IF;

                        --INI -- ETM --BUG 34776/202076--
                        IF v_sperson_2 IS NOT NULL THEN
                           SELECT COUNT('*')
                             INTO v_cdomici_2
                             FROM estper_direcciones
                            WHERE sperson = v_sperson_2
                              AND cdomici = x.cdomici;

                           v_traza := '230';

                           IF v_cdomici_2 = 0 THEN
                              SELECT MIN(cdomici)
                                INTO v_cdomici_2
                                FROM estper_direcciones
                               WHERE sperson = v_sperson_2;
                           ELSE
                              v_cdomici_2 := x.cdomici;
                           END IF;
                        END IF;
                     --FIN -- ETM --BUG 34776/202076--
                     ELSE
                        SELECT COUNT(*)
                          INTO v_cdomici
                          FROM per_direcciones
                         WHERE sperson = v_sperson
                           AND cdomici = x.cdomici;

                        v_traza := '230';

                        IF v_cdomici = 0 THEN
                           SELECT MIN(cdomici)
                             INTO v_cdomici
                             FROM per_direcciones
                            WHERE sperson = v_sperson;
                        ELSE
                           v_cdomici := x.cdomici;
                        END IF;

                        --INI -- ETM --BUG 34776/202076--
                        IF v_sperson_2 IS NOT NULL THEN
                           SELECT COUNT(*)
                             INTO v_cdomici_2
                             FROM per_direcciones
                            WHERE sperson = v_sperson_2
                              AND cdomici = x.cdomici;

                           v_traza := '230';

                           IF v_cdomici_2 = 0 THEN
                              SELECT MIN(cdomici)
                                INTO v_cdomici_2
                                FROM per_direcciones
                               WHERE sperson = v_sperson_2;
                           ELSE
                              v_cdomici_2 := x.cdomici;
                           END IF;
                        --FIN -- ETM --BUG 34776/202076--
                        END IF;
                     END IF;

                     -- 23289/120321 - ECP - 03/09/2012 Fin
                     v_traza := '240';

                     BEGIN
                        -- 23289/120321 - GAG - 23/08/2012
                        IF ptablas = 'EST' THEN
                           INSERT INTO esttomadores
                                       (sperson, sseguro, nordtom, cdomici)
                                VALUES (v_sperson, v_seguros.sseguro, 1, v_cdomici);

                           --ini -- ETM --BUG 34776/202076--
                           IF v_sperson_2 IS NOT NULL THEN
                              INSERT INTO esttomadores
                                          (sperson, sseguro, nordtom, cdomici)
                                   VALUES (v_sperson_2, v_seguros.sseguro, 2, v_cdomici_2);
                           END IF;
                        --FIN -- ETM --BUG 34776/202076--
                        ELSE
                           INSERT INTO tomadores
                                       (sperson, sseguro, nordtom, cdomici)
                                VALUES (v_sperson, v_seguros.sseguro, 1, v_cdomici);

                           --ini -- ETM --BUG 34776/202076--
                           IF v_sperson_2 IS NOT NULL THEN
                              INSERT INTO tomadores
                                          (sperson, sseguro, nordtom, cdomici)
                                   VALUES (v_sperson_2, v_seguros.sseguro, 2, v_cdomici_2);
                           END IF;
                        --FIN -- ETM --BUG 34776/202076--
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, 2,
                                     v_seguros.sseguro || '|' || v_sperson);

                        UPDATE mig_seguros
                           SET sseguro = v_seguros.sseguro,
                               sperson = v_sperson,
                               cestmig = 3
                         WHERE mig_pk = x.mig_pk;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                          'Error(tomadores):' || SQLCODE
                                                          || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;

                     v_traza := '250';

                     --Insertamos la póliza original
                     IF x.npolini IS NOT NULL
                        AND NOT v_error THEN
                        BEGIN
                           INSERT INTO cnvpolizas
                                       (sistema, polissa_ini, producte, aplica, ram,
                                        moda, npoliza,
                                        sseguro, activitat, tipo,
                                        cole, cdescuadre)
                                VALUES (0, x.npolini, x.sproduc, 0, v_seguros.cramo,
                                        v_seguros.cmodali, v_seguros.npoliza,
                                        v_seguros.sseguro, 0, v_seguros.ctipseg,
                                        v_seguros.ccolect, 0);

                           INSERT INTO mig_pk_mig_axis
                                VALUES (x.mig_pk, pncarga, pntab, 3, '0|' || x.npolini);

                           UPDATE mig_seguros
                              SET sseguro = v_seguros.sseguro,
                                  cestmig = 4
                            WHERE mig_pk = x.mig_pk;
                        EXCEPTION
                           WHEN OTHERS THEN
                              num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                             'Error(cnvpolizas):' || SQLCODE
                                                             || '-' || SQLERRM);
                              v_error := TRUE;
                              ROLLBACK;
                        END;
                     END IF;

                     v_traza := '260';

                     --Insertamos en SEG_CBANCAR es caso de ser necesario
                     IF v_bancob
                        AND NOT v_error
                        AND(x.cbancar IS NOT NULL
                            OR x.cbancob IS NOT NULL) THEN
                        BEGIN
                           -- 23289/120321 - GAG - 29/08/2012
                           IF ptablas = 'EST' THEN
                              INSERT INTO estseg_cbancar
                                          (sseguro, nmovimi, finiefe, ffinefe,
                                           cbancar, cbancob)
                                   VALUES (v_seguros.sseguro, 1, v_seguros.fefecto,
                                                                                   /*v_seguros.fvencim*/
                                           NULL,
                                           NVL(x.cbancar, '000000000000'), x.cbancob);
                           ELSE
                              INSERT INTO seg_cbancar
                                          (sseguro, nmovimi, finiefe, ffinefe,
                                           cbancar, cbancob)
                                   VALUES (v_seguros.sseguro, 1, v_seguros.fefecto,
                                                                                   /*v_seguros.fvencim*/
                                           NULL,
                                           NVL(x.cbancar, '000000000000'), x.cbancob);
                           END IF;

                           INSERT INTO mig_pk_mig_axis
                                VALUES (x.mig_pk, pncarga, pntab, 5, v_seguros.sseguro || '|1');
                        EXCEPTION
                           WHEN OTHERS THEN
                              num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                             'Error(seg_cbancar):' || SQLCODE
                                                             || '-' || SQLERRM);
                              v_error := TRUE;
                              ROLLBACK;
                        END;
                     END IF;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error(seguros) 2: ' || v_traza || '-'
                                                 || SQLCODE || '-' || SQLERRM);
                  v_error := TRUE;
                  ROLLBACK;
            END;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, 'Inicio', 'E',
                                              'Error(1):' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

-- JLB - I -  08/07/2013
      --END IF;

      -- JLB - I -  08/07/2013
--      IF v_propietario THEN
  --       num_err := f_trata_trigger('ACTUALIZ_SEGUREDCOM', 'ENABLE');

      --         IF num_err = 99 THEN
--            num_err := f_ins_mig_logs_axis(pncarga, 'TRIGGER', 'E',
--                                           'Error al habilitar trigger ACTUALIZ_SEGUREDCOM ');
--            v_error := TRUE;
--         END IF;
--      END IF;
      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         SELECT COUNT(*)
           INTO v_cont
           FROM mig_logs_axis
          WHERE ncarga = pncarga
            AND tipo = 'W';

         IF v_cont > 0 THEN
            v_estdes := 'WARNING';
         ELSE
            v_estdes := 'OK';
         END IF;
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_estdes = 'ERROR' THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_seguros;

/***************************************************************************
      FUNCTION f_migra_seguros_ren_aho
      Función que inserta los registros grabados en MIG_SEGUROSREN_AHO, en las
      tablas SEGUROS_REN y SEGUROS_AHO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_seguros_ren_aho(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_seg_ren    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_seguros_ren  seguros_ren%ROWTYPE;
      v_seguros_aho  seguros_aho%ROWTYPE;
      --v_seguros      seguros%ROWTYPE;
      v_cont         NUMBER := 0;
      v_fecultpago   DATE;
      v_fecprimpago  DATE;
      v_importebruto seguros_ren.ibruren%TYPE;
      v_fecfinrenta  DATE;
      v_fechaproxpago DATE;
      v_fechainteres DATE;
      v_estadopago   seguros_ren.cestmre%TYPE;
      v_estadopagos  seguros_ren.cblopag%TYPE;
      v_durtramo     NUMBER;
      v_capinirent   seguros_ren.icapren%TYPE;
      v_tipoint      seguros_ren.ptipoint%TYPE;
      v_doscab       seguros_ren.pdoscab%TYPE;   --:=pctrevRT;  --JRH IMP
      v_capfallec    seguros_ren.pcapfall%TYPE;
      v_reserv       seguros_ren.ireserva%TYPE;
      v_fecrevi      DATE;
      --
      v_nduraci      seguros.nduraci%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
      v_fvencim      seguros.fvencim%TYPE;
      vnmesextra     producto_ren.nmesextra%TYPE;
      vcmodextra     producto_ren.cmodextra%TYPE;
      vimesextra     producto_ren.imesextra%TYPE;
      -- JLB
      vnmovimi       garanseg.nmovimi%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      --Tratamos cada una de las polizas.
      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, p.cagrpro cagrpro
                    FROM mig_seguros_ren_aho a, mig_seguros s, productos p
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                     AND p.sproduc = s.sproduc
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_seg_ren THEN
               v_1_seg_ren := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 3, 'SEGUROS_REN');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'INTERTECSEG');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 2, 'SEGUROS_AHO');
            END IF;

            v_error := FALSE;

/*            BEGIN
               -- 23289/120321 - ECP - 03/09/2012  Inicio
               IF ptablas = 'EST' THEN
                  INSERT INTO estseguros
                              (sseguro, cmodali, ccolect,
                               ctipseg, casegur, cagente,
                               cramo, npoliza, ncertif,
                               nsuplem, fefecto, creafac,
                               ctarman, cobjase, ctipreb,
                               cactivi, ccobban, ctipcoa,
                               ctiprea, crecman, creccob,
                               ctipcom, fvencim, femisio,
                               fanulac, fcancel, csituac,
                               cbancar, ctipcol, fcarant,
                               fcarpro, fcaranu, cduraci,
                               nduraci, nanuali, iprianu,
                               cidioma, nfracci, cforpag,
                               pdtoord, nrenova, crecfra,
                               tasegur, creteni, ndurcob,
                               sciacoa, pparcoa, npolcoa,
                               nsupcoa, tnatrie, pdtocom,
                               prevali, irevali, ncuacoa,
                               nedamed, crevali, cempres,
                               cagrpro, ssegpol, ctipest, ccompani,
                               nparben, nbns, ctramo,
                               cindext, pdispri, idispri,
                               cimpase, sproduc, intpres,
                               nmescob, cnotibaja, ccartera,
                               cagencorr, nsolici, fimpsol,
                               ctipban, ctipcob, sprodtar,
                               polissa_ini, csubage, cpolcia,
                               cpromotor, cmoneda, ncuotar,
                               ctipretr, cindrevfran, precarg,
                               pdtotec, preccom, cdomper, frenova,
                               nedamar)   -- Bug 25584/0135342 - MMS - 25/03/2013
                       VALUES (v_seguros.sseguro, v_seguros.cmodali, v_seguros.ccolect,
                               v_seguros.ctipseg, v_seguros.casegur, v_seguros.cagente,
                               v_seguros.cramo, v_seguros.npoliza, v_seguros.ncertif,
                               v_seguros.nsuplem, v_seguros.fefecto, v_seguros.creafac,
                               v_seguros.ctarman, v_seguros.cobjase, v_seguros.ctipreb,
                               v_seguros.cactivi, v_seguros.ccobban, v_seguros.ctipcoa,
                               v_seguros.ctiprea, v_seguros.crecman, v_seguros.creccob,
                               v_seguros.ctipcom, v_seguros.fvencim, v_seguros.femisio,
                               v_seguros.fanulac, v_seguros.fcancel, v_seguros.csituac,
                               v_seguros.cbancar, v_seguros.ctipcol, v_seguros.fcarant,
                               v_seguros.fcarpro, v_seguros.fcaranu, v_seguros.cduraci,
                               v_seguros.nduraci, v_seguros.nanuali, v_seguros.iprianu,
                               v_seguros.cidioma, v_seguros.nfracci, v_seguros.cforpag,
                               v_seguros.pdtoord, v_seguros.nrenova, v_seguros.crecfra,
                               v_seguros.tasegur, v_seguros.creteni, v_seguros.ndurcob,
                               v_seguros.sciacoa, v_seguros.pparcoa, v_seguros.npolcoa,
                               v_seguros.nsupcoa, v_seguros.tnatrie, v_seguros.pdtocom,
                               v_seguros.prevali, v_seguros.irevali, v_seguros.ncuacoa,
                               v_seguros.nedamed, v_seguros.crevali, v_seguros.cempres,
                               v_seguros.cagrpro, NULL, NULL, v_seguros.ccompani,
                               v_seguros.nparben, v_seguros.nbns, v_seguros.ctramo,
                               v_seguros.cindext, v_seguros.pdispri, v_seguros.idispri,
                               v_seguros.cimpase, v_seguros.sproduc, v_seguros.intpres,
                               v_seguros.nmescob, v_seguros.cnotibaja, v_seguros.ccartera,
                               v_seguros.cagencorr, v_seguros.nsolici, v_seguros.fimpsol,
                               v_seguros.ctipban, v_seguros.ctipcob, v_seguros.sprodtar,
                               NULL, v_seguros.csubage, v_seguros.cpolcia,
                               v_seguros.cpromotor, v_seguros.cmoneda, v_seguros.ncuotar,
                               v_seguros.ctipretr, v_seguros.cindrevfran, v_seguros.precarg,
                               v_seguros.pdtotec, v_seguros.preccom, NULL, v_seguros.frenova,
                               v_seguros.nedamar);   -- Bug 25584/0135342 - MMS - 25/03/2013
               ELSIF ptablas = 'POL' THEN
                  SELECT *
                    INTO v_seguros
                    FROM seguros
                   WHERE sseguro = x.s_sseguro;
               END IF;

            -- 23289/120321 - ECP - 03/09/2012  Fin
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error al obtener datos de SEGUROS:'
                                                 || SQLCODE);
                  v_error := TRUE;
            END;
   */
            IF ptablas = 'EST' THEN
               SELECT s.nduraci, s.sproduc, s.fefecto, s.fvencim
                 INTO v_nduraci, v_sproduc, v_fefecto, v_fvencim
                 FROM estseguros s
                WHERE sseguro = x.s_sseguro;

               SELECT MAX(nmovimi)
                 INTO vnmovimi
                 FROM estgaranseg
                WHERE sseguro = x.s_sseguro;
            ELSE
               SELECT s.nduraci, s.sproduc, s.fefecto, s.fvencim
                 INTO v_nduraci, v_sproduc, v_fefecto, v_fvencim
                 FROM seguros s
                WHERE sseguro = x.s_sseguro;

               SELECT MAX(nmovimi)
                 INTO vnmovimi
                 FROM garanseg
                WHERE sseguro = x.s_sseguro;
            END IF;

            BEGIN   -- jlb -- controlo si me llega el regisgtro mig_seguros_ren_aho, pero el producto no soporta rentas.
               SELECT nmesextra, cmodextra, imesextra
                 INTO vnmesextra, vcmodextra, vimesextra
                 FROM producto_ren
                WHERE sproduc = v_sproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  num_err :=
                     f_ins_mig_logs_axis
                                (pncarga, x.mig_pk, 'E',
                                 'Error al recuperar cfg rentas(seguros_aho): producto_ren'
                                 || ' - SPRODUC: ' || v_sproduc);
                  v_error := TRUE;
                  ROLLBACK;
            END;

            IF NOT v_error THEN
               BEGIN
                  -- 23289/120321 - ECP - 03/09/2012  Inicio
                  IF ptablas = 'EST' THEN
                     num_err := f_grabar_inttec(v_sproduc, x.s_sseguro, v_fefecto, vnmovimi,
                                                x.pinttec, NULL, NULL, 'EST');
                  ELSE
                     num_err := f_grabar_inttec(v_sproduc, x.s_sseguro, v_fefecto, vnmovimi,
                                                x.pinttec, NULL, NULL, 'POL');
                  END IF;

                  -- 23289/120321 - ECP - 03/09/2012  Fin
                  IF num_err <> 0 THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error(intertecseg):' || num_err);
                     v_error := TRUE;
                     ROLLBACK;
                  ELSE
                     INSERT INTO mig_pk_mig_axis
                          VALUES (x.mig_pk, pncarga, pntab, 1, x.s_sseguro || '|1|0');

                     UPDATE mig_seguros_ren_aho
                        SET cestmig = 2
                      WHERE mig_pk = x.mig_pk;
                  END IF;

                  IF NOT v_error THEN
                     v_seguros_aho := NULL;
                     v_seguros_aho.sseguro := x.s_sseguro;
                     v_seguros_aho.pinttec := x.pinttec;
                     v_seguros_aho.ndurper := x.ndurper;
                     v_seguros_aho.frevisio := x.frevisio;
                     v_seguros_aho.frevant := x.frevant;

                     BEGIN
                        -- 23289/120321 - ECP - 29/08/2012
                        IF ptablas = 'EST' THEN
                           INSERT INTO estseguros_aho
                                VALUES v_seguros_aho;
                        ELSE
                           INSERT INTO seguros_aho
                                VALUES v_seguros_aho;
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, 2, x.s_sseguro);

                        UPDATE mig_seguros_ren_aho
                           SET cestmig = 3
                         WHERE mig_pk = x.mig_pk;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                  'Error al insertar(seguros_aho):' || SQLCODE
                                                  || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
                  END IF;

                  IF NOT v_error
                     -- AND v_seguros.cagrpro = 10 THEN
                     AND x.cagrpro IN(10, 22) THEN
                     v_doscab := x.pdoscab;
                     v_seguros_ren := NULL;

                     IF vnmovimi = 1 THEN   -- si sol hay es nmovimi solo llamo una vez sino tengo que llamar dos veces
                        num_err :=
                           pac_calc_rentas.f_obtener_datos_rentas_ini
                                                      (x.s_sseguro, v_sproduc, v_fefecto,
                                                       v_fvencim, v_nduraci,   --v_seguros.nduraci,
                                                       v_fecultpago, v_fecprimpago,
                                                       v_seguros_ren.ibruren,   --v_importebruto,
                                                       v_fecfinrenta, v_fechaproxpago,
                                                       v_fechainteres, v_estadopago,
                                                       v_estadopagos, v_durtramo,
                                                       v_capinirent, v_tipoint, v_doscab,
                                                       v_capfallec, v_reserv, v_fecrevi,

                                                       --'SEG');
                                                       ptablas, vnmovimi);
                     ELSE
                        num_err :=
                           pac_calc_rentas.f_obtener_datos_rentas_ini
                                                     (x.s_sseguro, v_sproduc, v_fefecto,
                                                      v_fvencim, v_nduraci,   --v_seguros.nduraci,
                                                      v_fecultpago, v_fecprimpago,
                                                      v_seguros_ren.ibruren,   -- v_importebruto,
                                                      v_fecfinrenta, v_fechaproxpago,
                                                      v_fechainteres, v_estadopago,
                                                      v_estadopagos, v_durtramo, v_capinirent,
                                                      v_tipoint, v_doscab, v_capfallec,
                                                      v_reserv, v_fecrevi,
                                                      --'SEG');
                                                      ptablas, 1);

                        IF num_err = 0 THEN
                           num_err :=
                              pac_calc_rentas.f_obtener_datos_rentas_ini
                                                               (x.s_sseguro, v_sproduc,
                                                                v_fefecto, v_fvencim,
                                                                v_nduraci,   --v_seguros.nduraci,
                                                                v_fecultpago, v_fecprimpago,
                                                                v_importebruto, v_fecfinrenta,
                                                                v_fechaproxpago,
                                                                v_fechainteres, v_estadopago,
                                                                v_estadopagos, v_durtramo,
                                                                v_capinirent, v_tipoint,
                                                                v_doscab, v_capfallec,
                                                                v_reserv, v_fecrevi,
                                                                --'SEG');
                                                                ptablas, vnmovimi);
                        END IF;
                     END IF;

                     IF num_err <> 0 THEN
                        num_err :=
                           f_ins_mig_logs_axis
                                      (pncarga, x.mig_pk, 'E',
                                       'Error(pac_calc_rentas.f_obtener_datos_rentas_ini):'
                                       || num_err);
                        v_error := TRUE;
                     ELSE
                        v_doscab := x.pdoscab;
                        --
                        v_seguros_ren.sseguro := x.s_sseguro;
                        -- v_seguros_ren.f1paren := NVL(v_fecprimpago, v_seguros.fefecto);
                        -- JLB - I -
                          -- v_seguros_ren.f1paren := NVL(v_fecprimpago, v_fefecto);
                        v_seguros_ren.f1paren := NVL(x.f1paren, x.fppren);

                        IF v_seguros_ren.f1paren IS NULL THEN
                           v_seguros_ren.f1paren := NVL(v_fecprimpago, v_fefecto);
                        END IF;

                        -- JLB - F -
                        v_seguros_ren.fuparen := v_fecultpago;
                        v_seguros_ren.cforpag := x.cforpag;
                        --v_seguros_ren.ibruren := v_importebruto;
                        v_seguros_ren.ffinren := v_fecfinrenta;
                        v_seguros_ren.cmotivo := NULL;
                        v_seguros_ren.cmodali := NULL;
                        v_seguros_ren.fppren := NVL(x.fppren, v_fechaproxpago);
                        v_seguros_ren.ibrure2 := NULL;
                        v_seguros_ren.fintgar := v_fechainteres;
                        v_seguros_ren.cestmre := v_estadopago;
                        v_seguros_ren.cblopag := v_estadopagos;
                        --v_seguros_ren.nduraint := v_durtramo;
                        v_seguros_ren.icapren := v_capinirent;
                        v_seguros_ren.ptipoint := v_tipoint;
                        v_seguros_ren.pdoscab := v_doscab;
                        v_seguros_ren.pcapfall := NVL(x.pcapfall, 0);

                        IF NVL(vcmodextra, 0) <> 0 THEN
                           v_seguros_ren.nmesextra := x.nmesextra;
                           v_seguros_ren.imesextra := x.imesextra;
                        ELSE
                           v_seguros_ren.nmesextra := vnmesextra;
                           v_seguros_ren.imesextra := vimesextra;
                        END IF;

                        IF NVL(v_seguros_ren.icapren, 0) <> 0 THEN
                           v_seguros_ren.tipocalcul := 1;
                        ELSE
                           v_seguros_ren.tipocalcul := 2;
                        END IF;

                        /*
                                             IF f_parproductos_v(v_seguros.sproduc, 'DURPER') = 1 THEN
                           v_seguros_ren.frevisio :=
                                              ADD_MONTHS(v_seguros.fefecto, NVL(x.ndurper, 0));
                        END IF;
                        */
                        BEGIN
                           -- 23289/120321 - GAG - 29/08/2012
                           IF ptablas = 'EST' THEN
                              INSERT INTO estseguros_ren
                                   VALUES v_seguros_ren;
                           ELSE
                              INSERT INTO seguros_ren
                                   VALUES v_seguros_ren;
                           END IF;

                           INSERT INTO mig_pk_mig_axis
                                VALUES (x.mig_pk, pncarga, pntab, 3, x.s_sseguro);

                           UPDATE mig_seguros_ren_aho
                              SET cestmig = 4
                            WHERE mig_pk = x.mig_pk;
                        EXCEPTION
                           WHEN OTHERS THEN
                              num_err :=
                                 f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                     'Error al insertar(seguros_ren):'
                                                     || SQLCODE || '-' || SQLERRM);
                              v_error := TRUE;
                              ROLLBACK;
                        END;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error(seguros_ren_aho):' || SQLCODE
                                                    || '-' || SQLERRM);
                     v_error := TRUE;
                     ROLLBACK;
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, 'Inicio', 'E',
                                              'Error(1):' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_seguros_ren_aho;

/***************************************************************************
      FUNCTION f_migra_asegurados
      Función que inserta los registros grabados en MIG_ASEGURADOS, en la tabla
      ASEGURADOS de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_asegurados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_asegurado  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_asegurados   asegurados%ROWTYPE;
      v_sperson      per_personas.sperson%TYPE;
--   v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, p.idperson p_sperson
                    FROM mig_asegurados a, mig_seguros s, mig_personas p
                   WHERE p.mig_pk = a.mig_fk
                     AND s.mig_pk = a.mig_fk2
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_asegurado THEN
               v_1_asegurado := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'ASEGURADOS');
            END IF;

            v_error := FALSE;
            v_asegurados := NULL;
            v_asegurados.sseguro := x.s_sseguro;
            v_asegurados.sperson := x.p_sperson;
            v_asegurados.norden := x.norden;
            v_asegurados.cdomici := x.cdomici;
            v_asegurados.ffecini := x.ffecini;
            v_asegurados.ffecfin := x.ffecfin;
            v_asegurados.ffecmue := x.ffecmue;
            v_asegurados.nriesgo := 1;
            v_asegurados.fecretroact := x.fecretroact;   --bfp bug 22481
            v_asegurados.cparen := x.cparen;

            -- 23289/120321 - GAG - 23/08/2012
            IF ptablas = 'EST' THEN
               INSERT INTO estassegurats
                    VALUES v_asegurados;
            ELSE
               INSERT INTO asegurados
                    VALUES v_asegurados;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         x.s_sseguro || '|' || x.p_sperson || '|' || x.norden);

            UPDATE mig_asegurados
               SET sseguro = v_asegurados.sseguro,
                   sperson = v_asegurados.sperson,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
         --   ROLLBACK;
         --  EXIT;
         END;
      --  COMMIT;
      END LOOP;

      --      SELECT COUNT(*)
      --        INTO v_cont
      --       FROM mig_logs_axis
      --     WHERE ncarga = pncarga
      --       AND tipo = 'E';
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_asegurados;

/***************************************************************************
      FUNCTION f_migra_autconductores
      Función que inserta los registros grabados en MIG_AUTCONDUCTORES, en la tabla
      AUTCONDUCTORES de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_autconductores(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_autconductor BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_autconductores autconductores%ROWTYPE;
--    v_sperson      per_personas.sperson%TYPE;
--   v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.sseguro s_sseguro, per.idperson idperson
                    FROM mig_autconductores a, mig_autriesgos r, mig_personas per
                   WHERE r.mig_pk = a.mig_fk
                     AND per.mig_pk = a.mig_fk2
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_autconductor THEN
               v_1_autconductor := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'AUTCONDUCTORES');
            END IF;

            v_error := FALSE;
            v_autconductores := NULL;
            v_autconductores.sseguro := x.s_sseguro;
            v_autconductores.sperson := x.idperson;
            v_autconductores.nmovimi := x.nmovimi;
            v_autconductores.norden := x.norden;
            v_autconductores.cdomici := x.cdomici;
            v_autconductores.fnacimi := x.fnacimi;
            v_autconductores.fcarnet := x.fcarnet;
            v_autconductores.csexo := x.csexo;
            v_autconductores.nriesgo := 1;
            v_autconductores.npuntos := x.npuntos;
            v_autconductores.cprincipal := x.cprincipal;
            v_autconductores.exper_manual := x.exper_manual;
            v_autconductores.exper_cexper := x.exper_cexper;
            v_autconductores.exper_sinie := x.exper_sinie;
            v_autconductores.exper_sinie_manual := x.exper_sinie_manual;

            IF ptablas = 'EST' THEN
               INSERT INTO estautconductores
                    VALUES v_autconductores;
            ELSE
               INSERT INTO autconductores
                    VALUES v_autconductores;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         x.sseguro || '|' || x.sperson || '|' || x.norden);

            UPDATE mig_autconductores
               SET sseguro = v_autconductores.sseguro,
                   sperson = v_autconductores.sperson,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
               EXIT;
         END;
      --         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_autconductores;

/***************************************************************************
      FUNCTION f_migra_autdisriesgos
      Función que inserta los registros grabados en MIG_AUTDISRIESGOS, en la tabla
      AUTDISRIESGOS de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_autdisriesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_autdisriesgo BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_autdisriesgos autdisriesgos%ROWTYPE;
--     v_sperson      per_personas.sperson%TYPE;
--   v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.sseguro s_sseguro
                    FROM mig_autdisriesgos a, mig_autriesgos r
                   WHERE r.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_autdisriesgo THEN
               v_1_autdisriesgo := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'AUTDISRIESGOS');
            END IF;

            v_error := FALSE;
            v_autdisriesgos := NULL;
            v_autdisriesgos.sseguro := x.s_sseguro;
            v_autdisriesgos.nriesgo := 1;
            v_autdisriesgos.nmovimi := x.nmovimi;
            v_autdisriesgos.cversion := x.cversion;
            v_autdisriesgos.cdispositivo := x.cdispositivo;
            v_autdisriesgos.cpropdisp := x.cpropdisp;
            v_autdisriesgos.ivaldisp := x.ivaldisp;
            v_autdisriesgos.finicontrato := x.finicontrato;
            v_autdisriesgos.ffincontrato := x.ffincontrato;
            v_autdisriesgos.ncontrato := x.ncontrato;
            v_autdisriesgos.tdescdisp := x.tdescdisp;

            IF ptablas = 'EST' THEN
               INSERT INTO estautdisriesgos
                    VALUES v_autdisriesgos;
            ELSE
               INSERT INTO autdisriesgos
                    VALUES v_autdisriesgos;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, x.sseguro);

            UPDATE mig_autdisriesgos
               SET sseguro = v_autdisriesgos.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
               EXIT;
         END;
      --         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_autdisriesgos;

/***************************************************************************
      FUNCTION f_migra_bonfranseg
      Función que inserta los registros grabados en MIG_bonfranseg, en la tabla
      *bf_bonfranseg de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_bonfranseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_mig_bonfranseg BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_bf_bonfranseg bf_bonfranseg%ROWTYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.sseguro s_sseguro
                    FROM mig_bf_bonfranseg a, mig_autriesgos r
                   WHERE r.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_mig_bonfranseg THEN
               v_1_mig_bonfranseg := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'BF_BONFRANSEG');
            END IF;

            v_error := FALSE;
            v_bf_bonfranseg := NULL;
            --
            v_bf_bonfranseg.sseguro := x.s_sseguro;
            v_bf_bonfranseg.nriesgo := x.nriesgo;
            v_bf_bonfranseg.nmovimi := x.nmovimi;
            --   v_bf_bonfranseg.CGRUP    := x.cgrup;
            --   v_bf_bonfranseg.CSUBGRUP := x.csubgrup;
            --    v_bf_bonfranseg.CNIVEL   := x.cnivel;
            --    v_bf_bonfranseg.CVERSION := x.cversion;

            --    select * from bf_detnivel
            --   where cgrup = 603101 and
            v_bf_bonfranseg.finiefe := x.finiefe;
            v_bf_bonfranseg.ctipgrup := x.ctipgrup;
            v_bf_bonfranseg.cvalor1 := x.cvalor1;
            v_bf_bonfranseg.impvalor1 := x.impvalor1;
            --            v_bf_bonfranseg.CVALOR2  := x.cvalor2;
            --            v_bf_bonfranseg.IMPVALOR2:= x.impvalor2;
            v_bf_bonfranseg.cimpmin := x.cimpmin;
            v_bf_bonfranseg.impmin := x.impmin;
            v_bf_bonfranseg.cimpmax := x.cimpmax;
            v_bf_bonfranseg.impmax := x.impmax;
            v_bf_bonfranseg.ffinefe := x.ffinefe;
            --v_bf_bonfranseg.cusualt := NVL(x.cusualt, f_user);
            v_bf_bonfranseg.falta := NVL(x.falta, f_sysdate);
            v_bf_bonfranseg.cusumod := NULL;   -- x.cusumod;
            v_bf_bonfranseg.fmodifi := NULL;
            v_bf_bonfranseg.cniveldefecto := NULL;   --:= x.cniveldefecto;

            IF ptablas = 'EST' THEN
               INSERT INTO estbf_bonfranseg
                    VALUES v_bf_bonfranseg;
            ELSE
               INSERT INTO bf_bonfranseg
                    VALUES v_bf_bonfranseg;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, x.sseguro);

            UPDATE mig_bf_bonfranseg
               SET sseguro = v_bf_bonfranseg.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
               EXIT;
         END;
      --         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_bonfranseg;

/***************************************************************************
      FUNCTION f_migra_riesgos
      Función que inserta los registros grabados en MIG_RIESGOS, en la tabla
      RIESGOS de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_riesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_riesgos    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_riesgos      riesgos%ROWTYPE;
      v_sperson      per_personas.sperson%TYPE;
      v_cobjase      seguros.cobjase%TYPE;
      --jlb esto tendra que se sustituido por una mig_sitriesgo
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, p.idperson p_sperson, s.sproduc,
                         p.ctipvia ctipvia, p.tnomvia tnomvia, p.nnumvia nnumvia,
                         p.tcomple tcomple, p.cpostal cpostal, p.cpoblac cpoblac,
                         p.cprovin cprovin
                    FROM mig_riesgos a, mig_seguros s, mig_personas p
                   WHERE p.mig_pk(+) = a.mig_fk
                     AND s.mig_pk = a.mig_fk2
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_riesgos THEN
               v_1_riesgos := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'RIESGOS');
            END IF;

            v_error := FALSE;
            v_riesgos := NULL;
            v_riesgos.sseguro := x.s_sseguro;
            v_riesgos.sperson := x.p_sperson;
            v_riesgos.nriesgo := x.nriesgo;
            v_riesgos.nmovima := x.nmovima;
            v_riesgos.fefecto := x.fefecto;
            v_riesgos.nmovimb := x.nmovimb;
            v_riesgos.fanulac := x.fanulac;
            v_riesgos.tnatrie := x.tnatrie;

            -- 23289/120321 - ECP- 03/09/2012 Inicio
            IF ptablas = 'EST' THEN
               SELECT cobjase
                 INTO v_cobjase
                 FROM estseguros
                WHERE sseguro = x.s_sseguro;
            ELSE
               SELECT cobjase
                 INTO v_cobjase
                 FROM seguros
                WHERE sseguro = x.s_sseguro;
            END IF;

            IF v_cobjase <> 1 THEN
               v_riesgos.sperson := NULL;
            ELSE
               BEGIN
                  SELECT cdomici
                    INTO v_riesgos.cdomici
                    FROM mig_asegurados
                   WHERE mig_pk = x.mig_pk;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_riesgos.cdomici := NULL;
               END;
            END IF;

            -- 23289/120321 -  ECP - 05/09/2012
            IF ptablas = 'EST' THEN
               INSERT INTO estriesgos
                           (nriesgo, sseguro, nmovima,
                            fefecto, sperson, cclarie,
                            nmovimb, fanulac, tnatrie,
                            cdomici, nasegur, starjet, nedacol,
                            csexcol, sbonush, czbonus,
                            ctipdiraut, spermin, cactivi,
                            cmodalidad, pdtocom, precarg,
                            pdtotec, preccom)
                    VALUES (v_riesgos.nriesgo, v_riesgos.sseguro, v_riesgos.nmovima,
                            v_riesgos.fefecto, v_riesgos.sperson, v_riesgos.cclarie,
                            v_riesgos.nmovimb, v_riesgos.fanulac, v_riesgos.tnatrie,
                            v_riesgos.cdomici, v_riesgos.nasegur, NULL, v_riesgos.nedacol,
                            v_riesgos.csexcol, v_riesgos.sbonush, v_riesgos.czbonus,
                            v_riesgos.ctipdiraut, v_riesgos.spermin, v_riesgos.cactivi,
                            v_riesgos.cmodalidad, v_riesgos.pdtocom, v_riesgos.precarg,
                            v_riesgos.pdtotec, v_riesgos.preccom);
            ELSE
               INSERT INTO riesgos
                    VALUES v_riesgos;
            END IF;

            BEGIN
               -- 23289/120321 - ECP- 03/09/2012 Fin
               IF v_cobjase = 2 THEN   --domicilio
                  IF v_riesgos.tnatrie IS NOT NULL THEN
                     --jlb esto tendra que ser sustituido por una mig_sitriesgo
                     -- 23289/120321 - GAG - 23/08/2012
                     IF ptablas = 'EST' THEN
                        INSERT INTO estsitriesgo
                                    (sseguro, nriesgo,
                                     tdomici, cprovin, cpostal, cpoblac, csiglas,
                                     tnomvia, nnumvia, tcomple)
                             VALUES (v_riesgos.sseguro, v_riesgos.nriesgo,
                                     SUBSTR(v_riesgos.tnatrie, 1, 60), 0, NULL, 0, NULL,
                                     NULL, NULL, SUBSTR(v_riesgos.tnatrie, 1, 250));
                     ELSE
                        INSERT INTO sitriesgo
                                    (sseguro, nriesgo,
                                     tdomici, cprovin, cpostal, cpoblac, csiglas,
                                     tnomvia, nnumvia, tcomple)
                             VALUES (v_riesgos.sseguro, v_riesgos.nriesgo,
                                     SUBSTR(v_riesgos.tnatrie, 1, 60), 0, NULL, 0, NULL,
                                     NULL, NULL, SUBSTR(v_riesgos.tnatrie, 1, 250));
                     END IF;
                  -- v_riesgos.sperson := NULL;   -- elimino el speson si llega
                  ELSIF v_riesgos.sperson IS NOT NULL THEN
                     -- intento recuperar la direccion del asegurado
                     -- 23289/120321 - GAG - 23/08/2012
                     IF ptablas = 'EST' THEN
                        INSERT INTO estsitriesgo
                                    (sseguro, nriesgo,
                                     tdomici, cprovin, cpostal,
                                     cpoblac, csiglas, tnomvia, nnumvia,
                                     tcomple)
                             VALUES (v_riesgos.sseguro, v_riesgos.nriesgo,
                                     SUBSTR(x.tnomvia, 1, 60), x.cprovin, x.cpostal,
                                     x.cpoblac, x.ctipvia, SUBSTR(x.tnomvia, 1, 200), NULL,
                                     SUBSTR(x.tnomvia, 1, 250));
                     ELSE
                        INSERT INTO sitriesgo
                                    (sseguro, nriesgo,
                                     tdomici, cprovin, cpostal,
                                     cpoblac, csiglas, tnomvia, nnumvia,
                                     tcomple)
                             VALUES (v_riesgos.sseguro, v_riesgos.nriesgo,
                                     SUBSTR(x.tnomvia, 1, 60), x.cprovin, x.cpostal,
                                     x.cpoblac, x.ctipvia, SUBSTR(x.tnomvia, 1, 200), NULL,
                                     SUBSTR(x.tnomvia, 1, 250));
                     END IF;
                  --v_riesgos.sperson := NULL;   -- elimino el speson si llega
                  END IF;
               --jlb esto tendra que se sustituido por una mig_sitriesgo
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, x.s_sseguro || '|' || x.nriesgo);

            UPDATE mig_riesgos
               SET sseguro = v_riesgos.sseguro,
                   sperson = v_riesgos.sperson,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_riesgos;

-- BUG : 18334 - 26-04-2011 - JMC - Carga pólizas
/***************************************************************************
      FUNCTION f_migra_autriesgos
      Función que inserta los registros grabados en MIG_AUTRIESGOS, en la tabla
      AUTRIESGOS de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_autriesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_riesgos    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_riesgos      autriesgos%ROWTYPE;
      v_cont         NUMBER;
      vcclaveh       aut_versiones.cclaveh%TYPE;
      vctipveh       aut_versiones.ctipveh%TYPE;
      vcuso          aut_usosubuso.cuso%TYPE;
      vcsubuso       aut_usosubuso.csubuso%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.sseguro s_sseguro
                    FROM mig_autriesgos a, mig_riesgos r
                   WHERE r.mig_pk = a.mig_fk
                     AND r.sseguro <> 0
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_riesgos THEN
               v_1_riesgos := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'AUTRIESGOS');
            END IF;

            v_error := FALSE;
            v_riesgos := NULL;
            v_riesgos.sseguro := x.s_sseguro;
            v_riesgos.nriesgo := x.nriesgo;
            v_riesgos.nmovimi := x.nmovimi;
            v_riesgos.cversion := x.cversion;
            v_riesgos.ctipmat := x.ctipmat;
            v_riesgos.cmatric := x.cmatric;
            v_riesgos.cuso := x.cuso;
            v_riesgos.csubuso := x.csubuso;
            v_riesgos.fmatric := x.fmatric;
            v_riesgos.nkilometros := x.nkilometros;
            v_riesgos.cvehnue := x.cvehnue;
            v_riesgos.ivehicu := x.ivehicu;
            v_riesgos.npma := x.npma;
            v_riesgos.ntara := x.ntara;
            v_riesgos.ccolor := x.ccolor;
            v_riesgos.nbastid := x.nbastid;
            v_riesgos.nplazas := x.nplazas;
            v_riesgos.cgaraje := x.cgaraje;
            v_riesgos.cusorem := x.cusorem;
            v_riesgos.cremolque := x.cremolque;
            v_riesgos.anyo := x.anyo;
            v_riesgos.ccaja := x.ccaja;
            v_riesgos.ccampero := x.ccampero;
            v_riesgos.cchasis := x.cchasis;
            v_riesgos.ccilindraje := x.ccilindraje;
            v_riesgos.ciaant := x.ciaant;
            v_riesgos.cmotor := x.cmotor;
            v_riesgos.codmotor := x.codmotor;
            v_riesgos.corigen := x.corigen;
            v_riesgos.cpaisorigen := x.cpaisorigen;
            v_riesgos.cpintura := x.cpintura;
            v_riesgos.cservicio := x.cservicio;
            v_riesgos.ctipcarroceria := x.ctipcarroceria;
            v_riesgos.ctransporte := x.ctransporte;
            v_riesgos.ffinciant := x.ffinciant;
            v_riesgos.ivehinue := x.ivehinue;
            v_riesgos.nkilometraje := x.nkilometraje;
            v_riesgos.triesgo := x.triesgo;
            v_riesgos.cmodalidad := x.cmodalidad;

            IF v_riesgos.cversion IS NOT NULL THEN
               BEGIN   --Comprobar versión
                  SELECT cclaveh, ctipveh
                    INTO vcclaveh, vctipveh
                    FROM aut_versiones
                   WHERE cversion = v_riesgos.cversion;

                  IF x.cuso IS NOT NULL
                     AND x.csubuso IS NOT NULL THEN
                     BEGIN   --Comprobar uso
                        SELECT cuso, csubuso
                          INTO vcuso, vcsubuso
                          FROM aut_usosubuso
                         WHERE cclaveh = vcclaveh
                           AND ctipveh = vctipveh
                           AND cuso = x.cuso
                           AND csubuso = x.csubuso;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                          'Error usosubuso:' || vcclaveh
                                                          || '|' || vctipveh || '|' || x.cuso
                                                          || '|' || x.csubuso || ' - '
                                                          || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                     END;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error cversion:' || x.cversion || ' - '
                                                    || SQLCODE || '-' || SQLERRM);
                     v_error := TRUE;
               END;
            END IF;

            IF NOT v_error THEN
               -- 23289/120321 - ECP- 03/09/2012 Inicio
               IF ptablas = 'EST' THEN
                  INSERT INTO estautriesgos
                       VALUES v_riesgos;
               ELSE
                  INSERT INTO autriesgos
                       VALUES v_riesgos;
               END IF;

               -- 23289/120321 - ECP- 03/09/2012 Fin
               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 1,
                            x.s_sseguro || '|' || x.nriesgo || '|' || x.nmovimi);

               UPDATE mig_autriesgos
                  SET sseguro = v_riesgos.sseguro,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_autriesgos;

/***************************************************************************
      FUNCTION f_migra_autdetriesgos
      Función que inserta los registros grabados en MIG_AUTRIESGOS, en la tabla
      AUTRIESGOS de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_autdetriesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_riesgos    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_riesgos      autdetriesgos%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.sseguro s_sseguro, r.nriesgo n_nriesgo, r.nmovimi n_nmovimi,
                         r.cversion c_cversion
                    FROM mig_autdetriesgos a, mig_autriesgos r
                   WHERE r.mig_pk = a.mig_fk
                     AND r.sseguro <> 0
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_riesgos THEN
               v_1_riesgos := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'AUTDETRIESGOS');
            END IF;

            v_error := FALSE;
            v_riesgos := NULL;
            v_riesgos.sseguro := x.s_sseguro;
            v_riesgos.nriesgo := x.n_nriesgo;
            v_riesgos.nmovimi := x.n_nmovimi;
            v_riesgos.cversion := x.c_cversion;
            v_riesgos.caccesorio := x.caccesorio;
            v_riesgos.ctipacc := x.ctipacc;
            v_riesgos.fini := x.fini;
            v_riesgos.ivalacc := x.ivalacc;
            v_riesgos.tdesacc := x.tdesacc;
            v_riesgos.casegurable := x.casegurable;
            v_riesgos.cversion := x.cversion;
            v_riesgos.nmovimi := x.nmovimi;
            v_riesgos.nriesgo := x.nriesgo;

            IF ptablas = 'EST' THEN
               INSERT INTO estautdetriesgos
                    VALUES v_riesgos;
            ELSE
               INSERT INTO autdetriesgos
                    VALUES v_riesgos;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         x.s_sseguro || '|' || x.n_nriesgo || '|' || x.n_nmovimi || '|'
                         || x.caccesorio);

            UPDATE mig_autdetriesgos
               SET sseguro = v_riesgos.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_autdetriesgos;

/***************************************************************************
      FUNCTION f_migra_sitriesgo
      Función que inserta los registros grabados en MIG_SITRIESGO, en la tabla
      SITRIESGO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sitriesgo(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_riesgos    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_riesgos      sitriesgo%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.sseguro s_sseguro
                    FROM mig_sitriesgo a, mig_riesgos r
                   WHERE r.mig_pk = a.mig_fk
                     AND r.sseguro <> 0
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_riesgos THEN
               v_1_riesgos := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SITRIESGO');
            END IF;

            v_error := FALSE;
            v_riesgos := NULL;
            v_riesgos.sseguro := x.s_sseguro;
            v_riesgos.nriesgo := x.nriesgo;
            v_riesgos.tdomici := x.tdomici;
            v_riesgos.cprovin := x.cprovin;
            v_riesgos.cpostal := x.cpostal;
            v_riesgos.cpoblac := x.cpoblac;
            v_riesgos.csiglas := x.csiglas;
            v_riesgos.tnomvia := x.tnomvia;
            v_riesgos.nnumvia := x.nnumvia;
            v_riesgos.tcomple := x.tcomple;
            v_riesgos.cciudad := x.cciudad;
            v_riesgos.fgisx := x.fgisx;
            v_riesgos.fgisy := x.fgisy;
            v_riesgos.fgisz := x.fgisz;
            v_riesgos.cvalida := x.cvalida;

            -- 23289/120321 - ECP- 03/09/2012  Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estsitriesgo
                           (sseguro, nriesgo, tdomici, cprovin, cpostal, cpoblac, csiglas,
                            tnomvia, nnumvia, tcomple)
                    VALUES (v_riesgos.sseguro, v_riesgos.nriesgo, NULL, 0, NULL, 0, NULL,
                            NULL, NULL, NULL);
            ELSE
               INSERT INTO sitriesgo
                    VALUES v_riesgos;
            END IF;

            -- 23289/120321 - ECP- 03/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, x.s_sseguro || '|' || x.nriesgo);

            UPDATE mig_sitriesgo
               SET sseguro = v_riesgos.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sitriesgo;

-- FIN BUG : 18334 - 26-04-2011 - JMC
-- BUG : 10395 - 17-06-2009 - JMC - Proceso para insertar PRESTCUADROSEG
/***************************************************************************
        PROCEDURE p_insertar_cuadro
        Procedimiento para crear los cuadros de amortización de las pólizas
        migradas. Es una copia de PAC_FORM_APR.f_insertar_cuadro
           param in  pncarga:     Número de carga.
           param in  pntab:       Número de tabla.
           param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 03/09/2012
           param in  psseguro:    Número de seguro.
     ***************************************************************************/
   PROCEDURE p_insertar_cuadro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL') IS
      num_err        NUMBER;
      v_cgarant      NUMBER;
      v_capital_ini  NUMBER;
      v_nmovimi      NUMBER;
      v_fefepol      DATE;
      v_fvencimpol   DATE;
      v_cforpag      NUMBER;
      v_ctipamort    NUMBER;
      v_cforpagpre   NUMBER;
      v_duracprest   NUMBER;
      v_fvencimgar   NUMBER;
      v_forpagp      NUMBER;
      v_interes      NUMBER;
      v_ctapres      prestamos.ctapres%TYPE := psseguro;
      meses          NUMBER := 0;
      v_falta        DATE;   -- Bug 11301 - APD - 21/10/2009
   BEGIN
      -- 23289/120321 - ECP- 03/09/2012 Inicio
      IF ptablas = 'EST' THEN
         SELECT MAX(cgarant), MAX(nmovimi), MAX(icapital), MAX(s.cforpag), MAX(s.fefecto),
                MAX(s.fvencim),
                MAX(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                    tmp.cgarant, 'PREST_VINC')) tipamort
           INTO v_cgarant, v_nmovimi, v_capital_ini, v_cforpag, v_fefepol,
                v_fvencimpol,
                v_ctipamort
           FROM estgaranseg tmp, estseguros s
          WHERE tmp.sseguro = psseguro
            AND s.sseguro = tmp.sseguro
            AND nmovimi = 1
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                tmp.cgarant, 'PREST_VINC') <> 0;

         DELETE FROM estprestcuadroseg
               WHERE sseguro = psseguro;

         DELETE FROM prestamos
               WHERE ctapres = psseguro;

         SELECT crespue
           INTO v_cforpagpre
           FROM estpregungaranseg
          WHERE sseguro = psseguro
            AND cpregun = 1046
            AND nmovimi = v_nmovimi
            AND cgarant = v_cgarant;

         SELECT crespue
           INTO v_duracprest
           FROM estpregungaranseg
          WHERE sseguro = psseguro
            AND cpregun = 1044
            AND nmovimi = v_nmovimi
            AND cgarant = v_cgarant;
      ELSE
         SELECT MAX(cgarant), MAX(nmovimi), MAX(icapital), MAX(s.cforpag), MAX(s.fefecto),
                MAX(s.fvencim),
                MAX(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                    tmp.cgarant, 'PREST_VINC')) tipamort
           INTO v_cgarant, v_nmovimi, v_capital_ini, v_cforpag, v_fefepol,
                v_fvencimpol,
                v_ctipamort
           FROM garanseg tmp, seguros s
          WHERE tmp.sseguro = psseguro
            AND s.sseguro = tmp.sseguro
            AND nmovimi = 1
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                tmp.cgarant, 'PREST_VINC') <> 0;

         DELETE FROM prestcuadroseg
               WHERE sseguro = psseguro;

         DELETE FROM prestamos
               WHERE ctapres = psseguro;

         SELECT crespue
           INTO v_cforpagpre
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND cpregun = 1046
            AND nmovimi = v_nmovimi
            AND cgarant = v_cgarant;

         SELECT crespue
           INTO v_duracprest
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND cpregun = 1044
            AND nmovimi = v_nmovimi
            AND cgarant = v_cgarant;
      END IF;

      -- 23289/120321 - ECP- 03/09/2012 Fin
      SELECT DECODE(v_cforpagpre, 1, 12, 12, 1, 4, 3, 2, 6, v_cforpagpre)
        INTO v_forpagp
        FROM DUAL;

      -- Calculamos la fecha de vencimiento de la garantía
      v_fvencimgar := TO_NUMBER(TO_CHAR(ADD_MONTHS(v_fefepol, v_duracprest), 'YYYYMMDD'));
      v_duracprest := TRUNC(v_duracprest / v_forpagp);

      -- 23289/120321 - ECP- 03/09/2012 Inicio
      IF ptablas = 'EST' THEN
         FOR reg IN (SELECT *
                       FROM estpregungaranseg
                      WHERE sseguro = psseguro
                        AND cpregun IN(1010,   -- % INTERÉS
                                            1019))   --Nº de préstamo
                                                  LOOP
            IF reg.cpregun = 1010 THEN
               v_interes := reg.crespue;
            ELSIF reg.cpregun = 1019 THEN
               v_ctapres := reg.trespue;
            END IF;
         END LOOP;
      ELSE
         FOR reg IN (SELECT *
                       FROM pregungaranseg
                      WHERE sseguro = psseguro
                        AND cpregun IN(1010,   -- % INTERÉS
                                            1019))   --Nº de préstamo
                                                  LOOP
            IF reg.cpregun = 1010 THEN
               v_interes := reg.crespue;
            ELSIF reg.cpregun = 1019 THEN
               v_ctapres := reg.trespue;
            END IF;
         END LOOP;
      END IF;

      -- 23289/120321 - ECP- 03/09/2012 Fin
      v_ctapres := psseguro;

      -- insertamos en préstamos
      BEGIN
         -- Bug 11301 - APD - 11301 - se guarda en la variable v_falta la fecha de alta
         -- del prestamo para insertarla tambien en prestcuadroseg
         -- Se sustituye f_sysdate por v_falta
         v_falta := f_sysdate;

         -- Bug 11301 - APD - 23/10/2009 - se elimina la FBAJA del insert
         INSERT INTO prestamos
                     (ctapres, icapini, ctipamort, ctipint, ctippres, falta)
              VALUES (v_ctapres, v_capital_ini, v_ctipamort, v_interes, 2, v_falta);

         INSERT INTO mig_pk_mig_axis
              VALUES (v_ctapres || '|' || TO_CHAR(v_falta, 'yyyymmdd'), pncarga, pntab, 2,
                      v_ctapres || '|' || TO_CHAR(v_falta, 'yyyymmdd'));
      EXCEPTION
         WHEN OTHERS THEN
            num_err := f_ins_mig_logs_axis(pncarga, psseguro, 'E',
                                           'Error al insertar prestamos:' || SQLCODE || '-'
                                           || SQLERRM);
      END;

      meses := MONTHS_BETWEEN(TO_DATE(v_fvencimgar, 'YYYYMMDD'), v_fefepol);

      BEGIN
         -- Bug 11301 - APD - 21/10/2009 - se añade la columna FALTA en el insert
         -- 23289/120321 - ECP- 03/09/2012 Inicio
         IF ptablas = 'EST' THEN
            INSERT INTO estprestcuadroseg
                        (ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg, fefecto,
                         fvencim, icapital, iinteres, icappend, falta)
                 VALUES (v_ctapres, psseguro, v_nmovimi, v_fefepol, NULL, v_fefepol,
                         ADD_MONTHS(v_fefepol, 1), v_capital_ini, 0, v_capital_ini, v_falta);
         ELSE
            INSERT INTO prestcuadroseg
                        (ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg, fefecto,
                         fvencim, icapital, iinteres, icappend, falta)
                 VALUES (v_ctapres, psseguro, v_nmovimi, v_fefepol, NULL, v_fefepol,
                         ADD_MONTHS(v_fefepol, 1), v_capital_ini, 0, v_capital_ini, v_falta);
         END IF;

         -- 23289/120321 - ECP- 03/09/2012  Fin
         INSERT INTO mig_pk_mig_axis
              VALUES (psseguro || '|' || v_nmovimi || '|' || TO_CHAR(v_fefepol, 'yyyymmdd'),
                      pncarga, pntab, 3,
                      psseguro || '|' || v_nmovimi || '|' || TO_CHAR(v_fefepol, 'yyyymmdd'));
      EXCEPTION
         WHEN OTHERS THEN
            num_err := f_ins_mig_logs_axis(pncarga, psseguro, 'E',
                                           'Error al insertar prestcuadroseg:' || SQLCODE
                                           || '-' || SQLERRM);
            ROLLBACK;
      END;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := f_ins_mig_logs_axis(pncarga, psseguro, 'E',
                                        'Error p_insertar_cuadro:' || SQLCODE || '-'
                                        || SQLERRM);
         ROLLBACK;
   END p_insertar_cuadro;

-- FIN BUG : 10395 - 17-06-2009 - JMC
-- BUG : 10395 - 18-06-2009 - JMC - Proceso que determina que polizas tienen cuadro
/***************************************************************************
        PROCEDURE p_cuadro
        Procedimiento que despues de la carga de pregungaranseg, determina que
        pólizas tienen que tener cuadros de amortización
           param in  pncarga:     Número de carga.
           param in  pntab:       Número de tabla.
     ***************************************************************************/
   PROCEDURE p_cuadro(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL') IS
      num_err        NUMBER;
      v_1_cuadro     BOOLEAN := TRUE;
   BEGIN
      FOR x IN (SELECT DISTINCT s.sseguro
                           FROM mig_pregungaranseg p, mig_movseguro m, seguros s
                          WHERE m.mig_pk = p.mig_fk
                            AND s.sseguro = m.sseguro
                            AND p.ncarga = pncarga
                            AND p.cestmig = 2
                            AND p.sseguro > 0
                            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                                s.cactivi, p.cgarant, 'PREST_VINC') <> 0
                       ORDER BY sseguro) LOOP
         IF v_1_cuadro THEN
            v_1_cuadro := FALSE;
            num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 2, 'PRESTAMOS');
            num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 3, 'PRESTCUADROSEG');
         END IF;

         p_insertar_cuadro(pncarga, pntab, x.sseguro);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := f_ins_mig_logs_axis(pncarga, '0', 'E',
                                        'Error p_cuadro:' || SQLCODE || '-' || SQLERRM);
         ROLLBACK;
   END p_cuadro;

-- FIN BUG : 10395 - 18-06-2009 - JMC

   /***************************************************************************
      FUNCTION f_migra_garanseg
      Función que inserta los registros grabados en MIG_GARANSEG, en la tabla
      GARANSEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_garanseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_garanseg   BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_garanseg     garanseg%ROWTYPE;
      --   v_seguros      seguros%ROWTYPE;
      v_garanpro     garanpro%ROWTYPE;
      v_estgaranseg  estgaranseg%ROWTYPE;
      -- v_estseguros   estseguros%ROWTYPE;
      v_sproduc      productos.sproduc%TYPE;
      v_cactivi      codiactseg.cactivi%TYPE;
      v_cont         NUMBER;
      literal        VARCHAR2(2000);
      v_detmovseguro detmovseguro%ROWTYPE;
      -- Bug 21121 - APD - 24/02/2012
      v_pargaranpro  NUMBER;
      v_cramo        productos.cramo%TYPE;
      v_cmodali      productos.cmodali%TYPE;
      v_ctipseg      productos.ctipseg%TYPE;
      v_ccolect      productos.ccolect%TYPE;
      -- fin Bug 21121 - APD - 24/02/2012
      v_ntraza       NUMBER(4) := 0;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, s.sproduc, s.fefecto s_fefecto,
                         s.cactivi s_cactivi, m.nmovimi m_nmovimi
                    FROM mig_garanseg a, mig_seguros s, mig_movseguro m
                   WHERE m.mig_pk = a.mig_fk
                     AND s.mig_pk = m.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_garanseg THEN
               v_1_garanseg := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 3, 'GARANSEG');
            END IF;

            v_error := FALSE;

            -- jlb -- nueva validacion
            IF x.ffinefe IS NOT NULL THEN
               IF x.finiefe > x.ffinefe THEN   --error en fechas
                  num_err :=
                     f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                         'Error f_migra_garanseg. Fecha de inicio '
                                         || x.finiefe || ' mayor que fecha fin ' || x.ffinefe);
                  v_error := TRUE;
               --                  ROLLBACK;
               --                EXIT;
               END IF;
            END IF;

            -- JLB 3289/120321
            IF ptablas = 'EST' THEN
               v_estgaranseg := NULL;
               v_estgaranseg.cobliga := 1;
               v_estgaranseg.cgarant := x.cgarant;
               v_estgaranseg.nriesgo := x.nriesgo;

               IF NVL(x.nmovimi, 0) = 0 THEN
                  v_estgaranseg.nmovimi := x.m_nmovimi;
               ELSE
                  v_estgaranseg.nmovimi := x.nmovimi;
               END IF;

               v_estgaranseg.nmovima := x.nmovima;
               v_estgaranseg.sseguro := x.s_sseguro;
               v_estgaranseg.finiefe := x.finiefe;
               v_estgaranseg.icapital := NVL(x.icapital, 0);
               v_estgaranseg.precarg := x.precarg;
               v_estgaranseg.iextrap := x.iextrap;

               -- JLB - graba la prima anualizada

               --BUG 12855 - 15-02-2010 - JMC - Redondeo segun parámetro
               IF NVL(f_parproductos_v(x.sproduc, 'REDONDEOFP_12'), 0) = 0 THEN
                  v_estgaranseg.iprianu := NVL(x.iprianu, 0);
               ELSE
                  v_estgaranseg.iprianu := ROUND((NVL(x.iprianu, 0) / 12), 2) * 12;   -- OJO
               END IF;

               v_estgaranseg.itotanu := NVL(x.itotanu, x.iprianu);
               --FIN BUG 12855 - 15-02-2010 - JMC
               v_estgaranseg.ffinefe := x.ffinefe;
               v_estgaranseg.irecarg := x.irecarg;
               v_estgaranseg.ipritar := NVL(x.ipritar, 0);
               v_estgaranseg.falta := x.falta;
               v_estgaranseg.ipritot := NVL(x.itotanu, x.iprianu);
               v_estgaranseg.icaptot := v_estgaranseg.icapital;
            ELSE
               v_garanseg := NULL;
               v_garanseg.cgarant := x.cgarant;
               v_garanseg.nriesgo := x.nriesgo;

               IF NVL(x.nmovimi, 0) = 0 THEN
                  v_garanseg.nmovimi := x.m_nmovimi;
               ELSE
                  v_garanseg.nmovimi := x.nmovimi;
               END IF;

               v_garanseg.nmovima := x.nmovima;
               v_garanseg.sseguro := x.s_sseguro;
               v_garanseg.finiefe := x.finiefe;
               v_garanseg.icapital := NVL(x.icapital, 0);
               v_garanseg.precarg := x.precarg;
               v_garanseg.iextrap := x.iextrap;

               -- JLB - graba la prima anualizada

               --BUG 12855 - 15-02-2010 - JMC - Redondeo segun parámetro
               IF NVL(f_parproductos_v(x.sproduc, 'REDONDEOFP_12'), 0) = 0 THEN
                  v_garanseg.iprianu := NVL(x.iprianu, 0);
               ELSE
                  v_garanseg.iprianu := ROUND((NVL(x.iprianu, 0) / 12), 2) * 12;   -- OJO
               END IF;

               v_garanseg.itotanu := NVL(x.itotanu, x.iprianu);
               --FIN BUG 12855 - 15-02-2010 - JMC
               v_garanseg.ffinefe := x.ffinefe;
               v_garanseg.irecarg := x.irecarg;
               v_garanseg.ipritar := NVL(x.ipritar, 0);
               v_garanseg.falta := x.falta;
               v_garanseg.ipritot := NVL(x.itotanu, x.iprianu);
               v_garanseg.icaptot := v_garanseg.icapital;
            END IF;   -- JLB -  3289/120321

            --BUG 21121 - 24-02-2012 - APD - ftarifa en segun parametro NOVATARIFA
            SELECT cramo, cmodali, ctipseg, ccolect
              INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
              FROM productos
             WHERE sproduc = x.sproduc;

            v_pargaranpro := NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                 x.s_cactivi, v_garanseg.cgarant,
                                                 'NOVATARIFAGAR'),
                                 -1);

            -- JLB -  3289/120321
            SELECT *
              INTO v_garanpro
              FROM garanpro
             WHERE cmodali = v_cmodali
               AND ccolect = v_ccolect
               AND ctipseg = v_ctipseg
               AND cgarant = x.cgarant
               AND cactivi = x.s_cactivi
               AND cramo = v_cramo;

            IF ptablas = 'EST' THEN
               IF v_pargaranpro = -1 THEN
                  IF NVL(f_parproductos_v(x.sproduc, 'NOVATARIFA'), 0) = 1 THEN
                     v_estgaranseg.ftarifa := v_estgaranseg.finiefe;
                  ELSE
                     v_estgaranseg.ftarifa := x.s_fefecto;
                  END IF;
               ELSE
                  IF v_pargaranpro = 1 THEN
                     v_estgaranseg.ftarifa := v_estgaranseg.finiefe;
                  ELSE
                     v_estgaranseg.ftarifa := x.s_fefecto;
                  END IF;
               END IF;

               --fin BUG 21121 - 24-02-2012 - APD
               v_estgaranseg.ctipgar := v_garanpro.ctipgar;
               v_estgaranseg.itarifa := 0;   -- v_estgaranseg.ipritar + v_estgaranseg.iextrap;
               v_estgaranseg.norden := v_garanpro.norden;

               --crevali,irevali y prevali si no viene informado crevali,
               --valores definidos a nivel de producto
               IF x.crevali IS NULL THEN
                  v_estgaranseg.crevali := v_garanpro.crevali;
                  v_estgaranseg.prevali := v_garanpro.prevali;
                  v_estgaranseg.irevali := v_garanpro.irevali;
               ELSE
                  v_estgaranseg.crevali := x.crevali;
                  v_estgaranseg.prevali := x.prevali;
                  v_estgaranseg.irevali := x.irevali;
               END IF;

               v_estgaranseg.pdtocom := x.pdtocom;
               v_estgaranseg.idtocom := x.idtocom;

               INSERT INTO estgaranseg
                    VALUES v_estgaranseg;
            ELSE   -- 'POL'
               IF v_pargaranpro = -1 THEN
                  IF NVL(f_parproductos_v(x.sproduc, 'NOVATARIFA'), 0) = 1 THEN
                     v_garanseg.ftarifa := v_garanseg.finiefe;
                  ELSE
                     v_garanseg.ftarifa := x.s_fefecto;
                  END IF;
               ELSE
                  IF v_pargaranpro = 1 THEN
                     v_garanseg.ftarifa := v_garanseg.finiefe;
                  ELSE
                     v_garanseg.ftarifa := x.s_fefecto;
                  END IF;
               END IF;

               --fin BUG 21121 - 24-02-2012 - APD
               --   v_garanseg.ctipgar  :=v_garanpro.ctipgar;
               v_garanseg.itarifa := 0;   --v_garanseg.ipritar + v_garanseg.iextrap;
               v_garanseg.norden := v_garanpro.norden;

               --crevali,irevali y prevali si no viene informado crevali,
               --valores definidos a nivel de producto
               IF x.crevali IS NULL THEN
                  v_garanseg.crevali := v_garanpro.crevali;
                  v_garanseg.prevali := v_garanpro.prevali;
                  v_garanseg.irevali := v_garanpro.irevali;
               ELSE
                  v_garanseg.crevali := x.crevali;
                  v_garanseg.prevali := x.prevali;
                  v_garanseg.irevali := x.irevali;
               END IF;

               v_garanseg.pdtocom := x.pdtocom;
               v_garanseg.idtocom := x.idtocom;

               INSERT INTO garanseg
                    VALUES v_garanseg;
            END IF;   -- JLB -  3289/120321

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 3,
                         x.s_sseguro || '|' || x.nriesgo || '|' || x.cgarant || '|'
                         || x.nmovimi || '|' || TO_CHAR(x.finiefe, 'yyyymmdd'));

            v_ntraza := 5;

            UPDATE mig_garanseg
               SET sseguro = x.s_sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error f_migra_garanseg traza:' || v_ntraza
                                              || '-' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
         --      ROLLBACK;
         --    EXIT;
         END;

         COMMIT;
      END LOOP;

      IF NOT v_error THEN
         --Inserción del detalle de los movimientos de los cambios de garantias.
         v_1_garanseg := TRUE;

         FOR x IN (SELECT   a.*, s.sseguro s_sseguro, s.femisio, s.sproduc
                       FROM mig_movseguro a, mig_seguros s, codimotmov cmm
                      -- Bug 0012557 - 14-01-2009 - JMC  - Se añade codimotmov
                   WHERE    s.mig_pk = a.mig_fk
                        AND cmm.cmotmov = a.cmotmov
                        --Bug 0012557 - 14-01-2009 - JMC - Se añade relación codimotmov
                        AND cmm.cmovseg = 1
                        --Bug 0012557 - 14-01-2009 - JMC - Solo movimientos de alta
                        AND a.cestmig = 2
                        AND a.ncarga = pncarga
                        AND s.ncarga = a.ncarga
                   ORDER BY a.mig_fk, nmovimi) LOOP
            -- 23289/120321 - ECP- 04/09/2012  Inicio
            IF ptablas = 'EST' THEN
               FOR y IN (SELECT TO_CHAR(NVL(s.icapital, 0), 'FM999G999G999G990D00') antes,
                                s.cgarant, s.nriesgo, s.iprianu
                           FROM estgaranseg s, garanpro e, estseguros x
                          WHERE s.cgarant = e.cgarant
                            --AND s.ffinefe IS NULL
                            AND nmovimi = x.nmovimi - 1   --movimiento anterior
                            AND s.sseguro = x.s_sseguro
                            AND x.sseguro = s.sseguro
                            AND e.ctipgar <> 8
                            AND e.cgarant = s.cgarant
                            AND e.sproduc = x.sproduc
                            AND e.cactivi = pac_seguros.ff_get_actividad(x.s_sseguro,
                                                                         s.nriesgo)) LOOP
                  --BUG 8402 - 13-05-2009 - JMC - Obtención valores e inserción tabla DETMOVSEGURO
                  v_detmovseguro := NULL;
                  num_err := f_desgarantia(y.cgarant, f_idiomauser, literal);
                  v_detmovseguro.sseguro := x.s_sseguro;
                  v_detmovseguro.nmovimi := x.nmovimi;
                  v_detmovseguro.cmotmov := x.cmotmov;
                  v_detmovseguro.cpregun := 0;

                  BEGIN
                     SELECT TO_CHAR(icapital, 'FM999G999G999G990D00')
                       INTO v_detmovseguro.tvalord
                       FROM estgaranseg
                      WHERE sseguro = x.s_sseguro
                        AND nriesgo = y.nriesgo
                        AND cgarant = y.cgarant
                        AND nmovimi = x.nmovimi;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_detmovseguro.tvalord := 0;
                  END;

                  IF NVL(y.antes, '0') <> NVL(v_detmovseguro.tvalord, '0') THEN
                     v_detmovseguro.tvalora := literal || ': ' || y.antes;
                     v_detmovseguro.tvalord := literal || ': ' || v_detmovseguro.tvalord;
                     --||' ¿';
                     v_detmovseguro.cgarant := y.cgarant;
                     v_detmovseguro.nriesgo := y.nriesgo;

                     IF v_1_garanseg THEN
                        v_1_garanseg := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 31,
                                                             'DETMOVSEGURO');
                     END IF;

                     BEGIN
                        INSERT INTO estdetmovseguro
                             VALUES v_detmovseguro;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, 31,
                                     v_detmovseguro.sseguro || '|' || v_detmovseguro.nmovimi
                                     || '|' || v_detmovseguro.cmotmov || '|'
                                     || v_detmovseguro.nriesgo || '|'
                                     || v_detmovseguro.cgarant || '|'
                                     || v_detmovseguro.cpregun);
                     --           COMMIT;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE estdetmovseguro
                              SET tvalora = v_detmovseguro.tvalora,
                                  tvalord = v_detmovseguro.tvalord
                            WHERE sseguro = v_detmovseguro.sseguro
                              AND nriesgo = v_detmovseguro.nriesgo
                              AND cgarant = v_detmovseguro.cgarant
                              AND cpregun = NVL(v_detmovseguro.cpregun, 0)
                              AND cmotmov = v_detmovseguro.cmotmov
                              AND nmovimi = v_detmovseguro.nmovimi;
                        --                        COMMIT;
                        WHEN OTHERS THEN
                           num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                          'Error(detmovseguro):' || SQLCODE
                                                          || '-' || SQLERRM);
                           v_error := TRUE;
                     --          ROLLBACK;
                     --        EXIT;
                     END;
                  END IF;
               --FIN BUG 8402 - 13-05-2009 - JMC
               END LOOP;
            ELSE
               FOR y IN (SELECT TO_CHAR(NVL(s.icapital, 0), 'FM999G999G999G990D00') antes,
                                s.cgarant, s.nriesgo, s.iprianu
                           FROM garanseg s, garanpro e, seguros x
                          WHERE s.cgarant = e.cgarant
                            --AND s.ffinefe IS NULL
                            AND nmovimi = x.nmovimi - 1   --movimiento anterior
                            AND s.sseguro = x.s_sseguro
                            AND x.sseguro = s.sseguro
                            AND e.ctipgar <> 8
                            AND e.cgarant = s.cgarant
                            AND e.sproduc = x.sproduc
                            AND e.cactivi = pac_seguros.ff_get_actividad(x.s_sseguro,
                                                                         s.nriesgo)) LOOP
                  --BUG 8402 - 13-05-2009 - JMC - Obtención valores e inserción tabla DETMOVSEGURO
                  v_detmovseguro := NULL;
                  num_err := f_desgarantia(y.cgarant, f_idiomauser, literal);
                  v_detmovseguro.sseguro := x.s_sseguro;
                  v_detmovseguro.nmovimi := x.nmovimi;
                  v_detmovseguro.cmotmov := x.cmotmov;
                  v_detmovseguro.cpregun := 0;

                  BEGIN
                     SELECT TO_CHAR(icapital, 'FM999G999G999G990D00')
                       INTO v_detmovseguro.tvalord
                       FROM garanseg
                      WHERE sseguro = x.s_sseguro
                        AND nriesgo = y.nriesgo
                        AND cgarant = y.cgarant
                        AND nmovimi = x.nmovimi;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_detmovseguro.tvalord := 0;
                  END;

                  IF NVL(y.antes, '0') <> NVL(v_detmovseguro.tvalord, '0') THEN
                     v_detmovseguro.tvalora := literal || ': ' || y.antes;
                     v_detmovseguro.tvalord := literal || ': ' || v_detmovseguro.tvalord;
                     --||' ¿';
                     v_detmovseguro.cgarant := y.cgarant;
                     v_detmovseguro.nriesgo := y.nriesgo;

                     IF v_1_garanseg THEN
                        v_1_garanseg := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 31,
                                                             'DETMOVSEGURO');
                     END IF;

                     BEGIN
                        INSERT INTO detmovseguro
                             VALUES v_detmovseguro;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, 31,
                                     v_detmovseguro.sseguro || '|' || v_detmovseguro.nmovimi
                                     || '|' || v_detmovseguro.cmotmov || '|'
                                     || v_detmovseguro.nriesgo || '|'
                                     || v_detmovseguro.cgarant || '|'
                                     || v_detmovseguro.cpregun);
                     --        COMMIT;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE detmovseguro
                              SET tvalora = v_detmovseguro.tvalora,
                                  tvalord = v_detmovseguro.tvalord
                            WHERE sseguro = v_detmovseguro.sseguro
                              AND nriesgo = v_detmovseguro.nriesgo
                              AND cgarant = v_detmovseguro.cgarant
                              AND cpregun = NVL(v_detmovseguro.cpregun, 0)
                              AND cmotmov = v_detmovseguro.cmotmov
                              AND nmovimi = v_detmovseguro.nmovimi;

                           COMMIT;
                        WHEN OTHERS THEN
                           num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                          'Error(detmovseguro):' || SQLCODE
                                                          || '-' || SQLERRM);
                           v_error := TRUE;
                     --        ROLLBACK;
                     --      EXIT;
                     END;
                  END IF;
               --FIN BUG 8402 - 13-05-2009 - JMC
               END LOOP;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012  Fin
            -- 23289/120321 - ECP- 04/09/2012  Inicio
            IF ptablas = 'EST' THEN
               FOR y IN (SELECT TO_CHAR(NVL(s.icapital, 0), 'FM999G999G999G990D00') despues,
                                s.cgarant, s.nriesgo, s.iprianu
                           FROM estgaranseg s, garanpro e, estseguros x
                          WHERE s.cgarant = e.cgarant
                            --AND s.ffinefe IS NULL
                            AND nmovimi = x.nmovimi   --movimiento anterior
                            AND s.sseguro = x.s_sseguro
                            AND x.sseguro = s.sseguro
                            AND e.ctipgar <> 8
                            AND e.cgarant = s.cgarant
                            AND e.sproduc = x.sproduc
                            AND e.cactivi = pac_seguros.ff_get_actividad(x.s_sseguro,
                                                                         s.nriesgo)) LOOP
                  v_detmovseguro := NULL;
                  num_err := f_desgarantia(y.cgarant, f_idiomauser, literal);
                  v_detmovseguro.sseguro := x.s_sseguro;
                  v_detmovseguro.nmovimi := x.nmovimi;
                  v_detmovseguro.cmotmov := x.cmotmov;
                  v_detmovseguro.cpregun := 0;

                  BEGIN
                     SELECT TO_CHAR(icapital, 'FM999G999G999G990D00')
                       INTO v_detmovseguro.tvalora
                       FROM estgaranseg
                      WHERE sseguro = x.s_sseguro
                        AND nriesgo = y.nriesgo
                        AND cgarant = y.cgarant
                        AND nmovimi = x.nmovimi - 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_detmovseguro.tvalord := 0;
                  END;

                  IF NVL(y.despues, '0') <> NVL(v_detmovseguro.tvalora, '0') THEN
                     v_detmovseguro.tvalora := literal || ': ' || v_detmovseguro.tvalora;
                     v_detmovseguro.tvalord := literal || ': ' || y.despues;
                     --||' ¿';
                     v_detmovseguro.cgarant := y.cgarant;
                     v_detmovseguro.nriesgo := y.nriesgo;

                     IF v_1_garanseg THEN
                        v_1_garanseg := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 31,
                                                             'DETMOVSEGURO');
                     END IF;

                     BEGIN
                        INSERT INTO estdetmovseguro
                             VALUES v_detmovseguro;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, 31,
                                     v_detmovseguro.sseguro || '|' || v_detmovseguro.nmovimi
                                     || '|' || v_detmovseguro.cmotmov || '|'
                                     || v_detmovseguro.nriesgo || '|'
                                     || v_detmovseguro.cgarant || '|'
                                     || v_detmovseguro.cpregun);
                     --     COMMIT;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE estdetmovseguro
                              SET tvalora = v_detmovseguro.tvalora,
                                  tvalord = v_detmovseguro.tvalord
                            WHERE sseguro = v_detmovseguro.sseguro
                              AND nriesgo = v_detmovseguro.nriesgo
                              AND cgarant = v_detmovseguro.cgarant
                              AND cpregun = NVL(v_detmovseguro.cpregun, 0)
                              AND cmotmov = v_detmovseguro.cmotmov
                              AND nmovimi = v_detmovseguro.nmovimi;
                        --        COMMIT;
                        WHEN OTHERS THEN
                           num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                          'Error(detmovseguro-2):' || SQLCODE
                                                          || '-' || SQLERRM);
                           v_error := TRUE;
                     --         ROLLBACK;
                     --      EXIT;
                     END;
                  END IF;
               END LOOP;
            ELSE
               FOR y IN (SELECT TO_CHAR(NVL(s.icapital, 0), 'FM999G999G999G990D00') despues,
                                s.cgarant, s.nriesgo, s.iprianu
                           FROM garanseg s, garanpro e, seguros x
                          WHERE s.cgarant = e.cgarant
                            --AND s.ffinefe IS NULL
                            AND nmovimi = x.nmovimi   --movimiento anterior
                            AND s.sseguro = x.s_sseguro
                            AND x.sseguro = s.sseguro
                            AND e.ctipgar <> 8
                            AND e.cgarant = s.cgarant
                            AND e.sproduc = x.sproduc
                            AND e.cactivi = pac_seguros.ff_get_actividad(x.s_sseguro,
                                                                         s.nriesgo)) LOOP
                  v_detmovseguro := NULL;
                  num_err := f_desgarantia(y.cgarant, f_idiomauser, literal);
                  v_detmovseguro.sseguro := x.s_sseguro;
                  v_detmovseguro.nmovimi := x.nmovimi;
                  v_detmovseguro.cmotmov := x.cmotmov;
                  v_detmovseguro.cpregun := 0;

                  BEGIN
                     SELECT TO_CHAR(icapital, 'FM999G999G999G990D00')
                       INTO v_detmovseguro.tvalora
                       FROM garanseg
                      WHERE sseguro = x.s_sseguro
                        AND nriesgo = y.nriesgo
                        AND cgarant = y.cgarant
                        AND nmovimi = x.nmovimi - 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_detmovseguro.tvalord := 0;
                  END;

                  IF NVL(y.despues, '0') <> NVL(v_detmovseguro.tvalora, '0') THEN
                     v_detmovseguro.tvalora := literal || ': ' || v_detmovseguro.tvalora;
                     v_detmovseguro.tvalord := literal || ': ' || y.despues;
                     --||' ¿';
                     v_detmovseguro.cgarant := y.cgarant;
                     v_detmovseguro.nriesgo := y.nriesgo;

                     IF v_1_garanseg THEN
                        v_1_garanseg := FALSE;
                        num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 31,
                                                             'DETMOVSEGURO');
                     END IF;

                     BEGIN
                        INSERT INTO detmovseguro
                             VALUES v_detmovseguro;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, 31,
                                     v_detmovseguro.sseguro || '|' || v_detmovseguro.nmovimi
                                     || '|' || v_detmovseguro.cmotmov || '|'
                                     || v_detmovseguro.nriesgo || '|'
                                     || v_detmovseguro.cgarant || '|'
                                     || v_detmovseguro.cpregun);
                     --      COMMIT;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE detmovseguro
                              SET tvalora = v_detmovseguro.tvalora,
                                  tvalord = v_detmovseguro.tvalord
                            WHERE sseguro = v_detmovseguro.sseguro
                              AND nriesgo = v_detmovseguro.nriesgo
                              AND cgarant = v_detmovseguro.cgarant
                              AND cpregun = NVL(v_detmovseguro.cpregun, 0)
                              AND cmotmov = v_detmovseguro.cmotmov
                              AND nmovimi = v_detmovseguro.nmovimi;
                        --        COMMIT;
                        WHEN OTHERS THEN
                           num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                          'Error(detmovseguro-2):' || SQLCODE
                                                          || '-' || SQLERRM);
                           v_error := TRUE;
                     --        ROLLBACK;
                     --      EXIT;
                     END;
                  END IF;
               END LOOP;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012  Fin
            UPDATE mig_movseguro
               SET cestmig = 3
             WHERE mig_pk = x.mig_pk;

            COMMIT;
         END LOOP;
      END IF;   -- not verror;

      --FIN Inserción del detalle de los movimientos de los cambios de garantias.
      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_garanseg;

-- BUG 8402 - 15-05-2009 - JMC - Función para la migración de la tabla DETGARANSEG
/***************************************************************************
      FUNCTION f_migra_detgaranseg
      Función que inserta los registros grabados en MIG_DETGARANSEG, en la tabla
      DETGARANSEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_detgaranseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_garanseg   BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_detgaranseg  detgaranseg%ROWTYPE;
      v_seguros      seguros%ROWTYPE;
      v_estseguros   estseguros%ROWTYPE;
      v_garanpro     garanpro%ROWTYPE;
      v_sproduc      productos.sproduc%TYPE;
      v_cactivi      codiactseg.cactivi%TYPE;
      v_detmovseguro detmovseguro%ROWTYPE;
      v_cont         NUMBER;
      v_sseguro      NUMBER;
      v_capital      NUMBER;
      v_ipritar      NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;


      FOR x IN
         (SELECT   a.*, s.sseguro s_sseguro,
                   MIN(a.fefecto) OVER(PARTITION BY SUBSTR(a.mig_fk, 1, 12), a.cgarant, a.ndetgar)
                                                                                   min_fefecto
              FROM mig_detgaranseg a, mig_seguros s, mig_movseguro m
             WHERE m.mig_pk = a.mig_fk
               AND s.mig_pk = m.mig_fk
               AND a.ncarga = pncarga
               AND a.cestmig = 1
          ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_garanseg THEN
               v_1_garanseg := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 4, 'DETGARANSEG');
            END IF;

            v_error := FALSE;
            v_detgaranseg := NULL;
            v_detgaranseg.cgarant := x.cgarant;
            v_detgaranseg.nriesgo := x.nriesgo;
            v_detgaranseg.nmovimi := x.nmovimi;
            v_detgaranseg.ndetgar := x.ndetgar;
            v_detgaranseg.sseguro := x.s_sseguro;
            v_detgaranseg.fefecto := x.min_fefecto;
            v_detgaranseg.finiefe := x.fefecto;
            v_detgaranseg.fvencim := x.fvencim;
            v_detgaranseg.ndurcob := x.ndurcob;
            v_detgaranseg.ctarifa := x.ctarifa;
            v_detgaranseg.pinttec := x.pinttec;
            v_detgaranseg.ftarifa := x.ftarifa;
            v_detgaranseg.crevali := x.crevali;
            v_detgaranseg.icapital := NVL(x.icapital, 0);
            v_detgaranseg.iprianu := NVL(x.iprianu, 0);
            v_detgaranseg.precarg := x.precarg;
            v_detgaranseg.irecarg := x.irecarg;
            v_detgaranseg.cparben := x.cparben;
            v_detgaranseg.cprepost := x.cprepost;
            --v_detgaranseg.pcomcom := x.pcomcom;
            --v_detgaranseg.pporint := x.pporint;
            v_detgaranseg.ffincob := x.ffincob;
            v_detgaranseg.ipritar := NVL(x.ipritar, 0);
            v_detgaranseg.cunica := x.cunica;
            v_detgaranseg.ipripur := x.ipripur;
            v_detgaranseg.ipriinv := x.ipriinv;

            -- 23289/120321 - ECP- 04/09/2012
            IF ptablas = 'EST' THEN
               SELECT finiefe
                 INTO v_detgaranseg.finiefe
                 FROM estgaranseg
                WHERE sseguro = x.s_sseguro
                  AND nriesgo = x.nriesgo
                  AND cgarant = x.cgarant
                  AND nmovimi = x.nmovimi;
            ELSE
               SELECT finiefe
                 INTO v_detgaranseg.finiefe
                 FROM garanseg
                WHERE sseguro = x.s_sseguro
                  AND nriesgo = x.nriesgo
                  AND cgarant = x.cgarant
                  AND nmovimi = x.nmovimi;
            END IF;

            INSERT INTO detgaranseg
                 VALUES v_detgaranseg;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 4,
                         v_detgaranseg.sseguro || '|' || v_detgaranseg.nriesgo || '|'
                         || v_detgaranseg.cgarant || '|' || v_detgaranseg.nmovimi || '|'
                         || TO_CHAR(v_detgaranseg.finiefe, 'yyyymmdd') || '|'
                         || v_detgaranseg.ndetgar);

            UPDATE mig_detgaranseg
               SET sseguro = v_detgaranseg.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         v_sseguro:=x.sseguro;
         COMMIT;
      END LOOP;

      -- INI RLLF 04/05/2016 0034532: POSTEC - Migracion PU y MVA
               -- Insertar suplementos de MVA.
      FOR Y IN (SELECT A.SSEGURO,M.NMOVIMI,M.CMOTMOV,A.CGARANT,A.NRIESGO
              FROM mig_detgaranseg a, mig_seguros s, mig_movseguro m
             WHERE m.mig_pk = a.mig_fk
               AND s.mig_pk = m.mig_fk
               AND a.ncarga = pncarga
               AND a.cestmig = 2
               AND m.cmotmov=556
          ORDER BY a.mig_pk)
      LOOP
       SELECT icapital, ipritar
       INTO v_capital, v_ipritar
       FROM DETGARANSEG D
       WHERE D.SSEGURO=Y.SSEGURO AND D.NMOVIMI=Y.NMOVIMI AND D.CGARANT=Y.CGARANT AND D.NDETGAR=
       (SELECT MAX(D2.NDETGAR) FROM DETGARANSEG D2 WHERE D2.SSEGURO=D.SSEGURO AND
         D2.NMOVIMI=D.NMOVIMI AND D2.CGARANT=D.CGARANT);

       v_detmovseguro.sseguro := y.sseguro;
       v_detmovseguro.nmovimi := y.nmovimi;
       v_detmovseguro.cmotmov := y.cmotmov;
       v_detmovseguro.cpregun := 0;
       v_detmovseguro.tvalora := null;
       v_detmovseguro.tvalord := f_axis_literales(1000073, f_idiomauser) || ': ' || v_capital || '  ' || f_axis_literales(9907732, f_idiomauser) || ': ' || v_ipritar;
       v_detmovseguro.cgarant := y.cgarant;
       v_detmovseguro.nriesgo := y.nriesgo;

       BEGIN
        INSERT INTO detmovseguro
                             VALUES v_detmovseguro;
       EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          UPDATE detmovseguro
                              SET tvalora = v_detmovseguro.tvalora,
                                  tvalord = v_detmovseguro.tvalord
                            WHERE sseguro = v_detmovseguro.sseguro
                              AND nriesgo = v_detmovseguro.nriesgo
                              AND cgarant = v_detmovseguro.cgarant
                              AND cpregun = NVL(v_detmovseguro.cpregun, 0)
                              AND cmotmov = v_detmovseguro.cmotmov
                              AND nmovimi = v_detmovseguro.nmovimi;
       END;
      END LOOP;
      -- FIN RLLF 04/05/2016 0034532: POSTEC - Migracion PU y MVA


      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_detgaranseg;

-- INI RLLF 28/09/2015 función para migrar PBEX.
/***************************************************************************
      FUNCTION f_migra_pbex
      Función que inserta los registros grabados en MIG_PBEX, en la tabla
      PBEX de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_pbex(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_pbex       BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_pbex         pbex%ROWTYPE;
      v_seguros      seguros%ROWTYPE;
      v_estseguros   estseguros%ROWTYPE;
      v_garanpro     garanpro%ROWTYPE;
      v_sproduc      productos.sproduc%TYPE;
      v_cactivi      codiactseg.cactivi%TYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_pbex a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_pbex THEN
               v_1_pbex := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 4, 'PBEX');
            END IF;

            v_error := FALSE;
            v_pbex := NULL;
            v_pbex.cempres := x.cempres;
            v_pbex.fcalcul := x.fcalcul;
            v_pbex.sproces := x.sproces;
            v_pbex.cramdgs := x.cramdgs;
            v_pbex.cramo := x.cramo;
            v_pbex.cmodali := x.cmodali;
            v_pbex.ctipseg := x.ctipseg;
            v_pbex.ccolect := x.ccolect;
            v_pbex.sseguro := x.s_sseguro;
            v_pbex.cgarant := x.cgarant;
            v_pbex.ivalact := NVL(x.ivalact, 0);
            v_pbex.icapgar := NVL(x.icapgar, 0);
            v_pbex.ipromat := NVL(x.ipromat, 0);
            v_pbex.cerror := NVL(x.cerror, 0);
            v_pbex.nriesgo := NVL(x.nriesgo, 0);

            INSERT INTO pbex
                 VALUES v_pbex;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 4,
                         v_pbex.sproces || '|' || v_pbex.sseguro || '|'
                         || TO_CHAR(v_pbex.fcalcul, 'yyyymmdd') || '|' || v_pbex.nriesgo || '|'
                         || v_pbex.cgarant);

            UPDATE mig_pbex
               SET sseguro = v_pbex.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_pbex;

-- FIN RLLF 28/09/2015 función para migrar PBEX.

   -- INI RLLF 05/10/2015 función para migrar REEMPLAZOS.
/***************************************************************************
      FUNCTION f_migra_pbex
      Función que inserta los registros grabados en MIG_MIGREEMPLAZOS, en la tabla
      REEMPLAZOS de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_reemplazos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_pbex       BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_reemplazos   reemplazos%ROWTYPE;
      v_sproduc      productos.sproduc%TYPE;
      v_cactivi      codiactseg.cactivi%TYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_reemplazos a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_pbex THEN
               v_1_pbex := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 4, 'REEMPLAZOS');
            END IF;

            v_error := FALSE;
            v_reemplazos := NULL;
            v_reemplazos.sseguro := x.s_sseguro;
            v_reemplazos.sreempl := x.sreempl;
            v_reemplazos.fmovdia := x.fmovdia;
            v_reemplazos.cusuario := x.cusuario;
            v_reemplazos.cagente := x.cagente;
            v_reemplazos.ctipo := x.ctipo;

            INSERT INTO reemplazos
                 VALUES v_reemplazos;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 4, pncarga || '|' || v_reemplazos.sseguro);

            UPDATE mig_reemplazos
               SET sseguro = v_reemplazos.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_reemplazos;

-- FIN RLLF 28/09/2015  función para migrar REEMPLAZOS.

   -- FIN BUG 8402 - 15-05-2009 - JMC
-- BUG 10395 - 17-06-2009 - JMC - Función para la migración de la tabla COMISIGARANSEG
/***************************************************************************
      FUNCTION f_migra_comisigaranseg
      Función que inserta los registros grabados en MIG_COMISIGARANSEG, en la tabla
      COMISIGARANSEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_comisigaranseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_garanseg   BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_comisigaranseg comisigaranseg%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_comisigaranseg a, mig_seguros s, mig_movseguro m
                   WHERE m.mig_pk = a.mig_fk
                     AND s.mig_pk = m.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_garanseg THEN
               v_1_garanseg := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 4, 'COMISIGARANSEG');
            END IF;

            v_error := FALSE;
            v_comisigaranseg := NULL;
            v_comisigaranseg.sseguro := x.s_sseguro;
            v_comisigaranseg.nriesgo := x.nriesgo;
            v_comisigaranseg.cgarant := x.cgarant;
            v_comisigaranseg.nmovimi := x.nmovimi;
            v_comisigaranseg.finiefe := x.finiefe;
            v_comisigaranseg.iprianu := x.iprianu;
            v_comisigaranseg.pcomisi := x.pcomisi;
            v_comisigaranseg.icomanu := x.icomanu;
            v_comisigaranseg.itotcom := x.itotcom;
            v_comisigaranseg.ndetgar := x.ndetgar;
            v_comisigaranseg.ffinpg := x.ffinpg;

            INSERT INTO comisigaranseg
                 VALUES v_comisigaranseg;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 4,
                         v_comisigaranseg.sseguro || '|' || v_comisigaranseg.nriesgo || '|'
                         || v_comisigaranseg.cgarant || '|' || v_comisigaranseg.nmovimi || '|'
                         || TO_CHAR(v_comisigaranseg.finiefe, 'yyyymmdd') || '|'
                         || v_comisigaranseg.ndetgar);

            UPDATE mig_comisigaranseg
               SET sseguro = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_comisigaranseg;

-- FIN BUG 10395 - 17-06-2009 - JMC
/***************************************************************************
      FUNCTION f_migra_pregunseg
      Función que inserta los registros grabados en MIG_PREGUNSEG, en las tablas
      PREGUNSEG y PROGUNPOLSEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_pregunseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_pregunseg  BOOLEAN := TRUE;
      v_1_pregunpol  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_pregunseg    pregunseg%ROWTYPE;
      v_ntabaxis     NUMBER := 3;
      v_ntabaxisseg  NUMBER := 3;
      v_ntabaxispol  NUMBER := 3;
--     v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, ctippre,
                         pro.cnivel cnivel   -- jlb para saber  si es de riesgo o de póliza
                    FROM mig_pregunseg a, mig_seguros s, codipregun p, pregunpro pro
                   --BUG 12855 - 15-02-2010 - JMC - Se añade tabla codipregun
                WHERE    s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                     AND p.cpregun = a.cpregun
                     AND pro.cpregun = a.cpregun
                     AND pro.sproduc = s.sproduc
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF x.nriesgo IS NOT NULL THEN
               IF v_1_pregunseg THEN
                  v_1_pregunseg := FALSE;
                  v_ntabaxis := v_ntabaxis + 1;
                  v_ntabaxisseg := v_ntabaxis;
                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, v_ntabaxis,
                                                       'PREGUNSEG');
               END IF;
            ELSE
               IF v_1_pregunpol THEN
                  v_1_pregunpol := FALSE;
                  v_ntabaxis := v_ntabaxis + 1;
                  v_ntabaxispol := v_ntabaxis;
                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, v_ntabaxis,
                                                       'PREGUNPOLSEG');
               END IF;
            END IF;

            v_error := FALSE;
            v_pregunseg := NULL;
            v_pregunseg.cpregun := x.cpregun;
            v_pregunseg.nriesgo := x.nriesgo;
            --v_pregunseg.nmovimi := 1; --Bug 0012557 - 14-01-2009 - JMC - Se elimina linea
            v_pregunseg.sseguro := x.s_sseguro;

            --BUG 12855 - 15-02-2010 - JMC - Dependiendo del tipo se graba el CRESPUE o TRESPUE
            IF x.ctippre IN(4, 5) THEN
               v_pregunseg.trespue := x.crespue;
               v_pregunseg.crespue := 0;   --BUG 14172 - 27-04-2010 - JMC
            ELSE
               v_pregunseg.crespue := x.crespue;
            END IF;

            --FIN BUG 12855 - 15-02-2010 - JMC

            --Ini Bug 0012557 - 14-01-2009 - JMC - Se obtiene nmovimi
            IF x.nmovimi = 0 THEN
               SELECT MAX(nmovimi)
                 INTO v_pregunseg.nmovimi
                 FROM movseguro
                WHERE sseguro = x.s_sseguro
                  AND cmovseg <> 3;
            ELSE
               v_pregunseg.nmovimi := x.nmovimi;
            END IF;

            --Fin Bug 0012557 - 14-01-2009 - JMC
            --            IF x.nriesgo IS NOT NULL THEN
            IF x.cnivel = 'R' THEN
               -- 23289/120321 - ECP- 04/09/2012 Inicio
               IF ptablas = 'EST' THEN
                  INSERT INTO estpregunseg
                              (sseguro, nriesgo, cpregun,
                               crespue, nmovimi,
                               trespue)
                       VALUES (v_pregunseg.sseguro, v_pregunseg.nriesgo, v_pregunseg.cpregun,
                               v_pregunseg.crespue, NVL(v_pregunseg.nmovimi, 1),
                               v_pregunseg.trespue);
               ELSE
                  INSERT INTO pregunseg
                              (sseguro, nriesgo, cpregun,
                               crespue, nmovimi, trespue)
                       VALUES (v_pregunseg.sseguro, v_pregunseg.nriesgo, v_pregunseg.cpregun,
                               v_pregunseg.crespue, v_pregunseg.nmovimi, v_pregunseg.trespue);
               END IF;

               -- 23289/120321 - ECP- 04/09/2012  Fin
               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, v_ntabaxisseg,
                            v_pregunseg.sseguro || '|' || v_pregunseg.nriesgo || '|'
                            || v_pregunseg.cpregun || '|' || v_pregunseg.nmovimi);
            ELSE
               -- 23289/120321 - ECP- 04/09/2012 Inicio
               IF ptablas = 'EST' THEN
                  INSERT INTO estpregunpolseg
                              (sseguro, cpregun, crespue,
                               nmovimi, trespue)
                       VALUES (v_pregunseg.sseguro, v_pregunseg.cpregun, v_pregunseg.crespue,
                               v_pregunseg.nmovimi, v_pregunseg.trespue);
               ELSE
                  INSERT INTO pregunpolseg
                              (sseguro, cpregun, crespue,
                               nmovimi, trespue)
                       VALUES (v_pregunseg.sseguro, v_pregunseg.cpregun, v_pregunseg.crespue,
                               v_pregunseg.nmovimi, v_pregunseg.trespue);
               END IF;

               -- 23289/120321 - ECP- 04/09/2012  Fin
               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, v_ntabaxispol,
                            v_pregunseg.sseguro || '|' || v_pregunseg.cpregun || '|'
                            || v_pregunseg.nmovimi);
            END IF;

            UPDATE mig_pregunseg
               SET sseguro = v_pregunseg.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
         --  ROLLBACK;
         -- EXIT;
         END;
      --COMMIT;
      END LOOP;

      --      SELECT COUNT(*)
      --       INTO v_cont
      --       FROM mig_logs_axis
      --      WHERE ncarga = pncarga
      --       AND tipo = 'E';
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_pregunseg;

-- JLB - Añado preguntas a nivel de tabla
/***************************************************************************
      FUNCTION f_migra_preguntab
      Función que inserta los registros grabados en MIG_PREGUNSEGTAB, en las tablas
      PREGUNSEG y PROGUNPOLSEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_preguntab(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_pregunsegtab BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_pregunsegtab pregunsegtab%ROWTYPE;
      v_ntabaxis     NUMBER := 3;
      v_ntabaxisseg  NUMBER := 3;
      v_ntabaxispol  NUMBER := 3;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, ctipdato
                    FROM mig_pregunsegtab a, mig_seguros s, pregunprotab p
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                     AND p.cpregun = a.cpregun
                     AND p.sproduc = s.sproduc
                     AND p.columna = a.columna
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_pregunsegtab THEN
               v_1_pregunsegtab := FALSE;
               v_ntabaxis := v_ntabaxis + 1;
               v_ntabaxisseg := v_ntabaxis;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, v_ntabaxis,
                                                    'PREGUNSEGTAB');
            END IF;

            v_error := FALSE;
            v_pregunsegtab := NULL;
            v_pregunsegtab.cpregun := x.cpregun;
            v_pregunsegtab.nriesgo := x.nriesgo;
            --v_pregunseg.nmovimi := 1; --Bug 0012557 - 14-01-2009 - JMC - Se elimina linea
            v_pregunsegtab.sseguro := x.s_sseguro;
            v_pregunsegtab.nlinea := x.fila;
            v_pregunsegtab.ccolumna := x.columna;

            --BUG 12855 - 15-02-2010 - JMC - Dependiendo del tipo se graba el CRESPUE o TRESPUE
            IF x.ctipdato = 1 THEN
               v_pregunsegtab.nvalor := x.crespue;
            ELSIF x.ctipdato = 2 THEN
               v_pregunsegtab.tvalor := x.crespue;
            ELSIF x.ctipdato = 3 THEN
               v_pregunsegtab.fvalor := TO_DATE(x.crespue, 'DD/MM/YYYY');
            END IF;

            --Ini Bug 0012557 - 14-01-2009 - JMC - Se obtiene nmovimi
            IF x.nmovimi = 0 THEN
               SELECT MAX(nmovimi)
                 INTO v_pregunsegtab.nmovimi
                 FROM movseguro
                WHERE sseguro = x.s_sseguro
                  AND cmovseg <> 3;
            ELSE
               v_pregunsegtab.nmovimi := x.nmovimi;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estpregunsegtab
                           (sseguro, nriesgo,
                            cpregun, nmovimi,
                            nlinea, ccolumna,
                            tvalor, fvalor,
                            nvalor)
                    VALUES (v_pregunsegtab.sseguro, v_pregunsegtab.nriesgo,
                            v_pregunsegtab.cpregun, v_pregunsegtab.nmovimi,
                            v_pregunsegtab.nlinea, v_pregunsegtab.ccolumna,
                            v_pregunsegtab.tvalor, v_pregunsegtab.fvalor,
                            v_pregunsegtab.nvalor);
            ---
            ELSE
               INSERT INTO pregunsegtab
                           (sseguro, nriesgo,
                            cpregun, nmovimi,
                            nlinea, ccolumna,
                            tvalor, fvalor,
                            nvalor)
                    VALUES (v_pregunsegtab.sseguro, v_pregunsegtab.nriesgo,
                            v_pregunsegtab.cpregun, v_pregunsegtab.nmovimi,
                            v_pregunsegtab.nlinea, v_pregunsegtab.ccolumna,
                            v_pregunsegtab.tvalor, v_pregunsegtab.fvalor,
                            v_pregunsegtab.nvalor);
            END IF;

            -- 23289/120321 - ECP- 04/09/2012  Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, v_ntabaxisseg,
                         v_pregunsegtab.sseguro || '|' || v_pregunsegtab.nriesgo || '|'
                         || v_pregunsegtab.cpregun || '|' || v_pregunsegtab.nmovimi);

            UPDATE mig_pregunsegtab
               SET sseguro = v_pregunsegtab.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_preguntab;

/***************************************************************************
      FUNCTION f_migra_ctaseguro
      Función que inserta los registros grabados en MIG_CTASEGURO, en la tabla
      ctaseguro de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctaseguro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_ctaseguro  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_ctaseguro    ctaseguro%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, s.cempres
                    FROM mig_ctaseguro a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_ctaseguro THEN
               v_1_ctaseguro := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'CTASEGURO');
            END IF;

            v_error := NULL;
            v_ctaseguro := NULL;
            v_ctaseguro.sseguro := x.s_sseguro;
            v_ctaseguro.fcontab := x.fcontab;
            v_ctaseguro.nnumlin := x.nnumlin;
            v_ctaseguro.ffecmov := x.ffecmov;
            v_ctaseguro.fvalmov := x.fvalmov;
            v_ctaseguro.cmovimi := x.cmovimi;
            v_ctaseguro.imovimi := x.imovimi;
            v_ctaseguro.ccalint := x.ccalint;
            v_ctaseguro.imovim2 := x.imovim2;
            v_ctaseguro.nrecibo := x.nrecibo;
            v_ctaseguro.nsinies := x.nsinies;
            v_ctaseguro.cmovanu := x.cmovanu;
            v_ctaseguro.smovrec := x.smovrec;
            v_ctaseguro.cesta := x.cesta;
            v_ctaseguro.nunidad := x.nunidad;
            v_ctaseguro.cestado := x.cestado;
            v_ctaseguro.fasign := x.fasign;
            v_ctaseguro.nparpla := x.nparpla;
            v_ctaseguro.cestpar := x.cestpar;
            v_ctaseguro.iexceso := x.iexceso;
            v_ctaseguro.spermin := x.spermin;
            v_ctaseguro.sidepag := x.sidepag;
            v_ctaseguro.ctipapor := x.ctipapor;
            v_ctaseguro.srecren := x.srecren;

            INSERT INTO ctaseguro
                 VALUES v_ctaseguro;

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF NVL(pac_parametros.f_parempresa_n(x.cempres, 'MULTIMONEDA'), 0) = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_monpol(v_ctaseguro.sseguro,
                                                                     v_ctaseguro.fcontab,
                                                                     v_ctaseguro.nnumlin,
                                                                     v_ctaseguro.fvalmov);

               IF num_err <> 0 THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E', 'Error: ' || num_err);
                  v_error := TRUE;
                  ROLLBACK;
               END IF;
            END IF;

            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_ctaseguro.sseguro || '|' || TO_CHAR(v_ctaseguro.fcontab, 'yyyymmdd')
                         || '|' || v_ctaseguro.nnumlin);

            UPDATE mig_ctaseguro
               SET sseguro = v_ctaseguro.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;
      ---  COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_ctaseguro;

---------------------------------etm ini
   -- BUG 34776/216124- 22-10-2015 - ETM - Función para la migración de MIG_CTASEGURO_SHADOW y SEGDISIN2 --INI
/***************************************************************************
      FUNCTION f_migra_ctaseguro_shadow
      Función que inserta los registros grabados en MIG_CTASEGURO_SHADOW, en la tabla
      ctaseguro_shadow de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctaseguro_shadow(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_ctaseguro  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_ctaseguro    ctaseguro_shadow%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, s.cempres
                    FROM mig_ctaseguro_shadow a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_ctaseguro THEN
               v_1_ctaseguro := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'CTASEGURO_SHADOW');
            END IF;

            v_error := NULL;
            v_ctaseguro := NULL;
            v_ctaseguro.sseguro := x.s_sseguro;
            v_ctaseguro.fcontab := x.fcontab;
            v_ctaseguro.nnumlin := x.nnumlin;
            v_ctaseguro.ffecmov := x.ffecmov;
            v_ctaseguro.fvalmov := x.fvalmov;
            v_ctaseguro.cmovimi := x.cmovimi;
            v_ctaseguro.imovimi := x.imovimi;
            v_ctaseguro.ccalint := x.ccalint;
            v_ctaseguro.imovim2 := x.imovim2;
            v_ctaseguro.nrecibo := x.nrecibo;
            v_ctaseguro.nsinies := x.nsinies;
            v_ctaseguro.cmovanu := x.cmovanu;
            v_ctaseguro.smovrec := x.smovrec;
            v_ctaseguro.cesta := x.cesta;
            v_ctaseguro.nunidad := x.nunidad;
            v_ctaseguro.cestado := x.cestado;
            v_ctaseguro.fasign := x.fasign;
            v_ctaseguro.nparpla := x.nparpla;
            v_ctaseguro.cestpar := x.cestpar;
            v_ctaseguro.iexceso := x.iexceso;
            v_ctaseguro.spermin := x.spermin;
            v_ctaseguro.sidepag := x.sidepag;
            v_ctaseguro.ctipapor := x.ctipapor;
            v_ctaseguro.srecren := x.srecren;

            INSERT INTO ctaseguro_shadow
                 VALUES v_ctaseguro;

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF NVL(pac_parametros.f_parempresa_n(x.cempres, 'MULTIMONEDA'), 0) = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_monpol(v_ctaseguro.sseguro,
                                                                     v_ctaseguro.fcontab,
                                                                     v_ctaseguro.nnumlin,
                                                                     v_ctaseguro.fvalmov);

               IF num_err <> 0 THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E', 'Error: ' || num_err);
                  v_error := TRUE;
                  ROLLBACK;
               END IF;
            END IF;

            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_ctaseguro.sseguro || '|' || TO_CHAR(v_ctaseguro.fcontab, 'yyyymmdd')
                         || '|' || v_ctaseguro.nnumlin);

            UPDATE mig_ctaseguro_shadow
               SET sseguro = v_ctaseguro.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;
      ---  COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_ctaseguro_shadow;

 --FIN  BUG 34776/216124 - 22-10-2015 - ETM - Función para la migración de MIG_CTASEGURO_SHADOW y SEGDISIN2
/***************************************************************************
      FUNCTION f_migra_ctaseguro_libreta
      Función que inserta los registros grabados en MIG_CTASEGURO_LIBRETA, en la tabla
      CTASEGURO_LIBRETA de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctaseguro_libreta(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_ctaseguro  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_ctaseguro    ctaseguro_libreta%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_ctaseguro_libreta a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_ctaseguro THEN
               v_1_ctaseguro := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'CTASEGURO_LIBRETA');
            END IF;

            v_error := NULL;
            v_ctaseguro := NULL;
            v_ctaseguro.sseguro := x.s_sseguro;
            v_ctaseguro.nnumlin := x.nnumlin;
            v_ctaseguro.fcontab := x.fcontab;
            v_ctaseguro.ccapgar := x.ccapgar;
            v_ctaseguro.ccapfal := x.ccapfal;
            v_ctaseguro.nmovimi := x.nmovimi;
            v_ctaseguro.sintbatch := x.sintbatch;
            v_ctaseguro.nnumlib := x.nnumlib;
            v_ctaseguro.npagina := x.npagina;
            v_ctaseguro.nlinea := x.nlinea;
            v_ctaseguro.fimpres := x.fimpres;
            v_ctaseguro.sreimpre := x.sreimpre;
            v_ctaseguro.igasext := x.igasext;
            v_ctaseguro.igasint := x.igasint;

            INSERT INTO ctaseguro_libreta
                 VALUES v_ctaseguro;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_ctaseguro.sseguro || '|' || TO_CHAR(v_ctaseguro.fcontab, 'yyyymmdd')
                         || '|' || v_ctaseguro.nnumlin);

            UPDATE mig_ctaseguro_libreta
               SET sseguro = v_ctaseguro.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_ctaseguro_libreta;

/***************************************************************************
      FUNCTION f_migra_pregungaranseg
      Función que inserta los registros grabados en MIG_PREGUNGARANSEG, en la tabla
      PREGUNGARANSEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_pregungaranseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_garanseg   BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_pregungaranseg pregungaranseg%ROWTYPE;
      v_seguros      seguros%ROWTYPE;
      v_cont         NUMBER;
      vntraza        VARCHAR2(10);
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, m.fefecto, m.nmovimi, p.ctippre
                    --Bug 0012557 - 14-01-2009 - JMC - fefecto de mig_movseguro
                FROM     mig_pregungaranseg a, mig_seguros s, mig_movseguro m, codipregun p
                   WHERE m.mig_pk = a.mig_fk
                     AND s.mig_pk = m.mig_fk
                     AND p.cpregun = a.cpregun
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_garanseg THEN
               v_1_garanseg := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'PREGUNGARANSEG');
            END IF;

            vntraza := 1;
            v_error := FALSE;
            v_pregungaranseg := NULL;
            v_pregungaranseg.cgarant := x.cgarant;
            v_pregungaranseg.nriesgo := x.nriesgo;
            v_pregungaranseg.nmovimi := x.nmovimi;
            v_pregungaranseg.nmovima := 1;
            v_pregungaranseg.sseguro := x.s_sseguro;
            v_pregungaranseg.finiefe := x.fefecto;
            v_pregungaranseg.cpregun := x.cpregun;
            vntraza := 2;

            IF x.ctippre IN(4, 5) THEN
               v_pregungaranseg.trespue := x.crespue;
               v_pregungaranseg.crespue := 0;
            ELSE
               v_pregungaranseg.crespue := x.crespue;
            END IF;

            vntraza := 3;

            IF ptablas = 'EST' THEN
               INSERT INTO estpregungaranseg
                    VALUES v_pregungaranseg;
            ELSE
               INSERT INTO pregungaranseg
                    VALUES v_pregungaranseg;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_pregungaranseg.sseguro || '|' || v_pregungaranseg.nriesgo || '|'
                         || v_pregungaranseg.cgarant || '|' || v_pregungaranseg.nmovimi || '|'
                         || TO_CHAR(v_pregungaranseg.finiefe, 'yyyymmdd') || '|'
                         || v_pregungaranseg.nmovima || '|' || v_pregungaranseg.cpregun);

            UPDATE mig_pregungaranseg
               SET sseguro = v_pregungaranseg.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error PREGUNGARANSEG: ' || vntraza || ' '
                                              || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      -- BUG : 10395 - 18-06-2009 - JMC - Llamada a p_cuadro
      p_cuadro(pncarga, pntab);

      -- FIN BUG : 10395 - 18-06-2009 - JMC
      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_pregungaranseg;

/***************************************************************************
      FUNCTION f_migra_clausuesp
      Función que inserta los registros grabados en MIG_CLAUSUESP, en las tablas
      CLAUSUESP, CLAUBENSEG y CLAUSUSEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_clausuesp(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_clausuesp  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_clausuesp    clausuesp%ROWTYPE;
      v_claubenseg   claubenseg%ROWTYPE;
      v_claususeg    claususeg%ROWTYPE;
      v_seguros      seguros%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, s.fefecto
                    FROM mig_clausuesp a, mig_seguros s, mig_movseguro m
                   WHERE m.mig_pk = a.mig_fk
                     AND s.mig_pk = m.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_clausuesp THEN
               v_1_clausuesp := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 20, 'CLAUSUESP');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 30, 'CLAUBENSEG');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 40, 'CLAUSUSEG');
            END IF;

            v_error := FALSE;

            --Determinamos si la clausula es especial o definida por producto
            IF x.sclagen IS NULL
               OR(x.sclagen IS NOT NULL
                  AND x.cclaesp = 4) THEN   -- Especial, o por pregunta
               BEGIN
                  v_clausuesp := NULL;
                  v_clausuesp.nmovimi := x.nmovimi;
                  v_clausuesp.sseguro := x.s_sseguro;
                  v_clausuesp.cclaesp := x.cclaesp;
                  v_clausuesp.nordcla := x.nordcla;
                  v_clausuesp.nriesgo := x.nriesgo;
                  v_clausuesp.finiclau := x.finiclau;
                  v_clausuesp.sclagen := x.sclagen;
                  v_clausuesp.tclaesp := x.tclaesp;
                  v_clausuesp.ffinclau := x.ffinclau;

                  IF ptablas = 'EST' THEN
                     SELECT NVL(MAX(nordcla), 0) + 1
                       INTO v_clausuesp.nordcla
                       FROM estclausuesp
                      WHERE sseguro = v_clausuesp.sseguro
                        AND nriesgo = v_clausuesp.nriesgo
                        AND nmovimi = v_clausuesp.nmovimi
                        AND cclaesp = v_clausuesp.cclaesp;

                     INSERT INTO estclausuesp
                                 (nmovimi, sseguro,
                                  cclaesp, nordcla,
                                  nriesgo, finiclau,
                                  sclagen, tclaesp,
                                  ffinclau)
                          VALUES (v_clausuesp.nmovimi, v_clausuesp.sseguro,
                                  v_clausuesp.cclaesp, v_clausuesp.nordcla,
                                  v_clausuesp.nriesgo, v_clausuesp.finiclau,
                                  v_clausuesp.sclagen, v_clausuesp.tclaesp,
                                  v_clausuesp.ffinclau);
                  ELSE
                     SELECT NVL(MAX(nordcla), 0) + 1
                       INTO v_clausuesp.nordcla
                       FROM clausuesp
                      WHERE sseguro = v_clausuesp.sseguro
                        AND nriesgo = v_clausuesp.nriesgo
                        AND nmovimi = v_clausuesp.nmovimi
                        AND cclaesp = v_clausuesp.cclaesp;

                     INSERT INTO clausuesp
                          VALUES v_clausuesp;
                  END IF;

                  INSERT INTO mig_pk_mig_axis
                       VALUES (x.mig_pk, pncarga, pntab, 20,
                               v_clausuesp.sseguro || '|' || v_clausuesp.nriesgo || '|'
                               || v_clausuesp.cclaesp || '|' || v_clausuesp.nmovimi || '|'
                               || v_clausuesp.nordcla);
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error clausuesp:' || SQLCODE || '-'
                                                    || SQLERRM);
                     v_error := TRUE;
                     ROLLBACK;
               END;
            ELSE   -- Producto
               --Determinamos si es General o Beneficiario
               IF x.cclaesp = 1 THEN   --Clausula Beneficiario (claubenseg)
                  BEGIN
                     v_claubenseg := NULL;
                     v_claubenseg.finiclau := x.finiclau;
                     v_claubenseg.sclaben := x.sclagen;
                     v_claubenseg.sseguro := x.s_sseguro;
                     v_claubenseg.nmovimi := x.nmovimi;
                     v_claubenseg.ffinclau := x.ffinclau;

                     IF ptablas = 'EST' THEN
                        IF NVL(x.nriesgo, 0) = 0 THEN
                           SELECT nriesgo
                             INTO v_claubenseg.nriesgo
                             FROM estriesgos
                            WHERE sseguro = v_claubenseg.sseguro;
                        ELSE
                           v_claubenseg.nriesgo := x.nriesgo;
                        END IF;

                        INSERT INTO estclaubenseg
                                    (nmovimi, sclaben,
                                     sseguro, nriesgo,
                                     finiclau, ffinclau)
                             VALUES (v_claubenseg.nmovimi, v_claubenseg.sclaben,
                                     v_claubenseg.sseguro, v_claubenseg.nriesgo,
                                     v_claubenseg.finiclau, v_claubenseg.ffinclau);
                     ELSE
                        IF NVL(x.nriesgo, 0) = 0 THEN
                           SELECT nriesgo
                             INTO v_claubenseg.nriesgo
                             FROM riesgos
                            WHERE sseguro = v_claubenseg.sseguro;
                        ELSE
                           v_claubenseg.nriesgo := x.nriesgo;
                        END IF;

                        INSERT INTO claubenseg
                             VALUES v_claubenseg;
                     END IF;

                     INSERT INTO mig_pk_mig_axis
                          VALUES (x.mig_pk, pncarga, pntab, 30,
                                  v_claubenseg.nmovimi || '|' || v_claubenseg.sclaben || '|'
                                  || v_claubenseg.sseguro || '|' || v_claubenseg.nriesgo);
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                       'Error claubenseg:' || SQLCODE || '-'
                                                       || SQLERRM);
                        v_error := TRUE;
                        ROLLBACK;
                  END;
               ELSIF x.cclaesp = 2 THEN   --Clausula General (claususeg)
                  BEGIN
                     v_claususeg := NULL;
                     v_claususeg.nmovimi := x.nmovimi;
                     v_claususeg.sseguro := x.s_sseguro;
                     v_claususeg.sclagen := x.sclagen;
                     v_claususeg.finiclau := x.finiclau;
                     v_claususeg.ffinclau := x.ffinclau;
                     v_claususeg.nordcla := x.nordcla;

                     IF ptablas = 'EST' THEN
                        SELECT NVL(MAX(nordcla), 0) + 1
                          INTO v_claususeg.nordcla
                          FROM estclaususeg
                         WHERE sseguro = v_claususeg.sseguro
                           AND sclagen = v_claususeg.sclagen
                           AND nmovimi = v_claususeg.nmovimi;

                        INSERT INTO estclaususeg
                                    (nmovimi, sseguro,
                                     sclagen, finiclau,
                                     ffinclau, nordcla)
                             VALUES (v_claususeg.nmovimi, v_claususeg.sseguro,
                                     v_claususeg.sclagen, v_claususeg.finiclau,
                                     v_claususeg.ffinclau, v_claususeg.nordcla);
                     ELSE
                        SELECT NVL(MAX(nordcla), 0) + 1
                          INTO v_claususeg.nordcla
                          FROM claususeg
                         WHERE sseguro = v_claususeg.sseguro
                           AND sclagen = v_claususeg.sclagen
                           AND nmovimi = v_claususeg.nmovimi;

                        INSERT INTO claususeg
                             VALUES v_claususeg;
                     END IF;

                     INSERT INTO mig_pk_mig_axis
                          VALUES (x.mig_pk, pncarga, pntab, 40,
                                  v_claususeg.sseguro || '|' || v_claususeg.nmovimi || '|'
                                  || v_claususeg.sclagen);
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                       'Error claususeg:' || SQLCODE || '-'
                                                       || SQLERRM);
                        v_error := TRUE;
                        ROLLBACK;
                  END;
               END IF;
            END IF;

            IF NOT v_error THEN
               UPDATE mig_clausuesp
                  SET sseguro = x.s_sseguro,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_clausuesp;

/***************************************************************************
      FUNCTION f_migra_age_corretaje
       Función que inserta los registros grabados en MIG_AGE_CORRETAJE, en las tablas
       AGE_CORRETAJE de AXIS.
          param in  pncarga:     Número de carga.
          param in  pntab:       Número de tabla.
          param in  ptablas      EST Simulaciones POL Pólizas
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_age_corretaje(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_age_corretaje BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_age_corretaje age_corretaje%ROWTYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      --COMMIT;
      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, s.fefecto
                    FROM mig_age_corretaje a, mig_seguros s, mig_movseguro m
                   WHERE m.mig_pk = a.mig_fk
                     AND s.mig_pk = m.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_age_corretaje THEN
               v_1_age_corretaje := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'AGE_CORRETAJE');
            END IF;

            v_error := FALSE;

            BEGIN
               v_age_corretaje := NULL;
               v_age_corretaje.sseguro := x.s_sseguro;
               v_age_corretaje.nmovimi := x.nmovimi;
               v_age_corretaje.nordage := x.nordage;
               v_age_corretaje.cagente := x.cagente;
               v_age_corretaje.pcomisi := x.pcomisi;
               v_age_corretaje.ppartici := x.ppartici;
               v_age_corretaje.islider := x.islider;

               IF ptablas = 'EST' THEN
                  INSERT INTO estage_corretaje
                              (sseguro, nmovimi,
                               nordage, cagente,
                               pcomisi, ppartici,
                               islider)
                       VALUES (v_age_corretaje.sseguro, v_age_corretaje.nmovimi,
                               v_age_corretaje.nordage, v_age_corretaje.cagente,
                               v_age_corretaje.pcomisi, v_age_corretaje.ppartici,
                               v_age_corretaje.islider);
               ELSE
                  INSERT INTO age_corretaje
                       VALUES v_age_corretaje;
               END IF;

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 1,
                            v_age_corretaje.sseguro || '|' || v_age_corretaje.nmovimi || '|'
                            || v_age_corretaje.cagente);
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error age_corretaje:' || SQLCODE || '-'
                                                 || SQLERRM);
                  v_error := TRUE;
                  ROLLBACK;
            END;

            IF NOT v_error THEN
               UPDATE mig_age_corretaje
                  SET sseguro = x.s_sseguro,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      /* SELECT COUNT(*)
         INTO v_cont
         FROM mig_logs_axis
        WHERE ncarga = pncarga
          AND tipo = 'E'; */
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_age_corretaje;

/***************************************************************************
      FUNCTION f_migra_movseguro
      Función que inserta los registros grabados en MIG_MOVSEGURO, en las tablas
      MOVSEGURO, HISTORICOSEGUROS y DETMOVSEGURO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_movseguro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_movseguro  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_movseguro    movseguro%ROWTYPE;
      v_detmovseguro detmovseguro%ROWTYPE;
      v_cont         NUMBER;
      v_max_nmovimi  NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, s.femisio, s.sproduc, s.csituac
                    FROM mig_movseguro a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_fk, nmovimi) LOOP
         BEGIN
            IF v_1_movseguro THEN
               v_1_movseguro := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 2, 'MOVSEGURO');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 2, 'HISTORICOSEGUROS');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 3, 'DETMOVSEGURO');
               -- BUG : 10054 - 19-10-2009 - JMC - Insertamos en f_migra_movseguro la tabla PENALISEG
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 4, 'PENALISEG');
            -- FIN BUG : 10054 - 19-10-2009 - JMC
            END IF;

            v_error := FALSE;
            v_movseguro := NULL;
            v_detmovseguro := NULL;
            v_movseguro.sseguro := x.s_sseguro;
            v_detmovseguro.sseguro := x.s_sseguro;
            v_movseguro.nmovimi := x.nmovimi;
            v_detmovseguro.nmovimi := x.nmovimi;
            v_movseguro.cmotmov := x.cmotmov;
            v_detmovseguro.cmotmov := x.cmotmov;
            v_movseguro.fmovimi := x.fmovimi;
            v_movseguro.fefecto := x.fefecto;
            v_movseguro.cimpres := 0;
            v_movseguro.nsuplem := 0;
            v_movseguro.cmotven := x.cmotven;

            /* comentado por JMC 22-02-2011
                     --v_movseguro.femisio := x.fmovimi;
            v_movseguro.femisio := x.femisio;
            -- jlb ya que si esta en estado 4 y pone femisio luego no se esmite*/
            IF x.csituac IN(4, 5) THEN
               SELECT MAX(nmovimi)
                 INTO v_max_nmovimi
                 FROM mig_movseguro
                WHERE mig_fk = x.mig_fk;

               IF x.nmovimi = v_max_nmovimi THEN
                  v_movseguro.femisio := NULL;
               ELSE
                  v_movseguro.femisio := x.fmovimi;
               END IF;
            ELSE
               v_movseguro.femisio := x.fmovimi;

               -- si esta emitida , es el primer movimiento emito el seguro
               IF x.cmotmov = 100 THEN
                  UPDATE seguros
                     SET femisio = v_movseguro.femisio
                   WHERE sseguro = x.s_sseguro
                     AND femisio IS NULL;
               END IF;
            END IF;

            v_movseguro.cusumov := NVL(x.cusumov, f_user);
            v_detmovseguro.nriesgo := 0;
            v_detmovseguro.cgarant := 0;
            v_detmovseguro.tvalora := NULL;
            v_detmovseguro.cpregun := 0;
            v_detmovseguro.tvalord := f_axis_literales(151347, f_idiomauser);

            --Ini Bug 0012557 - 14-01-2009 - JMC - Si es baja al venvimiento, futuro cmotmov=319
            IF x.cmotmov = 221
               AND v_movseguro.cmotven IS NULL THEN
               v_movseguro.cmotven := 319;
            END IF;

            --Fin Bug 0012557 - 14-01-2009 - JMC
            BEGIN
               SELECT cmovseg
                 INTO v_movseguro.cmovseg
                 FROM codimotmov
                WHERE cmotmov = x.cmotmov;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error(movseguro-cmovseg):' || SQLCODE || '-'
                                                 || SQLERRM);
                  v_error := TRUE;
                  ROLLBACK;
            END;

            IF NOT v_error THEN
               BEGIN
                  IF ptablas <> 'EST' THEN   -- No existe tabla EST
                     INSERT INTO movseguro
                          VALUES v_movseguro;
                  END IF;

                  INSERT INTO mig_pk_mig_axis
                       VALUES (x.mig_pk, pncarga, pntab, 2,
                               v_movseguro.sseguro || '|' || v_movseguro.nmovimi);

                  UPDATE mig_movseguro
                     SET sseguro = x.s_sseguro,
                         cestmig = 2
                   WHERE mig_pk = x.mig_pk;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error(movseguro):' || SQLCODE || '-'
                                                    || SQLERRM);
                     v_error := TRUE;
                     ROLLBACK;
               END;
            END IF;

            IF NOT v_error THEN
               IF x.nmovimi > 1 THEN
                  num_err := f_act_hisseg(x.s_sseguro, x.nmovimi - 1);

                  IF num_err <> 0 THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error(f_act_hisseg):' || num_err);
                     v_error := TRUE;
                     ROLLBACK;
                  ELSE
                     INSERT INTO mig_pk_mig_axis
                          VALUES (x.mig_pk, pncarga, pntab, 2,
                                  x.s_sseguro || '|' || TO_CHAR(x.nmovimi - 1));
                  END IF;
               END IF;
            END IF;

            IF NOT v_error THEN
               IF x.cmotmov = 100 THEN
                  BEGIN
                     -- 23289/120321 - ECP- 04/09/2012 Inicio
                     IF ptablas = 'EST' THEN
                        INSERT INTO estdetmovseguro
                             VALUES v_detmovseguro;
                     ELSE
                        INSERT INTO detmovseguro
                             VALUES v_detmovseguro;
                     END IF;

                     -- 23289/120321 - ECP- 04/09/2012 Fin
                     INSERT INTO mig_pk_mig_axis
                          VALUES (x.mig_pk, pncarga, pntab, 3,
                                  v_detmovseguro.sseguro || '|' || v_detmovseguro.nmovimi
                                  || '|' || v_detmovseguro.cmotmov || '|'
                                  || v_detmovseguro.nriesgo || '|' || v_detmovseguro.cgarant
                                  || '|' || v_detmovseguro.cpregun);

                     UPDATE mig_movseguro
                        SET sseguro = x.s_sseguro,
                            cestmig = 3
                      WHERE mig_pk = x.mig_pk;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                       'Error(movseguro):' || SQLCODE || '-'
                                                       || SQLERRM);
                        v_error := TRUE;
                        ROLLBACK;
                  END;
               END IF;
            END IF;

            -- BUG : 10054 - 19-10-2009 - JMC - Proceso para grabar PENALISEG
               --Proceso para grabar PENALISEG
            IF NOT v_error THEN
               num_err := f_grabar_penalizacion(x.sproduc, x.sseguro, x.fefecto, x.nmovimi,
                                                x.mig_pk, pncarga, pntab);

               IF num_err <> 0 THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error (penaliseg):' || num_err);
                  v_error := TRUE;
                  ROLLBACK;
               END IF;
            END IF;
         -- FIN BUG : 10054 - 19-10-2009 - JMC
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_movseguro;

/***************************************************************************
      FUNCTION f_nrecibo
      Función que genera el número de recibo
      PREGUNGARANSEG de AXIS.
         param in  pcempres:    Código empresa.
         param in  pcolectivo:  SI o NO es un producto colectivo.
         param out pnrecibo:   Número de recibo.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_nrecibo(
      pcempres IN seguros.cempres%TYPE,
      pcolectivo IN VARCHAR2,
      pnrecibo OUT recibos.nrecibo%TYPE)
      RETURN NUMBER IS
   BEGIN
      IF NVL(pcolectivo, 'NO') = 'SI' THEN
         --En caso de ser un producto colectivo, se da numeros de recibos ficticios
         --para despues unir estos en un solo recibo.

         --De momento no lo hago.
         pnrecibo := 0;
      ELSE
         -- BUG18054:DRA:23/03/2011:Inici
         pnrecibo := pac_adm.f_get_seq_cont(pcempres);
      /****************************************************
            IF pcempres = 1 THEN
         SELECT seq_cont_01.NEXTVAL
           INTO pnrecibo
           FROM DUAL;
      ELSIF pcempres = 2 THEN
         SELECT seq_cont_02.NEXTVAL
           INTO pnrecibo
           FROM DUAL;
      ELSIF pcempres = 3 THEN
         SELECT seq_cont_03.NEXTVAL
           INTO pnrecibo
           FROM DUAL;
      ELSIF pcempres = 4 THEN
         SELECT seq_cont_04.NEXTVAL
           INTO pnrecibo
           FROM DUAL;
      ELSIF pcempres = 5 THEN
         SELECT seq_cont_05.NEXTVAL
           INTO pnrecibo
           FROM DUAL;
      ELSIF pcempres = 6 THEN
         SELECT seq_cont_06.NEXTVAL
           INTO pnrecibo
           FROM DUAL;
      ELSIF pcempres = 7 THEN
         SELECT seq_cont_07.NEXTVAL
           INTO pnrecibo
           FROM DUAL;
      ELSIF pcempres = 8 THEN
         SELECT seq_cont_08.NEXTVAL
           INTO pnrecibo
           FROM DUAL;
      ELSE
         SELECT seq_cont_09.NEXTVAL
           INTO pnrecibo
           FROM DUAL;
      END IF;
      ********************************************/
      -- BUG18054:DRA:23/03/2011:Fi
      END IF;

      IF NVL(pnrecibo, 0) = 0 THEN
         RETURN 102876;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pnrecibo := NULL;
         RETURN SQLCODE;
   END f_nrecibo;


   /*************************************************************************
          Función que en una liquidación devuelve en nliqmen  dependiendo de empresa, fecha liqui y agente
          y si estamos en modo real y existe algún previo lo borramos.

          param in pcempres   : código de la empresa
          param in pcagente   : Agente
          param in pfecliq    : Fecha lquidación
          param in psproces   : Código de todo el proceso de liquidación para todos los agentes
          param in pmodo      : Pmodo = 0 Real y 1 Previo
          return psquery   : varchar2
   *************************************************************************/
   FUNCTION f_get_nliqmen(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pmodo IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      v_nliqmen      NUMBER := NULL;
      v_nliqaux2     NUMBER := NULL;
      v_selec        CLOB;
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_get_nliqmen';
      v_param        VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ', pcagente: ' || pcagente
            || ', pfecliq: ' || pfecliq || ', psproces: ' || psproces || ', pmodo: ' || pmodo;
      v_pasexec      NUMBER(5) := 1;
      vdiasliq       NUMBER(5) := 0;
      vcestado       NUMBER;
   BEGIN
      BEGIN
         SELECT nliqmen
           INTO v_nliqmen
           FROM liquidacab
          WHERE cempres = pcempres
            AND sproliq = psproces
            AND cagente = pcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT NVL(MAX(nliqmen), 0) + 1
              INTO v_nliqmen
              FROM liquidacab
             WHERE cempres = pcempres
               AND cagente = pcagente;

            v_pasexec := 3;

            IF pmodo = 0 THEN   --Bug 27599 19/08/2013 Si es modo/liquidación REAL, el cestado = 1 de liquidacab
               vcestado := 1;
            END IF;

            --Creamos la cabecera de liquidacab por agente
            vnumerr := pac_liquida.f_set_cabeceraliq(pcagente, v_nliqmen, pfecliq, f_sysdate,
                                                     NULL, pcempres, psproces, NULL, NULL,
                                                     NULL, pmodo, vcestado, NULL, NULL);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            v_pasexec := 4;
      END;

      v_pasexec := 5;
      RETURN v_nliqmen;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_nliqmen;



/***************************************************************************
        FUNCTION f_migra_recibos
        Función que trata y traspasa la información de la tabla Intermedia
        MIG_RECIBOS (+MIG_SEGUROS), a las tablas de axis: RECIBOS y MOVRECIBO
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
           return            : 0 si valido, sino codigo error
     ***************************************************************************/
   FUNCTION f_migra_recibos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_recibos    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_tiene_movrec BOOLEAN := TRUE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_recibos      recibos%ROWTYPE;
      v_movrecibo    movrecibo%ROWTYPE;
      v_cagente      seguros.cagente%TYPE;
      v_nanuali      seguros.nanuali%TYPE;
      v_nfracci      seguros.nfracci%TYPE;
      v_ccobban      seguros.ccobban%TYPE;
      v_cforpag      seguros.cforpag%TYPE;
      v_cbancar      seguros.cbancar%TYPE;
      v_ctipban      seguros.ctipban%TYPE;
      v_ncuacoa      seguros.ncuacoa%TYPE;
      v_ctipcoa      seguros.ctipcoa%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_ctipemp      empresas.ctipemp%TYPE;
      v_ctippag      productos.ctippag%TYPE;
      v_ccarpen      productos.ccarpen%TYPE;
      v_ctipcob      seguros.ctipcob%TYPE;
      v_cestsop      recibos.cestsop%TYPE;
      v_cestimp      recibos.cestimp%TYPE;
      v_ctipreb      productos.ctipreb%TYPE;
      v_colect       VARCHAR2(2);
      v_cestaux      recibos.cestaux%TYPE;
      v_cbancob      NUMBER;
      v_cperven      NUMBER;
      v_cont         NUMBER;
      v_propietario  BOOLEAN := FALSE;
      vnliqmen       NUMBER;
      vnproces       NUMBER;
      vnliqlin       NUMBER;
      bEntra         NUMBER;
      vnprocdia      NUMBER;
      ltexto         VARCHAR2(200);
      ltexto2        VARCHAR2(200);
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;
      bEntra:=1;


      SELECT COUNT(*)
        INTO num_err
        FROM user_objects
       WHERE object_name = 'T_FEFEADM';

      IF num_err = 0 THEN
         v_propietario := FALSE;
      ELSE
         v_propietario := TRUE;
      END IF;

      IF v_propietario THEN
         num_err := f_trata_trigger('T_FEFEADM', 'DISABLE');
      END IF;

      IF num_err = 99
         AND v_propietario THEN
         num_err := f_ins_mig_logs_axis(pncarga, 'TRIGGER', 'E',
                                        'Error al deshabilitar trigger T_FEFEADM ');
         v_error := TRUE;
      ELSE
         SELECT COUNT(*)
           INTO num_err
           FROM mig_cargas_tab_mig
          WHERE ncarga = pncarga
            AND tab_des = 'MIG_MOVRECIBO'
            AND ffindes IS NULL;

         IF num_err > 0 THEN
            v_tiene_movrec := TRUE;
         ELSE
            v_tiene_movrec := FALSE;
         END IF;


         FOR x IN (SELECT   a.*, s.sseguro s_sseguro, ncertif, s.fefecto s_fefecto
                       --BUG 12855 - 15-02-2010 - JMC - Se añade ncertif
                   FROM     mig_recibos a, mig_seguros s
                      WHERE s.mig_pk = a.mig_fk
                        AND a.ncarga = pncarga
                        AND a.cestmig = 1
                   ORDER BY a.mig_pk) LOOP
            BEGIN
               IF v_1_recibos THEN
                  v_1_recibos := FALSE;
                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'RECIBOS');

                  IF NOT v_tiene_movrec THEN
                     num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 2, 'MOVRECIBO');
                  END IF;
               END IF;

               v_error := FALSE;

               /* Los campos cuyo valor se calcula, se calculan en base a como lo calcula
                                                                              la función F_INSRECIBO */
               --Obtenemos datos de seguros,agentes,empresas y productos
               BEGIN
                  SELECT s.cagente, s.nanuali, s.nfracci, s.ccobban,
                         DECODE(NVL(a.csoprec, 0), 0, 0, 1),
                         DECODE(a.csoprec, 2, 0, DECODE(s.ccobban, NULL, 1, 4)), s.cforpag,
                         s.cbancar, s.ctipban, s.ncuacoa, s.ctipcoa, s.cempres, e.ctipemp,
                         p.ctippag, p.ccarpen, s.ctipcob, p.ctipreb
                    INTO v_cagente, v_nanuali, v_nfracci, v_ccobban,
                         v_cestsop,
                         v_cestimp, v_cforpag,
                         v_cbancar, v_ctipban, v_ncuacoa, v_ctipcoa, v_cempres, v_ctipemp,
                         v_ctippag, v_ccarpen, v_ctipcob, v_ctipreb
                    FROM agentes a, seguros s, empresas e, productos p
                   WHERE s.sseguro = x.s_sseguro
                     AND a.cagente = s.cagente
                     AND e.cempres = s.cempres
                     AND s.cramo = p.cramo
                     AND s.cmodali = p.cmodali
                     AND s.ctipseg = p.ctipseg
                     AND s.ccolect = p.ccolect;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error:' || SQLCODE || '-' || SQLERRM);
                     v_error := TRUE;
               END;

               p_control_error('rllf','pac_mig_axis.f_migra_recibos','paso 1');

                -- ini rllf 19/05/2016 0041411: POSDM200-POSMA800-Modificaciones a las pólizas migradas de vida individual en producción
               IF (NVL(pac_parametros.f_parempresa_n(v_cempres,'ERPNOENV_RECMIGRADOS'),0) = 1 AND
                   bEntra=1 AND x.cestrec=1) THEN
                p_literal2(108482, 8, ltexto);
                p_literal2(103828, 8, ltexto2);

                select count(*) into vnprocdia from procesoscab where TRUNC(fproini)=trunc(sysdate)
                  and tproces=trim(ltexto) and cproces=trim(ltexto2);
                IF (vnprocdia=0) THEN
                 num_err := f_procesini(f_user,v_cempres,ltexto2,ltexto,vnproces);
                ELSE
                 select sproces into vnproces from procesoscab
                 where trunc(fproini)=trunc(sysdate) and tproces=trim(ltexto) and cproces=trim(ltexto2)
                       and sproces=(select max(sproces) from procesoscab
                                     where trunc(fproini)=trunc(sysdate) and tproces=trim(ltexto) and cproces=trim(ltexto2));
                END IF;
                IF (num_err=0 AND vnproces>0) THEN
                 vnliqmen := f_get_nliqmen(v_cempres, v_cagente, to_date('01/01/1900','dd/mm/yyyy'), vnproces, 0);
                 bEntra:=0;
                ELSE
                 v_error := TRUE;
                END IF;
               END IF;
               -- fin rllf 19/05/2016 0041411: POSDM200-POSMA800-Modificaciones a las pólizas migradas de vida individual en producción

               IF NOT v_error THEN
                  v_recibos := NULL;
----------------
                  v_movrecibo := NULL;

----------------
                  --obtención nrecibo
                  SELECT DECODE(v_ctipreb, 3, 'SI', 'NO')
                    INTO v_colect
                    FROM DUAL;

                  IF x.nrecibo IS NULL THEN
                     num_err := f_nrecibo(v_cempres, v_colect, v_recibos.nrecibo);
                  ELSE
                     v_recibos.nrecibo := x.nrecibo;
                  END IF;

                  IF num_err <> 0 THEN
                     num_err :=
                        f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                            'Error al obtener el número de recibo:' || num_err);
                     v_error := TRUE;
                  END IF;

                  v_recibos.cagente := v_cagente;
                  v_recibos.cempres := v_cempres;
                  v_recibos.nmovimi := x.nmovimi;
                  v_recibos.sseguro := x.s_sseguro;
                  v_recibos.femisio := x.femisio;
                  v_recibos.fefecto := x.fefecto;
                  v_recibos.fvencim := x.fvencim;
                  v_recibos.ctiprec := x.ctiprec;
                  v_recibos.cdelega := f_delega(x.s_sseguro, x.fefecto);
                  v_recibos.creccia := x.creccia;

                  IF v_recibos.cdelega IS NULL THEN
                     v_recibos.cdelega := 1;
                  END IF;

                  v_recibos.ccobban := v_ccobban;

                  --Obtención cestaux
                  IF v_ctipcoa = 8
                     OR v_ctipcoa = 9 THEN
                     v_recibos.cestaux := 1;
                  ELSE
                     v_recibos.cestaux := 0;
                  END IF;

                  IF NVL(v_ctipemp, 0) = 1 THEN   --Es correduria
                     IF x.ctiprec <> 0
                        AND NVL(v_ccarpen, 0) <> 0 THEN
                        v_recibos.cestaux := 1;
                     ELSIF NVL(v_ccarpen, 0) = 2 THEN
                        v_recibos.cestaux := 1;
                     ELSE
                        v_recibos.cestaux := 0;
                     END IF;
                  END IF;

                  --calculamos el nanuali de recibos
                  v_recibos.nanuali := NVL(TRUNC((v_recibos.fefecto - x.s_fefecto) / 365), 0)
                                       + 1;
                  --v_recibos.nanuali := v_nanuali;
                  v_recibos.nfracci := v_nfracci;

                  --Obtenemos el cestimp y cgescob
                  --BUG 12855 - 15-02-2010 - JMC - Si cestimp viene informado se mantiene
                  IF x.cestimp IS NULL THEN
                     v_recibos.cestimp := v_cestimp;
                  ELSE
                     v_recibos.cestimp := x.cestimp;
                  END IF;

                  --FIN BUG 12855 - 15-02-2010 - JMC
                  IF v_ctipcoa = 8 THEN   -- Es un coaseguro aceptado de recibo unico
                     v_recibos.cestimp := 0;   -- No debe imprimirse
                  END IF;

                  IF NVL(v_ctipemp, 0) = 1 THEN   --Es correduria
                     v_recibos.cgescob := 1;

                     IF x.ctiprec = 0
                        AND v_ctippag = 3 THEN   -- NP i gestiona la Cia
                        v_recibos.cestimp := 0;   -- No imprimible
                        v_recibos.cgescob := 2;   -- Gestió de cobrament la cia
                     END IF;

                     IF (x.ctiprec <> 0)
                        AND v_ctippag IN(3, 4) THEN   -- Cobra la cia.
                        v_recibos.cestimp := 0;
                        v_recibos.cgescob := 2;
                     END IF;
                  END IF;

                  --
                  v_recibos.nriesgo := x.nriesgo;
                  v_recibos.cforpag := v_cforpag;
                  v_recibos.cbancar := v_cbancar;
                  v_recibos.nmovanu := NULL;   --NULL
                  v_recibos.cretenc := NULL;   --NULL
                  v_recibos.pretenc := NULL;   --NULL
                  v_recibos.ncuacoa := v_ncuacoa;
                  v_recibos.ctipcoa := v_ctipcoa;
                  v_recibos.cestsop := v_cestsop;

                  --Obtención cmanual y cbancar
                  BEGIN
                     SELECT nvalpar
                       INTO v_cbancob
                       FROM parempresas
                      WHERE cparam = 'CBANCOB'
                        AND cempres = v_cempres;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_cbancob := NULL;
                        v_recibos.cmanual := NULL;
                  END;

                  BEGIN
                     IF v_cbancob IS NOT NULL THEN
                        IF v_cbancob = 1 THEN
                           IF v_ctipcob = 2 THEN
                              SELECT cbancob, cbancar
                                INTO v_recibos.cbancar, v_cbancar
                                FROM seg_cbancar
                               WHERE sseguro = x.s_sseguro
                                 AND nmovimi = x.nmovimi
                                 AND TRUNC(finiefe) <= TRUNC(x.fefecto)
                                 AND NVL(TRUNC(ffinefe), TRUNC(x.fefecto)) >= TRUNC(x.fefecto);

                              IF v_recibos.cbancar IS NOT NULL
                                 AND v_cbancar = '000000000000' THEN
                                 IF x.cestrec = 0 THEN
                                    v_recibos.cestimp := 1;
                                 ELSIF x.cestrec = 1 THEN
                                    v_recibos.cestimp := 2;
                                 ELSE
                                    v_recibos.cestimp := 1;
                                 END IF;
                              --v_recibos.cestimp := 1;
                              END IF;

                              IF v_recibos.cbancar IS NULL THEN
                                 v_recibos.cmanual := 1;
                              ELSE
                                 v_recibos.cmanual := 2;
                              END IF;
                           ELSE
                              IF x.cestrec = 0 THEN
                                 v_recibos.cestimp := 1;
                              ELSIF x.cestrec = 1 THEN
                                 v_recibos.cestimp := 2;
                              ELSE
                                 v_recibos.cestimp := 1;
                              END IF;
                           END IF;
                        ELSE
                           v_recibos.cmanual := 1;
                           v_recibos.cbancar := NULL;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_recibos.cmanual := 1;
                        v_recibos.cbancar := NULL;

                        IF x.cestrec = 0 THEN
                           v_recibos.cestimp := 1;
                        ELSIF x.cestrec = 1 THEN
                           v_recibos.cestimp := 2;
                        ELSE
                           v_recibos.cestimp := 1;
                        END IF;
                  END;

                  -- Obtenemos npreven
                  --  Segons el par instal.lació , utilitzarem el peride de venda segons
                  --  vendes o meritació
                  v_cperven := NVL(f_parinstalacion_n('PERMERITA'), 0);

                  IF v_cperven = 1 THEN
                     v_recibos.nperven := pac_merita.f_permerita(x.ctiprec, x.femisio,
                                                                 x.fefecto, v_cempres);
                  ELSE
                     v_recibos.nperven := f_perventa(NULL, x.femisio, x.fefecto, v_cempres);
                  END IF;

                  --
                  v_recibos.ctransf := NULL;   --NULL
                  v_recibos.festimp := NULL;   --NULL
                  v_recibos.ctipban := v_ctipban;
                  v_recibos.ctipcob := v_ctipcob;
                  v_recibos.esccero := x.esccero;

                  --BUG 13609 - 11-03-2010 - JMC - grabamos campo esccero
                  IF NOT v_error THEN
                     BEGIN
                        INSERT INTO recibos
                             VALUES v_recibos;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, 1, v_recibos.nrecibo);

                        UPDATE mig_recibos
                           SET sseguro = v_recibos.sseguro,
                               nrecibo = v_recibos.nrecibo,
                               cestmig = 2
                         WHERE mig_pk = x.mig_pk;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                          'Error(recibos):' || SQLCODE || '-'
                                                          || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;

                     --BUG 9337 - 26/03/2009 - DCT - Insertar en la tabla movrecibo
                     IF NOT v_tiene_movrec THEN
                        IF x.cestrec = 1
                           AND NOT v_error THEN
                           --2 movimientos uno 0 - 0 y el otro 1 - 0
                           --1er movimiento
                           v_movrecibo.cestrec := 0;
                           v_movrecibo.cestant := 0;
                           v_movrecibo.nrecibo := v_recibos.nrecibo;

                           SELECT smovrec.NEXTVAL
                             INTO v_movrecibo.smovrec
                             FROM DUAL;

                           v_movrecibo.cusuari := f_user;

                           SELECT smovagr.NEXTVAL
                             INTO v_movrecibo.smovagr
                             FROM DUAL;

                           IF k_tipo_carga = 'C' THEN
                              v_movrecibo.fmovini := NVL(x.freccob, x.femisio);
                              v_movrecibo.fmovfin := NVL(x.freccob, x.femisio);
                           ELSE
                              v_movrecibo.fmovini := NVL(x.freccob, x.fefecto);
                              v_movrecibo.fmovfin := NVL(x.freccob, x.fefecto);
                           END IF;

                           --Bug.: 0014867 - 12/07/2010 - ICV
                           v_movrecibo.fcontab :=
                                  TO_DATE('01-01-' || TO_CHAR(x.fefecto, 'yyyy'), 'dd-mm-yyyy');
                           v_movrecibo.fmovdia := x.fefecto;
                           --v_movrecibo.CMOTMOV :=
                           v_movrecibo.cdelega := f_delega(x.s_sseguro, x.fefecto);
                           v_movrecibo.fefeadm :=
                                  TO_DATE('01-01-' || TO_CHAR(x.fefecto, 'yyyy'), 'dd-mm-yyyy');

                           BEGIN
                              INSERT INTO movrecibo
                                   VALUES v_movrecibo;

                              INSERT INTO mig_pk_mig_axis
                                   VALUES (x.mig_pk, pncarga, pntab, 2, v_movrecibo.smovrec);

                              UPDATE mig_recibos
                                 SET cestmig = 3
                               WHERE mig_pk = x.mig_pk;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                                'Error(movrecibo):' || SQLCODE
                                                                || '-' || SQLERRM);
                                 v_error := TRUE;
                                 ROLLBACK;
                           END;

                           --2º movimiento
                           v_movrecibo.cestrec := 1;
                           v_movrecibo.cestant := 0;
                           v_movrecibo.fmovfin := NULL;

                           --Bug.: 0014867 - 12/07/2010 - ICV
                           SELECT smovrec.NEXTVAL
                             INTO v_movrecibo.smovrec
                             FROM DUAL;

                           SELECT smovagr.NEXTVAL
                             INTO v_movrecibo.smovagr
                             FROM DUAL;

                           BEGIN
                              INSERT INTO movrecibo
                                   VALUES v_movrecibo;

                              INSERT INTO mig_pk_mig_axis
                                   VALUES (x.mig_pk, pncarga, pntab, 2, v_movrecibo.smovrec);

                              UPDATE mig_recibos
                                 SET cestmig = 4
                               WHERE mig_pk = x.mig_pk;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 num_err :=
                                    f_ins_mig_logs_axis
                                                 (pncarga, x.mig_pk, 'E',
                                                  SUBSTR('Error(movrecibo):' || SQLERRM
                                                         || CHR(10)
                                                         || DBMS_UTILITY.format_error_backtrace,
                                                         1, 500));
                                 v_error := TRUE;
                                 ROLLBACK;
                           END;
                        ELSIF x.cestrec = 0
                              AND NOT v_error THEN
                           --1 sólo movimiento 0 - 0
                           v_movrecibo.cestrec := 0;
                           v_movrecibo.cestant := 0;
                           v_movrecibo.nrecibo := v_recibos.nrecibo;

                           SELECT smovrec.NEXTVAL
                             INTO v_movrecibo.smovrec
                             FROM DUAL;

                           v_movrecibo.cusuari := f_user;

                           SELECT smovagr.NEXTVAL
                             INTO v_movrecibo.smovagr
                             FROM DUAL;

                           v_movrecibo.fmovini := x.fefecto;
                           -- Bug 16525. FAL. 10-11-2010. Debe generarse movrecibo.fmovfin con valor Nulo
                           --v_movrecibo.fmovfin := x.fefecto;
                           v_movrecibo.fmovfin := NULL;
                           -- Fi Bug 16525
                           v_movrecibo.fcontab :=
                                  TO_DATE('01-01-' || TO_CHAR(x.fefecto, 'yyyy'), 'dd-mm-yyyy');
                           v_movrecibo.fmovdia := x.fefecto;
                           --v_movrecibo.CMOTMOV :=
                           v_movrecibo.cdelega := f_delega(x.s_sseguro, x.fefecto);
                           v_movrecibo.fefeadm :=
                                  TO_DATE('01-01-' || TO_CHAR(x.fefecto, 'yyyy'), 'dd-mm-yyyy');

                           BEGIN
                              INSERT INTO movrecibo
                                   VALUES v_movrecibo;

                              INSERT INTO mig_pk_mig_axis
                                   VALUES (x.mig_pk, pncarga, pntab, 2, v_movrecibo.smovrec);

                              UPDATE mig_recibos
                                 SET cestmig = 3
                               WHERE mig_pk = x.mig_pk;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 num_err :=
                                    f_ins_mig_logs_axis
                                                 (pncarga, x.mig_pk, 'E',
                                                  SUBSTR('Error(movrecibo):' || SQLERRM
                                                         || CHR(10)
                                                         || DBMS_UTILITY.format_error_backtrace,
                                                         1, 500));
                                 v_error := TRUE;
                                 ROLLBACK;
                           END;
                        -- Bug 16525. FAL. 11-11-2010. movimientos de recibo anulado
                        ELSIF x.cestrec = 2
                              AND NOT v_error THEN
                           --2 movimientos uno 0 - 0 y el otro 2 - 0
                           --1er movimiento
                           v_movrecibo.cestrec := 0;
                           v_movrecibo.cestant := 0;
                           v_movrecibo.nrecibo := v_recibos.nrecibo;

                           SELECT smovrec.NEXTVAL
                             INTO v_movrecibo.smovrec
                             FROM DUAL;

                           v_movrecibo.cusuari := f_user;

                           SELECT smovagr.NEXTVAL
                             INTO v_movrecibo.smovagr
                             FROM DUAL;

                           v_movrecibo.fmovini := x.fefecto;
                           v_movrecibo.fmovfin := x.fefecto;
                           --Bug.: 0014867 - 12/07/2010 - ICV
                           v_movrecibo.fcontab :=
                                  TO_DATE('01-01-' || TO_CHAR(x.fefecto, 'yyyy'), 'dd-mm-yyyy');
                           v_movrecibo.fmovdia := x.fefecto;
                           --v_movrecibo.CMOTMOV :=
                           v_movrecibo.cdelega := f_delega(x.s_sseguro, x.fefecto);
                           v_movrecibo.fefeadm :=
                                  TO_DATE('01-01-' || TO_CHAR(x.fefecto, 'yyyy'), 'dd-mm-yyyy');

                           BEGIN
                              INSERT INTO movrecibo
                                   VALUES v_movrecibo;

                              INSERT INTO mig_pk_mig_axis
                                   VALUES (x.mig_pk, pncarga, pntab, 2, v_movrecibo.smovrec);

                              UPDATE mig_recibos
                                 SET cestmig = 3
                               WHERE mig_pk = x.mig_pk;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                                'Error(movrecibo):' || SQLCODE
                                                                || '-' || SQLERRM);
                                 v_error := TRUE;
                                 ROLLBACK;
                           END;

                           --2º movimiento
                           v_movrecibo.cestrec := 2;
                           v_movrecibo.cestant := 0;
                           v_movrecibo.fmovfin := NULL;

                           --Bug.: 0014867 - 12/07/2010 - ICV
                           SELECT smovrec.NEXTVAL
                             INTO v_movrecibo.smovrec
                             FROM DUAL;

                           SELECT smovagr.NEXTVAL
                             INTO v_movrecibo.smovagr
                             FROM DUAL;

                           BEGIN
                              INSERT INTO movrecibo
                                   VALUES v_movrecibo;

                              INSERT INTO mig_pk_mig_axis
                                   VALUES (x.mig_pk, pncarga, pntab, 2, v_movrecibo.smovrec);

                              UPDATE mig_recibos
                                 SET cestmig = 4
                               WHERE mig_pk = x.mig_pk;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 num_err :=
                                    f_ins_mig_logs_axis
                                                 (pncarga, x.mig_pk, 'E',
                                                  SUBSTR('Error(movrecibo):' || SQLERRM
                                                         || CHR(10)
                                                         || DBMS_UTILITY.format_error_backtrace,
                                                         1, 500));
                                 v_error := TRUE;
                                 ROLLBACK;
                           END;
                        -- Fi Bug 16525
                        END IF;
                     END IF;

                     -- INI RLLF 10/05/2016 0042110: POSES800-POS ADM Migración VI Recibos Contabilizados en SAP
                     IF NVL(pac_parametros.f_parempresa_n(v_cempres,'ERPNOENV_RECMIGRADOS'),0) = 1 THEN
                      BEGIN
                       INSERT INTO ESTADO_PROC_RECIBOS (CEMPRES,CTIPOPAGO,NPAGO,NMOV,SPROCES,
                                                        CTIPOMOV,CESTADO,FEC_ALTA,USU_ALTA,FEC_PROCESO,
                                                        USU_PROC,TERROR,SINTERF, SSEGURO)
                       VALUES                           (V_CEMPRES, 4, V_RECIBOS.NRECIBO, v_movrecibo.smovrec, -1,
                                                         1, 1, F_SYSDATE, F_USER, F_SYSDATE,
                                                         F_USER, NULL,-1, V_RECIBOS.SSEGURO);
                      EXCEPTION
                        WHEN OTHERS THEN
                          num_err :=
                         f_ins_mig_logs_axis
                          (pncarga, x.mig_pk, 'E',
                           SUBSTR('Error(estado_proc_recibos):' || SQLERRM
                              || CHR(10)
                              || DBMS_UTILITY.format_error_backtrace,
                              1, 500));
                              v_error := TRUE;
                         ROLLBACK;
                      END;
                      -- INSERTAR EN LAS TABLAS DE COMISIONES COMO SI SE HUBIESE LIQUIDADO YA EL RECIBO COBRADO.
                      IF x.cestrec=1 THEN
                       SELECT NVL(MAX(nliqlin)+1,1) into vnliqlin from liquidalin where cempres=v_cempres and
                         nliqmen=vnliqmen and cagente=v_cagente;
                       BEGIN
                         INSERT INTO liquidalin
                              (cempres, nliqmen, cagente, nliqlin, nrecibo,
                               smovrec, itotimp,
                               itotalr, iprinet,
                               icomisi, iretenccom, isobrecomision,
                               iretencsobrecom, iconvoleducto, iretencoleoducto, ctipoliq,
                               itotimp_moncia,
                               itotalr_moncia,
                               iprinet_moncia,
                               icomisi_moncia,
                               iretenccom_moncia, isobrecom_moncia, iretencscom_moncia,
                               iconvoleod_moncia, iretoleod_moncia,
                               fcambio)
                         VALUES (v_cempres, vnliqmen, v_cagente, vnliqlin, v_recibos.nrecibo,
                               v_movrecibo.smovrec, NULL,
                               NULL, NULL,
                               NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL,
                               NULL, NULL, f_sysdate
                              );
                       EXCEPTION
                       WHEN OTHERS THEN
                        num_err :=
                         f_ins_mig_logs_axis
                          (pncarga, x.mig_pk, 'E',
                           SUBSTR('Error(liquidalin):' || SQLERRM
                              || CHR(10)
                              || DBMS_UTILITY.format_error_backtrace,
                              1, 500));
                              v_error := TRUE;
                              ROLLBACK;
                       END;
                      END IF;

                     END IF;
                     -- FIN RLLF 10/05/2016 0042110: POSES800-POS ADM Migración VI Recibos Contabilizados en SAP
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error:' || SQLCODE || '-' || SQLERRM);
                  v_error := TRUE;
                  ROLLBACK;
            END;

            COMMIT;
         END LOOP;
      END IF;

      IF v_propietario THEN
         num_err := f_trata_trigger('T_FEFEADM', 'ENABLE');

         IF num_err = 99 THEN
            num_err := f_ins_mig_logs_axis(pncarga, 'TRIGGER', 'E',
                                           'Error al habilitar trigger T_FEFEADM ');
            v_error := TRUE;
         END IF;
      END IF;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_error
         OR v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0
         OR v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_recibos;


/***************************************************************************
       FUNCTION f_migra_detrecibos
       Función que trata y traspasa la información de la tabla Intermedia
       MIG_DETRECIBOS (+MIG_SEGUROS), a las tablas de axis: DETRECIBOS Y VDETRECIBOS
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
          return            : 0 si valido, sino codigo error
    ***************************************************************************/
   FUNCTION f_migra_detrecibos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_recibos    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_detrecibos   detrecibos%ROWTYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.nrecibo r_nrecibo
                    FROM mig_detrecibos a, mig_recibos r
                   WHERE r.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_recibos THEN
               v_1_recibos := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'DETRECIBOS');
            END IF;

            v_detrecibos := NULL;
            v_detrecibos.nrecibo := x.r_nrecibo;
            v_detrecibos.cconcep := x.cconcep;
            v_detrecibos.cgarant := x.cgarant;
            v_detrecibos.nriesgo := NVL(x.nriesgo, 1);
            v_detrecibos.iconcep := x.iconcep;
            v_detrecibos.cageven := NULL;
            v_detrecibos.nmovima := x.nmovima;
            v_detrecibos.iconcep_monpol := x.iconcep_monpol;
            v_detrecibos.fcambio := x.fcambio;

            INSERT INTO detrecibos
                 VALUES v_detrecibos;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_detrecibos.nrecibo || '|' || v_detrecibos.cconcep || '|'
                         || v_detrecibos.cgarant || '|' || v_detrecibos.nriesgo);

            UPDATE mig_detrecibos
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      /*
      --BUG 9337 - 26/03/2009 - DCT - Insertar ebn la tabla vdetrecibos
      FOR x IN (SELECT DISTINCT nrecibo
                           FROM mig_recibos
                          WHERE ncarga = pncarga) LOOP
         BEGIN
            num_err := f_vdetrecibos('R', x.nrecibo);
            IF num_err <> 0 THEN
               v_error := TRUE;
               ROLLBACK;
            END IF;
         END;
      END LOOP;
      */
      FOR x IN (SELECT DISTINCT r.nrecibo, r.mig_pk, r.ctiprec
                           FROM mig_detrecibos d, mig_recibos r
                          WHERE r.mig_pk = d.mig_fk
                            AND d.ncarga = pncarga
                            AND d.cestmig = 2
                       ORDER BY r.ctiprec) LOOP
         BEGIN
            num_err := f_vdetrecibos('R', x.nrecibo);

            IF num_err <> 0 THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error: f_vdetrecibos' || num_err || '-'
                                              || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
            ELSE
               UPDATE mig_detrecibos d
                  SET cestmig = 3
                WHERE ncarga = pncarga
                  AND mig_fk = x.mig_pk;

               COMMIT;
            END IF;
         END;
      END LOOP;

---------------------------------------------
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_detrecibos;

-- BUG 8402 - 15-05-2009 - JMC - Se añade función para la migración de la tabla MOVRECIBO
/***************************************************************************
      FUNCTION f_migra_movrecibo
      Función que inserta los registros grabados en MIG_MOVRECIBO, en la tabla
      movrecibo de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_movrecibo(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_recibos    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_movrecibo    movrecibo%ROWTYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.nrecibo r_nrecibo, r.fefecto, s.sseguro s_sseguro
                    FROM mig_movrecibo a, mig_recibos r, mig_seguros s
                   WHERE r.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND s.mig_pk = r.mig_fk
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_recibos THEN
               v_1_recibos := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'MOVRECIBO');
            END IF;

            v_movrecibo := NULL;
            v_movrecibo.cestrec := x.cestrec;
            v_movrecibo.cestant := 0;
            v_movrecibo.nrecibo := x.r_nrecibo;

            SELECT smovrec.NEXTVAL
              INTO v_movrecibo.smovrec
              FROM DUAL;

            v_movrecibo.cusuari := f_user;

            SELECT smovagr.NEXTVAL
              INTO v_movrecibo.smovagr
              FROM DUAL;

            v_movrecibo.fmovini := x.fmovini;
            v_movrecibo.fmovfin := x.fmovfin;
            v_movrecibo.fmovdia := x.fmovdia;
            v_movrecibo.fefeadm := x.fefeadm;
            v_movrecibo.fcontab := x.fefeadm;
            v_movrecibo.cdelega := f_delega(x.s_sseguro, x.fefecto);
            v_movrecibo.cmotmov := x.cmotmov;

            INSERT INTO movrecibo
                 VALUES v_movrecibo;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_movrecibo.smovrec);

            UPDATE mig_movrecibo
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_movrecibo;

-- BUG 8402 - 15-05-2009 - JMC
/***************************************************************************
      FUNCTION f_migra_agensegu
      Función que inserta los registros grabados en MIG_AGENSEGU, en la tabla
      agensegu de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_agensegu(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_agensegu   BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_agensegu     agensegu%ROWTYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.sseguro s_sseguro
                    FROM mig_agensegu a, mig_seguros r
                   WHERE r.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_agensegu THEN
               v_1_agensegu := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'AGENSEGU');
            END IF;

            v_agensegu := NULL;
            v_agensegu.sseguro := x.s_sseguro;
            --Ini Bug 0012557 - 14-01-2009 - JMC - Se modifica estructura de mig_agensegu
            v_agensegu.falta := x.falta;
            v_agensegu.ctipreg := x.ctipreg;
            v_agensegu.cestado := x.cestado;
            v_agensegu.ttitulo := x.ttitulo;
            v_agensegu.ffinali := x.ffinali;
            v_agensegu.ttextos := x.ttextos;
            v_agensegu.cmanual := x.cmanual;
            v_agensegu.ctipreg := x.ctipreg;

            SELECT NVL(MAX(nlinea), 0) + 1
              INTO v_agensegu.nlinea
              FROM agensegu
             WHERE sseguro = x.s_sseguro;

            --Fin Bug 0012557 - 14-01-2009 - JMC
            INSERT INTO agensegu
                 VALUES v_agensegu;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_agensegu.sseguro || '|' || v_agensegu.nlinea);

            UPDATE mig_agensegu
               SET cestmig = 2,
                   sseguro = x.s_sseguro
             --Bug 0012557 - 14-01-2009 - JMC - Se actualiza sseguro
            WHERE  mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_agensegu;

--BUG:11115 - 30-09-2009 - JMC - Migración tabla SEGUROS_ULK y SEGDISIN2
/***************************************************************************
      FUNCTION f_migra_seguros_ulk
      Función que inserta los registros grabados en MIG_SEGUROS_ULK, en las
      tablas SEGUROS_ULK.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_seguros_ulk(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_seg_ren    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_seguros_ulk  seguros_ulk%ROWTYPE;
      v_segdisin2    segdisin2%ROWTYPE;
      v_cont         NUMBER := 0;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_migra        NUMBER := 0;
      v_migra_segdisin NUMBER := 0;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      --Tratamos cada una de las polizas.
      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_seguros_ulk a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         IF v_1_seg_ren THEN
            v_1_seg_ren := FALSE;
            num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SEGUROS_ULK');
            num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 2, 'SEGDISIN2');
         END IF;

         v_error := FALSE;
         v_seguros_ulk := NULL;
         v_seguros_ulk.sseguro := x.s_sseguro;
         v_seguros_ulk.cmodinv := x.cmodinv;

         BEGIN
            -- 23289/120321 - ECP- 04/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estseguros_ulk
                    VALUES v_seguros_ulk;
            ELSIF ptablas = 'POL' THEN
               INSERT INTO seguros_ulk
                    VALUES v_seguros_ulk;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012  Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_seguros_ulk.sseguro);

            UPDATE mig_seguros_ulk
               SET cestmig = 3
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error al insertar(seguros_finv):' || SQLCODE
                                              || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;

         -- BUG 34776 - 22-10-2015 - ETM - Función para la migración de MIG_CTASEGURO_SHADOW y SEGDISIN2
         SELECT COUNT(*)
           INTO v_migra_segdisin
           FROM mig_segdisin2
          WHERE ncarga = pncarga
            AND cestmig = 1;

         --FIN  BUG 34776 - 22-10-2015 - ETM - Función para la migración de MIG_CTASEGURO_SHADOW y SEGDISIN2
         IF NOT v_error THEN
            IF v_migra_segdisin = 0 THEN
               BEGIN
                  v_segdisin2 := NULL;

                  -- 23289/120321 - ECP- 04/09/2012 Inicio
                  IF ptablas = 'EST' THEN
                     SELECT s.sseguro,
                            1,
                            m.nmovimi,
                            m.fefecto finicio,
                            NULL ffin,
                            mf.ccodfon,
                            mf.pinvers pdistrec,
                            NULL pdistuni,
                            NULL pdistext,
                            NULL cmodabo
                       INTO v_segdisin2
                       FROM estseguros_ulk s, movseguro m, modinvfondo mf, estseguros seg
                      WHERE s.sseguro = x.s_sseguro
                        AND seg.sseguro = s.sseguro
                        AND mf.cramo = seg.cramo
                        AND mf.cmodali = seg.cmodali
                        AND mf.ctipseg = seg.ctipseg
                        AND mf.ccolect = seg.ccolect
                        AND s.sseguro = m.sseguro
                        AND m.nmovimi = (SELECT MAX(nmovimi)
                                           FROM movseguro m2
                                          WHERE m2.sseguro = s.sseguro)
                        AND s.cmodinv = mf.cmodinv;
                  ELSE
                     SELECT s.sseguro,
                            1,
                            m.nmovimi,
                            m.fefecto finicio,
                            NULL ffin,
                            mf.ccodfon,
                            mf.pinvers pdistrec,
                            NULL pdistuni,
                            NULL pdistext,
                            NULL cmodabo
                       INTO v_segdisin2
                       FROM seguros_ulk s, movseguro m, modinvfondo mf, seguros seg
                      WHERE s.sseguro = x.s_sseguro
                        AND seg.sseguro = s.sseguro
                        AND mf.cramo = seg.cramo
                        AND mf.cmodali = seg.cmodali
                        AND mf.ctipseg = seg.ctipseg
                        AND mf.ccolect = seg.ccolect
                        AND s.sseguro = m.sseguro
                        AND m.nmovimi = (SELECT MAX(nmovimi)
                                           FROM movseguro m2
                                          WHERE m2.sseguro = s.sseguro)
                        AND s.cmodinv = mf.cmodinv;
                  END IF;
               -- 23289/120321 - ECP- 04/09/2012 Fin
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error al obtener datos segdisin2:'
                                                    || SQLCODE || '-' || SQLERRM);
                     v_error := TRUE;
               END;

               IF NOT v_error THEN
                  BEGIN
                     -- 23289/120321 - ECP- 04/09/2012 Inicio
                     IF ptablas = 'EST' THEN
                        INSERT INTO estsegdisin2
                             VALUES v_segdisin2;
                     ELSE
                        INSERT INTO segdisin2
                             VALUES v_segdisin2;
                     END IF;

                     -- 23289/120321 - ECP- 04/09/2012 Fin
                     INSERT INTO mig_pk_mig_axis
                          VALUES (x.mig_pk, pncarga, pntab, 2,
                                  v_segdisin2.sseguro || '|' || v_segdisin2.nriesgo || '|'
                                  || v_segdisin2.nmovimi || '|' || v_segdisin2.ccesta);

                     UPDATE mig_seguros_ulk
                        SET cestmig = 4
                      WHERE mig_pk = x.mig_pk;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                       'Error al insertar(segdisin2):'
                                                       || SQLCODE || '-' || SQLERRM);
                        v_error := TRUE;
                        ROLLBACK;
                  END;
               END IF;
            ELSE
               v_migra := pac_mig_axis.f_migra_segdisin2(pncarga, pntab, ptablas);
            END IF;
         END IF;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_seguros_ulk;

--etm ini
   -- BUG 34776/216124 - 22-10-2015 - ETM - Función para la migración de MIG_CTASEGURO_SHADOW y SEGDISIN2
   /***************************************************************************
        FUNCTION f_migra_segdisin2
        Función que inserta los registros grabados en MIG_SEGDISIN2, en la
        tabla segdisin2 de AXIS.
           param in  pncarga:     Número de carga.
           param in  pntab:       Número de tabla.
           param in  ptablas      EST Simulaciones, POL Pólizas
           return:                0-OK, <>0-Error
     ***************************************************************************/
   FUNCTION f_migra_segdisin2(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_seg_ren    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_seguros_ulk  seguros_ulk%ROWTYPE;
      v_segdisin2    segdisin2%ROWTYPE;
      v_cont         NUMBER := 0;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      --Tratamos cada una de las polizas.
      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, m.nmovimi m_nmovimi,
                         NVL(a.finicio, m.fefecto) m_fefecto
                    FROM mig_segdisin2 a, mig_seguros s, mig_movseguro m
                   WHERE m.mig_fk = s.mig_pk
                     AND s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         IF v_1_seg_ren THEN
            v_1_seg_ren := FALSE;
            num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SEGDISIN2');
         END IF;

         v_error := FALSE;
         v_segdisin2 := NULL;
         v_segdisin2.sseguro := x.s_sseguro;
         v_segdisin2.nriesgo := NVL(x.nriesgo, 1);
         v_segdisin2.nmovimi := x.m_nmovimi;
         v_segdisin2.finicio := x.m_fefecto;
         v_segdisin2.ffin := x.ffin;
         v_segdisin2.ccesta := x.ccesta;
         v_segdisin2.pdistrec := x.pdistrec;
         v_segdisin2.pdistuni := x.pdistuni;
         v_segdisin2.pdistext := x.pdistext;
         v_segdisin2.cmodabo := x.cmodabo;

         BEGIN
            -- 23289/120321 - ECP- 04/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estsegdisin2
                    VALUES v_segdisin2;
            ELSIF ptablas = 'POL' THEN
               INSERT INTO segdisin2
                    VALUES v_segdisin2;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_segdisin2.sseguro || '|' || v_segdisin2.nriesgo || '|'
                         || v_segdisin2.nmovimi || '|' || v_segdisin2.ccesta);

            UPDATE mig_segdisin2
               SET cestmig = 3
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error al insertar(segdisin2):' || SQLCODE
                                              || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_segdisin2;

 -- FIN BUG 34776/216124 - 22-10-2015 - ETM - Función para la migración de MIG_CTASEGURO_SHADOW y SEGDISIN2
/***************************************************************************
      FUNCTION f_migra_tabvalces
      Función que inserta los registros grabados en MIG_TABVALCES, en las
      tablas TABVALCES.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_tabvalces(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_tabvalces  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_tabvalces    tabvalces%ROWTYPE;
      v_cont         NUMBER := 0;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      --Tratamos cada una de las polizas.
      FOR x IN (SELECT   a.*
                    FROM mig_tabvalces a
                   WHERE a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         IF v_1_tabvalces THEN
            v_1_tabvalces := FALSE;
            num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'TABVALCES');
         END IF;

         v_error := FALSE;
         v_tabvalces := NULL;
         v_tabvalces.ccesta := x.ccesta;
         v_tabvalces.fvalor := x.fvalor;
         v_tabvalces.nparact := x.nparact;
         v_tabvalces.iuniact := x.iuniact;
         v_tabvalces.ivalact := x.ivalact;
         v_tabvalces.nparasi := x.nparasi;
         v_tabvalces.igastos := x.igastos;

         BEGIN
            INSERT INTO tabvalces
                 VALUES v_tabvalces;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_tabvalces.ccesta || '|' || v_tabvalces.fvalor);

            UPDATE mig_tabvalces
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error al insertar(tabvalces):' || SQLCODE
                                              || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_tabvalces;

--FIN BUG:11115 - 30-09-2009 - JMC
--INI BUG:12374 - 21-12-2009 - JMC --Creación función f_migra_prestamoseg
/***************************************************************************
      FUNCTION f_migra_prestamoseg
      Función que inserta los registros grabados en MIG_PRESTAMOSEG, en la tabla
      PRESTAMOSEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_prestamoseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_prestamoseg BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_prestamoseg  prestamoseg%ROWTYPE;
      v_ntabaxis     NUMBER := 3;
      v_ntabaxisseg  NUMBER := 3;
      v_ntabaxispol  NUMBER := 3;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_prestamoseg a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_prestamoseg THEN
               v_1_prestamoseg := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'PRESTAMOSEG');
            END IF;

            v_error := FALSE;
            v_prestamoseg := NULL;
            v_prestamoseg.ctapres := x.ctapres;
            v_prestamoseg.sseguro := x.s_sseguro;
            v_prestamoseg.nmovimi := x.nmovimi;
            v_prestamoseg.nriesgo := x.nriesgo;
            v_prestamoseg.isaldo := x.isaldo;
            v_prestamoseg.descripcion := x.descripcion;

            -- 23289/120321 - ECP- 04/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estprestamoseg
                    VALUES v_prestamoseg;
            ELSE
               INSERT INTO prestamoseg
                    VALUES v_prestamoseg;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, v_ntabaxisseg,
                         v_prestamoseg.ctapres || '|' || v_prestamoseg.sseguro || '|'
                         || v_prestamoseg.nmovimi || '|' || v_prestamoseg.nriesgo);

            UPDATE mig_prestamoseg
               SET sseguro = v_prestamoseg.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_prestamoseg;

--FIN BUG:12374 - 21-12-2009 - JMC
--INI BUG:12374 - 22-12-2009 - JMC - Migración nuevo modelo siniestros.
/***************************************************************************
      FUNCTION f_migra_sin_siniestro
      Función que inserta los registros grabados en MIG_SIN_SINIESTRO, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_siniestro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL',
      pboldaxis IN BOOLEAN DEFAULT FALSE)
      RETURN NUMBER IS
      v_1_siniestro  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_siniestro    sin_siniestro%ROWTYPE;
      v_cont         NUMBER;
      v_seg          seguros%ROWTYPE;
      --AFM 28/09/10-vvv- Bug 0014954: migrar de OLDAXIS a NEWAXIS -vvv-
      v_query        VARCHAR2(1000)
         := 'SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_sin_siniestro a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = '
            || pncarga || 'AND a.cestmig = 1
                  ORDER BY a.mig_pk';
      v_qoldaxis     VARCHAR2(1000)
         := 'SELECT   a.*, a.sseguro s_sseguro
                    FROM mig_sin_siniestro a
                   WHERE a.ncarga = '
            || pncarga || 'AND a.cestmig = 1
                  ORDER BY a.mig_pk';

      CURSOR c_row IS
         SELECT   a.*, s.sseguro s_sseguro
             FROM mig_sin_siniestro a, mig_seguros s
            WHERE s.mig_pk = a.mig_fk
              AND a.ncarga = pncarga
              AND a.cestmig = 1
         ORDER BY a.mig_pk;

      x              c_row%ROWTYPE;

      TYPE cursor_type IS REF CURSOR;

      c_query        cursor_type;
--AFM 28/09/10-^^^- Bug 0014954: migrar de OLDAXIS a NEWAXIS -^^^-
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF pboldaxis THEN
         v_query := v_qoldaxis;
      END IF;

      /*   --AFM 28/09/10-vvv- Bug 0014954: migrar de OLDAXIS a NEWAXIS -vvv-
              FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                          FROM mig_sin_siniestro a, mig_seguros s
                         WHERE s.mig_pk = a.mig_fk
                           AND a.ncarga = pncarga
                           AND a.cestmig = 1
                        ORDER BY a.mig_pk)
      */
      OPEN c_query FOR v_query;

      LOOP
         FETCH c_query
          INTO x;

         EXIT WHEN c_query%NOTFOUND;

         BEGIN
            IF v_1_siniestro THEN
               v_1_siniestro := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SIN_SINIESTRO');
            END IF;

            v_error := FALSE;
            v_siniestro := NULL;

            IF NOT pboldaxis THEN
               --Obtención número siniestro
               BEGIN
                  SELECT *
                    INTO v_seg
                    FROM seguros seg
                   WHERE seg.sseguro = x.s_sseguro;

                  -- BUG 17367 - 26/01/2011 - JMP - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del número de siniestro
                  /*IF NVL(f_parinstalacion_n('CONTSINIES'), 0) = 1 THEN
                                    -- 'Contador de siniestros y rescates diferentes?' = 1 (Sí)
                     v_siniestro.nsinies :=
                        pac_siniestros.ff_contador_siniestros(v_seg.cramo, v_seg.cmodali,
                                                              x.ccausin);
                  ELSE
                     v_siniestro.nsinies := f_contador('01', v_seg.cramo);
                  END IF;
                  */
                  v_siniestro.nsinies := pac_propio.f_contador2(v_seg.cempres, '01',

--                                                                v_seg.cramo);
                                                                v_seg.cramo, x.s_sseguro);
               -- 210032:ASN:23/01/2012
               -- FIN BUG 17367 - 26/01/2011 - JMP
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error:' || SQLERRM || CHR(10)
                                                    || DBMS_UTILITY.format_error_backtrace);
                     v_error := TRUE;
               END;
            ELSE
               v_siniestro.nsinies := x.nsinies;
            END IF;

            v_siniestro.sseguro := x.s_sseguro;

            IF NOT pboldaxis THEN
               IF x.nriesgo = 0 THEN
                  --Obtención número riesgo
                  FOR y IN (SELECT   *
                                FROM mig_riesgos
                               WHERE mig_fk2 = x.mig_fk
                            ORDER BY nriesgo) LOOP
                     v_siniestro.nriesgo := y.nriesgo;
                     EXIT;
                  END LOOP;
               ELSE
                  v_siniestro.nriesgo := x.nriesgo;
               END IF;
            ELSE
               v_siniestro.nriesgo := x.nriesgo;
            END IF;

            IF x.nmovimi = 0 THEN
               SELECT MAX(nmovimi)
                 INTO v_siniestro.nmovimi
                 FROM movseguro
                WHERE sseguro = x.s_sseguro
                  AND cmovseg <> 3;
            ELSE
               v_siniestro.nmovimi := x.nmovimi;
            END IF;

            ------
            v_siniestro.fsinies := x.fsinies;
            v_siniestro.fnotifi := x.fnotifi;
            v_siniestro.ccausin := x.ccausin;
            v_siniestro.cmotsin := x.cmotsin;
            v_siniestro.cevento := x.cevento;
            v_siniestro.cculpab := x.cculpab;
            v_siniestro.creclama := x.creclama;
            v_siniestro.nasegur := x.nasegur;
            v_siniestro.cmeddec := x.cmeddec;
            v_siniestro.ctipdec := x.ctipdec;
            v_siniestro.tnomdec := x.tnomdec;
            v_siniestro.tape1dec := x.tape1dec;
            v_siniestro.tape2dec := x.tape2dec;
            v_siniestro.tteldec := x.tteldec;
            v_siniestro.tsinies := x.tsinies;
            v_siniestro.cusualt := x.cusualt;
            v_siniestro.falta := x.falta;
            v_siniestro.tape2dec := x.tape2dec;
            v_siniestro.cusumod := x.cusumod;
            v_siniestro.fmodifi := x.fmodifi;
            v_siniestro.ncuacoa := x.ncuacoa;
            v_siniestro.nsincoa := x.nsincoa;
            v_siniestro.nsincia := x.csincia;
            -- ini BUG 0028909 - 21-10-2013 - JMF
            v_siniestro.ctipide := x.ctipide;
            v_siniestro.nnumide := x.nnumide;
            v_siniestro.tnom2dec := x.tnom2dec;
            v_siniestro.tnom1dec := x.tnom1dec;
            v_siniestro.temaildec := x.temaildec;
            v_siniestro.cagente := x.cagente;
            v_siniestro.ccarpeta := x.ccarpeta;

            -- fin BUG 0028909 - 21-10-2013 - JMF
            IF pboldaxis THEN
               --AFM solo para identificar que es un row migrado (esta col no se usa)
               v_siniestro.fechapp := f_sysdate;
            END IF;

            ------
            INSERT INTO sin_siniestro
                 VALUES v_siniestro;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_siniestro.nsinies);

            UPDATE mig_sin_siniestro
               SET sseguro = v_siniestro.sseguro,
                   nriesgo = v_siniestro.nriesgo,
                   nmovimi = v_siniestro.nmovimi,
                   nsinies = v_siniestro.nsinies,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      CLOSE c_query;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_siniestro;

/***************************************************************************
      FUNCTION f_migra_sin_movsiniestro
      Función que inserta los registros grabados en MIG_SIN_MOVSINIESTRO, en la tabla
      SIN_MOVSINIESTRO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_movsiniestro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_movsin     BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_movsin       sin_movsiniestro%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies
                    FROM mig_sin_movsiniestro a, mig_sin_siniestro s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_movsin THEN
               v_1_movsin := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SIN_MOVSINIESTRO');
            END IF;

            v_error := FALSE;
            v_movsin := NULL;
            v_movsin.nsinies := x.s_nsinies;

            IF NVL(x.nmovsin, -1) <> -1 THEN
               v_movsin.nmovsin := x.nmovsin;
            ELSE
               SELECT NVL(MAX(nmovsin), 0) + 1
                 INTO v_movsin.nmovsin
                 FROM sin_movsiniestro
                WHERE nsinies = x.s_nsinies;
            END IF;

            v_movsin.cestsin := x.cestsin;
            v_movsin.festsin := x.festsin;
            v_movsin.ccauest := x.ccauest;
            v_movsin.cunitra := x.cunitra;
            v_movsin.ctramitad := x.ctramitad;
            v_movsin.cusualt := x.cusualt;
            v_movsin.falta := x.falta;

            ------
            INSERT INTO sin_movsiniestro
                 VALUES v_movsin;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_movsin.nsinies || '|' || v_movsin.nmovsin);

            UPDATE mig_sin_movsiniestro
               SET nsinies = v_movsin.nsinies,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_movsiniestro;

/***************************************************************************
      FUNCTION f_migra_sin_SINIESTRO_REFERENCIAS
      Función que inserta los registros grabados en MIG_sin_SINIESTRO_REFERENCIAS, en la tabla
      SIN_TRAMITACION de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_siniestro_referenc(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_siniestro_referencias%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies
                    FROM mig_sin_siniestro_referencias a, mig_sin_siniestro s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1,
                                                    'SIN_SINIESTRO_REFERENCIAS');
            END IF;

            v_error := FALSE;
            v_trami := NULL;

            SELECT srefext.NEXTVAL + 1   -- esta asi en pac_iax_siniestros
              INTO v_trami.srefext
              FROM DUAL;

            -- v_trami.SREFEXT := x.SREFEXT;
            v_trami.nsinies := x.s_nsinies;
            v_trami.ctipref := x.ctipref;
            v_trami.trefext := x.trefext;
            v_trami.frefini := x.frefini;
            v_trami.freffin := x.freffin;
            v_trami.cusualt := x.cusualt;
            v_trami.falta := x.falta;
            v_trami.cusumod := x.cusumod;
            v_trami.fmodifi := x.fmodifi;

            ------
            IF NOT v_error THEN
               INSERT INTO sin_siniestro_referencias
                    VALUES v_trami;

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 1, v_trami.srefext);

               UPDATE mig_sin_siniestro_referencias
                  SET nsinies = v_trami.nsinies,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
               EXIT;
         END;
      --COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_siniestro_referenc;

/***************************************************************************
      FUNCTION f_migra_sin_tramitacion
      Función que inserta los registros grabados en MIG_SIN_TRAMITACION, en la tabla
      SIN_TRAMITACION de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramitacion(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_tramitacion%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies
                    FROM mig_sin_tramitacion a, mig_sin_siniestro s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SIN_TRAMITACION');
            END IF;

            v_error := FALSE;
            v_trami := NULL;
            v_trami.nsinies := x.s_nsinies;
            v_trami.ntramit := x.ntramit;
            v_trami.ctramit := x.ctramit;

            IF x.ctcausin IS NULL THEN
               BEGIN
                  SELECT ctcausin
                    INTO v_trami.ctcausin
                    FROM sin_codtramitacion
                   WHERE ctramit = x.ctramit;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                    'Error al obtener ctcausin:' || SQLCODE
                                                    || '-' || SQLERRM);
                     v_error := TRUE;
               END;
            ELSE
               v_trami.ctcausin := x.ctcausin;
            END IF;

            v_trami.cinform := x.cinform;
            v_trami.cusualt := x.cusualt;
            v_trami.falta := x.falta;
            v_trami.cusumod := x.cusumod;
            v_trami.fmodifi := x.fmodifi;

            ------
            IF NOT v_error THEN
               INSERT INTO sin_tramitacion
                    VALUES v_trami;

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 1,
                            v_trami.nsinies || '|' || v_trami.ntramit);

               UPDATE mig_sin_tramitacion
                  SET nsinies = v_trami.nsinies,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;
            END IF;

            IF x.fformalizacion IS NOT NULL THEN
               INSERT INTO sin_tramita_documento
                           (nsinies, ntramit, ndocume, cdocume, frecibe,
                            freclama, cobliga, cusualt, falta,
                            cusumod, fmodifi, corigen)
                    VALUES (v_trami.nsinies, v_trami.ntramit, 1, 521, x.fformalizacion,
                            x.fformalizacion, 0, v_trami.cusualt, v_trami.falta,
                            v_trami.cusumod, v_trami.fmodifi, 0);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_tramitacion;

/***************************************************************************
      FUNCTION f_migra_sin_tramita_movimiento
      Función que inserta los registros grabados en MIG_SIN_TRAMITA_MOVIMIENTO, en la tabla
      SIN_TRAMITA_MOVIMIENTO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramita_movimiento(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_tramita_movimiento%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies
                    FROM mig_sin_tramita_movimiento a, mig_sin_tramitacion s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1,
                                                    'SIN_TRAMITA_MOVIMIENTO');
            END IF;

            v_error := FALSE;
            v_trami := NULL;
            v_trami.nsinies := x.s_nsinies;
            v_trami.ntramit := x.ntramit;
            v_trami.nmovtra := x.nmovtra;
            v_trami.cunitra := x.cunitra;
            v_trami.ctramitad := x.ctramitad;
            v_trami.cesttra := x.cesttra;
            v_trami.csubtra := x.csubtra;
            v_trami.festtra := x.festtra;
            v_trami.cusualt := x.cusualt;
            v_trami.falta := x.falta;
            v_trami.ccauest := x.ccauest;

            ------
            INSERT INTO sin_tramita_movimiento
                 VALUES v_trami;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_trami.nsinies || '|' || v_trami.ntramit || '|' || v_trami.nmovtra);

            UPDATE mig_sin_tramita_movimiento
               SET nsinies = v_trami.nsinies,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_tramita_movimiento;

/***************************************************************************
       FUNCTION f_migra_sin_tramita_agenda
       Función que inserta los registros grabados en MIG_SIN_TRAMITA_AGENDA, en la tabla
       sin_tramita_agenda de AXIS.
          param in  pncarga:     Número de carga.
          param in  pntab:       Número de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_agenda(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_tramita_agenda%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies
                    FROM mig_sin_tramita_agenda a, mig_sin_tramitacion s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SIN_TRAMITA_AGENDA');
            END IF;

            v_error := FALSE;
            v_trami := NULL;
            v_trami.nsinies := x.s_nsinies;
            v_trami.ntramit := x.ntramit;
            v_trami.nlinage := x.nmovage;
            v_trami.ctipreg := x.ctipreg;
            v_trami.cmanual := NVL(NULL, 0);   --código registro manual???;
            v_trami.cestage := x.cestado;
            v_trami.ffinage := x.ffinali;
            v_trami.ttitage := SUBSTR(x.tagenda, 1, 100);   --???
            v_trami.tlinage := SUBSTR(x.tagenda, 1, 2000);
            --perdemos texto: origen de 4000
            v_trami.cusualt := x.cusuari;
            v_trami.falta := x.fapunte;
            v_trami.cusumod := NULL;
            v_trami.fmodifi := NULL;

            ------
            INSERT INTO sin_tramita_agenda
                 VALUES v_trami;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_trami.nsinies || '|' || v_trami.ntramit || '|' || v_trami.nlinage);

            UPDATE mig_sin_tramita_agenda
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_tramita_agenda;

/***************************************************************************
       FUNCTION f_migra_sin_tramita_dest
       Función que inserta los registros grabados en MIG_SIN_TRAMITA_DEST, en la tabla
       sin_tramita_destinatario de AXIS.
          param in  pncarga:     Número de carga.
          param in  pntab:       Número de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_dest(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_tramita_destinatario%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies
                    FROM mig_sin_tramita_dest a, mig_sin_tramitacion s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1,
                                                    'SIN_TRAMITA_DESTINATARIO');
            END IF;

            v_error := FALSE;
            v_trami := NULL;
            v_trami.nsinies := x.s_nsinies;
            v_trami.ntramit := x.ntramit;
            v_trami.sperson := x.sperson;
            v_trami.ctipdes := x.ctipdes;
            v_trami.ctipban := x.ctipban;
            v_trami.cbancar := x.cbancar;
            v_trami.cpagdes := x.cpagdes;
            v_trami.cactpro := x.cactpro;
            v_trami.pasigna := x.pasigna;
            v_trami.cpaisre := x.cpaisre;
            v_trami.cactpro := x.cactpro;
            v_trami.cusualt := x.cusualt;
            v_trami.falta := x.falta;
            v_trami.cusumod := x.cusumod;
            v_trami.fmodifi := x.fmodifi;
            v_trami.ctipcap := x.ctipcap;
            -- BUG 0028909 - 21-10-2013 - JMF
            v_trami.crelase := x.crelase;

            ------
            INSERT INTO sin_tramita_destinatario
                 VALUES v_trami;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_trami.nsinies || '|' || v_trami.ntramit || '|' || v_trami.sperson
                         || '|' || v_trami.ctipdes);

            UPDATE mig_sin_tramita_dest
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN   -- si ya esta el destinatario se da el registro por bueno
               --
               UPDATE mig_sin_tramita_dest
                  SET cestmig = 2
                WHERE mig_pk = x.mig_pk;
            --
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_tramita_dest;

/***************************************************************************
       FUNCTION f_migra_sin_tramita_personasrel
       Función que inserta los registros grabados en MIG_SIN_TRAMITA_PERSONASREL, en la tabla
       sin_tramita_destinatario de AXIS.
          param in  pncarga:     Número de carga.
          param in  pntab:       Número de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_personasre(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_tramita_personasrel%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies
                    FROM mig_sin_tramita_personasrel a, mig_sin_tramitacion s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1,
                                                    'MIG_SIN_TRAMITA_PERSONASREL');
            END IF;

            v_error := FALSE;
            v_trami := NULL;
            v_trami.nsinies := x.s_nsinies;
            v_trami.ntramit := x.ntramit;

            BEGIN
               --SELECT MAX(npersrel) + 1
               SELECT NVL(MAX(npersrel) + 1, 1)
                 INTO v_trami.npersrel
                 FROM sin_tramita_personasrel
                WHERE nsinies = v_trami.nsinies
                  AND ntramit = v_trami.ntramit;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_trami.npersrel := 1;
               WHEN OTHERS THEN
                  v_trami.npersrel := 1;
            END;

            -- v_trami.NPERSREL := x.NPERSREL ;
            v_trami.ctipide := x.ctipide;
            v_trami.nnumide := x.nnumide;
            v_trami.tnombre := x.tnombre;
            v_trami.tapelli1 := x.tapelli1;
            v_trami.tapelli2 := x.tapelli2;
            v_trami.ttelefon := x.ttelefon;
            v_trami.sperson := x.sperson;
            v_trami.tdesc := x.tdesc;
            v_trami.tnombre2 := x.tnombre2;
            v_trami.temail := x.temail;
            v_trami.tmovil := x.tmovil;
            v_trami.ctiprel := x.ctiprel;

            ------
            INSERT INTO sin_tramita_personasrel
                 VALUES v_trami;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_trami.nsinies || '|' || v_trami.ntramit || '|' || v_trami.npersrel);

            UPDATE mig_sin_tramita_personasrel
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
               EXIT;
         END;
      --COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_tramita_personasre;

/***************************************************************************
      FUNCTION f_migra_sin_tramita_reserva
      Función que inserta los registros grabados en MIG_SIN_TRAMITA_RESERVA, en la tabla
      SIN_TRAMITA_RESERVA de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramita_reserva(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_tramita_reserva%ROWTYPE;
      v_cont         NUMBER;
      venviocontabonline NUMBER(1);
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF ptablas = 'MIG' THEN
         venviocontabonline := 1;
      ELSE
         venviocontabonline := 0;
      END IF;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies, s.fsinies fsinies, s.sseguro sseguro,
                         s.nriesgo nriesgo, t.ctramit ctramit, s.ccausin ccausin,
                         s.cmotsin cmotsin, s.fnotifi fnotifi, seg.sproduc sproduc,
                         NVL(seg.cactivi, 0) cactivi
                    FROM mig_sin_tramita_reserva a, mig_sin_tramitacion t, mig_sin_siniestro s,
                         seguros seg
                   WHERE t.mig_pk = a.mig_fk
                     AND s.mig_pk = t.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                     AND seg.sseguro = s.sseguro
                ORDER BY a.mig_fk, a.nmovres) LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SIN_TRAMITA_RESERVA');
            END IF;

            v_error := FALSE;
            v_trami := NULL;
            v_trami.nsinies := x.s_nsinies;
            v_trami.ntramit := x.ntramit;
            v_trami.ctipres := x.ctipres;
            v_trami.nmovres := x.nmovres;
            v_trami.cgarant := x.cgarant;
            v_trami.ccalres := x.ccalres;
            v_trami.fmovres := x.fmovres;
            v_trami.cmonres := x.cmonres;
            v_trami.ireserva := x.ireserva;
            v_trami.ipago := x.ipago;
            v_trami.iingreso := x.iingreso;
            v_trami.irecobro := x.irecobro;
            v_trami.icaprie := NVL(x.icaprie, NVL(x.ipenali, 0) + x.ireserva);
            v_trami.ipenali := NVL(x.ipenali, 0);
            v_trami.fresini := x.fresini;
            v_trami.fresfin := x.fresfin;
            v_trami.fultpag := x.fultpag;
            v_trami.sidepag := x.sidepag;
            v_trami.sproces := x.sproces;
            v_trami.fcontab := x.fcontab;
            v_trami.cusualt := x.cusualt;
            v_trami.falta := x.falta;
            v_trami.cusumod := x.cusumod;
            v_trami.fmodifi := x.fmodifi;
            v_trami.iprerec := x.iprerec;
            v_trami.ctipgas := x.ctipgas;
            v_trami.ireserva_moncia := x.ireserva_moncia;
            v_trami.ipago_moncia := x.ipago_moncia;
            v_trami.iingreso_moncia := x.iingreso_moncia;
            v_trami.irecobro_moncia := x.irecobro_moncia;
            v_trami.icaprie_moncia := x.icaprie_moncia;
            v_trami.ipenali_moncia := x.ipenali_moncia;
            v_trami.iprerec_moncia := x.iprerec_moncia;
            v_trami.fcambio := x.fcambio;
            v_trami.ifranq := x.ifranq;
            v_trami.ifranq_moncia := x.ifranq_moncia;
            v_trami.idres := x.idres;
            v_trami.cmovres := NVL(x.cmovres, 0);
            v_trami.sidepag := x.sidepag;

            ------
            IF v_trami.ccalres = 1 THEN   -- si es automatica, los importes se calculan  ahora..
               num_err :=
                  pac_sin_formula.f_cal_valora
                     (x.fsinies,   -- pfsinies IN sin_siniestro.fsinies%TYPE,
                      x.sseguro,   --psseguro IN seguros.sseguro%TYPE,
                      x.nriesgo,   --pnriesgo IN sin_siniestro.nriesgo%TYPE,
                      v_trami.nsinies,   --pnsinies IN sin_siniestro.nsinies%TYPE,
                      v_trami.ntramit,   --   pntramit IN sin_tramitacion.ntramit%TYPE,
                      x.ctramit,   -- IN sin_tramitacion.ctramit%TYPE,
                      x.sproduc,   -- psproduc IN productos.sproduc%TYPE,
                      x.cactivi,   --pcactivi IN activisegu.cactivi%TYPE DEFAULT 0,
                      v_trami.cgarant,   --pcgarant IN codigaran.cgarant%TYPE,
                      x.ccausin,   -- IN sin_siniestro.ccausin%TYPE,
                      x.cmotsin,   -- IN sin_siniestro.cmotsin%TYPE,
                      x.fnotifi,   -- IN sin_siniestro.fnotifi%TYPE,
                      v_trami.fmovres,   -- pfecval IN sin_tramita_reserva.fmovres%TYPE DEFAULT f_sysdate,
                      v_trami.fresini,   -- pfperini IN sin_tramita_reserva.fresini%TYPE,
                      v_trami.fresfin,   --pfperfin IN sin_tramita_reserva.fresfin%TYPE,
                      v_trami.ireserva,   --pivalora OUT sin_tramita_reserva.ireserva%TYPE,
                      v_trami.ipenali,   -- pipenali OUT sin_tramita_reserva.ipenali%TYPE,
                      v_trami.icaprie,   --picapris OUT sin_tramita_reserva.icaprie%TYPE,
                      v_trami.ifranq   --pifranq OUT sin_tramita_reserva.ifranq%TYPE   --Bug 27059:NSS:05/06/2013
                                    );

               IF num_err <> 0 THEN
                  -- Bug 0028909 - 27/11/2013 - JMF: mostrar el error
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'fcalvalora-' || num_err || ' Error:'
                                                 || SQLCODE || '-' || SQLERRM);
                  v_error := TRUE;
               END IF;
            END IF;

            --          INSERT INTO sin_tramita_reserva
            --               VALUES v_trami;
            num_err :=
               pac_siniestros.f_ins_reserva
                  (v_trami.nsinies,   -- pnsinies IN sin_siniestro.nsinies%TYPE,
                   v_trami.ntramit,   --  pntramit IN NUMBER,
                   v_trami.ctipres,   -- pctipres IN NUMBER,
                   v_trami.cgarant,   -- pcgarant IN NUMBER,
                   v_trami.ccalres,   -- pccalres IN NUMBER,
                   v_trami.fmovres,   -- pfmovres IN DATE,
                   v_trami.cmonres,   -- pcmonres IN VARCHAR2,
                   v_trami.ireserva,   -- pireserva IN NUMBER,
                   v_trami.ipago,   -- pipago IN NUMBER,
                   v_trami.icaprie,   -- picaprie IN NUMBER,
                   v_trami.ipenali,   --pipenali IN NUMBER,
                   v_trami.iingreso,   --piingreso IN NUMBER,
                   v_trami.irecobro,   --pirecobro IN NUMBER,
                   v_trami.fresini,   --pfresini IN DATE,
                   v_trami.fresfin,   --pfresfin IN DATE,
                   v_trami.fultpag,   --pfultpag IN DATE,
                   v_trami.sidepag,   --psidepag IN NUMBER,
                   v_trami.iprerec,   -- piprerec IN NUMBER,
                   v_trami.ctipgas,   -- pctipgas IN NUMBER,
                   v_trami.nmovres,   -- pnmovres IN OUT NUMBER,
                   v_trami.cmovres,   --Bug 31294/174788:NSS:22/05/2014
                   v_trami.ifranq,   --pifranq IN NUMBER DEFAULT NULL   --Bug 27059:NSS:03/06/2013
                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   venviocontabonline   -- indica 0 - No es migración, envio a sistema remoto. 1- Es migracion no envio a sisemas remotos.
                                     );

            IF num_err <> 0 THEN
               -- Bug 0028909 - 27/11/2013 - JMF: mostrar el error
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'finsreserva-' || num_err || ' Error:'
                                              || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
            END IF;

            --
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_trami.nsinies || '|' || v_trami.ntramit || '|' || v_trami.ctipres
                         || '|' || v_trami.nmovres);

            UPDATE mig_sin_tramita_reserva
               SET nsinies = v_trami.nsinies,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_tramita_reserva;

/***************************************************************************
      FUNCTION f_migra_sin_tramita_pago
      Función que inserta los registros grabados en MIG_SIN_TRAMITA_PAGO, en la tabla
      SIN_TRAMITA_PAGO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramita_pago(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL',
      pboldaxis IN BOOLEAN DEFAULT FALSE)
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_tramita_pago%ROWTYPE;
      v_cont         NUMBER;
      v_trami_dest   sin_tramita_destinatario%ROWTYPE;

/*
      --AFM 28/09/10-vvv- Bug 0014954: migrar de OLDAXIS a NEWAXIS -vvv-
      v_query        VARCHAR2(1000)
         := 'SELECT   a.*, s.nsinies s_nsinies, p.idperson
                    FROM mig_sin_tramita_pago a, mig_sin_tramitacion s, mig_personas p
                   WHERE s.mig_pk = a.mig_fk2
                     AND p.mig_pk = a.mig_fk
                     AND a.ncarga = '
            || pncarga || 'AND a.cestmig = 1
                ORDER BY a.mig_pk ';
      v_qoldaxis     VARCHAR2(1000)
         := 'SELECT   a.*, s.nsinies s_nsinies, a.sperson idperson
                    FROM mig_sin_tramita_pago a, mig_sin_tramitacion s
                   WHERE s.mig_pk = a.mig_fk2
                     AND a.ncarga = '
            || pncarga || 'AND a.cestmig = 1
                ORDER BY a.mig_pk';
*/
      CURSOR c_row IS
         SELECT   a.*, s.nsinies s_nsinies, a.sperson idperson, a.mig_pk mmig_pk
             FROM mig_sin_tramita_pago a, mig_sin_tramitacion s
            WHERE s.mig_pk = a.mig_fk2
              AND a.ncarga = pncarga
              AND a.sperson <> 0
              AND a.cestmig = 1   -- si tiene persona informado la cojo de aqui
         UNION
         SELECT   a.*, s.nsinies s_nsinies, p.idperson, a.mig_pk mmig_pk
             FROM mig_sin_tramita_pago a, mig_sin_tramitacion s, mig_personas p
            WHERE s.mig_pk = a.mig_fk2
              AND p.mig_pk = a.mig_fk
              AND a.ncarga = pncarga
              AND a.sperson = 0
              AND a.cestmig = 1
         ORDER BY mmig_pk;
--      x              c_row%ROWTYPE;

   --    TYPE cursor_type IS REF CURSOR;

   --   c_query        cursor_type;
--AFM 28/09/10-^^^- Bug 0014954: migrar de OLDAXIS a NEWAXIS -^^^-
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      --     IF pboldaxis THEN
       --       v_query := v_qoldaxis;
       --    END IF;

      /* --AFM 28/09/10-vvv- Bug 0014954: migrar de OLDAXIS a NEWAXIS -vvv-
              FOR x IN (SELECT   a.*, s.nsinies s_nsinies, p.idperson
                            FROM mig_sin_tramita_pago a, mig_sin_tramitacion s, mig_personas p
                           WHERE s.mig_pk = a.mig_fk2
                             AND p.mig_pk = a.mig_fk
                             AND a.ncarga = pncarga
                             AND a.cestmig = 1
                        ORDER BY a.mig_pk) LOOP
        */
      --  OPEN c_query FOR v_query;

      -- LOOP
      --    FETCH c_query
       --    INTO x;

      --EXIT WHEN c_query%NOTFOUND;
      FOR x IN c_row LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SIN_TRAMITA_PAGO');
            END IF;

            v_error := FALSE;
            v_trami := NULL;

            IF NOT pboldaxis THEN
               SELECT sidepag.NEXTVAL
                 INTO v_trami.sidepag
                 FROM DUAL;
            ELSE
               v_trami.sidepag := x.sidepag;
            END IF;

            v_trami.nsinies := x.s_nsinies;
            v_trami.ntramit := x.ntramit;
            v_trami.sperson := x.idperson;   -- x.sperson;
            v_trami.ctipdes := x.ctipdes;
            v_trami.ctippag := x.ctippag;
            v_trami.cconpag := x.cconpag;
            v_trami.ccauind := x.ccauind;
            v_trami.cforpag := x.cforpag;
            v_trami.fordpag := x.fordpag;
            v_trami.ctipban := x.ctipban;
            v_trami.cbancar := x.cbancar;
            v_trami.cmonres := x.cmonres;
            v_trami.isinret := x.isinret;
            v_trami.iretenc := x.iretenc;
            v_trami.iiva := x.iiva;
            v_trami.isuplid := x.isuplid;
            v_trami.ifranq := x.ifranq;
            v_trami.iresrcm := x.iresrcm;
            v_trami.iresred := x.iresred;
            v_trami.cmonpag := x.cmonpag;
            v_trami.isinretpag := x.isinretpag;
            v_trami.iretencpag := x.iretencpag;
            v_trami.iivapag := x.iivapag;
            v_trami.isuplidpag := x.isuplidpag;
            v_trami.ifranqpag := x.ifranqpag;
            v_trami.iresrcmpag := x.iresrcmpag;
            v_trami.iresredpag := x.iresredpag;
            v_trami.fcambio := x.fcambio;
            v_trami.nfacref := x.nfacref;
            v_trami.ffacref := x.ffacref;
            v_trami.cusualt := x.cusualt;
            v_trami.falta := x.falta;
            v_trami.cusumod := x.cusumod;
            v_trami.fmodifi := x.fmodifi;
            v_trami.cultpag := x.cultpag;
            v_trami.ireteiva := x.ireteiva;
            v_trami.ireteica := x.ireteica;
            v_trami.iica := x.iica;
            v_trami.ireteivapag := x.ireteivapag;
            v_trami.ireteicapag := x.ireteicapag;
            v_trami.iicapag := x.iicapag;
            v_trami.ctributa := x.ctributa;
            -- BUG 0028909 - 21-10-2013 - JMF
            v_trami.ctransfer := x.ctransfer;
            v_trami.sperson_presentador := x.sperson_presentador;
            v_trami.tobserva := x.tobserva;
            v_trami.iotrosgas := x.iotrosgas;
            v_trami.iotrosgaspag := x.iotrosgaspag;
            v_trami.ibaseipoc := x.ibaseipoc;
            v_trami.ibaseipocpag := x.ibaseipocpag;
            v_trami.iipoconsumo := x.iipoconsumo;
            v_trami.iipoconsumopag := x.iipoconsumopag;
            ------
            INSERT INTO sin_tramita_pago
                 VALUES v_trami;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_trami.sidepag);

            UPDATE mig_sin_tramita_pago
               SET nsinies = v_trami.nsinies,
                   sidepag = v_trami.sidepag,
                   sperson = v_trami.sperson,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

-- inserto destinatario del pago
         v_trami_dest := NULL;
         v_trami_dest.nsinies := x.s_nsinies;
         v_trami_dest.ntramit := x.ntramit;
         v_trami_dest.sperson := x.idperson;   -- x.sperson;
         v_trami_dest.ctipdes := x.ctipdes;
         v_trami_dest.ctipban := x.ctipban;
         v_trami_dest.cbancar := x.cbancar;
         v_trami_dest.cpagdes := 1;   --x.cpagdes;
         v_trami_dest.cactpro := NULL;   --x.cactpro;
         v_trami_dest.pasigna := NULL;   --x.pasigna;
         v_trami_dest.cpaisre := NULL;   --x.cpaisre;
         v_trami_dest.cactpro := NULL;   --x.cactpro;
         v_trami_dest.cusualt := x.cusualt;
         v_trami_dest.falta := x.falta;
         v_trami_dest.cusumod := x.cusumod;
         v_trami_dest.fmodifi := x.fmodifi;
         v_trami_dest.ctipcap := NULL;   --x.ctipcap;
         v_trami_dest.crelase := NULL;   --x.crelase;

         ------
         BEGIN
            INSERT INTO sin_tramita_destinatario
                 VALUES v_trami_dest;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;   -- si ya existe pagador no pasa nada.
         END;

         COMMIT;
      END LOOP;

      -- CLOSE c_query;
      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_tramita_pago;

/***************************************************************************
      FUNCTION f_migra_sin_tramita_movpago
      Función que inserta los registros grabados en MIG_SIN_TRAMITA_MOVPAGO, en la tabla
      SIN_TRAMITA_MOVPAGO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramita_movpago(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_tramita_movpago%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies, s.sidepag s_sidepag
                    FROM mig_sin_tramita_movpago a, mig_sin_tramita_pago s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SIN_TRAMITA_MOVPAGO');
            END IF;

            v_error := FALSE;
            v_trami := NULL;
            v_trami.sidepag := x.s_sidepag;
            v_trami.nmovpag := x.nmovpag;
            v_trami.cestpag := x.cestpag;
            v_trami.fefepag := x.fefepag;
            v_trami.cestval := x.cestval;
            v_trami.fcontab := x.fcontab;
            v_trami.sproces := x.sproces;
            v_trami.cusualt := x.cusualt;
            v_trami.falta := x.falta;
            v_trami.csubpag := x.csubpag;

            ------
            INSERT INTO sin_tramita_movpago
                 VALUES v_trami;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_trami.sidepag || '|' || v_trami.nmovpag);

            UPDATE mig_sin_tramita_movpago
               SET sidepag = v_trami.sidepag,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_tramita_movpago;

/***************************************************************************
      FUNCTION f_migra_sin_tramita_pago_gar
      Función que inserta los registros grabados en MIG_SIN_TRAMITA_PAGO_GAR, en la tabla
      SIN_TRAMITA_PAGO_GAR de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramita_pago_gar(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_trami      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_trami        sin_tramita_pago_gar%ROWTYPE;
      v_tramita_reserva sin_tramita_reserva%ROWTYPE;
      v_cont         NUMBER;
      venviocontabonline NUMBER(1);
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF ptablas = 'MIG' THEN
         venviocontabonline := 1;
      ELSE
         venviocontabonline := 0;
      END IF;

      FOR x IN (SELECT   a.*, s.nsinies s_nsinies, s.sidepag s_sidepag, s.ntramit ntramit
                    FROM mig_sin_tramita_pago_gar a, mig_sin_tramita_pago s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_trami THEN
               v_1_trami := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SIN_TRAMITA_PAGO_GAR');
            END IF;

            v_error := FALSE;
            v_trami := NULL;
            v_trami.sidepag := x.s_sidepag;
            v_trami.ctipres := x.ctipres;
            -- v_trami.nmovres := x.nmovres;
            v_trami.cgarant := x.cgarant;
            v_trami.fperini := x.fperini;
            v_trami.fperfin := x.fperfin;
            v_trami.cmonres := x.cmonres;
            v_trami.isinret := x.isinret;
            v_trami.iretenc := x.iretenc;
            v_trami.iiva := x.iiva;
            v_trami.isuplid := x.isuplid;
            v_trami.ifranq := x.ifranq;
            v_trami.iresrcm := x.iresrcm;
            v_trami.iresred := x.iresred;
            v_trami.cmonpag := x.cmonpag;
            v_trami.isinretpag := x.isinretpag;
            v_trami.iretencpag := x.iretencpag;
            v_trami.iivapag := x.iivapag;
            v_trami.isuplidpag := x.isuplidpag;
            v_trami.ifranqpag := x.ifranqpag;
            v_trami.iresrcmpag := x.iresrcmpag;
            v_trami.iresredpag := x.iresredpag;
            v_trami.fcambio := x.fcambio;
            v_trami.pretenc := x.pretenc;
            v_trami.piva := x.piva;
            v_trami.cusualt := x.cusualt;
            v_trami.falta := x.falta;
            v_trami.cusumod := x.cusumod;
            v_trami.fmodifi := x.fmodifi;
            --Bug.: 0014867: CRT002 - ICV - 13/07/2010
            v_trami.cconpag := x.cconpag;
            v_trami.norden := x.norden;
            --Fin Bug.: 0014867: CRT002 - ICV - 13/07/2010
            v_trami.iica := x.iica;
            v_trami.ireteiva := x.ireteiva;
            v_trami.ireteica := x.ireteica;
            v_trami.pica := x.pica;
            v_trami.preteiva := x.preteiva;
            v_trami.preteica := x.preteica;
            v_trami.caplfra := x.caplfra;
            v_trami.iicapag := x.iicapag;
            v_trami.ireteivapag := x.ireteivapag;
            v_trami.ireteicapag := x.ireteicapag;
            v_trami.iotrosgas    := x.iotrosgas;
            v_trami.iotrosgaspag := x.iotrosgaspag;
            v_trami.ibaseipoc    := x.ibaseipoc;
            v_trami.ibaseipocpag := x.ibaseipocpag;
            v_trami.pipoconsumo  := x.pipoconsumo;
            v_trami.iipoconsumo  := x.iipoconsumo;
            v_trami.iipoconsumopag := x.iipoconsumopag;

            IF x.nmovres IS NOT NULL
               AND v_trami.idres IS NOT NULL THEN
               v_trami.nmovres := x.nmovres;
               v_trami.idres := x.idres;
            ELSE
               SELECT   idres, MAX(nmovres) nmovres
                   INTO v_trami.idres, v_trami.nmovres
                   FROM sin_tramita_reserva
                  WHERE nsinies = x.s_nsinies
                    AND ntramit = x.ntramit
                    AND ctipres = v_trami.ctipres
                    --    AND NVL(ctipgas, -1) = NVL(x.ctipgas, -1)
                    AND NVL(cgarant, -1) = NVL(x.cgarant, -1)
                    AND NVL(fresini, TO_DATE('01/01/1900', 'dd/mm/yyyy')) =
                                      NVL(v_trami.fperini, TO_DATE('01/01/1900', 'dd/mm/yyyy'))
                    AND NVL(fresfin, TO_DATE('01/01/1900', 'dd/mm/yyyy')) =
                                      NVL(v_trami.fperfin, TO_DATE('01/01/1900', 'dd/mm/yyyy'))
               GROUP BY idres;
            END IF;

            ------
            INSERT INTO sin_tramita_pago_gar
                 VALUES v_trami;

            -- llamo a modificar la reserva.
            IF NVL(x.crestareserva, 1) = 1 THEN
               SELECT *
                 INTO v_tramita_reserva
                 FROM sin_tramita_reserva
                WHERE nsinies = x.s_nsinies
                  AND idres = v_trami.idres
                  AND nmovres = v_trami.nmovres;

               -- modifico reserva
               v_tramita_reserva.nmovres := NULL;   -- para que la inserte nueva
               num_err :=
                  pac_siniestros.f_ins_reserva
                     (v_tramita_reserva.nsinies,   -- pnsinies IN sin_siniestro.nsinies%TYPE,
                      v_tramita_reserva.ntramit,   --  pntramit IN NUMBER,
                      v_tramita_reserva.ctipres,   -- pctipres IN NUMBER,
                      v_tramita_reserva.cgarant,   -- pcgarant IN NUMBER,
                      v_tramita_reserva.ccalres,   -- pccalres IN NUMBER,
                      f_sysdate,   -- pfmovres IN DATE,
                      v_tramita_reserva.cmonres,   -- pcmonres IN VARCHAR2,
                      v_tramita_reserva.ireserva - NVL(v_trami.isinret, 0),   -- pireserva IN NUMBER,
                      NVL(v_tramita_reserva.ipago, 0) + NVL(v_trami.isinret, 0),   -- pipago IN NUMBER,
                      v_tramita_reserva.icaprie,   -- picaprie IN NUMBER,
                      v_tramita_reserva.ipenali,   --pipenali IN NUMBER,
                      v_tramita_reserva.iingreso,   --piingreso IN NUMBER,
                      v_tramita_reserva.irecobro,   --pirecobro IN NUMBER,
                      v_tramita_reserva.fresini,   --pfresini IN DATE,
                      v_tramita_reserva.fresfin,   --pfresfin IN DATE,
                      NULL,   --pfultpag IN DATE,
                      v_trami.sidepag,   --psidepag IN NUMBER,
                      NULL,   -- piprerec IN NUMBER,
                      v_tramita_reserva.ctipgas,   -- pctipgas IN NUMBER,
                      v_tramita_reserva.nmovres,   -- pnmovres IN OUT NUMBER,
                      4,   -- resta de reserva por pago
                      v_trami.ifranq,   --pifranq IN NUMBER DEFAULT NULL   --Bug 27059:NSS:03/06/2013
                      NULL,   -- pndias
                      NVL(v_tramita_reserva.itotimp, 0) + NVL(v_trami.iica, 0)
                      + NVL(v_trami.iiva, 0),   --
                      NVL(v_tramita_reserva.itotret, 0) + NVL(v_trami.ireteiva, 0)
                      + NVL(v_trami.ireteica, 0),
                      NULL, NULL, NULL, NULL, 0, venviocontabonline);   -- si es migración

               IF num_err <> 0 THEN
                  -- Bug 0028909 - 27/11/2013 - JMF: mostrar el error
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'finsreserva-' || num_err || ' Error:'
                                                 || SQLCODE || '-' || SQLERRM);
                  v_error := TRUE;
               END IF;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_trami.sidepag || '|' || v_trami.ctipres || '|' || v_trami.nmovres);

            UPDATE mig_sin_tramita_pago_gar
               SET sidepag = v_trami.sidepag,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_tramita_pago_gar;

--Ini Bug 0012557 - 14-01-2009 - JMC - Se añaden nuevas funciones
/***************************************************************************
      FUNCTION f_migra_sup_diferidosseg
      Función que inserta los registros grabados en MIG_SUP_DIFERIDOSSEG, en la tabla
      sup_diferidosseg de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sup_diferidosseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_diferido   BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_sup_diferidosseg sup_diferidosseg%ROWTYPE;
      v_cont         NUMBER;
      v_seg          seguros%ROWTYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_sup_diferidosseg a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_diferido THEN
               v_1_diferido := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SUP_DIFERIDOSSEG');
            END IF;

            v_error := FALSE;
            v_sup_diferidosseg := NULL;
            v_sup_diferidosseg.sseguro := x.s_sseguro;
            v_sup_diferidosseg.cmotmov := x.cmotmov;
            v_sup_diferidosseg.estado := x.estado;
            v_sup_diferidosseg.fecsupl := x.fecsupl;
            v_sup_diferidosseg.fvalfun := x.fvalfun;
            v_sup_diferidosseg.cusuari := x.cusuari;
            v_sup_diferidosseg.falta := x.falta;
            v_sup_diferidosseg.tvalord := x.tvalord;
            v_sup_diferidosseg.fanula := x.fanula;

            ------
            INSERT INTO sup_diferidosseg
                 VALUES v_sup_diferidosseg;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_sup_diferidosseg.cmotmov || '|' || v_sup_diferidosseg.sseguro || '|'
                         || v_sup_diferidosseg.estado);

            UPDATE mig_sup_diferidosseg
               SET sseguro = v_sup_diferidosseg.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sup_diferidosseg;

/***************************************************************************
      FUNCTION f_migra_sup_acciones_dif
      Función que inserta los registros grabados en MIG_SUP_ACCIONES_DIF, en la tabla
      sup_acciones_dif de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sup_acciones_dif(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_accion     BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_accion       sup_acciones_dif%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_sup_acciones_dif a, mig_sup_diferidosseg s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_accion THEN
               v_1_accion := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'SUP_ACCIONES_DIF');
            END IF;

            v_error := FALSE;
            v_accion := NULL;
            v_accion.sseguro := x.s_sseguro;
            v_accion.cmotmov := x.cmotmov;
            v_accion.norden := x.norden;
            v_accion.estado := x.estado;
            v_accion.dinaccion := x.dinaccion;
            v_accion.ttable := x.ttable;
            v_accion.tcampo := x.tcampo;
            v_accion.twhere := x.twhere;
            v_accion.taccion := x.taccion;
            v_accion.naccion := x.naccion;
            v_accion.vaccion := x.vaccion;
            v_accion.ttarifa := x.ttarifa;

            ------
            INSERT INTO sup_acciones_dif
                 VALUES v_accion;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_accion.cmotmov || '|' || v_accion.sseguro || '|' || v_accion.norden
                         || '|' || v_accion.estado);

            UPDATE mig_sup_acciones_dif
               SET sseguro = v_accion.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sup_acciones_dif;

/***************************************************************************
      FUNCTION f_migra_pagosrenta
      Función que inserta los registros grabados en MIG_PAGOSRENTA, en la tabla
      pagosrenta de AXIS (PAGOSRENTA y MOVPAGREN).
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_pagosrenta(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_pagosrenta BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_pagosrenta   pagosrenta%ROWTYPE;
      v_cont         NUMBER;
      e_error        EXCEPTION;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, s.sperson s_sperson
                    FROM mig_pagosrenta a, mig_asegurados s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_pagosrenta THEN
               v_1_pagosrenta := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'PAGOSRENTA');
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 2, 'MOVPAGREN');
            END IF;

            v_error := NULL;
            v_pagosrenta := NULL;
            v_pagosrenta.sseguro := x.s_sseguro;
            v_pagosrenta.sperson := x.s_sperson;
            --SELECT sperson
            --  INTO v_pagosrenta.sperson
            --  FROM mig_asegurados
            -- WHERE mig_asegurados.mig_pk = x.mig_fk;
            v_pagosrenta.ffecefe := x.ffecefe;
            v_pagosrenta.ffecpag := x.ffecpag;
            v_pagosrenta.cmotanu := x.cmotanu;
            v_pagosrenta.isinret := x.isinret;
            v_pagosrenta.iconret := x.iconret;
            v_pagosrenta.ibase := x.ibase;
            v_pagosrenta.pparben := x.pparben;
            v_pagosrenta.pretenc := x.pretenc;
            v_pagosrenta.iretenc := x.iretenc;
            v_pagosrenta.ffecanu := x.ffecanu;
            v_pagosrenta.pintgar := x.pintgar;
            v_pagosrenta.nctacor := x.nctacor;
            v_pagosrenta.nremesa := x.nremesa;
            v_pagosrenta.fremesa := x.fremesa;
            v_pagosrenta.ctipban := x.ctipban;
            v_pagosrenta.proceso := x.proceso;

            SELECT ssrecren.NEXTVAL
              --Bug 0013924 - 06-04-2010 - JMC - Se cambia secuencia
            INTO   v_pagosrenta.srecren
              FROM DUAL;

            INSERT INTO pagosrenta
                 VALUES v_pagosrenta;

            IF NVL(pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'),
                                                 'MULTIMONEDA'),
                   0) = 1 THEN
               num_err := pac_oper_monedas.f_contravalores_pagosrenta(v_pagosrenta.srecren,
                                                                      v_pagosrenta.sseguro);

               IF num_err <> 0 THEN
                  RAISE e_error;
               END IF;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_pagosrenta.srecren);

            INSERT INTO movpagren
                        (srecren, smovpag, cestrec, fmovini,
                         fmovfin, fefecto)
                 VALUES (v_pagosrenta.srecren, 1, 0, v_pagosrenta.ffecpag,
                         v_pagosrenta.ffecpag, v_pagosrenta.ffecefe);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 2, v_pagosrenta.srecren || '|1');

            INSERT INTO movpagren
                        (srecren, smovpag, cestrec, fmovini, fmovfin,
                         fefecto)
                 VALUES (v_pagosrenta.srecren, 2, 1, v_pagosrenta.ffecpag, NULL,
                         v_pagosrenta.ffecefe);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 2, v_pagosrenta.srecren || '|2');

            UPDATE mig_pagosrenta
               SET sseguro = v_pagosrenta.sseguro,
                   sperson = v_pagosrenta.sperson,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;

            -- BUG 0011691 - 12/2009 - JRH  -  Actualizar ctaseguro con el srecren
            UPDATE ctaseguro
               SET srecren = v_pagosrenta.srecren
             WHERE sseguro = v_pagosrenta.sseguro
               AND ffecmov = v_pagosrenta.ffecpag
               AND cmovimi = 53
               AND srecren IS NULL;
         -- Fi BUG 0011691 - 12/2009 - JRH
         EXCEPTION
            WHEN e_error THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error contravalores:' || SQLCODE || '-'
                                              || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_pagosrenta;

/***************************************************************************
      FUNCTION f_migra_comisionsegu
      Función que inserta los registros grabados en MIG_COMISIONSEGU, en la tabla
      COMISIONSEGU de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_comisionsegu(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_csegu      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_csegu        comisionsegu%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_comisionsegu a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_csegu THEN
               v_1_csegu := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'COMISIONSEGU');
            END IF;

            v_error := NULL;
            v_csegu := NULL;
            v_csegu.sseguro := x.s_sseguro;
            v_csegu.cmodcom := x.cmodcom;
            v_csegu.pcomisi := x.pcomisi;
            v_csegu.ninialt := x.ninialt;
            v_csegu.nfinalt := x.nfinalt;
            v_csegu.nmovimi := x.nmovimi;   -- Bug 30642/169851 - 20/03/2014 - AMC

            -- 23289/120321 - ECP- 04/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estcomisionsegu
                    VALUES v_csegu;

               -- pongo a tipo de comision especial el seguro
               UPDATE estseguros
                  SET ctipcom = 90
                WHERE sseguro = v_csegu.sseguro;
            ELSE
               INSERT INTO comisionsegu
                    VALUES v_csegu;

               -- pongo a tipo de comision especial el seguro
               UPDATE seguros
                  SET ctipcom = 90
                WHERE sseguro = v_csegu.sseguro;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_csegu.sseguro || '|' || x.cmodcom || '|' || x.ninialt || '|'
                         || x.nmovimi);

            UPDATE mig_comisionsegu
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_comisionsegu;

--Fin Bug 0012557 - 14-01-2009 - JMC
--FIN BUG:12374 - 22-12-2009 - JMC
/***************************************************************************
      PROCEDURE p_migra_cargas
      Procedimiento que determina las cargas que estan pendientes de migrar y
      lanza dinamicamente la función para migrar dichas cargas.
      ctaseguro de AXIS.
         param in  pide:     Identificador de las cargas.
         param in  ptipo:    Tipo proceso (M-Migración;C-Carga Pólizas).
         param in  pncarga:  Número de carga, si NULL todas.
   ***************************************************************************/
   PROCEDURE p_migra_cargas(
      pid IN VARCHAR2 DEFAULT NULL,
      --BUG:12243 - 02-12-2009 - JMC - Se añade parametro pid
      ptipo IN VARCHAR2 DEFAULT 'M',
      --BUG:14185 - 11-05-2010 - JMC - Se añade parametro ptipo
      pncarga IN NUMBER DEFAULT NULL,
      --BUG:14185 - 11-05-2010 - JMC - Se añade parametro pncarga
      pcestado IN VARCHAR2 DEFAULT 'RET',
      --BUG:14185 - 11-05-2010 - JMC - Se añade parametro pcestado
      ptabla IN VARCHAR2 DEFAULT 'POL',   -- BUG 23548 -- 18/09/2012,
      pcmodo IN VARCHAR DEFAULT 'GENERAL') IS
      num_err        NUMBER := 0;
      v_funcion      VARCHAR2(100);
      v_usu_context  VARCHAR2(100);
      empresa        VARCHAR2(10);
      v_ncarga       NUMBER;
           -- JLB - I
      --     v_sproduc      productos.sproduc%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      --     v_fefecto      seguros.fefecto%TYPE;
      --     v_cactivi      seguros.cactivi%TYPE;
      vmens          mig_logs_axis.incid%TYPE;
-- JLB -  I - 26050
 -- optimización de query's
      v_query        VARCHAR2(2000);

      TYPE cur_typ IS REF CURSOR;

      c              cur_typ;
      vtfuncion      mig_orden_axis.tfuncion%TYPE;
      --   vncarga   mig_cargas.ncarga%type;
      vntab          mig_cargas_tab_mig.ntab%TYPE;
      vnorden        mig_orden_axis.norden%TYPE;
   BEGIN
      empresa := f_parinstalacion_n('EMPRESADEF');
      k_tipo_carga := ptipo;

      -- JLB me guardo el tipo carga, si es migracion o carga

      --BUG:14568 - 17-05-2010 - JMC - Solo se inicializa contexto en caso de Migración
      IF ptipo = 'M' THEN
         num_err := pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(empresa,
                                                                                'USER_BBDD'));
      END IF;

      --FIN BUG:14568 - 17-05-2010 - JMC
      IF f_user IS NOT NULL
         AND num_err = 0 THEN
         /*
         FOR x IN (SELECT DISTINCT a.ncarga, b.ntab, b.tab_des, c.tfuncion,
                                   norden   --a.ncarga, b.ntab, b.tab_des, c.tfuncion
                              FROM mig_cargas a, mig_cargas_tab_mig b, mig_orden_axis c
                             WHERE b.ncarga = a.ncarga
                               AND b.tab_des = TRIM('MIG_' || tabla)
                               AND finides IS NULL
                               -- BUG : 12243 - 02-12-2009 - JMC - Se tiene en cuenta el ID
                               AND(a.ID = pid
                                   OR(a.ID IS NULL
                                      AND pid IS NULL))
                               AND(pncarga IS NULL
                                   OR pncarga = a.ncarga)
                          -- FIN BUG : 12243 - 02-12-2009 - JMC
                   ORDER BY        norden, ncarga, ntab) LOOP */--
         v_query :=
            'SELECT DISTINCT a.ncarga, b.ntab, c.tfuncion, c.norden
                              FROM mig_cargas a, mig_cargas_tab_mig b, mig_orden_axis c
                             WHERE b.ncarga = a.ncarga
                               AND b.tab_des = TRIM(''MIG_'' || tabla)
                               AND finides IS NULL ';

         IF pid IS NOT NULL THEN
            --      AND(a.ID = pid
              --        OR(a.ID IS NULL
                --         AND pid IS NULL))
            v_query := v_query || ' AND a.id = ''' || pid || ''' ';
         ELSE
            v_query := v_query || ' AND a.ID IS NULL ';
         END IF;

         IF pncarga IS NOT NULL THEN
             -- AND(pncarga IS NULL
            --      OR pncarga = a.ncarga)
            v_query := v_query || ' AND a.ncarga = ' || pncarga;
         END IF;

         v_query := v_query || ' ORDER BY        norden, ncarga, ntab';

         OPEN c FOR v_query;

         LOOP
            BEGIN
               FETCH c
                INTO v_ncarga, vntab, vtfuncion, vnorden;

               EXIT WHEN c%NOTFOUND;
               -- i - jlb - 26050
--               v_ncarga := x.ncarga;
  --             v_funcion := 'begin :num_err:=' || x.tfuncion || '(' || x.ncarga || ','
        --                    || x.ntab || ',''' || ptabla || '''); end;';
               v_funcion := 'begin :num_err:=' || vtfuncion || '(' || v_ncarga || ',' || vntab
                            || ',''' || ptabla || '''); end;';

               EXECUTE IMMEDIATE v_funcion
                           USING OUT num_err;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_MIG_AXIS', 0, 'Error en p_migra_cargas',
                              'Error:' || SQLCODE || ',' || SQLERRM);
                  num_err := f_ins_mig_logs_axis(pncarga, 'PRINCIPAL', 'E',
                                                 'Error P_MIGRA_CARGAS:' || SQLCODE || '-'
                                                 || SQLERRM || ' v_funcion: ' || v_funcion);

                  IF NVL(ptipo, 'M') = 'C' THEN
                     num_err := 1;
                     EXIT;
                  END IF;
            END;

            IF num_err <> 0
               AND NVL(ptipo, 'M') = 'C' THEN
               EXIT;
            END IF;
         END LOOP;

         IF c%ISOPEN THEN
            CLOSE c;
         END IF;

         IF NVL(ptipo, 'M') = 'C'
            AND num_err > 0 THEN
            UPDATE mig_cargas_tab_mig
               SET estdes = NVL(pcestado, 'RET')
             WHERE ncarga = v_ncarga;

--            COMMIT;
            IF ptabla IN('POL', 'MIG') THEN
               p_borra_cargas(NVL(pcestado, 'RET'), v_ncarga, ptipo);
            END IF;

            UPDATE mig_cargas_tab_mig
               SET estdes = NULL
             WHERE ncarga = v_ncarga
               AND estdes = NVL(pcestado, 'RET');

            COMMIT;
         ELSE   -- JLB
            -- si ha ido bien la migracion
            -- JLB - I
            BEGIN
               --  BEGIN
               FOR reg IN (SELECT sproduc, sseguro, fefecto, cactivi, mig_pk
                             --  INTO v_sproduc, v_sseguro, v_fefecto, v_cactivi
                           FROM   mig_seguros
                            WHERE ncarga = v_ncarga) LOOP
                  v_sseguro := reg.sseguro;
                  num_err := f_lanza_post(v_ncarga, ptabla, v_sseguro, reg.sproduc,
                                          reg.fefecto, 1, vmens, pcmodo, reg.cactivi);

                  --lanzamos para el movimiento 1
                  IF num_err <> 0 THEN
                     ROLLBACK;
                     num_err := f_ins_mig_logs_axis(pncarga, 'PRINCIPAL', 'E',
                                                    'Error:' || num_err || '-' || vmens);
                  END IF;

                  -- INI RLLF 18/06/2015 BUG-34959 Cambios problemas con Conmutación Pensional por no grabar en SEGUROSCOL
                  IF ptabla IN('POL', 'MIG') THEN
                     num_err := f_act_seguroscol(v_sseguro, vmens);

                     IF num_err <> 0 THEN
                        ROLLBACK;
                        num_err := f_ins_mig_logs_axis(pncarga, 'PRINCIPAL', 'E',
                                                       'Error:' || num_err || '-' || vmens);
                     END IF;
                  END IF;

                  -- FIN RLLF 18/06/2015 BUG-34959  Cambios problemas con Conmutación Pensional por no grabar en SEGUROSCOL

                  --EXCEPTION
                    -- WHEN NO_DATA_FOUND THEN   --
                  IF v_sseguro IS NOT NULL THEN
                     UPDATE mig_seguros
                        SET sseguro = v_sseguro
                      -- updateo con el seguro obtenido en la emision
                     WHERE  mig_pk = reg.mig_pk;
                  END IF;
               -- END;--
               END LOOP;

               IF NVL(ptipo, 'M') = 'C'
                  AND num_err > 0 THEN
                  UPDATE mig_cargas_tab_mig
                     SET estdes = NVL(pcestado, 'RET')
                   WHERE ncarga = v_ncarga;

                  --           COMMIT;
                  IF ptabla IN('POL', 'MIG') THEN
                     p_borra_cargas(NVL(pcestado, 'RET'), v_ncarga, ptipo);
                  END IF;

                  UPDATE mig_cargas_tab_mig
                     SET estdes = NULL
                   WHERE ncarga = v_ncarga
                     AND estdes = NVL(pcestado, 'RET');
/*               ELSE
                  IF v_sseguro IS NOT NULL THEN
                     UPDATE mig_seguros
                        SET sseguro = v_sseguro
                      -- updateo con el seguro obtenido en la emision
                     WHERE  ncarga = v_ncarga;
                  END IF;*/
               END IF;

               COMMIT;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_logs_axis(pncarga, 'PRINCIPAL', 'E',
                                                 'Error:' || SQLERRM);
            END;
         -- JLB - F
         END IF;
      END IF;
   END p_migra_cargas;

/***************************************************************************
        PROCEDURE p_borra_tabla_mig
        Procedimiento que dada una carga, la tabla MIG  retrocede o borra la
        migración de dicha carga.
           param in  pncarga:     Número de carga.
           param in  pntab:       Número de tabla.
           param in  pttab:       Nombre de la tabla.
           param in  ptipo        Tipo proceso M-Migración, C-Carga pólizas
     ***************************************************************************/
   PROCEDURE p_borra_tabla_mig(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      pttab IN VARCHAR2,
      ptipo IN VARCHAR2 DEFAULT 'M') IS
      num_err        NUMBER;
      v_cont         NUMBER := 0;
      v_ttexto       VARCHAR2(100);
      v_last_seqlog  NUMBER;
      v_error        BOOLEAN := FALSE;

      TYPE r_cont IS RECORD(
         cont           NUMBER
      );

      TYPE t_cont IS TABLE OF r_cont
         INDEX BY BINARY_INTEGER;

      v_contador     t_cont;
   BEGIN
      --BUG:10395 - 12-06-2009 - JMC - Obtenemos el último SEQLOG de MIG_LOGS_AXIS
      SELECT MAX(seqlog)
        INTO v_last_seqlog
        FROM mig_logs_axis
       WHERE ncarga = pncarga;

      --FIN BUG:10395 - 12-06-2009 - JMC
      --Primero borramos los registros de las tablas AXIS que se han
      --insertado a raiz de acciones de triggers de tablas
      IF pttab = 'MIG_SEGUROS' THEN
         FOR x IN 0 .. 7 LOOP
            v_contador(x).cont := 0;
         END LOOP;

         FOR x IN (SELECT pkaxis
                     FROM mig_pk_mig_axis
                    WHERE ncarga = pncarga
                      AND ntab = pntab
                      AND ntabaxis = 1) LOOP
            DELETE      segurosredcom
                  WHERE sseguro = TO_NUMBER(x.pkaxis);

            v_contador(0).cont := v_contador(0).cont + SQL%ROWCOUNT;

            DELETE      seguredcom
                  WHERE sseguro = TO_NUMBER(x.pkaxis);

            v_contador(1).cont := v_contador(1).cont + SQL%ROWCOUNT;

            DELETE      detreasegemi dr
                  WHERE EXISTS(SELECT '*'
                                 FROM reasegemi r
                                WHERE r.sreaemi = dr.sreaemi
                                  AND r.sseguro = TO_NUMBER(x.pkaxis));

            v_contador(2).cont := v_contador(2).cont + SQL%ROWCOUNT;

            DELETE      reasegemi
                  WHERE sseguro = TO_NUMBER(x.pkaxis);

            v_contador(3).cont := v_contador(3).cont + SQL%ROWCOUNT;

            DELETE      cuafacul
                  WHERE sseguro = TO_NUMBER(x.pkaxis);

            v_contador(4).cont := v_contador(4).cont + SQL%ROWCOUNT;

            DELETE      cesionesrea
                  WHERE sseguro = TO_NUMBER(x.pkaxis);

            v_contador(5).cont := v_contador(5).cont + SQL%ROWCOUNT;

            DELETE      ppnc_previo
                  WHERE sseguro = TO_NUMBER(x.pkaxis);

            v_contador(6).cont := v_contador(6).cont + SQL%ROWCOUNT;

            DELETE      ppnc
                  WHERE sseguro = TO_NUMBER(x.pkaxis);

            v_contador(7).cont := v_contador(7).cont + SQL%ROWCOUNT;
            COMMIT;
         END LOOP;

         FOR x IN 0 .. 7 LOOP
            v_ttexto := CASE
                          WHEN x = 0 THEN 'SEGUROSREDCOM'
                          WHEN x = 1 THEN 'SEGUREDCOM'
                          WHEN x = 2 THEN 'DETREASEGEMI'
                          WHEN x = 3 THEN 'REASEGEMI'
                          WHEN x = 4 THEN 'CUAFACUL'
                          WHEN x = 5 THEN 'CESIONESREA'
                          WHEN x = 6 THEN 'PPNC_PREVIO'
                          WHEN x = 7 THEN 'PPNC'
                       END;
            num_err := f_ins_mig_logs_axis(pncarga, 'Borrado', 'I',
                                           v_ttexto || ' : ' || SQL%ROWCOUNT
                                           || ' registros borrados (Fuera proceso)');
         END LOOP;
      END IF;

      --Ini Bug 0012557 - 14-01-2009 - JMC - Se borra historico de la agenda de la póliza.
      IF pttab = 'MIG_AGENSEGU' THEN
         v_cont := 0;

         FOR x IN (SELECT pkaxis
                     FROM mig_pk_mig_axis
                    WHERE ncarga = pncarga
                      AND ntab = pntab
                      AND ntabaxis = 1) LOOP
            DELETE      hisagensegu
                  WHERE sseguro = TO_NUMBER(x.pkaxis);

            v_cont := v_cont + 1;
            COMMIT;
         END LOOP;

         num_err := f_ins_mig_logs_axis(pncarga, 'Borrado', 'I',
                                        'HISAGENSEGU : ' || v_cont
                                        || ' registros borrados (Fuera proceso)');
      END IF;

      --Ini Bug 0012557 - 14-01-2009 - JMC
      --Borramos los registros de v_detrecibos que ha generado la carga
      IF pttab = 'MIG_RECIBOS' THEN
         v_cont := 0;

         FOR x IN (SELECT pkaxis
                     FROM mig_pk_mig_axis
                    WHERE ncarga = pncarga
                      AND ntab = pntab
                      AND ntabaxis = 1) LOOP
            -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE FROM vdetrecibos_monpol
                  WHERE nrecibo = TO_NUMBER(x.pkaxis);

            -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE      vdetrecibos
                  WHERE nrecibo = TO_NUMBER(x.pkaxis);

            v_cont := v_cont + SQL%ROWCOUNT;
            COMMIT;
         END LOOP;

         num_err := f_ins_mig_logs_axis(pncarga, 'Borrado', 'I',
                                        'VDETRECIBOS : ' || v_cont
                                        || ' registros borrados (Fuera proceso)');
      END IF;

      IF pttab = 'MIG_RIESGO' THEN
         FOR x IN (SELECT pkaxis
                     FROM mig_pk_mig_axis
                    WHERE ncarga = pncarga
                      AND ntab = pntab
                      AND ntabaxis = 1) LOOP
            DELETE FROM sitriesgo
                  WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                    AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));

            v_cont := v_cont + SQL%ROWCOUNT;
            COMMIT;
         END LOOP;

         num_err := f_ins_mig_logs_axis(pncarga, 'Borrado', 'I',
                                        'SITRIESGO : ' || v_cont
                                        || ' registros borrados (Fuera proceso)');
      END IF;

      --Borramos los registros de las tablas Axis que se han cargado basandose
      --en las tablas intermedias MIG_
      FOR y IN (SELECT   ntabaxis, ttabaxis
                    FROM mig_cargas_tab_axis
                   WHERE ncarga = pncarga
                     AND ntab = pntab
                ORDER BY ntabaxis DESC) LOOP
         v_cont := 0;

         FOR x IN (SELECT pkaxis
                     FROM mig_pk_mig_axis
                    WHERE ncarga = pncarga
                      AND ntab = pntab
                      AND ntabaxis = y.ntabaxis) LOOP
            BEGIN
               IF y.ttabaxis = 'PREGUNGARANSEG' THEN
                  DELETE      pregungaranseg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cgarant = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3))
                          AND finiefe = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 4),
                                                'yyyymmdd')
                          AND nmovima = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 5))
                          AND cpregun = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 6));
               ELSIF y.ttabaxis = 'HISTORICOSEGUROS' THEN
                  DELETE      historicoseguros
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'MOVSEGURO' THEN
                  DELETE      movseguro
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'ASEGURADOS_INNOM' THEN
                  DELETE      asegurados_innom
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'CNV_CONV_EMP_SEG' THEN
                  DELETE      cnv_conv_emp_seg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'CTASEGURO_LIBRETA' THEN
                  DELETE      ctaseguro_libreta
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND fcontab = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 1),
                                                'yyyymmdd')
                          AND nnumlin = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'CTASEGURO' THEN
                  DELETE      ctaseguro
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND fcontab = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 1),
                                                'yyyymmdd')
                          AND nnumlin = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'COMISIONSEGU' THEN
                  DELETE      comisionsegu
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cmodcom = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND ninialt = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'COACUADRO' THEN
                  DELETE      coacuadro
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ncuacoa = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'COACEDIDO' THEN
                  DELETE      coacedido
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ncuacoa = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND ccompan = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'PREGUNSEG' THEN
                  DELETE      pregunseg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cpregun = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'AGENSEGU' THEN
                  DELETE      agensegu
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nlinea = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'GESCOBROS' THEN
                  DELETE      gescobros
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'PAGOSRENTA' THEN
                  DELETE      pagosrenta
                        WHERE srecren = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1));
               ELSIF y.ttabaxis = 'MOVPAGREN' THEN
                  DELETE      movpagren
                        WHERE srecren = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND smovpag = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'SUP_DIFERIDOSSEG' THEN
                  DELETE      sup_diferidosseg
                        WHERE cmotmov = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND estado = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'SUP_ACCIONES_DIF' THEN
                  DELETE      sup_acciones_dif
                        WHERE cmotmov = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND norden = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND estado = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'PREGUNPOLSEG' THEN
                  DELETE      pregunpolseg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cpregun = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'GARANSEG' THEN
                  DELETE      garanseg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cgarant = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3))
                          AND finiefe = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 4),
                                                'yyyymmdd');
               ELSIF y.ttabaxis = 'DETGARANSEG' THEN
                  DELETE      detgaranseg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cgarant = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3))
                          AND finiefe = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 4),
                                                'yyyymmdd')
                          AND ndetgar = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 5));
               --BUG:10395 - 15-06-2009 - JMC - Borrados de COMISIGARANSEG
               ELSIF y.ttabaxis = 'COMISIGARANSEG' THEN
                  DELETE      comisigaranseg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cgarant = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3))
                          AND finiefe = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 4),
                                                'yyyymmdd')
                          AND ndetgar = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 5));
               ELSIF y.ttabaxis = 'PRESTAMOS' THEN
                  DELETE      prestamos
                        WHERE ctapres = pac_map.f_valor_linia('|', x.pkaxis, 0, 1)
                          AND falta = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 1),
                                              'yyyymmdd');
               ELSIF y.ttabaxis = 'PRESTAMOSEG' THEN
                  DELETE      prestamoseg
                        WHERE ctapres = pac_map.f_valor_linia('|', x.pkaxis, 0, 1)
                          AND sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'PRESTCUADROSEG' THEN
                  DELETE      prestcuadroseg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND fefecto = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 2),
                                                'yyyymmdd');
               --FIN BUG:10395 - 15-06-2009 - JMC
               ELSIF y.ttabaxis = 'CLAUBENSEG' THEN
                  DELETE      claubenseg
                        WHERE nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND sclaben = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'CLAUSUESP' THEN
                  DELETE      clausuesp
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cclaesp = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3))
                          AND nordcla = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 4));
               ELSIF y.ttabaxis = 'CLAUSUSEG' THEN
                  DELETE      claususeg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND sclagen = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'RIESGOS' THEN
                  DELETE      riesgos
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               -- BUG : 18334 - 26-04-2011 - JMC - Carga pólizas
               ELSIF y.ttabaxis = 'AUTRIESGOS' THEN
                  DELETE      autriesgos
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'AUTDETRIESGOS' THEN
                  DELETE      autdetriesgos
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND caccesorio = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'SITRIESGO' THEN
                  DELETE      sitriesgo
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               -- FIN BUG : 18334 - 26-04-2011 - JMC
               ELSIF y.ttabaxis = 'ASEGURADOS' THEN
                  DELETE      asegurados
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND norden = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'SEGUROS_AHO' THEN
                  DELETE      seguros_aho
                        WHERE sseguro = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'SEGUROS_REN' THEN
                  DELETE      seguros_ren
                        WHERE sseguro = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'SEG_CBANCAR' THEN
                  DELETE      seg_cbancar
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'INTERTECSEG' THEN
                  DELETE      intertecseg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND ndesde = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'PENALISEG' THEN
                  DELETE      penaliseg
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND ctipmov = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND niniran = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'DETMOVSEGURO' THEN
                  DELETE      detmovseguro
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cmotmov = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3))
                          AND cgarant = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 4))
                          AND cpregun = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 5));
               ELSIF y.ttabaxis = 'CNVPOLIZAS' THEN
                  DELETE      cnvpolizas
                        WHERE sistema = pac_map.f_valor_linia('|', x.pkaxis, 0, 1)
                          AND polissa_ini = pac_map.f_valor_linia('|', x.pkaxis, 1, 1);
               ELSIF y.ttabaxis = 'TOMADORES' THEN
                  DELETE      tomadores
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'SEGUROS' THEN
                  DELETE      seguredcom
                        WHERE sseguro = TO_NUMBER(x.pkaxis);

                  DELETE      segurosredcom
                        WHERE sseguro = TO_NUMBER(x.pkaxis);

                  DELETE      riesgos
                        WHERE sseguro = TO_NUMBER(x.pkaxis);

                  DELETE      detmovseguro
                        WHERE sseguro = TO_NUMBER(x.pkaxis);

                  DELETE      movseguro
                        WHERE sseguro = TO_NUMBER(x.pkaxis);

                  DELETE      seguros
                        WHERE sseguro = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'CONTRATOSAGE' THEN
                  DELETE      contratosage
                        WHERE cempres = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'COMISIONVIG_AGENTE' THEN
                  DELETE      comisionvig_agente
                        WHERE cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ccomisi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND TRUNC(finivig) = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1,
                                                                             2),
                                                       'yyyymmdd');
               ELSIF y.ttabaxis = 'AGENTES_COMP' THEN
                  DELETE      agentes_comp
                        WHERE cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1));
               ELSIF y.ttabaxis = 'AGEREDCOM' THEN
                  DELETE      ageredcom
                        WHERE cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1));
               ELSIF y.ttabaxis = 'REPRESENTANTES' THEN
                  DELETE      representantes
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1));
               ELSIF y.ttabaxis = 'EMPLEADOS' THEN
                  DELETE      empleados
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1));
               ELSIF y.ttabaxis = 'PRODUCTOS_EMPLEADOS' THEN
                  DELETE      productos_empleados
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND sproduc = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cageadn = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND cageint = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'TIPO_EMPLEADOS' THEN
                  DELETE      tipo_empleados
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND csegmento = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'REDCOMERCIAL' THEN
                  DELETE      redcomercial
                        WHERE cempres = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND TRUNC(fmovini) = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1,
                                                                             2),
                                                       'yyyymmdd');
               ELSIF y.ttabaxis = 'AGENTES' THEN
                  DELETE      agentes
                        WHERE cagente = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'PER_PERSONAS_REL' THEN
                  DELETE      per_personas_rel
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND sperson_rel = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1,
                                                                            2));
               ELSIF y.ttabaxis = 'PER_REGIMENFISCAL' THEN
                  DELETE      per_regimenfiscal
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND TRUNC(fefecto) = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1,
                                                                             2),
                                                       'yyyymmdd');
               ELSIF y.ttabaxis = 'PER_VINCULOS' THEN
                  DELETE      per_vinculos
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cvinclo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'PER_NACIONALIDADES' THEN
                  DELETE      per_nacionalidades
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cpais = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'PER_CCC' THEN
                  DELETE      per_ccc
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cnordban = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'PER_IDENTIFICADOR' THEN
                  DELETE      per_identificador
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND ctipide = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'PER_CONTACTOS' THEN
                  DELETE      per_contactos
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cmodcon = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'PER_DIRECCIONES' THEN
                  DELETE      per_direcciones
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cdomici = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'PER_DETPER' THEN
                  DELETE      per_detper
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));

                  DELETE      hisper_detper
                        WHERE sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'PER_PERSONAS' THEN
                  DELETE      hisper_identificador
                        WHERE sperson = TO_NUMBER(x.pkaxis);

                  DELETE      hisper_nacionalidades
                        WHERE sperson = TO_NUMBER(x.pkaxis);

                  DELETE      per_personas
                        WHERE sperson = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'RECIBOS' THEN
                  DELETE      recibos
                        WHERE nrecibo = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'MOVRECIBO' THEN
                  DELETE      movrecibo
                        WHERE smovrec = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'DETRECIBOS' THEN
                  DELETE      detrecibos
                        WHERE nrecibo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND cconcep = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cgarant = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'SEGUROS_ULK' THEN
                  DELETE      seguros_ulk
                        WHERE sseguro = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'TABVALCES' THEN
                  DELETE      tabvalces
                        WHERE ccesta = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND fvalor = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 1),
                                               'yyyymmdd');
               -- BUG 10054 - 22-10-2009 - JMC - Borrado de la tabla PER_PARPERSONAS
               ELSIF y.ttabaxis = 'PER_PARPERSONAS' THEN
                  DELETE      per_parpersonas
                        WHERE cparam = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cagente = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               -- FIN BUG 10054 - 22-10-2009 - JMC
               ELSIF y.ttabaxis = 'SIN_SINIESTRO' THEN
                  DELETE      sin_siniestro
                        WHERE nsinies = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'SIN_SINIESTRO_REFERENCIAS' THEN
                  DELETE      sin_siniestro_referencias
                        WHERE srefext = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'SIN_MOVSINIESTRO' THEN
                  DELETE      sin_movsiniestro
                        WHERE nsinies = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovsin = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'SIN_TRAMITACION' THEN
                  DELETE      sin_tramita_documento
                        WHERE nsinies = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ntramit = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));

                  DELETE      sin_tramitacion
                        WHERE nsinies = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ntramit = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'SIN_TRAMITA_RESERVA' THEN
                  DELETE      sin_tramita_reserva
                        WHERE nsinies = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ntramit = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND ctipres = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovres = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'SIN_TRAMITA_AGENDA' THEN
                  DELETE      sin_tramita_agenda
                        WHERE nsinies = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ntramit = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND nlinage = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'SIN_TRAMITA_PERSONASREL' THEN
                  DELETE      sin_tramita_personasrel
                        WHERE nsinies = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ntramit = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND npersrel = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'SIN_TRAMITA_DESTINATARIO' THEN
                  DELETE      sin_tramita_destinatario
                        WHERE nsinies = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ntramit = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND sperson = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND ctipdes = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3));
               ELSIF y.ttabaxis = 'SIN_TRAMITA_PAGO' THEN
                  DELETE      sin_tramita_pago
                        WHERE sidepag = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'SIN_TRAMITA_MOVIMIENTO' THEN
                  DELETE      sin_tramita_movimiento
                        WHERE nsinies = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ntramit = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND nmovtra = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'SIN_TRAMITA_MOVPAGO' THEN
                  DELETE      sin_tramita_movpago
                        WHERE sidepag = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nmovpag = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1));
               ELSIF y.ttabaxis = 'SIN_TRAMITA_PAGO_GAR' THEN
                  DELETE      sin_tramita_pago_gar
                        WHERE sidepag = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND ctipres = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND nmovres = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2));
               ELSIF y.ttabaxis = 'GESCARTAS' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  DELETE      gescartas
                        WHERE sgescarta = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'DEVBANPRESENTADORES' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  DELETE      devbanpresentadores
                        WHERE sdevolu = TO_NUMBER(x.pkaxis);
               ELSIF y.ttabaxis = 'DEVBANORDENANTES' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  DELETE      devbanordenantes
                        WHERE sdevolu = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nnumnif = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND tsufijo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND fremesa = TO_DATE(TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis,
                                                                                1, 3)));
               ELSIF y.ttabaxis = 'DEVBANRECIBOS' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  DELETE      devbanrecibos
                        WHERE sdevolu = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nnumnif = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND tsufijo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND fremesa = TO_DATE(TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis,
                                                                                1, 3)))
                          AND crefere = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 4))
                          AND nrecibo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 5));
               ELSIF y.ttabaxis = 'DETPRIMAS' THEN
                  -- BUG 21121 - 21-02-2012 - APD
                  DELETE      detprimas
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cgarant = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3))
                          AND finiefe = TO_DATE(pac_map.f_valor_linia('|', x.pkaxis, 1, 4),
                                                'yyyymmdd')
                          AND ccampo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 5))
                          AND cconcep = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 6));
               ELSIF y.ttabaxis = 'GARANDETCAP' THEN
                  -- BUG 21121 - 21-02-2012 - APD
                  DELETE      garandetcap
                        WHERE sseguro = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 0, 1))
                          AND nriesgo = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 1))
                          AND cgarant = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 2))
                          AND nmovimi = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 3))
                          AND norden = TO_NUMBER(pac_map.f_valor_linia('|', x.pkaxis, 1, 4));
               END IF;

               v_cont := v_cont + SQL%ROWCOUNT;
               COMMIT;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_logs_axis(pncarga, 'BORRADO', 'E',
                                                 'p_borra_tabla_mig Error(0)=' || SQLCODE
                                                 || ',' || SQLERRM || '-->ttabaxis='
                                                 || y.ttabaxis || ', rwd=' || x.pkaxis);
                  ROLLBACK;
                  v_error := TRUE;
            --EXIT;
            END;
         END LOOP;

         num_err := f_ins_mig_logs_axis(pncarga, 'Borrado', 'I',
                                        y.ttabaxis || ': ' || v_cont || ' registros borrados');

         IF v_error THEN
            EXIT;
         END IF;
      END LOOP;

      IF NOT v_error THEN
         v_cont := 0;

         FOR x IN (SELECT pkmig
                     FROM mig_pk_emp_mig
                    WHERE ncarga = pncarga
                      AND ntab = pntab) LOOP
            IF g_cestado = 'DEL' THEN
               IF pttab = 'MIG_PREGUNGARANSEG' THEN
                  DELETE      mig_pregungaranseg
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_CTASEGURO_LIBRETA' THEN
                  DELETE      mig_ctaseguro_libreta
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_CTASEGURO' THEN
                  DELETE      mig_ctaseguro
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PREGUNSEG' THEN
                  DELETE      mig_pregunseg
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_AGENSEGU' THEN
                  DELETE      mig_agensegu
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PAGOSRENTA' THEN
                  DELETE      mig_pagosrenta
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SUP_DIFERIDOSSEG' THEN
                  DELETE      mig_sup_diferidosseg
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SUP_ACCIONES_DIF' THEN
                  DELETE      mig_sup_acciones_dif
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_GARANSEG' THEN
                  DELETE      mig_garanseg
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DETGARANSEG' THEN
                  DELETE      mig_detgaranseg
                        WHERE mig_pk = x.pkmig;
               --BUG:10395 - 15-06-2009 - JMC - Borrados de MIG_COMISIGARANSEG
               ELSIF pttab = 'MIG_COMISIGARANSEG' THEN
                  DELETE      mig_comisigaranseg
                        WHERE mig_pk = x.pkmig;
               --FIN BUG:10395 - 15-06-2009 - JMC
               ELSIF pttab = 'MIG_CLAUSUESP' THEN
                  DELETE      mig_clausuesp
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_RIESGOS' THEN
                  DELETE      mig_riesgos
                        WHERE mig_pk = x.pkmig;
               -- BUG : 18334 - 26-04-2011 - JMC - Carga pólizas
               ELSIF pttab = 'MIG_AUTRIESGOS' THEN
                  DELETE      mig_autriesgos
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_AUTDETRIESGOS' THEN
                  DELETE      mig_autdetriesgos
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SITRIESGO' THEN
                  DELETE      mig_sitriesgo
                        WHERE mig_pk = x.pkmig;
               -- FIN BUG : 18334 - 26-04-2011 - JMC
               ELSIF pttab = 'MIG_ASEGURADOS' THEN
                  DELETE      mig_asegurados
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_MOVSEGURO' THEN
                  DELETE      mig_movseguro
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SEGUROS' THEN
                  DELETE      mig_seguros
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_AGENTES' THEN
                  DELETE      mig_agentes
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_REPRESENTANTES' THEN
                  DELETE      mig_representantes
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_EMPLEADOS' THEN
                  DELETE      mig_empleados
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PRODIUCTOS_EMPLEADOS' THEN
                  DELETE      mig_empleados
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_TIPO_EMPLEADOS' THEN
                  DELETE      mig_empleados
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PERSONAS' THEN
                  DELETE      mig_personas
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SINIESTROS' THEN
                  DELETE      mig_siniestros
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PRESTAMOSEG' THEN
                  DELETE      mig_prestamoseg
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_VALORASINI' THEN
                  DELETE      mig_valorasini
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_TRAMITACIONSINI' THEN
                  DELETE      mig_tramitacionsini
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DESTINATARIOS' THEN
                  DELETE      mig_destinatarios
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PAGOSINI' THEN
                  DELETE      mig_pagosini
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PAGOGARANTIA' THEN
                  DELETE      mig_pagogarantia
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_RECIBOS' THEN
                  DELETE      mig_recibos
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DETRECIBOS' THEN
                  DELETE      mig_detrecibos
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_MOVRECIBO' THEN
                  DELETE      mig_movrecibo
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SEGUROS_REN_AHO' THEN
                  DELETE      mig_seguros_ren_aho
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SEGUROS_ULK' THEN
                  DELETE      mig_seguros_ulk
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_TABVALCES' THEN
                  DELETE      mig_tabvalces
                        WHERE mig_pk = x.pkmig;
               -- BUG 10054 - 22-10-2009 - JMC - Borrado de la tabla PER_PARPERSONAS
               ELSIF pttab = 'MIG_PARPERSONAS' THEN
                  DELETE      mig_parpersonas
                        WHERE mig_pk = x.pkmig;
               -- FIN BUG 10054 - 22-10-2009 - JMC
               -- BUG 15640 - 06-09-2010 - JMC - Borrado de la tabla PER_DIRECCIONES
               ELSIF pttab = 'MIG_DIRECCIONES' THEN
                  DELETE      mig_direcciones
                        WHERE mig_pk = x.pkmig;
               -- FIN BUG 15640 - 06-09-2010 - JMC
               ELSIF pttab = 'MIG_PERSONAS_REL' THEN
                  DELETE      mig_personas_rel
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_REGIMENFISCAL' THEN
                  DELETE      mig_regimenfiscal
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_VINCULOS' THEN
                  DELETE      mig_vinculos
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_SINIESTRO' THEN
                  DELETE      mig_sin_siniestro
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_MOVSINIESTRO' THEN
                  DELETE      mig_sin_movsiniestro
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITACION' THEN
                  DELETE      mig_sin_tramitacion
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_RESERVA' THEN
                  DELETE      mig_sin_tramita_reserva
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_PAGO' THEN
                  DELETE      mig_sin_tramita_pago
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_AGENDA' THEN
                  DELETE      mig_sin_tramita_agenda
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_DEST' THEN
                  DELETE      mig_sin_tramita_dest
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_MOVIMIENTO' THEN
                  DELETE      mig_sin_tramita_movimiento
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_MOVPAGO' THEN
                  DELETE      mig_sin_tramita_movpago
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_PAGO_GAR' THEN
                  DELETE      mig_sin_tramita_pago_gar
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_GESCARTAS' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  DELETE      mig_gescartas
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DEVBANPRESENTADORES' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  DELETE      mig_devbanpresentadores
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DEVBANORDENANTES' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  DELETE      mig_devbanordenantes
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DEVBANRECIBOS' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  DELETE      mig_devbanrecibos
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DETPRIMAS' THEN
                  -- BUG 21121 - 21-02-2012 - APD
                  DELETE      mig_detprimas
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_GARANDETCAP' THEN
                  -- BUG 22393 - 25-05-2012 - JMC
                  DELETE      mig_garandetcap
                        WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_GARANSEGCOM' THEN
                  -- bfp bug 21947 ini
                  DELETE      mig_garansegcom
                        WHERE mig_pk = x.pkmig;
               -- bfp bug 21947 fi
               END IF;
            ELSE
               IF pttab = 'MIG_PREGUNGARANSEG' THEN
                  UPDATE mig_pregungaranseg
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_CTASEGURO_LIBRETA' THEN
                  UPDATE mig_ctaseguro_libreta
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_CTASEGURO' THEN
                  UPDATE mig_ctaseguro
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PREGUNSEG' THEN
                  UPDATE mig_pregunseg
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_AGENSEGU' THEN
                  UPDATE mig_agensegu
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PAGOSRENTA' THEN
                  UPDATE mig_pagosrenta
                     SET sseguro = 0,
                         sperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SUP_DIFERIDOSSEG' THEN
                  UPDATE mig_sup_diferidosseg
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SUP_ACCIONES_DIF' THEN
                  UPDATE mig_sup_acciones_dif
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_GARANSEG' THEN
                  UPDATE mig_garanseg
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DETGARANSEG' THEN
                  UPDATE mig_detgaranseg
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               --BUG:10395 - 15-06-2009 - JMC - Actualización MIG_COMISIGARANSEG
               ELSIF pttab = 'MIG_COMISIGARANSEG' THEN
                  UPDATE mig_comisigaranseg
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               --FI BUG:10395 - 15-06-2009 - JMC
               --BUG:15640 - 06-09-2010 - JMC - Actualización MIG_DIRECCIONES
               ELSIF pttab = 'MIG_DIRECCIONES' THEN
                  UPDATE mig_direcciones
                     SET sperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               --FI BUG:15640 - 06-09-2010 - JMC
               ELSIF pttab = 'MIG_PERSONAS_REL' THEN
                  UPDATE mig_personas_rel
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_REGIMENFISCAL' THEN
                  UPDATE mig_regimenfiscal
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_VINCULOS' THEN
                  UPDATE mig_vinculos
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_MOVSEGURO' THEN
                  UPDATE mig_movseguro
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_CLAUSUESP' THEN
                  UPDATE mig_clausuesp
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_RIESGOS' THEN
                  UPDATE mig_riesgos
                     SET sseguro = 0,
                         sperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               -- BUG : 18334 - 26-04-2011 - JMC - Carga pólizas
               ELSIF pttab = 'MIG_AUTRIESGOS' THEN
                  UPDATE mig_autriesgos
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_AUTDETRIESGOS' THEN
                  UPDATE mig_autdetriesgos
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SITRIESGO' THEN
                  UPDATE mig_sitriesgo
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               -- FI BUG : 18334 - 26-04-2011 - JMC
               ELSIF pttab = 'MIG_ASEGURADOS' THEN
                  UPDATE mig_asegurados
                     SET sseguro = 0,
                         sperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SEGUROS' THEN
                  UPDATE mig_seguros
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_AGENTES' THEN
                  UPDATE mig_agentes
                     SET idperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_REPRESENTANTES' THEN
                  UPDATE mig_representantes
                     SET idperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_EMPLEADOS' THEN
                  UPDATE mig_empleados
                     SET idperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PRODUCTOS_EMPLEADOS' THEN
                  UPDATE mig_empleados
                     SET idperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_TIPO_EMPLEADOS' THEN
                  UPDATE mig_empleados
                     SET idperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PERSONAS' THEN
                  UPDATE mig_personas
                     SET idperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_RECIBOS' THEN
                  UPDATE mig_recibos
                     SET sseguro = 0,   --nrecibo = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DETRECIBOS' THEN
                  UPDATE mig_detrecibos
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_MOVRECIBO' THEN
                  UPDATE mig_movrecibo
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SINIESTROS' THEN
                  UPDATE mig_siniestros
                     SET sseguro = 0,
                         nsinies = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_TRAMITACIONSINI' THEN
                  UPDATE mig_tramitacionsini
                     SET nsinies = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_VALORASINI' THEN
                  UPDATE mig_valorasini
                     SET nsinies = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PAGOSINI' THEN
                  UPDATE mig_pagosini
                     SET nsinies = 0,
                         sperson = 0,
                         sidepag = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PAGOGARANTIA' THEN
                  UPDATE mig_pagogarantia
                     SET sidepag = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DESTINATARIOS' THEN
                  UPDATE mig_destinatarios
                     SET nsinies = 0,
                         sperson = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SEGUROS_ULK' THEN
                  UPDATE mig_seguros_ulk
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_PRESTAMOSEG' THEN
                  UPDATE mig_prestamoseg
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_TABVALCES' THEN
                  UPDATE mig_tabvalces
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               -- BUG 10054 - 22-10-2009 - JMC - Borrado de la tabla PER_PARPERSONAS
               ELSIF pttab = 'MIG_TABVALCES' THEN
                  UPDATE mig_parpersonas
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               -- FIN BUG 10054 - 22-10-2009 - JMC
               ELSIF pttab = 'MIG_SIN_SINIESTRO' THEN
                  UPDATE mig_sin_siniestro
                     SET cestmig = 1,
                         nsinies = 0
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_MOVSINIESTRO' THEN
                  UPDATE mig_sin_movsiniestro
                     SET cestmig = 1,
                         nsinies = 0
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITACION' THEN
                  UPDATE mig_sin_tramitacion
                     SET cestmig = 1,
                         nsinies = 0
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_MOVIMIENTO' THEN
                  UPDATE mig_sin_tramita_movimiento
                     SET cestmig = 1,
                         nsinies = 0
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_AGENDA' THEN
                  UPDATE mig_sin_tramita_agenda
                     SET cestmig = 1,
                         nsinies = 0
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_DEST' THEN
                  UPDATE mig_sin_tramita_dest
                     SET cestmig = 1,
                         nsinies = 0
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_RESERVA' THEN
                  UPDATE mig_sin_tramita_reserva
                     SET cestmig = 1,
                         nsinies = 0
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_PAGO' THEN
                  UPDATE mig_sin_tramita_pago
                     SET cestmig = 1,
                         nsinies = 0
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_MOVPAGO' THEN
                  UPDATE mig_sin_tramita_movpago
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_SIN_TRAMITA_PAGO_GAR' THEN
                  UPDATE mig_sin_tramita_pago_gar
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_GESCARTAS' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  UPDATE mig_gescartas
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DEVBANPRESENTADORES' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  UPDATE mig_devbanpresentadores
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DEVBANORDENANTES' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  UPDATE mig_devbanordenantes
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DEVBANRECIBOS' THEN
                  -- BUG 0017015 - 31-01-2011 - JMF
                  UPDATE mig_devbanrecibos
                     SET cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_DETPRIMAS' THEN
                  -- BUG 21121 - 21-02-2012 - APD
                  UPDATE mig_detprimas
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_GARANDETCAP' THEN
                  -- BUG 22393 - 25-05-2012 - JMC
                  UPDATE mig_garandetcap
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               ELSIF pttab = 'MIG_GARANSEGCOM' THEN
                  -- bfp bug 21947 ini
                  UPDATE mig_garansegcom
                     SET sseguro = 0,
                         cestmig = 1
                   WHERE mig_pk = x.pkmig;
               -- bfp bug 21947 fi
               END IF;
            END IF;

            v_cont := v_cont + SQL%ROWCOUNT;
         --         COMMIT;
         END LOOP;

         --
         v_ttexto := NULL;

         SELECT DECODE(g_cestado, 'DEL', ' borrados ', ' modificados')
           INTO v_ttexto
           FROM DUAL;

         num_err := f_ins_mig_logs_axis(pncarga, 'Borrado', 'I',
                                        pttab || ': ' || v_cont || ' registros' || v_ttexto);

         --
         --     FOR x IN (SELECT ROWID
         --                FROM mig_pk_mig_axis
         --              WHERE ncarga = pncarga
         --                AND ntab = pntab) LOOP
         DELETE      mig_pk_mig_axis
               --WHERE ROWID = x.ROWID;
         WHERE       ncarga = pncarga;

         --                AND ntab = pntab

         --      COMMIT;
         --     END LOOP;
         DELETE      mig_cargas_tab_axis
               WHERE ncarga = pncarga
                 AND ntab = pntab;

         --     COMMIT;

         --BUG:10395 - 12-06-2009 - JMC - Borramos trazas anteriores de la carga en Axis.
         IF g_cestado = 'DEL' THEN
            IF ptipo = 'M' THEN
               DELETE      mig_logs_axis
                     WHERE ncarga = pncarga
                       AND tipo <> 'I'
                       AND seqlog < v_last_seqlog;
            ELSE
               DELETE      mig_logs_axis
                     WHERE ncarga = pncarga
                       AND tipo NOT IN('E', 'W')
                       AND seqlog < v_last_seqlog;
            END IF;
         END IF;

         --FIN BUG:10395 - 12-06-2009 - JMC
         IF g_cestado = 'RET' THEN
            UPDATE mig_cargas_tab_mig
               SET finides = NULL,
                   ffindes = NULL,
                   estdes = NULL
             WHERE ncarga = pncarga
               AND ntab = pntab;
         ELSE
            --    DELETE      mig_pk_emp_mig
            --        WHERE ncarga = pncarga
            --        AND ntab = pntab;

            --BUG:10395 - 12-06-2009 - JMC - Borrar las trazas de la carga a las tablas MIG
            DELETE      mig_logs_emp
                  WHERE ncarga = pncarga;

            --FI BUG:10395 - 12-06-2009 - JMC
            DELETE      mig_cargas_tab_mig
                  WHERE ncarga = pncarga
                    AND ntab = pntab;

            DELETE      mig_cargas
                  WHERE ncarga = pncarga
                    AND NOT EXISTS(SELECT '1'
                                     FROM mig_cargas_tab_mig
                                    WHERE ncarga = pncarga);
         END IF;

         COMMIT;
      END IF;
--
   EXCEPTION
      WHEN OTHERS THEN
         num_err := f_ins_mig_logs_axis(pncarga, 'BORRADO', 'E',
                                        pncarga || '- p_borra_tabla_mig Error=' || SQLCODE
                                        || ',' || SQLERRM);
         ROLLBACK;
   END p_borra_tabla_mig;

/***************************************************************************
      PROCEDURE p_borra_cargas
      Procedimiento que determina las cargas que estan es situación de ser
      retrocedidas o borradas y lanza la función para relizar dicha acción.
         param in  pcestado:    Estado 'DEL' para borrar, 'RET' para retroceder
   ***************************************************************************/
   PROCEDURE p_borra_cargas(
      pcestado IN VARCHAR2,
      pncarga IN NUMBER,
      ptipo IN VARCHAR2 DEFAULT 'M') IS
      --Los valores de cestado son:
      --    RET  Retrocede una carga, la deja en situación para volver a ser migrada, borra solo los
      --         datos de AXIS y mantiene los datos de las tablas intermedias MIG_
      --    DEL  Elimina una carga, borra los datos que migro en AXIS, y borra los datos de las tablas
      --         intermedias MIG_
      --
      --    Para borrar o retroceder una carga, se tiene que moficar el cestdes de la tabla MIG_CARGAS_TAB_MIG
      --    con el valor DEL o RET.
      num_err        NUMBER;
      v_funcion      VARCHAR2(100);
      v_usu_context  VARCHAR2(100);
   BEGIN
      -- Bug 19689 - 05/10/2011 - JMC - Sólo si no hay usuario, inializamos contexto.
      IF f_user IS NULL THEN
         v_usu_context := f_parinstalacion_t('CONTEXT_USER');
         pac_contexto.p_contextoasignaparametro(v_usu_context, 'nombre', 'AXIS');
      END IF;

      -- Fin Bug 19689 - 05/10/2011 - JMC
      g_cestado := pcestado;
      num_err := f_ins_mig_logs_axis(0, 'BORRADO', 'I', 'Inicio Proceso');

      FOR x IN (SELECT   a.ncarga, b.ntab, b.tab_des, c.tfuncion
                    FROM mig_cargas a, mig_cargas_tab_mig b, mig_orden_axis c
                   WHERE b.ncarga = a.ncarga
                     AND b.tab_des = TRIM('MIG_' || tabla)
                     AND finides IS NOT NULL
                     AND estdes = pcestado
                     AND   --(pncarga IS NULL
                           -- OR
                        a.ncarga = pncarga
                --)
                ORDER BY norden DESC, ncarga) LOOP
         BEGIN
            IF pcestado NOT IN('DEL', 'RET') THEN
               num_err := f_ins_mig_logs_axis(x.ncarga, 'BORRADO', 'W', 'Estado Incorrecto');
            ELSE
               IF pcestado = 'DEL' THEN
                  v_funcion := 'begin pac_mig_axis.p_borra_tabla_mig (' || x.ncarga || ','
                               || x.ntab || ',''' || UPPER(x.tab_des) || ''',''' || ptipo
                               || '''); end;';

                  EXECUTE IMMEDIATE v_funcion;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_MIG_AXIS', 0, 'Error en p_borra_cargas',
                           'Error:' || SQLCODE || ',' || SQLERRM);
         END;
      END LOOP;

      num_err := f_ins_mig_logs_axis(0, 'BORRADO', 'I', 'Fin Proceso');
   END p_borra_cargas;

-- Bug 0011578 - JMF - 05-11-2009
   PROCEDURE p_mig_cesiones
-- BUG 11100 - 16/09/2009 - FAL - Afegir parametrització a Mig_cesiones
/*************************************************************************
                               param in pcempres   :   empresa.
       param in pfefecto   :   efecto movimiento
       param in pcdetrea   :   genera detall per rebut o no: (PCDETREA 0-No(defecte) / 1-Si)
       param in pctanca    :   traspassar cessions al tancament o no: (PCTANCA 0-No (defecte) 1-Si)
       param in pultmov    :   només genera les cessions del darrer moviment( pultmov = 0-NO (defecte) 1-Si)
       param in puser      :   usuario necesario para reaseguro.
       param in psproduc   :   producto a tratar si NULL todos
    *************************************************************************/
   (
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pcdetrea IN NUMBER DEFAULT 0,
      pctanca IN NUMBER DEFAULT 0,
      pultmov IN NUMBER DEFAULT 0,
      puser IN VARCHAR2,
      psproduc IN NUMBER DEFAULT NULL   --BUG:12374 - 23-12-2009 - JMC - Parámetro producto
                                     )
-- FI BUG 11100 - 16/09/2009 – FAL
/***********************************************************************************************
     NOMBRE:     MIG_CESIONES
   PROPÓSITO:  Generar cesiones de reaseguro
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   2.0        03/04/2009  XCG                1. Modificació de la funció. Utilizar la función ff_get_actividad para buscar la actividad
                                                Se trata cuando no hay datos en actividad en la tabla garanpro por la actividad = 0 BUG9685
   3.0        15/04/2009  ICV                2. 0009704: Se modifica el parametro REACUMGAR de parinstalación por REACUM en parempresa.
   4.0        16/06/2009  ETM                3. 0010462: IAX - REA - Eliminar tabla FACPENDIENTES
   5.0        03/07/2009  FAL                4. 0006329: Inserción descripción cúmulos para los idiomas definidos
   6.0        15/09/2009  FAL                5. 0011100: CRE046 - Revisión de cesionesrea. Se adapta Mig_cesiones con la versión de MVida
                                                         Afegir parametrització a Mig_cesiones
   7.0        26/10/2009  FAL                6. 0011100: CRE046 - Revisión de cesionesrea - Eliminar tabla FACPENDIENTES
   8.0        29/10/2009  JMF                7. 0011578 Incorporar proceso post-migración para la creación del último movimiento de CESIONESREA
***********************************************************************************************/
   IS
-- CANVIAR EL CURSOR PER POSAR els moviments per ordre d'emissio ?????????????????????
--SET serverout ON SIZE 1000000
--spool mig_cesiones.log
--SET serverout OFF
--SET serverout ON SIZE 1000000;
-- Procés de generació de cessions de migració NO ANULACIONS
-- Genera cesionesrea del TAR
-- i cesionesrea + reasegemi + detreasegemi de la NP de ASSP
-- Moviment que no tenim en compte
--213   Canvi de beneficiari
--215   Canvi dades del prenedor
--221   Anul.lació programada al venciment
--225   Canvi d'oficina
--228   Anul.lació de la programació al venciment
--320   Anul·lació estudi
--800   Modificació
--810   Migració CSV
--814   Sinistre per contingencia
-------------------------------------------------------------------------------------------------------
-- 2004/06/16 - JGARCIA PATCH "MV_447a"
--
-- INCIDENCIAS:
--
--   1) Redondeos por diferencias entre la forma de cáculo de AXIS y la
--      la de Mónica Lamana (March Vida), no significaron cambios en AXIS.
--   2) MIG_CESIONES - No retrocede movimiento de baja por suplementos (por ejemplo aumento de capital)
--      F_ATRAS cuando busca los movimientos a retroceder la condición "fvencim > pfinici" hace que no
--      encuentre algunos movimientos a los le ha calculado en cesionesrea una fecha de vencimiento =
--      inicio +1 mes (1 mes correspondiente a la forma de pago) y siempre debería ser un año.
-------------------------------------------------------------------------------------------------------
-- 2004/07/22 - JGARCIA PATCH : MV_484
--     Solo generamos apuntes de cesiones de los movimientos que generan recibos
--     Este cambio ya se había incluido en el p_EMITIR_PROPUESTA, pero no en MIG_CESIONES
-------------------------------------------------------------------------------------------------------
      b_error        BOOLEAN;   -- Bug 0011578 - JMF - 05-11-2009
      b_warning      BOOLEAN;   -- Bug 0011578 - JMF - 05-11-2009
      v_estadomig    mig_cargas.estorg%TYPE;

      -- Bug 0011578 - JMF - 05-11-2009
      CURSOR c_pol IS
         SELECT   sseguro, ctiprea, fvto, sproduc, cforpag, fefecto, nrenova, nmovimi,
                  cmotmov, fmovimi, cmovseg, fefecmov, tipo, cforamor, ctipseg, fdatagen
             FROM (SELECT s.sseguro, s.ctiprea,
                          DECODE(s.fcaranu, NULL, s.fvencim, s.fcaranu) fvto, s.sproduc,
                          s.cforpag, s.fefecto, s.nrenova, m.nmovimi, m.cmotmov, m.fmovimi,
                          m.cmovseg, m.fefecto fefecmov, 'E' tipo, NULL cforamor, s.ctipseg,
                          NVL(m.femisio, m.fmovimi) fdatagen
                     FROM seguros s, movseguro m
                    WHERE   --s.cramo = 30 AND s.sproduc IN (3,4,5,6)
                          --AND
                          -- BUG 11100 - 16/09/2009 - FAL - Afegir parametrització a Mig_cesiones
                          m.fefecto >= pfefecto
                      AND s.cempres = pcempres
                      -- FI BUG 11100 - 16/09/2009 – FAL
                      AND s.csituac < 7
                      AND s.sseguro = m.sseguro
                      AND m.femisio IS NOT NULL
                      -- Los movimientos estan emitidos
                      AND s.csituac NOT IN(4)
                      AND DECODE(s.fcaranu, NULL, s.fvencim, s.fcaranu) > m.fefecto
                      --INI BUG:12374 - 23-12-2009 - JMC - Parámetro producto
                      AND(psproduc IS NULL
                          OR s.sproduc = psproduc)
                      --FIN BUG:12374 - 23-12-2009 - JMC
                      AND pac_anulacion.f_anulada_al_emitir(s.sseguro) = 0
                      AND NOT EXISTS(SELECT sseguro
                                       FROM cesionesrea ce
                                      WHERE ce.sseguro = s.sseguro
                                        AND DECODE(ce.cgenera,
                                                   6, 0,
                                                   (SELECT MAX(a.nmovimi)
                                                      FROM cesionesrea a
                                                     WHERE a.sseguro = ce.sseguro
                                                       AND a.nmovigen = ce.nmovigen)) =
                                                             DECODE(m.cmovseg,
                                                                    3, 0,
                                                                    m.nmovimi)
                                        AND ce.fefecto = m.fefecto)
                      -- JGR - 22-07-2004 Solo los movimientos que generan recibos
                      AND EXISTS(SELECT cgenrec
                                   FROM codimotmov c
                                  WHERE c.cmotmov = m.cmotmov
                                    AND(c.cgenrec = 1
                                        OR c.cmovseg IN(3, 4)))
                      AND EXISTS(SELECT nmovimi
                                   FROM garanseg g
                                  WHERE g.sseguro = m.sseguro
                                    AND g.nmovimi = DECODE(m.cmovseg, 3, 1, m.nmovimi))
                      AND m.nmovimi >= (SELECT NVL(MIN(nmovimi), 0)
                                          -- A partir de la renovació del 2002
                                        FROM   movseguro m2
                                         WHERE m2.sseguro = m.sseguro
                                           --AND fefecto >= '01/01/2004'
                                           --AND fefecto <'01/12/2004'
                                           AND m2.cmovseg IN(0, 2))
                   --        and s.sseguro = 104871
                   UNION ALL
                   SELECT s.sseguro, s.ctiprea,
                          TO_DATE(TO_CHAR(nfila + 2004 + 1) || LPAD(s.nrenova, 4, '0'),
                                  'yyyymmdd') fvto,
                          s.sproduc, s.cforpag, s.fefecto, s.nrenova,
                          (SELECT MAX(nmovimi)
                             FROM garanseg m
                            WHERE m.sseguro = s.sseguro) nmovimi, 404,
                          TO_DATE(TO_CHAR(nfila + 2004) || LPAD(s.nrenova, 4, '0'),
                                  'yyyymmdd') fmovimi,
                          2 cmovseg,
                          TO_DATE(TO_CHAR(nfila + 2004) || LPAD(s.nrenova, 4, '0'),
                                  'yyyymmdd') fefecmov,
                          'E' tipo, NULL cforamor, s.ctipseg,
                          TO_DATE(TO_CHAR(nfila + 2004) || LPAD(s.nrenova, 4, '0'),
                                  'yyyymmdd') fdatagen
                     FROM seguros s, int_filas f
                    WHERE ((csituac = 5)
                           OR(creteni = 0
                              AND csituac NOT IN(7, 8, 9, 10)))
                      AND s.cempres = pcempres
                      --INI BUG:12374 - 23-12-2009 - JMC - Parámetro producto
                      AND(psproduc IS NULL
                          OR s.sproduc = psproduc)
                      --FIN BUG:12374 - 23-12-2009 - JMC
                      AND NOT EXISTS(SELECT 1
                                       FROM cesionesrea c
                                      WHERE cgenera IN(3, 5)
                                        AND c.sseguro = s.sseguro
                                        AND TO_CHAR(fvencim, 'yyyy') = TO_CHAR(nfila + 2004)
                                                                       + 1)
                      AND(fvencim > TO_DATE(TO_CHAR(nfila + 2004) || LPAD(s.nrenova, 4, '0'),
                                            'yyyymmdd')
                          OR fvencim IS NULL)
                      AND f_parproductos_v(sproduc, 'REASEGURO') = 1
                      -- Reaseguro a la renovación
                      AND s.cforpag = 0
                      AND s.ctiprea <> 2
                      AND s.fefecto < TO_DATE(TO_CHAR(nfila + 2004) || LPAD(s.nrenova, 4, '0'),
                                              'yyyymmdd')
                      AND(s.fanulac > TO_DATE(TO_CHAR(nfila + 2004) || LPAD(s.nrenova, 4, '0'),
                                              'yyyymmdd')
                          OR s.fanulac IS NULL)
                      AND f_sysdate > TO_DATE(TO_CHAR(nfila + 2004) || LPAD(s.nrenova, 4, '0'),
                                              'yyyymmdd')
                      AND s.femisio IS NOT NULL
                                               --        and s.sseguro = 104871
                  ) c
         ORDER BY GREATEST(NVL((SELECT
-- BUG 11100 - 16/09/2009 - FAL - Ordenació per emissió del moviment per generar cúmuls en ordre correcte
--MAX(m2.fefecto)
                                       MAX(m2.femisio)
                                  -- FI BUG 11100 - 16/09/2009 – FAL
                                FROM   movseguro m2
                                 WHERE m2.sseguro = c.sseguro
                                   AND m2.nmovimi < c.nmovimi), TRUNC(c.fmovimi)),
                           c.fdatagen),
                  c.sseguro, c.nmovimi;

      CURSOR c_ries(wsseguro NUMBER) IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = wsseguro
            AND fanulac IS NULL;

      i              NUMBER := 0;
      lnmovi_vig     NUMBER;
      ltexto         VARCHAR2(120);
      nprolin        NUMBER;
      lmotiu         NUMBER;
      lfini          DATE;
      lffi           DATE;
      lsfacult       NUMBER;
      num_err        NUMBER := 0;
      lorigen        NUMBER;
      ldetces        NUMBER;
      lsproces       NUMBER;
      lcforamor      NUMBER;
      lmeses         NUMBER;
      dd             VARCHAR2(2);
      lfaux          DATE;
      ddmm           VARCHAR2(4);
      l_c            NUMBER;
      cumulo         NUMBER;
      ldatafi        DATE;
      amortit        pk_cuadro_amortizacion.t_amortizacion;
      pimporte       NUMBER;
      lfefecto_ini   DATE;
      wfcontab       DATE := TO_DATE('01/01/1900', 'dd/mm/yyyy');
      -- ini bug 0011578 Incorporar proceso post-migración para la creación del último movimiento de CESIONESREA
      pncarga        mig_cargas_tab_mig.ncarga%TYPE;
      v_maxmov       NUMBER;

-- ctiprea = V.Fixe 60
-- ( El ctiprea = 2 (No es reassegura) es mira també desde la funció
--  f_buscatrrea , però si ho mirem aquí ens estalviem accessos)
-- 0 = Normal
-- 1 = Mai facultatiu
-- 2 = No es reassegura
-- 3 = No calculi facultatiu opcionalment(en aquesta emissio),
--      després es posa a 0 = Normal
-- 5 = No s'aturi encara que existeixi el quadre de facultatiu (acceptat)
------------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
      FUNCTION f_num_proces(puser VARCHAR2, psproces IN OUT NUMBER)
         RETURN NUMBER IS
         num_err        NUMBER := 0;
      BEGIN
          /*
            psproces := psproces + 1;
         --   IF psproces <=315208 THEN
         BEGIN
            INSERT INTO procesoscab
                        (sproces, cempres, cusuari, cproces, tproces, fproini,
                         fprofin, nerror)
                 VALUES (psproces, pcempres, puser, 'MIGRACIO', 'Generació de cessions', f_sysdate,
                         NULL, 0);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
            WHEN OTHERS THEN
               --DBMS_OUTPUT.PUT_LINE ('787878:'||SQLERRM); --> BORRAR JGR
               RETURN 787878;
         END;
         */
          --   ELSE
          --      psproces := 2;

         -- ini bug 0011578 canvi func local per a que funcioni a proves.
         num_err := f_procesini(puser, pcempres, 'MIGRACIO', 'Generació de cessions',
                                psproces);
         --   END IF;
         RETURN num_err;
      END f_num_proces;

------------------------------------------------------------------------------
-----------------------------------------------------------------------------
      PROCEDURE mig_ces_rec(psproces IN NUMBER, psseguro IN NUMBER, pnmovimi IN NUMBER) IS
         CURSOR c_reb(wsseguro NUMBER, wnmovimi NUMBER) IS
            SELECT DISTINCT c.sseguro, r.nrecibo, r.fefecto, r.fvencim, r.cforpag, s.cramo,
                            s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.fcaranu,
                            s.fefecto fefepol
                       FROM cesionesrea c, recibos r, seguros s
                      WHERE r.sseguro = wsseguro
                        AND r.nmovimi = wnmovimi
                        AND c.sseguro = s.sseguro
                        AND c.sseguro = r.sseguro
                        AND c.sproces = psproces;

         --        AND s.cramo = 30;
         --        AND (s.cramo = 30 AND s.cmodali = 1 AND s.ctipseg = 4);
         -- ASSP No va per rebut OR (s.cramo = 15 AND s.cmodali = 1 AND s.ctipseg = 3 AND r.ctiprec = 0));
         CURSOR c_mov(wnrecibo NUMBER) IS
            SELECT   *
                FROM movrecibo
               WHERE nrecibo = wnrecibo
                 AND((cestrec = 0
                      AND cestant = 0)
                     OR cestrec = 2)
            ORDER BY fmovdia;

         -- BUG 17106 - 27/12/2010 - JMP - Se añade este 'ORDER BY'
         lcprorra       NUMBER;
         lcmodulo       NUMBER;
         ldifdias       NUMBER;
         ldifdiasanu    NUMBER;
         ldifdias2      NUMBER;
         ldifdiasanu2   NUMBER;
         lfanyoprox     DATE;
         ldivisor2      NUMBER;
         ldivisor       NUMBER;
         lfacces        NUMBER;
         lffinany       DATE;
         lfiniany       DATE;
         num_err        NUMBER;
         ltexto         VARCHAR2(120);
      BEGIN
         FOR v_reb IN c_reb(psseguro, pnmovimi) LOOP
            FOR v_mov IN c_mov(v_reb.nrecibo) LOOP
               -- calcula la cessio
               IF v_mov.cestrec = 0 THEN   -- Emissió
-------------------------
------------------------
                  BEGIN
                     SELECT cprorra
                       INTO lcprorra
                       FROM productos
                      WHERE cramo = v_reb.cramo
                        AND cmodali = v_reb.cmodali
                        AND ctipseg = v_reb.ctipseg
                        AND ccolect = v_reb.ccolect;
                  EXCEPTION
                     WHEN OTHERS THEN
                        --DBMS_OUTPUT.PUT_LINE('Error a productos '||SQLERRM);
                        NULL;
                  END;

                  lfanyoprox := ADD_MONTHS(v_reb.fefecto, 12);

                  -- Cálculo de días
                  IF lcprorra = 2 THEN   -- Mod. 360
                     lcmodulo := 3;
                  ELSE   -- Mod. 365
                     lcmodulo := 1;
                  END IF;

                  num_err := f_difdata(v_reb.fefecto, v_reb.fvencim, 3, 3, ldifdias);

                  IF num_err <> 0 THEN
                     --DBMS_OUTPUT.PUT_LINE(' Error difdata reb '||v_reb.nrecibo||'-'|| num_err);
                     p_literal2(num_err, 1, ltexto);
                     num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E', ltexto);
                  --COMMIT;
                  END IF;

                  BEGIN
                     SELECT fefecto
                       INTO lfiniany
                       FROM movseguro
                      WHERE sseguro = v_reb.sseguro
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM movseguro m
                                        WHERE sseguro = v_reb.sseguro
                                          --AND cmovseg IN (0,2)
                                          --AND cmotmov NOT IN (286,213,215,221,225,228,320,800,810,814)
                                          -- JGR - 22-07-2004 Solo los movimientos que generan recibos
                                          AND EXISTS(
                                                  SELECT cgenrec
                                                    FROM codimotmov c
                                                   WHERE c.cmotmov = m.cmotmov
                                                     AND c.cgenrec = 1)
                                          AND fefecto <= v_reb.fefecto);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        lfiniany := v_reb.fefepol;
                  END;

                  --DBMS_OUTPUT.put_line('MIG_CES_REC - 04 - REBUT:'||v_reb.nrecibo||' lfiniany:'||lfiniany); --> BORRAR JGR
                  BEGIN
                     SELECT fefecto
                       INTO lffinany
                       FROM movseguro
                      WHERE sseguro = v_reb.sseguro
                        AND nmovimi = (SELECT MIN(nmovimi)
                                         FROM movseguro
                                        WHERE sseguro = v_reb.sseguro
                                          AND cmovseg = 2
                                          AND fefecto > v_reb.fefecto);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        lffinany := v_reb.fcaranu;
                  END;

                  lffinany := NVL(lffinany, v_reb.fvencim);   --> BORRAR JGR
                  num_err := f_difdata(lfiniany, lffinany, 3, 3, ldifdiasanu);

                  IF num_err <> 0 THEN
                     p_literal2(num_err, 1, ltexto);
                     num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E', ltexto);
                  --COMMIT;
                  END IF;

                  num_err := f_difdata(v_reb.fefecto, v_reb.fvencim, lcmodulo, 3, ldifdias2);

                  -- dias recibo
                  IF num_err <> 0 THEN
                     p_literal2(num_err, 1, ltexto);
                     num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E', ltexto);
                  --COMMIT;
                  END IF;

                  num_err := f_difdata(lfiniany, lffinany, lcmodulo, 3, ldifdiasanu2);

                  -- dias venta
                  IF num_err <> 0 THEN
                     p_literal2(num_err, 1, ltexto);
                     num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E', ltexto);
                  --COMMIT;
                  END IF;

                  num_err := f_difdata(v_reb.fefecto, lfanyoprox, lcmodulo, 3, ldivisor2);

                  -- divisor del módulo de suplementos para pagos anuales
                  IF num_err <> 0 THEN
                     p_literal2(num_err, 1, ltexto);
                     num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E', ltexto);
                  --COMMIT;
                  END IF;

                  -- Els anys de traspàs han de prorratejar com un any normal, és a dir a 365
                  IF ldivisor2 = 366 THEN
                     ldivisor2 := 365;
                  END IF;

                  num_err := f_difdata(v_reb.fefepol, v_reb.fvencim, lcmodulo, 3, ldivisor);

                  -- divisor del periodo para pago único
                  IF num_err <> 0 THEN
                     p_literal2(num_err, 1, ltexto);
                     num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E', ltexto);
                  --COMMIT;
                  END IF;

                  -- Calculem els factors a aplicar per prorratejar
                  -- També el factor per la reassegurança = diesrebut/dies cessio
                  --p_control_Error('MIG_CESIONES','REA','MIG_CES_REC - 07 - REBUT:'||v_reb.nrecibo||' lcprorra:'||lcprorra); --> BORRAR JGR
                  IF lcprorra IN(1, 2) THEN   -- Per dies
                     --p_control_Error('MIG_CESIONES','REA','MIG_CES_REC - 08 - REBUT:'||v_reb.nrecibo||' lcprorra:'||v_reb.cforpag); --> BORRAR JGR
                     IF v_reb.cforpag <> 0 THEN
                        --p_control_Error('MIG_CESIONES','REA','MIG_CES_REC - 09 - REBUT:'||v_reb.nrecibo||' ldifdias:'||ldifdias); --> BORRAR JGR
                        IF MOD(ldifdias, 30) = 0 THEN
                           -- No hi ha prorrata
                           lfacces := ldifdias / ldifdiasanu;
                        ELSE
                           lfacces := ldifdias2 / ldifdiasanu2;
                        END IF;
                     ELSE
                        lfacces := ldifdias2 / ldifdiasanu2;
                     -- lfacces      := 1;
                     END IF;
                  END IF;

-------------------------
------------------------
                  num_err := pac_cesionesrea.f_cessio_det(psproces, v_reb.sseguro,
                                                          v_reb.nrecibo, v_reb.cactivi,
                                                          v_reb.cramo, v_reb.cmodali,
                                                          v_reb.ctipseg, v_reb.ccolect,
                                                          v_reb.fefecto, v_reb.fvencim,
                                                          lfacces, 1, 1);

                  -- BUG 11100 - 16/09/2009 - FAL - Afegir parametrització a Mig_cesiones
                  IF num_err = 0 THEN
                     IF pctanca = 0 THEN   -- pcdetrea = 1 ya que estamos en mig_ces_rec
                        BEGIN
                           UPDATE reasegemi
                              SET fcierre = wfcontab
                            WHERE sproces = psproces
                              AND fcierre IS NULL;
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_literal2(151144, 1, ltexto);
                              num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E',
                                                             ltexto || '-' || SQLERRM);
                        END;
                     ELSE
                        BEGIN
                           UPDATE reasegemi
                              SET fgenera = fefecte
                            WHERE sproces = psproces
                              AND fcierre IS NULL;
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_literal2(151144, 1, ltexto);
                              num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E',
                                                             ltexto || '-' || SQLERRM);
                        END;
                     END IF;
                  END IF;
               -- FI BUG 11100 - 16/09/2009 – FAL
               ELSIF v_mov.cestrec = 2 THEN   -- Anul.lació
                  num_err := pac_cesionesrea.f_cesdet_anu(v_reb.nrecibo);

                  -- BUG 11100 - 16/09/2009 - FAL - Afegir parametrització a Mig_cesiones
                  IF num_err = 0 THEN
                     IF pctanca = 0 THEN   -- pcdetrea = 1 ya que estamos en mig_ces_rec
                        BEGIN
                           UPDATE reasegemi
                              SET fcierre = wfcontab
                            WHERE nrecibo = v_reb.nrecibo
                              AND fcierre IS NULL;
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_literal2(151144, 1, ltexto);
                              num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E',
                                                             ltexto || '-' || SQLERRM);
                        END;
                     ELSE
                        BEGIN
                           UPDATE reasegemi
                              SET fgenera = fefecte
                            WHERE sproces = psproces
                              AND fcierre IS NULL;
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_literal2(151144, 1, ltexto);
                              num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E',
                                                             ltexto || '-' || SQLERRM);
                        END;
                     END IF;
                  END IF;

                  -- FI BUG 11100 - 16/09/2009 – FAL
                  IF num_err <> 0 THEN
                     --DBMS_OUTPUT.PUT_LINE(' Error pac_cesionesrea  '||v_reb.nrecibo||'-'|| num_err);
                     p_literal2(num_err, 1, ltexto);
                     num_err := f_ins_mig_logs_axis(pncarga, v_reb.sseguro, 'E', ltexto);
                  --COMMIT;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
      END mig_ces_rec;

----------------------------------------------------------------------------
------------------------------------------------------------------------------
      PROCEDURE calcula_cessions_rea(
         psseguro IN NUMBER,
         pctiprea IN NUMBER,
         pdataini IN DATE,
         pdatafi IN DATE,
         psproces IN NUMBER,
         pmoneda IN NUMBER,
         pcidioma IN NUMBER) IS
         lnmovimi       NUMBER;
         ltexto         VARCHAR2(100);
         nprolin        NUMBER;
         pfecha         DATE;
         num_err        NUMBER;
      BEGIN
         --p_control_Error ('REASEGURO 1ER TRIMESTRE','REA','000-SEG:'||psseguro||' sproces:'||psproces||' motiu:(5) origen:(2) fini:'||pdataini||' ffi:'||pdatafi||' num_Err:'||num_Err); --> BORRAR JGR
         -- ( El ctiprea = 2 (No es reassegura) es mira també desde la funció
         --  f_buscatrrea , però si ho mirem aquí ens estalviem accessos)
         IF pctiprea <> 2 THEN
            -- motiu  = 5
            -- origen = 2 - Q. amortització
            SELECT MAX(nmovimi)
              INTO lnmovimi
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = 1
               AND cgarant IN(1, 2)
               AND(finiefe <= pdataini
                   AND(ffinefe IS NULL
                       OR ffinefe > pdataini));

            num_err := f_buscactrrea(psseguro, lnmovimi, psproces, 5, pmoneda, 2, pdataini,
                                     pdatafi);

            IF num_err <> 0
               OR num_err = 99 THEN
               -- missatge d'error no s'ha calculat la cessió
               p_literal2(num_err, 1, ltexto);
               num_err := f_ins_mig_logs_axis(pncarga, psseguro, 'E', ltexto);
            --COMMIT;
            ELSE
               num_err := f_cessio(psproces, 5, pmoneda, pdataini);

               IF num_err <> 0
                  OR num_err = 99 THEN
                  p_literal2(num_err, 1, ltexto);
                  num_err := f_ins_mig_logs_axis(pncarga, psseguro, 'E', ltexto);
               --COMMIT;
               ELSE
                  --crida al detall del periode
                  num_err := pac_cesionesrea.f_cessio_det_per(psseguro, pdataini, pdatafi,
                                                              psproces);

                  IF num_err <> 0 THEN
                     p_literal2(num_err, 1, ltexto);
                     num_err := f_ins_mig_logs_axis(pncarga, psseguro, 'E', ltexto);
                  --COMMIT;
                  END IF;
--nunu
--------------------------------------------------
-- Sempre que hi hagi canvis en una pòlissa d'un cúmul, recalcularem totes les pòlisses
-- d'aquest cúmul
--------------------------------------------------
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            --DBMS_OUTPUT.PUT_LINE(SQLERRM);
            NULL;
      END calcula_cessions_rea;
----------------------------------------------------------------------------
-- INICI
----------------------------------------------------------------------------
   BEGIN
      pac_iax_login.p_iax_iniconnect(puser);
      -- ini bug 0011578 Incorporar proceso post-migración para la creación del último movimiento de CESIONESREA
      pncarga := pac_mig_axis.f_next_carga;
      pac_mig_axis.p_crea_migcargas(pncarga, pcempres);
      pac_mig_axis.p_crea_migcargastabmig(pncarga, 1, 'P_POST_INSTALACION_REA',
                                          'P_MIG_CESIONES');
      b_error := FALSE;
      b_warning := FALSE;
      v_estadomig := NULL;
      num_err := f_ins_mig_cargas_tab_axis(pncarga, 1, 1, 'CESIONESREA');
      num_err := f_ins_mig_cargas_tab_axis(pncarga, 1, 2, 'CUAFACUL');
      num_err := f_ins_mig_cargas_tab_axis(pncarga, 1, 3, 'REASEGEMI');
      num_err := f_ins_mig_cargas_tab_axis(pncarga, 1, 4, 'DETREASEGEMI');
      num_err := f_ins_mig_cargas_tab_axis(pncarga, 1, 5, 'CUMULOS');
      num_err := f_ins_mig_cargas_tab_axis(pncarga, 1, 6, 'DESCUMULOS');
      num_err := f_ins_mig_cargas_tab_axis(pncarga, 1, 7, 'REARIESGOS');
      -- fin bug 0011578 Incorporar proceso post-migración para la creación del último movimiento de CESIONESREA
      num_err := f_num_proces(f_user, lsproces);

      --   DBMS_OUTPUT.put_line('INICIO');
      FOR v_pol IN c_pol LOOP
         --      DBMS_OUTPUT.put_line('v_pol.sseguro: ' || v_pol.sseguro);
         num_err := f_proceslin(lsproces, 'inici ' || v_pol.sseguro || ':' || v_pol.nmovimi,
                                v_pol.sseguro, nprolin);
         -- ini bug 0011578 Incorporar proceso post-migración para la creación del último movimiento de CESIONESREA
         v_maxmov := v_pol.nmovimi;

         IF pultmov = 1 THEN
            BEGIN
               SELECT MAX(nmovimi)
                 INTO v_maxmov
                 FROM movseguro
                WHERE sseguro = v_pol.sseguro
                  AND cmovseg IN(0, 2);
            -- 12030 AVT 26-11-2009 a partir del darrer moviment de renovació o alta
            EXCEPTION
               WHEN OTHERS THEN
                  b_error := TRUE;
                  p_literal2(104349, 1, ltexto);
                  num_err := f_ins_mig_logs_axis(pncarga,
                                                 v_pol.sseguro || ':' || v_pol.nmovimi, 'E',
                                                 ltexto);
            END;
         END IF;

         IF v_maxmov = v_pol.nmovimi THEN   --> continuem perque ja estem al darrer moviment
            -- fin bug 0011578 Incorporar proceso post-migración para la creación del último movimiento de CESIONESREA

            -- Primer mirarem si és a facpendientes, pq no fagi cap més moviment
            -- de la mateixa pòlissa

            -- BUG 11100 - 26/10/2009 - FAL - Eliminar tabla FACPENDIENTES
                  /*
                           BEGIN
                     SELECT COUNT(f.sseguro)
                       INTO l_c
                       FROM facpendientes f, cuafacul c
                      WHERE f.sseguro = v_pol.sseguro
                        AND f.sfacult = c.sfacult
                        AND c.cestado = 1;
                  EXCEPTION
                     WHEN OTHERS THEN
            --            DBMS_OUTPUT.put_line(' ERROR al comptar a facpendientes ' || SQLERRM);
                        num_err := f_ins_mig_logs_axis(pncarga, v_pol.sseguro||':'||v_pol.nmovimi, 'E', 'Error al comptar facpendientes' );
                  --COMMIT;
                  END;
                  */
            BEGIN
               SELECT COUNT(c.sseguro)
                 INTO l_c
                 FROM cuafacul c
                WHERE c.sseguro = v_pol.sseguro
                  AND c.cestado = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT COUNT(c.sseguro)
                    INTO l_c
                    FROM cuafacul c, reariesgos r
                   WHERE c.scumulo = r.scumulo
                     AND r.sseguro = v_pol.sseguro
                     AND c.cestado = 1;
               WHEN OTHERS THEN
                  b_error := TRUE;
                  p_literal2(num_err, 104486, ltexto);
                  num_err := f_ins_mig_logs_axis(pncarga,
                                                 v_pol.sseguro || ':' || v_pol.nmovimi, 'E',
                                                 ltexto);
            END;

            -- FI BUG 11100 - 16/09/2009 – FAL

            --      DBMS_OUTPUT.put_line(' FACPENDIENTES ' || l_c);
            num_err := 0;

------------------------------------
--- Primer mirarem si és anul. o no pq tenen tractament diferent
------------------------------------
------------------------------------
--      DBMS_OUTPUT.put_line('000a-SEG:' || v_pol.sseguro || ' v_pol.tipo:' || v_pol.tipo
--                           || ' l_c:' || l_c || ' Antes del IF');   --> BORRAR JGR
            IF l_c = 0 THEN
               IF v_pol.tipo = 'E' THEN   -- 'E'-Emissio 'Q'-Quadre amortit
                  IF v_pol.cmovseg = 3 THEN
                     -- anulació ---
                     num_err := f_atras(lsproces, v_pol.sseguro, v_pol.fefecmov, 6, 1,
                                        v_pol.nmovimi, v_pol.fdatagen);

                     -- BUG 11100 - 16/09/2009 - FAL - Afegir parametrització a Mig_cesiones
                     IF num_err = 0 THEN
                        IF pctanca = 0 THEN
                           BEGIN
                              UPDATE cesionesrea
                                 SET fcontab = wfcontab
                               WHERE sproces = lsproces
                                 AND fcontab IS NULL;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 b_error := TRUE;
                                 p_literal2(104859, 1, ltexto);
                                 num_err := f_ins_mig_logs_axis(pncarga,
                                                                v_pol.sseguro || ':'
                                                                || v_pol.nmovimi,
                                                                'E', ltexto);
                           END;
                        END IF;
                     END IF;

                     -- FI BUG 11100 - 16/09/2009 – FAL

                     --               DBMS_OUTPUT.put_line('CPM F_atras num_err=' || num_err);
                     IF num_err = 0 THEN
                        FOR i IN c_ries(v_pol.sseguro) LOOP
                           BEGIN
                              SELECT scumulo
                                INTO cumulo
                                FROM reariesgos
                               WHERE sseguro = v_pol.sseguro
                                 AND nriesgo = i.nriesgo
                                 AND freafin IS NULL;

                              IF cumulo IS NOT NULL THEN
                                 num_err := f_bajacu(v_pol.sseguro, v_pol.fefecmov);

                                 --                           DBMS_OUTPUT.put_line('CPM F_bajacu num_err=' || num_err);
                                 IF num_err = 0 THEN
                                    num_err := f_cumulo(lsproces, cumulo, v_pol.fefecmov, 1,
                                                        1, NULL);

                                    --                              DBMS_OUTPUT.put_line('CPM F_cumulo num_err=' || num_err);
                                    IF num_err <> 0 THEN
                                       b_warning := TRUE;
                                       p_literal2(num_err, 1, ltexto);
                                       num_err :=
                                          f_ins_mig_logs_axis(pncarga,
                                                              v_pol.sseguro || ':'
                                                              || v_pol.nmovimi,
                                                              'W', ltexto);
                                    --COMMIT;
                                    --                                 DBMS_OUTPUT.put_line('Error ' || v_pol.sseguro
                                    --                                                      || ' num_err = ' || num_err);
                                    END IF;
                                 ELSE
                                    b_warning := TRUE;
                                    p_literal2(num_err, 1, ltexto);
                                    num_err := f_ins_mig_logs_axis(pncarga,
                                                                   v_pol.sseguro || ':'
                                                                   || v_pol.nmovimi,
                                                                   'W', ltexto);
                                 --COMMIT;
                                 --                              DBMS_OUTPUT.put_line('Error ' || v_pol.sseguro || ' num_err = '
                                 --                                                   || num_err);
                                 END IF;
                              END IF;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 NULL;
                              WHEN OTHERS THEN
                                 b_error := TRUE;
                                 num_err := f_ins_mig_logs_axis(pncarga,
                                                                v_pol.sseguro || ':'
                                                                || v_pol.nmovimi,
                                                                'E', 'Error al buscar cumul');
                           END;
                        END LOOP;
                     ELSE
                        b_error := TRUE;
                        p_literal2(num_err, 1, ltexto);
                        num_err := f_ins_mig_logs_axis(pncarga,
                                                       v_pol.sseguro || ':' || v_pol.nmovimi,
                                                       'E', ltexto);
                     END IF;
                  ELSIF v_pol.cmovseg = 4 THEN   -- Rehabiliatció
                     -- buscamos el último movimiento vigente
                     SELECT MAX(nmovimi)
                       INTO lnmovi_vig
                       FROM movseguro
                      WHERE sseguro = v_pol.sseguro
                        AND nmovimi < v_pol.nmovimi
                        AND cmovseg <> 3;   -- no anulació

                     lorigen := 1;
                     lfini := v_pol.fefecmov;

                     BEGIN
                        -- moviment de renovació posterior a l'actual per saber la data de fi
                        -- de la cessió actual
                        SELECT fefecto
                          INTO lffi
                          FROM movseguro
                         WHERE sseguro = v_pol.sseguro
                           AND nmovimi = (SELECT MIN(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = v_pol.sseguro
                                             AND nmovimi > v_pol.nmovimi
                                             AND cmovseg = 2);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           lffi := v_pol.fvto;
                        WHEN OTHERS THEN
                           b_error := TRUE;
                           num_err := f_ins_mig_logs_axis(pncarga,
                                                          v_pol.sseguro || ':'
                                                          || v_pol.nmovimi,
                                                          'E', 'Error movseguro ');
                           num_err := -1;
                     END;

                     --               DBMS_OUTPUT.put_line(' F_BUSCACTRREA *****************************(1)');   --> BORRAR JGR
                     num_err := f_buscactrrea(v_pol.sseguro, lnmovi_vig, lsproces, 9, 1,
                                              lorigen, lfini, lffi);

                     IF num_err <> 0
                        AND num_err <> 99 THEN
                        b_warning := TRUE;
                        p_literal2(num_err, 1, ltexto);
                        num_err := f_ins_mig_logs_axis(pncarga,
                                                       v_pol.sseguro || ':' || v_pol.nmovimi,
                                                       'W', ltexto);
                     --COMMIT;
                     ELSIF num_err = 99 THEN
                        NULL;   -- no hay cesión al reaseguro
                     ELSE
                        num_err := f_cessio(lsproces, 9, 1, v_pol.fdatagen);

                        -- BUG 11100 - 16/09/2009 - FAL - Afegir parametrització a Mig_cesiones
                        IF num_err = 0 THEN
                           IF pctanca = 0 THEN
                              BEGIN
                                 UPDATE cesionesrea
                                    SET fcontab = wfcontab
                                  WHERE sproces = lsproces
                                    AND fcontab IS NULL;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    b_error := TRUE;
                                    p_literal2(104859, 1, ltexto);
                                    num_err := f_ins_mig_logs_axis(pncarga,
                                                                   v_pol.sseguro || ':'
                                                                   || v_pol.nmovimi,
                                                                   'E',
                                                                   ltexto || '-' || SQLERRM);
                              END;
                           END IF;
                        END IF;

                        -- FI BUG 11100 - 16/09/2009 – FAL
                        IF num_err <> 0
                           AND num_err <> 99 THEN
                           --ROLLBACK;
                           b_warning := TRUE;
                           p_literal2(num_err, 1, ltexto);
                           num_err := f_ins_mig_logs_axis(pncarga,
                                                          v_pol.sseguro || ':'
                                                          || v_pol.nmovimi,
                                                          'W', ltexto);
                        --COMMIT;
                        ELSIF num_err = 99 THEN
                           --p_control_Error ('REASEGURO 1ER TRIMESTRE','REA','04-SEG:'||v_pol.sseguro||' nmovimi:'||v_pol.nmovimi||' sproces:'||lsproces||' motiu:'||lmotiu||' origen:'||lorigen||' fini:'||lfini||' ffi:'||lffi||' num_Err:'||num_Err); --> BORRAR JGR
                           b_warning := TRUE;
                           num_err := 105382;
                           p_literal2(num_err, 1, ltexto);
                           num_err := f_ins_mig_logs_axis(pncarga,
                                                          v_pol.sseguro || ':'
                                                          || v_pol.nmovimi,
                                                          'W', ltexto);
                        --COMMIT;
                        END IF;
                     --nununu num_err := pac_cesionesrea.f_recalcula_cumul(v_pol.sseguro, lfini, lsproces );
                     END IF;
                  ELSE   -- altres moviments
                     -- Cal obtenir les dates d'inici i final de cessió
                     lfini := v_pol.fefecmov;

                     IF v_pol.ctipseg = 3 THEN
                        BEGIN
                           SELECT DECODE(cforamor, 0, v_pol.cforpag, cforamor)
                             INTO lcforamor
                             FROM seguros_assp
                            WHERE sseguro = v_pol.sseguro;

                           --IF NVL(lcforamor,0) = 0 THEN DBMS_OUTPUT.PUT_LINE('DIVISOR CERO: lcforamor='||lcforamor); END IF; --> BORRAR JGR
                           lffi := ADD_MONTHS(lfini, 12 / lcforamor);
                        EXCEPTION
                           WHEN OTHERS THEN
                              lffi := v_pol.fvto;
                        END;
                     ELSE
                        BEGIN
                           -- moviment de renovació posterior a l'actual per saber la data de fi
                           -- de la cessió actual
                           SELECT fefecto
                             INTO lffi
                             FROM movseguro
                            WHERE sseguro = v_pol.sseguro
                              AND nmovimi = (SELECT MIN(nmovimi)
                                               FROM movseguro
                                              WHERE sseguro = v_pol.sseguro
                                                AND nmovimi > v_pol.nmovimi
                                                AND cmovseg = 2);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              lffi := v_pol.fvto;
                           WHEN OTHERS THEN
                              b_error := TRUE;
                              num_err := f_ins_mig_logs_axis(pncarga,
                                                             v_pol.sseguro || ':'
                                                             || v_pol.nmovimi,
                                                             'E', 'Error movseguro ');
                              num_err := -1;
                        END;
                     END IF;

                     IF num_err = 0 THEN
                        IF v_pol.ctiprea <> 2 THEN
                           IF v_pol.cmotmov = 100 THEN   -- Nova producció
                              lmotiu := 3;
                           --- V.Fixe 128 (3 = Nova producció)
                           ELSIF v_pol.cmovseg = 2 THEN   -- Renovació
                              lmotiu := 5;
                           ELSE   -- Suplemento
                              -- lmotiu = V.Fixe 128 ( Tipus de registre a cessionesrea)
                              lmotiu := 4;   --Suplemento normal...

                              IF v_pol.ctiprea NOT IN(5, 1, 3) THEN
                                 -- Suplement amb facultatiu: es té d'aturar...
                                 BEGIN   --
                                    SELECT sfacult
                                      INTO lsfacult
                                      FROM cuafacul
                                     WHERE sseguro = v_pol.sseguro
                                       AND finicuf <= lfini
                                       AND(ffincuf > lfini
                                           OR ffincuf IS NULL);

                                    num_err := 107439;   -- 'Parar facultativo';
                                    --ROLLBACK;
                                    b_error := TRUE;
                                    p_literal2(num_err, 1, ltexto);
                                    num_err := f_ins_mig_logs_axis(pncarga,
                                                                   v_pol.sseguro || ':'
                                                                   || v_pol.nmovimi,
                                                                   'E', ltexto);
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                       NULL;
                                    WHEN TOO_MANY_ROWS THEN
                                       num_err := 107439;
                                       --                                 DBMS_OUTPUT.put_line('    masses registres cuafacul ');
                                       --ROLLBACK;
                                       p_literal2(num_err, 1, ltexto);
                                       b_error := TRUE;
                                       num_err :=
                                          f_ins_mig_logs_axis(pncarga,
                                                              v_pol.sseguro || ':'
                                                              || v_pol.nmovimi,
                                                              'E', ltexto);
                                    --COMMIT;
                                    WHEN OTHERS THEN
                                       --                                 DBMS_OUTPUT.put_line('    Altres cuafacul ' || SQLERRM);
                                       b_error := TRUE;
                                       num_err := 107518;
                                       p_literal2(num_err, 1, ltexto);
                                       num_err :=
                                          f_ins_mig_logs_axis(pncarga,
                                                              v_pol.sseguro || ':'
                                                              || v_pol.nmovimi,
                                                              'E', ltexto);
                                 --COMMIT;
                                 END;
                              END IF;
                           END IF;

                           IF num_err = 0 THEN
                              lorigen := 1;
                              ldetces := NULL;
                              num_err := f_parproductos(v_pol.sproduc, 'REASEGURO', ldetces);

                              -- CPM 1/3/06: Controlem les pòlisses de P.U. doncs reaseguren anualment
                              IF lmotiu = 3
                                 OR(v_pol.cforpag = 0
                                    AND lmotiu <> 5) THEN
                                 IF NVL(ldetces, 1) = 2 THEN
                                    -- Q. amort.
                                    lorigen := 2;
                                    --IF  v_pol.cforpag = 0 THEN
                                    -- A nova producció si és prima única i es calcularà
                                    -- els propers periodes a q. amortització, es fa
                                    -- la cessió segons  cforamor
                                    -- lcforamor calculat més amunt
                                    --                              DBMS_OUTPUT.put_line('DIVISOR: lcforamor=' || lcforamor);
                                    lmeses := 12 / lcforamor;
                                    dd := '31';
                                    lfaux := TO_DATE('31/12/'
                                                     || TO_CHAR(v_pol.fefecto, 'yyyy'),
                                                     'dd/mm/yyyy');

                                    IF LAST_DAY(lfini) = lfini
                                       AND MOD(TO_NUMBER(TO_CHAR(lfini, 'mm')), 12 / lcforamor) =
                                                                                              0 THEN
                                       lffi := lfini;
                                    ELSE
                                       BEGIN
                                          WHILE TRUE LOOP
                                             lfaux := f_summeses(lfaux, -lmeses, dd);

                                             IF lfaux <= v_pol.fefecto THEN
                                                lffi := f_summeses(lfaux, lmeses, dd);
                                                EXIT;
                                             END IF;
                                          END LOOP;
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             b_error := TRUE;
                                             num_err :=
                                                f_ins_mig_logs_axis(pncarga,
                                                                    v_pol.sseguro || ':'
                                                                    || v_pol.nmovimi,
                                                                    'E',
                                                                    'ERROR f_summeses 1 ');
                                       END;
                                    END IF;
                                 ELSE
                                    lmeses := 12;   --> JGR  PATCH "MV_447a"
                                    --END IF;                     --> JGR  PATCH "MV_447a"
                                    dd := SUBSTR(LPAD(v_pol.nrenova, 4, 0), 3, 2);
                                    ddmm := dd || SUBSTR(LPAD(v_pol.nrenova, 4, 0), 1, 2);
                                    --lfaux := TO_DATE(ddmm ||TO_CHAR(v_pol.fcaran, 'YYYY'),'DDMMYYYY');
                                    lfaux := v_pol.fvto;

                                    IF LAST_DAY(lfini) = lfini
                                       AND MOD(TO_NUMBER(TO_CHAR(lfini, 'mm')), 12 / lcforamor) =
                                                                                              0 THEN
                                       lffi := lfini;
                                    ELSE
                                       BEGIN
                                          WHILE TRUE LOOP
                                             lfaux := f_summeses(lfaux, -lmeses, dd);

                                             IF lfaux <= v_pol.fefecto THEN
                                                lffi := f_summeses(lfaux, lmeses, dd);
                                                EXIT;
                                             END IF;
                                          END LOOP;
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             b_error := TRUE;
                                             num_err :=
                                                f_ins_mig_logs_axis(pncarga,
                                                                    v_pol.sseguro || ':'
                                                                    || v_pol.nmovimi,
                                                                    'E',
                                                                    'ERROR f_summeses 2 ');
                                       END;
                                    END IF;
                                 END IF;
                              --                           DBMS_OUTPUT.put_line('          data fi NOVA '
                              --                                                || TO_CHAR(lffi, 'dd/mm/yyyy'));
                              END IF;

                              --                        DBMS_OUTPUT.put_line
                              --                                       ('004-SEG:' || v_pol.sseguro
                              --                                        || ' F_BUSCACTRREA *************************(2), lffi='
                              --                                        || lffi);   --> BORRAR JGR
                              --                        DBMS_OUTPUT.put_line('004-SEG:' || v_pol.nmovimi || '-' || lsproces
                              --                                             || '-' || lmotiu || '-' || lorigen || '-' || lfini
                              --                                             || '-' || lffi);   --> BORRAR JGR
                              --                        DBMS_OUTPUT.put_line('antes de F_Buscactrrea, num_err: ' || num_err);
                              num_err := f_buscactrrea(v_pol.sseguro, v_pol.nmovimi, lsproces,
                                                       lmotiu, 1, lorigen, lfini, lffi);

                              --                        DBMS_OUTPUT.put_line('despues de F_Buscactrrea, num_err: ' || num_err);
                              IF num_err <> 0
                                 AND num_err <> 99 THEN
                                 b_error := TRUE;
                                 p_literal2(num_err, 1, ltexto);
                                 num_err := f_ins_mig_logs_axis(pncarga,
                                                                v_pol.sseguro || ':'
                                                                || v_pol.nmovimi,
                                                                'E', ltexto);
                              ELSIF num_err = 99 THEN
                                 -- no troba contracte ???
                                 num_err := 0;
                              ELSE
                                 num_err := f_cessio(lsproces, lmotiu, 1, v_pol.fdatagen);

                                 -- BUG 11100 - 16/09/2009 - FAL - Afegir parametrització a Mig_cesiones
                                 IF num_err = 0 THEN
                                    IF pctanca = 0 THEN
                                       BEGIN
                                          UPDATE cesionesrea
                                             SET fcontab = wfcontab
                                           WHERE sproces = lsproces
                                             AND fcontab IS NULL;
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             b_error := TRUE;
                                             p_literal2(104859, 1, ltexto);
                                             num_err :=
                                                f_ins_mig_logs_axis(pncarga,
                                                                    v_pol.sseguro || ':'
                                                                    || v_pol.nmovimi,
                                                                    'E', ltexto);
                                       END;
                                    END IF;
                                 END IF;

                                 -- FI BUG 11100 - 16/09/2009 – FAL
                                 IF num_err <> 0
                                    AND num_err <> 99 THEN
                                    --                              DBMS_OUTPUT.put_line('      f_cessio ' || num_err);
                                    --ROLLBACK;
                                    b_error := TRUE;
                                    p_literal2(num_err, 1, ltexto);
                                    num_err := f_ins_mig_logs_axis(pncarga,
                                                                   v_pol.sseguro || ':'
                                                                   || v_pol.nmovimi,
                                                                   'E', ltexto);
                                 --COMMIT;
                                 ELSIF num_err = 99 THEN
                                    num_err := 105382;   --No te facultatiu
                                    --COMMIT;
                                    b_error := TRUE;
                                    p_literal2(num_err, 1, ltexto);
                                    num_err := f_ins_mig_logs_axis(pncarga,
                                                                   v_pol.sseguro || ':'
                                                                   || v_pol.nmovimi,
                                                                   'E', ltexto);
                                 --COMMIT;

                                 --IF v_pol.cmotmov <> 298 THEN -- No es suspensió de pòlissa
                                 -- no emet el suplement, queda en proposta
                                 --DBMS_OUTPUT.put_line('    Facultatiu pendent d''emetre');
                                 --END IF;

                                 --COMMIT;
                                 ELSE
                                    -- Si és emissio d una pòlissa que es reassegura en
                                    -- el q.amortització :Cal calcular el detall de cessions
                                    -- pel periode de la emissió
                                    IF NVL(lorigen, 1) = 2 THEN
                                       num_err :=
                                          pac_cesionesrea.f_cessio_det_per(v_pol.sseguro,
                                                                           lfini, lffi,
                                                                           lsproces);

                                       -- BUG 11100 - 16/09/2009 - FAL - Afegir parametrització a Mig_cesiones
                                       IF num_err = 0 THEN
                                          IF pctanca = 0
                                             AND pcdetrea = 1 THEN
                                             BEGIN
                                                UPDATE reasegemi
                                                   SET fcierre = wfcontab
                                                 WHERE sproces = lsproces
                                                   AND fcierre IS NULL;
                                             EXCEPTION
                                                WHEN OTHERS THEN
                                                   b_error := TRUE;
                                                   p_literal2(151144, 1, ltexto);
                                                   num_err :=
                                                      f_ins_mig_logs_axis(pncarga,
                                                                          v_pol.sseguro || ':'
                                                                          || v_pol.nmovimi,
                                                                          'E',
                                                                          ltexto || '-'
                                                                          || SQLERRM);
                                             END;
                                          ELSE
                                             BEGIN
                                                UPDATE reasegemi
                                                   SET fgenera = fefecte
                                                 WHERE sproces = lsproces
                                                   AND fcierre IS NULL;
                                             EXCEPTION
                                                WHEN OTHERS THEN
                                                   p_literal2(151144, 1, ltexto);
                                                   num_err :=
                                                      f_ins_mig_logs_axis(pncarga,
                                                                          v_pol.sseguro, 'E',
                                                                          ltexto || '-'
                                                                          || SQLERRM);
                                             END;
                                          END IF;
                                       END IF;

                                       -- FI BUG 11100 - 16/09/2009 – FAL
                                       IF num_err <> 0 THEN
                                          b_error := TRUE;
                                          p_literal2(num_err, 1, ltexto);
                                          num_err :=
                                             f_ins_mig_logs_axis(pncarga,
                                                                 v_pol.sseguro || ':'
                                                                 || v_pol.nmovimi,
                                                                 'E', ltexto);
                                       --COMMIT;
                                       END IF;
                                    END IF;
                                 END IF;
                              END IF;
                           ELSE
                              b_error := TRUE;
                              p_literal2(num_err, 1, ltexto);
                              num_err := f_ins_mig_logs_axis(pncarga,
                                                             v_pol.sseguro || ':'
                                                             || v_pol.nmovimi,
                                                             'E', ltexto);
                           END IF;
                        END IF;
                     ELSE
                        b_error := TRUE;
                        p_literal2(num_err, 1, ltexto);
                        num_err := f_ins_mig_logs_axis(pncarga,
                                                       v_pol.sseguro || ':' || v_pol.nmovimi,
                                                       'E', ltexto);
                     END IF;
                  END IF;
               ELSE   -- 'Q' quadre amortitz
------------------------------------------------------------------
-- Quadre d'amortització
------------------------------------------------------------------
-- Cridem al càlcul de cessions de la reassegurança
--IF NVL(v_pol.cforamor,0) = 0 THEN DBMS_OUTPUT.PUT_LINE('DIVISOR: v_pol.cforamor='||v_pol.cforamor); END IF; --> BORRAR JGR
                  ldatafi := ADD_MONTHS(v_pol.fmovimi, 12 / v_pol.cforamor);

                  -- update
                  SELECT ADD_MONTHS(TRUNC(LAST_DAY(v_pol.fefecto), 'YYYY'),
                                    (12 / v_pol.cforamor)
                                    * CEIL(TO_NUMBER(TO_CHAR(LAST_DAY(v_pol.fefecto), 'MM'))
                                           * v_pol.cforamor / 12))
                         - 1
                    INTO lfefecto_ini
                    FROM DUAL;

                  pk_cuadro_amortizacion.calcular_cuadro(v_pol.sseguro, lfefecto_ini);

                  --pk_CUADRO_AMORTIZACION.pinta_cuadro;
                  FOR i IN 1 .. 2000 LOOP
                     pk_cuadro_amortizacion.ver_mensajes(i, amortit);
                     pimporte := amortit.pendiente;

                     IF amortit.famort >= TRUNC(v_pol.fmovimi) THEN
                        EXIT;
                     END IF;
                  END LOOP;

                  --Updategem les garanties de mort i d'ivalidesa
                  UPDATE garanseg
                     SET icapital = pimporte,
                         icaptot = pimporte
                   WHERE sseguro = v_pol.sseguro
                     AND nriesgo = 1
                     AND cgarant IN(1, 2)
                     AND(finiefe <= v_pol.fmovimi
                         AND(ffinefe IS NULL
                             OR ffinefe > v_pol.fmovimi));

                  calcula_cessions_rea(v_pol.sseguro, v_pol.ctiprea, v_pol.fmovimi, ldatafi,
                                       lsproces, 1, 1);
               --COMMIT;
               END IF;
            END IF;

            --- Fem les cessions dels rebuts del moviment
            --      DBMS_OUTPUT.put_line('v_pol.tipo: ' || v_pol.tipo);

            -- BUG 11100 - 16/09/2009 - FAL - Afegir parametrització a Mig_cesiones
            --IF v_pol.tipo = 'E' THEN
            IF pcdetrea = 1 THEN
               -- FI BUG 11100 - 16/09/2009 – FAL
               mig_ces_rec(lsproces, v_pol.sseguro, v_pol.nmovimi);
            END IF;

            --      DELETE /*+ RULE  FROM TMP_GARANCAR WHERE sproces = lsproces;
            --      DELETE /*+ RULE  FROM PREGUNCAR    WHERE sproces = lsproces;
            --COMMIT;
            i := i + 1;

            IF i > 100 THEN
               COMMIT;
               i := 0;
            END IF;
         END IF;
      -- fin bug 0011578 final condición.
      END LOOP;

      num_err := f_procesfin(lsproces, 0);

      --   DBMS_OUTPUT.put_line('FIN');

      -- ini Bug 0011578 - JMF - 05-11-2009 Actualizar estado migración.
      IF b_error THEN
         v_estadomig := 'ERROR';
      ELSIF b_warning THEN
         v_estadomig := 'WARNING';
      ELSE
         v_estadomig := 'OK';
      END IF;

      pac_mig_axis.p_act_migcargastabmig(pncarga, 1, 'P_POST_INSTALACION_REA',
                                         'P_MIG_CESIONES', v_estadomig);
      -- fin Bug 0011578 - JMF - 05-11-2009 Actualizar estado migración.
      COMMIT;
   END p_mig_cesiones;

-- fin Bug 0011578 - JMF - 05-11-2009

   -- ini Bug 0011578 - JMF - 05-11-2009
   PROCEDURE p_post_instalacion_rea
                                   /***************************************************************************
                                                                PROCEDURE P_POST_INSTALACION_REA
                                                                Procedimiento que lanza tareas a realizar en la migración de cesiones.
                                                                    param in pcempres   :   empresa.
                                                                    param in pfefecto   :   efecto movimiento
                                                                    param in pcdetrea   :   genera detall per rebut o no: (PCDETREA 0-No(defecte) / 1-Si)
                                                                    param in pctanca    :   traspassar cessions al tancament o no: (PCTANCA 0-No (defecte) 1-Si)
                                                                    param in pultmov    :   només genera les cessions del darrer moviment( pultmov = 0-NO (defecte) 1-Si)
                                                                    param in puser      :   usuario necesario para reaseguro.
                                                                    param in psproduc   :   producto a tratar si NULL todos
                                                            ***************************************************************************/
   (
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pcdetrea IN NUMBER DEFAULT 0,
      pctanca IN NUMBER DEFAULT 0,
      pultmov IN NUMBER DEFAULT 0,
      puser IN VARCHAR2,
      psproduc IN NUMBER DEFAULT NULL   --BUG:12374 - 23-12-2009 - JMC - Parámetro producto
                                     ) IS
   BEGIN
      -- Generar cesiones de reaseguro
      p_mig_cesiones(pcempres, pfefecto, pcdetrea, pctanca, pultmov, puser, psproduc);
      p_mig_pagos_ces(pcempres, pfefecto, puser, psproduc);   -- BUG: JMF 12620
   END p_post_instalacion_rea;

-- fin Bug 0011578 - JMF - 05-11-2009
   PROCEDURE p_mig_pagos_ces
                            /*************************************************************************
                                                      param in pcempres   :   empresa.
                                                      param in pfefecto   :   efecto movimiento
                                                      param in puser      :   usuario necesario para reaseguro.
                                                      param in psproduc   :   producto a tratar si NULL todos
                                                   *************************************************************************/
   (
      pcempres IN NUMBER,
      pfefecto IN DATE,
      puser IN VARCHAR2,
      psproduc IN NUMBER DEFAULT NULL) IS
      num_err        NUMBER;
      psproces       NUMBER;
      num_err2       NUMBER;
      nprolin        NUMBER;
      b_error        BOOLEAN;
      b_warning      BOOLEAN;
      v_estadomig    mig_cargas.estorg%TYPE;
      pncarga        mig_cargas_tab_mig.ncarga%TYPE;
      ltexto         VARCHAR2(100);

      CURSOR c1 IS
         SELECT se.sseguro, p.sidepag, cmonpag, s.nsinies, ctippag, fefepag
           FROM seguros se, sin_siniestro s, sin_tramita_pago p, sin_tramita_movpago m
          WHERE s.sseguro = se.sseguro
            AND se.cempres = pcempres
            AND s.nsinies = p.nsinies
            AND p.sidepag = m.sidepag
            AND fsinies >= pfefecto
            AND(psproduc IS NULL
                OR se.sproduc = psproduc)
            AND m.cestpag = 2;
   BEGIN
      pac_iax_login.p_iax_iniconnect(puser);
      pncarga := pac_mig_axis.f_next_carga;
      pac_mig_axis.p_crea_migcargas(pncarga, pcempres);
      pac_mig_axis.p_crea_migcargastabmig(pncarga, 1, 'P_POST_INSTALACION_REA',
                                          'P_MIG_PAGOS_CES');
      b_error := FALSE;
      b_warning := FALSE;
      v_estadomig := NULL;
      num_err := f_ins_mig_cargas_tab_axis(pncarga, 1, 1, 'CESIONESREA');
      num_err := f_ins_mig_cargas_tab_axis(pncarga, 1, 2, 'PAGOSSINCES');
      num_err := f_procesini(puser, pcempres, 'MIGRACIO', 'Generació de pagos cessions',
                             psproces);

      FOR f1 IN c1 LOOP
         num_err := pac_siniestros.f_sin_rea(f1.sidepag, f1.cmonpag, f1.nsinies, f1.ctippag,
                                             f1.fefepag);
         num_err2 := f_proceslin(psproces, 'sin=' || f1.nsinies || ' err=' || num_err,
                                 f1.sseguro, nprolin);

         IF NVL(num_err, 0) <> 0 THEN
            b_error := TRUE;
            p_literal2(num_err, 1, ltexto);
            num_err := pac_mig_axis.f_ins_mig_logs_axis(pncarga, f1.nsinies, 'E', ltexto);
         END IF;
      END LOOP;

      num_err2 := f_procesfin(psproces, 0);

      IF b_error THEN
         v_estadomig := 'ERROR';
      ELSIF b_warning THEN
         v_estadomig := 'WARNING';
      ELSE
         v_estadomig := 'OK';
      END IF;

      pac_mig_axis.p_act_migcargastabmig(pncarga, 1, 'P_POST_INSTALACION_REA',
                                         'P_MIG_PAGOS_CES', v_estadomig);
      COMMIT;
   END p_mig_pagos_ces;

-- fin BUG 0012620 - 11/01/2010 - JMF - CEM - REA cessions de pagaments al procés de migració

   -- ini Bug 0011364 - ICV - 05-01-2010
/***************************************************************************
      FUNCTION f_migra_depositarias_axis
      Función que inserta los registros grabados en MIG_depositarias, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_depositarias(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_depositarias BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_depositarias depositarias%ROWTYPE;
      v_cont         NUMBER;
      v_ccoddep      depositarias.ccoddep%TYPE;
      v_sperson      per_personas.sperson%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*
                    FROM mig_depositarias a
                   WHERE a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_depositarias THEN
               v_1_depositarias := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'DEPOSITARIAS');
            END IF;

            v_error := FALSE;
            v_depositarias := NULL;

            SELECT coddepositarias_seq.NEXTVAL
              INTO v_ccoddep
              FROM DUAL;

            v_depositarias.ccoddep := v_ccoddep;
            v_depositarias.falta := TRUNC(f_sysdate);
            v_depositarias.fbaja := NULL;

            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM per_personas
                WHERE nnumide = x.mig_fk;
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  SELECT MAX(sperson)
                    INTO v_sperson
                    FROM per_personas
                   WHERE nnumide = x.mig_fk;
            END;

            v_depositarias.sperson := v_sperson;
            v_depositarias.cbanco := x.cbanco;

            INSERT INTO depositarias
                 VALUES v_depositarias;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_depositarias.ccoddep);

            UPDATE mig_depositarias
               SET ccoddep = v_depositarias.ccoddep,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_depositarias;

/***************************************************************************
       FUNCTION f_migra_planpensiones_axis
       Función que inserta los registros grabados en planpensiones, en la tabla
       SIN_SINIESTRO de AXIS.
          param in  pncarga:     Número de carga.
          param in  pntab:       Número de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_planpensiones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_planpensiones BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_planpensiones planpensiones%ROWTYPE;
      v_cont         NUMBER;
      v_ccodpla      planpensiones.ccodpla%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT DISTINCT a.*, b.ccodfon c_codfon
                           FROM mig_planpensiones a, mig_fonpensiones b
                          WHERE a.ncarga = pncarga
                            AND a.cestmig = 1
                            AND a.mig_fk = b.mig_pk
                       ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_planpensiones THEN
               v_1_planpensiones := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'PLANPENSIONES');
            END IF;

            v_error := FALSE;
            v_planpensiones := NULL;

            SELECT codplanpensiones_seq.NEXTVAL
              INTO v_ccodpla
              FROM DUAL;

            v_planpensiones.ccodpla := v_ccodpla;
            v_planpensiones.tnompla := x.tnompla;
            v_planpensiones.faltare := TRUNC(f_sysdate);
            v_planpensiones.fadmisi := TRUNC(f_sysdate);
            v_planpensiones.cmodali := 1;
            v_planpensiones.csistem := 1;
            v_planpensiones.ccodfon := x.c_codfon;
            --Insertado ya en mig_planpensiones cuando se pasen mig_fondos???
            v_planpensiones.ccomerc := NULL;
            v_planpensiones.icomdep := NULL;
            v_planpensiones.icomges := NULL;
            v_planpensiones.cmespag := NULL;
            v_planpensiones.ctipren := NULL;
            v_planpensiones.cperiod := NULL;
            v_planpensiones.ivalorl := NULL;
            v_planpensiones.clapla := NULL;
            v_planpensiones.npartot := NULL;
            v_planpensiones.coddgs := x.mig_pk;
            --v_planpensiones.CCODSN := null;
            v_planpensiones.fbajare := NULL;

            INSERT INTO planpensiones
                 VALUES v_planpensiones;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_planpensiones.ccodpla);

            UPDATE mig_planpensiones
               SET ccodpla = v_planpensiones.ccodpla,
                   ccodfon = v_planpensiones.ccodfon,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_planpensiones;

/***************************************************************************
      FUNCTION f_migra_fonpensiones_axis
      Función que inserta los registros grabados en MIG_fonpensiones, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_fonpensiones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_fonpensiones BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_fonpensiones fonpensiones%ROWTYPE;
      v_cont         NUMBER;
      v_ccodfon      fonpensiones.ccodfon%TYPE;
      v_sperson      per_personas.sperson%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT DISTINCT a.*, b.ccodges c_codges
                           FROM mig_fonpensiones a, mig_gestoras b
                          WHERE a.ncarga = pncarga
                            AND a.cestmig = 1
                            AND a.mig_fk = b.mig_pk
                       ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_fonpensiones THEN
               v_1_fonpensiones := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'FONPENSIONES');
            END IF;

            v_error := FALSE;
            v_fonpensiones := NULL;

            SELECT codfonpensiones_seq.NEXTVAL
              INTO v_ccodfon
              FROM DUAL;

            v_fonpensiones.ccodfon := v_ccodfon;
            v_fonpensiones.faltare := TRUNC(f_sysdate);

            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM per_personas
                WHERE nnumide = x.nnumide;
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  SELECT MAX(sperson)
                    INTO v_sperson
                    FROM per_personas
                   WHERE nnumide = x.nnumide;
            END;

            v_fonpensiones.sperson := v_sperson;
            v_fonpensiones.ccodges := x.c_codges;
            v_fonpensiones.spertit := NULL;
            v_fonpensiones.fbajare := NULL;
            v_fonpensiones.ntomo := NULL;
            v_fonpensiones.nfolio := NULL;
            v_fonpensiones.nhoja := NULL;
            v_fonpensiones.cbancar := x.ccc;
            v_fonpensiones.ccomerc := NULL;
            v_fonpensiones.clafon := NULL;
            v_fonpensiones.ctipban := 1;
            v_fonpensiones.coddgs := x.mig_pk;

            INSERT INTO fonpensiones
                 VALUES v_fonpensiones;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_fonpensiones.ccodfon);

            UPDATE mig_fonpensiones
               SET ccodfon = v_fonpensiones.ccodfon,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_fonpensiones;

/***************************************************************************
      FUNCTION f_migra_gestoras_axis
      Función que inserta los registros grabados en MIG_gestoras, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_gestoras(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_gestoras   BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_gestoras     gestoras%ROWTYPE;
      v_cont         NUMBER;
      v_ccodges      gestoras.ccodges%TYPE;
      v_sperson      per_personas.sperson%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT DISTINCT a.*
                           FROM mig_gestoras a
                          WHERE a.ncarga = pncarga
                            AND a.cestmig = 1
                       ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_gestoras THEN
               v_1_gestoras := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'GESTORAS');
            END IF;

            v_error := FALSE;
            v_gestoras := NULL;

            SELECT codgestoras_seq.NEXTVAL
              INTO v_ccodges
              FROM DUAL;

            v_gestoras.ccodges := v_ccodges;
            v_gestoras.falta := TRUNC(f_sysdate);
            v_gestoras.fbaja := NULL;
            v_gestoras.fbaja := NULL;
            v_gestoras.cbanco := NULL;
            v_gestoras.coficin := NULL;
            v_gestoras.cdc := NULL;
            v_gestoras.ncuenta := NULL;
            v_gestoras.spertit := NULL;
            --v_gestoras.ccoddep := NULL;
            v_gestoras.coddgs := x.mig_pk;

            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM per_personas
                WHERE nnumide = x.nnumide;
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  SELECT MAX(sperson)
                    INTO v_sperson
                    FROM per_personas
                   WHERE nnumide = x.nnumide;
            END;

            v_gestoras.sperson := v_sperson;

            INSERT INTO gestoras
                 VALUES v_gestoras;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_gestoras.ccodges);

            UPDATE mig_gestoras
               SET ccodges = v_gestoras.ccodges,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_gestoras;

/***************************************************************************
      FUNCTION f_migra_aseguradoras_axis
      Función que inserta los registros grabados en MIG_aseguradoras, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_aseguradoras(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_aseguradoras BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_aseguradoras aseguradoras%ROWTYPE;
      v_cont         NUMBER;
      v_ccodaseg     aseguradoras.ccodaseg%TYPE;
      v_sperson      per_personas.sperson%TYPE;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*
                    FROM mig_aseguradoras a
                   WHERE a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_aseguradoras THEN
               v_1_aseguradoras := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'ASEGURADORAS');
            END IF;

            v_error := FALSE;
            v_aseguradoras := NULL;

            SELECT codaseguradoras_seq.NEXTVAL
              INTO v_ccodaseg
              FROM DUAL;

            v_aseguradoras.ccodaseg := v_ccodaseg;
            v_aseguradoras.ccodban := SUBSTR(x.cbancar, 1, 4);
            v_aseguradoras.cbancar := x.cbancar;

            --Obtenemos la empresa
            SELECT cempres
              INTO v_cempres
              FROM mig_cargas
             WHERE ncarga = pncarga;

            v_aseguradoras.cempres := v_cempres;
            v_aseguradoras.ccoddep := NULL;
            v_aseguradoras.coddgs := x.mig_pk;
            v_aseguradoras.ctipban := 1;

            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM per_personas
                WHERE nnumide = x.nnumide;
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  SELECT MAX(sperson)
                    INTO v_sperson
                    FROM per_personas
                   WHERE nnumide = x.nnumide;
            END;

            v_aseguradoras.sperson := v_sperson;

            INSERT INTO aseguradoras
                 VALUES v_aseguradoras;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_aseguradoras.ccodaseg);

            UPDATE mig_aseguradoras
               SET ccodaseg = v_aseguradoras.ccodaseg,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_aseguradoras;

/***************************************************************************
      FUNCTION f_migra_planpensiones_axis
      Función que inserta los registros grabados en aseguradoras_planes, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_aseguradoras_planes(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_aseguradoras_planes BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_aseguradoras_planes aseguradoras_planes%ROWTYPE;
      v_cont         NUMBER;
      v_ccodigo      aseguradoras_planes.ccodigo%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, b.ccodaseg c_codaseg
                    FROM mig_aseguradoras_planes a, mig_aseguradoras b
                   WHERE a.ncarga = pncarga
                     AND a.cestmig = 1
                     AND a.mig_fk = b.mig_pk
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_aseguradoras_planes THEN
               v_1_aseguradoras_planes := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'ASEGURADORAS_PLANES');
            END IF;

            v_error := FALSE;
            v_aseguradoras_planes := NULL;
            --select CODASEG_PLANES_SEQ.nextval into v_ccodigo from dual;
            v_aseguradoras_planes.ccodigo := 1;
            --Contador de planes por aseguradora
            v_aseguradoras_planes.tnombre := x.tnombre;
            v_aseguradoras_planes.coddgs := x.mig_pk;
            v_aseguradoras_planes.ccodaseg := x.c_codaseg;

            INSERT INTO aseguradoras_planes
                 VALUES v_aseguradoras_planes;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_aseguradoras_planes.ccodaseg || '|' || v_aseguradoras_planes.ccodigo);

            UPDATE mig_aseguradoras_planes
               SET ccodaseg = v_aseguradoras_planes.ccodaseg,
                   ccodigo = v_aseguradoras_planes.ccodigo,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_aseguradoras_planes;

-- fin Bug 0011364 - ICV - 05-01-2010
-- BUG 0015640 - 06-09-2010 - JMC - Función para la migración de la tabla PER_DIRECCIONES
/***************************************************************************
      FUNCTION f_migra_direcciones
      Función que inserta los registros grabados en MIG_DIRECCIONES, en la tabla
      PER_DIRECCIONES de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_direcciones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL',
      pmig_pk IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_1_direc      BOOLEAN := TRUE;
      v_direc        per_direcciones%ROWTYPE;
      v_cont         NUMBER;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_sperson      estper_personas.spereal%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      --  COMMIT;
      FOR x IN (SELECT   a.*, p.idperson s_sperson, p.mig_pk mig_pk_per
                    FROM mig_direcciones a, mig_personas p
                   WHERE p.mig_pk = a.mig_fk
                     AND p.mig_pk = NVL(pmig_pk, p.mig_pk)
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_direc THEN
               v_1_direc := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -8, 'PER_DIRECCIONES');
            END IF;

            -- primero valido que este creada
            IF ptablas = 'EST' THEN
               SELECT spereal
                 INTO v_sperson
                 FROM estper_personas
                WHERE sperson = x.s_sperson;
            ELSE
               v_sperson := x.s_sperson;
            END IF;

            v_direc := NULL;
            v_direc.tdomici := pac_persona.f_tdomici(x.csiglas, x.tnomvia, x.nnumvia,
                                                     x.tcomple, x.cviavp, x.clitvp, x.cbisvp,
                                                     x.corvp, x.nviaadco, x.clitco, x.corco,
                                                     x.nplacaco, x.cor2co, x.cdet1ia,
                                                     x.tnum1ia, x.cdet2ia, x.tnum2ia,
                                                     x.cdet3ia, x.tnum3ia, x.localidad);
            v_direc.cdomici := pac_persona.f_existe_direccion(v_sperson, NVL(x.cagente, '1'),
                                                              x.ctipdir, x.csiglas, x.tnomvia,
                                                              x.nnumvia, x.tcomple,

                                                              /*  pac_persona.f_tdomici(x.csiglas, x.tnomvia,
                                                                                      x.nnumvia, x.tcomple,
                                                                                      x.cviavp, x.clitvp,
                                                                                      x.cbisvp, x.corvp,
                                                                                      x.nviaadco, x.clitco,
                                                                                      x.corco, x.nplacaco,
                                                                                      x.cor2co, x.cdet1ia,
                                                                                      x.tnum1ia, x.cdet2ia,
                                                                                      x.tnum2ia, x.cdet3ia,
                                                                                      x.tnum3ia, x.localidad ), */
                                                              v_direc.tdomici,
                                                              UPPER(x.cpostal), x.cpoblac,
                                                              x.cprovin);

            IF v_direc.cdomici IS NULL
               AND ptablas = 'EST' THEN   -- miro que la dire no este ya en las EST
               --
               SELECT MIN(cdomici)
                 INTO v_direc.cdomici
                 FROM estper_direcciones
                WHERE sperson = x.s_sperson
                  AND cagente = NVL(x.cagente, '1')
                  AND ctipdir = x.ctipdir
                  AND NVL(csiglas, -1) = NVL(x.csiglas, -1)
                  AND NVL(tnomvia, '-1') = NVL(x.tnomvia, '-1')
                  AND NVL(nnumvia, -1) = NVL(x.nnumvia, -1)
                  AND NVL(tcomple, '-1') = NVL(x.tcomple, '-1')
                  AND NVL(tdomici, '-1') = NVL(v_direc.tdomici, '-1')
                  AND NVL(cpostal, '-1') = NVL(UPPER(x.cpostal), '-1')
                  AND NVL(cpoblac, -1) = NVL(x.cpoblac, -1)
                  AND NVL(cprovin, -1) = NVL(x.cprovin, -1);
            --
            END IF;

            IF v_direc.cdomici IS NULL THEN
               v_error := FALSE;

               --
               IF ptablas = 'EST' THEN
                  SELECT NVL(MAX(e.cdomici), 0)
                    INTO v_direc.cdomici
                    FROM estper_direcciones e, estper_personas p
                   WHERE e.sperson = x.s_sperson
                     AND p.sperson = e.sperson;

                  SELECT GREATEST(v_direc.cdomici, NVL(MAX(c.cdomici), 0)) + 1
                    INTO v_direc.cdomici
                    FROM per_direcciones c, estper_personas p
                   WHERE p.sperson = x.s_sperson
                     AND c.sperson(+) = p.spereal;
               ELSE
                  SELECT NVL(MAX(cdomici), 0) + 1
                    INTO v_direc.cdomici
                    FROM per_direcciones
                   WHERE sperson = v_sperson;
               END IF;

               --
               v_direc.sperson := x.s_sperson;
               v_direc.cagente := x.cagente;
               --v_direc.cdomici := x.cdomici;
               v_direc.ctipdir := x.ctipdir;
               v_direc.csiglas := x.csiglas;
               v_direc.tnomvia := x.tnomvia;
               v_direc.nnumvia := x.nnumvia;
               v_direc.tcomple := x.tcomple;
                 --v_direc.tdomici := x.tdomici;
               /*  v_direc.tdomici := pac_persona.f_tdomici(x.csiglas, x.tnomvia, x.nnumvia,
                                                          x.tcomple, x.cviavp, x.clitvp,
                                                          x.cbisvp, x.corvp, x.nviaadco,
                                                          x.clitco, x.corco, x.nplacaco,
                                                          x.cor2co, x.cdet1ia, x.tnum1ia,
                                                          x.cdet2ia, x.tnum2ia, x.cdet3ia,
                                                          x.tnum3ia,x.localidad);*/
               v_direc.cpostal := x.cpostal;
               v_direc.cpoblac := x.cpoblac;
               v_direc.cprovin := x.cprovin;
               v_direc.cusuari := f_user;
               v_direc.fmovimi := f_sysdate;
               --
               v_direc.cviavp := x.cviavp;
               v_direc.clitvp := x.clitvp;
               v_direc.cbisvp := x.cbisvp;
               v_direc.corvp := x.corvp;
               v_direc.nviaadco := x.nviaadco;
               v_direc.clitco := x.clitco;
               v_direc.corco := x.corco;
               v_direc.nplacaco := x.nplacaco;
               v_direc.cor2co := x.cor2co;
               v_direc.cdet1ia := x.cdet1ia;
               v_direc.tnum1ia := x.tnum1ia;
               v_direc.cdet2ia := x.cdet2ia;
               v_direc.tnum2ia := x.tnum2ia;
               v_direc.cdet3ia := x.cdet3ia;
               v_direc.tnum3ia := x.tnum3ia;
               v_direc.localidad := x.localidad;
               v_direc.talias := x.talias;

               -- 23289/120321 - ECP- 04/09/2012 Inicio
               IF ptablas = 'EST' THEN
                  INSERT INTO estper_direcciones
                              (sperson, cagente, cdomici,
                               ctipdir, csiglas, tnomvia,
                               nnumvia, tcomple, tdomici,
                               cpostal, cpoblac, cprovin,
                               cusuari, fmovimi, corigen, trecibido, cviavp,
                               clitvp, cbisvp, corvp,
                               nviaadco, clitco, corco,
                               nplacaco, cor2co, cdet1ia,
                               tnum1ia, cdet2ia, tnum2ia,
                               cdet3ia, tnum3ia, localidad, talias)
                       VALUES (v_direc.sperson, v_direc.cagente, v_direc.cdomici,
                               v_direc.ctipdir, v_direc.csiglas, v_direc.tnomvia,
                               v_direc.nnumvia, v_direc.tcomple, v_direc.tdomici,
                               v_direc.cpostal, v_direc.cpoblac, v_direc.cprovin,
                               v_direc.cusuari, v_direc.fmovimi, NULL, NULL, v_direc.cviavp,
                               v_direc.clitvp, v_direc.cbisvp, v_direc.corvp,
                               v_direc.nviaadco, v_direc.clitco, v_direc.corco,
                               v_direc.nplacaco, v_direc.cor2co, v_direc.cdet1ia,
                               v_direc.tnum1ia, v_direc.cdet2ia, v_direc.tnum2ia,
                               v_direc.cdet3ia, v_direc.tnum3ia, x.localidad, v_direc.talias);

                  -- JLB - I - 18/02/2014
                  BEGIN
                     INSERT INTO estper_cargas
                                 (sperson, tipo, proceso, cagente,
                                  ccodigo, cusuari, fecha)
                          VALUES (v_direc.sperson, 'AD', NVL(x.proceso, 0), v_direc.cagente,
                                  v_direc.cdomici, f_user, f_sysdate);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;   -- reprocesamiento
                  END;
               ELSE
                  INSERT INTO per_direcciones
                       VALUES v_direc;

                  -- JLB - I - 18/02/2014
                  BEGIN
                     INSERT INTO per_cargas
                                 (sperson, tipo, proceso, cagente,
                                  ccodigo, cusuari, fecha)
                          VALUES (v_direc.sperson, 'AD', NVL(x.proceso, 0), v_direc.cagente,
                                  v_direc.cdomici, f_user, f_sysdate);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;   -- reprocesamiento
                  END;
               END IF;

               UPDATE mig_direcciones
                  SET sperson = v_direc.sperson,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;

               -- 23289/120321 - ECP- 04/09/2012  Fin
               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, -8,
                            v_direc.sperson || '|' || v_direc.cdomici);
            END IF;

            BEGIN
               UPDATE mig_seguros   -- si es el tomador
                  SET cdomici = v_direc.cdomici
                WHERE mig_fk = x.mig_fk
                  AND ncarga = pncarga
                  AND cdomici IS NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --
            END;

            BEGIN
               UPDATE mig_asegurados   -- si es el asegurado
                  SET cdomici = v_direc.cdomici
                WHERE mig_fk = x.mig_fk
                  AND ncarga = pncarga
                  AND cdomici IS NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --
            END;
--            END IF;
--Contactos asociados a direccion JTS 08/02/2017 CONF-564
               --Teléfono
               IF TRIM(x.tnumtel) IS NOT NULL
                  AND NOT v_error THEN

                   DECLARE
                      v_cmodcon NUMBER;
                      v_warning BOOLEAN;
                   BEGIN
                      IF ptablas = 'EST' then
                         SELECT NVL(MAX(cmodcon), 0) + 1
                           INTO v_cmodcon
                           FROM estper_contactos
                          WHERE sperson = v_sperson;

                         IF v_cmodcon >= 100 THEN
                            num_err :=
                               f_ins_mig_logs_axis
                                              (pncarga, x.mig_pk, 'W',
                                               'Número de contactos excedido, Warning : '
                                               || v_cmodcon);
                            v_warning := TRUE;
                         ELSE
                            INSERT INTO estper_contactos
                                        (sperson, cagente, cmodcon, ctipcon,
                                         tcomcon, tvalcon, cusuari, fmovimi, cobliga, cdomici)
                                 VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 1,
                                         NULL, x.tnumtel, f_user, f_sysdate, 0, v_direc.cdomici);
                         END IF;
                      ELSE
                         SELECT NVL(MAX(cmodcon), 0) + 1
                           INTO v_cmodcon
                           FROM per_contactos
                          WHERE sperson = v_sperson;

                         IF v_cmodcon >= 100 THEN
                            num_err :=
                               f_ins_mig_logs_axis
                                              (pncarga, x.mig_pk, 'W',
                                               'Número de contactos excedido, Warning : '
                                               || v_cmodcon);
                            v_warning := TRUE;
                         ELSE
                            INSERT INTO per_contactos
                                        (sperson, cagente, cmodcon, ctipcon,
                                         tcomcon, tvalcon, cusuari, fmovimi, cobliga, cdomici)
                                 VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 1,
                                         NULL, x.tnumtel, f_user, f_sysdate, 0, v_direc.cdomici);
                         END IF;
                      END IF;

                      INSERT INTO mig_pk_mig_axis
                           VALUES (x.mig_pk, pncarga, pntab, -7,
                                   v_sperson || '|' || v_cmodcon);
                   EXCEPTION
                      WHEN OTHERS THEN
                         num_err :=
                            f_ins_mig_logs_axis
                                          (pncarga, x.mig_pk, 'E',
                                           'Error al insertar en PER_CONTACTOS(tnumtel):'
                                           || SQLCODE || '-' || SQLERRM);
                         v_error := TRUE;
                         ROLLBACK;
                   END;
               END IF;

               --Fax
               IF TRIM(x.tnumfax) IS NOT NULL
                  AND NOT v_error THEN

                  DECLARE
                      v_cmodcon NUMBER;
                      v_warning BOOLEAN;
                 BEGIN
                      IF ptablas = 'EST' THEN
                         SELECT NVL(MAX(cmodcon), 0) + 1
                           INTO v_cmodcon
                           FROM estper_contactos
                          WHERE sperson = v_sperson;

                         IF v_cmodcon >= 100 THEN
                            num_err :=
                               f_ins_mig_logs_axis
                                              (pncarga, x.mig_pk, 'W',
                                               'Número de contactos excedido, Warning : '
                                               || v_cmodcon);
                            v_warning := TRUE;
                         ELSE
                            INSERT INTO estper_contactos
                                        (sperson, cagente, cmodcon, ctipcon,
                                         tcomcon, tvalcon, cusuari, fmovimi, cobliga, cdomici)
                                 VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 2,
                                         NULL, x.tnumfax, f_user, f_sysdate, 0, v_direc.cdomici);
                         END IF;
                      ELSE
                         SELECT NVL(MAX(cmodcon), 0) + 1
                           INTO v_cmodcon
                           FROM per_contactos
                          WHERE sperson = v_sperson;

                         IF v_cmodcon >= 100 THEN
                            num_err :=
                               f_ins_mig_logs_axis
                                              (pncarga, x.mig_pk, 'W',
                                               'Número de contactos excedido, Warning : '
                                               || v_cmodcon);
                            v_warning := TRUE;
                         ELSE
                            INSERT INTO per_contactos
                                        (sperson, cagente, cmodcon, ctipcon,
                                         tcomcon, tvalcon, cusuari, fmovimi, cobliga, cdomici)
                                 VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 2,
                                         NULL, x.tnumfax, f_user, f_sysdate, 0, v_direc.cdomici);
                         END IF;
                      END IF;

                      INSERT INTO mig_pk_mig_axis
                           VALUES (x.mig_pk, pncarga, pntab, -7,
                                   v_sperson || '|' || v_cmodcon);
                   EXCEPTION
                      WHEN OTHERS THEN
                         num_err :=
                            f_ins_mig_logs_axis
                                          (pncarga, x.mig_pk, 'E',
                                           'Error al insertar en PER_CONTACTOS(tnumfax):'
                                           || SQLCODE || '-' || SQLERRM);
                         v_error := TRUE;
                         ROLLBACK;
                   END;
               END IF;

               --Móvil
               IF TRIM(x.tnummov) IS NOT NULL
                  AND NOT v_error THEN

                   DECLARE
                      v_cmodcon NUMBER;
                      v_warning BOOLEAN;
                   BEGIN
                        IF ptablas = 'EST' THEN
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM estper_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO estper_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga, cdomici)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 5,
                                           NULL, x.tnummov, f_user, f_sysdate, 0, v_direc.cdomici);
                           END IF;
                        ELSE
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM per_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO per_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga, cdomici)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 5,
                                           NULL, x.tnummov, f_user, f_sysdate, 0, v_direc.cdomici);
                           END IF;
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -7,
                                     v_sperson || '|' || v_cmodcon);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                            (pncarga, x.mig_pk, 'E',
                                             'Error al insertar en PER_CONTACTOS(tnummov):'
                                             || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
               END IF;

               --Mail
               IF TRIM(x.temail) IS NOT NULL
                  AND NOT v_error THEN

                   DECLARE
                      v_cmodcon NUMBER;
                      v_warning BOOLEAN;
                   BEGIN
                        IF ptablas = 'EST' THEN
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM estper_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO estper_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga, cdomici)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 3,
                                           NULL, x.temail, f_user, f_sysdate, 0, v_direc.cdomici);
                           END IF;
                        ELSE
                           SELECT NVL(MAX(cmodcon), 0) + 1
                             INTO v_cmodcon
                             FROM per_contactos
                            WHERE sperson = v_sperson;

                           IF v_cmodcon >= 100 THEN
                              num_err :=
                                 f_ins_mig_logs_axis
                                                (pncarga, x.mig_pk, 'W',
                                                 'Número de contactos excedido, Warning : '
                                                 || v_cmodcon);
                              v_warning := TRUE;
                           ELSE
                              INSERT INTO per_contactos
                                          (sperson, cagente, cmodcon, ctipcon,
                                           tcomcon, tvalcon, cusuari, fmovimi, cobliga, cdomici)
                                   VALUES (v_sperson, NVL(x.cagente, '1'), v_cmodcon, 3,
                                           NULL, x.temail, f_user, f_sysdate, 0, v_direc.cdomici);
                           END IF;
                        END IF;

                        INSERT INTO mig_pk_mig_axis
                             VALUES (x.mig_pk, pncarga, pntab, -7,
                                     v_sperson || '|' || v_cmodcon);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err :=
                              f_ins_mig_logs_axis
                                             (pncarga, x.mig_pk, 'E',
                                              'Error al insertar en PER_CONTACTOS(temail):'
                                              || SQLCODE || '-' || SQLERRM);
                           v_error := TRUE;
                           ROLLBACK;
                     END;
               END IF;
--fin CONF-564
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;
      --COMMIT;
      END LOOP;

      IF NOT v_1_direc THEN   -- si ha migrado una direccion como minimo miramos si ha habido errores
          /*     SELECT COUNT(*)
                 INTO v_cont
                 FROM mig_logs_axis
                WHERE ncarga = pncarga
                  AND tipo = 'E';

               IF v_cont > 0 THEN
                  v_estdes := 'ERROR';
               ELSE
                  v_estdes := 'OK';
               END IF;
         */
         IF v_error THEN
            v_estdes := 'ERROR';
            v_cont := 1;
         ELSE
            v_estdes := 'OK';
            v_cont := 0;
         END IF;

         UPDATE mig_cargas_tab_mig
            SET ffindes = f_sysdate,
                estdes = v_estdes
          WHERE ncarga = pncarga
            AND ntab = pntab;

         COMMIT;
         RETURN v_cont;
      ELSE
         -- no hay direcciones migradas
         RETURN 0;
      END IF;

      /*
         IF v_cont > 0 THEN
            RETURN v_cont;
         ELSE
            RETURN 0;
         END IF; */
      RETURN 0;
   END f_migra_direcciones;

-- FIN BUG 0015640 - 06-09-2010 - JMC

   -- ini BUG 0017015 - 31-01-2011 - JMF
/***************************************************************************
      FUNCTION f_migra_gescartas
      Función que inserta los registros grabados en MIG_GESCARTAS, en la tabla
      gescartas de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_gescartas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_gescartas  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_gescartas    gescartas%ROWTYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, r.sseguro s_sseguro
                    FROM mig_gescartas a, mig_seguros r
                   WHERE r.mig_pk = TO_CHAR(a.mig_fk)
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_gescartas THEN
               v_1_gescartas := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'GESCARTAS');
            END IF;

            v_gescartas := NULL;

            SELECT sgescarta.NEXTVAL
              INTO v_gescartas.sgescarta
              FROM DUAL;

            v_gescartas.ctipcar := x.ctipcar;
            v_gescartas.sseguro := x.sseguro;
            v_gescartas.sperson := x.sperson;
            v_gescartas.cgarant := x.cgarant;
            v_gescartas.nrecibo := x.nrecibo;
            v_gescartas.fsolici := x.fsolici;
            v_gescartas.ususol := x.ususol;
            v_gescartas.fimpres := x.fimpres;
            v_gescartas.usuimp := x.usuimp;
            v_gescartas.cestado := x.cestado;
            v_gescartas.nimpres := x.nimpres;
            v_gescartas.cimprimir := x.cimprimir;
            v_gescartas.scaragr := x.scaragr;
            v_gescartas.nresul := x.nresul;
            v_gescartas.sdevolu := x.sdevolu;
            v_gescartas.smovrec := x.smovrec;

            INSERT INTO gescartas
                 VALUES v_gescartas;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_gescartas.sgescarta);

            UPDATE mig_gescartas
               SET cestmig = 2,
                   sgescarta = v_gescartas.sgescarta
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_gescartas;

-- fin BUG 0017015 - 31-01-2011 - JMF

   -- BUG 0017015 - 31-01-2011 - JMF
/***************************************************************************
      FUNCTION f_migra_devbanpresentadores
      Función que inserta los registros grabados en MIG_DEVBANPRESENTADORES, en la tabla
      devbanpresentadores de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_devbanpresentadores(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_devbanpresentadores BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_devbanpresentadores devbanpresentadores%ROWTYPE;
      v_sdevolu_par  mig_codigos_emp.cvalaxis%TYPE;
      v_sdevolu_ini  devbanpresentadores.sdevolu%TYPE;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      --Averiguamos la empresa de la carga
      SELECT TO_NUMBER(cempres)
        INTO v_cempres
        FROM mig_cargas
       WHERE ncarga = pncarga;

      -- Buscar si hem definit algun parametre amb la secuencia per asignar el número.
      num_err := pac_mig_axis.f_codigo_axis(v_cempres, 'PARAM_SDEVOLU', NULL, v_sdevolu_par);

      IF v_sdevolu_par IS NULL THEN
         SELECT NVL(MAX(sdevolu), 0) + 1
           INTO v_sdevolu_ini
           FROM devbanpresentadores;
      ELSE
         v_sdevolu_ini := TO_NUMBER(v_sdevolu_par);
      END IF;

      FOR x IN (SELECT   a.*
                    FROM mig_devbanpresentadores a
                   WHERE a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_devbanpresentadores THEN
               v_1_devbanpresentadores := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'DEVBANPRESENTADORES');
            END IF;

            v_devbanpresentadores := NULL;
            v_devbanpresentadores.sdevolu := v_sdevolu_ini;
            v_devbanpresentadores.cempres := x.cempres;
            v_devbanpresentadores.cdoment := x.cdoment;
            v_devbanpresentadores.cdomsuc := x.cdomsuc;
            v_devbanpresentadores.fsoport := x.fsoport;
            v_devbanpresentadores.nnumnif := x.nnumnif;
            v_devbanpresentadores.tsufijo := x.tsufijo;
            v_devbanpresentadores.tprenom := x.tprenom;
            v_devbanpresentadores.fcarga := x.fcarga;
            v_devbanpresentadores.cusuari := f_user;
            v_devbanpresentadores.tficher := x.tficher;
            v_devbanpresentadores.nprereg := x.nprereg;
            v_devbanpresentadores.ipretot_r := x.ipretot_r;
            v_devbanpresentadores.ipretot_t := x.ipretot_t;
            v_devbanpresentadores.npretot_r := x.npretot_r;
            v_devbanpresentadores.npretot_t := x.npretot_t;
            v_devbanpresentadores.sproces := NULL;

            INSERT INTO devbanpresentadores
                 VALUES v_devbanpresentadores;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, v_devbanpresentadores.sdevolu);

            UPDATE mig_devbanpresentadores
               SET cestmig = 2,
                   sdevolu = v_devbanpresentadores.sdevolu
             WHERE mig_pk = x.mig_pk;

            v_sdevolu_ini := v_sdevolu_ini + 1;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_devbanpresentadores;

-- fin BUG 0017015 - 31-01-2011 - JMF

   -- BUG 0017015 - 31-01-2011 - JMF
/***************************************************************************
      FUNCTION f_migra_devbanordenantes
      Función que inserta los registros grabados en MIG_DEVBANORDENANTES, en la tabla
      devbanordenantes de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_devbanordenantes(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_devbanordenantes BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_devbanordenantes devbanordenantes%ROWTYPE;
      v_ccobban_par  mig_codigos_emp.cvalaxis%TYPE;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      --Averiguamos la empresa de la carga
      SELECT TO_NUMBER(cempres)
        INTO v_cempres
        FROM mig_cargas
       WHERE ncarga = pncarga;

      -- Buscar si hem definit algun parametre amb cobrador bancari defecte.
      num_err := pac_mig_axis.f_codigo_axis(v_cempres, 'PARAM_DEV_CCOBBAN', NULL,
                                            v_ccobban_par);

      FOR x IN (SELECT   a.*
                    FROM mig_devbanordenantes a
                   WHERE a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_devbanordenantes THEN
               v_1_devbanordenantes := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'DEVBANORDENANTES');
            END IF;

            v_devbanordenantes := NULL;

            DECLARE
               CURSOR c1 IS
                  SELECT sdevolu
                    FROM mig_devbanpresentadores
                   WHERE mig_pk = SUBSTR(x.mig_pk, 1, INSTR(x.mig_pk, '|') - 1);
            BEGIN
               OPEN c1;

               FETCH c1
                INTO v_devbanordenantes.sdevolu;

               IF v_devbanordenantes.sdevolu IS NULL THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Falta sdevolu '
                                                 || SUBSTR(x.mig_pk, 1,
                                                           INSTR(x.mig_pk, '|') - 1));
                  RAISE NO_DATA_FOUND;
               END IF;

               CLOSE c1;
            END;

            v_devbanordenantes.nnumnif := x.nnumnif;
            v_devbanordenantes.tsufijo := x.tsufijo;
            v_devbanordenantes.fremesa := x.fremesa;
            v_devbanordenantes.ccobban := NVL(v_ccobban_par, x.ccobban);
            v_devbanordenantes.tordnom := x.tordnom;
            v_devbanordenantes.nordccc := x.nordccc;
            v_devbanordenantes.nordreg := x.nordreg;
            v_devbanordenantes.iordtot_r := x.iordtot_r;
            v_devbanordenantes.iordtot_t := x.iordtot_t;
            v_devbanordenantes.nordtot_r := x.nordtot_r;
            v_devbanordenantes.nordtot_t := x.nordtot_t;
            v_devbanordenantes.ctipban := x.ctipban;

            INSERT INTO devbanordenantes
                 VALUES v_devbanordenantes;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         TO_CHAR(v_devbanordenantes.sdevolu) || '|' || x.nnumnif || '|'
                         || x.tsufijo || '|' || x.fremesa);

            UPDATE mig_devbanordenantes
               SET cestmig = 2,
                   sdevolu = v_devbanordenantes.sdevolu
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_devbanordenantes;

-- fin BUG 0017015 - 31-01-2011 - JMF

   -- BUG 0017015 - 31-01-2011 - JMF
/***************************************************************************
      FUNCTION f_migra_devbanrecibos
      Función que inserta los registros grabados en MIG_DEVBANRECIBOS, en la tabla
      devbanrecibos de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_devbanrecibos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_devbanrecibos BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_devbanrecibos devbanrecibos%ROWTYPE;
      v_ccobban_par  mig_codigos_emp.cvalaxis%TYPE;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      --Averiguamos la empresa de la carga
      SELECT TO_NUMBER(cempres)
        INTO v_cempres
        FROM mig_cargas
       WHERE ncarga = pncarga;

      -- Buscar si hem definit algun parametre amb cobrador bancari defecte.
      num_err := pac_mig_axis.f_codigo_axis(v_cempres, 'PARAM_DEV_CCOBBAN', NULL,
                                            v_ccobban_par);

      FOR x IN (SELECT   a.*
                    FROM mig_devbanrecibos a
                   WHERE a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_devbanrecibos THEN
               v_1_devbanrecibos := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'DEVBANRECIBOS');
            END IF;

            v_devbanrecibos := NULL;

            DECLARE
               CURSOR c1 IS
                  SELECT sdevolu
                    FROM mig_devbanpresentadores
                   WHERE mig_pk = SUBSTR(x.mig_pk, 1, INSTR(x.mig_pk, '|') - 1);
            BEGIN
               OPEN c1;

               FETCH c1
                INTO v_devbanrecibos.sdevolu;

               IF v_devbanrecibos.sdevolu IS NULL THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Falta sdevolu '
                                                 || SUBSTR(x.mig_pk, 1,
                                                           INSTR(x.mig_pk, '|') - 1));
                  RAISE NO_DATA_FOUND;
               END IF;

               CLOSE c1;
            END;

            DECLARE
               CURSOR c1 IS
                  SELECT nrecibo
                    FROM mig_recibos
                   WHERE mig_pk = TO_CHAR(x.mig_fk);
            BEGIN
               OPEN c1;

               FETCH c1
                INTO v_devbanrecibos.nrecibo;

               IF v_devbanrecibos.nrecibo IS NULL THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Falta recibo ' || x.mig_fk);
                  RAISE NO_DATA_FOUND;
               END IF;

               CLOSE c1;
            END;

            v_devbanrecibos.nnumnif := x.nnumnif;
            v_devbanrecibos.tsufijo := x.tsufijo;
            v_devbanrecibos.fremesa := x.fremesa;
            v_devbanrecibos.crefere := x.crefere;
            v_devbanrecibos.trecnom := x.trecnom;
            v_devbanrecibos.nrecccc := x.nrecccc;
            v_devbanrecibos.irecdev := x.irecdev;
            v_devbanrecibos.cdevrec := x.cdevrec;
            v_devbanrecibos.crefint := x.crefint;
            v_devbanrecibos.cdevmot := x.cdevmot;
            v_devbanrecibos.cdevsit := x.cdevsit;
            v_devbanrecibos.tprilin := x.tprilin;
            v_devbanrecibos.ccobban := NVL(v_ccobban_par, x.ccobban);
            v_devbanrecibos.ctipban := x.ctipban;

            INSERT INTO devbanrecibos
                 VALUES v_devbanrecibos;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         SUBSTR(TO_CHAR(v_devbanrecibos.sdevolu) || '|' || x.nnumnif || '|'
                                || x.tsufijo || '|' || x.fremesa || '|' || x.crefere || '|'
                                || TO_CHAR(v_devbanrecibos.nrecibo),
                                1, 50));

            UPDATE mig_devbanrecibos
               SET cestmig = 2,
                   sdevolu = v_devbanrecibos.sdevolu,
                   nrecibo = v_devbanrecibos.nrecibo
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_devbanrecibos;

-- fin BUG 0017015 - 31-01-2011 - JMF
-- BUG 20003 - 07-11-2011 - JMC - Funciónes para las migraciones de las tablas:
-- PER_PERSONAS_REL, PER_REGIMENFISCAL y PER_VINCULOS.
/***************************************************************************
      FUNCTION f_migra_personas_rel
      Función que inserta los registros grabados en MIG_PERSONAS_REL, en la
      tabla de relaciones de personas de AXIS. (PER_PERSONAS_REL)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_personas_rel(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_parper     BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, p.idperson p_sperson, p.cagente, p2.idperson p_sperson2
                    FROM mig_personas_rel a, mig_personas p, mig_personas p2
                   WHERE p.mig_pk = a.mig_fk
                     AND p2.mig_pk = a.fkrel
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_parper THEN
               v_1_parper := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'PER_PERSONAS_REL');
            END IF;

            INSERT INTO per_personas_rel
                        (sperson, cagente, sperson_rel, ctipper_rel, pparticipacion, islider)
                 VALUES (x.p_sperson, x.cagente, x.p_sperson2, x.ctiprel, x.pparticipacion, x.islider);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10,
                         x.p_sperson || '|' || x.cagente || '|' || x.p_sperson2);

            UPDATE mig_personas_rel
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_personas_rel;

/***************************************************************************
      FUNCTION f_migra_regimenfiscal
      Función que inserta los registros grabados en MIG_REGIMENFISCAL, en la
      tabla de regimen fiscales de personas de AXIS. (PER_REGIMENFISCAL)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
          param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_regimenfiscal(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_parper     BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, p.idperson p_sperson, p.cagente
                    FROM mig_regimenfiscal a, mig_personas p
                   WHERE p.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_parper THEN
               v_1_parper := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'PER_REGIMENFISCAL');
            END IF;

            -- 23289/120321 - ECP- 05/09/2012 Inicio
            IF ptablas = 'EST' THEN
               -- BUG 29553_0163699- 29/01/2014 - JLTS - Se adiciona EXCEPTION WHEN_DUP_VAL...
               BEGIN
                  INSERT INTO estper_regimenfiscal
                              (sperson, cagente, anualidad, fefecto, cregfiscal)
                       VALUES (x.p_sperson, x.cagente, x.nanuali, x.fefecto, x.cregfis);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     NULL;
               END;
            ELSE
               -- BUG 29553_0163699- 29/01/2014 - JLTS - Se adiciona EXCEPTION WHEN_DUP_VAL...
               BEGIN
                  INSERT INTO per_regimenfiscal
                              (sperson, cagente, anualidad, fefecto, cregfiscal)
                       VALUES (x.p_sperson, x.cagente, x.nanuali, x.fefecto, x.cregfis);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     NULL;
               END;
            END IF;

            -- 23289/120321 - ECP- 05/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10,
                         x.p_sperson || '|' || x.cagente || '|'
                         || TO_CHAR(x.fefecto, 'yyyymmdd'));

            UPDATE mig_regimenfiscal
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_regimenfiscal;

/***************************************************************************
      FUNCTION f_migra_vinculos
      Función que inserta los registros grabados en MIG_VINCULOS, en la
      tabla de vinculos de personas de AXIS. (PER_VINCULOS)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_vinculos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_parper     BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, p.idperson p_sperson, p.cagente
                    FROM mig_vinculos a, mig_personas p
                   WHERE p.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_parper THEN
               v_1_parper := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'PER_VINCULOS');
            END IF;

            -- 23289/120321 - ECP- 05/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estper_vinculos
                           (sperson, cagente, cvinclo)
                    VALUES (x.p_sperson, x.cagente, x.cvinclo);
            ELSE
               INSERT INTO per_vinculos
                           (sperson, cagente, cvinclo)
                    VALUES (x.p_sperson, x.cagente, x.cvinclo);
            END IF;

            -- 23289/120321 - ECP- 05/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10,
                         x.p_sperson || '|' || x.cagente || '|' || x.cvinclo);

            UPDATE mig_vinculos
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_vinculos;

-- FIN BUG 20003 - 07-11-2011 - JMC

   /***************************************************************************
      FUNCTION f_migra_detprimas
      Función que inserta los registros grabados en MIG_DETPRIMAS, en la tabla
      DETPRIMAS de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
-- Bug 21121 - APD - 22/02/2012 - se crea la funcion
   FUNCTION f_migra_detprimas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_detprimas  BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_detprimas    detprimas%ROWTYPE;
      v_seguros      seguros%ROWTYPE;
      v_cont         NUMBER;
      v_norden       detgaranformula.norden%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      -- Bug 21686 - JRH - 26/03/2012 - se modifica el cursor
      FOR x IN (SELECT   a.*, m.sseguro s_sseguro, m.sproduc s_sproduc, m.cactivi s_cactivi,
                         g.finiefe g_finiefe, g.nmovimi g_nmovimi, g.cgarant g_cgarant
                    /*m.fefecto m_fefecto, m.nmovimi m_nmovimi*/
                    --Bug 0012557 - 14-01-2009 - JMC - fefecto de mig_movseguro
                FROM     mig_detprimas a, mig_movseguro s, mig_seguros m, mig_garanseg g
                   WHERE g.mig_pk = a.mig_fk
                     AND s.mig_pk = g.mig_fk
                     AND m.mig_pk = s.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         -- Fi Bug 21686 - JRH  - 26/03/2012
         BEGIN
            IF v_1_detprimas THEN
               v_1_detprimas := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'DETPRIMAS');
            END IF;

            v_error := FALSE;
            v_detprimas := NULL;

            BEGIN
               SELECT norden
                 INTO v_norden
                 FROM detgaranformula
                WHERE sproduc = x.s_sproduc
                  AND cactivi = x.s_cactivi
                  AND cgarant = x.g_cgarant
                  AND ccampo = x.ccampo
                  AND cconcep = x.cconcep;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT norden
                       INTO v_norden
                       FROM detgaranformula
                      WHERE sproduc = x.s_sproduc
                        AND cactivi = 0
                        AND cgarant = x.g_cgarant
                        AND ccampo = x.ccampo
                        AND cconcep = x.cconcep;
                  EXCEPTION
                     -- se añade el when others v_norder = 1 pero se debe eliminar más adelante
                     WHEN OTHERS THEN
                        v_norden := 1;
                  END;
               -- se añade el when others v_norder = 1 pero se debe eliminar más adelante
               WHEN OTHERS THEN
                  v_norden := 1;
            END;

            v_detprimas.sseguro := x.s_sseguro;
            v_detprimas.nriesgo := x.nriesgo;
            v_detprimas.cgarant := x.cgarant;
            v_detprimas.nmovimi := x.g_nmovimi;
            v_detprimas.finiefe := x.g_finiefe;
            v_detprimas.ccampo := x.ccampo;
            v_detprimas.cconcep := x.cconcep;
            v_detprimas.norden := v_norden;
            v_detprimas.iconcep := x.iconcep;
            v_detprimas.iconcep2 := x.iconcep2;

            -- 23289/120321 - ECP- 05/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estdetprimas
                    VALUES v_detprimas;
            ELSE
               INSERT INTO detprimas
                    VALUES v_detprimas;
            END IF;

            -- 23289/120321 - ECP- 05/09/2012  Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_detprimas.sseguro || '|' || v_detprimas.nriesgo || '|'
                         || v_detprimas.cgarant || '|' || v_detprimas.nmovimi || '|'
                         || TO_CHAR(v_detprimas.finiefe, 'yyyymmdd') || '|'
                         || v_detprimas.ccampo || '|' || v_detprimas.cconcep);

            UPDATE mig_detprimas
               SET sseguro = v_detprimas.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      -- FIN BUG : 10395 - 18-06-2009 - JMC
      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_detprimas;

-- fin Bug 21121 - APD - 22/02/2012

   -- Bug 21686 - JMC - 25/05/2012 - Se añade funcion para migrar GARANDETCAP
/***************************************************************************
      FUNCTION f_migra_garandetcap
      Función que inserta los registros grabados en MIG_GARANDETCAP, en la tabla
      GARANDETCAP de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_garandetcap(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_garandetcap BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_garandetcap  garandetcap%ROWTYPE;
      v_seguros      seguros%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, m.sseguro s_sseguro, m.sproduc s_sproduc, m.cactivi s_cactivi,
                         g.finiefe g_finiefe, g.nmovimi g_nmovimi, g.cgarant g_cgarant
                    FROM mig_garandetcap a, mig_movseguro s, mig_seguros m, mig_garanseg g
                   WHERE g.mig_pk = a.mig_fk
                     AND s.mig_pk = g.mig_fk
                     AND m.mig_pk = s.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_garandetcap THEN
               v_1_garandetcap := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'GARANDETCAP');
            END IF;

            v_error := FALSE;
            v_garandetcap := NULL;
            v_garandetcap.sseguro := x.s_sseguro;
            v_garandetcap.nriesgo := x.nriesgo;
            v_garandetcap.cgarant := x.cgarant;
            v_garandetcap.nmovimi := x.g_nmovimi;
            v_garandetcap.norden := x.norden;
            v_garandetcap.cconcepto := x.cconcepto;
            v_garandetcap.tdescrip := x.tdescrip;
            v_garandetcap.icapital := x.icapital;

            -- 23289/120321 - ECP- 05/09/2012 Inicio
            IF ptablas = 'POL' THEN
               INSERT INTO estgarandetcap
                    VALUES v_garandetcap;
            ELSE
               INSERT INTO garandetcap
                    VALUES v_garandetcap;
            END IF;

            -- 23289/120321 - ECP- 05/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_garandetcap.sseguro || '|' || v_garandetcap.nriesgo || '|'
                         || v_garandetcap.cgarant || '|' || v_garandetcap.nmovimi || '|'
                         || v_garandetcap.norden);

            UPDATE mig_garandetcap
               SET sseguro = v_garandetcap.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_garandetcap;

-- fin Bug 21686 - JMC - 25/05/2012

   --bfp bug 21947 ini
/***************************************************************************
      FUNCTION f_migra_garansegcom
      Función que inserta los registros grabados en MIG_GARANSEGCOM, en la tabla
      PREGUNGARANSEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_garansegcom(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_garansegcom BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_garansegcom  garansegcom%ROWTYPE;
      v_seguros      seguros%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, m.sseguro s_sseguro, m.sproduc s_sproduc, m.cactivi s_cactivi,
                         g.finiefe g_finiefe, g.nmovimi g_nmovimi
                    FROM mig_garansegcom a, mig_movseguro s, mig_seguros m, mig_garanseg g
                   WHERE g.mig_pk = a.mig_fk
                     AND s.mig_pk = g.mig_fk
                     AND m.mig_pk = s.mig_fk
                     AND a.ncarga = pncarga
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_garansegcom THEN
               v_1_garansegcom := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'GARANSEGCOM');
            END IF;

            v_error := FALSE;
            v_garansegcom := NULL;
            v_garansegcom.sseguro := x.s_sseguro;
            v_garansegcom.nriesgo := x.nriesgo;
            v_garansegcom.cgarant := x.cgarant;
            v_garansegcom.nmovimi := x.g_nmovimi;
            v_garansegcom.finiefe := x.g_finiefe;
            v_garansegcom.cmodcom := x.cmodcom;
            v_garansegcom.pcomisi := x.pcomisi;

            -- 23289/120321 - ECP- 05/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estgaransegcom
                           (sseguro, nriesgo,
                            cgarant, nmovimi,
                            finiefe, cmodcom,
                            pcomisi, cmatch, tdesmat, pintfin, ninialt,
                            nfinalt, pcomisicua,
                            falta, cusualt,
                            fmodifi, cusumod)
                    VALUES (v_garansegcom.sseguro, v_garansegcom.nriesgo,
                            v_garansegcom.cgarant, v_garansegcom.nmovimi,
                            v_garansegcom.finiefe, v_garansegcom.cmodcom,
                            v_garansegcom.pcomisi, NULL, NULL, NULL, v_garansegcom.ninialt,
                            v_garansegcom.nfinalt, v_garansegcom.pcomisicua,
                            v_garansegcom.falta, v_garansegcom.cusualt,
                            v_garansegcom.fmodifi, v_garansegcom.cusumod);
            ELSE
               INSERT INTO garansegcom
                    VALUES v_garansegcom;
            END IF;

            -- 23289/120321 - ECP- 05/09/2012  Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_garansegcom.sseguro || '|' || v_garansegcom.nriesgo || '|'
                         || v_garansegcom.cgarant || '|' || v_garansegcom.nmovimi || '|'
                         || v_garansegcom.finiefe || '|' || v_garansegcom.cmodcom || '|'
                         || v_garansegcom.pcomisi);

            UPDATE mig_garansegcom
               SET sseguro = v_garansegcom.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_garansegcom;

--bfp bug 21947 fi

   -- 23289/120321 - JLB- 19/09/2012
/***************************************************************************
        FUNCTION f_migra_benespseg
        Función que inserta las personas grabadas en MIG_benespseg, en
        la tabla de benespseg de AXIS.
           param in  pncarga:     Número de carga.
           param in  pntab:       Número de tabla.
           return:                0-OK, <>0-Error
     ***************************************************************************/
   FUNCTION f_migra_benespseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_sperson      per_personas.sperson%TYPE;
      v_sperson_con  per_personas.sperson%TYPE := 0;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_benespseg  BOOLEAN := TRUE;
      v_nriesgo      mig_benespseg.nriesgo%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, s.fefecto, s.cagente
                    FROM mig_benespseg a, mig_seguros s, mig_movseguro m
                   WHERE m.mig_pk = a.mig_fk
                     AND s.mig_pk = m.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_benespseg THEN
               v_1_benespseg := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'BENESPSEG');
            END IF;

            --Obtenemos el sperson
            IF x.sperson = 0 THEN
               SELECT idperson
                 INTO v_sperson
                 FROM mig_personas
                WHERE mig_pk = x.mig_fk2
                                        --AND ncarga = pncarga
               ;
            ELSE
               v_sperson := x.sperson;
            END IF;

               -- Mirarmos si hay algun beneficiario contigente
            --   IF NVL(x.nnumide_cont, '0') <> '0' THEN
                   /*   select idperson
                                into  v_sperson_con
                       from mig_personas
                       where ncarga =  pncarga
                         and ctipide = x.CTIPIDE_CONT
                         and nnumide = x.NNUMIDE_CONT
                         and nvl(tapelli1,'*') = nvl( x.TAPELLI1_CONT,'*')
                         and nvl(tapelli2,'*') = nvl(x.TAPELLI2_CONT,'*')
                         and nvl(tnombre,'*') = nvl( x.TNOMBRE1_CONT,'*')
                         and nvl(tnombre2,'*') = nvl(x.TNOMBRE2_CONT,'*');
                  */

            --    END IF;
            IF ptablas = 'EST' THEN
               -- Mirarmos si hay algun beneficiario contigente
               IF NVL(x.nnumide_cont, '0') <> '0' THEN
                  SELECT per.sperson
                    INTO v_sperson_con
                    FROM estper_personas per, estper_detper pd
                   WHERE ctipide = x.ctipide_cont
                     AND nnumide = x.nnumide_cont
                     AND nnumide <> 'Z'
                     AND pd.sperson = per.sperson
                     AND pd.cagente = ff_agente_cpervisio(x.cagente)
                     AND NVL(tapelli1, '*') = NVL(x.tapelli1_cont, '*')
                     AND NVL(tapelli2, '*') = NVL(x.tapelli2_cont, '*')
                     AND NVL(tnombre1, '*') = NVL(x.tnombre1_cont, '*')
                     AND NVL(tnombre2, '*') = NVL(x.tnombre2_cont, '*')
                     AND ROWNUM = 1;
               END IF;

               IF x.nriesgo = 0 THEN
                  v_nriesgo := 1;
               ELSE
                  v_nriesgo := x.nriesgo;
               END IF;

               INSERT INTO estbenespseg
                           (sseguro, nriesgo, cgarant, nmovimi, sperson,
                            sperson_tit, finiben, ffinben, ctipben, cparen,
                            pparticip, cestado, ctipocon)
                    VALUES (x.s_sseguro, v_nriesgo, x.cgarant, x.nmovimi, v_sperson,
                            NVL(v_sperson_con, 0), x.finiben, x.ffinben, x.ctipben, x.cparen,
                            x.pparticip, x.cestado, x.ctipocon);
            ELSE
               -- Mirarmos si hay algun beneficiario contigente
               IF NVL(x.nnumide_cont, '0') <> '0' THEN
                  SELECT per.sperson
                    INTO v_sperson_con
                    FROM per_personas per, per_detper pd
                   WHERE ctipide = x.ctipide_cont
                     AND nnumide = x.nnumide_cont
                     AND nnumide <> 'Z'
                     AND pd.sperson = per.sperson
                     AND pd.cagente = ff_agente_cpervisio(x.cagente)
                     AND NVL(tapelli1, '*') = NVL(x.tapelli1_cont, '*')
                     AND NVL(tapelli2, '*') = NVL(x.tapelli2_cont, '*')
                     AND NVL(tnombre1, '*') = NVL(x.tnombre1_cont, '*')
                     AND NVL(tnombre2, '*') = NVL(x.tnombre2_cont, '*')
                     AND ROWNUM = 1;
               END IF;

               IF x.nriesgo = 0 THEN
                  v_nriesgo := 1;
               ELSE
                  v_nriesgo := x.nriesgo;
               END IF;

               INSERT INTO benespseg
                           (sseguro, nriesgo, cgarant, nmovimi, sperson,
                            sperson_tit, finiben, ffinben, ctipben, cparen,
                            pparticip, cestado, ctipocon)
                    VALUES (x.s_sseguro, v_nriesgo, x.cgarant, x.nmovimi, v_sperson,
                            NVL(v_sperson_con, 0), x.finiben, x.ffinben, x.ctipben, x.cparen,
                            x.pparticip, x.cestado, x.ctipocon);

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 1, x.sseguro || x.nriesgo || v_sperson);
            END IF;

            UPDATE mig_benespseg
               SET sperson = v_sperson,
                   sseguro = x.s_sseguro,
                   cestmig = 9
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_benespseg;

-- Inicio Bug:24744-SCO-20130917
/***************************************************************************
   FUNCTION f_mig_validacion
   función que realiza las validaciones de la tabla MIG_VALIDACION para cada producto del seguro
      psseguro       código del seguro
      ptablas        tablas EST o SEG
   ***************************************************************************/
   FUNCTION f_mig_validacion(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psproduc IN NUMBER,
      pmens OUT VARCHAR2)
      RETURN NUMBER IS
      -- v_sproduc      NUMBER(10);
      v_ss           VARCHAR2(3000);
      v_cursor       NUMBER;
      v_retorno      NUMBER := 0;
      v_filas        NUMBER;
   BEGIN
       /*
            --obtenemos el producto del seguro
            IF ptablas = 'EST' THEN
               SELECT sproduc
                 INTO v_sproduc
                 FROM estseguros
                WHERE sseguro = psseguro;
            ELSE
               SELECT sproduc
                 INTO v_sproduc
                 FROM seguros
                WHERE sseguro = psseguro;
            END IF;
      */    --obtenemos las funciones y orden de las mismas para el producto del seguro
      FOR reg IN (SELECT   tvalidacion
                      FROM mig_validacion
                     WHERE sproduc = psproduc
                  ORDER BY norden) LOOP
         v_ss := 'BEGIN ' || ':RETORNO := ' || reg.tvalidacion || '(' || CHR(39) || ptablas
                 || CHR(39) || ', ' || psseguro || '); ' || 'END;';

         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         v_cursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
         DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
         v_filas := DBMS_SQL.EXECUTE(v_cursor);
         DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);

         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         IF v_retorno <> 0 THEN
            pmens := reg.tvalidacion;
            EXIT;
         END IF;
      END LOOP;

      RETURN v_retorno;
   END f_mig_validacion;

-- Fin Bug:24744-SCO-20130917

   /***************************************************************************
      FUNCTION f_trata_preguntas_migracion - SCO-20131017
      función que añade las garantías que faltan y comprueba las preguntas de póliza, riesgo y garantías
      para las pólizas cargadas por fichero en modo migración
         psseguro       código del seguro
   ***************************************************************************/
   FUNCTION f_trata_preguntas_migracion(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_res          NUMBER;
      v_norden       NUMBER;
      v_riesgo       NUMBER;
      v_resp         pregunpolseg.crespue%TYPE;
      nerror         NUMBER;
      v_sproduc      NUMBER;
   BEGIN
      -- Obtenemos el producto de la póliza migrada
      IF ptablas = 'EST' THEN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      -- Obtenemos las garantías obligatorias del producto de la póliza
      FOR reg_garantias IN (SELECT   cgarant, norden
                                FROM garanpro
                               WHERE sproduc = v_sproduc
                                 AND ctipgar = 8
                            ORDER BY norden) LOOP
         -- Comprobamos para cada movimiento si la garantía existe para la póliza migrada
         FOR reg_movimientos IN (SELECT DISTINCT nmovimi, finiefe, ffinefe, nriesgo
                                            FROM garanseg
                                           WHERE sseguro = psseguro
                                             AND ptablas <> 'EST'
                                 UNION
                                 SELECT DISTINCT nmovimi, finiefe, ffinefe, nriesgo
                                            FROM estgaranseg
                                           WHERE sseguro = psseguro
                                             AND cobliga = 1
                                             AND ptablas = 'EST'
                                        ORDER BY nmovimi) LOOP
            IF ptablas = 'EST' THEN
               SELECT COUNT(cgarant)
                 INTO v_res
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nmovimi = reg_movimientos.nmovimi
                  AND cgarant = reg_garantias.cgarant
                  AND cobliga = 1;
            ELSE
               SELECT COUNT(cgarant)
                 INTO v_res
                 FROM garanseg
                WHERE sseguro = psseguro
                  AND nmovimi = reg_movimientos.nmovimi
                  AND cgarant = reg_garantias.cgarant;
            END IF;

            IF v_res = 0 THEN
               -- La garantía no existe en la póliza para el movimiento
               -- Creamos el registro en garanseg para la póliza con los valores a cero para la garantía y movimiento
               IF ptablas = 'EST' THEN
                  INSERT INTO estgaranseg
                              (cgarant, nriesgo,
                               nmovimi, sseguro, finiefe,
                               norden, crevali, ctarifa, icapital, precarg, iextrap, iprianu,
                               ffinefe, cformul, ctipfra, ifranqu, irecarg, ipritar, pdtocom,
                               idtocom, prevali, irevali, itarifa, itarrea, ipritot, icaptot,
                               pdtoint, idtoint, ftarifa, feprev, fpprev, percre, crevalcar,
                               cmatch, tdesmat, pintfin, cref, cintref, pdif, pinttec,
                               nparben, nbns, tmgaran, cderreg, ccampanya, nversio, nmovima,
                               cageven, nfactor, nlinea, cmotmov, finider, falta, cfranq,
                               nfraver, ngrpfra, ngrpgara, pdtofra, ctarman, nordfra,
                               itotanu, pdtotec, preccom, idtotec, ireccom, icaprecomend,
                               cobliga)
                       VALUES (reg_garantias.cgarant, reg_movimientos.nriesgo,
                               reg_movimientos.nmovimi, psseguro, reg_movimientos.finiefe,
                               reg_garantias.norden, 0, NULL, 0, 0, 0, 0,
                               reg_movimientos.ffinefe, NULL, NULL, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0,
                               0, 0, NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL, NULL, 1,
                               NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, 0, NULL,
                               0, 0, 0, 0, 0, 0,
                               1);
               ELSE
                  INSERT INTO garanseg
                              (cgarant, nriesgo,
                               nmovimi, sseguro, finiefe,
                               norden, crevali, ctarifa, icapital, precarg, iextrap, iprianu,
                               ffinefe, cformul, ctipfra, ifranqu, irecarg, ipritar, pdtocom,
                               idtocom, prevali, irevali, itarifa, itarrea, ipritot, icaptot,
                               pdtoint, idtoint, ftarifa, feprev, fpprev, percre, crevalcar,
                               cmatch, tdesmat, pintfin, cref, cintref, pdif, pinttec,
                               nparben, nbns, tmgaran, cderreg, ccampanya, nversio, nmovima,
                               cageven, nfactor, nlinea, cmotmov, finider, falta, cfranq,
                               nfraver, ngrpfra, ngrpgara, pdtofra, ctarman, nordfra,
                               itotanu, pdtotec, preccom, idtotec, ireccom, icaprecomend)
                       VALUES (reg_garantias.cgarant, reg_movimientos.nriesgo,
                               reg_movimientos.nmovimi, psseguro, reg_movimientos.finiefe,
                               reg_garantias.norden, 0, NULL, 0, 0, 0, 0,
                               reg_movimientos.ffinefe, NULL, NULL, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0,
                               0, 0, NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL, NULL, 1,
                               NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, 0, NULL,
                               0, 0, 0, 0, 0, 0);
               END IF;

               COMMIT;
            END IF;
         END LOOP;
      END LOOP;

      -- Calculamos las preguntas a nivel de póliza, riesgo y garantías para cada movimiento
      FOR reg_movimientos IN (SELECT DISTINCT nmovimi
                                         FROM movseguro
                                        WHERE sseguro = psseguro
                                          AND ptablas <> 'EST'
                              UNION
                              SELECT   1 nmovimi
                                  FROM DUAL
                                 WHERE ptablas = 'EST'
                              ORDER BY nmovimi) LOOP
         -- preguntas a nivel de poliza
         FOR reg_pregunt IN (SELECT   p.npreord, p.cpregun, p.cpretip, p.tprefor, 1 nmovima,
                                      seg.fefecto fefecto, pc.ctippre, seg.npoliza npoliza,
                                      esccero, cresdef
                                 FROM pregunpro p, codipregun pc, seguros seg
                                WHERE p.sproduc = seg.sproduc
                                  AND seg.sseguro = psseguro
                                  AND pc.cpregun = p.cpregun
                                  AND(p.cpretip = 2   --automaticas
                                      OR(p.cpretip = 3   --semiautomaticas
                                         AND p.esccero = 0))
                                  AND p.cnivel = 'P'
                                  AND ptablas <> 'EST'
                             UNION
                             SELECT   p.npreord, p.cpregun, p.cpretip, p.tprefor, 1 nmovima,
                                      seg.fefecto fefecto, pc.ctippre, seg.npoliza npoliza,
                                      esccero, cresdef
                                 FROM pregunpro p, codipregun pc, estseguros seg
                                WHERE p.sproduc = seg.sproduc
                                  AND seg.sseguro = psseguro
                                  AND pc.cpregun = p.cpregun
                                  AND(p.cpretip = 2   --automaticas
                                      OR(p.cpretip = 3   --semiautomaticas
                                         AND p.esccero = 0))
                                  AND p.cnivel = 'P'
                                  AND ptablas = 'EST'
                             ORDER BY npreord) LOOP
            v_resp := NULL;

            IF reg_pregunt.tprefor IS NOT NULL THEN
               -- se ha encontrado la fórmula para la pregunta
               nerror := pac_albsgt.f_tprefor(reg_pregunt.tprefor, ptablas, psseguro, NULL,
                                              reg_pregunt.fefecto, reg_movimientos.nmovimi, 0,
                                              v_resp, 1, 1, 0);

               IF v_resp IS NULL THEN
                  v_resp := reg_pregunt.cresdef;
               END IF;

               IF v_resp IS NOT NULL THEN
                  BEGIN
                     IF ptablas = 'EST' THEN
                        INSERT INTO estpregunpolseg
                                    (sseguro, cpregun, crespue,
                                     nmovimi, trespue)
                             VALUES (psseguro, reg_pregunt.cpregun, v_resp,
                                     reg_movimientos.nmovimi, NULL);
                     ELSE
                        INSERT INTO pregunpolseg
                                    (sseguro, cpregun, crespue,
                                     nmovimi, trespue)
                             VALUES (psseguro, reg_pregunt.cpregun, v_resp,
                                     reg_movimientos.nmovimi, NULL);
                     END IF;

                     COMMIT;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
               END IF;
            END IF;
         END LOOP;

         -- preguntas a nivel de riesgo
         FOR reg_pregunt IN (SELECT   p.npreord, p.cpregun, p.cpretip, p.tprefor, 1 nmovima,
                                      seg.fefecto fefecto, pc.ctippre, r.nriesgo,
                                      seg.npoliza npoliza, esccero, p.cresdef
                                 FROM pregunpro p, codipregun pc, seguros seg, riesgos r
                                WHERE p.sproduc = seg.sproduc
                                  AND seg.sseguro = psseguro
                                  AND r.sseguro = seg.sseguro
                                  AND r.fanulac IS NULL
                                  AND pc.cpregun = p.cpregun
                                  AND(p.cpretip = 2   --automaticas
                                      OR(p.cpretip = 3   --semiautomaticas
                                         AND p.esccero = 0))
                                  AND p.cnivel = 'R'
                                  AND ptablas <> 'EST'
                             UNION
                             SELECT   p.npreord, p.cpregun, p.cpretip, p.tprefor, 1 nmovima,
                                      seg.fefecto fefecto, pc.ctippre, r.nriesgo,
                                      seg.npoliza npoliza, esccero, p.cresdef
                                 FROM pregunpro p, codipregun pc, estseguros seg, estriesgos r
                                WHERE p.sproduc = seg.sproduc
                                  AND seg.sseguro = psseguro
                                  AND r.sseguro = seg.sseguro
                                  AND r.fanulac IS NULL
                                  AND pc.cpregun = p.cpregun
                                  AND(p.cpretip = 2   --automaticas
                                      OR(p.cpretip = 3   --semiautomaticas
                                         AND p.esccero = 0))
                                  AND p.cnivel = 'R'
                                  AND ptablas = 'EST'
                             ORDER BY npreord) LOOP
            v_resp := NULL;

            IF reg_pregunt.tprefor IS NOT NULL THEN
               -- se ha encontrado la fórmula para la pregunta
               nerror := pac_albsgt.f_tprefor(reg_pregunt.tprefor, ptablas, psseguro,
                                              reg_pregunt.nriesgo, reg_pregunt.fefecto,
                                              reg_movimientos.nmovimi, 0, v_resp, 1, 1, 0);

               IF v_resp IS NULL THEN
                  v_resp := reg_pregunt.cresdef;
               END IF;

               IF v_resp IS NOT NULL THEN
                  BEGIN
                     IF ptablas = 'EST' THEN
                        INSERT INTO estpregunseg
                                    (sseguro, nriesgo, cpregun,
                                     crespue, nmovimi, trespue)
                             VALUES (psseguro, reg_pregunt.nriesgo, reg_pregunt.cpregun,
                                     v_resp, reg_movimientos.nmovimi, NULL);
                     ELSE
                        INSERT INTO pregunseg
                                    (sseguro, nriesgo, cpregun,
                                     crespue, nmovimi, trespue)
                             VALUES (psseguro, reg_pregunt.nriesgo, reg_pregunt.cpregun,
                                     v_resp, reg_movimientos.nmovimi, NULL);
                     END IF;

                     COMMIT;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
               END IF;
            END IF;
         END LOOP;

         -- preguntas a nivel de garantia
         FOR reg_garant IN (SELECT   p.cgarant, p.npreord, p.cpregun, p.cpretip, p.tprefor,
                                     1 nmovima, seg.fefecto fefecto, pc.ctippre, g.nriesgo,
                                     g.nmovimi, g.finiefe, seg.npoliza npoliza, p.cresdef,
                                     esccero
                                FROM pregunprogaran p, codipregun pc, seguros seg, garanseg g
                               WHERE p.sproduc = seg.sproduc
                                 AND p.cactivi = seg.cactivi
                                 AND p.cgarant = g.cgarant
                                 AND seg.sseguro = psseguro
                                 AND g.sseguro = seg.sseguro
                                 AND g.nmovimi = reg_movimientos.nmovimi
                                 AND g.ffinefe IS NULL
                                 AND pc.cpregun = p.cpregun
                                 AND(p.cpretip = 2
                                     OR(p.cpretip = 3
                                        AND p.esccero = 0))
                                 AND ptablas <> 'EST'
                            UNION
                            SELECT   p.cgarant, p.npreord, p.cpregun, p.cpretip, p.tprefor,
                                     1 nmovima, seg.fefecto fefecto, pc.ctippre, g.nriesgo,
                                     g.nmovimi, g.finiefe, seg.npoliza npoliza, p.cresdef,
                                     esccero
                                FROM pregunprogaran p, codipregun pc, estseguros seg,
                                     estgaranseg g
                               WHERE p.sproduc = seg.sproduc
                                 AND p.cactivi = seg.cactivi
                                 AND p.cgarant = g.cgarant
                                 AND seg.sseguro = psseguro
                                 AND g.sseguro = seg.sseguro
                                 AND g.nmovimi = reg_movimientos.nmovimi
                                 AND g.ffinefe IS NULL
                                 AND g.cobliga = 1
                                 AND pc.cpregun = p.cpregun
                                 AND(p.cpretip = 2
                                     OR(p.cpretip = 3
                                        AND p.esccero = 0))
                                 AND ptablas = 'EST'
                            ORDER BY npreord) LOOP
            v_resp := NULL;

            IF reg_garant.tprefor IS NOT NULL THEN
               -- se ha encontrado la fórmula para la pregunta
               nerror := pac_albsgt.f_tprefor(reg_garant.tprefor, ptablas, psseguro,
                                              reg_garant.nriesgo, reg_garant.fefecto,
                                              reg_movimientos.nmovimi, reg_garant.cgarant,
                                              v_resp, 1, 1, 0);

               IF v_resp IS NULL THEN
                  v_resp := reg_garant.cresdef;
               END IF;

               IF v_resp IS NOT NULL THEN
                  BEGIN
                     IF ptablas = 'EST' THEN
                        INSERT INTO estpregungaranseg
                                    (sseguro, nriesgo, cgarant,
                                     nmovimi, cpregun, crespue, nmovima,
                                     finiefe, trespue)
                             VALUES (psseguro, reg_garant.nriesgo, reg_garant.cgarant,
                                     reg_garant.nmovimi, reg_garant.cpregun, v_resp, 1,
                                     reg_garant.finiefe, NULL);
                     ELSE
                        INSERT INTO pregungaranseg
                                    (sseguro, nriesgo, cgarant,
                                     nmovimi, cpregun, crespue, nmovima,
                                     finiefe, trespue)
                             VALUES (psseguro, reg_garant.nriesgo, reg_garant.cgarant,
                                     reg_garant.nmovimi, reg_garant.cpregun, v_resp, 1,
                                     reg_garant.finiefe, NULL);
                     END IF;

                     COMMIT;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mig_axis.f_trata_preguntas_migracion', '1', '1',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_trata_preguntas_migracion;

/***************************************************************************
      FUNCTION f_migra_antiguedades
      función para migrar las antiguedades

      Bug 29738/163540 - 27/02/2014 - AMC
   ***************************************************************************/
   FUNCTION f_migra_antiguedades(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL',
      pmig_pk IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_1_anti       BOOLEAN := TRUE;
      v_anti         per_antiguedad%ROWTYPE;
      v_cont         NUMBER;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_sperson      estper_personas.spereal%TYPE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, p.idperson s_sperson, p.mig_pk mig_pk_per
                    FROM mig_per_antiguedad a, mig_personas p
                   WHERE p.mig_pk = a.mig_fk
                     AND p.mig_pk = NVL(pmig_pk, p.mig_pk)
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF ptablas = 'EST' THEN
               SELECT COUNT(*)
                 INTO v_cont
                 FROM estper_antiguedad
                WHERE sperson = x.s_sperson;
            ELSE
               SELECT COUNT(*)
                 INTO v_cont
                 FROM per_antiguedad
                WHERE sperson = x.s_sperson;
            END IF;

            IF v_cont = 0 THEN
               IF v_1_anti THEN
                  v_1_anti := FALSE;
                  num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'PER_ANTIGUEDAD');
               END IF;

               v_anti := NULL;
               v_error := FALSE;
               v_anti.sperson := x.s_sperson;
               v_anti.cagrupa := x.cagrupa;
               v_anti.norden := x.norden;
               v_anti.fantiguedad := x.fantiguedad;
               v_anti.cestado := x.cestado;
               v_anti.sseguro_ini := x.sseguro_ini;
               v_anti.nmovimi_ini := x.nmovimi_ini;
               v_anti.ffin := x.ffin;
               v_anti.sseguro_fin := x.sseguro_fin;
               v_anti.nmovimi_fin := x.nmovimi_fin;
               v_anti.falta := x.falta;
               v_anti.cusualt := x.cusualt;
               v_anti.fmodifi := x.fmodifi;
               v_anti.cusumod := x.cusumod;

               IF ptablas = 'EST' THEN
                  INSERT INTO estper_antiguedad
                       VALUES v_anti;
               ELSE
                  INSERT INTO per_antiguedad
                       VALUES v_anti;
               END IF;

               UPDATE mig_per_antiguedad
                  SET sperson = v_anti.sperson,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, -10,
                            v_anti.sperson || '|' || v_anti.fantiguedad);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_antiguedades;

/***************************************************************************
      FUNCTION f_migra_gescobros
      Función que inserta los registros grabados en MIG_GESCOBROS, en la tabla
      ASEGURADOS de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_gescobros(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_gescobro   BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_gescobros    gescobros%ROWTYPE;
      v_sperson      per_personas.sperson%TYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      --   COMMIT;
      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, p.idperson p_sperson
                    FROM mig_gescobros a, mig_seguros s, mig_personas p
                   WHERE p.mig_pk = a.mig_fk
                     AND s.mig_pk = a.mig_fk2
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_gescobro THEN
               v_1_gescobro := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'GESCOBROS');
            END IF;

            v_error := FALSE;
            v_gescobros := NULL;
            v_gescobros.sseguro := x.s_sseguro;
            v_gescobros.sperson := x.p_sperson;
            v_gescobros.cdomici := x.cdomici;

            IF ptablas = 'EST' THEN
               INSERT INTO estgescobros
                    VALUES v_gescobros;
            ELSE
               INSERT INTO gescobros
                    VALUES v_gescobros;
            END IF;

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1, x.s_sseguro || '|' || x.p_sperson);

            UPDATE mig_gescobros
               SET sseguro = v_gescobros.sseguro,
                   sperson = v_gescobros.sperson,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      SELECT COUNT(*)
        INTO v_cont
        FROM mig_logs_axis
       WHERE ncarga = pncarga
         AND tipo = 'E';

      IF v_cont > 0 THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_cont > 0 THEN
         RETURN v_cont;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_gescobros;

/***************************************************************************
      FUNCTION f_migra_coacuadro
      Función que inserta los registros grabados en MIG_COACUADRO, en la tabla
      COACUADRO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_coacuadro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_coacu      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_coacuadro    coacuadro%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      --      COMMIT;
      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_coacuadro a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_coacu THEN
               v_1_coacu := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'COACUADRO');
            END IF;

            v_error := NULL;
            v_coacuadro := NULL;
            v_coacuadro.sseguro := x.s_sseguro;
            v_coacuadro.ncuacoa := x.ncuacoa;
            v_coacuadro.finicoa := x.finicoa;
            v_coacuadro.ffincoa := x.ffincoa;
            v_coacuadro.ploccoa := x.ploccoa;
            v_coacuadro.fcuacoa := x.fcuacoa;
            v_coacuadro.ccompan := x.ccompan;
            v_coacuadro.npoliza := x.npoliza;

            -- 23289/120321 - ECP- 04/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estcoacuadro
                           (sseguro, ncuacoa, finicoa,
                            fcuacoa, ffincoa, ploccoa,
                            ccompan, npoliza)
                    VALUES (v_coacuadro.sseguro, v_coacuadro.ncuacoa, v_coacuadro.finicoa,
                            v_coacuadro.fcuacoa, v_coacuadro.ffincoa, v_coacuadro.ploccoa,
                            v_coacuadro.ccompan, v_coacuadro.npoliza);
            ELSE
               INSERT INTO coacuadro
                    VALUES v_coacuadro;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_coacuadro.sseguro || '|' || v_coacuadro.ncuacoa);

            UPDATE mig_coacuadro
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;
      --      COMMIT;
      END LOOP;

      --     SELECT COUNT(*)
      --      INTO v_cont
      --      FROM mig_logs_axis
      --     WHERE ncarga = pncarga
      --       AND tipo = 'E';
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_coacuadro;

/***************************************************************************
      FUNCTION f_migra_coacedido
      Función que inserta los registros grabados en MIG_COACEDIDO, en la tabla
      COACEDIDO de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         param in  ptablas      EST Simulaciones POL Pólizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_coacedido(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_coace      BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_coacedido    estcoacedido%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      --      COMMIT;
      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_coacedido a, mig_seguros s
                   WHERE s.mig_pk = a.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_coace THEN
               v_1_coace := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'COACEDIDO');
            END IF;

            v_error := NULL;
            v_coacedido := NULL;
            v_coacedido.sseguro := x.s_sseguro;
            v_coacedido.ncuacoa := x.ncuacoa;
            v_coacedido.ccompan := x.ccompan;
            v_coacedido.pcescoa := x.pcescoa;
            v_coacedido.pcomcoa := x.pcomcoa;
            v_coacedido.pcomcon := x.pcomcon;
            v_coacedido.pcomgas := x.pcomgas;
            v_coacedido.pcesion := x.pcesion;

            -- 23289/120321 - ECP- 04/09/2012 Inicio
            IF ptablas = 'EST' THEN
               INSERT INTO estcoacedido
                    VALUES v_coacedido;
            ELSE
               INSERT INTO coacedido
                    VALUES v_coacedido;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_coacedido.sseguro || '|' || v_coacedido.ncuacoa || '|'
                         || v_coacedido.ccompan);

            UPDATE mig_coacedido
               SET cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;
      --      COMMIT;
      END LOOP;

      --     SELECT COUNT(*)
      --      INTO v_cont
      --      FROM mig_logs_axis
      --     WHERE ncarga = pncarga
      --       AND tipo = 'E';
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_coacedido;

/***************************************************************************
      FUNCTION f_migra_detalle_riesgos
      Función que inserta los registros grabados en MIG_DETALLE_RIESGOS, en la tabla
      ASEGURADOS_INNOM de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_detalle_riesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_driesgo    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_aseg_innom   estasegurados_innom%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      --      COMMIT;
      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_detalle_riesgos a, mig_seguros s, mig_movseguro m
                   WHERE m.mig_pk = a.mig_fk
                     AND s.mig_pk = m.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_driesgo THEN
               v_1_driesgo := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'ASEGURADOS_INNOM');
            END IF;

            v_error := NULL;
            v_aseg_innom := NULL;
            v_aseg_innom.sseguro := x.s_sseguro;
            v_aseg_innom.nmovimi := x.nmovimi;
            v_aseg_innom.nriesgo := x.nriesgo;
            -- v_aseg_innom.NORDEN := x.norden;
            v_aseg_innom.nif := x.nif;
            v_aseg_innom.nombre := x.nombre;
            v_aseg_innom.apellidos := x.apellidos;
            v_aseg_innom.csexo := x.csexo;
            v_aseg_innom.fnacim := x.fnacim;
            v_aseg_innom.falta := x.falta;
            v_aseg_innom.fbaja := x.fbaja;

            -- 23289/120321 - ECP- 04/09/2012 Inicio
            IF ptablas = 'EST' THEN
               SELECT NVL(MAX(norden), 0) + 1
                 INTO v_aseg_innom.norden
                 FROM estasegurados_innom
                WHERE sseguro = v_aseg_innom.sseguro
                  AND nmovimi = v_aseg_innom.nmovimi
                  AND nriesgo = v_aseg_innom.nriesgo;

               INSERT INTO estasegurados_innom
                    VALUES v_aseg_innom;
            ELSE
               SELECT NVL(MAX(norden), 0) + 1
                 INTO v_aseg_innom.norden
                 FROM asegurados_innom
                WHERE sseguro = v_aseg_innom.sseguro
                  AND nmovimi = v_aseg_innom.nmovimi
                  AND nriesgo = v_aseg_innom.nriesgo;

               INSERT INTO asegurados_innom
                    VALUES v_aseg_innom;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_aseg_innom.sseguro || '|' || v_aseg_innom.nriesgo || '|'
                         || v_aseg_innom.nmovimi);

            UPDATE mig_detalle_riesgos
               SET sseguro = v_aseg_innom.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
         --   ROLLBACK;
         END;
      --      COMMIT;
      END LOOP;

      --     SELECT COUNT(*)
      --      INTO v_cont
      --      FROM mig_logs_axis
      --     WHERE ncarga = pncarga
      --       AND tipo = 'E';
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

/***************************************************************************
      FUNCTION f_migra_convenio_seg
      Función que inserta los registros grabados en MIG_CNV_CONV_EMP_SEG, en la tabla
      CNV_CONV_EMP_SEG de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_convenio_seg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_driesgo    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_conv_emp_seg cnv_conv_emp_seg%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      --      COMMIT;
      FOR x IN (SELECT   a.*, s.sseguro s_sseguro
                    FROM mig_cnv_conv_emp_seg a, mig_seguros s, mig_movseguro m
                   WHERE m.mig_pk = a.mig_fk
                     AND s.mig_pk = m.mig_fk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_driesgo THEN
               v_1_driesgo := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'CNV_CONV_EMP_SEG');
            END IF;

            v_error := NULL;
            v_conv_emp_seg := NULL;
            v_conv_emp_seg.sseguro := x.s_sseguro;
            v_conv_emp_seg.nmovimi := x.nmovimi;
            v_conv_emp_seg.falta := f_sysdate;
            v_conv_emp_seg.cusualt := f_user;

            BEGIN
               SELECT MAX(idversion)
                 INTO v_conv_emp_seg.idversion
                 FROM cnv_conv_emp emp, cnv_conv_emp_vers vers
                WHERE emp.tcodconv = x.tcodconv
                  AND emp.idconv = vers.idconv;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                                 'Error recuperdando convenio :' || x.tcodconv
                                                 || '- No existe en la tabla maestra');
                  v_error := TRUE;
            END;

            IF ptablas = 'EST' THEN
               INSERT INTO estcnv_conv_emp_seg
                           (sseguro, nmovimi,
                            idversion)
                    VALUES (v_conv_emp_seg.sseguro, v_conv_emp_seg.nmovimi,
                            v_conv_emp_seg.idversion);
            ELSE
               INSERT INTO cnv_conv_emp_seg
                    VALUES v_conv_emp_seg;
            END IF;

            -- 23289/120321 - ECP- 04/09/2012 Fin
            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, 1,
                         v_conv_emp_seg.sseguro || '|' || v_conv_emp_seg.nmovimi);

            UPDATE mig_cnv_conv_emp_seg
               SET sseguro = v_conv_emp_seg.sseguro,
                   cestmig = 2
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
         --               ROLLBACK;
         END;
      --      COMMIT;
      END LOOP;

      --     SELECT COUNT(*)
      --      INTO v_cont
      --      FROM mig_logs_axis
      --     WHERE ncarga = pncarga
      --       AND tipo = 'E';
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

--INI -- ETM --BUG 34776/202076--
   /***************************************************************************
      FUNCTION f_migra_bloqueoseg
      Función que inserta los bloqueos grabados en MIG_BLOQUEOSEG, en las distintas
      tablas de agentes de AXIS.
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_bloqueoseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_driesgo    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_bloqueoseg   bloqueoseg%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, m.cmotmov m_cmotmov
                    FROM mig_bloqueoseg a, mig_seguros s, mig_movseguro m
                   WHERE a.mig_fk = s.mig_pk
                     AND m.mig_fk = s.mig_pk
                     AND a.nmovimi = m.nmovimi
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_driesgo THEN
               v_1_driesgo := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'MIG_BLOQUEOSEG');
            END IF;

            v_error := NULL;
            v_bloqueoseg := NULL;
            v_bloqueoseg.sseguro := x.s_sseguro;
            v_bloqueoseg.finicio := x.finicio;
            v_bloqueoseg.ffinal := x.ffinal;
            v_bloqueoseg.iimporte := x.iimporte;
            v_bloqueoseg.ttexto := x.ttexto;
            v_bloqueoseg.nmovimi := x.nmovimi;
            v_bloqueoseg.nbloqueo := x.nbloqueo;

            IF x.mig_fk2 IS NOT NULL THEN
               SELECT p.idperson
                 INTO v_bloqueoseg.sperson
                 FROM mig_personas p
                WHERE p.mig_pk = x.mig_fk2;
            END IF;

            v_bloqueoseg.copcional := x.copcional;
            v_bloqueoseg.nrango := x.nrango;
            v_bloqueoseg.ncolater := x.ncolater;
            v_bloqueoseg.ctipocausa := x.ctipocausa;

            IF x.cmotmov IS NULL THEN
               IF x.ctipocausa IN(0, 1) THEN
                  v_bloqueoseg.cmotmov := 261;
               ELSIF x.ctipocausa IN(2, 3) THEN
                  v_bloqueoseg.cmotmov := 262;
               END IF;
            END IF;

            IF ptablas = 'POL' THEN
               INSERT INTO bloqueoseg
                    VALUES v_bloqueoseg;

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 1,
                            v_bloqueoseg.sseguro || '|' || v_bloqueoseg.nmovimi);

               UPDATE mig_bloqueoseg
                  SET sseguro = v_bloqueoseg.sseguro,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      --     SELECT COUNT(*)
      --      INTO v_cont
      --      FROM mig_logs_axis
      --     WHERE ncarga = pncarga
      --       AND tipo = 'E';
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

--FIN -- ETM --BUG 34776/202076--
--INI -- JLB --BUG 34776/213932--
  /***************************************************************************
     FUNCTION f_migra_psu_retenidas
      Función que inserta las polizas retenidas en MIG_PSU_RETENIDAS, en PSU_RETENIDAS
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_psu_retenidas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_1_driesgo    BOOLEAN := TRUE;
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_psu_retenidas psu_retenidas%ROWTYPE;
      v_cont         NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, s.sseguro s_sseguro, m.cmotmov m_cmotmov, m.nmovimi m_nmovimi
                    FROM mig_psu_retenidas a, mig_seguros s, mig_movseguro m
                   WHERE a.mig_fk = m.mig_pk
                     AND m.mig_fk = s.mig_pk
                     --       AND a.nmovimi = m.nmovimi
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_driesgo THEN
               v_1_driesgo := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, 1, 'MIG_PSU_RETENIDAS');
            END IF;

            v_error := NULL;
            v_psu_retenidas := NULL;
            v_psu_retenidas.sseguro := x.s_sseguro;
            v_psu_retenidas.nmovimi := x.m_nmovimi;
            v_psu_retenidas.fmovimi := x.fmovimi;
            v_psu_retenidas.cmotret := x.cmotret;
            v_psu_retenidas.cnivelbpm := 0;
            v_psu_retenidas.cusuret := x.cusuret;
            v_psu_retenidas.ffecret := x.ffecret;
            v_psu_retenidas.cusuaut := x.cusuaut;
            v_psu_retenidas.ffecaut := x.ffecaut;
            v_psu_retenidas.observ := x.observ;
            v_psu_retenidas.cdetmotrec := x.cdetmotrec;
            v_psu_retenidas.postpper := x.postpper;
            v_psu_retenidas.perpost := x.perpost;

            IF ptablas = 'POL' THEN
               INSERT INTO psu_retenidas
                    VALUES v_psu_retenidas;

               INSERT INTO mig_pk_mig_axis
                    VALUES (x.mig_pk, pncarga, pntab, 1,
                            v_psu_retenidas.sseguro || '|' || v_psu_retenidas.nmovimi);

               UPDATE mig_psu_retenidas
                  SET sseguro = v_psu_retenidas.sseguro,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;
            ELSE
               INSERT INTO estpsu_retenidas
                           (sseguro, nmovimi,
                            fmovimi, cmotret,
                            cnivelbpm, cusuret,
                            ffecret, cusuaut,
                            ffecaut, observ,
                            postpper, perpost)
                    VALUES (v_psu_retenidas.sseguro, v_psu_retenidas.nmovimi,
                            v_psu_retenidas.fmovimi, v_psu_retenidas.cmotret,
                            v_psu_retenidas.cnivelbpm, v_psu_retenidas.cusuret,
                            v_psu_retenidas.ffecret, v_psu_retenidas.cusuaut,
                            v_psu_retenidas.ffecaut, v_psu_retenidas.observ,
                            v_psu_retenidas.postpper, v_psu_retenidas.perpost);

               UPDATE mig_psu_retenidas
                  SET sseguro = v_psu_retenidas.sseguro,
                      cestmig = 2
                WHERE mig_pk = x.mig_pk;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      --     SELECT COUNT(*)
      --      INTO v_cont
      --      FROM mig_logs_axis
      --     WHERE ncarga = pncarga
      --       AND tipo = 'E';
      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_psu_retenidas;
/***************************************************************************
      FUNCTION f_migra_sin_prof_profesionales
      Función que inserta los registros grabados en MIG_PROF_PROFESIONALES, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_PROFESIONALES)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_profesionales(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_sinprof    BOOLEAN := TRUE;
      v_sprofes      sin_prof_profesionales.sprofes%TYPE;
      v_count       NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT   a.*, p.idperson p_sperson, p.cagente
                    FROM mig_sin_prof_profesionales a, mig_personas p
                   WHERE p.mig_pk = a.mig_pk
                     AND a.ncarga = pncarga
                     AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_sinprof THEN
               v_1_sinprof := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_PROFESIONALES');
            END IF;

            IF x.sprofes = 0 THEN
              SELECT NVL(MAX(sprofes) + 1, 0)
                INTO v_sprofes
                FROM sin_prof_profesionales;
            ELSE
              v_sprofes := x.sprofes;
            END IF;

            SELECT COUNT(1)
              INTO v_count
              FROM sin_prof_profesionales
             WHERE sperson = x.p_sperson;

            IF v_count = 0 THEN
              INSERT INTO sin_prof_profesionales
                        (sprofes, sperson, nregmer, fregmer, cdomici, cmodcon, nlimite, cnoasis)
                 VALUES (v_sprofes, x.p_sperson, x.nregmer, x.fregmer, x.cdomici, x.cmodcon, x.nlimite, x.cnoasis);

              INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes);

              UPDATE mig_sin_prof_profesionales
                 SET cestmig = 2,
                     sprofes = v_sprofes
               WHERE mig_pk = x.mig_pk;

            ELSE
              UPDATE sin_prof_profesionales
                 SET nregmer = x.nregmer,
                     fregmer = x.fregmer,
                     cdomici = x.cdomici,
                     cmodcon = x.cmodcon,
                     nlimite = x.nlimite,
                     cnoasis = x.nlimite
               WHERE sprofes = (SELECT sprofes FROM sin_prof_profesionales WHERE sperson = x.p_sperson AND rownum = 1);

              INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes);

              UPDATE mig_sin_prof_profesionales
                 SET cestmig = 2,
                     sprofes = v_sprofes
               WHERE mig_pk = x.mig_pk;

            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM || ' linea: '|| dbms_utility.format_error_backtrace);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_profesionales;

/***************************************************************************
      FUNCTION f_migra_sin_prof_indicadores
      Función que inserta los registros grabados en MIG_PROF_INDICADORES, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_INDICADORES)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_indicadores(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_indicador  BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes
                  FROM mig_sin_prof_indicadores a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_indicador THEN
               v_1_indicador := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_INDICADORES');
            END IF;

            INSERT INTO sin_prof_indicadores
                        (sprofes, ctipind, falta, cusualta)
                 VALUES (x.p_sprofes, x.ctipind, f_sysdate, f_user);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.ctipind);

            UPDATE mig_sin_prof_indicadores
               SET cestmig = 2,
                   sprofes = x.p_sprofes
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM || ' linea: '|| dbms_utility.format_error_backtrace);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_indicadores;
/***************************************************************************
      FUNCTION f_migra_sin_prof_rol
      Función que inserta los registros grabados en MIG_PROF_ROL, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_ROL)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_rol(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_rol  BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes
                  FROM mig_sin_prof_rol a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_rol THEN
               v_1_rol := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_ROL');
            END IF;

            INSERT INTO sin_prof_rol
                        (sprofes, CTIPPRO, CSUBPRO, CUSUALT, FALTA, FBAJA)
                 VALUES (x.p_sprofes, x.ctippro, x.csubpro, f_user, f_sysdate, x.fbaja);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.ctippro|| '|' ||x.csubpro);

            UPDATE mig_sin_prof_rol
               SET cestmig = 2,
                   sprofes = x.p_sprofes
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM  || ' linea: '|| dbms_utility.format_error_backtrace);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_rol;
/***************************************************************************
      FUNCTION f_migra_sin_prof_contactos
      Función que inserta los registros grabados en MIG_PROF_CONTACTOS, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_CONTACTOS)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_contactos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_contacto  BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes
                  FROM mig_sin_prof_contactos a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_contacto THEN
               v_1_contacto := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_CONTACTOS');
            END IF;

            INSERT INTO sin_prof_contactos
                        (sprofes, nordcto, ctipide, cnumide, tnombre, temail, tcargo, tdirec, tmovil, fbaja, falta, cusualt)
                 VALUES (x.p_sprofes, x.nordcto, x.ctipide, x.cnumide, x.tnombre, x.temail, x.tcargo, x.tdirec, x.tmovil, x.fbaja, f_sysdate, f_user);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.nordcto);

            UPDATE mig_sin_prof_contactos
               SET cestmig = 2,
                   sprofes = x.p_sprofes
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM || ' linea: '|| dbms_utility.format_error_backtrace);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_contactos;

/***************************************************************************
      FUNCTION f_migra_sin_prof_ccc
      Función que inserta los registros grabados en MIG_SIN_PROF_CCC, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_CCC)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_ccc(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_ccc  BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes
                  FROM mig_sin_prof_ccc a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_ccc THEN
               v_1_ccc := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_CCC');
            END IF;


            INSERT INTO sin_prof_ccc
                        (sprofes, cnorden, cramo, sproduc, cactivi, cnordban, cusualt, falta, fbaja)
                 VALUES (x.p_sprofes, x.cnorden, x.cramo, x.sproduc, x.cactivi, x.CNORDEN, f_user, f_sysdate, x.fbaja);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.cnorden);

            UPDATE mig_sin_prof_ccc
               SET cestmig = 2,
                   sprofes = x.p_sprofes
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_ccc;
/***************************************************************************
      FUNCTION f_migra_sin_prof_repre
      Función que inserta los registros grabados en MIG_SIN_PROF_REPRE, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_REPRE)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_repre(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err        NUMBER;
      v_error        BOOLEAN := FALSE;
      v_estdes       mig_cargas_tab_mig.estdes%TYPE;
      v_1_repre  BOOLEAN := TRUE;
      v_sperson NUMBER;
      v_person_sprof number;
      v_cagente NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes, p.mig_pk pk_sprof
                  FROM mig_sin_prof_repre a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_repre THEN
               v_1_repre := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_REPRE');
            END IF;

            SELECT idperson
              INTO v_sperson
              FROM mig_personas
             WHERE mig_pk = x.mig_pk;

            INSERT INTO sin_prof_repre
                        (SPROFES, SPERSON, CTELCON, CMAILCON, TCARGO, CUSUARI, FALTA, FBAJA)
                 VALUES (x.p_sprofes, v_sperson, 1, 1, x.tcargo, f_user, f_sysdate, x.fbaja);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.idperson);

            UPDATE mig_sin_prof_repre
               SET cestmig = 2,
                   sprofes = x.p_sprofes,
                   idperson = v_sperson
             WHERE mig_pk = x.mig_pk;


         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_repre;
/***************************************************************************
      FUNCTION f_migra_sin_prof_sede
      Función que inserta los registros grabados en MIG_SIN_PROF_SEDE, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_SEDE)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_sede(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err   NUMBER;
      v_error   BOOLEAN := FALSE;
      v_estdes  mig_cargas_tab_mig.estdes%TYPE;
      v_1_sede  BOOLEAN := TRUE;
      v_sperson NUMBER;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes
                  FROM mig_sin_prof_sede a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_sede THEN
               v_1_sede := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_SEDE');
            END IF;

            SELECT idperson
              INTO v_sperson
              FROM mig_personas
             WHERE mig_pk = x.mig_pk;


            INSERT INTO sin_prof_sede
                        (sprofes, spersed, thorari, cusualt, falta, tpercto)
                 VALUES (x.p_sprofes, v_sperson, x.thorari, f_user, f_sysdate, x.tpercto);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.idperson);

            UPDATE mig_sin_prof_sede
               SET cestmig = 2,
                   sprofes = x.p_sprofes,
                   idperson = v_sperson
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_sede;
/***************************************************************************
      FUNCTION f_migra_sin_prof_estados
      Función que inserta los registros grabados en MIG_SIN_PROF_ESTADOS, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_ESTADOS)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_estados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err   NUMBER;
      v_error   BOOLEAN := FALSE;
      v_estdes  mig_cargas_tab_mig.estdes%TYPE;
      v_1_estados  BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes
                  FROM mig_sin_prof_estados a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_estados THEN
               v_1_estados := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_ESTADOS');
            END IF;

            INSERT INTO sin_prof_estados
                        (sprofes, CESTADO, FESTADO, CMOTBAJ, TOBSERV, CUSUALT, FALTA)
                 VALUES (x.p_sprofes, x.cestado, x.festado, x.cmotbaj, x.tobserv, f_user, f_sysdate);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.festado);

            UPDATE mig_sin_prof_estados
               SET cestmig = 2,
                   sprofes = x.p_sprofes
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_estados;
/***************************************************************************
      FUNCTION f_migra_sin_prof_zonas
      Función que inserta los registros grabados en MIG_SIN_PROF_ZONAS, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_ZONAS)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_zonas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err   NUMBER;
      v_error   BOOLEAN := FALSE;
      v_estdes  mig_cargas_tab_mig.estdes%TYPE;
      v_1_zonas  BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes
                  FROM mig_sin_prof_zonas a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_zonas THEN
               v_1_zonas := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_ZONAS');
            END IF;

            INSERT INTO sin_prof_zonas
                        (sprofes, cnordzn, ctpzona, cpais, cprovin, cpoblac, falta, fdesde, fhasta, cusualt)
                 VALUES (x.p_sprofes, x.cnordzn, x.ctpzona, x.cpais, x.cprovin, x.cpoblac, f_sysdate, x.fdesde, x.fhasta, f_user);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.cnordzn);

            UPDATE mig_sin_prof_zonas
               SET cestmig = 2,
                   sprofes = x.p_sprofes
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_zonas;
/***************************************************************************
      FUNCTION f_migra_sin_prof_carga
      Función que inserta los registros grabados en MIG_SIN_PROF_CARGA, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_CARGA)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_carga(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err   NUMBER;
      v_error   BOOLEAN := FALSE;
      v_estdes  mig_cargas_tab_mig.estdes%TYPE;
      v_1_zonas  BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes
                  FROM mig_sin_prof_carga a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_zonas THEN
               v_1_zonas := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_ZONAS');
            END IF;

            INSERT INTO sin_prof_carga
                        (SPROFES, CTIPPRO, CSUBPRO, NCARDIA, NCARSEM, FDESDE, CUSUALT, FALTA)
                 VALUES (x.p_sprofes, x.ctippro, x.csubpro, x.ncardia, x.ncarsem, x.fdesde, f_user, f_sysdate);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.ctippro|| '|' ||x.csubpro|| '|' ||x.fdesde);

            UPDATE mig_sin_prof_carga
               SET cestmig = 2,
                   sprofes = x.p_sprofes
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_carga;
/***************************************************************************
      FUNCTION f_migra_sin_prof_observaciones
      Función que inserta los registros grabados en MIG_SIN_PROF_OBSERVACIONES, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_OBSERVACIONES)
         param in  pncarga:     Número de carga.
         param in  pntab:       Número de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_observaciones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      num_err   NUMBER;
      v_error   BOOLEAN := FALSE;
      v_estdes  mig_cargas_tab_mig.estdes%TYPE;
      v_1_obs  BOOLEAN := TRUE;
   BEGIN
      UPDATE mig_cargas_tab_mig
         SET finides = f_sysdate
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      FOR x IN (SELECT a.*, p.sprofes p_sprofes
                  FROM mig_sin_prof_observaciones a, mig_sin_prof_profesionales p
                 WHERE p.mig_pk = a.mig_fk
                   AND a.ncarga = pncarga
                   AND a.cestmig = 1
                ORDER BY a.mig_pk) LOOP
         BEGIN
            IF v_1_obs THEN
               v_1_obs := FALSE;
               num_err := f_ins_mig_cargas_tab_axis(pncarga, pntab, -10, 'SIN_PROF_OBSERVACIONES');
            END IF;

            INSERT INTO sin_prof_observaciones
                        (SPROFES, CNORDCM, TCOMENT, CUSUALT, FALTA)
                 VALUES (x.p_sprofes, x.cnordcm, x.tcoment, f_user, f_sysdate);

            INSERT INTO mig_pk_mig_axis
                 VALUES (x.mig_pk, pncarga, pntab, -10, x.sprofes|| '|' ||x.cnordcm);

            UPDATE mig_sin_prof_observaciones
               SET cestmig = 2,
                   sprofes = x.p_sprofes
             WHERE mig_pk = x.mig_pk;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := f_ins_mig_logs_axis(pncarga, x.mig_pk, 'E',
                                              'Error:' || SQLCODE || '-' || SQLERRM || ' lineap: '|| dbms_utility.format_error_backtrace);
               v_error := TRUE;
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      IF v_error THEN
         v_estdes := 'ERROR';
      ELSE
         v_estdes := 'OK';
      END IF;

      UPDATE mig_cargas_tab_mig
         SET ffindes = f_sysdate,
             estdes = v_estdes
       WHERE ncarga = pncarga
         AND ntab = pntab;

      COMMIT;

      IF v_error THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_migra_sin_prof_observaciones;
END pac_mig_axis;

/

  GRANT EXECUTE ON "AXIS"."PAC_MIG_AXIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MIG_AXIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MIG_AXIS" TO "PROGRAMADORESCSI";
