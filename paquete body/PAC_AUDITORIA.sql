--------------------------------------------------------
--  DDL for Package Body PAC_AUDITORIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AUDITORIA" AS
 /*****************************************************************************************
      NOMBRE:      PAC_AUDITORIA
      PROPÓSITO: Funciones para la auditoria
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ----------------------------------------------
      1.0        27/04/2012    lcf            1. Creación del package.
      2.0        27/04/2012    lcf            2. 0110901 p_get_rec_rastros - PROCESO REGISTRO DE RASTROS DE AUDITORIA
      3.0        27/01/2014    RCL            3. 0029765: LCOL_MILL-LCOL - Fase Mejoras - Proceso nocturno de auditoria

   **************************************************************************************/
/****************************************************************************************
       Prcedimiento p_get_rec_rastros, PROCESO REGISTRO DE RASTROS DE AUDITORIA
       Registra todos los cambios en Tabla AUD_RASTROS
       param in  p_fecha_ini,
                 p_fecha_fin,
                 p_login
    ************************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   PROCEDURE p_get_rec_rastros(
      p_fecha_ini IN DATE,
      p_fecha_fin IN DATE,
      p_login IN VARCHAR2 DEFAULT NULL) IS
      v_object       VARCHAR2(500) := 'PAC_AUDITORIA.f_get_rec_rastros';
      v_param        VARCHAR2(500)
         := 'params : p_fecha_ini : ' || p_fecha_ini || ', p_fecha_fin  ' || p_fecha_fin
            || ', p_login : ' || p_login;
      v_pasexec      NUMBER(5) := 1;
      num_err        NUMBER := 0;
      vnumerr        NUMBER := 0;
      v_titulo       VARCHAR2(2000);
      v_ttexto       VARCHAR2(1000);
      v_llinia       NUMBER := 0;
      pcidioma       NUMBER;
      pcempres       NUMBER;
      nsrastro       NUMBER := 0;
      psproces       NUMBER;

      CURSOR c1 IS
         SELECT   *
             FROM (SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = lc.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = lc.cusuari) numero_id_usuario,
                          lc.cusuari login, 'LOGIN' codigo_evento, lc.fconexion fecha,
                          lc.nipusu id_terminal,
                          DECODE(NVL(lc.msg, 'INFO'), 'INFO', 'INFO', 'ERROR') severidad,
                          DECODE(NVL(lc.msg, 'OK'), 'OK', 'OK', 'KO') codigo_respuesta,
                          NULL codigo_confirmacion, 'Número de sesión' origen_codigo_entidad,
                          'Conexión' origen_tipo_producto,
                          TO_CHAR(session_id) origen_numero_producto
                     FROM log_conexion lc
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusumov) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusumov) numero_id_usuario,
                          m.cusumov login, 'POLIZA' codigo_evento, m.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = m.cusumov
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = m.cusumov
                                                     AND lc2.fconexion <= m.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de póliza' origen_codigo_entidad,
                          ms.tmotmov origen_tipo_producto,
                          TO_CHAR(s.npoliza) origen_numero_producto
                     FROM movseguro m, seguros s, motmovseg ms
                    WHERE m.sseguro = s.sseguro
                      AND m.cmotmov = ms.cmotmov
                      AND ms.cidioma = pac_md_common.f_get_cxtidioma
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusualt) numero_id_usuario,
                          m.cusualt login, 'SINIESTRO' codigo_evento, m.festsin fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = m.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = m.cusualt
                                                     AND lc2.fconexion <= m.festsin)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de siniestro' origen_codigo_entidad,
                          ff_desvalorfijo(6,
                                          pac_md_common.f_get_cxtidioma,
                                          m.cestsin) origen_tipo_producto,
                          si.nsinies origen_numero_producto
                     FROM sin_movsiniestro m, sin_siniestro si, seguros s
                    WHERE m.nsinies = si.nsinies
                      AND si.sseguro = s.sseguro
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusualt) numero_id_usuario,
                          m.cusualt login, 'TRAMITACION' codigo_evento, m.festtra fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = m.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = m.cusualt
                                                     AND lc2.fconexion <= m.festtra)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de siniestro' origen_codigo_entidad,
                          ff_desvalorfijo(6,
                                          pac_md_common.f_get_cxtidioma,
                                          m.cesttra)
                          || ', '
                          || ff_desvalorfijo
                                          (665,
                                           pac_md_common.f_get_cxtidioma,
                                           m.csubtra) origen_tipo_producto,
                          si.nsinies origen_numero_producto
                     FROM sin_tramita_movimiento m, sin_siniestro si, seguros s
                    WHERE m.nsinies = si.nsinies
                      AND si.sseguro = s.sseguro
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusualt) numero_id_usuario,
                          m.cusualt login, 'PAGO' codigo_evento, m.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = m.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = m.cusualt
                                                     AND lc2.fconexion <= m.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de siniestro' origen_codigo_entidad,
                          ff_desvalorfijo(324,
                                          pac_md_common.f_get_cxtidioma,
                                          m.cestpag) origen_tipo_producto,
                          si.nsinies origen_numero_producto
                     FROM sin_tramita_movpago m, sin_tramita_pago pag, sin_siniestro si,
                          seguros s
                    WHERE m.sidepag = pag.sidepag
                      AND pag.nsinies = si.nsinies
                      AND si.sseguro = s.sseguro
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusualt) numero_id_usuario,
                          m.cusualt login, 'DESTINATARIO' codigo_evento, m.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = m.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = m.cusualt
                                                     AND lc2.fconexion <= m.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de siniestro' origen_codigo_entidad,
                          'Creación' origen_tipo_producto, si.nsinies origen_numero_producto
                     FROM sin_tramita_destinatario m, sin_siniestro si, seguros s
                    WHERE m.nsinies = si.nsinies
                      AND si.sseguro = s.sseguro
                      AND m.cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = m.cusumod) numero_id_usuario,
                          m.cusumod login, 'DESTINATARIO' codigo_evento, m.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = m.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = m.cusumod
                                                     AND lc2.fconexion <= m.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de siniestro' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          si.nsinies origen_numero_producto
                     FROM sin_tramita_destinatario m, sin_siniestro si, seguros s
                    WHERE m.nsinies = si.nsinies
                      AND si.sseguro = s.sseguro
                      AND m.cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = p.sperson
                              AND tm.sseguro = s.sseguro
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = si.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = si.cusumod) numero_id_usuario,
                          si.cusumod login, 'SINIESTRO' codigo_evento, si.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = si.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = si.cusumod
                                                     AND lc2.fconexion <= si.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de siniestro' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          si.nsinies origen_numero_producto
                     FROM hissin_siniestro si, sin_siniestro si2, seguros s
                    WHERE si.nsinies = si2.nsinies
                      AND si2.sseguro = s.sseguro
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'ACCION SEGUN CAUSA MOTIVO' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Secuencia Causa/Motivo' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(scaumot) origen_numero_producto
                     FROM sin_causa_motivo a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'ACCION SEGUN CAUSA MOTIVO' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Secuencia Causa/Motivo' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(scaumot) origen_numero_producto
                     FROM sin_causa_motivo a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'CAUSA ESTADO SINIESTRO' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Causa Estado' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(ccauest) origen_numero_producto
                     FROM sin_codcauest a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'CAUSA ESTADO SINIESTRO' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Causa Estado' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(ccauest) origen_numero_producto
                     FROM sin_codcauest a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'CAUSA SINIESTRO' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Causa' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(ccausin) origen_numero_producto
                     FROM sin_codcausa a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'CAUSA SINIESTRO' codigo_evento, a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Causa' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(ccausin) origen_numero_producto
                     FROM sin_codcausa a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'EVENTO SINIESTRO' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Evento' origen_codigo_entidad,
                          'Creación' origen_tipo_producto, a.cevento origen_numero_producto
                     FROM sin_codevento a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'CAUSA SINIESTRO' codigo_evento, a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Causa' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.cevento origen_numero_producto
                     FROM sin_codevento a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'MOTIVOS CAUSA SINIESTRO' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Causa-Motivo' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.ccausin || '-' || a.cmotsin origen_numero_producto
                     FROM sin_codmotcau a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'MOTIVOS CAUSA SINIESTRO' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Causa-Motivo' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.ccausin || '-' || a.cmotsin origen_numero_producto
                     FROM sin_codmotcau a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'MOTIVOS RESCATE SINIESTRO' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Producto-Causa-Motivo' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sproduc || '-' || a.ccausin || '-'
                          || a.cmotresc origen_numero_producto
                     FROM sin_codmotresccau a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'MOTIVOS RESCATE SINIESTRO' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Producto-Causa-Motivo' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.sproduc || '-' || a.ccausin || '-'
                          || a.cmotresc origen_numero_producto
                     FROM sin_codmotresccau a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'TIPOS TRAMITADORES' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Tipo Tramitador' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.ctiptramit) origen_numero_producto
                     FROM sin_codtiptramitador a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'TIPOS TRAMITADORES' codigo_evento, a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Tipo Tramitador' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.ctiptramit) origen_numero_producto
                     FROM sin_codtiptramitador a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'TRAMITACIONES SINIESTROS' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Tramitación' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.ctramit) origen_numero_producto
                     FROM sin_codtramitacion a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'TRAMITACIONES SINIESTROS' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Tramitación' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.ctramit) origen_numero_producto
                     FROM sin_codtramitacion a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'CONCEPTOS CAUSAS INDEMNIZACION PAGO' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código  Pago-Destinatario-Concepto-Causa' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.ctippag || '-' || a.ctipdes || '-'
                          || a.cconpag || '-' || ccauind origen_numero_producto
                     FROM sin_datpago a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'CONCEPTOS CAUSAS INDEMNIZACION PAGO' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Pago-Destinatario-Concepto-Causa' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.ctippag || '-' || a.ctipdes || '-'
                          || a.cconpag || '-' || ccauind origen_numero_producto
                     FROM sin_datpago a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'DETALLE CAUSAS Y MOTIVOS' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Secuencia Causa/Motivo - Tipo Destinatario' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.scaumot || '-' || a.ctipdes origen_numero_producto
                     FROM sin_det_causa_motivo a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'DETALLE CAUSAS Y MOTIVOS' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Secuencia Causa/Motivo - Tipo Destinatario' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.scaumot || '-' || a.ctipdes origen_numero_producto
                     FROM sin_det_causa_motivo a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'TARIFAS PROFESIONALES' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Secuencia tarifa - Linea' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.starifa || '-' || a.nlinea origen_numero_producto
                     FROM sin_dettarifas a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'FORMULAS CAUSAS Y MOTIVOS' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Secuencia Causa/Motivo - Tipo Destinatario - Campo'
                                                                         origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.scaumot || '-' || a.ctipdes || '-'
                          || a.ccampo origen_numero_producto
                     FROM sin_for_causa_motivo a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'FORMULAS CAUSAS Y MOTIVOS' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Secuencia Causa/Motivo - Tipo Destinatario - Campo'
                                                                         origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.scaumot || '-' || a.ctipdes || '-'
                          || a.ccampo origen_numero_producto
                     FROM sin_for_causa_motivo a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'GARANTIAS CAUSAS Y MOTIVOS' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Garantia-Causa-Motivo' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.cgarant || '-' || a.ccausin || '-'
                          || a.cmotsin origen_numero_producto
                     FROM sin_gar_causa a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'GARANTIAS CAUSAS Y MOTIVOS' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Garantia-Causa-Motivo' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.cgarant || '-' || a.ccausin || '-'
                          || a.cmotsin origen_numero_producto
                     FROM sin_gar_causa a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'GARANTIAS CAUSAS Y MOTIVOS (2)' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Garantia-Causa-Motivo' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.cgarant || '-' || a.scaumot || '-'
                          || a.ctramit origen_numero_producto
                     FROM sin_gar_causa_motivo a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'GARANTIAS CAUSAS Y MOTIVOS (2)' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Garantia-Causa/Motivo-Tramitación'
                                                                         origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.cgarant || '-' || a.scaumot || '-'
                          || a.ctramit origen_numero_producto
                     FROM sin_gar_causa_motivo a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PREGUNTAS-GARANTIAS PARA RESERVAS' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Garantia-Tramitación-Pregunta'
                                                                         origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.cgarant || '-' || a.ctramit || '-'
                          || a.cpregun origen_numero_producto
                     FROM sin_gar_pregunta a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PREGUNTAS-GARANTIAS PARA RESERVAS' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Garantia-Tramitación-Pregunta'
                                                                         origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.cgarant || '-' || a.ctramit || '-'
                          || a.cpregun origen_numero_producto
                     FROM sin_gar_pregunta a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'GARANTIAS POR TRAMITACIONES' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Garantia-Tramitación' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.cgarant || '-' || a.ctramit origen_numero_producto
                     FROM sin_gar_tramitacion a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'GARANTIAS POR TRAMITACIONES' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Garantia-Tramitación' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.cgarant || '-' || a.ctramit origen_numero_producto
                     FROM sin_gar_tramitacion a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PARAMETRIZACION GESTIONES' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Gestión-Movimiento' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.ctipges || '-' || a.ctipmov origen_numero_producto
                     FROM sin_parges_movimientos a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'SINIESTROS PREGUNTAS' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Tramitación-Pregunta' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.ctramit || '-' || a.cpregun origen_numero_producto
                     FROM sin_pro_pregunta a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'SINIESTROS PREGUNTAS' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Tramitación-Pregunta' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.ctramit || '-' || a.cpregun origen_numero_producto
                     FROM sin_pro_pregunta a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'TRAMITACIONES POR PRODUCTO' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Tramitación-Tramite' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.ctramit || '-' || a.ctramte origen_numero_producto
                     FROM sin_pro_tramitacion a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'TRAMITACIONES POR PRODUCTO' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Tramitación-Tramite' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.ctramit || '-' || a.ctramte origen_numero_producto
                     FROM sin_pro_tramitacion a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'TRAMITES POR PRODUCTO' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Tramite' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.ctramte origen_numero_producto
                     FROM sin_prod_tramite a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'TRAMITES POR PRODUCTO' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Producto-Actividad-Tramite' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.sproduc || '-' || a.cactivi || '-'
                          || a.ctramte origen_numero_producto
                     FROM sin_prod_tramite a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'CARGA TRABAJO' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Profesional-Tipo-Subtipo-Inicio' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sprofes || '-' || a.ctippro || '-'
                          || csubpro || '-'
                          || TO_CHAR(fdesde, 'yyymmdd') origen_numero_producto
                     FROM sin_prof_carga a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'CARGA REAL TRABAJO' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Profesional-Tipo-Subtipo-Inicio' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.sprofes || '-' || a.ctippro || '-'
                          || csubpro || '-'
                          || TO_CHAR(fdesde, 'yyymmdd') origen_numero_producto
                     FROM sin_prof_carga_real a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'APUNTES' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de apunte' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.idapunte) origen_numero_producto
                     FROM agd_apunte a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'APUNTES' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de apunte' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.idapunte) origen_numero_producto
                     FROM agd_hisapunte a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'APUNTES' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de apunte' origen_codigo_entidad,
                          ff_desvalorfijo(29,
                                          pac_md_common.f_get_cxtidioma,
                                          a.cestapu) origen_tipo_producto,
                          TO_CHAR(a.idapunte) origen_numero_producto
                     FROM agd_movapunte a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'AGENDA' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de agenda' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.idagenda) origen_numero_producto
                     FROM agd_agenda a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'AGENDA' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de agenda' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.idagenda) origen_numero_producto
                     FROM agd_hisagenda a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'AGENDA' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de agenda' origen_codigo_entidad,
                          ff_desvalorfijo(29,
                                          pac_md_common.f_get_cxtidioma,
                                          a.cestagd) origen_tipo_producto,
                          TO_CHAR(a.idagenda) origen_numero_producto
                     FROM agd_movagenda a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'OBSERVACIONES' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de observación' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.idobs) origen_numero_producto
                     FROM agd_observaciones a
                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'OBSERVACIONES' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de observación' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.idobs) origen_numero_producto
                     FROM agd_observaciones a
                    WHERE cusumod IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'AGENDA' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de agenda' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.idobs) origen_numero_producto
                     FROM agd_hisobserv a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'AGENDA' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de agenda' origen_codigo_entidad,
                          ff_desvalorfijo(29,
                                          pac_md_common.f_get_cxtidioma,
                                          a.cestobs) origen_tipo_producto,
                          TO_CHAR(a.idobs) origen_numero_producto
                     FROM agd_movobs a
                   /*
                      T A B L A S       P E R S O N A S
                   */
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_personas a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_personas
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_personas a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS DETALLE' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_detper a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_detper
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS DETALLE' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_detper a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualta) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualta) numero_id_usuario,
                          a.cusualta login, 'PERSONAS CCC' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualta
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualta
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_ccc a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_ccc
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumov) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumov) numero_id_usuario,
                          a.cusumov login, 'PERSONAS CCC' codigo_evento, a.fusumov fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumov
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumov
                                                     AND lc2.fconexion <= a.fusumov)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_ccc a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS CONTACTO' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_contactos a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_contactos
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS CONTACTO' codigo_evento, a.fusumod fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_contactos a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS DIRECCION' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_direcciones a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_direcciones
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS DIRECCION' codigo_evento, a.fusumod fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_direcciones a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS VINCULO' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_vinculos a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_vinculos
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS DIRECCION' codigo_evento, a.fusumod fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          DECODE(norden, 1, 'Creación', 'Actualización') origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_vinculos a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PERSONAS REG FISCAL' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_regimenfiscal a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS POTENCIAL' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_potencial a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PERSONAS DOCUMENTO' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_documentos a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_documentos
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS DOCUMENTO' codigo_evento, a.fusumod fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_documentos a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS IRPF' codigo_evento,
                          TO_DATE(a.fmovimi, 'dd/mm/yy') fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_irpf a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_irpf
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS IRPF' codigo_evento,
                          TO_DATE(a.fusumod, 'dd/mm/yy') fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          DECODE(norden, 1, 'Creación', 'Actualización') origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_irpf a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS IRPFDESCEN' codigo_evento,
                          TO_DATE(a.fmovimi, 'dd/mm/yy') fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_irpfdescen a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS IRPFDESCEN' codigo_evento,
                          a.fusumod fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_irpfdescen a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS IRPFMAYORES' codigo_evento,
                          TO_DATE(a.fmovimi, 'dd/mm/yy') fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_irpfmayores a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS IRPFMAYORES' codigo_evento,
                          a.fusumod fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_irpfmayores a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS LOPD' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_lopd a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_lopd
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS LOPD' codigo_evento, a.fusumod fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          DECODE(a.norden,
                                 1, 'Creación',
                                 'Actualización') origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_lopd a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuari) numero_id_usuario,
                          a.cusuari login, 'PERSONAS REL' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuari
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuari
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_personas_rel a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_personas_rel
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS REL' codigo_evento, a.fusumod fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_personas_rel a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PERSONAS SARLAF' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM per_sarlaft a
                    WHERE NOT EXISTS(SELECT '1'
                                       FROM hisper_sarlaft
                                      WHERE sperson = a.sperson)
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PERSONAS DOCUMENTO' codigo_evento, a.fusumod fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fusumod)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_sarlaft a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) tipo_id_cliente,
                          (SELECT p.nnumide
                             FROM tomadores tm, per_personas p
                            WHERE tm.sperson = a.sperson
                              AND p.sperson = tm.sperson
                              AND ROWNUM = 1) numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PERSONAS NACION' codigo_evento, a.fmovimi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.fmovimi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_fmovimi,
                          'Identificador de persona' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.sperson) origen_numero_producto
                     FROM hisper_nacionalidades a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU CODIGO CONTROL' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.ccontrol) origen_numero_producto
                     FROM psu_codcontrol a
--                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU CODIGO CONTROL' codigo_evento, a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.ccontrol) origen_numero_producto
                     FROM his_psu_codcontrol a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU CODIGO NIVEL' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Nivel' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.cnivel) origen_numero_producto
                     FROM psu_codnivel a
--                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU CODIGO NIVEL' codigo_evento, a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Nivel' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.cnivel) origen_numero_producto
                     FROM his_psu_codnivel a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU CODIGO AGRUPACION' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Agrupación' origen_codigo_entidad,
                          'Creación' origen_tipo_producto, a.cusuagru origen_numero_producto
                     FROM psu_codusuagru a
--                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU CODIGO AGRUPACION' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Agrupación' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.cusuagru origen_numero_producto
                     FROM his_psu_codusuagru a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU FORMULA' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control - Producto' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.ccontrol || '-' || a.sproduc origen_numero_producto
                     FROM psu_controlpro a
--                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU FORMULA' codigo_evento, a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control - Producto' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.ccontrol || '-' || a.sproduc origen_numero_producto
                     FROM his_psu_controlpro a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusubaja) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusubaja) numero_id_usuario,
                          a.cusubaja login, 'PSU FORMULA' codigo_evento, a.fbaja fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusubaja
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusubaja
                                                     AND lc2.fconexion <= a.fbaja)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control - Producto' origen_codigo_entidad,
                          'Baja' origen_tipo_producto,
                          a.ccontrol || '-' || a.sproduc origen_numero_producto
                     FROM psu_controlpro a
                    WHERE fbaja IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU DESCRIPCION CONTROL' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.ccontrol) origen_numero_producto
                     FROM psu_descontrol a
--                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU DESCRIPCION CONTROL' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.ccontrol) origen_numero_producto
                     FROM his_psu_descontrol a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU DESCRIPCION NIVEL' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Nivel' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(a.cnivel) origen_numero_producto
                     FROM psu_desnivel a
--                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU DESCRIPCION NIVEL' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Nivel' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          TO_CHAR(a.cnivel) origen_numero_producto
                     FROM his_psu_desnivel a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU RESULTADO' codigo_evento, a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control-Producto-Nivel' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.ccontrol || '-' || a.sproduc || '-'
                          || a.cnivel origen_numero_producto
                     FROM psu_desresultado a
--                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU RESULTADO' codigo_evento, a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control-Producto-Nivel' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.ccontrol || '-' || a.sproduc || '-'
                          || a.cnivel origen_numero_producto
                     FROM his_psu_desresultado a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU DESCRIPCION AGRUPACION' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Agrupación' origen_codigo_entidad,
                          'Creación' origen_tipo_producto, a.cusuagru origen_numero_producto
                     FROM psu_desusuagru a
--                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU DESCRIPCION AGRUPACION' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Agrupación' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.cusuagru origen_numero_producto
                     FROM his_psu_desusuagru a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU NIVEL POR CONTROL' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control-Producto' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.ccontrol || '-' || a.sproduc origen_numero_producto
                     FROM psu_nivel_control a
--                    WHERE cusumod IS NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU NIVEL POR CONTROL' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Control-Producto' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.ccontrol || '-' || a.sproduc origen_numero_producto
                     FROM his_psu_nivel_control a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuret) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuret) numero_id_usuario,
                          a.cusuret login, 'PSU RETENIDAS' codigo_evento, a.ffecret fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuret
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuret
                                                     AND lc2.fconexion <= a.ffecret)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de Póliza' origen_codigo_entidad,
                          'Retención' origen_tipo_producto,
                          TO_CHAR(s.npoliza) origen_numero_producto
                     FROM psu_retenidas a, seguros s
                    WHERE s.sseguro = a.sseguro
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuaut) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuaut) numero_id_usuario,
                          a.cusuaut login, 'PSU RETENIDAS' codigo_evento, a.ffecaut fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuaut
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuaut
                                                     AND lc2.fconexion <= a.ffecaut)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de Póliza' origen_codigo_entidad,
                          'Autorización' origen_tipo_producto,
                          TO_CHAR(s.npoliza) origen_numero_producto
                     FROM psu_retenidas a, seguros s
                    WHERE s.sseguro = a.sseguro
                      AND cusuaut IS NOT NULL
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU USUARIOS POR AGRUPACION' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Usuario' origen_codigo_entidad,
                          'Creación' origen_tipo_producto, a.cusuari origen_numero_producto
                     FROM psu_usuagru a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU USUARIOS POR AGRUPACION' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Usuario' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.cusuari origen_numero_producto
                     FROM his_psu_usuagru a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusualt) numero_id_usuario,
                          a.cusualt login, 'PSU NIVEL AGRUPACION USUARIO' codigo_evento,
                          a.falta fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusualt
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusualt
                                                     AND lc2.fconexion <= a.falta)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Agrupación-Producto' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          a.cusuagru || '-' || a.sproduc origen_numero_producto
                     FROM psu_usuagru_nivel a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumod) numero_id_usuario,
                          a.cusumod login, 'PSU NIVEL AGRUPACION USUARIO' codigo_evento,
                          a.fmodifi fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumod
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumod
                                                     AND lc2.fconexion <= a.fmodifi)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Código Agrupación-Producto' origen_codigo_entidad,
                          'Actualización' origen_tipo_producto,
                          a.cusuagru || '-' || a.sproduc origen_numero_producto
                     FROM his_psu_usuagru_nivel a
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumov) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusumov) numero_id_usuario,
                          a.cusumov login, 'PSU NIVEL AGRUPACION USUARIO' codigo_evento,
                          a.fmovpsu fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusumov
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusumov
                                                     AND lc2.fconexion <= a.fmovpsu)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de póliza' origen_codigo_entidad,
                          'Creación' origen_tipo_producto,
                          TO_CHAR(npoliza) origen_numero_producto
                     FROM psucontrolseg a, seguros s
                    WHERE s.sseguro = a.sseguro
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuaur) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuaur) numero_id_usuario,
                          a.cusuaur login, 'PSU NIVEL AGRUPACION USUARIO' codigo_evento,
                          a.fautrec fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuaur
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuaur
                                                     AND lc2.fconexion <= a.fautrec)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de póliza' origen_codigo_entidad,
                          'Autorización' origen_tipo_producto,
                          TO_CHAR(npoliza) origen_numero_producto
                     FROM psucontrolseg a, seguros s
                    WHERE s.sseguro = a.sseguro
                      AND a.cautrec = 1
                   UNION
                   SELECT NULL id_registro, 'IAXIS' id_canal, NULL tipo_id_cliente,
                          NULL numero_id_cliente,
                          (SELECT ff_desvalorfijo
                                               (672,
                                                pac_md_common.f_get_cxtidioma,
                                                p.ctipide)
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuaur) tipo_id_usuario,
                          (SELECT p.nnumide
                             FROM usuarios u, agentes ag, per_personas p
                            WHERE u.cdelega = ag.cagente
                              AND ag.sperson = p.sperson
                              AND u.cusuari = a.cusuaur) numero_id_usuario,
                          a.cusuaur login, 'PSU NIVEL AGRUPACION USUARIO' codigo_evento,
                          a.fautrec fecha,
                          (SELECT nipusu
                             FROM log_conexion lc
                            WHERE lc.cusuari = a.cusuaur
                              AND lc.fconexion = (SELECT MAX(lc2.fconexion)
                                                    FROM log_conexion lc2
                                                   WHERE lc2.cusuari = a.cusuaur
                                                     AND lc2.fconexion <= a.fautrec)
                              AND ROWNUM = 1) id_terminal,
                          NULL severidad, NULL codigo_respuesta, NULL codigo_confirmacion,
                          'Número de póliza' origen_codigo_entidad,
                          'Rechazo' origen_tipo_producto,
                          TO_CHAR(npoliza) origen_numero_producto
                     FROM psucontrolseg a, seguros s
                    WHERE s.sseguro = a.sseguro
                      AND a.cautrec = 2)
            WHERE (p_fecha_ini IS NULL
                   OR TRUNC(fecha) >= p_fecha_ini)
              AND(p_fecha_fin IS NULL
                  OR TRUNC(fecha) <= p_fecha_fin)
              AND login = NVL(p_login, login)
         ORDER BY fecha, login;
   BEGIN
      v_pasexec := 1;

      IF f_user IS NULL THEN
         pac_iax_login.p_iax_iniconnect
                             (pac_parametros.f_parempresa_t(f_parinstalacion_n('EMPRESADEF'),
                                                            'USER_BBDD'));
         pcidioma := pac_iax_common.f_get_cxtidioma;
         pcempres := pac_iax_common.f_get_cxtempresa;
      ELSE
         pcidioma := pac_iax_common.f_get_cxtidioma;
         pcempres := pac_iax_common.f_get_cxtempresa;
      END IF;

      v_titulo := 'PROCESO REGISTRO DE RASTROS DE AUDITORIA';
      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      vnumerr := f_procesini(f_user, pcempres, 'AUDITORIA ', v_titulo, psproces);

      IF vnumerr = 0 THEN
         v_pasexec := 2;

         IF p_fecha_ini IS NULL
            OR p_fecha_fin IS NULL THEN
            num_err := 101688;
         ELSE
            v_pasexec := 3;

            FOR i IN c1 LOOP
               SELECT srastro.NEXTVAL
                 INTO nsrastro
                 FROM DUAL;

               IF nsrastro IS NULL THEN
                  ROLLBACK;
                  num_err := 1;
               END IF;

               IF num_err <> 1 THEN
                  v_pasexec := 4;

                  BEGIN
                     INSERT INTO aud_rastros
                                 (srastro, ccanal,
                                  tipidcli,
                                  numidcli,
                                  tipidudu,
                                  numidusu,
                                  login,
                                  ccodeven, frastro,
                                  cterminal, cseveridad,
                                  crespue,
                                  cconfirm,
                                  ccodent,
                                  ctipprod,
                                  cnumprod)
                          VALUES (nsrastro, SUBSTR(i.id_canal, 1, 10),
                                  SUBSTR(i.tipo_id_cliente, 1, 25),
                                  SUBSTR(i.numero_id_cliente, 1, 50),
                                  SUBSTR(i.tipo_id_usuario, 1, 25),
                                  SUBSTR(i.numero_id_usuario, 1, 50),
                                  SUBSTR(NVL(p_login, i.login), 1, 20),
                                  SUBSTR(i.codigo_evento, 1, 20), i.fecha,
                                  SUBSTR(i.id_terminal, 1, 50), SUBSTR(i.severidad, 1, 10),
                                  SUBSTR(i.codigo_respuesta, 1, 10),
                                  SUBSTR(i.codigo_confirmacion, 1, 10),
                                  SUBSTR(i.origen_codigo_entidad, 1, 50),
                                  SUBSTR(i.origen_tipo_producto, 1, 50),
                                  SUBSTR(i.origen_numero_producto, 1, 50));
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                        p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                                    SQLCODE || ' - ' || SQLERRM);
                        num_err := 1;
                  END;
               END IF;
            END LOOP;
         END IF;
      END IF;

      IF num_err <> 0 THEN   -- hay errores
         v_ttexto := f_axis_literales(num_err, pcidioma);
         vnumerr := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         vnumerr := f_procesfin(psproces, 1);
         ROLLBACK;
      END IF;

      vnumerr := f_procesfin(psproces, 1);
      num_err := 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         num_err := 1;
   END p_get_rec_rastros;

   /************************************************************************************
       Inicia una auditoria.
       param in  pcusuari: Usuario de la ejecución
                 pcempres: Empresa asociada
                 pcaudit: Código de auditoria
                 ptaudit: Texto de la auditoria
       param out psauditoria: Número de proceso de la auditoria
   ************************************************************************************/
   FUNCTION f_auditoriaini(
      pcusuari IN VARCHAR2,
      pcempres IN NUMBER,
      pcaudit IN VARCHAR2,
      ptaudit IN VARCHAR2,
      psauditoria OUT NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      wfecha         DATE;
      wproces        NUMBER;
   BEGIN
      -- Recuperamos la fecha
      wfecha := f_sysdate;

      -- Recuperamos el sigueinte código de proceso
      SELECT sauditoria.NEXTVAL
        INTO wproces
        FROM DUAL;

      -- Damos de alta el proceso de auditoria
      INSERT INTO auditoriacab
                  (sauditoria, cempres, cusuari, caudit, taudit, faudini, faudfin, nerror)
           VALUES (wproces, pcempres, pcusuari, pcaudit, ptaudit, wfecha, NULL, 0);

      -- Devolvemos el código del proceso
      psauditoria := wproces;
      COMMIT;
      RETURN 0;
   END f_auditoriaini;

   /************************************************************************************
       CREA O MODIFICA UNA LINEA EN LA TABLA DE CONTROL DE AUDITORIAS
       Registra todos los cambios en Tabla AUDITORIALIN
       param in psauditoria: Número de proceso de la auditoria
                par_taudlin: Descripción de la linea de auditoria
                pnaudnum: Numero seguro
                pnaudlin: Numero de linia (Si es NULL o 0, inserta una nova linia)
                pctiplin: Tipo de línea. null y 1.- Error, 2.- Aviso. Valor fijo:713
   ************************************************************************************/
   FUNCTION f_auditorialin(
      psauditoria IN NUMBER,
      par_taudlin IN VARCHAR2,
      pnaudnum IN NUMBER,
      pnaudlin IN OUT NUMBER,
      pctiplin IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_obj          VARCHAR2(100) := 'f_auditorialin';
      v_pas          NUMBER := 100;
      v_par          VARCHAR2(2000)
         := 'p=' || psauditoria || ' t=' || par_taudlin || ' n=' || pnaudnum || ' l='
            || pnaudlin || ' c=' || pctiplin;
      xaudlin        NUMBER;
      v_taudlin      auditorialin.taudlin%TYPE;
      n_error        NUMBER;
      v_usu          usuarios.cusuari%TYPE;
      v_audnum       auditorialin.naudnum%TYPE;
      v_emp          auditoriacab.cempres%TYPE;
      e_error        EXCEPTION;
   BEGIN
      v_pas := 100;
      n_error := 0;
      v_audnum := NVL(pnaudnum, 0);
      v_usu := f_user;
      v_pas := 105;

      IF LENGTH(par_taudlin) > 120 THEN
         p_tab_error(f_sysdate, v_usu, v_obj, v_pas, 'error=9906430', v_par);   --Error al insertar en la tabla AUDITORIALIN
         v_taudlin := SUBSTR(par_taudlin, 1, 120);
      ELSE
         v_taudlin := par_taudlin;
      END IF;

      IF pnaudlin IS NOT NULL
         AND pnaudlin > 0 THEN
         BEGIN
            v_pas := 110;

            UPDATE auditorialin
               SET taudlin = v_taudlin,
                   naudnum = v_audnum,
                   faudlin = f_sysdate,
                   ctiplin = DECODE(pctiplin, NULL, 1, pctiplin)
             WHERE sauditoria = psauditoria
               AND naudlin = pnaudlin;

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               n_error := 9906431;   -- ERROR AL MODIFICAR LA TAULA AUDITORIALIN
               RAISE e_error;
         END;

         n_error := 0;
      ELSE   -- pnaudlin = NULL O IGUAL A 0
         BEGIN
            v_pas := 120;

            SELECT NVL(MAX(naudlin), 0)
              INTO xaudlin
              FROM auditorialin
             WHERE sauditoria = psauditoria;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               n_error := 9906432;   -- PROCÉS NO TROBAT A AUDITORIALIN
               RAISE e_error;
            WHEN OTHERS THEN
               n_error := 9906433;   -- ERROR AL LLEGIR DE AUDITORIALIN
               RAISE e_error;
         END;

         BEGIN
            v_pas := 130;

            INSERT INTO auditorialin
                        (sauditoria, naudlin, naudnum, taudlin, faudlin, cestado,
                         ctiplin)
                 VALUES (psauditoria, xaudlin + 1, v_audnum, v_taudlin, f_sysdate, 0,
                         DECODE(pctiplin, NULL, 1, pctiplin));

            COMMIT;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               n_error := 9906434;   -- LÍNIA DE PROCÉS REPETIDA A AUDITORIALIN
               RAISE e_error;
            WHEN OTHERS THEN
               n_error := 9906430;   -- ERROR A L' INSERIR A AUDITORIALIN
               RAISE e_error;
         END;

         n_error := 0;
      END IF;

      v_pas := 140;
      RETURN n_error;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, v_usu, v_obj, v_pas, 'error=' || n_error,
                     v_par || ' err=' || SQLCODE || ' ' || SQLERRM);
         RETURN n_error;
   END f_auditorialin;

   /************************************************************************************
       Finaliza una auditoria.
       param in psauditoria: nº de proceso de auditoria a finalizar
                pnerror : nº de errores en el proceso
   ************************************************************************************/
   FUNCTION f_auditoriafin(psauditoria IN NUMBER, pnerror IN NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      wfecha         DATE;
      wproces        NUMBER;
   BEGIN
      -- Recuperamos la fecha
      wfecha := f_sysdate;

      -- Validamos la existencia del proceso de auditoria
      BEGIN
         SELECT sauditoria
           INTO wproces
           FROM auditoriacab
          WHERE sauditoria = psauditoria;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 1;
         WHEN TOO_MANY_ROWS THEN
            RETURN 2;
      END;

      -- Actualizamos la información del proceso de auditoria
      UPDATE auditoriacab
         SET faudfin = wfecha,
             nerror = pnerror
       WHERE sauditoria = psauditoria;

      COMMIT;
      RETURN 0;
   END f_auditoriafin;
END pac_auditoria;

/

  GRANT EXECUTE ON "AXIS"."PAC_AUDITORIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AUDITORIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AUDITORIA" TO "PROGRAMADORESCSI";
