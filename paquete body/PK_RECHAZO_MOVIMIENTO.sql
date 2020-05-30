--------------------------------------------------------
--  DDL for Package Body PK_RECHAZO_MOVIMIENTO
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PK_RECHAZO_MOVIMIENTO AS
   /******************************************************************************
    NOMBRE:      PK_RECHAZO_MOVIMIENTO
    PROPÓSITO:   Funciones para la producción en segunda capa
    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        ??/??/????   ???              1. Creación del package.
    2.0        16/06/2009   DRA              2. 0010464: CRE - L'anul·lació de propostes pendents d'emetre no tira enderrera correctament el moviment anul·lat.
    3.0        16/06/2009   ETM              3. 0010462: IAX - REA - Eliminar tabla FACPENDIENTES
    4.0        02/09/2009   DRA              4. 0010569: CRE080 - Suplementos/ Anulaciones para el producto Saldo Deutors
    5.0        26/10/2009   XPL              5. 11210 :APR - Reducción de garantías y reducción total de póliza
    6.0        14/01/2010   JMF              6. 0011936 APR - Adaptación de rechazo de movimientos a suplementos no economicos
    7.0        20/06/2011   APD              7. 0018830: CRE800 - Rechazo de suplemento
    8.0        22/11/2011   JMP              8. 0018423: LCOL000 - Multimoneda
    9.0        02/12/2011   JMF              9. 0019802 LCOL_T001-Adaptación proceso de cartera (Vida Individual)
   10.0        03/01/2012   JMF             10. 0020761 LCOL_A001- Quotes targetes
   11.0        21/02/2012   APD             11. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
   12.0        11/04/2012   ETM             12. 0021924: MDP - TEC - Nuevos campos en pantalla de Gestión (Tipo de retribución, Domiciliar 1º recibo, Revalorización franquicia)
   13.0        23/04/2011   MDS             13. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
   14.0        01/08/2012   FPG             14. 0023075: LCOL_T010-Figura del pagador
   15.0        14/08/2012   DCG             15. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   16.0        14/11/2012   DCT             16. 0024505: LCOL_T001-QTracker: 4877: Hace cesion cuando hay movimientos de ahorro
   17.0        30/11/2012   DCT             17. 0024655: LCOL_T010-LCOL - Revision incidencias qtracker (II)
   18.0        06/02/2013   APD             18. 0025840: LCOL_T031-LCOL - Fase 3 - (Id 111, 112, 115) - Parametrización suplementos
   19.0        18/03/2013   ECP             19. 0026485: LCOL_T001- QT 6824: Impresi?n P?liza Suplementos Realizados y Consulta de P?liza No Muestran Beneficiarios
   20.0        25/11/2013   DCT             20. 0024450: LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS
   21.0        10/02/2014   JDS             21. 0029665: LCOL_PROD-Qtrackers Fase 2 - iAXIS Produccion
   22.0        21/02/2014   JDS             22. 0026420: POSRA200-Parametrizaci?n Final de Vida Individual
   23.0        11/07/2014   DCT             23. 0032009: LCOL_PROD-LCOL_T031-Revisión Fase 3A Producción
   24.0        06/02/2015   AFM             24. 0034461: PRB. Productos de convenios
   25.0        22/06/2015   CJMR            25. 36397/208377: PRB. Corrección Anulación de un suplemento de regularización
   26.0        17/03/2016   JAEG            26. 41143/229973: Desarrollo Diseño técnico CONF_TEC-01_VIGENCIA_AMPARO
   27.0        26/08/2019   ECP             27. IAXIS-5120. Revisión Anulación Suplemento.
   28.0        05/08/2019   SPV             28. IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
   29.0        23/10/2019   DFR             29. IAXIS-4926: Anulación de póliza y movimientos con recibos abonados y Reversión de recaudos en recibos.
   30.0        18/11/2019   DFR             30. IAXIS-7627: Verificación de campo CSUBTIPREC de la tabla RECIBOS para efectos contables. 
   31.0        17/01/2020   CJMR            31. IAXIS-3640: Anulaciones. Corrección fechas de plazo de ejecución en anulaciones
   32.0        13/02/2020   ECP             32. IAXIS-12909. Error al realizar anulación de endosos
   ******************************************************************************/
   FUNCTION f_validar_recibo(psseguro IN NUMBER,
                             pnmovimi IN NUMBER) RETURN NUMBER IS
      /**********************************************************************************************
               devolvemos las siguientes situaciones
            0 - No hay recibos
            1 - Hay recibos de cartera porteriores al suplemento
            2 - Los recibos tienen distinto estado de impresión
            3 - El estado de impresión no es el permitido para anular el suplemento
            4 - Se pueden borrar los recibos.
            5 - When others
            6 - Se pueden anular los recibos.
      ***********************************************************************************************/
      num_rec   NUMBER;
      num_dev   NUMBER;
      wtipo     NUMBER;
      westimp   NUMBER;
      situacion NUMBER;
      vobject   VARCHAR2(100) := 'pk_rechazo_movimiento.f_validar_recibo';

      -- Lista de recibos cobrados sólo con prima devengada
      CURSOR c2 IS
         SELECT nrecibo
           FROM recibos a
          WHERE sseguro = psseguro
            AND f_cestrec(nrecibo, NULL) = 1
            AND nmovimi = pnmovimi
            AND EXISTS (SELECT 1
                   FROM vdetrecibos x
                  WHERE x.nrecibo = a.nrecibo
                    AND x.iprinet = 0);

      v_recpridev VARCHAR2(2000);
   BEGIN
      -- Me guardo lista de recibos cobrados prima devengada, para comprobar despues.
      FOR f2 IN c2
      LOOP
         v_recpridev := v_recpridev || f2.nrecibo || ',';
      END LOOP;

      -- Mirar si existen recibos.
      SELECT COUNT(*)
        INTO num_rec
        FROM recibos
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi;

      IF num_rec = 0
      THEN
         -- caso 0 - No hay recibos
         situacion := 0;
      ELSE
         -- Mirar cuantos tenemos cobrados prima devengada
         SELECT COUNT(*)
           INTO num_dev
           FROM recibos
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND INSTR(v_recpridev, nrecibo || ',') > 0;

         IF num_dev = num_rec
         THEN
            -- Si sólo existen recibos cobradros prima devengada
            -- caso 6 - Se pueden anular los recibos.
            situacion := 6;
         ELSE
            BEGIN
               -- Comprobamos que todos sean el mismo tipo de recibo
               -- Los recibos cobrados prima devengada no los miramos.
               SELECT DISTINCT (ctiprec)
                 INTO wtipo
                 FROM recibos
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND NVL(INSTR(v_recpridev, nrecibo || ','), 0) = 0;

               BEGIN
                  -- Comprobamos que todos tengan el mismo estado de impresión
                  -- Los recibos cobrados prima devengada no los miramos.
                  SELECT DISTINCT (cestimp)
                    INTO westimp
                    FROM recibos
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND NVL(INSTR(v_recpridev, nrecibo || ','), 0) = 0;

                  -- Sólo hay un estado de impresión, miramos si es uno de los permitidos
                  IF westimp NOT IN (0, 1, 4, 7)
                  THEN
                     -- caso 3 - El estado de impresión no es el permitido para anular el suplemento
                     situacion := 3;
                  ELSE
                     -- Bug 0011936 - JMF - 14/01/2010
                     --situacion := 4;
                     -- caso 6 - Se pueden anular los recibos.
                     situacion := 6;
                  END IF;
               EXCEPTION
                  WHEN TOO_MANY_ROWS THEN
                     -- Hay distintos estados de impresión
                     -- caso 2 - Los recibos tienen distinto estado de impresión
                     situacion := 2;
               END;
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  -- Caso 1 - Hay recibos de cartera porteriores al suplemento
                  situacion := 1;
            END;
         END IF;
      END IF;

      -- Bug 0011936 - JMF - 14/01/2010
      -- RETURN 0;
      RETURN situacion;
   EXCEPTION
      WHEN OTHERS THEN
         situacion := 5;
         RETURN situacion;
   END f_validar_recibo;

   FUNCTION f_comprobar_cobrador(psseguro IN NUMBER,
                                 pcempres IN NUMBER) RETURN NUMBER IS
      -- Busqueda de las direcciones del tomador.
      CURSOR ccpostal(psperson NUMBER,
                      pcdomici NUMBER) IS
         SELECT cpostal FROM direcciones WHERE sperson = psperson;

      -- Busqueda de la delegacion correpondiente.
      CURSOR delpostal(pcpostal codpostal.cpostal%TYPE)
      -- canvi format codi postal
      IS
         SELECT cagedel
           FROM delegaciones_codpostal
          WHERE cpostal = pcpostal
            AND ctipdel = 1;

      -- Busqueda del agente cobrador.
      CURSOR redcom(pempresa NUMBER,
                    pcagedel NUMBER) IS
         SELECT cagente
           FROM redcomercial
          WHERE cempres = pempresa
            AND ctipage = 11
            AND fmovfin IS NULL
          START WITH cpadre = pcagedel
                 AND cempres = pempresa
                 AND fmovfin IS NULL
         CONNECT BY cpadre = PRIOR cagente
                AND PRIOR cempres = cempres
                AND fmovfin IS NULL;

      CURSOR agen(pcagente NUMBER) IS
         SELECT sperson FROM agentes WHERE cagente = pcagente;

      xval0        NUMBER;
      xval1        NUMBER;
      xval2        NUMBER;
      indice3      NUMBER := 1;
      xnom         VARCHAR2(100);
      xresultat    NUMBER;
      xsperson     NUMBER(10);
      xcdomici     NUMBER(2);
      xcagedel     NUMBER(6) := NULL;
      xcagecob     NUMBER(6) := NULL;
      xnif         VARCHAR2(12);
      xerror       NUMBER := 0;
      xagentecob   NUMBER := 0;
      v_encontrado BOOLEAN := TRUE;
      pcobrador    NUMBER;
   BEGIN
      BEGIN
         SELECT NVL(cagecob, 0)
           INTO pcobrador
           FROM agentescob
          WHERE sseguro = psseguro
            AND nrecibo IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xerror := 105111; -- Tomador no encontrado en la tabla TOMADORES.
         WHEN OTHERS THEN
            xerror := 105112; -- Error al leer de la tabla TOMADORES.
      END;

      BEGIN
         SELECT sperson,
                cdomici
           INTO xsperson,
                xcdomici
           FROM tomadores
          WHERE sseguro = psseguro
            AND nordtom = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xerror := 105111; -- Tomador no encontrado en la tabla TOMADORES.
         WHEN OTHERS THEN
            xerror := 105112; -- Error al leer de la tabla TOMADORES.
      END;

      FOR valor0 IN ccpostal(xsperson, xcdomici)
      LOOP
         xval0 := 1;

         -- IF xcpostal IS NULL THEN
         --     perror:= 110695;   -- Tomador no tiene informado el código postal.
         -- END IF;
         FOR valor1 IN delpostal(valor0.cpostal)
         LOOP
            xval1 := 1;

            FOR valor2 IN redcom(pcempres, valor1.cagedel)
            LOOP
               xval2 := 1;

               OPEN agen(valor2.cagente);

               FETCH agen
                  INTO xsperson;

               CLOSE agen;

               -- Buscar el nombre del agente por xsperson
               xerror := f_persona(xsperson,
                                   2,
                                   xnif,
                                   xsperson,
                                   xnom,
                                   xresultat);

               IF TO_CHAR(valor2.cagente) = pcobrador
               THEN
                  v_encontrado := TRUE;
                  EXIT;
               END IF;

               indice3 := indice3 + 1;
            END LOOP;

            IF v_encontrado
            THEN
               EXIT;
            END IF;
         END LOOP;

         IF v_encontrado
         THEN
            EXIT;
         END IF;
      END LOOP;

      IF xval1 IS NULL
      THEN
         xerror := 107575;
         -- No puede localizarse una dirección para el tomador.
      END IF;

      IF xval1 IS NULL
      THEN
         xerror := 110693;
         -- No existe delegación asignada al código postal del tomador.
      END IF;

      IF xval2 IS NULL
      THEN
         xerror := 110694;
         -- No existe cobrador asignado a la delegación correspondiente.
      END IF;

      IF v_encontrado
      THEN
         RETURN 0;
      ELSE
         SELECT DECODE(xerror, 0, 1, xerror) INTO xerror FROM dual;

         RETURN xerror;
      END IF;
   END f_comprobar_cobrador;

   --INICIO 32009 - DCT - 11/07/2014.- Añadir parámetro poriduplic
   FUNCTION f_anulacion_propuesta(psseguro   IN NUMBER,
                                  pcmotmov   IN NUMBER,
                                  paccion    IN NUMBER,
                                  poriduplic IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vsproduc  NUMBER;
      vparampsu NUMBER;
   BEGIN
      -- Modificamos la situación de la póliza a anulada.
      -- pero mantenemos el movimiento de nueva producción.
      UPDATE seguros SET creteni = paccion WHERE sseguro = psseguro;

      SELECT sproduc INTO vsproduc FROM seguros WHERE sseguro = psseguro;

      vparampsu := pac_parametros.f_parproducto_n(vsproduc, 'PSU');

      -- 19/10/2012 LRE - JLB - que siempre inserte en la tabla de motanuv
      --   IF NVL(vparampsu, 0) = 0 THEN
      BEGIN
         INSERT INTO motanumov
            (sseguro, nmovimi, cmotmov, falta, cusualt)
         VALUES
            (psseguro, 1, pcmotmov, f_sysdate, f_user);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'pk_rechazo_movimiento.f_anulacion_propuesta',
                        1,
                        'error en el motivo de anulacion',
                        SQLERRM);

            --INICIO 32009 - DCT - 11/07/2014.- Si el parámetro poriduplic és NULL realizamos el return sino continuamos.
            IF poriduplic IS NULL
            THEN
               RETURN 151371; --Error en el motivo de anulación
            END IF;
            --FIN 32009 - DCT - 11/07/2014.- Si el parámetro poriduplic és NULL realizamos el return sino continuamos.
      END;

      --ELS
      IF NVL(vparampsu, 0) = 1
      THEN
         UPDATE psu_retenidas
            SET cmotret = 4
          WHERE sseguro = psseguro
            AND nmovimi = 1;
      END IF;

      RETURN 0;
   END f_anulacion_propuesta;

   FUNCTION f_anulacion_suplemento(psseguro IN NUMBER,
                                   pcmotmov IN NUMBER,
                                   pnsuplem IN NUMBER,
                                   paccion  NUMBER,
                                   pnmovimi IN NUMBER DEFAULT NULL,
                                   pnorec   IN NUMBER DEFAULT 0) RETURN NUMBER IS
      -- Bug 0011936 - JMF - 14/01/2010: Afegir movimient.
      -- ini Bug 0011936 - JMF - 14/01/2010
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := ' seg=' || psseguro || ' mot=' || pcmotmov ||
                                 ' sup=' || pnsuplem || ' acc=' || paccion ||
                                 ' pm=' || pnmovimi || ' pnorec=' || pnorec;
      v_object  VARCHAR2(200) := 'pk_rechazo_movimiento.f_anulacion_suplemento';
      -- fin Bug 0011936 - JMF - 14/01/2010
      ttexto            VARCHAR2(100);
      movi_ac           NUMBER;
      movi_ant          NUMBER;
      num_err           NUMBER;
      regseguro         historicoseguros%ROWTYPE;
      regseguro_aux     seguros%ROWTYPE;
      aux_pppc          NUMBER;
      borrar_recibo     BOOLEAN;
      situacion         NUMBER;
      motmovbloq        NUMBER;
      numbloq           NUMBER;
      ffinalbloq        DATE;
      movimibloq        NUMBER;
      v_agente_cobrador NUMBER := 0;
      vcount            NUMBER := 0;
      --CONF-220 KJSC Anular suplementos con recibos cobrados CONF
      vrecibo NUMBER := 0;

      --RAL BUG 0036650: POSES100-Error al emitir colectivo despues de modificar riesgo (bug hermano interno)

      -- Si --> 0 : El agente cobrador pertenece al codigo postal del tomador.

      --> 1 : El agente cobrador assignado no pertenece al codigo postal del tomador.

      --> 1 : Ha cambiado el cbancar al movimiento anterior, y se tiene que generar un movimiento.
      CURSOR c_recibos(wnmovimi NUMBER) IS
         SELECT nrecibo,
                cestimp
           FROM recibos
          WHERE sseguro = psseguro
            AND nmovimi = wnmovimi;

      --bfp ini bug 20672/0113114: LCOL_T001-LCOL - UAT - TEC: Suplementos
      CURSOR c_historicoriesgos(wnmovimi NUMBER) IS
         SELECT nriesgo,
                sseguro,
                nmovimi,
                tnatrie,
                cdomici,
                nasegur,
                nedacol,
                csexcol,
                sbonush,
                czbonus,
                ctipdiraut,
                spermin,
                cactivi,
                pdtocom,
                precarg,
                pdtotec,
                preccom
         --                nmovima, fefecto, cclarie, nmovimb, fanulac, sseguro, nriesgo, nmovimi,
         --                tnatrie, cdomici, nasegur, nedacol, csexcol, ctipdiraut
         --          FROM historicoriesgos
           FROM hisriesgos
          WHERE sseguro = psseguro
            AND nmovimi = wnmovimi;

      -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - incluir campo cexistepagador
      CURSOR c_histomadores(wnmovimi NUMBER) IS
         SELECT sseguro,
                sperson,
                nmovimi,
                nordtom,
                cdomici,
                cexistepagador
           FROM histomadores
          WHERE sseguro = psseguro
            AND nmovimi = wnmovimi;

      CURSOR c_hisasegurados(wnmovimi NUMBER) IS
         SELECT sseguro,
                sperson,
                nmovimi,
                norden,
                cdomici,
                ffecfin,
                ffecmue,
                fecretroact,
                ffecini,
                --BUG24505: DCT : 14/11/2012 - Añadir ffecini
                cparen
           FROM hisasegurados
          WHERE sseguro = psseguro
            AND nmovimi = wnmovimi;

      --bfp fi bug 20672/0113114: LCOL_T001-LCOL - UAT - TEC: Suplementos
      mov_reg        movseguro%ROWTYPE;
      seg_reg        seguros%ROWTYPE;
      v_hay_anterior BOOLEAN;
      v_escertif0    NUMBER;
      v_meses        NUMBER;
      v_fcarpro_cert seguros.fcarpro%TYPE;
      v_fcarant_cert seguros.fcarant%TYPE;
      v_fcaranu_cert seguros.fcaranu%TYPE;
      v_nfracci_cert seguros.nfracci%TYPE;
      v_sproces      procesoscab.sproces%TYPE;
      vnumerr        NUMBER;
      v_crespue_4790 pregunpolseg.crespue%TYPE;
      v_fcontab      DATE;
      --BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS
      v_nrecibo recibos.nrecibo%TYPE;
      --BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS
      v_cmotmov        NUMBER; -- bug 27766
      v_cambiostomador NUMBER := 0; -- BUG 0038051 - FAL - 13/10/2015
      --
      -- Inicio IAXIS-4926 23/10/2019
      --
      viimporte_moncon NUMBER;
      viimporte        NUMBER;
      --
      -- Fin IAXIS-4926 23/10/2019
      --
   BEGIN
      v_pasexec := 1;

      BEGIN
         SELECT * INTO seg_reg FROM seguros WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903; --Seguro no encontrado
      END;

      v_pasexec := 2;

      BEGIN
         -- Bug 0011936 - JMF - 14/01/2010: Afegir movimient.
         IF pnmovimi IS NOT NULL
         THEN
            SELECT *
              INTO mov_reg
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;
         ELSE
            SELECT *
              INTO mov_reg
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM movseguro
                               WHERE sseguro = psseguro
                                 AND cmovseg <> 52);
            -- No anulado
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903; --seguro no econtrado
      END;
 -- Ini IAXIS-12909 -- ECP -- 13/02/2020 -- Para que permita anular todos los Tipos de MOvimientos
      --Obtenemos el motivo de suplemento del que quermos retroceder
      /*IF mov_reg.cmotmov IN (212, 214, 218, 219, 220, 222, 223, 251, 255)
      THEN
         RETURN 104620;
      ELS*/
      -- Fin IAXIS-12909 -- ECP -- 13/02/2020
      IF mov_reg.cmotmov IN (211, 215)
      THEN
         v_pasexec := 3;

         -- Bug 0011936 - JMF - 14/01/2010: Afegir movimient.
         IF pnmovimi IS NOT NULL
         THEN
            movi_ac := pnmovimi;
         ELSE
            SELECT MAX(nmovimi)
              INTO movi_ac
              FROM movseguro
             WHERE sseguro = psseguro
               AND nsuplem = pnsuplem
               AND cmovseg <> 52;
            -- No anulado
         END IF;

         v_param := v_param || ' mov=' || movi_ac;
         --  No se puede anular si existen provisiones
         v_pasexec := 4;

         -- ini Bug 0011936 - JMF - 14/01/2010: Rendimiento
         -- SELECT COUNT(*)
         --   INTO aux_pppc
         --   FROM pppc
         --  WHERE sseguro = psseguro
         --    AND nmovimi = movi_ac;
         DECLARE
            CURSOR c1 IS
               SELECT 1
                 FROM pppc
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;
         BEGIN
            OPEN c1;

            FETCH c1
               INTO aux_pppc;

            IF c1%FOUND
            THEN
               aux_pppc := 1;
            ELSE
               aux_pppc := 0;
            END IF;

            CLOSE c1;
         END;

         -- fin Bug 0011936 - JMF - 14/01/2010: Rendimiento
         IF aux_pppc > 0
         THEN
            RETURN 107646;
         ELSE
            -------- Moviments
            -- Modificamos la prima
            v_pasexec := 5;

            UPDATE seguros
               SET csituac  = 0,
                   creteni  = 0,
                   ccartera = NULL,
                   iprianu  = f_segprima(psseguro, mov_reg.fefecto)
             WHERE sseguro = psseguro;

            -- Anulamos el último suplemento.
            v_pasexec := 6;

            UPDATE movseguro
               SET cmovseg = 52,
                   fanulac = f_sysdate,
                   fcontab = f_sysdate,
                   cusuanu = f_user
             WHERE sseguro = psseguro
               AND nmovimi = movi_ac;
            -------------------
         END IF;
      ELSE
         -- De momento el suplemento multiple lo dejamos pasar y lo anulamos todo
         borrar_recibo := FALSE;
         v_pasexec     := 7;

         -- Bug 0011936 - JMF - 14/01/2010: Afegir movimient.
         IF pnmovimi IS NOT NULL
         THEN
            movi_ac := pnmovimi;
         ELSE
            SELECT MAX(nmovimi)
              INTO movi_ac
              FROM movseguro
             WHERE sseguro = psseguro
               AND nsuplem = pnsuplem
               AND cmovseg <> 52;
            -- No anulado
         END IF;

         v_param := v_param || ' mov=' || movi_ac;
         --  No se puede anular si existen provisiones
         v_pasexec := 8;

         -- ini Bug 0011936 - JMF - 14/01/2010: Rendimiento
         --SELECT COUNT(*)
         --  INTO aux_pppc
         --  FROM pppc
         -- WHERE sseguro = psseguro
         --   AND nmovimi = movi_ac;
         DECLARE
            CURSOR c1 IS
               SELECT 1
                 FROM pppc
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;
         BEGIN
            OPEN c1;

            FETCH c1
               INTO aux_pppc;

            IF c1%FOUND
            THEN
               aux_pppc := 1;
            ELSE
               aux_pppc := 0;
            END IF;

            CLOSE c1;
         END;

         -- fin Bug 0011936 - JMF - 14/01/2010: Rendimiento
         IF aux_pppc > 0
         THEN
            RETURN 107646;
         ELSE
            IF pnorec = 0
            THEN
               -- Mirem si està emesa (per tant té rebuts)
               IF seg_reg.csituac = 0
               THEN
                  -- Podemos tener varias situaciones:
                  -- a) Tenemos varios recibos, pero todos generados por el mismo suplemento,
                  --    porque es un recibo por riesgo.
                  -- b) Tenemos varios recibos, todos con el mismo nº de suplemento, pero
                  --    son de cartera (en este caso, no se puede hacerla anulación del
                  --    suplemento anterior).
                  -- c) no hay recibos generados por el suplemento.
                  v_pasexec := 9;
                  situacion := f_validar_recibo(psseguro, movi_ac);

                  IF situacion = 0
                  THEN
                     -- No trobem cap rebut
                     borrar_recibo := TRUE;
                     -- Bug 26151 - APD - 26/02/2013 - se comenta aqui la situiacion = 1
                     -- ya que se quiere que haga lo mismo que en la situacion = 6
                     /*ELSIF situacion = 1 THEN
                     -- hay recibos de cartera posteriores al suplemento
                     borrar_recibo := FALSE;*/
                     --  fin Bug 26151 - APD - 26/02/2013
                  ELSIF situacion = 2
                  THEN
                     -- el estado de impresión del recibo no es el mismo para todos
                     borrar_recibo := FALSE;
                  ELSIF situacion = 3 AND
                        mov_reg.cmotmov <> 296
                  THEN
                     -- el estado de impresion del recibo no es el permitido
                     -- El rebut no es pot esborrar
                     borrar_recibo := FALSE;
                  ELSIF situacion = 4 OR
                        (mov_reg.cmotmov = 296 AND situacion = 3)
                  THEN
                     v_pasexec := 10;

                     FOR reb IN c_recibos(movi_ac)
                     LOOP
                        ------   Rebuts
                        BEGIN
                           v_pasexec := 11;

                           DELETE FROM movrecibo
                            WHERE nrecibo = reb.nrecibo;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_pasexec := 12;

                              DELETE FROM liquidalin
                               WHERE nrecibo = reb.nrecibo;

                              v_pasexec := 13;

                              DELETE FROM movrecibo
                               WHERE nrecibo = reb.nrecibo;
                        END;

                        -- Dejamos constancia de que hemos borrado un recibo
                        v_pasexec := 14;

                        INSERT INTO borraproces
                           (nrecibo, fproces, sseguro, cusuari, tdescrip) -- BUG 0041482 - FAL - 08/04/2016
                        VALUES
                           (reb.nrecibo, f_sysdate, psseguro, f_user, NULL);

                        v_pasexec := 15;

                        DELETE FROM detrecibos WHERE nrecibo = reb.nrecibo;

                        v_pasexec := 16;

                        -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
                        DELETE FROM vdetrecibos_monpol
                         WHERE nrecibo = reb.nrecibo;

                        -- FIN BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
                        DELETE FROM vdetrecibos
                         WHERE nrecibo = reb.nrecibo;

                        v_pasexec := 17;

                        DELETE FROM recibosredcom
                         WHERE nrecibo = reb.nrecibo;

                        -- Afegim CARTAAVIS
                        v_pasexec := 18;

                        DELETE FROM cartaavis WHERE nrecibo = reb.nrecibo;

                        -- Borramos los agentescob del seguro
                        v_pasexec := 19;

                        DELETE FROM agentescob WHERE nrecibo = reb.nrecibo;

                        v_pasexec := 20;

                        DELETE FROM recibos WHERE nrecibo = reb.nrecibo;
                     END LOOP;

                     borrar_recibo := TRUE;
                  ELSIF situacion = 5
                  THEN
                     borrar_recibo := FALSE;
                     RETURN 0;
                     -- Bug 26151 - APD - 26/02/2013 - se añade aqui la situiacion = 1
                     -- ya que se quiere que haga lo mismo que en la situacion = 6
                  ELSIF situacion IN (1, 6)
                  THEN
                     -- fin Bug 26151 - APD - 26/02/2013
                     -- ini Bug 0011936 - JMF - 14/01/2010: 6 - Se pueden anular los recibos.
                     v_pasexec := 200;

                     DECLARE
                        d_efeanu  DATE := f_sysdate;
                        d_emianu  DATE := TRUNC(f_sysdate);
                        ssmovrec  NUMBER := 0;
                        n_motanul NUMBER := 52;
                        nnliqmen  NUMBER;
                        nnliqlin  NUMBER;

                        CURSOR c1 IS
                        -- Recibos pendientes
                        --
                        -- Inicio IAXIS-4926 23/10/2019
                        --
                        SELECT nrecibo, cdelega, 0 cobrat, ctiprec 
                          FROM recibos r
                         WHERE r.sseguro = psseguro
                           AND f_cestrec(r.nrecibo, NULL) = 0
                           AND r.nmovimi = movi_ac
                           AND r.ctiprec <> 5
                        -- Los recibos de extorno y suplemento clonados no se anulan, los dejamos pendientes tal cual como fueron clonados.
                           AND NOT EXISTS (SELECT 1
                                             FROM recibosclon rc
                                            WHERE rc.nreciboact = r.nrecibo
                                              AND rc.corigen = 2);                   
                        -- Se excluyen los recibos cobrados pues por requerimiento de SAP deben permanecer cobrados.
                        /*UNION
                        -- Recibos cobrados sólo con prima devengada
                        SELECT nrecibo, cdelega, 1 cobrat, ctiprec 
                          FROM recibos a
                         WHERE sseguro = psseguro
                           AND f_cestrec(nrecibo, NULL) = 1
                           AND nmovimi = movi_ac
                           AND EXISTS (SELECT 1
                                         FROM vdetrecibos x
                                        WHERE x.nrecibo = a.nrecibo
                                         AND x.iprinet = 0)
                           AND ctiprec <> 5;*/
                        --   
                        -- Fin IAXIS-4926 23/10/2019   
                        --
                     BEGIN
                        v_pasexec := 202;

                        -- Anular recibos
                        FOR f1 IN c1
                        LOOP
                           v_pasexec := 204;

                           -- Bug 26151 - APD - 27/02/2013 - antes de anular el recibo
                           -- se debe mirar si el recibo es un recibo agrupado. Si es
                           -- asi se anularan todos los recibos que cuelgan de el.
                           FOR v_recind IN (SELECT nrecibo
                                              FROM adm_recunif a
                                             WHERE nrecunif = f1.nrecibo)
                           LOOP
                              --Bug 28925 - 11/11/2013 - JMC
                              SELECT MAX(greatest(fmovini, d_emianu))
                                INTO d_emianu
                                FROM movrecibo
                               WHERE nrecibo = v_recind.nrecibo
                                 AND fmovfin IS NULL;

                              --Fi Bug 28925 - 11/11/2013 - JMC
                              num_err := f_movrecibo(v_recind.nrecibo,
                                                     2,
                                                     d_efeanu,
                                                     2,
                                                     ssmovrec,
                                                     nnliqmen,
                                                     nnliqlin,
                                                     d_emianu,
                                                     NULL,
                                                     f1.cdelega,
                                                     n_motanul,
                                                     NULL);
                           END LOOP;

                           -- fin Bug 26151 - APD - 27/02/2013
                           SELECT MAX(greatest(fmovini, d_emianu))
                             INTO d_emianu
                             FROM movrecibo
                            WHERE nrecibo = f1.nrecibo
                              AND fmovfin IS NULL;

                           IF f1.cobrat = 1
                           THEN
                              -- Els rebuts cobrats prima devengada, primer el posem a pendent i despres anulem.
                              v_pasexec := 206;
                              --
                              -- Inicio IAXIS-4926 23/10/2019
                              --
                              -- Al no haber ningún recibo cobrado, lo siguiente nunca se ejecuta y el recibo cobrado permanece cobrado
                              --
                              -- Fin IAXIS-4926 23/10/2019
                              --
                              num_err   := f_movrecibo(f1.nrecibo,
                                                       0,
                                                       d_efeanu,
                                                       2,
                                                       ssmovrec,
                                                       nnliqmen,
                                                       nnliqlin,
                                                       d_emianu,
                                                       NULL,
                                                       f1.cdelega,
                                                       n_motanul,
                                                       NULL);
                           END IF;

                           v_pasexec := 208;
                           --CONF-220 KJSC Anular suplementos con recibos cobrados CONF
                           IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                                'REC_COBRADO'),
                                  0) = 1
                           THEN
                             --
                             -- Inicio IAXIS-4926 23/10/2019
                             -- 
                             -- Esto es requerimiento exclusivo de SAP. Se revisa si el recibo tiene o no recaudos: 
                             -- * Si los tiene, el recibo está recaudado parcialmente (y se encuentra en estado pendiente) y no se deberá anular para que SAP
                             --   los compense como corresponda haciendo uso del recibo clonado.
                             -- * Si no los tiene, se deberá anular. Antes, más arriba, se controla también que para estos recibos sin recaudo no se genere             
                             --   ningún clon.
                             --
                             -- Si el recibo no tiene recaudo, se anula. 
                             --
                             IF NOT (pac_adm_cobparcial.f_get_importe_cobro_parcial(f1.nrecibo) > 0) THEN
                               --
                               num_err := f_movrecibo(f1.nrecibo,
                                                      2,
                                                      d_efeanu,
                                                      2,
                                                      ssmovrec,
                                                      nnliqmen,
                                                      nnliqlin,
                                                      d_emianu,
                                                      NULL,
                                                      f1.cdelega,
                                                      n_motanul,
                                                       NULL);   
                             END IF;                          
                           ELSE
                              --
                              -- Inicio IAXIS-4926 23/10/2019
                              --
                              -- Esto nunca se ejecuta debido al valor del parámetro REC_COBRADO.
                              --
                              -- Fin IAXIS-4926 23/10/2019
                              --
                              num_err := f_movrecibo(f1.nrecibo,
                                                     2,
                                                     d_efeanu,
                                                     2,
                                                     ssmovrec,
                                                     nnliqmen,
                                                     nnliqlin,
                                                     d_emianu,
                                                     NULL,
                                                     f1.cdelega,
                                                     n_motanul,
                                                     NULL);
                           END IF;

                        END LOOP;

                        v_pasexec     := 210;
                        borrar_recibo := TRUE;
                     END;
                     -- fini Bug 0011936 - JMF - 14/01/2010
                  END IF;
               ELSE
                  -- Si es propuesta suplemento
                  borrar_recibo := TRUE;
               END IF;
            ELSE
               borrar_recibo := TRUE;
            END IF; --IF pnorec  0 THEN

            v_pasexec := 21;
            num_err   := f_comprobar_cobrador(psseguro, seg_reg.cempres);

            /***************************************************************************
             ************Aqui hay que tratar el comprobar cobrador***********************
            ***************************************************************************/
            IF borrar_recibo
            THEN
               -- Se modifica los riesgos si han sido rehabilitados a una fecha en concreto, es decir
               -- por suplemento.
               --bfp ini bug 20672/0113114: LCOL_T001-LCOL - UAT - TEC: Suplementos
               --FOR reg IN c_historicoriesgos(movi_ac - 1) LOOP
               FOR reg IN c_historicoriesgos(movi_ac)
               LOOP
                  v_pasexec := 22;

                  --                  UPDATE riesgos
                  --                     SET nmovima = reg.nmovima,
                  --nmovimb = reg.nmovimb,
                  --fanulac = reg.fanulac,
                  --fefecto = reg.fefecto,
                  --cclarie = reg.cclarie,
                  --                         tnatrie = reg.tnatrie,
                  --                         cdomici = reg.cdomici,
                  --                         nasegur = reg.nasegur,
                  --                         nedacol = reg.nedacol,
                  --                         csexcol = reg.csexcol,
                  --                         ctipdiraut = reg.ctipdiraut
                  --                   WHERE sseguro = reg.sseguro
                  --                     AND nriesgo = reg.nriesgo;
                  UPDATE riesgos
                     SET --nmovima = reg.nmovimi, --Bug 24657 - XVM - 10/01/2013. Inicio
                             tnatrie = reg.tnatrie,
                         cdomici    = reg.cdomici,
                         nasegur    = reg.nasegur,
                         nedacol    = reg.nedacol,
                         csexcol    = reg.csexcol,
                         sbonush    = reg.sbonush,
                         czbonus    = reg.czbonus,
                         ctipdiraut = reg.ctipdiraut,
                         spermin    = reg.spermin,
                         cactivi    = reg.cactivi,
                         -- Ini Bug 21907 - MDS - 02/05/2012
                         pdtocom = reg.pdtocom,
                         precarg = reg.precarg,
                         pdtotec = reg.pdtotec,
                         preccom = reg.preccom
                  -- Fin Bug 21907 - MDS - 22/05/2012
                   WHERE sseguro = reg.sseguro
                     AND nriesgo = reg.nriesgo;

                  --bfp fi bug 20672/0113114: LCOL_T001-LCOL - UAT - TEC: Suplementos
                  v_pasexec := 23;

                  UPDATE notibajagar
                     SET crehab = NULL, nmovrehab = NULL
                   WHERE sseguro = reg.sseguro
                     AND nriesgo = reg.nriesgo
                     AND nmovrehab = movi_ac;

                  v_pasexec := 24;

                  -- Ini Bug 21907 - MDS - 02/05/2012
                  --DELETE FROM historicoriesgos
                  DELETE FROM hisriesgos
                  -- Fin  Bug 21907 - MDS - 02/05/2012
                   WHERE sseguro = reg.sseguro
                     AND nriesgo = reg.nriesgo
                     AND nmovimi = reg.nmovimi;
               END LOOP;

               v_pasexec := 25;

               DELETE FROM garansegcom
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -- Bug 21121 - APD - 21/02/2012 - se incluye la tabla detprimas
               DELETE FROM detprimas
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -- fin Bug 21121 - APD - 21/02/2012
               -------- Notificacion de baja
               v_pasexec := 26;

               DELETE FROM notibajaseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -------- Notificacion de baja de garantías
               v_pasexec := 27;

               DELETE FROM notibajagar
                WHERE sseguro = psseguro
                  AND nmovimb = movi_ac;

               -------- Exclusiones
               v_pasexec := 28;

               DELETE FROM excluseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -------- Carencias
               v_pasexec := 29;

               DELETE FROM carenseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -------- Preguntes
               v_pasexec := 30;

               DELETE FROM pregunseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               DELETE FROM pregunsegtab
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               v_pasexec := 31;

               DELETE FROM pregungaranseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               DELETE FROM pregungaransegtab
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               v_pasexec := 32;

               DELETE FROM pregunpolseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               DELETE FROM pregunpolsegtab
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -- BUG10569:DRA:02/09/2009:Inici
               v_pasexec := 33;

               DELETE FROM saldodeutorseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -- BUG10569:DRA:02/09/2009:Fi

               -------- Garanties
               v_pasexec := 34;

               DELETE FROM comisigaranseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -- BUG11210:XPL:26/10/2009:Inici
               v_pasexec := 35;

               DELETE FROM detgaranseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -- BUG11210:XPL:26/10/2009:Fi
               v_pasexec := 36;

               --CONVENIOS
               IF NVL(mov_reg.cregul, 0) = 1
               THEN
                  FOR regregul IN (SELECT *
                                     FROM tramosregul
                                    WHERE sseguro = psseguro
                                      AND nmovimi = movi_ac)
                  LOOP
                     UPDATE garanseg
                        SET ffinefe = regregul.ffinorigar
                      WHERE sseguro = regregul.sseguro
                        AND nriesgo = regregul.nriesgo
                        AND cgarant = regregul.cgarant
                        AND nmovimi = regregul.nmovimiorg
                        AND finiefe = regregul.finiorigar;
                     --JRH Dejamos las versiones de garntía igual como estaban antes de la regularización
                  END LOOP;

                  DELETE tramosregul
                   WHERE sseguro = psseguro
                     AND nmovimi = movi_ac;
               END IF;

               --CONVENIOS
               DELETE FROM garanseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               vcount    := SQL%ROWCOUNT;
               v_pasexec := 37;

               --CONVENIOS
               DELETE aseguradosmes
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               --CONVENIOS
               IF mov_reg.cmovseg <> 6
               THEN
                  -- Bug: 36397/208377     CJMR      22/06/2015
                  SELECT MAX(nmovimi)
                    INTO movi_ant
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND ffinefe = mov_reg.fefecto
                        -- Hem d'agafar el darrer moviment que no sigui regularitzacio
                     AND nmovimi IN (SELECT nmovimi
                                       FROM movseguro
                                      WHERE sseguro = psseguro
                                        AND cmovseg <> 6
                                        AND cmovseg <> 52); -- No anulado

                  v_pasexec := 38;

                  IF vcount > 0
                  THEN
                     UPDATE garanseg
                        SET ffinefe = NULL
                      WHERE sseguro = psseguro
                        AND nmovimi = movi_ant
                        AND NVL(pac_parametros.f_pargaranpro_n(seg_reg.sproduc,
                                                               NVL(seg_reg.cactivi,
                                                                   0),
                                                               garanseg.cgarant,
                                                               'TIPO'),
                                0) NOT IN (4, 12);
                  END IF;
               END IF;

               ----------- reaseguro...
               -- BUG10462:ETM:16/06/2009:Inici
               -- DELETE FROM facpendientes
               --       WHERE sseguro = psseguro
               --         AND nmovimi = movi_ac;
               -- BUG10462:ETM:16/06/2009:Fi
               v_pasexec := 40;

               IF mov_reg.cmotmov IN (404, 406)
               THEN
                  SELECT MAX(fcontab)
                    INTO v_fcontab
                    FROM cesionesrea
                   WHERE sseguro = psseguro
                     AND nmovimi = movi_ac
                     AND cgenera = 5;

                  IF v_fcontab IS NULL
                  THEN
                     DELETE FROM cesionesrea
                      WHERE sseguro = psseguro
                        AND nmovimi = movi_ac
                        AND cgenera = 5;
                  ELSE
                     INSERT INTO cesionesrea
                        (scesrea, ncesion, icesion, icapces, sseguro,
                         nversio, scontra, ctramo, sfacult, nriesgo, icomisi,
                         icomreg, scumulo, cgarant, spleno, ccalif1, ccalif2,
                         fefecto, fvencim, pcesion, sproces, cgenera,
                         fgenera, nmovimi, ipritarrea, idtosel, psobreprima,
                         cdetces, fanulac, fregula, nmovigen, ipleno,
                         icapaci, iextrea)
                        (SELECT scesrea.nextval,
                                ncesion,
                                -icesion,
                                icapces,
                                sseguro,
                                nversio,
                                scontra,
                                ctramo,
                                sfacult,
                                nriesgo,
                                icomisi,
                                icomreg,
                                scumulo,
                                cgarant,
                                spleno,
                                ccalif1,
                                ccalif2,
                                fefecto,
                                fvencim,
                                pcesion,
                                sproces,
                                cgenera,
                                TRUNC(f_sysdate),
                                nmovimi,
                                ipritarrea,
                                idtosel,
                                psobreprima,
                                cdetces,
                                fanulac,
                                fregula,
                                nmovigen,
                                ipleno,
                                icapaci,
                                iextrea
                           FROM cesionesrea
                          WHERE sseguro = psseguro
                            AND nmovimi = movi_ac
                            AND cgenera = 5);
                  END IF;
               ELSE
                  DELETE FROM cesionesrea
                   WHERE sseguro = psseguro
                     AND nmovimi = movi_ac
                     AND cgenera = 4;

                  v_pasexec := 41;

                  UPDATE cesionesrea
                     SET fanulac = NULL
                   WHERE sseguro = psseguro
                     AND nmovimi IN (SELECT MAX(nmovimi)
                                       FROM cesionesrea
                                      WHERE sseguro = psseguro
                                        AND nmovimi < movi_ac)
                     AND cgenera <> 7;

                  v_pasexec := 42;

                  DELETE FROM cesionesrea
                   WHERE sseguro = psseguro
                     AND nmovimi IN (SELECT MAX(nmovimi)
                                       FROM cesionesrea
                                      WHERE sseguro = psseguro
                                        AND nmovimi < movi_ac)
                     AND cgenera = 7;
               END IF;

               --UNIT LINKED
               v_pasexec := 43;

               DELETE FROM segdisin2
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               IF mov_reg.cmovseg <> 6
               THEN
                  -- Bug: 36397/208377     CJMR      22/06/2015
                  v_pasexec := 44;

                  UPDATE segdisin2
                     SET ffin = NULL
                   WHERE sseguro = psseguro
                     AND nmovimi = movi_ant;
               END IF;

               v_pasexec := 45;

               DELETE FROM v_rescate
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               IF mov_reg.cmovseg <> 6
               THEN
                  -- Bug: 36397/208377     CJMR      22/06/2015
                  v_pasexec := 46;

                  UPDATE v_rescate
                     SET ffinefe = NULL
                   WHERE sseguro = psseguro
                     AND nmovimi = movi_ant;
               END IF;

               -------- Clàusules de beneficiari
               v_pasexec := 47;

               DELETE FROM claubenseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               v_pasexec := 48;

               DELETE FROM psucontrolseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               v_pasexec := 488;

               DELETE FROM psu_retenidas
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               /* SELECT MAX(nmovimi)
                                              INTO movi_ant
                FROM claubenseg
               WHERE sseguro = psseguro
                 AND ffinclau = mov_reg.fefecto
                 -- Hem d'agafar el darrer moviment que no sigui regularitzacio
                 AND nmovimi IN (SELECT nmovimi
                                   FROM movseguro
                                  WHERE sseguro = psseguro
                                    AND cmovseg <> 6);
                */
               v_pasexec := 49;

               UPDATE claubenseg
                  SET ffinclau = NULL
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM claubenseg
                                   WHERE sseguro = psseguro
                                     AND nmovimi < movi_ac);

               -------- Cláusulas con parámetros
               v_pasexec := 50;

               DELETE FROM clauparesp
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -------- Restauramos las direcciones anteriore
               /*  Lo quitamos
                                             num_err :=
                    pk_suplementos.f_recuperar_direcciones (psseguro, movi_ac);
               IF num_err <> 0
               THEN
                  RETURN num_err;
               END IF;
               num_err :=
                    pk_suplementos.f_borrar_supdirecciones (psseguro, movi_ac);
               IF num_err <> 0
               THEN
                  RETURN num_err;
               END IF;*/

               -------- Clàusules especials
               v_pasexec := 54;

               DELETE FROM clausuesp
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               /*SELECT MAX(nmovimi)
                                               INTO movi_ant
                 FROM clausuesp
                WHERE sseguro = psseguro
                  AND ffinclau = mov_reg.fefecto
                  -- Hem d'agafar el darrer moviment que no sigui regularitzacio
                  AND nmovimi IN (SELECT nmovimi
                                    FROM movseguro
                                  WHERE sseguro = psseguro
                                    AND cmovseg <> 6);
               */
               v_pasexec := 60;

               UPDATE clausuesp
                  SET ffinclau = NULL
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM clausuesp
                                   WHERE sseguro = psseguro
                                     AND nmovimi < movi_ac);

               -------- Tarjetes
               v_pasexec := 61;

               DELETE FROM tarjetas
                WHERE sseguro = psseguro
                  AND nmovima = movi_ac;

               v_pasexec := 62;

               UPDATE tarjetas
                  SET fbaja = NULL, nmovimb = NULL
                WHERE sseguro = psseguro
                  AND nmovimb = movi_ac;

               -- BUG10464:DRA:18/06/2009:Inici
               v_pasexec := 63;

               DELETE FROM claususeg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               UPDATE claususeg --JRH PRB
                  SET ffinclau = NULL
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM claususeg
                                   WHERE sseguro = psseguro
                                     AND nmovimi < movi_ac);

               -- BUG10464:DRA:18/06/2009:Fi

               -------- Riscos
               --  Afegim les taules d'AUTOS
               --Autos
               v_pasexec := 64;

               DELETE FROM autconductores
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               v_pasexec := 65;

               -- Bug 06/02/2013 - se añade la tabla autdisriesgos
               DELETE FROM autdisriesgos
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -- fin Bug 06/02/2013
               DELETE FROM autdetriesgos
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               v_pasexec := 66;

               DELETE FROM bf_bonfranseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               v_pasexec := 67;

               DELETE FROM autriesgos
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               -- Fin JDC
               v_pasexec := 68;

               DELETE FROM sitriesgo
                WHERE (sseguro, nriesgo) IN
                      (SELECT sseguro,
                              nriesgo
                         FROM riesgos
                        WHERE sseguro = psseguro
                          AND nmovima = movi_ac);

               -- ini Bug 0011936 - JMF - 23/04/2010
               v_pasexec := 69;

               DELETE detembarcriesgos
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               v_pasexec := 70;

               DELETE embarcriesgos
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               v_pasexec := 71;

               DELETE planrentasirreg
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               v_pasexec := 72;

               DELETE intertecseggar
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               v_pasexec := 73;

               DELETE campsalut
                WHERE sseguro = psseguro
                  AND nriesgo IN (SELECT nriesgo
                                    FROM riesgos
                                   WHERE sseguro = psseguro
                                     AND nmovima = movi_ac);

               -- fin Bug 0011936 - JMF - 23/04/2010
               v_pasexec := 74;

               -- Bug 18830 - APD - 20/06/2011
               -- se debe eliminar el motivo de la retencion
               DELETE FROM motretencion
                WHERE (sseguro, nriesgo) IN
                      (SELECT sseguro,
                              nriesgo
                         FROM riesgos
                        WHERE sseguro = psseguro
                          AND nmovima = movi_ac);

               -- Fin Bug 18830 - APD - 20/06/2011
               DELETE FROM riesgos
                WHERE sseguro = psseguro
                  AND nmovima = movi_ac;

               v_pasexec := 75;

               UPDATE riesgos
                  SET fanulac = NULL, nmovimb = NULL
                WHERE sseguro = psseguro
                  AND nmovimb = movi_ac;

               -- Borramos tablas de prestamos
               v_pasexec := 76;

               DELETE FROM prestamoseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               v_pasexec := 77;

               UPDATE prestamoseg
                  SET ffinprest = NULL
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM prestamoseg
                                   WHERE sseguro = psseguro
                                     AND nmovimi < movi_ac);

               v_pasexec := 78;

               DELETE FROM prestcuadroseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               v_pasexec := 79;

               UPDATE prestcuadroseg
                  SET ffincuaseg = NULL
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM prestcuadroseg
                                   WHERE sseguro = psseguro
                                     AND nmovimi < movi_ac);

               -------- Textos de movimientos
               v_pasexec := 80;

               DELETE FROM texmovseguro
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               IF mov_reg.cmovseg <> 6
               THEN
                  -- Bug: 36397/208377     CJMR      22/06/2015
                  v_pasexec := 82;

                  SELECT MAX(nmovimi)
                    INTO movi_ant
                    FROM texmovseguro
                   WHERE sseguro = psseguro
                     AND ffinefe = mov_reg.fefecto
                        -- Hem d'agafar el darrer moviment que no sigui regularitzacio
                     AND nmovimi IN (SELECT nmovimi
                                       FROM movseguro
                                      WHERE sseguro = psseguro
                                        AND cmovseg <> 6
                                        AND cmovseg <> 52); -- No anulado

                  v_pasexec := 84;

                  UPDATE texmovseguro
                     SET ffinefe = NULL
                   WHERE sseguro = psseguro
                     AND nmovimi = movi_ant;
               END IF;
               -------- Moviments
               -- Se recuperan los datos del seguro mediante la tabla historicoseguros.
               DECLARE
                  v_nmovimi NUMBER;
               BEGIN
                  v_pasexec := 90;

                  SELECT MAX(nmovimi)
                    INTO v_nmovimi
                    FROM movseguro
                   WHERE sseguro = psseguro
                     AND nmovimi < movi_ac
                     AND cmovseg <> 52
                     AND EXISTS
                   (SELECT 1
                            FROM historicoseguros
                           WHERE sseguro = psseguro
                             AND nmovimi = movseguro.nmovimi); -- no anulado

                  SELECT *
                    INTO regseguro
                    FROM historicoseguros
                   WHERE sseguro = psseguro
                     AND nmovimi = v_nmovimi;
                  --movi_ac - 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'pk_rechazo.movimiento.f_anulacion_suplemento',
                                 5,
                                 ' psseguro = ' || psseguro ||
                                 ' movi_ac = ' || movi_ac,
                                 NULL);
                     RETURN 151330;
               END;
               --- modificar SEGUROS_AHO amb la informació de HISTORICOSEGUROS
               v_pasexec := 91;

               UPDATE seguros_aho
                  SET ndurper = regseguro.ndurper
                WHERE sseguro = psseguro;

               IF mov_reg.cmotmov IN (261, 262, 263, 264, 940)
               THEN
                  -- BUG 27766 Pignoraciones
                  -- BUG 27766 Pignoraciones
                  v_cmotmov := mov_reg.cmotmov;

                  IF mov_reg.cmotmov = 940
                  THEN
                     BEGIN
                        SELECT cmotmov
                          INTO v_cmotmov
                          FROM detmovseguro
                         WHERE sseguro = psseguro
                           AND nmovimi = mov_reg.nmovimi;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN 101903; --seguro no econtrado
                     END;
                  END IF;

                  -- Fin BUG 27766
                  IF v_cmotmov IN (263, 264)
                  THEN
                     IF v_cmotmov = 263
                     THEN
                        motmovbloq := 261;
                     ELSE
                        motmovbloq := 262;
                     END IF;

                     -- Se busca el número de bloqueo del desbloqueo/despignoración.
                     BEGIN
                        v_pasexec := 92;

                        SELECT nbloqueo
                          INTO numbloq
                          FROM bloqueoseg
                         WHERE nmovimi = movi_ac
                           AND sseguro = psseguro
                           AND cmotmov = v_cmotmov;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN 108469;
                     END;

                     -- Se recupera la fecha de fin del bloqueo/pignoración perteneciente
                     -- al desbloqueo/despignoración actual.
                     BEGIN
                        v_pasexec := 93;

                        SELECT ffinal,
                               nmovimi
                          INTO ffinalbloq,
                               movimibloq
                          FROM bloqueoseg
                         WHERE nbloqueo = numbloq
                           AND sseguro = psseguro
                           AND cmotmov = motmovbloq;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN 108469;
                     END;

                     -- Si no es nula la fecha de fin, se modifica el desbloqueo/despignoración
                     -- actual asignando este valor a la fecha de inicio.
                     IF ffinalbloq IS NOT NULL
                     THEN
                        v_pasexec := 94;

                        UPDATE bloqueoseg
                           SET finicio = ffinalbloq,
                               nmovimi = movimibloq,
                               ttexto  = regseguro.ttexto
                         WHERE nmovimi = movi_ac
                           AND sseguro = psseguro
                           AND cmotmov = v_cmotmov;

                        v_pasexec := 95;

                        UPDATE bloqueoseg
                           SET ffinal = NULL
                         WHERE nmovimi = movimibloq
                           AND sseguro = psseguro
                           AND cmotmov = motmovbloq;
                     ELSE
                        v_pasexec := 96;

                        DELETE bloqueoseg
                         WHERE nmovimi = movi_ac
                           AND sseguro = psseguro;
                     END IF;
                  ELSE
                     v_pasexec := 97;

                     DELETE bloqueoseg
                      WHERE nmovimi = movi_ac
                        AND sseguro = psseguro;
                  END IF;
                  -------- Defunción.
               ELSIF mov_reg.cmotmov = 265
               THEN
                  v_pasexec := 100;

                  UPDATE asegurados
                     SET ffecfin = NULL, ffecmue = NULL
                   WHERE sseguro = psseguro
                     AND ffecfin IS NOT NULL;

                  v_pasexec := 102;
                  num_err   := pk_rentas.desanula_rec(mov_reg.fefecto,
                                                      psseguro);

                  IF num_err <> 0
                  THEN
                     RETURN num_err;
                  END IF;
               END IF;

               -- ini Bug 0011936 - JMF - 14/01/2010
               v_pasexec := 104;

               DELETE seg_cbancar
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               v_pasexec := 106;

               DELETE resulseg
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               v_pasexec := 108;

               DELETE garanseggas
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               v_pasexec := 110;

               DELETE garanseg_sbpri
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               v_pasexec := 112;

               DELETE intertecseg
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               v_pasexec := 114;

               DELETE evoluprovmatseg
                WHERE nmovimi = movi_ac
                  AND sseguro = psseguro;

               -- fin Bug 0011936 - JMF - 14/01/2010

               -------- Moviments
               -- Se modifica el seguro actual con los datos recuperados del histórico.
               v_pasexec := 120;

               --IF v_hay_anterior THEN
               UPDATE seguros
                  SET casegur  = regseguro.casegur,
                      cagente  = regseguro.cagente,
                      nsuplem  = regseguro.nsuplem,
                      fefecto  = regseguro.fefecto,
                      creafac  = regseguro.creafac,
                      ctarman  = regseguro.ctarman,
                      cobjase  = regseguro.cobjase,
                      ctipreb  = regseguro.ctipreb,
                      cactivi  = regseguro.cactivi,
                      ccobban  = regseguro.ccobban,
                      ctipcoa  = regseguro.ctipcoa,
                      ctiprea  = regseguro.ctiprea,
                      crecman  = regseguro.crecman,
                      creccob  = regseguro.creccob,
                      ctipcom  = regseguro.ctipcom,
                      fvencim  = regseguro.fvencim,
                      femisio  = regseguro.femisio,
                      fanulac  = regseguro.fanulac,
                      fcancel  = regseguro.fcancel,
                      csituac  = regseguro.csituac,
                      cbancar  = regseguro.cbancar,
                      ccartera = NULL,
                      ctipcol  = regseguro.ctipcol,
                      cduraci  = regseguro.cduraci,
                      nduraci  = regseguro.nduraci,
                      iprianu  = regseguro.iprianu,
                      cidioma  = regseguro.cidioma,
                      cforpag  = regseguro.cforpag,
                      pdtoord  = regseguro.pdtoord,
                      nrenova  = regseguro.nrenova,
                      crecfra  = regseguro.crecfra,
                      tasegur  = regseguro.tasegur,
                      creteni  = regseguro.creteni,
                      ndurcob  = regseguro.ndurcob,
                      sciacoa  = regseguro.sciacoa,
                      pparcoa  = regseguro.pparcoa,
                      npolcoa  = regseguro.npolcoa,
                      nsupcoa  = regseguro.nsupcoa,
                      tnatrie  = regseguro.tnatrie,
                      pdtocom  = regseguro.pdtocom,
                      prevali  = regseguro.prevali,
                      irevali  = regseguro.irevali,
                      ncuacoa  = regseguro.ncuacoa,
                      nedamed  = regseguro.nedamed,
                      crevali  = regseguro.crevali,
                      cempres  = regseguro.cempres,
                      cagrpro  = regseguro.cagrpro,
                      nsolici  = regseguro.nsolici,
                      -- Bug 0011936 - JMF - 14/01/2010
                      fcarant = NVL(regseguro.fcarant, fcarant),
                      fcarpro = NVL(regseguro.fcarpro, fcarpro),
                      fcaranu = NVL(regseguro.fcaranu, fcaranu),
                      nfracci = NVL(regseguro.nfracci, nfracci),
                      -- BUG 0020761 - 03/01/2012 - JMF
                      ncuotar = regseguro.ncuotar,
                      nanuali = regseguro.nanuali,
                      --Bug 0021924 -11/04/2012-- ETM--ini
                      ctipretr    = regseguro.ctipretr,
                      cindrevfran = regseguro.cindrevfran,
                      precarg     = regseguro.precarg,
                      pdtotec     = regseguro.pdtotec,
                      preccom     = regseguro.preccom,
                      --FIN -Bug 0021924 -11/04/2012-- ETM
                      frenova = regseguro.frenova,
                      ctipcob = regseguro.ctipcob,
                      fefeplazo = regseguro.fefeplazo,   -- IAXIS-3640  CJMR  17/01/2020
                      fvencplazo = regseguro.fvencplazo  -- IAXIS-3640  CJMR  17/01/2020
               -- BUG 0023117 - FAL - 26/07/2012
                WHERE sseguro = psseguro;

               IF pcmotmov = 403
               THEN
                  IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS',
                                                           seg_reg.sproduc) = 1
                  THEN
                     v_escertif0 := pac_seguros.f_get_escertifcero(NULL,
                                                                   psseguro);
                     vnumerr     := pac_preguntas.f_get_pregunpolseg(psseguro,
                                                                     4790,
                                                                     'SEG',
                                                                     v_crespue_4790);

                     IF v_escertif0 > 0 AND
                        (pac_seguros.f_es_col_admin(psseguro, 'POL') = 1 OR
                        (pac_seguros.f_es_col_agrup(psseguro, 'POL') = 1 AND
                        v_crespue_4790 = 2))
                     THEN
                        FOR regs IN (SELECT DISTINCT sseguro_cert,
                                                     nmovimi_cert
                                       FROM detrecmovsegurocol
                                      WHERE sseguro_0 = psseguro
                                        AND nmovimi_0 = movi_ac)
                        LOOP
                           SELECT DISTINCT sproces
                             INTO v_sproces
                             FROM detrecmovsegurocol
                            WHERE sseguro_0 = psseguro
                              AND nmovimi_0 = movi_ac
                              AND sseguro_cert = regs.sseguro_cert
                              AND nmovimi_cert = regs.nmovimi_cert;

                           SELECT MIN(fcarpro),
                                  MIN(fcarant),
                                  MIN(fcaranu),
                                  MIN(nfracci)
                             INTO v_fcarpro_cert,
                                  v_fcarant_cert,
                                  v_fcaranu_cert,
                                  v_nfracci_cert
                             FROM segcartera
                            WHERE sseguro = regs.sseguro_cert
                              AND sproces = v_sproces;

                           UPDATE seguros
                              SET fcarpro = v_fcarpro_cert,
                                  fcarant = v_fcarant_cert,
                                  fcaranu = v_fcaranu_cert,
                                  nfracci = v_nfracci_cert
                            WHERE sseguro = regs.sseguro_cert;
                        END LOOP;

                        --> UNA VEZ RECHAZADO! Borramos estos registros de DETRECMOVSEGUROCOL
                        -- Se deben borrar ya que si rechazamos una propuesta de cartera que no ha finalizado
                        -- Si dejamos los registros y y luego finalmente volvemos a pasar la cartera la agrupación
                        -- de recibos de cartera toma tambien esos registros que pertenecen a un movimiento rechazado
                        -- y acaba generado dos recibos (uno por movimiento, el rechazado y el posterior).
                        DELETE FROM detrecmovsegurocol
                         WHERE sseguro_0 = psseguro
                           AND nmovimi_0 = movi_ac;
                     END IF;
                  END IF;
               END IF;

               IF pcmotmov IN (404, 406)
               THEN
                  IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS',
                                                           seg_reg.sproduc) = 1
                  THEN
                     v_escertif0 := pac_seguros.f_get_escertifcero(NULL,
                                                                   psseguro);
                     vnumerr     := pac_preguntas.f_get_pregunpolseg(psseguro,
                                                                     4790,
                                                                     'SEG',
                                                                     v_crespue_4790);

                     IF v_escertif0 > 0 AND
                        (pac_seguros.f_es_col_admin(psseguro, 'POL') = 1 OR
                        (pac_seguros.f_es_col_agrup(psseguro, 'POL') = 1 AND
                        v_crespue_4790 = 2))
                     THEN
                        --> UNA VEZ RECHAZADO! Borramos estos registros de DETRECMOVSEGUROCOL
                        -- Se deben borrar ya que si rechazamos una propuesta de cartera que no ha finalizado
                        -- Si dejamos los registros y y luego finalmente volvemos a pasar la cartera la agrupación
                        -- de recibos de cartera toma tambien esos registros que pertenecen a un movimiento rechazado
                        -- y acaba generado dos recibos (uno por movimiento, el rechazado y el posterior).
                        DELETE FROM detrecmovsegurocol
                         WHERE sseguro_0 = psseguro
                           AND nmovimi_0 = movi_ac;
                     END IF;
                  END IF;
               END IF;

               -- Se borra de historicoseguros el registro creado
               -- por el suplemento.
               v_pasexec := 122;

               DELETE FROM historicoseguros
                WHERE sseguro = psseguro
                  AND nmovimi = regseguro.nmovimi;

               -- Bug 26485 --ECP-- 18/03/2013
               UPDATE benespseg
                  SET ffinben = NULL
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM benespseg
                                   WHERE sseguro = psseguro
                                     AND nmovimi < movi_ac);

               -- Bug 26485 --ECP-- 18/03/2013

               --- BFP bug 20672 12/04/2012 ini
               DELETE FROM benespseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               DELETE FROM anuage_corretaje
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               --bug 21657 --etm--04/06/2012
               DELETE FROM inquiaval
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               --fin bug 12657--etm--04/06/2012

               --INI BUG 34461: AFM 02/2015 CONVENIOS
               DELETE FROM cnv_conv_emp_seg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               --FIN BUG 34461: AFM 02/2015 CONVENIOS
               -- Ini IAXIS-5120 --ECP -- 26/08/2019
               --BUG24655: DCT: 30-11-2012 - INICIO Primero borrar la tabla coacedido y despues coacuadro
            /*   DELETE FROM coacedido
                WHERE sseguro = psseguro
                  AND ncuacoa = movi_ac;

               -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
               DELETE FROM coacuadro
                WHERE sseguro = psseguro
                  AND ncuacoa = movi_ac;*/
              -- Fin IAXIS-5120 -- ECP -- 26/08/2019
               -- Bug INI: 35095/199894 - 06/03/2015 - PRB
               DELETE FROM asegurados_innom
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               --BUG24655: DCT: 30-11-2012 - FIN Primero borrar la tabla coacedido y despues coacuadro

               --BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS
               DELETE FROM suspensionseg
                WHERE sseguro = psseguro
                  AND nmovimi = movi_ac;

               UPDATE suspensionseg
                  SET ffinal = NULL
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM suspensionseg
                                   WHERE sseguro = psseguro
                                     AND nmovimi < movi_ac);

               v_pasexec := 123;

               IF pnorec = 0
               THEN
                  IF pcmotmov = 391
                  THEN
                     num_err := pac_rehabilita.f_genrec(psseguro,
                                                        movi_ac,
                                                        v_nrecibo,
                                                        NULL,
                                                        1);

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;
                  END IF;
               END IF;

               --BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS

               -- Fin Bug 0023183

               --- BFP bug 20672 12/04/2012 fi
               BEGIN
                  IF paccion IN (3, 4)
                  THEN
                     v_pasexec := 124;

                     UPDATE movseguro
                        SET cmovseg = 52,
                            fanulac = f_sysdate,
                            fcontab = f_sysdate,
                            cusuanu = f_user
                      WHERE sseguro = psseguro
                        AND nmovimi = movi_ac;
                  ELSE
                     v_pasexec := 126;

                     DELETE movseguro
                      WHERE sseguro = psseguro
                        AND nmovimi = movi_ac;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     IF paccion IN (3, 4)
                     THEN
                        v_pasexec := 128;

                        UPDATE movseguro
                           SET cmovseg = 52,
                               fanulac = f_sysdate,
                               fcontab = f_sysdate,
                               cusuanu = f_user
                         WHERE sseguro = psseguro
                           AND nmovimi = movi_ac;
                     ELSE
                        v_pasexec := 130;

                        DELETE FROM detmovseguro
                         WHERE sseguro = psseguro
                           AND nmovimi = movi_ac;

                        v_pasexec := 132;

                        DELETE movseguro
                         WHERE sseguro = psseguro
                           AND nmovimi = movi_ac;
                     END IF;
               END;

               --------------------
               ---bfp ini bug 20672/0113114: LCOL_T001-LCOL - UAT - TEC: Suplementos
               FOR reg IN c_histomadores(movi_ac)
               LOOP
                  v_pasexec := 133;

                  -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - incluir campo cexistepagador

                  --UPDATE tomadores
                  --   SET nordtom = reg.nordtom,
                  --       cdomici = reg.cdomici,
                  --       cexistepagador = reg.cexistepagador
                  -- WHERE sseguro = reg.sseguro
                  --   AND sperson = reg.sperson;

                  --                  v_pasexec := 134;

                  --                  UPDATE notibajagar
                  --                     SET crehab = NULL,
                  --                         nmovrehab = NULL
                  --                   WHERE sseguro = reg.sseguro
                  --                     AND nmovrehab = movi_ac;

                  --                  v_pasexec := 135;

                  --                  DELETE FROM historicoriesgos
                  --                        WHERE sseguro = reg.sseguro
                  --                          AND sperson = reg.sperson
                  --                          AND nmovimi = reg.nmovimi;
                  v_cambiostomador := 1; -- BUG 0038051 - FAL - 13/10/2015
               END LOOP;

               -- BUG 0038051 - FAL - 13/10/2015
               IF v_cambiostomador = 1
               THEN
                  DELETE FROM tomadores WHERE sseguro = psseguro;

                  INSERT INTO tomadores
                     (sperson, sseguro, nordtom, cdomici, cexistepagador)
                     SELECT sperson,
                            sseguro,
                            nordtom,
                            cdomici,
                            cexistepagador
                       FROM histomadores
                      WHERE sseguro = psseguro
                        AND nmovimi = movi_ac;
               END IF;

               -- FI BUG 0038051
               FOR reg IN c_hisasegurados(movi_ac)
               LOOP
                  v_pasexec := 136;

                  UPDATE asegurados
                     SET --nriesgo = reg.nriesgo,
                         cdomici = reg.cdomici,
                         ffecini = reg.ffecini,
                         --BUG24505: DCT : 14/11/2012 - Añadir ffecini
                         ffecfin     = reg.ffecfin,
                         ffecmue     = reg.ffecmue,
                         fecretroact = reg.fecretroact,
                         cparen      = reg.cparen
                   WHERE sseguro = reg.sseguro
                     AND sperson = reg.sperson
                     AND norden = reg.norden;
                  --                  v_pasexec := 137;

               --                  UPDATE notibajagar
               --                     SET crehab = NULL,
               --                         nmovrehab = NULL
               --                   WHERE sseguro = reg.sseguro
               --                     AND nmovrehab = movi_ac;
               --                  v_pasexec := 138;

               --                  DELETE FROM historicoriesgos
               --                        WHERE sseguro = reg.sseguro
               --                          AND sperson = reg.sperson
               --                          AND nmovimi = reg.nmovimi;
               END LOOP;

               ---bfp fin bug 20672/0113114: LCOL_T001-LCOL - UAT - TEC: Suplementos

               -- BUG 26151 -  APD - 22/02/2013 -
               -- caso de los productos Agrupados en que se ha generado el suplemento en el certificado 0
               -- y el suplemento se debe propagar a sus n certificados, por lo que se ha quedado el
               -- suplemento programado en sus n certificados y no sera hasta que se pase cartera
               -- de renovacion cuando se ejecuten.
               -- Por lo que si se rechaza el suplemento del certificado 0, se debe eliminar la
               -- programacion del suplemento en sus n certificados para que no se ejecuten
               -- en la cartera de renovacion
               IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS',
                                                        seg_reg.sproduc) = 1 AND
                  seg_reg.ncertif = 0
               THEN
                  FOR reg IN (SELECT sp.sseguro,
                                     sp.cmotmov
                                FROM sup_diferidosseg sp
                               WHERE sp.sseguro IN
                                     (SELECT s.sseguro
                                        FROM seguros s
                                       WHERE s.npoliza IN
                                             (SELECT s2.npoliza
                                                FROM seguros s2
                                               WHERE s2.sseguro = psseguro))
                                 AND sp.nmovimi = pnmovimi
                                 AND EXISTS
                               (SELECT *
                                        FROM detmovseguro
                                       WHERE sseguro = psseguro
                                         AND nmovimi = pnmovimi
                                         AND NVL(cpropagasupl, 0) IN (1, 3)))
                  LOOP
                     DELETE FROM sup_acciones_dif
                      WHERE sseguro = reg.sseguro
                        AND cmotmov = reg.cmotmov;

                     DELETE FROM sup_diferidosseg
                      WHERE sseguro = reg.sseguro
                        AND cmotmov = reg.cmotmov;
                  END LOOP;
               END IF;
               -- fin BUG 26151 -  APD - 22/02/2013
            END IF;
         END IF;
      END IF;

      vnumerr := pac_propio.f_accion_post_rechazo(psseguro,
                                                  pcmotmov,
                                                  pnsuplem,
                                                  paccion,
                                                  pnmovimi,
                                                  pnorec);

      IF vnumerr <> 0
      THEN
         RETURN vnumerr;
      END IF;

      v_pasexec := 200;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     ' Error traspàs ' || v_param,
                     SQLERRM);
         RETURN 105419;
   END f_anulacion_suplemento;

   FUNCTION f_insert_anulacion(psseguro IN NUMBER,
                               pcmotmov IN NUMBER,
                               pnmovimi IN NUMBER DEFAULT NULL) RETURN NUMBER IS
      -- Bug 0011936 - JMF - 14/01/2010: Afegir movimient.
      -- ini Bug 0011936 - JMF - 14/01/2010: Modificada toda la función para añadir tablas anulaciones
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'seg=' || psseguro || ' mot=' || pcmotmov ||
                                 'pm=' || pnmovimi;
      v_object  VARCHAR2(200) := 'pk_rechazo_movimiento.f_insert_anulacion';
      n_return  NUMBER(8);
      e_salida EXCEPTION;
      -- fin Bug 0011936 - JMF - 14/01/2010: Modificada toda la función para añadir tablas anulaciones
      vnmovimi NUMBER;
   BEGIN
      v_pasexec := 1;

      IF pnmovimi IS NOT NULL
      THEN
         vnmovimi := pnmovimi;
      ELSE
         v_pasexec := 5;

         SELECT MAX(nmovimi)
           INTO vnmovimi
           FROM movseguro
          WHERE sseguro = psseguro
            AND cmovseg <> 52; -- No anulado
      END IF;

      v_param   := v_param || ' mov=' || vnmovimi;
      v_pasexec := 7;

      -- Hace lo mismo que F_ACT_HISSEG
      DECLARE
         xf1paren  DATE := NULL;
         xfcarult  DATE := NULL;
         xttexto   VARCHAR2(50);
         xndurper  NUMBER(6);
         xfrevisio DATE;
         xcgasges  NUMBER(3);
         xcgasred  NUMBER(3);
         xcmodinv  NUMBER(4);
         xfrevant  DATE;
      BEGIN
         BEGIN
            v_pasexec := 10;

            SELECT f1paren
              INTO xf1paren
              FROM seguros_ren
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xf1paren := NULL;
         END;

         BEGIN
            v_pasexec := 12;

            SELECT fcarult
              INTO xfcarult
              FROM seguros_assp
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xfcarult := NULL;
         END;

         BEGIN
            v_pasexec := 14;

            SELECT ttexto
              INTO xttexto
              FROM bloqueoseg
             WHERE sseguro = psseguro
               AND nmovimi = vnmovimi
               AND finicio = (SELECT MAX(finicio)
                                FROM bloqueoseg
                               WHERE sseguro = psseguro
                                 AND nmovimi = vnmovimi);
         EXCEPTION
            WHEN OTHERS THEN
               xttexto := NULL;
         END;

         BEGIN
            v_pasexec := 16;

            SELECT ndurper,
                   frevisio,
                   frevant
              INTO xndurper,
                   xfrevisio,
                   xfrevant
              FROM seguros_aho
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xndurper := NULL;
         END;

         BEGIN
            v_pasexec := 18;

            SELECT cgasges,
                   cgasred
              INTO xcgasges,
                   xcgasred
              FROM seguros_ulk
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xcgasges := NULL;
               xcgasred := NULL;
         END;

         BEGIN
            v_pasexec := 20;

            SELECT cmodinv
              INTO xcmodinv
              FROM seguros_ulk
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xcmodinv := NULL;
         END;

         v_pasexec := 22;

         -- BUG 0020761 - 03/01/2012 - JMF: ncuotar
         INSERT INTO anuseg
            (sseguro, nmovimi, fmovimi, casegur, cagente, nsuplem, fefecto,
             creafac, ctarman, cobjase, ctipreb, cactivi, ccobban, ctipcoa,
             ctiprea, crecman, creccob, ctipcom, fvencim, femisio, fanulac,
             fcancel, csituac, cbancar, ctipcol, fcarant, fcarpro, fcaranu,
             cduraci, nduraci, nanuali, iprianu, cidioma, nfracci, cforpag,
             pdtoord, nrenova, crecfra, tasegur, creteni, ndurcob, sciacoa,
             pparcoa, npolcoa, nsupcoa, tnatrie, pdtocom, prevali, irevali,
             ncuacoa, nedamed, crevali, cempres, cagrpro, nsolici, f1paren,
             fcarult, ttexto, ccompani, ndurper, frevisio, cgasges, cgasred,
             cmodinv, ctipban, ctipcob, sprodtar, frevant, ncuotar
              --Bug 0021924 -11/04/2012-- ETM--ini
            , ctipretr, cindrevfran, precarg, pdtotec, preccom, frenova) -- BUG 0023117 - FAL - 26/07/2012

         --FIN -Bug 0021924 -11/04/2012-- ETM
            (SELECT sseguro,
                    vnmovimi,
                    f_sysdate,
                    casegur,
                    cagente,
                    nsuplem,
                    fefecto,
                    creafac,
                    ctarman,
                    cobjase,
                    ctipreb,
                    cactivi,
                    ccobban,
                    ctipcoa,
                    ctiprea,
                    crecman,
                    creccob,
                    ctipcom,
                    fvencim,
                    femisio,
                    fanulac,
                    fcancel,
                    csituac,
                    cbancar,
                    ctipcol,
                    fcarant,
                    fcarpro,
                    fcaranu,
                    cduraci,
                    nduraci,
                    nanuali,
                    iprianu,
                    cidioma,
                    nfracci,
                    cforpag,
                    pdtoord,
                    nrenova,
                    crecfra,
                    tasegur,
                    creteni,
                    ndurcob,
                    sciacoa,
                    pparcoa,
                    npolcoa,
                    nsupcoa,
                    tnatrie,
                    pdtocom,
                    prevali,
                    irevali,
                    ncuacoa,
                    nedamed,
                    crevali,
                    cempres,
                    cagrpro,
                    nsolici,
                    xf1paren,
                    xfcarult,
                    xttexto,
                    ccompani,
                    xndurper,
                    xfrevisio,
                    xcgasges,
                    xcgasred,
                    xcmodinv,
                    ctipban,
                    ctipcob,
                    sprodtar,
                    xfrevant,
                    ncuotar
                    --Bug 0021924 -11/04/2012-- ETM--ini
                   ,
                    ctipretr,
                    cindrevfran,
                    precarg,
                    pdtotec,
                    preccom,
                    frenova
             -- BUG 0023117 - FAL - 26/07/2012
             --FIN -Bug 0021924 -11/04/2012-- ETM
               FROM seguros
              WHERE sseguro = psseguro);
      END;

      v_pasexec := 30;

      BEGIN
         -- Bug 0011936 - JMF - 14/01/2010: Me guardo la situación actual.
         INSERT INTO anuriesgos
            (sseguro, nriesgo, nmovimi, nmovima, fefecto, sperson, tnatrie,
             cdomici, nasegur,
             -- Ini Bug 21907 - MDS - 02/05/2012
             pdtocom, precarg, pdtotec, preccom
             -- Fin Bug 21907 - MDS - 02/05/2012
             )
            (SELECT sseguro,
                    nriesgo,
                    vnmovimi,
                    nmovima,
                    fefecto,
                    sperson,
                    tnatrie,
                    cdomici,
                    nasegur,
                    -- Ini Bug 21907 - MDS - 02/05/2012
                    pdtocom,
                    precarg,
                    pdtotec,
                    preccom
             -- Fin Bug 21907 - MDS - 02/05/2012
               FROM riesgos
              WHERE sseguro = psseguro);
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 103190; --No se puede anular el riesgo
            RAISE e_salida;
      END;

      v_pasexec := 32;

      INSERT INTO anucampsalut
         (sseguro, nriesgo, nempleado, iimport, fpag, faltarisc, fanularisc,
          anumovimi)
         SELECT sseguro,
                nriesgo,
                nempleado,
                iimport,
                fpag,
                faltarisc,
                fanularisc,
                vnmovimi
           FROM campsalut
          WHERE sseguro = psseguro;

      v_pasexec := 34;

      INSERT INTO anuintertecseggar
         (sseguro, nmovimi, cgarant, ctipo, nriesgo, fefemov, pinttec,
          ndesde, nhasta, ninntec)
         SELECT sseguro,
                nmovimi,
                cgarant,
                ctipo,
                nriesgo,
                fefemov,
                pinttec,
                ndesde,
                nhasta,
                ninntec
           FROM intertecseggar
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 36;

      INSERT INTO anuplanrentasirreg
         (sseguro, nriesgo, nmovimi, mes, anyo, importe, estado, srecren)
         SELECT sseguro,
                nriesgo,
                nmovimi,
                mes,
                anyo,
                importe,
                estado,
                srecren
           FROM planrentasirreg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 38;

      INSERT INTO anuseg_cbancar
         (sseguro, nmovimi, finiefe, ffinefe, cbancar, cbancob)
         SELECT sseguro,
                nmovimi,
                finiefe,
                ffinefe,
                cbancar,
                cbancob
           FROM seg_cbancar
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 40;

      INSERT INTO anuclausupara
         (sclagen, nparame, cformat, tparame, sseguro, nmovimi)
         SELECT sclagen,
                nparame,
                cformat,
                tparame,
                psseguro,
                vnmovimi
           FROM clausupara a
          WHERE EXISTS (SELECT 1
                   FROM clauparseg b
                  WHERE a.sclagen = b.sclagen
                    AND a.nparame = b.nparame
                    AND b.sseguro = psseguro);

      v_pasexec := 42;

      INSERT INTO anuclauparseg
         (sseguro, sclagen, nparame, tvalor, ctippar, nmovimi)
         SELECT sseguro,
                sclagen,
                nparame,
                tvalor,
                ctippar,
                vnmovimi
           FROM clauparseg
          WHERE sseguro = psseguro;

      v_pasexec := 44;

      INSERT INTO anuclaususeg
         (nmovimi, sseguro, sclagen, finiclau, ffinclau, timagen, nordcla)
         SELECT nmovimi,
                sseguro,
                sclagen,
                finiclau,
                ffinclau,
                timagen,
                nordcla
           FROM claususeg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 46;

      INSERT INTO anuclaubenseg
         (finiclau, sclaben, sseguro, nriesgo, nmovimi, ffinclau)
         SELECT finiclau,
                sclaben,
                sseguro,
                nriesgo,
                nmovimi,
                ffinclau
           FROM claubenseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 48;

      INSERT INTO anuclausuesp
         (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen,
          tclaesp, ffinclau, timagen)
         SELECT nmovimi,
                sseguro,
                cclaesp,
                nordcla,
                nriesgo,
                finiclau,
                sclagen,
                tclaesp,
                ffinclau,
                timagen
           FROM clausuesp
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 50;

      INSERT INTO anuclauparesp
         (sseguro, nriesgo, nmovimi, sclagen, nparame, cclaesp, nordcla,
          ctippar, tvalor)
         SELECT sseguro,
                nriesgo,
                nmovimi,
                sclagen,
                nparame,
                cclaesp,
                nordcla,
                ctippar,
                tvalor
           FROM clauparesp
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 52;

      INSERT INTO anuprestcuadroseg
         (ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg, fefecto,
          fvencim, icapital, iinteres, icappend, falta)
         SELECT ctapres,
                sseguro,
                nmovimi,
                finicuaseg,
                ffincuaseg,
                fefecto,
                fvencim,
                icapital,
                iinteres,
                icappend,
                falta
           FROM prestcuadroseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 54;

      INSERT INTO anuprestamoseg
         (ctapres, sseguro, nmovimi, finiprest, ffinprest, pporcen, nriesgo,
          ctipcuenta, ctipban, ctipimp, isaldo, porcen, ilimite, icapmax,
          icapital, cmoneda, icapaseg, falta, descripcion)
         SELECT ctapres,
                sseguro,
                nmovimi,
                finiprest,
                ffinprest,
                pporcen,
                nriesgo,
                ctipcuenta,
                ctipban,
                ctipimp,
                isaldo,
                porcen,
                ilimite,
                icapmax,
                icapital,
                cmoneda,
                icapaseg,
                falta,
                descripcion
           FROM prestamoseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 56;

      INSERT INTO anudetmovseguro
         (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora, tvalord,
          cpregun)
         SELECT sseguro,
                nmovimi,
                cmotmov,
                nriesgo,
                cgarant,
                tvalora,
                tvalord,
                cpregun
           FROM detmovseguro
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 58;

      INSERT INTO anuintertecseg
         (sseguro, fefemov, nmovimi, fmovdia, pinttec, ndesde, nhasta,
          ninntec)
         SELECT sseguro,
                fefemov,
                nmovimi,
                fmovdia,
                pinttec,
                ndesde,
                nhasta,
                ninntec
           FROM intertecseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 60;

      INSERT INTO anugaransegcom
         (sseguro, nriesgo, cgarant, nmovimi, finiefe, cmodcom, pcomisi)
         SELECT sseguro,
                nriesgo,
                cgarant,
                nmovimi,
                finiefe,
                cmodcom,
                pcomisi
           FROM garansegcom
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 61;

      INSERT INTO anugaranseggas
         (sseguro, nriesgo, cgarant, nmovimi, finiefe, cgastos, pvalor,
          pvalres, nprima, cmatch, tdesmat, pintfin)
         SELECT sseguro,
                nriesgo,
                cgarant,
                nmovimi,
                finiefe,
                cgastos,
                pvalor,
                pvalres,
                nprima,
                cmatch,
                tdesmat,
                pintfin
           FROM garanseggas
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 64;

      INSERT INTO anugaranseg_sbpri
         (sseguro, nriesgo, cgarant, nmovimi, finiefe, norden, ctipsbr,
          ccalsbr, pvalor, ncomisi)
         SELECT sseguro,
                nriesgo,
                cgarant,
                nmovimi,
                finiefe,
                norden,
                ctipsbr,
                ccalsbr,
                pvalor,
                ncomisi
           FROM garanseg_sbpri
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 66;

      INSERT INTO anupregungaranseg
         (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, nmovima,
          finiefe, trespue)
         SELECT sseguro,
                nriesgo,
                cgarant,
                nmovimi,
                cpregun,
                crespue,
                nmovima,
                finiefe,
                trespue
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      INSERT INTO anupregungaransegtab
         (sseguro, nriesgo, cgarant, nmovimi, cpregun, nmovima, finiefe,
          nlinea, ccolumna, tvalor, fvalor, nvalor)
         SELECT sseguro,
                nriesgo,
                cgarant,
                nmovimi,
                cpregun,
                nmovima,
                finiefe,
                nlinea,
                ccolumna,
                tvalor,
                fvalor,
                nvalor
           FROM pregungaransegtab
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 70;

      --convenios
      INSERT INTO anuaseguradosmes
         (sseguro, nriesgo, nmovimi, nmes, nanyo, fregul, naseg)
         SELECT sseguro,
                nriesgo,
                nmovimi,
                nmes,
                nanyo,
                fregul,
                naseg
           FROM aseguradosmes
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      --convenios

      --
      -- Insertamos en anugaranseg
      --
      BEGIN
         -- Bug 0011936 - JMF - 14/01/2010: Me llevo la situación actual.
         INSERT INTO anugaranseg
            (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
             ctarifa, icapital, precarg, iextrap, iprianu, ffinefe, cformul,
             ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
             irevali, itarifa, itarrea, ipritot, icaptot, pdtoint, idtoint,
             ftarifa, cderreg, feprev, fpprev, percre, ccampanya, nversio,
             crevalcar, cmatch, tdesmat, pintfin, cref, cintref, pdif,
             pinttec, nparben, nbns, tmgaran, cageven, nmovima, nlinea,
             nfactor, cmotmov, finider,
             -- Ini Bug 21907 - MDS - 02/05/2012
             pdtotec, preccom, idtotec, ireccom,
             -- Fin Bug 21907 - MDS - 02/05/2012
             finivig, ffinvig, ccobprima, ipridev
              -- BUG 41143/229973 - 17/03/2016 - JAEG
             )
            (SELECT cgarant,
                    nriesgo,
                    nmovimi,
                    sseguro,
                    finiefe,
                    norden,
                    crevali,
                    ctarifa,
                    icapital,
                    precarg,
                    iextrap,
                    iprianu,
                    ffinefe,
                    cformul,
                    ctipfra,
                    ifranqu,
                    irecarg,
                    ipritar,
                    pdtocom,
                    idtocom,
                    prevali,
                    irevali,
                    itarifa,
                    itarrea,
                    ipritot,
                    icaptot,
                    pdtoint,
                    idtoint,
                    ftarifa,
                    cderreg,
                    feprev,
                    fpprev,
                    percre,
                    ccampanya,
                    nversio,
                    crevalcar,
                    cmatch,
                    tdesmat,
                    pintfin,
                    cref,
                    cintref,
                    pdif,
                    pinttec,
                    nparben,
                    nbns,
                    tmgaran,
                    cageven,
                    nmovima,
                    nlinea,
                    nfactor,
                    cmotmov,
                    finider,
                    -- Ini Bug 21907 - MDS - 02/05/2012
                    pdtotec,
                    preccom,
                    idtotec,
                    ireccom,
                    -- Fin Bug 21907 - MDS - 02/05/2012
                    finivig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                    ffinvig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                    ccobprima, -- BUG 41143/229973 - 17/03/2016 - JAEG
                    ipridev    -- BUG 41143/229973 - 17/03/2016 - JAEG
               FROM garanseg
              WHERE sseguro = psseguro
                AND nmovimi = vnmovimi);
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 151372; --Error al anular las garantías
            RAISE e_salida;
      END;

      v_pasexec := 71;

      --convenios
      INSERT INTO anutramosregul
         (sseguro, nriesgo, nmovimi, cgarant, nmovimiorg, fecini, fecfin,
          ctipo, iprianuorg, iprianufin, icapitalorg, icapitalfin,
          iimprecibo, finiorigar)
         SELECT sseguro,
                nriesgo,
                nmovimi,
                cgarant,
                nmovimiorg,
                fecini,
                fecfin,
                ctipo,
                iprianuorg,
                iprianufin,
                icapitalorg,
                icapitalfin,
                iimprecibo,
                finiorigar
           FROM tramosregul
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      --convenios

      --Bug 24657 - XVM - 10/01/2013. Inicio
      INSERT INTO anudetprimas
         (sseguro, nriesgo, cgarant, nmovimi, finiefe, ccampo, cconcep,
          norden, iconcep, iconcep2)
         SELECT sseguro,
                nriesgo,
                cgarant,
                nmovimi,
                finiefe,
                ccampo,
                cconcep,
                norden,
                iconcep,
                iconcep2
           FROM detprimas
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      --Bug 24657 - XVM - 10/01/2013. Fin
      v_pasexec := 72;

      INSERT INTO anucomisigaranseg
         (sseguro, nriesgo, cgarant, nmovimi, finiefe, iprianu, pcomisi,
          icomanu, itotcom, ndetgar, ffinpg)
         SELECT sseguro,
                nriesgo,
                cgarant,
                nmovimi,
                finiefe,
                iprianu,
                pcomisi,
                icomanu,
                itotcom,
                ndetgar,
                ffinpg
           FROM comisigaranseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 74;

      INSERT INTO anuresulseg
         (clave, sseguro, nriesgo, nmovimi, cgarant, finiefe, nresult)
         SELECT clave,
                sseguro,
                nriesgo,
                nmovimi,
                cgarant,
                finiefe,
                nresult
           FROM resulseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 76;

      INSERT INTO anudetgaranseg
         (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar, fefecto,
          fvencim, ndurcob, ctarifa, pinttec, ftarifa, crevali, prevali,
          irevali, icapital, iprianu, precarg, irecarg, cparben, cprepost,
          ffincob, ipritar, provmat0, fprovmat0, provmat1, fprovmat1,
          pintmin, pdtocom, idtocom, ctarman, ipripur, ipriinv, itarrea,
          cagente, cunica)
         SELECT cgarant,
                nriesgo,
                nmovimi,
                sseguro,
                finiefe,
                ndetgar,
                fefecto,
                fvencim,
                ndurcob,
                ctarifa,
                pinttec,
                ftarifa,
                crevali,
                prevali,
                irevali,
                icapital,
                iprianu,
                precarg,
                irecarg,
                cparben,
                cprepost,
                ffincob,
                ipritar,
                provmat0,
                fprovmat0,
                provmat1,
                fprovmat1,
                pintmin,
                pdtocom,
                idtocom,
                ctarman,
                ipripur,
                ipriinv,
                itarrea,
                cagente,
                cunica
           FROM detgaranseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 78;

      INSERT INTO anupregunseg
         (sseguro, nriesgo, cpregun, crespue, nmovimi, trespue)
         SELECT sseguro,
                nriesgo,
                cpregun,
                crespue,
                nmovimi,
                trespue
           FROM pregunseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      INSERT INTO anupregunsegtab
         (sseguro, nriesgo, cpregun, nmovimi, nlinea, ccolumna, tvalor,
          fvalor, nvalor)
         SELECT sseguro,
                nriesgo,
                cpregun,
                nmovimi,
                nlinea,
                ccolumna,
                tvalor,
                fvalor,
                nvalor
           FROM pregunsegtab
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 80;

      INSERT INTO anusaldodeutorseg
         (sseguro, nmovimi, icapmax)
         SELECT sseguro,
                nmovimi,
                icapmax
           FROM saldodeutorseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 82;

      INSERT INTO anupregunpolseg
         (sseguro, cpregun, crespue, nmovimi, trespue)
         SELECT sseguro,
                cpregun,
                crespue,
                nmovimi,
                trespue
           FROM pregunpolseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      INSERT INTO anupregunpolsegtab
         (sseguro, cpregun, nmovimi, nlinea, ccolumna, tvalor, fvalor,
          nvalor)
         SELECT sseguro,
                cpregun,
                nmovimi,
                nlinea,
                ccolumna,
                tvalor,
                fvalor,
                nvalor
           FROM pregunpolsegtab
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 84;

      INSERT INTO anuevoluprovmatseg
         (sseguro, nmovimi, nanyo, fprovmat, iprovmat, icapfall, prescate,
          pinttec, iprovest, crevisio)
         SELECT sseguro,
                nmovimi,
                nanyo,
                fprovmat,
                iprovmat,
                icapfall,
                prescate,
                pinttec,
                iprovest,
                crevisio
           FROM evoluprovmatseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 86;

      INSERT INTO anuautriesgos
         (sseguro, nriesgo, nmovimi, cversion, ctipmat, cmatric, cuso,
          csubuso, fmatric, nkilometros, cvehnue, ivehicu, npma, ntara,
          ccolor, nbastid, nplazas, cgaraje, cusorem, cremolque)
         SELECT sseguro,
                nriesgo,
                nmovimi,
                cversion,
                ctipmat,
                cmatric,
                cuso,
                csubuso,
                fmatric,
                nkilometros,
                cvehnue,
                ivehicu,
                npma,
                ntara,
                ccolor,
                nbastid,
                nplazas,
                cgaraje,
                cusorem,
                cremolque
           FROM autriesgos
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 87;

      INSERT INTO anubf_bonfranseg
         (sseguro, nriesgo, cgrup, csubgrup, cnivel, cversion, nmovimi,
          finiefe, ctipgrup, cusualt, falta)
         SELECT sseguro,
                nriesgo,
                cgrup,
                csubgrup,
                cnivel,
                cversion,
                nmovimi,
                finiefe,
                ctipgrup,
                cusualt,
                falta
           FROM bf_bonfranseg
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 88;

      INSERT INTO anuautconductores
         (sseguro, nriesgo, nmovimi, norden, sperson, fnacimi, fcarnet,
          csexo, npuntos)
         SELECT sseguro,
                nriesgo,
                nmovimi,
                norden,
                sperson,
                fnacimi,
                fcarnet,
                csexo,
                npuntos
           FROM autconductores
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 90;

      INSERT INTO anumotretencion
         (sseguro, nriesgo, nmovimi, cmotret, cusuret, freten, nmotret,
          cestgest)
         SELECT sseguro,
                nriesgo,
                nmovimi,
                cmotret,
                cusuret,
                freten,
                nmotret,
                cestgest
           FROM motretencion
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 92;

      INSERT INTO anuautdetriesgos
         (sseguro, nriesgo, nmovimi, cversion, caccesorio, ctipacc, fini,
          ivalacc, tdesacc)
         SELECT sseguro,
                nriesgo,
                nmovimi,
                cversion,
                caccesorio,
                ctipacc,
                fini,
                ivalacc,
                tdesacc
           FROM autdetriesgos
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      -- Bug 25840 - APD - 06/02/2013 - se añade la tabla anuautdisriesgos
      v_pasexec := 93;

      INSERT INTO anuautdisriesgos
         (sseguro, nriesgo, nmovimi, cversion, cdispositivo, cpropdisp,
          ivaldisp, finicontrato, ffincontrato, ncontrato, tdescdisp)
         SELECT sseguro,
                nriesgo,
                nmovimi,
                cversion,
                cdispositivo,
                cpropdisp,
                ivaldisp,
                finicontrato,
                ffincontrato,
                ncontrato,
                tdescdisp
           FROM autdisriesgos
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      -- fin Bug 25840 - APD - 06/02/2013
      v_pasexec := 94;

      INSERT INTO anuembarcriesgos
         (nriesgo, sseguro, nmovimi, tmatric, tnombre, tpuerto, cpais,
          tmarca, ivalor, ireval, sbonush, czbonus, cznavega, nnifpat,
          nsupvel, npotmo1, npotmo2, cubicac, fmatric, cpropul, cpostal)
         SELECT nriesgo,
                sseguro,
                nmovimi,
                tmatric,
                tnombre,
                tpuerto,
                cpais,
                tmarca,
                ivalor,
                ireval,
                sbonush,
                czbonus,
                cznavega,
                nnifpat,
                nsupvel,
                npotmo1,
                npotmo2,
                cubicac,
                fmatric,
                cpropul,
                cpostal
           FROM embarcriesgos
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 96;

      INSERT INTO anudetembarcriesgos
         (nriesgo, sseguro, nmovimi, tdesacc, ivalacc, ireval)
         SELECT nriesgo,
                sseguro,
                nmovimi,
                tdesacc,
                ivalacc,
                ireval
           FROM detembarcriesgos
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi;

      v_pasexec := 98;

      INSERT INTO anuasegurados
         (sseguro, sperson, norden, cdomici, ffecini, ffecfin, ffecmue,
          nriesgo, nmovimi, fecretroact, cparen)
         SELECT sseguro,
                sperson,
                norden,
                cdomici,
                ffecini,
                ffecfin,
                ffecmue,
                nriesgo,
                vnmovimi,
                fecretroact,
                cparen
           FROM asegurados
          WHERE sseguro = psseguro;

      v_pasexec := 100;

      --
      --  Insertamos en ANUEXCLUSEG
      --
      BEGIN
         INSERT INTO anuexcluseg
            (sseguro, nriesgo, cgarant, nmovimi, finiefe, nmovima, cexclu,
             nduraci, cizqder, nproext)
            (SELECT sseguro,
                    nriesgo,
                    cgarant,
                    nmovimi,
                    finiefe,
                    nmovima,
                    cexclu,
                    nduraci,
                    cizqder,
                    nproext
               FROM excluseg
              WHERE sseguro = psseguro
                AND nmovimi = vnmovimi);
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 151373; -- Error al anular les exclusions
            RAISE e_salida;
      END;

      v_pasexec := 101;

      BEGIN
         INSERT INTO anupsucontrolseg
            (sseguro, nmovimi, fmovpsu, ccontrol, nriesgo, nocurre, cgarant,
             cnivelr, establoquea, ordenbloquea, autoriprev, nvalor,
             nvalorinf, nvalorsuper, nvalortope, cusumov, cnivelu, cautrec,
             autmanual, fautrec, cusuaur, observ)
            (SELECT p.sseguro,
                    p.nmovimi,
                    p.fmovpsu,
                    p.ccontrol,
                    p.nriesgo,
                    p.nocurre,
                    p.cgarant,
                    p.cnivelr,
                    p.establoquea,
                    p.ordenbloquea,
                    p.autoriprev,
                    p.nvalor,
                    p.nvalorinf,
                    p.nvalorsuper,
                    p.nvalortope,
                    p.cusumov,
                    p.cnivelu,
                    p.cautrec,
                    p.autmanual,
                    p.fautrec,
                    p.cusuaur,
                    p.observ
               FROM psucontrolseg p
              WHERE sseguro = psseguro
                AND nmovimi = vnmovimi);
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 1; -- Error al anular les exclusions
            RAISE e_salida;
      END;

      v_pasexec := 102;

      BEGIN
         INSERT INTO anupsu_retenidas
            (sseguro, nmovimi, fmovimi, cmotret, cnivelbpm, cusuret,
             ffecret, cusuaut, ffecaut, observ)
            (SELECT p.sseguro,
                    p.nmovimi,
                    p.fmovimi,
                    p.cmotret,
                    p.cnivelbpm,
                    p.cusuret,
                    p.ffecret,
                    p.cusuaut,
                    p.ffecaut,
                    p.observ
               FROM psu_retenidas p
              WHERE sseguro = psseguro
                AND nmovimi = vnmovimi);
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 1; -- Error al anular les exclusions
            RAISE e_salida;
      END;

      --- BFP Bug 20672 12/04/2012 ini
      v_pasexec := 103;

      BEGIN
         INSERT INTO anubenespseg
            (sseguro, nriesgo, cgarant, nmovimi, sperson, sperson_tit,
             finiben, ffinben, ctipben, cparen, pparticip, cusuari, fmovimi)
            SELECT sseguro,
                   nriesgo,
                   cgarant,
                   nmovimi,
                   sperson,
                   sperson_tit,
                   finiben,
                   ffinben,
                   ctipben,
                   cparen,
                   pparticip,
                   cusuari,
                   fmovimi
              FROM benespseg
             WHERE sseguro = psseguro
               AND nmovimi = vnmovimi;
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 1; -- Error al anular les exclusions
            RAISE e_salida;
      END;

      v_pasexec := 104;

      BEGIN
         INSERT INTO anuage_corretaje
            (sseguro, cagente, nmovimi, nordage, pcomisi, ppartici, islider)
            SELECT sseguro,
                   cagente,
                   nmovimi,
                   nordage,
                   pcomisi,
                   ppartici,
                   islider
              FROM anuage_corretaje
             WHERE sseguro = psseguro
               AND nmovimi = vnmovimi;
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 1; -- Error al anular les exclusions
            RAISE e_salida;
      END;

      --- BFP Bug 20672 12/04/2012 fi
      BEGIN
         v_pasexec := 110;

         INSERT INTO motanumov
            (sseguro, nmovimi, cmotmov, falta, cusualt)
         VALUES
            (psseguro, vnmovimi, pcmotmov, TRUNC(f_sysdate), f_user);
      EXCEPTION
         WHEN dup_val_on_index THEN
            BEGIN
               v_pasexec := 112;

               UPDATE motanumov
                  SET cmotmov = pcmotmov,
                      falta   = TRUNC(f_sysdate),
                      cusualt = f_user
                WHERE nmovimi = vnmovimi
                  AND sseguro = psseguro;
            END;
         WHEN OTHERS THEN
            n_return := 105419;
            RAISE e_salida;
      END;

      --bug 21657--etm--04/06/2012
      BEGIN
         v_pasexec := 113;

         INSERT INTO anuinquiaval
            (sseguro, sperson, nriesgo, nmovimi, ctipfig, cdomici, iingrmen,
             iingranual, ffecini, ffecfin, ctipcontrato, csitlaboral,
             csupfiltro)
            SELECT sseguro,
                   sperson,
                   nriesgo,
                   nmovimi,
                   ctipfig,
                   cdomici,
                   iingrmen,
                   iingranual,
                   ffecini,
                   ffecfin,
                   ctipcontrato,
                   csitlaboral,
                   csupfiltro
              FROM inquiaval
             WHERE sseguro = psseguro
               AND nmovimi = vnmovimi;
         /*AND NRIESGO=
         AND SPERSON=*/
      END;

      --FIN bug 21657--etm--04/06/2012

      -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
      BEGIN
         v_pasexec := 114;
       -- Ini IAXIS - 5120 -- ECP -- 26/08/2019
        /* INSERT INTO anucoacuadro
            (sseguro, ncuacoa, ploccoa, finicoa, fcuacoa, ffincoa, ccompan,
             npoliza)
            SELECT sseguro,
                   ncuacoa,
                   ploccoa,
                   finicoa,
                   fcuacoa,
                   ffincoa,
                   ccompan,
                   npoliza
              FROM coacuadro
             WHERE sseguro = psseguro
               AND ncuacoa = vnmovimi;*/
        -- Fin IAXIS - 5120 -- ECP -- 26/08/2019

         -- Bug INI: 35095/199894 - 06/03/2015 - PRB
         INSERT INTO anuasegurados_innom e
            (e.sseguro, e.nmovimi, e.nriesgo, e.norden, e.nif, e.nombre,
             e.apellidos, e.csexo, e.fnacim, e.falta, e.fbaja)
            SELECT i.sseguro,
                   i.nmovimi,
                   i.nriesgo,
                   i.norden,
                   i.nif,
                   i.nombre,
                   i.apellidos,
                   i.csexo,
                   i.fnacim,
                   i.falta,
                   i.fbaja
              FROM asegurados_innom i
             WHERE i.sseguro = psseguro
               AND i.nmovimi = vnmovimi;

         v_pasexec := 115;
-- Ini IAXIS - 5120 -- ECP -- 26/08/2019
      /*   INSERT INTO anucoacedido
            (sseguro, ncuacoa, ccompan, pcomcoa, pcomgas, pcomcon, pcescoa,
             pcesion)
            SELECT sseguro,
                   ncuacoa,
                   ccompan,
                   pcomcoa,
                   pcomgas,
                   pcomcon,
                   pcescoa,
                   pcesion
              FROM coacedido
             WHERE sseguro = psseguro
               AND ncuacoa = vnmovimi;*/
               -- Ini IAXIS - 5120 -- ECP -- 26/08/2019
      END;

      -- INI Bug 0034461 - AFM - 02/2015 - Producto convenios
      BEGIN
         v_pasexec := 117;

         INSERT INTO anucnv_conv_emp_seg
            (sseguro, nmovimi, idversion)
            SELECT sseguro,
                   nmovimi,
                   idversion
              FROM cnv_conv_emp_seg
             WHERE sseguro = psseguro
               AND nmovimi = vnmovimi;
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 1;
            RAISE e_salida;
      END;

      -- FIN Bug 0034461 - AFM - 02/2015 - Producto convenios

      -- Fin Bug 0023183
      v_pasexec := 120;

      --BUG:24450 - INICIO - DCT - 25/11/2013 - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS
      BEGIN
         INSERT INTO anususpensionseg
            (sseguro, finicio, ffinal, ttexto, cmotmov, nmovimi, fvigencia)
            SELECT sseguro,
                   finicio,
                   ffinal,
                   ttexto,
                   cmotmov,
                   nmovimi,
                   fvigencia
              FROM suspensionseg
             WHERE sseguro = psseguro
               AND nmovimi = vnmovimi;
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 1; -- Error al anular les  suspensions
            RAISE e_salida;
      END;

      v_pasexec := 121;

      --BUG:24450 - FIN - DCT - 25/11/2013 - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS
      BEGIN
         INSERT INTO anudetrecmovsegurocol
            (sseguro_0, nmovimi_0, sseguro_cert, nmovimi_cert, nrecibo,
             sproces)
            SELECT sseguro_0,
                   nmovimi_0,
                   sseguro_cert,
                   nmovimi_cert,
                   nrecibo,
                   sproces
              FROM detrecmovsegurocol
             WHERE sseguro_0 = psseguro
               AND nmovimi_0 = vnmovimi;
      EXCEPTION
         WHEN OTHERS THEN
            n_return := 1; -- Error al anular les  suspensions
            RAISE e_salida;
      END;

      v_pasexec := 122;
      RETURN 0;
   EXCEPTION
      WHEN e_salida THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     v_param,
                     SQLERRM);
         RETURN n_return;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     v_param,
                     SQLERRM);
         RETURN n_return;
   END f_insert_anulacion;

   --CONF-220 KJSC Genera un recibo de extorno como copia un recibo
   FUNCTION f_extorn_rec_pend(pnrecibo IN NUMBER, pctiprec IN NUMBER) RETURN NUMBER IS
      ssmovrec       NUMBER := 0;
      num_err        NUMBER;
      n_paso         NUMBER;
      v_nreciboclon  recibos.nrecibo%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_crespue_4092 pregunpolseg.crespue%TYPE;
      xcestrec       movrecibo.cestrec%TYPE;
      xfmovini       movrecibo.fmovini%TYPE;
      xsmovrec       movrecibo.smovrec%TYPE;
      vcestrec       NUMBER;
      vctiprecclon   NUMBER; -- IAXIS-4926 23/10/2019
   BEGIN
      n_paso  := 1;
      --
      -- Inicio IAXIS-4926 23/10/2019
      --
      -- Dependiendo del tipo de recibo a clonar se enviará de una vez el tipo del nuevo recibo
      -- Por convención de SAP:
      -- Un extorno (tipo 9) se clonará a uno suplemento (tipo 1)
      -- Un suplemento (tipo 1) se clonará a uno extorno (tipo 9)
      --
      SELECT DECODE(pctiprec, 13, 15, 9, 1, 15, 13, 9) 
        INTO vctiprecclon
        FROM DUAL;
      --  
      -- Fin IAXIS-4926 23/10/2019
      --
      n_paso  := 2;
         
      num_err := pac_adm.f_clonrecibo(1,
                                      pnrecibo,
                                      v_nreciboclon,
                                      ssmovrec,
                                      NULL,
                                      2,
                                      vctiprecclon, -- IAXIS-4926 23/10/2019
                                      8); -- IAXIS-7627 18/11/2019
      n_paso  := 3;
      
      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      SELECT MAX(smovrec)
        INTO xsmovrec
        FROM movrecibo
       WHERE nrecibo = v_nreciboclon;

      SELECT cestrec,
             fmovini
        INTO xcestrec,
             xfmovini
        FROM movrecibo
       WHERE smovrec = xsmovrec;

      num_err := f_insctacoas(v_nreciboclon,
                              xcestrec,
                              v_cempres,
                              xsmovrec,
                              TRUNC(xfmovini));

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      n_paso := 3;

      SELECT sseguro,
             cempres
        INTO v_sseguro,
             v_cempres
        FROM recibos
       WHERE nrecibo = pnrecibo;

      n_paso := 2;

      SELECT MAX(nmovimi)
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = v_sseguro;

      n_paso  := 5;
      num_err := pac_preguntas.f_get_pregunpolseg(v_sseguro,
                                                  4092,
                                                  'SEG',
                                                  v_crespue_4092);
      --
      -- Inicio IAXIS-4926 23/10/2019
      --
      -- Debido al funcionamiento del trigger TRG_INS_MOVCONTASAP el siguiente UPDATE no tendrá lugar pues se tiene el riesgo de enviar
      -- a contabilidad dos veces la información del recibo clonado.
      --
      /*IF v_crespue_4092 = 1 AND
         num_err = 0
      THEN
        UPDATE recibos r
           SET nmovimi    = v_nmovimi,
               ctiprec    = DECODE(ctiprec, 13, 15, 9, 1, 15, 13, 9),
               femisio    = f_sysdate
               csubtiprec = DECODE(ctiprec, 13, 15, 9, 1, 15, 13, 9)
         WHERE nrecibo    = v_nreciboclon;
      ELSE
         UPDATE recibos r
            SET nmovimi    = v_nmovimi,
                ctiprec    = DECODE(ctiprec, 13, 15, 9, 1, 15, 13, 9),
                cestaux    = 0,
                femisio    = f_sysdate
                csubtiprec = DECODE(ctiprec, 13, 15, 9, 1, 15, 13, 9)
          WHERE nrecibo = v_nreciboclon;
      END IF;
      --
      --
      n_paso := 6;
      --
      -- Se reemplaza la función pac_corretaje.f_reparto_corretaje por la sección de código en la función pac_adm.f_clonrecibo que 
      -- duplica los registros existentes en la tabla comrecibo.
      --
      /*
      IF pac_corretaje.f_tiene_corretaje(v_sseguro, NULL) = 1
      THEN
         n_paso  := 7;
         num_err := pac_corretaje.f_reparto_corretaje(v_sseguro,
                                                      v_nmovimi,
                                                      v_nreciboclon);

         IF num_err <> 0
         THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'pac_anulacion.f_extorn_rec_pend',
                        n_paso,
                        'pnrecibo:' || pnrecibo || ' v_sseguro:' ||
                        v_sseguro || ' v_nmovimi:' || v_nmovimi ||
                        ' v_nreciboclon:' || v_nreciboclon,
                        f_axis_literales(num_err, f_usu_idioma));
            RETURN num_err;
         END IF;
      END IF;*/
      --
      -- Fin IAXIS-4926 23/10/2019
      --
      IF v_crespue_4092 = 1 AND
         num_err = 0
      THEN
         NULL;
      ELSE
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'GESTIONA_COBPAG'),
                0) = 1 AND
            num_err = 0
         THEN
            n_paso  := 7; -- IAXIS-4926 23/10/2019
            num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(v_cempres,
                                                              v_sseguro,
                                                              v_nmovimi,
                                                              4,
                                                              NULL);
         END IF;
      END IF;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_anulacion.f_extorn_rec_pend',
                     n_paso,
                     'pnrecibo:' || pnrecibo,
                     SQLERRM);
         RETURN 140999; --{Error no controlat}
   END f_extorn_rec_pend;
    --INI SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
    -- Creamos funcion clon de la original donde se guarda el recibo clon 
    --
    -- Inicio IAXIS-4926 22/10/2019 
    --
    -- Se comenta la función para evitar confusiones acerca de la función de clonado vigente.
    --
    /*FUNCTION f_extorn_rec_pend_clon(pnrecibo IN NUMBER,
                                    pnrecibo_clon OUT NUMBER) RETURN NUMBER IS
      ssmovrec       NUMBER := 0;
      num_err        NUMBER;
      n_paso         NUMBER;
      v_nreciboclon  recibos.nrecibo%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_crespue_4092 pregunpolseg.crespue%TYPE;
      xcestrec       movrecibo.cestrec%TYPE;
      xfmovini       movrecibo.fmovini%TYPE;
      xsmovrec       movrecibo.smovrec%TYPE;

      vcestrec NUMBER;
      --INI SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados 
	  v_ctiprecclon recibos.ctiprec%TYPE;
	  v_csubtiprecclon recibos.csubtiprec%TYPE;
	  --
	  v_itotalr vdetrecibos.itotalr%TYPE;
	  --
	  v_femisio_clon recibos.femisio%TYPE;
	  v_sproduc seguros.sproduc%TYPE;
	  --
	  v_tasa NUMBER;
	  v_count_usd NUMBER(3) := 0;
	  v_count_eur NUMBER(3) := 0;
	  --FIN SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
   BEGIN
      n_paso  := 1;
      num_err := pac_adm.f_clonrecibo(1,
                                      pnrecibo,
                                      v_nreciboclon,
                                      ssmovrec,
                                      NULL,
                                      2);
      n_paso  := 2;

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      SELECT MAX(smovrec)
        INTO xsmovrec
        FROM movrecibo
       WHERE nrecibo = v_nreciboclon;

      SELECT cestrec,
             fmovini
        INTO xcestrec,
             xfmovini
        FROM movrecibo
       WHERE smovrec = xsmovrec;

      num_err := f_insctacoas(v_nreciboclon,
                              xcestrec,
                              v_cempres,
                              xsmovrec,
                              TRUNC(xfmovini));

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      n_paso := 3;

      SELECT sseguro,
             cempres
        INTO v_sseguro,
             v_cempres
        FROM recibos
       WHERE nrecibo = v_nreciboclon;

      n_paso := 4;

      SELECT MAX(nmovimi)
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = v_sseguro;

      n_paso  := 5;
      num_err := pac_preguntas.f_get_pregunpolseg(v_sseguro,
                                                  4092,
                                                  'SEG',
                                                  v_crespue_4092);

      IF v_crespue_4092 = 1 AND
         num_err = 0
      THEN
         UPDATE recibos r
            SET nmovimi    = v_nmovimi,
                ctiprec    = DECODE(ctiprec, 13, 15, 9, 1, 15, 13, 9),
                femisio    = f_sysdate,
                csubtiprec = DECODE(ctiprec, 13, 15, 9, 1, 15, 13, 9)
          WHERE nrecibo = v_nreciboclon;
      ELSE
         UPDATE recibos r
            SET nmovimi    = v_nmovimi,
                ctiprec    = DECODE(ctiprec, 13, 15, 9, 1, 15, 13, 9),
                cestaux    = 0,
                femisio    = f_sysdate,
                csubtiprec = DECODE(ctiprec, 13, 15, 9, 1, 15, 13, 9)
          WHERE nrecibo = v_nreciboclon;
      END IF;

      n_paso := 6;

      IF pac_corretaje.f_tiene_corretaje(v_sseguro, NULL) = 1
      THEN
         n_paso  := 7;
         num_err := pac_corretaje.f_reparto_corretaje(v_sseguro,
                                                      v_nmovimi,
                                                      v_nreciboclon);

         IF num_err <> 0
         THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'pac_anulacion.f_extorn_rec_pend',
                        n_paso,
                        'pnrecibo:' || pnrecibo || ' v_sseguro:' ||
                        v_sseguro || ' v_nmovimi:' || v_nmovimi ||
                        ' v_nreciboclon:' || v_nreciboclon,
                        f_axis_literales(num_err, f_usu_idioma));
            RETURN num_err;
         END IF;
      END IF;

      IF v_crespue_4092 = 1 AND
         num_err = 0
      THEN
         NULL;
      ELSE
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'GESTIONA_COBPAG'),
                0) = 1 AND
            num_err = 0
         THEN
            num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(v_cempres,
                                                              v_sseguro,
                                                              v_nmovimi,
                                                              4,
                                                              NULL);
         END IF;
      END IF;
      -- INI SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
      --  Hallamos valor de cobro  parcial del recibo base
	  --
	  SELECT ctiprec, csubtiprec, femisio
	    INTO  v_ctiprecclon, v_csubtiprecclon,
		      v_femisio_clon
	    FROM  recibos
	   WHERE  nrecibo = v_nreciboclon;
	  --
	  SELECT sproduc
	    INTO v_sproduc
	   FROM seguros
	   WHERE sseguro = v_sseguro;
	  --
	  -- Validamos si esta en moneda extranjera
	  SELECT COUNT(*)
	    INTO v_count_usd
	   FROM v_productos
	   WHERE sproduc = v_sproduc
         AND ttitulo LIKE '%Dolar%';
	  --
	   SELECT COUNT(*)
	    INTO v_count_eur
	   FROM v_productos
	   WHERE sproduc = v_sproduc
         AND ttitulo LIKE '%Euro%';
	  --
	  IF  v_count_usd > 0 THEN --producto en moneda dolar
	    --
	    BEGIN
		  --
		  SELECT itasa
		   INTO v_tasa
		  FROM eco_tipocambio
		   WHERE fcambio = TRUNC(v_femisio_clon)
		     AND cmonori = 'USD';
          --
		EXCEPTION WHEN OTHERS THEN
		  --
		  v_tasa := 1;
		  --
		END;
		--
	  ELSIF v_count_eur > 0 THEN -- Averiguar si es en euro
	    --
		BEGIN
		  --
		  SELECT itasa
		   INTO v_tasa
		  FROM eco_tipocambio
		   WHERE fcambio = TRUNC(v_femisio_clon)
		     AND cmonori = 'EUR';
          --
		EXCEPTION WHEN OTHERS THEN
		  --
		  v_tasa := 1;
		  --
		END;
		--
	  END IF;
	  --
	  SELECT itotalr
	     INTO v_itotalr
        FROM vdetrecibos
		 WHERE nrecibo = pnrecibo;
	  --
	  IF v_tasa > 1 THEN -- Moneda extranjera
	   --
	   v_itotalr := v_itotalr * v_tasa; -- Tasa del dia en que se anula movimiento
	   --
	  END IF;
	  --
	  IF v_ctiprecclon = 9 THEN
		--
		UPDATE vdetrecibos_monpol
          SET itotalr = (-1)*(v_itotalr)
        WHERE nrecibo = v_nreciboclon;
		--
	  ELSE 
	    UPDATE vdetrecibos_monpol
          SET itotalr = (v_itotalr)
        WHERE nrecibo = v_nreciboclon;
		--
	  END IF;
	  --
	  COMMIT;
	  --
	  pnrecibo_clon := v_nreciboclon;
      --
      -- FIN SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_anulacion.f_extorn_rec_pend',
                     n_paso,
                     'pnrecibo:' || pnrecibo,
                     SQLERRM);
         RETURN 140999; --{Error no controlat}
   END f_extorn_rec_pend_clon;*/
   --
   -- Fin IAXIS-4926 22/10/2019 
   --
   --FIN SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados 
   --INICIO 32009 - DCT - 11/07/2014.- Añadir parámetro poriduplic
   FUNCTION f_rechazo(psseguro   IN NUMBER,
                      pcmotmov   IN NUMBER,
                      pnsuplem   IN NUMBER,
                      paccion    IN NUMBER,
                      ptobserv   IN VARCHAR2,
                      pnmovimi   IN NUMBER DEFAULT NULL,
                      pnorec     IN NUMBER DEFAULT 0,
                      poriduplic IN NUMBER DEFAULT NULL) RETURN NUMBER IS
      -- Bug 0011936 - JMF - 14/01/2010: Afegir movimient.
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(200) := ' seg=' || psseguro || ' mot=' || pcmotmov ||
                                ' sup=' || pnsuplem || ' acc=' || paccion ||
                                ' mov=' || pnmovimi;
      vobject  VARCHAR2(200) := 'PK_RECHAZO_MOVIMIENTO.f_rechazo';

      CURSOR revision(pc_mov IN NUMBER) IS
         SELECT *
           FROM motretencion
          WHERE sseguro = psseguro
            AND nmovimi = pc_mov;

      reg_seg     seguros%ROWTYPE;
      num_err     NUMBER;
      c_cmotret   NUMBER;
      n_mov       NUMBER;
      vsproduc    NUMBER;
      vparampsu   NUMBER;
      vparamanula NUMBER;
      vaccion     NUMBER;
      vsituac     NUMBER;
      -- I - jlb - 23823
      vmens VARCHAR2(1000);
      -- F - jlb - 23823
      -- INI SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
    --
    -- Inicio IAXIS-4926 23/10/2019   
    --
    --v_nrecibo recibos.nrecibo%TYPE;
    --v_nrecibo_cl recibos.nrecibo%TYPE;
    viimporte_moncon NUMBER;
    viimporte         NUMBER;
    --
    -- Fin IAXIS-4926 23/10/2019
    -- 
    -- FIN SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
   BEGIN
      vpasexec := 1;

      BEGIN
         SELECT * INTO reg_seg FROM seguros WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903; --seguro no encontrado en la tabla SEGUROS
      END;

      IF reg_seg.csituac IN (4, 12, 14, 16)
      THEN
         --propuesta de alta, Proyecto Genérico, prepoliza, traspasada
         vpasexec    := 2;
         vparamanula := NVL(pac_parametros.f_parempresa_n(reg_seg.cempres,
                                                          'MOT_ANULA_PROP'),
                            0);

         --  edit detvalores where cvalor = 61 and cidioma = 1 and catribu = 17
         IF vparamanula = 1
         THEN
            num_err := f_anulacion_propuesta(psseguro,
                                             pcmotmov,
                                             paccion,
                                             poriduplic);

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;

            IF reg_seg.csituac = 4
            THEN
               vsituac := 7; --Anul·lació Propuesta de alta
            ELSIF reg_seg.csituac = 12
            THEN
               vsituac := 13; --Anul·lació Projecte Genèric
            ELSIF reg_seg.csituac = 14
            THEN
               vsituac := 15; --Anulació Prepòlissa
            ELSIF reg_seg.csituac = 16
            THEN
               vsituac := 13; --Anul·lació Projecte Genèric
            END IF;

            UPDATE seguros SET csituac = vsituac WHERE sseguro = psseguro;
         ELSE
            num_err := f_anulacion_propuesta(psseguro,
                                             pcmotmov,
                                             paccion,
                                             poriduplic);

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;
         END IF;

         --ini bug 32667:NSS:13/10/2014
         IF pac_parametros.f_parproducto_n(reg_seg.sproduc, 'HAYCTACLIENTE') = 1
         THEN
            num_err := pac_caja.f_anula_aportini(psseguro, reg_seg.sproduc);

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;
         END IF;
         --fin bug 32667:NSS:13/10/2014
      ELSE
         IF paccion IN (3, 4)
         THEN
            -- si es rechazo ó anulación del suplemento
            -- grabamos en las tablas de anulación
            vpasexec := 3;
            --CONF-220 KJSC Llama a la funcion que genera un recibo de extorno como copia un recibo
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                 'REC_COBRADO'),
                   0) = 1
            THEN
              FOR reg IN (SELECT nrecibo, ctiprec
                            FROM recibos a
                           WHERE sseguro = psseguro
                             AND nmovimi = pnmovimi
                             --
                             -- Inicio IAXIS-4926 23/10/2019 
                             --
                             -- Así esté en estado Pendiente, se debe crear el clon si tiene recaudos
                             -- AND f_cestrec(nrecibo, NULL) = 1
                             AND EXISTS (SELECT 1
                                           FROM detmovrecibo d
                                          WHERE d.nrecibo = a.nrecibo))
                             --             
                             -- Fin IAXIS-4926 23/10/2019 
                             --
              LOOP
                --
                -- Inicio IAXIS-4926 23/10/2019 
                --
                -- La razón por la que se verifica la suma es por la posibilidad de que exista un recibo cuyo total de recaudos
                -- hayan sido igualmente reversados. Si lo anterior se diera, se tendría como resultado un recibo en estado "Pendiente" 
                -- pero con valor "0" en recaudos (contando los realizados y los reversados) y por consiguiente, no se debería generar
                -- un clon.
                --              
                -- A la existencia de un valor recaudado se genera un recibo clon de tipo extorno o suplemento. Según sea el caso
                --
                IF (pac_adm_cobparcial.f_get_importe_cobro_parcial(reg.nrecibo) > 0) THEN
                  num_err := f_extorn_rec_pend(reg.nrecibo, reg.ctiprec);
                  IF num_err <> 0 THEN
                    RETURN num_err;
                  END IF;
                END IF;  
                --   
                -- Fin IAXIS-4926 23/10/2019 
                --
              END LOOP;
              --
            END IF;
            -- Bug 0011936 - JMF - 14/01/2010: Afegir movimient.
            num_err := f_insert_anulacion(psseguro, pcmotmov, pnmovimi);

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;
         END IF;
         --
         -- Anulamos el último suplemento.
         vpasexec := 4;
         -- Bug 0011936 - JMF - 14/01/2010: Afegir movimient.
         num_err := f_anulacion_suplemento(psseguro,
                                           pcmotmov,
                                           pnsuplem,
                                           paccion,
                                           pnmovimi,
                                           pnorec);

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;
      END IF;
      
      vpasexec := 5;

      IF paccion = 3
      THEN
         --{Rechazo}
         c_cmotret := 2; --{Rebutjada}
      ELSIF paccion = 4
      THEN
         --{Anulación}
         c_cmotret := 3; --{Anulada}
      END IF;

      /*
                                                      {Insertamos el registro de motretencion detalle conforme se ha anulado, para cada
      motivo asociado a la poliza}
      */
      vpasexec := 6;

      -- Bug 0011936 - JMF - 14/01/2010: Afegir movimient.
      IF pnmovimi IS NOT NULL
      THEN
         n_mov := pnmovimi;
      ELSE
         SELECT MAX(nmovimi)
           INTO n_mov
           FROM movseguro
          WHERE sseguro = psseguro
            AND cmovseg <> 52; -- No anulado
      END IF;

      SELECT sproduc INTO vsproduc FROM seguros WHERE sseguro = psseguro;

      vparampsu := pac_parametros.f_parproducto_n(vsproduc, 'PSU');

      IF NVL(vparampsu, 0) = 0
      THEN
         FOR c IN revision(n_mov)
         LOOP
            BEGIN
               vpasexec := 7;

               INSERT INTO motreten_rev
                  (nmotret, nmotrev, sseguro, nriesgo, nmovimi, cmotret,
                   cusuauto, fusuauto, cresulta, tobserva)
               VALUES
                  (c.nmotret,
                   pac_motretencion.f_max_nmotrev(c.sseguro,
                                                   c.nmovimi,
                                                   c.nriesgo,
                                                   c.cmotret,
                                                   c.nmotret) + 1, c.sseguro,
                   c.nriesgo, c.nmovimi, c.cmotret, f_user, f_sysdate,
                   c_cmotret, ptobserv);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 151720;
                  --{Error al insertar el detalle de retención}
            END;
         END LOOP;
      END IF;

      vpasexec := 8;
      -- I - jlb - 23823
      -- Llamo a las listas restringidas
      -- Accion: rechazo o anulación de propuesta
      num_err := pac_listarestringida.f_valida_listarestringida(psseguro,
                                                                n_mov,
                                                                NULL,
                                                                2,
                                                                NULL,
                                                                NULL,
                                                                NULL
                                                                -- Bug 31411/175020 - 16/05/2014 - AMC
                                                                );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      -- F - jlb - 23823
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobject,
                     vpasexec,
                     'Error no controlat ' || vparam,
                     SQLERRM);
         RETURN 140999; -- Error no controlat
   END;
END pk_rechazo_movimiento;

/