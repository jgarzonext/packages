--------------------------------------------------------
--  DDL for Package Body PAC_BLOQUEO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_BLOQUEO" AS
/******************************************************************************
   NOMBRE:    PAC_BLOQUEO
   PROP¿SITO: Funciones para el bloqueo/desbloqueo/pignoracion/despignoarcion de
              p¿lizas

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/05/2009   APD               1. Creaci¿n del package (Bug 9390)
   2.0        15/09/2009   ICV               2. 11164: CRE - No se visualiza la fecha de pignoraci¿n/despignoraci¿n cuando se realiza el suplemento.
   3.0        25/03/2010   DRA               3. 0013888: CEM800 - Augmentar precisi¿ dels camps TVALORA i TVALORD (DETMOVSEGURO, ESTDETMOVSEGURO)
   4.0        26/03/2010   DRA               4. 0013866: CEM800 - PPA debe permitir bloquear pero no pignorar
   5.0        25/05/2010   ICV               5. 0014620: CEM800 - Validaci¿n fecha en desbloqueo de p¿lizas
   6.0        25/05/2010   JRH               6. 0015607: CEM - Bloqueo de p¿lizas y fecha fin
   7.0        14/08/2015   YDA               7. 00211334: Se modifica la funci¿n f_get_bloqueos para incluir en el cursor la descripci¿n de la causa
   8.0        19/08/2015   YDA               8. 00211334: Se modifica la funci¿n f_set_mov para cambiar el formato de la situaci¿n antes y despues para pignoraci¿n
   9.0        20/01/2016   JCP               9. 0040011:Se modifica f_get_textdesbloq
******************************************************************************/

   /*************************************************************************
      Funcion que realiza la insercion de los movimientos bloqueo, desbloqueo,
      pignoracion y despignoracion de polizas
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfmovfin : fecha fin movimiento
      param in pttexto  : descripcion del movimiento de bloqueo/pignoracion
      param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
      param in pimporte : importe de pignoracion
      param in pcausa   : tipo de la causa
      return            : Error
   *************************************************************************/
   FUNCTION f_set_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfmovini IN DATE,
      pfmovfin IN DATE,
      pttexto IN VARCHAR2,
      pttexto2 IN VARCHAR2,
      pimporte IN NUMBER,
      psperson IN NUMBER,
      pcopcional IN NUMBER,
      pnrango IN NUMBER,
      pncolater IN NUMBER,
      pnmovimi IN NUMBER,
      pmodo IN VARCHAR2,
      pcausa IN NUMBER DEFAULT NULL,
      pbenefici OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_validamov    NUMBER;
      v_suplemento   movseguro.nsuplem%TYPE;
      v_siguiente_mov movseguro.nmovimi%TYPE;
      v_siguiente_mov2 movseguro.nmovimi%TYPE;
      v_motmovbloq   NUMBER;
      v_motmovdes    NUMBER;
      v_nriesgo      riesgos.nriesgo%TYPE;
      v_cmotmov      bloqueoseg.cmotmov%TYPE;
      v_nmovimi      bloqueoseg.nmovimi%TYPE;
      v_nbloqueo     bloqueoseg.nbloqueo%TYPE;
      v_motaux       NUMBER;
      v_ttexto       VARCHAR2(1000);
      v_ffinalaux    bloqueoseg.finicio%TYPE;
      v_desnmovimi   bloqueoseg.nmovimi%TYPE;
      v_numbloqueo   bloqueoseg.nbloqueo%TYPE;
      v_fecha_efecto DATE;
      v_situac_ant   VARCHAR2(1000);
      v_situac_ant_tmp VARCHAR2(1000);
      v_situac_act   VARCHAR2(1000);
      v_siguiente_mov_ant movseguro.nmovimi%TYPE;
      v_maxlenght    NUMBER := 1000;
      -- BUG13352:DRA:25/03/2010
      v_fmovimi      DATE;   --Bug.: 14620
      v_estapignorado NUMBER;   -- BUG: 27766
      v_numreg       NUMBER;   -- BUG: 27766
      v_sproduc      NUMBER;   -- BUG: 27766
      v_tperson      VARCHAR2(500);   -- BUG: 27766
      v_pignoracionmultiple NUMBER;   -- BUG: 27766
      v_vmensajebl   VARCHAR2(1000);
      v_ttipocausa   VARCHAR2(1000) := NULL;
      v_susppoliza   NUMBER;
      v_sperson      bloqueoseg.sperson%TYPE;
      v_nrango       bloqueoseg.nrango%TYPE;
   BEGIN
      -- Se valida si se puede realizar el movimiento de bloqueo/desbloqueo,
      -- pignoracion/despignoracion
      v_validamov := f_valida_mov(psseguro, pcmotmov, pfmovini, pfmovfin, pimporte, pmodo);

      IF NVL(pac_parametros.F_PAREMPRESA_N(pac_md_common.f_get_cxtempresa, 'VALIDA_LAPSE_PLEDGE'), 1) = 1 THEN
        v_susppoliza := pac_seguros.f_suspendida(psseguro, f_sysdate);

        IF v_susppoliza = 1 THEN
            RETURN 9908457;
        END IF;
      END IF;

      -- Si se puede realizar el movimiento
      IF v_validamov = 0 THEN
         -- BUG: 27766
         SELECT seg.sproduc
           INTO v_sproduc
           FROM seguros seg
          WHERE seg.sseguro = psseguro;

         v_pignoracionmultiple := NVL(f_parproductos_v(v_sproduc, 'CPIGNOMULT'), 0);

         -- Fin BUG: 27766

         -- Se busca el ultimo suplemento de la poliza
         BEGIN
            SELECT nsuplem
              INTO v_suplemento
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM movseguro
                               WHERE sseguro = psseguro);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 112158;   -- P¿liza no encontrada en la tabla MOVSEGURO
         END;

         --Ini Bug.: 0014620 - 25/05/2010 - ICV
         IF pcmotmov IN(261, 262) THEN   --261 Pignoraci¿n o 262 Bloqueo
            v_fmovimi := pfmovini;

            BEGIN
               SELECT COUNT(*)   --29822/213785
                 INTO pbenefici
                 FROM benespseg
                WHERE sseguro = psseguro
                  AND ffinben IS NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  pbenefici := 0;   -- P¿liza no tiene beneficiarios
            END;
         ELSE
            -- 263: Bloqueo. 264: Despignoraci¿n o Desbloqueo.
            v_fmovimi := pfmovfin;
         END IF;

         -- BUG: 27766
         v_cmotmov := pcmotmov;

         IF v_pignoracionmultiple = 2
            AND pmodo IS NOT NULL THEN
            v_cmotmov := 940;

            IF pmodo = 'ALTA_BENEF' THEN
               -- Poliza que nunca ha sido pignorada
               SELECT COUNT(*)
                 INTO v_estapignorado
                 FROM bloqueoseg
                WHERE sseguro = psseguro
                  AND cmotmov = 261;

               IF v_estapignorado = 0 THEN
                  v_cmotmov := 261;
               END IF;
            END IF;

            IF pmodo = 'ELIMINAR_BENEF' THEN
               -- En caso que sea el zltimo beneficiario
               SELECT COUNT(*)
                 INTO v_numreg
                 FROM bloqueoseg
                WHERE sseguro = psseguro
                  AND cmotmov = 261
                  AND ffinal IS NULL;

               IF v_numreg = 1 THEN
                  v_cmotmov := 263;
               END IF;
            END IF;
         --
         END IF;

         -- Fin BUG: 27766

         -- Se genera el nuevo movimiento
         num_err := f_movseguro(psseguro, NULL, pcmotmov, 1, v_fmovimi, NULL, v_suplemento, 0,
                                NULL, v_siguiente_mov, f_sysdate, NULL);

         -- BUG: 27766
         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         v_cmotmov := pcmotmov;

         --Recuperem el mov- anterior
         BEGIN
            SELECT tvalord
              INTO v_situac_ant_tmp
              FROM detmovseguro
             WHERE sseguro = psseguro
               AND nmovimi IN(SELECT MAX(nmovimi)
                                FROM bloqueoseg
                               WHERE sseguro = psseguro
                                 AND cmotmov IN(261, 263));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_situac_ant_tmp := NULL;
         END;

         IF pcausa IS NOT NULL THEN
            v_ttipocausa := ff_desvalorfijo(8000958, pac_md_common.f_get_cxtidioma, pcausa);
         END IF;

         IF v_pignoracionmultiple = 2 THEN
            -- Si el producto tiene Pignoracisn multiple.
            v_tperson := NVL(f_nombre(psperson, 1, NULL), ' ');
            v_ttexto := NVL(pttexto, ' ');

            IF pmodo = 'ALTA_BENEF' THEN
               v_cmotmov := 261;
               --Aqadir beneficiario
               v_situac_act := SUBSTR(f_axis_literales(9904351, pac_md_common.f_get_cxtidioma)
                                      || ' ' || pimporte || ' '
                                      || f_axis_literales(9001911,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ' || v_tperson || ' '
                                      || f_axis_literales(100566,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ' || v_ttexto || ' '
                                      || f_axis_literales(9000526,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ',
                                      1, v_maxlenght);
               v_situac_ant := v_situac_ant_tmp;
            ELSIF pmodo = 'ELIMINAR_BENEF' THEN
               v_cmotmov := 263;
               --Eliminar beneficiario.
               v_situac_ant := v_situac_ant_tmp;
               v_situac_act := SUBSTR(f_axis_literales(9904351, pac_md_common.f_get_cxtidioma)
                                      || ' ' || pimporte || ' '
                                      || f_axis_literales(9001911,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ' || v_tperson || ' '
                                      || f_axis_literales(100566,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ' || NVL(pttexto2, ' ') || ' '
                                      || f_axis_literales(9000526,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ',
                                      1, v_maxlenght);
            ELSE
               IF v_cmotmov = 261 THEN
                  IF pimporte IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(f_axis_literales(9904351, pac_md_common.f_get_cxtidioma)
                               || ': ' || pimporte,
                               1, v_maxlenght);
                  END IF;

                  IF v_tperson IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(9001911, pac_md_common.f_get_cxtidioma)
                               || ': ' || v_tperson,
                               1, v_maxlenght);
                  END IF;

                  IF v_ttexto IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(100566, pac_md_common.f_get_cxtidioma)
                               || ': ' || v_ttexto,
                               1, v_maxlenght);
                  END IF;

                  IF pfmovini IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(9000526, pac_md_common.f_get_cxtidioma)
                               || ': ' || TO_DATE(pfmovini, 'dd/mm/rrrr'),
                               1, v_maxlenght);
                  END IF;

                  IF v_ttipocausa IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(9908387, pac_md_common.f_get_cxtidioma)
                               || ': ' || v_ttipocausa,
                               1, v_maxlenght);
                  END IF;

                  v_situac_ant := v_situac_ant_tmp;
               ELSIF v_cmotmov = 262 THEN
                  v_situac_act := SUBSTR(f_axis_literales(100566,
                                                          pac_md_common.f_get_cxtidioma)
                                         || ' ' || v_ttexto || ' '
                                         || f_axis_literales(9000526,
                                                             pac_md_common.f_get_cxtidioma)
                                         || ' ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ',
                                         1, v_maxlenght);
                  v_situac_ant := NULL;
               ELSIF v_cmotmov = 263 THEN
                  v_situac_ant := v_situac_ant_tmp;

                  IF pimporte IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(f_axis_literales(9904351, pac_md_common.f_get_cxtidioma)
                               || ': ' || pimporte,
                               1, v_maxlenght);
                  END IF;

                  IF v_tperson IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(9001911, pac_md_common.f_get_cxtidioma)
                               || ': ' || v_tperson,
                               1, v_maxlenght);
                  END IF;

                  IF v_ttexto IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(100566, pac_md_common.f_get_cxtidioma)
                               || ': ' || pttexto2,
                               1, v_maxlenght);
                  END IF;

                  IF v_ttipocausa IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(9908387, pac_md_common.f_get_cxtidioma)
                               || ': ' || v_ttipocausa,
                               1, v_maxlenght);
                  END IF;
               ELSIF v_cmotmov = 264 THEN
                  IF pttexto IS NULL THEN
                     SELECT tvalord
                       INTO v_ttexto
                       FROM detmovseguro d
                      WHERE sseguro = psseguro
                        AND cmotmov = 262
                        AND EXISTS(SELECT *
                                     FROM bloqueoseg s
                                    WHERE s.sseguro = d.sseguro
                                      AND s.cmotmov = d.cmotmov
                                      AND ffinal IS NULL);
                  END IF;

                  v_situac_ant := SUBSTR(v_situac_ant
                                         || f_axis_literales(100566,
                                                             pac_md_common.f_get_cxtidioma)
                                         || ' ' || v_ttexto || ' '
                                         || f_axis_literales(9000526,
                                                             pac_md_common.f_get_cxtidioma)
                                         || ' ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ',
                                         1, v_maxlenght);
                  v_situac_act := SUBSTR(v_situac_ant
                                         || f_axis_literales(100566,
                                                             pac_md_common.f_get_cxtidioma)
                                         || ' ' || NVL(pttexto2, ' ') || ' ',
                                         1, v_maxlenght);
               END IF;
            END IF;

            --
            num_err := f_detmovseguro(psseguro, v_siguiente_mov, v_cmotmov, v_situac_ant,
                                      v_situac_act);
         --
         END IF;

         -- Fin BUG: 27766

         --Fin Bug.: 14620
         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         -- Se llama a f_act_hisseg para guardar la situaci¿n anterior al suplemento.
         -- El nmovimi es el anterior al del suplemento, por eso se le resta uno al reci¿n creado.
         num_err := f_act_hisseg(psseguro, v_siguiente_mov - 1);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         -- 261: Pignoraci¿n. 263: Despignoraci¿n.
         IF pcmotmov IN(261, 263) THEN
            v_motmovbloq := 261;
            v_motmovdes := 263;
         ELSE
            -- 262: Bloqueo. 264: Desbloqueo.
            v_motmovbloq := 262;
            v_motmovdes := 264;
         END IF;

         -- Motivo: despignoraci¿n (263) o desbloqueo (264).
         IF pcmotmov IN(263, 264) THEN
            BEGIN
               SELECT cmotmov, nmovimi, nbloqueo, sperson, nrango
                 INTO v_cmotmov, v_nmovimi, v_nbloqueo, v_sperson, v_nrango
                 FROM bloqueoseg
                WHERE sseguro = psseguro
                  AND cmotmov = v_motmovbloq
                  AND nmovimi = pnmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  v_cmotmov := NULL;
                  v_nmovimi := NULL;
                  v_nbloqueo := NULL;
                  v_sperson := NULL;
                  v_nrango := NULL;
            END;
         -- Motivo: pignoraci¿n (261) o bloqueo (262).
         ELSE
            BEGIN
               SELECT cmotmov, nmovimi, nbloqueo
                 INTO v_cmotmov, v_nmovimi, v_nbloqueo
                 FROM bloqueoseg
                WHERE sseguro = psseguro
                  AND cmotmov = v_motmovdes
                  AND nmovimi = pnmovimi;   -- BUG 27766
            EXCEPTION
               WHEN OTHERS THEN
                  v_cmotmov := NULL;
                  v_nmovimi := NULL;
                  v_nbloqueo := NULL;
            END;
         END IF;

         IF pfmovfin IS NOT NULL
            AND pcmotmov IN(262, 261) THEN   -- Motivo: pignoraci¿n (261) o bloqueo (262).
            IF pcmotmov = 261 THEN
               v_motaux := 263;
            ELSE
               v_motaux := 264;
            END IF;

            v_siguiente_mov2 := v_siguiente_mov;
            v_ttexto := SUBSTR(pttexto, 1, v_maxlenght);
                                                    -- BUG13888:DRA:25/03/2010
         -- APD - 20/05/2009 - el comentario se deja para saber la funcionalidad que habia antes
         -- Si se hace un desbloqueo modificando la fecha de fin, se debe eliminar el
         -- registro de desbloqueo anterior.
         -- Si se borra un desbloqueo porque se inserta otro con otra fecha, la fecha
         -- del desbloqueo original se graba en la fecha de fin del bloqueo para poder
         -- recuperarla.
         -- APD - 20/05/2009 - actualmente:
         -- Si se hace un desbloqueo modificando la fecha de fin, se debe eliminar el
         -- registro de desbloqueo anterior.
         -- Si se borra un desbloqueo porque se inserta otro con otra fecha, la fecha
         -- del desbloqueo actual se graba en la fecha de fin del bloqueo
         ELSIF pfmovfin IS NOT NULL
               AND pcmotmov IN(263, 264) THEN   -- Motivo: despignoraci¿n (263) o desbloqueo (264).
            v_ttexto := SUBSTR(pttexto2, 1, v_maxlenght);

            -- BUG13888:DRA:25/03/2010
            BEGIN
               SELECT a.finicio, a.nmovimi
                 -- recuperar fecha inicio y movimiento del ultimo desbloqueo/despignoraci¿n
               INTO   v_ffinalaux, v_desnmovimi
                 FROM bloqueoseg a
                WHERE a.sseguro = psseguro
                  AND a.cmotmov = pcmotmov
                  AND a.nbloqueo = v_nbloqueo
                  AND a.finicio = (SELECT MIN(b.finicio)
                                     FROM bloqueoseg b
                                    WHERE b.sseguro = psseguro
                                      AND b.cmotmov = pcmotmov
                                      AND b.nbloqueo = a.nbloqueo);

               IF v_pignoracionmultiple IS NULL
                  OR v_pignoracionmultiple <> 2 THEN
                  DELETE FROM bloqueoseg
                        WHERE sseguro = psseguro
                          AND cmotmov = pcmotmov
                          AND nmovimi = v_desnmovimi;
               END IF;

               UPDATE bloqueoseg
                  SET ffinal = pfmovfin   --v_ffinalaux
                WHERE sseguro = psseguro
                  AND cmotmov = v_cmotmov
                  AND nmovimi = pnmovimi;   -- BUG 27766
            EXCEPTION
               WHEN OTHERS THEN
                  -- si es el primer desbloqueo/pignoracion que se realiza se debe actualizar
                  -- la fecha fin del movimiento de bloqueo/pignoracion
                  UPDATE bloqueoseg
                     SET ffinal = pfmovfin
                   WHERE sseguro = psseguro
                     AND cmotmov = v_cmotmov
                     AND nmovimi = pnmovimi;   -- BUG 27766
            END;
         ELSE
            v_ttexto := SUBSTR(pttexto, 1, v_maxlenght);
         -- BUG13888:DRA:25/03/2010
         END IF;

         -- Se busca el identificador del bloqueo.
         IF pcmotmov IN(261, 262) THEN
            SELECT NVL(MAX(nbloqueo), 0) + 1
              INTO v_numbloqueo
              FROM bloqueoseg
             WHERE sseguro = psseguro;
         ELSE
            v_numbloqueo := v_nbloqueo;
         END IF;

         BEGIN
            SELECT DECODE(pcmotmov,
                          261, pfmovini,
                          262, pfmovini,
                          263, pfmovfin,
                          264, pfmovfin)
              INTO v_fecha_efecto
              FROM DUAL;
         END;

         -- recuperar riesgo de la poliza
         BEGIN
            SELECT nriesgo
              INTO v_nriesgo
              FROM riesgos
             WHERE sseguro = psseguro
               AND fanulac IS NULL
               AND nriesgo = (SELECT MIN(nriesgo)
                                FROM riesgos
                               WHERE sseguro = psseguro
                                 AND fanulac IS NULL);
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT nriesgo
                    INTO v_nriesgo
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = (SELECT MIN(nriesgo)
                                      FROM riesgos
                                     WHERE sseguro = psseguro);
               EXCEPTION
                  WHEN OTHERS THEN
                     v_nriesgo := 0;
               END;
         END;

         IF pcmotmov = 261 THEN   -- pignoraci¿n
            --Bug.: 11164 - 15/09/2009 - ICV - No se visualiza la fecha de pignoraci¿n/despignoraci¿n cuando se realiza el suplemento.
            --'P¿liza pignorada.
            v_situac_act := SUBSTR(f_axis_literales(152211, pac_md_common.f_get_cxtidioma)
                                   || '.',
                                   1, v_maxlenght);

            IF pfmovfin IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act || ' // '
                                      || f_axis_literales(9001993,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' - '
                                      || TO_DATE(pfmovfin, 'dd/mm/rrrr') || ' ) ',
                                      1, v_maxlenght);
            ELSE
               v_situac_act := SUBSTR(v_situac_act || ' // '
                                      || f_axis_literales(9000526,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ) ',
                                      1, v_maxlenght);
            END IF;

            IF pimporte IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act || ' // '
                                      || f_axis_literales(100576,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ': ' || pimporte,
                                      1, v_maxlenght);
            END IF;

            IF pttexto IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act || ' // '
                                      || f_axis_literales(100559,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ': ' || pttexto,
                                      1, v_maxlenght);
            END IF;

            IF v_ttipocausa IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act || ' // '
                                      || f_axis_literales(9908387,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ': ' || v_ttipocausa,
                                      1, v_maxlenght);
            END IF;
         ELSIF pcmotmov = 262 THEN   -- bloqueo
            v_situac_act := SUBSTR(f_axis_literales(152212, pac_md_common.f_get_cxtidioma)
                                   || '. ',
                                   1, v_maxlenght);

            IF pfmovfin IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act
                                      || f_axis_literales(9001993,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' - '
                                      || TO_DATE(pfmovfin, 'dd/mm/rrrr') || ' ) ',
                                      1, v_maxlenght);
            ELSE
               v_situac_act := SUBSTR(v_situac_act
                                      || f_axis_literales(9000526,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ) ',
                                      1, v_maxlenght);
            END IF;

            IF pttexto IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act
                                      || f_axis_literales(100559,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ' || pttexto || '.',
                                      1, v_maxlenght);
            END IF;
         --'P¿liza bloqueada';
         ELSIF pcmotmov = 263 THEN   -- despignoraci¿n
            --'P¿liza pignorada.
            v_situac_ant := SUBSTR(f_axis_literales(152211, pac_md_common.f_get_cxtidioma)
                                   || '.',
                                   1, v_maxlenght);

            IF pfmovfin IS NOT NULL THEN
               v_situac_ant := SUBSTR(v_situac_ant || ' // '
                                      || f_axis_literales(9001993,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' - '
                                      || TO_DATE(pfmovfin, 'dd/mm/rrrr') || ' ) ',
                                      1, v_maxlenght);
            ELSE
               v_situac_ant := SUBSTR(v_situac_ant || ' // '
                                      || f_axis_literales(9000526,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ) ',
                                      1, v_maxlenght);
            END IF;

            IF pimporte IS NOT NULL THEN
               v_situac_ant := SUBSTR(v_situac_ant || ' // '
                                      || f_axis_literales(100576,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ': ' || pimporte,
                                      1, v_maxlenght);
            END IF;

            IF pttexto IS NOT NULL THEN
               v_situac_ant := SUBSTR(v_situac_ant || ' // '
                                      || f_axis_literales(100559,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ': ' || pttexto,
                                      1, v_maxlenght);
            END IF;

            --'P¿liza despignorada.
            v_situac_act := SUBSTR(f_axis_literales(109219, pac_md_common.f_get_cxtidioma)
                                   || '.',
                                   1, v_maxlenght);

            IF pfmovini IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act || ' // '
                                      || f_axis_literales(100562,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ': ' || TO_DATE(pfmovini, 'dd/mm/rrrr'),
                                      1, v_maxlenght);
            END IF;

            IF pimporte IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act || ' // '
                                      || f_axis_literales(100576,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ': ' || pimporte,
                                      1, v_maxlenght);
            END IF;

            IF pttexto2 IS NOT NULL
               OR pttexto IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act || ' // '
                                      || f_axis_literales(100559,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ': ' || NVL(pttexto2, pttexto),
                                      1, v_maxlenght);
            END IF;
         --Fi Bug.: 11164 - 15/09/2009 - ICV
         ELSIF pcmotmov = 264 THEN   -- desbloqueo
            --'P¿liza bloqueada';
            v_situac_ant := SUBSTR(f_axis_literales(152212, pac_md_common.f_get_cxtidioma)
                                   || '. ',
                                   1, v_maxlenght);

            IF pfmovfin IS NOT NULL THEN
               v_situac_ant := SUBSTR(v_situac_ant
                                      || f_axis_literales(9001993,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' - '
                                      || TO_DATE(pfmovfin, 'dd/mm/rrrr') || ' ) ',
                                      1, v_maxlenght);
            ELSE
               v_situac_ant := SUBSTR(v_situac_ant
                                      || f_axis_literales(9000526,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ) ',
                                      1, v_maxlenght);
            END IF;

            IF pttexto IS NOT NULL THEN
               v_situac_ant := SUBSTR(v_situac_ant
                                      || f_axis_literales(100559,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ' || pttexto || '.',
                                      1, v_maxlenght);
            END IF;

            --'P¿liza desbloqueada';
            v_situac_act := SUBSTR(f_axis_literales(109220, pac_md_common.f_get_cxtidioma)
                                   || '. '
                                   || f_axis_literales(100562, pac_md_common.f_get_cxtidioma)
                                   || ' ( ' || TO_DATE(pfmovfin, 'dd/mm/rrrr') || ' ) ',
                                   1, v_maxlenght);

            IF pttexto2 IS NOT NULL
               OR pttexto IS NOT NULL THEN
               v_situac_act := SUBSTR(v_situac_act
                                      || f_axis_literales(100559,
                                                          pac_md_common.f_get_cxtidioma)
                                      || ' ' || NVL(pttexto2, pttexto) || '.',
                                      1, v_maxlenght);
            END IF;
         END IF;

         IF v_pignoracionmultiple <> 2 THEN   -- BUG 27766
            -- Insercion del detalle del movimiento
            BEGIN
               INSERT INTO detmovseguro
                           (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                            tvalord, cpregun)
                    VALUES (psseguro, v_siguiente_mov, pcmotmov, v_nriesgo, 0, v_situac_ant,
                            v_situac_act, 0);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE detmovseguro
                     SET tvalora = v_situac_ant,
                         tvalord = v_situac_act
                   WHERE sseguro = psseguro
                     AND nriesgo = v_nriesgo
                     AND cgarant = 0
                     AND cpregun = 0
                     AND cmotmov = pcmotmov
                     AND nmovimi = v_siguiente_mov;
            END;
         END IF;

         -- BUG: 27766
         v_cmotmov := pcmotmov;

         IF v_pignoracionmultiple = 2
            AND pmodo IS NOT NULL THEN
            IF pmodo = 'ALTA_BENEF' THEN
               v_cmotmov := 261;
            ELSIF pmodo = 'ELIMINAR_BENEF' THEN
               v_cmotmov := 263;
            END IF;
         END IF;

         -- Fin BUG: 27766

         -- INTRODUCIMOS O ACTUALIZAMOS EL BLOQUEOSEG.
         BEGIN
            INSERT INTO bloqueoseg
                        (sseguro, finicio, ffinal, iimporte, ttexto, cmotmov,
                         nmovimi, nbloqueo, sperson, copcional,
                         nrango, ncolater, ctipocausa)   -- BUG 27766
                 VALUES (psseguro, v_fecha_efecto, NULL, pimporte, v_ttexto, v_cmotmov,
                         v_siguiente_mov, v_numbloqueo, NVL(psperson, v_sperson), pcopcional,
                         NVL(pnrango, v_nrango), pncolater, pcausa);   -- BUG 27766
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               /* UPDATE bloqueoseg
                   SET ffinal = NULL,
                       iimporte = pimporte,
                       ttexto = v_ttexto,
                       nmovimi = v_siguiente_mov
                 WHERE sseguro = psseguro
                   AND cmotmov = pcmotmov
                   AND finicio = v_fecha_efecto;*/
               ROLLBACK;
               p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_set_mov', 1,
                           'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov || ' pfmovini:'
                           || pfmovini || ' pfmovfin:' || pfmovfin || ' pttexto:' || pttexto
                           || ' pttexto2:' || pttexto2 || ' pimporte:' || pimporte,
                           SQLERRM);
               RETURN 9906363;
         END;

         -- Si es un bloqueo o pignoracion con la fecha fin informada, insertar tambien el movimiento de desbloqueo/despignorizacion
         IF pfmovfin IS NOT NULL
            AND pcmotmov IN(262, 261) THEN
            BEGIN
               -- Nos guardamos el nmovimi del bloqueo/pignoracion
               v_siguiente_mov_ant := v_siguiente_mov;

               -- Se busca el ultimo suplemento de la poliza
               BEGIN
                  SELECT nsuplem
                    INTO v_suplemento
                    FROM movseguro
                   WHERE sseguro = psseguro
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM movseguro
                                     WHERE sseguro = psseguro);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 112158;
               -- P¿liza no encontrada en la tabla MOVSEGURO
               END;

               -- Se genera el nuevo movimiento
               --Bug 15607 - 02/08/2010 - JRH - CEM - Bloqueo de p¿lizas y fecha fin (fecfin por fecini)
               num_err := f_movseguro(psseguro, NULL, v_motaux, 1, pfmovfin,   --pfmovini,
                                      NULL, v_suplemento, 0, NULL, v_siguiente_mov, f_sysdate,
                                      NULL);

               --Fi Bug 15607 - 02/08/2010 - JRH - CEM
               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               -- Se llama a f_act_hisseg para guardar la situaci¿n anterior al suplemento.
               -- El nmovimi es el anterior al del suplemento, por eso se le resta uno al reci¿n creado.
               num_err := f_act_hisseg(psseguro, v_siguiente_mov - 1);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               IF v_motaux = 263 THEN   -- despignoraci¿n
                  --Bug.: 11164 - 15/09/2009 - ICV - No se visualiza la fecha de pignoraci¿n/despignoraci¿n cuando se realiza el suplemento.
                  --P¿liza pignorada
                  v_situac_ant := SUBSTR(f_axis_literales(152211,
                                                          pac_md_common.f_get_cxtidioma)
                                         || '.',
                                         1, v_maxlenght);

                  IF pfmovfin IS NOT NULL THEN
                     v_situac_ant :=
                        SUBSTR(v_situac_ant || ' // '
                               || f_axis_literales(9001993, pac_md_common.f_get_cxtidioma)
                               || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' - '
                               || TO_DATE(pfmovfin, 'dd/mm/rrrr') || ' ) ',
                               1, v_maxlenght);
                  ELSE
                     v_situac_ant :=
                        SUBSTR(v_situac_ant || ' // '
                               || f_axis_literales(9000526, pac_md_common.f_get_cxtidioma)
                               || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ) ',
                               1, v_maxlenght);
                  END IF;

                  IF pimporte IS NOT NULL THEN
                     v_situac_ant :=
                        SUBSTR(v_situac_ant || ' // '
                               || f_axis_literales(100576, pac_md_common.f_get_cxtidioma)
                               || ' ' || pimporte || '.',
                               1, v_maxlenght);
                  END IF;

                  IF pttexto IS NOT NULL THEN
                     v_situac_ant :=
                        SUBSTR(v_situac_ant || ' // '
                               || f_axis_literales(100559, pac_md_common.f_get_cxtidioma)
                               || ' ' || pttexto || '.',
                               1, v_maxlenght);
                  END IF;

                  --P¿liza Despignorada
                  v_situac_act := SUBSTR(f_axis_literales(109219,
                                                          pac_md_common.f_get_cxtidioma)
                                         || '.',
                                         1, v_maxlenght);

                  IF pfmovfin IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(100562, pac_md_common.f_get_cxtidioma)
                               || ' ( ' || TO_DATE(pfmovfin, 'dd/mm/rrrr') || ' ) ',
                               1, v_maxlenght);
                  END IF;

                  IF pimporte IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(100576, pac_md_common.f_get_cxtidioma)
                               || ': ' || pimporte,
                               1, v_maxlenght);
                  END IF;

                  IF pttexto2 IS NOT NULL
                     OR pttexto IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act || ' // '
                               || f_axis_literales(100559, pac_md_common.f_get_cxtidioma)
                               || ' ' || NVL(pttexto2, pttexto) || '.',
                               1, v_maxlenght);
                  END IF;
               --'P¿liza despignorada. Importe: ' || pimporte;
               ELSIF v_motaux = 264 THEN   -- desbloqueo
                  --'P¿liza bloqueada';
                  v_situac_ant := SUBSTR(f_axis_literales(152212,
                                                          pac_md_common.f_get_cxtidioma)
                                         || '. ',
                                         1, v_maxlenght);

                  IF pfmovfin IS NOT NULL THEN
                     v_situac_ant :=
                        SUBSTR(v_situac_ant
                               || f_axis_literales(9001993, pac_md_common.f_get_cxtidioma)
                               || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' - '
                               || TO_DATE(pfmovfin, 'dd/mm/rrrr') || ' ) ',
                               1, v_maxlenght);
                  ELSE
                     v_situac_ant :=
                        SUBSTR(v_situac_ant
                               || f_axis_literales(9000526, pac_md_common.f_get_cxtidioma)
                               || ' ( ' || TO_DATE(pfmovini, 'dd/mm/rrrr') || ' ) ',
                               1, v_maxlenght);
                  END IF;

                  IF pttexto IS NOT NULL THEN
                     v_situac_ant :=
                        SUBSTR(v_situac_ant
                               || f_axis_literales(100559, pac_md_common.f_get_cxtidioma)
                               || ' ' || pttexto || '.',
                               1, v_maxlenght);
                  END IF;

                  --'P¿liza desbloqueada';
                  v_situac_act := SUBSTR(f_axis_literales(109220,
                                                          pac_md_common.f_get_cxtidioma)
                                         || '. '
                                         || f_axis_literales(100562,
                                                             pac_md_common.f_get_cxtidioma)
                                         || ' ( ' || TO_DATE(pfmovfin, 'dd/mm/rrrr') || ' ) ',
                                         1, v_maxlenght);

                  IF pttexto2 IS NOT NULL
                     OR pttexto IS NOT NULL THEN
                     v_situac_act :=
                        SUBSTR(v_situac_act
                               || f_axis_literales(100559, pac_md_common.f_get_cxtidioma)
                               || ' ' || NVL(pttexto2, pttexto) || '.',
                               1, v_maxlenght);
                  END IF;
                 /* v_situac_ant := f_axis_literales(152212, pac_md_common.f_get_cxtidioma);
                  --'P¿liza bloqueada';
                  v_situac_act := f_axis_literales(109220, pac_md_common.f_get_cxtidioma);*/
               --'P¿liza desbloqueada';
               END IF;

               -- Inserci¿n del detalle del movimiento
               BEGIN
                  INSERT INTO detmovseguro
                              (sseguro, nmovimi, cmotmov, nriesgo, cgarant,
                               tvalora, tvalord, cpregun)
                       VALUES (psseguro, v_siguiente_mov, v_motaux, v_nriesgo, 0,
                               v_situac_ant, v_situac_act, 0);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     UPDATE detmovseguro
                        SET tvalora = v_situac_ant,
                            tvalord = v_situac_act
                      WHERE sseguro = psseguro
                        AND nriesgo = v_nriesgo
                        AND cgarant = 0
                        AND cpregun = 0
                        AND cmotmov = v_motaux
                        AND nmovimi = v_siguiente_mov;
               END;

               -- se inserta el movimiento de desbloqueo/pignoracion
               INSERT INTO bloqueoseg
                           (sseguro, finicio, ffinal, iimporte, ttexto, cmotmov,
                            nmovimi, nbloqueo, sperson, copcional, nrango,
                            ncolater, ctipocausa)
                    VALUES (psseguro, pfmovfin, NULL, pimporte, pttexto2, v_motaux,
                            v_siguiente_mov, v_numbloqueo, psperson, pcopcional, pnrango,
                            pncolater, pcausa);

               -- se actualiza la ffinal del movimiento de bloqueo/pignoracion
               UPDATE bloqueoseg
                  SET ffinal = pfmovfin
                WHERE sseguro = psseguro
                  AND cmotmov = pcmotmov
                  AND nmovimi = v_siguiente_mov_ant;
            EXCEPTION
               WHEN OTHERS THEN
                  ROLLBACK;
                  RETURN 101283;   -- No se han podido grabar los datos.
            END;
         END IF;

         COMMIT;

         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'POST_ACCION_LRE'),
                0) = 1 THEN
            num_err := pac_propio.f_acciones_post_movimientos(psseguro, 0, pcmotmov);

            IF num_err != 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         RETURN 0;   -- Todo Ok
      ELSE   -- No se puede realizar el movimiento de bloqueo/desbloqueo,
             -- pignoracion/despignoracion
         RETURN v_validamov;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_set_mov', 1,
                     'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov || ' pfmovini:'
                     || pfmovini || ' pfmovfin:' || pfmovfin || ' pttexto:' || pttexto
                     || ' pttexto2:' || pttexto2 || ' pimporte:' || pimporte,
                     SQLERRM);
         RETURN 101283;   -- No se han podido grabar los datos.
   END f_set_mov;

   /*************************************************************************
      Funcion que sirve para recuperar la descripcion del movimiento de
      desbloqueo o despignoracion
      param in psseguro  : id. de la poliza
      param in pcmotmov  : codigo motivo movimiento
      param in pnbloqueo : fecha inicio movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_get_textdesbloq(psseguro IN NUMBER, pcmotmov IN NUMBER, pnbloqueo IN NUMBER)
      RETURN VARCHAR2 IS
      v_ttexto       bloqueoseg.ttexto%TYPE;
   BEGIN
      SELECT ttexto
        INTO v_ttexto
        FROM bloqueoseg
       WHERE sseguro = psseguro
         AND nbloqueo = pnbloqueo
         AND cmotmov = pcmotmov
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM bloqueoseg b1
                         WHERE b1.sseguro = psseguro
                           AND b1.nbloqueo = pnbloqueo
                           AND b1.cmotmov = pcmotmov);

      RETURN v_ttexto;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_get_textdesbloq', 1,
                     'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov || ' pnbloqueo:'
                     || pnbloqueo,
                     SQLERRM);
         RETURN NULL;
   END f_get_textdesbloq;

   /*************************************************************************
      Funcion que valida la situacion de una poliza para realizar un
      bloqueo/desbloqueo o pignoracion/despignoracion
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_crea_mov(psseguro IN NUMBER, pcmotmov IN NUMBER)
      RETURN NUMBER IS
      v_sseguro      seguros.sseguro%TYPE;
      v_csituac      seguros.csituac%TYPE;
      v_creteni      seguros.creteni%TYPE;
      v_fcaranu      seguros.fcaranu%TYPE;
      v_fcarpro      seguros.fcarpro%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
      v_fvencim      seguros.fvencim%TYPE;
      v_motmovbloq   NUMBER;
      v_motmovdes    NUMBER;
      v_numbloq      NUMBER;
      v_numdes       NUMBER;
      v_existsbloqueo NUMBER;
      v_cmotmov      bloqueoseg.cmotmov%TYPE;
      v_crealiza number;
      v_cempres number;
      vnumerr number;
   BEGIN
      -- se mira que el seguro exista
      BEGIN
         SELECT sseguro, csituac, creteni, fcaranu, fcarpro, sproduc, fefecto,
                fvencim, cempres
           INTO v_sseguro, v_csituac, v_creteni, v_fcaranu, v_fcarpro, v_sproduc, v_fefecto,
                v_fvencim, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(100500);   -- P¿liza inexistente
      END;

      -- situaci¿n de la p¿liza: la poliza debe estar vigente y no retenida
      vnumerr:=pac_cfg.f_get_user_accion_permitida(f_user, 'PIGNORA_CANCELADA', 0, v_cempres, v_crealiza);
      --No se controla el error solo el resultado

      if nvl(v_crealiza,0) = 1 then
          IF v_csituac not in (0,2)
             OR v_creteni <> 0 THEN
             RETURN(120129);
          END IF;
      else
      IF v_csituac <> 0
         OR v_creteni <> 0 THEN
         RETURN(120129);
      END IF;
      end if;

      -- Si no permite pignoraci¿n pues mensage informativo
      IF f_parproductos_v(v_sproduc, 'PERMITE_PIGNORACION') = 0 THEN
         RETURN(180569);
-- Bloqueo/Desbloqueo/Pignoraci¿n/Despignoraci¿n de este tipo de p¿lizas no permitida
      END IF;

      -- BUG13866:DRA:26/03/2010:Inici
      IF pcmotmov IN(261, 263)
         AND f_parproductos_v(v_sproduc, 'PERMITE_PIGNORACION') NOT IN(1, 3) THEN
         RETURN 9901115;
      -- Pignoraci¿n/Despignoraci¿n de este tipo de p¿lizas no permitida
      ELSIF pcmotmov IN(262, 264)
            AND f_parproductos_v(v_sproduc, 'PERMITE_PIGNORACION') NOT IN(2, 3) THEN
         RETURN 9901114;
      -- Bloqueo/Desbloqueo de este tipo de p¿lizas no permitida
      END IF;

      -- BUG13866:DRA:26/03/2010:Fi

      -- Comprobar la situaci¿n de bloqueos/pignoraciones y desbloqueos/despignoraciones.
      BEGIN
         -- 261: Pignoraci¿n. 263: Despignoraci¿n.
         IF pcmotmov IN(261, 263) THEN
            v_motmovbloq := 261;
            v_motmovdes := 263;
         ELSE
            -- 262: Bloqueo. 264: Desbloqueo.
            v_motmovbloq := 262;
            v_motmovdes := 264;
         END IF;

         SELECT COUNT(sseguro)
           INTO v_numbloq
           FROM bloqueoseg
          WHERE sseguro = psseguro
            AND cmotmov = v_motmovbloq;

         SELECT COUNT(sseguro)
           INTO v_numdes
           FROM bloqueoseg
          WHERE sseguro = psseguro
            AND cmotmov = v_motmovdes;
      END;

      -- Hay m¿s bloqueos que desbloqueos.
      IF v_numbloq > v_numdes THEN
         -- Si se est¿ intentando crear un bloqueo, mostrar error.
         IF pcmotmov = 262 THEN
            RETURN(109201);
-- Este seguro est¿ bloqueado. Para poder hacer un nuevo bloqueo debe desbloquearlo antes.
         END IF;

         -- Si se est¿ intentando crear una pignoraci¿n, mostrar error.
         IF pcmotmov = 261 THEN
            RETURN(109200);
-- Este seguro est¿ pignorado. Para poder hacer una nueva pignoraci¿n debe despignorarlo antes
         END IF;
      -- Hay m¿s desbloqueos que bloqueos.
      ELSIF v_numbloq < v_numdes THEN
         -- Si se est¿ intentando crear un desbloqueo, mostrar error.
         IF pcmotmov = 264 THEN
            RETURN(109223);   -- No hay ning¿n bloqueo activo
         END IF;

         -- Si se est¿ intentando crear una despignoraci¿n, mostrar error.
         IF pcmotmov = 263 THEN
            RETURN(109213);
         -- Sobre este seguro no hay ninguna pignoraci¿n vigente.
         END IF;
      END IF;

      -- Motivo: despignoraci¿n (263) o desbloqueo (264).
      -- Si se trata de un desbloqueo o despignoraci¿n debe existir un bloqueo o pignoraci¿n activo.
      IF pcmotmov IN(263, 264) THEN
         BEGIN
            SELECT 1
              INTO v_existsbloqueo
              FROM bloqueoseg
             WHERE sseguro = psseguro
               AND cmotmov = v_motmovbloq
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM bloqueoseg
                               WHERE sseguro = psseguro
                                 AND cmotmov = v_motmovbloq);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF pcmotmov = 263 THEN
                  -- ERROR : NO HAY NINGUNA PIGNORACI¿N ACTIVA
                  RETURN(109213);
               ELSE
                  -- ERROR : NO HAY NING¿N BLOQUEO ACTIVO
                  RETURN(109223);
               END IF;
         END;
      END IF;

      -- Si la poliza est¿ bloqueda no se puede pignorar
      -- Si la poliza est¿ pignorada no se puede bloquear
      BEGIN
         -- Se busca la ultima situacion de la poliza
         -- Debe estar el max por si se ha bloquedo y desbloqueado en el mismo movimiento, es decir,
         -- si se ha realizado un bloqueo o pignoracion con la fecha fin informada, se inserta
         -- tambien el movimiento de desbloqueo/despignorizacion
         SELECT MAX(cmotmov)
           INTO v_cmotmov
           FROM bloqueoseg
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM bloqueoseg
                            WHERE sseguro = psseguro);
      EXCEPTION
         WHEN OTHERS THEN
            v_cmotmov := NULL;
      END;

      IF v_cmotmov IS NOT NULL THEN
         -- Si la poliza est¿ bloqueda no se puede pignorar, ni despignorar ni bloquear otra vez
         IF v_cmotmov = 262
            AND(pcmotmov = 261
                OR pcmotmov = 263
                OR pcmotmov = 262) THEN
            RETURN 152212;   -- P¿liza bloqueada
         END IF;

         -- Si la poliza est¿ pignorada no se puede bloquear, ni desbloquear ni pignorar
         IF v_cmotmov = 261
            AND(pcmotmov = 262
                OR pcmotmov = 261
                OR pcmotmov = 264) THEN
            RETURN 152211;   -- P¿liza pignorada
         END IF;

         -- Si la poliza est¿ despignorada no se puede bloquear, ni desbloquear ni despignorar
         IF v_cmotmov = 263
            AND(pcmotmov = 263
                OR pcmotmov = 264) THEN
            RETURN 109219;   -- P¿liza despignorada
         END IF;

         -- Si la poliza est¿ desbloquejada no se puede despignorar, ni pignorar ni desbloquear
         IF v_cmotmov = 264
            AND(pcmotmov = 264
                OR pcmotmov = 263) THEN
            RETURN 109220;   -- P¿liza desbloqueada
         END IF;
      END IF;

      RETURN 0;   -- Todo Ok
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_valida_crea_mov', 1,
                     'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov, SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_valida_crea_mov;

   /*************************************************************************
      Funcion que realiza la validacion para la insercion de un movimiento de
      bloqueo, desbloqueo, pignoracion y despignoracion de la poliza
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfmovfin : fecha fin movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfmovini IN DATE,
      pfmovfin IN DATE,
      pimporte IN NUMBER,
      pmodo IN VARCHAR2)
      RETURN NUMBER IS
      v_fefecto      DATE;
      v_sseguro      seguros.sseguro%TYPE;
      v_csituac      seguros.csituac%TYPE;
      v_creteni      seguros.creteni%TYPE;
      v_fcaranu      seguros.fcaranu%TYPE;
      v_fcarpro      seguros.fcarpro%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_fefectopol   seguros.fefecto%TYPE;
      v_fvencim      seguros.fvencim%TYPE;
      v_motmovbloq   NUMBER;
      v_motmovdes    NUMBER;
      v_finicio      bloqueoseg.finicio%TYPE;
      v_ffinal       bloqueoseg.ffinal%TYPE;
      v_fmovimi      DATE;   --Bug.: 14620
      v_numreg       NUMBER;   -- Bug: 27766
      v_numdes       NUMBER;   -- Bug: 27766
      v_importetot   NUMBER;
      v_importepigno NUMBER;
      v_cempres      seguros.cempres%TYPE;   -- BUG:34496
      v_crealiza     cfg_accion.crealiza%TYPE;   -- BUG:34496
      vnumerr        NUMBER;   -- BUG:34496
   BEGIN
      -- comprobaci¿n de fechas
      SELECT MAX(fefecto)
        INTO v_fefecto
        FROM movseguro
       WHERE sseguro = psseguro;

      BEGIN
         SELECT sseguro, csituac, creteni, fcaranu, fcarpro, sproduc,
                fefecto, fvencim, cempres
           INTO v_sseguro, v_csituac, v_creteni, v_fcaranu, v_fcarpro, v_sproduc,
                v_fefectopol, v_fvencim, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(100500);   -- P¿liza inexistente
      END;

      BEGIN
         SELECT NVL(SUM(icapital), 0)
           INTO v_importetot
           FROM garanseg
          WHERE sseguro = psseguro
            AND ffinefe IS NULL
            AND cgarant IN(SELECT cgarant
                             FROM garanpro
                            WHERE sproduc = v_sproduc
                              AND cbasica = 1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(100500);   -- P¿liza inexistente
      END;

      --Ini Bug.: 0014620 - 25/05/2010 - ICV
      IF pcmotmov IN(261, 262) THEN   -- Pignoraci¿n o Bloqueo
         v_fmovimi := pfmovini;
      ELSE   -- Despignoraci¿n o Desbloqueo.
         v_fmovimi := pfmovfin;
      END IF;

      -- La fecha de incio del movimiento debe ser anterior a la fecha de
      -- pr¿xima cartera y a la fecha de cartera anual, y posterior a la fecha
      -- del ¿ltimo movimiento
      /*IF v_fmovimi > v_fcaranu THEN
         RETURN(103308);
-- La fecha del suplemento no puede ser superior a la fecha de la pr¿xima cartera
      END IF;

      IF v_fmovimi > v_fcarpro THEN
         RETURN(103308);
-- La fecha del suplemento no puede ser superior a la fecha de la pr¿xima cartera
      END IF;*/

      -- Bug 34496 - XBA - 03/02/2015 - MSV - Modifications in manual pledge
      -- Solo algunos usuarios podr¿n realizar una pignoraci¿n con fecha anterior a una existente
      vnumerr := pac_cfg.f_get_user_accion_permitida(f_user, 'PERMITE_PIGNORAR', psseguro,
                                                     v_cempres, v_crealiza);

      IF NVL(v_crealiza, 0) = 0 THEN
         IF v_fmovimi < v_fefecto THEN
            RETURN(700088);
         -- La fecha no puede ser anterior al moviento anterior
         END IF;
      END IF;

      -- La fecha de incio del movimiento debe ser posterior a la fecha efecto
      -- de la p¿liza y anterior a la fecha de vencimiento
      IF v_fmovimi < v_fefectopol THEN
         RETURN(101203);
      -- Esta fecha no puede ser m¿s peque¿a que la fecha efecto del seg.
      END IF;

      IF v_fmovimi > v_fvencim THEN
         RETURN(101729);
      -- Esta fecha no puede ser m¿s grande que la de vencimiento del seg.
      END IF;

      --Fin Bug.: 0014620

      -- 261: Pignoraci¿n. 263: Despignoraci¿n.
      IF pcmotmov IN(261, 263) THEN
         BEGIN
            SELECT NVL(SUM(iimporte), 0)
              INTO v_importepigno
              FROM bloqueoseg
             WHERE sseguro = psseguro
               AND cmotmov = 261
               AND ffinal IS NULL;

            v_importepigno := v_importepigno + pimporte;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_importepigno := pimporte;
         END;

         v_motmovbloq := 261;
         v_motmovdes := 263;
      ELSE
         -- 262: Bloqueo. 264: Desbloqueo.
         v_motmovbloq := 262;
         v_motmovdes := 264;
      END IF;

      -- Motivo: despignoraci¿n (263) o desbloqueo (264).
      IF pcmotmov IN(263, 264) THEN
         BEGIN
            SELECT finicio, ffinal
              INTO v_finicio, v_ffinal
              FROM bloqueoseg
             WHERE sseguro = psseguro
               AND cmotmov = v_motmovbloq
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM bloqueoseg
                               WHERE sseguro = psseguro
                                 AND cmotmov = v_motmovbloq);
         EXCEPTION
            WHEN OTHERS THEN
               v_finicio := NULL;
               v_ffinal := NULL;
         END;
      -- Motivo: pignoraci¿n (261) o bloqueo (262).
      ELSE
         BEGIN
            SELECT finicio, ffinal
              INTO v_finicio, v_ffinal
              FROM bloqueoseg
             WHERE sseguro = psseguro
               AND cmotmov = v_motmovdes
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM bloqueoseg
                               WHERE sseguro = psseguro
                                 AND cmotmov = v_motmovdes);
         EXCEPTION
            WHEN OTHERS THEN
               v_finicio := NULL;
               v_ffinal := NULL;
         END;
      END IF;

      -- Se comprueba que la fecha de inicio de un bloqueo no sea menor que la del ultimo desbloqueo.
      IF NVL(f_parproductos_v(v_sproduc, 'CPIGNOMULT'), 0) IN(0, 1) THEN   -- BUG - 27766
         IF (pcmotmov = 261)
            AND(v_finicio IS NOT NULL)
            AND(pfmovini < v_finicio) THEN
            RETURN(109858);
         -- La fecha de inicio no puede ser inferior a la fecha del ultimo desbloqueo
         END IF;
      END IF;

      -- Se comprueba que la fecha de inicio de una pignoracion no sea menor que la de la ultima despignoracion.
      IF (pcmotmov = 262)
         AND(v_finicio IS NOT NULL)
         AND(pfmovini < v_finicio) THEN
         RETURN(109859);
      -- La fecha de inicio no puede ser inferior a la fecha de despignoracion
      END IF;

      -- BUG - 27766
      -- Se comprueba que una psliza ya se encuentra pignorada
      IF pmodo IS NULL   -- Se quiere pignorar
         AND pcmotmov = 261
         AND NVL(f_parproductos_v(v_sproduc, 'CPIGNOMULT'), 0) IN(0, 1) THEN
         SELECT COUNT(sseguro)
           INTO v_numreg
           FROM bloqueoseg
          WHERE sseguro = psseguro
            AND cmotmov = 261;

         SELECT COUNT(sseguro)
           INTO v_numdes
           FROM bloqueoseg
          WHERE sseguro = psseguro
            AND cmotmov = 263;

         -- Hay mas bloqueos que desbloqueos.
         IF v_numreg > v_numdes THEN
            -- Si se esta intentando crear una pignoracion, mostrar error.
            RETURN(109200);
-- Este seguro esta pignorado. Para poder hacer una nueva pignoracion debe despignorarlo antes
         END IF;
      END IF;

      --
      IF pmodo IS NULL
         AND pcmotmov = 263 THEN
         -- Comprobar que existe un znico beneficiaro
         SELECT COUNT(*)
           INTO v_numreg
           FROM bloqueoseg
          WHERE sseguro = psseguro
            AND sperson IS NOT NULL
            AND cmotmov = 261
            AND ffinal IS NULL;

         IF v_numreg > 1 THEN
            RETURN(9906361);
         -- No se permite despignorar una psliza con mas de un beneficiario activo
         END IF;
      END IF;

      -- FIN BUG - 27766

      -- Validaciones de la fecha de fin.
      IF pfmovfin IS NOT NULL THEN
         -- La fecha fin de un movimiento debe ser posterior a la fecha inicio del movimiento
         IF pfmovfin < pfmovini THEN
            RETURN(101922);
         -- La fecha inicial no puede ser mayor que la final
         END IF;

         -- La fecha fin de un movimiento debe ser anterior a la fecha de vencimiento de la poliza
         IF pfmovfin > v_fvencim THEN
            RETURN(101729);
         -- Esta fecha no puede ser mas grande que la de vencimiento del seg.
         END IF;
      ELSE
         -- Si desbloqueo o despignoracion, la fecha de fin no puede ser nula.
         IF pcmotmov IN(263, 264) THEN
            RETURN(105554);   -- Fecha final obligatoria
         END IF;
      END IF;

      -- Validacion del importe.
      -- En los movimientos de pignoracion debe informarse el importe

      -- BUG34603:XBA:17/02/2015:Inici
      -- MSV nos pide poder hacer pignoraciones sin importe. En siniestros deber¿n informarlo
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                           'PIGNORA_SIN_IMPORTE'),
             0) = 0 THEN
         IF pcmotmov = 261
            AND pimporte IS NULL THEN
            RETURN(104536);   -- Importe obligatorio
         END IF;

         --END IF;

         -- BUG34603:XBA:17/02/2015:Fi
         IF pcmotmov = 261
            AND v_importepigno > v_importetot THEN
            RETURN(9901617);   -- Importe max.
         END IF;
      END IF;   -- BUG 34946-200315.

      RETURN 0;   -- Todo Ok
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_valida_mov', 1,
                     'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov || ' pfmovini:'
                     || pfmovini || ' pfmovfin:' || pfmovfin || ' pimporte:' || pimporte,
                     SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_valida_mov;

   /*************************************************************************
      Funcion que inicializa los campos de pantalla en funcion de los
      parametros de entrada
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pnmovimi : Nzmero de movimiento  -- BUG 27766
      param out pquery  : consulta a realizar construida en funcion de los
                          parametros
      return            : Error
   *************************************************************************/
   FUNCTION f_get_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      v_motmovbloq   NUMBER;
      v_motmovdes    NUMBER;
   BEGIN
      -- 261: Pignoraci¿n. 263: Despignoraci¿n.
      IF pcmotmov IN(261, 263) THEN
         v_motmovbloq := 261;
         v_motmovdes := 263;
      ELSE
         -- 262: Bloqueo. 264: Desbloqueo.
         v_motmovbloq := 262;
         v_motmovdes := 264;
      END IF;

      -- BUG 27766: Se adicionan nuevas columnas a la query
      -- Motivo: despignoracion (263) o desbloqueo (264).
      IF pcmotmov IN(263, 264) THEN
         pquery :=
            'select finicio, ffinal, ttexto, iimporte, nbloqueo, sperson, copcional, nrango, ncolater, ctipocausa '
            || 'from bloqueoseg where sseguro = ' || psseguro || ' and cmotmov = '
            || v_motmovbloq || ' and nmovimi = ' || pnmovimi;
      /*'(select max(nmovimi) from bloqueoseg where sseguro = ' || psseguro
      || ' and cmotmov = ' || v_motmovbloq || ')';*/
      END IF;

      RETURN 0;   -- Todo Ok
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_get_mov', 1,
                     'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov, SQLERRM);
         RETURN 140999;
   -- Error no controlado
   END f_get_mov;

   /*************************************************************************
      f_get_pignoradores
        Funcion que retornara la lista de personas que contienen el parametro en PER_PARPERSONAS
        con valor 0, mas los que ya existan en los bloqueos asociados a la poliza
        param in psperson : id. de persona
        param in pcmotmov : Motivo del movimiento
        param out pquery  : consulta a realizar construida en funcion de los
                          parametros
        return            : Error
      BUG - 27766
   *************************************************************************/
   FUNCTION f_get_pignoradores(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pmodo IN VARCHAR2,
      pnmovimi IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      -- 940
      --
      IF pcmotmov = 261
         AND pmodo = 'ALTA_BENEF' THEN
         -- XBA - BUG:34496 (02/02/2015) - Quieren que el beneficiario de la pignoraci¿n pueda pignorar m¿s de una vez la misma p¿liza
         /*
         pquery := 'SELECT sperson,f_nombre(sperson,1,NULL) as tnombre '
                   || 'FROM per_parpersonas p '
                   || 'WHERE cparam = ''CPIGNORADOR'' AND nvalpar = 0 ' || 'AND NOT EXISTS ( '
                   || 'SELECT sperson,f_nombre(sperson,1,NULL) as tnombre '
                   || 'FROM bloqueoseg b ' || 'WHERE b.sperson is not null and b.sseguro = '
                   || psseguro
                   || '  AND b.sperson = p.sperson AND b.cmotmov = 261 AND ffinal IS NULL )';
         */
         pquery := 'SELECT DISTINCT(sperson),f_nombre(sperson,1,NULL) as tnombre '
                   || 'FROM per_parpersonas p '
                   || 'WHERE cparam = ''CPIGNORADOR'' AND nvalpar = 0 ';
      END IF;

      --
      -- 263: Despignoracion
      IF pcmotmov = 263 THEN
         pquery := 'SELECT sperson,f_nombre(sperson,1,NULL) as tnombre ' || 'FROM bloqueoseg '
                   || 'WHERE sperson is not null and sseguro = ' || psseguro
                   || ' AND nmovimi = ' || pnmovimi;
      END IF;

      --
      -- 261: Pignoracion.
      IF pcmotmov = 261
         AND pmodo IS NULL THEN
         pquery := 'SELECT sperson,f_nombre(sperson,1,NULL) as tnombre '
                   || 'FROM per_parpersonas '
                   || 'WHERE cparam = ''CPIGNORADOR'' AND nvalpar = 0 ' || 'UNION '
                   || 'SELECT sperson,f_nombre(sperson,1,NULL) as tnombre '
                   || 'FROM bloqueoseg ' || 'WHERE sperson is not null and sseguro ='
                   || psseguro || ' AND cmotmov = 261 AND ffinal IS NULL';
      END IF;

      IF pcmotmov IN(262, 264) THEN
         pquery := 'SELECT '' '' sperson, '' '' tnombre ' || 'FROM DUAL ' || 'WHERE 1 = 1';
      END IF;
      -- CONF-274-25/11/2016-JLTS- Ini
      IF pcmotmov =391 THEN
         pquery := 'SELECT '' '' sperson, '' '' tnombre ' || 'FROM DUAL ' || 'WHERE 1 = 1';
      END IF;

      IF pcmotmov =141 THEN
         pquery := 'SELECT '' '' sperson, '' '' tnombre ' || 'FROM DUAL ' || 'WHERE 1 = 1';
      END IF;
      -- CONF-274-25/11/2016-JLTS- Ini
      RETURN 0;   --Todo OK
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_get_pignoradores', 1,
                     'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov, SQLERRM);
         RETURN 140999;
   -- Error no controlado
   END f_get_pignoradores;

   /*************************************************************************
      f_get_bloqueos
        Funcion que retorna los registros de la tabla bloqueo que se encuentren vigentes
        param in psperson : id. de persona
        param out pquery  : consulta a realizar construida en funcion de los
                          parametros
        return            : Error
      BUG - 27766
   *************************************************************************/
   FUNCTION f_get_bloqueos(psseguro IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER IS
      v_cempres      seguros.cempres%TYPE;
   BEGIN
      v_cempres := pac_md_common.f_get_cxtempresa();

      -- 29822/202593 - Se agrega columna ff_desvalorfijo
      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MUESTRA_TODO_BLOQUEO'), 1) = 1 THEN
         pquery :=
            'SELECT b.sseguro, b.nmovimi, s.fmovimi,  s.fefecto, b.finicio, b.ffinal, b.cmotmov, m.tmotmov, b.iimporte, '
            || 'b.sperson, f_nombre(b.sperson,1,NULL) tnombre, b.nrango, b.ttexto, s.cusumov, ff_desvalorfijo(8000957, pac_md_common.f_get_cxtidioma, b.nrango) trango, b.ctipocausa, '
            || 'ff_desvalorfijo(8000958, pac_md_common.f_get_cxtidioma, b.ctipocausa) ttipocausa, b.NCOLATER, '
            || 'pac_bloqueo.f_permitir_modificar(b.sseguro,  b.finicio, b.cmotmov, b.nmovimi) modpledge '
            || 'FROM bloqueoseg b, movseguro s, motmovseg m '
            || 'WHERE b.sseguro = s.sseguro
                   AND b.nmovimi = s.nmovimi
                   AND b.cmotmov = m.cmotmov '
            || 'AND b.sseguro = ' || psseguro || ' ' || 'AND b.ffinal IS NULL '
            || 'AND b.cmotmov = 261 ' || 'AND m.cidioma = ' || pac_md_common.f_get_cxtidioma
            || ' ORDER BY b.nrango, b.nbloqueo, b.cmotmov';
      ELSE
         pquery :=
            'SELECT b.sseguro, b.nmovimi, s.fmovimi,  s.fefecto, b.finicio, b.ffinal, b.cmotmov, m.tmotmov, b.iimporte, '
            || 'b.sperson, f_nombre(b.sperson,1,NULL) tnombre, b.nrango, b.ttexto, s.cusumov, ff_desvalorfijo(8000957, pac_md_common.f_get_cxtidioma, b.nrango) trango, b.ctipocausa, '
            || 'ff_desvalorfijo(8000958, pac_md_common.f_get_cxtidioma, b.ctipocausa) ttipocausa, b.NCOLATER, '
            || 'pac_bloqueo.f_permitir_modificar(b.sseguro,  b.finicio, b.cmotmov, b.nmovimi) modpledge '
            || 'FROM bloqueoseg b, movseguro s, motmovseg m '
            || 'WHERE b.sseguro = s.sseguro
                   AND b.nmovimi = s.nmovimi
                   AND b.cmotmov = m.cmotmov '
            || 'AND b.sseguro = ' || psseguro || ' ' || 'AND m.cidioma = '
            || pac_md_common.f_get_cxtidioma || ' ORDER BY b.nrango, b.nbloqueo, b.cmotmov';
      END IF;

      RETURN 0;   --Todo OK
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_get_bloqueos', 1,
                     'psseguro:' || psseguro, SQLERRM);
         RETURN 140999;
   -- Error no controlado
   END f_get_bloqueos;

   /*************************************************************************
      f_detmovseguro
      Funcion que graba en la tabla detmovseguro la informaicon recibida por
      parametros
      param in psseguro : id. de la poliza
      param in pnmovimi : id. del movimiento
      param in pcmotmov : codigo motivo movimiento
      param in pantes   : valor antes del suplemento
      param in pdepues  : valor despues del suplemento
      return           : 0 OK
                         <> 0 Error
      BUG - 27766
   *************************************************************************/
   FUNCTION f_detmovseguro(
      psseguro IN NUMBER,
      pnmovini IN NUMBER,
      pcmotmov IN NUMBER,
      pantes IN VARCHAR2,
      pdespues IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO detmovseguro
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora, tvalord, cpregun)
           VALUES (psseguro, pnmovini, pcmotmov, 0, 0, pantes, pdespues, 0);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_detmovseguro', 1,
                     'psseguro:' || psseguro || ' pnmovini:' || pnmovini || ' pcmotmov:'
                     || pcmotmov || ' pantes:' || pantes || ' pdespues:' || pdespues,
                     SQLERRM);
         RETURN 101283;
   END f_detmovseguro;

    /*************************************************************************
      f_valida_bloqueo_vigente
        Funcisn que Verifica la existencia de un bloqueo/pignoracisn vigente con el mismo nzmero de rango
        param in sseguro : id. de la poliza
        param in  pnrango: Nzmero de rango dentro de las pignoraciones
        return                : 0 (todo OK)
                                <> 0 (ha habido algun error)
      BUG - 27766
   *************************************************************************/
   FUNCTION f_valida_bloqueo_vigente(
      psseguro IN NUMBER,
      pnrango IN NUMBER,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_nreg         NUMBER;
   BEGIN
      --
      SELECT COUNT(*)
        INTO v_nreg
        FROM bloqueoseg
       WHERE sseguro = psseguro
         AND nrango = pnrango
         AND ffinal IS NULL
         AND((pcmotmov IS NOT NULL
              AND cmotmov = pcmotmov)
             OR pcmotmov IS NULL);

      --
      IF v_nreg != 0 THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_valida_bloqueo_vigente', 1,
                     'psseguro:' || psseguro || ' pnrango:' || pnrango, SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_valida_bloqueo_vigente;

   /*************************************************************************
      f_valida_dest_pignoracion
        Funcisn que valida si la persona esta parametrizada para poder
        ser destinatario de una pignoracisn
        param in psperson : id. de persona
        return                : 0 (todo OK)
                                <> 0 (ha habido algun error)
      BUG - 27766
   *************************************************************************/
   FUNCTION f_valida_dest_pignoracion(psperson IN NUMBER)
      RETURN NUMBER IS
      v_nreg         NUMBER;
   BEGIN
      --
      SELECT COUNT(*)
        INTO v_nreg
        FROM per_parpersonas
       WHERE cparam = 'CPIGNORADOR'
         AND sperson = psperson
         AND nvalpar = 0;

      --
      IF v_nreg = 0 THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_bloqueo.f_valida_dest_pignoracion', 1,
                     'psperson:' || psperson, SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_valida_dest_pignoracion;

   FUNCTION f_update_pledged(
      psseguro IN NUMBER,
      pcmotmov IN VARCHAR2,
      pnmovimi IN NUMBER,
      pttexto_ant IN VARCHAR2,
      psperson_ant IN NUMBER,
      pnrango_ant IN NUMBER,
      pncolater_ant IN NUMBER,
      pfmovini_ant IN DATE,
      pttexto_upd IN VARCHAR2,
      psperson_upd IN NUMBER,
      pnrango_upd IN NUMBER,
      pncolater_upd IN NUMBER,
      pfmovini_upd IN DATE)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vobject        VARCHAR(50) := 'PAC_BLOQUEO.f_update_pledged';
      vparam         VARCHAR(4000)
         := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || ' pnmovimi=' || pnmovimi
            || ' pttexto_ant=' || pttexto_ant || ' psperson_ant=' || psperson_ant
            || ' pnrango_ant=' || pnrango_ant || ' pncolater_ant=' || pncolater_ant
            || ' pfmovini_ant=' || pfmovini_ant || ' pttexto_upd=' || pttexto_upd
            || ' psperson_upd=' || psperson_upd || ' pnrango_upd=' || pnrango_upd
            || ' pncolater_upd=' || pncolater_upd || ' pfmovini_upd=' || pfmovini_upd;
      vpasexec       NUMBER := 1;
   BEGIN
      UPDATE bloqueoseg
         SET ttexto = pttexto_upd,
             sperson = psperson_upd,
             nrango = pnrango_upd,
             ncolater = pncolater_upd,
             finicio = pfmovini_upd
       WHERE sseguro = psseguro
         AND cmotmov = pcmotmov
         AND nmovimi = pnmovimi
         /*AND(ttexto = pttexto_ant
             OR ttexto IS NULL)
         AND sperson = psperson_ant
         AND nrango = pnrango_ant
         AND ncolater = pncolater_ant*/
         AND finicio = pfmovini_ant;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 1, vparam, SQLERRM);
         RETURN 1;
   END f_update_pledged;

   FUNCTION f_permitir_modificar(
      psseguro IN NUMBER,
      pfinicio IN DATE,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      --
      vcont          NUMBER := 0;
      vobject        VARCHAR2(50) := 'PAC_BLOQUEO.f_permitir_modificar';
      vparam         VARCHAR2(200)
         := 'psseguro= ' || psseguro || ' - pfinicio= ' || pfinicio || ' -pcmotmov= '
            || pcmotmov || ' -pnmovimi= ' || pnmovimi;
   --
   BEGIN
      --
      SELECT COUNT(1)
        INTO vcont
        FROM bloqueoseg
       WHERE sseguro = psseguro
         AND finicio = pfinicio
         AND nmovimi = pnmovimi
         AND((ffinal IS NOT NULL
              AND pcmotmov IN(261, 262)
              AND cmotmov = pcmotmov)
             OR(pcmotmov IN(263, 264)
                AND cmotmov = pcmotmov));

      --
      RETURN vcont;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 1, vparam, SQLERRM);
         RETURN 1;
   END f_permitir_modificar;
END pac_bloqueo;

/

  GRANT EXECUTE ON "AXIS"."PAC_BLOQUEO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BLOQUEO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BLOQUEO" TO "PROGRAMADORESCSI";
