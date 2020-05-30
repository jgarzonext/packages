--------------------------------------------------------
--  DDL for Package Body PAC_CESSGALIQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CESSGALIQ" AS
/******************************************************************************
   NOMBRE:     PAC_CESSGALIQ
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/07/2009   DCT                1. 0010612: CRE - Error en la generació de pagaments automàtics.
                                              Canviar vista personas por tablas personas y añadir filtro de visión de agente
******************************************************************************/
   PROCEDURE inicialitzar(vempres IN NUMBER, vcia IN NUMBER, vsdatamov IN DATE) AS
   BEGIN
      p_cempres := vempres;
      p_ccompani := vcia;
      p_datamov := vsdatamov;
   END inicialitzar;

   PROCEDURE fecha AS
   BEGIN
      wfecha := NULL;

      SELECT LAST_DAY(p_datamov)
        INTO wfecha
        FROM DUAL;
   END fecha;

   PROCEDURE lee AS
      leido          BOOLEAN := FALSE;
      wfanulac       DATE;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      IF NOT rebut_cv%ISOPEN THEN
         OPEN rebut_cv;
      END IF;

      sortir := FALSE;

      FETCH rebut_cv
       INTO regliq;

      IF rebut_cv%NOTFOUND THEN
         leido := FALSE;
         sortir := TRUE;

         CLOSE rebut_cv;
      ELSE
         leido := TRUE;

         -- BUG -21546_108724- 14/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF rebut_cv%ISOPEN THEN
            CLOSE rebut_cv;
         END IF;
      END IF;

-- Inicializar variables
      IF leido THEN
         p_sseguro := 0;
         p_cramo := 0;
         p_cmodali := 0;
         p_ctipseg := 0;
         p_ccolect := 0;
         p_efe := NULL;
         p_tip_reb := NULL;
         num_certificado := NULL;
         tip_reb := NULL;
         numpol := NULL;
         num_certif := 0;
         nom_asse := NULL;
         nif_asse := NULL;
         data_cobr := NULL;
         p_num_registres := p_num_registres + 1;
         p_tot_pr_neta := p_tot_pr_neta + regliq.iprinet;
         p_tot_ips := p_tot_ips + regliq.iips;
         p_tot_pr_bruta := p_tot_pr_bruta + regliq.itotalr;
         p_tot_comissio := p_tot_comissio + regliq.icomcia;
         -- Obtención de campos para siniestros y recibos
         p_sseguro := regliq.sseguro;
         p_tip_reb := regliq.tipo;
         p_efe := regliq.fefecto;
         data_cobr := regliq.fecha_movimiento;

         BEGIN
            -- Se mira la situación del seguro
            SELECT csituac
              INTO situacion
              FROM seguros
             WHERE sseguro = regliq.sseguro;

            IF situacion IN(2, 3) THEN
               anulada := 'SI';
            ELSE
               anulada := NULL;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               anulada := NULL;
         END;

         -- Lectura del número de certificado
         BEGIN
            SELECT LPAD(polissa_ini, 10, '0')
              INTO num_certificado
              FROM cnvpolizas
             WHERE sseguro = p_sseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               num_certificado := '0000000000';
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line('(Cnvpolizas 1) sseguro = ' || TO_CHAR(p_sseguro) || ' - '
               --                     || SQLERRM);
               NULL;
         END;

         -- Acceso a seguros
         BEGIN
            SELECT cramo, cmodali, ctipseg, ccolect
              INTO p_cramo, p_cmodali, p_ctipseg, p_ccolect
              FROM seguros
             WHERE sseguro = p_sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line('(Seguros 1) sseguro = ' || TO_CHAR(p_sseguro) || ' - '
               --                     || SQLERRM);
               NULL;
         END;

         -- Determinar póliza colectiva
         BEGIN
            SELECT NVL(numpol, '0')
              INTO numpol
              FROM cnvproductos
             WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0) AND NVL(npolfin,
                                                                              99999999)
               AND cramo = p_cramo
               AND cmodal = p_cmodali
               AND ctipseg = p_ctipseg
               AND ccolect = p_ccolect;
         EXCEPTION
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line('(CnvProductos 1) sseguro = ' || TO_CHAR(p_sseguro)
               --                     || ' - ' || SQLERRM);
               NULL;
         END;

         -- Datos de personas
         BEGIN
            --Bug10612 - 09/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = p_sseguro;

            SELECT TRIM(SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20))
                   || TRIM(SUBSTR(d.tnombre, 0, 20))
              INTO nom_asse
              FROM per_personas p, per_detper d
             WHERE d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
               AND p.sperson = (SELECT sperson
                                  FROM asegurados
                                 WHERE sseguro = p_sseguro
                                   AND norden = (SELECT MIN(norden)
                                                   FROM asegurados
                                                  WHERE sseguro = p_sseguro
                                                    AND ffecfin IS NULL));
         /*SELECT trim(tapelli)||trim(tnombre)
           INTO nom_asse
         FROM personas
         WHERE sperson = (SELECT sperson
                            FROM asegurados
                            WHERE sseguro = p_sseguro
                              AND norden = (SELECT MIN(norden) FROM asegurados
                                            WHERE sseguro = p_sseguro
                                              AND ffecfin IS NULL));*/

         --FI Bug10612 - 09/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               nom_asse := 'Desconocido';
         END;

         -- Acceso a Personas_ULK
         BEGIN
            SELECT cnifhos
              INTO nif_asse
              FROM personas_ulk
             WHERE sperson = (SELECT sperson
                                FROM asegurados
                               WHERE sseguro = p_sseguro
                                 AND norden = (SELECT MIN(norden)
                                                 FROM asegurados
                                                WHERE sseguro = p_sseguro
                                                  AND ffecfin IS NULL));
         EXCEPTION
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line('(Personas_ULK) 1sseguro = ' || TO_CHAR(p_sseguro)
               --                     || ' - ' || SQLERRM);
               NULL;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('sseguro = ' || TO_CHAR(p_sseguro) || ' - ' || SQLERRM);
         leido := FALSE;
         sortir := TRUE;

         CLOSE rebut_cv;
   END lee;

   FUNCTION fin
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF sortir THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('sseguro = ' || TO_CHAR(p_sseguro) || ' - ' || SQLERRM);
         NULL;
   END fin;
END pac_cessgaliq;

/

  GRANT EXECUTE ON "AXIS"."PAC_CESSGALIQ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CESSGALIQ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CESSGALIQ" TO "PROGRAMADORESCSI";
