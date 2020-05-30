CREATE OR REPLACE PACKAGE BODY pac_md_docrequerida AS
   /******************************************************************************
      NOMBRE:       PAC_MD_DOCREQUERIDA
      PROPÓSITO: Funciones relacionadas con la documentación requerida

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        10/05/2011   JMP      1. Creación del package.
      2.0        30/05/2012   MDS      2. 0022267: LCOL_P001 - PER - Documentaci?n obligatoria subir a Gedox y si es persona o p?liza
      3.0        01/08/2012   MDS      3. 0023078: LCOL_P001 - PER - Documentaci?n obligatoria subir a Gedox y si es persona o póliza. Parametrización.
      4.0        22/11/2012   MDS      4. 0024657: MDP_T001-Pruebas de Suplementos
      5.0        26/07/2013   RCL      5. 0027304: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Rentas Vitalicias
      6.0        14/10/2013   JSV      6. 0027923: LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0
      7.0        04/11/2013   RCL      7. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
      8.0        24/12/2013   JDS      8. 0029487: LCOL_T031-LCOL_T010-LCOL - Revision incidencias qtracker Fase3A (I)
      9.0        30/04/2019   ECP      9. IAXIS-3634  Gestor Documental (Documentos internos y externos)
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
         F_GET_DIRECTORIO
      Obtiene el directorio donde se subirán los ficheros.
      param in pparam                : código de parámetro
      param out ppath                : directorio
      param in out t_iax_mensajes    : mensajes de error
      return                         : 0 todo correcto
                                       1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_directorio(
      pparam IN VARCHAR2,
      ppath OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500) := 'pparam: ' || pparam;
      v_object       VARCHAR2(200) := 'PAC_MD_DOCREQUERIDA.f_get_directorio';
   BEGIN
      v_error := pac_docrequerida.f_get_directorio(pparam, ppath);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_directorio;

   /*************************************************************************
         F_SUBIR_DOCSGEDOX
      Realiza la subida de los documentos requeridos al GEDOX.
      param in psseguro              : número secuencial de seguro
      param in pnmovimi              : número de movimiento
      param in out t_iax_mensajes    : mensajes de error
      return                         : 0 todo correcto
                                       1 ha habido un error
   *************************************************************************/
   FUNCTION f_subir_docsgedox(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500) := 'psseguro: ' || psseguro || ' - pnmovimi: ' || pnmovimi;
      v_object       VARCHAR2(200) := 'PAC_MD_DOCREQUERIDA.f_subir_docsgedox';

      -- BUG 18351 - 21/09/2011 - RSC - Añadimos "IDDOCGEDOX"
      CURSOR c_docum IS
         SELECT   cclase, seqdocu, sseguro, nmovimi, tfilename, tdescrip, iddocgedox,
-- Ini Bug 22267 - MDS - 30/05/2012
                                                                                     cdocume,
                  sproduc, cactivi
-- fin Bug 22267 - MDS - 30/05/2012
         FROM     docrequerida
            WHERE sseguro = psseguro
              AND nmovimi = pnmovimi
         UNION
         SELECT   cclase, seqdocu, sseguro, nmovimi, tfilename, tdescrip, iddocgedox,
-- Ini Bug 22267 - MDS - 30/05/2012
                                                                                     cdocume,
                  sproduc, cactivi
-- fin Bug 22267 - MDS - 30/05/2012
         FROM     docrequerida_riesgo
            WHERE sseguro = psseguro
              AND nmovimi = pnmovimi
         UNION
         SELECT   cclase, seqdocu, sseguro, nmovimi, tfilename, tdescrip, iddocgedox,
-- Ini Bug 22267 - MDS - 30/05/2012
                                                                                     cdocume,
                  sproduc, cactivi
-- fin Bug 22267 - MDS - 30/05/2012
         FROM     docrequerida_inqaval
            WHERE sseguro = psseguro
              AND nmovimi = pnmovimi
         UNION
         SELECT   cclase, seqdocu, sseguro, nmovimi, tfilename, tdescrip, iddocgedox, cdocume,
                  sproduc, cactivi
             FROM docrequerida_benespseg
            WHERE sseguro = psseguro
              AND nmovimi = pnmovimi
         ORDER BY 3;

      v_idfich       docrequerida.tfilename%TYPE;
      v_count        NUMBER;   -- Bug 22267 - MDS - 30/05/2012
      v_ctipdest     NUMBER;   -- Bug 22267 - MDS - 30/05/2012
   BEGIN
      FOR reg IN c_docum LOOP
         v_pasexec := 2;
         v_idfich := reg.tfilename;
         v_pasexec := 3;

         IF v_idfich IS NOT NULL THEN
            -- Ini Bug 22267 - MDS - 30/05/2012
            v_pasexec := 4;

            -- mirar si hay documentación requerida para tipo persona
            SELECT COUNT(1)
              INTO v_count
              FROM doc_docurequerida d
             WHERE d.cdocume = reg.cdocume
               AND d.sproduc = reg.sproduc
               AND d.cactivi = reg.cactivi
               AND d.cclase = reg.cclase
               AND d.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM detmovseguro
                                          WHERE sseguro = reg.sseguro
                                            AND nmovimi = reg.nmovimi
                                UNION
                                SELECT cmotmov
                                  FROM movseguro
                                 WHERE sseguro = reg.sseguro
                                   AND nmovimi = reg.nmovimi)
               AND d.norden = (SELECT MAX(norden)
                                 FROM doc_docurequerida d2
                                WHERE d2.cdocume = reg.cdocume
                                  AND d2.sproduc = reg.sproduc
                                  AND d2.cactivi = reg.cactivi
                                  AND d2.cclase = reg.cclase
                                  AND d2.cmotmov = d.cmotmov)
               AND d.ctipdest = 2;

            IF v_count > 0 THEN
               -- al menos hay un documento requerido para persona --> tipo destino : persona
               v_ctipdest := 2;
            ELSE
               -- no hay documentación requerida para persona --> tipo destino : póliza
               v_ctipdest := 1;
            END IF;

            --Inici Bug 27304 - RCL - 26/07/2013 - Nomes es puja a GEDOX si hi ha nom de fitxer.
            IF reg.tfilename IS NOT NULL THEN
               -- Fin Bug 22267 - MDS - 30/05/2012
               -- BUG 28263/155705 - RCL - 04/11/2013 - Desarrollo modificaciones de iAxis para BPM
               IF reg.iddocgedox IS NOT NULL THEN
                  -- Fin Bug 22267 - MDS - 30/05/2012
                  v_error :=
                     pac_md_gedox.f_set_docummovseg(reg.sseguro, reg.nmovimi,
                                                    f_user,
                                                    reg.tfilename, reg.iddocgedox,
                                                    reg.tdescrip, 8, 0, mensajes,
                                                    v_ctipdest   -- Bug 22267 - MDS - 30/05/2012
                                                              );
                  v_idfich := reg.iddocgedox;
               ELSE
                  v_error :=
                     pac_md_gedox.f_set_docummovseggedox
                                                    (reg.sseguro, reg.nmovimi,
                                                     f_user,
                                                     reg.tfilename, v_idfich, reg.tdescrip, 8,
                                                     0, mensajes,
                                                     v_ctipdest   -- Bug 22267 - MDS - 30/05/2012
                                                               );
               END IF;

               v_pasexec := 5;

               IF reg.cclase = 1 THEN
                  UPDATE docrequerida
                     SET iddocgedox = v_idfich
                   WHERE seqdocu = reg.seqdocu;
               ELSIF reg.cclase = 2 THEN
                  UPDATE docrequerida_riesgo
                     SET iddocgedox = v_idfich
                   WHERE seqdocu = reg.seqdocu;
               ELSIF reg.cclase IN(3, 4) THEN
                  UPDATE docrequerida_inqaval
                     SET iddocgedox = v_idfich
                   WHERE seqdocu = reg.seqdocu;
               ELSIF reg.cclase = 5 THEN
                  UPDATE docrequerida_benespseg
                     SET iddocgedox = v_idfich
                   WHERE seqdocu = reg.seqdocu;
               END IF;

               -- Bug 23078 - MDS - 01/08/2012 : puesto el commit para que baje a la bbdd los update
               COMMIT;
            END IF;
         --Fi Bug 27304 - RCL - 26/07/2013 - Nomes es puja a GEDOX si hi ha nom de fitxer.
         END IF;

         IF v_error <> 0 THEN
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_subir_docsgedox;

   --INI 18351: LCOL003 - Documentación requerida en contratación y suplementos
   /*************************************************************************
    F_AVISO_DOCREQ_PENDIENTE
      Para las empreses que deben retener la emisión porque hay documentación requerida
      obligatoaria, devuelve un mensaje de confirmación
      param in  psseguro                : sseguro
      param in  pnmovimi                : Numero de movimiento de la poliza
      param out t_iax_mensajes       : mensajes de error
      return                         : 0 No hay doc obligatoria
                                       1 Hay doc obligatoria pendiente
   ****************************************************************************/
   FUNCTION f_aviso_docreq_pendiente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500) := 'psseguro: ' || psseguro || ' - pnmovimi: ' || pnmovimi;
      v_object       VARCHAR2(200) := 'PAC_MD_DOCREQUERIDA.f_aviso_docreq_pendiente';
      vcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      vretorn        NUMBER := 0;
      vparempres     NUMBER := 0;
      vdummy         NUMBER;
      v_result       NUMBER;
      vtmsg          VARCHAR2(1000);   -- Bug 22267 - MDS - 26/06/2012
      vtitdoc        VARCHAR2(200);   -- Bug 22267 - MDS - 26/06/2012
      vctipdoc       doc_docurequerida.ctipdoc%TYPE;   -- Bug: 27923/155724 - JSV - 14/10/2013

-- Ini IAXIS-3634  -- ECP -- 30/04/2019
      CURSOR c_docrequerida IS
         SELECT d.cdocume, d.norden, d.cclase, d.ctipdoc, d.tfuncio, NULL nriesgo,
                d.cobligedox,   -- Bug 22267 - MDS - 30/05/2012
                             NULL sperson,   -- Bug 24657 - MDS - 22/11/2012
                                          NULL ctipben
           FROM doc_docurequerida d, estseguros s
          WHERE s.sseguro = psseguro
            AND s.sproduc = d.sproduc
            AND d.sproduc = psproduc
           -- AND d.cactivi = pcactivi
            AND d.cclase = 1   -- Póliza
            AND(d.cmotmov IN(SELECT DISTINCT cmotmov
                                        FROM estdetmovseguro
                                       WHERE sseguro = psseguro
                                         AND nmovimi = pnmovimi)
                OR(d.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM detmovseguro
                                          WHERE sseguro = s.ssegpol
                                            AND nmovimi = pnmovimi))   -- En propuestas de suplemento
                OR(d.cmotmov = 100
                   AND pnmovimi = 1)   -- nueva produccion
                OR(d.cmotmov = 0
                   AND pnmovimi <> 1
                   AND EXISTS((SELECT 1
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi = pnmovimi
                                  AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                           --  AND dd.cactivi = pcactivi
                                             )))   -- Otros suplementos
                                                                         )
                OR(d.cmotmov = 0
                   AND pnmovimi <> 1
                   AND 0 = (SELECT COUNT(*)
                              FROM estdetmovseguro
                             WHERE sseguro = psseguro
                               AND nmovimi = pnmovimi)))
         UNION
         SELECT aux.cdocume, aux.norden, aux.cclase, aux.ctipdoc, aux.tfuncio, aux.nriesgo,
                aux.cobligedox,   -- Bug 22267 - MDS - 30/05/2012
                               NULL sperson,   -- Bug 24657 - MDS - 22/11/2012
                                            NULL ctipben
           FROM (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase, d.ctipdoc,
                        d.tfuncio, es.nriesgo, es.sperson, d.cmotmov, s.ssegpol,
                        d.cobligedox   -- Bug 22267 - MDS - 30/05/2012
                   FROM doc_docurequerida d, estseguros s, estriesgos es
                  WHERE s.sseguro = psseguro
                    AND s.sproduc = d.sproduc
                    AND es.sseguro = s.sseguro
                    AND d.sproduc = psproduc
                  --  AND d.cactivi = pcactivi
                    AND d.cclase = 2) aux   -- Riesgo
          WHERE (aux.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM estdetmovseguro
                                          WHERE sseguro = psseguro
                                            AND nriesgo = aux.nriesgo
                                            AND nmovimi = pnmovimi)   -- en suplementos
                 OR(aux.cmotmov IN(SELECT DISTINCT cmotmov
                                              FROM detmovseguro
                                             WHERE sseguro = aux.ssegpol
                                               AND nriesgo = aux.nriesgo
                                               AND nmovimi = pnmovimi))   -- En propuestas de suplemento
                 OR(aux.cmotmov = 100
                    AND pnmovimi = 1)   -- nueva producción
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM estdetmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                             --AND dd.cactivi = pcactivi
                                             ))))
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND 0 = (SELECT COUNT(*)
                               FROM estdetmovseguro
                              WHERE sseguro = psseguro
                                AND nmovimi = pnmovimi)))
         UNION
         SELECT aux.cdocume, aux.norden, aux.cclase, aux.ctipdoc, aux.tfuncio, aux.nriesgo,
                aux.cobligedox,   -- Bug 22267 - MDS - 30/05/2012
                               aux.sperson,   -- Bug 24657 - MDS - 22/11/2012
                                           NULL ctipben
           FROM (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase, d.ctipdoc,
                        d.tfuncio, es.nriesgo, es.sperson, d.cmotmov, s.ssegpol,
                        d.cobligedox   -- Bug 22267 - MDS - 30/05/2012
                   FROM doc_docurequerida d, estseguros s, estinquiaval es
                  WHERE s.sseguro = psseguro
                    AND s.sproduc = d.sproduc
                    AND es.sseguro = s.sseguro
                    AND d.sproduc = psproduc
                   -- AND d.cactivi = pcactivi
                    AND es.ctipfig = 1
                    AND d.cclase = 3) aux   -- Inquilino
          WHERE (aux.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM estdetmovseguro
                                          WHERE sseguro = psseguro
                                            AND nriesgo = aux.nriesgo
                                            AND nmovimi = pnmovimi)   -- en suplementos
                 OR(aux.cmotmov IN(SELECT DISTINCT cmotmov
                                              FROM detmovseguro
                                             WHERE sseguro = aux.ssegpol
                                               AND nriesgo = aux.nriesgo
                                               AND nmovimi = pnmovimi))   -- En propuestas de suplemento
                 OR(aux.cmotmov = 100
                    AND pnmovimi = 1)   -- nueva producciÃ³n
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM estdetmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                             --AND dd.cactivi = pcactivi
                                             ))))
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND 0 = (SELECT COUNT(*)
                               FROM estdetmovseguro
                              WHERE sseguro = psseguro
                                AND nmovimi = pnmovimi)))
         UNION
         SELECT aux.cdocume, aux.norden, aux.cclase, aux.ctipdoc, aux.tfuncio, aux.nriesgo,
                aux.cobligedox,   -- Bug 22267 - MDS - 30/05/2012
                               aux.sperson,   -- Bug 24657 - MDS - 22/11/2012
                                           NULL ctipben
           FROM (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase, d.ctipdoc,
                        d.tfuncio, es.nriesgo, es.sperson, d.cmotmov, s.ssegpol,
                        d.cobligedox   -- Bug 22267 - MDS - 30/05/2012
                   FROM doc_docurequerida d, estseguros s, estinquiaval es
                  WHERE s.sseguro = psseguro
                    AND s.sproduc = d.sproduc
                    AND es.sseguro = s.sseguro
                    AND d.sproduc = psproduc
                   -- AND d.cactivi = pcactivi
                    AND es.ctipfig = 2
                    AND d.cclase = 4) aux   -- Avalista
          WHERE (aux.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM estdetmovseguro
                                          WHERE sseguro = psseguro
                                            AND nriesgo = aux.nriesgo
                                            AND nmovimi = pnmovimi)   -- en suplementos
                 OR(aux.cmotmov IN(SELECT DISTINCT cmotmov
                                              FROM detmovseguro
                                             WHERE sseguro = aux.ssegpol
                                               AND nriesgo = aux.nriesgo
                                               AND nmovimi = pnmovimi))   -- En propuestas de suplemento
                 OR(aux.cmotmov = 100
                    AND pnmovimi = 1)   -- nueva producciÃ³n
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM estdetmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                             --AND dd.cactivi = pcactivi
                                             ))))
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND 0 = (SELECT COUNT(*)
                               FROM estdetmovseguro
                              WHERE sseguro = psseguro
                                AND nmovimi = pnmovimi)))
         UNION
         SELECT aux.cdocume, aux.norden, aux.cclase, aux.ctipdoc, aux.tfuncio, aux.nriesgo,
                aux.cobligedox,   -- Bug 22267 - MDS - 30/05/2012
                               aux.sperson,   -- Bug 24657 - MDS - 22/11/2012
                                           aux.ctipben ctipben
           FROM (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase, d.ctipdoc,
                        d.tfuncio, es.nriesgo, es.sperson, d.cmotmov, s.ssegpol, d.cobligedox,
                        es.ctipben   -- Bug 22267 - MDS - 30/05/2012
                   FROM doc_docurequerida d, estseguros s, estbenespseg es
                  WHERE s.sseguro = psseguro
                    AND s.sproduc = d.sproduc
                    AND es.sseguro = s.sseguro
                    AND d.sproduc = psproduc
                    --AND d.cactivi = pcactivi
                    --AND es.ctipfig = 2
                    AND d.cclase = 5) aux   -- Beneficiario
          WHERE (aux.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM estdetmovseguro
                                          WHERE sseguro = psseguro
                                            AND nriesgo = aux.nriesgo
                                            AND nmovimi = pnmovimi)   -- en suplementos
                 OR(aux.cmotmov IN(SELECT DISTINCT cmotmov
                                              FROM detmovseguro
                                             WHERE sseguro = aux.ssegpol
                                               AND nriesgo = aux.nriesgo
                                               AND nmovimi = pnmovimi))   -- En propuestas de suplemento
                 OR(aux.cmotmov = 100
                    AND pnmovimi = 1)   -- nueva producciÃ³n
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM estdetmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                             --AND dd.cactivi = pcactivi
                                             ))))
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND 0 = (SELECT COUNT(*)
                               FROM estdetmovseguro
                              WHERE sseguro = psseguro
                                AND nmovimi = pnmovimi)));
    -- Fin IAXIS-3634  -- ECP -- 30/04/2019
-------------------------------------------------------------------------
-- En este cursor se debería añadir la select a ESTINQUILINO_AVALISTA  --
-------------------------------------------------------------------------
   BEGIN
      -- Si es 0 no ha de fer res
      vparempres := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                      'PRODUCE_REQUERIDA'),
                        0);

      IF vparempres <> 0 THEN
         FOR reg IN c_docrequerida LOOP
            IF vretorn = 0 THEN
               -- Bug: 27923/155724 - JSV - 14/10/2013
               vctipdoc := reg.ctipdoc;
               v_error := pac_docrequerida.f_docreq_col(psseguro, pnmovimi, psproduc,
                                                        pcactivi, reg.cdocume, vctipdoc);

               IF reg.cclase = 1 THEN
                  vdummy := 0;

                  FOR regs2 IN (SELECT adjuntado, tfilename   -- Bug 22267 - MDS - 30/05/2012
                                  FROM estdocrequerida
                                 WHERE cdocume = reg.cdocume
                                   AND norden = reg.norden
                                   AND sseguro = psseguro) LOOP
                     vdummy := 1;

                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     IF regs2.adjuntado = 0 THEN
                        IF vctipdoc = 2
                           AND reg.cclase IN(1, 2) THEN
                           vretorn := 1;
                        ELSIF vctipdoc = 4
                              AND reg.cclase IN(1, 2) THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                                psseguro, pnmovimi,

                                                                -- Ini Bug 24657 - MDS - 22/11/2012
                                                                reg.nriesgo, reg.sperson,

                                                                -- Fin Bug 24657 - MDS - 22/11/2012
                                                                v_result);

                           IF v_result = 1 THEN
                              vretorn := 1;
                           END IF;
                        END IF;
                     -- Ini Bug 22267 - MDS - 30/05/2012
                     -- si está adjuntado, y es obligatorio, y es obligatorio subirlo a gedox, y no existe el fichero --> error
                     ELSIF regs2.adjuntado = 1 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2
                           AND reg.cobligedox = 1
                           AND regs2.tfilename IS NULL THEN
                           -- avisar del documento que no está subido a gedox
                           vtmsg :=
                              pac_iobj_mensajes.f_get_descmensaje
                                                                (9903863,
                                                                 pac_md_common.f_get_cxtidioma);

                           SELECT ttitdoc
                             INTO vtitdoc
                             FROM doc_desdocumento
                            WHERE cdocume = reg.cdocume
                              AND cidioma = pac_md_common.f_get_cxtidioma;

                           vtmsg := vtmsg || ' ' || vtitdoc;
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vtmsg);
                           -- marcar que hay documentos pendientes
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4 THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                                psseguro, pnmovimi,

                                                                -- Ini Bug 24657 - MDS - 22/11/2012
                                                                reg.nriesgo, reg.sperson,

                                                                -- Fin Bug 24657 - MDS - 22/11/2012
                                                                v_result);

                           IF v_result = 1
                              AND reg.cobligedox = 1
                              AND regs2.tfilename IS NULL THEN
                              -- avisar del documento que no está subido a gedox
                              vtmsg :=
                                 pac_iobj_mensajes.f_get_descmensaje
                                                                (9903863,
                                                                 pac_md_common.f_get_cxtidioma);

                              SELECT ttitdoc
                                INTO vtitdoc
                                FROM doc_desdocumento
                               WHERE cdocume = reg.cdocume
                                 AND cidioma = pac_md_common.f_get_cxtidioma;

                              vtmsg := vtmsg || ' ' || vtitdoc;
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vtmsg);
                              -- marcar que hay documentos pendientes
                              vretorn := 1;
                           END IF;
                        END IF;
                     -- Fin Bug 22267 - MDS - 30/05/2012
                     END IF;
                  END LOOP;

                  -- Bug: 27923/155724 - JSV - 14/10/2013
                  IF vdummy = 0 THEN
                     IF vctipdoc = 2
                        AND reg.cclase IN(1, 2) THEN
                        vretorn := 1;
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     ELSIF vctipdoc = 4
                           AND reg.cclase IN(1, 2) THEN
                        v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                             psseguro, pnmovimi,
                                                             -- Ini Bug 24657 - MDS - 22/11/2012
                                                             reg.nriesgo, reg.sperson,

                                                             -- Fin Bug 24657 - MDS - 22/11/2012
                                                             v_result);

                        IF v_result = 1 THEN
                           vretorn := 1;
                        END IF;
                     END IF;
                  END IF;
               ELSIF reg.cclase = 2 THEN
                  vdummy := 0;

                  FOR regs2 IN (SELECT adjuntado, tfilename   -- Bug 22267 - MDS - 30/05/2012
                                  FROM estdocrequerida_riesgo
                                 WHERE cdocume = reg.cdocume
                                   AND norden = reg.norden
                                   AND sseguro = psseguro
                                   AND nriesgo = reg.nriesgo) LOOP
                     vdummy := 1;

                     IF regs2.adjuntado = 0 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2
                           AND reg.cclase IN(1, 2) THEN
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4
                              AND reg.cclase IN(1, 2) THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                                psseguro, pnmovimi,

                                                                -- Ini Bug 24657 - MDS - 22/11/2012
                                                                reg.nriesgo, reg.sperson,

                                                                -- Fin Bug 24657 - MDS - 22/11/2012
                                                                v_result);

                           IF v_result = 1 THEN
                              vretorn := 1;
                           END IF;
                        END IF;
                     -- Ini Bug 22267 - MDS - 30/05/2012
                     -- si está adjuntado, y es obligatorio, y es obligatorio subirlo a gedox, y no existe el fichero --> error
                     ELSIF regs2.adjuntado = 1 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2
                           AND reg.cobligedox = 1
                           AND regs2.tfilename IS NULL THEN
                           -- avisar del documento que no está subido a gedox
                           vtmsg :=
                              pac_iobj_mensajes.f_get_descmensaje
                                                                (9903863,
                                                                 pac_md_common.f_get_cxtidioma);

                           SELECT ttitdoc
                             INTO vtitdoc
                             FROM doc_desdocumento
                            WHERE cdocume = reg.cdocume
                              AND cidioma = pac_md_common.f_get_cxtidioma;

                           vtmsg := vtmsg || ' ' || vtitdoc;
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vtmsg);
                           -- marcar que hay documentos pendientes
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4 THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                                psseguro, pnmovimi,

                                                                -- Ini Bug 24657 - MDS - 22/11/2012
                                                                reg.nriesgo, reg.sperson,

                                                                -- Fin Bug 24657 - MDS - 22/11/2012
                                                                v_result);

                           IF v_result = 1
                              AND reg.cobligedox = 1
                              AND regs2.tfilename IS NULL THEN
                              -- avisar del documento que no está subido a gedox
                              vtmsg :=
                                 pac_iobj_mensajes.f_get_descmensaje
                                                                (9903863,
                                                                 pac_md_common.f_get_cxtidioma);

                              SELECT ttitdoc
                                INTO vtitdoc
                                FROM doc_desdocumento
                               WHERE cdocume = reg.cdocume
                                 AND cidioma = pac_md_common.f_get_cxtidioma;

                              vtmsg := vtmsg || ' ' || vtitdoc;
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vtmsg);
                              -- marcar que hay documentos pendientes
                              vretorn := 1;
                           END IF;
                        END IF;
                     -- Fin Bug 22267 - MDS - 30/05/2012
                     END IF;
                  END LOOP;

                  IF vdummy = 0 THEN
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     IF vctipdoc = 2
                        AND reg.cclase IN(1, 2) THEN
                        vretorn := 1;
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     ELSIF vctipdoc = 4
                           AND reg.cclase IN(1, 2) THEN
                        v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                             psseguro, pnmovimi,
                                                             -- Ini Bug 24657 - MDS - 22/11/2012
                                                             reg.nriesgo, reg.sperson,

                                                             -- Fin Bug 24657 - MDS - 22/11/2012
                                                             v_result);

                        IF v_result = 1 THEN
                           vretorn := 1;
                        END IF;
                     END IF;
                  END IF;
               ELSIF reg.cclase IN(3, 4) THEN
                  vdummy := 0;

                  FOR regs2 IN (SELECT adjuntado, tfilename   -- Bug 22267 - MDS - 30/05/2012
                                  FROM estdocrequerida_inqaval
                                 WHERE cdocume = reg.cdocume
                                   AND norden = reg.norden
                                   AND sseguro = psseguro
                                   AND ninqaval = reg.nriesgo) LOOP
                     vdummy := 1;

                     IF regs2.adjuntado = 0 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2 THEN
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4 THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                                psseguro, pnmovimi,

                                                                -- Ini Bug 24657 - MDS - 22/11/2012
                                                                reg.nriesgo, reg.sperson,

                                                                -- Fin Bug 24657 - MDS - 22/11/2012
                                                                v_result);

                           IF v_result = 1 THEN
                              vretorn := 1;
                           END IF;
                        END IF;
                     -- Ini Bug 22267 - MDS - 30/05/2012
                     -- si está adjuntado, y es obligatorio, y es obligatorio subirlo a gedox, y no existe el fichero --> error
                     ELSIF regs2.adjuntado = 1 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2
                           AND reg.cobligedox = 1
                           AND regs2.tfilename IS NULL THEN
                           -- avisar del documento que no está subido a gedox
                           vtmsg :=
                              pac_iobj_mensajes.f_get_descmensaje
                                                                (9903863,
                                                                 pac_md_common.f_get_cxtidioma);

                           SELECT ttitdoc
                             INTO vtitdoc
                             FROM doc_desdocumento
                            WHERE cdocume = reg.cdocume
                              AND cidioma = pac_md_common.f_get_cxtidioma;

                           vtmsg := vtmsg || ' ' || vtitdoc;
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vtmsg);
                           -- marcar que hay documentos pendientes
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4 THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                                psseguro, pnmovimi,

                                                                -- Ini Bug 24657 - MDS - 22/11/2012
                                                                reg.nriesgo, reg.sperson,

                                                                -- Fin Bug 24657 - MDS - 22/11/2012
                                                                v_result);

                           IF v_result = 1
                              AND reg.cobligedox = 1
                              AND regs2.tfilename IS NULL THEN
                              -- avisar del documento que no está subido a gedox
                              vtmsg :=
                                 pac_iobj_mensajes.f_get_descmensaje
                                                                (9903863,
                                                                 pac_md_common.f_get_cxtidioma);

                              SELECT ttitdoc
                                INTO vtitdoc
                                FROM doc_desdocumento
                               WHERE cdocume = reg.cdocume
                                 AND cidioma = pac_md_common.f_get_cxtidioma;

                              vtmsg := vtmsg || ' ' || vtitdoc;
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vtmsg);
                              -- marcar que hay documentos pendientes
                              vretorn := 1;
                           END IF;
                        END IF;
                     -- Fin Bug 22267 - MDS - 30/05/2012
                     END IF;
                  END LOOP;

                  IF vdummy = 0 THEN
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     IF vctipdoc = 2 THEN
                        vretorn := 1;
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     ELSIF vctipdoc = 4 THEN
                        v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                             psseguro, pnmovimi,
                                                             -- Ini Bug 24657 - MDS - 22/11/2012
                                                             reg.nriesgo, reg.sperson,

                                                             -- Fin Bug 24657 - MDS - 22/11/2012
                                                             v_result);

                        IF v_result = 1 THEN
                           vretorn := 1;
                        END IF;
                     END IF;
                  END IF;
               ELSIF reg.cclase = 5 THEN
                  vdummy := 0;

                  FOR regs2 IN (SELECT adjuntado, tfilename
                                  FROM estdocrequerida_benespseg
                                 WHERE cdocume = reg.cdocume
                                   AND norden = reg.norden
                                   AND sseguro = psseguro
                                   AND nriesgo = reg.nriesgo) LOOP
                     vdummy := 1;

                     IF regs2.adjuntado = 0 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2 THEN
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4 THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                                psseguro, pnmovimi,
                                                                reg.nriesgo, reg.sperson,
                                                                v_result);

                           IF v_result = 1 THEN
                              vretorn := 1;
                           END IF;
                        END IF;
                     -- si está adjuntado, y es obligatorio, y es obligatorio subirlo a gedox, y no existe el fichero --> error
                     ELSIF regs2.adjuntado = 1 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2
                           AND reg.cobligedox = 1
                           AND regs2.tfilename IS NULL THEN
                           -- avisar del documento que no está subido a gedox
                           vtmsg :=
                              pac_iobj_mensajes.f_get_descmensaje
                                                                (9903863,
                                                                 pac_md_common.f_get_cxtidioma);

                           SELECT ttitdoc
                             INTO vtitdoc
                             FROM doc_desdocumento
                            WHERE cdocume = reg.cdocume
                              AND cidioma = pac_md_common.f_get_cxtidioma;

                           vtmsg := vtmsg || ' ' || vtitdoc;
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vtmsg);
                           -- marcar que hay documentos pendientes
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4 THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                                psseguro, pnmovimi,
                                                                reg.nriesgo, reg.sperson,
                                                                v_result);

                           IF v_result = 1
                              AND reg.cobligedox = 1
                              AND regs2.tfilename IS NULL THEN
                              -- avisar del documento que no está subido a gedox
                              vtmsg :=
                                 pac_iobj_mensajes.f_get_descmensaje
                                                                (9903863,
                                                                 pac_md_common.f_get_cxtidioma);

                              SELECT ttitdoc
                                INTO vtitdoc
                                FROM doc_desdocumento
                               WHERE cdocume = reg.cdocume
                                 AND cidioma = pac_md_common.f_get_cxtidioma;

                              vtmsg := vtmsg || ' ' || vtitdoc;
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vtmsg);
                              -- marcar que hay documentos pendientes
                              vretorn := 1;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  IF vdummy = 0 THEN
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     IF vctipdoc = 2 THEN
                        vretorn := 1;
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     ELSIF vctipdoc = 4 THEN
                        v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, 'EST', pcactivi,
                                                             psseguro, pnmovimi, reg.nriesgo,
                                                             reg.sperson, v_result);

                        IF v_result = 1 THEN
                           vretorn := 1;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN vretorn;
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
   END f_aviso_docreq_pendiente;


   FUNCTION f_docreq_pendiente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER IS
      pmsgs          t_iax_mensajes;
   BEGIN
      RETURN f_docreq_pendiente(psseguro, pnmovimi, psproduc, pcactivi, pmsgs);
   END f_docreq_pendiente;

--FIN 18351: LCOL003 - Documentación requerida en contratación y suplementos

   /*************************************************************************
    f_retencion
      Crear retención por falta de documentación
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
      num_err := pac_emision_mv.f_retener_poliza('EST', psseguro, 1, pnmovimi, pmotretencion,
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

   FUNCTION f_docreq_pendiente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500) := 'psseguro: ' || psseguro || ' - pnmovimi: ' || pnmovimi;
      v_object       VARCHAR2(200) := 'PAC_MD_DOCREQUERIDA.f_docreq_pendiente';
      vcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      vretorn        NUMBER := 0;
      vparempres     NUMBER := 0;
      vdummy         NUMBER;
      v_result       NUMBER;
      vctipdoc       doc_docurequerida.ctipdoc%TYPE;
-- IAXIS-3634 -- ECP -- 30/04/2019
      CURSOR c_docrequerida IS
         SELECT d.cdocume, d.norden, d.cclase, d.ctipdoc, d.tfuncio, NULL nriesgo,
                NULL sperson, NULL ctipben   -- Bug 24657 - MDS - 22/11/2012
           FROM doc_docurequerida d, seguros s
          WHERE s.sseguro = psseguro
            AND s.sproduc = d.sproduc
            AND d.sproduc = psproduc
           -- AND d.cactivi = pcactivi
            AND d.cclase = 1   -- Póliza
            AND(d.cmotmov IN(SELECT DISTINCT cmotmov
                                        FROM estdetmovseguro
                                       WHERE sseguro = psseguro
                                         AND nmovimi = pnmovimi)   -- en suplementos
                OR(d.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM detmovseguro
                                          WHERE sseguro = psseguro
                                            AND nmovimi = pnmovimi))   -- En propuestas de suplemento
                OR(d.cmotmov = 100
                   AND pnmovimi = 1)   -- nueva produccion
                OR(d.cmotmov = 0
                   AND pnmovimi <> 1
                   AND EXISTS((SELECT 1
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi = pnmovimi
                                  AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                            -- AND dd.cactivi = pcactivi
                                             )))   -- Otros suplementos
                                                                         )
                OR(d.cmotmov = 0
                   AND pnmovimi <> 1
                   AND EXISTS((SELECT 1
                                 FROM detmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi = pnmovimi
                                  AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                            -- AND dd.cactivi = pcactivi
                                             )))))
         UNION
         SELECT aux.cdocume, aux.norden, aux.cclase, aux.ctipdoc, aux.tfuncio, aux.nriesgo,
                NULL sperson, NULL ctipben   -- Bug 24657 - MDS - 22/11/2012
           FROM (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase, d.ctipdoc,
                        d.tfuncio, es.nriesgo, es.sperson, s.cagente, d.cmotmov
                   FROM doc_docurequerida d, seguros s, riesgos es
                  WHERE s.sseguro = psseguro
                    AND s.sproduc = d.sproduc
                    AND es.sseguro = s.sseguro
                    AND d.sproduc = psproduc
                    --AND d.cactivi = pcactivi
                    AND d.cclase = 2) aux   -- Riesgo
          WHERE (aux.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM estdetmovseguro
                                          WHERE sseguro = psseguro
                                            AND nriesgo = aux.nriesgo
                                            AND nmovimi = pnmovimi)   -- En suplementos
                 OR(aux.cmotmov IN(SELECT DISTINCT cmotmov
                                              FROM detmovseguro
                                             WHERE sseguro = psseguro
                                               AND nriesgo = aux.nriesgo
                                               AND nmovimi = pnmovimi))   -- en propuestas de suplemento
                 OR(aux.cmotmov = 100
                    AND pnmovimi = 1)   -- nueva producción
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM estdetmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                            -- AND dd.cactivi = pcactivi
                                             ))))
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM detmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                            -- AND dd.cactivi = pcactivi
                                             )))))
         UNION
         SELECT aux.cdocume, aux.norden, aux.cclase, aux.ctipdoc, aux.tfuncio, aux.nriesgo,
                aux.sperson, NULL ctipben   -- Bug 24657 - MDS - 22/11/2012
           FROM (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase, d.ctipdoc,
                        d.tfuncio, es.nriesgo, es.sperson, s.cagente, d.cmotmov
                   FROM doc_docurequerida d, seguros s, inquiaval es
                  WHERE s.sseguro = psseguro
                    AND s.sproduc = d.sproduc
                    AND es.sseguro = s.sseguro
                    AND d.sproduc = psproduc
                    --AND d.cactivi = pcactivi
                    AND es.ctipfig = 1
                    AND d.cclase = 3) aux   -- Inquilino
          WHERE (aux.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM estdetmovseguro
                                          WHERE sseguro = psseguro
                                            AND nriesgo = aux.nriesgo
                                            AND nmovimi = pnmovimi)   -- En suplementos
                 OR(aux.cmotmov IN(SELECT DISTINCT cmotmov
                                              FROM detmovseguro
                                             WHERE sseguro = psseguro
                                               AND nriesgo = aux.nriesgo
                                               AND nmovimi = pnmovimi))   -- en propuestas de suplemento
                 OR(aux.cmotmov = 100
                    AND pnmovimi = 1)   -- nueva producciÃ³n
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM estdetmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                            -- AND dd.cactivi = pcactivi
                                             ))))
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM detmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                             --AND dd.cactivi = pcactivi
                                             )))))
         UNION
         SELECT aux.cdocume, aux.norden, aux.cclase, aux.ctipdoc, aux.tfuncio, aux.nriesgo,
                aux.sperson, NULL ctipben   -- Bug 24657 - MDS - 22/11/2012
           FROM (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase, d.ctipdoc,
                        d.tfuncio, es.nriesgo, es.sperson, s.cagente, d.cmotmov
                   FROM doc_docurequerida d, seguros s, inquiaval es
                  WHERE s.sseguro = psseguro
                    AND s.sproduc = d.sproduc
                    AND es.sseguro = s.sseguro
                    AND d.sproduc = psproduc
                    --AND d.cactivi = pcactivi
                    AND es.ctipfig = 2
                    AND d.cclase = 4) aux   -- Avalista
          WHERE (aux.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM estdetmovseguro
                                          WHERE sseguro = psseguro
                                            AND nriesgo = aux.nriesgo
                                            AND nmovimi = pnmovimi)   -- En suplementos
                 OR(aux.cmotmov IN(SELECT DISTINCT cmotmov
                                              FROM detmovseguro
                                             WHERE sseguro = psseguro
                                               AND nriesgo = aux.nriesgo
                                               AND nmovimi = pnmovimi))   -- en propuestas de suplemento
                 OR(aux.cmotmov = 100
                    AND pnmovimi = 1)   -- nueva producciÃ³n
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM estdetmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                            -- AND dd.cactivi = pcactivi
                                             ))))
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM detmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                            -- AND dd.cactivi = pcactivi
                                             )))))
         UNION
         SELECT aux.cdocume, aux.norden, aux.cclase, aux.ctipdoc, aux.tfuncio, aux.nriesgo,
                aux.sperson, aux.ctipben
           FROM (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase, d.ctipdoc,
                        d.tfuncio, es.nriesgo, es.sperson, s.cagente, d.cmotmov, es.ctipben
                   FROM doc_docurequerida d, seguros s, benespseg es
                  WHERE s.sseguro = psseguro
                    AND s.sproduc = d.sproduc
                    AND es.sseguro = s.sseguro
                    AND d.sproduc = psproduc
                    --AND d.cactivi = pcactivi
                    --AND es.ctipfig = 1
                    AND d.cclase = 5) aux   -- Beneficiario
          WHERE (aux.cmotmov IN(SELECT DISTINCT cmotmov
                                           FROM estdetmovseguro
                                          WHERE sseguro = psseguro
                                            AND nriesgo = aux.nriesgo
                                            AND nmovimi = pnmovimi)   -- En suplementos
                 OR(aux.cmotmov IN(SELECT DISTINCT cmotmov
                                              FROM detmovseguro
                                             WHERE sseguro = psseguro
                                               AND nriesgo = aux.nriesgo
                                               AND nmovimi = pnmovimi))   -- en propuestas de suplemento
                 OR(aux.cmotmov = 100
                    AND pnmovimi = 1)   -- nueva producciÃ³n
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM estdetmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                             --AND dd.cactivi = pcactivi
                                             ))))
                 OR(aux.cmotmov = 0
                    AND pnmovimi <> 1
                    AND EXISTS((SELECT 1
                                  FROM detmovseguro
                                 WHERE sseguro = psseguro
                                   AND nmovimi = pnmovimi
                                   AND cmotmov NOT IN(
                                          SELECT cmotmov
                                            FROM doc_docurequerida dd
                                           WHERE dd.sproduc = psproduc
                                             --AND dd.cactivi = pcactivi
                                             )))));
                                             -- IAXIS-3634 -- ECP -- 30/04/2019
   BEGIN
      -- Si es 0 no ha de fer res
      vparempres := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                      'PRODUCE_REQUERIDA'),
                        0);

      IF vparempres <> 0 THEN
         FOR reg IN c_docrequerida LOOP
            IF vretorn = 0 THEN
               vctipdoc := reg.ctipdoc;
               v_error := pac_docrequerida.f_docreq_col(psseguro, pnmovimi, psproduc,
                                                        pcactivi, reg.cdocume, vctipdoc);

               IF reg.cclase = 1 THEN
                  vdummy := 0;

                  FOR regs2 IN (SELECT adjuntado
                                  FROM docrequerida
                                 WHERE cdocume = reg.cdocume
                                   AND norden = reg.norden
                                   --El último movimiento menor igual al parametro
                                   AND nmovimi = (SELECT MAX(nmovimi)
                                                    FROM docrequerida
                                                   WHERE cdocume = reg.cdocume
                                                     AND norden = reg.norden
                                                     AND sseguro = psseguro
                                                     AND nmovimi <= pnmovimi)
                                   AND sseguro = psseguro) LOOP
                     vdummy := 1;

                     IF regs2.adjuntado = 0 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2
                           AND reg.cclase IN(1, 2) THEN
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4
                              AND reg.cclase IN(1, 2) THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, NULL, pcactivi,
                                                                psseguro, pnmovimi,

                                                                -- Ini Bug 24657 - MDS - 22/11/2012
                                                                reg.nriesgo, reg.sperson,

                                                                -- Fin Bug 24657 - MDS - 22/11/2012
                                                                v_result);

                           IF v_result = 1 THEN
                              vretorn := 1;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  IF vdummy = 0 THEN
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     IF vctipdoc = 2
                        AND reg.cclase IN(1, 2) THEN
                        vretorn := 1;
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     ELSIF vctipdoc = 4
                           AND reg.cclase IN(1, 2) THEN
                        v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, NULL, pcactivi,
                                                             psseguro, pnmovimi,
                                                             -- Ini Bug 24657 - MDS - 22/11/2012
                                                             reg.nriesgo, reg.sperson,

                                                             -- Fin Bug 24657 - MDS - 22/11/2012
                                                             v_result);

                        IF v_result = 1 THEN
                           vretorn := 1;
                        END IF;
                     END IF;
                  END IF;
               ELSIF reg.cclase = 2 THEN
                  vdummy := 0;

                  FOR regs2 IN (SELECT adjuntado
                                  FROM docrequerida_riesgo
                                 WHERE cdocume = reg.cdocume
                                   AND norden = reg.norden
                                   AND sseguro = psseguro
                                   AND nmovimi = (SELECT MAX(nmovimi)
                                                    FROM docrequerida_riesgo
                                                   WHERE cdocume = reg.cdocume
                                                     AND norden = reg.norden
                                                     AND sseguro = psseguro
                                                     AND nriesgo = reg.nriesgo
                                                     AND nmovimi <= pnmovimi)
                                   AND nriesgo = reg.nriesgo) LOOP
                     vdummy := 1;

                     IF regs2.adjuntado = 0 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2
                           AND reg.cclase IN(1, 2) THEN
                           vretorn := 1;
                        ELSIF vctipdoc = 4
                              AND reg.cclase IN(1, 2) THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, NULL, pcactivi,
                                                                psseguro, pnmovimi,

                                                                -- Ini Bug 24657 - MDS - 22/11/2012
                                                                reg.nriesgo, reg.sperson,

                                                                -- Fin Bug 24657 - MDS - 22/11/2012
                                                                v_result);

                           IF v_result = 1 THEN
                              vretorn := 1;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  IF vdummy = 0 THEN
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     IF vctipdoc = 2
                        AND reg.cclase IN(1, 2) THEN
                        vretorn := 1;
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     ELSIF vctipdoc = 4
                           AND reg.cclase IN(1, 2) THEN
                        v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, NULL, pcactivi,
                                                             psseguro, pnmovimi,
                                                             -- Ini Bug 24657 - MDS - 22/11/2012
                                                             reg.nriesgo, reg.sperson,

                                                             -- Fin Bug 24657 - MDS - 22/11/2012
                                                             v_result);

                        IF v_result = 1 THEN
                           vretorn := 1;
                        END IF;
                     END IF;
                  END IF;
               ELSIF reg.cclase IN(3, 4) THEN
                  vdummy := 0;

                  FOR regs2 IN (SELECT adjuntado
                                  FROM docrequerida_inqaval
                                 WHERE cdocume = reg.cdocume
                                   AND norden = reg.norden
                                   AND sseguro = psseguro
                                   AND nmovimi = (SELECT MAX(nmovimi)
                                                    FROM docrequerida_inqaval
                                                   WHERE cdocume = reg.cdocume
                                                     AND norden = reg.norden
                                                     AND sseguro = psseguro
                                                     AND ninqaval = reg.nriesgo
                                                     AND nmovimi <= pnmovimi)
                                   AND ninqaval = reg.nriesgo) LOOP
                     vdummy := 1;

                     IF regs2.adjuntado = 0 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2 THEN
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4 THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, NULL, pcactivi,
                                                                psseguro, pnmovimi,

                                                                -- Ini Bug 24657 - MDS - 22/11/2012
                                                                reg.nriesgo, reg.sperson,

                                                                -- Fin Bug 24657 - MDS - 22/11/2012
                                                                v_result);

                           IF v_result = 1 THEN
                              vretorn := 1;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  IF vdummy = 0 THEN
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     IF vctipdoc = 2 THEN
                        vretorn := 1;
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     ELSIF vctipdoc = 4 THEN
                        v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, NULL, pcactivi,
                                                             psseguro, pnmovimi,
                                                             -- Ini Bug 24657 - MDS - 22/11/2012
                                                             reg.nriesgo, reg.sperson,

                                                             -- Fin Bug 24657 - MDS - 22/11/2012
                                                             v_result);

                        IF v_result = 1 THEN
                           vretorn := 1;
                        END IF;
                     END IF;
                  END IF;
               ELSIF reg.cclase = 5 THEN
                  vdummy := 0;

                  FOR regs2 IN (SELECT adjuntado
                                  FROM docrequerida_benespseg
                                 WHERE cdocume = reg.cdocume
                                   AND norden = reg.norden
                                   AND sseguro = psseguro
                                   AND nmovimi = (SELECT MAX(nmovimi)
                                                    FROM docrequerida_benespseg
                                                   WHERE cdocume = reg.cdocume
                                                     AND norden = reg.norden
                                                     AND sseguro = psseguro
                                                     AND nriesgo = reg.nriesgo
                                                     AND nmovimi <= pnmovimi)
                                   AND nriesgo = reg.nriesgo) LOOP
                     vdummy := 1;

                     IF regs2.adjuntado = 0 THEN
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        IF vctipdoc = 2 THEN
                           vretorn := 1;
                        -- Bug: 27923/155724 - JSV - 14/10/2013
                        ELSIF vctipdoc = 4 THEN
                           v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, NULL, pcactivi,
                                                                psseguro, pnmovimi,
                                                                reg.nriesgo, reg.sperson,
                                                                v_result);

                           IF v_result = 1 THEN
                              vretorn := 1;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  IF vdummy = 0 THEN
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     IF vctipdoc = 2 THEN
                        vretorn := 1;
                     -- Bug: 27923/155724 - JSV - 14/10/2013
                     ELSIF vctipdoc = 4 THEN
                        v_error := pac_albsgt.f_tval_docureq(reg.tfuncio, NULL, pcactivi,
                                                             psseguro, pnmovimi, reg.nriesgo,
                                                             reg.sperson, v_result);

                        IF v_result = 1 THEN
                           vretorn := 1;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN vretorn;
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
   END f_docreq_pendiente;

   FUNCTION f_get_docurequerida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN T_IAX_DOCREQUERIDA IS
      vpasexec    NUMBER := 1;
      vparam      VARCHAR2(2000) := 'psseguro=' || psseguro;
      vobject     VARCHAR2(2000) := 'PAC_MD_DOCREQUERIDA.f_get_docurequerida';
      vt_docreq   t_iax_docrequerida := t_iax_docrequerida();
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vt_docreq := pac_docrequerida.f_get_docurequerida(psseguro, pnmovimi, mensajes);

      RETURN vt_docreq;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         RETURN vt_docreq;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         RETURN vt_docreq;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

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
      mensajes IN OUT t_iax_mensajes,
      pciddocgedox IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(3) := 1;
      v_object       VARCHAR2(200) := 'PAC_MD_DOCREQUERIDA.f_grabardocrequeridapol';
      v_param        VARCHAR2(500)
         := 'pseqdocu: ' || pseqdocu || ' - psproduc: ' || psproduc || ' - psseguro: '
            || psseguro || ' - pcactivi: ' || pcactivi || ' - pnmovimi: ' || pnmovimi
            || '- pnriesgo: ' || pnriesgo || ' - pninqaval: ' || pninqaval ;
   BEGIN
      --
      v_error := pac_docrequerida.f_grabardocrequeridapol(pseqdocu, psproduc, psseguro, pcactivi,
                                                          pnmovimi, pnriesgo, pninqaval,
                                                          pcdocume, pctipdoc, pcclase, pnorden,
                                                          ptdescrip, ptfilename, padjuntado, pcrecibido, pciddocgedox, mensajes);
      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_grabardocrequeridapol;
END pac_md_docrequerida;
/
