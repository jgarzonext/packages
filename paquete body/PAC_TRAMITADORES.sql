--------------------------------------------------------
--  DDL for Package Body PAC_TRAMITADORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_TRAMITADORES" AS
/******************************************************************************
      NOMBRE:       PAC_TRAMITADORES
      PROPÃ“SITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor   Descripcion
     ---------  ----------  ------   ------------------------------------
      1.0        07/05/2012   AMC     1. Creacion del package.
      2.0        06/08/2012   ASN     0023101: LCOL_S001-SIN - Apuntes de agenda automáticos
      3.0        04/11/2014   JTT     0033298/0190844: Corrección de la funcion F_anula_msg_asignacion

   ******************************************************************************/

   /*************************************************************************
        FUNCTION f_get_tramitador
        Recupera el nombre del tramitador
        param in pctramitad  : codi tramitador
        param in  out pttramitad  : Nombre de tramitador
        param out mensajes : missatges d'error
        return             : refcursor
   *************************************************************************/
   FUNCTION f_get_tramitador(pctramitad IN VARCHAR2, pttramitad IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT codt.ttramitad
        INTO pttramitad
        FROM sin_codtramitador codt
       WHERE ctramitad = pctramitad;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_TRAMITADORES.f_get_tramitador', 1,
                     'Error no controlado SQLERRM:', SQLERRM);
         RETURN SQLERRM;
   END f_get_tramitador;

     /*************************************************************************
        FUNCTION f_cambio_tramitador
        Inserta el movimiento de cambio de tramitador
        param in pctramitad  : codi tramitador
        param in pcunitra : codi de la unidad de tramitacion
        param in pctramitad : codi del tramitador
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_cambio_tramitador(
      psiniestros IN VARCHAR2,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2)
      RETURN NUMBER IS
      vpsiniestros   VARCHAR2(4000);
      vpsiniestro    VARCHAR2(100);
      vpos           NUMBER;
      vcesttra       NUMBER;
      vcsubtra       NUMBER;
      vccauest       NUMBER;
      vsini          VARCHAR2(100);
      vtrami         VARCHAR2(100);
      vnumerr        NUMBER;
      vnmovtra       NUMBER;
   BEGIN
      vpsiniestros := psiniestros;

      LOOP
         EXIT WHEN NVL(INSTR(vpsiniestros, '|'), 0) = 0;
         vpsiniestro := SUBSTR(vpsiniestros, 1,(INSTR(vpsiniestros, '|') - 1));
         vpos := INSTR(vpsiniestros, '|') + 1;
         vpsiniestros := SUBSTR(vpsiniestros, vpos, LENGTH(vpsiniestros));

         SELECT SUBSTR(vpsiniestro, 1, INSTR(vpsiniestro, '#') - 1)
           INTO vsini
           FROM DUAL;

         SELECT SUBSTR(vpsiniestro, INSTR(vpsiniestro, '#') + 1)
           INTO vtrami
           FROM DUAL;

         SELECT cesttra, csubtra
           INTO vcesttra, vcsubtra
           FROM sin_tramita_movimiento
          WHERE nsinies = vsini
            AND ntramit = TO_NUMBER(vtrami)
            AND nmovtra = (SELECT MAX(nmovtra)
                             FROM sin_tramita_movimiento
                            WHERE nsinies = vsini
                              AND ntramit = TO_NUMBER(vtrami));

         vccauest := 101;   --Cambio de tramitador
         vnumerr := pac_siniestros.f_ins_tramita_movimiento(vsini, vtrami, pcunitra,
                                                            pctramitad, vcesttra, vcsubtra,
                                                            f_sysdate, vnmovtra, vccauest);
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_TRAMITADORES.f_cambio_tramitador', 1,
                     'Error no controlado SQLERRM:', SQLERRM);
         RETURN SQLERRM;
   END f_cambio_tramitador;

    /*************************************************************************
        FUNCTION f_mensaje_asignacion
        Inserta mensaje en la agenda cuando se asigna un tramite/tramitacion
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        param in pctramitad  : codi tramitador
        param in pcunitra : codi de la unidad de tramitacion
        param in pctramitad : codi del tramitador
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_mensaje_asignacion(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pntramit IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vcusuari       sin_codtramitador.cusuari%TYPE;
      vcempres       NUMBER;
      vcidioma       NUMBER;
      vtitulo        VARCHAR2(100);
      vcuerpo        VARCHAR2(2000);
      vidapunte      NUMBER;
      vslittit       NUMBER;
      vslitbod       NUMBER;
      num_err        NUMBER;
      vapunte_repetido NUMBER;
      vntramit       NUMBER;   -- ASN:13/11/2012
   BEGIN
      IF pac_sin_tramite.ff_hay_tramites(pnsinies) = 1 THEN
         vslittit := 9904097;   -- Tramite asignado
         vslitbod := 9904097;
      ELSE
         vslittit := 9904098;   -- Tramitacion asignada
         vslitbod := 9904098;
      END IF;

      IF pntramit IS NULL THEN   -- ASN:13/11/2012
         SELECT MIN(t.ntramit)
           INTO vntramit
           FROM sin_tramitacion t, sin_tramita_movimiento m
          WHERE m.nsinies = t.nsinies
            AND t.nsinies = pnsinies
            AND m.cesttra = 0;
      ELSE
         vntramit := pntramit;
      END IF;

      vpasexec := 2;

      SELECT t.cusuari, u.cempres, u.cidioma
        INTO vcusuari, vcempres, vcidioma
        FROM sin_codtramitador t, usuarios u
       WHERE t.cusuari = u.cusuari
         AND t.ctramitad = pctramitad;

      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'TRAMITADORES'), 0) <> 1 THEN
         RETURN 0;
      END IF;

      vpasexec := 3;

      SELECT f_axis_literales(vslittit, vcidioma)
        INTO vtitulo
        FROM DUAL;

      vpasexec := 4;

      SELECT f_axis_literales(vslitbod, vcidioma)
        INTO vcuerpo
        FROM DUAL;

      vpasexec := 5;
      num_err := f_apunte_repetido(vcusuari, pnsinies, 1, 0, vtitulo, vapunte_repetido);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF vapunte_repetido > 0 THEN
         RETURN 0;
      END IF;

      vpasexec := 6;
      num_err := pac_agenda.f_set_apunte(NULL, NULL, 0,   -- Código Clave Agenda 0:siniestro / 1:poliza
                                         pnsinies, 1,   -- tarea
                                         0, NULL,   -- tipo de grupo
                                         NULL,   -- grupo asignado
                                         vtitulo, vcuerpo, 0, 0, NULL, NULL, f_user, NULL,
                                         f_sysdate, f_sysdate, NULL, vidapunte);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      vpasexec := 7;
      num_err := pac_agenda.f_set_agenda(vidapunte, NULL, vcusuari, NULL, NULL, 0, pnsinies,
                                         NULL, NULL, NULL, NULL, vcempres, vcidioma, 'NUEVA_TAREA',
                                         vntramit);   -- ASN:13/11/2012

--                                         pntramit);
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_tramitadores.f_mensaje_asignacion', vpasexec,
                     'pnsinies=' || pnsinies || ' pntramte=' || pntramte || ' pntramit='
                     || pntramit || ' pcunitra=' || pcunitra || ' pctramitad=' || pctramitad,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9903168;
   END f_mensaje_asignacion;

   /*************************************************************************
        FUNCTION f_apunte_repetido
        Comprueba si ya hay un apunte igual en la agenda de un tramitador
        param in pcusuari  : codigo usuario
        param in pnsinies  : Numero siniestro
        param in pcconapu  : concepto apunte
        param in pctipapu  : tipo de apunte
        param in pttitulo  : titulo apunte
        param out apunte_repetido : 1=si 0=no
   *************************************************************************/
   FUNCTION f_apunte_repetido(
      pcusuari IN VARCHAR2,
      pnsinies IN VARCHAR2,
      pcconapu IN NUMBER,
      pctipapu IN NUMBER,
      pttitulo IN VARCHAR2,
      papunte_repetido OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      papunte_repetido := 0;

      FOR i IN (SELECT g.idapunte
                  FROM agd_agenda g, agd_movagenda m
                 WHERE m.idagenda = g.idagenda
                   AND m.idapunte = g.idapunte
                   AND m.cusuari_dest = pcusuari
                   AND TRUNC(g.falta) = TRUNC(f_sysdate)
                   AND g.cclagd = 0
                   AND g.tclagd = pnsinies) LOOP
         BEGIN
            SELECT COUNT(*)
              INTO papunte_repetido
              FROM agd_apunte a
             WHERE a.idapunte = i.idapunte
               AND a.cconapu = pcconapu
               AND a.ctipapu = pctipapu
               AND a.ttitapu = pttitulo;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               papunte_repetido := 0;
               NULL;
         END;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_tramitadores.f_apunte_repetido', 1,
                     'pnsinies=' || pnsinies || ' pcusuari=' || pcusuari || ' pcconapu='
                     || pcconapu || ' pctipapu=' || pctipapu || ' pttitulo=' || pttitulo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
   END f_apunte_repetido;

   /****************************************************************************
   Replica un apunte cuando el destinatario es tramitador global en las agendas
   de los tramitadores de todas las tramitaciones abiertas
      23101:ASN:31/07/2012
   ****************************************************************************/
   FUNCTION f_replica_apunte(pidapunte IN NUMBER, pcempres IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      vtraza         NUMBER;
      vidagenda      NUMBER;
      vcusuari       VARCHAR2(20);
      vctipapu       NUMBER;
      vtitulo        VARCHAR2(100);
      vcuerpo        VARCHAR2(2000);
      vfrecordatorio DATE;
      vcusualt       VARCHAR2(20);
      vfalta         DATE;
      vidapunte      NUMBER;
      vnsinies       VARCHAR2(40);
      vctramitad     VARCHAR2(20);
   BEGIN
      vtraza := 0;

      SELECT idagenda
        INTO vidagenda
        FROM agd_agenda
       WHERE idapunte = pidapunte;

      vtraza := 1;

      SELECT cusuari_dest, tclagd
        INTO vcusuari, vnsinies
        FROM agd_agenda age, agd_movagenda mva
       WHERE age.idagenda = vidagenda
         AND age.idapunte = pidapunte
         AND age.idapunte = mva.idapunte
         AND age.idagenda = mva.idagenda
         AND mva.nmovagd = (SELECT MAX(mva2.nmovagd)
                              FROM agd_movagenda mva2
                             WHERE mva2.idagenda = vidagenda
                               AND mva2.idapunte = pidapunte);

      vtraza := 2;

      SELECT tdor.cusuari
        INTO vctramitad
        FROM sin_movsiniestro m, sin_codtramitador tdor
       WHERE m.ctramitad = tdor.ctramitad
         AND nsinies = vnsinies
         AND nmovsin = (SELECT MAX(nmovsin)
                          FROM sin_movsiniestro m1
                         WHERE m1.nsinies = m.nsinies);

      IF vctramitad = vcusuari THEN   -- el destinatario del mensaje es el tramitador global del siniestro
         vtraza := 3;

         SELECT ctipapu, ttitapu, tapunte, frecordatorio, cusualt, falta
           INTO vctipapu, vtitulo, vcuerpo, vfrecordatorio, vcusualt, vfalta
           FROM agd_apunte
          WHERE idapunte = pidapunte;

         FOR i IN (SELECT DISTINCT tdor.cusuari, m.ntramit
                              FROM sin_tramita_movimiento m, sin_codtramitador tdor
                             WHERE m.ctramitad = tdor.ctramitad
                               AND m.nsinies = vnsinies
                               AND m.cesttra = 0
                               AND m.nmovtra = (SELECT MAX(m1.nmovtra)
                                                  FROM sin_tramita_movimiento m1
                                                 WHERE m1.nsinies = m.nsinies)) LOOP   -- Para los tramitadores de tramitaciones abiertas en el mismo siniestro
            IF i.cusuari <> vcusuari THEN
               num_err :=
                  pac_agenda.f_set_apunte(NULL,   -- id apunte nulo para que lo cree nuevo
                                          NULL,   -- id agenda
                                          0,   -- Código Clave Agenda 0:siniestro / 1:poliza
                                          vnsinies,   -- clave
                                          0,   -- concepto apunte
                                          0,   -- estado apunte
                                          NULL,   -- tipo de grupo
                                          NULL,   -- grupo asignado
                                          vtitulo,   -- titulo apunte
                                          vcuerpo,   -- mensaje
                                          vctipapu, 0, NULL, NULL, vcusualt, NULL, f_sysdate,
                                          vfalta, vfrecordatorio, vidapunte);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               num_err :=
                  pac_agenda.f_set_agenda(vidapunte, NULL, i.cusuari, NULL,   -- tipo grupo
                                          NULL,   -- grupo asignado grupo
                                          0,   -- Código Clave Agenda 0:siniestro / 1:poliza
                                          vnsinies,   -- clave
                                          NULL, NULL,   -- usuario origen
                                          NULL,   -- tipo de grupo origen
                                          NULL,
                                          -- grupo origen
                                          pcempres, pcidioma, NULL, i.ntramit);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_replica_apunte', vtraza,
                     ' pidapunte=' || pidapunte, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN SQLCODE;
   END f_replica_apunte;

   /****************************************************************************
    Traspasa los apuntes abiertos a la agenda del nuevo tramitador
       23101:ASN:31/07/2012
   ****************************************************************************/
   FUNCTION f_traspasa_agenda(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnmovtra IN NUMBER,
      pcuniori IN VARCHAR2,
      pctramiori IN VARCHAR2,
      pcunidest IN VARCHAR2,
      pctramidest IN VARCHAR2)
      RETURN NUMBER IS
      vmov_anterior  NUMBER;
      vusuori        VARCHAR2(20);
      vusudest       VARCHAR2(20);
      vntramte       NUMBER;
      vnmovtte       NUMBER;
      num_err        NUMBER;
      vtraza         NUMBER;
      vcgrupo_ori    VARCHAR2(40);
      --
      ya_existe      NUMBER;
      vctipapu       NUMBER;
      vtitulo        VARCHAR2(100);
      vcuerpo        VARCHAR2(2000);
      vfrecordatorio DATE;
      vcusualt       VARCHAR2(20);
      vfalta         DATE;
      vidapunte      NUMBER;
      vnsinies       VARCHAR2(40);
      vcestapu       NUMBER;
      es_msg_asignacion NUMBER;   -- 23101:ASN:12/11/2012
   BEGIN
      IF pnmovtra = 1 THEN
         RETURN 0;
      END IF;

      /*IF pcuniori IS NULL
         OR pctramiori IS NULL
         OR pcunidest IS NULL
         OR pctramidest IS NULL THEN   -- alta movimiento de tramitacion
         vtraza := 1;

         SELECT MAX(nmovtra)
           INTO vmov_anterior
           FROM sin_tramita_movimiento
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND nmovtra < pnmovtra;

         SELECT cusuari
           INTO vusuori
           FROM sin_codtramitador
          WHERE ctramitad = (SELECT ctramitad
                               FROM sin_tramita_movimiento
                              WHERE nsinies = pnsinies
                                AND ntramit = pntramit
                                AND nmovtra = vmov_anterior);

         vtraza := 2;

         SELECT cusuari
           INTO vusudest
           FROM sin_codtramitador
          WHERE ctramitad = (SELECT ctramitad
                               FROM sin_tramita_movimiento
                              WHERE nsinies = pnsinies
                                AND ntramit = pntramit
                                AND nmovtra = pnmovtra);
      ELSE */
      IF pac_sin_tramite.ff_hay_tramites(pnsinies) = 0 THEN
         vtraza := 1;

         SELECT cusuari
           INTO vusudest
           FROM sin_tramita_movimiento tm1, sin_codtramitador ct
          WHERE tm1.ctramitad = ct.ctramitad
            AND tm1.nsinies = pnsinies
            AND tm1.ntramit = pntramit
            AND tm1.nmovtra = pnmovtra;

         vtraza := 2;

         SELECT cusuari
           INTO vusuori
           FROM sin_tramita_movimiento tm1, sin_codtramitador ct
          WHERE tm1.ctramitad = ct.ctramitad
            AND tm1.nsinies = pnsinies
            AND tm1.ntramit = pntramit
            AND tm1.nmovtra = (SELECT MAX(nmovtra)
                                 FROM sin_tramita_movimiento
                                WHERE nsinies = pnsinies
                                  AND ntramit = pntramit
                                  AND nmovtra < pnmovtra);
      ELSE   -- si hay tramites. el tramitador no esta en la tramitacion, sino en el tramite
         vtraza := 3;

         SELECT ntramte
           INTO vntramte
           FROM sin_tramitacion
          WHERE nsinies = pnsinies
            AND ntramit = pntramit;

         vtraza := 4;

         SELECT cusuari, tm1.nmovtte
           INTO vusudest, vnmovtte
           FROM sin_tramite_mov tm1, sin_codtramitador ct
          WHERE tm1.ctramitad = ct.ctramitad
            AND tm1.nsinies = pnsinies
            AND tm1.ntramte = vntramte
            AND tm1.nmovtte = (SELECT MAX(nmovtte)
                                 FROM sin_tramite_mov tm2
                                WHERE tm2.nsinies = tm1.nsinies
                                  AND tm2.ntramte = tm1.ntramte);

         vtraza := 5;

         SELECT cusuari
           INTO vusuori
           FROM sin_tramite_mov tm1, sin_codtramitador ct
          WHERE tm1.ctramitad = ct.ctramitad
            AND tm1.nsinies = pnsinies
            AND tm1.ntramte = vntramte
            AND tm1.nmovtte = (SELECT MAX(nmovtte)
                                 FROM sin_tramite_mov tm2
                                WHERE tm2.nsinies = tm1.nsinies
                                  AND tm2.ntramte = tm1.ntramte
                                  AND tm2.nmovtte < vnmovtte);
      END IF;

--      END IF;
      IF vusuori = vusudest THEN
         RETURN 0;
      END IF;

      FOR i IN (SELECT a.idagenda, a.idapunte, m.cusuari_ori, m.cgrupo_ori, m.tgrupo_ori,
                       p.ttitapu
                  FROM agd_agenda a, agd_movagenda m, agd_apunte p
                 WHERE m.idagenda = a.idagenda
                   AND m.idapunte = a.idapunte
                   AND m.cusuari_dest = vusuori
                   AND a.cclagd = 0
                   AND a.tclagd = pnsinies
                   AND m.nmovagd = (SELECT MAX(nmovagd)
                                      FROM agd_movagenda m1
                                     WHERE m1.idagenda = m.idagenda
                                       AND m1.idapunte = m.idapunte)
                   AND p.idapunte = a.idapunte
                   AND a.ntramit = pntramit   -- ASN:13/11/2012
/*
             AND p.ttitapu NOT IN(SELECT tlitera
                                    FROM axis_literales
                                   WHERE slitera IN(9904097, 9904098))   -- no se traspasa el mensaje de asignacion
*/
              ) LOOP
         -- 23101:ASN:12/11/2012 ini
         vtraza := 30;

         SELECT COUNT(*)
           INTO es_msg_asignacion
           FROM axis_literales
          WHERE tlitera LIKE i.ttitapu || '%'
            AND slitera IN(9904097, 9904098);

         IF es_msg_asignacion > 0 THEN   -- es el mensaje de asignacion
            vtraza := 31;

            SELECT m.cestapu
              INTO vcestapu
              FROM agd_movapunte m
             WHERE m.idapunte = i.idapunte
               AND m.nmovapu = (SELECT MAX(mo.nmovapu)
                                  FROM agd_movapunte mo
                                 WHERE mo.idapunte = m.idapunte);

            vtraza := 32;

            IF vcestapu = 0 THEN   -- finalizamos el apunte de asignacion original
               num_err := pac_agenda.f_set_movapunte(i.idapunte, NULL, 2, f_sysdate, NULL,
                                                     NULL);
            END IF;

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSE
            -- 23101:ASN:12/11/2012 fin
            vtraza := 33;

            SELECT COUNT
                      (*)   -- comprobamos que no estamos traspasando un apunte que ya esta en la agenda de destino
              INTO ya_existe
              FROM agd_movagenda a
             WHERE a.idapunte = i.idapunte
               AND a.cusuari_dest = vusudest
               AND a.nmovagd = (SELECT MAX(a1.nmovagd)
                                  FROM agd_movagenda a1
                                 WHERE a1.idapunte = a.idapunte);

            IF ya_existe = 0 THEN
               vtraza := 34;

               SELECT m.cestapu
                 INTO vcestapu
                 FROM agd_movapunte m
                WHERE m.idapunte = i.idapunte
                  AND m.nmovapu = (SELECT MAX(mo.nmovapu)
                                     FROM agd_movapunte mo
                                    WHERE mo.idapunte = m.idapunte);

               IF vcestapu = 0 THEN   -- solo traspasamos apuntes sin finalizar
                  vtraza := 35;
                  num_err := pac_agenda.f_set_movagenda(i.idapunte, i.idagenda, NULL, NULL,
                                                        i.cusuari_ori, i.cgrupo_ori,
                                                        i.tgrupo_ori, vusudest, NULL, NULL);
               END IF;
            END IF;

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_traspasa_agenda', vtraza,
                     'pnsinies=' || pnsinies || ' pntramit=' || pntramit || ' pnmovtra='
                     || pnmovtra || ' pcuniori=' || pcuniori || ' pctramiori=' || pctramiori
                     || ' pcunidest=' || pcunidest || ' pctramidest=' || pctramidest,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN SQLCODE;
   END f_traspasa_agenda;

    /*************************************************************************
        FUNCTION f_reasignacion
        Comprueba si ha habido cambio de tramitador y realiza las acciones pertinentes
        param in pnsinies    : numero siniestro
        param in pntramit    : numero tramitacion
        param in pnmovimi    : numero de movimiento
        param in pcunitra    : codigo de la unidad de tramitacion
        param in pctramitad  : codigo del tramitador
        return               : 0 - OK , SQLERRM - KO
   *************************************************************************/
   FUNCTION f_reasignacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnmovimi IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2)
      RETURN NUMBER IS
      vmov_anterior  NUMBER;
      vcunitra_ant   VARCHAR2(4);
      vctramitad_ant VARCHAR2(4);
      vcambio        NUMBER;
      num_err        NUMBER;
      vpasexec       NUMBER;
      dummy          NUMBER;
   BEGIN
      IF pnsinies IS NULL
         OR pntramit IS NULL THEN
         RETURN 9000505;
      END IF;

      IF pnmovimi = 1 THEN
         vcambio := 1;
      ELSE
         vpasexec := 1;

         SELECT MAX(nmovtra)
           INTO vmov_anterior
           FROM sin_tramita_movimiento
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND nmovtra < pnmovimi;

         vpasexec := 2;

         SELECT ctramitad
           INTO vctramitad_ant
           FROM sin_tramita_movimiento
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND nmovtra = pnmovimi - 1;

         IF vctramitad_ant = pctramitad THEN
            vcambio := 0;
         ELSE
            vcambio := 1;
         END IF;
      END IF;

      IF vcambio = 0 THEN
         RETURN 0;
      END IF;

      vpasexec := 5;
      -- enviamos tarea a la agenda del tramitador
      num_err := pac_tramitadores.f_mensaje_asignacion(pnsinies, NULL, pntramit, pcunitra,
                                                       pctramitad);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- traspasamos los apuntes abiertos a la agenda del nuevo tramitador
      vpasexec := 6;
      num_err := pac_tramitadores.f_traspasa_agenda(pnsinies, pntramit, pnmovimi, NULL, NULL,
                                                    NULL, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      vpasexec := 7;

      IF vctramitad_ant IS NOT NULL THEN
         -- Anulamos el mensaje de asignacion original
         num_err := pac_tramitadores.f_anula_msg_asignacion(vctramitad_ant, pnsinies,
                                                            pntramit);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_tramitadores.f_reasignacion', vpasexec,
                     'pnsinies=' || pnsinies || ' pntramit=' || pntramit || ' pnmovimi='
                     || pnmovimi || ' pcunitra=' || pcunitra || ' pctramitad=' || pctramitad,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN SQLCODE;
   END f_reasignacion;

    /*************************************************************************
        FUNCTION f_mensaje_siniestro
        Inserta mensaje en la agenda del tramitador
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        param in pctramitad  : codi tramitador
        param in pcunitra : codi de la unidad de tramitacion
        param in pctramitad : codi del tramitador
        param in pcconapu  : tipo apunte
        param in pslittit  : literal titulo
        param in pslitbod  : literal body
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_mensaje_siniestro(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pntramit IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pcconapu IN NUMBER,
      pslittit IN NUMBER,
      pslitbod IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vcusuari       sin_codtramitador.cusuari%TYPE;
      vcempres       NUMBER;
      vcidioma       NUMBER;
      vtitulo        VARCHAR2(100);
      vcuerpo        VARCHAR2(2000);
      vidapunte      NUMBER;
      vslittit       NUMBER;
      vslitbod       NUMBER;
      num_err        NUMBER;
      vapunte_repetido NUMBER;
   BEGIN
      vpasexec := 1;

      SELECT t.cusuari, u.cempres, u.cidioma
        INTO vcusuari, vcempres, vcidioma
        FROM sin_codtramitador t, usuarios u
       WHERE t.cusuari = u.cusuari
         AND t.ctramitad = pctramitad;

      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'TRAMITADORES'), 0) <> 1 THEN
         RETURN 0;
      END IF;

      vpasexec := 2;

      SELECT f_axis_literales(pslittit, vcidioma)
        INTO vtitulo
        FROM DUAL;

      IF pslittit = pslitbod THEN
         vcuerpo := vtitulo;
      ELSE
         vpasexec := 4;

         SELECT f_axis_literales(pslitbod, vcidioma)
           INTO vcuerpo
           FROM DUAL;
      END IF;

      vpasexec := 5;
      num_err := f_apunte_repetido(vcusuari, pnsinies, 0, 0, vtitulo, vapunte_repetido);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF vapunte_repetido > 0 THEN
         RETURN 0;
      END IF;

      vpasexec := 6;
      num_err := pac_agenda.f_set_apunte(NULL, NULL, 0,   -- Código Clave Agenda 0:siniestro / 1:poliza
                                         pnsinies, pcconapu, 0, NULL,   -- tipo de grupo
                                         NULL,   -- grupo asignado
                                         vtitulo, vcuerpo, 0, 0, NULL, NULL, f_user, NULL,
                                         f_sysdate, f_sysdate, NULL, vidapunte);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      vpasexec := 7;
      num_err := pac_agenda.f_set_agenda(vidapunte, NULL, vcusuari, NULL, NULL, 0, pnsinies,
                                         NULL, NULL, NULL, NULL, vcempres, vcidioma, NULL,
                                         pntramit);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_tramitadores.f_mensaje_siniestro', vpasexec,
                     'pnsinies=' || pnsinies || ' pntramte=' || pntramte || ' pntramit='
                     || pntramit || ' pcunitra=' || pcunitra || ' pctramitad=' || pctramitad,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9903168;
   END f_mensaje_siniestro;

    /*************************************************************************
        FUNCTION f_msg_tramitador_global
        Inserta mensaje en la agenda del tramitador global del siniestro
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        param in pcconapu  : tipo apunte
        param in pslittit  : literal titulo
        param in pslitbod  : literal body
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_msg_tramitador_global(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pntramit IN NUMBER,
      pcconapu IN NUMBER,
      pslittit IN NUMBER,
      pslitbod IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vctramitad     sin_codtramitador.ctramitad%TYPE;
      vcunitra       sin_tramita_movimiento.cunitra%TYPE;
      vcempres       NUMBER;
      vcidioma       NUMBER;
      vtitulo        VARCHAR2(100);
      vcuerpo        VARCHAR2(2000);
      num_err        NUMBER;
   BEGIN
      vpasexec := 1;
      -- recuperamos el tramitador global del siniestro
      num_err := pac_siniestros.f_get_tramitador(pnsinies, NULL, NULL, vcunitra, vctramitad);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_mensaje_siniestro(pnsinies, NULL, pntramit, vcunitra, vctramitad, pcconapu,
                                     pslittit, pslitbod);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_tramitadores.f_msg_tramitador_global', vpasexec,
                     'pnsinies=' || pnsinies || ' pntramte=' || pntramte || ' pntramit='
                     || pntramit,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9903168;
   END f_msg_tramitador_global;

    /*************************************************************************
        FUNCTION f_msg_responsable
        Inserta mensaje en la agenda del responsable de siniestros
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        param in pcconapu  : tipo apunte
        param in pslittit  : literal titulo
        param in pslitbod  : literal body
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_msg_responsable(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pntramit IN NUMBER,
      pcconapu IN NUMBER,
      pslittit IN NUMBER,
      pslitbod IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
--      vctramitad     sin_codtramitador.ctramitad%TYPE;
--      vcunitra       sin_tramita_movimiento.cunitra%TYPE;
      vcusuari       usuarios.cusuari%TYPE;
      vcempres       NUMBER;
      vcidioma       NUMBER;
      vtitulo        VARCHAR2(100);
      vcuerpo        VARCHAR2(2000);
      vidapunte      agd_apunte.idapunte%TYPE;
      num_err        NUMBER;
   BEGIN
      vpasexec := 1;

      SELECT se.cempres
        INTO vcempres
        FROM sin_siniestro si, seguros se
       WHERE si.sseguro = se.sseguro
         AND si.nsinies = pnsinies;

      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'TRAMITADORES'), 0) <> 1 THEN
         RETURN 0;
      END IF;

      vpasexec := 2;

      BEGIN
         SELECT tvalpar
           INTO vcusuari
           FROM parempresas
          WHERE cempres = vcempres
            AND cparam = 'RESPONSABLE_SINIS';
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
      END;

      vpasexec := 3;

      SELECT cidioma
        INTO vcidioma
        FROM usuarios
       WHERE cusuari = vcusuari;

      vpasexec := 4;

      SELECT f_axis_literales(pslittit, vcidioma)
        INTO vtitulo
        FROM DUAL;

      IF pslittit = pslitbod THEN
         vcuerpo := vtitulo;
      ELSE
         vpasexec := 5;

         SELECT f_axis_literales(pslitbod, vcidioma)
           INTO vcuerpo
           FROM DUAL;
      END IF;

      vpasexec := 6;
      num_err := pac_agenda.f_set_apunte(NULL, NULL, 0,   -- Código Clave Agenda 0:siniestro / 1:poliza
                                         pnsinies, pcconapu, 0, NULL,   -- tipo de grupo
                                         NULL,   -- grupo asignado
                                         vtitulo, vcuerpo, 0, 0, NULL, NULL, f_user, NULL,
                                         f_sysdate, f_sysdate, NULL, vidapunte);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      vpasexec := 7;
      num_err := pac_agenda.f_set_agenda(vidapunte, NULL, vcusuari, NULL, NULL, 0, pnsinies,
                                         NULL, NULL, NULL, NULL, vcempres, vcidioma, NULL,
                                         NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_tramitadores.f_msg_responsable', vpasexec,
                     'pnsinies=' || pnsinies || ' pntramte=' || pntramte || ' pntramit='
                     || pntramit,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9903168;
   END f_msg_responsable;

    /*************************************************************************
        FUNCTION f_anula_msg_asignacion
        Anula el mensaje de asignacion si procede
        param in pctramitad: tramitador
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_anula_msg_asignacion(
      pctramitad IN VARCHAR2,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER)
      RETURN NUMBER IS
      v_pasexec      NUMBER := 1;
      v_cuantos      NUMBER;
      v_idapunte     agd_apunte.idapunte%TYPE;
      v_nmovapu      agd_movapunte.nmovapu%TYPE;
      v_cusuari      agd_movagenda.cusuari_dest%TYPE;
   BEGIN
      -- primero se comprueba si el tramitador tiene otras tramitaciones asignadas en el mismo siniestro
      SELECT COUNT(*)
        INTO v_cuantos
        FROM sin_tramita_movimiento m1
       WHERE m1.ctramitad = pctramitad
         AND m1.nsinies = pnsinies
         AND m1.ntramit <> pntramit
         AND m1.nmovtra = (SELECT MAX(m2.nmovtra)
                             FROM sin_tramita_movimiento m2
                            WHERE m2.nsinies = m1.nsinies
                              AND m2.ntramit = m1.ntramit);

      -- si hay mas, no hacemos nada
      IF v_cuantos > 0 THEN
         RETURN 0;
      END IF;

      v_pasexec := 2;

      SELECT t.cusuari
        INTO v_cusuari
        FROM sin_codtramitador t, usuarios u
       WHERE t.cusuari = u.cusuari
         AND t.ctramitad = pctramitad;

      v_pasexec := 3;

      -- si no hay mas tramitaciones, anulamos el mensaje de asignacion original
      -- Bug 33298 - 04/11/2014 - JTT: Recuperamos el idapunto original (menor)
      SELECT MIN(ap.idapunte)
        INTO v_idapunte
        FROM agd_agenda ag, agd_apunte ap, agd_movagenda ma
       WHERE ag.idapunte = ap.idapunte
         AND ag.cclagd = 0   -- siniestro
         AND ag.tclagd = pnsinies
         AND ap.ctipapu = 0   -- automaitco
         AND ap.ttitapu IN(SELECT tlitera
                             FROM axis_literales
                            WHERE slitera IN(9904097, 9904098))
         AND ma.idagenda = ag.idagenda
         AND ma.cusuari_dest = v_cusuari;

      v_pasexec := 4;

      SELECT MAX(nmovapu) + 1
        INTO v_nmovapu
        FROM agd_movapunte
       WHERE idapunte = v_idapunte;

      v_pasexec := 5;

      INSERT INTO agd_movapunte
                  (idapunte, nmovapu, cestapu, festapu, cusualt, falta)
           VALUES (v_idapunte, v_nmovapu, 1, f_sysdate, f_user, f_sysdate);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_anula_msg_asignacion', v_pasexec,
                     'pctramitad=' || pctramitad || ' pnsinies=' || pnsinies || ' pntramit='
                     || pntramit,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001719;
   END f_anula_msg_asignacion;
END pac_tramitadores;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRAMITADORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRAMITADORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRAMITADORES" TO "PROGRAMADORESCSI";
