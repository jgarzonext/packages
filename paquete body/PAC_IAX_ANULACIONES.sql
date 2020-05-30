--------------------------------------------------------
--  DDL for Package Body PAC_IAX_ANULACIONES
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PAC_IAX_ANULACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_ANULACIONES
   PROPÓSITO: Funciones para anular una póliza

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/12/2007  ACC              1. Creación del package.
   1.1        02/03/2009  DCM              2. Modificaciones Bug 8850
   1.2        02/03/2009  JGM              3. Bug 10842
   1.3        19/05/2009  JTS              3. 9914: IAX- ANULACIÓN DE PÓLIZA - Baja inmediata
   1.4        29/10/2009  JTS              4. 10249: CIV - PIAS - Mensaje de anulación de póliza duplicado
   2.0        05/11/2009  DRA              5. 0011772: CEM - Extorn automàtic en anul·lacions immediates (a data d'efecte proposada per CEM)
   3.0        23/11/2009  DRA              6. 0010772: CRE - Desanul·lar programacions al venciment/propera cartera
   4.0        02/03/2009  ICV              7. 0013068: CRE - Grabar el motivo de la anulación al anular la póliza
   5.0        13/12/2010  ICV              8. 0016775: CRT101 - Baja de pólizas
   6.0        24/02/2011  ICV              9. 0017718: CCAT003 - Accés a productes en funció de l'operació
   7.0        21/10/2011  DRA             10. 0019863: CIV903 - Desconnexió de les crides a Eclipse pels productes PPA i PIES
   8.0        11/07/2012  APD             11. 0022826: LCOL_T010-Recargo por anulación a corto plazo
   9.0        26/09/2012  APD             12. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
   10.0       06/11/2012  JGR             13. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249
   11.0       16-11-2012  DCT             14. 0023817: LCOL - Anulación de colectivos
   12.0       10-11-2012  JDS             15. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   13.0       05-03-2013  APD             16. 0026151: LCOL - QT 6096 - Anular movimientos de carátula
   14.0       08-04-2013  APD             17. 0026645: LCOL: Recobro de Retorno
   15.0       21/11/2013  FAL             18. 0026835: GIP800 - Incidencias reportadas 23/4
   16.0       17/06/2016  VCG             19. AMA-187-Realizar el desarrollo del GAP 114
   20.0       17/01/2020  CJMR            20. IAXIS-3640: Anulaciones. No debe permitir anular pólizas con endosos activos
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
      Recupera los datos de la poliza
      param out psseguro  : código de seguro
      param out onpoliza  : número de póliza
      param out oncertif  : número de certificado
      param out ofefecto  : fecha efecto
      param out ofvencim  : fecha vencimiento
      param out ofrenovac : fecha proxima cartera
      param out osproduc  : código del producto de la póliza
      param out otproduc  : título del producto
      param out otsituac  : descripción de la situación de la póliza
      param out mensajes  : mensajes de error
      return              : 0 todo ha sido correcto
                            1 ha habido un error
   ***********************************************************************/
   FUNCTION f_get_datpoliza(
      psseguro IN NUMBER,
      onpoliza OUT NUMBER,
      oncertif OUT NUMBER,
      ofefecto OUT DATE,
      ofvencim OUT DATE,
      ofrenovac OUT DATE,
      osproduc OUT NUMBER,
      otproduc OUT VARCHAR2,
      otsituac OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.F_Get_DatPoliza';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vobjpol        ob_iax_genpoliza;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vobjpol := pac_iax_produccion.f_get_datpoliza(psseguro, mensajes, 'POL');

      IF vobjpol IS NULL THEN
         RAISE e_object_error;
      END IF;

      onpoliza := vobjpol.npoliza;
      oncertif := vobjpol.ncertif;
      osproduc := vobjpol.sproduc;
      otproduc := vobjpol.tproduc;
      otsituac := vobjpol.tsituac;
      ofefecto := vobjpol.fefecto;
      ofvencim := vobjpol.fvencim;
      ofrenovac := vobjpol.fcaranu;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_datpoliza;

   /***********************************************************************
      Recupera los datos del tomador de la poliza
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : objeto tomadores
   ***********************************************************************/
   FUNCTION f_get_tomadores(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_tomadores IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.F_Get_Tomadores';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_obtenerdatos.f_inicializa('POL', psseguro, NULL, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      RETURN pac_md_obtenerdatos.f_leetomadores(mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_tomadores;

   /***********************************************************************
      Recupera los datos de los recibos de la poliza
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_recibos(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.F_Get_Recibos';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
   BEGIN
      --Inicialitzacions
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vcursor := pac_md_anulaciones.f_get_recibos(psseguro, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_recibos;

   /***********************************************************************
      Recupera los datos de los siniestros de la poliza
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_siniestros(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.F_Get_Siniestros';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vcursor := pac_md_anulaciones.f_get_siniestros(psseguro, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_siniestros;

   /***********************************************************************
      Dado el tipo de anulación calcula la fecha de la anulación
      param in psseguro  : código de seguro
      param in pctipanul : código tipo de anulación
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_tipanulacion(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN DATE IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.F_Set_TipAnulacion';
      vparam         VARCHAR2(500)
                     := 'parámetros - psseguro: ' || psseguro || ' - pctipanul: ' || pctipanul;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL
         OR pctipanul IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      RETURN pac_md_anulaciones.f_get_fanulac(psseguro, pctipanul, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_set_tipanulacion;

   /***********************************************************************
      Procesa la anulación de la póliza
      param in psseguro  : código de seguro
      param in pctipanul : código tipo de anulación
      param in pfanulac  : fecha anulación
      param in pmotanula : motivo anulación
      param out mensajes : mensajes de error
      param in precextrn default 0 : indica si se debe procesar el extorno
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   ***********************************************************************/
   -- Bug 22826 - APD - 11/07/2012 - se añade el parametro paplica_penali
   -- Bug 22839 - APD - 26/09/2012 - se cambia el nombre de la funcion por f_anulacion_poliza
   -- se añade el parametro pbajacol = 0.Se está realizando la baja de un certificado normal
   -- 1.Se está realizando la baja del certificado 0
   -- Bug 26151 - APD - 26/02/2013 - se añade el parametro pcommit para indicar si se debe
   -- realizar el COMMIT/ROLLBACK (1) o no (0)
   FUNCTION f_anulacion_poliza(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      pfanulac IN DATE,
      pccauanul IN NUMBER,
      pmotanula IN VARCHAR2,
      precextrn IN NUMBER,
      panula_rec IN NUMBER,
      precibos IN VARCHAR2,
      paplica_penali IN NUMBER,
      pbajacol IN NUMBER DEFAULT 0,
      pimpextorsion IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes,
      panumasiva IN NUMBER DEFAULT 0,
      pcommit IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.F_Anulacion_Poliza';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pctipanul: ' || pctipanul
            || ' - pfanulac: ' || pfanulac || ' - pccauanul: ' || pccauanul
            || ' - pmotanula: ' || pmotanula || ' - precextrn: ' || precextrn
            || ' - panula_rec: ' || panula_rec || ' - precibos: ' || precibos
            || ' - paplica_penali: ' || paplica_penali || ' - pimpextorsion: '
            || pimpextorsion || ' - panumasiva: ' || panumasiva || ' - pcommit: ' || pcommit;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vttipanul      VARCHAR2(100);
      v_sproduc      NUMBER;
      vnmovimi       NUMBER;
      vsinterf       NUMBER;
      vterror        VARCHAR2(2000);
      verror         NUMBER(10);
      vfanufinal     seguros.fanulac%TYPE;   -- 13. 0022346 - 0126249 (+)
      vcidioma       NUMBER := pac_md_common.f_get_cxtidioma;   -- 13. 0022346 - 0126249 (+)
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL
         OR pctipanul IS NULL
         OR pfanulac IS NULL
         OR pccauanul IS NULL
         OR precextrn IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_seguros.f_get_sproduc(psseguro, NULL, v_sproduc);
      -- dra 16-12-2008: bug mantis 7826
      -- Validem si té accés per contractar el producte
      vpasexec := 3;
      vnumerr := pac_md_validaciones.f_valida_acces_prod(v_sproduc,
                                                         pac_md_common.f_get_cxtagente, 6,
                                                         mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      --Apuntem el motiu de l'anul·lació a l'agenda de l'assegurança
      -- Bug 22826 - APD - 11/07/2012 - se añade el parametro precextrn y paplica_penali
      vnumerr := pac_md_anulaciones.f_ins_agensegu(psseguro, pctipanul, pmotanula, pccauanul,
                                                   precextrn, paplica_penali, mensajes);

      -- fin Bug 22826 - APD - 11/07/2012
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      -- BUG 8850 - 8850 - DCM ¿ Tratamiento tipo de anulacion al VTO fecha de proxima cartera
      --IF pctipanul = 1 THEN
      IF pctipanul IN(1, 5) THEN   --JAMF  33921  23/01/2015
         -- AL EFECTO VF 553
         -- FI BUG 8850 - 8850 - DCM – Tratamiento tipo de anulacion al VTO fecha de proxima cartera
         --BUG 9914 - JTS - 19/05/2009

         --Ini Bug.: 13068 - 02/03/2009  - ICV
         -- Bug 22826 - APD - 11/07/2012 - se añade el parametro paplica_penali
         vnumerr := pac_md_anulaciones.f_anulacion_poliza(psseguro, precextrn, pfanulac,
                                                          pctipanul, panula_rec, NULL,
                                                          pccauanul, paplica_penali, pbajacol,
                                                          mensajes, pimpextorsion, panumasiva);

         -- fin Bug 22826 - APD - 11/07/2012
         --Fin Bug.: 13068

         --Fi BUG 9914 - JTS - 19/05/2009
         IF vnumerr <> 0 THEN
            vpasexec := 7;
            RAISE e_object_error;
         END IF;

         /* dra 16-12-2008: se reemplaza por una función más arriba *
         SELECT SPRODUC INTO v_sproduc
         from seguros
         where sseguro = psseguro;*/
         SELECT MAX(nmovimi)
           INTO vnmovimi
           FROM movseguro
          WHERE sseguro = psseguro
            AND cmovseg = 3;

         vpasexec := 10;

         IF (pac_mdpar_productos.f_get_parproducto('EXTORNO_AUTOMATICO', v_sproduc) = 1)
            AND vnumerr = 0 THEN
            vnumerr := pac_md_produccion.f_cobro_recibos(psseguro, vnmovimi, NULL, NULL, NULL,
                                                         mensajes);

            IF vnumerr <> 0 THEN
               vpasexec := 11;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         -- Bug 26151 - APD - 26/02/2013
         IF pcommit = 1 THEN
            COMMIT;
         END IF;

         -- fin Bug 26151 - APD - 26/02/2013
         -- BUG19863:DRA:21/10/2011: Se pasa el parametro a productos
         IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'INT_SINCRON_POLIZA'), 0) = 1 THEN
            verror := pac_md_con.f_proceso_alta(pac_md_common.f_get_cxtempresa,   -- empresa
                                                psseguro,   --seguro
                                                vnmovimi,   -- nmovimi
                                                'B',   -- A (alta ) 'M' (suplemento)
                                                f_user,   -- fuser
                                                vsinterf,   -- ni caso
                                                vterror   -- ni caso
                                                       );

            -- Bug 26151 - APD - 26/02/2013
            IF pcommit = 1 THEN
               COMMIT;
            END IF;
         -- fin Bug 26151 - APD - 26/02/2013
         END IF;
      ELSIF pctipanul IN(2, 3) THEN   -- 2=PROXIMA CARTERA, 3=VENCIMIENTO :VF 553
         -- BUG 8850 - 8850 - DCM ¿ Tratamiento tipo de anulacion fecha de proxima cartera
         vnumerr := pac_md_anulaciones.f_anulacion_vto(psseguro, pccauanul, 0, pctipanul,
                                                       mensajes);

         IF vnumerr <> 0 THEN
            vpasexec := 9;
            RAISE e_object_error;
         END IF;
      -- FI BUG 8850 - 8850 - DCM – Tratamiento tipo de anulacion fecha de proxima cartera
      --BUG 9914 - JTS - 19/05/2009
      ELSIF pctipanul = 4 THEN   -- 4=INMEDIATA :VF 553
         --vnumerr := pac_md_anulaciones.f_anulacion_poliza(psseguro, pccauanul, 0, pctipanul,
         --mensajes);

         --Ini Bug.: 13068 - 02/03/2009  - ICV
         -- Bug 22826 - APD - 11/07/2012 - se añade el parametro paplica_penali
         vnumerr := pac_md_anulaciones.f_anulacion_poliza(psseguro, precextrn, pfanulac,
                                                          pctipanul, panula_rec, precibos,
                                                          pccauanul, paplica_penali, pbajacol,
                                                          mensajes, pimpextorsion, panumasiva);

         -- fin Bug 22826 - APD - 11/07/2012
         --Fin Bug.: 13068
         IF vnumerr <> 0 THEN
            vpasexec := 15;
            RAISE e_object_error;
         END IF;

         -- BUG11772:DRA:05/11/2009:Inici
         SELECT MAX(nmovimi)
           INTO vnmovimi
           FROM movseguro
          WHERE sseguro = psseguro
            AND cmovseg = 3;

         vpasexec := 16;

         IF (pac_mdpar_productos.f_get_parproducto('EXTORNO_AUTOMATICO', v_sproduc) = 1)
            AND vnumerr = 0 THEN
            vnumerr := pac_md_produccion.f_cobro_recibos(psseguro, vnmovimi, NULL, NULL, NULL,
                                                         mensajes);

            IF vnumerr <> 0 THEN
               vpasexec := 17;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         -- Bug 26151 - APD - 26/02/2013
         IF pcommit = 1 THEN
            COMMIT;
         END IF;

         -- fin Bug 26151 - APD - 26/02/2013
         vpasexec := 18;

         -- BUG19863:DRA:21/10/2011: Se pasa el parametro a productos
         IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'INT_SINCRON_POLIZA'), 0) = 1 THEN
            verror := pac_md_con.f_proceso_alta(pac_md_common.f_get_cxtempresa,   -- empresa
                                                psseguro,   --seguro
                                                vnmovimi,   -- nmovimi
                                                'B',   -- A (alta ) 'M' (suplemento)
                                                f_user,   -- fuser
                                                vsinterf,   -- ni caso
                                                vterror   -- ni caso
                                                       );

            -- Bug 26151 - APD - 26/02/2013
            IF pcommit = 1 THEN
               COMMIT;
            END IF;
         -- fin Bug 26151 - APD - 26/02/2013
         END IF;

         vpasexec := 19;
         -- BUG11772:DRA:05/11/2009:Fi
      --Fi BUG 9914 - JTS - 19/05/2009
      END IF;

      IF vnumerr = 0 THEN
         -- BUG 9645 - LPS - 02/04/2009 ¿ Mensaje de programación de anulación de pólizas
         /*IF pctipanul = 1 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 101853);
         ELS*/ --BUG 10249 - JTS - 29/10/2009
         IF pctipanul IN(2, 3) THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 151975);
         END IF;

         -- 13. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249 - Inicio
         BEGIN
            SELECT fanulac
              INTO vfanufinal
              FROM seguros
             WHERE sseguro = psseguro;

            IF vfanufinal <> pfanulac THEN
               -- 9904341 'Póliza anulada con fecha #1# diferente de la solicitada #2#.
               vterror := f_axis_literales(9904341, vcidioma);
               vterror := REPLACE(vterror, '#1#', TO_CHAR(vfanufinal));
               vterror := REPLACE(vterror, '#2#', TO_CHAR(pfanulac));
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, vcidioma, NULL, vterror);
            END IF;
         END;

         -- 13. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249 - Fin
         -- Bug 26151 - APD - 26/02/2013
         IF pcommit = 1 THEN
            COMMIT;
         END IF;
         -- fin Bug 26151 - APD - 26/02/2013
      -- FI BUG 9645 - LPS - 02/04/2009 ¿ Mensaje de programación de anulación de pólizas
      ELSE
         -- Bug 26151 - APD - 26/02/2013
         IF pcommit = 1 THEN
            ROLLBACK;
         END IF;
      -- fin Bug 26151 - APD - 26/02/2013
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_anulacion_poliza;

   --BUG 9914 - JTS - 19/05/2009
   /*************************************************************************
      FUNCTION f_get_reccobrados
      param in psseguro  : Num. seguro
      param in pfanulac  : Fecha de anulacion
      param out pcursor  : sys_refcursor
      param out mensajes : t_iax_mensajes
      return             : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_reccobrados(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.f_get_reccobrados';
      vparam         VARCHAR2(500)
                       := 'parámetros - psseguro: ' || psseguro || ' - pfanulac: ' || pfanulac;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_anulaciones.f_get_reccobrados(psseguro, pfanulac, pcursor, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_reccobrados;

   /*************************************************************************
      FUNCTION f_get_recpendientes
      param in psseguro  : Num. seguro
      param in pfanulac  : Fecha de anulacion
      param out pcursor  : sys_refcursor
      param out mensajes : t_iax_mensajes
      return             : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_recpendientes(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.f_get_recpendientes';
      vparam         VARCHAR2(500)
                       := 'parámetros - psseguro: ' || psseguro || ' - pfanulac: ' || pfanulac;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_anulaciones.f_get_recpendientes(psseguro, pfanulac, pcursor, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_recpendientes;

   /*************************************************************************
     Valida si es pot anular la pólissa a aquella data
     Paràmetres entrada:
        psSeguro : Identificador de l'assegurança   (obligatori)
        pFAnulac : Data d'anulació de la pòlissa    (obligatori)
        pValparcial : Valida parcialmente              (opcional)
                      1 posició = 0 o 1
                      2 posició = 1 no valida dies anulació (11)
                      3 posició = 1 ...
    Torna :
        0 si es permet anular la pòlissa, 1 KO
   **************************************************************************/
   FUNCTION f_val_fanulac(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pvalparcial IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.f_val_fanulac';
      vparam         VARCHAR2(500)
                       := 'parámetros - psseguro: ' || psseguro || ' - pfanulac: ' || pfanulac;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psseguro IS NULL
         OR pfanulac IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_anulaciones.f_val_fanulac(psseguro, pfanulac, 0, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_val_fanulac;

--Fi BUG 9914 - JTS - 19/05/2009

   --ini BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera
   /***********************************************************************
      Comprobar si es posible desanular una póliza.
      param in  psseguro  : código de seguro
      param out oestado   : Estado 0.- no se puede desanular, 1.- se puede desanular
      param out mensajes  : mensajes de error
      return              : 0 todo ha sido correcto
                            1 ha habido un error
   ***********************************************************************/
   FUNCTION f_es_desanulable(
      psseguro IN NUMBER,
      oestado OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.f_es_desanulable';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      n_ret          NUMBER;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      --Comprovació de paràmetres d'entrada
      vpasexec := 1;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      n_ret := pac_md_anulaciones.f_es_desanulable(psseguro, mensajes);

      IF n_ret IN(0, 1) THEN
         oestado := n_ret;
      ELSE
         oestado := NULL;
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_es_desanulable;

   --fin BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera

   --ini BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera
   /***********************************************************************
      Realizar la desanulación de una póliza.
      param in psseguro  : código de seguro
      param in pfanulac  : fecha anulación
      param in pnsuplem  : número suplemento
      param out mensajes : mensajes de error
      return             : 0.- proceso correcto
                           1.- error
   ***********************************************************************/
   FUNCTION f_desanula_poliza_vto(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pnsuplem IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.f_desanula_poliza_vto';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pfanulac: ' || pfanulac
            || ' - pnsuplem: ' || pnsuplem;
      n_estado       NUMBER;
   BEGIN
      --Comprovació de paràmetres d'entrada
      vpasexec := 1;

      IF psseguro IS NULL
         OR pfanulac IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_iax_anulaciones.f_es_desanulable(psseguro, n_estado, mensajes);
      vpasexec := 3;

      IF n_estado = 0 THEN
         -- Cambio de estado no permitido
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 110300);
         RAISE e_object_error;
      ELSIF n_estado = 1 THEN
         vpasexec := 4;
         vnumerr := pac_md_anulaciones.f_desanula_poliza_vto(psseguro, pfanulac, pnsuplem,
                                                             mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSE
         RAISE e_object_error;
      END IF;

      -- BUG10772:DRA:23/11/2009:inici
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9002298);
      COMMIT;
      -- BUG10772:DRA:23/11/2009:fi
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;   -- BUG10772:DRA:23/11/2009
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;   -- BUG10772:DRA:23/11/2009
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;   -- BUG10772:DRA:23/11/2009
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_desanula_poliza_vto;

--fin BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera

   --Ini Bug.: 16775 - ICV - 30/11/2010
   /***********************************************************************
      Función que realiza una solicitud de Anulación.
      param in psseguro  : código de seguro
      param in pctipanul  : Tipo anulación
      param in pnriesgo  : número de riesgo
      param in pfanulac  : fecha anulación
      param in ptobserv  : Observaciones.
      param in pTVALORD  : Descripción del motivio.
      param in pcmotmov  : Causa anulacion.
      param out mensajes : mensajes de error
      return             : 0.- proceso correcto
                           1.- error
   ***********************************************************************/
   FUNCTION f_set_solanulac(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      pnriesgo IN NUMBER,
      pfanulac IN DATE,
      ptobserv IN VARCHAR2,
      ptvalord IN VARCHAR2,
      pcmotmov IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.f_set_solanulac';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pctipanul: ' || pctipanul
            || ' - pnriesgo: ' || pnriesgo || ' - pfanulac: ' || pfanulac || ' - ptobserv: '
            || ptobserv || ' - pTVALORD: ' || ptvalord || ' - pcmotmov: ' || pcmotmov;
   BEGIN
      --Comprovació de paràmetres d'entrada
      vpasexec := 1;

      IF psseguro IS NULL
         OR pfanulac IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --BUG 18193 - 20/04/2011 - JRB - Se añade motivo anulacion.
      vnumerr := pac_md_anulaciones.f_set_solanulac(psseguro, pctipanul, pnriesgo, pfanulac,
                                                    ptobserv, ptvalord, pcmotmov, mensajes);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      -- BUG10772:DRA:23/11/2009:fi
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;   -- BUG10772:DRA:23/11/2009
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;   -- BUG10772:DRA:23/11/2009
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;   -- BUG10772:DRA:23/11/2009
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_solanulac;

--Fin Bug.: 16775

   /***********************************************************************
     Funcion para determinar si se debe mostrar o no el check Anulacion a corto plazo
    1.   psproduc: Identificador del producto (IN)
    2.   pcmotmov: Motivo de movimiento (IN)
    3.   psseguro: Identificador de la poliza (IN)
    4.   pcvisible: Devuelve 0 si no es visible, 1 si si es visible (OUT)
      return             : NUMBER (0 --> OK)
   ***********************************************************************/
   -- Bug 22826 - APD - 12/07/2012- se crea la funcion
   -- Bug 23817 - APD - 04/10/2012 - se añade el parametro psseguro
   FUNCTION f_aplica_penali_visible(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      psseguro IN NUMBER,
      pcvisible OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.f_aplica_penali_visible';
      vparam         VARCHAR2(4000)
         := 'psproduc = ' || psproduc || ' - pcmotmov = ' || pcmotmov || ' - psseguro = '
            || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_anulaciones.f_aplica_penali_visible(psproduc, pcmotmov, psseguro,
                                                            pcvisible, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_aplica_penali_visible;

   /***********************************************************************
      Procesa la anulación de la póliza comprobando primero si se trata
      de un certificado 0 o no
      param in psseguro  : código de seguro
      param in pctipanul : código tipo de anulación
      param in pfanulac  : fecha anulación
      param in pmotanula : motivo anulación
      param out mensajes : mensajes de error
      param in precextrn default 0 : indica si se debe procesar el extorno
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   ***********************************************************************/
   FUNCTION f_anulacion(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      pfanulac IN DATE,
      pccauanul IN NUMBER,
      pmotanula IN VARCHAR2,
      precextrn IN NUMBER,
      panula_rec IN NUMBER,
      precibos IN VARCHAR2,
      paplica_penali IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pimpextorsion IN NUMBER DEFAULT 0,
      pcommitpag IN NUMBER DEFAULT 1,
      ptraslado IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.F_Anulacion';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pctipanul: ' || pctipanul
            || ' - pfanulac: ' || pfanulac || ' - pccauanul: ' || pccauanul
            || ' - pmotanula: ' || pmotanula || ' - precextrn: ' || precextrn
            || ' - panula_rec: ' || panula_rec || ' - precibos: ' || SUBSTR(precibos, 1, 50)
            || ' - paplica_penali: ' || paplica_penali || ' - pimpextorsion: '
            || pimpextorsion;
      vpasexec       NUMBER(5) := 1;
      Vnumerr        Number(8) := 0;
      Num_Err        Number(8) := 0;
      vadmite        NUMBER;
      vexiste        NUMBER;
      vnpoliza       seguros.npoliza%TYPE;
      vncertif       seguros.ncertif%TYPE;
      vsproduc       seguros.sproduc%TYPE;
      vcempres       seguros.cempres%TYPE;
      vtext          VARCHAR(4000) := NULL;
      psproces       NUMBER;
      indice         NUMBER := 0;
      indice_error   NUMBER := 0;
      pnprolin       NUMBER;
      vnmovimi_out   movseguro.nmovimi%TYPE := NULL;
      vfanulac       DATE;
      --BUG:23817/128727: DCT : 14/11/2012: INICIO
      vsseguro       NUMBER;
      vpermite_anu   NUMBER;
      v_crespue_4092 NUMBER;
      -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias
      t_recibo       t_lista_id := t_lista_id();
      v_sseguro_0    NUMBER;
      v_nmovimi_0    NUMBER;
      v_sproduc      NUMBER;
      v_cempres      NUMBER;
      v_fefecto      DATE;
      -- Bug 26070 - RSC - 08/03/2013
      vrecibosstr    VARCHAR2(2000);
      vcont          NUMBER := 1;
      vcur           sys_refcursor;
      rpend          pac_anulacion.recibos_pend;
      vmarcado       NUMBER;
      vtagente       VARCHAR2(200);
      vttiprec       VARCHAR2(200);
      vitotalr       NUMBER;
      -- Fin Bug 26070
      vrecibosanul   VARCHAR2(2000);
      vrecibosanu_prop VARCHAR2(1000);
      vrecibosanumingas_prop VARCHAR2(1000);

      --BUG:23817/128727: DCT : 14/11/2012: FIN
      CURSOR cur_certif(p_npoliza IN NUMBER) IS
         SELECT   sseguro, npoliza, ncertif
             FROM seguros
            WHERE npoliza = p_npoliza
              -- BUG 0026835 - FAL - 21/11/2013
              --AND csituac <> 2
              AND csituac NOT IN(2, 3)
              -- FI BUG 0026835
              AND NOT(csituac = 4
                      AND creteni IN(3, 4))
              AND ncertif <> 0
         ORDER BY ncertif;

        ---AMA-187 - 15/06/2016-VCG
      CURSOR cur_simul(p_npoliza IN NUMBER) IS
         Select Sseguro
         From Estseguros
         Where Npoliza = P_Npoliza
         And Csituac = 7
         And Ncertif <>0;


      -- Contiene los certificados anulados
      -- cescero = 0.-No es el certificado 0, 1.-Si es el certificado 0
      TYPE rcertificados_anululados IS RECORD(
         sseguro        NUMBER,
         nmovimi        NUMBER,
         cescero        NUMBER
      );

      TYPE certificados_anululados IS TABLE OF rcertificados_anululados
         INDEX BY BINARY_INTEGER;

      certif_anul    certificados_anululados;
      vprecibos_cursor sys_refcursor;
      vpnrecibos     VARCHAR2(2000);
      rec_pend       pac_anulacion.recibos_pend;
      rec_cob        pac_anulacion.recibos_cob;
      vdummy         NUMBER;
      vdummy2        VARCHAR2(150);
      vdummy4        NUMBER;
      vdummy3        VARCHAR2(150);
      v_cont         NUMBER;
      v_pbajacol     NUMBER;

      FUNCTION f_recibos_propios(psseguro IN NUMBER, precibos IN VARCHAR2)
         RETURN VARCHAR2 IS
         vcur           sys_refcursor;
         vquery         VARCHAR2(5000);
         vnrecibo       recibos.nrecibo%TYPE;
         vrecibos       VARCHAR2(10000) := NULL;
      BEGIN
         IF precibos IS NOT NULL THEN
            vquery := 'SELECT r.nrecibo' || ' FROM recibos r' || ' where r.nrecibo in ('
                      || precibos || ')' || ' and r.sseguro = ' || psseguro;

            OPEN vcur FOR vquery;

            FETCH vcur
             INTO vnrecibo;

            WHILE vcur%FOUND LOOP
               IF vrecibos IS NULL THEN
                  vrecibos := vnrecibo;
               ELSE
                  vrecibos := vrecibos || ', ' || vnrecibo;
               END IF;

               FETCH vcur
                INTO vnrecibo;
            END LOOP;
         END IF;

         RETURN vrecibos;
      EXCEPTION
         WHEN OTHERS THEN
            IF vcur%ISOPEN THEN
               CLOSE vcur;
            END IF;

            p_tab_error(f_sysdate, f_user, 'PAC_IAX_ANULACION.f_recibos_propios', 1,
                        'psseguro: ' || psseguro || '; precibos: ' || precibos,
                        SQLCODE || ' - ' || SQLERRM);
            RETURN NULL;
      END f_recibos_propios;

      FUNCTION f_mov_anul_certif(
         psseguro IN NUMBER,
         pcescero IN NUMBER,
         pctipanul IN NUMBER,
         pcertif_anul IN OUT certificados_anululados)
         RETURN NUMBER IS
         vnmovimi       movseguro.nmovimi%TYPE;
         vcont          NUMBER;
      BEGIN
         -- Se busca el movimiento de anulacion que se ha creado
         --IF pctipanul IN(1, 4) THEN
         IF pctipanul IN(1, 4, 5) THEN   --JAMF   33921  23/01/2015
            SELECT MAX(nmovimi)
              INTO vnmovimi
              FROM movseguro
             WHERE sseguro = psseguro
               AND cmovseg = 3;

            vcont := pcertif_anul.COUNT + 1;
            pcertif_anul(vcont).sseguro := psseguro;
            pcertif_anul(vcont).nmovimi := vnmovimi;
            pcertif_anul(vcont).cescero := pcescero;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_IAX_ANULACION.f_mov_anul_certif', 1,
                        'psseguro: ' || psseguro, SQLCODE || ' - ' || SQLERRM);
            RETURN 1000455;   -- Error no controlado.
      END f_mov_anul_certif;

      FUNCTION f_inserta_detmovsegurocol(pcertif_anul IN OUT certificados_anululados)
         RETURN NUMBER IS
         vnumerr        NUMBER;
         vsseguro       seguros.sseguro%TYPE;
         vnmovimi       movseguro.nmovimi%TYPE;
         salir          EXCEPTION;
      BEGIN
         IF pcertif_anul.FIRST IS NOT NULL THEN
            -- se busca la informacion del certificado 0
            FOR i IN pcertif_anul.FIRST .. pcertif_anul.LAST LOOP
               IF pcertif_anul(i).cescero = 1 THEN
                  vsseguro := pcertif_anul(i).sseguro;
                  vnmovimi := pcertif_anul(i).nmovimi;
               END IF;
            END LOOP;

            -- se busca la informacion del resto de certifcados para
            -- registrar la informacion en la tabla detmovsegurocol
            FOR i IN pcertif_anul.FIRST .. pcertif_anul.LAST LOOP
               IF pcertif_anul(i).cescero = 0 THEN
                  vnumerr := pac_seguros.f_set_detmovsegurocol(vsseguro, vnmovimi,
                                                               pcertif_anul(i).sseguro,
                                                               pcertif_anul(i).nmovimi);

                  IF vnumerr <> 0 THEN
                     RAISE salir;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN salir THEN
            p_tab_error(f_sysdate, f_user, 'PAC_IAX_ANULACION.f_inserta_detmovsegurocol', 1,
                        NULL, f_axis_literales(vnumerr, pac_md_common.f_get_cxtidioma()));
            RETURN vnumerr;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_IAX_ANULACION.f_inserta_detmovsegurocol', 1,
                        NULL, SQLCODE || ' - ' || SQLERRM);
            RETURN 1000455;   -- Error no controlado.
      END f_inserta_detmovsegurocol;

      FUNCTION f_trata_mensajes(mensajes IN t_iax_mensajes)
         RETURN VARCHAR2 IS
         vmensaje       VARCHAR2(1000) := NULL;
      BEGIN
         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                  IF vmensaje IS NULL THEN
                     vmensaje := mensajes(i).terror;
                  ELSE
                     vmensaje := vmensaje || '; ' || mensajes(i).terror;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         RETURN vmensaje;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_IAX_ANULACION.f_trata_mensajes', 1, NULL,
                        SQLCODE || ' - ' || SQLERRM);
            RETURN NULL;
      END f_trata_mensajes;

      FUNCTION f_recibos_propios_mingas(psseguro IN NUMBER, precibos IN VARCHAR2)
         RETURN VARCHAR2 IS
         vcur           sys_refcursor;
         vquery         VARCHAR2(5000);
         vnrecibo       recibos.nrecibo%TYPE;
         vrecibos       VARCHAR2(10000) := NULL;
         vcestaux       recibos.cestaux%TYPE;
         vinrecibos     VARCHAR2(1000);
      BEGIN
         vinrecibos := precibos;

         IF vinrecibos IS NOT NULL THEN
            vquery := 'SELECT r.nrecibo, r.cestaux ' || ' FROM recibos r'
                      || ' where r.nrecibo in (' || vinrecibos || ')' || ' and r.sseguro = '
                      || psseguro;

            OPEN vcur FOR vquery;

            FETCH vcur
             INTO vnrecibo, vcestaux;

            WHILE vcur%FOUND LOOP
               IF vcestaux = 0 THEN   -- Si estamos tratando un recibo agrupado (del cero)
                  -- cojemos recibos del cero con cestaux = 2 (prima mínima y gastos)
                  FOR regs IN
                     (SELECT nrecibo, nrecunif
                        FROM adm_recunif
                       WHERE nrecunif = vnrecibo
                         AND nrecibo IN(SELECT nrecibo
                                          FROM recibos
                                         WHERE sseguro = psseguro
                                           AND cestaux = 2
                                           AND pac_seguros.f_get_escertifcero(NULL, psseguro) =
                                                                                              1)) LOOP
                     vinrecibos := vinrecibos || ', ' || regs.nrecibo;
                  END LOOP;
               END IF;

               FETCH vcur
                INTO vnrecibo, vcestaux;
            END LOOP;
         END IF;

         RETURN vinrecibos;
      EXCEPTION
         WHEN OTHERS THEN
            IF vcur%ISOPEN THEN
               CLOSE vcur;
            END IF;

            p_tab_error(f_sysdate, f_user, 'PAC_IAX_ANULACION.f_recibos_propios_mingas', 1,
                        'psseguro: ' || psseguro || '; precibos: ' || precibos,
                        SQLCODE || ' - ' || SQLERRM);
            RETURN NULL;
      END f_recibos_propios_mingas;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL
         OR pctipanul IS NULL
         OR pfanulac IS NULL
         OR pccauanul IS NULL
         OR precextrn IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      -- INI IAXIS-3640  CJMR  17/01/2020
      SELECT count(*) 
        INTO v_cont
        FROM movseguro
       WHERE nmovimi != 1  -- No sea mov. inicial 
         AND cmovseg != 52 -- Mov. no esté anulado
         AND sseguro = psseguro;

      IF v_cont > 0 THEN
         vtext := f_axis_literales(89908013, pac_md_common.f_get_cxtidioma());
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtext);
         RETURN 1;
      END IF;
      -- FIN IAXIS-3640  CJMR  17/01/2020

      vfanulac := pfanulac;

      SELECT npoliza, sproduc, ncertif, cempres
        INTO vnpoliza, vsproduc, vncertif, vcempres
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 3;
      vadmite := NVL(f_parproductos_v(vsproduc, 'ADMITE_CERTIFICADOS'), 0);
      vexiste := pac_seguros.f_get_escertifcero(NULL, psseguro);
      vnumerr := pac_preguntas.f_get_pregunpolseg(psseguro, 4092, 'SEG', v_crespue_4092);
      vpasexec := 4;
      --BUG:23817/128727: DCT : 14/11/2012: INICIO
      vpermite_anu := 0;

      IF vadmite = 1
         AND vexiste = 0
         AND(v_crespue_4092 = 1
             AND vnumerr = 0) THEN   -- admite certificados y no es un certificado 0.
         --debemos obtener el sseguro del certificado 0
         SELECT sseguro
           INTO vsseguro
           FROM seguros
          WHERE npoliza = vnpoliza
            AND ncertif = 0;

         IF pctipanul = 1 THEN   -- Baja al efecto
            SELECT GREATEST(fefecto, pfanulac)
              INTO vfanulac
              FROM seguros
             WHERE sseguro = vsseguro;
         ELSE
            vfanulac := pfanulac;
         END IF;

         vpermite_anu := pac_anulacion.f_valida_permite_anular_poliza(psseguro, vfanulac);

         --9904544 --> No se permite anular la póliza. El Colectivo no está abierto.
         IF vpermite_anu <> 0 THEN
            -- ini BUG 0025033 - 14/12/2012 - JMF
            vtext := f_axis_literales(vpermite_anu, pac_md_common.f_get_cxtidioma());
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtext);
            -- fin BUG 0025033 - 14/12/2012 - JMF
            RETURN 9904544;
         END IF;
      END IF;

      --No se permite anular la póliza con certificado 0
      IF vpermite_anu = 0 THEN
         --BUG:23817/128727: DCT : 14/11/2012: FIN
           -- si el producto admite certificados
           -- y estamos en un certificado 0
         IF vadmite = 1
            AND vexiste = 1 THEN
            vpasexec := 5;
            --BUG 27539 - INICIO - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
            vpermite_anu := pac_anulacion.f_valida_permite_anular_poliza(psseguro, vfanulac);

            --9904544 --> No se permite anular la póliza. El Colectivo no está abierto.
            IF vpermite_anu <> 0 THEN
               -- ini BUG 0025033 - 14/12/2012 - JMF
               vtext := f_axis_literales(vpermite_anu, pac_md_common.f_get_cxtidioma());
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtext);
               -- fin BUG 0025033 - 14/12/2012 - JMF
               RETURN 9904544;
            END IF;

            --BUG 27539 - FIN - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)

            -- se buscan todos los certificados que cuelgan del certificado 0
            -- para validar si están en situación de poder anularse
            -- no se deben tener en cuenta los certificados ya anulados (csituac <> 2)
            vnumerr := 0;   -- BUG 26835 - FAL - 21/11/2013 . Sin certificados con csituac NOT IN (2,3) y sin pregunta 4092 definida, arrastra vnumerr y lanza excepción e_object_error

            FOR reg IN cur_certif(vnpoliza) LOOP
               --IF pctipanul = 1 THEN   -- Baja al efecto
               IF pctipanul in (1,4) THEN   -- Baja al efecto y Baja inmediata KJSC Bug 38847 se verifica y baja al efecto no estaba tomando la fecha mayor del los certificados hijos.
                  SELECT GREATEST(fefecto, pfanulac)
                    INTO vfanulac
                    FROM seguros
                   WHERE sseguro = reg.sseguro;
               ELSE
                  vfanulac := pfanulac;
               END IF;

               vpasexec := 6;
               vnumerr := pac_anulacion.f_valida_permite_anular_poliza(reg.sseguro, vfanulac,
                                                                       0, 1);
               vpasexec := 7;

               -- si la validacion de algun certificado es incorrecta, no parar el proceso,
               -- continuar validando todos los certificados pero dejar registro en procesoslin
               IF vnumerr <> 0 THEN
                  IF vtext IS NULL THEN   -- para que solo muestre este mensaje una vez
                     -- Poliza colectiva. La póliza no se puede anular.
                     vtext := f_axis_literales(102707, pac_md_common.f_get_cxtidioma())
                              || '. '
                              || f_axis_literales(107821, pac_md_common.f_get_cxtidioma());
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtext);
                  END IF;

                  vtext := f_axis_literales(101273, pac_md_common.f_get_cxtidioma()) || ' '
                           || reg.npoliza || '-' || reg.ncertif;
                  vtext := vtext || ': '
                           || f_axis_literales(vnumerr, pac_md_common.f_get_cxtidioma());
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtext);
               END IF;
            END LOOP;

            vpasexec := 8;

            -- no se puede anular algún certificado que cuelga del certificado 0
            -- no continuar entonces con la anulacion
            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;

            -- En reemplazos tenemos que construir la lista de recibos pendeintes
            IF pccauanul = 302
               AND NVL(panula_rec, 0) = 1
               AND pctipanul = 4 THEN
               vnumerr := pac_iax_anulaciones.f_get_recpendientes(psseguro, vfanulac,
                                                                  vprecibos_cursor, mensajes);
               vcont := 1;

               IF vnumerr <> 0 THEN
                  RETURN vnumerr;
               END IF;

               FETCH vprecibos_cursor
                INTO rec_pend(vcont).nrecibo, rec_pend(vcont).fefecto, rec_pend(vcont).fvencim,
                     rec_pend(vcont).fmovini, vdummy, vdummy2, vdummy3, vdummy4;

               WHILE vprecibos_cursor%FOUND LOOP
                  vpnrecibos := vpnrecibos || rec_pend(vcont).nrecibo || ',';
                  vcont := vcont + 1;

                  FETCH vprecibos_cursor
                   INTO rec_pend(vcont).nrecibo, rec_pend(vcont).fefecto,
                        rec_pend(vcont).fvencim, rec_pend(vcont).fmovini, vdummy, vdummy2,
                        vdummy3, vdummy4;
               END LOOP;

               IF INSTR(vpnrecibos, ',') <> 0 THEN
                  vpnrecibos := SUBSTR(vpnrecibos, 1, LENGTH(vpnrecibos) - 1);
               END IF;
            END IF;

            vpasexec := 9;
            --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
            vnumerr := f_procesini(f_user, vcempres,
                                   UPPER(f_axis_literales(104838,
                                                          pac_md_common.f_get_cxtidioma())),
                                   f_axis_literales(9904285, pac_md_common.f_get_cxtidioma()),
                                   psproces);
            -- generar un movimiento de anulación en el certificado cero para poder
            -- registrar la informacion en la tabla detmovsegurocol
            vnumerr := f_movseguro(psseguro, NULL, 345, 3, pfanulac, NULL, NULL, 0, NULL,
                                   vnmovimi_out, NULL, NULL, NULL);

            IF vnumerr = 0 THEN
               vnumerr := f_mov_anul_certif(psseguro, 1, pctipanul, certif_anul);

               IF vnumerr <> 0 THEN
                  pnprolin := NULL;
                  vnumerr := f_proceslin(psproces,
                                         f_axis_literales(vnumerr,
                                                          pac_md_common.f_get_cxtidioma())
                                         || ' ' || TO_CHAR(vnpoliza) || '-'
                                         || TO_CHAR(vncertif),
                                         psseguro, pnprolin, 1);   -- Error;
               END IF;
            ELSE
               pnprolin := NULL;
               vnumerr := f_proceslin(psproces,
                                      f_axis_literales(vnumerr,
                                                       pac_md_common.f_get_cxtidioma())
                                      || ' ' || TO_CHAR(vnpoliza) || '-' || TO_CHAR(vncertif),
                                      psseguro, pnprolin, 1);   -- Error;
            END IF;

            IF pctipanul = 1 THEN
               SELECT GREATEST(fefecto, pfanulac)
                 INTO vfanulac
                 FROM seguros
                WHERE sseguro = psseguro;

               vcur := pac_anulacion.f_recibos(psseguro, vfanulac, 0,
                                               pac_md_common.f_get_cxtidioma, vnumerr, 1, 1);

               IF vnumerr <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               FETCH vcur
                INTO rpend(vcont).nrecibo, rpend(vcont).fefecto, rpend(vcont).fvencim,
                     rpend(vcont).fmovini, vmarcado, vtagente, vttiprec, vitotalr;

               WHILE vcur%FOUND LOOP
                  IF vrecibosstr IS NULL THEN
                     vrecibosstr := TO_CHAR(rpend(vcont).nrecibo);
                  ELSE
                     vrecibosstr := vrecibosstr || ', ' || rpend(vcont).nrecibo;
                  END IF;

                  vcont := vcont + 1;

                  FETCH vcur
                   INTO rpend(vcont).nrecibo, rpend(vcont).fefecto, rpend(vcont).fvencim,
                        rpend(vcont).fmovini, vmarcado, vtagente, vttiprec, vitotalr;
               END LOOP;
            END IF;

            -- se pueden anular todos los certificados que cuelgan del certificado 0
            FOR reg IN cur_certif(vnpoliza) LOOP
              --IF pctipanul = 1 THEN   -- Baja al efecto
              IF pctipanul in (1,4) THEN   -- Baja al efecto y Baja inmediata KJSC Bug 38847 se verifica y baja al efecto no estaba tomando la fecha mayor del los certificados hijos.
                  SELECT GREATEST(fefecto, pfanulac)
                    INTO vfanulac
                    FROM seguros
                   WHERE sseguro = reg.sseguro;
               ELSE
                  vfanulac := pfanulac;
               END IF;

               vpasexec := 10;
               indice := indice + 1;
               vnumerr :=
                  pac_iax_anulaciones.f_anulacion_poliza(reg.sseguro, pctipanul, vfanulac,
                                                         pccauanul, pmotanula, precextrn,
                                                         panula_rec,
                                                         f_recibos_propios(reg.sseguro,
                                                                           precibos),
                                                         paplica_penali, 1, pimpextorsion,
                                                         mensajes, 1, pcommitpag);
               vpasexec := 11;

               IF vnumerr = 0 THEN
                  pnprolin := NULL;
                  vnumerr := f_proceslin(psproces,
                                         f_axis_literales(101483,
                                                          pac_md_common.f_get_cxtidioma())
                                         || ' ' || TO_CHAR(reg.npoliza) || '-'
                                         || TO_CHAR(reg.ncertif),
                                         reg.sseguro, pnprolin, 4);   -- Correcto
                  vnumerr := f_mov_anul_certif(reg.sseguro, 0, pctipanul, certif_anul);

                  IF vnumerr <> 0 THEN
                     pnprolin := NULL;
                     vnumerr :=
                        f_proceslin(psproces,
                                    f_axis_literales(vnumerr, pac_md_common.f_get_cxtidioma())
                                    || ' ' || TO_CHAR(reg.npoliza) || '-'
                                    || TO_CHAR(reg.ncertif),
                                    reg.sseguro, pnprolin, 1);   -- Error;
                  END IF;
               ELSE
                  pnprolin := NULL;
                  vnumerr := f_proceslin(psproces,
                                         f_axis_literales(107821,
                                                          pac_md_common.f_get_cxtidioma())
                                         || ' ' || TO_CHAR(reg.npoliza) || '-'
                                         || TO_CHAR(reg.ncertif) || ': '
                                         || f_trata_mensajes(mensajes),
                                         reg.sseguro, pnprolin, 1);   -- Error;
                  indice_error := indice_error + 1;
               END IF;
            END LOOP;

            -- Se registra en la tabla detmovsegurocol los movimientos
            -- de anulacion que han habido
            vnumerr := f_inserta_detmovsegurocol(certif_anul);

            IF vnumerr = 0 THEN
               IF pcommitpag = 1 THEN
                  COMMIT;
               END IF;
            ELSE
               ROLLBACK;
               pnprolin := NULL;
               vnumerr := f_proceslin(psproces,
                                      f_axis_literales(9904288,
                                                       pac_md_common.f_get_cxtidioma()),
                                      psseguro, pnprolin, 1);   -- Error;
            END IF;

            -- Si se han podido anular correctamente todos los certificados que
            -- cuelgan del certificado 0, entonces ahora se anula el certificado 0
            IF indice_error = 0 THEN
               indice := indice + 1;
               v_pbajacol := 0;

               IF pac_seguros.f_es_col_admin(psseguro, 'SEG') = 1 THEN
                  v_pbajacol := 1;
               END IF;

               IF pctipanul = 1 THEN
                  -- Bug QT:7740 - RSC - 17/06/2013
                  IF pac_seguros.f_es_col_admin(psseguro, 'SEG') = 1 THEN
                     -- Fin Bug QT:7740
                     vrecibosanu_prop := f_recibos_propios(psseguro, vrecibosstr);

                     IF ptraslado = 0 THEN
                        vrecibosanumingas_prop :=
                                               f_recibos_propios_mingas(psseguro, vrecibosstr);
                     END IF;

                     IF vrecibosanu_prop IS NOT NULL
                        AND vrecibosanumingas_prop IS NOT NULL THEN
                        vrecibosanul := vrecibosanu_prop || ', ' || vrecibosanumingas_prop;
                     ELSIF vrecibosanu_prop IS NOT NULL THEN
                        vrecibosanul := vrecibosanu_prop;
                     ELSIF vrecibosanumingas_prop IS NOT NULL THEN
                        vrecibosanul := vrecibosanumingas_prop;
                     ELSE
                        vrecibosanul := NULL;
                     END IF;
                  -- Bug QT:7740 - RSC - 17/06/2013
                  ELSE
                     vrecibosanul := NULL;
                  END IF;

                  -- Fin Bug QT:7740
                  vnumerr := pac_iax_anulaciones.f_anulacion_poliza(psseguro, 4, pfanulac,--vfanulac,KJSC Bug 38847 estaba tomando la fecha de los certificados hijos y no la del padre.
                                                                    pccauanul, pmotanula,
                                                                    precextrn, panula_rec,
                                                                    vrecibosanul,
                                                                    paplica_penali, v_pbajacol,
                                                                    pimpextorsion, mensajes, 0,
                                                                    pcommitpag);

                  -- Despues de anular actualizamos el cmotmov ya que hemos hecho la inmediata
                  UPDATE movseguro
                     SET cmotmov = 306
                   WHERE sseguro = psseguro
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM movseguro
                                     WHERE sseguro = psseguro);
               ELSE
                  --JAMF  33921  23/01/2015Recuperamos la fecha para el caso de que la baja no sea por pantalla
                  --(por pantalla ya se le pasa la fecha calculada) si viene de un fichero de carga la fecha puede no estar bien calculada.
                  IF pctipanul = 5 THEN
                     vfanulac := pac_md_anulaciones.f_get_fanulac(psseguro, pctipanul,
                                                                  mensajes);
                  ELSE
                     vfanulac := pfanulac;
                  END IF;

                  -- Bug QT:7740 - RSC - 17/06/2013
                  IF pac_seguros.f_es_col_admin(psseguro, 'SEG') = 1 THEN
                     -- Fin Bug QT:7740
                     IF pccauanul = 302
                        AND NVL(panula_rec, 0) = 1 THEN
                        vrecibosanu_prop := f_recibos_propios(psseguro, vpnrecibos);
                        vrecibosanumingas_prop :=
                                                f_recibos_propios_mingas(psseguro, vpnrecibos);
                     ELSE
                        vrecibosanu_prop := f_recibos_propios(psseguro, precibos);
                        vrecibosanumingas_prop := f_recibos_propios_mingas(psseguro, precibos);
                     END IF;

                     IF vrecibosanu_prop IS NOT NULL
                        AND vrecibosanumingas_prop IS NOT NULL THEN
                        vrecibosanul := vrecibosanu_prop || ', ' || vrecibosanumingas_prop;
                     ELSIF vrecibosanu_prop IS NOT NULL THEN
                        vrecibosanul := vrecibosanu_prop;
                     ELSIF vrecibosanumingas_prop IS NOT NULL THEN
                        vrecibosanul := vrecibosanumingas_prop;
                     ELSE
                        vrecibosanul := NULL;
                     END IF;
                  -- Bug QT:7740 - RSC - 17/06/2013
                  ELSE
                     vrecibosanul := NULL;
                  END IF;

                  -- Fin bug QT: 7740
                  vnumerr :=
                     pac_iax_anulaciones.f_anulacion_poliza(psseguro, pctipanul,
                                                            --pfanulac, pccauanul,
                                                            vfanulac, pccauanul,   --JAMF 33921  23/01/2015
                                                            pmotanula, precextrn, panula_rec,
                                                            vrecibosanul, paplica_penali,
                                                            v_pbajacol, pimpextorsion,
                                                            mensajes, 0, pcommitpag);
               END IF;

               vpasexec := 11;

               IF vnumerr = 0 THEN
                  pnprolin := NULL;
                  vnumerr := f_proceslin(psproces,
                                         f_axis_literales(101483,
                                                          pac_md_common.f_get_cxtidioma())
                                         || ' ' || TO_CHAR(vnpoliza) || '-'
                                         || TO_CHAR(vncertif),
                                         psseguro, pnprolin, 4);   -- Correcto
               ELSE
                  pnprolin := NULL;
                  vnumerr := f_proceslin(psproces,
                                         f_axis_literales(107821,
                                                          pac_md_common.f_get_cxtidioma())
                                         || ' ' || TO_CHAR(vnpoliza) || '-'
                                         || TO_CHAR(vncertif) || ': '
                                         || f_trata_mensajes(mensajes),
                                         psseguro, pnprolin, 1);   -- Error;
                  indice_error := indice_error + 1;
               END IF;
            END IF;

            -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias
            IF indice_error = 0 THEN
               v_sseguro_0 := psseguro;
               v_nmovimi_0 := vnmovimi_out;

               SELECT s.sproduc, s.cempres, m.fefecto
                 INTO v_sproduc, v_cempres, v_fefecto
                 FROM seguros s, movseguro m
                WHERE s.sseguro = v_sseguro_0
                  AND s.sseguro = m.sseguro
                  AND m.nmovimi = v_nmovimi_0;

               IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                  AND NVL(f_parproductos_v(v_sproduc, 'RECUNIF'), 0) = 1 THEN
                  IF v_crespue_4092 = 1 THEN   -- Administrado
                     FOR tiprec IN (SELECT DISTINCT r.ctiprec
                                               FROM recibos r, detmovsegurocol d
                                              WHERE r.sseguro = d.sseguro_cert
                                                AND r.nmovimi = d.nmovimi_cert
                                                AND d.sseguro_0 = v_sseguro_0
                                                AND d.nmovimi_0 = v_nmovimi_0
                                                AND NOT EXISTS(SELECT a.nrecibo
                                                                 FROM adm_recunif a
                                                                WHERE a.nrecibo = r.nrecibo)
                                    UNION
                                    SELECT DISTINCT r.ctiprec
                                               FROM recibos r
                                              WHERE r.sseguro = v_sseguro_0
                                                AND r.nmovimi = v_nmovimi_0
                                                AND NOT EXISTS(SELECT a.nrecibo
                                                                 FROM adm_recunif a
                                                                WHERE a.nrecibo = r.nrecibo)
                                           ORDER BY ctiprec) LOOP
                        -- Bug 26645 - APD - 08/04/2013 - se añade el cursor PERS para
                        -- tener encuenta los recibos de retorno (para este tipo de recibos
                        -- se debe generar un recibo agrupado por tipo de recibo y persona)
                        t_recibo := NULL;
                        t_recibo := t_lista_id();

                        FOR pers IN (SELECT DISTINCT r.sperson
                                                FROM recibos r, detmovsegurocol d
                                               WHERE r.sseguro = d.sseguro_cert
                                                 AND r.nmovimi = d.nmovimi_cert
                                                 AND r.ctiprec = tiprec.ctiprec
                                                 AND d.sseguro_0 = v_sseguro_0
                                                 AND d.nmovimi_0 = v_nmovimi_0
                                                 AND NOT EXISTS(SELECT a.nrecibo
                                                                  FROM adm_recunif a
                                                                 WHERE a.nrecibo = r.nrecibo)
                                     UNION
                                     SELECT DISTINCT r.sperson
                                                FROM recibos r
                                               WHERE r.sseguro = v_sseguro_0
                                                 AND r.nmovimi = v_nmovimi_0
                                                 AND r.ctiprec = tiprec.ctiprec
                                                 AND NOT EXISTS(SELECT a.nrecibo
                                                                  FROM adm_recunif a
                                                                 WHERE a.nrecibo = r.nrecibo)
                                                 AND NOT EXISTS(SELECT a.nrecunif
                                                                  FROM adm_recunif a
                                                                 WHERE a.nrecunif = r.nrecibo)) LOOP
                           -- fin Bug 26645 - APD - 08/04/2013
                           FOR rec IN (SELECT r.nrecibo
                                         FROM recibos r, detmovsegurocol d
                                        WHERE r.sseguro = d.sseguro_cert
                                          AND r.nmovimi = d.nmovimi_cert
                                          AND r.ctiprec = tiprec.ctiprec
                                          AND NVL(r.sperson, -1) = NVL(pers.sperson, -1)
                                          AND d.sseguro_0 = v_sseguro_0
                                          AND d.nmovimi_0 = v_nmovimi_0
                                          AND NOT EXISTS(SELECT a.nrecibo
                                                           FROM adm_recunif a
                                                          WHERE a.nrecibo = r.nrecibo)
                                       UNION
                                       SELECT r.nrecibo
                                         FROM recibos r
                                        WHERE r.sseguro = v_sseguro_0
                                          AND r.nmovimi = v_nmovimi_0 + 1
                                          AND r.ctiprec = tiprec.ctiprec
                                          AND NVL(r.sperson, -1) = NVL(pers.sperson, -1)
                                          AND NOT EXISTS(SELECT a.nrecibo
                                                           FROM adm_recunif a
                                                          WHERE a.nrecibo = r.nrecibo)
                                          AND NOT EXISTS(SELECT a.nrecunif
                                                           FROM adm_recunif a
                                                          WHERE a.nrecunif = r.nrecibo)) LOOP
                              t_recibo.EXTEND;
                              t_recibo(t_recibo.LAST) := ob_lista_id();
                              t_recibo(t_recibo.LAST).idd := rec.nrecibo;
                           END LOOP;

                           IF t_recibo IS NOT NULL THEN
                              IF t_recibo.COUNT > 0 THEN
                                 vpasexec := 17;
                                 vnumerr := pac_gestion_rec.f_agruparecibo(v_sproduc,
                                                                           v_fefecto,
                                                                           f_sysdate,
                                                                           v_cempres,
                                                                           t_recibo,
                                                                           tiprec.ctiprec, 0,
                                                                           pcommitpag);

                                 IF vnumerr <> 0 THEN
                                    mensajes := NULL;
                                    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                                    RAISE e_object_error;
                                 END IF;
                              END IF;
                           END IF;
                        END LOOP;
                     END LOOP;
                  END IF;
               END IF;
            END IF;

            -- Fin bug 26070
            IF indice_error > 0 THEN
               -- Se eliminan los mensajes que pudiera tener la variable mensajes
               -- para que solo muestre el mensaje Poliza colectiva. La póliza no se puede anular.
               mensajes.DELETE;
               -- Poliza colectiva. La póliza no se puede anular.
               vtext := f_axis_literales(102707, pac_md_common.f_get_cxtidioma()) || '. '
                        || f_axis_literales(107821, pac_md_common.f_get_cxtidioma());
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtext);
            END IF;

            -- Nº Pólizas anuladas: X | Nº de pólizas con errores: X
            vtext := f_axis_literales(9902517, pac_md_common.f_get_cxtidioma()) || ': '
                     || TO_CHAR(indice - indice_error) || ' | '
                     || f_axis_literales(103149, pac_md_common.f_get_cxtidioma()) || ' '
                     || indice_error;
            pnprolin := NULL;
            vnumerr := f_proceslin(psproces, vtext, 0, pnprolin);
            vnumerr := f_procesfin(psproces, indice_error);
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, NULL,
                                              f_axis_literales(9000493,
                                                               pac_md_common.f_get_cxtidioma)
                                              || ' : ' || psproces);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtext);

            IF indice_error > 0 THEN
               RAISE e_object_error;
            ELSE
               IF pcommitpag = 1 THEN
                  COMMIT;
               END IF;
            END IF;
         ELSE
            --JAMF  33921  23/01/2015
            IF pctipanul = 5 THEN
               vfanulac := pac_md_anulaciones.f_get_fanulac(psseguro, pctipanul, mensajes);
            ELSE
               vfanulac := pfanulac;
            END IF;

            vpasexec := 12;
            -- No es un certificado 0
            vnumerr :=
               pac_iax_anulaciones.f_anulacion_poliza(psseguro, pctipanul,
                                                      --pfanulac,
                                                      vfanulac,   --JAMF  33921  23/01/2015
                                                      pccauanul, pmotanula, precextrn,
                                                      panula_rec, precibos, paplica_penali, 0,
                                                      pimpextorsion, mensajes, 0, pcommitpag);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;

            vpasexec := 13;
         END IF;
      End If;
      --AMA-187-16/06/2016-VCG
      --- Valida si borrar simulaciones al producto
      IF Nvl(F_Parproductos_V(V_Sproduc, 'BORRAR_SIMUL'), 0) = 1
          And Vncertif = 0	Then

           Vpasexec := 14;
           For I In Cur_Simul(Vnpoliza) Loop
            Num_Err := Pac_Md_Simulaciones.F_Rechazar_Simul(I.Sseguro,Mensajes);
            If Num_Err <> 0 Then
               Raise e_param_error;
            End If;
           End Loop;
           Vpasexec := 15;
      End If;

     RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_anulacion;
END pac_iax_anulaciones;

/

