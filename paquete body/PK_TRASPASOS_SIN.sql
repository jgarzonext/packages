--------------------------------------------------------
--  DDL for Package Body PK_TRASPASOS_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_TRASPASOS_SIN" AS
/*****************************************************************************
   NOMBRE:     PK_TRASPASOS_SIN
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/07/2009   DCT                1. 0010612: CRE - Error en la generació de pagaments automàtics.
                                              Canviar vista personas por tablas personas y añadir filtro de visión de agente
******************************************************************************/
   FUNCTION f_crea_siniestro(
      psseguro IN NUMBER,
      pstras IN NUMBER,
      pfvalmov IN DATE,
      ptipdestinat IN NUMBER,
      pimovimi IN NUMBER,
      pspersdest IN NUMBER,
      ptipsinistre IN NUMBER,
      pnsinies OUT NUMBER,
      psidepag OUT NUMBER,
      paccpag IN NUMBER)
      RETURN NUMBER IS
      ---paccpag INDICA l'estat en el que ha de quedar el pagament del sinistre ACCEPTAT (1) O PAGAT (2)
      num_err        NUMBER(6);
      garantia       NUMBER(8);
      psperson       NUMBER(10);
      cuantos        NUMBER(6);
      sidepag        NUMBER(8);
      tcausa         VARCHAR2(400);
      ncausa         NUMBER;
      pcidioma       NUMBER;
      pcramo         NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
---ptipsinistre: 1: traspas de sortida; 2: prestacio
   BEGIN
      IF ptipsinistre = 1 THEN
         BEGIN
            --Bug10612 - 14/07/2009 - DCT (canviar vista personas)
            SELECT per_personas.sperson, seguros.cramo, seguros.cidioma
              INTO psperson, pcramo, pcidioma
              FROM per_personas, planpensiones, fonpensiones, proplapen, seguros
             WHERE seguros.sseguro = psseguro
               AND proplapen.sproduc = seguros.sproduc
               AND planpensiones.ccodpla = proplapen.ccodpla
               AND fonpensiones.ccodfon = planpensiones.ccodfon
               AND per_personas.sperson = fonpensiones.sperson;
         /*SELECT personas.sperson, seguros.cramo, seguros.cidioma
           INTO psperson, pcramo, pcidioma
           FROM personas, planpensiones, fonpensiones, proplapen, seguros
          WHERE seguros.sseguro = psseguro
            AND proplapen.sproduc = seguros.sproduc
            AND planpensiones.ccodpla = proplapen.ccodpla
            AND fonpensiones.ccodfon = planpensiones.ccodfon
            AND personas.sperson = fonpensiones.sperson;*/
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 1;
         END;

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF pcidioma = 0 THEN
            --Bug10612 - 13/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = psseguro;

            SELECT d.cidioma
              INTO pcidioma
              FROM tomadores a, per_detper d
             WHERE a.sseguro = psseguro
               AND a.nordtom = 1
               AND d.sperson = a.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);
         /*SELECT cidioma
           INTO pcidioma
           FROM tomadores a, personas b
          WHERE a.sseguro = psseguro
            AND a.sperson = b.sperson
            AND a.nordtom = 1;*/

         --FI Bug10612 - 13/07/2009 - DCT (canviar vista personas)
         END IF;

         num_err := f_desvalorfijo(684, pcidioma, 2, tcausa);
         garantia := 6;
      ELSIF ptipsinistre = 2 THEN
         BEGIN
            SELECT cramo, cidioma
              INTO pcramo, pcidioma
              FROM seguros
             WHERE seguros.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 1;
         END;

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF pcidioma = 0 THEN
            --Bug10612 - 13/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = psseguro;

            SELECT d.cidioma
              INTO pcidioma
              FROM tomadores a, per_detper d
             WHERE a.sseguro = psseguro
               AND a.nordtom = 1
               AND d.sperson = a.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);
         /*SELECT cidioma
           INTO pcidioma
           FROM tomadores a, personas b
          WHERE a.sseguro = psseguro
            AND a.sperson = b.sperson
            AND a.nordtom = 1;*/

         --FI Bug10612 - 13/07/2009 - DCT (canviar vista personas)
         END IF;

         tcausa := f_axis_literales(109433, pcidioma);
      END IF;

      ncausa := pcramo * 100 + 8;
      num_err := f_regsinies(psseguro, pcramo, pfvalmov, tcausa, pnsinies, ncausa);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_regdestinat(pnsinies, psperson, ptipdestinat, 1, pimovimi, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_regvalorac(pnsinies, garantia, pfvalmov, pimovimi);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --*** Si el destinatario es el fondo entonces cambiamos la cta/cte.
      UPDATE destinatarios
         SET cbancar = (SELECT cbancar
                          FROM trasplainout
                         WHERE trasplainout.stras = pstras)
       WHERE nsinies = pnsinies
         AND sperson = psperson;

      num_err := f_regpagosin(pnsinies, 5, psperson, 2, 0, 2, 1, 0, 0, NULL, SYSDATE, NULL,
                              NULL, pimovimi, NULL, NULL, NULL, NULL, 1, NULL, psidepag);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_aceptar_pago(psidepag, pnsinies, SYSDATE, 1, pfvalmov, psseguro, 2, paccpag);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

---
   FUNCTION f_regsinies(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pfecha IN DATE,
      ptsinies IN VARCHAR2,
      pnsinies OUT NUMBER,
      pcausa IN NUMBER)
      RETURN NUMBER IS
   BEGIN
--dbms_output.put_line('regsinies: '||pcramo);
   --Generar un registro en SINIESTROS de prestación
   -----------------------------------------------
      pnsinies := f_contador('01', pcramo);

      INSERT INTO siniestros
                  (nsinies, fnotifi, cestsin, tsinies, fsinies, ipromes, ipro31d, ccausin,
                   sseguro, cusuari, nriesgo, festsin, ccauest)
           VALUES (pnsinies, SYSDATE, 0, ptsinies, pfecha, NULL, NULL, pcausa,
                   psseguro, f_user, 1, NULL, NULL);

--dbms_output.put_line('regsinies: '||pnsinies);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pnsinies := 0;
         RETURN SQLCODE;
   END f_regsinies;

------
   FUNCTION f_regpagosin(
      pnsinies IN NUMBER,
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
      pnmescon IN NUMBER,
      ptcoddoc IN NUMBER,
      pisinret IN NUMBER,
      piconret IN NUMBER,
      piretenc IN NUMBER,
      piimpiva IN NUMBER,
      ppretenc IN NUMBER,
      pcptotal IN NUMBER,
      pfimpres IN DATE,
      psidepag IN OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT sidepag.NEXTVAL
        INTO psidepag
        FROM DUAL;

      psidepag := psidepag;

      INSERT INTO pagosini
                  (sidepag, nsinies, ctipdes, sperson, ctippag, cestpag, cforpag,
                   cmanual, cimpres, fefepag, fordpag, tcoddoc, isinret, iconret,
                   iretenc, iimpiva, pretenc, cptotal, fimpres)
           VALUES (psidepag, pnsinies, pctipdes, psperson, pctippag, pcestpag, pcforpag,
                   pcmanual, pcimpres, pfefepag, pfordpag, ptcoddoc, pisinret, piconret,
                   piretenc, piimpiva, ppretenc, pcptotal, pfimpres);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102697;
   END f_regpagosin;

------
   FUNCTION f_regdestinat(
      pnsinies IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pivalora IN NUMBER,
      pcactpro IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      --- Generar un registro en DESTINATARIOS-------
      INSERT INTO destinatarios
                  (nsinies, sperson, ctipdes, cpagdes, ivalora, cactpro)
           VALUES (pnsinies, psperson, pctipdes, pcpagdes, pivalora, pcactpro);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102696;
   END f_regdestinat;

------
   FUNCTION f_regvalorac(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE,
      pivalora IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      ---Generar un registro en VALORACIONES
      INSERT INTO valorasini
                  (nsinies, cgarant, fvalora, ivalora)
           VALUES (pnsinies, pcgarant, pfecha, pivalora);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102696;
   END f_regvalorac;

------
   FUNCTION f_aceptar_pago(
      psidepag IN NUMBER,
      pnsinies IN NUMBER,
      ford DATE,
      cptotal NUMBER,
      fechapago DATE,
      psseguro NUMBER,
      pmoneda IN NUMBER,
      paccpag IN NUMBER)
      RETURN NUMBER IS
      ---
      ttexto         VARCHAR2(100);
      xpendents      NUMBER;
      empr           NUMBER;
      nproc          NUMBER;
      num_err        NUMBER := 0;
      xcestpag       NUMBER;
      xfefepag       DATE;
      fecha_pago     DATE;
      trans          NUMBER(1);
   BEGIN
      IF paccpag = 1 THEN
         xcestpag := 1;   ----acceptat
         trans := 1;   -- Pendent de transferir
         fecha_pago := NULL;
      ELSIF paccpag = 2 THEN
         xcestpag := 2;   ----pagat
         trans := 2;   -- Transferit
         fecha_pago := fechapago;
      END IF;

      BEGIN
         UPDATE pagosini
            SET fordpag = fordpag,
                ctransf = trans,
                fcontab = fecha_pago
          WHERE nsinies = pnsinies
            AND sidepag = psidepag;
      EXCEPTION
         WHEN OTHERS THEN
--         dbms_output.put_line(SQLERRM);
            IF SQLCODE = -20001 THEN
               RETURN 108134;
            END IF;
      END;

      -- Añadimos una llamada a la función F_XL,
      -- y controlamos el error, cerrando el expediente solo
      -- si no existe error.
      num_err := f_empresa(psseguro, NULL, NULL, empr, f_user);

      IF cptotal = 1 THEN
         num_err := f_procesini(f_user, empr, 'PK_TRASPASOS_SIN', 'Finalización siniestro',
                                nproc);
      ELSE
         num_err := f_procesini(f_user, empr, 'PK_TRASPASOS_SIN', 'Aceptación pago', nproc);
      END IF;

      num_err := f_xl(nproc, pnsinies, SYSDATE, pmoneda);

      IF num_err <> 0 THEN
         RETURN 105622;
      END IF;

      xfefepag := SYSDATE;

      BEGIN
         UPDATE pagosini
            SET cestpag = xcestpag,
                cptotal = 1,
                fefepag = xfefepag,
                fordpag = ford,
                cusuari = f_user
          WHERE nsinies = pnsinies
            AND sidepag = psidepag;
      EXCEPTION
         WHEN OTHERS THEN
--         dbms_output.put_line(SQLERRM);
            RETURN 108134;
      END;

      -- Si el pagament que s'acepta és CPTOTAL = 1 es
      -- pot tancar el sinistre (si no hi ha cap pagament pendent).
      IF cptotal = 1 THEN
         SELECT COUNT(*)
           INTO xpendents
           FROM pagosini
          WHERE cestpag = 0
            AND nsinies = pnsinies;

         IF NVL(xpendents, 0) = 0 THEN
            num_err := f_cierra_siniestro(pnsinies);
         END IF;
      END IF;

      num_err := f_procesfin(nproc, num_err);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_aceptar_pago;

---
---
   FUNCTION f_cierra_siniestro(pnsinies NUMBER)
      RETURN NUMBER IS
      ttexto         VARCHAR2(100);
      num_err        NUMBER;
      xprovisio      NUMBER(25, 10);
      i9998          NUMBER;
   BEGIN
      -- Cerramos el siniestro aunque no este pagado el pago.
      num_err := f_provisio(pnsinies, xprovisio, f_sysdate);

      IF xprovisio <> 0 THEN
         num_err := f_val9998(pnsinies, i9998, f_sysdate, 3);

         INSERT INTO valorasini
                     (nsinies, cgarant, fvalora, ivalora)
              VALUES (pnsinies, 9998, SYSDATE, 0 - i9998);
      END IF;

      BEGIN
         UPDATE siniestros
            SET cestsin = 1,
                festsin = SYSDATE,
                ccauest = SUBSTR(LPAD(TO_CHAR(pnsinies), 8, '0'), 1, 2) || '01'
          WHERE nsinies = pnsinies;
      EXCEPTION
         WHEN OTHERS THEN
            -- Error recollit de trigger de festsin, que evita que es tanquin
            -- sinistres amb data anterior a l'ultim tancament
            IF SQLCODE = -20001 THEN
               RETURN(108127);
            ELSE
               RETURN(108129);
            END IF;
      END;

      -- Al anular un siniestro creamos en la agenda un registro
      -- para mantener el historico del estado. Será del tipo automático (5), y
      -- los dos primeros caracteres del texto indicarán el movimiento (01: cierre)
      SELECT tlitera
        INTO ttexto
        FROM literales c
       WHERE c.slitera = 100832
         AND cidioma = 1;

      num_err := f_insagensini(pnsinies, f_sysdate, 5, NULL, SYSDATE, 1, '01-' || ttexto,
                               f_user, SYSDATE);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- *** Borramos el registro de REAJUSTE POR CIERRE
      -- *** en siniestros y ACTUALIZAMOS EL valorasini
      -- *** con la suma de todos los pagos
      DELETE      valorasini
            WHERE nsinies = pnsinies
              AND cgarant = 9998;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103119;
   END f_cierra_siniestro;
END pk_traspasos_sin;

/

  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS_SIN" TO "PROGRAMADORESCSI";
