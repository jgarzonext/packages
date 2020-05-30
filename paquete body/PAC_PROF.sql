--------------------------------------------------------
--  DDL for Package Body PAC_PROF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROF" AS
/******************************************************************************
   NOMBRE:    PAC_PROF
   PROPSITO: Funciones para profesionales

   REVISIONES:
   Ver        Fecha        Autor             Descripcin
   ---------  ----------  ---------------  ------------------------------------
    1.0       08/11/2012   JDS             Creacion
    2.0       28/05/2013   ETM             0026318: POSS038-(POSIN011)-Interfaces:IAXIS-SAP: Interfaz de Personas
    3.0       31/01/2018   ACL             TCS_1569B: Se modifica la funcin f_set_profesional.
    4.0	      01/03/2019   CES		   	   TCS_1554: Convivencia Osiris iAxis
    5.0		  19/07/2019    PK	           Cambio de IAXIS-4844 - Optimizar Petición Servicio I017
	6.0		  18/03/2020	SP			   Cambios de  tarea IAXIS-13044
******************************************************************************/
   FUNCTION f_get_lstccc(psprofes IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
      vtraza         NUMBER := 0;
   BEGIN
      SELECT sperson
        INTO vsperson
        FROM sin_prof_profesionales
       WHERE sprofes = psprofes;

      vtraza := 1;
      ptselect := 'select cbancar,cnordban from per_ccc where sperson = ' || vsperson;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROF.F_GET_LSTCCC', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_lstccc;

   FUNCTION f_ins_ccc(
      psprofes IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcnordban IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
        Graba una linea de detalle en SIN_PROF_CCC
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_ins_ccc';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pcramo=' || pcramo || ' psproduc='
            || psproduc || ' pcactivi=' || pcactivi || ' pcnordban=' || pcnordban;
      vnumcccs       NUMBER := 0;
      vpasexec       NUMBER := 0;
      vnorden        NUMBER := 0;
   BEGIN
      IF pcramo IS NULL
         AND psproduc IS NULL
         AND pcactivi IS NULL THEN
         SELECT COUNT(sprofes)
           INTO vnumcccs
           FROM sin_prof_ccc
          WHERE sprofes = psprofes
            AND cramo IS NULL
            AND sproduc IS NULL
            AND cactivi IS NULL;

         IF vnumcccs > 0 THEN
            RETURN 1;
         END IF;
      END IF;

      SELECT MAX(cnorden + 1)
        INTO vnorden
        FROM sin_prof_ccc
       WHERE sprofes = psprofes;

      IF vnorden IS NULL THEN
         vnorden := 1;
      END IF;

      INSERT INTO sin_prof_ccc
                  (sprofes, cnorden, cramo, sproduc, cactivi, cnordban, cusualt, falta)
           VALUES (psprofes, vnorden, pcramo, psproduc, pcactivi, pcnordban, f_user, f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_ins_ccc', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_ins_ccc;

   FUNCTION f_get_dades_profesional(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_profesional IS
      vpasexec       NUMBER(8) := 1;
      i              NUMBER := 1;
      vparam         VARCHAR2(3000) := 'PSPROFES=' || psprofes;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_dades_profesional';
      v_error        NUMBER;
      v_result       ob_iax_profesional := ob_iax_profesional();
      v_prof_ccc     ob_iax_prof_ccc := ob_iax_prof_ccc();
      t_v_prof_ccc   t_iax_prof_ccc := t_iax_prof_ccc();

      CURSOR cur_prof_ccc IS
         SELECT *
           FROM sin_prof_ccc
          WHERE sprofes = psprofes;

      v_reg          cur_prof_ccc%ROWTYPE;
   BEGIN
      vpasexec := 2;

      OPEN cur_prof_ccc;

      LOOP
         FETCH cur_prof_ccc
          INTO v_reg;

         EXIT WHEN cur_prof_ccc%NOTFOUND;
         v_prof_ccc.cnorden := v_reg.cnorden;
         v_prof_ccc.cramo := v_reg.cramo;
         v_prof_ccc.tramo := NULL;
         v_prof_ccc.sproduc := v_reg.sproduc;
         v_prof_ccc.sproduc := v_reg.sproduc;
         v_prof_ccc.tproduc := NULL;
         v_prof_ccc.cactivi := v_reg.cactivi;
         v_prof_ccc.cnordban := v_reg.cnordban;
         v_prof_ccc.cbancar := NULL;
         t_v_prof_ccc.EXTEND;
         t_v_prof_ccc(i) := v_prof_ccc;
         i := i + 1;
      END LOOP;

      CLOSE cur_prof_ccc;

      v_result.sprofes := psprofes;
      vpasexec := 3;
      v_result.cuentas := t_v_prof_ccc;
      RETURN v_result;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_dades_profesional;

   FUNCTION f_get_ccc(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_ccc';
      vnumerr        NUMBER := 0;
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT to_number(c.cnorden),
       to_number(c.cramo),
      to_char(DECODE(c.cramo,0,f_axis_literales(100934, '
         || pcidioma || '),ff_desramo(c.cramo, ' || pcidioma
         || '))),
             to_number(c.sproduc),
             to_char(F_DESPRODUCTO_T (pr.cramo ,  pr.cmodali, pr.ctipseg, pr.ccolect , 2, '
         || pcidioma
         || ' )),
             to_number(c.cactivi),
            substr(to_char(ff_desactividad(c.cactivi, c.cramo,'
         || pcidioma
         || ')),1,40),
            to_number(c.cnordban),
            to_char(p.cbancar)
      FROM   sin_prof_ccc c, per_ccc p, sin_prof_profesionales per,
             productos pr
      WHERE  p.sperson = per.sperson
        AND  c.sprofes = '
         || psprofes
         || '
        AND  c.sprofes = per.sprofes
        AND  p.cnordban = c.cnordban
        AND  pr.sproduc (+)= c.sproduc
        AND  c.fbaja is null
      ORDER BY c.falta';
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_ccc;

   FUNCTION f_set_estado(
      sprofes IN NUMBER,
      cestprf IN NUMBER,
      festado IN DATE,
      cmotbaja IN NUMBER,
      tobservaciones IN VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
        Graba una linea de detalle en SIN_PROF_ESTADOS
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_estado';
      vparam         VARCHAR2(500)
         := 'parametros sprofes=' || sprofes || 'cestprf=' || cestprf || ' festado='
            || festado || ' cmotbaja=' || cmotbaja || ' tobservaciones=' || tobservaciones;
      vnumcccs       NUMBER := 0;
      vpasexec       NUMBER := 0;
      vnorden        NUMBER := 0;
   BEGIN
      IF cestprf = 3
         AND festado < f_sysdate THEN
         RETURN 9904705;
      ELSE
         INSERT INTO sin_prof_estados
                     (sprofes, cestado, festado, cmotbaj, tobserv, canulad, cusualt,
                      falta)
              VALUES (sprofes, cestprf, festado, cmotbaja, tobservaciones, 0, f_user,
                      f_sysdate);

         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_estado', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_estado;

   FUNCTION f_get_estados(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_estados';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT e.cestado, d.tatribu, e.festado, e.cmotbaj, d1.tatribu, e.tobserv, e.canulad, e.cusualt
         FROM sin_prof_estados e, detvalores d, detvalores d1
        WHERE d.catribu = e.cestado
          AND d.cvalor = 742
          AND d.cidioma = '
         || pcidioma
         || '
          AND d1.catribu(+) = e.cmotbaj
          AND d1.cvalor(+) = 1066
          AND d1.cidioma(+) = '
         || pcidioma || '
          AND sprofes = ' || psprofes || '
          ORDER BY e.festado desc';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_estados;

   FUNCTION f_del_estado(psprofes IN NUMBER, pfestado IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
        Anula una linea de detalle en SIN_PROF_ESTADOS
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_del_estado';
      vparam         VARCHAR2(500)
                               := 'parametros sprofes=' || psprofes || ' festado=' || pfestado;
      vpasexec       NUMBER := 0;
   BEGIN
      IF TRUNC(pfestado) >= TRUNC(f_sysdate) THEN
         UPDATE sin_prof_estados
            SET canulad = 1
          WHERE sprofes = psprofes
            AND festado = pfestado;

         COMMIT;
         RETURN 0;
      ELSE
         RETURN 9904699;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_del_estado', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_estado;

   FUNCTION f_del_ccc(psprofes IN NUMBER, pcnorden IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
        Elimina una linea de detalle en SIN_PROF_CCC
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_del_ccc';
      vparam         VARCHAR2(500)
                              := 'parametros sprofes=' || psprofes || ' pcnorden=' || pcnorden;
      vpasexec       NUMBER := 0;
   BEGIN
      UPDATE sin_prof_ccc
         SET fbaja = f_sysdate,
             cusubaj = f_user
       WHERE sprofes = psprofes
         AND cnorden = pcnorden;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_ccc', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_ccc;

   FUNCTION f_set_zona(
      psprofes IN NUMBER,
      pctpzona IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcposini IN VARCHAR2,
      pcposfin IN VARCHAR2,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
        Graba una linea de detalle en SIN_PROF_ZONAS
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_zona';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pctpzona=' || pctpzona || ' pcprovin='
            || pcprovin || ' pcpoblac=' || pcpoblac || ' pcposini=' || pcposini
            || ' pcposfin=' || pcposfin || ' pfdesde=' || pfdesde || ' pfhasta=' || pfhasta;
      vnumcccs       NUMBER := 0;
      vpasexec       NUMBER := 0;
      vcnordzn       NUMBER := 0;
      vcprovin       NUMBER := 0;
   BEGIN
      IF pctpzona = 2
         AND pcprovin IS NULL THEN
         RETURN 9904714;
      END IF;

      IF pctpzona = 3
         AND pcpoblac IS NULL THEN
         RETURN 9904931;
      END IF;

      IF pctpzona = 4
         AND(pcposfin IS NULL
             OR pcposini IS NULL) THEN
         RETURN 9904715;
      END IF;

      IF TRUNC(pfdesde) < TRUNC(f_sysdate) THEN
         RETURN 9904716;
      END IF;

      SELECT MAX(cnordzn) + 1
        INTO vcnordzn
        FROM sin_prof_zonas
       WHERE sprofes = psprofes;

      IF vcnordzn IS NULL THEN
         vcnordzn := 1;
      END IF;

      vcprovin := pcprovin;

      IF pctpzona IN(1, 4) THEN
         vcprovin := 0;
      END IF;

      INSERT INTO sin_prof_zonas
                  (sprofes, cnordzn, ctpzona, cpais, cprovin, cpoblac, cposini,
                   cposfin, fdesde, fhasta, cusualt, falta)
           VALUES (psprofes, vcnordzn, pctpzona, pcpais, vcprovin, pcpoblac, pcposini,
                   pcposfin, pfdesde, pfhasta, f_user, f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_zona', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_zona;

   FUNCTION f_get_zonas(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_zonas';
      vparam         VARCHAR2(500)
                           := 'parametros psprofes= ' || psprofes || ' pcidioma= ' || pcidioma;
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT z.cnordzn, z.ctpzona, d.tatribu, z.cpais, p.tpais, z.cprovin, null, z.cpoblac, null,
                 substr(to_char(z.cposini,''09999''),2,5), substr(to_char(z.cposfin,''09999''),2,5), z.fdesde, z.fhasta
            FROM sin_prof_zonas z, detvalores d, paises p
           WHERE d.catribu = z.ctpzona
             AND d.cvalor  = 728
             AND d.cidioma = '
         || pcidioma
         || '
             AND z.ctpzona = 1
             AND p.cpais = z.cpais
             AND z.sprofes = '
         || psprofes
         || '
          UNION
          SELECT z.cnordzn, z.ctpzona, d.tatribu, z.cpais, NULL, z.cprovin, pr.tprovin, z.cpoblac, null,
                 substr(to_char(z.cposini,''09999''),2,5), substr(to_char(z.cposfin,''09999''),2,5), z.fdesde, z.fhasta
            FROM sin_prof_zonas z, detvalores d, provincias pr
           WHERE d.catribu = z.ctpzona
             AND d.cvalor  = 728
             AND d.cidioma = '
         || pcidioma
         || '
             AND z.ctpzona = 2
             AND pr.cpais = z.cpais
             AND pr.cprovin = z.cprovin
             AND z.sprofes = '
         || psprofes
         || '
          UNION
          SELECT z.cnordzn, z.ctpzona, d.tatribu, z.cpais, NULL, z.cprovin, pr.tprovin, z.cpoblac, po.tpoblac,
                 substr(to_char(z.cposini,''09999''),2,5), substr(to_char(z.cposfin,''09999''),2,5), z.fdesde, z.fhasta
            FROM sin_prof_zonas z, detvalores d, provincias pr, poblaciones po
           WHERE d.catribu = z.ctpzona
             AND d.cvalor  = 728
             AND d.cidioma = '
         || pcidioma
         || '
             AND z.ctpzona = 3
             AND pr.cpais = z.cpais
             AND pr.cprovin = z.cprovin
             AND z.sprofes = '
         || psprofes
         || '
             AND po.cprovin = z.cprovin
             AND po.cpoblac = z.cpoblac';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_zonas;

   FUNCTION f_mod_zona(psprofes IN NUMBER, pcnordzn IN NUMBER, pfhasta IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
        Modifica la fecha hasta la cual est asignada esa zona
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_mod_zona';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pcnordzn=' || pcnordzn || ' pfhasta='
            || pfhasta;
      vnumcccs       NUMBER := 0;
      vpasexec       NUMBER := 0;
      vcnordzn       NUMBER := 0;
      vcprovin       NUMBER := 0;
   BEGIN
      IF TRUNC(pfhasta) < TRUNC(f_sysdate) THEN
         RETURN 9904718;
      END IF;

      UPDATE sin_prof_zonas
         SET fhasta = pfhasta
       WHERE sprofes = psprofes
         AND cnordzn = pcnordzn;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_mod_zona', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_mod_zona;

   FUNCTION f_set_contacto_per(
      psprofes IN NUMBER,
      pctipdoc IN NUMBER,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptmovil IN VARCHAR2,
      ptemail IN VARCHAR2,
      ptcargo IN VARCHAR2,
      ptdirecc IN VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
        Graba una linea de detalle en SIN_PROF_CONTACTOS
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_contacto_per';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pctipdoc=' || pctipdoc || ' pnnumnif='
            || pnnumnif || ' ptnombre=' || ptnombre || ' ptmovil=' || ptmovil || ' ptemail='
            || ptemail || ' ptcargo=' || ptcargo || ' ptdirecc=' || ptdirecc;
      vpasexec       NUMBER := 0;
      vnordcto       NUMBER := 0;
   BEGIN
      IF ptemail NOT LIKE '%@%' THEN
         RETURN 9904619;
      END IF;

      IF pnnumnif IS NULL
         AND ptmovil IS NULL
         AND ptemail IS NULL
         AND ptdirecc IS NULL THEN
         RETURN 9904736;
      END IF;

      SELECT MAX(nordcto) + 1
        INTO vnordcto
        FROM sin_prof_contactos
       WHERE sprofes = psprofes;

      IF vnordcto IS NULL THEN
         vnordcto := 1;
      END IF;

      INSERT INTO sin_prof_contactos
                  (sprofes, nordcto, ctipide, cnumide, tnombre, tmovil, temail,
                   tcargo, tdirec, cusualt, falta)
           VALUES (psprofes, vnordcto, pctipdoc, pnnumnif, ptnombre, ptmovil, ptemail,
                   ptcargo, ptdirecc, f_user, f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_contacto_per', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_contacto_per;

   FUNCTION f_get_contactos_per(psprofes IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_contactos_per';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT nordcto, ctipide, cnumide, tnombre, tmovil, temail, tcargo, tdirec, fbaja, cusubaj
                     FROM sin_prof_contactos
                    WHERE sprofes = '
         || psprofes || 'ORDER BY falta desc';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_contactos_per;

   FUNCTION f_del_contacto_per(psprofes IN NUMBER, pnordcto IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
        Elimina la persona de contacto del profesional
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_del_contacto_per';
      vparam         VARCHAR2(500)
                              := 'parametros sprofes=' || psprofes || ' pnordcto=' || pnordcto;
      vpasexec       NUMBER := 0;
   BEGIN
      UPDATE sin_prof_contactos
         SET fbaja = f_sysdate,
             cusubaj = f_user
       WHERE sprofes = psprofes
         AND nordcto = pnordcto;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_del_contacto_per', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_contacto_per;

   FUNCTION f_get_ctipprof(psprofes IN NUMBER, pcidioma IN NUMBER, pquery IN OUT VARCHAR2)
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_ctipprof';
   BEGIN
      vtraza := 1;
      pquery :=
         'SELECT sprofes, ctippro, csubpro, cusualt, falta, d.tatribu
                     FROM sin_prof_rol p, detvalores d
                    WHERE p.sprofes = '
         || psprofes || '
                      AND d.cidioma = ' || pcidioma
         || '
                      AND p.ctippro = d.catribu
                      AND d.cvalor = 724
                      AND p.fbaja IS NULL';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_ctipprof;

   FUNCTION f_get_csubprof(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcidioma IN NUMBER,
      pquery IN OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_csubprof';
   BEGIN
      vtraza := 1;
      pquery :=
         'SELECT sprofes, ctippro, csubpro, cusualt, falta, d.tatribu
                     FROM sin_prof_rol p, detvalores d
                    WHERE p.sprofes = '
         || psprofes || '
                      AND p.ctippro = ' || pctippro
         || '
                      AND d.cidioma = ' || pcidioma
         || '
                      AND p.csubpro = d.catribu
                      AND d.cvalor = 725
                      AND p.fbaja IS NULL';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_csubprof;

   FUNCTION f_set_carga(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pncardia IN NUMBER,
      pncarsem IN NUMBER,
      pfdesde IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
          Graba una linea de detalle en SIN_PROF_CARGA
          return              : NUMBER 0(ok) / 1(error)
        *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_carga';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro || ' pncardia=' || pncardia || ' pncarsem=' || pncarsem || ' pfdesde='
            || pfdesde;
      vpasexec       NUMBER := 0;
   BEGIN
      INSERT INTO sin_prof_carga
                  (sprofes, ctippro, csubpro, ncardia, ncarsem, fdesde, cusualt,
                   falta)
           VALUES (psprofes, pctippro, pcsubpro, pncardia, pncarsem, pfdesde, f_user,
                   f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_carga', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_carga;

   FUNCTION f_valida_carga(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pfdesde IN DATE,
      ptipo IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_valida_carga';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro || ' pfdesde=' || pfdesde || ' ptipo=' || ptipo;
      vpasexec       NUMBER := 0;
      vcapacidad     NUMBER := 0;
      vfdesde        DATE;
   BEGIN
      IF ptipo = 1 THEN
         BEGIN
            SELECT NVL(ncapaci, -1)
              INTO vcapacidad
              FROM sin_prof_carga_real
             WHERE sprofes = psprofes
               AND ctippro = pctippro
               AND csubpro = pcsubpro
               AND fdesde = pfdesde;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcapacidad := -1;
         END;

         IF vcapacidad <> 100
            AND vcapacidad <> -1 THEN
            RETURN 9904743;
         END IF;

         SELECT MAX(fdesde)
           INTO vfdesde
           FROM sin_prof_carga
          WHERE sprofes = psprofes
            AND fbaja IS NULL;

         IF pfdesde <= vfdesde THEN
            RETURN 9904744;
         END IF;
      ELSE
         IF ptipo = 2 THEN
            SELECT MAX(fdesde)
              INTO vfdesde
              FROM sin_prof_carga_real
             WHERE sprofes = psprofes
               AND fbaja IS NULL;

            IF pfdesde <= vfdesde THEN
               RETURN 9904744;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_valida_carga', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_valida_carga;

   FUNCTION f_get_carga(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_carga';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT p.ctippro, d.tatribu, p.csubpro, d1.tatribu, ncardia, ncarsem, ncarmes, fdesde
                   FROM   sin_prof_carga p, detvalores d, detvalores d1
                   WHERE  d.catribu = p.ctippro
                   AND    d.cidioma = '
         || pcidioma
         || '
                   AND    d.cvalor = 724
                   AND    d1.catribu = p.csubpro
                   AND    d1.cidioma = '
         || pcidioma
         || '
                   AND    d1.cvalor  = 725
                   AND    p.sprofes = '
         || psprofes
         || '
                   AND    p.fbaja is null
                   ORDER BY fdesde DESC';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_carga;

   FUNCTION f_del_carga(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pfdesde IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
        Elimina la carga del profesional
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_del_carga';
      vparam         VARCHAR2(500)
         := 'parametros sprofes=' || psprofes || ' pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro || ' pfdesde=' || pfdesde;
      vpasexec       NUMBER := 0;
      vfdesde        DATE;
   BEGIN
      SELECT MAX(fdesde)
        INTO vfdesde
        FROM sin_prof_carga
       WHERE sprofes = psprofes
         AND fbaja IS NULL;

      IF vfdesde <> pfdesde THEN
         RETURN 9902125;
      END IF;

      UPDATE sin_prof_carga
         SET fbaja = f_sysdate,
             cusubaj = f_user
       WHERE sprofes = psprofes
         AND ctippro = pctippro
         AND csubpro = pcsubpro
         AND fdesde = pfdesde;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_del_carga', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_carga;

   FUNCTION f_mod_contacto_per(
      psprofes IN NUMBER,
      pcnordcto IN NUMBER,
      pctipdoc IN NUMBER,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptmovil IN VARCHAR2,
      ptemail IN VARCHAR2,
      ptcargo IN VARCHAR2,
      ptdirecc IN VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
        Modifica la persona de contacto del profesional
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_mod_contacto_per';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pcnordcto=' || pcnordcto || ' pctipdoc='
            || pctipdoc || ' pnnumnif=' || pnnumnif || ' ptnombre=' || ptnombre || ' ptmovil='
            || ptmovil || ' ptemail=' || ptemail || ' ptcargo=' || ptcargo || ' ptdirecc='
            || ptdirecc;
      vnumcccs       NUMBER := 0;
      vpasexec       NUMBER := 0;
      vcnordzn       NUMBER := 0;
      vcprovin       NUMBER := 0;
   BEGIN
      IF NANVL(ptmovil, -1) = -1 THEN
         RETURN 9904735;
      END IF;

      IF ptemail NOT LIKE '%@%' THEN
         RETURN 9904619;
      END IF;

      IF pnnumnif IS NULL
         AND ptmovil IS NULL
         AND ptemail IS NULL
         AND ptdirecc IS NULL THEN
         RETURN 9904736;
      END IF;

      UPDATE sin_prof_contactos
         SET ctipide = pctipdoc,
             cnumide = pnnumnif,
             tnombre = ptnombre,
             tmovil = ptmovil,
             temail = ptemail,
             tcargo = ptcargo,
             tdirec = ptdirecc
       WHERE sprofes = psprofes
         AND nordcto = pcnordcto;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_mod_zona', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_mod_contacto_per;

   FUNCTION f_calc_carga(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pncapaci IN NUMBER,
      pfdesde IN DATE,
      pquery IN OUT VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
        Calcula la carga semanal y diaria por capacidad del profesional
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_calc_carga';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro || ' pncapaci=' || pncapaci || ' pfdesde=' || pfdesde;
      vnumcccs       NUMBER := 0;
      vpasexec       NUMBER := 0;
      vncardia       NUMBER := 0;
      vncarsem       NUMBER := 0;
      vtraza         NUMBER := 0;
   BEGIN
      vtraza := 1;
      pquery :=
         'SELECT decode(' || pncapaci
         || ',100,a.ncardia,50,floor(a.ncardia/2),0,0) as ncardia,
                        decode('
         || pncapaci
         || ',100,a.ncarsem,50,floor(a.ncarsem/2),0,0) as ncarsem
                   FROM sin_prof_carga a
                  WHERE a.sprofes = '
         || psprofes || '
                    AND a.ctippro = ' || pctippro || '
                    AND a.csubpro = ' || pcsubpro
         || '
                    AND a.fdesde  = (SELECT max(s.fdesde)
                                     FROM sin_prof_carga s
                                    WHERE s.fdesde <= to_date('
         || CHR(39) || pfdesde || CHR(39)
         || ',''dd/mm/yy'')
                                    )
                    AND a.fbaja IS NULL';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_calc_carga', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_calc_carga;

   FUNCTION f_set_carga_real(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pncapaci IN NUMBER,
      pncardia IN NUMBER,
      pncarsem IN NUMBER,
      pfdesde IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
          Graba una linea de detalle en SIN_PROF_CARGA_REAL
          return              : NUMBER 0(ok) / 1(error)
        *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_carga_real';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro || ' pncapaci=' || pncapaci || ' pncardia=' || pncardia
            || ' pncarsem=' || pncarsem || ' pfdesde=' || pfdesde;
      vpasexec       NUMBER := 0;
   BEGIN
      INSERT INTO sin_prof_carga_real
                  (sprofes, ctippro, csubpro, ncapaci, ncardia, ncarsem, fdesde,
                   cusualt, falta)
           VALUES (psprofes, pctippro, pcsubpro, pncapaci, pncardia, pncarsem, pfdesde,
                   f_user, f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_carga_real', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_carga_real;

   FUNCTION f_get_carga_real(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_carga_real';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT p.ctippro, d.tatribu, p.csubpro, d1.tatribu, ncapaci,ncardia, ncarsem, ncarmes, fdesde, cusualt
                   FROM   sin_prof_carga_real p, detvalores d, detvalores d1
                   WHERE  d.catribu = p.ctippro
                   AND    d.cidioma = '
         || pcidioma
         || '
                   AND    d.cvalor = 724
                   AND    d1.catribu = p.csubpro
                   AND    d1.cidioma = '
         || pcidioma
         || '
                   AND    d1.cvalor  = 725
                   AND    p.sprofes = '
         || psprofes
         || '
                   AND    p.fbaja is null
                   ORDER BY fdesde DESC';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_carga_real;

   FUNCTION f_del_carga_real(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pfdesde IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
        Elimina la carga real del profesional
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_del_carga_real';
      vparam         VARCHAR2(500)
         := 'parametros sprofes=' || psprofes || ' pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro || ' pfdesde=' || pfdesde;
      vpasexec       NUMBER := 0;
      vfdesde        DATE;
   BEGIN
      SELECT MAX(fdesde)
        INTO vfdesde
        FROM sin_prof_carga_real
       WHERE sprofes = psprofes
         AND fbaja IS NULL;

      IF vfdesde <> pfdesde THEN
         RETURN 9902125;
      END IF;

      UPDATE sin_prof_carga_real
         SET fbaja = f_sysdate,
             cusubaj = f_user
       WHERE sprofes = psprofes
         AND ctippro = pctippro
         AND csubpro = pcsubpro
         AND fdesde = pfdesde;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_del_carga_real', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_carga_real;

   FUNCTION f_valida_descartado(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psproduc IN NUMBER,
      pccausin IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_valida_descartado';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro || ' pccausin=' || pccausin || ' pfdesde=' || pfdesde || ' pfhasta='
            || pfhasta;
      vpasexec       NUMBER := 0;
      vcapacidad     NUMBER := 0;
      vfhasta        DATE;
   BEGIN
      IF psproduc IS NULL
         AND pccausin IS NULL THEN
         RETURN 9904761;
      END IF;

      BEGIN
         SELECT fhasta
           INTO vfhasta
           FROM sin_prof_descartados
          WHERE sprofes = psprofes
            AND ctippro = pctippro
            AND csubpro = pcsubpro
            AND sproduc = psproduc
            AND ccausin = pccausin
            AND vfhasta IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vfhasta := TO_DATE('1900/01/01', 'yyyy/mm/dd');
      END;

      IF vfhasta IS NULL THEN
         RETURN 9904762;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_valida_descartado', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_valida_descartado;

   FUNCTION f_set_descartado(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psproduc IN NUMBER,
      pccausin IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
          Graba una linea de detalle en SIN_PROF_DESCARTADOS
          return              : NUMBER 0(ok) / 1(error)
        *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_descartado';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro || ' psproduc=' || psproduc || ' pccausin=' || pccausin || ' pfdesde='
            || pfdesde || ' pfhasta=' || pfhasta;
      vpasexec       NUMBER := 0;
   BEGIN
      INSERT INTO sin_prof_descartados
                  (sprofes, ctippro, csubpro, sproduc, ccausin, fdesde, fhasta,
                   cusualt, falta)
           VALUES (psprofes, pctippro, pcsubpro, psproduc, pccausin, pfdesde, pfhasta,
                   f_user, f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_descartado', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_descartado;

   FUNCTION f_get_descartados(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_descartados';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT p.ctippro, d.tatribu, p.csubpro, d1.tatribu, p.sproduc, p.ccausin,
                 ff_desvalorfijo(815, '
         || pcidioma
         || ', p.ccausin) as tcausin, p.fdesde, p.fhasta
            FROM sin_prof_descartados p, detvalores d, detvalores d1
           WHERE d.catribu = p.ctippro
             AND d.cidioma = '
         || pcidioma
         || '
             AND d.cvalor = 724
             AND d1.catribu = p.csubpro
             AND d1.cidioma = '
         || pcidioma || '
             AND d1.cvalor  = 725
             AND p.sprofes = ' || psprofes || '
        ORDER BY fdesde DESC';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_descartados;

   FUNCTION f_mod_descartados(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psproduc IN NUMBER,
      pccausin IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
        Modifica los productos o causas descartadas del profesional
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_mod_descartados';
      vparam         VARCHAR2(500)
         := 'parametros psprofes=' || psprofes || 'pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro || ' psproduc=' || psproduc || ' pccausin=' || pccausin || ' pfdesde='
            || pfdesde || ' pfhasta=' || pfhasta;
      vpasexec       NUMBER := 0;
   BEGIN
      UPDATE sin_prof_descartados
         SET sproduc = psproduc,
             ccausin = pccausin,
             fhasta = pfhasta
       WHERE sprofes = psprofes
         AND ctippro = pctippro
         AND csubpro = pcsubpro
         AND fdesde = pfdesde;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_mod_descartados', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_mod_descartados;

   FUNCTION f_set_observaciones(psprofes IN NUMBER, ptobserv IN VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
          Graba una linea de detalle en SIN_PROF_OBSERVACIONES
          return              : NUMBER 0(ok) / 1(error)
        *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_observaciones';
      vparam         VARCHAR2(500)
                              := 'parametros psprofes=' || psprofes || 'ptobserv=' || ptobserv;
      vpasexec       NUMBER := 0;
      vcnordcm       NUMBER := 0;
   BEGIN
      BEGIN
         SELECT NVL(MAX(cnordcm) + 1, 0)
           INTO vcnordcm
           FROM sin_prof_observaciones
          WHERE sprofes = psprofes;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcnordcm := 1;
      END;

      IF vcnordcm = 0 THEN
         vcnordcm := 1;
      END IF;

      INSERT INTO sin_prof_observaciones
                  (sprofes, cnordcm, tcoment, cusualt, falta)
           VALUES (psprofes, vcnordcm, ptobserv, f_user, f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_observaciones', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_observaciones;

   FUNCTION f_get_observaciones(psprofes IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_observaciones';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT p.cnordcm, tcoment, cusualt, falta
                   FROM   sin_prof_observaciones p
                   WHERE  p.sprofes = '
         || psprofes || '
                   ORDER BY 1 DESC';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_observaciones;

   FUNCTION f_set_rol(psprofes IN NUMBER, pctippro IN NUMBER, pcsubpro IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
          Graba una linea de detalle en SIN_PROF_ROL
          return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_rol';
      vparam         VARCHAR2(500)
         := 'parametros psprofes= ' || psprofes || ' pctippro= ' || pctippro || ' pcsubpro='
            || pcsubpro;
      vpasexec       NUMBER := 0;
      vcnordcm       NUMBER := 0;
   BEGIN
      BEGIN
         INSERT INTO sin_prof_rol
                     (sprofes, ctippro, csubpro, cusualt, falta)
              VALUES (psprofes, pctippro, pcsubpro, f_user, f_sysdate);

         COMMIT;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 9904775;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_rol', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_rol;

   FUNCTION f_get_roles(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_roles';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT d.catribu, d.tatribu, d1.catribu, d1.tatribu
                   FROM   sin_prof_rol p, detvalores d, detvalores d1
                   WHERE  d.catribu = p.ctippro
                   AND    d.cidioma = '
         || pcidioma
         || '
                   AND    d.cvalor = 724
                   AND    d1.catribu = p.csubpro
                   AND    d1.cidioma = '
         || pcidioma
         || '
                   AND    d1.cvalor  = 725
                   AND    p.sprofes = '
         || psprofes
         || '
                   AND    p.fbaja IS NULL
                   ORDER BY falta DESC';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_roles;

   FUNCTION f_set_seguimiento(psprofes IN NUMBER, ptobserv IN VARCHAR2, pccalific IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
          Graba una linea de detalle en SIN_PROF_SEG
          return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_seguimiento';
      vparam         VARCHAR2(500)
         := 'parametros psprofes= ' || psprofes || ' ptobserv= ' || ptobserv || ' pccalific='
            || pccalific;
      vpasexec       NUMBER := 0;
      vcnsegui       NUMBER := 0;
   BEGIN
      BEGIN
         SELECT NVL(MAX(cnsegui) + 1, 0)
           INTO vcnsegui
           FROM sin_prof_seg
          WHERE sprofes = psprofes;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcnsegui := 1;
      END;

      IF vcnsegui = 0 THEN
         vcnsegui := 1;
      END IF;

      INSERT INTO sin_prof_seg
                  (sprofes, cnsegui, cvalora, tobserv, cusualt, falta)
           VALUES (psprofes, vcnsegui, pccalific, ptobserv, f_user, f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_seguimiento', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_seguimiento;

   FUNCTION f_get_seguimiento(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_seguimiento';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT cnsegui, cvalora, decode(cvalora,0,f_axis_literales(9903556,' || pcidioma
         || '),
                                                              f_axis_literales(9903555,'
         || pcidioma
         || ')),
                           tobserv, cusualt, falta
                   FROM   sin_prof_seg
                   WHERE  sprofes = '
         || psprofes || '
                   ORDER BY falta DESC';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_seguimiento;

   FUNCTION f_get_sprofes(pquery IN OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_sprofes';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      pquery :=
         'SELECT NVL(MAX(sprofes)+1,0) AS SPROFES
                   FROM sin_prof_profesionales';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_sprofes;

   FUNCTION f_get_lstemail(psperson IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_lstemail';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT c.cmodcon, c.tvalcon
                   FROM per_contactos c
                  WHERE c.sperson = '
         || psperson || '
                    AND c.ctipcon = 3';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_lstemail;

   FUNCTION f_get_lsttelefonos(psperson IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_lsttelefonos';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT c.cmodcon, c.tvalcon
                   FROM per_contactos c
                  WHERE c.sperson = '
         || psperson || '
                    AND c.ctipcon IN (1,5,6,8)';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_lsttelefonos;

   FUNCTION f_set_profesional(
      psprofes IN NUMBER,
      psperson IN NUMBER,
      pnregmer IN VARCHAR2,
      pfregmer IN DATE,
      pcdomici IN NUMBER,
      pcmodcon IN NUMBER,
      pctelcli IN NUMBER,
      pnlimite IN NUMBER,
      pcnoasis IN NUMBER,
      pcmodo IN NUMBER,
      psgestio IN NUMBER DEFAULT NULL,   --26630
      ptexto OUT VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
          Graba una linea de detalle en SIN_PROF_PROFESIONALES
          return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_profesional';
      vparam         VARCHAR2(500)
         := 'parametros psprofes= ' || psprofes || ' psperson= ' || psperson || ' pnregmer='
            || pnregmer || ' pfregmer=' || pfregmer || ' pcdomici= ' || pcdomici
            || ' pcmodcon= ' || pcmodcon || ' pctelcli=' || pctelcli || ' pnlimite='
            || pnlimite || ' pcnoasis= ' || pcnoasis || ' pcmodo= ' || pcmodo || ' psgestio= '
            || psgestio;
      vpasexec       NUMBER := 0;
      vcnsegui       NUMBER := 0;
      vnum_error     NUMBER := 0;
      vcterminal     usuarios.cterminal%TYPE;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      v_host         VARCHAR2(10);
      v_email        NUMBER;
      vtvalcon       VARCHAR2(100);
	  /* Cambios de IAXIS-4844 : start */
	  VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;	  
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
	  /* Cambios de IAXIS-4844 : end */
	  -- Ini TCS_1569B - ACL - 31/01/2019
	   CURSOR cur_prof_imp IS
            select p.*
            from per_indicadores p, sin_prof_profesionales s
            where s.sprofes = psprofes
            AND p.sperson = s.sperson
            AND (p.codvinculo = 2 or p.codvinculo = 7);

	  -- Fin TCS_1569B - ACL - 31/01/2019
   BEGIN
      v_email := pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                               'EMAIL_PROF_OBLIG');

      IF v_email = 1 THEN
         BEGIN
            SELECT tvalcon
              INTO vtvalcon
              FROM per_contactos
             WHERE sperson = psperson
               AND ctipcon = 3;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ptexto := f_axis_literales(9905711, pac_md_common.f_get_cxtidioma);
               RETURN -1;
         END;
      END IF;

      IF pcmodo = 1 THEN
         INSERT INTO sin_prof_profesionales
                     (sprofes, sperson, nregmer, fregmer, cdomici, cmodcon, ttelcli,
                      nlimite, cnoasis, sgestio,   -- 26630
                                                cusualt, falta)
              VALUES (psprofes, psperson, pnregmer, pfregmer, pcdomici, pcmodcon, pctelcli,
                      pnlimite, pcnoasis, psgestio,   -- 26630
                                                   f_user, f_sysdate);
		-- Ini TCS_1569B - ACL - 31/01/2019
		BEGIN
             for cur_prof_imp_r in cur_prof_imp loop
                    INSERT INTO sin_prof_indicadores
                    VALUES (psprofes, cur_prof_imp_r.ctipind, cur_prof_imp_r.falta, cur_prof_imp_r.cusualta, null);
             END LOOP;
        END;
		COMMIT;
		-- Fin TCS_1569B - ACL - 31/01/2019
      ELSE
         IF pcmodo = 2 THEN
            UPDATE sin_prof_profesionales
               SET nregmer = pnregmer,
                   fregmer = pfregmer,
                   cdomici = pcdomici,
                   cmodcon = pcmodcon,
                   ttelcli = pctelcli,
                   nlimite = pnlimite,
                   cnoasis = pcnoasis,
                   cusualt = f_user,
                   falta = f_sysdate
             WHERE sprofes = psprofes
               AND sperson = psperson;
         END IF;
      END IF;
		/* Cambios de IAXIS-4844 : start */
		  BEGIN
			SELECT PP.NNUMIDE,PP.TDIGITOIDE
			  INTO VPERSON_NUM_ID,VDIGITOIDE
			  FROM PER_PERSONAS PP
			 WHERE PP.SPERSON = psperson
			   AND ROWNUM = 1;
		  EXCEPTION
			WHEN NO_DATA_FOUND THEN
			  SELECT PP.CTIPIDE, PP.NNUMIDE
				INTO VCTIPIDE, VPERSON_NUM_ID
				FROM PER_PERSONAS PP
			   WHERE PP.SPERSON = psperson;
			  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
															 UPPER(VPERSON_NUM_ID));
		  END;
		/* Cambios de IAXIS-4844 : end */
        
      --Bug 29166/160004 - 29/11/2013 - AMC
      -- Se convierte la persona a pblica
      vnum_error := pac_persona.f_convertir_apublica(psperson);
      -- ini BUG 0026318 -- ETM -- 28/05/2013
      v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'ALTA_PROV_HOST');

      IF v_host IS NOT NULL THEN
         IF pac_persona.f_gubernamental(psperson) = 1 THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'DUPL_ACREEDOR_HOST');
         END IF;

         vnum_error := pac_user.f_get_terminal(f_user, vcterminal);
		/* Cambios de IAXIS-4844 : start */
         vnum_error := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 1, 'ALTA', VDIGITOIDE,
                                              v_host);
        /* Cambios de IAXIS-4844 : end */
---???????????
      END IF;

      IF vnum_error <> 0 THEN
         RETURN 1;
      END IF;

      --fin BUG 0026318 -- ETM -- 28/05/2013
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_seguimiento', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_profesional;

   FUNCTION f_get_profesionales(
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psprofes IN NUMBER,
      pcidioma IN NUMBER,
      pcprovin IN NUMBER DEFAULT NULL,
      pcpoblac IN NUMBER DEFAULT NULL,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_profesionales';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT pr.sprofes, pe.ctipide, pe.nnumide, f_nombre(pe.sperson,3) as TNOMBRE,
                          ff_desvalorfijo(724,'
         || pcidioma
         || ',r.ctippro) as TTIPPRO,
                          ff_desvalorfijo(725,' || pcidioma
         || ',r.csubpro) as TSUBPRO,
         pe.sperson '   --bug 24637/147756:NSS:26/02/2014
         || ' , (select case Z.ctpzona when 1 then ff_despais(z.cpais,2)
                                                       when 2 then f_desprovin2(z.cprovin,z.cpais)
                                                       when 3 then f_desprovin2(z.cprovin,z.cpais) || '' - '' || f_despoblac2(z.cpoblac,z.cprovin)
                                                       end
                                                       FROM sin_prof_zonas z where z.sprofes = pr.sprofes and z.cnordzn = 1) TZONA_GEO
                     FROM sin_prof_profesionales pr, per_personas pe, sin_prof_rol r
                    WHERE r.sprofes(+)  = pr.sprofes
                      AND pe.sperson = pr.sperson
                      AND r.fbaja IS NULL';

      IF psprofes IS NOT NULL THEN
         ptselect := ptselect || ' AND pr.sprofes = ' || psprofes;
      END IF;

      IF pctipide IS NOT NULL THEN
         ptselect := ptselect || ' AND pe.ctipide = ' || pctipide;
      END IF;

      IF pnnumide IS NOT NULL THEN
         --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'),
                0) = 1 THEN
            ptselect := ptselect || ' AND UPPER(pe.nnumide) = UPPER(' || CHR(39) || pnnumide
                        || CHR(39) || ')';
         ELSE
            ptselect := ptselect || ' AND pe.nnumide = ' || CHR(39) || pnnumide || CHR(39);
         END IF;
      END IF;

      IF ptnombre IS NOT NULL THEN
         ptselect :=
            ptselect
            || ' AND pe.sperson IN (SELECT sperson FROM per_detper WHERE UPPER(tbuscar) LIKE UPPER(''%'
            || ptnombre || '%''))';
      END IF;

      IF pctippro IS NOT NULL THEN
         ptselect := ptselect || ' AND r.ctippro = ' || pctippro;
      END IF;

      IF pcsubpro IS NOT NULL THEN
         ptselect := ptselect || ' AND r.csubpro = ' || pcsubpro;
      END IF;

      IF pcprovin IS NOT NULL
        AND pcpoblac IS NOT NULL THEN
        ptselect := ptselect || ' AND EXISTS (SELECT ''1'' FROM SIN_PROF_ZONAS zo where zo.sprofes = pr.sprofes and ((zo.ctpzona > 2 '
                     || ' and zo.cprovin = ' ||pcprovin
                     || ' and zo.cpoblac = ' ||pcpoblac|| ') '
                     || ' or (zo.ctpzona = 2 and zo.cprovin = '||pcprovin || ') '
                     || ' or zo.ctpzona = 1)) ';


      END IF;

      IF pcprovin IS NOT NULL
        AND pcpoblac IS NULL THEN
        ptselect := ptselect || ' AND EXISTS (SELECT ''1'' FROM SIN_PROF_ZONAS zo where zo.sprofes = pr.sprofes and ((zo.ctpzona > 1 '
                      || ' and zo.cprovin = '||pcprovin||') or zo.ctpzona = 1)) ';
      END IF;


      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_profesionales;

   FUNCTION f_get_profesional(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_profesional';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT pr.sprofes, pr.sperson, pe.ctipide, pe.nnumide, f_nombre(pe.sperson,3) as TNOMBRE,
                 pr.nregmer, pr.fregmer, pr.cdomici, dd1.tdomici ||'' ''||dd1.cpostal ||'' ''||dd1.tpoblac ||'' ''||
                 dd1.tprovin ||'' ''||dd1.tpais as tdomici, pr.cmodcon, pc.tvalcon, pr.nlimite, pr.cnoasis,
                 pe.ctipper, d2.tatribu as TTIPIDE
            FROM sin_prof_profesionales pr, per_personas pe,
                (select d1.tdomici, d1.cpostal, po.tpoblac, pv.tprovin, pa.tpais, d1.cdomici, d1.sperson
                   from per_direcciones d1,per_personas pee , poblaciones po, provincias pv, paises pa
                  where d1.sperson = pee.sperson
                    and d1.cprovin = po.cprovin
                    and d1.cpoblac = po.cpoblac
                    and d1.cprovin = pv.cprovin
                    and pa.cpais   = pv.cpais ) dd1,
                 detvalores d2, per_contactos pc
          WHERE pr.sperson = pe.sperson(+)
            AND pr.sprofes = '
         || psprofes
         || '
            AND pr.cdomici = dd1.cdomici(+)
            AND pr.sperson = dd1.sperson(+)
            AND pe.ctipide = d2.CATRIBU
            AND d2.CIDIOMA = '
         || pcidioma
         || '
            AND d2.CVALOR  = 672
            AND pr.sperson = pc.sperson(+)
            AND pr.cmodcon = pc.cmodcon(+) ';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_profesional;

   FUNCTION f_get_ctipprof_carga_real(
      psprofes IN NUMBER,
      pcidioma IN NUMBER,
      pquery IN OUT VARCHAR2)
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_ctipprof_carga_real';
   BEGIN
      vtraza := 1;
      pquery :=
         'SELECT ctippro, d.tatribu, count(*)
            FROM sin_prof_carga c, detvalores d
           WHERE c.sprofes = '
         || psprofes || '
             AND d.cidioma = ' || pcidioma
         || '
             AND c.ctippro = d.catribu
             AND d.cvalor = 724
           GROUP BY ctippro, d.tatribu';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_ctipprof_carga_real;

   FUNCTION f_get_csubprof_carga_real(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcidioma IN NUMBER,
      pquery IN OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_csubprof';
   BEGIN
      vtraza := 1;
      pquery :=
         'SELECT csubpro, d.tatribu, count(*) as cuantos
            FROM sin_prof_carga c, detvalores d
           WHERE c.sprofes = '
         || psprofes || '
             AND c.ctippro = ' || pctippro || '
             AND d.cidioma = ' || pcidioma
         || '
             AND c.csubpro = d.catribu
             AND d.cvalor = 725
           GROUP BY csubpro, d.tatribu';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_csubprof_carga_real;

   FUNCTION f_del_rol(psprofes IN NUMBER, pctippro IN NUMBER, pcsubpro IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
        Anula una linea de detalle en SIN_PROF_ROL
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_del_rol';
      vparam         VARCHAR2(500)
         := 'parametros sprofes=' || psprofes || ' pctippro=' || pctippro || ' pcsubpro='
            || pcsubpro;
      vpasexec       NUMBER := 0;
   BEGIN
      UPDATE sin_prof_rol
         SET fbaja = f_sysdate,
             cusubaj = f_user
       WHERE sprofes = psprofes
         AND ctippro = pctippro
         AND csubpro = pcsubpro;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_del_rol', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_rol;

   FUNCTION f_get_contactos(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_contactos';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT decode(p.cmodcon,c.cmodcon,1,0) cprefer, c.cmodcon, ctipcon, tatribu, tvalcon
                     FROM per_contactos c, sin_prof_profesionales p, detvalores d
                    WHERE d.catribu  = c.ctipcon
                      AND d.cvalor   = 15
                      AND d.cidioma  = '
         || pcidioma
         || '
                      AND c.sperson  = p.sperson
                      AND p.sprofes  = '
         || psprofes;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_contactos;

   FUNCTION f_set_contacto_pref(psprofes IN NUMBER, pcmodcon IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
          Actualiza el contacto preferente en SIN_PROF_PROFESIONALES
          return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_contacto_pref';
      vparam         VARCHAR2(500)
                           := 'parametros psprofes= ' || psprofes || ' pcmodcon= ' || pcmodcon;
      vpasexec       NUMBER := 0;
      vcnsegui       NUMBER := 0;
   BEGIN
      UPDATE sin_prof_profesionales
         SET cmodcon = pcmodcon,
             cusualt = f_user,
             falta = f_sysdate
       WHERE sprofes = psprofes;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_contacto_pref', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_contacto_pref;

   FUNCTION f_get_documentos(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_documentos';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT norddoc, iddocgx, tdescri, cusualt, falta, fcaduca, tobserva
            FROM sin_prof_doc
           WHERE sprofes  = '
         || psprofes || '
             AND fbaja IS NULL';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_documentos;

   FUNCTION f_set_documentacion(
      psprofes IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parmetros - psprofes: ' || psprofes || ' - pfcaduca: '
            || TO_CHAR(pfcaduca, 'DD/MM/YYYY') || ' - ptobserva: ' || ptobserva
            || ' - piddocgedox: ' || piddocgedox || ' - ptdesc: ' || ptdesc;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_set_documentacion';
      vnorddoc       NUMBER(8) := 0;
      salir          EXCEPTION;
      viddocgx       NUMBER(10);
   BEGIN
      IF psprofes IS NULL
         OR piddocgedox IS NULL THEN
         vnumerr := 103135;   --Faltan parmetros
         RAISE salir;
      END IF;

      vpasexec := 2;

      BEGIN
         SELECT iddocgx
           INTO viddocgx
           FROM sin_prof_doc
          WHERE sprofes = psprofes
            AND iddocgx = piddocgedox;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT NVL(MAX(norddoc) + 1, 1)
                 INTO vnorddoc
                 FROM sin_prof_doc
                WHERE sprofes = psprofes;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vnorddoc := 1;
            END;

            INSERT INTO sin_prof_doc
                        (sprofes, norddoc, iddocgx, tdescri, cusualt, falta, fcaduca,
                         tobserva)
                 VALUES (psprofes, vnorddoc, piddocgedox, ptdesc, f_user, f_sysdate, pfcaduca,
                         ptobserva);

            COMMIT;
      END;

      IF viddocgx IS NOT NULL THEN
         UPDATE sin_prof_doc
            SET fcaduca = pfcaduca,
                tobserva = ptobserva,
                tdescri = ptdesc
          WHERE sprofes = psprofes
            AND iddocgx = piddocgedox;

         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, 'PAC_prof', vpasexec, 'f_set_docpersona',
                     f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_prof', vpasexec, 'f_set_docpersona', SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_set_documentacion;

   FUNCTION f_get_sedes(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_sedes';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT s2.sperson_rel, s2.tnombre, s1.cdomici, s1.tdomic, s1.tpercto, s1.thorari
                   FROM
                        (SELECT s.spersed,decode(spersed, NULL, '
         || CHR(39) || CHR(39)
         || ', f_nombre(s.spersed,3)) as TNOMBRE,
                                s.cdomici, d1.tdomici ||'
         || CHR(39) || CHR(39) || '||d1.cpostal ||' || CHR(39) || CHR(39) || '||po.tpoblac ||'
         || CHR(39) || CHR(39) || '|| pv.tprovin ||' || CHR(39) || CHR(39)
         || '||pa.tpais as tdomic,
                                s.tpercto, s.thorari
                           FROM sin_prof_sede s, per_direcciones d1, poblaciones po, provincias pv, paises pa
                          WHERE s.sprofes  = '
         || psprofes
         || '
                            AND s.spersed  = d1.sperson
                            AND s.cdomici  = d1.cdomici
                            AND d1.cprovin = po.cprovin
                            AND d1.cpoblac = po.cpoblac
                            AND d1.cprovin = pv.cprovin
                            AND pv.cpais   = pa.cpais) s1,
                        (SELECT pp.sperson_rel,f_nombre(p.sperson,3) as TNOMBRE,null,null,null,null
                           FROM per_personas p, per_personas_rel pp, sin_prof_profesionales pr
                          WHERE PR.sprofes  = '
         || psprofes
         || '
                            AND PR.sperson  = pp.SPERSON
                            AND pp.CTIPPER_REL = 2
                            AND pp.sperson_rel  = p.sperson) s2
                   WHERE s1.spersed(+) = s2.sperson_Rel';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_sedes;

   FUNCTION f_set_sede(
      psprofes IN NUMBER,
      pspersed IN NUMBER,
      pthorari IN VARCHAR2,
      ptpercto IN VARCHAR2,
      pcdomici IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
          Actualiza los datos de la sede del profesional en SIN_PROF_SEDE
          return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_sede';
      vparam         VARCHAR2(500)
         := 'parametros psprofes= ' || psprofes || ' pspersed= ' || pspersed || ' pthorari= '
            || pthorari || ' ptpercto= ' || ptpercto || ' pcdomici= ' || pcdomici;
      vpasexec       NUMBER := 0;
      vspersed       NUMBER;
   BEGIN
      BEGIN
         SELECT spersed
           INTO vspersed
           FROM sin_prof_sede
          WHERE sprofes = psprofes
            AND spersed = pspersed;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vspersed := NULL;
      END;

      IF vspersed IS NULL THEN
         INSERT INTO sin_prof_sede
                     (sprofes, spersed, spercto, thorari, cusualt, falta, tpercto,
                      cdomici)
              VALUES (psprofes, pspersed, NULL, pthorari, f_user, f_sysdate, ptpercto,
                      pcdomici);
      ELSE
         UPDATE sin_prof_sede
            SET thorari = pthorari,
                tpercto = ptpercto,
                cdomici = pcdomici
          WHERE sprofes = psprofes
            AND spersed = pspersed;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_sede;

   FUNCTION f_get_representantes(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_representantes';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT s2.nnumide, s2.sperson_rel, s2.tnombre, s1.cmailcon, s1.tvalcon, s1.ctelcon, s1.ttelcon, s1.tcargo
                   FROM
                    (SELECT p.NNUMIDE, s.sperson,f_nombre(s.sperson,3) as TNOMBRE, S.CMAILCON, pc.tvalcon, S.CTELCON, pc2.tvalcon as ttelcon,
                            S.TCARGO
                       FROM per_personas p, sin_prof_repre s, per_contactos pc, per_contactos pc2
                      WHERE s.sprofes  = '
         || psprofes
         || '
                        AND pc.SPERSON = s.SPERSON
                        AND s.sperson  = p.sperson
                        AND pc.cmodcon = s.cmailcon
                        AND pc2.sperson = s.sperson
                        AND pc2.cmodcon = s.ctelcon
                    ) s1,
                    (SELECT p2.NNUMIDE, pp.sperson_rel,f_nombre(p2.sperson,3) as TNOMBRE, null, null, null, null, null
                       FROM per_personas p2, per_personas_rel pp, sin_prof_profesionales pr
                      WHERE PR.sprofes  = '
         || psprofes
         || '
                        AND PR.sperson  = pp.SPERSON
                        AND pp.CTIPPER_REL = 1
                        AND pp.sperson_rel  = p2.sperson) s2
                   WHERE s1.sperson(+) = s2.sperson_Rel';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_representantes;

   FUNCTION f_set_representante(
      psprofes IN NUMBER,
      psperson IN NUMBER,
      pnmovil IN NUMBER,
      ptemail IN NUMBER,
      ptcargo IN VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
          Actualiza los datos del representante legal del profesional en SIN_PROF_REPRE
          return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_representante';
      vparam         VARCHAR2(500)
         := 'parametros psprofes= ' || psprofes || ' psperson= ' || psperson || ' pnmovil= '
            || pnmovil || ' ptemail= ' || ptemail || ' ptcargo= ' || ptcargo;
      vpasexec       NUMBER := 0;
      vsperson       NUMBER;
   BEGIN
      BEGIN
         SELECT sperson
           INTO vsperson
           FROM sin_prof_repre
          WHERE sprofes = psprofes
            AND sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vsperson := NULL;
      END;

      IF vsperson IS NULL THEN
         INSERT INTO sin_prof_repre
                     (sprofes, sperson, ctelcon, cmailcon, tcargo, cusuari, falta)
              VALUES (psprofes, psperson, pnmovil, ptemail, ptcargo, f_user, f_sysdate);
      ELSE
         UPDATE sin_prof_repre
            SET ctelcon = pnmovil,
                cmailcon = ptemail,
                tcargo = ptcargo
          WHERE sprofes = psprofes
            AND sperson = psperson;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_representante;

   FUNCTION f_get_sservic(ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
   BEGIN
      vtraza := 1;
      ptselect := 'SELECT max(sservic)+1 AS sservic
                     FROM sin_dettarifas';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROF.F_GET_SSERVIC', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_sservic;

   FUNCTION f_get_lstcups(ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
   BEGIN
      vtraza := 1;
      ptselect := 'SELECT 1 AS cups
                     FROM dual';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROF.F_GET_LSTCUPS', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_lstcups;

   FUNCTION f_set_servicio(
      pstarifa IN NUMBER,
      psservic IN NUMBER,
      pccodcup IN VARCHAR2,
      ptdescri IN VARCHAR2,
      pcunimed IN NUMBER,
      piprecio IN NUMBER,
      pctipcal IN NUMBER,
      pcmagnit IN NUMBER,
      piminimo IN NUMBER,
      pcselecc IN NUMBER,
      pctipser IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
          Actualiza los datos del servicio en SIN_DETTARIFAS
          return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_servicio';
      vparam         VARCHAR2(500)
         := 'parametros pstarifa= ' || pstarifa || ' psservic= ' || psservic || ' pccodcup= '
            || pccodcup || ' ptdescri= ' || ptdescri || ' pcunimed= ' || pcunimed
            || ' piprecio= ' || piprecio || ' pctipcal= ' || pctipcal || ' pcmagnit= '
            || pcmagnit || ' piminimo= ' || piminimo || ' pcselecc= ' || pcselecc
            || ' pctipser= ' || pctipser || ' pfinivig= ' || pfinivig || ' pffinvig= '
            || pffinvig;
      vpasexec       NUMBER := 0;
      vsservic       NUMBER;
      vnlinea        NUMBER;
      vcorigen       VARCHAR2(20) := 'MANUAL';
      vccodmon       VARCHAR2(3);
      v_num_err      NUMBER := 0;
   BEGIN
      vpasexec := 1;

      BEGIN
         SELECT sservic
           INTO vsservic
           FROM sin_dettarifas
          WHERE starifa = pstarifa
            AND sservic = psservic;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vsservic := NULL;
      END;

      vpasexec := 2;
      v_num_err := f_get_moneda(pcmagnit, vccodmon);

      IF vsservic IS NULL THEN
         vpasexec := 3;

         BEGIN
            SELECT MAX(nlinea) + 1
              INTO vnlinea
              FROM sin_dettarifas
             WHERE starifa = pstarifa;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnlinea := 1;
         END;

         IF vnlinea IS NULL THEN
            vnlinea := 1;
         END IF;

         vpasexec := 4;
         v_num_err := f_set_dettarifas_rel(psservic, pctipser);   -- 26929:ASN:07/06/2013
         vpasexec := 5;

         INSERT INTO sin_dettarifas
                     (starifa, nlinea, sservic, ccodcup, tdescri, cunimed, iprecio,
                      ccodmon, ctipcal, cmagnit, iminimo, cselecc, ctipser, finivig,
                      corigen, cusualt, falta)
              VALUES (pstarifa, vnlinea, psservic, pccodcup, ptdescri, pcunimed, piprecio,
                      vccodmon, pctipcal, pcmagnit, piminimo, pcselecc, pctipser, pfinivig,
                      vcorigen, f_user, f_sysdate);
      ELSE
         UPDATE sin_dettarifas
            SET starifa = pstarifa,
                sservic = psservic,
                ccodcup = pccodcup,
                tdescri = ptdescri,
                cunimed = pcunimed,
                iprecio = piprecio,
                cmagnit = pcmagnit,
                iminimo = piminimo,
                cselecc = pcselecc,
                ctipser = pctipser,
                finivig = pfinivig,
                ffinvig = pffinvig
          WHERE starifa = pstarifa
            AND sservic = psservic;
      END IF;

      COMMIT;
      RETURN v_num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_servicio;

   FUNCTION f_get_servicios(
      pstarifa IN NUMBER,
      psservic IN NUMBER,
      ptdescri IN VARCHAR2,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_servicios';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT sservic, tdescri, iprecio, iminimo, finivig, ffinvig
                     FROM sin_dettarifas
                    WHERE starifa = '
         || pstarifa;

      IF psservic IS NOT NULL THEN
         ptselect := ptselect || ' AND sservic = ' || psservic;
      END IF;

      IF ptdescri IS NOT NULL THEN
         ptselect := ptselect || ' AND upper(tdescri) like upper(''%' || ptdescri || '%'')';
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_servicios;

   FUNCTION f_get_servicio(
      pstarifa IN NUMBER,
      psservic IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_servicio';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT sservic, ccodcup, tdescri, cunimed, iprecio, cmagnit, iminimo, cselecc, ctipser, finivig, ffinvig ,ctipcal
                     FROM sin_dettarifas
                    WHERE starifa = '
         || pstarifa || '
                      AND sservic = ' || psservic;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_servicio;

   FUNCTION f_get_tarifas(pstarifa IN NUMBER, ptdescri IN VARCHAR2, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_tarifas';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect := 'SELECT starifa, tdescri
                     FROM sin_tarifas ';

      IF pstarifa IS NOT NULL
         OR ptdescri IS NOT NULL THEN
         ptselect := ptselect || ' WHERE ';
      END IF;

      IF pstarifa IS NOT NULL
         AND ptdescri IS NOT NULL THEN
         ptselect := ptselect || ' starifa = ' || pstarifa || ' AND ';
      END IF;

      IF pstarifa IS NOT NULL
         AND ptdescri IS NULL THEN
         ptselect := ptselect || ' starifa = ' || pstarifa;
      END IF;

      IF ptdescri IS NOT NULL THEN
         ptselect := ptselect || ' tdescri like ''% ' || ptdescri || '%''';
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_tarifas;

   FUNCTION f_get_starifa(ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
   BEGIN
      vtraza := 1;
      ptselect := 'SELECT nvl(max(starifa), 0)+1 AS starifa
                     FROM sin_tarifas';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROF.F_GET_STARIFA', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_starifa;

   FUNCTION f_set_tarifa(pstarifa IN NUMBER, ptdescri IN VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
          Actualiza los datos del servicio en SIN_TARIFAS
          return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_tarifa';
      vparam         VARCHAR2(500)
                           := 'parametros pstarifa= ' || pstarifa || ' ptdescri= ' || ptdescri;
      vpasexec       NUMBER := 0;
      vstarifa       NUMBER;
   BEGIN
      BEGIN
         SELECT starifa
           INTO vstarifa
           FROM sin_tarifas
          WHERE starifa = pstarifa;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vstarifa := NULL;
      END;

      IF vstarifa IS NULL THEN
         INSERT INTO sin_tarifas
                     (starifa, tdescri, cusualt, falta)
              VALUES (pstarifa, ptdescri, f_user, f_sysdate);
      ELSE
         UPDATE sin_tarifas
            SET starifa = pstarifa,
                tdescri = ptdescri
          WHERE starifa = pstarifa;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_tarifa;

   FUNCTION f_get_convenios(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_convenios';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT st.sconven, st.tdescri, st.starifa, t.tdescri as ttarifa, st.spersed, decode(st.spersed, NULL, '
         || CHR(39) || CHR(39)
         || ',
                                                                                                          f_nombre(st.spersed,3)) as tpersed,
              st.ncomple, st.npriorm, s.cestado, ff_desvalorfijo(742, '
         || pcidioma
         || ', s.cestado) as testado,
              s.festado
         FROM sin_prof_tarifa st, sin_tarifas t,
              (SELECT *
               FROM sin_prof_conv_estados s1
               WHERE s1.festado = (SELECT max(s2.festado)
                                   FROM  sin_prof_conv_estados s2
                                   WHERE s2.sconven = s1.sconven
                                  )
              ) s
        WHERE st.sprofes = '
         || psprofes
         || '
          AND st.starifa = t.starifa
          AND st.sconven = s.sconven(+)';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_convenios;

   FUNCTION f_get_estados_convenio(
      psconven IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_estados_convenio';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT s.sconven, s.cestado, s.tobserv, d.tatribu as testado, s.festado, s.canulad, s.cusualt, s.falta
                     FROM sin_prof_conv_estados s, detvalores d
                    WHERE d.catribu = s.cestado
                      AND d.cvalor = 742
                      AND d.cidioma = '
         || pcidioma || '
                      AND s.sconven = ' || psconven;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_estados_convenio;

   FUNCTION f_set_estado_convenio(
      sconven IN NUMBER,
      cestado IN NUMBER,
      festado IN DATE,
      tobservaciones IN VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
        Graba una linea de detalle en SIN_PROF_CONV_ESTADOS
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_estado_convenio';
      vparam         VARCHAR2(500)
         := 'parametros sconven=' || sconven || 'cestado=' || cestado || ' festado='
            || festado || ' tobservaciones=' || tobservaciones;
      vpasexec       NUMBER := 0;
      vnorden        NUMBER := 0;
   BEGIN
      INSERT INTO sin_prof_conv_estados
                  (sconven, cestado, festado, tobserv, canulad, cusualt, falta)
           VALUES (sconven, cestado, festado, tobservaciones, 0, f_user, f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_estado_convenio', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_estado_convenio;

   FUNCTION f_del_estado_convenio(psconven IN NUMBER, pcestado IN NUMBER, pfestado IN DATE)
      RETURN NUMBER IS
      /*************************************************************************
        Anula una linea de detalle en SIN_PROF_CONV_ESTADOS
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_del_estado_convenio';
      vparam         VARCHAR2(500)
         := 'parametros sconven=' || psconven || ' cestado=' || pcestado || ' festado='
            || pfestado;
      vpasexec       NUMBER := 0;
   BEGIN
      IF TRUNC(pfestado) >= TRUNC(f_sysdate) THEN
         UPDATE sin_prof_conv_estados
            SET canulad = 1
          WHERE sconven = psconven
            AND festado = pfestado;

         COMMIT;
         RETURN 0;
      ELSE
         RETURN 9904699;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_del_estado_convenio', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_estado_convenio;

   FUNCTION f_set_convenio(
      psconven IN NUMBER,
      psprofes IN NUMBER,
      pstarifa IN NUMBER,
      pspersed IN NUMBER,
      pncomple IN NUMBER,
      pnpriorm IN NUMBER,
      ptdescri IN VARCHAR2,
      pcvalor IN NUMBER,
      pctipo IN NUMBER,
      pnimporte IN NUMBER,
      pnporcent IN NUMBER,
      ptermino IN VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
        Graba una linea de detalle en SIN_PROF_TARIFA
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_convenio';
      vparam         VARCHAR2(500)
         := 'parametros sconven=' || psconven || ' sprofes=' || psprofes || 'starifa='
            || pstarifa || 'spersed=' || pspersed || 'ncomple=' || pncomple || 'npriorm='
            || pnpriorm || 'tdescri=' || ptdescri || 'cvalor =' || pcvalor || 'ctipo='
            || pctipo || 'nimporte=' || pnimporte || 'nporcent=' || pnporcent || 'termino='
            || ptermino;
      vpasexec       NUMBER := 0;
      vsconven       NUMBER := 1;
   BEGIN
      IF psconven IS NULL THEN
         BEGIN
            SELECT NVL(MAX(sconven), 0) + 1
              INTO vsconven
              FROM sin_prof_tarifa;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vsconven := 1;
         END;

         INSERT INTO sin_prof_tarifa
                     (sconven, sprofes, starifa, tdescri, spersed, cestado,
                      festado, ncomple, npriorm, cusualt,
                      falta, cvalor, ctipo, nimporte, nporcent, termino)   --BUG 26630:NSS:08/07/2013
              VALUES (vsconven, psprofes, pstarifa, ptdescri, pspersed, -1,
                      TO_DATE('1900/01/01', 'yyyy/mm/dd'), pncomple, pnpriorm, f_user,
                      f_sysdate, pcvalor, pctipo, pnimporte, pnporcent, ptermino);   --BUG 26630:NSS:08/07/2013

         -- Ini BUG 26630:NSS:19/07/2013
         INSERT INTO sin_prof_conv_estados
                     (sconven, cestado, festado, canulad, cusualt, falta)
              VALUES (vsconven, 1, f_sysdate, 0, f_user, f_sysdate);

         -- Fin BUG 26630:NSS:19/07/2013
         RETURN 0;
      ELSE
         BEGIN
            SELECT MAX(sconven)
              INTO vsconven
              FROM sin_prof_tarifa;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vsconven := NULL;
         END;

         IF vsconven IS NULL THEN
            BEGIN
               SELECT NVL(MAX(sconven), 0) + 1
                 INTO vsconven
                 FROM sin_prof_tarifa
                WHERE sprofes = psprofes;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vsconven := 1;
            END;

            INSERT INTO sin_prof_tarifa
                        (sconven, sprofes, starifa, tdescri, spersed, cestado,
                         festado, ncomple, npriorm, cusualt,
                         falta, cvalor, ctipo, nimporte, nporcent, termino)   --BUG 26630:NSS:08/07/2013
                 VALUES (vsconven, psprofes, pstarifa, ptdescri, pspersed, -1,
                         TO_DATE('1900/01/01', 'yyyy/mm/dd'), pncomple, pnpriorm, f_user,
                         f_sysdate, pcvalor, pctipo, pnimporte, pnporcent, ptermino);   --BUG 26630:NSS:08/07/2013

            -- Ini BUG 26630:NSS:19/07/2013
            INSERT INTO sin_prof_conv_estados
                        (sconven, cestado, festado, canulad, cusualt, falta)
                 VALUES (vsconven, 1, f_sysdate, 0, f_user, f_sysdate);
         -- Fin BUG 26630:NSS:19/07/2013
         ELSE
            UPDATE sin_prof_tarifa
               SET starifa = pstarifa,
                   tdescri = ptdescri,
                   spersed = pspersed,
                   ncomple = pncomple,
                   npriorm = pnpriorm,
                   cvalor = pcvalor,   --BUG 26630:NSS:08/07/2013
                   ctipo = pctipo,   --BUG 26630:NSS:08/07/2013
                   nimporte = pnimporte,   --BUG 26630:NSS:08/07/2013
                   nporcent = pnporcent,   --BUG 26630:NSS:08/07/2013
                   termino = ptermino   --BUG 26630:NSS:08/07/2013
             WHERE sconven = psconven;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_convenio', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_convenio;

   FUNCTION f_get_tarifa(pstarifa IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_tarifa';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT starifa, tdescri
                     FROM sin_tarifas
                    WHERE starifa = '
         || pstarifa;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_tarifa;

   FUNCTION f_get_convenio(psconven IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_convenio';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT c.sconven, c.tdescri, c.starifa, t.tdescri as ttarifa, c.spersed, c.ncomple, c.npriorm,
                 c.cvalor,  c.ctipo,   c.nimporte, c.nporcent, c.termino
                     FROM sin_prof_tarifa c, sin_tarifas t
                    WHERE c.sconven = '
         || psconven || '
                      AND c.starifa = t.starifa';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_convenio;

   FUNCTION f_actualiza_servicio(
      pstarifa IN NUMBER,
      psservic IN NUMBER,
      piprecio IN NUMBER,
      piminimo IN NUMBER,
      pfinivig IN DATE)
      RETURN NUMBER IS
      /********************************************************************************************
          Actualiza los datos del servicio en SIN_DETTARIFAS y crea uno nuevo con los nuevos datos
          return              : NUMBER 0(ok) / 1(error)
      *******************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_actualiza_servicio';
      vparam         VARCHAR2(500)
         := 'parametros pstarifa= ' || pstarifa || ' psservic= ' || psservic || ' piprecio= '
            || piprecio || ' piminimo= ' || piminimo || ' pfinivig= ' || pfinivig;
      vpasexec       NUMBER := 0;
      vsservic       NUMBER;
      vnlinea        NUMBER;
      vccodcup       VARCHAR2(100);
      vtdescri       VARCHAR2(200);
      vcunimed       NUMBER;
      vcmagnit       NUMBER;
      vcselecc       NUMBER;
      vctipser       NUMBER;
      vcorigen       VARCHAR2(20);
   BEGIN
      BEGIN
         SELECT MAX(sservic) + 1 AS sservic
           INTO vsservic
           FROM sin_dettarifas;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vsservic := 1;
      END;

      BEGIN
         SELECT MAX(nlinea) + 1
           INTO vnlinea
           FROM sin_dettarifas
          WHERE starifa = pstarifa;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vnlinea := 1;
      END;

      IF vnlinea IS NULL THEN
         vnlinea := 1;
      END IF;

      BEGIN
         SELECT ccodcup, tdescri, cunimed, cmagnit, cselecc, ctipser, corigen
           INTO vccodcup, vtdescri, vcunimed, vcmagnit, vcselecc, vctipser, vcorigen
           FROM sin_dettarifas
          WHERE sservic = psservic
            AND starifa = pstarifa;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN -1;
      END;

      INSERT INTO sin_dettarifas
                  (starifa, nlinea, sservic, ccodcup, tdescri, cunimed, iprecio,
                   cmagnit, iminimo, cselecc, ctipser, finivig, corigen, cusualt,
                   falta)
           VALUES (pstarifa, vnlinea, vsservic, vccodcup, vtdescri, vcunimed, piprecio,
                   vcmagnit, piminimo, vcselecc, vctipser, pfinivig, vcorigen, f_user,
                   f_sysdate);

      UPDATE sin_dettarifas
         SET ffinvig = pfinivig
       WHERE starifa = pstarifa
         AND sservic = psservic;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_actualiza_servicio;

   FUNCTION f_get_tarifa_a_copiar(pstarifa_sel IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
        Busca los registros de servicios a copiar
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_get_tarifa_a_copiar';
      vparam         VARCHAR2(500) := 'parametros starifa_sel=' || pstarifa_sel;
      vpasexec       NUMBER := 0;
   BEGIN
      ptselect :=
         'SELECT tdescri, cunimed, iprecio,  cmagnit, iminimo,
                          finivig, ffinvig, ctipser, ccodcup, cselecc
                     FROM sin_dettarifas
                    WHERE starifa = '
         || pstarifa_sel;
      RETURN 0;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_copiar_tarifa', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_tarifa_a_copiar;

   FUNCTION f_copiar_tarifa(
      pstarifa_new IN NUMBER,
      ptdescri IN VARCHAR2,
      pcunimed IN NUMBER,
      piprecio IN NUMBER,
      pcmagnit IN NUMBER,
      piminimo IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pctipser IN NUMBER,
      pccodcup IN VARCHAR2,
      pcselecc IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
        Copia en SIN_DETTARIFAS los servicios de la tarifa seleccionada a la nueva tarifa
        return              : NUMBER 0(ok) / 1(error)
      **************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_copiar_tarifa';
      vparam         VARCHAR2(500) := 'parametros starifa_new=' || pstarifa_new;
      vpasexec       NUMBER := 0;
      vnlinea        NUMBER;
      vsservic       NUMBER;
      vcorigen       VARCHAR2(20) := 'MANUAL';
   BEGIN
      BEGIN
         SELECT MAX(sservic) + 1
           INTO vsservic
           FROM sin_dettarifas;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vsservic := 1;
      END;

      BEGIN
         SELECT MAX(nlinea) + 1
           INTO vnlinea
           FROM sin_dettarifas
          WHERE starifa = pstarifa_new;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vnlinea := 1;
      END;

      IF vnlinea IS NULL THEN
         vnlinea := 1;
      END IF;

      INSERT INTO sin_dettarifas
                  (starifa, nlinea, sservic, ccodcup, tdescri, cunimed, iprecio,
                   cmagnit, iminimo, cselecc, ctipser, finivig, corigen, cusualt,
                   falta)
           VALUES (pstarifa_new, vnlinea, vsservic, pccodcup, ptdescri, pcunimed, piprecio,
                   pcmagnit, piminimo, pcselecc, pctipser, pfinivig, vcorigen, f_user,
                   f_sysdate);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_copiar_tarifa', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_copiar_tarifa;

   FUNCTION f_actualiza_servicios(
      pstarifa IN NUMBER,
      pservicios IN VARCHAR2,
      pcvalor IN NUMBER,
      pctipo IN NUMBER,
      pnimporte IN NUMBER,
      pnporcent IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
        Actualiza masivamente los servicios seleccionados incrementando o disminuyendo
         su precio en el porcentaje o importe indicando
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_actualiza_servicios';
      vparam         VARCHAR2(500)
         := 'parametros starifa=' || pstarifa || 'servicios=' || pservicios || 'cvalor='
            || pcvalor || 'ctipo=' || pctipo || 'nimporte=' || pnimporte || 'nporcent='
            || pnporcent;
      vpasexec       NUMBER := 0;
      vpservicios    VARCHAR2(4000);
      vpservicio     VARCHAR2(100);
      vpos           NUMBER;
      viprecio       NUMBER;
   BEGIN
      vpservicios := pservicios;

      LOOP
         EXIT WHEN NVL(INSTR(vpservicios, ','), 0) = 0;
         vpservicio := SUBSTR(vpservicios, 1,(INSTR(vpservicios, ',') - 1));
         vpos := INSTR(vpservicios, ',') + 1;
         vpservicios := SUBSTR(vpservicios, vpos, LENGTH(vpservicios));

         BEGIN
            SELECT iprecio
              INTO viprecio
              FROM sin_dettarifas
             WHERE sservic = TO_NUMBER(vpservicio)
               AND starifa = pstarifa;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
         END;

         IF pcvalor > 0 THEN
            IF pctipo = 1 THEN
               viprecio := viprecio + pnimporte;
            ELSE
               IF pctipo = 2 THEN
                  viprecio := viprecio +((viprecio * pnporcent) / 100);
               END IF;
            END IF;
         ELSE
            IF pcvalor < 0 THEN
               IF pctipo = 1 THEN
                  viprecio := viprecio - pnimporte;
               ELSE
                  IF pctipo = 2 THEN
                     viprecio := viprecio -((viprecio * pnporcent) / 100);
                  END IF;
               END IF;
            END IF;
         END IF;

         IF viprecio < 0 THEN
            RETURN 9907783;
         END IF;

         UPDATE sin_dettarifas
            SET iprecio = viprecio
          WHERE sservic = TO_NUMBER(vpservicio);

         COMMIT;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_convenio', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_actualiza_servicios;

   FUNCTION f_get_tipos_profesional(pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_tipos_profesional';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT distinct ctippro, d.tatribu
                     FROM sin_prof_tipoprof p, detvalores d
                    WHERE d.cidioma = '
         || pcidioma
         || '
                      AND p.ctippro = d.catribu
                      AND d.cvalor = 724
                      ORDER BY tatribu ASC';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_tipos_profesional;

   FUNCTION f_get_subtipos_profesional(
      pctipprof IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_subtipos_profesional';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT ctippro, csubpro, d.tatribu
                     FROM sin_prof_tipoprof p, detvalores d
                    WHERE d.cidioma = '
         || pcidioma || '
                          AND p.ctippro = ' || pctipprof
         || '
                      AND p.csubpro = d.catribu
                      AND d.cvalor = 725';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_subtipos_profesional;

   FUNCTION f_get_tdescri_tarifa(pstarifa IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_tdescri_tarifa';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT starifa, tdescri
            FROM sin_tarifas
           WHERE starifa = '
         || pstarifa;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_tdescri_tarifa;

   FUNCTION f_get_tarifa_profesional(
      psprofes IN NUMBER,
      psconven IN NUMBER,
      pstarifa OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
   BEGIN
      SELECT starifa
        INTO pstarifa
        FROM sin_prof_tarifa sp
       WHERE sp.sprofes = psprofes
         AND sp.sconven = psconven;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROF.f_get_tarifa_profesional', 1,
                     'param - psprofes = ' || psprofes || ' psconven = ' || psconven,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_tarifa_profesional;

   FUNCTION f_lstmagnitud(pctipcal IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
   BEGIN
      ptselect :=
         'SELECT catribu, tatribu
                    FROM detvalores
                    WHERE cvalor = 733
                      AND (( '
         || pctipcal || '= 1 and catribu = 0)
                       OR (' || pctipcal
         || ' = 2 and catribu in (2,3))
                       OR (' || pctipcal
         || ' = 3 and catribu = 1))
                      AND cidioma = ' || pcidioma;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROF.f_lstmagnitud', 1,
                     'param - pctipcal = ' || pctipcal,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_lstmagnitud;

   FUNCTION f_get_moneda(pcmagnit IN NUMBER, pccodmon OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
   BEGIN
      IF pcmagnit = 2   -- Dolares
                     THEN
         pccodmon := 'USD';
      ELSIF pcmagnit = 3   -- Euros
                        THEN
         pccodmon := 'EUR';
      ELSE   -- Moneda de la aplicacion
         SELECT cmonint
           INTO pccodmon
           FROM parempresas p, monedas
          WHERE cmoneda = nvalpar
            AND cparam = 'MONEDAEMP'
            AND cempres = pac_md_common.f_get_cxtempresa()
            AND cidioma = pac_md_common.f_get_cxtidioma();
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROF.f_get_moneda', 1,
                     'param - pcmagnit = ' || pcmagnit,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_moneda;

   FUNCTION f_set_dettarifas_rel(psservic IN NUMBER, pctipser IN NUMBER)
      RETURN NUMBER IS
      -- 26929:ASN:07/06/2013
      vcodigo1       sin_dettarifas_rel.codigo1%TYPE;
      vcodigo2       sin_dettarifas_rel.codigo2%TYPE;
   BEGIN
      IF pctipser = 4 THEN   -- Reparacion autos
         vcodigo1 := 5;

         SELECT MAX(codigo2) + 1
           INTO vcodigo2
           FROM sin_dettarifas_rel
          WHERE corigen = 'MANUAL'
            AND codigo1 = 5;

         IF vcodigo2 IS NULL THEN
            vcodigo2 := 600;
         END IF;
      ELSIF pctipser = 5 THEN   -- Repuestos autos
         vcodigo1 := 5;

         SELECT MAX(codigo2) + 1
           INTO vcodigo2
           FROM sin_dettarifas_rel
          WHERE corigen = 'MANUAL'
            AND codigo1 = 5;

         IF vcodigo2 IS NULL THEN
            vcodigo2 := 600;
         END IF;
      END IF;

      IF vcodigo1 IS NOT NULL THEN
         INSERT INTO sin_dettarifas_rel
                     (corigen, codaxis, codigo1, codigo2)
              VALUES ('MANUAL', psservic, vcodigo1, vcodigo2);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROF.f_set_dettarifas_rel', 1,
                     'param - psservic = ' || psservic || ' pctipser = ' || pctipser,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_dettarifas_rel;

   FUNCTION f_lstterminos(ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
   BEGIN
      ptselect := 'SELECT clave, codigo
            FROM sgt_parm_formulas';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROF.f_lstterminos', 1, 'param - ',
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_lstterminos;

   --26630:NSS:09/07/2013
   FUNCTION f_set_convenio_temporal(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pstarifa IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pcvalor IN NUMBER,
      pctipo IN NUMBER,
      pnimporte IN NUMBER,
      pnporcent IN NUMBER,
      ptermino IN VARCHAR2,
      ptemail IN VARCHAR2,
      pcagente IN NUMBER,
      psprofes OUT NUMBER,
      psconven OUT NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
        Graba una linea de detalle en SIN_PROF_TARIFA
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_PROF.f_set_convenio_temporal';
      vparam         VARCHAR2(500)
         := 'parametros psperson=' || psperson || 'pnlocali=' || pnlocali || ' pctippro='
            || pctippro || 'pcsubpro=' || pcsubpro || 'pstarifa=' || pstarifa || 'pnnumide='
            || pnnumide || 'ptnombre=' || ptnombre || 'cvalor =' || pcvalor || 'ctipo='
            || pctipo || 'nimporte=' || pnimporte || 'nporcent=' || pnporcent || 'termino='
            || ptermino || 'ptemail=' || ptemail || 'pcagente=' || pcagente;
      vpasexec       NUMBER := 0;
      vsconven       NUMBER := 1;
      vsprofes       NUMBER := 1;
      vcpais         NUMBER;
      vmodcon        NUMBER;
      vnumerr        NUMBER;
      vtexto         VARCHAR2(100);
	/* Cambios de  tarea IAXIS-13044 :START */	  
	  VPERSON_NUM_ID per_personas.nnumide%type;
	/* Cambios de  tarea IAXIS-13044 :END */  
   BEGIN
      SELECT NVL(MAX(cmodcon), 0) + 1
        INTO vmodcon
        FROM per_contactos
       WHERE sperson = psperson;

      vpasexec := 1;

      INSERT INTO per_contactos
                  (sperson, cagente, cmodcon, ctipcon, tvalcon, cusuari, fmovimi)
           VALUES (psperson, pcagente, vmodcon, 3, ptemail, f_user, f_sysdate);

--INI 1554 CESS
	/* Cambios de  tarea IAXIS-13044 :START */
       BEGIN
         SELECT PP.NNUMIDE
           INTO VPERSON_NUM_ID
           FROM PER_PERSONAS PP
          WHERE PP.SPERSON = PSPERSON;
       
         PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                           1,
                                           'S03502',
                                           NULL);
       EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_PROF.f_set_convenio_temporal',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
	   END;			         	
    /* Cambios de  tarea IAXIS-13044 :END */
--END 1554 CESS

      vpasexec := 2;

      INSERT INTO per_personas_rel
                  (sperson, cagente, sperson_rel, ctipper_rel)
           VALUES (psperson, pcagente, psperson, 2);

      vpasexec := 3;

      BEGIN
         SELECT NVL(MAX(sprofes) + 1, 0)
           INTO vsprofes
           FROM sin_prof_profesionales;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vsprofes := 1;
      END;

      vpasexec := 4;
      vnumerr := f_set_profesional(vsprofes, psperson, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, 1, TO_NUMBER(pnsinies) *(-1), vtexto);
      vpasexec := 5;

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vnumerr := f_set_rol(vsprofes, pctippro, pcsubpro);
      vpasexec := 6;

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vnumerr := f_set_estado(vsprofes, 1, f_sysdate, NULL, NULL);
      vpasexec := 7;

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      BEGIN
         SELECT cpais
           INTO vcpais
           FROM sin_tramita_localiza
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND nlocali = pnlocali;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcpais := NULL;
      END;

      vpasexec := 8;
      vnumerr := f_set_zona(vsprofes, 1, vcpais, NULL, NULL, NULL, NULL, f_sysdate, NULL);
      vpasexec := 9;

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      BEGIN
         SELECT NVL(MAX(sconven) + 1, 1)
           INTO vsconven
           FROM sin_prof_tarifa;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vsconven := 1;
      END;

      vpasexec := 10;

      INSERT INTO sin_prof_tarifa
                  (sconven, sprofes, starifa, cestado, festado,
                   cusualt, falta, cvalor, ctipo, nimporte, nporcent, termino,
                   sgestio)
           VALUES (vsconven, vsprofes, pstarifa, 1, TO_DATE('1900/01/01', 'yyyy/mm/dd'),
                   f_user, f_sysdate, pcvalor, pctipo, pnimporte, pnporcent, ptermino,
                   TO_NUMBER(pnsinies) *(-1));

      vpasexec := 11;

      INSERT INTO sin_prof_conv_estados
                  (sconven, cestado, festado, canulad, cusualt, falta)
           VALUES (vsconven, 1, f_sysdate, 0, f_user, f_sysdate);

      vpasexec := 12;
      COMMIT;
      psprofes := vsprofes;
      psconven := vsconven;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prof.f_set_convenio_temporal', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_convenio_temporal;

   --0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros:NSS;25/02/2014
   FUNCTION f_get_impuestos(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_PROF.f_get_impuestos';
      vparam         VARCHAR2(200) := '';
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT di.ccodimp, di.tdesimp, pi.ctipind, i.tindica, pi.cusualta, pi.falta
           FROM sin_prof_indicadores pi, tipos_indicadores i, sin_imp_desimpuesto di
          WHERE pi.sprofes ='
         || psprofes
         || '
            AND pi.ctipind = i.ctipind
            AND i.cimpret = di.ccodimp
            AND di.cidioma = '
         || pcidioma
         || '
            AND di.ccodimp <> 4
         UNION
         SELECT di.ccodimp, di.tdesimp, pi.ctipind, p.tpoblac || '' - '' || i.tindica tindica,
                pi.cusualta, pi.falta
           FROM sin_prof_indicadores pi, tipos_indicadores i, sin_imp_desimpuesto di,
                tipos_indicadores_det d, poblaciones p
          WHERE pi.sprofes = '
         || psprofes
         || '
            AND pi.ctipind = i.ctipind
            AND i.cimpret = di.ccodimp
            AND di.cidioma = '
         || pcidioma
         || '
            AND di.ccodimp = 4
            AND d.ctipind = i.ctipind
            AND p.cprovin = TO_NUMBER(SUBSTR(LTRIM(TO_CHAR(d.cpostal, ''00000'')), 1, 2))
            AND p.cpoblac = TO_NUMBER(SUBSTR(LTRIM(TO_CHAR(d.cpostal, ''00000'')), 3, 3))';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'error recuperando datos', SQLERRM);
         RETURN 1;
   END f_get_impuestos;
END pac_prof;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROF" TO "PROGRAMADORESCSI";
