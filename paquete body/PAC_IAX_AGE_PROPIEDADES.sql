--------------------------------------------------------
--  DDL for Package Body PAC_IAX_AGE_PROPIEDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_AGE_PROPIEDADES" IS
   /******************************************************************************
        NOMBRE:       PAC_IAX_AGE_PROPIEDADES
        PROPOSITO: Funciones para gestionar los parametros de los agentes

        REVISIONES:
        Ver        Fecha        Autor             Descripción
        ---------  ----------  ---------------  ------------------------------------
        1.0        08/03/2012  AMC               1. Creaci�n del package.

     ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

    /*************************************************************************
        Inserta el parametre per agent
        param in pcagente   : Codi agent
        param in pcparam    : Codi parametre
        param in pnvalpar   : Resposta numerica
        param in ptvalpar   : Resposta text
        param in pfvalpar   : Resposta data
        return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_paragente(
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - pcagente: ' || pcagente || ' - pcparam: ' || pcparam
            || ' - pnvalpar: ' || pnvalpar || ' - ptvalpar: ' || ptvalpar || ' - pfvalpar: '
            || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_PROPIEDADES.f_ins_paragente';
   BEGIN
      IF pcagente IS NULL
         OR pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_propiedades.f_ins_paragente(pcagente, pcparam, pnvalpar, ptvalpar,
                                                        pfvalpar, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_ins_paragente;

   /*************************************************************************
        Inserta el parametre per agente
        param in pcagente   : Codi agent
        return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_grabar_paragente(pcagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_PROPIEDADES.F_GRABAR_PARAGENTE';
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF paragentes IS NOT NULL
         AND paragentes.COUNT > 0 THEN
         FOR i IN paragentes.FIRST .. paragentes.LAST LOOP
            IF paragentes(i).nvalpar IS NOT NULL
               OR paragentes(i).tvalpar IS NOT NULL
               OR paragentes(i).fvalpar IS NOT NULL THEN
               vnumerr := pac_md_age_propiedades.f_ins_paragente(pcagente,
                                                                 paragentes(i).cparam,
                                                                 paragentes(i).nvalpar,
                                                                 paragentes(i).tvalpar,
                                                                 paragentes(i).fvalpar,
                                                                 mensajes);

               IF vnumerr <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      END IF;

      paragentes := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_grabar_paragente;

   /*************************************************************************
        Esborra el parametre per agent
        param in pcagente   : Codi agent
        param in pcparam    : Codi parametre
        return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_paragente(
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parametros - pcagente: ' || pcagente || ' - pcparam: ' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_PROPIEDADES.F_Del_Paragente';
   BEGIN
      IF pcagente IS NULL
         OR pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_propiedades.f_del_paragente(pcagente, pcparam, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_paragente;

    /*************************************************************************
   Obté la select amb els parametres per agente
   param in pcagente   : Codi agent
   param in ptots      : 0.- Només retorna els paràmetres contestats
                         1.- Retorna tots els paràmetres
   param out pcur      : Cursor
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_paragente_ob(
      pcagente IN NUMBER,
      ptots IN NUMBER,
      pparage OUT t_iax_par_agentes,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      pcur           sys_refcursor;
      vparam         VARCHAR2(500)
                             := 'parametros - pcagente: ' || pcagente || ' - ptots: ' || ptots;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_PROPIEDADES.f_get_paragente_ob';
      squery         VARCHAR2(5000);
      obparagente    ob_iax_par_agentes := ob_iax_par_agentes();
      pparage2       t_iax_par_agentes;
      visibles       BOOLEAN := TRUE;
   BEGIN
      IF ptots IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF (paragentes IS NULL
          OR paragentes.COUNT = 0)
         OR ptots = 1 THEN
         IF pcagente IS NOT NULL THEN
            vnumerr := pac_md_age_propiedades.f_get_paragente(pcagente, ptots, pcur, mensajes);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;

            pparage2 := paragentes;
            paragentes := t_iax_par_agentes();
            obparagente := ob_iax_par_agentes();

            LOOP
               FETCH pcur
                INTO obparagente.cutili, obparagente.cparam, obparagente.ctipo,
                     obparagente.tparam, obparagente.cvisible, obparagente.tvalpar,
                     obparagente.nvalpar, obparagente.fvalpar, obparagente.resp;

               EXIT WHEN pcur%NOTFOUND;

               IF obparagente.cvisible IS NOT NULL THEN
                  vnumerr := pac_md_age_propiedades.f_get_compvisible(pcagente,
                                                                      obparagente.cvisible,
                                                                      mensajes);

                  IF vnumerr = 1 THEN
                     visibles := TRUE;
                  ELSE
                     visibles := FALSE;
                  END IF;
               ELSE
                  visibles := TRUE;
               END IF;

               IF visibles THEN
                  paragentes.EXTEND;
                  paragentes(paragentes.LAST) := obparagente;
                  obparagente := ob_iax_par_agentes();
               END IF;
            END LOOP;
         /*   IF pparage2 IS NOT NULL
               AND pparage2.COUNT > 0
               AND paragentes IS NOT NULL
               AND paragentes.COUNT > 0 THEN
               FOR j IN paragentes.FIRST .. paragentes.LAST LOOP
                  FOR i IN pparage2.FIRST .. pparage2.LAST LOOP
                     IF paragentes(j).cparam = pparage2(i).cparam THEN
                        paragentes(j).tvalpar := pparage2(i).tvalpar;
                        paragentes(j).nvalpar := pparage2(i).nvalpar;
                        paragentes(j).fvalpar := pparage2(i).fvalpar;

                        IF pparage2(i).nvalpar IS NOT NULL THEN
                           SELECT det.tvalpar
                             INTO paragentes(j).resp
                             FROM detparam det
                            WHERE det.cparam = paragentes(j).cparam
                              AND det.cidioma = pac_md_common.f_get_cxtidioma
                              AND det.cvalpar = pparage2(i).nvalpar;
                        END IF;
                     END IF;
                  END LOOP;
               END LOOP;
            END IF;*/
         END IF;
      END IF;

      --pparper := parpersonas;
      IF ptots = 0 THEN
         IF paragentes IS NOT NULL
            AND paragentes.COUNT > 0 THEN
            pparage := t_iax_par_agentes();

            FOR i IN paragentes.FIRST .. paragentes.LAST LOOP
               IF paragentes(i).nvalpar IS NOT NULL
                  OR paragentes(i).tvalpar IS NOT NULL
                  OR paragentes(i).fvalpar IS NOT NULL THEN
                  pparage.EXTEND;
                  pparage(pparage.LAST) := paragentes(i);
               END IF;
            END LOOP;
         END IF;
      ELSE
         pparage := paragentes;
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
   END f_get_paragente_ob;

   /*************************************************************************
     Obté la select amb els paràmetres per agente
     param in pcagente   : Codi agent
     param in ptots      : 0.- Només retorna els paràmetres contestats
                           1.- Retorna tots els paràmetres
     param out pcur      : Cursor
     return              : 0.- OK, 1.- KO
     *************************************************************************/
   FUNCTION f_get_paragente(
      pcagente IN NUMBER,
      ptots IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                             := 'parametros - pcagente: ' || pcagente || ' - ptots: ' || ptots;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_PROPIEDADES.f_get_paragente';
      squery         VARCHAR2(5000);
   BEGIN
      IF pcagente IS NULL
         OR ptots IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_propiedades.f_get_paragente(pcagente, ptots, pcur, mensajes);

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
   END f_get_paragente;
END pac_iax_age_propiedades;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_PROPIEDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_PROPIEDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_PROPIEDADES" TO "PROGRAMADORESCSI";
