--------------------------------------------------------
--  DDL for Package Body PAC_MD_LIQUIDACOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LIQUIDACOR" AS
/******************************************************************************
   NOMBRE:       PAC_MD_LIQUIDACOR
   PROPÓSITO:    Contiene las funciones para la liquidación de comisiones de Correduria

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/11/2010   XPL                1. Creación del package. Bug 16310
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
         Función que nos creará una nueva liquidación, pasándole el mes, año y descripción.
         Nos guardará en persistencia la liquidación inicializada
         param in  p_mes       : Mes de la liquidación
         param in  p_anyo      : Año de la liquidación
         param in  p_tliquida  : Observaciones
         param in out mensajes    : mensajes de error
         return                : 0.-    OK
                                 1.-    KO
          25/11/2010#XPL#16310
     *************************************************************************/
   FUNCTION f_inicializa_liquidacion(
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_ccompani IN NUMBER,
      p_finiliq IN DATE,
      p_ffinliq IN DATE,
      p_importe IN NUMBER,
      p_tliquida IN VARCHAR2,
      pt_liquida OUT t_iax_liquidacion,
      p_sproces OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_squery       VARCHAR2(2000);
      v_cur          sys_refcursor;
      vcestrec       NUMBER;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
           := ' p_mes = ' || p_mes || ',p_anyo = ' || p_anyo || ',p_tliquida = ' || p_tliquida;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDACOR.f_inicializa_liquidacion';
      v_error        NUMBER(8);
      vsproliq       NUMBER;
      vliquida       ob_iax_liquidacion := ob_iax_liquidacion();
      vrecibo        NUMBER;
      vobrecibo      ob_iax_liquida_rec := ob_iax_liquida_rec();
      vcont          NUMBER := 0;
      vsigno         NUMBER := 1;
      esimpago       NUMBER := 0;
      vnrecibo       NUMBER;
      vnoliquida     NUMBER := 1;
      v_finiliq      DATE;
      v_ffinliq      DATE;
      v_smovrec      NUMBER;
      v_cont         NUMBER;
      v_cestrec_ultliq NUMBER;
      ok             NUMBER;
      v_ctiprec      NUMBER;
   BEGIN
      IF p_mes IS NULL
         OR p_anyo IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      v_error := pac_liquidacor.f_valida_propuesta(p_mes, p_anyo, p_ccompani);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      IF p_finiliq > p_ffinliq THEN
         v_error := 101922;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         --//pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, v_error, v_pasexec, v_param);
         RAISE e_object_error;
      ELSE
         v_pasexec := 3;
         pt_liquida := t_iax_liquidacion();
         pt_liquida.EXTEND;

         SELECT sproliq.NEXTVAL
           INTO vsproliq
           FROM DUAL;

         vliquida.sproliq := vsproliq;
         vliquida.cempres := pac_md_common.f_get_cxtempresa;
         p_sproces := vsproliq;

         SELECT tempres
           INTO vliquida.tempres
           FROM empresas
          WHERE cempres = pac_md_common.f_get_cxtempresa;

         vliquida.tliquida := p_tliquida;
         vliquida.fliquida := TO_DATE('01/' || p_mes || '/' || p_anyo, 'DD/MM/YYYY');
         vliquida.ccompani := p_ccompani;

         IF vliquida.ccompani IS NOT NULL THEN
            v_error := f_descompania(vliquida.ccompani, vliquida.tcompani);
         END IF;

         vliquida.finiliq := p_finiliq;
         vliquida.ffinliq := p_ffinliq;
         vliquida.importe := p_importe;
         vliquida.nmovliq := 1;
         vliquida.cestliq := 1;
         vliquida.testliq := ff_desvalorfijo(800030, pac_md_common.f_get_cxtidioma, 1);
         vliquida.itotliq := 0;
         v_pasexec := 4;
         vliquida.movimientos := t_iax_liquida_mov();
         vliquida.movimientos.EXTEND;
         vliquida.movimientos(vliquida.movimientos.LAST) := ob_iax_liquida_mov();
         vliquida.movimientos(vliquida.movimientos.LAST).nmovliq := vliquida.nmovliq;
         vliquida.movimientos(vliquida.movimientos.LAST).cestliq := vliquida.cestliq;
         vliquida.movimientos(vliquida.movimientos.LAST).testliq := vliquida.testliq;
         vliquida.movimientos(vliquida.movimientos.LAST).itotliq := vliquida.itotliq;
         vliquida.movimientos(vliquida.movimientos.LAST).cusualt := f_user;
         vliquida.movimientos(vliquida.movimientos.LAST).falta := f_sysdate;
         v_squery := pac_liquidacor.f_recibos_propuestos(pac_md_common.f_get_cxtempresa, NULL,
                                                         NULL, vliquida.ccompani, NULL, NULL,
                                                         NULL, NULL, NULL, NULL, p_finiliq,
                                                         p_ffinliq, p_mes, p_anyo,
                                                         pac_md_common.f_get_cxtidioma);
         v_pasexec := 5;
         v_cur := pac_md_listvalores.f_opencursor(v_squery, mensajes);
         vliquida.recibos := t_iax_liquida_rec();

         LOOP
            FETCH v_cur
             INTO vnrecibo;

            EXIT WHEN v_cur%NOTFOUND;

            SELECT COUNT(1)
              INTO vcont
              FROM adm_liquida_recibos
             WHERE nrecibo = vnrecibo;

            SELECT cestrec
              INTO vcestrec
              FROM movrecibo
             WHERE fmovfin IS NULL
               AND nrecibo = vnrecibo;

            SELECT ctiprec
              INTO v_ctiprec
              FROM recibos
             WHERE nrecibo = vnrecibo;

            v_pasexec := 6;

            --rebut anulat, liquidat en positiu i que nomes estigui un cop.--> s'ha de liquidar en negatiu
            IF vcont > 0 THEN
               vobrecibo.estaliquidado := 1;
               vnoliquida := 0;

               /*
                               Es mira si un rebut s'ha quedat sense entrar a cap
                               liquidació.
                               Mirem si ha tingut un moviment entre la data de l'ultima
                               liquidació de companyia i la data fi de la liquidació
                               Ja que pot ser que estigui liquidat en un altre liquidacio i tornem a buscar per
                               les mateixes dates
                               */
               SELECT finiliq, ffinliq
                 INTO v_finiliq, v_ffinliq
                 FROM adm_liquida al, adm_liquida_recibos alr
                WHERE al.ccompani = p_ccompani
                  AND al.sproliq = alr.sproliq
                  AND nrecibo = vnrecibo
                  AND alr.sproliq = (SELECT MAX(sproliq)
                                       FROM adm_liquida_recibos
                                      WHERE nrecibo = vnrecibo);

               v_pasexec := 7;

               SELECT MAX(smovrec)
                 INTO v_smovrec
                 FROM movrecibo mr
                WHERE nrecibo = vnrecibo
                  AND mr.fmovini BETWEEN v_finiliq AND v_ffinliq;

               v_pasexec := 8;

               IF v_smovrec IS NOT NULL THEN
                  SELECT cestrec
                    INTO v_cestrec_ultliq
                    FROM movrecibo
                   WHERE nrecibo = vnrecibo
                     AND smovrec = v_smovrec;
               ELSE
                  v_cestrec_ultliq := vcestrec;
               END IF;

               v_pasexec := 9;

               IF v_cestrec_ultliq <> vcestrec THEN
                  --vnoliquida := 1;
                  IF vcestrec IN(2, 0)
                     AND v_cestrec_ultliq IN(2, 0) THEN
                     vnoliquida := 0;
                  ELSE
                     esimpago := f_estimpago(vnrecibo, f_sysdate);

                     IF esimpago <> 0 THEN
                        vnoliquida := 1;
                        vsigno := -1;

                        IF v_ctiprec = 9 THEN
                           vsigno := 1;
                        END IF;
                     ELSIF vcestrec = 2 THEN   --ESTA ANULADO
                        vnoliquida := 1;

                        SELECT SIGN(iliquida) *(-1)
                          INTO vsigno
                          FROM adm_liquida liq, adm_liquida_recibos reb
                         WHERE liq.sproliq = reb.sproliq
                           AND reb.ccompani = liq.ccompani
                           AND nrecibo = vnrecibo
                           AND fliquida = (SELECT MAX(fliquida)
                                             FROM adm_liquida
                                            WHERE sproliq IN(SELECT sproliq
                                                               FROM adm_liquida_recibos reb
                                                              WHERE nrecibo = vnrecibo));

                        IF v_ctiprec = 9 THEN
                           vsigno := 1;
                        END IF;
                     ELSE
                        -- v_cestrec := f_cestrec(p_nrecibo,v_finiliq);
                        IF p_finiliq >= v_finiliq
                           AND p_finiliq <= v_ffinliq THEN
                           IF p_ffinliq > v_ffinliq THEN
                              v_finiliq := v_ffinliq;

                              SELECT COUNT(1)
                                INTO ok
                                FROM movrecibo
                               WHERE fmovfin IS NULL
                                 AND nrecibo = vnrecibo
                                 AND fmovini BETWEEN v_finiliq AND p_ffinliq;

                              IF ok > 0 THEN
                                 vnoliquida := 1;

                                 IF v_ctiprec = 9 THEN
                                    vsigno := -1;
                                 END IF;
                              END IF;
                           END IF;
                        ELSE
                           IF v_ctiprec = 9 THEN
                              vsigno := -1;
                           END IF;

                           vnoliquida := 1;
                        END IF;
                     END IF;
                  END IF;
               ELSE
                  vnoliquida := 0;
               END IF;
            ELSE
               -- vnoliquida := 0;
               esimpago := f_estimpago(vnrecibo, f_sysdate);
               vobrecibo.estaliquidado := 0;

               IF esimpago <> 0
                  OR vcestrec = 2 THEN
                  vnoliquida := 0;
               END IF;

               IF v_ctiprec = 9 THEN
                  vsigno := -1;
               END IF;
            END IF;

            v_pasexec := 10;

            IF vnoliquida = 1 THEN
               vobrecibo.nrecibo := vnrecibo;
               vobrecibo.recibo := pac_md_adm.f_get_datosrecibo_mv(vobrecibo.nrecibo, 0,
                                                                   mensajes);
               v_pasexec := 67;
               vobrecibo.cselecc := 1;
               vobrecibo.poliza := ob_iax_genpoliza();

               SELECT cpolcia, npoliza,
                      f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1,
                                      pac_md_common.f_get_cxtidioma),
                      ccompani, sproduc, cramo
                 INTO vobrecibo.poliza.cpolcia, vobrecibo.poliza.npoliza,
                      vobrecibo.poliza.tproduc,
                      vobrecibo.ccompani, vobrecibo.poliza.sproduc, vobrecibo.poliza.cramo
                 FROM seguros
                WHERE sseguro = vobrecibo.recibo.sseguro;

               --pac_iax_produccion.f_get_datpoliza(vobrecibo.recibo.sseguro,
                                                                      --mensajes);
               IF vobrecibo.ccompani IS NOT NULL THEN
                  v_error := f_descompania(vobrecibo.ccompani, vobrecibo.tcompani);
               END IF;

               IF v_error <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
               END IF;

               v_pasexec := 6;
               vobrecibo.cagente := vobrecibo.recibo.cagente;
               vobrecibo.tagente := vobrecibo.recibo.tagente;
               vobrecibo.cmonseg := NULL;
               -- vtliquida(i).recibos(v_index).recibo.cmonseg;
               vobrecibo.tmonseg := '';
               --vtliquida(i).recibos(v_index).recibo.tmonseg;
               vobrecibo.itotalr := vobrecibo.recibo.importe;
               vobrecibo.icomisi := vobrecibo.recibo.icomisi;
               vobrecibo.iretenc := NULL;
               -- vtliquida(i).recibos(v_index).recibo.iretenc;
               vobrecibo.iprinet := NULL;
               --vtliquida(i).recibos(v_index).recibo.iprinet;
               vobrecibo.iliquida := vobrecibo.recibo.icomisi * vsigno;
               vobrecibo.cgescob := vobrecibo.recibo.cgescob;
               vobrecibo.tgescob := vobrecibo.recibo.tgescob;
               vliquida.itotliq := NVL(vobrecibo.recibo.icomisi, 0) + NVL(vliquida.itotliq, 0);
               vliquida.movimientos(vliquida.movimientos.LAST).itotliq := vliquida.itotliq;
               v_pasexec := 7;
               vliquida.recibos.EXTEND;
               vliquida.recibos(vliquida.recibos.LAST) := vobrecibo;
               vobrecibo := ob_iax_liquida_rec();
            END IF;

            vsigno := 1;
            vnoliquida := 1;
         END LOOP;

         v_pasexec := 8;

         CLOSE v_cur;

         pt_liquida(pt_liquida.LAST) := vliquida;
         v_error := f_set_recliqui(pt_liquida(pt_liquida.LAST), mensajes);

         IF v_error <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
   END f_inicializa_liquidacion;

   /*************************************************************************
       Función que modifica liquidación, pasándole el mes, año y descripción.
       Nos guardará en persistencia la liquidación inicializada
       param in  p_mes       : Mes de la liquidación
       param in  p_anyo      : Año de la liquidación
       param in  p_tliquida  : Observaciones
       param out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
        15/12/2010#JBN#16310
   *************************************************************************/
   FUNCTION f_modifica_liquidacion(
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_ccompani IN NUMBER,
      p_finiliq IN DATE,
      p_ffinliq IN DATE,
      p_importe IN NUMBER,
      p_tliquida IN VARCHAR2,
      p_sproliq IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
           := ' p_mes = ' || p_mes || ',p_anyo = ' || p_anyo || ',p_tliquida = ' || p_tliquida;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDACOR.f_inicializa_liquidacion';
      v_error        NUMBER(8);
      vliquida       ob_iax_liquidacion := ob_iax_liquidacion();
   BEGIN
      IF p_mes IS NULL
         OR p_anyo IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      v_error := pac_liquidacor.f_valida_propuesta(p_mes, p_anyo, p_ccompani, p_sproliq);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
      END IF;

      IF p_finiliq > p_ffinliq THEN
         v_error := 101922;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, v_error, v_pasexec, v_param);
      ELSE
         v_pasexec := 3;

         IF pac_iax_liquidacor.vtliquida IS NOT NULL
            AND pac_iax_liquidacor.vtliquida.COUNT > 0 THEN
            FOR i IN pac_iax_liquidacor.vtliquida.FIRST .. pac_iax_liquidacor.vtliquida.LAST LOOP
               IF pac_iax_liquidacor.vtliquida(i).sproliq = p_sproliq THEN
                  pac_iax_liquidacor.vtliquida(i).finiliq := p_finiliq;
                  pac_iax_liquidacor.vtliquida(i).ffinliq := p_ffinliq;
                  pac_iax_liquidacor.vtliquida(i).importe := p_importe;
                  pac_iax_liquidacor.vtliquida(i).tliquida := p_tliquida;
                  pac_iax_liquidacor.vtliquida(i).ccompani := p_ccompani;
                  pac_iax_liquidacor.vtliquida(i).fliquida :=
                                        TO_DATE('01/' || p_mes || '/' || p_anyo, 'DD/MM/YYYY');
                  v_error := f_set_recliqui(pac_iax_liquidacor.vtliquida(i), mensajes);

                  IF v_error <> 0 THEN
                     RAISE e_object_error;
                  END IF;

                  RETURN 0;
               END IF;
            END LOOP;
         END IF;

         v_pasexec := 4;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_modifica_liquidacion;

   /*************************************************************************
      Función que cargará el  objecto liquidacion con sus movimientos y recibos buscados en la bd
      param in  P_cempres   : Empresa
      param in  P_sproduc   : Producto
      param in  p_sproliq   : Proceso liquidacion
      param in  p_mes       : Mes de la liquidación
      param in  p_anyo      : Año de la liquidación
      param in  p_cestado   : Estado de la liquidación(abierto, cerrado..)
      param in  P_npoliza   : Póliza
      param in  P_npolcia   : Póliza Compañia
      param in  p_nrecibo   : Recibo
      param in  p_creccia   : Recibo Compañia
      param in p_ccompani   : Compañia del seguro
      param in  P_cagente   : Agente
      param in  P_femiini   : Fecha inicio emisión
      param in  P_femifin   : Fecha fin emisión
      param in  P_fefeini   : Fecha inicio efecto
      param in  P_fefefin   : Fecha fin efecto
      param in  P_fcobini   : Fecha inicio cobro
      param in  P_fcobfin   : Fecha fin cobro
      param in out mensajes    : Mensajes de error
      param out pt_liquida  : Colección liquidación
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquida(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_sproliq IN NUMBER,
      p_nmes IN NUMBER,
      p_anyo IN NUMBER,
      p_cestado IN NUMBER,
      p_npoliza IN NUMBER,
      p_cpolcia IN VARCHAR2,
      p_nrecibo IN NUMBER,
      p_creccia IN VARCHAR2,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_femiini IN DATE,
      p_femifin IN DATE,
      p_fefeini IN DATE,
      p_fefefin IN DATE,
      p_fcobini IN DATE,
      p_fcobfin IN DATE,
      pt_liquida OUT t_iax_liquidacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_squery       CLOB;
      v_cur          sys_refcursor;
      v_cur2         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'P_cempres = ' || p_cempres || ', P_sproduc = ' || p_sproduc || ', P_npoliza = '
            || p_npoliza || ', P_cagente = ' || p_cagente;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDACOR.f_get_liquida';
      v_error        NUMBER(8) := 0;
      vt_liquida     t_iax_liquidacion := t_iax_liquidacion();
      vliquida       ob_iax_liquidacion := ob_iax_liquidacion();
   BEGIN
      IF p_cempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      v_squery := pac_liquidacor.f_get_liquida(p_cempres, p_sproduc, p_sproliq, p_nmes, p_anyo,
                                               p_cestado, p_npoliza, p_cpolcia, p_nrecibo,
                                               p_creccia, p_ccompani, p_cagente, p_femiini,
                                               p_femifin, p_fefeini, p_fefefin, p_fcobini,
                                               p_fcobfin, pac_md_common.f_get_cxtidioma);
      v_pasexec := 3;
      v_cur := pac_md_listvalores.f_opencursor(v_squery, mensajes);
      v_pasexec := 4;
      pt_liquida := t_iax_liquidacion();

      LOOP
         FETCH v_cur
          INTO vliquida.sproliq;

         EXIT WHEN v_cur%NOTFOUND;
         v_pasexec := 5;
         v_squery := pac_liquidacor.f_get_cabecera_liquida(p_cempres, vliquida.ccompani, NULL,
                                                           NULL, vliquida.sproliq, NULL,
                                                           pac_md_common.f_get_cxtidioma);
         v_pasexec := 6;
         v_cur2 := pac_md_listvalores.f_opencursor(v_squery, mensajes);
         v_pasexec := 7;

         LOOP
            FETCH v_cur2
             INTO vliquida.sproliq, vliquida.cempres, vliquida.tempres, vliquida.fliquida,
                  vliquida.tliquida, vliquida.nmovliq, vliquida.cestliq, vliquida.testliq,
                  vliquida.itotliq, vliquida.importe, vliquida.finiliq, vliquida.ffinliq,
                  vliquida.ccompani, vliquida.tcompani;

            EXIT WHEN v_cur2%NOTFOUND;
            v_error := f_get_movliquida(vliquida.sproliq, NULL, NULL, NULL,
                                        vliquida.movimientos, mensajes);

            IF v_error <> 0 THEN
               RAISE e_object_error;
            END IF;

            v_error := f_get_recliquida(vliquida.sproliq, NULL, NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, vliquida.recibos, mensajes);

            IF v_error <> 0 THEN
               RAISE e_object_error;
            END IF;

            v_pasexec := 5;
            pt_liquida.EXTEND;
            pt_liquida(pt_liquida.LAST) := vliquida;
            vliquida := ob_iax_liquidacion();
         END LOOP;

         CLOSE v_cur2;
      END LOOP;

      v_pasexec := 13;

      CLOSE v_cur;

      v_pasexec := 14;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         IF v_cur2%ISOPEN THEN
            CLOSE v_cur2;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         IF v_cur2%ISOPEN THEN
            CLOSE v_cur2;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         IF v_cur2%ISOPEN THEN
            CLOSE v_cur2;
         END IF;

         RETURN 1;
   END f_get_liquida;

   /*************************************************************************
      Función que cargará el  objecto liquidacion con sus movimientos buscados en la bd
      param in  P_cempres   : Empresa
      param in  P_sproduc   : Producto
      param in  p_sproliq   : Proceso liquidacion
      param in  p_mes       : Mes de la liquidación
      param in  p_anyo      : Año de la liquidación
      param in  p_cestado   : Estado de la liquidación(abierto, cerrado..)
      param in  P_npoliza   : Póliza
      param in  P_npolcia   : Póliza Compañia
      param in  p_nrecibo   : Recibo
      param in  p_creccia   : Recibo Compañia
      param in p_ccompani   : Compañia del seguro
      param in  P_cagente   : Agente
      param in  P_femiini   : Fecha inicio emisión
      param in  P_femifin   : Fecha fin emisión
      param in  P_fefeini   : Fecha inicio efecto
      param in  P_fefefin   : Fecha fin efecto
      param in  P_fcobini   : Fecha inicio cobro
      param in  P_fcobfin   : Fecha fin cobro
      param in out mensajes    : Mensajes de error
      param out pt_liquida  : Colección liquidación
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquida_cab(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_sproliq IN NUMBER,
      p_nmes IN NUMBER,
      p_anyo IN NUMBER,
      p_cestado IN NUMBER,
      p_npoliza IN NUMBER,
      p_cpolcia IN VARCHAR2,
      p_nrecibo IN NUMBER,
      p_creccia IN VARCHAR2,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_femiini IN DATE,
      p_femifin IN DATE,
      p_fefeini IN DATE,
      p_fefefin IN DATE,
      p_fcobini IN DATE,
      p_fcobfin IN DATE,
      pt_liquida OUT t_iax_liquidacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_squery       CLOB;
      v_cur          sys_refcursor;
      v_cur2         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'P_cempres = ' || p_cempres || ', P_sproduc = ' || p_sproduc || ', P_npoliza = '
            || p_npoliza || ', P_cagente = ' || p_cagente;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDACOR.f_get_liquida_cab';
      v_error        NUMBER(8) := 0;
      vt_liquida     t_iax_liquidacion := t_iax_liquidacion();
      vliquida       ob_iax_liquidacion := ob_iax_liquidacion();
   BEGIN
      IF p_cempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      v_squery := pac_liquidacor.f_get_liquida(p_cempres, p_sproduc, p_sproliq, p_nmes, p_anyo,
                                               p_cestado, p_npoliza, p_cpolcia, p_nrecibo,
                                               p_creccia, p_ccompani, p_cagente, p_femiini,
                                               p_femifin, p_fefeini, p_fefefin, p_fcobini,
                                               p_fcobfin, pac_md_common.f_get_cxtidioma);
      v_pasexec := 3;
      v_cur := pac_md_listvalores.f_opencursor(v_squery, mensajes);
      v_pasexec := 4;
      pt_liquida := t_iax_liquidacion();

      LOOP
         FETCH v_cur
          INTO vliquida.sproliq;

         EXIT WHEN v_cur%NOTFOUND;
         v_pasexec := 5;
         v_squery := pac_liquidacor.f_get_cabecera_liquida(p_cempres, vliquida.ccompani, NULL,
                                                           NULL, vliquida.sproliq, NULL,
                                                           pac_md_common.f_get_cxtidioma);
         v_pasexec := 6;
         v_cur2 := pac_md_listvalores.f_opencursor(v_squery, mensajes);
         v_pasexec := 7;

         LOOP
            FETCH v_cur2
             INTO vliquida.sproliq, vliquida.cempres, vliquida.tempres, vliquida.fliquida,
                  vliquida.tliquida, vliquida.nmovliq, vliquida.cestliq, vliquida.testliq,
                  vliquida.itotliq, vliquida.importe, vliquida.finiliq, vliquida.ffinliq,
                  vliquida.ccompani, vliquida.tcompani;

            EXIT WHEN v_cur2%NOTFOUND;
            /*v_error := f_get_movliquida(vliquida.sproliq, NULL, NULL, NULL,
                                        vliquida.movimientos, mensajes);

            IF v_error <> 0 THEN
               RAISE e_object_error;
            END IF;

            v_error := f_get_recliquida(vliquida.sproliq, NULL, NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, vliquida.recibos, mensajes);

            IF v_error <> 0 THEN
               RAISE e_object_error;
            END IF;*/
            v_pasexec := 5;
            pt_liquida.EXTEND;
            pt_liquida(pt_liquida.LAST) := vliquida;
            vliquida := ob_iax_liquidacion();
         END LOOP;

         CLOSE v_cur2;
      END LOOP;

      v_pasexec := 13;

      CLOSE v_cur;

      v_pasexec := 14;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         IF v_cur2%ISOPEN THEN
            CLOSE v_cur2;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         IF v_cur2%ISOPEN THEN
            CLOSE v_cur2;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         IF v_cur2%ISOPEN THEN
            CLOSE v_cur2;
         END IF;

         RETURN 1;
   END f_get_liquida_cab;

   /*************************************************************************
      Función que devolverá la colección de movimientos de un proceso de liquidación concreto
      param in  p_sproliq   : Proceso liquidacion
      param in  p_nmovliq   : Movimiento liquidacion
      param in  p_cestliq   : Estado de la liquidación(abierto, cerrado..)
      param in  p_cmonliq   : Moneda liquidacion
      param in out mensajes    : Mensajes de error
      param out pt_movliquida  : Colección Movimientos
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_movliquida(
      p_sproliq IN NUMBER,
      p_nmovliq IN NUMBER,
      p_cestliq IN NUMBER,
      p_cmonliq IN VARCHAR2,
      pt_movliquida OUT t_iax_liquida_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_squery       CLOB;
      v_cur          sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := '';
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDACOR.f_get_liquidamov';
      v_error        NUMBER(8) := 0;
      vsproliq       NUMBER;
      vliquidamov    ob_iax_liquida_mov := ob_iax_liquida_mov();
   BEGIN
      IF p_sproliq IS NULL THEN
         RAISE e_param_error;
      END IF;

      pt_movliquida := t_iax_liquida_mov();
      v_pasexec := 2;
      v_squery := pac_liquidacor.f_get_liquidamov(p_sproliq, p_nmovliq, p_cestliq, p_cmonliq,
                                                  pac_md_common.f_get_cxtidioma);
      v_pasexec := 3;
      v_cur := pac_md_listvalores.f_opencursor(v_squery, mensajes);
      v_pasexec := 4;

      LOOP
         FETCH v_cur
          INTO vsproliq, vliquidamov.nmovliq, vliquidamov.cestliq, vliquidamov.testliq,
               vliquidamov.itotliq, vliquidamov.cmonliq, vliquidamov.tmonliq,
               vliquidamov.cusualt, vliquidamov.falta;

         EXIT WHEN v_cur%NOTFOUND;
         v_pasexec := 5;
         pt_movliquida.EXTEND;
         pt_movliquida(pt_movliquida.LAST) := vliquidamov;
         vliquidamov := ob_iax_liquida_mov();
      END LOOP;

      v_pasexec := 13;

      CLOSE v_cur;

      v_pasexec := 14;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
   END f_get_movliquida;

/*************************************************************************
      Función que cargará los recibos de una liquidacion
      param in  p_sproliq   : Proceso liquidacion
      param in  p_nrecibo   : Movimiento liquidacion
      param in  p_ccompani   : Estado de la liquidación(abierto, cerrado..)
      param in  p_cagente   : Agente
      param in  p_cmonseg   : Moneda seguro
      param in  p_cmonliq   : Moneda liquidacion
      param in  p_cgescob   : ges cob
      param in  p_cramo   : ramo
      param in  p_sproduc   : producto
      param in  p_fefectoini   : fecha efecto inicial
      param in  p_fefectofin   : fecha efecto fin
      param out pt_recliquida : coleccion de recibos
      param in out mensajes    : Mensajes de error
      param out pt_recliquida  : Colección de recibos
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_recliquida(
      p_sproliq IN NUMBER,
      p_nrecibo IN NUMBER,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_cmonseg IN VARCHAR2,
      p_cmonliq IN VARCHAR2,
      p_cgescob IN NUMBER,
      p_cramo IN NUMBER,
      p_sproduc IN NUMBER,
      p_fefectoini IN DATE,
      p_fefectofin IN DATE,
      pt_recliquida OUT t_iax_liquida_rec,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_squery       CLOB;
      v_cur          sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := '';
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDACOR.f_get_recliquida';
      v_error        NUMBER(8) := 0;
      vsproliq       NUMBER;
      vliquidarec    ob_iax_liquida_rec := ob_iax_liquida_rec();
      estaliquidado  NUMBER;
      v_cont         NUMBER;
   BEGIN
      IF p_sproliq IS NULL THEN
         RAISE e_param_error;
      END IF;

      pt_recliquida := t_iax_liquida_rec();
      v_pasexec := 2;
      v_squery := pac_liquidacor.f_get_liquidarec(pac_md_common.f_get_cxtempresa, p_sproliq,
                                                  p_nrecibo, p_ccompani, p_cagente, p_cmonseg,
                                                  p_cmonliq, p_cgescob, p_cramo, p_sproduc,
                                                  p_fefectoini, p_fefectofin,
                                                  pac_md_common.f_get_cxtidioma);
      v_pasexec := 3;
      v_cur := pac_md_listvalores.f_opencursor(v_squery, mensajes);
      v_pasexec := 4;

      LOOP
         FETCH v_cur
          INTO vsproliq, vliquidarec.nrecibo, vliquidarec.ccompani, vliquidarec.tcompani,
               vliquidarec.cagente, vliquidarec.tagente, vliquidarec.cmonseg,
               vliquidarec.tmonseg, vliquidarec.itotalr, vliquidarec.icomisi,
               vliquidarec.iretenc, vliquidarec.iprinet, vliquidarec.iliquida,
               vliquidarec.cmonliq, vliquidarec.tmonliq, vliquidarec.iliquidaliq,
               vliquidarec.fcambio, vliquidarec.cgescob, vliquidarec.tgescob;

         EXIT WHEN v_cur%NOTFOUND;
         v_pasexec := 5;
         vliquidarec.cselecc := 1;   --por defecto marcado todos los recibos
         vliquidarec.recibo := pac_md_adm.f_get_datosrecibo_mv(vliquidarec.nrecibo, 0,
                                                               mensajes);
         /* vliquidarec.poliza := pac_iax_produccion.f_get_datpoliza(vliquidarec.recibo.sseguro,
                                                                   mensajes);*/
         vliquidarec.poliza := ob_iax_genpoliza();

         SELECT cpolcia, npoliza,
                f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1,
                                pac_md_common.f_get_cxtidioma)
           INTO vliquidarec.poliza.cpolcia, vliquidarec.poliza.npoliza,
                vliquidarec.poliza.tproduc
           FROM seguros
          WHERE sseguro = vliquidarec.recibo.sseguro;

         /* IF vliquidarec.poliza.ccompani IS NOT NULL THEN
             v_error := f_descompania(vliquidarec.poliza.ccompani, vliquidarec.poliza.tcompani);
          END IF;*/

         --Miraremos si ya existe en alguna liquidación y lo marcaremos
         SELECT COUNT(1)
           INTO estaliquidado
           FROM adm_liquida_recibos
          WHERE nrecibo = vliquidarec.nrecibo
            AND sproliq <> vsproliq;

         IF v_cont > 0 THEN
            vliquidarec.estaliquidado := 1;
         ELSE
            vliquidarec.estaliquidado := 0;
         END IF;

         pt_recliquida.EXTEND;
         pt_recliquida(pt_recliquida.LAST) := vliquidarec;
         vliquidarec := ob_iax_liquida_rec();
      END LOOP;

      v_pasexec := 13;

      CLOSE v_cur;

      pac_iax_produccion.limpiartemporales();
      v_pasexec := 14;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
   END f_get_recliquida;

/*************************************************************************
      Función que cargará los recibos propuestos para liquidar o los que filtremos por pantalla
      param in  p_sproliq   : Proceso liquidacion
      param in  p_nrecibo   : Movimiento liquidacion
      param in  p_ccompani   : Estado de la liquidación(abierto, cerrado..)
      param in  p_cagente   : Agente
      param in  p_cmonseg   : Moneda seguro
      param in  p_cmonliq   : Moneda liquidacion
      param in  p_cgescob   : ges cob
      param in  p_cramo   : ramo
      param in  p_sproduc   : producto
      param in  p_fefectoini   : fecha efecto inicial
      param in  p_fefectofin   : fecha efecto fin
      param out pt_recliquida : coleccion de recibos
      param in out mensajes    : Mensajes de error
      param out pt_recliquida  : Colección de recibos
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_recibos_propuestos(
      p_sproliq IN NUMBER,
      p_nrecibo IN NUMBER,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_cmonseg IN VARCHAR2,
      p_cmonliq IN VARCHAR2,
      p_cgescob IN NUMBER,
      p_cramo IN NUMBER,
      p_sproduc IN VARCHAR2,
      p_fefectoini IN DATE,
      p_fefectofin IN DATE,
      pt_recliquida OUT t_iax_liquida_rec,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_squery       CLOB;
      v_cur          sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := '';
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDACOR.f_get_recibos_propuestos';
      v_error        NUMBER(8) := 0;
      vsproliq       NUMBER;
      vliquidarec    ob_iax_liquida_rec := ob_iax_liquida_rec();
      vobrecibo      ob_iax_liquida_rec := ob_iax_liquida_rec();
      estaliquidado  NUMBER;
      v_cont         NUMBER;
   BEGIN
      IF p_sproliq IS NULL THEN
         RAISE e_param_error;
      END IF;

      pt_recliquida := t_iax_liquida_rec();
      v_pasexec := 2;
      v_squery := pac_liquidacor.f_recibos_propuestos(pac_md_common.f_get_cxtempresa,
                                                      p_sproliq, p_nrecibo, p_ccompani,
                                                      p_cagente, p_cmonseg, p_cmonliq,
                                                      p_cgescob, p_cramo, p_sproduc,
                                                      p_fefectoini, p_fefectofin, NULL, NULL,
                                                      pac_md_common.f_get_cxtidioma);
      v_pasexec := 3;
      v_cur := pac_md_listvalores.f_opencursor(v_squery, mensajes);
      /*  v_pasexec := 4;

        LOOP
           FETCH v_cur
            INTO vsproliq, vliquidarec.nrecibo, vliquidarec.ccompani, vliquidarec.tcompani,
                 vliquidarec.cagente, vliquidarec.tagente, vliquidarec.cmonseg,
                 vliquidarec.tmonseg, vliquidarec.itotalr, vliquidarec.icomisi,
                 vliquidarec.iretenc, vliquidarec.iprinet, vliquidarec.iliquida,
                 vliquidarec.cmonliq, vliquidarec.tmonliq, vliquidarec.iliquidaliq,
                 vliquidarec.fcambio, vliquidarec.cgescob, vliquidarec.tgescob;

           EXIT WHEN v_cur%NOTFOUND;
           v_pasexec := 5;
           vliquidarec.cselecc := 1;   --por defecto marcado todos los recibos
           vliquidarec.recibo := pac_md_adm.f_get_datosrecibo_mv(vliquidarec.nrecibo, mensajes);
           pt_recliquida.EXTEND;
           pt_recliquida(pt_recliquida.LAST) := vliquidarec;
        END LOOP;*/
      pt_recliquida := t_iax_liquida_rec();

      LOOP
         FETCH v_cur
          INTO vobrecibo.nrecibo;

         EXIT WHEN v_cur%NOTFOUND;
         vobrecibo.recibo := pac_md_adm.f_get_datosrecibo_mv(vobrecibo.nrecibo, 0, mensajes);
         v_pasexec := 67;
         vobrecibo.cselecc := 1;
         /*  vobrecibo.poliza := pac_iax_produccion.f_get_datpoliza(vobrecibo.recibo.sseguro,
                                                                  mensajes);*/
         vobrecibo.poliza := ob_iax_genpoliza();

         SELECT cpolcia, npoliza,
                f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1,
                                pac_md_common.f_get_cxtidioma),
                ccompani
           INTO vobrecibo.poliza.cpolcia, vobrecibo.poliza.npoliza,
                vobrecibo.poliza.tproduc,
                vobrecibo.ccompani
           FROM seguros
          WHERE sseguro = vobrecibo.recibo.sseguro;

         IF vobrecibo.ccompani IS NOT NULL THEN
            v_error := f_descompania(vobrecibo.ccompani, vobrecibo.tcompani);
         END IF;

         IF v_error <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         END IF;

         v_pasexec := 6;
         vobrecibo.cagente := vobrecibo.recibo.cagente;
         vobrecibo.tagente := vobrecibo.recibo.tagente;
         vobrecibo.cmonseg := NULL;
         -- vtliquida(i).recibos(v_index).recibo.cmonseg;
         vobrecibo.tmonseg := '';
         --vtliquida(i).recibos(v_index).recibo.tmonseg;
         vobrecibo.itotalr := vobrecibo.recibo.importe;
         vobrecibo.icomisi := vobrecibo.recibo.icomisi;
         vobrecibo.iretenc := NULL;
         -- vtliquida(i).recibos(v_index).recibo.iretenc;
         vobrecibo.iprinet := NULL;
         --vtliquida(i).recibos(v_index).recibo.iprinet;
         vobrecibo.iliquida := vobrecibo.recibo.icomisi;
         vobrecibo.cgescob := vobrecibo.recibo.cgescob;
         vobrecibo.tgescob := vobrecibo.recibo.tgescob;

         --Miraremos si ya existe en alguna liquidación y lo marcaremos
         SELECT COUNT(1)
           INTO estaliquidado
           FROM adm_liquida_recibos
          WHERE nrecibo = vliquidarec.nrecibo
            AND sproliq <> vsproliq;

         IF v_cont > 0 THEN
            vobrecibo.estaliquidado := 1;
         ELSE
            vobrecibo.estaliquidado := 0;
         END IF;

         v_pasexec := 7;
         pt_recliquida.EXTEND;
         pt_recliquida(pt_recliquida.LAST) := vobrecibo;
         vobrecibo := ob_iax_liquida_rec();
      END LOOP;

      v_pasexec := 8;

      CLOSE v_cur;

      v_pasexec := 14;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);

         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         RETURN 1;
   END f_get_recibos_propuestos;

   /*************************************************************************
        Función que insertará los recibos que forman la liquidación
        param in  p_selrecliq : Objeto OB_IAX_LIQUIDACION
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
        25/11/2010#XPL#16310
    *************************************************************************/
   FUNCTION f_set_recliqui(p_selrecliq IN ob_iax_liquidacion, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_objectname   VARCHAR2(500) := 'PAC_MD_LIQUIDACOR.f_set_RecLiqui';
      v_param        VARCHAR2(500) := 'parámetros - ';
      v_pasexec      NUMBER(5) := 1;
      v_numerr       NUMBER(8) := 0;
      v_sproliq      NUMBER;
      v_primero      BOOLEAN := FALSE;
   BEGIN
      v_pasexec := 11;
      v_numerr := pac_liquidacor.f_set_liquida(p_selrecliq.sproliq, p_selrecliq.ccompani,
                                               p_selrecliq.finiliq, p_selrecliq.ffinliq,
                                               p_selrecliq.cempres, p_selrecliq.fliquida,
                                               p_selrecliq.importe, p_selrecliq.tliquida);
      v_pasexec := 2;

      IF v_numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
         RAISE e_object_error;
      END IF;

      v_pasexec := 3;

      IF p_selrecliq.movimientos IS NOT NULL
         AND p_selrecliq.movimientos.COUNT > 0 THEN
         FOR i IN p_selrecliq.movimientos.FIRST .. p_selrecliq.movimientos.LAST LOOP
            v_pasexec := 2;
            v_numerr := pac_liquidacor.f_set_movliquida(p_selrecliq.sproliq,
                                                        p_selrecliq.ccompani,
                                                        p_selrecliq.movimientos(i).nmovliq,
                                                        p_selrecliq.movimientos(i).cestliq,
                                                        p_selrecliq.movimientos(i).cmonliq,
                                                        p_selrecliq.movimientos(i).itotliq);

            IF v_numerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
               RAISE e_object_error;
            END IF;
         END LOOP;
      END IF;

      v_pasexec := 4;

      IF p_selrecliq.recibos IS NOT NULL
         AND p_selrecliq.recibos.COUNT > 0 THEN
         v_pasexec := 5;

         FOR i IN p_selrecliq.recibos.FIRST .. p_selrecliq.recibos.LAST LOOP
            IF p_selrecliq.recibos(i).cselecc = 1 THEN
               v_pasexec := 6;
               v_numerr := pac_liquidacor.f_set_recliquida(p_selrecliq.sproliq,
                                                           p_selrecliq.recibos(i).nrecibo,
                                                           p_selrecliq.ccompani,
                                                           p_selrecliq.recibos(i).cagente,
                                                           p_selrecliq.recibos(i).cmonseg,
                                                           p_selrecliq.recibos(i).itotalr,
                                                           p_selrecliq.recibos(i).icomisi,
                                                           p_selrecliq.recibos(i).iretenc,
                                                           p_selrecliq.recibos(i).iprinet,
                                                           p_selrecliq.recibos(i).iliquida,
                                                           p_selrecliq.recibos(i).cmonliq,
                                                           p_selrecliq.recibos(i).iliquidaliq,
                                                           p_selrecliq.recibos(i).fcambio,
                                                           p_selrecliq.recibos(i).cgescob);

               IF v_numerr <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
                  RAISE e_object_error;
               END IF;
            ELSE
               v_numerr := pac_liquidacor.f_del_recliquida(p_selrecliq.sproliq,
                                                           p_selrecliq.ccompani,
                                                           p_selrecliq.recibos(i).nrecibo);

               IF v_numerr <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      END IF;

      v_pasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_objectname, 1000005, v_pasexec,
                                           v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_objectname, 1000006, v_pasexec,
                                           v_param, v_numerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_objectname, 1000001, v_pasexec,
                                           v_param, NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_recliqui;

   /*************************************************************************
        Función nos devuelve las liquidaciones en las cuales se encuentra el recibo
        param in  P_nrecibo   : Nº de recibo
        param out mensajes    : Mensajes de error
        return                : 0.-    OK
                                1.-    KO
        03/06/2011#XPL#0018732
     *************************************************************************/
   FUNCTION f_get_liquida_rec(
      p_nrecibo IN NUMBER,
      p_liquidarec OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(4000) := ' p_nrecibo = ' || p_nrecibo;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDACOR.f_get_liquida_rec';
      v_error        NUMBER(8);
      vquery         VARCHAR2(2000);
      v_cur          sys_refcursor;
   BEGIN
      IF p_nrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_liquidacor.f_get_liquida_rec(p_nrecibo, pac_md_common.f_get_cxtidioma,
                                                  vquery);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      p_liquidarec := pac_md_listvalores.f_opencursor(vquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_liquida_rec;
END pac_md_liquidacor;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACOR" TO "PROGRAMADORESCSI";
