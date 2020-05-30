CREATE OR REPLACE PACKAGE BODY PAC_MD_CUMULOS_CONF AS
  /******************************************************************************
        NOMBRE:       PAC_MD_CUMULOS_CONF
        PROPÓSITO:  Funciones para gestionar los cumulos del tomador

        REVISIONES:
        Ver        Fecha        Autor   Descripción
       ---------  ----------  ------   ------------------------------------
        1.0        25/01/2017   HRE     1.0 Creación del package.
        2.0        23/03/2017   HRE     2.0 CONF-298: Cumulos
        3.0        21/05/2019   AP      3.0 IAXIS-4208 Actualizacion de consulta funcion f_get_cum_consorcio y f_get_cum_tomador
        4.0        06/07/2019  ECP      4.0 IAXIS-4209. Cmulo en riesgo  
        5.0        15/07/2019  ECP      5.0 IAXIS-4785  Ajustes pantalla052
        6.0        05/02/2020  DFR      6.0 IAXIS-11903: Anulación de póliza
        7.0        11/02/2020  DFR      7.0 IAXIS-11903: Anulación de póliza
        8.0        14/02/2020  ECP      8.0 IAXIS-6158. Errores Varios relacionados con Cúmulos
        9.0        19/02/2020  DFR      9.0 IAXIS-11903: Anulación de póliza
       10.0        27/02/2020  ECP     10.0 IAXIS-4785  Ajustes pantalla052 
       11.0        21/04/2020  ECP     11.0 IAXIS-13630.Cumulo Consorcios y/o Uniones Temporales
  ******************************************************************************/
   e_object_error EXCEPTION;
/*************************************************************************
    FUNCTION f_get_cum_tomador
    Permite obtener los cumulos del tomador
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out mensajes      : mesajes de error
    return                  : ref cursor
   *************************************************************************/
   FUNCTION f_get_cum_tomador(pfcorte        IN     DATE,
                              ptcumulo       IN     VARCHAR2,
                              pnnumide       IN     VARCHAR2,
                              mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
    cur      SYS_REFCURSOR;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-ptcumulo='||ptcumulo||'-pnnumide='||pnnumide;
    vobject  VARCHAR2(200) := 'pac_md_cumulos_conf.f_get_cum_tomador';
    terror         VARCHAR2(200) := 'Error obtener cumulos';
    v_moninst monedas.cmonint%TYPE;--moneda local

  BEGIN

      SELECT cmonint
        INTO v_moninst
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');
      p_control_error('pac_md_cumulos_conf', 'f_get_cum_tomador','paso 14.-' || v_moninst );
      -- Ini IAXIS-4209 -- ECP -- 06/07/2019
      --
      -- Inicio IAXIS-11903 05/02/2020
      -- Notas de la versión: 05/02/2020
      -- 1. Para los tipo de movimiento 6 (cesión por anulación) se reemplaza el valor de la capacidad de la cesión de positivo a negativo con el DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces). 
      --    para que en caso de anulación se libere ese capital del cúmulo del afianzado.
      -- 2. Se cambia la fecha dce.falta por la fecha ces.fgenera a fin de filtrar por la fecha de generación de la cesión de la tabla principal de cesiones.
      -- 3. Se comentan los filtros de las fechas de anulación y regularización de la cesión pues impiden extraer las cesiones requeridas de acuerdo a la fecha de corte.  
      -- 4. Se incluye el filtro de la fecha de generación de la cesión en el subquery para extraer la máxima cesión del seguro para traer únicamente las cesiones hasta esa fecha.
      -- 5. Se agregan dos parámetros de entrada de la función pac_cumulos_conf.f_calcula_depura_auto que sólo son necesarios para esta consulta.
      -- Se hacen los cambios para las dos consultas.
      -- Notas de la versión: 11/02/2020
      -- 1. Se añaden modificaciones a los subqueries sobre la tabla de Garantías para mejorar el rendimiento.
      -- Notas de la versión: 19/02/2020
      -- 1. Se añade la relación "AND dce.sseguro = ces.sseguro"  
      --
       --IAXIS-13630 -- 20/04/2020

      cur := pac_iax_listvalores.f_opencursor(
          'SELECT doc_tom, nom_tom, sperson, serie, 0 porc_partic, SUM(cum_tot) cum_tot, (sum(cum_tot) - sum(depura) - depuaut) cum_depu, (sum(cum_ries)) cum_ries, sum(cum_nories) cum_nories,
                  SUM(depura) depura, depuaut, SUM(rete) rete, SUM(q1) q1, SUM(q2) q2, SUM(q3) q3,
                  SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10,
                  SUM(comfu_cont) comfu_cont, SUM(comfu_pos) comfu_pos, cupo_au, cupo_mod
           FROM(
                  SELECT doc_tom, nom_tom, sperson, serie, 0 porc_partic, SUM(cum_tot) cum_tot,SUM(cum_depu) cum_depu,  sum(cum_ries) cum_ries,
                  sum(cum_nories) cum_nories, sum(depura) depura , depuaut, SUM(rete) rete, SUM(q1) q1, SUM(q2) q2, SUM(q3) q3,
                  SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10, comfu_cont, comfu_pos,
                  cupo_au, cupo_mod
                FROM(
                SELECT doc_tom, poliza, mov, seguro, sperson, garantia, serie, cgarant,  cmonint, nom_tom, cgenera,
                SUM(cum_tot) cum_tot,
                SUM(cum_tot - NVL(pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), seguro, garan, cgenera, sperson), 0)
                 - NVL(pac_cumulos_conf.f_calcula_depura_auto(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), null, null, sperson, '||''''||'POL'||''''||', '||''''||'CONSULTA'||''''||'), 0)) cum_depu,
                sum(cum_ries) cum_ries, sum(cum_nories) cum_nories,
                NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), seguro, garan, cgenera, sperson)), 0) depura,
                NVL(pac_cumulos_conf.f_calcula_depura_auto(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), null, null, sperson, '||''''||'POL'||''''||', '||''''||'CONSULTA'||''''||'), 0) depuaut,
                NVL(pac_cumulos_conf.f_calcula_comfu_cont(seguro, sperson), 0)  comfu_cont,
                NVL(pac_cumulos_conf.f_calcula_comfu_pos(seguro, sperson), 0)  comfu_pos, cupo_au, cupo_mod, SUM(rete) rete, SUM(q1) q1,
                SUM(q2) q2, SUM(q3) q3, SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10
                FROM (
                SELECT (select id.nnumide from per_identificador id where id.sperson = pe.sperson) doc_tom, seg.npoliza poliza, pe.sperson, seg.sseguro seguro, dce.cgarant garan, cmonint,
                (select pdp.tnombre1'||'||'||''''||' '||''''||'||'||'pdp.tnombre2'||'||'||''''||' '||''''||'||'||'pdp.tapelli1'||'||'||''''||' '||''''||'||'||'pdp.tapelli2 from per_detper pdp where pdp.sperson = pe.sperson) nom_tom,
                (select dv.tatribu from detvalores dv where dv.catribu = ces.cgenera
               AND cvalor = 128
               AND dv.cidioma = '||pac_md_common.f_get_cxtidioma||') mov, dce.cgarant,(select tgarant from garangen gge where gge.cgarant = dce.cgarant AND gge.cidioma = '||pac_md_common.f_get_cxtidioma||' )  garantia, ces.cgenera, to_char(con.fconini,'||''''||'yyyy'||''''||') serie,
                NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dce.icapces)), 0)cum_tot,
                NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dcr.icapces)), 0)
                          FROM garanseg gar2, det_cesionesrea dcr
                         WHERE gar2.sseguro = dcr.sseguro
                           AND gar2.cgarant = dcr.cgarant
                           AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') >= gar2.finivig
                           AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                           AND dcr.sdetcesrea = dce.sdetcesrea
                           AND gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)),0) cum_ries,
                NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dcr2.icapces)), 0)
                        FROM  garanseg gar4, det_cesionesrea dcr2
                       WHERE gar4.sseguro = dcr2.sseguro
                         AND gar4.cgarant = dcr2.cgarant
                         AND gar4.finivig > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                         AND dcr2.sdetcesrea = dce.sdetcesrea
                         AND gar4.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar5 WHERE gar4.sseguro = gar5.sseguro)),0) cum_nories,
                 NVL(pac_cumulos_conf.f_calcula_cupo_autorizado(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_au,
                 NVL(pac_cumulos_conf.f_calcula_cupo_modelo(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_mod,
                 DECODE(ces.ctramo, 0, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) rete,
                 DECODE(ces.ctramo, 1, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q1,
                       DECODE(ces.ctramo, 2, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q2,
                       DECODE(ces.ctramo, 3, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q3,
                       DECODE(ces.ctramo, 4, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q4,
                       DECODE(ces.ctramo, 5, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) facul,
                       DECODE(ces.ctramo, 6, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q6,
                       DECODE(ces.ctramo, 7, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q7,
                       DECODE(ces.ctramo, 8, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q8,
                       DECODE(ces.ctramo, 9, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q9,
                       DECODE(ces.ctramo, 10, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q10
                FROM det_cesionesrea dce, cesionesrea ces, seguros seg, monedas mon,
                     per_personas pe, tomadores tom, garanseg gar2, contratos con
                 WHERE pe.nnumide = '||''''||pnnumide||''''||'
                   AND tom.sperson = pe.sperson
                   AND gar2.sseguro = dce.sseguro
                   AND gar2.cgarant = dce.cgarant
                   AND ces.scontra = con.scontra
                   AND ces.nversio = con.nversio
                   AND ces.nmovimi = (select max(cr1.nmovimi) from cesionesrea cr1 where cr1.sseguro = ces.sseguro AND trunc(cr1.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') )
                   AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                   AND gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
                   AND tom.sseguro = ces.sseguro
                    and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                   AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
                   AND dce.sseguro = seg.sseguro
                   AND dce.sseguro = ces.sseguro
                   AND seg.csituac = 0
                   AND dce.scesrea = ces.scesrea
                   AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'N'||''''||'
                   AND mon.cidioma = '||pac_md_common.f_get_cxtidioma||'
                   AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                UNION ALL
                    SELECT (select id.nnumide from per_identificador id where id.sperson = ppr.sperson_rel) doc_tom, seg.npoliza poliza, pe.sperson, seg.sseguro seguro, dce.cgarant garan, cmonint,
                (select pdp.tnombre1'||'||'||''''||' '||''''||'||'||'pdp.tnombre2'||'||'||''''||' '||''''||'||'||'pdp.tapelli1'||'||'||''''||' '||''''||'||'||'pdp.tapelli2 from per_detper pdp where pdp.sperson = ppr.sperson_rel) nom_tom,
                (select dv.tatribu from detvalores dv where dv.catribu = ces.cgenera
               AND cvalor = 128
               AND dv.cidioma = '||pac_md_common.f_get_cxtidioma||') mov, dce.cgarant,(select tgarant from garangen gge where gge.cgarant = dce.cgarant AND gge.cidioma = '||pac_md_common.f_get_cxtidioma||' )  garantia, ces.cgenera, to_char(con.fconini,'||''''||'yyyy'||''''||') serie,
                        (NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0) * ppr.pparticipacion/ 100) cum_tot,
                        (NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dcr.icapces)), 0)
                                  FROM garanseg gar2, det_cesionesrea dcr
                                 WHERE gar2.sseguro = dcr.sseguro
                                   AND gar2.cgarant = dcr.cgarant
                                   AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') >= gar2.finivig
                                   AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                                   AND dcr.sdetcesrea = dce.sdetcesrea
                                   AND gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)),0)* ppr.pparticipacion/ 100) cum_ries,
                                (NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||',
                                 to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dcr2.icapces)), 0)
                                FROM  garanseg gar4, det_cesionesrea dcr2
                               WHERE gar4.sseguro = dcr2.sseguro
                                 AND gar4.cgarant = dcr2.cgarant
                                 AND gar4.finivig > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                                 AND dcr2.sdetcesrea = dce.sdetcesrea
                                 AND gar4.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar5 WHERE gar4.sseguro = gar5.sseguro)),0) * ppr.pparticipacion/ 100) cum_nories,
                 NVL(pac_cumulos_conf.f_calcula_cupo_autorizado(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_au,
                 NVL(pac_cumulos_conf.f_calcula_cupo_modelo(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_mod,
                 (DECODE(ces.ctramo, 0, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) rete,
                 (DECODE(ces.ctramo, 1, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q1,
                       (DECODE(ces.ctramo, 2, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q2,
                       (DECODE(ces.ctramo, 3, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q3,
                       (DECODE(ces.ctramo, 4, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q4,
                       (DECODE(ces.ctramo, 5, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * ppr.pparticipacion/ 100) facul,
                       (DECODE(ces.ctramo, 6, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q6,
                       (DECODE(ces.ctramo, 7, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q7,
                       (DECODE(ces.ctramo, 8, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q8,
                       (DECODE(ces.ctramo, 9, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q9,
                       (DECODE(ces.ctramo, 10, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q10
                FROM det_cesionesrea dce, cesionesrea ces, seguros seg, monedas mon,
                     per_personas pe, tomadores tom, garanseg gar2, contratos con, per_personas_rel ppr
                 WHERE pe.nnumide = '||''''||pnnumide||''''||'
                   AND pe.sperson = ppr.sperson_rel
                   AND ppr.sperson = tom.sperson
                   AND tom.cagrupa = ppr.cagrupa
                   AND ppr.ctipper_rel in (0,3)
                   AND gar2.sseguro = dce.sseguro
                   AND gar2.cgarant = dce.cgarant
                   AND ces.scontra = con.scontra
                   AND ces.nversio = con.nversio
                   AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                   AND gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
                   AND tom.sseguro = ces.sseguro
                   and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                   AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
                   AND ces.nmovimi = (select max(cr1.nmovimi) from cesionesrea cr1 where cr1.sseguro = ces.sseguro AND trunc(cr1.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') )
                   AND dce.sseguro = seg.sseguro
                   AND dce.sseguro = ces.sseguro
                   AND seg.csituac = 0
                   AND dce.scesrea = ces.scesrea
                   AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'N'||''''||'
                   AND mon.cidioma = '||pac_md_common.f_get_cxtidioma||'
                   AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                 )
           group by  doc_tom, poliza, mov, seguro, garantia, sperson, serie, cgarant,  cmonint, nom_tom, cgenera, garan, cupo_au, cupo_mod,
                     NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                     pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), seguro, garan, 4, sperson)), 0),
                     NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                     pac_cumulos_conf.f_calcula_depura_auto(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), null, null, sperson, '||''''||'POL'||''''||', '||''''||'CONSULTA'||''''||')), 0)
                ) valores, garanseg gar
                WHERE   gar.sseguro = valores.seguro
                   AND gar.cgarant = valores.cgarant
                   AND gar.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar2 WHERE gar2.sseguro = gar.sseguro)
          group by  doc_tom, nom_tom, sperson, serie, comfu_cont, comfu_pos, cupo_au, cupo_mod, depuaut
          )
          group by  doc_tom, nom_tom, sperson, serie, cupo_au, cupo_mod, depuaut', mensajes);
      --
      -- Fin IAXIS-11903 05/02/2020
       --IAXIS-13630 -- 20/04/2020

      -- 
    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN

          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;
  END f_get_cum_tomador;


/*************************************************************************
    FUNCTION f_get_cum_consorcio
    Permite obtener los cumulos de los integrantes de un consorcio o del tomador,
    en caso de no ser consorcio.
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del consorcio/tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_consorcio(pfcorte        IN     DATE,
                                ptcumulo       IN     VARCHAR2,
                                pnnumide       IN     VARCHAR2,
                                mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
    cur      SYS_REFCURSOR;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-ptcumulo='||ptcumulo||'-pnnumide='||pnnumide;
    vobject  VARCHAR2(200) := 'pac_md_cumulos_conf.f_get_cum_consorcio';
    terror         VARCHAR2(200) := 'Error obtener cumulos';
    v_consorcio NUMBER;
    vsperson NUMBER;

    CURSOR cur_consorcio (vsperson NUMBER) IS        
        SELECT f_consorcio (vsperson) FROM dual;
        v_moninst monedas.cmonint%TYPE;--moneda local
  BEGIN
     SELECT cmonint
       INTO v_moninst
       FROM monedas
      WHERE cidioma = pac_md_common.f_get_cxtidioma
        AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');

    SELECT sperson 
          INTO vsperson
    FROM per_personas pe WHERE pe.nnumide = pnnumide;

     OPEN cur_consorcio (vsperson);
     FETCH cur_consorcio INTO v_consorcio;
     CLOSE cur_consorcio;
     --
     --IAXIS-13630 -- ECP -- 31/03/2020 --
     IF (v_consorcio) > 0 THEN

        cur := pac_iax_listvalores.f_opencursor(
          'SELECT doc_tom, nom_tom, sperson, cagente, SUM(cum_tot) cum_tot, (sum(cum_tot) - sum(depura) - depuaut) cum_depu, (sum(cum_ries)) cum_ries, sum(cum_nories) cum_nories,
                  SUM(depura) depura,  depuaut, SUM(rete) rete, SUM(q1) q1, SUM(q2) q2, SUM(q3) q3,
                  SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10,
                  SUM(comfu_cont) comfu_cont, SUM(comfu_pos) comfu_pos, cupo_au, cupo_mod
           FROM(
                  SELECT doc_tom, nom_tom, sperson, cagente, SUM(cum_tot) cum_tot,SUM(cum_depu) cum_depu,  sum(cum_ries) cum_ries,
                  sum(cum_nories) cum_nories, sum(depura) depura, depuaut, SUM(rete) rete, SUM(q1) q1, SUM(q2) q2, SUM(q3) q3,
                  SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10, comfu_cont, comfu_pos,
                  cupo_au, cupo_mod
                FROM(
                SELECT doc_tom, poliza, mov, seguro, sperson, cagente, garantia, cgarant,  cmonint, nom_tom, cgenera,
                SUM(cum_tot) cum_tot,
                SUM(cum_tot - NVL(pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), seguro, garan, cgenera, sperson), 0)
                 - NVL(pac_cumulos_conf.f_calcula_depura_auto(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), null, null, sperson, '||''''||'POL'||''''||', '||''''||'CONSULTA'||''''||'), 0)) cum_depu,
                sum(cum_ries) cum_ries, sum(cum_nories) cum_nories,
                NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), seguro, garan, cgenera, sperson)), 0) depura,
                NVL(pac_cumulos_conf.f_calcula_depura_auto(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), null, null, sperson, '||''''||'POL'||''''||', '||''''||'CONSULTA'||''''||'), 0) depuaut,
                NVL(pac_cumulos_conf.f_calcula_comfu_cont(seguro, sperson), 0)  comfu_cont,
                NVL(pac_cumulos_conf.f_calcula_comfu_pos(seguro, sperson), 0)  comfu_pos, cupo_au, cupo_mod, SUM(rete) rete, SUM(q1) q1,
                SUM(q2) q2, SUM(q3) q3, SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10
                FROM (
                SELECT (select id.nnumide from per_identificador id where id.sperson = ppr.sperson_rel) doc_tom, seg.npoliza poliza, ppr.sperson_rel sperson, pe.cagente, seg.sseguro seguro, dce.cgarant garan, cmonint, NVL(ppr.pparticipacion,0) porc_partic,
                (select pdp.tnombre1'||'||'||''''||' '||''''||'||'||'pdp.tnombre2'||'||'||''''||' '||''''||'||'||'pdp.tapelli1'||'||'||''''||' '||''''||'||'||'pdp.tapelli2 from per_detper pdp where pdp.sperson = ppr.sperson_rel) nom_tom,
                (select dv.tatribu from detvalores dv where dv.catribu = ces.cgenera
               AND cvalor = 128
               AND dv.cidioma = '||pac_md_common.f_get_cxtidioma||') mov, dce.cgarant, (select tgarant from garangen gge where gge.cgarant = dce.cgarant AND gge.cidioma = '||pac_md_common.f_get_cxtidioma||' )  garantia, ces.cgenera, 
                NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 cum_tot,
                NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dcr.icapces, dcr.icapces))), 0) 
                          FROM garanseg gar2, det_cesionesrea dcr 
                         WHERE gar2.sseguro = dcr.sseguro
                           AND gar2.cgarant = dcr.cgarant
                           AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') >= gar2.finivig
                           AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                           AND dcr.sdetcesrea = dce.sdetcesrea
                           AND gar2.nmovimi = garant1.nmovimi),0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 cum_ries,
                NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dcr2.icapces, dcr2.icapces))), 0)
                        FROM  garanseg gar4, det_cesionesrea dcr2
                       WHERE gar4.sseguro = dcr2.sseguro
                         AND gar4.cgarant = dcr2.cgarant
                         AND gar4.finivig > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                         AND dcr2.sdetcesrea = dce.sdetcesrea
                         AND gar4.nmovimi = garant1.nmovimi),0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 cum_nories,
                 NVL(pac_cumulos_conf.f_calcula_cupo_autorizado(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_au,
                 NVL(pac_cumulos_conf.f_calcula_cupo_modelo(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_mod,
                 DECODE(ces.ctramo, 0, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 rete,
                 DECODE(ces.ctramo, 1, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 q1,
                       DECODE(ces.ctramo, 2, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 q2,
                       DECODE(ces.ctramo, 3, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 q3,
                       DECODE(ces.ctramo, 4, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 q4,
                       DECODE(ces.ctramo, 5, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 facul,
                       DECODE(ces.ctramo, 6, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 q6,
                       DECODE(ces.ctramo, 7, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 q7,
                       DECODE(ces.ctramo, 8, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 q8,
                       DECODE(ces.ctramo, 9, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 q9,
                       DECODE(ces.ctramo, 10, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * decode(ppr.pparticipacion,0,100,ppr.pparticipacion) /100 q10
                FROM per_personas pe, per_personas_rel ppr, tomadores tom, seguros seg, cesionesrea ces, det_cesionesrea dce, 
                      garanseg garant1,  monedas mon
                 WHERE pe.nnumide = '||''''||pnnumide||''''||'
                   AND ppr.sperson = pe.sperson
                   AND ppr.ctipper_rel in (0,3)
                   AND ppr.sperson = tom.sperson
                   and ppr.cagrupa = tom.cagrupa
                   AND tom.sseguro = seg.sseguro
                   AND seg.sseguro = ces.sseguro
                   AND ces.sseguro = dce.sseguro
                   AND ces.scesrea = dce.scesrea
                   and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                   AND ces.cgenera   IN(1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
                   AND ces.nmovimi = (select max(cr1.nmovimi) from cesionesrea cr1 where cr1.sseguro = ces.sseguro AND trunc(cr1.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') )
                   AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'N'||''''||'                 
                   AND dce.sseguro = garant1.sseguro
                   AND dce.cgarant = garant1.cgarant
                   AND garant1.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE garant1.sseguro = gar3.sseguro)
                   AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= garant1.ffinvig
                   AND mon.cidioma = '||pac_md_common.f_get_cxtidioma||'
                   AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                 )
           group by  doc_tom, poliza, mov, seguro, garantia, sperson, cagente,  cgarant,  cmonint, nom_tom, cgenera, garan, cupo_au, cupo_mod,
                     NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                     pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), seguro, garan, 4, sperson)), 0),
                     NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                     pac_cumulos_conf.f_calcula_depura_auto(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), null, null, sperson, '||''''||'POL'||''''||', '||''''||'CONSULTA'||''''||')), 0)
                ) valores, garanseg gar
                WHERE   gar.sseguro = valores.seguro
                   AND gar.cgarant = valores.cgarant
                   AND gar.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar2 WHERE gar2.sseguro = gar.sseguro)
          group by  doc_tom, nom_tom, sperson, cagente, comfu_cont, comfu_pos, cupo_au, cupo_mod, depuaut
          )
          group by  doc_tom, nom_tom, sperson, cagente, cupo_au, cupo_mod, depuaut', mensajes);
--IAXIS-13630 -- ECP -- 31/03/2020
    ELSE
       cur := f_get_cum_tomador(pfcorte,
                                ptcumulo,
                                pnnumide,
                                mensajes);
    END IF;
    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;
   END f_get_cum_consorcio;

/*************************************************************************
    FUNCTION f_get_com_futuros
    Permite obtener las polizas con compromisos futuros de un tomador a
    una fecha de corte.
    param in pfcorte        : Fecha de corte
    param in pnnumide       : Documento del consorcio/tomador
    param in ptipcomp       : Tipo de compromiso 1-Contractual, 2-PostContractual
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_com_futuros(pfcorte        IN     DATE,
                              pnnumide       IN     VARCHAR2,
                              ptipcomp       IN     NUMBER,
                              psperson       IN     NUMBER,
                              mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-pnnumide='||pnnumide||'-ptipcomp='||ptipcomp;
      vobject  VARCHAR2(200) := 'pac_md_cumulos_conf.f_get_com_futuros';
      terror         VARCHAR2(200) := 'Error obtener cumulos';
      v_monprod monedas.cmonint%TYPE;--moneda del producto
      v_moninst monedas.cmonint%TYPE;--moneda local

   BEGIN
      SELECT cmonint
        INTO v_moninst
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');

      cur := pac_iax_listvalores.f_opencursor(
  'SELECT poliza, mov, seguro, sperson, garantia, cgarant,  cmonint,
                DECODE('||ptipcomp||',1, NVL(pac_cumulos_conf.f_calcula_comfu_cont(seguro, sperson), 0),
                         NVL(pac_cumulos_conf.f_calcula_comfu_pos(seguro, sperson ), 0)
                       ) valor
                FROM (
                SELECT seg.npoliza poliza, pe.sperson, seg.sseguro seguro, dce.cgarant garan, cmonint,
                tatribu mov, gge.cgarant,gge.tgarant garantia

                FROM det_cesionesrea dce, cesionesrea ces, seguros seg, detvalores dv, garangen gge, monedas mon,
                     per_personas pe, tomadores tom, per_detper pdp
                 WHERE pe.nnumide = '||''''||pnnumide||''''||'
                    AND pe.sperson = pdp.sperson
                    AND tom.sseguro = ces.sseguro
                    AND tom.sperson = pe.sperson
                    --AND ces.fefecto <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                    --AND ces.fvencim > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                    AND(ces.fanulac  > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                        OR ces.fanulac  IS NULL)
                    AND(ces.fregula  > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                         OR ces.fregula  IS NULL)
                    AND ces.cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                   AND dce.sseguro = seg.sseguro
                   AND dce.scesrea = ces.scesrea
                   AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'N'||''''||'
                   AND dv.catribu = ces.cgenera
                   AND cvalor = 128
                   AND dv.cidioma = 8
                   AND dce.cgarant = gge.cgarant
                   AND gge.cidioma = 8
                   AND mon.cidioma = 8
                   AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                UNION ALL
                    SELECT seg.npoliza poliza, pe.sperson, seg.sseguro seguro, dce.cgarant garan, cmonint,
                tatribu mov, gge.cgarant,gge.tgarant garantia
                FROM det_cesionesrea dce, cesionesrea ces, seguros seg, detvalores dv, garangen gge, monedas mon,
                     per_personas pe, tomadores tom, per_detper pdp, per_personas_rel ppr
                 WHERE pe.nnumide = '||''''||pnnumide||''''||'
                    AND pe.sperson = pdp.sperson
                    AND pe.sperson = ppr.sperson_rel
                    AND ppr.sperson = tom.sperson
                    AND tom.cagrupa = ppr.cagrupa
                    AND ppr.ctipper_rel in (0,3)
                    AND tom.sseguro = ces.sseguro
                    --AND ces.fefecto <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                    --AND ces.fvencim > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                    AND(ces.fanulac  > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                        OR ces.fanulac  IS NULL)
                    AND(ces.fregula  > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                         OR ces.fregula  IS NULL)
                    AND ces.cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                   AND dce.sseguro = seg.sseguro
                   AND dce.scesrea = ces.scesrea
                   AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'N'||''''||'
                   AND dv.catribu = ces.cgenera
                   AND cvalor = 128
                   AND dv.cidioma = 8
                   AND dce.cgarant = gge.cgarant
                   AND gge.cidioma = 8
                   AND mon.cidioma = 8
                   AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                 )
             WHERE DECODE('||ptipcomp||',1, NVL(pac_cumulos_conf.f_calcula_comfu_cont(seguro, sperson), 0),
                         NVL(pac_cumulos_conf.f_calcula_comfu_pos(seguro, sperson ), 0)
                       ) > 0
           group by  poliza, mov, seguro, sperson, garantia, cgarant,  cmonint, garan', mensajes);

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_com_futuros;
/*************************************************************************
    FUNCTION f_get_detcom_futuros
    Permite obtener el detalle de los compromisos futuros de una poliza
    param in psseguro       : numero del seguro
    param in ptipcomp       : Tipo de compromiso 1-Contractual, 2-PostContractual
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_detcom_futuros(psseguro       IN     NUMBER,
                                 ptipcomp       IN     NUMBER,
                                 pfcorte        IN     DATE,
                                 psperson       IN     NUMBER,
                                 mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'psseguro='||psseguro||'-ptipcomp='||ptipcomp;
      vobject  VARCHAR2(200) := 'pac_md_cumulos_conf.f_get_detcom_futuros';
      terror         VARCHAR2(200) := 'Error obtener cumulos';
      v_sproduc productos.sproduc%TYPE;
      v_monprod monedas.cmonint%TYPE;--moneda del producto
      v_moninst monedas.cmonint%TYPE;--moneda local
      --
      v_consorcio VARCHAR2(1);
      v_tomador tomadores.sperson%TYPE;
      v_participa NUMBER;
      vcoaseguro NUMBER;

      CURSOR cur_participa(ppercons per_personas.sperson%TYPE,
                         pconsorcio VARCHAR2) IS
         SELECT  pparticipacion
           FROM per_personas_rel
          WHERE sperson = ppercons
            AND sperson_rel = psperson
            AND ctipper_rel = 0
            AND pconsorcio = 'S';

   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT cmonint
        INTO v_monprod
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_monedas.f_moneda_producto(v_sproduc);

      SELECT cmonint
        INTO v_moninst
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');
      --
      SELECT sperson
        INTO v_tomador
        FROM tomadores
       WHERE sseguro = psseguro;
      --
      IF(psperson = v_tomador) THEN
         v_participa := 100;
      ELSE
         SELECT DECODE(F_CONSORCIO(v_tomador), 0, 'N','S')
           INTO v_consorcio
              FROM dual;

         OPEN cur_participa(v_tomador, v_consorcio);
         FETCH cur_participa INTO v_participa;
         CLOSE cur_participa;
      END IF;

      BEGIN 
      SELECT nvl(c.ploccoa,0)  INTO vcoaseguro
      FROM seguros s, coacuadro c
        WHERE s.sseguro = c.sseguro
        AND s.ctipcoa = 1
        AND c.ncuacoa = (select max(ncuacoa) from coacuadro where sseguro = psseguro)
        AND s.sseguro = psseguro;
     EXCEPTION WHEN OTHERS THEN
            vcoaseguro := 0;
        END;
      IF vcoaseguro = 0 THEN
         vcoaseguro := 100;      
      END IF;

      cur := pac_iax_listvalores.f_opencursor('SELECT  gge.tgarant, pac_eco_tipocambio.f_importe_cambio((select UPPER(cmonint) from monedas where cidioma = '||pac_md_common.f_get_cxtidioma||' and cmoneda = mon),'||''''||v_moninst||''''||',to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                                                ((valor *'|| v_participa||'/ 100) * '|| vcoaseguro||'/ 100))  valor FROM (SELECT nlinea, SUM(garan) cgaran, sum(mon) mon, SUM(valor) valor
                                                 FROM (SELECT pt1.nlinea, DECODE(ccolumna,1,nvalor,0) garan, DECODE(ccolumna,2,nvalor,0) mon,
                                                              DECODE(ccolumna,4,nvalor,0) valor
                                                         FROM pregungaransegtab  pt1
                                                        WHERE pt1.sseguro = '||psseguro||'
                                                          AND pt1.cpregun = 9551
                                                          AND pt1.nmovimi = (SELECT MAX(nmovimi)
                                                                               FROM pregungaransegtab  pt2
                                                                              WHERE pt2.sseguro = pt1.sseguro
                                                                                AND pt2.cpregun = 9551)
                                                          AND pt1.ccolumna IN (1,2,4)
                                                       ) gar
                                                GROUP BY nlinea
                                              ) gar2, garangen gge
                                          WHERE gar2.cgaran = gge.cgarant
                                            AND cidioma = '||pac_md_common.f_get_cxtidioma||'
                                            AND gar2.cgaran IN (SELECT cgarant FROM pargaranpro pgp
                                                                 WHERE sproduc = '||v_sproduc||'
                                                                   AND pgp.cpargar = '||''''||'EXCONTRACTUAL'||''''||'
                                                                   AND pgp.cvalpar = '||ptipcomp||'
                                                              )', mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;

   END f_get_detcom_futuros;

/*************************************************************************
    FUNCTION f_get_pinta_consorcio
    Permite identificar cuales cuotas se pintan o no en el java.
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del consorcio/tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_pinta_contratos(pfcorte        IN     DATE,
                                  ptcumulo       IN     VARCHAR2,
                                  pnnumide       IN     VARCHAR2,
                                  mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
    cur      SYS_REFCURSOR;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-ptcumulo='||ptcumulo||'-pnnumide='||pnnumide;
    vobject  VARCHAR2(200) := 'pac_md_cumulos_conf.f_get_pinta_consorcio';
    terror         VARCHAR2(200) := 'Error obtener cumulos';
    v_consorcio NUMBER;
    v_count_rec NUMBER;
-- Ini IAXIS-4785 -- ECP -- 27/02/2020
    CURSOR cur_consorcio IS
     SELECT NVL(COUNT(0), 0)
       FROM per_parpersonas ppp, per_personas pe
      WHERE ppp.sperson = pe.sperson
        AND pe.nnumide = pnnumide
        AND ppp.cparam = 'PER_ASO_JURIDICA'
        AND ppp.nvalpar IN (1, 2);

     CURSOR cur_count_rec IS
      SELECT COUNT(0)
                  FROM (
          SELECT pe.nnumide doc_tom
            FROM per_personas pe, per_personas_rel ppr,
                 per_personas pe2, cesionesrea ces,per_parpersonas ppp,
                 seguros seg, det_cesionesrea dce, garanseg gar2
           WHERE pe.sperson = ppr.sperson_rel
             AND gar2.sseguro = dce.sseguro
             AND gar2.cgarant = dce.cgarant
             --AND to_date('20042017','ddmmyyyy') >= gar2.finivig
             AND pfcorte <= gar2.ffinvig
             and gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
             AND pe2.nnumide = pnnumide
             AND seg.sseguro = ces.sseguro
             AND ces.scesrea = dce.scesrea
             AND dce.sperson = ppr.sperson
             AND pe2.sperson = ppr.sperson
             AND pe2.sperson = ppp.sperson
             AND ppp.cparam  = 'PER_ASO_JURIDICA'
             AND ppp.nvalpar = 1
            and trunc(ces.fgenera) <= pfcorte
            AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
          UNION ALL
          SELECT pe.nnumide doc_tom
            FROM per_personas pe,
                 cesionesrea ces, seguros seg, det_cesionesrea dce, garanseg gar2
           WHERE pe.nnumide = pnnumide
             AND gar2.sseguro = dce.sseguro
             AND gar2.cgarant = dce.cgarant
             --AND to_date('20042017','ddmmyyyy') >= gar2.finivig
             AND pfcorte <= gar2.ffinvig
             and gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
             AND seg.sseguro = ces.sseguro
             AND ces.scesrea = dce.scesrea
             AND dce.sperson = pe.sperson
             and trunc(ces.fgenera) <= pfcorte
             AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
                 );


  BEGIN
     OPEN cur_consorcio;
     FETCH cur_consorcio INTO v_consorcio;
     CLOSE cur_consorcio;
     --
     OPEN cur_count_rec;
     FETCH cur_count_rec INTO v_count_rec;
     CLOSE cur_count_rec;

     IF (v_count_rec > 0) THEN
        IF (v_consorcio) > 0 THEN
           cur := pac_iax_listvalores.f_opencursor(
                                   'SELECT  DECODE(SUM(q1),0,0,1) q1, DECODE(SUM(q2),0,0,1) q2, DECODE(SUM(q3),0,0,1) q3, DECODE(SUM(q4),0,0,1) q4, DECODE(SUM(q6),0,0,1) q6,
                                        DECODE(SUM(q7),0,0,1) q7, DECODE(SUM(q8),0,0,1) q8, DECODE(SUM(q9),0,0,1) q9, DECODE(SUM(q10),0,0,1) q10
                                    FROM (
                                        SELECT doc_tom, nom_tom,
                                           SUM(q1) q1, SUM(q2) q2, SUM(q3) q3, SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10
                                            FROM (
                                    SELECT pe.nnumide doc_tom, pdp.tnombre1'||'||'||''''||' '||''''||'||'||'pdp.tnombre2'||'||'||''''||' '||''''||'||'||'pdp.tapelli1'||'||'||''''||' '||''''||'||'||'pdp.tapelli2 nom_tom,
                                           DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 0, NVL(SUM(ces.icapces), 0), 0), 0) rete,
                                           DECODE(ces.ctramo, 1, NVL(SUM(ces.icapces), 0), 0)
                                           + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 1, NVL(SUM(ces.icapces), 0), 0), 0) q1,
                                           DECODE(ces.ctramo, 2, NVL(SUM(ces.icapces), 0), 0)
                                           + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 2, NVL(SUM(ces.icapces), 0), 0), 0) q2,
                                           DECODE(ces.ctramo, 3, NVL(SUM(ces.icapces), 0), 0)
                                           + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 3, NVL(SUM(ces.icapces), 0), 0), 0) q3,
                                           DECODE(ces.ctramo, 4, NVL(SUM(ces.icapces), 0), 0)
                                           + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 4, NVL(SUM(ces.icapces), 0), 0), 0) q4,
                                           DECODE(ces.ctramo, 5, NVL(SUM(ces.icapces), 0), 0) facul,
                                           DECODE(ces.ctramo, 6, NVL(SUM(ces.icapces), 0), 0)
                                           + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 6, NVL(SUM(ces.icapces), 0), 0), 0) q6,
                                           DECODE(ces.ctramo, 7, NVL(SUM(ces.icapces), 0), 0)
                                           + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 7, NVL(SUM(ces.icapces), 0), 0), 0) q7,
                                           DECODE(ces.ctramo, 8, NVL(SUM(ces.icapces), 0), 0)
                                           + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 8, NVL(SUM(ces.icapces), 0), 0), 0) q8,
                                           DECODE(ces.ctramo, 9, NVL(SUM(ces.icapces), 0), 0)
                                           + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 9, NVL(SUM(ces.icapces), 0), 0), 0) q9,
                                           DECODE(ces.ctramo, 10, NVL(SUM(ces.icapces), 0), 0)
                                           + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0),10, NVL(SUM(ces.icapces), 0), 0), 0) q10
                                      FROM per_personas pe, per_personas_rel ppr,
                                           per_detper pdp, per_personas pe2, cesionesrea ces,per_parpersonas ppp,
                                           seguros seg, det_cesionesrea dce, garanseg gar2
                                     WHERE pe.sperson = ppr.sperson_rel
                                       AND pe2.nnumide = '||''''||pnnumide||''''||'
                                       AND gar2.sseguro = dce.sseguro
                                       AND gar2.cgarant = dce.cgarant
                                       AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                                       and gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
                                       AND seg.sseguro = ces.sseguro
                                       AND pe.sperson = pdp.sperson
                                       AND pe2.sperson = ppr.sperson
                                       AND dce.scesrea = ces.scesrea
                                       AND dce.sperson = ppr.sperson_rel
                                       AND pe2.sperson = ppp.sperson
                                       AND ppp.cparam  = '||''''||'PER_ASO_JURIDICA'||''''||'
                                       AND ppp.nvalpar = 1
                                       and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                                       AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
                                    GROUP BY pe.nnumide, ppr.pparticipacion, pdp.tnombre1'||'||'||''''||' '||''''||'||'||'pdp.tnombre2'||'||'||''''||' '||''''||'||'||'pdp.tapelli1'||'||'||''''||' '||''''||'||'||'pdp.tapelli2,
                                           ces.sseguro, ces.ctramo, ctrampa, pe.ctipper, ces.icapces, pe.sperson
                                    )
                                    GROUP BY doc_tom, nom_tom
                                    )', mensajes);

      ELSE

         cur := pac_iax_listvalores.f_opencursor(
                                 'SELECT  DECODE(SUM(q1),0,0,1) q1, DECODE(SUM(q2),0,0,1) q2, DECODE(SUM(q3),0,0,1) q3, DECODE(SUM(q4),0,0,1) q4, DECODE(SUM(q6),0,0,1) q6,
                                  DECODE(SUM(q7),0,0,1) q7, DECODE(SUM(q8),0,0,1) q8, DECODE(SUM(q9),0,0,1) q9, DECODE(SUM(q10),0,0,1) q10
                              FROM (
                                  SELECT doc_tom, nom_tom,
                                     SUM(q1) q1, SUM(q2) q2, SUM(q3) q3, SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10
                                      FROM (
                              SELECT pe.nnumide doc_tom, pdp.tnombre1'||'||'||''''||' '||''''||'||'||'pdp.tnombre2'||'||'||''''||' '||''''||'||'||'pdp.tapelli1'||'||'||''''||' '||''''||'||'||'pdp.tapelli2 nom_tom,
                                     DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 0, NVL(SUM(ces.icapces), 0), 0), 0) rete,
                                     DECODE(ces.ctramo, 1, NVL(SUM(ces.icapces), 0), 0)
                                     + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 1, NVL(SUM(ces.icapces), 0), 0), 0) q1,
                                     DECODE(ces.ctramo, 2, NVL(SUM(ces.icapces), 0), 0)
                                     + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 2, NVL(SUM(ces.icapces), 0), 0), 0) q2,
                                     DECODE(ces.ctramo, 3, NVL(SUM(ces.icapces), 0), 0)
                                     + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 3, NVL(SUM(ces.icapces), 0), 0), 0) q3,
                                     DECODE(ces.ctramo, 4, NVL(SUM(ces.icapces), 0), 0)
                                     + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 4, NVL(SUM(ces.icapces), 0), 0), 0) q4,
                                     DECODE(ces.ctramo, 5, NVL(SUM(ces.icapces), 0), 0) facul,
                                     DECODE(ces.ctramo, 6, NVL(SUM(ces.icapces), 0), 0)
                                     + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 6, NVL(SUM(ces.icapces), 0), 0), 0) q6,
                                     DECODE(ces.ctramo, 7, NVL(SUM(ces.icapces), 0), 0)
                                     + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 7, NVL(SUM(ces.icapces), 0), 0), 0) q7,
                                     DECODE(ces.ctramo, 8, NVL(SUM(ces.icapces), 0), 0)
                                     + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 8, NVL(SUM(ces.icapces), 0), 0), 0) q8,
                                     DECODE(ces.ctramo, 9, NVL(SUM(ces.icapces), 0), 0)
                                     + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 9, NVL(SUM(ces.icapces), 0), 0), 0) q9,
                                     DECODE(ces.ctramo, 10, NVL(SUM(ces.icapces), 0), 0)
                                     + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0),10, NVL(SUM(ces.icapces), 0), 0), 0) q10
                                FROM per_personas pe, per_personas_rel ppr,
                                     per_detper pdp,  cesionesrea ces,
                                     seguros seg, det_cesionesrea dce, garanseg gar2
                               WHERE pe.nnumide = '||''''||pnnumide||''''||'
                                     AND gar2.sseguro = dce.sseguro
                                     AND gar2.cgarant = dce.cgarant
                                     AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                                     and gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
                                 AND seg.sseguro = ces.sseguro
                                 AND pe.sperson = pdp.sperson
                                 AND dce.scesrea = ces.scesrea
                                 AND dce.sperson = pe.sperson
                                 and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                                 AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
                              GROUP BY pe.nnumide, ppr.pparticipacion, pdp.tnombre1'||'||'||''''||' '||''''||'||'||'pdp.tnombre2'||'||'||''''||' '||''''||'||'||'pdp.tapelli1'||'||'||''''||' '||''''||'||'||'pdp.tapelli2,
                                     ces.sseguro, ces.ctramo, ctrampa, pe.ctipper, ces.icapces, pe.sperson
                              )
                              GROUP BY doc_tom, nom_tom
                              )', mensajes);

      END IF;
-- Fin IAXIS-4785 -- ECP -- 27/02/2020
   END IF;

   RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;
   END f_get_pinta_contratos;

/*************************************************************************
    FUNCTION f_get_cum_tomador_serie
    Permite obtener los cumulos del tomador por anio/serie
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_tomador_serie(pfcorte        IN     DATE,
                                    ptcumulo       IN     VARCHAR2,
                                    pnnumide       IN     VARCHAR2,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
       cur      SYS_REFCURSOR;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-ptcumulo='||ptcumulo||'-pnnumide='||pnnumide;
    vobject  VARCHAR2(200) := 'pac_md_cumulos_conf.f_get_cum_tomador';
    terror         VARCHAR2(200) := 'Error obtener cumulos';
    v_moninst monedas.cmonint%TYPE;--moneda local
  BEGIN

      SELECT cmonint
        INTO v_moninst
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');
-- Ini IAXIS-13630 -- 15/04/2020
    cur := pac_iax_listvalores.f_opencursor(
          'SELECT doc_tom, nom_tom, sperson, serie, 0 porc_partic, SUM(cum_tot) cum_tot, (sum(cum_tot) - sum(depura) - depuaut) cum_depu, (sum(cum_ries)) cum_ries, sum(cum_nories) cum_nories,
                  SUM(depura) depura, depuaut, SUM(rete) rete, SUM(q1) q1, SUM(q2) q2, SUM(q3) q3,
                  SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10,
                  SUM(comfu_cont) comfu_cont, SUM(comfu_pos) comfu_pos, cupo_au, cupo_mod
           FROM(
                  SELECT doc_tom, nom_tom, sperson, serie, 0 porc_partic, SUM(cum_tot) cum_tot,SUM(cum_depu) cum_depu,  sum(cum_ries) cum_ries,
                  sum(cum_nories) cum_nories, sum(depura) depura , depuaut, SUM(rete) rete, SUM(q1) q1, SUM(q2) q2, SUM(q3) q3,
                  SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10, comfu_cont, comfu_pos,
                  cupo_au, cupo_mod
                FROM(
                SELECT doc_tom, poliza, mov, seguro, sperson, garantia, serie, cgarant,  cmonint, nom_tom, cgenera,
                SUM(cum_tot) cum_tot,
                SUM(cum_tot - NVL(pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), seguro, garan, cgenera, sperson), 0)
                 - NVL(pac_cumulos_conf.f_calcula_depura_auto(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), null, null, sperson), 0)) cum_depu,
                sum(cum_ries) cum_ries, sum(cum_nories) cum_nories,
                NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), seguro, garan, cgenera, sperson)), 0) depura,
                NVL(pac_cumulos_conf.f_calcula_depura_auto(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), null, null, sperson), 0) depuaut,
                NVL(pac_cumulos_conf.f_calcula_comfu_cont(seguro, sperson), 0)  comfu_cont,
                NVL(pac_cumulos_conf.f_calcula_comfu_pos(seguro, sperson), 0)  comfu_pos, cupo_au, cupo_mod, SUM(rete) rete, SUM(q1) q1,
                SUM(q2) q2, SUM(q3) q3, SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9, SUM(q10) q10
                FROM (
                SELECT (select id.nnumide from per_identificador id where id.sperson = pe.sperson) doc_tom, seg.npoliza poliza, pe.sperson, seg.sseguro seguro, dce.cgarant garan, cmonint,
                (select pdp.tnombre1'||'||'||''''||' '||''''||'||'||'pdp.tnombre2'||'||'||''''||' '||''''||'||'||'pdp.tapelli1'||'||'||''''||' '||''''||'||'||'pdp.tapelli2 from per_detper pdp where pdp.sperson = pe.sperson) nom_tom,
                (select dv.tatribu from detvalores dv where dv.catribu = ces.cgenera
               AND cvalor = 128
               AND dv.cidioma = '||pac_md_common.f_get_cxtidioma||') mov, dce.cgarant,(select tgarant from garangen gge where gge.cgarant = dce.cgarant AND gge.cidioma = '||pac_md_common.f_get_cxtidioma||' )  garantia, ces.cgenera, to_char(con.fconini,'||''''||'yyyy'||''''||') serie,
                NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dce.icapces)), 0)cum_tot,
                NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dcr.icapces)), 0)
                          FROM garanseg gar2, det_cesionesrea dcr
                         WHERE gar2.sseguro = dcr.sseguro
                           AND gar2.cgarant = dcr.cgarant
                           AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') >= gar2.finivig
                           AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                           AND dcr.sdetcesrea = dce.sdetcesrea
                           AND gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)),0) cum_ries,
                NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dcr2.icapces)), 0)
                        FROM  garanseg gar4, det_cesionesrea dcr2
                       WHERE gar4.sseguro = dcr2.sseguro
                         AND gar4.cgarant = dcr2.cgarant
                         AND gar4.finivig > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                         AND dcr2.sdetcesrea = dce.sdetcesrea
                         AND gar4.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar5 WHERE gar4.sseguro = gar5.sseguro)),0) cum_nories,
                 NVL(pac_cumulos_conf.f_calcula_cupo_autorizado(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_au,
                 NVL(pac_cumulos_conf.f_calcula_cupo_modelo(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_mod,
                 DECODE(ces.ctramo, 0, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) rete,
                 DECODE(ces.ctramo, 1, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q1,
                       DECODE(ces.ctramo, 2, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q2,
                       DECODE(ces.ctramo, 3, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q3,
                       DECODE(ces.ctramo, 4, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q4,
                       DECODE(ces.ctramo, 5, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) facul,
                       DECODE(ces.ctramo, 6, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q6,
                       DECODE(ces.ctramo, 7, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q7,
                       DECODE(ces.ctramo, 8, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q8,
                       DECODE(ces.ctramo, 9, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q9,
                       DECODE(ces.ctramo, 10, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q10
                FROM det_cesionesrea dce, cesionesrea ces, seguros seg, monedas mon,
                     per_personas pe, tomadores tom, garanseg gar2, contratos con
                 WHERE pe.nnumide = '||''''||pnnumide||''''||'
                   AND tom.sperson = pe.sperson
                   AND gar2.sseguro = dce.sseguro
                   AND gar2.cgarant = dce.cgarant
                   AND ces.scontra = con.scontra
                   AND ces.nversio = con.nversio
                   AND ces.nmovimi = (select max(cr1.nmovimi) from cesionesrea cr1 where cr1.sseguro = ces.sseguro AND trunc(cr1.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') )
                   AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                   AND gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
                   AND tom.sseguro = ces.sseguro
                    and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                   AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
                   AND dce.sseguro = seg.sseguro
                   AND dce.sseguro = ces.sseguro
                   AND seg.csituac = 0
                   AND dce.scesrea = ces.scesrea
                   AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'N'||''''||'
                   AND mon.cidioma = '||pac_md_common.f_get_cxtidioma||'
                   AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                UNION ALL
                    SELECT (select id.nnumide from per_identificador id where id.sperson = ppr.sperson_rel) doc_tom, seg.npoliza poliza, pe.sperson, seg.sseguro seguro, dce.cgarant garan, cmonint,
                (select pdp.tnombre1'||'||'||''''||' '||''''||'||'||'pdp.tnombre2'||'||'||''''||' '||''''||'||'||'pdp.tapelli1'||'||'||''''||' '||''''||'||'||'pdp.tapelli2 from per_detper pdp where pdp.sperson = ppr.sperson_rel) nom_tom,
                (select dv.tatribu from detvalores dv where dv.catribu = ces.cgenera
               AND cvalor = 128
               AND dv.cidioma = '||pac_md_common.f_get_cxtidioma||') mov, dce.cgarant,(select tgarant from garangen gge where gge.cgarant = dce.cgarant AND gge.cidioma = '||pac_md_common.f_get_cxtidioma||' )  garantia, ces.cgenera, to_char(con.fconini,'||''''||'yyyy'||''''||') serie,
                        (NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0) * ppr.pparticipacion/ 100) cum_tot,
                        (NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dcr.icapces)), 0)
                                  FROM garanseg gar2, det_cesionesrea dcr
                                 WHERE gar2.sseguro = dcr.sseguro
                                   AND gar2.cgarant = dcr.cgarant
                                   AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') >= gar2.finivig
                                   AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                                   AND dcr.sdetcesrea = dce.sdetcesrea
                                   AND gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)),0)* ppr.pparticipacion/ 100) cum_ries,
                                (NVL((SELECT NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||',
                                 to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), dcr2.icapces)), 0)
                                FROM  garanseg gar4, det_cesionesrea dcr2
                               WHERE gar4.sseguro = dcr2.sseguro
                                 AND gar4.cgarant = dcr2.cgarant
                                 AND gar4.finivig > to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                                 AND dcr2.sdetcesrea = dce.sdetcesrea
                                 AND gar4.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar5 WHERE gar4.sseguro = gar5.sseguro)),0) * ppr.pparticipacion/ 100) cum_nories,
                 NVL(pac_cumulos_conf.f_calcula_cupo_autorizado(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_au,
                 NVL(pac_cumulos_conf.f_calcula_cupo_modelo(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), pe.sperson), 0)  cupo_mod,
                 (DECODE(ces.ctramo, 0, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) rete,
                 (DECODE(ces.ctramo, 1, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q1,
                       (DECODE(ces.ctramo, 2, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q2,
                       (DECODE(ces.ctramo, 3, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q3,
                       (DECODE(ces.ctramo, 4, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q4,
                       (DECODE(ces.ctramo, 5, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * ppr.pparticipacion/ 100) facul,
                       (DECODE(ces.ctramo, 6, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q6,
                       (DECODE(ces.ctramo, 7, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q7,
                       (DECODE(ces.ctramo, 8, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q8,
                       (DECODE(ces.ctramo, 9, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q9,
                       (DECODE(ces.ctramo, 10, NVL((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion/ 100) q10
                FROM det_cesionesrea dce, cesionesrea ces, seguros seg, monedas mon,
                     per_personas pe, tomadores tom, garanseg gar2, contratos con, per_personas_rel ppr
                 WHERE pe.nnumide = '||''''||pnnumide||''''||'
                   AND pe.sperson = ppr.sperson_rel
                   AND ppr.sperson = tom.sperson
                   AND tom.cagrupa = ppr.cagrupa
                   AND ppr.ctipper_rel in (0,3)
                   AND gar2.sseguro = dce.sseguro
                   AND gar2.cgarant = dce.cgarant
                   AND ces.scontra = con.scontra
                   AND ces.nversio = con.nversio
                   AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
                   AND gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
                   AND tom.sseguro = ces.sseguro
                   and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
                   AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
                   AND ces.nmovimi = (select max(cr1.nmovimi) from cesionesrea cr1 where cr1.sseguro = ces.sseguro AND trunc(cr1.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') )
                   AND dce.sseguro = seg.sseguro
                   AND dce.sseguro = ces.sseguro
                   AND seg.csituac = 0
                   AND dce.scesrea = ces.scesrea
                   AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'N'||''''||'
                   AND mon.cidioma = '||pac_md_common.f_get_cxtidioma||'
                   AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                 )
           group by  doc_tom, poliza, mov, seguro, garantia, sperson, serie, cgarant,  cmonint, nom_tom, cgenera, garan, cupo_au, cupo_mod,
                     NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                     pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), seguro, garan, 4, sperson)), 0),
                     NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
                     pac_cumulos_conf.f_calcula_depura_auto(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), null, null, sperson)), 0)
                ) valores, garanseg gar
                WHERE   gar.sseguro = valores.seguro
                   AND gar.cgarant = valores.cgarant
                   AND gar.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar2 WHERE gar2.sseguro = gar.sseguro)
          group by  doc_tom, nom_tom, sperson, serie, comfu_cont, comfu_pos, cupo_au, cupo_mod, depuaut
          )
          group by  doc_tom, nom_tom, sperson, serie, cupo_au, cupo_mod, depuaut', mensajes);
-- Fin IAXIS-13630 -- 15/04/2020
    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN

          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;
  END f_get_cum_tomador_serie;

 /*************************************************************************
    FUNCTION f_get_cum_tomador_pol
    Permite obtener los cumulos del tomador por poliza
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_tomador_pol(pfcorte        IN     DATE,
                                  ptcumulo       IN     VARCHAR2,
                                  pnnumide       IN     VARCHAR2,
                                  mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS

    cur      SYS_REFCURSOR;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-ptcumulo='||ptcumulo||'-pnnumide='||pnnumide;
    vobject  VARCHAR2(200) := 'pac_md_cumulos_conf.f_get_cum_tomador_pol';
    terror         VARCHAR2(200) := 'Error obtener cumulos';
    v_moninst monedas.cmonint%TYPE;--moneda local
  BEGIN

      SELECT cmonint
        INTO v_moninst
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');

  -- Ini IAXIS-4785 -- ECP -- 27/02/2020
    cur := pac_iax_listvalores.f_opencursor(
    'SELECT poliza, mov, garantia, cgenera, serie, TRUNC(gar.finivig) vig_ini, TRUNC(gar.ffinvig) vig_fin, gar.sseguro, gar.cgarant,
       DECODE(ctipcoa,1,(DECODE(pparticipacion ,0, pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), gar.icapital),(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), gar.icapital) * pparticipacion /100))
       *  (select nvl(ploccoa,0) from coacuadro where sseguro = gar.sseguro and ncuacoa = (select max(ncuacoa) from coacuadro where sseguro = gar.sseguro)) / 100),
       DECODE(pparticipacion ,0, pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), gar.icapital),(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), gar.icapital) * pparticipacion /100))) 
        capital,
       rete, q1, q2, q3, q4, facul, q6, q7, q8, q9, q10
      FROM(
      SELECT poliza, mov, sseguro, garantia, serie, pparticipacion, ctipcoa,  cgarant,  cmonint, cgenera, SUM(rete) rete, SUM(q1) q1,
      SUM(q2) q2, SUM(q3) q3, SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9,
      SUM(q10) q10
      FROM (
      SELECT seg.npoliza poliza, seg.sseguro, cmonint, tatribu mov, gge.cgarant,gge.tgarant garantia, ces.cgenera,to_char(con.fconini, '||''''||'yyyy'||''''||') serie, 0 pparticipacion, seg.ctipcoa ctipcoa, 
             DECODE(ces.ctramo, 0, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) rete,
             DECODE(ces.ctramo, 1, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q1,
             DECODE(ces.ctramo, 2, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q2,
             DECODE(ces.ctramo, 3, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q3,
             DECODE(ces.ctramo, 4, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q4,
             DECODE(ces.ctramo, 5, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) facul,
             DECODE(ces.ctramo, 6, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q6,
             DECODE(ces.ctramo, 7, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q7,
             DECODE(ces.ctramo, 8, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q8,
             DECODE(ces.ctramo, 9, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q9,
             DECODE(ces.ctramo, 10, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) q10
      FROM det_cesionesrea dce, cesionesrea ces, seguros seg, detvalores dv, garangen gge, monedas mon,
           per_personas pe, tomadores tom, garanseg gar2, contratos con
       WHERE pe.nnumide = '||''''||pnnumide||''''||'
         AND tom.sperson = pe.sperson
         AND gar2.sseguro = dce.sseguro
         AND gar2.cgarant = dce.cgarant
         AND ces.scontra = con.scontra
         AND ces.nversio = con.nversio
         AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
         and gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
          AND tom.sseguro = ces.sseguro
          and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
          AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
          AND ces.nmovimi = (select max(cr1.nmovimi) from cesionesrea cr1 where cr1.sseguro = ces.sseguro AND trunc(cr1.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') )
         AND dce.sseguro = seg.sseguro
         AND dce.sseguro = ces.sseguro
         AND dce.scesrea = ces.scesrea
         AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'N'||''''||'
         AND dv.catribu = ces.cgenera
         AND cvalor = 128
         AND dv.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND dce.cgarant = gge.cgarant
         AND gge.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND mon.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
      GROUP BY  seg.npoliza, seg.sseguro, cmonint, tatribu, gge.tgarant, to_char(con.fconini, '||''''||'yyyy'||''''||'), seg.ctipcoa, 
              ces.ctramo, CTRAMPA, gge.cgarant, ces.cgenera
        UNION ALL
        SELECT seg.npoliza poliza, seg.sseguro, cmonint, tatribu mov, gge.cgarant,gge.tgarant garantia, ces.cgenera,to_char(con.fconini, '||''''||'yyyy'||''''||') serie, ppr.pparticipacion pparticipacion, seg.ctipcoa ctipcoa, 
             (DECODE(ces.ctramo, 0, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) * ppr.pparticipacion / 100) rete,
             (DECODE(ces.ctramo, 1, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) q1,
             (DECODE(ces.ctramo, 2, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) q2,
             (DECODE(ces.ctramo, 3, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) q3,
             (DECODE(ces.ctramo, 4, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) q4,
             (DECODE(ces.ctramo, 5, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) facul,
             (DECODE(ces.ctramo, 6, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) q6,
             (DECODE(ces.ctramo, 7, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) q7,
             (DECODE(ces.ctramo, 8, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) q8,
             (DECODE(ces.ctramo, 9, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) q9,
             (DECODE(ces.ctramo, 10, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)* ppr.pparticipacion / 100) q10
      FROM det_cesionesrea dce, cesionesrea ces, seguros seg, detvalores dv, garangen gge, monedas mon,
           per_personas pe, tomadores tom, garanseg gar2, contratos con, per_personas_rel ppr
       WHERE pe.nnumide = '||''''||pnnumide||''''||'
         AND pe.sperson = ppr.sperson_rel
         AND ppr.sperson = tom.sperson
         AND tom.cagrupa = ppr.cagrupa
         AND ppr.ctipper_rel in (0,3)
         AND gar2.sseguro = dce.sseguro
         AND gar2.cgarant = dce.cgarant
         AND ces.scontra = con.scontra
         AND ces.nversio = con.nversio
         AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
         and gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
          AND tom.sseguro = ces.sseguro
          and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
          AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
          AND ces.nmovimi = (select max(cr1.nmovimi) from cesionesrea cr1 where cr1.sseguro = ces.sseguro AND trunc(cr1.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') )
         AND dce.sseguro = seg.sseguro
         AND dce.sseguro = ces.sseguro
         AND dce.scesrea = ces.scesrea
         AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'N'||''''||'
         AND dv.catribu = ces.cgenera
         AND cvalor = 128
         AND dv.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND dce.cgarant = gge.cgarant
         AND gge.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND mon.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
      GROUP BY  seg.npoliza, seg.sseguro, cmonint, tatribu, gge.tgarant, to_char(con.fconini, '||''''||'yyyy'||''''||'), ppr.pparticipacion, seg.ctipcoa,
              ces.ctramo, CTRAMPA, gge.cgarant, ces.cgenera
      )
      GROUP BY  poliza, mov, sseguro, garantia, serie, pparticipacion, ctipcoa,  cgarant, cmonint, cgenera

      ) valores, garanseg gar
      WHERE   gar.sseguro = valores.sseguro
         AND gar.cgarant = valores.cgarant
         AND gar.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar2 WHERE gar2.sseguro = gar.sseguro )
      ORDER BY serie, poliza, mov, garantia desc' , mensajes);
-- Fin IAXIS-4785 -- ECP -- 27/02/2020
    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN

          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;

   END f_get_cum_tomador_pol;

   /*************************************************************************
    FUNCTION f_set_depuracion_manual
    Permite generar el registro de depuracion manual
    param in psseguro       : codigo seguro
    param in pcgenera       : Tipo de movimiento
    param in pcgarant       : codigo de garantia
    param in pindicad       : indicador, P(orcentaje) - V(alor)
    param in pvalor         : valor, puede ser un importe o un
                              porcentaje depndiendo de pindicad
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_set_depuracion_manual(psseguro       IN     NUMBER,
                                    pcgenera       IN     NUMBER,
                                    pcgarant       IN     NUMBER,
                                    pindicad       IN     VARCHAR2,
                                    pvalor         IN     NUMBER,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parmetros - psseguro: ' || psseguro|| ' - pcgenera: ' || pcgenera
                                      || ' - pcgarant: ' || pcgarant|| ' - pindicad: ' || pindicad
                                      || ' - pvalor: ' || pvalor;
      vobject        VARCHAR2(200) := 'pac_md_cumulos_conf.f_set_depuracion_manual';
   BEGIN
      vnumerr := pac_cumulos_conf.f_set_depuracion_manual(psseguro, pcgenera, pcgarant, pindicad, pvalor);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;

  END f_set_depuracion_manual;

/*************************************************************************
    FUNCTION f_get_depuracion_manual
    Permite obtener las depuraciones manuales de un tomador
    param in pfcorte        : fecha de corte
    param in pnnumide       : numero de documento
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_depuracion_manual(pfcorte        IN     DATE,
                                    pnnumide       IN     VARCHAR2,
                                    psperson       IN     NUMBER,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS

    cur      SYS_REFCURSOR;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-pnnumide='||pnnumide;
    vobject  VARCHAR2(200) := 'pac_md_cumulos_conf.f_get_depuracion_manual';
    terror         VARCHAR2(200) := 'Error obtener cumulos';
    v_moninst monedas.cmonint%TYPE;--moneda local
  BEGIN

      SELECT cmonint
        INTO v_moninst
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');
-- Ini IAXIS-4785 -- ECP -- 27/02/2020
    cur := pac_iax_listvalores.f_opencursor(
    'SELECT serie, poliza npoliza, sperson, gar.sseguro, garantia tgarant, pac_cumulos_conf.f_get_fechadepu(gar.sseguro, gar.cgarant) fefecdema,
            depura totdepu, rete, q1, q2, q3, q4, facul, q6, q7, q8, q9, q10

      FROM(
      SELECT poliza, mov, sperson, sseguro, garantia, serie,cgarant,  cmonint, cgenera,
             NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||',
             to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
             pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), sseguro, cgarant, cgenera, sperson)), 0) depura,
      SUM(rete) rete, SUM(q1) q1,
      SUM(q2) q2, SUM(q3) q3, SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9,
      SUM(q10) q10
      FROM (
      SELECT seg.npoliza poliza, pe.sperson, seg.sseguro, cmonint, tatribu mov, gge.cgarant,gge.tgarant garantia, ces.cgenera,to_char(ces.fefecto, '||''''||'yyyy'||''''||') serie,
             DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 0, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) rete,
             DECODE(ces.ctramo, 1, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 1, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q1,
             DECODE(ces.ctramo, 2, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 2, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q2,
             DECODE(ces.ctramo, 3, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 3, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q3,
             DECODE(ces.ctramo, 4, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 4, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q4,
             DECODE(ces.ctramo, 5, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) facul,
             DECODE(ces.ctramo, 6, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 6, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q6,
             DECODE(ces.ctramo, 7, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 7, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q7,
             DECODE(ces.ctramo, 8, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 8, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q8,
             DECODE(ces.ctramo, 9, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 9, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q9,
             DECODE(ces.ctramo, 10, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0),10, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q10
      FROM det_cesionesrea dce, cesionesrea ces, seguros seg, detvalores dv, garangen gge, monedas mon,
           per_personas pe, tomadores tom, garanseg gar2
       WHERE pe.nnumide = '||''''||pnnumide||''''||'
         --AND tom.sperson = pe.sperson
           AND gar2.sseguro = dce.sseguro
           AND gar2.cgarant = dce.cgarant
           --AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') >= gar2.finivig
           AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
           and gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
         AND dce.sperson = pe.sperson
          AND tom.sseguro = ces.sseguro
         and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
          AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)
         AND dce.sseguro = seg.sseguro
         AND dce.scesrea = ces.scesrea
         AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'S'||''''||'



         AND TRUNC(dce.fefecdema) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
         AND  dce.nmovimi = (SELECT MAX(nmovimi) FROM det_cesionesrea dces2
                                WHERE dce.sseguro = dces2.sseguro)
          AND  (dce.nmovidep = (SELECT MAX(nmovidep) FROM det_cesionesrea dces3
                                  WHERE dce.sseguro = dces3.sseguro
                                    AND dce.cgarant = dces3.cgarant)

                )
           AND dce.nmovidep != 1




         AND dv.catribu = ces.cgenera
         AND cvalor = 128
         AND dv.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND dce.cgarant = gge.cgarant
         AND gge.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND mon.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
      GROUP BY  seg.npoliza, pe.sperson, seg.sseguro, cmonint, tatribu, gge.tgarant, to_char(ces.fefecto, '||''''||'yyyy'||''''||'),
              ces.ctramo, CTRAMPA, gge.cgarant, ces.cgenera
      )
      GROUP BY  poliza, mov, sseguro, sperson, garantia, serie, cgarant, cmonint, cgenera

      ) valores, garanseg gar
      WHERE   gar.sseguro = valores.sseguro
         AND gar.cgarant = valores.cgarant
         AND gar.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar2 WHERE gar2.sseguro = gar.sseguro)
         AND depura > 0
      ORDER BY serie, poliza, mov, garantia desc',  mensajes);
--Fin IAXIS-4785 -- ECP -- 27/02/2020
    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN

          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;
   END f_get_depuracion_manual;

/*************************************************************************
    FUNCTION f_get_depuracion_manual_serie
    Permite obtener las depuraciones manuales de un tomador por serie/anio
    param in pfcorte        : fecha de corte
    param in pnnumide       : numero de documento
    param in pserie         : serie/anio
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_depuracion_manual_serie(pfcorte        IN     DATE,
                                          pnnumide       IN     VARCHAR2,
                                          pserie         IN     NUMBER,
                                          psperson       IN     NUMBER,
                                          mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS

    cur      SYS_REFCURSOR;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-pnnumide='||pnnumide;
    vobject  VARCHAR2(200) := 'pac_md_cumulos_conf.f_get_depuracion_manual';
    terror         VARCHAR2(200) := 'Error obtener cumulos';
    v_moninst monedas.cmonint%TYPE;--moneda local
  BEGIN

      SELECT cmonint
        INTO v_moninst
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');
--Ini IAXIS-4785 -- ECP -- 27/02/2020
    cur := pac_iax_listvalores.f_opencursor(
    'SELECT serie, poliza npoliza, sperson, gar.sseguro, garantia tgarant, pac_cumulos_conf.f_get_fechadepu(gar.sseguro, gar.cgarant) fefecdema,
            depura totdepu, rete, q1, q2, q3, q4, facul, q6, q7, q8, q9, q10

      FROM(
      SELECT poliza, sperson, mov, sseguro, garantia, serie,cgarant,  cmonint, cgenera,
             NVL(pac_eco_tipocambio.f_importe_cambio(cmonint,'||''''||v_moninst||''''||',
             to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'),
             pac_cumulos_conf.f_calcula_depura_manual(to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), sseguro, cgarant, cgenera, sperson)), 0) depura,
      SUM(rete) rete, SUM(q1) q1,
      SUM(q2) q2, SUM(q3) q3, SUM(q4) q4, SUM(facul) facul, SUM(q6) q6, SUM(q7) q7, SUM(q8) q8, SUM(q9) q9,
      SUM(q10) q10
      FROM (
      SELECT seg.npoliza poliza, pe.sperson, seg.sseguro, cmonint, tatribu mov, gge.cgarant,gge.tgarant garantia, ces.cgenera,to_char(ces.fefecto, '||''''||'yyyy'||''''||') serie,
             DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 0, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) rete,
             DECODE(ces.ctramo, 1, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 1, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q1,
             DECODE(ces.ctramo, 2, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 2, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q2,
             DECODE(ces.ctramo, 3, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 3, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q3,
             DECODE(ces.ctramo, 4, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 4, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q4,
             DECODE(ces.ctramo, 5, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0) facul,
             DECODE(ces.ctramo, 6, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 6, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q6,
             DECODE(ces.ctramo, 7, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 7, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q7,
             DECODE(ces.ctramo, 8, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 8, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q8,
             DECODE(ces.ctramo, 9, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0), 9, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q9,
             DECODE(ces.ctramo, 10, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0)
             + DECODE(ces.ctramo, 0, DECODE(NVL(ctrampa, 0),10, NVL(SUM(pac_eco_tipocambio.f_importe_cambio(mon.cmonint,'||''''||v_moninst||''''||', to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||'), DECODE(ces.cgenera, 6, -dce.icapces, dce.icapces))), 0), 0), 0) q10
      FROM det_cesionesrea dce, cesionesrea ces, seguros seg, detvalores dv, garangen gge, monedas mon,
           per_personas pe, tomadores tom, garanseg gar2
       WHERE pe.nnumide = '||''''||pnnumide||''''||'
         AND to_char(ces.fefecto, '||''''||'YYYY'||''''||') = '||pserie||'
         --AND tom.sperson = pe.sperson
           AND gar2.sseguro = dce.sseguro
           AND gar2.cgarant = dce.cgarant
           AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') >= gar2.finivig
           AND to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||') <= gar2.ffinvig
           and gar2.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar3 WHERE gar2.sseguro = gar3.sseguro)
         AND dce.sperson = pe.sperson
          AND tom.sseguro = ces.sseguro
          AND ces.fefecto <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
         and trunc(ces.fgenera) <= to_date('||''''||to_char(pfcorte,'ddmmyyyy')||''''||','||''''||'ddmmyyyy'||''''||')
          AND ces.cgenera   IN(1, 3, 4, 5,6, 9, 10, 20, 40, 41)

         AND dce.sseguro = seg.sseguro
         AND dce.scesrea = ces.scesrea
         AND NVL(dce.cdepura,'||''''||'N'||''''||') = '||''''||'S'||''''||'
         AND dv.catribu = ces.cgenera
         AND cvalor = 128
         AND dv.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND dce.cgarant = gge.cgarant
         AND gge.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND mon.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
      GROUP BY  seg.npoliza, pe.sperson, seg.sseguro, cmonint, tatribu, gge.tgarant, to_char(ces.fefecto, '||''''||'yyyy'||''''||'),
              ces.ctramo, CTRAMPA, gge.cgarant, ces.cgenera
      )
      GROUP BY  poliza, sperson, mov, sseguro, garantia, serie, cgarant, cmonint, cgenera

      ) valores, garanseg gar
      WHERE   gar.sseguro = valores.sseguro
         AND gar.cgarant = valores.cgarant
         AND gar.nmovimi = (SELECT MAX(nmovimi) FROM garanseg gar2 WHERE gar2.sseguro = gar.sseguro)
         AND depura > 0
      ORDER BY serie, poliza, mov, garantia desc', mensajes);
 -- Ini IAXIS-4785 -- ECP -- 27/02/2020
    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN

          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;
   END f_get_depuracion_manual_serie;

END pac_md_cumulos_conf;

/
