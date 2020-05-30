--------------------------------------------------------
--  DDL for Function F_DUPLICAR_ACTIVIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DUPLICAR_ACTIVIDAD" (
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pccolect IN NUMBER,
   pctipseg IN NUMBER,
   pcactivi IN NUMBER,
   pcactivic IN NUMBER,
   ptabla_err OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/********************************************************************
Duplica las garantías de la actividad PCACTIVI en la actividad PCACTIVIC.
Las tablas afectadas en la inserción son:
clausugar
comisionacti
comisiongar
forpagrecacti
garanformula
paractividad
pargaranpro
garanpro
incompgaran
codmorpar_garanpro
forpagrecgaran
garanprogas
garanpro_sbpri
garanpro_sbpri_depor
garanpro_sbpri_prof
garanprotramit
intcomprogar
intprogar
pregunprogaran
vinculaciones_prod
detcampanya
detcarencias
Se añade el campo CCLAMIN  0026501: POSRA400-(POSRA400)-Vida Grupo (Voluntario)  (MMS - 20130328)
********************************************************************/
   v_cactiviprod  NUMBER;
   v_cactivisegu  NUMBER;
   v_garanpro     NUMBER;
   v_codiactseg   NUMBER;
   v_sproduc      NUMBER;
   i              NUMBER;
   mensaje        NUMBER;
   vpasexec       NUMBER(8) := 1;
   vparam         VARCHAR2(2000)
      := 'pcramo' || pcramo || ' pcmodali ' || pcmodali || ' pccolect ' || pccolect
         || ' pctipseg ' || pctipseg || ' pcactivi ' || pcactivi || ' pcactivic ' || pcactivic
         || ' ptabla_err ' || ptabla_err;
   vobject        VARCHAR2(200) := 'f_duplicar_actividad';
BEGIN
   i := 0;
   mensaje := 0;

   BEGIN
      -- Buscamos el código de producto secuencia, sproduc para usarlo despues
      SELECT sproduc
        INTO v_sproduc
        FROM productos
       WHERE cmodali = pcmodali
         AND ccolect = pccolect
         AND ctipseg = pctipseg
         AND cramo = pcramo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         i := 1;
         mensaje := 120040;   -- Error al obtener datos de la tabla #1
         ptabla_err := 'PRODUCTOS';
      WHEN OTHERS THEN
         mensaje := 120040;   -- Error al obtener datos de la tabla #1
         ptabla_err := 'PRODUCTOS';
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   END;

   BEGIN
      -- Buscamos que exista un registro en codiactseg
      SELECT cactivi
        INTO v_codiactseg
        FROM codiactseg
       WHERE cactivi = pcactivic
         AND cramo = pcramo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         i := 1;
         mensaje := 120040;   -- Error al obtener datos de la tabla #1
         ptabla_err := 'CODIACTSEG';
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         mensaje := 120040;   -- Error al obtener datos de la tabla #1
         ptabla_err := 'CODIACTSEG';
   END;

   BEGIN
      -- Buscamos que exista un registro en activiprod
      SELECT cactivi
        INTO v_cactiviprod
        FROM activiprod
       WHERE cmodali = pcmodali
         AND ccolect = pccolect
         AND ctipseg = pctipseg
         AND cactivi = pcactivic
         AND cramo = pcramo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         i := 1;
         mensaje := 120040;   -- Error al obtener datos de la tabla #1
         ptabla_err := 'ACTIVIPROD';
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         mensaje := 120040;   -- Error al obtener datos de la tabla #1
         ptabla_err := 'ACTIVIPROD';
   END;

   -- Buscamos que exista un registro en activisegu
   BEGIN
      SELECT COUNT(cactivi)
        INTO v_cactivisegu
        FROM activisegu
       WHERE cramo = pcramo
         AND cactivi = pcactivic;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         mensaje := 120040;   -- Error al obtener datos de la tabla #1
         ptabla_err := 'ACTIVISEGU';
   END;

   IF v_cactivisegu = 0 THEN
      i := 1;
      mensaje := 120040;   -- Error al obtener datos de la tabla #1
      ptabla_err := 'ACTIVISEGU';
   END IF;

   -- Buscamos que no exista ningún registro en garanpro
   BEGIN
      SELECT COUNT(*)
        INTO v_garanpro
        FROM garanpro
       WHERE cmodali = pcmodali
         AND ccolect = pccolect
         AND ctipseg = pctipseg
         AND cactivi = pcactivic
         AND cramo = pcramo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         mensaje := 120040;   -- Error al obtener datos de la tabla #1
         ptabla_err := 'GARANPRO';
   END;

   IF v_garanpro >= 1 THEN
      i := 1;
      mensaje := 120042;   -- La actividad destino ya tiene garantías
      ptabla_err := NULL;
   END IF;

   -- Sabemos que no existe en activiprod, ni en activisegu ni en codiactseg y no hay nada en garanpro
   IF i = 0 THEN
      /*Inserta en clausugar con las mismas garantias*/
      BEGIN
         INSERT INTO clausugar
                     (cmodali, ccolect, cramo, ctipseg, cgarant, cactivi, sclapro, caccion)
            SELECT cmodali, ccolect, cramo, ctipseg, cgarant, pcactivic, sclapro, caccion
              FROM clausugar
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'CLAUSUGAR';
      END;

      /*Inserta en comisionacti*/
      BEGIN
         INSERT INTO comisionacti
                     (ccomisi, cactivi, cramo, cmodcom, pcomisi, cmodali, ctipseg, ccolect)
            SELECT ccomisi, pcactivic, cramo, cmodcom, pcomisi, cmodali, ctipseg, ccolect
              FROM comisionacti
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'COMISIONACTI';
      END;

      /*Inserta en comisiongar*/
      BEGIN
         INSERT INTO comisiongar
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ccomisi, cmodcom,
                      pcomisi)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, ccomisi, cmodcom,
                   pcomisi
              FROM comisiongar
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'COMISIONGAR';
      END;

      /*Inserta en forpagrecacti*/
      BEGIN
         INSERT INTO forpagrecacti
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cforpag, precarg)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cforpag, precarg
              FROM forpagrecacti
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'FORPAGRECACTI';
      END;

      /*Inserta en garanformula*/
      BEGIN
         INSERT INTO garanformula
                     (cgarant, ccampo, cramo, cmodali, ctipseg, ccolect, cactivi, clave)
            SELECT cgarant, ccampo, cramo, cmodali, ctipseg, ccolect, pcactivic, clave
              FROM garanformula
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'GARANFORMULA';
      END;

      /*Inserta en paractividad*/
      BEGIN
         INSERT INTO paractividad
                     (sproduc, cactivi, cparame, ctippar, tvalpar, nvalpar, fvalpar)
            SELECT sproduc, pcactivic, cparame, ctippar, tvalpar, nvalpar, fvalpar
              FROM paractividad
             WHERE cactivi = pcactivi
               AND sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'PARACTIVIDAD';
      END;

      /*Inserta en pargaranpro*/
      BEGIN
         INSERT INTO pargaranpro
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cpargar, cvalpar)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, cpargar, cvalpar
              FROM pargaranpro
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'PARGARANPRO';
      END;

      /*Inserta en garanpro*/
      BEGIN
         INSERT INTO garanpro
                     (cmodali, ccolect, cramo, cgarant, ctipseg, ctarifa, norden, ctipgar,
                      ctipcap, ctiptar, cgardep, pcapdep, ccapmax, icapmax, icapmin, nedamic,
                      nedamac, nedamar, cformul, ctipfra, ifranqu, cgaranu, cimpcon, cimpdgs,
                      cimpips, cimpces, cimparb, cdtocom, crevali, cextrap, crecarg, cmodtar,
                      prevali, irevali, cmodrev, cimpfng, cactivi, ctarjet, ctipcal, cimpres,
                      cpasmax, cderreg, creaseg, cexclus, crenova, ctecnic, cbasica, cprovis,
                      ctabla, precseg, cramdgs, cdtoint, icaprev, iprimax, iprimin, ciedmac,
                      ciedmic, ciedmar, sproduc, cobjaseg, csubobjaseg, cgenrie, cofersn,
                      nparben, nbns, crecfra, ciema2c, ciemi2c, ciema2r, nedma2c, nedmi2c,
                      nedma2r, cclacap, cmodint, ctarman, cclamin)   -- Bug 26501 - MMS - 28/03/2013
            SELECT cmodali, ccolect, cramo, cgarant, ctipseg, ctarifa, norden, ctipgar,
                   ctipcap, ctiptar, cgardep, pcapdep, ccapmax, icapmax, icapmin, nedamic,
                   nedamac, nedamar, cformul, ctipfra, ifranqu, cgaranu, cimpcon, cimpdgs,
                   cimpips, cimpces, cimparb, cdtocom, crevali, cextrap, crecarg, cmodtar,
                   prevali, irevali, cmodrev, cimpfng, pcactivic, ctarjet, ctipcal, cimpres,
                   cpasmax, cderreg, creaseg, cexclus, crenova, ctecnic, cbasica, cprovis,
                   ctabla, precseg, cramdgs, cdtoint, icaprev, iprimax, iprimin, ciedmac,
                   ciedmic, ciedmar, sproduc, cobjaseg, csubobjaseg, cgenrie, cofersn,
                   nparben, nbns, crecfra, ciema2c, ciemi2c, ciema2r, nedma2c, nedmi2c,
                   nedma2r, cclacap, cmodint, ctarman, cclamin   -- Bug 26501 - MMS - 28/03/2013
              FROM garanpro
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'GARANPRO';
      END;

      /*Inserta en incompgaran*/
      BEGIN
         INSERT INTO incompgaran
                     (cramo, cmodali, ctipseg, ccolect, cgarant, cgarinc, cactivi)
            SELECT cramo, cmodali, ctipseg, ccolect, cgarant, cgarinc, pcactivic
              FROM incompgaran
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'INCOMPGARAN';
      END;

      /*Inserta en codmorpar_garanpro*/
      BEGIN
         INSERT INTO codmorpar_garanpro
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, scodmorpar,
                      fini_vig, ffin_vig, cusualt, falta, cusumod, fmodif)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, scodmorpar, fini_vig,
                   ffin_vig, cusualt, falta, cusumod, fmodif
              FROM codmorpar_garanpro
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'CODMORPAR_GARANPRO';
      END;

      /*Inserta en forpagrecgaran*/
      BEGIN
         INSERT INTO forpagrecgaran
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cforpag, precarg)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, cforpag, precarg
              FROM forpagrecgaran
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'FORPAGRECGARAN';
      END;

      /*Inserta en garanprogas*/
      BEGIN
         INSERT INTO garanprogas
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cgasto, fini, ffin,
                      pmin, pmax, pvalor, nprima, nmod, cusualt, falta, cusumod, fmodif,
                      pminres, pmaxres, pvalres)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, cgasto, fini, ffin,
                   pmin, pmax, pvalor, nprima, nmod, cusualt, falta, cusumod, fmodif, pminres,
                   pmaxres, pvalres
              FROM garanprogas
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'GARANPROGAS';
      END;

      /*Inserta en garanpro_sbpri*/
      BEGIN
         INSERT INTO garanpro_sbpri
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ctipspr, fini, ffin,
                      ccalspr, nvalor, ncomisi)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, ctipspr, fini, ffin,
                   ccalspr, nvalor, ncomisi
              FROM garanpro_sbpri
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'GARANPRO_SBPRI';
      END;

      /*Inserta en garanpro_sbpri_depor*/
      BEGIN
         INSERT INTO garanpro_sbpri_depor
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cdeport, nvalor)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, cdeport, nvalor
              FROM garanpro_sbpri_depor
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'GARANPRO';
      END;

      /*Inserta en garanpro_sbpri_prof*/
      BEGIN
         INSERT INTO garanpro_sbpri_prof
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cprofes, nvalor)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, cprofes, nvalor
              FROM garanpro_sbpri_prof
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'GARANPRO_SBPRI_PROF';
      END;

      /*Inserta en garanprotramit*/
      BEGIN
         INSERT INTO garanprotramit
                     (sproduc, cactivi, cgarant, ctramit, cusualt, falta, cusumod, fmodif)
            SELECT sproduc, pcactivic, cgarant, ctramit, cusualt, falta, cusumod, fmodif
              FROM garanprotramit
             WHERE cactivi = pcactivi
               AND sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'GARANPROTRAMIT';
      END;

      /*Inserta en intcomprogar*/
      BEGIN
         INSERT INTO intcomprogar
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, fini, ffin, pintcom,
                      cusualt, falta, cusumod, fmodif)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, fini, ffin, pintcom,
                   cusualt, falta, cusumod, fmodif
              FROM intcomprogar
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'INTCOMPROGAR';
      END;

      /*Inserta en intprogar*/
      BEGIN
         INSERT INTO intprogar
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, fini, ffin, cref,
                      cintref, pdif, pinttec, cusualt, falta, cusumod, fmodif, pmax, pmin)
            SELECT cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant, fini, ffin, cref,
                   cintref, pdif, pinttec, cusualt, falta, cusumod, fmodif, pmax, pmin
              FROM intprogar
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'INTPROGAR';
      END;

      /*Inserta en pregunprogaran*/
      BEGIN
         INSERT INTO pregunprogaran
                     (sproduc, cactivi, cgarant, cpregun, cpretip, npreord, tprefor, cpreobl,
                      npreimp, cresdef)
            SELECT sproduc, pcactivic, cgarant, cpregun, cpretip, npreord, tprefor, cpreobl,
                   npreimp, cresdef
              FROM pregunprogaran
             WHERE cactivi = pcactivi
               AND sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'PREGUNPROGARAN';
      END;

      /*Inserta en vinculaciones_prod*/
      BEGIN
         INSERT INTO vinculaciones_prod
                     (cvinclo, cramo, cmodali, ctipseg, ccolect, cactivi, cgarant,
                      tipo_descuento, descuento)
            SELECT cvinclo, cramo, cmodali, ctipseg, ccolect, pcactivic, cgarant,
                   tipo_descuento, descuento
              FROM vinculaciones_prod
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'VINCULACIONES_PROD';
      END;

      /*Inserta en detcampanya*/
      BEGIN
         INSERT INTO detcampanya
                     (ccampanya, nversio, sproduc, cactivi, cgarant, fefever, ffinver,
                      cestado, finicam, ffincam, ctipdto, idto, pdto, caplidto, cduraci,
                      nmeses, nedalim, nedamax, nedamin, csexe, falta, cusualt, fmodif,
                      cusumod)
            SELECT ccampanya, nversio, sproduc, pcactivic, cgarant, fefever, ffinver, cestado,
                   finicam, ffincam, ctipdto, idto, pdto, caplidto, cduraci, nmeses, nedalim,
                   nedamax, nedamin, csexe, falta, cusualt, fmodif, cusumod
              FROM detcampanya
             WHERE cactivi = pcactivi
               AND sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'DETCAMPANYA';
      END;

      /*Inserta en detcarencias*/
      BEGIN
         INSERT INTO detcarencias
                     (csexo, nmescar, cgarant, ccaren, sproduc, cactivi, cramo, cmodali,
                      ctipseg, ccolect)
            SELECT csexo, nmescar, cgarant, ccaren, sproduc, pcactivic, cramo, cmodali,
                   ctipseg, ccolect
              FROM detcarencias
             WHERE cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            mensaje := 120038;   -- Error al insertar en la tabla #1
            ptabla_err := 'DETCARENCIAS';
      END;

      IF mensaje <> 0 THEN
         ROLLBACK;
      ELSE
         COMMIT;
      END IF;
   END IF;

   RETURN mensaje;
END;

/

  GRANT EXECUTE ON "AXIS"."F_DUPLICAR_ACTIVIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DUPLICAR_ACTIVIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DUPLICAR_ACTIVIDAD" TO "PROGRAMADORESCSI";
