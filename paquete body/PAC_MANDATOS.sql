--------------------------------------------------------
--  DDL for Package Body PAC_MANDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MANDATOS" IS
      /*******************************************************************************
    FUNCION f_set_mandatos
         -- Descripcion
   Parámetros:
    Entrada :
      psperson: Identificador de la persona
      pcnordban: Código unico consecutivo que identifica la cuenta bancaria de la persona
      pctipban: Tipo cuenta bancaria
      pcbancar: Cuenta bancaria
      pccobban: Código de cobrador bancario
      pvencim: Fecha vencimiento
      pseguri: Codigo de seguridad

     Retorna un valor numérico: 0 si ha grabado el mandato y 1 si se ha producido algún error.

   */
   FUNCTION f_set_mandatos(
      pmode IN VARCHAR2,
      psperson IN mandatos.sperson%TYPE,
      pcnordban IN mandatos.cnordban%TYPE,
      pctipban IN mandatos.ctipban%TYPE,
      pcbancar IN mandatos.cbancar%TYPE,
      pccobban IN mandatos.ccobban%TYPE,
      pcestado IN mandatos.cestado%TYPE,
      pvencim IN mandatos.fvencim%TYPE DEFAULT NULL,
      pseguri IN mandatos.tseguri%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vcmandato      VARCHAR2(35 BYTE);
   BEGIN
      vpasexec := 10;

      -- Estado inical a pendiente.
       -- vcestado := 0;
      SELECT seq_mandatos.NEXTVAL
        INTO vcmandato
        FROM DUAL;

      IF pmode = 'POL' THEN
         IF NVL(f_existe_pers_mandato(psperson, pcnordban, 'POL'), 0) <> 1 THEN
            INSERT INTO mandatos
                        (sperson, cnordban, ctipban, cbancar, ccobban, sseguro, cmandato,
                         cestado, ffirma, fusualta, cusualta, fvencim, tseguri)
                 VALUES (psperson, pcnordban, pctipban, pcbancar, pccobban, NULL, vcmandato,
                         pcestado, f_sysdate, f_sysdate, f_user, pvencim, pseguri);

            vpasexec := 20;
         ELSE
            vpasexec := 30;

            -- mirar si se puede updatear la cuenta bancaria
            UPDATE mandatos
               SET ctipban = pctipban,
                   cbancar = pcbancar,
                   ccobban = pccobban,
                   fvencim = pvencim,
                   tseguri = pseguri
             WHERE sperson = psperson
               AND cnordban = pcnordban;

            IF SQL%ROWCOUNT = 0 THEN
               p_tab_error(f_sysdate, f_user, 'pac_mandatos', 30,
                           'f_set_mandatos.Error Imprevisto insertando MANDATOS.', SQLERRM);
               RETURN 140999;
            END IF;
         END IF;
      ELSE   -- tablas 'EST'
         IF NVL(f_existe_pers_mandato(psperson, pcnordban, 'EST'), 0) <> 1 THEN
            INSERT INTO estmandatos
                        (sperson, cnordban, ctipban, cbancar, ccobban, cmandato,
                         cestado, ffirma, fusualta, cusualta, fvencim, tseguri)
                 VALUES (psperson, pcnordban, pctipban, pcbancar, pccobban, vcmandato,
                         pcestado, f_sysdate, f_sysdate, f_user, pvencim, pseguri);

            vpasexec := 20;
         ELSE
            vpasexec := 30;

            -- mirar si se puede updatear la cuenta bancaria
            UPDATE estmandatos
               SET ctipban = pctipban,
                   cbancar = pcbancar,
                   ccobban = pccobban,
                   fvencim = pvencim,
                   tseguri = pseguri
             WHERE sperson = psperson
               AND cnordban = pcnordban;

            IF SQL%ROWCOUNT = 0 THEN
               p_tab_error(f_sysdate, f_user, 'pac_mandatos', 30,
                           'f_set_mandatos.Error Imprevisto insertando ESTMANDATOS.', SQLERRM);
               RETURN 140999;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mandatos.f_set_mandatos', vpasexec, SQLCODE,
                     SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_set_mandatos;

   FUNCTION f_existe_pers_mandato(
      psperson IN mandatos.sperson%TYPE,
      pcnordban IN mandatos.cnordban%TYPE,
      pmode IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vexiste        NUMBER;
   BEGIN
      vpasexec := 10;

      IF pmode = 'POL' THEN
         SELECT 1
           INTO vexiste
           FROM mandatos
          WHERE sperson = psperson
            AND cnordban = pcnordban;
      ELSE
         SELECT 1
           INTO vexiste
           FROM estmandatos
          WHERE sperson = psperson
            AND cnordban = pcnordban;
      END IF;

      vpasexec := 20;
      RETURN vexiste;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_existe_pers_mandato;

   FUNCTION f_anular_mandato(
      psperson IN mandatos.sperson%TYPE,
      pcnordban IN mandatos.cnordban%TYPE,
      pmode IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      v_numfolios    NUMBER;
      e_salir        EXCEPTION;
      vnum_err       NUMBER;
      vdeserror      VARCHAR2(50);
   BEGIN
      vpasexec := 10;

      IF pmode = 'POL' THEN
         UPDATE mandatos
            SET cestado = 2
          WHERE sperson = psperson
            AND cnordban = pcnordban;

         --S'han d'anular els numfolio que tienen ese mandato.
         FOR regnumfolio IN (SELECT DISTINCT numfolio
                                        FROM mandatos_seguros ms
                                       WHERE ms.cmandato IN(
                                                SELECT cmandato
                                                  FROM mandatos
                                                 WHERE sperson = psperson
                                                   AND cnordban = pcnordban)
                                         AND NOT EXISTS(
                                                SELECT 1
                                                  FROM mandatos_estados me
                                                 WHERE me.numfolio = ms.numfolio
                                                   AND cestado = 2)) LOOP
            -- Accion anular
            vnum_err := pac_mandatos.f_set_mandatos_gestion(regnumfolio.numfolio, 8, NULL,
                                                            NULL, 'Baja de Cuenta/Tarjeta',
                                                            NULL);

            IF vnum_err <> 0 THEN
               vnum_err := 9906785;
               vdeserror := 'Error modificando en la tabla de mandatos_gestion';
               RAISE e_salir;
            END IF;

            vpasexec := 20;
            --Estado anulacion
            vnum_err := pac_mandatos.f_set_estado_mandato(regnumfolio.numfolio, 2);

            IF vnum_err <> 0 THEN
               vnum_err := 9906786;
               vdeserror := 'Error modificando en la tabla de mandatos_estados';
               RAISE e_salir;
            END IF;

            vpasexec := 30;
         END LOOP;
      ELSE
         UPDATE estmandatos
            SET cestado = 2
          WHERE sperson = psperson
            AND cnordban = pcnordban;
      -- En el traspaso a tablas reales se hará la anulación de los numeros de folios de ese manadato.
      END IF;

      vpasexec := 40;
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         p_tab_error(f_sysdate, f_user, 'pac_mandatos.f_anular_mandato', vpasexec,
                     'ERROR SALIR: vnum_err:' || vnum_err || 'vdeserror' || vdeserror,
                     SQLERRM);
         RETURN vnum_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mandatos.f_anular_mandato', vpasexec,
                     'ERROR SALIR: vnum_err:' || 9906756 || 'vdeserror'
                     || 'Error modificando en tablas de mandatos ',
                     SQLERRM);
         RETURN 9906756;   -- Error modificando en tablas de mandatos
   END f_anular_mandato;

   FUNCTION f_get_mandato(
      psperson IN estmandatos.sperson%TYPE,
      pcbancar IN estmandatos.cbancar%TYPE,
      pcmandato OUT estmandatos.cmandato%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
   BEGIN
      vpasexec := 10;

      SELECT cmandato
        INTO pcmandato
        FROM estmandatos
       WHERE sperson = psperson
         AND cbancar = pcbancar;

      vpasexec := 20;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'pac_mandatos.f_get_mandato', vpasexec,
                     'psperson= ' || psperson || ' pcbancar= ' || pcbancar,
                     'No se ha encontrado el mandato para persona y cuenta bancaria');
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mandatos.f_get_mandato', vpasexec, SQLCODE,
                     SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_get_mandato;

   /******************************************************************************
            NOM:  f_descbanco
            DESC: Recupera la descripció del banco

            REVISIONES:
            Ver        Fecha        Autor             Descripción
            ---------  ----------  ---------------  ------------------------------------
            1.0
      ******************************************************************************/
   FUNCTION f_descbanco(pcbancar IN VARCHAR2, pctipban IN NUMBER)
      RETURN VARCHAR2 IS
      v_desc_banco   VARCHAR2(50);
   BEGIN
      v_desc_banco := NULL;

      SELECT f_descentidadsin(SUBSTR(pcbancar, t.pos_entidad, t.long_entidad))
        INTO v_desc_banco
        FROM tipos_cuenta t
       WHERE t.ctipban = pctipban;

      RETURN(v_desc_banco);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_descbanco;

   FUNCTION f_desccobradorbanc(p_ccobban IN NUMBER)
      RETURN VARCHAR2 IS
      v_desc_cobradorbanc cobbancario.descripcion%TYPE;
   BEGIN
      v_desc_cobradorbanc := NULL;

      SELECT descripcion
        INTO v_desc_cobradorbanc
        FROM cobbancario
       WHERE ccobban = p_ccobban;

      RETURN(v_desc_cobradorbanc);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_desccobradorbanc;

   FUNCTION f_desctipotarjeta(pctipban IN NUMBER)
      RETURN VARCHAR2 IS
      v_desc_tipotarjeta VARCHAR2(100);
   BEGIN
      v_desc_tipotarjeta := NULL;

      SELECT ff_desvalorfijo(800049, pac_md_common.f_get_cxtidioma, t.ctipcc)
        INTO v_desc_tipotarjeta
        FROM tipos_cuenta t
       WHERE t.ctipban = pctipban;

      RETURN(v_desc_tipotarjeta);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_desctipotarjeta;

   FUNCTION f_codtipotarjeta(pctipban IN NUMBER)
      RETURN VARCHAR2 IS
      v_cod_tipotarjeta tipos_cuenta.ctipcc%TYPE;
   BEGIN
      v_cod_tipotarjeta := NULL;

      SELECT t.ctipcc
        INTO v_cod_tipotarjeta
        FROM tipos_cuenta t
       WHERE t.ctipban = pctipban;

      RETURN(v_cod_tipotarjeta);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_codtipotarjeta;

   FUNCTION f_get_rut(psperson IN NUMBER)
      RETURN VARCHAR2 IS
      v_nnumide      VARCHAR2(52);
   BEGIN
      v_nnumide := NULL;

      SELECT per.nnumide || DECODE(tdigitoide, NULL, NULL, '-' || tdigitoide)
        INTO v_nnumide
        FROM per_personas per
       WHERE per.sperson = psperson;

      RETURN(v_nnumide);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_get_rut;

   FUNCTION f_get_nombre(psseguro IN NUMBER, pperson IN NUMBER)
      RETURN VARCHAR2 IS
      v_nombre       VARCHAR2(200);
   BEGIN
      v_nombre := NULL;

      SELECT TRIM(c.tapelli1) || ' ' || TRIM(c.tapelli2)
             || DECODE(c.tnombre, NULL, NULL, ', ' || TRIM(c.tnombre))
        INTO v_nombre
        FROM seguros a, per_detper c
       WHERE a.sseguro = psseguro
         AND c.sperson = pperson
         AND c.cagente = ff_agente_cpervisio(a.cagente, f_sysdate, a.cempres);

      RETURN(v_nombre);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_get_nombre;

   FUNCTION f_get_contactos(psseguro IN NUMBER, pperson IN NUMBER)
      RETURN VARCHAR2 IS
      v_tvalcon      per_contactos.tvalcon%TYPE;
      v_agensuperv   redcomercial.cpervisio%TYPE;
      v_telefonos    VARCHAR2(200);

      CURSOR cur_cont(agensuperv NUMBER) IS
         SELECT   tvalcon
             FROM per_contactos
            WHERE sperson = pperson
              AND cagente = agensuperv
              AND ROWNUM <= 2
         ORDER BY ctipcon;
   BEGIN
      v_telefonos := NULL;

      SELECT ff_agente_cpervisio(a.cagente, f_sysdate, a.cempres)
        INTO v_agensuperv
        FROM seguros a
       WHERE a.sseguro = psseguro;

      FOR reg IN cur_cont(v_agensuperv) LOOP
         IF v_telefonos IS NOT NULL THEN
            v_telefonos := v_telefonos || '/' || reg.tvalcon;
         ELSE
            v_telefonos := reg.tvalcon;
         END IF;
      END LOOP;

      RETURN(v_telefonos);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_get_contactos;

   FUNCTION f_get_numfolio(pcmandato IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_numfolio     mandatos_seguros.numfolio%TYPE;
   BEGIN
      v_numfolio := NULL;

      SELECT DISTINCT (numfolio)
                 INTO v_numfolio
                 FROM mandatos_seguros
                WHERE cmandato = pcmandato;

      RETURN(v_numfolio);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_get_numfolio;

   FUNCTION f_codbanco(pcbancar IN VARCHAR2, pctipban IN NUMBER)
      RETURN VARCHAR2 IS
      v_cod_banco    VARCHAR2(10);
   BEGIN
      v_cod_banco := NULL;

      SELECT SUBSTR(pcbancar, t.pos_entidad, t.long_entidad)
        INTO v_cod_banco
        FROM tipos_cuenta t
       WHERE t.ctipban = pctipban;

      RETURN(v_cod_banco);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_codbanco;

   FUNCTION f_getultaccionmandato(pnumfolio IN mandatos_gestion.numfolio%TYPE)
      RETURN NUMBER IS
      v_caccion      mandatos_gestion.accion%TYPE;
   BEGIN
      v_caccion := NULL;

      SELECT accion
        INTO v_caccion
        FROM mandatos_gestion
       WHERE numfolio = pnumfolio
         AND caviso = (SELECT MAX(caviso)
                         FROM mandatos_gestion
                        WHERE numfolio = pnumfolio);

      RETURN(v_caccion);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_getultaccionmandato;

   FUNCTION f_getultestadomandato(pnumfolio IN mandatos_estados.numfolio%TYPE)
      RETURN VARCHAR2 IS
      v_descestado   detvalores.tatribu%TYPE;
   BEGIN
      v_descestado := NULL;

      SELECT ff_desvalorfijo(489, pac_md_common.f_get_cxtidioma, cestado)
        INTO v_descestado
        FROM mandatos_estados
       WHERE numfolio = pnumfolio
         AND fechaestado = (SELECT MAX(fechaestado)
                              FROM mandatos_estados
                             WHERE numfolio = pnumfolio);

      RETURN(v_descestado);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_getultestadomandato;

   FUNCTION f_getcodultestadomandato(pnumfolio IN mandatos_estados.numfolio%TYPE)
      RETURN NUMBER IS
      v_cestado      mandatos_estados.cestado%TYPE;
   BEGIN
      v_cestado := NULL;

      SELECT cestado
        INTO v_cestado
        FROM mandatos_estados
       WHERE numfolio = pnumfolio
         AND fechaestado = (SELECT MAX(fechaestado)
                              FROM mandatos_estados
                             WHERE numfolio = pnumfolio);

      RETURN(v_cestado);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_getcodultestadomandato;

   FUNCTION f_set_mandatos_gestion(
      pnumfolio IN mandatos_gestion.numfolio%TYPE,
      paccion IN mandatos_gestion.accion%TYPE,
      pfproxaviso IN mandatos_gestion.fproxaviso%TYPE,
      pmotrechazo IN mandatos_gestion.motrechazo%TYPE DEFAULT NULL,
      pcomentario IN mandatos_gestion.comentario%TYPE DEFAULT NULL,
      psmandoc_rechazo IN mandatos_gestion.smandoc_rechazo%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vcaviso        NUMBER;
   BEGIN
      vpasexec := 10;

      SELECT seq_mandatos_gestion.NEXTVAL
        INTO vcaviso
        FROM DUAL;

      INSERT INTO mandatos_gestion
                  (caviso, numfolio, faccion, cusuaccion, accion, motrechazo, fproxaviso,
                   comentario, smandoc_rechazo)
           VALUES (vcaviso, pnumfolio, f_sysdate, f_user, paccion, pmotrechazo, pfproxaviso,
                   pcomentario, psmandoc_rechazo);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MANDATOS.f_set_mandatos_gestion', 1,
                     'f_set_mandatos_gestion.Error Imprevisto insertando mandatos_gestion.',
                     SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_set_mandatos_gestion;

   FUNCTION f_set_estado_mandato(
      pnumfolio IN mandatos_estados.numfolio%TYPE,
      pcestado IN mandatos_estados.cestado%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vcaviso        NUMBER;
   BEGIN
      vpasexec := 10;

      INSERT INTO mandatos_estados
                  (numfolio, cestado, fechaestado, cusualta)
           VALUES (pnumfolio, pcestado, f_sysdate, f_user);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error
            (f_sysdate, f_user, 'PAC_MANDATOS.f_set_estado_mandato', 1,
             'f_set_estado_mandato.Error Imprevisto insertando mandatos. param: pnumfolio'
             || pnumfolio || 'pcestado' || pcestado,
             SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_set_estado_mandato;

   FUNCTION f_getmot_rechazo(pnumfolio IN mandatos_gestion.numfolio%TYPE)
      RETURN NUMBER IS
      v_cmotrechazo  mandatos_gestion.motrechazo%TYPE;
   BEGIN
      v_cmotrechazo := NULL;

      SELECT motrechazo
        INTO v_cmotrechazo
        FROM mandatos_gestion
       WHERE numfolio = pnumfolio
         AND accion = 8;   -- accion anular

      RETURN(v_cmotrechazo);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_getmot_rechazo;

   FUNCTION f_getult_nomina(pnumfolio IN mandatos_masiva.numfolio%TYPE)
      RETURN NUMBER IS
      v_nomina       mandatos_masiva.nomina%TYPE;
   BEGIN
      v_nomina := NULL;

      SELECT MAX(nomina)
        INTO v_nomina
        FROM mandatos_masiva
       WHERE numfolio = pnumfolio;

      RETURN(v_nomina);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_getult_nomina;

   FUNCTION f_set_mandatos_masiva(
      pnomina IN mandatos_masiva.nomina%TYPE,
      pnumfolio IN mandatos_masiva.numfolio%TYPE,
      paccion IN mandatos_masiva.accion%TYPE,
      prownum IN NUMBER,
      pcarta IN mandatos_masiva.ncarta%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vcarta         NUMBER(10);
      vnomina        NUMBER;
   BEGIN
      vpasexec := 10;

      INSERT INTO mandatos_masiva
                  (nomina, numfolio, accion, fecha, usuario, nitem, ncarta)
           VALUES (pnomina, pnumfolio, paccion, f_sysdate, f_user, prownum, pcarta);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MANDATOS.f_set_mandatos_masiva', 1,
                     'f_set_mandatos_masiva.Error Imprevisto insertando mandatos masiva.',
                     SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_set_mandatos_masiva;

   FUNCTION f_mandato_editable(
      pnominaselec IN mandatos_masiva.nomina%TYPE,
      pnominaultima IN mandatos_masiva.nomina%TYPE,
      psituacion IN mandatos_estados.cestado%TYPE)
      RETURN NUMBER IS
      --
      v_rolman       NUMBER;
      v_rolusu       menu_usercodirol.crolmen%TYPE;
   BEGIN
      v_rolman := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                    'ROL_MANDATO'),
                      0);
      v_rolusu := pac_mandatos.f_getrolusuari(f_user);

      IF (v_rolman = 0
          AND v_rolusu = 'CENTRAL')
         OR(v_rolman = 1
            AND v_rolusu IN('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO')) THEN
         IF psituacion NOT IN(7, 8) THEN
            RETURN(0);
         END IF;
      ELSE
         IF psituacion NOT IN(6) THEN
            RETURN(0);
         END IF;
      END IF;

      IF pnominaselec = 0
         OR pnominaultima = 0
         OR pnominaselec = pnominaultima THEN
         RETURN(1);
      ELSE
         RETURN(0);
      END IF;
   END f_mandato_editable;

   FUNCTION f_get_nomina_mandato(pnumfolio IN mandatos_masiva.numfolio%TYPE)
      RETURN NUMBER IS
      v_nomina       mandatos_masiva.nomina%TYPE;
      v_ult_estado   mandatos_estados.cestado%TYPE;
      v_accion       mandatos_masiva.accion%TYPE;
   BEGIN
      v_nomina := NULL;
      v_ult_estado := pac_mandatos.f_getcodultestadomandato(pnumfolio);

      IF v_ult_estado IN(7, 8, 3) THEN
         IF v_ult_estado = 7 THEN   --Estado Envío a casa matriz
            v_accion := 0;   -- Accion Envío a casa matriz
         ELSIF v_ult_estado = 8 THEN   --Estado Custodia
            v_accion := 1;   -- Accion Custodia
         ELSIF v_ult_estado = 3 THEN   --Estado En tránsito
            v_accion := 2;   -- Accion En transito
         END IF;

         SELECT nomina
           INTO v_nomina
           FROM mandatos_masiva
          WHERE numfolio = pnumfolio
            AND accion = v_accion;
      END IF;

      RETURN(v_nomina);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_nomina_mandato;

   PROCEDURE traspaso_tablas_estmandatos(
      psperson IN estmandatos.sperson%TYPE,
      mens OUT VARCHAR2) IS
      vsperson_new   estmandatos.sperson%TYPE;
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vdeserror      VARCHAR2(50);
      e_salir        EXCEPTION;
   BEGIN
      vsperson_new := pac_persona.f_sperson_spereal(psperson);

      FOR reg IN (SELECT *
                    FROM estmandatos
                   WHERE sperson = psperson) LOOP
         BEGIN
            vtraza := 1;

            IF NVL(f_existe_mandato(reg.cmandato, 'POL'), 0) <> 1 THEN
               INSERT INTO mandatos
                           (sperson, cnordban, ctipban, cbancar,
                            ccobban, sseguro, cmandato, cestado, ffirma,
                            fusualta, cusualta, fvencim, tseguri)
                    VALUES (vsperson_new, reg.cnordban, reg.ctipban, reg.cbancar,
                            reg.ccobban, NULL, reg.cmandato, reg.cestado, reg.ffirma,
                            reg.fusualta, reg.cusualta, reg.fvencim, reg.tseguri);

               vtraza := 2;
            ELSE
               vtraza := 3;

               UPDATE mandatos
                  SET ctipban = reg.ctipban,
                      cbancar = reg.cbancar,
                      ccobban = reg.ccobban,
                      cestado = reg.cestado,
                      fvencim = reg.fvencim,
                      tseguri = reg.tseguri
                WHERE cmandato = reg.cmandato;

               vtraza := 4;
            END IF;

            IF reg.cestado = 2 THEN
               -- Si se ha anulado el mandato, se miran los folios que no esten anulados para anularse.
               FOR regnumfolio IN (SELECT DISTINCT numfolio
                                              FROM mandatos_seguros ms
                                             WHERE ms.cmandato = reg.cmandato
                                               AND NOT EXISTS(
                                                     SELECT 1
                                                       FROM mandatos_estados me
                                                      WHERE me.numfolio = ms.numfolio
                                                        AND cestado = 2)) LOOP
                  -- Accion anular
                  vnum_err := pac_mandatos.f_set_mandatos_gestion(regnumfolio.numfolio, 8,
                                                                  NULL, NULL,
                                                                  'Baja de Cuenta/Tarjeta',
                                                                  NULL);

                  IF vnum_err <> 0 THEN
                     vnum_err := 9906785;
                     vdeserror := 'Error modificando en la tabla de mandatos_gestion';
                     RAISE e_salir;
                  END IF;

                  vtraza := 5;
                  --Estado anulacion
                  vnum_err := pac_mandatos.f_set_estado_mandato(regnumfolio.numfolio, 2);

                  IF vnum_err <> 0 THEN
                     vnum_err := 9906786;
                     vdeserror := 'Error modificando en la tabla de mandatos_estados';
                     RAISE e_salir;
                  END IF;

                  vtraza := 6;
               END LOOP;
            END IF;
         END;
      END LOOP;
   EXCEPTION
      WHEN e_salir THEN
         mens := vdeserror;
         p_tab_error(f_sysdate, f_user, 'PAC_MANDATOS.TRASPASO_TABLAS_ESTMANDATOS', vtraza,
                     'TRASPASO_TABLAS_ESTMANDATOS. Error= ' || vnum_err || 'vdeserror = '
                     || vdeserror || '  SPERSON = ' || psperson,
                     SQLERRM);
      WHEN OTHERS THEN
         mens := SQLERRM;
         p_tab_error(f_sysdate, f_user, 'PAC_MANDATOS.TRASPASO_TABLAS_ESTMANDATOS', vtraza,
                     'TRASPASO_TABLAS_ESTMANDATOS. Error .  SPERSON = ' || psperson, SQLERRM);
   END traspaso_tablas_estmandatos;

   PROCEDURE traspaso_mandatos_seguros(
      psseguro IN NUMBER,
      pssegpol IN NUMBER,
      mens OUT VARCHAR2) IS
      haymandato     NUMBER;
      v_pasexec      NUMBER := 0;
      hayregnuevo    NUMBER;
      regestmand_seg estmandatos_seguros%ROWTYPE;
      exist_estado   NUMBER;
      vestado        NUMBER;
      --
      v_rolman       NUMBER;
      v_rolusu       menu_usercodirol.crolmen%TYPE;
   BEGIN
      v_pasexec := 1;

      -- Se mira si se ha insertado un registro nuevo en estmandatos_seguros
      SELECT COUNT(*)
        INTO hayregnuevo
        FROM estmandatos_seguros
       WHERE sseguro = psseguro;

      IF hayregnuevo > 0 THEN
         -- Se mira si existe un mandato anterior
         SELECT COUNT(*)
           INTO haymandato
           FROM mandatos_seguros
          WHERE sseguro = pssegpol
            AND fbajarel IS NULL
            AND cusubajarel IS NULL;

         v_pasexec := 2;

         IF haymandato > 0 THEN   -- es una modificacion del mandato se da de baja la anterior relacion.
            UPDATE mandatos_seguros
               SET fbajarel = f_sysdate,
                   cusubajarel = f_user
             WHERE sseguro = pssegpol
               AND fbajarel IS NULL
               AND cusubajarel IS NULL;
         END IF;

         v_pasexec := 3;

         SELECT *
           INTO regestmand_seg
           FROM estmandatos_seguros
          WHERE sseguro = psseguro;

         INSERT INTO mandatos_seguros
                     (cmandato, numfolio,
                      sucursal, fechamandato, sseguro,
                      faltarel, cusualtarel, fbajarel, cusubajarel,
                      nmovimi, ffinvig)
              VALUES (regestmand_seg.cmandato, regestmand_seg.numfolio,
                      regestmand_seg.sucursal, regestmand_seg.fechamandato, pssegpol,
                      regestmand_seg.faltarel, regestmand_seg.cusualtarel, NULL, NULL,
                      regestmand_seg.nmovimi, regestmand_seg.ffinvig);

         -- Se mira si este mandato ya esta dado de alta en mandatos_estados
         SELECT COUNT(*)
           INTO exist_estado
           FROM mandatos_estados
          WHERE numfolio = regestmand_seg.numfolio;

         IF exist_estado = 0 THEN
            -- Faltaria mirar si el estado es 0 o 6  pendiente o pendiente sucursal depende de quien se haya conectado.
            --Miramos el usuario conectado si es servicios centrales o oficina.
            v_rolman := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                          'ROL_MANDATO'),
                            0);
            v_rolusu := pac_mandatos.f_getrolusuari(f_user);

            IF (v_rolman = 0
                AND v_rolusu = 'CENTRAL')
               OR(v_rolman = 1
                  AND v_rolusu IN('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO')) THEN   -- si es servicios centrales
               vestado := 0;
            ELSE   -- si es oficina
               vestado := 6;
            END IF;

            INSERT INTO mandatos_estados
                        (numfolio, cestado, fechaestado, cusualta)
                 VALUES (regestmand_seg.numfolio, vestado, f_sysdate, f_user);
         END IF;

         v_pasexec := 4;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         mens := SQLERRM;
         p_tab_error(f_sysdate, f_user, 'pac_mandatos.traspaso_mandatos_seguros', v_pasexec,
                     'traspaso est', SQLERRM);
   END traspaso_mandatos_seguros;

   FUNCTION f_get_estado_mandato(psseguro IN NUMBER)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_get_estado_mandato';
      vpasexec       NUMBER := 10;
      vcestado       NUMBER;
   BEGIN
      SELECT me.cestado
        INTO vcestado
        FROM mandatos_seguros ms, mandatos_estados me
       WHERE ms.sseguro = psseguro
         AND ms.faltarel = (SELECT MAX(ms2.faltarel)
                              FROM mandatos_seguros ms2
                             WHERE ms2.sseguro = ms.sseguro)
         AND ms.numfolio = me.numfolio
         AND me.fechaestado = (SELECT MAX(me2.fechaestado)
                                 FROM mandatos_estados me2
                                WHERE me2.numfolio = me.numfolio);

      RETURN vcestado;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --El seguro no tiene asociado un mandato
         RETURN -1;
      WHEN OTHERS THEN
         -- Error recuperar estado del mandato
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'Error recuperar estado del mandato SQLCODE= ' || SQLCODE);
         RETURN -1;
   END f_get_estado_mandato;

   FUNCTION f_set_mandatos_documentos(piddocgedox IN NUMBER, pnumfolio IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      v_smandoc      mandatos_documentos.smandoc%TYPE;
   BEGIN
      vpasexec := 10;

      SELECT documentomandato_sec.NEXTVAL
        INTO v_smandoc
        FROM DUAL;

      INSERT INTO mandatos_documentos
                  (smandoc, iddocgedox, numfolio, falta, cusualta)
           VALUES (v_smandoc, piddocgedox, pnumfolio, f_sysdate, f_user);

      vpasexec := 20;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error
                (f_sysdate, f_user, 'PAC_MANDATOS.f_set_mandatos_documentos', 1,
                 'f_set_mandatos_documentos.Error Imprevisto insertando mandatos documentos.',
                 SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_set_mandatos_documentos;

   FUNCTION f_existe_mandato(pcmandato IN mandatos.cmandato%TYPE, pmode IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vexiste        NUMBER;
   BEGIN
      vpasexec := 10;

      IF pmode = 'POL' THEN
         SELECT 1
           INTO vexiste
           FROM mandatos
          WHERE cmandato = pcmandato;
      ELSE
         SELECT 1
           INTO vexiste
           FROM estmandatos
          WHERE cmandato = pcmandato;
      END IF;

      vpasexec := 20;
      RETURN vexiste;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_existe_mandato;

   FUNCTION f_existe_folio(pnumfolio IN mandatos_seguros.numfolio%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vnumfolios     NUMBER(2);
   BEGIN
      vpasexec := 10;

      SELECT COUNT(*)
        INTO vnumfolios
        FROM mandatos_seguros
       WHERE numfolio = pnumfolio;

      vpasexec := 20;
      RETURN vnumfolios;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MANDATOS.f_existe_folio', 1,
                     'f_existe_folio.Error Imprevisto recuperando mandatos_seguros.', SQLERRM);
         RETURN 1;
   END f_existe_folio;

   FUNCTION f_getcuentabancformateada(ptipban IN NUMBER, pbancar IN VARCHAR2)
      RETURN VARCHAR2 IS
      vparam         VARCHAR2(500) := 'ptipban=' || ptipban || ' pbancar=' || pbancar;
      RESULT         VARCHAR2(500);
      nerr           NUMBER;
      vpasexec       NUMBER(8) := 1;
      banco          VARCHAR2(100);
      cuenta         VARCHAR2(100);
   BEGIN
      nerr := f_formatoccc(pbancar, RESULT, ptipban);

      IF RESULT IS NULL THEN
         RESULT := pbancar;
      END IF;

      SELECT SUBSTR(RESULT, pos_entidad + long_entidad)
        INTO cuenta
        FROM tipos_cuenta
       WHERE ctipban = ptipban;

      IF SUBSTR(cuenta, 1, 1) = '-' THEN
         cuenta := SUBSTR(cuenta, 2);
      END IF;

      RETURN cuenta;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MANDATOS', 3,
                     'PAC_MANDATOS.f_getcuentabancformateada' || 1000135, SQLERRM);   --el formato de campo
         RETURN NULL;
   END f_getcuentabancformateada;

   FUNCTION f_getrolusuari(pcusuari VARCHAR2)
      RETURN VARCHAR2 IS
      pcrolmen       VARCHAR2(20);
   BEGIN
      SELECT crolmen
        INTO pcrolmen
        FROM menu_usercodirol
       WHERE UPPER(cuser) = UPPER(pcusuari)
         AND ROWNUM = 1;

      RETURN pcrolmen;
   -- Por el momento solo recuperamos un rol de menu
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         RETURN NULL;
         p_tab_error(f_sysdate, f_user, 'PAC_MANDATOS.f_getrolusuari', 1,
                     'f_getrolusuari.Error Imprevisto recuperando ROL USUARI.', SQLERRM);
   END f_getrolusuari;

-- Inicio Bug 32676 - 20141016 - MMS
/*******************************************************************************
    FUNCION f_vigencia_mandato
         -- Descripcion
   Parámetros:
    Entrada :
      psseguro: Identificador del seguro

     Retorna un 1 cuando el mandato esté vigente.
*/
   FUNCTION f_vigencia_mandato(psseguro NUMBER)
      RETURN NUMBER IS
      v_result       NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO v_result
        FROM mandatos_seguros ms
       WHERE ms.fechamandato IN(SELECT MAX(ms1.fechamandato)
                                  FROM mandatos_seguros ms1
                                 WHERE ms1.sseguro = ms.sseguro)   -- Obtenemos la última fecha de mantados para esa póliza
         AND ms.nmovimi IN(SELECT MAX(ms2.nmovimi)
                             FROM mandatos_seguros ms2
                            WHERE ms2.sseguro = ms.sseguro
                              AND ms2.fechamandato = ms.fechamandato)   -- Obtenemos el último movimiento segun fecha y póliza
         AND NVL(ms.ffinvig, f_sysdate) >= f_sysdate
         AND ms.fbajarel IS NULL   -- Bug 37924 20151001 MMS
         AND ms.sseguro = psseguro;

      IF v_result = 1 THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MANDATOS.F_VIGENCIA_MANDATO', 1,
                     'psseguro: ' || psseguro || '.Error Imprevisto recuperando MANDATOS.',
                     SQLERRM);
         RETURN 1;
   END f_vigencia_mandato;
-- Fin Bug 32676 - 20141016 - MMS
END pac_mandatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MANDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MANDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MANDATOS" TO "PROGRAMADORESCSI";
