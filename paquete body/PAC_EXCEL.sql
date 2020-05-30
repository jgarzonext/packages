--------------------------------------------------------
--  DDL for Package Body PAC_EXCEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_EXCEL" AS
   /******************************************************************************
      NOMBRE:       PAC_EXCEL
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha     Autor             Descripción
      ------  ----------  -------  ------------------------------------
       1.0        -         -      1. Creación de package
       2.0    17/03/2009  RSC      2. Análisis adaptación productos indexados
       2.1    07/04/2009  RSC      3. Análisis adaptación productos indexados
       3.0    08/07/2009  DCT      4. 0010612: CRE - Error en la generació de pagaments automàtics.
                                      Canviar vista personas por tablas personas y añadir filtro de visión de agente
       4.0    02/11/2009  APD      5. Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
       5.0    31/12/2009  NMM      6. 12442: ADAPTACIÓ PPJ (CAGRPRO 11).
       6.0    16/04/2010  RSC      7. 0014160: CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
       7.0    25/02/2011  APD      8. 0015707: ENSA102 - Valors liquidatius - Estat actual
       8.0    11/04/2011  APD      9. 0018225: AGM704 - Realizar la modificación de precisión el cagente
       9.0    30/11/2011  RSC     10. 0020309: LCOL_T004-Parametrización Fondos
   ******************************************************************************/
   /*
     27/02/2006 MCA Ref.1450 Función f_alpln305 que genera el fichero mensual de aportaciones
     27/02/2006 MCA Ref.1451 Funcion f_alpln342 que genera el fichero de pagos realizados en
                          un periodo de fechas
     24/03/2006 LEH  Inclusió de la funció F_ALPLN304 (Cuadern de previsions tècniques) corresponent
                 al report ALPLN304.RDF, cridat des de el formulari ALPLN304.FMB.
     06/04/2006 LEH  Inclusió de la funció F_SNCTR003 (Llistat d'altes de certificats) corresponent
                 al report SNCTR003.RDF, cridat des de el formulari SNCTR003.FMB.
     12/04/2006 LEH  Inclusió de la funció F_SNCTR004 (Llistat de baixes de certificats) corresponent
                 al report SNCTR004.RDF, cridat des de el formulari SNCTR003.FMB.
     22/06/2006 JMF Ref.1460 Noves funcions f_alpln339 (Contractes suspesos)
                    nova funció f_alpln338 (Contractes reactivats)
                    nova funció f_alpln341 (Situació contractes).
     26/06/2007 GEH Ref.1534 Función que genera el fichero mensual de los movimientos de planes de pensiones
     11/07/2007 GEH Ref.2506 Modificación de la función F_SNCTR002 para separar las columnas de nombre, apellidos y DNI
   */
   v_ruta CONSTANT VARCHAR2(100) := f_parinstalacion_t('INFORMES');

   --  Utilitzat per les funcions del Des. 3530 i família
   TYPE tt_index IS TABLE OF NUMBER(6)
      INDEX BY PLS_INTEGER;

   TYPE tt_valor IS TABLE OF NUMBER   --20-03NUMBER(16, 2)
      INDEX BY PLS_INTEGER;

   TYPE rt_dies IS RECORD(
      valor_1        tt_valor,   -- Guardem l'import a la columna del producte-durada per primes inicials / extraordinàries
      valor_2        tt_valor,   -- Guardem l'import a la columna del producte-durada per primes perìodiques
      nombre         tt_index   -- Guardem quantes pòlisses a la columna del producte-durada
   );

   TYPE tt_dies IS TABLE OF rt_dies
      INDEX BY PLS_INTEGER;

   --
   --  Funcions privades
   --
   -- Com la funció NVL2 de SQL no va PL/SQL en creem una que faci el mateix
   FUNCTION nvl2x(p1 IN VARCHAR2, p2 IN VARCHAR2, p3 IN VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN CASE
         WHEN p1 IS NOT NULL THEN p2
         ELSE p3
      END;
   END nvl2x;

   FUNCTION fpv_desc0123(
      pcidioma IN idiomas.cidioma%TYPE,
      pcmultilinia IN VARCHAR2,
      pcodi IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN CASE
         WHEN pcmultilinia = 'S'
              AND pcodi = 1 THEN f_axis_literales(103638, pcidioma)   -- Si
         WHEN pcmultilinia = 'N'
              AND pcodi = 1 THEN f_axis_literales(180450, pcidioma)   -- Titular 1er
         WHEN pcodi = 2 THEN f_axis_literales(180451, pcidioma)   -- Titular 2on
         WHEN pcodi = 3 THEN f_axis_literales(180448, pcidioma)   -- Ambdós titulars
      END;
   END fpv_desc0123;

   FUNCTION fpv_desproducto(
      pcidioma IN idiomas.cidioma%TYPE,
      psproduc IN productos.sproduc%TYPE)
      RETURN VARCHAR2 IS
   BEGIN
      FOR r IN (SELECT ttitulo
                  FROM titulopro t, productos p
                 WHERE t.cramo = p.cramo
                   AND t.cmodali = p.cmodali
                   AND t.ctipseg = p.ctipseg
                   AND t.ccolect = p.ccolect
                   AND p.sproduc = psproduc
                   AND cidioma = pcidioma) LOOP
         RETURN r.ttitulo;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fpv_desproducto;

   -- Se busca la descripción de la Agrupación
   FUNCTION fpv_desramo(pcidioma IN idiomas.cidioma%TYPE, pcramo IN seguros.cramo%TYPE)
      RETURN VARCHAR2 IS
   BEGIN
      FOR r IN (SELECT tramo
                  FROM ramos
                 WHERE cidioma = pcidioma
                   AND cramo = pcramo) LOOP
         RETURN r.tramo;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fpv_desramo;

   -- Se busca la descripción de la Agrupación
   FUNCTION fpv_desagrpro(
      pcidioma IN idiomas.cidioma%TYPE,
      pcagrpro IN seguros.cagrpro%TYPE)
      RETURN VARCHAR2 IS
   BEGIN
      FOR r IN (SELECT tagrpro
                  FROM agrupapro
                 WHERE cidioma = pcidioma
                   AND cagrpro = pcagrpro) LOOP
         RETURN r.tagrpro;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fpv_desagrpro;

   -- Se busca la decripción de la Oficina
   FUNCTION fpv_desagente(
      pcidioma IN idiomas.cidioma%TYPE,
      pcagente IN seguros.cagente%TYPE)
      RETURN VARCHAR2 IS
      v_desoficina   VARCHAR2(2000);
   BEGIN
      IF f_desagente(pcagente, v_desoficina) <> 0 THEN
         RETURN '**********************************';
      END IF;

      RETURN v_desoficina;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fpv_desagente;

   -- Se busca la descripción de la empresa
   FUNCTION fpv_desempresa(pcempresa IN empresas.cempres%TYPE)
      RETURN VARCHAR2 IS
      v_empresa      VARCHAR2(2000);
   BEGIN
      IF f_desempresa(pcempresa, NULL, v_empresa) <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN v_empresa;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fpv_desempresa;

   FUNCTION fpv_descausasini(pcidioma IN idiomas.cidioma%TYPE, pscausin IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      FOR r IN (SELECT tcausin
                  FROM causasini
                 WHERE ccausin = pscausin
                   AND cidioma = pcidioma) LOOP
         RETURN r.tcausin;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fpv_descausasini;

   FUNCTION titulo_generico(pusuidioma IN idiomas.cidioma%TYPE)
      RETURN VARCHAR2 IS
   BEGIN
      IF pusuidioma IS NOT NULL THEN
         RETURN f_axis_literales(111204, pusuidioma)   -- Código agrupación
                                                    || ';'
                || f_axis_literales(111471, pusuidioma)   -- Agrupación
                                                       || ';'
                || f_axis_literales(100784, pusuidioma)   -- Ramo
                                                       || ';'
                || f_axis_literales(102053, pusuidioma)   -- Descripción ramo
                                                       || ';'
                || f_axis_literales(100784, pusuidioma)   -- Ramo
                                                       || ';'
                || f_axis_literales(100943, pusuidioma)   -- Modalidad
                                                       || ';'
                || f_axis_literales(102098, pusuidioma)   -- Tipo Seguro
                                                       || ';'
                || f_axis_literales(180571, pusuidioma)   -- Colectividad
                                                       || ';'
                || f_axis_literales(100829, pusuidioma)   -- Producto
                                                       ;
      END IF;

      RETURN ';;;;;;;;';
   END titulo_generico;

   FUNCTION linea_generico(
      pusuidioma IN idiomas.cidioma%TYPE,
      psproduc IN seguros.sproduc%TYPE)
      RETURN VARCHAR2 IS
   BEGIN
      IF psproduc IS NOT NULL THEN
         FOR r IN (SELECT cagrpro, cmodali, ctipseg, ccolect, cramo
                     FROM productos
                    WHERE sproduc = psproduc) LOOP
            RETURN r.cagrpro || ';' || fpv_desagrpro(pusuidioma, r.cagrpro) || ';' || r.cramo
                   || ';' || fpv_desramo(pusuidioma, r.cramo) || ';' || r.cramo || ';'
                   || r.cmodali || ';' || r.ctipseg || ';' || r.ccolect || ';'
                   || fpv_desproducto(pusuidioma, psproduc);
         END LOOP;
      END IF;

      RETURN ';;;;;;;;' || fpv_desproducto(pusuidioma, psproduc);
   END linea_generico;

   FUNCTION linea_generico(
      pusuidioma IN idiomas.cidioma%TYPE,
      pcagrpro IN seguros.cagrpro%TYPE,
      pcramo IN seguros.cramo%TYPE,
      pcmodali IN seguros.cmodali%TYPE,
      pctipseg IN seguros.ctipseg%TYPE,
      pccolect IN seguros.ccolect%TYPE)
      RETURN VARCHAR2 IS
      v_desproducto  VARCHAR2(200);
   BEGIN
      -- Se busca la descripción del producto
      BEGIN
         IF f_desproducto(pcramo, pcmodali, 1, pusuidioma, v_desproducto, pctipseg, pccolect) <>
                                                                                             0 THEN
            v_desproducto := NULL;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            v_desproducto := NULL;
      END;

      RETURN pcagrpro || ';' || fpv_desagrpro(pusuidioma, pcagrpro) || ';' || pcramo || ';'
             || fpv_desramo(pusuidioma, pcramo) || ';' || pcramo || ';' || pcmodali || ';'
             || pctipseg || ';' || pccolect || ';' || v_desproducto;
   END linea_generico;

   FUNCTION f_reabrir_fichero(
      p_fichero IN OUT UTL_FILE.file_type,
      pnombre_excel IN VARCHAR2,
      p_num_excel IN OUT NUMBER)
      RETURN NUMBER IS
      /* Función que cierra un fichero excel y abre otro con el mismo nombre*/
      v_ruta         VARCHAR2(100);
      v_nomfit       VARCHAR2(100);
   BEGIN
      -- Se cierra el fichero Excel
      IF UTL_FILE.is_open(p_fichero) = TRUE THEN
         UTL_FILE.fclose(p_fichero);
      END IF;

      -- Se abre otro fichero Excel
      p_num_excel := p_num_excel + 1;
      v_ruta := f_parinstalacion_t('INFORMES');
      v_nomfit := pnombre_excel || '_' || TO_CHAR(f_sysdate, 'YYYYMMDD_HH24MISS') || '_'
                  || p_num_excel || '.csv';

      IF UTL_FILE.is_open(p_fichero) = FALSE THEN
         p_fichero := UTL_FILE.fopen(v_ruta, v_nomfit, 'W');
      END IF;

      cont := cont + 1;
      v_nombre_fichero(cont).nombre := v_nomfit;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, getuser, 'pac_excel.f_reabrir_fichero', NULL,
                     ' pnombre_excel = ' || pnombre_excel || ' p_num_excel = ' || p_num_excel,
                     f_axis_literales(151016, f_idiomauser) || ' - ' || SQLERRM);
         RETURN 151016;   -- Error al crear el fichero
   END f_reabrir_fichero;

   --
   -- Funcions públiques
   --
   FUNCTION f_fichero_produccion(
      pfecha IN DATE DEFAULT f_sysdate,
      cproces IN OUT NUMBER,
      pempres IN NUMBER)
      RETURN VARCHAR2 IS
      fichero        UTL_FILE.file_type;
      rutafich       VARCHAR2(255);
      nomfich        VARCHAR2(255);
      linea          VARCHAR2(500);
      vproces        NUMBER;
      num_err        NUMBER;
      numlinea       NUMBER;
      tmovim         VARCHAR2(15);
      fdesde         DATE := TO_DATE('01' || TO_CHAR(pfecha, 'mmyyyy'), 'ddmmyyyy');
   BEGIN
      IF cproces IS NULL THEN
         num_err := f_procesini(getuser, pempres, 'ESTAD_PROD',
                                'Estadística producción de ' || TO_CHAR(pfecha, 'dd-mm-yyyy'),
                                vproces);
      ELSE
         vproces := cproces;
      END IF;

      --rutafich := f_parinstalacion_t('PATH_DOMIS');
      rutafich := f_parempresa_t('PATH_DOMIS');
      nomfich := 'Estadistica_Produccion_' || TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '.csv';
      fichero := UTL_FILE.fopen(rutafich, nomfich, 'w');
      linea := 'PRODUCTO;DESCRIPCION;MOVIMIENTO;OFICINA;CANTIDAD;FECHADESDE;FECHAHASTA';
      UTL_FILE.put_line(fichero, linea);

      /* Cursor diario */
      FOR aux IN
         (SELECT   s.cramo || '-' || s.cmodali || '-' || s.ctipseg || '-'
                   || s.ccolect "PRODUCTO",
                   t.ttitulo "DESCRIPCION", TRUNC(m.femisio) AS femisio,   --DECODE (m.femisio, NULL, 'SOLICITUD', 'ALTA') "MOVIMIENTO",
                                                                        s.cagente "OFICINA",
                   COUNT(1) "CANTIDAD"
              FROM seguros s, movseguro m, titulopro t
             WHERE s.sseguro = m.sseguro
               AND m.cmotmov = 100   -- MOVIMIENTO DE ALTA
               AND(TRUNC(m.fmovimi) = TRUNC(pfecha)
                   OR TRUNC(m.femisio) = TRUNC(pfecha))
               AND s.cramo = t.cramo
               AND s.cmodali = t.cmodali
               AND s.ctipseg = t.ctipseg
               AND s.ccolect = t.ccolect
               AND t.cidioma = 2
          GROUP BY s.cramo || '-' || s.cmodali || '-' || s.ctipseg || '-' || s.ccolect,
                   t.ttitulo, TRUNC(m.femisio),   --DECODE (m.femisio, NULL, 'SOLICITUD', 'ALTA'),
                                               s.cagente) LOOP
         IF aux.femisio IS NULL THEN
            tmovim := 'SOLICITUD';
         ELSIF TRUNC(aux.femisio) <= TRUNC(pfecha) THEN
            tmovim := 'ALTA';
         END IF;

         linea := aux.producto || ';' || aux.descripcion || ';' || tmovim || ';' || aux.oficina
                  || ';' || aux.cantidad || ';' || TO_CHAR(pfecha, 'dd-mm-yyyy') || ';'
                  || TO_CHAR(pfecha, 'dd-mm-yyyy');
         UTL_FILE.put_line(fichero, linea);
      END LOOP;

      /* Cursor acumulado mensual */
      FOR aux IN (SELECT   s.cramo || '-' || s.cmodali || '-' || s.ctipseg || '-'
                           || s.ccolect "PRODUCTO",
                           t.ttitulo "DESCRIPCION",
                           DECODE(m.femisio, NULL, 'SOLICITUD', 'ALTA') "MOVIMIENTO",
                           s.cagente "OFICINA", COUNT(1) "CANTIDAD"
                      FROM seguros s, movseguro m, titulopro t
                     WHERE s.sseguro = m.sseguro
                       AND m.cmotmov = 100   -- MOVIMIENTO DE ALTA
                       AND TRUNC(m.fmovimi) BETWEEN TRUNC(fdesde) AND TRUNC(pfecha)
                       AND s.cramo = t.cramo
                       AND s.cmodali = t.cmodali
                       AND s.ctipseg = t.ctipseg
                       AND s.ccolect = t.ccolect
                       AND t.cidioma = 2
                  GROUP BY s.cramo || '-' || s.cmodali || '-' || s.ctipseg || '-' || s.ccolect,
                           t.ttitulo, DECODE(m.femisio, NULL, 'SOLICITUD', 'ALTA'), s.cagente) LOOP
         linea := aux.producto || ';' || aux.descripcion || ';' || aux.movimiento || ';'
                  || aux.oficina || ';' || aux.cantidad || ';'
                  || TO_CHAR(fdesde, 'dd-mm-yyyy') || ';' || TO_CHAR(pfecha, 'dd-mm-yyyy');
         UTL_FILE.put_line(fichero, linea);
      END LOOP;

      IF UTL_FILE.is_open(fichero) THEN
         UTL_FILE.fclose(fichero);
      END IF;

      num_err := f_proceslin(vproces, 'Proceso finalizado.', 0, numlinea, 4);

      IF cproces IS NULL THEN
         num_err := f_procesfin(vproces, 0);
      END IF;

      cproces := vproces;
      RETURN nomfich;
   EXCEPTION
      WHEN OTHERS THEN
         numlinea := NULL;
         num_err := f_proceslin(vproces, SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 150), 0,
                                numlinea, 1);

         IF UTL_FILE.is_open(fichero) THEN
            UTL_FILE.fclose(fichero);
         END IF;

         IF cproces IS NULL THEN
            num_err := f_procesfin(vproces, 1);
         END IF;

         cproces := vproces;
         RETURN NULL;
   END f_fichero_produccion;

   FUNCTION f_alctr651(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pmesanyo IN DATE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pagente IN NUMBER,
      pusuidioma IN NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp IS
      v_ruta         VARCHAR2(100);
      v_nomfit       VARCHAR2(100);
      v_fichero      UTL_FILE.file_type;
      v_nombre_excel VARCHAR2(100);
      cadena         VARCHAR2(1000);
      cabecera       VARCHAR2(1000);
      v_descramodgs  VARCHAR2(200);
      v_desproducto  VARCHAR2(200);
      v_poliza_antigua cnvpolizas.polissa_ini%TYPE;   --       v_poliza_antigua VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nif          VARCHAR2(15);
      v_sperson      tomadores.sperson%TYPE;   --       v_sperson      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_tomador      VARCHAR2(200);
      v_idioma_tomador NUMBER;
      v_riesgos      NUMBER;
      v_prima_sfp    seguros.iprianu%TYPE;   --NUMBER;
      v_empresa      VARCHAR2(200);
      v_desagente    VARCHAR2(200);
      v_num_lin      NUMBER;
      v_num_excel    NUMBER := 1;
      num_err        NUMBER;
      v_literal_tots CONSTANT VARCHAR2(20) := f_axis_literales(100934, pusuidioma);   -- Tots
      v_literal_totes CONSTANT VARCHAR2(20) := f_axis_literales(103233, pusuidioma);   -- Totes
      error          EXCEPTION;

      FUNCTION f_cabecera(p_num_lin IN OUT NUMBER)
         RETURN NUMBER IS
      BEGIN
         p_num_lin := 0;

         -- Se busca la descripción de la empresa
         BEGIN
            num_err := f_desempresa(pcempres, NULL, v_empresa);
         EXCEPTION
            WHEN OTHERS THEN
               v_empresa := NULL;
         END;

         cabecera := f_axis_literales(100857, pusuidioma)   -- Empresa
                                                         || ';'
                     || v_empresa   -- Descripción de la Empresa
                                 || ';' || ' '   -- Columna en blanco
                                              || ';' || ' '   -- Columna en blanco
                                                           || ';'
                     || f_axis_literales(100550, pusuidioma)   -- Fecha
                                                            || ';' || pmesanyo;   -- Descripcion de la Fecha
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := f_axis_literales(100765, pusuidioma)   -- Ramo:
                                                         || ';'
                     || nvl2x(pcramo, fpv_desramo(pusuidioma, pcramo), v_literal_tots)   -- Descripción del Ramo
                     || ';';
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := f_axis_literales(100681, pusuidioma)   -- Producto
                                                         || ';'
                     || nvl2x(psproduc, fpv_desproducto(pusuidioma, psproduc), v_literal_tots)   -- Descripción del Producto
                                                                                              ;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;

         -- Se busca la decripción del agente
         BEGIN
            IF pagente IS NOT NULL THEN
               num_err := f_desagente(pagente, v_desagente);

               IF num_err <> 0 THEN
                  v_desagente := '??';
               END IF;
            ELSE
               v_desagente := NULL;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_desagente := NULL;
         END;

         cabecera := NULL;
         cabecera := f_axis_literales(100871, pusuidioma)   -- Agente
                                                         || ';' || pagente || ' - '
                     || v_desagente;   -- Código y Descripción del agente
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         -- Se insertan dos lineas en blanco
         cabecera := NULL;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := NULL;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := f_axis_literales(107248, pusuidioma)   -- Ramo DGS
                                                         || ';'
                     || f_axis_literales(102053, pusuidioma)   -- Descripción ramo
                                                            || ';'
                     || f_axis_literales(100784, pusuidioma)   -- Ramo
                                                            || ';'
                     || f_axis_literales(100943, pusuidioma)   -- Modalidad
                                                            || ';'
                     || f_axis_literales(102098, pusuidioma)   -- Tipo Seguro
                                                            || ';'
                     || f_axis_literales(180571, pusuidioma)   -- Colectividad
                                                            || ';'
                     || f_axis_literales(100829, pusuidioma)   -- Producto
                                                            || ';'
                     || f_axis_literales(104934, pusuidioma)   -- Pól. Antigua
                                                            || ';'
                     || f_axis_literales(101273, pusuidioma)   -- Póliza
                                                            || ';'
                     || f_axis_literales(104595, pusuidioma)   -- Certificado
                                                            || ';'
                     || f_axis_literales(102347, pusuidioma)   -- Oficina
                                                            || ';'
                     || f_axis_literales(180572, pusuidioma)   -- NIF tomador
                                                            || ';'
                     || f_axis_literales(101027, pusuidioma)   -- Tomador
                                                            || ';'
                     || f_axis_literales(105808, pusuidioma)   -- Nº Asegur.
                                                            || ';'
                     || f_axis_literales(101672, pusuidioma)   -- Prima anual
                                                            || ';'
                     || f_axis_literales(151227, pusuidioma)   -- Prima s./f.p.
                                                            || ';'
                     || f_axis_literales(180063, pusuidioma)   -- Cap. Fallecimiento
                                                            || ';'
                     || f_axis_literales(107118, pusuidioma)   -- Capital garantizado
                                                            || ';'
                     || f_axis_literales(107120, pusuidioma)   -- Provisión matemática
                                                            || ';';
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, getuser, 'pac_excel.f_alctr651.f_cabecera', NULL,
                        'p_num_lin =' || p_num_lin, SQLERRM);
            RETURN -1;
      END f_cabecera;
   BEGIN
      IF psproces IS NULL
         OR pmesanyo IS NULL
         --OR pagente IS NULL
         OR pusuidioma IS NULL THEN
         RAISE error;
      --RETURN -1;
      END IF;

      v_ruta := f_parinstalacion_t('INFORMES');
      v_nombre_excel := 'alctr651';
      v_nomfit := v_nombre_excel || '_' || TO_CHAR(f_sysdate, 'YYYYMMDD_HH24MISS') || '.csv';

      IF UTL_FILE.is_open(v_fichero) = FALSE THEN
         v_fichero := UTL_FILE.fopen(v_ruta, v_nomfit, 'W');
      END IF;

      cont := cont + 1;
      v_nombre_fichero(cont).nombre := v_nomfit;
      num_err := f_cabecera(v_num_lin);

      IF num_err <> 0 THEN
         RAISE error;
      --         RETURN -1;
      END IF;

      FOR reg IN (SELECT   p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                           s.npoliza, s.ncertif, s.nduraci, s.fefecto, s.sproduc,
                           SUM(p.ipriini) prima_anual, SUM(p.ivalact) cap_fallec,
                           SUM(p.icapgar) cap_garant, SUM(ipromat) prov_mat, s.iprianu,
                           s.cagente
                      FROM seguros s,
                           (SELECT cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg,
                                   ccolect, sseguro, cgarant, cprovis, ipriini, ivalact,
                                   icapgar, ipromat, cerror, nriesgo
                              FROM provmat
                             WHERE sproces = psproces
                            UNION
                            SELECT cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg,
                                   ccolect, sseguro, cgarant, cprovis, ipriini, ivalact,
                                   icapgar, ipromat, cerror, nriesgo
                              FROM provmat_previo
                             WHERE sproces = psproces) p,
                           seguredcom src
                     WHERE sproces = psproces
                       AND p.sseguro = s.sseguro
                       AND(s.sproduc = psproduc
                           OR psproduc IS NULL)
                       AND(s.cramo = pcramo
                           OR pcramo IS NULL)
                       AND s.cagente = pagente
                       AND src.sseguro = p.sseguro
                       AND src.fmovini <= pmesanyo
                       AND(src.fmovfin > pmesanyo
                           OR src.fmovfin IS NULL)
                       AND src.cageseg = pagente
                       AND pagente IS NOT NULL
                  GROUP BY p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                           s.npoliza, s.ncertif, s.nduraci, s.fefecto, s.sproduc, s.iprianu,
                           s.cagente
                  UNION
                  SELECT   p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                           s.npoliza, s.ncertif, s.nduraci, s.fefecto, s.sproduc,
                           SUM(p.ipriini) prima_anual, SUM(p.ivalact) cap_fallec,
                           SUM(p.icapgar) cap_garant, SUM(ipromat) prov_mat, s.iprianu,
                           s.cagente
                      FROM seguros s,
                           (SELECT cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg,
                                   ccolect, sseguro, cgarant, cprovis, ipriini, ivalact,
                                   icapgar, ipromat, cerror, nriesgo
                              FROM provmat
                             WHERE sproces = psproces
                            UNION
                            SELECT cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg,
                                   ccolect, sseguro, cgarant, cprovis, ipriini, ivalact,
                                   icapgar, ipromat, cerror, nriesgo
                              FROM provmat_previo
                             WHERE sproces = psproces) p
                     WHERE sproces = psproces
                       AND p.sseguro = s.sseguro
                       AND(s.sproduc = psproduc
                           OR psproduc IS NULL)
                       AND(s.cramo = pcramo
                           OR pcramo IS NULL)
                       AND pagente IS NULL
                  GROUP BY p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                           s.npoliza, s.ncertif, s.nduraci, s.fefecto, s.sproduc, s.iprianu,
                           s.cagente
                  ORDER BY 7, 8) LOOP
         -- Si el número de lineas del fichero excel supera las 65000 lineas, se debe cerrar el fichero excel y abrir otro
         IF v_num_lin >= 65000 THEN
            num_err := f_reabrir_fichero(v_fichero, v_nombre_excel, v_num_excel);

            IF num_err <> 0 THEN
               RAISE error;
            --             RETURN -1;
            END IF;

            num_err := f_cabecera(v_num_lin);

            IF num_err <> 0 THEN
               RAISE error;
            --             RETURN -1;
            END IF;
         ELSE
            -- Se busca la descripción del ramo
            BEGIN
               num_err := f_desramodgs(reg.cramdgs, pusuidioma, v_descramodgs);

               IF num_err <> 0 THEN
                  v_descramodgs := NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_descramodgs := NULL;
            END;

            -- Se busca la descripción del producto
            BEGIN
               num_err := f_desproducto(reg.cramo, reg.cmodali, 1, pusuidioma, v_desproducto,
                                        reg.ctipseg, reg.ccolect);

               IF num_err <> 0 THEN
                  v_desproducto := NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_desproducto := NULL;
            END;

            -- Se busca la póliza antigua
            BEGIN
               SELECT polissa_ini
                 INTO v_poliza_antigua
                 FROM cnvpolizas
                WHERE sseguro = reg.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  v_poliza_antigua := NULL;
            END;

            -- Se busca el Nif, Nombre y Apellidos del Tomador
            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM tomadores
                WHERE sseguro = reg.sseguro;

               v_nif := ff_buscanif(v_sperson);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nif := NULL;
            END;

            BEGIN
               v_idioma_tomador := pusuidioma;
               num_err := f_tomador(reg.sseguro, 1, v_tomador, v_idioma_tomador);
            EXCEPTION
               WHEN OTHERS THEN
                  v_tomador := NULL;
            END;

            -- Se busca el Número de Asegurados
            BEGIN
               IF NVL(f_parproductos_v(reg.sproduc, '2_CABEZAS'), 0) = 1 THEN
                  SELECT COUNT(*)
                    INTO v_riesgos
                    FROM asegurados
                   WHERE sseguro = reg.sseguro
                     AND ffecfin IS NULL;
               ELSE
                  SELECT COUNT(*)
                    INTO v_riesgos
                    FROM riesgos
                   WHERE sseguro = reg.sseguro
                     AND fanulac IS NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_riesgos := NULL;
            END;

            -- Se busca la prima según forma de pago
            BEGIN
               v_prima_sfp := f_prima_forpag('CAR', 2, 1, reg.sseguro, NULL, NULL,
                                             reg.iprianu);
            EXCEPTION
               WHEN OTHERS THEN
                  v_prima_sfp := NULL;
            END;

            cadena := reg.cramdgs || ';' || v_descramodgs || ';' || reg.cramo || ';'
                      || reg.cmodali || ';' || reg.ctipseg || ';' || reg.ccolect || ';'
                      || v_desproducto || ';' || v_poliza_antigua || ';' || reg.npoliza || ';'
                      || reg.ncertif || ';' || reg.cagente || ';' || v_nif || ';' || v_tomador
                      || ';' || v_riesgos || ';' || reg.prima_anual || ';' || v_prima_sfp
                      || ';' || reg.cap_fallec || ';' || reg.cap_garant || ';' || reg.prov_mat;
            UTL_FILE.put_line(v_fichero, cadena);
            v_num_lin := v_num_lin + 1;
            cadena := NULL;
         END IF;
      END LOOP;

      IF UTL_FILE.is_open(v_fichero) = TRUE THEN
         UTL_FILE.fclose(v_fichero);
      END IF;

      --      RETURN v_nomfit;
      RETURN v_nombre_fichero;
   EXCEPTION
      WHEN error THEN
         perror := -1;
         v_nombre_fichero(cont).nombre := NULL;
         RETURN v_nombre_fichero;
   END f_alctr651;

   FUNCTION f_sictr009(
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pagente IN NUMBER,
      pestado IN NUMBER,
      pusuidioma IN NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp IS
      v_ruta         VARCHAR2(100);
      v_nomfit       VARCHAR2(100);
      v_fichero      UTL_FILE.file_type;
      v_nombre_excel VARCHAR2(100);
      cadena         VARCHAR2(1000);
      cabecera       VARCHAR2(1000);
      v_num_lin      NUMBER;
      v_num_excel    NUMBER := 1;
      k_tot_ple CONSTANT BOOLEAN := TRUE;   -- No volem que deixi caselles en blanc
      num_err        NUMBER;
      v_empresa      VARCHAR2(200);
      v_tagrpro      agrupapro.tagrpro%TYPE;   --       v_tagrpro      VARCHAR2(200); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_dessproduc   VARCHAR2(200);
      v_tramo        ramos.tramo%TYPE;   --       v_tramo        VARCHAR2(200); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_desproducto  VARCHAR2(200);
      v_desoficina   VARCHAR2(200);
      v_numtel       VARCHAR2(100);
      v_desestat     VARCHAR2(200);
      v_person       VARCHAR2(200);
      v_nif          VARCHAR2(20);
      v_prima        seguros.iprianu%TYPE;   --20.03NUMBER(13, 2);
      v_provmat      seguros.iprianu%TYPE;   --20.03NUMBER(13, 2);
      v_dessexo      VARCHAR2(200);
      v_sseguro_ant  NUMBER;
      error          EXCEPTION;

      FUNCTION f_cabecera(p_num_lin IN OUT NUMBER)
         RETURN NUMBER IS
      BEGIN
         p_num_lin := 0;

         -- Se busca la descripción de la empresa
         BEGIN
            num_err := f_desempresa(pcempres, NULL, v_empresa);
         EXCEPTION
            WHEN OTHERS THEN
               v_empresa := NULL;
         END;

         cabecera := f_axis_literales(100857, pusuidioma)   -- Empresa
                                                         || ';' || v_empresa;   -- Descripción de la Empresa
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;

         -- Se busca la descripción de la Agrupación
         BEGIN
            IF pcagrpro IS NULL THEN
               v_tagrpro := f_axis_literales(100934, pusuidioma);   -- Todos
            ELSE
               SELECT tagrpro
                 INTO v_tagrpro
                 FROM agrupapro
                WHERE cidioma = pusuidioma
                  AND cagrpro = pcagrpro;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_tagrpro := NULL;
         END;

         -- Se busca la descripción del ramo
         BEGIN
            IF pcramo IS NULL THEN
               v_tramo := f_axis_literales(100934, pusuidioma);   -- Todos
            ELSE
               SELECT tramo
                 INTO v_tramo
                 FROM ramos
                WHERE cramo = pcramo
                  AND cidioma = pusuidioma;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_tramo := NULL;
         END;

         cabecera := NULL;
         cabecera := f_axis_literales(100706, pusuidioma)   -- Agrupación:
                                                         || ';'
                     || v_tagrpro   -- Descripción de la Agrupación
                                 || ';' || ' '   -- Columna en blanco
                                              || ';'
                     || f_axis_literales(100765, pusuidioma)   -- Ramo:
                                                            || ';' || v_tramo;   -- Descripción del Ramo
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;

         -- Se busca la decripción del producto
         BEGIN
            IF psproduc IS NULL THEN
               v_dessproduc := f_axis_literales(100934, pusuidioma);   -- Todos
            ELSE
               SELECT ttitulo
                 INTO v_dessproduc
                 FROM titulopro t, productos p
                WHERE t.cramo = p.cramo
                  AND t.cmodali = p.cmodali
                  AND t.ctipseg = p.ctipseg
                  AND t.ccolect = p.ccolect
                  AND p.sproduc = psproduc
                  AND cidioma = pusuidioma;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_dessproduc := NULL;
         END;

         cabecera := NULL;
         cabecera := f_axis_literales(100681, pusuidioma)   -- Producto
                                                         || ';' || v_dessproduc;   -- Descripción del Producto
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;

         -- Se busca la decripción de la Oficina
         BEGIN
            IF pagente IS NULL THEN
               v_desoficina := f_axis_literales(103233, pusuidioma);   -- Todas
            ELSE
               num_err := f_desagente(pagente, v_desoficina);

               IF num_err <> 0 THEN
                  v_desoficina := '**********************************';
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_desoficina := NULL;
         END;

         -- Se busca la decripción del Estado
         BEGIN
            IF pestado IS NULL THEN
               v_desestat := f_axis_literales(100934, pusuidioma);   -- Todos
            ELSE
               num_err := f_desvalorfijo(61, pusuidioma, pestado, v_desestat);

               IF num_err <> 0 THEN
                  v_desestat := NULL;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_desestat := NULL;
         END;

         cabecera := NULL;
         cabecera := f_axis_literales(102591, pusuidioma)   -- Oficina:
                                                         || ';'
                     || v_desoficina   -- Descripción de la Oficina
                                    || ';' || ' '   -- Columna en blanco
                                                 || ';'
                     || f_axis_literales(100554, pusuidioma)   -- Estado:
                                                            || ';' || v_desestat;   -- Descripción del Estado
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         -- Se insertan dos lineas en blanco
         cabecera := NULL;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := NULL;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := titulo_generico(pusuidioma) || ';'
                     || f_axis_literales(101273, pusuidioma)   -- Póliza
                                                            || ';'
                     || f_axis_literales(104595, pusuidioma)   -- Certificado
                                                            || ';'
                     || f_axis_literales(109528, pusuidioma)   -- Solicitud
                                                            || ';'
                     || f_axis_literales(102348, pusuidioma)   -- Código de la oficina
                                                            || ';'
                     || f_axis_literales(102347, pusuidioma)   -- Oficina
                                                            || ';'
                     || f_axis_literales(101510, pusuidioma)   -- Estado
                                                            || ';'
                     || f_axis_literales(101028, pusuidioma)   -- Asegurado
                                                            || ';'
                     || f_axis_literales(100577, pusuidioma)   -- NIF
                                                            || ';'
                     || f_axis_literales(100959, pusuidioma)   -- F. nacimiento
                                                            || ';'
                     || f_axis_literales(100962, pusuidioma)   -- Sexo
                                                            || ';'
                     || CASE
                        WHEN k_tot_ple THEN 'N;'
                        ELSE NULL
                     END   -- Ordre de l'assegurat dins la pòlissa
                     || f_axis_literales(101368, pusuidioma)   -- Prima
                                                            || ';'
                     || f_axis_literales(107120, pusuidioma)   -- Provisión matemática
                                                            || ';'
                     || f_axis_literales(101332, pusuidioma)   -- F. Efecto
                                                            || ';'
                     || f_axis_literales(110518, pusuidioma);   -- F. Anulación
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, getuser, 'pac_excel.f_sictr009.f_cabecera', NULL,
                        'p_num_lin =' || p_num_lin, SQLERRM);
            RETURN -1;
      END f_cabecera;
   BEGIN
      IF pcempres IS NULL
         OR pusuidioma IS NULL THEN
         RAISE error;
      --RETURN -1;
      END IF;

      v_ruta := f_parinstalacion_t('INFORMES');
      v_nombre_excel := 'sictr009';
      v_nomfit := v_nombre_excel || '_' || TO_CHAR(f_sysdate, 'YYYYMMDD_HH24MISS') || '.csv';

      IF UTL_FILE.is_open(v_fichero) = FALSE THEN
         v_fichero := UTL_FILE.fopen(v_ruta, v_nomfit, 'W');
      END IF;

      cont := cont + 1;
      v_nombre_fichero(cont).nombre := v_nomfit;
      num_err := f_cabecera(v_num_lin);

      IF num_err <> 0 THEN
         RAISE error;
      --RETURN -1;
      END IF;

      v_sseguro_ant := NULL;   -- Se inicializa la variable que guarda el valor del seguro anterior

      --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
      FOR reg IN
         (SELECT   s.sseguro, s.cagrpro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sproduc,
                   s.cagente, s.npoliza, s.ncertif,
                   DECODE(s.csituac, 0, 0, 5, 0, 2, 2, 3, 2) estado_seguro, s.nsolici,
                   TO_CHAR(s.fefecto, 'dd/mm/yyyy') fefecto,
                   TO_CHAR(s.fanulac, 'dd/mm/yyyy') fanulac,
                   SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' '
                   || SUBSTR(d.tapelli2, 0, 20) nombre,
                   p.nnumide nnumnif, TO_CHAR(p.fnacimi, 'dd/mm/yyyy') fnacimi, p.csexper,
                   RANK() OVER(PARTITION BY s.sseguro ORDER BY aseg.norden) rang_norden   -- Numerem els assegurats que te de 1 en endavant
              FROM seguros s, asegurados aseg, per_personas p, per_detper d
             WHERE d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
               AND aseg.sseguro = s.sseguro
               AND aseg.sperson = p.sperson
               AND(aseg.ffecfin IS NULL
                   OR aseg.ffecfin > ADD_MONTHS(s.fanulac, -1))   -- las pólizas de TAR anuladas que se han migrado tienen la ffecfin del asegurado informado,
                                                                  -- pero se deben mostrar dichas pólizas con sus asegurados
               AND s.cempres = NVL(pcempres, 1)
               AND s.cagrpro = NVL(pcagrpro, s.cagrpro)
               AND s.cramo = NVL(pcramo, s.cramo)
               AND s.sproduc = NVL(psproduc, s.sproduc)
               AND s.cagente = NVL(pagente, s.cagente)
               AND((pestado = 0
                    AND s.csituac IN(0, 5))
                   OR(pestado = 2
                      AND s.csituac IN(2, 3))
                   OR(pestado IS NULL))
               AND csituac <> 4   -- las propuestas de alta no se deben mostrar
          ORDER BY s.cagrpro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.npoliza, s.ncertif,
                   aseg.norden) LOOP
         /*FOR reg IN
         (SELECT   s.sseguro, s.cagrpro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sproduc,
                   s.cagente, s.npoliza, s.ncertif,
                   DECODE(s.csituac, 0, 0, 5, 0, 2, 2, 3, 2) estado_seguro, s.nsolici,
                   TO_CHAR(s.fefecto, 'dd/mm/yyyy') fefecto,
                   TO_CHAR(s.fanulac, 'dd/mm/yyyy') fanulac,
                   p.tnombre || ' ' || p.tapelli nombre, p.nnumnif,
                   TO_CHAR(p.fnacimi, 'dd/mm/yyyy') fnacimi, p.csexper,
                   RANK() OVER(PARTITION BY s.sseguro ORDER BY aseg.norden) rang_norden   -- Numerem els assegurats que te de 1 en endavant
              FROM seguros s, asegurados aseg, personas p
             WHERE aseg.sseguro = s.sseguro
               AND aseg.sperson = p.sperson
               AND(aseg.ffecfin IS NULL
                   OR aseg.ffecfin > ADD_MONTHS(s.fanulac, -1))   -- las pólizas de TAR anuladas que se han migrado tienen la ffecfin del asegurado informado,
                                                                  -- pero se deben mostrar dichas pólizas con sus asegurados
               AND s.cempres = NVL(pcempres, 1)
               AND s.cagrpro = NVL(pcagrpro, s.cagrpro)
               AND s.cramo = NVL(pcramo, s.cramo)
               AND s.sproduc = NVL(psproduc, s.sproduc)
               AND s.cagente = NVL(pagente, s.cagente)
               AND((pestado = 0
                    AND s.csituac IN(0, 5))
                   OR(pestado = 2
                      AND s.csituac IN(2, 3))
                   OR(pestado IS NULL))
               AND csituac <> 4   -- las propuestas de alta no se deben mostrar
          ORDER BY s.cagrpro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.npoliza, s.ncertif,
                   aseg.norden) LOOP*/

         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)

         -- Si el número de lineas del fichero excel supera las 65000 lineas, se debe cerrar el fichero excel y abrir otro
         IF v_num_lin >= 65000 THEN
            num_err := f_reabrir_fichero(v_fichero, v_nombre_excel, v_num_excel);

            IF num_err <> 0 THEN
               RAISE error;
            --RETURN -1;
            END IF;

            num_err := f_cabecera(v_num_lin);

            IF num_err <> 0 THEN
               RAISE error;
            --RETURN -1;
            END IF;
         ELSE
            -- Se busca la descripción de la oficina
            BEGIN
               num_err := f_desagente(reg.cagente, v_desoficina);

               IF num_err <> 0 THEN
                  v_desoficina := '**********************************';
               END IF;
            END;

            -- Se busca el Estado del Seguro
            BEGIN
               num_err := f_desvalorfijo(61, pusuidioma, reg.estado_seguro, v_desestat);

               IF num_err <> 0 THEN
                  v_desestat := NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_desestat := NULL;
            END;

            -- Se busca la Prima
            BEGIN
               IF reg.cagrpro = 1 THEN   -- Vida Riesgo
                  v_prima := f_prima_forpag('SEG', 2, 1, reg.sseguro, NULL, NULL,
                                            f_segprima(reg.sseguro, f_sysdate, 'SEG'), NULL);
               ELSE
                  v_prima := f_segprima(reg.sseguro, f_sysdate, 'SEG');
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_prima := 0;
            END;

            -- Se busca la Provisión
            BEGIN
               IF reg.cagrpro <> 1 THEN   -- No es Vida Riesgo
                  v_provmat := fbuscasaldo(NULL, reg.sseguro, TO_CHAR(f_sysdate, 'yyyymmdd'));
               ELSIF reg.sproduc IN(41, 42) THEN   -- Rentas
                  v_provmat := fultprovcalc(NULL, reg.sseguro, NULL, NULL,
                                            TO_CHAR(f_sysdate, 'yyyymmdd'), 2);
               ELSE
                  v_provmat := NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_provmat := 0;
            END;

            -- Se busca la descripción del Sexo
            BEGIN
               num_err := f_desvalorfijo(11, pusuidioma, reg.csexper, v_dessexo);

               IF num_err <> 0 THEN
                  v_dessexo := NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_dessexo := NULL;
            END;

            IF NVL(v_sseguro_ant, -1) <> reg.sseguro
               OR k_tot_ple THEN
               cadena := linea_generico(pusuidioma, reg.cagrpro, reg.cramo, reg.cmodali,
                                        reg.ctipseg, reg.ccolect)
                         || ';' || reg.npoliza || ';' || reg.ncertif || ';' || reg.nsolici
                         || ';' || reg.cagente || ';' || v_desoficina || ';' || v_desestat
                         || ';' || reg.nombre   -- Nombre
                                             || ';' || reg.nnumnif   -- Nif
                                                                  || ';'
                         || reg.fnacimi   -- Fecha Nacimiento
                                       || ';' || v_dessexo   -- Sexo
                                                          || ';'
                         || CASE
                            WHEN k_tot_ple THEN reg.rang_norden || ';'
                            ELSE NULL
                         END   -- Ordre de l'assegurat dins la pòlissa
                            || v_prima || ';' || v_provmat || ';' || reg.fefecto || ';'
                         || reg.fanulac;
            ELSE
               cadena := NULL || ';' || NULL || ';' || NULL || ';' || NULL || ';' || NULL
                         || ';' || NULL || ';' || NULL || ';' || NULL || ';' || NULL || ';'
                         || NULL || ';' || NULL || ';' || NULL || ';' || NULL || ';' || NULL
                         || ';' || NULL || ';' || reg.nombre   -- Nombre
                                                            || ';' || reg.nnumnif   -- Nif
                         || ';' || reg.fnacimi   -- Fecha Nacimiento
                                              || ';' || v_dessexo;   -- Sexo
            END IF;

            UTL_FILE.put_line(v_fichero, cadena);
            v_num_lin := v_num_lin + 1;
            cadena := NULL;
            v_sseguro_ant := reg.sseguro;
         END IF;
      END LOOP;

      IF UTL_FILE.is_open(v_fichero) = TRUE THEN
         UTL_FILE.fclose(v_fichero);
      END IF;

      --      RETURN v_nomfit;
      RETURN v_nombre_fichero;
   EXCEPTION
      WHEN error THEN
         perror := -1;
         v_nombre_fichero(cont).nombre := NULL;
         RETURN v_nombre_fichero;
   END f_sictr009;

   FUNCTION f_sictr018(
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pagente IN NUMBER,
      pfechaini IN DATE,
      pfechafin IN DATE,
      pusuidioma IN NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp IS
      v_ruta         VARCHAR2(100);
      v_nomfit       VARCHAR2(100);
      v_fichero      UTL_FILE.file_type;
      v_nombre_excel VARCHAR2(100);
      cadena         VARCHAR2(1000);
      cabecera       VARCHAR2(1000);
      v_num_lin      NUMBER;
      v_num_excel    NUMBER := 1;
      num_err        NUMBER;
      v_empresa      VARCHAR2(200);
      v_tagrpro      agrupapro.tagrpro%TYPE;   --       v_tagrpro      VARCHAR2(200); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_dessproduc   VARCHAR2(200);
      v_tramo        ramos.tramo%TYPE;   --       v_tramo        VARCHAR2(200); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_desproducto  VARCHAR2(200);
      v_desoficina   VARCHAR2(200);
      v_tipoaport    VARCHAR2(200);
      error          EXCEPTION;

      FUNCTION f_cabecera(p_num_lin IN OUT NUMBER)
         RETURN NUMBER IS
      BEGIN
         p_num_lin := 0;

         -- Se busca la descripción de la empresa
         BEGIN
            num_err := f_desempresa(pcempres, NULL, v_empresa);
         EXCEPTION
            WHEN OTHERS THEN
               v_empresa := NULL;
         END;

         cabecera := f_axis_literales(100857, pusuidioma)   -- Empresa
                                                         || ';'
                     || v_empresa   -- Descripción de la Empresa
                                 || ';' || ' '   -- Columna en blanco
                                              || ';' || ' '   -- Columna en blanco
                                                           || ';'
                     || f_axis_literales(101836, pusuidioma)   -- Desde
                                                            || ';'
                     || pfechaini   -- Descripcion de la Desde
                                 || ';' || f_axis_literales(101837, pusuidioma)   -- Hasta
                     || ';' || pfechafin;   -- Descripcion de la Hasta
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;

         -- Se busca la descripción de la Agrupación
         BEGIN
            IF pcagrpro IS NULL THEN
               v_tagrpro := f_axis_literales(100934, pusuidioma);   -- Todos
            ELSE
               SELECT tagrpro
                 INTO v_tagrpro
                 FROM agrupapro
                WHERE cidioma = pusuidioma
                  AND cagrpro = pcagrpro;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_tagrpro := NULL;
         END;

         -- Se busca la descripción del ramo
         BEGIN
            IF pcramo IS NULL THEN
               v_tramo := f_axis_literales(100934, pusuidioma);   -- Todos
            ELSE
               SELECT tramo
                 INTO v_tramo
                 FROM ramos
                WHERE cramo = pcramo
                  AND cidioma = pusuidioma;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_tramo := NULL;
         END;

         cabecera := NULL;
         cabecera := f_axis_literales(100706, pusuidioma)   -- Agrupación:
                                                         || ';'
                     || v_tagrpro   -- Descripción de la Agrupación
                                 || ';' || ' '   -- Columna en blanco
                                              || ';'
                     || f_axis_literales(100765, pusuidioma)   -- Ramo:
                                                            || ';' || v_tramo;   -- Descripción del Ramo
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;

         -- Se busca la decripción del producto
         BEGIN
            IF psproduc IS NULL THEN
               v_dessproduc := f_axis_literales(100934, pusuidioma);
            ELSE
               SELECT ttitulo
                 INTO v_dessproduc
                 FROM titulopro t, productos p
                WHERE t.cramo = p.cramo
                  AND t.cmodali = p.cmodali
                  AND t.ctipseg = p.ctipseg
                  AND t.ccolect = p.ccolect
                  AND p.sproduc = psproduc
                  AND cidioma = pusuidioma;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_dessproduc := NULL;
         END;

         -- Se busca la decripción de la Oficina
         BEGIN
            IF pagente IS NULL THEN
               v_desoficina := f_axis_literales(103233, pusuidioma);   -- Todas
            ELSE
               num_err := f_desagente(pagente, v_desoficina);

               IF num_err <> 0 THEN
                  v_desoficina := '**********************************';
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_desoficina := NULL;
         END;

         cabecera := NULL;
         cabecera := f_axis_literales(100681, pusuidioma)   -- Producto
                                                         || ';'
                     || v_dessproduc   -- Descripción del Producto
                                    || ';' || ' '   -- Columna en blanco
                                                 || ';'
                     || f_axis_literales(102591, pusuidioma)   -- Oficina:
                                                            || ';' || v_desoficina;   -- Descripción de la Oficina
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         -- Se insertan dos lineas en blanco
         cabecera := NULL;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := NULL;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := f_axis_literales(111204, pusuidioma)   -- Código agrupación
                                                         || ';'
                     || f_axis_literales(111471, pusuidioma)   -- Agrupación
                                                            || ';'
                     || f_axis_literales(100784, pusuidioma)   -- Ramo
                                                            || ';'
                     || f_axis_literales(102053, pusuidioma)   -- Descripción ramo
                                                            || ';'
                     || f_axis_literales(100784, pusuidioma)   -- Ramo
                                                            || ';'
                     || f_axis_literales(100943, pusuidioma)   -- Modalidad
                                                            || ';'
                     || f_axis_literales(102098, pusuidioma)   -- Tipo Seguro
                                                            || ';'
                     || f_axis_literales(180571, pusuidioma)   -- Colectividad
                                                            || ';'
                     || f_axis_literales(100829, pusuidioma)   -- Producto
                                                            || ';'
                     || f_axis_literales(101273, pusuidioma)   -- Póliza
                                                            || ';'
                     || f_axis_literales(104595, pusuidioma)   -- Certificado
                                                            || ';'
                     || f_axis_literales(109528, pusuidioma)   -- Solicitud
                                                            || ';'
                     || f_axis_literales(102348, pusuidioma)   -- Código de la oficina
                                                            || ';'
                     || f_axis_literales(102347, pusuidioma)   -- Oficina
                                                            || ';'
                     || f_axis_literales(100577, pusuidioma)   -- NIF
                                                            || ';'
                     || f_axis_literales(101028, pusuidioma)   -- Asegurado
                                                            || ';'
                     || f_axis_literales(100896, pusuidioma)   -- Concepto
                                                            || ';'
                     || f_axis_literales(100563, pusuidioma)   -- Importe
                                                            || ';'
                     || f_axis_literales(100562, pusuidioma);   -- Fecha
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, getuser, 'pac_excel.f_sictr018.f_cabecera', NULL,
                        'p_num_lin =' || p_num_lin, SQLERRM);
            RETURN -1;
      END f_cabecera;
   BEGIN
      IF pcempres IS NULL
         OR pfechaini IS NULL
         OR pfechafin IS NULL
         OR pusuidioma IS NULL THEN
         RAISE error;
      --RETURN -1;
      END IF;

      v_ruta := f_parinstalacion_t('INFORMES');
      v_nombre_excel := 'sictr018';
      v_nomfit := v_nombre_excel || '_' || TO_CHAR(f_sysdate, 'YYYYMMDD_HH24MISS') || '.csv';

      IF UTL_FILE.is_open(v_fichero) = FALSE THEN
         v_fichero := UTL_FILE.fopen(v_ruta, v_nomfit, 'W');
      END IF;

      cont := cont + 1;
      v_nombre_fichero(cont).nombre := v_nomfit;
      num_err := f_cabecera(v_num_lin);

      IF num_err <> 0 THEN
         RAISE error;
      --RETURN -1;
      END IF;

      --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
      FOR reg IN
         (SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sproduc producto, s.npoliza,
                 s.ncertif, SUBSTR(f_formatopol(s.npoliza, s.ncertif, 1), 1, 50) ncontrato,
                 s.sseguro, s.cagrpro, s.nsolici, s.cagente,
                 SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' '
                 || SUBSTR(d.tapelli2, 0, 20) tomador,
                 p.nnumide nif_tomador, ctaseguro.imovimi importe,
                 TO_CHAR(ctaseguro.fvalmov, 'dd/mm/yyyy') fpago,

                 --DECODE(nnumlin, 1, 'I', 'E') TipoAport  -- I = Aportación Inicial, E = Aportación  Extraordinaria, C = Cobro Manual
                 DECODE(nnumlin, 1, 'I', DECODE(ctaseguro.cmovimi, 51, 'EX', 'E')) tipoaport   -- I = Aportación Inicial, E = Aportación  Extraordinaria, EX = Anulación aportacion (Extorno), C = Cobro Manual
            FROM seguros s, tomadores, productos, per_personas p, per_detper d, ctaseguro
           WHERE d.sperson = p.sperson
             AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
             AND s.sseguro = tomadores.sseguro
             AND p.sperson = tomadores.sperson
             AND tomadores.nordtom = 1
             AND s.sproduc = productos.sproduc
             AND s.sseguro = ctaseguro.sseguro
             AND fvalmov BETWEEN pfechaini AND pfechafin
             AND(cmovimi =
                    1   -- sólo se listan las aportaciones iniciales y extraordinarias, NO las periódicas
                 OR cmovimi = 51
                    AND 9 = (SELECT ctiprec
                               FROM recibos
                              WHERE nrecibo = ctaseguro.nrecibo))
             AND s.cempres = pcempres
             AND s.sproduc = NVL(psproduc, s.sproduc)
             AND s.cramo = NVL(pcramo, s.cramo)
             AND s.cagrpro = NVL(pcagrpro, s.cagrpro)
             AND s.cagente = NVL(pagente, s.cagente)
          UNION ALL
          SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sproduc producto, s.npoliza,
                 s.ncertif, SUBSTR(f_formatopol(s.npoliza, s.ncertif, 1), 1, 50) ncontrato,
                 s.sseguro, s.cagrpro, s.nsolici, s.cagente,
                 SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' '
                 || SUBSTR(d.tapelli2, 0, 20) tomador,
                 p.nnumide nif_tomador, v.itotalr importe,
                 TO_CHAR(m.fmovini, 'dd/mm/yyyy') fpago,
                 'C' tipoaport   -- I = Aportación Inicial, E = Aportación  Extraordinaria, C = Cobro Manual
            FROM seguros s, recibos r, movrecibo m, vdetrecibos v, tomadores t, per_personas p,
                 per_detper d
           WHERE d.sperson = p.sperson
             AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
             AND s.sseguro = r.sseguro
             AND s.sseguro = t.sseguro
             AND t.sperson = p.sperson
             AND m.nrecibo = r.nrecibo
             AND r.nrecibo = v.nrecibo
             AND m.ctipcob = 1   --RECIBO COBRADO MANUALMENTE
             AND m.fmovdia BETWEEN TO_DATE(TO_CHAR(pfechaini, 'dd/mm/yyyy') || ' 00:00:00',
                                           'dd/mm/yyyy hh24:mi:ss')
                               AND TO_DATE(TO_CHAR(pfechafin, 'dd/mm/yyyy') || ' 23:59:59',
                                           'dd/mm/yyyy hh24:mi:ss')
             AND s.cempres = pcempres
             AND s.sproduc = NVL(psproduc, s.sproduc)
             AND s.cramo = NVL(pcramo, s.cramo)
             AND s.cagrpro = NVL(pcagrpro, s.cagrpro)
             AND s.cagente = NVL(pagente, s.cagente)
                                                    --ORDER BY S.CRAMO,S.CMODALI,S.CTIPSEG,S.CCOLECT,S.SPRODUC, S.NPOLIZA, S.NCERTIF
         ) LOOP
         /*FOR reg IN
         (SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sproduc producto, s.npoliza,
                 s.ncertif, SUBSTR(f_formatopol(s.npoliza, s.ncertif, 1), 1, 50) ncontrato,
                 s.sseguro, s.cagrpro, s.nsolici, s.cagente,
                 p.tnombre || ' ' || p.tapelli tomador, p.nnumnif nif_tomador,
                 ctaseguro.imovimi importe, TO_CHAR(ctaseguro.fvalmov, 'dd/mm/yyyy') fpago,

                 --DECODE(nnumlin, 1, 'I', 'E') TipoAport  -- I = Aportación Inicial, E = Aportación  Extraordinaria, C = Cobro Manual
                 DECODE(nnumlin, 1, 'I', DECODE(ctaseguro.cmovimi, 51, 'EX', 'E')) tipoaport   -- I = Aportación Inicial, E = Aportación  Extraordinaria, EX = Anulación aportacion (Extorno), C = Cobro Manual
            FROM seguros s, tomadores, productos, personas p, ctaseguro
           WHERE s.sseguro = tomadores.sseguro
             AND p.sperson = tomadores.sperson
             AND tomadores.nordtom = 1
             AND s.sproduc = productos.sproduc
             AND s.sseguro = ctaseguro.sseguro
             AND fvalmov BETWEEN pfechaini AND pfechafin
             AND(cmovimi =
                    1   -- sólo se listan las aportaciones iniciales y extraordinarias, NO las periódicas
                 OR cmovimi = 51
                    AND 9 = (SELECT ctiprec
                               FROM recibos
                              WHERE nrecibo = ctaseguro.nrecibo))
             AND s.cempres = pcempres
             AND s.sproduc = NVL(psproduc, s.sproduc)
             AND s.cramo = NVL(pcramo, s.cramo)
             AND s.cagrpro = NVL(pcagrpro, s.cagrpro)
             AND s.cagente = NVL(pagente, s.cagente)
          UNION ALL
          SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sproduc producto, s.npoliza,
                 s.ncertif, SUBSTR(f_formatopol(s.npoliza, s.ncertif, 1), 1, 50) ncontrato,
                 s.sseguro, s.cagrpro, s.nsolici, s.cagente,
                 p.tnombre || ' ' || p.tapelli tomador, p.nnumnif nif_tomador,
                 v.itotalr importe, TO_CHAR(m.fmovini, 'dd/mm/yyyy') fpago,
                 'C' tipoaport   -- I = Aportación Inicial, E = Aportación  Extraordinaria, C = Cobro Manual
            FROM seguros s, recibos r, movrecibo m, vdetrecibos v, tomadores t, personas p
           WHERE s.sseguro = r.sseguro
             AND s.sseguro = t.sseguro
             AND t.sperson = p.sperson
             AND m.nrecibo = r.nrecibo
             AND r.nrecibo = v.nrecibo
             AND m.ctipcob = 1   --RECIBO COBRADO MANUALMENTE
             AND m.fmovdia BETWEEN TO_DATE(TO_CHAR(pfechaini, 'dd/mm/yyyy') || ' 00:00:00',
                                           'dd/mm/yyyy hh24:mi:ss')
                               AND TO_DATE(TO_CHAR(pfechafin, 'dd/mm/yyyy') || ' 23:59:59',
                                           'dd/mm/yyyy hh24:mi:ss')
             AND s.cempres = pcempres
             AND s.sproduc = NVL(psproduc, s.sproduc)
             AND s.cramo = NVL(pcramo, s.cramo)
             AND s.cagrpro = NVL(pcagrpro, s.cagrpro)
             AND s.cagente = NVL(pagente, s.cagente)
                                                    --ORDER BY S.CRAMO,S.CMODALI,S.CTIPSEG,S.CCOLECT,S.SPRODUC, S.NPOLIZA, S.NCERTIF
         ) LOOP*/

         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         -- Si el número de lineas del fichero excel supera las 65000 lineas, se debe cerrar el fichero excel y abrir otro
         IF v_num_lin >= 65000 THEN
            num_err := f_reabrir_fichero(v_fichero, v_nombre_excel, v_num_excel);

            IF num_err <> 0 THEN
               RAISE error;
            --RETURN -1;
            END IF;

            num_err := f_cabecera(v_num_lin);

            IF num_err <> 0 THEN
               RAISE error;
            --RETURN -1;
            END IF;
         ELSE
            -- Se busca la descripción de la agrupación
            BEGIN
               SELECT tagrpro
                 INTO v_tagrpro
                 FROM agrupapro
                WHERE cidioma = pusuidioma
                  AND cagrpro = reg.cagrpro;
            EXCEPTION
               WHEN OTHERS THEN
                  v_tramo := NULL;
            END;

            -- Se busca la descripción del ramo
            BEGIN
               SELECT tramo
                 INTO v_tramo
                 FROM ramos
                WHERE cramo = reg.cramo
                  AND cidioma = pusuidioma;
            EXCEPTION
               WHEN OTHERS THEN
                  v_tramo := NULL;
            END;

            -- Se busca la descripción del producto
            BEGIN
               num_err := f_desproducto(reg.cramo, reg.cmodali, 1, pusuidioma, v_desproducto,
                                        reg.ctipseg, reg.ccolect);

               IF num_err <> 0 THEN
                  v_desproducto := NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_desproducto := NULL;
            END;

            -- Se busca la descripción de la oficina
            BEGIN
               num_err := f_desagente(reg.cagente, v_desoficina);

               IF num_err <> 0 THEN
                  v_desoficina := '**********************************';
               END IF;
            END;

            -- Se busca la Descripción del Concepto
            BEGIN
               IF reg.tipoaport = 'I' THEN   -- Prima Inicial
                  v_tipoaport := f_axis_literales(107116, pusuidioma);
               ELSIF reg.tipoaport = 'E' THEN   -- Aportación Extraordinaria
                  v_tipoaport := f_axis_literales(180435, pusuidioma);
               ELSIF reg.tipoaport = 'EX' THEN   -- Anulacion aportación (extorno)
                  v_tipoaport := f_axis_literales(500156, pusuidioma) || '('
                                 || f_axis_literales(109474, pusuidioma) || ')';
               ELSIF reg.tipoaport = 'C' THEN   -- Cobro Manual
                  v_tipoaport := f_axis_literales(102132, pusuidioma);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_tipoaport := NULL;
            END;

            cadena := reg.cagrpro || ';' || v_tagrpro || ';' || reg.cramo || ';' || v_tramo
                      || ';' || reg.cramo || ';' || reg.cmodali || ';' || reg.ctipseg || ';'
                      || reg.ccolect || ';' || v_desproducto || ';' || reg.npoliza || ';'
                      || reg.ncertif || ';' || reg.nsolici || ';' || reg.cagente || ';'
                      || v_desoficina || ';' || reg.nif_tomador || ';' || reg.tomador || ';'
                      || v_tipoaport || ';' || reg.importe || ';' || reg.fpago;
            UTL_FILE.put_line(v_fichero, cadena);
            v_num_lin := v_num_lin + 1;
            cadena := NULL;
         END IF;
      END LOOP;

      IF UTL_FILE.is_open(v_fichero) = TRUE THEN
         UTL_FILE.fclose(v_fichero);
      END IF;

      --      RETURN v_nomfit;
      RETURN v_nombre_fichero;
   EXCEPTION
      WHEN error THEN
         perror := -1;
         v_nombre_fichero(cont).nombre := NULL;
         RETURN v_nombre_fichero;
   END f_sictr018;

   /*
   Listado de altas de certificados (LEH)
   */
   FUNCTION f_snctr003(
      pfechaini IN DATE,
      pfechafin IN DATE,
      pempres IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      pcramo IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_ruta         VARCHAR2(100);
      v_nomfit       VARCHAR2(100);
      v_fichero      UTL_FILE.file_type;
      cadena         VARCHAR2(1000);
      vsumacapital   NUMBER;
      vgarantia      NUMBER;
      vproducto      NUMBER;
      vsumpneta      NUMBER;
      vsumrecargo    NUMBER;
      vsumconsorcio  NUMBER;
      vsumimpuesto   NUMBER;
      vsumtotal      NUMBER;
      vcgarant       NUMBER;
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      vtexto         VARCHAR2(100);
      vpolcertif     VARCHAR2(40);
      verror         NUMBER;
      vdesc          VARCHAR2(40);
      vtitulo        VARCHAR2(40);
      vprima         NUMBER;
      vrecargo       NUMBER;
      vconsorcio     NUMBER;
      vclea          NUMBER;
      vsconclea      NUMBER;
      vimpuesto      NUMBER;
      vtotal         NUMBER;
      vicapital      NUMBER;
      vramoant       NUMBER := 0;
      vprodant       NUMBER := 0;
      vcomplet       BOOLEAN;
      vtotram        NUMBER;

      FUNCTION f_numero_riesgos(psseguro IN NUMBER)
         RETURN NUMBER IS
         vreg           NUMBER;
      BEGIN
         SELECT COUNT(nriesgo)
           INTO vreg
           FROM riesgos
          WHERE sseguro = psseguro;

         RETURN vreg;
      END f_numero_riesgos;

      FUNCTION f_nombre_tomador(psseguro IN NUMBER)
         RETURN CHAR IS
         vperson        VARCHAR2(150);
         vagente_poliza seguros.cagente%TYPE;
         vcempres       seguros.cempres%TYPE;
      BEGIN
         BEGIN
            --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = psseguro;

            SELECT SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' '
                   || SUBSTR(d.tapelli2, 0, 20)
              INTO vperson
              FROM per_personas p, per_detper d, tomadores s
             WHERE d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
               AND p.sperson = s.sperson
               AND s.sseguro = psseguro;
         /*SELECT tnombre || ' ' || tapelli
           INTO vperson
           FROM personas p, tomadores s
          WHERE p.sperson = s.sperson
            AND s.sseguro = psseguro;*/

         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               vperson := NULL;
         END;

         RETURN vperson;
      END f_nombre_tomador;

      FUNCTION f_importe_recibo(pnrecibo IN NUMBER)
         RETURN NUMBER IS
         vvalor         vdetrecibos.itotalr%TYPE;   --          vvalor         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      BEGIN
         SELECT itotalr
           INTO vvalor
           FROM vdetrecibos
          WHERE nrecibo = pnrecibo;

         RETURN vvalor;
      END f_importe_recibo;

      PROCEDURE p_total_garantia(
         pfechaini IN DATE,
         pfechafin IN DATE,
         pempres IN NUMBER,
         psproduc IN NUMBER,
         pcramo IN NUMBER,
         pcagente IN NUMBER) IS
      BEGIN
         FOR suma IN (SELECT   SUM(icapital) sumacapital, g.cgarant garantia,
                               s.sproduc producto,
                               SUM(f_impgarant(r.nrecibo, 'PRIMA TARIFA',
                                               g.cgarant)) sum_p_neta,
                               SUM(f_impgarant(r.nrecibo, 'REC FPAGO', g.cgarant))
                                                                                  sum_recargo,
                               SUM(f_impgarant(r.nrecibo, 'CONSORCIO',
                                               g.cgarant))
                               + SUM(f_impgarant(r.nrecibo, 'CLEA', g.cgarant)) sum_consorcio,
                               SUM(f_impgarant(r.nrecibo, 'IMPUESTO', g.cgarant))
                                                                                 sum_impuesto,
                               SUM(f_impgarant(r.nrecibo, 'PRIMA TOTAL', g.cgarant))
                                                                                    sum_total,
                               COUNT(1) contador
                          FROM seguros s, movseguro m, recibos r, garanseg g, garanpro p
                         WHERE s.sseguro = m.sseguro
                           AND r.sseguro = s.sseguro
                           AND s.sseguro = g.sseguro
                           AND m.nmovimi = g.nmovimi
                           AND g.nriesgo = 1
                           AND r.ctiprec = 0   --recibos de nueva produccion
                           AND(TRUNC(m.femisio) BETWEEN TO_DATE(pfechaini, 'DD/MM/RRRR')
                                                    AND TO_DATE(pfechafin, 'DD/MM/RRRR'))
                           AND m.cmovseg = 0
                           AND s.cempres = pempres
                           AND s.cagente = NVL(pcagente, s.cagente)
                           AND s.sproduc = psproduc
                           AND s.cramo = pcramo
                           AND g.cgarant = p.cgarant
                           AND p.cramo = s.cramo
                           AND p.cmodali = s.cmodali
                           AND p.ctipseg = s.ctipseg
                           AND p.ccolect = s.ccolect
                           AND p.ctipgar <> 8
                      GROUP BY g.cgarant, s.sproduc) LOOP
            verror := f_desgarantia(suma.garantia, pcidioma, vdesc);
            cadena :=(RPAD(f_axis_literales(110236, pcidioma), 26, ' ') || ';'
                      || LPAD(suma.contador, 8, ' ') || ';' || LPAD(';', 4, ' ')
                      || RPAD(';', 81, ' ') || RPAD(';', 11, ' ') || RPAD(';', 11, ' ')
                      || RPAD(';', 7, ' ') || RPAD(';', 10, ' ') || RPAD(';', 17, ' ') || ';'
                      || RPAD(NVL(vdesc, ' '), 40, ' ') || ';'
                      || LPAD(suma.sumacapital, 18, ' ') || ';'
                      || LPAD(suma.sum_p_neta, 18, ' ') || ';'
                      || LPAD(suma.sum_recargo, 18, ' ') || ';'
                      || LPAD(suma.sum_consorcio, 18, ' ') || ';'
                      || LPAD(suma.sum_impuesto, 18, ' ') || ';'
                      || LPAD(suma.sum_total, 18, ' ') || ';');
            UTL_FILE.put_line(v_fichero, cadena);
            cadena := NULL;
         END LOOP;
      END p_total_garantia;

      FUNCTION f_total_ramo(
         pfechaini IN DATE,
         pfechafin IN DATE,
         pempres IN NUMBER,
         psproduc IN NUMBER,
         pcramo IN NUMBER,
         pcagente IN NUMBER)
         RETURN NUMBER IS
         contador       NUMBER := 0;
      BEGIN
         SELECT COUNT(1)
           INTO contador
           FROM seguros s, movseguro m, recibos r
          WHERE s.sseguro = m.sseguro
            AND r.sseguro = s.sseguro
            AND r.ctiprec = 0   --recibos de nueva produccion
            AND(TRUNC(m.femisio) BETWEEN TO_DATE(pfechaini, 'DD/MM/RRRR')
                                     AND TO_DATE(pfechafin, 'DD/MM/RRRR'))
            AND m.cmovseg = 0
            AND s.cempres = pempres
            AND s.cagente = NVL(pcagente, s.cagente)
            AND s.cramo = pcramo
            AND EXISTS(SELECT 1
                         FROM garanseg g, garanpro p
                        WHERE g.sseguro = s.sseguro
                          AND m.nmovimi = g.nmovimi
                          AND g.nriesgo = 1
                          AND g.cgarant = p.cgarant
                          AND p.cramo = s.cramo
                          AND p.cmodali = s.cmodali
                          AND p.ctipseg = s.ctipseg
                          AND p.ccolect = s.ccolect
                          AND p.ctipgar <> 8);

         RETURN contador;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
      END f_total_ramo;
   BEGIN
      IF UTL_FILE.is_open(v_fichero) = TRUE THEN
         UTL_FILE.fclose(v_fichero);
      END IF;

      v_ruta := f_parinstalacion_t('INFORMES');
      v_nomfit := 'snctr003_' || TO_CHAR(f_sysdate, 'YYYYMMDD_HH24MISS') || '.csv';

      IF UTL_FILE.is_open(v_fichero) = FALSE THEN
         v_fichero := UTL_FILE.fopen(v_ruta, v_nomfit, 'W');
      END IF;

      FOR rec IN (SELECT   s.sproduc, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                           m.nmovimi, s.cagente, s.nsolici, s.npoliza, s.ncertif, r.nrecibo,
                           s.cactivi, m.fmovimi, s.fefecto, s.femisio
                      FROM seguros s, movseguro m, recibos r
                     WHERE s.sseguro = m.sseguro
                       AND r.sseguro = s.sseguro
                       AND s.cagente = NVL(pcagente, s.cagente)
                       AND r.ctiprec = 0   --recibos de nueva produccion
                       AND(TRUNC(m.femisio) BETWEEN TO_DATE(pfechaini, 'DD/MM/RRRR')
                                                AND TO_DATE(pfechafin, 'DD/MM/RRRR'))
                       AND m.cmovseg = 0
                       AND s.cempres = pempres
                       AND((s.sproduc = psproduc)
                           OR(psproduc IS NULL
                              AND f_prodactivo(s.sproduc) = 1))
                       AND s.cramo = NVL(pcramo, s.cramo)
                  ORDER BY s.cramo, s.sproduc, s.femisio, s.npoliza, s.ncertif) LOOP
         vpolcertif := f_formatopol(rec.npoliza, rec.ncertif, 1);

         IF rec.sproduc <> vprodant THEN
            IF vprodant <> 0 THEN
               p_total_garantia(pfechaini => pfechaini, pfechafin => pfechafin,
                                pempres => pempres, psproduc => vprodant, pcramo => vramoant,
                                pcagente => pcagente);

               IF rec.cramo <> vramoant THEN
                  vtotram := f_total_ramo(pfechaini => pfechaini, pfechafin => pfechafin,
                                          pempres => pempres, psproduc => vprodant,
                                          pcramo => vramoant, pcagente => pcagente);
                  cadena := UPPER(f_axis_literales(111475, pcidioma)) || ';' || vtotram
                            || ';;;;;;;;;;;;;;;;';
                  UTL_FILE.put_line(v_fichero, cadena);
                  cadena := NULL;
               END IF;
            END IF;

            verror := f_desramo(rec.cramo, pcidioma, vdesc);

            IF verror <> 0 THEN
               vdesc := NULL;
            END IF;

            cadena := f_axis_literales(100765, pcidioma) || ';' || rec.cramo || ';' || vdesc
                      || ';;;;;;;;;;;;;;;';
            UTL_FILE.put_line(v_fichero, cadena);
            cadena := NULL;
            verror := f_desproducto(rec.cramo, rec.cmodali, 1, pcidioma, vtitulo, rec.ctipseg,
                                    rec.ccolect);
            cadena := f_axis_literales(100681, pcidioma) || ';' || rec.cramo || ';'
                      || rec.cmodali || ';' || rec.ctipseg || ';' || rec.ccolect || ';'
                      || vtitulo || ';;;;;;;;;;;;';
            UTL_FILE.put_line(v_fichero, cadena);
            cadena := NULL;
            cadena := f_axis_literales(100877, pcidioma) || ';'
                      || f_axis_literales(111324, pcidioma) || ';'
                      || f_axis_literales(109528, pcidioma) || ';'
                      || f_axis_literales(105808, pcidioma) || ';'
                      || f_axis_literales(101027, pcidioma) || ';'
                      || f_axis_literales(100883, pcidioma) || ';'
                      || f_axis_literales(105887, pcidioma) || ';'
                      || f_axis_literales(102347, pcidioma) || ';'
                      || f_axis_literales(100895, pcidioma) || ';'
                      || f_axis_literales(800358, pcidioma) || ';'
                      || f_axis_literales(102083, pcidioma) || ';'
                      || f_axis_literales(151452, pcidioma) || ';'
                      || f_axis_literales(100915, pcidioma) || ';'
                      || f_axis_literales(101280, pcidioma) || ';'
                      || f_axis_literales(100916, pcidioma) || ';'
                      || f_axis_literales(101278, pcidioma) || ';'
                      || f_axis_literales(101093, pcidioma) || ';';
            UTL_FILE.put_line(v_fichero, cadena);
            cadena := NULL;
         END IF;

         vcomplet := TRUE;

         FOR gar IN (SELECT DISTINCT g.cgarant, g.sseguro, g.nmovimi, g.icapital
                                FROM garanseg g, garanpro p
                               WHERE g.sseguro = rec.sseguro
                                 AND g.nmovimi = rec.nmovimi
                                 AND g.cgarant = p.cgarant
                                 AND p.cramo = rec.cramo
                                 AND p.cmodali = rec.cmodali
                                 AND p.ctipseg = rec.ctipseg
                                 AND p.ccolect = rec.ccolect
                                 AND p.ctipgar <> 8)
                                                    /*AND g.finiefe >= pfechaini
                                                            AND (   g.ffinefe <= pfechafin
                                                                 OR g.ffinefe IS NULL
                                                                )*/
         LOOP
            verror := f_desgarantia(gar.cgarant, pcidioma, vdesc);

            IF verror <> 0 THEN
               vdesc := 'ERROR:' || gar.cgarant;
            END IF;

            vprima := f_impgarant(rec.nrecibo, 'PRIMA TARIFA', gar.cgarant);
            vrecargo := f_impgarant(rec.nrecibo, 'REC FPAGO', gar.cgarant);
            vconsorcio := f_impgarant(rec.nrecibo, 'CONSORCIO', gar.cgarant);
            vclea := f_impgarant(rec.nrecibo, 'CLEA', gar.cgarant);
            vsconclea := vconsorcio + vclea;
            vimpuesto := f_impgarant(rec.nrecibo, 'IMPUESTO', gar.cgarant);
            vtotal := f_impgarant(rec.nrecibo, 'PRIMA TOTAL', gar.cgarant);

            IF vcomplet THEN
               -- Bug 18225 - APD - 12/04/2011 - la precion del campo cagente puede ser mayor de 6
               -- se añade el GREATEST en el LPAD del campo rec.cagente, por si este campo es mayor a 6
               cadena := TO_CHAR(rec.femisio, 'DD/MM/YYYY') || ';'
                         || RPAD(vpolcertif, 15, ' ') || ';'
                         || LPAD(NVL(TO_CHAR(rec.nsolici), ' '), 8, ' ') || ';'
                         || LPAD(f_numero_riesgos(rec.sseguro), 4, ' ') || ';'
                         || RPAD(f_nombre_tomador(rec.sseguro), 80, ' ') || ';'
                         || TO_CHAR(rec.fefecto, 'DD/MM/YYYY') || ';'
                         || TO_CHAR(rec.fmovimi, 'DD/MM/YYYY') || ';'
                         || LPAD(rec.cagente, GREATEST(LENGTH(rec.cagente), 6), ' ') || ';'
                         || LPAD(rec.nrecibo, 9, ' ') || ';'
                         || LPAD(f_importe_recibo(rec.nrecibo), 16, ' ') || ';'
                         || RPAD(NVL(vdesc, ' '), 40, ' ') || ';'
                         || LPAD(gar.icapital, 18, ' ') || ';' || LPAD(vprima, 18, ' ') || ';'
                         || LPAD(vrecargo, 18, ' ') || ';' || LPAD(vsconclea, 18, ' ') || ';'
                         || LPAD(vimpuesto, 18, ' ') || ';' || LPAD(vtotal, 18, ' ') || ';';
               -- Fin Bug 18225 - APD - 12/04/2011
               UTL_FILE.put_line(v_fichero, cadena);
               cadena := NULL;
               vcomplet := FALSE;
            ELSE
               cadena := LPAD(';', 11, ' ') || LPAD(';', 16, ' ') || LPAD(';', 9, ' ')
                         || LPAD(';', 5, ' ') || LPAD(';', 81, ' ') || LPAD(';', 11, ' ')
                         || LPAD(';', 11, ' ') || LPAD(';', 7, ' ') || LPAD(';', 10, ' ')
                         || LPAD(';', 17, ' ') || RPAD(NVL(vdesc, ' '), 40, ' ') || ';'
                         || LPAD(gar.icapital, 18, ' ') || ';' || LPAD(vprima, 18, ' ') || ';'
                         || LPAD(vrecargo, 18, ' ') || ';' || LPAD(vsconclea, 18, ' ') || ';'
                         || LPAD(vimpuesto, 18, ' ') || ';' || LPAD(vtotal, 18, ' ') || ';';
               UTL_FILE.put_line(v_fichero, cadena);
               cadena := NULL;
            END IF;
         END LOOP;

         vramoant := rec.cramo;
         vprodant := rec.sproduc;
      END LOOP;

      p_total_garantia(pfechaini => pfechaini, pfechafin => pfechafin, pempres => pempres,
                       psproduc => vprodant, pcramo => vramoant, pcagente => pcagente);
      vtotram := f_total_ramo(pfechaini => pfechaini, pfechafin => pfechafin,
                              pempres => pempres, psproduc => vprodant, pcramo => vramoant,
                              pcagente => pcagente);
      cadena := UPPER(f_axis_literales(111475, pcidioma)) || ';' || vtotram
                || ';;;;;;;;;;;;;;;;';
      UTL_FILE.put_line(v_fichero, cadena);
      cadena := NULL;

      IF UTL_FILE.is_open(v_fichero) = TRUE THEN
         UTL_FILE.fclose(v_fichero);
      END IF;

      RETURN v_nomfit;
   EXCEPTION
      WHEN OTHERS THEN
         IF UTL_FILE.is_open(v_fichero) = TRUE THEN
            UTL_FILE.fclose(v_fichero);
         END IF;

         --DBMS_OUTPUT.put_line(SQLERRM);
         p_tab_error(f_sysdate, getuser, 'pac_excel.f_snctr003', NULL, NULL, SQLERRM);
         RETURN -1;
   END f_snctr003;

   /*
   Listado de bajas de certificados (LEH)
   */
   FUNCTION f_snctr004(
      pfechaini IN DATE,
      pfechafin IN DATE,
      pempres IN NUMBER,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pvincu IN NUMBER,
      pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vprodant       NUMBER := 0;
      vramoant       NUMBER := 0;
      v_ruta         VARCHAR2(100);
      v_nomfit       VARCHAR2(100);
      v_fichero      UTL_FILE.file_type;
      cadena         VARCHAR2(1000);
      verror         NUMBER;
      vdesc          VARCHAR2(100);
      vtitulo        VARCHAR2(100);
      -- RSC 17/04/2008
      vtotalr        vdetrecibos.itotalr%TYPE;   --       vtotalr        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vfmovini       movrecibo.fmovini%TYPE;   --       vfmovini       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vnnmovimi      movseguro.nmovimi%TYPE;   --       vnnmovimi      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

      FUNCTION f_numero_riesgos(psseguro IN NUMBER)
         RETURN NUMBER IS
         vreg           NUMBER;
      BEGIN
         SELECT COUNT(nriesgo)
           INTO vreg
           FROM riesgos
          WHERE sseguro = psseguro;

         RETURN vreg;
      END f_numero_riesgos;

      FUNCTION f_nombre_tomador(psseguro IN NUMBER)
         RETURN CHAR IS
         vperson        VARCHAR2(150);
         vagente_poliza seguros.cagente%TYPE;
         vcempres       seguros.cempres%TYPE;
      BEGIN
         BEGIN
            --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = psseguro;

            SELECT SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' '
                   || SUBSTR(d.tapelli2, 0, 20)
              INTO vperson
              FROM per_personas p, per_detper d, tomadores s
             WHERE d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
               AND p.sperson = s.sperson
               AND s.sseguro = psseguro;
         /*SELECT tnombre || ' ' || tapelli
           INTO vperson
           FROM personas p, tomadores s
          WHERE p.sperson = s.sperson
            AND s.sseguro = psseguro;*/

         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               vperson := NULL;
         END;

         RETURN vperson;
      END f_nombre_tomador;

      FUNCTION f_des_motivo(pcmotmov IN NUMBER, pcidioma IN NUMBER)
         RETURN CHAR IS
         vdes           motmovseg.tmotmov%TYPE;   --          vdes           VARCHAR2(100); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      BEGIN
         SELECT tmotmov
           INTO vdes
           FROM motmovseg
          WHERE cmotmov = pcmotmov
            AND cidioma = pcidioma;

         RETURN vdes;
      END f_des_motivo;

      FUNCTION f_total_producto(
         pfechaini IN DATE,
         pfechafin IN DATE,
         pempres IN NUMBER,
         psproduc IN NUMBER,
         pcramo IN NUMBER,
         pvincu IN NUMBER)
         RETURN NUMBER IS
         contador       NUMBER;
      BEGIN
         SELECT COUNT(1)
           INTO contador
           FROM seguros s, movseguro m
          WHERE s.sseguro = m.sseguro
            AND(TRUNC(m.femisio) BETWEEN TO_DATE(pfechaini, 'DD/MM/RRRR')
                                     AND TO_DATE(pfechafin, 'DD/MM/RRRR'))
            AND m.cmovseg = 3   --Bajas
            AND s.cempres = pempres
            AND((s.sproduc = psproduc)
                OR(psproduc IS NULL
                   AND f_prodactivo(s.sproduc) = 1))
            AND s.cramo = NVL(pcramo, s.cramo)
            AND DECODE(pvincu, NULL, 99, f_es_vinculada(s.sseguro)) = NVL(pvincu, 99);

         RETURN contador;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
      END f_total_producto;
   BEGIN
      IF UTL_FILE.is_open(v_fichero) = TRUE THEN
         UTL_FILE.fclose(v_fichero);
      END IF;

      v_ruta := f_parinstalacion_t('INFORMES');
      v_nomfit := 'snctr004_' || TO_CHAR(f_sysdate, 'YYYYMMDD_HH24MISS') || '.csv';

      IF UTL_FILE.is_open(v_fichero) = FALSE THEN
         v_fichero := UTL_FILE.fopen(v_ruta, v_nomfit, 'W');
      END IF;

      FOR rec IN (SELECT   s.sproduc, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                           f_formatopol(s.npoliza, s.ncertif, 1) polcertif, m.nmovimi,
                           s.cagente, s.nsolici, m.fmovimi, s.fefecto, s.femisio,
                           DECODE(f_es_vinculada(s.sseguro), 0, 'No', 1, 'Si') vinculada,
                           m.cmotmov
                      FROM seguros s, movseguro m
                     WHERE s.sseguro = m.sseguro
                       AND(TRUNC(m.femisio) BETWEEN TO_DATE(pfechaini, 'DD/MM/RRRR')
                                                AND TO_DATE(pfechafin, 'DD/MM/RRRR'))
                       AND m.cmovseg = 3   --Bajas
                       AND s.cempres = pempres
                       AND((s.sproduc = psproduc)
                           OR(psproduc IS NULL
                              AND f_prodactivo(s.sproduc) = 1))
                       AND s.cramo = NVL(pcramo, s.cramo)
                       AND DECODE(pvincu, NULL, 99, f_es_vinculada(s.sseguro)) =
                                                                                NVL(pvincu, 99)
                  ORDER BY cramo, sproduc, /*femisio,*/ npoliza, ncertif) LOOP
         IF rec.sproduc <> vprodant THEN
            IF vprodant <> 0 THEN
               cadena := f_axis_literales(111475, pcidioma) || ';'
                         || f_total_producto(pfechaini => pfechaini, pfechafin => pfechafin,
                                             pempres => pempres, psproduc => vprodant,
                                             pcramo => vramoant, pvincu => pvincu)
                         || ';';
               UTL_FILE.put_line(v_fichero, cadena);
               cadena := NULL;

               IF vramoant <> rec.cramo THEN
                  cadena := UPPER(f_axis_literales(111475, pcidioma)) || ';'
                            || f_total_producto(pfechaini => pfechaini,
                                                pfechafin => pfechafin, pempres => pempres,
                                                psproduc => NULL, pcramo => vramoant,
                                                pvincu => pvincu)
                            || ';';
                  UTL_FILE.put_line(v_fichero, cadena);
                  cadena := NULL;
               END IF;
            END IF;

            verror := f_desramo(rec.cramo, pcidioma, vdesc);

            IF verror <> 0 THEN
               vdesc := NULL;
            END IF;

            cadena := f_axis_literales(100765, pcidioma) || ';' || rec.cramo || ';' || vdesc
                      || ';;;;;;;;;;;;;;;';
            UTL_FILE.put_line(v_fichero, cadena);
            cadena := NULL;
            verror := f_desproducto(rec.cramo, rec.cmodali, 1, pcidioma, vtitulo, rec.ctipseg,
                                    rec.ccolect);
            cadena := f_axis_literales(100681, pcidioma) || ';' || rec.cramo || ';'
                      || rec.cmodali || ';' || rec.ctipseg || ';' || rec.ccolect || ';'
                      || vtitulo || ';;;;;;;;;;;;';
            UTL_FILE.put_line(v_fichero, cadena);
            cadena := NULL;
            cadena := f_axis_literales(100877, pcidioma) || ';'
                      || f_axis_literales(111324, pcidioma) || ';'
                      || f_axis_literales(109528, pcidioma) || ';'
                      || f_axis_literales(105808, pcidioma) || ';'
                      || f_axis_literales(101027, pcidioma) || ';'
                      || f_axis_literales(100883, pcidioma) || ';'
                      || f_axis_literales(102347, pcidioma) || ';'
                      || f_axis_literales(152156, pcidioma) || ';'
                      || f_axis_literales(103218, pcidioma) || ';'
                      || f_axis_literales(180835, pcidioma) || ';'
                      || f_axis_literales(180836, pcidioma) || ';';
            UTL_FILE.put_line(v_fichero, cadena);
            cadena := NULL;
         END IF;

         -- Bug 18225 - APD - 12/04/2011 - la precion del campo cagente puede ser mayor de 6
         -- se añade el GREATEST en el LPAD del campo rec.cagente, por si este campo es mayor a 6
         cadena := TO_CHAR(rec.femisio, 'DD/MM/YYYY') || ';' || RPAD(rec.polcertif, 15, ' ')
                   || ';' || LPAD(NVL(TO_CHAR(rec.nsolici), ' '), 8, ' ') || ';'
                   || LPAD(f_numero_riesgos(rec.sseguro), 4, ' ') || ';'
                   || RPAD(f_nombre_tomador(rec.sseguro), 80, ' ') || ';'
                   || TO_CHAR(rec.fmovimi, 'DD/MM/YYYY') || ';'
                   || LPAD(rec.cagente, GREATEST(LENGTH(rec.cagente), 6), ' ') || ';'
                   || rec.vinculada || ';' || f_des_motivo(rec.cmotmov, pcidioma) || ';';

         -- Fin Bug 18225 - APD - 12/04/2011
         IF NVL(f_parmotmov(rec.cmotmov, 'ANUL_EFECTO'), 0) = 1 THEN
            BEGIN
               SELECT nmovimi
                 INTO vnnmovimi
                 FROM movseguro
                WHERE cmotmov = rec.cmotmov
                  AND sseguro = rec.sseguro;

               SELECT m.fmovini, v.itotalr totalr
                 INTO vfmovini, vtotalr
                 FROM vdetrecibos v, recibos r, movrecibo m
                WHERE r.sseguro = rec.sseguro
                  AND v.nrecibo = r.nrecibo
                  AND m.nrecibo = r.nrecibo
                  AND r.ctiprec = 9
                  AND m.cestrec = 1
                  AND m.cestant = 0
                  AND r.nmovimi = vnnmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  vfmovini := NULL;
                  vtotalr := NULL;
            END;

            cadena := cadena || vtotalr || ';' || vfmovini || ';';
         END IF;

         UTL_FILE.put_line(v_fichero, cadena);
         cadena := NULL;
         vprodant := rec.sproduc;
         vramoant := rec.cramo;
      END LOOP;

      cadena := f_axis_literales(111475, pcidioma) || ';'
                || f_total_producto(pfechaini => pfechaini, pfechafin => pfechafin,
                                    pempres => pempres, psproduc => vprodant,
                                    pcramo => vramoant, pvincu => pvincu)
                || ';';
      UTL_FILE.put_line(v_fichero, cadena);
      cadena := NULL;
      cadena := UPPER(f_axis_literales(111475, pcidioma)) || ';'
                || f_total_producto(pfechaini => pfechaini, pfechafin => pfechafin,
                                    pempres => pempres, psproduc => NULL, pcramo => vramoant,
                                    pvincu => pvincu)
                || ';';
      UTL_FILE.put_line(v_fichero, cadena);
      cadena := NULL;

      IF UTL_FILE.is_open(v_fichero) = TRUE THEN
         UTL_FILE.fclose(v_fichero);
      END IF;

      RETURN v_nomfit;
   EXCEPTION
      WHEN OTHERS THEN
         IF UTL_FILE.is_open(v_fichero) = TRUE THEN
            UTL_FILE.fclose(v_fichero);
         END IF;

         RETURN -1;
   END f_snctr004;

   /***********************************************************************
    -- RSC 11/03/2008
    -- Listado de cierre de provisiones de siniestros con pagos pendientes de
       pago.
   ************************************************************************/
   FUNCTION f_snctr652(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pmesanyo IN DATE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pccausin IN siniestros.ccausin%TYPE,
      pcagente IN seguros.cagente%TYPE,
      pusuidioma IN NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp IS
      v_ruta         VARCHAR2(100);
      v_nomfit       VARCHAR2(100);
      v_fichero      UTL_FILE.file_type;
      v_nombre_excel VARCHAR2(100);
      cadena         VARCHAR2(1000);
      cabecera       VARCHAR2(1000);
      v_descramodgs  VARCHAR2(200);
      v_desproducto  VARCHAR2(200);
      v_poliza_antigua cnvpolizas.polissa_ini%TYPE;   --       v_poliza_antigua VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nif          VARCHAR2(15);
      v_sperson      tomadores.sperson%TYPE;   --       v_sperson      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_tomador      VARCHAR2(200);
      v_idioma_tomador NUMBER;
      v_riesgos      NUMBER;
      v_prima_sfp    seguros.iprianu%TYPE;   --20.03NUMBER;
      v_empresa      VARCHAR2(200);
      v_desagente    VARCHAR2(200);
      v_num_lin      NUMBER;
      v_num_excel    NUMBER := 1;
      num_err        NUMBER;
      v_literal_tots CONSTANT VARCHAR2(20) := f_axis_literales(100934, pusuidioma);   -- Tots
      v_literal_totes CONSTANT VARCHAR2(20) := f_axis_literales(103233, pusuidioma);   -- Totes
      vtmotsin       desmotsini.tmotsin%TYPE;   --       vtmotsin       VARCHAR2(100); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      error          EXCEPTION;

      FUNCTION f_cabecera(p_num_lin IN OUT NUMBER)
         RETURN NUMBER IS
      BEGIN
         p_num_lin := 0;

         -- Se busca la descripción de la empresa
         BEGIN
            num_err := f_desempresa(pcempres, NULL, v_empresa);
         EXCEPTION
            WHEN OTHERS THEN
               v_empresa := NULL;
         END;

         cabecera := f_axis_literales(100857, pusuidioma)   -- Empresa
                                                         || ';'
                     || v_empresa   -- Descripción de la Empresa
                                 || ';' || ' '   -- Columna en blanco
                                              || ';' || ' '   -- Columna en blanco
                                                           || ';'
                     || f_axis_literales(100550, pusuidioma)   -- Fecha
                                                            || ';' || pmesanyo;   -- Descripcion de la Fecha
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := f_axis_literales(100765, pusuidioma)   -- Ramo:
                                                         || ';'
                     || nvl2x(pcramo, fpv_desramo(pusuidioma, pcramo), v_literal_tots)   -- Descripción del Ramo
                     || ';';
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := f_axis_literales(100681, pusuidioma)   -- Producto
                                                         || ';'
                     || nvl2x(psproduc, fpv_desproducto(pusuidioma, psproduc), v_literal_tots)   -- Descripción del Producto
                                                                                              ;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := f_axis_literales(102106, pusuidioma)   -- Causa de siniestro
                                                         || ';'
                     || nvl2x(psproduc, fpv_descausasini(pusuidioma, pccausin), v_literal_tots)   -- Descripción del Producto
                                                                                               ;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := f_axis_literales(102591, pusuidioma)   -- Oficina:
                                                         || ';'
                     || nvl2x(pcagente, fpv_desagente(pusuidioma, pcagente), v_literal_totes)   -- Descripción de la Oficina
                                                                                             ;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         -- Se insertan dos lineas en blanco
         cabecera := NULL;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := NULL;
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         cabecera := f_axis_literales(100784, pusuidioma)   -- Ramo
                                                         || ';'
                     || f_axis_literales(100943, pusuidioma)   -- Modalidad
                                                            || ';'
                     || f_axis_literales(102098, pusuidioma)   -- Tipo Seguro
                                                            || ';'
                     || f_axis_literales(180571, pusuidioma)   -- Colectividad
                                                            || ';'
                     || f_axis_literales(100829, pusuidioma)   -- Producto
                                                            || ';'
                     || f_axis_literales(102106, pusuidioma)   -- Causa Siniestro
                                                            || ';'
                     || f_axis_literales(101273, pusuidioma)   -- Póliza
                                                            || ';'
                     || f_axis_literales(104595, pusuidioma)   -- Certificado
                                                            || ';'
                     || f_axis_literales(102347, pusuidioma)   -- Oficina
                                                            || ';'
                     || f_axis_literales(180572, pusuidioma)   -- NIF tomador
                                                            || ';'
                     || f_axis_literales(101027, pusuidioma)   -- Tomador
                                                            || ';'
                     || f_axis_literales(109651, pusuidioma)   -- Motivo siniestro
                                                            || ';'
                     || f_axis_literales(152188, pusuidioma)   -- I. Bruto
                                                            || ';'
                     || f_axis_literales(152189, pusuidioma)   -- I.pagado
                                                            || ';'
                     || f_axis_literales(152190, pusuidioma)   -- I. pendiente
                                                            || ';';
         UTL_FILE.put_line(v_fichero, cabecera);
         p_num_lin := p_num_lin + 1;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, getuser, 'pac_excel.f_snctr652.f_cabecera', NULL,
                        'p_num_lin =' || p_num_lin, SQLERRM);
            RETURN -1;
      END f_cabecera;
   BEGIN
      IF psproces IS NULL
         OR pmesanyo IS NULL
         --OR pagente IS NULL
         OR pusuidioma IS NULL THEN
         RAISE error;
      --         RETURN -1;
      END IF;

      v_ruta := f_parinstalacion_t('INFORMES');
      v_nombre_excel := 'snctr652';
      v_nomfit := v_nombre_excel || '_' || TO_CHAR(f_sysdate, 'YYYYMMDD_HH24MISS') || '.csv';

      IF UTL_FILE.is_open(v_fichero) = FALSE THEN
         v_fichero := UTL_FILE.fopen(v_ruta, v_nomfit, 'W');
      END IF;

      cont := cont + 1;
      v_nombre_fichero(cont).nombre := v_nomfit;
      num_err := f_cabecera(v_num_lin);

      IF num_err <> 0 THEN
         RAISE error;
      --         RETURN -1;
      END IF;

      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- se añade la UNION con las tablas nuevas de siniestros
      FOR reg IN (SELECT   p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                           s.npoliza, s.ncertif, s.nduraci, s.fefecto, s.sproduc, s.cagente,
                           p.nsinies, TO_CHAR(si.fentrad, 'dd/mm/yyyy') fentrad,
                           TO_CHAR(si.fsinies, 'dd/mm/yyyy') fsinies,
                           pac_sin.ff_sperson_sinies(si.nsinies) sperson, si.cmotsin cmotsin,
                           si.ccausin ccausin, si.tsinies tsinies, p.ivalbruto, p.ivalpago,
                           p.ipplpsd
                      FROM seguros s,
                           (SELECT *
                              FROM ptpplp
                             WHERE sproces = psproces
                            UNION
                            SELECT *
                              FROM ptpplp_previo
                             WHERE sproces = psproces) p,
                           siniestros si
                     WHERE p.sproces = psproces
                       AND p.sseguro = s.sseguro
                       AND(s.sproduc = psproduc
                           OR psproduc IS NULL)
                       AND(s.cramo = pcramo
                           OR pcramo IS NULL)
                       AND(s.cagente = pcagente
                           OR pcagente IS NULL)
                       AND(si.ccausin = pccausin
                           OR pccausin IS NULL)
                       AND s.cagrpro <> 11
                       AND p.nsinies = si.nsinies
                       AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
                  UNION
                  SELECT   p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                           s.npoliza, s.ncertif, s.nduraci, s.fefecto, s.sproduc, s.cagente,
                           p.nsinies, TO_CHAR(si.falta, 'dd/mm/yyyy') fentrad,
                           TO_CHAR(si.fsinies, 'dd/mm/yyyy') fsinies,
                           pac_sin.ff_sperson_sinies(si.nsinies) sperson, si.cmotsin cmotsin,
                           si.ccausin ccausin, si.tsinies tsinies, p.ivalbruto, p.ivalpago,
                           p.ipplpsd
                      FROM seguros s,
                           (SELECT *
                              FROM ptpplp
                             WHERE sproces = psproces
                            UNION
                            SELECT *
                              FROM ptpplp_previo
                             WHERE sproces = psproces) p,
                           sin_siniestro si
                     WHERE p.sproces = psproces
                       AND p.sseguro = s.sseguro
                       AND(s.sproduc = psproduc
                           OR psproduc IS NULL)
                       AND(s.cramo = pcramo
                           OR pcramo IS NULL)
                       AND(s.cagente = pcagente
                           OR pcagente IS NULL)
                       AND(si.ccausin = pccausin
                           OR pccausin IS NULL)
                       AND s.cagrpro <> 11
                       AND p.nsinies = si.nsinies
                       AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1
                  --ORDER BY s.cramo, s.cmodali, s.ctipseg, s.ccolect, si.ccausin, s.npoliza, s.ncertif
                  ORDER BY 2, 3, 4, 5, 18, 7, 8) LOOP
         -- Si el número de lineas del fichero excel supera las 65000 lineas, se debe cerrar el fichero excel y abrir otro
         IF v_num_lin >= 65000 THEN
            num_err := f_reabrir_fichero(v_fichero, v_nombre_excel, v_num_excel);

            IF num_err <> 0 THEN
               RAISE error;
            --             RETURN -1;
            END IF;

            cont := cont + 1;
            v_nombre_fichero(cont).nombre := v_nomfit;
            num_err := f_cabecera(v_num_lin);

            IF num_err <> 0 THEN
               RAISE error;
            --             RETURN -1;
            END IF;
         ELSE
            -- Se busca la descripción del ramo
            BEGIN
               num_err := f_desramodgs(reg.cramdgs, pusuidioma, v_descramodgs);

               IF num_err <> 0 THEN
                  v_descramodgs := NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_descramodgs := NULL;
            END;

            -- Se busca la descripción del producto
            BEGIN
               num_err := f_desproducto(reg.cramo, reg.cmodali, 1, pusuidioma, v_desproducto,
                                        reg.ctipseg, reg.ccolect);

               IF num_err <> 0 THEN
                  v_desproducto := NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_desproducto := NULL;
            END;

            -- Se busca el Nif, Nombre y Apellidos del Tomador
            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM tomadores
                WHERE sseguro = reg.sseguro;

               v_nif := ff_buscanif(v_sperson);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nif := NULL;
            END;

            BEGIN
               v_idioma_tomador := pusuidioma;
               num_err := f_tomador(reg.sseguro, 1, v_tomador, v_idioma_tomador);
            EXCEPTION
               WHEN OTHERS THEN
                  v_tomador := NULL;
            END;

            BEGIN
               SELECT tmotsin
                 INTO vtmotsin
                 FROM desmotsini
                WHERE cramo = reg.cramo
                  AND ccausin = reg.ccausin
                  AND cmotsin = reg.cmotsin
                  AND cidioma = pusuidioma;
            EXCEPTION
               WHEN OTHERS THEN
                  vtmotsin := NULL;
            END;

            cadena := reg.cramo || ';' || reg.cmodali || ';' || reg.ctipseg || ';'
                      || reg.ccolect || ';' || v_desproducto || ';'
                      || fpv_descausasini(pusuidioma, reg.ccausin) || ';' || reg.npoliza || ';'
                      || reg.ncertif || ';' || reg.cagente || ';' || v_nif || ';' || v_tomador
                      || ';' || vtmotsin || ';' || reg.ivalbruto || ';' || reg.ivalpago || ';'
                      || reg.ipplpsd;
            UTL_FILE.put_line(v_fichero, cadena);
            v_num_lin := v_num_lin + 1;
            cadena := NULL;
         END IF;
      END LOOP;

      IF UTL_FILE.is_open(v_fichero) = TRUE THEN
         UTL_FILE.fclose(v_fichero);
      END IF;

      --      RETURN v_nomfit;
      RETURN v_nombre_fichero;
   EXCEPTION
      WHEN error THEN
         perror := -1;
         v_nombre_fichero(cont).nombre := NULL;
         RETURN v_nombre_fichero;
   END f_snctr652;

   /*************************************************************************
     Operaciones del dia sobre contratos financieros de inversión.
     param in pcIdioma     : codigo de idioma
     param in pfFecha      : codigo de fecha
     param in pcEmpresa    : codigo de empresa
     param in pcRamo       : codigo de ramo
     param in psProduc     : codigo de producto
     param in pcAgente     : codigo de agente
     param out mensajes  : mesajes de error
     return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 17/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_sictr024finv(
      pcidioma IN seguros.cidioma%TYPE,
      pffecha IN DATE,
      pcempresa IN seguros.cempres%TYPE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcagente IN seguros.cagente%TYPE,
      psprocesxml OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp IS
      v_ruta CONSTANT VARCHAR2(100) := f_parinstalacion_t('INFORMES');
      v_nomfit CONSTANT VARCHAR2(100)
                            := 'SG63LS02_' || TO_CHAR(f_sysdate, 'YYYYMMDD_HH24MISS')
                               || '.csv';
      v_fichero      UTL_FILE.file_type;
      v_cadena       VARCHAR2(1000);
      v_literal_tots CONSTANT VARCHAR2(20) := f_axis_literales(100934, pcidioma);   -- Tots
      v_literal_totes CONSTANT VARCHAR2(20) := f_axis_literales(103233, pcidioma);   -- Totes
      -- Dia  final de mes
      v_final_mes    NUMBER := TO_CHAR(LAST_DAY(pffecha), 'YYYYMMDD');
      ex_error       EXCEPTION;
      vimovim_g      NUMBER;
      vcontratoa     NUMBER;
      vcontratob     NUMBER;
      v_provision    NUMBER;

      --Hash de conceptos
      TYPE assoc_array_conceptos IS TABLE OF NUMBER
         INDEX BY VARCHAR2(100);

      vhashconceptos assoc_array_conceptos;
      concepto       VARCHAR2(100);

      -- Tabla Hash de fondos
      TYPE assoc_array_fondos IS TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

      vfondoentrada  assoc_array_fondos;
      vfondosalidas  assoc_array_fondos;
      fondo          NUMBER;
      vnpoliza       seguros.npoliza%TYPE;   --       vnpoliza       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vncertif       seguros.ncertif%TYPE;   --       vncertif       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcontrato      VARCHAR2(20);
      vprimer        NUMBER := 1;
      vunidades      NUMBER;
      precio_uni     NUMBER;
      -- RSC 17/01/2008
      num_err        NUMBER;
      tcesta_unidades NUMBER := 0;
      tcesta_importe NUMBER := 0;
      total_cestas   NUMBER := 0;
      v_det_modinv   pac_operativa_finv.tt_det_modinv;
      vcurimovimi    NUMBER;
      vgredanual     NUMBER;
      ventra         NUMBER := 0;
      vtfoncmp       VARCHAR2(100);
      -- Bug 11465 - 15/10/2009 - RSC - CRE - Modificar el formulario de entradas/salidas (fondos)
      vcontansin     NUMBER;
      vivalora       sin_tramita_reserva.ireserva%TYPE;   --       vivalora       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vfvalora       sin_tramita_reserva.fmovres%TYPE;   --       vfvalora       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_vliq_resc    NUMBER;
      v_vliq_date    DATE;   --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nmovimi      NUMBER;
      v_tfonabv      fondos.tfonabv%TYPE;
      -- Bug XXX - RSC - 25/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
      v_icaprisc     sin_tramita_reserva.icaprie%TYPE;   --       v_icaprisc     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Bug 17373 - 04/02/2011 - AMC
      vsproces       resumfinv.sproces%TYPE;   --       vsproces       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vasset         resumfinv.asset%TYPE;   --       vasset         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Fi Bug 17373 - 04/02/2011 - AMC

      -- Fin Bug XXX

      -- Bug 20309 - RSC - 29/11/2011 - LCOL_T004-Parametrización Fondos
      v_sproduc      seguros.sproduc%TYPE;
      v_ipenali      sin_tramita_reserva.ipenali%TYPE;
      v_ppenali      NUMBER;
      -- Fin Bug 20309

      -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
      v_rendiment    NUMBER;
      v_unidades_rend NUMBER;
      v_movrech      NUMBER;

      -- Fin Bug 20853

      -- Fin Bug 11465
      CURSOR cur_cestas IS
         SELECT   f.ccodfon, f.tfonabv
             FROM fondos f
            WHERE f.cempres = NVL(pcempresa, f.cempres)
              --and f.ccodfon = NVL(pccodfon,f.ccodfon)
              AND f.ffin IS NULL
         ORDER BY f.ccodfon;

      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- se añade la UNION con las tablas nuevas de siniestros
      -- Bug 15707 - APD - 25/02/2011 - Los siniestros que generan pagos de renta se tratan en el CURSOR cctaseguro.
      -- Para estar seguros de que no entran en el CURSOR cur_siniestros_dia excluiremos del cursos los siniestros que
      -- generan renta (PRESTAREN).
      -- Se añade la condicion AND NOT EXISTS (SELECT 1 FROM prestaren p WHERE p.nsinies = si.nsinies)
      -- Ademas se debe añadir ccausin = 8
      CURSOR cur_siniestros_dia IS
         SELECT   /*+ INDEX(si SINIES_NUK_1) */
                  d.tmotsin, si.sseguro, TO_CHAR(si.nsinies) nsinies, si.fsinies, s.npoliza,
                  s.ncertif, s.cempres, si.ccausin
             FROM siniestros si, seguros s, desmotsini d, segdisin2 se
            WHERE si.sseguro = s.sseguro
              AND s.cagrpro IN(11, 21)   -- 12442.NMM.12/2009.Afegim l' 11.
              AND(s.sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cramo = pcramo
                  OR pcramo IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND(s.cempres = pcempresa
                  OR pcempresa IS NULL)
              --AND TRUNC(si.fnotifi) = TRUNC(pffecha)
              AND si.ccausin IN(1, 3, 4, 5, 8)
              AND(si.cmotsin NOT IN(2, 4)
                  OR(si.cmotsin = 2
                     AND si.ccausin = 8))
              --AND si.cestsin NOT IN(1, 2, 3)   -- finalizado, Anulado o Rechazado
              AND s.sseguro = se.sseguro
              AND se.nmovimi = (SELECT MAX(nmovimi)
                                  FROM segdisin2
                                 WHERE sseguro = s.sseguro)
              AND((si.cestsin NOT IN(1, 2, 3)
                   AND si.ccausin IN(1, 3, 4, 5)
                   AND TRUNC(si.fnotifi) = TRUNC(pffecha))
                  OR
                    -- Traspasos realizados a la fecha con fecha valor la del siniestro
                  (  si.ccausin = 8
                     AND NOT EXISTS(SELECT 1
                                      FROM tabvalces
                                     WHERE ccesta = se.ccesta
                                       AND fvalor = TRUNC(si.fsinies))
                     AND TRUNC(si.fsinies) = TRUNC(pffecha))
                  OR
                    -- Traspasos realizados a la fecha con fecha valor anterior (valor liquidativo ya entrado)
                  (  si.ccausin = 8
                     AND EXISTS(SELECT 1
                                  FROM tabvalces
                                 WHERE ccesta = se.ccesta
                                   AND fvalor = TRUNC(si.fsinies))
                     AND TRUNC(si.falta) = TRUNC(pffecha)
                     AND TRUNC(si.fsinies) < TRUNC(pffecha)))
              AND d.cramo = s.cramo
              AND d.ccausin = si.ccausin
              AND d.cmotsin = si.cmotsin
              AND d.cidioma = pcidioma
              AND NOT EXISTS(SELECT 1
                               FROM prestaren p
                              WHERE p.nsinies = si.nsinies)
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT   /*+ INDEX(si SINIES_NUK_1) */
                  d.tmotsin, si.sseguro, si.nsinies, si.fsinies, s.npoliza, s.ncertif,
                  s.cempres, si.ccausin
             FROM sin_siniestro si, seguros s, sin_desmotcau d, sin_movsiniestro sm,
                  segdisin2 se
            WHERE si.sseguro = s.sseguro
              AND s.cagrpro IN(11, 21)   -- 12442.NMM.12/2009. Afegim l' 11.
              AND(s.sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cramo = pcramo
                  OR pcramo IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND(s.cempres = pcempresa
                  OR pcempresa IS NULL)
              AND(si.ccausin IN(1, 3, 4, 5, 8)
                  OR(si.ccausin IN(2410, 2411, 2412, 2413, 2414, 2415, 2416, 2417, 2418, 2419,
                                   2420, 2421, 2422, 2423, 2424)
                     AND EXISTS(SELECT 1
                                  FROM sin_tramita_reserva st
                                 WHERE st.nsinies = si.nsinies
                                   AND st.ctipres = 1   -- jlb - 18423#c105054
                                   AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg,
                                                           s.ccolect, s.cactivi, st.cgarant,
                                                           'GAR_CONTRA_CTASEGURO'),
                                           0) = 1)))
              AND(si.cmotsin NOT IN(2, 4)
                  OR(si.cmotsin = 2
                     AND si.ccausin = 8))
              AND si.nsinies = sm.nsinies
              AND sm.nmovsin = (SELECT MAX(nmovsin)
                                  FROM sin_movsiniestro
                                 WHERE nsinies = sm.nsinies)
              --AND sm.cestsin NOT IN(1, 2, 3)
              AND s.sseguro = se.sseguro
              AND se.nmovimi = (SELECT MAX(nmovimi)
                                  FROM segdisin2
                                 WHERE sseguro = s.sseguro)
              AND((sm.cestsin NOT IN(1, 2, 3)
                   AND(si.ccausin IN(1, 3, 4, 5)
                       OR(si.ccausin IN(2410, 2411, 2412, 2413, 2414, 2415, 2416, 2417, 2418,
                                        2419, 2420, 2421, 2422, 2423, 2424)
                          AND EXISTS(SELECT 1
                                       FROM sin_tramita_reserva st
                                      WHERE st.nsinies = si.nsinies
                                        AND st.ctipres = 1   -- jlb - 18423#c105054
                                        AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg,
                                                                s.ccolect, s.cactivi,
                                                                st.cgarant,
                                                                'GAR_CONTRA_CTASEGURO'),
                                                0) = 1)))
                   AND TRUNC(si.fnotifi) = TRUNC(pffecha))
                  OR
                    -- Traspasos realizados a la fecha con fecha valor la del siniestro
                  (  si.ccausin = 8
                     AND NOT EXISTS(SELECT 1
                                      FROM tabvalces
                                     WHERE ccesta = se.ccesta
                                       AND fvalor = TRUNC(si.fsinies))
                     AND TRUNC(si.fsinies) = TRUNC(pffecha))
                  OR
                    -- Traspasos realizados a la fecha con fecha valor anterior (valor liquidativo ya entrado)
                  (  si.ccausin = 8
                     AND EXISTS(SELECT 1
                                  FROM tabvalces
                                 WHERE ccesta = se.ccesta
                                   AND fvalor = TRUNC(si.fsinies))
                     AND TRUNC(si.falta) = TRUNC(pffecha)
                     AND TRUNC(si.fsinies) < TRUNC(pffecha)))
              --AND d.cramo = s.cramo
              AND d.ccausin = si.ccausin
              AND d.cmotsin = si.cmotsin
              AND d.cidioma = pcidioma
              AND NOT EXISTS(SELECT 1
                               FROM prestaren p
                              WHERE p.nsinies = si.nsinies)
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1
         --ORDER BY s.npoliza, s.ncertif;
         ORDER BY 5, 6;

      -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
      CURSOR cur_siniestros_dia_anul_rech IS
         SELECT   /*+ INDEX(si SINIES_NUK_1) */
                  d.tmotsin, si.sseguro, TO_CHAR(si.nsinies) nsinies, si.fsinies, s.npoliza,
                  s.ncertif, s.cempres, si.ccausin, NULL nmovsin
             FROM siniestros si, seguros s, desmotsini d, segdisin2 se
            WHERE si.sseguro = s.sseguro
              AND s.cagrpro IN(11, 21)
              AND(s.sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cramo = pcramo
                  OR pcramo IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND(s.cempres = pcempresa
                  OR pcempresa IS NULL)
              AND si.ccausin IN(1, 3, 4, 5, 8)
              AND(si.cmotsin NOT IN(2, 4)
                  OR(si.cmotsin = 2
                     AND si.ccausin = 8))
              AND s.sseguro = se.sseguro
              AND se.nmovimi = (SELECT MAX(nmovimi)
                                  FROM segdisin2
                                 WHERE sseguro = s.sseguro)
              AND si.cestsin IN(2, 3)
              AND TRUNC(si.festsin) = TRUNC(pffecha)
              AND d.cramo = s.cramo
              AND d.ccausin = si.ccausin
              AND d.cmotsin = si.cmotsin
              AND d.cidioma = pcidioma
              AND NOT EXISTS(SELECT 1
                               FROM prestaren p
                              WHERE p.nsinies = si.nsinies)
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT   /*+ INDEX(si SINIES_NUK_1) */
                  d.tmotsin, si.sseguro, si.nsinies, si.fsinies, s.npoliza, s.ncertif,
                  s.cempres, si.ccausin, sm.nmovsin
             FROM sin_siniestro si, seguros s, sin_desmotcau d, sin_movsiniestro sm,
                  segdisin2 se
            WHERE si.sseguro = s.sseguro
              AND s.cagrpro IN(11, 21)
              AND(s.sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cramo = pcramo
                  OR pcramo IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND(s.cempres = pcempresa
                  OR pcempresa IS NULL)
              AND(si.ccausin IN(1, 3, 4, 5, 8)
                  OR(si.ccausin IN(2410, 2411, 2412, 2413, 2414, 2415, 2416, 2417, 2418, 2419,
                                   2420, 2421, 2422, 2423, 2424)
                     AND EXISTS(SELECT 1
                                  FROM sin_tramita_reserva st
                                 WHERE st.nsinies = si.nsinies
                                   AND st.ctipres = 1   -- jlb - 18423#c105054
                                   AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg,
                                                           s.ccolect, s.cactivi, st.cgarant,
                                                           'GAR_CONTRA_CTASEGURO'),
                                           0) = 1)))
              AND(si.cmotsin NOT IN(2, 4)
                  OR(si.cmotsin = 2
                     AND si.ccausin = 8))
              AND si.nsinies = sm.nsinies
              AND sm.nmovsin = (SELECT MAX(nmovsin)
                                  FROM sin_movsiniestro
                                 WHERE nsinies = sm.nsinies)
              AND s.sseguro = se.sseguro
              AND se.nmovimi = (SELECT MAX(nmovimi)
                                  FROM segdisin2
                                 WHERE sseguro = s.sseguro)
              AND sm.cestsin IN(2, 3)
              AND TRUNC(sm.festsin) = TRUNC(pffecha)
              AND d.ccausin = si.ccausin
              AND d.cmotsin = si.cmotsin
              AND d.cidioma = pcidioma
              AND NOT EXISTS(SELECT 1
                               FROM prestaren p
                              WHERE p.nsinies = si.nsinies)
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1
         ORDER BY 5, 6;

      -- Fin Bug 20853
      CURSOR cur_segdisin2(psseguro IN NUMBER) IS
         SELECT p.ccodfon, s.ccesta, s.pdistrec
           FROM segdisin2 s, fondos p
          WHERE s.sseguro = psseguro
            AND s.ffin IS NULL
            AND s.ccesta = p.ccodfon
            AND s.nmovimi = (SELECT MAX(s2.nmovimi)
                               FROM segdisin2 s2
                              WHERE s2.sseguro = psseguro
                                AND s2.ffin IS NULL);

      PROCEDURE f_cabecera IS
         cabecera       VARCHAR2(1000);
      BEGIN
         cabecera := f_axis_literales(100857, pcidioma)   -- Empresa
                                                       || ';'
                     || nvl2x(pcempresa, fpv_desempresa(pcempresa), v_literal_tots)   -- Descripción de la Empresa
                                                                                   ;
         UTL_FILE.put_line(v_fichero, cabecera);
         cabecera := f_axis_literales(100706, pcidioma)   -- Agrupación:
                                                       || ';'
                     || nvl2x(21, fpv_desagrpro(pcidioma, 21), v_literal_tots)   -- Descripción de la Agrupación
                     || ';' || ' '   -- Columna en blanco
                                  || ';' || f_axis_literales(100562, pcidioma)   -- Fecha
                     || ';' || f_sysdate   -- Descripcion de la Desde
                                        ;
         UTL_FILE.put_line(v_fichero, cabecera);
         cabecera := f_axis_literales(100765, pcidioma)   -- Ramo:
                                                       || ';'
                     || nvl2x(pcramo, fpv_desramo(pcidioma, pcramo), v_literal_tots)   -- Descripción del Ramo
                     || ';' || ' ' || ';'
                     || f_axis_literales(180734, pcidioma)   -- Fecha de consulta
                                                          || ';'
                     || pffecha   -- Descripcion de la Desde
                               ;
         UTL_FILE.put_line(v_fichero, cabecera);
         cabecera := f_axis_literales(100681, pcidioma)   -- Producto
                                                       || ';'
                     || nvl2x(psproduc, fpv_desproducto(pcidioma, psproduc), v_literal_tots)   -- Descripción del Producto
                                                                                            ;
         UTL_FILE.put_line(v_fichero, cabecera);
         cabecera := f_axis_literales(102591, pcidioma)   -- Oficina:
                                                       || ';'
                     || nvl2x(pcagente, fpv_desagente(pcidioma, pcagente), v_literal_totes)   -- Descripción de la Oficina
                                                                                           ;
         UTL_FILE.put_line(v_fichero, cabecera);
         -- Se insertan dos lineas en blanco
         UTL_FILE.put_line(v_fichero, NULL);
         UTL_FILE.put_line(v_fichero, NULL);
         cabecera := UPPER(f_axis_literales(101945, pcidioma)) || ';'
                     || UPPER(f_axis_literales(100562, pcidioma)) || ';'
                     || UPPER(f_axis_literales(105998, pcidioma)) || ';'
                     || UPPER(f_axis_literales(107059, pcidioma)) || ';'
                     || UPPER(f_axis_literales(100563, pcidioma)) || ';'
                     || UPPER(f_axis_literales(108490, pcidioma)) || ';'
                     || UPPER(f_axis_literales(180719, pcidioma)) || ';' || ';'
                     || UPPER(f_axis_literales(107599, pcidioma)) || ';'
                     || UPPER(f_axis_literales(180720, pcidioma));
         UTL_FILE.put_line(v_fichero, cabecera);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, getuser, 'pac_excel.f_sictr024.f_cabecera', NULL, NULL,
                        SQLERRM);
            RAISE ex_error;
      END f_cabecera;
   BEGIN
      IF pcidioma IS NULL
         OR pffecha IS NULL THEN
         perror := -1;
         RAISE ex_error;
      END IF;

      v_fichero := UTL_FILE.fopen(v_ruta, v_nomfit, 'W');
      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Añadimos ruta 'INFORMES_C' al nombre retornado
      v_nombre_fichero(1).nombre := f_parinstalacion_t('INFORMES_C') || '\' || v_nomfit;
      f_cabecera;

      -- cursor sobre cestas para llenar tabla. Inicialización
      FOR i IN cur_cestas LOOP
         vfondoentrada(i.ccodfon) := 0;
         vfondosalidas(i.ccodfon) := 0;
      END LOOP;

      FOR r_dades IN
         (SELECT   --+ ORDERED USE_NL(s c) INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                   c.sseguro, s.sproduc, c.nnumlin,
                   f_formatopol(s.npoliza, s.ncertif, 1) contrato, c.fvalmov, c.cmovimi,
                   d.tatribu, c.cesta, c.imovimi,
                   CASE
                      WHEN c.cesta IS NOT NULL THEN f_gettabvalces(c.cesta,
                                                                   pffecha)
                      ELSE NULL
                   END valor_teorico,
                   CASE
                      WHEN c.cesta IS NOT NULL THEN f_getdate_tabvalces(c.cesta,
                                                                        pffecha)
                      ELSE NULL
                   END fvalora
              FROM seguros s, ctaseguro c, detvalores d
             WHERE s.sseguro = c.sseguro
               AND s.cagrpro IN(11, 21)   -- 12442.NMM.12/2009. Afegim l' 11.
               AND(s.sproduc = psproduc
                   OR psproduc IS NULL)
               AND(s.cramo = pcramo
                   OR pcramo IS NULL)
               AND(s.cagente = pcagente
                   OR pcagente IS NULL)
               AND(s.cempres = pcempresa
                   OR pcempresa IS NULL)
               AND c.fvalmov >= TRUNC(pffecha)
               AND c.fvalmov < TRUNC(pffecha) + 1
               AND d.cvalor = 83
               AND d.catribu = c.cmovimi
               AND d.cidioma = pcidioma
               AND c.nunidad IS NULL
               AND c.cmovimi <> 0
               --and c.cesta = NVL(pccodfon,c.cesta) -- 17/03/2009
               AND (SELECT c2.nunidad
                      FROM ctaseguro c2
                     WHERE c2.sseguro = c.sseguro
                       --AND trunc(c2.fcontab) = trunc(c.fcontab)
                       AND c2.nnumlin = c.nnumlin + 1) IS NULL   -- excloem els que ja estan asignats
               AND (SELECT COUNT(*)
                      FROM ctaseguro c3
                     WHERE c3.sseguro = c.sseguro
                       AND c3.ccalint = c.ccalint) >
                                         1   -- excloem les parts Europlazo de Ibex 35 Garantizado
          UNION
          SELECT   --+ INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                   s.sseguro, s.sproduc, c.nnumlin,
                   f_formatopol(s.npoliza, s.ncertif, 1) contrato, c.ffecmov, c.cmovimi,
                   d.tatribu, c.cesta, c.imovimi, t.iuniact, t.fvalor fvalora
              FROM ctaseguro c, seguros s, detvalores d, tabvalces t
             WHERE s.sseguro = c.sseguro
               AND s.cagrpro IN(11, 21)   -- 12442.NMM.12/2009. Afegim l' 11.
               AND(s.sproduc = psproduc
                   OR psproduc IS NULL)
               AND(s.cramo = pcramo
                   OR pcramo IS NULL)
               AND(s.cagente = pcagente
                   OR pcagente IS NULL)
               AND(s.cempres = pcempresa
                   OR pcempresa IS NULL)
               AND c.ffecmov >= TRUNC(pffecha)
               AND c.ffecmov < TRUNC(pffecha) + 1
               AND c.fvalmov < c.ffecmov
               AND d.cvalor = 83
               AND d.catribu = c.cmovimi
               AND d.cidioma = pcidioma
               --and c.cesta = NVL(pccodfon,c.cesta) -- 17/03/2009
               AND c.cmovimi IN(51, 58, 10, 90)
               -- También cogemos aquellos movimientos de anulación generados en el dia pero con fecha valor anterior
               -- (por la anulación de aportación). Son movimientos que aunque consolidados se deben mostrar en la sección de operaciones
               -- del dia para que la compañia tenga constancia del movimiento y actue vendiendo parti cipaciones en conseqüencia
               AND c.cesta = t.ccesta(+)
               AND c.fvalmov = t.fvalor(+)
          ORDER BY sseguro, sproduc, nnumlin) LOOP
         ventra := 1;
         -- Colocamos el contrato
         vcontratob := r_dades.sseguro;

         IF vcontratob = vcontratoa THEN
            v_cadena := NULL;
         ELSE
            -- Antes de cambiar de seguro mostramos los Siniestros / Rescates. Iteramos sobre los siniestros del dia del seguro que ha tenido movimientos hoy
            -- Esto es para tener las operaciones de rescate junto con las operaciones del dia en lugar de tenerlas por separado (en el excel).
            v_cadena := r_dades.contrato;
            vcontratoa := vcontratob;
         END IF;

         BEGIN
            SELECT tfonabv
              INTO v_tfonabv
              FROM fondos
             WHERE ccodfon = r_dades.cesta;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_tfonabv := NULL;
         END;

         IF v_tfonabv IS NOT NULL THEN
            v_cadena := v_cadena || ';' || r_dades.fvalmov || ';' || r_dades.tatribu || ';'
                        || r_dades.cesta || ' - ' || v_tfonabv;
         ELSE
            v_cadena := v_cadena || ';' || r_dades.fvalmov || ';' || r_dades.tatribu || ';'
                        || r_dades.cesta;
         END IF;

         IF r_dades.cesta IS NULL THEN
            IF r_dades.cmovimi IN(60, 70) THEN
               total_cestas := 0;
               tcesta_unidades := 0;
               v_det_modinv.DELETE;
               num_err := pac_operativa_finv.f_cta_saldo_fondos(r_dades.sseguro, NULL,
                                                                total_cestas, tcesta_unidades,
                                                                v_det_modinv);
               vcurimovimi := total_cestas;
            ELSIF r_dades.cmovimi IN(80) THEN
               total_cestas := 0;
               tcesta_unidades := 0;
               v_det_modinv.DELETE;
               num_err := pac_operativa_finv.f_cta_saldo_fondos(r_dades.sseguro, NULL,
                                                                total_cestas, tcesta_unidades,
                                                                v_det_modinv);
               num_err := pac_operativa_finv.f_gastos_redistribucion_anual(r_dades.sseguro,
                                                                           total_cestas,
                                                                           vgredanual);
               vcurimovimi := vgredanual;
            ELSE
               vcurimovimi := r_dades.imovimi;   -- Importe del movimiento
            END IF;

            -- Llenamos el Hash de conceptos para luego mostrarlo en el listado
            IF vhashconceptos.EXISTS(r_dades.tatribu) THEN
               vhashconceptos(r_dades.tatribu) := vhashconceptos(r_dades.tatribu)
                                                  + vcurimovimi;
            ELSE
               vhashconceptos(r_dades.tatribu) := vcurimovimi;
            END IF;

---------------------------------------------------------------------------
            v_cadena := v_cadena || ';' || vcurimovimi;
            v_cadena := v_cadena || ';' || ';' || ';' || ';' || ';';
            vimovim_g := vcurimovimi;
         ELSE
            IF r_dades.cmovimi IN(61) THEN
               tcesta_unidades := 0;
               tcesta_importe := 0;
               total_cestas := 0;
               -- Existe una redistribución pendiente para el seguro
               num_err := pac_operativa_finv.f_cta_provision_cesta(r_dades.sseguro, NULL,
                                                                   TRUNC(pffecha),
                                                                   r_dades.cesta,
                                                                   tcesta_unidades,
                                                                   tcesta_importe,
                                                                   total_cestas);
               v_cadena := v_cadena || ';' || tcesta_importe || ';'
                           || tcesta_importe / r_dades.valor_teorico || ';'
                           || r_dades.valor_teorico || ';' || '(' || r_dades.fvalora || ')'
                           || ';' || f_get_segdisin2(r_dades.sseguro, r_dades.cesta, 1) || ';'
                           || tcesta_importe;
               -- Actualizamos los valores de entradas / salidas
               vfondosalidas(r_dades.cesta) := vfondosalidas(r_dades.cesta) + tcesta_importe;
            ELSIF r_dades.cmovimi IN(71, 81) THEN
               v_cadena := v_cadena || ';'
                           || vimovim_g
                              *(f_get_segdisin2(r_dades.sseguro, r_dades.cesta) / 100) || ';'
                           || vimovim_g
                              *(f_get_segdisin2(r_dades.sseguro, r_dades.cesta) / 100)
                              / r_dades.valor_teorico
                           || ';' || r_dades.valor_teorico || ';' || '(' || r_dades.fvalora
                           || ')' || ';' || f_get_segdisin2(r_dades.sseguro, r_dades.cesta)
                           || ';'
                           || vimovim_g
                              *(f_get_segdisin2(r_dades.sseguro, r_dades.cesta) / 100);

               -- Actualizamos los valores de entradas / salidas
               IF r_dades.cmovimi = 71 THEN
                  vfondoentrada(r_dades.cesta) :=
                     vfondoentrada(r_dades.cesta)
                     + vimovim_g *(f_get_segdisin2(r_dades.sseguro, r_dades.cesta) / 100);
               ELSIF r_dades.cmovimi = 81 THEN
                  -- Los gastos los descontamos de las entradas
                  vfondoentrada(r_dades.cesta) :=
                     vfondoentrada(r_dades.cesta)
                     - vimovim_g *(f_get_segdisin2(r_dades.sseguro, r_dades.cesta) / 100);
               END IF;
            ELSE
               v_cadena := v_cadena || ';' || r_dades.imovimi || ';'
                           || r_dades.imovimi / r_dades.valor_teorico || ';'
                           || r_dades.valor_teorico || ';' || '(' || r_dades.fvalora || ')'
                           || ';' || (r_dades.imovimi / vimovim_g) * 100 || ';'
                           || r_dades.imovimi;

               -- Actualizamos los valores de entradas / salidas
               -- Bug 15707 - APD - 25/02/2011 - En el cursor de movimientos de ctaseguro pueden
               -- entrar movimientos 90 que son anulaciones de pago de renta y se deben tratar como entradas
               IF r_dades.cmovimi IN(45, 46, 90) THEN
                  vfondoentrada(r_dades.cesta) :=
                                                 vfondoentrada(r_dades.cesta)
                                                 + r_dades.imovimi;
               ELSE
                  vfondosalidas(r_dades.cesta) :=
                                                 vfondosalidas(r_dades.cesta)
                                                 + r_dades.imovimi;
               END IF;
            END IF;
         END IF;

         -- Tratamiento para la última póliza
         UTL_FILE.put_line(v_fichero, v_cadena);
      END LOOP;

      IF ventra = 0 THEN
         v_cadena := ';' || ';' || f_axis_literales(180717, pcidioma);   -- No hay mas datos para este informe
         UTL_FILE.put_line(v_fichero, v_cadena);
      END IF;

      ventra := 0;
---------------------------------------------------------------------
-- Iteramos sobre los siniestros del dia que no han tenido movimientos hoy
      UTL_FILE.put_line(v_fichero, NULL);
      UTL_FILE.put_line(v_fichero, UPPER(f_axis_literales(180725, pcidioma)));
      UTL_FILE.put_line(v_fichero, NULL);
      -- Colocamos el contrato
      vcontratob := NULL;
      vcontratoa := NULL;

      -- Mostramos la sección de Siniestros / Rescates del día
      FOR regsini IN cur_siniestros_dia LOOP
         ventra := 1;
         -- Colocamos el contrato
         vcontratob := regsini.sseguro;

         IF vcontratob = vcontratoa THEN
            vcontrato := NULL;
         ELSE
            SELECT npoliza, ncertif
              INTO vnpoliza, vncertif
              FROM seguros
             WHERE sseguro = regsini.sseguro;

            vcontrato := f_formatopol(vnpoliza, vncertif, 1);
         END IF;

         -- Bug 20309 - RSC - 29/11/2011 - LCOL_T004-Parametrización Fondos
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = regsini.sseguro;

         -- Fin Bug 20309
         FOR regs2 IN cur_segdisin2(regsini.sseguro) LOOP
            -- Bug 14160 - RSC - 16/04/2010: CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
            vcontansin := 0;

            -- Bug 15707 - APD - 14/03/2011 - Tratar el ccausin = 8 como si fuera un rescate parcial
            IF regsini.ccausin IN(5, 8) THEN
               -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               IF NVL(pac_parametros.f_parempresa_n(regsini.cempres, 'MODULO_SINI'), 0) = 0 THEN
                  SELECT COUNT(*)
                    INTO vcontansin
                    FROM valorasini
                   WHERE nsinies = regsini.nsinies;
               ELSE
                  SELECT COUNT(*)
                    INTO vcontansin
                    FROM sin_tramita_reserva
                   WHERE nsinies = regsini.nsinies
                     AND ctipres = 1   -- jlb - 18423#c105054
                     AND nmovres = (SELECT MAX(v1.nmovres)
                                      FROM sin_tramita_reserva v1
                                     WHERE v1.nsinies = sin_tramita_reserva.nsinies
                                       AND v1.ctipres = sin_tramita_reserva.ctipres);
               END IF;
            END IF;

            -- Fin Bug 14160
            IF vcontansin <> 0 THEN
               -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               IF NVL(pac_parametros.f_parempresa_n(regsini.cempres, 'MODULO_SINI'), 0) = 0 THEN
                  SELECT ivalora, fvalora, icaprisc, NVL(ipenali, 0)
                    INTO vivalora, vfvalora, v_icaprisc, v_ipenali
                    FROM valorasini
                   WHERE nsinies = regsini.nsinies;
               ELSE
                  SELECT ireserva, fmovres, icaprie, NVL(ipenali, 0)
                    INTO vivalora, vfvalora, v_icaprisc, v_ipenali
                    FROM sin_tramita_reserva
                   WHERE nsinies = regsini.nsinies
                     AND ctipres = 1   -- jlb - 18423#c105054
                     AND nmovres = (SELECT MAX(v1.nmovres)
                                      FROM sin_tramita_reserva v1
                                     WHERE v1.nsinies = sin_tramita_reserva.nsinies
                                       AND v1.ctipres = sin_tramita_reserva.ctipres);
               END IF;

               --PRECIO UNIDAD
               BEGIN
                  SELECT NVL(iuniact, 0), fvalor
                    INTO v_vliq_resc, v_vliq_date
                    FROM tabvalces
                   WHERE ccesta = regs2.ccesta
                     AND TRUNC(fvalor) = TRUNC(vfvalora);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT NVL(iuniact, 0), fvalor
                       INTO v_vliq_resc, v_vliq_date
                       FROM tabvalces
                      WHERE ccesta = regs2.ccesta
                        AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                               FROM tabvalces
                                              WHERE ccesta = regs2.ccesta
                                                AND TRUNC(fvalor) <= TRUNC(vfvalora));
               END;

               BEGIN
                  SELECT tfonabv
                    INTO v_tfonabv
                    FROM fondos
                   WHERE ccodfon = regs2.ccodfon;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_tfonabv := NULL;
               END;

               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  IF v_tfonabv IS NOT NULL THEN
                     v_cadena := vcontrato || ';' || pffecha || ';' || regsini.tmotsin || ';'
                                 || regs2.ccodfon || ' - ' || v_tfonabv || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100)) || ';'
                                 || ((v_icaprisc *(regs2.pdistrec / 100))) / v_vliq_resc
                                 || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100));
                  ELSE
                     v_cadena := vcontrato || ';' || pffecha || ';' || regsini.tmotsin || ';'
                                 || regs2.ccodfon || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100)) || ';'
                                 || ((v_icaprisc *(regs2.pdistrec / 100))) / v_vliq_resc
                                 || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100));
                  END IF;
               ELSE
                  IF v_tfonabv IS NOT NULL THEN
                     v_cadena := vcontrato || ' - ' || regsini.nsinies || ';' || pffecha
                                 || ';' || regsini.tmotsin || ';' || regs2.ccodfon || ' - '
                                 || v_tfonabv || ';'
                                 ||((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100)) || ';'
                                 || (((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100)))
                                    / v_vliq_resc
                                 || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100));
                     UTL_FILE.put_line(v_fichero, v_cadena);

                     IF NVL(v_ipenali, 0) <> 0 THEN
                        v_cadena := '' || ';' || '' || ';'
                                    || f_axis_literales(109713, pcidioma) || ';'
                                    || regs2.ccodfon || ' - ' || v_tfonabv || ';'
                                    ||(v_ipenali *(regs2.pdistrec / 100)) || ';'
                                    || ((v_ipenali *(regs2.pdistrec / 100))) / v_vliq_resc
                                    || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                    || ';' || regs2.pdistrec || ';'
                                    ||(v_ipenali *(regs2.pdistrec / 100));
                     END IF;
                  ELSE
                     v_cadena := vcontrato || ' - ' || regsini.nsinies || ';' || pffecha
                                 || ';' || regsini.tmotsin || ';' || regs2.ccodfon || ';'
                                 ||((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100)) || ';'
                                 || (((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100)))
                                    / v_vliq_resc
                                 || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 ||((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100));
                     UTL_FILE.put_line(v_fichero, v_cadena);

                     IF NVL(v_ipenali, 0) <> 0 THEN
                        v_cadena := '' || ';' || '' || ';'
                                    || f_axis_literales(109713, pcidioma) || ';'
                                    || regs2.ccodfon || ';'
                                    ||(v_ipenali *(regs2.pdistrec / 100)) || ';'
                                    || ((v_ipenali *(regs2.pdistrec / 100))) / v_vliq_resc
                                    || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                    || ';' || regs2.pdistrec || ';'
                                    ||(v_ipenali *(regs2.pdistrec / 100));
                     END IF;
                  END IF;
               END IF;

               vcontrato := NULL;

               -- Llenamos el Hash de conceptos para luego mostrarlo en el listado
               IF vhashconceptos.EXISTS(regsini.tmotsin) THEN
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                     vhashconceptos(regsini.tmotsin) :=
                          vhashconceptos(regsini.tmotsin)
                          +(v_icaprisc *(regs2.pdistrec / 100));
                  ELSE
                     vhashconceptos(regsini.tmotsin) :=
                        vhashconceptos(regsini.tmotsin)
                        +((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100));
                     vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                        vhashconceptos(f_axis_literales(109713, pcidioma))
                        +(v_ipenali *(regs2.pdistrec / 100));
                  END IF;
               ELSE
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                     vhashconceptos(regsini.tmotsin) :=(v_icaprisc *(regs2.pdistrec / 100));
                  ELSE
                     vhashconceptos(regsini.tmotsin) :=
                                             ((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100));
                     vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                                                            (v_ipenali *(regs2.pdistrec / 100));
                  END IF;
               END IF;

               -- Actualizamos los valores de entradas / salidas
               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  vfondosalidas(regs2.ccodfon) :=
                             vfondosalidas(regs2.ccodfon)
                             +(v_icaprisc *(regs2.pdistrec / 100));
               ELSE
                  vfondosalidas(regs2.ccodfon) :=
                     vfondosalidas(regs2.ccodfon)
                     +((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100));
                  vfondoentrada(regs2.ccodfon) :=
                              vfondoentrada(regs2.ccodfon)
                              +(v_ipenali *(regs2.pdistrec / 100));
               END IF;
            ELSE
               -- Saldo de participaciones de la cesta en el seguro (provision de la cesta)
               SELECT NVL(SUM(nunidad), 0)
                 INTO vunidades
                 FROM ctaseguro
                WHERE sseguro = regsini.sseguro
                  AND cmovimi <> 0
                  AND cesta = regs2.ccesta
                  AND fvalmov <= pffecha
                  AND((cestado <> '9')
                      OR(cestado = '9'
                         AND imovimi <> 0
                         AND imovimi IS NOT NULL));

               BEGIN
                  SELECT NVL(iuniact, 0), fvalor
                    INTO precio_uni, v_vliq_date
                    FROM tabvalces
                   WHERE ccesta = regs2.ccesta
                     AND TRUNC(fvalor) = TRUNC(regsini.fsinies);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT NVL(iuniact, 0), fvalor
                       INTO precio_uni, v_vliq_date
                       FROM tabvalces
                      WHERE ccesta = regs2.ccesta
                        AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                               FROM tabvalces
                                              WHERE ccesta = regs2.ccesta
                                                AND TRUNC(fvalor) <= TRUNC(regsini.fsinies));
               END;

               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  v_cadena := vcontrato || ';' || pffecha || ';' || regsini.tmotsin || ';'
                              || regs2.ccodfon || ';' || vunidades * precio_uni || ';'
                              || (vunidades * precio_uni) / precio_uni || ';' || precio_uni
                              || ';' || '(' || v_vliq_date || ')' || ';' || regs2.pdistrec
                              || ';' || vunidades * precio_uni;
               ELSE
                  v_ppenali :=
                     NVL(calc_rescates.fporcenpenali(NULL, regsini.sseguro,
                                                     TO_NUMBER(TO_CHAR(regsini.fsinies,
                                                                       'YYYYMMDD')),
                                                     4),
                         0)
                     / 100;

                  -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                     v_rendiment :=
                        pac_operativa_finv.ffrendiment(NULL, regsini.sseguro,
                                                       TO_NUMBER(TO_CHAR(regsini.fsinies,
                                                                         'YYYYMMDD')));

                     IF precio_uni > 0 THEN
                        v_unidades_rend := v_rendiment / precio_uni;
                     END IF;

                     v_cadena := vcontrato || ' - ' || regsini.nsinies || ';' || pffecha || ';'
                                 || regsini.tmotsin || ';' || regs2.ccodfon || ';'
                                 || (vunidades -(v_unidades_rend * v_ppenali)) * precio_uni
                                 || ';'
                                 || ((vunidades -(v_unidades_rend * v_ppenali)) * precio_uni)
                                    / precio_uni
                                 || ';' || precio_uni || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 || (vunidades -(v_unidades_rend * v_ppenali)) * precio_uni;

                     IF (v_unidades_rend * v_ppenali) <> 0 THEN
                        UTL_FILE.put_line(v_fichero, v_cadena);
                        v_cadena := '' || ';' || '' || ';'
                                    || f_axis_literales(109713, pcidioma) || ';'
                                    || regs2.ccodfon || ';'
                                    || (v_unidades_rend * v_ppenali) * precio_uni || ';'
                                    || ((v_unidades_rend * v_ppenali) * precio_uni)
                                       / precio_uni || ';' || precio_uni || ';' || '('
                                    || v_vliq_date || ')' || ';' || regs2.pdistrec || ';'
                                    || (v_unidades_rend * v_ppenali) * precio_uni;
                     END IF;
                  ELSE
                     v_cadena := vcontrato || ' - ' || regsini.nsinies || ';' || pffecha
                                 || ';' || regsini.tmotsin || ';' || regs2.ccodfon || ';'
                                 || (vunidades -(vunidades * v_ppenali)) * precio_uni || ';'
                                 || ((vunidades -(vunidades * v_ppenali)) * precio_uni)
                                    / precio_uni
                                 || ';' || precio_uni || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 || (vunidades -(vunidades * v_ppenali)) * precio_uni;

                     IF (vunidades * v_ppenali) <> 0 THEN
                        UTL_FILE.put_line(v_fichero, v_cadena);
                        v_cadena := '' || ';' || '' || ';'
                                    || f_axis_literales(109713, pcidioma) || ';'
                                    || regs2.ccodfon || ';'
                                    || (vunidades * v_ppenali) * precio_uni || ';'
                                    || ((vunidades * v_ppenali) * precio_uni) / precio_uni
                                    || ';' || precio_uni || ';' || '(' || v_vliq_date || ')'
                                    || ';' || regs2.pdistrec || ';'
                                    || (vunidades * v_ppenali) * precio_uni;
                     END IF;
                  END IF;
               END IF;

               vcontrato := NULL;

               -- Llenamos el Hash de conceptos para luego mostrarlo en el listado
               IF vhashconceptos.EXISTS(regsini.tmotsin) THEN
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                     vhashconceptos(regsini.tmotsin) :=
                                      vhashconceptos(regsini.tmotsin)
                                      +(vunidades * precio_uni);
                  ELSE
                     -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
                     IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                        vhashconceptos(regsini.tmotsin) :=
                           vhashconceptos(regsini.tmotsin)
                           +((vunidades -(v_unidades_rend * v_ppenali)) * precio_uni);
                        vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                           vhashconceptos(f_axis_literales(109713, pcidioma))
                           +((v_unidades_rend * v_ppenali) * precio_uni);
                     ELSE
                        -- Fin bug 20853
                        vhashconceptos(regsini.tmotsin) :=
                           vhashconceptos(regsini.tmotsin)
                           +((vunidades -(vunidades * v_ppenali)) * precio_uni);
                        vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                           vhashconceptos(f_axis_literales(109713, pcidioma))
                           +((vunidades * v_ppenali) * precio_uni);
                     END IF;
                  END IF;
               ELSE
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                     vhashconceptos(regsini.tmotsin) := vunidades * precio_uni;
                  ELSE
                     -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
                     IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                        vhashconceptos(regsini.tmotsin) :=
                                        (vunidades -(v_unidades_rend * v_ppenali)) * precio_uni;
                        vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                                                      (v_unidades_rend * v_ppenali)
                                                      * precio_uni;
                     ELSE
                        -- FIn Bug 20853
                        vhashconceptos(regsini.tmotsin) :=
                                              (vunidades -(vunidades * v_ppenali)) * precio_uni;
                        vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                                                            (vunidades * v_ppenali)
                                                            * precio_uni;
                     END IF;
                  END IF;
               END IF;

               -- Actualizamos los valores de entradas / salidas
               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  vfondosalidas(regs2.ccodfon) :=
                                         vfondosalidas(regs2.ccodfon)
                                         +(vunidades * precio_uni);
               ELSE
                  -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                     vfondosalidas(regs2.ccodfon) :=
                        vfondosalidas(regs2.ccodfon)
                        +((vunidades -(v_unidades_rend * v_ppenali)) * precio_uni);
                     vfondoentrada(regs2.ccodfon) :=
                        vfondoentrada(regs2.ccodfon)
                        +((v_unidades_rend * v_ppenali) * precio_uni);
                  ELSE
                     vfondosalidas(regs2.ccodfon) :=
                        vfondosalidas(regs2.ccodfon)
                        +((vunidades -(vunidades * v_ppenali)) * precio_uni);
                     vfondoentrada(regs2.ccodfon) :=
                            vfondoentrada(regs2.ccodfon)
                            +((vunidades * v_ppenali) * precio_uni);
                  END IF;
               END IF;
            END IF;

            UTL_FILE.put_line(v_fichero, v_cadena);
         END LOOP;
      --END IF;
      END LOOP;

      -- Bug 20668 - RSC - 09/12/2012 - CRE - Errors ordres de compra i venda.
      FOR regsini IN cur_siniestros_dia_anul_rech LOOP
         ventra := 1;
         -- Colocamos el contrato
         vcontratob := regsini.sseguro;

         IF vcontratob = vcontratoa THEN
            vcontrato := NULL;
         ELSE
            SELECT npoliza, ncertif
              INTO vnpoliza, vncertif
              FROM seguros
             WHERE sseguro = regsini.sseguro;

            vcontrato := f_formatopol(vnpoliza, vncertif, 1);
         END IF;

         -- Bug 20309 - RSC - 29/11/2011 - LCOL_T004-Parametrización Fondos
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = regsini.sseguro;

         -- Fin Bug 20309
         FOR regs2 IN cur_segdisin2(regsini.sseguro) LOOP
            -- Bug 14160 - RSC - 16/04/2010: CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
            vcontansin := 0;

            -- Bug 15707 - APD - 14/03/2011 - Tratar el ccausin = 8 como si fuera un rescate parcial
            IF regsini.ccausin IN(5, 8) THEN
               -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               IF NVL(pac_parametros.f_parempresa_n(regsini.cempres, 'MODULO_SINI'), 0) = 0 THEN
                  SELECT COUNT(*)
                    INTO vcontansin
                    FROM valorasini
                   WHERE nsinies = regsini.nsinies;
               ELSE
                  SELECT COUNT(*)
                    INTO vcontansin
                    FROM sin_tramita_reserva
                   WHERE nsinies = regsini.nsinies
                     AND ctipres = 1   -- jlb - 18423#c105054
                     AND nmovres = (SELECT MAX(v1.nmovres)
                                      FROM sin_tramita_reserva v1
                                     WHERE v1.nsinies = sin_tramita_reserva.nsinies
                                       AND v1.ctipres = sin_tramita_reserva.ctipres);
               END IF;
            END IF;

            -- Fin Bug 14160
            IF vcontansin <> 0 THEN
               -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               IF NVL(pac_parametros.f_parempresa_n(regsini.cempres, 'MODULO_SINI'), 0) = 0 THEN
                  SELECT ivalora, fvalora, icaprisc, NVL(ipenali, 0)
                    INTO vivalora, vfvalora, v_icaprisc, v_ipenali
                    FROM valorasini
                   WHERE nsinies = regsini.nsinies;
               ELSE
                  SELECT ireserva, fmovres, icaprie, NVL(ipenali, 0)
                    INTO vivalora, vfvalora, v_icaprisc, v_ipenali
                    FROM sin_tramita_reserva
                   WHERE nsinies = regsini.nsinies
                     AND ctipres = 1   -- jlb - 18423#c105054
                     AND nmovres = (SELECT MAX(v1.nmovres)
                                      FROM sin_tramita_reserva v1
                                     WHERE v1.nsinies = sin_tramita_reserva.nsinies
                                       AND v1.ctipres = sin_tramita_reserva.ctipres);
               END IF;

               --PRECIO UNIDAD
               BEGIN
                  SELECT NVL(iuniact, 0), fvalor
                    INTO v_vliq_resc, v_vliq_date
                    FROM tabvalces
                   WHERE ccesta = regs2.ccesta
                     AND TRUNC(fvalor) = TRUNC(vfvalora);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT NVL(iuniact, 0), fvalor
                       INTO v_vliq_resc, v_vliq_date
                       FROM tabvalces
                      WHERE ccesta = regs2.ccesta
                        AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                               FROM tabvalces
                                              WHERE ccesta = regs2.ccesta
                                                AND TRUNC(fvalor) <= TRUNC(vfvalora));
               END;

               BEGIN
                  SELECT tfonabv
                    INTO v_tfonabv
                    FROM fondos
                   WHERE ccodfon = regs2.ccodfon;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_tfonabv := NULL;
               END;

               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  IF v_tfonabv IS NOT NULL THEN
                     v_cadena := vcontrato || ';' || pffecha || ';' || regsini.tmotsin || ';'
                                 || regs2.ccodfon || ' - ' || v_tfonabv || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100)) || ';'
                                 || ((v_icaprisc *(regs2.pdistrec / 100))) / v_vliq_resc
                                 || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100));
                  ELSE
                     v_cadena := vcontrato || ';' || pffecha || ';' || regsini.tmotsin || ';'
                                 || regs2.ccodfon || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100)) || ';'
                                 || ((v_icaprisc *(regs2.pdistrec / 100))) / v_vliq_resc
                                 || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100));
                  END IF;
               ELSE
                  IF v_tfonabv IS NOT NULL THEN
                     v_cadena := vcontrato || ' - ' || regsini.nsinies || ';' || pffecha
                                 || ';' || regsini.tmotsin || ';' || regs2.ccodfon || ' - '
                                 || v_tfonabv || ';'
                                 ||((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100)) || ';'
                                 || (((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100)))
                                    / v_vliq_resc
                                 || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 ||(v_icaprisc *(regs2.pdistrec / 100));
                     UTL_FILE.put_line(v_fichero, v_cadena);

                     IF NVL(v_ipenali, 0) <> 0 THEN
                        v_cadena := '' || ';' || '' || ';'
                                    || f_axis_literales(109713, pcidioma) || ';'
                                    || regs2.ccodfon || ' - ' || v_tfonabv || ';'
                                    ||(v_ipenali *(regs2.pdistrec / 100)) || ';'
                                    || ((v_ipenali *(regs2.pdistrec / 100))) / v_vliq_resc
                                    || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                    || ';' || regs2.pdistrec || ';'
                                    ||(v_ipenali *(regs2.pdistrec / 100));
                     END IF;
                  ELSE
                     v_cadena := vcontrato || ' - ' || regsini.nsinies || ';' || pffecha
                                 || ';' || regsini.tmotsin || ';' || regs2.ccodfon || ';'
                                 ||((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100)) || ';'
                                 || (((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100)))
                                    / v_vliq_resc
                                 || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 ||((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100));
                     UTL_FILE.put_line(v_fichero, v_cadena);

                     IF NVL(v_ipenali, 0) <> 0 THEN
                        v_cadena := '' || ';' || '' || ';'
                                    || f_axis_literales(109713, pcidioma) || ';'
                                    || regs2.ccodfon || ';'
                                    ||(v_ipenali *(regs2.pdistrec / 100)) || ';'
                                    || ((v_ipenali *(regs2.pdistrec / 100))) / v_vliq_resc
                                    || ';' || v_vliq_resc || ';' || '(' || v_vliq_date || ')'
                                    || ';' || regs2.pdistrec || ';'
                                    ||(v_ipenali *(regs2.pdistrec / 100));
                     END IF;
                  END IF;
               END IF;

               vcontrato := NULL;

               -- Llenamos el Hash de conceptos para luego mostrarlo en el listado
               IF vhashconceptos.EXISTS(regsini.tmotsin) THEN
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                     vhashconceptos(regsini.tmotsin) :=
                          vhashconceptos(regsini.tmotsin)
                          +(v_icaprisc *(regs2.pdistrec / 100));
                  ELSE
                     vhashconceptos(regsini.tmotsin) :=
                        vhashconceptos(regsini.tmotsin)
                        +((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100));
                     vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                        vhashconceptos(f_axis_literales(109713, pcidioma))
                        +(v_ipenali *(regs2.pdistrec / 100));
                  END IF;
               ELSE
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                     vhashconceptos(regsini.tmotsin) :=(v_icaprisc *(regs2.pdistrec / 100));
                  ELSE
                     vhashconceptos(regsini.tmotsin) :=
                                             ((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100));
                     vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                                                            (v_ipenali *(regs2.pdistrec / 100));
                  END IF;
               END IF;

               SELECT COUNT(*)
                 INTO v_movrech
                 FROM sin_movsiniestro
                WHERE nsinies = regsini.nsinies
                  AND cestsin = 0
                  AND TRUNC(festsin) = TRUNC(pffecha)
                  AND nmovsin = regsini.nmovsin - 1;

               -- Actualizamos los valores de entradas / salidas
               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  vfondoentrada(regs2.ccodfon) :=
                             vfondoentrada(regs2.ccodfon)
                             +(v_icaprisc *(regs2.pdistrec / 100));

                  IF v_movrech > 0 THEN
                     vfondosalidas(regs2.ccodfon) :=
                             vfondosalidas(regs2.ccodfon)
                             +(v_icaprisc *(regs2.pdistrec / 100));
                  END IF;
               ELSE
                  vfondoentrada(regs2.ccodfon) :=
                     vfondoentrada(regs2.ccodfon)
                     +((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100));
                  vfondosalidas(regs2.ccodfon) :=
                              vfondosalidas(regs2.ccodfon)
                              +(v_ipenali *(regs2.pdistrec / 100));

                  IF v_movrech > 0 THEN
                     vfondosalidas(regs2.ccodfon) :=
                        vfondosalidas(regs2.ccodfon)
                        +((v_icaprisc - v_ipenali) *(regs2.pdistrec / 100));
                     vfondoentrada(regs2.ccodfon) :=
                              vfondoentrada(regs2.ccodfon)
                              +(v_ipenali *(regs2.pdistrec / 100));
                  END IF;
               END IF;
            ELSE
               -- Saldo de participaciones de la cesta en el seguro (provision de la cesta)
               SELECT NVL(SUM(nunidad), 0)
                 INTO vunidades
                 FROM ctaseguro
                WHERE sseguro = regsini.sseguro
                  AND cmovimi <> 0
                  AND cesta = regs2.ccesta
                  AND fvalmov <= pffecha
                  AND((cestado <> '9')
                      OR(cestado = '9'
                         AND imovimi <> 0
                         AND imovimi IS NOT NULL));

               BEGIN
                  SELECT NVL(iuniact, 0), fvalor
                    INTO precio_uni, v_vliq_date
                    FROM tabvalces
                   WHERE ccesta = regs2.ccesta
                     AND TRUNC(fvalor) = TRUNC(regsini.fsinies);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT NVL(iuniact, 0), fvalor
                       INTO precio_uni, v_vliq_date
                       FROM tabvalces
                      WHERE ccesta = regs2.ccesta
                        AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                               FROM tabvalces
                                              WHERE ccesta = regs2.ccesta
                                                AND TRUNC(fvalor) <= TRUNC(regsini.fsinies));
               END;

               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  v_cadena := vcontrato || ';' || pffecha || ';' || regsini.tmotsin || ';'
                              || regs2.ccodfon || ';' || vunidades * precio_uni || ';'
                              || (vunidades * precio_uni) / precio_uni || ';' || precio_uni
                              || ';' || '(' || v_vliq_date || ')' || ';' || regs2.pdistrec
                              || ';' || vunidades * precio_uni;
               ELSE
                  v_ppenali :=
                     NVL(calc_rescates.fporcenpenali(NULL, regsini.sseguro,
                                                     TO_NUMBER(TO_CHAR(regsini.fsinies,
                                                                       'YYYYMMDD')),
                                                     4),
                         0)
                     / 100;

                  -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                     v_rendiment :=
                        pac_operativa_finv.ffrendiment(NULL, regsini.sseguro,
                                                       TO_NUMBER(TO_CHAR(regsini.fsinies,
                                                                         'YYYYMMDD')));

                     IF precio_uni > 0 THEN
                        v_unidades_rend := v_rendiment / precio_uni;
                     END IF;

                     v_cadena := vcontrato || ' - ' || regsini.nsinies || ';' || pffecha || ';'
                                 || regsini.tmotsin || ';' || regs2.ccodfon || ';'
                                 || (vunidades -(v_unidades_rend * v_ppenali)) * precio_uni
                                 || ';'
                                 || ((vunidades -(v_unidades_rend * v_ppenali)) * precio_uni)
                                    / precio_uni
                                 || ';' || precio_uni || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 || (vunidades -(v_unidades_rend * v_ppenali)) * precio_uni;

                     IF (v_unidades_rend * v_ppenali) <> 0 THEN
                        UTL_FILE.put_line(v_fichero, v_cadena);
                        v_cadena := '' || ';' || '' || ';'
                                    || f_axis_literales(109713, pcidioma) || ';'
                                    || regs2.ccodfon || ';'
                                    || (v_unidades_rend * v_ppenali) * precio_uni || ';'
                                    || ((v_unidades_rend * v_ppenali) * precio_uni)
                                       / precio_uni || ';' || precio_uni || ';' || '('
                                    || v_vliq_date || ')' || ';' || regs2.pdistrec || ';'
                                    || (v_unidades_rend * v_ppenali) * precio_uni;
                     END IF;
                  ELSE
                     v_cadena := vcontrato || ' - ' || regsini.nsinies || ';' || pffecha
                                 || ';' || regsini.tmotsin || ';' || regs2.ccodfon || ';'
                                 || (vunidades -(vunidades * v_ppenali)) * precio_uni || ';'
                                 || ((vunidades -(vunidades * v_ppenali)) * precio_uni)
                                    / precio_uni
                                 || ';' || precio_uni || ';' || '(' || v_vliq_date || ')'
                                 || ';' || regs2.pdistrec || ';'
                                 || (vunidades -(vunidades * v_ppenali)) * precio_uni;

                     IF (vunidades * v_ppenali) <> 0 THEN
                        UTL_FILE.put_line(v_fichero, v_cadena);
                        v_cadena := '' || ';' || '' || ';'
                                    || f_axis_literales(109713, pcidioma) || ';'
                                    || regs2.ccodfon || ';'
                                    || (vunidades * v_ppenali) * precio_uni || ';'
                                    || ((vunidades * v_ppenali) * precio_uni) / precio_uni
                                    || ';' || precio_uni || ';' || '(' || v_vliq_date || ')'
                                    || ';' || regs2.pdistrec || ';'
                                    || (vunidades * v_ppenali) * precio_uni;
                     END IF;
                  END IF;
               END IF;

               vcontrato := NULL;

               -- Llenamos el Hash de conceptos para luego mostrarlo en el listado
               IF vhashconceptos.EXISTS(regsini.tmotsin) THEN
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                     vhashconceptos(regsini.tmotsin) :=
                                      vhashconceptos(regsini.tmotsin)
                                      +(vunidades * precio_uni);
                  ELSE
                     IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                        vhashconceptos(regsini.tmotsin) :=
                           vhashconceptos(regsini.tmotsin)
                           +((vunidades -(v_unidades_rend * v_ppenali)) * precio_uni);
                        vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                           vhashconceptos(f_axis_literales(109713, pcidioma))
                           +((v_unidades_rend * v_ppenali) * precio_uni);
                     ELSE
                        vhashconceptos(regsini.tmotsin) :=
                           vhashconceptos(regsini.tmotsin)
                           +((vunidades -(vunidades * v_ppenali)) * precio_uni);
                        vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                           vhashconceptos(f_axis_literales(109713, pcidioma))
                           +((vunidades * v_ppenali) * precio_uni);
                     END IF;
                  END IF;
               ELSE
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                     vhashconceptos(regsini.tmotsin) := vunidades * precio_uni;
                  ELSE
                     IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                        vhashconceptos(regsini.tmotsin) :=
                                        (vunidades -(v_unidades_rend * v_ppenali)) * precio_uni;
                        vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                                                      (v_unidades_rend * v_ppenali)
                                                      * precio_uni;
                     ELSE
                        vhashconceptos(regsini.tmotsin) :=
                                              (vunidades -(vunidades * v_ppenali)) * precio_uni;
                        vhashconceptos(f_axis_literales(109713, pcidioma)) :=
                                                            (vunidades * v_ppenali)
                                                            * precio_uni;
                     END IF;
                  END IF;
               END IF;

               SELECT COUNT(*)
                 INTO v_movrech
                 FROM sin_movsiniestro
                WHERE nsinies = regsini.nsinies
                  AND cestsin = 0
                  AND TRUNC(festsin) = TRUNC(pffecha)
                  AND nmovsin = regsini.nmovsin - 1;

               -- Actualizamos los valores de entradas / salidas
               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  vfondoentrada(regs2.ccodfon) :=
                                         vfondoentrada(regs2.ccodfon)
                                         +(vunidades * precio_uni);

                  IF v_movrech > 0 THEN
                     vfondosalidas(regs2.ccodfon) :=
                                         vfondosalidas(regs2.ccodfon)
                                         +(vunidades * precio_uni);
                  END IF;
               ELSE
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                     vfondoentrada(regs2.ccodfon) :=
                        vfondoentrada(regs2.ccodfon)
                        +((vunidades -(v_unidades_rend * v_ppenali)) * precio_uni);
                     vfondosalidas(regs2.ccodfon) :=
                        vfondosalidas(regs2.ccodfon)
                        +((v_unidades_rend * v_ppenali) * precio_uni);

                     IF v_movrech > 0 THEN
                        vfondosalidas(regs2.ccodfon) :=
                           vfondosalidas(regs2.ccodfon)
                           +((vunidades -(v_unidades_rend * v_ppenali)) * precio_uni);
                        vfondoentrada(regs2.ccodfon) :=
                           vfondoentrada(regs2.ccodfon)
                           +((v_unidades_rend * v_ppenali) * precio_uni);
                     END IF;
                  ELSE
                     vfondoentrada(regs2.ccodfon) :=
                        vfondoentrada(regs2.ccodfon)
                        +((vunidades -(vunidades * v_ppenali)) * precio_uni);
                     vfondosalidas(regs2.ccodfon) :=
                            vfondosalidas(regs2.ccodfon)
                            +((vunidades * v_ppenali) * precio_uni);

                     IF v_movrech > 0 THEN
                        vfondosalidas(regs2.ccodfon) :=
                           vfondosalidas(regs2.ccodfon)
                           +((vunidades -(vunidades * v_ppenali)) * precio_uni);
                        vfondoentrada(regs2.ccodfon) :=
                            vfondoentrada(regs2.ccodfon)
                            +((vunidades * v_ppenali) * precio_uni);
                     END IF;
                  END IF;
               END IF;
            END IF;

            UTL_FILE.put_line(v_fichero, v_cadena);
         END LOOP;
      END LOOP;

      -- Fin Bug 20668
      IF ventra = 0 THEN
         v_cadena := ';' || ';' || f_axis_literales(180717, pcidioma);   -- No hay mas datos para este informe
         UTL_FILE.put_line(v_fichero, v_cadena);
      END IF;

      ventra := 0;
--------------------------------------------------------------------

      -- Sessión de entradas / salidas -----------------------------------
      UTL_FILE.put_line(v_fichero, NULL);
      UTL_FILE.put_line(v_fichero, NULL);
      fondo := vfondoentrada.FIRST;
      -- Titulo: Resumen por fondos teoricos
      v_cadena := UPPER(f_axis_literales(180727, pcidioma));
      UTL_FILE.put_line(v_fichero, v_cadena);
      v_cadena := ';' || ';' || ';' || UPPER(f_axis_literales(107059, pcidioma)) || ';' || ' '
                  || ';' || UPPER(f_axis_literales(109190, pcidioma)) || ';'
                  || UPPER(f_axis_literales(109191, pcidioma));
      UTL_FILE.put_line(v_fichero, v_cadena);

      -- Bug 17373 - 04/02/2011 - AMC
      SELECT finv_seq.NEXTVAL
        INTO vsproces
        FROM DUAL;

      -- Fi Bug 17373 - 04/02/2011 - AMC
      LOOP
         EXIT WHEN NOT vfondoentrada.EXISTS(fondo);
         ventra := 1;

         SELECT tfoncmp
           INTO vtfoncmp
           FROM fondos
          WHERE ccodfon = fondo;

         UTL_FILE.put_line(v_fichero,
                           ';' || ';' || ';' || fondo || ';' || vtfoncmp || ';'
                           || vfondoentrada(fondo) || ';' || vfondosalidas(fondo));

         -- Bug 17373 - 04/02/2011 - AMC
         IF vtfoncmp = '35' THEN
            vasset := 602415;
         ELSIF vtfoncmp = '45'
               OR vtfoncmp = '14' THEN
            vasset := 602416;
         ELSIF vtfoncmp = '55'
               OR vtfoncmp = '18' THEN
            vasset := 602417;
         ELSIF vtfoncmp = '62' THEN
            vasset := 624318;
         END IF;

         IF (vfondoentrada(fondo) > 0) THEN
            INSERT INTO resumfinv
                        (sproces, operacion, asset, codacc, cont,
                         cantidad, cempres, fechavalor)
                 VALUES (vsproces, 1, vasset, 1029, '1096176.102',
                         ROUND(vfondoentrada(fondo), 4), pcempresa, pffecha);
         END IF;

         IF (vfondosalidas(fondo) > 0) THEN
            INSERT INTO resumfinv
                        (sproces, operacion, asset, codacc, cont,
                         cantidad, cempres, fechavalor)
                 VALUES (vsproces, 4, vasset, 1029, '1096176.102',
                         ROUND(vfondosalidas(fondo), 4), pcempresa, pffecha);
         END IF;

         fondo := vfondoentrada.NEXT(fondo);
      END LOOP;

      psprocesxml := vsproces;

      -- Fi Bug 17373 - 04/02/2011 - AMC
      IF ventra = 0 THEN
         v_cadena := ';' || ';' || f_axis_literales(180717, pcidioma);   -- No hay mas datos para este informe
         UTL_FILE.put_line(v_fichero, v_cadena);
      END IF;

      ventra := 0;
--------------------------------------------------------------------

      -- Sessión agrupando por conceptos ---------------------------------
      UTL_FILE.put_line(v_fichero, NULL);
      UTL_FILE.put_line(v_fichero, NULL);
      concepto := vhashconceptos.FIRST;
      -- Titulo: Resumen por conceptos
      v_cadena := UPPER(f_axis_literales(180728, pcidioma));
      UTL_FILE.put_line(v_fichero, v_cadena);
      v_cadena := ';' || ';' || ';' || UPPER(f_axis_literales(100896, pcidioma)) || ';'
                  || UPPER(f_axis_literales(100563, pcidioma));
      UTL_FILE.put_line(v_fichero, v_cadena);

      LOOP
         EXIT WHEN NOT vhashconceptos.EXISTS(concepto);
         ventra := 1;
         UTL_FILE.put_line(v_fichero,
                           ';' || ';' || ';' || concepto || ';' || vhashconceptos(concepto));
         concepto := vhashconceptos.NEXT(concepto);
      END LOOP;

      IF ventra = 0 THEN
         v_cadena := ';' || ';' || f_axis_literales(180717, pcidioma);   -- No hay mas datos para este informe
         UTL_FILE.put_line(v_fichero, v_cadena);
      END IF;

      UTL_FILE.fclose(v_fichero);
      RETURN v_nombre_fichero;
   EXCEPTION
      WHEN ex_error THEN
         IF UTL_FILE.is_open(v_fichero) THEN
            UTL_FILE.fclose(v_fichero);
         END IF;

         perror := -1;
         v_nombre_fichero(1).nombre := NULL;
         RETURN v_nombre_fichero;
   END f_sictr024finv;
END pac_excel;

/

  GRANT EXECUTE ON "AXIS"."PAC_EXCEL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_EXCEL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_EXCEL" TO "PROGRAMADORESCSI";
