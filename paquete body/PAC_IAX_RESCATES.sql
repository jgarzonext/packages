--------------------------------------------------------
--  DDL for Package Body PAC_IAX_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_RESCATES" AS
/*****************************************************************************
   NAME:       PAC_IAX_RESCATES
   PURPOSE:    Funciones de rescates para productos financieros

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   JRH             1. Creación del package.
   2.0        07/05/2008   JRH             2. 0009596: CRE - Rescates y promoción nómina en producto PPJ
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;

   ------- Funciones internes

   --JRH 03/2008
     /*************************************************************************
      Valida si se puede realizar el rescate
      param in psseguro  : póliza
      param in pnriesgo  : riesgo
      param in pfecha     : fecha del rescate
      param in pccausin  : tipo oper ( 4 --> rescate total)
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_permite_rescate(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pccausin IN NUMBER,
      pimporte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfecha= ' || pfecha
            || ' pccausin= ' || pccausin || ' pccausin= ' || pccausin;
      vobject        VARCHAR2(200) := 'PAC_IAX_RESCATES.f_valida_permite_rescate';
      v_sproduc      NUMBER;
      v_norden       NUMBER;
      num            NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pccausin IS NULL THEN
         RAISE e_param_error;
      END IF;

      numerr := pac_md_rescates.f_valida_permite_rescate(psseguro, pnriesgo, pfecha, pccausin,
                                                         pimporte, mensajes);

      IF numerr <> 0 THEN
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
       param in pfecha     : pfecha del rescate
       pimporte           : Importe del rescate (nulo si es total)
       pipenali           : Importe penalización
       tipoOper           : 3 en rescate total , 4 en rescate parcial.
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_rescate_poliza(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pipenali IN NUMBER,   -- BUG 9596 - 19/05/2009 - JRH - 0009596: CRE - Rescates y promoción nómina en producto PPJ  (pasar l apenalización por parámetro)
      tipooper IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfecha= ' || pfecha
            || ' pimporte= ' || pimporte || ' tipoOper= ' || tipooper;
      vobject        VARCHAR2(200) := 'PAC_IAX_RESCATES.f_rescate_poliza';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR tipooper IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_md_rescates.f_rescate_poliza(psseguro, pnriesgo, pfecha, pimporte,
                                                 pipenali, tipooper, mensajes);

      IF numerr <> 0 THEN
         --PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr); -- el producto no permite rescates
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 111313);
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
   END f_rescate_poliza;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
      Valida y realiza la simulación de un rescate
      param in psseguro  : póliza
      param in pnriesgo  : riesgo
      param in pfecha     : pfecha del rescate
      pimporte           : Importe del rescate (nulo si es total)
      pccausin           : 4 en rescate total , 5 en rescate parcial.
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valor_simulacion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pccausin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_simrescate IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfecha= ' || pfecha
            || ' pimporte= ' || pimporte || ' pccausin= ' || pccausin;
      vobject        VARCHAR2(200) := 'PAC_IAX_RESCATES.f_Valor_Simulacion';
      num_err        NUMBER;
      w_cgarant      NUMBER;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      ximport        NUMBER;
      mostrar_datos  NUMBER;
      cavis          NUMBER;
      simresc        ob_iax_simrescate;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pccausin IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vpasexec := 2;
      numerr := pac_md_rescates.f_valor_simulacion(psseguro, pnriesgo, pfecha, pimporte,
                                                   pccausin, simresc, mensajes);

      IF numerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN simresc;
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
         RETURN NULL;
   END f_valor_simulacion;
--JRH 03/2008

/*************************************************************************
       Inicializa el objeto con los datos de simulación
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in pfecha     : pfecha del rescate
       param out mensajes : mensajes de error
      return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
/*   FUNCTION f_Inicializar(psseguro in NUMBER,
                                pnriesgo in NUMBER,
                                pfecha in DATE,
                                mensajes OUT T_IAX_MENSAJES) RETURN OB_IAX_SIMRESCATE IS
        numerr    NUMBER:=0;
        vpasexec NUMBER(8):=1;
        vparam VARCHAR2(200):='psproduc= '|| psseguro||' pnriesgo= '|| pnriesgo||' pfecha= '|| pfecha||' pccausin= '|| pccausin||' pimporte='||pimporte;
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

        IF psseguro is null OR pnriesgo is null OR pfecha is null THEN
            RAISE e_param_error;
        END IF;

        vpasexec:=1;

        return (f_Inicializarr(psseguro  pnriesgo  ,  pfecha, mensajes));





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
END pac_iax_rescates;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RESCATES" TO "PROGRAMADORESCSI";
