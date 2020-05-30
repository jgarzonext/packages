--------------------------------------------------------
--  DDL for Package Body PAC_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIN" IS
   /****************************************************************************
    NOMBRE:     PAC_SIN
    PROPÓSITO:  Funciones para los módulos del área SIN

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ----------------------------------
    1.0        ???          ???              1. Creación del package.
    2.0        19/03/2009   JRB              2. Se añaden las fechas para identificar los pagos
    3.0        11/05/2009   APD              3. Bug 9685 - en lugar de coger la actividad de la tabla seguros,
                                                llamar a la función pac_seguros.ff_get_actividad
    4.0        02/06/2009   ETM              4. bug 0010266: CRE - cuenta de abono en pólizas de salud y bajas
    5.0        03/06/2009   ICV              5. 0008947: CRE046 - Gestión de cobertura Enfermedad Grave en siniestros
    6.0        30/06/2009   DRA              6. 0010581: CRE - Error en la generació automàtica de pagaments de sinistres, i la posterior generació de transferències
    7.0        02/07/2009   DCT              7. 0010612: Canviar vista personas por tablas personas per_personas, per_detper.
    8.0        23/09/2009   DRA              8. 0011183: CRE - Suplemento de alta de asegurado ya existente
    9.0        03/03/2010   RSC              9. 0013482: CRE - Vencimientos PPJ Dinámico / Pla Estudiant
                                                         en fin de semana no se están contabilizano en Entradas / Salidas
    10.0       11/03/2010   JRH              10. 0012136: CEM - RVI - Verificación productos RVI
    11.0       11/03/2010   RSC              11. 0013435: REajuste en el cálculo de la fecha de efecto del suplemento automático
    12.0       30/03/2010   RSC              12. 0014021: CRE - Entran rescates en dias no habiles PPJ Dinámico/PLA Estudiant
    13.0       03/05/2010   DRA              13. 0014289: CRE200 - Recuperación de cuenta de abono en siniestros y reembolsos
    14.0       05/05/2010   RSC              14. 0013435: CRE - Ajuste en el cálculo de la fecha de efecto del suplemento automático
    15.0       20/09/2010   JRH              15. 0015869: CIV401 - Renta vitalícia: incidencias 12/08/2010
    16.0       18/07/2012   DRA              16. 0022807: CIV800-ERROR EN TRANSFERENCIAS PRODUCTO PIAS
    17.0       01/03/2019   CES		     	 17. TCS-1554: Convivencia Osiris - iAxis
	18.0	   18/03/2020	SP				 18. Cambios de  tarea IAXIS-13044	
   ****************************************************************************/

   -- Bug 9276 - 27/02/2009 - APD - Se crea la funcion
   /*  Funcion que reajusta un seguro cuando se finaliza un siniestro que ha sido reabrierto*/
   FUNCTION f_reajustar_ctaseguro(p_nsinies IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER IS
      v_ivalora      valorasini.ivalora%TYPE;
      v_imovimi      ctaseguro.imovimi%TYPE;   -- NUMBER(13,2)
      num_err        NUMBER;
      v_sproduc      seguros.sproduc%TYPE;
   BEGIN
      -- Bug 9276 - 27/02/2009 - APD -Se busca el sumatorio de todos los imovimi para el siniestros.
      -- De esta manera también se está buscando si existe o no el apunte en ctaseguro
      -- Bug 7484 - 03/02/2011 - JBN -CRE800 - Registres duplicats a CTASEGURO
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = p_sseguro;

      IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         SELECT NVL(SUM(imovimi), 0)
           INTO v_imovimi
           FROM ctaseguro
          WHERE sseguro = p_sseguro
            AND nsinies = p_nsinies
            AND cesta IS NOT NULL;
      ELSE
         SELECT NVL(SUM(imovimi), 0)
           INTO v_imovimi
           FROM ctaseguro
          WHERE sseguro = p_sseguro
            AND nsinies = p_nsinies;
      END IF;

      -- Bug 9276 - 27/02/2009 - APD -Se busca el sumatorio de todos los ivalora para el siniestros.
      IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         SELECT NVL(SUM(icaprisc), 0)
           INTO v_ivalora
           FROM valorasini
          WHERE nsinies = p_nsinies
            AND fvalora = (SELECT MAX(fvalora)
                             FROM valorasini
                            WHERE nsinies = p_nsinies
                              AND cgarant <> 9998);
      ELSE
         SELECT NVL(SUM(ivalora), 0)
           INTO v_ivalora
           FROM valorasini
          WHERE nsinies = p_nsinies
            AND fvalora = (SELECT MAX(fvalora)
                             FROM valorasini
                            WHERE nsinies = p_nsinies
                              AND cgarant <> 9998);
      END IF;

      -- fin Bug 7484 - 03/02/2011 - JBN -CRE800 - Registres duplicats a CTASEGURO
      IF v_imovimi = 0 THEN
         RETURN 0;   -- Bug 9276 - 27/02/2009 - APD -No existe el apunte en ctaseguro
      ELSIF v_imovimi = v_ivalora THEN
         RETURN 1;   -- Bug 9276 - 27/02/2009 - APD - Ya existe el apunte en ctaseguro
      ELSE   -- Bug 9276 - 27/02/2009 - APD - v_imovimi <> v_ivalora
         FOR reg IN (SELECT sseguro, ffecmov, fvalmov, cmovimi, imovimi, nsinies
                       FROM ctaseguro
                      WHERE sseguro = p_sseguro
                        AND nsinies = p_nsinies) LOOP
            -- Bug 9276 - 27/02/2009 - APD - se deben anular los apuntes en ctaseguro
            -- para volverlos a introducir llamando a pac_rescates.f_finaliza_rescates
            -- Se inserta el movimiento 10 (Anulacion prestacion)
            num_err := pac_ctaseguro.f_insctaseguro(reg.sseguro, f_sysdate, NULL, reg.ffecmov,
                                                    reg.fvalmov, 10, reg.imovimi, 0, NULL, 0,
                                                    0, reg.nsinies, NULL, NULL);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            num_err := pac_ctaseguro.f_insctaseguro_shw(reg.sseguro, f_sysdate, NULL,
                                                        reg.ffecmov, reg.fvalmov, 10,
                                                        reg.imovimi, 0, NULL, 0, 0,
                                                        reg.nsinies, NULL, NULL);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            RETURN 0;   -- Bug 9276 - 27/02/2009 - APD - Se han anulado los apuntes introducidos anteriormente
                        -- y despues se tendran que volver a introducir llamando a pac_rescates.f_finaliza_rescates
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104882;   -- Error al leer de la tabla CTASEGURO
   END f_reajustar_ctaseguro;

   FUNCTION f_datosnsinies(
      pnsinies IN NUMBER,
      pfsinies OUT DATE,
      ptsinies OUT VARCHAR2,
      pcculpab OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT fsinies, tsinies, cculpab
        INTO pfsinies, ptsinies, pcculpab
        FROM siniestros
       WHERE nsinies = pnsinies;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pfsinies := NULL;
         ptsinies := '**';
         pcculpab := NULL;
         RETURN 101667;
      WHEN OTHERS THEN
         pfsinies := NULL;
         ptsinies := '***';
         pcculpab := NULL;
         RETURN SQLCODE;
   END f_datosnsinies;

--------------------------------------------------------------------
   FUNCTION f_ivapago(psidepag IN NUMBER, pptipiva OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT t.ptipiva
        INTO pptipiva
        FROM pagosinitrami p, destinatrami d, profesionales f, tipoiva t
       WHERE p.sidepag = psidepag
         AND p.nsinies = d.nsinies
         AND p.ntramit = d.ntramit
         AND p.ctipdes = d.ctipdes
         AND p.sperson = d.sperson
         AND d.sperson = f.sperson
         AND d.cactpro = f.cactpro
         AND f.ctipiva = t.ctipiva
         AND t.finivig < p.fordpag
         AND(t.ffinvig IS NULL
             OR t.ffinvig > p.fordpag);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pptipiva := 0;
         RETURN 0;
      WHEN OTHERS THEN
         pptipiva := 0;
         RETURN SQLCODE;
   END f_ivapago;

--------------------------------------------------------------------
   FUNCTION f_iimpiva(pisinret IN NUMBER, pptipiva IN NUMBER, pimpiva OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      pimpiva := f_round(((1 -(100 /(100 + pptipiva))) * pisinret));
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pimpiva := 0;
         RETURN SQLCODE;
   END f_iimpiva;

--------------------------------------------------------------------
   FUNCTION f_valoracio(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      valoracio OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(v1.ivalora, 0)
        INTO valoracio
        FROM valorasinitrami v1
       WHERE v1.nsinies = pnsinies
         AND v1.ntramit = pntramit
         AND v1.cgarant = pcgarant
         AND v1.nvalora = (SELECT MAX(nvalora)
                             FROM valorasinitrami v2
                            WHERE v2.nsinies = v1.nsinies
                              AND v2.ntramit = v1.ntramit
                              AND v2.cgarant = v1.cgarant
                              AND(pdata IS NULL
                                  OR v2.fvalora <= pdata));

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         valoracio := 0;
         RETURN 101667;
      WHEN OTHERS THEN
         valoracio := 0;
         RETURN SQLCODE;
   END f_valoracio;

--------------------------------------------------------------------
   FUNCTION f_pagos(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      pagos OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(SUM(DECODE(s.ctippag, 2, g.isinret, 8, g.isinret, g.isinret * -1)), 0)
        INTO pagos
        FROM pagosinitrami s, pagogarantrami g
       WHERE s.sidepag = g.sidepag
         AND s.nsinies = pnsinies
         AND s.ntramit = pntramit
         AND(pdata IS NULL
             OR s.fordpag <= pdata)
         AND g.cgarant = pcgarant
         AND s.cestpag <> 8;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pagos := 0;
         RETURN 101667;
      WHEN OTHERS THEN
         pagos := 0;
         RETURN SQLCODE;
   END f_pagos;

--------------------------------------------------------------------
   FUNCTION f_destramitacionsini(
      psseguro IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcidioma IN NUMBER,
      pttramit OUT VARCHAR2,
      plongitud IN NUMBER DEFAULT 500)
      RETURN NUMBER IS
      vctiptra       NUMBER;
      vcpais         NUMBER;
      vcprovin       NUMBER;
      vcpoblac       NUMBER;
      vcpostal       codpostal.cpostal%TYPE;
      vtpais         VARCHAR2(20);
      vtprovin       VARCHAR2(20);
      vtpoblac       VARCHAR2(20);
      res            NUMBER;
      vsmodelo       NUMBER;
      vcmatric       VARCHAR2(12);
      vcmarca        VARCHAR2(5);
      vtmarca        VARCHAR2(40);
      vtmodelo       VARCHAR2(40);
      vcversion      VARCHAR2(11);
      vtversion      VARCHAR2(40);
      vnnumnif       VARCHAR2(10);
      vtdescri       VARCHAR2(500);
      vtvarian       VARCHAR2(30);
      vcolor         VARCHAR2(30);
      vtapelli       VARCHAR2(40);
      vtnombre       VARCHAR2(20);
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      SELECT c.ctiptra
        INTO vctiptra
        FROM coditramitacion c, tramitacionsini t
       WHERE t.nsinies = pnsinies
         AND t.ntramit = pntramit
         AND t.ctramit = c.ctramit;

      IF vctiptra = 0 THEN   -- Tramitación genérica
         IF pcidioma = 1 THEN
            pttramit := 'Tramitació Global Sinistre';
         ELSE
            pttramit := 'Tramitación Global Siniestro';
         END IF;
      ELSIF vctiptra = 1 THEN   -- Vehículo asegurado
         res := f_desvehicle_aseg(pnsinies, pntramit, vcmatric, vcolor, vtmarca, vtmodelo,
                                  vtversion, pcidioma);

         IF (vcmatric IS NULL
             AND vtmarca IS NULL
             AND vtmodelo IS NULL
             AND vtversion IS NULL) THEN
            RETURN 101667;
         ELSE
            IF pcidioma = 1 THEN
               pttramit := 'Cotxe: ' || vcmatric || ', Marca: ' || vtmarca || ', Model: '
                           || vtmodelo || ', Versió: ' || vtversion;
            ELSE
               pttramit := 'Coche: ' || vcmatric || ', Marca: ' || vtmarca || ', Modelo: '
                           || vtmodelo || ', Versión: ' || vtversion;
            END IF;
         END IF;
      /*ELSIF VCTIPTRA = 2 THEN      -- Vehículo contrario
        SELECT CMATRIC, CMARCA, SMODELO, CVERSION
        INTO VCMATRIC, VCMARCA, VSMODELO, VCVERSION
        FROM TRAMITACIONSINI
        WHERE NSINIES = PNSINIES AND
              NTRAMIT = PNTRAMIT;
        if (VCMATRIC IS NULL AND VCMARCA IS NULL AND VSMODELO IS NULL  AND VCVERSION IS NULL ) then
          RETURN 101667;
        else
          res:=f_desautmodelo (1,vcmarca,vtmarca,vsmodelo,vtmodelo,50,50);
          res:=f_desautversion (1,vcversion,vtmarca,vtmodelo,vtversion,vtvarian,50,50,50,50);
          IF PCIDIOMA = 1 THEN
            PTTRAMIT := 'Cotxe: '||VCMATRIC||', Marca: '||VTMARCA||', Model: '||VTMODELO||', Versió: '||VTVERSION;
          ELSE
            PTTRAMIT := 'Coche: '||VCMATRIC||', Marca: '||VTMARCA||', Modelo: '||VTMODELO||', Versión: '||VTVERSION;
          END IF;
        end if;*/
      ELSIF vctiptra = 3 THEN   -- Víctima
         -- Bug10612 - 02/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
         --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
         SELECT cagente, cempres
           INTO vagente_poliza, vcempres
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT p.nnumide
           INTO vnnumnif
           FROM tramitacionsini t, per_personas p, per_detper d
          WHERE t.nsinies = pnsinies
            AND t.ntramit = pntramit
            AND t.sperson = p.sperson
            AND d.sperson = p.sperson
            AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);

         /*SELECT nnumnif
           INTO vnnumnif
           FROM tramitacionsini t, personas p
          WHERE t.nsinies = pnsinies
            AND t.ntramit = pntramit
            AND t.sperson = p.sperson;*/

         -- FI Bug10612 - 02/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
         pttramit := 'Persona: ' || vnnumnif;
      ELSIF vctiptra = 4 THEN   -- Otros involucrados
         SELECT tdescri
           INTO pttramit
           FROM tramitacionsini
          WHERE nsinies = pnsinies
            AND ntramit = pntramit;
      ELSIF vctiptra = 5 THEN   -- Dirección
         SELECT cpais, cprovin, cpoblac, cpostal
           INTO vcpais, vcprovin, vcpoblac, vcpostal
           FROM tramitacionsini
          WHERE nsinies = pnsinies
            AND ntramit = pntramit;

         IF (vcpais IS NULL
             AND vcprovin IS NULL
             AND vcpoblac IS NULL
             AND vcpostal IS NULL) THEN
            RETURN 101667;
         ELSE
            res := f_desprovin(vcprovin, vtprovin, vcpais, vtpais);
            res := f_despoblac(vcpoblac, vcprovin, vtpoblac);

            IF pcidioma = 1 THEN
               pttramit := 'País: ' || vtpais || ', Provincia: ' || vtprovin || ', Població: '
                           || vtpoblac || ', CP: ' || vcpostal;
            --|| LPAD (TO_CHAR (vcpostal), 5, '0');
            ELSE
               pttramit := 'País: ' || vtpais || ', Provincia: ' || vtprovin
                           || ', Población: ' || vtpoblac || ', CP: ' || vcpostal;
            --|| LPAD (TO_CHAR (vcpostal), 5, '0');
            END IF;
         END IF;
      ELSIF vctiptra = 6 THEN   -- Conductro vehículo asegurado
         -- Bug10612 - 02/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
         --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
         SELECT cagente, cempres
           INTO vagente_poliza, vcempres
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT p.nnumide,
                SUBSTR(SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20), 1, 40)
                                                                                       tapelli,
                d.tnombre
           INTO vnnumnif,
                vtapelli,
                vtnombre
           FROM tramitacionsini t, per_personas p, per_detper d
          WHERE t.nsinies = pnsinies
            AND t.ntramit = pntramit
            AND t.sperson = p.sperson
            AND d.sperson = p.sperson
            AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);

         /*SELECT nnumnif, tapelli, tnombre
           INTO vnnumnif, vtapelli, vtnombre
           FROM tramitacionsini t, personas p
          WHERE t.nsinies = pnsinies
            AND t.ntramit = pntramit
            AND t.sperson = p.sperson;*/

         -- FI Bug10612 - 02/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
         IF pcidioma = 1 THEN
            pttramit := 'Conductor: ' || vnnumnif || ' ' || vtnombre || ' ' || vtapelli;
         ELSE
            pttramit := 'Conductor: ' || vnnumnif || ' ' || vtnombre || ' ' || vtapelli;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pttramit := '**';
         RETURN 101667;
      WHEN OTHERS THEN
         pttramit := '***';
         RETURN SQLCODE;
   END f_destramitacionsini;

--------------------------------------------------------------------
   FUNCTION f_desvehicle_aseg(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pmatricula OUT VARCHAR2,
      pcolor OUT VARCHAR2,
      pmarca OUT VARCHAR2,
      pmodelo OUT VARCHAR2,
      pversion OUT VARCHAR2,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      aux            NUMBER;
      vcolor         NUMBER;
   BEGIN
      SELECT ar.cmatric, ar.ccolor, am.tmarca, ad.tmodelo, av.tversion
        INTO pmatricula, vcolor, pmarca, pmodelo, pversion
        FROM tramitacionsini tr, siniestros si, autriesgos ar, aut_versiones av, aut_marcas am,
             aut_modelos ad
       WHERE tr.nsinies = si.nsinies
         AND si.sseguro = ar.sseguro
         AND ar.nriesgo = si.nriesgo
         AND ar.nmovimi = si.nmovimi
         AND av.cversion = ar.cversion
         AND am.cmarca = av.cmarca
         AND ad.cmarca = av.cmarca
         AND ad.cmodelo = av.cmodelo
         AND tr.nsinies = pnsinies
         AND tr.ntramit = pntramit;

      IF vcolor IS NOT NULL THEN
         aux := f_desvalorfijo(440, pcidioma, vcolor, pcolor);
      ELSE
         pcolor := NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pmatricula := NULL;
         pmarca := NULL;
         pmodelo := NULL;
         pversion := NULL;
         pcolor := NULL;
   END f_desvehicle_aseg;

--------------------------------------------------------------------
   FUNCTION f_iconret(pisinret IN NUMBER, pretenc IN NUMBER, piconret OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      piconret := pisinret -((pisinret * pretenc) / 100);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         piconret := 0;
         RETURN SQLCODE;
   END f_iconret;

--------------------------------------------------------------------
   FUNCTION f_retencpago(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pdata IN DATE,
      pretenc OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT t.pretenc
        INTO pretenc
        FROM profesionales f, retenciones t, destinatrami d
       WHERE d.nsinies = pnsinies
         AND d.ntramit = pntramit
         AND d.sperson = psperson
         AND d.ctipdes = pctipdes
         AND f.sperson = d.sperson
         AND f.cactpro = d.cactpro
         AND t.cretenc = f.cretenc
         AND t.finivig < pdata
         AND(t.ffinvig IS NULL
             OR t.ffinvig > pdata);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pretenc := 0;
         RETURN 0;
      WHEN OTHERS THEN
         pretenc := 0;
         RETURN SQLCODE;
   END f_retencpago;

--------------------------------------------------------------------
   FUNCTION f_ctipcoa(psseguro IN NUMBER, pctipcoa OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT ctipcoa
        INTO pctipcoa
        FROM seguros
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pctipcoa := 0;
         RETURN 0;
      WHEN OTHERS THEN
         pctipcoa := 0;
         RETURN SQLCODE;
   END f_ctipcoa;

--------------------------------------------------------------------
   FUNCTION f_descausasini(pccausin IN NUMBER, pcidioma IN NUMBER, ptcausin OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT tcausin
        INTO ptcausin
        FROM causasini
       WHERE cidioma = pcidioma
         AND ccausin = pccausin;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ptcausin := '**';
         RETURN 101667;
      WHEN OTHERS THEN
         ptcausin := '***';
         RETURN SQLCODE;
   END f_descausasini;

--------------------------------------------------------------------
   FUNCTION f_crefsin(
      pnsinies IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pcrefsin OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT DISTINCT crefsin
                 INTO pcrefsin
                 FROM destinatrami
                WHERE nsinies = pnsinies
                  AND sperson = psperson
                  AND ctipdes = pctipdes;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pcrefsin := NULL;
         RETURN SQLCODE;
   END f_crefsin;

--------------------------------------------------------------------
   FUNCTION f_crefint(pnsinies IN NUMBER, ptramitador IN VARCHAR2, pcrefint OUT VARCHAR2)
      RETURN NUMBER IS
      aux            NUMBER(8);
   BEGIN
      aux := f_parinstalacion_n('CREFINT');

      IF aux = 1 THEN
         pcrefint := TO_CHAR(f_sysdate, 'rrrr') || '/' || TO_CHAR(pnsinies);
      ELSIF aux = 2 THEN
         pcrefint := TO_CHAR(f_sysdate, 'rrrr') || '/' || ptramitador || '/'
                     || TO_CHAR(pnsinies);
      ELSE
         pcrefint := TO_CHAR(pnsinies);
      END IF;

      RETURN 0;
   END f_crefint;

--------------------------------------------------------------------
   FUNCTION f_desdiario(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pnlintra IN NUMBER,
      pcidioma IN NUMBER,
      pdesc OUT VARCHAR2)
      RETURN NUMBER IS
      no_nul         EXCEPTION;
      pclintra       NUMBER;
      psasigna       NUMBER;
      pnlocali       NUMBER;
      psperson       NUMBER;
      pctipdes       NUMBER;
      pcgarant       NUMBER;
      pnvalora       NUMBER;
      psidepag       NUMBER;
      pnlinpro       NUMBER;
      pcestado       NUMBER;
      pndano         NUMBER;
      pasig          VARCHAR2(500);
      pcpais         NUMBER;
      pcprovin       NUMBER;
      pcpoblac       NUMBER;
      pcpostal       codpostal.cpostal%TYPE;
      pcactpro       NUMBER;
      sortida        NUMBER;
      vsperson       NUMBER;
      vcestado       NUMBER;
      res            NUMBER;
      pivalora       NUMBER;
      pisinret       NUMBER;
      pcestpag       NUMBER;
      pctipdan       NUMBER;
      dcpais         VARCHAR2(20);
      dcprovin       VARCHAR2(30);
      dcpoblac       VARCHAR2(50);
      dcactpro       VARCHAR2(100);
      dnom           VARCHAR2(60);
      dnif           VARCHAR2(10);
      dcestado       VARCHAR2(10);
      dpasig         VARCHAR2(15);
      dctipdes       VARCHAR2(30);
      dcgarant       VARCHAR2(40);
      dcestpag       VARCHAR2(30);
      dctipdan       VARCHAR2(30);
      primer         NUMBER := 0;
      cont           NUMBER;
   BEGIN
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR pnlintra IS NULL
          OR pcidioma IS NULL) THEN
         RAISE no_nul;
      END IF;

      SELECT clintra, sasigna, nlocali, sperson, ctipdes, cgarant, nvalora, sidepag,
             nlinpro, cestado, ndano, tlintra
        INTO pclintra, psasigna, pnlocali, psperson, pctipdes, pcgarant, pnvalora, psidepag,
             pnlinpro, pcestado, pndano, pasig
        FROM diariotramitacion
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND nlintra = pnlintra;

      IF (pclintra = 1) THEN   -- registro modificado en LOCALIZATRAMI
         IF (pnlocali IS NULL) THEN
            RAISE no_nul;
         END IF;

         SELECT cprovin, cpoblac, cpostal, cpais
           INTO pcprovin, pcpoblac, pcpostal, pcpais
           FROM localizatrami
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND nlocali = pnlocali;

         res := f_desprovin(pcprovin, dcprovin, pcpais, dcpais);
         res := f_despoblac(pcpoblac, pcprovin, dcpoblac);

         SELECT d.nlocali
           INTO sortida
           FROM diariotramitacion d
          WHERE d.nsinies = pnsinies
            AND d.ntramit = pntramit
            AND d.nlocali = pnlocali
            AND d.clintra = 1;

         IF (pcidioma = 1) THEN
            IF (sortida > 1) THEN
               pdesc := 'S''ha fet un trasllat a la Provincia: ' || dcprovin || ', Població: '
                        || dcpoblac || ', CP: ' || pcpostal
                                                           --  || LPAD (TO_CHAR (pcpostal), 5, '0')
                        || '.';
            ELSE
               pdesc := 'S''ha introduït la localització inicial a la Provincia: ' || dcprovin
                        || ', Població: ' || dcpoblac || ', CP: '
                                                                 -- || LPAD (TO_CHAR (pcpostal), 5, '0')
                        || pcpostal || '.';
            END IF;
         ELSIF(pcidioma = 2) THEN
            IF (sortida > 1) THEN
               pdesc := 'Se ha hecho un traslado a la Província: ' || dcprovin
                        || ', Población: ' || dcpoblac || ', CP: '
                                                                  -- || NVL (LPAD (TO_CHAR (pcpostal), 5, '0'), '**')
                        || NVL(pcpostal, '**') || '.';
            ELSE
               pdesc := 'Se ha introducido la localización inicial en la Província: '
                        || dcprovin || ', Población: ' || dcpoblac || ', CP: '
                        -- || NVL (LPAD (TO_CHAR (pcpostal), 5, '0'), '**')
                        || NVL(pcpostal, '**') || '.';
            END IF;
         END IF;
      ELSIF(pclintra = 2) THEN   -- registro modificado en TRAMITACIONSINI
         SELECT t.cestado
           INTO vcestado
           FROM diariotramitacion t
          WHERE t.nsinies = pnsinies
            AND t.ntramit = pntramit
            AND nlintra = pnlintra;

         res := f_desvalorfijo(6, pcidioma, vcestado, dcestado);

         IF (pcidioma = 1) THEN
            pdesc := 'La tramitació ha canviat a l''estat ' || dcestado || '.';
         ELSIF(pcidioma = 2) THEN
            pdesc := 'La tramitación ha cambiado al estado ' || dcestado || '.';
         END IF;
      ELSIF(pclintra = 3) THEN   -- registro modificado en ASIGPROTRAMI
         IF (pasig = 'AUT') THEN
            IF (pcidioma = 1) THEN
               dpasig := 'Automàtic';
            ELSE
               dpasig := 'Automático';
            END IF;
         ELSIF(pasig = 'MAN') THEN
            dpasig := 'Manual';
         END IF;

         IF (pnlocali IS NULL
             OR psasigna IS NULL) THEN
            RAISE no_nul;
         END IF;

         SELECT a.sperson, a.cactpro, l.cprovin, l.cpoblac, l.cpostal, l.cpais
           INTO vsperson, pcactpro, pcprovin, pcpoblac, pcpostal, pcpais
           FROM asigprotrami a, localizatrami l
          WHERE a.sasigna = psasigna
            AND a.nlocali = pnlocali
            AND l.nsinies = pnsinies
            AND l.ntramit = pntramit
            AND l.nlocali = a.nlocali;

         res := f_desprovin(pcprovin, dcprovin, pcpais, dcpais);
         res := f_despoblac(pcpoblac, pcprovin, dcpoblac);
         res := f_desactpro(pcactpro, pcidioma, dcactpro);
         res := f_persona(vsperson, 2, dnif, vsperson, dnom, sortida);

         IF (pcidioma = 1) THEN
            pdesc := 'El profesional asignat a la Provincia: ' || dcprovin || ', Població: '
                     || dcpoblac || ', CP: '
                                            -- || NVL (LPAD (TO_CHAR (pcpostal), 5, '0'), '**')
                     || NVL(pcpostal, '**') || ' és ' || dnom || ' amb la categoria de '
                     || dcactpro || ' i NIF ' || NVL(dnif, '(Sense NIF)') || '.'
                     || 'L''asignació ha estat ' || dpasig;
         ELSIF(pcidioma = 2) THEN
            pdesc := 'El profesional asignado a la Provincia: ' || dcprovin || ', Población: '
                     || dcpoblac || ', CP: '
                                            --|| NVL (LPAD (TO_CHAR (pcpostal), 5, '0'), '**')
                     || NVL(pcpostal, '**') || ' es ' || dnom || ' con la categoría de '
                     || dcactpro || ' y NIF ' || NVL(dnif, '(Sin NIF)') || '.'
                     || 'La asignación ha sido ' || dpasig;
         END IF;
      ELSIF(pclintra = 4) THEN   -- registro modificado en DESTINATRAMI
         IF (psperson IS NULL
             OR pctipdes IS NULL) THEN
            RAISE no_nul;
         END IF;

         -- Protegemos la select
         BEGIN
            SELECT cactpro
              INTO pcactpro
              FROM destinatrami
             WHERE nsinies = pnsinies
               AND ntramit = pntramit
               AND sperson = psperson
               AND ctipdes = pctipdes;
         EXCEPTION
            WHEN OTHERS THEN
               SELECT cactpro
                 INTO pcactpro
                 FROM destinatarios
                WHERE nsinies = pnsinies
                  AND sperson = psperson
                  AND ctipdes = pctipdes;
         END;

         res := f_desvalorfijo(10, pcidioma, pctipdes, dctipdes);
         res := f_desactpro(pcactpro, pcidioma, dcactpro);
         res := f_persona(psperson, 2, dnif, vsperson, dnom, sortida);

         IF (pcidioma = 1) THEN
            IF pctipdes <> 13 THEN
               pdesc := 'El nou destinatari és ' || dnom || ', NIF '
                        || NVL(dnif, '(Sense NIF)') || ' i es del tipus ' || dctipdes || '.';

               IF pcactpro IS NOT NULL THEN
                  pdesc := pdesc || ' La categoria profesional és ' || dcactpro || '.';
               END IF;
            ELSE
               pdesc := 'El testimoni és ' || dnom || ', NIF ' || NVL(dnif, '(Sense NIF)')
                        || '.';
            END IF;
         ELSIF(pcidioma = 2) THEN
            IF pctipdes <> 13 THEN
               pdesc := 'El nuevo destinatario es ' || dnom || ', NIF '
                        || NVL(dnif, '(Sin NIF)') || ' y es del tipo ' || dctipdes || '.';

               IF pcactpro IS NOT NULL THEN
                  pdesc := pdesc || ' La categoría profesional es ' || dcactpro || '.';
               END IF;
            ELSE
               pdesc := 'El testigo es ' || dnom || ', NIF ' || NVL(dnif, '(Sin NIF)') || '.';
            END IF;
         END IF;
      ELSIF(pclintra = 5) THEN   -- registro modificado en VALORASINITRAMI
         IF (pcgarant IS NULL
             OR pnvalora IS NULL) THEN
            RAISE no_nul;
         END IF;

            /* SELECT ivalora
             INTO pivalora
             FROM valorasini--trami
             WHERE nsinies=pnsinies
                   AND ntramit=pntramit
                   AND cgarant=pcgarant;
                   AND nvalora=pnvalora;
         */
         res := f_desgarantia(pcgarant, pcidioma, dcgarant);

         IF (pcidioma = 1) THEN
            pdesc := 'S''ha introduït una nova valoració amb garantia ' || dcgarant || '.';
         ELSIF(pcidioma = 2) THEN
            pdesc := 'Se ha introducido una nueva valoración con garantía ' || dcgarant || '.';
         END IF;
      ELSIF(pclintra = 6) THEN   -- registro modificado en PAGOSINITRAMI
         IF (psidepag IS NULL) THEN
            RAISE no_nul;
         END IF;

         SELECT MIN(nlintra)
           INTO primer
           FROM diariotramitacion
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND sidepag = psidepag
            AND clintra = pclintra;

         SELECT cestado, sperson
           INTO pcestpag, vsperson
           FROM diariotramitacion
          WHERE nlintra = pnlintra
            AND nsinies = pnsinies
            AND ntramit = pntramit;

         res := f_persona(vsperson, 2, dnif, vsperson, dnom, sortida);
         res := f_desvalorfijo(3, pcidioma, pcestpag, dcestpag);

         -- pcestpag: 0-Pendiente; 1-Aceptado; 2-Pagado; 8-Anulado
         IF (pcidioma = 1) THEN
            IF (pcestpag = 0)
               AND(primer = pnlintra) THEN
               pdesc := 'S''ha obert un pagament per el Sr./Sra. ' || dnom || ', NIF '
                        || NVL(dnif, '(Sense NIF)') || '.';
            ELSIF (pcestpag = 0)
                  AND(primer <> pnlintra) THEN
               pdesc := 'Estat ' || dcestpag || ' per el pagament del Sr./Sra. ' || dnom
                        || ', NIF ' || NVL(dnif, '(Sense NIF)') || '.';
            ELSIF (pcestpag = 1)
                  OR(pcestpag = 8) THEN
               pdesc := 'S''ha ' || dcestpag || ' el pagament per el Sr./Sra. ' || dnom
                        || ', NIF ' || NVL(dnif, '(Sense NIF)') || '.';
            ELSIF(pcestpag = 2) THEN
               pdesc := 'S''ha efectuat el pagament per el Sr./Sra. ' || dnom || ', NIF '
                        || NVL(dnif, '(Sense NIF)') || '.';
            END IF;
         ELSIF(pcidioma = 2) THEN
            IF (pcestpag = 0)
               AND(primer = pnlintra) THEN
               pdesc := 'Se ha abierto un pago para el Sr./Sra. ' || dnom || ', NIF '
                        || NVL(dnif, '(Sin NIF)') || '.';
            ELSIF (pcestpag = 0)
                  AND(primer <> pnlintra) THEN
               pdesc := 'Estado ' || dcestpag || ' para el pago del Sr./Sra. ' || dnom
                        || ', NIF ' || NVL(dnif, '(Sense NIF)') || '.';
            ELSIF (pcestpag = 1)
                  OR(pcestpag = 8) THEN
               pdesc := 'Se ha ' || dcestpag || ' el pago para el Sr./Sra. ' || dnom
                        || ', NIF ' || NVL(dnif, '(Sin NIF)') || '.';
            ELSIF(pcestpag = 2) THEN
               pdesc := 'Se ha efectuado el pago para el Sr./Sra. ' || dnom || ', NIF '
                        || NVL(dnif, '(Sin NIF)') || '.';
            END IF;
         END IF;
      ELSIF(pclintra = 7) THEN   -- registro modificado en PAGOGARANTRAMI
         IF (pcgarant IS NULL
             OR psidepag IS NULL) THEN
            RAISE no_nul;
         END IF;

         SELECT isinret
           INTO pisinret
           FROM pagogarantia   --trami
          WHERE cgarant = pcgarant
            AND sidepag = psidepag;

         -- Protegemos la select
         BEGIN
            SELECT sperson
              INTO vsperson
              FROM pagosinitrami
             WHERE sidepag = psidepag;
         EXCEPTION
            WHEN OTHERS THEN
               SELECT sperson
                 INTO vsperson
                 FROM pagosini
                WHERE sidepag = psidepag;
         END;

         res := f_desgarantia(pcgarant, pcidioma, dcgarant);
         res := f_persona(vsperson, 2, dnif, vsperson, dnom, sortida);

         IF (pcidioma = 1) THEN
            pdesc := 'S''ha abonat al Sr./Sra. ' || dnom || ', NIF ' || NVL(dnif, '(Sin NIF)')
                     || ', una quantitat en concepte de la garantia ' || dcgarant || '.';
         ELSIF(pcidioma = 2) THEN
            pdesc := 'Se ha abonado al Sr./Sra. ' || dnom || ', NIF '
                     || NVL(dnif, '(Sin NIF)') || ', una cantidad en concepto de la garantía '
                     || dcgarant || '.';
         END IF;
      ELSIF(pclintra = 8) THEN   -- registro modificado en DIARIOPROFTRAMI
         IF (psperson IS NULL
             OR pctipdes IS NULL
             OR pnlinpro IS NULL) THEN
            RAISE no_nul;
         END IF;

         SELECT cestado, sperson
           INTO vcestado, vsperson
           FROM diariotramitacion
          WHERE sperson = psperson
            AND ctipdes = pctipdes
            AND nlinpro = pnlinpro
            AND nsinies = pnsinies
            AND ntramit = pntramit
            AND nlintra = pnlintra
            AND nsinies = pnsinies
            AND ntramit = pntramit;

         res := f_persona(vsperson, 2, dnif, vsperson, dnom, sortida);
         res := f_desvalorfijo(804, pcidioma, vcestado, dcestado);

         IF (pcidioma = 1) THEN
            pdesc := 'S''ha afegit una anotació al diari del profesional ' || dnom || ', NIF '
                     || NVL(dnif, '(Sin NIF)') || ', en estat de ' || dcestado || '.';
         ELSIF(pcidioma = 2) THEN
            pdesc := 'Se ha añadido una anotación en el diario del profesional ' || dnom
                     || ', NIF ' || NVL(dnif, '(Sin NIF)') || ', en estado de ' || dcestado
                     || '.';
         END IF;
      ELSIF(pclintra = 9) THEN   -- registro modificado en DANOSTRAMI
         IF (pndano IS NULL) THEN
            RAISE no_nul;
         END IF;

         SELECT ctipdan
           INTO pctipdan
           FROM danostrami
          WHERE ndano = pndano
            AND nsinies = pnsinies
            AND ntramit = pntramit;

         res := f_desvalorfijo(802, pcidioma, pctipdan, dctipdan);

         IF (pcidioma = 1) THEN
            pdesc := 'S''ha afegit el ' || dctipdan || '.';
         ELSIF(pcidioma = 2) THEN
            pdesc := 'Se ha añadido el ' || dctipdan || '.';
         END IF;
      ELSIF(pclintra = 99) THEN   -- registro manual
         IF (pasig IS NULL) THEN
            RAISE no_nul;
         END IF;

         pdesc := pasig;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pdesc := '**';
         RETURN 0;
      WHEN no_nul THEN
         pdesc := '**';
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         pdesc := '***';
         RETURN SQLCODE;
   END f_desdiario;

--------------------------------------------------------------------
   FUNCTION f_mantdiario(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcidioma IN NUMBER,
      ptlintra IN VARCHAR2)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 99;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR pcidioma IS NULL
          OR ptlintra IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, tlintra)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, ptlintra);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario;

--------------------------------------------------------------------
   FUNCTION f_mantdiario_locali(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcidioma IN NUMBER,
      pnlocali IN NUMBER)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 1;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR pcidioma IS NULL
          OR pnlocali IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, nlocali)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, pnlocali);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario_locali;

--------------------------------------------------------------------
   FUNCTION f_mantdiario_tram(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcestado IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 2;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR pcidioma IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, cestado)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, pcestado);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario_tram;

--------------------------------------------------------------------
   FUNCTION f_mantdiario_asig(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcidioma IN NUMBER,
      psasigna IN NUMBER,
      pnlocali IN NUMBER,
      ptlintra IN VARCHAR2)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 3;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR pcidioma IS NULL
          OR psasigna IS NULL
          OR pnlocali IS NULL
          OR ptlintra IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, sasigna, nlocali,
                   tlintra)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, psasigna, pnlocali,
                   ptlintra);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario_asig;

--------------------------------------------------------------------
   FUNCTION f_mantdiario_desti(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 4;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR psperson IS NULL
          OR pctipdes IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, sperson, ctipdes)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, psperson, pctipdes);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario_desti;

--------------------------------------------------------------------
   FUNCTION f_mantdiario_valora(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      pnvalora IN NUMBER)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 5;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR pcgarant IS NULL
          OR pnvalora IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, cgarant, nvalora)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, pcgarant, pnvalora);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario_valora;

--------------------------------------------------------------------
   FUNCTION f_mantdiario_pagosini(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      pcestado IN NUMBER,
      psperson IN NUMBER)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 6;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR psidepag IS NULL
          OR pcestado IS NULL
          OR psperson IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, sidepag, cestado,
                   sperson)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, psidepag, pcestado,
                   psperson);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario_pagosini;

--------------------------------------------------------------------
   FUNCTION f_mantdiario_pagogaran(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      psidepag IN NUMBER)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 7;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR pcgarant IS NULL
          OR psidepag IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, cgarant, sidepag)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, pcgarant, psidepag);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario_pagogaran;

--------------------------------------------------------------------
   FUNCTION f_mantdiario_diarioprof(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pnlinpro IN NUMBER,
      pcestado IN NUMBER)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 8;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR psperson IS NULL
          OR pctipdes IS NULL
          OR pnlinpro IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, sperson, nlinpro,
                   cestado)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, psperson, pnlinpro,
                   pcestado);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario_diarioprof;

--------------------------------------------------------------------
   FUNCTION f_mantdiario_dano(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      pnlintra       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pclintra       NUMBER := 9;
   BEGIN
-- control de paso correcto de parametros
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR pndano IS NULL
          OR pcidioma IS NULL) THEN
         RAISE no_nul;
      END IF;

      res := pac_sin.f_newnlintra(pnsinies, pntramit, pnlintra);

      INSERT INTO diariotramitacion
                  (nsinies, ntramit, nlintra, flintra, clintra, ndano)
           VALUES (pnsinies, pntramit, pnlintra, f_sysdate, pclintra, pndano);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiario_dano;

--------------------------------------------------------------------
   FUNCTION f_newnlintra(pnsinies IN NUMBER, pntramit IN NUMBER, pnlintra OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(MAX(nlintra) + 1, 1)
        INTO pnlintra
        FROM diariotramitacion
       WHERE nsinies = pnsinies
         AND ntramit = pntramit;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pnlintra := 1;
         RETURN 0;
      WHEN OTHERS THEN
         pnlintra := 1;
         RETURN SQLCODE;
   END f_newnlintra;

--------------------------------------------------------------------
   FUNCTION f_desglosegarant(psidepag IN NUMBER)
      RETURN NUMBER IS
      psidepagfill   NUMBER;
      no_nul         EXCEPTION;

      CURSOR desgarant IS
         SELECT *
           FROM pagogarantrami
          WHERE sidepag = psidepagfill;
   BEGIN
      IF psidepag IS NULL THEN
         RAISE no_nul;
      END IF;

      SELECT spganul
        INTO psidepagfill
        FROM pagosinitrami
       WHERE sidepag = psidepag;

      FOR dsg IN desgarant LOOP
         INSERT INTO pagogarantrami
                     (cgarant, sidepag, isinret, fperini, fperfin,
                      iimpiva)
              VALUES (dsg.cgarant, psidepag, dsg.isinret, dsg.fperini, dsg.fperfin,
                      dsg.iimpiva);
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_desglosegarant;

--------------------------------------------------------------------
   FUNCTION f_provisio(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      provisio OUT NUMBER)
      RETURN NUMBER IS
      aux            NUMBER;
      valoracio      NUMBER;
      pagos          NUMBER;
   BEGIN
      aux := f_valoracio(pnsinies, pntramit, pcgarant, pdata, valoracio);

      IF aux <> 0 THEN
         RETURN aux;
      END IF;

      aux := f_pagos(pnsinies, pntramit, pcgarant, pdata, pagos);

      IF aux <> 0 THEN
         RETURN aux;
      END IF;

      provisio := valoracio - pagos;
      RETURN 0;
   END f_provisio;

--------------------------------------------------------------------
   FUNCTION f_iconiva(psidepag IN NUMBER, piconiva OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(SUM(isinret - iimpiva), 0)
        INTO piconiva
        FROM pagosinitrami
       WHERE sidepag = psidepag
         AND iimpiva >= 0;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         piconiva := 0;
         RETURN 0;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_iconiva;

--------------------------------------------------------------------
   FUNCTION f_iretenc(ppretenc IN NUMBER, piconret IN NUMBER, piretenc OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      piretenc := f_round(piconret * ppretenc / 100);
      RETURN 0;
   END f_iretenc;

--------------------------------------------------------------------
   FUNCTION f_ins_destinatrami(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pcactpro IN NUMBER,
      pcrefsin IN NUMBER)
      RETURN NUMBER IS
      aux            NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO aux
        FROM destinatrami
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND sperson = psperson
         AND ctipdes = pctipdes;

      IF aux = 0 THEN
         INSERT INTO destinatrami
                     (nsinies, ntramit, sperson, ctipdes, cpagdes, cactpro, crefsin)
              VALUES (pnsinies, pntramit, psperson, pctipdes, pcpagdes, pcactpro, pcrefsin);

         aux := pac_sinitrami.f_ins_destinatarios(pnsinies, pntramit, psperson, pctipdes,
                                                  pcpagdes, pcactpro, pcrefsin);
         RETURN aux;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_ins_destinatrami;

--------------------------------------------------------------------
   FUNCTION f_peticiodoc(pnsinies IN NUMBER, pntramit IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER IS
      pnlinpro       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
      pcactpro       NUMBER;
   BEGIN
-- control de paso correcto de parametros
      IF (psperson IS NULL
          OR pnsinies IS NULL
          OR pntramit IS NULL) THEN
         RAISE no_nul;
      END IF;

      SELECT cactpro
        INTO pcactpro
        FROM destinatrami
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND sperson = psperson
         AND ctipdes = 2;

      IF (pcactpro = 15) THEN
         res := f_mantdiarioprof(psperson, 2, pnsinies, pntramit, 1, 1, 1, 'Alsin016');
      ELSIF(pcactpro = 19) THEN
         res := f_mantdiarioprof(psperson, 2, pnsinies, pntramit, 1, 1, 1, 'Alsin015');
      END IF;

      IF (res <> 0) THEN
         RETURN res;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_peticiodoc;

--------------------------------------------------------------------
   FUNCTION f_mantdiarioprof(
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      ptiplin IN NUMBER,
      pcestado IN NUMBER,
      pcforenv IN NUMBER,
      ptdocume IN VARCHAR)
      RETURN NUMBER IS
      pnlinpro       NUMBER;
      no_nul         EXCEPTION;
      res            NUMBER;
   BEGIN
-- control de paso correcto de parametros
      IF (psperson IS NULL
          OR pctipdes IS NULL
          OR pnsinies IS NULL
          OR pntramit IS NULL
          OR ptiplin IS NULL
          OR pcestado IS NULL
          OR pcforenv IS NULL
          OR ptdocume IS NULL) THEN
         RAISE no_nul;
      END IF;

      BEGIN
         SELECT NVL(MAX(nlinpro) + 1, 1)
           INTO pnlinpro
           FROM diarioproftrami
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pnlinpro := 1;
      END;

      INSERT INTO diarioproftrami
                  (sperson, ctipdes, nlinpro, nsinies, ntramit, ctiplin, cestado,
                   cforenv, tdocume)
           VALUES (psperson, pctipdes, pnlinpro, pnsinies, pntramit, ptiplin, pcestado,
                   pcforenv, ptdocume);

      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_mantdiarioprof;

--------------------------------------------------------------------
   FUNCTION f_tramitautomac(pnsinies IN NUMBER)
      RETURN NUMBER IS
      aux            NUMBER;
      vcaseta        NUMBER;
      vcideasc       NUMBER;
      vcramo         NUMBER;
   BEGIN
      -- Tramitació genèrica
      aux := pac_sin.f_insert_tramita(pnsinies, 0);

      IF aux <> 0 THEN
         RETURN aux;
      END IF;

      -- Convenis
      SELECT caseta, cideasc, cramo
        INTO vcaseta, vcideasc, vcramo
        FROM siniestros
       WHERE nsinies = pnsinies;

      IF vcideasc = 1 THEN
         aux := pac_sin.f_insert_tramita(pnsinies, 1);

         IF aux <> 0 THEN
            RETURN aux;
         END IF;

         aux := pac_sin.f_insert_tramita(pnsinies, 2);

         IF aux <> 0 THEN
            RETURN aux;
         END IF;
      END IF;

      IF vcaseta = 1 THEN
         aux := pac_sin.f_insert_tramita(pnsinies, 9);

         IF aux <> 0 THEN
            RETURN aux;
         END IF;
      END IF;

      RETURN 0;
   END f_tramitautomac;

--------------------------------------------------------------------
   FUNCTION f_insert_tramita(pnsinies IN NUMBER, pctramit IN NUMBER)
      RETURN NUMBER IS
      vntramit       NUMBER;
      vctraint       VARCHAR2(20);
   BEGIN
      BEGIN
         SELECT NVL(MAX(ntramit) + 1, 0)
           INTO vntramit
           FROM tramitacionsini
          WHERE nsinies = pnsinies;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vntramit := 0;
      END;

      BEGIN
         SELECT ctraint
           INTO vctraint
           FROM siniestros
          WHERE nsinies = pnsinies;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vctraint := NULL;
      END;

      INSERT INTO tramitacionsini
                  (nsinies, ntramit, ctramit, cestado, ctraint)
           VALUES (pnsinies, vntramit, pctramit, 0, vctraint);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin.f_insert_tramita', NULL,
                     'parametros: pnsinies =' || pnsinies || '  pctramit =' || pctramit
                     || '  vntramit =' || vntramit || '  vctraint = ' || vctraint,
                     SQLERRM);
         RETURN SQLCODE;
   END f_insert_tramita;

----------------------------------------------------------------------------------
   FUNCTION f_valoracio_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      valoracio OUT NUMBER)
      RETURN NUMBER IS
      v_sseguro      seguros.sseguro%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_fnotifi      siniestros.fnotifi%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cvalpar      pargaranpro.cvalpar%TYPE;
      v_error        NUMBER;
   BEGIN
      -- Bug 8744 - 03/03/2009 - JRB - Se cambia la forma de recuperar la valoración cuando el producto es baja
      -- Bug 9685 - APD - 11/05/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      SELECT seg.sseguro, sproduc, pac_seguros.ff_get_actividad(SIN.sseguro, SIN.nriesgo),
             SIN.fnotifi, seg.cramo, seg.cmodali, seg.ctipseg, seg.ccolect, seg.cactivi
        INTO v_sseguro, v_sproduc, v_cactivi,
             v_fnotifi, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
        FROM seguros seg, siniestros SIN
       WHERE SIN.nsinies = pnsinies
         AND seg.sseguro = SIN.sseguro;

      -- Bug 9685 - APD - 11/05/2009 - fin
      v_error := f_pargaranpro(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, pcgarant,
                               'BAJA', v_cvalpar);

      IF NVL(v_cvalpar, 0) <> 1 THEN
         SELECT NVL(v1.ivalora, 0)
           INTO valoracio
           FROM valorasini v1
          WHERE v1.nsinies = pnsinies
            AND v1.cgarant = pcgarant
            AND v1.fvalora = (SELECT MAX(fvalora)
                                FROM valorasini v2
                               WHERE v2.nsinies = v1.nsinies
                                 AND v2.cgarant = v1.cgarant
                                 AND(pdata IS NULL
                                     OR TRUNC(v2.fvalora) <= pdata));
      ELSE
         SELECT NVL(SUM(NVL(v1.ivalora, 0)), 0)
           INTO valoracio
           FROM valorasini v1
          WHERE v1.nsinies = pnsinies
            AND v1.cgarant = pcgarant
            AND v1.fperini <= pdata;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         valoracio := 0;
         RETURN 101667;
      WHEN OTHERS THEN
         valoracio := 0;
         RETURN SQLCODE;
   END f_valoracio_sini;

   -- Bug 8744 - 03/03/2009 - JRB - Se añaden las fechas de inicio y fin para el cálculo de los pagos
---------------------------------------------------------------------------------
   FUNCTION f_pagos_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      pagos OUT NUMBER,
      plevelpag IN NUMBER DEFAULT 0,
      pfperini IN DATE DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(SUM(DECODE(s.ctippag, 2, g.isinret, 8, g.isinret, g.isinret * -1)), 0)
        INTO pagos
        FROM pagosini s, pagogarantia g
       WHERE s.sidepag = g.sidepag
         AND s.nsinies = pnsinies
         AND(pdata IS NULL
             OR s.fordpag <= pdata)
         AND g.cgarant = pcgarant
         AND s.cestpag <> 8
         AND s.cestpag >= plevelpag
         AND((s.fperini >= pfperini
              OR pfperini IS NULL)
             AND(s.fperfin <= pfperfin
                 OR pfperfin IS NULL));

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pagos := 0;
         RETURN 101667;
      WHEN OTHERS THEN
         pagos := 0;
         RETURN SQLCODE;
   END f_pagos_sini;

-- Bug 8744 - 03/03/2009 - JRB - Se crea la funcion de pago automático
/*************************************************************************
   FUNCTION f_pago_aut
   Crea un pago automático
   param in pdata   : fecha final de pago
   return             : código de error
*************************************************************************/
   FUNCTION f_pago_aut(p_data IN DATE)
      RETURN NUMBER IS
      CURSOR c_sinies IS
         -- Bug 9685 - APD - 11/05/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT   s.fsinies, s.nsinies, v.cgarant, v.fvalora, s.falta, s.sseguro, s.ccausin,
                  s.cmotsin, s.fnotifi, s.nriesgo, sg.sproduc,
                  pac_seguros.ff_get_actividad(s.sseguro, s.nriesgo) cactivi, v.fultpag,
                  v.fperini, v.fperfin, v.ivalora, pr.nnumpag, sg.cbancar,
                  sg.ctipban   -- BUG10581:DRA:30/06/2009
             FROM siniestros s, valorasini v, seguros sg, productos pr
            WHERE s.cestsin = 0
              AND s.nsubest = 27
              AND s.nsinies = v.nsinies
              AND s.sseguro = sg.sseguro
              AND pr.cramo = sg.cramo
              AND pr.ctipseg = sg.ctipseg
              AND pr.ccolect = sg.ccolect
              AND pr.cmodali = sg.cmodali
              AND(p_data BETWEEN v.fperini AND v.fperfin
                  OR(p_data >= v.fperfin
                     AND NVL(v.fultpag, v.fperfin - 1) <> v.fperfin))
              AND NVL(v.fultpag, v.fperini - 1) < p_data
         ORDER BY s.nsinies ASC;

      -- Bug 9685 - APD - 11/05/2009 - fin
      v_cgarant      valorasini.cgarant%TYPE;
      v_error        literales.slitera%TYPE;
      v_provisio     valorasini.ivalora%TYPE;
      v_fperini      DATE;
      v_fperfin      DATE;
      v_destinatario NUMBER;
      v_ctipdes      destipermisin.cdestin%TYPE;
      --etm ini
      v_movimi       NUMBER(4);
      v_ccc          VARCHAR2(4000);
      n_error        NUMBER;
      --etm fin
      v_ctipban      destinatarios.ctipban%TYPE;   -- BUG10581:DRA:30/06/2009
   BEGIN
      FOR sini IN c_sinies LOOP
         v_error := f_provisio_sini(sini.nsinies, sini.cgarant, p_data, v_provisio);

         IF v_error = 0 THEN
            IF v_provisio > 0
               AND sini.fperini <= sini.fperfin THEN
               IF sini.fultpag IS NULL THEN
                  v_fperini := sini.fperini;
               ELSE
                  v_fperini := sini.fultpag + 1;
               END IF;

               IF sini.fperfin <= p_data THEN
                  v_fperfin := sini.fperfin;
               ELSE
                  v_fperfin := p_data;
               END IF;

               SELECT COUNT(1)
                 INTO v_destinatario
                 FROM destinatarios
                WHERE nsinies = sini.nsinies;

               IF v_destinatario = 0 THEN
                  SELECT DISTINCT (cdestin)
                             INTO v_ctipdes
                             FROM destipermisin
                            WHERE cdestin <> 0
                              AND sprcamosin IN(SELECT sprcamosin
                                                  FROM prodcaumotsin
                                                 WHERE sproduc = sini.sproduc
                                                   AND cgarant = sini.cgarant
                                                   AND cactivi = sini.cactivi
                                                   AND ccausin = sini.ccausin
                                                   AND cmotsin = sini.cmotsin);

                  -- BUG14289:DRA:03/05/2010:Inici
                  -- bug 0010266: etm : 02-06-2009--INI
                  --SELECT MAX(nmovimi)
                  --  INTO v_movimi
                  --  FROM movseguro
                  -- WHERE sseguro = sini.sseguro;

                  -- BUG10581:DRA:30/06/2009:Inici
                  v_ccc := NULL;
                  v_ctipban := NULL;

                  -- BUG10581:DRA:30/06/2009:Fi

                  --esta respondida la pregun
                  BEGIN
                     SELECT p.trespue
                       INTO v_ccc
                       FROM pregunpolseg p
                      WHERE p.sseguro = sini.sseguro
                        AND p.cpregun = 9001
                        AND p.nmovimi = (SELECT MAX(p1.nmovimi)
                                           FROM pregunpolseg p1
                                          WHERE p1.sseguro = p.sseguro
                                            AND p1.cpregun = p.cpregun);
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_ccc := NULL;
                        v_ctipban := NULL;
                  END;

                  -- BUG10581:DRA:30/06/2009:Inici
                  IF v_ccc IS NOT NULL THEN
                     BEGIN
                        SELECT p.crespue
                          INTO v_ctipban
                          FROM pregunpolseg p
                         WHERE p.sseguro = sini.sseguro
                           AND p.cpregun = 9000
                           AND p.nmovimi = (SELECT MAX(p1.nmovimi)
                                              FROM pregunpolseg p1
                                             WHERE p1.sseguro = p.sseguro
                                               AND p1.cpregun = p.cpregun);
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_ctipban := NULL;
                     END;
                  END IF;

                  -- BUG14289:DRA:03/05/2010:Fi

                  -- BUG10581:DRA:30/06/2009:Fi

                  -- bug 0010266: etm : 02-06-2009--FIN
                  v_error :=
                     pac_sin_insert.f_insert_destinatarios
                                                  (sini.nsinies, sini.sseguro, sini.nriesgo,
                                                   sini.nnumpag, v_ctipdes, 1, sini.ivalora,
                                                   NULL,   /*etm ini*/
                                                   NVL(v_ccc /*etm fin*/, sini.cbancar), NULL,
                                                   NVL(v_ctipban, sini.ctipban),   -- BUG10581:DRA:30/06/2009
                                                   NULL);

                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               END IF;

               v_error := pk_cal_sini.gen_pag_sini(sini.fsinies, sini.sseguro, sini.nsinies,
                                                   sini.sproduc, sini.cactivi, sini.ccausin,
                                                   sini.cmotsin, sini.fnotifi, sini.nriesgo,
                                                   v_fperini, v_fperfin);
               v_error := pk_cal_sini.insertar_pagos(sini.nsinies);

               IF v_error = 0 THEN
                  UPDATE valorasini
                     SET fultpag = LEAST(v_fperfin, fperfin)
                   WHERE nsinies = sini.nsinies
                     AND cgarant = sini.cgarant
                     AND(v_fperini BETWEEN fperini AND fperfin
                         OR v_fperfin BETWEEN fperini AND fperfin);
               ELSE
                  RETURN v_error;
               END IF;
            END IF;
         ELSE
            RETURN v_error;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 101667;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_pago_aut;

---------------------------------------------------------------------------------
   FUNCTION f_provisio_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      provisio OUT NUMBER,
      plevelpag IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      aux            NUMBER;
      valoracio      NUMBER;
      pagos          NUMBER;
   BEGIN
      aux := f_valoracio_sini(pnsinies, pcgarant, pdata, valoracio);

      IF aux <> 0 THEN
         RETURN aux;
      END IF;

      aux := f_pagos_sini(pnsinies, pcgarant, pdata, pagos, plevelpag);

      IF aux <> 0 THEN
         RETURN aux;
      END IF;

      provisio := valoracio - pagos;
      RETURN 0;
   END f_provisio_sini;

---------------------------------------------------------------------------------
   FUNCTION f_insctactescia(psidepag IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER IS
      xcempres       NUMBER(2);
      xccompani      NUMBER(3);
      xnnumlin       NUMBER(6);
   BEGIN
      -- Recupera la empresa y la compañía.
      BEGIN
         SELECT a.cempres, NVL(a.ccompani, b.ccompani)
           INTO xcempres, xccompani
           FROM seguros a, productos b
          WHERE a.cramo = b.cramo
            AND a.ctipseg = b.ctipseg
            AND a.cmodali = b.cmodali
            AND a.ccolect = b.ccolect
            AND a.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101919;   -- Error al llegir dades de la taula SEGUROS
      END;

      -- Recuperar el siguiente número de línea.
      BEGIN
         SELECT NVL(MAX(nnumlin), 0) + 1
           INTO xnnumlin
           FROM ctactescia
          WHERE ccompani = xccompani
            AND cempres = xcempres;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 110185;   -- Error al llegir de la taula CTACTESCIA
      END;

      -- Se inserta en ctactescia.
      -- cdebhab -> 1: debe.
      -- cconta --> 5: pago siniestros
      -- cestado --> 1: pendiente
      -- cmanual --> 0: automático
      INSERT INTO ctactescia
                  (ccompani, nnumlin, cdebhab, cconcta, cestado, ffecmov, iimport, cmanual,
                   cempres, nsinies, sidepag)
         (SELECT xccompani, xnnumlin, DECODE(ctippag, 2, 1, 8, 1, 3, 2, 7, 2, 1), 5, 1,
                 fordpag, isinret, 0, xcempres, nsinies, sidepag
            FROM pagosini
           WHERE sidepag = psidepag);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110187;   -- Error a l' inserir a la taula CTACTESCIA
   END f_insctactescia;

---------------------------------------------------------------------------------
   FUNCTION f_refsiniestro(pnsinies IN NUMBER, pcrefint IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT crefint
        INTO pcrefint
        FROM siniestros
       WHERE nsinies = pnsinies;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pcrefint := pnsinies;
         RETURN 0;
      WHEN OTHERS THEN
         RETURN 105144;   -- Error en la lectura de SINIESTROS.
   END f_refsiniestro;

   FUNCTION f_permite_alta_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      num_err := pac_propio.f_permite_alta_siniestro(psseguro, pnriesgo, pfsinies, pfnotifi,
                                                     pccausin, pcmotsin);
      RETURN num_err;
   END f_permite_alta_siniestro;

/*************************************************************************
   FUNCTION f_accion_siniestro
   Realiza acciones sobre el siniestro
   param in pnsini es   : Siniestro
   paccion :Accion
   pcgarant : Garantia
   return             : código de error
*************************************************************************/
   FUNCTION f_accion_siniestro(
      pnsinies IN NUMBER,
      paccion IN NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
/*paccion: 1-->Estamos en apertura siniestros.
           2-->Estamos en colclusión de siniestro.*/
      paso           NUMBER;
      vcmovseg       NUMBER;
      vcmotmov       NUMBER;
      vcmotfin       NUMBER;
      v_efecto       DATE;
      vnmovimi       NUMBER;
      num_err        NUMBER;
      vsseguro       NUMBER;
      vnriesgo       NUMBER;
      accion         BOOLEAN;
      motivo         NUMBER;
      num_riesgos    NUMBER;
      v_nsuplem      NUMBER;
      v_creteni      NUMBER;
      v_cmotmov      NUMBER;
      vsperson_fallec NUMBER;
      vsperson_vigente NUMBER;
      vfsinies       DATE;
      vcdelega       NUMBER;
      vocoderror     NUMBER;
      vomsgerror     VARCHAR2(2000);
      vedad          NUMBER;
      resc_abierto   NUMBER;
      xccausin       NUMBER;
      vsproduc       NUMBER;
      -- RSC 11/12/2007
      vagente        NUMBER;
      vidiom         NUMBER;
      vsperson2      NUMBER;
      vnorden        NUMBER;
      vcdomici_tom1  NUMBER;
      vcdomici_aseg2 NUMBER;
      -- RSC 25/03/2008
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcmotsin       NUMBER;
      vcgarant       NUMBER;
      virescatep     NUMBER;
      --ICV 28/05/2009
      vnmovsup       movseguro.nmovimi%TYPE;
      vvalora        NUMBER := 0;
      -- Bug 12199 - RSC - 27/11/2009 - 0012199: CRE201 - Incidencia suplemento de anulación de garantía por siniestro
      vfcarpro       DATE;
      -- Fin Bug 12199
      n_primfall     NUMBER;
   BEGIN
      paso := 1;

      SELECT   MAX(cmotmov), MAX(cmotfin), s.sseguro, si.nriesgo, si.ccausin, si.fsinies,
               s.sproduc
          INTO vcmotmov, vcmotfin, vsseguro, vnriesgo, xccausin, vfsinies,
               vsproduc
          FROM prodcaumotsin p, seguros s, siniestros si
         WHERE si.nsinies = pnsinies
           AND si.ccausin = p.ccausin
           AND si.cmotsin = p.cmotsin
           AND si.sseguro = s.sseguro
           AND s.sproduc = p.sproduc
           AND(p.cgarant = pcgarant
               OR pcgarant IS NULL)
      GROUP BY s.sseguro, si.nriesgo, si.ccausin, si.fsinies, s.sproduc;

      -- Bug 13435 - RSC - 05/05/2010 - CRE
      -- Ajuste en el cálculo de la fecha de efecto del suplemento automático (añadimos vfcarpro)
      SELECT npoliza, ncertif, fcarpro
        INTO vnpoliza, vncertif, vfcarpro
        FROM seguros
       WHERE sseguro = vsseguro;

      SELECT usu.cdelega
        INTO vcdelega
        FROM siniestros si, usuarios usu
       WHERE si.cusuari = usu.cusuari
         AND si.nsinies = pnsinies;

      IF paccion = 1
         AND vcmotmov IS NOT NULL THEN   -- apertur siniestro
         accion := TRUE;
         motivo := vcmotmov;
      ELSIF paccion = 2
            AND vcmotfin IS NOT NULL THEN   -- finalización siniestro
         accion := TRUE;
         motivo := vcmotfin;
      ELSIF paccion = 3 THEN   -- rechazo o anulacion siniestro
         accion := TRUE;
         motivo := 111;   -- desretener
      ELSE
         accion := FALSE;
      END IF;

      paso := 2;

      IF accion THEN
         SELECT cmovseg
           INTO vcmovseg
           FROM codimotmov
          WHERE cmotmov = motivo;

         paso := 3;
         v_efecto := TRUNC(f_sysdate);

         IF vcmovseg = 3 THEN   -- movimiento de anulación de póliza
            IF xccausin IN(3, 4, 5) THEN   --vencimientos y rescates
               v_efecto := vfsinies;
            END IF;

            num_err :=
               pac_anulacion.f_anulacion_poliza(vsseguro, motivo,

                                                -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                   --1,
                                                pac_monedas.f_moneda_producto(vsproduc),

                                                -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                v_efecto, 0, 1, NULL, NULL, NULL);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         -- Aqui faltaria cerrar siniestro en caso de estar tratando una siniestro de fallecimiento
         -- de primer titular en una póliza MULTILINK
         ELSIF motivo = 514 THEN   -- anulación de riesgo
             --si hay más de 1 riesgo vigente se anula el riesgo, si sólo hay un riesgo vigente
            -- se anula la póliza
            SELECT COUNT(*)
              INTO num_riesgos
              FROM riesgos
             WHERE sseguro = vsseguro
               AND fanulac IS NULL;

            IF num_riesgos > 1 THEN   -- anulamos el riesgo
               SELECT NVL(nsuplem, 0) + 1
                 INTO v_nsuplem
                 FROM movseguro
                WHERE sseguro = vsseguro
                  AND nmovimi = (SELECT MAX(mm.nmovimi)
                                   FROM movseguro mm
                                  WHERE mm.sseguro = vsseguro);

               num_err := f_movseguro(vsseguro, NULL, motivo, vcmovseg, v_efecto, NULL,
                                      v_nsuplem, 0, NULL, vnmovimi, f_sysdate);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               num_err := f_act_hisseg(vsseguro, vnmovimi - 1);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               num_err := f_anularisc(vsseguro, vnriesgo, v_efecto, vnmovimi, NULL, motivo);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               --Controlamos si la poliza esta retenida por haber generado un siniestro.
               --Recuperamos el numero del seguro
               BEGIN
                  SELECT creteni, cmotmov
                    INTO v_creteni, v_cmotmov
                    FROM seguros s, movseguro m, siniestros si
                   WHERE s.sseguro = m.sseguro
                     AND s.sseguro = si.sseguro
                     AND si.nsinies = pnsinies
                     AND m.nmovimi = (SELECT MAX(nmovimi)
                                        FROM movseguro mm
                                       WHERE mm.sseguro = m.sseguro) - 1
                     AND m.cmotmov IN(SELECT cmotmov
                                        FROM prodcaumotsin p
                                       WHERE si.ccausin = p.ccausin
                                         AND si.cmotsin = p.cmotsin
                                         AND si.sseguro = s.sseguro
                                         AND s.sproduc = p.sproduc);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
               END;

               IF v_creteni = 1 THEN
                  num_err := f_movseguro(vsseguro, NULL, 111, NULL, v_efecto, NULL, NULL, 0,
                                         NULL, vnmovimi, f_sysdate);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            ELSE   -- anulación de póliza
               num_err :=
                  pac_anulacion.f_anulacion_poliza(vsseguro, 505,

                                                   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                   --1,
                                                   pac_monedas.f_moneda_producto(vsproduc),

                                                   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                   v_efecto, 0, 1, NULL, NULL, NULL);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         ELSIF vcmovseg = 10 THEN   -- retener póliza
            -- Bug 13435 - RSC - 05/05/2010 - CRE
            IF vfcarpro IS NULL THEN
               -- Ajuste en el cálculo de la fecha de efecto del suplemento automático (LEAST(v_efecto, vfcarpro))
               num_err := f_movseguro(vsseguro, NULL, motivo, vcmovseg, v_efecto, NULL, NULL,
                                      0, NULL, vnmovimi, f_sysdate);
            ELSE
               -- Ajuste en el cálculo de la fecha de efecto del suplemento automático (LEAST(v_efecto, vfcarpro))
               num_err := f_movseguro(vsseguro, NULL, motivo, vcmovseg,
                                      LEAST(v_efecto, vfcarpro), NULL, NULL, 0, NULL,
                                      vnmovimi, f_sysdate);
            END IF;

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSIF vcmovseg = 11 THEN   -- desretener póliza
            --Controlamos si la poliza esta retenida por haber generado un siniestro.
            --Recuperamos el numero del seguro

            --Controlamos si la poliza esta retenida por haber generado un siniestro.
            BEGIN
               SELECT creteni, cmotmov, fcarpro
                 INTO v_creteni, v_cmotmov, vfcarpro
                 FROM seguros s, movseguro m, siniestros si
                WHERE s.sseguro = m.sseguro
                  AND s.sseguro = si.sseguro
                  AND si.nsinies = pnsinies
                  AND m.nmovimi = (SELECT MAX(nmovimi)
                                     FROM movseguro mm
                                    WHERE mm.sseguro = m.sseguro)
                  AND m.cmotmov IN(SELECT cmotmov
                                     FROM prodcaumotsin p
                                    WHERE si.ccausin = p.ccausin
                                      AND si.cmotsin = p.cmotsin
                                      AND si.sseguro = s.sseguro
                                      AND s.sproduc = p.sproduc);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;

            IF v_creteni = 1 THEN
               -- Bug 13435 - RSC - 05/05/2010 - CRE
               IF vfcarpro IS NULL THEN
                  -- Ajuste en el cálculo de la fecha de efecto del suplemento automático (LEAST(v_efecto, vfcarpro))
                  num_err := f_movseguro(vsseguro, NULL, motivo, NULL, v_efecto, NULL, NULL,
                                         0, NULL, vnmovimi, f_sysdate);
               ELSE
                  -- Ajuste en el cálculo de la fecha de efecto del suplemento automático (LEAST(v_efecto, vfcarpro))
                  num_err := f_movseguro(vsseguro, NULL, motivo, NULL,
                                         LEAST(v_efecto, vfcarpro), NULL, NULL, 0, NULL,
                                         vnmovimi, f_sysdate);
               END IF;

               -- Fi Bug 13435 - RSC - 11/03/2010 - JRH
               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         ELSIF motivo = 265 THEN   -- suplemento Fallecimiento de un Titular
            -- Si la póliza no tiene un rescate
            -- (para el caso de las pólizas de migración que
            -- se abre el siniestro de baja de fallec. ene l momento de hacer el rescate.
            -- En este caso no queremos que haga el suplemento)
            num_err := pac_rescates.f_rescate_total_abierto(vsseguro, resc_abierto);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            IF resc_abierto = 0 THEN
               -- Se realiza el suplemento
               -- Bug 15869 - 20/09/2010 - JRH - Rentas CIV 2 cabezas
               --IF NVL(f_parproductos_v(vsproduc, '2_CABEZAS'), 0) = 1 THEN
               IF NVL(f_parproductos_v(vsproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
                  SELECT sperson
                    INTO vsperson_fallec
                    FROM siniestros si, asegurados aseg
                   WHERE si.sseguro = aseg.sseguro
                     AND si.nasegur = aseg.norden
                     AND si.nsinies = pnsinies;

                  -- ini Bug 0012822 - 24/02/2010 - JMF
                  SELECT COUNT(1)
                    INTO n_primfall
                    FROM tomadores
                   WHERE sseguro = vsseguro
                     AND sperson = vsperson_fallec;
               -- fin Bug 0012822 - 24/02/2010 - JMF
               END IF;

-- Fi Bug 15869 - 20/09/2010
               num_err := pac_ref_contrata_comu.f_suplemento_fall_asegurado(vsseguro,
                                                                            TRUNC(f_sysdate),
                                                                            vsperson_fallec,
                                                                            vfsinies, vcdelega,
                                                                            NULL, f_idiomauser,
                                                                            0, vocoderror,
                                                                            vomsgerror);

               IF num_err IS NULL THEN   -- Ha habido algún error
                  RETURN vocoderror;
               END IF;

               -- Se actualiza el campo siniestros.nmovimi con el número de movimiento del suplemento realizado
               SELECT MAX(nmovimi)
                 INTO vnmovimi
                 FROM movseguro
                WHERE sseguro = vsseguro;

               UPDATE siniestros
                  SET nmovimi = vnmovimi
                WHERE nsinies = pnsinies;

               -- Si el asegurado que queda vigente es menor de edad la póliza debe quedar retenida
               SELECT sperson
                 INTO vsperson_vigente
                 FROM asegurados
                WHERE sseguro = vsseguro
                  AND ffecfin IS NULL;

               IF n_primfall > 0
                  AND NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                        'RETIENE_POLIZA'),
                          0) = 0 THEN
                  num_err := pac_emision_mv.f_retener_poliza('SEG', vsseguro, 1, vnmovimi, 6,
                                                             1, TRUNC(f_sysdate));

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               --RETURN 180456; -- El titular que queda vigente es menor de edad. La póliza quedará retenida. Consulte con la Cía.
               END IF;

               vedad := fedadaseg(0, vsperson_vigente, TO_CHAR(f_sysdate, 'YYYYMMDD'), 2);

               IF vedad < 18 THEN
                  num_err := pac_emision_mv.f_retener_poliza('SEG', vsseguro, 1, vnmovimi, 4,
                                                             1, TRUNC(f_sysdate));

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               --RETURN 180456; -- El titular que queda vigente es menor de edad. La póliza quedará retenida. Consulte con la Cía.
               END IF;
            END IF;
         ELSIF motivo = 510 THEN   -- Al abrir siniestro realizar el Rescate (Multilink)
            -- RSC 11/12/2007
            num_err := f_constar_fallecimiento(vsseguro, vsproduc, pnsinies, vfsinies);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            --  El único producto que tendrá parametrizado este motivo(510) al abrir un siniestro será MULTILINK.
            --  Por tanto preveo que por esta rama solo se entrará cuando se produzca un Fallecimiento de primer
            --  asegurado en el producto MultiLink de 2_cabezas.
            -- Realizamos la solicitud de rescate (aquellos que tengan motivo 510 como acción al abrir)
            SELECT cagente, cidioma
              INTO vagente, vidiom
              FROM seguros
             WHERE sseguro = vsseguro;

            --num_err := PUB_SINIES_ULK.f_sol_rescate_total(vsseguro, vagente, vfsinies, vidiom, F_IdiomaUser,  NULL, voCODERROR, voMSGERROR);
            num_err := pac_ref_sinies_ulk.f_sol_rescate_total(vsseguro, vagente,
                                                              TRUNC(f_sysdate), vidiom,
                                                              f_idiomauser, NULL, vocoderror,
                                                              vomsgerror);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSIF motivo = 550 THEN
            -- Obtener de valorasini la valoracion del siniestro para saber el importe
            -- del rescate y pasarselo a la función PUB_CONTRATA_COMU.f_suplemento_rescate_parcial
            SELECT cmotsin
              INTO vcmotsin
              FROM siniestros
             WHERE nsinies = pnsinies;

            SELECT cgarant
              INTO vcgarant
              FROM prodcaumotsin
             WHERE sproduc = vsproduc
               AND ccausin = xccausin
               AND cmotsin = vcmotsin;

            SELECT icaprisc
              INTO virescatep
              FROM valorasini v
             WHERE nsinies = pnsinies
               AND cgarant = vcgarant
               AND fvalora = (SELECT MAX(fvalora)
                                FROM valorasini
                               WHERE nsinies = pnsinies
                                 AND cgarant = vcgarant);

            -- Bug 12136 - JRH - 11/03/2010 - JRH - Desretener antes la póliza si hace falta
            BEGIN
               SELECT creteni, cmotmov
                 INTO v_creteni, v_cmotmov
                 FROM seguros s, movseguro m, siniestros si
                WHERE s.sseguro = m.sseguro
                  AND s.sseguro = si.sseguro
                  AND si.nsinies = pnsinies
                  AND m.nmovimi = (SELECT MAX(nmovimi)
                                     FROM movseguro mm
                                    WHERE mm.sseguro = m.sseguro)
                  AND m.cmotmov IN(SELECT cmotmov
                                     FROM prodcaumotsin p
                                    WHERE si.ccausin = p.ccausin
                                      AND si.cmotsin = p.cmotsin
                                      AND si.sseguro = s.sseguro
                                      AND s.sproduc = p.sproduc);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;

            IF v_creteni = 1 THEN
               --num_err := f_movseguro(vsseguro, NULL, 111, NULL, vfsinies, NULL, NULL, 0,
                --                      NULL, vnmovimi, f_sysdate);
               UPDATE seguros
                  SET creteni = 0
                WHERE sseguro = vsseguro;   --JRH Sera el rescate parcial el que lo active.
            --IF num_err <> 0 THEN
            --   RETURN num_err;
            --END IF;
            END IF;

            -- Fi Bug 12136 - JRH - 11/03/2010

            -- Retarificación de la póliza para actualizar provisiones, etc
            num_err := pac_ref_contrata_comu.f_suplemento_rescate_parcial(vnpoliza, vncertif,
                                                                          TRUNC(vfsinies),
                                                                          virescatep, vcdelega,
                                                                          NULL, f_idiomauser,
                                                                          0, vocoderror,
                                                                          vomsgerror);

            IF num_err IS NULL THEN   -- Ha habido algún error
               RETURN vocoderror;
            END IF;

            -- Se actualiza el campo siniestros.nmovimi con el número de movimiento del suplemento realizado
            SELECT MAX(nmovimi)
              INTO vnmovimi
              FROM movseguro
             WHERE sseguro = vsseguro;

            UPDATE siniestros
               SET nmovimi = vnmovimi
             WHERE nsinies = pnsinies;
         /****************************************************************
         (*) Dado que la función de tarificación de productos con EVOLUPROVMATSEG
             tiene en cuenta años enteros con la fecha de efecto de la póliza, al
             solicitar un rescate parcial en cualquier momento esta tarificación
             generará unos valores desviados. Quedará pendiente analizar el problema
             y ver qué tramos o imporets grabar en EVOLUPROVMATSEG. Queda abierto
             también la respuesta que nos diga Sa Nostra al respecto de este tema.
         *****************************************************************/--Ini Bug.: 8947 - 28/05/09 - ICV - Gestión de Cobertura Enfermedad Grave
         ELSIF motivo = 516 THEN
            --Controlamos si la poliza esta retenida por haber generado un siniestro.
            SELECT creteni, fcarpro
              INTO v_creteni, vfcarpro
              FROM seguros
             WHERE sseguro = vsseguro;

            IF v_creteni = 1 THEN   --Desretenemos para generar el suplemento
               UPDATE seguros
                  SET creteni = 0
                WHERE sseguro = vsseguro;
            END IF;

            SELECT cmotsin
              INTO vcmotsin
              FROM siniestros
             WHERE nsinies = pnsinies;

            SELECT cgarant
              INTO vcgarant
              FROM prodcaumotsin
             WHERE sproduc = vsproduc
               AND ccausin = xccausin
               AND cmotsin = vcmotsin;

            SELECT COUNT('1')
              INTO vvalora
              FROM valorasini v
             WHERE nsinies = pnsinies
               AND cgarant = vcgarant
               AND fvalora = (SELECT MAX(fvalora)
                                FROM valorasini
                               WHERE nsinies = pnsinies
                                 AND cgarant = vcgarant);

            IF vvalora = 0 THEN   --Si no tiene valoración devolvemos error
               p_tab_error(f_sysdate, getuser, 'pac_sin.f_accion_siniestro', 2,
                           'pnsinies :' || pnsinies || ' vcgarant :' || vcgarant, SQLERRM);
               RETURN 102784;
            END IF;

            -- Bug 12199 - RSC - 27/11/2009 - 0012199: CRE201 - Incidencia suplemento de anulación de garantía por siniestro
            --Generamos el suplemento por vto_garantia (tiene en cuenta gar. dependientes)
            num_err := pac_sup_general.f_supl_vto_garantia(vsseguro, vnriesgo, vfcarpro,
                                                           motivo, vcgarant, vnmovsup, NULL);

            -- Fin Bug 12199
            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            -- Se actualiza el campo siniestros.nmovimi con el número de movimiento del suplemento realizado
            SELECT MAX(nmovimi)
              INTO vnmovimi
              FROM movseguro
             WHERE sseguro = vsseguro;

            UPDATE siniestros
               SET nmovimi = vnmovimi
             WHERE nsinies = pnsinies;
         --Fi Bug.: 8947
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, getuser, 'pac_sin.f_accion_siniestro', paso,
                     'error no controlat', SQLERRM);
         RETURN 140999;
   END f_accion_siniestro;

-----------------------------------------------------------------------------------

   /*
     Función que realiza o deja la constancia del fallecimiento del asegurado.
    Solo se utiliza en el contecto de fallecimiento del 1er asegurado en seguro 2 Cabezas.
    Parte de esta modificación ya se hace en f_inicializar_siniestro.
   */
   FUNCTION f_constar_fallecimiento(
      vsseguro IN NUMBER,
      vsproduc IN NUMBER,
      pnsinies IN NUMBER,
      vfsinies IN DATE)
      RETURN NUMBER IS
      vsperson_fallec NUMBER;
      vsperson2      NUMBER;
      vcdomici_tom1  NUMBER;
      vcdomici_aseg2 NUMBER;
      vnorden        NUMBER;
      num_err        NUMBER;
	  /* Cambios de  tarea IAXIS-13044 :START */
	  VPERSON_NUM_ID per_personas.nnumide%type;
	  /* Cambios de  tarea IAXIS-13044 :START */
							
   BEGIN
      --Realizamos la baja del asegurado fallecido (producción_comu.f_cambio_fall_asegurado)
      IF NVL(f_parproductos_v(vsproduc, '2_CABEZAS'), 0) = 1 THEN
         SELECT sperson
           INTO vsperson_fallec
           FROM siniestros si, asegurados aseg
          WHERE si.sseguro = aseg.sseguro
            AND si.nasegur = aseg.norden
            AND si.nsinies = pnsinies;
      END IF;

      -- Modificar los campos ESTASSEGURATS.FFECFIN y ESTASSEGURATS.FFECMUE con la fecha de fallecimiento
      UPDATE asegurados
         SET ffecfin = vfsinies,
             ffecmue = vfsinies
       WHERE sseguro = vsseguro
         AND sperson = vsperson_fallec
         AND ffecfin IS NULL;   -- BUG11183:DRA:23/09/2009

      -- Se marca la persona como Fallecida
      UPDATE per_personas
         SET cestper = 2   -- Fallecida
       WHERE sperson = vsperson_fallec;

      -- Se da de baja la garantía de cobertura adicional de fallecimiento o accidentes si la tuviera contratada
      SELECT norden
        INTO vnorden
        FROM asegurados
       WHERE sseguro = vsseguro
         AND sperson = vsperson_fallec;

      -- Modificar el tomador del seguro si el asegurado fallecido es el primer titular
      IF vnorden = 1 THEN   -- la persona fallecida es el primer titular
         -- Se busca el sperson del segundo asegurado
         SELECT sperson
           INTO vsperson2
           FROM asegurados
          WHERE sseguro = vsseguro
            AND norden = 2;

         -- Se busca la direccion del contrato
         SELECT cdomici
           INTO vcdomici_tom1
           FROM tomadores
          WHERE sseguro = vsseguro
            AND sperson = vsperson_fallec;

         -- Se comprueba si la dirección del contrato (dirección del tomador) ya existe en las direcciones del asegurado 2
         num_err := pac_personas.f_valida_misma_direccion(vsperson_fallec, vcdomici_tom1,
                                                          vsperson2, vcdomici_aseg2);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF vcdomici_aseg2 IS NULL THEN   -- No existe la dirección del contrato entre las direcciones del asegurado 2
            -- Se busca la dirección del asegurado vigente (en este caso es el segundo titular)
            BEGIN
               SELECT MAX(cdomici) + 1
                 INTO vcdomici_aseg2
                 FROM direcciones
                WHERE sperson = vsperson2;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcdomici_aseg2 := 1;
               WHEN OTHERS THEN
                  RETURN 104474;   -- Error al leer de la tabla DIRECCIONES
            END;

            -- Se inserta la dirección del titular fallecido en las direcciones del segundo titular
            -- Bug 18940/92686 - 28/09/2011 - AMC
            INSERT INTO per_direcciones
                        (sperson, cagente, cdomici, ctipdir, csiglas, tnomvia, nnumvia,
                         tcomple, tdomici, cpostal, cpoblac, cprovin, cusuari, fmovimi, cviavp,
                         clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                         cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia)
               (SELECT vsperson2, cagente, vcdomici_aseg2, ctipdir, csiglas, tnomvia, nnumvia,
                       tcomple, tdomici, cpostal, cpoblac, cprovin, f_user, f_sysdate, cviavp,
                       clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                       cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia
                  FROM per_direcciones
                 WHERE sperson = vsperson_fallec
                   AND cdomici = vcdomici_tom1);

                   --INI 1554 CESS
	/* Cambios de  tarea IAXIS-13044 :START */
       BEGIN
         SELECT PP.NNUMIDE
           INTO VPERSON_NUM_ID
           FROM PER_PERSONAS PP
          WHERE PP.SPERSON = VSPERSON_FALLEC;
       
         PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                           1,
                                           'S03502',
                                           NULL);
       				EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_SIN.f_constar_fallecimiento',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			    END;		
    /* Cambios de  tarea IAXIS-13044 :END */
--END 1554 CESS

         -- Fi Bug 18940/92686 - 28/09/2011 - AMC
         END IF;

         -- Se modifica el tomador y riesgo del seguro
         UPDATE tomadores
            SET sperson = vsperson2,
                cdomici = vcdomici_aseg2
          WHERE sseguro = vsseguro;

         UPDATE riesgos
            SET sperson = vsperson2,
                cdomici = vcdomici_aseg2
          WHERE sseguro = vsseguro;
      END IF;

      RETURN 0;
   END f_constar_fallecimiento;

/*************************************************************************
   FUNCTION f_inicializar_siniestro
   Realiza acciones sobre el siniestro
   param in psseguro : Seguro
      pnriesgo : Riesgo
      pfsinies :Siniestro
      pfnotifi : Fecha
      ptsinies : Texto
      pccausin : Causa
      pcmotsin :Motivo
      pnsubest Subestado
   return             : código de error
*************************************************************************/
   FUNCTION f_inicializar_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      ptsinies IN VARCHAR2,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pnsubest IN NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
      vnsinies       NUMBER;
      vsperson_fallec NUMBER;
      v_sproduc      NUMBER;
      -- Bug XXX - RSC - 23/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
      v_fsinies      DATE;
      v_fnotifi      DATE;
      v_cempres      NUMBER;
      vfdiahabil     DATE;
      v_nasegur      siniestros.nasegur%TYPE;
      vnriesgo       siniestros.nriesgo%TYPE;
      vcramo         seguros.cramo%TYPE;
   -- Fin Bug XXX
   BEGIN
      -- Bug XXX - RSC - 23/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
      v_fsinies := pfsinies;
      v_fnotifi := pfnotifi;

      SELECT sproduc, cempres, cramo
        INTO v_sproduc, v_cempres, vcramo
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         -- Bug 13482 - RSC - 03/03/2010 - CRE - Vencimientos PPJ Dinámico / Pla Estudiant
         -- en fin de semana no se están contabilizano en Entradas / Salidas

         -- Bug 20309 - RSC - 20/12/2011 - LCOL_T004-Parametrización Fondos
         --IF TO_NUMBER(TO_CHAR(v_fnotifi, 'd')) IN(6, 7) THEN
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'HABIL_FIN_SEMANA'), 0) = 0 THEN
            IF TRIM(TO_CHAR(v_fnotifi, 'DAY', ' NLS_DATE_LANGUAGE=''AMERICAN'' ')) IN
                                                                        ('SATURDAY', 'SUNDAY') THEN
               vfdiahabil := f_diahabil(0, TRUNC(v_fnotifi), NULL);
               v_fnotifi := vfdiahabil;
            END IF;
         END IF;

         -- Bug 20309 - RSC - 20/12/2011 - LCOL_T004-Parametrización Fondos
         --IF TO_NUMBER(TO_CHAR(v_fsinies, 'd')) IN(6, 7) THEN
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'HABIL_FIN_SEMANA'), 0) = 0 THEN
            IF TRIM(TO_CHAR(v_fsinies, 'DAY', ' NLS_DATE_LANGUAGE=''AMERICAN'' ')) IN
                                                                        ('SATURDAY', 'SUNDAY') THEN
               vfdiahabil := f_diahabil(0, TRUNC(v_fsinies), NULL);
               v_fsinies := vfdiahabil;
            END IF;
         END IF;

         -- Fin Bug 13482

         -- Verificació de fons tancats / oberts
         IF pac_mantenimiento_fondos_finv.f_get_estado_fondo(v_cempres, v_fnotifi) = 107742 THEN
            -- Obtenemos el siguiente dia habil
            vfdiahabil := f_diahabil(0, TRUNC(v_fnotifi), NULL);
            v_fnotifi := vfdiahabil;
            vfdiahabil := f_diahabil(0, TRUNC(v_fsinies), NULL);
            v_fsinies := vfdiahabil;
         ELSE
            -- Obtenemos el siguiente dia habil o la misma fecha si ya es habil!
            -- (Esto se debe hacer ya que si el fondo no se abre por defecto se considera
            -- abierto y se colarian rescates en dias no habiles!)
            vfdiahabil := f_diahabil(13, TRUNC(v_fnotifi), NULL);
            v_fnotifi := vfdiahabil;
            vfdiahabil := f_diahabil(13, TRUNC(v_fsinies), NULL);
            v_fsinies := vfdiahabil;
         END IF;
      END IF;

      -- Fin Bug XXX
      num_err := pac_sin.f_permite_alta_siniestro(psseguro, pnriesgo, pfsinies, pfnotifi,
                                                  pccausin, pcmotsin);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- se inserta un siniestro con estado abierto
      num_err := pac_sin_insert.f_insert_siniestros(vnsinies, psseguro, pnriesgo, pfsinies,
                                                    pfnotifi, 0, ptsinies, pccausin, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF NVL(f_parproductos_v(v_sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
         -- ini Bug 0012822 - 24/02/2010 - JMF
         IF pccausin = 1
            AND pcmotsin = 12 THEN
            -- Defunción primer titular.
            v_nasegur := 1;
            vnriesgo := pnriesgo;
         ELSIF pccausin = 1
               AND pcmotsin = 13 THEN
            -- Defunción segundo titular.
            v_nasegur := 2;
            vnriesgo := pnriesgo;
         ELSE
            v_nasegur := pnriesgo;
            vnriesgo := 1;
         END IF;
      -- fin Bug 0012822 - 24/02/2010 - JMF
      ELSE   -- Si el producto NO es a 2_CABEZAS
         v_nasegur := NULL;
         vnriesgo := pnriesgo;
      END IF;

      UPDATE siniestros
         SET cmotsin = pcmotsin,
             nsubest = pnsubest,
             nasegur = v_nasegur,
             nriesgo = vnriesgo
       WHERE nsinies = vnsinies;

      num_err := pac_sin.f_tramitautomac(vnsinies);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Si se trata de un siniestro de fallecimiento ( pcmotsin=0 o pcmotsin=4)
      IF pccausin = 1
         AND(pcmotsin = 0
             OR pcmotsin = 4
             OR pcmotsin = 12) THEN   -- Muerte de 1er y unico titular o Muerte de 1er titular (2_CABEZAS)
         -- IF NVL(f_parproductos_v(v_sproduc, '2_CABEZAS'), 0) = 1 THEN
         IF NVL(f_parproductos_v(v_sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
            SELECT sperson
              INTO vsperson_fallec
              FROM siniestros si, asegurados aseg
             WHERE si.sseguro = aseg.sseguro
               AND si.nasegur = aseg.norden
               AND si.nsinies = vnsinies;
         ELSE   -- Si el producto NO es a 2_CABEZAS, el sperson se busca de la tabla RIESGOS
            SELECT sperson
              INTO vsperson_fallec
              FROM riesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         END IF;

         -- Se marca la persona como Fallecida
         UPDATE per_personas
            SET cestper = 2   -- Fallecida
          WHERE sperson = vsperson_fallec;
      END IF;

      num_err := pac_sin.f_accion_siniestro(vnsinies, 1, pcgarant);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_insagensini(vnsinies, f_sysdate, 1, f_sysdate + 1, NULL, 0,
                               'Apertura Siniestro', f_user, f_sysdate);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

-- ini Bug 0012822 - 24/02/2010 - JMF
      IF NVL(f_parproductos_v(v_sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1
         AND pccausin = 1
         AND pcmotsin = 13 THEN
         -- Si se trata de un producto de dos cabezas,
         -- y se trata de un siniestro defunción segundo titular,
         -- finalizamos el siniestro que acabamos de abrir.
         num_err := pac_sin.f_finalizar_sini(vnsinies, 1, vcramo || '01', TRUNC(f_sysdate),
                                             100832, f_idiomauser);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin.f_inicializar_siniestro', 1,
                     'error no controlat', SQLERRM);
         RETURN 140999;
   END f_inicializar_siniestro;

/*************************************************************************
   FUNCTION f_inicializar_siniestro
   Realiza acciones sobre el siniestro
   param in psseguro : Seguro
      pnriesgo : Riesgo
      pfsinies :Siniestro
      pfnotifi : Fecha
      ptsinies : Texto
      pccausin : Causa
      pcmotsin :Motivo
      pnsubest Subestado
      pcgarant  : Garantía
    param in pnsinies : Siniestro
   return             : código de error
*************************************************************************/

   ---------------------------------------------------------------------------------------------
   FUNCTION f_inicializar_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      ptsinies IN VARCHAR2,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pnsubest IN NUMBER,
      pnsinies OUT NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
      vnsinies       NUMBER;
      vsperson_fallec NUMBER;
      v_sproduc      NUMBER;
      -- Bug XXX - RSC - 23/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
      v_fsinies      DATE;
      v_fnotifi      DATE;
      v_cempres      NUMBER;
      vfdiahabil     DATE;
      -- Fin Bug XXX
      vnriesgo       siniestros.nriesgo%TYPE;
      v_nasegur      siniestros.nasegur%TYPE;
      vcramo         seguros.cramo%TYPE;
   BEGIN
      -- Bug XXX - RSC - 23/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
      v_fsinies := pfsinies;
      v_fnotifi := pfnotifi;

      SELECT sproduc, cempres, cramo
        INTO v_sproduc, v_cempres, vcramo
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         -- Bug 13482 - RSC - 03/03/2010 - CRE - Vencimientos PPJ Dinámico / Pla Estudiant
         -- en fin de semana no se están contabilizano en Entradas / Salidas

         -- Bug 20309 - RSC - 20/12/2011 - LCOL_T004-Parametrización Fondos
         --IF TO_NUMBER(TO_CHAR(v_fnotifi, 'd')) IN(6, 7) THEN
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'HABIL_FIN_SEMANA'), 0) = 0 THEN
            IF TRIM(TO_CHAR(v_fnotifi, 'DAY', ' NLS_DATE_LANGUAGE=''AMERICAN'' ')) IN
                                                                        ('SATURDAY', 'SUNDAY') THEN
               vfdiahabil := f_diahabil(0, TRUNC(v_fnotifi), NULL);
               v_fnotifi := vfdiahabil;
            END IF;
         END IF;

         -- Bug 20309 - RSC - 20/12/2011 - LCOL_T004-Parametrización Fondos
         --IF TO_NUMBER(TO_CHAR(v_fsinies, 'd')) IN(6, 7) THEN
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'HABIL_FIN_SEMANA'), 0) = 0 THEN
            IF TRIM(TO_CHAR(v_fsinies, 'DAY', ' NLS_DATE_LANGUAGE=''AMERICAN'' ')) IN
                                                                        ('SATURDAY', 'SUNDAY') THEN
               vfdiahabil := f_diahabil(0, TRUNC(v_fsinies), NULL);
               v_fsinies := vfdiahabil;
            END IF;
         END IF;

         -- Fin Bug 13482

         -- Verificació de fons tancats / oberts
         IF pac_mantenimiento_fondos_finv.f_get_estado_fondo(v_cempres, v_fnotifi) = 107742 THEN
            -- Obtenemos el siguiente dia habil
            vfdiahabil := f_diahabil(0, TRUNC(v_fnotifi), NULL);
            v_fnotifi := vfdiahabil;
            vfdiahabil := f_diahabil(0, TRUNC(v_fsinies), NULL);
            v_fsinies := vfdiahabil;
         -- Bug 14021 - RSC - 31/03/2010 - CRE - Entran rescates en dias no habiles PPJ Dinámico/PLA Estudiant
         ELSE
            -- Obtenemos el siguiente dia habil o la misma fecha si ya es habil!
            -- (Esto se debe hacer ya que si el fondo no se abre por defecto se considera
            -- abierto y se colarian rescates en dias no habiles!)
            vfdiahabil := f_diahabil(13, TRUNC(v_fnotifi), NULL);
            v_fnotifi := vfdiahabil;
            vfdiahabil := f_diahabil(13, TRUNC(v_fsinies), NULL);
            v_fsinies := vfdiahabil;
         -- Fin Bug 14021
         END IF;
      END IF;

      -- Fin Bug XXX
      num_err := pac_sin.f_permite_alta_siniestro(psseguro, pnriesgo, v_fsinies, v_fnotifi,
                                                  pccausin, pcmotsin);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- se inserta un siniestro con estado abierto
      num_err := pac_sin_insert.f_insert_siniestros(vnsinies, psseguro, pnriesgo, v_fsinies,
                                                    v_fnotifi, 0, ptsinies, pccausin, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      pnsinies := vnsinies;

      IF NVL(f_parproductos_v(v_sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
         -- ini Bug 0012822 - 24/02/2010 - JMF
         IF pccausin = 1
            AND pcmotsin = 12 THEN
            -- Defunción primer titular.
            v_nasegur := 1;
            vnriesgo := pnriesgo;
         ELSIF pccausin = 1
               AND pcmotsin = 13 THEN
            -- Defunción segundo titular.
            v_nasegur := 2;
            vnriesgo := pnriesgo;
         ELSE
            v_nasegur := pnriesgo;
            vnriesgo := 1;
         END IF;
      -- fin Bug 0012822 - 24/02/2010 - JMF
      ELSE   -- Si el producto NO es a 2_CABEZAS
         v_nasegur := NULL;
         vnriesgo := pnriesgo;
      END IF;

      UPDATE siniestros
         SET cmotsin = pcmotsin,
             nsubest = pnsubest,
             nriesgo = vnriesgo,
             nasegur = v_nasegur
       WHERE nsinies = vnsinies;

      num_err := pac_sin.f_tramitautomac(vnsinies);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Si se trata de un siniestro de fallecimiento ( pcmotsin=0 o pcmotsin=4)
      IF pccausin = 1
         AND(pcmotsin = 0
             OR pcmotsin = 4
             OR pcmotsin = 12) THEN   -- Muerte de 1er y unico titular o Muerte de 1er titular (2_CABEZAS)
         --IF NVL(f_parproductos_v(v_sproduc, '2_CABEZAS'), 0) = 1 THEN
         IF NVL(f_parproductos_v(v_sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
            SELECT sperson
              INTO vsperson_fallec
              FROM siniestros si, asegurados aseg
             WHERE si.sseguro = aseg.sseguro
               AND si.nasegur = aseg.norden
               AND si.nsinies = vnsinies;
         ELSE   -- Si el producto NO es a 2_CABEZAS, el sperson se busca de la tabla RIESGOS
            SELECT sperson
              INTO vsperson_fallec
              FROM riesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         END IF;

         -- Se marca la persona como Fallecida
         UPDATE per_personas
            SET cestper = 2   -- Fallecida
          WHERE sperson = vsperson_fallec;
      END IF;

      num_err := pac_sin.f_accion_siniestro(vnsinies, 1, pcgarant);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_insagensini(vnsinies, f_sysdate, 1, f_sysdate + 1, NULL, 0,
                               'Apertura Siniestro', f_user, f_sysdate);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

-- ini Bug 0012822 - 24/02/2010 - JMF
      IF NVL(f_parproductos_v(v_sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1
         AND pccausin = 1
         AND pcmotsin = 13 THEN
         -- Si se trata de un producto de dos cabezas,
         -- y se trata de un siniestro defunción segundo titular,
         -- finalizamos el siniestro que acabamos de abrir.
         num_err := pac_sin.f_finalizar_sini(vnsinies, 1, vcramo || '01', TRUNC(f_sysdate),
                                             100832, f_idiomauser);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin.f_inicializar_siniestro', 1,
                     'error no controlat', SQLERRM);
         RETURN 140999;
   END f_inicializar_siniestro;

-----------------------------------------------------------------------------------
   FUNCTION f_insctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      cmovimi IN NUMBER,
      pimporte IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER IS
      num_linea      NUMBER;
      xfcontab       DATE;
-----------Calculamos el número de línea----------------------------------
   BEGIN
      BEGIN
         SELECT MAX(nnumlin)
           INTO num_linea
           FROM ctaseguro
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      num_linea := NVL(num_linea + 1, 1);

      IF pffecmov >= pfcontab THEN
         xfcontab := pffecmov;
      ELSE
         xfcontab := pfcontab;
      END IF;

      BEGIN
         INSERT INTO ctaseguro
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                      ccalint, imovim2, nrecibo, nsinies, cmovanu, smovrec, cesta, nunidad,
                      cestado, fasign, nparpla, cestpar, iexceso, spermin, sidepag)
              VALUES (psseguro, xfcontab, num_linea, pffecmov, pfvalmov, cmovimi, pimporte,
                      0, 0, NULL, pnsinies, 0, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 102555;
         WHEN OTHERS THEN
            RETURN 102555;
      END;

      RETURN 0;
   END f_insctaseguro;

   FUNCTION f_insctaseguro_shw(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      cmovimi IN NUMBER,
      pimporte IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER IS
      num_linea      NUMBER;
      xfcontab       DATE;
-----------Calculamos el número de línea----------------------------------
   BEGIN
      BEGIN
         SELECT MAX(nnumlin)
           INTO num_linea
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      num_linea := NVL(num_linea + 1, 1);

      IF pffecmov >= pfcontab THEN
         xfcontab := pffecmov;
      ELSE
         xfcontab := pfcontab;
      END IF;

      BEGIN
         INSERT INTO ctaseguro_shadow
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                      ccalint, imovim2, nrecibo, nsinies, cmovanu, smovrec, cesta, nunidad,
                      cestado, fasign, nparpla, cestpar, iexceso, spermin, sidepag)
              VALUES (psseguro, xfcontab, num_linea, pffecmov, pfvalmov, cmovimi, pimporte,
                      0, 0, NULL, pnsinies, 0, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 102555;
         WHEN OTHERS THEN
            RETURN 102555;
      END;

      RETURN 0;
   END f_insctaseguro_shw;

-----------------------------------------------------------------------------------
   FUNCTION f_estatsini(pnsinies IN NUMBER)
      RETURN NUMBER IS
      /* Funcion que devuelve el estado del Siniestro actualmente*/
      v_estat        NUMBER;
      v_nmovimi      NUMBER;
   BEGIN
      -- Se debe tener en cuenta el estado Reapertura
      -- Si cestsin = 0 y trunc(max(fmovimi)) = siniestros.fentrad, es Reapertura
      -- Sino, se debe devolver el cestsin que se encuentra
      SELECT cestsin
        INTO v_estat
        FROM siniestros
       WHERE nsinies = pnsinies;

      IF v_estat = 0 THEN   -- Abierto o Reabierto
         -- Mirar si el siniestro está realmente abierto (cestado = 0 and nmovimi = 1) o reabierto (cestado = 0 and nmovimi <> 1)
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movsiniestro
          WHERE nsinies = pnsinies
            AND cestado = 0;

         IF v_nmovimi <> 1 THEN
            v_estat := 4;   -- Reabierto
         END IF;
      END IF;

      RETURN v_estat;
   END f_estatsini;

-----------------------------------------------------------------------------------
   FUNCTION f_estatpago(psidepag IN NUMBER)
      RETURN NUMBER IS
      v_estat        NUMBER;
   BEGIN
      SELECT cestpag
        INTO v_estat
        FROM pagosini
       WHERE sidepag = psidepag;

      --
      RETURN v_estat;
   END f_estatpago;

---------------------------------------------------------------------------------------
   FUNCTION f_finalizar_sini(
      pnsinies IN NUMBER,
      ptipo IN NUMBER,
      pccauest IN NUMBER,
      pfecha IN DATE,
      pliteral IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
/***********************************************************************************************
-Funcion que concluye un siniestro: finaliza, anula o rechaza un siniestro.
-Si tiene pagos pendientes no se pueden realizar las operaciones de anulación y rechazo
-Genera un apunte en la agenda del siniestro.
-Realiza la insercion de la provision
-Comprueva a ver si la poliza esta retenida por haber realizado un siniestro si es asi la deja en estado normal.
TIPO : nos indica si se trata de un rechado de expediente o es anulacion.
             1 - Finalización
    2 - Anulación
    3 - Rechazo
***********************************************************************************************/
      v_cont_pagos   NUMBER;
      error          NUMBER;
      v_provision    NUMBER;
      v_creteni      NUMBER;
      v_sseguro      NUMBER;
      v_nmovimi      NUMBER;
      v_ttexto       VARCHAR2(400);
      v_cestsin      NUMBER;
      v_articulo     VARCHAR2(4);
      v_num_literal  NUMBER;
      v_cmotmov      NUMBER;
      max_valor      DATE;
      max_pago       DATE;
      accion         NUMBER;
      v_sproduc      NUMBER;
      v_ccausin      NUMBER;
--
      vcontapagos    NUMBER;
   BEGIN
--   Validaciones
      IF ptipo IN(2, 3) THEN   --anulación o rechazo
         --Se controla que no existan pagos pendientes.
         SELECT COUNT(*)
           INTO v_cont_pagos
           FROM pagosini p
          WHERE p.cestpag <> 8
            AND ctippag = 2
            AND NOT EXISTS(SELECT pp.sidepag
                             FROM pagosini pp
                            WHERE pp.nsinies = pnsinies
                              AND p.sidepag = pp.spganul
                              AND pp.cestpag <> 8)
            AND p.nsinies = pnsinies;

         IF v_cont_pagos > 0 THEN
            IF ptipo = 1 THEN   --Anulación
               v_num_literal := 100844;   --No se puede anular. Existen pagos.
            ELSE   --Rechazo
               v_num_literal := 100856;   --No se puede rechazar. Existen pagos.
            END IF;

            RETURN v_num_literal;
         END IF;
      ELSE   -- finalización
         --   Validamos que la fecha elegida no supere al ultimo pago/valoracion
         SELECT MAX(fvalora)
           INTO max_valor
           FROM valorasini
          WHERE nsinies = pnsinies;

         SELECT MAX(fordpag)
           INTO max_pago
           FROM pagosini
          WHERE nsinies = pnsinies;

         IF TRUNC(pfecha) < TRUNC(max_pago) THEN
            RETURN 107706;   -- existen pagos con fecha posterior
         END IF;

         IF TRUNC(pfecha) < TRUNC(max_valor) THEN
            RETURN 107705;   -- existen valoraciones con fecha posterior
         END IF;
      END IF;

      IF ptipo = 1 THEN   -- finalización
         v_cestsin := 1;
         v_articulo := '01- ';
      ELSIF ptipo = 2 THEN
         v_cestsin := 2;   --Anulación
         v_articulo := '02- ';
      ELSE
         v_cestsin := 3;   --Rechazo
         v_articulo := '03- ';
      END IF;

      --Se actualiza el siniestro anulándolo y poniéndole la causa de anulación.
      BEGIN
         UPDATE siniestros
            SET cestsin = v_cestsin,
                festsin = pfecha,
                ccauest = pccauest
          WHERE nsinies = pnsinies;
      EXCEPTION
         WHEN OTHERS THEN
            -- Error recollit de trigger de festsin, que evita que es tanquin
            --               sinistres amb data anterior a l'ultim tancament
            IF SQLCODE = -20001 THEN
               p_tab_error(f_sysdate, f_user, 'pac_sin.f_finalizar_sini', 1,
                           'Siniestro = ' || pnsinies || ', v_cestsin=' || v_cestsin
                           || ', pfecha=' || pfecha || ', pccauest=' || pccauest,
                           SQLERRM);
               RETURN 108127;   --fecha de cierre no permitida
            ELSE
               p_tab_error(f_sysdate, f_user, 'pac_sin.f_finalizar_sini', 2,
                           'Siniestro = ' || pnsinies || ', v_cestsin=' || v_cestsin
                           || ', pfecha=' || pfecha || ', pccauest=' || pccauest,
                           SQLERRM);
               RETURN 108129;   -- error al actualizar la tabla siniestros
            END IF;
      END;

      --Para controlar el siniestro realizamos un apunte en la Agenda de siniestros.
      v_ttexto := f_axis_literales(pliteral, pcidioma);
      --Realizamos la insercion en la Agenda.
      error := f_insagensini(pnsinies, pfecha, 5, NULL, f_sysdate, 1, v_articulo || v_ttexto,
                             f_user, f_sysdate);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      --Recuperamos la provision total del siniestro.
      error := f_provisio_total(pnsinies, pfecha, v_provision);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      IF v_provision <> 0 THEN   -- sólo insertamos si la provisión es <>0
         --Insertamos en valorasini para dejar a cero la provisión.
         BEGIN
            INSERT INTO valorasini
                        (nsinies, cgarant, fvalora, ivalora)
                 VALUES (pnsinies, 9998, pfecha, 0 - v_provision);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 102695;
         END;
      END IF;

      IF ptipo = 1 THEN
         accion := 2;   --finalizar
      ELSIF ptipo IN(2, 3) THEN   -- anular o rechazar
         accion := 3;
      END IF;

      BEGIN
         SELECT s.sproduc, ccausin, s.sseguro
           INTO v_sproduc, v_ccausin, v_sseguro
           FROM siniestros si, seguros s
          WHERE s.sseguro = si.sseguro
            AND si.nsinies = pnsinies;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 105144;   -- error en la lextura de siniestros
      END;

      -- Si es un rescate o vencimiento, se cierra el siniestro por finalización y la póliza
      -- graba en ctaseguro se grabará el registro de rescate o vencimiento
      --  (comentado v_ccausin <> 1 para permitir finalizar también siniestros)
      --if accion = 2  and v_ccausin <> 1 and

      -- APD 01/10/2008 se comenta el IF NVL(F_Parproductos_V(v_sproduc, 'ES_PRODUCTO_INDEXADO'),0) = 1 para que
      -- se finalice el siniestro tanto si es un producto de Ahorro como de UnitLink

      --   IF NVL(F_Parproductos_V(v_sproduc, 'ES_PRODUCTO_INDEXADO'),0) = 1 THEN
      --
      -- Si esta pagado podemos generar movimiento en CTASEGURO (Unit Linked)
      -- Se buscan los pagos de tipo pago y que estén pagados o se haya aceptado el pago
      BEGIN
         SELECT COUNT(*)
           INTO vcontapagos
           FROM pagosini
          WHERE nsinies = pnsinies
            AND ctippag = 2   -- 2 = Pago
            AND cestpag IN(1, 2)   -- 1 = Aceptado, 2 = Pagado
            AND pagosini.sidepag NOT IN(SELECT NVL(pp.spganul, 0)
                                          FROM pagosini pp
                                         WHERE nsinies = pagosini.nsinies
                                           AND cestpag <> 8);   -- 8 = Anulado
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcontapagos := 0;
      END;

      IF accion = 2
         AND NVL(f_parproductos_v(v_sproduc, 'CUENTA_SEGURO'), 0) = 1
         AND vcontapagos <> 0 THEN
         error := f_reajustar_ctaseguro(pnsinies, v_sseguro);

         IF error = 0 THEN   -- Bug 9276 - 27/02/2009 - APD - Se debe finalizar el rescate
            error := pac_rescates.f_finaliza_rescate(v_sseguro, 1, pnsinies, 1);

            IF error <> 0 THEN
               RETURN error;
            END IF;
         ELSIF error = 1 THEN   -- Bug 9276 - 27/02/2009 - APD - NO se debe finalizar el rescate
            NULL;
         ELSIF error <> 1 THEN   -- Bug 9276 - 27/02/2009 - APD - Se debe mostrar mensaje de error
            RETURN error;
         END IF;
      END IF;

/*
   ELSE
    if accion = 2 and v_ccausin <> 1 and NVL(F_Parproductos_V(v_sproduc, 'CUENTA_SEGURO'),0)= 1 THEN
        error:=pac_rescates.f_finaliza_rescate(v_sseguro,1, pnsinies, 1);
        IF error <> 0 THEN
                  Return error;
            END IF;
     END IF;
   END IF;
*/
      IF accion = 3 THEN   -- si se rechaza o anula se deben borrar las primas consumidas de ese rescate
         DELETE FROM primas_consumidas
               WHERE nsinies = pnsinies;
      END IF;

      -- accion al cerrar o anular un siniestro
      error := pac_sin.f_accion_siniestro(pnsinies, accion);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      --Todo correcto
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin.f_finalizar_sini', 99,
                     'Error al finalizar el siniestro', SQLERRM);

         IF ptipo = 1 THEN
            RETURN 152186;   --Anulacio
         ELSE
            RETURN 152187;   --Rechazo
         END IF;
   END f_finalizar_sini;

---------------------------------------------------------------------------------
   FUNCTION f_provisio_total(
      pnsinies IN NUMBER,
      pdata IN DATE,
      provisio OUT NUMBER,
      plevelpag IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
/***********************************************************************************************
--Calcula la provision total del siniestro.
*************************************************************************************************/
      num_err        NUMBER;
      v_prov         NUMBER;
   BEGIN
      --Inicializamos la variable total.
      provisio := 0;

      --Recuperamos las garantias que tiene valoracion del siniestro.
      FOR aux IN (SELECT DISTINCT cgarant
                             FROM valorasini
                            WHERE nsinies = pnsinies) LOOP
         --Calculamos la provision para cada garantia.
         num_err := f_provisio_sini(pnsinies, aux.cgarant, pdata, v_prov, plevelpag);

         IF num_err = 0 THEN
            --Realizamos la suma de las provisiones.
            provisio := provisio + v_prov;
         ELSE
            RETURN num_err;
         END IF;
      END LOOP;

      --Todo correcto
      RETURN 0;
   END f_provisio_total;

------------------------------------------------------------------------------------------------------------
   FUNCTION f_anu_sini_mov(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
/***********************************************************************************************

-Esta funcion anula un siniestro dependiendo del movimiento de la poliza.
-Se recupera el idioma para utilizarlo en la llamada a la anulacion del siniestro.
-Se realiza la llamada a F_anul_rechazo_sini
***********************************************************************************************/
      v_nsinies      NUMBER;
      v_cidioma      NUMBER;
      num_err        NUMBER;
      v_causa        NUMBER;
      v_tliteral     NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      --Controlamos si la poliza ha generado un siniestro en el movimiento que se pasa por parametro.
      --Se controla que el siniestro no este anulado ni rechazado.
      FOR aux IN (SELECT nsinies
                    FROM siniestros
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND cestsin NOT IN(2, 3)) LOOP
         --Inicializamos la causa.
         v_causa := 2303;   -- ANUL.LAT REHABILITACIÓ

         BEGIN
            --Se recupera el idioma para realizar la llamada a la funcion que anula el siniestro.
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cidioma, cempres, cagente
              INTO v_cidioma, vcempres, vagente_poliza
              FROM seguros
             WHERE sseguro = psseguro;

            IF v_cidioma = 0 THEN   --El del tomador
               --Se recupera el idioma del tomador.
               SELECT d.cidioma
                 INTO v_cidioma
                 FROM per_personas p, per_detper d
                WHERE p.sperson = d.sperson
                  AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
                  AND p.sperson = (SELECT sperson
                                     FROM tomadores
                                    WHERE sseguro = psseguro
                                      AND nordtom = 1);
            /*SELECT cidioma
              INTO v_cidioma
              FROM personas
             WHERE sperson = (SELECT sperson
                                FROM tomadores
                               WHERE sseguro = psseguro);*/
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 152184;
         END;

         --Se realiza la llamada a la funcion que anula el siniestro.
         v_tliteral := 152150;   --Anul.lacio d'expedient per rehabilitació
         num_err := f_finalizar_sini(aux.nsinies, 2, v_causa, f_sysdate, v_tliteral, v_cidioma);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      --Todo correcto
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin.f_anu_sini_mov', NULL,
                     'Error al anular el movimiento el siniestro', SQLERRM);
         RETURN 152186;
   END f_anu_sini_mov;

   FUNCTION ff_sperson_sinies(pnsinies IN NUMBER)
      RETURN NUMBER IS
--Función que devuelve el sperson de la persona siniestrada. Si el producto es a 2_Cabezas, el sperson se busca de la tabla ASEGURADOS,
-- sino de la tabla RIESGOS
      v_sseguro      NUMBER;
      v_sproduc      NUMBER;
      v_sperson      NUMBER;
      v_nasegur      NUMBER;
      v_nriesgo      NUMBER;
   BEGIN
      SELECT si.sseguro, s.sproduc, si.nasegur, si.nriesgo
        INTO v_sseguro, v_sproduc, v_nasegur, v_nriesgo
        FROM siniestros si, seguros s
       WHERE si.sseguro = s.sseguro
         AND si.nsinies = pnsinies;

      -- Si el producto es a 2_CABEZAS, el sperson se busca de la tabla ASEGURADOS
      IF NVL(f_parproductos_v(v_sproduc, '2_CABEZAS'), 0) = 1 THEN
         SELECT sperson
           INTO v_sperson
           FROM asegurados
          WHERE sseguro = v_sseguro
            AND norden = v_nasegur;
      ELSE   -- Si el producto NO es a 2_CABEZAS, el sperson se busca de la tabla RIESGOS
         SELECT sperson
           INTO v_sperson
           FROM riesgos
          WHERE sseguro = v_sseguro
            AND nriesgo = v_nriesgo;
      END IF;

      RETURN v_sperson;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_sperson_sinies;

   FUNCTION f_reabrir_sini(pnsinies IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      ttexto         VARCHAR2(400);
      v_cempres      NUMBER;
      v_idioma       NUMBER;
   BEGIN
      UPDATE siniestros
         SET cestsin = 0,
             festsin = NULL,
             ccauest = NULL
       WHERE nsinies = pnsinies;

      SELECT seg.cempres
        INTO v_cempres
        FROM seguros seg, siniestros s
       WHERE seg.sseguro = s.sseguro
         AND nsinies = pnsinies;

      -- borramos la valoración de la garantia 9998 (reajuste de
       --    cierre)
      DELETE FROM valorasini
            WHERE nsinies = pnsinies
              AND cgarant = 9998;

      v_idioma := pac_parametros.f_parempresa_n(v_cempres, 'IDIOMA_DEF');
      ttexto := f_axis_literales(100675, v_idioma);
      num_err := f_insagensini(pnsinies, f_sysdate, 5, NULL, f_sysdate, 1, '04-' || ttexto,
                               f_user, f_sysdate);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin.f_reabrir_sini', NULL,
                     'Error al reabrir el siniestro', SQLERRM);
         RETURN 140999;
   END f_reabrir_sini;

---------------------------------------------------------------------------------
   FUNCTION f_rcm_sini(pnsinies IN NUMBER, pcgarant IN NUMBER, pdata IN DATE, resrcm OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(SUM(DECODE(s.ctippag, 2, s.iresrcm, 8, s.iresrcm, s.iresrcm * -1)), 0)
        INTO resrcm
        FROM pagosini s, pagogarantia g
       WHERE s.sidepag = g.sidepag
         AND s.nsinies = pnsinies
         AND(pdata IS NULL
             OR s.fordpag <= pdata)
         AND g.cgarant = pcgarant
         AND s.cestpag <> 8;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         resrcm := 0;
         RETURN 101667;
      WHEN OTHERS THEN
         resrcm := 0;
         RETURN SQLCODE;
   END f_rcm_sini;

---------------------------------------------------------------------------------
   FUNCTION f_iretenc_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      retenc OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(SUM(DECODE(s.ctippag, 2, s.iretenc, 8, s.iretenc, s.iretenc * -1)), 0)
        INTO retenc
        FROM pagosini s, pagogarantia g
       WHERE s.sidepag = g.sidepag
         AND s.nsinies = pnsinies
         AND(pdata IS NULL
             OR s.fordpag <= pdata)
         AND g.cgarant = pcgarant
         AND s.cestpag <> 8;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         retenc := 0;
         RETURN 101667;
      WHEN OTHERS THEN
         retenc := 0;
         RETURN SQLCODE;
   END f_iretenc_sini;

---------------------------------------------------------------------------------
   FUNCTION f_reduccion_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      resred OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(SUM(DECODE(s.ctippag, 2, s.iresred, 8, s.iresred, s.iresred * -1)), 0)
        INTO resred
        FROM pagosini s, pagogarantia g
       WHERE s.sidepag = g.sidepag
         AND s.nsinies = pnsinies
         AND(pdata IS NULL
             OR s.fordpag <= pdata)
         AND g.cgarant = pcgarant
         AND s.cestpag <> 8;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         resred := 0;
         RETURN 101667;
      WHEN OTHERS THEN
         resred := 0;
         RETURN SQLCODE;
   END f_reduccion_sini;

-- Retorna la descripcio del motiu de sinistre
--------------------------------------------------------------------
   FUNCTION f_desmotsini(
      pcramo IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcidioma IN NUMBER,
      ptmotsin OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT d.tmotsin
        INTO ptmotsin
        FROM desmotsini d
       WHERE d.cramo = pcramo
         AND d.ccausin = pccausin
         AND d.cmotsin = pcmotsin
         AND d.cidioma = pcidioma;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ptmotsin := '**';
         RETURN 101667;
      WHEN OTHERS THEN
         ptmotsin := '***';
         RETURN SQLCODE;
   END f_desmotsini;

-- Actualitza la culpabilitat d'un sinistre
---------------------------------------------------------------------------------
   FUNCTION f_constar_culpabilidad(pnsinies IN NUMBER, pcculpab IN NUMBER)
      RETURN NUMBER IS
      e_param_error  EXCEPTION;
      vobjectname    tab_error.tdescrip%TYPE;
      vparam         tab_error.tdescrip%TYPE;
      vpasexec       NUMBER(8);
   BEGIN
      vobjectname := 'PAC_SIN.f_constar_culpabilidad';
      vparam := 'parámetros - pnsinies: ' || pnsinies || ' - pcculpab: ' || pcculpab;
      vpasexec := 1;

      IF pnsinies IS NULL /*OR pcculpab IS NULL*/ -- La culpabilitat deixa de ser sempre obligatòria
                         THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      UPDATE siniestros s
         SET cculpab = pcculpab
       WHERE s.nsinies = pnsinies;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 107839;   --Error en els paràmetres d'entrada.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 111504;   --Error en la modificació de sinistres.
   END f_constar_culpabilidad;
END pac_sin;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN" TO "PROGRAMADORESCSI";
