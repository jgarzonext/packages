--------------------------------------------------------
--  DDL for Package Body PAC_MD_VALIDACIONES_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_VALIDACIONES_AHO" AS
/******************************************************************************
   NAME:       PAC_MD_VALIDACIONES_AHO
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   JRH             1. Creación del package.
   2.0        08/05/2009   APD             2. Bug 9922: se añade el parametro porigen a la funcion
                                              pac_limites_ahorro.ff_importe_por_aportar_persona
   3.0        16/12/2009   JRH             3. Bug 0012414: Quitar del pac_md_validaciones_aho validación de periodo respecto duracion
   4.0        05/01/2010   JMF             4. Bug 0012549 CIV - ESTRUC - Prima múltiplo de 100
   5.0        11/03/2010   DRA             5. 0013360: MODIFICACIONS RENDES VITALICIES
   6.0        22/03/2010   ICV             6. 0013640: CRE202 - Nuevo control en fecha vencimiento producto PPJ Garantit
   7.0        24/03/2010   JRH             7. 0012136: CEM - RVI - Verificación productos RVI
   8.0        26/04/2010   JRH             8. Se añade interes y fppren
   9.0        30/06/2010   ICV             9. 0015145: GRC - Capital garantía múltiplo
   10.0       18/02.2013   NMM            10. 24497#c134060.Rendes vitalícies
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;

   ------- Funciones internes

   --JRH 03/2008
   /*************************************************************************
        Valida la fecha de próximo pago de la renta
        param in psproduc  : código de producto
        param in pfppren  : fecha próxima renta
        param in pfefecto  : fecha efecto de la póliza
        param out mensajes : mensajes de error
        return             : 0 todo correcto
                             1 ha habido un error
     *************************************************************************/
   FUNCTION f_valida_fppren(
      psproduc IN seguros.sproduc%TYPE,
      pfppren IN DATE,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
                 := 'psproduc= ' || psproduc || ' pfppren= ' || TO_CHAR(pfppren, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.f_valida_fppren';
      num            NUMBER;
   BEGIN
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 0 THEN   --JRH Si no es un producto de rentas no ha de validarse
         RETURN 0;
      END IF;

      IF pfppren IS NULL THEN
         RETURN 0;
      END IF;

      IF pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- NMM.02.2013.24497#c134060.Rendes vitalícies.i.
      IF TO_CHAR(pfefecto, 'YYYYMM') > TO_CHAR(pfppren, 'YYYYMM') THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904939);   --JRH IMP Falta
         RETURN(1);
      END IF;

      -- Comprovem que comenci per 01
      IF SUBSTR(TO_CHAR(pfppren), 1, 2) <> '01' THEN
         -- La data del primer pagament de renda ha de començar per 01.
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904937);
         RETURN(1);
      END IF;

      --.f.
      RETURN(0);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
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
   END f_valida_fppren;

   --JRH 03/2008
     /*************************************************************************
          Valida el valor del interés técnico.
          param in psproduc  : código de producto
          param in pinttec  : interés
          param out mensajes : mensajes de error
          return             : 0 todo correcto
                               1 ha habido un error
       *************************************************************************/
   FUNCTION f_valida_inttec(
      psproduc IN seguros.sproduc%TYPE,
      pinttec IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc= ' || psproduc || ' pinttec= ' || pinttec;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.f_valida_inttec';
      num            NUMBER;
   BEGIN
      IF pinttec IS NULL THEN
         RETURN 0;
      END IF;

      IF pinttec NOT BETWEEN 0 AND 100 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107403);
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
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
   END f_valida_inttec;

   --JRH 03/2008
   /*************************************************************************
        Valida la forma de pago de la renta según la parametrización del producto
        param in psproduc  : código de producto
        param in pforpagren  : código de forma de pago de la renta
        param out mensajes : mensajes de error
        return             : 0 todo correcto
                             1 ha habido un error
     *************************************************************************/
   FUNCTION f_valida_forma_pago_renta(
      psproduc IN seguros.sproduc%TYPE,
      pforpagren IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc= ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.f_valida_forma_pago_renta';
      num            NUMBER;
   BEGIN
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 0 THEN   --JRH Si no es un producto de rentas no ha de validarse
         RETURN 0;
      END IF;

      IF psproduc IS NULL
         OR pforpagren IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002192);
         RETURN 1;
      END IF;

      SELECT 1
        INTO num
        FROM forpagren f
       WHERE f.sproduc = psproduc
         AND f.cforpag = pforpagren;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
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
   END f_valida_forma_pago_renta;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
       Valida el % de reversión de la renta según la parametrización del producto
       param in psproduc  : código de producto
       param in prevers  : % Reversión
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_valida_pct_revers(
      psproduc IN seguros.sproduc%TYPE,
      prevers IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      xcpctrev       producto_ren.cpctrev%TYPE;
      xnpctrev       producto_ren.npctrev%TYPE;
      xnpctrevmin    producto_ren.npctrevmin%TYPE;
      xnpctrevmax    producto_ren.npctrevmax%TYPE;
      vparam         VARCHAR2(100) := 'psproduc= ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.f_valida_pct_revers';
      poliza         ob_iax_detpoliza := pac_iobj_prod.f_getpoliza(mensajes);   --Objeto póliza
      toma           t_iax_tomadores;
      tablariesg     t_iax_riesgos;
      tablaaseg      t_iax_asegurados;
   BEGIN
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 0 THEN   --JRH Si no es un producto de rentas no ha de validarse
         RETURN 0;
      END IF;

      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT cpctrev, npctrev, npctrevmin, npctrevmax
        INTO xcpctrev, xnpctrev, xnpctrevmin, xnpctrevmax
        FROM producto_ren
       WHERE sproduc = psproduc;

      vpasexec := 3;
      -- Bug 0012414 - JRH - 17/12/2009 - 0012414: Si hay 1 asegurado, pctrevers ha de ser = 0
      tablariesg := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);
      vpasexec := 4;

      IF tablariesg IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 4567, 'No existen tomadores');
         vpasexec := 5;
         RAISE e_object_error;
      ELSE
         IF tablariesg.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 4587, 'No existen tomadores');
            vpasexec := 6;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 7;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 8;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 9;
      tablaaseg := tablariesg(1).riesgoase;
      vpasexec := 10;

      IF tablaaseg IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 4567, 'No existen asegurados');
         vpasexec := 11;
         RAISE e_object_error;
      END IF;

      IF xcpctrev IS NULL THEN
         IF prevers IS NOT NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180593);
            RETURN 1;
         END IF;
      ELSE
         IF prevers IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180587);
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 12;

      IF tablaaseg.COUNT < 2 THEN
         IF NVL(prevers, 0) <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180593);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 13;

      -- Bug 12136 - 24/03/2010 - JRH - 0012136: CEM - RVI - Verificación productos RVI
      IF xcpctrev = 1 THEN
         IF tablaaseg.COUNT >= 2 THEN   --Sólo validamos el % revers. si hay dos cabezas
            IF prevers <> xnpctrev THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180594);
               RETURN 1;   --No debe tener pct revers. Crear mas mensajes.
            END IF;
         END IF;
      ELSIF xcpctrev = 2 THEN
         IF tablaaseg.COUNT >= 2 THEN   --Sólo validamos el % revers. si hay dos cabezas
            IF prevers NOT BETWEEN NVL(xnpctrevmin, 0) AND NVL(xnpctrevmax, 0) THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180595);
               RETURN 1;   --No debe tener pct revers. Crear mas mensajes.
            END IF;
         END IF;
      END IF;

      -- Fi Bug 12136 - 24/03/2010 - JRH
      vpasexec := 14;
-- Fi Bug 0012414 - JRH - 17/12/2009
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_pct_revers;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
       Valida el % de reserva fallec. de la renta según la parametrización del producto
       param in psproduc  : código de producto
       param in pfallec  : % fallecimiento
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_valida_percreservcap(
      psproduc IN seguros.sproduc%TYPE,
      pfallec IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc= ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.f_valida_percreservcap';
      xcduraci       NUMBER;
      vcpctfall      NUMBER;
      vnpctfall      NUMBER;
      vnpctfallmin   NUMBER;
      vnpctfallmax   NUMBER;
   BEGIN
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 0 THEN   --JRH Si no es un producto de rentas no ha de validarse
         RETURN 0;
      END IF;

      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      --JRH De momento validamos que sea un porcentaje
      vpasexec := 2;

      IF pfallec IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180591);
         RETURN 1;
      END IF;

      IF pfallec < 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 111260);
         RETURN 1;
      END IF;

      --IF NOT(pfallec BETWEEN 0 AND 105) THEN   --JRH Ponemos de momento 105
      --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180592);
      --   RETURN 1;
      --END IF;
      SELECT cpctfall, npctfall, npctfallmin, npctfallmax
        INTO vcpctfall, vnpctfall, vnpctfallmin, vnpctfallmax
        FROM producto_ren
       WHERE sproduc = psproduc;

      vpasexec := 3;

      -- Bug 12136 - 24/03/2010 - JRH - 0012136: CEM - RVI - Verificación productos RVI
      IF vcpctfall IS NOT NULL THEN
         IF vcpctfall = 1 THEN   --Fijo
            IF pfallec <> vnpctfall THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180592);
               RETURN 1;   --No coincide el capital de fallecimiento
            END IF;
         ELSIF vcpctfall = 2 THEN   -- Variable
            IF pfallec NOT BETWEEN NVL(vnpctfallmin, 0) AND NVL(vnpctfallmax, 0) THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180592);
               RETURN 1;   --No coincide el capital de fallecimiento
            END IF;
         END IF;
      ELSE
         NULL;
      END IF;

      -- Fi Bug 12136 - 24/03/2010 - JRH
      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_percreservcap;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
       Valida el % periodo de revisión
       param in psproduc  : código de producto
       param in pduracion  : duración póliza
       param in pperiodo  :periodo de revisión
       param in pfefecto  :fecha efecto
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_valida_periodo(
      psproduc IN seguros.sproduc%TYPE,
      pduracion IN NUMBER,
      pperiodo IN NUMBER,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc= ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.f_valida_percreservcap';
      xcduraci       NUMBER;
   BEGIN
      --La duración ya viene validada de antes
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF NVL(f_parproductos_v(psproduc, 'DURPER'), 0) = 1 THEN
         IF pperiodo IS NULL THEN   --El periodo de revisión se ha de informar
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 109954);
            RETURN 1;
         END IF;

         vpasexec := 3;
         num_err := pac_md_validaciones.f_durper(psproduc, pperiodo, pfefecto, mensajes);

         IF num_err <> 0 THEN
            -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            -- RETURN 1;
            RAISE e_object_error;   -- BUG13360:DRA:11/03/2010
         END IF;

         vpasexec := 4;

         IF pduracion IS NOT NULL THEN
            IF pperiodo > pduracion THEN   --El periodo de revisión no puede ser superior a la revisión
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 109954);
               RETURN 1;
            END IF;

            vpasexec := 5;
         -- Bug 0012414 - JRH - 16/12/2009 - 0012414: Quitar del pac_md_validaciones_aho validación de periodo respecto duracion
         --IF MOD(pperiodo, pduracion) <> 0 THEN   --El periodo de revisión ha de ser divisor de la duración
         --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 109954);
         --   RETURN 1;
         --END IF;
         -- Fi Bug 0012414 - JRH - 16/12/2009
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_periodo;

   --JRH 03/2008

   -- BUG13360:DRA:18/03/2010:Inici
   -- bug 8286 - 04/03/2009 - AMC
   /*************************************************************************
      Valida si es obligatorio intruducir los % de reversión y fallecimiento
      param in psproduc : Código del producto
      param in prever : % reversión
      param in pcapfall : % fallecimiento
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_por_rev_fall(
      psproduc IN NUMBER,
      prever IN NUMBER,
      pcapfall IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.f_valida_por_rev_fall';
      vparam         VARCHAR2(200)
                := 'psproduc:' || psproduc || ' prever:' || prever || ' pcapfall:' || pcapfall;
      num_err        NUMBER;
      vvalpar        NUMBER;
   BEGIN
      -- Bug 8286 - AMC - 04/03/2009 - Creación de la función
      vvalpar := NVL(pac_parametros.f_parproducto_n(psproduc, 'NO_REVERS_Y_CAPFALL'), 0);

      IF vvalpar = 0 THEN
         -- BUG13360:DRA:10/03/2010:Inici
         IF NVL(pac_parametros.f_parproducto_n(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
            IF prever IS NULL
               OR pcapfall IS NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001142);
               RAISE e_object_error;
            ELSE
               RETURN 0;
            END IF;
         ELSE
            RETURN 0;
         END IF;
      -- BUG13360:DRA:10/03/2010:Fi
      ELSE
         IF NVL(prever, 0) <> 0
            AND NVL(pcapfall, 0) <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001143);
            RAISE e_object_error;
         ELSE
            RETURN 0;
         END IF;
      END IF;
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
   END f_valida_por_rev_fall;

   --Fi bug 8286 - 04/03/2009 - AMC
   -- BUG13360:DRA:18/03/2010:Inici

   --JRH 03/2008
   /*************************************************************************
       Valida todos los datos de gestión financieros de golpe
       param in psproduc  : código de producto
       param in gestion  : objeto OB_IAX_GESTION
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_valida_datosgest(
      psproduc IN seguros.sproduc%TYPE,
      gestion IN ob_iax_gestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc= ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.f_valida_datosGest';
      pforpagren     NUMBER;
      prevers        NUMBER;
      pfallec        NUMBER;
      pduracion      NUMBER;
      pperiodo       NUMBER;
      pfefecto       DATE;
      --Ini Bug.: 13640 - ICV - 17/03/2010
      poliza         ob_iax_detpoliza := pac_iobj_prod.f_getpoliza(mensajes);   --Objeto póliza
      tablariesg     t_iax_riesgos;
      tablaaseg      t_iax_asegurados;
      n_tramo        NUMBER;
      --Fin Bug.: 13640
      -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratación
      vfppren        DATE;
      vinttec        NUMBER;
   -- Fi Bug 14285 - 26/04/2010 - JRH
   BEGIN
      IF psproduc IS NULL
         OR gestion IS NULL THEN
         RAISE e_param_error;
      END IF;

      pforpagren := gestion.cforpagren;
      prevers := gestion.pdoscab;
      pfallec := gestion.pcapfall;
      pduracion := gestion.duracion;
      pperiodo := gestion.ndurper;
      pfefecto := gestion.fefecto;
      -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratación
      vfppren := gestion.fppren;
      vinttec := gestion.inttec;
      -- Fi Bug 14285 - 26/04/2010 - JRH

      --Ini Bug.: 13640 - ICV - 17/03/2010
      n_tramo := NVL(pac_parametros.f_parproducto_n(psproduc, 'VALIDA_FVENC_AHORRO'), 0);

      IF n_tramo <> 0 THEN
         tablariesg := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);
         tablaaseg := tablariesg(1).riesgoase;
         --Solo hay un asegurado
         numerr := pac_md_validaciones.f_valida_fvencim_aho(tablaaseg(1).fnacimi,
                                                            tablaaseg(1).ffecini,
                                                            gestion.fvencim, n_tramo,
                                                            mensajes);

         IF numerr > 0 THEN
            RETURN 1;
         END IF;
      END IF;

      --Fin Bug.: 13640

      -- BUG13360:DRA:18/03/2010:Inici
      --IF NVL(f_parproductos_v(psproduc, 'NO_REVERS_Y_CAPFALL'), 0) = 1 THEN   --JRH 12/2008 Si no se permite convivir a la  vez % evers. y % fallec. lo advertimos
      --   IF NVL(prevers, 0) <> 0
      --      AND NVL(pfallec, 0) <> 0 THEN
      --      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180593);
      --      RETURN 1;
      --   END IF;
      --END IF;
      numerr := f_valida_por_rev_fall(psproduc, prevers, pfallec, mensajes);

      IF numerr > 0 THEN
         RETURN 1;
      END IF;

      -- BUG13360:DRA:18/03/2010:Fi

      --La duración ya viene validada de antes
      vpasexec := 2;
      numerr := f_valida_forma_pago_renta(psproduc, pforpagren, mensajes);

      IF numerr <> 0 THEN
         RETURN 1;
      END IF;

      vpasexec := 3;
      numerr := f_valida_pct_revers(psproduc, prevers, mensajes);

      IF numerr <> 0 THEN
         RETURN 1;
      END IF;

      vpasexec := 4;
      numerr := f_valida_percreservcap(psproduc, pfallec, mensajes);

      IF numerr <> 0 THEN
         RETURN 1;
      END IF;

      vpasexec := 5;
      numerr := f_valida_periodo(psproduc, pduracion, pperiodo, pfefecto, mensajes);

      IF numerr <> 0 THEN
         RETURN 1;
      END IF;

      -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratación
      vpasexec := 6;
      numerr := f_valida_fppren(psproduc, vfppren, pfefecto, mensajes);

      IF numerr <> 0 THEN
         RETURN 1;
      END IF;

      vpasexec := 7;
      numerr := f_valida_inttec(psproduc, vinttec, mensajes);

      IF numerr <> 0 THEN
         RETURN 1;
      END IF;

      -- Fi Bug 14285 - 26/04/2010 - JRH
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_datosgest;

   --JRH 03/2008

   --JRH 03/2008
    /*************************************************************************
         Valida varios parámetros de capitales de garantías
         param in psproduc  : código de producto
         param in pcgarant  : garantía
         param in picapital  : capital
         param in ptipo  : 1 para Nueva Producción.
         param out mensajes : mensajes de error
         return             : 0 todo correcto
                              1 ha habido un error
      *************************************************************************/
   FUNCTION f_valida_capitales_gar(
      psproduc IN seguros.sproduc%TYPE,
      pcgarant IN NUMBER,
      picapital IN NUMBER,
      ptipo IN NUMBER,
      pfecha IN DATE,
      porigen IN NUMBER DEFAULT 2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc= ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.f_valida_capitales_gar';
      n              NUMBER;
      poliza         ob_iax_detpoliza := pac_iobj_prod.f_getpoliza(mensajes);   --Objeto póliza
      toma           t_iax_tomadores;
      tablariesg     t_iax_riesgos;
      tablaaseg      t_iax_asegurados;
      v_csujeto      NUMBER;
      v_anyo         NUMBER;
      v_ctipgar      NUMBER;
      pcpais         NUMBER;
      psperson       NUMBER;
      tipogar        NUMBER;
      n_capimult     NUMBER;   -- Bug 0012549 - 05/01/2010 - JMF
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF NOT(NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1
             OR NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_AHO'), 0) = 1) THEN   --JRH Si no es un producto de rentas no ha de validarse
         RETURN 0;
      END IF;

      --Lo substituimos por lo de abajo, si no da un too_many_rows en productos con varias garantias tipo 4
      --if NOT ((pac_calc_comu.f_cod_garantia(psproduc, 3, NULL, v_ctipgar) = pcgarant) OR (pac_calc_comu.f_cod_garantia(psproduc, 4, NULL, v_ctipgar)= pcgarant)) THEN
      --  Return 0; --Sólo validamos las coberturas tipo 3 o 4
      --end if;
      BEGIN
         SELECT DISTINCT NVL(f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi,
                                             cgarant, 'TIPO'),
                             0)
                    INTO tipogar
                    FROM garanpro
                   WHERE sproduc = psproduc
                     AND cgarant = pcgarant
                     AND NVL(f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi,
                                             cgarant, 'TIPO'),
                             0) IN(3, 4);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;   --Sólo validamos las coberturas tipo 3 o 4
         WHEN TOO_MANY_ROWS THEN
            NULL;
      END;

      --IF ptipo = 1 AND  -- Alta
      -- ini Bug 0012549 - 05/01/2010 - JMF
      --IF NVL(f_parproductos_v(psproduc, 'CAPMULT1000'), 0) = 1 THEN
      --   n := MOD(picapital, 1000);
      --   IF n <> 0 THEN
      --      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 153044);
      --      RETURN 1;
      --   END IF;
      --END IF;

      --Bug.: 15145 - 30/06/2010 - ICV
      /*n_capimult := NVL(f_parproductos_v(psproduc, 'CAPMULT1000'), 0);

      IF n_capimult = 1 THEN
         n := MOD(picapital, 1000);

         IF n <> 0 THEN
            RETURN 153044;
         END IF;
      ELSIF n_capimult = 2 THEN
         n := MOD(picapital, 100);

         IF n <> 0 THEN
            RETURN 9900912;
         END IF;
      ELSIF n_capimult = 3 THEN
         n := MOD(picapital, 10000);

         IF n <> 0 THEN
            RETURN 9900913;
         END IF;
      END IF;*/
      --Fin Bug.: 15145 - 30/06/2010 - ICV

      -- fin Bug 0012549 - 05/01/2010 - JMF

      --END IF;
      IF poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, -456,
                                              'No se ha inicializado correctamente');
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      tablariesg := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);
      vpasexec := 3;

      IF tablariesg IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 4567, 'No existen tomadores');
         vpasexec := 4;
         RAISE e_object_error;
      ELSE
         IF tablariesg.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 4587, 'No existen tomadores');
            vpasexec := 5;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 6;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 7;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 8;
      tablaaseg := tablariesg(1).riesgoase;
      vpasexec := 9;

      IF tablaaseg IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 4567, 'No existen tomadores');
         vpasexec := 10;
         RAISE e_object_error;
      END IF;

      vpasexec := 11;

      IF tablaaseg.EXISTS(1) THEN
         psperson := tablaaseg(1).sperson;
      END IF;

      vpasexec := 17;

      -- Si la garantía es la Prima período según forma de pago y se está en modo suplemetno, entonces no se debe
      -- validar la prima
      IF psperson IS NOT NULL
         AND NVL(f_parproductos_v(psproduc, 'APORTMAXIMAS'), 0) = 1 THEN
         IF NOT(tipogar = 3
                AND ptipo = 2) THEN
            v_anyo := TO_CHAR(pfecha, 'yyyy');

            IF picapital > NVL(pac_ppa_planes.ff_importe_por_aportar_persona(v_anyo, NULL,
                                                                             NULL, psperson,
                                                                             1, porigen),
                               0) THEN
               vpasexec := 18;   -- Se supera las aportaciones máximas por año.
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180221);
               RETURN 1;
            END IF;
         END IF;
      END IF;

      -- RSC 30/01/2008 PIAS ----------------------------------------------------------------------
      -- Si se trata de una validación en un producto PIAS se debe realizar la validación de cumulos
      IF psperson IS NOT NULL
         AND NVL(f_parproductos_v(psproduc, 'TIPO_LIMITE'), 0) <> 0 THEN
         v_anyo := TO_CHAR(pfecha, 'yyyy');

         -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen a la funcion
         -- pac_limites_ahorro.ff_importe_por_aportar_persona
         IF picapital >
               NVL
                  (pac_limites_ahorro.ff_importe_por_aportar_persona
                                                             (v_anyo,
                                                              f_parproductos_v(psproduc,
                                                                               'TIPO_LIMITE'),
                                                              psperson, pfecha, porigen),
                   0) THEN
            vpasexec := 9;   -- Se supera la aportación máxima por año o total en la totalidad de pólizas.
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180742);
            RETURN 1;
         END IF;
      -- Bug 9922 - APD - 08/05/2009 - fin
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_capitales_gar;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
        Valida las rentas irregulares
        param in nriesgo  : Número de riesgo
        param out mensajes : mensajes de error
        return             : 0 todo correcto
                             1 ha habido un error
     *************************************************************************/
   FUNCTION f_valida_rentairreg(nriesgo NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      rirr           t_iax_rentairr;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES_AHO.F_Valida_RentaIrreg';
      error          EXCEPTION;
      vparam         VARCHAR2(100) := 'nriesgo= ' || nriesgo;
      gar            t_iax_garantias;
      tgr            ob_iax_garantias;
      rie            ob_iax_riesgos;
      poliza         ob_iax_detpoliza := pac_iobj_prod.f_getpoliza(mensajes);   --Objeto póliza
      rentairreg     BOOLEAN := FALSE;

      FUNCTION existeanyo(rirr2 t_iax_rentairr, panyo IN NUMBER, pos IN NUMBER)
         RETURN BOOLEAN IS
      BEGIN
         FOR vgar2 IN rirr2.FIRST .. rirr2.LAST LOOP
            IF rirr2.EXISTS(vgar2) THEN
               IF rirr(vgar2).anyo = panyo
                  AND vgar2 <> pos THEN
                  RETURN TRUE;
               END IF;
            END IF;
         END LOOP;

         RETURN FALSE;
      END;
   BEGIN
      --JRH Validamos que existan o no los datos según se contraten o no la cobertura tipo 11
      IF poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, -456,
                                              'No se ha inicializado correctamente');
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      rie := pac_iobj_prod.f_partpolriesgo(poliza, nriesgo, mensajes);

      IF rie IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 49773,
                                              'No se ha encontrado el riesgo');
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      rirr := pac_iobj_prod.f_partrentirreg(rie, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 5;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 4;
      gar := pac_iobj_prod.f_partriesgarantias(rie, mensajes);

      IF gar IS NULL THEN
         gar := t_iax_garantias();
      END IF;

      vpasexec := 5;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 6;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 6;

      FOR vgar3 IN gar.FIRST .. gar.LAST LOOP
         vpasexec := 7;

         IF gar.EXISTS(vgar3) THEN
            IF gar(vgar3).ctipo = 11 THEN   --Si la cobertura es de tipo 11 , renta irregular
               rentairreg := TRUE;
               vpasexec := 8;

               IF gar(vgar3).cobliga = 0 THEN   --Si no está contratada , nbo pueden haber datos de rentas irregulares
                  vpasexec := 9;

                  IF (rirr IS NOT NULL) THEN
                     IF (rirr.COUNT <> 0) THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje
                                                         (mensajes, 1, 49773,
                                                          'No pueden haber rentas irregulares');   --JRH Mensaje
                        vpasexec := 10;
                        RETURN 1;
                     END IF;
                  END IF;
               ELSE
                  vpasexec := 11;

                  IF (rirr IS NULL) THEN
                     vpasexec := 12;
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 49773,
                                                          'No pueden haber rentas irregulare');   --JRH Mensaje
                     vpasexec := 3;
                     RETURN 1;
                  ELSE
                     IF (rirr.COUNT = 0) THEN   --Si  está contratada , tienen que haber datos de rentas irregulares
                        vpasexec := 14;
                        pac_iobj_mensajes.crea_nuevo_mensaje
                                                          (mensajes, 1, 49773,
                                                           'No pueden haber rentas irregulare');   --JRH Mensaje
                        vpasexec := 3;
                        RETURN 1;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 15;

      IF NOT rentairreg THEN   --Si no hay rentas irregulares contatadas no pueden existir sus datos
         IF (rirr IS NOT NULL) THEN
            vpasexec := 16;

            IF (rirr.COUNT > 0) THEN
               vpasexec := 22;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 49773,
                                                    'No pueden haber rentas irregulares');   --JRH Mensaje
               vpasexec := 17;
               RETURN 1;
            END IF;
         END IF;
      END IF;

      IF rirr IS NULL THEN
         vpasexec := 23;
         RETURN 0;
      ELSE
         IF (rirr.COUNT = 0) THEN
            vpasexec := 24;
            RETURN 0;
         END IF;
      END IF;

      FOR vgar IN rirr.FIRST .. rirr.LAST LOOP
         vpasexec := 18;

         IF rirr.EXISTS(vgar) THEN
            vpasexec := 19;

            IF existeanyo(rirr, rirr(vgar).anyo, vgar) THEN   --No pueden existir 2 registros con el mismo año
               vpasexec := 20;   -- Se mira que no se dupliquen los años
               pac_iobj_mensajes.crea_nuevo_mensaje
                                      (mensajes, 1, 180221,
                                       'No se puede duplicar el año en las rentas irregulares');
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_rentairreg;
END pac_md_validaciones_aho;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AHO" TO "PROGRAMADORESCSI";
