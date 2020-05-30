--------------------------------------------------------
--  DDL for Package Body PAC_MD_CAJA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CAJA" AS
   /*****************************************************************************
      NAME:       pac_md_caja
      PURPOSE:    Funciones de obtención de datos del modulo de CAJA

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        25/02/2013   AFM             1. Creación del package.
      2.0        26/02/2015   JAMF            2. 0034022: RSA300 - Proceso pagos masivo no finaliza (Ejecutarlo como job)
      3.0        16/04/2015   YDA             3. Se crea la función f_lee_cajamov
      4.0        29/04/2015   YDA             4. Se crea de la función f_delmovcaja_spl
      5.0        30/04/2015   YDA             5. Se crea la función f_insmovcaja_apply
      6.0        04/05/2015   YDA             6. Se crea la función f_lee_datmedio_reembolso
      7.0        25/06/2015   MMS             7. 0032660: COLM004-Permitir el pago por caja con tarjeta

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;

   /*************************************************************************
      Extrae los registros de los ficheros que se han cargado previamente
      y aún están pendientes de pago.


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_lee_pagos_mas_pdtes(
      pcagente agentes.cagente%TYPE,
      pcmoneda monedas.cmonint%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'CAGENTE= ' || pcagente;
      vobject        VARCHAR2(200) := 'pac_md_caja.f_lee_pagos_mas_pdtes';
      cur            sys_refcursor;
      cur1           sys_refcursor;
      vsproces       pagos_masivos.sproces%TYPE;
      vfcarga        pagos_masivos.fcarga%TYPE;
      vtfichero      pagos_masivos.tfichero%TYPE;
      vsproduc       pagos_masivos.sproduc%TYPE;
      viimppro       pagos_masivos.iimppro%TYPE;
      viimpopeori    pagos_masivos.iimpope%TYPE;
      vcmoneop       pagos_masivos.cmoneop%TYPE;
      vcmoneop2      pagos_masivos.cmoneop%TYPE;
      vcmonint       eco_codmonedas.cmoneda%TYPE;
      vcmonint2      eco_codmonedas.cmoneda%TYPE;
      viimpope       pagos_masivos.iimpope%TYPE;
      vcagente       pagos_masivos.cagente%TYPE;
      vtagente       VARCHAR2(200);
      vinformat      NUMBER(1) := 0;
      vmoneprod      NUMBER;
      viimptot       NUMBER;
      vcdivisa       monedas.cmonint%TYPE;
   BEGIN
      BEGIN
         SELECT cmoneda
           INTO vmoneprod
           FROM monedas
          WHERE cmonint = pcmoneda
            AND cidioma = gidioma;

         vpasexec := 3;
         cur := pac_caja.f_lee_pagos_mas_pdtes(pcagente, vmoneprod);
         vpasexec := 4;
         cur1 := cur;

         LOOP
            FETCH cur
             INTO vsproces, vfcarga, vcagente, vtfichero, vsproduc, vcdivisa, viimppro,
                  viimpopeori, vcmoneop, vcmoneop2, vcmonint, vcmonint2, viimpope, vtagente,
                  viimptot;

            EXIT WHEN cur%NOTFOUND;

            IF viimpope = 0
               AND vinformat <> 1 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9905610);
               vinformat := 1;
            END IF;
         END LOOP;

         CLOSE cur;

         cur := pac_caja.f_lee_pagos_mas_pdtes(pcagente, vmoneprod);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vpasexec := 2;
            --Mensaje no ha encontrado monedas
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905579);
      END;

      vpasexec := 5;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         IF cur%ISOPEN THEN
            CLOSE cur1;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         IF cur%ISOPEN THEN
            CLOSE cur1;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         IF cur%ISOPEN THEN
            CLOSE cur1;
         END IF;

         RETURN cur;
   END f_lee_pagos_mas_pdtes;

   /*************************************************************************
      Función que modifica que se ha pagado el fichero masivo cargado


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
      pcmoneop IN NUMBER,
      piautliqp IN NUMBER DEFAULT NULL,
      pidifcambio IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros -: ' || ', pcempres: ' || pcempres || ', psperson: ' || psperson
            || ', pctipmov: ' || pctipmov || ', pimovimi: ' || pimovimi || ', piautliq: '
            || piautliq || ', pipagsin: ' || pipagsin || ', pcmoneop: ' || pcmoneop
            || ', piautliqp: ' || piautliqp || ', pidifcambio: ' || pidifcambio;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_upd_pagos_masivo';
      vtmsg          VARCHAR2(4000);
      --
      v_pspagmas     NUMBER;
      v_i            NUMBER := 0;
      registro       VARCHAR(50);
      v_importe      NUMBER;
      v_sproces      NUMBER;
      caracter       CHAR;
      pseqcaja       cajamov.seqcaja%TYPE;
      v_cagente_partner agentes.cagente%TYPE;
      v_cagente      agentes.cagente%TYPE;
      v_autoliq      cajamov.iautins%TYPE;
      v_autoliqp     cajamov.iautinsp%TYPE;
      v_sproduc      pagos_masivos.sproduc%TYPE;
      v_ncheque      caja_datmedio.ncheque%TYPE;
      v_ccc          caja_datmedio.ccc%TYPE;
      v_cmedmov      caja_datmedio.cmedmov%TYPE;
      v_cestchq      caja_datmedio.cestchq%TYPE;
      v_cbanco       caja_datmedio.cbanco%TYPE;
      v_numero       caja_datmedio.ncheque%TYPE;   -- Numero Cheque/Cuenta
      vn_monins      monedas.cmoneda%TYPE;
      vn_itasains    eco_tipocambio.itasa%TYPE;
      v_difcambio    pagos_masivos.idifcambio%TYPE;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_caja.f_insmvtocaja(pcempres, pcusuari, psperson, TRUNC(f_sysdate),
                                        pctipmov, pimovimi, pcmoneop, pseqcaja, piautliq,
                                        pipagsin, piautliqp, pidifcambio);
      vpasexec := 2;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --
      -- Se ingresa los medios de pagos
      --
      vpasexec := 3;
      v_i := 0;
      vpasexec := 4;

      FOR x IN 1 .. LENGTH(pcadforpag) LOOP
         caracter := SUBSTR(pcadforpag, x, 1);

         IF caracter = '-' THEN
            v_i := v_i + 1;
         END IF;
      END LOOP;

      --
      vpasexec := 4;

      FOR x IN 2 .. v_i + 1 LOOP
         v_cestchq := NULL;
         v_ncheque := NULL;
         v_cbanco := NULL;
         v_ccc := NULL;

         SELECT pac_util.splitt(pcadforpag, x, '-')
           INTO registro
           FROM DUAL;

         vpasexec := 5;
         v_cmedmov := pac_util.splitt(registro, 1, '_');
         vpasexec := 51;
         v_cbanco := pac_util.splitt(registro, 2, '_');
         vpasexec := 52;
         v_numero := pac_util.splitt(registro, 3, '_');
         vpasexec := 53;
         v_importe := pac_util.splitt(registro, 4, '_');
         vpasexec := 54;
         --
         vpasexec := 6;

         IF v_cmedmov = 0 THEN   -- Efectivo
            v_cestchq := NULL;
            v_ncheque := NULL;
            v_cbanco := NULL;
            v_ccc := NULL;
            vpasexec := 7;
         ELSIF v_cmedmov = 1 THEN   -- cheque
            v_cestchq := 1;
            v_ncheque := v_numero;
            vpasexec := 8;
         ELSIF v_cmedmov = 2 THEN   -- transferencia
            v_cestchq := NULL;
            v_ccc := v_numero;

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         ELSIF v_cmedmov = 3 THEN   -- Vale a la vista (no implementado pantalla)
            v_cestchq := NULL;
         ELSIF v_cmedmov = 4 THEN   -- Tarjeta (no implementado pantalla)
            v_cestchq := NULL;

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 11;
         -- Se genera registro en medios de pago
         vnumerr := pac_caja.f_inscajadatmedio(pseqcaja, v_ncheque, v_cestchq, v_cbanco, v_ccc,
                                               NULL, NULL, NULL, v_importe, v_cmedmov,
                                               pcmoneop);
         vpasexec := 12;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END LOOP;

      vpasexec := 14;
      -- Buscamos la tasa por si nos pagan en otra moneda.
      -- En cuenta agente siempre tiene que ir en moneda instalación
      vn_monins := f_parinstalacion_n('MONEDAINST');
      vpasexec := 15;

      IF vn_monins <> pcmoneop THEN
         vn_itasains := pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(pcmoneop),
                                                    pac_monedas.f_cmoneda_t(vn_monins),
                                                    TRUNC(f_sysdate));
         vpasexec := 16;

         IF vn_itasains IS NULL THEN
            vnumerr := 9902592;
            RAISE e_object_error;
         -- No se ha encontrado el tipo de cambio entre monedas
         END IF;
      ELSE
         vn_itasains := 1;
      END IF;

      --Capturamos los valores de la autoliquidación.
      vpasexec := 17;
      v_i := 0;

      FOR x IN 1 .. LENGTH(pcadena) LOOP
         caracter := SUBSTR(pcadena, x, 1);
         vpasexec := 18;

         IF caracter = '-' THEN
            v_i := v_i + 1;
         END IF;
      END LOOP;

      vpasexec := 19;
      v_i := v_i + 1;

      FOR x IN 2 .. v_i LOOP
         SELECT pac_util.splitt(pcadena, x, '-')
           INTO registro
           FROM DUAL;

         vpasexec := 20;
         v_sproces := pac_util.splitt(registro, 1, '_');
         v_importe := pac_util.splitt(registro, 2, '_');
         v_autoliq := pac_util.splitt(registro, 3, '_');
         v_sproduc := pac_util.splitt(registro, 4, '_');
         v_cagente := pac_util.splitt(registro, 5, '_');
         v_autoliqp := pac_util.splitt(registro, 6, '_');
         v_difcambio := pac_util.splitt(registro, 7, '_');
         -- Autoliquidación Intermediario
         vpasexec := 21;

         IF v_autoliq IS NOT NULL THEN
            vnumerr := pac_md_caja.f_ins_det_autliq(v_cagente, v_sproces, pcmoneop, v_sproduc,
                                                    pac_monedas.f_round(v_autoliq
                                                                        * vn_itasains,
                                                                        vn_monins),
                                                    mensajes);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         --
         END IF;

         vpasexec := 22;

         -- Autoliquidación Partner
         -- Busco el partner del intermediario
         IF v_autoliqp IS NOT NULL THEN
            v_cagente_partner := pac_redcomercial.f_busca_padre(gempres, v_cagente, 7,
                                                                TRUNC(f_sysdate));
            vnumerr := pac_md_caja.f_ins_det_autliq(v_cagente_partner, v_sproces, pcmoneop,
                                                    v_sproduc,
                                                    pac_monedas.f_round(v_autoliqp
                                                                        * vn_itasains,
                                                                        vn_monins),
                                                    mensajes);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         --
         END IF;

         vpasexec := 23;
         --Se pagan los recibos de los ficheros.
         vnumerr := pac_caja.f_upd_pagos_masivo(v_sproces, pseqcaja, v_autoliq, v_autoliqp,
                                                v_difcambio);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 24;

         IF v_importe <> 0 THEN
            BEGIN
               SELECT spagmas
                 INTO v_pspagmas
                 FROM pagos_masivos
                WHERE sproces = v_sproces;

               vpasexec := 25;
               vnumerr := pac_caja.f_ins_sobrante(v_pspagmas, v_importe, 1);

               IF vnumerr <> 0 THEN
                  RAISE e_object_error;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  vnumerr := 108520;
                  RAISE e_object_error;
            END;
         END IF;
      END LOOP;

      --
      vpasexec := 26;
      vtmsg := pac_iobj_mensajes.f_get_descmensaje(9905270, pac_md_common.f_get_cxtidioma);
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg);
      vpasexec := 27;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
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
      vtselect       VARCHAR2(4000);
      vnumerr        NUMBER(4);
   BEGIN
      vnumerr := pac_caja.f_obtenermvtocaja(pcusuari, pffecmov_ini, pffecmov_fin, pctipmov,
                                            pcmedmov, pac_md_common.f_get_cxtidioma(),
                                            vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);
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
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psperson IN NUMBER,
      pffecmov IN DATE,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      piautliq IN NUMBER,
      pipagsin IN NUMBER,
      pcmoneop IN NUMBER,
      pcmedmov IN NUMBER,
      pncheque IN VARCHAR2,
      pcestchq IN NUMBER,
      pcbanco IN NUMBER,
      pccc IN VARCHAR2,
      pctiptar IN NUMBER,
      pntarget IN NUMBER,
      pfcadtar IN VARCHAR2,
      pseqcaja OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pidifcambio IN NUMBER DEFAULT NULL,
      pfcambio IN DATE DEFAULT NULL,
      pcmanual IN NUMBER DEFAULT 1,
      -- Bug 0032660/0190245 - 12/11/2014 - JMF
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL,
      --BUG 33886/199827
      pcestado IN NUMBER DEFAULT NULL,
      psseguro IN VARCHAR2 DEFAULT NULL,
      psseguro_d IN VARCHAR2 DEFAULT NULL,
      pcrazon IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres: ' || pcempres || ', pcusuari: ' || pcusuari
            || ', psperson: ' || psperson || ', pffecmov: ' || pffecmov || ', pctipmov: '
            || pctipmov || ', pimovimi: ' || pimovimi || ', piautliq: ' || piautliq
            || ', pipagsin: ' || pipagsin || ' pcmanual=' || pcmanual
                                                                     -- Bug 0032660/0190245 - 12/11/2014 - JMF
            || ', aut: ' || pcautoriza || ', ult: ' || pnultdigtar || ', cuo: ' || pncuotas
            || ', com: ' || pccomercio;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_ins_movtocaja';
      --
      d_fecini       DATE;
      v_import       cajamov.imovimi%TYPE;
      v_moneda       cajamov.cmoneop%TYPE;

      CURSOR c1 IS
         SELECT   cmoneop
             FROM cajamov a, caja_datmedio b
            WHERE (d_fecini IS NULL
                   OR ffecmov >= d_fecini)
              AND ctipmov IN(0, 1, 2, 3, 4)
              AND cusuari = pcusuari
              --AND a.cmoneop = 11
              AND b.seqcaja = a.seqcaja
              AND b.cmedmov = 0
         GROUP BY cmoneop;
   BEGIN
      vpasexec := 100;

      IF pcautoriza IS NOT NULL
         AND pcautoriza > 9999999 THEN
         vnumerr := 9907238;
         RAISE e_object_error;
      END IF;

      vpasexec := 102;

      IF pnultdigtar IS NOT NULL
         AND(LTRIM(TO_CHAR(3, '0999')) < '0000'
             AND LTRIM(TO_CHAR(3, '0999')) > '9999') THEN
         vnumerr := 180156;
         RAISE e_object_error;
      END IF;

      vpasexec := 104;

      IF pncuotas IS NOT NULL
         AND(pncuotas < 1
             OR pncuotas > 24) THEN
         vnumerr := 9907237;
         RAISE e_object_error;
      END IF;

      vpasexec := 106;

      IF pccomercio IS NOT NULL
         AND pccomercio > 99999999 THEN
         vnumerr := 9907239;
         RAISE e_object_error;
      END IF;

      -- Bug 0032660/0190245 - 12/11/2014 - JMF : saldo automatico -> cierre
      IF pctipmov = 3
         AND pcmanual = 0 THEN
         vpasexec := 110;

         SELECT MAX(ffecmov)
           INTO d_fecini
           FROM cajamov
          WHERE TRUNC(fcierre) = TRUNC(f_sysdate)
            AND cusuari = pcusuari;   -- Bug 0032660 MMS 20150625

         IF d_fecini IS NOT NULL THEN
            -- ya existe el cierre para la fecha
            RETURN 108127;
         END IF;

         vpasexec := 120;

         SELECT MAX(ffecmov)
           INTO d_fecini
           FROM cajamov
          WHERE ctipmov = 3
            AND cmanual = 0
            AND fcierre IS NOT NULL
            AND cusuari = pcusuari;   -- Bug 0032660 MMS 20150625

         vpasexec := 130;

-- Inicio Bug 0032660 MMS 20150625
         /*SELECT SUM(DECODE(ctipmov, 0, iimpins, 0))   -- ingresos,
                - SUM(DECODE(ctipmov, 1, iimpins, 0))   -- pagos,
                - SUM(DECODE(ctipmov, 4, iimpins, 0))   -- deposito
           INTO v_import
           FROM cajamov
          WHERE (d_fecini IS NULL
                 OR ffecmov > d_fecini)
            AND ctipmov IN(0, 1);
            */
         FOR f1 IN c1 LOOP
            SELECT SUM(DECODE(ctipmov, 0, a.imovimi, 0))   -- ingresos,
                   - SUM(DECODE(ctipmov, 1, a.imovimi, 0))   -- pagos,
                   + SUM(DECODE(ctipmov, 2, a.imovimi, 0))   -- Apuntes manuales
                   + SUM(DECODE(ctipmov, 3, a.imovimi, 0))   -- Saldos iniciales
                   - SUM(DECODE(ctipmov, 4, a.imovimi, 0))   -- deposito
              INTO v_import
              FROM cajamov a, caja_datmedio b
             WHERE (d_fecini IS NULL
                    OR ffecmov >= d_fecini)
               AND ctipmov IN(0, 1, 2, 3, 4)
               AND cusuari = pcusuari
               AND b.seqcaja = a.seqcaja
               AND b.cmedmov = 0
               AND cmoneop = f1.cmoneop;

            vpasexec := 140;
            /*SELECT f_parinstalacion_n('MONEDAINST')
              INTO v_moneda
              FROM DUAL;*/
            v_moneda := f1.cmoneop;
-- Fin Bug 0032660 MMS 20150527
            vpasexec := 150;
            vnumerr := pac_caja.f_insmvtocaja(pcempres, pcusuari, psperson, f_sysdate + 1,
                                              pctipmov, v_import, v_moneda, pseqcaja, NULL,
                                              NULL, NULL, pidifcambio, pfcambio, pcmanual);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;

            -- Inserta Datos del medio
            vpasexec := 160;
            vnumerr := pac_caja.f_inscajadatmedio(pseqcaja, pncheque, pcestchq, pcbanco, pccc,
                                                  pctiptar, pntarget, pfcadtar, v_import,
                                                  pcmedmov, v_moneda, NULL, pcautoriza,
                                                  pnultdigtar, pncuotas, pccomercio);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END LOOP;
      ELSE
         -- Inserta movimiento
         -- Bug 0032660/0190245 - 12/11/2014 - JMF : pcmanual
         vpasexec := 170;
         vnumerr := pac_caja.f_insmvtocaja(pcempres, pcusuari, psperson, pffecmov, pctipmov,
                                           pimovimi, pcmoneop, pseqcaja, NULL, NULL, NULL,
                                           pidifcambio, pfcambio, pcmanual);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         -- Inserta Datos del medio
         vpasexec := 180;
         vnumerr := pac_caja.f_inscajadatmedio(pseqcaja, pncheque, pcestchq, pcbanco, pccc,
                                               pctiptar, pntarget, pfcadtar, pimovimi,
                                               pcmedmov, pcmoneop, NULL, pcautoriza,
                                               pnultdigtar, pncuotas, pccomercio);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   FUNCTION f_get_agente(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_get_agente';
      vtmsg          VARCHAR2(4000);
      cur            sys_refcursor;
   BEGIN
      OPEN cur FOR
         SELECT a.*, (SELECT cliquido
                        FROM agentes ag
                       WHERE r.cpadre = ag.cagente) pcliquido
           FROM agentes a, redcomercial r
          WHERE a.cagente = pcagente
            AND a.cagente = r.cagente;

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
      Función que Inserta la autoliquidación por fichero


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_ins_det_autliq(
      pcagente IN NUMBER,
      psproces IN NUMBER,
      pcmonope IN NUMBER,
      psproduc IN NUMBER,
      piautliq IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcagente - ' || pcagente || ' psproces - ' || psproces || ' pcmonope - '
            || pcmonope || ' piautliq - ' || piautliq;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_ins_det_autliq';
      vtmsg          VARCHAR2(4000);
   BEGIN
      --Recuperación de los recibos.
      vnumerr := pac_caja.f_ins_det_autliq(pcagente, psproces, pcmonope, psproduc, piautliq);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

--JAMF  0034022
--      COMMIT;
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
   END f_ins_det_autliq;

   /*************************************************************************
      Función que Inserta el movimiento de caja inicial


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_ins_movto_pinicial(
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psperson IN NUMBER,
      pffecmov IN DATE,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      psproduc IN NUMBER,
      pcmoneop IN NUMBER,
      pcmedmov IN NUMBER,
      pncheque IN VARCHAR2,
      pcestchq IN NUMBER,
      pcbanco IN NUMBER,
      pccc IN VARCHAR2,
      pctiptar IN NUMBER,
      pntarget IN NUMBER,
      pfcadtar IN VARCHAR2,
      pseqcaja OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pfcambio IN DATE,
--Bug.: 32665 - casanchez - 03/09/2014 - Se añade el nuevo parametro de fecha de pago
      -- Bug 0032660/0190245 - 12/11/2014 - JMF
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres: ' || pcempres || ', pcusuari: ' || pcusuari
            || ', psperson: ' || psperson || ', pffecmov: ' || pffecmov || ', pctipmov: '
            || pctipmov || ', pimovimi: ' || pimovimi || ', psproduc: ' || psproduc
            || ', pfcambio: ' || pfcambio
                                         -- Bug 0032660/0190245 - 12/11/2014 - JMF
            || ', aut: ' || pcautoriza || ', ult: ' || pnultdigtar || ', cuo: ' || pncuotas
            || ', com: ' || pccomercio;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_ins_movto_pinicial';
   BEGIN
      -- Bug 0032660/0190245 - 12/11/2014 - JMF
      vpasexec := 100;

      IF pcautoriza IS NOT NULL
         AND pcautoriza > 9999999 THEN
         vnumerr := 9907238;
         RAISE e_object_error;
      END IF;

      vpasexec := 110;

      IF pnultdigtar IS NOT NULL
         AND(LTRIM(TO_CHAR(3, '0999')) < '0000'
             AND LTRIM(TO_CHAR(3, '0999')) > '9999') THEN
         vnumerr := 180156;
         RAISE e_object_error;
      END IF;

      vpasexec := 120;

      IF pncuotas IS NOT NULL
         AND(pncuotas < 1
             OR pncuotas > 24) THEN
         vnumerr := 9907237;
         RAISE e_object_error;
      END IF;

      vpasexec := 130;

      IF pccomercio IS NOT NULL
         AND pccomercio > 99999999 THEN
         vnumerr := 9907239;
         RAISE e_object_error;
      END IF;

      -- Inserta movimiento
      vpasexec := 140;
      vnumerr := pac_caja.f_insmvtocaja(pcempres => pcempres, pcusuari => pcusuari,
                                        psperson => psperson, pffecmov => pffecmov,
                                        pctipmov => pctipmov, pimovimi => pimovimi,
                                        pcmoneop => pcmoneop, pseqcaja => pseqcaja,
                                        pfcambio => pfcambio);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      -- Inserta Datos del medio
      vpasexec := 150;
      vnumerr := pac_caja.f_inscajadatmedio(pseqcaja, pncheque, pcestchq, pcbanco, pccc,
                                            pctiptar, pntarget, pfcadtar, pimovimi, pcmedmov,
                                            pcmoneop, NULL, pcautoriza, pnultdigtar, pncuotas,
                                            pccomercio);
      vpasexec := 160;
      vnumerr := pac_ctacliente.f_ins_pagoinictacli(pcempres, psperson, 0, pffecmov, pimovimi,
                                                    pcmoneop, psproduc, pseqcaja, pfcambio);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 170;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_ins_movto_pinicial;

   FUNCTION f_lee_pagos_pdtes(pcagente agentes.cagente%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'CAGENTE= ' || pcagente;
      vobject        VARCHAR2(200) := 'pac_md_caja.f_lee_pagos_pdtes';
      cur            sys_refcursor;
      vtagente       VARCHAR2(200);
      vinformat      NUMBER(1) := 0;
      vmoneprod      NUMBER;
   BEGIN
      BEGIN
         vpasexec := 1;
         cur := pac_caja.f_lee_pagos_pdtes(pcagente);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vpasexec := 2;
            --Mensaje no ha encontrado monedas
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905579);
      END;

      vpasexec := 5;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

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
      Función que lee el sobrante de pago de ficheros Masivos


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_lee_sobrante(
      pcagente IN NUMBER,
      ptfichero IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente = ' || pcagente || ' ptfichero=' || ptfichero;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_lee_sobrante';
      cur            sys_refcursor;
      vtselect       VARCHAR2(4000);
      vnumerr        NUMBER(4);
   BEGIN
      vnumerr := pac_caja.f_lee_sobrante(pcagente, ptfichero, vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);
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
      Función que inserta el sobrante de un agente/pago Masivos


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_ins_sobrante(pspagmas IN NUMBER, pimporte IN NUMBER, pcmovimi IN NUMBER)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
          := ' pspagmas=' || pspagmas || ' pimporte= ' || pimporte || ' pcmovimi=' || pcmovimi;
      vobject        VARCHAR2(200) := 'pac_md_caja.f_ins_sobrante';
      terror         VARCHAR2(200);
      num_err        axis_literales.slitera%TYPE := 0;
   BEGIN
      num_err := pac_caja.f_ins_sobrante(pspagmas, pimporte, pcmovimi);
      RETURN num_err;
   EXCEPTION
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 102555;   -- error al insertar en ctacliente
   END f_ins_sobrante;

   /*************************************************************************
      Función que inserta devoluciones del sobrante


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_ins_devolucion(pcadena IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros -, pcadena: ' || pcadena;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_ins_devolucion';
      vtmsg          VARCHAR2(4000);
      v_pspagmas     NUMBER;
      v_i            NUMBER := 0;
      registro       VARCHAR(50);
      v_importe      NUMBER;
      v_numlin       NUMBER;
      caracter       CHAR;
   BEGIN
      vpasexec := 1;

      --Calculamos valores sproces y importe
      IF (pcadena IS NULL) THEN
         vtmsg := pac_iobj_mensajes.f_get_descmensaje(9906315, pac_md_common.f_get_cxtidioma);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg);
         RETURN 1;
      END IF;

      FOR x IN 1 .. LENGTH(pcadena) LOOP
         caracter := SUBSTR(pcadena, x, 1);

         IF caracter = '-' THEN
            v_i := v_i + 1;
         END IF;
      END LOOP;

      vpasexec := 2;
      v_i := v_i + 1;
      vpasexec := 3;

      FOR x IN 2 .. v_i LOOP
         SELECT pac_util.splitt(pcadena, x, '-')
           INTO registro
           FROM DUAL;

         v_pspagmas := pac_util.splitt(registro, 1, '_');
         v_numlin := pac_util.splitt(registro, 2, '_');
         v_importe := pac_util.splitt(registro, 3, '_');

         IF v_importe <> 0 THEN
            vnumerr := pac_caja.f_ins_sobrante(v_pspagmas, v_importe, 3);
         END IF;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END LOOP;

      vpasexec := 3;
      vtmsg := pac_iobj_mensajes.f_get_descmensaje(9906319, pac_md_common.f_get_cxtidioma);
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
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
   END f_ins_devolucion;

--
   -- Bug 0032660/0190245 - 12/11/2014 - JMF
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
--      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 't=' || pctipmov || ' 1=' || pcusuari1 || ' 2=' || pcusuari2 || ' m=' || pcmoneop
            || ' i=' || pimovimi || ' f=' || pffecmov || ' t=' || ptmotapu;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_apuntemanual';
      num_err        NUMBER;
      v_terror       VARCHAR2(2000);
      v_seq          cajamov.seqcaja%TYPE;
      v_mon          monedas.cmoneda%TYPE;
   BEGIN
      vpasexec := 100;

      IF pctipmov IS NULL THEN
         v_terror := f_axis_literales(1000591, gidioma) || ' '
                     || f_axis_literales(9905652, gidioma);
         RAISE e_param_error;
      ELSIF pcusuari1 IS NULL THEN
         -- Usuario para el que se realiza el apunte
         v_terror := f_axis_literales(9905999, gidioma) || ' '
                     || f_axis_literales(9905652, gidioma);
         RAISE e_param_error;
      ELSIF pcusuari2 IS NULL THEN
         -- Usuario que realiza el apunte
         v_terror := f_axis_literales(9905557, gidioma) || ' '
                     || f_axis_literales(9905652, gidioma);
         RAISE e_param_error;
      ELSIF pcmoneop IS NULL THEN
         v_terror := f_axis_literales(9902771, gidioma) || ' '
                     || f_axis_literales(9905652, gidioma);
         RAISE e_param_error;
      ELSIF pimovimi IS NULL THEN
         v_terror := f_axis_literales(9904351, gidioma) || ' '
                     || f_axis_literales(9905652, gidioma);
         RAISE e_param_error;
      ELSIF pffecmov IS NULL THEN
         v_terror := f_axis_literales(101006, gidioma) || ' '
                     || f_axis_literales(9905652, gidioma);
         RAISE e_param_error;
      ELSIF pctipmov NOT IN(2, 3) THEN
         v_terror := f_axis_literales(1000591, gidioma) || ' ('
                     || ff_desvalorfijo(482, gidioma, 2) || ' , '
                     || ff_desvalorfijo(482, gidioma, 3) || ')';
         RAISE e_param_error;
      END IF;

      vpasexec := 110;

      SELECT MAX(cmoneda)
        INTO v_mon
        FROM monedas
       WHERE cmonint = pcmoneop;

      IF v_mon IS NULL THEN
         v_terror := f_axis_literales(9902771, gidioma) || ' ' || pcmoneop || ' '
                     || f_axis_literales(1000134, gidioma);
         RAISE e_param_error;
      END IF;

      vpasexec := 120;
      num_err := pac_caja.f_insmvtocaja(gempres, pcusuari1, NULL, pffecmov, pctipmov, pimovimi,
                                        v_mon, v_seq, NULL, NULL, NULL, NULL, NULL, 1,
                                        pcusuari2, ptmotapu);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 130;
      num_err := pac_caja.f_inscajadatmedio(v_seq, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                            pimovimi, 0, v_mon);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, v_terror);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_apuntemanual;

   --BUG 32661:NSS:03/11/2014
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
         := 'parámetros -, pnrefdeposito: ' || pnrefdeposito || ' pimovimi: ' || pimovimi
            || ' pcmoneop: ' || pcmoneop;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_valida_valor_ingresado';
      vtmsg          VARCHAR2(4000);
      v_pspagmas     NUMBER;
      v_i            NUMBER := 0;
      registro       VARCHAR(50);
      v_importe      NUMBER;
      v_numlin       NUMBER;
      caracter       CHAR;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_caja.f_valida_valor_ingresado(pnrefdeposito, pimovimi, pcmoneop,
                                                   pac_md_common.f_get_cxtidioma, pconfirm);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
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
         := 'pnrefdeposito = ' || pnrefdeposito || ' pimovimi=' || pimovimi || ' pcmoneop='
            || pcmoneop;
      vobject        VARCHAR2(200) := 'pac_md_caja.f_get_cheques';
      cur            sys_refcursor;
      vtselect       VARCHAR2(4000);
      vnumerr        NUMBER(4);
   BEGIN
      vnumerr := pac_caja.f_get_cheques(pnrefdeposito, pimovimi, pcmoneop,
                                        pac_md_common.f_get_cxtidioma, vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

--      p_control_error('NURIA', vobject, vparam);
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);
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
      pcheques IN t_iax_info,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros -, pcmoneop: ' || pcmoneop || '  pimovimi: ' || pimovimi
            || ' pnrefdeposito: ' || pnrefdeposito || '  pcmedmov: ' || pcmedmov;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_confirmadeposito';
   BEGIN
      vpasexec := 1;
      vnumerr := pac_caja.f_confirmadeposito(4, f_user, pcmoneop, pimovimi, f_sysdate,
                                             pnrefdeposito, pcmedmov, pcheques);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      -- Proceso finalizado correctamente
      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
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
   FUNCTION f_comercio_usuario(
      pcusuari IN VARCHAR2,
      pcomercio OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'u=' || pcusuari;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_comercio_usuario';
      --
      vret           NUMBER;
   BEGIN
      vpasexec := 1;
      pcomercio := pac_caja.f_comercio_usuario(pcusuari);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_comercio_usuario;

   /*************************************************************************
      Función que modifica que se ha pagado el fichero masivo cargado
      Ejecución mediante job
      --JAMF  0034022
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_ejecuta_upd_pagos_masivo(
      pcadena IN VARCHAR2,
      pcadforpag IN VARCHAR2,
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psperson IN NUMBER,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      piautliq IN NUMBER,
      pipagsin IN NUMBER,
      pcmoneop IN NUMBER,
      piautliqp IN NUMBER DEFAULT NULL,
      pidifcambio IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros -: ' || 'pcaden: ' || pcadena || ', pcadforpag: ' || pcadforpag
            || ', pcempres: ' || pcempres || ', psperson: ' || psperson || ', pctipmov: '
            || pctipmov || ', pimovimi: ' || pimovimi || ', piautliq: ' || piautliq
            || ', pipagsin: ' || pipagsin || ', pcmoneop: ' || pcmoneop || ', piautliqp: '
            || piautliqp || ', pidifcambio: ' || pidifcambio;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_ejecuta_upd_pagos_masivo';
      vtmsg          VARCHAR2(4000);
      vtitulo        axis_literales.tlitera%TYPE;
      vidioma        idiomas.cidioma%TYPE;
      vsproces       procesoscab.sproces%TYPE;
   BEGIN
      SELECT COUNT(1)
        INTO vnumerr
        FROM user_jobs
       WHERE UPPER(what) LIKE '%PAGOS_MASIVOS%';

      IF vnumerr > 0 THEN
         -- Ya existe un proceso de liquidación activo
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905165);
         ---CAMBIAR LITERAL a "Ya existe un proceso de cobro masivo activo"
         RAISE e_object_error;
      END IF;

      vidioma := pac_md_common.f_get_cxtidioma;
      vtitulo := f_axis_literales(9905076, vidioma);   ---  Cobros Masivos
      vnumerr := f_procesini(f_user, pcempres, 'PAGOS_MASIVOS ', vtitulo, vsproces);
      vpasexec := 10;
            /*
      pcadena IN VARCHAR2,
            pcadforpag IN VARCHAR2,
            pcempres IN NUMBER,
            pcusuari IN VARCHAR2,
            psperson IN NUMBER,
            pctipmov IN NUMBER,
            pimovimi IN NUMBER,
            piautliq IN NUMBER,
            pipagsin IN NUMBER,
            pcmoneop IN NUMBER,
            piautliqp IN NUMBER DEFAULT NULL,
            pidifcambio
      */
      --BUG XVM
      vnumerr := pac_jobs.f_ejecuta_job(NULL,
                                        'P_EJECUTAR_COBROS_MASIVOS(' || ' ' || vsproces || ', '
                                        || '''' || pcadena || ''', ' || '''' || pcadforpag
                                        || ''', ' || pcempres || ', ' || '''' || pcusuari
                                        || ''', ' || psperson || ', ' || pctipmov || ', '
                                        || pimovimi || ', ' || NVL(TO_CHAR(piautliq), 'NULL')
                                        || ', ' || NVL(TO_CHAR(pipagsin), 'NULL') || ', '
                                        --|| pipagsin || ', '
                                        --||'NULL'|| ', '              --<-- ¡¡¡¡¡¡¡¡Revisar esto!!!!!!!!!!
                                        || pcmoneop || ', ' || NVL(TO_CHAR(piautliqp), 'NULL')
                                        || ', ' || NVL(TO_CHAR(pidifcambio), 'NULL') || ');',
                                        NULL);

      IF vnumerr > 0 THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || vnumerr);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vnumerr);
         vnumerr := f_procesfin(vsproces, vnumerr);
         RETURN 1;
      END IF;

      vnumerr := f_procesfin(vsproces, vnumerr);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_ejecuta_upd_pagos_masivo;

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
      vnumerr := pac_caja.f_update_caja(pseqcaja);

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
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_lee_cajamov';
      cur            sys_refcursor;
   BEGIN
      BEGIN
         vpasexec := 1;
         cur := pac_caja.f_lee_cajamov(psseguro, pseqcaja, pstatus);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vpasexec := 2;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907889);
      -- No existen movimientos
      END;

      vpasexec := 5;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

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
      vpasexec := 1;

      BEGIN
         cur := pac_caja.f_lee_datmedio_reembolso(psseguro, psperson, pcestado);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vpasexec := 2;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907889);
      -- No existen movimientos
      END;

      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

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
      v_number       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros -, pnrefdeposito: ' || pnrefdeposito || ' pimovimi: ' || pimporte
            || ' pcmoneop: ' || pcmoneop;
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_insmovcaja_spl';
   BEGIN
      vpasexec := 2;
      v_number :=
         pac_caja.f_insmovcaja_spl
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
                              pcestado, psseguro_d, pcrazon, pseqcaja_o, psperson);
      RETURN v_number;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, v_number, vpasexec, vparam);
         RETURN v_number;
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
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_get_suma_caja';
      v_terror       VARCHAR2(2000);
   BEGIN
      --
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      --
      vpasexec := 2;
      --
      vnumerr := pac_caja.f_get_suma_caja(psseguro, psperson, pcestado);

      --
      IF vnumerr = 102555 THEN
         RAISE e_object_error;
      END IF;

      --
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 102555;
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
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_delmovcaja_spl';
      num_err        axis_literales.slitera%TYPE := 0;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pseqcaja IS NULL
         OR pnnumlin IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_caja.f_delmovcaja_spl(psseguro, pseqcaja, pnnumlin, pcestado);

      IF num_err != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

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
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_insmovcaja_apply';
      num_err        axis_literales.slitera%TYPE := 0;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_caja.f_insmovcaja_apply(psseguro, psperson);

      IF num_err != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

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
      vobject        VARCHAR2(200) := 'PAC_MD_CAJA.f_aprueba_caja_spl';
      num_err        NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pseqcaja IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_caja.f_aprueba_caja_spl(psseguro, psperson, pseqcaja, pautoriza);

      IF num_err != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   END f_aprueba_caja_spl;
END pac_md_caja;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CAJA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CAJA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CAJA" TO "PROGRAMADORESCSI";
