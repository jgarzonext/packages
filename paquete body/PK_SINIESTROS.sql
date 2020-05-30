--------------------------------------------------------
--  DDL for Package Body PK_SINIESTROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_SINIESTROS" IS
   /******************************************************************************
      NOMBRE:       PK_SINIESTROS
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor     Descripción
      ---------  ----------  -------  ------------------------------------
       1.0       -            -       1. Creación de package
       2.0       15/12/2011  JMP      2. 0018423: LCOL705 - Multimoneda
       3.0       02/10/2014  JTT      3. Correccion de caracteres UTF8
   ******************************************************************************/
-- ******************************************************************
-- Rescates Parciales.
-- ******************************************************************
   FUNCTION f_rescate(
      ptarea IN NUMBER,   --33-Rescate Parcial,34-Rescate Total
      psseguro IN NUMBER,
      pidioma IN NUMBER,
      pimporte IN NUMBER,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      pfcontab IN DATE,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pnsinies OUT NUMBER,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      xcramo         seguros.cramo%TYPE;   --NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
      xvalor         NUMBER;
      xcmotmov       NUMBER;
      num_err        NUMBER;   -- Error funciones
      paso           NUMBER;   -- Control de codigo
      xnmovimi       NUMBER;   -- Numero de movimiento
      xnsuple        seguros.nsuplem%TYPE;   --NUMBER;   -- Numero de Suplemento
      ximovimimax    NUMBER;   -- Saldo
      ximpresc       NUMBER;   -- Importe de Rescate
      ximporte       NUMBER;   -- Importe Bruto
      ximpotot       NUMBER;
      ximporte2      NUMBER;
      xretenc        NUMBER;   -- Importe de Retencion
      xipenali       NUMBER;   -- Importe de Penalización
      xmoneda        NUMBER;   -- Codigo de la moneda
      xppagdes       NUMBER;
      xnmov          NUMBER;   -- Devuelve anulaseg
      xcestpag       NUMBER;   -- Estado del Pago
      fmuerte        asegurados.ffecmue%TYPE;   --DATE;
      ximppigno      NUMBER;
      xccausin       NUMBER;
      xcmotsin       NUMBER;
      muerto         NUMBER;
      cuantos        NUMBER;
      causa          VARCHAR2(30);
   BEGIN
      xvalor := f_valorgrupo(psseguro);

      IF xvalor = -1 THEN
         RETURN 110448;   -- Parametrización del producto incompleta
      END IF;

      paso := 0;

-- Validación de los rescates diarios que se pueden realizar
      SELECT COUNT(*)
        INTO cuantos
        FROM ctaseguro
       WHERE ctaseguro.sseguro = psseguro
         AND fvalmov = pfvalmov
         AND cmovimi IN(32, 33, 34);

      --
      IF cuantos > 0 THEN
         RETURN 110104;   -- Solo un rescate por día
      END IF;

      paso := 1;
-- Miro si la poliza esta bloqueada/pignorada
      num_err := f_bloqueada(psseguro, pfvalmov);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_pignorada(psseguro, pfvalmov, ximppigno);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      paso := 2;

      IF ptarea = 33 THEN
         ximpresc := pimporte;
      ELSE
         ximpresc := 0;
      END IF;

      paso := 3;
      num_err := validar_aportacion_rescate(ptarea, psseguro, pfvalmov, ximpresc);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      paso := 4;

      IF xvalor = 4 THEN   -- *** rvi
         ximovimimax := pk_provmatematicas.f_provmat(0, psseguro, pfvalmov, 2, ximpresc);
         xipenali := 0;
      ELSE
         ximovimimax := pk_provmatematicas.f_provmat(0, psseguro, pfvalmov - 1, 1, ximpresc);
         xipenali := pk_provmatematicas.f_provmat(1, psseguro, pfvalmov, 2, ximpresc);

         IF xipenali = -8 THEN
            xipenali := 0;
         END IF;
      END IF;

      paso := 5;

-- ------------------------ Parcial
      IF ptarea = 33 THEN
-- Valor Maximo de Rescate
         IF ximovimimax < 0 THEN
            ximovimimax := 0;
         END IF;

         --
         IF NVL(pimporte, 0) >= ximovimimax
            AND NVL(ximovimimax, 0) > 0 THEN
            RETURN 109855;   -- El importe no puede ser superior a la PM
         END IF;

         paso := 6;
         ximporte := NVL(ximpresc, 0) - NVL(xipenali, 0);

         --
         IF ximporte < 0
            OR xipenali < 0
            OR ximpresc < 0 THEN
            RETURN 102556;   -- Error al calcular el saldo
         END IF;

         --
         IF ximpresc >(ximovimimax * 0.7) THEN
--message ( 'el rescate máximo será de: ' || :area_ctaseguro.ip_imovimimax*0.7)
            RETURN 109855;   -- El importe no puede ser superior a la P.M.
         END IF;

         --
         xcmotmov := 506;   -- Rescate Parcial
-- ------------------------ Total
      ELSIF ptarea = 34 THEN
         --*** Si hay uno vivo y uno muerto en PFV el proceso es diferente
         IF xvalor = 3
            AND f_vivos_muertos(psseguro, 2) = 1
            AND f_vivos_muertos(psseguro, 1) = 1 THEN
            muerto := 1;

            --
            SELECT ffecmue
              INTO fmuerte
              FROM asegurados
             WHERE asegurados.sseguro = psseguro
               AND asegurados.ffecmue IS NOT NULL;

            --
            ximporte := pk_provmatematicas.f_provmat(0, psseguro, fmuerte, 1);
            ximporte := TRUNC(ximporte / 2) +(ximporte MOD 2);
            ximporte2 := NVL(ximovimimax, 0) - NVL(xipenali, 0) - NVL(ximporte, 0);
         --
         ELSE
            muerto := 0;
            ximporte := NVL(ximovimimax, 0) - NVL(xipenali, 0);
            ximporte2 := 0;
         END IF;

         --
         xcmotmov := 510;   -- Rescate total
      --
      END IF;

      -- GENERO SINIESTRO
      SELECT (NVL(MAX(nsuplem), 0) + 1)
        INTO xnsuple
        FROM movseguro
       WHERE sseguro = psseguro;

      paso := 7;
      num_err := f_movseguro(psseguro, NULL, xcmotmov, 1, pffecmov, NULL, xnsuple, NULL,
                             TRUNC(f_sysdate), xnmovimi, TRUNC(f_sysdate));

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- *** Ponemos la fecha contable y la fecha de emisión
      UPDATE movseguro m
         SET fcontab = pfvalmov
       WHERE m.sseguro = psseguro
         AND m.nmovimi = xnmovimi;

      paso := 9;

      --Cambiamos el numero de suplementos en SEGUROS
      BEGIN
         UPDATE seguros
            SET nsuplem = xnsuple
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 105841;   --Error en lectura o modificación de SEGUROS
      END;

      paso := 10;
      num_err := f_desvalorfijo(83, pidioma, ptarea, causa);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      paso := 99;

      IF ptarea = 33 THEN
         ximpotot := ximporte;
         muerto := 0;
      ELSE
         num_err := f_anulaseg(psseguro, 0, TRUNC(f_sysdate), 511, NULL, 2, xnmov);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         ximpotot := ximporte + ximporte2;
      END IF;

      paso := 11;

      IF ptarea = 33 THEN
         xccausin := 3;
         xcmotsin := 0;
      ELSE
         xccausin := 4;
         xcmotsin := 0;
      END IF;

      --  num_err := f_regsinies(psseguro,pffecmov,ptarea,causa,pnsinies);
      num_err := f_regsinies(psseguro, NULL, pffecmov, causa, xccausin, xcmotsin, pfcontab,
                             pfvalmov, 1, pnsinies);

      --
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      paso := 12;
      num_err := f_regvalorac(pnsinies, 283, pffecmov, ximpotot);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT NVL(p.nnumpag, 0), p.cdivisa
           INTO xppagdes, xmoneda
           FROM seguros s, productos p
          WHERE s.sseguro = psseguro
            AND s.cramo = p.cramo
            AND s.cmodali = p.cmodali
            AND s.ctipseg = p.ctipseg
            AND s.ccolect = p.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xppagdes := NULL;
            xmoneda := NULL;
         WHEN OTHERS THEN
            xppagdes := NULL;
            xmoneda := NULL;
      END;

      paso := 13;
      num_err := f_regdestinat(pnsinies, psseguro, xppagdes, 1, 1, ximpotot, NULL, pcbancar,
                               pcbancar2, pctipban, pctipban2);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF ximporte2 > 0 THEN
         xcestpag := 0;
      ELSE
         xcestpag := 1;
      END IF;

      paso := 14;
      num_err := f_regpagosin(pnsinies, psseguro, xppagdes, pffecmov, 1, 0, 2, xcestpag, 1, 0,
                              0, 0, NULL, f_sysdate, NULL, NULL, ximporte, NULL, NULL, NULL,
                              NULL, 1, NULL, xmoneda, muerto);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF ximporte2 > 0 THEN
         num_err := f_regpagosin(pnsinies, psseguro, xppagdes, pffecmov, 1, 0, 2, xcestpag, 1,
                                 0, 0, 0, NULL, f_sysdate, NULL, NULL, ximporte2, NULL, NULL,
                                 NULL, NULL, 1, NULL, xmoneda, muerto);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      -- Si dejamos un pago pendiente el expediente queda abierto
      IF xcestpag = 0 THEN
         UPDATE siniestros
            SET cestsin = 0
          WHERE nsinies = pnsinies;
      END IF;

      paso := 15;

      -- *** Calculamos la retención
      IF muerto = 0 THEN
         num_err := f_retencion(psseguro, xnmovimi, pnsinies, pfvalmov, pfvalmov, ptarea,
                                ximporte, xretenc);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         paso := 16;
         num_err := f_reparte_retenciones(pnsinies, psseguro, xppagdes, pfvalmov, xretenc,
                                          ximporte, xmoneda);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      paso := 17;
      num_err := f_insctaseguro(psseguro, pfcontab, pffecmov, pfvalmov, ptarea, ximporte,
                                pnsinies);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
         num_err := f_insctaseguro_shw(psseguro, pfcontab, pffecmov, pfvalmov, ptarea,
                                       ximporte, pnsinies);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      paso := 18;

      IF xipenali <> 0 THEN
         num_err := f_insctaseguro(psseguro, pfcontab, pffecmov, pfvalmov, 27, xipenali,
                                   pnsinies);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
            num_err := f_insctaseguro_shw(psseguro, pfcontab, pffecmov, pfvalmov, 27,
                                          xipenali, pnsinies);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END IF;   -- penalización = 0

      --
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END;

-- ****************************************************************
-- Validar Rescate
-- ****************************************************************
   FUNCTION validar_aportacion_rescate(
      ptarea IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      pimovimi IN NUMBER)
      RETURN NUMBER IS
      xsproduc       productos.sproduc%TYPE;   --NUMBER(8);
      movimiento     NUMBER(2);
      encontrados    NUMBER(1);
      importe_anuales NUMBER(25, 10);
      anyos          NUMBER(4);
      salir          EXCEPTION;
      penalizacion   VARCHAR2(1) := 'N';
      gratuita       VARCHAR2(1) := 'N';
      cuantas_aportaciones NUMBER(8);
      cuantos_rescates NUMBER(8);
      nummovimi      NUMBER(2);
      moneda         productos.cdivisa%TYPE;   --       moneda         NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      prod           productos.cprprod%TYPE;   --       prod           NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fecha_renta    seguros_ren.f1paren%TYPE;   --       fecha_renta    DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfefecto       seguros.fefecto%TYPE;   --       xfefecto       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

      CURSOR c_rango IS
         SELECT niniran, nfinran, ngraano, nmaxano, ipenali, ppenali, imaximo, clave, iminimo
           FROM prodtraresc, detprodtraresc
          WHERE prodtraresc.sidresc = detprodtraresc.sidresc
            AND prodtraresc.sproduc = xsproduc
            AND ctipmov = movimiento
            AND TO_CHAR(finicio, 'YYYYMMDD') <= TO_CHAR(pfvalmov, 'YYYYMMDD')
            AND(ffin IS NULL
                OR TO_CHAR(ffin, 'YYYYMMDD') >= TO_CHAR(pfvalmov, 'YYYYMMDD'))
            AND(MONTHS_BETWEEN(pfvalmov, xfefecto) / 12) BETWEEN niniran AND nfinran;

      rango          c_rango%ROWTYPE;
   BEGIN
      SELECT p.cprprod, p.cdivisa, s.fefecto, MONTHS_BETWEEN(pfvalmov, s.fefecto) / 12,
             p.sproduc
        INTO prod, moneda, xfefecto, anyos,
             xsproduc
        FROM seguros s, productos p
       WHERE s.sseguro = psseguro
         AND s.cramo = p.cramo
         AND s.cmodali = p.cmodali
         AND s.ctipseg = p.ctipseg
         AND s.ccolect = p.ccolect;

      IF prod = 1 THEN
         SELECT f1paren
           INTO fecha_renta
           FROM seguros_ren
          WHERE sseguro = psseguro;
      END IF;

      IF ptarea = 33 THEN
         IF TO_CHAR(f_sysdate, 'YYYYMMDD') >= TO_CHAR(fecha_renta, 'YYYYMMDD')
            AND prod = 1 THEN
            movimiento := 5;
         ELSE
            movimiento := 2;
         END IF;
      ELSIF ptarea = 34 THEN
         IF TO_CHAR(f_sysdate, 'YYYYMMDD') >= TO_CHAR(fecha_renta, 'YYYYMMDD')
            AND prod = 1 THEN
            movimiento := 6;
         ELSE
            movimiento := 3;
         END IF;
      END IF;

      --
      encontrados := 0;

      --
      OPEN c_rango;

      LOOP
         FETCH c_rango
          INTO rango;

         EXIT WHEN c_rango%NOTFOUND;

         -- Buscamos las aportaciones realizadas durante el período
         IF ptarea IN(33, 34) THEN
            SELECT COUNT(*), SUM(imovimi)
              INTO cuantos_rescates, importe_anuales
              FROM ctaseguro
             WHERE ctaseguro.sseguro = psseguro
               AND cmovimi = ptarea
               AND fvalmov BETWEEN ADD_MONTHS(xfefecto,(rango.niniran * 12))
                               AND ADD_MONTHS(xfefecto,(rango.nfinran * 12));

--message ( 'cuantos rescates' || cuantos_rescates );pause;
            IF cuantos_rescates + 1 > rango.nmaxano THEN
               --Max. rescates permitidas
               RETURN(109548);
            ELSIF(NVL(importe_anuales, 0) + NVL(pimovimi, 0) > rango.imaximo) THEN
               -- *** imp. superior al max. a rescatar
               RETURN(109549);
            ELSIF rango.iminimo > NVL(pimovimi, 0) THEN
               --*** imp. superior al mínimo permitido
               RETURN(109547);
            ELSIF(cuantos_rescates + 1) <= rango.ngraano THEN
               gratuita := 'S';
            ELSIF(cuantos_rescates + 1) > rango.ngraano THEN
               penalizacion := 'S';
            END IF;
         END IF;

         IF penalizacion = 'S'
            AND rango.ipenali > 0 THEN
            --:IP_PENALIZACION := RANGO.IPENALI;
            NULL;
         ELSIF penalizacion = 'S'
               AND rango.ppenali > 0 THEN
            IF moneda = 2 THEN
               --:IP_PENALIZACION := ROUND( (( nvl(:IP_IMOVIMI,0) * RANGO.PPENALI )/ 100) ,0);
               NULL;
            ELSE
               --:IP_PENALIZACION := ROUND( (( nvl(:IP_IMOVIMI,0) * RANGO.PPENALI )/ 100) ,2);
               NULL;
            END IF;
         ELSE
            --:IP_PENALIZACION := 0;
            NULL;
         END IF;

         --
         encontrados := 1;
         EXIT WHEN encontrados = 1;
      END LOOP;

      CLOSE c_rango;

      IF encontrados = 1 THEN
         RETURN 0;
      ELSE
         RETURN 109550;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(109550);
      -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona WHEN OTHERS
      WHEN OTHERS THEN
         IF c_rango%ISOPEN THEN
            CLOSE c_rango;
         END IF;

         RETURN 104999;
   END validar_aportacion_rescate;

-- ****************************************************************
-- Devuelve el valor del grupo
-- ****************************************************************
   FUNCTION f_valorgrupo(psseguro IN NUMBER)
      RETURN NUMBER IS
      agrupacion     NUMBER(6);
   BEGIN
      -- Primero, buscamo el producto
      SELECT parproductos.cvalpar
        INTO agrupacion
        FROM productos, seguros, parproductos
       WHERE seguros.sseguro = psseguro
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND productos.sproduc = parproductos.sproduc
         AND parproductos.cparpro = 'DESPRODPROVMAT';

      RETURN(agrupacion);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(-1);   -- Parametrización del producto incompleta
   END;

-- ****************************************************************
-- Devuelve el Estado de los asegurados
-- Parámetros
-- ESTADO
--
--  1- Devuelve los asegurados vivos
--  2- Devuelve los asegurados muertos
--  3- Devuelve el numero de asegurados tanto vivos como muertos
-- ****************************************************************
   FUNCTION f_vivos_muertos(psseguro IN NUMBER, estado IN NUMBER)
      RETURN NUMBER IS
      cuantos        NUMBER;
      vivos          NUMBER;
      muertos        NUMBER;
      todos          NUMBER;
   BEGIN
      IF estado = 1 THEN
         SELECT COUNT(1)
           INTO vivos
           FROM asegurados
          WHERE asegurados.sseguro = psseguro
            AND asegurados.ffecmue IS NULL;

         RETURN(vivos);
      ELSIF estado = 2 THEN
         SELECT COUNT(1)
           INTO muertos
           FROM asegurados
          WHERE asegurados.sseguro = psseguro
            AND asegurados.ffecmue IS NOT NULL;

         RETURN(muertos);
      ELSIF estado = 3 THEN
         SELECT COUNT(1)
           INTO todos
           FROM asegurados
          WHERE asegurados.sseguro = psseguro;

         RETURN(todos);
      ELSE
         RETURN(-1);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(-2);
   END;

-- ****************************************************************
-- Genera registro de valoración
-- ****************************************************************
   FUNCTION f_grabvalorac(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE,
      pivalora IN NUMBER,
      pipenali IN NUMBER,
      picapris IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      xnvalora       NUMBER;
      xivalora       valorasini.ivalora%TYPE;   --NUMBER;
   BEGIN
      --
      xivalora :=(pivalora - pipenali);
      num_err := pac_sin.f_mantdiario_valora(pnsinies, 0, pcgarant, xivalora);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --
      BEGIN
         INSERT INTO valorasini
                     (nsinies, cgarant, fvalora, ivalora, icaprisc, ipenali)
              VALUES (pnsinies, pcgarant, pfecha, xivalora, picapris, pipenali);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102695;
      END;

      --
      RETURN 0;
   --
   END;

-- *******************************************************************
-- Genera registro destinatarios que serán los asegurados de la póliza
-- *******************************************************************
   FUNCTION f_grabdestrescat(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR c_asegurados IS
         SELECT   sperson, norden
             FROM asegurados
            WHERE asegurados.sseguro = psseguro
              AND ffecmue IS NULL
         ORDER BY norden;

      --
      aseg           c_asegurados%ROWTYPE;
      --
      num_err        NUMBER;
      cuenta         seguros.cbancar%TYPE;
      cuenta1        seguros.cbancar%TYPE;
      cuenta2        seguros.cbancar%TYPE;
      xctipban       seguros.cbancar%TYPE;
      xctipban1      seguros.cbancar%TYPE;
      xctipban2      seguros.cbancar%TYPE;
      xpagdes        NUMBER;
      xctipdes       NUMBER;
      riesgo         riesgos.sperson%TYPE;   --NUMBER;
   --
   BEGIN
      IF pcbancar IS NULL THEN
         BEGIN
            SELECT cbancar, ctipban
              INTO cuenta1, xctipban1
              FROM seguros
             WHERE seguros.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               cuenta1 := NULL;
               xctipban1 := NULL;
         END;
      ELSE
         cuenta1 := pcbancar;
         xctipban1 := pctipban;
      END IF;

      --
      IF pcbancar2 IS NULL THEN
         cuenta2 := cuenta1;
         xctipban2 := xctipban1;
      ELSE
         cuenta2 := pcbancar2;
         xctipban2 := pctipban2;
      END IF;

      --
      BEGIN
         SELECT NVL(nnumpag, 0)
           INTO xpagdes
           FROM productos
          WHERE sproduc IN(SELECT sproduc
                             FROM seguros
                            WHERE sseguro = psseguro);
      EXCEPTION
         WHEN OTHERS THEN
            riesgo := 0;
      END;

      --
      BEGIN
         SELECT sperson
           INTO riesgo
           FROM riesgos
          WHERE riesgos.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            riesgo := 0;
      END;

      --
      OPEN c_asegurados;

      LOOP
         FETCH c_asegurados
          INTO aseg;

         EXIT WHEN c_asegurados%NOTFOUND;

         --
         IF (NVL(xpagdes, 0) = 1
             AND riesgo = aseg.sperson)
            OR(NVL(xpagdes, 0) = 0) THEN
            IF aseg.norden = 1 THEN
               cuenta := cuenta1;
               xctipban := xctipban1;
               xctipdes := 1;
            ELSIF aseg.norden = 2 THEN
               cuenta := cuenta2;
               xctipban := xctipban2;
               xctipdes := 10;
            END IF;

            --
            BEGIN
               INSERT INTO destinatarios
                           (nsinies, sperson, ctipdes, cbancar, ctipban)
                    VALUES (pnsinies, aseg.sperson, xctipdes, cuenta, xctipban);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 102696;
            END;

            --
            num_err := pac_sin.f_mantdiario_desti(pnsinies, 0, aseg.sperson, xctipdes);

            IF num_err <> 0 THEN
               RETURN(num_err);
            END IF;
         END IF;
      END LOOP;

      --
      CLOSE c_asegurados;

      --
      RETURN 0;
   -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF c_asegurados%ISOPEN THEN
            CLOSE c_asegurados;
         END IF;

         RETURN 104999;
   END f_grabdestrescat;

-- ****************************************************************
-- Genera el registro de siniestros
-- ****************************************************************
   FUNCTION f_regsinies(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pffecmov IN DATE,
      ptsinies IN VARCHAR2,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pfcontab IN DATE,
      pfvalmov IN DATE,
      pnriesgo IN NUMBER,
      pnsinies IN OUT NUMBER)
      RETURN NUMBER IS
      --
      contador       NUMBER;
      causa          NUMBER;
      xcramo         seguros.cramo%TYPE;   --       xcramo         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xmovimi        agensini.nmovage%TYPE;   --       xmovimi        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      --
      num_err        NUMBER;
      xctipcoa       seguros.ctipcoa%TYPE;   --NUMBER;
      aux            NUMBER;
      xctraint       VARCHAR2(20);
      xctraext       VARCHAR2(20);
      xcrefint       VARCHAR2(50);
   --
   BEGIN
--Generar un registro en SINIESTROS de prestación
-----------------------------------------------
      IF pcramo IS NULL THEN
         BEGIN
            SELECT cramo, ctipcoa
              INTO xcramo, xctipcoa
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 102694;
         END;
      ELSE
         xcramo := pcramo;

         --
         BEGIN
            SELECT ctipcoa
              INTO xctipcoa
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xctipcoa := NULL;
         END;
      --
      END IF;

      --
      num_err := 0;
      contador := f_contador('01', xcramo);
      pnsinies := contador;
      --
      aux := pac_sin.f_crefint(pnsinies, xctraint, xcrefint);

      --
      BEGIN
         --
         INSERT INTO siniestros
                     (nsinies, fnotifi, cestsin, tsinies, fsinies, ccausin, cmotsin,
                      sseguro, cusuari, nriesgo, festsin, cusualt, falta, fentrad,
                      crefint, ctraint, ctipcoa, cramo, nsubest, ctraext)
              VALUES (pnsinies, pfvalmov, 0, ptsinies, pffecmov, pccausin, pcmotsin,
                      psseguro, f_user, pnriesgo, pfcontab, f_user, f_sysdate, f_sysdate,
                      xcrefint, xctraint, xctipcoa, xcramo, 21, xctraext);
      --
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102694;
      END;

      --
      num_err := pac_sin.f_tramitautomac(pnsinies);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --
      -- Generamos apunte en la Agenda
      --
      BEGIN
         SELECT NVL(MAX(nmovage), 0) + 1
           INTO xmovimi
           FROM agensini
          WHERE nsinies = pnsinies;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107728;
      END;

      --
      BEGIN
         INSERT INTO agensini
                     (nsinies, nmovage, fapunte, ctipreg, fagenda, ffinali, cestado,
                      tagenda, cusuari, fmovimi, capunte, sproces, sperson, csubtip, cageext)
              VALUES (pnsinies, xmovimi, f_sysdate, 1, f_sysdate + 1, NULL, 0,
                      'Apertura siniestro', f_user, f_sysdate, NULL, NULL, NULL, NULL, NULL);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 107728;
         WHEN OTHERS THEN
            RETURN 107727;
      END;

      --
      RETURN 0;
   --
   END;

-- ****************************************************************
-- Genera registro de valoración
-- ****************************************************************
   FUNCTION f_regvalorac(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE,
      pivalora IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      pivalora_aux   NUMBER;
   BEGIN
      pivalora_aux := f_round(pivalora);

      BEGIN
         INSERT INTO valorasini
                     (nsinies, cgarant, fvalora, ivalora)
              VALUES (pnsinies, pcgarant, pfecha, pivalora_aux);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 1;
      END;

      IF num_err <> 0 THEN
         RETURN 102695;
      ELSE
         RETURN 0;
      END IF;
   END;

-- ****************************************************************
-- Genera registros destinatarios
-- ****************************************************************
   FUNCTION f_regdestinat(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
      ppagdes IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pivalora IN NUMBER,
      pcactpro IN NUMBER,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      num_err        NUMBER;

      --
      CURSOR c_asegurados IS
         SELECT   sperson, norden
             FROM asegurados
            WHERE asegurados.sseguro = psseguro
              AND ffecmue IS NULL
         ORDER BY norden;

      aseg           c_asegurados%ROWTYPE;
      --
      cuenta         seguros.cbancar%TYPE;
      cuenta1        seguros.cbancar%TYPE;
      cuenta2        seguros.cbancar%TYPE;
      xctipban       seguros.ctipban%TYPE;
      xctipban1      seguros.ctipban%TYPE;
      xctipban2      seguros.ctipban%TYPE;
      riesgo         riesgos.sperson%TYPE;   --NUMBER;
   --
   BEGIN
      IF pcbancar IS NULL THEN
         BEGIN
            SELECT cbancar, ctipban
              INTO cuenta1, xctipban1
              FROM seguros
             WHERE seguros.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               cuenta1 := NULL;
               xctipban1 := NULL;
         END;
      ELSE
         cuenta1 := pcbancar;
         xctipban := pctipban;
      END IF;

      IF pcbancar2 IS NULL THEN
         cuenta2 := cuenta1;
         xctipban2 := xctipban1;
      ELSE
         cuenta2 := pcbancar2;
         xctipban2 := pctipban2;
      END IF;

      SELECT sperson
        INTO riesgo
        FROM riesgos
       WHERE riesgos.sseguro = psseguro;

      OPEN c_asegurados;

      LOOP
         FETCH c_asegurados
          INTO aseg;

         EXIT WHEN c_asegurados%NOTFOUND;

         IF (NVL(ppagdes, 0) = 1
             AND riesgo = aseg.sperson)
            OR(NVL(ppagdes, 0) = 0) THEN
            IF aseg.norden = 1 THEN
               cuenta := cuenta1;
               xctipban := xctipban1;
            ELSIF aseg.norden = 2 THEN
               cuenta := cuenta2;
               xctipban := xctipban2;
            END IF;

            BEGIN
               INSERT INTO destinatarios
                           (nsinies, sperson, ctipdes, cpagdes, ivalora, cactpro, cbancar,
                            ctipban)
                    VALUES (pnsinies, aseg.sperson, 1, pcpagdes, pivalora, pcactpro, cuenta,
                            xctipban);
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 1;
            END;

            EXIT WHEN num_err = 1;
         END IF;
      END LOOP;

      CLOSE c_asegurados;

      IF num_err <> 0 THEN
         RETURN 102696;
      ELSE
         RETURN 0;
      END IF;
   -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF c_asegurados%ISOPEN THEN
            CLOSE c_asegurados;
         END IF;
   END;

-- ****************************************************************
-- Genera resgistro de pagos
-- ****************************************************************
   FUNCTION f_regpagosin(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
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
      pmuerto IN NUMBER)
      RETURN NUMBER IS
      psidepag       NUMBER;
      num_err        NUMBER;
      estado_pago    pagosini.cestpag%TYPE;   --  NUMBER;

      CURSOR c_asegurados IS
         SELECT   sperson
             FROM asegurados
            WHERE asegurados.sseguro = psseguro
              AND ffecmue IS NULL
         ORDER BY norden;

      aseg           c_asegurados%ROWTYPE;
      pago_parcial   pagosini.isinret%TYPE;   -- NUMBER(25, 2);
      cuantos        NUMBER(6);
      orden          NUMBER(6);
      resto          NUMBER(5, 2);
      pago           NUMBER(25, 2);
      riesgo         riesgos.sperson%TYPE;   --NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO cuantos
        FROM asegurados
       WHERE asegurados.sseguro = psseguro
         AND ffecmue IS NULL;

      IF NVL(pdes, 0) = 1 THEN
         cuantos := 1;
      END IF;

      SELECT sperson
        INTO riesgo
        FROM riesgos
       WHERE riesgos.sseguro = psseguro;

      orden := 1;
      pago := pisinret;

      OPEN c_asegurados;

      LOOP
         FETCH c_asegurados
          INTO aseg;

         EXIT WHEN c_asegurados%NOTFOUND;

         IF (NVL(pdes, 0) = 1
             AND riesgo = aseg.sperson)
            OR(NVL(pdes, 0) = 0) THEN
            IF moneda = 2 THEN   -- pesetas
               IF orden = 1 THEN
                  pago_parcial := f_round(pago / cuantos, 2);
               ELSE
                  pago_parcial := f_round(pago - f_round(pago / cuantos, 2), 2);
               END IF;
            ELSE   -- euros
               IF orden = 1 THEN
                  pago_parcial := f_round(pago / cuantos, 1);
               ELSE
                  pago_parcial := f_round(pago - f_round(pago / cuantos, 1), 1);
               END IF;
            END IF;

            SELECT sidepag.NEXTVAL
              INTO psidepag
              FROM DUAL;

            estado_pago := pcestpag;

            -- *** En el caso de un fallecido
            IF pmuerto = 1 THEN
               pago_parcial := pisinret;
            END IF;

            INSERT INTO pagosini
                        (sidepag, nsinies, ctipdes, sperson, ctippag, cestpag, cforpag,
                         cmanual, cimpres, fefepag, fordpag, tcoddoc, isinret,
                         iconret, iretenc, iimpiva, pretenc, cptotal, fimpres)
                 VALUES (psidepag, pnsinies, pctipdes, aseg.sperson, pctippag, estado_pago, 2,
                         pcmanual, pcimpres, pffecmov, pfordpag, ptcoddoc, pago_parcial,
                         piconret, piretenc, piimpiva, ppretenc, pcptotal, pfimpres);

            INSERT INTO pagogarantia
                        (cgarant, sidepag, isinret, fperini, fperfin, iimpiva)
                 VALUES (283, psidepag, pago_parcial, NULL, NULL, 0);

            orden := orden + 1;
         END IF;
      END LOOP;

      CLOSE c_asegurados;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_asegurados%ISOPEN THEN
            CLOSE c_asegurados;
         END IF;

         RETURN 102697;
   END;

-- *************************************************************************
-- Busca los recibos que se han anulado para desanularlos y recalcula Rentas
-- *************************************************************************
   FUNCTION f_reparte_retenciones(
      siniestro IN NUMBER,
      psseguro IN NUMBER,
      pdes IN NUMBER,
      pfvalmov IN DATE,
      retencion IN NUMBER,
      importe NUMBER,
      moneda NUMBER)
      RETURN NUMBER IS
      CURSOR c_asegurados IS
         SELECT   sperson
             FROM asegurados
            WHERE asegurados.sseguro = psseguro
              AND ffecmue IS NULL
         ORDER BY norden;

      aseg           c_asegurados%ROWTYPE;
      retenparcial   NUMBER(25, 2);
      ret            pagosini.pretenc%TYPE;   --       ret            NUMBER(6, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      cuantos        NUMBER(6);
      num_err        NUMBER(6);
      orden          NUMBER(6);
      resto          NUMBER(5, 2);
      resto_reten    NUMBER(25, 2);
      pago           NUMBER(25, 2);
      pago_parcial   pagosini.isinret%TYPE;   --       pago_parcial   NUMBER(25, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      reducida       NUMBER(25, 2);
      redbruta       NUMBER(25, 2);
      redreduc       NUMBER(25, 2);
      reducida_parcial NUMBER(25, 2);
      redbruta_parcial NUMBER(25, 2);
      redreduc_parcial NUMBER(25, 2);
      sum_pago_parcial NUMBER;
      sum_redu_parcial NUMBER;
      sum_rbru_parcial NUMBER;
      sum_rred_parcial NUMBER;
      riesgo         riesgos.sperson%TYPE;   --       riesgo         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xsproduc       seguros.sproduc%TYPE;   --       xsproduc       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      pago := importe;
      pago_parcial := 0;
      sum_pago_parcial := 0;
      sum_redu_parcial := 0;
      sum_rbru_parcial := 0;
      sum_rred_parcial := 0;
      orden := 1;

      BEGIN
         SELECT sproduc
           INTO xsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 1;
      END;

      SELECT   COUNT(*)
          INTO cuantos
          FROM asegurados
         WHERE sseguro = psseguro
           AND ffecmue IS NULL
      ORDER BY norden;

      IF NVL(pdes, 0) = 1 THEN
         cuantos := 1;
      END IF;

      SELECT sperson
        INTO riesgo
        FROM riesgos
       WHERE riesgos.sseguro = psseguro;

      SELECT NVL(iimpred, 0), NVL(iresrcm, 0), NVL(iresred, 0)
        INTO reducida, redbruta, redreduc
        FROM ulreten
       WHERE ulreten.sseguro = psseguro
         AND norden = (SELECT MAX(norden)
                         FROM ulreten b
                        WHERE b.sseguro = psseguro);

      OPEN c_asegurados;

      LOOP
         FETCH c_asegurados
          INTO aseg;

         EXIT WHEN c_asegurados%NOTFOUND;

         IF (NVL(pdes, 0) = 1
             AND riesgo = aseg.sperson)
            OR(NVL(pdes, 0) = 0) THEN
            pago_parcial := ROUND(pago / cuantos, 2);
            reducida_parcial := ROUND(reducida / cuantos, 2);
            redbruta_parcial := ROUND(redbruta / cuantos, 2);
            redreduc_parcial := ROUND(redreduc / cuantos, 2);
            sum_pago_parcial := sum_pago_parcial + pago_parcial;
            sum_redu_parcial := sum_redu_parcial + reducida_parcial;
            sum_rbru_parcial := sum_rbru_parcial + redbruta_parcial;
            sum_rred_parcial := sum_rred_parcial + redreduc_parcial;

            IF orden = cuantos THEN
               pago_parcial := pago_parcial +(pago - sum_pago_parcial);
               reducida_parcial := reducida_parcial +(reducida - sum_redu_parcial);
               redbruta_parcial := redbruta_parcial +(redbruta - sum_rbru_parcial);
               redreduc_parcial := redreduc_parcial +(redreduc - sum_rred_parcial);
            END IF;

            --****** Buscamos el % de retención
            ret := fbuscapreten(1, aseg.sperson, xsproduc,
                                TO_NUMBER(TO_CHAR(pfvalmov, 'YYYYMMDD')));

            IF ret IS NULL THEN
               ret := 0;
            END IF;

            retenparcial := 0;

            IF reducida_parcial > 0 THEN
               IF moneda = 2 THEN
                  retenparcial := f_round((reducida_parcial * ret) / 100, 2);
               ELSE
                  retenparcial := f_round((reducida_parcial * ret) / 100, 1);
               END IF;
            END IF;

            UPDATE pagosini
               SET isinret = DECODE(moneda, 2, ROUND(pago_parcial), pago_parcial),
                   iimpiva = 0,
                   iretenc = DECODE(moneda, 2, ROUND(retenparcial), retenparcial),
                   pretenc = ret,
                   iconret = DECODE(moneda, 2, ROUND(reducida_parcial), reducida_parcial),
                   isiniva = DECODE(moneda, 2, ROUND(pago_parcial), pago_parcial),
                   iimpsin = DECODE(moneda,
                                    2, ROUND(pago_parcial) - ROUND(retenparcial),
                                    pago_parcial - retenparcial),
                   iresrcm = DECODE(moneda, 2, ROUND(redbruta_parcial), redbruta_parcial),
                   iresred = DECODE(moneda, 2, ROUND(redreduc_parcial), redreduc_parcial)
             WHERE nsinies = siniestro
               AND sperson = aseg.sperson;

            UPDATE pagogarantia
               SET isinret = DECODE(moneda, 2, ROUND(pago_parcial), pago_parcial)
             WHERE cgarant = 283
               AND sidepag IN(SELECT sidepag
                                FROM pagosini
                               WHERE nsinies = siniestro
                                 AND sperson = aseg.sperson);

            UPDATE destinatarios
               SET ivalora = DECODE(moneda, 2, ROUND(pago_parcial), pago_parcial)
             WHERE sperson = aseg.sperson
               AND nsinies = siniestro;

            orden := orden + 1;
         END IF;
      END LOOP;

      CLOSE c_asegurados;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_asegurados%ISOPEN THEN
            CLOSE c_asegurados;
         END IF;

         RETURN(1);
   END;

-- *************************************************************************
-- Anulación de un Rescate parcial, Rescate total o Aportación
-- *************************************************************************
   FUNCTION f_anulacion(
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      pnsinies IN NUMBER,
      pfcartera IN DATE,
      pcmovimi IN NUMBER)
      RETURN NUMBER IS
      movimiento     NUMBER;
      pase           NUMBER;
   BEGIN
-- *** Comenzamos a borrar primero las primas consumidas;
      pase := 1;

      DELETE      primas_consumidas
            WHERE sseguro = psseguro
              AND frescat = pfvalmov;

      pase := 2;

      DELETE      ulreten
            WHERE nsinies = pnsinies;

      pase := 3;

      DELETE      pagogarantia
            WHERE sidepag IN(SELECT sidepag
                               FROM pagosini
                              WHERE nsinies = pnsinies);

      pase := 4.1;

      DELETE      pagosini
            WHERE nsinies = pnsinies;

      pase := 4.2;

      DELETE      destinatarios
            WHERE nsinies = pnsinies;

      pase := 4.3;

      DELETE      valorasini
            WHERE nsinies = pnsinies;

      pase := 4.4;

      DELETE      diariotramitacion
            WHERE nsinies = pnsinies
              AND ntramit = 0;

      pase := 4.5;

      DELETE      tramitacionsini
            WHERE nsinies = pnsinies
              AND ntramit = 0;

      pase := 4.6;

      DELETE      siniestros
            WHERE nsinies = pnsinies;

/*
510 - RESC. TOTAL
506 - RESC. PARCIAL
501 - POL. CADUCADA O VENCIDA
283 - ????? NO EXISTE

*/
      SELECT MAX(nmovimi)
        INTO movimiento
        FROM movseguro
       WHERE sseguro = psseguro
         AND fefecto = pfvalmov
         AND cmotmov IN(510, 506, 501, 283);

      pase := 7;

      DELETE      garanseg
            WHERE sseguro = psseguro
              AND nmovimi = movimiento;

-- PQ LA 287 NO ??
      pase := 8;

      UPDATE garanseg g
         SET ffinefe = NULL
       WHERE nmovimi = (SELECT MAX(nmovimi)
                          FROM garanseg g2
                         WHERE g2.sseguro = g.sseguro)
         AND sseguro = psseguro
         AND cgarant <> 287;

      pase := 9;

      DELETE      claubenseg
            WHERE sseguro = psseguro
              AND nmovimi = (SELECT nmovimi
                               FROM movseguro
                              WHERE sseguro = psseguro
                                AND fefecto = pfvalmov
                                AND cmotmov IN(510, 506, 501, 283));

/*
505 - Anulación de póliza por siniestro
511 - Anulación de póliza por rescate
*/
      pase := 10;

      DELETE      historicoseguros
            WHERE sseguro = psseguro
              AND nmovimi IN(SELECT nmovimi - 1
                               FROM movseguro
                              WHERE sseguro = psseguro
                                AND fefecto = pfvalmov
                                AND cmotmov IN(505, 510, 506, 501, 283, 511));

      pase := 11;

      DELETE      movseguro
            WHERE sseguro = psseguro
              AND fefecto = pfvalmov
              AND cmotmov IN(505, 510, 506, 501, 283, 511);

-- Si es un rescate total o un vencimiento, reactivamos la póliza;
      pase := 12;

      IF pcmovimi IN(32, 34) THEN
         UPDATE seguros
            SET fanulac = NULL,
                fcarpro = pfcartera,
                csituac = 0
          WHERE seguros.sseguro = psseguro;
      END IF;

      pase := 13;

      DELETE      ctaseguro
            WHERE cmovimi IN(32, 33, 34, 27)
              AND ctaseguro.sseguro = psseguro
              AND fvalmov = pfvalmov;

      pase := 14;

      UPDATE seguros_ren
         SET ffinren = NULL,
             cmotivo = NULL
       WHERE sseguro = psseguro;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN pase;
   END;

-- *************************************************************************
-- Poliza bloqueada
-- *************************************************************************
   FUNCTION f_bloqueada(psseguro IN NUMBER, pfvalmov IN DATE)
      RETURN NUMBER IS
      num_err        NUMBER(6);
      fecha_bloqueo  DATE;
      num_bloqueo    NUMBER;
      fecha_desbloqueo DATE;
      fecha_pigno    DATE;
      fecha_despigno DATE;
      valor          NUMBER;
   BEGIN
      fecha_bloqueo := NULL;
      fecha_desbloqueo := NULL;

      --------Control que la póliza está bloqueada
      SELECT MAX(finicio)
        INTO fecha_bloqueo
        FROM bloqueoseg
       WHERE bloqueoseg.sseguro = psseguro
         AND finicio <= pfvalmov
         AND cmotmov = 262;

      --
      IF fecha_bloqueo IS NOT NULL THEN
         SELECT MAX(nbloqueo)
           INTO num_bloqueo
           FROM bloqueoseg
          WHERE bloqueoseg.sseguro = psseguro
            AND finicio = fecha_bloqueo
            AND cmotmov = 262;

         --
         SELECT MAX(finicio)
           INTO fecha_desbloqueo
           FROM bloqueoseg
          WHERE bloqueoseg.sseguro = psseguro
            AND finicio <= pfvalmov
            AND nbloqueo = num_bloqueo
            AND cmotmov = 264;
      END IF;

      IF (fecha_bloqueo IS NOT NULL
          AND fecha_desbloqueo IS NULL)
         OR(fecha_bloqueo > fecha_desbloqueo) THEN
         RETURN(109730);
      END IF;

      RETURN(0);
   END;

-- *************************************************************************
-- Poliza Pignorada
-- *************************************************************************
   FUNCTION f_pignorada(psseguro IN NUMBER, pfvalmov IN DATE, pimporte OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER(6);
      num_bloqueo    NUMBER;
      fecha_pigno    DATE;
      fecha_despigno DATE;
      valor          NUMBER;
   BEGIN
      fecha_pigno := NULL;
      fecha_despigno := NULL;

      --------Control que la póliza está PIGNORADA
      SELECT MAX(finicio)
        INTO fecha_pigno
        FROM bloqueoseg
       WHERE bloqueoseg.sseguro = psseguro
         AND finicio <= pfvalmov
         AND cmotmov = 261;

      --
      IF fecha_pigno IS NOT NULL THEN
         SELECT nbloqueo, iimporte
           INTO num_bloqueo, valor
           FROM bloqueoseg
          WHERE bloqueoseg.sseguro = psseguro
            AND finicio = fecha_pigno
            AND cmotmov = 261
            AND nbloqueo = (SELECT MAX(nbloqueo)
                              FROM bloqueoseg
                             WHERE sseguro = psseguro
                               AND finicio = fecha_pigno
                               AND cmotmov = 261);

         --
         SELECT MAX(finicio)
           INTO fecha_despigno
           FROM bloqueoseg
          WHERE bloqueoseg.sseguro = psseguro
            AND finicio <= pfvalmov
            AND nbloqueo = num_bloqueo
            AND cmotmov = 263;
      END IF;

      --
      IF (fecha_pigno IS NOT NULL
          AND fecha_despigno IS NULL)
         OR(fecha_pigno > fecha_despigno) THEN
         pimporte := valor;
         RETURN(110048);
      END IF;

      --
      pimporte := 0;
      RETURN(0);
   --
   END;

-- *************************************************************************
-- Insertar pagogarantia
-- *************************************************************************
   FUNCTION f_desglosegarant(psidepag IN NUMBER)
      RETURN NUMBER IS
      psidepagfill   NUMBER;
      no_nul         EXCEPTION;

      CURSOR desgarant IS
         SELECT *
           FROM pagogarantia
          WHERE sidepag = psidepagfill;
   BEGIN
      IF psidepag IS NULL THEN
         RAISE no_nul;
      END IF;

      SELECT spganul
        INTO psidepagfill
        FROM pagosini
       WHERE sidepag = psidepag;

      FOR dsg IN desgarant LOOP
         INSERT INTO pagogarantia
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

-- *************************************************************************
-- Insertar Ctaseguro
-- *************************************************************************
   FUNCTION f_provisio(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      provisio OUT NUMBER)
      RETURN NUMBER IS
      aux            NUMBER;
      valoracio      NUMBER;
      pagos          NUMBER;
   BEGIN
      aux := f_valoracio(pnsinies, pcgarant, pdata, valoracio);

      IF aux <> 0 THEN
         RETURN aux;
      END IF;

      aux := f_pagos(pnsinies, pcgarant, pdata, pagos);

      IF aux <> 0 THEN
         RETURN aux;
      END IF;

      provisio := valoracio - pagos;
      RETURN 0;
   END f_provisio;

-- *************************************************************************
-- Pagos
-- *************************************************************************
   FUNCTION f_pagos(pnsinies IN NUMBER, pcgarant IN NUMBER, pdata IN DATE, pagos OUT NUMBER)
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

-- *************************************************************************
-- Valoracio
-- *************************************************************************
   FUNCTION f_valoracio(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      valoracio OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
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

-- *************************************************************************
-- Insertar Ctaseguro
-- *************************************************************************
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
      v_cempres      seguros.cempres%TYPE;
      num_err        axis_literales.slitera%TYPE;
-----------Calculamos el número de línea----------------------------------
   BEGIN
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

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

         -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
            num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, xfcontab,
                                                                  num_linea, pfvalmov);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
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
      v_cempres      seguros.cempres%TYPE;
      num_err        axis_literales.slitera%TYPE;
-----------Calculamos el número de línea----------------------------------
   BEGIN
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

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

         -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
            num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, xfcontab,
                                                                      num_linea, pfvalmov);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 102555;
         WHEN OTHERS THEN
            RETURN 102555;
      END;

      RETURN 0;
   END f_insctaseguro_shw;

-- *************************************************************************
-- Descripción del diario
-- *************************************************************************
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
      pcpostal       codpostal.cpostal%TYPE;   --3606 jdomingo 30/11/2007  canvi format codi postal
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
      dctipdes       VARCHAR2(15);
      dcgarant       VARCHAR2(40);
      dcestpag       VARCHAR2(15);
      dctipdan       VARCHAR2(15);
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

      --
      IF (pclintra = 2) THEN   -- registro modificado en TRAMITACIONSINI
         SELECT t.cestado
           INTO vcestado
           FROM diariotramitacion t
          WHERE t.nsinies = pnsinies
            AND t.ntramit = pntramit
            AND nlintra = pnlintra;

         res := f_desvalorfijo(6, pcidioma, vcestado, dcestado);

         IF (pcidioma = 1) THEN
            pdesc := 'La tramitacio ha canviat a l''estat ' || dcestado || '.';
         ELSIF(pcidioma = 2) THEN
            pdesc := 'La tramitacion ha cambiado al estado ' || dcestado || '.';
         END IF;
      ELSIF(pclintra = 4) THEN   -- registro modificado en DESTINATARIOS
         IF (psperson IS NULL
             OR pctipdes IS NULL) THEN
            RAISE no_nul;
         END IF;

         BEGIN
            SELECT cactpro
              INTO pcactpro
              FROM destinatarios
             WHERE nsinies = pnsinies
               AND sperson = psperson
               AND ctipdes = pctipdes;
         EXCEPTION
            WHEN OTHERS THEN
               pcactpro := NULL;
         END;

         res := f_desvalorfijo(10, pcidioma, pctipdes, dctipdes);
         res := f_desactpro(pcactpro, pcidioma, dcactpro);
         res := f_persona(psperson, 2, dnif, vsperson, dnom, sortida);

         IF (pcidioma = 1) THEN
            IF pctipdes <> 13 THEN
               pdesc := 'El nou destinatari es ' || dnom || ', NIF '
                        || NVL(dnif, '(Sense NIF)') || ' i es del tipus ' || dctipdes || '.';

               IF pcactpro IS NOT NULL THEN
                  pdesc := pdesc || ' La categoria profesional es ' || dcactpro || '.';
               END IF;
            ELSE
               pdesc := 'El testimoni es ' || dnom || ', NIF ' || NVL(dnif, '(Sense NIF)')
                        || '.';
            END IF;
         ELSIF(pcidioma = 2) THEN
            IF pctipdes <> 13 THEN
               pdesc := 'El nuevo destinatario es ' || dnom || ', NIF '
                        || NVL(dnif, '(Sin NIF)') || ' y es del tipo ' || dctipdes || '.';

               IF pcactpro IS NOT NULL THEN
                  pdesc := pdesc || ' La categoria profesional es ' || dcactpro || '.';
               END IF;
            ELSE
               pdesc := 'El testigo es ' || dnom || ', NIF ' || NVL(dnif, '(Sin NIF)') || '.';
            END IF;
         END IF;
      ELSIF(pclintra = 5) THEN   -- registro modificado en VALORASINI
         IF (pcgarant IS NULL
             OR pnvalora IS NULL) THEN
            RAISE no_nul;
         END IF;

         SELECT ivalora
           INTO pivalora
           FROM valorasini
          WHERE nsinies = pnsinies
            AND cgarant = pcgarant
            AND fvalora = (SELECT MAX(fvalora)
                             FROM valorasini
                            WHERE nsinies = pnsinies
                              AND cgarant = pcgarant);

         res := f_desgarantia(pcgarant, pcidioma, dcgarant);

         IF (pcidioma = 1) THEN
            pdesc := 'S''ha introduit una nova valoracio amb garantia ' || dcgarant || '.';
         ELSIF(pcidioma = 2) THEN
            pdesc := 'Se ha introducido una nueva valoracion con garantia ' || dcgarant || '.';
         END IF;
      ELSIF(pclintra = 6) THEN   -- registro modificado en PAGOSINI
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
      ELSIF(pclintra = 7) THEN   -- registro modificado en PAGOGARANTIA
         IF (pcgarant IS NULL
             OR psidepag IS NULL) THEN
            RAISE no_nul;
         END IF;

         SELECT isinret
           INTO pisinret
           FROM pagogarantia
          WHERE cgarant = pcgarant
            AND sidepag = psidepag;

         SELECT sperson
           INTO vsperson
           FROM pagosini
          WHERE sidepag = psidepag;

         res := f_desgarantia(pcgarant, pcidioma, dcgarant);
         res := f_persona(vsperson, 2, dnif, vsperson, dnom, sortida);

         IF (pcidioma = 1) THEN
            pdesc := 'S''ha abonat al Sr./Sra. ' || dnom || ', NIF ' || NVL(dnif, '(Sin NIF)')
                     || ', una quantitat en concepte de la garantia ' || dcgarant || '.';
         ELSIF(pcidioma = 2) THEN
            pdesc := 'Se ha abonado al Sr./Sra. ' || dnom || ', NIF '
                     || NVL(dnif, '(Sin NIF)') || ', una cantidad en concepto de la garantia '
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
            pdesc := 'S''ha afegit una anotacio al diari del profesional ' || dnom || ', NIF '
                     || NVL(dnif, '(Sin NIF)') || ', en estat de ' || dcestado || '.';
         ELSIF(pcidioma = 2) THEN
            pdesc := 'Se ha añadido una anotacion en el diario del profesional ' || dnom
                     || ', NIF ' || NVL(dnif, '(Sin NIF)') || ', en estado de ' || dcestado
                     || '.';
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
END pk_siniestros;

/

  GRANT EXECUTE ON "AXIS"."PK_SINIESTROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_SINIESTROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_SINIESTROS" TO "PROGRAMADORESCSI";
