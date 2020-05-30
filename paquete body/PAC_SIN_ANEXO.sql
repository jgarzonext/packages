--------------------------------------------------------
--  DDL for Package Body PAC_SIN_ANEXO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIN_ANEXO" IS
   /******************************************************************************
   NOMBRE:     PAC_SIN_ANEXO
   PROP¿SITO:  Cuerpo del paquete de las funciones para
      los m¿dulos del area de SINIESTROS
   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/11/2016   IGIL       1. Creaci¿n del package.
*/
  FUNCTION f_get_datos_sin(
      psprofes IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pnsinies IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_datos_sin';
      vparam         VARCHAR2(200) := '';
     -- ptselect        VARCHAR2(5000);
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT '||
' g.nsinies as TSINIES, '||
' g.sseguro, ' ||
' g.ntramit , ' ||
' dm.tatribu as TESTADO, '||
' dt.ttramit as TTRAMIT, '||
' t.nradica as TTIPUSTRAM, '||
' dg.tatribu as TATRIBU, G.SPROFES as TSPROFES, '||
'          dp.tnombre || '' '' || dp.tapelli1 || '' '' || dp.tapelli2 PROFESIONAL, mg.falta as TFALTA  '||
' , ff_desvalorfijo(800, pac_md_common.f_get_cxtidioma(),t.ctramit  ) TTIPTRA ' ||
' , ff_desvalorfijo(665, pac_md_common.f_get_cxtidioma(),m.csubtra  ) TSUBEST ' ||
' , (select ttramitad from sin_codtramitador where ctramitad = m.cunitra) TUNITRA ' ||
' , (select ttramitad from sin_codtramitador where ctramitad = m.ctramitad) TTRAMITAD ' ||
'     FROM sin_tramita_gestion g, sin_tramita_movimiento m, detvalores dm, sin_tramitacion t, sin_destramitacion dt, sin_prof_profesionales p, '||
'          per_detper dp, sin_tramita_movgestion mg, detvalores dg, sin_codtramitacion codtram, per_personas pr '||
'    WHERE m.nsinies = g.nsinies  '||
'       AND m.nmovtra = (SELECT max(x.nmovtra) ' ||
'                          FROM sin_tramita_movimiento x ' ||
'                         WHERE x.nsinies = m.nsinies ' ||
'                           AND x.ntramit = g.ntramit )  ' ||
'      AND m.ntramit = g.ntramit  '||
'      AND dm.cvalor = 6  '||
'      AND dm.catribu = m.cesttra  '||
'      AND dm.cidioma = 8  '||
'      AND t.nsinies = g.nsinies  '||
'      AND t.ntramit = g.ntramit  '||
'      AND dt.ctramit = t.ctramit  '||
'      AND dt.cidioma = dm.cidioma  '||
'      AND p.sprofes = g.sprofes  '||
'      AND dp.sperson = p.sperson  '||
'      AND dp.sperson = pr.sperson '||
'      AND pr.cagente = dp.cagente '||
'      AND mg.sgestio = g.sgestio  '||
'      AND mg.nmovges = ( '||
'                        SELECT MIN(nmovges)  '||
'                          FROM sin_tramita_movgestion xx  '||
'                         WHERE xx.sgestio = mg.sgestio  '||
'                           AND xx.ctipmov = 1 )  '||
'      AND DG.CVALOR = 722    '||
'      AND dg.catribu = g.ctipges  '||
'      AND dg.cidioma = dm.cidioma '||
'      AND codtram.ctramit = t.ctramit';

      IF psprofes IS NOT NULL THEN
         ptselect := ptselect || ' AND p.sprofes = ' || psprofes;
      END IF;

       IF pnsinies IS NOT NULL THEN
         ptselect := ptselect || ' AND m.nsinies = ' || pnsinies;
      END IF;

      -- dbms_output.put_line(ptselect);

      p_control_error(1000000, 'PAC_SINIESTROS',
                            ptselect);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_datos_sin;
END pac_sin_anexo;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_ANEXO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_ANEXO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_ANEXO" TO "PROGRAMADORESCSI";
