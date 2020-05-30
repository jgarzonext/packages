CREATE OR REPLACE PACKAGE BODY pac_iax_con IS
   /******************************************************************************
    NOMBRE:      PAC_IAX_CON
    PROPÓSITO:   Funciones para las interfases en primera capa
    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        ??/??/????   ???               1. Creación del package.
    2.0        17/12/2009   JAS               2. 0011302: CEM002 - Interface Libretas
    3.0        16/02/2010   ICV               3. 0012555: CEM002 - Interficie per apertura de llibretes
    4.0        26/08/2010   SRA               4. 14365: CRT002 - Gestion de personas
    5.0        01/09/2010   FAL               5. 14365: CRT002 - Gestion de personas
    6.0        22/11/2010   JAS               6. 13266: CIVF001 - Modificación interfases apertura y cierre de puesto (parte PL)
    7.0        10/04/2012   JMF               0021190 CRE998-CRE - Sistema de comunicaci Axis - eCredit (ver 0021187)
    8.0        07/09/2012   MDS               8. 0023588: LCOL - Canvis pantalles de prestecs
    9.0        09/10/2012   XVM               9. 0023687: Release 2. Webservices de Mutua de Propietarios
   10.0        21/03/2013   ECP              10. 0025943: LCOL_T031-LCOL - AUTOS CONTINUIDAD
   11.0        05/07/2013   MMM              11. 0027596 0008438 Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a Devuelto
   12.0        29/10/2019   DFR              12. IAXIS-6219: Error en paquete 3 de reversiones
   13.0        04/12/2019   DFR              12. IAXIS-7640: Ajuste paquete listener para Recaudos SAP
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   --Funcion que valida un usuario
   FUNCTION f_validar_usuario(
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pvalidado OUT NUMBER,
      poficina OUT NUMBER,
      ptnombre OUT VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_validar_usuario';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pusuario || '-' || ppassword;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_validar_usuario(pusuario, ppassword, pvalidado, poficina,
                                            ptnombre, psinterf, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_datos_persona(
      psip IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_datos_persona';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := psip;
      error          NUMBER;
      vcagente       NUMBER;
   BEGIN
      error := pac_md_con.f_datos_persona(psip, vcagente, psinterf, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_cuentas_persona(
      psip IN VARCHAR2,
      pcrol IN NUMBER,
      pcestado IN NUMBER,
      pcsaldo IN NUMBER,
      porigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_cuentas_persona';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                  := psip || '-' || pcrol || '-' || pcestado || '-' || pcsaldo;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_cuentas_persona(psip, pcrol, pcestado, pcsaldo, porigen, psinterf,
                                            mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_cobro_recibo(
      pnrecibo IN NUMBER,
      pcobrado OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_cobro_recibo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnrecibo;
      error          NUMBER;
      terror         VARCHAR2(2000);
   BEGIN
      error := pac_md_con.f_cobro_recibo(pnrecibo, pcobrado, psinterf, terror, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_cobro_recibo;

   -- Abrir puesto
   FUNCTION f_abrir_puesto(
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      poficina OUT VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_abrir_puesto';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pusuario;
      vtermlog       NUMBER;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_abrir_puesto(pusuario, ppassword, psinterf, poficina, vtermlog,
                                         mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_abrir_puesto;

   -- Cerrar puesto
   FUNCTION f_cerrar_puesto(
      pusuario IN VARCHAR2,
      psinterf OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_cerrar_puesto';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pusuario;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_cerrar_puesto(pusuario, psinterf, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_cerrar_puesto;

   FUNCTION f_obtener_valor_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalemp IN VARCHAR2)
      RETURN VARCHAR2 IS
      mensajes       t_iax_mensajes;
      vobject        VARCHAR2(200) := 'pac_iax_con.f_obtener_valor_axis';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pemp || '-' || pcampo || '-' || pvalemp;
      valor          int_codigos_emp.cvalaxis%TYPE;
   BEGIN
      valor := pac_md_con.f_obtener_valor_axis(pemp, pcampo, pvalemp);
      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END;

   FUNCTION f_obtener_valor_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalaxis IN VARCHAR2)
      RETURN VARCHAR2 IS
      mensajes       t_iax_mensajes;
      vobject        VARCHAR2(200) := 'pac_iax_con.f_cuentas_persona';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pemp || '-' || pcampo || '-' || pvalaxis;
      valor          int_codigos_emp.cvalemp%TYPE;
   BEGIN
      valor := pac_md_con.f_obtener_valor_emp(pemp, pcampo, pvalaxis);
      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_proceso_alta(
      pempresa IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pop IN VARCHAR2,
      pusuario IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      mensajes       t_iax_mensajes;
      vobject        VARCHAR2(200) := 'pac_md_con.f_proceso_alta';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := pempresa || '-' || psseguro || '-' || pnmovimi || '-' || pop || '-' || pusuario
            || '-' || psinterf;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_proceso_alta(pempresa, psseguro, pnmovimi, pop, pusuario,
                                         psinterf, perror);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_proceso_alta;

   FUNCTION f_lista_polizas(
      pcempres IN NUMBER,
      psnip IN VARCHAR2,
      pcsituac IN NUMBER,
      psinterf OUT NUMBER,
      pcurlistapolizas OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_lista_polizas';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pcempres;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_lista_polizas(pcempres, psnip, pcsituac, psinterf,
                                          pcurlistapolizas, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lista_polizas;

   FUNCTION f_extracto_polizas(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      psinterf OUT NUMBER,
      pcurextractopol OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_extracto_polizas';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pcempres;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_extracto_polizas(pcempres, pnpoliza, pfini, pffin, psinterf,
                                             pcurextractopol, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_extracto_polizas;

   -- Bug 0021190 - 10/04/2012 - JMF
   FUNCTION f_extracto_polizas_asegurado(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      psinterf OUT NUMBER,
      pcurextractopol OUT sys_refcursor,
      mensajes OUT t_iax_mensajes,
      psnip IN VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_extracto_polizas_asegurado';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pcempres;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_extracto_polizas_asegurado(pcempres, pnpoliza, pfini, pffin,
                                                       psinterf, pcurextractopol, mensajes,
                                                       psnip);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_extracto_polizas_asegurado;

   FUNCTION f_detalle_poliza(
      pnpoliza IN NUMBER,
      psinterf OUT NUMBER,
      pcurdetpol OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_detalle_poliza';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnpoliza;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_detalle_poliza(pnpoliza, psinterf, pcurdetpol, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_detalle_poliza;

   -- Bug 0021190 - 10/04/2012 - JMF
   FUNCTION f_detalle_poliza_asegurado(
      pnpoliza IN NUMBER,
      psinterf OUT NUMBER,
      pcurdetpol OUT sys_refcursor,
      mensajes OUT t_iax_mensajes,
      psnip IN VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_detalle_poliza_asegurado';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnpoliza;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_detalle_poliza_asegurado(pnpoliza, psinterf, pcurdetpol, mensajes,
                                                     psnip);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_detalle_poliza_asegurado;

   /*************************************************************************
                  Impresió llibreta d'estalvi
      param in  pcempres:       codi d'empresa
      param in  psseguro:       sseguro de la pòlissa
      param in  pnpoliza:       npoliza de la pòlissa
      param in  pncertif:       ncertif de la pòlissa
      param in  pnpolcia:       número de pòlissa de la companyia
      param in  pvalsaldo:      flag per indicar si cal realitzar validació de saldo
      param in  pisaldo:        saldo del moviment de llibreta a partir del qual se vol imprimir (per validacions).
      param in  pcopcion:       opció d'impressió
                                    1 -> Actualització de registres pendents
                                    2 -> Reimpressió a partir de número de seqüència
      param in  pnseq:          número de seqüència a partir del qual realitzar la reimpressió (opció d'impressió 2)
      param in  pfrimpresio     Data a partir del qual realitzar la reimpressió (opció d'impressió 2)
      param in  pnmov           número de moviments a retornar (-1 vol dir tots)
      param in  porden          ordenació de la llibreta
      param in  pcidioma        idioma de les descripcions de moviments de llibreta
      param out pcur_reg_lib    cursor/llista de moviments de llibreta impressos
      param out mensajes        missatges d'error
      return                    0/1 -> Tot OK/error
   *************************************************************************/
   FUNCTION f_imprimir_libreta(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnpolcia IN VARCHAR2,
      pvalsaldo IN NUMBER,
      pisaldo IN NUMBER,
      pcopcion IN NUMBER,
      pnseq IN NUMBER,
      pfrimpresio IN DATE,
      pnmov IN NUMBER,
      porden IN NUMBER,
      pcidioma IN NUMBER,
      pcur_reg_lib OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_IAX_CON.f_imprimir_libreta';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ' - psseguro: ' || psseguro
            || ' - pnpoliza: ' || pnpoliza || ' - pncertif: ' || pncertif || ' - pnpolcia: '
            || pnpolcia || ' - pvalsaldo: ' || pvalsaldo || ' - pisaldo: ' || pisaldo
            || ' - pcopcion: ' || pcopcion || ' - pnseq: ' || pnseq || ' - pfrimpresio: '
            || pfrimpresio || ' - pnmov: ' || pnmov || ' - porden: ' || porden
            || ' - pcidioma: ' || pcidioma;
      vpasexec       NUMBER(8) := 1;
      vnum_err       NUMBER(8) := 0;
      vcempres       NUMBER(8);
   BEGIN
      IF (psseguro IS NULL
          AND pnpoliza IS NULL
          AND pnpolcia IS NULL)
         OR pcopcion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcempres IS NULL THEN
         vcempres := pac_md_param.f_parinstalacion_nn('EMPRESADEF', mensajes);
      ELSE
         vcempres := pcempres;
      END IF;

      vpasexec := 5;
      pac_iax_login.p_iax_iniconnect(pac_parametros.f_parempresa_t(vcempres, 'USER_BBDD'));
      vpasexec := 7;
      vnum_err := pac_md_con.f_imprimir_libreta(vcempres, psseguro, pnpoliza, pncertif,
                                                pnpolcia, NVL(pvalsaldo, 0), NVL(pisaldo, 0),
                                                pcopcion, pnseq, pfrimpresio, pnmov, porden,
                                                pcidioma, pcur_reg_lib, mensajes);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, pac_md_common.f_get_cxtidioma(),
                                              vnum_err);
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
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
   END f_imprimir_libreta;

   --Ini Bug.: 0012555 - ICV - 16/02/2010 - CEM002 - Interficie per apertura de llibretes
   FUNCTION f_imprimir_portada_libreta(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnpolcia IN VARCHAR2,
      ptproducto OUT VARCHAR2,
      pnnumide OUT VARCHAR2,
      ptnombre OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_IAX_CON.f_imprimir_portada_libreta';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ' - psseguro: ' || psseguro
            || ' - pnpoliza: ' || pnpoliza || ' - pncertif: ' || pncertif || ' - pnpolcia: '
            || pnpolcia;
      vpasexec       NUMBER(8) := 1;
      vnum_err       NUMBER(8) := 0;
      vcempres       NUMBER(8);
   BEGIN
      IF (psseguro IS NULL
          AND pnpoliza IS NULL
          AND pnpolcia IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcempres IS NULL THEN
         vcempres := pac_md_param.f_parinstalacion_nn('EMPRESADEF', mensajes);
      ELSE
         vcempres := pcempres;
      END IF;

      vpasexec := 5;
      pac_iax_login.p_iax_iniconnect(pac_parametros.f_parempresa_t(vcempres, 'USER_BBDD'));
      vpasexec := 7;
      vnum_err := pac_md_con.f_imprimir_portada_libreta(vcempres, psseguro, pnpoliza, pncertif,
                                                        pnpolcia, ptproducto, pnnumide,
                                                        ptnombre, mensajes);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, pac_md_common.f_get_cxtidioma(),
                                              vnum_err);
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
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
   END f_imprimir_portada_libreta;

   --Fin Bug.: 0012555

   -- Bug 14365 - 01/09/2010 - FAL - Alta de personas en el C.I
   FUNCTION f_alta_persona(
      psip IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_alta_persona';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := psip;
      error          NUMBER;
      vcagente       NUMBER;
   BEGIN
      error := pac_md_con.f_alta_persona(psip, vcagente, psinterf, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   -- Fi Bug 14365 - 01/09/2010 - FAL

   -- Bug 14365 - 26/08/2010 - SRA - función que devuelve un cursor con todas las equivalencias entre códigos origen de la empresa
   -- y su código equivalente en AXIS
   FUNCTION f_obtener_valores_axis(
      pemp IN VARCHAR2,
      pcampo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(200) := 'PAC_IAX_CON.f_obtener_valores_axis';
      vparam         VARCHAR2(500) := 'parámetros - pemp: ' || pemp || ' - pcampo: ' || pcampo;
      vpasexec       NUMBER := 0;
      cur_vvalaxis   sys_refcursor;
   BEGIN
      vpasexec := 1;

      BEGIN
         cur_vvalaxis := pac_md_con.f_obtener_valores_axis(pemp, pcampo, mensajes);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_object_error;
      END;

      vpasexec := 2;
      RETURN cur_vvalaxis;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         OPEN cur_vvalaxis FOR
            SELECT NULL AS co, NULL AS ce
              FROM DUAL;

         RETURN cur_vvalaxis;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         OPEN cur_vvalaxis FOR
            SELECT NULL AS co, NULL AS ce
              FROM DUAL;

         RETURN cur_vvalaxis;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         OPEN cur_vvalaxis FOR
            SELECT NULL AS co, NULL AS ce
              FROM DUAL;

         RETURN cur_vvalaxis;
   END f_obtener_valores_axis;

   -- Bug 14365 - 26/08/2010 - SRA - función que devuelve un cursor con todas las equivalencias entre códigos origen en AXIS
   -- y su código equivalente en la empresa
   FUNCTION f_obtener_valores_emp(
      pemp IN VARCHAR2,
      pcampo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(200) := 'PAC_IAX_CON.f_obtener_valores_emp';
      vparam         VARCHAR2(500) := 'parámetros - pemp: ' || pemp || ' - pcampo: ' || pcampo;
      vpasexec       NUMBER := 0;
      cur_vvalemp    sys_refcursor;
   BEGIN
      vpasexec := 1;

      BEGIN
         cur_vvalemp := pac_md_con.f_obtener_valores_emp(pemp, pcampo, mensajes);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_object_error;
      END;

      vpasexec := 2;
      RETURN cur_vvalemp;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         OPEN cur_vvalemp FOR
            SELECT NULL AS co, NULL AS ce
              FROM DUAL;

         RETURN cur_vvalemp;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         OPEN cur_vvalemp FOR
            SELECT NULL AS co, NULL AS ce
              FROM DUAL;

         RETURN cur_vvalemp;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         OPEN cur_vvalemp FOR
            SELECT NULL AS co, NULL AS ce
              FROM DUAL;

         RETURN cur_vvalemp;
   END f_obtener_valores_emp;

   FUNCTION f_cobrar_recibo(pnrecibo IN NUMBER, pctipcob IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_cobrar_recibo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnrecibo || ', pctipcob:' || pctipcob;
      error          NUMBER;
   BEGIN
      -- INI -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos parámetros en null
      error := pac_md_con.f_cobrar_recibo(pnrecibo, pctipcob,null,null,mensajes);
      -- FIN -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos parámetros en null

      IF error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_cobrar_recibo;

   FUNCTION f_descobrar_recibo(pnrecibo IN NUMBER, pfecha IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_descobrar_recibo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnrecibo || ', pfecha:' || pfecha;
      vfecha         DATE;
      error          NUMBER;
   BEGIN
      IF (pnrecibo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      -- 11.0 MMM 0027596 0008438 Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a Devuelto -- INICIO
      --IF pfecha IS NULL THEN
      --   vfecha := f_sysdate;
      --ELSE
      --   vfecha := pfecha;
      --END IF;
      error := pac_md_gestion_rec.f_impago_recibo(pnrecibo, pfecha, /*vfecha,*/ NULL, NULL,
                                                  NULL, mensajes);

      -- 11.0 MMM 0027596 0008438 Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a Devuelto -- FIN
      IF error = 0 THEN
         COMMIT;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         ROLLBACK;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_descobrar_recibo;

   FUNCTION f_insert_cuota(
      pctapres IN VARCHAR2,
      pidpago IN NUMBER,
      pfpago IN DATE,
      picapital IN NUMBER,
      pfalta IN DATE,
      pcmoneda IN NUMBER,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_insert_cuota';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pctapres:' || pctapres || ', pidpago:' || pidpago || ', pfpago:' || pfpago
            || ', picapital:' || picapital || ', pfalta:' || pfalta || ', pcmoneda:'
            || pcmoneda || ', pcempres:' || pcempres;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_insert_cuota(pctapres, pidpago, pfpago, picapital, pfalta,
                                         pcmoneda, pcempres, mensajes);

      IF error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_insert_cuota;

   FUNCTION f_importe_financiacion_pdte(
      psseguro IN NUMBER,
      pimporte OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION.f_importe_financiacion_pdte';
      vcempres       NUMBER;
   BEGIN
      vpasexec := 1;
      -- INI BUG 23588 - MDS - 07/09/2012
      --vcempres := pac_md_param.f_parinstalacion_nn('EMPRESADEF', mensajes);
      vcempres := pac_md_common.f_get_cxtempresa;
      -- FIN BUG 23588 - MDS - 07/09/2012
      vnumerr := pac_md_con.f_importe_financiacion_pdte(vcempres, psseguro, pimporte,
                                                        mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_importe_financiacion_pdte;

   -- Ini Bug 23687 - XVM - 09/10/2012
   /*************************************************************************
               Función f_recordarpwd: su finalidad es enviar un correo al usuario
      a la dirección pasada por parámetro notificándole su password de acceso a la aplicación
      param in  pcusuari:       Código de usuario
      param in  pto:            Dirección de correo a enviar (sería el "Para:" del correo)
      param out mensajes        Mensajes de error
      return                    0/1 -> Todo OK/error
   *************************************************************************/
   FUNCTION f_recordarpwd(pcusuari IN VARCHAR2, pto VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8);
      vparam         VARCHAR2(500) := 'parametros - pcusuari:' || pcusuari || ' - pto:' || pto;
      vobject        VARCHAR2(200) := 'PAC_IAX_CON.f_recordarpwd';
      vcempres       NUMBER(2);
      vcidioma       NUMBER(2);
   BEGIN
      vpasexec := 1;
      vcempres := pac_md_common.f_get_cxtempresa;
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnumerr := pac_md_con.f_recordarpwd(vcempres, vcidioma, pcusuari, pto, mensajes);
      vpasexec := 2;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_recordarpwd;

   /*************************************************************************
                        Función f_csinotesws: función para mover un fichero de la ubicaicón de
      gedox temporal a GEDOX
      param in  ptfilename:       Nombre del fichero sin path y con extensión
      param in  pcategoria:       Categoría del fichero
      param in  pcdesc:           Descripción del fichero a mover
      param in  pidref:           Identificador del objeto asociado al fichero
      param out mensajes          Mensajes de error
      return                      0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_csinotesws(
      ptfilename IN VARCHAR2,
      pcategoria IN NUMBER,
      pcdesc IN VARCHAR2,
      pidref IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8);
      vparam         VARCHAR2(500)
         := 'parametros - ptfilename:' || ptfilename || ' - pcategoria:' || pcategoria
            || ' - pcdesc:' || pcdesc || ' - pidref:' || pidref;
      vobject        VARCHAR2(200) := 'PAC_IAX_CON.f_csinotesws';
      vcempres       NUMBER(2);
      vcagente       NUMBER(20);
   BEGIN
      vpasexec := 1;
      vcempres := pac_md_common.f_get_cxtempresa;
      vcagente := pac_md_common.f_get_cxtagente;
      vnumerr := pac_md_con.f_csinotesws(vcempres, ptfilename, pcategoria, pcdesc, pidref,
                                         vcagente, mensajes);
      vpasexec := 2;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_csinotesws;

   -- Fi Bug 23687 - XVM - 09/10/2012
   FUNCTION f_obtener_cambio_moneda(
      pcmoneda_origen IN NUMBER,
      pcmoneda_destino IN NUMBER,
      pfcambio IN DATE,
      pcambio_desde IN BOOLEAN,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8);
      vparam         VARCHAR2(2000)
         := 'pcmoneda_origen: ' || pcmoneda_origen || ' pcmoneda_destino: '
            || pcmoneda_destino || ' pfcambio: ' || pfcambio || ' pcambio_desde: '
            ||(CASE pcambio_desde
                  WHEN TRUE THEN 'TRUE'
                  ELSE 'FALSE'
               END);
      vresultado     NUMBER;
      vresultado2    eco_desmonedas.tmoneda%TYPE;
      vobject        VARCHAR2(200) := 'PAC_IAX_CON.f_obtener_cambio_moneda';
      vcempres       NUMBER;
      vtabcambio     pac_md_con.tab_cambiomoneda;
      vcmonori       eco_codmonedas.cmoneda%TYPE;
      vcmondes       eco_codmonedas.cmoneda%TYPE;
   BEGIN
      IF pcmoneda_origen IS NULL
         OR pcmoneda_destino IS NULL
         OR pfcambio IS NULL
         OR pcambio_desde IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vcempres := pac_md_common.f_get_cxtempresa;
      vpasexec := 2;

      IF vcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_con.f_obtener_cambio_moneda(vcempres, pcmoneda_origen,
                                                    pcmoneda_destino, pfcambio, pcambio_desde,
                                                    mensajes, vtabcambio);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      vresultado2 := pac_iax_listvalores.f_get_tmoneda(vtabcambio(1).cmonedaorigen, vcmonori,
                                                       mensajes);

      IF vresultado2 = '' THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vresultado2 := pac_iax_listvalores.f_get_tmoneda(vtabcambio(1).cmonedadestino, vcmondes,
                                                       mensajes);

      IF vresultado2 = '' THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
      vnumerr := pac_md_operativa_finv.f_creacotizacion(vcmonori, vcmondes,
                                                        vtabcambio(1).fcambio,
                                                        vtabcambio(1).valor, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtener_cambio_moneda;

   -- Bug 024791 - 01/09/2010 - JLB -Nuevas interfaces de autos
   FUNCTION f_ultimosegurovehiculo(
      ptipomatricula IN VARCHAR2,
      pmatricula IN VARCHAR2,
      pfechaultimavig OUT DATE,
      pcompani OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_ultimoSeguroVehiculo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ptipomatricula || '-' || pmatricula;
      error          NUMBER := 0;
      vcagente       NUMBER;
      -- Ini Bug 25943 -- ECP -- 21/03/2013
      vobdetpoliza   ob_iax_detpoliza;
   -- Fin Bug 25943 -- ECP -- 21/03/2013
   BEGIN
      -- Ini Bug 25943 -- ECP -- 21/03/2013
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF NVL(f_parproductos_v(vobdetpoliza.sproduc, 'AUT_COMP_ANTERIOR'), 0) = 1
         AND NOT pac_iax_produccion.issimul THEN
         error := pac_md_con.f_ultimosegurovehiculo(ptipomatricula, pmatricula,
                                                    pfechaultimavig, pcompani, psinterf,
                                                    mensajes);
      END IF;

      -- Ini Bug 25943 -- ECP -- 21/03/2013
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_antiguedadconductor(
      ptipodoc IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pantiguedad OUT NUMBER,
      pcompani OUT NUMBER,
      psinies OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_antiguedadConductor';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ptipodoc || '-' || pnnumide;
      error          NUMBER;
      vcagente       NUMBER;
   BEGIN
      error := pac_md_con.f_antiguedadconductor(ptipodoc, pnnumide, pantiguedad, pcompani,
                                                psinies, psinterf, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_solicitar_inspeccion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmotinspec IN NUMBER,
      ptabla IN VARCHAR2,
      pnordenext OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_solicitar_inspeccion';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := psseguro || '-' || pnriesgo || '-' || pnmovimi || '-' || pmotinspec || '-'
            || ptabla;
      error          NUMBER;
      vcagente       NUMBER;
   BEGIN
      error := pac_md_con.f_solicitar_inspeccion(psseguro, pnriesgo, pnmovimi, pmotinspec,
                                                 ptabla, pnordenext, psinterf, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   --BUG 29177/160128:NSS:16-12-2013
   FUNCTION f_lista_contratos_pago(
      pipago IN NUMBER,
      psperson IN NUMBER,
      pnsinies IN VARCHAR2,
      psseguro IN NUMBER,
      psinterf OUT NUMBER,
      pcurcontratos OUT t_iax_sin_trami_pago_ctr,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_lista_contratos_pago';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pipago: ' || pipago || ' psperson: ' || psperson || ' pnsinies: ' || pnsinies
            || ' psseguro: ' || psseguro || ' psinterf: ' || psinterf;
      error          NUMBER;
   BEGIN
      error := pac_md_con.f_lista_contratos_pago(pipago, psperson, pnsinies, psseguro,
                                                 psinterf, pcurcontratos, mensajes);
      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lista_contratos_pago;

-- Fi BUG24918
   FUNCTION f_resultado_carga(psproces IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8);
      vobject        VARCHAR2(200) := 'PAC_IAX_CON.f_resultado_carga';
      vparam         VARCHAR2(2000) := 'Params: sproces:' || psproces;
      vcempres       NUMBER;
   BEGIN
      vpasexec := 1;
      vcempres := pac_md_common.f_get_cxtempresa;
      vpasexec := 2;

      IF vcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_con.f_resultado_carga(vcempres, psproces, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_resultado_carga;

   -- INICIO BUG24918 MMS 20140424
   FUNCTION f_export_datos_sian(
      ppath_in IN VARCHAR2,
      ppath_out IN VARCHAR2,
      pfich IN VARCHAR2,
      pproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      prespuesta OUT NUMBER,
      prespfichero OUT VARCHAR2)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8);
      vobject        VARCHAR2(200) := 'PAC_IAX_CON.F_EXPORT_DATOS_SIAN';
      vparam         VARCHAR2(2000)
         := 'Params: ppath_in:' || ppath_in || ' ppath_out:' || ppath_out || ' pfich:'
            || pfich;
      vcempres       NUMBER;
      trespuestas    pac_md_con.tab_resp_sian;
   BEGIN
      vpasexec := 1;
      vcempres := pac_md_common.f_get_cxtempresa;
      vpasexec := 2;

      IF vcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_con.f_export_datos_sian(vcempres, ppath_in, ppath_out, pfich, pproduc,
                                                mensajes, trespuestas);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      IF trespuestas(1).respok <> 0 THEN
         prespuesta := 1;
      ELSE
         prespuesta := trespuestas(1).respok;
      END IF;

      vpasexec := 5;
      prespfichero := trespuestas(1).respdesc;
      vpasexec := 6;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_export_datos_sian;
-- FIN BUG24918 MMS 20140424
   --
   -- Inicio IAXIS-6219 29/10/2019
   --
   FUNCTION f_reversa_recibo(pnrecibo IN VARCHAR2, -- IAXIS-7640 04/12/2019
                             pnreccaj IN VARCHAR2, 
                             mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_reversa_recibo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnrecibo || ', pnreccaj:' || pnreccaj;
      error          NUMBER;
   BEGIN
      IF (pnrecibo IS NULL) OR (pnreccaj IS NULL) THEN
         RAISE e_param_error;
      END IF;

      p_reversa_recibo(pnrecibo, pnreccaj, error);

      IF error = 0 THEN
         COMMIT;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         ROLLBACK;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_reversa_recibo;
   --
   -- Fin IAXIS-6219 29/10/2019
   -- 
END pac_iax_con;
/
