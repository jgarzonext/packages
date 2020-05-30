--------------------------------------------------------
--  DDL for Package Body PAC_INSPECCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_INSPECCION" AS
/******************************************************************************
 NOMBRE: pac_INSPECCION
   PROPÓSITO:  Funciones para la inspeccion

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------pac_md_inspeccion.f_act_seguros
   1.0        05/04/2013   XPL              1. Creación del package.
   2.0        05/06/2013   JDS              2. 0025221: LCOL_T031-LCOL - Fase 3 - Desarrollo Inspección de Riesgo
   3.0        10/12/2013   JDS              3. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
   4.0        12/12/2013   JDS              4. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
******************************************************************************/
   FUNCTION f_insert_orden_insp(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psorden OUT NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := ' ptablas :' || ptablas || ',pcempres:' || pcempres || ',psseguro:' || psseguro
            || ',pnmovimi:' || pnmovimi || ',pnriesgo:' || pnriesgo;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.F_INSERT_ORDEN_INSP';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      vsproduc       NUMBER;
      vctiporiesgo   NUMBER;
      vcobjase       NUMBER;
      vcclase        NUMBER;
      vcmotmov       NUMBER;
      vctipmat       NUMBER;
      vmatric        VARCHAR2(12);
      vmotor         VARCHAR2(100);
      vcchasis       VARCHAR2(100);
      vnbastid       VARCHAR2(20);
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT sproduc, cobjase
           INTO vsproduc, vcobjase
           FROM estseguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT cmotmov
              INTO vcmotmov
              FROM estdetmovseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcmotmov := 100;   --alta poliza
         END;

         IF vcobjase = 5 THEN
            SELECT ctipmat, cmatric, codmotor, cchasis, nbastid
              INTO vctipmat, vmatric, vmotor, vcchasis, vnbastid
              FROM estautriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;
         END IF;
      ELSE
         SELECT sproduc, cobjase
           INTO vsproduc, vcobjase
           FROM seguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT cmotmov
              INTO vcmotmov
              FROM detmovseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcmotmov := 100;   --alta poliza
         END;

         IF vcobjase = 5 THEN
            SELECT ctipmat, cmatric, codmotor, cchasis, nbastid
              INTO vctipmat, vmatric, vmotor, vcchasis, vnbastid
              FROM autriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;
         END IF;
      END IF;

      IF vcobjase = 5 THEN
         vctiporiesgo := 3;   --vehiculo
      ELSIF vcobjase = 2 THEN
         vctiporiesgo := 2;   --domicilio
      END IF;

      IF vcmotmov = 100 THEN
         vcclase := 1;   --Asegurabilidad de póliza nueva
      ELSIF vcmotmov = 420 THEN   --cambio de vehiculo
         vcclase := 4;   -- Cambio vehículo
      ELSIF vcmotmov = 422 THEN   --Modificación datos vehículo
         vcclase := 2;   -- Modificación datos vehículo
      ELSIF vcmotmov = 424 THEN   --Inclusión accesorios
         vcclase := 3;   -- Inclusión accesorios
      ELSE
         vcclase := 2;   -- Modificación datos vehículo
      END IF;

      IF vmatric IS NOT NULL THEN
         BEGIN
            SELECT sorden
              INTO vsorden
              FROM ir_ordenes
             WHERE cmatric LIKE vmatric
               AND cestado NOT IN(5, 6)
               AND vcmotmov = 100;   --solo cogemos la orden existente si es alta poliza

            vnumerr := -1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT seq_ir_ordenes_sorden.NEXTVAL
                 INTO vsorden
                 FROM DUAL;

               INSERT INTO ir_ordenes
                           (cempres, sorden, fsolicitud, ctiporiesgo, cestado, cclase,
                            sproduc, ctipmat, cmatric, codmotor, cchasis, nbastid)
                    VALUES (pcempres, vsorden, f_sysdate, vctiporiesgo, 1, vcclase,
                            vsproduc, vctipmat, vmatric, vmotor, vcchasis, vnbastid);   --Estado 1 solicitado
         END;
      ELSE
         SELECT seq_ir_ordenes_sorden.NEXTVAL
           INTO vsorden
           FROM DUAL;

         INSERT INTO ir_ordenes
                     (cempres, sorden, fsolicitud, ctiporiesgo, cestado, cclase, sproduc,
                      ctipmat, cmatric, codmotor, cchasis, nbastid)
              VALUES (pcempres, vsorden, f_sysdate, vctiporiesgo, 1, vcclase, vsproduc,
                      vctipmat, vmatric, vmotor, vcchasis, vnbastid);   --Estado 1 solicitado
      END IF;

      IF ptablas = 'EST' THEN
         BEGIN
            INSERT INTO estriesgos_ir
                        (sseguro, nriesgo, nmovimi, cinspreq, cresultr, tperscontacto,
                         ttelcontacto, tmailcontacto, crolcontacto)
                 VALUES (psseguro, pnriesgo, pnmovimi, 1, 4, NULL,
                         NULL, NULL, NULL);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE estriesgos_ir
                  SET cinspreq = 1,
                      cresultr = 4
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = pnmovimi;
         END;

         BEGIN
            INSERT INTO estriesgos_ir_ordenes
                        (sseguro, nriesgo, nmovimi, cempres, sorden, cnueva)
                 VALUES (psseguro, pnriesgo, pnmovimi, pcempres, vsorden, 1);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      ELSE
         BEGIN
            INSERT INTO riesgos_ir
                        (sseguro, nriesgo, nmovimi, cinspreq, cresultr, tperscontacto,
                         ttelcontacto, tmailcontacto, crolcontacto)
                 VALUES (psseguro, pnriesgo, pnmovimi, 1, 4, NULL,
                         NULL, NULL, NULL);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE riesgos_ir
                  SET cinspreq = 1,
                      cresultr = 4
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = pnmovimi;
         END;

         BEGIN
            INSERT INTO riesgos_ir_ordenes
                        (sseguro, nriesgo, nmovimi, cempres, sorden, cnueva)
                 VALUES (psseguro, pnriesgo, pnmovimi, pcempres, vsorden, 1);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      END IF;

      psorden := vsorden;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1, 'F_INSERT_ORDEN_INSP', SQLERRM);
         RETURN 1;
   END f_insert_orden_insp;

   FUNCTION f_set_nordenext(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pnordenext IN VARCHAR2)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := ' ptablas :' || ptablas || ',pcempres:' || pcempres || ',pnordenext:'
            || pnordenext || ',psorden:' || psorden;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.F_SET_NORDENEXT';
      vcont          NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcont
        FROM ir_ordenes
       WHERE cempres = pcempres
         AND nordenext = pnordenext;

      IF vcont = 0 THEN
         UPDATE ir_ordenes
            SET nordenext = pnordenext
          WHERE cempres = pcempres
            AND sorden = psorden;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1, 'F_SET_NORDENEXT', SQLERRM);
         RETURN 1;
   END f_set_nordenext;

   FUNCTION f_act_orden(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN OUT NUMBER,
      pnordenext IN VARCHAR2,
      pcestado IN NUMBER,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      pcmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := ' ptablas :' || ptablas || ',pcempres:' || pcempres || ',psorden:' || psorden
            || ',pnordenext:' || pnordenext || ',pcestado:' || pcestado || ',pctipmat:'
            || pctipmat || ',pcmatric:' || pcmatric || ',pcmotor:' || pcmotor || ',pcchasis:'
            || pcchasis || ',pnbastid:' || pnbastid;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.F_ACT_ORDEN';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vcestado       NUMBER;
      vcmatric       VARCHAR2(100);
      vcodmotor      VARCHAR2(100);
      vcchasis       VARCHAR2(100);
      vnbastid       VARCHAR2(100);
   BEGIN
      vcmatric := pcmatric;
      vcodmotor := pcmotor;
      vcchasis := pcchasis;
      vnbastid := pnbastid;

      IF pnordenext IS NOT NULL THEN
         BEGIN
            SELECT sorden, cestado
              INTO psorden, vcestado
              FROM ir_ordenes
             WHERE cempres = pcempres
               AND nordenext = pnordenext;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9905268;   --'Orden de inspección inexistente'.
         END;
      END IF;

      IF vcestado IS NOT NULL
         AND vcestado IN(5, 6) THEN
         RETURN 9905269;   --La orden de inspección no está activa'.
      END IF;

      IF psorden IS NOT NULL
         AND pcestado IS NOT NULL THEN
         --ini BUG 29315#c161241 , JDS 12/12/2013
         vnumerr := pac_validaciones.f_valida_campo(pcempres, 'CODMOTOR', vcodmotor);

         IF vnumerr <> 0 THEN
            vcodmotor := NULL;
            vnumerr := 0;
         END IF;

         vnumerr := pac_validaciones.f_valida_campo(pcempres, 'CMATRIC', vcmatric);

         IF vnumerr <> 0 THEN
            vcmatric := NULL;
            vnumerr := 0;
         END IF;

         vnumerr := pac_validaciones.f_valida_campo(pcempres, 'CCHASIS', vcchasis);

         IF vnumerr <> 0 THEN
            vcchasis := NULL;
            vnumerr := 0;
         END IF;

         vnumerr := pac_validaciones.f_valida_campo(pcempres, 'NBASTID', vnbastid);

         IF vnumerr <> 0 THEN
            vnbastid := NULL;
            vnumerr := 0;
         END IF;

         --fi BUG 29315#c161241 , JDS 12/12/2013
         UPDATE ir_ordenes
            SET cestado = NVL(pcestado, cestado),
                ctipmat = NVL(pctipmat, ctipmat),
                cmatric = NVL(vcmatric, cmatric),
                codmotor = NVL(vcodmotor, codmotor),
                cchasis = NVL(vcchasis, cchasis),
                nbastid = NVL(vnbastid, nbastid)
          WHERE sorden = psorden
            AND cempres = pcempres;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1, 'F_ACT_ORDEN', SQLERRM);
         RETURN 1;
   END f_act_orden;

   FUNCTION f_set_inspeccion(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN OUT NUMBER,
      pfinspeccion IN DATE,
      pcestado IN NUMBER,
      pcresultado IN NUMBER,
      pcreinspeccion IN NUMBER,
      phllegada IN VARCHAR2,
      phsalida IN VARCHAR2,
      pccentroinsp IN NUMBER,
      pcinspdomi IN NUMBER,
      pcpista IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ' ptablas :' || ptablas || ',pcempres:' || pcempres || ',psorden:' || psorden
            || ',pninspeccion:' || pninspeccion || ',pcestado:' || pcestado || ',pcresultado:'
            || pcresultado || ',pcreinspeccion:' || pcreinspeccion || ',phllegada:'
            || phllegada || ',phsalida:' || phsalida || ',pccentroinsp:' || pccentroinsp
            || ',pcinspdomi:' || pcinspdomi || ',pcpista:' || pcpista;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.f_set_inspeccion';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      vsproduc       NUMBER;
      vctiporiesgo   NUMBER;
      vcobjase       NUMBER;
      vcclase        NUMBER;
      vcmotmov       NUMBER;
      vctipmat       NUMBER;
      vmatric        VARCHAR2(12);
      vmotor         VARCHAR2(100);
      vcchasis       VARCHAR2(100);
      vnbastid       VARCHAR2(20);
      vcmaticlre_out NUMBER;
      vcmatric       VARCHAR2(200);
      vcodmotor      VARCHAR2(500);
   BEGIN
      IF pninspeccion IS NULL THEN
         SELECT NVL(MAX(ninspeccion), 0) + 1
           INTO pninspeccion
           FROM ir_inspecciones
          WHERE cempres = pcempres
            AND sorden = psorden;

         INSERT INTO ir_inspecciones
                     (cempres, sorden, ninspeccion, finspeccion, cestado,
                      cresultado, creinspeccion, hllegada, hsalida,
                      ccentroinsp, cinspdomi, cpista)
              VALUES (pcempres, psorden, pninspeccion, pfinspeccion, pcestado,
                      DECODE(pcresultado, 0, 2, 1, 1), pcreinspeccion, phllegada, phsalida,
                      pccentroinsp, pcinspdomi, pcpista);
      ELSE
         UPDATE ir_inspecciones
            SET finspeccion = pfinspeccion,
                cestado = pcestado,
                cresultado = DECODE(pcresultado, 0, 2, 1, 1),
                creinspeccion = pcreinspeccion,
                hllegada = phllegada,
                hsalida = phsalida,
                ccentroinsp = pccentroinsp,
                cinspdomi = pcinspdomi,
                cpista = pcpista
          WHERE cempres = pcempres
            AND sorden = psorden
            AND ninspeccion = pninspeccion;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1, 'F_SET_INSPECCION', SQLERRM);
         RETURN 1;
   END f_set_inspeccion;

   FUNCTION f_set_inspeccion_dveh(
      ptablas IN VARCHAR2,
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
      pesactualizacion IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ' ptablas :' || ptablas || ',pcempres:' || pcempres || ',psorden:' || psorden
            || ',pninspeccion:' || pninspeccion || ',pcversion:' || pcversion
            || ',pcpaisorigen:' || pcpaisorigen || ',pnpma:' || pnpma || ',pccilindraje:'
            || pccilindraje || ',panyo:' || panyo || ',pnplazas:' || pnplazas
            || ',pcservicio:' || pcservicio || ',pcblindado:' || pcblindado || ',pccampero:'
            || pccampero || ',pcgama:' || pcgama || ',pcmatcabina:' || pcmatcabina
            || ',pivehinue:' || pivehinue || ',pcuso:' || pcuso || ',pccolor:' || pccolor
            || ',pnkilometraje:' || pnkilometraje || ',pctipmotor:' || pctipmotor
            || ',pntara:' || pntara || ',pcpintura:' || pcpintura || ',pctransporte:'
            || pctransporte || ',pctipcarroceria:' || pctipcarroceria || ',pesactualizacion:'
            || pesactualizacion;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.f_set_inspeccion_dveh';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      vsproduc       NUMBER;
      vctiporiesgo   NUMBER;
      vcobjase       NUMBER;
      vcclase        NUMBER;
      vcmotmov       NUMBER;
      vctipmat       NUMBER;
      vmatric        VARCHAR2(12);
      vmotor         VARCHAR2(100);
      vcchasis       VARCHAR2(100);
      vnbastid       VARCHAR2(20);
      vnplazas       NUMBER := pnplazas;
      vcont          NUMBER;
      vnuevo         NUMBER;
   BEGIN
      /*  IF pesactualizacion = 1 THEN
           UPDATE ir_inspecciones_dveh
              SET cversion = pcversion,
                  cpaisorigen = pcpaisorigen,
                  npma = pnpma,
                  ccilindraje = pccilindraje,
                  anyo = panyo,
                  nplazas = pnplazas,
                  cservicio = pcservicio,
                  cblindado = pcblindado,
                  ccampero = pccampero,
                  cgama = pcgama,
                  cmatcabina = pcmatcabina,
                  ivehinue = pivehinue,
                  cuso = pcuso,
                  ccolor = pccolor,
                  nkilometraje = pnkilometraje,
                  ctipmotor = pctipmotor,
                  ntara = pntara,
                  cpintura = pcpintura,
                  ccaja = pccaja,
                  ctransporte = pctransporte,
                  ctipcarroceria = pctipcarroceria
            WHERE cempres = pcempres
              AND sorden = psorden
              AND ninspeccion = pninspeccion;
        ELSE
           INSERT INTO ir_inspecciones_dveh
                       (cempres, sorden, ninspeccion, cversion, cpaisorigen, npma,
                        ccilindraje, anyo, nplazas, cservicio, cblindado, ccampero,
                        cgama, cmatcabina, ivehinue, cuso, ccolor, nkilometraje, ctipmotor,
                        ntara, cpintura, ccaja, ctransporte, ctipcarroceria                                                                 )
                VALUES (pcempres, psorden, pninspeccion, pcversion, pcpaisorigen, pnpma,
                        pccilindraje, panyo, pnplazas, pcservicio, pcblindado, pccampero,
                        pcgama, pcmatcabina, pivehinue, pcuso, pccolor, pnkilometraje, NULL,
                        pntara, pcpintura, pccaja, pctransporte, pctipcarroceria                                                               );
        END IF;
        */
      IF pnplazas < 0 THEN
         vnplazas := NULL;   --todo, la interficie nos llega como -4352523424
      END IF;

      p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', vpasexec,
                  'f_set_inspeccion_dveh ; pcversion= ', pcversion);

      SELECT COUNT(1)
        INTO vcont
        FROM aut_versiones
       WHERE cversion = pcversion;

      IF (vcont = 0) THEN
         BEGIN
            SELECT ar.cversion
              INTO vcversion
              FROM riesgos_ir_ordenes ri, autriesgos ar
             WHERE ri.sorden = psorden
               AND ri.sseguro = ar.sseguro
               AND ri.nriesgo = ar.nriesgo
               AND ri.nmovimi = ar.nmovimi
               AND ri.nmovimi = (SELECT MAX(nmovimi)
                                   FROM movseguro
                                  WHERE sseguro = ar.sseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcversion := pcversion;
         END;
      ELSE
         vcversion := pcversion;

         BEGIN
            SELECT vcomercial
              INTO vnuevo
              FROM aut_versiones_anyo
             WHERE cversion = pcversion
               AND anyo = (SELECT MAX(anyo)
                             FROM aut_versiones_anyo
                            WHERE cversion = pcversion);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

      BEGIN
         INSERT INTO ir_inspecciones_dveh
                     (cempres, sorden, ninspeccion, cversion, cpaisorigen, npma,
                      ccilindraje, anyo, nplazas, cservicio, cblindado, ccampero,
                      cgama, cmatcabina, ivehinue, cuso, ccolor,
                      nkilometraje, ctipmotor, ntara, cpintura, ccaja, ctransporte,
                      ctipcarroceria                                                                  /* ,
                                     clase, codmotor, chasis, nbastid, ctipmat, cmatric, ctipveh*/)
              VALUES (pcempres, psorden, pninspeccion, vcversion, pcpaisorigen, pnpma,
                      pccilindraje, panyo, vnplazas, pcservicio, pcblindado, pccampero,
                      pcgama, pcmatcabina, NVL(vnuevo, pivehinue), pcuso, pccolor,
                      pnkilometraje, NULL, pntara, pcpintura, pccaja, pctransporte,
                      pctipcarroceria                                                               /*,
                                      pclase, pcodmotor, pchasis, pnbastid, pctipmat, pcmatric, pctipveh*/);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            IF pesactualizacion = 1 THEN
               BEGIN
                  UPDATE ir_inspecciones_dveh
                     SET cversion = vcversion,
                         cpaisorigen = pcpaisorigen,
                         npma = pnpma,
                         ccilindraje = pccilindraje,
                         anyo = panyo,
                         nplazas = vnplazas,
                         cservicio = pcservicio,
                         cblindado = pcblindado,
                         ccampero = pccampero,
                         cgama = pcgama,
                         cmatcabina = pcmatcabina,
                         ivehinue = NVL(vnuevo, pivehinue),
                         cuso = pcuso,
                         ccolor = pccolor,
                         nkilometraje = pnkilometraje,
                         ctipmotor = pctipmotor,
                         ntara = pntara,
                         cpintura = pcpintura,
                         ccaja = pccaja,
                         ctransporte = pctransporte,
                         ctipcarroceria = pctipcarroceria
                   WHERE cempres = pcempres
                     AND sorden = psorden
                     AND ninspeccion = pninspeccion;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1,
                                 'f_set_inspeccion_dveh 0', SQLERRM);
               END;
            END IF;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1, 'f_set_inspeccion_dveh 1',
                        SQLERRM);
            NULL;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1, 'f_set_inspeccion_dveh', SQLERRM);
         RETURN 1;
   END f_set_inspeccion_dveh;

   FUNCTION f_set_inspeccion_acc(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcaccesorio IN NUMBER,
      pctipacc IN NUMBER,
      ptdesacc IN VARCHAR2,
      pivalacc IN NUMBER,
      pcasegurable IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ' ptablas :' || ptablas || ',pcempres:' || pcempres || ',psorden:' || psorden
            || ',pninspeccion:' || pninspeccion || ',PCACCESORIO:' || pcaccesorio
            || ',PCTIPACC:' || pctipacc || ',PTDESACC:' || ptdesacc || ',PIVALACC:'
            || pivalacc || ',PCASEGURABLE:' || pcasegurable;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.F_SET_INSPECCION_ACC';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      vsproduc       NUMBER;
      vctiporiesgo   NUMBER;
      vcobjase       NUMBER;
      vcclase        NUMBER;
      vcmotmov       NUMBER;
      vctipmat       NUMBER;
      vmatric        VARCHAR2(12);
      vmotor         VARCHAR2(100);
      vcchasis       VARCHAR2(100);
      vnbastid       VARCHAR2(20);
   BEGIN
      BEGIN
         INSERT INTO ir_inspecciones_acc
                     (cempres, sorden, ninspeccion, caccesorio, ctipacc, tdesacc,
                      ivalacc, casegurable, coriginal)
              VALUES (pcempres, psorden, pninspeccion, pcaccesorio, pctipacc, ptdesacc,
                      pivalacc, pcasegurable, 1);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE ir_inspecciones_acc
               SET ctipacc = pctipacc,
                   tdesacc = ptdesacc,
                   ivalacc = pivalacc,
                   casegurable = pcasegurable                             /*,
                                                coriginal = c1*/
             WHERE cempres = pcempres
               AND sorden = psorden
               AND ninspeccion = pninspeccion
               AND caccesorio = pcaccesorio;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1, 'f_set_inspeccion_acc', SQLERRM);
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
      piddocgedox IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ' pcempres:' || pcempres || ',psorden:' || psorden || ',pninspeccion:'
            || pninspeccion || ',pcdocume:' || pcdocume || ',pcgenerado:' || pcgenerado
            || ',pcobliga:' || pcobliga || ',pcadjuntado:' || pcadjuntado || ',piddocgedox:'
            || piddocgedox;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.F_SET_INSPECCION_DOC';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vndocume       NUMBER;
   BEGIN
      BEGIN
         SELECT NVL(MAX(ndocume), 0) + 1
           INTO vndocume
           FROM ir_inspecciones_doc
          WHERE cempres = pcempres
            AND sorden = psorden
            AND ninspeccion = pninspeccion;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vndocume := 1;
      END;

      BEGIN
         INSERT INTO ir_inspecciones_doc
                     (cempres, sorden, ninspeccion, ndocume, cdocume, cgenerado,
                      cobliga, cadjuntado, iddocgedox)
              VALUES (pcempres, psorden, pninspeccion, vndocume, pcdocume, pcgenerado,
                      pcobliga, pcadjuntado, piddocgedox);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1, 'F_SET_INSPECCION_DOC', SQLERRM);
         RETURN 1;
   END f_set_inspeccion_doc;

   FUNCTION f_act_accesorios(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ' pcempres:' || pcempres || ',psorden:' || psorden || ',pninspeccion:'
            || pninspeccion || ',PSSEGURO:' || psseguro || ',NRIESGO:' || pnriesgo
            || ',NMOVIMI:' || pnmovimi;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.f_act_accesorios';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vcresultado    NUMBER;
      pcpaisorigen   NUMBER;
      pnpma          NUMBER;
      pccilindraje   NUMBER;
      panyo          NUMBER;
      pnplazas       NUMBER;
      pcservicio     NUMBER;
      pcblindado     NUMBER;
      pccampero      NUMBER;
      pcgama         NUMBER;
      pcmatcabina    NUMBER;
      pivehinue      NUMBER;
      pcuso          NUMBER;
      pccolor        NUMBER;
      pnkilometraje  NUMBER;
      pctipmotor     NUMBER;
      pntara         NUMBER;
      pcpintura      NUMBER;
      pccaja         NUMBER;
      pctransporte   NUMBER;
      pctipcarroceria NUMBER;
      pcversion      VARCHAR2(11);
      vctipmat       NUMBER;
      vcmatric       VARCHAR2(100);
      vcodmotor      VARCHAR2(100);
      vcchasis       VARCHAR2(100);
      vnbastid       VARCHAR2(100);
      vsproduc       NUMBER;
   BEGIN
      vpasexec := 2;

      SELECT ctipmat, cmatric, codmotor, cchasis, nbastid
        INTO vctipmat, vcmatric, vcodmotor, vcchasis, vnbastid
        FROM ir_ordenes
       WHERE cempres = pcempres
         AND sorden = psorden;

      SELECT cresultado
        INTO vcresultado
        FROM ir_inspecciones
       WHERE cempres = pcempres
         AND sorden = psorden
         AND ninspeccion = pninspeccion;

      vpasexec := 3;

      BEGIN
         SELECT ar.cversion
           INTO vcversion
           FROM riesgos_ir_ordenes ri, autriesgos ar
          WHERE ri.sorden = psorden
            AND ri.sseguro = psseguro
            AND ri.nriesgo = pnriesgo
            AND ri.sseguro = ar.sseguro
            AND ri.nriesgo = ar.nriesgo
            AND ri.nmovimi = ar.nmovimi
            AND ri.nmovimi = (SELECT MAX(nmovimi)
                                FROM movseguro
                               WHERE sseguro = ar.sseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcversion := pcversion;
      END;

      BEGIN
         DELETE      autdetriesgos
               WHERE (sseguro, nriesgo, nmovimi) IN(
                        SELECT sseguro, nriesgo, nmovimi
                          FROM riesgos_ir_ordenes ri
                         WHERE ri.sorden = psorden
                           AND ri.nmovimi = (SELECT MAX(nmovimi)
                                               FROM movseguro
                                              WHERE sseguro = ri.sseguro))
                 AND sseguro = psseguro
                 AND nriesgo = pnriesgo;

         FOR i IN (SELECT caccesorio, ctipacc, tdesacc, ivalacc, casegurable, coriginal
                     FROM ir_inspecciones_acc
                    WHERE cempres = pcempres
                      AND sorden = psorden
                      AND ninspeccion = pninspeccion) LOOP
            IF i.casegurable = 1 THEN   --solo se traspasn si son asegurables
               BEGIN
                  INSERT INTO autdetriesgos
                              (sseguro, nriesgo, nmovimi, cversion, caccesorio,
                               ctipacc,
                               fini,
                               ivalacc, tdesacc, casegurable)
                       VALUES (psseguro, pnriesgo, pnmovimi, vcversion, i.caccesorio,
                               i.ctipacc,
                               TO_DATE(TO_CHAR(f_sysdate, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
                               i.ivalacc, i.tdesacc, i.casegurable);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     UPDATE autdetriesgos
                        SET caccesorio = i.caccesorio,
                            ctipacc = i.ctipacc,
                            ivalacc = i.ivalacc,
                            tdesacc = i.tdesacc,
                            casegurable = i.casegurable                              /*,
                                                          fini = to_char(f_sysdate,'DD/MM/YYYY')*/
                      WHERE sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND nmovimi = pnmovimi
                        AND cversion = pcversion
                        AND caccesorio = i.caccesorio
                        AND cversion = pcversion;
               END;
            END IF;
         END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION 11', vpasexec, 'F_ACT_SEGURO',
                        SQLERRM);
      END;

      vpasexec := 8;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', vpasexec, 'f_act_accesorios',
                     SQLERRM);
         RETURN 1;
   END f_act_accesorios;

   FUNCTION f_act_seguro(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ' pcempres:' || pcempres || ',psorden:' || psorden || ',pninspeccion:'
            || pninspeccion || ',PSSEGURO:' || psseguro || ',NRIESGO:' || pnriesgo
            || ',NMOVIMI:' || pnmovimi;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.F_ACT_SEGURO';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vcresultado    NUMBER;
      pcpaisorigen   NUMBER;
      pnpma          NUMBER;
      pccilindraje   NUMBER;
      panyo          NUMBER;
      pnplazas       NUMBER;
      pcservicio     NUMBER;
      pcblindado     NUMBER;
      pccampero      NUMBER;
      pcgama         NUMBER;
      pcmatcabina    NUMBER;
      pivehinue      NUMBER;
      pcuso          NUMBER;
      pccolor        NUMBER;
      pnkilometraje  NUMBER;
      pctipmotor     NUMBER;
      pntara         NUMBER;
      pcpintura      NUMBER;
      pccaja         NUMBER;
      pctransporte   NUMBER;
      pctipcarroceria NUMBER;
      vcomercial     NUMBER;
      pcversion      VARCHAR2(11);
      vctipmat       NUMBER;
      vcmatric       VARCHAR2(100);
      vcodmotor      VARCHAR2(100);
      vcchasis       VARCHAR2(100);
      vnbastid       VARCHAR2(100);
      vsproduc       NUMBER;
      vfinspeccion   DATE;
   BEGIN
      vpasexec := 2;

      SELECT ctipmat, cmatric, codmotor, cchasis, nbastid
        INTO vctipmat, vcmatric, vcodmotor, vcchasis, vnbastid
        FROM ir_ordenes
       WHERE cempres = pcempres
         AND sorden = psorden;

      SELECT cresultado, TRUNC(finspeccion)
        INTO vcresultado, vfinspeccion
        FROM ir_inspecciones
       WHERE cempres = pcempres
         AND sorden = psorden
         AND ninspeccion = pninspeccion;

      vpasexec := 3;

      BEGIN
         SELECT i.cpaisorigen, i.npma, i.ccilindraje, i.anyo, i.nplazas, i.cservicio,
                i.cblindado, i.ccampero, i.cgama, i.cmatcabina, i.ivehinue, i.cuso, i.ccolor,
                i.nkilometraje, i.ctipmotor, i.ntara, i.cpintura, i.ccaja, i.ctransporte,
                i.ctipcarroceria, i.cversion
           INTO pcpaisorigen, pnpma, pccilindraje, panyo, pnplazas, pcservicio,
                pcblindado, pccampero, pcgama, pcmatcabina, pivehinue, pcuso, pccolor,
                pnkilometraje, pctipmotor, pntara, pcpintura, pccaja, pctransporte,
                pctipcarroceria, pcversion
           FROM ir_inspecciones_dveh i
          WHERE cempres = pcempres
            AND sorden = psorden
            AND ninspeccion = pninspeccion;

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         vnumerr := pac_autos.f_controlduplicidad(psseguro, vcmatric, vnbastid, vcodmotor,
                                                  vsproduc, f_sysdate, vcchasis, 'POL');

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;

         --ini BUG 29315#c161241 , JDS 12/12/2013
         vnumerr := pac_validaciones.f_valida_campo(pcempres, 'CODMOTOR', vcodmotor);

         IF vnumerr <> 0 THEN
            vcodmotor := NULL;
            vnumerr := 0;
         END IF;

         vnumerr := pac_validaciones.f_valida_campo(pcempres, 'CMATRIC', vcmatric);

         IF vnumerr <> 0 THEN
            vcmatric := NULL;
            vnumerr := 0;
         END IF;

         vnumerr := pac_validaciones.f_valida_campo(pcempres, 'CCHASIS', vcchasis);

         IF vnumerr <> 0 THEN
            vcchasis := NULL;
            vnumerr := 0;
         END IF;

         vnumerr := pac_validaciones.f_valida_campo(pcempres, 'NBASTID', vnbastid);

         IF vnumerr <> 0 THEN
            vnbastid := NULL;
            vnumerr := 0;
         END IF;

         BEGIN
            --Si cambia la version, se consulta cual es el valor comercial para actualizarlo tb.
            SELECT vcomercial
              INTO vcomercial
              FROM aut_versiones_anyo
             WHERE anyo = panyo
               AND cversion = pcversion;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         --fi BUG 29315#c161241 , JDS 12/12/2013
         UPDATE autriesgos
            SET ctipmat = NVL(vctipmat, ctipmat),
                cmatric = NVL(vcmatric, cmatric),
                cuso = NVL(pcuso, cuso),
                npma = NVL(pnpma, npma),
                ntara = NVL(pntara, ntara),
                ccolor = NVL(pccolor, ccolor),
                nbastid = NVL(vnbastid, nbastid),
                nplazas = NVL(pnplazas, nplazas),
                cpaisorigen = NVL(pcpaisorigen, cpaisorigen),
                cchasis = NVL(vcchasis, cchasis),
                ivehicu = NVL(vcomercial, ivehicu),
                ivehinue = NVL(pivehinue, ivehinue),
                nkilometraje = NVL(pnkilometraje, nkilometraje),
                ccilindraje = NVL(pccilindraje, ccilindraje),
                --   ctipmotor = NVL(pctipmotor, ctipmotor),
                cpintura = NVL(pcpintura, cpintura),
                ccaja = NVL(pccaja, ccaja),
                ccampero = NVL(pccampero, ccampero),
                ctipcarroceria = NVL(pctipcarroceria, ctipcarroceria),
                cservicio = NVL(pcservicio, cservicio),
                ctransporte = NVL(pctransporte, ctransporte),
                codmotor = NVL(vcodmotor, codmotor),
                anyo = NVL(panyo, anyo),
                cversion = NVL(pcversion, cversion)
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;

         vpasexec := 4;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION 22', vpasexec, 'F_ACT_SEGURO',
                        SQLERRM);
      END;

      vpasexec := 5;

      UPDATE riesgos_ir
         SET cresultr = vcresultado
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi;

      vpasexec := 6;

      IF pnmovimi = 1 THEN
         pk_nueva_produccion.p_modificar_fefecto_seg(psseguro, vfinspeccion, pnmovimi, 'POL');

         UPDATE seguros
            SET fefecto = vfinspeccion
          WHERE sseguro = psseguro;
      ELSE
         pk_nueva_produccion.p_modificar_fefecto_seg(psseguro, vfinspeccion, pnmovimi, 'POL');
      END IF;

      --La inclusión/exclusion de las listas lo haremos cuando se rechaze la propuesta en gestión de propuestas retenidas.
      IF vcresultado = 2 THEN   --inspección rechazada, la ponemos en listas restringuidas el vehiculo
         vpasexec := 7;
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', vpasexec, 'AÑADIR',
                     'AÑADIMOS DE LISTAS RESTRINGIDAS');
         vnumerr :=
            pac_listarestringida.f_valida_listarestringida
                                                   (psseguro, pnmovimi, NULL, 2, NULL, NULL,
                                                    NULL   -- Bug 31411/175020 - 16/05/2014 - AMC
                                                        );
      ELSE
         vpasexec := 8;
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', vpasexec, 'UPDATE',
                     'QUITAMOS DE LISTAS RESTRINGIDAS');

         --Excluímos el vehiculo de listas restringidas ya que la inspección ha sido aprobada
         UPDATE lre_autos
            SET fexclus = f_sysdate
          WHERE cmatric = vcmatric
            /*  AND codmotor = vcodmotor
              AND cchasis = vcchasis
              AND nbastid = vnbastid */
            AND fexclus IS NULL;
      END IF;

--borramos los accesorios ya que solo valen los que lleguen por la inspeccion
      DELETE      autdetriesgos
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND nmovimi = pnmovimi;

      vpasexec := 8;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', vpasexec, 'F_ACT_SEGURO', SQLERRM);
         RETURN 1;
   END f_act_seguro;

   FUNCTION f_permiteinspeccion(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      ppermiteinspec OUT NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ' pcempres:' || pcempres || ',pcagente:' || pcagente || ',psseguro:' || psseguro
            || ',ptablas:' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.f_permiteinspeccion';
      vnnumide       VARCHAR2(25);
      vctipide       NUMBER;
      vsproduc       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcagente       NUMBER;
      vctipmat       NUMBER;
   BEGIN
      /*cogemos el documento del tomador*/
      IF ptablas = 'POL' THEN
         SELECT ctipmat
           INTO vctipmat
           FROM autriesgos
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(a.nmovimi)
                             FROM autriesgos a
                            WHERE a.sseguro = psseguro);

         IF (vctipmat IN(1, 13)) THEN
            --MATRICULA EXTRANJERA (TIPO 1,13) NO PASA INSPECCION.
            ppermiteinspec := 0;
            RETURN 0;
         END IF;

         SELECT ctipide, nnumide, sproduc, npoliza, ncertif, s.cagente
           INTO vctipide, vnnumide, vsproduc, vnpoliza, vncertif, vcagente
           FROM per_personas p, seguros s, tomadores t
          WHERE p.sperson = t.sperson
            AND t.nordtom = 1
            AND s.sseguro = t.sseguro
            AND s.sseguro = psseguro;
      ELSE
         SELECT ctipmat
           INTO vctipmat
           FROM estautriesgos
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(e.nmovimi)
                             FROM estautriesgos e
                            WHERE e.sseguro = psseguro);

         IF (vctipmat IN(1, 13)) THEN
            --MATRICULA EXTRANJERA (TIPO 1,13) NO PASA INSPECCION.
            ppermiteinspec := 0;
            RETURN 0;
         END IF;

         SELECT ctipide, nnumide, sproduc, npoliza, ncertif, s.cagente
           INTO vctipide, vnnumide, vsproduc, vnpoliza, vncertif, vcagente
           FROM estper_personas p, estseguros s, esttomadores t
          WHERE p.sperson = t.sperson
            AND t.nordtom = 1
            AND s.sseguro = t.sseguro
            AND s.sseguro = psseguro;
      END IF;

      BEGIN
         SELECT permiteinspec
           INTO ppermiteinspec
           FROM ir_permiteinspeccion
          WHERE sproduc = vsproduc
            AND cagente = 0
            AND ctipide = 0
            AND nnumide = '0'
            AND npoliza = 0
            AND ncertif = 0
            AND cempres = pcempres;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT permiteinspec
                 INTO ppermiteinspec
                 FROM ir_permiteinspeccion
                WHERE sproduc = vsproduc
                  AND cagente = vcagente
                  AND ctipide = 0
                  AND nnumide = '0'
                  AND npoliza = 0
                  AND ncertif = 0
                  AND cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT permiteinspec
                       INTO ppermiteinspec
                       FROM ir_permiteinspeccion
                      WHERE sproduc = vsproduc
                        AND cagente = 0
                        AND ctipide = vctipide
                        AND nnumide = vnnumide
                        AND npoliza = 0
                        AND ncertif = 0
                        AND cempres = pcempres;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT permiteinspec
                             INTO ppermiteinspec
                             FROM ir_permiteinspeccion
                            WHERE sproduc = vsproduc
                              AND cagente = 0
                              AND ctipide = 0
                              AND nnumide = '0'
                              AND npoliza = vnpoliza
                              AND ncertif = vncertif
                              AND cempres = pcempres;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              BEGIN
                                 SELECT permiteinspec
                                   INTO ppermiteinspec
                                   FROM ir_permiteinspeccion
                                  WHERE sproduc = 0
                                    AND cagente = 0
                                    AND ctipide = 0
                                    AND nnumide = '0'
                                    AND npoliza = 0
                                    AND ncertif = 0
                                    AND cempres = pcempres;
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    --Si no hay registro permitimos hacer inspección
                                    ppermiteinspec := 1;
                              END;
                        END;
                  END;
            END;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_INSPECCION', 1, 'F_PERMITEINSPECCION', SQLERRM);
         ppermiteinspec := 1;
         RETURN 1;
   END f_permiteinspeccion;

   FUNCTION f_retener_poliza(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER,
      pcreteni IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER IS
      /*********************************************************************************************
            F_RETENER_POLIZA_MV:
               INSERTARÁ EN LA TABLA motretencion EL MOTIVO DE RETENCIÓN Y CAMBIARÁ EL ESTADO
              DE LA POLIZA.
            13/11/2003 YIL.
      *********************************************************************************************/
      n_nmotret      NUMBER;
      vpasexec       NUMBER(10);
      v_existe       NUMBER;
      vparampsu      NUMBER;
      vsproduc       NUMBER;
      vccontrol      NUMBER;
      vcempres       NUMBER;
      vcnivel        NUMBER;
      vnvalinf       NUMBER;
      vnvalsup       NUMBER;
      vcidioma       NUMBER;
      vautmanual     VARCHAR2(50);
      vestabloquea   VARCHAR2(50);
      vordenbloquea  NUMBER;
      vautoriprev    VARCHAR2(50);
      vcnivelu       NUMBER;
      vnocurre       NUMBER;
      vcreteni       NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         vpasexec := 1;

         SELECT sproduc, cempres, cidioma
           INTO vsproduc, vcempres, vcidioma
           FROM estseguros
          WHERE sseguro = psseguro;

         vparampsu := pac_parametros.f_parproducto_n(vsproduc, 'PSU');

         IF NVL(vparampsu, 0) != 0 THEN
            UPDATE estseguros
               SET creteni = pcreteni
             WHERE sseguro = psseguro;
         ---final
         END IF;
      ELSE
         vpasexec := 11;
         vpasexec := 1;

         SELECT sproduc, cempres, cidioma
           INTO vsproduc, vcempres, vcidioma
           FROM seguros
          WHERE sseguro = psseguro;

         vparampsu := pac_parametros.f_parproducto_n(vsproduc, 'PSU');

         IF NVL(vparampsu, 0) != 0 THEN
            -- actualizamos seguros a retenido por pdt.inspeccion
            UPDATE seguros
               SET creteni = pcreteni
             WHERE sseguro = psseguro;
         ---fiii
         END IF;
      -- BUG18011:DRA:18/03/2011:Fi
      END IF;

      RETURN 0;
   END f_retener_poliza;
END pac_inspeccion;

/

  GRANT EXECUTE ON "AXIS"."PAC_INSPECCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INSPECCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INSPECCION" TO "PROGRAMADORESCSI";
