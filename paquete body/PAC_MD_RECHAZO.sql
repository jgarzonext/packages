--------------------------------------------------------
--  DDL for Package Body PAC_MD_RECHAZO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_RECHAZO" AS
   /******************************************************************************
      NOMBRE:    PAC_MD_RECHAZO
      PROP¿SITO: Funciones para

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        11/02/2009   JMF                1. Creaci¿n del package.
      2.0        27/12/2011   APD                2. 0020664: LCOL_T001-LCOL - UAT - TEC - Anulaciones y Rehabilitaciones
      3.0        19/02/2013   APD                3. 0026151: LCOL - QT 6096 - Anular movimientos de car¿tula
      4.9        09/12/2013   DCT                4. 0029229: LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
      5.0        14/04/2014   JSV                5. 0029665: LCOL_PROD-Qtrackers Fase 2 - iAXIS Produccion
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Valida el rechazo.
      param in     psseguro : C¿digo del seguro
      param in     pcmotmov : C¿digo del motivo
      param in     pnmovimi : N¿mero movimiento
      param in     paccion  : Acci¿n (3) si es rechazo ¿ (4) anulaci¿n del suplemento
      param in     ptobserv : Observaciones
      param in out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION val_rechazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pskip IN NUMBER DEFAULT 0,
      pnorec IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'seg=' || psseguro || ' mot=' || pcmotmov || ' mov=' || pnmovimi || ' acc='
            || paccion;
      vobject        VARCHAR2(200) := 'PAC_MD_RECHAZO.val_rechazo';
      num_err        NUMBER;
      n_emp          NUMBER;
      n_pro          NUMBER;
      n_rea          NUMBER;
      vcmovseg       movseguro.cmovseg%TYPE;   -- Bug 20664 - APD - 27/12/2011
      vncertif       NUMBER;
      vfmovimi_0     movseguro.fmovimi%TYPE;   -- Bug 26151 - APD - 26/02/2013
      vfmovimi_max   movseguro.fmovimi%TYPE;   -- Bug 26151 - APD - 26/02/2013
   BEGIN
-------------------------------------------------------------
-- Comprobar si esta permitido el rechazo.
      vpasexec := 1;

      SELECT cempres, sproduc, ncertif
        INTO n_emp, n_pro, vncertif
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;
      num_err := pac_cfg.f_get_user_accion_permitida(f_user, 'RECHAZO_MOV', n_pro, n_emp,
                                                     n_rea);

      IF num_err = 0 THEN
         num_err := 9901023;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

-------------------------------------------------------------
-- Este movimiento no se puede anular
      IF pnmovimi = 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104620);
         RAISE e_object_error;
      END IF;

-------------------------------------------------------------
-- Solo se puede rechazar el ¿ltimo movimiento.
      vpasexec := 3;
      -- CONF-274-25/11/2016-JLTS- Se adiciona la variavle pac_suspension.vcod_reinicio
      IF vncertif <> 0
         AND pcmotmov IN(391, pac_suspension.vcod_reinicio)
         AND pnorec = 1 THEN
         --No hacemos nada
         NULL;
      ELSE
         SELECT DECODE(COUNT(1), 0, 0, 9901021)
           INTO num_err
           FROM movseguro
          WHERE sseguro = psseguro
            AND cmovseg <> 52
            AND nmovimi > pnmovimi;

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;
      END IF;

-------------------------------------------------------------
-- Si existe algun recibo cobrado, no se puede rechazar.
-- (exceptuamos los recibos cobrados con s¿lo prima devendada).
      vpasexec := 4;
      --CONF-220 KJSC Anular suplementos con recibos cobrados
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),'REC_COBRADO'),0) = 0 THEN
         SELECT DECODE(COUNT(1), 0, 0, 9001636)
           INTO num_err
           FROM recibos a
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND f_cestrec(nrecibo, NULL) = 1
            AND NOT EXISTS(SELECT 1
                             FROM vdetrecibos x
                            WHERE x.nrecibo = a.nrecibo
                              AND x.iprinet = 0);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;
      END IF;
--Bug 41801/233886 - AMC - 27/04/2016
     -- Si el movimiento tiene un recibo con impresion retenida no se puede anular el movimiento
     SELECT DECODE(COUNT(1), 0, 0, 9908981)
        INTO num_err
        FROM recibos a
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi
         and a.cestimp = 3
         AND NOT EXISTS(SELECT 1
                          FROM vdetrecibos x
                         WHERE x.nrecibo = a.nrecibo
                           AND x.iprinet = 0);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;
      --Fi Bug 41801/233886 - AMC - 27/04/2016
-------------------------------------------------------------
-- Bug 26151 - APD - 26/02/2013 - se debe comentar esta validacion ya que ahora
-- si se permite rechazar movimientos del certificado 0 que son los que tienen
-- recibos agrupados
-- Si es un recibo agrupado, de momento no permitimos.
      vpasexec := 5;

      IF pskip = 0 THEN
         SELECT DECODE(COUNT(1), 0, 0, 9001160)
           INTO num_err
           FROM recibos a, adm_recunif b
          WHERE a.sseguro = psseguro
            AND a.nmovimi = pnmovimi
            AND a.nrecibo IN(b.nrecibo, b.nrecunif)
            AND pac_seguros.f_get_escertifcero(NULL, a.sseguro) <> 1;

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;
      END IF;

    -- fin Bug 26151 - APD - 26/02/2013
-------------------------------------------------------------
-- Bug 20664 - APD - 27/12/2011 - s¿lo se debe permitir anular movimientos
-- de suplementos (cmovseg = 1) y cartera (cmovseg = 2) (detvalores = 16)
-- hay algunos suplementos que tampoco se debe permitir anular su movimiento
-- cmotmov = 221.-Anulaci¿n programada al vencimiento
-- cmotmov = 236.-Anulaci¿n programada al pr¿ximo recibo
-- cmotmov = 261.-Pignoraciones
-- cmotmov = 262.-Bloqueos
-- cmotmov = 263.-Despignoraciones
-- cmotmov = 264.-Desbloqueos
      vpasexec := 6;

      SELECT cmovseg
        INTO vcmovseg
        FROM movseguro
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi;

      IF (vcmovseg NOT IN(1, 2, 6)   --JRH 03/2015 regularizaci¿n anulaci¿n
          OR pcmotmov IN(221, 236, 261, 262, 263, 264)) THEN
         num_err := 104620;   -- Este movimiento no se puede anular
      END IF;

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

-- fin Bug 20664 - APD - 27/12/2011

      -- Bug 26151 - APD - 26/02/2013 - se modifica esta validacion pues no todos los
      -- movimientos del certificado 0 no se pueden anular
      IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', n_pro) = 1
         AND vncertif = 0
         AND pac_seguros.f_es_col_agrup(psseguro) = 1 THEN
         --BUG 22839 - 22/10/2012 - JRB - Los movimientos del certificado 0 no se deben poder anular.

         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104620);
         --RAISE e_object_error;
         -- Bug 26151 - APD - 26/02/2013 - no se puede rechazar un movimiento del certificado 0
         -- si existen movimientos en sus n certificados con fefecto > a la fefecto del
         -- movimiento del 0
         -- Esta validacion sirve para controlar en el caso de productos Agrupados
         -- que no se pueda rechazar el suplemento realizado en el certificado 0 y que
         -- ya ha sido ejecutado en sus n certificados ya que era un suplemento que
         -- se tenia que propagar a sus n certificados
         SELECT fmovimi
           INTO vfmovimi_0
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         SELECT MAX(m.fmovimi)
           INTO vfmovimi_max
           FROM seguros s, movseguro m
          WHERE s.sseguro = m.sseguro
            AND s.npoliza IN(SELECT s2.npoliza
                               FROM seguros s2
                              WHERE s2.sseguro = psseguro)
            AND s.ncertif <> 0
            AND m.cmovseg <> 52;

         IF vfmovimi_max > vfmovimi_0 THEN
            num_err := 104620;   -- Este movimiento no se puede anular
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;
      -- fi Bug 26151 - APD - 26/02/2013
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END val_rechazo;

   /*************************************************************************
      Genera el rechazo.
      param in     psseguro : C¿digo del seguro
      param in     pcmotmov : C¿digo del motivo
      param in     pnsuplem : N¿mero suplemento
      param in     paccion  : Acci¿n (3) si es rechazo ¿ (4) anulaci¿n del suplemento
      param in     ptobserv : Observaciones
      param in     pnmovimi : N¿mero movimiento
      param in     pnorec:    No tratamiento de recibos
      param in out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION gen_rechazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      pnmovimi IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes,
      pnorec IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'seg=' || psseguro || ' mot=' || pcmotmov || ' sup=' || pnsuplem || ' acc='
            || paccion || ' mov=' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_RECHAZO.gen_rechazo';
      num_err        NUMBER;
   BEGIN
      num_err := pk_rechazo_movimiento.f_rechazo(psseguro, pcmotmov, pnsuplem, paccion,
                                                 ptobserv, pnmovimi, pnorec);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END gen_rechazo;

   FUNCTION f_gen_rechazo_col(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      pnmovimi IN NUMBER DEFAULT NULL,
      pfemisio IN DATE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes,
      pnorec IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'seg=' || psseguro || ' mot=' || pcmotmov || ' acc=' || paccion || ' mov='
            || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_RECHAZO.f_gen_rechazo_col';
      num_err        NUMBER;
      n_sup          NUMBER;
      vcmotmov       movseguro.cmotmov%TYPE;
      vcmovseg       movseguro.cmovseg%TYPE;
      vfefecto       seguros.fefecto%TYPE;
      vnmovimi       movseguro.nmovimi%TYPE;
      vcaccion       NUMBER;
      vterror        VARCHAR2(1000);
      vnmovimi_rehabilita NUMBER;   -- Bug 0029665/172570 - 14/04/2014
   BEGIN
      vpasexec := 1;

      -- movimiento del certficado 0 emitido
      IF pfemisio IS NOT NULL THEN
         -- si el movimiento del certificado 0 est¿ emitido (ser¿ el movimiento de
         -- 'Abrir suplemento' con cmotven = 998) todos los movimientos generados
         -- en sus n certificados estaran insertados en la tabla detmovsegurocol
         FOR reg IN (SELECT sseguro_cert, nmovimi_cert
                       FROM detmovsegurocol
                      WHERE sseguro_0 = psseguro
                        AND nmovimi_0 = pnmovimi) LOOP
            vpasexec := 2;

            SELECT cmotmov, cmovseg
              INTO vcmotmov, vcmovseg
              FROM movseguro
             WHERE sseguro = reg.sseguro_cert
               AND nmovimi = reg.nmovimi_cert;

            vpasexec := 3;

            IF vcmotmov = 100 THEN   -- Movimiento de Alta
               vpasexec := 4;

               SELECT fefecto
                 INTO vfefecto
                 FROM seguros
                WHERE sseguro = reg.sseguro_cert;

               vpasexec := 5;
               num_err := pac_iax_anulaciones.f_anulacion_poliza(reg.sseguro_cert, 4, vfefecto,
                                                                 396, NULL, 1, 1, NULL, NULL,
                                                                 0, 0, mensajes, 1, 0);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;

               -- Se cambia el cmotmov a 306 ya que aunque se ha hecho una anulacion inmediata (ctipanu = 4)
               -- realmente se queria hacer una anulacion al efecto (ctipanu = 1) pero se hace la inmediata
               -- ya que al no pasarle los recibos por parametro no hace nada con los recibos y eso es lo
               -- que se querie en este caso
               SELECT MAX(nmovimi)
                 INTO vnmovimi
                 FROM movseguro
                WHERE sseguro = reg.sseguro_cert;

               UPDATE movseguro
                  SET cmotmov = 306
                WHERE sseguro = reg.sseguro_cert
                  AND nmovimi = vnmovimi;

               -- se guarda en detmovsegurocol la relacion del certificado 0 con el nuevo
               -- movimiento generado en el certificado n
               num_err := pac_seguros.f_set_detmovsegurocol(psseguro, pnmovimi,
                                                            reg.sseguro_cert, vnmovimi);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;
            ELSIF vcmovseg IN(1, 2, 6) THEN   --JRH Regularizacion
               -- V.F. 16
               -- Movimiento de suplemento (cmovseg = 1)
               -- Movimiento de renovacion (cmovseg = 2)
               vpasexec := 6;
               num_err := pac_md_rechazo.val_rechazo(reg.sseguro_cert, pcmotmov,
                                                     reg.nmovimi_cert, paccion, ptobserv,
                                                     mensajes, 1);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;

               vpasexec := 7;

               SELECT MAX(nsuplem)
                 INTO n_sup
                 FROM movseguro
                WHERE sseguro = reg.sseguro_cert
                  AND nmovimi = reg.nmovimi_cert;

               vpasexec := 8;
               num_err := pac_md_rechazo.gen_rechazo(reg.sseguro_cert, pcmotmov, n_sup,
                                                     paccion, ptobserv, reg.nmovimi_cert,
                                                     mensajes, pnorec);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;
            ELSIF vcmovseg = 3 THEN
               -- V.F. 16
               -- Movimiento de anulacion (cmovseg = 3)
               num_err := pac_md_rehabilita.f_valida_rehabilita(reg.sseguro_cert, mensajes);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;

               num_err := pac_md_rehabilita.f_rehabilitapol(reg.sseguro_cert, 720, 1, mensajes,
                                                            0);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;

               SELECT MAX(nmovimi)
                 INTO vnmovimi
                 FROM movseguro
                WHERE sseguro = reg.sseguro_cert
                  AND cmovseg <> 52;

               -- Bug 0029665/172570 - 14/04/2014 - INI
               UPDATE movseguro
                  SET cmovseg = 52
                WHERE sseguro = reg.sseguro_cert
                  AND nmovimi = vnmovimi;

               DELETE      historicoseguros
                     WHERE sseguro = reg.sseguro_cert
                       AND nmovimi = vnmovimi - 1;

               UPDATE movseguro
                  SET cmovseg = 52
                WHERE sseguro = reg.sseguro_cert
                  AND nmovimi = reg.nmovimi_cert;

               DELETE      historicoseguros
                     WHERE sseguro = reg.sseguro_cert
                       AND nmovimi = reg.nmovimi_cert - 1;

               -- Bug 0029665/172570 - 14/04/2014 - FIN

               -- se guarda en detmovsegurocol la relacion del certificado 0 con el nuevo
               -- movimiento generado en el certificado n
               num_err := pac_seguros.f_set_detmovsegurocol(psseguro, pnmovimi,
                                                            reg.sseguro_cert, vnmovimi);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;
            END IF;
         END LOOP;
      ELSE
         -- movimiento del certficado 0 NO emitido
         BEGIN
            SELECT m.fmovimi
              INTO vfefecto
              FROM movseguro m
             WHERE m.sseguro = psseguro
               AND m.nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vfefecto := f_sysdate;
         END;

         -- si el movimiento del certificado 0 NO est¿ emitido (ser¿ el movimiento de
         -- 'Abrir suplemento' con cmotven = 998) NO estaran los movimientos generados
         -- en sus n certificados insertados en la tabla detmovsegurocol.
         -- Asi que se deben buscar aquellos n certificados del certificado 0
         -- que se hayan dado de alta, se haya realizado un suplemento, que se hayan
         -- dado de baja,...(mismo cursor que en pac_md_produccion.f_emitir_col_admin)
         FOR reg IN (SELECT sseguro sseguro_cert, csituac, creteni, npoliza, ncertif
                       FROM seguros
                      WHERE npoliza = (SELECT s2.npoliza
                                         FROM seguros s2
                                        WHERE s2.sseguro = psseguro)
                        AND ncertif <> 0
                        AND((csituac = 4
                             AND creteni IN(0, 2))
                            OR(csituac = 5)
                            OR(csituac = 2
                               AND EXISTS(SELECT 1
                                            FROM movseguro
                                           WHERE sseguro = seguros.sseguro
                                             AND cmovseg = 3
                                             AND fmovimi >= vfefecto
                                             AND nmovimi NOT IN(
                                                   SELECT nmovimi_cert
                                                     FROM detmovsegurocol
                                                    WHERE sseguro_0 = psseguro
                                                      AND sseguro_cert = seguros.sseguro))))) LOOP
            SELECT MAX(nmovimi)
              INTO vnmovimi
              FROM movseguro
             WHERE sseguro = reg.sseguro_cert
               AND cmovseg <> 52;

            IF reg.csituac IN(4, 5) THEN   -- v.f. 61
               IF reg.csituac = 4 THEN   -- prop. alta
                  vcaccion := 4;   -- rechazo de propuesta
               ELSIF reg.csituac = 5 THEN   -- prop. suplem.
                  vcaccion := 3;   -- rechazo de suplemento
               END IF;

               vpasexec := 6;

               IF reg.csituac = 5 THEN   -- prop. suplem.
                  num_err := pac_md_rechazo.val_rechazo(reg.sseguro_cert, pcmotmov, vnmovimi,
                                                        vcaccion, ptobserv, mensajes);

                  IF num_err <> 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                     vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                     EXIT;
                  END IF;
               END IF;

               vpasexec := 7;

               SELECT MAX(nsuplem)
                 INTO n_sup
                 FROM movseguro
                WHERE sseguro = reg.sseguro_cert
                  AND nmovimi = vnmovimi;

               vpasexec := 8;
               num_err := pac_md_rechazo.gen_rechazo(reg.sseguro_cert, pcmotmov, n_sup,
                                                     vcaccion, ptobserv, vnmovimi, mensajes,
                                                     pnorec);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;
            ELSIF reg.csituac = 2 THEN   -- Anulada
               num_err := pac_md_rehabilita.f_valida_rehabilita(reg.sseguro_cert, mensajes);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;

               --Pasamos el ptratar_recibo=1 porque si estamos rehabilitando es que se ha anulado y al igual hay recibos de extorno a anular o a crear otros de pago
               num_err := pac_md_rehabilita.f_rehabilitapol(reg.sseguro_cert, 720, 1, mensajes,
                                                            1);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  vterror := f_axis_literales(102829) || f_formatopolseg(reg.sseguro_cert);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vterror);
                  EXIT;
               END IF;

               -- Bug 0029665/172570 - 14/04/2014 - INI
               SELECT MAX(nmovimi)
                 INTO vnmovimi_rehabilita
                 FROM movseguro
                WHERE sseguro = reg.sseguro_cert
                  AND cmovseg <> 52;

               UPDATE movseguro
                  SET cmovseg = 52
                WHERE sseguro = reg.sseguro_cert
                  AND nmovimi = vnmovimi_rehabilita;

               DELETE      historicoseguros
                     WHERE sseguro = reg.sseguro_cert
                       AND nmovimi = vnmovimi_rehabilita - 1;

               UPDATE movseguro
                  SET cmovseg = 52
                WHERE sseguro = reg.sseguro_cert
                  AND nmovimi = vnmovimi;

               DELETE      historicoseguros
                     WHERE sseguro = reg.sseguro_cert
                       AND nmovimi = vnmovimi - 1;
            -- Bug 0029665/172570 - 14/04/2014 - FIN
            END IF;
         END LOOP;
      END IF;

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_gen_rechazo_col;

   /*************************************************************************
      Acciones del rechazo de colectivos
      param in     psseguro : C¿digo del seguro
      param in     pcmotmov : C¿digo del motivo
      param in     pnmovimi : N¿mero movimiento
      param in     paccion  : Acci¿n (3) si es rechazo ¿ (4) anulaci¿n del suplemento
      param in     ptobserv : Observaciones
      param in out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION rechazo_col(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pnorec IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'seg=' || psseguro || ' mot=' || pcmotmov || ' mov=' || pnmovimi || ' acc='
            || paccion;
      vobject        VARCHAR2(200) := 'PAC_MD_RECHAZO.rechazo_col';
      num_err        NUMBER;
      n_sup          NUMBER;
      vcmotven       movseguro.cmotven%TYPE;
      vcmotmov       detmovseguro.cmotmov%TYPE;
      vcont          NUMBER;
      vnmovimi_ant   detmovseguro.nmovimi%TYPE;
      vfefecto       seguros.fefecto%TYPE;
      vfemisio       movseguro.femisio%TYPE;
      v_csituac      seguros.csituac%TYPE;
      v_cmotmov      movseguro.cmotmov%TYPE;
   BEGIN
      vpasexec := 1;

      -- Se debe distinguir si el suplemento que se quiere anular, en el caso de que sea
      -- un suplemento de tipo 'Abrir suplemento' sea porque se ha creado automaticamente
      -- (caso de los suplementos que se realizan en el certifcado 0 y se propagan a sus
      -- hijos) o porque se ha pulsado manualmente el boton 'Abrir Suplemento'
      BEGIN
         SELECT cmotven, femisio, cmotmov
           INTO vcmotven, vfemisio, v_cmotmov
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;
      EXCEPTION
         WHEN OTHERS THEN
            vcmotven := NULL;
      END;

      vpasexec := 2;

      BEGIN
         SELECT csituac
           INTO v_csituac
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            v_csituac := NULL;
      END;

      IF v_csituac = 4
         AND v_cmotmov = 100 THEN
         vpasexec := 6;

         SELECT MAX(nsuplem)
           INTO n_sup
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         vpasexec := 7;
         num_err := pac_md_rechazo.gen_rechazo(psseguro, pcmotmov, n_sup, paccion, ptobserv,
                                               pnmovimi, mensajes, pnorec);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         RETURN 0;
      END IF;

      IF NVL(vcmotven, 0) = 998 THEN
         -- En el caso que el movimiento que se quiere anular es de tipo 'Abrir suplemento',
         -- se mira si su movimiento anterior tenia que progagar el suplemento a sus
         -- n certificados. Si es asi, nos indica que el suplemento 'Abrir suplemento'
         -- se creado automaticamente, por lo que se debe anular este movimiento y
         -- el anterior.
         vpasexec := 3;

         SELECT COUNT(1)
           INTO vcont
           FROM detmovseguro d, movseguro m
          WHERE d.sseguro = m.sseguro
            AND d.nmovimi = m.nmovimi
            AND m.sseguro = psseguro
            AND m.nmovimi = pnmovimi - 1
            AND NVL(d.cpropagasupl, 0) IN(1, 3);
      END IF;

      vpasexec := 4;

      -- Caso de suplemento 'Abrir suplemento' creado automaticamente
      IF vcont <> 0 THEN
         vpasexec := 5;
         -- Se valida si se puede rechazar el movimiento
         num_err := pac_md_rechazo.val_rechazo(psseguro, pcmotmov, pnmovimi, paccion,
                                               ptobserv, mensajes);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 6;
         -- Se rechazan los movimientos generados en los certificados del certificado 0
         num_err := pac_md_rechazo.f_gen_rechazo_col(psseguro, pcmotmov, paccion, ptobserv,
                                                     pnmovimi, vfemisio, mensajes, pnorec);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 7;

         -- Si se ha propagado el suplemento a sus n certficados, primero se debe anular el suplemento
         -- 'Abrir suplemento' y luego rechazar el suplemento
         SELECT MAX(nsuplem)
           INTO n_sup
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         vpasexec := 8;
         num_err := pac_md_rechazo.gen_rechazo(psseguro, pcmotmov, n_sup, paccion, ptobserv,
                                               pnmovimi, mensajes, pnorec);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 9;
         -- Se valida si se puede rechazar el movimieno anterior (el que realmente es el del
         -- suplemento del 0)
         vnmovimi_ant := pnmovimi - 1;
         vpasexec := 10;
         num_err := pac_md_rechazo.val_rechazo(psseguro, pcmotmov, vnmovimi_ant, paccion,
                                               ptobserv, mensajes);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 11;

         -- Se rechaza el movimiento anterior (el que realmente es el del
         -- suplemento del 0)
         SELECT MAX(nsuplem)
           INTO n_sup
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = vnmovimi_ant;

         vpasexec := 12;
         num_err := pac_md_rechazo.gen_rechazo(psseguro, pcmotmov, n_sup, paccion, ptobserv,
                                               vnmovimi_ant, mensajes, pnorec);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         -- Caso de suplemento 'Abrir suplemento' creado manualmente
         vpasexec := 13;
         -- Se valida si se puede rechazar el movimiento
         num_err := pac_md_rechazo.val_rechazo(psseguro, pcmotmov, pnmovimi, paccion,
                                               ptobserv, mensajes);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 14;

         --BUG 29229 - INICIO - DCT - 09/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
         -- Se rechazan los movimientos generados en los certificados del certificado 0
         IF pcmotmov <> 403 THEN
            num_err := pac_md_rechazo.f_gen_rechazo_col(psseguro, pcmotmov, paccion, ptobserv,
                                                        pnmovimi, vfemisio, mensajes, pnorec);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

         --BUG 29229 - FIN - DCT - 09/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
         SELECT MAX(nsuplem)
           INTO n_sup
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         vpasexec := 15;
         -- Se rechaza el movimiento del certificado 0
         num_err := pac_md_rechazo.gen_rechazo(psseguro, pcmotmov, n_sup, paccion, ptobserv,
                                               pnmovimi, mensajes, pnorec);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END rechazo_col;

   /*************************************************************************
      Acciones del rechazo.
      param in     psseguro : C¿digo del seguro
      param in     pcmotmov : C¿digo del motivo
      param in     pnmovimi : N¿mero movimiento
      param in     paccion  : Acci¿n (3) si es rechazo ¿ (4) anulaci¿n del suplemento
      param in     ptobserv : Observaciones
      param in out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION rechazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pnorec IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'seg=' || psseguro || ' mot=' || pcmotmov || ' mov=' || pnmovimi || ' acc='
            || paccion;
      vobject        VARCHAR2(200) := 'PAC_MD_RECHAZO.rechazo';
      num_err        NUMBER;
      n_sup          NUMBER;
      vsproduc       seguros.sproduc%TYPE;
      vncertif       seguros.ncertif%TYPE;
      vcmotven       movseguro.cmotven%TYPE;
   BEGIN
      vpasexec := 1;

      -- Bug 26151 - APD - 27/02/2013
      BEGIN
         SELECT sproduc, ncertif
           INTO vsproduc, vncertif
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            vpasexec := 2;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101919);
            RAISE e_object_error;
      END;

      -- fin Bug 26151 - APD - 27/02/2013
      vpasexec := 3;

      -- Bug 26151 - APD - 27/02/2013 - si el producto 'ADMITE_CERTIFICADOS' = 1 y
      -- es el certificado 0 y es un producto Administrado
      IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', vsproduc) = 1
         AND vncertif = 0
         AND pac_seguros.f_es_col_admin(psseguro) = 1 THEN
         -- caso de la productos Administrados en el que:
         -- 1. o se ha realizado un suplemento en el certificado 0 y ese suplemento se ha podido
         -- propagar a sus n certificados, y por eso se ha generado automaticamente el suplemento
         -- de 'Abrir suplemento' en el certificado 0
         -- 2. o se ha generado manualmente el suplemento de 'Abrir suplemento' en el certificado 0
         -- porque se queria modificar alguno de sus n certificados, ya sea dar de alta un nuevo n
         -- certificado, dar de baja un n certificado, realizar un suplemento en un n certificado, ...
         vpasexec := 4;
         num_err := pac_md_rechazo.rechazo_col(psseguro, pcmotmov, pnmovimi, paccion,
                                               ptobserv, mensajes, pnorec);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         mensajes := NULL;
      ELSE
         -- fin Bug 26151 - APD - 27/02/2013
         vpasexec := 5;
         num_err := pac_md_rechazo.val_rechazo(psseguro, pcmotmov, pnmovimi, paccion,
                                               ptobserv, mensajes, NULL, pnorec);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 6;

         SELECT MAX(nsuplem)
           INTO n_sup
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         vpasexec := 7;
         num_err := pac_md_rechazo.gen_rechazo(psseguro, pcmotmov, n_sup, paccion, ptobserv,
                                               pnmovimi, mensajes, pnorec);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END rechazo;
END pac_md_rechazo;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_RECHAZO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RECHAZO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RECHAZO" TO "PROGRAMADORESCSI";
