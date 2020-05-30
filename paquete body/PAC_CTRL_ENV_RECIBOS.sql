CREATE OR REPLACE PACKAGE BODY pac_ctrl_env_recibos IS
/******************************************************************************
   NOMBRE:      PAC_CARGAS_ENSA
   PROPÓSITO: Funciones para la gestión de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/11/2011   JRH              1. Creación del package.
   2.0        28/09/2012   DCG              2. 0023838: LCOL_A003-No enviar al JDE els rebuts dels certificats (INT34)
   3.0        24/12/2012   DCT              3 0025357: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro
   4.0        04/03/2013   AMJ              4.0026265: LCOL_T001-QT 6336: Retenida por env?o fallido a la ERP
   5.0        04/12/2017   ABC              5. CONF-403:Creacion nueva funcion f_procesar_reccaus comision causacion.
   6.0        14/06/2019   WAJ			   6. iAxis-4182 Se hace validacion si la poliza es VF, si cumple la condicion se generan sinterf adicional para las comisiones 
******************************************************************************/

   -- Bug 19290- JRH - 06/09/2011 - 0019290: ENSA102- Tabla de control de los recibos que se envían a SAP
/*************************************************************************
      procedimiento que inserta un movimiento de recibo a tratar
      param in psproces   : Proceso
      param in pcempres :  Empresa
      param in pctipopago   : Tipo pago/recibo (1,2,3,4)
      param in   pnpago   : Pago/Recibo
      param in   pnmov   : Número de movmimento del pago /recibo
      retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ins_recproc(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      pctipomov IN NUMBER DEFAULT 1,
      psseguro IN NUMBER DEFAULT NULL)   --BUG: 26265  04/03/2013 AMJ
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTRL_ENV_RECIBOS.f_ins_recproc';
      v_pasexec      NUMBER := 0;
      v_parerr       EXCEPTION;
      vparam         VARCHAR2(500)
         := 'psproces:' || psproces || 'pcempres: ' || pcempres || ' pctipopago:'
            || pctipopago || ' pnpago:' || pnpago || ' pnmov:' || pnmov || ' pCTIPOMOV:'
            || pctipomov;
   BEGIN
      IF psproces IS NULL
         OR pcempres IS NULL
         OR pctipopago IS NULL
         OR pnpago IS NULL
         OR pnmov IS NULL
         OR pctipomov IS NULL THEN
         RAISE v_parerr;
      END IF;

      v_pasexec := 1;

      /* BUG: 26265 04/03/2013 AMJ
      INSERT INTO estado_proc_recibos
                  (sproces, cempres, ctipopago, npago, nmov, cestado, fec_alta, usu_alta,
                   fec_proceso, usu_proc, terror, ctipomov)
           VALUES (psproces, pcempres, pctipopago, pnpago, pnmov, 0, f_sysdate, f_user,
                   NULL, NULL, NULL, pctipomov);*/

      --BUG: 26265 04/03/2013 AMJ   Ini
      INSERT INTO estado_proc_recibos
                  (sproces, cempres, ctipopago, npago, nmov, cestado, fec_alta, usu_alta,
                   fec_proceso, usu_proc, terror, ctipomov, sseguro)
           VALUES (psproces, pcempres, pctipopago, pnpago, pnmov, 0, f_sysdate, f_user,
                   NULL, NULL, NULL, pctipomov, psseguro);

      --BUG: 26265 04/03/2013 AMJ Fin
      v_pasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN v_parerr THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Parametros erróneos', vparam);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, SQLCODE, vparam || ' ' || SQLERRM);
         RETURN 1;
   END;

/*************************************************************************
      Función que actualiza el estado de un movimiento de recibo a tratar
      param in pctipopago   : Tipo pago/recibo (1,2,3,4)
      param in   pnpago   : Pago/Recibo
      param in   pnmov   : Número de movmimento del pago /recibo
      param in   cestado   : Estado del movimiento
      param in   terror   : Texto de error
      retorna 0 si ha ido bien, 1 en casos contrario

   *************************************************************************/
   FUNCTION f_act_estado(
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      pcestado IN NUMBER,
      pterror IN VARCHAR2,
      psinterf IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTRL_ENV_RECIBOS.f_act_estado';
      v_pasexec      NUMBER := 0;
      v_parerr       EXCEPTION;
      vparam         VARCHAR2(20000)
         := 'cestado:' || pcestado || ' pctipopago:' || pctipopago || ' pnpago:' || pnpago
            || ' pnmov:' || pnmov || ' terror:' || pterror || ' psinterf :' || psinterf;
   BEGIN
      IF pcestado IS NULL
         OR pctipopago IS NULL
         OR pnpago IS NULL
         OR pnmov IS NULL THEN
         RAISE v_parerr;
      END IF;

      v_pasexec := 1;

      UPDATE estado_proc_recibos
         SET cestado = pcestado,
             terror = pterror,
             fec_proceso = TRUNC(f_sysdate),
             usu_proc = f_user,
             sinterf = psinterf
       WHERE ctipopago = pctipopago
         AND npago = pnpago
         AND nmov = pnmov;

      v_pasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN v_parerr THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Parametros erróneos', vparam);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, SQLCODE, vparam || ' ' || SQLERRM);
         RETURN 1;
   END;

   /*************************************************************************
      Función que actualiza el estado de un movimiento de recibo a tratar
      param in psproces   : Proceso
      param in pctipopago   : Tipo pago/recibo (1,2,3,4)
      param in   pnpago   : Pago/Recibo
      param in   pnmov   : Número de movmimento del pago /recibo

      retorna 0 si ha ido bien, 1 en casos contrario

   *************************************************************************/
   FUNCTION f_procesar_pendientes_proc(
      psproces IN NUMBER,
      pnok OUT NUMBER,
      pnko OUT NUMBER,
      pctipopago IN NUMBER DEFAULT NULL,
      pnpago IN NUMBER DEFAULT NULL,
      pnmov IN NUMBER DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL)   -- BUG: 26265  04/03/213  AMJ
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTRL_ENV_RECIBOS.f_procesar_pendientes_proc';
      v_pasexec      NUMBER := 0;
      v_parerr       EXCEPTION;
      vparam         VARCHAR2(500)
         := 'psproces:' || psproces || ' pctipopago:' || pctipopago || ' pnpago:' || pnpago
            || ' pnmov:' || pnmov;
      vnumerr        NUMBER;
      vsinterf       NUMBER;

      CURSOR c_pend IS
         SELECT   *
             FROM estado_proc_recibos e
            WHERE e.sproces = psproces
              AND NVL(e.sseguro, -1) =
                    NVL
                       (DECODE(psseguro, NULL, e.sseguro, psseguro), -1)   -- BUG: 26605/0142535  -- JLTS -- 24/04/2013 - Incluye NVL
              AND e.cestado IN(0, 2)   --por procesar, error
              AND(ctipomov <> 1
                  OR(ctipomov = 1
                     AND((pctipopago = 1
                          AND NOT EXISTS(SELECT 1
                                           FROM sin_tramita_movpago m
                                          WHERE m.sidepag = e.nmov
                                            AND m.cestpag = 9))   --Si es emisión igualmente comprobamos que no se han enviado a SAP ya por lo que sea
                         OR(pctipopago IN(4, 7)
                            AND NOT EXISTS(SELECT 1
                                             FROM movrecibo m
                                            WHERE m.nrecibo = e.nmov
                                              AND m.cestrec = 3))
                         OR(pctipopago IN(2, 3)
                            AND NOT EXISTS(SELECT 1
                                             FROM movpagren m
                                            WHERE m.srecren = e.nmov
                                              AND m.cestrec = 6)))))
              AND((pctipopago IS NULL)
                  OR(pctipopago IS NOT NULL
                     AND e.ctipopago = pctipopago))
              AND((pnpago IS NULL)
                  OR(pnpago IS NOT NULL
                     AND e.npago = pnpago))
              AND((pnmov IS NULL)
                  OR(pnmov IS NOT NULL
                     AND e.nmov = pnmov))
         ORDER BY ctipopago, npago, nmov;
   BEGIN
      IF psproces IS NULL THEN
         IF pctipopago IS NULL
            OR pnpago IS NULL
            OR pnmov IS NULL THEN
            RAISE v_parerr;
         END IF;
      END IF;

      pnok := 0;
      pnko := 0;
      v_pasexec := 1;

      FOR reg IN c_pend LOOP
         DECLARE
            erract         EXCEPTION;
            vterror        VARCHAR2(2000);
         BEGIN
            v_pasexec := 2;
            vnumerr := f_procesar_recpago(reg.cempres, reg.ctipopago, reg.npago, reg.nmov,
                                          reg.ctipomov, psproces, vterror, vsinterf);
            v_pasexec := 3;

            IF vnumerr = 0 THEN
               v_pasexec := 4;
               --pnok := pnok + 1;
               vnumerr := f_act_estado(reg.ctipopago, reg.npago, reg.nmov, 1, NULL, vsinterf);   --Procesados
               v_pasexec := 5;

               IF vnumerr <> 0 THEN
                  RAISE erract;
               ELSE
                  pnok := pnok + 1;
               END IF;
            ELSE
               v_pasexec := 6;
               vnumerr := f_act_estado(reg.ctipopago, reg.npago, reg.nmov, 2, vterror,
                                       vsinterf);
               v_pasexec := 7;

               IF vnumerr <> 0 THEN
                  RAISE erract;
               END IF;

               pnko := pnko + 1;
            END IF;
         EXCEPTION
            WHEN erract THEN
               pnko := pnko + 1;
               p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Error actualizando estado',
                           reg.ctipopago || ' ' || reg.npago || ' ' || reg.nmov || ' '
                           || vterror);
            WHEN OTHERS THEN
               pnko := pnko + 1;
               p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Error actualizando estado',
                           reg.ctipopago || ' ' || reg.npago || ' ' || reg.nmov || ' '
                           || SQLERRM);
         END;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN v_parerr THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Parametros erróneos', vparam);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, SQLCODE, vparam || ' ' || SQLERRM);
         RETURN 1;
   END;

     /*************************************************************************
        Función que procesa un pago
        param in pcempres: Empresa
        param in pctipopago   : Tipo pago/recibo (1 pago,2 renta prestaren ,3 renta seguros_ren,4 recibo)
        param in   pnpago   : Pago/Recibo
        param in   pnmov   : Número de movmimento del pago /recibo
         param in   ptipoaccion   : 1 emisión , 2 anulación
        retorna 0 si ha ido bien, 1 en casos contrario

   *************************************************************************/
   FUNCTION f_procesar_recpago(
      pcempres IN NUMBER,
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      ptipoaccion IN NUMBER,
      psproces IN NUMBER,
      pterror OUT VARCHAR2,
      psinterf OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTRL_ENV_RECIBOS.f_procesar_recpago';
      v_pasexec      NUMBER := 0;
      v_parerr       EXCEPTION;
      vparam         VARCHAR2(500)
         := 'pcempres:' || pcempres || ' pctipopago:' || pctipopago || ' pnpago:' || pnpago
            || ' pnmov:' || pnmov;
      vemitido       NUMBER;
      vterror        VARCHAR2(2000);
      verror         NUMBER;
      pnumevento     NUMBER;
      vsinterf       NUMBER;
      vterminal      VARCHAR2(200);
      l_tippag       NUMBER;        --Version 41
      l_sseguro      NUMBER;        --Version 41
      l_cagente      NUMBER;
      --
      CURSOR c_age_corretaje(c_nrecibo IN recibos.nrecibo%TYPE)
      IS
        SELECT DISTINCT ac.cagente
          FROM recibos r,age_corretaje ac
         WHERE ac.sseguro = r.sseguro
           AND ac.nmovimi = r.nmovimi
           AND r.nrecibo  = c_nrecibo ;
      --
   BEGIN
      IF pcempres IS NULL
         OR pctipopago IS NULL
         OR pnpago IS NULL
         OR pnmov IS NULL THEN
         RAISE v_parerr;
      END IF;

      v_pasexec := 1;
      verror := pac_user.f_get_terminal(f_user, vterminal);

      IF verror < 0 THEN
         RAISE v_parerr;
      END IF;

      v_pasexec := 2;
      verror := pac_con.f_emision_pagorec(pcempres, 1, pctipopago, pnpago, pnmov, vterminal,
                                          vemitido, vsinterf, vterror, f_user);
      --Version 5.0
      IF  verror = 0 THEN
         --
         verror:= f_procesar_reccaus(pcempres, pctipopago, pnpago, pnmov,
                                     ptipoaccion, psproces, vterror, vsinterf);
         --
      END IF;
      --Version 5.0
      v_pasexec := 3;
      psinterf := vsinterf;

      IF verror <> 0
         OR TRIM(vterror) IS NOT NULL THEN   --JRH IMP ?
         --Mira si borraar pagorentas y movpagren porque se tiene que hacer un commit para que loo vea el sap
         pterror := TRIM(vterror);

         IF verror = 0 THEN
            verror := 151323;
         END IF;

         IF pterror IS NULL THEN
            pterror := vterror;
         END IF;

         v_pasexec := 4;
         p_tab_error(f_sysdate, f_user, 'pac_ctrl_env_recibos.f_procesar_recpago', 1,
                     'error no controlado', pterror || ' ' || verror);
         RETURN verror;
      ELSE   --Actualizamos a remesado en IAXIS
         verror := f_act_estado_pagofin(pctipopago, pnpago, pnmov, ptipoaccion, psproces);

         IF verror <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'pac_ctrl_env_recibos.f_movpago', v_pasexec,
                        'error actualizando recibo en IAXIS',
                        'error actualizando recibo en IAXIS' || ' ' || verror);
            pterror := TRIM('Error actualizando estado en IAXIS');
            RETURN verror;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN v_parerr THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Parametros erróneos', vparam);
         pterror := TRIM('Parametros erróneos');
         RETURN 1;
      WHEN OTHERS THEN
         pterror := TRIM(SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, SQLCODE, vparam || ' ' || SQLERRM);
         RETURN 1;
   END;
   --Version 5.0
   FUNCTION f_procesar_reccaus(
      pcempres IN NUMBER,
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      ptipoaccion IN NUMBER,
      psproces IN NUMBER,
      pterror OUT VARCHAR2,
      psinterf OUT NUMBER,
      precaudo IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTRL_ENV_RECIBOS.f_procesar_reccaus';
      v_pasexec      NUMBER := 0;
      v_parerr       EXCEPTION;
      vparam         VARCHAR2(500)
         := 'pcempres:' || pcempres || ' pctipopago:' || pctipopago || ' pnpago:' || pnpago
            || ' pnmov:' || pnmov;
      vemitido       NUMBER;
      vterror        VARCHAR2(2000);
      verror         NUMBER;
      pnumevento     NUMBER;
      vsinterf       NUMBER;
      vterminal      VARCHAR2(200);
      l_tippag       NUMBER;        --Version 41
      l_sseguro      NUMBER;        --Version 41
      l_cagente      NUMBER;
	  --BEGIN iAxis-4182 WAJ
	  x_femisio      date;
      x_fefecto      date;
	  --END iAxis-4182 WAJ
      --
      CURSOR c_age_corretaje(c_nrecibo IN recibos.nrecibo%TYPE)
      IS
        SELECT DISTINCT ac.cagente
          FROM recibos r,age_corretaje ac
         WHERE ac.sseguro = r.sseguro
           AND ac.nmovimi = r.nmovimi
           AND r.nrecibo  = c_nrecibo ;

      CURSOR c_compa_coase(c_nrecibo IN recibos.nrecibo%TYPE) --INI CONF-403 LR
      IS
      SELECT DISTINCT ac.ccompani
          FROM recibos r,ctacoaseguro ac
         WHERE ac.nrecibo = r.nrecibo
           AND r.nrecibo  = c_nrecibo ; --FIN CONF-403 LR
      --
   BEGIN
      IF pcempres IS NULL
         OR pctipopago IS NULL
         OR pnpago IS NULL
         OR pnmov IS NULL THEN
         RAISE v_parerr;
      END IF;

      v_pasexec := 1;
      verror := pac_user.f_get_terminal(f_user, vterminal);

      IF verror < 0 THEN
         RAISE v_parerr;
      END IF;
      v_pasexec := 2;
     --
     -- INI -IAXIS-4153 - JLTS - 07/06/2019 no se envía el recaudo = 1 a SAP
     IF precaudo = 0 THEN
        l_tippag := pac_contab_conf.f_catribu(963,8,'CAUSACION COMISION');
        --
        IF l_tippag IS NOT NULL THEN
           --
           l_sseguro := pac_contab_conf.f_sseguro_coretaje(pnpago);
           --
           IF l_sseguro <> 0 THEN
               --
               FOR y IN c_age_corretaje(pnpago) LOOP
                   --
                   verror := pac_con.f_emision_pagorec(pcempres, 1, l_tippag,y.cagente , pnpago, vterminal,
                                                       vemitido, vsinterf, vterror, f_user);
                   --
                END LOOP;
                --
            ELSE
               --
               BEGIN
                  --
                  SELECT TO_NUMBER(r.cagente)
                    INTO l_cagente
                    FROM recibos r
                   WHERE r.nrecibo = pnpago;
               EXCEPTION WHEN no_data_found THEN
                  --
                  l_cagente := NULL;
                  --
               END;
               verror := pac_con.f_emision_pagorec(pcempres, 1, l_tippag,l_cagente , pnpago, vterminal,
                                          vemitido, vsinterf, vterror, f_user);
              --
            END IF;
			
			--BEGIN iAxis-4182 WAJ
			begin
                  select trunc(a.femisio),  trunc(a.fefecto) 
                     into x_femisio, x_fefecto
                  from seguros a, recibos b
                  where a.sseguro = b.sseguro
                     and b.nrecibo = pnpago;
              exception
                when no_data_found then 
                  x_femisio := null;
                  x_fefecto := null;
              end;

              if x_fefecto > x_femisio then

                 IF l_sseguro <> 0 THEN
                         --
                         FOR y IN c_age_corretaje(pnpago) LOOP
                             --
                             verror := pac_con.f_emision_pagorec(pcempres, 1, l_tippag,y.cagente , pnpago, vterminal,
                                                                 vemitido, vsinterf, vterror, f_user);
                             --
                          END LOOP;
                          --
                 ELSE
                         --
                         BEGIN
                            --
                            SELECT TO_NUMBER(r.cagente)
                              INTO l_cagente
                              FROM recibos r
                             WHERE r.nrecibo = pnpago;
                         EXCEPTION WHEN no_data_found THEN
                            --
                            l_cagente := NULL;
                            --
                         END;
                                  pac_int_online.p_inicializar_sinterf;
                                  vsinterf := pac_int_online.f_obtener_sinterf;
                         verror := pac_con.f_emision_pagorec(pcempres, 1, l_tippag,l_cagente , pnpago, vterminal,
                                                    vemitido, vsinterf, vterror, f_user);
                        --
                 END IF;
              end if;     
			--END iAxis-4182 WAJ
             --
         END IF;
         --
     
          --INI CONF-403 LR
          l_tippag := pac_contab_conf.f_catribu(963,8,'COASEGURO');
          --
          IF l_tippag IS NOT NULL THEN
            vsinterf := NULL;
            --
            FOR y IN c_compa_coase(pnpago) LOOP
              --P_CONTROL_ERROR('LIZMR', 'ENTRA PAC_CTRL_ENV_RECIBOS CAMBIO COA',y.ccompani || ' - '|| pnpago);
              --
              verror := pac_con.f_emision_pagorec(pcempres, 1, l_tippag,y.ccompani , pnpago, vterminal,
                                                  vemitido, vsinterf, vterror, f_user);
              --
            END LOOP;
            --
        END IF;
       --FIN CONF-403 LR
     
      v_pasexec := 3;
      psinterf := vsinterf;

      IF verror <> 0
         OR TRIM(vterror) IS NOT NULL THEN   --JRH IMP ?
         --Mira si borraar pagorentas y movpagren porque se tiene que hacer un commit para que loo vea el sap
         pterror := TRIM(vterror);

         IF verror = 0 THEN
            verror := 151323;
         END IF;

         IF pterror IS NULL THEN
            pterror := vterror;
         END IF;

         v_pasexec := 4;
         p_tab_error(f_sysdate, f_user, 'pac_ctrl_env_recibos.f_procesar_reccaus', 1,
                     'error no controlado', pterror || ' ' || verror);
         RETURN verror;
      ELSE   --Actualizamos a remesado en IAXIS
         --INI CONF-403 LR
         verror := f_act_estado_pagofin(pctipopago, pnpago, pnmov, ptipoaccion, psproces);

         IF verror <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'pac_ctrl_env_recibos.f_movpago', v_pasexec,
                        'error actualizando recibo en IAXIS',
                        'error actualizando recibo en IAXIS' || ' ' || verror);
            pterror := TRIM('Error actualizando estado en IAXIS');
            RETURN verror;
         END IF;--FIN CONF-403 LR
       END IF;
     END IF;
     -- FIN -IAXIS-4153 - JLTS - 07/06/2019 no se envía el recaudo a SAP
     RETURN 0;
   EXCEPTION
      WHEN v_parerr THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Parametros erroneos', vparam);
         pterror := TRIM('Parametros erroneos');
         RETURN 1;
      WHEN OTHERS THEN
         pterror := TRIM(SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, SQLCODE, vparam || ' ' || SQLERRM);
         RETURN 1;
   END f_procesar_reccaus;
   --Version 5.0
    /*************************************************************************
      Función que actualiza el estado de un movimiento de recibo a tratar en AXIS
      param in pctipopago   : Tipo pago/recibo (1 pago,2 renta prestaren ,3 renta seguros_ren,4 recibo)
      param in   pnpago   : Pago/Recibo
      param in   pnmov   : Número de movmimento del pago /recibo
      param in   cestado   : Estado del movimiento
      param in   ptipoaccion   : 1 emisión , 2 anulación
      param in   psproces   : procesos
      retorna 0 si ha ido bien, 1 en casos contrario

   *************************************************************************/
   FUNCTION f_act_estado_pagofin(
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      ptipoaccion IN NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTRL_ENV_RECIBOS.f_act_estado_pagofin';
      v_pasexec      NUMBER := 0;
      v_parerr       EXCEPTION;
      vparam         VARCHAR2(20000)
         := ' pctipopago:' || pctipopago || ' pnpago:' || pnpago || ' pnmov:' || pnmov
            || ' ptipoaccion:' || ptipoaccion;
      vcestrec       NUMBER;
      xcestrec       NUMBER;
      xsmovrec       movrecibo.smovrec%TYPE;
      vfmovini       movrecibo.fmovini%TYPE;
      perror         VARCHAR2(1000);
      vctipcob       movrecibo.ctipcob%TYPE;
      vcmotmov       movrecibo.cmotmov%TYPE;
      vccobban       movrecibo.ccobban%TYPE;
      vcdelega       movrecibo.cdelega%TYPE;
      vsmovagr       movrecibo.smovagr%TYPE;
      vsmovpag       NUMBER;
      vfppren        DATE;
      vnmovpag       NUMBER;
      vfefepag       DATE;
      vfcontab       DATE;
      vcestpag       NUMBER;
      vcempres       NUMBER;
      -- Bug 26070 - RSC - 12/02/2013 - QT 6090
      v_rec_retorno  recibos.nrecibo%TYPE;
   -- Fin Bug 26070
   BEGIN
      IF pctipopago IS NULL
         OR pnpago IS NULL
         OR pnmov IS NULL
         OR ptipoaccion IS NULL THEN
         RAISE v_parerr;
      END IF;

      v_pasexec := 1;

      IF ptipoaccion <> 1 THEN   --Solo emisiones
         RETURN 0;
      END IF;

      -- Bug 26070 - RSC - 12/02/2013 - QT 6090
      BEGIN
         SELECT nrecibo
           INTO v_rec_retorno
           FROM recibos
          WHERE nrecibo = pnpago
            AND pctipopago = 7
            AND ctiprec IN(13, 15);
      EXCEPTION
         WHEN OTHERS THEN
            v_rec_retorno := NULL;
      END;

      -- Fin Bug 26070
      IF pctipopago = 4
         OR v_rec_retorno IS NOT NULL THEN
         --Bug.: 20923 - 14/01/2012 - ICV
         SELECT cempres
           INTO vcempres
           FROM recibos
          WHERE nrecibo = pnpago;

         IF NVL(pac_parametros.f_parempresa_n(vcempres, 'MARCA_REC_REMESADO'), 0) = 0 THEN
            RETURN 0;
         END IF;

         --Fin Bug.: 20923
         v_pasexec := 2;

         BEGIN
            SELECT cestrec, cestant, smovrec, fmovini, ctipcob, cmotmov, ccobban,
                   cdelega, smovagr
              INTO vcestrec, xcestrec, xsmovrec, vfmovini, vctipcob, vcmotmov, vccobban,
                   vcdelega, vsmovagr
              FROM movrecibo
             WHERE nrecibo = pnpago
               AND fmovfin IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               vcestrec := NULL;
               xcestrec := NULL;
         END;

         v_pasexec := 3;

         IF NOT(vcestrec = 0
                AND NVL(xcestrec, 0) = 0)   --SI NO ES EMISION
                                         THEN
            RETURN 0;
         END IF;

         v_pasexec := 4;

         UPDATE movrecibo
            SET fmovfin = TRUNC(vfmovini)
          WHERE smovrec = xsmovrec;   --actualizamos el último estado

         v_pasexec := 5;

         -- poner aquí el cambio de estado . Que nuevo tipo?
         BEGIN
            SELECT smovrec.NEXTVAL
              INTO xsmovrec
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104060;   -- Error al llegir la seqüència (smovrec) de BD
         END;

         v_pasexec := 6;

--p_control_error('APD','f_recries','num_recibo = '||num_recibo);
         INSERT INTO movrecibo
                     (smovrec, cestrec, fmovini, fcontab, fmovfin, nrecibo, cestant, cusuari,
                      smovagr, fmovdia, cmotmov, ccobban, cdelega, ctipcob)
              VALUES (xsmovrec, '3', TRUNC(vfmovini), NULL, NULL, pnpago, vcestrec, f_user,
                      vsmovagr, f_sysdate, vcmotmov, vccobban, vcdelega, vctipcob);

--
         v_pasexec := 7;
      ELSIF pctipopago IN(2, 3) THEN
         SELECT fmovini, smovpag
           INTO vfppren, vsmovpag
           FROM movpagren
          WHERE srecren = pnpago
            AND smovpag = (SELECT MAX(smovpag)
                             FROM movpagren
                            WHERE srecren = pnpago)
            AND fmovfin IS NULL;

         v_pasexec := 8;

         UPDATE movpagren
            SET fmovfin = vfppren
          WHERE srecren = pnpago
            AND smovpag = vsmovpag;

         -- DBMS_OUTPUT.put_line('________1');
         v_pasexec := 9;

         -- poner aquí el cambio de estado
         INSERT INTO movpagren
                     (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
              VALUES (pnpago, 2, 6, vfppren, NULL, f_sysdate);
      ELSE
         v_pasexec := 10;

         SELECT nmovpag, fefepag, fcontab, cestpag
           INTO vnmovpag, vfefepag, vfcontab, vcestpag
           FROM sin_tramita_movpago
          WHERE sidepag = pnpago
            AND nmovpag = (SELECT MAX(nmovpag)
                             FROM sin_tramita_movpago
                            WHERE sidepag = pnpago);

         v_pasexec := 11;

         INSERT INTO sin_tramita_movpago
                     (sidepag, nmovpag, cestpag, fefepag, cestval, fcontab, sproces, cestpagant)
              VALUES (pnpago, vnmovpag + 1, 9, vfefepag, 1, vfcontab, psproces, vcestpag);   --9 es nuevo estado de pago "Remesado"
--
      END IF;

      v_pasexec := 12;
      RETURN 0;
   EXCEPTION
      WHEN v_parerr THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Parametros erróneos', vparam);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, SQLCODE, vparam || ' ' || SQLERRM);
         RETURN 1;
   END;

   /*************************************************************************
      Función que procesa lors recibos de un movimiento de póliza
      param in pcempers : Empresa
      param in psseguro : Sseguro
      param in Pnmovimi : Pnmovimi
      param in pctipopago   : Tipo pago/recibo (1 pago,2 renta prestaren ,3 renta seguros_ren,4 recibo)
      param in out psproces : Número de proceso
      retorna 0 si ha ido bien, error en caso contrario

   *************************************************************************/
   FUNCTION f_proc_recpag_mov(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctipopago IN NUMBER,
      psproces IN NUMBER,
      penvaport IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTRL_ENV_RECIBOS.f_proc_recpag_mov';
      v_pasexec      NUMBER := 0;
      v_parerr       EXCEPTION;
      vparam         VARCHAR2(20000)
         := 'pcempres : ' || pcempres || ' psseguro:' || psseguro || ' pnmovimi:' || pnmovimi
            || ' pctipopago:' || pctipopago || ' psproces:' || psproces;
      num_err        NUMBER := 0;
      vesrentaprest  NUMBER;
      pnok           NUMBER := 0;
      pnko           NUMBER := 0;
      vsproces       NUMBER;
      vesexonerado   NUMBER := 0;   -- BUG22543-13/06/2012-JLTS
      exp_continuar  EXCEPTION;   -- BUG22543-13/06/2012-JLTS
      vsubfi         VARCHAR2(100);
      ss             VARCHAR2(3000);
      v_cursor       NUMBER;
      v_ttippag      NUMBER := 4;
      v_filas        NUMBER;
      v_ko           NUMBER := 0;

      CURSOR c_rec IS
         SELECT r.nrecibo, m.smovrec, r.ctiprec, v.itotalr,
                r.cestaux   -- BUG23838-28/09/2012-DCG
           FROM recibos r, movrecibo m, vdetrecibos v
          WHERE r.sseguro = psseguro
            AND r.cempres = pcempres
            AND r.nmovimi = pnmovimi
            AND r.nrecibo = m.nrecibo
            AND m.fmovfin IS NULL
            AND m.cestrec = 0   --de momento solo ha de gestionar los recibos pendientes.
            AND m.cestant = 0
            AND v.nrecibo = r.nrecibo
            AND NOT EXISTS(SELECT '1'
                             FROM estado_proc_recibos epr
                            WHERE epr.cempres = r.cempres
                              AND epr.ctipopago IN(4, 7)   --recibos
                              AND epr.npago = r.nrecibo
                              AND epr.nmov = m.smovrec
                                                      /*AND cestado = 1*/--ICV 20/11/2013 problema lcol cartera
               );   --Seguridad, no enviar otra vez recibos procesado (OK)
   /* CURSOR c_rec_env IS
       SELECT DISTINCT (ctipopago)
                  FROM estado_proc_recibos
                 WHERE cestado = 0
                   AND sproces = vsproces;*/--ICV 20/11/2013 problema lcol cartera
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pctipopago IS NULL THEN
         RAISE v_parerr;
      END IF;

      v_pasexec := 1;

      --Incializamos el número de proceso
      IF psproces IS NULL THEN
         num_err := f_procesini(f_user, pcempres, 'F_proc_recpag_mov',
                                'Envío de Recibos/Pagos a ERP.', vsproces);
      ELSE
         vsproces := psproces;
      END IF;

      IF pctipopago = 4 THEN   --De momento solo preparado para recibos
         FOR rc IN c_rec LOOP
            BEGIN   -- BUG22543-13/06/2012-JLTS
               SELECT COUNT(*)
                 INTO vesrentaprest
                 FROM seguros_ren_prest
                WHERE ssegren = psseguro;

               IF rc.cestaux <> 2 THEN   -- BUG23838-28/09/2012-DCG
                  IF rc.ctiprec <> 4
                     OR (rc.ctiprec = 4
                         AND(pnmovimi = 1
                             OR NVL(penvaport, 0) = 1))
                        AND vesrentaprest = 0
                        AND rc.itotalr <> 0 THEN
                     -- BUG22543-13/06/2012-JLTS-Inicio.
                     IF rc.ctiprec = 3 THEN
                        vesexonerado := pac_propio.f_esta_en_exoneracion(psseguro);

                        IF vesexonerado <> 0 THEN
                           RAISE exp_continuar;
                        END IF;
                     END IF;

                     vsubfi := pac_parametros.f_parempresa_t(pcempres, 'SUFIJO_EMP');
                     ss := 'BEGIN ' || ' :RETORNO := PAC_PROPIO_' || vsubfi || '_INT.'
                           || 'f_obtener_ttippag(' || rc.ctiprec || ')' || ';' || 'END;';

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     v_cursor := DBMS_SQL.open_cursor;
                     DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
                     DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_ttippag);
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_ttippag);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     -- BUG22543-13/06/2012-JLTS-Fin.
                     --Insertamos todos los recibos del movimiento de la póliza en la tabla de recibos temporales
                     /* BUG:26265   04/03/2013  AMJ
                     num_err := pac_ctrl_env_recibos.f_ins_recproc(vsproces, pcempres,
                                                                   NVL(v_ttippag, pctipopago),
                                                                   rc.nrecibo, rc.smovrec);*/
                      -- BUG:26265   04/03/2013  AMJ
                     num_err := pac_ctrl_env_recibos.f_ins_recproc(vsproces, pcempres,
                                                                   NVL(v_ttippag, pctipopago),
                                                                   rc.nrecibo, rc.smovrec, 1,
                                                                   psseguro);

                     IF num_err <> 0 THEN
                        RETURN num_err;   --Si no podemos garantizar que los marcamos todos para gestionar salimos con error.
                     END IF;

--ICV 20/11/2013 problema lcol cartera
                     num_err :=
                        pac_ctrl_env_recibos.f_procesar_pendientes_proc(vsproces, pnok, pnko,
                                                                        NVL(v_ttippag,
                                                                            pctipopago),
                                                                        rc.nrecibo, NULL,
                                                                        psseguro);

                     IF num_err <> 0
                        OR pnko <> 0 THEN   --Si peta la función
                        v_ko := 1;
                     END IF;
                  END IF;
               END IF;   -- BUG23838-28/09/2012-DCG
            -- BUG22543-13/06/2012-JLTS Inicio
            EXCEPTION
               WHEN exp_continuar THEN
                  NULL;
            END;
         -- BUG22543-13/06/2012-JLTS Fin
         END LOOP;

         -- FOR rc IN c_rec_env LOOP
             --Procesamos todos los recibos insertados
             /*  -- BUG:26265   04/03/2013  AMJ
             num_err := pac_ctrl_env_recibos.f_procesar_pendientes_proc(vsproces, pnok, pnko,
                                                                        rc.ctipopago);*/
              -- BUG:26265   04/03/2013  AMJ
            /* num_err := pac_ctrl_env_recibos.f_procesar_pendientes_proc(vsproces, pnok, pnko,
                                                                        rc.ctipopago, NULL,
                                                                        NULL, psseguro);
          END LOOP;*/
         IF NVL(v_ko, 0) = 1 THEN   --Si peta la función
            IF NVL(pac_parametros.f_parempresa_n(pcempres, 'RETEN_FALLO_ENVERP'), 0) = 1 THEN
               --Si falla la interficie retenmos la póliza
               UPDATE seguros
                  SET creteni = 6
                WHERE sseguro = psseguro;
            END IF;

            IF pnko <> 0 THEN
               RETURN 9903116;
            ELSE
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN v_parerr THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Parámetros erróneos', vparam);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, SQLCODE, vparam || ' ' || SQLERRM);
         RETURN 1;
   END f_proc_recpag_mov;

   /*************************************************************************
      Función que procesa lors recibos de un movimiento de póliza
      param in pcempers : Empresa
      param in psseguro : Sseguro
      param in Pnmovimi : Pnmovimi
      param in pctipopago   : Tipo pago/recibo (1 pago,2 renta prestaren ,3 renta seguros_ren,4 recibo)
      param in out psproces : Número de proceso
      retorna 0 si ha ido bien, error en caso contrario

   *************************************************************************/
   FUNCTION f_proc_recpag_mov_clon(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctipopago IN NUMBER,
      psproces IN NUMBER,
      penvaport IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTRL_ENV_RECIBOS.f_proc_recpag_mov_clon';
      v_pasexec      NUMBER := 0;
      v_parerr       EXCEPTION;
      vparam         VARCHAR2(20000)
         := 'pcempres : ' || pcempres || ' psseguro:' || psseguro || ' pnmovimi:' || pnmovimi
            || ' pctipopago:' || pctipopago || ' psproces:' || psproces;
      num_err        NUMBER := 0;
      vesrentaprest  NUMBER;
      pnok           NUMBER := 0;
      pnko           NUMBER := 0;
      vsproces       NUMBER;
      -- ini BUG 0025357: DCT: 24/12/2012
      vcmotmov       NUMBER;
      vsmovagr       NUMBER;
      vnliqmen       NUMBER;
      vnliqlin       NUMBER;
      v_ko           NUMBER := 0;

      -- fin BUG 0025357: DCT: 24/12/2012
      CURSOR c_rec IS
         SELECT r.nrecibo, m.smovrec, r.ctiprec, v.itotalr, r.ctipcoa, r.cdelega, r.ccobban,
                r.cagente
           FROM recibos r, movrecibo m, vdetrecibos v, recibosclon rc
          WHERE r.sseguro = psseguro
            AND r.cempres = pcempres
            --AND r.nmovimi = pnmovimi
            AND r.nrecibo = m.nrecibo
            AND r.nrecibo = rc.nreciboact
            AND rc.sseguro = r.sseguro
            AND m.fmovfin IS NULL
            AND m.cestrec = 0   --de momento solo ha de gestionar los recibos pendientes.
            AND m.cestant = 0
            AND v.nrecibo = r.nrecibo
            AND NOT EXISTS(SELECT '1'
                             FROM estado_proc_recibos epr
                            WHERE epr.cempres = r.cempres
                              AND epr.ctipopago = 4   --recibos
                              AND epr.npago = r.nrecibo
                              AND epr.nmov = m.smovrec
                                                      --AND cestado = 1 --ICV 20/11/2013 problema lcol cartera
               );   --Seguridad, no enviar otra vez recibos procesado (OK)
   BEGIN
      IF psseguro IS NULL
         OR pctipopago IS NULL THEN
         RAISE v_parerr;
      END IF;

      v_pasexec := 1;

      IF pnmovimi IS NULL THEN
         RAISE v_parerr;
      END IF;

      v_pasexec := 2;

      --Incializamos el número de proceso
      IF psproces IS NULL THEN
         num_err := f_procesini(f_user, pcempres, 'F_proc_recpag_mov',
                                'Envío de Recibos/Pagos a ERP.', vsproces);
      ELSE
         vsproces := psproces;
      END IF;

      IF pctipopago = 4 THEN   --De momento solo preparado para recibos
         FOR rc IN c_rec LOOP
            SELECT COUNT(*)
              INTO vesrentaprest
              FROM seguros_ren_prest
             WHERE ssegren = psseguro;

            IF rc.ctiprec <> 4
               OR (rc.ctiprec = 4
                   AND(pnmovimi = 1
                       OR NVL(penvaport, 0) = 1))
                  AND vesrentaprest = 0
                  AND rc.itotalr <> 0 THEN
               --BUG 0025357: DCT: 24/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
               IF rc.ctiprec IN(13, 15)
                  AND rc.ctipcoa = 8 THEN
                  --Obtenemos el motivo de movimiento
                  BEGIN
                     SELECT cmotmov
                       INTO vcmotmov
                       FROM movseguro
                      WHERE sseguro = psseguro
                        AND nmovimi = pnmovimi;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RAISE v_parerr;
                  END;

                  BEGIN
                     SELECT smovagr.NEXTVAL
                       INTO vsmovagr
                       FROM DUAL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RAISE v_parerr;
                  END;

                  num_err := f_movrecibo(rc.nrecibo, 1, TRUNC(f_sysdate), pnmovimi, vsmovagr,
                                         vnliqmen, vnliqlin, TRUNC(f_sysdate), rc.ccobban,
                                         rc.cdelega, vcmotmov, rc.cagente, NULL,   -- pcagrpro
                                         NULL,   -- pccompani
                                         NULL,   -- pcempres
                                         NULL,   -- pctipemp
                                         NULL,   -- psseguro
                                         NULL,   -- pctiprec
                                         NULL,   -- pcbancar
                                         NULL,   -- pnmovimi
                                         NULL,   -- pcramo
                                         NULL,   -- pcmodali
                                         NULL,   -- pctipseg
                                         NULL,   -- pccolect
                                         NULL,   -- pnomovrec
                                         NULL,   -- pusu_cob
                                         NULL,   -- pfefecrec
                                         NULL,   -- ppgasint
                                         NULL,   -- ppgasext
                                         NULL,   -- pcfeccob
                                         NULL   -- pctipcob
                                             );
               ELSE
                  --Insertamos todos los recibos del movimiento de la póliza en la tabla de recibos temporales
                  num_err := pac_ctrl_env_recibos.f_ins_recproc(vsproces, pcempres,
                                                                pctipopago, rc.nrecibo,
                                                                rc.smovrec);
               END IF;

               --BUG 0025357: DCT: 24/12/2012: FIN: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
               IF num_err <> 0 THEN
                  RETURN num_err;   --Si no podemos garantizar que los marcamos todos para gestionar salimos con error.
               END IF;

                     --ICV 20/11/2013 problema lcol cartera
               --Procesamos todos los recibos insertados
               num_err := pac_ctrl_env_recibos.f_procesar_pendientes_proc(vsproces, pnok, pnko,
                                                                          pctipopago,
                                                                          rc.nrecibo);

               IF num_err <> 0
                  OR pnko <> 0 THEN   --Si peta la función
                  v_ko := 1;
               END IF;
            END IF;
         END LOOP;

--ICV 20/11/2013 problema lcol cartera
         --Procesamos todos los recibos insertados
      /*   num_err := pac_ctrl_env_recibos.f_procesar_pendientes_proc(vsproces, pnok, pnko,
                                                                    pctipopago);*/
         IF NVL(v_ko, 0) = 1 THEN   --Si peta la función
            IF NVL(pac_parametros.f_parempresa_n(pcempres, 'RETEN_FALLO_ENVERP'), 0) = 1 THEN
               --Si falla la interficie retenmos la póliza
               UPDATE seguros
                  SET creteni = 6
                WHERE sseguro = psseguro;
            END IF;

            IF pnko <> 0 THEN
               RETURN 9903116;
            ELSE
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN v_parerr THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, 'Parámetros erróneos', vparam);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, v_pasexec, SQLCODE, vparam || ' ' || SQLERRM);
         RETURN 1;
   END f_proc_recpag_mov_clon;
END pac_ctrl_env_recibos;
/
