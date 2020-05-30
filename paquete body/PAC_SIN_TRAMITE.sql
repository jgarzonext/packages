--------------------------------------------------------
--  DDL for Package Body PAC_SIN_TRAMITE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIN_TRAMITE" IS
       /******************************************************************************
       NOMBRE:     PAC_SIN_TRAMITE
       PROPÓSITO:  Funciones para gestionar los trámites de siniestros

       REVISIONES:
       Ver        Fecha        Autor             Descripción
       ---------  ----------  ---------------  ------------------------------------
       1.0        17/02/2009  JMC              1. Creación del package. Bug 18363 LCOL710 Funciones grabar trámite.
       2.0        16/05/2012  JMF              0022099: MDP_S001-SIN - Trámite de asistencia
       3.0        14/06/2012  JMF              0022108 MDP_S001-SIN - Movimiento de trámites
   *******************************************************************************/
   FUNCTION f_ins_tramite(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctramte IN NUMBER,
      pntramte IN OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_TRAMITE.F_Ins_tramite';
      vparam         VARCHAR2(500)
         := 'parámetros - nsinies: ' || pnsinies || ' pntramte:' || pntramte || ' pctramte:'
            || pctramte;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL
         OR pctramte IS NULL THEN
         RETURN 9000505;
      END IF;

      vpasexec := 2;

      IF pntramte IS NULL THEN
         BEGIN
            SELECT NVL(MAX(ntramte) + 1, 0)
              INTO pntramte
              FROM sin_tramite
             WHERE nsinies = pnsinies;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pntramte := 0;
         END;
      END IF;

      BEGIN
         INSERT INTO sin_tramite
                     (nsinies, ntramte, ctramte)
              VALUES (pnsinies, pntramte, pctramte);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE sin_tramite
               SET ctramte = pctramte
             WHERE nsinies = pnsinies
               AND ntramte = pntramte;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9901986;   --Error al actualizar SIN_TRAMITE
   END f_ins_tramite;

   /*************************************************************************
      FUNCTION F_Ins_tramite_mov
         Inserta o modifica la tabla SIN_TRAMITE_MOV con los parámetros pasados.
         param in pnsinies   : número del sinistre
         param in pntramte   : numero tràmit sinistre
         param in pcesttte   : codi estat tràmit
         param in pCCAUEST   : Causa cambio de estado
         param in pCUNITRA   : Código de unidad de tramitación
         param in pCTRAMITAD : Código de tramitador
         param in pFESTTRA   : Fecha estado trámite
         param in out pnmovtte   : número moviment tràmit
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
      -- Bug 0022108 - 14/06/2012 - JMF
   *************************************************************************/
   FUNCTION f_ins_tramite_mov(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN NUMBER,
      pcesttte IN NUMBER,
      pccauest IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pfesttra IN DATE,
      pnmovtte IN OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_TRAMITE.f_ins_tramite_mov';
      vparam         VARCHAR2(500)
         := 'parámetros - nsinies: ' || pnsinies || ' pntramte:' || pntramte || ' pcesttte:'
            || pcesttte || ' pCCAUEST=' || pccauest || ' pCUNITRA=' || pcunitra
            || ' pCTRAMITAD=' || pctramitad || ' pFESTTRA=' || pfesttra || ' pnmovtte:'
            || pnmovtte;
      vpasexec       NUMBER(5) := 1;
      vcount         NUMBER(5);
      num_err        NUMBER;
   BEGIN
      vpasexec := 10;

      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL
         OR pntramte IS NULL
         OR pcesttte IS NULL THEN
         RETURN 9000505;
      END IF;

      IF pnmovtte IS NULL THEN
         BEGIN
            vpasexec := 20;

            SELECT NVL(MAX(nmovtte) + 1, 1)
              INTO pnmovtte
              FROM sin_tramite_mov
             WHERE nsinies = pnsinies
               AND ntramte = pntramte;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pnmovtte := 1;
         END;
      ELSIF pnmovtte = 0 THEN
         pnmovtte := 1;   -- 23514:ASN:27/08/2012
      END IF;

      BEGIN
         vpasexec := 30;

         INSERT INTO sin_tramite_mov
                     (nsinies, ntramte, nmovtte, cesttte, ccauest, cunitra, ctramitad,
                      festtra)
              VALUES (pnsinies, pntramte, pnmovtte, pcesttte, pccauest, pcunitra, pctramitad,
                      pfesttra);

         -- 23101:ASN:07/08/2012 ini
         num_err := pac_sin_tramite.f_asigna_tramitaciones(pnsinies, pntramte, pnmovtte,
                                                           pcunitra, pctramitad);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
         /* REASIGNAMOS TRAMITACION A TRAMITACION
         num_err := pac_tramitadores.f_reasignacion(pnsinies, pntramte, NULL, pnmovtte,
                                                    pcunitra, pctramitad);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
         */
      -- 23101:ASN:07/08/2012 fin
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            vpasexec := 40;

            UPDATE sin_tramite_mov
               SET cesttte = pcesttte,
                   ccauest = pccauest,
                   cunitra = pcunitra,
                   ctramitad = pctramitad,
                   festtra = pfesttra
             WHERE nsinies = pnsinies
               AND ntramte = pntramte
               AND nmovtte = pnmovtte;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9901987;   --Error al actualizar
   END f_ins_tramite_mov;

   /*************************************************************************
      FUNCTION f_get_tramite_mov
         Función que construye la select para obtener los datos necesarios para
         asignar los valores del objeto OB_IAX_TRAMITE_MOV.
         param in pnsinies   : número del sinistre
         param in pntramte   : numero tràmit sinistre
         param in pnmovtte   : número movimiento de trámite
         param in pcidioma   : código idioma
         param out psquery   : select
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_get_tramite_mov(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN NUMBER,
      pnmovtte IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(500) := 'PAC_SIN_TRAMITE.f_get_tramite_mov';
      vpar           VARCHAR2(500)
                                 := 's=' || pnsinies || ' t=' || pntramte || ' m=' || pnmovtte;
   BEGIN
      -- Bug 0022108 - 14/06/2012 - JMF
      psquery :=
         'SELECT mov.nsinies, mov.ntramte, mov.nmovtte,  mov.cesttte,'
         || ' ff_desvalorfijo(6,' || pcidioma || ', mov.cesttte) testtte,'
         || ' CCAUEST, CUNITRA, CTRAMITAD, FESTTRA,'
         || ' (SELECT ttramitad FROM sin_codtramitador tram WHERE tram.ctramitad = mov.cunitra) tunitra,'
         || ' (SELECT ttramitad FROM sin_codtramitador tram WHERE tram.ctramitad = mov.ctramitad) ttramitad,'
         || ' (SELECT sd.tcauest' || ' FROM sin_codcauest sc, sin_descauest sd'
         || ' WHERE sc.ccauest = sd.ccauest' || ' AND sc.cestsin = sd.cestsin'
         || ' AND sd.cidioma = ' || pcidioma || ' AND sc.ccauest = mov.ccauest'
         || ' AND sc.cestsin = DECODE(mov.CESTTTE, 0, 25, 1, 27, 3, 28, -1)) tcauest'
         || ' FROM sin_tramite_mov mov' || ' where mov.nsinies = ' || pnsinies
         || ' and mov.ntramte = ' || pntramte || ' and mov.nmovtte = ' || pnmovtte;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, 1, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_get_tramite_mov;

   /*************************************************************************
      FUNCTION f_get_tramite
         Función que construye la select para obtener los datos necesarios para
         asignar los valores del objeto OB_IAX_TRAMITE.
         param in pnsinies   : número del sinistre
         param in pntramte   : numero tràmit sinistre
         param in pcidioma   : código idioma
         param out psquery   : select
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_get_tramite(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vcagente       NUMBER;
   BEGIN
      psquery :=
         'SELECT tram.nsinies, tram.ntramte, tram.ctramte, dt.TTRAMITE
         FROM sin_destramite dt, sin_tramite tram where tram.nsinies = '
         || CHR(39) || pnsinies || CHR(39) || ' and tram.ntramte = ' || pntramte
         || ' and dt.ctramte = tram.ctramte and dt.cidioma=' || pcidioma;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_SIN_TRAMITE', 1, 'f_get_tramite', SQLERRM);
         RETURN 1;
   END f_get_tramite;

   -- BUG 21546_108727- 04/02/2012 - JLTS - Se cambia la utilizacion del objeto por parametros simples
   FUNCTION f_ins_tramite_recob(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN sin_tramite_recobro.ntramte%TYPE,
      pfprescrip IN sin_tramite_recobro.fprescrip%TYPE,
      pireclamt IN sin_tramite_recobro.ireclamt%TYPE,
      pirecobt IN sin_tramite_recobro.irecobt%TYPE,
      piconcurr IN sin_tramite_recobro.iconcurr%TYPE,
      pircivil IN sin_tramite_recobro.ircivil%TYPE,
      piassegur IN sin_tramite_recobro.iassegur%TYPE,
      pcresrecob IN sin_tramite_recobro.cresrecob%TYPE,
      pcdestim IN sin_tramite_recobro.cdestim%TYPE,
      pnrefges IN sin_tramite_recobro.nrefges%TYPE,
      pctiprec IN sin_tramite_recobro.ctiprec%TYPE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_TRAMITE.f_ins_tramite_recob';
      vparam         VARCHAR2(500) := 'parámetros - nsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vcount         NUMBER(5);
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL THEN
         RETURN 9000505;
      END IF;

      BEGIN
         INSERT INTO sin_tramite_recobro
                     (nsinies, ntramte, fprescrip, ireclamt, irecobt, iconcurr,
                      ircivil, iassegur, cresrecob, cdestim, nrefges, ctiprec)
              VALUES (pnsinies, pntramte, pfprescrip, pireclamt, pirecobt, piconcurr,
                      pircivil, piassegur, pcresrecob, pcdestim, pnrefges, pctiprec);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE sin_tramite_recobro
               SET fprescrip = pfprescrip,
                   ireclamt = pireclamt,
                   irecobt = pirecobt,
                   iconcurr = piconcurr,
                   ircivil = pircivil,
                   iassegur = piassegur,
                   cresrecob = pcresrecob,
                   cdestim = pcdestim,
                   nrefges = pnrefges,
                   ctiprec = pctiprec
             WHERE nsinies = pnsinies
               AND ntramte = pntramte;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9901987;   --Error al actualizar
   END f_ins_tramite_recob;

   -- BUG 21546_108727- 04/02/2012 - JLTS - Se cambia la utilizacion del objeto por parametros simples
   FUNCTION f_ins_tramite_lesiones(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN sin_tramite_lesiones.ntramte%TYPE,
      pnlesiones IN sin_tramite_lesiones.nlesiones%TYPE,
      pnmuertos IN sin_tramite_lesiones.nmuertos%TYPE,
      pagravantes IN sin_tramite_lesiones.agravantes%TYPE,
      pcgradoresp IN sin_tramite_lesiones.cgradoresp%TYPE,
      pctiplesiones IN sin_tramite_lesiones.ctiplesiones%TYPE,
      pctiphos IN sin_tramite_lesiones.ctiphos%TYPE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_TRAMITE.f_ins_tramite_lesiones';
      vparam         VARCHAR2(500) := 'parámetros - nsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vcount         NUMBER(5);
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL THEN
         RETURN 9000505;
      END IF;

      BEGIN
         INSERT INTO sin_tramite_lesiones
                     (nsinies, ntramte, nlesiones, nmuertos, agravantes, cgradoresp,
                      ctiplesiones, ctiphos)
              VALUES (pnsinies, pntramte, pnlesiones, pnmuertos, pagravantes, pcgradoresp,
                      pctiplesiones, pctiphos);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE sin_tramite_lesiones
               SET nlesiones = pnlesiones,
                   nmuertos = pnmuertos,
                   agravantes = pagravantes,
                   cgradoresp = pcgradoresp,
                   ctiplesiones = pctiplesiones,
                   ctiphos = pctiphos
             WHERE nsinies = pnsinies
               AND ntramte = pntramte;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9901987;   --Error al actualizar
   END f_ins_tramite_lesiones;

   /*************************************************************************
      FUNCTION ff_hay_tramites
         Comprueba si se han parametrizado los tramites para el producto del siniestro
         param in pnsinies   : número de siniestro
         return              : 0 -> No
                               1 -> Si
   *************************************************************************/
   FUNCTION ff_hay_tramites(pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_TRAMITE.ff_hay_tramites';
      vparam         VARCHAR2(500) := 'parámetros - nsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vcuantos_hay   NUMBER;
   BEGIN
      IF pnsinies IS NULL THEN
         RETURN NULL;
      END IF;

      SELECT COUNT(*)
        INTO vcuantos_hay
        FROM sin_prod_tramite
       WHERE ctramte != 0
         AND sproduc = (SELECT sproduc
                          FROM seguros se, sin_siniestro si
                         WHERE si.sseguro = se.sseguro
                           AND si.nsinies = pnsinies);

      IF vcuantos_hay > 0 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END ff_hay_tramites;

   /*************************************************************************
      FUNCTION
         Crea o actualiza en bbdd, información del tramite asistencia.
         param in  pnsinies   : codi del sinistre
         param in  pntramte   : numero tràmit sinistre
         param in  trefext    : Referencia Externa
         param in  cciaasis   : Compañía de asistencia VF=XXX
         param out psindup   : Numero siniestro con referencia duplicada
         return              : Error (0 -> Tot correcte, codi error)
    -- Bug 0022099 - 16/05/2012 - JMF
   *************************************************************************/
   FUNCTION f_ins_tramite_asistencia(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      ptrefext IN VARCHAR2,
      pcciaasis IN NUMBER,
      psindup OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_SIN_TRAMITE.f_ins_tramite_asistencia';
      vparam         VARCHAR2(500)
         := 'nsinies=' || pnsinies || ' pntramte=' || pntramte || ' TREFEXT=' || ptrefext
            || ' CCIAASIS=' || pcciaasis;
      vpasexec       NUMBER(5) := 0;
      v_sin          sin_tramite_asistencia.nsinies%TYPE;
   BEGIN
      vpasexec := 10;
      psindup := NULL;

      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL
         OR pntramte IS NULL THEN
         RETURN 9000505;
      END IF;

      SELECT MAX(nsinies)
        INTO psindup
        FROM sin_siniestro_referencias
       WHERE ctipref = 2
         AND freffin IS NULL
         AND trefext = ptrefext
         AND nsinies <> pnsinies;

      IF psindup IS NOT NULL THEN
         RETURN 9903714;
      END IF;

      SELECT MAX(nsinies)
        INTO psindup
        FROM sin_tramite_asistencia
       WHERE trefext = ptrefext
         AND nsinies <> pnsinies;

      IF psindup IS NOT NULL THEN
         RETURN 9903714;
      END IF;

      BEGIN
         vpasexec := 20;

         INSERT INTO sin_tramite_asistencia
                     (nsinies, ntramte, trefext, cciaasis)
              VALUES (pnsinies, pntramte, ptrefext, pcciaasis);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            vpasexec := 30;

            UPDATE sin_tramite_asistencia
               SET trefext = ptrefext,
                   cciaasis = pcciaasis
             WHERE nsinies = pnsinies
               AND ntramte = pntramte;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         -- Error al actualizar SIN_TRAMITE_ASISTENCIA
         RETURN 9903705;
   END f_ins_tramite_asistencia;

   /***********************************************************************
      Cambia el estado de una tramite
      param in pnsinies : Número siniestro
      param in pntramte : Número tramitación
      param in pcesttra : Código estado
      return            : 0 -> Tot correcte
                          1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
      Bug 12298 - 15/12/2009 - AMC
   ***********************************************************************/
   FUNCTION f_estado_tramite(pnsinies IN VARCHAR2, pntramte IN NUMBER, pcesttte IN NUMBER)
      RETURN NUMBER IS
      -- ini Bug 0020765 - 13/01/2012 - JMF
      vobj           VARCHAR2(100) := 'pac_sin_tramite.f_estado_tramite';
      vpar           VARCHAR2(500)
                                 := 's=' || pnsinies || ' t=' || pntramte || ' e=' || pcesttte;
      vpas           NUMBER := 1;
      -- fin Bug 0020765 - 13/01/2012 - JMF
      vnerror        NUMBER(10);
      vnmovtte       sin_tramite_mov.nmovtte%TYPE;
      vcesttte       sin_tramite_mov.cesttte%TYPE;
      vcunitra       sin_tramite_mov.cunitra%TYPE;
      vctramitad     sin_tramite_mov.ctramitad%TYPE;
   BEGIN
      -- Sólo insertamos si el estado inicial es abierto/reabierto o el estado inicial es Finalizado y el nuevo estado Reabierto.
      BEGIN
         SELECT MAX(cesttte)
           INTO vcesttte
           FROM sin_tramite_mov
          WHERE nsinies = pnsinies
            AND ntramte = pntramte;
      EXCEPTION
         WHEN OTHERS THEN
            vcesttte := NULL;
      END;

      IF pcesttte = 1 THEN
         -- Si quieren finalizar tramite, validamos tramitaciones
         SELECT COUNT(1)
           INTO vnerror
           FROM sin_tramitacion a, sin_tramita_movimiento b
          WHERE a.nsinies = pnsinies
            AND a.ntramte = pntramte
            AND b.nsinies = a.nsinies
            AND b.ntramit = a.ntramit
            AND b.nmovtra = (SELECT MAX(b1.nmovtra)
                               FROM sin_tramita_movimiento b1
                              WHERE b1.nsinies = b.nsinies
                                AND b1.ntramit = b.ntramit)
            AND b.cesttra NOT IN(1, 2, 3);

         IF vnerror > 0 THEN
            -- Cambio estado siniestro/tramitación
            RETURN 9002026;
         END IF;
      END IF;

      IF vcesttte IN(0, 4)
         OR(vcesttte = 1
            AND pcesttte = 4) THEN
         vnerror := pac_siniestros.f_get_tramitador(pnsinies, pntramte, NULL, vcunitra,
                                                    vctramitad);

         IF NVL(vnerror, 99999) > 1 THEN
            RETURN vnerror;
         END IF;

         vnerror := 0;
         vnmovtte := NULL;
         vnerror := pac_sin_tramite.f_ins_tramite_mov(pnsinies, pntramte, pcesttte, NULL,
                                                      vcunitra, vctramitad, f_sysdate,
                                                      vnmovtte);

         IF vnerror <> 0 THEN
            RETURN vnerror;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9001916;
   END f_estado_tramite;

    /*************************************************************************
      FUNCTION
         Crea o actualiza en bbdd, información del tramite asistencia.
         param in  pnsinies  : codi del sinistre
         param out pntramit  : Numero de tramitaci
         param in out t_iax_mensajes      : mensajes de error
         return              : Error (0 -> Tot correcte, codi error)

      Bug 22325/115249- 07/06/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_tramite9999(pnsinies IN NUMBER, pntramit OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_get_ntramitglobal';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 1;
      vntramte       NUMBER;
   BEGIN
      BEGIN
         SELECT ntramte
           INTO vntramte
           FROM sin_tramite
          WHERE nsinies = pnsinies
            AND ctramte = 9999;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;   -- 0025126: SIN - Traza pac_sin_tramite.f_get_tramite9999
      END;

      SELECT ntramit
        INTO pntramit
        FROM sin_tramitacion
       WHERE nsinies = pnsinies
         AND ntramte = vntramte;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_tramite9999;

    /*************************************************************************
        FUNCTION f_asigna_tramitaciones
        Crea un movimiento de tramitacion cuando se crea un movimiento de tramite
        para cambiar el tramitador
        param in pnsinies    : numero siniestro
        param in pntramte    : numero tramite
        param in pnmovimi    : ultimo movimiento
        param in pcunitra    : codigo de la unidad de tramitacion
        param in pctramitad  : codigo del tramitador
        return               : 0 - OK , SQLERRM - KO
   *************************************************************************/
   FUNCTION f_asigna_tramitaciones(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
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
         OR pntramte IS NULL
         OR pcunitra IS NULL
         OR pctramitad IS NULL THEN
         RETURN 9000505;
      END IF;

      IF pnmovimi = 1 THEN
         vcambio := 0;
      ELSE
         vpasexec := 3;

         SELECT MAX(nmovtte)
           INTO vmov_anterior
           FROM sin_tramite_mov
          WHERE nsinies = pnsinies
            AND ntramte = pntramte
            AND nmovtte < pnmovimi;

         vpasexec := 4;

         SELECT ctramitad
           INTO vctramitad_ant
           FROM sin_tramite_mov
          WHERE nsinies = pnsinies
            AND ntramte = pntramte
            AND nmovtte = vmov_anterior;

         IF vctramitad_ant = pctramitad THEN
            vcambio := 0;
         ELSE
            vcambio := 1;
         END IF;
      END IF;

      IF vcambio = 0 THEN
         RETURN 0;
      END IF;

      FOR i IN (SELECT t.ntramit, m.cesttra, m.csubtra, m.festtra
                  FROM sin_tramitacion t, sin_tramita_movimiento m
                 WHERE m.nsinies = t.nsinies
                   AND m.ntramit = t.ntramit
                   AND m.nmovtra = (SELECT MAX(m1.nmovtra)
                                      FROM sin_tramita_movimiento m1
                                     WHERE m1.nsinies = m.nsinies
                                       AND m1.ntramit = m.ntramit)
                   AND t.nsinies = pnsinies
                   AND t.ntramte = pntramte
                   AND m.cesttra = 0) LOOP   -- Leemos todas las tramitaciones abiertas del tramite
         -- creamos un movimiento de cambio de tramitador
         num_err := pac_siniestros.f_ins_tramita_movimiento(pnsinies, i.ntramit, pcunitra,
                                                            pctramitad, i.cesttra, i.csubtra,
                                                            i.festtra, dummy, 21);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_tramite.f_asigna_tramitacion', 1,
                     'pnsinies=' || pnsinies || ' pntramte=' || pntramte || ' pcunitra='
                     || pcunitra || ' pctramitad=' || pctramitad,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_asigna_tramitaciones;
END pac_sin_tramite;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_TRAMITE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_TRAMITE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_TRAMITE" TO "PROGRAMADORESCSI";
