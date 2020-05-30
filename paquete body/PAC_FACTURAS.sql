--------------------------------------------------------
--  DDL for Package Body PAC_FACTURAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FACTURAS" IS
   /******************************************************************************
      NOMBRE:       PAC_FACTURAS
      PROPÓSITO:    Funciones de la capa lógica para realizar acciones sobre la tabla FACTURAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/05/2012   APD             1. Creación del package. 0022321: MDP_F001-MDP_A001-Facturas
      2.0        04/09/2012   APD             2. 0023595: MDP_F001- Modificaciones modulo de facturas
   ******************************************************************************/

   /**************************************************************************************/
   PROCEDURE init_vector /*(descartados IN OUT vector )*/ IS
   BEGIN
      v_descartados.DELETE;

      FOR i IN 1 .. 999 LOOP
         pac_facturas.v_descartados(i) := 'N';
      END LOOP;
   END;

   FUNCTION leer_elm(i NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN v_descartados(i);
   END;

   PROCEDURE activar_elm( /*descartados IN OUT vector,*/i NUMBER) IS
   BEGIN
      pac_facturas.v_descartados(i) := 'S';
   END;

   PROCEDURE desactivar_elm( /*descartados IN OUT vector,*/i NUMBER) IS
   BEGIN
      pac_facturas.v_descartados(i) := 'N';
   END;

   FUNCTION abrir(filename IN VARCHAR2, modo IN VARCHAR2)
      RETURN UTL_FILE.file_type IS
      directorio     VARCHAR2(200) := SUBSTR(filename, 1, INSTR(filename, '\', -1, 1) - 1);
      nomfichero     VARCHAR2(200) := SUBSTR(filename, INSTR(filename, '\', -1, 1) + 1);
      directorio_x   VARCHAR2(200) := SUBSTR(filename, 1, INSTR(filename, '/', -1, 1) - 1);
      win_unix       NUMBER := INSTR(filename, '/');   -- si es > 0 ==>UNIX
      fin            UTL_FILE.file_type;
   BEGIN
      IF win_unix > 0 THEN
         directorio := directorio_x;
         nomfichero := SUBSTR(filename, INSTR(filename, '/', -1, 1) + 1);
      ELSE
         IF directorio IS NULL THEN
            IF UPPER(os) = 'WINDOWS' THEN
               directorio := 'C:\Temp';
            ELSE
               directorio := '/tmp';
            END IF;
         END IF;
      END IF;

      fin := UTL_FILE.fopen(directorio, nomfichero, modo);
      RETURN fin;
   END abrir;

   PROCEDURE desplegar_fijo(linea IN VARCHAR2, l IN longitud, campos IN OUT t_campos) IS
      j              NUMBER(6, 0) := 0;
      n              NUMBER(6, 0) := 1;
      campito        VARCHAR2(250);
   BEGIN
      FOR i IN 1 .. l.COUNT LOOP
         --    dbms_output.put_line(n||' '||l(i));
         campito := SUBSTR(linea, n, l(i));
         --dbms_output.put_line(campito);
         n := n + l(i);
         j := j + 1;   -- Nuevo campo
         campos(j) := campito;
      --   dbms_output.put_line('nuevo campo');
      END LOOP;
   END desplegar_fijo;

   PROCEDURE desplegar(
      p_linea IN VARCHAR2,
      delimitador IN VARCHAR2 DEFAULT '|',
      campos IN OUT t_campos) IS
      j              NUMBER(6, 0) := 0;
      n              NUMBER(6, 0) := 0;
      campito        VARCHAR2(250);
      c              VARCHAR2(1);
   BEGIN
--         campos.DELETE;
      campito := NULL;

      FOR i IN 1 .. LENGTH(p_linea) LOOP
         c := SUBSTR(p_linea, i, 1);

         IF c = delimitador THEN
            j := j + 1;   -- Nuevo campo
            campos(j) := campito;
            campito := NULL;
         ELSE
            campito := campito || c;
         END IF;
      END LOOP;

      j := j + 1;   -- Último campo
      campos(j) := campito;
      campito := NULL;
/*
       IF j < min_separadores THEN
             FOR i IN j+1..min_separadores
          LOOP
                j := j + 1;
              campos(j) := NULL;
          END LOOP;
       END IF;
*/
   END desplegar;

/**************************************************************************************/

   /*************************************************************************
    Función que realiza la búsqueda de facturas a partir de los criterios de consulta entrados
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pnnumide     : Nif
    param in pnfact     : Nº factura
    param in pffact_ini     : fecha inicio emision factura
    param in pffact_fin     : fecha fin emision factura
    param in pcestado     : estado de la factura
    param in pctipfact     : tipo de la factura
    param in pcidioma     : codigo idioma
    param in pCAUTORIZADA : codigo autorizada
    param out pquery      : select a ejcutar
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_facturas(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pnnumide IN VARCHAR2,
      pnfact IN VARCHAR2,
      pffact_ini IN DATE,
      pffact_fin IN DATE,
      pcestado IN NUMBER,
      pctipfact IN NUMBER,
      pcidioma IN NUMBER,
      pcautorizada IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres = ' || pcempres || '; pcagente = ' || pcagente
            || '; pnnumide = ' || pnnumide || '; pnfact = ' || pnfact || '; pffact_ini = '
            || pffact_ini || '; pffact_fin = ' || pffact_fin || '; pcestado = ' || pcestado
            || '; pctipfact = ' || pctipfact || ' aut=' || pcautorizada;
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'pac_facturas.f_get_facturas';
      vwhere         VARCHAR2(2000);
      vsperson       per_personas.sperson%TYPE;
   BEGIN
      IF pcempres IS NOT NULL THEN
         vwhere := vwhere || ' and f.cempres = ' || pcempres;
      END IF;

      IF pcagente IS NOT NULL THEN
         vwhere := vwhere || ' and f.cagente = ' || pcagente;
      END IF;

      IF pnnumide IS NOT NULL THEN
         --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'),
                0) = 1 THEN
            vwhere :=
               vwhere
               || ' and f.sperson IN (SELECT p.sperson from per_personas p where UPPER(p.nnumide) = UPPER('''
               || pnnumide || '''))';
         ELSE
            vwhere :=
               vwhere
               || ' and f.sperson IN (SELECT p.sperson from per_personas p where p.nnumide = '''
               || pnnumide || ''')';
         END IF;
      END IF;

      -- nos aseguramos que el número de factura no tenga espacios por delante
      -- ni por detras y que si hay letras las sean en mayusculas para poder
      -- detectar duplicados
      IF pnfact IS NOT NULL THEN
         vwhere := vwhere || ' and f.nfact = UPPER(TRIM(''' || pnfact || '''))';
      END IF;

      IF pffact_ini IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(f.ffact) >= ' || CHR(39) || pffact_ini || CHR(39);
      END IF;

      IF pffact_fin IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(f.ffact) <= ' || CHR(39) || pffact_fin || CHR(39);
      END IF;

      IF pcestado IS NOT NULL THEN
         vwhere := vwhere || ' and f.cestado = ' || pcestado;
      END IF;

      IF pctipfact IS NOT NULL THEN
         vwhere := vwhere || ' and f.ctipfact = ' || pctipfact;
      END IF;

      IF pcautorizada IS NOT NULL THEN
         vwhere := vwhere || ' and f.CAUTORIZADA = ' || pcautorizada;
      END IF;

      pquery :=
         'SELECT f.nfact, f.cempres, f.ffact, f.ctipfact, ff_desvalorfijo(1082, ' || pcidioma
         || ',f.ctipfact) ttipfact,' || ' f.ctipiva, ff_destipiva(f.ctipiva, ' || pcidioma
         || ') ttipiva, f.cestado,' || ' ff_desvalorfijo(1083, ' || pcidioma
         || ', f.cestado) ttipfact, f.cagente,'
         || ' ff_desagente(f.cagente) tnombre, f.sperson, ff_buscanif(f.sperson) nnumide,'
         || ' SUM(d.iimporte) iimporte_total, SUM(d.iirpf) iirpf_total, SUM(d.iimpneto) iimpneto_total, SUM(d.iimpcta) iimpcta_total,'
         || ' f.ctipdoc, f.nfolio, f.ccarpeta, f.IDDOCGEDOX,' || ' ff_desvalorfijo(1140, '
         || pcidioma || ', f.ctipdoc) ttipdoc,'
         || ' f.nliqmen, f.CAUTORIZADA, decode(f.CAUTORIZADA,0,''No'',1,''Si'',null) tautorizada'
         || ' FROM facturas f, detfactura d'
         || ' WHERE f.nfact = d.nfact(+) and f.cagente = d.cagente(+) ';
      pquery :=
         pquery || vwhere
         || ' GROUP BY f.nfact, f.cempres, f.ffact, f.ctipfact, f.ctipiva, f.cestado, f.cagente, f.sperson,'
         || ' f.ctipdoc, f.nfolio, f.ccarpeta, f.IDDOCGEDOX, f.nliqmen, f.CAUTORIZADA'
         || ' order by f.nfact';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vparam, SQLCODE || CHR(10) || pquery);
         RETURN 1;
   END f_get_facturas;

   /*************************************************************************
    Función que devuelve la cabecera de una factura
    param in pnfact     : Nº factura
    param in pcidioma     : codigo idioma
    param out pquery      : select a ejcutar
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_factura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000) := 'parámetros - pnfact = ' || pnfact;
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'pac_facturas.f_get_factura';
      vwhere         VARCHAR2(2000);
      vsperson       per_personas.sperson%TYPE;
   BEGIN
      -- nos aseguramos que el número de factura no tenga espacios por delante
      -- ni por detras y que si hay letras las sean en mayusculas para poder
      -- detectar duplicados
      IF pnfact IS NOT NULL
         AND pcagente IS NOT NULL THEN
         vwhere := vwhere || ' and f.nfact = UPPER(TRIM(''' || pnfact
                   || ''')) and f.cagente = ' || pcagente;
      ELSE
         RETURN 103135;   -- Faltan parámetros
      END IF;

      pquery :=
         'SELECT f.nfact, f.cempres, f.ffact, f.ctipfact, ff_desvalorfijo(1082, ' || pcidioma
         || ', f.ctipfact) ttipfact,' || ' f.ctipiva, ff_destipiva(f.ctipiva, ' || pcidioma
         || ') ttipiva, f.cestado,' || ' ff_desvalorfijo(1083, ' || pcidioma
         || ', f.cestado) ttipfact, f.cagente,'
         || ' ff_desagente(f.cagente) tnombre, f.sperson, ff_buscanif(f.sperson) nnumide,'
         || ' SUM(d.iimporte) iimporte_total, SUM(d.iirpf) iirpf_total, SUM(d.iimpneto) iimpneto_total, SUM(d.iimpcta) iimpcta_total,'
         || ' f.ctipdoc, f.nfolio, f.ccarpeta, f.IDDOCGEDOX,' || ' ff_desvalorfijo(1140, '
         || pcidioma
         || ', f.ctipdoc) ttipdoc, f.nliqmen, f.CAUTORIZADA, decode(f.CAUTORIZADA,0,''No'',1,''Si'',null) tautorizada'
         || ' FROM facturas f, detfactura d'
         || ' WHERE f.nfact = d.nfact(+) and f.cagente = d.cagente(+) ';
      pquery :=
         pquery || vwhere
         || ' GROUP BY f.nfact, f.cempres, f.ffact, f.ctipfact, f.ctipiva, f.cestado, f.cagente, f.sperson,'
         || ' f.ctipdoc, f.nfolio, f.ccarpeta, f.IDDOCGEDOX, f.nliqmen, f.CAUTORIZADA';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vparam, SQLCODE || CHR(10) || pquery);
         RETURN 1000455;   -- Error no controlado.
   END f_get_factura;

   /*************************************************************************
    Función que devuelve el detalle de una factura
    param in pnfact     : Nº factura
    param out pquery      : select a ejcutar
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_detfactura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000) := 'parámetros - pnfact = ' || pnfact;
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'pac_facturas.f_get_detfactura';
      vwhere         VARCHAR2(2000);
      vsperson       per_personas.sperson%TYPE;
   BEGIN
      IF pnfact IS NOT NULL
         AND pcagente IS NOT NULL THEN
         vwhere := vwhere || ' and d.nfact = UPPER(TRIM(''' || pnfact
                   || ''')) and d.cagente = ' || pcagente;
      ELSE
         RETURN 103135;   -- Faltan parámetros
      END IF;

      pquery :=
         'SELECT d.norden, d.cconcepto, ff_desvalorfijo(1100, ' || pcidioma
         || ',
                                                 d.cconcepto) tconcepto, d.iimporte, d.iirpf, d.iimpneto, d.iimpcta
    FROM detfactura d
   WHERE 1 = 1 ';
      pquery := pquery || vwhere || ' ORDER BY d.norden';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vparam, SQLCODE || CHR(10) || pquery);
         RETURN 1000455;   -- Error no controlado.
   END f_get_detfactura;

   /*************************************************************************
    Función que graba en BBDD una factura
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pnnumide     : Nif
    param in pffact     : fecha emision factura
    param in pcestado     : estado de la factura
    param in pctipfact     : tipo de la factura
    param in pctipiva     : tipo de iva la factura
    param in out pnfact     : Nº factura
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_set_factura(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pffact IN DATE,
      pcestado IN NUMBER,
      pctipfact IN NUMBER,
      pctipiva IN NUMBER,
      pnfact IN VARCHAR2,
      onfact OUT VARCHAR2,
      pctipdoc IN NUMBER DEFAULT NULL,
      piddocgedox IN NUMBER DEFAULT NULL,
      pnliqmen IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'pac_facturas.f_set_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres = ' || pcempres || '; pcagente = ' || pcagente
            || '; pffact = ' || TO_CHAR(pffact, 'DD/MM/YYYY') || '; pcestado = ' || pcestado
            || '; pctipfact = ' || pctipfact || '; pctipiva = ' || pctipiva || '; pnfact = '
            || pnfact;
      vnfact         facturas.nfact%TYPE;
      salir          EXCEPTION;
      vnnumide       per_personas.nnumide%TYPE;
      vsperson       per_personas.sperson%TYPE;
      vnom           VARCHAR2(200);
      vresultat      NUMBER;
      vcont          NUMBER;
      vautorizada    facturas.cautorizada%TYPE;
   BEGIN
      -- De momento, el campo cagente es tambien obligatorio, pues se necesita para el cálculo
      -- del Nº de Factura
      IF pcempres IS NULL
         OR pffact IS NULL
         OR pcagente IS NULL
         OR pcestado IS NULL
         OR pctipfact IS NULL
         OR pctipiva IS NULL THEN
         vnumerr := 151397;   -- Falta informar algun campo obligatorio
         RAISE salir;
      END IF;

      -- se obtiene el sperson de agentes
      BEGIN
         SELECT sperson
           INTO vsperson
           FROM agentes
          WHERE cagente = pcagente;
      EXCEPTION
         WHEN OTHERS THEN
            vnumerr := 9000503;   -- Error al recuperar los datos del agente
      END;

      IF vnumerr <> 0 THEN
         RAISE salir;
      END IF;

      -- Nos aseguramos que el sperson esté informado
      IF vsperson IS NULL THEN
         vnumerr := 100534;   -- Persona inexistent
         RAISE salir;
      END IF;

      -- Bug 23595 - APD - 05/09/2012 - se añade el IF
      -- si pnfact IS NULL --> se calcula automaticamente el numero de factura
      -- si pnfact IS NOT NULL --> se inserta el numero de factura introducido por el usuario
      IF pnfact IS NULL THEN
         -- Se calcula automaticamente el numero de factura
         vnumerr := pac_facturas.f_get_nfact(pcempres, pcagente, pffact, vnfact);

         IF vnumerr <> 0 THEN
            RAISE salir;
         END IF;

         -- Nos aseguramos que el nfact esté informado
         IF vnfact IS NULL THEN
            vnumerr := 9903726;   -- Error al calcular el Número de Factura.
            RAISE salir;
         END IF;
      ELSE
         vnfact := pnfact;
      END IF;

      -- fin Bug 23595 - APD - 05/09/2012

      -- Bug 23595 - APD - 07/09/2012 - control de duplicados de facturas
      -- nos aseguramos que el número de factura no tenga espacios por delante
      -- ni por detras y que si hay letras las sean en mayusculas para poder
      -- detectar duplicados
      vnfact := UPPER(TRIM(vnfact));

      SELECT COUNT(1)
        INTO vcont
        FROM facturas
       WHERE cempres = pcempres
         AND UPPER(nfact) = vnfact
         AND cagente = pcagente;   --Añadimos agente

      IF vcont <> 0 THEN
         vnumerr := 9904179;   -- N.Factura existente.
         RAISE salir;
      END IF;

      -- si la factura es anterior a 2 meses, queda pendiente de autorizar.
      IF pffact < ADD_MONTHS(f_sysdate, -2) THEN
         vautorizada := 0;
      ELSE
         vautorizada := NULL;
      END IF;

      -- fin Bug 23595 - APD - 07/09/2012
      INSERT INTO facturas
                  (nfact, cempres, ffact, ctipfact, ctipiva, cestado, cagente,
                   sperson, ctipdoc, iddocgedox, nliqmen, cautorizada)
           VALUES (vnfact, pcempres, pffact, pctipfact, pctipiva, pcestado, pcagente,
                   vsperson, pctipdoc, piddocgedox, pnliqmen, vautorizada);

      vpasexec := 3;
      onfact := vnfact;
      vpasexec := 6;
      RETURN vnumerr;
   EXCEPTION
      WHEN salir THEN
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ': ' || SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_set_factura;

   /*************************************************************************
    Función que devuelve el número de la factura
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pffact     : fecha emision factura
    param in out pnfact     : Nº factura
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_nfact(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pffact IN DATE,
      pnfact IN OUT VARCHAR2)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'pac_facturas.f_get_nfact';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres = ' || pcempres || '; pcagente = ' || pcagente
            || '; pffact = ' || TO_CHAR(pffact, 'DD/MM/YYYY');
      vnfact         facturas.nfact%TYPE;
      vnfact_aux     facturas.nfact%TYPE;
      vnanyo         NUMBER(4);
      vcagente       NUMBER;
      vseq           NUMBER(4) := 1;
      vcont          NUMBER;
      salir          EXCEPTION;
   BEGIN
      IF pcempres IS NULL
         OR pffact IS NULL
         OR pcagente IS NULL THEN
         vnumerr := 151397;   -- Falta informar algun campo obligatorio
         RAISE salir;
      END IF;

      -- El Nº de Factura se calcula para cada agente por año
      -- Se busca si ya existe alguna factura para el agente para el año de emision de la factura
      vnanyo := TO_CHAR(pffact, 'yyyy');

      -- Factura compuesta por : codigo agente/año/secuencia
      -- el año será siempre de 4 posiciones
      -- secuencia será siempre de 4 posiciones
      -- bug 0028554 - 14/03/2014 - JMF
      BEGIN
         SELECT MAX(nfact), COUNT(1)
           INTO vnfact_aux, vcont
           FROM facturas
          WHERE cempres = pcempres
            AND SUBSTR(nfact, 1, LENGTH(nfact) - 8) = TO_CHAR(pcagente)
            AND TO_CHAR(ffact, 'yyyy') = vnanyo;

         IF vcont = 0 THEN
            vnfact := TO_CHAR(pcagente) || TO_CHAR(vnanyo) || LPAD(vseq, 4, 0);
         ELSE
            vseq := SUBSTR(vnfact_aux, LENGTH(vnfact_aux) - 3) + 1;
            vnfact := SUBSTR(vnfact_aux, 1, LENGTH(vnfact_aux) - 4) || LPAD(vseq, 4, 0);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            vnumerr := 9903726;   -- Error al calcular el Número de Factura.
            RAISE salir;
      END;

      pnfact := vnfact;
      RETURN vnumerr;
   EXCEPTION
      WHEN salir THEN
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ': ' || SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_get_nfact;

   /*************************************************************************
    Función que emite una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_valida_emitir_factura(pcempres IN NUMBER, pnfact IN VARCHAR2, pcagente IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'pac_facturas.f_valida_emitir_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                                   := 'e=' || pcempres || ' a=' || pcagente || ' f=' || pnfact;
      vcestado       NUMBER;
      salir          EXCEPTION;
      v_ffact        VARCHAR2(8);
      n_aux          NUMBER;
      v_liquido      agentes.cliquido%TYPE;
      v_nliqmen      facturas.nliqmen%TYPE;
      v_totfacafe    NUMBER;
      v_totfacexe    NUMBER;
      v_c11af        NUMBER;
      v_c11ex        NUMBER;
   BEGIN
      vpasexec := 100;

      IF pcempres IS NULL
         OR pnfact IS NULL
         OR pcagente IS NULL THEN
         vnumerr := 151397;   -- Falta informar algun campo obligatorio
         RAISE salir;
      END IF;

      vpasexec := 110;

      SELECT MAX(TO_CHAR(ffact, 'yyyymm')), MAX(nliqmen)
        INTO v_ffact, v_nliqmen
        FROM facturas
       WHERE nfact = pnfact
         AND cagente = pcagente
         AND cestado = 0;

      -- Buscar facturas del agente en el mes de la factura actual
      -- Si existe una factura pendiente de autorizar, no emitimos
      vpasexec := 120;

      SELECT COUNT(1)
        INTO n_aux
        FROM facturas
       WHERE cagente = pcagente
         AND TO_CHAR(ffact, 'yyyymm') = v_ffact
         AND cempres = pcempres
         AND cautorizada = 0;

      IF n_aux > 0 THEN
         -- Para el mes de la factura actual, el agente tiene una factura pendiente de autorizar.
         vnumerr := 9906536;
         RAISE salir;
      END IF;

      vpasexec := 130;

      SELECT MAX(cliquido)
        INTO v_liquido
        FROM agentes
       WHERE cagente = pcagente;

      IF v_liquido = 1 THEN
         -- autoliquidacion
         -- permite importes inferiores o notas de credito si sobrepasa

         -- Restar notas de credito
         vpasexec := 140;

         SELECT SUM(DECODE(a.ctipdoc, 1, b.iimporte, 2, b.iimporte, 5,(-1) * b.iimporte, 0)),
                SUM(DECODE(a.ctipdoc, 3, b.iimporte, 4, b.iimporte, 0))
           INTO v_totfacafe,
                v_totfacexe
           FROM facturas a, detfactura b
          WHERE a.cagente = pcagente
            AND a.cempres = pcempres
            AND a.cestado = 0
            AND b.nfact = a.nfact
            AND b.cagente = a.cagente;

         vpasexec := 150;

         SELECT SUM(a.iimport)
           INTO v_c11af
           FROM ctactes a
          WHERE a.cagente = pcagente
            AND a.cempres = pcempres
            AND a.cestado = 0
            AND a.cconcta = 10;

         -- En ctactes no lo tenemos desglosado, validamos el total
         vpasexec := 160;

         IF v_c11af -(v_totfacafe + v_totfacexe) < 0 THEN
            -- Importe factura supera importe autoliquidado
            vnumerr := 9906555;
            RAISE salir;
         END IF;
      ELSE
         -- Validar contra la liquidacion realizada, el importe debe ser igual
         vpasexec := 170;

         SELECT SUM(DECODE(a.ctipdoc, 1, b.iimporte, 2, b.iimporte, 0)),
                SUM(DECODE(a.ctipdoc, 3, b.iimporte, 4, b.iimporte, 0))
           INTO v_totfacafe,
                v_totfacexe
           FROM facturas a, detfactura b
          WHERE a.cagente = pcagente
            AND a.cempres = pcempres
            AND TO_CHAR(a.ffact, 'yyyymm') = v_ffact
            AND a.cestado = 0
            AND b.nfact = a.nfact
            AND b.cagente = a.cagente;

         vpasexec := 180;

         SELECT SUM(NVL(c11af, 0)), SUM(NVL(c11ex, 0))
           INTO v_c11af, v_c11ex
           FROM liquidalindet
          WHERE nliqmen = v_nliqmen
            AND cagente = pcagente
            AND cempres = pcempres;

         -- afectas
         IF v_totfacafe <> NVL(v_c11af, 0) THEN
            -- Importe afecto diferente de liquidaciones
            vnumerr := 9906534;
            RAISE salir;
         END IF;

         -- exentas
         IF v_totfacexe <> NVL(v_c11ex, 0) THEN
            -- Importe exento diferente de liquidaciones
            vnumerr := 9906535;
            RAISE salir;
         END IF;
      END IF;

      vpasexec := 190;
      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ': ' || SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_valida_emitir_factura;

   /*************************************************************************
    Función que emite una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_emitir_factura(pcempres IN NUMBER, pnfact IN VARCHAR2, pcagente IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'pac_facturas.f_emitir_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pcempres = ' || pcempres || ' - pnfact = ' || pnfact;
      vcestado       NUMBER;
      v_ffact        VARCHAR2(10);
      salir          EXCEPTION;
   BEGIN
      vpasexec := 100;

      IF pcempres IS NULL
         OR pnfact IS NULL
         OR pcagente IS NULL THEN
         vnumerr := 151397;   -- Falta informar algun campo obligatorio
         RAISE salir;
      END IF;

      -- Validar importes y autorizaciones
      vpasexec := 110;
      vnumerr := f_valida_emitir_factura(pcempres, pnfact, pcagente);

      IF vnumerr <> 0 THEN
         RAISE salir;
      END IF;

      -- Buscamos la fecha
      vpasexec := 120;

      SELECT MAX(TO_CHAR(ffact, 'yyyymm'))
        INTO v_ffact
        FROM facturas
       WHERE nfact = pnfact
         AND cagente = pcagente
         AND cempres = pcempres
         AND cestado = 0;

      -- Se emiten todas las facturas pendientes del agente en la fecha
      vpasexec := 130;

      UPDATE facturas
         SET cestado = 1
       WHERE TO_CHAR(ffact, 'yyyymm') = v_ffact
         AND cestado = 0
         AND cempres = pcempres
         AND cagente = pcagente;

      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ': ' || SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_emitir_factura;

   /*************************************************************************
    Función que anula una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_anular_factura(pcempres IN NUMBER, pnfact IN VARCHAR2, pcagente IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'pac_facturas.f_anular_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pcempres = ' || pcempres || ' - pnfact = ' || pnfact;
      vcestado       NUMBER;
      salir          EXCEPTION;
   BEGIN
      vpasexec := 100;

      IF pcempres IS NULL
         OR pnfact IS NULL THEN
         vnumerr := 151397;   -- Falta informar algun campo obligatorio
         RAISE salir;
      END IF;

      -- Sólo se puede anular una factura si está pendiente
      vpasexec := 110;

      SELECT cestado
        INTO vcestado
        FROM facturas
       WHERE nfact = pnfact
         AND cempres = pcempres
         AND cagente = pcagente;

      -- detvalores 1083
      IF vcestado = 0 THEN
         vpasexec := 120;

         UPDATE facturas
            SET cestado = 2
          WHERE nfact = pnfact
            AND cempres = pcempres
            AND cagente = pcagente;
      ELSE
         vnumerr := 9903731;   -- No se puede anular la factura.
         RAISE salir;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN salir THEN
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ': ' || SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_anular_factura;

   /*************************************************************************
    Función que genera query factura para una carpeta
    param in pCCARPETA   : Codigo carpeta
    param in pcempres   : Codigo empresa
    param in pcidioma   : Codigo idioma
    param out pquery    : texto con la query resultante
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_query_factura_carpeta(
      pccarpeta IN VARCHAR2,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT CLOB)
      RETURN NUMBER IS
      --
      vobj           VARCHAR2(200) := 'pac_facturas.f_query_factura_carpeta';
      vpar           VARCHAR2(1000)
                               := ' c=' || pccarpeta || ' e=' || pcempres || ' i=' || pcidioma;
      vlin           NUMBER;
      vwhere         CLOB;
   BEGIN
      vlin := 1000;
      vwhere := ' where cempres=' || pcempres;

      IF pccarpeta IS NOT NULL THEN
         vlin := 1005;
         vwhere := vwhere || ' and CCARPETA = ' || CHR(39) || pccarpeta || CHR(39);
      END IF;

      vlin := 1200;
      pquery := 'select ff_desvalorfijo(1140,' || pcidioma || ',ctipdoc) DESTIPDOC,'
                || ' min(sfactura) ninicio, max(sfactura) nfinal, count(1) total,'
                || ' sum(decode(nfolio,null,0,1)) asignadas' || ' from facturas';
      vlin := 1205;
      pquery := pquery || vwhere || ' group by ctipdoc order by 1,2';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLERRM);
         p_tab_error(f_sysdate, f_user, vobj, 999, vpar, SUBSTR(pquery, 1, 2000));
         RETURN 103212;
   END f_query_factura_carpeta;

   /*************************************************************************
    Función que asigna numero de folio a partir de un numero interno de factura, tambien trata folios erroneos
    param in pcempres   : Codigo empresa
    param in pobfacturacarpeta   : Objeto con toda la informacion
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_asigna_carpeta(pcempres IN NUMBER, pobfacturacarpeta IN ob_iax_asigfactura)
      RETURN NUMBER IS
      --
      vobj           VARCHAR2(200) := 'pac_facturas.f_asigna_carpeta';
      vpar           VARCHAR2(1000) := ' e=' || pcempres;
      vlin           NUMBER := 0;
      verr           NUMBER;
      v_car          facturas.ccarpeta%TYPE;
      v_fac          facturas.sfactura%TYPE;
      v_ini          facturas.nfolio%TYPE;
      v_fin          facturas.nfolio%TYPE;
      t_err          t_iax_info;
      v_folio        NUMBER;
      v_conta        NUMBER;

      CURSOR c1 IS
         SELECT   *
             FROM facturas
            WHERE ccarpeta = v_car
              AND cempres = pcempres
              AND nfolio IS NULL
              AND sfactura >= v_fac
              AND fcontab IS NULL
         ORDER BY sfactura;
   BEGIN
      vlin := 100;

      IF pobfacturacarpeta IS NULL THEN
         RETURN 9000505;
      ELSE
         vlin := 110;
         v_car := pobfacturacarpeta.ccaperta;
         v_fac := pobfacturacarpeta.sfactura;
         v_ini := pobfacturacarpeta.ninicio;
         v_fin := pobfacturacarpeta.nfinal;
         t_err := pobfacturacarpeta.lista_error;
         vpar := vpar || ' c=' || v_car || ' f=' || v_fac || ' i=' || v_ini || ' f=' || v_fin;
      END IF;

      v_folio := v_ini;
      vlin := 120;

      FOR f1 IN c1 LOOP
         -- asignamos folio y marcamos con estado generado
         vlin := 130;

         SELECT COUNT(1)
           INTO v_conta
           FROM facturas
          WHERE nfolio = v_folio;

         IF v_conta = 0 THEN
            -- asigno los folios que no existan
            vlin := 132;

            UPDATE facturas
               SET cestado = 1,
                   nfolio = v_folio
             WHERE nfact = f1.nfact
               AND cagente = f1.cagente;
         END IF;

         vlin := 140;
         v_folio := v_folio + 1;

         IF v_folio > v_fin THEN
            EXIT;
         END IF;
      END LOOP;

      vlin := 150;

      IF v_folio <= v_fin THEN
         -- error, faltan folios
         RETURN 1000151;
      END IF;

      vlin := 160;

      -- Tratar folios erroneos
      IF t_err IS NOT NULL THEN
         IF (t_err.COUNT) > 0 THEN
            FOR vinfo IN t_err.FIRST .. t_err.LAST LOOP
               vlin := 170;
               v_folio := t_err(vinfo).valor_columna;

               IF (LENGTH(t_err(vinfo).valor_columna) > 0) THEN
                  -- asignamos folio y marcamos con estado generado
                  vlin := 180;

                  UPDATE facturas
                     SET cestado = 0,
                         nfolio = NULL
                   WHERE cempres = pcempres
                     AND ccarpeta = v_car
                     AND fcontab IS NULL
                     AND nfolio = v_folio;
               END IF;
            END LOOP;
         END IF;
      END IF;

      vlin := 200;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLERRM);
         RETURN 1;
   END f_asigna_carpeta;

   /*************************************************************************
    Función emite facturas anticipadas ( a la emision recibo)
    param in p_fecini   : Fecha inicio
    param in p_fecfin   : Fecha final
    param in pcempres   : Codigo empresa
    param in p_sproces  : proceso
    param in pobfacturacarpeta   : Objeto con toda la informacion
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_emite_anticipadas(
      p_fecini DATE,
      p_fecfin DATE,
      p_empres NUMBER,
      p_proces NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      vobj           VARCHAR2(200) := 'PAC_FACTURAS.f_emite_anticipadas';
      vpar           VARCHAR2(1000)
           := ' i=' || p_fecini || ' f=' || p_fecfin || ' e=' || p_empres || ' p=' || p_proces;
      v_lin          NUMBER := 0;
      d_ini          DATE;
      d_fin          DATE;

      -- ANTICIPADA ( factura + nota credito )
      -- productos no masivos
      -- emision de recibos
      -- Contribuyentes
      -- que no exista en otra factura
      -- notas de credito para recibos extorno 9,13
      -- importes moneda a nivel de póliza (por defecto será la de la empresa)
      CURSOR c1 IS
         SELECT a.fanulac, a.cempres, 1 ctipfact, g.ctipiva, h.ptipiva, 0 cestado, c.cagente,
                d.sperson, 1 canticip,
                DECODE(c.ctiprec, 9, 5, 13, 5, DECODE(i.itotimp, 0, 3, 1)) ctipdoc,
                d.sperson ccontri, c.ctiprec, e.nrecibo, e.smovrec, c.femisio, i.itotalr
           FROM seguros a, recibos c, tomadores d, movrecibo e, per_regimenfiscal f,
                regfiscal_ivaretenc g, tipoiva h, vdetrecibos_monpol i, pregunpolseg p
          WHERE a.cempres = p_empres
            AND c.femisio BETWEEN d_ini AND d_fin
            AND f.sperson = d.sperson
            AND f.cregfiscal = 2
            AND g.cregfiscal = f.cregfiscal
            AND h.ctipiva = g.ctipiva
            AND c.sseguro = a.sseguro
            -- buscar anticipada
            AND p.sseguro = a.sseguro
            AND p.cpregun = 9131
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM pregunpolseg p2
                              WHERE p2.sseguro = a.sseguro
                                AND p2.cpregun = 9131)
            AND p.crespue = 1
            -- buscar anticipada
            AND d.sseguro = a.sseguro
            AND nordtom = (SELECT MIN(d1.nordtom)
                             FROM tomadores d1
                            WHERE d1.sseguro = a.sseguro)
            AND e.nrecibo = c.nrecibo
            AND e.smovrec = (SELECT MAX(e1.smovrec)
                               FROM movrecibo e1
                              WHERE e1.nrecibo = c.nrecibo)
            AND e.cestrec = 0
            AND i.nrecibo = c.nrecibo
            AND i.itotalr <> 0
            AND NOT EXISTS(SELECT 1
                             FROM detfactura x1, facturas x2
                            WHERE x1.nrecibo = c.nrecibo
                              AND x1.smovrec = e.smovrec
                              AND x2.nfact = x1.nfact
                              AND x2.cagente = x1.cagente
                              AND x2.canticip IN(0, 1));

      --
      n_err          NUMBER;
      d_hoy          DATE := f_sysdate;
      v_usu          usuarios.cusuari%TYPE := f_user;
      v_nfact        facturas.nfact%TYPE;
      v_sfactura     facturas.sfactura%TYPE := NULL;
      v_sproces      facturas.sproces%TYPE := NULL;
      v_clau         detfactura.smovrec%TYPE := NULL;
      v_iirpf        detfactura.iirpf%TYPE := NULL;
   BEGIN
      v_lin := 100;
      d_ini := TO_DATE(TO_CHAR(p_fecini, 'ddmmyyyy') || '000000', 'ddmmyyyyhh24miss');
      d_fin := TO_DATE(TO_CHAR(p_fecfin, 'ddmmyyyy') || '235959', 'ddmmyyyyhh24miss');

      IF p_proces IS NULL THEN
         v_lin := 110;
         n_err := f_procesini(v_usu, p_empres, 'FACTURAS_ANTICIPADAS',
                              f_axis_literales(9000442, f_usu_idioma), v_sproces);
      ELSE
         v_sproces := p_proces;
      END IF;

      v_lin := 120;

      SELECT NVL(MAX(sfactura), 0)
        INTO v_sfactura
        FROM facturas;

      v_lin := 130;

      FOR f1 IN c1 LOOP
         v_lin := 140;
         v_clau := f1.smovrec;
         n_err := pac_facturas.f_get_nfact(f1.cempres, f1.cagente, d_hoy, v_nfact);
         v_sfactura := v_sfactura + 1;
         v_lin := 150;

         INSERT INTO facturas
                     (nfact, cempres, ffact, ctipfact, ctipiva, cestado,
                      cagente, sperson, falta, cusualt, fmodifi, cusumod, sfactura,
                      canticip, ctipdoc, ccontri, sproces, nfolio,
                      ccarpeta, nliqmen)
              VALUES (v_nfact, f1.cempres, TRUNC(d_hoy), f1.ctipfact, f1.ctipiva, f1.cestado,
                      f1.cagente, f1.sperson, d_hoy, v_usu, NULL, NULL, v_sfactura,
                      f1.canticip, f1.ctipdoc, f1.ccontri, v_sproces, NULL,
                      f1.ctipdoc || '-' || TO_CHAR(d_hoy, 'yyyymmdd'), NULL);

         -- CCONCEPTO = 4 Otras retribuciones
         v_lin := 160;
         v_iirpf := (NVL(pac_agentes.f_get_reteniva(f1.cagente, d_hoy), 0) / 100) * f1.itotalr;
         v_lin := 162;

         INSERT INTO detfactura
                     (nfact, norden, cconcepto, iimporte, iirpf, iimpneto, iimpcta, falta,
                      cusualt, fmodifi, cusumod, cagente, nrecibo, smovrec)
              VALUES (v_nfact, 1, 4, f1.itotalr + v_iirpf, v_iirpf, f1.itotalr, 0, d_hoy,
                      v_usu, NULL, NULL, f1.cagente, f1.nrecibo, f1.smovrec);
      END LOOP;

      IF p_proces IS NULL THEN
         v_lin := 170;
         n_err := f_procesfin(v_sproces, 0);
      END IF;

      v_lin := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, v_lin, vpar || ' smovrec=' || v_clau,
                     SQLCODE || ' ' || SQLERRM);

         IF p_proces IS NULL THEN
            v_lin := 170;
            n_err := f_procesfin(v_sproces, 0);
         END IF;

         RETURN 1;
   END f_emite_anticipadas;

   /*************************************************************************
    Función emite facturas normales (al cobro recibo)
    param in p_fecini   : Fecha inicio
    param in p_fecfin   : Fecha final
    param in pcempres   : Codigo empresa
    param in p_sproces  : proceso
    param in pobfacturacarpeta   : Objeto con toda la informacion
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_emite_normal(
      p_fecini DATE,
      p_fecfin DATE,
      p_empres NUMBER,
      p_proces NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      vobj           VARCHAR2(200) := 'PAC_FACTURAS.f_emite_normal';
      vpar           VARCHAR2(1000)
           := ' i=' || p_fecini || ' f=' || p_fecfin || ' e=' || p_empres || ' p=' || p_proces;
      v_lin          NUMBER := 0;
      d_ini          DATE;
      d_fin          DATE;

      -- NORMAL
      -- productos no masivos
      -- pago de recibos
      -- Contribuyentes
      -- Agrupado
      -- que no exista en otra factura
      -- importes moneda a nivel de póliza (por defecto será la de la empresa)
      CURSOR c1 IS
         SELECT   d.sperson, a.cempres, 1 ctipfact, g.ctipiva, 0 cestado, c.cagente,
                  0 canticip, DECODE(i.itotimp, 0, 3, 1) ctipdoc, d.sperson ccontri,
                  c.ctiprec, e.nrecibo, e.smovrec, i.itotalr
             FROM seguros a, recibos c, tomadores d, movrecibo e, per_regimenfiscal f,
                  regfiscal_ivaretenc g, tipoiva h, vdetrecibos_monpol i, pregunpolseg p
            WHERE a.cempres = p_empres
              AND f.sperson = d.sperson
              AND f.cregfiscal = 2
              AND g.cregfiscal = f.cregfiscal
              AND h.ctipiva = g.ctipiva
              AND c.sseguro = a.sseguro
              -- buscar normal
              AND p.sseguro = a.sseguro
              AND p.cpregun = 9131
              AND p.nmovimi = (SELECT MAX(nmovimi)
                                 FROM pregunpolseg p2
                                WHERE p2.sseguro = a.sseguro
                                  AND p2.cpregun = 9131)
              AND p.crespue = 0
              -- buscar normal
              AND d.sseguro = a.sseguro
              AND nordtom = (SELECT MIN(d1.nordtom)
                               FROM tomadores d1
                              WHERE d1.sseguro = a.sseguro)
              AND e.nrecibo = c.nrecibo
              AND e.smovrec = (SELECT MAX(e1.smovrec)
                                 FROM movrecibo e1
                                WHERE e1.nrecibo = c.nrecibo
                                  AND e1.fmovdia BETWEEN d_ini AND d_fin)
              AND e.cestrec = 1
              AND c.ctiprec NOT IN(9, 13)
              AND i.nrecibo = c.nrecibo
              AND i.itotalr <> 0
              AND NOT EXISTS(SELECT 1
                               FROM detfactura x1, facturas x2
                              WHERE x1.nrecibo = c.nrecibo
                                AND x1.smovrec = e.smovrec
                                AND x2.nfact = x1.nfact
                                AND x2.cagente = x1.cagente
                                AND x2.canticip IN(0, 1))
         ORDER BY 1;

      --
      n_err          NUMBER;
      d_hoy          DATE := f_sysdate;
      v_usu          usuarios.cusuari%TYPE := f_user;
      v_nfact        facturas.nfact%TYPE;
      v_sfactura     facturas.sfactura%TYPE := NULL;
      v_sproces      facturas.sproces%TYPE := NULL;
      v_perold       facturas.sperson%TYPE := NULL;
      v_norden       detfactura.norden%TYPE := 0;
      v_clau         detfactura.smovrec%TYPE := NULL;
      v_iirpf        detfactura.iirpf%TYPE := NULL;
   BEGIN
      v_lin := 100;
      d_ini := TO_DATE(TO_CHAR(p_fecini, 'ddmmyyyy') || '000000', 'ddmmyyyyhh24miss');
      d_fin := TO_DATE(TO_CHAR(p_fecfin, 'ddmmyyyy') || '235959', 'ddmmyyyyhh24miss');

      IF p_proces IS NULL THEN
         v_lin := 110;
         n_err := f_procesini(v_usu, p_empres, 'FACTURAS_NORMALES',
                              f_axis_literales(9000442, f_usu_idioma), v_sproces);
      ELSE
         v_sproces := p_proces;
      END IF;

      v_lin := 120;

      SELECT NVL(MAX(sfactura), 0)
        INTO v_sfactura
        FROM facturas;

      v_lin := 130;

      FOR f1 IN c1 LOOP
         IF v_perold IS NULL
            OR v_perold <> f1.sperson THEN
            v_lin := 140;
            v_clau := f1.smovrec;
            n_err := pac_facturas.f_get_nfact(f1.cempres, f1.cagente, d_hoy, v_nfact);
            v_sfactura := v_sfactura + 1;
            v_lin := 150;

            INSERT INTO facturas
                        (nfact, cempres, ffact, ctipfact, ctipiva,
                         cestado, cagente, sperson, falta, cusualt, fmodifi, cusumod,
                         sfactura, canticip, ctipdoc, ccontri, sproces, nfolio,
                         ccarpeta, nliqmen)
                 VALUES (v_nfact, f1.cempres, TRUNC(d_hoy), f1.ctipfact, f1.ctipiva,
                         f1.cestado, f1.cagente, f1.sperson, d_hoy, v_usu, NULL, NULL,
                         v_sfactura, f1.canticip, f1.ctipdoc, f1.ccontri, v_sproces, NULL,
                         f1.ctipdoc || '-' || TO_CHAR(d_hoy, 'yyyymmdd'), NULL);

            v_perold := f1.sperson;
            v_norden := 0;
         END IF;

         v_lin := 160;

         IF f1.ctipdoc = 1 THEN
            -- como estan agrapadas, si existe una que sea normal, la factura sera afecta
            -- (para exenta todos tienen que ser sin iva)
            v_lin := 170;

            UPDATE facturas
               SET ctipdoc = 1,
                   ccarpeta = f1.ctipdoc || '-' || TO_CHAR(d_hoy, 'yyyymmdd')
             WHERE nfact = v_nfact
               AND cagente = f1.cagente
               AND ctipdoc <> 1;
         END IF;

         -- CCONCEPTO = 4 Otras retribuciones
         v_norden := v_norden + 1;
         v_lin := 180;
         v_iirpf := (NVL(pac_agentes.f_get_reteniva(f1.cagente, d_hoy), 0) / 100) * f1.itotalr;
         v_lin := 182;

         INSERT INTO detfactura
                     (nfact, norden, cconcepto, iimporte, iirpf, iimpneto, iimpcta,
                      falta, cusualt, fmodifi, cusumod, cagente, nrecibo, smovrec)
              VALUES (v_nfact, v_norden, 4, f1.itotalr + v_iirpf, v_iirpf, f1.itotalr, 0,
                      d_hoy, v_usu, NULL, NULL, f1.cagente, f1.nrecibo, f1.smovrec);
      END LOOP;

      IF p_proces IS NULL THEN
         v_lin := 190;
         n_err := f_procesfin(v_sproces, 0);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, v_lin, vpar || ' smovrec=' || v_clau,
                     SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_emite_normal;

   /*************************************************************************
    Función emite facturas normales (al cobro recibo)
    param in p_fecini   : Fecha inicio
    param in p_fecfin   : Fecha final
    param in pcempres   : Codigo empresa
    param in p_sproces  : proceso
    param in pobfacturacarpeta   : Objeto con toda la informacion
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_emite_notacredito(
      p_fecini DATE,
      p_fecfin DATE,
      p_empres NUMBER,
      p_proces NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      vobj           VARCHAR2(200) := 'PAC_FACTURAS.f_emite_notacredito';
      vpar           VARCHAR2(1000)
           := ' i=' || p_fecini || ' f=' || p_fecfin || ' e=' || p_empres || ' p=' || p_proces;
      v_lin          NUMBER := 0;
      d_ini          DATE;
      d_fin          DATE;

      -- NOTA CREDITO : NORMAL
      -- productos no masivos
      -- emision de recibos
      -- Contribuyentes
      -- que no exista en otra factura
      -- importes moneda a nivel de póliza (por defecto será la de la empresa)
      CURSOR c1 IS
         SELECT   a.fanulac, a.cempres, 1 ctipfact, g.ctipiva, h.ptipiva, 0 cestado,
                  c.cagente, d.sperson, 0 canticip, 5 ctipdoc, d.sperson ccontri, c.ctiprec,
                  e.nrecibo, e.smovrec, c.femisio, i.itotalr
             FROM seguros a, recibos c, tomadores d, movrecibo e, per_regimenfiscal f,
                  regfiscal_ivaretenc g, tipoiva h, vdetrecibos_monpol i, pregunpolseg p
            WHERE a.cempres = p_empres
              AND f.sperson = d.sperson
              AND f.cregfiscal = 2
              AND g.cregfiscal = f.cregfiscal
              AND h.ctipiva = g.ctipiva
              AND c.sseguro = a.sseguro
              -- buscar normal
              AND p.sseguro = a.sseguro
              AND p.cpregun = 9131
              AND p.nmovimi = (SELECT MAX(nmovimi)
                                 FROM pregunpolseg p2
                                WHERE p2.sseguro = a.sseguro
                                  AND p2.cpregun = 9131)
              AND p.crespue = 0
              -- buscar normal
              AND d.sseguro = a.sseguro
              AND nordtom = (SELECT MIN(d1.nordtom)
                               FROM tomadores d1
                              WHERE d1.sseguro = a.sseguro)
              AND e.nrecibo = c.nrecibo
              AND e.smovrec = (SELECT MAX(e1.smovrec)
                                 FROM movrecibo e1
                                WHERE e1.nrecibo = c.nrecibo
                                  AND e1.fmovdia BETWEEN d_ini AND d_fin)
              AND e.cestrec = 1
              AND c.ctiprec IN(9, 13)
              AND i.nrecibo = c.nrecibo
              AND i.itotalr <> 0
              AND NOT EXISTS(SELECT 1
                               FROM detfactura x1, facturas x2
                              WHERE x1.nrecibo = c.nrecibo
                                AND x1.smovrec = e.smovrec
                                AND x2.nfact = x1.nfact
                                AND x2.cagente = x1.cagente
                                AND x2.canticip IN(0, 1))
         ORDER BY 1;

      --
      n_err          NUMBER;
      d_hoy          DATE := f_sysdate;
      v_usu          usuarios.cusuari%TYPE := f_user;
      v_nfact        facturas.nfact%TYPE;
      v_sfactura     facturas.sfactura%TYPE := NULL;
      v_sproces      facturas.sproces%TYPE := NULL;
      v_clau         detfactura.smovrec%TYPE := NULL;
      v_iirpf        detfactura.iirpf%TYPE := NULL;
   BEGIN
      v_lin := 100;
      d_ini := TO_DATE(TO_CHAR(p_fecini, 'ddmmyyyy') || '000000', 'ddmmyyyyhh24miss');
      d_fin := TO_DATE(TO_CHAR(p_fecfin, 'ddmmyyyy') || '235959', 'ddmmyyyyhh24miss');

      IF p_proces IS NULL THEN
         v_lin := 110;
         n_err := f_procesini(v_usu, p_empres, 'FACTURAS_NORMALES',
                              f_axis_literales(9000442, f_usu_idioma), v_sproces);
      ELSE
         v_sproces := p_proces;
      END IF;

      v_lin := 115;

      SELECT NVL(MAX(sfactura), 0)
        INTO v_sfactura
        FROM facturas;

      v_lin := 120;

      FOR f1 IN c1 LOOP
         v_lin := 130;
         v_clau := f1.smovrec;
         n_err := pac_facturas.f_get_nfact(f1.cempres, f1.cagente, d_hoy, v_nfact);
         v_sfactura := v_sfactura + 1;
         v_lin := 140;

         INSERT INTO facturas
                     (nfact, cempres, ffact, ctipfact, ctipiva, cestado,
                      cagente, sperson, falta, cusualt, fmodifi, cusumod, sfactura,
                      canticip, ctipdoc, ccontri, sproces, nfolio,
                      ccarpeta, nliqmen)
              VALUES (v_nfact, f1.cempres, TRUNC(d_hoy), f1.ctipfact, f1.ctipiva, f1.cestado,
                      f1.cagente, f1.sperson, d_hoy, v_usu, NULL, NULL, v_sfactura,
                      f1.canticip, f1.ctipdoc, f1.ccontri, v_sproces, NULL,
                      f1.ctipdoc || '-' || TO_CHAR(d_hoy, 'yyyymmdd'), NULL);

         -- CCONCEPTO = 4 Otras retribuciones
         v_lin := 150;
         v_iirpf := (NVL(pac_agentes.f_get_reteniva(f1.cagente, d_hoy), 0) / 100) * f1.itotalr;

         INSERT INTO detfactura
                     (nfact, norden, cconcepto, iimporte, iirpf, iimpneto, iimpcta, falta,
                      cusualt, fmodifi, cusumod, cagente, nrecibo, smovrec)
              VALUES (v_nfact, 1, 4, f1.itotalr + v_iirpf, v_iirpf, f1.itotalr, 0, d_hoy,
                      v_usu, NULL, NULL, f1.cagente, f1.nrecibo, f1.smovrec);
      END LOOP;

      IF p_proces IS NULL THEN
         v_lin := 160;
         n_err := f_procesfin(v_sproces, 0);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, v_lin, vpar || ' smovrec=' || v_clau,
                     SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_emite_notacredito;

   /*************************************************************************
    Proceso emite facturas
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   PROCEDURE p_emite_facturas IS
      --
      vobj           VARCHAR2(200) := 'PAC_FACTURAS.p_emite_facturas';
      vpar           VARCHAR2(1000) := NULL;
      v_lin          NUMBER := 0;
      v_emp          empresas.cempres%TYPE;
      d_ini          DATE;
      d_fin          DATE;
      n_err          NUMBER;
      v_sproces      procesoscab.sproces%TYPE;
      n_toterr       NUMBER := 0;
   BEGIN
      v_emp := f_parinstalacion_n('EMPRESADEF');
      d_ini := TRUNC(f_sysdate);
      d_fin := TRUNC(f_sysdate);
      n_err := f_procesini(f_user, v_emp, 'FACTURAS', f_axis_literales(9000442, f_usu_idioma),
                           v_sproces);
      n_err := pac_facturas.f_emite_anticipadas(d_ini, d_fin, v_emp, v_sproces);
      n_toterr := n_toterr + n_err;
      n_err := pac_facturas.f_emite_normal(d_ini, d_fin, v_emp, v_sproces);
      n_toterr := n_toterr + n_err;
      n_err := pac_facturas.f_emite_notacredito(d_ini, d_fin, v_emp, v_sproces);
      n_toterr := n_toterr + n_err;
      n_err := f_procesfin(v_sproces, n_toterr);
   END p_emite_facturas;

   /*************************************************************************
    Función que autoriza una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_autoriza_factura(pcempres IN NUMBER, pnfact IN VARCHAR2, pcagente IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'pac_facturas.f_autoriza_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                                   := 'e=' || pcempres || ' f=' || pnfact || ' a=' || pcagente;
      vcautorizada   facturas.cautorizada%TYPE;
      vcestado       facturas.cestado%TYPE;
      salir          EXCEPTION;
      v_crealiza     cfg_accion.crealiza%TYPE;
   BEGIN
      vpasexec := 100;

      IF pcempres IS NULL
         OR pnfact IS NULL
         OR pcagente IS NULL THEN
         vnumerr := 151397;   -- Falta informar algun campo obligatorio
         RAISE salir;
      END IF;

      vpasexec := 110;

      SELECT cautorizada, cestado
        INTO vcautorizada, vcestado
        FROM facturas
       WHERE nfact = pnfact
         AND cempres = pcempres
         AND cagente = pcagente;

      IF NVL(vcestado, -1) <> 0 THEN
         -- La factura no se puede autorizar
         vnumerr := 9906561;
         RAISE salir;
      END IF;

      -- bug 0028554 - 14/03/2014 - JMF
      vpasexec := 120;
      vnumerr := pac_cfg.f_get_user_accion_permitida(f_user, 'AUTORIZA_FACTURA', 0, pcempres,
                                                     v_crealiza);
      vnumerr := 0;

      IF NVL(v_crealiza, 0) = 0 THEN
         -- El tramitador no tiene permisos para autorizar
         vnumerr := 9905761;
         RAISE salir;
      END IF;

      IF vcautorizada = 0 THEN
         vpasexec := 130;

         UPDATE facturas
            SET cautorizada = 1,
                cusuaut = f_user,
                fautorizada = f_sysdate
          WHERE nfact = pnfact
            AND cempres = pcempres
            AND cagente = pcagente;
      ELSE
         -- La factura no se puede autorizar
         vnumerr := 9906561;
         RAISE salir;
      END IF;

      vpasexec := 140;
      RETURN vnumerr;
   EXCEPTION
      WHEN salir THEN
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ': ' || SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_autoriza_factura;
END pac_facturas;

/

  GRANT EXECUTE ON "AXIS"."PAC_FACTURAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FACTURAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FACTURAS" TO "PROGRAMADORESCSI";
