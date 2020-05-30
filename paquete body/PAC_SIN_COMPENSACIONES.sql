--------------------------------------------------------
--  DDL for Package Body PAC_SIN_COMPENSACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIN_COMPENSACIONES" IS
/******************************************************************************
   NOMBRE    : PAC_SIN_COMPENSACIONES
   ARCHIVO   : PAC_SIN_COMPENSACIONES.pkb
   PROPÓSITO : Package con funciones propias de la funcionalidad de Compensaciones en siniestros

REVISIONES:
   Ver    Fecha       Autor     Descripción
   ------ ----------  --------- ------------------------------------------------
   1.0    22-01-2014  JTT       Creación del package.
   2.0    20-08-2015  ACL       33884/212340: Corregir la llamada a la función F_INS_PAGO, añadiendo el parámetro ncheque.
******************************************************************************/
   e_error        EXCEPTION;

   FUNCTION f_valida_siniestro_muerte(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pexisten IN OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_COMPENSACIONES.f_valida_siniestro_muerte';
      vparam         VARCHAR2(500) := ' pnsinies = ' || pnsinies;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      IF pnsinies IS NULL THEN
         vnumerr := 9000505;
         RAISE e_error;
      END IF;

      pexisten := 0;

      SELECT COUNT(1)
        INTO pexisten
        FROM parproductos p, sin_siniestro ss, seguros s
       WHERE ss.nsinies = pnsinies
         AND s.sseguro = ss.sseguro
         AND p.sproduc = s.sproduc
         AND p.cparpro = 'COMPENSACION_DEUDA'
         AND NVL(cvalpar, 0) = 1;

      IF pexisten = 0 THEN
         RETURN 0;
      END IF;

      vpasexec := 2;

      /*
         Contamos el numero de garantias en el siniestro que causara la anlacion de la poliza
         (cmotfin = 505) al finalizarse el siniestro.
      */
      SELECT COUNT(1)
        INTO pexisten
        FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm, sin_siniestro s, seguros ss,
             sin_tramita_reserva r
       WHERE sgcm.scaumot = scm.scaumot
         AND sgcm.sproduc = ss.sproduc
         AND sgcm.cgarant = r.cgarant
         AND scm.ccausin = s.ccausin
         AND scm.cmotsin = s.cmotsin
         AND ss.sseguro = s.sseguro
         AND r.nsinies = s.nsinies
         AND s.nsinies = pnsinies
         AND scm.cmotfin = 505;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     ' Error = ' || vnumerr || ' -  ' || f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_valida_siniestro_muerte;

   FUNCTION f_valida_reserva_noindem(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pexisten IN OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_COMPENSACIONES.f_valida_reserva_noindem';
      vparam         VARCHAR2(500) := ' pnsinies = ' || pnsinies;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      IF pnsinies IS NULL THEN
         vnumerr := 9000505;
         RAISE e_error;
      END IF;

      /*
         Contamos el numero de reservas no indemnizatorias
      */
      SELECT COUNT(1)
        INTO pexisten
        FROM sin_tramita_reserva r
       WHERE r.nsinies = pnsinies
         AND r.ctipres <> 1
         AND r.ireserva > 0
         AND r.nmovres = (SELECT MAX(nmovres)
                            FROM sin_tramita_reserva
                           WHERE idres = r.idres);

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     ' Error = ' || vnumerr || ' -  ' || f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_valida_reserva_noindem;

   FUNCTION f_crear_pago_compensatorio_cia(
      pnsinies IN sin_tramita_reserva.nsinies%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      pipago IN NUMBER,
      psperson IN sin_tramita_destinatario.sperson%TYPE,
      psidepag_nou OUT sin_tramita_pago.sidepag%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pnrecibo IN recibos.nrecibo%TYPE,
      pcestcomp IN sin_recibos_compensados.cestcomp%TYPE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_COMPENSACIONES.f_crear_pago_compensatorio_cia';
      vparam         VARCHAR2(500)
         := 'pnsinies = ' || pnsinies || ' pidres = ' || pidres || ' pipago = ' || pipago
            || ' psperson = ' || psperson || ' pnrecibo = ' || pnrecibo || ' pcestcomp = '
            || pcestcomp;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER;
      vnmovpag       sin_tramita_movpago.nmovpag%TYPE;
      vnmovres       sin_tramita_reserva.nmovres%TYPE;
      vres           sin_tramita_reserva%ROWTYPE;
      vccc           per_ccc%ROWTYPE;
      vsidepag       sin_tramita_pago.sidepag%TYPE;
      vsinterf       NUMBER;
      vcconpag       sin_tramita_pago.cconpag%TYPE := 191;   -- Indemnizacion
      vccauind       sin_tramita_pago.ccauind%TYPE := 7;   -- pàgo indemnizatorio
   BEGIN
      IF pnsinies IS NULL
         OR pidres IS NULL
         OR pipago IS NULL
         OR psperson IS NULL
         OR psseguro IS NULL
         OR pnrecibo IS NULL
         OR pcestcomp IS NULL THEN
         vnumerr := 9000505;
         RAISE e_error;
      END IF;

      vpasexec := 1;
      vnumerr := pac_siniestros.f_getrow_reserva(pnsinies, pidres, vres);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      vpasexec := 2;

      BEGIN
         SELECT *
           INTO vccc
           FROM per_ccc
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- Si no encontramos la CCC correspondiente a la Cia no la informamos, no es necesaria.
            NULL;
      END;

      vpasexec := 4;
      -- Movvimiento de disminucion de la reserva por pago
      vnumerr := pac_siniestros.f_ins_reserva(vres.nsinies,   --pnsinies
                                              vres.ntramit,   -- pntramit
                                              vres.ctipres,   --pctipres
                                              vres.cgarant,   --pcgarant
                                              1,   -- ctipcal
                                              f_sysdate,   --fmovres
                                              vres.cmonres,   --pcmonres
                                              NVL(vres.ireserva, 0) - pipago,   --pireserva
                                              NVL(vres.ipago, 0) + pipago,   --pipago
                                              vres.icaprie,   --picaprie
                                              vres.ipenali,   --pipenali
                                              vres.iingreso,   --piingreso
                                              vres.irecobro,   --piingreso
                                              vres.fresini,   --pfresini
                                              vres.fresfin,   --pfresfin
                                              NULL,   --pfultpag
                                              NULL,   --psidepag
                                              vres.iprerec,   --piprerec
                                              vres.ctipgas,   --pctipgas
                                              vnmovres,   --pcmovres
                                              4   --cmovres
                                               );

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      vpasexec := 5;
      -- Creacion de la cabecera del pago
      vsidepag := NULL;
      vnumerr :=
         pac_siniestros.f_ins_pago(vsidepag,   -- sidepag
                                   vres.nsinies,   -- nsinies
                                   vres.ntramit,   -- ntramit
                                   psperson,   -- sperson destinatario
                                   4,   -- ctipdes CIA
                                   2,   -- ctippag PAGO
                                   vcconpag,   -- cconpag  Indemnizacion
                                   vccauind,   -- ccauind,   Pago indemnizatorio
                                   31,   -- cforpag, Transferencia ACH
                                   TRUNC(f_sysdate),   -- fordpag,
                                   vccc.ctipban,   -- ctipban,
                                   vccc.cbancar,   -- cbancar,
                                   pipago,   -- isinret,
                                   0,   -- piretenc
                                   0,   -- iiva
                                   0,   -- isuplid
                                   0,   -- ifranq
                                   0,   -- iresrcm
                                   0,   -- iresred
                                   NULL,   -- nfacref
                                   NULL,   -- ffacref
                                   1,   -- sidepagtemp  --> Solicitud de creacion de nuevo pago
                                   NULL,   -- cultpag  --> Es ultimo pago
                                   NULL,   -- ncheque  -- Bug 33884/212340 ACL
                                   0,   -- ireteiva
                                   0,   -- ireteica
                                   0,   -- ireteivapag
                                   0,   -- ireteicapag
                                   0,   -- iica
                                   0,   -- iicapag
                                   vres.cmonres);   -- pcmonres

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      vpasexec := 6;
      --  Movimiento inicial del pago (pago Aceptado)
      vnmovpag := 0;   -- Movimiento inicial
      vnumerr := pac_siniestros.f_ins_movpago(vsidepag, 1, f_sysdate, 1, NULL, NULL, 0,
                                              vnmovpag, 0, 0);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      vpasexec := 7;
      -- Creacion del detalle del pago
      vnumerr :=
         pac_siniestros.f_ins_pago_gar
                       (vres.nsinies,   --nsinies
                        vres.ntramit,   --ntramit
                        vsidepag,   --sidepag
                        vres.ctipres,   --ctipres
                        vnmovres - 1,   -- nmovres (Correspondiente al movimiento de reserva previo)
                        vres.cgarant,   -- cgarant
                        NULL,   --fresini
                        NULL,   --fresfin
                        vres.cmonres,   --cmonres
                        pipago,   --isinret
                        0,   --iiva
                        0,   --isuplid,
                        0,   --iretenc,
                        0,   --ifranq,
                        0,   --iresrcm,
                        0,   --iresred,
                        NULL,   --pretenc,
                        0,   --piva,
                        vres.cmonres, pipago,   --isinretpag,
                        0,   --iivapag,
                        0,   --isuplidpag,
                        0,   --iretencpag,
                        0,   --ifranqpag,
                        TRUNC(f_sysdate),   --fcambio,
                        vcconpag,   --pcconpag
                        1,   --pnordem
                        NULL,   --preteiva,
                        NULL,   --preteica,  sin_tramita_pago_gar
                        NULL,   --ireteiva,
                        NULL,   --ireteica,
                        NULL,   --ireteivapag,
                        NULL,   --ireteicapag,
                        NULL,   --pica,
                        NULL,   --iica,
                        NULL   --iicapag
                            );

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      vpasexec := 8;

      -- Insertamos en la tabla de compensacíon de pagos
      INSERT INTO sin_recibos_compensados
                  (nsinies, sseguro, sidepag_old, nrecibo, sidepag_new, irestorec, cestcomp)
           VALUES (pnsinies, psseguro, 0, pnrecibo, vsidepag, 0, pcestcomp);

      vpasexec := 9;
      -- Comunicamos el pago al SAP, el pago pasa a estado 'Remesado'
      vnumerr := pac_siniestros.f_gestiona_cobpag(vsidepag, vnmovpag, 1, TRUNC(f_sysdate),
                                                  NULL, vsinterf);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      psidepag_nou := vsidepag;
      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     ' Error = ' || vnumerr || ' -  ' || f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_crear_pago_compensatorio_cia;

   FUNCTION f_recibos_no_emitidos(
      psseguro IN seguros.sseguro%TYPE,
      pnrecfut OUT NUMBER,
      pirecfut OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_COMPENSACIONES.f_recibos_no_emitidos';
      vparam         VARCHAR2(500) := ' psseguro = ' || psseguro;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnrecibo       NUMBER;
      virecibo       NUMBER;
      vfultrec       DATE;
      vcduraci       seguros.cduraci%TYPE;
      vcforpag       seguros.cforpag%TYPE;
      vfcaranu       seguros.fcaranu%TYPE;
      vfvencim       seguros.fvencim%TYPE;
   BEGIN
      IF psseguro IS NULL THEN
         vnumerr := 9000505;
         RAISE e_error;
      END IF;

      pnrecfut := 0;
      pirecfut := 0;

      SELECT fcaranu, fvencim, cforpag, cduraci
        INTO vfcaranu, vfvencim, vcforpag, vcduraci
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      IF vcforpag = 0 THEN
         -- Si es prima unica no hay recibos pendientes de emitir hasta la proxima renovacion de cartera
         pnrecfut := 0;
         pirecfut := 0;
         RETURN 0;
      END IF;

      vpasexec := 3;

      BEGIN
         SELECT r.nrecibo, v.itotalr, r.fefecto
           INTO vnrecibo, virecibo, vfultrec
           FROM recibos r, vdetrecibos v
          WHERE r.nrecibo = (SELECT MAX(nrecibo)
                               FROM recibos
                              WHERE ctiprec IN(0, 3)
                                AND sseguro = psseguro)
            AND v.nrecibo = r.nrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9907545;
      END;

      vpasexec := 4;

      BEGIN
         IF vcduraci IN(0   -- Anual renovable
                         , 6   -- Temporal
                            ) THEN
            pnrecfut := TRUNC(MONTHS_BETWEEN(vfcaranu, vfultrec) /(12 / vcforpag)) - 1;
            pirecfut := ROUND(virecibo * pnrecfut, 2);
         ELSIF vcduraci IN(1   -- Años
                            , 2   -- Meses
                               , 3   -- Hasta vencimiento
                                  , 5   -- Años más 1 dia
                                     , 7   -- Hasta Edad
                                        ) THEN
            pnrecfut := TRUNC(MONTHS_BETWEEN(vfvencim, vfultrec) /(12 / vcforpag)) - 1;
            pirecfut := ROUND(virecibo * pnrecfut, 2);
         ELSIF vcduraci = 4 THEN   -- Vitalicio
            pnrecfut := 0;
            pirecfut := 0;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            vnumerr := 9907545;
            RAISE e_error;
      END;

      IF pnrecfut < 0 THEN
         pnrecfut := 0;
         pirecfut := 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     ' Error = ' || vnumerr || ' -  ' || f_axis_literales(vnumerr));
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     ' forma de pago =' || vcforpag || '  vcduraci= ' || vcduraci
                     || ' fcaranu= ' || vfcaranu || ' fvencim= ' || vfvencim || ' nrecibo= '
                     || vnrecibo);
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_recibos_no_emitidos;

   FUNCTION f_reducir_reserva(
      pnsinies IN sin_tramita_reserva.nsinies%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      pimporte IN NUMBER,
      pcmovres IN sin_tramita_reserva.cmovres%TYPE DEFAULT 3)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_COMPENSACIONES.f_reducir_reserva';
      vparam         VARCHAR2(500)
         := ' pnsinies = ' || pnsinies || ' pidres = ' || pidres || ' pimporte = ' || pimporte;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vres           sin_tramita_reserva%ROWTYPE;
      vnmovres       sin_tramita_reserva.nmovres%TYPE;
   BEGIN
      IF pnsinies IS NULL
         OR pidres IS NULL
         OR pimporte IS NULL THEN
         vnumerr := 9000505;
         RAISE e_error;
      END IF;

      vpasexec := 1;
      vnumerr := pac_siniestros.f_getrow_reserva(pnsinies, pidres, vres);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      vpasexec := 2;
      -- Movvimiento de disminucion de la reserva
      vnumerr := pac_siniestros.f_ins_reserva(vres.nsinies,   --pnsinies
                                              vres.ntramit,   -- pntramit
                                              vres.ctipres,   --pctipres
                                              vres.cgarant,   --pcgarant
                                              1,   -- ctipcal
                                              TRUNC(f_sysdate),   --fmovres
                                              vres.cmonres,   --pcmonres
                                              NVL(vres.ireserva, 0) - pimporte,   --pireserva
                                              vres.ipago,   --pipago
                                              vres.icaprie,   --picaprie
                                              vres.ipenali,   --pipenali
                                              vres.iingreso,   --piingreso
                                              vres.irecobro,   --piingreso
                                              vres.fresini,   --pfresini
                                              vres.fresfin,   --pfresfin
                                              NULL,   --pfultpag
                                              NULL,   --psidepag
                                              vres.iprerec,   --piprerec
                                              vres.ctipgas,   --pctipgas
                                              vnmovres,
                                              --pcmovres
                                              pcmovres   --cmovres
                                                      );
      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     ' Error = ' || vnumerr || ' -  ' || f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_reducir_reserva;
END pac_sin_compensaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_COMPENSACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_COMPENSACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_COMPENSACIONES" TO "PROGRAMADORESCSI";
