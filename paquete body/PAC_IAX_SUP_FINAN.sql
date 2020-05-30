--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SUP_FINAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SUP_FINAN" AS
/*****************************************************************************
   NAME:       PAC_IAX_RESCATES
   PURPOSE:    Funciones de suplementos para productos financieros

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   JRH             1. Creación del package.
   2.0        11/11/2009   JRB             2. Se añade ctipban a la aportación
   3.0        07/06/2011   ICV                3. 0018632: ENSA102-Aportaciones a nivel diferente de tomador
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;

   ------- Funciones internes
   FUNCTION iniciarsuple
      RETURN NUMBER IS
   BEGIN
      RETURN(pac_md_sup_finan.iniciarsuple);
   END;

   /*************************************************************************
         Tarifica una aportación extraordinaria
         param in psseguro  : póliza
         param in pnriesgo  : riesgo
         param in pfecha     : pfecha de la aportación
         pimporte           : Importe de la aportación
         capitalGaran out   : Capital garantizado en el suplemento
         param out mensajes : mensajes de error
         return             : 0 todo correcto
                              1 ha habido un error
      *************************************************************************/
   FUNCTION f_tarif_aport_extraordinaria(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pcgarant IN NUMBER,
      capitalgaran OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= ' || pcgarant
            || ' pfecha= ' || pfecha || ' pimporte= ' || pimporte;
      vobject        VARCHAR2(200) := 'PAC_IAX_SUP_FINAN.f_tarif_aport_extraordinaria';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pcgarant IS NULL
         OR pimporte IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_md_sup_finan.f_tarif_aport_extraordinaria(psseguro, pnriesgo, pfecha,
                                                              pimporte, pcgarant, capitalgaran,
                                                              mensajes);

      IF numerr <> 0 THEN
         --PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr); -- el producto no permite SUP_FINAN
         RETURN 1;
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
   END f_tarif_aport_extraordinaria;

   --JRH 03/2008

   --JRH 03/2008
    /*************************************************************************
       Valida y realiza una aportación extraordinaria
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in pfecha     : pfecha de la aportación
       pimporte           : Importe de la aportación
       pctipban           : Tipo de cuenta.
       pcbancar           : Cuenta bancaria.
       param out mensajes : mensajes de error
       pctipapor in       : Tipo de aportación
       psperapor in       : Persona aportante
       ptipoaportante in  : Tipo de aportante
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_aportacion_extraordinaria(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pctipapor IN NUMBER DEFAULT NULL,
      psperapor IN NUMBER DEFAULT NULL,
      pcobrorec IN NUMBER DEFAULT 1,
      pccobban IN NUMBER DEFAULT NULL,
      ptipoaportante IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= ' || pcgarant
            || ' pfecha= ' || pfecha || ' pimporte= ' || pimporte || ' pctipban= ' || pctipban
            || ' pcbancar= ' || pcbancar || ' pctipapor=' || pctipapor || ' psperapor= '
            || psperapor;
      vobject        VARCHAR2(200) := 'PAC_IAX_SUP_FINAN.f_aportacion_extraordinaria';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pimporte IS NULL
         OR pcgarant IS NULL THEN
         --OR pctipban IS NULL THEN
         --OR pcbancar IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_md_sup_finan.f_aportacion_extraordinaria(psseguro, pnriesgo, pfecha,
                                                             pimporte, pctipban, pcbancar,
                                                             pcgarant, pnmovimi, mensajes, 1,
                                                             pctipapor, psperapor, pcobrorec,
                                                             pccobban, ptipoaportante);

      IF numerr <> 0 THEN
         -- PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr); -- el producto no permite rescates
         RETURN 1;
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
   END f_aportacion_extraordinaria;

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

   --Bug.: 18632 - ICV - 06/06/2011

   /*************************************************************************
   param in psseguro  : póliza
   param out mensajes : mensajes de error
   return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_aportantes(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_MD_SUP_FINAN.f_get_aportantes';
   BEGIN
      cur := pac_md_sup_finan.f_get_aportantes(psseguro, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_aportantes;

   /*************************************************************************
   param in pctipapor  : Tipo Aportante
   param in psseguro : Identificador del seguro
   param out psperapor  : Sperson del aportante
   param out pcagente  : Cagente del aportante
   param out mensajes : mensajes de error
   return             : 0 correcto 1 error
   *************************************************************************/
   FUNCTION f_get_infoaportante(
      pctipapor IN NUMBER,
      psseguro IN NUMBER,
      psperapor OUT NUMBER,
      pcagente OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'pctipapor= ' || pctipapor;
      vobject        VARCHAR2(200) := 'PAC_IAX_SUP_FINAN.f_get_infoaportante';
   BEGIN
      num_err := pac_md_sup_finan.f_get_infoaportante(pctipapor, psseguro, psperapor,
                                                      pcagente, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RETURN 1;
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
   END f_get_infoaportante;
--Fi Bug.: 18632
END pac_iax_sup_finan;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SUP_FINAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SUP_FINAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SUP_FINAN" TO "PROGRAMADORESCSI";
