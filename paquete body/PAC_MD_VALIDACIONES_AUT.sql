--------------------------------------------------------
--  DDL for Package Body PAC_MD_VALIDACIONES_AUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_VALIDACIONES_AUT" AS
/******************************************************************************
   NOMBRE:       PAC_MD_VALIDACIONES_AUT
   PROPÓSITO:  Funciones para validar autos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        24/02/2009  XVM                 1. Creación del package.
   2.0        07/01/2013  MDS                 2. 0025458: LCOL_T031-LCOL - AUT - (ID 279) Tipos de placa (matr?cula)
   3.0        14/02/2013  JDS                 3. 0025964: LCOL - AUT - Experiencia

   BUG 9247-24022009-XVM
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
   FUNCTION F_valida_RieAuto
      Funció que valida una série d'aspectes d'un risc.
      param in pauto        : objecte d'autos
      param in out mensajes : missatges d'error
      return                : 1 -> Tot correcte
                              0 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_rieauto(pauto IN ob_iax_autriesgos, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - :';
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AUT.f_valida_rieauto';
      vnumerr        NUMBER(10);
   BEGIN
      vpasexec := 11;
      vparam := 'parámetros - :' || pauto.sseguro || ' - ' || pauto.nriesgo || ' - '
                || pauto.cversion || ' - ' || pauto.cmodelo || ' - ' || pauto.cmarca || ' - '
                || pauto.ctipveh || ' - ' || pauto.cclaveh || ' - ' || pauto.cmatric || ' - '
                || pauto.ctipmat || ' - ' || pauto.cuso || ' - ' || pauto.csubuso || ' - '
                || pauto.fmatric || ' - ' || pauto.nkilometros || ' - ' || pauto.ivehicu
                || ' - ' || pauto.npma || ' - ' || pauto.ntara || ' - ' || pauto.npuertas
                || ' - ' || pauto.nplazas || ' - ' || pauto.cmotor || ' - ' || pauto.cgaraje
                || ' - ' || pauto.cvehb7 || ' - ' || pauto.cusorem || ' - ' || pauto.cremolque
                || ' - ' || pauto.ccolor || ' - ' || pauto.cvehnue || ' - ' || pauto.nbastid
                || ' - ' || pauto.cchasis || ' - ' || pauto.codmotor;
      vpasexec := 2;

      -- Valida el tipo de matrícula
      IF pauto.ctipmat IS NULL THEN
         vnumerr := 9001001;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN vnumerr;
      END IF;

      vpasexec := 3;

      -- Si el tipo de matricula es diferente del tipo 2 (sin matricula) hacemos la validación de la matrícula
      IF pauto.ctipmat <> 2 THEN
         IF pauto.cmatric IS NULL THEN
            vnumerr := 9000993;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RETURN vnumerr;
         END IF;
      END IF;

      vpasexec := 4;

      -- Valida la versión del vehículo
      IF pauto.cversion IS NULL THEN
         vnumerr := 9000997;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN vnumerr;
      END IF;

      vpasexec := 5;

      -- Valida el tipo de vehículo
      IF pauto.ctipveh IS NULL THEN
         vnumerr := 9000994;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN vnumerr;
      END IF;

      vpasexec := 6;

      IF pauto IS NOT NULL THEN
         -- Valida información del vehículo
         vnumerr := pac_md_autos.f_valida_rieauto(pauto.sseguro, pauto.nriesgo,
                                                  pauto.cversion, pauto.cmodelo, pauto.cmarca,
                                                  pauto.ctipveh, pauto.cclaveh, pauto.cmatric,
                                                  pauto.ctipmat, pauto.cuso, pauto.csubuso,
                                                  pauto.fmatric, pauto.nkilometros,
                                                  pauto.ivehicu, pauto.npma, pauto.ntara,
                                                  pauto.npuertas, pauto.nplazas, pauto.cmotor,
                                                  pauto.cgaraje, pauto.cvehb7, pauto.cusorem,
                                                  pauto.cremolque, pauto.ccolor,
                                                  pauto.cvehnue, pauto.nbastid, pauto.cchasis,
                                                  pauto.codmotor, pauto.anyo, mensajes);
         vpasexec := 7;

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;

         vpasexec := 8;
      END IF;

      vpasexec := 9;
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
   END f_valida_rieauto;

   /*************************************************************************
   FUNCTION f_validaconductores
      Funció que valida un conductor.
      param in pauto        : objecte d'autos
      param in out mensajes : missatges d'error
      return                : 1 -> Tot correcte
                              0 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_validaconductores(pautos IN ob_iax_autriesgos, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - :';
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AUT.f_validaconductores';
      vnumerr        NUMBER(10);
      vcontador      NUMBER := 0;
      vcentinela     VARCHAR2(1) := 'N';
      cond           t_iax_autconductores;
   BEGIN
      cond := pac_iobj_prod.f_partautconductores(pautos, mensajes);

      FOR vcond IN cond.FIRST .. cond.LAST LOOP
         IF cond.EXISTS(vcond) THEN
            --hem de mirar que només hi hagi un  conductor habitual
            vpasexec := 2;

            IF (cond(vcond).norden) = 0 THEN
               vcontador := vcontador + 1;
            END IF;
         END IF;
      END LOOP;

      IF vcontador != 1 THEN   --hi ha algun conductor habitual
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001008);
         RETURN 9001008;
      END IF;

      FOR vcond IN cond.FIRST .. cond.LAST LOOP
         IF cond.EXISTS(vcond) THEN
            vpasexec := 3;

            IF (cond(vcond).norden) = 0 THEN
               vnumerr := f_validaconductornominado(cond(vcond).nriesgo, cond(vcond).norden,
                                                    cond(vcond).persona.ctipper,
                                                    cond(vcond).persona.fnacimi,
                                                    cond(vcond).fcarnet,
                                                    cond(vcond).persona.csexper,
                                                    cond(vcond).npuntos,
                                                    cond(vcond).exper_manual,
                                                    cond(vcond).exper_cexper, mensajes);

               IF vnumerr <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                  RETURN vnumerr;
               END IF;
            ELSE
               IF (cond(vcond).sperson) IS NULL THEN   --conductor innominat
                  vpasexec := 4;
                  vnumerr := f_validaconductorinnominado(cond(vcond).nriesgo,
                                                         cond(vcond).norden,
                                                         cond(vcond).fnacimi,
                                                         cond(vcond).fcarnet,
                                                         cond(vcond).csexo,
                                                         cond(vcond).npuntos,
                                                         cond(vcond).exper_manual,
                                                         cond(vcond).exper_cexper, mensajes);

                  IF vnumerr <> 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                     RETURN vnumerr;
                  END IF;
               ELSE   -- conductor nominat
                  vpasexec := 5;
                  vnumerr := f_validaconductornominado(cond(vcond).nriesgo,
                                                       cond(vcond).norden,
                                                       cond(vcond).persona.ctipper,
                                                       cond(vcond).persona.fnacimi,
                                                       cond(vcond).fcarnet,
                                                       cond(vcond).persona.csexper,
                                                       cond(vcond).npuntos,
                                                       cond(vcond).exper_manual,
                                                       cond(vcond).exper_cexper, mensajes);

                  IF vnumerr <> 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                     RETURN vnumerr;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

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
   END f_validaconductores;

   /*************************************************************************
   FUNCTION f_validaConductorInnominado
      Funció que valida els camps perque sigui un conductor innominat correcte
      param in pnriesgo : número risc
      param in pnorden  : número ordre
      param in pfnacimi   : edat
      param in pfcarnet : data carnet
      param in pcsexo   : sexe
      param in pnpuntos : número de punts
      param in pexper_manual : Numero de años de experiencia del conductor.
      param in pexper_cexper : Numero de años de experiencia que viene por interfaz.
      param in out mensajes : missatges d'error
      return                : 1 -> Tot correcte
                              0 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_validaconductorinnominado(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      pfnacimi IN DATE,
      pfcarnet IN DATE,
      pcsexo IN NUMBER,
      pnpuntos IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - : pnriesgo' || pnriesgo || ' - pnorden:' || pnorden
            || ' - pfnacimi:' || pfnacimi || ' - pfcarnet:' || pfcarnet || ' - pcsexo:'
            || pcsexo || ' - pexper_manual:' || pexper_manual || ' - pexper_cexper:'
            || pexper_cexper;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AUT.f_validaconductorinnominado';
      vnumerr        NUMBER(10);
   BEGIN
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                           'VALIDADATOSINNOMINAD'),
             0) = 0 THEN
         IF pfnacimi IS NULL THEN
            vnumerr := 9001009;   --Edat no informada
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RETURN vnumerr;
         END IF;

         /*  IF pfcarnet IS NULL THEN
              vnumerr := 9001010;   --Error validacions conductor innominat
              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
              RETURN vnumerr;
           END IF;*/
         IF pcsexo IS NULL THEN
            vnumerr := 9000771;   --Ha d'informar del sexe de la persona
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RETURN vnumerr;
         END IF;
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
   END f_validaconductorinnominado;

   /*************************************************************************
   FUNCTION f_validaConductorNominado
      Funció que valida els camps perque sigui un conductor nominat correcte
      param in pnriesgo : número risc
      param in pnorden  : número ordre
      param in pfnacimi   : edat
      param in pfcarnet : data carnet
      param in pcsexo   : sexe
      param in pnpuntos : número de punts
      param in pexper_manual : Numero de años de experiencia del conductor.
      param in pexper_cexper : Numero de años de experiencia que viene por interfaz.
      param in pcond        : objecte d'conductor
      return                : 1 -> Tot correcte
                              0 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_validaconductornominado(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      pctipper IN NUMBER,
      pfnacimi IN DATE,
      pfcarnet IN DATE,
      pcsexo IN NUMBER,
      pnpuntos IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - : pnriesgo' || pnriesgo || ' - pnorden:' || pnorden
            || ' - pfnacimi:' || pfnacimi || ' - pfcarnet:' || pfcarnet || ' - pcsexo:'
            || pcsexo || '-  pnppuntos: ' || pnpuntos || ' - pexper_manual:' || pexper_manual
            || ' - pexper_cexper:' || pexper_cexper;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AUT.f_validaconductorinnominado';
      vnumerr        NUMBER(10);
   BEGIN
      -- Quizas deberíamos validar que no fuera una persona jurídica!!!
      IF pctipper = 2 THEN
         --RETURN 9001313;   -- El conductor no puede ser una persona jurídica
         vnumerr := 9001313;   --Edat no informada
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN vnumerr;
      END IF;

      IF pfnacimi IS NULL THEN
         -- RETURN 9001009;   --Edat no informada
         vnumerr := 9001009;   --Edat no informada
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN vnumerr;
      END IF;

      IF pcsexo IS NULL THEN
         -- -RETURN 9000771;   --Ha d'informar del sexe de la persona
         vnumerr := 9000771;   --Edat no informada
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN vnumerr;
      END IF;

         /*   IF pfcarnet IS NULL THEN
               --RETURN 9001010;   --Error validacions conductor innominat
               vnumerr := 9001010;   --Edat no informada
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RETURN vnumerr;
            END IF;
      */
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 9001011;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 9001011;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 9001011;
   END f_validaconductornominado;
END pac_md_validaciones_aut;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AUT" TO "PROGRAMADORESCSI";
