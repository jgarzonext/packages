--------------------------------------------------------
--  DDL for Package Body PAC_CARGA_SPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGA_SPL" AS
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   FUNCTION f_set_carga_archivo_spl(
      pcdarchi IN VARCHAR2,
      pcarcest IN NUMBER,
      pctiparc IN NUMBER,
      pcsepara IN VARCHAR2,
      pdsproces IN NUMBER)
      RETURN NUMBER IS
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vparam         VARCHAR2(2000)
         := 'cdarchi=' || pcdarchi || ' carcest=' || pcarcest || ' ctiparc=' || pctiparc
            || ' sperson=' || ' csepara=' || pcsepara || ' dsproces=' || pdsproces;
      vobject        VARCHAR2(200) := 'PAC_CARGA_SPL.f_set_carga_archivo_spl';
      vtmsg          VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
      vexidat        NUMBER(8) := 0;
      vnumerr        NUMBER(8) := 0;
      vnomper        VARCHAR2(200);
      vliteral       NUMBER;
      vtabext        VARCHAR2(200);
   --v_host         VARCHAR2(200);
   BEGIN
      IF pcdarchi IS NULL
         OR pcarcest IS NULL
         OR pctiparc IS NULL THEN
         vnumerr := 103135;
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT MAX(NVL(cproceso, 0)) + 1
        INTO vexidat
        FROM cfg_files;

      SELECT MAX(slitera) + 1000000
        INTO vliteral
        FROM axis_literales;

      vpasexec := 3;
      vtabext := f_parinstalacion_t('TABEXT_C');

      INSERT INTO int_carga_archivo_spl
                  (cdarchi, cproces, carcest, ctiparc, csepara)
           VALUES (pcdarchi, vexidat, pcarcest, pctiparc, pcsepara);

      INSERT INTO cfg_files
                  (cempres, cproceso, tdestino, tdestino_bbdd, cdescrip,
                   tproceso, tpantalla, cactivo,
                   ttabla, cpara_error, cborra_fich, cbusca_host, cformato_decimales, ctablas,
                   cjob, cdebug, nregmasivo)
           VALUES (pac_md_common.f_get_cxtempresa, vexidat, vtabext, 'TABEXT', vliteral,
                   'Pac_cargas_msv.f_standing_order_ejecutar', 'axisint001', 1,
                   'INT_CARGA_LOAD_SPL', 0, 0, 1, 0, 'POL',
                   NULL, 99, 1);

      vpasexec := 5;

      INSERT INTO axis_codliterales
           VALUES (vliteral, 1);

      INSERT INTO axis_literales
                  (cidioma, slitera, tlitera)
           VALUES (1, vliteral, 'orden permanente' || ' ' || SUBSTR(pcdarchi, 1, 5));

      vpasexec := 6;

      INSERT INTO axis_literales
                  (cidioma, slitera, tlitera)
           VALUES (2, vliteral, 'orden permanente' || ' ' || SUBSTR(pcdarchi, 1, 5));

      vpasexec := 7;

      INSERT INTO axis_literales
                  (cidioma, slitera, tlitera)
           VALUES (5, vliteral, 'Standing orders' || ' ' || SUBSTR(pcdarchi, 1, 5));

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_CARGA_SPL', vpasexec, 'f_set_carga_archivo_spl',
                     f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_CARGA_SPL', vpasexec, 'f_set_carga_archivo_spl',
                     SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_set_carga_archivo_spl;

/*************************************************************************
   FUNCTION f_set_campo_spl

*************************************************************************/
   FUNCTION f_set_campo_spl(
      pcdarchi IN VARCHAR2,
      pnorden IN NUMBER,
      pccampo IN VARCHAR2,
      pctipcam IN VARCHAR2,
      pnordennew IN NUMBER,
      pccamponew IN VARCHAR2,
      pctipcamnew IN VARCHAR2,
      pnposici IN NUMBER,
      pnlongitud IN NUMBER,
      pntipo IN NUMBER,
      pndecimal IN NUMBER,   --RACS
      pcmask IN VARCHAR2,   --RACS
      pcmodo IN VARCHAR2,
      pcedit IN NUMBER)
      RETURN NUMBER IS
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vparam         VARCHAR2(2000)
         := 'cdarchi=' || pcdarchi || ' NORDEN=' || pnorden || ' CCAMPO =' || pccampo
            || ' CTIPCAM=' || pctipcam || ' NPOSICI =' || pnposici || ' NLONGITUD ='
            || pnlongitud || ' SPERSON =' || ' pntipo =' || pntipo;
      vobject        VARCHAR2(200) := 'PAC_CARGA_SPL.f_set_campo_spl';
      vtmsg          VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
      vexidat        NUMBER(8) := 0;
      vnumerr        NUMBER(8) := 0;
      varchi         VARCHAR2(200);
   BEGIN
      IF pcdarchi IS NULL
         OR pccampo IS NULL
         OR pctipcam IS NULL
         OR pnposici IS NULL
         OR pnlongitud IS NULL
         OR pntipo IS NULL
         OR pcmodo IS NULL THEN
         vnumerr := 103135;
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT 1
        INTO varchi
        FROM int_carga_archivo_spl
       WHERE cdarchi = pcdarchi;

      IF varchi <> 1 THEN
         vnumerr := 9907676;
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcmodo = 'MOD' THEN
         --
         UPDATE int_carga_campo_spl
            SET norden = pnordennew,
                ccampo = pccamponew,
                ctipcam = pctipcamnew,
                nposici = pnposici,
                nlongitud = pnlongitud,
                ntipo = pntipo,
                cdecimal = pndecimal,
                cmask = pcmask,
                cedit = pcedit
          WHERE cdarchi = pcdarchi
            AND norden = pnorden
            AND ccampo = pccampo
            AND ctipcam = pctipcam;
      --
      ELSIF pcmodo = 'ALTA' THEN
         --
         INSERT INTO int_carga_campo_spl
                     (cdarchi, norden, ccampo, ctipcam, nposici, nlongitud, ntipo,
                      cdecimal, cmask, cedit)
              VALUES (pcdarchi, pnorden, pccampo, pctipcam, pnposici, pnlongitud, pntipo,
                      pndecimal, pcmask, pcedit);   --RACS DECIMAL Y MASCARA DEL CAMPO
      --
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CARGA_SPL', vpasexec, 'f_set_carga_archivo_spl',
                     f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CARGA_SPL', vpasexec, 'f_set_carga_archivo_spl',
                     f_axis_literales(9904284));
         RETURN 9904284;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CARGA_SPL', vpasexec, 'f_set_carga_archivo_spl',
                     SQLERRM);
         RETURN 140999;
   -- Error no controlado
   END f_set_campo_spl;

 /*************************************************************************
   FUNCTION f_set_carga_valida_spl

*************************************************************************/
   FUNCTION f_set_carga_valida_spl(
      pcdarchi IN VARCHAR2,
      pccampo1 IN VARCHAR2,
      pctipcam1 IN NUMBER,
      pccampo2 IN VARCHAR2,
      pctipcam2 IN NUMBER,
      pcoperador IN NUMBER)
      RETURN NUMBER IS
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vparam         VARCHAR2(2000)
         := 'cdarchi=' || pcdarchi || 'pccampo1=' || pccampo1 || ' ctipcam1 =' || pctipcam1
            || ' ccampo2=' || pccampo2 || ' ctipcam2 =' || pctipcam2 || ' coperador ='
            || pcoperador;
      vobject        VARCHAR2(200) := 'PAC_CARGA_SPL.f_set_carga_valida_spl';
      vtmsg          VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
      vexidat        NUMBER(8) := 0;
      vnumerr        NUMBER(8) := 0;
      varchi         VARCHAR2(200);
   BEGIN
      IF pcdarchi IS NULL
         OR pccampo1 IS NULL
         OR pctipcam1 IS NULL
         OR pccampo2 IS NULL
         OR pctipcam2 IS NULL
         OR pcoperador IS NULL THEN
         vnumerr := 103135;
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT 1
        INTO varchi
        FROM int_carga_archivo_spl
       WHERE cdarchi = pcdarchi;

      IF varchi <> 1 THEN
         vnumerr := 9907676;
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      INSERT INTO int_carga_valida_spl
                  (cdarchi, ccampo1, ctipcam1, ccampo2, ctipcam2, coperador)
           VALUES (pcdarchi, pccampo1, pctipcam1, pccampo2, pctipcam2, pcoperador);

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CARGA_SPL', vpasexec, 'f_set_carga_archivo_spl',
                     f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CARGA_SPL', vpasexec, 'f_set_carga_archivo_spl',
                     SQLERRM);
         RETURN 140999;
   END f_set_carga_valida_spl;

 /*************************************************************************
   FUNCTION f_set_carga_valida_spl

*************************************************************************/
   FUNCTION f_get_campo_spl(cdarchiv IN VARCHAR2)
      RETURN sys_refcursor IS
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi' || cdarchiv;
      vobject        VARCHAR2(200) := 'f_get_campo_spl';
      terror         VARCHAR2(200);
      num_err        axis_literales.slitera%TYPE := 0;
      cur            sys_refcursor;
   BEGIN
      OPEN cur FOR
         SELECT   i.cdarchi, i.norden, i.ccampo, i.ctipcam,
                  (SELECT d.tatribu
                     FROM detvalores d
                    WHERE d.cvalor = 8001012
                      AND d.catribu = i.ctipcam
                      AND d.cidioma = pac_md_common.f_get_cxtidioma()) tatribu,
                  i.nposici, i.nlongitud,
                  (SELECT d.tatribu
                     FROM detvalores d
                    WHERE d.cvalor = 8001016
                      AND d.catribu = i.ntipo
                      AND d.cidioma = pac_md_common.f_get_cxtidioma()) ntipo,
                  NVL((SELECT d.tatribu
                         FROM detvalores d
                        WHERE d.cvalor = 9
                          AND d.catribu = i.cdecimal
                          AND d.cidioma = pac_md_common.f_get_cxtidioma()),
                      ' ') cdecimal,
                  cmask, cedit,
                  (SELECT d.catribu
                     FROM detvalores d
                    WHERE d.cvalor = 8001012
                      AND d.catribu = i.ctipcam
                      AND d.cidioma = pac_md_common.f_get_cxtidioma()) catribu
             FROM int_carga_campo_spl i
            WHERE i.cdarchi = cdarchiv
         ORDER BY catribu ASC, nposici ASC;

      --   SELECT cdarchi, norden, ccampo, ctipcam, nposici, nlongitud
      --     FROM int_carga_campo_spl
      --    WHERE cdarchi = cdarchiv;
      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_campo_spl;

  /*************************************************************************
   FUNCTION f_get_campo_spl

*************************************************************************/
   FUNCTION f_get_cabecera_spl(cdarchiv IN VARCHAR2)
      RETURN sys_refcursor IS
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi' || cdarchiv;
      vobject        VARCHAR2(200) := 'f_get_cabecera_spl';
      terror         VARCHAR2(200);
      num_err        axis_literales.slitera%TYPE := 0;
      cur            sys_refcursor;
   BEGIN
      OPEN cur FOR
         SELECT i.cdarchi, i.cproces,
                (SELECT d.tatribu
                   FROM detvalores d
                  WHERE d.cvalor = 8000951
                    AND d.catribu = i.carcest
                    AND d.cidioma = pac_md_common.f_get_cxtidioma()) carcest,
                (SELECT d.tatribu
                   FROM detvalores d
                  WHERE d.cvalor = 8000950
                    AND d.catribu = i.ctiparc
                    AND d.cidioma = pac_md_common.f_get_cxtidioma()) ctiparc,
                i.csepara
           FROM int_carga_archivo_spl i
          WHERE i.cdarchi = NVL(cdarchiv, i.cdarchi);

      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cabecera_spl;

  /*************************************************************************
   FUNCTION f_get_campo_spl

*************************************************************************/
   FUNCTION f_get_valida_spl(cdarchiv IN VARCHAR2)
      RETURN sys_refcursor IS
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi' || cdarchiv;
      vobject        VARCHAR2(200) := 'f_get_valida_spl';
      terror         VARCHAR2(200);
      num_err        axis_literales.slitera%TYPE := 0;
      cur            sys_refcursor;
   BEGIN
      OPEN cur FOR
         SELECT cdarchi, ccampo1, DECODE(ctipcam1, 1, 'HEADER', 'FOOTER') ctipcam1, ccampo2,
                DECODE(ctipcam2, 2, 'CONTENT', NULL) ctipcam2,
                DECODE(coperador, 1, 'SUM', 'COUNT') coperador
           FROM int_carga_valida_spl
          WHERE cdarchi = cdarchiv;

      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_valida_spl;

/*************************************************************************
   FUNCTION f_del_campo_spl
   Borra los registros de la tabla int_carga_campo_spl

*************************************************************************/
   FUNCTION f_del_campo_spl(
      pcdarchi IN int_carga_campo_spl.cdarchi%TYPE,
      pnorden IN int_carga_campo_spl.norden%TYPE,
      pccampo IN int_carga_campo_spl.ccampo%TYPE,
      pctipcam IN int_carga_campo_spl.ctipcam%TYPE)
      RETURN NUMBER IS
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
   BEGIN
      DELETE FROM int_carga_campo_spl
            WHERE cdarchi = pcdarchi
              AND norden = pnorden
              AND ccampo = pccampo
              AND ctipcam = pctipcam;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CARGA_SPL', 1, 'f_del_campo_spl', SQLERRM);
         RETURN 140999;
   END f_del_campo_spl;

/*************************************************************************
   FUNCTION f_del_valida_spl
   Borra un registro de la tabla int_carga_valida_spl

*************************************************************************/
   FUNCTION f_del_valida_spl(pcdarchi IN VARCHAR2)
      RETURN NUMBER IS
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
   BEGIN
      DELETE FROM int_carga_valida_spl
            WHERE cdarchi = pcdarchi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CARGA_SPL', 1, 'f_del_valida_spl', SQLERRM);
         RETURN 140999;
   END f_del_valida_spl;

   FUNCTION f_get_int_campo_spl(
      pcdarchi IN int_carga_campo_spl.cdarchi%TYPE,
      pnorden IN int_carga_campo_spl.norden%TYPE,
      pccampo IN int_carga_campo_spl.ccampo%TYPE,
      pctipcam IN int_carga_campo_spl.ctipcam%TYPE,
      obccampo OUT ob_iax_cargacampo_spl,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcdarchi= ' || pcdarchi || ' pnorden= ' || pnorden || ' pccampo= ' || pccampo
            || ' pctipcam= ' || pctipcam;
      vobject        VARCHAR2(200) := 'PAC_CARGA_SPL.f_get_int_campo_spl';
   --
   BEGIN
      --
      IF pcdarchi IS NULL
         OR pnorden IS NULL
         OR pccampo IS NULL
         OR pctipcam IS NULL THEN
         RAISE e_param_error;
      END IF;

      --
      vpasexec := 2;
      --
      obccampo := ob_iax_cargacampo_spl();

      --
      SELECT cdarchi, norden, ccampo, ctipcam,
             nposici, nlongitud, ntipo, cdecimal,
             cmask, cedit
        INTO obccampo.cdarchi, obccampo.norden, obccampo.ccampo, obccampo.ctipcam,
             obccampo.nposici, obccampo.nlongitud, obccampo.ntipo, obccampo.cdecimal,
             obccampo.cmask, obccampo.cedit
        FROM int_carga_campo_spl i
       WHERE i.cdarchi = pcdarchi
         AND i.norden = pnorden
         AND i.ccampo = pccampo
         AND i.ctipcam = pctipcam;

      --
      RETURN vnumerr;
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1000006;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1000005;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 140999;
   END f_get_int_campo_spl;
END pac_carga_spl;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGA_SPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_SPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_SPL" TO "PROGRAMADORESCSI";
