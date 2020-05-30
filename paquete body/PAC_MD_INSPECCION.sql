--------------------------------------------------------
--  DDL for Package Body PAC_MD_INSPECCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_INSPECCION" AS
/******************************************************************************
 NOMBRE: pac_md_INSPECCION
   PROPÓSITO:  Funciones para la inspeccion

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/04/2013   XPL              1. Creación del package.
   2.0        05/06/2013   JDS              2. 0025221: LCOL_T031-LCOL - Fase 3 - Desarrollo Inspección de Riesgo
   3.0        27/06/2013   JDS              3. 0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A
   4.0        04/07/2013   JDS              4. 0025221: LCOL_T031-LCOL - Fase 3 - Desarrollo Inspección de Riesgo
   5.0        11/07/2013   JDS              5. 0025221: LCOL_T031-LCOL - Fase 3 - Desarrollo Inspección de Riesgo
   6.0        25/07/2013   JDS              6. 0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_set_documentacion_inspeccion(
      pcempres IN NUMBER,
      ptfichero IN VARCHAR2,
      psorden IN NUMBER,
      pidinspeccion IN VARCHAR2,
      pninspeccion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500) := ' --';
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.f_set_documentacion_inspeccion';
      vidgedox       NUMBER;
      vsorden        NUMBER;
      viddoc_out     NUMBER;
   BEGIN
      vnumerr := pac_md_gedox.f_get_idfichero(vidgedox, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_md_gedox.f_set_documinspeccion(0,
                                                    NVL(pac_md_common.f_get_cxtusuario, f_user),
                                                    ptfichero, vidgedox, 'Inspección', 8, NULL,
                                                    mensajes, NULL, viddoc_out);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_md_inspeccion.f_set_inspeccion_doc(pcempres, psorden, pninspeccion, 305,
                                                        0, 0, 1, NVL(vidgedox, viddoc_out),
                                                        mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_set_documentacion_inspeccion;

   FUNCTION f_crear_orden_insp(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psorden OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := ' ptablas :' || ptablas || ',pcempres:' || pac_md_common.f_get_cxtempresa
            || ',psseguro:' || psseguro || ',pnmovimi:' || pnmovimi || ',pnriesgo:'
            || pnriesgo;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.F_CREAR_ORDEN_INSP';
      vsproduc       NUMBER;
      pnordenext     VARCHAR2(100);
      vsinterf       NUMBER;
      vcmotmov       NUMBER;
      vcont          NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF NVL(pac_mdpar_productos.f_get_parproducto('GESTION_IR', vsproduc), 0) = 1 THEN
         vnumerr := pac_inspeccion.f_insert_orden_insp(ptablas,
                                                       pac_md_common.f_get_cxtempresa,
                                                       psseguro, pnmovimi, pnriesgo, psorden);

         IF vnumerr > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         IF vnumerr = 0 THEN   --ya existe inspección vigente o solicitada para este vehiculo no volvemos a solicitar inspeccion
            IF ptablas = 'POL' THEN
               BEGIN
                           /*

                  Pasar motivo de inspeccion
                  Motivos de inspección
                  Código   Valor
                  -1  Póliza Nueva
                  2  Renovación
                  3  Rechazo inspección anterior
                  -4  Modificación póliza
                  -5  Inclusión de accesorios
                  -6  Cambio de vehículo
                  */
                  FOR i IN (SELECT DISTINCT cmotmov
                                       FROM detmovseguro
                                      WHERE sseguro = psseguro
                                        AND nmovimi = pnmovimi
                                        AND nriesgo = 1) LOOP
                     IF i.cmotmov = 100 THEN
                        vcmotmov := 1;
                     ELSIF i.cmotmov = 420 THEN
                        vcmotmov := 6;
                     ELSIF i.cmotmov = 422 THEN
                        vcmotmov := 4;
                     ELSIF i.cmotmov = 424 THEN
                        vcmotmov := 5;
                     ELSIF i.cmotmov = 404 THEN
                        vcmotmov := 2;
                     END IF;
                  END LOOP;

                  IF vcmotmov IS NULL THEN
                     vcmotmov := 1;

                     IF pnmovimi IS NOT NULL
                        AND pnmovimi > 1 THEN
                        SELECT COUNT(1)
                          INTO vcont
                          FROM riesgos_ir
                         WHERE sseguro = psseguro
                           AND nmovimi = pnmovimi - 1   --movimiento anterior.
                           AND cresultr = 2;

                        IF vcont > 0 THEN
                           vcmotmov := 3;   --tiene una inspección rechazada
                        END IF;
                     END IF;
                  END IF;
               /*      SELECT DECODE(cmotmov, 100, 1, 420, 6, 422, 4, 424, 5, 404, 2, 6)
                       INTO vcmotmov
                       FROM detmovseguro
                      WHERE sseguro = psseguro
                        AND nmovimi = pnmovimi
                        AND nriesgo = 1
                        AND ROWNUM = 1;*/
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vcmotmov := 1;

                     IF pnmovimi IS NOT NULL
                        AND pnmovimi > 1 THEN
                        SELECT COUNT(1)
                          INTO vcont
                          FROM riesgos_ir
                         WHERE sseguro = psseguro
                           AND nmovimi = pnmovimi - 1   --movimiento anterior
                           AND cresultr = 2;

                        IF vcont > 0 THEN
                           vcmotmov := 3;   --tiene una inspección rechazada
                        END IF;
                     END IF;
               END;
            ELSE
               BEGIN
                           /*

                  Pasar motivo de inspeccion
                  Motivos de inspección
                  Código   Valor
                  -1  Póliza Nueva
                  2  Renovación
                  3  Rechazo inspección anterior
                  -4  Modificación póliza
                  -5  Inclusión de accesorios
                  -6  Cambio de vehículo
                  */
                  FOR i IN (SELECT DISTINCT cmotmov
                                       FROM estdetmovseguro
                                      WHERE sseguro = psseguro
                                        AND nmovimi = pnmovimi
                                        AND nriesgo = 1) LOOP
                     IF i.cmotmov = 100 THEN
                        vcmotmov := 1;
                     ELSIF i.cmotmov = 420 THEN
                        vcmotmov := 6;
                     ELSIF i.cmotmov = 422 THEN
                        vcmotmov := 4;
                     ELSIF i.cmotmov = 424 THEN
                        vcmotmov := 5;
                     ELSIF i.cmotmov = 404 THEN
                        vcmotmov := 2;
                     END IF;
                  END LOOP;

                  /* SELECT DECODE(cmotmov, 100, 1, 420, 6, 422, 4, 424, 5, 404, 2, 6)
                     INTO vcmotmov
                     FROM estdetmovseguro
                    WHERE sseguro = psseguro
                      AND nmovimi = pnmovimi
                      AND nriesgo = 1
                      AND ROWNUM = 1;*/
                  IF vcmotmov IS NULL THEN
                     vcmotmov := 1;

                     IF pnmovimi IS NOT NULL
                        AND pnmovimi > 1 THEN
                        SELECT COUNT(1)
                          INTO vcont
                          FROM estriesgos_ir
                         WHERE sseguro = psseguro
                           AND nmovimi = pnmovimi - 1   --movimiento anterior
                           AND cresultr = 2;

                        IF vcont > 0 THEN
                           vcmotmov := 3;   --tiene una inspección rechazada
                        END IF;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vcmotmov := 1;

                     IF pnmovimi IS NOT NULL
                        AND pnmovimi > 1 THEN
                        SELECT COUNT(1)
                          INTO vcont
                          FROM estriesgos_ir
                         WHERE sseguro = psseguro
                           AND nmovimi = pnmovimi - 1   --movimiento anterior
                           AND cresultr = 2;

                        IF vcont > 0 THEN
                           vcmotmov := 3;   --tiene una inspección rechazada
                        END IF;
                     END IF;
               END;
            END IF;

            IF vnumerr <= 0 THEN   --ya existe inspección vigente o solicitada para este vehiculo no volvemos a solicitar inspeccion
               vnumerr := pac_md_con.f_solicitar_inspeccion(psseguro, NVL(pnriesgo, 1),
                                                            NVL(pnmovimi, 1), vcmotmov,
                                                            ptablas, pnordenext, vsinterf,
                                                            mensajes);
               vnumerr := 0;

               /* SELECT sperson.NEXTVAL -----> para probar en local descomentar este trozo y comentar pac_md_con.f_solicitar_inspeccion(arriba), y parametro GESTION_IR debe ser 1 para el producto
                   INTO pnordenext
                   FROM DUAL;*/
               IF vnumerr = 0 THEN
                  vnumerr := pac_inspeccion.f_set_nordenext(ptablas,
                                                            pac_md_common.f_get_cxtempresa,
                                                            psorden, pnordenext);

                  IF vnumerr <> 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                     RAISE e_object_error;
                  END IF;
               ELSE
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_crear_orden_insp;

   FUNCTION f_act_orden_ext(
      pcempres IN NUMBER,
      psorden IN OUT NUMBER,
      pnordenext IN VARCHAR2,
      pcestado IN NUMBER,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      pcmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := ' psorden :' || psorden || ',pcempres:' || pac_md_common.f_get_cxtempresa
            || ',cestado:' || pcestado || ',cestado:' || pcestado || ',ctipmat:' || pctipmat
            || ',cmatric:' || pcmatric || ',cmotor:' || pcmotor || ',cchasis:' || pcchasis
            || ',nbastid:' || pnbastid;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.f_act_orden_ext';
      vsproduc       NUMBER;
   BEGIN
      vnumerr := pac_inspeccion.f_act_orden(NULL,
                                            NVL(pcempres, pac_md_common.f_get_cxtempresa),
                                            psorden, pnordenext, pcestado, pctipmat, pcmatric,
                                            pcmotor, pcchasis, pnbastid);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_act_orden_ext;

   FUNCTION f_buscar_inspeccion(
      pcempres IN NUMBER,
      psorden_in IN NUMBER,
      psordenext_in IN NUMBER,
      psorden_out OUT NUMBER,
      psordenext_out OUT NUMBER,
      pninspeccion_out OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                       := ' psorden_in :' || psorden_in || ', psordenext_in:' || psordenext_in;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.f_buscar_inspeccion';
      v_cestado      NUMBER;
      v_sorden       NUMBER;
      v_sordenext    VARCHAR2(100);
   BEGIN
      BEGIN
         IF psordenext_in IS NOT NULL THEN
            SELECT sorden, cestado
              INTO v_sorden, v_cestado
              FROM ir_ordenes
             WHERE cempres = NVL(pcempres, pac_md_common.f_get_cxtempresa)
               AND nordenext = psordenext_in;

            v_sordenext := psordenext_in;
         ELSE
            SELECT nordenext, cestado
              INTO v_sordenext, v_cestado
              FROM ir_ordenes
             WHERE cempres = NVL(pcempres, pac_md_common.f_get_cxtempresa)
               AND sorden = psorden_in;

            v_sorden := psorden_in;
         END IF;

         IF v_cestado IS NOT NULL
            AND v_cestado IN(5, 6) THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905269);   --La orden de inspección no está activa'.
            RAISE e_object_error;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            psorden_out := NULL;
            psordenext_out := NULL;
      END;

      BEGIN
         SELECT MAX(ninspeccion)
           INTO pninspeccion_out
           FROM ir_inspecciones
          WHERE cempres = NVL(pcempres, pac_md_common.f_get_cxtempresa)
            AND sorden = v_sorden;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pninspeccion_out := NULL;
      END;

      psorden_out := v_sorden;
      psordenext_out := v_sordenext;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_buscar_inspeccion;

   FUNCTION f_set_inspeccion_acc(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcaccesorio IN NUMBER,
      pctipacc IN NUMBER,
      ptdesacc IN VARCHAR2,
      pivalacc IN NUMBER,
      pcasegurable IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ',psorden:' || psorden || ',pninspeccion:' || pninspeccion || ',pcaccesorio:'
            || pcaccesorio || ',pctipacc:' || pctipacc || ',ptdesacc:' || ptdesacc
            || ',pivalacc:' || pivalacc || ',pcasegurable:' || pcasegurable;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.f_set_inspeccion_acc';
      vsproduc       NUMBER;
   BEGIN
      vnumerr := pac_inspeccion.f_set_inspeccion_acc(NULL,
                                                     NVL(pcempres,
                                                         pac_md_common.f_get_cxtempresa),
                                                     psorden, pninspeccion, pcaccesorio,
                                                     pctipacc, ptdesacc, pivalacc,
                                                     pcasegurable);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_inspeccion_acc;

   FUNCTION f_set_inspeccion_doc(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcdocume IN NUMBER,
      pcgenerado IN NUMBER,
      pcobliga IN NUMBER,
      pcadjuntado IN NUMBER,
      piddocgedox IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ',psorden:' || psorden || ',pninspeccion:' || pninspeccion || ',PCDOCUME:'
            || pcdocume || ',PCGENERADO:' || pcgenerado || ',PCOBLIGA:' || pcobliga
            || ',PCADJUNTADO:' || pcadjuntado || ',PIDDOCGEDOX:' || piddocgedox;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.f_set_inspeccion_doc';
      vsproduc       NUMBER;
   BEGIN
      vnumerr := pac_inspeccion.f_set_inspeccion_doc(NVL(pcempres,
                                                         pac_md_common.f_get_cxtempresa),
                                                     psorden, pninspeccion, pcdocume,
                                                     pcgenerado, pcobliga, pcadjuntado,
                                                     piddocgedox);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_inspeccion_doc;

   FUNCTION f_act_accesorios(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
                                 := ',psorden:' || psorden || ',pninspeccion:' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.f_act_accesorios';
      vcestado       NUMBER;
      vcont          NUMBER := 0;
      vsorden        NUMBER;
      vcreteni       NUMBER;
   BEGIN
      vpasexec := 2;
      vpasexec := 4;

      FOR i IN (SELECT seg.ROWID, seg.sseguro, seg.csituac, seg.creteni, b.nriesgo, b.nmovimi
                  FROM seguros seg, riesgos_ir ri, riesgos_ir_ordenes b
                 WHERE b.cempres = NVL(pcempres, pac_md_common.f_get_cxtempresa)
                   AND b.sorden = psorden
                   AND b.nmovimi = ri.nmovimi
                   AND seg.sseguro = ri.sseguro
                   AND ri.sseguro = b.sseguro
                   AND ri.nriesgo = b.nriesgo
                   AND b.nmovimi = (SELECT MAX(nmovimi)
                                      FROM riesgos_ir_ordenes rio
                                     WHERE rio.sseguro = b.sseguro
                                       AND rio.nriesgo = b.nriesgo
                                       AND rio.cempres = b.cempres
                                       AND rio.sorden = b.sorden)
                   AND seg.sseguro = b.sseguro) LOOP
         vpasexec := 5;

         IF i.csituac IN(0, 4, 5) THEN
            vnumerr := pac_inspeccion.f_act_accesorios(NULL,
                                                       NVL(pcempres,
                                                           pac_md_common.f_get_cxtempresa),
                                                       psorden, pninspeccion, i.sseguro,
                                                       i.nriesgo, i.nmovimi);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 10;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_act_accesorios;

   FUNCTION f_act_seguros(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
                                 := ',psorden:' || psorden || ',pninspeccion:' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.f_act_seguros';
      vcestado       NUMBER;
      vcont          NUMBER := 0;
      vsorden        NUMBER;
      vcreteni       NUMBER;
   BEGIN
      vpasexec := 2;

      BEGIN
         SELECT cestado
           INTO vcestado
           FROM ir_ordenes
          WHERE cempres = NVL(pcempres, pac_md_common.f_get_cxtempresa)
            AND sorden = psorden;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905268);
            RAISE e_object_error;
      --'Orden de inspección inexistente'.
      END;

      vpasexec := 3;

      IF vcestado IS NOT NULL
         AND vcestado IN(5, 6) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905269);
         RAISE e_object_error;
      --La orden de inspección no está activa'.
      END IF;

      vpasexec := 4;

      FOR i IN (SELECT seg.ROWID, seg.sseguro, seg.csituac, seg.creteni, b.nriesgo, b.nmovimi
                  FROM seguros seg, riesgos_ir ri, riesgos_ir_ordenes b
                 WHERE b.cempres = NVL(pcempres, pac_md_common.f_get_cxtempresa)
                   AND b.sorden = psorden
                   AND b.nmovimi = ri.nmovimi
                   AND seg.sseguro = ri.sseguro
                   AND ri.sseguro = b.sseguro
                   AND ri.nriesgo = b.nriesgo
                   AND seg.creteni NOT IN(3, 4)
                   AND b.nmovimi = (SELECT MAX(nmovimi)
                                      FROM riesgos_ir_ordenes rio
                                     WHERE rio.sseguro = b.sseguro
                                       AND rio.nriesgo = b.nriesgo
                                       AND rio.cempres = b.cempres
                                       AND rio.sorden = b.sorden)
                   AND seg.sseguro = b.sseguro) LOOP
         vpasexec := 5;

         IF i.csituac = 0
            AND i.creteni = 0 THEN
            vpasexec := 7;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905277);
            RAISE e_object_error;
         ELSIF i.csituac IN(4, 5) THEN
            vpasexec := 8;
            vcont := vcont + 1;
            vnumerr := pac_inspeccion.f_act_seguro(NULL,
                                                   NVL(pcempres,
                                                       pac_md_common.f_get_cxtempresa),
                                                   psorden, pninspeccion, i.sseguro,
                                                   i.nriesgo, i.nmovimi);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            vnumerr := pac_md_inspeccion.f_gest_retener_porinspeccion('POL', i.sseguro,
                                                                      i.nmovimi, i.nriesgo,
                                                                      NULL, NULL, vsorden,
                                                                      vcreteni, mensajes, 1);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 9;
      --IF vcont = 0 THEN
        -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905278);
        -- RAISE e_object_error;
      --END IF;
      vpasexec := 10;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_act_seguros;

   FUNCTION f_set_inspeccion_dveh(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcversion IN VARCHAR2,
      pcpaisorigen IN VARCHAR2,
      pnpma IN NUMBER,
      pccilindraje IN VARCHAR2,
      panyo IN NUMBER,
      pnplazas IN NUMBER,
      pcservicio IN NUMBER,
      pcblindado IN NUMBER,
      pccampero IN NUMBER,
      pcgama IN NUMBER,
      pcmatcabina IN VARCHAR2,
      pivehinue IN NUMBER,
      pcuso IN VARCHAR2,
      pccolor IN NUMBER,
      pnkilometraje IN NUMBER,
      pctipmotor IN VARCHAR2,
      pntara IN NUMBER,
      pcpintura IN NUMBER,
      pccaja IN NUMBER,
      pctransporte IN NUMBER,
      pctipcarroceria IN NUMBER,
      pesactualizacion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := 'psorden:' || psorden || ',pninspeccion:' || pninspeccion || ',pcversion:'
            || pcversion || ',pcpaisorigen:' || pcpaisorigen || ',pnpma:' || pnpma
            || ',pccilindraje:' || pccilindraje || ',panyo:' || panyo || ',pnplazas:'
            || pnplazas || ',pcservicio:' || pcservicio || ',pcblindado:' || pcblindado
            || ',pccampero:' || pccampero || ',pcgama:' || pcgama || ',pcmatcabina:'
            || pcmatcabina || ',pivehinue:' || pivehinue || ',pcuso:' || pcuso || ',pccolor:'
            || pccolor || ',pnkilometraje:' || pnkilometraje || ',pctipmotor:' || pctipmotor
            || ',pntara:' || pntara || ',pcpintura:' || pcpintura || ',pctransporte:'
            || pctransporte || ',pctipcarroceria:' || pctipcarroceria || ',pesactualizacion:'
            || pesactualizacion;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.f_set_inspeccion_dveh';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vsseguro       NUMBER;
   BEGIN
      vnumerr := pac_inspeccion.f_set_inspeccion_dveh(NULL,
                                                      NVL(pcempres,
                                                          pac_md_common.f_get_cxtempresa),
                                                      psorden, pninspeccion, pcversion,
                                                      pcpaisorigen, pnpma, pccilindraje,
                                                      panyo, pnplazas, pcservicio, pcblindado,
                                                      pccampero, pcgama, pcmatcabina,
                                                      pivehinue, pcuso, pccolor,
                                                      pnkilometraje, pctipmotor, pntara,
                                                      pcpintura, pccaja, pctransporte,
                                                      pctipcarroceria, pesactualizacion);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_inspeccion_dveh;

   FUNCTION f_set_inspeccion(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion_in IN NUMBER,
      pfinspeccion IN DATE,
      pcestado IN NUMBER,
      pcresultado IN NUMBER,
      pcreinspeccion IN NUMBER,
      phllegada IN VARCHAR2,
      phsalida IN VARCHAR2,
      pccentroinsp IN NUMBER,
      pcinspdomi IN NUMBER,
      pcpista IN NUMBER,
      pninspeccion_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := 'psorden:' || psorden || ',pninspeccion_in:' || pninspeccion_in || ',pcestado:'
            || pcestado || ',pcresultado:' || pcresultado || ',pcreinspeccion:'
            || pcreinspeccion || ',phllegada:' || phllegada || ',phsalida:' || phsalida
            || ',pccentroinsp:' || pccentroinsp || ',pcinspdomi:' || pcinspdomi || ',pcpista:'
            || pcpista;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.F_SET_INSPECCION';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vsseguro       NUMBER;
      vninspeccion   NUMBER := pninspeccion_in;
   BEGIN
      vnumerr := pac_inspeccion.f_set_inspeccion(NULL,
                                                 NVL(pcempres, pac_md_common.f_get_cxtempresa),
                                                 psorden, vninspeccion, pfinspeccion,
                                                 pcestado, pcresultado, pcreinspeccion,
                                                 phllegada, phsalida, pccentroinsp,
                                                 pcinspdomi, pcpista);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pninspeccion_out := vninspeccion;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_inspeccion;

   FUNCTION f_necesita_inspeccion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(5000) := 'PAC_MD_INSPECCION.f_necesita_inspeccion';
      vparam         VARCHAR2(5000)
         := 'parámetros - pparams : psseguro: ' || psseguro || ' pnmovimi: ' || pnmovimi
            || ' ptablas: ' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsproduc       NUMBER;
      vcversion      VARCHAR2(15);
      vanyo          NUMBER;
      vvalmotivos    NUMBER;
      vvalanyo       NUMBER;
      ppermiteinspec NUMBER;
      vcrespues      NUMBER;
   BEGIN
      --  vpasexec :=psseguro;
      vpasexec := 20;

      IF ptablas = 'POL' THEN
         SELECT COUNT(*)
           INTO ppermiteinspec
           FROM cnvpolizas
          WHERE sseguro = psseguro;

         IF ppermiteinspec > 0 THEN
            --Si tenim registres a CNVPOLIZAS per la polissa que estem contractant no passarem inspecció de risc.
            RETURN 0;
         END IF;

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT COUNT(*)
           INTO ppermiteinspec
           FROM estseguros
          WHERE polissa_ini IS NOT NULL
            AND sseguro = psseguro;

         IF ppermiteinspec > 0 THEN
            --Si tenim registres a estseguros per la polissa que estem contractant no passarem inspecció de risc.
            RETURN 0;
         END IF;

         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      END IF;

      vpasexec := 22;

      IF NVL(pac_mdpar_productos.f_get_parproducto('GESTION_IR', vsproduc), 0) = 1 THEN
         vpasexec := 23;
         --     cempres,cramo,sproduc,cagente,ctipdoc,nnumide,
         vnumerr := pac_inspeccion.f_permiteinspeccion(pac_md_common.f_get_cxtempresa,
                                                       pac_md_common.f_get_cxtagente,
                                                       psseguro, ptablas, ppermiteinspec);
         vpasexec := 24;

         IF ppermiteinspec = 0 THEN
            RETURN ppermiteinspec;
         END IF;

         vpasexec := 25;

         IF ptablas = 'POL' THEN
            SELECT cversion, anyo
              INTO vcversion, vanyo
              FROM autriesgos
             WHERE sseguro = psseguro
               AND((pnmovimi IS NOT NULL
                    AND nmovimi = pnmovimi)
                   OR(pnmovimi IS NULL
                      AND nmovimi = (SELECT MAX(nmovimi)
                                       FROM movseguro
                                      WHERE sseguro = psseguro)));

            IF vanyo >= TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) THEN
               RETURN 0;
            END IF;

            SELECT COUNT(1)
              INTO vvalmotivos
              FROM detmovseguro
             WHERE sseguro = psseguro
               AND((pnmovimi IS NOT NULL
                    AND nmovimi = pnmovimi)
                   OR(pnmovimi IS NULL
                      AND nmovimi = (SELECT MAX(nmovimi)
                                       FROM movseguro
                                      WHERE sseguro = psseguro)))
               AND cmotmov IN(100, 420, 422, 424);

            vpasexec := 27;

            IF vvalmotivos = 0 THEN
               RETURN 0;
            END IF;

            BEGIN
               SELECT crespue
                 INTO vcrespues
                 FROM pregunseg
                WHERE sseguro = psseguro
                  AND cpregun = 4010   --continuidad
                  AND((pnmovimi IS NOT NULL
                       AND nmovimi = pnmovimi)
                      OR(pnmovimi IS NULL
                         AND nmovimi = (SELECT MAX(movseguro.nmovimi)
                                          FROM movseguro
                                         WHERE movseguro.sseguro = psseguro)));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcrespues := 0;
            END;

            vpasexec := 28;

            IF vcrespues = 1 THEN
               RETURN 0;
            END IF;
         ELSE
            vpasexec := 2;

            SELECT cversion, anyo
              INTO vcversion, vanyo
              FROM estautriesgos ea, estseguros es
             WHERE ea.sseguro = psseguro
               AND ea.sseguro = es.sseguro
               AND((pnmovimi IS NOT NULL
                    AND nmovimi = pnmovimi)
                   OR(pnmovimi IS NULL
                      AND nmovimi = (SELECT MAX(estautriesgos.nmovimi)
                                       FROM estautriesgos
                                      WHERE estautriesgos.sseguro = psseguro)));

            vpasexec := 3;

            IF vanyo >= TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) THEN
               RETURN 0;
            END IF;

            SELECT COUNT(1)
              INTO vvalmotivos
              FROM estdetmovseguro ea, estseguros es
             WHERE ea.sseguro = psseguro
               AND ea.sseguro = es.sseguro
               AND((pnmovimi IS NOT NULL
                    AND nmovimi = pnmovimi)
                   OR(pnmovimi IS NULL
                      AND nmovimi = (SELECT MAX(estautriesgos.nmovimi)
                                       FROM estautriesgos
                                      WHERE estautriesgos.sseguro = psseguro)))
               AND cmotmov IN(100, 420, 422, 424);

            vpasexec := 4;

            IF vvalmotivos = 0 THEN
               BEGIN
                  SELECT cmotmov
                    INTO vvalmotivos
                    FROM estdetmovseguro ea, estseguros es
                   WHERE ea.sseguro = psseguro
                     AND ea.sseguro = es.sseguro
                     AND((pnmovimi IS NOT NULL
                          AND nmovimi = pnmovimi)
                         OR(pnmovimi IS NULL
                            AND nmovimi = (SELECT MAX(estautriesgos.nmovimi)
                                             FROM estautriesgos
                                            WHERE estautriesgos.sseguro = psseguro)));

                  RETURN 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;   --si no hay registros estamos en una modificacion
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            SELECT crespue
              INTO vcrespues
              FROM estpregunseg ep, estseguros es
             WHERE ep.sseguro = psseguro
               AND ep.sseguro = es.sseguro
               AND ep.cpregun = 4010   --continuidad
               AND((pnmovimi IS NOT NULL
                    AND ep.nmovimi = pnmovimi)
                   OR(pnmovimi IS NULL
                      AND ep.nmovimi = (SELECT MAX(estautriesgos.nmovimi)
                                          FROM estautriesgos
                                         WHERE estautriesgos.sseguro = psseguro)));

            vpasexec := 5;

            IF vcrespues = 1 THEN
               RETURN 0;
            END IF;
         END IF;

         RETURN 1;
      ELSE
         RETURN 0;
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 0;
   END f_necesita_inspeccion;

   FUNCTION f_get_ord_inspec_mod_consulta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pnecesitainspeccion OUT NUMBER,
      presultadoinspeccion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCION.f_get_ord_inspec_mod_consulta';
      vcmatric       NUMBER;
      vctipmat       NUMBER;
      vcont          NUMBER;
      vquery         VARCHAR2(2000);
      w_nmovimi      NUMBER;
   BEGIN
      w_nmovimi := pnmovimi;

      IF pnmovimi IS NULL THEN
         SELECT MAX(nmovimi)
           INTO w_nmovimi
           FROM movseguro
          WHERE sseguro = psseguro;
      END IF;

      SELECT cinspreq, cresultr
        INTO pnecesitainspeccion, presultadoinspeccion
        FROM riesgos_ir
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      vquery :=
         ' SELECT FSOLICITUD + nvl(pac_mdpar_productos.f_get_parproducto(''VIGENCIA_ORDENINSP'', s.sproduc),35) FVTORDEN,  io.sorden, ii.ninspeccion, io.cmatric, io.ctipmat, io.fsolicitud, io.cestado cestadoorden, ff_desvalorfijo (750, PAC_MD_COMMON.F_Get_CXTIDIOMA(), io.cestado)  testadoorden, io.cclase, ff_desvalorfijo (751, PAC_MD_COMMON.F_Get_CXTIDIOMA(), io.cclase)  tclase,
       ii.finspeccion, ii.cestado cestadoinspeccion, ff_desvalorfijo (752, PAC_MD_COMMON.F_Get_CXTIDIOMA(), ii.cestado) testadoinspeccion, rir.cinspreq, rir.cresultr '
         || '  FROM riesgos_ir_ordenes rio, ir_ordenes io, ir_inspecciones ii, riesgos_ir rir, seguros s'
         || ' WHERE s.sseguro = rio.sseguro and rio.sseguro = ' || psseguro
         || ' AND rio.cempres = ' || pac_md_common.f_get_cxtempresa
         || ' AND rio.nmovimi = NVL(''' || w_nmovimi
         || ''', (SELECT MAX(nmovimi)
                                       FROM movseguro ms
                                      WHERE sseguro = '
         || psseguro || '))
   AND rio.nriesgo = nvl(''' || pnriesgo
         || ''',rio.nriesgo)
   AND rio.sorden = io.sorden
   AND rio.sorden = ii.sorden(+)
   AND rio.cempres = ii.cempres (+)
   and rir.SSEGURO = rio.SSEGURO
   and rir.NRIESGO = rio.NRIESGO
   and rir.NMOVIMI = rio.nmovimi ';
      vnumerr := pac_md_log.f_log_consultas(vquery, vobjectname, 1, 1, mensajes);
      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN NO_DATA_FOUND THEN
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_ord_inspec_mod_consulta;

   FUNCTION f_get_ordenes_inspeccion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2,
      pnecesitainspeccion OUT NUMBER,
      presultadoinspeccion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_get_ordenes_inspeccion';
      vcmatric       NUMBER;
      vctipmat       NUMBER;
      vcont          NUMBER;
      vquery         VARCHAR2(2000);
      w_nmovimi      NUMBER;
   BEGIN
      w_nmovimi := pnmovimi;

      IF pnmovimi IS NULL THEN
         IF ptablas = 'POL' THEN
            SELECT MAX(nmovimi)
              INTO w_nmovimi
              FROM movseguro
             WHERE sseguro = psseguro;
         ELSE
            --SELECT MAX(nmovimi)
              --INTO w_nmovimi
              --FROM movseguro mv, estseguros s
             --WHERE s.sseguro = psseguro
               --AND mv.sseguro = s.ssegpol;
            SELECT MAX(estautriesgos.nmovimi)
              INTO w_nmovimi
              FROM estautriesgos
             WHERE estautriesgos.sseguro = psseguro;
         END IF;
      END IF;

      /*  vnumerr := pac_md_inspeccion.f_resultado_inspeccion(ptablas, psseguro, w_nmovimi,
                                                              pnriesgo, presultadoinspeccion,
                                                              pnecesitainspeccion, mensajes);*/
      vquery :=
         ' SELECT FSOLICITUD + nvl(pac_mdpar_productos.f_get_parproducto(''VIGENCIA_ORDENINSP'', s.sproduc),35) FVTORDEN,  io.sorden, ii.ninspeccion, io.cmatric, io.ctipmat, io.fsolicitud, io.cestado cestadoorden, ff_desvalorfijo (750, PAC_MD_COMMON.F_Get_CXTIDIOMA(), io.cestado)  testadoorden, io.cclase, ff_desvalorfijo (751, PAC_MD_COMMON.F_Get_CXTIDIOMA(), io.cclase)  tclase,
       ii.finspeccion, ii.cestado cestadoinspeccion, ff_desvalorfijo (752, PAC_MD_COMMON.F_Get_CXTIDIOMA(), ii.cestado) testadoinspeccion, rir.cinspreq, rir.cresultr ';

      IF ptablas = 'EST' THEN
         vquery :=
            vquery
            || '  FROM estriesgos_ir_ordenes rio, ir_ordenes io, ir_inspecciones ii, estriesgos_ir rir, estseguros s';
      ELSE
         vquery :=
            vquery
            || '  FROM riesgos_ir_ordenes rio, ir_ordenes io, ir_inspecciones ii, riesgos_ir rir, seguros s';
      END IF;

      vquery :=
         vquery || ' WHERE s.sseguro = rio.sseguro and rio.sseguro = ' || psseguro
         || ' AND rio.cempres = ' || pac_md_common.f_get_cxtempresa
         || ' AND rio.nmovimi = NVL(''' || w_nmovimi
         || ''', (SELECT MAX(nmovimi)
                                       FROM movseguro ms
                                      WHERE sseguro = '
         || psseguro || '))
   AND rio.nriesgo = nvl(''' || pnriesgo
         || ''',rio.nriesgo)
   AND rio.sorden = io.sorden
   AND rio.sorden = ii.sorden(+)
   AND rio.cempres = ii.cempres (+)
   and rir.SSEGURO = rio.SSEGURO
   and rir.NRIESGO = rio.NRIESGO
   and rir.NMOVIMI = rio.nmovimi ';
      vnumerr := pac_md_log.f_log_consultas(vquery,
                                            'PAC_MD_INSPECCION.f_get_ordenes_inspeccion', 1, 1,
                                            mensajes);
      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_ordenes_inspeccion;

   FUNCTION f_gestion_inspeccion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2,
      pnecesitainspeccion OUT NUMBER,
      presultadoinspeccion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_gestion_inspeccion';
      vctipmat       NUMBER;
      vcont          NUMBER;
      vquery         VARCHAR2(2000);
      w_nmovimi      NUMBER := pnmovimi;
      vcmatric       VARCHAR2(100);
      vviginspdias   NUMBER;
      vsproduc       NUMBER;
      vsorden        NUMBER;
      vvalmotivos    NUMBER;
      vvigorden      NUMBER;
   BEGIN
      w_nmovimi := pnmovimi;

      IF pnmovimi IS NULL THEN
         IF ptablas = 'POL' THEN
            SELECT MAX(nmovimi)
              INTO w_nmovimi
              FROM movseguro
             WHERE sseguro = psseguro;
         ELSE
            SELECT MAX(ea.nmovimi)
              INTO w_nmovimi
              FROM autriesgos ea
             WHERE ea.sseguro = psseguro;
         END IF;
      END IF;

      IF ptablas = 'EST' THEN
         SELECT estautriesgos.cmatric, ee.sproduc
           INTO vcmatric, vsproduc
           FROM estautriesgos, estseguros ee
          WHERE estautriesgos.sseguro = psseguro
            AND ee.sseguro = estautriesgos.sseguro
            AND nriesgo = NVL(pnriesgo, nriesgo)
            AND nmovimi = w_nmovimi;

         SELECT COUNT(1)
           INTO vvalmotivos
           FROM estdetmovseguro
          WHERE sseguro = psseguro
            AND((pnmovimi IS NOT NULL
                 AND nmovimi = pnmovimi)
                OR(pnmovimi IS NULL
                   AND nmovimi = (SELECT MAX(nmovimi)
                                    FROM movseguro
                                   WHERE sseguro = psseguro)))
            AND cmotmov IN(420, 422, 424);   --miramos si es un suplemento
      ELSE
         SELECT autriesgos.cmatric, ee.sproduc
           INTO vcmatric, vsproduc
           FROM autriesgos, seguros ee
          WHERE autriesgos.sseguro = psseguro
            AND ee.sseguro = autriesgos.sseguro
            AND nriesgo = NVL(pnriesgo, nriesgo)
            AND nmovimi = w_nmovimi;

         SELECT COUNT(1)
           INTO vvalmotivos
           FROM detmovseguro
          WHERE sseguro = psseguro
            AND((pnmovimi IS NOT NULL
                 AND nmovimi = pnmovimi)
                OR(pnmovimi IS NULL
                   AND nmovimi = (SELECT MAX(nmovimi)
                                    FROM movseguro
                                   WHERE sseguro = psseguro)))
            AND cmotmov IN(420, 422, 424);
      END IF;

      vpasexec := 27;
--comprobamos si hay alguna inspeccion vigente
      vnumerr := pac_cfg.f_get_user_accion_permitida(pac_md_common.f_get_cxtusuario,
                                                     'VIGENCIA_INSPECCION', vsproduc,
                                                     pac_md_common.f_get_cxtempresa(),
                                                     vviginspdias);

      IF vviginspdias IS NULL THEN
         vviginspdias := pac_mdpar_productos.f_get_parproducto('VIGENCIA_ORDENINSP', vsproduc);
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM ir_inspecciones ii, ir_ordenes io
       WHERE ii.sorden = io.sorden
         AND ii.cempres = io.cempres
         AND ii.cestado != 4
         AND io.cmatric LIKE vcmatric
         AND ii.cempres = pac_md_common.f_get_cxtempresa
         AND f_sysdate - ii.finspeccion < vviginspdias;

      vvigorden := pac_mdpar_productos.f_get_parproducto('VIGENCIA_ORDENINSP', vsproduc);   -- orden --35 dias
      vnumerr := pac_md_inspeccion.f_resultado_inspeccion(ptablas, psseguro, w_nmovimi,
                                                          pnriesgo, presultadoinspeccion,
                                                          pnecesitainspeccion, mensajes);

      IF presultadoinspeccion != 0
         AND pnecesitainspeccion = 1 THEN
         IF vcont = 0 THEN
            --comprobamos si hay alguna orden vigente

            --hay orden pero no inspeccion
            IF ptablas = 'EST' THEN
               BEGIN
                  SELECT COUNT(1)
                    INTO vcont
                    FROM ir_ordenes io
                   WHERE io.cempres = pac_md_common.f_get_cxtempresa
                     AND f_sysdate - io.fsolicitud < vvigorden
                     AND io.cmatric LIKE vcmatric
                     AND cestado NOT IN(5, 6)
                     AND io.sorden NOT IN(SELECT sorden
                                            FROM ir_inspecciones ii
                                           WHERE ii.cempres = pac_md_common.f_get_cxtempresa);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vcont := 0;
               END;
            END IF;
         END IF;
      END IF;

      IF vcont > 0
         AND vvalmotivos = 0 THEN
         IF (ptablas = 'EST') THEN
            BEGIN
               SELECT io.sorden, cinspreq, cresultr
                 INTO vsorden, pnecesitainspeccion, presultadoinspeccion
                 FROM ir_ordenes io, estriesgos_ir ir,
                      estriesgos_ir_ordenes rio   -- ir_inspecciones ii,
                WHERE rio.cempres = io.cempres
                  AND rio.sorden = io.sorden
                  AND ir.sseguro = rio.sseguro
                  AND ir.nriesgo = rio.nriesgo
                  AND ir.nmovimi = rio.nmovimi
                  AND io.cmatric LIKE vcmatric
                  AND io.cempres = pac_md_common.f_get_cxtempresa
                  AND f_sysdate - io.fsolicitud < vvigorden
                  AND cestado NOT IN(5, 6)
                  AND rio.sseguro = psseguro
                  AND rio.nmovimi = pnmovimi
                  -- AND f_situacion_poliza(s.sseguro) <> 2
                  AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT io.sorden, cinspreq, cresultr
                    INTO vsorden, pnecesitainspeccion, presultadoinspeccion
                    FROM ir_ordenes io, riesgos_ir ir,
                         riesgos_ir_ordenes rio   -- ir_inspecciones ii,
                   WHERE rio.cempres = io.cempres
                     AND rio.sorden = io.sorden
                     AND ir.sseguro = rio.sseguro
                     AND ir.nriesgo = rio.nriesgo
                     AND ir.nmovimi = rio.nmovimi
                     AND io.cmatric LIKE vcmatric
                     AND io.cempres = pac_md_common.f_get_cxtempresa
                     AND f_sysdate - io.fsolicitud < vvigorden
                     AND cestado NOT IN(5, 6)
                     -- AND s.sseguro = rio.sseguro
                      -- AND f_situacion_poliza(s.sseguro) <> 2
                     AND ROWNUM = 1;
            END;

            BEGIN
               INSERT INTO estriesgos_ir
                           (sseguro, nriesgo, nmovimi, cinspreq,
                            cresultr, tperscontacto, ttelcontacto, tmailcontacto, crolcontacto)
                    VALUES (psseguro, pnriesgo, w_nmovimi, pnecesitainspeccion,
                            presultadoinspeccion, NULL, NULL, NULL, NULL);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE estriesgos_ir
                     SET cinspreq = pnecesitainspeccion,
                         cresultr = presultadoinspeccion
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = w_nmovimi;
            END;

            BEGIN
               INSERT INTO estriesgos_ir_ordenes
                           (sseguro, nriesgo, nmovimi, cempres,
                            sorden, cnueva)
                    VALUES (psseguro, pnriesgo, w_nmovimi, pac_md_common.f_get_cxtempresa,
                            vsorden, 0);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         /* EXCEPTION
             WHEN NO_DATA_FOUND THEN

                vnumerr := pac_md_inspeccion.f_resultado_inspeccion(ptablas, psseguro,
                                                                    w_nmovimi, pnriesgo,
                                                                    presultadoinspeccion,
                                                                    pnecesitainspeccion,
                                                                    mensajes);

                IF (ptablas = 'EST') THEN
                   BEGIN
                      INSERT INTO estriesgos_ir
                                  (sseguro, nriesgo, nmovimi, cinspreq,
                                   cresultr)
                           VALUES (psseguro, pnriesgo, pnmovimi, pnecesitainspeccion,
                                   presultadoinspeccion);
                   EXCEPTION
                      WHEN DUP_VAL_ON_INDEX THEN
                         UPDATE estriesgos_ir
                            SET cinspreq = pnecesitainspeccion,
                                cresultr = presultadoinspeccion
                          WHERE sseguro = psseguro
                            AND nriesgo = pnriesgo
                            AND nmovimi = pnmovimi;
                   END;
                END IF;
          END;*/
         END IF;
      ELSE
         vnumerr := pac_md_inspeccion.f_resultado_inspeccion(ptablas, psseguro, w_nmovimi,
                                                             pnriesgo, presultadoinspeccion,
                                                             pnecesitainspeccion, mensajes);

         IF (ptablas = 'EST') THEN
            BEGIN
               INSERT INTO estriesgos_ir
                           (sseguro, nriesgo, nmovimi, cinspreq,
                            cresultr)
                    VALUES (psseguro, pnriesgo, pnmovimi, pnecesitainspeccion,
                            presultadoinspeccion);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE estriesgos_ir
                     SET cinspreq = pnecesitainspeccion,
                         cresultr = presultadoinspeccion
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = pnmovimi;
            END;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_gestion_inspeccion;

   FUNCTION f_tiene_inspec_vigente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pctipmat IN VARCHAR2,
      pcmatric IN VARCHAR2,
      psproduc IN NUMBER,
      ptablas IN VARCHAR2,
      pmodo IN VARCHAR2,
      pinspeccion_vigente OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_TIENE_INSPEC_VIGENTE';
      vctipmat       NUMBER;
      vcont          NUMBER;
      vquery         VARCHAR2(2000);
      w_nmovimi      NUMBER := pnmovimi;
      vcmatric       VARCHAR2(100);
      vviginspdias   NUMBER;
      vsproduc       NUMBER;
      vsorden        NUMBER;
      vvalmotivos    NUMBER;
   BEGIN
      pinspeccion_vigente := 0;

      IF (pmodo NOT LIKE('%420%')
          OR pmodo NOT LIKE('%422%')
          OR pmodo NOT LIKE('%424%')) THEN
         w_nmovimi := pnmovimi;

         BEGIN
            IF pnmovimi IS NULL THEN
               IF ptablas = 'POL' THEN
                  SELECT MAX(nmovimi)
                    INTO w_nmovimi
                    FROM movseguro
                   WHERE sseguro = psseguro;
               ELSE
                  SELECT MAX(ea.nmovimi)
                    INTO w_nmovimi
                    FROM autriesgos ea
                   WHERE ea.sseguro = psseguro;
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_nmovimi := 1;
         END;

         vpasexec := 27;
--comprobamos si hay alguna inspeccion vigente
         vnumerr := pac_cfg.f_get_user_accion_permitida(pac_md_common.f_get_cxtusuario,
                                                        'VIGENCIA_INSPECCION', psproduc,
                                                        pac_md_common.f_get_cxtempresa(),
                                                        vviginspdias);
         vnumerr := 0;

         IF vviginspdias IS NULL THEN
            vviginspdias := pac_mdpar_productos.f_get_parproducto('VIGENCIA_ORDENINSP',
                                                                  psproduc);
         END IF;

         SELECT COUNT(1)
           INTO vcont
           FROM ir_inspecciones ii, ir_ordenes io
          WHERE ii.sorden = io.sorden
            AND ii.cempres = io.cempres
            AND ii.cestado = 3
            AND io.cmatric LIKE pcmatric
            AND ii.cempres = pac_md_common.f_get_cxtempresa
            AND f_sysdate - ii.finspeccion < vviginspdias;

         IF vcont > 0 THEN
            pinspeccion_vigente := 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_tiene_inspec_vigente;

      /*************************************************************************
    f_retencion
      Crear retención por inspeccion
      param in  psseguro                : sseguro
      param in  pnmovimi                : Numero de movimiento de la poliza
      param out t_iax_mensajes       : mensajes de error
      return                         : 0 todo correcto
                                       1 aviso
                                       2 error
   ****************************************************************************/
   FUNCTION f_retencion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes,
      pmotretencion IN NUMBER DEFAULT 16)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500) := 'psseguro: ' || psseguro || ' - pnmovimi: ' || pnmovimi;
      v_object       VARCHAR2(200) := 'PAC_MD_DOCREQUERIDA.f_retencion';
      vcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      num_err        NUMBER;
   BEGIN
      num_err := pac_inspeccion.f_retener_poliza('EST', psseguro, 1, pnmovimi, pmotretencion,
                                                 1, pfecha);
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 2;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 2;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 2;
   END f_retencion;

   FUNCTION f_gest_retener_porinspeccion(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pnecesitainspeccion_in IN NUMBER,
      presultadoinspeccion_in IN NUMBER,
      psorden OUT NUMBER,
      pcreteni OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pgestretinsp IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_gest_retener_porinspeccion';
      vcmatric       NUMBER;
      vctipmat       NUMBER;
      vcont          NUMBER;
      vquery         VARCHAR2(2000);
      vpsuretenidas  NUMBER := 0;
      vpsucritica    NUMBER;
      vsproduc       NUMBER;
      vcmotret       NUMBER;
      vcreteni       NUMBER;
      presultadoinspeccion NUMBER;
      pnecesitainspeccion NUMBER;
   BEGIN
      p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 1, 'f_gest_retener_porinspeccion',
                  vparam);

      IF NOT pac_iax_produccion.isaltacol
         OR pac_iax_produccion.isaltacol IS NULL THEN
         IF ptablas = 'EST' THEN
            SELECT creteni
              INTO vcreteni
              FROM estseguros es
             WHERE sseguro = psseguro;
         ELSE
            SELECT creteni
              INTO vcreteni
              FROM seguros es
             WHERE sseguro = psseguro;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 2,
                     'f_gest_retener_porinspeccion - vcreteni : ', vcreteni);
         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 3,
                     'f_gest_retener_porinspeccion -  pnecesitainspeccion_in : ',
                     pnecesitainspeccion_in);
         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 4,
                     'f_gest_retener_porinspeccion - presultadoinspeccion_in : ',
                     presultadoinspeccion_in);

         IF pnecesitainspeccion_in IS NULL
            AND presultadoinspeccion_in IS NULL THEN
            vnumerr := pac_md_inspeccion.f_resultado_inspeccion(ptablas, psseguro, pnmovimi,
                                                                pnriesgo,
                                                                presultadoinspeccion,
                                                                pnecesitainspeccion, mensajes,
                                                                pgestretinsp);
         ELSE
            pnecesitainspeccion := pnecesitainspeccion_in;
            presultadoinspeccion := presultadoinspeccion_in;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 5,
                     'f_gest_retener_porinspeccion - pnecesitainspeccion : ',
                     pnecesitainspeccion);
         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 6,
                     'f_gest_retener_porinspeccion - presultadoinspeccion : ',
                     presultadoinspeccion);

         IF pnecesitainspeccion != 0
            AND presultadoinspeccion IN(4, 5, 2, 1) THEN
            IF ptablas = 'EST' THEN
               BEGIN
                  SELECT cmotret, sproduc, creteni
                    INTO vcmotret, vsproduc, vcreteni
                    FROM estpsu_retenidas epr, estseguros es
                   WHERE epr.sseguro = psseguro
                     AND es.sseguro = epr.sseguro
                     AND nmovimi = pnmovimi;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vcmotret := 0;
               END;

               IF vcmotret IN(2, 3) THEN
                  vpsuretenidas := 1;   ----retenida con psus

                  BEGIN
                     SELECT COUNT(1)
                       INTO vpsucritica
                       FROM psu_controlpro pc, estseguros a, esttomadores b,
                            estpsucontrolseg e
                      WHERE pc.ccontrol = e.ccontrol
                        AND pc.sproduc = vsproduc
                        AND pc.ccritico = 1
                        AND(e.cnivelr <> 0)
                        AND e.cautrec = 0
                        AND e.nmovimi = pnmovimi
                        AND a.sseguro = psseguro
                        AND e.nmovimi = (SELECT MAX(c.nmovimi)
                                           FROM estpsucontrolseg c
                                          WHERE c.sseguro = psseguro
                                            AND c.nriesgo = e.nriesgo)
                        AND b.sseguro = a.sseguro
                        AND b.nordtom = (SELECT MIN(c.nordtom)
                                           FROM esttomadores c
                                          WHERE c.sseguro = a.sseguro)
                        AND e.sseguro = a.sseguro;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vpsucritica := 0;
                  END;

                  IF vpsucritica > 0 THEN
                     vpsuretenidas := 2;   --retenida con psu criticas
                  END IF;
               END IF;
            ELSE
               BEGIN
                  SELECT cmotret, sproduc, es.creteni
                    INTO vcmotret, vsproduc, vcreteni
                    FROM psu_retenidas epr, seguros es
                   WHERE epr.sseguro = psseguro
                     AND es.sseguro = epr.sseguro
                     AND nmovimi = pnmovimi;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vcmotret := 0;
                     vpsuretenidas := 0;
               END;

               p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 7,
                           'f_gest_retener_porinspeccion - vcmotret : ', vcmotret);
               p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 8,
                           'f_gest_retener_porinspeccion - vsproduc : ', vsproduc);
               p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 9,
                           'f_gest_retener_porinspeccion - vcreteni : ', vcreteni);

               IF vcmotret IN(2, 3) THEN
                  vpsuretenidas := 1;   ----retenida con psus

                  BEGIN
                     SELECT COUNT(1)
                       INTO vpsucritica
                       FROM psu_controlpro pc, seguros a, tomadores b, psucontrolseg e
                      WHERE pc.ccontrol = e.ccontrol
                        AND pc.sproduc = vsproduc
                        AND pc.ccritico = 1
                        AND(e.cnivelr <> 0)
                        AND e.cautrec = 0
                        AND e.nmovimi = pnmovimi
                        AND a.sseguro = psseguro
                        AND e.nmovimi = (SELECT MAX(c.nmovimi)
                                           FROM psucontrolseg c
                                          WHERE c.sseguro = psseguro
                                            AND c.nriesgo = e.nriesgo)
                        AND b.sseguro = a.sseguro
                        AND b.nordtom = (SELECT MIN(c.nordtom)
                                           FROM tomadores c
                                          WHERE c.sseguro = a.sseguro)
                        AND e.sseguro = a.sseguro;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vpsucritica := 0;
                  END;

                  IF vpsucritica > 0 THEN
                     vpsuretenidas := 2;   --retenida con psu criticas
                  END IF;
               END IF;
            END IF;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 10,
                     'f_gest_retener_porinspeccion - vpsuretenidas : ', vpsuretenidas);
         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 11,
                     'f_gest_retener_porinspeccion - presultadoinspeccion : ',
                     presultadoinspeccion);
         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 12,
                     'f_gest_retener_porinspeccion - pcreteni : ', pcreteni);
         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 13,
                     'f_gest_retener_porinspeccion - vcreteni : ', vcreteni);

         IF presultadoinspeccion = 5 THEN   --pendent solicitar
            IF vpsuretenidas IN(1, 0) THEN   --sin psu's o psu's autorizadas
               vnumerr := pac_md_inspeccion.f_crear_orden_insp(ptablas, psseguro, pnmovimi, 1,
                                                               psorden, mensajes);

               IF vnumerr <> 0 THEN
                  RETURN 1;
               END IF;

               IF psorden IS NOT NULL THEN
                  IF vpsuretenidas > 0 THEN
                     pcreteni := 10;   --Pendent autorizació i inspecció de risc
                  ELSE
                     pcreteni := 7;   --Pendiente de inspección
                  END IF;

                  presultadoinspeccion := 4;
               ELSE
                  pcreteni := 10;   --Pendent autorizació i inspecció de risc
               END IF;
            ELSE   --psu criticas
               pcreteni := 13;   --Pendent autorizació (PSU crítica) i inspecció de risc
            --no llancem inspecció
            END IF;
         ELSIF presultadoinspeccion = 4 THEN   --pendent de rebre inspecció
            IF vpsuretenidas > 0 THEN
               pcreteni := 10;   --Pendent autorizació i inspecció de risc
            ELSE
               pcreteni := 7;   --Pendiente de inspección
            END IF;
         ELSIF presultadoinspeccion = 1 THEN   --Aprovada
            p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 15,
                        'f_gest_retener_porinspeccion--Aprovada : ', vpsuretenidas);
            p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 16,
                        'f_gest_retener_porinspeccion--Aprovada : ', vcreteni);

            IF vpsuretenidas > 0 THEN
               pcreteni := 12;   --Pendent autorizació i inspecció de risc - inspecció aprovada
            ELSE
               IF vcreteni = 14
                  OR vcreteni = 15 THEN
                  pcreteni := 15;   --Autorizada - Inspecció aprovada
               ELSIF vcreteni = 10 THEN
                  pcreteni := 12;   --Pendent autorizació i inspecció de risc - inspecció aprovada
               ELSE
                  pcreteni := 9;   --Inspecció aprovada
               END IF;
            END IF;
         ELSIF presultadoinspeccion = 2 THEN   --Rebutjada
            IF vpsuretenidas > 0 THEN
               IF vcreteni IN(8) THEN
                  pcreteni := 2;   --El deixem com a pdt. autorització-
               ELSE
                  pcreteni := 11;   --Pendent autorizació i inspecció de risc - inspecció rebutjada
               END IF;
            ELSE
               IF vcreteni = 14
                  OR vcreteni = 16 THEN
                  pcreteni := 16;   --Autorizada - Inspecció rebutjada
               ELSIF vcreteni = 10 THEN
                  pcreteni := 11;   --Pendent autorizació i inspecció de risc - inspecció rebutjada
               ELSE
                  pcreteni := 8;   --Inspecció rebutjada
               END IF;
            END IF;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 14,
                     'f_gest_retener_porinspeccion - pcreteni : ', pcreteni);

         IF pcreteni IS NOT NULL THEN
            -- edit detvalores where cvalor = 755
            vnumerr := pac_inspeccion.f_retener_poliza(ptablas, psseguro, pnriesgo, pnmovimi,
                                                       vcmotret, pcreteni, f_sysdate);
         END IF;

         IF (ptablas = 'EST') THEN
            BEGIN
               INSERT INTO estriesgos_ir
                           (sseguro, nriesgo, nmovimi, cinspreq,
                            cresultr)
                    VALUES (psseguro, pnriesgo, pnmovimi, pnecesitainspeccion,
                            presultadoinspeccion);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE estriesgos_ir
                     SET cinspreq = pnecesitainspeccion,
                         cresultr = presultadoinspeccion
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = pnmovimi;
            END;
         END IF;

         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_gest_retener_porinspeccion;

   FUNCTION f_resultado_inspeccion(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      presultadoinspeccion OUT NUMBER,
      pnecesitainspeccion OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pgestretinsp IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_resultado_inspeccion';
      vcmatric       VARCHAR2(100);
      vctipmat       NUMBER;
      vcont          NUMBER;
      vquery         VARCHAR2(2000);
   BEGIN
      IF pgestretinsp = 0
         OR pgestretinsp IS NULL THEN
         pnecesitainspeccion := pac_md_inspeccion.f_necesita_inspeccion(psseguro, pnmovimi,
                                                                        ptablas, mensajes);
         vpasexec := 2;
      ELSE
         pnecesitainspeccion := 1;
      END IF;

      IF pnecesitainspeccion = 0 THEN
                    /* BEGIN
                        IF ptablas = 'POL' THEN
                           SELECT cinspreq, cresultr
                             INTO pnecesitainspeccion, presultadoinspeccion
                             FROM riesgos_ir r, seguros s
                            WHERE r.sseguro = psseguro
                              AND nmovimi = pnmovimi
                              AND nriesgo = pnriesgo
                              AND r.sseguro = s.sseguro;
                        --AND f_situacion_poliza(s.sseguro) <> 2;
                        ELSE
                           SELECT cinspreq, cresultr
                             INTO pnecesitainspeccion, presultadoinspeccion
                             FROM estriesgos_ir r, estseguros s
                            WHERE r.sseguro = psseguro
                              AND nmovimi = pnmovimi
                              AND nriesgo = pnriesgo
                              AND r.sseguro = s.sseguro;
                        -- AND f_situacion_poliza(s.sseguro) <> 2;
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           presultadoinspeccion := 0;
                     END;

         */
         presultadoinspeccion := 0;
         vpasexec := 3;
      ELSIF pnecesitainspeccion = 1 THEN
         vpasexec := 4;

         IF ptablas = 'POL' THEN
            SELECT cmatric, ctipmat
              INTO vcmatric, vctipmat
              FROM autriesgos
             WHERE sseguro = psseguro
               AND((pnmovimi IS NOT NULL
                    AND nmovimi = pnmovimi)
                   OR(pnmovimi IS NULL
                      AND nmovimi = (SELECT MAX(nmovimi)
                                       FROM movseguro
                                      WHERE sseguro = psseguro)))
               AND nriesgo = NVL(pnriesgo, 1);

            vpasexec := 5;

            IF vcmatric IS NOT NULL THEN
               SELECT COUNT(1)
                 INTO vcont
                 FROM autriesgos ar, riesgos_ir ri, riesgos_ir_ordenes rio, seguros s
                WHERE ctipmat = vctipmat
                  AND cmatric LIKE vcmatric
                  AND ar.sseguro = ri.sseguro
                  AND ar.nriesgo = ri.nriesgo
                  AND ar.nmovimi = ri.nmovimi
                  AND s.sseguro = ar.sseguro
                  AND rio.cempres = s.cempres
                  AND rio.sseguro = ri.sseguro
                  AND rio.nmovimi = ri.nmovimi
                  AND rio.nriesgo = ri.nriesgo;
            ELSE
               vcont := 0;
            END IF;

            vpasexec := 6;

            IF vcont > 0 THEN
               SELECT COUNT(1)
                 INTO vcont
                 FROM autriesgos ar, riesgos_ir ri, riesgos_ir_ordenes rio, ir_inspecciones ii,
                      seguros s
                WHERE ctipmat = vctipmat
                  AND cmatric LIKE vcmatric
                  AND ar.sseguro = ri.sseguro
                  AND ar.nriesgo = ri.nriesgo
                  AND ar.nmovimi = ri.nmovimi
                  AND ar.sseguro = s.sseguro
                  AND rio.cempres = s.cempres
                  AND rio.sseguro = ri.sseguro
                  AND rio.nmovimi = ri.nmovimi
                  AND rio.nriesgo = ri.nriesgo
                  AND rio.cempres = ii.cempres
                  AND ii.sorden = rio.sorden;

               vpasexec := 7;

               IF vcont = 0 THEN
                  presultadoinspeccion := 4;
               ELSE
                  SELECT cresultr
                    INTO presultadoinspeccion
                    FROM autriesgos ar, riesgos_ir ri, riesgos_ir_ordenes rio, seguros s
                   WHERE ctipmat = vctipmat
                     AND cmatric LIKE vcmatric
                     AND ar.sseguro = ri.sseguro
                     AND ar.nriesgo = ri.nriesgo
                     AND ar.nmovimi = ri.nmovimi
                     AND ar.sseguro = s.sseguro
                     AND rio.cempres = s.cempres
                     AND rio.sseguro = ri.sseguro
                     AND rio.nmovimi = ri.nmovimi
                     AND rio.nriesgo = ri.nriesgo
                     AND ROWNUM = 1;
               END IF;
            ELSE
               presultadoinspeccion := 5;
            END IF;

            vpasexec := 8;
         ELSIF ptablas = 'EST' THEN
            SELECT cmatric, ctipmat
              INTO vcmatric, vctipmat
              FROM estautriesgos
             WHERE sseguro = psseguro
               AND nriesgo = NVL(pnriesgo, 1);

            vpasexec := 9;

            IF vcmatric IS NOT NULL THEN
               SELECT COUNT(1)
                 INTO vcont
                 FROM estautriesgos ar, estriesgos_ir ri, estriesgos_ir_ordenes rio
                WHERE ctipmat = vctipmat
                  AND cmatric LIKE vcmatric
                  AND ar.sseguro = ri.sseguro
                  AND ar.nriesgo = ri.nriesgo
                  AND ar.nmovimi = ri.nmovimi
                  AND rio.cempres = pac_md_common.f_get_cxtempresa
                  AND rio.sseguro = ri.sseguro
                  AND rio.nmovimi = ri.nmovimi
                  AND rio.nriesgo = ri.nriesgo;
            ELSE
               vcont := 0;
            END IF;

            vpasexec := 10;

            IF vcont > 0 THEN
               SELECT COUNT(1)
                 INTO vcont
                 FROM estautriesgos ar, estriesgos_ir ri, estriesgos_ir_ordenes rio,
                      ir_inspecciones ii
                WHERE ctipmat = vctipmat
                  AND cmatric LIKE vcmatric
                  AND ar.sseguro = ri.sseguro
                  AND ar.nriesgo = ri.nriesgo
                  AND ar.nmovimi = ri.nmovimi
                  AND rio.cempres = pac_md_common.f_get_cxtempresa
                  AND rio.sseguro = ri.sseguro
                  AND rio.nmovimi = ri.nmovimi
                  AND rio.nriesgo = ri.nriesgo
                  AND rio.cempres = ii.cempres
                  AND ii.sorden = rio.sorden;

               vpasexec := 11;

               IF vcont = 0 THEN
                  presultadoinspeccion := 4;
               ELSE
                  SELECT cresultr
                    INTO presultadoinspeccion
                    FROM estautriesgos ar, estriesgos_ir ri, estriesgos_ir_ordenes rio
                   WHERE ctipmat = vctipmat
                     AND cmatric LIKE vcmatric
                     AND ar.sseguro = ri.sseguro
                     AND ar.nriesgo = ri.nriesgo
                     AND ar.nmovimi = ri.nmovimi
                     AND rio.cempres = pac_md_common.f_get_cxtempresa
                     AND rio.sseguro = ri.sseguro
                     AND rio.nmovimi = ri.nmovimi
                     AND rio.nriesgo = ri.nriesgo
                     AND ROWNUM = 1;

                  pnecesitainspeccion := pac_md_inspeccion.f_necesita_inspeccion(psseguro,
                                                                                 pnmovimi,
                                                                                 ptablas,
                                                                                 mensajes);
                  vpasexec := 12;

                  IF (pnecesitainspeccion IS NOT NULL
                      AND pnecesitainspeccion = 0)
                     OR presultadoinspeccion IS NULL THEN
                     pnecesitainspeccion := 1;
                     presultadoinspeccion := 5;
                  END IF;
               END IF;
            ELSE
               vpasexec := 13;
               presultadoinspeccion := 5;
            END IF;
         END IF;
      END IF;

      -- COMMIT;
      vpasexec := 14;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_resultado_inspeccion;

   FUNCTION f_permite_emitirinspeccion(
      psseguro IN NUMBER,
      ptablas IN VARCHAR,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500) := 'psseguro: ' || psseguro || ' - ptablas: ' || ptablas;
      v_object       VARCHAR2(200) := 'PAC_MD_inspeccion.f_permite_emitirinspeccion';
      vcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      vnumerr        NUMBER := 0;
      vsproduc       NUMBER;
      vvigorden      NUMBER;
      vfsolicitud    DATE;
      vsorden        NUMBER;
      vdias          NUMBER;
      vviginspdias   NUMBER;
      vcont          NUMBER;
   BEGIN
      --si la propuesta esta vigente, y la orden y la inspección tambien dejaremos emitir.
      IF ptablas = 'POL' THEN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      END IF;

      vvigorden := pac_mdpar_productos.f_get_parproducto('VIGENCIA_ORDENINSP', vsproduc);   -- orden --35 dias

      FOR i IN (SELECT fsolicitud, rio.sorden, cinspreq, cresultr
                  FROM riesgos_ir ri, riesgos_ir_ordenes rio, ir_ordenes io
                 WHERE ri.sseguro = rio.sseguro
                   AND ri.nmovimi = rio.nmovimi
                   AND ri.nriesgo = rio.nriesgo
                   AND rio.cempres = pac_md_common.f_get_cxtempresa
                   AND rio.cempres = io.cempres
                   AND rio.sorden = io.sorden
                   AND ri.sseguro = psseguro
                   AND ri.nriesgo = 1   --todo
                   AND ri.nmovimi = (SELECT MAX(nmovimi)
                                       FROM movseguro
                                      WHERE sseguro = psseguro)) LOOP
         IF i.cinspreq = 1
            AND i.cresultr IN(4, 5) THEN
            vsorden := i.sorden;
            vfsolicitud := i.fsolicitud;
            vdias := f_sysdate - vfsolicitud;

            IF vvigorden IS NOT NULL
               AND vdias > vvigorden THEN
               RETURN 9905394;   --La orden no esta vigente
            ELSE
               vnumerr :=
                  pac_cfg.f_get_user_accion_permitida(f_user, 'VIGENCIA_INSPECCION', vsproduc,
                                                      pac_md_common.f_get_cxtempresa(),
                                                      vviginspdias);
               vnumerr := 0;

               IF vviginspdias IS NULL THEN
                  vviginspdias := pac_mdpar_productos.f_get_parproducto('VIGENCIA_ORDENINSP',
                                                                        vsproduc);
               END IF;

               SELECT COUNT(1)
                 INTO vcont
                 FROM ir_inspecciones
                WHERE cempres = pac_md_common.f_get_cxtempresa
                  AND sorden = vsorden
                  AND f_sysdate - finspeccion > vviginspdias;

               IF vcont > 0 THEN
                  --miramos la vigencia de la inspeccion
                  RETURN 9905395;   --la inspección no esta vigente
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 2;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 3;
   END f_permite_emitirinspeccion;

   FUNCTION f_permite_emitirinspec_pend(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCION.f_permite_emitirinspec_pend';
      vparam         VARCHAR2(1000)
                 := 'parámetros - pparams : psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnuminspec     NUMBER := 0;
   BEGIN
      vnumerr := pac_md_inspeccion.f_permite_emitirinspeccion(psseguro, ptablas, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN 1;
      END IF;

      vpasexec := 2;

      SELECT COUNT(*)
        INTO vnuminspec
        FROM riesgos_ir ri
       WHERE ri.cinspreq = 1   --inspeccion requerida=1
         AND ri.cresultr = 5   --Pendent Sol·licitar ordre =5 (VF 755)
         AND ri.sseguro = psseguro
         AND nmovimi IN(SELECT MAX(nmovimi)
                          FROM movseguro
                         WHERE sseguro = psseguro);

      IF (vnuminspec > 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905778);
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_permite_emitirinspec_pend;

   FUNCTION f_get_irordenes(
      ptablas IN VARCHAR2,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'pctipmat :' || pctipmat || ', pcmatric : ' || pcmatric || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_get_irordenes';
      vquery         VARCHAR2(2000);
      vmatric        VARCHAR2(50) := ' = ' || CHR(39) || pcmatric || CHR(39);
   BEGIN
      IF ptablas = 'POL' THEN
         IF (pctipmat IS NOT NULL) THEN
            IF (pcmatric IS NULL
                OR TRIM(pcmatric) = '') THEN
               vmatric := 'IS NULL';
            END IF;

            vquery :=
               'SELECT sorden, fsolicitud, ff_desvalorfijo (754, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ctiporiesgo) triesgo,
                    ff_desvalorfijo (750, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cestado) testado,
                    ff_desvalorfijo (751, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cclase) tclase,
                    t.ttitulo tproducto, ff_desvalorfijo (290, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ctipmat) ttipmat,
                    cmatric, codmotor, cchasis, nbastid FROM ir_ordenes iro,productos p, titulopro t WHERE iro.cmatric '
               || vmatric || ' AND iro.ctipmat= ' || CHR(39) || pctipmat || CHR(39)
               || ' AND p.sproduc = iro.sproduc'
               || ' AND t.cramo = p.cramo
      AND t.cmodali = p.cmodali
      AND t.ctipseg = p.ctipseg
      AND t.ccolect = p.ccolect
      AND t.cmodali = p.cmodali
      AND t.cidioma = pac_iax_common.f_get_cxtidioma';
         ELSE
            vquery :=
               'SELECT iro.sorden, fsolicitud, ff_desvalorfijo (754, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ctiporiesgo) triesgo,
                    ff_desvalorfijo (750, PAC_MD_COMMON.F_Get_CXTIDIOMA(),iro.cestado) testado,
                    ff_desvalorfijo (751, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cclase) tclase,
                    t.ttitulo tproducto, ff_desvalorfijo (290, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ctipmat) ttipmat,
                    cmatric, codmotor, cchasis, nbastid FROM ir_ordenes iro,productos p, titulopro t, ir_inspecciones iri WHERE  p.sproduc = iro.sproduc'
               || ' AND t.cramo = p.cramo
      AND t.cmodali = p.cmodali
      AND t.ctipseg = p.ctipseg
      AND t.ccolect = p.ccolect
      AND t.cmodali = p.cmodali
      AND t.cidioma = pac_iax_common.f_get_cxtidioma
      AND iri.sorden = iro.sorden
      AND iri.sorden= '
               || CHR(39) || psorden || CHR(39) || ' and iri.ninspeccion=' || CHR(39)
               || pninspeccion || CHR(39);
         END IF;
      END IF;

      vnumerr := pac_md_log.f_log_consultas(vquery, 'PAC_MD_INSPECCIONES.f_get_irordenes', 1,
                                            1, pmensajes);
      cur := pac_md_listvalores.f_opencursor(vquery, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN NO_DATA_FOUND THEN
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irordenes;

   FUNCTION f_get_irinspecciones(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                                 := 'psorden :' || psorden || 'pninspeccion :' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_get_irinspecciones';
      vquery         VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vquery :=
         'SELECT ninspeccion, finspeccion, ff_desvalorfijo (752, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cestado) testado,
                    ff_desvalorfijo (753, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cresultado) tresultado,
                    ff_desvalorfijo (9, PAC_MD_COMMON.F_Get_CXTIDIOMA(),creinspeccion) treinspeccion,
                    hllegada, hsalida, ccentroinsp,
                    ff_desvalorfijo (9, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cinspdomi) tinspdomi,
                    ff_desvalorfijo (9, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cpista) tpista FROM ir_inspecciones iri WHERE iri.sorden= '
         || CHR(39) || psorden || CHR(39);

      IF (pninspeccion IS NOT NULL) THEN
         vquery := vquery || ' and iri.ninspeccion=' || CHR(39) || pninspeccion || CHR(39);
      END IF;

      vnumerr := pac_md_log.f_log_consultas(vquery, 'PAC_MD_INSPECCIONES.f_get_irinspecciones',
                                            1, 1, pmensajes);
      cur := pac_md_listvalores.f_opencursor(vquery, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN NO_DATA_FOUND THEN
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irinspecciones;

   FUNCTION f_get_irinspeccionesdveh(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                                := 'psorden :' || psorden || ' pninspeccion :' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_get_irinspeccionesdveh';
      vquery         VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vquery :=
         'SELECT cversion, ff_despais(cpaisorigen, pac_md_common.f_get_cxtidioma()) cpaisorigen, npma,ccilindraje,anyo,nplazas,
                    ff_desvalorfijo (8000904, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cservicio) tservicio,
                    ff_desvalorfijo (9, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cblindado) tblindado,
                    ff_desvalorfijo (758, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ccampero) tcampero,
                    ff_desvalorfijo (757, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cgama) tgama,
                    ff_desvalorfijo (759, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cmatcabina) tmatcabina,
                    ff_desvalorfijo (291, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ivehinue) tivehinue, cuso,
                    ff_desvalorfijo (440, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ccolor) tcolor,
                    nkilometraje, ff_desvalorfijo (291, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ctipmotor) ttipmotor,
                    ntara, ff_desvalorfijo (760, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cpintura) tpintura,
                    ff_desvalorfijo (8000907, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ccaja) tcaja,
                    ff_desvalorfijo (9, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ctransporte) ttransporte,
                    ff_desvalorfijo (761, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ctipcarroceria) ttipcarroceria
                    FROM ir_inspecciones_dveh irid WHERE irid.sorden= '
         || CHR(39) || psorden || CHR(39) || ' and irid.ninspeccion=' || CHR(39)
         || pninspeccion || CHR(39);
      vnumerr := pac_md_log.f_log_consultas(vquery,
                                            'PAC_MD_INSPECCIONES.f_get_irinspeccionesdveh', 1,
                                            1, pmensajes);
      cur := pac_md_listvalores.f_opencursor(vquery, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN NO_DATA_FOUND THEN
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irinspeccionesdveh;

   FUNCTION f_get_irinspeccionesacc(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                                := 'psorden :' || psorden || ' pninspeccion :' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_get_irinspeccionesacc';
      vquery         VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vquery :=
         'SELECT    autacc.TACCESORIO taccesorio,
                    ff_desvalorfijo (292, PAC_MD_COMMON.F_Get_CXTIDIOMA(),ctipacc) ttipacc, tdesacc,
                    ivalacc,
                    casegurable
                    FROM ir_inspecciones_acc iria, aut_accesorios autacc WHERE iria.caccesorio=autacc.caccesorio AND iria.sorden= '
         || CHR(39) || psorden || CHR(39) || ' and iria.ninspeccion=' || CHR(39)
         || pninspeccion || CHR(39);
      vnumerr := pac_md_log.f_log_consultas(vquery,
                                            'PAC_MD_INSPECCIONES.f_get_irinspeccionesacc', 1,
                                            1, pmensajes);
      cur := pac_md_listvalores.f_opencursor(vquery, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN NO_DATA_FOUND THEN
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irinspeccionesacc;

   FUNCTION f_get_irinspeccionesdoc(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                                := 'psorden :' || psorden || ' pninspeccion :' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_INSPECCIONES.f_get_irinspeccionesdoc';
      vquery         VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vquery :=
         'SELECT ndocume, cdocume,
                    ff_desvalorfijo (9, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cgenerado) tgenerado,
                    ff_desvalorfijo (9, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cobliga) tobliga,
                    ff_desvalorfijo (9, PAC_MD_COMMON.F_Get_CXTIDIOMA(),cadjuntado) tadjuntado,
                    iddocgedox
                    FROM ir_inspecciones_doc irid WHERE irid.sorden= '
         || CHR(39) || psorden || CHR(39) || ' and irid.ninspeccion=' || CHR(39)
         || pninspeccion || CHR(39);
      vnumerr := pac_md_log.f_log_consultas(vquery,
                                            'PAC_MD_INSPECCIONES.f_get_irinspeccionesdoc', 1,
                                            1, pmensajes);
      cur := pac_md_listvalores.f_opencursor(vquery, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN NO_DATA_FOUND THEN
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irinspeccionesdoc;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_INSPECCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_INSPECCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_INSPECCION" TO "PROGRAMADORESCSI";
