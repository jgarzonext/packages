CREATE OR REPLACE PACKAGE BODY pac_docrequerida AS
   /******************************************************************************
      NOMBRE:       PAC_DOCREQUERIDA
      PROPÓSITO: Funciones relacionadas con la documentación requerida

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        11/05/2011   JMP      1. Creación del package.
      2.0        14/10/2013   JSV      0027923: LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0
      3.0        04/11/2013   RCL      3. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
      4.0        30/04/2019   ECP      4. IAXIS-3634  Gestor Documental (Documentos internos y externos)
   ******************************************************************************/
   /*************************************************************************
         F_GET_DIRECTORIO
      Obtiene el directorio donde se subirán los ficheros.
      param in pparam                : código de parámetro
      param out ppath                : directorio
      return                         : 0 todo correcto
                                       1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_directorio(pparam IN VARCHAR2, ppath OUT VARCHAR2)
      RETURN NUMBER IS
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500) := 'pparam: ' || pparam;
      v_object       VARCHAR2(200) := 'PAC_MD_DOCREQUERIDA.f_get_directorio';
   BEGIN
      ppath := f_parinstalacion_t(pparam);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 1;
   END f_get_directorio;

   /*************************************************************************
         F_GRABARDOCREQUERIDA
      Inserta un registro en la tabla ESTDOCREQUERIDA, ESTDOCREQUERIDA_RIESGO o
      ESTDOCREQUERIDA_INQAVAL, dependiendo de la clase de documento que estamos
      insertando.
      param in pseqdocu                : número secuencial de documento
      param in psproduc                : código de producto
      param in psseguro                : número secuencial de seguro
      param in pcactivi                : código de actividad
      param in pnmovimi                : número de movimiento
      param in pnriesgo                : número de riesgo
      param in pninqaval               : número de inquilino/avalista
      param in pcdocume                : código de documento
      param in pctipdoc                : tipo de documento
      param in pcclase                 : clase de documento
      param in pnorden                 : número de orden documento
      param in ptdescrip               : descripción del documento
      param in ptfilename              : nombre del fichero
      param in padjuntado              : indicador de fichero adjuntado
      return                           : 0 todo correcto
                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabardocrequerida(
      pseqdocu IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pninqaval IN NUMBER,
      pcdocume IN NUMBER,
      pctipdoc IN NUMBER,
      pcclase IN NUMBER,
      pnorden IN NUMBER,
      ptdescrip IN VARCHAR2,
      ptfilename IN VARCHAR2,
      padjuntado IN NUMBER,
      psperson IN NUMBER,
      pctipben IN NUMBER,
      pciddocgedox IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500)
         := 'pseqdocu: ' || pseqdocu || ' - psproduc: ' || psproduc || ' - psseguro: '
            || psseguro || ' - pcactivi: ' || pcactivi || ' - pnmovimi: ' || pnmovimi
            || '- pnriesgo: ' || pnriesgo || ' - pninqaval: ' || pninqaval || ' - psperson: '
            || psperson || ' - pctipben: ' || pctipben;
      v_object       VARCHAR2(200) := 'PAC_DOCREQUERIDA.f_grabardocrequerida';
      v_seqdocu      estdocrequerida.seqdocu%TYPE;
      v_tfilename    estdocrequerida.tfilename%TYPE;
      -- Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
      v_doc_null     NUMBER;
   -- Fin Bug 20672
   BEGIN
      IF pseqdocu IS NOT NULL THEN
         v_seqdocu := pseqdocu;
      ELSE
         SELECT seqdocu.NEXTVAL
           INTO v_seqdocu
           FROM DUAL;
      END IF;

      IF pcclase = 1 THEN
         -- Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
         SELECT COUNT(*)
           INTO v_doc_null
           FROM estdocrequerida
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND cdocume = pcdocume
            AND sproduc = psproduc
            --AND cactivi = pcactivi
            AND ctipdoc = pctipdoc
            AND cclase = pcclase
            AND tfilename IS NULL;
-- INicio IAXIS-3634 -- ECP -- 30/04/2019
         IF v_doc_null > 0 THEN
            DELETE      estdocrequerida
                  WHERE sseguro = psseguro
                    AND nmovimi = pnmovimi
                    AND cdocume = pcdocume
                    AND sproduc = psproduc
                   -- AND cactivi = pcactivi
                    AND ctipdoc = pctipdoc
                    AND cclase = pcclase
                    AND tfilename IS NULL;
         END IF;
 

         -- Fin Bug 20672
         BEGIN
            INSERT INTO estdocrequerida
                        (seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc, cclase,
                         sseguro, nmovimi, tfilename, tdescrip, adjuntado,
                         iddocgedox)
                 VALUES (v_seqdocu, pcdocume, psproduc, pcactivi, pnorden, pctipdoc, pcclase,
                         psseguro, pnmovimi, ptfilename, ptdescrip, NVL(padjuntado, 1),
                         pciddocgedox);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               SELECT tfilename
                 INTO v_tfilename
                 FROM estdocrequerida
                WHERE seqdocu = pseqdocu
                  AND sseguro = psseguro
                  AND nmovimi = pnmovimi;

               -- BUG 26902_0145243 - JLTS - 2013/06/13
               IF padjuntado = 0 THEN
                  DELETE      estdocrequerida
                        WHERE seqdocu = pseqdocu
                          AND sseguro = psseguro
                          AND nmovimi = pnmovimi;
               ELSE
                  UPDATE estdocrequerida
                     SET adjuntado = padjuntado
                   WHERE seqdocu = pseqdocu
                     AND sseguro = psseguro
                     AND nmovimi = pnmovimi;
               END IF;
         END;

         -- Para la gestión de propuestas retenida (MODIF_PROP_245)
         UPDATE pds_estsegurosupl
            SET cestado = 'X'
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND cmotmov = 245;
      ELSIF pcclase = 2 THEN
         -- Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
         SELECT COUNT(*)
           INTO v_doc_null
           FROM estdocrequerida_riesgo
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nriesgo = pnriesgo
            AND cdocume = pcdocume
            AND sproduc = psproduc
            --AND cactivi = pcactivi
            AND ctipdoc = pctipdoc
            AND cclase = pcclase
            AND tfilename IS NULL;

         IF v_doc_null > 0 THEN
            DELETE      estdocrequerida_riesgo
                  WHERE sseguro = psseguro
                    AND nmovimi = pnmovimi
                    AND nriesgo = pnriesgo
                    AND cdocume = pcdocume
                    AND sproduc = psproduc
                    --AND cactivi = pcactivi
                    AND ctipdoc = pctipdoc
                    AND cclase = pcclase
                    AND tfilename IS NULL;
         END IF;

         -- Fin Bug 20672
         BEGIN
            INSERT INTO estdocrequerida_riesgo
                        (seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc, cclase,
                         sseguro, nmovimi, nriesgo, tfilename, tdescrip,
                         adjuntado, iddocgedox)
                 VALUES (v_seqdocu, pcdocume, psproduc, pcactivi, pnorden, pctipdoc, pcclase,
                         psseguro, pnmovimi, pnriesgo, ptfilename, ptdescrip,
                         NVL(padjuntado, 1), pciddocgedox);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               SELECT tfilename
                 INTO v_tfilename
                 FROM estdocrequerida_riesgo
                WHERE seqdocu = pseqdocu
                  AND sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND nriesgo = pnriesgo;

               -- BUG 26902_0145243 - JLTS - 2013/06/13
               IF padjuntado = 0 THEN
                  DELETE      estdocrequerida_riesgo
                        WHERE seqdocu = pseqdocu
                          AND sseguro = psseguro
                          AND nmovimi = pnmovimi
                          AND nriesgo = pnriesgo;
               ELSE
                  UPDATE estdocrequerida_riesgo
                     SET adjuntado = padjuntado
                   WHERE seqdocu = pseqdocu
                     AND sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND nriesgo = pnriesgo;
               END IF;
         END;

         -- Para la gestión de propuestas retenida (MODIF_PROP_245)
         UPDATE pds_estsegurosupl
            SET cestado = 'X'
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND cmotmov = 245;
      ELSIF pcclase IN(3, 4) THEN
         -- Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
         SELECT COUNT(*)
           INTO v_doc_null
           FROM estdocrequerida_inqaval
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND ninqaval = pninqaval
            AND cdocume = pcdocume
            AND sproduc = psproduc
            --AND cactivi = pcactivi
            AND ctipdoc = pctipdoc
            AND cclase = pcclase
            AND sperson = psperson
            AND tfilename IS NULL;

         IF v_doc_null > 0 THEN
            DELETE      estdocrequerida_inqaval
                  WHERE sseguro = psseguro
                    AND nmovimi = pnmovimi
                    AND ninqaval = pninqaval
                    AND cdocume = pcdocume
                    AND sproduc = psproduc
                   -- AND cactivi = pcactivi
                    AND ctipdoc = pctipdoc
                    AND cclase = pcclase
                    AND sperson = psperson
                    AND tfilename IS NULL;
         END IF;

         -- Fin Bug 20672
         BEGIN
            INSERT INTO estdocrequerida_inqaval
                        (seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc, cclase,
                         sseguro, nmovimi, ninqaval, tfilename, tdescrip,
                         adjuntado, iddocgedox, sperson)
                 VALUES (v_seqdocu, pcdocume, psproduc, pcactivi, pnorden, pctipdoc, pcclase,
                         psseguro, pnmovimi, pninqaval, ptfilename, ptdescrip,
                         NVL(padjuntado, 1), pciddocgedox, psperson);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               SELECT tfilename
                 INTO v_tfilename
                 FROM estdocrequerida_inqaval
                WHERE seqdocu = pseqdocu
                  AND sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND ninqaval = pninqaval
                  AND sperson = psperson;

               -- BUG 26902_0145243 - JLTS - 2013/06/13
               IF padjuntado = 0 THEN
                  DELETE      estdocrequerida_inqaval
                        WHERE seqdocu = pseqdocu
                          AND sseguro = psseguro
                          AND nmovimi = pnmovimi
                          AND ninqaval = pninqaval
                          AND sperson = psperson;
               ELSE
                  UPDATE estdocrequerida_inqaval
                     SET adjuntado = padjuntado
                   WHERE seqdocu = pseqdocu
                     AND sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND ninqaval = pninqaval
                     AND sperson = psperson;
               END IF;
         END;

         -- Para la gestión de propuestas retenida (MODIF_PROP_245)
         UPDATE pds_estsegurosupl
            SET cestado = 'X'
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND cmotmov = 245;
      ELSIF pcclase = 5 THEN
         -- Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
         SELECT COUNT(*)
           INTO v_doc_null
           FROM estdocrequerida_benespseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nriesgo = pnriesgo
            AND cdocume = pcdocume
            AND sproduc = psproduc
            --AND cactivi = pcactivi
            AND ctipdoc = pctipdoc
            AND cclase = pcclase
            AND sperson = psperson
            AND ctipben = pctipben
            AND tfilename IS NULL;

         IF v_doc_null > 0 THEN
            DELETE      estdocrequerida_benespseg
                  WHERE sseguro = psseguro
                    AND nmovimi = pnmovimi
                    AND nriesgo = pnriesgo
                    AND cdocume = pcdocume
                    AND sproduc = psproduc
                    --AND cactivi = pcactivi
                    AND ctipdoc = pctipdoc
                    AND cclase = pcclase
                    AND sperson = psperson
                    AND ctipben = pctipben
                    AND tfilename IS NULL;
         END IF;

         -- Fin Bug 20672
         BEGIN
            INSERT INTO estdocrequerida_benespseg
                        (seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc, cclase,
                         sseguro, nmovimi, nriesgo, tfilename, tdescrip,
                         adjuntado, iddocgedox, sperson, ctipben)
                 VALUES (v_seqdocu, pcdocume, psproduc, pcactivi, pnorden, pctipdoc, pcclase,
                         psseguro, pnmovimi, pnriesgo, ptfilename, ptdescrip,
                         NVL(padjuntado, 1), pciddocgedox, psperson, pctipben);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               SELECT tfilename
                 INTO v_tfilename
                 FROM estdocrequerida_benespseg
                WHERE seqdocu = pseqdocu
                  AND sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND nriesgo = pnriesgo
                  AND sperson = psperson
                  AND ctipben = pctipben;

               -- BUG 26902_0145243 - JLTS - 2013/06/13
               IF padjuntado = 0 THEN
                  DELETE      estdocrequerida_benespseg
                        WHERE seqdocu = pseqdocu
                          AND sseguro = psseguro
                          AND nmovimi = pnmovimi
                          AND nriesgo = pnriesgo
                          AND sperson = psperson
                          AND ctipben = pctipben;
               ELSE
                  UPDATE estdocrequerida_benespseg
                     SET adjuntado = padjuntado
                   WHERE seqdocu = pseqdocu
                     AND sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND nriesgo = pnriesgo
                     AND sperson = psperson
                     AND ctipben = pctipben;
               END IF;
         END;

         -- Para la gestión de propuestas retenida (MODIF_PROP_245)
         UPDATE pds_estsegurosupl
            SET cestado = 'X'
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND cmotmov = 245;
      END IF;
      -- FIN IAXIS-3634 -- ECP -- 30/04/2019

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 1;
   END f_grabardocrequerida;

   -- Bug: 27923/155724 - JSV - 14/10/2013
   FUNCTION f_docreq_col(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcdocume IN NUMBER,
      pctipdoc IN OUT NUMBER)
      RETURN NUMBER IS
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500)
         := 'pparam: psseguro = ' || psseguro || '; pnmovimi = ' || pnmovimi
            || '; psproduc = ' || psproduc || '; pcactivi = ' || pcactivi;
      v_object       VARCHAR2(200) := 'PAC_DOCREQUERIDA.f_docreq_col';
      v_error        NUMBER;
      mensajes       t_iax_mensajes;
      v_cdocreq      NUMBER;
      vnpoliza       NUMBER;
      vcount         NUMBER;
      vsseguro       NUMBER;
      vselect        VARCHAR2(1000);
      vrespuestas    sys_refcursor;
      vcpregun       NUMBER;
      vnmovimi       NUMBER;
      vnlinea        NUMBER;
      vccolumna      VARCHAR2(50);
      vtvalor        VARCHAR2(250);
      vfvalor        DATE;
      vnvalor        NUMBER;
      trobat         BOOLEAN;
   BEGIN
      IF NVL(pac_parametros.f_parproducto_n(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
         v_error := pac_productos.f_get_herencia_col(psproduc, 18, v_cdocreq);

         IF NVL(v_cdocreq, 0) = 1 THEN
            SELECT npoliza
              INTO vnpoliza
              FROM estseguros
             WHERE sseguro = psseguro;

            SELECT COUNT(1)
              INTO vcount
              FROM seguros
             WHERE npoliza = vnpoliza
               AND ncertif = 0;

            IF vcount > 0 THEN
               SELECT sseguro
                 INTO vsseguro
                 FROM seguros
                WHERE npoliza = vnpoliza
                  AND ncertif = 0;

               vselect := pac_preguntas.f_respuestas_pregtabla('POL', vsseguro, NULL, 9092,
                                                               NULL, pnmovimi, 'P');
            END IF;

            vrespuestas := pac_md_listvalores.f_opencursor(vselect, mensajes);

            LOOP
               FETCH vrespuestas
                INTO vsseguro, vcpregun, vnmovimi, vnlinea, vccolumna, vtvalor, vfvalor,
                     vnvalor;

               --Miramos si el valor de la primera columna coresponde con el cod. de la documentación
               IF vccolumna = 1 THEN
                  IF vnvalor = pcdocume THEN
                     trobat := TRUE;
                  END IF;
               END IF;

               IF vccolumna = 2 THEN
                  IF trobat THEN
                     FOR reg IN (SELECT cmotmov
                                   FROM estdetmovseguro
                                  WHERE sseguro = psseguro
                                    AND nmovimi = pnmovimi) LOOP
                        IF vnvalor = reg.cmotmov THEN
                           trobat := TRUE;
                        ELSE
                           trobat := FALSE;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;

               IF vccolumna = 3 THEN
                  IF trobat THEN
                     IF vnvalor = 1 THEN
                        pctipdoc := 2;
                     ELSE
                        pctipdoc := 1;
                     END IF;
                  END IF;

                  trobat := FALSE;
               END IF;

               EXIT WHEN vrespuestas%NOTFOUND;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 1000455;
   END f_docreq_col;

   FUNCTION f_get_docurequerida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_docrequerida IS
      --
      CURSOR c_docreq IS
        SELECT DISTINCT e.seqdocu
                       ,NVL(e.cdocume, d.cdocume) cdocume
                       ,d.sproduc
                       ,d.cactivi
                       ,d.norden
                       ,d.cclase
                       ,DECODE(e.cdocume,
                               NULL,
                               dd.ttitdoc,
                               DECODE(e.tfilename,
                                      NULL,
                                      DECODE(e.adjuntado,
                                             1,
                                             dd.ttitdoc || ' - ' || dd.ttitdoc,
                                             dd.ttitdoc),
                                      dd.ttitdoc || ' - ' || e.tdescrip)) tdescrip
                       ,NVL(e.ctipdoc, d.ctipdoc) ctipdoc
                       ,d.tfuncio
                       ,e.tfilename
                       ,NVL(e.adjuntado, 0) adjuntado
                       ,NULL nriesgo
                       ,NULL ninqaval
                       ,NULL ctipo
                       ,NULL sperson
                       ,NULL ctipben
                       ,e.crecibido
                       ,e.frecibido
          FROM doc_docurequerida d, doc_desdocumento dd, seguros s, docrequerida e
         WHERE s.sseguro = psseguro
           AND s.sproduc = d.sproduc
           AND d.sproduc = s.sproduc
           --AND d.cactivi = s.cactivi
           AND e.sseguro(+) = psseguro
           AND e.cdocume(+) = d.cdocume
           AND e.ctipdoc(+) = d.ctipdoc
           AND e.norden(+) = d.norden
           AND e.nmovimi(+) = NVL(1, 1)
           AND d.cclase = 1
           AND d.cdocume = dd.cdocume
           AND dd.cidioma = pac_md_common.f_get_cxtidioma()
           AND (d.cmotmov IN (SELECT DISTINCT cmotmov
                                FROM detmovseguro
                               WHERE sseguro = psseguro
                                 AND nmovimi = NVL(1, 1)) OR
               (d.cmotmov IN (SELECT DISTINCT cmotmov
                                 FROM detmovseguro
                                WHERE sseguro = s.sseguro
                                  AND nmovimi = NVL(pnmovimi, 1))) OR
               (d.cmotmov = 100 AND NVL(pnmovimi, 1) = 1) OR
               (d.cmotmov = 0 AND NVL(pnmovimi, 1) <> 1 AND
               EXISTS((SELECT 1
                          FROM detmovseguro
                         WHERE psseguro = psseguro
                           AND nmovimi = NVL(pnmovimi, 1)
                           AND cmotmov NOT IN (SELECT cmotmov
                                                 FROM doc_docurequerida dd
                                                WHERE dd.sproduc = s.sproduc
                                                 -- AND dd.cactivi = s.cactivi
                                                  )))) OR
               (d.cmotmov = 0 AND NVL(pnmovimi, 1) <> 1 AND
               0 = (SELECT COUNT(*)
                        FROM detmovseguro
                       WHERE sseguro = psseguro
                         AND nmovimi = NVL(pnmovimi, 1))));
      --
      vctipdoc    doc_docurequerida.ctipdoc%TYPE;
      sw_insertar BOOLEAN := TRUE;
      v_result    NUMBER(1);
      vt_docreq   t_iax_docrequerida := t_iax_docrequerida();
      vob_docreq  ob_iax_docrequerida;
      --
      v_error     axis_literales.slitera%TYPE;
      v_pasexec   NUMBER(3) := 1;
      v_object    VARCHAR2(200) := 'PAC_DOCREQUERIDA.f_get_docurequerida';
      v_param     VARCHAR2(200) := ' psseguro: ' || psseguro ||
                                   ' - pnmovimi: ' || pnmovimi;
      --
      e_object_error EXCEPTION;
      --
   BEGIN

      FOR reg IN c_docreq
      LOOP
         vob_docreq := ob_iax_docrequerida();
         vob_docreq.seqdocu := reg.seqdocu;
         vob_docreq.cdocume := reg.cdocume;
         vob_docreq.sproduc := reg.sproduc;
         vob_docreq.cactivi := reg.cactivi;
         vob_docreq.norden := reg.norden;
         vctipdoc := reg.ctipdoc;
         v_error := pac_docrequerida.f_docreq_col(psseguro,
                                                  pnmovimi,
                                                  reg.sproduc,
                                                  reg.cactivi,
                                                  reg.cdocume,
                                                  vctipdoc);
         vob_docreq.ctipdoc := vctipdoc;
         vob_docreq.cclase := reg.cclase;
         vob_docreq.sseguro := psseguro;
         vob_docreq.nmovimi := pnmovimi;
         vob_docreq.nriesgo := reg.nriesgo;
         vob_docreq.ninqaval := reg.ninqaval;
         vob_docreq.tdescrip := reg.tdescrip;
         vob_docreq.tfilename := reg.tfilename;
         vob_docreq.adjuntado := reg.adjuntado;
         vob_docreq.crecibido := reg.crecibido;
         vob_docreq.frecibido := reg.frecibido;

         IF vob_docreq.tfilename IS NOT NULL
         THEN
            vob_docreq.adjuntado := 1;
         ELSE
            vob_docreq.adjuntado := reg.adjuntado;
         END IF;
         vob_docreq.sperson := reg.sperson;
         vob_docreq.ctipben := reg.ctipben;

         IF vob_docreq.ctipdoc = 1
         THEN
            vob_docreq.cobliga := 0;

            sw_insertar := TRUE;
         ELSIF vob_docreq.ctipdoc = 2
         THEN
            vob_docreq.cobliga := 1;

            sw_insertar := TRUE;
         ELSE
            v_error := pac_albsgt.f_tval_docureq(reg.tfuncio,
                                                 'POL',
                                                 reg.cactivi,
                                                 psseguro,
                                                 pnmovimi,
                                                 reg.nriesgo,
                                                 reg.sperson,
                                                 v_result);
            IF v_error <> 0
            THEN
               RAISE e_object_error;
            END IF;
            --
            IF v_result = 1
            THEN
               IF vob_docreq.ctipdoc = 3
               THEN
                  vob_docreq.cobliga := 0;
               ELSIF vob_docreq.ctipdoc = 4
               THEN
                  vob_docreq.cobliga := 1;
               END IF;

               sw_insertar := TRUE;
            ELSE
               sw_insertar := FALSE;

               IF reg.seqdocu IS NOT NULL
               THEN
                  DELETE FROM docrequerida
                   WHERE seqdocu = reg.seqdocu
                     AND sseguro = psseguro
                     AND nmovimi = pnmovimi;
               END IF;
            END IF;
         END IF;
         --
         IF sw_insertar
         THEN
            vt_docreq.extend;
            vt_docreq(vt_docreq.last) := vob_docreq;
         END IF;
      END LOOP;

      RETURN vt_docreq;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param);

         RETURN vt_docreq;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           psqcode   => SQLCODE,
                                           psqerrm   => SQLERRM);

         RETURN vt_docreq;
   END f_get_docurequerida;


   FUNCTION f_grabardocrequeridapol(
      pseqdocu IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pninqaval IN NUMBER,
      pcdocume IN NUMBER,
      pctipdoc IN NUMBER,
      pcclase IN NUMBER,
      pnorden IN NUMBER,
      ptdescrip IN VARCHAR2,
      ptfilename IN VARCHAR2,
      padjuntado IN NUMBER,
      pcrecibido IN NUMBER,
      pciddocgedox IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500)
         := 'pseqdocu: ' || pseqdocu || ' - psproduc: ' || psproduc || ' - psseguro: '
            || psseguro || ' - pcactivi: ' || pcactivi || ' - pnmovimi: ' || pnmovimi
            || '- pnriesgo: ' || pnriesgo || ' - pninqaval: ' || pninqaval;
      v_object       VARCHAR2(200) := 'PAC_DOCREQUERIDA.f_grabardocrequeridapol';
      nerror         NUMBER;
      v_seqdocu      estdocrequerida.seqdocu%TYPE;
      v_doc_null     NUMBER;
      v_tfilename    estdocrequerida.tfilename%TYPE;
   BEGIN
     IF pseqdocu IS NOT NULL THEN
         v_seqdocu := pseqdocu;
     ELSE
         SELECT seqdocu.NEXTVAL
           INTO v_seqdocu
           FROM DUAL;
     END IF;

     IF pcclase = 1
     THEN
       --
       SELECT COUNT(*)
         INTO v_doc_null
         FROM docrequerida
        WHERE sseguro = psseguro
          AND nmovimi = pnmovimi
          AND cdocume = pcdocume
          AND sproduc = psproduc
          --AND cactivi = pcactivi
          AND ctipdoc = pctipdoc
          AND cclase = pcclase
          AND tfilename IS NULL;

       IF v_doc_null > 0 THEN
          DELETE docrequerida
           WHERE sseguro = psseguro
             AND nmovimi = pnmovimi
             AND cdocume = pcdocume
             AND sproduc = psproduc
             --AND cactivi = pcactivi
             AND ctipdoc = pctipdoc
             AND cclase = pcclase
             AND tfilename IS NULL;
       END IF;

       BEGIN
          INSERT INTO docrequerida
                      (seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc, cclase,
                       sseguro, nmovimi, tfilename, tdescrip, adjuntado,
                       iddocgedox)
               VALUES (v_seqdocu, pcdocume, psproduc, pcactivi, pnorden, pctipdoc, pcclase,
                       psseguro, pnmovimi, ptfilename, ptdescrip, NVL(padjuntado, 1),
                       pciddocgedox);
          --
          nerror := pac_md_docrequerida.f_subir_docsgedox (psseguro, pnmovimi, mensajes);
          --
          IF nerror > 0 THEN
             RETURN 1;
          END IF;
       EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN

             IF padjuntado = 0 THEN
                DELETE docrequerida
                 WHERE seqdocu = pseqdocu
                   AND sseguro = psseguro
                   AND nmovimi = pnmovimi;
             ELSE
                UPDATE docrequerida
                   SET adjuntado = padjuntado,
                       tfilename = ptfilename,
                       tdescrip = ptdescrip
                 WHERE seqdocu = pseqdocu
                   AND sseguro = psseguro
                   AND nmovimi = pnmovimi;
                --
                IF pcrecibido IS NOT NULL
                THEN
                  IF pcrecibido = 0
                  THEN
                    UPDATE docrequerida
                       SET crecibido = pcrecibido
                     WHERE seqdocu = pseqdocu
                       AND sseguro = psseguro
                       AND nmovimi = pnmovimi;
                  ELSE
                    UPDATE docrequerida
                      SET crecibido = pcrecibido,
                          frecibido = f_sysdate()
                    WHERE seqdocu = pseqdocu
                      AND sseguro = psseguro
                      AND nmovimi = pnmovimi;
                  END IF;
                END IF;
                --
                nerror := pac_md_docrequerida.f_subir_docsgedox (psseguro, pnmovimi, mensajes);
                --
                IF nerror > 0 THEN
                   RETURN 1;
                END IF;
             END IF;
       END;
       --
     END IF;
     --
     COMMIT;
     --
     RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 1;
   END f_grabardocrequeridapol;

END pac_docrequerida;
/
