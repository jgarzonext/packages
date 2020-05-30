--------------------------------------------------------
--  DDL for Function F_LIQUIDAPAGREAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_LIQUIDAPAGREAS" (
   psproces IN NUMBER,
   pcempresa IN NUMBER,
   pfinicio IN DATE,
   pffin IN DATE,
   pexperr IN OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
-- ***************************************
--  DECLARACION DE LAS VARIABLES GLOBALES
-- ***************************************
   vnombre        liqpagreaaux.tnombre%TYPE := ' ';
   vsitrie        riesgos.nasegur%TYPE := NULL;   --SITUACION RIESGO
   vfsin          siniestros.fsinies%TYPE := NULL;
   vfnotifi       siniestros.fnotifi%TYPE := NULL;
   vany           liqpagreaaux.nanyo%TYPE := 0;
   vramo          seguros.cramo%TYPE := 0;
   vtipram        NUMBER(2) := 0;   -- TIPO DE RAMO, 1 SCONAGR(CODICONTRATOS),
                                    -- 2 SCONTRA (CODICONTRATOS),
                                    -- 3 CRAMO(SEGUROS)
   vtippag        pagosini.ctippag%TYPE := NULL;   -- TIPO DE PAGO:1 PREV.PAGO,    2 PAGO,    3 ANUL.PAGO,
   --              4->6 PREV.RECOBRO, 5->7 RECOBRO, 6->8 ANUL.RECOBRO
   vpagcoa        pagosini.cpagcoa%TYPE := NULL;   -- PAGO de coaseg: 1 Totalidad,    2 parte local
   vfefepag       pagosini.fefepag%TYPE;
   vicesion       NUMBER := 0;   -- IMPORTE INICIAL
   vnsegcon       NUMBER := NULL;   -- 2º CONTRATO
   vnverpro       NUMBER := NULL;   -- VERSION 2º CONTRATO
   vplocpro       NUMBER(8, 5) := 0;   -- PORCENTAJE DEL PROPIO 2º CONTRATO
   vppropi        liqpagreaaux.ppropio%TYPE := 0;   -- PORCENTAJE DEL PROPIO
   vipropi        liqpagreaaux.ipropio%TYPE := 0;   -- IMPORTE PROPIO
   vsfacult       NUMBER(6) := 0;
   vptramo        cesionesrea.pcesion%TYPE := 0;   -- PCESION TRAMO
   vitramo        NUMBER := 0;   -- IMPORTE TRAMO
   vpcompa        cuadroces.pcesion%TYPE := 0;   -- PCESION COMPAÑIA
   vicompa        liqpagreaaux.icompan%TYPE := 0;   -- IMPORTE COMPAÑIA
   vploccoa       NUMBER(5, 2) := 0;   -- % COASEGURO( % PROPIO)
   error          NUMBER(7) := 0;

-- *************************
--  DECLARACION DE CURSORES
-- *************************
-- CURSOR PARA LOS PAGOS
   CURSOR c_liqpag(pcempresa IN NUMBER, pfinicio IN DATE, pffin IN DATE) IS
      SELECT   c.nsinies nsinies, c.scontra scontra, c.nversio nversio, c.sseguro sseguro,
               c.nriesgo nriesgo, s.npoliza npoliza, s.cobjase,
               NVL(NVL(s.fcaranu, s.fanulac), s.fvencim) fvencim, s.fefecto fefecto,
               s.ctipcoa, c.sidepag sidepag, c.cgarant cgarant
          FROM cesionesrea c, seguros s
         WHERE s.sseguro = c.sseguro
           AND s.cempres = pcempresa
           AND c.cgenera = 2
           AND c.ctramo > 0
           AND c.ctramo < 6
           AND c.fcontab BETWEEN pfinicio AND pffin
      GROUP BY c.nsinies, c.scontra, c.nversio, c.sseguro, c.nriesgo, s.npoliza, s.cobjase,
               s.fcaranu, s.fanulac, s.fvencim, s.fefecto, s.ctipcoa, c.sidepag, c.cgarant;

-- CURSOR PARA LOS TRAMOS
   CURSOR c_tramo(
      pscontra_c1 IN NUMBER,
      pnversio_c1 IN NUMBER,
      pnsinies_c1 IN NUMBER,
      psidepag_c1 IN NUMBER,
      pcgarant_c1 IN NUMBER) IS
      SELECT   c.ctramo ctramo, c.sfacult sfacult, c.pcesion pcesion
          FROM cesionesrea c
         WHERE (c.scontra = pscontra_c1
                OR c.scontra IS NULL)
           AND(c.nversio = pnversio_c1
               OR c.nversio IS NULL)
           AND c.nsinies = pnsinies_c1
           AND c.sidepag = psidepag_c1
           AND c.cgarant = pcgarant_c1
           AND c.ctramo > 0
           AND c.ctramo < 6
           AND c.fcontab BETWEEN pfinicio AND pffin
      ORDER BY c.ctramo;

-- CURSOR PARA LAS COMPAÑIAS
   CURSOR c_companias(
      pscontra_c1 IN NUMBER,
      pnversio_c1 IN NUMBER,
      pctramo_c2 IN NUMBER,
      psfacult_c2 IN NUMBER) IS
      SELECT ccompani, pcesion
        FROM cuadroces
       WHERE pctramo_c2 != 5
         AND scontra = pscontra_c1
         AND nversio = pnversio_c1
         AND ctramo = pctramo_c2
      UNION
      SELECT ccompani, pcesion
        FROM cuacesfac
       WHERE pctramo_c2 = 5
         AND sfacult = psfacult_c2;

-- CURSOR PARA LOS PAGOS CON 2º CONTRATO
   CURSOR c_liqpag2con(psproces IN NUMBER) IS
      SELECT *
        FROM liqpagreaaux
       WHERE sproces = psproces
         AND icompan IS NULL;

-- **************************************
--  DECLARACION DE LAS FUNCIONES LOCALES
-- **************************************
-- *** FUNCIONES DE BUSQUEDA DEL RAMO ***
-- **************************************
-- *** BUSCA EL RAMO EN LA TABLA SEGUROS ***
   FUNCTION buscar_ramo_seguros(psseguro NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT cramo
        INTO vramo
        FROM seguros
       WHERE sseguro = psseguro;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || SQLERRM || ' ' || TO_CHAR(SQLCODE);
         RETURN(103286);   -- EL SEGURO NO EXISTE
      WHEN OTHERS THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || SQLERRM || ' ' || TO_CHAR(SQLCODE);
         RETURN(101919);   -- ERROR AL LEER DE LA TABLA SEGUROS
   END buscar_ramo_seguros;

-- *** BUSCA EL RAMO EN LA TABLA CODICONTRATO ***
   FUNCTION buscar_ramo_codicontratos(pscontra IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(sconagr, scontra), DECODE(sconagr, NULL, 2, 1)
        INTO vramo, vtipram
        FROM codicontratos
       WHERE scontra = pscontra;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := pexperr || ' ' || pscontra || ' ' || SQLERRM || ' ' || TO_CHAR(SQLCODE);
         RETURN(104697);   -- CONTRATO NO ENCONTRADO EN CODICONTRATOS
      WHEN OTHERS THEN
         pexperr := pexperr || ' ' || pscontra || ' ' || SQLERRM || ' ' || TO_CHAR(SQLCODE);
         RETURN(104516);   -- ERROR EN CODICONTRATOS
   END buscar_ramo_codicontratos;

-- *** DECIDE DONDE DEBEREMOS IR A BUSCAR EL RAMO ***
   FUNCTION buscar_ramo(pscontra IN NUMBER, psseguro IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF pscontra IS NULL THEN
         pexperr := ' SEGURO:';
         vtipram := 3;
         error := buscar_ramo_seguros(psseguro, pexperr);
      ELSE
         pexperr := ' CONTRATO: ';
         error := buscar_ramo_codicontratos(pscontra, pexperr);
      END IF;

      RETURN(error);
   END buscar_ramo;

-- ****************************
-- *** BUSCAR ANYO CONTRATO ***
-- ****************************
-- ** RETORNA EL AÑO EN QUE SE INICIO EL CONTRATO ***
   FUNCTION buscar_ano_contratos(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT TO_CHAR(fconini, 'YYYY')
        INTO vany
        FROM contratos
       WHERE scontra = pscontra
         AND nversio = pnversio;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := pexperr || ' ' || pscontra || ' ' || pnversio || ' ' || SQLERRM || ' '
                    || TO_CHAR(SQLCODE);
         RETURN(104332);   -- CONTRATO NO ENCONTRADO EN LA TABLA CONTRATOS
      WHEN OTHERS THEN
         pexperr := pexperr || ' ' || pscontra || ' ' || pnversio || ' ' || SQLERRM || ' '
                    || TO_CHAR(SQLCODE);
         RETURN(104704);   -- ERROR AL LEER DE CONTRATOS
   END buscar_ano_contratos;

-- *** RETORNA EL AÑO EN QUE SE INICIO EL CUADRO FACULTATIVO ***
   FUNCTION buscar_ano_cuafacul(psfacult IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT TO_CHAR(finicuf, 'YYYY')
        INTO vany
        FROM cuafacul
       WHERE sfacult = psfacult;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := pexperr || ' ' || psfacult || ' ' || SQLERRM || ' ' || TO_CHAR(SQLCODE);
         RETURN(104487);   -- TODAVIA NO HAY CUADRO DE FACULTATIVO
      WHEN OTHERS THEN
         pexperr := pexperr || ' ' || psfacult || ' ' || SQLERRM || ' ' || TO_CHAR(SQLCODE);
         RETURN(107518);   -- ERROR AL LEER DE CUAFACUL
   END buscar_ano_cuafacul;

-- *** MIRA SI BUSCAMOS EL AÑO INICIO CONTRATO O CUADRO FACULTATIVO ***
   FUNCTION anyo_contrato(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      psfacult IN NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF pscontra IS NOT NULL THEN
         error := buscar_ano_contratos(pscontra, pnversio, pexperr);
      ELSE
         error := buscar_ano_cuafacul(psfacult, pexperr);
      END IF;

      RETURN(error);
   END anyo_contrato;

-- ****************************************
-- *** FUNCION BUSCA NOMBRE DEL TOMADOR ***
-- ****************************************
   FUNCTION nombre_tomador(psseguro IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
      vidioma        NUMBER;
      error          NUMBER;
   BEGIN
      error := f_tomador(psseguro, 1, vnombre, vidioma);   --FUNCIÓN DE BD'S

      IF error != 0 THEN
         pexperr := pexperr || ' ' || psseguro || SQLERRM || TO_CHAR(SQLCODE);
         RETURN(error);   --ERROR DEVUELTO POR LA FUNCION F_TOMADOR
      END IF;

      RETURN(0);
   END nombre_tomador;

-- ************************************
-- *** BUSCA LA SITUACION DE RIESGO ***
-- ************************************
-- *** RETORNA NOMBRE Y APELLIDO DE LA PERSONA DEL RIESGO ***
   FUNCTION datos_persona(pnriesgo IN NUMBER, psseguro IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      -- Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
      SELECT cagente, cempres
        INTO vagente_poliza, vcempres
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' '
             || SUBSTR(d.tapelli2, 0, 20)
        INTO vsitrie
        FROM per_personas p, per_detper d, riesgos r
       WHERE p.sperson = r.sperson
         AND r.nriesgo = pnriesgo
         AND r.sseguro = psseguro
         AND d.sperson = p.sperson
         AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);

      /*SELECT SUBSTR (p.tnombre || ' ' || p.tapelli, 1, 150)
        INTO vsitrie
        FROM PERSONAS p, RIESGOS r
       WHERE p.sperson = r.sperson
         AND r.nriesgo = pnriesgo
         AND r.sseguro = psseguro;*/

      -- FI Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || pnriesgo || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(103836);   --RIESGO NO ENCONTRADO EN LA TABLA RIESGOS
      WHEN OTHERS THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || pnriesgo || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(103509);   --ERROR AL LEER DE LA TABLA RIESGOS
   END datos_persona;

-- *** RETORNA EL DOMICILIO DEL RIESGO (OBJETO) ***
   FUNCTION domicilio(pnriesgo IN NUMBER, psseguro IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT SUBSTR(sr.tdomici || ' ' || pr.tprovin || ' ' || sr.cpostal || ' ' || po.tpoblac,
                    1, 150)
        INTO vsitrie
        FROM sitriesgo sr, provincias pr, poblaciones po
       WHERE sr.nriesgo = pnriesgo
         AND sr.sseguro = psseguro
         AND pr.cprovin = sr.cprovin
         AND po.cprovin(+) = sr.cprovin
         AND po.cpoblac(+) = sr.cpoblac;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || pnriesgo || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(102819);   --RIESGO NO ENCONTRADO
      WHEN OTHERS THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || pnriesgo || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(107517);   --ERROR AL LEER DE LA TABLA SITRIESGOS
   END domicilio;

-- *** RETORNA LA NATURALEZA DEL RIESGO ***
   FUNCTION indeterminado(pnriesgo IN NUMBER, psseguro IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT SUBSTR(tnatrie, 1, 150)
        INTO vsitrie
        FROM riesgos
       WHERE nriesgo = pnriesgo
         AND sseguro = psseguro;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || pnriesgo || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(102819);   --RIESGO NO ENCONTRADO
      WHEN OTHERS THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || pnriesgo || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(103509);   --ERROR AL LEER DE LA TABLA RIESGOS
   END indeterminado;

-- *** RETORNA EL NUMERO DE RIESGOS ***
   FUNCTION inominados(pnriesgo IN NUMBER, psseguro IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT nasegur
        INTO vsitrie
        FROM riesgos
       WHERE nriesgo = pnriesgo
         AND sseguro = psseguro;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || pnriesgo || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(102819);   --RIESGO NO ENCONTRADO
      WHEN OTHERS THEN
         pexperr := pexperr || ' ' || psseguro || ' ' || pnriesgo || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(103509);   --ERROR AL LEER DE LA TABLA RIESGOS
   END inominados;

-- *** ELIGE LA SITUACION DEL RIESGO SEGUN EL COBJASE ***
   FUNCTION situacion_riesgo(
      pnriesgo IN NUMBER,
      psseguro IN NUMBER,
      pcobjase IN NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF pcobjase = 1 THEN
         pexperr := 'PERSONA: ';
         error := datos_persona(pnriesgo, psseguro, pexperr);
      ELSIF pcobjase = 2 THEN
         pexperr := ' OBJETO: ';
         error := domicilio(pnriesgo, psseguro, pexperr);
      ELSIF pcobjase = 3 THEN
         pexperr := 'INDETERMINADO: ';
         error := indeterminado(pnriesgo, psseguro, pexperr);
      ELSIF pcobjase = 4 THEN
         pexperr := 'INOMINADO: ';
         error := inominados(pnriesgo, psseguro, pexperr);
      END IF;

      RETURN(error);
   END situacion_riesgo;

-- *************************************
-- *** FUNCION BUSCA FECHA SINIESTRO ***
-- *************************************
   FUNCTION fecha_siniestro(psseguro IN NUMBER, pnsinies IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT fsinies, fnotifi
        INTO vfsin, vfnotifi
        FROM siniestros
       WHERE sseguro = psseguro
         AND nsinies = pnsinies;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := psseguro || ' ' || pnsinies || SQLERRM || TO_CHAR(SQLCODE);
         RETURN(100513);   --EL SEGURO NO TIENE SINIESTROS
      WHEN OTHERS THEN
         pexperr := psseguro || ' ' || pnsinies || SQLERRM || TO_CHAR(SQLCODE);
         RETURN(105144);   --ERROR EN LA LECTURA DE SINIESTROS
   END fecha_siniestro;

-- ********************************
-- *** FUNCION BUSQUEDA PPROPIO ***
-- ********************************
   FUNCTION buscar_plocal(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      vplocal IN OUT NUMBER,
      vnsegcon IN OUT NUMBER,
      vnverpro IN OUT NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
      error          NUMBER;
   BEGIN
      error := pac_llibsin.busca_plocal(pscontra, pnversio, vplocal, vnsegcon, vnverpro);

      IF error <> 0 THEN
         pexperr := pscontra || ' ' || pnversio;
         RETURN(error);
      END IF;

      RETURN(0);
   END buscar_plocal;

-- *******************************
-- *** FUNCION BUSCA TIPO PAGO ***
-- *******************************
   FUNCTION tipo_pago(
      psseguro IN NUMBER,
      pnsinies IN NUMBER,
      psidepag IN NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
      error          NUMBER;
   BEGIN
      SELECT ctippag, cpagcoa, fefepag
        INTO vtippag, vpagcoa, vfefepag
        FROM pagosini
       WHERE sidepag = psidepag;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pexperr := psseguro || ' ' || pnsinies || ' ' || psidepag || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(104756);   --CLAVE INEXISTENTE EN PAGOSINI
      WHEN OTHERS THEN
         pexperr := psseguro || ' ' || pnsinies || ' ' || psidepag || SQLERRM
                    || TO_CHAR(SQLCODE);
         RETURN(100540);   --ERROR AL CALCULAR LOS PAGOS
   END tipo_pago;

-- ****************************************
-- *** FUNCION PROCESA SEGUNDO CONTRATO ***
-- ****************************************
   FUNCTION segundo_contrato(
      pscontra IN NUMBER,
      pplocpro IN OUT NUMBER,
      pnverpro IN OUT NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
      error          NUMBER;
   BEGIN
      error := pac_llibsin.busca_plocal_proteccio(pscontra, pnverpro, pplocpro);

      IF error <> 0 THEN
         pexperr := pscontra || ' ' || pnverpro;
         RETURN(error);
      END IF;

      RETURN(0);
   END segundo_contrato;

-- ************************************************
-- *** FUNCION DE INSERTAR EN LA TABLA TEMPORAL ***
-- ************************************************
   FUNCTION insertar_tabla_liqpagreaaux(
      pnsinies IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pptramo IN NUMBER,
      pitramo IN NUMBER,
      pnpoliza IN NUMBER,
      pfvencim IN DATE,
      pfefecto IN DATE,
      pccompani IN NUMBER,
      ppcompan IN NUMBER,
      pitotal IN NUMBER,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      psidepag IN NUMBER,
      pcgarant IN NUMBER,
      pnsegcon IN NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO liqpagreaaux
                  (nsinies, sidepag, cgarant, scontra, nversio, cramo, ctipram,
                   sseguro, npoliza, fvencim, tsitrie, fsin, tnombre, sproces, nsegcon,
                   itotal, ppropio, ipropio, ctramo, nanyo, ptramo, itramo, ccompani,
                   pcompan, icompan, fefecto, fnotifi, fefepag)
           VALUES (pnsinies, psidepag, pcgarant, pscontra, pnversio, vramo, vtipram,
                   psseguro, pnpoliza, pfvencim, vsitrie, vfsin, vnombre, psproces, pnsegcon,
                   pitotal, vppropi, vipropi, pctramo, vany, pptramo, pitramo, pccompani,
                   ppcompan, vicompa, pfefecto, vfnotifi, vfefepag);

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         pexperr := pnsinies || ' ' || pscontra || ' ' || pnversio;
         RETURN(107516);   -- ERROR AL INSERTAR EN LA TABLA LIQPAGREAAUX
   END insertar_tabla_liqpagreaaux;

-- ********************************************************
-- *** FUNCION GUARDA INFORMACION PARA SEGUNDO CONTRATO ***
-- ********************************************************
   FUNCTION inserta_segundo_contrato(
      pnsinies IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pnpoliza IN NUMBER,
      pfvencim IN DATE,
      pfefecto IN DATE,
      pitotal IN NUMBER,
      pppropi IN NUMBER,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      psidepag IN NUMBER,
      pcgarant IN NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO liqpagreaaux
                  (nsinies, sidepag, cgarant, scontra, nversio, sseguro, npoliza,
                   fvencim, tsitrie, fsin, tnombre, sproces, itotal, ppropio, fefecto,
                   fnotifi, fefepag)
           VALUES (pnsinies, psidepag, pcgarant, pscontra, pnversio, psseguro, pnpoliza,
                   pfvencim, vsitrie, vfsin, vnombre, psproces, pitotal, pppropi, pfefecto,
                   vfnotifi, vfefepag);

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         pexperr := pnsinies || ' ' || pscontra || ' ' || pnversio;
         RETURN(107516);   -- ERROR INSERTAR EN LA TABLA LIQPAGREAAUX
   END inserta_segundo_contrato;

-- ****************************************************************
-- *** FUNCION BORRA INFORMACION GUARDADA PARA SEGUNDO CONTRATO ***
-- ** EL REGISTRO QUE CONTIENE LA INF. TIENE LOS IMPORTES VACÍOS **
-- ****************************************************************
   FUNCTION borrar_segundo_contrato(
      psproces IN NUMBER,
      psidepag IN NUMBER,
      pcgarant IN NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      DELETE FROM liqpagreaaux
            WHERE sproces = psproces
              AND sidepag = psidepag
              AND cgarant = pcgarant
              AND icompan IS NULL;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         pexperr := psproces || ' ' || psidepag || ' ' || pcgarant;
         RETURN(107516);   -- ERROR INSERTAR EN LA TABLA LIQPAGREAAUX
   END borrar_segundo_contrato;

-- ************************************************************
-- *** FUNCION DE MODIFICA EL % E IMPORTE PROPIO SI TRAMO O ***
-- ************************************************************
   FUNCTION modificar_propios(
      pnsinies IN NUMBER,
      psidepag IN NUMBER,
      pcgarant IN NUMBER,
      psproces IN NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
      vporcen        cesionesrea.pcesion%TYPE;
      vimporte       NUMBER;
   BEGIN
      SELECT pcesion
        INTO vporcen
        FROM cesionesrea
       WHERE nsinies = pnsinies
         AND sidepag = psidepag
         AND cgarant = pcgarant
         AND ctramo = 0;

      UPDATE liqpagreaaux
         SET ppropio = vporcen,
             ipropio = (vporcen / 100) * itotal
       WHERE nsinies = pnsinies
         AND sidepag = psidepag
         AND cgarant = pcgarant
         AND sproces = psproces
         AND icompan IS NOT NULL;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         pexperr := pnsinies || ' ' || psidepag || ' ' || pcgarant;
         RETURN(107519);   -- ERROR AL MODIFICAR EN LA TABLA LIQPAGREAAUX
   END modificar_propios;

-- **************************************
-- *** GRABAR INCIDENCIAS DEL LISTADO ***
-- **************************************
   PROCEDURE grabar_incidencia(
      pnsinies IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pptramo IN NUMBER,
      pitramo IN NUMBER,
      pnpoliza IN NUMBER,
      pfvencim IN DATE,
      pccompani IN NUMBER,
      ppcompan IN NUMBER,
      pitotal IN NUMBER,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pexperr IN OUT VARCHAR2) IS
   BEGIN
      INSERT INTO liqpagreaaux_err
                  (nsinies, scontra, nversio, ctramo, ptramo, itramo, npoliza,
                   fvencim, cramo, ccompani, nanyo, tsitrie, fsin, pcompan, tnombre,
                   itotal, icompan, sproces, sseguro, incidenc)
           VALUES (pnsinies, pscontra, pnversio, pctramo, pptramo, pitramo, pnpoliza,
                   pfvencim, vramo, pccompani, vany, vsitrie, vfsin, ppcompan, vnombre,
                   pitotal, vicompa, psproces, psseguro, pexperr);
   EXCEPTION
      WHEN OTHERS THEN
         pexperr := 'ERROR GRABAR INCIDENCIA';
   END grabar_incidencia;
-- **************************************************************************
--                     CUERPO DE LA FUNCION PRINCIPAL
-- **************************************************************************
BEGIN
   FOR r_liqpag IN c_liqpag(pcempresa, pfinicio, pffin) LOOP
      vnombre := ' ';
      vsitrie := '';
      vfsin := NULL;
      vfnotifi := NULL;
      vany := 0;
      vramo := 0;
      vtipram := 0;
      vicesion := 0;
      vitramo := 0;
      vicompa := 0;
      error := buscar_ramo(r_liqpag.scontra, r_liqpag.sseguro, pexperr);

      IF error <> 0 THEN
         pexperr := error || ' : ' || pexperr;
         grabar_incidencia(r_liqpag.nsinies, r_liqpag.scontra, r_liqpag.nversio, 0, vptramo,
                           vitramo, r_liqpag.npoliza, r_liqpag.fvencim, 0, 0, 0, psproces,
                           r_liqpag.sseguro, pexperr);
         RETURN(error);
      END IF;

      error := nombre_tomador(r_liqpag.sseguro, pexperr);

      IF error <> 0 THEN
         pexperr := error || ' : ' || pexperr;
         grabar_incidencia(r_liqpag.nsinies, r_liqpag.scontra, r_liqpag.nversio, 0, vptramo,
                           vitramo, r_liqpag.npoliza, r_liqpag.fvencim, 0, 0, 0, psproces,
                           r_liqpag.sseguro, pexperr);
         RETURN(error);
      END IF;

      error := situacion_riesgo(r_liqpag.nriesgo, r_liqpag.sseguro, r_liqpag.cobjase, pexperr);

      IF error <> 0 THEN
         pexperr := error || ' : ' || pexperr;
         grabar_incidencia(r_liqpag.nsinies, r_liqpag.scontra, r_liqpag.nversio, 0, vptramo,
                           vitramo, r_liqpag.npoliza, r_liqpag.fvencim, 0, 0, 0, psproces,
                           r_liqpag.sseguro, pexperr);
         RETURN(error);
      END IF;

      error := fecha_siniestro(r_liqpag.sseguro, r_liqpag.nsinies, pexperr);

      IF error <> 0 THEN
         pexperr := error || ' : ' || pexperr;
         grabar_incidencia(r_liqpag.nsinies, r_liqpag.scontra, r_liqpag.nversio, 0, vptramo,
                           vitramo, r_liqpag.npoliza, r_liqpag.fvencim, 0, 0, 0, psproces,
                           r_liqpag.sseguro, pexperr);
         RETURN(error);
      END IF;

      error := tipo_pago(r_liqpag.sseguro, r_liqpag.nsinies, r_liqpag.sidepag, pexperr);

      IF error <> 0 THEN
         pexperr := error || ' : ' || pexperr;
         grabar_incidencia(r_liqpag.nsinies, r_liqpag.scontra, r_liqpag.nversio, 0, vptramo,
                           vitramo, r_liqpag.npoliza, r_liqpag.fvencim, 0, 0, 0, psproces,
                           r_liqpag.sseguro, pexperr);
         RETURN(error);
      END IF;

      vipropi := NULL;
      vppropi := NULL;
      vnsegcon := NULL;
      vplocpro := NULL;

      SELECT SUM(icesion) itotpaggar
        INTO vicesion
        FROM cesionesrea c
       WHERE c.cgenera = 2
         AND(scontra = r_liqpag.scontra
             OR scontra IS NULL)
         AND(nversio = r_liqpag.nversio
             OR nversio IS NULL)
         AND nsinies = r_liqpag.nsinies
         AND sidepag = r_liqpag.sidepag
         AND cgarant = r_liqpag.cgarant
         AND(fcontab >= pfinicio
             AND fcontab <= pffin
             OR fcontab IS NULL);

-- DBMS_OUTPUT.put_line (vicesion);
      FOR r_tramo IN c_tramo(r_liqpag.scontra, r_liqpag.nversio, r_liqpag.nsinies,
                             r_liqpag.sidepag, r_liqpag.cgarant) LOOP
         vany := 0;
         error := anyo_contrato(r_liqpag.scontra, r_liqpag.nversio, r_tramo.sfacult, pexperr);

         IF error <> 0 THEN
            pexperr := error || ' : ' || pexperr;
            grabar_incidencia(r_liqpag.nsinies, r_liqpag.scontra, r_liqpag.nversio,
                              r_tramo.ctramo, vptramo, vitramo, r_liqpag.npoliza,
                              r_liqpag.fvencim, 0, 0, vicesion, psproces, r_liqpag.sseguro,
                              pexperr);
            RETURN(error);
         END IF;

         vptramo := r_tramo.pcesion;

         IF r_tramo.ctramo = 1 THEN
            error := buscar_plocal(r_liqpag.scontra, r_liqpag.nversio, vppropi, vnsegcon,
                                   vnverpro, pexperr);

            IF error <> 0 THEN
               grabar_incidencia(r_liqpag.nsinies, r_liqpag.scontra, r_liqpag.nversio,
                                 r_tramo.ctramo, vptramo, vitramo, r_liqpag.npoliza,
                                 r_liqpag.fvencim, 0, 0, vicesion, psproces, r_liqpag.sseguro,
                                 pexperr);
               RETURN(error);
            END IF;

            vptramo := vptramo *(1 -(vppropi / 100));
            vppropi := (r_tramo.pcesion / 100) * vppropi;
            vipropi := (vppropi / 100) * vicesion;

            IF vnsegcon IS NOT NULL THEN
               error := segundo_contrato(vnsegcon, vplocpro, vnverpro, pexperr);

               IF vplocpro < 100 THEN
                  error := inserta_segundo_contrato(r_liqpag.nsinies, vnsegcon, vnverpro,
                                                    r_liqpag.npoliza, r_liqpag.fvencim,
                                                    r_liqpag.fefecto, vipropi, vplocpro,
                                                    psproces, r_liqpag.sseguro,
                                                    r_liqpag.sidepag, r_liqpag.cgarant,
                                                    pexperr);
               END IF;

               IF error <> 0 THEN
                  grabar_incidencia(r_liqpag.nsinies, r_liqpag.scontra, r_liqpag.nversio,
                                    r_tramo.ctramo, vptramo, vitramo, r_liqpag.npoliza,
                                    r_liqpag.fvencim, 0, 0, vicesion, psproces,
                                    r_liqpag.sseguro, pexperr);
                  RETURN(error);
               END IF;
            END IF;
         END IF;

         vitramo := (vptramo / 100) * vicesion;

         FOR r_companias IN c_companias(r_liqpag.scontra, r_liqpag.nversio, r_tramo.ctramo,
                                        r_tramo.sfacult) LOOP
            vpcompa := r_companias.pcesion;
            vicompa := (vpcompa / 100) *(r_tramo.pcesion / 100) * vicesion;
            error := insertar_tabla_liqpagreaaux(r_liqpag.nsinies, r_liqpag.scontra,
                                                 r_liqpag.nversio, r_tramo.ctramo, vptramo,
                                                 vitramo, r_liqpag.npoliza, r_liqpag.fvencim,
                                                 r_liqpag.fefecto, r_companias.ccompani,
                                                 vpcompa, vicesion, psproces,
                                                 r_liqpag.sseguro, r_liqpag.sidepag,
                                                 r_liqpag.cgarant, 0, pexperr);

            IF error <> 0 THEN
               pexperr := error || ' : ' || pexperr;
               grabar_incidencia(r_liqpag.nsinies, r_liqpag.scontra, r_liqpag.nversio,
                                 r_tramo.ctramo, vptramo, vitramo, r_liqpag.npoliza,
                                 r_liqpag.fvencim, r_companias.ccompani, r_companias.pcesion,
                                 vicesion, psproces, r_liqpag.sseguro, pexperr);
               RETURN(error);
            END IF;
         END LOOP;
      END LOOP;

      IF vipropi IS NULL THEN
         error := modificar_propios(r_liqpag.nsinies, r_liqpag.sidepag, r_liqpag.cgarant,
                                    psproces, pexperr);
      END IF;
   END LOOP;

-- PROCESO PARA EL 2º CONTRATO
   FOR r_liqpag2con IN c_liqpag2con(psproces) LOOP
      vramo := 0;
      vtipram := 0;
      vany := 0;
      vicesion := 0;
      vitramo := 0;
      vicompa := 0;
      error := buscar_ramo(r_liqpag2con.scontra, r_liqpag2con.sseguro, pexperr);

      IF error <> 0 THEN
         pexperr := error || ' : ' || pexperr;
         grabar_incidencia(r_liqpag2con.nsinies, r_liqpag2con.scontra, r_liqpag2con.nversio,
                           0, vptramo, vitramo, r_liqpag2con.npoliza, r_liqpag2con.fvencim, 0,
                           0, 0, psproces, r_liqpag2con.sseguro, pexperr);
         RETURN(error);
      END IF;

      error := anyo_contrato(r_liqpag2con.scontra, r_liqpag2con.nversio, NULL, pexperr);

      IF error <> 0 THEN
         pexperr := error || ' : ' || pexperr;
         grabar_incidencia(r_liqpag2con.nsinies, r_liqpag2con.scontra, r_liqpag2con.nversio,
                           1, vptramo, vitramo, r_liqpag2con.npoliza, r_liqpag2con.fvencim, 0,
                           0, r_liqpag2con.itotal, psproces, r_liqpag2con.sseguro, pexperr);
         RETURN(error);
      END IF;

      vicesion := r_liqpag2con.itotal;
      vppropi := r_liqpag2con.ppropio;
      vptramo :=(100 - vppropi);
      vipropi := (vppropi / 100) * vicesion;
      vitramo := (vptramo / 100) * vicesion;

      FOR r_companias IN c_companias(r_liqpag2con.scontra, r_liqpag2con.nversio, 1, NULL) LOOP
         vpcompa := r_companias.pcesion;
         vicompa := (vpcompa / 100) * vicesion;
         error := insertar_tabla_liqpagreaaux(r_liqpag2con.nsinies, r_liqpag2con.scontra,
                                              r_liqpag2con.nversio, 1, vptramo, vitramo,
                                              r_liqpag2con.npoliza, r_liqpag2con.fvencim,
                                              r_liqpag2con.fefecto, r_companias.ccompani,
                                              vpcompa, r_liqpag2con.itotal, psproces,
                                              r_liqpag2con.sseguro, r_liqpag2con.sidepag,
                                              r_liqpag2con.cgarant, 1, pexperr);

         IF error <> 0 THEN
            pexperr := error || ' : ' || pexperr;
            grabar_incidencia(r_liqpag2con.nsinies, r_liqpag2con.scontra,
                              r_liqpag2con.nversio, 1, vptramo, vitramo, r_liqpag2con.npoliza,
                              r_liqpag2con.fvencim, r_companias.ccompani, r_companias.pcesion,
                              r_liqpag2con.itotal, psproces, r_liqpag2con.sseguro, pexperr);
            RETURN(error);
         END IF;
      END LOOP;

      error := borrar_segundo_contrato(psproces, r_liqpag2con.sidepag, r_liqpag2con.cgarant,
                                       pexperr);

      IF error <> 0 THEN
         pexperr := error || ' : ' || pexperr;
         grabar_incidencia(r_liqpag2con.nsinies, r_liqpag2con.scontra, r_liqpag2con.nversio,
                           1, vptramo, vitramo, r_liqpag2con.npoliza, r_liqpag2con.fvencim, 0,
                           0, r_liqpag2con.itotal, psproces, r_liqpag2con.sseguro, pexperr);
         RETURN(error);
      END IF;
   END LOOP;

   RETURN(0);
END f_liquidapagreas;

/

  GRANT EXECUTE ON "AXIS"."F_LIQUIDAPAGREAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_LIQUIDAPAGREAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_LIQUIDAPAGREAS" TO "PROGRAMADORESCSI";
