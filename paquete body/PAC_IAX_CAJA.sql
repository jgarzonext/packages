CREATE OR REPLACE PACKAGE BODY pac_iax_caja AS
   /*****************************************************************************
      NAME:       PAC_IAX_CAJA
      PURPOSE:   Funciones que gestionan el módulo de CAJA

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        25/03/2013   AFM             1. Creación del package.
      2.0        06/11/2013   CEC             2. 0026295: RSA702-Desarrollar el modulo de Caja
      3.0        03/09/2014   CASANCHEZ       3. 0032665: COLM004-Informar la fecha valor de cambio del pago inicial
      4.0        04/02/2015   MDS             4. 0032674: COLM004-Guardar los importes de recaudo a la fecha de recaudo
      5.0        27/02/2015   JAMF            5. 0034022: RSA300 - Proceso pagos masivo no finaliza (Ejecutarlo como job)
      6.0        17/04/2015   YDA             6. 0033886: Se crea la función f_lee_caja_mov
      7.0        29/04/2015   YDA             7. Se crea de la función f_delmovcaja_spl
      8.0        30/04/2015   YDA             8. Se crea la función f_insmovcaja_apply
      9.0        04/05/2015   YDA             9. Se crea la función f_lee_datmedio_reembolso
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;
   gusuari        VARCHAR2(20) := pac_md_common.f_get_cxtusuario;

   /*************************************************************************
      Obtiene los ficheros pendientes de pagar por el intermediario
      param in cagente   : Codigo del agente
      param out mensajes : mensajes de error
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_lee_pagos_mas_pdtes(
      pcagente agentes.cagente%TYPE,
      pcmoneda monedas.cmonint%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'CAGENTE= ' || pcagente || ' CMONEDA= ' || pcmoneda;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_lee_pagos_mas_pdtes';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_caja.f_lee_pagos_mas_pdtes(pcagente, pcmoneda, mensajes);
      RETURN cur;
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lee_pagos_mas_pdtes;

   /*************************************************************************
      Función que registra el pago por caja y marca en la tabla pagos_masivos
      los ficheros cobrados, si existe autoliquidación registra un apunte en
      la cuenta del Agente.


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_upd_pagos_masivo(
      pcadena IN VARCHAR2,
      pcadforpag IN VARCHAR2,
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psperson IN NUMBER,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      piautliq IN NUMBER,
      pipagsin IN NUMBER,
      pcmoneop IN VARCHAR2,
      piautliqp IN NUMBER DEFAULT NULL,
      pidifcambio IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - : ' || ', psperson: ' || psperson || ', pctipmov: ' || pctipmov
            || ', pimovimi: ' || pimovimi || ', piautliq: ' || piautliq || ', pipagsin: '
            || pipagsin || ', pcmoneop: ' || pcmoneop || ', piautliqp: ' || piautliqp
            || ', pidifcambio: ' || pidifcambio;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_upd_pagos_masivo';
      vcestchq       caja_datmedio.cestchq%TYPE;
   BEGIN
      --Recuperación de los recibos.
--      vnumerr := pac_md_caja.f_upd_pagos_masivo(pcadena, pcadforpag, gempres, gusuari,
--                                                psperson, pctipmov, pimovimi, piautliq,
--                                                pipagsin,
--                                                pac_eco_monedas.f_obtener_cmoneda(pcmoneop),
--                                                piautliqp, pidifcambio, mensajes);

      --JAMF  34022
      vnumerr :=
         pac_md_caja.f_ejecuta_upd_pagos_masivo(pcadena, pcadforpag, gempres, gusuari,
                                                psperson, pctipmov, pimovimi, piautliq,
                                                pipagsin,
                                                pac_eco_monedas.f_obtener_cmoneda(pcmoneop),
                                                piautliqp, pidifcambio, mensajes);

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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         ROLLBACK;
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_upd_pagos_masivo;

   /*************************************************************************
      Obtiene los movimientos asociados a un usuario/fecha
      param in pcusuari  : Codigo del Usuario
      param in pffecmov  : Fecha de los movimientos
      param out mensajes : mensajes de error
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_obtenermvtocaja(
      pcusuari cajamov.cusuari%TYPE,
      pffecmov_ini cajamov.ffecmov%TYPE,
      pffecmov_fin cajamov.ffecmov%TYPE,
      pctipmov cajamov.ctipmov%TYPE,
      pcmedmov caja_datmedio.cmedmov%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'CUSUARI= ' || pcusuari || ' Fecha_INI=' || pffecmov_ini || ' Fecha_fin='
            || pffecmov_fin || ' ctipmov=' || pctipmov || ' cmedmov=' || pcmedmov;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_obtenermvtocaja';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_caja.f_obtenermvtocaja(pcusuari, pffecmov_ini, pffecmov_fin, pctipmov,
                                           pcmedmov, mensajes);
      RETURN cur;
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_obtenermvtocaja;

   /*************************************************************************
      Función que inserta movimientos en caja

      -- Bug 0032660/0190245 - 12/11/2014 - JMF : pcmanual
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_ins_movtocaja(
      psperson IN NUMBER,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      piautliq IN NUMBER,
      pipagsin IN NUMBER,
      pcmoneop IN VARCHAR2,
      pcmedmov IN NUMBER,
      pncheque IN VARCHAR2,
      pcbanco IN NUMBER,
      pccc IN VARCHAR2,
      pctiptar IN NUMBER,
      pntarget IN NUMBER,
      pfcadtar IN VARCHAR2,
      pseqcaja OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pcmanual IN NUMBER DEFAULT 1,
      --BUG 33886/199827
      pcestado IN NUMBER DEFAULT NULL,
      psseguro IN VARCHAR2 DEFAULT NULL,
      psseguro_d IN VARCHAR2 DEFAULT NULL,
      ppamount IN NUMBER DEFAULT NULL,
      pcrazon IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros -  psperson: ' || psperson || ', pctipmov: ' || pctipmov
            || ', pimovimi: ' || pimovimi || ', piautliq: ' || piautliq || ', pipagsin: '
            || pipagsin || ', pcmoneop: ' || pcmoneop || ', pcmedmov: ' || pcmedmov
            || ', pncheque: ' || pncheque || ', pcbanco: ' || pcbanco || ', pccc: ' || pccc
            || ', pctiptar: ' || pctiptar || ', pntarget: ' || pntarget || ', pfcadtar: '
            || pfcadtar || ' pcmanual=' || pcmanual || ' pcestado=' || pcestado
            || ' psseguro=' || psseguro || ' psseguro_d=' || psseguro_d;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_ins_movtocaja';
      --
      vcestchq       caja_datmedio.cestchq%TYPE;
   BEGIN
      IF pcmedmov = 1 THEN
         vcestchq := 1;
      ELSE
         vcestchq := NULL;
      END IF;

      IF (pcmedmov = 4) THEN
         vnumerr := pac_md_persona.f_validaccc(pcbanco, pntarget, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 2;
      --Recuperación de los recibos.
      -- Bug 0032660/0190245 - 12/11/2014 - JMF : pcmanual
      vnumerr :=
         pac_md_caja.f_ins_movtocaja(pcempres => gempres, pcusuari => gusuari,
                                     psperson => psperson, pffecmov => TRUNC(f_sysdate),
                                     pctipmov => pctipmov, pimovimi => pimovimi,
                                     piautliq => piautliq, pipagsin => pipagsin,
                                     pcmoneop => pac_eco_monedas.f_obtener_cmoneda(pcmoneop),
                                     pcmedmov => pcmedmov, pncheque => pncheque,
                                     pcestchq => vcestchq, pcbanco => pcbanco, pccc => pccc,
                                     pctiptar => pctiptar, pntarget => pntarget,
                                     pfcadtar => pfcadtar, pseqcaja => pseqcaja,
                                     mensajes => mensajes, pidifcambio => NULL,
                                     pfcambio => NULL, pcmanual => pcmanual,
                                     pcestado => pcestado, psseguro => psseguro,
                                     psseguro_d => psseguro_d, pcrazon => pcrazon);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN 1;
      END IF;

      COMMIT;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9901094, gidioma));
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_ins_movtocaja;

   /*************************************************************************
      Función captura los datos del agente


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_get_agente(pcagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_get_agente';
      vtmsg          VARCHAR2(4000);
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_caja.f_get_agente(pcagente, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agente;

   /*************************************************************************
      Función que inserta la autoliquidación aplicada en cada fichero


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_ins_det_autliq(
      pcagente IN NUMBER,
      psproces IN NUMBER,
      pcmonope IN NUMBER,
      psproduc IN NUMBER,
      piautliq IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcagente - ' || pcagente || ' psproces - ' || psproces || ' pcmonope - '
            || pcmonope || ' piautliq - ' || piautliq;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_ins_det_autliq';
      vtmsg          VARCHAR2(4000);
   BEGIN
      --Recuperación de los recibos.
      vnumerr := pac_md_caja.f_ins_det_autliq(pcagente, psproces, pcmonope, psproduc,
                                              piautliq, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_ins_det_autliq;

   /*************************************************************************
      Función que inserta el movimiento de Pago Inicial


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_ins_movto_pinicial(
      psperson IN NUMBER,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      psproduc IN NUMBER,
      pcmoneop IN VARCHAR2,
      pcmedmov IN NUMBER,
      pncheque IN VARCHAR2,
      pcbanco IN NUMBER,
      pccc IN VARCHAR2,
      pctiptar IN NUMBER,
      pntarget IN NUMBER,
      pfcadtar IN VARCHAR2,
      pfcambio IN DATE,   --Bug.: 32665 - casanchez - 03/09/2014 - Se añade el nuevo parametro de fecha de pago
      pseqcaja OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      -- Bug 0032660/0190245 - 12/11/2014 - JMF
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros -  psperson: ' || psperson || ', pctipmov: ' || pctipmov
            || ', pimovimi: ' || pimovimi || ', psproduc: ' || psproduc || ', pcmoneop: '
            || pcmoneop || ', pcmedmov: ' || pcmedmov || ', pncheque: ' || pncheque
            || ', pcbanco: ' || pcbanco || ', pccc: ' || pccc || ', pctiptar: ' || pctiptar
            || ', pntarget: ' || pntarget || ', pfcadtar: ' || pfcadtar || ', pfcambio: '
            || pfcambio
                       -- Bug 0032660/0190245 - 12/11/2014 - JMF
            || ', aut: ' || pcautoriza || ', ult: ' || pnultdigtar || ', cuo: ' || pncuotas
            || ', com: ' || pccomercio;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.F_INS_MOVTO_PINICIAL';
      --
      vcestchq       caja_datmedio.cestchq%TYPE;
   BEGIN
      IF pcmedmov = 1 THEN
         vcestchq := 1;
      ELSE
         vcestchq := NULL;
      END IF;

      -- ini Bug 0032660/0190245 - 12/11/2014 - JMF
      /*
      IF (pcmedmov = 4) THEN
         vnumerr := pac_md_persona.f_validaccc(pcbanco, pntarget, mensajes);
         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;
      */
      -- fin Bug 0032660/0190245 - 12/11/2014 - JMF
      vpasexec := 2;
      --Recuperación de los recibos.
      vnumerr := pac_md_caja.f_ins_movto_pinicial(gempres, gusuari, psperson, TRUNC(f_sysdate),
                                                  pctipmov, pimovimi, psproduc,
                                                  pac_eco_monedas.f_obtener_cmoneda(pcmoneop),
                                                  pcmedmov, pncheque, vcestchq, pcbanco, pccc,
                                                  pctiptar, pntarget, pfcadtar, pseqcaja,
                                                  mensajes, pfcambio,
                                                  -- Bug 0032660/0190245 - 12/11/2014 - JMF
                                                  pcautoriza, pnultdigtar, pncuotas,
                                                  pccomercio);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_ins_movto_pinicial;

   /*************************************************************************
      Función que realiza pagos de los recibos seleccionados en pantalla

      param out mensajes : mensajes de error
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   --2.0        06/11/2013   CEC             2. 0026295: RSA702-Desarrollar el modulo de Caja
   FUNCTION f_ins_pagos_rec(
      lista_recibos IN VARCHAR2,
      psperson IN NUMBER,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      piautliq IN NUMBER,
      pipagsin IN NUMBER,
      pcmoneop IN VARCHAR2,
      pcmedmov IN NUMBER,
      pncheque IN VARCHAR2,
      pcbanco IN NUMBER,
      pccc IN VARCHAR2,
      pctiptar IN NUMBER,
      pntarget IN NUMBER,
      pfcadtar IN VARCHAR2,
      pseqcaja OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pfcambio IN DATE DEFAULT NULL,
      pidifcambio IN NUMBER DEFAULT NULL,
      -- Bug 0032660/0190245 - 12/11/2014 - JMF
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;   --maneja el error al insertar el movimiento de caja
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psperson: ' || psperson || ', pctipmov: ' || pctipmov
            || ', pimovimi: ' || pimovimi || ', pcmoneop: ' || pcmoneop || ', pcmedmov: '
            || pcmedmov || ', pncheque: ' || pncheque || ', pcbanco: ' || pcbanco
            || ', pccc: ' || pccc || ', pctiptar: ' || pctiptar || ', pntarget: ' || pntarget
            || ', pfcadtar: ' || pfcadtar || ', pidifcambio: ' || pidifcambio
            || ', pfcambio: ' || pfcambio
                                         -- Bug 0032660/0190245 - 12/11/2014 - JMF
            || ', aut: ' || pcautoriza || ', ult: ' || pnultdigtar || ', cuo: ' || pncuotas
            || ', com: ' || pccomercio;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_ins_pagos_rec';
      --
      vcestchq       caja_datmedio.cestchq%TYPE;
      cant_recibos   NUMBER := 0;
      cont_recibos   NUMBER := 1;
      pctipcob       NUMBER := 3;
      reciboaux      NUMBER := 0;
      importeaux     NUMBER := 0;
      importemon     NUMBER := 0;
      importeins     NUMBER := 0;
      monedaaux      NUMBER := 0;
      lsproduc       seguros.sproduc%TYPE;
      lsseguro       seguros.sseguro%TYPE;
      lcdivisa       productos.cdivisa%TYPE;
      recibo         VARCHAR2(2000);
      lhayctacliente parempresas.nvalpar%TYPE;
      lmonins        monedas.cmoneda%TYPE;
      vn_itasains    eco_tipocambio.itasa%TYPE;
      lrecfemisio    recibos.femisio%TYPE;   -- fecha emisión del recibo
   --
   BEGIN
      --obtengo la cantidad de recibos.
      cant_recibos := LENGTH(lista_recibos) - LENGTH(REPLACE(lista_recibos, '+')) + 1;

      IF cant_recibos = 0 THEN
         RAISE e_object_error;
      END IF;

      IF pcmedmov = 1 THEN
         vcestchq := 1;
      ELSE
         vcestchq := NULL;
      END IF;

      --
      vpasexec := 2;

      --
      IF (pcmedmov = 4) THEN
         vnumerr := pac_md_persona.f_validaccc(pcbanco, pntarget, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      --
      vpasexec := 3;
      --Recuperación de los recibos.
      vnumerr := pac_md_caja.f_ins_movtocaja(gempres, gusuari, psperson, TRUNC(f_sysdate),
                                             pctipmov, pimovimi, piautliq, pipagsin,
                                             pac_eco_monedas.f_obtener_cmoneda(pcmoneop),
                                             pcmedmov, pncheque, vcestchq, pcbanco, pccc,
                                             pctiptar, pntarget, pfcadtar, pseqcaja, mensajes,
                                             pidifcambio, pfcambio);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      --recorro la lista de recibos
      FOR cont_recibos IN 1 .. cant_recibos LOOP
         vpasexec := 45;
         recibo := pac_util.splitt(lista_recibos, cont_recibos, '+');
         reciboaux := pac_util.splitt(recibo, 1, '_');
         monedaaux := pac_util.splitt(recibo, 2, '_');
         lsproduc := pac_util.splitt(recibo, 3, '_');
         lsseguro := pac_util.splitt(recibo, 4, '_');

         BEGIN
            SELECT cdivisa
              INTO lcdivisa
              FROM productos
             WHERE sproduc = lsproduc;
         EXCEPTION
            WHEN OTHERS THEN
               lcdivisa := NULL;
         END;

         --
         BEGIN
            SELECT (r.itotalr
                    -(pac_adm_cobparcial.f_get_importe_cobro_parcial(r.nrecibo, NULL, NULL))),
                   pac_monedas.f_round
                            (((r.itotalr
                               -(pac_adm_cobparcial.f_get_importe_cobro_parcial(r.nrecibo,
                                                                                NULL, NULL)))
                              * pac_eco_tipocambio.f_cambio
                                                           (pac_monedas.f_cmoneda_t(lcdivisa),
                                                            pac_monedas.f_cmoneda_t(monedaaux),
                                                            NVL(pfcambio, TRUNC(f_sysdate)))),
                             monedaaux)
              INTO importeaux,
                   importemon
              FROM vdetrecibos r
             WHERE nrecibo = reciboaux;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         --
         pac_ctacliente.ggrabar := 0;
	 -- INI -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos parámetros en null
         vnumerr := pac_md_adm_cobparcial.f_cobro_parcial_recibo(reciboaux, pctipcob,
                                                                 importeaux, monedaaux,
                                                                 mensajes,null,null,null,null);
         -- FIN -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos parámetros en null
         pac_ctacliente.ggrabar := 1;
         vpasexec := 5;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         --
         lhayctacliente := NVL(f_parproductos_v(lsproduc, 'HAYCTACLIENTE'), 0);

         --
         IF lhayctacliente = 1 THEN
            lmonins := f_parinstalacion_n('MONEDAINST');

            IF lmonins <> lcdivisa THEN
               vpasexec := 6;
               vn_itasains := pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(lcdivisa),
                                                          pac_monedas.f_cmoneda_t(lmonins),
                                                          NVL(pfcambio, TRUNC(f_sysdate)));

               IF vn_itasains IS NULL THEN
                  vnumerr := 9902592;
                  RAISE e_param_error;
               -- No se ha encontrado el tipo de cambio entre monedas
               END IF;
            ELSE
               vn_itasains := 1;
            END IF;

            -- Calcular el importe en moneda instalacion
            IF lcdivisa <> lmonins THEN
               vpasexec := 190;
               importeins := pac_monedas.f_round(importeaux * vn_itasains, lmonins);
            ELSE
               importeins := importeaux;
            END IF;

            --
            vnumerr := pac_ctacliente.f_ins_movpatctacli(gempres, NULL, lsseguro, lsproduc,
                                                         importeaux, monedaaux, importemon,
                                                         importeins, TRUNC(f_sysdate),
                                                         reciboaux, pseqcaja, pfcambio);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;

            vpasexec := 7;

            -- fecha emisión del recibo
            SELECT TRUNC(femisio)
              INTO lrecfemisio
              FROM recibos
             WHERE nrecibo = reciboaux;

            -- si la fecha de cambio es diferente a la fecha de emisión del recibo
            IF NVL(pfcambio, TRUNC(f_sysdate)) <> lrecfemisio THEN
               --
               vpasexec := 8;
               vnumerr :=
                  pac_adm_cobparcial.f_set_detmovrecibo
                                         (reciboaux,   -- nrecibo
                                          NULL,   -- psmovrec
                                          NULL,   -- pnorden
                                          importeaux,   -- piimporte (en moneda del producto)
                                          NULL,   -- pfmovimi
                                          NULL,   -- pfefeadm
                                          NULL,   -- pcusuari
                                          NULL,   -- psdevolu
                                          NULL,   -- pnnumnlin
                                          NULL,   -- pcbancar1
                                          NULL,   -- pnnumord
                                          NULL,   -- psmovrecr
                                          NULL,   -- pnordenr
                                          pseqcaja,   -- ptdescrip,
                                          importeins,   -- piimpmon (en moneda de la instalación)
                                          NULL,   --psproces,
                                          NULL,   --vimoncon,
                                          vn_itasains, NVL(pfcambio, TRUNC(f_sysdate)));

               IF vnumerr <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;

         --
         vpasexec := 9;
      --
      END LOOP;

      --
      vpasexec := 10;
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, recibo);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, recibo);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_ins_pagos_rec;

   /*************************************************************************
      Función que lee el sobrante de un agente/fichero

      param out mensajes : mensajes de error
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_lee_sobrante(
      pcagente IN NUMBER,
      ptfichero IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente= ' || pcagente || ' ptfichero=' || ptfichero;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_lee_sobrante';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_caja.f_lee_sobrante(pcagente, ptfichero, mensajes);
      RETURN cur;
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lee_sobrante;

   /*************************************************************************
      Obtiene los ficheros pendientes de pagar por el partner
      param in cagente   : Codigo del agente
      param out mensajes : mensajes de error
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_lee_pagos_pdtes(pcagente agentes.cagente%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'CAGENTE= ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_lee_pagos_pdtes';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_caja.f_lee_pagos_pdtes(pcagente, mensajes);
      RETURN cur;
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lee_pagos_pdtes;

   /*************************************************************************
      Función que genera la devolución del sobrante


   *************************************************************************/
   FUNCTION f_ins_devolucion(pcadena IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros  pcadena: ' || pcadena;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_ins_devolucion';
      vtmsg          VARCHAR2(4000);
      v_i            NUMBER := 0;
      registro       VARCHAR(50);
      caracter       CHAR;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_md_caja.f_ins_devolucion(pcadena, mensajes);
      vpasexec := 2;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_ins_devolucion;

    /*************************************************************************
      Recupera descripción de detvalores
      param in clave        : código de la tabla
      param in valor        : código del valor a recuperar
      param in out mensajes : mesajes de error
      return                : descripción del valor
   *************************************************************************/
   FUNCTION f_getdescripvalores(clave IN NUMBER, valor IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      RESULT         VARCHAR2(100);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'clave=' || clave || ' valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES.F_GetDescripValores';
   BEGIN
      RESULT := pac_md_listvalores.f_getdescripvalores(clave, valor, mensajes);
      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_getdescripvalores;

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   /*************************************************************************
      Función que inserta apuntes manuales en caja
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_apuntemanual(
      pctipmov IN NUMBER,
      pcusuari1 IN VARCHAR2,
      pcusuari2 IN VARCHAR2,
      pcmoneop IN VARCHAR2,
      pimovimi IN NUMBER,
      pffecmov IN DATE,
      ptmotapu IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 't=' || pctipmov || ' 1=' || pcusuari1 || ' 2=' || pcusuari2 || ' m=' || pcmoneop
            || ' i=' || pimovimi || ' f=' || pffecmov || ' t=' || ptmotapu;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_apuntemanual';
   --
   BEGIN
      vpasexec := 2;
      vnumerr := pac_md_caja.f_apuntemanual(pctipmov, pcusuari1, pcusuari2, pcmoneop,
                                            pimovimi, pffecmov, ptmotapu, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RETURN 1;
      END IF;

      COMMIT;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9901094, gidioma));
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_apuntemanual;

   --INI BUG 32661:NSS:03/11/2014
    /*************************************************************************
       Valida valor ingresado
       param in nrefdeposito        : numero de deposito
       param in iimpins        : importe
       param in out mensajes : mesajes de error
       return                : descripción del valor
    *************************************************************************/
   FUNCTION f_valida_valor_ingresado(
      pnrefdeposito IN NUMBER,
      pimovimi IN NUMBER,
      pcmoneop IN VARCHAR2,
      pconfirm OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pnrefdeposito=' || pnrefdeposito || ' pimovimi=' || pimovimi || ' pcmoneop='
            || pcmoneop;
      vobject        VARCHAR2(200) := 'pac_md_caja.f_valida_valor_ingresado';
   BEGIN
      vnumerr := pac_md_caja.f_valida_valor_ingresado(pnrefdeposito, pimovimi, pcmoneop,
                                                      pconfirm, mensajes);
      vpasexec := 2;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_valida_valor_ingresado;

   /*************************************************************************
      Obtiene "cheques" y "vales vista" entrados por caja por el propio usuario, con estado "Aceptado", en la moneda seleccionada por
      pantalla y que no estén vinculados con ninguna referencia de depósito anterior, permitiendo su selección para ser incluidos en
      la referencia de depósito
      param in nrefdeposito        : numero de deposito
      param in iimpins        : importe
      param in out mensajes : mesajes de error
      return                : descripción del valor
   *************************************************************************/
   FUNCTION f_get_cheques(
      pnrefdeposito IN NUMBER,
      pimovimi IN NUMBER,
      pcmoneop IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pnrefdeposito= ' || pnrefdeposito || ' pimovimi: ' || pimovimi || ' pcmoneop: '
            || pcmoneop;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_get_cheques';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_caja.f_get_cheques(pnrefdeposito, pimovimi, pcmoneop, mensajes);
      RETURN cur;
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cheques;

   FUNCTION f_confirmadeposito(
      pcmoneop IN NUMBER,
      pimovimi IN NUMBER,
      pnrefdeposito IN NUMBER,
      pcmedmov IN NUMBER,
      pcheques IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcmoneop=' || pcmoneop || ' pimovimi=' || pimovimi || ' pnrefdeposito='
            || pnrefdeposito || ' pcmedmov=' || pcmedmov || ' pcheques=' || pcheques;
      vobject        VARCHAR2(200) := 'pac_iax_caja.f_confirmadeposito';
      vt_info        t_iax_info := t_iax_info();
      vo_info        ob_iax_info;
      lv_appendstring VARCHAR2(4000);
      lv_resultstring VARCHAR2(4000);
      lv_count       NUMBER;
      vresto         VARCHAR2(4000);
      vseq           caja_datmedio.seqcaja%TYPE;
      vnumlin        caja_datmedio.nnumlin%TYPE;
      vselec         NUMBER(1);
   BEGIN
      IF pcheques IS NOT NULL THEN
         lv_appendstring := pcheques;

         BEGIN
            LOOP
               EXIT WHEN NVL(INSTR(lv_appendstring, '#'), -99) < 0;
               lv_resultstring := SUBSTR(lv_appendstring, 1,(INSTR(lv_appendstring, '#') - 1));
               lv_count := INSTR(lv_appendstring, '#') + 1;
               lv_appendstring := SUBSTR(lv_appendstring, lv_count, LENGTH(lv_appendstring));
               vpasexec := 2;

               SELECT TO_NUMBER(SUBSTR(lv_resultstring, 1, INSTR(lv_resultstring, '-') - 1))
                 INTO vseq
                 FROM DUAL;

               vpasexec := 3;

               SELECT SUBSTR(lv_resultstring, INSTR(lv_resultstring, '-') + 1)
                 INTO vresto
                 FROM DUAL;

               vpasexec := 4;

               SELECT SUBSTR(vresto, 1, INSTR(vresto, '-') - 1)
                 INTO vnumlin
                 FROM DUAL;

               vpasexec := 5;

               SELECT SUBSTR(vresto, INSTR(vresto, '-') + 1)
                 INTO vselec
                 FROM DUAL;

               vpasexec := 6;
               p_control_error('nuria', vobject,
                               'vseq: ' || vseq || ' vnumlin: ' || vnumlin || ' vselec: '
                               || vselec);
               vo_info := ob_iax_info();
               vo_info.nombre_columna := vseq;
               vo_info.valor_columna := vnumlin;
               vo_info.seleccionado := vselec;
               vt_info.EXTEND;
               vt_info(vt_info.LAST) := vo_info;
            END LOOP;
         END;
      END IF;

      vnumerr := pac_md_caja.f_confirmadeposito(pcmoneop, pimovimi, pnrefdeposito, pcmedmov,
                                                vt_info, mensajes);
      vpasexec := 7;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 8;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_confirmadeposito;

--FIN BUG 32661:NSS:03/11/2014

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   /*************************************************************************
      Obtener comercio del agente asignado al usuario
      param in pcusuari     : usuario
      param out pcomercio   : comercio
      param in out mensajes : mesajes de error
      return                : descripción del valor
   *************************************************************************/
   FUNCTION f_comercio_usuario(pcomercio OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := '';
      vobject        VARCHAR2(200) := 'pac_md_caja.f_comercio_usuario';
   BEGIN
      vpasexec := 2;
      vnumerr := pac_md_caja.f_comercio_usuario(f_user, pcomercio, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_comercio_usuario;

--Bug 33886/199825 ACL
 /******************************************************************************
      NOMBRE:     F_UPDATE_CAJA
      PROPÓSITO:  Funcion que realiza un update de los campos CAJA_DATMEDIO.CESTCHE
                  y CAJA_DATMEDIO.FAUTORI.
      param in out mensajes : mesajes de error
      return                : descripción del valor
    *****************************************************************************/
   FUNCTION f_update_caja(pseqcaja IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'PSEQCAJA = ' || pseqcaja;
      vobject        VARCHAR2(200) := 'pac_md_caja.f_update_caja ';
   BEGIN
      vpasexec := 2;
      vnumerr := pac_md_caja.f_update_caja(pseqcaja, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_update_caja;

   -- Bug 33886/202377 - 16/04/2015
   -- Functión que devuelve un cursor con los movimientos de caja
   FUNCTION f_lee_cajamov(
      psseguro IN seguros.sseguro%TYPE,
      pseqcaja IN cajamov.seqcaja%TYPE,
      pstatus IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
          := 'pseqcaja : ' || pseqcaja || ' psseguro: ' || psseguro || ' pstatus: ' || pstatus;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_lee_cajamov';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_caja.f_lee_cajamov(psseguro, pseqcaja, pstatus, mensajes);
      RETURN cur;
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lee_cajamov;

   -- Bug 33886/202377 - 04/05/2015
   -- Función que devuelve datos de datmedio para la pantalla de reembolso
   FUNCTION f_lee_datmedio_reembolso(
      psseguro IN caja_datmedio.sseguro%TYPE,
      psperson IN cajamov.sperson%TYPE,
      pcestado IN caja_datmedio.cestado%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8);
      vparam         VARCHAR2(2000) := 'psseguro = ' || psseguro || ' pcestado = ' || pcestado;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_lee_datmedio_reembolso';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_caja.f_lee_datmedio_reembolso(psseguro, psperson, pcestado, mensajes);
      RETURN cur;
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lee_datmedio_reembolso;

   --JCP
   FUNCTION f_insmovcaja_spl(
      pcempres NUMBER,
      psseguro NUMBER,
      pimporte NUMBER,
      --v_seqcaja,   --pseqcaja IN NUMBER,
      pncheque IN VARCHAR2 DEFAULT NULL,
      --el número de cheque puede venir de parametro
      pcestchq IN NUMBER DEFAULT NULL,   --el estado del cheque
      pcbanco IN NUMBER DEFAULT NULL,
--si el pago fue porque el cliente acreditó a una cuenta bancaria, el codigo del banco
      pccc IN VARCHAR2 DEFAULT NULL,   --el número de cuenta
      pctiptar IN NUMBER DEFAULT NULL,
      --si fuera por tarjeta de credito el tipo de la tarjeta
      pntarget IN NUMBER DEFAULT NULL,
      --el número de la tarjeta de crédito
      pfcadtar IN VARCHAR2 DEFAULT NULL,
                                         --cuando caduca la tarjeta de crédito
      --100,   --pimovimi IN NUMBER,     --el importe del movimiento
      pcmedmov IN NUMBER DEFAULT NULL,   -->detvalores 841
      pcmoneop IN NUMBER DEFAULT 1,
--> 1 EUROS  moneda en que se realiza la operación, debo convertir de esa moneda a la moneda del producto para ver si puedo pagar el recibo
      pnrefdeposito IN NUMBER DEFAULT NULL,   -->referencia del depósito
      pcautoriza IN NUMBER DEFAULT NULL,
      -->codigo de autorización si fuera tarjeta de crédito
      pnultdigtar IN NUMBER DEFAULT NULL,
      -->cuatro últimos dígitos de la tarjeta de crédito
      pncuotas IN NUMBER DEFAULT NULL,   -->no aplica para msv
      pccomercio IN NUMBER DEFAULT NULL,
      --BUG 33886/199827 -JCP
      pcestado IN NUMBER DEFAULT 3,
      psseguro_d IN NUMBER DEFAULT NULL,
      pcrazon IN NUMBER DEFAULT NULL,
      pseqcaja_o NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_insmovcaja_spl';
   BEGIN
      vnumerr :=
         pac_md_caja.f_insmovcaja_spl
                             (pcempres, psseguro, pimporte,
                              --v_seqcaja,   --pseqcaja IN NUMBER,
                              pncheque,   --el número de cheque puede venir de parametro
                              pcestchq,   --el estado del cheque
                              pcbanco,
--si el pago fue porque el cliente acreditó a una cuenta bancaria, el codigo del banco
                              pccc,   --el número de cuenta
                              pctiptar,   --si fuera por tarjeta de credito el tipo de la tarjeta
                              pntarget,   --el número de la tarjeta de crédito
                              pfcadtar,   --cuando caduca la tarjeta de crédito
                              --100,   --pimovimi IN NUMBER,     --el importe del movimiento
                              pcmedmov,   -->detvalores 841
                              pcmoneop,
--> 1 EUROS  moneda en que se realiza la operación, debo convertir de esa moneda a la moneda del producto para ver si puedo pagar el recibo
                              pnrefdeposito,   -->referencia del depósito
                              pcautoriza,   -->codigo de autorización si fuera tarjeta de crédito
                              pnultdigtar,   -->cuatro últimos dígitos de la tarjeta de crédito
                              pncuotas,   -->no aplica para msv
                              pccomercio,
                              --BUG 33886/199827 -JCP
                              pcestado, psseguro_d, pcrazon, pseqcaja_o, psperson, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN 1;
      END IF;

      --
      COMMIT;
      --
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_insmovcaja_spl;

   --Obtiene la suma de recibos de caja de reembolsos msv - JCP
   FUNCTION f_get_suma_caja(
      psseguro IN seguros.sseguro%TYPE,
      psperson IN per_detper.sperson%TYPE,
      pcestado IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
            := 'psseguro=' || psseguro || ' psperson=' || psperson || ' pcestado=' || pcestado;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_get_suma_caja';
   BEGIN
      vpasexec := 2;
      vnumerr := pac_md_caja.f_get_suma_caja(psseguro, psperson, pcestado, mensajes);

      IF vnumerr = 102555 THEN
         RAISE e_object_error;
      END IF;

        /* IF vnumerr = 102555 THEN
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN 1;
      END IF;*/
      RETURN vnumerr;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                              f_axis_literales(9901094, gidioma));
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_suma_caja;

   -- Función que borra de caja_detmedio
   FUNCTION f_delmovcaja_spl(
      psseguro IN caja_datmedio.sseguro%TYPE,
      pseqcaja IN caja_datmedio.seqcaja%TYPE,
      pnnumlin IN caja_datmedio.nnumlin%TYPE,
      pcestado IN caja_datmedio.cestado%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psseguro = ' || psseguro || ' pseqcaja = ' || pseqcaja || ' pnnumlin = '
            || pnnumlin || ' pcestado: ' || pcestado;
      terror         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_delmovcaja_spl';
      num_err        axis_literales.slitera%TYPE := 0;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pseqcaja IS NULL
         OR pnnumlin IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_md_caja.f_delmovcaja_spl(psseguro, pseqcaja, pnnumlin, pcestado, mensajes);

      IF num_err != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9901094, gidioma));
      RETURN num_err;
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
   END f_delmovcaja_spl;

   -- Función que cambia el estado de las transacciones de una caja
   FUNCTION f_insmovcaja_apply(
      psseguro IN caja_datmedio.sseguro%TYPE,
      psperson IN cajamov.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro = ' || psseguro || ' psperson = ' || psperson;
      terror         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_insmovcaja_apply';
      num_err        axis_literales.slitera%TYPE := 0;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_md_caja.f_insmovcaja_apply(psseguro, psperson, mensajes);

      IF num_err != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9901094, gidioma));
      COMMIT;
      RETURN num_err;
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
   END f_insmovcaja_apply;

   --Funcion aprueba caja
   FUNCTION f_aprueba_caja_spl(
      psseguro IN caja_datmedio.sseguro%TYPE,
      psperson IN cajamov.sperson%TYPE,
      pseqcaja IN cajamov.seqcaja%TYPE,
      pautoriza IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8);
      vparam         VARCHAR2(2000)
         := 'psseguro = ' || psseguro || ' psperson = ' || psperson || ' pseqcaja = '
            || pseqcaja;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_aprueba_caja_spl';
      num_err        NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pseqcaja IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_md_caja.f_aprueba_caja_spl(psseguro, psperson, pseqcaja, pautoriza,
                                                mensajes);

      IF num_err != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9901094, gidioma));
      COMMIT;
      RETURN num_err;
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
   END f_aprueba_caja_spl;
END pac_iax_caja;
/
