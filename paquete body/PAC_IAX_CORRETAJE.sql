--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CORRETAJE
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PAC_IAX_CORRETAJE" AS
   /******************************************************************************
      NOMBRE:      PAC_IAX_CORRETAJE
      PROPÓSITO:   Contiene las funciones de gestión del Co-corretaje

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/09/2011   DRA               1. 0019069: LCOL_C001 - Co-corretaje
      2.0        17/07/2019   DFR               2. IAXIS-3591: Visualizar los importes del recibo de manera ordenada 
                                                   y sin repetir conceptos.
      3.0        01/11/2019   CJMR              3. IAXSI-5428. Al cambiar intermediario, se debe cambiar el intermediario líder del corretaje
      4.0        21/01/2020   JLTS              4. IAXIS-10627. Se ajustó la función f_trapaso_intermediario incluyendo el parámetro NMOVIMI en f_partpolcorretaje y f_leecorretaje
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_calcular_comision_corretaje(
      pcagente IN NUMBER,
      pnriesgo IN NUMBER,
      ppartici IN NUMBER,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
         := 'pcagente: ' || pcagente || ', pnriesgo: ' || pnriesgo || ', ppartici: '
            || ppartici;
      vobject        VARCHAR2(200) := 'PAC_IAX_CORRETAJE.f_calcular_comision_corretaje';
      vnumerr        NUMBER := 0;
      poliza         ob_iax_detpoliza := ob_iax_detpoliza();
   BEGIN
      vpasexec := 1;
      poliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 2;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_corretaje.f_calcular_comision_corretaje(poliza.sseguro, pnriesgo,
                                                                poliza.nmovimi,
                                                                poliza.gestion.fefecto,
                                                                poliza.cramo, poliza.cmodali,
                                                                poliza.ctipseg, poliza.ccolect,
                                                                poliza.gestion.cactivi,
                                                                NVL(pcagente, poliza.cagente),
                                                                pac_iax_produccion.vpmode,
                                                                ppartici, ppcomisi, ppretenc,
                                                                mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_calcular_comision_corretaje;
   --
   -- Inicio IAXIS-3591 17/07/2019       
   --
   /*******************************************************************************
    FUNCION f_leecorretaje
    Función que obtiene los importes de comisión del recibo inclusive si existe Co-corretaje
    param in psseguro   -> Número de seguro
    param in pnrecibo   -> Número de recibo
    return              -> Cursor con importes de comisión aplicados por agente
    ********************************************************************************/
   FUNCTION f_leecorretaje(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(100)
         := 'psseguro: ' || psseguro || ', pnrecibo: ' || pnrecibo;
      vobject        VARCHAR2(200) := 'pac_iax_corretaje.f_leecorretaje';
      vcursor SYS_REFCURSOR;
   BEGIN
     
      vpasexec := 1;

      IF psseguro IS NULL OR 
        pnrecibo IS NULL 
        THEN
          vpasexec := 2;
          RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vcursor  := pac_md_corretaje.f_leecorretaje(psseguro, pnrecibo, mensajes);
      vpasexec := 4;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         IF vcursor%ISOPEN THEN
           CLOSE vcursor;
         END IF;
         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         IF vcursor%ISOPEN THEN
           CLOSE vcursor;
         END IF;
         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         IF vcursor%ISOPEN THEN
           CLOSE vcursor;
         END IF;
         RETURN vcursor;
   END f_leecorretaje;
   --
   -- Fin IAXIS-3591 17/07/2019       
   --
   -- INI IAXIS-5428 01/11/2019
   /******************************************************************
    Función f_trapaso_intermediario
    PROPÓSITO:  Función que traspasa los datos de corretaje
   *******************************************************************/
   FUNCTION f_trapaso_intermediario(
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      poliza         ob_iax_detpoliza := ob_iax_detpoliza();
      corret         t_iax_corretaje;
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(100) := 'pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'pac_iax_corretaje.f_trapaso_intermediario';
      v_cont_age     NUMBER := 0;
      vnumerr        NUMBER := 0;
   BEGIN

      IF pcagente IS NULL THEN
          RAISE e_param_error;
      END IF;
      
      vpasexec := 1;
      poliza := pac_iobj_prod.f_getpoliza(mensajes);
      
      vpasexec := 2;
      SELECT NVL(COUNT(*), 0)
      INTO v_cont_age
      FROM age_corretaje c
      WHERE c.sseguro = poliza.ssegpol
      AND c.cagente = pcagente
      AND c.nmovimi = PAC_ISQLFOR_CONF.f_get_ultmov(c.sseguro,1);
                       
      IF v_cont_age > 0 THEN
          vpasexec := 3;
          pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9902560 );
          RAISE e_object_error;
      END IF;
      
      vpasexec := 4;
      -- INI -IAXIS-10627 -21/01/2020
      corret := pac_iobj_prod.f_partpolcorretaje (poliza, null, mensajes);
      -- FIN -IAXIS-10627 -21/01/2020
      
      IF corret IS NOT NULL THEN
         IF corret.COUNT > 0 THEN
            vpasexec := 5;
            
            FOR vcorr IN corret.FIRST .. corret.LAST LOOP
               vpasexec := 6;
               
               IF corret.EXISTS (vcorr) THEN
                  vpasexec := 7;

                  IF corret (vcorr).islider = 1 THEN
                     vpasexec := 8;
                     corret (vcorr).cagente := pcagente;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;
      
      vpasexec := 9;
      vnumerr := pac_md_grabardatos.f_grabarcorretaje (corret, mensajes);
      COMMIT;

      IF vnumerr <> 0 THEN
         vpasexec := 10;
         RAISE e_object_error;
      END IF;
      
      vpasexec := 11;
      pac_md_obtenerdatos.define_mode ('EST', mensajes);
      -- INI -IAXIS-10627 -21/01/2020
      pac_iax_produccion.poliza.det_poliza.corretaje := pac_md_obtenerdatos.f_leecorretaje (null,mensajes);
      -- FIN -IAXIS-10627 -21/01/2020
      pac_md_obtenerdatos.define_mode (pac_iax_produccion.vpmode, mensajes);

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
   END f_trapaso_intermediario;
   -- FIN IAXIS-5428 01/11/2019
   
   -- Inicio IAXIS-12960 05/03/2020      
   --
   /*******************************************************************************
    FUNCION f_corretaje
    Función que obtiene los valores de sucursal, participacion y intermediario lider del recibo cuando existe Co-corretaje
    param in pnrecibo   -> Número de recibo
    return              -> Cursor con valores de cada intermediario
    ********************************************************************************/  
   FUNCTION f_corretaje(pnrecibo IN NUMBER,
                        mensajes OUT t_iax_mensajes)
                        RETURN SYS_REFCURSOR IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(100) := 'pnrecibo: ' || pnrecibo;
      vobject        VARCHAR2(200) := 'pac_iax_corretaje.f_corretaje';
      vcursor SYS_REFCURSOR;
   BEGIN

      vpasexec := 1;

      IF pnrecibo IS NULL 
        THEN
          vpasexec := 2;
          RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vcursor  := pac_md_corretaje.f_corretaje(pnrecibo, mensajes);
      vpasexec := 4;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         IF vcursor%ISOPEN THEN
           CLOSE vcursor;
         END IF;
         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         IF vcursor%ISOPEN THEN
           CLOSE vcursor;
         END IF;
         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         IF vcursor%ISOPEN THEN
           CLOSE vcursor;
         END IF;
         RETURN vcursor;
   END f_corretaje;
   --
   -- FIN IAXIS-12960 05/03/2020   

END pac_iax_corretaje;
/