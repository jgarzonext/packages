--------------------------------------------------------
--  DDL for Package Body PAC_MNTPREGUNPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MNTPREGUNPROD" AS
/******************************************************************************
   NOMBRE:       PAC_MD_MNTPROD
   PROPÓSITO: Funciones para mantenimiento productos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/04/2010   AMC                1. Creación del package.
   2.0        10/01/2012   DRA                2. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
   3.0        18/02/2014   DEV                3. 0029920: POSFC100-Taller de Productos
******************************************************************************/

   /*************************************************************************
      Recupera las posibles respuestas de una pregunta
      param in pcpregun : codigo de pregunta
      param in pcidioma : código de idioma

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_respuestas(pcpregun IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      texto          VARCHAR2(100);
   BEGIN
      texto := 'select crespue,trespue from respuestas' || ' where cpregun =' || pcpregun
               || ' and cidioma =' || pcidioma;
      RETURN texto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPREGUNPROD.F_GET_RESPUESTAS', 1,
                     'pcpregun=' || pcpregun || ' pcidioma=' || pcidioma, SQLERRM);
         RETURN NULL;
   END f_get_respuestas;

   /*************************************************************************
      Busca preguntas por descripción
      param in ptpregun : texto de la pregunta
      param in pcidioma : código de idioma

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_preguntas(ptpregun IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      texto          VARCHAR2(200);
   BEGIN
      texto := 'select cpregun,tpregun ' || ' from preguntas'
               || ' where upper(tpregun) like ''%' || UPPER(ptpregun) || '%'''
               || ' and cidioma =' || pcidioma || ' order by cpregun asc';
      RETURN texto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPREGUNPROD.F_GET_RESPUESTAS', 1,
                     'pcpregun=' || ptpregun || ' pcidioma=' || pcidioma, SQLERRM);
         RETURN NULL;
   END f_get_preguntas;

   /*************************************************************************
      Recupera el tipo de respuesta de una pregunta
      param in pcpregun : codigo de la pregunta
      param out pctippre : codigo del tipo de pregunta

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_ctippre(pcpregun IN NUMBER, pctippre OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT ctippre
        INTO pctippre
        FROM codipregun
       WHERE cpregun = pcpregun;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- La pregunta no existe
         RETURN 102741;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPREGUNPROD.f_get_ctippre', 1,
                     'pcpregun=' || pcpregun, SQLERRM);
         RETURN 1;
   END f_get_ctippre;

    /*************************************************************************
      Recupera la lista con las diferentes respuestas
      param in pcpregun : codigo de la pregunta
      param in pcidioma : codigo de idioma

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_listrespue(pcpregun IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vtexto         VARCHAR2(300);
   BEGIN
      vtexto := 'select crespue catribu,trespue tatribu from respuestas' || ' where cpregun ='
                || pcpregun || ' and cidioma =' || pcidioma;
      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPREGUNPROD.f_get_listrespue', 1,
                     'pcpregun=' || pcpregun || ' pcidioma=' || pcidioma, SQLERRM);
         RETURN NULL;
   END f_get_listrespue;

    /*************************************************************************
      Asigna la pregunta a nivel de producto/actividad/garantia
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param in pcpretip : tipo respuesta
      param in pnpreord : orden de la pregunta
      param in ptprefor : formula para cálculo respuesta
      param in pcpreobl : Obligatoria u opcional
      param in pnpreimp : Orden de impresión
      param in pcresdef : Respuesta por defecto
      param in pcofersn : Aparece en ofertas
      param in ptvalfor : fórmula para validación respuesta
      param in pcmodo   : Modo
      param in pcnivel  : Nivel, poliza o riesgo
      param in pctarpol : Retarificar
      param in pcvisible : Pregunta visible
      param in pcesccero : Certificado cero
      param in pcvisiblecol : Visible colectivos
      param in pcvisiblecert : Visible certificados
      param in pcrecarg : Recarga de preguntas

      Bug 13953 - 14/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_set_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcpretip IN NUMBER,
      pnpreord IN NUMBER,
      ptprefor IN VARCHAR2,
      pcpreobl IN NUMBER,
      pnpreimp IN NUMBER,
      pcresdef IN NUMBER,
      pcofersn IN NUMBER,
      ptvalfor IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pcnivel IN VARCHAR2,
      pctarpol IN NUMBER,
      pcvisible IN NUMBER,
      pcesccero IN NUMBER,
      pcvisiblecol IN NUMBER,
      pcvisiblecert IN NUMBER,
      pcrecarg IN NUMBER)
      RETURN NUMBER IS
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
      vcmodo         VARCHAR2(1);
      vcnivel        VARCHAR2(1);
      mensajes       t_iax_mensajes;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPREGUNPROD.f_set_pregunta';
      vpas           NUMBER;
   BEGIN
      vpas := 100;

      IF ptabla = 'PROD' THEN
         vpas := 110;
         verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

         IF verror <> 0 THEN
            RETURN verror;
         END IF;

         IF pcmodo = 1 THEN
            vcmodo := 'T';
         ELSIF pcmodo = 2 THEN
            vcmodo := 'S';
         ELSIF pcmodo = 3 THEN
            vcmodo := 'N';
         END IF;

         IF pcnivel = 1 THEN
            vcnivel := 'P';
         ELSIF pcnivel = 2 THEN
            vcnivel := 'R';
         -- BUG20498:DRA:09/01/2012:Inici
         ELSIF pcnivel = 4 THEN
            vcnivel := 'C';
         -- BUG20498:DRA:09/01/2012:Fi
         END IF;

         BEGIN
            vpas := 150;

            INSERT INTO pregunpro
                        (cpregun, cmodali, ccolect, cramo, ctipseg, sproduc, cpretip,
                         npreord, tprefor, cpreobl, npreimp, cresdef, cofersn,
                         tvalfor, cmodo, cnivel, ctarpol, cvisible, esccero,
                         visiblecol, visiblecert, crecarg)
                 VALUES (pcpregun, vcmodali, vccolect, vcramo, vctipseg, psproduc, pcpretip,
                         pnpreord, ptprefor, pcpreobl, pnpreimp, pcresdef, pcofersn,
                         ptvalfor, vcmodo, vcnivel, pctarpol, pcvisible, NVL(pcesccero, 0),
                         NVL(pcvisiblecol, 1), NVL(pcvisiblecert, 1), NVL(pcrecarg, 0));
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vpas := 160;

               UPDATE pregunpro
                  SET cpretip = pcpretip,
                      npreord = pnpreord,
                      tprefor = ptprefor,
                      cpreobl = pcpreobl,
                      npreimp = pnpreimp,
                      cresdef = pcresdef,
                      cofersn = pcofersn,
                      tvalfor = ptvalfor,
                      cmodo = vcmodo,
                      cnivel = vcnivel,
                      ctarpol = pctarpol,
                      cvisible = pcvisible,
                      esccero = NVL(pcesccero, 0),
                      visiblecol = NVL(pcvisiblecol, 1),
                      visiblecert = NVL(pcvisiblecert, 1),
                      crecarg = NVL(pcrecarg, 0)
                WHERE cpregun = pcpregun
                  AND cmodali = vcmodali
                  AND ccolect = vccolect
                  AND cramo = vcramo
                  AND ctipseg = vctipseg
                  AND sproduc = psproduc;
         END;
      ELSIF ptabla = 'ACT' THEN
         vpas := 170;
         verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

         IF verror <> 0 THEN
            RETURN verror;
         END IF;

         BEGIN
            vpas := 180;

            INSERT INTO pregunproactivi
                        (cramo, cmodali, ccolect, ctipseg, cactivi, cpregun, sproduc,
                         cpretip, npreord, tprefor, cpreobl, npreimp, cresdef,
                         cofersn, tvalfor)
                 VALUES (vcramo, vcmodali, vccolect, vctipseg, pcactivi, pcpregun, psproduc,
                         pcpretip, pnpreord, ptprefor, pcpreobl, pnpreimp, pcresdef,
                         pcofersn, ptvalfor);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vpas := 190;

               UPDATE pregunproactivi
                  SET cpretip = pcpretip,
                      npreord = pnpreord,
                      tprefor = ptprefor,
                      cpreobl = pcpreobl,
                      npreimp = pnpreimp,
                      cresdef = pcresdef,
                      cofersn = pcofersn,
                      tvalfor = ptvalfor
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ccolect = vccolect
                  AND ctipseg = vctipseg
                  AND cactivi = pcactivi
                  AND cpregun = pcpregun
                  AND sproduc = psproduc;
         END;
      ELSIF ptabla = 'GAR' THEN
         BEGIN
            vpas := 200;

            IF pcmodo = 1 THEN
               vcmodo := 'T';
            ELSIF pcmodo = 2 THEN
               vcmodo := 'S';
            ELSIF pcmodo = 3 THEN
               vcmodo := 'N';
            END IF;

            IF pcnivel = 1 THEN
               vcnivel := 'P';
            ELSIF pcnivel = 2 THEN
               vcnivel := 'R';
            -- BUG20498:DRA:09/01/2012:Inici
            ELSIF pcnivel = 4 THEN
               vcnivel := 'C';
            -- BUG20498:DRA:09/01/2012:Fi
            END IF;

            INSERT INTO pregunprogaran
                        (sproduc, cactivi, cgarant, cpregun, cpretip, npreord, tprefor,
                         cpreobl, npreimp, cresdef, cofersn, tvalfor, esccero,
                         visiblecol, visiblecert, cvisible,
                         cmodo)
                 VALUES (psproduc, pcactivi, pcgarant, pcpregun, pcpretip, pnpreord, ptprefor,
                         pcpreobl, pnpreimp, pcresdef, pcofersn, ptvalfor, NVL(pcesccero, 0),
                         NVL(pcvisiblecol, 1), NVL(pcvisiblecert, 1), NVL(pcvisible, 2),
                         NVL(vcmodo, 'T'));
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vpas := 210;

               UPDATE pregunprogaran
                  SET cpretip = pcpretip,
                      npreord = pnpreord,
                      tprefor = ptprefor,
                      cpreobl = pcpreobl,
                      npreimp = pnpreimp,
                      cresdef = pcresdef,
                      cofersn = pcofersn,
                      tvalfor = ptvalfor,
                      esccero = NVL(pcesccero, 0),
                      visiblecol = NVL(pcvisiblecol, 1),
                      visiblecert = NVL(pcvisiblecert, 1),
                      cvisible = NVL(pcvisible, 2),
                      cmodo = NVL(vcmodo, 'T')
                WHERE sproduc = psproduc
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND cpregun = pcpregun;
         END;
      END IF;

      vpas := 220;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPREGUNPROD.f_set_pregunta', vpas,
                     'pcpregun=' || pcpregun || ' psproduc=' || psproduc || ' ptabla:'
                     || ptabla,
                     SQLERRM);
         RETURN 108424;
   END f_set_pregunta;

    /*************************************************************************
      Devuel los datos de una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param out pcpretip : tipo respuesta
      param out pnpreord : orden de la pregunta
      param out ptprefor : formula para cálculo respuesta
      param out pcpreobl : Obligatoria u opcional
      param out pnpreimp : Orden de impresión
      param out pcresdef : Respuesta por defecto
      param out pcofersn : Aparece en ofertas
      param out ptvalfor : fórmula para validación respuesta
      param out pcmodo   : Modo
      param out pcnivel  : Nivel, poliza o riesgo
      param out pctarpol : Retarificar
      param out pcvisible : Pregunta visible
      param out pcesccero : Certificado cero
      param out pcvisiblecol : Visible colectivos
      param out pcvisiblecert : Visible certificados
      param out pcrecarg : Recarga de preguntas
      Bug 13953 - 14/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcpretip OUT NUMBER,
      pnpreord OUT NUMBER,
      ptprefor OUT VARCHAR2,
      pcpreobl OUT NUMBER,
      pnpreimp OUT NUMBER,
      pcresdef OUT NUMBER,
      pcofersn OUT NUMBER,
      ptvalfor OUT VARCHAR2,
      pcmodo OUT VARCHAR2,
      pcnivel OUT VARCHAR2,
      pctarpol OUT NUMBER,
      pcvisible OUT NUMBER,
      pcesccero OUT NUMBER,
      pcvisiblecol OUT NUMBER,
      pcvisiblecert OUT NUMBER,
      pcrecarg OUT NUMBER)
      RETURN NUMBER IS
      vcmodo         VARCHAR2(2);
      vcnivel        VARCHAR2(2);
   BEGIN
      IF ptabla = 'PROD' THEN
         SELECT cpretip, npreord, tprefor, cpreobl, npreimp, cresdef, cofersn,
                tvalfor, cmodo, cnivel, ctarpol, cvisible, esccero, visiblecol,
                visiblecert, crecarg
           INTO pcpretip, pnpreord, ptprefor, pcpreobl, pnpreimp, pcresdef, pcofersn,
                ptvalfor, vcmodo, vcnivel, pctarpol, pcvisible, pcesccero, pcvisiblecol,
                pcvisiblecert, pcrecarg
           FROM pregunpro
          WHERE cpregun = pcpregun
            AND sproduc = psproduc;

         IF vcmodo = 'T' THEN
            pcmodo := 1;
         ELSIF vcmodo = 'S' THEN
            pcmodo := 2;
         ELSIF vcmodo = 'N' THEN
            pcmodo := 3;
         END IF;

         IF vcnivel = 'P' THEN
            pcnivel := 1;
         ELSIF vcnivel = 'R' THEN
            pcnivel := 2;
         -- BUG20498:DRA:09/01/2012:Inici
         ELSIF vcnivel = 'C' THEN
            pcnivel := 4;
         -- BUG20498:DRA:09/01/2012:Fi
         END IF;
      ELSIF ptabla = 'ACT' THEN
         SELECT cpretip, npreord, tprefor, cpreobl, npreimp, cresdef, cofersn, tvalfor
           INTO pcpretip, pnpreord, ptprefor, pcpreobl, pnpreimp, pcresdef, pcofersn, ptvalfor
           FROM pregunproactivi
          WHERE cpregun = pcpregun
            AND cactivi = pcactivi
            AND sproduc = psproduc;
      ELSIF ptabla = 'GAR' THEN
         SELECT cpretip, npreord, tprefor, cpreobl, npreimp, cresdef, cofersn,
                tvalfor, esccero, visiblecol, visiblecert, cvisible, cmodo
           INTO pcpretip, pnpreord, ptprefor, pcpreobl, pnpreimp, pcresdef, pcofersn,
                ptvalfor, pcesccero, pcvisiblecol, pcvisiblecert, pcvisible, vcmodo
           FROM pregunprogaran
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant
            AND cpregun = pcpregun;

         IF vcmodo = 'T' THEN
            pcmodo := 1;
         ELSIF vcmodo = 'S' THEN
            pcmodo := 2;
         ELSIF vcmodo = 'N' THEN
            pcmodo := 3;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPREGUNPROD.f_get_pregunta', 1,
                     'pcpregun=' || pcpregun || ' psproduc=' || psproduc || ' ptabla='
                     || ptabla || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant,
                     SQLERRM);
         RETURN 9001823;
   END f_get_pregunta;

    /*************************************************************************
      Borrar una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia

      Bug 13953 - 19/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
      vcount         NUMBER;
   BEGIN
      verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

      IF ptabla = 'PROD' THEN
         SELECT COUNT(1)
           INTO vcount
           FROM pregunseg p, seguros s
          WHERE p.sseguro = s.sseguro
            AND p.cpregun = pcpregun
            AND s.sproduc = psproduc;

         IF vcount > 0 THEN
            RETURN 9901147;
         END IF;

         SELECT COUNT(1)
           INTO vcount
           FROM pregunpolseg p, seguros s
          WHERE p.sseguro = s.sseguro
            AND p.cpregun = pcpregun
            AND s.sproduc = psproduc;

         IF vcount > 0 THEN
            RETURN 9901147;
         END IF;

         DELETE      pregunpro
               WHERE cpregun = pcpregun
                 AND sproduc = psproduc
                 AND cramo = vcramo
                 AND cmodali = vcmodali
                 AND ctipseg = vctipseg
                 AND ccolect = vccolect;
      ELSIF ptabla = 'ACT' THEN
         SELECT COUNT(1)
           INTO vcount
           FROM pregunseg p, seguros s
          WHERE p.sseguro = s.sseguro
            AND p.cpregun = pcpregun
            AND s.cactivi = pcactivi
            AND s.sproduc = psproduc;

         IF vcount > 0 THEN
            RETURN 9901147;
         END IF;

         DELETE      pregunproactivi
               WHERE cpregun = pcpregun
                 AND cactivi = pcactivi
                 AND sproduc = psproduc
                 AND cramo = vcramo
                 AND cmodali = vcmodali
                 AND ctipseg = vctipseg
                 AND ccolect = vccolect;
      ELSIF ptabla = 'GAR' THEN
         SELECT COUNT(1)
           INTO vcount
           FROM pregungaranseg p, seguros s
          WHERE cpregun = pcpregun
            AND cgarant = pcgarant
            AND s.cactivi = pcactivi
            AND s.sproduc = psproduc
            AND p.sseguro = s.sseguro;

         IF vcount > 0 THEN
            RETURN 9901147;
         END IF;

         DELETE      pregunprogaran
               WHERE sproduc = psproduc
                 AND cactivi = pcactivi
                 AND cgarant = pcgarant
                 AND cpregun = pcpregun;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPREGUNPROD.f_del_pregunta', 1,
                     'pcpregun=' || pcpregun || ' psproduc=' || psproduc || ' ptabla='
                     || ptabla || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant,
                     SQLERRM);
         RETURN 9001881;
   END f_del_pregunta;

    /*************************************************************************
      Comprueba si se puede asignar una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia

      Bug 13953 - 23/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_asignar(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      vcount         NUMBER;
   BEGIN
      IF ptabla = 'PROD' THEN
         SELECT COUNT(1)
           INTO vcount
           FROM pregunproactivi
          WHERE cpregun = pcpregun
            AND cactivi = pcactivi
            AND sproduc = psproduc;

         IF vcount > 0 THEN
            RETURN 9901150;
         END IF;

         SELECT COUNT(1)
           INTO vcount
           FROM pregunprogaran
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant
            AND cpregun = pcpregun;

         IF vcount > 0 THEN
            RETURN 9901150;
         END IF;
      ELSIF ptabla = 'ACT' THEN
         SELECT COUNT(1)
           INTO vcount
           FROM pregunpro
          WHERE cpregun = pcpregun
            AND sproduc = psproduc;

         IF vcount > 0 THEN
            RETURN 9901150;
         END IF;

         SELECT COUNT(1)
           INTO vcount
           FROM pregunprogaran
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant
            AND cpregun = pcpregun;

         IF vcount > 0 THEN
            RETURN 9901150;
         END IF;
      ELSIF ptabla = 'GAR' THEN
         SELECT COUNT(1)
           INTO vcount
           FROM pregunpro
          WHERE cpregun = pcpregun
            AND sproduc = psproduc;

         IF vcount > 0 THEN
            RETURN 9901150;
         END IF;

         SELECT COUNT(1)
           INTO vcount
           FROM pregunproactivi
          WHERE cpregun = pcpregun
            AND cactivi = pcactivi
            AND sproduc = psproduc;

         IF vcount > 0 THEN
            RETURN 9901150;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPREGUNPROD.f_get_asignar', 1,
                     'pcpregun=' || pcpregun || ' psproduc=' || psproduc || ' ptabla='
                     || ptabla || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant,
                     SQLERRM);
         RETURN 140999;
   END f_get_asignar;
END pac_mntpregunprod;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNTPREGUNPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNTPREGUNPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNTPREGUNPROD" TO "PROGRAMADORESCSI";
