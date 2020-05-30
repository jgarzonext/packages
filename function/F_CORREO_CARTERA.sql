--------------------------------------------------------
--  DDL for Function F_CORREO_CARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CORREO_CARTERA" (
   pfecha_aaaamm IN VARCHAR2,
   pcorreoresumen IN VARCHAR2,
   pcagente IN NUMBER DEFAULT NULL)
   RETURN NUMBER IS
   --
   pscorreo       NUMBER := 303;
   pfenvio        DATE := f_sysdate;
   pfinicio       DATE;
   pfinal         DATE;
   pdirectorio    VARCHAR2(3000) := f_parinstalacion_t('DIR_EXPEDI_AUTO');
   --
   numer          NUMBER;
   v_scorreo      NUMBER := pscorreo;
   v_titulo       VARCHAR2(100);
   v_cidioma      NUMBER := NVL(pac_contexto.f_contextovalorparametro('IAX_IDIOMA'), 2);
   psproces       NUMBER;
   vnprolin       NUMBER;
   pfini          VARCHAR2(20);
   pfin           VARCHAR2(20);
   vcoun          NUMBER;
   mensajes       t_iax_mensajes := t_iax_mensajes();
   pparams        t_iax_info := t_iax_info();
   params         ob_iax_info := ob_iax_info();
   pnomfich       VARCHAR2(500);
   pofich         VARCHAR2(500);
   vdirectorio2   VARCHAR2(20) := pdirectorio;
   vfichero2      VARCHAR2(100) := '#CODIGOAGENTE#_RECIBO_CARTERA_#YYYYMM#.PDF';
   v_to           VARCHAR2(100);
   v_toresumen    VARCHAR2(100) := pcorreoresumen;
   v_error        VARCHAR2(100);
   v_texto        VARCHAR2(2000);
   vok            NUMBER := 0;
   vko            NUMBER := 0;
   vpasexec       NUMBER := 1;
   vobject        VARCHAR2(200) := 'F_CORREO_CARTERA';
   v_subject      VARCHAR2(300);
   pos            NUMBER := 0;
   v_adjunto2     VARCHAR2(50);

   CURSOR c_agentes IS
      SELECT ac.cagente
        FROM agentes_correo ac, agentes_comp ap
       WHERE ac.scorreo = v_scorreo
         AND ac.cagente = ap.cagente
         AND ap.cenvcorreo = 1
         AND ac.cenviar = 1
         AND(ac.tcorreo IS NOT NULL
             OR ap.tcorreo IS NOT NULL)
         AND(ac.cagente = pcagente
             OR pcagente IS NULL);
BEGIN
   BEGIN
      numer := pac_contexto.f_inicializarctx(f_parempresa_t('USER_BBDD',
                                                            f_parinstalacion_n('EMPRESADEF')));

      SELECT tatribu
        INTO v_titulo
        FROM detvalores
       WHERE cvalor = 714
         AND catribu = v_scorreo
         AND cidioma = v_cidioma;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, SQLCODE, SQLERRM);
   END;

   vpasexec := 2;
   numer := f_procesini(f_parempresa_t('USER_BBDD', f_parinstalacion_n('EMPRESADEF')),
                        f_parinstalacion_n('EMPRESADEF'), 'ENVIO_CORREO_AGENTE', v_titulo,
                        psproces);

   BEGIN
      vpasexec := 21;
      pfinicio := TO_DATE(pfecha_aaaamm || '01', 'yyyymmdd');
      vpasexec := 22;
      pfinal := LAST_DAY(TO_DATE(pfecha_aaaamm, 'yyyymm'));
   EXCEPTION
      WHEN OTHERS THEN
         numer := 1000147;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'pfecha_aaaamm=' || pfecha_aaaamm || ' -err ' || numer,
                     f_axis_literales(1000147, v_cidioma));
         RETURN numer;
   END;

   /*SELECT '01' || TO_CHAR(f_sysdate - 1, 'mmrrrr'),
          TO_CHAR(LAST_DAY(f_sysdate - 1), 'ddmmrrrr')
     INTO pfini,
          pfin
     FROM DUAL;*/
   SELECT tatribu
     INTO v_adjunto2
     FROM detvalores
    WHERE cvalor = 1904
      AND catribu = 29
      AND cidioma = v_cidioma;

   vfichero2 := '#CODIGOAGENTE#_' || v_adjunto2 || '_#YYYYMM#.PDF';
   pfini := '01' || TO_CHAR(pfinicio, 'mmrrrr');
   pfin := TO_CHAR(LAST_DAY(pfinal), 'ddmmrrrr');
   vpasexec := 3;

--recorremos agentes a los que se les pueda enviar el correo
   FOR c IN c_agentes LOOP
--miramos si genera el listado
      SELECT COUNT(1)
        INTO vcoun
        FROM seguros se, recibos r, vdetrecibos det
       WHERE se.sseguro = r.sseguro
         AND r.nrecibo = det.nrecibo
         AND r.ctiprec = 3   --recibo cartera
         AND(r.cagente, r.cempres) IN(
               SELECT rc.cagente, rc.cempres
                 FROM (SELECT     rc.cagente, rc.cempres
                             FROM redcomercial rc
                            WHERE rc.fmovfin IS NULL
                       START WITH rc.cagente =
                                     NVL(c.cagente,
                                         ff_agente_cpolvisio(pac_user.ff_get_cagente(f_user)))
                       CONNECT BY PRIOR rc.cagente = rc.cpadre
                              AND PRIOR rc.fmovfin IS NULL) rc)
         AND r.fefecto BETWEEN NVL(TO_DATE(LTRIM(TO_CHAR(pfini, '09999999')), 'ddmmrrrr'),
                                   r.fefecto)
                           AND NVL(TO_DATE(LTRIM(TO_CHAR(pfin, '09999999')), 'ddmmrrrr'),
                                   r.fefecto);

      vpasexec := 4;

      IF vcoun > 0 THEN
--listado:
--parametros
         pparams.EXTEND;
         params.nombre_columna := 'PCAGENTE';
         params.valor_columna := c.cagente;
         params.tipo_columna := 1;
         pparams(pparams.LAST) := params;
         pparams.EXTEND;
         params.nombre_columna := 'PFINI';
         params.valor_columna := pfini;
         params.tipo_columna := 1;
         pparams(pparams.LAST) := params;
         pparams.EXTEND;
         params.nombre_columna := 'PFIN';
         params.valor_columna := pfin;
         params.tipo_columna := 1;
         pparams(pparams.LAST) := params;
         numer := pac_iax_informes.f_ejecuta_informe('PRBLIST003',
                                                     f_parinstalacion_n('EMPRESADEF'), 'CSV',
                                                     pparams, 2, 0, NULL, pnomfich, pofich,
                                                     mensajes);
         vpasexec := 5;
         --si hay listado enviamos
         vfichero2 := REPLACE(vfichero2, '#CODIGOAGENTE#', c.cagente);
         vfichero2 := REPLACE(vfichero2, '#YYYYMM#', TO_CHAR(pfenvio, 'YYYYMM'));
         numer := pac_correo.f_envia_correo_agentes(c.cagente, v_cidioma, v_scorreo, pfini,
                                                    pfin, pnomfich, 17, NULL, vdirectorio2,
                                                    vfichero2
                                                             --null
                 );
         vpasexec := 6;

         BEGIN
            SELECT tcorreo
              INTO v_to
              FROM agentes_correo
             WHERE scorreo = v_scorreo
               AND cagente = c.cagente;
         EXCEPTION
            WHEN OTHERS THEN
               v_to := NULL;   --No existe ningún correo de este tipo .
         END;

         vpasexec := 7;

         IF v_to IS NULL THEN
            BEGIN
               SELECT tcorreo
                 INTO v_to
                 FROM agentes_comp
                WHERE cagente = c.cagente;
            EXCEPTION
               WHEN OTHERS THEN
                  v_error := 'no se ha podido encontrar la dirección de correo';   --No existe ningún correo de este tipo .
            END;
         END IF;

         vpasexec := 8;

         IF v_to IS NULL THEN
            v_to := 'no se ha encontrado dirección de correo';
         END IF;

         IF numer <> 0 THEN
            vpasexec := 9;

            INSERT INTO agentes_correo_env
                        (scorreo, cagente, sproces, fenvio, tdocumento, tcorreo, cestado,
                         terror)
                 VALUES (v_scorreo, c.cagente, psproces, pfenvio, pnomfich, v_to, 2,
                         v_error || f_axis_literales(numer, v_cidioma));

            vko := vko + 1;
            numer := f_proceslin(psproces,
                                 numer || ' - ' || f_axis_literales(numer, v_cidioma),
                                 c.cagente, vnprolin, 1);
         ELSE
            vpasexec := 10;

            INSERT INTO agentes_correo_env
                        (scorreo, cagente, sproces, fenvio, tdocumento, tcorreo, cestado,
                         terror)
                 VALUES (v_scorreo, c.cagente, psproces, pfenvio, pnomfich, v_to, 1,
                         f_axis_literales(numer, v_cidioma));

            vok := vok + 1;
            numer := f_proceslin(psproces,
                                 numer || ' - ' || f_axis_literales(numer, v_cidioma),
                                 c.cagente, vnprolin, NULL);
         END IF;
      END IF;
   END LOOP;

   COMMIT;
   vpasexec := 11;

   /*
   v_texto := 'El proceso de ' || v_titulo || ' ha enviado correctamente ' || vok
              || ' correos y ' || vko || ' erróneos. Revisar el proceso ' || psproces
              || ' o la tabla agentes_correo_env para más información.';
   numer := pac_md_informes.f_enviar_mail(NULL, v_toresumen, NULL, NULL,
                                          'Resumen envío proceso ' || psproces, v_texto);*/

   --Resumen
-- Obtenemos el asunto
   SELECT MAX(asunto)
     INTO v_subject
     FROM desmensaje_correo
    WHERE scorreo = 300
      AND cidioma = v_cidioma;

   IF v_subject IS NULL THEN
      --No esixte ningún Subject para este tipo de correo.
      RETURN 151422;
   END IF;

   v_texto := v_subject;
   --reemplazamos
   pos := INSTR(v_subject, '#SPROCES#', 1);

   IF pos > 0 THEN
      v_subject := REPLACE(v_subject, '#SPROCES#', psproces);
   END IF;

   pos := INSTR(v_subject, '#OK#', 1);

   IF pos > 0 THEN
      v_subject := REPLACE(v_subject, '#OK#', vok);
   END IF;

   pos := INSTR(v_subject, '#KO#', 1);

   IF pos > 0 THEN
      v_subject := REPLACE(v_subject, '#KO#', vko);
   END IF;

   pos := INSTR(v_texto, '#TITULO#', 1);

   IF pos > 0 THEN
      v_texto := REPLACE(v_texto, '#TITULO#', v_titulo);
   END IF;

   pos := INSTR(v_texto, '#SPROCES#', 1);

   IF pos > 0 THEN
      v_texto := REPLACE(v_texto, '#SPROCES#', psproces);
   END IF;

   pos := INSTR(v_texto, '#OK#', 1);

   IF pos > 0 THEN
      v_texto := REPLACE(v_texto, '#OK#', vok);
   END IF;

   pos := INSTR(v_texto, '#KO#', 1);

   IF pos > 0 THEN
      v_texto := REPLACE(v_texto, '#KO#', vko);
   END IF;

   numer := pac_md_informes.f_enviar_mail(NULL, v_toresumen, NULL, NULL, v_subject, v_texto);
   vpasexec := 12;
   numer := f_procesfin(psproces, vko);
   RETURN numer;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                  pnomfich || ' -p ' || pofich || ' -n ' || numer, SQLERRM);
      RETURN numer;
END f_correo_cartera;

/

  GRANT EXECUTE ON "AXIS"."F_CORREO_CARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CORREO_CARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CORREO_CARTERA" TO "PROGRAMADORESCSI";
