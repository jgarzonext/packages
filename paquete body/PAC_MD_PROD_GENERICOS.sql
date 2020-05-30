--------------------------------------------------------
--  DDL for Package Body PAC_MD_PROD_GENERICOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PROD_GENERICOS" IS
/******************************************************************************
   NOMBRE:       pac_md_prod_genericos
   PROPÃ“SITO: Funciones para gestionar productos genericos

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/08/2010    XPL              1. CreaciÃ³n del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*************************************************************************
   Obtiene las companias asociadas al seguro especificado
   param in psseguro   : Codigo sseguro
   param out ptcompanias   : Companias
   param out mensajes    : Codi idioma
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_obtener_companias(
      psseguro IN NUMBER,
      ptcompanias OUT t_iax_companiprod,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vsquery        VARCHAR2(500);
      vidioma        NUMBER;
      cur            sys_refcursor;
      vparam         VARCHAR2(500) := 'parÃ¡metros - psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_PROD_GENERICOS.f_obtener_compaÃ±ias';
      vcramo         NUMBER(8);
      vcmodali       NUMBER(2);
      vctipseg       NUMBER(2);
      vccolect       NUMBER(2);
      vcompania      ob_iax_companiprod := ob_iax_companiprod();
   BEGIN
      vnumerr := pac_prod_genericos.f_obtener_prescompanias(psseguro, vsquery, vidioma);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      ptcompanias := t_iax_companiprod();

      LOOP
         FETCH cur
          INTO vcompania.ccompani, vcompania.tcompani, vcompania.cagencorr,
               vcompania.sproducesp, vcompania.sproduc, vcompania.iddoc, vcompania.cmarcar,
               vcompania.fpresupuesto;

         IF vcompania.sproducesp IS NOT NULL THEN
            SELECT pr.cramo, pr.cmodali, pr.ctipseg, pr.ccolect
              INTO vcramo, vcmodali, vctipseg, vccolect
              FROM productos pr
             WHERE pr.sproduc = vcompania.sproducesp;

            vcompania.tproducesp := f_desproducto_t(vcramo, vcmodali, vctipseg, vccolect, 1,
                                                    pac_md_common.f_get_cxtidioma());
         END IF;

         IF vcompania.sproduc IS NOT NULL THEN
            SELECT pr.cramo, pr.cmodali, pr.ctipseg, pr.ccolect
              INTO vcramo, vcmodali, vctipseg, vccolect
              FROM productos pr
             WHERE pr.sproduc = vcompania.sproduc;

            vcompania.tproducgen := f_desproducto_t(vcramo, vcmodali, vctipseg, vccolect, 1,
                                                    pac_md_common.f_get_cxtidioma());
         END IF;

         EXIT WHEN cur%NOTFOUND;
         ptcompanias.EXTEND;
         ptcompanias(ptcompanias.LAST) := vcompania;
         vcompania := ob_iax_companiprod();
      END LOOP;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtener_companias;

/*************************************************************************
   Contrata un producto especÃ­fico
   param in det_poliza : objeto de la pÃ³liza
   param out mensajes  : Mensajes
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_traspasar_especifico(
      det_poliza IN OUT ob_iax_detpoliza,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vsquery        VARCHAR2(500);
      vidioma        NUMBER;
      cur            sys_refcursor;
      vparam         VARCHAR2(500) := 'parÃ¡metros - ';
      vobject        VARCHAR2(200) := 'PAC_MD_PROD_GENERICOS.f_traspasar_especifico';
      vcramo         NUMBER(8);
      vcmodali       NUMBER(2);
      vctipseg       NUMBER(2);
      vccolect       NUMBER(2);
      vcompania      ob_iax_companiprod := ob_iax_companiprod();
      aux_ssegpol    NUMBER;
      vsproduc       NUMBER;
      vcont          NUMBER;
      ppreguntas     t_iax_preguntas;
      pgarantias     t_iax_garantias;
      osseguro       NUMBER;
      v_index        NUMBER;
      ptclausulas    t_iax_clausulas;
   BEGIN
      IF det_poliza IS NULL
         OR det_poliza.sproduc IS NULL
         OR det_poliza.sseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

--Vamos a actualizar la tabla estseguros con los valores del producto especÃ­fico y
--obtendremos ssegpol,cramo,cmodali,ctipseg,ccolect y cactivi
      vnumerr := pac_prod_genericos.f_traspasar_especifico(det_poliza.sproduc,
                                                           det_poliza.sseguro,
                                                           det_poliza.ssegpol,
                                                           det_poliza.cramo,
                                                           det_poliza.cmodali,
                                                           det_poliza.ctipseg,
                                                           det_poliza.ccolect,
                                                           det_poliza.gestion.cactivi);
      det_poliza.nsolici := det_poliza.sseguro;
      det_poliza.npoliza := det_poliza.sseguro;
      --Inicializamos los objectos con los nuevos valores
      pac_md_produccion.inicializaobjetos(det_poliza, det_poliza.gestion, mensajes);
      pac_md_produccion.inicializaobjetosproduct(det_poliza, mensajes);
      vnumerr := pac_md_produccion.f_set_calc_fefecto(det_poliza.sproduc,
                                                      det_poliza.gestion.fefecto, mensajes);
      --actualizamos preguntas, eliminando las que no pertenezcan al producto
      ppreguntas := t_iax_preguntas();

      IF det_poliza.preguntas IS NOT NULL
         AND det_poliza.preguntas.COUNT > 0 THEN
         FOR vpregun IN det_poliza.preguntas.FIRST .. det_poliza.preguntas.LAST LOOP
            SELECT COUNT(1)
              INTO vcont
              FROM pregunpro
             WHERE cnivel = 'P'
               AND sproduc = det_poliza.sproduc
               AND cpregun = det_poliza.preguntas(vpregun).cpregun;

            IF vcont = 0 THEN
               DELETE      estpregunseg
                     WHERE cpregun = det_poliza.preguntas(vpregun).cpregun
                       AND sseguro = det_poliza.sseguro;

               DELETE      estpregunsegtab
                     WHERE cpregun = det_poliza.preguntas(vpregun).cpregun
                       AND sseguro = det_poliza.sseguro;
            ELSE
               ppreguntas.EXTEND;
               v_index := ppreguntas.LAST;
               ppreguntas(v_index) := det_poliza.preguntas(vpregun);
            END IF;
         END LOOP;
      END IF;

      det_poliza.preguntas := ppreguntas;
      --actualizamos clausulas, eliminando las que no pertenezcan al producto
      ptclausulas := t_iax_clausulas();

      IF det_poliza.clausulas IS NOT NULL
         AND det_poliza.clausulas.COUNT > 0 THEN
         FOR vclau IN det_poliza.clausulas.FIRST .. det_poliza.clausulas.LAST LOOP
            SELECT COUNT(1)
              INTO vcont
              FROM clausupro
             WHERE cramo = det_poliza.cramo
               AND cmodali = det_poliza.cmodali
               AND ctipseg = det_poliza.ctipseg
               AND ccolect = det_poliza.ccolect
               AND sclapro = det_poliza.clausulas(vclau).sclagen;

            IF vcont = 0 THEN
               DELETE      estclaususeg
                     WHERE sseguro = det_poliza.sseguro
                       AND sclagen = det_poliza.clausulas(vclau).sclagen
                       AND nordcla = NVL(det_poliza.clausulas(vclau).cidentity, 1);
            ELSE
               ptclausulas.EXTEND;
               v_index := ptclausulas.LAST;
               ptclausulas(v_index) := det_poliza.clausulas(vclau);
            END IF;
         END LOOP;
      END IF;

      det_poliza.clausulas := ptclausulas;

--actualizamos objetos del riesgo
      IF det_poliza.riesgos IS NOT NULL
         AND det_poliza.riesgos.COUNT > 0 THEN
         FOR vrisc IN det_poliza.riesgos.FIRST .. det_poliza.riesgos.LAST LOOP
            --actualizamos preguntas del riesgo, eliminando las que no pertenezcan al producto
            ppreguntas := t_iax_preguntas();

            IF det_poliza.riesgos(vrisc).preguntas IS NOT NULL
               AND det_poliza.riesgos(vrisc).preguntas.COUNT > 0 THEN
               FOR vpregun IN
                  det_poliza.riesgos(vrisc).preguntas.FIRST .. det_poliza.riesgos(vrisc).preguntas.LAST LOOP
                  SELECT COUNT(1)
                    INTO vcont
                    FROM pregunpro
                   WHERE cnivel = 'R'
                     AND sproduc = det_poliza.sproduc
                     AND cpregun = det_poliza.riesgos(vrisc).preguntas(vpregun).cpregun;

                  IF vcont = 0 THEN
                     DELETE      estpregunseg
                           WHERE cpregun =
                                          det_poliza.riesgos(vrisc).preguntas(vpregun).cpregun
                             AND nriesgo = det_poliza.riesgos(vrisc).nriesgo
                             AND sseguro = det_poliza.sseguro;

                     DELETE      estpregunsegtab
                           WHERE cpregun = det_poliza.riesgos(vrisc).preguntas(vpregun).cpregun
                             AND nriesgo = det_poliza.riesgos(vrisc).nriesgo
                             AND sseguro = det_poliza.sseguro;
                  ELSE
                     ppreguntas.EXTEND;
                     v_index := ppreguntas.LAST;
                     ppreguntas(v_index) := det_poliza.riesgos(vrisc).preguntas(vpregun);
                  END IF;
               END LOOP;
            END IF;

            det_poliza.riesgos(vrisc).preguntas := ppreguntas;
            --actualizamos garantias del riesgo, eliminando las que no pertenezcan al producto
            pgarantias := t_iax_garantias();

            IF det_poliza.riesgos(vrisc).garantias IS NOT NULL
               AND det_poliza.riesgos(vrisc).garantias.COUNT > 0 THEN
               FOR vgar IN
                  det_poliza.riesgos(vrisc).garantias.FIRST .. det_poliza.riesgos(vrisc).garantias.LAST LOOP
                  det_poliza.riesgos(vrisc).garantias(vgar).preguntas.DELETE;

                  SELECT COUNT(1)
                    INTO vcont
                    FROM garanpro
                   WHERE cramo = det_poliza.cramo
                     AND cmodali = det_poliza.cmodali
                     AND ctipseg = det_poliza.ctipseg
                     AND ccolect = det_poliza.ccolect
                     AND cactivi = det_poliza.gestion.cactivi
                     AND cgarant = det_poliza.riesgos(vrisc).garantias(vgar).cgarant;

                  IF vcont = 0 THEN
                     --   pgarantias.DELETE(vgar);
                     DELETE      estgaranseg
                           WHERE cgarant = det_poliza.riesgos(vrisc).garantias(vgar).cgarant
                             AND nriesgo = det_poliza.riesgos(vrisc).nriesgo
                             AND sseguro = det_poliza.sseguro;
                  ELSE
                     pgarantias.EXTEND;
                     v_index := pgarantias.LAST;
                     pgarantias(v_index) := det_poliza.riesgos(vrisc).garantias(vgar);
                  END IF;
               END LOOP;

               det_poliza.riesgos(vrisc).garantias := pgarantias;
            END IF;

            --actualizamos beneficiarios del riesgo, eliminando los que no pertenezcan al producto
            IF det_poliza.riesgos(vrisc).beneficiario IS NOT NULL THEN
               SELECT COUNT(1)
                 INTO vcont
                 FROM claubenpro
                WHERE sproduc = det_poliza.sproduc
                  AND sclaben = det_poliza.riesgos(vrisc).beneficiario.sclaben;

               IF vcont = 0 THEN
                  DELETE      estclaubenseg
                        WHERE sseguro = det_poliza.sseguro
                          AND nriesgo = det_poliza.riesgos(vrisc).nriesgo
                          AND sclaben = det_poliza.riesgos(vrisc).beneficiario.sclaben;
               ELSE
                  det_poliza.riesgos(vrisc).beneficiario := ob_iax_beneficiarios;
               END IF;
            END IF;
         END LOOP;
      END IF;

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
   END f_traspasar_especifico;

   /*************************************************************************
   Marca el producto correspondiente al seguro especificado
   param in psseguro   : Codigo sseguro
   param in pccompani  : Codigo compania
   param in pmarcar    : Marca
   param in pmodo      : Modo
   param out mensajes  : Mensajes
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_marcar_compania(
      psseguro IN NUMBER,
      pccompani IN NUMBER,
      psproduc IN NUMBER,
      pmarcar IN NUMBER,
      piddoc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parÃ¡metros - psseguro: ' || psseguro || ' - pccompani: ' || pccompani
            || ' - pmarcar: ' || pmarcar;
      vobject        VARCHAR2(200) := 'PAC_MD_PROD_GENERICOS.f_marcar_compaÃ±ia';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_prod_genericos.f_marcar_compania(psseguro, pccompani, psproduc, pmarcar,
                                                      piddoc);

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
   END f_marcar_compania;
END pac_md_prod_genericos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROD_GENERICOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROD_GENERICOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROD_GENERICOS" TO "PROGRAMADORESCSI";
