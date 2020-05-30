--------------------------------------------------------
--  DDL for Package Body PAC_IAX_GESTIONPROPUESTA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PAC_IAX_GESTIONPROPUESTA" AS
/******************************************************************************
 NOMBRE: PAC_IAX_GESTIONPROPUESTA
   PROP¿SITO:  Funciones para gestionar las propuestas retenidas

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/10/2008   APD                1. Creaci¿n del package.
   2.0        03/03/2009   DRA                2. BUG0009297: IAX - Gesti¿ de propostes - Revisi¿ punts pendents
   3.0        03/04/2009   DRA                3. BUG0009423: IAX - Gesti¿ propostes retingudes: detecci¿ difer¿ncies al modificar capitals o afegir garanties
   4.0        01/10/2009   JRB                3. BUG0011196: Gesti¿n de propuestas retenidas
   5.0        12/11/2009   JTS                5. 10093: CRE - Afegir filtre per RAM en els cercadors
   6.0        22/02/2010   ICV                6. 0009605: AGA - Buscadores
   7.0        02/11/2010   XPL                7. 16352: CRT702 - M¿dulo de Propuestas de Suplementos, -- BUG16352:XPL:02112010 INICI
   8.0        09/07/2013   RCL                8. 0027048: LCOL_T010-Revision incidencias qtracker (V)
   9.0        14/08/2013   RCL                9. 0027262: LCOL - Fase Mejoras - Autorizaci¿n masiva de propuestas retenidas
   10.0       20/09/2013   JSV                10. 0027876: LCOL_F3B-Parametrizacion suplementos AUTOS COLECTIVOS (Producto AWS)
   11.0       22/11/2013   RCL                11. 0027048: LCOL_T010-Revision incidencias qtracker (V)
   12.0       14/04/2014   FAL                12. 0029965: RSA702 - GAPS renovaci¿n
   13.0       20/03/2019   CJMR               13. IAXIS-3160: Adición de nuevos campo de búsqueda
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Recupera todas las propuestas retenidas
      param in psproduc  : C¿digo del producto
      param in pnpoliza  : N¿ de poliza
      param in pnsolici  : Solicitud
      param in pfcancel  : Fecha de cancelaci¿n
      param in pnumide   : Documento idenficaci¿n persona
      param in pnombre   : Tomador
      param in psnip     : Identificador externo
      param in pcestgest : Estado gesti¿n de la retenci¿n.
      pcmatric in varchar2
      pcpostal in varchar2
      pTNATRIE in varchar2
      pTDOMICI in varchar2
      param out mensajes : mesajes de error
      return             : T_IAX_POLIZASRETEN
   *************************************************************************/
   FUNCTION f_get_polizasreten(
      psproduc IN NUMBER,
      pnpoliza IN seguros.npoliza%TYPE,
      pnsolici IN NUMBER,
      pfcancel IN DATE,
      pnumide IN VARCHAR2,
      pnombre IN VARCHAR2,
      psnip IN VARCHAR2,
      pcmotret IN NUMBER,
      pcestgest IN NUMBER,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pctipo IN VARCHAR2,
      pcmatric IN VARCHAR2,
      pcpostal IN VARCHAR2,
      ptnatrie IN VARCHAR2,
      ptdomici IN VARCHAR2,
      pcnivelbpm IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pcsucursal IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcadm IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcmotor IN VARCHAR2 DEFAULT NULL,   -- Bug 25177/133016 - 28/12/2012 - AMC
      pcchasis IN VARCHAR2 DEFAULT NULL,   -- Bug 25177/133016 - 28/12/2012 - AMC
      pnbastid IN VARCHAR2 DEFAULT NULL,   -- Bug 25177/133016 - 28/12/2012 - AMC
      pmodo IN VARCHAR2 DEFAULT NULL,
      pccontrol IN NUMBER DEFAULT NULL,
      pcpolcia IN VARCHAR2 DEFAULT NULL,   -- Bug 0029965 - 14/04/2014 - FAL
      pfretend IN DATE DEFAULT NULL,   -- Bug 0029965 - 14/04/2014 - FAL
      pfretenh IN DATE DEFAULT NULL,   -- Bug 0029965 - 14/04/2014 - FAL
      pcactivi IN NUMBER DEFAULT NULL,       -- CJMR 20/03/2019 IAXIS-3160
      pnnumidease IN VARCHAR2 DEFAULT NULL,  -- CJMR 20/03/2019 IAXIS-3160
      pnombrease IN VARCHAR2 DEFAULT NULL,   -- CJMR 20/03/2019 IAXIS-3160
      ppolretpsu OUT t_iax_polretenpsu)
      RETURN t_iax_polizasreten IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psproduc: ' || psproduc || ' - pnsolici:' || pnsolici || ' - pfcancel:'
            || pfcancel || ' - pnumide:' || pnumide || ' - pnombre:' || pnombre || ' - psnip:'
            || psnip || ' - pcestgest: ' || pcestgest || ' - pcramo: ' || pcramo
            || ' - pcagente: ' || pcagente || ' - pctipo: ' || pctipo || ' - pcmatric : '
            || pcmatric || ' - pcpostal : ' || pcpostal || ' - ptnatrie : ' || ptnatrie
            || ' - pTDOMICI : ' || ptdomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_Get_PolizasReten';
      obj            t_iax_polizasreten;
   BEGIN
      --Autorizaci¿n masiva de propuestas retenidas
      IF pmodo = 'AUTORIZA_MASIVO' THEN
         IF pnpoliza IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 140896);
            RETURN NULL;
         END IF;
      END IF;

      obj :=
         pac_md_gestionpropuesta.f_get_polizasreten
                                               (psproduc, pnpoliza, pnsolici, pfcancel,
                                                pnumide, pnombre, psnip, pcmotret, pcestgest,
                                                pcramo, pcagente, pctipo, pcmatric, pcpostal,
                                                ptnatrie, ptdomici, pcnivelbpm, mensajes,
                                                pcsucursal, pcadm, pcmotor, pcchasis, pnbastid,   -- Bug 25177/133016 - 28/12/2012 - AMC
                                                pmodo, pccontrol, pcpolcia, pfretend, pfretenh,   -- Bug 0029965 - 14/04/2014 - FAL
                                                pcactivi, pnnumidease, pnombrease,                -- CJMR 20/03/2019 IAXIS-3160
                                                ppolretpsu);
      RETURN obj;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_polizasreten;

   /*************************************************************************
      Recupera los motivos de retenci¿n de las propuestas
      param in psseguro  : C¿digo seguro
      param in pnmovimi  : N¿mero de movimiento
      param out mensajes : mesajes de error
      return             : T_IAX_POLMVTRETEN
   *************************************************************************/
   FUNCTION f_get_motretenmov(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_polmvtreten IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_Get_MotRetenMov';
      obj            t_iax_polmvtreten;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      obj := pac_md_gestionpropuesta.f_get_motretenmov(psseguro, pnmovimi, mensajes);
      RETURN obj;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_motretenmov;

   /*************************************************************************
      Recupera la fecha de efecto de la propuesta y las observaciones a mostrar
      param in psseguro  : C¿digo seguro
      param out pfefecto  : Fecha efecto
      param out pobserv  : Observaciones
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_infopropreten(
      psseguro IN NUMBER,
      pfefecto OUT DATE,
      pobserv OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_Get_InfoPropReten';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_gestionpropuesta.f_get_infopropreten(psseguro, pfefecto, pobserv,
                                                            mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN nerror;
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
   END f_get_infopropreten;

   /*************************************************************************
      Acepta la propuesta retenida
      param in psseguro  : C¿digo seguro
      param in pnmovimi  : N¿mero de movimiento
      param in pfefecto  : Fecha efecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_aceptarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptobserv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pfefecto:'
            || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_AceptarPropuesta';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_gestionpropuesta.f_aceptarpropuesta(psseguro, pnmovimi, pfefecto,
                                                           ptobserv, mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_aceptarpropuesta;

   /*************************************************************************
      Rechaza la propuesta retenida
      param in psseguro  : C¿digo seguro
      param in pnmovimi  : N¿mero de movimiento
      param in pcmotmov  : C¿digo motivo rechazo
      param in pnsuplem  : C¿digo suplemento
      param in ptobserva  : Observaciones
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_rechazarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      ptobserva IN VARCHAR2,
      ptpostpper IN psu_retenidas.postpper%TYPE,
      pcperpost IN psu_retenidas.perpost%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := SUBSTR('psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pcmotmov:'
                   || pcmotmov || ' - pnsuplem:' || pnsuplem || ' - ptobserva:' || ptobserva
                   || ' ptpostpper: ' || ptpostpper || ' pcperpost: ' || pcperpost,
                   1, 2000);   -- BUG9423:DRA:03-04-2009
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_RechazarPropuesta';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pnsuplem IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_gestionpropuesta.f_rechazarpropuesta(psseguro, pnmovimi, pcmotmov,
                                                            pnsuplem, ptobserva, ptpostpper,
                                                            pcperpost, mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_rechazarpropuesta;

   /*************************************************************************
      Acepta propuestas retenidas
      param in p_cautrec:
      param in p_npoliza: Numero de poliza
      param in ptobserv: Observaciones
      param in p_controls: CCONTROLS de las psu's
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_aceptarpropuesta_masivo(
      p_cautrec IN NUMBER,
      p_npoliza IN NUMBER,
      ptobserv IN VARCHAR2,
      p_controls IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'p_cautrec: ' || p_cautrec || ' - p_npoliza:' || p_npoliza || ' - ptobserv:'
            || ptobserv || ' - p_controls:' || p_controls;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.f_aceptarpropuesta_masivo';
      nerror         NUMBER;
      vtlista        t_lista_id := t_lista_id();
      vlista         ob_lista_id;
      valor          NUMBER;
      i              NUMBER := 0;
      pos            NUMBER := 0;
      lv_str         VARCHAR2(200) := p_controls;
   BEGIN
      IF p_npoliza IS NULL
         OR p_controls IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Inicio: Transformaci¿n VARCHAR2 de tipo XXXX;XXXX;XXX... a t_lista_id
      --Recuperamos la primera posicion del token
      pos := INSTR(lv_str, ';', 1, 1);

      IF pos <> 0 THEN
         WHILE(pos != 0) LOOP
            i := i + 1;
            -- Recuperamos el valor del elemento
            valor := TO_NUMBER(SUBSTR(lv_str, 1, pos - 1));

            IF valor IS NOT NULL THEN
               vlista := ob_lista_id();
               vtlista.EXTEND;
               vlista.idd := valor;
               vtlista(vtlista.LAST) := vlista;
            END IF;

            -- Eliminamos el token que estamos procesando
            lv_str := SUBSTR(lv_str, pos + 1, LENGTH(lv_str));
            -- Recuperamos la posicion del siguiente token
            pos := INSTR(lv_str, ';', 1, 1);

            -- Si es el ¿ltimo, guardamos el valor en la lista
            IF pos = 0 THEN
               IF lv_str IS NOT NULL THEN
                  vlista := ob_lista_id();
                  vtlista.EXTEND;
                  vlista.idd := lv_str;
                  vtlista(vtlista.LAST) := vlista;
               END IF;
            END IF;
         END LOOP;
      ELSE
         --Si no existe token, solo se ha seleccionado un elemento, guardamos directamente su valor
         vlista := ob_lista_id();
         vtlista.EXTEND;
         vlista.idd := TO_NUMBER(p_controls);
         vtlista(vtlista.LAST) := vlista;
      END IF;

      --Fin: Transformaci¿n VARCHAR2 de tipo XXXX;XXXX;XXX... a t_lista_id
      vpasexec := 4;
      nerror := pac_md_gestionpropuesta.f_aceptarpropuesta_masivo(p_cautrec, p_npoliza,
                                                                  ptobserv, vtlista, mensajes);
      COMMIT;
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         COMMIT;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         COMMIT;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         COMMIT;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_aceptarpropuesta_masivo;

   /*************************************************************************
      Rechaza las propuestas retenida masivamente

      param in p_npoliza : Numero de poliza
      param in pcmotmov  : C¿¿digo motivo rechazo
      param in ptobserv  : Observaciones
      param in p_controls: CCONTROLS de las psu's
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_rechazarpropuesta_masivo(
      p_npoliza IN NUMBER,
      pcmotmov IN NUMBER,
      ptobserv IN VARCHAR2,
      p_controls IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := SUBSTR('p_npoliza:' || p_npoliza || ' - pcmotmov:' || pcmotmov || ' - ptobserv:'
                   || ptobserv || ' - p_controls:' || p_controls,
                   1, 2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_RechazarPropuesta';
      nerror         NUMBER;
      vtlista        t_lista_id := t_lista_id();
      vlista         ob_lista_id;
      valor          NUMBER;
      i              NUMBER := 0;
      pos            NUMBER := 0;
      lv_str         VARCHAR2(200) := p_controls;
   BEGIN
      IF p_npoliza IS NULL
         OR p_controls IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Inicio: Transformaci¿n VARCHAR2 de tipo XXXX;XXXX;XXX... a t_lista_id
      --Recuperamos la primera posicion del token
      pos := INSTR(lv_str, ';', 1, 1);

      IF pos <> 0 THEN
         WHILE(pos != 0) LOOP
            i := i + 1;
            -- Recuperamos el valor del elemento
            valor := TO_NUMBER(SUBSTR(lv_str, 1, pos - 1));

            IF valor IS NOT NULL THEN
               vlista := ob_lista_id();
               vtlista.EXTEND;
               vlista.idd := valor;
               vtlista(vtlista.LAST) := vlista;
            END IF;

            -- Eliminamos el token que estamos procesando
            lv_str := SUBSTR(lv_str, pos + 1, LENGTH(lv_str));
            -- Recuperamos la posicion del siguiente token
            pos := INSTR(lv_str, ';', 1, 1);

            -- Si es el ¿ltimo, guardamos el valor en la lista
            IF pos = 0 THEN
               IF lv_str IS NOT NULL THEN
                  vlista := ob_lista_id();
                  vtlista.EXTEND;
                  vlista.idd := lv_str;
                  vtlista(vtlista.LAST) := vlista;
               END IF;
            END IF;
         END LOOP;
      ELSE
         --Si no existe token, solo se ha seleccionado un elemento, guardamos directamente su valor
         vlista := ob_lista_id();
         vtlista.EXTEND;
         vlista.idd := TO_NUMBER(p_controls);
         vtlista(vtlista.LAST) := vlista;
      END IF;

      --Fin: Transformaci¿n VARCHAR2 de tipo XXXX;XXXX;XXX... a t_lista_id
      vpasexec := 4;
      nerror := pac_md_gestionpropuesta.f_rechazarpropuesta_masivo(p_npoliza, pcmotmov,
                                                                   ptobserv, vtlista, mensajes);
      COMMIT;
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         COMMIT;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         COMMIT;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         COMMIT;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_rechazarpropuesta_masivo;

   /*************************************************************************
      Recupera la fecha actual/nueva de cancelaci¿n de la propuesta
      param in psseguro  : C¿digo seguro
      param in psproduc  : C¿digo producto
      param out pfcancel  : Fecha actual de cancelaci¿n
      param out pfcancelnueva  : Nueva fecha de cancelaci¿n
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_fechacancel(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfcancel OUT DATE,
      pfcancelnueva OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' - psproduc:' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_Get_FechaCancel';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_gestionpropuesta.f_get_fechacancel(psseguro, psproduc, pfcancel,
                                                          pfcancelnueva, mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN nerror;
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
   END f_get_fechacancel;

   /*************************************************************************
      Cambia la fecha de cancelaci¿n de la propuesta a la nueva fecha
      param in psseguro  : C¿digo seguro
      param in pnmovimi  : N¿mero movimiento
      param out pfcancelnueva  : Nueva fecha de cancelaci¿n
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_cambio_fcancel(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfcancelnueva IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pfcancelnueva:'
            || pfcancelnueva;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_Cambio_FCancel';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_gestionpropuesta.f_cambio_fcancel(psseguro, pnmovimi, pfcancelnueva,
                                                         mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_cambio_fcancel;

   /*************************************************************************
      Limpia los datos temporales de la modificaci¿n de propuesta
      param in psseguro  : C¿digo seguro
   *************************************************************************/
   PROCEDURE limpiartemporales(psseguro IN NUMBER) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.LimpiarTemporales';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      pac_md_gestionpropuesta.limpiartemporales(psseguro);
      COMMIT;
   EXCEPTION
      WHEN e_param_error THEN
         --        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,1000005,vpasexec,vparam);
         NULL;
      WHEN OTHERS THEN
         --        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
         NULL;
   END limpiartemporales;

   /*************************************************************************
      Habilita la modificaci¿n de la propuesta retenida
      param in psseguro  : C¿digo seguro
      param in pcmodo  : Modo de trabajo
      param in pcform  : Nombre formulario
      param in pccampo  : Nombre del bot¿n pulsado
      param out oestsseguro  : C¿digo seguro temporal
      param out onmovimi  : N¿mero movimiento
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_inicializar_modificacion(
      psseguro IN NUMBER,
      pcmodo IN VARCHAR2,
      pcform IN VARCHAR2,
      pccampo IN VARCHAR2,
      oestsseguro OUT NUMBER,
      onmovimi OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pcmodo:' || pcmodo || ' - pcform:' || pcform
            || ' - pccampo:' || pccampo;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_Inicializar_Modificacion';
      nerror         NUMBER;
      v_cobjase      seguros.cobjase%TYPE;
   BEGIN
      -- BUG 0027876/0153187 - JSV (20/09/2013) - INI
      SELECT seg.cobjase
        INTO v_cobjase
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      IF pccampo IN('BT_DATOS_AUTO', 'BT_CONDUCTOR_AUTO', 'BT_REVINSPEC')
         AND v_cobjase <> 5 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905990);
         RAISE e_object_error;
      END IF;

      -- BUG 0027876/0153187 - JSV (20/09/2013) - FIN
      IF psseguro IS NULL
         OR pcmodo IS NULL
         OR pcform IS NULL
         OR pccampo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_gestionpropuesta.f_inicializar_modificacion(psseguro, 'MODIF_PROP',
                                                                   pcform, pccampo,
                                                                   oestsseguro, onmovimi,
                                                                   mensajes);

      IF nerror <> 0 THEN
         --es fa commit ja que si ha donat error es borren les dades de la taula EST i
         --s'hauria de comitejar ja que al llan¿ar l'excepci¿ far¿¿ un rollback.
         -- bug 11557 XPL 28/10/2009
         COMMIT;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF nerror = 0 THEN
         pac_iax_produccion.ismodifprop := TRUE;
         pac_iax_produccion.vsseguro := psseguro;
         pac_iax_produccion.vnmovimi := onmovimi;
         nerror := pac_iax_produccion.f_set_consultapoliza(oestsseguro, mensajes, 'EST');

         IF nerror <> 0 THEN
            RAISE e_object_error;
         END IF;

         IF pccampo = 'BT_REVINSPEC' THEN   --si estamos en revisi¿n de inspecci¿n, obligamos a tarificar
            pac_iax_produccion.poliza.det_poliza.p_set_needtarificar(1);
         END IF;
      END IF;

      COMMIT;
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_inicializar_modificacion;

   /*************************************************************************
      Graba las modificaciones realizadas a la propuesta
      param in psseguro  : C¿digo seguro
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_grabar_alta_poliza(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_GRABAR_ALTA_POLIZA';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_gestionpropuesta.f_grabar_alta_poliza(psseguro, mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF nerror = 0 THEN
         pac_iax_produccion.ismodifprop := FALSE;
         pac_iax_produccion.vsseguro := NULL;
         pac_iax_produccion.vnmovimi := NULL;
         pac_iax_produccion.vpmode := NULL;
      END IF;

      COMMIT;
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_grabar_alta_poliza;

   /*************************************************************************
      Mira si se puede asignar el n¿mero de p¿liza al emitir
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_npolizaenemision(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200);   --:='psseguro: '||psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_GET_NPOLIZAENEMISION';
      nerror         NUMBER;
      vcont          NUMBER;
      vresult        NUMBER;
   BEGIN
      nerror := pac_md_gestionpropuesta.f_get_npolizaenemision(vcont, mensajes);

      IF vcont = 0 THEN
         vresult := 1;   -- indica que NO se debe mostrar/introducir la solicitud
      ELSE
         vresult := 0;   -- indica que se debe mostrar/introducir la poliza y la solicitud
      END IF;

      RETURN vresult;
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
   END f_get_npolizaenemision;

   /*************************************************************************
      Recupera la fecha de efecto
      param in psseguro  : C¿digo seguro
      param out pfefecto : Fecha de efecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_fefecto(psseguro IN NUMBER, pfefecto OUT DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_GET_FEFECTO';
      nerror         NUMBER;
   BEGIN
      nerror := pac_md_gestionpropuesta.f_get_fefecto(psseguro, pfefecto, mensajes);
      RETURN nerror;
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
   END f_get_fefecto;

   /*************************************************************************
      Comprueba si se puede modificar la fecha de efecto o no
      param in psseguro  : C¿digo seguro
      param out mensajes : mesajes de error
      return             : NUMBER (0 --> NO se puede modificar la Fecha de efecto)
                                  (1 --> SI se puede modificar la Fecha de efecto)
   *************************************************************************/
   FUNCTION f_permite_cambio_fefecto(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_PERMITE_CAMBIO_FEFECTO';
      nerror         NUMBER;
      vresult        NUMBER;
   BEGIN
      vresult := pac_md_gestionpropuesta.f_permite_cambio_fefecto(psseguro, mensajes);
      RETURN vresult;
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
   END f_permite_cambio_fefecto;

   /*************************************************************************
      Valida que la fecha de efecto sea correcta
      param in psseguro  : C¿digo seguro
      param in pfefecto  : Fecha de efecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_valida_fefecto(psseguro IN NUMBER, pfefecto IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' pfefecto: ' || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_VALIDA_FEFECTO';
      nerror         NUMBER;
   BEGIN
      nerror := pac_md_gestionpropuesta.f_valida_fefecto(psseguro, pfefecto, mensajes);
      RETURN nerror;
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
   END f_valida_fefecto;

      /*************************************************************************
      Habilita la modificaci¿n de la propuesta retenida
      param in psseguro  : C¿digo seguro
      param in pnriesgo  : N¿mero del riesgo
      param in pnmovimi  : N¿mero movimiento
      param in pcmotret  : N¿mero motivo retenci¿n
      param in pnmotret  : N¿mero retenci¿n
      param in pcestgest : C¿digo estado gesti¿n
      param in ptodos    : Todos 0 por defecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_act_estadogestion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER,
      pnmotret IN NUMBER,
      pcestgest IN NUMBER,
      ptodos IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' - pnmovimi: '
            || pnmovimi || ' - pcmotret: ' || pcmotret || ' - pnmotret: ' || pnmotret
            || ' - pcestgest: ' || pcestgest || ' - ptodos: ' || ptodos;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_ACT_ESTADOGESTION';
      nerror         NUMBER;
   BEGIN
      nerror := pac_md_gestionpropuesta.f_act_estadogestion(psseguro, pnriesgo, pnmovimi,
                                                            pcmotret, pnmotret, pcestgest,
                                                            ptodos, mensajes);
      RETURN nerror;
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
   END f_act_estadogestion;

-- BUG16352:XPL:02112010 INICI
   /*************************************************************************
      Graba las modificaciones realizadas a la propuesta
      param in psseguro  : C¿digo seguro
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_actualizar_sol_suplemento(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.f_actualizar_sol_suplemento';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      nerror :=
         pac_md_gestionpropuesta.f_actualizar_sol_suplemento(psseguro,
                                                             pac_iax_produccion.vsolicit,
                                                             mensajes);

      IF nerror != 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_actualizar_sol_suplemento;

   /*************************************************************************
        Recupera las solicitudes segn los filtros introducidos
        param in psseguro  : C¿digo seguro
        return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
     *************************************************************************/
   FUNCTION f_get_solicitudsuplementos(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psolicitudes OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.f_get_solicitudsuplementos';
      nerror         NUMBER;
      vselect        VARCHAR2(2000);
      vfrom          VARCHAR2(200);
      vwhere         VARCHAR2(2000);
      pquery         VARCHAR2(4000);
      vsseguro       NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      nerror := pac_md_gestionpropuesta.f_get_solicitudsuplementos(psseguro, pnmovimi,
                                                                   pnriesgo, psolicitudes,
                                                                   mensajes);

      IF nerror != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN nerror;
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
   END f_get_solicitudsuplementos;

   /*************************************************************************
      Actualiza el estado de la solicitud del suplemento
      param in psseguro  : Cdigo seguro
      param in pnmovimi  : Num. Movimiento
      param in pnriesgo  : N. riesgo
      param in pcestsupl  : Estado suplemento
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_set_actualizarestado_supl(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pcestado IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.f_set_actualizarestado_supl';
      nerror         NUMBER;
      vselect        VARCHAR2(2000);
      vfrom          VARCHAR2(200);
      vwhere         VARCHAR2(2000);
      pquery         VARCHAR2(4000);
      vsseguro       NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      nerror := pac_md_gestionpropuesta.f_set_actualizarestado_supl(psseguro, pnmovimi,
                                                                    pnriesgo, pcmotmov,
                                                                    pcgarant, pcpregun,
                                                                    pcestado, mensajes);

      IF nerror != 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN nerror;
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
   END f_set_actualizarestado_supl;

   FUNCTION f_emision_masiva_marcar(
      ppolizas IN t_iax_info,
      pcestado IN NUMBER,
      psproces_in IN NUMBER,
      psproces_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.f_emision_masiva_marcar';
      nerror         NUMBER := 0;
      vselect        VARCHAR2(2000);
      vfrom          VARCHAR2(200);
      vwhere         VARCHAR2(2000);
      pquery         VARCHAR2(4000);
      vsseguro       NUMBER;
   BEGIN
      nerror := pac_md_gestionpropuesta.f_emision_masiva_marcar(ppolizas, pcestado,
                                                                psproces_in, psproces_out,
                                                                mensajes);

      IF nerror != 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN nerror;
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
   END f_emision_masiva_marcar;

   FUNCTION f_emision_masiva(psproces IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.f_emision_masiva';
      nerror         NUMBER;
      vselect        VARCHAR2(2000);
      vfrom          VARCHAR2(200);
      vwhere         VARCHAR2(2000);
      pquery         VARCHAR2(4000);
      vsseguro       NUMBER;
   BEGIN
      --RCL 09/07/2013 - INICI BUG 27048
      IF psproces IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905774);
         RETURN 1;
      END IF;

      --RCL 09/07/2013 - FI BUG 27048
      --BUG 27048/158857 - RCL - 22/11/2013 - Emision masiva
      nerror := pac_md_gestionpropuesta.f_emision_masiva_job(psproces, mensajes);

      IF nerror != 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN nerror;
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
   END f_emision_masiva;

	 /*************************************************************************
      Recupera movimiento de tabla est para reinicio de poliza    21/06/2017 DVA
      param in psseguro  : C¿digo seguro
      param in pcmotmov : Motivo de movimiento
	  param out outnmovimi : Movimiento a retornar
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_rei_nmovimi(psseguro IN NUMBER
   , pcmotmov IN NUMBER
   ,outnmovimi OUT NUMBER
   ,  mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' - pcmotmov:' || pcmotmov;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_GET_REI_NMOVIMI';
      nerror         NUMBER;
   BEGIN
      nerror := pac_md_gestionpropuesta.f_get_rei_nmovimi(psseguro,pcmotmov, outnmovimi, mensajes);
      RETURN nerror;
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
   END f_get_rei_nmovimi;
END pac_iax_gestionpropuesta;

/