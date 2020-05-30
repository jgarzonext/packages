CREATE OR REPLACE PACKAGE BODY pac_md_con AS
   /******************************************************************************
    NOMBRE:      PAC_MD_CON
    PROPÓSITO:   Funciones para las interfases en segunda capa
    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        ??/??/????   ???               1. Creación del package.
    2.0        07/05/2009   DRA               2. 0009981: IAX - Baixar l'empresa a totes les taules del model CFG
    3.0        17/12/2009   JAS               3. 0011302: CEM002 - Interface Libretas
    4.0        16/02/2010   ICV               4. 0012555: CEM002 - Interficie per apertura de llibretes
    6.0        26/08/2010   SRA               6. 14365: CRT002 - Gestion de personas
    7.0        01/09/2010   FAL               7. 14365: CRT002 - Gestion de personas
    8.0        22/11/2010   JAS               8. 13266: Modificación interfases apertura y cierre de puesto (parte PL) Diverses modificacions al codi
    9.0        13/09/2011   DRA               9. 0018682: AGM102 - Producto SobrePrecio- Definición y Parametrización
    10.0       09/02/2012   MDS              10. 0019880: LCOL898 - 03 - Interface Notificación del Recaudo de Recibos de JDE a iAXIS
    11.0       28/02/2012   DRA              11. 0021467: AGM- Quitar en la descripción de riesgos el plan y al final se muestran caracteres raros
    12.0       10/04/2012   JMF              12. 0021190 CRE998-CRE - Sistema de comunicaci Axis - eCredit (ver 0021187)
    13.0       09/10/2012   XVM              13. 0023687: Release 2. Webservices de Mutua de Propietarios
    14.0       27/12/2012   MAL              14. 0025129: RSA002 - Interafz WS cliente paridad peso-dolar
    15.0       27/06/2013   JDS              15. 0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A
    16.0       13/06/2014   SSM              16. 0031803/0177317: LCOL895-Interfaz Cexper - Tiempo respuesta interfaz
    17.0       07/06/2019   JLTS             17. IAXIS.4153: Se incluyen nuevos paráametros pnreccaj y pcmreca a la función f_cobro_parcial_recibo
    18.0       18/07/2019 Shakti    	     18. IAXIS-4753: Ajuste campos Servicio L003
    19.0       01/08/2019   Shakti           19. IAXIS-4944
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_validar_usuario';
      terror         VARCHAR2(2000);   --//ACC recuperar desde literales
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pusuario || '-' || ppassword;
      error          NUMBER;
   BEGIN
      error := pac_con.f_validar_usuario(pac_md_common.f_get_cxtempresa, pusuario, ppassword,
                                         pvalidado, poficina, ptnombre, psinterf, terror);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000555, terror);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

-----------------------------------------------------------------------------
   FUNCTION f_busqueda_persona(
      psip IN VARCHAR2,
      pctipdoc IN NUMBER,
      ptdocidentif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      po_masdatos OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_busqueda_persona';
      terror         VARCHAR2(2000);
      vcterminal     usuarios.cterminal%TYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := psip || '-' || pctipdoc || '-' || ptdocidentif || '-' || ptnombre || '-'
            || pcognom1 || '-' || pcognom2;
      error          NUMBER;
      v_masdatos     NUMBER;
   BEGIN
      error := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RETURN 1;
      END IF;

      vpasexec := 3;
      error := pac_con.f_busqueda_persona(pac_md_common.f_get_cxtempresa, psip, pctipdoc,
                                          ptdocidentif, ptnombre, vcterminal, v_masdatos,
                                          po_masdatos, psinterf, terror, pcognom1, pcognom2,
                                          pac_md_common.f_get_cxtusuario);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_busqueda_masdatos(
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      po_masdatos OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_busqueda_masdatos';
      terror         VARCHAR2(2000);
      vcterminal     usuarios.cterminal%TYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000);
      error          NUMBER;
      v_masdatos     NUMBER := 1;   -- mas datos
   BEGIN
      error := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RETURN 1;
      END IF;

      vpasexec := 3;
      error := pac_con.f_busqueda_persona(pac_md_common.f_get_cxtempresa, NULL, NULL, NULL,
                                          NULL, vcterminal,   --pac_md_common.f_get_cxtterminal
                                          v_masdatos, po_masdatos, psinterf, terror, NULL,
                                          NULL, pac_md_common.f_get_cxtusuario);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_datos_persona(
      psip IN VARCHAR2,
      pcagente OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_datos_persona';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vcterminal     usuarios.cterminal%TYPE;
      vparam         VARCHAR2(2000) := psip;
      error          NUMBER;
   BEGIN
      error := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RETURN 1;
      END IF;

      error := pac_con.f_datos_persona(pac_md_common.f_get_cxtempresa, psip, vcterminal,
                                       psinterf, terror, pac_md_common.f_get_cxtusuario);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
         RETURN error;
      END IF;

      vpasexec := 2;
      --llamar pac_propio_int
      error := pac_propio_int.f_busca_agente_persona(psip, psinterf, pcagente);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_cuentas_persona(
      psperson IN VARCHAR2,
      pcrol IN NUMBER,
      pcestado IN NUMBER,
      pcsaldo IN NUMBER,
      porigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_cuentas_persona';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
      --//ACC recuperar desde literales
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                              := psperson || '-' || pcrol || '-' || pcestado || '-' || pcsaldo;
      vcterminal     usuarios.cterminal%TYPE;
      error          NUMBER;
   BEGIN
      error := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RETURN 1;
      END IF;

      vpasexec := 3;
      error := pac_con.f_cuentas_persona(pac_md_common.f_get_cxtempresa, psperson, pcrol,
                                         pcestado, pcsaldo, pac_md_common.f_get_cxtusuario,
                                         pac_md_common.f_get_cxtagente, vcterminal, porigen,
                                         psinterf, terror, pac_md_common.f_get_cxtusuario);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

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
      pterror OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_cobro_recibo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnrecibo;
      vcterminal     usuarios.cterminal%TYPE;
      error          NUMBER;
   BEGIN
      error := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RETURN 1;
      END IF;

      vpasexec := 3;
      error := pac_con.f_cobro_recibo(pac_md_common.f_get_cxtempresa, pnrecibo, vcterminal,
                                      pcobrado, psinterf, pterror,
                                      pac_md_common.f_get_cxtusuario);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000006, pterror);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_cobro_recibo;

   FUNCTION f_abrir_puesto(
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      psinterf IN OUT NUMBER,
      poficina OUT NUMBER,
      ptermlog OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_abrir_puesto';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pusuario;
      --vpuesto        VARCHAR2(50);
      error          NUMBER;
   BEGIN
      vpasexec := 1;
      error := pac_con.f_abrir_puesto(pac_md_common.f_get_cxtempresa, pusuario, ppassword,
                                      psinterf, poficina, ptermlog, terror);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000555, terror);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_abrir_puesto;

   FUNCTION f_cerrar_puesto(
      pusuario IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_cerrar_puesto';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pusuario;
      vcterminal     usuarios.cterminal%TYPE;
      error          NUMBER := 0;
      vabrirp        NUMBER := 0;
      vabrirp_usu    NUMBER := 0;
      vcrealiza      NUMBER;
      vcempres       NUMBER;
   BEGIN
      vcempres := pac_md_common.f_get_cxtempresa;   -- BUG9981:DRA:07/05/2009
      --Només tanquem "puesto" si l'empresa te "obertura de puesto".
      vabrirp := pac_parametros.f_parempresa_n(vcempres, 'ABRIR_PUESTO');
      vabrirp_usu := pac_cfg.f_get_user_accion_permitida(pusuario, 'ABRIR_PUESTO', NULL,
                                                         vcempres,   -- BUG9981:DRA:07/05/2009
                                                         vcrealiza);

      IF NVL(vabrirp, 0) = 1
         AND NVL(vabrirp_usu, 0) = 1 THEN
         vpasexec := 3;
         error := pac_con.f_cerrar_puesto(vcempres, pusuario, psinterf, terror);

         IF error <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000571, terror);
         END IF;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_cerrar_puesto;

   -- Bug 21458/108087 - 23/02/2012 - AMC
   -- Se añaden nuevos parametros de entrada
   FUNCTION f_convertir_documento(
      ptipoorigen IN VARCHAR2,
      ptipodestino IN VARCHAR2,
      pficheroorigen IN VARCHAR2,
      pficherodestino IN VARCHAR2,
      pplantillaorigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      pfirmadigital IN VARCHAR2,
      pfirmadigitalalias IN VARCHAR2,
      pfirmaelectronicacliente IN VARCHAR2,
      pfirmaelectronicaclienteimagen IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_convertir_documento';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := ptipoorigen || '-' || ptipodestino || '-' || pficheroorigen || '-'
            || pficherodestino || '-' || pplantillaorigen;
      error          NUMBER;
      terror         VARCHAR2(200);
   BEGIN
      error :=
         pac_con.f_convertir_documento
                                    (pac_md_common.f_get_cxtempresa, ptipoorigen,
                                     ptipodestino, pficheroorigen, pficherodestino,
                                     pplantillaorigen, psinterf, pfirmadigital,
                                     pfirmadigitalalias,   -- Bug 21458/108087 - 23/02/2012 - AMC
                                     pfirmaelectronicacliente, pfirmaelectronicaclienteimagen,
                                     terror);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_convertir_documento;

   FUNCTION f_obtener_valor_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalemp IN VARCHAR2)
      RETURN VARCHAR2 IS
      mensajes       t_iax_mensajes;
      vobject        VARCHAR2(200) := 'pac_md_con.f_obtener_valor_axis';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
      --//ACC recuperar desde literales
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pemp || '-' || pcampo || '-' || pvalemp;
      valor          int_codigos_emp.cvalaxis%TYPE;
   BEGIN
      valor := pac_con.f_obtener_valor_axis(pemp, pcampo, pvalemp);
      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_obtener_valor_axis;

   FUNCTION f_obtener_valor_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalaxis IN VARCHAR2)
      RETURN VARCHAR2 IS
      mensajes       t_iax_mensajes;
      vobject        VARCHAR2(200) := 'pac_md_con.f_cuentas_persona';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
      --//ACC recuperar desde literales
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pemp || '-' || pcampo || '-' || pvalaxis;
      valor          int_codigos_emp.cvalemp%TYPE;
   BEGIN
      valor := pac_con.f_obtener_valor_emp(pemp, pcampo, pvalaxis);
      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtener_valor_emp;

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
      error := pac_con.f_proceso_alta(pempresa, psseguro, pnmovimi, pop, pusuario, psinterf,
                                      perror);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_lista_polizas';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pcempres;
      vcterminal     usuarios.cterminal%TYPE;
      error          NUMBER;
      vcempres       NUMBER := pcempres;
      vsquery        VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vpasexec := 3;
      error := pac_con.f_lista_polizas(vcempres, psnip, pcsituac, vsquery, psinterf, terror);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002054, terror);
      END IF;

      pcurlistapolizas := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_extracto_polizas';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pcempres;
      vcterminal     usuarios.cterminal%TYPE;
      error          NUMBER;
      vcempres       NUMBER := pcempres;
      vsquery        VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vpasexec := 3;
      error := pac_con.f_extracto_polizas(vcempres, pnpoliza, pfini, pffin, vsquery, psinterf,
                                          terror);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002055, terror);
      END IF;

      pcurextractopol := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
      mensajes IN OUT t_iax_mensajes,
      psnip IN VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_extracto_polizas_asegurado';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pcempres;
      vcterminal     usuarios.cterminal%TYPE;
      error          NUMBER;
      vcempres       NUMBER := pcempres;
      vsquery        VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vpasexec := 3;
      error := pac_con.f_extracto_polizas_asegurado(vcempres, pnpoliza, pfini, pffin, vsquery,
                                                    psinterf, terror, psnip);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002055, terror);
      END IF;

      pcurextractopol := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_detalle_polizas';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnpoliza;
      vnumerr        NUMBER;
      vsseguro       NUMBER;
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vsquery        VARCHAR2(4000);
   BEGIN
      vpasexec := 3;
      -- error := pac_con.f_detalle_poliza(pnpoliza, psinterf, terror);
      /*   SELECT sseguro
                                               INTO vsseguro
           FROM seguros
          WHERE npoliza = pnpoliza
            AND ROWNUM = 1;
            vnumerr := pac_md_obtenerdatos.f_inicializa('POL', vsseguro, NULL, mensajes);
            IF vnumerr <> 0 THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- 9002056);
            RAISE e_object_error;
         END IF;
            detpoliza := pac_md_obtenerdatos.f_leedatospoliza(mensajes);
            IF vnumerr <> 0 THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002056);   -- 9002056);
            RAISE e_object_error;
         END IF;
            detpoliza.gestion := pac_md_obtenerdatos.f_leedatosgestion(mensajes);
            IF vnumerr <> 0 THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002056);   -- 9002056);
            RAISE e_object_error;
         END IF;
            detpoliza.tomadores := pac_md_obtenerdatos.f_leetomadores(mensajes);
            IF vnumerr <> 0 THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002056);   -- 9002056);
            RAISE e_object_error;
         END IF;
            detpoliza.riesgos := pac_md_obtenerdatos.f_leeriesgos(mensajes);
            IF vnumerr <> 0 THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002056);   -- 9002056);
            RAISE e_object_error;
         END IF;
            detpoliza.clausulas := pac_md_obtenerdatos.f_leeclausulas(mensajes);
            IF vnumerr <> 0 THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002056);   -- 9002056);
            RAISE e_object_error;
         END IF;
            detpoliza.primas := pac_md_obtenerdatos.f_leeprimas(detpoliza, mensajes);
            IF vnumerr <> 0 THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002056);   -- 9002056);
            RAISE e_object_error;
         END IF;
            detpoliza.preguntas := pac_md_obtenerdatos.f_leepreguntaspoliza(mensajes);
            IF vnumerr <> 0 THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002056);   -- 9002056);
            RAISE e_object_error;
         END IF;*/
      vpasexec := 3;
      vnumerr := pac_con.f_detalle_poliza(pnpoliza, psinterf, vsquery, terror);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002056, terror);
      END IF;

      pcurdetpol := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
   END f_detalle_poliza;

   -- Bug 0021190 - 10/04/2012 - JMF
   FUNCTION f_detalle_poliza_asegurado(
      pnpoliza IN NUMBER,
      psinterf OUT NUMBER,
      pcurdetpol OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes,
      psnip IN VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_detalle_poliza_asegurado';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnpoliza;
      vnumerr        NUMBER;
      vsseguro       NUMBER;
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vsquery        VARCHAR2(4000);
   BEGIN
      vpasexec := 3;
      vnumerr := pac_con.f_detalle_poliza_asegurado(pnpoliza, psinterf, vsquery, terror,
                                                    psnip);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002056, terror);
      END IF;

      pcurdetpol := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
      param in out  mensajes    missatges d'error
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_MD_CON.f_imprimir_libreta';
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
      vlit           VARCHAR2(500);
      vcidioma       NUMBER(8);
   BEGIN
      IF (psseguro IS NULL
          AND pnpoliza IS NULL
          AND pnpolcia IS NULL)
         OR pvalsaldo IS NULL
         OR(pvalsaldo IS NOT NULL
            AND pisaldo IS NULL)
         OR pcopcion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcidioma IS NULL THEN
         vcidioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
      END IF;

      vpasexec := 5;
      vnum_err := pac_ctaseguro.f_imprimir_libreta(pcempres, psseguro, pnpoliza, pncertif,
                                                   pnpolcia, pvalsaldo, pisaldo, pcopcion,
                                                   pnseq, pfrimpresio, pnmov, porden,
                                                   NVL(pcidioma, vcidioma), vlit, pcur_reg_lib);

      IF vnum_err <> 0 THEN
         IF vlit IS NOT NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vlit);
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, pac_md_common.f_get_cxtidioma(),
                                                 vnum_err);
         END IF;

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

   FUNCTION f_get_listado_doc(
      psip IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_get_listado_doc';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' psip=' || psip || ' psseguro=' || psseguro;
      error          NUMBER;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(4000);
   BEGIN
      error := pac_con.f_get_listado_doc(pac_md_common.f_get_cxtempresa, psip, psseguro,
                                         pnmovimi, psinterf, terror,
                                         pac_md_common.f_get_cxtusuario);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

      COMMIT;
      vsquery :=
         'select id iddoc, descripcion tdescrip,nombre FICHERO
      from int_listado_doc
      where sinterf ='
         || psinterf;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_listado_doc;

   FUNCTION f_get_detalle_doc(
      pid IN VARCHAR2,
      pdestino IN OUT VARCHAR2,
      pnombre IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_get_detalle_doc';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                         := ' pid=' || pid || ' destino=' || pdestino || ' nombre=' || pnombre;
      error          NUMBER;
   BEGIN
      error := pac_con.f_get_detalle_doc(pac_md_common.f_get_cxtempresa, pid, pdestino,
                                         pnombre, psinterf, terror,
                                         pac_md_common.f_get_cxtusuario);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

      COMMIT;

      SELECT destino
        INTO pdestino
        FROM int_detalle_doc
       WHERE sinterf = psinterf;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_detalle_doc;

   FUNCTION f_get_datoscontratos(
      psperson IN VARCHAR2,
      porigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_get_datoscontratos';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
      --//ACC recuperar desde literales
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' psperson=' || psperson || ' porigen=' || porigen;
      vcterminal     usuarios.cterminal%TYPE;
      error          NUMBER;
   BEGIN
      error := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RETURN 1;
      END IF;

      vpasexec := 3;
      error := pac_con.f_get_datoscontratos(pac_md_common.f_get_cxtempresa, psperson,
                                            vcterminal, pac_md_common.f_get_cxtusuario,
                                            pac_md_common.f_get_cxtagente, porigen, psinterf,
                                            terror);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_datoscontratos;

   --Ini Bug.: 0012555 - ICV - 16/02/2010 - CEM002 - Interficie per apertura de llibretes
   FUNCTION f_imprimir_portada_libreta(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnpolcia IN VARCHAR2,
      ptproducto IN OUT VARCHAR2,
      pnnumide IN OUT VARCHAR2,
      ptnombre IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_MD_CON.f_imprimir_portada_libreta';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ' - psseguro: ' || psseguro
            || ' - pnpoliza: ' || pnpoliza || ' - pncertif: ' || pncertif || ' - pnpolcia: '
            || pnpolcia;
      vpasexec       NUMBER(8) := 1;
      vnum_err       NUMBER(8) := 0;
      vcempres       NUMBER(8);
      vcidioma       NUMBER(8);
   BEGIN
      IF (psseguro IS NULL
          AND pnpoliza IS NULL
          AND pnpolcia IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --IF pcidioma IS NULL THEN
      vcidioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
      --END IF;
      vpasexec := 5;
      vnum_err := pac_ctaseguro.f_imprimir_portada_libreta(pcempres, psseguro, pnpoliza,
                                                           pncertif, pnpolcia, vcidioma,
                                                           ptproducto, pnnumide, ptnombre);

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
      pcagente OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_alta_persona';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vcterminal     usuarios.cterminal%TYPE;
      vparam         VARCHAR2(2000) := psip;
      error          NUMBER;
   BEGIN
      error := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RETURN 1;
      END IF;

      error := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psip, vcterminal,
                                      psinterf, terror, pac_md_common.f_get_cxtusuario);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
         RETURN error;
      END IF;

      vpasexec := 2;
      --llamar pac_propio_int
      error := pac_propio_int.f_busca_agente_persona(psip, psinterf, pcagente);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

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
      vobject        VARCHAR2(200) := 'PAC_MD_CON.f_obtener_valores_axis';
      vparam         VARCHAR2(500) := 'parámetros - pemp: ' || pemp || ' - pcampo: ' || pcampo;
      vpasexec       NUMBER := 0;
      cur_vvalaxis   sys_refcursor;
   BEGIN
      IF pemp IS NULL
         OR pcampo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      BEGIN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion de mensajes.
         cur_vvalaxis := pac_con.f_obtener_valores_axis(pemp, pcampo);
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
      vobject        VARCHAR2(200) := 'PAC_MD_CON.f_obtener_valores_emp';
      vparam         VARCHAR2(500) := 'parámetros - pemp: ' || pemp || ' - pcampo: ' || pcampo;
      vpasexec       NUMBER := 0;
      cur_vvalemp    sys_refcursor;
   BEGIN
      IF pemp IS NULL
         OR pcampo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      BEGIN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion de mensajes.
         cur_vvalemp := pac_con.f_obtener_valores_emp(pemp, pcampo);
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

   -- BUG21467:DRA:01/03/2012:Inici
   FUNCTION f_get_datos_host(
      pcempres IN NUMBER,
      datpol IN ob_iax_int_datos_poliza,
      pregpol IN t_iax_int_preg_poliza,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_get_riesgos_host';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
      --//ACC recuperar desde literales
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcempres= ' || pcempres || ' - psinterf=' || psinterf;
      vcterminal     usuarios.cterminal%TYPE;
      error          NUMBER;
   BEGIN
      vpasexec := 1;

      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vpasexec := 2;

      BEGIN
         INSERT INTO int_datos_pol_preg
                     (sinterf, cnivel,
                      tvalores)
              VALUES (psinterf, 'DATPOL',
                      datpol.cempres || '|' || datpol.sseguro || '|' || datpol.ssegpol || '|'
                      || datpol.nsolici || '|' || datpol.nmovimi || '|' || datpol.nsuplem
                      || '|' || datpol.npoliza || '|' || datpol.ncertif || '|'
                      || datpol.fefecto || '|' || datpol.cmodali || '|' || datpol.ccolect
                      || '|' || datpol.cramo || '|' || datpol.ctipseg || '|' || datpol.cactivi
                      || '|' || datpol.sproduc || '|' || datpol.cagente || '|'
                      || datpol.cobjase || '|' || datpol.csubpro || '|' || datpol.cforpag
                      || '|' || datpol.csituac || '|' || datpol.creteni || '|'
                      || datpol.cpolcia || '|' || datpol.ccompani || '|' || datpol.cpromotor
                      || '|' || datpol.npoliza_ini || '|' || datpol.cidioma);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            RAISE e_object_error;
      END;

      vpasexec := 3;

      IF pregpol IS NOT NULL THEN
         IF pregpol.COUNT > 0 THEN
            FOR pr IN pregpol.FIRST .. pregpol.LAST LOOP
               BEGIN
                  INSERT INTO int_datos_pol_preg
                              (sinterf, cnivel,
                               tvalores)
                       VALUES (psinterf, 'PREGPOL',
                               pregpol(pr).cpregun || '|' || pregpol(pr).crespue || '|'
                               || pregpol(pr).trespue || '|' || pregpol(pr).ctipprg || '|'
                               || pregpol(pr).cnivel);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
                     RAISE e_object_error;
               END;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 4;
      error := pac_con.f_get_datos_host(pcempres, psinterf, terror);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

      RETURN error;
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
   END f_get_datos_host;

   -- BUG21467:DRA:01/03/2012:Fi
   FUNCTION f_cobrar_recibo(
      pnrecibo IN NUMBER,
      pctipcob IN NUMBER,
     ---- pnreccaj IN NUMBER DEFAULT NULL, -- INI -IAXIS-4153 - JLTS - 07/06/2019 nuevo parámetro
	  pnreccaj IN VARCHAR2 DEFAULT NULL, /* Cambios de IAXIS-4753 */  	
      pcmreca IN NUMBER DEFAULT NULL, -- INI -IAXIS-4153 - JLTS - 07/06/2019 nuevo parámetro
      mensajes IN OUT t_iax_mensajes,
      PCINDICAF IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      PCSUCURSAL IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      PNDOCSAP IN VARCHAR2 DEFAULT NULL,------Changes for 4944
      pcususap IN VARCHAR2 DEFAULT NULL )------Changes for 4944 
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_cobrar_recibo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnrecibo || ', pctipcob:' || pctipcob;
      error          NUMBER := 0;
      v_cempres      recibos.cempres%TYPE;
      v_cdelega      recibos.cdelega%TYPE;
      v_ccobban      recibos.ccobban%TYPE;
      v_ctipcob      seguros.ctipcob%TYPE;
      v_fmovini      movrecibo.fmovini%TYPE;
   BEGIN
      BEGIN
         SELECT r.cempres, r.cdelega, r.ccobban, NVL(pctipcob, s.ctipcob)
           INTO v_cempres, v_cdelega, v_ccobban, v_ctipcob
           FROM recibos r, seguros s   --, riesgos ri
          WHERE nrecibo = pnrecibo
            AND r.sseguro = s.sseguro;

         --AND s.sseguro = ri.sseguro;

         --busco fecha ini del ultimo movimiento pendiente, si no encuentra es que el recibo no es válido
         SELECT fmovini
           INTO v_fmovini
           FROM movrecibo
          WHERE nrecibo = pnrecibo
            AND cestrec = 0
            AND fmovfin IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000878);
            RETURN 9000878;   --error en datos enviados
      END;

      -- BUG 19880 : MDS : 09/02/2012
      -- pasar como fecha la mayor de: v_fmovini, f_sysdate
      -- INI -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos parámetros pnreccaj,pcmreca
      error := pac_gestion_rec.f_cobro_recibo(v_cempres, pnrecibo,
                                              TRUNC(GREATEST(v_fmovini, f_sysdate)), NULL,
                                              NULL, v_ccobban, v_cdelega, v_ctipcob,pnreccaj,pcmreca,PCINDICAF,PCSUCURSAL,PNDOCSAP,pcususap);
      -- FIN -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos parámetros pnreccaj,pcmreca
     ---PCINDICAF,PCSUCURSAL,PNDOCSAP,pcususap changes for 4944
      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000132;
   END f_cobrar_recibo;

   FUNCTION f_insert_cuota(
      pctapres IN VARCHAR2,
      pidpago IN NUMBER,
      pfpago IN DATE,
      picapital IN NUMBER,
      pfalta IN DATE,
      pcmoneda IN NUMBER,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_insert_cuota';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pctapres:' || pctapres || ', pidpago:' || pidpago || ', pfpago:' || pfpago
            || ', picapital:' || picapital || ', pfalta:' || pfalta || ', pcmoneda:'
            || pcmoneda || ', pcempres:' || pcempres;
      error          NUMBER := 0;
   BEGIN
      error := pac_prestamos.f_insert_cuota(pctapres, pidpago, pfpago, picapital, pfalta,
                                            pcmoneda, pcempres);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000132;
   END f_insert_cuota;

   FUNCTION f_importe_financiacion_pdte(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pimporte OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_get_riesgos_host';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
      --//ACC recuperar desde literales
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcempres= ' || pcempres;
      vcterminal     usuarios.cterminal%TYPE;
      v_sinterf      NUMBER;
      error          NUMBER := 0;
   BEGIN
      vpasexec := 1;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'PRIMA_FINAN_HOST'), 1) = 1 THEN
         IF v_sinterf IS NULL THEN
            pac_int_online.p_inicializar_sinterf;
            v_sinterf := pac_int_online.f_obtener_sinterf;
         END IF;

         vpasexec := 2;
         error := pac_con.f_importe_financiacion_pdte(pcempres, psseguro, v_sinterf, pimporte,
                                                      terror);

         IF error <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
         END IF;
      ELSE
         pimporte := 0;
      END IF;

      RETURN error;
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
   END f_importe_financiacion_pdte;

   -- Ini Bug 23687 - XVM - 09/10/2012
   FUNCTION f_recordarpwd(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcusuari IN VARCHAR2,
      pto IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_MD_CON.f_recordarpwd';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcempres:' || pcempres || ', pcidioma:' || pcidioma || ', pcusuari:' || pcusuari
            || ', pto:' || pto;
      error          NUMBER;
   BEGIN
      vpasexec := 1;
      error := pac_con.f_recordarpwd(pcempres, pcidioma, pcusuari, pto, terror);
      vpasexec := 2;

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RAISE e_object_error;
      END IF;

      RETURN error;
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
   END f_recordarpwd;

   /*************************************************************************
                     Función f_csinotesws: función para mover un fichero de la ubicaicón de
      gedox temporal a GEDOX
      param in  pcempres:         Código de empresa
      param in  ptfilename:       Nombre del fichero sin path y con extensión
      param in  pcategoria:       Categoría del fichero
      param in  pcdesc:           Descripción del fichero a mover
      param in  pidref:           Identificador del objeto asociado al fichero
      param in  pcagente:         Agente por defecto
      param out mensajes          Mensajes de error
      return                      0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_csinotesws(
      pcempres IN NUMBER,
      ptfilename IN VARCHAR2,
      pcategoria IN NUMBER,
      pcdesc IN VARCHAR2,
      pidref IN NUMBER,
      pcagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vobject        VARCHAR2(500) := 'PAC_MD_CON.f_csinotesws';
      vparam         VARCHAR2(4000)
         := 'pcempres:' || pcempres || ', ptfilename:' || ptfilename || ', pcategoria:'
            || pcategoria || ', pcdesc:' || pcdesc || ', pidref:' || pidref || ', pcagente:'
            || pcagente;
      vpasexec       NUMBER(5) := 0;
      viddoc         NUMBER(8) := 0;
      v_servergedox  VARCHAR2(200);
      vcur           VARCHAR2(2000);
      vterror        VARCHAR2(1000);
   BEGIN
      IF ptfilename IS NULL
         OR pcategoria IS NULL
         OR pcdesc IS NULL
         OR pidref IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      /*
                           IF INSTR(ptfilename, 'app') = 0 THEN
               v_servergedox :=
                  ff_desvalorfijo(1103, 2,
                                  pac_md_con.f_obtener_valor_axis(pcempres, 'SERVERGEDOX',
                                                                  LOWER(pserveralias)));
               vpasexec := 2;
               IF INSTR(ptfilename, '/') = 1 THEN
                  v_servergedox := v_servergedox || ptfilename;
               ELSE
                  v_servergedox := v_servergedox || '/' || ptfilename;
               END IF;
            ELSE*/
      v_servergedox := ptfilename;
      --END IF;
      vpasexec := 3;

      --pac_axisgedox.grabacabecera(f_user, v_servergedox, pcdesc, 1, 1, pcategoria, vterror,
      --                            viddoc);
      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904416);   --Error grabar cabecera Gedox
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      --pac_axisgedox.actualiza_gedoxdb(v_servergedox, viddoc, vterror, vterror);
      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904417);   --Error mover fichero a Gedox
         RAISE e_object_error;
      END IF;

      vpasexec := 6;

      IF pcategoria = 2 THEN
         vpasexec := 7;

         INSERT INTO per_documentos
                     (sperson, cagente, iddocgedox)
              VALUES (pidref, pcagente, viddoc);
      END IF;

      vpasexec := 9;
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
   END f_csinotesws;

   -- Fin Bug 23687 - XVM - 09/10/2012
   FUNCTION f_obtener_cambio_moneda(
      pcempres IN NUMBER,
      pcmoneda_origen IN NUMBER,
      pcmoneda_destino IN NUMBER,
      pfcambio IN DATE,
      pcambio_desde IN BOOLEAN,
      mensajes IN OUT t_iax_mensajes,
      tvalcotiza OUT tab_cambiomoneda)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000)
         := 'pcempres: ' || pcempres || ' pcmoneda_origen: ' || pcmoneda_origen
            || ' pcmoneda_destino: ' || pcmoneda_destino || ' pfcambio: ' || pfcambio
            || ' pcambio_desde: ' ||(CASE pcambio_desde
                                        WHEN TRUE THEN 'TRUE'
                                        ELSE 'FALSE'
                                     END);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vobject        VARCHAR2(200) := 'PAC_MD_CON.f_obtener_cambio_moneda';
      vfichero       VARCHAR2(100);
      verror         NUMBER;
      vtfichpath     VARCHAR2(300);
      vsinterf       NUMBER;
      v_msg          VARCHAR2(32000);
      v_msgout       VARCHAR2(32000);
      vparser        xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      verrort        VARCHAR2(1000);
      vpasexec       NUMBER(10);
      vboolean       VARCHAR2(10);
      vauxilia       NUMBER(1);

      FUNCTION f_booltochar(p_bool IN BOOLEAN)
         RETURN VARCHAR2 IS
         l_chr          VARCHAR2(10) := NULL;
      BEGIN
         l_chr :=(CASE p_bool
                     WHEN TRUE THEN 'true'
                     ELSE 'false'
                  END);
         RETURN(l_chr);
      END;
   BEGIN
      --pac_md_common.f_get_cxtempresa
      vpasexec := 1;
      pac_int_online.p_inicializar_sinterf;
      vsinterf := pac_int_online.f_obtener_sinterf;
      vpasexec := 2;
      vboolean := f_booltochar(pcambio_desde);
      vpasexec := 3;
      v_msg := '<cambio_moneda_out>' || '<sinterf>' || vsinterf || '</sinterf>' || '<cempres>'
               || pcempres || '</cempres>' || '<cmoneda_origen>' || pcmoneda_origen
               || '</cmoneda_origen>' || '<cmoneda_destino>' || pcmoneda_destino
               || '</cmoneda_destino>' || '<fcambio>' || TO_CHAR(pfcambio, 'YYYY-MM-DD')
               || '</fcambio>' || '<cambio_desde>' || vboolean || '</cambio_desde>'
               || '</cambio_moneda_out>';
      vpasexec := 4;
      vauxilia := pac_int_online.f_inicializar_log_listener('I025', v_msg, vsinterf);
      vpasexec := 41;
      pac_int_online.peticion_host(pcempres, 'I025', v_msg, v_msgout);
      vpasexec := 5;
      pac_xml.parsear(v_msgout, vparser);
      vpasexec := 6;
      v_domdoc := xmlparser.getdocument(vparser);
      vpasexec := 7;
      verror := pac_xml.buscarnodotexto(v_domdoc, 'inderrpro');

      IF verror <> 0 THEN
         -- verror := pac_xml.buscarnodotexto(v_domdoc, 'inderrpro');
         -- verror := pac_xml.buscarnodotexto(v_domdoc, 'inderrpro');
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      vpasexec := 8;

      SELECT pcmoneda_origen cmonedaorigen,
             pcmoneda_destino cmonedadestino,
             TO_DATE
                  (a.EXTRACT('/axiscon/cambio_moneda_in/cambio/fcambio/text()').getstringval(),
                   'yyyy-mm-dd') fcambio,
             TO_NUMBER
                     (a.EXTRACT('/axiscon/cambio_moneda_in/cambio/taza/text()').getstringval(),
                      '999999999999.9999999') valor
      BULK COLLECT INTO tvalcotiza
        FROM TABLE(XMLSEQUENCE(XMLTYPE(v_msgout))) a;

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
      vobject        VARCHAR2(200) := 'pac_md_con.f_ultimoSeguroVehiculo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ptipomatricula || '-' || pmatricula;
      error          NUMBER;
      terror         VARCHAR2(2000);   --//ACC recuperar desde literales
   BEGIN
      error := pac_con.f_ultimosegurovehiculo(pac_md_common.f_get_cxtempresa, ptipomatricula,
                                              pmatricula, pfechaultimavig, pcompani, psinterf,
                                              terror);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

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
      vobject        VARCHAR2(200) := 'pac_md_con.f_antiguedadConductor';
      terror         VARCHAR2(2000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ptipodoc || '-' || pnnumide;
      error          NUMBER;
   BEGIN
      error := pac_con.f_antiguedadconductor(pac_md_common.f_get_cxtempresa, ptipodoc,
                                             pnnumide, pantiguedad, pcompani, psinies,
                                             psinterf, terror);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000001, terror);
      END IF;

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
      vobject        VARCHAR2(200) := 'pac_md_con.F_SOLICITAR_INSPECCION';
      terror         VARCHAR2(2000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := psseguro || '-' || pnriesgo || '-' || pnmovimi || '-' || pmotinspec || '-'
            || ptabla;
      error          NUMBER;
   BEGIN
      error := pac_con.f_solicitar_inspeccion(pac_md_common.f_get_cxtempresa, psseguro,
                                              pnriesgo, pnmovimi, pmotinspec, ptabla,
                                              pnordenext, psinterf, terror);

      IF error <> 0 THEN
         IF terror IS NOT NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, terror);
         END IF;

         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905725);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_lista_contratos_pago(
      pipago IN NUMBER,
      psperson IN NUMBER,
      pnsinies IN VARCHAR2,
      psseguro IN NUMBER,
      psinterf OUT NUMBER,
      pcontratos OUT t_iax_sin_trami_pago_ctr,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_con.f_lista_contratos_pago';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pipago: ' || pipago || ' psperson: ' || psperson || ' pnsinies: ' || pnsinies
            || ' psseguro: ' || psseguro;
      verror         NUMBER;
      vcempres       NUMBER;
      v_msg          VARCHAR2(32000);
      v_msgout       VARCHAR2(32000);
      vccc           VARCHAR2(100);
      vauxilia       NUMBER(1);
      vparser        xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      vob            ob_iax_sin_trami_pago_ctr;
      vsquery        VARCHAR2(4000);
      cur            sys_refcursor;
   BEGIN
      --pac_md_common.f_get_cxtempresa
      vpasexec := 1;
      pac_int_online.p_inicializar_sinterf;
      psinterf := pac_int_online.f_obtener_sinterf;
      vpasexec := 2;
      vcempres := pac_md_common.f_get_cxtempresa;
      vpasexec := 3;

      BEGIN
         SELECT CASE
                   WHEN cramo IN(331, 334, 335, 337, 340) THEN '510210' || '0000'
                   WHEN cramo = 338 THEN '510211' || '0000'
                   WHEN cramo = 339 THEN '510214' || '0000'
                   ELSE '510213' || '0000'
                END
           INTO vccc
           FROM seguros s
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001250);
            RETURN 9001250;   --error en datos enviados
      END;

      vpasexec := 4;
      v_msg := '<presupuestacion_out>' || '<cempres>' || vcempres || '</cempres>'
               || '<sinterf>' || psinterf || '</sinterf>' || '<presupuestacion>'
               || '<entidadcp>' || '1000' || '</entidadcp>' || '<numcuenta>' || vccc
               || '</numcuenta>' || '<fechadocumento>' || TO_CHAR(f_sysdate, 'yyyy-mm-dd')
               || '</fechadocumento>' || '<fechacontab>' || TO_CHAR(f_sysdate, 'yyyy-mm-dd')
               || '</fechacontab>' || '<imp_moneda_local>' || pipago || '</imp_moneda_local>'
               || '<pos_presup>' || '001-001' || '</pos_presup>' || '<cgestor>' || 'POSITIVA'
               || '</cgestor>' || '<persona>' || psperson || '</persona>'
               || '</presupuestacion>' || '</presupuestacion_out>';
      vpasexec := 5;
      vauxilia := pac_int_online.f_inicializar_log_listener('I043', v_msg, psinterf);
      vpasexec := 6;
      pac_int_online.peticion_host(vcempres, 'I043', v_msg, v_msgout);
      vpasexec := 7;
      pac_xml.parsear(v_msgout, vparser);
      vpasexec := 8;
      v_domdoc := xmlparser.getdocument(vparser);
      vpasexec := 9;
      verror := pac_xml.buscarnodotexto(v_domdoc, 'inderrpro');

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      vpasexec := 10;
      vsquery :=
         'SELECT a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/crp/text()'').getstringval() crp,
                         a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/poscrp/text()'').getstringval() poscrp,
                         a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/contrato/text()'').getstringval() contrato,
                         a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/cdp/text()'').getstringval() cdp,
                         a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/pospres/text()'').getstringval() pospres,
                         a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/cgestor/text()'').getstringval() cgestor,
                         TO_NUMBER(a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/imp_moneda_local/text()'').getstringval(),
                                   ''999999999999.9999999'') imp_moneda_local,
                         a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/desc_contrato/text()'').getstringval() desc_contrato,
                         a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/mensaje/text()'').getstringval() mensaje,
                         a.EXTRACT(''/axiscon/presupuestacion_in/presupuestacion/status/text()'').getstringval() status
                  FROM TABLE(XMLSEQUENCE(XMLTYPE('''
         || v_msgout || '''))) a';
      pcontratos := t_iax_sin_trami_pago_ctr();
      vob := ob_iax_sin_trami_pago_ctr();
      vpasexec := 11;
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 12;

      LOOP
         FETCH cur
          INTO vob.crp, vob.poscrp, vob.contrato, vob.cdp, vob.posres, vob.cgestor,
               vob.imp_moneda_local, vob.desc_contrato, vob.mensaje, vob.status;

         EXIT WHEN cur%NOTFOUND;

         IF vob.status = 'W' THEN
            IF UPPER(vob.mensaje) = UPPER('No existen CRP para utilizar')
               OR UPPER(vob.mensaje) = UPPER('No existe CDP') THEN
               vob.status := 1;   --No hay contratos
            ELSE
               IF UPPER(vob.mensaje) =
                            UPPER('Acreedor sin CRP válidos, Contratos Asociados no Vigentes')
                  OR UPPER(vob.mensaje) =
                              UPPER('Todos los CRP vigentes tienen su importe total consumido')
                  OR UPPER(vob.mensaje) = UPPER('Los CRP vigentes tienen un importe inferior') THEN
                  vob.status := 2;   --No hay contratos vigentes
               END IF;
            END IF;
         ELSE
            vob.status := 0;   --Mostrar contratos
         END IF;

         pcontratos.EXTEND;
         pcontratos(pcontratos.LAST) := vob;
         vob := ob_iax_sin_trami_pago_ctr();
      END LOOP;

      vpasexec := 13;

      CLOSE cur;

      vpasexec := 14;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lista_contratos_pago;

   FUNCTION f_resultado_carga(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_MD_CON.f_resultado_carga';
      vparam         VARCHAR2(2000) := 'Params: sproces:' || psproces;
      vpasexec       NUMBER(10);
      verror         NUMBER;
      vauxilia       NUMBER(1);
      v_domdoc       xmldom.domdocument;
      vparser        xmlparser.parser;
      vsinterf       NUMBER;
      vcerror        resultado_carga_generico.cerror%TYPE;
      vfcarga        VARCHAR2(10);
      vrefcia        resultado_carga_generico.refcia%TYPE;
      vcproceso      resultado_carga_generico.cproceso%TYPE;
      vtproceso      resultado_carga_generico.tproceso%TYPE;
      vtmsg          resultado_carga_generico.tmsg%TYPE;
      v_msg          VARCHAR2(32000);
      v_msgout       VARCHAR2(32000);
      vpath          VARCHAR2(250);
   BEGIN
      pac_int_online.p_inicializar_sinterf;
      vsinterf := pac_int_online.f_obtener_sinterf;

      SELECT cproceso, tproceso, cerror, tmsg, TO_CHAR(fcarga, 'RRRR-MM-DD') fcarga,
             refcia   -- BUG 27849 MMS 20140502 -- agragar formato de fcarga
        INTO vcproceso, vtproceso, vcerror, vtmsg, vfcarga,
             vrefcia
        FROM resultado_carga_generico
       WHERE sproces = psproces;

      vpasexec := 1;
      v_msg := '<resultado_proceso_out>' || '<sinterf>' || vsinterf || '</sinterf>'
               || '<cempres>' || pcempres || '</cempres>' || '<cerror>' || vcerror
               || '</cerror>' || '<fecha_cargue>' || vfcarga || '</fecha_cargue>' || '<refcia>'
               || vrefcia || '</refcia>' || '<sproces>' || psproces || '</sproces>'
               || '<cproceso>' || vcproceso || ';' || vtproceso || '</cproceso>' || '<tmsg>'
               || vtmsg || '</tmsg>' || '</resultado_proceso_out>';
      vpasexec := 2;
      vauxilia := pac_int_online.f_inicializar_log_listener('I044', v_msg, vsinterf);
      vpasexec := 3;
      pac_int_online.peticion_host(pcempres, 'I044', v_msg, v_msgout);
      vpasexec := 5;
      pac_xml.parsear(v_msgout, vparser);
      vpasexec := 6;
      v_domdoc := xmlparser.getdocument(vparser);
      vpasexec := 7;
      verror := pac_xml.buscarnodotexto(v_domdoc, 'inderrpro');

      IF verror <> 0 THEN
         -- verror := pac_xml.buscarnodotexto(v_domdoc, 'inderrpro');
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      vpasexec := 8;
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

   -- INICIO Bug24918 MMS 20140130
   FUNCTION f_export_datos_sian(
      pcempres IN NUMBER,
      ppath_in IN VARCHAR2,
      ppath_out IN VARCHAR2,
      pfich IN VARCHAR2,
      pproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      trespuesta OUT tab_resp_sian)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_MD_CON.f_export_datos';
      vparam         VARCHAR2(2000)
         := 'Params: pcempres:' || pcempres || ' ppath_in:' || ppath_in || ' ppath_out:'
            || ppath_out || ' pfich:' || pfich;
      vpasexec       NUMBER(10);
      verror         NUMBER;
      vauxilia       NUMBER(1);
      v_domdoc       xmldom.domdocument;
      vparser        xmlparser.parser;
      vsinterf       NUMBER;
      v_msg          VARCHAR2(32000);
      v_msgout       VARCHAR2(32000);
      vpath          VARCHAR2(250);
   BEGIN
      pac_int_online.p_inicializar_sinterf;
      vsinterf := pac_int_online.f_obtener_sinterf;
      vpath := ppath_in || '/' || pfich;
      vpasexec := 1;
      v_msg := '<fileexport_out>' || '<sinterf>' || vsinterf || '</sinterf>' || '<cempres>'
               || pcempres || '</cempres>' || '<usuario>IAXIS</usuario>'
               || '<password>pruebas</password>' || '<entorno>SIAN</entorno>' || '<fichero>'
               || '<pathabsolutoenvio>' || vpath || '</pathabsolutoenvio>'
               || '<pathabsolutorespuesta>' || ppath_out || '</pathabsolutorespuesta>'
               || '<referenciacliente />' || '<tipocliente>' || pproduc || '</tipocliente>'
               || '' || '<referenciaIAXIS />' || '</fichero>' || '</fileexport_out>';
      vpasexec := 2;
      vauxilia := pac_int_online.f_inicializar_log_listener(k_cinterfsian, v_msg, vsinterf);
      vpasexec := 3;
      pac_int_online.peticion_host(pcempres, k_cinterfsian, v_msg, v_msgout);
      vpasexec := 5;
      pac_xml.parsear(v_msgout, vparser);
      vpasexec := 6;
      v_domdoc := xmlparser.getdocument(vparser);
      vpasexec := 7;
--      verror := pac_xml.buscarnodotexto(v_domdoc, 'inderrpro');

      --      IF verror <> 0 THEN
--         -- verror := pac_xml.buscarnodotexto(v_domdoc, 'inderrpro');
--         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
--         RAISE e_object_error;
--      END IF;
      vpasexec := 8;

      SELECT a.EXTRACT('/axiscon/mensajes/inderrpro/text()').getstringval() ok,
             a.EXTRACT('/axiscon/fileexport_in/fichero/pathabsolutorespuesta/text()').getstringval
                                                                                             ()
                                                                                       mensaje
      BULK COLLECT INTO trespuesta
        FROM TABLE(XMLSEQUENCE(XMLTYPE(v_msgout))) a;

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
-- FIN Bug24918 MMS 20140130
END pac_md_con;
/
