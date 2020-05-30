--------------------------------------------------------
--  DDL for Package Body PK_PLANESMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_PLANESMES" AS
---------------------------------------------------------------------------
/******************************************************************************
   NOMBRE:     PK_PLANESMES
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/07/2009   DCT                1. 0010612: CRE - Error en la generació de pagaments automàtics.
                                              Canviar vista personas por tablas personas y añadir filtro de visión de agente
******************************************************************************/
   PROCEDURE lee AS
      leido          BOOLEAN := FALSE;
   BEGIN
      IF NOT seg_cv%ISOPEN THEN
         OPEN seg_cv;
      END IF;

      FETCH seg_cv
       INTO regpila;

      IF seg_cv%NOTFOUND THEN
         leido := FALSE;
         regpila.sseguro := -1;

         CLOSE seg_cv;
      ELSE
         leido := TRUE;
         tratamiento;

         -- BUG -21546_108724- 13/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF seg_cv%ISOPEN THEN
            CLOSE seg_cv;
         END IF;
      END IF;
   END lee;

-------------------------------------------------------------------------
   PROCEDURE tratamiento IS
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
-- Inicializar variables
      num_certificado := NULL;
      moneda := '???';
      subproducto := 0;
      cod_oficina := 0;
      aport_periodica := 0;
      aport_inicial := 0;
      faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      tipo_crecimiento := ' ';
      fcrecimiento := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      fultaport := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      pcrec := 0;
      forma_crecimiento := ' ';
      percre := ' ';
      cta_prestamo := NULL;
      ipresta := 0;
      clavefondo := 0;
      claveplan := 0;
      idseq1 := 0;
      idseq2 := NULL;
      faltaplan := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      faltagest := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      siglascom := NULL;
      domicilio := NULL;
      numero := NULL;
      emplaza := NULL;
      codpostal := NULL;
      municipio := NULL;
      tipopers := NULL;
      --********* Asignación Alberto *********************************************
      ivalorp := 0;
      nparpla := 0;
      fpago := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      iretenc := 0;
      codcon := NULL;
      mmonpro := 0;
      ccont1 := NULL;
      ccont2 := NULL;
      ccont3 := NULL;
      tipcap := 0;
      contin := 0;
      fvalmov := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      imovimi := 0;
      cmovimi := NULL;
      ctipapor := NULL;
      codsperson := NULL;
      nporcen := 0;
      faccion := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      finibloq := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      ffinbloq := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      numbloq := 0;
      nparret := 0;
      codbloq := NULL;
      ibloq := 0;
      cbancar := NULL;
      finicio := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      cperiod := 0;
      fprorev := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      prevalo := 0;
      nrevanu := 0;
      ctiprev := NULL;
      cestado := NULL;
      cdivisa := NULL;
      ireducsn := 0;
      nanos := 0;

--*************************************************************************
  --  Datos de seguro
      SELECT sseguro,
             cramo,
             cmodali,
             ctipseg,
             ccolect,
             npoliza,
             fefecto,
             fanulac,
             DECODE(fanulac, NULL, 'A', 'V'),
             NVL(fvencim, TO_DATE('0001-01-01', 'yyyy-mm-dd')),
             DECODE(cforpag, 1, 'A', 2, 'S', 3, 'C', 4, 'T', 6, 'B', 12, 'M', 0, 'U'),
             cbancar
        INTO regseg
        FROM seguros
       WHERE sseguro = regpila.sseguro;

      -- *** Bucamos el total de los movimientos realizados este año
      SELECT SUM(NVL(DECODE(cmovimi,
                            1, nparpla,
                            2, nparpla,
                            8, nparpla,
                            10, nparpla,
                            49, -nparpla,
                            47, -nparpla,
                            51, -nparpla,
                            52, -nparpla,
                            53, -nparpla,
                            0),
                     0))
        INTO nparpla
        FROM ctaseguro
       WHERE ctaseguro.sseguro = regpila.sseguro
         AND TO_CHAR(ctaseguro.fvalmov, 'yyyymm') <= TO_CHAR(f_sysdate, 'yyyymm') - 1;

      SELECT TO_DATE('01' || TO_CHAR(f_sysdate, 'mmyyyy'), 'ddmmyyyy') - 1
        INTO fmes
        FROM DUAL;

      -- *** Calculamos la moneda del producto
      BEGIN
         SELECT cdivisa
           INTO cdivisa
           FROM productos, seguros
          WHERE seguros.sseguro = regpila.sseguro
            AND seguros.cramo = productos.cramo
            AND seguros.cmodali = productos.cmodali
            AND seguros.ctipseg = productos.ctipseg
            AND seguros.ccolect = productos.ccolect;
      EXCEPTION
         WHEN OTHERS THEN
            cdivisa := NULL;
      END;

      -- Datos de fondo y plan
      BEGIN
         SELECT clapla, planpensiones.ccodpla
           INTO claveplan, PLAN
           FROM proplapen, planpensiones
          WHERE sproduc = (SELECT sproduc
                             FROM productos
                            WHERE cramo = regseg.cramo
                              AND cmodali = regseg.cmodali
                              AND ctipseg = regseg.ctipseg
                              AND ccolect = regseg.ccolect)
            AND proplapen.ccodpla = planpensiones.ccodpla;
      EXCEPTION
         WHEN OTHERS THEN
            claveplan := NULL;
      END;

      BEGIN
         SELECT fp.clafon
           INTO clavefondo
           FROM planpensiones pp, fonpensiones fp
          WHERE pp.ccodfon = fp.ccodfon
            AND pp.ccodpla = PLAN;
      EXCEPTION
         WHEN OTHERS THEN
            clavefondo := NULL;
      END;

      -- Determinar tipo de producto
      BEGIN
         SELECT clase, DECODE(cmoneda, 2, 'PTA', 3, 'EUR', '???')
           INTO t_producto, moneda
           FROM tipos_producto
          WHERE cramo = regseg.cramo
            AND cmodali = regseg.cmodali
            AND ctipseg = regseg.ctipseg
            AND ccolect = regseg.ccolect;
      EXCEPTION
         WHEN OTHERS THEN
            t_producto := NULL;
            moneda := '???';
      END;

      -- Lectura del numero de certificado
      BEGIN
         --  Select per sseguro, no per npoliza
         SELECT LPAD(polissa_ini, 10, '0')
           INTO num_certificado
           FROM cnvpolizas
          WHERE sseguro = regseg.sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_certificado := '0000000000000';
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Pk_Planesmes.Tratamiento', 1,
                        'Error no controlado',
                        '(CnvPolizas) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                        || SQLERRM);
      END;

      idseq1 := 0900000000 + num_certificado;   -- N. de cliente de la Caja

      -- idseq2 := rpad(to_number(num_certificado),25,' '); -- En principio = a idseq2
       /*
        *  Si hay cambio de participe a beneficiario componer valor de idseq1
        */
        -- Fecha alta gestora
      BEGIN
         SELECT MIN(fantigi)
           INTO faltagest
           FROM trasplainout
          WHERE sseguro = regseg.sseguro
            AND cinout = 1;
      EXCEPTION
         WHEN OTHERS THEN
            faltagest := NULL;
      END;

      IF moneda = 'PTA'
         OR moneda = '???' THEN
         -- Determinar código de subproducto
         BEGIN
            SELECT producte_mu, NVL(numpol, 0)
              INTO subproducto, regseg.npoliza
              FROM cnvproductos
             WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0) AND NVL(npolfin,
                                                                              99999999)
               AND cramo = regseg.cramo
               AND cmodal = regseg.cmodali
               AND ctipseg = regseg.ctipseg
               AND ccolect = regseg.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               subproducto := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pk_Planesmes.Tratamiento', 2,
                           'Error no controlado',
                           '(CnvProductos 1) sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;
      ELSIF moneda = 'EUR' THEN
         -- Determinar código de subproducto
         BEGIN
            SELECT producte_mu, NVL(numpol, 0)
              INTO subproducto, regseg.npoliza
              FROM cnvproductos
             WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0) AND NVL(npolfin,
                                                                              99999999)
               AND cramo_e = regseg.cramo
               AND cmodali_e = regseg.cmodali
               AND ctipseg_e = regseg.ctipseg
               AND ccolect_e = regseg.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               subproducto := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pk_Planesmes.Tratamiento', 3,
                           'Error no controlado',
                           '(CnvProductos 1) sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;
      END IF;

      IF regseg.estado = 'F' THEN
         regmovseg.finisus := regseg.fanulac;
         regseg.fanulac := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      ELSE
         regmovseg.finisus := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      END IF;

      IF regmovseg.finisus IS NULL THEN
         regmovseg.finisus := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      END IF;

      -- Oficina
      BEGIN
         SELECT coficin
           INTO cod_oficina
           FROM historicooficinas
          WHERE sseguro = regseg.sseguro
            AND finicio = (SELECT MAX(finicio)
                             FROM historicooficinas
                            WHERE sseguro = regseg.sseguro
                              AND finicio <= regseg.fefecto);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            cod_oficina := 0;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Pk_Planesmes.Tratamiento', 4,
                        'Error no controlado',
                        '(HistOficinas) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                        || SQLERRM);
      END;

      --Bug10612 - 13/07/2009 - DCT (canviar vista personas)
      --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
      SELECT cagente, cempres
        INTO vagente_poliza, vcempres
        FROM seguros
       WHERE sseguro = regseg.sseguro;

      -- Datos de Persona
      SELECT r.sperson,
             SUBSTR(SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' '
                    || SUBSTR(d.tapelli2, 0, 20),
                    1, 60)
        INTO codsperson,
             nomape
        FROM riesgos r, per_personas p, per_detper d
       WHERE r.sseguro = regseg.sseguro
         AND p.sperson = r.sperson
         AND d.sperson = p.sperson
         AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);
   /*SELECT RIESGOS.sperson
              ,SUBSTR(PERSONAS.tnombre || ' ' || PERSONAS.tapelli, 1, 60)
   INTO codsperson
                     ,NOMAPE
   FROM RIESGOS, PERSONAS
   WHERE sseguro = RegSeg.sseguro
   AND PERSONAS.sperson = RIESGOS.sperson;*/

   --FI Bug10612 - 13/07/2009 - DCT (canviar vista personas)
   END tratamiento;

---------------------------------------------------------------------------
   FUNCTION fin
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regpila.sseguro = -1 THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Planesmes.Fin', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END fin;
---------------------------------------------------------------------------
END pk_planesmes;

/

  GRANT EXECUTE ON "AXIS"."PK_PLANESMES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_PLANESMES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_PLANESMES" TO "PROGRAMADORESCSI";
