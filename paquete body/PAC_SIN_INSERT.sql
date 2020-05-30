--------------------------------------------------------
--  DDL for Package Body PAC_SIN_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIN_INSERT" IS
/***************************************************************
    PAC_SIN_INSERT: Cuerpo del paquete de las
        funciones para la inserción de registros en
        las tablas de siniestros para los formularios
        de entrada rápida de siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        ???          ???              1. Creación del package.
   2.0        30/06/2009   DRA              2. 0010581: CRE - Error en la generació automàtica de pagaments de sinistres, i la posterior generació de transferències
   3.0        22/09/2009   DRA              3. 0011183: CRE - Suplemento de alta de asegurado ya existente
   4.0        11/03/2010   JRH              4. 0012136: CEM - RVI - Verificación productos RVI
   5.0        20/09/2010   JRH              5. 0015869: CIV401 - Renta vitalícia: incidencias 12/08/2010
   6.0        17/10/2011   JMP              6. 0019027: LCOL760 - Tamany del camp CRAMO
   7.0        20/10/2011   RSC              7. 0019425/94998: CIV998-Activar la nova gestio de traspassos
***************************************************************/
   FUNCTION ff_contador_siniestros(pcramo IN NUMBER, pmodali IN NUMBER, pccausin IN NUMBER)
      RETURN NUMBER IS
      v_nsinies      NUMBER;
      v_cagrpro      productos.cagrpro%TYPE;   --       v_cagrpro      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      SELECT DISTINCT cagrpro
                 INTO v_cagrpro
                 FROM productos
                WHERE cramo = pcramo;

      IF pccausin = 1 THEN   -- Siniestro
         -- Si el cramo es de vida riesgo (cagrpro = 1)
         IF v_cagrpro = 1 THEN
            v_nsinies := f_contador('01', pcramo);
         ELSE
            v_nsinies := f_contador('01', 99);
         END IF;
      ELSIF pccausin IN(3, 4, 5) THEN   -- Rescate o vencimiento
         v_nsinies := f_contador('01', LPAD(pcramo, 2, '0') || pmodali);
      ELSE
         v_nsinies := f_contador('01', pcramo);
      END IF;

      RETURN v_nsinies;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_contador_siniestros;

   FUNCTION f_insert_siniestros(
      pnsinies OUT NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pcestsin IN NUMBER,
      ptsinies IN VARCHAR2,
      pccausin IN NUMBER,
      pnsinref IN NUMBER)
      RETURN NUMBER IS
      vcramo         seguros.cramo%TYPE;
      vcmodali       seguros.cmodali%TYPE;   --       vcmodali       NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcrefint       siniestros.crefint%TYPE;   --       vcrefint       VARCHAR2(50); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vctipcoa       seguros.ctipcoa%TYPE;   --       vctipcoa       NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vnmovimi       NUMBER(4);
      vcdelega       siniestros.cdelega%TYPE;   --       vcdelega       NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vuser          siniestros.cusuari%TYPE;   --       vuser          VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vdata          siniestros.festsin%TYPE;   --       vdata          DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      aux            NUMBER;
      vnriesgo       siniestros.nriesgo%TYPE;   --       vnriesgo       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vnasegur       NUMBER;
      vsproduc       seguros.sproduc%TYPE;   --       vsproduc       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      vuser := f_user;
      vdata := f_sysdate;

      SELECT cramo, ctipcoa, cmodali, sproduc
        INTO vcramo, vctipcoa, vcmodali, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      --aux := f_nmovimi( psseguro, vdata, vnmovimi );
      --if aux <> 0 then
      --  return aux;
      --end if;
      vcdelega := f_delega(psseguro, vdata);

      IF NVL(f_parinstalacion_n('CONTSINIES'), 0) = 1 THEN   -- 'Contador de siniestros y rescates diferentes?' = 1 (Sí)
         pnsinies := ff_contador_siniestros(vcramo, vcmodali, pccausin);
      ELSE
         pnsinies := f_contador('01', vcramo);
      END IF;

      IF pnsinies = 0 THEN
         RETURN -1;
      END IF;

      aux := pac_sin.f_crefint(pnsinies, vuser, vcrefint);

      IF aux <> 0 THEN
         RETURN aux;
      END IF;

      -- Bug 15869 - 20/09/2010 - JRH - Rentas CIV 2 cabezas

      -- Si el producto es a 2_CABEZAS
      IF NVL(f_parproductos_v(vsproduc, '2_CABEZAS'), 0) = 1 THEN
         vnriesgo := 1;
         vnasegur := pnriesgo;
      ELSE   -- Si el producto NO es a 2_CABEZAS
         vnriesgo := pnriesgo;
         vnasegur := NULL;
      END IF;

-- Fi Bug 15869 - 20/09/2010 - JRH
      INSERT INTO siniestros
                  (nsinies, sseguro, nriesgo, cusuari, fsinies, fnotifi, cestsin,
                   tsinies, ccausin, festsin, fentrad, crefint, cramo, cdelega, ctipcoa,
                   cunimix, caseta, cideasc, ctcausin, nasegur)
           VALUES (pnsinies, psseguro, vnriesgo, vuser, pfsinies, pfnotifi, pcestsin,
                   ptsinies, pccausin, vdata, vdata, vcrefint, vcramo, vcdelega, vctipcoa,
                   0, 0, 0, 1, vnasegur);

      RETURN 0;
   END f_insert_siniestros;

---------------------------------------------------------------
   FUNCTION f_insert_localizatrami(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      ptubicac IN VARCHAR2,
      ptcontac IN VARCHAR2,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      psperson IN NUMBER,
      pcpoblac IN NUMBER,
      pcpostal IN codpostal.cpostal%TYPE,
      ptlocali IN VARCHAR2,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      aux            NUMBER;
      no_nul         EXCEPTION;
      vnlocali       localizatrami.nlocali%TYPE;   --       vnlocali       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vflocali       DATE;
   BEGIN
      IF (pnsinies IS NULL
          OR pntramit IS NULL
          OR pcpais IS NULL
          OR pcprovin IS NULL
          OR ptlocali IS NULL
          OR pcidioma IS NULL) THEN
         RAISE no_nul;
      END IF;

      SELECT NVL(MAX(nlocali), 0) + 1
        INTO vnlocali
        FROM localizatrami
       WHERE nsinies = pnsinies
         AND ntramit = pntramit;

      SELECT TRUNC(fsinies)
        INTO vflocali
        FROM siniestros
       WHERE nsinies = pnsinies;

      INSERT INTO localizatrami
                  (nsinies, ntramit, nlocali, cpais, cprovin, cpoblac, cpostal,
                   tlocali, flocali, sperson, tubicac, tcontac)
           VALUES (pnsinies, pntramit, vnlocali, pcpais, pcprovin, pcpoblac, pcpostal,
                   ptlocali, vflocali, psperson, ptubicac, ptcontac);

      aux := pac_sin.f_mantdiario_locali(pnsinies, pntramit, pcidioma, vnlocali);
      RETURN 0;
   EXCEPTION
      WHEN no_nul THEN
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_insert_localizatrami;

---------------------------------------------------------------------------------------------
   /*
    {Genera registro de valoración}
   */
   FUNCTION f_insert_valoraciones(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE,
      pivalora IN NUMBER,
      pipenali IN NUMBER,
      picaprisc IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
      pivalora_aux   valorasini.ivalora%TYPE;   --       pivalora_aux   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      pivalora_aux := f_round(pivalora);

      BEGIN
         INSERT INTO valorasini
                     (nsinies, cgarant, fvalora, ivalora, ipenali, icaprisc)
              VALUES (pnsinies, pcgarant, pfecha, pivalora_aux, pipenali, picaprisc);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102695;   --{Error al insertar en la tabla VALORACIONES}
      END;

      num_err := pac_sin.f_mantdiario_valora(pnsinies, 0, pcgarant, 1);
      RETURN 0;
   END f_insert_valoraciones;

   /*
    { Genera registros destinatarios }
   */
   FUNCTION f_insert_destinatarios(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ppagdes IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pivalora IN NUMBER,
      pcactpro IN NUMBER,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER
                   /* se vuel a cargar la función original con los cambios
                   relacionados con las modificaciones de cuentas bancarias */
   IS
      --
      num_err        NUMBER;

      --
      CURSOR c_asegurados IS
         SELECT   a.sperson, a.norden
             FROM asegurados a
            WHERE a.sseguro = psseguro
              AND a.ffecmue IS NULL
              AND a.ffecfin IS NULL   -- BUG11183:DRA:22/09/2009
         ORDER BY a.norden;

      --
      xcuenta        seguros.cbancar%TYPE;
      xcuenta1       seguros.cbancar%TYPE;
      xcuenta2       seguros.cbancar%TYPE;
      xctipban       seguros.ctipban%TYPE;
      xctipban1      seguros.ctipban%TYPE;
      xctipban2      seguros.ctipban%TYPE;
      xriesgo        NUMBER;
      ndestina       NUMBER;
      ntotal         NUMBER;
      vsproduc       seguros.sproduc%TYPE;   --       vsproduc       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   --
   BEGIN
      -- Si es producto es a '2_CABEZAS', el valor del parámetro pnriesgo será el norden del Asegurado
      -- Si el proudcto NO es a '2_CABEZAS', el valor del parámetro pnriesgo será el nriesgo del Riesgo

      --{Selecionamos la cuenta del seguro, si no nos informan ninguna cuenta por defecto}
      IF pcbancar IS NULL THEN
         BEGIN
            SELECT cbancar, ctipban
              INTO xcuenta1, xctipban1
              FROM seguros s
             WHERE s.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xcuenta1 := NULL;
               xctipban1 := NULL;
         END;
      ELSE
         xcuenta1 := pcbancar;
         xctipban1 := pctipban;   -- BUG10581:DRA:30/06/2009
      END IF;

      IF pcbancar2 IS NULL THEN
         xcuenta2 := xcuenta1;
         xctipban2 := xctipban1;
      ELSE
         xcuenta2 := pcbancar2;
         xctipban2 := pctipban2;
      END IF;

      -- Si el producto es a '2_CABEZAS', el sperson se busca de la tabla Asegurados
      -- Sino de la tabla Riesgos
      BEGIN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101919;   -- Error al leer datos de la tabla SEGUROS
      END;

      IF NVL(f_parproductos_v(vsproduc, '2_CABEZAS'), 0) = 1 THEN
         -- Se debe buscar el sperson de la persona que queda vigente, no de la fallecida
         BEGIN
            SELECT sperson
              INTO xriesgo
              FROM asegurados a
             WHERE a.sseguro = psseguro
               -- Bug 12136 - JRH - 11/03/2010 - JRH - Es un igual no un <>
               AND a.norden = NVL(pnriesgo, 1)
               -- Fi Bug 12136 - JRH - 11/03/2010
               AND a.ffecfin IS NULL;   -- BUG11183:DRA:22/09/2009
         EXCEPTION
            WHEN OTHERS THEN
               -- Por si acaso sólo hay un asegurado
               xriesgo := pnriesgo;
         END;
      ELSE
         BEGIN
            SELECT sperson
              INTO xriesgo
              FROM riesgos r
             WHERE r.sseguro = psseguro
               AND nriesgo = NVL(pnriesgo, 1);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 105709;   --{Riesgo no encontrado en la tabla ...}
         END;
      END IF;

      FOR aseg IN c_asegurados LOOP
          /*
          { Si el producto indica que solo tiene que hacer un pago por
          siniestro solo lo hacemos al riesgo}
         */
         IF (NVL(ppagdes, 0) = 1
             AND xriesgo = aseg.sperson)
            OR(NVL(ppagdes, 0) = 0) THEN
            IF aseg.norden = 1 THEN
               xcuenta := xcuenta1;
               xctipban := xctipban1;
            --{Si es el 1er aseg. agafem la seva compte}
            ELSIF aseg.norden = 2 THEN
               xcuenta := xcuenta2;
               xctipban := xctipban2;
            END IF;

            BEGIN
               INSERT INTO destinatarios
                           (nsinies, sperson, ctipdes, cpagdes, ivalora, cactpro, cbancar,
                            ctipban)
                    VALUES (pnsinies, aseg.sperson, 1, pcpagdes, pivalora, pcactpro, xcuenta,
                            xctipban);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 102696;
            --{Error a l' inserir a la taula DESTINATARIOS}
            END;

            num_err := pac_sin.f_mantdiario_desti(pnsinies, 0, aseg.sperson, 1);
         END IF;
      END LOOP;

      --MCA  se asigna según el nº de destinatarios y se actualiza pais de residencia
      SELECT COUNT('x')
        INTO ndestina
        FROM destinatarios
       WHERE nsinies = pnsinies;

      IF ndestina > 0 THEN
         UPDATE destinatarios
            SET pasigna = ROUND(100 / ndestina, 2),
                cpaisresid = (SELECT cpais
                                FROM personas
                               WHERE sperson = destinatarios.sperson)
          WHERE nsinies = pnsinies;

         SELECT SUM(NVL(pasigna, 0))
           INTO ntotal
           FROM destinatarios
          WHERE nsinies = pnsinies;

         IF ntotal <> 100 THEN
            --Asignación para llegar al 100%
            UPDATE destinatarios
               SET pasigna = pasigna + 0.01
             WHERE nsinies = pnsinies
               AND ROWNUM = 1;
         END IF;
      END IF;

      ----
      RETURN 0;
   END f_insert_destinatarios;

   /*
   { Genera resgistro de pagos}
   */
   FUNCTION f_insert_pago(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pdes IN NUMBER,
      pffecmov IN DATE,
      pctipdes IN NUMBER,
      psperson IN NUMBER,
      pctippag IN NUMBER,
      pcestpag IN NUMBER,
      pcforpag IN NUMBER,
      pccodcon IN NUMBER,
      pcmanual IN NUMBER,
      pcimpres IN NUMBER,
      pfefepag IN DATE,
      pfordpag IN DATE,
      pnmescon IN DATE,
      ptcoddoc IN NUMBER,
      pisinret IN NUMBER,
      piconret IN NUMBER,
      piretenc IN NUMBER,
      piimpiva IN NUMBER,
      ppretenc IN NUMBER,
      pcptotal IN NUMBER,
      pfimpres IN DATE,
      moneda IN NUMBER,
      pmuerto IN NUMBER,
      pirendi IN NUMBER,
      pireduc IN NUMBER,
      pimpsin IN NUMBER)
      RETURN NUMBER IS
      --
      CURSOR c_asegurados IS
         SELECT   a.sperson
             FROM asegurados a
            WHERE a.sseguro = psseguro
              AND a.ffecmue IS NULL
              AND a.ffecfin IS NULL   -- BUG11183:DRA:22/09/2009
         ORDER BY a.norden;

      xpago_parcial  pagosini.isinret%TYPE;   --       xpago_parcial  NUMBER(25, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xcuantos       NUMBER(6);
      xorden         NUMBER(6);
      xresto         NUMBER(5, 2);
      xpago          NUMBER(25, 2);
      xriesgo        NUMBER;
      psidepag       pagosini.sidepag%TYPE;   --       psidepag       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_err        NUMBER;
      xestado_pago   pagosini.cestpag%TYPE;   --       xestado_pago   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      -- {miramos cuantos hay vivos}
      SELECT COUNT(*)
        INTO xcuantos
        FROM asegurados a
       WHERE a.sseguro = psseguro
         AND a.ffecmue IS NULL
         AND a.ffecfin IS NULL;   -- BUG11183:DRA:22/09/2009

      -- {miarmos si solo se hace un pago por siniestro, da igual el numero de asegurados}
      IF NVL(pdes, 0) = 1 THEN
         xcuantos := 1;
      END IF;

      SELECT sperson
        INTO xriesgo
        FROM riesgos r
       WHERE r.sseguro = psseguro
         AND r.nriesgo = pnriesgo;

      xorden := 1;
      xpago := pisinret;

      FOR aseg IN c_asegurados LOOP
         IF (NVL(pdes, 0) = 1
             AND xriesgo = aseg.sperson)
            OR(NVL(pdes, 0) = 0) THEN
            IF moneda = 2 THEN   -- pesetas
               IF xorden = 1 THEN
                  xpago_parcial := f_round(xpago / xcuantos, 2);
               ELSE
                  xpago_parcial := f_round(xpago - f_round(xpago / xcuantos, 2), 2);
               END IF;
            ELSE   -- euros
               IF xorden = 1 THEN
                  xpago_parcial := f_round(xpago / xcuantos, 1);
               ELSE
                  xpago_parcial := f_round(xpago - f_round(xpago / xcuantos, 1), 1);
               END IF;
            END IF;

            SELECT sidepag.NEXTVAL
              INTO psidepag
              FROM DUAL;

            xestado_pago := pcestpag;

            -- *** En el caso de un fallecido
            IF pmuerto = 1 THEN
               xpago_parcial := pisinret;
            END IF;

            BEGIN
               INSERT INTO pagosini
                           (sidepag, nsinies, ctipdes, sperson, ctippag,
                            cestpag, cforpag, cmanual, cimpres, fefepag, fordpag,
                            tcoddoc, isinret, iconret, iretenc, iimpiva, pretenc,
                            cptotal, fimpres, iresrcm, iresred, iimpsin, isiniva, cconpag,
                            ctransf, ctransfer)
                    VALUES (psidepag, pnsinies, pctipdes, aseg.sperson, pctippag,
                            xestado_pago, 2, pcmanual, pcimpres, pffecmov, pfordpag,
                            ptcoddoc, xpago_parcial, piconret, piretenc, piimpiva, ppretenc,
                            pcptotal, pfimpres, pirendi, pireduc, pimpsin, xpago_parcial, 5,
                            1, 1);

               INSERT INTO pagogarantia
                           (cgarant, sidepag, isinret, fperini, fperfin, iimpiva)
                    VALUES (283, psidepag, xpago_parcial, NULL, NULL, 0);

               xorden := xorden + 1;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 102697;   --{Error a l' inserir a la taula PAGOSINI}
            END;
         END IF;
      END LOOP;

      RETURN 0;
   END f_insert_pago;

   FUNCTION f_insert_destinatario(
      pnsinies IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ppagdes IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pivalora IN NUMBER,
      pcactpro IN NUMBER,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER
                   /* se vuel a cargar la función original con los cambios
                   relacionados con las modificaciones de cuentas bancarias */
   IS
      --
      num_err        NUMBER;

      --
      CURSOR c_asegurados IS
         SELECT   a.sperson, a.norden
             FROM asegurados a
            WHERE a.sseguro = psseguro
              AND a.ffecmue IS NULL
              AND a.ffecfin IS NULL   -- BUG11183:DRA:22/09/2009
         ORDER BY a.norden;

      --
      xcuenta        seguros.cbancar%TYPE;
      xcuenta1       seguros.cbancar%TYPE;
      xcuenta2       seguros.cbancar%TYPE;
      xctipban       seguros.ctipban%TYPE;
      xctipban1      seguros.ctipban%TYPE;
      xctipban2      seguros.ctipban%TYPE;
      xriesgo        NUMBER;
      ndestina       NUMBER;
      ntotal         NUMBER;
      vsproduc       seguros.sproduc%TYPE;   --       vsproduc       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   --
   BEGIN
      xriesgo := psperson;

      -- Si es producto es a '2_CABEZAS', el valor del parámetro pnriesgo será el norden del Asegurado
      -- Si el proudcto NO es a '2_CABEZAS', el valor del parámetro pnriesgo será el nriesgo del Riesgo

      --{Selecionamos la cuenta del seguro, si no nos informan ninguna cuenta por defecto}
      IF pcbancar IS NULL THEN
         BEGIN
            SELECT cbancar, ctipban
              INTO xcuenta1, xctipban1
              FROM seguros s
             WHERE s.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xcuenta1 := NULL;
               xctipban1 := NULL;
         END;
      ELSE
         xcuenta1 := pcbancar;
         xctipban1 := pctipban;   -- BUG10581:DRA:30/06/2009
      END IF;

      IF pcbancar2 IS NULL THEN
         xcuenta2 := xcuenta1;
         xctipban2 := xctipban1;
      ELSE
         xcuenta2 := pcbancar2;
         xctipban2 := pctipban2;
      END IF;

      -- Si el producto es a '2_CABEZAS', el sperson se busca de la tabla Asegurados
      -- Sino de la tabla Riesgos
      BEGIN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101919;   -- Error al leer datos de la tabla SEGUROS
      END;

      IF psperson IS NULL THEN
         IF NVL(f_parproductos_v(vsproduc, '2_CABEZAS'), 0) = 1 THEN
            -- Se debe buscar el sperson de la persona que queda vigente, no de la fallecida
            BEGIN
               SELECT sperson
                 INTO xriesgo
                 FROM asegurados a
                WHERE a.sseguro = psseguro
                  -- Bug 12136 - JRH - 11/03/2010 - JRH - Es un igual no un <>
                  AND a.norden = NVL(pnriesgo, 1)
                  -- Fi Bug 12136 - JRH - 11/03/2010
                  AND a.ffecfin IS NULL;   -- BUG11183:DRA:22/09/2009
            EXCEPTION
               WHEN OTHERS THEN
                  -- Por si acaso sólo hay un asegurado
                  xriesgo := pnriesgo;
            END;
         ELSE
            BEGIN
               SELECT sperson
                 INTO xriesgo
                 FROM riesgos r
                WHERE r.sseguro = psseguro
                  AND nriesgo = NVL(pnriesgo, 1);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 105709;   --{Riesgo no encontrado en la tabla ...}
            END;
         END IF;
      END IF;

      IF psperson IS NULL THEN
         FOR aseg IN c_asegurados LOOP
            IF (NVL(ppagdes, 0) = 1
                AND xriesgo = aseg.sperson)
               OR(NVL(ppagdes, 0) = 0) THEN
               IF aseg.norden = 1 THEN
                  xcuenta := xcuenta1;
                  xctipban := xctipban1;
               --{Si es el 1er aseg. agafem la seva compte}
               ELSIF aseg.norden = 2 THEN
                  xcuenta := xcuenta2;
                  xctipban := xctipban2;
               END IF;

               BEGIN
                  INSERT INTO destinatarios
                              (nsinies, sperson, ctipdes, cpagdes, ivalora, cactpro,
                               cbancar, ctipban)
                       VALUES (pnsinies, aseg.sperson, 1, pcpagdes, pivalora, pcactpro,
                               xcuenta, xctipban);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 102696;
               END;

               num_err := pac_sin.f_mantdiario_desti(pnsinies, 0, aseg.sperson, 1);
            END IF;
         END LOOP;
      ELSE
         xcuenta := pcbancar;
         xctipban := pctipban;

         BEGIN
            INSERT INTO destinatarios
                        (nsinies, sperson, ctipdes, cpagdes, ivalora, cactpro, cbancar,
                         ctipban, pasigna)
                 VALUES (pnsinies, psperson, 1, pcpagdes, pivalora, pcactpro, xcuenta,
                         xctipban, 100);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE destinatarios
                  SET cpagdes = pcpagdes,
                      ivalora = pivalora,
                      cactpro = pcactpro,
                      cbancar = xcuenta,
                      ctipban = xctipban,
                      pasigna = 100
                WHERE nsinies = pnsinies
                  AND sperson = psperson
                  AND ctipdes = 1;
            WHEN OTHERS THEN
               RETURN 102696;
         END;

         num_err := pac_sin.f_mantdiario_desti(pnsinies, 0, psperson, 1);
      END IF;

      RETURN 0;
   END f_insert_destinatario;
END pac_sin_insert;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_INSERT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_INSERT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_INSERT" TO "PROGRAMADORESCSI";
