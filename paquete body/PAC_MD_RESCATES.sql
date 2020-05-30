--------------------------------------------------------
--  DDL for Package Body PAC_MD_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_RESCATES" AS
/*****************************************************************************
   NAME:       PAC_MD_RESCATES
   PURPOSE:    Funciones de rescates para productos financieros

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   JRH             1. Creación del package.
   2.0        07/05/2008   JRH             2. 0009596: CRE - Rescates y promoción nómina en producto PPJ
   3.0        19/02/2010   ICV             3. 0013274: ERROR EN RESCATES PIAS
   4.0        13/07/2011   DRA             4. 0019054: CIV800-No funcionen les sol?licituds de rescats a Beta
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   ------- Funciones internes
   v_nmovimi      NUMBER;
   v_est_sseguro  NUMBER;
   sim            ob_iax_simrescate;

/*************************************************************************
       Inicializa el objeto con los datos de simulación
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fecha     : fecha del rescate
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                          1 ha habido un error
    *************************************************************************/
 /*   FUNCTION f_Inicializar(psseguro in NUMBER,
                                pnriesgo in NUMBER,
                                fecha in DATE,
                                mensajes IN OUT T_IAX_MENSAJES) RETURN OB_IAX_SIMRESCATE IS
        numerr    NUMBER:=0;
        vpasexec NUMBER(8):=1;
        vparam VARCHAR2(200):='psproduc= '|| psseguro||' pnriesgo= '|| pnriesgo||' fecha= '|| fecha||' pccausin= '|| pccausin||' pimporte='||pimporte;
        vobject VARCHAR2(200):='PAC_MD_RESCATES.f_Valor_Simulacion';
        num_err      NUMBER;
        w_cgarant    NUMBER;
        v_sproduc    number;
        v_cactivi    number;
        ximport      number;
        mostrar_datos   number;
        cavis number;
        Salida EXCEPTION;

        res Pk_Cal_Sini.t_val;
    BEGIN

        IF psseguro is null OR pnriesgo is null OR fecha is null THEN
            RAISE e_param_error;
        END IF;

        vpasexec:=1;

        sim:=NULL;



         RETURN sim;

    EXCEPTION
    WHEN e_param_error THEN
        ROLLBACK;
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        RETURN 1;
    WHEN e_object_error THEN
        ROLLBACK;
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        RETURN 1;
    WHEN Salida THEN
        ROLLBACK;
        RETURN 1;
    WHEN OTHERS THEN
        ROLLBACK;
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        RETURN 1;
    END f_Inicializar;
     --JRH 03/2008
*/

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || fecha
            || ' pccausin= ' || pccausin;
      vobject        VARCHAR2(200) := 'PAC_MD_RESCATES.f_valida_permite_rescate';
      v_sproduc      NUMBER;
      v_norden       NUMBER;
      num            NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR fecha IS NULL
         OR pccausin IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Bug.: 10615 - 09/07/2009 - ICV - Revisió de la parametrització d'accions (Se llama a la función f_valida_permite_rescate de la capa de negocio)
      vpasexec := 2;
      numerr := pac_rescates.f_valida_permite_rescate(psseguro, NULL, fecha, pccausin,
                                                      pimporte);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- el producto no permite rescates
         RAISE e_object_error;
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
   END f_valida_permite_rescate;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
       Valida y realiza un rescate
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fecha     : fecha del rescate
       pimporte           : Importe del rescate (nulo si es total)
       pipenali           : Importe de penalización
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
      pipenali IN NUMBER,   -- BUG 9596 - 19/05/2009 - JRH - 0009596: CRE - Rescates y promoción nómina en producto PPJ  (pasar l apenalización por parámetro)
      tipooper IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || fecha
            || ' tipoOper= ' || tipooper || ' pimporte= ' || pimporte;
      vobject        VARCHAR2(200) := 'PAC_MD_RESCATES.f_rescate_poliza';
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
      --pipenali     NUMBER:=NULL;
      pireduc        NUMBER := NULL;
      pireten        NUMBER := NULL;
      pirendi        NUMBER := NULL;
      pnivel         NUMBER := 1;
      cavis          NUMBER;
      pdatos         NUMBER;
      xnivel         NUMBER;
      salida         EXCEPTION;
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
                                         mensajes);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- BUG19054:DRA:13/07/2011
         RAISE salida;
      END IF;

      vpasexec := 4;
      numerr := pac_rescates.f_avisos_rescates(psseguro, fecha, pimporte, cavis, pdatos);

      IF cavis IS NOT NULL THEN
         xnivel := 2;   -- no se generan datos
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, cavis);
      ELSE
         xnivel := 1;   -- se generarán también los pagos
      END IF;

      vpasexec := 5;
      numerr := pac_rescates.f_sol_rescate(psseguro, reg_seg.sproduc,
                                           f_parinstalacion_n('MONEDAINST'), NULL, gidioma,
                                           tipooper, pimporte, fecha, NVL(pipenali, 0), NULL,
                                           NULL, NULL, xnivel);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- error gestionando siniestro
         RETURN 1;
      END IF;

      vpasexec := 6;

      IF numerr <> 0 THEN
         RAISE salida;
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
      simresc IN OUT ob_iax_simrescate,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || fecha
            || ' pccausin= ' || pccausin || ' pimporte=' || pimporte;
      vobject        VARCHAR2(200) := 'PAC_MD_RESCATES.f_Valor_Simulacion';
      w_cgarant      NUMBER;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      ximport        NUMBER;
      mostrar_datos  NUMBER;
      cavis          NUMBER;
      salida         EXCEPTION;
      datecon        ob_iax_datoseconomicos;
      v_cagente      NUMBER;
      res            pk_cal_sini.t_val;
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
      numerr := f_valida_permite_rescate(psseguro, pnriesgo, fecha, pccausin, pimporte,
                                         mensajes);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- BUG19054:DRA:13/07/2011
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
         ximport := NULL;
      END IF;

      -- BUG19054:DRA:13/07/2011:Canviem el num_err per numerr
      numerr := pac_rescates.f_simulacion_rescate(psseguro, v_cagente, pccausin, ximport,
                                                  fecha, res);

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
         numerr := pac_rescates.f_avisos_rescates(psseguro, fecha, res(1).isinret, cavis,
                                                  mostrar_datos);

         IF cavis IS NOT NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, cavis);
         END IF;

         -- BUG19054:DRA:13/07/2011:Inici
         IF numerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- BUG19054:DRA:13/07/2011
            RAISE salida;
         END IF;
      -- BUG19054:DRA:13/07/2011:Fi
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
END pac_md_rescates;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_RESCATES" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RESCATES" TO "CONF_DWH";
