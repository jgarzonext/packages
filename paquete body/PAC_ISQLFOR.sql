--------------------------------------------------------
--  DDL for Package Body PAC_ISQLFOR
--------------------------------------------------------
create or replace PACKAGE BODY pac_isqlfor AS
      /******************************************************************************
         NOMBRE:       PAC_ISQLFOR
         PROP¿SITO: F¿rmulas de consultas de plantillas

         REVISIONES:
   --      Ver        Fecha       Autor    Descripci¿n
         ---------  ----------  -----    ------------------------------------
         1.0                             Creaci¿n del package.
         2.0        01f/04/2009  SBG      Modificaci¿ select de funci¿ f_cuestsaa
         3.0        02/04/2009  SBG      Modifs. a f_garantias_ass1 i f_capitales_ass1(BUG 9574)
         4.0        08/04/2009  SBG      Modifs. a f_garantias_ass1, f_capitales_ass1,
                                          f_titgarantias i f_capgarantias(BUG 9512)
         5.0        09/04/2009  SBG      Modifs. a f_capitales_ass1 (BUG 9505)
         6.0        23/04/2009  SBG      Nova funci¿ f_salud_preguntas (Bug 9472)
         7.0        29/04/2009  JTS      Noves funcions condicionat particular (Bug 8871)
         8.0        08/06/2009  DRA      0010134: ERROR INCLUSI¿ DE CL¿USULES TAR
         9.0        26/05/2009  APD      Bug 10199: se crea la funcion f_anulacion y f_importerescateparcial
        10.0        01/07/2009  APD      Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                  funci¿n pac_seguros.ff_get_actividad
        11.0        02/07/2009  MCA      Bug 10245 - Incorrecta definici¿ de la taula USUARIOS
        12.0        01/07/2009  JTS/NMM  10373: APR - condicionado particular.
        13.0        01/09/2009  JTS      10365 - Plantillas simulaciones
        14.0        07/09/2009  ASN      11006 - CRE - Condicionado particular para Creditvida sepeli
        15.0        16/09/2009  AMC      11165: Se sustitu¿e  T_iax_saldodeutorseg por t_iax_prestamoseg
        16.0        05/10/2009  DCT      11213 - CRE - Informar nacionalidad en producto Credit Vida Previsi¿
        17.0        02/11/2009  APD      11595: CEM - Siniestros. Adaptaci¿n al nuevo m¿dulo de siniestros
        18.0        03/11/2009  NMM      11654: CRE - Modificaci¿n plantillas PPJ /Pla Estudiant.
        19.0        19/11/2009  RSC      11993: CRE - Ajustes PPJ Din¿mico/Pla Estudiant
        20.0        30/11/2009  NMM      12101: CRE084 - A¿adir rentabilidad en consulta de p¿lizas.
        21.0        23/12/2009  NMM      12301: CRE084 - Plantilles retencions i suplements Pla Estudiant i PPJ Din¿mic.
        22.0        31/12/2009  JRH      12485: CEM201 - Incidencias varias PPA
        23.0        19/01/2010  ICV      12756: CRE200 - Incidencia en Fecha anulaci¿n en documento de baja.
        24.0        19/01/2010  JAS      12777: PPA: NO IMPRESSI¿ CONDICIONAT PARTICULAR
        25.0        20/01/2010  JTS      12764: CEM - Plantilla PPA
        26.0        03/02/2010  JTS      12839: CEM210 - Plantilles PIES
        27.0        05/02/2010  DRA      0010522: CRE069 - Modificaci¿n rtfs para incluir preguntas de los riegos
        28.0        24/02/2010  JTS      13025: CEM210: PLANTILLES RESCATS - CRS + PIES + PEA
        29.0        03/03/2010  JTS      13480: CEM800 - PLANTILLES: Capital garantit a venciment en duplicat de plantilles estalvi
        30.0        19/02/2010  JMF      0012803 AGA - Acceso a la vista PERSONAS
        31.0        15/04/2010  ICV      0013622: Simulation printout EIP 10947
        32.0        04/03/2010  JTS      13404: CEM800 - PLANTILLES: Nova plantilla per imprimir CTASEGURO
        33.0        18/05/2010  JMF      0012803 AGA - Acceso a la vista PERSONAS
        34.0        26/05/2010  ICV      0014249: APR800 - print out of policy
        35.0        15/07/2010  JTS      11651: AGA002 - Valores de rescate anual en productos de ahorro
        36.0        21/07/2010  JTS      14598: CEM800 - Informaci¿n adicional en pantallas y documentos
        37.0        07/07/2010  ETM      0014809: APR998 - Pas de plantilles de RTF a ODT--se a¿ade un campo para la plantillas de apra_srd
        38.0        03/09/2010  ETM      0015853: CEM808 - PLANTILLES: Situaci¿ actual de p¿lissa
        39.0        13/09/2010  JTS      0015795: CEM800 - PLANTILLES. Impressi¿ de CTASEGURO (CEM055)
        40.0        07/10/2010  ETM      0015795: CEM800 - PLANTILLES. Impressi¿ de CTASEGURO (CEM055)--QUE NO APAREZCAN ANULADOS
        41.0        10/08/2010  RSC      0014775: AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
        42.0        21/10/2010  DRA      0016373: CRE998 - Modificaci¿ pdf moviment compte asseguran¿a
        43.0        27/10/2010  ETM      0016494: CRS: INCORPORACI¿ INFO ADDICIONAL PANTALLA I DOCUMENT
        44.0        28/10/2010  ETM      0016459: print our extra prime unique
        45.0        05/11/2011  AMC      0016485: CRT101 - Modificar las plantillas de productos gen¿ricos
        46.0        10/11/2010  JTS      0016622: CRE800 - CVPrevisi¿ - P¿lisses sense condicions particulars
        47.0        12/01/2011  JMP      0016092: AGA601 - Impresi¿ productes RC
        48.0        27/01/2011  RSC      0017444: aportaci¿ ppa revalloritzaci¿ linea¿
        49.0        08/04/2011  RSC      0017657: MSGV101 - Creaci¿ i parametritzaci¿ producte Vida-Risc
        50.0        14/04/2011  FAL      0018172: CRT - Modificacion documentaci¿n
        51.0        17/06/2011  ETM      0018835: MSGV101 - Modificaci¿ de les condicions particulars per a que aparegui el deglos del rebut
        52.0        29/07/2011  APD      0019020: AGA800 - Simulaci¿ de Llar
        53.0        14/09/2011  DRA      0018682: AGM102 - Producto SobrePrecio- Definici¿n y Parametrizaci¿n
        54.0        27/09/2011  JMP      0019322: ENSA102-Segunda Documentaci¿n productos Contribuci¿n Definida Individual
        55.0        20/10/2011  JMF      0019779 condicionado del producto Transporte Mercaderias V. Flotante
        56.0        21/10/2011  JMP      0019780: GIP103 - condicionado del producto Transporte Mercader¿as CMR
        57.0        27/10/2011  MDS      0019726: AGM - Documentaci¿n del producto de sobre-precio
   --     58.0        23/11/2011  SVJ      0020257 AGM - Tipo de mediador en documentaci¿n
        59.0        10/04/2012  MDS      0021873: AGM - Documentaci¿n que genera iAxis en Siniestros (sobreprecio)
        60.0        30/04/2012  MDS      0022088: AGM - La consultas de 1321 no est¿ preparada cuando el nombre contiene un ap¿strofe.
        61.0        04/06/2012  MDS      0022009: AGM101 - Impresi¿n de los documentos relacionados (producci¿n, recibos, siniestros...)
        62.0        23/07/2012  ECP      0023077: ENSA102-Visualizaci?n erronea de los movimientos de CTASEGURO en la plantilla ENSA121
        63.0       02/08/2012  LCF       0022009  AGM - Parametros de Cla¿sulas - Entidad /Pr¿stamo
        64.0       17/08/2012  LCF       0022009  AGM - Presupuesto Plantilla EST Tablas
        65.0       13/02/2013  JMF       0025097: LCOL_T020-Qtrackers: 5609, 5624, 5625, 5626, 5627, 5628, 5629 i 5630
        66.0       16/02/2013  RDD       0024813   (POSDE100)-Desarrollo-GAPS Administracion-Id 109 - Reportes de comisiones
        67.0       10/05/2013  RDD       0024813: (POSDE100)-Desarrollo-GAPS Administracion-Id 109 - Reportes de comisiones NOTA 0144230
        68.0       23/09/2013  AGG       0028324: AGA800-DETALL PRIMA REBUT- Se a¿ade un par¿metro m¿s (n¿ 6) a la funci¿n F_CONREB_UNIFI para que devuelva el total de recargo de un recibo
        69.0       21/01/2014  JTT       0026501: Afegir el parametre npoliza a la crida de les funcio PAC_PROUCTOS.f_get_regunrespue
        70.0       19/05/2014  JTT       0029943: Afegir el parametre ndetar a la funcio F_provisio_actual
        71.0       18/08/2014  MMS       0031135: Montar Entorno Colmena en VAL
        72.0       29/10/2018  ACL       Ajuste al 42% aceptación personas. Se crea las funciones f_vinculo y f_codeudor.
        73.0       15/11/2018  WAJ       GE-FO-18-02: Ajuste Codigo Pais Alfanumerico
        74.0	   20/11/2018  KK     	 IAXIS-3152:Ficha financiera intermediario - Verificación datos
        75.0       20/09/2019  Swapnil   Cambios de IAXIS-5337		
      ******************************************************************************/
   FUNCTION f_ccc_mov(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER(8);
      vctipban       seguros.ctipban%TYPE;
      vcbancar       seguros.cbancar%TYPE;
      vcbancar_out   seguros.cbancar%TYPE;
      v_motiu        movseguro.cmotmov%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
   BEGIN
      BEGIN
         SELECT cmotmov, nmovimi
           INTO v_motiu, v_nmovimi
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM movseguro
                            WHERE sseguro = psseguro);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;

      IF v_motiu = 500 THEN
         SELECT cbancar, ctipban
           INTO vcbancar, vctipban
           FROM recibos
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi;
      ELSE
         SELECT cbancar, ctipban
           INTO vcbancar, vctipban
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      vnumerr := f_formatoccc(vcbancar, vcbancar_out, vctipban, 0);

      IF vnumerr <> 0 THEN   -- CCC espa¿olas
         vcbancar_out := vcbancar;
      END IF;

      RETURN vcbancar_out;
   END f_ccc_mov;

   FUNCTION f_ccc(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2
                     --JFD 01/10/2007 -- Se a¿aden adaptaciones para los diferentes formatos
                     --de tipos de CCC
   IS
      -- Devuelve el numero de CCC de una P¿liza
      vnumerr        NUMBER(8);
      ccc_vin        VARCHAR2(23);
      vctipban       seguros.ctipban%TYPE;
      vcbancar       seguros.cbancar%TYPE;
      vcbancar_out   seguros.cbancar%TYPE;
   BEGIN
      --(JAS)22.05.2005 Format de comptes segons tipus de compte bancari.
      /*
      SELECT    SUBSTR (cbancar, 1, 4)
             || '-'
             || SUBSTR (cbancar, 5, 4)
             || '-'
             || SUBSTR (cbancar, 9, 2)
             || '-'
             || SUBSTR (cbancar, 11),
             cbancar,
             ctipban
        INTO ccc_vin, xcbancar, xctipban
        FROM seguros
       WHERE sseguro = psseguro;

      if xctipban = 1 then -- CCC espa¿olas
         RETURN ccc_vin;
      else -- el resto se devuelven sin formatear
         return xcbancar;
      end if;
      */
      SELECT cbancar, ctipban
        INTO vcbancar, vctipban
        FROM seguros
       WHERE sseguro = psseguro;

      vnumerr := f_formatoccc(vcbancar, vcbancar_out, vctipban, 0);

      IF vnumerr <> 0 THEN   -- CCC espa¿olas
         vcbancar_out := vcbancar;
      END IF;

      RETURN vcbancar_out;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLERRM;
   END;

   FUNCTION f_fecha_pie(p_fecha IN DATE DEFAULT f_sysdate, p_idioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      fecha_pie      VARCHAR2(200);
      v_mes_lletres  VARCHAR2(40);
      v_concat_mes   VARCHAR2(40) := ' ';
      v_concat_any   VARCHAR2(40) := ' ';
   BEGIN
      SELECT UPPER(tatribu)
        INTO v_mes_lletres
        FROM detvalores
       WHERE cvalor = 54
         AND cidioma = NVL(p_idioma, 2)
         AND catribu = TO_NUMBER(TO_CHAR(p_fecha, 'MM'));

      --Bug.: 14444 ICV - 07/05/2010
      IF NVL(p_idioma, 2) IN(1, 7) THEN
         IF SUBSTR(v_mes_lletres, 1, 1) IN('A', 'O') THEN
            -- Mirem els mesos que porten un ap¿strof al davant: abril, agost i octubre
            v_concat_mes := ' ' || f_axis_literales(9901188, p_idioma) || CHR(39) || CHR(39);
         ELSE
            v_concat_mes := ' ' || f_axis_literales(9001853, p_idioma) || ' ';
         END IF;

         v_concat_any := ' ' || f_axis_literales(9001854, p_idioma) || ' ';
      --Bug.: 14444 ICV - 07/05/2010
      ELSIF NVL(p_idioma, 2) IN(4) THEN   --22659
         v_concat_mes := ' ' || f_axis_literales(9001853, p_idioma) || ' ';
         v_concat_any := ' ' || f_axis_literales(9001853, p_idioma) || ' ';
      ELSE
         --BUG 10373 - JTS - 26/06/2009
         v_concat_mes := ' ' || f_axis_literales(9001853, p_idioma) || ' ';
         v_concat_any := ' ' || f_axis_literales(9001854, p_idioma) || ' ';
      --BUG 10373 - JTS - 26/06/2009
      END IF;

      fecha_pie := TO_CHAR(p_fecha, 'DD') || v_concat_mes || INITCAP(v_mes_lletres)
                   || v_concat_any || TO_CHAR(p_fecha, 'YYYY');
      RETURN fecha_pie;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_persona(
      psseguro IN NUMBER DEFAULT NULL,
      pctipo IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
       -- F_PERSONA -> Devulve Apellidos y Nombre de la Persona en funci¿n del
      --              seguro y el tipo o ¿nicamente del sperson.
      --
      --    Pctipo -> 1 Tomador, 2 Asegurado, 3 Riesgo
      nombre         VARCHAR2(100);
   BEGIN
      IF psseguro IS NOT NULL
         AND pctipo IS NOT NULL THEN   --- Busqueda por seguro
         IF pctipo = 1 THEN   -- Tomador
            -- ini Bug 0012803 - 19/02/2010 - JMF
            -- SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
            --        || DECODE(tapelli1 || tapelli2,
            --                  NULL, NULL,
            --                  DECODE(tnombre, NULL, NULL, ', ')) || tnombre
            --   INTO nombre
            --   FROM tomadores, personas
            --  WHERE tomadores.sperson = personas.sperson
            --    AND tomadores.sseguro = psseguro;
            SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
                   || DECODE(tapelli1 || tapelli2,
                             NULL, NULL,
                             DECODE(tnombre, NULL, NULL, ', ')) || tnombre
              INTO nombre
              FROM seguros a, tomadores b, per_detper c
             WHERE a.sseguro = psseguro
               AND b.sseguro = a.sseguro
               AND c.sperson = b.sperson
               AND c.cagente = ff_agente_cpervisio(a.cagente, f_sysdate, a.cempres);
         -- fin Bug 0012803 - 19/02/2010 - JMF
         ELSIF pctipo = 2 THEN   -- Asegurado
            -- ini Bug 0012803 - 19/02/2010 - JMF
            -- SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
            --        || DECODE(tapelli1 || tapelli2,
            --                  NULL, NULL,
            --                  DECODE(tnombre, NULL, NULL, ', ')) || tnombre
            --   INTO nombre
            --   FROM asegurados, personas
            --  WHERE asegurados.sperson = personas.sperson
            --    AND asegurados.sseguro = psseguro;
            SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
                   || DECODE(tapelli1 || tapelli2,
                             NULL, NULL,
                             DECODE(tnombre, NULL, NULL, ', ')) || tnombre
              INTO nombre
              FROM seguros a, asegurados b, per_detper c
             WHERE a.sseguro = psseguro
               AND b.sseguro = a.sseguro
               AND c.sperson = b.sperson
               AND c.cagente = ff_agente_cpervisio(a.cagente, f_sysdate, a.cempres);
         -- fin Bug 0012803 - 19/02/2010 - JMF
         ELSIF pctipo = 3 THEN   -- Riesgo
            -- ini Bug 0012803 - 19/02/2010 - JMF
            -- SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
            --        || DECODE(tapelli1 || tapelli2,
            --                  NULL, NULL,
            --                  DECODE(tnombre, NULL, NULL, ', ')) || tnombre
            --   INTO nombre
            --   FROM riesgos, personas
            --  WHERE riesgos.sperson = personas.sperson
            --    AND riesgos.sseguro = psseguro;
            SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
                   || DECODE(tapelli1 || tapelli2,
                             NULL, NULL,
                             DECODE(tnombre, NULL, NULL, ', ')) || tnombre
              INTO nombre
              FROM seguros a, riesgos b, per_detper c
             WHERE a.sseguro = psseguro
               AND b.sseguro = a.sseguro
               AND c.sperson = b.sperson
               AND c.cagente = ff_agente_cpervisio(a.cagente, f_sysdate, a.cempres);
         -- fin Bug 0012803 - 19/02/2010 - JMF
         END IF;
      ELSE   --- busqueda por persona
         -- ini Bug 0012803 - 18/05/2010 - JMF
         -- SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
         --        || DECODE(tapelli1 || tapelli2, NULL, NULL, DECODE(tnombre, NULL, NULL, ', '))
         --        || tnombre
         --   INTO nombre
         --   FROM personas
         --  WHERE personas.sperson = psperson;
         --bug correccion para el bug 2485 antes usaba la tabla personas
         SELECT UPPER(DRTP.TNOMBRE ||DECODE(DRTP.TNOMBRE, NULL, NULL, ' ')||  DRTP.TAPELLI1||DECODE(DRTP.TAPELLI1, NULL, NULL, ' ')||
          DRTP.TAPELLI2||DECODE(DRTP.TAPELLI2, NULL, NULL, ' ')) NOMBRE INTO nombre FROM PER_PERSONAS PES, PER_DETPER DRTP
          WHERE DRTP.SPERSON=PES.SPERSON
          AND PES.SPERSON =psperson;
           --fn bug 24822
      -- fin Bug 0012803 - 18/05/2010 - JMF
      END IF;

      nombre := REPLACE(nombre, CHR(39), CHR(39) || CHR(39));
      RETURN UPPER(nombre);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_persona;

   FUNCTION f_dni(
      psseguro IN NUMBER DEFAULT NULL,
      pctipo IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
       -- F_DNI -> Devulve DNI EN FUNCI¿N DEL
      --              seguro y el tipo o ¿nicamente del sperson.
      --
      --    Pctipo -> 1 Tomador, 2 Asegurado, 3 Riesgo
      dni            VARCHAR2(100);
   BEGIN
      IF psseguro IS NOT NULL
         AND pctipo IS NOT NULL THEN   --- Busqueda por seguro
         IF pctipo = 1 THEN   -- Tomador
            SELECT nnumide   --nnumnif
              INTO dni
              FROM tomadores, per_personas a   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE tomadores.sperson = a.sperson
               AND tomadores.sseguro = psseguro;
         ELSIF pctipo = 2 THEN   -- Asegurado
            SELECT nnumide   --nnumnif
              INTO dni
              FROM asegurados, per_personas a   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE asegurados.sperson = a.sperson
               AND asegurados.sseguro = psseguro;
         ELSIF pctipo = 3 THEN   -- Riesgo
            SELECT nnumide   --nnumnif
              INTO dni
              FROM riesgos, per_personas a   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE riesgos.sperson = a.sperson
               AND riesgos.sseguro = psseguro;
         END IF;
      ELSE   --- busqueda por persona
         SELECT nnumide   --nnumnif
           INTO dni
           FROM per_personas a   -- Bug 0012803 - 19/02/2010 - JMF
          WHERE a.sperson = psperson;
      END IF;

      RETURN dni;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_dni;

   FUNCTION f_domicilio(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_DOMICILIO --> Devuelve la direcci¿n de la persona
      --                 en funci¿n del tipo de domicilio.
      domicilio      VARCHAR2(150);
   BEGIN
      SELECT tdomici
        INTO domicilio
        FROM per_direcciones
       WHERE per_direcciones.sperson = psperson
         AND per_direcciones.cdomici = pcdomici;

      domicilio := REPLACE(domicilio, CHR(39), CHR(39) || CHR(39));
      RETURN domicilio;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_domicilio;

   FUNCTION f_tcomple(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_DOMICILIO --> Devuelve la descripci¿n complementaria
      --                 en funci¿n del tipo de domicilio.
      comple      VARCHAR2(100);
   BEGIN
      SELECT tcomple
        INTO comple
        FROM per_direcciones
       WHERE per_direcciones.sperson = psperson
         AND per_direcciones.cdomici = pcdomici;

      RETURN comple;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tcomple;

   FUNCTION f_numvia(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_DOMICILIO --> Devuelve la descripci¿n complementaria
      --                 en funci¿n del tipo de domicilio.
      numvia      VARCHAR2(100);
   BEGIN
      SELECT nnumvia
        INTO numvia
        FROM per_direcciones
       WHERE per_direcciones.sperson = psperson
         AND per_direcciones.cdomici = pcdomici;

      RETURN numvia;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_numvia;

   FUNCTION f_nomvia(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_DOMICILIO --> Devuelve el nombre de la via
      --                 en funci¿n del tipo de domicilio.
      nomvia      VARCHAR2(200);
   BEGIN
      SELECT tnomvia
        INTO nomvia
        FROM per_direcciones
       WHERE per_direcciones.sperson = psperson
         AND per_direcciones.cdomici = pcdomici;

      RETURN nomvia;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_nomvia;
   -- Devuleve el domicilio del riesgo en funcion del sseguro
   FUNCTION f_domiciriesgo(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      domicilio      VARCHAR2(150);
   BEGIN
      SELECT tdomici
        INTO domicilio
        FROM per_direcciones, riesgos
       WHERE per_direcciones.sperson = riesgos.sperson
         AND per_direcciones.cdomici = NVL(riesgos.cdomici, 1)
         AND riesgos.sseguro = psseguro
         AND riesgos.fanulac IS NULL
         AND ROWNUM = 1;

      domicilio := REPLACE(domicilio, CHR(39), CHR(39) || CHR(39));
      RETURN domicilio;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_domiciriesgo;

   -- Poblaci¿n del riesgo
   FUNCTION f_pobriesgo(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      poblacion      VARCHAR2(150);
   BEGIN
      SELECT tpoblac
        INTO poblacion
        FROM per_direcciones, poblaciones, riesgos
       WHERE per_direcciones.sperson = riesgos.sperson
         AND riesgos.sseguro = psseguro
         AND per_direcciones.cdomici = NVL(riesgos.cdomici, 1)
         AND per_direcciones.cprovin = poblaciones.cprovin
         AND per_direcciones.cpoblac = poblaciones.cpoblac
         AND ROWNUM = 1;

      poblacion := REPLACE(poblacion, CHR(39), CHR(39) || CHR(39));
      RETURN poblacion;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_pobriesgo;

   FUNCTION f_nacim(
      psseguro IN NUMBER DEFAULT NULL,
      pctipo IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      -- F_PERSONA -> Devulve Fecha de Nacimiento de la Persona en funci¿n del
      --              seguro y el tipo o ¿nicamente del sperson.
      --
      --    Pctipo -> 1 EstTomador, 2 EsgtAsegurado, 3 EstRiesgo, 4 Tomadores, 5 Asegurados, 6 Riesgos, 7 Estdotado, 8 Dotado
      v_fnacimi      VARCHAR2(10);
   BEGIN
      IF psseguro IS NOT NULL
         AND pctipo IS NOT NULL THEN
         --- Busqueda por seguro
         IF pctipo = 1 THEN   -- Tomador
            SELECT TO_CHAR(fnacimi, 'dd/mm/yyyy')
              INTO v_fnacimi
              FROM esttomadores t, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE t.sperson = p.sperson
               AND t.sseguro = psseguro;
         ELSIF pctipo = 2 THEN   -- Asegurado
            SELECT TO_CHAR(fnacimi, 'dd/mm/yyyy')
              INTO v_fnacimi
              FROM estassegurats a, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE a.sperson = p.sperson
               AND a.sseguro = psseguro;
         ELSIF pctipo = 3 THEN   -- Riesgo
            SELECT TO_CHAR(fnacimi, 'dd/mm/yyyy')
              INTO v_fnacimi
              FROM estriesgos e, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE e.sperson = p.sperson
               AND e.sseguro = psseguro;
         ELSIF pctipo = 4 THEN   -- Tomador
            SELECT TO_CHAR(fnacimi, 'dd/mm/yyyy')
              INTO v_fnacimi
              FROM tomadores t, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE t.sperson = p.sperson
               AND t.sseguro = psseguro;
         ELSIF pctipo = 5 THEN   -- Asegurado
            SELECT TO_CHAR(fnacimi, 'dd/mm/yyyy')
              INTO v_fnacimi
              FROM asegurados a, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE a.sperson = p.sperson
               AND a.sseguro = psseguro;
         ELSIF pctipo = 6 THEN   -- Riesgo
            SELECT TO_CHAR(fnacimi, 'dd/mm/yyyy')
              INTO v_fnacimi
              FROM riesgos e, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE e.sperson = p.sperson
               AND e.sseguro = psseguro;
         END IF;
      ELSE   --- busqueda por persona
         SELECT TO_CHAR(fnacimi, 'dd/mm/yyyy')
           INTO v_fnacimi
           FROM per_personas   -- Bug 0012803 - 19/02/2010 - JMF
          WHERE sperson = psperson;
      END IF;

      RETURN v_fnacimi;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_nacim;

   FUNCTION f_sexo(
      psseguro IN NUMBER DEFAULT NULL,
      pctipo IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      -- F_PERSONA -> Devulve el sexo de la Persona en funci¿n del
      --              seguro y el tipo o ¿nicamente del sperson.
      --
      --    Pctipo -> 1 Tomador, 2 Asegurado, 3 Riesgo, 7 Estdotado, 8 Dotado
      v_sexo         NUMBER;
   BEGIN
      IF psseguro IS NOT NULL
         AND pctipo IS NOT NULL THEN
         --- Busqueda por seguro
         IF pctipo = 1 THEN   -- Tomador
            SELECT csexper
              INTO v_sexo
              FROM esttomadores t, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE t.sperson = p.sperson
               AND t.sseguro = psseguro;
         ELSIF pctipo = 2 THEN   -- Asegurado
            SELECT csexper
              INTO v_sexo
              FROM estassegurats a, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE a.sperson = p.sperson
               AND a.sseguro = psseguro;
         ELSIF pctipo = 3 THEN   -- Riesgo
            SELECT csexper
              INTO v_sexo
              FROM estriesgos e, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE e.sperson = p.sperson
               AND e.sseguro = psseguro;
         ELSIF pctipo = 4 THEN   -- Tomador
            SELECT csexper
              INTO v_sexo
              FROM tomadores t, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE t.sperson = p.sperson
               AND t.sseguro = psseguro;
         ELSIF pctipo = 5 THEN   -- Asegurado
            SELECT csexper
              INTO v_sexo
              FROM asegurados a, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE a.sperson = p.sperson
               AND a.sseguro = psseguro;
         ELSIF pctipo = 6 THEN   -- Riesgo
            SELECT csexper
              INTO v_sexo
              FROM riesgos e, per_personas p   -- Bug 0012803 - 19/02/2010 - JMF
             WHERE e.sperson = p.sperson
               AND e.sseguro = psseguro;
         /*ELSIF pctipo = 7 THEN                                       -- Estdotado
            SELECT csexper
              INTO v_sexo
              FROM estdotado e, per_personas p -- Bug 0012803 - 19/02/2010 - JMF
             WHERE e.sperson = p.sperson
               AND e.sseguro = psseguro;
         ELSIF pctipo = 8 THEN                                       -- Dotado
            SELECT csexper
              INTO v_sexo
              FROM dotado e, per_personas p -- Bug 0012803 - 19/02/2010 - JMF
             WHERE e.sperson = p.sperson
               AND e.sseguro = psseguro;*/
         END IF;
      ELSE   --- busqueda por persona
         SELECT csexper
           INTO v_sexo
           FROM per_personas   -- Bug 0012803 - 19/02/2010 - JMF
          WHERE sperson = psperson;
      END IF;

      RETURN v_sexo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_sexo;

   -- Provincia  del riesgo
   FUNCTION f_provriesgo(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      provincia      VARCHAR2(150);
   BEGIN
      SELECT tprovin
        INTO provincia
        FROM per_direcciones, provincias, riesgos
       WHERE per_direcciones.sperson = riesgos.sperson
         AND riesgos.sseguro = psseguro
         AND per_direcciones.cdomici = NVL(riesgos.cdomici, 1)
         AND per_direcciones.cprovin = provincias.cprovin
         AND ROWNUM = 1;

      provincia := REPLACE(provincia, CHR(39), CHR(39) || CHR(39));
      RETURN provincia;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_provriesgo;

   FUNCTION f_codpostal(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_CODPOSTAL--> Devuelve el c¿digo postal de la persona
      --                 en funci¿n del tipo de domicilio.
      postal         codpostal.cpostal%TYPE;
   --3606 jdomingo 30/11/2007  canvi format codi postal
   BEGIN
      SELECT cpostal   --3606 jdomingo 30/11/2007  canvi format codi postal
        INTO postal
        FROM per_direcciones
       WHERE per_direcciones.sperson = psperson
         AND per_direcciones.cdomici = pcdomici;

      RETURN postal;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_codpostal;

   -- cp DEL RIESGO
   FUNCTION f_cpriesgo(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      postal         codpostal.cpostal%TYPE;
   --3606 jdomingo 30/11/2007  canvi format codi postal
   BEGIN
      SELECT cpostal   --3606 jdomingo 30/11/2007  canvi format codi postal
        INTO postal
        FROM per_direcciones, riesgos
       WHERE per_direcciones.sperson = riesgos.sperson
         AND riesgos.sseguro = psseguro
         AND per_direcciones.cdomici = NVL(riesgos.cdomici, 1)
         AND ROWNUM = 1;

      RETURN postal;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_cpriesgo;

   -- Devuelve la poblacion del agente- oficina
   FUNCTION f_pobagente(pcagente IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR IS
      poblacion      VARCHAR2(150);
   BEGIN
      SELECT tpoblac
        INTO poblacion
        FROM per_direcciones, poblaciones, agentes
       WHERE per_direcciones.sperson = agentes.sperson
         AND agentes.cagente = pcagente
         AND per_direcciones.cdomici = pcdomici
         AND per_direcciones.cprovin = poblaciones.cprovin
         AND per_direcciones.cpoblac = poblaciones.cpoblac;

      poblacion := REPLACE(poblacion, CHR(39), CHR(39) || CHR(39));
      RETURN poblacion;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_poblacion(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_POBLACION--> Devuelve la poblacion de la persona
      --                 en funci¿n del tipo de domicilio.
      poblacion      VARCHAR2(150);
   BEGIN
      SELECT tpoblac
        INTO poblacion
        FROM per_direcciones, poblaciones
       WHERE per_direcciones.sperson = psperson
         AND per_direcciones.cdomici = pcdomici
         AND per_direcciones.cprovin = poblaciones.cprovin
         AND per_direcciones.cpoblac = poblaciones.cpoblac;

      poblacion := REPLACE(poblacion, CHR(39), CHR(39) || CHR(39));
      RETURN poblacion;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_poblacion;

   FUNCTION f_provincia(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_PROVINCIA--> Devuelve la PROVINCIA de la persona
      --                 en funci¿n del tipo de domicilio.
      provincia      VARCHAR2(150);
   BEGIN
      SELECT tprovin
        INTO provincia
        FROM per_direcciones, provincias
       WHERE per_direcciones.sperson = psperson
         AND per_direcciones.cdomici = pcdomici
         AND per_direcciones.cprovin = provincias.cprovin;

      provincia := REPLACE(provincia, CHR(39), CHR(39) || CHR(39));
      RETURN provincia;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_provincia;

   FUNCTION f_dirpais(
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pcidioma IN NUMBER DEFAULT f_usu_idioma)
      RETURN VARCHAR2 IS
      -- F_DIRPAIS--> Devuelve la EL PAIS de la persona
      --                 en funci¿n del tipo de domicilio.
      pais           VARCHAR2(150);
   BEGIN
      SELECT tpais
        INTO pais
        FROM per_direcciones, provincias, despaises
       WHERE per_direcciones.sperson = psperson
         AND per_direcciones.cdomici = pcdomici
         AND per_direcciones.cprovin = provincias.cprovin
         AND provincias.cpais = despaises.cpais
         AND despaises.cidioma = pcidioma;

      pais := REPLACE(pais, CHR(39), CHR(39) || CHR(39));
      RETURN pais;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_dirpais;

   FUNCTION f_nacion(psperson IN NUMBER)
      RETURN VARCHAR2 IS
      vpais          despaises.tpais%TYPE;
   BEGIN
      SELECT tpais
        INTO vpais
        FROM per_nacionalidades n, despaises p
       WHERE n.cpais = p.cpais
         AND n.sperson = psperson
         AND p.cidioma = NVL(pac_isql.rgidioma,
                             pac_contexto.f_contextovalorparametro('IAX_IDIOMA'))
         AND ROWNUM = 1;

      vpais := REPLACE(vpais, CHR(39), CHR(39) || CHR(39));
      RETURN(vpais);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_nacion;

   FUNCTION f_profesion(psperson IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_PROFESION-> Devuelve la PROFESI¿N de la persona en funci¿n del idioma.
      profesion      VARCHAR2(250);
   BEGIN
      -- ini Bug 0012803 - 19/02/2010 - JMF
      -- SELECT tprofes
      --   INTO profesion
      --   FROM profesiones, personas
      --  WHERE profesiones.cprofes = personas.cprofes
      --    AND personas.sperson = psperson
      --    AND profesiones.cidioma = pcidioma;
      --
      -- Busco la visible por usuario.
      SELECT MAX(a.tprofes)
        INTO profesion
        FROM profesiones a, per_detper b
       WHERE a.cprofes = b.cprofes
         AND b.sperson = psperson
         AND a.cidioma = pcidioma
         AND b.cagente = ff_agenteprod();

      IF profesion IS NULL THEN
         -- Como es para plantillas, busco la ultima.
         SELECT a.tprofes
           INTO profesion
           FROM profesiones a, per_detper b
          WHERE a.cprofes = b.cprofes
            AND b.sperson = psperson
            AND a.cidioma = pcidioma
            AND b.fmovimi = (SELECT MAX(b1.fmovimi)
                               FROM per_detper b1
                              WHERE b1.sperson = b.sperson);
      END IF;

      -- fin Bug 0012803 - 19/02/2010 - JMF
      profesion := REPLACE(profesion, CHR(39), CHR(39) || CHR(39));
      RETURN profesion;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_matricula(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve la matr¿cula del riesgo de un seguro
      matricula      VARCHAR2(20);
      riesgo         NUMBER;
   BEGIN
      IF priesgo IS NULL THEN
         riesgo := 1;
      ELSE
         riesgo := priesgo;
      END IF;

      SELECT SUBSTR(cmatric, 1, 11)
        INTO matricula
        FROM autriesgos r, aut_versiones v
       WHERE r.cversion = v.cversion
         AND sseguro = psseguro
         AND nriesgo = riesgo
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM autriesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = riesgo);

      RETURN matricula;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_marca(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve la MARCA del riesgo de un seguro
      marca          VARCHAR2(100);
      riesgo         NUMBER;
   BEGIN
      IF priesgo IS NULL THEN
         riesgo := 1;
      ELSE
         riesgo := priesgo;
      END IF;

      SELECT pac_autos.f_desmarca(v.cmarca)
        INTO marca
        FROM autriesgos r, aut_versiones v
       WHERE r.cversion = v.cversion
         AND r.sseguro = psseguro
         AND r.nriesgo = riesgo
         AND r.nmovimi = (SELECT MAX(nmovimi)
                            FROM autriesgos
                           WHERE sseguro = psseguro
                             AND nriesgo = riesgo);

      marca := REPLACE(marca, CHR(39), CHR(39) || CHR(39));
      RETURN marca;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_version(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve la VERSIONdel riesgo de un seguro
      v_version      VARCHAR2(500);
      riesgo         NUMBER;
   BEGIN
      IF priesgo IS NULL THEN
         riesgo := 1;
      ELSE
         riesgo := priesgo;
      END IF;

      SELECT aut_versiones.tversion
        INTO v_version
        FROM autriesgos, aut_versiones
       WHERE sseguro = psseguro
         AND autriesgos.cversion = aut_versiones.cversion
         AND nriesgo = riesgo
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM autriesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = riesgo);

      v_version := REPLACE(v_version, CHR(39), CHR(39) || CHR(39));
      RETURN v_version;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_importe(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve el importe del riesgo de un seguro de autos
      importe        VARCHAR2(100);
      riesgo         NUMBER;
   BEGIN
      IF priesgo IS NULL THEN
         riesgo := 1;
      ELSE
         riesgo := priesgo;
      END IF;

      SELECT TO_CHAR(NVL(ivehicu, 0), 'FM999G999G990D00')
        INTO importe
        FROM autriesgos
       WHERE sseguro = psseguro
         AND nriesgo = riesgo
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM autriesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = riesgo);

      RETURN importe;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_modelo(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve el modelo del riesgo de un seguro
      modelo         VARCHAR2(100);
      riesgo         NUMBER;
   BEGIN
      IF priesgo IS NULL THEN
         riesgo := 1;
      ELSE
         riesgo := priesgo;
      END IF;

      SELECT pac_autos.f_desmodelo(v.cmodelo, v.cmarca)
        INTO modelo
        FROM autriesgos r, aut_versiones v
       WHERE r.cversion = v.cversion
         AND r.sseguro = psseguro
         AND r.nriesgo = riesgo
         AND r.nmovimi = (SELECT MAX(nmovimi)
                            FROM autriesgos
                           WHERE sseguro = psseguro
                             AND nriesgo = riesgo);

      modelo := REPLACE(modelo, CHR(39), CHR(39) || CHR(39));
      RETURN modelo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_clase(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve la CLASE DE VEHICULO del riesgo de un seguro
      clase          VARCHAR2(100);
      riesgo         NUMBER;
   BEGIN
           -- Bug 9224 - 24/02/2009 - APD - Se comenta el codigo ya que falta pasarle por parametro el cidioma
           -- De momento, la funcion devuelve un null
      /*
            IF priesgo IS NULL THEN
               riesgo := 1;
            ELSE
               riesgo := priesgo;
            END IF;

            SELECT d.tclaveh
              INTO clase
              FROM autriesgos r, aut_versiones v, aut_tipoclase t, aut_desclaveh d
             WHERE r.cversion = v.cversion
               AND t.ctipveh = v.ctipveh
               AND t.cclaveh = v.cclaveh
               AND d.cclaveh = t.cclaveh
               AND d.cidioma = 1
               AND sseguro = psseguro
               AND nriesgo = riesgo
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM autriesgos
                               WHERE sseguro = psseguro
                                 AND nriesgo = riesgo);

            clase := REPLACE(clase, CHR(39), CHR(39) || CHR(39));
            RETURN clase;
      */
      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_matriculacion(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve LA FECHA DE LA PRIMERA MATRICULACI¿N DEL VEHICULO
      fecha          VARCHAR2(100);
      riesgo         NUMBER;
   BEGIN
      IF priesgo IS NULL THEN
         riesgo := 1;
      ELSE
         riesgo := priesgo;
      END IF;

      SELECT TO_CHAR(fmatric, 'dd/mm/yyyy')
        INTO fecha
        FROM autriesgos r
       WHERE sseguro = psseguro
         AND nriesgo = riesgo
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM autriesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = riesgo);

      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_cia(psseguro IN NUMBER, pcia IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve la compa¿ia del seguro o del c¿digo
      cia            VARCHAR2(100);
   BEGIN
      IF pcia IS NOT NULL THEN
         SELECT tcompani
           INTO cia
           FROM companias
          WHERE companias.ccompani = pcia;
      ELSIF psseguro IS NOT NULL THEN
         SELECT tcompani
           INTO cia
           FROM companias, seguros
          WHERE seguros.sseguro = psseguro
            AND seguros.ccompani = companias.ccompani;
      END IF;

      cia := REPLACE(cia, CHR(39), CHR(39) || CHR(39));
      RETURN cia;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_usuario
      RETURN VARCHAR2 IS
      usuario        VARCHAR2(100);
   BEGIN
      SELECT tusunom
        INTO usuario
        FROM usuarios
       WHERE cusuari = f_user;

      -- BUG10134:08/06/2009:DRA:Inici
      usuario := REPLACE(usuario, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN usuario;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_ramo(pramo IN NUMBER, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
      ramo           VARCHAR2(100);
   BEGIN
      SELECT tramo
        INTO ramo
        FROM ramos
       WHERE cidioma = pidioma
         AND cramo = pramo;

      ramo := REPLACE(ramo, CHR(39), CHR(39) || CHR(39));
      RETURN ramo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_agente(pcagente IN NUMBER)
      RETURN VARCHAR IS
      agente         VARCHAR2(100);
   BEGIN
      -- Busqueda del Agente / Oficina del Seguro
      IF pcagente IS NOT NULL THEN
         SELECT f_persona(NULL, NULL, sperson)
           INTO agente
           FROM agentes
          WHERE cagente = pcagente;
      END IF;

      --agente := REPLACE (agente, CHR (39), CHR (39) || CHR (39));
      RETURN agente;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_firma
      RETURN VARCHAR2 IS
      usuario        VARCHAR2(100);
   BEGIN
      SELECT tusunom
        INTO usuario
        FROM usuarios
       WHERE cusuari = f_user;

      usuario := REPLACE(usuario, CHR(39), CHR(39) || CHR(39));
      RETURN usuario;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_telefono(psperson IN NUMBER)
      RETURN VARCHAR2 IS
      telefono       VARCHAR2(100);
   BEGIN
      SELECT tvalcon
        INTO telefono
        FROM contactos
       WHERE contactos.sperson = psperson
         AND ROWNUM = 1
         AND ctipcon = 1;

      RETURN telefono;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

    FUNCTION f_telefono_movil(psperson IN NUMBER)
      RETURN VARCHAR2 IS
      telefono       VARCHAR2(100);
   BEGIN
      SELECT tvalcon
        INTO telefono
        FROM contactos
       WHERE contactos.sperson = psperson
         AND ROWNUM = 1
         AND ctipcon = 6;

      RETURN telefono;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_telefono_movil;


   FUNCTION f_conductor(psseguro IN NUMBER DEFAULT NULL, psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
       -- F_PERSONA -> Devulve cONDUCTOR HABITUAL la Persona en funci¿n del
      --              seguro o ¿nicamente del sperson.
      --
      nombre         VARCHAR2(100);
   BEGIN
      IF psseguro IS NOT NULL THEN   --- Busqueda por seguro
         SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
                || DECODE(tapelli1 || tapelli2, NULL, NULL, DECODE(tnombre, NULL, NULL, ', '))
                || tnombre
           INTO nombre
           FROM autconductores, personas
          WHERE autconductores.sperson = personas.sperson
            AND autconductores.sseguro = psseguro
            AND autconductores.nriesgo = 1;
      ELSE
         SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
                || DECODE(tapelli1 || tapelli2, NULL, NULL, DECODE(tnombre, NULL, NULL, ', '))
                || tnombre
           INTO nombre
           FROM personas
          WHERE personas.sperson = psperson;
      END IF;

      nombre := REPLACE(nombre, CHR(39), CHR(39) || CHR(39));
      RETURN nombre;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_conductor;

   FUNCTION f_sexoconductor(psseguro IN NUMBER DEFAULT NULL, psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
       -- F_SEXOCONDUCTOR -> Devulve EL SEXO la Persona en funci¿n del
      --              seguro o ¿nicamente del sperson.
      --
      numsexo        NUMBER;
      sexo           VARCHAR2(100);
      err            NUMBER;
   BEGIN
      IF psseguro IS NOT NULL THEN   --- Busqueda por seguro
         SELECT p.csexper
           INTO numsexo
           FROM autconductores, per_personas p
          WHERE autconductores.sperson = p.sperson
            AND autconductores.sseguro = psseguro
            AND autconductores.nriesgo = 1;
      ELSE
         SELECT csexper
           INTO numsexo
           FROM per_personas
          WHERE sperson = psperson;
      END IF;

      err := f_desvalorfijo(11, 1, numsexo, sexo);
      RETURN sexo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_sexoconductor;

   FUNCTION f_permiso(psseguro IN NUMBER DEFAULT NULL, psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
       -- F_PERMISO -> Devulve EL nif la Persona en funci¿n del
      --              seguro o ¿nicamente del sperson.
      --
      permiso        VARCHAR2(100);
      err            NUMBER;
   BEGIN
      IF psseguro IS NOT NULL THEN   --- Busqueda por seguro
         SELECT p.nnumide
           INTO permiso
           FROM autconductores, per_personas p
          WHERE autconductores.sperson = p.sperson
            AND autconductores.sseguro = psseguro
            AND autconductores.nriesgo = 1;
      ELSE
         SELECT p.nnumide
           INTO permiso
           FROM per_personas p
          WHERE p.sperson = psperson;
      END IF;

      RETURN permiso;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_permiso;

   /*
      FUNCTION f_fpermiso (psseguro IN NUMBER DEFAULT NULL)
         RETURN VARCHAR2
      IS
          -- F_FPERMISO -> Devulve la fecha del carnet de conducir del
         --              seguro
         --
         fpermiso   VARCHAR2 (100);
         err        NUMBER;
      BEGIN
         SELECT TO_CHAR (fcarnet, 'DD/MM/YYYY')
           INTO fpermiso
           FROM autconductor, personas, autcarnet
          WHERE autconductor.sperson = personas.sperson
            AND autconductor.ctipcar = autcarnet.ctipcar
            AND autconductor.sperson = autcarnet.sperson
            AND autconductor.sseguro = psseguro
            AND autconductor.nriesgo = 1;

         RETURN fpermiso;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END f_fpermiso;
   */
   -- Nombre de la empresa del seguro
   FUNCTION f_cobbancario(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      cobrador       VARCHAR2(200);
      err            NUMBER;
   BEGIN
      SELECT tapelli
        INTO cobrador
        FROM seguros, cobbancario, personas
       WHERE seguros.sseguro = psseguro
         AND seguros.ccobban = cobbancario.ccobban
         AND cobbancario.nnumnif = personas.nnumnif;

      -- BUG10134:08/06/2009:DRA:Inici
      cobrador := REPLACE(cobrador, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN cobrador;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_cobbancario;

   -- Nombre de la empresa del seguro
   FUNCTION f_empresa(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      empresa        VARCHAR2(200);
      err            NUMBER;
   BEGIN
      SELECT UPPER(tempres)
        INTO empresa
        FROM empresas, seguros
       WHERE seguros.sseguro = psseguro
         AND seguros.cempres = empresas.cempres;

      empresa := REPLACE(empresa, CHR(39), CHR(39) || CHR(39));
      RETURN empresa;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_empresa;

   -- Nombre del plan de pensiones del seguro
   FUNCTION f_plan(psseguro IN NUMBER DEFAULT NULL, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
      PLAN           VARCHAR2(200);
      err            NUMBER;
   BEGIN
      SELECT UPPER(ttitulo)
        INTO PLAN
        FROM productos, seguros, titulopro
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = productos.sproduc
         AND productos.cramo = titulopro.cramo
         AND productos.cmodali = titulopro.cmodali
         AND productos.ctipseg = titulopro.ctipseg
         AND productos.ccolect = titulopro.ccolect
         AND titulopro.cidioma = pidioma;

      PLAN := REPLACE(PLAN, CHR(39), CHR(39) || CHR(39));
      RETURN PLAN;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_plan;

   -- C¿digo del plan de pensiones del seguro
   FUNCTION f_codplan(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      PLAN           VARCHAR2(200);
      err            NUMBER;
   BEGIN
      SELECT planpensiones.coddgs
        INTO PLAN
        FROM productos, seguros, proplapen, planpensiones
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = productos.sproduc
         AND productos.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla;

      RETURN PLAN;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_codplan;

   -- Nombre del fondo de pensiones
   FUNCTION f_fondo(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      fondo          VARCHAR2(200);
      err            NUMBER;
   BEGIN
      -- Bug 15289 - APD - 07/02/2011 - se sustituye la vista personas por la tabla per_detper
      SELECT per_detper.tapelli1
        INTO fondo
        FROM productos, seguros, proplapen, planpensiones, fonpensiones, per_detper
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = productos.sproduc
         AND productos.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla
         AND fonpensiones.ccodfon = planpensiones.ccodfon
         AND fonpensiones.sperson = per_detper.sperson
         AND per_detper.cagente = ff_agente_cpervisio(seguros.cagente, f_sysdate,
                                                      seguros.cempres);

      -- Fin Bug 15289 - APD - 07/02/2011
      fondo := REPLACE(fondo, CHR(39), CHR(39) || CHR(39));
      RETURN fondo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- Bug 15289 - APD - 07/02/2011 -- se crea la exception NO_DATA_FOUND por si
         -- da algun error la select
         SELECT personas.tapelli
           INTO fondo
           FROM productos, seguros, proplapen, planpensiones, fonpensiones, personas
          WHERE seguros.sseguro = psseguro
            AND seguros.sproduc = productos.sproduc
            AND productos.sproduc = proplapen.sproduc
            AND proplapen.ccodpla = planpensiones.ccodpla
            AND fonpensiones.ccodfon = planpensiones.ccodfon
            AND fonpensiones.sperson = personas.sperson;

         fondo := REPLACE(fondo, CHR(39), CHR(39) || CHR(39));
         RETURN fondo;
      -- Fin Bug 15289 - APD - 07/02/2011
      WHEN OTHERS THEN
         RETURN NULL;
   END f_fondo;

   -- C¿digo del fondo de pensiones
   FUNCTION f_codfondo(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      fondo          VARCHAR2(200);
      err            NUMBER;
   BEGIN
      SELECT 'F-' || TO_CHAR(planpensiones.ccodfon, 'FM0000')
        INTO fondo
        FROM productos, seguros, proplapen, planpensiones
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = productos.sproduc
         AND productos.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla;

      RETURN fondo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_codfondo;

   -- Nombre de la gestora
   FUNCTION f_gestora(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      gestora        VARCHAR2(200);
      err            NUMBER;
   BEGIN
      SELECT personas.tapelli
        INTO gestora
        FROM productos, seguros, proplapen, planpensiones, fonpensiones, gestoras, personas
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = productos.sproduc
         AND productos.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla
         AND fonpensiones.ccodfon = planpensiones.ccodfon
         AND fonpensiones.ccodges = gestoras.ccodges
         AND gestoras.sperson = personas.sperson;

      gestora := REPLACE(gestora, CHR(39), CHR(39) || CHR(39));
      RETURN gestora;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_gestora;

   -- C¿digo de la entidad gestora
   FUNCTION f_codgestora(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      gestora        VARCHAR2(200);
      err            NUMBER;
   BEGIN
      SELECT 'G/' || fonpensiones.ccodges
        INTO gestora
        FROM productos, seguros, proplapen, planpensiones, fonpensiones
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = productos.sproduc
         AND productos.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla
         AND planpensiones.ccodfon = fonpensiones.ccodfon;

      RETURN gestora;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_codgestora;

   -- Nombre de la DEPOSITARIA
   FUNCTION f_depositaria(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      depositaria    VARCHAR2(200);
      err            NUMBER;
   BEGIN
      SELECT personas.tapelli
        INTO depositaria
        FROM productos, seguros, proplapen, planpensiones, fonpensiones, personas,
             depositarias   --JGM: se quita gestoras
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = productos.sproduc
         AND productos.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla
         AND fonpensiones.ccodfon = planpensiones.ccodfon
         --JGM: se quita gestoras, AND fonpensiones.ccodges = gestoras.ccodges
         --JGM: se quita gestoras, AND gestoras.ccoddep = depositarias.ccoddep
         AND fonpensiones.ccoddep = depositarias.ccoddep
         AND depositarias.sperson = personas.sperson;

      depositaria := REPLACE(depositaria, CHR(39), CHR(39) || CHR(39));
      RETURN depositaria;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_depositaria;

   -- C¿digo de la entidad depositaria
   FUNCTION f_coddepositaria(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      depositaria    VARCHAR2(200);
      err            NUMBER;
   BEGIN
      SELECT 'D/' || fonpensiones.ccodges
        INTO depositaria
        FROM productos, seguros, proplapen, planpensiones,
             fonpensiones   --JGM: no hace falta, gestoras
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = productos.sproduc
         AND productos.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla
         AND planpensiones.ccodfon = fonpensiones.ccodfon;

      RETURN depositaria;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_coddepositaria;

   FUNCTION f_motsin(pnsinies IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve el motivo del siniestro
      motivo         VARCHAR2(100);
      v_cempres      NUMBER;
   BEGIN
      -- BUG 11595 - 02/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros
      -- Para este caso, en vez de buscar por el parempresa 'MODULO_SINI' para saber si se
      -- est¿ en el m¿dulo antiguo o nuevo de siniestros (ya que se necesita la empresa del
      -- seguro para buscar el valor del parempresa) se parte de que por defecto se est¿
      -- en el modelo nuevo, y si no hay datos se busca en el modelo antiguo.
      BEGIN
         SELECT tmotsin
           INTO motivo
           FROM sin_desmotcau, sin_siniestro, seguros
          WHERE sin_siniestro.nsinies = pnsinies
            AND seguros.sseguro = sin_siniestro.sseguro
            AND sin_siniestro.cmotsin = sin_desmotcau.cmotsin
            AND sin_siniestro.ccausin = sin_desmotcau.ccausin
            AND sin_desmotcau.cidioma =
                    NVL(pac_isql.rgidioma, pac_contexto.f_contextovalorparametro('IAX_IDIOMA'));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT tmotsin
              INTO motivo
              FROM desmotsini, siniestros, seguros
             WHERE siniestros.nsinies = pnsinies
               AND seguros.sseguro = siniestros.sseguro
               AND desmotsini.cramo = seguros.cramo
               AND siniestros.cmotsin = desmotsini.cmotsin
               AND siniestros.ccausin = desmotsini.ccausin
               AND desmotsini.cidioma =
                     NVL(pac_isql.rgidioma,
                         pac_contexto.f_contextovalorparametro('IAX_IDIOMA'));
      END;

      motivo := REPLACE(motivo, CHR(39), CHR(39) || CHR(39));
      RETURN motivo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_causin(pnsinies IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve la causa del siniestro
      causa          VARCHAR2(100);
   BEGIN
      -- BUG 11595 - 02/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros
      -- Para este caso, en vez de buscar por el parempresa 'MODULO_SINI' para saber si se
      -- est¿ en el m¿dulo antiguo o nuevo de siniestros (ya que se necesita la empresa del
      -- seguro para buscar el valor del parempresa) se parte de que por defecto se est¿
      -- en el modelo nuevo, y si no hay datos se busca en el modelo antiguo.
      BEGIN
         SELECT tcausin
           INTO causa
           FROM sin_descausa, sin_siniestro
          WHERE sin_siniestro.nsinies = pnsinies
            AND sin_siniestro.ccausin = sin_descausa.ccausin
            AND sin_descausa.cidioma = NVL(pac_isql.rgidioma,
                                           pac_contexto.f_contextovalorparametro('IAX_IDIOMA'));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT tcausin
              INTO causa
              FROM causasini, siniestros
             WHERE siniestros.nsinies = pnsinies
               AND siniestros.ccausin = causasini.ccausin
               AND causasini.cidioma = NVL(pac_isql.rgidioma,
                                           pac_contexto.f_contextovalorparametro('IAX_IDIOMA'));
      END;

      -- Fin BUG 11595 - 02/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros
      causa := REPLACE(causa, CHR(39), CHR(39) || CHR(39));
      RETURN causa;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_tramitador(pnsinies IN NUMBER)
      RETURN VARCHAR2 IS
      -- Devuelve la causa del siniestro
      tramitador     VARCHAR2(100);
   BEGIN
      -- BUG 11595 - 02/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros
      -- Para este caso, en vez de buscar por el parempresa 'MODULO_SINI' para saber si se
      -- est¿ en el m¿dulo antiguo o nuevo de siniestros (ya que se necesita la empresa del
      -- seguro para buscar el valor del parempresa) se parte de que por defecto se est¿
      -- en el modelo nuevo, y si no hay datos se busca en el modelo antiguo.
      BEGIN
         SELECT tusunom
           INTO tramitador
           FROM usuarios, sin_siniestro, sin_movsiniestro
          WHERE sin_siniestro.nsinies = pnsinies
            AND sin_siniestro.nsinies = sin_movsiniestro.nsinies
            AND sin_movsiniestro.nmovsin = (SELECT MAX(nmovsin)
                                              FROM sin_movsiniestro
                                             WHERE nsinies = sin_movsiniestro.nsinies)
            AND usuarios.cusuari = sin_movsiniestro.ctramitad;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT tusunom
              INTO tramitador
              FROM usuarios, siniestros
             WHERE siniestros.nsinies = pnsinies
               AND usuarios.cusuari = siniestros.ctraint;
      END;

      -- Fin BUG 11595 - 02/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros
      tramitador := REPLACE(tramitador, CHR(39), CHR(39) || CHR(39));
      RETURN tramitador;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   ---***************************** Tablas sol *************
   FUNCTION f_solnomcon(pdni IN VARCHAR2)
      RETURN VARCHAR2 IS
      nombre         VARCHAR2(100);
   BEGIN
      SELECT tnombre || ' ' || tapelli1 || ' ' || tapelli2
        INTO nombre
        FROM personas
       WHERE nnumnif = pdni;

      nombre := REPLACE(nombre, CHR(39), CHR(39) || CHR(39));
      RETURN nombre;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_solcodpostalcon(pdni IN VARCHAR2, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      postal         codpostal.cpostal%TYPE;
   --3606 jdomingo 30/11/2007  canvi format codi postal
   BEGIN
      SELECT cpostal   --3606 jdomingo 30/11/2007  canvi format codi postal
        INTO postal
        FROM per_direcciones, personas
       WHERE per_direcciones.sperson = personas.sperson
         AND personas.nnumnif = pdni
         AND per_direcciones.cdomici = pcdomici;

      RETURN postal;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_soltelefonocon(pdni IN VARCHAR2)
      RETURN VARCHAR2 IS
      telefono       VARCHAR2(100);
   BEGIN
      SELECT tvalcon
        INTO telefono
        FROM contactos, personas
       WHERE contactos.sperson = personas.sperson
         AND personas.nnumnif = pdni
         AND ROWNUM = 1
         AND ctipcon = 1;

      RETURN telefono;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_solnacimientocon(pdni IN VARCHAR2)
      RETURN VARCHAR2 IS
      fecha          VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(fnacimi, 'DD/MM/YYYY')
        INTO fecha
        FROM personas
       WHERE personas.nnumnif = pdni;

      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_solfcarnetcon(pdni IN VARCHAR2)
      RETURN VARCHAR2 IS
      fcarnet        VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(fnacimi, 'DD/MM/YYYY')
        INTO fcarnet
        FROM personas
       WHERE personas.nnumnif = pdni;

      RETURN fcarnet;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_soltitulopro(pssolici IN VARCHAR2)
      RETURN VARCHAR2 IS
      titulo         VARCHAR2(100);
   BEGIN
      SELECT trotulo
        INTO titulo
        FROM titulopro, solseguros
       WHERE solseguros.cramo = titulopro.cramo
         AND solseguros.cmodali = titulopro.cmodali
         AND solseguros.ctipseg = titulopro.ctipseg
         AND solseguros.ccolect = titulopro.ccolect
         AND titulopro.cidioma = pac_isql.rgidioma
         AND solseguros.ssolicit = pssolici;

      -- BUG10134:08/06/2009:DRA:Inici
      titulo := REPLACE(titulo, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN titulo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_titulopro(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      titulo         VARCHAR2(100);
   BEGIN
      SELECT ttitulo
        INTO titulo
        FROM titulopro, seguros
       WHERE seguros.cramo = titulopro.cramo
         AND seguros.cmodali = titulopro.cmodali
         AND seguros.ctipseg = titulopro.ctipseg
         AND seguros.ccolect = titulopro.ccolect
         --AND TITULOPRO.CIDIOMA = Pac_Isql.RgIdioma
         AND titulopro.cidioma = NVL(pac_isql.rgidioma,
                                     pac_contexto.f_contextovalorparametro('IAX_IDIOMA'))
         AND seguros.sseguro = psseguro;

      titulo := REPLACE(titulo, CHR(39), CHR(39) || CHR(39));
      RETURN titulo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_nacimiento(psperson IN NUMBER)
      RETURN VARCHAR2 IS
      fecha          VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(fnacimi, 'DD/MM/YYYY')
        INTO fecha
        FROM per_personas
       WHERE sperson = psperson;

      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_carnet(psperson IN NUMBER)
      RETURN VARCHAR2 IS
      fcarnet        VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(fnacimi, 'DD/MM/YYYY')
        INTO fcarnet
        FROM per_personas
       WHERE sperson = psperson;

      RETURN fcarnet;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_nomconductor(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2 IS
      nombre         VARCHAR2(100);
   BEGIN
      SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
             || DECODE(tapelli1 || tapelli2, NULL, NULL, DECODE(tnombre, NULL, NULL, ', '))
             || tnombre
        INTO nombre
        FROM personas, autconductores
       WHERE personas.sperson = autconductores.sperson
         AND autconductores.sseguro = psseguro
         AND personas.sperson = autconductores.sperson
         AND autconductores.norden = pnorden;

      nombre := REPLACE(nombre, CHR(39), CHR(39) || CHR(39));
      RETURN nombre;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_dniconductor(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2 IS
      dni            VARCHAR2(100);
   BEGIN
      SELECT nnumide
        INTO dni
        FROM per_personas p, autconductores
       WHERE p.sperson = autconductores.sperson
         AND autconductores.sseguro = psseguro
         AND autconductores.norden = pnorden;

      RETURN dni;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_cpconductor(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2 IS
      postal         codpostal.cpostal%TYPE;
   --3606 jdomingo 30/11/2007  canvi format codi postal
   BEGIN
      SELECT cpostal   --3606 jdomingo 30/11/2007  canvi format codi postal
        INTO postal
        FROM per_direcciones, autconductores
       WHERE per_direcciones.sperson = autconductores.sperson
         AND autconductores.sseguro = psseguro
         AND autconductores.norden = pnorden
         AND per_direcciones.cdomici = 1;

      RETURN postal;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_telconductor(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2 IS
      tel            VARCHAR2(100);
   BEGIN
         /*
            SELECT tvalcon
              INTO tel
              FROM contactos, autconductores
             WHERE autconductores.sseguro = psseguro
               AND contactos.sperson = autconductores.sperson
               AND autconductor.norden = pnorden
               AND contactos.ctipcon = 1
               AND cmodcon = 1;
      */
      RETURN tel;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_nacimiconductor(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2 IS
      fecha          VARCHAR2(10);
   BEGIN
         /*
            SELECT TO_CHAR(fnacimi, 'DD/MM/YYYY')
              INTO fecha
              FROM personas, autconductor
             WHERE personas.sperson = autconductor.sperson
               AND autconductor.sseguro = psseguro
               AND autconductor.nriesgo = pnorden;
      */
      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   /*
      FUNCTION f_fcarnetconductor (psseguro IN NUMBER, pnorden IN NUMBER)
         RETURN VARCHAR2
      IS
         fecha   VARCHAR2 (10);
      BEGIN
         SELECT TO_CHAR (fcarnet, 'DD/MM/YYYY')
           INTO fecha
           FROM personas, autconductor, autcarnet
          WHERE personas.sperson = autconductor.sperson
            AND autconductor.sseguro = psseguro
            AND autcarnet.sperson = autconductor.sperson
            AND autconductor.norden = pnorden;

         RETURN fecha;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;
   */
   FUNCTION f_sexoriesgo(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2 IS
      numsexo        NUMBER;
      err            NUMBER;
      sexo           VARCHAR2(10);
   BEGIN
      SELECT csexper
        INTO numsexo
        FROM personas, riesgos
       WHERE riesgos.sseguro = psseguro
         AND personas.sperson = riesgos.sperson
         AND riesgos.nriesgo = NVL(pnriesgo, 1);

      err := f_desvalorfijo(11, 2, numsexo, sexo);
      RETURN sexo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   -- Prima periodica
   FUNCTION f_primaperiodo(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      prima          VARCHAR2(100);
      err            NUMBER;
   BEGIN
      SELECT TO_CHAR(icapital, 'FM999G999G990D00') || ' EUR'
        INTO prima
        FROM garanseg
       WHERE sseguro = psseguro
         AND ffinefe IS NULL
         AND cgarant = 48;

      RETURN prima;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_primaperiodo;

   -- Prima Extraordinaria
   FUNCTION f_primaextra(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      prima          VARCHAR2(100);
      err            NUMBER;
      cuantos        NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO cuantos
        FROM movseguro
       WHERE sseguro = psseguro;

      IF cuantos > 1 THEN   --> sUPLEMENTO
         prima := NULL;
      ELSE
         SELECT TO_CHAR(SUM(imovimi), 'FM999G999G990D00') || ' EUR'
           INTO prima
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND cmovimi = 1
            AND cmovanu = 0;
      END IF;

      RETURN prima;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_primaextra;

   FUNCTION f_primaanual(p_seguro IN NUMBER, p_riesgo IN NUMBER, p_movimi IN NUMBER)
      RETURN NUMBER IS
      -- INI JMF 16-05-2006: Generamos funci¿n para la consulta 38 de las plantillas.
      -- Riesgo y movimiento son opcionales. Siempre busca el ¿ltimo movimiento.
      n_ret          garanseg.ipritot%TYPE;   -- Suma de iprianu.
   BEGIN
      SELECT SUM(iprianu)
        INTO n_ret
        FROM garanseg g
       WHERE g.ffinefe IS NULL
         AND(p_riesgo IS NULL
             OR g.nriesgo = p_riesgo)
         AND g.nmovimi = (SELECT MAX(nmovimi)
                            FROM garanseg g2
                           WHERE g2.ffinefe IS NULL
                             AND(p_movimi IS NULL
                                 OR g2.nmovimi <= p_movimi)
                             AND(p_riesgo IS NULL
                                 OR g2.nriesgo = p_riesgo)
                             AND g2.sseguro = g.sseguro)
         AND g.sseguro = p_seguro;

      RETURN n_ret;
   -- FIN JMF 16-05-2006: Generamos funci¿n para la consulta 38 de las plantillas.
   END f_primaanual;

   FUNCTION f_primarecargo(p_seguro IN NUMBER, p_riesgo IN NUMBER, p_movimi IN NUMBER)
      RETURN NUMBER IS
      -- INI JMF 16-05-2006: Generamos funci¿n para la consulta 38 de las plantillas.
      -- Riesgo y movimiento son opcionales. Siempre busca el ¿ltimo movimiento.
      n_ret          garanseg.ipritot%TYPE;   -- Suma de iprianu.
   BEGIN
      SELECT SUM(irecarg)
        INTO n_ret
        FROM garanseg g
       WHERE g.ffinefe IS NULL
         AND(p_riesgo IS NULL
             OR g.nriesgo = p_riesgo)
         AND g.nmovimi = (SELECT MAX(nmovimi)
                            FROM garanseg g2
                           WHERE g2.ffinefe IS NULL
                             AND(p_movimi IS NULL
                                 OR g2.nmovimi <= p_movimi)
                             AND(p_riesgo IS NULL
                                 OR g2.nriesgo = p_riesgo)
                             AND g2.sseguro = g.sseguro)
         AND g.sseguro = p_seguro;

      RETURN n_ret;
   -- FIN JMF 16-05-2006: Generamos funci¿n para la consulta 38 de las plantillas.
   END f_primarecargo;

   -- Porcentaje de revalorizaci¿n
   FUNCTION f_revalorizacion(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      rev            VARCHAR2(100);
      err            NUMBER;
   BEGIN
      SELECT TO_CHAR(prevali, 'FM990D00') || ' %'
        INTO rev
        FROM garanseg
       WHERE sseguro = psseguro
         AND ffinefe IS NULL
         AND cgarant = 48;

      RETURN rev;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '0.00 %';
   END f_revalorizacion;

--------------------------------------------------------------------------------

   -- Forma de pago del seguro
   FUNCTION f_formapago(
      p_sseguro IN NUMBER,
      p_idioma IN NUMBER DEFAULT 2,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      v_tforpag      VARCHAR2(100);
      v_cforpag      NUMBER;
   BEGIN
      IF NVL(p_mode, 'POL') = 'EST' THEN
         SELECT cforpag
           INTO v_cforpag
           FROM estseguros
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT cforpag
           INTO v_cforpag
           FROM seguros
          WHERE sseguro = p_sseguro;
      END IF;

      SELECT tatribu
        INTO v_tforpag
        FROM detvalores
       WHERE cvalor = 17
         AND detvalores.cidioma = NVL(p_idioma, 2)
         AND catribu = v_cforpag;

      -- BUG10134:08/06/2009:DRA:Inici
      v_tforpag := REPLACE(v_tforpag, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN v_tforpag;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_formapago;

--------------------------------------------------------------------------------

   -- Clausulas del seguro
   FUNCTION f_clausulas(psseguro IN NUMBER, pidioma IN NUMBER DEFAULT 2)
      RETURN VARCHAR2 IS
      clau           VARCHAR2(31000);
      err            NUMBER;
      maximo         NUMBER;
   BEGIN
      BEGIN
         SELECT REPLACE(tclaesp, CHR(13), '\par ')
           INTO clau
           FROM clausuesp
          WHERE ffinclau IS NULL
            AND nriesgo = (SELECT MIN(riesgos.nriesgo)
                             FROM riesgos
                            WHERE riesgos.sseguro = clausuesp.sseguro
                              AND riesgos.fanulac IS NULL)
            AND sseguro = psseguro
            AND cclaesp = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT tclaben
              INTO clau
              FROM claubenseg, clausuben
             WHERE claubenseg.sseguro = psseguro
               AND clausuben.sclaben = claubenseg.sclaben
               AND cidioma = pidioma
               AND ffinclau IS NULL
               AND nriesgo = (SELECT MIN(riesgos.nriesgo)
                                FROM riesgos
                               WHERE riesgos.sseguro = claubenseg.sseguro
                                 AND riesgos.fanulac IS NULL);
      END;

      -- BUG10134:08/06/2009:DRA:Inici
      clau := REPLACE(clau, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN clau;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_clausulas;

   ---- Prestaciones

   -- Devuelve el importe de la prestaci¿n por capital
   FUNCTION f_prestacapital(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2 IS
      importe        VARCHAR2(20);
   BEGIN
      SELECT TO_CHAR(importe, 'FM999G999G990D00') || ' EUR'
        INTO importe
        FROM planbenefpresta
       WHERE sprestaplan = pparte
         AND sperson = psperson
         AND ctipcap = 1;

      RETURN importe;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_prestacapital;

   -- Devuelve el importe de la prestaci¿n por renta
   FUNCTION f_prestarenta(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2 IS
      importe        VARCHAR2(20);
   BEGIN
      SELECT TO_CHAR(importe, 'FM999G999G990D00') || DECODE(importe, NULL, NULL, ' EUR')
        INTO importe
        FROM planbenefpresta
       WHERE sprestaplan = pparte
         AND sperson = psperson
         AND ctipcap = 2;

      RETURN importe;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_prestarenta;

   -- Devuelve la forma de pago de la renta
   FUNCTION f_prestaformarenta(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2 IS
      forma_pago     VARCHAR2(20);
   BEGIN
      SELECT tatribu
        INTO forma_pago
        FROM planbenefpresta, detvalores
       WHERE sprestaplan = pparte
         AND sperson = psperson
         AND ctipcap IN(2, 4)
         AND detvalores.cvalor = 687
         AND detvalores.cidioma = NVL(pac_isql.rgidioma,
                                      pac_contexto.f_contextovalorparametro('IAX_IDIOMA'))
         AND detvalores.catribu = planbenefpresta.ctipcap;

      -- BUG10134:08/06/2009:DRA:Inici
      forma_pago := REPLACE(forma_pago, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN forma_pago;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_prestaformarenta;

   -- Fecha de pago del capital de la prestacion
   FUNCTION f_prestafpagocapital(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2 IS
      fecha          VARCHAR2(20);
   BEGIN
      SELECT TO_CHAR(finicio, 'DD/MM/YYYY')
        INTO fecha
        FROM planbenefpresta
       WHERE sprestaplan = pparte
         AND sperson = psperson
         AND ctipcap = 1;

      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_prestafpagocapital;

   -- FEcha de pago de la renta de la prestaci¿n
   FUNCTION f_prestafpagorenta(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2 IS
      fecha          VARCHAR2(20);
   BEGIN
      SELECT TO_CHAR(finicio, 'DD/MM/YYYY')
        INTO fecha
        FROM planbenefpresta
       WHERE sprestaplan = pparte
         AND sperson = psperson
         AND ctipcap = 2;

      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_prestafpagorenta;

   FUNCTION f_docuparte(pparte IN VARCHAR2, ptipo IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2 IS
      tipo           NUMBER;
   BEGIN
      IF ptipo IS NOT NULL THEN
         tipo := ptipo;
      ELSE
         SELECT ctipren
           INTO tipo
           FROM prestaplan
          WHERE sprestaplan = pparte;
      END IF;

      IF tipo = 1 THEN   -- JUBILACION
         RETURN('Fotocopia documento INSS acreditativo de su situaci¿n de pasivo indicando la FECHA DE CESE de la actividad laboral.\par '
                || 'Declaraci¿n Jurada de no poder acceder a dicha situaci¿n para personas mayores de edad superior o igual a 65 a¿os.\par '
                || 'Fotocopia del expediente de regulaci¿n de empleo.');
      ELSIF tipo = 2 THEN
         RETURN('Fotocopia documento INSS acreditativo de su situaci¿n de pasivo por la contingencia de invalidez permanente'
                || ' indicando la FECHA DE RESOLUCI¿N.');
      ELSIF tipo = 3 THEN
         RETURN('Fotocopia del DNI del beneficiario.\par ' || 'Certificado de Defunci¿n.\par '
                || 'Fotocopia de documento que acredite relaci¿n de parentesco con el fallecido.\par '
                || 'N¿mero de cuenta para el abono');
      ELSIF tipo = 5 THEN
         RETURN('Documento que acredite una baja durante un periodo continuado m¿nimo de TRES meses.\par '
                || 'Certificado m¿dico indicando las causas del cese de incapacidad temporal.\par '
                || 'Nota: La enfermedad grave puede ser del Part¿cipe, o del c¿nyuge o de alg¿n ascendiente o descendiente o '
                || 'persona que en r¿gimen de tutela o acogimiento conviva con el Part¿cipe o de ¿l dependa.');
      ELSIF tipo = 4 THEN
         RETURN('Fotocopia de documento que acredite estar inscrito en el INEM habiendo transcurrido m¿s de 12 '
                || 'meses seguidos en esta situaci¿n y no estar percibiendo prestaciones contributivas. ');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_docuparte;

   FUNCTION f_parte_col1(pparte IN VARCHAR2)
      RETURN VARCHAR2 IS
      tipo           NUMBER;
   BEGIN
      RETURN f_parte_col1(pparte, 2);
   END f_parte_col1;

   FUNCTION f_parte_col1(pparte IN VARCHAR2, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
      tipo           NUMBER;
   BEGIN
      SELECT ctipcap
        INTO tipo
        FROM benefprestaplan
       WHERE sprestaplan = pparte;

      IF tipo = 1 THEN   ---> Solo capital
         RETURN(f_axis_literales('500110', pidioma) || '.');
      --RETURN ('CAPITAL TOTAL.');
      ELSIF tipo = 2 THEN   ---> Renta
         RETURN(f_axis_literales('500111', pidioma) || ':');
      --RETURN ('RENTA MENSUAL:');
      ELSIF tipo = 3 THEN
         RETURN(f_axis_literales('500112', pidioma) || ':\par '
                || f_axis_literales('500111', pidioma));
      --RETURN ('CAPITAL PARCIAL:\par RENTA MENSUAL:');
      ELSIF tipo = 4 THEN   -- Vitalicio
         RETURN(f_axis_literales('500113', pidioma));
      --RETURN ('Renta VITALICIA');
      END IF;
   END f_parte_col1;

   FUNCTION f_parte_col2(pparte IN VARCHAR2)
      RETURN VARCHAR2 IS
      tipo           NUMBER;
      importecap     VARCHAR2(100);
      importeren     VARCHAR2(100);
   BEGIN
      SELECT ctipcap
        INTO tipo
        FROM benefprestaplan
       WHERE sprestaplan = pparte;

      IF tipo = 1 THEN   ---> Solo capital
          -- SELECT TO_CHAR(IMPORTE,'FM999G999G990D00') || ' EUR'
         --  INTO IMPORTECAP
          -- FROM PLANBENEFPRESTA
          -- WHERE SPRESTAPLAN = PPARTE
         --  AND CTIPCAP = 1 ;
         RETURN(NULL);
      ELSIF tipo = 2 THEN   ---> Renta
         SELECT TO_CHAR(importe, 'FM999G999G990D00') || ' EUR'
           INTO importeren
           FROM planbenefpresta
          WHERE sprestaplan = pparte
            AND ctipcap = 2;

         RETURN(importeren);
      ELSIF tipo = 3 THEN
         SELECT TO_CHAR(importe, 'FM999G999G990D00') || ' EUR'
           INTO importecap
           FROM planbenefpresta
          WHERE sprestaplan = pparte
            AND ctipcap = 1;

         SELECT TO_CHAR(importe, 'FM999G999G990D00') || ' EUR'
           INTO importeren
           FROM planbenefpresta
          WHERE sprestaplan = pparte
            AND ctipcap = 2;

         RETURN(importecap || '\par ' || importeren || '\par ');
      ELSIF tipo = 4 THEN   -- Vitalicio
         RETURN NULL;
      END IF;
   END f_parte_col2;

   FUNCTION f_parte_col3(pparte IN VARCHAR2)
      RETURN VARCHAR2 IS
      tipo           NUMBER;
   BEGIN
      RETURN f_parte_col3(pparte, 2);
   END f_parte_col3;

   FUNCTION f_parte_col3(pparte IN VARCHAR2, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
      tipo           NUMBER;
   BEGIN
      SELECT ctipcap
        INTO tipo
        FROM benefprestaplan
       WHERE sprestaplan = pparte;

      IF tipo = 1 THEN   ---> Solo capital
         RETURN(f_axis_literales('500114', pidioma));   --RETURN ('F.PAGO:');
      ELSIF tipo = 2 THEN   ---> Renta
         RETURN(f_axis_literales('500115', pidioma));
      --RETURN ('F.INICIO:');
      ELSIF tipo = 3 THEN
         RETURN(f_axis_literales('500114', pidioma) || ':\par '
                || f_axis_literales('500115', pidioma));
      --RETURN ('F.PAGO:\par F.INICIO:');
      ELSIF tipo = 4 THEN   -- Vitalicio
         RETURN NULL;
      END IF;
   END f_parte_col3;

   FUNCTION f_parte_col4(pparte IN VARCHAR2)
      RETURN VARCHAR2 IS
      tipo           NUMBER;
      fcap           VARCHAR2(100);
      fren           VARCHAR2(100);
   BEGIN
      SELECT ctipcap
        INTO tipo
        FROM benefprestaplan
       WHERE sprestaplan = pparte;

      IF tipo = 1 THEN   ---> Solo capital
         SELECT TO_CHAR(finicio, 'DD/MM/YYYY')
           INTO fcap
           FROM planbenefpresta
          WHERE sprestaplan = pparte
            AND ctipcap = 1;

         RETURN(fcap);
      ELSIF tipo = 2 THEN   ---> Renta
         SELECT TO_CHAR(finicio, 'DD/MM/YYYY')
           INTO fren
           FROM planbenefpresta
          WHERE sprestaplan = pparte
            AND ctipcap = 2;

         RETURN(fren);
      ELSIF tipo = 3 THEN   --> Mixto
         SELECT TO_CHAR(finicio, 'DD/MM/YYYY')
           INTO fcap
           FROM planbenefpresta
          WHERE sprestaplan = pparte
            AND ctipcap = 1;

         SELECT TO_CHAR(finicio, 'DD/MM/YYYY')
           INTO fren
           FROM planbenefpresta
          WHERE sprestaplan = pparte
            AND ctipcap = 2;

         RETURN(fcap || '\par ' || fren || '\par ');
      ELSIF tipo = 4 THEN   -- Vitalicio
         RETURN NULL;
      END IF;
   END f_parte_col4;

   FUNCTION f_cumulos_tar(psseguro IN NUMBER, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
      respuesta      NUMBER;
      movimiento     NUMBER;
      posicion       NUMBER;
      cabecera       NUMBER;

      TYPE tdocs IS TABLE OF VARCHAR2(100)
         INDEX BY BINARY_INTEGER;

      docs           tdocs;
      texto          VARCHAR2(2000);
   BEGIN
      docs(0) := '/0/';
      docs(1) := '/1/2/';
      docs(2) := '/1/2/3/';
      docs(3) := '/1/2/3/7/';
      docs(4) := '/1/2/3/4/';
      docs(5) := '/1/2/3/4/7/';
      docs(6) := '/1/2/3/4/5/6/';
      docs(7) := '/1/2/3/4/5/6/7/';
      docs(8) := '/1/2/7/';
      docs(9) := '/1/2/4/6/7/';
      docs(10) := '/1/2/4/5/6/7/';
      docs(11) := '/1/2/3/4/6/7/8/';
      docs(12) := '/1/2/3/4/5/6/7/8/';
      docs(13) := '/1/2/3/4/6/8/';

      SELECT MAX(nmovimi)
        INTO movimiento
        FROM pregunseg
       WHERE sseguro = psseguro
         AND cpregun = 2;

      SELECT crespue
        INTO respuesta
        FROM pregunseg
       WHERE sseguro = psseguro
         AND cpregun = 2
         AND nmovimi = movimiento;

      cabecera := 0;

      IF respuesta >= 0 THEN
         FOR reg IN (SELECT cprueba, tprueba
                       FROM prueba
                      WHERE cidioma = pidioma) LOOP
            posicion := INSTR(docs(respuesta), '/' || reg.cprueba || '/', 1);

            IF NVL(posicion, 0) > 0 THEN
               IF cabecera = 0 THEN
                  IF pidioma = 2 THEN
                     texto :=
                        '\par La tramitaci¿n de esta solicitud queda condicionada a la realizaci¿n de las pertinentes pruebas m¿dicas. Ser¿ imprescindible presentar documento acreditativo con foto: \par \par ';
                  ELSIF pidioma = 1 THEN
                     texto :=
                        '\par La tramitaci¿ d''aquesta sol¿licitud queda condicionada a la realitzaci¿ de les pertinents proves m¿diques i ser¿ imprescindible presentar document acreditatiu amb foto:  \par \par ';
                  END IF;

                  cabecera := 1;
               END IF;

               texto := texto || '\tab - ' || reg.tprueba || '\par ';
            END IF;
         END LOOP;
      --     IF cabecera = 1 THEN
      --        IF pidioma = 2 THEN
      --           TEXTO := TEXTO || '\tab - Documento acreditativo con foto\par ';
      --       ELSIF pidioma = 1 THEN
      --           TEXTO := TEXTO || '\tab - Document acreditatiu amb foto\par  ';
      --       END IF;
      --     END IF;
      END IF;

      RETURN texto;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_cumulos_tar;

   FUNCTION f_beneftar(psseguro IN NUMBER, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
      texto          VARCHAR2(1000);
      v_tipo         NUMBER;
      v_clausula     NUMBER;
   BEGIN
      BEGIN
         SELECT tclatex
           INTO texto
           FROM clausuesp, clausugen
          WHERE clausuesp.sclagen = clausugen.sclagen
            AND clausuesp.sclagen = 1
            AND clausuesp.cclaesp = 4
            AND cidioma = pidioma
            AND clausuesp.sseguro = psseguro
            AND clausuesp.ffinclau IS NULL;

         v_tipo := 2;   -- beneficiario irrevocable
      EXCEPTION
         WHEN OTHERS THEN
            v_tipo := 1;   -- s¿lo cla¿sula beneficiario
      END;

      IF v_tipo = 2 THEN
             -- si es benef. irrevocalbe y si es una p¿liza de migraci¿n no debe salir la clausula :
         -- 'Y  en caso de exceso de capital...', a menos que tenga un suplemento
         BEGIN
            SELECT 0
              INTO v_clausula
              FROM seguros
             WHERE nsolici < 23000000   -- es de migraci¿n
               AND sseguro = psseguro
               AND EXISTS(SELECT sclaben
                            FROM claubenseg
                           WHERE sseguro = psseguro
                             AND ffinclau IS NULL)
               AND sseguro NOT IN(SELECT sseguro
                                    FROM movseguro mov
                                   WHERE cmovseg = 1
                                     AND fmovimi > TO_DATE('09/06/2005 0', 'dd/mm/yyyy sssss'));

            v_tipo := 2;   --s¿lo benef irrevocable
         EXCEPTION
            WHEN OTHERS THEN
               v_tipo := 3;   -- benef irrevocable con clausula beneficiario
         END;
      END IF;

      IF v_tipo = 1 THEN   -- s¿lo cla¿sula beneficiario
         IF pidioma = 1 THEN
            RETURN('{\b BENEFICIARIS:}\par ' || pac_isqlfor.f_clausulas(psseguro, pidioma));
         ELSE
            RETURN('{\b BENEFICIARIOS:}\par ' || pac_isqlfor.f_clausulas(psseguro, pidioma));
         END IF;
      ELSIF v_tipo = 2 THEN   -- s¿lo benef irrevocable
         IF pidioma = 1 THEN
            RETURN('{\b BENEFICIARIS:}\par ' || texto);
         ELSE
            RETURN('{\b BENEFICIARIOS:}\par ' || texto);
         END IF;
      ELSE   -- benef irrevocable con clausula beneficiario
         IF pidioma = 1 THEN
            RETURN('{\b BENEFICIARIS:}\par ' || texto
                   || '\par \par En cas d''exc¿s de capital: \par '
                   || pac_isqlfor.f_clausulas(psseguro, pidioma));
         ELSE
            RETURN('{\b BENEFICIARIOS:}\par ' || texto
                   || '\par \par En caso de exceso de capital: \par '
                   || pac_isqlfor.f_clausulas(psseguro, pidioma));
         END IF;
      END IF;
   END f_beneftar;

   FUNCTION f_tarprimamuerte(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2 IS
      texto          VARCHAR2(1000) := '';
      prima          NUMBER;
   BEGIN
      FOR reg IN (SELECT   solseguros.ssolicit,
                           (SELECT f_prima_forpag('SOL', 2, 3, ssolicit, nriesgo,
                                                  cgarant, iprianu)
                              FROM solgaranseg
                             WHERE cgarant = 1
                               AND ssolicit = solseguros.ssolicit) prima
                      FROM solseguros
                     WHERE ssolicit BETWEEN pnsolini AND pnsolfin
                  --(1660, 1661, 1662, 1663)
                  ORDER BY cramo, cmodali, ctipseg, ccolect,
                           (SELECT COUNT(1)
                              FROM solgaranseg
                             WHERE ssolicit = solseguros.ssolicit
                               AND icapital IS NOT NULL)) LOOP
         texto := texto || TO_CHAR(reg.prima, '999G999G990D00') || '\par ';
      END LOOP;

      RETURN texto;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(SQLERRM);
         --DBMS_OUTPUT.put_line ('ERROR' || SQLERRM);
         RETURN NULL;
   END f_tarprimamuerte;

   FUNCTION f_tarprimainv(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2 IS
      texto          VARCHAR2(1000) := '';
      prima          NUMBER;
   BEGIN
      FOR reg IN (SELECT   solseguros.ssolicit,
                           (SELECT f_prima_forpag('SOL', 2, 3, ssolicit, nriesgo,
                                                  cgarant, iprianu)
                              FROM solgaranseg
                             WHERE cgarant = 2
                               AND ssolicit = solseguros.ssolicit) prima
                      FROM solseguros
                     WHERE ssolicit BETWEEN pnsolini AND pnsolfin
                  --(1660, 1661, 1662, 1663)
                  ORDER BY cramo, cmodali, ctipseg, ccolect,
                           (SELECT COUNT(1)
                              FROM solgaranseg
                             WHERE ssolicit = solseguros.ssolicit
                               AND icapital IS NOT NULL)) LOOP
         texto := texto || TO_CHAR(reg.prima, '999G999G990D00') || '\par ';
      END LOOP;

      RETURN texto;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line ('ERROR' || SQLERRM);
         RETURN NULL;
   END f_tarprimainv;

   FUNCTION f_tarprimailt(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2 IS
      texto          VARCHAR2(1000) := '';
      prima          NUMBER;
   BEGIN
      FOR reg IN (SELECT   solseguros.ssolicit,
                           (SELECT f_prima_forpag('SOL', 2, 3, ssolicit, nriesgo,
                                                  cgarant, iprianu)
                              FROM solgaranseg
                             WHERE cgarant = 100
                               AND ssolicit = solseguros.ssolicit) prima
                      FROM solseguros
                     WHERE ssolicit BETWEEN pnsolini AND pnsolfin
                  --(1660, 1661, 1662, 1663)
                  ORDER BY cramo, cmodali, ctipseg, ccolect,
                           (SELECT COUNT(1)
                              FROM solgaranseg
                             WHERE ssolicit = solseguros.ssolicit
                               AND icapital IS NOT NULL)) LOOP
         texto := texto || TO_CHAR(reg.prima, '999G999G990D00') || '\par ';
      END LOOP;

      RETURN texto;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line ('ERROR' || SQLERRM);
         RETURN NULL;
   END f_tarprimailt;

   FUNCTION f_tarprimaotros(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2 IS
      texto          VARCHAR2(1000) := '';
      prima          NUMBER;
   BEGIN
      FOR reg IN (SELECT   solseguros.ssolicit,
                           (SELECT f_prima_forpag('SOL', 2, 3, ssolicit, nriesgo,
                                                  cgarant, iprianu)
                              FROM solgaranseg
                             WHERE cgarant = 101
                               AND ssolicit = solseguros.ssolicit) prima
                      FROM solseguros
                     WHERE ssolicit BETWEEN pnsolini AND pnsolfin
                  --(1660, 1661, 1662, 1663)
                  ORDER BY cramo, cmodali, ctipseg, ccolect,
                           (SELECT COUNT(1)
                              FROM solgaranseg
                             WHERE ssolicit = solseguros.ssolicit
                               AND icapital IS NOT NULL)) LOOP
         texto := texto || TO_CHAR(reg.prima, '999G999G990D00') || '\par ';
      END LOOP;

      RETURN texto;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line ('ERROR' || SQLERRM);
         RETURN NULL;
   END f_tarprimaotros;

   FUNCTION f_tarprimamensual(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2 IS
      texto          VARCHAR2(1000) := '';
      prima          NUMBER;
   BEGIN
      FOR reg IN (SELECT   solseguros.ssolicit,
                           f_prima_forpag('SOL', 2, 1, ssolicit, 1, NULL,
                                          (SELECT SUM(NVL(iprianu, 0))
                                             FROM solgaranseg
                                            WHERE ssolicit = solseguros.ssolicit)) prima
                      FROM solseguros
                     WHERE ssolicit BETWEEN pnsolini AND pnsolfin
                  --(1660, 1661, 1662, 1663)
                  ORDER BY cramo, cmodali, ctipseg, ccolect,
                           (SELECT COUNT(1)
                              FROM solgaranseg
                             WHERE ssolicit = solseguros.ssolicit
                               AND icapital IS NOT NULL)) LOOP
         texto := texto || TO_CHAR(reg.prima, '999G999G990D00') || '\par ';
      END LOOP;

      RETURN texto;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line ('ERROR' || SQLERRM);
         RETURN NULL;
   END f_tarprimamensual;

   FUNCTION f_litaltamodif(ptipo IN VARCHAR2, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      IF ptipo = 'ALTA'
         AND pidioma = 1 THEN
         RETURN('*El Part¿cip manifesta la seva voluntat d''adhesi¿ al Pla descrit amb subjecci¿ al seu Reglament.');
      ELSIF ptipo = 'ALTA'
            AND pidioma = 2 THEN
         RETURN('*El Part¿cipe manifieta su voluntad de adhesi¿n al Plan descrito con subjecci¿n a su Reglamento');
      ELSIF ptipo IN('MODIFICACI¿N', 'MODIFICACION')
            AND pidioma = 1 THEN
         RETURN('* El present certificat anula y substitueix als anterios emessos. ');
      ELSIF ptipo IN('MODIFICACI¿N', 'MODIFICACION')
            AND pidioma = 2 THEN
         RETURN('* El presente certificado anula y sustituye a los anteriormente emitidos. ');
      ELSIF ptipo IN('COPIA') THEN
         RETURN(' ');
      END IF;

      RETURN(' ');
   END f_litaltamodif;

   FUNCTION f_litcabaltamodif(ptipo IN VARCHAR2, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      IF ptipo = 'ALTA' THEN
         RETURN('ALTA');
      ELSIF ptipo IN('MODIFICACI¿N', 'MODIFICACION')
            AND pidioma = 1 THEN
         RETURN('MODIFICACI¿');
      ELSIF ptipo IN('MODIFICACI¿N', 'MODIFICACION')
            AND pidioma = 2 THEN
         RETURN('MODIFICACI¿N');
      ELSIF ptipo = 'COPIA' THEN
         RETURN('COPIA');
      END IF;

      RETURN NULL;
   END f_litcabaltamodif;

   FUNCTION fechahoy_idioma(pfecha IN DATE, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
      mes            VARCHAR2(100);
   BEGIN
      IF pidioma = 1 THEN
         IF TO_CHAR(pfecha, 'MM') = '01' THEN
            mes := 'de Gener';
         ELSIF TO_CHAR(pfecha, 'MM') = '02' THEN
            mes := 'de Febrer';
         ELSIF TO_CHAR(pfecha, 'MM') = '03' THEN
            mes := 'de Mar¿';
         ELSIF TO_CHAR(pfecha, 'MM') = '04' THEN
            mes := 'd¿Abril';
         ELSIF TO_CHAR(pfecha, 'MM') = '05' THEN
            mes := 'de Maig';
         ELSIF TO_CHAR(pfecha, 'MM') = '06' THEN
            mes := 'de Juny';
         ELSIF TO_CHAR(pfecha, 'MM') = '07' THEN
            mes := 'de Juliol';
         ELSIF TO_CHAR(pfecha, 'MM') = '08' THEN
            mes := 'd¿Agost';
         ELSIF TO_CHAR(pfecha, 'MM') = '09' THEN
            mes := 'de Setembre';
         ELSIF TO_CHAR(pfecha, 'MM') = '10' THEN
            mes := 'd¿Octubre';
         ELSIF TO_CHAR(pfecha, 'MM') = '11' THEN
            mes := 'de Novembre';
         ELSIF TO_CHAR(pfecha, 'MM') = '12' THEN
            mes := 'de Desembre';
         END IF;
      ELSIF pidioma = 2 THEN
         IF TO_CHAR(pfecha, 'MM') = '01' THEN
            mes := 'de Enero';
         ELSIF TO_CHAR(pfecha, 'MM') = '02' THEN
            mes := 'de Febrero';
         ELSIF TO_CHAR(pfecha, 'MM') = '03' THEN
            mes := 'de Marzo';
         ELSIF TO_CHAR(pfecha, 'MM') = '04' THEN
            mes := 'de Abril';
         ELSIF TO_CHAR(pfecha, 'MM') = '05' THEN
            mes := 'de Mayo';
         ELSIF TO_CHAR(pfecha, 'MM') = '06' THEN
            mes := 'de Junio';
         ELSIF TO_CHAR(pfecha, 'MM') = '07' THEN
            mes := 'de Julio';
         ELSIF TO_CHAR(pfecha, 'MM') = '08' THEN
            mes := 'de Agosto';
         ELSIF TO_CHAR(pfecha, 'MM') = '09' THEN
            mes := 'de Septiembre';
         ELSIF TO_CHAR(pfecha, 'MM') = '10' THEN
            mes := 'de Octubre';
         ELSIF TO_CHAR(pfecha, 'MM') = '11' THEN
            mes := 'de Noviembre';
         ELSIF TO_CHAR(pfecha, 'MM') = '12' THEN
            mes := 'de Diciembre';
         END IF;
      END IF;

      RETURN TO_CHAR(pfecha, 'FMDD') || ' ' || mes || ' de ' || TO_CHAR(pfecha, 'YYYY');
   END fechahoy_idioma;

   FUNCTION f_profesion(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      -- ERP 17/05/2006
      -- Devuelve la profesion del tomador de un seguro
      v_profesion    VARCHAR2(250);
   BEGIN
      -- ini Bug 0012803 - 19/02/2010 - JMF
      -- SELECT c.tprofes
      --   INTO v_profesion
      --   FROM tomadores a, personas b, profesiones c
      --  WHERE a.sseguro = psseguro
      --    AND a.sperson = b.sperson
      --    AND b.cidioma = c.cidioma
      --    AND b.cprofes = c.cprofes;
      SELECT d.tprofes
        INTO v_profesion
        FROM seguros a, tomadores b, per_detper c, profesiones d
       WHERE a.sseguro = psseguro
         AND b.sseguro = a.sseguro
         AND c.sperson = b.sperson
         AND c.cagente = ff_agente_cpervisio(a.cagente, f_sysdate, a.cempres)
         AND d.cprofes = c.cprofes
         AND d.cidioma = c.cidioma;

      -- fin Bug 0012803 - 19/02/2010 - JMF
      v_profesion := REPLACE(v_profesion, CHR(39), CHR(39) || CHR(39));
      RETURN v_profesion;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLERRM;
   END f_profesion;

   FUNCTION f_tab_simpp_ejercicio(psesion IN NUMBER, parte IN NUMBER)
      RETURN VARCHAR2 IS
      retval         VARCHAR2(500) := '';
   BEGIN
      IF parte = 1 THEN
         FOR reg IN (SELECT   TO_CHAR(ejercicio) "VALOR"
                         FROM detsimulapp
                        WHERE sesion = psesion
                          AND ejercicio <= (SELECT CEIL(COUNT(1) / 2)
                                              FROM detsimulapp
                                             WHERE sesion = psesion)
                     ORDER BY ejercicio ASC) LOOP
            retval := retval || reg.valor || '\par ';
         END LOOP;
      ELSE
         FOR reg IN (SELECT   TO_CHAR(ejercicio) "VALOR"
                         FROM detsimulapp
                        WHERE sesion = psesion
                          AND ejercicio > (SELECT CEIL(COUNT(1) / 2)
                                             FROM detsimulapp
                                            WHERE sesion = psesion)
                     ORDER BY ejercicio ASC) LOOP
            retval := retval || reg.valor || '\par ';
         END LOOP;
      END IF;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tab_simpp_ejercicio;

   FUNCTION f_tab_simpp_apormes(psesion IN NUMBER, parte IN NUMBER)
      RETURN VARCHAR2 IS
      retval         VARCHAR2(500) := '';
   BEGIN
      IF parte = 1 THEN
         FOR reg IN (SELECT   TO_CHAR(apormes, 'FM999G999G990D00') "VALOR"
                         FROM detsimulapp
                        WHERE sesion = psesion
                          AND ejercicio <= (SELECT CEIL(COUNT(1) / 2)
                                              FROM detsimulapp
                                             WHERE sesion = psesion)
                     ORDER BY ejercicio ASC) LOOP
            retval := retval || reg.valor || '\par ';
         END LOOP;
      ELSE
         FOR reg IN (SELECT   TO_CHAR(apormes, 'FM999G999G990D00') "VALOR"
                         FROM detsimulapp
                        WHERE sesion = psesion
                          AND ejercicio > (SELECT CEIL(COUNT(1) / 2)
                                             FROM detsimulapp
                                            WHERE sesion = psesion)
                     ORDER BY ejercicio ASC) LOOP
            retval := retval || reg.valor || '\par ';
         END LOOP;
      END IF;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tab_simpp_apormes;

   FUNCTION f_tab_simpp_capital(psesion IN NUMBER, parte IN NUMBER)
      RETURN VARCHAR2 IS
      retval         VARCHAR2(1000) := '';
   BEGIN
      IF parte = 1 THEN
         FOR reg IN (SELECT   TO_CHAR(capital, 'FM999G999G990D00') "VALOR"
                         FROM detsimulapp
                        WHERE sesion = psesion
                          AND ejercicio <= (SELECT CEIL(COUNT(1) / 2)
                                              FROM detsimulapp
                                             WHERE sesion = psesion)
                     ORDER BY ejercicio ASC) LOOP
            retval := retval || reg.valor || '\par ';
         END LOOP;
      ELSE
         FOR reg IN (SELECT   TO_CHAR(capital, 'FM999G999G990D00') "VALOR"
                         FROM detsimulapp
                        WHERE sesion = psesion
                          AND ejercicio > (SELECT CEIL(COUNT(1) / 2)
                                             FROM detsimulapp
                                            WHERE sesion = psesion)
                     ORDER BY ejercicio ASC) LOOP
            retval := retval || reg.valor || '\par ';
         END LOOP;
      END IF;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tab_simpp_capital;

--------------------------------------------------------------------------------
   FUNCTION f_titgarantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pseparador IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(1000) := '';
      v_retval       NUMBER;
      v_valpar       NUMBER;
   BEGIN
      -- Bug 9685 - APD - 01/07/2009 - en lugar de coger la actividad de la tabla seguros,
      -- llamar a la funci¿n pac_seguros.ff_get_actividad
      FOR reg IN (SELECT   REPLACE(g.tgarant, CHR(39), CHR(39) || CHR(39)) "TGARANT",
                           se.cramo, se.cmodali, se.ctipseg, se.ccolect,
                           pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo) cactivi,
                           g.cgarant
                      FROM garangen g, garanpro p, garanseg s, seguros se
                     WHERE g.cgarant = s.cgarant
                       AND p.cgarant = s.cgarant
                       AND g.cidioma = pcidioma
                       AND p.sproduc = se.sproduc
                       AND p.cactivi = pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo)
                       AND s.sseguro = se.sseguro
                       AND s.nriesgo = NVL(pnriesgo, 1)
                       AND s.ffinefe IS NULL
                       AND se.sseguro = psseguro
                  ORDER BY DECODE(g.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC) LOOP
         v_retval := f_pargaranpro(reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                   reg.cactivi, reg.cgarant, 'VISIBLEDOCUM', v_valpar);

         -- Bug 9685 - APD - 01/07/2009 - fin
         IF NVL(v_valpar, 1) = 1 THEN
            IF pseparador = 0 THEN
               v_cadena := v_cadena || reg.tgarant || '\par ';
            ELSE
               IF v_cadena IS NULL THEN
                  v_cadena := reg.tgarant;
               ELSE
                  v_cadena := v_cadena || ', ' || reg.tgarant;
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_titgarantias;

--------------------------------------------------------------------------------
   FUNCTION f_capgarantias(psseguro IN NUMBER, pnriesgo IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(1000) := '';
      v_retval       NUMBER;
      v_valpar       NUMBER;
      v_tcapital     VARCHAR2(50);
   BEGIN
      -- Bug 9685 - APD - 01/07/2009 - en lugar de coger la actividad de la tabla seguros,
      -- llamar a la funci¿n pac_seguros.ff_get_actividad
      FOR reg IN (SELECT   p.cgarant, se.cramo, se.cmodali, se.ctipseg, se.ccolect,
                           pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo) cactivi,
                           icapital
                      FROM garanpro p, garanseg s, seguros se
                     WHERE p.cgarant = s.cgarant
                       AND p.sproduc = se.sproduc
                       AND p.cactivi = pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo)
                       AND s.sseguro = se.sseguro
                       AND s.nriesgo = NVL(pnriesgo, 1)
                       AND s.ffinefe IS NULL
                       AND se.sseguro = psseguro
                  ORDER BY DECODE(s.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC) LOOP
         v_retval := f_pargaranpro(reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                   reg.cactivi, reg.cgarant, 'VISIBLEDOCUM', v_valpar);

         -- Bug 9685 - APD - 01/07/2009 - fin
         IF NVL(v_valpar, 1) = 1 THEN
            BEGIN
               SELECT DECODE(icapital,
                             NULL, f_axis_literales(104619, 1),
                             TO_CHAR(icapital, 'FM999G999G999G990D00') || ' EUR')
                 INTO v_tcapital
                 FROM garanseg g
                WHERE g.sseguro = psseguro
                  AND g.nriesgo = NVL(pnriesgo, 1)
                  AND g.cgarant = reg.cgarant
                  AND g.ffinefe IS NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_tcapital := f_axis_literales(104619, 1);
            END;

            --            v_cadena := v_cadena || reg.capital || '\par ';
            v_cadena := v_cadena || v_tcapital || '\par ';
         END IF;
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_capgarantias;

--------------------------------------------------------------------------------
   FUNCTION f_prox_recibo(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      num_err        NUMBER;
      resultat       DATE;
      vsproduc       NUMBER;
      vcforpag       NUMBER;
      vnrenova       NUMBER;
      vfefecto       DATE;
      cambio_fp      NUMBER;
      dummy          DATE;
      v_nmovimi_nou  NUMBER;
      v_fsuplem      DATE;
      v_cforpag_nou  NUMBER;
      v_cforpag_ant  NUMBER;
   BEGIN
      SELECT COUNT(*), MAX(d.nmovimi), MAX(fefecto)
        INTO cambio_fp, v_nmovimi_nou, v_fsuplem
        FROM detmovseguro d, movseguro m
       WHERE d.sseguro = psseguro
         AND d.sseguro = m.sseguro
         AND d.nmovimi = m.nmovimi
         AND d.cmotmov = 269   -- cambio de forma de pago
         AND d.nmovimi = (SELECT MAX(nmovimi)
                            FROM movseguro
                           WHERE sseguro = psseguro);

      IF cambio_fp > 0 THEN
         -- ha habido un suplemento de cambio de forma de pago
         v_cforpag_nou := f_cforpag(psseguro, v_nmovimi_nou);
         v_cforpag_ant := f_cforpag(psseguro, v_nmovimi_nou - 1);
         num_err := pac_canviforpag.f_fcarpro_final(psseguro, v_fsuplem, v_cforpag_nou,
                                                    v_cforpag_ant, resultat, dummy);

         IF v_cforpag_nou = 0 THEN
            resultat := NULL;
         END IF;
      ELSE
         SELECT fcarpro, sproduc, cforpag, nrenova, fefecto
           INTO resultat, vsproduc, vcforpag, vnrenova, vfefecto
           FROM seguros
          WHERE sseguro = psseguro;

         IF resultat IS NULL
            AND vcforpag != 0 THEN
            resultat := pac_ppa_planes.f_fcarpro(vsproduc, vcforpag, vnrenova, vfefecto);
         ELSIF vcforpag = 0 THEN
            resultat := NULL;
         END IF;
      END IF;

      IF resultat IS NOT NULL THEN
         RETURN TO_CHAR(resultat, 'DD/MM/YYYY');
      ELSE
         RETURN ' -- ';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END f_prox_recibo;

   FUNCTION f_max_nmovimi(p_sseguro IN NUMBER, p_cduplica IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      v_nmovimi      NUMBER;
   BEGIN
      IF p_cduplica = 0 THEN
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movseguro
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM garanseg
          WHERE sseguro = p_sseguro;
      END IF;

      RETURN v_nmovimi;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_max_nmovimi;

   FUNCTION f_prima_mensual_inicial(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_prima_mensual_inicial NUMBER(15, 2);
      -- Bug 14422 - RSC - 07/06/2010 - CRE800 - P¿lizas con copago y suplementos
      v_sproduc      seguros.sproduc%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_ctiprec      recibos.ctiprec%TYPE;
      v_conta        NUMBER;
   -- Fin Bug 14422
   BEGIN
      -- Bug 14422 - RSC - 07/06/2010 - CRE800 - P¿lizas con copago y suplementos
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = p_sseguro;

      SELECT COUNT(*)
        INTO v_conta
        FROM aportaseg
       WHERE sseguro = p_sseguro;

      IF v_conta > 0 THEN
         SELECT   SUM(v.itotalr), s.cempres, r.ctiprec
             INTO v_prima_mensual_inicial, v_cempres, v_ctiprec
             FROM seguros s, recibos r, vdetrecibos v
            WHERE s.sseguro = p_sseguro
              AND s.sseguro = r.sseguro
              --AND r.ctiprec = 0
              AND(r.ctiprec = 0
                  AND f_max_nmovimi(s.sseguro) = 1
                  OR f_max_nmovimi(s.sseguro) > 1
                     AND r.nmovimi = f_max_nmovimi(s.sseguro))
              AND r.nrecibo = v.nrecibo
         --AND r.nmovimi = f_max_nmovimi(s.sseguro)
         GROUP BY s.cempres, r.ctiprec;
      ELSE
         -- FIn Bug 14422
         SELECT v.itotalr
           INTO v_prima_mensual_inicial
           FROM seguros s, recibos r, vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            --AND r.ctiprec = 0
            AND r.nrecibo = v.nrecibo
            AND(r.ctiprec = 0
                AND f_max_nmovimi(s.sseguro) = 1
                OR f_max_nmovimi(s.sseguro) > 1
                   AND r.nmovimi = f_max_nmovimi(s.sseguro))
            AND r.nrecibo = v.nrecibo;
      --AND r.nmovimi = f_max_nmovimi(s.sseguro);
      END IF;

      RETURN(v_prima_mensual_inicial);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_prima_mensual_inicial;

   FUNCTION f_prima_anual(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_prima_anual  NUMBER(15, 2);
   BEGIN
      SELECT (v.iprinet) * DECODE(s.cforpag, 0, 1, s.cforpag)
        INTO v_prima_anual
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.ctiprec = 0
         AND r.nrecibo = v.nrecibo
         AND r.nmovimi = f_max_nmovimi(s.sseguro);

      RETURN(v_prima_anual);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_prima_anual;

   FUNCTION f_prima_total(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_prima_total  NUMBER(15, 2);
   BEGIN
      SELECT (v.itotalr) * DECODE(s.cforpag, 0, 1, s.cforpag)
        INTO v_prima_total
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.ctiprec = 0
         AND r.nrecibo = v.nrecibo
         AND r.nmovimi = f_max_nmovimi(s.sseguro);

      RETURN(v_prima_total);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_prima_total;

   FUNCTION f_recarreg(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_recarreg     NUMBER(15, 2);
   BEGIN
      SELECT (v.irecfra) * DECODE(s.cforpag, 0, 1, s.cforpag)
        INTO v_recarreg
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.ctiprec = 0
         AND r.nrecibo = v.nrecibo
         AND r.nmovimi = f_max_nmovimi(s.sseguro);

      RETURN(v_recarreg);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_recarreg;

   FUNCTION f_tributs(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_tributs      NUMBER(15, 2);
   BEGIN
      SELECT (v.iips + v.idgs + v.iarbitr + v.ifng) * DECODE(s.cforpag, 0, 1, s.cforpag)
        INTO v_tributs
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.ctiprec = 0
         AND r.nrecibo = v.nrecibo
         AND r.nmovimi = f_max_nmovimi(s.sseguro);

      RETURN(v_tributs);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tributs;

--------------------------------------------------------------------------------
   FUNCTION f_dades_persona(
      p_sperson IN NUMBER,
      p_tipo IN NUMBER,
-- 1 DNI, 2 Data Naixement , 3 Sexe , 4 nom, 5 cognoms , 6 pais, 7 nacionalitat, 8 tipus document
      p_idioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL',
       p_cagente IN NUMBER DEFAULT ff_agenteprod)
      RETURN VARCHAR2 IS
      v_dades        VARCHAR2(200);
      v_dni          VARCHAR2(200);
      v_fnac         VARCHAR2(200);
      v_tsexe        VARCHAR2(200);
      v_nom          VARCHAR2(200);
      v_cognoms      VARCHAR2(200);
      v_pais         VARCHAR2(200);
      v_nacio        VARCHAR2(200);
      v_tipdoc       VARCHAR2(200);
   BEGIN
      IF p_sperson IS NULL THEN
         RETURN NULL;
      ELSIF p_tipo IN(1, 2, 3, 8) THEN
         BEGIN
            IF NVL(p_mode, 'POL') = 'EST' THEN
               SELECT p.nnumide, TO_CHAR(p.fnacimi, 'dd/mm/yyyy'),
                      ff_desvalorfijo(11, NVL(p_idioma, 1), p.csexper),
                      ff_desvalorfijo(672, NVL(p_idioma, 1), p.ctipide)
                 INTO v_dni, v_fnac,
                      v_tsexe,
                      v_tipdoc
                 FROM estper_personas p
                WHERE p.sperson = p_sperson;
            ELSE
               SELECT p.nnumide, TO_CHAR(p.fnacimi, 'dd/mm/yyyy'),
                      ff_desvalorfijo(11, NVL(p_idioma, 1), p.csexper),
                      ff_desvalorfijo(672, NVL(p_idioma, 1), p.ctipide)
                 INTO v_dni, v_fnac,
                      v_tsexe,
                      v_tipdoc
                 FROM per_personas p
                WHERE p.sperson = p_sperson;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      ELSIF p_tipo IN(4, 5, 6) THEN
         BEGIN
            IF NVL(p_mode, 'POL') = 'EST' THEN
               SELECT REPLACE(p.tnombre, CHR(39), CHR(39) || CHR(39)),
                      REPLACE(DECODE(p.tapelli1, NULL, NULL, p.tapelli1) || ' '
                              || DECODE(p.tapelli2, NULL, NULL, p.tapelli2),
                              CHR(39), CHR(39) || CHR(39)),
                      REPLACE(pa.tpais, CHR(39), CHR(39) || CHR(39))
                 INTO v_nom,
                      v_cognoms,
                      v_pais
                 FROM estpersonas p, despaises pa
                WHERE p.sperson = p_sperson
                  AND p.cpais = pa.cpais(+)
                  AND pa.cidioma(+) = NVL(p_idioma, 1);
            ELSE
               SELECT REPLACE(p.tnombre, CHR(39), CHR(39) || CHR(39)),
                      REPLACE(DECODE(p.tapelli1, NULL, NULL, p.tapelli1) || ' '
                              || DECODE(p.tapelli2, NULL, NULL, p.tapelli2),
                              CHR(39), CHR(39) || CHR(39)),
                      REPLACE(pa.tpais, CHR(39), CHR(39) || CHR(39))
                 INTO v_nom,
                      v_cognoms,
                      v_pais
                 FROM per_detper p, despaises pa
                WHERE p.sperson = p_sperson
                  AND p.cpais = pa.cpais(+)
                  AND pa.cidioma(+) = NVL(p_idioma, 1)
                  AND p.cagente = nvl(ff_agente_cpervisio(p_cagente),ff_agenteprod);
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      ELSIF p_tipo = 7 THEN   -- Nacionalitat
         BEGIN
            IF NVL(p_mode, 'POL') = 'EST' THEN
               SELECT REPLACE(tpais, CHR(39), CHR(39) || CHR(39))
                 INTO v_nacio
                 FROM estnacionalidades pn, despaises p
                WHERE pn.sperson = p_sperson
                  AND p.cpais = pn.cpais
                  AND(pn.cdefecto = 1
                      OR(pn.cdefecto = 0
                         AND pn.sperson NOT IN(SELECT pn2.sperson
                                                 FROM nacionalidades pn2
                                                WHERE pn2.cdefecto = 1)))
                  AND p.cidioma = NVL(p_idioma, 1)
                  AND ROWNUM = 1;
--(JAS)11.03.2008 Selecciono la nacionalitat per defecte, i si no t¿ nacionalitat per defecte selecciono la primera que tingui.
            ELSE
               SELECT REPLACE(tpais, CHR(39), CHR(39) || CHR(39))
                 INTO v_nacio
                 FROM nacionalidades pn, despaises p
                WHERE pn.sperson = p_sperson
                  AND p.cpais = pn.cpais
                  AND(pn.cdefecto = 1
                      OR(pn.cdefecto = 0
                         AND pn.sperson NOT IN(SELECT pn2.sperson
                                                 FROM nacionalidades pn2
                                                WHERE pn2.cdefecto = 1)))
                  AND p.cidioma = NVL(p_idioma, 1)
                  AND ROWNUM = 1;
--(JAS)11.03.2008 Selecciono la nacionalitat per defecte, i si no t¿ nacionalitat per defecte selecciono la primera que tingui.
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_nacio := NULL;   --No tenim nacionalitat
         END;
      END IF;

      SELECT DECODE(p_tipo,
                    1, v_dni,
                    2, v_fnac,
                    3, v_tsexe,
                    4, v_nom,
                    5, v_cognoms,
                    6, v_pais,
                    7, v_nacio,
                    8, v_tipdoc,
                    NULL)
        INTO v_dades
        FROM DUAL;

      RETURN v_dades;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_dades_persona;

--------------------------------------------------------------------------------
   FUNCTION f_direccion(
      p_sperson IN NUMBER,
      p_cdomici IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      vtdomici       per_direcciones.tdomici%TYPE;
      vtpoblac       poblaciones.tpoblac%TYPE;
      vcpostal       per_direcciones.cpostal%TYPE;
      v_direccion    VARCHAR2(150);
   BEGIN
      IF NVL(p_mode, 'POL') = 'EST' THEN
         SELECT tdomici, tpoblac, cpostal
           INTO vtdomici, vtpoblac, vcpostal
           FROM estper_direcciones d, poblaciones p
          WHERE d.sperson = p_sperson
            AND d.cdomici = p_cdomici
            AND d.cprovin = p.cprovin
            AND d.cpoblac = p.cpoblac;
      ELSE
         SELECT tdomici, tpoblac, cpostal
           INTO vtdomici, vtpoblac, vcpostal
           FROM per_direcciones d, poblaciones p
          WHERE d.sperson = p_sperson
            AND d.cdomici = p_cdomici
            AND d.cprovin = p.cprovin
            AND d.cpoblac = p.cpoblac;
      END IF;

      v_direccion := vtdomici;

      IF vcpostal IS NOT NULL
         AND v_direccion IS NOT NULL THEN
         v_direccion := v_direccion || ' - ' || vcpostal;
      ELSIF vcpostal IS NOT NULL
            AND v_direccion IS NULL THEN
         v_direccion := vcpostal;
      END IF;

      IF vtpoblac IS NOT NULL
         AND v_direccion IS NOT NULL THEN
         v_direccion := v_direccion || ' - ' || vtpoblac;
      ELSIF vtpoblac IS NOT NULL
            AND v_direccion IS NULL THEN
         v_direccion := vtpoblac;
      END IF;

      v_direccion := REPLACE(v_direccion, CHR(39), CHR(39) || CHR(39));
      RETURN v_direccion;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_direccion;

--------------------------------------------------------------------------------
   FUNCTION f_import_garantia(p_garant IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER IS
      v_import       garanseg.iprianu%TYPE;
   BEGIN
      SELECT iprianu
        INTO v_import
        FROM (SELECT iprianu
                FROM garanseg
               WHERE cgarant = p_garant
                 AND sseguro = p_sseguro
                 AND ffinefe IS NULL
              UNION
              SELECT iprianu
                FROM estgaranseg
               WHERE cgarant = p_garant
                 AND sseguro = p_sseguro
                 AND ffinefe IS NULL);

      RETURN(v_import);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

--------------------------------------------------------------------------------
   FUNCTION f_import_garantia_aho(p_garant IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER IS
      v_import       garanseg.icapital%TYPE;
   BEGIN
      SELECT icapital
        INTO v_import
        FROM (SELECT icapital
                FROM garanseg
               WHERE cgarant = p_garant
                 AND sseguro = p_sseguro
                 AND ffinefe IS NULL
              UNION
              SELECT icapital
                FROM estgaranseg
               WHERE cgarant = p_garant
                 AND sseguro = p_sseguro
                 AND ffinefe IS NULL);

      RETURN(v_import);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

--------------------------------------------------------------------------------
   FUNCTION f_revali(p_garant IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER IS
      v_crevali      garanseg.crevali%TYPE;
   BEGIN
      SELECT crevali
        INTO v_crevali
        FROM garanseg
       WHERE cgarant = p_garant
         AND sseguro = p_sseguro
         AND ffinefe IS NULL;

      RETURN(v_crevali);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   --BUG 10264 - JTS - 28/05/2009 - CRE - Incidencia condicionado particular PPJ
   FUNCTION f_revali_seguro(p_sseguro IN NUMBER)
      RETURN NUMBER IS
      v_crevali      seguros.crevali%TYPE;
   BEGIN
      SELECT crevali
        INTO v_crevali
        FROM seguros
       WHERE sseguro = p_sseguro;

      RETURN(v_crevali);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_revali_seguro;

   FUNCTION f_per_o_imp_creix_seguro(p_sseguro IN NUMBER, p_modo IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER IS
      v_result       NUMBER(15, 5);
      vsproduc       NUMBER(8);
      vcrevali       NUMBER(8);
      vnmovimi       NUMBER(8);
   BEGIN
      IF p_modo = 'SEG' THEN
         SELECT DECODE(crevali, 1, irevali, prevali)
           INTO v_result
           FROM seguros
          WHERE sseguro = p_sseguro;
      -- Bug 17444 - RSC - 27/01/2011 - aportaci¿ ppa revalloritzaci¿ linea¿
      --SELECT sproduc, crevali
      --INTO vsproduc, vcrevali
      --FROM seguros
      --WHERE sseguro = p_sseguro;

      --IF vsproduc IN(277, 279, 280, 281, 295)   --BUG 12839 - JTS - 03/02/2010
      --   AND vcrevali = 1 THEN
      --   SELECT ROUND((gs.icapital / v_result), 2)
      --     INTO v_result
      --     FROM garanseg gs
      --    WHERE gs.sseguro = p_sseguro
      --      AND gs.cgarant = 48
      --      AND gs.nmovimi = (SELECT MAX(m.nmovimi)
      --                          FROM movseguro m
      --                         WHERE m.sseguro = gs.sseguro);
      --END IF;
      -- Fin bug 17444
      ELSIF p_modo = 'EST' THEN   --BUG 12839 - JTS - 04/02/2010
         SELECT DECODE(crevali, 1, irevali, prevali)
           INTO v_result
           FROM estseguros
          WHERE sseguro = p_sseguro;
      -- Bug 17444 - RSC - 27/01/2011 - aportaci¿ ppa revalloritzaci¿ linea¿
      --SELECT sproduc, crevali
      --INTO vsproduc, vcrevali
      --FROM estseguros
      --WHERE sseguro = p_sseguro;

      --IF vsproduc IN(277, 279, 280, 281, 295)   --BUG 12839 - JTS - 03/02/2010
      --   AND vcrevali = 1 THEN
      --   SELECT ROUND((gs.icapital / v_result), 2)
      --     INTO v_result
      --     FROM estgaranseg gs
      --    WHERE gs.sseguro = p_sseguro
      --      AND gs.cgarant = 48;
      --END IF;
      END IF;

      RETURN(v_result);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_per_o_imp_creix_seguro;

   --Fi BUG 10264 - JTS - 28/05/2009

   --------------------------------------------------------------------------------
   FUNCTION f_per_o_imp_creix(p_garant IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER IS
      v_result       NUMBER(15, 5);
   BEGIN
      SELECT DECODE(crevali, 1, irevali, prevali)
        INTO v_result
        FROM garanseg
       WHERE cgarant = p_garant
         AND sseguro = p_sseguro
         AND ffinefe IS NULL;

      RETURN(v_result);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

--------------------------------------------------------------------------------
   FUNCTION f_fecha_ultpago(p_sseguro IN NUMBER, p_sproduc IN NUMBER)
      RETURN VARCHAR2 IS
      vfechault      VARCHAR2(20);
      vfvencim       DATE;
      vmesany        VARCHAR2(20);
   BEGIN
      SELECT fvencim
        INTO vfvencim
        FROM (SELECT fvencim
                FROM seguros
               WHERE sseguro = p_sseguro
              UNION
              SELECT fvencim
                FROM estseguros
               WHERE sseguro = p_sseguro);

      IF NVL(f_parproductos_v(p_sproduc, 'RECMESVENCI'), 1) = 1 THEN
         SELECT TO_CHAR(vfvencim, 'MM/YYYY')
           INTO vmesany
           FROM DUAL;

         vfechault := '01/' || vmesany;
      ELSE
         SELECT TO_CHAR(ADD_MONTHS(vfvencim, -1), 'MM/YYYY')
           INTO vmesany
           FROM DUAL;

         vfechault := '01/' || vmesany;
      END IF;

      RETURN vfechault;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

--------------------------------------------------------------------------------
   FUNCTION f_import_concepto(p_sseguro IN NUMBER, p_concepto IN NUMBER, p_ctrecibo IN NUMBER)
      RETURN VARCHAR2 IS
      v_iips         NUMBER(15, 2);
      v_idgs         NUMBER(15, 2);
      v_iarbitr      NUMBER(15, 2);
      v_ifng         NUMBER(15, 2);
      v_cforpag      NUMBER(15, 2);
   BEGIN
      SELECT NVL(v.iips, 0), NVL(v.idgs, 0), NVL(v.iarbitr, 0), NVL(v.ifng, 0)
        INTO v_iips, v_idgs, v_iarbitr, v_ifng
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.nrecibo = v.nrecibo
         AND r.ctiprec = p_ctrecibo
         AND r.nmovimi = f_max_nmovimi(s.sseguro);

      IF p_concepto = 4 THEN
         RETURN TO_CHAR(v_iips, 'FM999G999G999G990D00');
      ELSIF p_concepto = 5 THEN
         RETURN TO_CHAR(v_idgs, 'FM999G999G999G990D00');
      ELSIF p_concepto = 6 THEN
         RETURN TO_CHAR(v_iarbitr, 'FM999G999G999G990D00');
      ELSIF p_concepto = 7 THEN
         RETURN TO_CHAR(v_ifng, 'FM999G999G999G990D00');
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_import_concepto;

--------------------------------------------------------------------------------
   FUNCTION f_fsuplem(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_resul        VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(fefecto, 'DD/MM/YYYY')
        INTO v_resul
        FROM movseguro
       WHERE sseguro = p_sseguro
         AND nmovimi = p_nmovimi;

      RETURN(v_resul);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(NULL);
   END f_fsuplem;

--------------------------------------------------------------------------------
   FUNCTION f_recfracc_ultimsuplement(p_sseguro IN NUMBER)
      RETURN NUMBER IS
      v_crecfra      NUMBER;
      v_err          NUMBER;
      v_aux          NUMBER := 0;
      v_impfrac      NUMBER := 0;
   BEGIN
      SELECT NVL(crecfra, 0)
        INTO v_crecfra
        FROM seguros
       WHERE sseguro = p_sseguro;

      FOR c IN (SELECT cgarant, iprianu, nriesgo, nmovimi, idtocom
                  FROM garanseg g
                 WHERE g.ffinefe IS NULL
                   AND g.sseguro = p_sseguro) LOOP
         v_err := pac_tarifas.f_calcula_concepto(p_sseguro, c.nriesgo, c.nmovimi, 'POL', 8,
                                                 v_crecfra, c.cgarant, c.iprianu, c.idtocom,
                                                 v_aux);

         IF v_err = 0 THEN
            v_impfrac := v_impfrac + NVL(v_aux, 0);
         END IF;
      END LOOP;

      RETURN(v_impfrac);
   END f_recfracc_ultimsuplement;

--------------------------------------------------------------------------------
   FUNCTION f_tributs_ultimsuplement(p_sseguro IN NUMBER)
      RETURN NUMBER IS
      v_crecfra      NUMBER;
      v_err          NUMBER;
      v_aux          NUMBER := 0;
      v_iconsor      NUMBER := 0;
      v_iips         NUMBER := 0;
      v_iarbitr      NUMBER := 0;
      v_ifng         NUMBER := 0;
      v_irecfra      NUMBER := 0;
   BEGIN
      SELECT NVL(crecfra, 0)
        INTO v_crecfra
        FROM seguros
       WHERE sseguro = p_sseguro;

      FOR c IN (SELECT cgarant, iprianu, nriesgo, nmovimi, idtocom
                  FROM garanseg g
                 WHERE g.ffinefe IS NULL
                   AND g.sseguro = p_sseguro) LOOP
         v_err := pac_tarifas.f_calcula_concepto(p_sseguro, c.nriesgo, c.nmovimi, 'POL', 2,
                                                 v_crecfra, c.cgarant, c.iprianu, c.idtocom,
                                                 v_aux);

         IF v_err = 0 THEN
            v_iconsor := v_iconsor + NVL(v_aux, 0);
         END IF;

         v_err := pac_tarifas.f_calcula_concepto(p_sseguro, c.nriesgo, c.nmovimi, 'POL', 4,
                                                 v_crecfra, c.cgarant, c.iprianu, c.idtocom,
                                                 v_aux);

         IF v_err = 0 THEN
            v_iips := v_iips + NVL(v_aux, 0);
         END IF;

         v_err := pac_tarifas.f_calcula_concepto(p_sseguro, c.nriesgo, c.nmovimi, 'POL', 6,
                                                 v_crecfra, c.cgarant, c.iprianu, c.idtocom,
                                                 v_aux);

         IF v_err = 0 THEN
            v_iarbitr := v_iarbitr + NVL(v_aux, 0);
         END IF;

         v_err := pac_tarifas.f_calcula_concepto(p_sseguro, c.nriesgo, c.nmovimi, 'POL', 7,
                                                 v_crecfra, c.cgarant, c.iprianu, c.idtocom,
                                                 v_aux);

         IF v_err = 0 THEN
            v_ifng := v_ifng + NVL(v_aux, 0);
         END IF;
      END LOOP;

      RETURN(v_iconsor + v_iips + v_iarbitr + v_ifng);
   END f_tributs_ultimsuplement;

--------------------------------------------------------------------------------
   FUNCTION f_prtotal_ultimsuplement(p_sseguro IN NUMBER)
      RETURN NUMBER IS
      v_suma         NUMBER := 0;
   BEGIN
      v_suma := pac_isqlfor.f_primaanual(p_sseguro, NULL, NULL);
      v_suma := v_suma + pac_isqlfor.f_recfracc_ultimsuplement(p_sseguro);
      v_suma := v_suma + pac_isqlfor.f_tributs_ultimsuplement(p_sseguro);
      RETURN(v_suma);
   END f_prtotal_ultimsuplement;

--------------------------------------------------------------------------------
   FUNCTION f_prima_mensual_nmovimi(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN NUMBER IS
      v_prima_mensual_inicial NUMBER(15, 2);
      v_cempres      NUMBER(2);
      v_ctiprec      NUMBER(2);
      -- Bug 14422 - RSC - 07/06/2010 - CRE800 - P¿lizas con copago y suplementos
      v_sproduc      seguros.sproduc%TYPE;
      v_conta        NUMBER;
   -- Fin Bug 14422
   BEGIN
      -- Bug 14422 - RSC - 07/06/2010 - CRE800 - P¿lizas con copago y suplementos
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = p_sseguro;

      SELECT COUNT(*)
        INTO v_conta
        FROM aportaseg
       WHERE sseguro = p_sseguro;

      IF v_conta > 0 THEN
         SELECT   SUM(v.itotalr), s.cempres, r.ctiprec
             INTO v_prima_mensual_inicial, v_cempres, v_ctiprec
             FROM seguros s, recibos r, vdetrecibos v
            WHERE s.sseguro = p_sseguro
              AND s.sseguro = r.sseguro
              AND r.nrecibo = v.nrecibo
              AND r.nmovimi = p_nmovimi
         GROUP BY s.cempres, r.ctiprec;
      ELSE
         -- Fin Bug 14422
         SELECT v.itotalr, s.cempres, r.ctiprec
           INTO v_prima_mensual_inicial, v_cempres, v_ctiprec
           FROM seguros s, recibos r, vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.nmovimi = p_nmovimi;
      END IF;

      --BUG 14323 - JTS - 27/04/2010
      IF v_cempres IN(4, 5)
         AND v_ctiprec = 9 THEN
         v_prima_mensual_inicial := v_prima_mensual_inicial *(-1);
      END IF;

      --FI BUG 14323
      RETURN(v_prima_mensual_inicial);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_prima_mensual_nmovimi;

--------------------------------------------------------------------------------
   FUNCTION f_altresa(p_sseguro IN NUMBER, p_camp IN VARCHAR2, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS   -- P_CAMP: 'NOM', 'PARENT', 'SEXE', 'FNAC', 'NIF', 'CASS'
      v_result       VARCHAR2(32000);
      v_numcass      VARCHAR2(40);
      v_parenta      VARCHAR2(40);
      psproduc       NUMBER;

      CURSOR cur_altres IS
         SELECT   r.nriesgo, per.tapelli, per.tnombre, per.sperson, per.fnacimi, per.nnumnif
             FROM riesgos r, personas per
            WHERE r.sseguro = p_sseguro
              AND r.sperson = per.sperson
              AND r.fanulac IS NULL
         ORDER BY r.nriesgo;

      CURSOR cur_altres_est IS
         SELECT   r.nriesgo, per.tapelli, per.tnombre, per.sperson, per.fnacimi, per.nnumnif
             FROM estriesgos r, estpersonas per
            WHERE r.sseguro = p_sseguro
              AND r.sperson = per.sperson
              AND r.fanulac IS NULL
         ORDER BY r.nriesgo;
   BEGIN
      IF p_tipo = 1 THEN
         FOR reg IN cur_altres LOOP
            IF p_camp = 'NOM' THEN
               v_result := v_result || reg.tapelli || ', ' || reg.tnombre || ' (Asseg.'
                           || reg.nriesgo || ')\par ';
            ELSIF p_camp = 'PARENT' THEN
               --Bug 17874 - 03/03/2011 - AMC
               SELECT sproduc
                 INTO psproduc
                 FROM seguros
                WHERE sseguro = p_sseguro;

               BEGIN
                  SELECT r.trespue
                    INTO v_parenta
                    FROM pregunseg pr, respuestas r
                   WHERE pr.sseguro = p_sseguro
                     AND pr.nmovimi = (SELECT MAX(nmovimi)
                                         FROM pregunseg p2
                                        WHERE p2.sseguro = pr.sseguro
                                          AND p2.cpregun = pr.cpregun
                                          AND p2.nriesgo = pr.nriesgo)
                     AND pr.nriesgo = reg.nriesgo
                     AND pr.cpregun = r.cpregun
                     AND pr.cpregun = DECODE(psproduc, 258, 540, 505)
                     AND r.cidioma = 1
                     AND pr.crespue = r.crespue;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_parenta := 'Titular';
               END;

               -- Fi Bug 17874 - 03/03/2011 - AMC
               v_result := v_result || v_parenta || '\par ';
            ELSIF p_camp = 'SEXE' THEN
               v_result := v_result || pac_isqlfor.f_dades_persona(reg.sperson, 3) || '\par ';
            ELSIF p_camp = 'FNAC' THEN
               v_result := v_result || TO_CHAR(reg.fnacimi, 'dd/mm/yyyy') || '\par ';
            ELSIF p_camp = 'NIF' THEN
               v_result := v_result || reg.nnumnif || '\par ';
            ELSIF p_camp = 'CASS' THEN
               BEGIN
                  SELECT trespue
                    INTO v_numcass
                    FROM pregunseg pr
                   WHERE sseguro = p_sseguro
                     AND pr.nmovimi = (SELECT MAX(nmovimi)
                                         FROM pregunseg p2
                                        WHERE p2.sseguro = pr.sseguro
                                          AND p2.cpregun = pr.cpregun
                                          AND p2.nriesgo = pr.nriesgo)
                     AND nriesgo = reg.nriesgo
                     AND cpregun = 530
                     AND crespue = 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_numcass := ' ';
               END;

               v_result := v_result || v_numcass || '\par ';
            END IF;
         END LOOP;
      ELSE
         FOR reg IN cur_altres_est LOOP
            IF p_camp = 'NOM' THEN
               v_result := v_result || reg.tapelli || ', ' || reg.tnombre || ' (Asseg.'
                           || reg.nriesgo || ')\par ';
            ELSIF p_camp = 'PARENT' THEN
               --Bug 17874 - 03/03/2011 - AMC
               SELECT sproduc
                 INTO psproduc
                 FROM estseguros
                WHERE sseguro = p_sseguro;

               BEGIN
                  SELECT r.trespue
                    INTO v_parenta
                    FROM estpregunseg pr, respuestas r
                   WHERE pr.sseguro = p_sseguro
                     AND pr.nmovimi = (SELECT MAX(nmovimi)
                                         FROM estpregunseg p2
                                        WHERE p2.sseguro = pr.sseguro
                                          AND p2.cpregun = pr.cpregun
                                          AND p2.nriesgo = pr.nriesgo)
                     AND pr.nriesgo = reg.nriesgo
                     AND pr.cpregun = r.cpregun
                     AND pr.cpregun = DECODE(psproduc, 258, 540, 505)
                     AND r.cidioma = 1
                     AND pr.crespue = r.crespue;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_parenta := 'Titular';
               END;

               -- Fi Bug 17874 - 03/03/2011 - AMC
               v_result := v_result || v_parenta || '\par ';
            ELSIF p_camp = 'SEXE' THEN
               v_result := v_result || pac_isqlfor.f_dades_persona(reg.sperson, 3, 1, 'EST')
                           || '\par ';
            ELSIF p_camp = 'FNAC' THEN
               v_result := v_result || TO_CHAR(reg.fnacimi, 'dd/mm/yyyy') || '\par ';
            ELSIF p_camp = 'NIF' THEN
               v_result := v_result || reg.nnumnif || '\par ';
            ELSIF p_camp = 'CASS' THEN
               BEGIN
                  SELECT trespue
                    INTO v_numcass
                    FROM estpregunseg pr
                   WHERE sseguro = p_sseguro
                     AND pr.nmovimi = (SELECT MAX(nmovimi)
                                         FROM estpregunseg p2
                                        WHERE p2.sseguro = pr.sseguro
                                          AND p2.cpregun = pr.cpregun
                                          AND p2.nriesgo = pr.nriesgo)
                     AND nriesgo = reg.nriesgo
                     AND cpregun = 530
                     AND crespue = 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_numcass := ' ';
               END;

               v_result := v_result || v_numcass || '\par ';
            END IF;
         END LOOP;
      END IF;

      -- BUG10134:08/06/2009:DRA:Inici
      v_result := REPLACE(v_result, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN(v_result);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_altresa;

--------------------------------------------------------------------------------
   FUNCTION f_altresa_nom(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN(pac_isqlfor.f_altresa(p_sseguro, 'NOM', p_tipo));
   END f_altresa_nom;

--------------------------------------------------------------------------------
   FUNCTION f_altresa_parent(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN(pac_isqlfor.f_altresa(p_sseguro, 'PARENT', p_tipo));
   END f_altresa_parent;

--------------------------------------------------------------------------------
   FUNCTION f_altresa_sexe(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN(pac_isqlfor.f_altresa(p_sseguro, 'SEXE', p_tipo));
   END f_altresa_sexe;

--------------------------------------------------------------------------------
   FUNCTION f_altresa_fnac(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN(pac_isqlfor.f_altresa(p_sseguro, 'FNAC', p_tipo));
   END f_altresa_fnac;

--------------------------------------------------------------------------------
   FUNCTION f_altresa_nif(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN(pac_isqlfor.f_altresa(p_sseguro, 'NIF', p_tipo));
   END f_altresa_nif;

--------------------------------------------------------------------------------
   FUNCTION f_altresa_cass(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN(pac_isqlfor.f_altresa(p_sseguro, 'CASS', p_tipo));
   END f_altresa_cass;

--------------------------------------------------------------------------------
   FUNCTION f_cuestsaa(p_sseguro IN NUMBER, p_cidioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      CURSOR cur_riesgos IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = p_sseguro
         UNION
         SELECT nriesgo
           FROM estriesgos
          WHERE sseguro = p_sseguro;

      CURSOR cur_cuestsaa IS
         SELECT   pp.cpregun, pr.tpregun
             FROM pregunpro pp, codipregun c, preguntas pr, seguros s
            WHERE pp.sproduc = s.sproduc
              AND s.sseguro = p_sseguro
              AND pp.cpregun = c.cpregun
              AND c.ctipgru = 1
              AND pr.cpregun = pp.cpregun
              AND pr.cidioma = NVL(p_cidioma, 1)
              AND pp.cpregun NOT IN(529, 530)
         UNION
         SELECT   pp.cpregun, pr.tpregun
             FROM pregunpro pp, codipregun c, preguntas pr, estseguros s
            WHERE pp.sproduc = s.sproduc
              AND s.sseguro = p_sseguro
              AND pp.cpregun = c.cpregun
              AND c.ctipgru = 1
              AND pr.cpregun = pp.cpregun
              AND pr.cidioma = NVL(p_cidioma, 1)
              AND pp.cpregun NOT IN(529, 530)
         ORDER BY cpregun ASC;

      v_result       VARCHAR2(32000) := '';
      v_respuesta    VARCHAR2(32000) := '';
      v_separador    VARCHAR2(20);
      v_ncontador    NUMBER;
      v_npregnum     NUMBER := 0;
   BEGIN
      SELECT SUM(a)
        INTO v_ncontador
        FROM (SELECT COUNT(1) a
                FROM riesgos
               WHERE sseguro = p_sseguro
              UNION
              SELECT COUNT(1) a
                FROM estriesgos
               WHERE sseguro = p_sseguro);

      FOR reg IN cur_cuestsaa LOOP
         v_npregnum := v_npregnum + 1;

         IF v_npregnum > 1 THEN
            v_separador := RPAD('_', 5, '_') || '\par ';
         END IF;

         v_result := v_result || v_separador || v_npregnum || '.- ' || reg.tpregun || '\par ';

         -- Obtenemos respuesta por cada asegurado
         FOR reg2 IN cur_riesgos LOOP
            IF reg2.nriesgo = 1 THEN
               IF v_ncontador > 1 THEN
                  v_result := v_result || '(Asseg.' || reg2.nriesgo || ': ';
               END IF;
            ELSE
               v_result := v_result || ' (Asseg.' || reg2.nriesgo || ': ';
            END IF;

            BEGIN
               -- BUG 9472 - 01/04/2009 - SBG - No es tenia en compte el pr.trespue
               SELECT resposta
                 INTO v_respuesta
                 FROM (SELECT NVL(pr.trespue, NVL(r.trespue, TRUNC(pr.crespue, 2))) resposta
                         FROM pregunseg pr, respuestas r
                        WHERE pr.sseguro = p_sseguro
                          AND pr.nmovimi = 1
                          AND pr.nriesgo = reg2.nriesgo
                          AND pr.cpregun = r.cpregun(+)
                          AND pr.cpregun = reg.cpregun
                          AND r.cidioma(+) = NVL(p_cidioma, 1)
                          AND pr.crespue = r.crespue(+)
                       UNION
                       SELECT NVL(pr.trespue, NVL(r.trespue, TRUNC(pr.crespue, 2))) resposta
                         FROM estpregunseg pr, respuestas r
                        WHERE pr.sseguro = p_sseguro
                          AND pr.nmovimi = 1
                          AND pr.nriesgo = reg2.nriesgo
                          AND pr.cpregun = r.cpregun(+)
                          AND pr.cpregun = reg.cpregun
                          AND r.cidioma(+) = NVL(p_cidioma, 1)
                          AND pr.crespue = r.crespue(+));
            -- FINAL BUG 9472 - 01/04/2009 - SBG
            EXCEPTION
               WHEN OTHERS THEN
                  v_respuesta := '---';
            END;

            -- Se a¿ade respuesta.
            v_result := v_result || v_respuesta;

            IF v_ncontador > 1 THEN
               v_result := v_result || ')';
            END IF;
         END LOOP;

         -- Generamos cambio de l¿nea
         v_result := v_result || '\par';
      END LOOP;

      -- BUG10134:08/06/2009:DRA:Inici
      v_result := REPLACE(v_result, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN(v_result);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_cuestsaa;

--------------------------------------------------------------------------------
   FUNCTION f_detalleds(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      CURSOR cur_riesgos IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = p_sseguro
         UNION
         SELECT nriesgo
           FROM estriesgos
          WHERE sseguro = p_sseguro;

      v_result       VARCHAR2(32000) := '';
      v_respuesta    VARCHAR2(32000) := '';
      v_ncontador    NUMBER;
   BEGIN
      SELECT SUM(a)
        INTO v_ncontador
        FROM (SELECT COUNT(1) a
                FROM riesgos
               WHERE sseguro = p_sseguro
              UNION
              SELECT COUNT(1) a
                FROM estriesgos
               WHERE sseguro = p_sseguro);

      FOR reg IN cur_riesgos LOOP
         -- Obtenemos respuesta por riesgo
         BEGIN
            SELECT trespue
              INTO v_respuesta
              FROM (SELECT pr.trespue
                      FROM pregunseg pr
                     WHERE pr.sseguro = p_sseguro
                       AND pr.nmovimi = 1
                       AND pr.nriesgo = reg.nriesgo
                       AND pr.cpregun = 529
                    UNION
                    SELECT pr.trespue
                      FROM estpregunseg pr
                     WHERE pr.sseguro = p_sseguro
                       AND pr.nmovimi = 1
                       AND pr.nriesgo = reg.nriesgo
                       AND pr.cpregun = 529);

            -- Se a¿ade respuesta de cada asegurado.
            IF v_ncontador > 1 THEN
               v_result := v_result || '(Asseg.' || reg.nriesgo || ':) ';
            END IF;

            v_result := v_result || v_respuesta || '\par ';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      -- BUG10134:08/06/2009:DRA:Inici
      v_result := REPLACE(v_result, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN(v_result);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_detalleds;

--------------------------------------------------------------------------------
   -- BUG 9574 - 02/04/2009 - SBG - Es comprova amb una crida a f_pargaranpro si
   -- les garanties amb capital=0 cal imprimir-les o no.
   -- BUG 9512 - 08/04/2009 - SBG - Es separa la select depenent de si estem a CREDIT o no.
   -- Bug 11006 - 07/09/2009 - ASN - Eliminamos el parametro p_ntipsel y consideramos el parametro 'GARANT_IMP'
--------------------------------------------------------------------------------
   FUNCTION f_garantias_ass1(
      p_sseguro IN NUMBER,
      p_idioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL'
/******************************************************************************
   ¿¿¿¿FUNCION OBSOLETA!!!!
   MEJOR UTILIZAR FUNCION M¿S GEN¿RICA: F_GARANTIAS_RIESGO; SE DUPLICA PARA NO
   CREAR CONFUSI¿N CON EL NOMBRE
******************************************************************************//* ,
                                      p_ntipsel IN NUMBER DEFAULT 1    */
                                                                            -- Bug 11006 - 07/09/2009 - ASN
   )
      RETURN VARCHAR2 IS
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_tlinia       VARCHAR2(50);
      v_tpargar      VARCHAR2(200);
      v_tablaseg     VARCHAR2(30);
      v_act0         NUMBER(1);
      v_actividad    VARCHAR2(20);
   BEGIN
      -- BUG 16092 - 12/01/2011 - JMP - AGA RC: Miramos si las garant¿as est¿n definidas para la actividad del seguro
      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tablaseg := 'estseguros';
      ELSE
         v_tablaseg := 'seguros';
      END IF;

      v_tconsulta := 'BEGIN SELECT decode(count(*), 0, 1, 0)'
                     || ' INTO :v_act0 FROM garanpro gp, ' || v_tablaseg || ' s'
                     || ' WHERE s.sseguro = :p_sseguro AND gp.sproduc = s.sproduc'
                     || ' AND gp.cactivi = s.cactivi; END;';

      EXECUTE IMMEDIATE v_tconsulta
                  USING OUT v_act0, IN p_sseguro;

      IF v_act0 = 1 THEN
         v_actividad := '0';
      ELSE
         v_actividad := 'se.cactivi';
      END IF;

      -- Fin BUG 16092 - 12/01/2011 - JMP
      v_tconsulta := 'SELECT REPLACE(tgarant, CHR(39), CHR(39) || CHR(39)) a';
      v_tconsulta := v_tconsulta || ' FROM garangen g, garanpro p, ';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || 'estgaranseg s, estseguros se';
      ELSE
         v_tconsulta := v_tconsulta || 'garanseg s, seguros se';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE g.cgarant = s.cgarant';
      v_tconsulta := v_tconsulta || ' AND p.cgarant = s.cgarant';
      v_tconsulta := v_tconsulta || ' AND p.sproduc = se.sproduc';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = se.sseguro';
      v_tconsulta := v_tconsulta || ' AND p.CACTIVI = ' || v_actividad;
      v_tconsulta := v_tconsulta || ' AND s.ffinefe IS NULL';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND g.cidioma = ' || NVL(p_idioma, 1);
      v_tconsulta := v_tconsulta || ' AND s.nriesgo = 1';

      -- Bug 19020 - APD - 29/07/2011 - si pmode = EST
      --  s¿lo deben imprimirse las garant¿as seleccionadas
      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' AND s.cobliga = 1';
      END IF;

      -- Fin Bug 19020 - APD - 29/07/2011
      /*      IF NVL(p_ntipsel, 1) = 1 THEN
               v_tconsulta := v_tconsulta || ' AND s.icapital IS NOT NULL';
               v_tconsulta :=
                  v_tconsulta
                  || ' ORDER BY DECODE(g.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC';
            ELSIF p_ntipsel = 3 THEN
               v_tconsulta := v_tconsulta || ' ORDER BY p.norden';
            ELSE
      */ -- Bug 11006 - 07/09/2009 - ASN - Se elimina el parametro p_ntipsel
      SELECT ' AND (NVL(pac_parametros.f_pargaranpro_n(' || sproduc || ', ' || cactivi
             --                || ', g.cgarant, ''GARANT_IMP''), 0) = 1 OR NVL(icapital, 0) > 0)' Bug 11006 07/09/2009 ASN
             || ', g.cgarant, ''GARANT_IMP''), 0) = 1 OR NVL(icapital, 0) > 0)'
        INTO v_tpargar
        FROM (SELECT seg.sproduc, seg.cactivi
                FROM seguros seg
               WHERE seg.sseguro = p_sseguro
              UNION
              SELECT seg.sproduc, seg.cactivi
                FROM estseguros seg
               WHERE seg.sseguro = p_sseguro);

      v_tconsulta := v_tconsulta || v_tpargar;
      v_tconsulta := v_tconsulta || ' ORDER BY p.norden';

      --      END IF;  Bug 11006 - 07/09/2009 - ASN
      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_tlinia;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || v_tlinia || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_garantias_ass1;

--------------------------------------------------------------------------------
   -- BUG 9574 - 02/04/2009 - SBG - Es comprova amb una crida a f_pargaranpro si
   -- les garanties amb capital=0 cal imprimir-les o no.
   -- BUG 9512 - 08/04/2009 - SBG - Es separa la select depenent de si estem a CREDIT o no.
   -- Bug 11006 - 07/09/2009 - ASN - Eliminamos el parametro p_ntipsel y consideramos el parametro 'GARANT_IMP'
   FUNCTION f_capitales_ass1(p_sseguro IN NUMBER, p_mode IN VARCHAR2 DEFAULT 'POL'
/******************************************************************************
   ¿¿¿¿FUNCION OBSOLETA!!!!
   MEJOR UTILIZAR FUNCION M¿S GEN¿RICA: F_CAPITALES_RIESGO; SE DUPLICA PARA NO
   CREAR CONFUSI¿N CON EL NOMBRE
******************************************************************************/                                    /* ,
                                                                                  p_ntipsel IN NUMBER DEFAULT 1    */ -- Bug 11006 - 07/09/2009 - ASN
   )
      RETURN VARCHAR2 IS
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(4000);
      v_tlinia       VARCHAR2(50);
      v_tpargar      VARCHAR2(200);
      v_icapital     garanseg.icapital%TYPE;
      v_ctipcap      garanpro.ctipcap%TYPE;
      v_cimpres      garanpro.cimpres%TYPE;
      v_npargar      NUMBER := 0;
      v_tablaseg     VARCHAR2(30);
      v_act0         NUMBER(1);
      v_actividad    VARCHAR2(20);
   BEGIN
      -- BUG 16092 - 12/01/2011 - JMP - AGA RC: Miramos si las garant¿as est¿n definidas para la actividad del seguro
      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tablaseg := 'estseguros';
      ELSE
         v_tablaseg := 'seguros';
      END IF;

      v_tconsulta := 'BEGIN SELECT decode(count(*), 0, 1, 0)'
                     || ' INTO :v_act0 FROM garanpro gp, ' || v_tablaseg || ' s'
                     || ' WHERE s.sseguro = :p_sseguro AND gp.sproduc = s.sproduc'
                     || ' AND gp.cactivi = s.cactivi; END;';

      EXECUTE IMMEDIATE v_tconsulta
                  USING OUT v_act0, IN p_sseguro;

      IF v_act0 = 1 THEN
         v_actividad := '0';
      ELSE
         v_actividad := 'se.cactivi';
      END IF;

      -- Fin BUG 16092 - 12/01/2011 - JMP
      v_tconsulta :=

         --       'SELECT TO_CHAR(icapital, ''FM999G999G999G990D00'') || '' EUR'' a, s.icapital b, p.ctipcap c';          Bug 11006 - 07/09/2009 - ASN
         'SELECT TO_CHAR(icapital, ''FM999G999G999G990D00'') || '' EUR'' a, s.icapital b, p.ctipcap c, p.cimpres,'
         || ' NVL(pac_parametros.f_pargaranpro_n(p.sproduc,p.cactivi,g.cgarant,''GARANT_IMP''), 0)';
      v_tconsulta := v_tconsulta || ' FROM garangen g, garanpro p,';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' estgaranseg s, estseguros se';
      ELSE
         v_tconsulta := v_tconsulta || ' garanseg s, seguros se';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE g.cgarant = s.cgarant';
      v_tconsulta := v_tconsulta || ' AND p.cgarant = s.cgarant';
      v_tconsulta := v_tconsulta || ' AND p.sproduc = se.sproduc';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = se.sseguro';
      v_tconsulta := v_tconsulta || ' AND p.cactivi = ' || v_actividad;
      v_tconsulta := v_tconsulta || ' AND s.ffinefe IS NULL';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND g.cidioma = 1';
      v_tconsulta := v_tconsulta || ' AND s.nriesgo = 1';

      -- Bug 19020 - APD - 29/07/2011 - si pmode = EST
      --  s¿lo deben imprimirse las garant¿as seleccionadas
      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' AND s.cobliga = 1';
      END IF;

      -- Fin Bug 19020 - APD - 29/07/2011
      /*      IF NVL(p_ntipsel, 1) = 1 THEN   -- BUG 9512
               v_tconsulta := v_tconsulta || ' AND s.icapital IS NOT NULL';
               v_tconsulta :=
                  v_tconsulta
                  || ' ORDER BY DECODE(p.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC';
            ELSIF p_ntipsel = 3 THEN
               v_tconsulta := v_tconsulta || ' ORDER BY p.norden';
            ELSE*/
      SELECT ' AND (NVL(pac_parametros.f_pargaranpro_n(' || sproduc || ', ' || cactivi
             || ', g.cgarant, ''GARANT_IMP''), 0) = 1 OR NVL(icapital, 0) > 0)'
        INTO v_tpargar
        FROM (SELECT seg.sproduc, seg.cactivi
                FROM seguros seg
               WHERE seg.sseguro = p_sseguro
              UNION
              SELECT seg.sproduc, seg.cactivi
                FROM estseguros seg
               WHERE seg.sseguro = p_sseguro);

      v_tconsulta := v_tconsulta || v_tpargar;
      v_tconsulta := v_tconsulta || ' ORDER BY p.norden';

            /*END IF;
      */
         -- Bug 11006 - 07/09/2009 - ASN--v_tconsulta := v_tconsulta || ' ORDER BY p.norden';
      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_tlinia, v_icapital, v_ctipcap, v_cimpres, v_npargar;

         EXIT WHEN vr_cursor%NOTFOUND;

          -- Bug 11006 - 07/09/2009 - ASN  INICIO
         /*         IF NVL(p_ntipsel, 1) = 1
                     OR p_ntipsel IN (2,3) THEN   -- BUG 9512
                     -- BUG 9505 - 09/04/2009 - SBG - Si la garantia ¿s "Indemn. baixa laboral"
                     -- hem de mostrar "INCLOSA" en lloc del capital. Finalment es decideix que
                     -- sigui aix¿ per a totes les garanties de tipus calculat (GARANPRO.CTIPCAP=4)
                     IF v_ctipcap = 4 THEN
                        --El que cal fer ¿s recuperar el tipus de capital de la garantia en q¿estio (camp CTIPCAP de GARANPRO), i en cas de ser una garantia de tipus calculat (CTIPCAP = 4) mostrar el literal "INCLOSA".
                        v_tlinia := f_axis_literales(104619, 1);
                     ELSE
                        -- FINAL BUG 9505 - 09/04/2009 - SBG
                        IF v_icapital = 0 THEN
                           v_tlinia := f_axis_literales(104619, 1);
                        END IF;
                     END IF;
                  END IF;
         */
         IF v_npargar = 1 THEN
            SELECT tatribu
              INTO v_tlinia
              FROM detvalores
             WHERE cvalor = 126
               AND catribu = NVL(v_cimpres, 59)   -- INCLOSSA
               AND cidioma = 1;
         END IF;

         -- Bug 11006 - 07/09/2009 - ASN  FIN
         v_tresult := v_tresult || v_tlinia || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_capitales_ass1;

--------------------------------------------------------------------------------
   FUNCTION f_benefs_riesgos(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_idioma IN NUMBER DEFAULT 1,
      p_claucre IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_result       VARCHAR2(32000) := '';
      v_clausula_crediticia NUMBER(1);
      v_sclapro      NUMBER(5);
      v_tclatex      VARCHAR2(2000);

      CURSOR cur_riesgos IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = p_sseguro
            AND fanulac IS NULL
            AND(p_nriesgo IS NULL
                OR(p_nriesgo IS NOT NULL
                   AND nriesgo = p_nriesgo));

      CURSOR cur_benef(p_nries NUMBER) IS
         SELECT DISTINCT NVL(REPLACE(REPLACE(tclaesp, CHR(39), CHR(39) || CHR(39)),
                                     CHR(13) || CHR(10), '\par '),
                             '') clausula
                    FROM clausuesp c
                   WHERE cclaesp = 1
                     AND(ffinclau IS NULL
                         OR TRUNC(ffinclau) > TRUNC(f_sysdate))
                     AND sseguro = p_sseguro
                     AND ffinclau IS NULL
                     AND nriesgo = p_nries
         UNION
         SELECT NVL(REPLACE(cb.tclaben, CHR(39), CHR(39) || CHR(39)), '') clausula
           FROM claubenseg c, clausuben cb
          WHERE c.sseguro = p_sseguro
            AND c.ffinclau IS NULL
            AND c.sclaben = cb.sclaben
            AND cb.cidioma = NVL(p_idioma, 1)
            AND c.nriesgo = p_nries;
   BEGIN
      FOR reg IN cur_riesgos LOOP
         IF NVL(p_claucre, 0) = 1 THEN
            -- Inici cl¿usula crediticia:
            BEGIN
               SELECT crespue
                 INTO v_clausula_crediticia
                 FROM pregunseg
                WHERE sseguro = p_sseguro
                  AND nriesgo = reg.nriesgo
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregunseg
                                  WHERE sseguro = p_sseguro
                                    AND nriesgo = reg.nriesgo
                                    AND cpregun = 302)
                  AND cpregun = 302;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_clausula_crediticia := 0;
            END;

            IF v_clausula_crediticia = 1 THEN
               SELECT REPLACE(gen.tclatex, CHR(39), CHR(39) || CHR(39))
                 INTO v_result
                 FROM clausupreg preg, clausupro pro, clausugen gen
                WHERE gen.sclagen = pro.sclagen
                  AND pro.sclapro = preg.sclapro
                  AND preg.cpregun = 302
                  AND gen.cidioma = NVL(p_idioma, 1);
            ELSE
               v_result := NULL;
            END IF;
         -- Final cl¿usula crediticia
         ELSE
            FOR reg2 IN cur_benef(reg.nriesgo) LOOP
               IF p_nriesgo IS NULL THEN
                  v_result := v_result || '(Asseg.' || reg.nriesgo || ':) ' || v_tclatex
                              || reg2.clausula || '\par ';
               ELSE
                  v_result := v_tclatex || reg2.clausula;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      RETURN(v_result);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_benefs_riesgos;

   FUNCTION f_benefs(p_sseguro IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      v_result       VARCHAR2(32000) := '';

      CURSOR cur_benef IS
         SELECT DISTINCT NVL(REPLACE(REPLACE(tclaesp, CHR(39), CHR(39) || CHR(39)),
                                     CHR(13) || CHR(10), '\par '),
                             '') clausula
                    FROM clausuesp c
                   WHERE cclaesp = 1
                     AND(ffinclau IS NULL
                         OR TRUNC(ffinclau) > TRUNC(f_sysdate))
                     AND sseguro = p_sseguro
                     AND ffinclau IS NULL
         UNION
         SELECT NVL(REPLACE(cb.tclaben, CHR(39), CHR(39) || CHR(39)), '') clausula
           FROM claubenseg c, clausuben cb
          WHERE c.sseguro = p_sseguro
            AND c.ffinclau IS NULL
            AND c.sclaben = cb.sclaben
            AND cb.cidioma = NVL(p_idioma, 1);
   BEGIN
      FOR reg2 IN cur_benef LOOP
         v_result := v_result || reg2.clausula || '\par ';
      END LOOP;

      RETURN(v_result);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_benefs;

--------------------------------------------------------------------------------

   -- JGM --
   FUNCTION f_dirdeleg(
      pcdelega IN NUMBER,
      pcformat IN NUMBER,
      ptlin1 OUT VARCHAR2,
      ptlin2 OUT VARCHAR2,
      ptlin3 OUT VARCHAR2,
      ptlin4 OUT VARCHAR2,
      ptlin5 OUT VARCHAR2)
      RETURN NUMBER IS
      /***********************************************************************
          F_DIRDELE:  Retorna la direcci¿n de una delegaci¿n entrando su
      c¿digo.
      La variable PCFORMAT indica el tipo de formato ( de
      momento s¿lo existe el pcformat 1 ).
      Devuelve 5 l¿neas con la direcci¿n.
          ALLIBMFM

      ***********************************************************************/
      error          NUMBER := 0;
      xpersona       per_direcciones.sperson%type;
      xcdomici       per_direcciones.cdomici%TYPE;
      xtdomici       per_direcciones.tdomici%TYPE;
      xcpostal       codpostal.cpostal%TYPE;   -- canvi format codi postal
      xcpoblac       codpostal.cpoblac%TYPE;
      xcprovin       codpostal.cprovin%TYPE;
      xpoblacio      POBLACIONES.TPOBLAC%TYPE;
      xtelefono      PER_CONTACTOS.TVALCON%TYPE;
      xfax           PER_CONTACTOS.TVALCON%TYPE;
      xemail         PER_CONTACTOS.TVALCON%TYPE;
      xnomdel        PER_DETPER.TAPELLI1%TYPE;
   BEGIN
      IF pcdelega IS NOT NULL THEN
         IF pcformat = 1 THEN
            BEGIN
               SELECT d.sperson, d.cdomici, pd.tapelli1
                 INTO xpersona, xcdomici, xnomdel
                 FROM agentes a, per_direcciones d, per_personas p, per_detper pd
                WHERE a.cagente = pcdelega
                  AND d.sperson = a.sperson
                  AND d.sperson = p.sperson
                  AND p.swpubli = 1
                  AND p.sperson = pd.sperson
                  AND d.cdomici = (SELECT MIN(cdomici)
                                     FROM per_direcciones d2
                                    WHERE d2.sperson = d.sperson);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 104472;   -- Agent no trobat a AGENTES
               WHEN OTHERS THEN
                  RETURN 104473;   -- Error al llegir de AGENTES
            END;

            BEGIN
               SELECT tdomici, cpostal, cpoblac, cprovin
                 INTO xtdomici, xcpostal, xcpoblac, xcprovin
                 FROM per_direcciones
                WHERE sperson = xpersona
                  AND cdomici = xcdomici;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 104475;   -- Adre¿a no trobada a DIRECCIONES
               WHEN OTHERS THEN
                  RETURN 104474;   -- Error al llegir de DIRECCIONES
            END;

            BEGIN
               SELECT tvalcon
                 INTO xtelefono
                 FROM per_contactos
                WHERE sperson = xpersona
                  AND ctipcon = 1
                  AND cmodcon = (SELECT MIN(cmodcon)
                                   FROM per_contactos
                                  WHERE sperson = xpersona
                                    AND ctipcon = 1);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 104476;   -- Error al llegir de CONTACTOS
            END;

            BEGIN
               SELECT tvalcon
                 INTO xfax
                 FROM per_contactos
                WHERE sperson = xpersona
                  AND ctipcon = 2
                  AND cmodcon = (SELECT MIN(cmodcon)
                                   FROM per_contactos
                                  WHERE sperson = xpersona
                                    AND ctipcon = 2);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 104476;   -- Error al llegir de CONTACTOS
            END;

            BEGIN
               SELECT tvalcon
                 INTO xemail
                 FROM per_contactos
                WHERE sperson = xpersona
                  AND ctipcon = 3
                  AND cmodcon = (SELECT MIN(cmodcon)
                                   FROM per_contactos
                                  WHERE sperson = xpersona
                                    AND ctipcon = 3);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 104476;   -- Error al llegir de CONTACTOS
            END;

            error := f_despoblac(xcpoblac, xcprovin, xpoblacio);

            IF error = 0 THEN
               ptlin1 := RPAD(SUBSTR(pcdelega, 3, 6) || ' ' || xnomdel, 60, ' ');
               ptlin2 := RPAD(xtdomici, 60, ' ');
               ptlin3 := RPAD(xcpostal || ' ' || xpoblacio, 60, ' ');
               ptlin4 := NULL;

               IF xtelefono IS NOT NULL THEN
                  ptlin4 := 'Tel. ' || xtelefono;
               END IF;

               IF xfax IS NOT NULL THEN
                  ptlin4 := ptlin4 || ' ' || 'Fax. ' || xfax;
               END IF;

               ptlin5 := '';
               RETURN 0;
            ELSE
               RETURN error;
            END IF;
         ELSE
            RETURN 101901;   -- Error en la introducci¿ de par¿metres
         END IF;
      ELSE
         RETURN 101901;   -- Error en la introducci¿ de par¿metres
      END IF;
   END f_dirdeleg;

--------------------------------------------------------------------------------
   FUNCTION f_for_dirdele(pcdelega IN NUMBER)
      RETURN VARCHAR2 IS
      l1             VARCHAR2(100);
      l2             VARCHAR2(100);
      l3             VARCHAR2(100);
      l4             VARCHAR2(100);
      l5             VARCHAR2(100);
      v_error        NUMBER;
   BEGIN
      --usa f_dirdele
      v_error := f_dirdeleg(pcdelega, 1, l1, l2, l3, l4, l5);

      IF v_error = 0 THEN
         --return l1||' - '||l2||' - '||l3||' - '||l4||' - '||l5;
         RETURN REPLACE(l1 || l2 || l3 || l4, CHR(39), CHR(39) || CHR(39));
      ELSE
         RETURN TO_CHAR(v_error);
      END IF;
   END f_for_dirdele;

--------------------------------------------------------------------------------
   FUNCTION f_for_poblacion(pcdelega IN NUMBER)
      RETURN VARCHAR2 IS
      conta          NUMBER;
      l2             VARCHAR2(100);
      l1             VARCHAR2(100);
      l3             VARCHAR2(100);
      l4             VARCHAR2(100);
      l5             VARCHAR2(100);
      v_error        NUMBER;
   BEGIN
      --usa f_dirdele
      v_error := f_dirdele(pcdelega, 1, l1, l2, l3, l4, l5);

      IF v_error <> 0 THEN
         SELECT INSTR(l2, ' ')
           INTO conta
           FROM DUAL;

         SELECT SUBSTR(l2, conta + 1)
           INTO l1
           FROM DUAL;

         RETURN REPLACE(l1, CHR(39), CHR(39) || CHR(39));
      ELSE
         RETURN NULL;
      END IF;
   END f_for_poblacion;

--------------------------------------------------------------------------------
   FUNCTION f_for_aportextra(
      p_sseguro IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_cactivi IN NUMBER,
      p_tipo IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
      v_motiu        movseguro.cmotmov%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_capital      VARCHAR2(30);
   BEGIN
      BEGIN
         SELECT cmotmov, nmovimi
           INTO v_motiu, v_nmovimi
           FROM movseguro
          WHERE sseguro = p_sseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM movseguro
                            WHERE sseguro = p_sseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT TO_CHAR(icapital, 'FM999G999G999G990D00')
                 INTO v_capital
                 FROM estgaranseg
                WHERE sseguro = p_sseguro
                  AND f_pargaranpro_v(p_cramo, p_cmodali, p_ctipseg, p_ccolect, p_cactivi,
                                      cgarant, 'TIPO') = 4
                  AND nmovimi = 1;

               RETURN v_capital;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN TO_CHAR(0, 'FM999G999G999G990D00');
            END;
         WHEN OTHERS THEN
            RETURN -1;
      END;

      IF p_tipo = 0 THEN
         BEGIN
            SELECT TO_CHAR(icapital, 'FM999G999G999G990D00')
              INTO v_capital
              FROM garanseg
             WHERE sseguro = p_sseguro
               AND f_pargaranpro_v(p_cramo, p_cmodali, p_ctipseg, p_ccolect, p_cactivi,
                                   cgarant, 'TIPO') = 4
               AND nmovimi = DECODE(v_motiu, 500, v_nmovimi, 1);

            RETURN v_capital;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN TO_CHAR(0, 'FM999G999G999G990D00');
         END;
      ELSE
         BEGIN
            SELECT TO_CHAR(icapital, 'FM999G999G999G990D00')
              INTO v_capital
              FROM garanseg
             WHERE sseguro = p_sseguro
               AND f_pargaranpro_v(p_cramo, p_cmodali, p_ctipseg, p_ccolect, p_cactivi,
                                   cgarant, 'TIPO') = 4
               AND nmovimi = NVL(v_nmovimi, 0);

            RETURN v_capital;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN TO_CHAR(0, 'FM999G999G999G990D00');
         END;
      END IF;
   END f_for_aportextra;

--------------------------------------------------------------------------------
   FUNCTION f_for_aportperio(
      p_sseguro IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_cactivi IN NUMBER)
      RETURN VARCHAR2 IS
      v_capital      VARCHAR2(30);
   BEGIN
      SELECT TO_CHAR(icapital, 'FM999G999G999G990D00')
        INTO v_capital
        FROM garanseg
       WHERE sseguro = p_sseguro
         AND f_pargaranpro_v(p_cramo, p_cmodali, p_ctipseg, p_ccolect, p_cactivi, cgarant,
                             'TIPO') = 3
         AND ffinefe IS NULL;

      RETURN v_capital;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN TO_CHAR(0, 'FM999G999G999G990D00');
   END f_for_aportperio;

   FUNCTION f_litnompersona(p_sperson IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      tipusper       NUMBER;
      nombre         VARCHAR2(200);
   BEGIN
      SELECT ctipper   --tidenti
        INTO tipusper
        FROM per_personas
       WHERE sperson = p_sperson;

      IF tipusper = 2 THEN   -- Persona juridica
         nombre := f_axis_literales(9000651, p_idioma);
      ELSE   -- Persona fisica
         nombre := f_axis_literales(105940, p_idioma) || ':';
      END IF;

      -- BUG10134:08/06/2009:DRA:Inici
      nombre := REPLACE(nombre, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN nombre;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_litnompersona;

   FUNCTION f_litcognompersona(p_sperson IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      tipusper       NUMBER;
      nombre         VARCHAR2(200);
   BEGIN
      SELECT ctipper   --tidenti
        INTO tipusper
        FROM per_personas
       WHERE sperson = p_sperson;

      IF tipusper = 2 THEN   -- Persona juridica
         RETURN NULL;
      ELSE   -- Persona fisica
         nombre := f_axis_literales(1000560, p_idioma) || ':';
         -- BUG10134:08/06/2009:DRA:Inici
         nombre := REPLACE(nombre, CHR(39), CHR(39) || CHR(39));
         -- BUG10134:08/06/2009:DRA:Fi
         RETURN nombre;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_litcognompersona;

   FUNCTION f_nompersona(p_sperson IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      tipusper       NUMBER;
      nombre         VARCHAR2(200);
   BEGIN
      SELECT ctipper   --tidenti
        INTO tipusper
        FROM per_personas
       WHERE sperson = p_sperson;

      IF tipusper = 2 THEN   -- Persona juridica
         nombre := f_dades_persona(p_sperson, 4) || ' ' || f_dades_persona(p_sperson, 5);
      ELSE   -- Persona fisica
         nombre := f_dades_persona(p_sperson, 4);
      END IF;

      -- BUG10134:08/06/2009:DRA:Inici
      -- nombre := REPLACE(nombre, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN LTRIM(nombre);   -- Bug 0021373 - FAL - 15/02/2012. Evitar blanco cuando recupera nombre de jur¿dicas.
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_nompersona;

   FUNCTION f_cognompersona(p_sperson IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      tipusper       NUMBER;
      nombre         VARCHAR2(200);
   BEGIN
      SELECT ctipper   --tidenti
        INTO tipusper
        FROM per_personas
       WHERE sperson = p_sperson;

      IF tipusper = 2 THEN   -- Persona juridica
         RETURN NULL;
      ELSE   -- Persona fisica
         nombre := f_dades_persona(p_sperson, 5);
         -- BUG10134:08/06/2009:DRA:Inici
         -- nombre := REPLACE(nombre, CHR(39), CHR(39) || CHR(39));
         -- BUG10134:08/06/2009:DRA:Fi
         RETURN nombre;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_cognompersona;

--------------------------------------------------------------------------------
   FUNCTION f_clausula_particular(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_replace IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_resultat     VARCHAR2(31000);

      CURSOR c_clausuesp(pp_sseguro NUMBER, pp_nriesgo NUMBER) IS
         SELECT   tclaesp
             FROM clausuesp c1
            WHERE cclaesp = 2
              AND sseguro = pp_sseguro
              AND(pp_nriesgo IS NULL
                  OR(pp_nriesgo IS NOT NULL
                     AND nriesgo = pp_nriesgo))
              AND nmovimi = (SELECT MAX(nmovimi)
                               FROM clausuesp c2
                              WHERE cclaesp = 2
                                AND c2.nriesgo = c1.nriesgo
                                AND c2.sseguro = pp_sseguro)
         ORDER BY nordcla;
   BEGIN
      FOR cur IN c_clausuesp(p_sseguro, p_nriesgo) LOOP
         IF p_replace IS NOT NULL THEN
            v_resultat := v_resultat || REPLACE(cur.tclaesp, '<br>', CHR(10)) || '\par ';
         ELSE
            v_resultat := v_resultat || cur.tclaesp || '\par ';
         END IF;
      END LOOP;

      -- BUG10134:08/06/2009:DRA:Inici
      v_resultat := REPLACE(v_resultat, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN(v_resultat);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(NULL);
   END f_clausula_particular;

--------------------------------------------------------------------------------
   FUNCTION f_camp_ctaseguros(
      psseguro IN NUMBER,
      pcampo IN NUMBER,
      pfechaini IN DATE DEFAULT NULL,
      pfechafin IN DATE DEFAULT NULL)
      RETURN VARCHAR2 IS
      vtexto         VARCHAR2(4000);   --BUG15280 - JTS - 09/07/2010
      vfechaini      DATE;
      vfefecto       DATE;
      v_tcesta_unidades NUMBER;
      v_tcesta_importe NUMBER;
      v_total_cestas NUMBER;
      v_ccesta       segdisin2.ccesta%TYPE;
      v_error        axis_literales.slitera%TYPE;
   BEGIN
      IF pfechafin IS NULL THEN
         SELECT fefecto
           INTO vfefecto
           FROM seguros
          WHERE sseguro = psseguro;

         --SELECT GREATEST(vfefecto, ADD_MONTHS(f_sysdate, -12))
         SELECT ADD_MONTHS(f_sysdate, -12)
           INTO vfechaini
           FROM DUAL;
      END IF;

      -- Bug 11097 - RSC - 19/10/2009 - CRE - Documentaci¿n de los productos PPJ Din¿mico + PLA Estudiant
      -- Se a¿ade join con seguros y f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), ...
      -- Bug 23077 - 23/07/2012 - ECP - Se pasa el valor s.cidioma a la funci¿n ff_desvalorfijo
      FOR cur IN (SELECT   ff_desvalorfijo(83, s.cidioma, c.cmovimi) "MOVIMIENTO", c.ffecmov,
                           c.fvalmov, c.imovimi,
                           NVL(c.nrecibo, NVL(c.nsinies, c.srecren)) recibo, c.nunidad,
                           DECODE(c.nunidad,
                                  0, NULL,
                                  ROUND(c.imovimi / c.nunidad, 6)) valorliq, s.sproduc,
                           c.cesta, c.nnumlin, c.cmovimi
                      FROM ctaseguro c, seguros s
                     WHERE c.sseguro = psseguro
                       AND c.sseguro = s.sseguro
                       --AND c.fcontab BETWEEN NVL(pfechaini, vfechaini)  30/11/2009.NMM.i.12101
                       --                  AND NVL(pfechafin, f_sysdate)  30/11/2009.NMM.f.12101
                       AND((NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
                            AND c.cesta IS NOT NULL)
                           OR(NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
                              AND c.cmovimi = 0)
                           OR(NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1))
                  ORDER BY DECODE(c.cmovimi,   --BUG 15795-JTS-13/09/2010
                                  0, c.fvalmov,
                                  2, c.fvalmov,
                                  53, c.fvalmov,
                                  TRUNC(c.fcontab)) DESC,
                           c.nnumlin DESC) LOOP
         -- Fin Bug 11097
         -- BUG 19322 - 27/09/2011 - JMP
         IF pcampo IN(8, 9) THEN
            IF NVL(f_parproductos_v(cur.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
               OR(cur.imovimi IS NOT NULL
                  AND cur.nunidad IS NOT NULL) THEN
               v_tcesta_unidades := 0;
               v_tcesta_importe := 0;
               v_total_cestas := 0;

               IF cur.cesta IS NOT NULL THEN
                  v_error := pac_operativa_finv.f_cta_provision_cesta(psseguro, NULL,
                                                                      cur.fvalmov, cur.cesta,
                                                                      v_tcesta_unidades,
                                                                      v_tcesta_importe,
                                                                      v_total_cestas,
                                                                      cur.nnumlin);
               ELSE
                  IF cur.cmovimi = 0 THEN
                     SELECT ccesta
                       INTO v_ccesta
                       FROM segdisin2
                      WHERE sseguro = psseguro
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM segdisin2 s2
                                        WHERE s2.sseguro = segdisin2.sseguro);

                     v_error := pac_operativa_finv.f_cta_provision_cesta(psseguro, NULL,
                                                                         cur.fvalmov, v_ccesta,
                                                                         v_tcesta_unidades,
                                                                         v_tcesta_importe,
                                                                         v_total_cestas,
                                                                         cur.nnumlin);
                  END IF;
               END IF;
            END IF;
         END IF;

         -- FIN BUG 19322 - 27/09/2011 - JMP
         IF pcampo = 1 THEN
            vtexto := vtexto || cur.movimiento || '\par ';
         ELSIF pcampo = 2 THEN
            vtexto := vtexto || TO_CHAR(cur.ffecmov, 'DD/MM/YYYY') || '\par ';
         ELSIF pcampo = 3 THEN
            vtexto := vtexto || TO_CHAR(cur.fvalmov, 'DD/MM/YYYY') || '\par ';
         ELSIF pcampo = 4 THEN
            vtexto := vtexto || TO_CHAR(cur.imovimi, 'FM999G999G999G990D00') || '\par ';
         -- BUG 19322 - 27/09/2011 - JMP
         ELSIF pcampo = 5 THEN
            vtexto := vtexto || TO_CHAR(cur.recibo) || '\par ';
         ELSIF pcampo = 6 THEN
            vtexto := vtexto || TO_CHAR(cur.nunidad, 'FM999G999G999G990D00') || '\par ';
         ELSIF pcampo = 7 THEN
            vtexto := vtexto || TO_CHAR(cur.valorliq, 'FM999G999G999G990D00') || '\par ';
         ELSIF pcampo = 8 THEN
            vtexto := vtexto || TO_CHAR(v_tcesta_unidades, 'FM999G999G999G990D00') || '\par ';
         ELSIF pcampo = 9 THEN
            vtexto := vtexto || TO_CHAR(v_tcesta_importe, 'FM999G999G999G990D00') || '\par ';
         -- FIN BUG 19322 - 27/09/2011 - JMP
         END IF;
      END LOOP;

      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_camp_ctaseguros;

   --BUG 9059 - 19/03/2009 - JTS
   FUNCTION f_recibosimpagados(psseguro IN NUMBER, pfvencim IN DATE)
      RETURN VARCHAR2 IS
      vtext          VARCHAR2(2000);

      CURSOR c_rec IS
         SELECT r.nrecibo, TO_CHAR(r.fefecto, 'dd/mm/yyyy') fefecto,
                TO_CHAR(r.fvencim, 'dd/mm/yyyy') fvencim,
                (SELECT NVL(SUM(pac_gestion_rec.f_importe_recibo(r.nrecibo)), 0)
                   FROM recibos r, movrecibo m
                  WHERE r.nrecibo = imp.nrecibo
                    AND r.nrecibo = m.nrecibo
                    AND m.cestrec = 0
                    AND m.smovrec = (SELECT MAX(mm.smovrec)
                                       FROM movrecibo mm
                                      WHERE mm.nrecibo = r.nrecibo)
                    AND r.fvencim >= pfvencim) tot_venc,
                (SELECT NVL(SUM(pac_gestion_rec.f_importe_recibo(r.nrecibo)), 0)
                   FROM recibos r, movrecibo m
                  WHERE r.nrecibo = imp.nrecibo
                    AND r.nrecibo = m.nrecibo
                    AND m.cestrec = 0
                    AND m.smovrec = (SELECT MAX(mm.smovrec)
                                       FROM movrecibo mm
                                      WHERE mm.nrecibo = r.nrecibo)
                    AND r.fvencim < pfvencim) tot_novenc
           FROM (SELECT DISTINCT nrecibo
                            FROM tmp_impagados
                           WHERE sseguro = psseguro
                        ORDER BY nrecibo) imp,
                recibos r
          WHERE r.nrecibo = imp.nrecibo;
   BEGIN
      FOR i IN c_rec LOOP
         vtext := vtext || RPAD(i.nrecibo, 30, ' ') || RPAD(i.fefecto, 15, ' ')
                  || RPAD(i.fvencim, 25, ' ')
                  || LPAD(LTRIM(TO_CHAR(i.tot_venc, '999G999G990D99')), 14, ' ')
                  || LPAD(LTRIM(TO_CHAR(i.tot_novenc, '999G999G990D99')), 14, ' ') || '\par ';
      END LOOP;

      RETURN vtext;
   END f_recibosimpagados;

   -- BUG 9575-25/03/2009-AMC- Noves funcions

   /*************************************************************************
    FUNCTION f_conreb_nmovimi
    Recupera los diferentes importes del ¿ltimo recibo
    param in psseguro   : c¿digo del seguro
    param in pnmovimi   : n¿mero de movimiento
    param in pcampo     : n¿mero de campo que se quiere recuperar
    return             : importe del campo requerido
    *************************************************************************/
   FUNCTION f_conreb_nmovimi(psseguro IN NUMBER, pnmovimi IN NUMBER, pcampo IN NUMBER)
      RETURN VARCHAR2 IS
      v_itotalr      NUMBER(15, 2);
      v_iprinet      NUMBER(15, 2);
      v_iips         NUMBER(15, 2);
      v_iconsor      NUMBER(15, 2);
      v_idgs         NUMBER(15, 2);
      v_irecfra      NUMBER(15, 2);
      v_itotdto      NUMBER(15, 2);
      v_formateado   VARCHAR2(100);
   BEGIN
      SELECT v.itotalr, v.iprinet, v.iips, v.iconsor, v.idgs, v.irecfra, v.itotdto
        INTO v_itotalr, v_iprinet, v_iips, v_iconsor, v_idgs, v_irecfra, v_itotdto
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = psseguro
         AND s.sseguro = r.sseguro
         AND r.nrecibo = v.nrecibo
         AND r.nmovimi = pnmovimi;

      IF pcampo = 1 THEN
         SELECT TO_CHAR(NVL(v_itotalr, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 2 THEN
         SELECT TO_CHAR(NVL(v_iprinet, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 3 THEN
         SELECT TO_CHAR(NVL(v_iips, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 4 THEN
         SELECT TO_CHAR(NVL(v_iconsor, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 5 THEN
         SELECT TO_CHAR(NVL(v_idgs, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 6 THEN
         SELECT TO_CHAR(NVL(v_iprinet + v_irecfra, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 7 THEN
         SELECT TO_CHAR(NVL(v_iprinet + v_irecfra - v_itotdto, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_conreb_nmovimi;

   /*************************************************************************
    FUNCTION f_tconreb_nmovimi
    Funci¿n que te devuelve la cabecera del campo si este es diferente de null
    param in psseguro   : c¿digo del seguro
    param in pnmovimi   : n¿mero de movimiento
    param in pcampo     : n¿mero de campo que se quiere recuperar
    param in pidioma    : idioma del literal
    return             : texto con el nombre del campo del RTF.
    *************************************************************************/
   FUNCTION f_tconreb_nmovimi(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcampo IN NUMBER,
      pidioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      v_return       VARCHAR2(100);
   BEGIN
      v_return := f_conreb_nmovimi(psseguro, pnmovimi, pcampo);

      IF v_return IS NULL THEN
         RETURN NULL;
      ELSE
         IF pcampo = 1 THEN
            RETURN f_axis_literales(806304, pidioma);
         ELSIF pcampo = 2 THEN
            RETURN f_axis_literales(806305, pidioma);
         ELSIF pcampo = 3 THEN
            RETURN f_axis_literales(806307, pidioma);
         ELSIF pcampo = 4 THEN
            RETURN f_axis_literales(806308, pidioma);
         ELSIF pcampo = 5 THEN
            RETURN f_axis_literales(806309, pidioma);
         END IF;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tconreb_nmovimi;

   --Fi BUG 9575-25/03/2009-AMC

   -- BUG 9472 - 23/04/2009 - SBG - Es crea la funci¿ f_salud_preguntas
   /*************************************************************************
     FUNCTION f_salud_preguntas
     Devuelve cuestionario de salud para un asegurado determinado
     param in p_sseguro  : c¿digo del seguro
     param in p_nriesgo  : c¿digo del riesgo
     param in pidioma    : idioma de las preguntas
     return              : texto con pregs. + las respuestas del nriesgo.
   *************************************************************************/
   FUNCTION f_salud_preguntas(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cidioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      CURSOR cur_questsal IS
         SELECT   pp.npreord, pp.cpregun, pr.tpregun
             FROM pregunpro pp, codipregun c, preguntas pr, seguros s
            WHERE pp.sproduc = s.sproduc
              AND s.sseguro = p_sseguro
              AND pp.cpregun = c.cpregun
              AND c.ctipgru = 1
              AND pr.cpregun = pp.cpregun
              AND pr.cidioma = NVL(p_cidioma, 1)
              AND pp.cpregun <> 530
         UNION
         SELECT   pp.npreord, pp.cpregun, pr.tpregun
             FROM pregunpro pp, codipregun c, preguntas pr, estseguros s
            WHERE pp.sproduc = s.sproduc
              AND s.sseguro = p_sseguro
              AND pp.cpregun = c.cpregun
              AND c.ctipgru = 1
              AND pr.cpregun = pp.cpregun
              AND pr.cidioma = NVL(p_cidioma, 1)
              AND pp.cpregun <> 530
         ORDER BY npreord ASC;

      v_result       VARCHAR2(32000);
      v_separador    VARCHAR2(20);
      v_npregnum     NUMBER := 0;
      --      v_fletxa       VARCHAR2(80)
      --                := ' {\field{\*\fldinst SYMBOL 224 \\f "Wingdings" \\s 7}{\fldrslt\f10\fs14}} ';
      v_respuesta    VARCHAR2(32000);
   BEGIN
      FOR reg IN cur_questsal LOOP
         v_npregnum := v_npregnum + 1;

         IF v_npregnum > 1 THEN
            v_separador := RPAD('_', 5, '_') || '\par ';
         END IF;

         BEGIN
            SELECT REPLACE(resposta, CHR(39), CHR(39) || CHR(39))
              INTO v_respuesta
              FROM (SELECT NVL(pr.trespue, NVL(r.trespue, TRUNC(pr.crespue, 2))) resposta
                      FROM pregunseg pr, respuestas r
                     WHERE pr.sseguro = p_sseguro
                       AND pr.nmovimi = f_max_nmovimi(pr.sseguro)
                       AND pr.nriesgo = p_nriesgo
                       AND pr.cpregun = r.cpregun(+)
                       AND pr.cpregun = reg.cpregun
                       AND r.cidioma(+) = NVL(p_cidioma, 1)
                       AND pr.crespue = r.crespue(+)
                    UNION
                    SELECT NVL(pr.trespue, NVL(r.trespue, TRUNC(pr.crespue, 2))) resposta
                      FROM estpregunseg pr, respuestas r
                     WHERE pr.sseguro = p_sseguro
                       AND pr.nmovimi = f_max_nmovimi(pr.sseguro)
                       AND pr.nriesgo = p_nriesgo
                       AND pr.cpregun = r.cpregun(+)
                       AND pr.cpregun = reg.cpregun
                       AND r.cidioma(+) = NVL(p_cidioma, 1)
                       AND pr.crespue = r.crespue(+));
         EXCEPTION
            WHEN OTHERS THEN
               v_respuesta := '---';
         END;

         v_result := v_result || v_separador
                     || REPLACE(reg.tpregun, CHR(39), CHR(39) || CHR(39)) || '   '   --v_fletxa
                     || v_respuesta || '\par ';
      END LOOP;

      RETURN(v_result);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_salud_preguntas;

   -- FINAL BUG 9472 - 23/04/2009 - SBG

   --BUG 8871 - 29/04/2009 - JTS
   /*************************************************************************
     FUNCTION f_capitalamort_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     param in p_campo    : columna
     return              : texto
   *************************************************************************/
   FUNCTION f_capitalamort_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER, p_campo IN NUMBER)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(4000) := '';
      v_tmp          VARCHAR2(100);
      -- Mantis 10373.01/07/2009.NMM.Condicionat Particular.i.
      w_total        NUMBER;
      w_imp_o_zero   NUMBER := 1;
      w_crespue      NUMBER;
      w_idioma       idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma();
      w_fefecto      DATE;
   --
   BEGIN
      SELECT NVL(crespue, 0)
        INTO w_crespue
        FROM pregungaranseg p
       WHERE p.sseguro = p_sseguro
         AND p.nmovimi = p_nmovimi
         AND p.cpregun = 1049
         AND p.cgarant = 2109;

      --w_crespue := NVL(pac_isqlfor.f_respuesta_apr(p_sseguro, p_nmovimi, 1049, w_idioma), 0);
      SELECT s.fefecto
        INTO w_fefecto
        FROM seguros s
       WHERE s.sseguro = p_sseguro;

      FOR reg IN (SELECT   fdesde, fhasta, DECODE(r, 1, total, cap_act) cap_act,
                           DECODE(r, 1, 0, total) total
                      FROM (SELECT   ROWNUM r, fefecto fdesde,
                                     ADD_MONTHS(fefecto, 12) - 1 fhasta,
                                     icappend + icapital cap_act, icapital + iinteres total
                                FROM prestcuadroseg
                               WHERE sseguro = p_sseguro
                                 AND nmovimi = p_nmovimi
                            ORDER BY fefecto, fvencim)
                     WHERE (TO_CHAR(fdesde, 'DDMM') = TO_CHAR(w_fefecto, 'DDMM'))
                  ORDER BY fdesde) LOOP
         IF (MONTHS_BETWEEN(reg.fdesde, w_fefecto) / 12) <= w_crespue
            OR w_crespue = 0 THEN
            w_imp_o_zero := 1;
         ELSE
            w_imp_o_zero := 0;
         END IF;

         --BUG 14837 - 29/06/2010 - ETM -SE QUITA LA MASCARA YA QUE SE LE APLICA MAS ABAJO
         -- w_total := RTRIM(LTRIM(TO_CHAR(reg.total, '9G999G999G990D00')));
         SELECT DECODE
                   (p_campo,
                    1, TO_CHAR(reg.fdesde, 'dd.mm.yyyy'),
                    2, TO_CHAR(reg.fhasta, 'dd.mm.yyyy'),
                    3, TRIM(TO_CHAR(reg.cap_act, '9G999G999G990D00')),
                    4, TRIM(TO_CHAR(DECODE(w_imp_o_zero, 1, reg.total, 0), '9G999G999G990D00')),
                    5, TRIM(TO_CHAR(pac_isqlfor.f_import_garantia(2109, p_sseguro),
                                    '9G999G999G990D00')))   --BUG 14809 - 29/06/2010 - ETM -se llama a la funcion
           INTO v_tmp
           FROM DUAL;

         -- Mantis 10373.f.
         v_cadena := v_cadena || v_tmp || '\par ';
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_capitalamort_apr;

   /*************************************************************************
     FUNCTION f_iprianu_tot
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_iprianu_tot(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          NUMBER(15, 2) := 0;
      v_retv         VARCHAR2(100);
      v_cforpag      NUMBER;
   BEGIN
      SELECT NVL(cforpag, 1)
        INTO v_cforpag
        FROM seguros
       WHERE sseguro = p_sseguro;

      DECLARE
         v_ret_tmp      NUMBER(15, 2) := 0;

         CURSOR c_iprianu IS
            SELECT SUM(iprianu_p / NVL(v_cforpag, 1)) iprianu_p
              FROM (SELECT SUM(g.iprianu) iprianu_p
                      FROM seguros s, garanseg g, pargaranpro gp
                     WHERE s.sseguro = p_sseguro
                       AND g.sseguro = s.sseguro
                       AND g.nmovimi = p_nmovimi
                       AND g.cgarant = gp.cgarant
                       AND s.cramo = gp.cramo
                       AND s.cmodali = gp.cmodali
                       AND s.ctipseg = gp.ctipseg
                       AND s.ccolect = gp.ccolect
                       AND gp.cpargar = 'TIPO'
                       AND gp.cvalpar = 6
                    UNION
                    SELECT SUM(iprianu) iprianu_p
                      FROM garanseg g
                     WHERE g.sseguro = p_sseguro
                       AND g.nmovimi = p_nmovimi
                       AND g.cgarant NOT IN(SELECT gp.cgarant
                                              FROM seguros s, garanseg g, pargaranpro gp
                                             WHERE g.sseguro = s.sseguro
                                               AND g.cgarant = gp.cgarant
                                               AND s.cramo = gp.cramo
                                               AND s.cmodali = gp.cmodali
                                               AND s.ctipseg = gp.ctipseg
                                               AND s.ccolect = gp.ccolect
                                               AND gp.cpargar = 'TIPO'));
      BEGIN
         FOR reg IN c_iprianu LOOP
            v_ret_tmp := v_ret_tmp + reg.iprianu_p;
         END LOOP;

         v_ret := v_ret + NVL(v_ret_tmp, 0);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      --
      DECLARE
         v_ret_tmp      NUMBER(15, 2) := 0;

         CURSOR c_iprianu IS
            SELECT SUM(g.iprianu / NVL(v_cforpag, 1)) iprianu_c
              FROM seguros s, garanseg g, pargaranpro gp
             WHERE s.sseguro = p_sseguro
               AND g.sseguro = s.sseguro
               AND g.nmovimi = p_nmovimi
               AND g.cgarant = gp.cgarant
               AND s.cramo = gp.cramo
               AND s.cmodali = gp.cmodali
               AND s.ctipseg = gp.ctipseg
               AND s.ccolect = gp.ccolect
               AND gp.cpargar = 'TIPO'
               AND gp.cvalpar = 7;
      BEGIN
         FOR reg IN c_iprianu LOOP
            v_ret_tmp := v_ret_tmp + reg.iprianu_c;
         END LOOP;

         v_ret := v_ret + NVL(v_ret_tmp, 0);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      --
      DECLARE
         v_ret_tmp      NUMBER(15, 2) := 0;
         v_tmp          NUMBER(15, 2);
         v_error        NUMBER(8);
         v_crecfra      NUMBER(15);
         v_cforpag      NUMBER(15);
      BEGIN
         SELECT NVL(crecfra, 0), cforpag
           INTO v_crecfra, v_cforpag
           FROM seguros
          WHERE sseguro = p_sseguro;

         FOR reg IN (SELECT cgarant, nriesgo, nmovimi, iprianu, idtocom
                       FROM garanseg
                      WHERE sseguro = p_sseguro
                        AND nmovimi = p_nmovimi) LOOP
            v_error := pac_tarifas.f_calcula_concepto(p_sseguro, reg.nriesgo, reg.nmovimi,
                                                      NULL, 5, v_crecfra, reg.cgarant,
                                                      reg.iprianu / NVL(v_cforpag, 1),
                                                      reg.idtocom, v_tmp);

            IF v_error = 0 THEN
               v_ret_tmp := v_ret_tmp + v_tmp;
            END IF;

            v_tmp := 0;
         END LOOP;

         v_ret := v_ret + NVL(v_ret_tmp, 0);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      --
      DECLARE
         v_ret_tmp      NUMBER(15, 2) := 0;
         v_tmp          NUMBER(15, 2);
         v_error        NUMBER(8);
         v_crecfra      NUMBER(15);
         v_cforpag      NUMBER(15);
      BEGIN
         SELECT NVL(crecfra, 0), cforpag
           INTO v_crecfra, v_cforpag
           FROM seguros
          WHERE sseguro = p_sseguro;

         FOR reg IN (SELECT cgarant, nriesgo, nmovimi, iprianu, idtocom
                       FROM garanseg
                      WHERE sseguro = p_sseguro
                        AND nmovimi = p_nmovimi) LOOP
            v_error := pac_tarifas.f_calcula_concepto(p_sseguro, reg.nriesgo, reg.nmovimi,
                                                      NULL, 8, v_crecfra, reg.cgarant,
                                                      reg.iprianu / NVL(v_cforpag, 1),
                                                      reg.idtocom, v_tmp);

            IF v_error = 0 THEN
               v_ret_tmp := v_ret_tmp + v_tmp;
            END IF;

            v_tmp := 0;
         END LOOP;

         v_ret := v_ret + NVL(v_ret_tmp, 0);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      --
      v_retv := RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))) || ' EUR';
      RETURN v_retv;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_iprianu_tot;

   /*************************************************************************
     FUNCTION f_garantax_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_garantax_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          NUMBER(15, 2) := 0;
      v_retv         VARCHAR2(30);
      v_tmp          NUMBER(15, 2);
      v_error        NUMBER(8);
      v_crecfra      NUMBER(15);
      v_cforpag      NUMBER(15);
   BEGIN
      SELECT NVL(crecfra, 0), cforpag
        INTO v_crecfra, v_cforpag
        FROM seguros
       WHERE sseguro = p_sseguro;

      FOR reg IN (SELECT cgarant, nriesgo, nmovimi,
                         (iprianu / NVL((SELECT cforpag
                                           FROM seguros
                                          WHERE sseguro = p_sseguro), 1)) iprianu, idtocom
                    FROM garanseg
                   WHERE sseguro = p_sseguro
                     AND nmovimi = p_nmovimi) LOOP
         v_error := pac_tarifas.f_calcula_concepto(p_sseguro, reg.nriesgo, reg.nmovimi, NULL,
                                                   8, v_crecfra, reg.cgarant, reg.iprianu,
                                                   reg.idtocom, v_tmp);

         IF v_error = 0 THEN
            v_ret := v_ret + v_tmp;
         END IF;

         v_tmp := 0;
      END LOOP;

      v_retv := RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))) || ' EUR';
      RETURN v_retv;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_garantax_apr;

   /*************************************************************************
     FUNCTION f_garantclea_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_garantclea_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          NUMBER(15, 2) := 0;
      v_retv         VARCHAR2(30);
      v_tmp          NUMBER(15, 2);
      v_error        NUMBER(8);
      v_crecfra      NUMBER(15);
      v_cforpag      NUMBER(15);
   BEGIN
      SELECT NVL(crecfra, 0), cforpag
        INTO v_crecfra, v_cforpag
        FROM seguros
       WHERE sseguro = p_sseguro;

      FOR reg IN (SELECT cgarant, nriesgo, nmovimi,
                         (iprianu / NVL((SELECT cforpag
                                           FROM seguros
                                          WHERE sseguro = p_sseguro), 1)) iprianu, idtocom
                    FROM garanseg
                   WHERE sseguro = p_sseguro
                     AND nmovimi = p_nmovimi) LOOP
         v_error := pac_tarifas.f_calcula_concepto(p_sseguro, reg.nriesgo, reg.nmovimi, NULL,
                                                   5, v_crecfra, reg.cgarant, reg.iprianu,
                                                   reg.idtocom, v_tmp);

         IF v_error = 0 THEN
            v_ret := v_ret + v_tmp;
         END IF;

         v_tmp := 0;
      END LOOP;

      v_retv := RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))) || ' EUR';
      RETURN v_retv;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_garantclea_apr;

   /*************************************************************************
     FUNCTION f_iprianu_comp
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_iprianu_comp(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          NUMBER(15, 2);

      CURSOR c_iprianu IS
         SELECT SUM(g.iprianu / NVL(s.cforpag, 1)) iprianu_c
           FROM seguros s, garanseg g, pargaranpro gp
          WHERE s.sseguro = p_sseguro
            AND g.sseguro = s.sseguro
            AND g.nmovimi = p_nmovimi
            AND g.cgarant = gp.cgarant
            AND s.cramo = gp.cramo
            AND s.cmodali = gp.cmodali
            AND s.ctipseg = gp.ctipseg
            AND s.ccolect = gp.ccolect
            AND gp.cpargar = 'TIPO'
            AND gp.cvalpar = 7;
   BEGIN
      FOR reg IN c_iprianu LOOP
         v_ret := reg.iprianu_c;
      END LOOP;

      IF v_ret > 0
         AND v_ret IS NOT NULL THEN
         RETURN RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))) || ' EUR';
      ELSE
         RETURN f_axis_literales(9001479, f_usu_idioma);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN f_axis_literales(9001479, f_usu_idioma);
   END f_iprianu_comp;

   /*************************************************************************
     FUNCTION f_iprianu_princ
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_iprianu_princ(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          NUMBER(15, 2);

      CURSOR c_iprianu IS
         SELECT SUM(iprianu_p) iprianu_p
           FROM (SELECT SUM(g.iprianu / NVL(s.cforpag, 1)) iprianu_p
                   FROM seguros s, garanseg g, pargaranpro gp
                  WHERE s.sseguro = p_sseguro
                    AND g.sseguro = s.sseguro
                    AND g.nmovimi = p_nmovimi
                    AND g.cgarant = gp.cgarant
                    AND s.cramo = gp.cramo
                    AND s.cmodali = gp.cmodali
                    AND s.ctipseg = gp.ctipseg
                    AND s.ccolect = gp.ccolect
                    AND gp.cpargar = 'TIPO'
                    AND gp.cvalpar = 6
                 UNION
                 SELECT SUM(g.iprianu / NVL((SELECT cforpag
                                               FROM seguros
                                              WHERE sseguro = p_sseguro), 1)) iprianu_p
                   FROM garanseg g
                  WHERE g.sseguro = p_sseguro
                    AND g.nmovimi = p_nmovimi
                    AND g.cgarant NOT IN(SELECT gp.cgarant
                                           FROM seguros s, garanseg g, pargaranpro gp
                                          WHERE g.sseguro = s.sseguro
                                            AND g.cgarant = gp.cgarant
                                            AND s.cramo = gp.cramo
                                            AND s.cmodali = gp.cmodali
                                            AND s.ctipseg = gp.ctipseg
                                            AND s.ccolect = gp.ccolect
                                            AND gp.cpargar = 'TIPO'));
   BEGIN
      FOR reg IN c_iprianu LOOP
         v_ret := reg.iprianu_p;
      END LOOP;

      IF v_ret > 0
         AND v_ret IS NOT NULL THEN
         RETURN RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))) || ' EUR';
      ELSE
         RETURN f_axis_literales(9001479, f_usu_idioma);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN f_axis_literales(9001479, f_usu_idioma);
   END f_iprianu_princ;

   /*************************************************************************
     FUNCTION f_garantcomp_apr
     param in p_sseguro  : c¿digo del seguro
     return              : texto
   *************************************************************************/
   FUNCTION f_garantcomp_apr(p_sseguro IN NUMBER, p_campo IN NUMBER)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(5000) := '';
      v_tmp          VARCHAR2(5000) := '';
   BEGIN
      FOR reg IN (SELECT   ff_desgarantia(g.cgarant, s.cidioma) tgarant,
                           TO_CHAR(g.icaptot) icaptot, TO_CHAR(g.ipritot) ipritot
                      FROM seguros s, garanseg g, pargaranpro gp
                     WHERE s.sseguro = p_sseguro
                       AND g.sseguro = s.sseguro
                       AND g.cgarant = gp.cgarant
                       AND s.cramo = gp.cramo
                       AND s.cmodali = gp.cmodali
                       AND s.ctipseg = gp.ctipseg
                       AND s.ccolect = gp.ccolect
                       AND gp.cpargar = 'TIPO'
                       AND gp.cvalpar = 7
                  ORDER BY 1) LOOP
         SELECT DECODE(p_campo,
                       1, TO_CHAR(reg.tgarant),
                       2, RTRIM(LTRIM(TO_CHAR(reg.icaptot, '9G999G999G990D00'))) || ' EUR',
                       RTRIM(LTRIM(TO_CHAR(reg.ipritot, '9G999G999G990D00'))) || ' EUR')
           INTO v_tmp
           FROM DUAL;

         v_cadena := v_cadena || v_tmp || '\par ';
      END LOOP;

      IF v_cadena IS NOT NULL
         AND p_campo = 1 THEN
         RETURN v_cadena;
      ELSE
         RETURN f_axis_literales(9001479, f_usu_idioma);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN f_axis_literales(9001479, f_usu_idioma);
   END f_garantcomp_apr;

   /*************************************************************************
     FUNCTION f_ipritotdec_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_ipritotdec_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          NUMBER(15, 2);
      -- Mantis 10373.01/07/2009.NMM.Condicionat Particular.i.
      w_cforpag      seguros.cforpag%TYPE;
      w_moneda       NUMBER := pac_md_common.f_get_parinstalacion_n('MONEDAINST');
      w_sproduc      productos.sproduc%TYPE;

      -- Mantis 10373.f.
      CURSOR c_ipritot IS
         SELECT SUM(ipritot) ipritot
           FROM (SELECT SUM(g.ipritot) ipritot
                   FROM seguros ss, garanseg g, pargaranpro gp
                  WHERE ss.sseguro = p_sseguro
                    AND g.nmovimi = p_nmovimi
                    AND g.sseguro = ss.sseguro
                    AND g.cgarant = gp.cgarant
                    AND ss.cramo = gp.cramo
                    AND ss.cmodali = gp.cmodali
                    AND ss.ctipseg = gp.ctipseg
                    AND ss.ccolect = gp.ccolect
                    AND gp.cpargar = 'TIPO'
                    AND gp.cvalpar = 6
                 UNION
                 SELECT SUM(ipritot)
                   FROM seguros ss, garanseg g
                  WHERE ss.sseguro = p_sseguro
                    AND g.nmovimi = p_nmovimi
                    AND g.sseguro = ss.sseguro
                    AND g.cgarant = 2105);
   --Bug.: 0014249 - ICV - 26/05/2010 - No se tiene en cuenta el FORFAIT.
   BEGIN
      -- Mantis 10373.01/07/2009.NMM.Condicionat Particular.i.
      SELECT cforpag, sproduc
        INTO w_cforpag, w_sproduc
        FROM seguros
       WHERE sseguro = p_sseguro;

      -- Mantis 10373.f.
      FOR reg IN c_ipritot LOOP
         v_ret := reg.ipritot;
      END LOOP;

      v_ret := f_round_forpag((v_ret / NVL(w_cforpag, 1)), 1, w_moneda, w_sproduc);

      -- Mantis 10373.01/07/2009.NMM.Condicionat Particular.
      IF v_ret > 0
         AND v_ret IS NOT NULL THEN
         RETURN RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))) || ' EUR';
      ELSE
         RETURN f_axis_literales(9001479, f_usu_idioma);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN f_axis_literales(9001479, f_usu_idioma);
   END f_ipritotdec_apr;

   /*************************************************************************
     FUNCTION f_icaptotdec_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_icaptotdec_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          NUMBER(15, 2);

      /*CURSOR c_icaptot IS
         SELECT SUM(icaptot) icaptot
           FROM (SELECT SUM(g.icaptot) icaptot
                   FROM seguros ss, garanseg g, pargaranpro gp
                  WHERE ss.sseguro = p_sseguro
                    AND g.nmovimi = p_nmovimi
                    AND g.sseguro = ss.sseguro
                    AND g.cgarant = gp.cgarant
                    AND ss.cramo = gp.cramo
                    AND ss.cmodali = gp.cmodali
                    AND ss.ctipseg = gp.ctipseg
                    AND ss.ccolect = gp.ccolect
                    AND gp.cpargar = 'TIPO'
                    AND gp.cvalpar = 6
                 UNION
                 SELECT SUM(icaptot)
                   FROM seguros ss, garanseg g
                  WHERE ss.sseguro = p_sseguro
                    AND g.nmovimi = p_nmovimi
                    AND g.sseguro = ss.sseguro
                    AND g.cgarant = 2105);*/

      /* INII --bug 16459--ETM--28/10/2010*/
      CURSOR c_icaptot IS
         SELECT SUM(icaptot) icaptot
           FROM (SELECT SUM(d.icapital) icaptot
                   FROM seguros ss, garanseg g, pargaranpro gp, detgaranseg d
                  WHERE ss.sseguro = p_sseguro
                    AND g.nmovimi = p_nmovimi
                    AND g.sseguro = ss.sseguro
                    AND g.sseguro = d.sseguro
                    AND d.nriesgo = g.nriesgo
                    AND d.cgarant = g.cgarant
                    AND d.nmovimi = g.nmovimi
                    AND d.finiefe = g.finiefe
                    AND g.cgarant = gp.cgarant
                    AND ss.cramo = gp.cramo
                    AND ss.cmodali = gp.cmodali
                    AND ss.ctipseg = gp.ctipseg
                    AND ss.ccolect = gp.ccolect
                    AND gp.cpargar = 'TIPO'
                    AND gp.cvalpar = 6
                 UNION
                 SELECT SUM(dd.icapital)
                   FROM seguros ss, garanseg g, detgaranseg dd
                  WHERE ss.sseguro = p_sseguro
                    AND g.nmovimi = p_nmovimi
                    AND g.sseguro = ss.sseguro
                    AND g.cgarant = 2105
                    AND g.sseguro = dd.sseguro
                    AND dd.nriesgo = g.nriesgo
                    AND dd.cgarant = g.cgarant
                    AND dd.nmovimi = g.nmovimi
                    AND dd.finiefe = g.finiefe);
   /* FIN--bug 16459--ETM--28/10/2010*/
   BEGIN
      FOR reg IN c_icaptot LOOP
         v_ret := reg.icaptot;
      END LOOP;

      IF v_ret > 0
         AND v_ret IS NOT NULL THEN
         RETURN RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))) || ' EUR';
      ELSE
         RETURN f_axis_literales(9001479, f_usu_idioma);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN f_axis_literales(9001479, f_usu_idioma);
   END f_icaptotdec_apr;

   /*************************************************************************
     FUNCTION f_ipritotvid_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_ipritotvid_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          NUMBER(15, 2);
      -- Mantis 10373.01/07/2009.NMM.Condicionat Particular.i.
      w_cforpag      seguros.cforpag%TYPE;
      w_moneda       NUMBER := pac_md_common.f_get_parinstalacion_n('MONEDAINST');
      w_sproduc      productos.sproduc%TYPE;

      -- Mantis 10373.f.
      CURSOR c_ipritot IS
         SELECT SUM(g.ipritot) ipritot
           FROM garanseg g
          WHERE g.sseguro = p_sseguro
            AND g.nmovimi = p_nmovimi
            AND g.cgarant NOT IN(2116, 2105)
            --Bug.: 0014249 - ICV - 26/05/2010 - No se tiene en cuenta el FORFAIT.
            AND g.cgarant NOT IN(SELECT gp.cgarant
                                   FROM seguros ss, garanseg gg, pargaranpro gp
                                  WHERE ss.sseguro = p_sseguro
                                    AND gg.nmovimi = p_nmovimi
                                    AND gg.sseguro = ss.sseguro
                                    AND gg.cgarant = gp.cgarant
                                    AND ss.cramo = gp.cramo
                                    AND ss.cmodali = gp.cmodali
                                    AND ss.ctipseg = gp.ctipseg
                                    AND ss.ccolect = gp.ccolect
                                    AND gp.cpargar = 'TIPO');
   BEGIN
      -- Mantis 10373.01/07/2009.NMM.Condicionat Particular.i.
      SELECT cforpag, sproduc
        INTO w_cforpag, w_sproduc
        FROM seguros
       WHERE sseguro = p_sseguro;

      -- Mantis 10373.f.
      FOR reg IN c_ipritot LOOP
         v_ret := reg.ipritot;
      END LOOP;

      v_ret := f_round_forpag((v_ret / NVL(w_cforpag, 1)), 1, w_moneda, w_sproduc);

      -- Mantis 10373.01/07/2009.NMM.Condicionat Particular.
      IF v_ret > 0
         AND v_ret IS NOT NULL THEN
         RETURN RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))) || ' EUR';
      ELSE
         RETURN f_axis_literales(9001479, f_usu_idioma);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN f_axis_literales(9001479, f_usu_idioma);
   END f_ipritotvid_apr;

   /*************************************************************************
     FUNCTION f_icaptotvid_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_icaptotvid_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          NUMBER(15, 2);

      CURSOR c_icaptot IS
         SELECT /* bug 16459--ETM--28/10/2010--SUM(g.icaptot) icaptot,*/ SUM
                                                                           (d.icapital)
                                                                                      icaptot
           FROM garanseg g, detgaranseg d
          WHERE g.sseguro = p_sseguro
            AND g.sseguro = d.sseguro
            AND d.nriesgo = g.nriesgo
            AND d.cgarant = g.cgarant
            AND d.nmovimi = g.nmovimi
            AND d.finiefe = g.finiefe
            AND g.cgarant NOT IN(2116, 2105)
            --Bug.: 0014249 - ICV - 26/05/2010 - No se tiene en cuenta el FORFAIT.
            AND g.nmovimi = p_nmovimi
            AND g.cgarant NOT IN(SELECT gp.cgarant
                                   FROM seguros ss, garanseg gg, pargaranpro gp
                                  WHERE ss.sseguro = p_sseguro
                                    AND gg.nmovimi = p_nmovimi
                                    AND gg.sseguro = ss.sseguro
                                    AND gg.cgarant = gp.cgarant
                                    AND ss.cramo = gp.cramo
                                    AND ss.cmodali = gp.cmodali
                                    AND ss.ctipseg = gp.ctipseg
                                    AND ss.ccolect = gp.ccolect
                                    AND gp.cpargar = 'TIPO');
   BEGIN
      FOR reg IN c_icaptot LOOP
         v_ret := reg.icaptot;
      END LOOP;

      IF v_ret > 0
         AND v_ret IS NOT NULL THEN
         RETURN RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))) || ' EUR';
      ELSE
         RETURN f_axis_literales(9001479, f_usu_idioma);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN f_axis_literales(9001479, f_usu_idioma);
   END f_icaptotvid_apr;

   /*************************************************************************
     FUNCTION f_titgarantias_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_cidioma  : c¿digo de idioma
     param in p_nriesgo  : riesgo
     return              : texto
   *************************************************************************/
   FUNCTION f_titgarantias_apr(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(1000) := '';
      v_retval       NUMBER;
      v_valpar       NUMBER;
   BEGIN
      -- Bug 9685 - APD - 01/07/2009 - en lugar de coger la actividad de la tabla seguros,
      -- llamar a la funci¿n pac_seguros.ff_get_actividad
      FOR reg IN (SELECT   REPLACE(gg.tgarant, CHR(39), CHR(39) || CHR(39)) "TGARANT",
                           s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                           pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo) cactivi,
                           g.cgarant
                      FROM garangen gg, garanseg g, seguros s
                     WHERE gg.cgarant = g.cgarant
                       AND g.sseguro = s.sseguro
                       AND s.sseguro = p_sseguro
                       AND g.ffinefe IS NULL
                       AND gg.cidioma = p_cidioma
                       AND g.nriesgo = NVL(p_nriesgo, 1)
                       AND g.cgarant != 2116
                       AND g.cgarant != 48   --BUG 10373 - JTS - 26/06/2009
                  ORDER BY g.cgarant ASC) LOOP
         v_retval := f_pargaranpro(reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                   reg.cactivi, reg.cgarant, 'VISIBLEDOCUM', v_valpar);

         -- Bug 9685 - APD - 01/07/2009 - fin
         IF NVL(v_valpar, 1) = 1 THEN
            v_cadena := v_cadena || '(' || reg.cgarant || ') ' || reg.tgarant || '\par ';
         END IF;
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_titgarantias_apr;

   /*************************************************************************
     FUNCTION f_respuesta_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     param in p_cpregun  : c¿digo de la pregunta
     return              : texto
   *************************************************************************/
   FUNCTION f_respuesta_apr(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cpregun IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          VARCHAR2(250);
   BEGIN
      BEGIN
         SELECT NVL(trespue, crespue)
           INTO v_ret
           FROM pregungaranseg p
          WHERE p.sseguro = p_sseguro
            AND p.nmovimi = p_nmovimi
            AND p.cpregun = p_cpregun;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT NVL(trespue,
                       (SELECT r.trespue
                          FROM respuestas r
                         WHERE r.crespue = p.crespue
                           AND r.cpregun = p.cpregun
                           AND r.cidioma = p_cidioma))
              INTO v_ret
              FROM pregunseg p
             WHERE p.sseguro = p_sseguro
               AND p.nmovimi = p_nmovimi
               AND p.cpregun = p_cpregun;
      END;

      -- BUG10134:08/06/2009:DRA:Inici
      v_ret := REPLACE(v_ret, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_respuesta_apr;

   /*************************************************************************
     FUNCTION f_clausulas_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     param in p_cidioma  : idioma
     return              : texto
   *************************************************************************/
   FUNCTION f_clausulas_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          VARCHAR2(250);
   BEGIN
      FOR reg IN (SELECT   cg.sclagen, cg.tclatex
                      FROM claususeg cs, clausugen cg
                     WHERE cs.sclagen = cg.sclagen
                       AND cs.nmovimi = p_nmovimi
                       AND cs.sseguro = p_sseguro
                       AND cg.cidioma = p_cidioma
                  ORDER BY cg.sclagen) LOOP
         v_ret := v_ret || reg.sclagen || ' ' || reg.tclatex || '\par ';
      END LOOP;

      IF v_ret IS NULL THEN
         v_ret := f_axis_literales(9001479, f_usu_idioma);
      END IF;

      -- BUG10134:08/06/2009:DRA:Inici
      v_ret := REPLACE(v_ret, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN f_axis_literales(9001479, f_usu_idioma);
   END f_clausulas_apr;

   /*************************************************************************
     FUNCTION f_ndurcob_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_ndurcob_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          VARCHAR2(250);
      v_ndurcob      NUMBER;
      v_ndurcob_seg  NUMBER;
      v_fefecto      DATE;
      v_fvencim      DATE;
   BEGIN
      BEGIN
         SELECT ndurcob, fefecto, fvencim
           INTO v_ndurcob_seg, v_fefecto, v_fvencim
           FROM seguros
          WHERE sseguro = p_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;

      BEGIN
         SELECT MAX(ndurcob)
           INTO v_ndurcob
           FROM detgaranseg
          WHERE sseguro = p_sseguro
            AND nmovimi = p_nmovimi;
      EXCEPTION
         WHEN OTHERS THEN
            v_ndurcob := NULL;
      END;

      IF v_ndurcob IS NOT NULL THEN
         v_ret := TO_CHAR(ADD_MONTHS(v_fefecto, v_ndurcob * 12), 'DD.MM.YYYY');
      ELSIF v_ndurcob_seg IS NOT NULL THEN
         v_ret := TO_CHAR(ADD_MONTHS(v_fefecto, v_ndurcob_seg * 12), 'DD.MM.YYYY');
      ELSE
         v_ret := TO_CHAR(v_fvencim, 'DD.MM.YYYY');
      END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_ndurcob_apr;

   --FINAL BUG 8871 - 29/04/2009 - JTS

   --BUG 10233 - 03/06/2009 - JTS
   /*************************************************************************
     FUNCTION f_camposrecibosimp_apr
     param in p_sseguro  : c¿digo del seguro
     param in p_campo    : campo
     return              : texto
   *************************************************************************/
   FUNCTION f_camposrecibosimp_apr(p_sseguro IN NUMBER, p_campo IN NUMBER)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(4000) := '';
      v_tmp          VARCHAR2(250);
   BEGIN
      FOR reg IN (SELECT DISTINCT seg.npoliza,
                                  pac_isqlfor.f_plan(seg.sseguro, seg.cidioma) prod,
                                  imp.nrecibo nrecibo,
                                  TO_CHAR(rec.fefecto, 'dd.mm.yyyy') || ' - '
                                  || TO_CHAR(rec.fvencim, 'dd.mm.yyyy') period,
                                  pac_gestion_rec.f_importe_recibo(rec.nrecibo) importe
                             FROM tmp_impagados imp, tomadores tom, per_personas per,
                                  seguros seg, recibos rec
                            WHERE imp.sseguro = p_sseguro
                              AND imp.sseguro = tom.sseguro
                              AND tom.nordtom = 1
                              AND per.sperson = tom.sperson
                              AND seg.sseguro = imp.sseguro
                              AND rec.nrecibo = imp.nrecibo
                         ORDER BY nrecibo) LOOP
         SELECT DECODE(p_campo,
                       1, TO_CHAR(reg.npoliza),
                       2, TO_CHAR(reg.prod),
                       3, TO_CHAR(reg.nrecibo),
                       4, TO_CHAR(reg.period),
                       TO_CHAR(RTRIM(LTRIM(TO_CHAR(reg.importe, '9G999G999G990D00')))))
           INTO v_tmp
           FROM DUAL;

         v_cadena := v_cadena || v_tmp || '\par ';
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_camposrecibosimp_apr;

   /*************************************************************************
     FUNCTION f_totalesrecibosimp
     param in p_sseguro   : c¿digo de la carta
     param in p_fefecto   : c¿digo de la carta
     param in p_campo     : campo
     return               : texto
   *************************************************************************/
   FUNCTION f_totalesrecibosimp(p_sseguro IN NUMBER, p_fefecto IN DATE, p_campo IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          VARCHAR2(250);
   BEGIN
      IF p_campo = 1 THEN   --TOTAL REBUTS
         SELECT NVL(SUM(pac_gestion_rec.f_importe_recibo(imp.nrecibo)), 0)
           INTO v_ret
           FROM (SELECT DISTINCT nrecibo
                            FROM tmp_impagados
                           WHERE sseguro = p_sseguro) imp;
      ELSIF p_campo = 2 THEN   --TOTAL REBUTS VENCUTS
         SELECT NVL(SUM(pac_gestion_rec.f_importe_recibo(r.nrecibo)), 0)
           INTO v_ret
           FROM recibos r,
                (SELECT DISTINCT nrecibo
                            FROM tmp_impagados
                           WHERE sseguro = p_sseguro) imp
          WHERE r.nrecibo = imp.nrecibo
            AND r.fvencim >= p_fefecto;
      ELSIF p_campo = 3 THEN   --TOTAL REBUTS NO VENCUTS
         SELECT NVL(SUM(pac_gestion_rec.f_importe_recibo(r.nrecibo)), 0)
           INTO v_ret
           FROM recibos r,
                (SELECT DISTINCT nrecibo
                            FROM tmp_impagados
                           WHERE sseguro = p_sseguro) imp
          WHERE r.nrecibo = imp.nrecibo
            AND r.fvencim < p_fefecto;
      END IF;

      RETURN TO_CHAR(RTRIM(LTRIM(TO_CHAR(v_ret, '9G999G999G990D00'))));
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_totalesrecibosimp;

   --Fi BUG 10233 - 03/06/2009 - JTS

   -- Bug 10199 - APD - 26/05/2009 - se crea la funcion f_anulacion
   /*************************************************************************
     FUNCTION f_fanulacion
     Funci¿n que devuelve la fecha de anulacion de una poliza una vez ¿sta ha
     sido anulada o programada para la anulacion
     param in p_sseguro  : c¿digo del seguro
     return              : date
   *************************************************************************/
   FUNCTION f_fanulacion(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_cmotmov      NUMBER;
      v_fanulac      DATE;
   BEGIN
      --Ini Bug.: 12756 - ICV - 19/01/2010 - Se a¿ade el motivo 324 Baja inmediata, para que vaya por el else y devuelva la fanulac.
      BEGIN
         SELECT cmotmov
           INTO v_cmotmov
           FROM movseguro
          WHERE sseguro = p_sseguro
            AND cmotmov IN(306, 236, 221, 324)
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM movseguro
                            WHERE sseguro = p_sseguro
                              AND cmotmov IN(306, 236, 221, 324));
      -- 306 : Anulaci¿n sin efecto
      -- 236 : Anulaci¿n programada al pr¿ximo recibo
      -- 221 : Anulaci¿n programada al vencimiento
      -- 324 : Baja inmediata
      --Fin Bug.: 12756 - ICV
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;

      IF v_cmotmov IN(236, 221) THEN
         BEGIN
            SELECT fvencim
              INTO v_fanulac
              FROM seguros
             WHERE sseguro = p_sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      ELSE
         BEGIN
            SELECT fanulac
              INTO v_fanulac
              FROM seguros
             WHERE sseguro = p_sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      END IF;

      RETURN TO_CHAR(v_fanulac, 'DD/MM/YYYY');
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_fanulacion;

   -- Bug 10199 - APD - 26/05/2009 - se crea la funcion f_importerescateparcial
   -- Bug 11993 - RSC - 19/11/2009  - CRE - Ajustes PPJ Din¿mico/Pla Estudiant
   /*************************************************************************
     FUNCTION f_importerescateparcial
     Funci¿n que devuelve el importe del rescate
     param in p_nsinies  : c¿digo del siniestro
     return              : number
   *************************************************************************/
   FUNCTION f_importerescateparcial(p_nsinies IN NUMBER)
      RETURN NUMBER IS
      v_ivalora      NUMBER;
   BEGIN
      -- BUG 11595 - 02/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros
      -- Para este caso, en vez de buscar por el parempresa 'MODULO_SINI' para saber si se
      -- est¿ en el m¿dulo antiguo o nuevo de siniestros (ya que se necesita la empresa del
      -- seguro para buscar el valor del parempresa) se parte de que por defecto se est¿
      -- en el modelo nuevo, y si no hay datos se busca en el modelo antiguo.
      BEGIN
         SELECT ipago
           INTO v_ivalora
           FROM sin_tramita_reserva v, sin_tramitacion t, sin_siniestro si, seguros s
          WHERE s.sseguro = si.sseguro
            AND si.nsinies = t.nsinies
            AND t.nsinies = v.nsinies
            AND t.ntramit = v.ntramit
            AND v.nsinies = p_nsinies
            AND v.ctipres = 1   -- jlb - 18423#c105054
            AND v.nmovres = (SELECT MAX(v1.nmovres)
                               FROM sin_tramita_reserva v1
                              WHERE v1.nsinies = v.nsinies
                                AND v1.ctipres = v.ctipres)
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                pac_seguros.ff_get_actividad(s.sseguro, si.nriesgo), v.cgarant,
                                'TIPO') IN(3, 5);
      -- 283 = Capital Garantizado al vencimiento
      -- Bug 11993 - RSC - 19/11/2009: Se incluye TIPO = 3
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT ivalora
              INTO v_ivalora
              FROM valorasini v, siniestros si, seguros s
             WHERE s.sseguro = si.sseguro
               AND si.nsinies = v.nsinies
               AND v.nsinies = p_nsinies
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                   pac_seguros.ff_get_actividad(s.sseguro, si.nriesgo),
                                   v.cgarant, 'TIPO') IN(3, 5);
      -- 283 = Capital Garantizado al vencimiento
      -- Bug 11993 - RSC - 19/11/2009: Se incluye TIPO = 3
      END;

      -- Fin BUG 11595 - 02/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros
      RETURN v_ivalora;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_importerescateparcial;

   /*************************************************************************
     FUNCTION f_tituloSaldoDeutor
     Funci¿n que devuelve la cabecera del saldo deutores
     param in p_sproduc  : c¿digo del producto
     param in p_column   : indica que columna devuelve
     param in p_sseguro  : c¿digo del seguro
     param in p_idioma   : idioma
     return              : texto de la cabecera

     Bug 10857 - 31/07/2009 - AMC
   *************************************************************************/
   -- Bug 11165 - 16/09/2009 - AMC - Se sustitu¿e  detsaldodeutorseg por prestamoseg
   FUNCTION f_capitales_ase(
      p_sproduc IN NUMBER,
      p_colum IN NUMBER,
      p_sseguro IN NUMBER,
      p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      vtexto         VARCHAR2(1000);
      valor          VARCHAR2(100);
      num_err        NUMBER;
   BEGIN
      IF f_parproductos_v(p_sproduc, 'ES_PRODUCTO_SALDODE') = 1 THEN
         IF p_colum = 1 THEN
            FOR cur IN (SELECT ctapres
                          FROM prestamoseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = p_sseguro)) LOOP
               vtexto := vtexto || cur.ctapres || ' \par ';
            END LOOP;
         ELSIF p_colum = 2 THEN
            FOR cur IN (SELECT ctipcuenta
                          FROM prestamoseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = p_sseguro)) LOOP
               num_err := f_desvalorfijo(401, p_idioma, cur.ctipcuenta, valor);
               vtexto := vtexto || valor || ' \par ';
            END LOOP;
         ELSIF p_colum = 3 THEN
            FOR cur IN (SELECT TO_CHAR(NVL(icapaseg, 0), 'FM999G999G999G990D00') icapaseg
                          FROM prestamoseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = p_sseguro)) LOOP
               vtexto := vtexto || cur.icapaseg || ' \par ';
            END LOOP;
         ELSIF p_colum = 4 THEN
            FOR cur IN (SELECT TO_CHAR(NVL(isaldo, 0), 'FM999G999G999G990D00') isaldo
                          FROM prestamoseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = p_sseguro)) LOOP
               vtexto := vtexto || cur.isaldo || ' \par ';
            END LOOP;
         ELSIF p_colum = 5 THEN
            FOR cur IN (SELECT ctipimp
                          FROM prestamoseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = p_sseguro)) LOOP
               num_err := f_desvalorfijo(402, p_idioma, cur.ctipimp, valor);
               vtexto := vtexto || valor || ' \par ';
            END LOOP;
         ELSIF p_colum = 6 THEN
            FOR cur IN (SELECT TO_CHAR(NVL(icapmax, 0), 'FM999G999G999G990D00') icapmax
                          FROM prestamoseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = p_sseguro)) LOOP
               vtexto := vtexto || cur.icapmax || ' \par ';
            END LOOP;
         ELSIF p_colum = 7 THEN
            FOR cur IN (SELECT cmoneda
                          FROM prestamoseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = p_sseguro)) LOOP
               vtexto := vtexto || cur.cmoneda || ' \par ';
            END LOOP;
         ELSIF p_colum = 8 THEN
            FOR cur IN (SELECT TO_CHAR(NVL(porcen, 0), 'FM990D00') porcen
                          FROM prestamoseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = p_sseguro)) LOOP
               vtexto := vtexto || cur.porcen || ' \par ';
            END LOOP;
         ELSIF p_colum = 9 THEN
            FOR cur IN (SELECT TO_CHAR(NVL(ilimite, 0), 'FM999G999G999G990D00') ilimite
                          FROM prestamoseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = p_sseguro)) LOOP
               vtexto := vtexto || cur.ilimite || ' \par ';
            END LOOP;
         END IF;
      END IF;

      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_capitales_ase;

   /*************************************************************************
     FUNCTION f_sum_calculoconcepto
     param in psseguro  : c¿digo del seguro
     param in pnriesgo  : numero de riesgo
     param in pnmovimi  : n¿mero de movimiento
     param in pmodo     : modo EST\POL
     param in pconcep   : concepto
     return             : cantidad

     Bug 10365 - 01/09/2009 - JTS
   *************************************************************************/
   FUNCTION f_sum_calculoconcepto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmodo IN VARCHAR2,
      pconcep IN NUMBER)
      RETURN NUMBER IS
      v_temp         NUMBER;
      v_total        NUMBER := 0;
      v_numer        NUMBER;
      v_crecfra      seguros.crecfra%TYPE;

      CURSOR v_curgar IS
         SELECT cgarant, iprianu
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;

      CURSOR v_curestgar IS
         SELECT cgarant, iprianu
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;
   BEGIN
      IF pmodo = 'EST' THEN
         FOR gar IN v_curestgar LOOP
            --Ini Bug.: 0013622 - ICV - 15/04/2010
            SELECT crecfra
              INTO v_crecfra
              FROM estseguros es
             WHERE es.sseguro = psseguro;

            v_numer := pac_tarifas.f_calcula_concepto(psseguro, pnriesgo, pnmovimi, pmodo,
                                                      pconcep, v_crecfra, gar.cgarant,
                                                      gar.iprianu, 0, v_temp);
            v_total := v_total + v_temp;
         END LOOP;
      ELSE
         FOR gar IN v_curgar LOOP
            SELECT crecfra
              INTO v_crecfra
              FROM seguros s
             WHERE s.sseguro = psseguro;

            v_numer := pac_tarifas.f_calcula_concepto(psseguro, pnriesgo, pnmovimi, pmodo,
                                                      pconcep, v_crecfra, gar.cgarant,
                                                      gar.iprianu, 0, v_temp);
            v_total := v_total + v_temp;
         --Fin Bug.: 0013622 - ICV - 15/04/2010
         END LOOP;
      END IF;

      RETURN v_total;
   END f_sum_calculoconcepto;

   /*************************************************************************
      FUNCTION f_opciondinamica
      param in psseguro  : c¿digo del seguro
      param in pcidioma  : codigo del idioma
      return             : opci¿n

      Bug 11097 - 10/09/2009 - AMC
    *************************************************************************/
   FUNCTION f_opciondinamica(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vtrespue       VARCHAR2(2000);
   BEGIN
      SELECT r.trespue
        INTO vtrespue
        FROM (SELECT pr.crespue
                FROM pregunseg pr
               WHERE pr.sseguro = psseguro
                 AND pr.nmovimi = (SELECT MAX(nmovimi)
                                     FROM pregunseg p2
                                    WHERE p2.sseguro = pr.sseguro
                                      AND p2.cpregun = pr.cpregun
                                      AND p2.nriesgo = pr.nriesgo)
                 AND pr.nriesgo = 1
                 AND pr.cpregun = 560
              UNION
              SELECT pr.crespue
                FROM estpregunseg pr
               WHERE pr.sseguro = psseguro
                 AND pr.nmovimi = (SELECT MAX(nmovimi)
                                     FROM estpregunseg p2
                                    WHERE p2.sseguro = pr.sseguro
                                      AND p2.cpregun = pr.cpregun
                                      AND p2.nriesgo = pr.nriesgo)
                 AND pr.nriesgo = 1
                 AND pr.cpregun = 560) x,
             respuestas r
       WHERE r.cpregun = 560
         AND r.crespue = x.crespue
         AND r.cidioma = pcidioma;

      RETURN vtrespue;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_opciondinamica;

   /*************************************************************************
     FUNCTION f_perfil_inversion
     param in psseguro  : c¿digo del seguro
     param in pcidioma  : codigo del idioma
     return             : perfil de inversi¿n

     Bug 11097 - 10/09/2009 - AMC
   *************************************************************************/
   FUNCTION f_perfil_inversion(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')   -- 12301.21/12/2009.NMM
      RETURN VARCHAR2 IS
      w_tmodinv      VARCHAR2(50);
      w_cramo        productos.cramo%TYPE;
      w_cmodali      productos.cmodali%TYPE;
      w_ctipseg      productos.ctipseg%TYPE;
      w_ccolect      productos.ccolect%TYPE;
   BEGIN
      IF p_mode = 'POL' THEN
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT c.tmodinv
           INTO w_tmodinv
           FROM seguros_ulk s, codimodelosinversion c
          WHERE s.sseguro = psseguro
            AND s.cmodinv = c.cmodinv
            AND c.cidioma = pcidioma
            AND c.cramo = w_cramo
            AND c.cmodali = w_cmodali
            AND c.ctipseg = w_ctipseg
            AND c.ccolect = w_ccolect;
      ELSE
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect
           FROM estseguros
          WHERE sseguro = psseguro;

         SELECT c.tmodinv
           INTO w_tmodinv
           FROM estseguros_ulk s, codimodelosinversion c
          WHERE s.sseguro = psseguro
            AND s.cmodinv = c.cmodinv
            AND c.cidioma = pcidioma
            AND c.cramo = w_cramo
            AND c.cmodali = w_cmodali
            AND c.ctipseg = w_ctipseg
            AND c.ccolect = w_ccolect;
      END IF;

      RETURN(w_tmodinv);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_perfil_inversion;

   /*************************************************************************
     FUNCTION f_detperfil_inversion
     param in psseguro  : c¿digo del seguro
     return             : detalle perfil de inversi¿n

     Bug 11097 - 10/09/2009 - AMC
   *************************************************************************/
   FUNCTION f_detperfil_inversion(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      vtexto         VARCHAR2(2000);
   BEGIN
      FOR cur IN (SELECT tfonabv, pdistrec
                    FROM (SELECT f.tfonabv, s.pdistrec
                            FROM segdisin2 s, fondos f
                           WHERE s.sseguro = psseguro
                             AND s.nmovimi = (SELECT MAX(nmovimi)
                                                FROM segdisin2 p2
                                               WHERE p2.sseguro = s.sseguro)
                             AND s.ccesta = f.ccodfon
                          UNION
                          SELECT f.tfonabv, s.pdistrec
                            FROM estsegdisin2 s, fondos f
                           WHERE s.sseguro = psseguro
                             AND s.nmovimi = (SELECT MAX(nmovimi)
                                                FROM estsegdisin2 p2
                                               WHERE p2.sseguro = s.sseguro)
                             AND s.ccesta = f.ccodfon)) LOOP
         IF vtexto IS NULL THEN
            vtexto := cur.tfonabv || '-' || cur.pdistrec || '%';
         ELSE
            vtexto := vtexto || ',' || cur.tfonabv || '-' || cur.pdistrec || '%';
         END IF;
      END LOOP;

      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_detperfil_inversion;

   /*************************************************************************
     FUNCTION f_datosestudiante
     param in psseguro  : c¿digo del seguro
     return             : datos estudiante

     Bug 11097 - 14/09/2009 - AMC
   *************************************************************************/
   FUNCTION f_datosestudiante(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      vtrespue       VARCHAR2(2000);
   BEGIN
      SELECT trespue
        INTO vtrespue
        FROM (SELECT pr.trespue
                FROM pregunpolseg pr
               WHERE pr.sseguro = psseguro
                 AND pr.nmovimi = (SELECT MAX(nmovimi)
                                     FROM pregunpolseg p2
                                    WHERE p2.sseguro = pr.sseguro
                                      AND p2.cpregun = pr.cpregun)
                 AND pr.cpregun = 579
              UNION
              SELECT pr.trespue
                FROM estpregunpolseg pr
               WHERE pr.sseguro = psseguro
                 AND pr.nmovimi = (SELECT MAX(nmovimi)
                                     FROM estpregunpolseg p2
                                    WHERE p2.sseguro = pr.sseguro
                                      AND p2.cpregun = pr.cpregun)
                 AND pr.cpregun = 579);

      RETURN vtrespue;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_datosestudiante;

   /*************************************************************************
     FUNCTION f_fnacimiento
     param in psseguro  : c¿digo del seguro
     return             : fecha nacimiento del estudiante

     Bug 11097 - 14/09/2009 - AMC
   *************************************************************************/
   FUNCTION f_fnacimiento(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      vtrespue       VARCHAR2(2000);
   BEGIN
      SELECT trespue
        INTO vtrespue
        FROM (SELECT pr.trespue
                FROM pregunpolseg pr
               WHERE pr.sseguro = psseguro
                 AND pr.nmovimi = (SELECT MAX(nmovimi)
                                     FROM pregunpolseg p2
                                    WHERE p2.sseguro = pr.sseguro
                                      AND p2.cpregun = pr.cpregun)
                 AND pr.cpregun = 576
              UNION
              SELECT pr.trespue
                FROM estpregunpolseg pr
               WHERE pr.sseguro = psseguro
                 AND pr.nmovimi = (SELECT MAX(nmovimi)
                                     FROM estpregunpolseg p2
                                    WHERE p2.sseguro = pr.sseguro
                                      AND p2.cpregun = pr.cpregun)
                 AND pr.cpregun = 576);

      RETURN vtrespue;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_fnacimiento;

 /*************************************************************************
  FUNCTION f_respuesta_nacionalidad
  param in p_sseguro  : c¿digo del seguro
  param in p_nmovimi  : c¿digo del movimiento
  param in p_cpregun  : c¿digo de la pregunta
  return              : texto
*************************************************************************/
/*
FUNCTION f_respuesta_nacionalidad(
   p_sseguro IN NUMBER,
   p_nmovimi IN NUMBER,
   p_cpregun IN NUMBER)
   RETURN VARCHAR2 IS
   v_ret          VARCHAR2(250);
BEGIN
   SELECT p.trespue
     INTO v_ret
     FROM pregunpolseg p
    WHERE p.sseguro = p_sseguro
      AND p.cpregun = p_cpregun
      AND p.nmovimi = (SELECT MAX(m.nmovimi)
                         FROM movseguro m
                        WHERE m.sseguro = p.sseguro);

   RETURN v_ret;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END f_respuesta_nacionalidad;
*/
--------------------------------------------------------------------------------
   FUNCTION f_garant_addicional(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_idioma IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      w_tgarant      garangen.tgarant%TYPE;
      w_idioma       garangen.cidioma%TYPE;
      w_nriesgo      riesgos.nriesgo%TYPE;
      w_nmovimi      movseguro.nmovimi%TYPE;
   --
   -- En cas que es busqui en les taules definitives i no es trobi informaci¿,
   -- cercarem en les EST ( cas de simulacions).
   --
   BEGIN
      IF p_mode = 'POL' THEN
         SELECT gg.tgarant
           INTO w_tgarant
           FROM garanseg gs, garangen gg
          WHERE gs.sseguro = p_sseguro
            AND gs.nriesgo = NVL(p_nriesgo, 1)
            AND((p_nmovimi IS NULL
                 AND gs.ffinefe IS NULL)
                OR gs.nmovimi = NVL(p_nmovimi, -1))
            AND gs.cgarant = p_cgarant
            AND gs.cgarant = gg.cgarant
            AND gg.cidioma = NVL(p_idioma, pac_md_common.f_get_cxtidioma);
      ELSE
         SELECT gg.tgarant
           INTO w_tgarant
           FROM estgaranseg gs, garangen gg
          WHERE gs.sseguro = p_sseguro
            AND gs.nriesgo = NVL(p_nriesgo, 1)
            AND((p_nmovimi IS NULL
                 AND gs.ffinefe IS NULL)
                OR gs.nmovimi = NVL(p_nmovimi, -1))
            AND gs.cgarant = p_cgarant
            AND gs.cobliga = 1
            AND gs.cgarant = gg.cgarant
            AND gg.cidioma = NVL(p_idioma, pac_md_common.f_get_cxtidioma);
      END IF;

      RETURN(w_tgarant);
   --
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('NO CONTRACTADA');
   END f_garant_addicional;

   /*************************************************************************
     FUNCTION F_CAPITAL_GARANT_AD
     param in psseguro  : codi asseguran¿a
     return             : capital garantia addicional

     Bug 11654 - 03/11/2009 - NMM.
   *************************************************************************/
   FUNCTION f_capital_garant_ad(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      w_icapital     NUMBER;
      w_idioma       garangen.cidioma%TYPE;
      w_nriesgo      riesgos.nriesgo%TYPE;
      w_nmovimi      movseguro.nmovimi%TYPE;
   --
   -- En cas que es busqui en les taules definitives i no es trobi informaci¿,
   -- cercarem en les EST ( cas de simulacions).
   --
   BEGIN
      IF p_mode = 'POL' THEN
         SELECT gs.icapital
           INTO w_icapital
           FROM garanseg gs
          WHERE gs.sseguro = p_sseguro
            AND gs.nriesgo = NVL(p_nriesgo, 1)
            AND((p_nmovimi IS NULL
                 AND gs.ffinefe IS NULL)
                OR gs.nmovimi = NVL(p_nmovimi, -1))
            AND gs.cgarant = p_cgarant;
      ELSE
         SELECT gs.icapital
           INTO w_icapital
           FROM estgaranseg gs
          WHERE gs.sseguro = p_sseguro
            AND gs.nriesgo = NVL(p_nriesgo, 1)
            AND((p_nmovimi IS NULL
                 AND gs.ffinefe IS NULL)
                OR gs.nmovimi = NVL(p_nmovimi, -1))
            AND gs.cgarant = p_cgarant;
      END IF;

      RETURN(TO_CHAR(w_icapital, 'FM999G999G999G990D00'));
   --
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('0,00');
   END f_capital_garant_ad;

   /*************************************************************************
     FUNCTION F_tot_prima_periodica
     param in psseguro  : codi asseguran¿a
     return             : capital garantia addicional

     Bug 11654 - 03/11/2009 - NMM.
   *************************************************************************/
   FUNCTION f_tot_prima_periodica(
      p_sseguro IN VARCHAR2,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_primaini IN NUMBER,
      p_idioma IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      w_iprianu      NUMBER;
      w_nriesgo      riesgos.nriesgo%TYPE;
      w_nmovimi      movseguro.nmovimi%TYPE;
      w_resultat     NUMBER;
      w_primaini     NUMBER;
   --
   -- En cas que es busqui en les taules definitives i no es trobi informaci¿,
   -- cercarem en les EST ( cas de simulacions).
   --
   BEGIN
      w_primaini := NVL(p_primaini, 0);

      BEGIN
         IF p_mode = 'POL' THEN
            SELECT NVL(gs.iprianu, 0)
              INTO w_iprianu
              FROM garanseg gs
             WHERE gs.sseguro = p_sseguro
               AND gs.nriesgo = NVL(p_nriesgo, 1)
               AND((p_nmovimi IS NULL
                    AND gs.ffinefe IS NULL)
                   OR gs.nmovimi = NVL(p_nmovimi, -1))
               AND gs.cgarant = p_cgarant;
         ELSE
            SELECT NVL(gs.iprianu, 0)
              INTO w_iprianu
              FROM estgaranseg gs
             WHERE gs.sseguro = p_sseguro
               AND gs.nriesgo = NVL(p_nriesgo, 1)
               AND((p_nmovimi IS NULL
                    AND gs.ffinefe IS NULL)
                   OR gs.nmovimi = NVL(p_nmovimi, -1))
               AND gs.cgarant = p_cgarant;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_iprianu := 0;
      END;

      w_resultat := w_primaini +(w_iprianu / 12) +(4 / 100 * w_iprianu / 12);
      RETURN(TO_CHAR(w_resultat, 'FM999G999G999G990D00'));
   --
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('0,00');
   END f_tot_prima_periodica;

   /*************************************************************************
     FUNCTION f_suma_aportacio
     param in psseguro   : codi asseguran¿a
     param in p_fecini   : data inici
     param in p_fecfin   : data fin
     param in p_ctipapor : tipus d'aportacio
                           E - Empresa
                           P - Part¿cep
     return              : suma aportaci¿

     Bug 11654 - 30/11/2009 - NMM.i.
   *************************************************************************/
   FUNCTION f_suma_aportacio(
      p_sseguro IN VARCHAR2,
      p_fecini IN DATE DEFAULT NULL,   -- BUG 19322 - 27/09/2011 - JMP
      p_fecfin IN DATE DEFAULT NULL,   -- BUG 19322 - 27/09/2011 - JMP
      p_ctipapor IN VARCHAR2 DEFAULT NULL   -- BUG 19322 - 27/09/2011 - JMP
                                         )
      RETURN VARCHAR2 IS
      w_suma_aportacio NUMBER;
   --
   BEGIN
      SELECT SUM(DECODE(cmovimi,
                        1, imovimi,
                        2, imovimi,
                        3, imovimi,
                        4, imovimi,
                        8, imovimi,
                        10, imovimi,
                        -imovimi))
        INTO w_suma_aportacio
        FROM ctaseguro
       WHERE sseguro = p_sseguro
         AND cesta IS NULL   --JRH
         AND cmovimi <> 0   --JRH
         AND nrecibo IS NOT NULL
         AND nsinies IS NULL
         -- BUG 19322 - 27/09/2011 - JMP
         AND(fvalmov >= p_fecini
             OR p_fecini IS NULL)
         AND(fvalmov <= p_fecfin
             OR p_fecfin IS NULL)
         AND((p_ctipapor = 'E'
              AND ctipapor IN('PR', 'SP', 'B'))
             OR(p_ctipapor = 'P'
                AND NVL(ctipapor, 'P') NOT IN('PR', 'SP', 'B'))
             OR p_ctipapor IS NULL);   -- FIN BUG 19322 - 27/09/2011 - JMP

      RETURN(TO_CHAR(w_suma_aportacio, 'FM999G999G999G990D00'));
   --
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('0,00');
   END f_suma_aportacio;

-- 30/11/2009.NMM.f.12101: CRE084 - A¿adir rentabilidad en consulta de p¿lizas.

   -- BUG 12485- 12/2009 - JRH  - Incidencias varias PPA
    /*************************************************************************
      FUNCTION f_interes_neto:retorna interes net
      param in psseguro  : codi asseguran¿a
      return             : interes net


    *************************************************************************/
   FUNCTION f_interes_neto(p_sseguro IN VARCHAR2)
      RETURN NUMBER IS
      vinteres       NUMBER;
      vprov          NUMBER;
      vfecrevi       DATE;
      vfecefec       DATE;
      vprima         NUMBER;
      vdias          NUMBER;
      vnum           NUMBER;
      v_resul        NUMBER;
      PRAGMA AUTONOMOUS_TRANSACTION;
   --
   BEGIN
      SELECT COUNT(*)
        INTO vnum
        FROM movseguro
       WHERE sseguro = p_sseguro;

      IF vnum <> 1 THEN
         RETURN NULL;   --Solo NP
      END IF;

      SELECT COUNT(*)
        INTO vnum
        FROM seguros
       WHERE sseguro = p_sseguro
         AND csituac = 0
         AND creteni = 0;

      IF vnum <> 1 THEN
         RETURN NULL;   --Solo NP emesses
      END IF;

      -- BUG 12777- 19/01/2010 - JAS
      SELECT COUNT(*)
        INTO vnum
        FROM pregunpolseg
       WHERE sseguro = p_sseguro
         AND nmovimi = 1
         AND cpregun = 9003
         AND crespue = 1;

      IF vnum = 1 THEN
         RETURN NULL;   --Nom¿s ho calculem per traspassos d'entrada.
      END IF;

      --Fi BUG 12777- 19/01/2010 - JAS
      SELECT fefecto
        INTO vfecefec
        FROM seguros
       WHERE sseguro = p_sseguro;

      SELECT frevisio
        INTO vfecrevi
        FROM seguros_aho
       WHERE sseguro = p_sseguro;

      BEGIN
         SELECT icapital
           INTO vprima
           FROM garanseg
          WHERE sseguro = p_sseguro
            AND cgarant = 282
            AND nmovimi = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT icapital
              INTO vprima
              FROM garanseg
             WHERE sseguro = p_sseguro
               AND cgarant = 48
               AND nmovimi = 1;
      END;

      vprov := pac_provmat_formul.f_calcul_formulas_provi(p_sseguro, vfecrevi, 'IPROVAC');
      vdias := vfecrevi - vfecefec;

      --INI--BUG 15853 - 03/09/2010 - ETM -se hacen un mejor tratmiento de errores
      IF NVL(vprima, 0) <> 0 THEN
         vinteres := POWER((vprov / vprima),(365 / vdias)) - 1;
         RETURN ROUND(vinteres * 100, 2);
      ELSIF vprima = 0 THEN
         v_resul := 0;
         RETURN 0;
      ELSIF vprima IS NULL THEN
         v_resul := -1;
         p_tab_error(f_sysdate, f_user, 'PAC_ISQLFOR.f_interes_neto', 1, SQLCODE,
                     'EL campo vprima es nulo--SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQLFOR.f_interes_neto', 1, SQLCODE,
                     'La variable v_resul es ' || v_resul || ' -- ' || 'SQLERROR: ' || SQLCODE
                     || ' - ' || SQLERRM);
         RETURN NVL(v_resul, NULL);
   --FIN--BUG 15853 - 03/09/2010 - ETM -se hacen un mejor tratmiento de errores
   END f_interes_neto;

-- Fi BUG 12485- 12/2009 - JRH  - Incidencias varias PPA

   /*************************************************************************
      FUNCTION f_perccc: retorna el CCC formatat d'una persona
      param in p_sperson : sperson
      return             : CCC de la persona
      BUG 12764 - JTS - 20/01/2010
    *************************************************************************/
   FUNCTION f_perccc(p_sperson IN NUMBER)
      RETURN VARCHAR2 IS
      v_cbancar      VARCHAR2(50);
      v_ctipban      NUMBER;
      v_ret          VARCHAR2(50);
      v_numerr       NUMBER;
   BEGIN
      v_numerr := f_buscarccc(p_sperson, v_cbancar, v_ctipban);

      IF v_numerr = 0 THEN
         v_numerr := f_formatoccc(v_cbancar, v_ret, v_ctipban);

         IF v_numerr = 0 THEN
            RETURN v_ret;
         ELSE
            RETURN v_cbancar;
         END IF;
      END IF;

      RETURN NULL;
   END f_perccc;

   /*****************************************************************
    FF_FORMATOCCC: Retorna el compte bancari sense formatejar en un
    string formatejat
    Encapsula la funci¿ f_formatoccc per a poder-la utilitzar directament
    en selects
    param pcbancar IN        : pcbancar
    param pctipban IN        : pctipban
    param pquitarformato IN  : pquitarformato
          return             : CCC formatat
    BUG 12764 - JTS - 20/01/2010
    ******************************************************************/
   FUNCTION ff_formatoccc(
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER DEFAULT 1,
      pquitarformato IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
      v_ret          VARCHAR2(50);
      v_numerr       NUMBER;
   BEGIN
      v_numerr := f_formatoccc(pcbancar, v_ret, pctipban, pquitarformato);

      IF v_numerr = 0 THEN
         RETURN v_ret;
      ELSE
         RETURN pcbancar;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQLFOR.ff_formatoccc', 1, SQLCODE,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END ff_formatoccc;

   -- BUG10522:DRA:08/02/2010:Inici
   /*****************************************************************
    F_TITPREG_RIE: Retorna els t¿tols de les preguntes de risc
    param p_sseguro IN        : sseguro
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_preguntas(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      -- BUG 0019779 - 20/10/2011 - JMF
      v_tlinia       VARCHAR2(500);
   BEGIN
      v_tconsulta := 'SELECT REPLACE(p.tpregun, CHR(39), CHR(39) || CHR(39)) a';
      v_tconsulta := v_tconsulta || ' FROM preguntas p, pregunpro pp, codipregun cp';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ', estseguros s';
      ELSE
         v_tconsulta := v_tconsulta || ', seguros s';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE s.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND p.cidioma = ' || NVL(p_cidioma, 1);
      v_tconsulta := v_tconsulta || ' AND pp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' AND pp.cramo = s.cramo';
      v_tconsulta := v_tconsulta || ' AND pp.cmodali = s.cmodali';
      v_tconsulta := v_tconsulta || ' AND pp.ctipseg = s.ctipseg';
      v_tconsulta := v_tconsulta || ' AND pp.ccolect = s.ccolect';
      v_tconsulta := v_tconsulta || ' AND pp.npreimp IS NOT NULL';
      v_tconsulta := v_tconsulta || ' AND cp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' AND NVL (cp.ctipgru, 0) = 0';
      v_tconsulta := v_tconsulta || ' AND p.cpregun IN (';
      v_tconsulta := v_tconsulta || ' SELECT sp.cpregun FROM ';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || 'estpregunseg sp';
      ELSE
         v_tconsulta := v_tconsulta || 'pregunseg sp';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE sp.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND sp.nmovimi = ' || NVL(p_nmovimi, 1);
      v_tconsulta := v_tconsulta || ' AND sp.nriesgo = ' || NVL(p_nriesgo, 1);
      v_tconsulta := v_tconsulta || ' UNION ALL ';
      v_tconsulta := v_tconsulta || ' SELECT sp.cpregun FROM ';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || 'estpregunpolseg sp';
      ELSE
         v_tconsulta := v_tconsulta || 'pregunpolseg sp';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE sp.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND sp.nmovimi = ' || NVL(p_nmovimi, 1);
      v_tconsulta := v_tconsulta || ' ) ORDER BY p.cpregun';

      --      END IF;  Bug 11006 - 07/09/2009 - ASN
      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_tlinia;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || v_tlinia || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_preguntas;

   /*****************************************************************
    F_respuestas: Retorna la resposta de les preguntes de risc
    param p_sseguro IN        : sseguro
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_respuestas(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_cpregun      NUMBER;
      v_crespue      NUMBER;
      v_sproduc      NUMBER;
      v_trespue      VARCHAR2(500);
      v_numerr       NUMBER;
      v_ctippre      codipregun.ctippre%TYPE;
      v_npoliza      NUMBER;
      v_cagente      NUMBER;
   BEGIN
      -- BUG26501 - 21/01/2014 - JTT
      SELECT npoliza, cagente
        INTO v_npoliza, v_cagente
        FROM (SELECT npoliza, cagente
                FROM estseguros
               WHERE sseguro = p_sseguro
                 AND p_mode = 'EST'
              UNION ALL
              SELECT npoliza, cagente
                FROM seguros
               WHERE sseguro = p_sseguro
                 AND NVL(p_mode, 'POL') <> 'EST');

      -- Fi BUG26501
      v_tconsulta := 'SELECT cpregun, ctippre, crespue, trespue, sproduc FROM (';
      v_tconsulta := v_tconsulta
                     || 'SELECT p.cpregun, cp.ctippre, p.crespue, p.trespue, s.sproduc ';
      v_tconsulta := v_tconsulta || ' FROM pregunpro pp, codipregun cp';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ', estpregunseg p, estseguros s';
      ELSE
         v_tconsulta := v_tconsulta || ', pregunseg p, seguros s';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE s.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND p.sseguro = s.sseguro';
      v_tconsulta := v_tconsulta || ' AND p.nriesgo = ' || NVL(p_nriesgo, 1);
      v_tconsulta := v_tconsulta || ' AND p.nmovimi = ' || NVL(p_nmovimi, 1);
      v_tconsulta := v_tconsulta || ' AND pp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' AND pp.cramo = s.cramo';
      v_tconsulta := v_tconsulta || ' AND pp.cmodali = s.cmodali';
      v_tconsulta := v_tconsulta || ' AND pp.ctipseg = s.ctipseg';
      v_tconsulta := v_tconsulta || ' AND pp.ccolect = s.ccolect';
      v_tconsulta := v_tconsulta || ' AND pp.npreimp IS NOT NULL';
      v_tconsulta := v_tconsulta || ' AND cp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' AND NVL (cp.ctipgru, 0) = 0';
      v_tconsulta := v_tconsulta || ' UNION ALL ';
      v_tconsulta := v_tconsulta
                     || ' SELECT p.cpregun, cp.ctippre, p.crespue, p.trespue, s.sproduc ';
      v_tconsulta := v_tconsulta || ' FROM pregunpro pp, codipregun cp';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ', estpregunpolseg p, estseguros s';
      ELSE
         v_tconsulta := v_tconsulta || ', pregunpolseg p, seguros s';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE s.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND p.sseguro = s.sseguro';
      v_tconsulta := v_tconsulta || ' AND p.nmovimi = ' || NVL(p_nmovimi, 1);
      v_tconsulta := v_tconsulta || ' AND pp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' AND pp.cramo = s.cramo';
      v_tconsulta := v_tconsulta || ' AND pp.cmodali = s.cmodali';
      v_tconsulta := v_tconsulta || ' AND pp.ctipseg = s.ctipseg';
      v_tconsulta := v_tconsulta || ' AND pp.ccolect = s.ccolect';
      v_tconsulta := v_tconsulta || ' AND pp.npreimp IS NOT NULL';
      v_tconsulta := v_tconsulta || ' AND cp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' AND NVL (cp.ctipgru, 0) = 0';
      v_tconsulta := v_tconsulta || ') ORDER BY cpregun';

      --      END IF;  Bug 11006 - 07/09/2009 - ASN
      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_cpregun, v_ctippre, v_crespue, v_trespue, v_sproduc;

         IF v_ctippre IN(3, 4, 5) THEN
            v_trespue := NVL(v_trespue, v_crespue);

            IF v_cpregun = 607 THEN
               -- Si la pregunta es la de salario declarado la formateamos
               v_trespue := TO_CHAR(v_crespue, 'FM999G999G999G990D00') || ' EUR';
            END IF;
         ELSE
            -- BUG26501 - 21/01/2014 - JTT: Passem el parametre npoliza
            v_numerr := pac_productos.f_get_pregunrespue(v_sproduc, v_cpregun, v_crespue,
                                                         p_cidioma, v_trespue, v_npoliza,
                                                         v_cagente);
         END IF;

         IF v_numerr <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_ISQLFOR.f_pregun_rie', 1, v_numerr,
                        'Params: ' || ' - ' || v_cpregun || ' - ' || v_crespue || ' - '
                        || v_sproduc);
         END IF;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || REPLACE(v_trespue, CHR(39), CHR(39) || CHR(39)) || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_respuestas;

-- BUG10522:DRA:08/02/2010:Fi

   /*************************************************************************
     FUNCTION f_imports
     param in psseguro  : codi asseguran¿a
     return             : import brut, rendiment, retencio, import_net

     Bug 13025 - JTS - 24/2/2010
   *************************************************************************/
   FUNCTION f_imports(p_sseguro IN seguros.sseguro%TYPE, p_tipus IN VARCHAR2)
      RETURN VARCHAR2 IS
      w_isinret      sin_tramita_pago.isinret%TYPE;
      w_iretenc      sin_tramita_pago.iretenc%TYPE;
      w_iresrcm      sin_tramita_pago.iresrcm%TYPE;
      w_ipenali      sin_tramita_reserva.ipenali%TYPE;
      w_imp_net      NUMBER;
      w_retorn       NUMBER;
   --
   BEGIN
      SELECT str.icaprie, iretenc, iresrcm,(isinret - iretenc) imp_net, str.ipenali
        INTO w_isinret, w_iretenc, w_iresrcm, w_imp_net, w_ipenali
        FROM sin_tramita_pago stp, sin_tramita_reserva str
       WHERE stp.nsinies = (SELECT MAX(s.nsinies)
                              FROM sin_siniestro s
                             WHERE s.sseguro = p_sseguro)
         AND stp.sidepag = str.sidepag(+);

      --
      IF p_tipus = 'IMP_BRUT' THEN
         w_retorn := w_isinret;
      ELSIF p_tipus = 'RETENCIO' THEN
         w_retorn := w_iretenc;
      ELSIF p_tipus = 'RENDIMENT' THEN
         w_retorn := w_iresrcm;
      ELSIF p_tipus = 'IMP_NET' THEN
         w_retorn := w_imp_net;
      ELSIF p_tipus = 'IMP_PENA' THEN
         w_retorn := w_ipenali;
      END IF;

      RETURN(TO_CHAR(w_retorn, 'FM999G999G999G990D00'));
   --
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_imports;

   /*************************************************************************
     FUNCTION f_total_parcial
     param in psseguro  : codi asseguran¿a
     return             : total o parcial

     Bug 12388 - 28/12/2009 - NMM.
   *************************************************************************/
   FUNCTION f_total_parcial(p_sseguro IN seguros.sseguro%TYPE, pcidioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      w_ccausin      VARCHAR2(50);
   --
   BEGIN
      SELECT DECODE(ccausin,
                    4, f_axis_literales(9901008, pcidioma),
                    5, f_axis_literales(9901009, pcidioma),
                    NULL)
        INTO w_ccausin
        FROM sin_siniestro
       WHERE nsinies = (SELECT MAX(s.nsinies)
                          FROM sin_siniestro s
                         WHERE s.sseguro = p_sseguro);

      RETURN(w_ccausin);
   --
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_total_parcial;

   /*************************************************************************
      FUNCTION f_provisio_actual
      param in psseguro  : codi asseguran¿a
      param in pconcepto : camp de la provisio
      param in p_fecha   : data de c¿lcul
      return             : cap defuncio
      --BUG13480-JTS-03/03/2010
      -- BUG 19322 - 28/09/2011 - JMP
     -- Bug 0025097 - 13/02/2013 - JMF
     *************************************************************************/
   FUNCTION f_provisio_actual(
      p_sseguro IN VARCHAR2,
      p_concepto IN VARCHAR2,
      p_fecha IN DATE DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT NULL,
      p_ndetgar IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_result       NUMBER;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      v_result := pac_provmat_formul.f_calcul_formulas_provi(p_sseguro,
                                                             NVL(p_fecha, f_sysdate),
                                                             p_concepto, p_cgarant, p_ndetgar);
      RETURN v_result;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN v_result;
   END f_provisio_actual;

   /*************************************************************************
      FUNCTION f_apunts_ctaseguro
      param in psseguro  : codi asseguran¿a
      param in pidioma   : idioma
      param in pcamp     : camp
      return             : apunt
      --BUG13404-JTS-04/03/2010
    *************************************************************************/
   FUNCTION f_apunts_ctaseguro(p_sseguro IN NUMBER, p_idioma IN NUMBER, p_camp IN NUMBER)
      RETURN VARCHAR2 IS
      v_result       VARCHAR2(4000);

      CURSOR v_cur IS
         SELECT   REPLACE
                     (DECODE
                         (p_camp,
                          1, TO_CHAR(cta.ffecmov, 'DD/MM/YYYY'),
                          6, TO_CHAR(cta.fvalmov, 'DD/MM/YYYY'),
                          2, pac_isqlfor.f_agente((SELECT mov.coficin
                                                     FROM movseguro mov
                                                    WHERE mov.nmovimi =
                                                             DECODE(nrecibo,
                                                                    NULL, (SELECT s.nmovimi
                                                                             FROM sin_siniestro s
                                                                            WHERE s.nsinies =
                                                                                     cta.nsinies),
                                                                    (SELECT r.nmovimi
                                                                       FROM recibos r
                                                                      WHERE r.nrecibo =
                                                                                    cta.nrecibo))
                                                      AND mov.sseguro = cta.sseguro)),
                          3, dv.tatribu,
                          4, TO_CHAR(cta.imovimi, 'FM999G999G999G999G999G990D00') || ' EUR',
                          5, TO_CHAR((SELECT SUM(DECODE(cta2.nsinies,
                                                        NULL, imovimi,
                                                        (-1 * imovimi)))
                                        FROM ctaseguro cta2
                                       WHERE cta2.nnumlin <= cta.nnumlin
                                         AND cta2.sseguro = cta.sseguro),
                                     'FM999G999G999G999G999G990D00')
                           || ' EUR',
                          NULL),
                      CHR(39), CHR(39) || CHR(39)) camp
             FROM ctaseguro cta, detvalores dv
            WHERE cta.sseguro = p_sseguro
              AND cta.cmovanu = 0   --BUG 15795--ETM--07/10/2010
              AND dv.cvalor = 83
              AND dv.catribu = cta.cmovimi
              AND dv.cidioma = p_idioma
         ORDER BY DECODE(cta.cmovimi,   --BUG 15795-JTS-13/09/2010
                         0, cta.fvalmov,
                         2, cta.fvalmov,
                         53, cta.fvalmov,
                         TRUNC(cta.fcontab)) DESC,
                  cta.nnumlin DESC;
   BEGIN
      FOR res IN v_cur LOOP
         IF v_result IS NULL THEN
            v_result := res.camp;
         ELSE
            v_result := v_result || '\par ' || res.camp;
         END IF;
      END LOOP;

      RETURN v_result;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN v_result;
   END f_apunts_ctaseguro;

   /*************************************************************************
      FUNCTION f_apunts_rescat_anual
      param in psseguro  : codi asseguran¿a
      param in pcamp     : camp de la provisio
      return             : apunt del rescat anual
      --BUG11651-JTS-15/07/2010
    *************************************************************************/
   FUNCTION f_apunts_rescat_anual(p_sseguro IN NUMBER, p_camp IN NUMBER, p_tablas IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_result       VARCHAR2(4000);
      v_nmovimi      NUMBER;
      v_pgarantit    NUMBER;
      v_prestimada   NUMBER;
      v_pmensualini  NUMBER;
   BEGIN
      IF p_tablas IS NULL
         OR p_tablas = 'SEG' THEN
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM evoluprovmatseg
          WHERE sseguro = p_sseguro;

         SELECT pac_inttec.ff_int_seguro('SEG', s.sseguro, s.fefecto, 0)
           INTO v_pgarantit
           FROM seguros s
          WHERE sseguro = p_sseguro;

         IF p_camp = 1 THEN
            SELECT SUM(pinttec) / COUNT(1)
              INTO v_prestimada
              FROM evoluprovmatseg
             WHERE sseguro = p_sseguro
               AND nmovimi = v_nmovimi;

            v_result := TO_CHAR(v_prestimada, 'FM990D00') || '%';
         ELSIF p_camp = 2 THEN
            SELECT iprima
              INTO v_pmensualini
              FROM evoluprovmatseg
             WHERE sseguro = p_sseguro
               AND nmovimi = v_nmovimi
               AND nanyo = (SELECT MIN(nanyo)
                              FROM evoluprovmatseg
                             WHERE sseguro = p_sseguro
                               AND nmovimi = v_nmovimi);

            v_result := TO_CHAR(v_pmensualini, 'FM999G999G999G999G999G990D00') || ' EUR';
         ELSIF p_camp = 9 THEN
            v_result := TO_CHAR(v_pgarantit, 'FM990D00') || '%';
         ELSE
            FOR i IN (SELECT   DECODE(p_camp,
                                      3, TO_CHAR(nanyo),
                                      4, TO_CHAR(v_pgarantit, 'FM990D00') || '%',
                                      5, TO_CHAR(pinttec - v_pgarantit, 'FM990D00') || '%',
                                      6, TO_CHAR(pinttec, 'FM990D00') || '%',
                                      7, TO_CHAR(iprima, 'FM999G999G999G999G999G990D00')
                                       || ' EUR',
                                      8, TO_CHAR(ivalres, 'FM999G999G999G999G999G990D00')
                                       || ' EUR',
                                      10, TO_CHAR(fprovmat, 'DD/MM/YYYY'),
                                      11, TO_CHAR(icapfall, 'FM999G999G999G999G999G990D00')
                                       || ' EUR',
                                      NULL) pval
                          FROM evoluprovmatseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = v_nmovimi
                      ORDER BY nanyo) LOOP
               v_result := v_result || i.pval || '\par ';
            END LOOP;
         END IF;
      ELSIF p_tablas = 'EST' THEN
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM estevoluprovmatseg
          WHERE sseguro = p_sseguro;

         SELECT pac_inttec.ff_int_seguro('EST', s.sseguro, s.fefecto, 0)
           INTO v_pgarantit
           FROM estseguros s
          WHERE sseguro = p_sseguro;

         IF p_camp = 1 THEN
            SELECT SUM(pinttec) / COUNT(1)
              INTO v_prestimada
              FROM estevoluprovmatseg
             WHERE sseguro = p_sseguro
               AND nmovimi = v_nmovimi;

            v_result := TO_CHAR(v_prestimada, 'FM990D00') || '%';
         ELSIF p_camp = 2 THEN
            SELECT iprima
              INTO v_pmensualini
              FROM estevoluprovmatseg
             WHERE sseguro = p_sseguro
               AND nmovimi = v_nmovimi
               AND nanyo = (SELECT MIN(nanyo)
                              FROM estevoluprovmatseg
                             WHERE sseguro = p_sseguro
                               AND nmovimi = v_nmovimi);

            v_result := TO_CHAR(v_pmensualini, 'FM999G999G999G999G999G990D00') || ' EUR';
         ELSIF p_camp = 9 THEN
            v_result := TO_CHAR(v_pgarantit, 'FM990D00') || '%';
         ELSE
            FOR i IN (SELECT   DECODE(p_camp,
                                      3, TO_CHAR(nanyo),
                                      4, TO_CHAR(v_pgarantit, 'FM990D00') || '%',
                                      5, TO_CHAR(pinttec - v_pgarantit, 'FM990D00') || '%',
                                      6, TO_CHAR(pinttec, 'FM990D00') || '%',
                                      7, TO_CHAR(iprima, 'FM999G999G999G999G999G990D00')
                                       || ' EUR',
                                      8, TO_CHAR(ivalres, 'FM999G999G999G999G999G990D00')
                                       || ' EUR',
                                      10, TO_CHAR(fprovmat, 'DD/MM/YYYY'),
                                      11, TO_CHAR(iprovmat, 'FM999G999G999G999G999G990D00')
                                       || ' EUR',
                                      NULL) pval
                          FROM estevoluprovmatseg
                         WHERE sseguro = p_sseguro
                           AND nmovimi = v_nmovimi
                      ORDER BY nanyo) LOOP
               v_result := v_result || i.pval || '\par ';
            END LOOP;
         END IF;
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_apunts_rescat_anual;

   /*************************************************************************
      FUNCTION f_capital_estimat
      param in psseguro  : codi asseguran¿a
      param in pnriesgo  : riesgo
      param in pfefecto  : data efecte
      param in pcamp     : camp de la provisio
      return             : apunt del rescat anual
      --BUG11651-JTS-15/07/2010
    *************************************************************************/
   FUNCTION f_capital_estimat(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_fefecto IN DATE,
      p_camp IN NUMBER)
      RETURN VARCHAR2 IS
      v_result       VARCHAR2(4000);
      v_numerr       NUMBER;
      v_datecon      ob_iax_datoseconomicos;
      v_mensajes     t_iax_mensajes;
      PRAGMA AUTONOMOUS_TRANSACTION;   --BUG14598-JTS-21/07/2010
   BEGIN
      v_numerr := pac_md_datosctaseguro.f_obtdatecon(p_sseguro, p_nriesgo, p_fefecto,
                                                     v_datecon, v_mensajes);
      v_result := TO_CHAR(v_datecon.impcapgarrevi, 'FM999G999G999G999G999G990D00') || ' EUR';
      RETURN v_result;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN v_result;
   END f_capital_estimat;

   -- Bug 14775 - RSC - 13/08/2010- AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
   FUNCTION f_tmp_prima_anual(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2 IS
      v_fcaranu      seguros.fcaranu%TYPE;
      v_npoliza      seguros.npoliza%TYPE;
      v_ncertif      seguros.ncertif%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cramo%TYPE;
      v_ctipseg      seguros.cramo%TYPE;
      v_ccolect      seguros.cramo%TYPE;
      v_error        NUMBER;
      v_prima_anual  NUMBER(15, 2) := 0;
      v_prima_np     NUMBER;
      v_prima_rec    NUMBER;
      v_prima_tmp    NUMBER;
   BEGIN
----------------------------------------------------
-- Recibo de nueva producci¿n
----------------------------------------------------
      BEGIN
         SELECT (v.iprinet)
           INTO v_prima_np
           FROM seguros s, recibos r, vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.ctiprec = 0
            AND r.nrecibo = v.nrecibo
            AND r.nmovimi = f_max_nmovimi(s.sseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_prima_np := 0;
      END;

-------------------------------------
-- Sumatorio de recibos ya generados
-------------------------------------
      SELECT NVL(SUM(v.iprinet), 0)
        INTO v_prima_rec
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.nrecibo = v.nrecibo
         AND r.ctiprec = 3
         AND r.nrecibo IN(SELECT r2.nrecibo
                            FROM recibos r2
                           WHERE r2.sseguro = s.sseguro
                             AND r2.ctiprec = 3
                             AND r2.fefecto >= ADD_MONTHS(v_fcaranu, -12)
                             AND r2.fefecto <= v_fcaranu);

----------------------------------------------------
-- Sumatorio/simulaci¿n de recibos restantes del a¿o
----------------------------------------------------
      IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) = 0 THEN
         SELECT NVL(SUM(v.iprinet), 0)
           INTO v_prima_tmp
           FROM seguros s, tmp_adm_recibos r, tmp_adm_vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces;
      ELSE
         SELECT NVL(SUM(v.iprinet), 0)
           INTO v_prima_tmp
           FROM seguros s, reciboscar r, vdetreciboscar v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces;
      END IF;

      v_prima_anual := v_prima_np + v_prima_rec + v_prima_tmp;
      RETURN(v_prima_anual);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tmp_prima_anual;

   FUNCTION f_tmp_prima_total(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2 IS
      v_fcaranu      seguros.fcaranu%TYPE;
      v_npoliza      seguros.npoliza%TYPE;
      v_ncertif      seguros.ncertif%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cramo%TYPE;
      v_ctipseg      seguros.cramo%TYPE;
      v_ccolect      seguros.cramo%TYPE;
      v_error        NUMBER;
      v_prima_np     NUMBER;
      v_prima_rec    NUMBER;
      v_prima_tmp    NUMBER;
      v_prima_total  NUMBER(15, 2);
   BEGIN
----------------------------------------------------
-- Recibo de nueva producci¿n
----------------------------------------------------
      BEGIN
         SELECT (v.itotalr)
           INTO v_prima_np
           FROM seguros s, recibos r, vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.ctiprec = 0
            AND r.nrecibo = v.nrecibo
            AND r.nmovimi = f_max_nmovimi(s.sseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_prima_np := 0;
      END;

-------------------------------------
-- Sumatorio de recibos ya generados
-------------------------------------
      SELECT NVL(SUM(v.itotalr), 0)
        INTO v_prima_rec
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.nrecibo = v.nrecibo
         AND r.ctiprec = 3
         AND r.nrecibo IN(SELECT r2.nrecibo
                            FROM recibos r2
                           WHERE r2.sseguro = s.sseguro
                             AND r2.ctiprec = 3
                             AND r2.fefecto >= ADD_MONTHS(v_fcaranu, -12)
                             AND r2.fefecto <= v_fcaranu);

----------------------------------------------------
-- Sumatorio/simulaci¿n de recibos restantes del a¿o
----------------------------------------------------
      IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) = 0 THEN
         SELECT NVL(SUM(v.itotalr), 0)
           INTO v_prima_tmp
           FROM seguros s, tmp_adm_recibos r, tmp_adm_vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces;
      ELSE
         SELECT NVL(SUM(v.itotalr), 0)
           INTO v_prima_tmp
           FROM seguros s, reciboscar r, vdetreciboscar v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces;
      END IF;

      v_prima_total := v_prima_np + v_prima_rec + v_prima_tmp;
      RETURN(v_prima_total);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tmp_prima_total;

   FUNCTION f_tmp_recarreg(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2 IS
      v_fcaranu      seguros.fcaranu%TYPE;
      v_npoliza      seguros.npoliza%TYPE;
      v_ncertif      seguros.ncertif%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cramo%TYPE;
      v_ctipseg      seguros.cramo%TYPE;
      v_ccolect      seguros.cramo%TYPE;
      v_error        NUMBER;
      v_recar_np     NUMBER;
      v_recar_rec    NUMBER;
      v_recar_tmp    NUMBER;
      v_recarreg     NUMBER(15, 2);
   BEGIN
----------------------------------------------------
-- Recibo de nueva producci¿n
----------------------------------------------------
      BEGIN
         SELECT (v.irecfra)
           INTO v_recar_np
           FROM seguros s, recibos r, vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.ctiprec = 0
            AND r.nrecibo = v.nrecibo
            AND r.nmovimi = f_max_nmovimi(s.sseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_recar_np := 0;
      END;

-------------------------------------
-- Sumatorio de recibos ya generados
-------------------------------------
      SELECT NVL(SUM(v.irecfra), 0)
        INTO v_recar_rec
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.nrecibo = v.nrecibo
         AND r.ctiprec = 3
         AND r.nrecibo IN(SELECT r2.nrecibo
                            FROM recibos r2
                           WHERE r2.sseguro = s.sseguro
                             AND r2.ctiprec = 3
                             AND r2.fefecto >= ADD_MONTHS(v_fcaranu, -12)
                             AND r2.fefecto <= v_fcaranu);

----------------------------------------------------
-- Sumatorio/simulaci¿n de recibos restantes del a¿o
----------------------------------------------------
      IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) = 0 THEN
         SELECT NVL(SUM(v.irecfra), 0)
           INTO v_recar_tmp
           FROM seguros s, tmp_adm_recibos r, tmp_adm_vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces;
      ELSE
         SELECT NVL(SUM(v.irecfra), 0)
           INTO v_recar_tmp
           FROM seguros s, reciboscar r, vdetreciboscar v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces;
      END IF;

      v_recarreg := v_recar_np + v_recar_rec + v_recar_tmp;
      RETURN(v_recarreg);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tmp_recarreg;

   FUNCTION f_tmp_tributs(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2 IS
      v_fcaranu      seguros.fcaranu%TYPE;
      v_npoliza      seguros.npoliza%TYPE;
      v_ncertif      seguros.ncertif%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cramo%TYPE;
      v_ctipseg      seguros.cramo%TYPE;
      v_ccolect      seguros.cramo%TYPE;
      v_error        NUMBER;
      v_trib_np      NUMBER;
      v_trib_rec     NUMBER;
      v_trib_tmp     NUMBER;
      v_tributs      NUMBER(15, 2);
   BEGIN
----------------------------------------------------
-- Recibo de nueva producci¿n
----------------------------------------------------
      BEGIN
         SELECT (v.iips + v.idgs + v.iarbitr + v.ifng)
           INTO v_trib_np
           FROM seguros s, recibos r, vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.ctiprec = 0
            AND r.nrecibo = v.nrecibo
            AND r.nmovimi = f_max_nmovimi(s.sseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_trib_np := 0;
      END;

-------------------------------------
-- Sumatorio de recibos ya generados
-------------------------------------
      SELECT NVL(SUM(v.iips + v.idgs + v.iarbitr + v.ifng), 0)
        INTO v_trib_rec
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.nrecibo = v.nrecibo
         AND r.ctiprec = 3
         AND r.nrecibo IN(SELECT r2.nrecibo
                            FROM recibos r2
                           WHERE r2.sseguro = s.sseguro
                             AND r2.ctiprec = 3
                             AND r2.fefecto >= ADD_MONTHS(v_fcaranu, -12)
                             AND r2.fefecto <= v_fcaranu);

----------------------------------------------------
-- Sumatorio/simulaci¿n de recibos restantes del a¿o
----------------------------------------------------
      IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) = 0 THEN
         SELECT NVL(SUM(v.iips + v.idgs + v.iarbitr + v.ifng), 0)
           INTO v_trib_tmp
           FROM seguros s, tmp_adm_recibos r, tmp_adm_vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces;
      ELSE
         SELECT NVL(SUM(v.iips + v.idgs + v.iarbitr + v.ifng), 0)
           INTO v_trib_tmp
           FROM seguros s, reciboscar r, vdetreciboscar v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces;
      END IF;

      v_tributs := v_trib_np + v_trib_rec + v_trib_tmp;
      RETURN(v_tributs);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tmp_tributs;

   FUNCTION f_tmp_prima_mensual_inicial(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2 IS
      v_prima_mensual_inicial NUMBER(15, 2);
      v_fcaranu      seguros.fcaranu%TYPE;
      v_npoliza      seguros.npoliza%TYPE;
      v_ncertif      seguros.ncertif%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cramo%TYPE;
      v_ctipseg      seguros.cramo%TYPE;
      v_ccolect      seguros.cramo%TYPE;
      v_error        NUMBER;
   BEGIN
----------------------------------------------------
-- Sumatorio/simulaci¿n de recibos restantes del a¿o
----------------------------------------------------
      IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) = 0 THEN
         SELECT NVL(SUM(v.itotalr), 0)
           INTO v_prima_mensual_inicial
           FROM seguros s, tmp_adm_recibos r, tmp_adm_vdetrecibos v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces
            AND r.fefecto = (SELECT MIN(r2.fefecto)
                               FROM tmp_adm_recibos r2
                              WHERE r2.sseguro = s.sseguro
                                AND r2.sproces = r.sproces);
      ELSE
         SELECT NVL(SUM(v.itotalr), 0)
           INTO v_prima_mensual_inicial
           FROM seguros s, reciboscar r, vdetreciboscar v
          WHERE s.sseguro = p_sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.sproces = psproces
            AND r.fefecto = (SELECT MIN(r2.fefecto)
                               FROM reciboscar r2
                              WHERE r2.sseguro = s.sseguro
                                AND r2.sproces = r.sproces);
      END IF;

      RETURN(v_prima_mensual_inicial);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tmp_prima_mensual_inicial;

-- Fin Bug 14775

   -- BUG16373:DRA:21/10/2010:Inici
   FUNCTION f_camp_ctaseguros_sinsaldo(
      psseguro IN NUMBER,
      pcampo IN NUMBER,
      pfechaini IN DATE DEFAULT NULL,
      pfechafin IN DATE DEFAULT NULL)
      RETURN VARCHAR2 IS
      --
      vtexto         VARCHAR2(4000);   --BUG15280 - JTS - 09/07/2010
      vfechaini      DATE;
      vfefecto       DATE;
   BEGIN
      IF pfechafin IS NULL THEN
         SELECT fefecto
           INTO vfefecto
           FROM seguros
          WHERE sseguro = psseguro;

         --SELECT GREATEST(vfefecto, ADD_MONTHS(f_sysdate, -12))
         SELECT ADD_MONTHS(f_sysdate, -12)
           INTO vfechaini
           FROM DUAL;
      END IF;

      -- Bug 11097 - RSC - 19/10/2009 - CRE - Documentaci¿n de los productos PPJ Din¿mico + PLA Estudiant
      -- Se a¿ade join con seguros y f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), ...
      FOR cur IN (SELECT   ff_desvalorfijo(83, 1, c.cmovimi) "MOVIMIENTO", c.ffecmov,
                           c.fvalmov, c.imovimi
                      FROM ctaseguro c, seguros s
                     WHERE c.sseguro = psseguro
                       AND c.sseguro = s.sseguro
                       AND c.cmovimi <> 0   -- BUG16373:DRA:21/10/2010
                       --AND c.fcontab BETWEEN NVL(pfechaini, vfechaini)  30/11/2009.NMM.i.12101
                       --                  AND NVL(pfechafin, f_sysdate)  30/11/2009.NMM.f.12101
                       AND((NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
                            AND c.cesta IS NOT NULL)
                           OR(NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1))
                  ORDER BY DECODE(c.cmovimi,   --BUG 15795-JTS-13/09/2010
                                  2, c.fvalmov,
                                  53, c.fvalmov,
                                  TRUNC(c.fcontab)) DESC,
                           c.nnumlin DESC) LOOP
         -- Fin Bug 11097
         IF pcampo = 1 THEN
            vtexto := vtexto || cur.movimiento || '\par ';
         ELSIF pcampo = 2 THEN
            vtexto := vtexto || TO_CHAR(cur.ffecmov, 'DD/MM/YYYY') || '\par ';
         ELSIF pcampo = 3 THEN
            vtexto := vtexto || TO_CHAR(cur.fvalmov, 'DD/MM/YYYY') || '\par ';
         ELSIF pcampo = 4 THEN
            vtexto := vtexto || TO_CHAR(cur.imovimi, 'FM999G999G999G990D00') || '\par ';
         END IF;
      END LOOP;

      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_camp_ctaseguros_sinsaldo;

-- BUG16373:DRA:21/10/2010:Fi

   /*****************************************************************
    F_PREGUNTAS_GAR: Retorna els t¿tols de les preguntes de garantia
    param p_sseguro IN        : sseguro
    param p_nriesgo IN        : numero de riesgo
    param p_nmovimi IN        : numero de movimiento
    param p_cidioma IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2

     Bug 16485 - 05/11/2010 - AMC
    ******************************************************************/
   FUNCTION f_preguntas_gar(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_tlinia       VARCHAR2(1000);
      v_orden        VARCHAR2(100);
   BEGIN
      v_tconsulta := 'select to_char(g.cgarant),to_char(tgarant)';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' from estgaranseg g, garangen ga';
      ELSE
         v_tconsulta := v_tconsulta || ' from garanseg g, garangen ga';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE g.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND g.nriesgo = ' || p_nriesgo;
      v_tconsulta := v_tconsulta || ' AND g.nmovimi = ' || p_nmovimi;
      v_tconsulta := v_tconsulta || ' AND g.cgarant = ga.cgarant';
      v_tconsulta := v_tconsulta || ' AND ga.cidioma = ' || NVL(p_cidioma, 1);
      v_tconsulta := v_tconsulta || ' UNION';
      v_tconsulta :=
         v_tconsulta
         || ' select to_char(p.cgarant)||''-''||to_char(rownum),'' - ''||to_Char(pr.tpregun) ';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' from estpregungaranseg p,  preguntas pr ';
      ELSE
         v_tconsulta := v_tconsulta || ' from pregungaranseg p, preguntas pr ';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE p.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND p.nriesgo = ' || p_nriesgo;
      v_tconsulta := v_tconsulta || ' AND p.nmovimi = ' || p_nmovimi;
      v_tconsulta := v_tconsulta || ' AND p.CPREGUN = pr.CPREGUN';
      v_tconsulta := v_tconsulta || ' AND pr.cidioma = ' || NVL(p_cidioma, 1);
      v_tconsulta := v_tconsulta || ' order by 1';

      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_orden, v_tlinia;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || v_tlinia || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_preguntas_gar;

   /*****************************************************************
    F_RESPUESTAS_GAR: Retorna els respuestas de les preguntes de garantia
    param p_sseguro IN        : sseguro
    param p_nriesgo IN        : numero de riesgo
    param p_nmovimi IN        : numero de movimiento
    param p_cidioma IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2

    Bug 16485 - 05/11/2010 - AMC
    ******************************************************************/
   FUNCTION f_respuestas_gar(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_tlinia       VARCHAR2(1000);
      v_orden        VARCHAR2(100);
      v_cpregun      NUMBER;
      v_crespue      NUMBER;
      v_sproduc      NUMBER;
      v_trespue      VARCHAR2(500);
      v_numerr       NUMBER;
      v_ctippre      codipregun.ctippre%TYPE;
      v_npoliza      NUMBER;
      v_cagente      NUMBER;
   BEGIN
      -- BUG26501 - 21/01/2014 - JTT
      SELECT npoliza, cagente
        INTO v_npoliza, v_cagente
        FROM (SELECT npoliza, cagente
                FROM estseguros
               WHERE sseguro = p_sseguro
                 AND p_mode = 'EST'
              UNION ALL
              SELECT npoliza, cagente
                FROM seguros
               WHERE sseguro = p_sseguro
                 AND NVL(p_mode, 'POL') <> 'EST');

      -- Fi BUG26501
      v_tconsulta := 'select to_char(g.cgarant),null,null,null,null,null';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' from estgaranseg g, garangen ga';
      ELSE
         v_tconsulta := v_tconsulta || ' from garanseg g, garangen ga';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE g.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND g.nriesgo = ' || p_nriesgo;
      v_tconsulta := v_tconsulta || ' AND g.nmovimi = ' || p_nmovimi;
      v_tconsulta := v_tconsulta || ' AND g.cgarant = ga.cgarant';
      v_tconsulta := v_tconsulta || ' AND ga.cidioma = ' || NVL(p_cidioma, 1);
      v_tconsulta := v_tconsulta || ' UNION';
      v_tconsulta :=
         v_tconsulta
         || ' select to_char(p.cgarant)||''-''||to_char(rownum),p.cpregun,cp.ctippre, p.crespue, p.trespue, s.sproduc ';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta :=
            v_tconsulta
            || ' from estpregungaranseg p, preguntas pr,codipregun cp, estseguros s  ';
      ELSE
         v_tconsulta := v_tconsulta
                        || ' from pregungaranseg p, preguntas pr,codipregun cp, seguros s  ';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE p.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND p.nriesgo = ' || p_nriesgo;
      v_tconsulta := v_tconsulta || ' AND p.nmovimi = ' || p_nmovimi;
      v_tconsulta := v_tconsulta || ' AND p.cpregun = pr.cpregun';
      v_tconsulta := v_tconsulta || ' AND pr.cidioma = ' || NVL(p_cidioma, 1);
      v_tconsulta := v_tconsulta || ' AND cp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = p.sseguro';
      v_tconsulta := v_tconsulta || ' order by 1';

      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_orden, v_cpregun, v_ctippre, v_crespue, v_trespue, v_sproduc;

         IF v_ctippre IN(3, 4, 5) THEN
            v_trespue := NVL(v_trespue, v_crespue);

            IF v_cpregun = 607 THEN
               -- Si la pregunta es la de salario declarado la formateamos
               v_trespue := TO_CHAR(v_crespue, 'FM999G999G999G990D00') || ' EUR';
            END IF;
         ELSE
            -- BUB26501 - 21/01/2014 - JTT: Passem el parametre npoliza
            v_numerr := pac_productos.f_get_pregunrespue(v_sproduc, v_cpregun, v_crespue,
                                                         p_cidioma, v_trespue, v_npoliza,
                                                         v_cagente);
         END IF;

         IF v_numerr <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_ISQLFOR.f_respuestas_gar', 1, v_numerr,
                        'Params: ' || ' - ' || v_cpregun || ' - ' || v_crespue || ' - '
                        || v_sproduc);
         END IF;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || v_trespue || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_respuestas_gar;

   /*****************************************************************
    F_CAPITAL_GAR: Retorna els capitals de garantia
    param p_sseguro IN        : sseguro
    param p_nriesgo IN        : numero de riesgo
    param p_nmovimi IN        : numero de movimiento
    param p_cidioma IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2

     Bug 16485 - 05/11/2010 - AMC
    ******************************************************************/
   FUNCTION f_capital_gar(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_tlinia       VARCHAR2(1000);
      v_orden        VARCHAR2(100);
      v_capital      NUMBER;
   BEGIN
      v_tconsulta := 'select to_char(g.cgarant),icapital';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' from estgaranseg g, garangen ga';
      ELSE
         v_tconsulta := v_tconsulta || ' from garanseg g, garangen ga';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE g.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND g.nriesgo = ' || p_nriesgo;
      v_tconsulta := v_tconsulta || ' AND g.nmovimi = ' || p_nmovimi;
      v_tconsulta := v_tconsulta || ' AND g.cgarant = ga.cgarant';
      v_tconsulta := v_tconsulta || ' AND ga.cidioma = ' || NVL(p_cidioma, 1);
      v_tconsulta := v_tconsulta || ' UNION';
      v_tconsulta := v_tconsulta || ' select to_char(p.cgarant)||''-''||to_char(rownum),null ';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta :=
            v_tconsulta
            || ' from estpregungaranseg p, preguntas pr,codipregun cp, estseguros s  ';
      ELSE
         v_tconsulta := v_tconsulta
                        || ' from pregungaranseg p, preguntas pr,codipregun cp, seguros s  ';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE p.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND p.nriesgo = ' || p_nriesgo;
      v_tconsulta := v_tconsulta || ' AND p.nmovimi = ' || p_nmovimi;
      v_tconsulta := v_tconsulta || ' AND p.cpregun = pr.cpregun';
      v_tconsulta := v_tconsulta || ' AND pr.cidioma = ' || NVL(p_cidioma, 1);
      v_tconsulta := v_tconsulta || ' AND cp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = p.sseguro';
      v_tconsulta := v_tconsulta || ' order by 1';

      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_orden, v_capital;

         EXIT WHEN vr_cursor%NOTFOUND;

         IF v_capital IS NOT NULL THEN
            v_tresult := v_tresult || TO_CHAR(v_capital, 'FM999G999G999G990D00') || ' EUR'
                         || '\par ';
         ELSE
            v_tresult := v_tresult || '\par ';
         END IF;
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_capital_gar;

   /*****************************************************************
    F_SUPLEMENTOS: Retorna los suplementos
    param p_sseguro IN  : sseguro
    param p_nriesgo IN  : numero de riesgo
    param p_cidioma IN  : idioma
    return              : VARCHAR2

     Bug 16485 - 22/11/2010 - AMC
   ******************************************************************/
   FUNCTION f_suplementos(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_tlinia       VARCHAR2(1000);
      v_motmov       VARCHAR2(500);
      v_valor        VARCHAR2(500);
   BEGIN
      v_tconsulta := 'select m.tmotmov,s.TVALORD ';
      v_tconsulta := v_tconsulta || ' from sup_solicitud s,motmovseg m ';
      v_tconsulta := v_tconsulta || ' where s.SSEGURO = ' || psseguro;
      v_tconsulta := v_tconsulta || ' and s.NRIESGO = ' || pnriesgo;
      v_tconsulta := v_tconsulta || ' and s.CESTSUP = 0';
      v_tconsulta := v_tconsulta || ' and s.cmotmov = m.cmotmov ';
      v_tconsulta := v_tconsulta || ' and m.cidioma =' || pcidioma;

      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_motmov, v_valor;

         EXIT WHEN vr_cursor%NOTFOUND;

         IF v_motmov IS NOT NULL THEN
            v_tresult := v_tresult || v_motmov || ' --> ' || v_valor || '\par ';
         ELSE
            v_tresult := v_tresult || '\par ';
         END IF;
      END LOOP;

      RETURN(v_tresult);
   END f_suplementos;

   /*****************************************************************
    f_formapagorecibo: Retorna la forma de pago del recibo
    param p_nrecibo IN  : nrecibo
    param p_cidioma IN  : idioma
    return              : VARCHAR2

     Bug 17435 - 03/02/2011 - JTS
   ******************************************************************/
   FUNCTION f_formapagorecibo(pnrecibo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      CURSOR v_formapag IS
         SELECT ff_desvalorfijo(1026, pcidioma, NVL(m.ctipcob, 2)) ret
           FROM movrecibo m
          WHERE m.nrecibo = pnrecibo
            AND m.fmovfin IS NULL;

      v_tresult      VARCHAR2(250) := '';
   BEGIN
      FOR i IN v_formapag LOOP
         v_tresult := i.ret;
      END LOOP;

      RETURN(v_tresult);
   END f_formapagorecibo;

   /***********************************************************************
          F_PER_CONTACTOS:  Retorna datos de contacto de una persona.
   **********************************************************************/
   -- Bug 17657 -RSC - 08/04/2011 -: MSGV101 - Creaci¿ i parametritzaci¿ producte Vida-Risc
   FUNCTION f_per_contactos(p_sperson IN NUMBER, p_tipcon IN NUMBER)
      RETURN VARCHAR2 IS
      error          NUMBER := 0;
      v_resultat     VARCHAR2(100);
   BEGIN
      BEGIN
         SELECT tvalcon
           INTO v_resultat
           FROM per_contactos
          WHERE sperson = p_sperson
            AND ctipcon = p_tipcon
            AND cmodcon = (SELECT MIN(cmodcon)
                             FROM per_contactos
                            WHERE sperson = p_sperson
                              AND ctipcon = p_tipcon);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            RETURN 104476;   -- Error al llegir de CONTACTOS
      END;

      RETURN v_resultat;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_per_contactos;

   FUNCTION f_per_contactos_est(p_sperson IN NUMBER, p_tipcon IN NUMBER)
      RETURN VARCHAR2 IS
      error          NUMBER := 0;
      v_resultat     VARCHAR2(100);
   BEGIN
      BEGIN
         SELECT tvalcon
           INTO v_resultat
           FROM estper_contactos
          WHERE sperson = p_sperson
            AND ctipcon = p_tipcon
            AND cmodcon = (SELECT MIN(cmodcon)
                             FROM estper_contactos
                            WHERE sperson = p_sperson
                              AND ctipcon = p_tipcon);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            RETURN 104476;   -- Error al llegir de CONTACTOS
      END;

      RETURN v_resultat;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_per_contactos_est;

-- Fin Bug 17657

   -- Bug 18712 - FAL - 11-04-2011
   /*************************************************************************
     FUNCTION f_respuesta
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     param in p_cpregun  : c¿digo de la pregunta
     param in p_cidioma  : c¿digo de idioma
     return              : texto
   *************************************************************************/
   FUNCTION f_respuesta(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cpregun IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          VARCHAR2(250);
   BEGIN
      BEGIN
         SELECT NVL(trespue, crespue)
           INTO v_ret
           FROM pregunseg p
          WHERE p.sseguro = p_sseguro
            AND p.nmovimi = p_nmovimi
            AND p.cpregun = p_cpregun;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT NVL(trespue,
                       (SELECT r.trespue
                          FROM respuestas r
                         WHERE r.crespue = p.crespue
                           AND r.cpregun = p.cpregun
                           AND r.cidioma = p_cidioma))
              INTO v_ret
              FROM pregunseg p
             WHERE p.sseguro = p_sseguro
               AND p.nmovimi = p_nmovimi
               AND p.cpregun = p_cpregun;
      END;

      -- BUG10134:08/06/2009:DRA:Inici
      v_ret := REPLACE(v_ret, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_respuesta;

   /*************************************************************************
     FUNCTION f_datos_asegurados
     param in p_sseguro  : c¿digo del seguro
     param in p_nriesgo  : c¿digo del riesgo
     param in p_cidioma  : c¿digo de idioma
     param in p_simul    : 1:proyecto / 0:emision
     param in p_mode     : POL' / 'EST'
     return              : texto
   *************************************************************************/
   FUNCTION f_datos_asegurados(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_idioma IN NUMBER DEFAULT 1,
      p_simul IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      wsperson       NUMBER;
      tresult        VARCHAR2(3000);
      wlitera        VARCHAR2(60);
      wtprofes       profesiones.tprofes%TYPE;
   BEGIN
      IF p_simul = 0 THEN
         FOR reg IN (SELECT sperson
                       FROM riesgos
                      WHERE sseguro = p_sseguro
                        AND nriesgo = p_nriesgo) LOOP
            -- 1 DNI, 2 Data Naixement , 3 Sexe , 4 nom, 5 cognoms , 6 pais, 7 nacionalitat, 8 tipus document
            wlitera := 'Nombre: ';
            tresult := wlitera || f_dades_persona(reg.sperson, 4);
            wlitera := 'Apellidos: ';
            tresult := tresult || '     ' || wlitera
                       || f_dades_persona(reg.sperson, 5, p_idioma);
            wlitera := 'DNI: ';
            tresult := tresult || '     ' || wlitera
                       || f_dades_persona(reg.sperson, 1, p_idioma);
            wlitera := 'F.Nacimiento: ';
            tresult := tresult || '     ' || wlitera
                       || f_dades_persona(reg.sperson, 2, p_idioma);
            wlitera := 'Sexo: ';
            tresult := tresult || '     ' || wlitera
                       || f_dades_persona(reg.sperson, 3, p_idioma);
            wlitera := 'Profesi¿n: ';

            BEGIN
               SELECT f.tprofes
                 INTO wtprofes
                 FROM per_detper p, profesiones f
                WHERE p.cprofes = f.cprofes
                  AND f.cidioma = p_idioma
                  AND p.sperson = reg.sperson;
            EXCEPTION
               WHEN OTHERS THEN
                  wtprofes := NULL;
            END;

            tresult := tresult || '     ' || wlitera || wtprofes;
         END LOOP;
      ELSIF p_simul = 1 THEN
         FOR reg IN (SELECT sperson
                       FROM estriesgos
                      WHERE sseguro = p_sseguro
                        AND nriesgo = p_nriesgo) LOOP
            wlitera := 'NIF/CIF: ';
            tresult := wlitera || f_dades_persona(reg.sperson, 1, p_idioma, 'EST');
            wlitera := 'Nombre y apellidos: ';
            tresult := tresult || '     ' || wlitera
                       || f_dades_persona(reg.sperson, 4, p_idioma, 'EST') || ' '
                       || f_dades_persona(reg.sperson, 5, p_idioma, 'EST');
            wlitera := 'F.Nacimiento: ';
            tresult := tresult || '     ' || wlitera
                       || f_dades_persona(reg.sperson, 2, p_idioma, 'EST');
            wlitera := 'Sexo: ';
            tresult := tresult || '     ' || wlitera
                       || f_dades_persona(reg.sperson, 3, p_idioma, 'EST');
         END LOOP;
      END IF;

      RETURN(tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_datos_asegurados;

   /*************************************************************************
     FUNCTION f_nacimconduct
     param in p_sseguro  : c¿digo del seguro
     param in p_norden  : c¿digo del orden
     return              : texto
   *************************************************************************/
   FUNCTION f_nacimconduct(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2 IS
      fecha          VARCHAR2(10);
   BEGIN
      SELECT NVL(TO_CHAR(autconductores.fnacimi, 'DD/MM/YYYY'),
                 TO_CHAR(per_personas.fnacimi, 'DD/MM/YYYY'))
        INTO fecha
        FROM per_personas, autconductores
       WHERE per_personas.sperson(+) = autconductores.sperson
         AND autconductores.sseguro = psseguro
         AND autconductores.norden = pnorden;

      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   /*************************************************************************
     FUNCTION f_fcarnetconduct
     param in p_sseguro  : c¿digo del seguro
     param in p_norden  : c¿digo del orden
     return              : texto
   *************************************************************************/
   FUNCTION f_fcarnetconduct(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2 IS
      fecha          VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(autconductores.fcarnet, 'DD/MM/YYYY')
        INTO fecha
        FROM per_personas, autconductores
       WHERE per_personas.sperson(+) = autconductores.sperson
         AND autconductores.sseguro = psseguro
         AND autconductores.norden = pnorden;

      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   /*************************************************************************
     FUNCTION f_fcarnettomador
     param in p_sseguro  : c¿digo del seguro
     return              : texto
   *************************************************************************/
   FUNCTION f_fcarnettomador(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      fecha          VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(autconductores.fcarnet, 'DD/MM/YYYY')
        INTO fecha
        FROM per_personas, autconductores, tomadores
       WHERE per_personas.sperson = autconductores.sperson(+)
         AND per_personas.sperson = tomadores.sperson
         AND tomadores.sseguro = psseguro;

      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   /*************************************************************************
     FUNCTION f_direccion_conductor
     param in p_sseguro  : c¿digo del seguro
     param in p_norden  : c¿digo del orden
     return              : texto
   *************************************************************************/
   FUNCTION f_direccion_conductor(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2 IS
      vtdomici       per_direcciones.tdomici%TYPE;
      vtpoblac       poblaciones.tpoblac%TYPE;
      vcpostal       per_direcciones.cpostal%TYPE;
      v_direccion    VARCHAR2(150);
   BEGIN
      SELECT tdomici, tpoblac, cpostal
        INTO vtdomici, vtpoblac, vcpostal
        FROM per_direcciones d, poblaciones p, autconductores a
       WHERE a.sseguro = psseguro
         AND a.norden = pnorden
         AND a.sperson = d.sperson
         AND d.cdomici = 1
         AND d.cprovin = p.cprovin
         AND d.cpoblac = p.cpoblac;

      v_direccion := vtdomici;

      IF vcpostal IS NOT NULL
         AND v_direccion IS NOT NULL THEN
         v_direccion := v_direccion || ' - ' || vcpostal;
      ELSIF vcpostal IS NOT NULL
            AND v_direccion IS NULL THEN
         v_direccion := vcpostal;
      END IF;

      IF vtpoblac IS NOT NULL
         AND v_direccion IS NOT NULL THEN
         v_direccion := v_direccion || ' - ' || vtpoblac;
      ELSIF vtpoblac IS NOT NULL
            AND v_direccion IS NULL THEN
         v_direccion := vtpoblac;
      END IF;

      v_direccion := REPLACE(v_direccion, CHR(39), CHR(39) || CHR(39));
      RETURN v_direccion;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_direccion_conductor;

   /*************************************************************************
     FUNCTION f_respuesta
     param in p_sseguro  : c¿digo del seguro
     param in p_nmovimi  : c¿digo del movimiento
     param in p_cpregun  : c¿digo de la pregunta
     param in p_cidioma  : c¿digo de idioma
     return              : texto
   *************************************************************************/
   FUNCTION f_respuesta_pol(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cpregun IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          VARCHAR2(250);
   BEGIN
      BEGIN
         SELECT NVL(trespue, crespue)
           INTO v_ret
           FROM pregunpolseg p
          WHERE p.sseguro = p_sseguro
            AND p.nmovimi = p_nmovimi
            AND p.cpregun = p_cpregun;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT NVL(trespue,
                       (SELECT r.trespue
                          FROM respuestas r
                         WHERE r.crespue = p.crespue
                           AND r.cpregun = p.cpregun
                           AND r.cidioma = p_cidioma))
              INTO v_ret
              FROM pregunpolseg p
             WHERE p.sseguro = p_sseguro
               AND p.nmovimi = p_nmovimi
               AND p.cpregun = p_cpregun;
      END;

      -- BUG10134:08/06/2009:DRA:Inici
      v_ret := REPLACE(v_ret, CHR(39), CHR(39) || CHR(39));
      -- BUG10134:08/06/2009:DRA:Fi
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_respuesta_pol;

   /*************************************************************************
     FUNCTION f_requisits_m¿dics
     param in pfnacimi   : Data Naixement
     param in pCapital   : Capital assegurat
     return              : text: Retorna els requ¿sits m¿nims per aquesta edat i aquests capital.
   *************************************************************************/
   FUNCTION f_requisits_medics(pfnacimi DATE, pcapital IN NUMBER)
      RETURN VARCHAR IS
      v_salida       VARCHAR2(100) := 'QS';
      num_err        NUMBER;
      v_edad         NUMBER;
   BEGIN
--1.- Obtenemos lav_edad actuarial del asegurado:
      num_err := f_difdata(pfnacimi, f_sysdate, 2, 1, v_edad);

      IF pcapital >= 100001
         AND pcapital <= 150000
         AND v_edad >= 51 THEN
         v_salida := v_salida || ' + Q¿estionari m¿dic + LAB(A) + ECG + PE';
      ELSIF pcapital >= 150001
            AND pcapital <= 250000
            AND v_edad <= 50 THEN
         v_salida := v_salida || ' + Q¿estionari m¿dic';
      ELSIF pcapital >= 150001
            AND pcapital <= 250000
            AND v_edad >= 51 THEN
         v_salida := v_salida || ' + Q¿estionari m¿dic + LAB(A) + ECG + PE';
      ELSIF pcapital >= 250001
            AND pcapital <= 500000
            AND v_edad <= 50 THEN
         v_salida := v_salida || ' + Q¿estionari m¿dic + LAB(A) + ECG + PE';
      ELSIF pcapital >= 250001
            AND pcapital <= 500000
            AND v_edad >= 51 THEN
         v_salida := v_salida || ' + Q¿estionari m¿dic + LAB(A) + LAB(B) + ECG + PE';
      ELSIF pcapital >= 500001
            AND pcapital <= 1000000 THEN
         v_salida := v_salida || ' + LAB(A) + LAB(B) + EM + ECG + PE';
      ELSIF pcapital >= 1000001 THEN
         v_salida := v_salida || ' + LAB(A) + LAB(B) + EM + ECG + PE + ECOCARDIOGRAMA';
      END IF;

      RETURN v_salida;
   END f_requisits_medics;

-- Fi Bug 18712

   --ETM INI BUG--18606
/*************************************************************************
     FUNCTION f_import_garantias
    param in p_sseguro  : c¿digo del seguro
     param in pcidioma  : c¿digo de idioma
     param in pnriesgo  : riesgo
     param in pnrecibo   : recibo
     param in pconcept  :concepto
     param in ptotal    : 0 si no queremos el total del importe de todas garantias
     return              : number devuelve el importe de los diferentes conceptos(prima, isi...)
  *****************************************************************************/
   FUNCTION f_import_garantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pnrecibo IN NUMBER,
      pconcept IN NUMBER,
      ptotal IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(1000) := '';
      v_retval       NUMBER;
      v_valpar       NUMBER;
      v_iconcep      NUMBER;
      v_sum          NUMBER := 0;
   BEGIN
      FOR reg IN (SELECT   se.cramo, se.cmodali, se.ctipseg, se.ccolect,
                           pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo) cactivi,
                           g.cgarant
                      FROM garangen g, garanpro p, garanseg s, seguros se
                     WHERE g.cgarant = s.cgarant
                       AND p.cgarant = s.cgarant
                       AND g.cidioma = pcidioma
                       AND p.sproduc = se.sproduc
                       AND p.cactivi = pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo)
                       AND s.sseguro = se.sseguro
                       AND s.nriesgo = NVL(pnriesgo, 1)
                       AND s.ffinefe IS NULL
                       AND se.sseguro = psseguro
                  ORDER BY DECODE(g.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC) LOOP
         v_retval := f_pargaranpro(reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                   reg.cactivi, reg.cgarant, 'VISIBLEDOCUM', v_valpar);

         IF NVL(v_valpar, 1) = 1 THEN
            SELECT SUM(iconcep)
              INTO v_iconcep
              FROM detrecibos d
             WHERE nrecibo = pnrecibo
               AND cgarant = reg.cgarant
               AND cconcep = pconcept;

            IF ptotal = 0 THEN
               v_cadena := v_cadena || TO_CHAR(v_iconcep, 'FM999G999G990D00') || '\par ';
            ELSE
               v_sum := v_sum + v_iconcep;
               v_cadena := TO_CHAR(v_sum, 'FM999G999G990D00');
            END IF;
         END IF;
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_import_garantias;

/*************************************************************************
     FUNCTION  f_total_import_garantias
    param in p_sseguro  : c¿digo del seguro
     param in pcidioma  : c¿digo de idioma
     param in pnriesgo  : riesgo
     param in pnrecibo   : recibo
     param in ptotal    : 0 si no queremos el total del importe de todas garantias
    return              : number devuelve el total del importe de los diferentes conceptos(prima, isi...)
  *****************************************************************************/
   FUNCTION f_total_import_garantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pnrecibo IN NUMBER,
      ptotal IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(1000) := '';
      v_retval       NUMBER;
      v_valpar       NUMBER;
      v_iconcep      NUMBER;
      v_sum          NUMBER := 0;
   BEGIN
      FOR reg IN (SELECT   se.cramo, se.cmodali, se.ctipseg, se.ccolect,
                           pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo) cactivi,
                           g.cgarant
                      FROM garangen g, garanpro p, garanseg s, seguros se
                     WHERE g.cgarant = s.cgarant
                       AND p.cgarant = s.cgarant
                       AND g.cidioma = pcidioma
                       AND p.sproduc = se.sproduc
                       AND p.cactivi = pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo)
                       AND s.sseguro = se.sseguro
                       AND s.nriesgo = NVL(pnriesgo, 1)
                       AND s.ffinefe IS NULL
                       AND se.sseguro = psseguro
                  ORDER BY DECODE(g.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC) LOOP
         v_retval := f_pargaranpro(reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                   reg.cactivi, reg.cgarant, 'VISIBLEDOCUM', v_valpar);

         IF NVL(v_valpar, 1) = 1 THEN
            SELECT SUM(iconcep)
              INTO v_iconcep
              FROM detrecibos d
             WHERE nrecibo = pnrecibo
               AND cgarant = reg.cgarant
               AND cconcep IN(4, 0);

            IF ptotal = 0 THEN
               v_cadena := v_cadena || TO_CHAR(v_iconcep, 'FM999G999G990D00') || '\par ';
            ELSE
               v_sum := v_sum + v_iconcep;
               v_cadena := TO_CHAR(v_sum, 'FM999G999G990D00');
            END IF;
         END IF;
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_total_import_garantias;

    /*************************************************************************
      FUNCTION  f_import_comis_garantias
     param in p_sseguro  : c¿digo del seguro
      param in pcidioma  : c¿digo de idioma
      param in pnriesgo  : riesgo
      param in pnrecibo   : recibo
      param in ptotal    : 0 comision de garantias
     return              : number devuelve el importe comision de las garantias
   *****************************************************************************/
   FUNCTION f_import_comis_garantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pnrecibo IN NUMBER,
      ptotal IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(1000) := '';
      v_retval       NUMBER;
      v_valpar       NUMBER;
      v_iconcep      NUMBER;
      v_iconcep_prima NUMBER;
      v_iconcep_comisi NUMBER;
      v_sum          NUMBER := 0;
   BEGIN
      FOR reg IN (SELECT   se.cramo, se.cmodali, se.ctipseg, se.ccolect,
                           pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo) cactivi,
                           g.cgarant
                      FROM garangen g, garanpro p, garanseg s, seguros se
                     WHERE g.cgarant = s.cgarant
                       AND p.cgarant = s.cgarant
                       AND g.cidioma = pcidioma
                       AND p.sproduc = se.sproduc
                       AND p.cactivi = pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo)
                       AND s.sseguro = se.sseguro
                       AND s.nriesgo = NVL(pnriesgo, 1)
                       AND s.ffinefe IS NULL
                       AND se.sseguro = psseguro
                  ORDER BY DECODE(g.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC) LOOP
         v_retval := f_pargaranpro(reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                   reg.cactivi, reg.cgarant, 'VISIBLEDOCUM', v_valpar);

         IF NVL(v_valpar, 1) = 1 THEN
            SELECT SUM(iconcep)
              INTO v_iconcep_comisi
              FROM detrecibos d
             WHERE nrecibo = pnrecibo
               AND cgarant = reg.cgarant
               AND cconcep = 11;

            SELECT SUM(iconcep)
              INTO v_iconcep_prima
              FROM detrecibos d
             WHERE nrecibo = pnrecibo
               AND cgarant = reg.cgarant
               AND cconcep = 0;

            IF ptotal = 0 THEN
               v_cadena := v_cadena
                           || TO_CHAR(ROUND((v_iconcep_comisi / v_iconcep_prima) * 100, 2),
                                      'FM999G999G990D00')
                           || '\par ';
            ELSE
               v_sum := v_sum + ROUND((v_iconcep_comisi / v_iconcep_prima) * 100, 2);
               v_cadena := TO_CHAR(v_sum, 'FM999G999G990D00');
            END IF;
         END IF;
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_import_comis_garantias;

       /*************************************************************************
      FUNCTION  f_import_liquidar_garantias
     param in p_sseguro  : c¿digo del seguro
      param in pcidioma  : c¿digo de idioma
      param in pnriesgo  : riesgo
      param in pnrecibo   : recibo
      param in ptotal    : 0 comision de garantias
     return              : number devuelve el importe a liquidar de las garantias
   *****************************************************************************/
   FUNCTION f_import_liquidar_garantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pnrecibo IN NUMBER,
      ptotal IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(1000) := '';
      v_retval       NUMBER;
      v_valpar       NUMBER;
      v_iconcep      NUMBER;
      v_iconcep_comis NUMBER;
      v_sum          NUMBER := 0;
   BEGIN
      FOR reg IN (SELECT   se.cramo, se.cmodali, se.ctipseg, se.ccolect,
                           pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo) cactivi,
                           g.cgarant
                      FROM garangen g, garanpro p, garanseg s, seguros se
                     WHERE g.cgarant = s.cgarant
                       AND p.cgarant = s.cgarant
                       AND g.cidioma = pcidioma
                       AND p.sproduc = se.sproduc
                       AND p.cactivi = pac_seguros.ff_get_actividad(se.sseguro, s.nriesgo)
                       AND s.sseguro = se.sseguro
                       AND s.nriesgo = NVL(pnriesgo, 1)
                       AND s.ffinefe IS NULL
                       AND se.sseguro = psseguro
                  ORDER BY DECODE(g.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC) LOOP
         v_retval := f_pargaranpro(reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                   reg.cactivi, reg.cgarant, 'VISIBLEDOCUM', v_valpar);

         IF NVL(v_valpar, 1) = 1 THEN
            SELECT SUM(iconcep)
              INTO v_iconcep
              FROM detrecibos d
             WHERE nrecibo = pnrecibo
               AND cgarant = reg.cgarant
               AND cconcep IN(4, 0);

            SELECT SUM(iconcep)
              INTO v_iconcep_comis
              FROM detrecibos d
             WHERE nrecibo = pnrecibo
               AND cgarant = reg.cgarant
               AND cconcep = 11;

            IF ptotal = 0 THEN
               v_cadena := v_cadena
                           || TO_CHAR((v_iconcep - v_iconcep_comis), 'FM999G999G990D00')
                           || '\par ';
            ELSE
               v_sum := v_sum +(v_iconcep - v_iconcep_comis);
               v_cadena := TO_CHAR(v_sum, 'FM999G999G990D00');
            END IF;
         END IF;
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_import_liquidar_garantias;

   --ETM FIN BUG --

   --bug 18835--etm--ini
   FUNCTION f_fefecto_recibo(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_fecha        VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(r.fefecto, 'dd/mm/yyyy')
        INTO v_fecha
        FROM seguros s, recibos r
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.ctiprec = 0
         AND r.nmovimi = f_max_nmovimi(s.sseguro);

      RETURN(v_fecha);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_fefecto_recibo;

   FUNCTION f_fvencim_recibo(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_fecha        VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(r.fvencim - 1, 'dd/mm/yyyy')
        INTO v_fecha
        FROM seguros s, recibos r
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.ctiprec = 0
         AND r.nmovimi = f_max_nmovimi(s.sseguro);

      RETURN(v_fecha);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_fvencim_recibo;

--bug 18835--etm--ini

   /*****************************************************************
    F_DESCSUPLEMENTOS: Retorna los suplementos
    param p_sseguro IN  : sseguro
    param p_nriesgo IN  : numero de riesgo
    param p_cidioma IN  : idioma
    param pctipo IN : 1 - Descripcion suplementos 2- Estado anterior 3-Estado actual
    return              : VARCHAR2

     Bug 18874/89912 - 18/07/2011- AMC
   ******************************************************************/
   FUNCTION f_descsuplementos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcidioma IN NUMBER,
      pctipo IN NUMBER)
      RETURN VARCHAR2 IS
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_tlinia       VARCHAR2(1000);
      v_motmov       VARCHAR2(500);
      v_tvalora      VARCHAR2(1000);
      v_tvalord      VARCHAR2(1000);
      v_valor        VARCHAR2(500);
      --
      v_nmovimi      NUMBER;
      v_cmotmov      NUMBER;
   BEGIN
      IF pctipo = 1 THEN
         v_tconsulta := 'select distinct m.tmotmov, s.FESTSUP,s.nmovimi,s.cmotmov ';
         v_tconsulta := v_tconsulta || ' from sup_solicitud s,motmovseg m ';
         v_tconsulta := v_tconsulta || ' where s.SSEGURO = ' || psseguro;
         --   v_tconsulta := v_tconsulta || ' and s.NRIESGO = ' || pnriesgo;
         v_tconsulta := v_tconsulta || ' and s.CESTSUP = 0';
         v_tconsulta := v_tconsulta || ' and s.cmotmov = m.cmotmov ';
         v_tconsulta := v_tconsulta || ' and m.cidioma =' || pcidioma;
         v_tconsulta := v_tconsulta || ' order by s.nmovimi,s.cmotmov ';

         OPEN vr_cursor FOR v_tconsulta;

         LOOP
            FETCH vr_cursor
             INTO v_motmov, v_valor, v_nmovimi, v_cmotmov;

            EXIT WHEN vr_cursor%NOTFOUND;

            IF v_motmov IS NOT NULL THEN
               v_tresult := v_tresult || v_motmov || ' ' || v_valor || '\par ';
            ELSE
               v_tresult := v_tresult || '\par ';
            END IF;
         END LOOP;
      ELSIF pctipo = 2 THEN
         v_tconsulta := 'select s.tvalora ,s.nmovimi,s.cmotmov  ';
         v_tconsulta := v_tconsulta || ' from sup_solicitud s ';
         v_tconsulta := v_tconsulta || ' where s.SSEGURO = ' || psseguro;
         --  v_tconsulta := v_tconsulta || ' and s.NRIESGO = ' || pnriesgo;
         v_tconsulta := v_tconsulta || ' and s.CESTSUP = 0';
         v_tconsulta := v_tconsulta || ' order by s.nmovimi,s.cmotmov ';

         OPEN vr_cursor FOR v_tconsulta;

         LOOP
            FETCH vr_cursor
             INTO v_tvalora, v_nmovimi, v_cmotmov;

            EXIT WHEN vr_cursor%NOTFOUND;

            IF v_tvalora IS NOT NULL THEN
               v_tresult := v_tresult || v_tvalora || '\par ';
            ELSE
               v_tresult := v_tresult || '\par ';
            END IF;
         END LOOP;
      ELSIF pctipo = 3 THEN
         v_tconsulta := 'select s.tvalord ,s.nmovimi,s.cmotmov  ';
         v_tconsulta := v_tconsulta || ' from sup_solicitud s ';
         v_tconsulta := v_tconsulta || ' where s.SSEGURO = ' || psseguro;
         --   v_tconsulta := v_tconsulta || ' and s.NRIESGO = ' || pnriesgo;
         v_tconsulta := v_tconsulta || ' and s.CESTSUP = 0';
         v_tconsulta := v_tconsulta || ' order by s.nmovimi,s.cmotmov ';

         OPEN vr_cursor FOR v_tconsulta;

         LOOP
            FETCH vr_cursor
             INTO v_tvalord, v_nmovimi, v_cmotmov;

            EXIT WHEN vr_cursor%NOTFOUND;

            IF v_tvalord IS NOT NULL THEN
               v_tresult := v_tresult || v_tvalord || '\par ';
            ELSE
               v_tresult := v_tresult || '\par ';
            END IF;
         END LOOP;
      ELSIF pctipo = 11 THEN
         v_tconsulta := 'select distinct m.tmotmov, s.nmovimi,s.cmotmov ';
         v_tconsulta := v_tconsulta || ' from detmovseguro s,motmovseg m ';
         v_tconsulta := v_tconsulta || ' where s.SSEGURO = ' || psseguro;
         --   v_tconsulta := v_tconsulta || ' and s.NRIESGO = ' || pnriesgo;
         --   v_tconsulta := v_tconsulta || ' and s.CESTSUP = 0';
         v_tconsulta := v_tconsulta
                        || ' and s.nmovimi = pac_isqlfor.f_max_nmovimi(s.sseguro) ';
         v_tconsulta := v_tconsulta || ' and s.cmotmov = m.cmotmov ';
         v_tconsulta := v_tconsulta || ' and m.cidioma =' || pcidioma;
         v_tconsulta := v_tconsulta || ' order by s.nmovimi,s.cmotmov ';

         OPEN vr_cursor FOR v_tconsulta;

         LOOP
            FETCH vr_cursor
             INTO v_motmov, v_nmovimi, v_cmotmov;

            EXIT WHEN vr_cursor%NOTFOUND;

            IF v_motmov IS NOT NULL THEN
               v_tresult := v_tresult || v_motmov || '\par ';
            ELSE
               v_tresult := v_tresult || '\par ';
            END IF;
         END LOOP;
      ELSIF pctipo = 21 THEN
         v_tconsulta := 'select s.tvalora ,s.nmovimi,s.cmotmov  ';
         v_tconsulta := v_tconsulta || ' from detmovseguro s ';
         v_tconsulta := v_tconsulta || ' where s.SSEGURO = ' || psseguro;
         --  v_tconsulta := v_tconsulta || ' and s.NRIESGO = ' || pnriesgo;
         --  v_tconsulta := v_tconsulta || ' and s.CESTSUP = 0';
         v_tconsulta := v_tconsulta
                        || ' and s.nmovimi = pac_isqlfor.f_max_nmovimi(s.sseguro) ';
         v_tconsulta := v_tconsulta || ' order by s.nmovimi,s.cmotmov ';

         OPEN vr_cursor FOR v_tconsulta;

         LOOP
            FETCH vr_cursor
             INTO v_tvalora, v_nmovimi, v_cmotmov;

            EXIT WHEN vr_cursor%NOTFOUND;

            IF v_tvalora IS NOT NULL THEN
               v_tresult := v_tresult || v_tvalora || '\par ';
            ELSE
               v_tresult := v_tresult || '\par ';
            END IF;
         END LOOP;
      ELSIF pctipo = 31 THEN
         v_tconsulta := 'select s.tvalord ,s.nmovimi,s.cmotmov  ';
         v_tconsulta := v_tconsulta || ' from detmovseguro s ';
         v_tconsulta := v_tconsulta || ' where s.SSEGURO = ' || psseguro;
         --   v_tconsulta := v_tconsulta || ' and s.NRIESGO = ' || pnriesgo;
         --   v_tconsulta := v_tconsulta || ' and s.CESTSUP = 0';
         v_tconsulta := v_tconsulta
                        || ' and s.nmovimi = pac_isqlfor.f_max_nmovimi(s.sseguro) ';
         v_tconsulta := v_tconsulta || ' order by s.nmovimi,s.cmotmov ';

         OPEN vr_cursor FOR v_tconsulta;

         LOOP
            FETCH vr_cursor
             INTO v_tvalord, v_nmovimi, v_cmotmov;

            EXIT WHEN vr_cursor%NOTFOUND;

            IF v_tvalord IS NOT NULL THEN
               v_tresult := v_tresult || v_tvalord || '\par ';
            ELSE
               v_tresult := v_tresult || '\par ';
            END IF;
         END LOOP;
      END IF;

      RETURN(v_tresult);
   END f_descsuplementos;

   /*************************************************************************
    FUNCTION f_conreb_unifi
    Recupera los diferentes importes de un recibo teniendo en cuenta si est¿ unificado
    param in pnrecibo   : n¿mero de recibo
    param in pcampo     : n¿mero de campo que se quiere recuperar
    return             : importe del campo requerido
    *************************************************************************/
   FUNCTION f_conreb_unifi(pnrecibo IN NUMBER, pcampo IN NUMBER)
      RETURN VARCHAR2 IS
      v_itotalr      NUMBER(15, 2);
      v_ifng         NUMBER(15, 2);
      v_iprinet      NUMBER(15, 2);
      v_iips         NUMBER(15, 2);
      v_itotpri      NUMBER(15, 2);
      v_irecfra      NUMBER(15, 2);
      v_formateado   VARCHAR2(100);
   BEGIN
      SELECT SUM(itotalr) itotalr, SUM(ifng) ifng, SUM(iips) ips, SUM(itotpri) itotpri,
             SUM(iprinet) iprinet, SUM(irecfra) irecfra
        INTO v_itotalr, v_ifng, v_iips, v_itotpri,
             v_iprinet, v_irecfra
        FROM vdetrecibos v
       WHERE nrecibo IN(SELECT nrecunif
                          FROM adm_recunif
                         WHERE nrecibo = pnrecibo
                        UNION
                        SELECT nrecibo
                          FROM adm_recunif
                         WHERE nrecibo = pnrecibo
                        UNION
                        SELECT nrecibo
                          FROM recibos
                         WHERE nrecibo = pnrecibo
                        UNION
                        SELECT nrecibo
                          FROM adm_recunif
                         WHERE nrecibo IN(SELECT nrecibo
                                            FROM adm_recunif
                                           WHERE nrecunif = pnrecibo));

      IF pcampo = 1 THEN
         SELECT TO_CHAR(NVL(v_itotalr, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 2 THEN
         SELECT TO_CHAR(NVL(v_iprinet, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 3 THEN
         SELECT TO_CHAR(NVL(v_iips, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 4 THEN
         SELECT TO_CHAR(NVL(v_ifng, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 5 THEN
         SELECT TO_CHAR(NVL(v_itotpri, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      ELSIF pcampo = 6 THEN
         SELECT TO_CHAR(NVL(v_irecfra, 0), 'FM999G999G999G990D00')
           INTO v_formateado
           FROM DUAL;

         RETURN v_formateado;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_conreb_unifi;

    /*************************************************************************
     FUNCTION f_docs_sini
     param in p_nsinies  : c¿digo del siniestro
     param in p_cidioma  : c¿digo de idioma
     return              : texto
   *************************************************************************/
   FUNCTION f_docs_sini(p_nsinies IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_ret          VARCHAR2(2000);
      v_temp         VARCHAR2(2000);
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      v_ccausin      NUMBER;
      v_cmotsin      NUMBER;
   BEGIN
      SELECT s.sproduc, s.cactivi, ss.ccausin, ss.cmotsin
        INTO v_sproduc, v_cactivi, v_ccausin, v_cmotsin
        FROM seguros s, sin_siniestro ss
       WHERE ss.sseguro = s.sseguro
         AND ss.nsinies = p_nsinies;

      FOR i IN (SELECT dd.tdocume
                  FROM doc_pro_documento dpd, doc_desdocumento dd
                 WHERE dpd.sproduc = v_sproduc
                   AND dpd.cactivi = v_cactivi
                   AND dpd.ccausin = v_ccausin
                   AND dpd.cmotsin = v_cmotsin
                   AND dpd.cmodul = 1   -- Siniestros
                   AND dpd.cobliga = 1   --obligatorio
                   AND dpd.cdocume = dd.cdocume
                   AND dd.cidioma = p_cidioma
                UNION
                SELECT dd.tdocume
                  FROM doc_pro_documento dpd, doc_desdocumento dd
                 WHERE dpd.sproduc = v_sproduc
                   AND dpd.cactivi = 0
                   AND dpd.cobliga = 1   --obligatorio
                   AND NOT EXISTS(SELECT 1
                                    FROM doc_pro_documento
                                   WHERE sproduc = dpd.sproduc
                                     AND cactivi = v_cactivi
                                     AND cdocume = dpd.cdocume
                                     AND cmodul = dpd.cmodul)
                   AND dpd.ccausin = v_ccausin
                   AND dpd.cmotsin = v_cmotsin
                   AND dpd.cmodul = 1   -- Siniestros
                   AND dpd.cdocume = dd.cdocume
                   AND dd.cidioma = p_cidioma
                UNION
                SELECT   d.ttitdoc
                    FROM sin_tramita_documento s, doc_desdocumento d
                   WHERE s.cdocume = d.cdocume
                     AND d.cidioma = p_cidioma
                     AND nsinies = p_nsinies
                GROUP BY ttitdoc) LOOP
         v_temp := i.tdocume;
         v_ret := v_ret || ' \par ' || v_temp;
      END LOOP;

      v_ret := REPLACE(v_ret, CHR(39), CHR(39) || CHR(39));
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_docs_sini;

    /*************************************************************************
     FUNCTION f_declarante
     param in p_nsinies  : c¿digo del siniestro
     return              : texto

     Bug 19389/91837 - 07/09/2011 - AMC
   *************************************************************************/
   FUNCTION f_declarante(p_nsinies IN NUMBER)
      RETURN VARCHAR2 IS
      vdec_sperson   NUMBER;
      vtnomdec       VARCHAR2(60);
      vtape1dec      VARCHAR2(60);
      vtape2dec      VARCHAR2(60);
      vnnumide       VARCHAR2(100);
      vdeclarante    VARCHAR2(300);
   BEGIN
      SELECT dec_sperson, tnomdec, tape1dec, tape2dec, nnumide
        INTO vdec_sperson, vtnomdec, vtape1dec, vtape2dec, vnnumide
        FROM sin_siniestro
       WHERE nsinies = p_nsinies;

      IF vtnomdec IS NOT NULL THEN
         vdeclarante := vnnumide || ',' || vtnomdec || ' ' || vtape1dec || ' ' || vtape2dec;
      ELSE
         IF vdec_sperson IS NOT NULL THEN
            vdeclarante := f_nombre(vdec_sperson, 2);
         END IF;
      END IF;

      RETURN vdeclarante;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_declarante;

   -- BUG18682:DRA:04/07/2011:Inici
   /*****************************************************************
    F_RESP_RIE: Retorna la resposta de les preguntes de tots els riscos
    param p_sseguro IN        : sseguro
    param p_cpregum IN        : codi pregunta
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_resp_rie(
      p_sseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_cpregun      NUMBER;
      v_crespue      NUMBER;
      v_sproduc      NUMBER;
      v_trespue      VARCHAR2(500);
      v_numerr       NUMBER;
      v_ctippre      codipregun.ctippre%TYPE;
      v_npoliza      NUMBER;
      v_cagente      NUMBER;
   BEGIN
      -- BUG26501 - 21/01/2014 - JTT
      SELECT npoliza, cagente
        INTO v_npoliza, v_cagente
        FROM (SELECT npoliza, cagente
                FROM estseguros
               WHERE sseguro = p_sseguro
                 AND p_mode = 'EST'
              UNION ALL
              SELECT npoliza, cagente
                FROM seguros
               WHERE sseguro = p_sseguro
                 AND NVL(p_mode, 'POL') <> 'EST');

      -- Fi BUG26501
      v_tconsulta := 'SELECT p.cpregun, cp.ctippre, p.crespue, p.trespue, s.sproduc ';
      v_tconsulta := v_tconsulta || ' FROM codipregun cp';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ', estpregunseg p, estseguros s';
      ELSE
         v_tconsulta := v_tconsulta || ', pregunseg p, seguros s';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE s.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND p.sseguro = s.sseguro';
      v_tconsulta := v_tconsulta || ' AND p.nriesgo = ' || NVL(TO_CHAR(p_nriesgo), 'p.nriesgo');
      v_tconsulta := v_tconsulta || ' AND p.cpregun = ' || p_cpregun;
      v_tconsulta := v_tconsulta || ' AND p.nmovimi = ' || NVL(p_nmovimi, 1);
      v_tconsulta := v_tconsulta || ' AND cp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' ORDER BY p.nriesgo';

      --      END IF;  Bug 11006 - 07/09/2009 - ASN
      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_cpregun, v_ctippre, v_crespue, v_trespue, v_sproduc;

         IF v_ctippre IN(3, 4, 5) THEN
            v_trespue := NVL(v_trespue, TO_CHAR(v_crespue, 'FM999G999G999G990D00'));
         ELSE
            -- BUG26501 - 21/01/2014 - JTT: Passem el npoliza
            v_numerr := pac_productos.f_get_pregunrespue(v_sproduc, v_cpregun, v_crespue,
                                                         p_cidioma, v_trespue, v_npoliza,
                                                         v_cagente);
         END IF;

         IF v_numerr <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_ISQLFOR.f_resp_rie', 1, v_numerr,
                        'Params: ' || ' - ' || v_cpregun || ' - ' || v_crespue || ' - '
                        || v_sproduc);
         END IF;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || v_trespue || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_resp_rie;

   -- BUG18682:DRA:04/07/2011:Inici
   /*****************************************************************
    F_RESP_RIE_MDEC: Retorna la resposta de les preguntes de tots els riscos, mascara de format amb 10 decimals
    param p_sseguro IN        : sseguro
    param p_cpregum IN        : codi pregunta
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_resp_rie_mdec(
      p_sseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_cpregun      NUMBER;
      v_crespue      NUMBER;
      v_sproduc      NUMBER;
      v_trespue      VARCHAR2(500);
      v_numerr       NUMBER;
      v_ctippre      codipregun.ctippre%TYPE;
      v_npoliza      NUMBER;
      v_cagente      NUMBER;
   BEGIN
      -- BUG26501 - 21/01/2014 - JTT
      SELECT npoliza, cagente
        INTO v_npoliza, v_cagente
        FROM (SELECT npoliza, cagente
                FROM estseguros
               WHERE sseguro = p_sseguro
                 AND p_mode = 'EST'
              UNION ALL
              SELECT npoliza, cagente
                FROM seguros
               WHERE sseguro = p_sseguro
                 AND NVL(p_mode, 'POL') <> 'EST');

      -- Fi BUG26501
      v_tconsulta := 'SELECT p.cpregun, cp.ctippre, p.crespue, p.trespue, s.sproduc ';
      v_tconsulta := v_tconsulta || ' FROM codipregun cp';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ', estpregunseg p, estseguros s';
      ELSE
         v_tconsulta := v_tconsulta || ', pregunseg p, seguros s';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE s.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND p.sseguro = s.sseguro';
      v_tconsulta := v_tconsulta || ' AND p.nriesgo = ' || NVL(TO_CHAR(p_nriesgo), 'p.nriesgo');
      v_tconsulta := v_tconsulta || ' AND p.cpregun = ' || p_cpregun;
      v_tconsulta := v_tconsulta || ' AND p.nmovimi = ' || NVL(p_nmovimi, 1);
      v_tconsulta := v_tconsulta || ' AND cp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' ORDER BY p.nriesgo';

      --      END IF;  Bug 11006 - 07/09/2009 - ASN
      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_cpregun, v_ctippre, v_crespue, v_trespue, v_sproduc;

         IF v_ctippre IN(3, 4, 5) THEN
            v_trespue := NVL(v_trespue, TO_CHAR(v_crespue, 'FM999G999G999G990D0099999999'));
         ELSE
            -- BUG26501 - 21/01/2014 - JTT: Passem el parametre npoliza
            v_numerr := pac_productos.f_get_pregunrespue(v_sproduc, v_cpregun, v_crespue,
                                                         p_cidioma, v_trespue, v_npoliza,
                                                         v_cagente);
         END IF;

         IF v_numerr <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_ISQLFOR.f_resp_rie', 1, v_numerr,
                        'Params: ' || ' - ' || v_cpregun || ' - ' || v_crespue || ' - '
                        || v_sproduc);
         END IF;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || v_trespue || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_resp_rie_mdec;

   /*****************************************************************
    F_CAP_RIE: Retorna el capital assegurat de tots els riscos
    param p_sseguro IN        : sseguro
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_cap_rie(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL',
      p_columna IN VARCHAR2 DEFAULT 'ICAPASE')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_tlinia       VARCHAR2(1000);
      v_orden        VARCHAR2(100);
      v_capital      NUMBER;
      v_iprianu      NUMBER;
      v_itarifa      NUMBER;
      v_itasa        NUMBER;
   BEGIN
      v_tconsulta := 'SELECT TO_CHAR(g.cgarant), g.icapital, g.iprianu, g.itarifa';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' FROM estgaranseg g';
      ELSE
         v_tconsulta := v_tconsulta || ' FROM garanseg g';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE g.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND g.nriesgo = ' || NVL(TO_CHAR(p_nriesgo), 'g.nriesgo');
      v_tconsulta := v_tconsulta || ' AND g.cgarant = ' || NVL(TO_CHAR(p_cgarant), 'g.cgarant');
      v_tconsulta := v_tconsulta || ' AND g.nmovimi = ' || p_nmovimi;
      v_tconsulta := v_tconsulta || ' ORDER BY g.nriesgo';

      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_orden, v_capital, v_iprianu, v_itarifa;

         EXIT WHEN vr_cursor%NOTFOUND;

         IF p_columna = 'ICAPASE' THEN
            IF v_capital IS NOT NULL THEN
               v_tresult := v_tresult || TO_CHAR(v_capital, 'FM999G999G999G990D00') || '\par ';
            ELSE
               v_tresult := v_tresult || '\par ';
            END IF;
         ELSIF p_columna = 'ITASA' THEN
            IF v_capital IS NOT NULL
               AND v_itarifa IS NOT NULL THEN
               v_itasa := (1 -(v_capital / v_itarifa)) * 100;
               v_tresult := v_tresult || TO_CHAR(v_itasa, 'FM999G999G999G990D00') || '\par ';
            ELSE
               v_tresult := v_tresult || '\par ';
            END IF;
         ELSIF p_columna = 'IPRINET' THEN
            IF v_iprianu IS NOT NULL THEN
               v_tresult := v_tresult || TO_CHAR(v_iprianu, 'FM999G999G999G990D00') || '\par ';
            ELSE
               v_tresult := v_tresult || '\par ';
            END IF;
         END IF;
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_cap_rie;

   /*****************************************************************
    F_CAP_TOT: Retorna la suma del capital assegurat de tots els riscos
    param p_sseguro IN        : sseguro
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_cap_tot(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL',
      p_columna IN VARCHAR2 DEFAULT 'ICAPASE')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_tlinia       VARCHAR2(1000);
      v_orden        VARCHAR2(100);
      v_capital      NUMBER;
      v_iprianu      NUMBER;
      v_itarifa      NUMBER;
      v_itasa        NUMBER;
      v_itotal       NUMBER := 0;
   BEGIN
      v_tconsulta := 'SELECT TO_CHAR(g.cgarant), g.icapital, g.iprianu, g.itarifa';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' FROM estgaranseg g';
      ELSE
         v_tconsulta := v_tconsulta || ' FROM garanseg g';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE g.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND g.nriesgo = ' || NVL(TO_CHAR(p_nriesgo), 'g.nriesgo');
      v_tconsulta := v_tconsulta || ' AND g.cgarant = ' || NVL(TO_CHAR(p_cgarant), 'g.cgarant');
      v_tconsulta := v_tconsulta || ' AND g.nmovimi = ' || p_nmovimi;
      v_tconsulta := v_tconsulta || ' ORDER BY g.nriesgo';

      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_orden, v_capital, v_iprianu, v_itarifa;

         EXIT WHEN vr_cursor%NOTFOUND;

         IF p_columna = 'ICAPASE' THEN
            v_itotal := v_itotal + NVL(v_capital, 0);
         ELSIF p_columna = 'ITASA' THEN
            v_itotal := v_itotal + NVL(v_itasa, 0);
         ELSIF p_columna = 'IPRINET' THEN
            v_itotal := v_itotal + NVL(v_iprianu, 0);
         END IF;
      END LOOP;

      v_tresult := TO_CHAR(v_itotal, 'FM999G999G999G990D00');
      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_cap_tot;

-- BUG18682:DRA:04/07/2011:Fi
    -- BUG 19322 - 28/09/2011 - JMP
   /*****************************************************************
    FUNCTION F_IUNIACT_FECHA:
      Calcula el valor unitari de les aportacions d'una asseguran¿a
      a una data determinada.

    param IN psseguro  : sseguro
    param IN pfecha    : data del valor
    return             : valor unitari de les aportacions
    ******************************************************************/
   FUNCTION f_iuniact_fecha(psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      v_ccesta       segdisin2.ccesta%TYPE;
      v_iuniact      tabvalces.iuniact%TYPE;
   BEGIN
      SELECT ccesta
        INTO v_ccesta
        FROM segdisin2
       WHERE sseguro = psseguro
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM segdisin2
                         WHERE sseguro = psseguro);

      SELECT NVL(iuniact, 0)
        INTO v_iuniact
        FROM tabvalces
       WHERE ccesta = v_ccesta
         AND fvalor = (SELECT MAX(fvalor)
                         FROM tabvalces
                        WHERE ccesta = v_ccesta
                          AND fvalor <= pfecha);

      RETURN v_iuniact;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_iuniact_fecha;

   /*****************************************************************
    FUNCTION F_SUMAPOR_TIPUS:
      Calcula la suma d'aportacions donats una asseguran¿a, un
      interval de dates i un tipus d'aportaci¿.

    param IN psseguro  : sseguro
    param IN pfecini   : data d'inici
    param IN pfecfin   : data de fi
    param IN pctipapor : tipus d'aportaci¿
                           E - Empresa
                           P - Part¿cep
    return             : suma d'aportacions
    ******************************************************************/
   FUNCTION f_sumapor_tipus(
      psseguro IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pctipapor IN VARCHAR2)
      RETURN NUMBER IS
      v_sum_unidades NUMBER;
   BEGIN
      SELECT SUM(NVL(nunidad, 0))
        INTO v_sum_unidades
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND(fvalmov >= pfecini
             OR pfecini IS NULL)
         AND fvalmov <= pfecfin
         AND((pctipapor = 'E'
              AND ctipapor IN('PR', 'SP', 'B'))
             OR(pctipapor = 'P'
                AND NVL(ctipapor, 'P') NOT IN('PR', 'SP', 'B'))
             OR pctipapor IS NULL)
         AND cesta IS NOT NULL
         AND nrecibo IS NOT NULL
         AND nsinies IS NULL;

      RETURN v_sum_unidades;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_sumapor_tipus;

   /*****************************************************************
    FUNCTION F_VALAPOR_TIPUS:
      Calcula el valor de les aportacions donats una asseguran¿a, un
      interval de dates i un tipus d'aportaci¿.

    param IN psseguro  : sseguro
    param IN pfecini   : data d'inici
    param IN pfecfin   : data de fi
    param IN pctipapor : tipus d'aportaci¿
                         E - Empresa
                         P - Part¿cep
    return             : valor de les aportacions
    ******************************************************************/
   FUNCTION f_valapor_tipus(
      psseguro IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pctipapor IN VARCHAR2)
      RETURN NUMBER IS
      v_sum_unidades NUMBER;
   BEGIN
      v_sum_unidades := f_sumapor_tipus(psseguro, pfecini, pfecfin, pctipapor);
      RETURN(v_sum_unidades * NVL(f_iuniact_fecha(psseguro, pfecfin), 0));
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_valapor_tipus;

   /*****************************************************************
    FUNCTION F_CALC_RENDIMENT:
      Calcula el rendiment de les aportacions d'una asseguran¿a a una
      data determinada

     param IN psseguro   : sseguro
     param IN pfecha     : data de c¿lcul
     param IN ptipo      : 1 - El rendiment es calcula sobre la suma
                               d'aportacions des de l'inici
                           2 - El rendiment es calcula sobre la suma
                               d'aportacions en un any
     param IN pctipapor  : tipus d'aportacions
                           E - Empresa
                           P - Part¿cep
     return              : rendiment
    ******************************************************************/
   FUNCTION f_calc_rendiment(
      psseguro IN NUMBER,
      pfecha IN DATE,
      ptipo IN NUMBER,
      pctipapor IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_fecini       DATE;
      v_fecfin       DATE;
      v_val_apor     NUMBER;
      v_val_apor_emp NUMBER;
      v_sum_apor     NUMBER;
      v_sum_apor_emp NUMBER;
      v_rendim       VARCHAR2(50);
   BEGIN
      IF ptipo = 1 THEN
         v_fecini := NULL;
         v_fecfin := pfecha;
      ELSE
         v_fecini := TO_DATE('01/01/' ||(TO_CHAR(pfecha, 'yyyy') - 1), 'dd/mm/yyyy');
         v_fecfin := TO_DATE('31/12/' ||(TO_CHAR(pfecha, 'yyyy') - 1), 'dd/mm/yyyy');
      END IF;

      v_sum_apor := TO_NUMBER(f_suma_aportacio(psseguro, v_fecini, v_fecfin, pctipapor),
                              'FM999G999G999G990D00');
      v_val_apor := f_valapor_tipus(psseguro, v_fecini, v_fecfin, pctipapor);
      v_rendim := TO_CHAR(NVL(((v_val_apor / v_sum_apor) - 1) * 100, 0), 'FM990D00') || ' %';
      RETURN v_rendim;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END f_calc_rendiment;

   /*****************************************************************
    FUNCTION f_get_riesgos
      Devuelve la naturaleza de los riesgos de la p¿liza

     param IN psseguro   : sseguro
     return              : rendiment

     Bug 19726/94425 - 11/10/2011 - AMC
    ******************************************************************/
   FUNCTION f_get_riesgos(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_tresult      VARCHAR2(32000) := '';
   BEGIN
      FOR cur IN (SELECT tnatrie
                    FROM riesgos
                   WHERE sseguro = psseguro) LOOP
         v_tresult := v_tresult || cur.tnatrie || '\par ';
      END LOOP;

      RETURN v_tresult;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END f_get_riesgos;

   /*****************************************************************
   FUNCTION f_get_sobreprecio
     Devuelve los sobreprecios

    param IN psseguro   : sseguro
    param IN p_cpregum  : codi pregunta
   param IN p_nmovimi  : numero moviment
   param IN p_idioma   : idioma
   param IN p_mode    : modo en que se llama
    return              : rendiment

    Bug 19726/94425 - 11/10/2011 - AMC
   ******************************************************************/
   FUNCTION f_get_sobreprecio(
      psseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_cpregun2 IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tresult      VARCHAR2(32000) := '';
      v_precio       VARCHAR2(10);
      vporcen        VARCHAR2(10);
   BEGIN
      -- % de sobreprecio
      SELECT resp.trespue
        INTO vporcen
        FROM pregunpolseg ps, respuestas resp
       WHERE ps.cpregun = p_cpregun2
         AND ps.sseguro = psseguro
         AND ps.nmovimi = p_nmovimi
         AND resp.cpregun = ps.cpregun
         AND resp.crespue = ps.crespue
         AND resp.cidioma = p_cidioma;

      vporcen := REPLACE(vporcen, '%');

      FOR cur IN (SELECT nriesgo
                    FROM riesgos
                   WHERE sseguro = psseguro) LOOP
         -- Precio seguro agrario
         v_precio := f_resp_rie_mdec(psseguro, p_cpregun, cur.nriesgo, p_nmovimi, p_cidioma,
                                     p_mode);
         v_precio := REPLACE(v_precio, '\par');
         v_tresult := v_tresult
                      || TO_CHAR((v_precio *(vporcen / 100)), 'FM999G999G999G990D00999')
                      || '\par ';
      END LOOP;

      RETURN v_tresult;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END f_get_sobreprecio;

   /*****************************************************************
    FUNCTION f_get_mediador


     param IN pcempres  : codigo de empresa
     param IN pcagente  : codi de agente
     param IN pmodo     : 1-Nombre padre 2-Tipo padre 3-Direcci¿n padre 4-Direcci¿n agente
                          5-email padre  6-telefono agente
     param IN pcidioma   : idioma
     return              : descripcion

     Bug 0019726 - MDS - 27/10/2011
    ******************************************************************/
   FUNCTION f_get_mediador(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pmodo IN NUMBER,
      pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      pctipage       NUMBER;
      pfbusca        DATE;
      pcpadre        NUMBER;
      vnumerr        NUMBER;
      vnombre        VARCHAR2(250);
      vsperson       NUMBER;
      vdomici        NUMBER;
   BEGIN
      --vnumerr := f_buscapadre(pcempres, pcagente, pctipage, pfbusca, pcpadre);

      -- la funci¿n anterior no es correcta, se modifica
      -- Bug 0019726 - MDS - 27/10/2011
      -- obtener el padre del agente, y su tipo
      SELECT cpadre, ctipage
        INTO pcpadre, pctipage
        FROM redcomercial
       WHERE cagente = pcagente
         AND cempres = pcempres
         AND fmovini <= f_sysdate
         AND(fmovfin > f_sysdate
             OR fmovfin IS NULL);

      --
      -- descripci¿n del agente padre
      IF pmodo = 1 THEN
         vnumerr := f_desagente(pcpadre, vnombre);

         IF vnumerr <> 0 THEN
            RETURN '';
         END IF;
      --
      -- descripci¿n del tipo padre
      ELSIF pmodo = 2 THEN
         BEGIN
            --Bug 20257
            SELECT pac_parametros.f_descdetparam('TIPAGENTE', pp.nvalpar, pcidioma)
              INTO vnombre
              FROM per_parpersonas pp
             WHERE pp.sperson = (SELECT sperson
                                   FROM agentes
                                  WHERE cagente = pcpadre)
               AND pp.cagente = (SELECT MIN(cagente)
                                   FROM per_parpersonas per
                                  WHERE per.sperson = pp.sperson)
               AND pp.cparam = 'TIPAGENTE';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnombre := NULL;
            WHEN OTHERS THEN
               vnombre := NULL;
         END;
      --
      -- direcci¿n del agente padre
      ELSIF pmodo = 3 THEN
         SELECT sperson, cdomici
           INTO vsperson, vdomici
           FROM agentes
          WHERE cagente = pcpadre;   -- agente padre

         vnombre := pac_isqlfor.f_direccion(vsperson, NVL(vdomici, 1));
      --
      -- direcci¿n del agente
      ELSIF pmodo = 4 THEN
         SELECT sperson, cdomici
           INTO vsperson, vdomici
           FROM agentes
          WHERE cagente = pcagente;   -- agente

         vnombre := pac_isqlfor.f_direccion(vsperson, NVL(vdomici, 1));
      --
      -- email del agente padre
      ELSIF pmodo = 5 THEN
         SELECT sperson, cdomici
           INTO vsperson, vdomici
           FROM agentes
          WHERE cagente = pcpadre;   -- agente padre

         vnombre := pac_isqlfor.f_per_contactos(vsperson, 3);
      --
      -- tel¿fono del agente
      ELSIF pmodo = 6 THEN
         SELECT sperson, cdomici
           INTO vsperson, vdomici
           FROM agentes
          WHERE cagente = pcagente;   -- agente

         vnombre := pac_isqlfor.f_per_contactos(vsperson, 1);
      --
      -- CIF del agente padre
      ELSIF pmodo = 7 THEN
         SELECT sperson, cdomici
           INTO vsperson, vdomici
           FROM agentes
          WHERE cagente = pcpadre;   -- agente padre

         vnombre := pac_isqlfor.f_dni(NULL, NULL, vsperson);
      END IF;

      RETURN vnombre;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END f_get_mediador;

   /*****************************************************************
   FUNCTION f_garantias_riesgo
     Devuelve las garant¿as de un riesgo

    param IN psseguro  : codigo de seguro
    param IN pnriesgo  : n¿mero de riesgo
    param IN pcidioma  : codigo de idioma
    param IN pmodo     : modo EST/POL
    return             : texto con las garant¿as del riesgo

    Bug 19780 - 21/10/2011 - JMP
   ******************************************************************/
   FUNCTION f_garantias_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pcidioma IN NUMBER DEFAULT 1,
      pmodo IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_tlinia       VARCHAR2(50);
      v_tpargar      VARCHAR2(200);
      v_tablaseg     VARCHAR2(30);
      v_act0         NUMBER(1);
      v_actividad    VARCHAR2(20);
   BEGIN
      -- BUG 16092 - 12/01/2011 - JMP - AGA RC: Miramos si las garant¿as est¿n definidas para la actividad del seguro
      IF NVL(pmodo, 'POL') = 'EST' THEN
         v_tablaseg := 'estseguros';
      ELSE
         v_tablaseg := 'seguros';
      END IF;

      v_tconsulta := 'BEGIN SELECT decode(count(*), 0, 1, 0)'
                     || ' INTO :v_act0 FROM garanpro gp, ' || v_tablaseg || ' s'
                     || ' WHERE s.sseguro = :psseguro AND gp.sproduc = s.sproduc'
                     || ' AND gp.cactivi = s.cactivi; END;';

      EXECUTE IMMEDIATE v_tconsulta
                  USING OUT v_act0, IN psseguro;

      IF v_act0 = 1 THEN
         v_actividad := '0';
      ELSE
         v_actividad := 'se.cactivi';
      END IF;

      -- Fin BUG 16092 - 12/01/2011 - JMP
      v_tconsulta := 'SELECT REPLACE(tgarant, CHR(39), CHR(39) || CHR(39)) a';
      v_tconsulta := v_tconsulta || ' FROM garangen g, garanpro p, ';

      IF NVL(pmodo, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || 'estgaranseg s, estseguros se';
      ELSE
         v_tconsulta := v_tconsulta || 'garanseg s, seguros se';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE g.cgarant = s.cgarant';
      v_tconsulta := v_tconsulta || ' AND p.cgarant = s.cgarant';
      v_tconsulta := v_tconsulta || ' AND p.sproduc = se.sproduc';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = se.sseguro';
      v_tconsulta := v_tconsulta || ' AND p.CACTIVI = ' || v_actividad;
      v_tconsulta := v_tconsulta || ' AND s.ffinefe IS NULL';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = ' || psseguro;
      v_tconsulta := v_tconsulta || ' AND g.cidioma = ' || NVL(pcidioma, 1);
      v_tconsulta := v_tconsulta || ' AND s.nriesgo = ' || pnriesgo;

      -- Bug 19020 - APD - 29/07/2011 - si pmode = EST
      --  s¿lo deben imprimirse las garant¿as seleccionadas
      IF NVL(pmodo, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' AND s.cobliga = 1';
      END IF;

      -- Fin Bug 19020 - APD - 29/07/2011
      /*      IF NVL(p_ntipsel, 1) = 1 THEN
               v_tconsulta := v_tconsulta || ' AND s.icapital IS NOT NULL';
               v_tconsulta :=
                  v_tconsulta
                  || ' ORDER BY DECODE(g.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC';
            ELSIF p_ntipsel = 3 THEN
               v_tconsulta := v_tconsulta || ' ORDER BY p.norden';
            ELSE
      */ -- Bug 11006 - 07/09/2009 - ASN - Se elimina el parametro p_ntipsel
      SELECT ' AND (NVL(pac_parametros.f_pargaranpro_n(' || sproduc || ', ' || cactivi
             --                || ', g.cgarant, ''GARANT_IMP''), 0) = 1 OR NVL(icapital, 0) > 0)' Bug 11006 07/09/2009 ASN
             || ', g.cgarant, ''GARANT_IMP''), 0) = 1 OR NVL(icapital, 0) > 0)'
        INTO v_tpargar
        FROM (SELECT seg.sproduc, seg.cactivi
                FROM seguros seg
               WHERE seg.sseguro = psseguro
              UNION
              SELECT seg.sproduc, seg.cactivi
                FROM estseguros seg
               WHERE seg.sseguro = psseguro);

      v_tconsulta := v_tconsulta || v_tpargar;
      v_tconsulta := v_tconsulta || ' ORDER BY p.norden';

      --      END IF;  Bug 11006 - 07/09/2009 - ASN
      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_tlinia;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || v_tlinia || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_garantias_riesgo;

   /*****************************************************************
   FUNCTION f_capitales_riesgo
     Devuelve los capitales de un riesgo

    param IN psseguro  : codigo de seguro
    param IN pnriesgo  : n¿mero de riesgo
    param IN pmodo     : modo EST/POL
    return             : texto con los capitales del riesgo

    Bug 19780 - 21/10/2011 - JMP
   ******************************************************************/
   FUNCTION f_capitales_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pmodo IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(4000);
      v_tlinia       VARCHAR2(50);
      v_tpargar      VARCHAR2(200);
      v_icapital     garanseg.icapital%TYPE;
      v_ctipcap      garanpro.ctipcap%TYPE;
      v_cimpres      garanpro.cimpres%TYPE;
      v_npargar      NUMBER := 0;
      v_tablaseg     VARCHAR2(30);
      v_act0         NUMBER(1);
      v_actividad    VARCHAR2(20);
   BEGIN
      -- BUG 16092 - 12/01/2011 - JMP - AGA RC: Miramos si las garant¿as est¿n definidas para la actividad del seguro
      IF NVL(pmodo, 'POL') = 'EST' THEN
         v_tablaseg := 'estseguros';
      ELSE
         v_tablaseg := 'seguros';
      END IF;

      v_tconsulta := 'BEGIN SELECT decode(count(*), 0, 1, 0)'
                     || ' INTO :v_act0 FROM garanpro gp, ' || v_tablaseg || ' s'
                     || ' WHERE s.sseguro = :psseguro AND gp.sproduc = s.sproduc'
                     || ' AND gp.cactivi = s.cactivi; END;';

      EXECUTE IMMEDIATE v_tconsulta
                  USING OUT v_act0, IN psseguro;

      IF v_act0 = 1 THEN
         v_actividad := '0';
      ELSE
         v_actividad := 'se.cactivi';
      END IF;

      -- Fin BUG 16092 - 12/01/2011 - JMP
      v_tconsulta :=

         --       'SELECT TO_CHAR(icapital, ''FM999G999G999G990D00'') || '' EUR'' a, s.icapital b, p.ctipcap c';          Bug 11006 - 07/09/2009 - ASN
         'SELECT TO_CHAR(icapital, ''FM999G999G999G990D00'') || '' EUR'' a, s.icapital b, p.ctipcap c, p.cimpres,'
         || ' NVL(pac_parametros.f_pargaranpro_n(p.sproduc,p.cactivi,g.cgarant,''GARANT_IMP''), 0)';
      v_tconsulta := v_tconsulta || ' FROM garangen g, garanpro p,';

      IF NVL(pmodo, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' estgaranseg s, estseguros se';
      ELSE
         v_tconsulta := v_tconsulta || ' garanseg s, seguros se';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE g.cgarant = s.cgarant';
      v_tconsulta := v_tconsulta || ' AND p.cgarant = s.cgarant';
      v_tconsulta := v_tconsulta || ' AND p.sproduc = se.sproduc';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = se.sseguro';
      v_tconsulta := v_tconsulta || ' AND p.cactivi = ' || v_actividad;
      v_tconsulta := v_tconsulta || ' AND s.ffinefe IS NULL';
      v_tconsulta := v_tconsulta || ' AND s.sseguro = ' || psseguro;
      v_tconsulta := v_tconsulta || ' AND g.cidioma = 1';
      v_tconsulta := v_tconsulta || ' AND s.nriesgo = ' || pnriesgo;

      -- Bug 19020 - APD - 29/07/2011 - si pmode = EST
      --  s¿lo deben imprimirse las garant¿as seleccionadas
      IF NVL(pmodo, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ' AND s.cobliga = 1';
      END IF;

      -- Fin Bug 19020 - APD - 29/07/2011
      /*      IF NVL(p_ntipsel, 1) = 1 THEN   -- BUG 9512
               v_tconsulta := v_tconsulta || ' AND s.icapital IS NOT NULL';
               v_tconsulta :=
                  v_tconsulta
                  || ' ORDER BY DECODE(p.cgarant, 1, 1, 80, 2, 10, 3, 87, 4), p.norden DESC';
            ELSIF p_ntipsel = 3 THEN
               v_tconsulta := v_tconsulta || ' ORDER BY p.norden';
            ELSE*/
      SELECT ' AND (NVL(pac_parametros.f_pargaranpro_n(' || sproduc || ', ' || cactivi
             || ', g.cgarant, ''GARANT_IMP''), 0) = 1 OR NVL(icapital, 0) > 0)'
        INTO v_tpargar
        FROM (SELECT seg.sproduc, seg.cactivi
                FROM seguros seg
               WHERE seg.sseguro = psseguro
              UNION
              SELECT seg.sproduc, seg.cactivi
                FROM estseguros seg
               WHERE seg.sseguro = psseguro);

      v_tconsulta := v_tconsulta || v_tpargar;
      v_tconsulta := v_tconsulta || ' ORDER BY p.norden';

      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_tlinia, v_icapital, v_ctipcap, v_cimpres, v_npargar;

         EXIT WHEN vr_cursor%NOTFOUND;

         IF v_npargar = 1 THEN
            SELECT tatribu
              INTO v_tlinia
              FROM detvalores
             WHERE cvalor = 126
               AND catribu = NVL(v_cimpres, 59)   -- INCLOSA
               AND cidioma = 1;
         END IF;

         v_tresult := v_tresult || v_tlinia || '\par ';
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_capitales_riesgo;

--------------------------------------------------------------------------------
   FUNCTION f_titgarantias_distinct(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pseparador IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
      v_cadena       VARCHAR2(1000) := '';
      v_retval       NUMBER;
      v_valpar       NUMBER;
   BEGIN
      --Bug 0019726 - MDS - 27/10/2011 - devolver todos los riesgos, mediante distinct
      FOR reg IN (SELECT DISTINCT REPLACE(g.tgarant, CHR(39), CHR(39) || CHR(39)) "TGARANT"
                             FROM garangen g, garanpro p, garanseg s, seguros se
                            WHERE g.cgarant = s.cgarant
                              AND p.cgarant = s.cgarant
                              AND g.cidioma = pcidioma
                              AND p.sproduc = se.sproduc
                              AND p.cactivi = pac_seguros.ff_get_actividad(se.sseguro,
                                                                           s.nriesgo)
                              AND s.sseguro = se.sseguro
                              AND s.ffinefe IS NULL
                              AND se.sseguro = psseguro) LOOP
         IF NVL(v_valpar, 1) = 1 THEN
            IF pseparador = 0 THEN
               v_cadena := v_cadena || reg.tgarant || '\par ';
            ELSE
               IF v_cadena IS NULL THEN
                  v_cadena := reg.tgarant;
               ELSE
                  v_cadena := v_cadena || ', ' || reg.tgarant;
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN v_cadena;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_titgarantias_distinct;

   /*****************************************************************
   FUNCTION f_get_sobreprecio_riesgo
     Devuelve el sobreprecio de un riesgo

    param IN psseguro   : sseguro
    param IN p_cpregum  : codigo pregunta
    param IN p_nmovimi  : numero movimiento
    param IN p_idioma   : idioma
    param IN p_mode     : modo en que se llama
    param IN p_nriesgo  : n¿mero de riesgo
    return              : sobreprecio

    Bug 21873 - 10/04/2012 - MDS
   ******************************************************************/
   FUNCTION f_get_sobreprecio_riesgo(
      psseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_cpregun2 IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2,
      p_nriesgo IN NUMBER)
      RETURN VARCHAR2 IS
      v_tresult      VARCHAR2(32000) := '';
      v_precio       VARCHAR2(10);
      vporcen        VARCHAR2(10);
   BEGIN
      -- % de sobreprecio
      SELECT resp.trespue
        INTO vporcen
        FROM pregunpolseg ps, respuestas resp
       WHERE ps.cpregun = p_cpregun2
         AND ps.sseguro = psseguro
         AND ps.nmovimi = p_nmovimi
         AND resp.cpregun = ps.cpregun
         AND resp.crespue = ps.crespue
         AND resp.cidioma = p_cidioma;

      vporcen := REPLACE(vporcen, '%');

      FOR cur IN (SELECT nriesgo
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = p_nriesgo) LOOP
         -- Precio seguro agrario
         v_precio := f_resp_rie_mdec(psseguro, p_cpregun, cur.nriesgo, p_nmovimi, p_cidioma,
                                     p_mode);
         v_precio := REPLACE(v_precio, '\par');
         v_tresult := v_tresult
                      || TO_CHAR((v_precio *(vporcen / 100)), 'FM999G999G999G990D00999')
                      || '\par ';
      END LOOP;

      RETURN v_tresult;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END f_get_sobreprecio_riesgo;

   /*****************************************************************
   FUNCTION ff_numlet

    Funci¿n que llama F_NUMLET (para que devuelva directamente el importe en letras)

    Bug 21873 - 10/04/2012 - MDS
   ******************************************************************/
   FUNCTION ff_numlet(nidioma IN NUMBER, np_nume IN NUMBER, moneda IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_error        NUMBER;
      v_numeroenletras VARCHAR2(1000);
   BEGIN
      v_error := f_numlet(nidioma, np_nume, moneda, v_numeroenletras);
      RETURN v_numeroenletras;
   END ff_numlet;

   /*****************************************************************
   FUNCTION ff_nombre

   Funci¿n que llama F_NOMBRE

   Bug 22088 - 30/04/2012 - MDS
   ******************************************************************/
   FUNCTION ff_nombre(
      psperson IN NUMBER,
      pnformat IN NUMBER,
      pcagente IN agentes.cagente%TYPE DEFAULT NULL)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN REPLACE(f_nombre(psperson, pnformat, pcagente), CHR(39), CHR(39) || CHR(39));
   END ff_nombre;

   /*****************************************************************
   FUNCTION f_get_respuesta_pol

   Funci¿n que devuelve la respuesta de una pregunta de una p¿liza

     param IN psseguro  : c¿digo de seguro
     param IN pnmovimi  : n¿mero de movimiento
     param IN pcpregun  : c¿digo de pregunta
     param IN pcidioma  : c¿digo de idioma
     param IN ptippre   : modo de tipo de pregunta
     return             : Texto de la respuesta

   Bug 22009 - 04/06/20102 - MDS
   ******************************************************************/
   FUNCTION f_get_respuesta_pol(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcidioma IN NUMBER,
      ptippre IN NUMBER DEFAULT NULL,
      p_mode IN VARCHAR2 DEFAULT 'POL')   --22009
      RETURN VARCHAR2 IS
      v_trespue      pregunpolseg.trespue%TYPE := NULL;
      v_crespue      pregunpolseg.crespue%TYPE := NULL;
      v_ctippre      codipregun.ctippre%TYPE;
   BEGIN
      BEGIN
         IF NVL(p_mode, 'POL') = 'EST' THEN   --22009
            SELECT trespue, crespue
              INTO v_trespue, v_crespue
              FROM estpregunpolseg p
             WHERE p.sseguro = psseguro
               AND p.nmovimi = pnmovimi
               AND p.cpregun = pcpregun;
         ELSE
            SELECT trespue, crespue
              INTO v_trespue, v_crespue
              FROM pregunpolseg p
             WHERE p.sseguro = psseguro
               AND p.nmovimi = pnmovimi
               AND p.cpregun = pcpregun;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- la pregunta no se ha respondido
            v_trespue := NULL;
            v_crespue := NULL;
      END;

      -- no hay respuesta
      IF v_trespue IS NULL
         AND v_crespue IS NULL THEN
         RETURN NULL;
      END IF;

      -- la respuesta es texto libre
      IF v_trespue IS NOT NULL THEN
         RETURN REPLACE(v_trespue, CHR(39), CHR(39) || CHR(39));
      END IF;

      -- la respuesta est¿ codificada, ver que tipo de pregunta es?
      SELECT c.ctippre
        INTO v_ctippre
        FROM codipregun c
       WHERE c.cpregun = pcpregun;

      IF v_ctippre IN(3, 4) THEN
         -- el valor es la respuesta
         RETURN REPLACE(v_crespue, CHR(39), CHR(39) || CHR(39));
      END IF;

      IF v_ctippre IN(1, 2)
         AND v_crespue IS NOT NULL THEN
         --  el tipo de pregunta es Si/No o Lista valores
         IF NVL(ptippre, 0) = 1 THEN
            -- se quiere que la respuesta sea el texto de la pregunta
            IF v_crespue = 1 THEN
               -- si la respuesta es Si --> la respuesta es el texto de la pregunta
               SELECT p.tpregun
                 INTO v_trespue
                 FROM preguntas p
                WHERE p.cpregun = pcpregun
                  AND p.cidioma = pcidioma;

               RETURN REPLACE(v_trespue, CHR(39), CHR(39) || CHR(39));
            ELSE
               -- si la respuesta es No --> la respuesta es vac¿a
               RETURN NULL;
            END IF;
         ELSE
            -- el valor codifica la respuesta
            SELECT r.trespue
              INTO v_trespue
              FROM respuestas r
             WHERE r.crespue = v_crespue
               AND r.cpregun = pcpregun
               AND r.cidioma = pcidioma;

            RETURN REPLACE(v_trespue, CHR(39), CHR(39) || CHR(39));
         END IF;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_respuesta_pol;

   /*****************************************************************
   FUNCTION f_get_respuestas_pol

   Funci¿n que devuelve las respuestas de unas preguntas de una p¿liza

     param IN psseguro  : c¿digo de seguro
     param IN pnmovimi  : n¿mero de movimiento
     param IN pcpregun1 : c¿digo de pregunta
     param IN pcpregun2 : c¿digo de pregunta
     param IN pcpregun3 : c¿digo de pregunta
     param IN pcpregun4 : c¿digo de pregunta
     param IN pcpregun5 : c¿digo de pregunta
     param IN pcidioma  : c¿digo de idioma
     param IN ptippre   : modo de tipo de pregunta
    param IN p_mode 'POL' EST)   --22009
     return             : Texto de la respuesta

   Bug 22009 - 04/06/20102 - MDS
   ******************************************************************/
   FUNCTION f_get_respuestas_pol(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun1 IN NUMBER,
      pcpregun2 IN NUMBER,
      pcpregun3 IN NUMBER,
      pcpregun4 IN NUMBER,
      pcpregun5 IN NUMBER,
      pcidioma IN NUMBER,
      ptippre IN NUMBER DEFAULT NULL,
      p_mode IN VARCHAR2 DEFAULT 'POL')   --22009
      RETURN VARCHAR2 IS
      v_trespue1     pregunpolseg.trespue%TYPE := NULL;
      v_trespue2     pregunpolseg.trespue%TYPE := NULL;
      v_trespue3     pregunpolseg.trespue%TYPE := NULL;
      v_trespue4     pregunpolseg.trespue%TYPE := NULL;
      v_trespue5     pregunpolseg.trespue%TYPE := NULL;
      v_trespue      pregunpolseg.trespue%TYPE := NULL;
   BEGIN
      -- obtener individualmente las respuestas de cada pregunta
      IF pcpregun1 IS NOT NULL THEN
         IF NVL(p_mode, 'POL') = 'EST' THEN   --22009
            v_trespue1 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun1, pcidioma,
                                              ptippre, 'EST');   --22009
         ELSE
            v_trespue1 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun1, pcidioma,
                                              ptippre, 'POL');   --22009
         END IF;
      END IF;

      IF pcpregun2 IS NOT NULL THEN
         IF NVL(p_mode, 'POL') = 'EST' THEN   --22009
            v_trespue2 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun2, pcidioma,
                                              ptippre, 'EST');
         ELSE
            v_trespue2 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun2, pcidioma,
                                              ptippre, 'POL');
         END IF;
      END IF;

      IF pcpregun3 IS NOT NULL THEN
         IF NVL(p_mode, 'POL') = 'EST' THEN   --22009
            v_trespue3 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun3, pcidioma,
                                              ptippre, 'EST');
         ELSE
            v_trespue3 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun3, pcidioma,
                                              ptippre, 'POL');
         END IF;
      END IF;

      IF pcpregun4 IS NOT NULL THEN
         IF NVL(p_mode, 'POL') = 'EST' THEN   --22009
            v_trespue4 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun4, pcidioma,
                                              ptippre, 'EST');
         ELSE
            v_trespue4 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun4, pcidioma,
                                              ptippre, 'POL');
         END IF;
      END IF;

      IF pcpregun5 IS NOT NULL THEN
         IF NVL(p_mode, 'POL') = 'EST' THEN   --22009
            v_trespue5 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun5, pcidioma,
                                              ptippre, 'EST');
         ELSE
            v_trespue5 := f_get_respuesta_pol(psseguro, pnmovimi, pcpregun5, pcidioma,
                                              ptippre, 'POL');
         END IF;
      END IF;

      -- crear la respuesta concatenada
      v_trespue := v_trespue1;

      IF v_trespue IS NOT NULL THEN
         IF v_trespue2 IS NOT NULL THEN
            v_trespue := v_trespue || ', ' || v_trespue2;
         END IF;
      ELSE
         v_trespue := v_trespue2;
      END IF;

      IF v_trespue IS NOT NULL THEN
         IF v_trespue3 IS NOT NULL THEN
            v_trespue := v_trespue || ', ' || v_trespue3;
         END IF;
      ELSE
         v_trespue := v_trespue3;
      END IF;

      IF v_trespue IS NOT NULL THEN
         IF v_trespue4 IS NOT NULL THEN
            v_trespue := v_trespue || ', ' || v_trespue4;
         END IF;
      ELSE
         v_trespue := v_trespue4;
      END IF;

      IF v_trespue IS NOT NULL THEN
         IF v_trespue5 IS NOT NULL THEN
            v_trespue := v_trespue || ', ' || v_trespue5;
         END IF;
      ELSE
         v_trespue := v_trespue5;
      END IF;

      RETURN v_trespue;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_respuestas_pol;

   /*****************************************************************
   FUNCTION f_get_desglose_garant

   Funci¿n que devuelve el desglose de una garant¿a de una p¿liza

     param IN psseguro  : c¿digo de seguro
     param IN pnriesgo  : n¿mero de riesgo
     param IN pcgarant  : c¿digo de garant¿a
     param IN pnmovimi  : n¿mero de movimiento
     return             : Desglose de garant¿as

   Bug 22009 - 04/06/20102 - MDS
   ******************************************************************/
   FUNCTION f_get_desglose_garant(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tconsulta    VARCHAR2(2000);
      v_tresult      VARCHAR2(32000) := '';
      v_tdescrip     garandetcap.tdescrip%TYPE;
      v_icapital     garandetcap.icapital%TYPE;
   BEGIN
      v_tconsulta := 'SELECT TRANSLATE( g.tdescrip, chr(39), chr(180)), g.icapital '
                     || ' FROM '
                     || CASE NVL(p_mode, 'POL')
                        WHEN 'POL' THEN 'garandetcap g '
                        ELSE 'estgarandetcap g '
                     END
                     || ' WHERE g.sseguro = ' || psseguro || ' AND g.nriesgo = '
                     || NVL(TO_CHAR(pnriesgo), 'g.nriesgo') || ' AND g.cgarant = '
                     || NVL(TO_CHAR(pcgarant), 'g.cgarant') || ' AND g.nmovimi = ' || pnmovimi
                     || ' ORDER BY g.nriesgo, g.norden';

      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_tdescrip, v_icapital;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || v_tdescrip || ' '
                      || TO_CHAR(v_icapital, 'FM999G999G999G990D00') || '; ';
      END LOOP;

      CLOSE vr_cursor;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         IF vr_cursor%ISOPEN THEN
            CLOSE vr_cursor;
         END IF;

         RETURN NULL;
   END f_get_desglose_garant;

   /*****************************************************************
   FUNCTION f_get_respuesta_garan

   Funci¿n que devuelve la respuesta de una pregunta de una garantia

     param IN psseguro  : c¿digo de seguro
     param IN pnmovimi  : n¿mero de movimiento
     param IN pcpregun  : c¿digo de pregunta
     param IN pcgarant  : c¿digo de garant¿a
     param IN pcidioma  : c¿digo de idioma
     param IN ptippre   : modo de tipo de pregunta
     return             : Texto de la respuesta

   Bug 22009 - 04/06/20102 - MDS
   ******************************************************************/
   FUNCTION f_get_respuesta_garan(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      pcidioma IN NUMBER,
      ptippre IN NUMBER DEFAULT NULL,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      v_trespue      pregungaranseg.trespue%TYPE := NULL;
      v_crespue      pregungaranseg.crespue%TYPE := NULL;
      v_ctippre      codipregun.ctippre%TYPE;
   BEGIN
      BEGIN
         IF NVL(p_mode, 'POL') = 'EST' THEN
            SELECT trespue, crespue
              INTO v_trespue, v_crespue
              FROM estpregungaranseg p
             WHERE p.sseguro = psseguro
               AND p.nmovimi = pnmovimi
               AND p.cgarant = pcgarant
               AND p.cpregun = pcpregun;
         ELSE
            SELECT trespue, crespue
              INTO v_trespue, v_crespue
              FROM pregungaranseg p
             WHERE p.sseguro = psseguro
               AND p.nmovimi = pnmovimi
               AND p.cgarant = pcgarant
               AND p.cpregun = pcpregun;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- la pregunta no se ha respondido
            v_trespue := NULL;
            v_crespue := NULL;
      END;

      -- no hay respuesta
      IF v_trespue IS NULL
         AND v_crespue IS NULL THEN
         RETURN NULL;
      END IF;

      -- la respuesta es texto libre
      IF v_trespue IS NOT NULL THEN
         RETURN REPLACE(v_trespue, CHR(39), CHR(39) || CHR(39));
      END IF;

      -- la respuesta est¿ codificada, ver que tipo de pregunta es?
      SELECT c.ctippre
        INTO v_ctippre
        FROM codipregun c
       WHERE c.cpregun = pcpregun;

      IF v_ctippre IN(3, 4) THEN
         -- el valor es la respuesta
         RETURN REPLACE(v_crespue, CHR(39), CHR(39) || CHR(39));
      END IF;

      IF v_ctippre IN(1, 2)
         AND v_crespue IS NOT NULL THEN
         --  el tipo de pregunta es Si/No o Lista valores
         IF NVL(ptippre, 0) = 1 THEN
            -- se quiere que la respuesta sea el texto de la pregunta
            IF v_crespue = 1 THEN
               -- si la respuesta es Si --> la respuesta es el texto de la pregunta
               SELECT p.tpregun
                 INTO v_trespue
                 FROM preguntas p
                WHERE p.cpregun = pcpregun
                  AND p.cidioma = pcidioma;

               RETURN REPLACE(v_trespue, CHR(39), CHR(39) || CHR(39));
            ELSE
               -- si la respuesta es No --> la respuesta es vac¿a
               RETURN NULL;
            END IF;
         ELSE
            -- el valor codifica la respuesta
            SELECT r.trespue
              INTO v_trespue
              FROM respuestas r
             WHERE r.crespue = v_crespue
               AND r.cpregun = pcpregun
               AND r.cidioma = pcidioma;

            RETURN REPLACE(v_trespue, CHR(39), CHR(39) || CHR(39));
         END IF;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_respuesta_garan;

    /*****************************************************************
    Funci¿n que devuelve el c¿digo del condicionado particular

     param IN psseguro  : c¿digo de seguro
     param IN pnmovimi  : n¿mero de movimiento
     param IN pcpregun  : c¿digo de pregunta
     return             : c¿digo del condicionado

     Bug 22936/118962- 18/07/20102 - AMC
   ******************************************************************/
   FUNCTION f_get_cod_condparticular(psseguro IN NUMBER, pnmovimi IN NUMBER, pcpregun IN NUMBER)
      RETURN VARCHAR2 IS
      v_crespue      pregunpolseg.crespue%TYPE := NULL;
      vcclausu       condicionadoprod.cclausu%TYPE := NULL;
   BEGIN
      SELECT crespue
        INTO v_crespue
        FROM pregunpolseg
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi
         AND cpregun = pcpregun;

      SELECT cclausu
        INTO vcclausu
        FROM condicionadoprod
       WHERE ccondicio = v_crespue;

      RETURN vcclausu;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_cod_condparticular;

     /*****************************************************************
    Funci¿n que devuelve el par¿metros de las Clausulas Entidad / Prestamo

     param IN psseguro  : c¿digo de seguro
     param IN pnmovimi  : n¿mero de movimiento
     param IN pnriesgo  : numero de riesgo
     param IN pnsclagen : secuencia cla¿sula
     param IN pnparame  : n¿mero de par¿metro
     return             : Texto del par¿metro de la clausula

     Bug 22009/119279- 02/08/20102 - LCF
   ******************************************************************/
   FUNCTION f_get_param_clau(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pnsclagen IN NUMBER,
      pnparame IN NUMBER)
      RETURN VARCHAR2 IS
      v_tparame      clauparaseg.tparame%TYPE := NULL;
   BEGIN
      SELECT tparame
        INTO v_tparame
        FROM clauparaseg
       WHERE sclagen = pnsclagen
         AND sseguro = psseguro
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo
         AND nparame = pnparame;

      RETURN v_tparame;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_param_clau;

   /*****************************************************************
   FUNCTION f_get_respuestas_gar

   Funci¿n que devuelve las respuestas de unas preguntas de una p¿liza

     param IN psseguro  : c¿digo de seguro
     param IN pnmovimi  : n¿mero de movimiento
     param IN pcpregun1 : c¿digo de pregunta
     param IN pcpregun2 : c¿digo de pregunta
     param IN pcpregun3 : c¿digo de pregunta
     param IN pcpregun4 : c¿digo de pregunta
     param IN pcpregun5 : c¿digo de pregunta
     param IN pcidioma  : c¿digo de idioma
     param IN ptippre   : modo de tipo de pregunta
    param IN p_mode 'POL' EST)   --22009
     return             : Texto de la respuesta

   ******************************************************************/
   FUNCTION f_get_respuestas_gar(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun1 IN NUMBER,
      pcpregun2 IN NUMBER,
      pcpregun3 IN NUMBER,
      pcpregun4 IN NUMBER,
      pcpregun5 IN NUMBER,
      pcidioma IN NUMBER,
      ptippre IN NUMBER DEFAULT NULL,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      v_trespue1     pregungaranseg.trespue%TYPE := NULL;
      v_trespue2     pregungaranseg.trespue%TYPE := NULL;
      v_trespue3     pregungaranseg.trespue%TYPE := NULL;
      v_trespue4     pregungaranseg.trespue%TYPE := NULL;
      v_trespue5     pregungaranseg.trespue%TYPE := NULL;
      v_trespue      pregungaranseg.trespue%TYPE := NULL;
   BEGIN
      -- obtener individualmente las respuestas de cada pregunta
      IF pcpregun1 IS NOT NULL THEN
         v_trespue1 := f_get_respuesta_garan(psseguro, pnmovimi, pcpregun1, pcgarant,
                                             pcidioma, ptippre, NVL(p_mode, 'POL'));   --22009
      END IF;

      IF pcpregun2 IS NOT NULL THEN
         v_trespue2 := f_get_respuesta_garan(psseguro, pnmovimi, pcpregun2, pcgarant,
                                             pcidioma, ptippre, NVL(p_mode, 'POL'));
      END IF;

      IF pcpregun3 IS NOT NULL THEN
         v_trespue3 := f_get_respuesta_garan(psseguro, pnmovimi, pcpregun3, pcgarant,
                                             pcidioma, ptippre, NVL(p_mode, 'POL'));
      END IF;

      IF pcpregun4 IS NOT NULL THEN
         v_trespue4 := f_get_respuesta_garan(psseguro, pnmovimi, pcpregun4, pcgarant,
                                             pcidioma, ptippre, NVL(p_mode, 'POL'));
      END IF;

      IF pcpregun5 IS NOT NULL THEN
         v_trespue5 := f_get_respuesta_garan(psseguro, pnmovimi, pcpregun5, pcgarant,
                                             pcidioma, ptippre, NVL(p_mode, 'POL'));
      END IF;

      -- crear la respuesta concatenada
      v_trespue := v_trespue1;

      IF v_trespue IS NOT NULL THEN
         IF v_trespue2 IS NOT NULL THEN
            v_trespue := v_trespue || ', ' || v_trespue2;
         END IF;
      ELSE
         v_trespue := v_trespue2;
      END IF;

      IF v_trespue IS NOT NULL THEN
         IF v_trespue3 IS NOT NULL THEN
            v_trespue := v_trespue || ', ' || v_trespue3;
         END IF;
      ELSE
         v_trespue := v_trespue3;
      END IF;

      IF v_trespue IS NOT NULL THEN
         IF v_trespue4 IS NOT NULL THEN
            v_trespue := v_trespue || ', ' || v_trespue4;
         END IF;
      ELSE
         v_trespue := v_trespue4;
      END IF;

      IF v_trespue IS NOT NULL THEN
         IF v_trespue5 IS NOT NULL THEN
            v_trespue := v_trespue || ', ' || v_trespue5;
         END IF;
      ELSE
         v_trespue := v_trespue5;
      END IF;

      RETURN v_trespue;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_respuestas_gar;

   --Bug 24598 - XVM - 27/12/2012
   FUNCTION f_tratamiento(
      p_sperson IN NUMBER,
      p_idioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      v_dades        VARCHAR2(200);
      v_csexper      NUMBER;
   BEGIN
      IF p_sperson IS NULL THEN
         RETURN NULL;
      ELSE
         BEGIN
            IF NVL(p_mode, 'POL') = 'EST' THEN
               SELECT p.csexper
                 INTO v_csexper
                 FROM estper_personas p
                WHERE p.sperson = p_sperson;
            ELSE
               SELECT p.csexper
                 INTO v_csexper
                 FROM per_personas p
                WHERE p.sperson = p_sperson;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

      IF v_csexper = 1 THEN
         v_dades := f_axis_literales(9904697, p_idioma);
      ELSIF v_csexper = 2 THEN
         v_dades := f_axis_literales(9904698, p_idioma);
      END IF;

      RETURN v_dades;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tratamiento;

   --Bug 24813 - RDD - 21/01/2013
   FUNCTION f_calc_formula_agente(
      pcagente IN NUMBER,
      pclave IN NUMBER,
      pfecefe IN DATE,
      psproduc IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vvalor         NUMBER;
      vregresa_pac_liquida NUMBER;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      vregresa_pac_liquida := pac_liquida.f_calc_formula_agente(pcagente, pclave, pfecefe,
                                                                vvalor, psproduc);
      COMMIT;
      RETURN NVL(vvalor, 0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_calc_formula_agente;

   FUNCTION f_total_rec(p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_total_rec    NUMBER(15, 2);
   BEGIN
      SELECT v.itotalr
        INTO v_total_rec
        FROM seguros s, recibos r, vdetrecibos v
       WHERE s.sseguro = p_sseguro
         AND s.sseguro = r.sseguro
         AND r.ctiprec = 0
         AND r.nrecibo = v.nrecibo
         AND r.nmovimi = f_max_nmovimi(s.sseguro);

      RETURN(v_total_rec);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_total_rec;

   -- Inico BUG31135:MMS:18/08/2014
   /*****************************************************************
    F_RESP_RIE_INF (F_RESP_RIE): Retorna la resposta de les preguntes de tots els riscos
    Modificaci¿n utilizada en el PAC_INFORMES
    param p_sseguro IN        : sseguro
    param p_cpregum IN        : codi pregunta
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_resp_rie_inf(
      p_sseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      --
      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      v_tresult      VARCHAR2(32000) := '';
      v_tconsulta    VARCHAR2(2000);
      v_cpregun      NUMBER;
      v_crespue      NUMBER;
      v_sproduc      NUMBER;
      v_trespue      VARCHAR2(500);
      v_numerr       NUMBER;
      v_ctippre      codipregun.ctippre%TYPE;
   BEGIN
      v_tconsulta := 'SELECT p.cpregun, cp.ctippre, p.crespue, p.trespue, s.sproduc ';
      v_tconsulta := v_tconsulta || ' FROM codipregun cp';

      IF NVL(p_mode, 'POL') = 'EST' THEN
         v_tconsulta := v_tconsulta || ', estpregunseg p, estseguros s';
      ELSE
         v_tconsulta := v_tconsulta || ', pregunseg p, seguros s';
      END IF;

      v_tconsulta := v_tconsulta || ' WHERE s.sseguro = ' || p_sseguro;
      v_tconsulta := v_tconsulta || ' AND p.sseguro = s.sseguro';
      v_tconsulta := v_tconsulta || ' AND p.nriesgo = ' || NVL(TO_CHAR(p_nriesgo), 'p.nriesgo');
      v_tconsulta := v_tconsulta || ' AND p.cpregun = ' || p_cpregun;
      v_tconsulta := v_tconsulta || ' AND p.nmovimi = ' || NVL(p_nmovimi, 1);
      v_tconsulta := v_tconsulta || ' AND cp.cpregun = p.cpregun';
      v_tconsulta := v_tconsulta || ' ORDER BY p.nriesgo';

      OPEN vr_cursor FOR v_tconsulta;

      LOOP
         FETCH vr_cursor
          INTO v_cpregun, v_ctippre, v_crespue, v_trespue, v_sproduc;

         IF v_ctippre IN(3, 4, 5) THEN
            v_trespue := NVL(v_trespue, TO_CHAR(v_crespue, 'FM999G999G999G990D00'));
         ELSE
            v_numerr := pac_productos.f_get_pregunrespue(v_sproduc, v_cpregun, v_crespue,
                                                         p_cidioma, v_trespue);
         END IF;

         IF v_numerr <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_ISQLFOR.f_resp_rie', 1, v_numerr,
                        'Params: ' || ' - ' || v_cpregun || ' - ' || v_crespue || ' - '
                        || v_sproduc);
         END IF;

         EXIT WHEN vr_cursor%NOTFOUND;
         v_tresult := v_tresult || v_trespue;
      END LOOP;

      RETURN(v_tresult);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('');
   END f_resp_rie_inf;

   FUNCTION f_lee_pregunta(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_ctippre      codipregun.ctippre%TYPE;
      v_crespue      pregunseg.crespue%TYPE;
      v_trespue      pregunseg.trespue%TYPE;
   BEGIN
      --
      BEGIN
         SELECT ctippre
           INTO v_ctippre
           FROM codipregun
          WHERE cpregun = pcpregun;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN NULL;
      END;

      --
      BEGIN
         SELECT crespue, trespue
           INTO v_crespue, v_trespue
           FROM seguros s, pregunpolseg p
          WHERE s.sseguro = psseguro
            AND s.sseguro = p.sseguro
            AND p.nmovimi = (SELECT MAX(p2.nmovimi)
                               FROM pregunpolseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.cpregun = p.cpregun)
            AND p.cpregun = pcpregun;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT crespue, trespue
                 INTO v_crespue, v_trespue
                 FROM seguros s, pregunseg p
                WHERE s.sseguro = psseguro
                  AND s.sseguro = p.sseguro
                  AND p.nriesgo = pnriesgo
                  AND p.nmovimi = (SELECT MAX(p2.nmovimi)
                                     FROM pregunseg p2
                                    WHERE p2.sseguro = p.sseguro
                                      AND p2.cpregun = p.cpregun
                                      AND p2.nriesgo = p.nriesgo)
                  AND p.cpregun = pcpregun;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT crespue, trespue
                       INTO v_crespue, v_trespue
                       FROM seguros s, pregungaranseg p
                      WHERE s.sseguro = psseguro
                        AND s.sseguro = p.sseguro
                        AND p.nriesgo = pnriesgo
                        AND p.cgarant = pcgarant
                        AND p.nmovimi = (SELECT MAX(p2.nmovimi)
                                           FROM pregungaranseg p2
                                          WHERE p2.sseguro = p.sseguro
                                            AND p2.cpregun = p.cpregun
                                            AND p2.nriesgo = p.nriesgo
                                            AND p2.cgarant = p.cgarant)
                        AND p.cpregun = pcpregun;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        RETURN NULL;
                  END;
            END;
      END;

      --
      IF v_ctippre IN(1, 2) THEN   -- Lista Si/no,  Lista Valores
         BEGIN
            SELECT trespue
              INTO v_trespue
              FROM respuestas
             WHERE cpregun = pcpregun
               AND cidioma = pcidioma
               AND crespue = v_crespue;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         RETURN v_trespue;
      ELSIF v_ctippre = 3 THEN   -- Valor
         RETURN v_crespue;
      ELSIF v_ctippre = 4 THEN   -- Fecha
         RETURN v_trespue;
      ELSIF v_ctippre = 5 THEN   -- texto
         RETURN v_trespue;
      ELSE
         IF v_ctippre IS NULL THEN
            RETURN v_trespue;
         END IF;

         RETURN v_crespue;
      END IF;

      --
      RETURN NULL;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_isqlfor_COLM.f_lee_pregunta', 1,
                     'psseguro = ' || psseguro || ' pnriesgo = ' || pnriesgo || ' pfefecto = '
                     || pfefecto || ' pnmovimi = ' || pnmovimi || ' pcactivi = ' || pcactivi
                     || ' pcgarant = ' || pcgarant || ' pcpregun = ' || pcpregun
                     || ' pcidioma = ' || pcidioma,
                     SQLERRM);
         RETURN NULL;
   END f_lee_pregunta;
-- Fin BUG31135:MMS:18/08/2014

   FUNCTION f_cantidad_garantias_poliza(
      psseguro IN NUMBER,
      pcvalpar IN NUMBER,
      ptipo    IN NUMBER)
      RETURN NUMBER IS

      TYPE r_cursor IS REF CURSOR;

      vr_cursor  r_cursor;
      v_ramo     NUMBER;
      v_contador NUMBER;
      v_consulta VARCHAR2(1000);
      BEGIN
        v_consulta := 'SELECT ';
               IF ptipo = 1 THEN -- cantidad de garantias por seguro
                 v_consulta:= v_consulta || 'COUNT(*)';
               ELSIF ptipo = 2 THEN --valor maximo de los meses de las garantias asociadas al seguro
                 v_consulta:= v_consulta || 'MAX(months_between(g.ffinvig, g.finivig))';
               ELSIF ptipo = 3 THEN --valor maximo de los dias de las garantias asociadas al seguro
                 v_consulta:= v_consulta || 'MAX(TRUNC(g.ffinvig) - TRUNC(g.finivig))';
               ELSIF ptipo = 4 THEN --valor maximo del valor asegurado de las garantias asociadas al seguro
                 v_consulta:= v_consulta || 'MAX(g.icapital)';
               END IF;
        v_consulta := v_consulta ||
         'FROM seguros s, garanseg g, garangen d, pargaranpro p, pregungaranseg pr
         WHERE s.sseguro = g.sseguro
           AND p.cramo = s.cramo
           AND p.sproduc = s.sproduc
           AND p.cgarant = g.cgarant
           AND p.cpargar = ''EXCONTRACTUAL''
           AND to_number(p.cvalpar) = ' || pcvalpar || '
           AND d.cgarant = g.cgarant
           AND s.sseguro = pr.sseguro
           AND pr.cgarant = g.cgarant
           AND pr.cpregun = 2894
           AND d.cidioma = 8
           AND s.sseguro = ' || psseguro;

          OPEN vr_cursor FOR v_consulta;

          LOOP
             FETCH vr_cursor
              INTO v_contador;

             EXIT WHEN vr_cursor%NOTFOUND;
          END LOOP;

          CLOSE vr_cursor;

        RETURN v_contador;
   END f_cantidad_garantias_poliza;

   -- Ini ajustes para el 42% personas ACL 29/10/2018
  FUNCTION f_vinculo ( psperson   IN NUMBER ) RETURN VARCHAR2 IS
    v_sperson   VARCHAR2(100);
    vinculo     VARCHAR2(100);
BEGIN
    BEGIN
        SELECT
            garco.sperson
        INTO
            v_sperson
        FROM
            ctgar_codeudor garco,
            per_contragarantia p,
            tomadores t
        WHERE
                garco.scontgar = p.scontgar
            AND
                p.sperson = t.sperson;

    EXCEPTION
        WHEN too_many_rows THEN
            vinculo := 'CODEUDOR';
        WHEN no_data_found THEN
            vinculo := NULL;
    END;

    IF
        v_sperson IS NULL
    THEN
        vinculo := 'TOMADOR';
    ELSE
        vinculo := 'CODEUDOR';
    END IF;

    RETURN vinculo;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END f_vinculo;

FUNCTION f_codeudor ( psperson   IN NUMBER ) RETURN VARCHAR2 IS
    v_codeudor   VARCHAR2(200);
BEGIN
    SELECT
        f_nombre(
            garco.sperson,
            1,
            NULL
        )
         || ' '
         || p.sperson
    INTO
        v_codeudor
    FROM
        ctgar_codeudor garco,
        per_contragarantia p,
        per_detper pper,
        tomadores t
    WHERE
            garco.scontgar = p.scontgar
        AND
            p.sperson = t.sperson
        AND
            pper.sperson = garco.sperson;

    RETURN v_codeudor;
EXCEPTION
    WHEN no_data_found THEN
        v_codeudor := NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END f_codeudor;
  -- Fin ajustes para el 42% personas ACL 29/10/2018

-- Inico GE-FO-18-02 15/11/2018
   FUNCTION f_pais_abreviatura(
      ppais IN NUMBER)
      RETURN VARCHAR2 IS

      v_codigo varchar2(2);
      begin
            begin
               select a.abreviatura
                  into v_codigo
               from paises a
               where a.cpais = ppais;
             exception when no_data_found then
                v_codigo := null;
             end;

       RETURN v_codigo;
   end f_pais_abreviatura;
-- Fin GE-FO-18-02 15/11/2018   
-- INI BUG 3324 - SGM Interacción del Rango DIAN con la póliza (No. Certificado)
    FUNCTION f_certifdian(
        psseguro IN SEGUROS.SSEGURO%TYPE,
        pnmovimi IN MOVSEGURO.NMOVIMI%TYPE
    )   RETURN VARCHAR2 
    IS
        vcactivi        NUMBER;
        vsucursal       NUMBER;
        vcertdian       VARCHAR2(20);
        vcagente        NUMBER;
    BEGIN
        BEGIN
           SELECT CACTIVI,CAGENTE
             INTO vcactivi,vcagente
             FROM seguros
            WHERE sseguro = psseguro;
        EXCEPTION
             WHEN OTHERS THEN
             RETURN 101919;  --(Error al leer datos de la tabla SEGUROS)
        END;             
        vsucursal := PAC_AGENTES.F_GET_CAGELIQ(PAC_MD_COMMON.F_GET_CXTEMPRESA(), 2, vcagente);       
        BEGIN
            SELECT VSUCURSAL||' '||NCERTDIAN
              INTO vcertdian
              FROM rango_dian_movseguro rd 
             WHERE rd.sseguro = psseguro and rd.nmovimi = pnmovimi;
        EXCEPTION
            WHEN OTHERS THEN
        RETURN NULL;
        END;         
        RETURN vcertdian;
    END f_certifdian;
    
    FUNCTION f_resoldian(
        psseguro in SEGUROS.SSEGURO%TYPE,
        pnmovimi IN MOVSEGURO.NMOVIMI%TYPE
    )   RETURN VARCHAR2 
    IS
        vrango          NUMBER;
        vresoldian      VARCHAR2(400);
    BEGIN     
        BEGIN
            SELECT SUBSTR(ncertdian,3)
              INTO vrango
              FROM rango_dian_movseguro rd 
             WHERE rd.sseguro = psseguro and rd.nmovimi = pnmovimi;
        EXCEPTION
            WHEN OTHERS THEN
        RETURN NULL;
        END;        
        BEGIN
            SELECT TDESCRIP
              INTO vresoldian
              FROM rango_dian WHERE vrango BETWEEN ninicial AND nfinal;
        EXCEPTION
             WHEN OTHERS THEN
             RETURN NULL;  --(Error al leer datos de la tabla SEGUROS)
        END;           
        RETURN vresoldian;
    END f_resoldian;    
-- FIN BUG 3324 - SGM Interacción del Rango DIAN con la póliza (No. Certificado)

FUNCTION f_tipo_contrato(
        psseguro IN NUMBER,
        pnpoliza IN NUMBER,
        p_idioma IN NUMBER DEFAULT 1
    )   RETURN VARCHAR2
    IS
        vtipsuscrito      VARCHAR2(400);
    BEGIN
            SELECT DISTINCT  DP.TDESCRIPCION INTO vtipsuscrito
          FROM DETCLASECONTRATO DP, SECTORESPROD PP, PRODUCTOS PR, CODIRAM CO
          WHERE DP.CIDIOMA = p_idioma
               AND PR.SPRODUC = (SELECT sproduc FROM seguros WHERE sseguro = psseguro) 
               AND PP.CCODCONTRATO = DP.CCODCONTRATO
               AND PP.CCLACONTRATO = DP.CCLACONTRATO
               AND PP.CRAMO = PR.CRAMO
               AND PP.CMODALI = PR.CMODALI
               AND PP.CTIPSEG = PR.CTIPSEG
               AND PP.CCOLECT = PR.CCOLECT 
               AND DP.CCODCONTRATO||DP.CCLACONTRATO = (SELECT crespue FROM pregunseg WHERE cpregun = 2880 and sseguro = psseguro)
               AND pp.csector = (CASE WHEN (SELECT COUNT(0) FROM (SELECT R.CRESPUE FROM ESTPREGUNPOLSEG R WHERE SSEGURO = (SELECT sseguro FROM estseguros WHERE npoliza = pnpoliza) AND CPREGUN = 2879 AND NMOVIMI = (SELECT MAX(NMOVIMI)
                   FROM ESTPREGUNPOLSEG P2 WHERE P2.SSEGURO = (SELECT sseguro FROM estseguros WHERE npoliza = pnpoliza) AND P2.CPREGUN = 2879))) > 0 THEN (SELECT R.CRESPUE
                   FROM ESTPREGUNPOLSEG R WHERE SSEGURO = (SELECT sseguro FROM estseguros WHERE npoliza = pnpoliza)
                   AND CPREGUN = 2879 AND NMOVIMI = (SELECT MAX(NMOVIMI) FROM ESTPREGUNPOLSEG P2 WHERE P2.SSEGURO = (SELECT sseguro FROM estseguros WHERE npoliza = pnpoliza)
                   AND P2.CPREGUN = 2879)) ELSE (SELECT R.CRESPUE FROM PREGUNPOLSEG R WHERE SSEGURO = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza) AND CPREGUN = 2879
                   AND NMOVIMI = (SELECT MAX(NMOVIMI) FROM PREGUNPOLSEG P2 WHERE P2.SSEGURO = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza)
                   AND P2.CPREGUN = 2879) UNION SELECT R.CRESPUE FROM ESTPREGUNPOLSEG R WHERE SSEGURO = (SELECT sseguro FROM estseguros WHERE npoliza = pnpoliza)
                   AND CPREGUN = 2879 AND NMOVIMI = (SELECT MAX(NMOVIMI) FROM ESTPREGUNPOLSEG P2
                   WHERE P2.SSEGURO = (SELECT sseguro FROM estseguros WHERE npoliza = pnpoliza) AND P2.CPREGUN = 2879)) END)
                      AND CO.CRAMO = PR.CRAMO
                      AND PP.CEMPRES = CO.CEMPRES
                         ORDER BY DP.TDESCRIPCION;
           RETURN vtipsuscrito;              
                            
        EXCEPTION
             WHEN OTHERS THEN
             RETURN NULL;  --(Error al leer datos de la tabla SEGUROS)
    END f_tipo_contrato;
-- FIN BUG 4167 - suscriptor para generar reporte de siniestros  


FUNCTION f_tercer_afectado( pnsinies IN NUMBER, pntramit  IN NUMBER )   
      RETURN VARCHAR2 IS
      vterc_afectado      VARCHAR2(4000);
   BEGIN

       -- bug hoja de ruta 4167 tercer afectado nombre completo
     SELECT (nvl(TNOMBRE,'')||' '||nvl(TNOMBRE2,'')||' '||nvl(TAPELLI1,'')||' '||nvl(TAPELLI2,'')) INTO vterc_afectado FROM sin_tramita_personasrel WHERE CTIPREL = 7 AND NTRAMIT= pntramit
     AND NPERSREL=(SELECT MAX(NPERSREL)  FROM sin_tramita_personasrel WHERE CTIPREL = 7 
     AND NSINIES = pnsinies) AND NSINIES = pnsinies;

       IF  vterc_afectado=NULL OR vterc_afectado='   'THEN 
     SELECT TDESC INTO vterc_afectado FROM sin_tramita_personasrel WHERE CTIPREL = 7 AND NTRAMIT= pntramit
     AND NPERSREL=(SELECT MAX(NPERSREL)  FROM sin_tramita_personasrel WHERE CTIPREL = 7 
     AND NSINIES = pnsinies) AND NSINIES = pnsinies;
      END IF;

      RETURN TRIM(vterc_afectado);
   EXCEPTION 
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tercer_afectado;
   
   
   
   
 FUNCTION f_suscriptor(
        psseguro IN NUMBER,
        pnmovimi IN NUMBER)
        RETURN VARCHAR2 IS
        vsuscriptor      VARCHAR2(400);
   BEGIN

     SELECT  tusunom INTO vsuscriptor FROM psu_retenidas s, usuarios u 
     WHERE u.cusuari = s.cusuaut 
     AND s.nmovimi = pnmovimi 
     AND s.sseguro = psseguro;

      RETURN vsuscriptor;
   EXCEPTION 
      WHEN OTHERS THEN
         RETURN NULL;
   END f_suscriptor;
   
   
   		   
 FUNCTION f_sucursal( pcagente IN NUMBER )   
      RETURN VARCHAR2 IS
      vnom_sucursal      VARCHAR2(400);
   BEGIN
	  SELECT f_nombre((SELECT sperson FROM agentes WHERE cagente= (SELECT cpadre FROM redcomercial WHERE fmovfin IS NULL AND cagente = pcagente)), 1)
       INTO vnom_sucursal FROM dual;  
      
	  RETURN vnom_sucursal;
	  
   EXCEPTION 
      WHEN OTHERS THEN
         RETURN NULL;
   END f_sucursal;
  -- FIN BUG 4167 - nombre de la sucursal 
  
  
  FUNCTION f_get_coacuadro(p_sseguro IN NUMBER,
        p_tipo IN NUMBER) 
 RETURN VARCHAR2 IS

    CURSOR c_ctgar IS
        SELECT  distinct(cia.tcompani),
            c.ploccoa,
            pac_isqlfor.f_persona(null, null, cia.sperson) nombre,
            nvl(pac_isqlfor.f_per_contactos(cia.sperson, 3), ' ') mail,
            nvl(pac_isqlfor.f_direccion(cia.sperson, 1), ' ' ) direccion,
            nvl(pac_isqlfor.f_telefono(cia.sperson),' ') telefono
            FROM coacuadro c, companias cia
              WHERE c.ccompan = cia.ccompani
              AND   c.sseguro = p_sseguro;

    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
  BEGIN

   IF p_tipo = 1 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.tcompani || '<br>';
      END LOOP;
   ELSIF p_tipo = 2 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.ploccoa||'%'|| '<br>';
      END LOOP;
   ELSIF p_tipo = 3 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.nombre || '<br>';
      END LOOP;
   ELSIF p_tipo = 4 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.mail || '<br>';
      END LOOP;
   ELSIF p_tipo = 5 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.direccion || '<br>';
      END LOOP;
   ELSIF p_tipo = 6 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.telefono || '<br>';
      END LOOP;
   END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_coacuadro;
-- FIN BUG 4167 - obtener coaseguro de tabla coacuadro

FUNCTION f_get_coacedido(p_sseguro IN NUMBER,
        p_tipo IN NUMBER) 
     RETURN VARCHAR2 IS

    CURSOR c_ctgar IS
        SELECT  distinct(cia.tcompani),
            c.pcescoa,
            pac_isqlfor.f_persona(null, null, cia.sperson) nombre,
            nvl(pac_isqlfor.f_per_contactos(cia.sperson, 3), ' ') mail,
            nvl(pac_isqlfor.f_direccion(cia.sperson, 1), ' ' ) direccion,
            nvl(pac_isqlfor.f_telefono(cia.sperson),' ') telefono
            FROM coacedido c, companias cia
              WHERE c.ccompan = cia.ccompani
              AND   c.sseguro = p_sseguro;

    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
  BEGIN

   IF p_tipo = 1 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.tcompani || '<br>';
      END LOOP;
   ELSIF p_tipo = 2 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.pcescoa||'%'|| '<br>';
      END LOOP;
   ELSIF p_tipo = 3 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.nombre || '<br>';
      END LOOP;
   ELSIF p_tipo = 4 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.mail || '<br>';
      END LOOP;
   ELSIF p_tipo = 5 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.direccion || '<br>';
      END LOOP;
   ELSIF p_tipo = 6 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.telefono || '<br>';
      END LOOP;
   END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_coacedido;
-- FIN BUG 4167 - obtener coacedido de tabla coacuadro

--desarrollo 2485 AB
--ultima modificacion 09/10/2019
FUNCTION f_num_letras(
        idioma IN NUMBER,
        numeros IN VARCHAR2
    )   RETURN VARCHAR2
    IS
        var_RetVal    NUMBER;
        var_CTEXTO    VARCHAR2 (32767);
        VCENTA     VARCHAR2 (32767);
        CENTAVOS NUMBER;
        NUMERO NUMBER;
		AUX VARCHAR2 (100);
    BEGIN

    SELECT regexp_substr(numeros,'[^,]+', 1, 1)NUMERO, regexp_substr(numeros,'[^,]+', 1, 2)CENTAVOS INTO NUMERO,CENTAVOS FROM dual;
     var_RetVal := F_NUMLET (idioma ,NUMERO,8,var_CTEXTO) ; 
	 
	 IF LENGTH(NUMERO)>6 THEN 
            AUX :=SUBSTR(NUMERO,-6);
            IF AUX='000000' THEN
             var_CTEXTO:=var_CTEXTO||' DE ';
            END IF; 
      END IF;
     
    IF CENTAVOS IS NULL THEN 
             var_CTEXTO:=var_CTEXTO||' PESOS';
             ELSE
              var_CTEXTO := var_CTEXTO || 'PESOS CON ' ;
                  IF CENTAVOS=1 THEN
                  var_CTEXTO := var_CTEXTO||'UN CENTAVO';
                  ELSE
                  var_RetVal := F_NUMLET (idioma ,CENTAVOS,8,VCENTA) ; 
                  var_CTEXTO := var_CTEXTO||VCENTA||'CENTAVOS';
                  END IF;
              
             END IF;
  RETURN var_CTEXTO; 
        EXCEPTION
             WHEN OTHERS THEN
             RETURN NULL; 
    END f_num_letras;
    
    --IAXIS-3152 :changes for tipo de canal
  FUNCTION f_tipo_canal(
    psperson IN NUMBER
    )RETURN VARCHAR2
    is 
    v_tipo_canal varchar2(100);
    begin
    select LISTAGG((
        CASE  
           WHEN  trolmen LIKE '%CONFIBROKER' THEN 
           'CONFIBROKER' 
           ELSE 'CONFIRED'

        END),',') within group(order by trolmen)into v_tipo_canal
       from (Select distinct trolmen from menu_desrolmen where crolmen in(
       select crolmen from menu_usercodirol where cuser in (select cusuari from usuarios where sperson=psperson)));
       RETURN (v_tipo_canal);
            EXCEPTION
     WHEN NO_DATA_FOUND THEN v_tipo_canal:= NULL;  
    
        END f_tipo_canal;
 
  /* Cambios de IAXIS-5337 : Starts */
  FUNCTION F_PAISE_SAP(PI_SPERSON IN NUMBER) RETURN NUMBER IS
    V_PAISE NUMBER;
  BEGIN
    SELECT PRO.CPAIS
      INTO V_PAISE
      FROM PER_DIRECCIONES PDIR, PROVINCIAS PRO, POBLACIONES POB
     WHERE PRO.CPROVIN = PDIR.CPROVIN
       AND POB.CPROVIN = PDIR.CPROVIN
       AND POB.CPOBLAC = PDIR.CPOBLAC
       AND PDIR.CDOMICI = (SELECT MAX(PD.CDOMICI)
                             FROM PER_DIRECCIONES PD
                            WHERE PD.SPERSON = PI_SPERSON)
       AND PDIR.SPERSON = PI_SPERSON;
    RETURN V_PAISE;
  END F_PAISE_SAP;  
  /* Cambios de IAXIS-5337 : Ends */
  
  
  
   /*************************************************************************
      FUNCTION F_Int_Ext_Reporte
         Obtenemos el valor de la participación de las empresas Reaseguradoras del Interior- Exterior y su Retención
         param in p_sseguro  : Número de sseguro 
         param in p_identif    : Número de idetificador de la columna (1)Interior  (0)Exterior (3) Retencion
        --IAXIS 7585 Reporte Siniestros Pagados, Recobros y Reservas - Reaseg - IRDR - 01/04/2020

*************************************************************************/
    
 FUNCTION F_INT_EXT_REPORTE (p_sseguro IN NUMBER,
                                             p_valorca IN NUMBER,
                                             p_identif   IN NUMBER)
     RETURN NUMBER IS 
 
    v_ctiprea           NUMBER;
    v_result_resumen    NUMBER;
    v_result_cero       NUMBER; 
    v_result_uno        NUMBER;
    v_result_dos        NUMBER;
    v_result_tres       NUMBER;
    v_result_cinco      NUMBER;
    v_pcesion           NUMBER;
    v_scesrea           NUMBER;
    v_scontra           NUMBER;
    v_nversio           NUMBER;
    v_ctramo            NUMBER;

    v_object       VARCHAR2(200) := 'f_Int_Ext_Reporte';
    v_param        VARCHAR2(500) :=  'p_sseguro:' || p_sseguro || 'p_valorca: ' || p_valorca || 'p_identif: ' || p_identif ;   
    vpasexec       NUMBER(5) := 0;  


BEGIN

--Exterior
IF p_identif = 0 then 

   BEGIN
vpasexec := 1;

        SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 1
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  

   select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 0
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
 
IF v_ctiprea = 0  and v_ctramo = 1  then  
      
    v_result_uno := (p_valorca * v_pcesion) ;           

END IF;


   BEGIN
vpasexec := 2;
   
      SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 2
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  
           
    select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 0
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
     
IF v_ctiprea = 0 and v_ctramo = 2 then  
    
    v_result_dos := (p_valorca * v_pcesion) ;           

END IF;
    
   BEGIN
vpasexec := 3;

       SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 3
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;
            
EXCEPTION WHEN no_data_found THEN
        v_nversio := 0;
     END;  
               
select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 0
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);

IF v_ctiprea = 0 and v_ctramo = 3 then  
    
    v_result_tres := (p_valorca * v_pcesion) ;           

END IF;
  
   v_result_resumen := nvl(v_result_uno, 0) + nvl(v_result_dos, 0) + nvl(v_result_tres, 0);-- + v_result_cinco; 
 
 END IF;
 

--Interior
IF p_identif = 1 then 

   BEGIN
vpasexec := 4;

        SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 1
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  

   select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 1
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
 
IF v_ctiprea = 1  and v_ctramo = 1  then  
      
    v_result_uno := (p_valorca * v_pcesion) ;           

END IF;


   BEGIN
vpasexec := 5;
   
      SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 2
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  
           
    select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 1
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
     
IF v_ctiprea = 1 and v_ctramo = 2 then  
    
    v_result_dos := (p_valorca * v_pcesion) ;           

END IF;
    
   BEGIN
vpasexec := 6;

       SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 3
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;
            
EXCEPTION WHEN no_data_found THEN
        v_nversio := 0;
     END;  
               
select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 1
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
IF v_ctiprea = 1 and v_ctramo = 3 then  
    
    v_result_tres := (p_valorca * v_pcesion) ;           

END IF;
  
   v_result_resumen := nvl(v_result_uno, 0) + nvl(v_result_dos, 0) + nvl(v_result_tres, 0);-- + v_result_cinco; 
 
 END IF;
  
 
 
--retencion  
IF p_identif = 3 then 

   BEGIN
vpasexec := 7;

        SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 0
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  


IF v_ctramo = 0  then  
      
    v_result_cero := (p_valorca * v_pcesion) ;           
    v_result_resumen := v_result_cero;

END IF;

    END IF;

  
          RETURN v_result_resumen;  
 EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     vpasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1;
END F_INT_EXT_REPORTE;

END pac_isqlfor;

/

