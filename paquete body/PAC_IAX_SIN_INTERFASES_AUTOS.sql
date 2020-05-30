--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SIN_INTERFASES_AUTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SIN_INTERFASES_AUTOS" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_SIN_INTERFASES_AUTOS
   PROPÓSITO: Funciones para interfases en siniestros de autos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       08/04/2013   ASN             Creacion
******************************************************************************/
   FUNCTION f_ciudad(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramita_gestion.ntramit%TYPE,
      pnlocali IN sin_tramita_gestion.nlocali%TYPE)
      RETURN VARCHAR2 IS
      v_taller       sin_tramita_gestion.sprofes%TYPE;
      v_spersed      sin_tramita_gestion.spersed%TYPE;
      v_ciudad       VARCHAR2(5);
   BEGIN
      SELECT SUBSTR(LTRIM(TO_CHAR(cprovin, '99909')) || LTRIM(TO_CHAR(cpoblac, '009')), 1, 5)
        INTO v_ciudad
        FROM sin_tramita_localiza
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND nlocali = pnlocali;

      RETURN v_ciudad;
   END f_ciudad;

   FUNCTION f_l021(
      ciudad IN VARCHAR2,
      fechaconsultaincialradicacion IN DATE,
      fechaconsultafinalradicacion IN DATE,
      siniestrospendientesvlr OUT t_iax_interfase_l021,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Devuelve los siniestros pendientes de valoracion
      *************************************************************************/
      obj_l021       ob_iax_interfase_l021;
      v_cversion     autriesgos.cversion%TYPE;
      v_ind          NUMBER;
      v_ctipges      NUMBER := 200;   -- tipo gestion: mano de obra
      v_ctipgas      NUMBER := 30;   -- tipo gasto mano de obra
      v_pdte         NUMBER := 8;   -- subestado pendiente de valorar
      v_traza        NUMBER := 0;
      v_sgestio      sin_tramita_gestion.sgestio%TYPE;
      v_taller       sin_tramita_gestion.sprofes%TYPE;
      v_spersed      sin_tramita_gestion.spersed%TYPE;
      v_sseguro      sin_siniestro.sseguro%TYPE;
      v_sproces      procesoscab.sproces%TYPE;
      dummy          NUMBER;
      num_err        NUMBER;
   BEGIN
      siniestrospendientesvlr := t_iax_interfase_l021();

      FOR i IN (SELECT   g.nsinies, g.ntramit, g.sgestio, g.sprofes, g.spersed, s.sseguro,
                         s.nriesgo, s.fsinies, s.fnotifi
                    FROM sin_tramita_movgestion m, sin_tramita_gestion g, sin_siniestro s
                   WHERE m.sgestio = g.sgestio
                     AND m.nmovges = (SELECT MAX(nmovges)
                                        FROM sin_tramita_movgestion m1
                                       WHERE m1.sgestio = m.sgestio)
                     AND m.cestges = 0   -- pdte
                     AND m.csubges = v_pdte   -- pdte valoracion
                     AND f_ciudad(g.nsinies, g.ntramit, g.nlocali) = ciudad
                     AND g.nsinies = s.nsinies
                     AND s.fsinies BETWEEN fechaconsultaincialradicacion
                                       AND fechaconsultafinalradicacion
                ORDER BY g.sprofes, g.nsinies) LOOP
         BEGIN
            obj_l021 := ob_iax_interfase_l021();
            obj_l021.ciudad := ciudad;
            v_traza := 1;

            SELECT cchasis, ccilindraje, cmotor, ctipmat,
                   cmatric, nbastid, cversion, cuso
              INTO obj_l021.chasis, obj_l021.cilindraje, obj_l021.motor, obj_l021.tipoplaca,
                   obj_l021.placa, obj_l021.vin, v_cversion, obj_l021.servicio
              FROM autriesgos a
             WHERE sseguro = i.sseguro
               AND nriesgo = i.nriesgo
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM autriesgos a1
                               WHERE a1.sseguro = a.sseguro
                                 AND a1.nriesgo = a.nriesgo);

            v_traza := 2;

            SELECT cmarca, SUBSTR(cversion, 4, 2), ctipveh
              INTO obj_l021.marca, obj_l021.tipo, obj_l021.clase
              FROM aut_versiones
             WHERE cversion = v_cversion;

            v_traza := 3;

            SELECT nanyo
              INTO obj_l021.modelo
              FROM sin_tramita_detvehiculo
             WHERE nsinies = i.nsinies
               AND ntramit = i.ntramit;

            v_traza := 4;

            SELECT DECODE(pp.ctipide,
                          33, 'E',
                          34, 'T',
                          35, 'R',
                          36, 'C',
                          37, DECODE(pp.ctipper, 1, 'I', 'N'),
                          38, 'NP',
                          40, 'P',
                          '*') tipide,
                   pp.nnumide
              INTO obj_l021.tipodocumento,
                   obj_l021.numerodocumento
              FROM sin_prof_profesionales pr, per_personas pp
             WHERE pr.sperson = pp.sperson
               AND pr.sprofes = i.sprofes;

            IF obj_l021.tipodocumento = '*' THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                                    'Siniestro=' || i.nsinies
                                                    || 'Tipo de documento no clasificado');
            END IF;

            v_traza := 5;

            SELECT tusunom
              INTO obj_l021.analista
              FROM usuarios u, sin_codtramitador ct, sin_tramita_movimiento mt
             WHERE u.cusuari = ct.cusuari
               AND ct.ctramitad = mt.ctramitad
               AND mt.nsinies = i.nsinies
               AND mt.ntramit = i.ntramit
               AND mt.nmovtra = (SELECT MAX(nmovtra)
                                   FROM sin_tramita_movimiento mt1
                                  WHERE mt1.nsinies = mt.nsinies
                                    AND mt1.ntramit = mt.ntramit);

            obj_l021.numerosiniestro := i.nsinies;
            obj_l021.fechaocurrencia := i.fsinies;
            obj_l021.fecharadicacion := i.fnotifi;
            v_traza := 6;

            SELECT sproduc
              INTO obj_l021.producto
              FROM seguros
             WHERE sseguro = i.sseguro;

            v_traza := 7;

            SELECT g.sgestio, g.sprofes, g.spersed
              INTO v_sgestio, v_taller, v_spersed
              FROM sin_tramita_gestion g, sin_tramita_movgestion m
             WHERE m.sgestio = g.sgestio
               AND g.nsinies = i.nsinies
               AND g.ntramit = i.ntramit
               AND g.ctipges = v_ctipges
               AND m.nmovges = (SELECT MAX(nmovges)
                                  FROM sin_tramita_movgestion m1
                                 WHERE m1.sgestio = m.sgestio)
               AND m.cestges = 0;

            IF v_spersed IS NULL THEN   -- Si no hay sede es la razon social del profesional
               obj_l021.sede := '1';
            ELSE
               v_traza := 8;

               BEGIN
                  SELECT ccodigo
                    INTO obj_l021.sede
                    FROM sin_interfase_sede
                   WHERE corigen = 'TALLERES'
                     AND sprofes = v_taller
                     AND sperson = v_spersed;
               EXCEPTION
                  WHEN OTHERS THEN
                     obj_l021.sede := '**';
               END;
            END IF;

            BEGIN
               v_traza := 11;

               SELECT DECODE(cgarant, 759, 3, 760, 1, 761, 2, NULL)
                 INTO obj_l021.garantiaafectada
                 FROM sin_tramita_reserva r
                WHERE nsinies = i.nsinies
                  AND ntramit = i.ntramit
                  AND ctipres = 3
                  AND ctipgas = v_ctipgas
                  AND nmovres = (SELECT MAX(nmovres)
                                   FROM sin_tramita_reserva r1
                                  WHERE r1.nsinies = r.nsinies
                                    AND r1.ntramit = r.ntramit
                                    AND r1.ctipres = r.ctipres
                                    AND r1.ctipgas = r.ctipgas);

               v_traza := 12;

               SELECT SUM(itotal)
                 INTO obj_l021.valorautorizadomanoobra
                 FROM sin_tramita_detgestion
                WHERE sgestio = v_sgestio;
            EXCEPTION
               WHEN OTHERS THEN
                  v_traza := 13;

                  SELECT DECODE(cgarant, 759, 3, 760, 1, 761, 2, NULL), ireserva
                    INTO obj_l021.garantiaafectada, obj_l021.valorautorizadomanoobra
                    FROM sin_tramita_reserva r
                   WHERE nsinies = i.nsinies
                     AND ntramit = 0   -- buscamos la reserva inicial
                     AND ctipres = 3
                     AND ctipgas = v_ctipgas
                     AND nmovres = (SELECT MAX(nmovres)
                                      FROM sin_tramita_reserva r1
                                     WHERE r1.nsinies = r.nsinies
                                       AND r1.ntramit = r.ntramit
                                       AND r1.ctipres = r.ctipres
                                       AND r1.ctipgas = r.ctipgas);
            END;

            v_traza := 14;
            siniestrospendientesvlr.EXTEND;
            v_ind := siniestrospendientesvlr.LAST;
            siniestrospendientesvlr(v_ind) := obj_l021;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_iax_sin_interfases_autos.F_L021', v_traza,
                           'Sin=' || i.nsinies || ' tram=' || i.ntramit || ' ges='
                           || i.sgestio || 'Error loop',
                           SQLERRM);

               IF v_sproces IS NULL THEN
                  num_err := f_procesini(f_user, pac_md_common.f_get_cxtempresa,
                                         'INTERFASE L021',
                                         'Consulta siniestros pendientes de valoracion',
                                         v_sproces);
               END IF;

               SELECT sseguro
                 INTO v_sseguro
                 FROM sin_siniestro
                WHERE nsinies = i.nsinies;

               IF v_traza = 1 THEN
                  num_err := f_proceslin(v_sproces,
                                         'SIN:' || i.nsinies
                                         || '. No se pudieron recuperar los datos del vehículo',
                                         v_sseguro, dummy);
               ELSIF v_traza = 2 THEN
                  num_err := f_proceslin(v_sproces,
                                         'SIN:' || i.nsinies
                                         || '. No se pudo recuperar la versión del vehículo',
                                         v_sseguro, dummy);
               ELSIF v_traza = 3 THEN
                  num_err := f_proceslin(v_sproces,
                                         'SIN:' || i.nsinies
                                         || '. No se pudo recuperar el modelo del vehículo',
                                         v_sseguro, dummy);
               ELSIF v_traza = 5 THEN
                  num_err := f_proceslin(v_sproces,
                                         'SIN:' || i.nsinies
                                         || '. No se pudo recuperar el analista',
                                         v_sseguro, dummy);
               ELSIF v_traza = 7 THEN
                  num_err := f_proceslin(v_sproces,
                                         'SIN:' || i.nsinies
                                         || '. No se encontró la gestion de mano de obra',
                                         v_sseguro, dummy);
               ELSIF v_traza IN(11, 13) THEN
                  num_err := f_proceslin(v_sproces,
                                         'SIN:' || i.nsinies
                                         || '. No se encontró el amparo siniestrado',
                                         v_sseguro, dummy);
               END IF;
         END;
      END LOOP;

      RETURN NVL(v_sproces, 0);
   END f_l021;

   FUNCTION f_l022(
      numerosiniestro IN VARCHAR2,
      tipoconsulta IN VARCHAR2,   -- 1:Todos los repuestos 2:Solo repuestos nuevos e imprevistos
      repuestos OUT t_iax_interfase_l022,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      obj_l022       ob_iax_interfase_l022;
      v_ind          NUMBER;
      v_pdte         NUMBER := 8;   -- subestado pendiente de valorar
      v_traza        NUMBER := 0;
      v_min_fecha    DATE;
      leer_otro      EXCEPTION;
/*************************************************************************
   Devuelve los repuestos pendientes de valoracion de un siniestro dado
*************************************************************************/
   BEGIN
      repuestos := t_iax_interfase_l022();

      FOR i IN (SELECT g.sgestio, g.sconven, dg.sservic, dg.ncantid, dg.nvalser, dg.falta
                  FROM sin_tramita_gestion g, sin_tramita_movgestion mg,
                       sin_tramita_detgestion dg
                 WHERE mg.sgestio = g.sgestio
                   AND mg.nmovges = (SELECT MAX(nmovges)
                                       FROM sin_tramita_movgestion mg1
                                      WHERE mg1.sgestio = mg.sgestio)
                   AND mg.csubges = v_pdte
                   AND dg.sgestio = g.sgestio
                   AND dg.nvalser = 0
                   AND g.nsinies = numerosiniestro) LOOP
         BEGIN
            obj_l022 := ob_iax_interfase_l022();
            v_traza := 1;

            SELECT MIN(falta)
              INTO v_min_fecha
              FROM sin_tramita_detgestion
             WHERE sgestio = i.sgestio;

            IF i.falta = v_min_fecha THEN
               obj_l022.imprevisto := 0;
            ELSE
               IF tipoconsulta = 2 THEN
                  RAISE leer_otro;
               END IF;

               obj_l022.imprevisto := 1;
            END IF;

            v_traza := 2;

            SELECT SUBSTR(tdescri, 1, 30)
              INTO obj_l022.descripcionespecifica
              FROM sin_dettarifas
             WHERE starifa = (SELECT starifa
                                FROM sin_prof_tarifa
                               WHERE sconven = i.sconven)
               AND sservic = i.sservic;

            v_traza := 3;

            SELECT codigo1, codigo2,
                   DECODE(codigo1,
                          1, 'PARTE DELANTERA',
                          2, 'PARTE MEDIA',
                          3, 'PARTE TRASERA',
                          4, 'MECANICA',
                          'FUERA CATALOGO')
              INTO obj_l022.codigo, obj_l022.codigoespecifico,
                   obj_l022.descripcion
              FROM sin_dettarifas_rel
             WHERE corigen IN('REPUESTOS', 'MANUAL')
               AND codaxis = i.sservic;

            obj_l022.unidades := i.ncantid;

            IF NVL(i.nvalser, 0) = 0 THEN
               obj_l022.estado := 1;   -- sin valorar
            ELSE
               obj_l022.estado := 2;   -- valorado
            END IF;

            repuestos.EXTEND;
            v_ind := repuestos.LAST;
            repuestos(v_ind) := obj_l022;
         EXCEPTION
            WHEN leer_otro THEN
               NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_iax_sin_interfases_autos.F_L022', v_traza,
                           'Error loop', SQLERRM);
         END;
      END LOOP;

      RETURN 0;
   END f_l022;

   FUNCTION f_l023(
      numerosiniestro IN VARCHAR2,
      codigo IN VARCHAR2,
      descripcion IN VARCHAR2,
      codigoespecifico IN VARCHAR2,
      descripcionespecifica IN VARCHAR2,
      referencia IN VARCHAR2,
      unidades IN NUMBER,
      imprevisto IN NUMBER,
      estado IN VARCHAR2,
      valorunitario IN NUMBER,
      tipodocumentoproveedor IN VARCHAR2,
      numerodocumentoproveedor IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_traza        NUMBER;
      v_sgestio      sin_tramita_gestion.sgestio%TYPE;
      v_ctipges      sin_tramita_gestion.ctipges%TYPE;
      v_ndetges      sin_tramita_detgestion.ndetges%TYPE;
      v_nvalser      sin_tramita_detgestion.nvalser%TYPE;
      v_cestges      sin_tramita_movgestion.csubges%TYPE;
      v_cmovval      sin_tramita_movgestion.ctipmov%TYPE := 7;   -- es el movimiento de valoracion
      v_hay          NUMBER;
      v_numerr       NUMBER;
      return_err     EXCEPTION;
/*************************************************************************
   Recibe la valoracion de un repuesto de un siniestro
*************************************************************************/
   BEGIN
      v_traza := 1;

      BEGIN
         SELECT g.sgestio, g.ctipges
           INTO v_sgestio, v_ctipges
           FROM sin_tramita_gestion g, sin_tramita_movgestion mg
          WHERE mg.sgestio = g.sgestio
            AND mg.nmovges = (SELECT MAX(nmovges)
                                FROM sin_tramita_movgestion m1
                               WHERE m1.sgestio = mg.sgestio)
            AND mg.csubges = 8   -- pdte valoracion
            AND g.nsinies = numerosiniestro
            AND g.ntramit = (SELECT ntramit
                               FROM sin_tramitacion
                              WHERE nsinies = g.nsinies
                                AND ctramit = 1);
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, 0,
                                                'Siniestro=' || numerosiniestro
                                                || ' Hay mas de una gestion pendiente de valorar');
            RETURN 1;
      END;

      BEGIN
         SELECT nvalser, ndetges
           INTO v_nvalser, v_ndetges
           FROM sin_tramita_detgestion
          WHERE sgestio = v_sgestio
            AND sservic = (SELECT codaxis
                             FROM sin_dettarifas_rel
                            WHERE codigo2 = codigoespecifico);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                                 'Siniestro=' || numerosiniestro || ' codigo='
                                                 || codigoespecifico || ' No encontrado.');
            RETURN 1;
      END;

      IF estado = 2 THEN   -- valorado. Se actualiza el precio de la pieza
         UPDATE sin_tramita_detgestion
            SET nvalser = valorunitario,
                ncantid = unidades,
                itotal = valorunitario * unidades
          WHERE sgestio = v_sgestio
            AND ndetges = v_ndetges
            AND estado = 2;
      ELSIF estado = 3 THEN   -- anulado. Se da de baja la pieza
         DELETE      sin_tramita_detgestion
               WHERE sgestio = v_sgestio
                 AND ndetges = v_ndetges
                 AND estado = 3;
      END IF;

      v_numerr := pac_gestiones.f_estado_valoracion(v_sgestio, v_cestges);   -- miramos si todos los repuestos estan valorados

      IF v_numerr <> 0 THEN
         RAISE return_err;
      END IF;

      IF v_cestges = 9 THEN   -- creamos movimiento de Valoracion para cambiar el estado a valorado
         v_numerr := pac_gestiones.f_reserva_autos(v_sgestio);

         IF v_numerr <> 0 THEN
            RAISE return_err;
         END IF;

         v_numerr := pac_gestiones.f_ins_movgestion(v_sgestio, v_cmovval, v_ctipges, NULL,
                                                    NULL, NULL);

         IF v_numerr <> 0 THEN
            RAISE return_err;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN return_err THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr, SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_iax_sin_interfases_autos.F_L023', v_traza,
                     'Sin=' || numerosiniestro || ' repuesto=' || codigoespecifico, SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_iax_sin_interfases_autos.F_L023', v_traza,
                     'Sin=' || numerosiniestro || ' repuesto=' || codigoespecifico, SQLERRM);
         RETURN 1;
   END f_l023;

   FUNCTION consultarautoasegurado(
      pcmatric IN VARCHAR2,
      pfecha IN DATE,
      ob_auto OUT ob_iax_interfase_automovil,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Devuelve los datos de un vehiculo
*************************************************************************/
      v_traza        NUMBER;
      v_error        NUMBER;
      v_sseguro      seguros.sseguro%TYPE;
      v_nriesgo      autriesgos.nriesgo%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_porcentaje   NUMBER;
      v_valor        NUMBER;
      v_count        NUMBER;
      franquicia     ob_iax_interfase_deducibles;
      deducibles     t_iax_interfase_deducibles;
      hay_error      EXCEPTION;
      dummy1         NUMBER;
      dummy2         NUMBER;
      dummy3         NUMBER;
      v_ind          NUMBER;
      v_cimpmin      NUMBER;
      v_impmin       NUMBER;
   BEGIN
      v_traza := 1;

      SELECT COUNT(*)
        INTO v_count
        FROM autriesgos
       WHERE cmatric = pcmatric;

      IF v_count = 0 THEN
         RETURN -10;   -- Vehiculo no encontrado
      END IF;

      v_traza := 2;
      ob_auto := ob_iax_interfase_automovil();

      BEGIN
         SELECT r.sseguro, r.nriesgo, r.nmovimi, r.ivehicu, r.cversion,
                r.codmotor, r.cchasis, r.nbastid, r.anyo
           INTO v_sseguro, v_nriesgo, v_nmovimi, v_valor, ob_auto.codigofasecolda,
                ob_auto.motor, ob_auto.chasis, ob_auto.vin, ob_auto.modelo
           FROM autriesgos r
          WHERE r.cmatric = pcmatric
            AND r.nmovimi = (SELECT MAX(nmovimi)
                               FROM garanseg g
                              WHERE g.sseguro = r.sseguro
                                AND g.nriesgo = r.nriesgo
                                AND g.finiefe <= pfecha)
            AND f_situacion_v(r.sseguro, pfecha, 1) = 1;   --BUG 32081/181874:NSS:14/08/2014
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN -10;   -- Vehiculo no encontrado
      END;

      v_traza := 3;

      SELECT v_valor + NVL(SUM(NVL(a.ivalacc, 0)), 0)
        INTO ob_auto.valorasegurado
        FROM autdetriesgos a, aut_accesorios b
       WHERE a.sseguro = v_sseguro
         AND a.nriesgo = v_nriesgo
         AND a.nmovimi = 2
         AND b.cversion = (SELECT MAX(c.cversion)
                             FROM aut_accesorios c
                            WHERE c.caccesorio = a.caccesorio
                              AND(c.cversion = a.cversion
                                  OR c.cversion = '0'))
         AND b.caccesorio = a.caccesorio
         AND a.ctipacc = 4;

      v_traza := 4;

      SELECT sproduc, npoliza, ncertif,
             fefecto, NVL(NVL(fanulac, fvencim), fcaranu),
             DECODE(ncertif, 0, 0, 1), DECODE(f_situacion_v(sseguro, pfecha, 1), 1, 1, 0),   --BUG 32081/181874:NSS:14/08/2014
             TO_CHAR(SUBSTR(cagente, -5))
        INTO ob_auto.producto, ob_auto.numeropoliza, ob_auto.numerocertificado,
             ob_auto.fechainiciovigenciapoliza, ob_auto.fechafinvigenciapoliza,
             ob_auto.polizacolectiva, ob_auto.polizaactiva,
             ob_auto.claveintermediario
        FROM seguros
       WHERE sseguro = v_sseguro;

      deducibles := t_iax_interfase_deducibles();
      v_traza := 5;

      FOR i IN (SELECT gg.trotgar, gg.cgarant, gs.icapital
                  FROM garanseg gs, garangen gg
                 WHERE gs.cgarant = gg.cgarant
                   AND sseguro = v_sseguro
                   AND nriesgo = v_nriesgo
                   AND nmovimi = v_nmovimi
                   AND cidioma = pac_md_common.f_get_cxtidioma
                   AND trotgar IN('PPD', 'PTD', 'PPH', 'PTH', 'RC')) LOOP
         franquicia := ob_iax_interfase_deducibles();
         franquicia.amparo := i.trotgar;
         v_traza := 6;
         v_error := pac_sin_franquicias.f_franquicia(v_sseguro, v_nmovimi, v_nriesgo,
                                                     i.cgarant,
                                                     TO_NUMBER(TO_CHAR(pfecha, 'ddddmmyy')),
                                                     dummy1, v_porcentaje, v_cimpmin,
                                                     v_impmin, dummy2, dummy3);

         IF v_error NOT IN(100, 0) THEN   -- si no hay franquicia devuelve 100
            RAISE hay_error;
         END IF;

         franquicia.porcentaje := v_porcentaje;
         v_traza := 7;
--         franquicia.valor := pac_sin_franquicias.f_fran_tot(v_sseguro, v_nmovimi, v_nriesgo,
--                                                            i.cgarant, i.icapital,
--                                                            TO_NUMBER(TO_CHAR(pfecha,
--                                                                              'ddddmmyy')));
         franquicia.valor := pac_sin_franquicias.f_fran_val(v_cimpmin, v_impmin, i.icapital,
                                                            TO_NUMBER(TO_CHAR(pfecha,
                                                                              'ddddmmyy')));
         deducibles.EXTEND;
         v_ind := deducibles.LAST;
         deducibles(v_ind) := franquicia;
      END LOOP;

      ob_auto.deducible := deducibles;
      RETURN 0;
   EXCEPTION
      WHEN hay_error THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error, SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_iax_sin_interfases_autos.ConsultarAutoAsegurado',
                     v_traza, 'Placa=' || pcmatric,
                     ' pac_sin_franquicias.f_franquicia error=' || v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_iax_sin_interfases_autos.ConsultarAutoAsegurado',
                     v_traza, 'Placa=' || pcmatric, SQLERRM);
         RETURN 1;
   END consultarautoasegurado;

   FUNCTION notificartallerasignado(
      pctipide IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pdane IN VARCHAR2,
      pnumsede IN VARCHAR2,
      pcmatric IN VARCHAR2,
      pnsinies IN VARCHAR2,
      pccontra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************

*************************************************************************/
      v_traza        NUMBER;
      v_error        NUMBER;
      v_sseguro      seguros.sseguro%TYPE;
      v_nriesgo      autriesgos.nriesgo%TYPE;
      v_count        NUMBER;
      v_cestsin      sin_movsiniestro.nmovsin%TYPE;
      v_nmovtra      sin_tramita_movimiento.nmovtra%TYPE;
      v_sperson      per_personas.sperson%TYPE;
      v_sede         sin_tramita_gestion.spersed%TYPE;
      v_ctramit      sin_tramitacion.ctramit%TYPE;
      v_ntramit      sin_tramitacion.ntramit%TYPE;
      v_sprofes      sin_prof_profesionales.sprofes%TYPE;
      v_triesgo      autriesgos.triesgo%TYPE;
      v_ctipmat      autriesgos.ctipmat%TYPE;
      v_cmarca       aut_versiones.cmarca%TYPE;
      v_cmodelo      aut_versiones.cmodelo%TYPE;
      v_cversion     autriesgos.cversion%TYPE;
      v_tversion     aut_versiones.tversion%TYPE;
      v_anyo         autriesgos.anyo%TYPE;
      v_codmotor     autriesgos.codmotor%TYPE;
      v_cchasis      autriesgos.cchasis%TYPE;
      v_nbastid      autriesgos.nbastid%TYPE;
      v_ccilindraje  autriesgos.ccilindraje%TYPE;
      v_cunitra      sin_movsiniestro.cunitra%TYPE;
      v_ctramitad    sin_movsiniestro.ctramitad%TYPE;
      v_nlocali      sin_tramita_localiza.nlocali%TYPE;
      v_cprovin      sin_tramita_localiza.cprovin%TYPE;
      v_cpoblac      sin_tramita_localiza.cpoblac%TYPE;
      v_cgarant      sin_tramita_reserva.cgarant%TYPE;
      v_sgestio      sin_tramita_gestion.sgestio%TYPE;
      v_sconven      sin_tramita_gestion.sconven%TYPE;
      v_cestges      sin_tramita_movgestion.cestges%TYPE;
      v_csubges      sin_tramita_movgestion.csubges%TYPE;
      v_fsinies      sin_siniestro.fsinies%TYPE;
   BEGIN
      -- comprobamos la existencia del siniestro
      v_traza := 1;

      BEGIN
         SELECT sseguro, nriesgo, fsinies
           INTO v_sseguro, v_nriesgo, v_fsinies
           FROM sin_siniestro
          WHERE nsinies = pnsinies;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(9001940,
                                                                pac_md_common.f_get_cxtidioma));   -- No existe el num. de siniestro
            RETURN 1;
      END;

      v_traza := 2;

      SELECT cestsin
        INTO v_cestsin
        FROM sin_movsiniestro m
       WHERE nsinies = pnsinies
         AND nmovsin = (SELECT MAX(nmovsin)
                          FROM sin_movsiniestro m1
                         WHERE m1.nsinies = m.nsinies);

      IF v_cestsin NOT IN(0, 4) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                              'El siniestro esta cerrado/rechazado');
         RETURN 1;
      END IF;

      -- Comprobamos la matricula
      v_traza := 21;

      SELECT COUNT(cmatric)
        INTO v_count
        FROM autriesgos
       WHERE sseguro = v_sseguro
         AND nriesgo = v_nriesgo
         AND cmatric = pcmatric;

      IF v_count = 0
         AND pccontra = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                              'El siniestro no coincide con la matricula');
         RETURN 1;
      END IF;

      -- Buscamos el profesional
      v_traza := 3;

      BEGIN
         SELECT pr.sperson, pr.sprofes
           INTO v_sperson, v_sprofes
           FROM per_personas pe, sin_prof_profesionales pr
          WHERE pr.sperson = pe.sperson
            AND ctipide = DECODE(pctipide,
                                 'C', 36,
                                 'E', 33,
                                 'P', 24,
                                 'R', 35,
                                 'T', 34,
                                 'NP', 38,
                                 37)
            AND nnumide = pnnumide;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, 'Taller no encontrado');
            RETURN 1;
      END;

      v_traza := 31;

      SELECT SUBSTR(LPAD(pdane, 5, '0'), 1, 2), SUBSTR(LPAD(pdane, 5, '0'), 3, 4)
        INTO v_cprovin, v_cpoblac
        FROM DUAL;

      v_traza := 4;

      BEGIN
         SELECT t.sconven, spersed
           INTO v_sconven, v_sede
           FROM sin_prof_tarifa t, per_direcciones d, sin_interfase_sede i
          WHERE t.sprofes = v_sprofes
            AND t.spersed = d.sperson
            AND d.cprovin = v_cprovin
            AND d.cpoblac = v_cpoblac
            AND d.cdomici = (SELECT MIN(cdomici)
                               FROM per_direcciones d1
                              WHERE d1.sperson = d.sperson
                                AND d.cprovin = d1.cprovin
                                AND d.cpoblac = d1.cpoblac)
            AND i.corigen = 'TALLERES'
            AND i.sprofes = t.sprofes
            AND i.sperson = t.spersed
            AND i.ccodigo = pnumsede;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 1, 0,
                                             'No se encontro el contrato del profesional/sede');
            RETURN 1;
      END;

      -- buscamos si ya hay una tramitacion abierta
      v_traza := 5;

      SELECT DECODE(pccontra, 0, 1, 2)
        INTO v_ctramit
        FROM DUAL;

      v_traza := 6;

      BEGIN
         SELECT t.ntramit
           INTO v_ntramit
           FROM sin_tramitacion t, sin_tramita_movimiento m
          WHERE m.nsinies = t.nsinies
            AND m.ntramit = t.ntramit
            AND t.nsinies = pnsinies
            AND t.ctramit = v_ctramit
            AND m.cesttra = 0
            AND m.nmovtra = (SELECT MAX(nmovtra)
                               FROM sin_tramita_movimiento m1
                              WHERE m1.nsinies = m.nsinies
                                AND m1.ntramit = m.ntramit);
      EXCEPTION
         WHEN OTHERS THEN
            v_ntramit := NULL;
      END;

      v_traza := 7;

      -- comprobamos la matricula
      IF v_ntramit IS NOT NULL THEN
         SELECT COUNT(*)
           INTO v_count
           FROM sin_tramita_detvehiculo
          WHERE nsinies = pnsinies
            AND ntramit = v_ntramit
            AND cmatric = pcmatric;

         IF v_count = 0 THEN
            v_ntramit := NULL;   -- si la matricula no coincide daremos de alta una nueva tramitacion
         END IF;
      END IF;

      IF v_ntramit IS NULL THEN   -- Creamos una nueva tramitacion
         v_traza := 8;
         v_error := pac_siniestros.f_ins_tramitacion(pnsinies, v_ctramit, 1,   -- ctcausin,
                                                     0,   -- cinform,
                                                     v_ntramit, 0,   -- cculpab,
                                                     NULL, NULL, NULL, NULL, NULL, NULL);

         IF v_error <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(v_error,
                                                                pac_md_common.f_get_cxtidioma));
            p_tab_error(f_sysdate, f_user,
                        'pac_iax_sin_interfases_autos.NotificarTallerAsignado', v_traza,
                        'Placa=' || pcmatric, 'Error al crear tramitacion');
            ROLLBACK;
            RETURN 1;
         END IF;

         IF pccontra = 0 THEN   -- si es el vehiculo asegurado recuperamos sus datos
            v_traza := 9;

            SELECT rie.ctipmat, rie.cversion, pac_autos.f_desversion(rie.cversion),
                   ver.cmarca,
--                 ver.ctipveh,
                              ver.cmodelo, rie.anyo, rie.triesgo, rie.codmotor, rie.cchasis,
                   rie.nbastid, rie.ccilindraje
              INTO v_ctipmat, v_cversion, v_tversion,
                   v_cmarca,
--                 v_ctipveh,
                            v_cmodelo, v_anyo, v_triesgo, v_codmotor, v_cchasis,
                   v_nbastid, v_ccilindraje
              FROM autriesgos rie, aut_versiones ver
             WHERE rie.sseguro = v_sseguro
               AND rie.nriesgo = v_nriesgo
               AND rie.cversion = ver.cversion
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM autriesgos a1
                               WHERE a1.sseguro = rie.sseguro
                                 AND a1.nriesgo = rie.nriesgo);
         ELSE
            v_triesgo := pcmatric;
         END IF;

         v_traza := 10;
         v_error := pac_siniestros.f_ins_detalltramitacio(v_ctramit, pnsinies, v_ntramit, NULL,   --sperson,
                                                          NULL,   --cestper,
                                                          v_triesgo,   --desctramit,
                                                          NULL,   --csiglas,
                                                          NULL,   --tnomvia,
                                                          NULL,   --nnumvia,
                                                          NULL,   --tcomple,
                                                          NULL,   --tdescdireccion,
                                                          NULL,   --cpais,
                                                          NULL,   --cprovin,
                                                          NULL,   --cpoblac,
                                                          NULL,   --cpostal,
                                                          NULL,   --cciudad,
                                                          NULL,   --fgisx,
                                                          NULL,   --fgisy,
                                                          NULL,   --fgisz,
                                                          NULL,   --cvalida,
                                                          NULL,   --ctipcar,
                                                          NULL,   --fcarnet,
                                                          NULL,   --ctipcon,
                                                          NULL,   --calcohol,
                                                          v_ctipmat, pcmatric, v_cmarca,
                                                          v_cmodelo, v_cversion, v_anyo,
                                                          v_codmotor, v_cchasis, v_nbastid,
                                                          v_ccilindraje, NULL,   --ireclam,
                                                          NULL);   --iindemn

         IF v_error <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(v_error,
                                                                pac_md_common.f_get_cxtidioma));
            p_tab_error(f_sysdate, f_user,
                        'pac_iax_sin_interfases_autos.NotificarTallerAsignado', v_traza,
                        'Placa=' || pcmatric, 'Error al crear detalle de tramitacion');
            ROLLBACK;
            RETURN 1;
         END IF;

         v_traza := 11;

         SELECT cunitra, ctramitad
           INTO v_cunitra, v_ctramitad   -- TRAMITACION CERO
           FROM sin_movsiniestro m
          WHERE m.nsinies = pnsinies
            AND m.nmovsin = (SELECT MAX(m1.nmovsin)
                               FROM sin_movsiniestro m1
                              WHERE m1.nsinies = m.nsinies);

         v_traza := 12;
         v_error := pac_siniestros.f_ins_tramita_movimiento(pnsinies, v_ntramit, v_cunitra,
                                                            v_ctramitad, 0,   -- cesttra,
                                                            0,   -- csubtra,
                                                            f_sysdate,   --festtra,
                                                            v_nmovtra, NULL);

         IF v_error <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(v_error,
                                                                pac_md_common.f_get_cxtidioma));
            p_tab_error(f_sysdate, f_user,
                        'pac_iax_sin_interfases_autos.NotificarTallerAsignado', v_traza,
                        'Placa=' || pcmatric, 'Error al crear movimiento de tramitacion');
            ROLLBACK;
            RETURN 1;
         END IF;
      END IF;

      -- CREACION LA GESTION

      -- Buscamos la localizacion
      v_traza := 13;

      SELECT MIN(nlocali)
        INTO v_nlocali
        FROM sin_tramita_localiza
       WHERE nsinies = pnsinies
         AND ntramit = v_ntramit
         AND cprovin = v_cprovin
         AND cpoblac = v_cpoblac;

      IF v_nlocali IS NULL THEN
         v_traza := 14;

         SELECT NVL(MAX(nlocali), 0) + 1
           INTO v_nlocali
           FROM sin_tramita_localiza
          WHERE nsinies = pnsinies
            AND ntramit = v_ntramit;

         v_traza := 15;
         v_error := pac_siniestros.f_ins_localiza(pnsinies, v_ntramit, v_nlocali, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, 170, v_cprovin,
                                                  v_cpoblac, NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, NULL);

         IF v_error <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(v_error,
                                                                pac_md_common.f_get_cxtidioma));
            p_tab_error(f_sysdate, f_user,
                        'pac_iax_sin_interfases_autos.NotificarTallerAsignado', v_traza,
                        'Placa=' || pcmatric, 'Error al crear localizacion');
            ROLLBACK;
            RETURN 1;
         END IF;
      END IF;

      v_traza := 16;

      -- buscamos la garantia de la reserva inicial
      BEGIN
         SELECT DISTINCT cgarant
                    INTO v_cgarant
                    FROM sin_tramita_reserva r
                   WHERE r.nsinies = pnsinies
                     AND r.ntramit = (SELECT MIN(ntramit)
                                        FROM sin_tramita_reserva r1
                                       WHERE r1.nsinies = r.nsinies)
                     AND r.ctipres = 3   -- Reserva de gastos
                     AND r.ctipgas = 30   -- Mano de obra
                     AND((pccontra = 0
                          AND cgarant IN(760, 761))
                         OR(pccontra = 1
                            AND cgarant = 755));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF pccontra = 0 THEN
               v_cgarant := NULL;
            ELSE   -- si es vehiculo contrario
                   -- comprobamos si la poliza tiene RC
               SELECT COUNT(*)
                 INTO v_count
                 FROM garanseg g
                WHERE g.sseguro = v_sseguro
                  AND g.nriesgo = v_nriesgo
                  AND g.cgarant = 755
                  AND g.nmovimi = (SELECT MAX(g1.nmovimi)
                                     FROM garanseg g1
                                    WHERE g1.sseguro = g.sseguro
                                      AND g1.nriesgo = g.nriesgo
                                      AND g1.finiefe <= v_fsinies);

               IF v_count = 0 THEN
                  v_cgarant := NULL;
               ELSE
                  v_cgarant := 755;
               END IF;
            END IF;
      END;

      -- Obtenemos el estado en el que ha de quedar la gestion
      v_traza := 17;

      BEGIN
         SELECT cestges, csubges
           INTO v_cestges, v_csubges
           FROM sin_parges_movimientos
          WHERE ctipges = 202   -- Taller (SIPO)
            AND ctipmov = 1;   -- alta
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, 'Gestion sin parametrizar');
            ROLLBACK;
            RETURN 1;
      END;

      -- Creamos la gestion
      v_traza := 18;
      v_error := pac_gestiones.f_ins_gestion(v_sseguro, pnsinies, v_ntramit, v_cgarant, NULL,
                                             202,   -- pctipges
                                             v_sprofes, 21,   -- ctippro,
                                             21,   -- csubpro,
                                             v_sede, v_sconven, 1, 1, NULL, v_nlocali, NULL,
                                             v_sgestio);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                              f_axis_literales(v_error,
                                                               pac_md_common.f_get_cxtidioma));
         p_tab_error(f_sysdate, f_user,
                     'pac_iax_sin_interfases_autos.NotificarTallerAsignado', v_traza,
                     'Placa=' || pcmatric, 'Error al crear gestion');
         ROLLBACK;
         RETURN 1;
      END IF;

      v_traza := 19;
      -- Creamos el detalle de la gestion
      v_error := pac_gestiones.f_ins_detgestion(v_sgestio, 0,   -- sservic (revision vehiculo asegurado)
                                                1, 1, 0, NULL, 0, NULL, f_sysdate, f_sysdate);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                              f_axis_literales(v_error,
                                                               pac_md_common.f_get_cxtidioma));
         p_tab_error(f_sysdate, f_user,
                     'pac_iax_sin_interfases_autos.NotificarTallerAsignado', v_traza,
                     'Placa=' || pcmatric, 'Error al crear detalle gestion');
         ROLLBACK;
         RETURN 1;
      END IF;

      v_traza := 20;
      v_error := pac_gestiones.f_ins_movgestion(v_sgestio, 1, 202,   --ctipges,
                                                'Asignación automática SIPO', v_cestges,
                                                v_csubges);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                              f_axis_literales(v_error,
                                                               pac_md_common.f_get_cxtidioma));
         p_tab_error(f_sysdate, f_user,
                     'pac_iax_sin_interfases_autos.NotificarTallerAsignado', v_traza,
                     'Placa=' || pcmatric, 'Error al crear movimiento de gestion');
         ROLLBACK;
         RETURN 1;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, SQLERRM);
         p_tab_error(f_sysdate, f_user,
                     'pac_iax_sin_interfases_autos.NotificarTallerAsignado', v_traza,
                     'Placa=' || pcmatric, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END notificartallerasignado;

   FUNCTION notificarvaloressiniestro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      valoresperdidas IN t_iax_interfase_valores_per,
      valoresrc IN t_iax_interfase_valores_rc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************

*************************************************************************/
      v_traza        NUMBER;
      v_error        NUMBER;
      v_count        NUMBER;
      v_actualiza    VARCHAR2(2);
      v_sgestio      sin_tramita_detgestion.sgestio%TYPE;
      v_sservic      sin_tramita_detgestion.sservic%TYPE;
      v_cunimed      sin_tramita_detgestion.cunimed%TYPE;
      v_itotal       sin_tramita_detgestion.itotal%TYPE;
      v_cestges      sin_tramita_movgestion.cestges%TYPE;
      v_csubges      sin_tramita_movgestion.csubges%TYPE;
      v_ctipmov      sin_tramita_movgestion.ctipmov%TYPE;
      v_ifranquicia  NUMBER := 0;
      descuentadeducible EXCEPTION;
      v_fr_gar       sin_tramita_reserva.cgarant%TYPE;
      v_fr_ntramit   sin_tramita_reserva.ntramit%TYPE;
      v_fr_mov_max   sin_tramita_reserva.nmovres%TYPE;
      v_fr_mov_mobra sin_tramita_reserva.nmovres%TYPE;
      v_fr_mov_repuestos sin_tramita_reserva.nmovres%TYPE;
      v_fr_tot_mobra sin_tramita_reserva.icaprie%TYPE;
      v_fr_tot_repuestos sin_tramita_reserva.icaprie%TYPE;
      v_fr_tot_ini   NUMBER;
      v_fr_porc_mobra NUMBER;
      v_fr_porc_repuestos NUMBER;
   BEGIN
      -- Comprobamos que el siniestro existe y esta abierto/reabierto
      v_traza := 1;

      SELECT COUNT(*)
        INTO v_count
        FROM sin_siniestro si, sin_movsiniestro ms
       WHERE ms.nsinies = si.nsinies
         AND si.nsinies = pnsinies
         AND ms.nmovsin = (SELECT MAX(nmovsin)
                             FROM sin_movsiniestro m1
                            WHERE m1.nsinies = si.nsinies)
         AND ms.cestsin IN(0, 4);

      IF v_count = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                              'Siniestro cerrado o no encontrado');
         RETURN 1;
      END IF;

      -- Tratamiento de las perdidas
      v_traza := 2;

      IF valoresperdidas IS NOT NULL
         AND valoresperdidas.COUNT > 0 THEN
         -- buscamos la tramitacion de vehiculo propio y la gestion
         v_sgestio := NULL;

         FOR k IN (SELECT sgestio
                     FROM sin_tramita_gestion g
                    WHERE g.nsinies = pnsinies
                      AND g.ntramit IN(SELECT ntramit
                                         FROM sin_tramitacion t
                                        WHERE t.nsinies = g.nsinies
                                          AND t.ntramit = g.ntramit
                                          AND t.ctramit = 1)
                      AND g.ctipges = 202) LOOP
            v_sgestio := k.sgestio;
            -- Comprobamos el estado de la gestion
            v_traza := 7;

            SELECT cestges, csubges
              INTO v_cestges, v_csubges
              FROM sin_tramita_movgestion m
             WHERE m.sgestio = v_sgestio
               AND m.nmovges = (SELECT MAX(m1.nmovges)
                                  FROM sin_tramita_movgestion m1
                                 WHERE m1.sgestio = m.sgestio);

            IF v_cestges <> 0 THEN
               v_sgestio := NULL;
            END IF;

            IF v_sgestio IS NOT NULL THEN
               EXIT;
            END IF;
         END LOOP;

         IF v_sgestio IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                               (mensajes, 1, 0,
                                'No se ha encontrado la gestion Taller del vehiculo asegurado');
            RETURN 1;
         END IF;

         -- alta detalle gestion
         FOR i IN valoresperdidas.FIRST .. valoresperdidas.LAST LOOP
            BEGIN
               IF valoresperdidas.EXISTS(i) THEN
                  IF valoresperdidas(i).tipo = 'DESCUENTADEDUCIBLE' THEN
                     RAISE descuentadeducible;
                  END IF;

                  v_actualiza := 'Si';
                  v_traza := 3;

                  SELECT sservic, cunimed
                    INTO v_sservic, v_cunimed
                    FROM sin_dettarifas
                   WHERE starifa = 101
                     AND sservic = DECODE(valoresperdidas(i).tipo,
                                          'PPDMANOOBRA', 5000,
                                          'PPDREPUESTOS', 5001,
                                          'PPHMANOOBRA', 5002,
                                          'PPHREPUESTOS', 5003,
                                          'PPDIMPREVISTOSMANOOBRA', 5004,
                                          'PPDIMPREVISTOSREPUESTOS', 5005,
                                          'PPHIMPREVISTOSMANOOBRA', 5006,
                                          'PPHIMPREVISTOSREPUESTOS', 5007,
                                          NULL);

                  v_traza := 4;

                  BEGIN
                     SELECT itotal
                       INTO v_itotal
                       FROM sin_tramita_detgestion
                      WHERE sgestio = v_sgestio
                        AND sservic = v_sservic;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_itotal := 0;
                  END;

                  v_itotal := v_itotal + valoresperdidas(i).valor;
                  v_traza := 5;

                  DELETE      sin_tramita_detgestion
                        WHERE sgestio = v_sgestio
                          AND sservic = v_sservic;

                  v_traza := 6;
                  v_error := pac_gestiones.f_ins_detgestion(v_sgestio, v_sservic, 1, v_cunimed,
                                                            v_itotal, NULL, v_itotal, 'COP',
                                                            f_sysdate, f_sysdate);

                  IF v_error <> 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(v_error,
                                                                pac_md_common.f_get_cxtidioma));
                     p_tab_error(f_sysdate, f_user,
                                 'pac_iax_sin_interfases_autos.NotificarValoresSiniestro',
                                 v_traza, 'Error=' || v_error,
                                 'Error al crear detalle de gestion 1');
                     ROLLBACK;
                     RETURN 1;
                  END IF;
               END IF;
            EXCEPTION
               WHEN descuentadeducible THEN
                  v_ifranquicia := valoresperdidas(i).valor;
            END;
         END LOOP;

         IF NVL(v_actualiza, 'No') = 'Si' THEN
            IF v_csubges = 8 THEN   -- si esta pendiente de valorar
               v_ctipmov := 7;   -- Mov. valoracion
            ELSE
               v_ctipmov := 0;   -- Mov. modificacion
            END IF;

            -- borramos el servicio generico si existe
            v_traza := 8;

            DELETE      sin_tramita_detgestion
                  WHERE sgestio = v_sgestio
                    AND sservic = 0;

            v_traza := 9;
            -- creamos el movimiento de valoracion
            v_error := pac_gestiones.f_ins_movgestion(v_sgestio, v_ctipmov,   -- tipo movimiento
                                                      202,
                                                      'Actualizacion SIPO '
                                                      || TO_CHAR(f_sysdate, 'dd/mm/yyyy'),
                                                      0,   -- estado pendiente
                                                      9   -- subestado valorada
                                                       );

            IF v_error <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(v_error,
                                                                pac_md_common.f_get_cxtidioma));
               p_tab_error(f_sysdate, f_user,
                           'pac_iax_sin_interfases_autos.NotificarValoresSiniestro', v_traza,
                           'Error=' || v_error, 'Error al crear movimiento de gestion 1');
               ROLLBACK;
               RETURN 1;
            END IF;

            IF v_ifranquicia > 0 THEN
               v_traza := 10;

               SELECT cgarant, ntramit
                 INTO v_fr_gar, v_fr_ntramit
                 FROM sin_tramita_gestion
                WHERE sgestio = v_sgestio;

               v_traza := 11;

               SELECT MAX(nmovres)
                 INTO v_fr_mov_max
                 FROM sin_tramita_reserva
                WHERE nsinies = pnsinies
                  AND ntramit = v_fr_ntramit
                  AND ctipres = 3;

               v_traza := 12;

               SELECT MAX(nmovres)
                 INTO v_fr_mov_mobra
                 FROM sin_tramita_reserva
                WHERE nsinies = pnsinies
                  AND ntramit = v_fr_ntramit
                  AND ctipres = 3
                  AND cgarant = v_fr_gar
                  AND ctipgas = 30;

               v_traza := 13;

               SELECT MAX(nmovres)
                 INTO v_fr_mov_repuestos
                 FROM sin_tramita_reserva
                WHERE nsinies = pnsinies
                  AND ntramit = v_fr_ntramit
                  AND ctipres = 3
                  AND cgarant = v_fr_gar
                  AND ctipgas = 31;

               BEGIN
                  v_traza := 14;

                  SELECT tr.icaprie
                    INTO v_fr_tot_mobra
                    FROM sin_tramita_reserva tr
                   WHERE tr.nsinies = pnsinies
                     AND tr.cgarant = v_fr_gar
                     AND tr.ctipres = 3
                     AND tr.ntramit = v_fr_ntramit
                     AND tr.ctipgas = 30
                     AND tr.nmovres = v_fr_mov_mobra;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_fr_tot_mobra := 0;
               END;

               BEGIN
                  v_traza := 15;

                  SELECT tr.icaprie
                    INTO v_fr_tot_repuestos
                    FROM sin_tramita_reserva tr
                   WHERE tr.nsinies = pnsinies
                     AND tr.cgarant = v_fr_gar
                     AND tr.ctipres = 3
                     AND tr.ntramit = v_fr_ntramit
                     AND tr.ctipgas = 31
                     AND tr.nmovres = v_fr_mov_repuestos;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_fr_tot_repuestos := 0;
               END;

               v_fr_tot_ini := v_fr_tot_mobra + v_fr_tot_repuestos;
               v_fr_porc_mobra := v_fr_tot_mobra / v_fr_tot_ini;
               v_fr_porc_repuestos := 1 - v_fr_porc_mobra;
               v_traza := 16;

               INSERT INTO sin_tramita_reserva
                           (nsinies, ntramit, ctipres, nmovres, cgarant, ccalres, fmovres,
                            cmonres, ireserva, ipago, iingreso, irecobro, icaprie, ipenali,
                            fresini, fresfin, fultpag, sidepag, sproces, fcontab, cusualt,
                            falta, cusumod, fmodifi, iprerec, ctipgas, ireserva_moncia,
                            ipago_moncia, irecobro_moncia, icaprie_moncia, ipenali_moncia,
                            iprerec_moncia, fcambio, ifranq, ifranq_moncia, itotimp,
                            itotimp_moncia, ndias, idres,   --31294/174629:NSS:13/05/2014
                                                         cmovres)   --31294/174788:NSS:13/05/2014
                  SELECT nsinies, ntramit, ctipres, v_fr_mov_max + 1, cgarant, ccalres,
                         f_sysdate, cmonres,
                         f_round(ireserva +(v_ifranquicia * v_fr_porc_mobra), 8), ipago,
                         iingreso, irecobro, icaprie, ipenali, fresini, fresfin, fultpag,
                         sidepag, sproces, fcontab, cusualt, f_sysdate, NULL, NULL, iprerec,
                         ctipgas, NULL, NULL, NULL, NULL, NULL, NULL, fcambio, ifranq, NULL,
                         itotimp, NULL, ndias, idres,   --31294/174629:NSS:13/05/2014
                                                     13   --31294/174788:NSS:13/05/2014
                    FROM sin_tramita_reserva str
                   WHERE nsinies = pnsinies
                     AND ntramit = v_fr_ntramit
                     AND ctipres = 3
                     AND ctipgas = 30
                     AND cgarant = v_fr_gar
                     AND str.nmovres = v_fr_mov_mobra;

               v_traza := 17;

               INSERT INTO sin_tramita_reserva
                           (nsinies, ntramit, ctipres, nmovres, cgarant, ccalres, fmovres,
                            cmonres, ireserva, ipago, iingreso, irecobro, icaprie, ipenali,
                            fresini, fresfin, fultpag, sidepag, sproces, fcontab, cusualt,
                            falta, cusumod, fmodifi, iprerec, ctipgas, ireserva_moncia,
                            ipago_moncia, irecobro_moncia, icaprie_moncia, ipenali_moncia,
                            iprerec_moncia, fcambio, ifranq, ifranq_moncia, itotimp,
                            itotimp_moncia, ndias, idres)   --31294/174629:NSS:13/05/2014
                  SELECT nsinies, ntramit, ctipres, v_fr_mov_max + 2, cgarant, ccalres,
                         f_sysdate, cmonres,
                         f_round(ireserva +(v_ifranquicia * v_fr_porc_repuestos), 8), ipago,
                         iingreso, irecobro, icaprie, ipenali, fresini, fresfin, fultpag,
                         sidepag, sproces, fcontab, cusualt, f_sysdate, NULL, NULL, iprerec,
                         ctipgas, NULL, NULL, NULL, NULL, NULL, NULL, fcambio, ifranq, NULL,
                         itotimp, NULL, ndias, idres   --31294/174629:NSS:13/05/2014
                    FROM sin_tramita_reserva str
                   WHERE nsinies = pnsinies
                     AND ntramit = v_fr_ntramit
                     AND ctipres = 3
                     AND ctipgas = 31
                     AND cgarant = v_fr_gar
                     AND str.nmovres = v_fr_mov_repuestos;

               v_traza := 28;
               v_error := pac_oper_monedas.f_contravalores_reserva(pnsinies, v_fr_ntramit, 3,
                                                                   v_fr_mov_max + 1);

               IF v_error <> 0 THEN
                  RETURN v_error;
               END IF;

               v_traza := 29;
               v_error := pac_oper_monedas.f_contravalores_reserva(pnsinies, v_fr_ntramit, 3,
                                                                   v_fr_mov_max + 2);

               IF v_error <> 0 THEN
                  RETURN v_error;
               END IF;
            END IF;
         END IF;
      END IF;

      -- Tratamiento de la RC
      v_traza := 18;

      IF valoresrc IS NOT NULL
         AND valoresrc.COUNT > 0 THEN
         v_actualiza := 'No';

         -- alta detalle gestion
         FOR i IN valoresrc.FIRST .. valoresrc.LAST LOOP
            IF valoresrc.EXISTS(i) THEN
               v_actualiza := 'Si';
               -- buscamos la tramitacion de vehiculo contrario y la gestion
               v_traza := 19;
               v_sgestio := NULL;

               FOR k IN (SELECT sgestio
                           FROM sin_tramita_gestion g
                          WHERE g.nsinies = pnsinies
                            AND g.ntramit IN(SELECT ntramit
                                               FROM sin_tramitacion t
                                              WHERE t.nsinies = g.nsinies
                                                AND t.ntramit = g.ntramit
                                                AND t.ctramit = 2)
                            AND g.ntramit IN(SELECT ntramit
                                               FROM sin_tramita_detvehiculo t1
                                              WHERE t1.nsinies = g.nsinies
                                                AND t1.ntramit = g.ntramit
                                                AND t1.cmatric =
                                                            valoresrc(i).placavehiculocontrario)
                            AND g.ctipges = 202) LOOP
                  v_sgestio := k.sgestio;
                  -- Comprobamos el estado de la gestion
                  v_traza := 20;

                  SELECT cestges, csubges
                    INTO v_cestges, v_csubges
                    FROM sin_tramita_movgestion m
                   WHERE m.sgestio = v_sgestio
                     AND m.nmovges = (SELECT MAX(m1.nmovges)
                                        FROM sin_tramita_movgestion m1
                                       WHERE m1.sgestio = m.sgestio);

                  IF v_cestges <> 0 THEN
                     v_sgestio := NULL;
                  END IF;

                  IF v_sgestio IS NOT NULL THEN
                     EXIT;
                  END IF;
               END LOOP;

               IF v_sgestio IS NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes, 1, 0,
                            'No se ha encontrado la gestion Taller del vehiculo contrario '
                            || valoresrc(i).placavehiculocontrario);
                  ROLLBACK;
                  RETURN 1;
               END IF;

               v_traza := 21;

               SELECT sservic, cunimed
                 INTO v_sservic, v_cunimed
                 FROM sin_dettarifas
                WHERE starifa = 101
                  AND tdescri = 'Valor RC';

               v_traza := 22;

               BEGIN
                  SELECT itotal
                    INTO v_itotal
                    FROM sin_tramita_detgestion
                   WHERE sgestio = v_sgestio
                     AND sservic = v_sservic;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_itotal := 0;
               END;

               v_itotal := v_itotal + valoresrc(i).valor;
               v_traza := 23;

               DELETE      sin_tramita_detgestion
                     WHERE sgestio = v_sgestio
                       AND sservic = v_sservic;

               v_traza := 24;
               v_error := pac_gestiones.f_ins_detgestion(v_sgestio, v_sservic, 1, v_cunimed,
                                                         v_itotal, NULL, v_itotal, 'COP',
                                                         f_sysdate, f_sysdate);

               IF v_error <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(v_error,
                                                                pac_md_common.f_get_cxtidioma));
                  p_tab_error(f_sysdate, f_user,
                              'pac_iax_sin_interfases_autos.NotificarValoresSiniestro',
                              v_traza, 'Error=' || v_error,
                              'Error al crear detalle de gestion 2');
                  ROLLBACK;
                  RETURN 1;
               END IF;
            END IF;
         END LOOP;

         IF NVL(v_actualiza, 'No') = 'Si' THEN
            IF v_csubges = 8 THEN   -- si esta pendiente de valorar
               v_ctipmov := 7;   -- Mov. valoracion
            ELSE
               v_ctipmov := 0;   -- Mov. modificacion
            END IF;

            -- borramos el servicio generico si existe
            v_traza := 25;

            DELETE      sin_tramita_detgestion
                  WHERE sgestio = v_sgestio
                    AND sservic = 0;

            v_traza := 26;
            -- creamos el movimiento de valoracion
            v_error := pac_gestiones.f_ins_movgestion(v_sgestio, v_ctipmov,   -- tipo movimiento
                                                      202,
                                                      'Actualizacion SIPO '
                                                      || TO_CHAR(f_sysdate, 'dd/mm/yyyy'),
                                                      0,   -- estado pendiente
                                                      9   -- subestado valorada
                                                       );

            IF v_error <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(v_error,
                                                                pac_md_common.f_get_cxtidioma));
               p_tab_error(f_sysdate, f_user,
                           'pac_iax_sin_interfases_autos.NotificarValoresSiniestro', v_traza,
                           'Error=' || v_error, 'Error al crear movimiento de gestion 2');
               ROLLBACK;
               RETURN 1;
            END IF;
/*
            v_traza := 20;
            v_error := pac_gestiones.f_ajusta_reserva(v_sgestio, NULL, 'COP',
                                                      2   -- modo : sustitucion
                                                       );

            IF v_error <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, 0,
                                               f_axis_literales(v_error,
                                                                pac_md_common.f_get_cxtidioma));
               p_tab_error(f_sysdate, f_user,
                           'pac_iax_sin_interfases_autos.NotificarValoresSiniestro', v_traza,
                           'Error=' || v_error, 'Error al actualizar reserva 2');
               ROLLBACK;
               RETURN 1;

            END IF;
*/
         END IF;
      END IF;

      v_traza := 27;
      v_error := pac_gestiones.f_reserva_autos(v_sgestio);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                              f_axis_literales(v_error,
                                                               pac_md_common.f_get_cxtidioma));
         p_tab_error(f_sysdate, f_user,
                     'pac_iax_sin_interfases_autos.NotificarValoresSiniestro', v_traza,
                     'Error=' || v_error, 'Error al anular reserva inicial');
         ROLLBACK;
         RETURN 1;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, SQLERRM);
         p_tab_error(f_sysdate, f_user,
                     'pac_iax_sin_interfases_autos.NotificarValoresSiniestro', v_traza,
                     'error general', SQLERRM);
         ROLLBACK;
         RETURN 1;
   END notificarvaloressiniestro;
END pac_iax_sin_interfases_autos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_INTERFASES_AUTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_INTERFASES_AUTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_INTERFASES_AUTOS" TO "PROGRAMADORESCSI";
