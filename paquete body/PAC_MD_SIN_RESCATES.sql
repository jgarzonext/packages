--------------------------------------------------------
--  DDL for Package Body PAC_MD_SIN_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SIN_RESCATES" AS
/*****************************************************************************
   NAME:       PAC_MD_SIN_RESCATES
   PURPOSE:    Funciones de rescates para productos financieros

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   JRH             1. Creación del package.
   2.0        02/02/2010   JTS             9703: Backoffice - Traspasos - Miriam Tomas
   3.0        20/05/2010   RSC             3.0013829: APRB78 - Parametrizacion y adapatacion de rescastes
   4.0        20/12/2010   ICV             4.0016294: 82103066
   5.0        01/07/2011   APD             5.0018913: CRE998 - Afegir motiu de Rescats
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   ------- Funciones internes
   v_nmovimi      NUMBER;
   v_est_sseguro  NUMBER;
   sim            ob_iax_simrescate;

    --JRH 03/2008
     /*************************************************************************
      Valida si se puede realizar el rescate
      param in psseguro  : póliza
      param in pnriesgo  : riesgo
      param in fecha     : fecha del rescate
      param in pccausin  : tipo oper ( 4 --> rescate total)
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_permite_rescate(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fecha IN DATE,
      pccausin IN NUMBER,
      pimporte IN NUMBER,
      pfondos IN t_iax_datos_fnd,
      pctipcal IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || fecha
            || ' pccausin= ' || pccausin;
      vobject        VARCHAR2(200) := 'PAC_MD_SIN_RESCATES.f_valida_permite_rescate';
      v_sproduc      NUMBER;
      v_norden       NUMBER;
      num            NUMBER;
      v_cempres      NUMBER;
      vcrealiza      cfg_accion.crealiza%TYPE;
      -- Bug 20665 - RSC - : LCOL_T001-LCOL - UAT - TEC - Rescates
      v_contador     NUMBER := 0;
      -- Fin bug 20665

      -- Bug 20665 - RSC - 07/02/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
      v_ip_provision NUMBER;
      -- Fin Bug 20665
      usarshw        NUMBER;
      vimpcestas     NUMBER := 0;
      vtotcestas     NUMBER := 0;
      vbonus         NUMBER := 0;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR fecha IS NULL
         OR pccausin IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      -- Primero mira si el producto y el usuario permite rescates
      /*IF pac_wizard.f_get_accion(f_user, 'RESCATES', v_sproduc) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180676);   -- el producto no permite rescates
         RETURN 1;
      END IF;*/
      --BUG 9703 - JTS - 02/02/2010
      numerr := pac_cfg.f_get_user_accion_permitida(f_user, 'RESCATES', v_sproduc, v_cempres,
                                                    vcrealiza);

      IF numerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180676);   -- el producto no permite rescates
         RETURN 1;
      ELSIF numerr <> 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RETURN 1;
      END IF;

      --Fi BUG 9703

      -- Miramos las validaciones generales de siniestros
      --buscamos el asegurado vigente
      BEGIN
         SELECT norden
           INTO v_norden
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecfin IS NULL;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            v_norden := 1;
         WHEN NO_DATA_FOUND THEN
            v_norden := 1;
      END;

      numerr := pac_siniestros.f_permite_alta_siniestro(psseguro, v_norden, fecha,
                                                        TRUNC(f_sysdate), pccausin, 0);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- el producto no permite rescates
         RETURN 1;
      END IF;

      -- Mirar que la póliza es de la misma oficina

      -- Mirar si está permitido el rescate según la parametrización del producto
      numerr := pac_sin_rescates.f_es_rescatable(psseguro, fecha, pccausin, pimporte);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- el producto no permite rescates
         RETURN 1;
      END IF;

      -- Bug 20665 - RSC - : LCOL_T001-LCOL - UAT - TEC - Rescates
      IF NVL(f_parproductos_v(v_sproduc, 'RESCATE_UNIDAD_PEND'), 1) = 0 THEN
         IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
            SELECT COUNT(*)
              INTO v_contador
              FROM ctaseguro
             WHERE sseguro = psseguro
               AND cesta IS NOT NULL
               AND nunidad IS NULL;

            IF v_contador > 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001155);   -- el producto no permite rescates
               RETURN 1;
            END IF;
         END IF;
      END IF;

      IF pccausin = 5
         AND pfondos IS NOT NULL THEN
         -- Fin Bug 20665
         IF NVL(f_parproductos_v(v_sproduc, 'RESCATE_UNIDAD_PEND'), 1) = 2 THEN
            IF pctipcal IS NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001155);
               RETURN 1;
            END IF;

            FOR resc IN pfondos.FIRST .. pfondos.LAST LOOP
               SELECT COUNT(*)
                 INTO v_contador
                 FROM ctaseguro
                WHERE sseguro = psseguro
                  AND cesta = pfondos(resc).ccesta
                  AND nunidad IS NULL;

               IF v_contador > 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903229);
                  RETURN 1;
               END IF;
            END LOOP;
         END IF;

         usarshw := pac_propio.f_usar_shw(psseguro, NULL);

         IF NVL(f_parproductos_v(v_sproduc, 'RESCATE_UNIDAD_PEND'), 1) IN(2, 3) THEN
            IF pctipcal IS NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001155);
               RETURN 1;
            END IF;

            IF pctipcal = 0 THEN
               FOR resc IN pfondos.FIRST .. pfondos.LAST LOOP
                  IF pfondos(resc).prescat > 100
                     OR pfondos(resc).prescat < 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000390);
                     RETURN 1;
                  END IF;
               END LOOP;
            ELSIF pctipcal = 1 THEN
               FOR resc IN pfondos.FIRST .. pfondos.LAST LOOP
                  IF NVL(usarshw, 0) = 1 THEN
                     numerr :=
                        pac_operativa_finv.f_cta_saldo_fondos_cesta_shw(psseguro, NULL,
                                                                        pfondos(resc).ccesta,
                                                                        v_contador,
                                                                        vimpcestas,
                                                                        vtotcestas);
                  ELSE
                     numerr :=
                        pac_operativa_finv.f_cta_saldo_fondos_cesta(psseguro, NULL,
                                                                    pfondos(resc).ccesta,
                                                                    v_contador, vimpcestas,
                                                                    vtotcestas);
                  END IF;

                  IF v_contador < pfondos(resc).irescat THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903229);
                     RETURN 1;
                  END IF;
               END LOOP;
            ELSIF pctipcal = 2 THEN
               FOR resc IN pfondos.FIRST .. pfondos.LAST LOOP
                  IF NVL(usarshw, 0) = 1 THEN
                     numerr :=
                        pac_operativa_finv.f_cta_saldo_fondos_cesta_shw(psseguro, NULL,
                                                                        pfondos(resc).ccesta,
                                                                        v_contador,
                                                                        vimpcestas,
                                                                        vtotcestas);
                  ELSE
                     numerr :=
                        pac_operativa_finv.f_cta_saldo_fondos_cesta(psseguro, NULL,
                                                                    pfondos(resc).ccesta,
                                                                    v_contador, vimpcestas,
                                                                    vtotcestas);
                  END IF;

                  IF vimpcestas < pfondos(resc).irescat THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903229);
                     RETURN 1;
                  END IF;
               END LOOP;
            --
            ELSIF pctipcal = 3 THEN
               --
               FOR resc IN pfondos.FIRST .. pfondos.LAST LOOP
                  --
                  IF NVL(usarshw, 0) = 1 THEN
                     --
                     numerr := pac_operativa_finv.f_get_imppb_shw(psseguro,
                                                                  pfondos(resc).ccesta, fecha,
                                                                  vbonus);
                  --
                  ELSE
                     --
                     numerr := pac_operativa_finv.f_get_imppb(psseguro, pfondos(resc).ccesta,
                                                              fecha, vbonus);
                  --
                  END IF;

                  --
                  IF pfondos(resc).irescat > vbonus THEN
                     --
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908364);
                     RETURN 1;
                  --
                  END IF;
               --
               END LOOP;
            --
            END IF;
         --
         END IF;
      END IF;

      -- Bug 20665 - RSC - 07/02/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
      IF pccausin = 5 THEN
         -- Provision Actual
         BEGIN
            vpasexec := 15;
            v_ip_provision := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                         TRUNC(fecha),
                                                                         'IPROVAC');
         EXCEPTION
            WHEN OTHERS THEN
               v_ip_provision := NULL;
         END;

         IF v_ip_provision IS NOT NULL THEN
            IF pimporte > v_ip_provision THEN
               -- No está permitido efectuar un rescate mayor al valor de provisión de ahorro disponible.
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903229);
               RETURN 1;
            END IF;
         END IF;
      END IF;

      -- Bug 20665

      -- Mirar si tiene descuadres
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN NO_DATA_FOUND THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180602);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_permite_rescate;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
       Valida y realiza un rescate
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fecha     : fecha del rescate
       pimporte           : Importe del rescate (nulo si es total)
       tipoOper           : 3 en rescate total , 4 en rescate parcial.
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_rescate_poliza(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fecha IN DATE,
      pimporte IN NUMBER,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      tipooper IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      pcmotresc IN NUMBER DEFAULT NULL,
      pfondos IN t_iax_datos_fnd,
      pctipcal IN NUMBER DEFAULT NULL)   -- Bug 18913 - APD - 01/07/2011
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || fecha
            || ' tipoOper= ' || tipooper || ' pimporte= ' || pimporte;
      vobject        VARCHAR2(200) := 'PAC_MD_SIN_RESCATES.f_rescate_poliza';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
      rec_pend       pac_anulacion.recibos_pend;
      rec_cobr       pac_anulacion.recibos_cob;

      CURSOR recibos_pendientes IS
         SELECT r.nrecibo, m.fmovini, r.fefecto
           FROM recibos r, movrecibo m
          WHERE r.sseguro = psseguro
            AND f_cestrec_mv(r.nrecibo, 0) = 0
            AND m.nrecibo = r.nrecibo
            AND m.fmovfin IS NULL;

      nrec_pend      NUMBER := 0;
      pireduc        NUMBER := NULL;
      pireten        NUMBER := NULL;
      pirendi        NUMBER := NULL;
      pnivel         NUMBER := 1;
      cavis          NUMBER;
      pdatos         NUMBER;
      xnivel         NUMBER;
      salida         EXCEPTION;
      -- Bug 13829 - RSC - 25/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ximport        NUMBER;
   -- Fin Bug 13829
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR fecha IS NULL
         OR tipooper IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

       /*
      {obtenemos los datos de la poliza}
      */
      BEGIN
         SELECT *
           INTO reg_seg
           FROM seguros
          WHERE sseguro = psseguro;
      END;

      vpasexec := 3;
      /*
      {validamos rescate}
      */
      numerr := f_valida_permite_rescate(psseguro, pnriesgo, fecha, tipooper, pimporte,
                                         pfondos, pctipcal, mensajes);

      IF numerr <> 0 THEN
         IF numerr <> 1 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- el producto no permite rescates
         END IF;

         RAISE salida;
      END IF;

      vpasexec := 4;
      numerr := pac_sin_rescates.f_avisos_rescates(psseguro, fecha, pimporte, cavis, pdatos);

      IF cavis IS NOT NULL THEN
         xnivel := 2;   -- no se generan datos
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, cavis);
      ELSE
         xnivel := 1;   -- se generarán también los pagos
      END IF;

      -- Bug 13829 - RSC - 25/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      --IF tipooper = 5 THEN   --rescate parcial
      --   ximport := pimporte;
      --ELSE
      --   IF NVL(f_parproductos_v(reg_seg.sproduc, 'RECALC_PAGOSVAL'), 1) = 0 THEN
      --      ximport := pimporte;
      --   ELSE
      --      ximport := NULL;
      --   END iF;
      --END IF;
      -- Fin Bug 13829

      -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      IF NVL(f_parproductos_v(reg_seg.sproduc, 'RESCATE_UNIDAD_PEND'), 0) IN(2, 3)
         AND tipooper IN(4, 5) THEN
         numerr := f_sol_rescate_fnd(psseguro, pnriesgo, fecha, gidioma, pfondos, pctipcal,
                                     pimporte, pimprcm, ppctreten, pipenali, tipooper);

         IF numerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
            RETURN numerr;
         END IF;
      ELSE
         IF NVL(f_parproductos_v(reg_seg.sproduc, 'RECALC_PAGOSVAL'), 1) = 0 THEN
            vpasexec := 5;
            -- Utilizamos ximport
            -- Bug 18913 - APD - 01/07/2011 - se añade el parametro pcmotresc a la
            -- funcion pac_sin_rescates.f_sol_rescate
            numerr := pac_sin_rescates.f_sol_rescate(psseguro, reg_seg.sproduc,
                                                     f_parinstalacion_n('MONEDAINST'), NULL,
                                                     gidioma, tipooper, pimporte, fecha,
                                                     NVL(pipenali, 0), NULL, NULL, NULL,
                                                     xnivel, pimprcm, ppctreten, pcmotresc);
         -- Fin Bug 18913 - APD - 01/07/2011
         ELSE
            -- Fin Bug 13829
            vpasexec := 5;
            -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
            -- Utilizamos ximport
            -- Bug 18913 - APD - 01/07/2011 - se añade el parametro pcmotresc a la
            -- funcion pac_sin_rescates.f_sol_rescate
            numerr := pac_sin_rescates.f_sol_rescate(psseguro, reg_seg.sproduc,
                                                     f_parinstalacion_n('MONEDAINST'), NULL,
                                                     gidioma, tipooper, pimporte, fecha,
                                                     NVL(pipenali, 0), NULL, NULL, NULL,
                                                     xnivel, NULL, NULL, pcmotresc);
         -- Fin Bug 18913 - APD - 01/07/2011
         END IF;

         IF numerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- error gestionando siniestro
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 6;

      IF numerr <> 0 THEN
         RAISE salida;
      END IF;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'POST_ACCION_LRE'),
             0) = 1 THEN
         numerr := pac_propio.f_acciones_post_rescate(psseguro, 0);

         IF numerr <> 0 THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, numerr, vpasexec, vparam);
            RETURN 1;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN salida THEN
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_rescate_poliza;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
      Valida y realiza la simulación de un rescate
      param in psseguro  : póliza
      param in pnriesgo  : riesgo
      param in fecha     : fecha del rescate
      pimporte           : Importe del rescate (nulo si es total)
      pccausin           : 4 en rescate total , 5 en rescate parcial.
      simResc out OB_IAX_SIMRESCATE : objeto con la simulación
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_valor_simulacion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fecha IN DATE,
      pimporte IN NUMBER,
      pccausin IN NUMBER,
      pctipcal IN NUMBER,
      simresc IN OUT ob_iax_simrescate,
      mensajes IN OUT t_iax_mensajes,
      pimppenali IN NUMBER DEFAULT NULL,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL)   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || fecha
            || ' pccausin= ' || pccausin || ' pimporte=' || pimporte;
      vobject        VARCHAR2(200) := 'PAC_MD_SIN_RESCATES.f_Valor_Simulacion';
      w_cgarant      NUMBER;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      ximport        NUMBER;
      mostrar_datos  NUMBER;
      cavis          NUMBER;
      salida         EXCEPTION;
      datecon        ob_iax_datoseconomicos;
      v_cagente      NUMBER;
      res            pac_sin_formula.t_val;
      v_icapesp      NUMBER;
      v_nmovimi      NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR fecha IS NULL
         OR pccausin IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      --Llamar a PACIAX_DATOSCTASEGURO .f_ObtDatEcon para obtener los OB_IAX_SIMRESCATE

      /*
      {validamos rescate}
      */
      --JRH IMP Poner el parcial
      numerr := f_valida_permite_rescate(psseguro, pnriesgo, fecha, pccausin, pimporte, NULL,
                                         NULL, mensajes);

      IF numerr <> 0 THEN
         --Ini bug.: 16294 - ICV - 20/12/2010
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- el producto no permite rescates
         --El mensaje se está montando en la valida_permite_rescate de la capa MD y siempre devuelve un 1 si peta por
         --lo que no hay que montar el resultado solo salir.
         --Fin Bug.
         RAISE salida;
      END IF;

      --JRH De momento validamos que sea un porcentaje
      vpasexec := 2;

      -- Buscamos datos de la póliza
      BEGIN
         SELECT sproduc, cactivi, cagente
           INTO v_sproduc, v_cactivi, v_cagente
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101919);
            RAISE salida;
      END;

      IF pccausin = 5 THEN   --rescate parcial
         ximport := pimporte;
      ELSE
         -- Bug 13829 - RSC - 25/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
         IF NVL(f_parproductos_v(v_sproduc, 'RECALC_PAGOSVAL'), 1) = 0 THEN
            ximport := pimporte;
         ELSE
            -- Fin Bug 13829
            ximport := NULL;
         END IF;
      END IF;

      -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      IF NVL(f_parproductos_v(v_sproduc, 'RECALC_PAGOSVAL'), 1) = 0 THEN
         numerr := pac_sin_rescates.f_simulacion_rescate(psseguro, v_cagente, pccausin,
                                                         ximport, fecha, pctipcal, res,
                                                         pimppenali, pimprcm, ppctreten);
      ELSE
         numerr := pac_sin_rescates.f_simulacion_rescate(psseguro, v_cagente, pccausin,
                                                         ximport, fecha, pctipcal, res,
                                                         pimppenali);
      END IF;

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- el producto no permite rescates
         ROLLBACK;
         RAISE salida;
      END IF;

      vpasexec := 5;

      DECLARE
         a              NUMBER;
      BEGIN
         a := res(1).isinret;
      END;

      IF pccausin = 4 THEN   --rescate total
         numerr := pac_sin_rescates.f_avisos_rescates(psseguro, fecha, res(1).isinret, cavis,
                                                      mostrar_datos);

         IF cavis IS NOT NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, cavis);
         END IF;
      END IF;

      --Obtenemos los datos económicos
      numerr := pac_md_datosctaseguro.f_obtdatecon(psseguro, pnriesgo, fecha, datecon,
                                                   mensajes);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RAISE salida;
      END IF;

      simresc := ob_iax_simrescate();
      simresc.datosecon := datecon;
      vpasexec := 6;
      simresc.impcapris := res(1).icapris;
      simresc.imppenali := res(1).ipenali;
      simresc.imprescate := res(1).isinret;
      simresc.impprimascons := res(1).iprimas;
      simresc.imprendbruto := GREATEST((res(1).isinret - res(1).iprimas), 0);
      simresc.pctreduccion := 0;
      simresc.impreduccion := res(1).iresred;
      simresc.impregtrans := res(1).iresred;
      simresc.imprcm := GREATEST(res(1).iresrcm - res(1).iresred, 0);
      simresc.pctpctreten := res(1).pretenc;
      simresc.impretencion := res(1).iretenc;
      simresc.impresneto := res(1).iimpsin;
      --JRH Falta pasar de res al objeto de iaxis simResc
      COMMIT;   --JRH IMP No sé si hace falta

      IF NVL(f_parproductos_v(v_sproduc, 'PROY_AHO_RESC'), 0) = 1 THEN
         vpasexec := 7;

         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movseguro
          WHERE sseguro = psseguro;

         vpasexec := 8;
         numerr := pac_propio.f_proy_aho_resc(psseguro, pnriesgo, v_nmovimi,
                                              TO_CHAR(fecha, 'YYYYMMDD'), res(1).icapris,
                                              v_icapesp);

         IF numerr = 0 THEN
            COMMIT;
         ELSE
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, numerr, vpasexec, vparam);
            RAISE salida;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN salida THEN
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valor_simulacion;

--JRH 03/2008
   FUNCTION f_sol_rescate_fnd(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pffecmov IN DATE,
      pcidioma IN NUMBER,
      pfondos IN t_iax_datos_fnd,
      pctipcal IN NUMBER,
      pimporte IN NUMBER,
      pimprcm IN NUMBER,
      ppctreten IN NUMBER,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      pccausin IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(60) := 'PAC_MD_SIN_RESCATES.F_SOL_RESCATE_FND';
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' pffecmov: '
            || TO_CHAR(pffecmov, 'dd/mm/yyyy') || ' pcidioma: ' || pcidioma || ' pctipcal: '
            || pctipcal || ' pimporte: ' || pimporte || ' pimprcm: ' || pimprcm
            || ' ppctreten: ' || ppctreten;
      vpasexec       NUMBER := 0;
      numerror       NUMBER := 0;
      --datosseguro sys_refcursor;
      vtcausa        sin_desmotcau.tmotsin%TYPE;
      vnorden        NUMBER;
      vsperson       NUMBER;
      vsproduc       NUMBER;
      vcactivi       NUMBER;
      vpretenc       NUMBER;
      vnsinies       NUMBER;
      vnmovsin       NUMBER;
      vntramit       NUMBER;
      pdiafinv       NUMBER;
      pskipfanulacion NUMBER;
      sini_exception EXCEPTION;
      pres_exception EXCEPTION;
      vcmotsin       NUMBER;
   BEGIN
      IF pac_sin_rescates.f_vivo_o_muerto(psseguro, 2, TRUNC(f_sysdate)) > 0 THEN
         BEGIN
            SELECT norden
              INTO vnorden
              FROM asegurados
             WHERE sseguro = psseguro
               AND ffecmue IS NULL
               AND ffecfin IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 120007;   --error al leer asegurados.
         END;
      ELSE
         vnorden := 1;
      END IF;

      BEGIN
         SELECT r.sperson, s.sproduc, s.cactivi
           INTO vsperson, vsproduc, vcactivi
           FROM asegurados r, seguros s
          WHERE r.sseguro = s.sseguro
            AND s.sseguro = psseguro
            AND r.norden = vnorden;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102819;   -- riesgo no encontrado.
      END;

      --Buscamos el valor de pretenc
      vpretenc := pac_sin_rescates.f_busca_preten(-1, vsperson, vsproduc,
                                                  TO_NUMBER(TO_CHAR(pffecmov, 'YYYYMMDD')));

      --Buscamos la descripcion de causini = 5
      IF NVL(pctipcal, 1) = 3 THEN
         --
         vcmotsin := 5;
      --
      ELSE
         --
         vcmotsin := 0;
      --
      END IF;

      --
      vtcausa := pac_siniestros.ff_desmotcausa(pccausin, vcmotsin, pcidioma);
      --
      --inicializamos el siniestro
      numerror := pac_siniestros.f_inicializa_sin(psseguro, pnriesgo, NULL, pffecmov, pffecmov,
                                                  vtcausa, pccausin, vcmotsin, 21, vnsinies,
                                                  vnmovsin, vntramit, pdiafinv,
                                                  pskipfanulacion);

      IF numerror <> 0 THEN
         RAISE sini_exception;
      END IF;

      --Insertamos la prereserva de fondos.
      numerror := pac_sin_rescates.f_ins_prereserva(vnsinies, vntramit, pffecmov, vpretenc,
                                                    pipenali, NVL(pctipcal, 1));

      IF numerror <> 0 THEN
         RAISE pres_exception;
      END IF;

      numerror := f_inserta_reserva_fondon(pfondos, psseguro, vsproduc, pnriesgo, pffecmov,
                                           vnsinies, vntramit, pctipcal, vcactivi, pccausin,
                                           vcmotsin, ppctreten, pimporte, pipenali);

      IF numerror <> 0 THEN
         RETURN numerror;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN sini_exception THEN
         RETURN numerror;
      WHEN pres_exception THEN
         RETURN numerror;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 140999;
   END f_sol_rescate_fnd;

   FUNCTION f_inserta_reserva_fondon(
      pfondos IN t_iax_datos_fnd,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pnriesgo IN NUMBER,
      pffecmov IN DATE,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctipcal IN NUMBER,
      pscactivi IN NUMBER,
      pcausin IN NUMBER,
      pcmotsin IN NUMBER,
      pretenc IN NUMBER DEFAULT NULL,
      pimporte IN NUMBER DEFAULT NULL,
      pipenal IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      breserva       BOOLEAN := TRUE;
      ireserva       NUMBER := 0;
      ivaluni        NUMBER := 0;
      ivalunishw     NUMBER := 0;
      nunidades      NUMBER := 0;
      nverifica      NUMBER := 0;
      ivalact        NUMBER := 0;
      ivalactshw     NUMBER := 0;
      nerror         NUMBER := 0;
      vcgarant       NUMBER := 0;
      vnmovres       NUMBER := 0;
      vivaloratot    NUMBER := 0;
      vppagdes       NUMBER := 0;
      vsidepag       NUMBER := 0;
      vipago         NUMBER := 0;
      vriesgo        NUMBER := 0;
      reg            sys_refcursor;
      v_tiene_shw    NUMBER(1);
      v_usar_shw     NUMBER(1);
      vprovision     NUMBER := 0;
      vprovshw       NUMBER := 0;
      vnmaxuni       NUMBER := 0;
      vnmaxunishw    NUMBER := 0;
      vnmaximporte   NUMBER := 0;
      vnmaximporteshw NUMBER := 0;
      vtotalcestas   NUMBER := 0;
      nverificashw   NUMBER := 0;
      vobject        VARCHAR2(100) := 'PAC_MD_SIN_RESCATES.f_inserta_reserva_fondon';
      vparam         VARCHAR2(1000)
         := psseguro || '#' || psproduc || '#' || pnriesgo || '#'
            || TO_CHAR(pffecmov, 'ddmmyyyy') || '#' || pnsinies || '#' || pntramit || '#'
            || pctipcal || '#' || pscactivi || '#' || pcausin || '#' || pcmotsin || '#'
            || pretenc || '#' || pipenal;
      vpexec         NUMBER := 1;
      data_error     EXCEPTION;
   BEGIN
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         v_usar_shw := pac_propio.f_usar_shw(psseguro, NULL);
         vpexec := 2;

         IF pcausin = 5 THEN
            IF pfondos IS NOT NULL THEN
               IF pfondos.COUNT > 0 THEN
                  FOR i IN pfondos.FIRST .. pfondos.LAST LOOP
                     IF (pfondos.EXISTS(i)
                         AND NVL(pfondos(i).cobliga, 0) = 1) THEN
                        IF NVL(pac_ctaseguro.f_ctaseguro_consolidada(pffecmov, f_empres,
                                                                     pfondos(i).ccesta,
                                                                     psseguro, v_usar_shw),
                               0) = 0 THEN
                           breserva := FALSE;
                        END IF;

                        vpexec := 3;

                        --calculamos el valor a rescatar
                        BEGIN
                           SELECT iuniact, iuniactvtashw
                             INTO ivaluni, ivalunishw
                             FROM tabvalces
                            WHERE ccesta = pfondos(i).ccesta
                              AND fvalor = TRUNC(pffecmov)
                                           + pac_md_fondos.f_get_diasdep(pfondos(i).ccesta);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              ivaluni := NULL;
                              ivalunishw := NULL;
                              breserva := FALSE;
                        END;

                        --paso 2 calculo de unidades
                        IF pctipcal = 0 THEN   --porcentaje
                           vpexec := 4;
                           vnmaxuni := 0;
                           vnmaximporte := 0;
                           vtotalcestas := 0;
                           nerror :=
                              pac_operativa_finv.f_cta_saldo_fondos_cesta_shw
                                                                            (psseguro, NULL,
                                                                             pfondos(i).ccesta,
                                                                             vnmaxuni,
                                                                             vnmaximporte,
                                                                             vtotalcestas);

                           IF nerror <> 0 THEN
                              RAISE data_error;
                           END IF;

                           vpexec := 5;
                           ivalactshw := (vnmaximporte * pfondos(i).prescat) / 100;
                           vnmaxuni := 0;
                           vnmaximporte := 0;
                           vtotalcestas := 0;
                           nerror :=
                              pac_operativa_finv.f_cta_saldo_fondos_cesta(psseguro, NULL,
                                                                          pfondos(i).ccesta,
                                                                          vnmaxuni,
                                                                          vnmaximporte,
                                                                          vtotalcestas);

                           IF nerror <> 0 THEN
                              RAISE data_error;
                           END IF;

                           ivalact := (vnmaximporte * pfondos(i).prescat) / 100;
                           vnmaxunishw := ivalactshw / ivalunishw;
                           nunidades := ivalact / ivaluni;
                        ELSIF pctipcal = 1 THEN   --numero de unidades
                           vpexec := 6;
                           nverifica := 0;
                           vnmaximporte := 0;
                           vtotalcestas := 0;
                           nerror :=
                              pac_operativa_finv.f_cta_saldo_fondos_cesta(psseguro, NULL,
                                                                          pfondos(i).ccesta,
                                                                          nverifica,
                                                                          vnmaximporte,
                                                                          vtotalcestas);

                           IF nerror <> 0 THEN
                              RAISE data_error;
                           END IF;

                           nverificashw := 0;
                           vnmaximporte := 0;
                           vtotalcestas := 0;
                           nerror :=
                              pac_operativa_finv.f_cta_saldo_fondos_cesta_shw
                                                                             (psseguro, NULL,
                                                                              pfondos(i).ccesta,
                                                                              nverificashw,
                                                                              vnmaximporte,
                                                                              vtotalcestas);

                           IF nerror <> 0 THEN
                              RAISE data_error;
                           END IF;

                           IF v_usar_shw = 1 THEN
                              IF nverificashw < pfondos(i).irescat THEN
                                 RETURN 102784;
                              END IF;

                              vnmaxunishw := pfondos(i).irescat;
                              nunidades := (nverifica * vnmaxunishw) / nverificashw;
                           ELSE
                              IF nverifica < pfondos(i).irescat THEN
                                 RETURN 102784;
                              END IF;

                              nunidades := pfondos(i).irescat;
                              vnmaxunishw := (nverificashw * nunidades) / nverifica;
                           END IF;

                           ivalact := ivaluni * nunidades;
                           ivalactshw := ivalunishw * vnmaxunishw;
                        ELSIF pctipcal = 2 THEN
                           vpexec := 7;
                           vnmaxunishw := 0;
                           nunidades := 0;
                           ivalact := 0;
                           ivalactshw := 0;
                           nerror := pac_propio.f_reparto_shadow(psseguro, NULL,
                                                                 pfondos(i).ccesta,
                                                                 pfondos(i).irescat, ivalact,
                                                                 ivalactshw);
                           vnmaxunishw := ivalactshw / ivalunishw;
                           nunidades := ivalact / ivaluni;

                           IF nerror <> 0 THEN
                              RAISE data_error;
                           END IF;
                        --
                        ELSIF pctipcal = 3 THEN
                           --
                           vpexec := 12;
                           vnmaxunishw := 0;
                           nunidades := 0;
                           ivalact := pfondos(i).irescat;
                           ivalactshw := pfondos(i).irescat;
                           vnmaxunishw := ivalactshw / ivalunishw;
                           nunidades := ivalact / ivaluni;
                        --
                        END IF;

                        ivalact := f_round(ivalact,
                                           pac_monedas.f_moneda_seguro('SEG', psseguro));
                        ivalactshw := f_round(ivalactshw,
                                              pac_monedas.f_moneda_seguro('SEG', psseguro));

                        IF breserva THEN
                           IF v_usar_shw = 1 THEN
                              ireserva := ireserva + ivalactshw;
                           ELSE
                              ireserva := ireserva + ivalact;
                           END IF;
                        END IF;

                        vpexec := 8;

                        FOR reg IN (SELECT DISTINCT cgarant
                                               FROM sin_gar_causa_motivo sgcm,
                                                    sin_causa_motivo scm
                                              WHERE sgcm.scaumot = scm.scaumot
                                                AND scm.ccausin = pcausin
                                                AND scm.cmotsin = pcmotsin
                                                AND sgcm.sproduc = psproduc
                                                AND sgcm.cactivi = pscactivi) LOOP
                           nerror := pac_sin_rescates.f_ins_prereserva_fnd(pnsinies, pntramit,
                                                                           pffecmov,
                                                                           pfondos(i).ccesta,
                                                                           ivalact, nunidades,
                                                                           ivaluni, pretenc,
                                                                           pipenal,
                                                                           reg.cgarant,
                                                                           ivalactshw,
                                                                           ivalunishw,
                                                                           vnmaxunishw);

                           IF nerror <> 0 THEN
                              RAISE data_error;
                           END IF;
                        END LOOP;
                     END IF;
                  END LOOP;
               ELSE
                  breserva := FALSE;
               END IF;
            ELSE
               breserva := FALSE;
            END IF;
         ELSIF pcausin IN(3, 4) THEN
            vpexec := 9;

            IF NVL(pimporte, 0) = 0 THEN
               breserva := FALSE;
            END IF;

            FOR segdis2 IN (SELECT DISTINCT (ccesta)
                                       FROM segdisin2
                                      WHERE sseguro = psseguro
                                        AND nmovimi = (SELECT MAX(nmovimi)
                                                         FROM segdisin2
                                                        WHERE sseguro = psseguro)) LOOP
               IF NVL(pac_ctaseguro.f_ctaseguro_consolidada(pffecmov, f_empres,
                                                            segdis2.ccesta, psseguro,
                                                            v_usar_shw),
                      0) = 0 THEN
                  breserva := FALSE;
               END IF;

               --calculamos el valor a rescatar
               BEGIN
                  SELECT iuniact, iuniactvtashw
                    INTO ivaluni, ivalunishw
                    FROM tabvalces
                   WHERE ccesta = segdis2.ccesta
                     AND fvalor = TRUNC(pffecmov) + pac_md_fondos.f_get_diasdep(segdis2.ccesta);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ivaluni := NULL;
                     ivalunishw := NULL;
                     breserva := FALSE;
               END;

               vnmaxuni := 0;
               vnmaximporte := 0;
               vtotalcestas := 0;
               nerror := pac_operativa_finv.f_cta_saldo_fondos_cesta(psseguro, NULL,
                                                                     segdis2.ccesta, vnmaxuni,
                                                                     vnmaximporte,
                                                                     vtotalcestas);

               IF nerror <> 0 THEN
                  RAISE data_error;
               END IF;

               vnmaxunishw := 0;
               vnmaximporteshw := 0;
               vtotalcestas := 0;
               nerror := pac_operativa_finv.f_cta_saldo_fondos_cesta_shw(psseguro, NULL,
                                                                         segdis2.ccesta,
                                                                         vnmaxunishw,
                                                                         vnmaximporteshw,
                                                                         vtotalcestas);

               IF nerror <> 0 THEN
                  RAISE data_error;
               END IF;

               vpexec := 10;

               FOR reg IN (SELECT DISTINCT cgarant
                                      FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm
                                     WHERE sgcm.scaumot = scm.scaumot
                                       AND scm.ccausin = pcausin
                                       AND scm.cmotsin = pcmotsin
                                       AND sgcm.sproduc = psproduc
                                       AND sgcm.cactivi = pscactivi) LOOP
                  nerror := pac_sin_rescates.f_ins_prereserva_fnd(pnsinies, pntramit,
                                                                  pffecmov, segdis2.ccesta,
                                                                  vnmaximporte, vnmaxuni,
                                                                  ivaluni, pretenc, pipenal,
                                                                  reg.cgarant,
                                                                  vnmaximporteshw, ivalunishw,
                                                                  vnmaxunishw);

                  IF nerror <> 0 THEN
                     RAISE data_error;
                  END IF;
               END LOOP;
            END LOOP;

            IF breserva THEN
               ireserva := pimporte;
            END IF;
         END IF;
      END IF;

      IF breserva THEN
         vpexec := 11;

         FOR reg IN (SELECT DISTINCT cgarant
                                FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm
                               WHERE sgcm.scaumot = scm.scaumot
                                 AND scm.ccausin = pcausin
                                 AND scm.cmotsin = pcmotsin
                                 AND sgcm.sproduc = psproduc
                                 AND sgcm.cactivi = pscactivi) LOOP
            vcgarant := reg.cgarant;
            nerror := pac_siniestros.f_ins_reserva(pnsinies, pntramit, 1, reg.cgarant, 1,
                                                   pffecmov, NULL,
                                                   NVL(ireserva, 0) - NVL(pipenal, 0), NULL,
                                                   NVL(ireserva, 0), pipenal, NULL, NULL,
                                                   NULL, NULL, NULL, NULL, NULL, NULL,
                                                   vnmovres, NULL);

            IF nerror <> 0 THEN
               RETURN nerror;
            END IF;
         END LOOP;

         IF NVL(f_parproductos_v(psproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
            vppagdes := 1;
         ELSE
            vppagdes := 0;
         END IF;

         nerror := pac_sin_rescates.f_ins_destinatario(pnsinies, pntramit, psseguro, pnriesgo,
                                                       vppagdes, 1, 1, NULL, NULL, NULL, NULL);

         IF nerror <> 0 THEN
            RETURN nerror;
         END IF;

         IF pipenal IS NOT NULL
            OR pretenc IS NOT NULL THEN
            nerror := pac_sin_formula.f_genera_pago(psseguro, pnriesgo, vcgarant, psproduc,
                                                    pscactivi, pnsinies, pntramit, pcausin,
                                                    pcmotsin, pffecmov, pffecmov, NULL, NULL,
                                                    pipenal, pretenc);
         ELSE
            nerror := pac_sin_formula.f_genera_pago(psseguro, pnriesgo, vcgarant, psproduc,
                                                    pscactivi, pnsinies, pntramit, pcausin,
                                                    pcmotsin, pffecmov, pffecmov);
         END IF;

         IF nerror <> 0 THEN
            RETURN nerror;
         END IF;

         nerror := pac_sin_formula.f_inserta_pago(pnsinies, pntramit, 1, vcgarant, vsidepag,
                                                  vipago);

         IF nerror <> 0 THEN
            RETURN nerror;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN data_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9904148, vpexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 9904148;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, 99, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 140999;
   END f_inserta_reserva_fondon;
END pac_md_sin_rescates;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_RESCATES" TO "PROGRAMADORESCSI";
