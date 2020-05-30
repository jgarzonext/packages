--------------------------------------------------------
--  DDL for Package Body PAC_CALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CALL" AS
   /******************************************************************************
    NOMBRE:      pac_iax_ws_supl
    PROPÓSITO:   Interficie para cada tipo de suplemento en la capa de negocio

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        28/07/2009   JRH                1. Creación del package. Bug 10776 reducción total
    2.0        15/09/2010   JRH                2. 0012278: Proceso de PB para el producto PEA.
    3.0        07/09/2011   JMF                3. 0018967 LCOL_T005 - Listas restringidas validaciones y controles
    4.0        19/10/2011   RSC                4. 0019412: LCOL_T004: Completar parametrización de los productos de Vida Individual
    5.0        16/01/2012   APD                5. 0020671: LCOL_T001-LCOL - UAT - TEC: Contratacion
    6.0        28/06/2012   FAL                6.0021905: MDP - TEC - Parametrización de productos del ramo de Accidentes - Nueva producción
    7.0        22/01/2013   JMF                0025815: LCOL: Cambios para Retorno seg?n reuni?n con Comercial
    8.0        25/02/2013   DCT                8. 0025965  0025965: LCOL - AUT - Listas Restringidas para placas
    9.0        07/05/2014   ECP                9. 31204/0012459: Error en beneficiarios al duplicar Solicitudes
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Realiza la reducción total de una póliza
      param in psseguro   : Número de seguro
      param in pfefecto   : Fecha del suplemento (puede ser nula, si es asi pondremos la del ultimo suplemento)
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_reduccion_total(psseguro IN NUMBER, pfefecto IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vestsseguro    estseguros.sseguro%TYPE;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
                 := 'psseguro=' || psseguro || ' pfefecto=' || TO_CHAR(pfefecto, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'pac_call.f_reduccion_total';
      vfefecto       DATE;
      vmodfefe       NUMBER;
      vcmotmov       NUMBER;
      v_npoliza      NUMBER;
      v_ncertif      NUMBER;
      v_nsuplem      NUMBER;
      v_efecpol      DATE;
      v_efesupl      DATE;
      mensajes       t_iax_mensajes;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfefecto IS NULL THEN
         vnumerr := f_buscapoliza(psseguro, v_npoliza, v_ncertif);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 2;
         vnumerr := f_ultsupl(v_npoliza, v_ncertif, v_nsuplem, v_efecpol, v_efesupl);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 3;
         vfefecto := v_efesupl;
      ELSE
         vfefecto := pfefecto;
      END IF;

      vnumerr := pac_iax_ws_supl.f_reduccion_total(psseguro, TRUNC(vfefecto), mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros Incorrectos');
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'e_object_error');

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               FOR i IN 1 .. mensajes.COUNT LOOP
                  IF mensajes.EXISTS(i) THEN
                     p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                                 mensajes(i).terror);
                  END IF;
               END LOOP;
            END IF;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               FOR i IN 1 .. mensajes.COUNT LOOP
                  IF mensajes.EXISTS(i) THEN
                     p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                                 mensajes(i).terror);
                  END IF;
               END LOOP;
            END IF;
         END IF;
   END f_reduccion_total;

   /*************************************************************************
      F_APERTURA_SINIESTRO
      Función que sirve para aperturar un siniestro con su tramitación y reserva inicial pendiente.
        1.  PSPRODUC: Tipo numérico. Parámetro de entrada. Identificador del producto
        2.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        3.  PNRIESGO: Tipo numérico. Parámetro de entrada. Número de riesgo.
        4.  PCACTIVI: Tipo numérico. Parámetro de entrada. Identificador de activivad.
        5.  PFSINIES: Tipo Fecha. Parámetro de etnrada. Fecha de siniestro. Desde traspasos se llamará con la fecha de efecto del traspaso
        6.  PFNOTIFI: Tipo Fecha. Parámetro de entrada. Fecha de notificación del siniestro. Desde traspasos se llamará con la fecha de aceptación del traspaso.
        7.  PCCAUSIN:Tipo numérico. Parámetro de entrada. Código de causa del siniestro
        8.  PCMOTSIN:  Tipo numérico. Parámetro de entrada. Código de motivo del siniestro
        9.  PTSINIES: Tipo carácter. Parámetro de entrada.
        10. PTZONAOCU: Tipo carácter. Parámetro de entrada.
        11. PCGARANT: Tipo numérico. Parámetro de entrada. Garantía asignada al traspaso
        12. PITRASPASO: Tipo numérico. Parámetro de entrada. Importe del traspaso.

        Retorna un valor numérico: 0 si se ha aperturado el siniestro y un código de error correspondiente si ha habido un error.
   *************************************************************************/
   FUNCTION f_apertura_siniestro(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcactivi IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      ptsinies IN VARCHAR2,
      ptzonaocu IN VARCHAR2,
      pcgarant IN NUMBER,
      pitraspaso IN NUMBER,
      pnsinies IN OUT NUMBER)
      RETURN NUMBER IS
      mensajes       t_iax_mensajes;
      vnumerr        NUMBER := 0;
      vestsseguro    estseguros.sseguro%TYPE;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'pac_call.f_apertura_siniestro';
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_iax_ws_siniestros.f_apertura_siniestro(psproduc, psseguro, pnriesgo,
                                                            pcactivi, pfsinies, pfsinies,
                                                            pccausin, pcmotsin, ptsinies,
                                                            ptzonaocu, pcgarant, pitraspaso,
                                                            pnsinies, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros Incorrectos');
         RETURN 1;
   END f_apertura_siniestro;

   FUNCTION f_pago_i_cierre_sin(
      pnsinies IN NUMBER,
      xproduc IN NUMBER,
      xcactivi IN NUMBER,
      psidepag IN NUMBER)
      RETURN NUMBER IS
      mensajes       t_iax_mensajes;
      vnumerr        NUMBER := 0;
      vestsseguro    estseguros.sseguro%TYPE;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnsinies=' || pnsinies || ' psidepag:' || psidepag;
      vobject        VARCHAR2(200) := 'pac_call.f_pago_i_cierre_sin';
   BEGIN
      IF pnsinies IS NULL
         OR psidepag IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_iax_ws_siniestros.f_pago_i_cierre_sin(pnsinies, xproduc, xcactivi,
                                                           psidepag, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros Incorrectos');
         RETURN 1;
   END f_pago_i_cierre_sin;

   -- BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.

   /*************************************************************************
      f_suplemento_garant
      Realiza un suplemento asociado a garnatía (PB, Aport ext.,..)
      param in psseguro   : Número de seguro
      param in pnriesgo   : Riesgo
      param in pfecha   : Fecha del suplemento
      param in pimporte   : Importe
      param in pctipban   : Tipo banc.
      param in pcbancar   : Cuenta
      param in pcgarant   : Garantía asociada al suplemento
      param out           : pnmovimi
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_suplemento_garant(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'psseguro=' || psseguro || ' pfecha=' || TO_CHAR(pfecha, 'DD/MM/YYYY')
            || 'pnriesgo=' || pnriesgo || ' pimporte=' || pimporte || 'pctipban=' || pctipban
            || ' pcbancar=' || pcbancar || 'pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'pac_call.f_suplemento_garant';
      mensajes       t_iax_mensajes;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_iax_ws_supl.f_suplemento_garant(psseguro, pnriesgo, pfecha, pimporte,
                                                     pctipban, pcbancar, pcgarant, pnmovimi,
                                                     mensajes);
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
   END f_suplemento_garant;

-- Fi BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.

   /*************************************************************************
      f_datos_tomador
      Obtener algunos datos del tomador del objeto
      pnregistro in number: Numero de registro que queremos obtener
      psperson out number:  secuencia persona
      pctipper out number: tipo de persona
      pctipide out number: tipo identificacion
      pnnumide out varchar2: numero identificacion
      ptapelli1 out varchar2: primer apellido
      ptapelli2 out varchar2: segundo apellido
      ptnombre1 out varchar2: primer nombre
      ptnombre2 out varchar2: segundo nombre
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 0018967 - 07/09/2011 - JMF
   FUNCTION f_datos_tomador(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pctipper OUT NUMBER,
      pctipide OUT NUMBER,
      pnnumide OUT VARCHAR2,
      ptapelli1 OUT VARCHAR2,
      ptapelli2 OUT VARCHAR2,
      ptnombre1 OUT VARCHAR2,
      ptnombre2 OUT VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_datos_tomador';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnregistro=' || pnregistro;
   BEGIN
      vpasexec := 100;
      psperson := NULL;
      pctipper := NULL;
      pctipide := NULL;
      pnnumide := NULL;
      ptapelli1 := NULL;
      ptapelli2 := NULL;
      ptnombre1 := NULL;
      ptnombre2 := NULL;
      vpasexec := 110;

      IF pac_iax_produccion.poliza.det_poliza.tomadores IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.tomadores.COUNT > 0 THEN
         vpasexec := 120;

         FOR i IN
            pac_iax_produccion.poliza.det_poliza.tomadores.FIRST .. pac_iax_produccion.poliza.det_poliza.tomadores.LAST LOOP
            vpasexec := 130;

            IF i = pnregistro THEN
               vpasexec := 140;
               psperson := pac_iax_produccion.poliza.det_poliza.tomadores(i).sperson;
               vpasexec := 145;
               pctipper := pac_iax_produccion.poliza.det_poliza.tomadores(i).ctipper;
               vpasexec := 150;
               pctipide := pac_iax_produccion.poliza.det_poliza.tomadores(i).ctipide;
               vpasexec := 155;
               pnnumide := pac_iax_produccion.poliza.det_poliza.tomadores(i).nnumide;
               vpasexec := 160;
               ptapelli1 := pac_iax_produccion.poliza.det_poliza.tomadores(i).tapelli1;
               vpasexec := 165;
               ptapelli2 := pac_iax_produccion.poliza.det_poliza.tomadores(i).tapelli2;
               vpasexec := 170;
               ptnombre1 := pac_iax_produccion.poliza.det_poliza.tomadores(i).tnombre1;
               vpasexec := 175;
               ptnombre2 := pac_iax_produccion.poliza.det_poliza.tomadores(i).tnombre2;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         psperson := NULL;
         RETURN 1;
   END f_datos_tomador;

   /*************************************************************************
      f_datos_asegurado
      Obtener algunos datos del asegurado del objeto
      pnregistro in number: Numero de registro que queremos obtener
      psperson out number:  secuencia persona
      pctipper out number: tipo de persona
      pctipide out number: tipo identificacion
      pnnumide out varchar2: numero identificacion
      ptapelli1 out varchar2: primer apellido
      ptapelli2 out varchar2: segundo apellido
      ptnombre1 out varchar2: primer nombre
      ptnombre2 out varchar2: segundo nombre
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 0018967 - 07/09/2011 - JMF
   FUNCTION f_datos_asegurado(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pctipper OUT NUMBER,
      pctipide OUT NUMBER,
      pnnumide OUT VARCHAR2,
      ptapelli1 OUT VARCHAR2,
      ptapelli2 OUT VARCHAR2,
      ptnombre1 OUT VARCHAR2,
      ptnombre2 OUT VARCHAR2,
      pcsexper OUT NUMBER)   -- BUG 21905 - FAL - 27/06/2012
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_datos_asegurado';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnregistro=' || pnregistro;
   BEGIN
      vpasexec := 100;
      psperson := NULL;
      pctipper := NULL;
      pctipide := NULL;
      pnnumide := NULL;
      ptapelli1 := NULL;
      ptapelli2 := NULL;
      ptnombre1 := NULL;
      ptnombre2 := NULL;
      vpasexec := 110;

      IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
         FOR j IN
            pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
            IF j = pnregistro THEN
               IF pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase IS NOT NULL
                  AND pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase.COUNT > 0 THEN
                  vpasexec := 120;

                  FOR i IN
                     pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                            (j).riesgoase.LAST LOOP
                     vpasexec := 140;
                     psperson :=
                          pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).sperson;
                     vpasexec := 145;
                     pctipper :=
                          pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).ctipper;
                     vpasexec := 150;
                     pctipide :=
                          pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).ctipide;
                     vpasexec := 155;
                     pnnumide :=
                          pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).nnumide;
                     vpasexec := 160;
                     ptapelli1 :=
                         pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).tapelli1;
                     vpasexec := 165;
                     ptapelli2 :=
                         pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).tapelli2;
                     vpasexec := 170;
                     ptnombre1 :=
                         pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).tnombre1;
                     vpasexec := 175;
                     ptnombre2 :=
                         pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).tnombre2;
                     -- BUG 21905 - FAL - 27/06/2012
                     vpasexec := 180;
                     pcsexper :=
                          pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).csexper;
                  -- FI BUG 21905
                  END LOOP;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         psperson := NULL;
         RETURN 1;
   END f_datos_asegurado;

   -- Bug 19412/95066 - RSC - 19/10/2011
   FUNCTION f_get_persona_tomador(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pcpais OUT NUMBER,
      pnacionalidad OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_datos_tomador';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnregistro=' || pnregistro;
      v_conta        NUMBER;
      v_ctipper      estper_personas.ctipper%TYPE;
   BEGIN
      vpasexec := 100;
      psperson := NULL;
      pcpais := NULL;
      pnacionalidad := 0;
      vpasexec := 110;

      IF pac_iax_produccion.poliza.det_poliza.tomadores IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.tomadores.COUNT > 0 THEN
         vpasexec := 120;

         FOR i IN
            pac_iax_produccion.poliza.det_poliza.tomadores.FIRST .. pac_iax_produccion.poliza.det_poliza.tomadores.LAST LOOP
            vpasexec := 130;

            IF i = pnregistro THEN
               vpasexec := 140;
               psperson := pac_iax_produccion.poliza.det_poliza.tomadores(i).sperson;
               vpasexec := 141;
               pcpais := pac_iax_produccion.poliza.det_poliza.tomadores(i).cpais;

               SELECT ctipper
                 INTO v_ctipper
                 FROM estper_personas
                WHERE sperson = psperson;

               IF v_ctipper = 2 THEN
                  pnacionalidad := 1;
               ELSE
                  SELECT COUNT(*)
                    INTO v_conta
                    FROM estper_nacionalidades
                   WHERE sperson = psperson;

                  IF v_conta > 0 THEN
                     pnacionalidad := 1;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         psperson := NULL;
         RETURN 1;
   END f_get_persona_tomador;

   FUNCTION f_get_persona_asegurado(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pcpais OUT NUMBER,
      pnacionalidad OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_datos_asegurado';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnregistro=' || pnregistro;
      v_conta        NUMBER;
      v_ctipper      estper_personas.ctipper%TYPE;
   BEGIN
      vpasexec := 100;
      psperson := NULL;
      pcpais := NULL;
      pnacionalidad := 0;
      vpasexec := 110;

      IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
         FOR j IN
            pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
            IF j = pnregistro THEN
               IF pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase IS NOT NULL
                  AND pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase.COUNT > 0 THEN
                  vpasexec := 120;

                  FOR i IN
                     pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                            (j).riesgoase.LAST LOOP
                     vpasexec := 140;
                     psperson :=
                          pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).sperson;
                     vpasexec := 141;
                     pcpais :=
                            pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).cpais;

                     SELECT ctipper
                       INTO v_ctipper
                       FROM estper_personas
                      WHERE sperson = psperson;

                     IF v_ctipper = 2 THEN
                        pnacionalidad := 1;
                     ELSE
                        SELECT COUNT(*)
                          INTO v_conta
                          FROM estper_nacionalidades
                         WHERE sperson = psperson;

                        IF v_conta > 0 THEN
                           pnacionalidad := 1;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         psperson := NULL;
         RETURN 1;
   END f_get_persona_asegurado;

   FUNCTION f_valida_beneficiario(pnriesgo IN NUMBER, pvalida OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_valida_beneficiario';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := '';
      v_conta        NUMBER := 0;
   BEGIN
      IF pac_iax_produccion.poliza.det_poliza IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
         --Bug 31686/179430 - 15/07/2014 - AMC
         FOR j IN
            pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
            IF pac_iax_produccion.poliza.det_poliza.riesgos(j) IS NOT NULL
               AND pac_iax_produccion.poliza.det_poliza.riesgos(j).nriesgo = pnriesgo THEN
               IF pac_iax_produccion.poliza.det_poliza.riesgos(j).beneficiario IS NOT NULL THEN
                  IF pac_iax_produccion.poliza.det_poliza.riesgos(j).beneficiario.benefesp IS NOT NULL
                     AND pac_iax_produccion.poliza.det_poliza.riesgos(j).beneficiario.benefesp.benef_riesgo IS NOT NULL
                     AND pac_iax_produccion.poliza.det_poliza.riesgos(j).beneficiario.benefesp.benef_riesgo.COUNT >
                                                                                              0 THEN
                     vpasexec := 2;
                     v_conta := v_conta + 1;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         IF v_conta = 0 THEN
            pvalida := v_conta;
            RETURN 0;
         END IF;

         FOR j IN
            pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
            IF pac_iax_produccion.poliza.det_poliza.riesgos(j) IS NOT NULL
               AND pac_iax_produccion.poliza.det_poliza.riesgos(j).nriesgo = pnriesgo THEN
               IF pac_iax_produccion.poliza.det_poliza.riesgos(j).beneficiario IS NOT NULL THEN
                  --  Ini  31204/0012459 -- ECP -- 07/05/2014
                  IF pac_iax_produccion.poliza.det_poliza.riesgos(j).beneficiario.benefesp IS NOT NULL
                     AND pac_iax_produccion.poliza.det_poliza.riesgos(j).beneficiario.benefesp.benefesp_gar IS NOT NULL
                     AND pac_iax_produccion.poliza.det_poliza.riesgos(j).beneficiario.benefesp.benefesp_gar.COUNT >
                                                                                              0 THEN
                     vpasexec := 3;
                     v_conta := v_conta + 1;
                  END IF;
               --  Fin  31204/0012459 -- ECP -- 07/05/2014
               END IF;
            END IF;
         END LOOP;
      --Fi Bug 31686/179430 - 15/07/2014 - AMC
      END IF;

      pvalida := v_conta;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_valida_beneficiario;

   /*************************************************************************
      f_get_preguntas
      Obtener las preguntas de poliza del objeto
      pnregistro in number: Numero de registro que queremos obtener
      pcpregun in out number: codigo de la pregunta
      pcrespue out number: respuesta de la pregunta
     pexistepreg out number: indica si existe o no la pregunta (0.-No existe, 1.-Si existe)
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 20671 - 16/01/2012 - APD
   FUNCTION f_get_preguntas(
      pnregistro IN NUMBER,
      pcpregun IN OUT NUMBER,
      pcrespue OUT NUMBER,
      ptrespue OUT VARCHAR2,
      pexistepreg OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_get_preguntas';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnregistro=' || pnregistro;
   BEGIN
      vpasexec := 100;
      pcrespue := NULL;
      ptrespue := NULL;
      pexistepreg := 0;   -- Se inicializa la variabla a 0.-No existe la pregunta
      vpasexec := 110;

      IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0 THEN
         vpasexec := 120;

         FOR i IN
            pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST LOOP
            vpasexec := 130;

            --IF i = pnregistro THEN
            IF pcpregun = pac_iax_produccion.poliza.det_poliza.preguntas(i).cpregun THEN
               --vpasexec := 140;
               --pcpregun := pac_iax_produccion.poliza.det_poliza.preguntas(i).cpregun;
               vpasexec := 150;
               pcrespue := pac_iax_produccion.poliza.det_poliza.preguntas(i).crespue;
               vpasexec := 160;
               ptrespue := pac_iax_produccion.poliza.det_poliza.preguntas(i).trespue;
               vpasexec := 170;
               pexistepreg := 1;   -- 1.-Sí existe la pregunta
               EXIT;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         pcrespue := NULL;
         ptrespue := NULL;
         RETURN 1;
   END f_get_preguntas;

   /*************************************************************************
       f_persona_asegurado
       Obtener algunos datos del asegurado del objeto
       pnregistro in number: Numero de registro que queremos obtener
       psperson out number:  secuencia persona
       pfnacimi out date: fecha de nacimiento
       return              : 0 todo correcto, 1 ha habido un error
    *************************************************************************/                                                                                                                                                                                                                                          -- Bug 20671 - RSC - LCOL_T001-LCOL - UAT - TEC: Contratación
   FUNCTION f_persona_asegurado(pnregistro IN NUMBER, psperson OUT NUMBER, pfnacimi OUT DATE)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_persona_asegurado';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnregistro=' || pnregistro;
   BEGIN
      vpasexec := 100;
      psperson := NULL;
      pfnacimi := NULL;
      vpasexec := 110;

      IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
         FOR j IN
            pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
            IF j = pnregistro THEN
               IF pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase IS NOT NULL
                  AND pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase.COUNT > 0 THEN
                  vpasexec := 120;

                  FOR i IN
                     pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                            (j).riesgoase.LAST LOOP
                     vpasexec := 140;
                     psperson :=
                          pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).sperson;
                     vpasexec := 145;
                     pfnacimi :=
                          pac_iax_produccion.poliza.det_poliza.riesgos(j).riesgoase(i).fnacimi;
                  END LOOP;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         psperson := NULL;
         RETURN 1;
   END f_persona_asegurado;

   FUNCTION f_valor_asegurado_basica(
      pnriesgo IN NUMBER,
      pcgardep IN NUMBER,
      pcpregun IN NUMBER,
      pcvalor OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_valor_asegurado_basica';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'pnriesgo=' || pnriesgo || ' pcgardep = ' || pcgardep || ' pcpregun = '
            || pcpregun;
   BEGIN
      pcvalor := NULL;

      IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
         FOR j IN
            pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
            IF pac_iax_produccion.poliza.det_poliza.riesgos(j).nriesgo = pnriesgo THEN
               IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias IS NOT NULL
                  AND pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.COUNT > 0 THEN
                  FOR i IN
                     pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                            (j).garantias.LAST LOOP
                     IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(i).cgarant =
                                                                                      pcgardep THEN
                        IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(i).preguntas IS NOT NULL
                           AND pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(i).preguntas.COUNT >
                                                                                              0 THEN
                           FOR z IN
                              pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(i).preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                                                (j).garantias
                                                                                                                (i).preguntas.LAST LOOP
                              IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(i).preguntas
                                                                                            (z).cpregun =
                                                                                      pcpregun THEN
                                 pcvalor :=
                                    pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias
                                                                                            (i).preguntas
                                                                                            (z).crespue;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_valor_asegurado_basica;

   /*************************************************************************
      f_datos_tomador
      Obtener algunos datos del seguro del objeto
      pcagente out number: codigo agente
      psproduc out number: secuencia del producto
      pfefecto out date: fecha de efecto
      pnpoliza out number: numero poliza
      pncertif out number: numero certificado
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 0025815 - 22/01/2013 - JMF
   FUNCTION f_datos_seguro(
      pcagente OUT NUMBER,
      psproduc OUT NUMBER,
      pfefecto OUT DATE,
      pnpoliza OUT NUMBER,
      pncertif OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_datos_seguro';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) NULL;
   BEGIN
      vpasexec := 100;
      --
      pcagente := NULL;
      psproduc := NULL;
      pfefecto := NULL;
      pncertif := NULL;
      vpasexec := 110;

      IF pac_iax_produccion.poliza.det_poliza IS NOT NULL THEN
         vpasexec := 120;
         pcagente := pac_iax_produccion.poliza.det_poliza.cagente;
         vpasexec := 130;
         psproduc := pac_iax_produccion.poliza.det_poliza.sproduc;
         vpasexec := 132;
         pnpoliza := pac_iax_produccion.poliza.det_poliza.npoliza;
         vpasexec := 134;
         pncertif := pac_iax_produccion.poliza.det_poliza.ncertif;
         vpasexec := 140;

         IF pac_iax_produccion.poliza.det_poliza.gestion IS NOT NULL THEN
            vpasexec := 150;
            pfefecto := pac_iax_produccion.poliza.det_poliza.gestion.fefecto;
         END IF;
      END IF;

      vpasexec := 160;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_datos_seguro;

   /*************************************************************************
      f_get_pregungaran
      Obtener las preguntas de garantia de poliza del objeto
      pcgarant in number: Garantia a la que pertenece la pregunta
      pcpregun in out number: codigo de la pregunta
      pcrespue out number: respuesta de la pregunta
     pexistepreg out number: indica si existe o no la pregunta (0.-No existe, 1.-Si existe)
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 20671 - 16/01/2012 - APD
   FUNCTION f_get_pregungaran(
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue OUT pregungaranseg.crespue%TYPE,
      ptrespue OUT pregungaranseg.trespue%TYPE)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_get_pregungaran';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
                           := 'pcgarant=' || pcgarant || '-' || 'pcpregun=' || '-' || pcpregun;
      rie            ob_iax_riesgos;
      gar            ob_iax_garantias;
      preg           t_iax_preguntas;
      mensajes       t_iax_mensajes;
      vtippre        NUMBER(3);
   BEGIN
      vpasexec := 1;
      pcrespue := NULL;
      ptrespue := NULL;

      IF pac_iax_produccion.poliza.det_poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      rie := pac_iobj_prod.f_partpolriesgo(pac_iax_produccion.poliza.det_poliza, pnriesgo,
                                           mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 3;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 4;

      IF rie IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001105);
         vpasexec := 5;
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
      gar := pac_iobj_prod.f_partriesgarantia(rie, pcgarant, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 7;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 8;

      IF gar IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001106);
         vpasexec := 9;
         RAISE e_object_error;
      END IF;

      vpasexec := 13;
      preg := gar.preguntas;

      FOR i IN preg.FIRST .. preg.LAST LOOP
         IF preg(i).cpregun = pcpregun THEN
            vtippre := pac_iaxpar_productos.f_get_pregtippre(preg(i).cpregun, mensajes);

            IF vtippre IN(1, 2, 6) THEN
               ptrespue := preg(i).trespue;
            ELSE
               pcrespue := preg(i).crespue;
            END IF;

            RETURN 0;
         END IF;
      END LOOP;

      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         pcrespue := NULL;
         ptrespue := NULL;
         RETURN 1;
   END f_get_pregungaran;

    /*************************************************************************
      f_datos_conductor
      Obtener algunos datos del conductor del objeto
      pnregistro in number: Numero de registro que queremos obtener
      psperson out number:  secuencia persona
      pctipper out number: tipo de persona
      pctipide out number: tipo identificacion
      pnnumide out varchar2: numero identificacion
      ptapelli1 out varchar2: primer apellido
      ptapelli2 out varchar2: segundo apellido
      ptnombre1 out varchar2: primer nombre
      ptnombre2 out varchar2: segundo nombre
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
    -- BUG 0025965- 25/02/2013 - DCT
   FUNCTION f_datos_conductor(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pctipper OUT NUMBER,
      pctipide OUT NUMBER,
      pnnumide OUT VARCHAR2,
      ptapelli1 OUT VARCHAR2,
      ptapelli2 OUT VARCHAR2,
      ptnombre1 OUT VARCHAR2,
      ptnombre2 OUT VARCHAR2,
      pcsexper OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_datos_conductor';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnregistro=' || pnregistro;
   BEGIN
      vpasexec := 100;
      psperson := NULL;
      pctipper := NULL;
      pctipide := NULL;
      pnnumide := NULL;
      ptapelli1 := NULL;
      ptapelli2 := NULL;
      ptnombre1 := NULL;
      ptnombre2 := NULL;
      vpasexec := 110;

      IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
         FOR k IN
            pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
            IF k = pnregistro THEN
               IF pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos IS NOT NULL
                  AND pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos.COUNT > 0 THEN
                  vpasexec := 120;

                  FOR j IN
                     pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                            (k).riesautos.LAST LOOP
                     FOR i IN
                        pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                                            (k).riesautos
                                                                                                            (j).conductores.LAST LOOP
                        vpasexec := 140;
                        psperson :=
                           pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores
                                                                                            (i).sperson;
                        vpasexec := 145;
                        pctipper :=
                           pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores
                                                                                            (i).persona.ctipper;
                        vpasexec := 150;
                        pctipide :=
                           pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores
                                                                                            (i).persona.ctipide;
                        vpasexec := 155;
                        pnnumide :=
                           pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores
                                                                                            (i).persona.nnumide;
                        vpasexec := 160;
                        ptapelli1 :=
                           pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores
                                                                                            (i).persona.tapelli1;
                        vpasexec := 165;
                        ptapelli2 :=
                           pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores
                                                                                            (i).persona.tapelli2;
                        vpasexec := 170;
                        ptnombre1 :=
                           pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores
                                                                                            (i).persona.tnombre1;
                        vpasexec := 175;
                        ptnombre2 :=
                           pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores
                                                                                            (i).persona.tnombre2;
                        -- BUG 21905 - FAL - 27/06/2012
                        vpasexec := 180;
                        pcsexper :=
                           pac_iax_produccion.poliza.det_poliza.riesgos(k).riesautos(j).conductores
                                                                                            (i).persona.csexper;
                     END LOOP;   -- conductores
                  END LOOP;   -- autriesgos
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         psperson := NULL;
         RETURN 1;
   END f_datos_conductor;

   /*************************************************************************
      f_garantias_siniestro
      Obtener las garantias seleccionadas para el siniestro del objeto
      ptgarantias out t_iax_garansini:  garantias seleccionadas
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/-- BUG 0025965- 25/02/2013 - DCT
   FUNCTION f_garantias_siniestro(ptgarantias OUT t_iax_garansini)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_garantias_siniestro';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100) := '';
   BEGIN
      vpasexec := 100;
      ptgarantias := NULL;
      vpasexec := 110;

      IF pac_iax_siniestros.vgobsiniestro.garantias IS NOT NULL THEN
         IF pac_iax_siniestros.vgobsiniestro.garantias.COUNT > 0 THEN
            ptgarantias := pac_iax_siniestros.vgobsiniestro.garantias;
         END IF;
      END IF;

      vpasexec := 180;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_garantias_siniestro;

   /*************************************************************************
      f_get_parpersona
      Obtener los parametros de la persona

      return              : 0 todo correcto, 1 ha habido un error

      Bug 27314/158946 - 18/11/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcvisible IN NUMBER,
      ptots IN NUMBER,
      pctipper IN NUMBER,
      pparper OUT t_iax_par_personas)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_get_parpersona';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100)
         := 'psperson:' || psperson || ' pcagente:' || pcagente || ' pcvisible:' || pcvisible
            || ' ptots:' || ptots || ' pctipper:' || pctipper;
      mensajes       t_iax_mensajes;
   BEGIN
      vnumerr := pac_iax_persona.f_get_estparpersona(psperson, pcagente, pcvisible, ptots,
                                                     pctipper, pparper, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_get_parpersona;

   /*************************************************************************
      f_abrir_suplemento
      Abrir suplemento

      return              : 0 todo correcto, 1 ha habido un error

      Bug 26472/169132 - 11/03/2014 - NSS
   *************************************************************************/
   FUNCTION f_abrir_suplemento(psseguro IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_abrir_suplemento';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100) := 'psseguro:' || psseguro;
      mensajes       t_iax_mensajes;
   BEGIN
      vnumerr := pac_iax_produccion.f_abrir_suplemento(psseguro, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_abrir_suplemento;

   /*************************************************************************
      f_emitir_col_admin
      Emitir colectivo administrado

      return              : 0 todo correcto, 1 ha habido un error

      Bug 26472/169132 - 11/03/2014 - NSS
   *************************************************************************/
   FUNCTION f_emitir_col_admin(psseguro IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_call.f_emitir_col_admin';
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100) := 'psseguro:' || psseguro;
      mensajes       t_iax_mensajes;
      vcontinuaemitir NUMBER;
   BEGIN
      vnumerr := pac_iax_produccion.f_emitir_col_admin(psseguro, vcontinuaemitir, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_emitir_col_admin;
END pac_call;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALL" TO "PROGRAMADORESCSI";
