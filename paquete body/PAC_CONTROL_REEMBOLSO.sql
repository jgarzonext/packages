--------------------------------------------------------
--  DDL for Package Body PAC_CONTROL_REEMBOLSO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CONTROL_REEMBOLSO" AS
   /******************************************************************************
      NOM:    pac_control_reembolso
      PROPÓSIT: Validació de reemborsaments.
      REVISIONS:
      Ver        Data        Autor    Descripció
      ---------  ----------  ------  ------------------------------------
      1.0        --          --      1. Creación del package.
      2.0        26/06/2009  MCA     2. RMB20
      3.0        01/07/2009  DRA     3. 0010604: Nuevo control Reembolsos - Pago Retenido
      4.0        08/07/2009  DCT     4. 0010612: CRE - Error en la generació de pagaments automàtics.
                                     Canviar vista personas por tablas personas y añadir filtro de visión de agente
      5.0        01/07/2009  NMM     5. 10682: CRE - Modificaciones para módulo de reembolsos ( ncertif)
      6.0        21/07/2009  DRA     6. 0010761: CRE - Reembolsos
      7.0        31/08/2009  DRA     7. 0010949: CRE - Pruebas módulo reembolsos
      8.0        06/10/2009  DRA     8. 0011190: CRE- Modificaciones en módulo de reembolsos.
      9.0        02/11/2009  DRA     9. 0011631: CRE - Incidencia en pac_control_reembolso
      10.0       15/12/2009  NMM     10.12378: CRE - Control 14 para reembolsos.
      11.0       29/12/2009  NMM     11.12506: CRE201 - Control 13 para reembolsos.
      12.0       15/03/2010  DRA     12.0012676: CRE201 - Consulta de reembolsos - Ocultar descripción de Acto y otras mejoras
      13.0       26/03/2010  DRA     13.0013927: CRE049 - Control cambio de estado reembolso
      14.0       22/04/2010  DRA     14.0014227: CRE201 - Modificaciones reembolsos
      15.0       18/08/2010  FAL     15.0015770: CRE - Reemborsaments - control de import màxim per acte
      16.0       18/01/2011  DRA     16.0016576: AGA602 - Parametrització de reemborsaments per veterinaris
      17.0       22/06/2011  DRA     17.0018770: CRE800 - Consulta Reemborsaments
   ******************************************************************************/
   FUNCTION f_validareemb(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      psmancont NUMBER DEFAULT NULL,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      TYPE t_cursor IS REF CURSOR;

      c_valida       t_cursor;
      s              VARCHAR2(4000);
      v_resp         NUMBER;
      ncursor        PLS_INTEGER;
      filas          PLS_INTEGER;
      cur1           PLS_INTEGER;
      i              NUMBER;
      cerror         NUMBER;
   BEGIN
      FOR cur IN (SELECT   ccontrol, ctipo, tvalidacion
                      FROM controlsan
                     WHERE cambito = 'REEM'
                       AND agr_salud = pagr_salud
                       AND cestado = 1
                       AND ccontrol NOT IN(SELECT ccontrol
                                             FROM tmp_controlsan
                                            WHERE smancont = NVL(psmancont, -1))
                  ORDER BY norden) LOOP
         i := 1;

         WHILE i < LENGTH(cur.tvalidacion)
          AND SUBSTR(cur.tvalidacion, i, 1) <> '(' LOOP
            i := i + 1;
         END LOOP;

         s := SUBSTR(cur.tvalidacion, 1, i) || ptipo || ',' || psseguro || ',' || pnriesgo
              || ',' || pcgarant || ',' || psperson || ',''' || pagr_salud || ''',''' || pcacto
              || ''',' || pnacto || ',TO_DATE(''' || TO_CHAR(pfacto, 'ddmmyyyy')
              || ''',''DDMMYYYY''), ' || REPLACE(TO_CHAR(NVL(piimporte, 0)), ',', '.') || ','
              || pnreemb || ',' || pnfact || ',' || pnlinea || ',''' || pnfact_cli || ''','
              || 'TO_DATE(''' || TO_CHAR(pftrans, 'ddmmyyyy') || ''',''DDMMYYYY''))';
         s := 'select ' || s || ' from dual';
         cerror := 0;
         ncursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse(ncursor, s, DBMS_SQL.native);
         DBMS_SQL.define_column(ncursor, 1, v_resp);
         filas := DBMS_SQL.EXECUTE(ncursor);

         IF DBMS_SQL.fetch_rows(ncursor) > 0 THEN
            DBMS_SQL.COLUMN_VALUE(ncursor, 1, v_resp);
         END IF;

         DBMS_SQL.close_cursor(ncursor);

         IF v_resp <> 0 THEN
            RETURN v_resp;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_SQL.close_cursor(ncursor);
         p_tab_error(f_sysdate, f_user, 'pac_control_reembolso.f_validareemb', 1,
                     SUBSTR(s, 1, 500), SQLERRM);
         RETURN 111111;   --falta literal
   END f_validareemb;

   FUNCTION f_control_rmb01(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      num_err        NUMBER;
      vnpoliza       NUMBER;
      vfanulac       DATE;
      vfefecto       DATE;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      --1.Póliza o asegurado no activo en fecha de acto
      -- SELECT npoliza
      --  INTO vnpoliza
      --  FROM seguros
      -- WHERE sseguro = psseguro;
      num_err := f_vigente(psseguro, NULL, pfacto);

      -- La poliza no esta vigente
      IF num_err <> 0 THEN
         RETURN 1;
      END IF;

      SELECT fanulac, fefecto
        INTO vfanulac, vfefecto
        FROM riesgos
       WHERE nriesgo = pnriesgo
         AND sseguro = psseguro;

      IF vfefecto IS NOT NULL
         AND vfefecto > pfacto THEN
         RETURN 1;
      END IF;

      -- El riesgo no esta activo para la fecha pasada por parametro
      IF vfanulac IS NOT NULL
         AND vfanulac < pfacto THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_control_rmb01;

   FUNCTION f_control_rmb02(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vfiniefe       DATE;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      --La fecha de acto ha de ser superior o igual a la fecha de efecto de la garantía
      SELECT falta
        INTO vfiniefe
        FROM garanseg
       WHERE cgarant = pcgarant
         AND sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM garanseg
                         WHERE cgarant = pcgarant
                           AND sseguro = psseguro
                           AND nriesgo = pnriesgo);

      IF vfiniefe > pfacto THEN
         RETURN 2;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 2;
   END f_control_rmb02;

   FUNCTION f_control_rmb03(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      v_crespue      NUMBER;
      v_pregunfix    NUMBER(3) := 504;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Riesgo con restricciones
      BEGIN
         SELECT crespue
           INTO v_crespue
           FROM pregunseg
          WHERE cpregun = v_pregunfix
            AND sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = v_pregunfix
                              AND sseguro = psseguro
                              AND nriesgo = pnriesgo);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_crespue := NULL;
         WHEN TOO_MANY_ROWS THEN
            v_crespue := 1;
      END;

      IF NVL(v_crespue, 0) = 1
         AND pcacto NOT IN('C', 'D', 'DO', 'P', 'CD', 'AMP', 'OPT') THEN   -- BUG15770:FAL:18/08/2010
         RETURN 3;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 3;
   END f_control_rmb03;

   FUNCTION f_control_rmb04(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vncass_tit     VARCHAR2(20);
      vncass_mal     VARCHAR2(20);
      v_titular      VARCHAR2(2000);
      v_malalt       VARCHAR2(2000);
      vorigen        NUMBER;
      vnriesgotitular NUMBER;
      vpregun        NUMBER;
      vsproduc       NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF vsproduc = 258 THEN
         vpregun := 540;
      ELSE
         vpregun := 505;
      END IF;

      -- Asegurado CASS no corresponde con Titular de la póliza.
      BEGIN
         SELECT ncass_ase, ncass, corigen
           INTO vncass_tit, vncass_mal, vorigen
           FROM reembfact
          WHERE nreemb = pnreemb
            AND nfact = pnfact;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 4;
      END;

      BEGIN
         SELECT nriesgo
           INTO vnriesgotitular
           FROM pregunseg
          WHERE cpregun = vpregun
            AND crespue = 0
            AND sseguro = psseguro
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = vpregun
                              AND sseguro = psseguro
                              AND crespue = 0);

         SELECT trespue
           INTO v_titular
           FROM pregunseg
          WHERE cpregun = 530
            AND sseguro = psseguro
            AND nriesgo = vnriesgotitular
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = 530
                              AND sseguro = psseguro
                              AND nriesgo = vnriesgotitular);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_titular := '';
      END;

      BEGIN
         SELECT trespue
           INTO v_malalt
           FROM pregunseg
          WHERE cpregun = 530
            AND sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = 530
                              AND sseguro = psseguro
                              AND nriesgo = pnriesgo);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_malalt := '';
      END;

      IF (vncass_tit <> v_titular
          OR vncass_mal <> v_malalt)
         AND vorigen = 0 THEN
         RETURN 4;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 4;
   END f_control_rmb04;

   FUNCTION f_control_rmb05(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vcacto         NUMBER;
      v_estatfix     NUMBER := 1;   --Actiu
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Acto no contemplado para el producto o no activo.
      BEGIN
         SELECT 1
           INTO vcacto
           FROM actos_garanpro
          WHERE fvigencia <= pfacto
            AND(ffinvig > pfacto
                OR ffinvig IS NULL)
            AND agr_salud = pagr_salud
            AND cgarant = pcgarant
            AND cestado = v_estatfix
            AND cacto = pcacto;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 5;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 5;
   END f_control_rmb05;

   FUNCTION f_control_rmb06(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vrevision      VARCHAR2(2);
      v_estatfix     NUMBER := 1;   --Actiu
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Acto con restricciones
      BEGIN
         SELECT revision
           INTO vrevision
           FROM actos_garanpro
          WHERE cacto = pcacto
            AND cgarant = pcgarant
            AND agr_salud = pagr_salud
            AND fvigencia <= pfacto
            AND(ffinvig > pfacto
                OR ffinvig IS NULL)
            AND cestado = v_estatfix;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 6;
      END;

      IF UPPER(vrevision) = 'S' THEN
         RETURN 6;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 6;
   END f_control_rmb06;

   FUNCTION f_control_rmb07(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vcrespue       NUMBER;
      vfefecto       DATE;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Acto en carencias
      FOR cur IN (SELECT *
                    FROM actos_carencia
                   WHERE cacto = pcacto
                     AND agr_salud = pagr_salud) LOOP
         BEGIN
            SELECT crespue
              INTO vcrespue
              FROM pregunseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cpregun = cur.ccaren
               AND nmovimi IN(SELECT MAX(nmovimi)
                                FROM pregunseg
                               WHERE sseguro = psseguro
                                 AND nriesgo = pnriesgo
                                 AND cpregun = cur.ccaren);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcrespue := NULL;
         END;

         IF vcrespue IS NOT NULL THEN
            SELECT fefecto
              INTO vfefecto
              FROM seguros
             WHERE sseguro = psseguro;

            IF pfacto < ADD_MONTHS(vfefecto, vcrespue) THEN
               RETURN 7;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 7;
   END f_control_rmb07;

   FUNCTION f_control_rmb08(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vcsexo         NUMBER;
      vcsexper       NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Sexo no contemplado
      BEGIN
         SELECT csexo
           INTO vcsexo
           FROM actos_garanpro
          WHERE cacto = pcacto
            AND cgarant = pcgarant
            AND agr_salud = pagr_salud
            AND fvigencia <= pfacto
            AND(ffinvig > pfacto
                OR ffinvig IS NULL);

         SELECT csexper
           INTO vcsexper
           FROM per_personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 8;
      END;

      IF vcsexo <> 3
         AND vcsexo <> vcsexper THEN
         RETURN 8;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 8;
   END f_control_rmb08;

   FUNCTION f_control_rmb09(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vedatmin       NUMBER;
      vfnacimi       DATE;
      vedat          NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Edad mínima
      BEGIN
         SELECT edadmin
           INTO vedatmin
           FROM actos_garanpro
          WHERE cacto = pcacto
            AND cgarant = pcgarant
            AND agr_salud = pagr_salud
            AND fvigencia <= pfacto
            AND(ffinvig > pfacto
                OR ffinvig IS NULL);

         SELECT fnacimi
           INTO vfnacimi
           FROM per_personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9;
      END;

      SELECT TO_CHAR((f_sysdate), 'yyyy') - TO_CHAR(vfnacimi, 'yyyy')
        INTO vedat
        FROM DUAL;

      IF vedat < vedatmin THEN
         RETURN 9;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9;
   END f_control_rmb09;

   FUNCTION f_control_rmb10(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vedatmax       NUMBER;
      vfnacimi       DATE;
      vedat          NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Edad máxima
      BEGIN
         SELECT edadmax
           INTO vedatmax
           FROM actos_garanpro
          WHERE cacto = pcacto
            AND cgarant = pcgarant
            AND agr_salud = pagr_salud
            AND fvigencia <= pfacto
            AND(ffinvig > pfacto
                OR ffinvig IS NULL);

         SELECT fnacimi
           INTO vfnacimi
           FROM per_personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 10;
      END;

      SELECT TO_CHAR((f_sysdate), 'yyyy') - TO_CHAR(vfnacimi, 'yyyy')
        INTO vedat
        FROM DUAL;

      IF vedat > vedatmax THEN
         RETURN 10;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 10;
   END f_control_rmb10;

   FUNCTION f_control_rmb11(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vnacto         NUMBER;
      vcacto         NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Nº de actos por siniestro
      BEGIN
         SELECT nacto
           INTO vnacto
           FROM actos_garanpro
          WHERE cacto = pcacto
            AND cgarant = pcgarant
            AND agr_salud = pagr_salud
            AND fvigencia <= pfacto
            AND(ffinvig > pfacto
                OR ffinvig IS NULL);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 11;
      END;

      IF pnacto > vnacto THEN
         RETURN 11;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 11;
   END f_control_rmb11;

   FUNCTION f_control_rmb12(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vireemb        NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Importe acto
      SELECT ireemb
        INTO vireemb
        FROM actos_garanpro
       WHERE cacto = pcacto
         AND agr_salud = pagr_salud
         AND cgarant = pcgarant
         AND fvigencia <= pfacto
         AND(ffinvig > pfacto
             OR ffinvig IS NULL);

      IF (piimporte / pnacto) > vireemb   -- BUG15770:FAL:18/08/2010
         AND vireemb > 0 THEN
         RETURN 12;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 12;
   END f_control_rmb12;

   FUNCTION f_control_rmb13(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vsunnacto      NUMBER;
      vnactoany      NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Actos en un año
      SELECT SUM(nacto)
        INTO vsunnacto
        FROM reembactosfac a, reembolsos b
       WHERE b.sperson = psperson
         AND b.nreemb = a.nreemb
         AND a.cacto = pcacto
         AND TO_CHAR(a.facto, 'YYYY') = TO_CHAR(f_sysdate, 'YYYY')   -- 12506.NMM.12/2009.i.
         AND b.cestado <> 4
         AND a.fbaja IS NULL;   -- 12506.NMM.12/2009.f.

      SELECT nactoany
        INTO vnactoany
        FROM actos_garanpro
       WHERE cacto = pcacto
         AND agr_salud = pagr_salud
         AND cgarant = pcgarant
         AND fvigencia <= pfacto
         AND(ffinvig > pfacto
             OR ffinvig IS NULL);

      IF vsunnacto > vnactoany
         AND vnactoany > 0 THEN
         RETURN 13;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 13;
   END f_control_rmb13;

   FUNCTION f_control_rmb14(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vireembany     NUMBER;
      vsunipago      NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Importe acto en un año
      SELECT SUM(ipago)
        INTO vsunipago
        FROM reembactosfac a, reembolsos b
       WHERE b.sperson = psperson
         AND b.nreemb = a.nreemb
         AND a.cacto = pcacto
         -- Mantis 12378.NMM.15/12/2009.i. Excloure reemborsaments amb estat 4 i els donats de baixa,
         -- canviar falta per facto
         AND TO_CHAR(a.facto, 'YYYY') = TO_CHAR(f_sysdate, 'YYYY')
         AND b.cestado <> 4
         AND a.fbaja IS NULL;

      SELECT ireembany
        INTO vireembany
        FROM actos_garanpro
       WHERE cacto = pcacto
         AND cgarant = pcgarant
         AND agr_salud = pagr_salud
         AND fvigencia <= pfacto
         AND(ffinvig > pfacto
             OR ffinvig IS NULL);

      IF vsunipago > vireembany
         AND vireembany > 0 THEN
         RETURN 14;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 14;
   END f_control_rmb14;

   FUNCTION f_control_rmb15(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vsunnacto      NUMBER;
      vnmaxacto      NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Nº máximo de actos
      SELECT SUM(nacto)
        INTO vsunnacto
        FROM reembactosfac a, reembolsos b
       WHERE a.cacto = pcacto
         AND b.sperson = psperson
         AND b.nreemb = a.nreemb;

      SELECT nmaxacto
        INTO vnmaxacto
        FROM actos_garanpro
       WHERE cacto = pcacto
         AND cgarant = pcgarant
         AND agr_salud = pagr_salud
         AND fvigencia <= pfacto
         AND(ffinvig > pfacto
             OR ffinvig IS NULL);

      IF vsunnacto > vnmaxacto
         AND vnmaxacto > 0 THEN
         RETURN 15;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 15;
   END f_control_rmb15;

   FUNCTION f_control_rmb16(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vipago         NUMBER;
      vimaxreemb     NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Importe máximo por acto
      SELECT SUM(ipago)
        INTO vipago
        FROM reembactosfac a, reembolsos b
       WHERE a.cacto = pcacto
         AND b.sperson = psperson
         AND b.nreemb = a.nreemb;

      SELECT imaxreemb
        INTO vimaxreemb
        FROM actos_garanpro
       WHERE cacto = pcacto
         AND cgarant = pcgarant
         AND agr_salud = pagr_salud
         AND fvigencia <= pfacto
         AND(ffinvig > pfacto
             OR ffinvig IS NULL);

      IF vipago > vimaxreemb
         AND vimaxreemb > 0 THEN
         RETURN 16;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 16;
   END f_control_rmb16;

   FUNCTION f_control_rmb17(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      viextra        NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Importe Extra
      BEGIN
         SELECT NVL(iextra, 0)
           INTO viextra
           FROM reembactosfac
          WHERE nreemb = pnreemb
            AND nfact = pnfact
            AND nlinea = pnlinea;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            viextra := 0;
      END;

      IF viextra > 0 THEN
         RETURN 17;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 17;
   END f_control_rmb17;

   FUNCTION f_control_rmb18(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vcount         NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Acto duplicado mismo día.
      SELECT COUNT(r1.nreemb)
        INTO vcount
        FROM reembolsos r1, reembfact r2, reembactosfac r3
       WHERE r1.nreemb = r2.nreemb
         AND r2.nfact_cli = pnfact_cli   -- BUG10761:DRA:21/07/2009
         AND r3.nreemb = r2.nreemb
         AND r3.nfact = r2.nfact
         AND r3.cacto = pcacto
         AND TRUNC(r3.facto) = TRUNC(pfacto)
         -- AND r1.nreemb <> pnreemb
         -- AND r2.nfact <> pnfact
         -- AND r2.nlinea <> pnlinea;
         AND r1.sperson = psperson
         AND r1.cestado NOT IN(4, 5)
         AND r3.fbaja IS NULL;

      --      IF vcount > 0 THEN
      IF vcount > 1 THEN
         RETURN 18;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 18;
   END f_control_rmb18;

   FUNCTION f_control_rmb19(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vcount         NUMBER;
      vipago         NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi
      SELECT COUNT(r1.nreemb)
        INTO vcount
        FROM reembolsos r1, reembactosfac r2
       WHERE r1.nreemb = r2.nreemb
         AND r2.cacto = pcacto
         AND TRUNC(r2.facto) >= TRUNC(pfacto) - 5
         AND TRUNC(r2.facto) <= TRUNC(pfacto) + 5
         --        AND r1.nreemb <> pnreemb
         --        AND r2.nfact <> pnfact
         --        AND r2.nlinea <> pnlinea;
         AND r1.sperson = psperson
         AND r1.cestado NOT IN(4, 5)
         AND r2.fbaja IS NULL;

      -- JFD 20110607 - solament es controla la farmàcia superior a 10 €
      IF pcacto = 'FA' THEN
         SELECT ipago
           INTO vipago
           FROM reembactosfac
          WHERE nreemb = pnreemb
            AND nfact = pnfact
            AND nlinea = pnlinea;
      END IF;

      IF vcount > 1
         AND pcacto <> 'FA' THEN
         RETURN 19;
      ELSIF vcount > 1
            AND pcacto = 'FA'
            AND vipago > 10 THEN
         RETURN 19;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_control_rmb19;

   FUNCTION f_control_rmb20(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      vpreemb        NUMBER(5, 2);
      vcorigen       reembactosfac.corigen%TYPE;
      vpreemb_real   NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- BUG 8072.MCA.26/06/2009.INI.
      --Revisión % de reembolso
      BEGIN
         SELECT preemb, corigen, ROUND((icass / itarcass) * 100)
           INTO vpreemb, vcorigen, vpreemb_real
           FROM reembactosfac
          WHERE nreemb = pnreemb
            AND nfact = pnfact
            AND nlinea = pnlinea;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 20;
      END;

      IF vcorigen = 0   -- automático
         AND(vpreemb IS NULL
             OR vpreemb <> 75
             OR vpreemb_real <> vpreemb) THEN
         RETURN 20;
      END IF;

      IF vcorigen = 1
         AND(vpreemb IS NOT NULL
             AND vpreemb <> 75
             OR vpreemb_real <> vpreemb) THEN
         RETURN 20;
      END IF;

      RETURN 0;
   -- BUG 8072.MCA.26/06/2009.FIN.
   END f_control_rmb20;

   FUNCTION f_control_rmb21(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      v_fnac         DATE;
      v_dif          NUMBER;
      v_err          NUMBER;
      vrespuesta     pregunseg.crespue%TYPE;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      --Bug 10682.NMM.01/07/2009.i.

      -- Edad del asegurado (hijo) superior a 25 años
      SELECT crespue
        INTO vrespuesta
        FROM pregunseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM pregunseg
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND cpregun = 505)
         AND cpregun = 505;

      IF vrespuesta = 2 THEN   --Es hijo
         SELECT fnacimi
           INTO v_fnac
           FROM per_personas
          WHERE sperson = psperson;

         /*SELECT fnacimi
                                                                                  INTO v_fnac
            FROM personas
           WHERE sperson = (SELECT sperson
                              FROM asegurados
                             WHERE sseguro = psseguro
                               AND norden = c.nriesgo);*/
         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         v_err := f_difdata(v_fnac, f_sysdate, 1, 1, v_dif);

         IF v_err = 0 THEN
            IF v_dif > 25 THEN
               RETURN 21;
            END IF;
         END IF;
      END IF;

      --Bug 10682.NMM.01/07/2009.f.
      RETURN 0;
   END f_control_rmb21;

   FUNCTION f_control_rmb22(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      v_ffactura     DATE;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Fecha acto no puede ser superior a fecha factura
      SELECT ffactura
        INTO v_ffactura
        FROM reembfact
       WHERE nreemb = pnreemb
         AND nfact = pnfact;

      IF pfacto > v_ffactura THEN
         RETURN 22;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_control_rmb22;

   FUNCTION f_control_rmb23(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      v_aux          NUMBER;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- Ya existe otra factura con este nº de hoja
      SELECT 1
        INTO v_aux
        FROM reembolsos r, reembfact r1
       WHERE r.nreemb = r1.nreemb
         AND r.cestado NOT IN(4, 5)
         AND r1.nfact_cli = pnfact_cli
         AND r1.fbaja IS NULL
         AND r1.corigen = 1
         --AND    R1.NFACT = (SELECT MAX(NFACT) FROM REEMBFACT R2 WHERE R2.NREEMB = R1.NREEMB AND R2.FBAJA IS NULL AND R2.CORIGEN = 1)
         AND NOT(r1.nreemb = pnreemb
                 AND r1.nfact = pnfact)
         AND ROWNUM = 1;

      RETURN 23;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_control_rmb23;

   FUNCTION f_control_rmb24(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      v_aux          NUMBER := 0;
   BEGIN
      -- BUG10761:DRA:27/07/2009:Inici
      IF pftrans IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      -- BUG10761:DRA:27/07/2009:Fi

      -- BUG14227:DRA:22/04/2010:Inici
      SELECT creteni
        INTO v_aux
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(v_aux, 0) <> 0 THEN
         RETURN 24;
      END IF;

      -- BUG14227:DRA:22/04/2010:Fi

      -- La póliza tiene algún recibo pendiente
      SELECT 1
        INTO v_aux
        FROM recibos r, movrecibo m
       WHERE r.nrecibo = m.nrecibo
         AND r.sseguro = psseguro
         AND m.cestrec = 0
         AND m.cestant = 1   -- BUG11631:DRA:02/11/2009
         AND m.fmovfin IS NULL
         AND ROWNUM = 1;

      RETURN 24;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_control_rmb24;

   -- BUG10949:DRA:25/08/2009:Inici
   /*************************************************************************
                         FUNCTION f_control_rmb25
    Valida si se informa el pago complemento pero no existe factura complementaria
        param in ptipo       : tipo
        param in psseguro    : código del seguro
        param in pnriesgo    : código del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb25(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      v_ipagocomp    reembactosfac.ipagocomp%TYPE;
      v_ftranscomp   reembactosfac.ftranscomp%TYPE;
      v_existe       NUMBER;
   BEGIN
      -- Este control también se valida aunque este transferido
      SELECT ipagocomp, ftranscomp
        INTO v_ipagocomp, v_ftranscomp
        FROM reembactosfac
       WHERE nreemb = pnreemb
         AND nfact = pnfact
         AND nlinea = pnlinea;

      IF v_ftranscomp IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      SELECT COUNT(1)
        INTO v_existe
        FROM reembfact
       WHERE nreemb = pnreemb
         AND fbaja IS NULL
         AND ctipofac = 0;   --> Es decir, si es complementaria

      IF NVL(v_ipagocomp, 0) <> 0
         AND v_existe = 0 THEN
         RETURN 25;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_control_rmb25;

   /*************************************************************************
                                                                                                                                                                                                                                                                                                                                                               FUNCTION f_control_rmb26
    Valida si se informa el pago complemento en un reembolso de la agrupacion 2
        param in ptipo       : tipo
        param in psseguro    : código del seguro
        param in pnriesgo    : código del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb26(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      v_ipagocomp    reembactosfac.ipagocomp%TYPE;
      v_ftranscomp   reembactosfac.ftranscomp%TYPE;
   BEGIN
      -- Este control también se valida aunque este transferido
      SELECT ipagocomp, ftranscomp
        INTO v_ipagocomp, v_ftranscomp
        FROM reembactosfac
       WHERE nreemb = pnreemb
         AND nfact = pnfact
         AND nlinea = pnlinea;

      IF v_ftranscomp IS NOT NULL THEN
         -- Si ya está transferido no evaluamos
         RETURN 0;
      END IF;

      IF NVL(v_ipagocomp, 0) <> 0
         AND pagr_salud = 2 THEN
         RETURN 26;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_control_rmb26;

   -- BUG10949:DRA:25/08/2009:Fi

   -- BUG11190:DRA:06/10/2009:Inici
   /*************************************************************************
                         FUNCTION f_control_rmb27
    La suma total de los importes (ipago + ipagocomp + icass) de todos los
     registros de actos en un reembolso han de inferior o igual a la suma
     del importe de las factura complementarias del reembolso.
        param in ptipo       : tipo
        param in psseguro    : código del seguro
        param in pnriesgo    : código del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb27(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      --
      v_impactos     NUMBER;
      v_impcomp      NUMBER;
      v_ipagocomp    reembactosfac.ipagocomp%TYPE;
      v_ftranscomp   reembactosfac.ftranscomp%TYPE;
      v_existe       NUMBER;
   BEGIN
      -- Este control también se valida aunque este transferido
      SELECT ipagocomp
        INTO v_ipagocomp
        FROM reembactosfac
       WHERE nreemb = pnreemb
         AND nfact = pnfact
         AND nlinea = pnlinea;

      IF v_ipagocomp IS NULL THEN
         -- No se está informando un pago complementario, saltamos la validacion
         RETURN 0;
      END IF;

      SELECT SUM(NVL(a.ipago, 0) + NVL(a.ipagocomp, 0) + NVL(a.icass, 0))
        INTO v_impactos
        FROM reembactosfac a
       WHERE a.nreemb = pnreemb
         AND a.nfact IN(SELECT f.nfact
                          FROM reembfact f
                         WHERE f.nreemb = a.nreemb
                           AND f.ctipofac = 1);

      SELECT SUM(NVL(f.impfact, 0))
        INTO v_impcomp
        FROM reembfact f
       WHERE f.nreemb = pnreemb
         AND f.fbaja IS NULL
         AND f.ctipofac = 0;   --> Es decir, si es complementaria

      IF NVL(v_impcomp, 0) < NVL(v_impactos, 0) THEN
         RETURN 27;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_control_rmb27;

   -- BUG11190:DRA:06/10/2009:Fi
   FUNCTION f_control_rmb28(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)
      RETURN NUMBER IS
      --
      v_impactos     NUMBER;
      v_impcomp      NUMBER;
      v_ipagocomp    reembactosfac.ipagocomp%TYPE;
      v_ftranscomp   reembactosfac.ftranscomp%TYPE;
      v_existe       NUMBER;
      w_anyo         NUMBER;
   BEGIN
      w_anyo := TO_CHAR(pfacto, 'YYYY');

      IF NVL(pagr_salud, 0) <> 6
         AND pcacto NOT IN('ZD', 'P', 'DO', 'D', 'CDQ', 'CD') THEN
         -- Si no es de la agrupaci?n 6 no lo validamos
         RETURN 0;
      END IF;

      SELECT SUM(NVL(a.ipago, 0) + NVL(a.ipagocomp, 0) + NVL(a.icass, 0))
        INTO v_impactos
        FROM reembactosfac a, reembolsos b
       WHERE a.cacto IN('ZD', 'P', 'DO', 'D', 'CDQ', 'CD')
         AND a.nreemb = b.nreemb
         AND a.facto BETWEEN TO_DATE('01/01/' || w_anyo, 'dd/mm/yyyy')
                         AND TO_DATE('31/12/' || w_anyo, 'dd/mm/yyyy')
         AND b.sseguro = psseguro
         AND b.nriesgo = pnriesgo
         AND b.nreemb <> pnreemb;

      v_impactos := NVL(v_impactos, 0) + piimporte;

      IF v_impactos > 750 THEN   -- Si superen els 750 euros retornem el id d'error.
         RETURN 28;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_control_rmb28;

   -- BUG15179:smf:22/10/2010:Inici
   /*************************************************************************
                         FUNCTION f_control_rmb29
        Se controla que el producto de autonomos no pague m?s de 750 euros por todos los
    actos relacionados con el dentista en un a?o. Autonomos es agr_salud =6
        param in ptipo       : tipo
        param in psseguro    : codigo del seguro
        param in pnriesgo    : codigo del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb29(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)
      RETURN NUMBER IS
      --
      v_impactos     NUMBER;
      v_impcomp      NUMBER;
      v_ipagocomp    reembactosfac.ipagocomp%TYPE;
      v_ftranscomp   reembactosfac.ftranscomp%TYPE;
      v_existe       NUMBER;
      w_anyo         NUMBER;
      v_falta        NUMBER;
   BEGIN
      w_anyo := TO_CHAR(pfacto, 'YYYY');

      IF NVL(pagr_salud, 0) NOT IN(4, 5)
         AND pcacto <> 'OR' THEN
         -- Si no es de la agrupaci?n 4 ? 5 , no hay que hacer esta validaci?n. Solo en caso de ortopedia
         -- si el producto esta bien parametrizado no lo har?, pero como hay usuarios torpes...
         RETURN 0;
      END IF;

      -- obtenemos el a?o de alta del riesgo
      SELECT TO_CHAR(fefecto, 'yyyy')
        INTO v_falta
        FROM riesgos
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo;

      SELECT SUM(NVL(a.ipago, 0) + NVL(a.ipagocomp, 0) + NVL(a.icass, 0))
        INTO v_impactos
        FROM reembactosfac a, reembolsos b
       WHERE a.cacto = pcacto
         AND a.nreemb = b.nreemb
         AND a.facto BETWEEN TO_DATE('01/01/' || w_anyo, 'dd/mm/yyyy')
                         AND TO_DATE('31/12/' || w_anyo, 'dd/mm/yyyy')
         AND b.sseguro = psseguro
         AND b.nriesgo = pnriesgo
         AND b.nreemb <> pnreemb;

      v_impactos := NVL(v_impactos, 0) + piimporte;

      IF w_anyo < v_falta + 2
                             -- si est? en els dos primers anys des de la contractaci?
      THEN
         IF pagr_salud = 4 THEN
            IF v_impactos > 470 THEN
               RETURN 29;
            END IF;
         ELSE
            IF v_impactos > 823 THEN
               RETURN 29;
            END IF;
         END IF;
      ELSE   -- si est? en els dos primers anys des de la contractaci?
         IF pagr_salud = 4 THEN
            IF v_impactos > 706 THEN
               RETURN 29;
            END IF;
         ELSE
            IF v_impactos > 1176 THEN
               RETURN 29;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_control_rmb29;

   -- BUG16576:DRA:18/01/2011:Fi
   /*************************************************************************
   FUNCTION f_control_rmb30
    Se controla que no haya más de un acto cada 5 años
        param in ptipo       : tipo
        param in psseguro    : codigo del seguro
        param in pnriesgo    : codigo del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb30(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)
      RETURN NUMBER IS
      --
      v_impactos     NUMBER;
      v_impmaxacto   NUMBER;
      v_numanys      NUMBER := 5;
   BEGIN
      IF NVL(pagr_salud, 0) NOT IN(6, 7, 8)
         OR pcacto <> 'NETBOC' THEN
         -- Si no es de la agrupación 6, 7, 8 , no hay que hacer esta validación.
         -- Solo en caso de "Neteja de Boca"
         RETURN 0;
      END IF;

      BEGIN
         SELECT ireemb
           INTO v_impmaxacto
           FROM actos_garanpro
          WHERE fvigencia <= pfacto
            AND(ffinvig > pfacto
                OR ffinvig IS NULL)
            AND agr_salud = pagr_salud
            AND cgarant = pcgarant
            AND cestado = 1
            AND cacto = pcacto;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;
      END;

      SELECT SUM(NVL(a.ipago, 0) + NVL(a.ipagocomp, 0) + NVL(a.icass, 0))
        INTO v_impactos
        FROM reembactosfac a, reembolsos b
       WHERE a.cacto = pcacto
         AND a.nreemb = b.nreemb
         AND a.facto BETWEEN ADD_MONTHS(pfacto, -12 * v_numanys) AND pfacto
         AND b.sseguro = psseguro
         AND b.nriesgo = pnriesgo
         AND b.nreemb <> pnreemb;

      IF NVL(v_impactos, 0) + NVL(piimporte, 0) > v_impmaxacto THEN
         -- Hay algun acto introducido en un margen de 5 años y la suma de estos supera el máximo permitido
         RETURN 30;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_control_rmb30;

   -- BUG16576:DRA:18/01/2011:Fi

   -- BUG10604:DRA:01/07/2009:Inici
   /*************************************************************************
                         FUNCTION f_control_rmb100
    Valida si es de origen manual o automatico
        param in ptipo       : tipo
        param in psseguro    : código del seguro
        param in pnriesgo    : código del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb100(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER IS
      v_aux          NUMBER := 0;
   BEGIN
      -- Si es de origen manual, Pago Retenido
      SELECT corigen
        INTO v_aux
        FROM reembactosfac
       WHERE nreemb = pnreemb
         AND nfact = pnfact
         AND nlinea = pnlinea;

      IF NVL(v_aux, 0) <> 0 THEN
         RETURN 100;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_control_rmb100;
-- BUG10604:DRA:01/07/2009:Fi
END pac_control_reembolso;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONTROL_REEMBOLSO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONTROL_REEMBOLSO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONTROL_REEMBOLSO" TO "PROGRAMADORESCSI";
