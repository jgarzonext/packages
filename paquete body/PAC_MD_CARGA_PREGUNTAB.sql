--------------------------------------------------------
--  DDL for Package Body PAC_MD_CARGA_PREGUNTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CARGA_PREGUNTAB" AS
/*******************************************************************************
   NOMBRE:       pac_md_carga_preguntab
   PROP¿SITO: Funciones para la carga de preguntas de tipo tabla

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ----------  ------------------------------------
   1.0        13/2/2015   AMC                1. Creaci¿n del package.
*******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/***********************************************************************
      Recupera los datos del riesgo (preguntas)
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in psimul    : indicador de simulacion
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_preguntab_rie(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2,
      psproduc IN NUMBER,
      psproces_out IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntastab IS
      preg           t_iax_preguntastab;
      resp           t_iaxpar_respuestas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'ptablas=' || ptablas || ', psseguro=' || psseguro || ', pnriesgo=' || pnriesgo
            || ' pcpregun:' || pcpregun || ' pcgarant:' || pcgarant || ' pnmovimi:'
            || pnmovimi || ' psproduc:' || psproduc;
      vobject        VARCHAR2(200) := 'pac_md_carga_preguntab.f_get_preguntab_rie';
      vconsulta      VARCHAR2(4000);
      cur            sys_refcursor;
      w_cprofes      VARCHAR2(200);
      w_tprofes      VARCHAR2(500);
      v_isaltacol    NUMBER;
      tcolumnas      t_iax_preguntastab_columns;
      vindex         NUMBER;
      catribu        NUMBER;
      tatribu        VARCHAR2(1000);
      vselect        VARCHAR2(1000);

      TYPE t_valores IS TABLE OF VARCHAR2(500)
         INDEX BY VARCHAR2(100);

      vcolumn1       t_valores;
      vcolumn2       t_valores;
      vcolumn3       t_valores;
      vcolumn4       t_valores;
      vcolumn5       t_valores;
      vcolumn6       t_valores;
      vcolumn7       t_valores;
      vcolumn8       t_valores;
      vcolumn9       t_valores;
      vcolumn10      t_valores;
      vcolumn11      t_valores;
      vcolumn12      t_valores;
      vcolumn13      t_valores;
      curid          INTEGER;
      dummy          INTEGER;
      cvalor         VARCHAR2(100);
      tvalor         VARCHAR2(500);
      vidioma        NUMBER;
   -- vsproduc  number;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma();
      vpasexec := 2;
      /*  IF ptablas = 'EST' THEN

          select sproduc into vsproduc from estseguros where sseguro = psseguro;
        ELSE
          select sproduc into vsproduc from seguros where sseguro = psseguro;
        END IF;  */
      vpasexec := 3;

      FOR cur IN (SELECT *
                    FROM preguntab_colum
                   WHERE cpregun = pcpregun) LOOP
         -- p_control_error('AMC','f_get_preguntab_rie','ctipcol:'||cur.ctipcol);
         IF cur.ctipcol = 5 THEN
            vselect := cur.tconsulta;
            -- p_control_error('AMC','f_get_preguntab_rie','1-vselect:'||vselect);
            vselect := REPLACE(vselect, ':PMT_IDIOMA', vidioma);
            vselect := REPLACE(vselect, ':PMT_SPRODUC', psproduc);
            vselect := REPLACE(vselect, ':PMT_CGARANT', pcgarant);
            -- p_control_error('AMC','f_get_preguntab_rie','2-vselect:'||vselect);
            curid := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(curid, vselect, DBMS_SQL.v7);
            dummy := DBMS_SQL.EXECUTE(curid);
            DBMS_SQL.define_column(curid, 1, cvalor, 2000);
            DBMS_SQL.define_column(curid, 2, tvalor, 2000);

            LOOP
               EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
               DBMS_SQL.COLUMN_VALUE(curid, 1, cvalor);
               DBMS_SQL.COLUMN_VALUE(curid, 2, tvalor);

               -- p_control_error('AMC','f_get_preguntab_rie','tvalor:'||tvalor);
               CASE cur.ccolumn
                  WHEN 1 THEN
                     vcolumn1(cvalor) := tvalor;
                  WHEN 2 THEN
                     vcolumn2(cvalor) := tvalor;
                  WHEN 3 THEN
                     vcolumn3(cvalor) := tvalor;
                  WHEN 4 THEN
                     vcolumn4(cvalor) := tvalor;
                  WHEN 5 THEN
                     vcolumn5(cvalor) := tvalor;
                  WHEN 6 THEN
                     vcolumn6(cvalor) := tvalor;
                  WHEN 7 THEN
                     vcolumn7(cvalor) := tvalor;
                  WHEN 8 THEN
                     vcolumn8(cvalor) := tvalor;
                  WHEN 9 THEN
                     vcolumn9(cvalor) := tvalor;
                  WHEN 10 THEN
                     vcolumn10(cvalor) := tvalor;
                  WHEN 11 THEN
                     vcolumn11(cvalor) := tvalor;
                  WHEN 12 THEN
                     vcolumn12(cvalor) := tvalor;
                  WHEN 13 THEN
                     vcolumn13(cvalor) := tvalor;
                  ELSE
                     NULL;
               END CASE;
            END LOOP;

            DBMS_SQL.close_cursor(curid);
         END IF;
      END LOOP;

      preg := t_iax_preguntastab();
      tcolumnas := t_iax_preguntastab_columns();
      vpasexec := 4;

      -- p_control_error('AMC','f_get_preguntab_rie','ptablas:'||ptablas);
      IF ptablas = 'EST' THEN
         vpasexec := 5;
         -- select sproduc into vsproduc from estseguros where sseguro = psseguro;
         vpasexec := 6;
         vidioma := pac_md_common.f_get_cxtidioma();

         -- p_control_error('AMC','f_get_preguntab_rie','pcnivel:'||pcnivel);
         IF pcnivel = 'P' THEN
            FOR cur IN (SELECT DISTINCT (nlinea)
                                   FROM estpregunpolsegtab
                                  WHERE sseguro = psseguro
                                    AND cpregun = pcpregun
                                    AND nmovimi = NVL(pnmovimi, 1)) LOOP
               preg.EXTEND;
               preg(preg.LAST) := ob_iax_preguntastab();
               preg(preg.LAST).cpregun := pcpregun;
               preg(preg.LAST).nmovimi := NVL(pnmovimi, 1);
               preg(preg.LAST).nlinea := cur.nlinea;
               tcolumnas := t_iax_preguntastab_columns();

               FOR cur2 IN (SELECT   p.ccolumna, p.tvalor, p.fvalor, p.nvalor, pc.ctipcol,
                                     pc.tconsulta
                                FROM estpregunpolsegtab p, preguntab_colum pc
                               WHERE p.sseguro = psseguro
                                 AND p.cpregun = pcpregun
                                 AND nmovimi = (SELECT MAX(nmovimi)
                                                  FROM estpregunpolsegtab pp
                                                 WHERE pp.sseguro = p.sseguro
                                                   AND pp.cpregun = p.cpregun
                                                   AND pp.nlinea = cur.nlinea)
                                 AND p.cpregun = pc.cpregun
                                 AND p.ccolumna = pc.ccolumn
                                 AND p.nlinea = cur.nlinea
                            ORDER BY TO_NUMBER(p.ccolumna)) LOOP
                  tcolumnas.EXTEND;
                  tcolumnas(tcolumnas.LAST) := ob_iax_preguntastab_columns();
                  tcolumnas(tcolumnas.LAST).ccolumna := cur2.ccolumna;
                  tcolumnas(tcolumnas.LAST).ctipcol := cur2.ctipcol;

                  IF cur2.ctipcol != 5 THEN
                     tcolumnas(tcolumnas.LAST).tvalor := cur2.nvalor;
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;
                  ELSE
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;

                     CASE cur2.ccolumna
                        WHEN 1 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn1(cur2.nvalor);
                        WHEN 2 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn2(cur2.nvalor);
                        WHEN 3 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn3(cur2.nvalor);
                        WHEN 4 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn4(cur2.nvalor);
                        WHEN 5 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn5(cur2.nvalor);
                        WHEN 6 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn6(cur2.nvalor);
                        WHEN 7 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn7(cur2.nvalor);
                        WHEN 8 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn8(cur2.nvalor);
                        WHEN 9 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn9(cur2.nvalor);
                        WHEN 10 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn10(cur2.nvalor);
                        WHEN 11 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn11(cur2.nvalor);
                        WHEN 12 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn12(cur2.nvalor);
                        WHEN 13 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn13(cur2.nvalor);
                        ELSE
                           NULL;
                     END CASE;
                  END IF;
               END LOOP;

               preg(preg.LAST).tcolumnas := tcolumnas;
            END LOOP;
         ELSIF pcnivel = 'R' THEN
            vpasexec := 7;

            FOR cur IN (SELECT DISTINCT (nlinea)
                                   FROM estpregunsegtab
                                  WHERE sseguro = psseguro
                                    AND cpregun = pcpregun
                                    AND nriesgo = pnriesgo
                                    AND nmovimi = NVL(pnmovimi, 1)) LOOP
               --   p_control_error('AMC','f_get_preguntab_rie','cur.nlinea:'||cur.nlinea);
               vpasexec := 8;
               preg.EXTEND;
               preg(preg.LAST) := ob_iax_preguntastab();
               preg(preg.LAST).cpregun := pcpregun;
               preg(preg.LAST).nmovimi := NVL(pnmovimi, 1);
               preg(preg.LAST).nlinea := cur.nlinea;
               tcolumnas := t_iax_preguntastab_columns();

               FOR cur2 IN (SELECT   p.ccolumna, p.tvalor, p.fvalor, p.nvalor, pc.ctipcol,
                                     pc.tconsulta
                                FROM estpregunsegtab p, preguntab_colum pc
                               WHERE p.sseguro = psseguro
                                 AND p.cpregun = pcpregun
                                 AND nmovimi = (SELECT MAX(nmovimi)
                                                  FROM estpregunsegtab pp
                                                 WHERE pp.sseguro = p.sseguro
                                                   AND pp.cpregun = p.cpregun
                                                   AND pp.nriesgo = p.nriesgo
                                                   AND pp.nlinea = cur.nlinea)
                                 AND nriesgo = pnriesgo
                                 AND p.cpregun = pc.cpregun
                                 AND p.ccolumna = pc.ccolumn
                                 AND p.nlinea = cur.nlinea
                            ORDER BY TO_NUMBER(p.ccolumna)) LOOP
                  vpasexec := 9;
                  tcolumnas.EXTEND;
                  tcolumnas(tcolumnas.LAST) := ob_iax_preguntastab_columns();
                  tcolumnas(tcolumnas.LAST).ccolumna := cur2.ccolumna;
                  tcolumnas(tcolumnas.LAST).ctipcol := cur2.ctipcol;
                  vpasexec := 10;

                  IF cur2.ctipcol != 5 THEN
                     tcolumnas(tcolumnas.LAST).tvalor := cur2.nvalor;
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;
                  ELSE
                     vpasexec := 11;
                     p_control_error('AMC', 'f_get_preguntab_rie',
                                     'cur2.ccolumna:' || cur2.ccolumna || ' cur2.nvalor:'
                                     || cur2.nvalor);
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;

                     CASE cur2.ccolumna
                        WHEN 1 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn1(cur2.nvalor);
                        WHEN 2 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn2(cur2.nvalor);
                        WHEN 3 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn3(cur2.nvalor);
                        WHEN 4 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn4(cur2.nvalor);
                        WHEN 5 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn5(cur2.nvalor);
                        WHEN 6 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn6(cur2.nvalor);
                        WHEN 7 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn7(cur2.nvalor);
                        WHEN 8 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn8(cur2.nvalor);
                        WHEN 9 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn9(cur2.nvalor);
                        WHEN 10 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn10(cur2.nvalor);
                        WHEN 11 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn11(cur2.nvalor);
                        WHEN 12 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn12(cur2.nvalor);
                        WHEN 13 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn13(cur2.nvalor);
                        ELSE
                           NULL;
                     END CASE;
                  END IF;
               -- p_control_error('AMC','f_get_preguntab_rie','tcolumnas(tcolumnas.LAST).tvalor:'||tcolumnas(tcolumnas.LAST).tvalor);
               END LOOP;

               preg(preg.LAST).tcolumnas := tcolumnas;
            END LOOP;
         ELSIF pcnivel = 'G' THEN
            FOR cur IN (SELECT DISTINCT (nlinea)
                                   FROM estpregungaransegtab
                                  WHERE sseguro = psseguro
                                    AND cpregun = pcpregun
                                    AND nriesgo = pnriesgo
                                    AND cgarant = pcgarant
                                    AND nmovimi  = nvl(pnmovimi,1)) LOOP
               preg.EXTEND;
               preg(preg.LAST) := ob_iax_preguntastab();
               preg(preg.LAST).cpregun := pcpregun;
               preg(preg.LAST).nmovimi := NVL(pnmovimi, 1);
               preg(preg.LAST).nlinea := cur.nlinea;
               tcolumnas := t_iax_preguntastab_columns();

               FOR cur2 IN (SELECT   p.ccolumna, p.tvalor, p.fvalor, p.nvalor, pc.ctipcol,
                                     pc.tconsulta
                                FROM estpregungaransegtab p, preguntab_colum pc
                               WHERE p.sseguro = psseguro
                                 AND p.cpregun = pcpregun
                                 AND nmovimi = (SELECT MAX(nmovimi)
                                                  FROM estpregungaransegtab pp
                                                 WHERE pp.sseguro = p.sseguro
                                                   AND pp.cpregun = p.cpregun
                                                   AND pp.nriesgo = p.nriesgo
                                                   AND pp.nlinea = cur.nlinea
                                                   AND pp.cgarant = p.cgarant)
                                 AND nriesgo = pnriesgo
                                 AND cgarant = pcgarant
                                 AND p.cpregun = pc.cpregun
                                 AND p.ccolumna = pc.ccolumn
                                 AND p.nlinea = cur.nlinea
                            ORDER BY TO_NUMBER(p.ccolumna)) LOOP
                  tcolumnas.EXTEND;
                  tcolumnas(tcolumnas.LAST) := ob_iax_preguntastab_columns();
                  tcolumnas(tcolumnas.LAST).ccolumna := cur2.ccolumna;
                  tcolumnas(tcolumnas.LAST).ctipcol := cur2.ctipcol;
                  p_control_error('AMC', 'f_get_preguntab_rie',
                                  'cur2.ccolumna:' || cur2.ccolumna || ' cur2.nvalor:'
                                  || cur2.nvalor);

                  IF cur2.ctipcol != 5 THEN
                     tcolumnas(tcolumnas.LAST).tvalor := cur2.nvalor;
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;
                  ELSE
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;

                     CASE cur2.ccolumna
                        WHEN 1 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn1(cur2.nvalor);
                        WHEN 2 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn2(cur2.nvalor);
                        WHEN 3 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn3(cur2.nvalor);
                        WHEN 4 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn4(cur2.nvalor);
                        WHEN 5 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn5(cur2.nvalor);
                        WHEN 6 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn6(cur2.nvalor);
                        WHEN 7 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn7(cur2.nvalor);
                        WHEN 8 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn8(cur2.nvalor);
                        WHEN 9 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn9(cur2.nvalor);
                        WHEN 10 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn10(cur2.nvalor);
                        WHEN 11 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn11(cur2.nvalor);
                        WHEN 12 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn12(cur2.nvalor);
                        WHEN 13 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn13(cur2.nvalor);
                        ELSE
                           NULL;
                     END CASE;
                  END IF;
               END LOOP;

               preg(preg.LAST).tcolumnas := tcolumnas;
            END LOOP;
         END IF;

         BEGIN
            SELECT sproces
              INTO psproces_out
              FROM estvalidacargapregtab
             WHERE cpregun = pcpregun
               AND sseguro = psseguro
               AND nmovimi = NVL(pnmovimi, 1)
               AND nriesgo = NVL(pnriesgo, 1)
               AND cgarant = NVL(pcgarant, 0)
               AND norden = (SELECT MAX(norden)
                               FROM estvalidacargapregtab
                              WHERE cpregun = pcpregun
                                AND sseguro = psseguro
                                AND nmovimi = NVL(pnmovimi, 1)
                                AND nriesgo = NVL(pnriesgo, 1)
                                AND cgarant = NVL(pcgarant, 0));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      ELSE
         -- p_control_error('AMC','f_get_preguntab_rie','pcnivel:'||pcnivel);
         vpasexec := 7;

         IF pcnivel = 'P' THEN
            FOR cur IN (SELECT DISTINCT (nlinea)
                                   FROM pregunpolsegtab
                                  WHERE sseguro = psseguro
                                    AND cpregun = pcpregun
                                    AND nmovimi = NVL(pnmovimi, 1)) LOOP
               preg.EXTEND;
               preg(preg.LAST) := ob_iax_preguntastab();
               preg(preg.LAST).cpregun := pcpregun;
               preg(preg.LAST).nmovimi := NVL(pnmovimi, 1);
               preg(preg.LAST).nlinea := cur.nlinea;
               tcolumnas := t_iax_preguntastab_columns();

               FOR cur2 IN (SELECT p.ccolumna, p.tvalor, p.fvalor, p.nvalor, pc.ctipcol,
                                   pc.tconsulta
                              FROM pregunpolsegtab p, preguntab_colum pc
                             WHERE p.sseguro = psseguro
                               AND p.cpregun = pcpregun
                               AND nmovimi = (SELECT MAX(nmovimi)
                                                FROM pregunpolsegtab pp
                                               WHERE pp.sseguro = p.sseguro
                                                 AND pp.cpregun = p.cpregun
                                                 AND pp.nlinea = cur.nlinea)
                               AND p.cpregun = pc.cpregun
                               AND p.ccolumna = pc.ccolumn
                               AND p.nlinea = cur.nlinea) LOOP
                  tcolumnas.EXTEND;
                  tcolumnas(tcolumnas.LAST) := ob_iax_preguntastab_columns();
                  tcolumnas(tcolumnas.LAST).ccolumna := cur2.ccolumna;
                  tcolumnas(tcolumnas.LAST).ctipcol := cur2.ctipcol;

                  IF cur2.ctipcol != 5 THEN
                     tcolumnas(tcolumnas.LAST).tvalor := cur2.nvalor;
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;
                  ELSE
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;

                     CASE cur2.ccolumna
                        WHEN 1 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn1(cur2.nvalor);
                        WHEN 2 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn2(cur2.nvalor);
                        WHEN 3 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn3(cur2.nvalor);
                        WHEN 4 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn4(cur2.nvalor);
                        WHEN 5 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn5(cur2.nvalor);
                        WHEN 6 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn6(cur2.nvalor);
                        WHEN 7 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn7(cur2.nvalor);
                        WHEN 8 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn8(cur2.nvalor);
                        WHEN 9 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn9(cur2.nvalor);
                        WHEN 10 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn10(cur2.nvalor);
                        WHEN 11 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn11(cur2.nvalor);
                        WHEN 12 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn12(cur2.nvalor);
                        WHEN 13 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn13(cur2.nvalor);
                        ELSE
                           NULL;
                     END CASE;
                  END IF;
               END LOOP;

               preg(preg.LAST).tcolumnas := tcolumnas;
            END LOOP;
         ELSIF pcnivel = 'R' THEN
            vpasexec := 8;

            FOR cur IN (SELECT DISTINCT (nlinea)
                                   FROM pregunsegtab
                                  WHERE sseguro = psseguro
                                    AND cpregun = pcpregun
                                    AND nriesgo = pnriesgo
                                    AND nmovimi = NVL(pnmovimi, 1)) LOOP
               preg.EXTEND;
               preg(preg.LAST) := ob_iax_preguntastab();
               preg(preg.LAST).cpregun := pcpregun;
               preg(preg.LAST).nmovimi := NVL(pnmovimi, 1);
               preg(preg.LAST).nlinea := cur.nlinea;
               tcolumnas := t_iax_preguntastab_columns();
               --  p_control_error('AMC','f_get_preguntab_rie','cur.nlinea:'||cur.nlinea);
               vpasexec := 9;

               FOR cur2 IN (SELECT   p.ccolumna, p.tvalor, p.fvalor, p.nvalor, pc.ctipcol,
                                     pc.tconsulta
                                FROM pregunsegtab p, preguntab_colum pc
                               WHERE p.sseguro = psseguro
                                 AND p.cpregun = pcpregun
                                 AND nmovimi = (SELECT MAX(nmovimi)
                                                  FROM pregunsegtab pp
                                                 WHERE pp.sseguro = p.sseguro
                                                   AND pp.cpregun = p.cpregun
                                                   AND pp.nriesgo = p.nriesgo
                                                   AND pp.nlinea = cur.nlinea)
                                 AND nriesgo = pnriesgo
                                 AND p.cpregun = pc.cpregun
                                 AND p.ccolumna = pc.ccolumn
                                 AND p.nlinea = cur.nlinea
                            ORDER BY TO_NUMBER(p.ccolumna)) LOOP
                  tcolumnas.EXTEND;
                  tcolumnas(tcolumnas.LAST) := ob_iax_preguntastab_columns();
                  tcolumnas(tcolumnas.LAST).ccolumna := cur2.ccolumna;
                  tcolumnas(tcolumnas.LAST).ctipcol := cur2.ctipcol;
                  --  p_control_error('AMC','f_get_preguntab_rie','cur2.tvalor:'||cur2.tvalor);
                  vpasexec := 10;

                  IF cur2.ctipcol != 5 THEN
                     tcolumnas(tcolumnas.LAST).tvalor := cur2.nvalor;
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;
                  ELSE
                     vpasexec := 11;
                     --   p_control_error('AMC','f_get_preguntab_rie','cur2.tvalor:'||cur2.nvalor);
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;

                     CASE cur2.ccolumna
                        WHEN 1 THEN
                           vpasexec := 111;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn1(cur2.nvalor);
                        WHEN 2 THEN
                           vpasexec := 112;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn2(cur2.nvalor);
                        WHEN 3 THEN
                           vpasexec := 113;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn3(cur2.nvalor);
                        WHEN 4 THEN
                           vpasexec := 114;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn4(cur2.nvalor);
                        WHEN 5 THEN
                           vpasexec := 115;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn5(cur2.nvalor);
                        WHEN 6 THEN
                           vpasexec := 116;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn6(cur2.nvalor);
                        WHEN 7 THEN
                           vpasexec := 117;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn7(cur2.nvalor);
                        WHEN 8 THEN
                           vpasexec := 118;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn8(cur2.nvalor);
                        WHEN 9 THEN
                           vpasexec := 119;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn9(cur2.nvalor);
                        WHEN 10 THEN
                           vpasexec := 120;
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn10(cur2.nvalor);
                        WHEN 11 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn11(cur2.nvalor);
                        WHEN 12 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn12(cur2.nvalor);
                        WHEN 13 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn13(cur2.nvalor);
                        ELSE
                           NULL;
                     END CASE;
                  END IF;
               --  p_control_error('AMC','f_get_preguntab_rie','tcolumnas(tcolumnas.LAST).tvalor:'||tcolumnas(tcolumnas.LAST).tvalor);
               END LOOP;

               vpasexec := 12;
               preg(preg.LAST).tcolumnas := tcolumnas;
            END LOOP;

            vpasexec := 13;
         ELSIF pcnivel = 'G' THEN
            FOR cur IN (SELECT DISTINCT (nlinea)
                                   FROM pregungaransegtab
                                  WHERE sseguro = psseguro
                                    AND cpregun = pcpregun
                                    AND nriesgo = pnriesgo
                                    AND cgarant = pcgarant
                                    AND nmovimi  in
                                    (select decode(cempres,25,decode(pcpregun,9235,1,nvl(pnmovimi,1)), nvl(pnmovimi,1)) from empresas)) LOOP
               preg.EXTEND;
               preg(preg.LAST) := ob_iax_preguntastab();
               preg(preg.LAST).cpregun := pcpregun;
               preg(preg.LAST).nmovimi := NVL(pnmovimi, 1);
               preg(preg.LAST).nlinea := cur.nlinea;
               tcolumnas := t_iax_preguntastab_columns();

               FOR cur2 IN (SELECT p.ccolumna, p.tvalor, p.fvalor, p.nvalor, pc.ctipcol,
                                   pc.tconsulta
                              FROM pregungaransegtab p, preguntab_colum pc
                             WHERE p.sseguro = psseguro
                               AND p.cpregun = pcpregun
                               AND nmovimi = (SELECT MAX(nmovimi)
                                                FROM pregungaransegtab pp
                                               WHERE pp.sseguro = p.sseguro
                                                 AND pp.cpregun = p.cpregun
                                                 AND pp.nriesgo = p.nriesgo
                                                 AND pp.nlinea = cur.nlinea
                                                 AND pp.cgarant = p.cgarant)
                               AND nriesgo = pnriesgo
                               AND cgarant = pcgarant
                               AND p.cpregun = pc.cpregun
                               AND p.ccolumna = pc.ccolumn
                               AND p.nlinea = cur.nlinea) LOOP
                  tcolumnas.EXTEND;
                  tcolumnas(tcolumnas.LAST) := ob_iax_preguntastab_columns();
                  tcolumnas(tcolumnas.LAST).ccolumna := cur2.ccolumna;
                  tcolumnas(tcolumnas.LAST).ctipcol := cur2.ctipcol;

                  IF cur2.ctipcol = 2 THEN --CONF-703 preguntab_column cticol = 2 texto no estaba trayendo el texto de la columna
                     tcolumnas(tcolumnas.LAST).tvalor := cur2.tvalor;
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;
                  ELSIF cur2.ctipcol = 5 THEN
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;

                     CASE cur2.ccolumna
                        WHEN 1 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn1(cur2.nvalor);
                        WHEN 2 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn2(cur2.nvalor);
                        WHEN 3 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn3(cur2.nvalor);
                        WHEN 4 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn4(cur2.nvalor);
                        WHEN 5 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn5(cur2.nvalor);
                        WHEN 6 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn6(cur2.nvalor);
                        WHEN 7 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn7(cur2.nvalor);
                        WHEN 8 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn8(cur2.nvalor);
                        WHEN 9 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn9(cur2.nvalor);
                        WHEN 10 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn10(cur2.nvalor);
                        WHEN 11 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn11(cur2.nvalor);
                        WHEN 12 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn12(cur2.nvalor);
                        WHEN 13 THEN
                           tcolumnas(tcolumnas.LAST).tvalor := vcolumn13(cur2.nvalor);
                        ELSE
                           NULL;
                     END CASE;
                  ELSE
                     tcolumnas(tcolumnas.LAST).tvalor := cur2.nvalor;
                     tcolumnas(tcolumnas.LAST).nvalor := cur2.nvalor;
                  END IF;
               END LOOP;

               preg(preg.LAST).tcolumnas := tcolumnas;
            END LOOP;
         END IF;

         BEGIN
            SELECT sproces
              INTO psproces_out
              FROM validacargapregtab
             WHERE cpregun = pcpregun
               AND sseguro = psseguro
               AND nmovimi = NVL(pnmovimi, 1)
               AND nriesgo = NVL(pnriesgo, 1)
               AND cgarant = NVL(pcgarant, 0)
               AND norden = (SELECT MAX(norden)
                               FROM validacargapregtab
                              WHERE cpregun = pcpregun
                                AND sseguro = psseguro
                                AND nmovimi = NVL(pnmovimi, 1)
                                AND nriesgo = NVL(pnriesgo, 1)
                                AND cgarant = NVL(pcgarant, 0));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

      vpasexec := 14;
      RETURN preg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_preguntab_rie;

   /***************************************************************************
        procedimiento que ejecuta una carga
        param in p_nombre   : Nombre fichero
        param in  out psproces   : N¿mero proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
     **************************************************************************/
   FUNCTION f_ejecutar_carga_preguntab(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_cpregun IN NUMBER,
      p_nmovimi IN NUMBER,
      ptablas IN VARCHAR2,
      psproces IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'ptablas=' || ptablas || ', p_sseguro=' || p_sseguro || ', pnriesgo=' || p_nriesgo
            || ' pcpregun:' || p_cpregun || ' pcgarant:' || p_cgarant || ' pnmovimi:'
            || p_nmovimi;
      vobject        VARCHAR2(200) := 'pac_md_carga_preguntab.f_ejecutar_carga_preguntab';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_carga_preguntab.f_ejecutar_carga_preguntab(p_nombre, p_path, p_cproces,
                                                                p_sseguro, p_nriesgo,
                                                                p_cgarant, p_cpregun,
                                                                p_nmovimi, psproces);
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
   END f_ejecutar_carga_preguntab;

   FUNCTION f_borrar_carga(
      psseguro IN NUMBER,
      pcpregun IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcnivel=' || pcnivel || ', psseguro=' || psseguro || ', pnriesgo=' || pnriesgo
            || ' pcpregun:' || pcpregun || ' pcgarant:' || pcgarant || ' pnmovimi:'
            || pnmovimi;
      vobject        VARCHAR2(200) := 'pac_md_carga_preguntab.f_borrar_carga';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_carga_preguntab.f_borrar_carga(psseguro, pcpregun, pnriesgo, pcgarant,
                                                    pnmovimi, pcnivel);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_borrar_carga;

   FUNCTION f_validar_carga(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(100) := 'PAC_MD_CARGA_PREGUNTAB.f_validar_carga';
      vparam         VARCHAR2(1000)
         := 'psproces:' || psproces || ' psseguro:' || psseguro || ' pnriesgo:' || pnriesgo
            || ' pcgarant:' || pcgarant || ' pcpregun:' || pcpregun || ' pnmovimi:'
            || pnmovimi;
      vpasexec       NUMBER(8) := 1;
      vnum_err       NUMBER;
      vmensaje       NUMBER;
   BEGIN
      vnum_err := pac_carga_preguntab.f_validar_carga(psproces, psseguro, pnriesgo, pcgarant,
                                                      pcpregun, pnmovimi, vmensaje);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF vmensaje IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vmensaje);
      END IF;

      RETURN 0;
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
   END f_validar_carga;

   FUNCTION f_cargas_validadas(
      psseguro IN NUMBER,
      pemitir IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(100) := 'PAC_MD_CARGA_PREGUNTAB.f_cargas_validadas';
      vparam         VARCHAR2(1000) := 'psseguro:' || psseguro;
      vpasexec       NUMBER(8) := 1;
      vnum_err       NUMBER;
      vmensaje       VARCHAR2(1000);
   BEGIN
      vnum_err := pac_carga_preguntab.f_cargas_validadas(psseguro, pemitir, vmensaje);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      p_control_error('AMC', 'cargas validadas', vmensaje);

      IF vmensaje IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, vmensaje);
      END IF;

      RETURN 0;
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
   END f_cargas_validadas;
END pac_md_carga_preguntab;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_PREGUNTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_PREGUNTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_PREGUNTAB" TO "PROGRAMADORESCSI";
