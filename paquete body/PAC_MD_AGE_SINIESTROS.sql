--------------------------------------------------------
--  DDL for Package Body PAC_MD_AGE_SINIESTROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_AGE_SINIESTROS" AS
/******************************************************************************
    NOMBRE:       PAC_MD_AGE_SINIESTROS
    PROP?SITO:
                Tratamiento de los actores de siniestros

    REVISIONES:
    Ver        Fecha        Autor             Descripci??n
    ---------  ----------  ---------------  ------------------------------------
    1.0        14/03/2012   BFP                1. 0021524: MDP - COM - AGENTES Secci?n siniestros
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*************************************************************************
       Prop?sito:
                    inserir un registre a la taula sin_agentes
       param in psclave     : clave unica
       param in pcagente    : Codigo de agente
       param in pctramte    : Tipo de tramite
       param in pcramo      : c?digo ramo
       param in pctipcod    : Indica si es agente o profesional (VF 740)
       param in pctramitad  : Codigo de tramitador
       param in psprofes    : Codigo de profesional
       param in pcvalora    : Preferido/Excluido (VF 741)
       param in pfinicio    : Fecha desde
       param in pffin       : Fecha hasta
       param in pcusuari    : Usuario creador
       param in pfalta      : Fecha de alta
       param out pmensajes  : mensajes de error
            return             : 0 inserci? correcta
                              <> 0 inserci? incorrecta
   *************************************************************************/
   FUNCTION f_set_actor(
      psclave IN NUMBER,
      pcagente IN NUMBER,
      pctramte IN NUMBER,
      pcramo IN NUMBER,
      pctipcod IN NUMBER,
      pctramitad IN VARCHAR2,
      psprofes IN NUMBER,
      pcvalora IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      pcusuari IN VARCHAR2,
      pfalta IN DATE,
      pmensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := 'psclave: ' || psclave || ' - pcagente: ' || pcagente || ' - pctramte: '
            || pctramte || ' - pcramo: ' || pcramo || ' - pctipcod: ' || pctipcod
            || ' - pctramitad: ' || pctramitad || ' - psprofes: ' || psprofes
            || ' - pcvalora: ' || pcvalora || ' - pfinicio: ' || pfinicio || ' - pffin: '
            || pffin || ' - pcusuari: ' || pcusuari || ' - pfalta: ' || pfalta;
      v_object       VARCHAR2(200) := 'PAC_MD_AGE_SINIESTROS.f_set_actor';
   BEGIN
      v_error := pac_age_siniestros.f_set_actor(psclave, pcagente, pctramte, pcramo, pctipcod,
                                                pctramitad, psprofes, pcvalora, pfinicio,
                                                pffin, pcusuari, pfalta);

      IF v_error <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_actor;

/*************************************************************************
       Prop?sito:
                    donar de baixa l'actor
       param in psclave     : clave ?nica
       param in pffin       : fecha hasta
       param out mensajes   : missatges d'error
            return             : 0 actualitzaci? correcta
                              <> 0 actualitzaci? incorrecta
   *************************************************************************/
   FUNCTION f_remove_actor(psclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500) := 'psclave:' || psclave;
      v_object       VARCHAR2(200) := 'PAC_MD_AGE_SINIESTROS.f_remove_actor';
   BEGIN
      IF (psclave IS NULL) THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_age_siniestros.f_remove_actor(psclave);
      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN v_error;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN v_error;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_error;
   END f_remove_actor;

/*************************************************************************
    Prop?sito: Recuperar los actores
    param in pfecha     : fecha de inicio
    param in pcagente   : codigo del agente
    param out mensajes  : mensajes de error
         return             : cursor con los datos

*************************************************************************/
   FUNCTION f_get_actores(pfecha IN DATE, pcagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500) := 'pfecha:' || pfecha || ' pcagente:' || pcagente;
      v_object       VARCHAR2(200) := 'PAC_MD_AGE_SINIESTROS.f_get_actores';
      v_query        VARCHAR2(4000)
         := 'SELECT sa.sclave "ACTOR", sa.ctipcod "TIPO", ff_desvalorfijo(740,'
            || pac_md_common.f_get_cxtidioma
            || ',sa.ctipcod) TTIPO, DECODE(sa.ctipcod, 1, sa.ctramitad, 2, sa.ctramitad,3, sa.sprofes,4, sa.sprofes, -1) "CODIGO",
       DECODE(sa.ctipcod,
              1, (SELECT sc.ttramitad
                    FROM sin_codtramitador sc
                   WHERE sc.ctramitad = sa.ctramitad),
              2, (SELECT sc.ttramitad
                    FROM sin_codtramitador sc
                   WHERE sc.ctramitad = sa.ctramitad),
              3, (SELECT f_nombre(spp.sperson, 1)
                    FROM sin_prof_profesionales spp
                   WHERE spp.sprofes = sa.sprofes),
              4, (SELECT f_nombre(spp.sperson, 1)
                    FROM sin_prof_profesionales spp
                   WHERE spp.sprofes = sa.sprofes),
              ''SIN NOMBRE'') "NOMBRE",
       (SELECT tramo
          FROM ramos
         WHERE cramo = sa.cramo
           AND cidioma = '
            || pac_md_common.f_get_cxtidioma
            || ') "RAMO", sa.ctramte "TRAMITE",
       sa.cvalora "VALOR",sa.FFIN,ff_desvalorfijo(288,'
            || pac_md_common.f_get_cxtidioma
            || ',sa.ctramte)  TTRAMTE
  FROM sin_agentes sa
 WHERE (sa.ffin > ''' || pfecha || '''
       OR sa.ffin IS NULL)
   AND sa.cagente = ' || pcagente;
      v_cursor       sys_refcursor;
   BEGIN
      IF (pfecha IS NULL)
         OR(pcagente IS NULL) THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      v_cursor := pac_iax_listvalores.f_opencursor(v_query, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN v_cursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN v_cursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
   END f_get_actores;
END pac_md_age_siniestros;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_SINIESTROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_SINIESTROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_SINIESTROS" TO "PROGRAMADORESCSI";
