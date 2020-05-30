--------------------------------------------------------
--  DDL for Package Body PAC_MD_ESTCESIONESREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_ESTCESIONESREA" IS
   /****************************************************************************
       NOMBRE:     PAC_MD_ESTCESIONESREA
       PROP¿SITO:  Cesiones Manuales de Reaseguro

       REVISIONES:

       Ver        Fecha       Autor    Descripci¿n
       ---------  ----------  -------- ----------------------------------------
       1.0        07/09/2015   XXX     1. Creaci¿n del package.
       2.0        14/01/2016   AGG     0039214: QT:22872: No permite realizar cesion manual
       3.0        28/01/2016   AGG     0039214: QT:22872: No permite realizar cesion manual
       4.0        09/02/2016   AGG     0039214: QT:22872: No permite realizar cesion manual
       5.0        10/02/2016   AGG     0037294: LAG8_894-Nuevo requerimiento - Cesiones manuales
       6.0        16/02/2016   AGG     0037294: LAG8_894-Nuevo requerimiento - Cesiones manuales
       7.0        01/04/2016   AGG     0037294: LAG8_894-Nuevo requerimiento - Cesiones manuales
	   8.0        06/20/2019   JRR     IAXIS-4404: Ajuste cesiones manuales SSEGURO	
       9.0        29/07/2019   FEPP    IAXUS-4611 : No se puede hacer la cesion cuando tiene decimales se modifico funciones FUNCTION f_update_estcesionesrea , FUNCTION 
	   compruebaporcentajes
	   10.0       08/12/2019   FEPP    IAXIS-4821 :MODIFICACIONES FACULTATIVAS LA INFORMACION DE FACULTATIVOS NO PASSA A LA TABLA REASEGURO
	   11.0       09/04/2020   FEPP    IAXIS-13247: En el menú de modificación  manual de cesiones no esta permitiendo modificar las pólizas de RC
    ****************************************************************************/
   psproces       NUMBER;
   param_error    EXCEPTION;
   param_sseguro CONSTANT VARCHAR2(32) := 'sseguro';
   param_scesrea CONSTANT VARCHAR2(32) := 'scesrea';
   param_nsinies CONSTANT VARCHAR2(32) := 'nsinies';
   param_scumulo CONSTANT VARCHAR2(32) := 'scumulo';
-- param_npoliza           CONSTANT VARCHAR2(32) := 'npoliza';
   param_npoliza CONSTANT VARCHAR2(32) := 'ssegpol';   -- 09/09/2015

	FUNCTION f_get_estcesionesrea(
      psfield VARCHAR2,
      pnvalue NUMBER,
      pcgenera IN NUMBER DEFAULT -1)
      RETURN t_iax_estcesionesrea IS
      TYPE cur_typ IS REF CURSOR;

      c              cur_typ;
      vsql           VARCHAR2(4096)
         :=   -- El UNION trae los que tienen cgarant diferente de null con los que tienen cgarant en null
           'SELECT * ' || CHR(10) || 'FROM ( ' || CHR(10)
           || '   SELECT c.scesrea,     c.ncesion, c.icesion, c.icapces, c.sseguro,   c.nversio, c.scontra, '
           || CHR(10)
           || '          c.ctramo,      c.sfacult, c.nriesgo, c.icomisi, c.scumulo,   c.cgarant, c.spleno,  '
           || CHR(10)
           || '          c.nsinies,     c.fefecto, c.fvencim, c.fcontab, c.pcesion,   c.sproces, c.cgenera, '
           || CHR(10)
           || '          c.fgenera,     c.fregula, c.fanulac, c.nmovimi, c.sidepag,   c.ipritarrea, '
           || CHR(10)
           || '          c.psobreprima, c.cdetces, c.ipleno,  c.icapaci, c.nmovigen,  c.iextrap, '
           || CHR(10)
           || '          c.iextrea,     c.nreemb,  c.nfact,   c.nlinea,  c.itarifrea, c.icomext, c.falta, '
           || CHR(10)
           || '          c.cusualt,     c.fmodifi, c.cusumod, c.ssegpol, c.npoliza,   c.ncertif, '
           || CHR(10)
           || '          ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, c.cgenera) movimiento, '
           || CHR(10) || '          g.tgarant amparo, ct.tcontra contrato, ' || CHR(10)
           || '          case when c.ctrampa is null then ff_desvalorfijo(8002002, pac_md_common.f_get_cxtidioma, c.ctramo) else ff_desvalorfijo(8002001, pac_md_common.f_get_cxtidioma, c.ctrampa) end as ttramo, '
           || CHR(10)
           || '          SUM(c.pcesion) OVER (PARTITION BY c.cgarant) total_pcesion, '
           || CHR(10)
           || '          SUM(c.icesion) OVER (PARTITION BY c.cgarant) total_icesion, '
           || CHR(10)
           || '          SUM(c.icapces) OVER (PARTITION BY c.cgarant) total_icapces,  '
           || CHR(10)
           || '    DECODE(c.ctipomov , ''A'' , ''Autom¿co'', ''M'', ''Manual'') ctipomov, '
           || CHR(10)
           || '           c.ctrampa '
           || CHR(10) || '   FROM estcesionesrea c, garangen g, contratos ct ' || CHR(10)
           || '   WHERE c.<psfield> = :nvalue1 ' || CHR(10)
           || '     AND c.cgarant   = g.cgarant(+) ' || CHR(10)
           || '     AND g.cidioma   = pac_md_common.f_get_cxtidioma ' || CHR(10)
           || '     AND c.scontra   = ct.scontra(+) ' || CHR(10)
           || '     AND c.nversio   = ct.nversio(+) ' || CHR(10)
           --INICIO (22872 + 39214): AGG 09/02/2016
           || '     AND (pcesion > 0 or cgenera is null)' || CHR(10)
           --FIN (22872 + 39214): AGG 09/02/2016
           || '     AND (c.cgenera   =  ' || CHR(10) || pcgenera || CHR(10)
           || '  AND c.cgenera != 7 or c.cgenera is null)    UNION' || CHR(10)
           || '   SELECT c.scesrea,     c.ncesion, c.icesion, c.icapces, c.sseguro,   c.nversio, c.scontra, '
           || CHR(10)
           || '          c.ctramo,      c.sfacult, c.nriesgo, c.icomisi, c.scumulo,   c.cgarant, c.spleno,  '
           || CHR(10)
           || '          c.nsinies,     c.fefecto, c.fvencim, c.fcontab, c.pcesion,   c.sproces, c.cgenera, '
           || CHR(10)
           || '          c.fgenera,     c.fregula, c.fanulac, c.nmovimi, c.sidepag,   c.ipritarrea, '
           || CHR(10)
           || '          c.psobreprima, c.cdetces, c.ipleno,  c.icapaci, c.nmovigen,  c.iextrap, '
           || CHR(10)
           || '          c.iextrea,     c.nreemb,  c.nfact,   c.nlinea,  c.itarifrea, c.icomext, c.falta, '
           || CHR(10)
           || '          c.cusualt,     c.fmodifi, c.cusumod, c.ssegpol, c.npoliza,   c.ncertif, '
           || CHR(10)
           || '          ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, c.cgenera) movimiento, '
           || CHR(10) || '          null amparo, ct.tcontra contrato, ' || CHR(10)
           || '          case when c.ctrampa is null then ff_desvalorfijo(8002002, pac_md_common.f_get_cxtidioma, c.ctramo) else ff_desvalorfijo(8002001, pac_md_common.f_get_cxtidioma, c.ctrampa) end as ttramo, '
           || CHR(10)
           || '          SUM(c.pcesion) OVER (PARTITION BY c.cgarant) total_pcesion, '
           || CHR(10)
           || '          SUM(c.icesion) OVER (PARTITION BY c.cgarant) total_icesion, '
           || CHR(10)
           || '          SUM(c.icapces) OVER (PARTITION BY c.cgarant) total_icapces,  '
           || CHR(10)
           || '          DECODE(c.ctipomov , ''A'' , ''Autom¿co'', ''M'', ''Manual'') ctipomov, '
           || CHR(10)
           || '           c.ctrampa '
           || CHR(10) || '   FROM estcesionesrea c, contratos ct ' || CHR(10)
           --INICIO (22872 + 39214): AGG 09/02/2016
           || '   WHERE c.<psfield> = :nvalue2 ' || CHR(10)
           --INICIO (22872 + 39214): AGG 16/02/2016
           || '     AND c.cgarant   is null AND (pcesion > 0 or cgenera is null) '
           --FIN (22872 + 39214): AGG 16/02/2016
           --FIN (22872 + 39214): AGG 09/02/2016
           || CHR(10) || '     AND c.scontra   = ct.scontra(+) ' || CHR(10)
           || '     AND c.nversio   = ct.nversio(+)    AND (c.cgenera   =  ' || CHR(10)
           || pcgenera || CHR(10) || '  AND c.cgenera != 7 or c.cgenera is null) ) ' || CHR(10)
           || 'ORDER BY sproces desc, CASE WHEN  ctrampa is null then ttramo END ASC, CASE WHEN  ctrampa is not null then ttramo END ASC ';
      vsqlsinmov     VARCHAR2(4096)
         :=   -- El UNION trae los que tienen cgarant diferente de null con los que tienen cgarant en null
           'SELECT * ' || CHR(10) || 'FROM ( ' || CHR(10)
           || '   SELECT c.scesrea,     c.ncesion, c.icesion, c.icapces, c.sseguro,   c.nversio, c.scontra, '
           || CHR(10)
           || '          c.ctramo,      c.sfacult, c.nriesgo, c.icomisi, c.scumulo,   c.cgarant, c.spleno,  '
           || CHR(10)
           || '          c.nsinies,     c.fefecto, c.fvencim, c.fcontab, c.pcesion,   c.sproces, c.cgenera, '
           || CHR(10)
           || '          c.fgenera,     c.fregula, c.fanulac, c.nmovimi, c.sidepag,   c.ipritarrea, '
           || CHR(10)
           || '          c.psobreprima, c.cdetces, c.ipleno,  c.icapaci, c.nmovigen,  c.iextrap, '
           || CHR(10)
           || '          c.iextrea,     c.nreemb,  c.nfact,   c.nlinea,  c.itarifrea, c.icomext, c.falta, '
           || CHR(10)
           || '          c.cusualt,     c.fmodifi, c.cusumod, c.ssegpol, c.npoliza,   c.ncertif, '
           || CHR(10)
           || '          ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, c.cgenera) movimiento, '
           || CHR(10) || '          g.tgarant amparo, ct.tcontra contrato, ' || CHR(10)
           || '          case when c.ctrampa is null then ff_desvalorfijo(8002002, pac_md_common.f_get_cxtidioma, c.ctramo) else ff_desvalorfijo(8002001, pac_md_common.f_get_cxtidioma, c.ctrampa) end as ttramo, '
           || CHR(10)
           || '          SUM(c.pcesion) OVER (PARTITION BY c.cgarant) total_pcesion, '
           || CHR(10)
           || '          SUM(c.icesion) OVER (PARTITION BY c.cgarant) total_icesion, '
           || CHR(10)
           || '          SUM(c.icapces) OVER (PARTITION BY c.cgarant) total_icapces,  '
           || CHR(10)
           || '         DECODE(c.ctipomov , ''A'' , ''Autom¿co'', ''M'', ''Manual'') ctipomov, '
           || CHR(10)
           || '           c.ctrampa '
           || CHR(10) || '   FROM estcesionesrea c, garangen g, contratos ct ' || CHR(10)
           || '   WHERE c.<psfield> = :nvalue1 ' || CHR(10)
           || '     AND c.cgarant   = g.cgarant(+) ' || CHR(10)
           || '     AND g.cidioma   = pac_md_common.f_get_cxtidioma ' || CHR(10)
           || '     AND c.scontra   = ct.scontra(+) ' || CHR(10)
           --INICIO (22872 + 39214): AGG 09/02/2016
           --INICIO (22872 + 39214): AGG 16/02/2016
           || '     AND c.nversio   = ct.nversio(+)  AND (pcesion > 0 AND cgenera != 7 or cgenera is null)'
           || CHR(10)
           --FIN (22872 + 39214): AGG 16/02/2016
                     --FIN (22872 + 39214): AGG 09/02/2016
           || '   UNION                             ' || CHR(10)
           || '   SELECT c.scesrea,     c.ncesion, c.icesion, c.icapces, c.sseguro,   c.nversio, c.scontra, '
           || CHR(10)
           || '          c.ctramo,      c.sfacult, c.nriesgo, c.icomisi, c.scumulo,   c.cgarant, c.spleno,  '
           || CHR(10)
           || '          c.nsinies,     c.fefecto, c.fvencim, c.fcontab, c.pcesion,   c.sproces, c.cgenera, '
           || CHR(10)
           || '          c.fgenera,     c.fregula, c.fanulac, c.nmovimi, c.sidepag,   c.ipritarrea, '
           || CHR(10)
           || '          c.psobreprima, c.cdetces, c.ipleno,  c.icapaci, c.nmovigen,  c.iextrap, '
           || CHR(10)
           || '          c.iextrea,     c.nreemb,  c.nfact,   c.nlinea,  c.itarifrea, c.icomext, c.falta, '
           || CHR(10)
           || '          c.cusualt,     c.fmodifi, c.cusumod, c.ssegpol, c.npoliza,   c.ncertif, '
           || CHR(10)
           || '          ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, c.cgenera) movimiento, '
           || CHR(10) || '          null amparo, ct.tcontra contrato, ' || CHR(10)
           || '          case when c.ctrampa is null then ff_desvalorfijo(8002002, pac_md_common.f_get_cxtidioma, c.ctramo) else ff_desvalorfijo(8002001, pac_md_common.f_get_cxtidioma, c.ctrampa) end as ttramo, '
           || CHR(10)
           || '          SUM(c.pcesion) OVER (PARTITION BY c.cgarant) total_pcesion, '
           || CHR(10)
           || '          SUM(c.icesion) OVER (PARTITION BY c.cgarant) total_icesion, '
           || CHR(10)
           || '          SUM(c.icapces) OVER (PARTITION BY c.cgarant) total_icapces,  '
           || CHR(10)
           || '          DECODE(c.ctipomov , ''A'' , ''Autom¿co'', ''M'', ''Manual'') ctipomov, '
           || CHR(10)
           || '           c.ctrampa '
           || CHR(10) || '   FROM estcesionesrea c, contratos ct ' || CHR(10)
           --INICIO (22872 + 39214): AGG 09/02/2016
           || '   WHERE c.<psfield> = :nvalue2 ' || CHR(10)
           || '     AND c.cgarant   is null AND (pcesion > 0  AND c.cgenera != 7 or cgenera is null)'
                                                                                 --FIN (22872 + 39214): AGG 09/02/2016
           || CHR(10) || '     AND c.scontra   = ct.scontra(+) ' || CHR(10)
           || '     AND c.nversio   = ct.nversio(+)  ' || CHR(10)
           || 'ORDER BY sproces desc, CASE WHEN  ctrampa is null then ttramo END ASC, CASE WHEN  ctrampa is not null then ttramo END ASC ';
      vcesion        ob_iax_estcesionesrea;
      vtcesiones     t_iax_estcesionesrea := t_iax_estcesionesrea();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '<psfield> = ' || pnvalue;
      vobject        VARCHAR2(200) := 'pac_md_estcesionesrea.f_get_estcesionesrea';
      i              NUMBER := 0;
      mensajes       t_iax_mensajes;
      v_error        NUMBER;
   BEGIN
      -- Valid field parameter names
      --
      IF (psfield NOT IN(param_sseguro,
                         param_scesrea,
                         param_nsinies,
                         param_scumulo,
                         param_npoliza)) THEN
         raise_application_error(-20001, 'Invalid field name');
      END IF;

      IF (pcgenera = -1)
         OR(pcgenera IS NULL) THEN
         BEGIN
            vsqlsinmov := REPLACE(vsqlsinmov, '<psfield>', psfield);
            i := 0;
            v_error :=
               pac_md_log.f_log_consultas(vsqlsinmov,
                                          'PAC_MD_ESTCESIONESREA.F_GET_ESTCESIONESREA', 1, 4,
                                          mensajes);

            OPEN c FOR vsqlsinmov USING pnvalue, pnvalue;
         END;
      ELSE
         BEGIN
            vsql := REPLACE(vsql, '<psfield>', psfield);
            i := 0;
            v_error :=
               pac_md_log.f_log_consultas(vsql, 'PAC_MD_ESTCESIONESREA.F_GET_ESTCESIONESREA',
                                          1, 4, mensajes);

            OPEN c FOR vsql USING pnvalue, pnvalue;
         END;
      END IF;

      LOOP
         vcesion := ob_iax_estcesionesrea();

         FETCH c
          INTO vcesion.scesrea, vcesion.ncesion, vcesion.icesion, vcesion.icapces,
               vcesion.sseguro, vcesion.nversio, vcesion.scontra, vcesion.ctramo,
               vcesion.sfacult, vcesion.nriesgo, vcesion.icomisi, vcesion.scumulo,
               vcesion.cgarant, vcesion.spleno, vcesion.nsinies, vcesion.fefecto,
               vcesion.fvencim, vcesion.fcontab, vcesion.pcesion, vcesion.sproces,
               vcesion.cgenera, vcesion.fgenera, vcesion.fregula, vcesion.fanulac,
               vcesion.nmovimi, vcesion.sidepag, vcesion.ipritarrea, vcesion.psobreprima,
               vcesion.cdetces, vcesion.ipleno, vcesion.icapaci, vcesion.nmovigen,
               vcesion.iextrap, vcesion.iextrea, vcesion.nreemb, vcesion.nfact,
               vcesion.nlinea, vcesion.itarifrea, vcesion.icomext, vcesion.falta,
               vcesion.cusualt, vcesion.fmodifi, vcesion.cusumod, vcesion.ssegpol,
               vcesion.npoliza, vcesion.ncertif, vcesion.movimiento, vcesion.amparo,
               vcesion.contrato, vcesion.ttramo, vcesion.total_pcesion, vcesion.total_icesion,
               vcesion.total_icapces, vcesion.ctipomov, vcesion.ctrampa;

         EXIT WHEN c%NOTFOUND;
         i := i + 1;
         vtcesiones.EXTEND();
         vtcesiones(i) := vcesion;
      END LOOP;

      CLOSE c;

      IF (i = 0) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN vtcesiones;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'f_get_estcesionrea',
                     f_axis_literales(no_se_encontraron_datos) || ': ' || vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'f_get_estcesionrea',
                     SQLERRM || ': ' || vparam);
         RAISE;
   END f_get_estcesionesrea;
   
   --INI - AXIS 4105 - 05/06/2019 - AABG - PROCEDIMIENTO PARA OBTENER LAS CESIONES DE UNA POLIZA MEDIANTE EL MOVIMIENTO
  FUNCTION f_get_estcesionesreamovimiento(
      psfield VARCHAR2,
      pnvalue NUMBER,
      pcgenera IN NUMBER DEFAULT -1,
      pnmovimi NUMBER)
      RETURN t_iax_estcesionesrea IS
      TYPE cur_typ IS REF CURSOR;

      c              cur_typ;
      vsql           VARCHAR2(4096)
         :=   -- El UNION trae los que tienen cgarant diferente de null con los que tienen cgarant en null
           'SELECT * ' || CHR(10) || 'FROM ( ' || CHR(10)
           || '   SELECT c.scesrea,     c.ncesion, c.icesion, c.icapces, c.sseguro,   c.nversio, c.scontra, '
           || CHR(10)
           || '          c.ctramo,      c.sfacult, c.nriesgo, c.icomisi, c.scumulo,   c.cgarant, c.spleno,  '
           || CHR(10)
           || '          c.nsinies,     c.fefecto, c.fvencim, c.fcontab, c.pcesion,   c.sproces, c.cgenera, '
           || CHR(10)
           || '          c.fgenera,     c.fregula, c.fanulac, c.nmovimi, c.sidepag,   c.ipritarrea, '
           || CHR(10)
           || '          c.psobreprima, c.cdetces, c.ipleno,  c.icapaci, c.nmovigen,  c.iextrap, '
           || CHR(10)
           || '          c.iextrea,     c.nreemb,  c.nfact,   c.nlinea,  c.itarifrea, c.icomext, c.falta, '
           || CHR(10)
           || '          c.cusualt,     c.fmodifi, c.cusumod, c.ssegpol, c.npoliza,   c.ncertif, '
           || CHR(10)
           || '          ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, c.cgenera) movimiento, '
           || CHR(10) || '          g.tgarant amparo, ct.tcontra contrato, ' || CHR(10)
           || '          case when c.ctrampa is null then ff_desvalorfijo(8002002, pac_md_common.f_get_cxtidioma, c.ctramo) else ff_desvalorfijo(8002001, pac_md_common.f_get_cxtidioma, c.ctrampa) end as ttramo, '
           || CHR(10)
           || '          SUM(c.pcesion) OVER (PARTITION BY c.cgarant) total_pcesion, '
           || CHR(10)
           || '          SUM(c.icesion) OVER (PARTITION BY c.cgarant) total_icesion, '
           || CHR(10)
           || '          SUM(c.icapces) OVER (PARTITION BY c.cgarant) total_icapces,  '
           || CHR(10)
           || '    DECODE(c.ctipomov , ''A'' , ''Autom¿co'', ''M'', ''Manual'') ctipomov, '
           || CHR(10)
           || '           c.ctrampa '
           || CHR(10) || '   FROM estcesionesrea c, garangen g, contratos ct ' || CHR(10)
           || '   WHERE c.<psfield> = :nvalue1 ' || CHR(10)
           || '     AND c.cgarant   = g.cgarant(+) ' || CHR(10)
           || '     AND g.cidioma   = pac_md_common.f_get_cxtidioma ' || CHR(10)
           || '     AND c.scontra   = ct.scontra(+) ' || CHR(10)
           || '     AND c.nversio   = ct.nversio(+) ' || CHR(10)
           --INICIO (22872 + 39214): AGG 09/02/2016
           || '     AND (pcesion > 0 or cgenera is null)' || CHR(10)
           --FIN (22872 + 39214): AGG 09/02/2016
           || '     AND c.nmovigen   =  ' || pnmovimi || CHR(10)
           || '     AND (c.cgenera   =  ' || CHR(10) || pcgenera || CHR(10)           
           || '  AND c.cgenera != 7 or c.cgenera is null)    UNION' || CHR(10)
           || '   SELECT c.scesrea,     c.ncesion, c.icesion, c.icapces, c.sseguro,   c.nversio, c.scontra, '
           || CHR(10)
           || '          c.ctramo,      c.sfacult, c.nriesgo, c.icomisi, c.scumulo,   c.cgarant, c.spleno,  '
           || CHR(10)
           || '          c.nsinies,     c.fefecto, c.fvencim, c.fcontab, c.pcesion,   c.sproces, c.cgenera, '
           || CHR(10)
           || '          c.fgenera,     c.fregula, c.fanulac, c.nmovimi, c.sidepag,   c.ipritarrea, '
           || CHR(10)
           || '          c.psobreprima, c.cdetces, c.ipleno,  c.icapaci, c.nmovigen,  c.iextrap, '
           || CHR(10)
           || '          c.iextrea,     c.nreemb,  c.nfact,   c.nlinea,  c.itarifrea, c.icomext, c.falta, '
           || CHR(10)
           || '          c.cusualt,     c.fmodifi, c.cusumod, c.ssegpol, c.npoliza,   c.ncertif, '
           || CHR(10)
           || '          ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, c.cgenera) movimiento, '
           || CHR(10) || '          null amparo, ct.tcontra contrato, ' || CHR(10)
           || '          case when c.ctrampa is null then ff_desvalorfijo(8002002, pac_md_common.f_get_cxtidioma, c.ctramo) else ff_desvalorfijo(8002001, pac_md_common.f_get_cxtidioma, c.ctrampa) end as ttramo, '
           || CHR(10)
           || '          SUM(c.pcesion) OVER (PARTITION BY c.cgarant) total_pcesion, '
           || CHR(10)
           || '          SUM(c.icesion) OVER (PARTITION BY c.cgarant) total_icesion, '
           || CHR(10)
           || '          SUM(c.icapces) OVER (PARTITION BY c.cgarant) total_icapces,  '
           || CHR(10)
           || '          DECODE(c.ctipomov , ''A'' , ''Autom¿co'', ''M'', ''Manual'') ctipomov, '
           || CHR(10)
           || '           c.ctrampa '
           || CHR(10) || '   FROM estcesionesrea c, contratos ct ' || CHR(10)
           --INICIO (22872 + 39214): AGG 09/02/2016
           || '   WHERE c.<psfield> = :nvalue2 ' || CHR(10)
           --INICIO (22872 + 39214): AGG 16/02/2016
           || '     AND c.cgarant   is null AND (pcesion > 0 or cgenera is null) '
           --FIN (22872 + 39214): AGG 16/02/2016
           --FIN (22872 + 39214): AGG 09/02/2016
           || CHR(10) || '     AND c.scontra   = ct.scontra(+) ' || CHR(10)
           || '     AND c.nmovigen   =  ' || pnmovimi || CHR(10)
           || '     AND c.nversio   = ct.nversio(+)    AND (c.cgenera   =  ' || CHR(10)
           || pcgenera || CHR(10) || '  AND c.cgenera != 7 or c.cgenera is null) ) ' || CHR(10)
           || 'ORDER BY sproces desc, CASE WHEN  ctrampa is null then ttramo END ASC, CASE WHEN  ctrampa is not null then ttramo END ASC ';
      vsqlsinmov     VARCHAR2(4096)
         :=   -- El UNION trae los que tienen cgarant diferente de null con los que tienen cgarant en null
           'SELECT * ' || CHR(10) || 'FROM ( ' || CHR(10)
           || '   SELECT c.scesrea,     c.ncesion, c.icesion, c.icapces, c.sseguro,   c.nversio, c.scontra, '
           || CHR(10)
           || '          c.ctramo,      c.sfacult, c.nriesgo, c.icomisi, c.scumulo,   c.cgarant, c.spleno,  '
           || CHR(10)
           || '          c.nsinies,     c.fefecto, c.fvencim, c.fcontab, c.pcesion,   c.sproces, c.cgenera, '
           || CHR(10)
           || '          c.fgenera,     c.fregula, c.fanulac, c.nmovimi, c.sidepag,   c.ipritarrea, '
           || CHR(10)
           || '          c.psobreprima, c.cdetces, c.ipleno,  c.icapaci, c.nmovigen,  c.iextrap, '
           || CHR(10)
           || '          c.iextrea,     c.nreemb,  c.nfact,   c.nlinea,  c.itarifrea, c.icomext, c.falta, '
           || CHR(10)
           || '          c.cusualt,     c.fmodifi, c.cusumod, c.ssegpol, c.npoliza,   c.ncertif, '
           || CHR(10)
           || '          ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, c.cgenera) movimiento, '
           || CHR(10) || '          g.tgarant amparo, ct.tcontra contrato, ' || CHR(10)
           || '          case when c.ctrampa is null then ff_desvalorfijo(8002002, pac_md_common.f_get_cxtidioma, c.ctramo) else ff_desvalorfijo(8002001, pac_md_common.f_get_cxtidioma, c.ctrampa) end as ttramo, '
           || CHR(10)
           || '          SUM(c.pcesion) OVER (PARTITION BY c.cgarant) total_pcesion, '
           || CHR(10)
           || '          SUM(c.icesion) OVER (PARTITION BY c.cgarant) total_icesion, '
           || CHR(10)
           || '          SUM(c.icapces) OVER (PARTITION BY c.cgarant) total_icapces,  '
           || CHR(10)
           || '         DECODE(c.ctipomov , ''A'' , ''Autom¿co'', ''M'', ''Manual'') ctipomov, '
           || CHR(10)
           || '           c.ctrampa '
           || CHR(10) || '   FROM estcesionesrea c, garangen g, contratos ct ' || CHR(10)
           || '   WHERE c.<psfield> = :nvalue1 ' || CHR(10)
           || '     AND c.cgarant   = g.cgarant(+) ' || CHR(10)
           || '     AND g.cidioma   = pac_md_common.f_get_cxtidioma ' || CHR(10)
           || '     AND c.scontra   = ct.scontra(+) ' || CHR(10)
           || '     AND c.nmovigen   =  ' || pnmovimi || CHR(10)
           --INICIO (22872 + 39214): AGG 09/02/2016
           --INICIO (22872 + 39214): AGG 16/02/2016
           || '     AND c.nversio   = ct.nversio(+)  AND (pcesion > 0 AND cgenera != 7 or cgenera is null)'
           || CHR(10)
           --FIN (22872 + 39214): AGG 16/02/2016
                     --FIN (22872 + 39214): AGG 09/02/2016
           || '   UNION                             ' || CHR(10)
           || '   SELECT c.scesrea,     c.ncesion, c.icesion, c.icapces, c.sseguro,   c.nversio, c.scontra, '
           || CHR(10)
           || '          c.ctramo,      c.sfacult, c.nriesgo, c.icomisi, c.scumulo,   c.cgarant, c.spleno,  '
           || CHR(10)
           || '          c.nsinies,     c.fefecto, c.fvencim, c.fcontab, c.pcesion,   c.sproces, c.cgenera, '
           || CHR(10)
           || '          c.fgenera,     c.fregula, c.fanulac, c.nmovimi, c.sidepag,   c.ipritarrea, '
           || CHR(10)
           || '          c.psobreprima, c.cdetces, c.ipleno,  c.icapaci, c.nmovigen,  c.iextrap, '
           || CHR(10)
           || '          c.iextrea,     c.nreemb,  c.nfact,   c.nlinea,  c.itarifrea, c.icomext, c.falta, '
           || CHR(10)
           || '          c.cusualt,     c.fmodifi, c.cusumod, c.ssegpol, c.npoliza,   c.ncertif, '
           || CHR(10)
           || '          ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, c.cgenera) movimiento, '
           || CHR(10) || '          null amparo, ct.tcontra contrato, ' || CHR(10)
           || '          case when c.ctrampa is null then ff_desvalorfijo(8002002, pac_md_common.f_get_cxtidioma, c.ctramo) else ff_desvalorfijo(8002001, pac_md_common.f_get_cxtidioma, c.ctrampa) end as ttramo, '
           || CHR(10)
           || '          SUM(c.pcesion) OVER (PARTITION BY c.cgarant) total_pcesion, '
           || CHR(10)
           || '          SUM(c.icesion) OVER (PARTITION BY c.cgarant) total_icesion, '
           || CHR(10)
           || '          SUM(c.icapces) OVER (PARTITION BY c.cgarant) total_icapces,  '
           || CHR(10)
           || '          DECODE(c.ctipomov , ''A'' , ''Autom¿co'', ''M'', ''Manual'') ctipomov, '
           || CHR(10)
           || '           c.ctrampa '
           || CHR(10) || '   FROM estcesionesrea c, contratos ct ' || CHR(10)
           --INICIO (22872 + 39214): AGG 09/02/2016
           || '   WHERE c.<psfield> = :nvalue2 ' || CHR(10)
           || '     AND c.cgarant   is null AND (pcesion > 0  AND c.cgenera != 7 or cgenera is null)'
                                                                                 --FIN (22872 + 39214): AGG 09/02/2016
           || CHR(10) || '     AND c.scontra   = ct.scontra(+) ' || CHR(10)
           || '     AND c.nmovigen   =  ' || pnmovimi || CHR(10)
           || '     AND c.nversio   = ct.nversio(+)  ' || CHR(10)
           || 'ORDER BY sproces desc, CASE WHEN  ctrampa is null then ttramo END ASC, CASE WHEN  ctrampa is not null then ttramo END ASC ';
      vcesion        ob_iax_estcesionesrea;
      vtcesiones     t_iax_estcesionesrea := t_iax_estcesionesrea();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '<psfield> = ' || pnvalue;
      vobject        VARCHAR2(200) := 'pac_md_estcesionesrea.f_get_estcesionesrea';
      i              NUMBER := 0;
      mensajes       t_iax_mensajes;
      v_error        NUMBER;
   BEGIN
      -- Valid field parameter names
      --
      IF (psfield NOT IN(param_sseguro,
                         param_scesrea,
                         param_nsinies,
                         param_scumulo,
                         param_npoliza)) THEN
         raise_application_error(-20001, 'Invalid field name');
      END IF;

      IF (pcgenera = -1)
         OR(pcgenera IS NULL) THEN
         BEGIN
            vsqlsinmov := REPLACE(vsqlsinmov, '<psfield>', psfield);
            i := 0;
            v_error :=
               pac_md_log.f_log_consultas(vsqlsinmov,
                                          'PAC_MD_ESTCESIONESREA.F_GET_ESTCESIONESREA', 1, 4,
                                          mensajes);

            OPEN c FOR vsqlsinmov USING pnvalue, pnvalue;
         END;
      ELSE
         BEGIN
            vsql := REPLACE(vsql, '<psfield>', psfield);
            i := 0;
            v_error :=
               pac_md_log.f_log_consultas(vsql, 'PAC_MD_ESTCESIONESREA.F_GET_ESTCESIONESREA',
                                          1, 4, mensajes);

            OPEN c FOR vsql USING pnvalue, pnvalue;
         END;
      END IF;

      LOOP
         vcesion := ob_iax_estcesionesrea();

         FETCH c
          INTO vcesion.scesrea, vcesion.ncesion, vcesion.icesion, vcesion.icapces,
               vcesion.sseguro, vcesion.nversio, vcesion.scontra, vcesion.ctramo,
               vcesion.sfacult, vcesion.nriesgo, vcesion.icomisi, vcesion.scumulo,
               vcesion.cgarant, vcesion.spleno, vcesion.nsinies, vcesion.fefecto,
               vcesion.fvencim, vcesion.fcontab, vcesion.pcesion, vcesion.sproces,
               vcesion.cgenera, vcesion.fgenera, vcesion.fregula, vcesion.fanulac,
               vcesion.nmovimi, vcesion.sidepag, vcesion.ipritarrea, vcesion.psobreprima,
               vcesion.cdetces, vcesion.ipleno, vcesion.icapaci, vcesion.nmovigen,
               vcesion.iextrap, vcesion.iextrea, vcesion.nreemb, vcesion.nfact,
               vcesion.nlinea, vcesion.itarifrea, vcesion.icomext, vcesion.falta,
               vcesion.cusualt, vcesion.fmodifi, vcesion.cusumod, vcesion.ssegpol,
               vcesion.npoliza, vcesion.ncertif, vcesion.movimiento, vcesion.amparo,
               vcesion.contrato, vcesion.ttramo, vcesion.total_pcesion, vcesion.total_icesion,
               vcesion.total_icapces, vcesion.ctipomov, vcesion.ctrampa;

         EXIT WHEN c%NOTFOUND;
         i := i + 1;
         vtcesiones.EXTEND();
         vtcesiones(i) := vcesion;
      END LOOP;

      CLOSE c;

      IF (i = 0) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN vtcesiones;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'f_get_estcesionrea',
                     f_axis_literales(no_se_encontraron_datos) || ': ' || vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'f_get_estcesionrea',
                     SQLERRM || ': ' || vparam);
         RAISE;
   END f_get_estcesionesreamovimiento;
   
   FUNCTION f_get_estcesionesreamovpol(pnpoliza NUMBER, pcgenera NUMBER, pnmovimi NUMBER)
      RETURN t_iax_estcesionesrea IS
   BEGIN
      RETURN f_get_estcesionesreamovimiento(param_npoliza, pnpoliza, pcgenera, pnmovimi);
   END f_get_estcesionesreamovpol;
   
   --FIN - AXIS 4105 - 05/06/2019 - AABG - PROCEDIMIENTO PARA OBTENER LAS CESIONES DE UNA POLIZA MEDIANTE EL MOVIMIENTO

-------------------------------------------------------------------
-- f_get_estcesionesrea, f_get_estcesionrea
-------------------------------------------------------------------
   FUNCTION f_get_estcesionesrea(psseguro NUMBER, pcgenera NUMBER)
      RETURN t_iax_estcesionesrea IS
   BEGIN
      RETURN f_get_estcesionesrea(param_sseguro, psseguro, pcgenera);
   END f_get_estcesionesrea;

   FUNCTION f_get_estcesionrea(psfield VARCHAR2, pnvalue NUMBER, pcgenera NUMBER)
      RETURN ob_iax_estcesionesrea IS
      vtcesiones     t_iax_estcesionesrea := f_get_estcesionesrea(psfield, pnvalue, pcgenera);
   BEGIN
      IF (vtcesiones IS NOT NULL)
         AND(vtcesiones.COUNT > 0) THEN
         RETURN vtcesiones(1);
      END IF;

      RETURN NULL;
   END f_get_estcesionrea;

   FUNCTION f_get_estcesionrea(pscesrea estcesionesrea.scesrea%TYPE, pcgenera NUMBER)
      RETURN ob_iax_estcesionesrea IS
   BEGIN
      RETURN f_get_estcesionrea(param_scesrea, pscesrea, pcgenera);
   END f_get_estcesionrea;

-------------------------------------------------------------------
-- f_get_estcesionesreasinies, f_get_estcesionreasinies
-------------------------------------------------------------------
   FUNCTION f_get_estcesionesreasinies(pnsinies estcesionesrea.nsinies%TYPE)
      RETURN t_iax_estcesionesrea IS
   BEGIN
      RETURN f_get_estcesionesrea(param_nsinies, pnsinies);
   END f_get_estcesionesreasinies;

   FUNCTION f_get_estcesionreasinies(pnsinies estcesionesrea.nsinies%TYPE)
      RETURN ob_iax_estcesionesrea IS
   BEGIN
      RETURN f_get_estcesionrea(param_nsinies, pnsinies);
   END f_get_estcesionreasinies;

-------------------------------------------------------------------
-- f_get_estcesionesreacum
-------------------------------------------------------------------
   FUNCTION f_get_estcesionesreacum(pscumulo NUMBER, pcgenera NUMBER)
      RETURN t_iax_estcesionesrea IS
   BEGIN
      RETURN f_get_estcesionesrea(param_scumulo, pscumulo, pcgenera);
   END f_get_estcesionesreacum;

-------------------------------------------------------------------
-- f_get_estcesionesreapolizas, f_get_estcesionesreapoliza
-------------------------------------------------------------------
   FUNCTION f_get_estcesionesreapolizas(pnpoliza NUMBER, pcgenera NUMBER)
      RETURN t_iax_estcesionesrea IS
   BEGIN
      RETURN f_get_estcesionesrea(param_npoliza, pnpoliza, pcgenera);
   END f_get_estcesionesreapolizas;

   FUNCTION f_get_estcesionreapoliza(pnpoliza estcesionesrea.npoliza%TYPE)
      RETURN ob_iax_estcesionesrea IS
   BEGIN
      RETURN f_get_estcesionrea(param_npoliza, pnpoliza);
   END f_get_estcesionreapoliza;

   FUNCTION f_set_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pncesion estcesionesrea.ncesion%TYPE,
      picesion estcesionesrea.icesion%TYPE,
      picapces estcesionesrea.icapces%TYPE,
      psseguro estcesionesrea.sseguro%TYPE,
      pssegpol estcesionesrea.ssegpol%TYPE,
      pnpoliza estcesionesrea.npoliza%TYPE,
      pncertif estcesionesrea.ncertif%TYPE,
      pnversio estcesionesrea.nversio%TYPE,
      pscontra estcesionesrea.scontra%TYPE,
      pctramo estcesionesrea.ctramo%TYPE,
      psfacult estcesionesrea.sfacult%TYPE,
      pnriesgo estcesionesrea.nriesgo%TYPE,
      picomisi estcesionesrea.icomisi%TYPE,
      pscumulo estcesionesrea.scumulo%TYPE,
      pgarant estcesionesrea.cgarant%TYPE,
      pspleno estcesionesrea.spleno%TYPE,
      pnsinies estcesionesrea.nsinies%TYPE,
      pfefecto estcesionesrea.fefecto%TYPE,
      pfvencim estcesionesrea.fvencim%TYPE,
      pfcontab estcesionesrea.fcontab%TYPE,
      ppcesion estcesionesrea.pcesion%TYPE,
      psproces estcesionesrea.sproces%TYPE,
      pcgenera estcesionesrea.cgenera%TYPE,
      pfgenera estcesionesrea.fgenera%TYPE,
      pfregula estcesionesrea.fregula%TYPE,
      pfanulac estcesionesrea.fanulac%TYPE,
      pnmovimi estcesionesrea.nmovimi%TYPE,
      psidepag estcesionesrea.sidepag%TYPE,
      pipritarrea estcesionesrea.ipritarrea%TYPE,
      ppsobreprima estcesionesrea.psobreprima%TYPE,
      pcdetces estcesionesrea.cdetces%TYPE,
      pipleno estcesionesrea.ipleno%TYPE,
      picapaci estcesionesrea.icapaci%TYPE,
      nmovigen estcesionesrea.nmovigen%TYPE,
      piextrap estcesionesrea.iextrap%TYPE,
      iextrea estcesionesrea.iextrea%TYPE,
      pnreemb estcesionesrea.nreemb%TYPE,
      pnfact estcesionesrea.nfact%TYPE,
      pnlinea estcesionesrea.nlinea%TYPE,
      pitarifrea estcesionesrea.itarifrea%TYPE,
      picomext estcesionesrea.icomext%TYPE)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      w_scesreaest   NUMBER;
      vparam         VARCHAR2(2000)
         := 'pscesrea: ' || pscesrea || 'pncesion: ' || pncesion || 'PICESION: ' || picesion
            || 'PICAPCES: ' || picapces || 'PSSEGURO: ' || psseguro || 'PSSEGPOL: '
            || pssegpol || 'PNPOLIZA: ' || pnpoliza || 'PNCERTIF: ' || pncertif
            || 'PNVERSIO: ' || pnversio || 'PSCONTRA: ' || pscontra || 'PCTRAMO:  ' || pctramo
            || 'PSFACULT: ' || psfacult || 'PNRIESGO: ' || pnriesgo || 'PICOMISI: '
            || picomisi || 'PSCUMULO: ' || pscumulo || 'PGARANT:  ' || pgarant || 'PSPLENO:  '
            || pspleno || 'PNSINIES: ' || pnsinies || 'PFEFECTO: ' || pfefecto || 'PFVENCIM: '
            || pfvencim || 'PFCONTAB: ' || pfcontab || 'PPCESION: ' || ppcesion
            || 'PSPROCES: ' || psproces || 'PCGENERA: ' || pcgenera || 'PFGENERA: '
            || pfgenera || 'PFREGULA: ' || pfregula || 'PFANULAC: ' || pfanulac
            || 'PNMOVIMI: ' || pnmovimi || 'PSIDEPAG: ' || psidepag || 'PIPRITARREA: '
            || pipritarrea || 'PPSOBREPRIMA: ' || ppsobreprima || 'PCDETCES: ' || pcdetces
            || 'PIPLENO: ' || pipleno || 'PICAPACI: ' || picapaci || 'NMOVIGEN: ' || nmovigen
            || 'PIEXTRAP: ' || piextrap || 'IEXTREA: ' || iextrea || 'PNREEMB: ' || pnreemb
            || 'PNFACT: ' || pnfact || 'PNLINEA: ' || pnlinea || 'PITARIFREA: ' || pitarifrea
            || 'PICOMEXT: ' || picomext;
      vobject        VARCHAR2(200) := 'pac_md_estcesionrea.f_set_estcesionesrea';
      vnmovimi       estcesionesrea.nmovimi%TYPE := pnmovimi;
   BEGIN
      IF (pncesion IS NULL
          OR picesion IS NULL
          OR picapces IS NULL) THEN
         vnumerr := faltan_parametros;
         RAISE param_error;
      END IF;

      vpasexec := 2;

      IF pscesrea IS NULL THEN
         SELECT scesrea.NEXTVAL
           INTO w_scesreaest
           FROM DUAL;
      ELSE
         w_scesreaest := pscesrea;
      END IF;

      vpasexec := 3;

      -- Tomar el maximo movimiento para el seguro para asignar el movimiento actual
      --
      SELECT MAX(nmovimi)
        INTO vnmovimi
        FROM estcesionesrea
       WHERE ssegpol = pssegpol;

      vnmovimi := NVL(vnmovimi, 0) + 1;

      INSERT INTO estcesionesrea
                  (scesrea, ncesion, icesion, icapces, sseguro, ssegpol, npoliza,
                   ncertif, nversio, scontra, ctramo, sfacult, nriesgo, icomisi,
                   scumulo, cgarant, spleno, nsinies, fefecto, fvencim, fcontab,
                   pcesion, sproces, cgenera, fgenera, fregula, fanulac, nmovimi, sidepag,
                   ipritarrea, psobreprima, cdetces, ipleno, icapaci, nmovigen, iextrap,
                   iextrea, nreemb, nfact, nlinea, itarifrea, icomext, falta, cusualt,
                   ctipomov)
           VALUES (w_scesreaest, pncesion, picesion, picapces, psseguro, pssegpol, pnpoliza,
                   pncertif, pnversio, pscontra, pctramo, psfacult, pnriesgo, picomisi,
                   pscumulo, pgarant, pspleno, pnsinies, pfefecto, pfvencim, pfcontab,
                   ppcesion, psproces, NULL, SYSDATE, pfregula, pfanulac, vnmovimi,   --ozea
                                                                                   psidepag,
                   pipritarrea, ppsobreprima, pcdetces, pipleno, picapaci, nmovigen, piextrap,
                   iextrea, pnreemb, pnfact, pnlinea, pitarifrea, picomext, f_sysdate, f_user,
                   'M');

      RETURN ok;
   EXCEPTION
      WHEN param_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec,
                     'f_set_estcesionesrea', f_axis_literales(vnumerr) || ': ' || vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec,
                     'f_set_estcesionesrea', SQLERRM || ': ' || vparam);
         RETURN error_no_controlado;
   END f_set_estcesionesrea;

   FUNCTION f_del_estcesionesrea(
      pscesrea NUMBER DEFAULT -1,
      pssegpol NUMBER DEFAULT -1,
      psseguro NUMBER DEFAULT -1)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(20) := 'pscesrea: ';
   BEGIN
      IF pscesrea IS NULL THEN
         vnumerr := campo_obligatorio;
         RAISE param_error;
      END IF;

      IF pscesrea <> -1 THEN
         DELETE      estcesionesrea
               WHERE scesrea = pscesrea;
      ELSIF pssegpol <> -1 THEN
         DELETE      estcesionesrea
               WHERE ssegpol = pssegpol;
      ELSIF psseguro <> -1 THEN
         DELETE      estcesionesrea
               WHERE sseguro = psseguro;
      END IF;

      RETURN ok;
   EXCEPTION
      WHEN param_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec,
                     'f_del_estcesionesrea', f_axis_literales(vnumerr) || ': ' || vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA.f_del_estcesionesrea', 1,
                     'pscesrea = ' || pscesrea, SQLERRM || ': ' || vparam);
         RETURN error_no_controlado;
   END f_del_estcesionesrea;

------------------------------------------------------------------
-- f_update_estcesionesrea: Actualiza tramo
------------------------------------------------------------------
   FUNCTION f_update_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pctramo estcesionesrea.ctramo%TYPE)
      RETURN NUMBER IS
      vpasexec       INTEGER := 1;
      vparam         VARCHAR2(100) := ' pscesrea: ' || pscesrea || ', pctramo: ' || pctramo;
   BEGIN

	  IF  pctramo < 11 THEN
        UPDATE estcesionesrea
             SET ctramo = pctramo
           WHERE scesrea = pscesrea;
      ELSE
        UPDATE estcesionesrea
             SET ctramo = 0,
                 ctrampa = pctramo - 10
           WHERE scesrea = pscesrea;
      END IF;

      RETURN ok;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec,
                     'f_update_estcesionesrea_tramo', SQLERRM || ': ' || vparam);
         RETURN error_no_controlado;
   END f_update_estcesionesrea;

------------------------------------------------------------------
-- f_update_estcesionesrea: Valida y actualiza fechas
------------------------------------------------------------------
   FUNCTION f_update_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,   -- Primary key en estcesionesrea
      pssegpol estcesionesrea.ssegpol%TYPE,   -- Identificador del seguro
      pcgarant estcesionesrea.cgarant%TYPE,   -- Garant¿a
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE)   -- Nueva fecha de vencimiento
      RETURN NUMBER IS
      vres           NUMBER;
      vpasexec       INTEGER := 1;
      vparam         VARCHAR2(100)
         := ' pscesrea: ' || pscesrea || ', pssegpol: ' || pssegpol || ', pfefecto: '
            || pfefecto || ', pfvencimiento: ' || pfvencimiento;
   BEGIN
      vres := validafechas(pscesrea, pssegpol, pcgarant, pfefecto, pfvencimiento);

      IF (vres = ok) THEN
         UPDATE estcesionesrea
            SET fefecto = pfefecto,
                fvencim = pfvencimiento
          WHERE scesrea = pscesrea
            AND ssegpol = pssegpol
            AND cgarant = cgarant;
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec,
                     'f_update_estcesionesrea', SQLERRM || ': ' || vparam);
         RETURN error_no_controlado;
   END f_update_estcesionesrea;

----------------------------------------------------------------------
-- Valida fechas en cada tramo para confirmar si se permite el update.
----------------------------------------------------------------------
   FUNCTION validafechas(
      pscesrea estcesionesrea.scesrea%TYPE,   -- Primary key en estcesionesrea
      pssegpol estcesionesrea.ssegpol%TYPE,   -- Identificador del seguro
      pcgarant estcesionesrea.cgarant%TYPE,   -- Garant¿a
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE)   -- Nueva fecha de vencimiento
      RETURN NUMBER IS
      vcount         NUMBER := 0;
      vsegpol        seguros.sseguro%TYPE;
      vseg_sseguro   seguros.sseguro%TYPE;
      vseg_fefecto   seguros.fefecto%TYPE;
      vseg_fvencim   seguros.fvencim%TYPE;
      vmin_fefecto   estcesionesrea.fefecto%TYPE;
      vmax_fvencim   estcesionesrea.fvencim%TYPE;
      vnumerr        NUMBER := 0;
      vpasexec       INTEGER := 0;
      vtotalmeses    INTEGER;
      vmes_cubierto  BOOLEAN;
      vmes           NUMBER;
      vdesde         NUMBER;
      vhasta         NUMBER;
      vcnt           NUMBER;
      vparam         VARCHAR2(128)
         := ' pscesrea: ' || pscesrea || ', pssegpol: ' || pssegpol || ', pfefecto: '
            || pfefecto || ', pfvencimiento: ' || pfvencimiento;

      CURSOR c_seguro IS
         SELECT *
           FROM seguros
          WHERE sseguro = pssegpol;

      CURSOR c_estcesionesrea_01 IS
         SELECT COUNT(*) cnt, MIN(fefecto) fefecto, MAX(fvencim) fvencim
           FROM estcesionesrea
          WHERE ssegpol = pssegpol
            AND cgarant = pcgarant
            AND fanulac IS NULL
            AND cgenera != 7;

      -- Cesiones de la garant¿a para seguro
      --
      CURSOR c_estcesionesrea_02 IS
         SELECT   scesrea, fefecto, fvencim
             FROM estcesionesrea
            WHERE ssegpol = pssegpol
              AND cgarant = pcgarant
              AND fanulac IS NULL
              AND cgenera != 7
         ORDER BY fefecto;

      CURSOR c_meses(d1 DATE, d2 DATE) IS   -- Dadas dos fechas retorna lista de meses en formato YYYYMM
         WITH t AS
              (SELECT d1 start_date, d2 end_date
                 FROM DUAL)
         SELECT     TO_CHAR(ADD_MONTHS(TRUNC(start_date, 'mm'), LEVEL - 1), 'yyyy')
                    || TO_CHAR(ADD_MONTHS(TRUNC(start_date, 'mm'), LEVEL - 1), 'mm') mes
               FROM t
         CONNECT BY TRUNC(end_date, 'mm') >= ADD_MONTHS(TRUNC(start_date, 'mm'), LEVEL - 1);
   BEGIN
      vpasexec := 1;

      BEGIN
         SELECT sseguro, fefecto, fvencim
           INTO vseg_sseguro, vseg_fefecto, vseg_fvencim
           FROM seguros
          WHERE sseguro = pssegpol;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vnumerr := seguro_no_existe;
            p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec, 'validaFechas',
                        f_axis_literales(vnumerr) || ': ' || vparam);
            RETURN vnumerr;
      END;

      FOR p1 IN c_estcesionesrea_01 LOOP
         vcnt := p1.cnt;
         vmin_fefecto := p1.fefecto;
         vmax_fvencim := p1.fvencim;
      END LOOP;

      -- V1. Siempre deber¿ existir una cesi¿n con fecha inicial de efecto de la p¿liza.
      --
      IF (pfefecto < vmin_fefecto) THEN
         vmin_fefecto := pfefecto;
      END IF;

      IF (TRUNC(vmin_fefecto) != TRUNC(vseg_fefecto)) THEN
         RETURN 9908413;   -- Debe existir una cesi¿n con fecha inicial igual a la fecha de efecto de la p¿liza
      END IF;

      -- V2. Fechas deben estar dentro de la vigencia de la cesi¿n inicial
      --
      IF ((TRUNC(pfefecto) < TRUNC(vmin_fefecto))
          OR(TRUNC(pfvencimiento) > TRUNC(vmax_fvencim))) THEN
         RETURN 9908412;   -- Fechas indicadas estan por fuera de la vigencia de la cesi¿n
      END IF;

      IF (vcnt = 1) THEN   -- Si solo hay una cesi¿n
         IF (pfefecto > vmin_fefecto) THEN
            RETURN 9908416;   -- Cambio de fechas inv¿lido. Debe ingresar los tramos necesarios hasta la fecha de vencimiento
         END IF;

         IF (pfvencimiento < vmax_fvencim) THEN
            RETURN 9908416;   -- Cambio de fechas inv¿lido. Debe ingresar los tramos necesarios hasta la fecha de vencimiento
         END IF;
      END IF;

      IF (pfefecto > vmax_fvencim) THEN
         RETURN 9908416;   -- Cambio de fechas inv¿lido. Debe ingresar los tramos necesarios hasta la fecha de vencimiento
      END IF;

      -- V3. Intervalos no cubiertos. Si la fecha de efecto del tramo es
      -- mayor que la fecha de efecto o menor que la fecha de vencimiento
      -- de la cesi¿n debemos revisar que exista al menos un tramo que
      -- cubra esos meses.
      --
      IF (TRUNC(pfefecto) > TRUNC(vmin_fefecto)) THEN
         -- Para el espacio que queda deben existir tramos que lo cubran.
         -- Debe existir al menos un tramo que cubra cada mes.  Si existe
         -- alg¿n mes no cubierto por alg¿n
         -- tramo se genera error.  Los tramos contra los que se compara
         -- son los tramos diferentes al de pscesrea pero que pertenece
         -- al mismo seguro.
         --
         FOR p1 IN c_meses(TRUNC(vmin_fefecto), TRUNC(pfefecto)) LOOP   -- Rango de meses para revisar si esta cubierto por algun tramo
            vmes := p1.mes;
            vmes_cubierto := FALSE;

            FOR p1 IN c_estcesionesrea_02 LOOP   -- Revisar todos los tramos para asegurar que este cubierto
               vdesde := TO_CHAR(p1.fefecto, 'YYYYMM');
               vhasta := TO_CHAR(p1.fvencim, 'YYYYMM');

               IF (p1.scesrea = pscesrea) THEN   -- Si tomamos las del cursor siempre estara cubierto. Por eso
                  vdesde := TO_CHAR(pfefecto, 'YYYYMM');   -- debemos actualizar temporalmente como quedar¿a y revisar si
               END IF;   -- quedar¿a cubierto para definir si se debe aceptar.

               IF (vmes BETWEEN vdesde AND vhasta) THEN
                  vmes_cubierto := TRUE;
                  EXIT;   -- Salir del loop p1.  No es necesario mirar m¿s tramos.
               END IF;
            END LOOP;

            -- Si al menos un mes no esta cubierto por alguno de los tramos
            -- retornar error.
            --
            IF (NOT vmes_cubierto) THEN
               RETURN 9908416;
            END IF;
         END LOOP;
      ELSE
         -- V2b. Intervalos no cubiertos. Si la fecha de vencimiento es menor que la fecha
         -- de vencimiento del seguro debemos revisar los otros tramos para asegurar
         -- que no haya meses sin cubrir.
         --
         IF (TRUNC(pfvencimiento) < TRUNC(vmax_fvencim)) THEN
            -- Para el espacio que queda deben existir tramos que lo cubran.
            -- Para lograr esto debe existir al menos un tramo que cubra
            -- cada mes.  Si existe alg¿n mes no cubierto por alg¿n
            -- tramo se genera error.  Los tramos contra los que se compara
            -- son los tramos diferentes al de pscesrea pero que pertenece
            -- al mismo seguro.
            --
            FOR p1 IN c_meses(TRUNC(pfvencimiento), TRUNC(vmax_fvencim)) LOOP
               vmes := p1.mes;
               vmes_cubierto := FALSE;

               FOR p1 IN c_estcesionesrea_02 LOOP
                  vdesde := TO_CHAR(p1.fefecto, 'YYYYMM');
                  vhasta := TO_CHAR(p1.fvencim, 'YYYYMM');

                  IF (p1.scesrea = pscesrea) THEN   -- Si tomamos las del cursor siempre estara cubierto. Por eso
                     vhasta := TO_CHAR(pfvencimiento, 'YYYYMM');   -- debemos actualizar temporalmente como quedar¿a y revisar si
                  END IF;

                  IF (vmes BETWEEN vdesde AND vhasta) THEN
                     vmes_cubierto := TRUE;
                     EXIT;   -- Salir del loop p1.  No es necesario mirar m¿s tramos.
                  END IF;
               END LOOP;

               -- Si al menos un mes no esta cubierto por alguno de los tramos
               -- retornar error.
               --
               IF (NOT vmes_cubierto) THEN
                  RETURN 9908416;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN ok;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec, 'validaFechas',
                     SQLERRM || ': ' || vparam);
         RETURN error_no_controlado;
   END validafechas;

------------------------------------------------------------------
-- f_update_estcesionesrea: Valida y actualiza totales
------------------------------------------------------------------
  FUNCTION f_update_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pssegpol estcesionesrea.ssegpol%TYPE,
      picesion estcesionesrea.icesion%TYPE,
      picapces estcesionesrea.icapces%TYPE,
      ppcesion estcesionesrea.pcesion%TYPE)
      RETURN NUMBER IS
      vparam         VARCHAR2(500)
         := 'pscesrea: ' || pscesrea || ', pssegpol: ' || pssegpol || ', picesion: '
            || picesion || ', picapces: ' || picapces || ', ppcesion: ' || ppcesion;
      vn_tot_pcesion NUMBER := 0;   -- Totales temporales en estcesionesrea
      vn_tot_icesion NUMBER := 0;
      vn_tot_icapces NUMBER := 0;
      vn_tot_real_pcesion NUMBER := 0;   -- Totales reales en cesionesrea
      vn_tot_real_icesion NUMBER := 0;
      vn_tot_real_icapces NUMBER := 0;
      vgarant        estcesionesrea.cgarant%TYPE;
      vpcesion       estcesionesrea.pcesion%TYPE;
      vicapces       estcesionesrea.icapces%TYPE;
      vicesion       estcesionesrea.icesion%TYPE;
      vpcesion2      estcesionesrea.pcesion%TYPE;
      vicapces2      estcesionesrea.icapces%TYPE;
      vicesion2      estcesionesrea.icesion%TYPE;
      vcvidaga       codicontratos.cvidaga%TYPE;
      vpasexec       NUMBER := 0;
      vresult        NUMBER := 0;
      v_cuantos      NUMBER := 0;
      bndupd         NUMBER := 0;

      CURSOR c_update_estcesionesrea IS
         SELECT scesrea, ssegpol, icesion, icapces, pcesion, cgarant, scontra,
                COUNT(*) OVER(PARTITION BY cgarant) cnt,
                SUM(pcesion) OVER(PARTITION BY cgarant) total_pcesion,
                SUM(icesion) OVER(PARTITION BY cgarant) total_icesion,
                SUM(icapces) OVER(PARTITION BY cgarant) total_icapces
           FROM estcesionesrea
          WHERE ssegpol = pssegpol
            AND fanulac IS NULL
            AND(cgenera != 7
                OR cgenera IS NULL);

      CURSOR c_totales_cesionesreagarantia IS   -- Cursor totales cuando trae garantia (cvidaga = 2)
        --INICIO (21901 + 37294): AGG 11/02/2016
         SELECT trunc(SUM(pcesion)) total_pcesion, SUM(icesion) total_icesion,
         --FIN (21901 + 37294): AGG 11/02/2016
                SUM(icapces) total_icapces
           FROM cesionesrea
          WHERE sseguro = pssegpol
      --  AND cgarant = pcgarant 
            AND fanulac IS NULL
            AND(cgenera != 7
                OR cgenera IS NULL);

      CURSOR c_totales_cesionesrea IS   -- Cursor totales cuando  no trae  informada garantia (cvidaga = 1)
         --INICIO (21901 + 37294): AGG 11/02/2016
         SELECT trunc(SUM(pcesion)) total_pcesion, SUM(icesion) total_icesion,
         --FIN (21901 + 37294): AGG 11/02/2016
                SUM(icapces) total_icapces
           FROM cesionesrea
          WHERE sseguro = pssegpol
            AND fanulac IS NULL  AND  (icesion>=0 and icapces>=0) and nmovimi=1
            AND(cgenera != 7
                OR cgenera IS NULL);
   BEGIN
      IF (ppcesion < 0
          OR picesion < 0
          OR picapces < 0) THEN
         RETURN 9902884;   -- Controlar valores negativos
      END IF;

      vpasexec := 1;

      FOR p1 IN c_update_estcesionesrea LOOP
      
           SELECT c.cvidaga
           INTO vcvidaga
           FROM codicontratos c
          WHERE c.scontra = p1.scontra;

         IF (vgarant IS NULL
             OR vgarant != p1.cgarant) THEN   -- Cada vez que cambie el cgarant, establecer nuevo vgarant
            vgarant := p1.cgarant;

            IF (vcvidaga = 1) THEN   -- No se toma los totales por garantia
              FOR q1 IN c_totales_cesionesrea LOOP   -- Calcular valores reales desde CESIONESREA.  El total del
                  vn_tot_real_pcesion := q1.total_pcesion;   -- porcentaje debe ser igual a 100%.
                  vn_tot_real_icesion := q1.total_icesion;
                  vn_tot_real_icapces := q1.total_icapces;
               END LOOP;
            END IF;

            IF (vcvidaga = 2) THEN   -- Se toma el total por garantia (p1.cgarant)
                 FOR q1 IN c_totales_cesionesreagarantia LOOP   -- Calcular valores reales desde CESIONESREA.  El total del
                  vn_tot_real_pcesion := q1.total_pcesion;   -- porcentaje debe ser igual a 100%.
                  vn_tot_real_icesion := q1.total_icesion;
                  vn_tot_real_icapces := q1.total_icapces;
               END LOOP;
            END IF;
            
                    IF vn_tot_real_pcesion<100 THEN
                     
                      SELECT trunc(SUM(pcesion)),SUM(icesion) total_icesion,
                           SUM(icapces) total_icapces 
                        INTO vn_tot_real_pcesion,vn_tot_real_icesion,vn_tot_real_icapces
                           FROM cesionesrea
                          WHERE sseguro = pssegpol
                            AND fanulac IS NULL  
                            AND(cgenera != 7
                      OR cgenera IS NULL);                    
                    
                    END IF;
                
              
            IF (vn_tot_real_pcesion != 100) THEN
               RETURN 9902398;   -- Total de porcentajes vigente diferente de 100.  No es posible continuar
            END IF;
         END IF;

         IF p1.scesrea = pscesrea THEN         
        
         IF(p1.pcesion>0) THEN
             IF (p1.pcesion != ppcesion) THEN   -- Si cambi¿ el valor del porcentaje
               vn_tot_pcesion := (p1.total_pcesion - p1.pcesion) + ppcesion;   -- Calcular nuevo total de porcentaje

               IF ((p1.cnt != 2)
                   AND   -- Si el total de registros es diferente de dos, realizar validaci¿n
                      (vn_tot_pcesion > vn_tot_real_pcesion)) THEN   -- El nuevo valor del total del porcentaje debe ser <= 100
                  RETURN 9908461;   -- No se permite el valor del nuevo porcentaje pues causa que se pase del total para la garant¿a
               END IF;
               
            END IF;
                        
               vpcesion := ppcesion;   -- Porcentaje esta bien
               vicesion := vn_tot_real_icesion * vpcesion / 100;   -- Nuevo icesion
               vicapces := vn_tot_real_icapces * vpcesion / 100;   -- Nuevo icapces

               IF (p1.cnt = 2) THEN   -- Si el total de registros es dos, realizar calculo autom¿tico y tambi¿n validar
                  IF ((vpcesion > 100)
                      OR(vpcesion < 0)) THEN
                     RETURN 9908461;   -- No se permite el valor del nuevo porcentaje pues causa que se pase del total para la garant¿a
                  END IF;
               END IF;
            ELSE            
            
               IF (p1.icesion != picesion) THEN   -- Cambi¿ el valor de la cesi¿n, debemos cambiar porcentaje y valor del importe capital
                  vn_tot_icesion := (p1.total_icesion - p1.icesion) +   -- Calcular nuevo total de cesion
                                                                     picesion;

                  IF ((p1.cnt != 2)
                      AND   -- Si el total de registros es diferente de dos, realizar validaci¿n
                         (vn_tot_icesion > vn_tot_real_icesion)) THEN   -- El nuevo total de cesi¿n debe ser menor o igual al total real de cesionesrea
                     RETURN 9908463;   -- No se permite valor de cesi¿n pues causa que se pase del total real para la cesion
                  END IF;

                  vicesion :=picesion;   -- Icesion esta bien
                  vpcesion := (vicesion / vn_tot_real_icesion) * 100;   -- Nuevo porcentaje
                  vicapces := vn_tot_real_icapces * vpcesion / 100;   -- Nuevo icapces 

                  IF (p1.cnt = 2) THEN   -- Si el total de registros es dos, realizar calculo autom¿tico y tambi¿n validar
                     IF ((vpcesion > 100)
                         OR(vpcesion < 0)) THEN
                        RETURN 9908463;   -- No se permite valor de cesi¿n pues causa que se pase del total real para la cesion
                     END IF;
                  END IF;
               ELSIF(p1.icapces != picapces) THEN   -- Cambi¿ el valor del importe capital, debemos cambiar porcentaje y valor de la cesi¿n
                  vn_tot_icapces := (p1.total_icapces - p1.icapces) +   -- Calcular nuevo total de capital
                                                                     picapces;

                  IF ((p1.cnt != 2)
                      AND   -- Si el total de registros es diferente de dos, realizar validaci¿n
                         (vn_tot_icapces > vn_tot_real_icapces)) THEN   -- El nuevo total de importe debe ser menor o igual al total real
                     RETURN 9908462;   -- No se permite valor de importe pues causa que se pase del total real para el importe
                  END IF;
                
              
                  vicapces := vn_tot_real_icapces * ppcesion / 100;    -- Icapces esta bien picapces 
                  vpcesion := (vicapces / vn_tot_real_icapces) * 100;   -- Nuevo porcentaje
                  vicesion := vn_tot_real_icesion * vpcesion / 100;   -- Nuevo icesion

                  IF (p1.cnt = 2) THEN   -- Si el total de registros es dos, realizar calculo autom¿tico y tambi¿n validar
                     IF ((vpcesion > 100)
                         OR(vpcesion < 0)) THEN
                        RETURN 9908462;   -- No se permite valor de importe pues causa que se pase del total real para el importe
                     END IF;
                  END IF;
               END IF;
            END IF;
            vpasexec := 2;   -- Actualizar valores (una sola vez)
    
              BEGIN
               UPDATE estcesionesrea
                  SET pcesion = ppcesion,
                      icesion = vicesion,
                      icapces = vicapces
                WHERE scesrea = p1.scesrea;
                     bndupd:=bndupd+1;
               IF SQL%ROWCOUNT = 0 THEN
                  p_control_error('20', 'f_update_estcesionesrea999',
                                  'Se actualizo ' || SQL%ROWCOUNT);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  p_control_error('17', 'f_update_estcesionesrea9999',
                                  'no se actualizo -->' || SQLERRM);
            END;

            p_control_error('13', 'f_update_estcesionesrea',
                            'v_ozea --> ppcesion: ' || vpcesion || '| picesion: ' || vicesion
                            || '| picapces: ' || vicapces || '| pscesrea: ' || p1.scesrea);
            vpcesion2 := vn_tot_real_pcesion - vpcesion;
            vicesion2 := vn_tot_real_icesion - vicesion;
            vicapces2 := vn_tot_real_icapces - vicapces; --
            vpasexec := 3;

            IF (p1.cnt = 2) THEN   -- Si el total de registros para la garant¿a
               IF (vcvidaga = 1) THEN   -- No se toma los totales por garantia
                  vpasexec := 4;
                  p_control_error('14', 'f_update_estcesionesrea', 'v_ozea');
                    bndupd:=bndupd+1;
                  UPDATE estcesionesrea   -- actualizar automaticamente el segundo registro 
                     SET pcesion = vpcesion2,
                         icesion = vicesion2, --
                         icapces = vicapces2
                   WHERE scesrea !=
                            p1.scesrea   -- Solo actualice el otro registro perteneciente a la misma garant¿a
                                      ;
                                     
               END IF;

               IF (vcvidaga = 2) THEN   -- Se toma el total por garantia
                  vpasexec := 5;

                  BEGIN
                     SELECT COUNT(*)
                       INTO v_cuantos
                       FROM estcesionesrea
                      WHERE scesrea != p1.scesrea
                        AND cgarant = vgarant;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_cuantos := -1;
                  END;

                    /*AGG 30/11/2015 s¿hacemos la modificaci¿uando hay dos registros,
                    si hay m¿ser¿l usuario el que introduzca los porcentajes manualmente*/
                  --  p_control_error('11', 'v_cuantos:' || v_cuantos, NULL);
                  IF v_cuantos <= 1 THEN
                     p_control_error('15', 'f_update_estcesionesrea', 'v_ozea');
                     bndupd:=bndupd+1;
                     UPDATE estcesionesrea   -- actualizar automaticamente el segundo registro 
                        SET pcesion = vpcesion2,
                            icesion = vicesion2,--
                            icapces =vicapces2
                      WHERE scesrea !=
                               p1.scesrea   -- Solo actualice el otro registro perteneciente a la misma garant¿a
                        AND cgarant = vgarant;                                   
                  END IF;
               END IF;
            END IF;

            EXIT;   -- Salir del loop despu¿s del update.  No debe intentar actualizar 
                    -- otros
         ELSE
         vicapces := vn_tot_real_icapces * ppcesion / 100; 
         vicesion := vn_tot_real_icesion * ppcesion / 100;
         
            BEGIN
            bndupd:=bndupd+1;
               UPDATE estcesionesrea
                  SET pcesion = ppcesion,
                      icesion = vicesion,
                      icapces = vicapces
                WHERE scesrea = pscesrea;

               p_control_error('16', 'f_update_estcesionesrea',
                               'v_ozea --> ppcesion: ' || ppcesion || '| picesion: '
                               || picesion || '| picapces: ' || picapces || '| pscesrea: '
                               || p1.scesrea);
            END;
         END IF;

      END LOOP;
      
       IF  bndupd=0 THEN 
         
                   vicapces := vn_tot_real_icapces * ppcesion / 100; 
                   vicesion := vn_tot_real_icesion * ppcesion / 100;
                       UPDATE estcesionesrea
                          SET pcesion = ppcesion,
                              icesion = vicesion,
                              icapces = vicapces 
                        WHERE scesrea = pscesrea;

            END IF;
      
   
      /*IF SQL%ROWCOUNT = 0 THEN
       p_control_error('17', 'f_update_estcesionesrea', 'no se actualizo');
         RETURN no_se_actualizaron_datos;
      END IF;*/
      p_control_error('18', 'f_update_estcesionesrea', 'Finalizo correctamente');
      RETURN ok;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_md_estcesionesrea.f_update_estcesionesrea',
                     vpasexec, 'f_update_estcesionesrea ', SQLERRM);
         RETURN error_no_controlado;
   END f_update_estcesionesrea;

   FUNCTION setnuevotramocesion(
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE,   -- Nueva fecha de vencimiento
      psseguro estcesionesrea.sseguro%TYPE,   -- Identificador del seguro
      pnmovimi NUMBER,   -- Identificador del movimiento
      psproces NUMBER,   -- Identificador del proceso
      pmoneda monedas.cmoneda%TYPE,   -- COP: 8
      pnpoliza NUMBER,
      pncertif NUMBER,
      porigen NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN pac_cesionesrea.f_calcula_cesiones(psseguro, pnmovimi, psproces, 0, 8);
   END setnuevotramocesion;

   FUNCTION compruebaporcenfacultativo(
      pscesrea estcesionesrea.scesrea%TYPE,
      pcesion estcesionesrea.pcesion%TYPE)
      RETURN NUMBER IS
      vrea           estcesionesrea%ROWTYPE;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100) := ' pscesrea: ' || pscesrea || ', pcesion: ' || pcesion;
   BEGIN
      -- Si el porcentaje es 0 se anular¿ el registro correspondiente a la cesi¿n del facultativo
      -- informando el campo FANULAC y posteriormente se crear¿ un nuevo registro con CGENERA=7
      -- que se corresponde con la anulaci¿n de la cesi¿n.
      --
      IF (pcesion = 0) THEN
         SELECT *
           INTO vrea
           FROM estcesionesrea
          WHERE scesrea = pscesrea;

         RETURN f_atras(vrea.sproces, vrea.sseguro, f_sysdate, 7, 8, NULL, f_sysdate, 'EST');
      END IF;

      RETURN ok;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec,
                     'compruebaPorcenFacultativo', SQLERRM || ': ' || vparam);
         RAISE NO_DATA_FOUND;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec,
                     'compruebaPorcenFacultativo', SQLERRM || ': ' || vparam);
         RETURN error_no_controlado;
   END compruebaporcenfacultativo;

   --Valida cantidad de garantias en estcesionesrea
   FUNCTION f_get_garant_est(
      pssegpol estcesionesrea.sseguro%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_ESTCESIONESREA.F_GET_GARANT_EST';
      vparam         VARCHAR2(500) := 'parametros - pssegpol: ' || pssegpol;
      vpasexec       NUMBER := 0;
   BEGIN
      vsquery := 'select distinct CGARANT from estcesionesrea where ssegpol=' || pssegpol;
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 1;

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_ESTCESIONESREA.F_GET_GARANT_EST', 1, 4,
                                    mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vobjectname,
                     SQLERRM || ': ' || vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001);
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_garant_est;

   -- Valida que la suma de porcentajes para la garantia del ssegpol sea 100
   --
   FUNCTION compruebaporcentajes(
      pssegpol estcesionesrea.sseguro%TYPE,
      pcgarant estcesionesrea.cgarant%TYPE)
      RETURN NUMBER IS
      p_sumporc      NUMBER := 0;
   BEGIN
      IF (pssegpol IS NOT NULL
          AND pcgarant IS NULL) THEN   -- Se valida si la garantia es nula, este caso se da cuando (cvidaga = 1)
         BEGIN
            SELECT SUM(NVL(pcesion, 0))
              INTO p_sumporc
              FROM estcesionesrea
             WHERE ssegpol = pssegpol
          -- AND fanulac IS NULL  
               AND(cgenera != 7
                   OR cgenera IS NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_sumporc := 0;
         END;
      ELSE   -- Si trae informada la garantia se hace la suma por la misma.
         BEGIN
            SELECT SUM(NVL(pcesion, 0))
              INTO p_sumporc
              FROM estcesionesrea
             WHERE ssegpol = pssegpol
               AND cgarant = pcgarant 
               --AND fanulac IS NULL
               AND(cgenera != 7
                   OR cgenera IS NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_sumporc := 0;
         END;
      END IF;

      IF (p_sumporc = 100) THEN
         RETURN ok;
      ELSE
         RETURN 9902398;
      END IF;
   END compruebaporcentajes;

   -- Tanto si se ha contabilizado como si no, siempre se tendr¿ que realizar
   -- una regularizaci¿n, (1) generando el registro de anulaci¿n con cgenera = 7 y
   -- (2) el registro de suplemento, con cgenera = 4 en el cual aparecer¿n reflejadas
   -- las modificaciones que el usuario haya realizado.

   -- En caso de que la cesi¿n se haga por recibo, la regularizaci¿n por ajuste de cesiones no
   -- tendr¿ efecto retroactivo y s¿lo aplicar¿ a partir del siguiente recibo emitido.
   -- Una vez realizados los cambios en ESTCESIONESREA cuando se acepten dichos cambios se
   -- traspasar¿ la informaci¿n a CESIONESREA.
   --
   -- Crear moviments d'anul-laci¿ de cessions a ESTCESIONESREA.
   -- Aquest moviments poden estar originats (1) per l'anul-laci¿ de p¿lissa o suplement.
   -- o per l'entrada d'un suplement
   -- Tipus o motius de moviments anul-lables:
   --       01 - REGULARITZACI¿
   --       03 - NOVA PRODUCCI¿
   --       04 - SUPLEMENT
   --       05 - CARTERA
   --       09 - REHABILITACI¿
   --       40 - ALLARGAMENT POSITIU ( RENOVACI¿ CAP AL FUTUR)
   --   Els tipus o motius que es crean son:
   --       06 - ANUL.LACI¿ DE P¿LISSA
   --       07 - ANUL.LACI¿ PER CAUSA DE SUPLEMENT
   --
   -- El moviment d'anul.laci¿ es far¿ sempre en funci¿ de la
   -- data d'efecte d'aquesta i considerant nom¿s la part en
   -- vig¿ncia de cada un dels moviments que afecti, sense
   -- que influeixi les formes de pagament ni duraci¿
   --
   -- Controlar el prorrateig tamb¿ en funci¿ de la data FREGULA
   -- informada en els registres afectats per un canvi de
   -- versi¿ del contracte.
   -- Pres de f_atras (idtosel, icomreg son campos solo de cesionesrea)
   --
   FUNCTION f_anular(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pfinici IN DATE,
      pmotiu IN NUMBER,
      pmoneda IN NUMBER,
      pnmovigen IN NUMBER DEFAULT NULL,
      pfdatagen IN DATE DEFAULT f_sysdate)
      RETURN NUMBER IS
      vpas           NUMBER := 0;
      vobj           VARCHAR2(200) := 'f_atras';
      vpar           VARCHAR2(500)
         := 'p=' || psproces || ' s=' || psseguro || ' i=' || pfinici || ' m=' || pmotiu
            || ' m=' || pmoneda || ' g=' || pnmovigen || ' f=' || pfdatagen;
      codi_error     NUMBER := 0;
      w_dias         NUMBER;
      w_dias_origen  NUMBER;
      w_icesion      estcesionesrea.icesion%TYPE;   -- bug 25803
      w_ipritarrea   estcesionesrea.ipritarrea%TYPE;   -- bug 25803
      w_iextrea      estcesionesrea.iextrea%TYPE;   -- bug 28056
      w_scesrea      estcesionesrea.scesrea%TYPE;   -- bug 25803
      avui           DATE;
      w_finianulces  estcesionesrea.fefecto%TYPE;   --- bug 25803
      w_ffinanulces  estcesionesrea.fefecto%TYPE;   -- bug 25803
      w_cforpag      seguros.cforpag%TYPE;   -- bug 25803
      lsproduc       seguros.sproduc%TYPE;   -- bug 25803
      ldetces        NUMBER;
      lnmovigen      estcesionesrea.nmovigen%TYPE;   -- bug 25803

      CURSOR cur_movim IS
         SELECT *
           FROM estcesionesrea
          WHERE sseguro = psseguro
            AND(cgenera = 01
                OR cgenera = 03
                OR cgenera = 04
                OR cgenera = 05
                OR cgenera = 09
                OR cgenera = 40)
            AND fvencim > GREATEST(pfinici, fefecto)
            -- CPM 6/3/06: Se coge la fecha m¿s grande pues es la que luego se updatar¿
            AND(fanulac > GREATEST(pfinici, fefecto)
                OR fanulac IS NULL)
            AND(fregula > GREATEST(pfinici, fefecto)
                OR fregula IS NULL);

-- 13195 01-03-2010 AVT actualitzem tamb¿ els registres negatiu perque no els reculli el detall
      CURSOR cur_movim_anula(proces IN NUMBER) IS
         SELECT *
           FROM estcesionesrea
          WHERE sseguro = psseguro
            AND(cgenera = 06
                OR cgenera = 07)
            AND fvencim > GREATEST(pfinici, fefecto)
            -- CPM 6/3/06: Se coge la fecha m¿s grande pues es la que luego se updatar¿
            AND(fanulac > GREATEST(pfinici, fefecto)
                OR fanulac IS NULL)
            AND(fregula > GREATEST(pfinici, fefecto)
                OR fregula IS NULL)
            AND sproces <> NVL(proces, 0);
   BEGIN
      vpas := 1000;

      IF pnmovigen IS NULL THEN
         -- Obtenim el n¿ nmovigen
         BEGIN
            vpas := 1010;

            SELECT NVL(MAX(nmovigen), 0) + 1
              INTO lnmovigen
              FROM estcesionesrea
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               lnmovigen := 1;
         END;
      ELSE
         lnmovigen := pnmovigen;
      END IF;

      vpas := 1020;
      avui := pfdatagen;

      BEGIN
         vpas := 1030;

         SELECT sproduc, cforpag
           INTO lsproduc, w_cforpag
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            -- Bug 0021242 - 14/02/2012 - JMF
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
            RETURN 101919;
      END;

      vpas := 1040;

      FOR regmovim IN cur_movim LOOP
         -- Controlamos que no se haya anulado ya una parte de la cesi¿n
         IF regmovim.fregula IS NOT NULL THEN   -- Control dels registres afectats per un
            w_ffinanulces := regmovim.fregula;   -- canvi de versi¿ de contracte
         ELSIF regmovim.fanulac IS NOT NULL THEN
            w_ffinanulces := regmovim.fanulac;
         ELSE
            w_ffinanulces := regmovim.fvencim;
         END IF;

         -- Se controla la fecha de inicio de anulaci¿n.
         IF regmovim.fefecto < pfinici THEN
            w_finianulces := pfinici;
         ELSE
            w_finianulces := regmovim.fefecto;
         END IF;

         BEGIN
            vpas := 1050;

            UPDATE estcesionesrea
               SET fanulac = w_finianulces
             WHERE scesrea = regmovim.scesrea;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Bug 0021242 - 14/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' c=' || regmovim.scesrea || ' a=' || w_finianulces,
                           SQLCODE || ' ' || SQLERRM);
               codi_error := 104738;
               RETURN(codi_error);
            WHEN OTHERS THEN
               -- Bug 0021242 - 14/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' c=' || regmovim.scesrea || ' a=' || w_finianulces,
                           SQLCODE || ' ' || SQLERRM);
               codi_error := 104739;
               RETURN(codi_error);
         END;

         vpas := 1060;
         codi_error := f_difdata(regmovim.fefecto, regmovim.fvencim, 3, 3, w_dias_origen);

         IF codi_error <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas,
                        vpar || ' ini=' || regmovim.fefecto || ' fin=' || regmovim.fvencim,
                        SQLCODE || ' ' || SQLERRM);
            RETURN(codi_error);
         END IF;

         vpas := 1070;
         codi_error := f_difdata(w_finianulces, w_ffinanulces, 3, 3, w_dias);

         IF codi_error <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas,
                        vpar || ' ini=' || w_finianulces || ' fin=' || w_ffinanulces,
                        SQLCODE || ' ' || SQLERRM);
            RETURN(codi_error);
         END IF;

         IF w_dias_origen = 0 THEN
            w_dias_origen := 1;
         END IF;

         IF w_dias = 0 THEN
            w_dias := 1;
         END IF;

         vpas := 1080;
         w_icesion := f_round((regmovim.icesion * w_dias) / w_dias_origen, pmoneda);
         vpas := 1090;
         w_ipritarrea := f_round((regmovim.ipritarrea * w_dias) / w_dias_origen, pmoneda);
         vpas := 1100;
         w_iextrea := f_round((regmovim.iextrea * w_dias) / w_dias_origen, pmoneda);

         SELECT scesrea.NEXTVAL
           INTO w_scesrea
           FROM DUAL;

         BEGIN
            vpas := 1120;

            INSERT INTO estcesionesrea
                        (scesrea, ncesion, icesion, icapces,
                         sseguro, nversio, scontra,
                         ctramo, sfacult, nriesgo,
                         icomisi, scumulo, cgarant,
                         spleno, nmovimi, fefecto, fvencim,
                         pcesion, sproces, cgenera, fgenera, ipritarrea,
                         psobreprima, cdetces, nmovigen, ipleno,
                         icapaci, iextrea, itarifrea, ctipomov)
                 VALUES (w_scesrea, regmovim.ncesion, w_icesion * -1, regmovim.icapces,
                         regmovim.sseguro, regmovim.nversio, regmovim.scontra,
                         regmovim.ctramo, regmovim.sfacult, regmovim.nriesgo,
                         regmovim.icomisi, regmovim.scumulo, regmovim.cgarant,
                         regmovim.spleno, regmovim.nmovimi, w_finianulces, w_ffinanulces,
                         regmovim.pcesion, psproces, pmotiu, avui, -w_ipritarrea,
                         regmovim.psobreprima, regmovim.cdetces, lnmovigen, regmovim.ipleno,
                         regmovim.icapaci, -w_iextrea, regmovim.itarifrea, 'M');
         EXCEPTION
            WHEN OTHERS THEN
               -- Bug 0021242 - 14/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           's=' || regmovim.sseguro || ' r=' || regmovim.nriesgo || ' c='
                           || regmovim.scontra || ' v=' || regmovim.nversio || ' g='
                           || regmovim.cgarant,
                           SQLCODE || ' ' || SQLERRM);
               codi_error := 104740;
               RETURN(codi_error);
         END;
      END LOOP;

      vpas := 1130;

      FOR regmov IN cur_movim_anula(psproces) LOOP
         BEGIN
            UPDATE estcesionesrea
               SET fanulac = w_finianulces
             WHERE scesrea = regmov.scesrea;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Bug 0021242 - 14/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' ces=' || regmov.scesrea || ' anu=' || w_finianulces,
                           SQLCODE || ' ' || SQLERRM);
               codi_error := 104738;
               RETURN(codi_error);
            WHEN OTHERS THEN
               -- Bug 0021242 - 14/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' ces=' || regmov.scesrea || ' anu=' || w_finianulces,
                           SQLCODE || ' ' || SQLERRM);
               codi_error := 104739;
               RETURN(codi_error);
         END;
      END LOOP;

      -- Si estem anul¿lant una p¿lissa cessions d'un producte que es calcula
      -- la cessio al quadre d'amortitzaci¿, tamb¿ haurem d'anul¿lar
      -- el detall de reasegemi i detreasegemi. Les que no s'hi calculen ja s'anul.len
      -- quan s'anul.la el rebut
      IF codi_error = 0 THEN
         ldetces := NULL;
         vpas := 1140;
         ldetces := f_cdetces(psseguro);   -- BUG: 17672 JGR 23/02/2011

         IF NVL(ldetces, 0) = 2 THEN   -- calcul a q amort.
            vpas := 1150;
            codi_error := pac_cesionesrea.f_cesdet_anu_per(psseguro, pfinici, 2);

            -- Bug 0021242 - 14/02/2012 - JMF
            IF codi_error <> 0 THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
            END IF;
         -- 2 Anul.laci¿
         END IF;
      END IF;

      RETURN(codi_error);
   END;

---------------------------------------------------------------------
-- Insert a cap¿alera de facultatiu en CUAFACUL.  Si FACPENDIENTES
-- existeix ja no fa res
----------------------------------------------------------------------
   FUNCTION cabfacul(pcesrec estcesionesrea%ROWTYPE)
      RETURN NUMBER IS
      w_sfacult      cuafacul.sfacult%TYPE;
      w_pfacced      cuafacul.pfacced%TYPE;
      w_ifacced      cuafacul.ifacced%TYPE;
      w_controllat   NUMBER(1);
      w_scontra      reaseguroaux.scontra%TYPE;
      w_nversio      reaseguroaux.nversio%TYPE;
      v_modifsfacult cuafacul.sfacult%TYPE;
      vpasexec       NUMBER;
   BEGIN
      IF pcesrec.scontra IS NULL THEN
         BEGIN   -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
            SELECT cramo
              INTO w_scontra
              FROM seguros
             WHERE sseguro = pcesrec.ssegpol;
         END;

         w_nversio := 1;
      ELSE
         w_scontra := pcesrec.scontra;
         w_nversio := pcesrec.nversio;
      END IF;

      vpasexec := 1;
      --dbms_output.put_line('***** band ozea1');
      w_controllat := 0;

      SELECT COUNT(*)
        INTO w_sfacult   --verificamos si ya existen cuadros facultativos.
        FROM cuafacul
       WHERE sseguro = pcesrec.ssegpol
         AND nriesgo = pcesrec.nriesgo
         AND NVL(cgarant, 0) = NVL(pcesrec.cgarant, 0)
         AND cestado = 2;

      IF w_sfacult > 0 THEN
         w_controllat := 1;
      END IF;

      vpasexec := 2;

      --dbms_output.put_line('***** band ozea2');
      SELECT sfacult.NEXTVAL
        INTO w_sfacult
        FROM DUAL;

      w_pfacced := pcesrec.pcesion;
      w_ifacced := pcesrec.icapces;
      vpasexec := 3;

      --dbms_output.put_line('***** band ozea3');
      IF w_controllat = 0 THEN   -- Si no existen Cuadros facultativos se crea uno nuevo incompleto.
         vpasexec := 4;

         IF NVL(pac_parametros.f_parempresa_n(gempresa, 'ACT_CUACESFAC'),0) != 1 THEN --CONF-1082
           --dbms_output.put_line('***** band ozea4');
           INSERT INTO cuafacul
                       (sfacult, cestado, finicuf, cfrebor, scontra, nversio,
                        sseguro, cgarant,
                        ccalif1, ccalif2, spleno, nmovimi, scumulo,
                        nriesgo, ffincuf, plocal, fultbor,
                        pfacced, ifacced, ncesion)
                VALUES (w_sfacult, 1, pcesrec.fefecto, 1, w_scontra, w_nversio,
                        --ini IAXIS-4404
                        --DECODE(pcesrec.scumulo, NULL, pcesrec.ssegpol, NULL)
                        pcesrec.ssegpol,
                        --fin IAXIS-4404
                         pcesrec.cgarant,
                        NULL, NULL, pcesrec.spleno, pcesrec.nmovimi, pcesrec.scumulo,
                        DECODE(pcesrec.scumulo, NULL, pcesrec.nriesgo, NULL), NULL, NULL, NULL,
                        w_pfacced, w_ifacced, 1);

           vpasexec := 5;

           UPDATE estcesionesrea
              SET sfacult = w_sfacult
            WHERE scesrea = pcesrec.scesrea;
         ELSE --CONF-1082 Inicio

           BEGIN
             SELECT sfacult
               INTO w_sfacult
               FROM cuafacul
              WHERE scumulo = pcesrec.scumulo
                AND(cgarant = pcesrec.cgarant
                    OR pcesrec.cgarant IS NULL)
                AND cestado = 2;
           EXCEPTION WHEN NO_DATA_FOUND THEN
             BEGIN
               SELECT sfacult
                 INTO w_sfacult
                 FROM cuafacul
                WHERE scumulo = pcesrec.scumulo
                  AND(cgarant = pcesrec.cgarant
                      OR pcesrec.cgarant IS NULL)
                  AND cestado = 1;
             EXCEPTION WHEN OTHERS THEN
               w_sfacult := NULL;
             END;
           END;

           IF w_sfacult IS NOT NULL THEN
             UPDATE cuafacul
                SET cestado = 1,
                    pfacced = w_pfacced,
                    ifacced = w_ifacced
              WHERE sfacult = w_sfacult;
           END IF;
         END IF; --CONF-1082 Fin
      ELSE
         --dbms_output.put_line('***** band ozea6');
         vpasexec := 6;

         IF pcesrec.scumulo IS NOT NULL THEN
            -- No existeix un registre de pendent i s¿ que forma cumul...
            -- Si ja existeix cap¿alera iniciada per el cumul, s'agafar¿
            -- el num. de cumul i es donar¿ l'alta a FACPENDIENTES
            -- solsament...
            -- Si no existeix cap¿alera, es dona d'alta als dos llocs...
            ----dbms_outpuT.put_line(' cabfacul TE CUMUL ');
            SELECT sfacult
              INTO w_sfacult
              FROM cuafacul
             WHERE scumulo = pcesrec.scumulo
               AND(cgarant = pcesrec.cgarant
                   OR pcesrec.cgarant IS NULL)
               AND cestado = 1;

            ----dbms_outpuT.put_line(' cabfacul TE QUADRE ');
            w_controllat := 2;   -- No hem de fer l'insert a CUAFACUL
            RETURN 0;
         END IF;

         --dbms_output.put_line('***** band ozea 7');
         vpasexec := 7;

         SELECT sfacult
           INTO v_modifsfacult   -- Guarda el identificador del regitro a modificar y duplicar el nuevo.
           FROM cuafacul
          WHERE (sseguro = pcesrec.ssegpol
                 OR scumulo = NVL(pcesrec.scumulo, -1))
            AND NVL(nriesgo, 0) = DECODE(scumulo,
                                         NULL, pcesrec.nriesgo,
                                         0)   -- 15590 AVT 30-07-2010
            AND(cgarant IS NULL
                OR cgarant = pcesrec.cgarant)
            AND ffincuf IS NULL
            AND scontra = w_scontra
            AND nversio = w_nversio;

         vpasexec := 8;

         --CONF-1082
         IF NVL(pac_parametros.f_parempresa_n(gempresa, 'ACT_CUACESFAC'),0) = 1 THEN
           UPDATE cuafacul
              SET cestado = 1,
                  pfacced = w_pfacced,
                  ifacced = w_ifacced
            WHERE sfacult = v_modifsfacult;
         ELSE
           UPDATE cuafacul
              SET ffincuf = pcesrec.fefecto
            WHERE sfacult = v_modifsfacult;
         END IF;
         --CONF-1082

         --dbms_output.put_line('***** band ozea 8');
         vpasexec := 9;

--INICIO (21901 + 37294): AGG 10/02/2016
         IF w_pfacced <> 0 AND NVL(pac_parametros.f_parempresa_n(gempresa, 'ACT_CUACESFAC'),0) != 1 THEN
            BEGIN
               INSERT INTO cuafacul
                           (sfacult, cestado, finicuf, cfrebor, scontra, nversio,   -- duda que colocar en el campo finicuf
                                                                                 sseguro,
                            cgarant, ccalif1, ccalif2, spleno, nmovimi, scumulo, nriesgo,
                            ffincuf, plocal, fultbor, pfacced, ifacced, ncesion)
                  --INICIO (QT 21901 + Bug 37294) AGG 01/04/2016
                  SELECT w_sfacult, 1, finicuf, cfrebor, scontra, nversio, sseguro, cgarant,
                  --FIN (QT 21901 + Bug 37294) AGG 01/04/2016
                         ccalif1, ccalif2, spleno, nmovimi, scumulo, nriesgo, NULL, plocal,
                         fultbor, w_pfacced, w_ifacced, ncesion
                    FROM cuafacul
                   WHERE sfacult = v_modifsfacult;

               vpasexec := 10;

               UPDATE estcesionesrea
                  SET sfacult = w_sfacult
                WHERE scesrea = pcesrec.scesrea;
            END;
         END IF;
      END IF;

      --FIN(21901 + 37294): AGG 10/02/2016
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         --dbms_output.put_line('***** band ozea10');
         p_tab_error(f_sysdate, f_user, 'pac_md_estcesionesrea.cabfacul', vpasexec,
                     'Error incontrolado variables w_sfacult = ' || w_sfacult, SQLERRM);
         --dbms_output.put_line('***** band ozea11');
         RETURN 1000133;
   END cabfacul;

   FUNCTION f_cabfacul(pssegpol NUMBER)
      RETURN NUMBER IS
      vcesrec        estcesionesrea%ROWTYPE;
      v_retorno      NUMBER := 0;
      e_error        EXCEPTION;

      CURSOR c_estcesionesrea(pssegpol NUMBER) IS   -- Cursor totales cuando trae garantia (cvidaga = 2)
         SELECT *
           FROM estcesionesrea
          WHERE ssegpol = pssegpol
            AND fanulac IS NULL
            --INICIO (21901 + 37294): AGG 11/02/2016
            AND nvl(cgenera,0) != 7
            --FIN (21901 + 37294): AGG 11/02/2016
            AND ctramo = 5;
            --INICIO (QT 21901 + Bug 37294) AGG 01/04/2016
            --and fmodifi is not null;  hans rea03
            --FIN (QT 21901 + Bug 37294) AGG 01/04/2016
   BEGIN
     --dc_p_trazas(777777, 'en pac_md_estcesionesrea. f_cabfacul paso 1');

      FOR q1 IN c_estcesionesrea(pssegpol) LOOP   -- Calcular valores reales desde CESIONESREA.  El total del
       --  dc_p_trazas(777777, 'en pac_md_estcesionesrea. f_cabfacul paso 2');
         IF (q1.ctramo = 5) THEN
        --   dc_p_trazas(777777, 'en pac_md_estcesionesrea. f_cabfacul paso 3');
            vcesrec.scesrea := q1.scesrea;
            vcesrec.ncesion := q1.ncesion;
            vcesrec.icesion := q1.icesion;
            vcesrec.icapces := q1.icapces;
            vcesrec.sseguro := q1.sseguro;
            vcesrec.ssegpol := q1.ssegpol;
            vcesrec.nversio := q1.nversio;
            vcesrec.scontra := q1.scontra;
            vcesrec.ctramo := q1.ctramo;
            vcesrec.sfacult := q1.sfacult;
            vcesrec.nriesgo := q1.nriesgo;
            vcesrec.icomisi := q1.icomisi;
            vcesrec.scumulo := q1.scumulo;
            vcesrec.cgarant := q1.cgarant;
            vcesrec.spleno := q1.spleno;
            vcesrec.nsinies := q1.nsinies;
            vcesrec.fefecto := q1.fefecto;
            vcesrec.fvencim := q1.fvencim;
            vcesrec.fcontab := q1.fcontab;
            vcesrec.pcesion := q1.pcesion;
            vcesrec.sproces := q1.sproces;
            vcesrec.cgenera := q1.cgenera;
            vcesrec.fgenera := q1.fgenera;
            vcesrec.fregula := q1.fregula;
            vcesrec.fanulac := q1.fanulac;
            vcesrec.nmovimi := q1.nmovimi;
            vcesrec.sidepag := q1.sidepag;
            vcesrec.ipritarrea := q1.ipritarrea;
            vcesrec.psobreprima := q1.psobreprima;
            vcesrec.cdetces := q1.cdetces;
            vcesrec.ipleno := q1.ipleno;
            vcesrec.icapaci := q1.icapaci;
            vcesrec.nmovigen := q1.nmovigen;
            vcesrec.iextrap := q1.iextrap;
            vcesrec.iextrea := q1.iextrea;
            vcesrec.nreemb := q1.nreemb;
            vcesrec.nfact := q1.nfact;
            vcesrec.nlinea := q1.nlinea;
            vcesrec.itarifrea := q1.itarifrea;
            vcesrec.icomext := q1.icomext;
            vcesrec.falta := q1.falta;
            vcesrec.cusualt := q1.cusualt;
            vcesrec.fmodifi := q1.fmodifi;
            vcesrec.cusumod := q1.cusumod;
            --dbms_output.put_line('***** band1');
        --    dc_p_trazas(777777, 'en pac_md_estcesionesrea. f_cabfacul paso 4');
            v_retorno := cabfacul(vcesrec);
        --    dc_p_trazas(777777, 'en pac_md_estcesionesrea. f_cabfacul paso 5');
            --dbms_output.put_line('***** band2' || v_retorno );
            IF v_retorno <> 0 THEN
               RAISE e_error;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         RETURN v_retorno;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_md_estcesionesrea.f_cabfacul', 1,
                     'Error incontrolado', SQLERRM);
         RETURN 1000133;
   END f_cabfacul;

   -- Inserta el facultativo
   --
   FUNCTION f_insert_ces(
      pp_capces NUMBER,
      pp_tramo NUMBER,
      pp_facult NUMBER,
      pp_cesio NUMBER,
      pp_porce NUMBER,
      pp_sproduc NUMBER)
      RETURN NUMBER IS
      w_scesrea      estcesionesrea.scesrea%TYPE;
      v_fconfin      DATE;
      v_irecarg      garanseg.irecarg%TYPE;
      v_iextrap      garanseg.iextrap%TYPE;
      v_icapital     garanseg.icapital%TYPE;
      v_pcomext      contratos.pcomext%TYPE;
      w_nmovigen     NUMBER;
      w_iprirea      estcesionesrea.icesion%TYPE;
      w_ipritarrea   estcesionesrea.ipritarrea%TYPE;
      -- w_idtosel   estcesionesrea.idtosel%TYPE;
      w_iextrea      estcesionesrea.iextrea%TYPE;
      w_iextrap      estcesionesrea.iextrap%TYPE;
      w_icomext      estcesionesrea.icomext%TYPE;
      registre       cesionesaux%ROWTYPE;
      pmotiu         NUMBER;
      pmoneda        NUMBER;
      codi_error     NUMBER;
      w_divisoranual NUMBER;
      w_dias         NUMBER;
      avui           DATE;
      perr           NUMBER;
   BEGIN
      SELECT scesrea.NEXTVAL
        INTO w_scesrea
        FROM DUAL;

      -- Multimoneda
      --
      w_iprirea := f_round(registre.iprirea * pp_porce, pmoneda);
      w_ipritarrea := f_round(registre.ipritarrea * pp_porce, pmoneda);
      --w_idtosel    := f_round(registre.idtosel * pp_porce, pmoneda);
      w_iextrea := f_round(registre.iextrea * pp_porce, pmoneda);
      w_iextrap := f_round(registre.iextrap * pp_porce, pmoneda);

      IF registre.fconfin IS NULL THEN
         SELECT DECODE(fcaranu, NULL, fvencim, fcaranu)
           INTO v_fconfin
           FROM seguros
          WHERE sseguro = registre.sseguro;

         codi_error := f_difdata(registre.fconini, v_fconfin, 3, 3, w_dias);
      ELSE
         codi_error := f_difdata(registre.fconini, registre.fconfin, 3, 3, w_dias);
      END IF;

      -- Cesi¿n de prima por emisi¿n:  Define s¿ se deben prorratear los movimientos de suplementos.
      -- No hacemos diferencias por forma de pago (entre f.ini i fin max 1 a¿o).
      -- Covertir el par¿metre de instal.laci¿ de prorrateig en la N.P per un parproducto
      IF (pmotiu IN(9, 4, 1, 3)) THEN
         -- Afegir prorrateig de la cessio en la Nova Producci¿ unicament per CIV. A¿adimos el pmotiu 3
         -- Per defecte tots els productes prorrategen
         IF pmotiu = 3
            AND NVL(f_parproductos_v(pp_sproduc, 'NO_PRORRATEA_REA'), 0) = 1 THEN
            NULL;   -- No prorrateja
         ELSE
            IF NVL(f_parproductos_v(pp_sproduc, 'NO_PRORRATEA_REA_SUP'), 0) = 1 THEN
               NULL;   -- No prorrateja
            ELSE
               codi_error := f_difdata(registre.fconini, ADD_MONTHS(registre.fconini, 12), 3,
                                       3, w_divisoranual);
               w_iprirea := f_round((w_iprirea * w_dias) / w_divisoranual, pmoneda);
               w_ipritarrea := f_round((w_ipritarrea * w_dias) / w_divisoranual, pmoneda);
               --w_idtosel    := f_round((w_idtosel * w_dias) / w_divisoranual, pmoneda);
               w_iextrea := f_round((w_iextrea * w_dias) / w_divisoranual, pmoneda);
               w_iextrap := f_round((w_iextrap * w_dias) / w_divisoranual, pmoneda);
            END IF;
         END IF;
      END IF;

      -- A¿adimos la comisi¿n de la extra prima
      BEGIN
         SELECT pcomext
           INTO v_pcomext
           FROM contratos
          WHERE scontra = registre.scontra
            AND nversio = registre.nversio;

         w_icomext := w_iextrea * v_pcomext;
      EXCEPTION
         WHEN OTHERS THEN
            w_icomext := 0;
      END;

      INSERT INTO estcesionesrea
                  (scesrea, ncesion, icesion, icapces, sseguro,
                   nversio,
                   scontra,
                   ctramo, sfacult, nriesgo,
                   icomisi,
                           -- icomreg,
                           scumulo, cgarant,
                   spleno,
                          -- ccalif1,
                          -- ccalif2,
                          fefecto,
                   fvencim, pcesion, sproces, cgenera, fgenera,
                   nmovimi, ipritarrea, psobreprima, cdetces,
                   fanulac, fregula, nmovigen, ipleno,
                   icapaci, iextrea,   -- LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                                    iextrap, itarifrea, icomext, ctipomov)
           VALUES (w_scesrea, pp_cesio, w_iprirea, pp_capces, registre.sseguro,
                   DECODE(registre.cfacult, 0, registre.nversio, NULL),
                   DECODE(registre.cfacult, 0, registre.scontra, NULL),
                   DECODE(pp_tramo, 6, 0, 7, 0, 8, 0, pp_tramo), pp_facult, registre.nriesgo,
                   NULL,
                        --NULL,
                        registre.scumulo, registre.cgarant,
                   DECODE(registre.cfacult, 0, registre.spleno, NULL),
                                                                      -- DECODE(registre.cfacult, 0, registre.ccalif1, NULL),
                                                                      -- DECODE(registre.cfacult, 0, registre.ccalif2, NULL),
                                                                      registre.fconini,
                   registre.fconfin,(pp_porce * 100), registre.sproces, pmotiu, avui,
                   registre.nmovimi, w_ipritarrea, registre.psobreprima, registre.cdetces,
                   registre.fanulac, registre.fregula, w_nmovigen, registre.ipleno,
                   registre.icapaci, w_iextrea, w_iextrap, registre.itarifrea, w_icomext, 'M');

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_cessio', 1, 'f_insert_ces', SQLERRM);
         RETURN 104692;
   END f_insert_ces;

   FUNCTION f_get_totalesestcesionrea(
      psseguro IN NUMBER,
      ptotporcesion OUT NUMBER,
      ptotcapital OUT NUMBER,
      ptotcesion OUT NUMBER)
      RETURN NUMBER IS
      cur            sys_refcursor;
      psalida        NUMBER := 1;
      vobject        VARCHAR2(200) := 'PAC_MD_ESTCESIONESREA.f_get_totalesestcesionrea';
      vnumerr        NUMBER := 0;
   BEGIN
      ptotporcesion := 0;
      ptotcapital := 0;
      ptotcesion := 0;

      SELECT   SUM(NVL(pcesion, 0)), SUM(NVL(icapces, 0)), SUM(NVL(icesion, 0))
          INTO ptotporcesion, ptotcapital, ptotcesion
          FROM estcesionesrea
         WHERE ssegpol = psseguro
      GROUP BY sseguro;

      RETURN ok;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN ok;
   END f_get_totalesestcesionrea;

   PROCEDURE simulacion_cierre_proporcional(
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      v_modo         NUMBER := 2;   --Siempre se llamar¿ en modo previo
      vmoneda        NUMBER := pac_monedas.f_moneda_seguro(NULL, psseguro);
      vdini          DATE;
      vdfin          DATE;
   BEGIN
      v_modo := 2;

      BEGIN
         SELECT MAX(fcierre)
           INTO vdini
           FROM cierres
          WHERE ctipo = 4
            AND cestado = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vdini := f_sysdate;
      END;

      vdfin := f_sysdate;
      pac_reaseguro_rec.proceso_batch_cierre(v_modo, gempresa, vmoneda, gidioma, vdini, vdfin,
                                             f_sysdate, pcerror, psproces, pfproces);

   END simulacion_cierre_proporcional;

   PROCEDURE simulacion_cierre_xl(
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      v_modo         NUMBER := 1;   --Siempre se llamar¿ en modo previo
      vmoneda        NUMBER := pac_monedas.f_moneda_seguro(NULL, psseguro);
      vdini          DATE;
      vdfin          DATE;
   BEGIN
      v_modo := 2;

      BEGIN
         SELECT MAX(fcierre)
           INTO vdini
           FROM cierres
          WHERE ctipo = 15
            AND cestado = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vdini := f_sysdate;
      END;

      vdfin := f_sysdate;
      pac_reaseguro_xl.proceso_batch_cierre(v_modo, gempresa, vmoneda, gidioma, vdini, vdfin,
                                            f_sysdate, pcerror, psproces, pfproces);
   END simulacion_cierre_xl;

   PROCEDURE traspaso_inf_cesionesreatoest(
      pssegpol NUMBER,
      psproces NUMBER,
      pmoneda NUMBER,
      pnsinies NUMBER,
      pcgenera NUMBER) IS
      vobject        VARCHAR2(20) := 'tras_inf_cestoest';
      vparam         VARCHAR2(128)
         := 'pssegpol: ' || pssegpol || ', psproces: ' || psproces || ', pmoneda: ' || pmoneda;
      v_error        NUMBER;
      vsproces       NUMBER := psproces;
   BEGIN
      IF (vsproces IS NULL) THEN
         v_error := f_procesini(f_user, gempresa, vobject, 'Traspaso Cesionesrea to Est',
                                vsproces);
      END IF;

      IF (v_error != 0) THEN
         raise_application_error(-20101, 'Error al generar n¿mero de proceso');
      END IF;

      pac_cesionesrea.traspaso_inf_cesionesreatoest(gempresa, pssegpol, gidioma, vsproces,
                                                    pmoneda, pcgenera, pnsinies);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 1, 'traspaso_inf_cesionesreatoest',
                     SQLERRM || ': ' || vparam);
         RAISE;
   END traspaso_inf_cesionesreatoest;

   PROCEDURE traspaso_inf_esttocesionesrea(
      psseguro IN NUMBER,
      psproces IN NUMBER,
      pmoneda IN NUMBER,
      pmensaje OUT VARCHAR2) IS --CONF-1082
      vobject        VARCHAR2(20) := 'tras_inf_esttoces';
      vparam         VARCHAR2(128)
         := 'psseguro: ' || psseguro || ', psproces: ' || psproces || ', pmoneda: ' || pmoneda;
      v_error        NUMBER;
      vsproces       NUMBER := psproces;
      vpasexec       NUMBER := 0;
   BEGIN
      vpasexec := 1;
    --  dc_p_trazas(777777, 'en pac_md_estcesionesrea paso 1');

      IF (vsproces IS NULL) THEN
         v_error := f_procesini(f_user, gempresa, vobject, 'Traspaso Est to Cesionesrea',
                                vsproces);
      END IF;

      vpasexec := 2;

      IF (v_error != 0) THEN
         raise_application_error(-20101, 'Error al generar n¿mero de proceso');
      END IF;

      vpasexec := 3;
    --  dc_p_trazas(777777, 'en pac_md_estcesionesrea paso 2');
      pac_cesionesrea.traspaso_inf_esttocesionesrea(gempresa, psseguro, gidioma, vsproces,
                                                    pmoneda, pmensaje); --CONF-1082
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vobject, SQLERRM || ': ' || vparam);
         RAISE;
   END traspaso_inf_esttocesionesrea;

   FUNCTION f_get_sim_estcesionesrea(psseguro NUMBER)
      RETURN t_iax_sim_estcesionesrea IS
      CURSOR c_sim_estcesionesrea IS
         SELECT DISTINCT mca.ccompapr cod_empresa,
                         (SELECT tcompani
                            FROM companias
                           WHERE ccompani = mca.ccompapr) desc_empresa, mca.sproduc,   -- Produ
                         mca.ccompani cod_reasegura,
                         (SELECT tcompani
                            FROM companias
                           WHERE ccompani = mca.ccompani) desc_reasegura,
                         mca.scontra cod_contra, ccon.tdescripcion desc_contra, mca.nversio,
                         mca.ctramo cod_tramo, dtram.tatribu desc_tramo, mca.fmovimi fcierre,
                         mca.cconcep cod_concept, dconc.tatribu desc_concept,
                         ccon.cmoneda cmoneda, iimport importe, mca.iimport
                    FROM movctatecnica mca, codicontratos ccon, detvalores dtram,   -- Descripci¿n de tramos
                         detvalores dconc   -- Descripci¿n de conceptos
                   WHERE dtram.cvalor = 105
                     AND dtram.cidioma = 2
                     AND mca.ctramo = dtram.catribu
                     AND dconc.cvalor = 124
                     AND dconc.cidioma = 2
                     AND mca.cconcep = dconc.catribu
                     AND mca.sproces = (SELECT MAX(sproces)
                                          FROM reaseguro
                                         WHERE sseguro = psseguro)
                     AND mca.scontra = ccon.scontra
                ORDER BY mca.ccompani, mca.cconcep;

      CURSOR c_sim_estcesionesrea_xl IS
         SELECT DISTINCT mca.ccompapr cod_empresa, comemp.tcompani desc_empresa, mca.sproduc,   -- Produ
                         com.ccompani cod_reasegura, com.tcompani desc_reasegura,
                         rea.scontra cod_contra, ccon.tdescripcion desc_contra, rea.nversio,
                         rea.ctramo cod_tramo, dtram.tatribu desc_tramo, rea.fcierre,
                         mca.cconcep cod_concept, dconc.tatribu desc_concept,
                         ccon.cmoneda cmoneda, rea.icesion importe
                    FROM reaseguroaux rea, movctaaux mca, companias comemp, companias com,
                         codicontratos ccon, detvalores dtram,   -- Descripci¿n de tramos
                                                              detvalores dconc,   -- Descripci¿n de conceptos
                         pagosreaxl_aux pa,   -- Pagos Reaseguro
                                           liquidareaxl_aux la   --Liquidaciones Reaseguro
                   WHERE rea.scontra = mca.scontra
                     AND rea.nversio = mca.nversio
                     AND comemp.ccompani = mca.ccompapr
                     AND rea.scontra = ccon.scontra
                     AND com.ccompani = rea.ccompani
                     AND rea.ctramo = dtram.catribu
                     AND dtram.cvalor = 105
                     AND dtram.cidioma = gidioma
                     AND mca.cconcep = dconc.catribu
                     AND dconc.cvalor = 124
                     AND rea.nsinies = la.nsinies
                     AND rea.nsinies = pa.nsinies
                     AND la.nsinies = pa.nsinies
                     AND mca.cconcep = 25
                     AND dconc.cidioma = gidioma
                     AND rea.sseguro = psseguro
                ORDER BY com.ccompani, mca.cconcep;

      vsim           ob_iax_sim_estcesionesrea;
      vsims          t_iax_sim_estcesionesrea := t_iax_sim_estcesionesrea();
      vscontraf      NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vcadena        VARCHAR2(1000);
      vobject        VARCHAR2(200) := 'PAC_MD_ESTCESIONESREA.f_get_estcesionesrea';
      i              NUMBER := 0;
   BEGIN
      --VALIDACION SI ES XL
      vscontraf := pac_md_estcesionesrea.f_get_reaseguro_xl(psseguro);
      vcadena := 'vscontraf-> ' || vscontraf || 'psseguro-> ' || psseguro;
      i := 0;

      IF vscontraf=0 THEN
         FOR p1 IN c_sim_estcesionesrea_xl LOOP
            vsim := ob_iax_sim_estcesionesrea();
            vsim.cod_empresa := p1.cod_empresa;
            vsim.desc_empresa := p1.desc_empresa;
            vsim.sproduc := p1.sproduc;
            vsim.cod_reasegura := p1.cod_reasegura;
            vsim.desc_reasegura := p1.desc_reasegura;
            vsim.cod_contra := p1.cod_contra;
            vsim.desc_contra := p1.desc_contra;
            vsim.nversio := p1.nversio;
            vsim.ctramo := p1.cod_tramo;
            vsim.desc_tramo := p1.desc_tramo;
            vsim.fcierre := p1.fcierre;
            vsim.cod_concept := p1.cod_concept;
            vsim.desc_concept := p1.desc_concept;
            vsim.cmoneda := p1.cmoneda;
            vsim.importe := p1.importe;
            i := i + 1;
            vsims.EXTEND();
            vsims(i) := vsim;
         END LOOP;

         IF (i = 0) THEN
            RAISE NO_DATA_FOUND;
         END IF;
      ELSE
         FOR p1 IN c_sim_estcesionesrea LOOP
            vsim := ob_iax_sim_estcesionesrea();
            vsim.cod_empresa := p1.cod_empresa;
            vsim.desc_empresa := p1.desc_empresa;
            vsim.sproduc := p1.sproduc;
            vsim.cod_reasegura := p1.cod_reasegura;
            vsim.desc_reasegura := p1.desc_reasegura;
            vsim.cod_contra := p1.cod_contra;
            vsim.desc_contra := p1.desc_contra;
            vsim.nversio := p1.nversio;
            vsim.ctramo := p1.cod_tramo;
            vsim.desc_tramo := p1.desc_tramo;
            vsim.fcierre := p1.fcierre;
            vsim.cod_concept := p1.cod_concept;
            vsim.desc_concept := p1.desc_concept;
            vsim.cmoneda := p1.cmoneda;
            vsim.importe := p1.importe;
            i := i + 1;
            vsims.EXTEND();
            vsims(i) := vsim;
         END LOOP;
      END IF;

      IF (i = 0) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN vsims;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'f_get_sim_estcesionesrea',
                     f_axis_literales(no_se_encontraron_datos) || ': ' || vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_ESTCESIONESREA', vpasexec,
                     'f_get_sim_estcesionesrea', SQLERRM);
         RAISE;
   END f_get_sim_estcesionesrea;

/**************************************************************************
  Get reaseguro xl
 **************************************************************************/
   FUNCTION f_get_reaseguro_xl(psseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER IS
      vobject        VARCHAR2(20) := 'f_get_reaseguro_xl';
      vparam         VARCHAR2(128) := 'psseguro: ' || psseguro;
      v_error        NUMBER;
      vscontra       NUMBER;
      
      
   BEGIN
 
   --DISTINCT
      SELECT DISTINCT co.scontra
                 INTO vscontra
                 FROM codicontratos co, reaseguroaux rea
                WHERE rea.sseguro = psseguro
                  AND rea.scontra = co.scontra
                  AND co.tdescripcion LIKE '%XL%';

      IF vscontra IS NOT NULL THEN --IS NOT NULL
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
       -- RETURN 0;
         RETURN 9908558;
        
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 1, vobject, SQLERRM || ': ' || vparam);
         RAISE;
   END f_get_reaseguro_xl;

   /***************************************************************************
     Devuelve la lista para consultas de cesiones manueales
     param in pnpoliza     : n¿mero de p¿liza
     param in pnsinies     : n¿mero del siniestro
    ****************************************************************************/
   FUNCTION f_consulta_ces_man(
      pnpoliza IN seguros.npoliza%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pnrecibo IN NUMBER,
      pfiniefe IN DATE,
      pffinefe IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_consulta_ces_man';
      vparam         VARCHAR2(500)
                       := 'parametros - pnpoliza: ' || pnpoliza || ' - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(5000);
      vbuscar        VARCHAR2(2000);
   BEGIN
      IF pnsinies IS NOT NULL THEN
         vsquery :=
            ' SELECT distinct se.sseguro, se.sproduc, se.npoliza, se.ncertif, se.cpolcia, si.nsinies, si.nriesgo,
                               PAC_MD_OBTENERDATOS.F_Desriesgos(''POL'', si.sseguro, si.nriesgo) as triesgo,
                               f_desproducto_t(se.cramo,se.cmodali,se.ctipseg,se.ccolect,1,PAC_MD_COMMON.F_Get_CXTIDIOMA) as tproduc,
                               cr.fefecto,
                 ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, cr.cgenera) descmovimi, cr.cgenera
                              FROM seguros se, sin_siniestro si, cesionesrea cr, recibos re WHERE cr.sseguro = se.sseguro AND re.sseguro (+) = cr.sseguro AND rownum <= NVL('
            || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null')
            || ', rownum) AND se.sseguro = si.sseguro and cr.cgenera != 7 and se.sseguro = cr.sseguro  and si.nsinies = '
            || pnsinies;
         vpasexec := 1;
      ELSIF pnpoliza IS NOT NULL THEN
      --INI - AXIS 4105 - 05/06/2019 - AABG - SE AGREGA FILTRO POR MOVIMIENTO
         vsquery :=
            ' SELECT distinct se.sseguro, se.sproduc, se.npoliza, se.ncertif, se.cpolcia, null nsinies, null nriesgo,
                               PAC_MD_OBTENERDATOS.F_Desriesgos(''POL'', se.sseguro, null) as triesgo,
                               f_desproducto_t(se.cramo,se.cmodali,se.ctipseg,se.ccolect,1,PAC_MD_COMMON.F_Get_CXTIDIOMA) as tproduc,
                              cr.fefecto,  ff_desvalorfijo(128, pac_md_common.f_get_cxtidioma, cr.cgenera) descmovimi,  cr.cgenera, cr.nmovigen
                              FROM seguros se, cesionesrea cr, recibos re WHERE cr.sseguro = se.sseguro AND re.sseguro (+) = cr.sseguro AND rownum <= NVL('
            || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null')
            || ', rownum) and se.sseguro = cr.sseguro and cr.cgenera != 7 and se.npoliza = ' || pnpoliza || ' order by cr.nmovigen desc';
     --FIN - AXIS 4105 - 05/06/2019 - AABG - SE AGREGA FILTRO POR MOVIMIENTO       
         vpasexec := 2;
      END IF;

      IF pnsinies IS NULL
         AND pnpoliza IS NULL THEN
         vsquery :=
            ' SELECT distinct se.sseguro, se.sproduc, se.npoliza, se.ncertif, se.cpolcia, null nsinies, null nriesgo,
                               PAC_MD_OBTENERDATOS.F_Desriesgos(''POL'', se.sseguro, null) as triesgo,
                               f_desproducto_t(se.cramo,se.cmodali,se.ctipseg,se.ccolect,1,PAC_MD_COMMON.F_Get_CXTIDIOMA) as tproduc,
                               se.cactivi,FF_DESACTIVIDAD(se.cactivi,se.cramo,PAC_MD_COMMON.F_Get_CXTIDIOMA) as tactivi, ff_desagente(se.cagente) tagente
                              FROM seguros se, recibos re, cesionesrea cr WHERE  rownum <= NVL('
            || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null')
            || ', rownum) AND cr.sseguro = se.sseguro  AND cr.cgenera != 7  AND re.sseguro (+) = se.sseguro ';
         vpasexec := 3;
      END IF;


      IF pnrecibo IS NOT NULL THEN
         vsquery := vsquery  || ' AND  re.nrecibo = ' || pnrecibo;
      END IF;

      IF pfiniefe IS NOT NULL THEN
         vsquery := vsquery  || ' AND  cr.fefecto >= to_date(''' || TO_CHAR(pfiniefe, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')';
      END IF;

      IF pffinefe IS NOT NULL THEN
         vsquery := vsquery  || ' AND  cr.fefecto <=to_date(''' || TO_CHAR(pffinefe, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')';
      END IF;


      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 3;

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_SINIESTROS.F_CONSULTA_CES_MAN', 1, 4,
                                    mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vobjectname,
                     SQLERRM || ': ' || vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001);
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_consulta_ces_man;

   PROCEDURE DEBUG(psfield VARCHAR2, pnvalue NUMBER, pbtodos BOOLEAN := FALSE) IS
      vtcesiones     t_iax_estcesionesrea;
      vtcesion       ob_iax_estcesionesrea;
   BEGIN
      IF (pbtodos) THEN
         vtcesiones := f_get_estcesionesrea(psfield, pnvalue);

         IF vtcesiones IS NOT NULL
            AND vtcesiones.COUNT > 0 THEN
            FOR i IN 1 .. vtcesiones.COUNT LOOP
               NULL;
            END LOOP;
         END IF;
      ELSE
         vtcesion := f_get_estcesionrea(psfield, pnvalue);
         NULL;
      END IF;
   END DEBUG;

   -- ERH
    FUNCTION f_detvalores_tramos(
      psseguro IN seguros.sseguro%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro =' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_ESTCESIONESREA.f_detvalores_tramos';
      terror         VARCHAR2(200) := 'No se puede recuperar la informaci??n de valores';
      v_scontra      cesionesrea.scontra%TYPE;
      v_nversio      cesionesrea.nversio%TYPE;
      v_ctiprea      seguros.ctiprea%TYPE;
      vsquery        VARCHAR2(5000);
      v_error        NUMBER := 0;
   BEGIN

    --  SELECT s.ctiprea
    --    INTO v_ctiprea
    --    FROM seguros s
    --   WHERE sseguro = psseguro;

      SELECT CTIPREA
        INTO v_ctiprea
        FROM CODICONTRATOS
       WHERE SCONTRA IN(SELECT DISTINCT SCONTRA
                          FROM cesionesrea
                         WHERE SSEGURO = psseguro);

     IF v_ctiprea = 5 THEN
           BEGIN
               SELECT MAX(c.scontra), MAX(c.nversio)
                 INTO v_scontra, v_nversio
                 FROM cesionesrea c
                WHERE sseguro = psseguro;
              --    AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT MAX(c.scontra), MAX(c.nversio)
                       INTO v_scontra, v_nversio
                       FROM estcesionesrea c
                      WHERE sseguro = psseguro;
                   --     AND ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_scontra := -1;
                        v_nversio := -1;
                  END;
            END;

            vpasexec := 2;
            vsquery :=   'SELECT 1 AS ORDEN, CATRIBU, TATRIBU, catribu AS CTRAMO, null AS CTRAMPA '
                       ||  'FROM detvalores '
                       || 'WHERE cidioma = pac_md_common.f_get_cxtidioma() '
                       || 'AND cvalor=8002002 '
                       || 'AND catribu = 0 union ';
            vsquery := vsquery || 'SELECT  2 AS ORDEN, CATRIBU, TATRIBU, catribu AS CTRAMO, null AS CTRAMPA '
                       || 'FROM detvalores '
                       || 'WHERE cidioma = pac_md_common.f_get_cxtidioma() '
                       || 'AND cvalor=8002002 '
                       || 'AND catribu IN (SELECT t.ctramo from tramos t ' || 'WHERE scontra = '
                       || v_scontra || ' and nversio = ' || v_nversio || ' ) '
                       || 'AND CATRIBU BETWEEN 1 AND 4 union ';
            vsquery := vsquery || 'SELECT 3 ORDEN, CATRIBU, TATRIBU, catribu AS CTRAMO, null AS CTRAMPA '
                       || 'FROM detvalores '
                       || 'WHERE cidioma = pac_md_common.f_get_cxtidioma() '
                       || 'AND cvalor=8002002 '
                       || 'AND catribu = 5 union ';
            vsquery := vsquery || 'SELECT  4 AS ORDEN, CATRIBU, TATRIBU, catribu AS CTRAMO, null AS CTRAMPA '
                       || 'FROM detvalores '
                       || 'WHERE cidioma = pac_md_common.f_get_cxtidioma() '
                       || 'AND cvalor=8002002 '
                       || 'AND catribu IN (SELECT t.ctramo from tramos t ' || 'WHERE scontra = '
                       || v_scontra || ' and nversio = ' || v_nversio || ' ) '
                       || 'AND CATRIBU BETWEEN 6 AND 10 union ';
            vsquery := vsquery || 'SELECT  5 AS ORDEN, CATRIBU + 10, TATRIBU, 0 AS CTRAMO, CATRIBU AS CTRAMPA '
                       || 'FROM detvalores '
                       || 'WHERE cidioma = pac_md_common.f_get_cxtidioma() '
                       || 'AND cvalor=8002001 '
                       || 'AND catribu IN (SELECT t.ctramo from tramos t ' || 'WHERE scontra = '
                       || v_scontra || ' and nversio = ' || v_nversio || ' and nvl(plocal,0) > 0) ';


            v_error := pac_md_log.f_log_consultas(vsquery,
                                                  'PAC_MD_ESTCESIONESREA.F_DETVALORES_TRAMOS', 1, 4,
                                                  mensajes);
            vpasexec := 3;
            cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
            vpasexec := 4;

     ELSE
            BEGIN
               SELECT c.scontra, c.nversio
                 INTO v_scontra, v_nversio
                 FROM cesionesrea c
                WHERE sseguro = psseguro
                  AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT c.scontra, c.nversio
                       INTO v_scontra, v_nversio
                       FROM estcesionesrea c
                      WHERE sseguro = psseguro
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_scontra := -1;
                        v_nversio := -1;
                  END;
            END;



            vpasexec := 2;
            vsquery := 'SELECT catribu,tatribu ' || 'FROM detvalores '
                       || 'WHERE cidioma = pac_md_common.f_get_cxtidioma() ' || 'AND cvalor=8002002 '
                       || 'AND catribu = 0 union ';
            vsquery := vsquery || 'SELECT catribu,tatribu ' || 'FROM detvalores '
                       || 'WHERE cidioma = pac_md_common.f_get_cxtidioma() ' || 'AND cvalor=8002002 '
                       || 'AND catribu IN (SELECT t.ctramo from tramos t ' || 'WHERE scontra = '
                       || v_scontra || ' and nversio = ' || v_nversio || ') union ';
            vsquery := vsquery || 'SELECT catribu,tatribu ' || 'FROM detvalores '
                       || 'WHERE cidioma = pac_md_common.f_get_cxtidioma() ' || 'AND cvalor=8002002 '
                       || 'AND catribu = 5';
            v_error := pac_md_log.f_log_consultas(vsquery,
                                                  'PAC_MD_ESTCESIONESREA.F_DETVALORES_TRAMOS', 1, 4,
                                                  mensajes);
            vpasexec := 3;
            cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
            vpasexec := 4;

      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_detvalores_tramos;
   -- ERH

   FUNCTION f_valida_tramos(pssegpol NUMBER)
      RETURN NUMBER IS
      vcesrec        estcesionesrea%ROWTYPE;
      v_retorno      NUMBER := 0;
      e_error        EXCEPTION;

      CURSOR c_estcesionesrea(pssegpol NUMBER) IS   -- Cursor totales cuando trae garantia (cvidaga = 2)
         SELECT   ctramo, ctrampa, COUNT(ctramo) cantidad--hans rea03
             FROM estcesionesrea e
            WHERE ssegpol = pssegpol
			  AND pcesion<>0 --BUGIAXIS-13247  En el menú de modificación  manual de cesiones no esta permitiendo modificar las    pólizas de RC
              AND fanulac IS NULL
              AND cgenera != 7--hans rea03
         --INICIO (22872 + 39214): AGG 28/01/2016
         GROUP BY ctramo, ctrampa, cgarant;
   --FIN (22872 + 39214): AGG 28/01/2016
   BEGIN
      FOR q1 IN c_estcesionesrea(pssegpol) LOOP   -- Calcular valores reales desde CESIONESREA.  El total del
         IF (q1.cantidad > 1) THEN
            RETURN 9908553;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         RETURN v_retorno;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_md_estcesionesrea.f_valida_tramos', 1,
                     'Error incontrolado', SQLERRM);
         RETURN 1000133;
   END f_valida_tramos;
BEGIN
   SELECT f_parinstalacion_n('EMPRESADEF')
     INTO gempresa
     FROM DUAL;

   SELECT pac_md_common.f_get_cxtidioma   --pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF')
     INTO gidioma
     FROM DUAL;
END pac_md_estcesionesrea;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ESTCESIONESREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ESTCESIONESREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ESTCESIONESREA" TO "PROGRAMADORESCSI";
