--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DEVOLUCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DEVOLUCIONES" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_DEVOLUCIONES
   PROPÓSITO: Funciones para la gestión de las devoluciones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/05/2009   XPL             1. Creación del package.
   2.0        23/04/2012   JMF             2. 0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
   3.0        26/07/2012   JGR             3. 0022086: LCOL_A003-Devoluciones - Fase 2 - 0117715
   4.0        11/06/2012   APD             4. 0022342: MDP_A001-Devoluciones
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
        Función que seleccionará información sobre los procesos de devolució
        param in pcempres     : codigo empresa
        param in psedevolu    : nº proceso de devolución
        param in pfsoport     : fecha confección del soporte
        param in pfcarga      : fecha carga del soporte
        param out pdevoluciones  : ref cursor
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_consulta_devol(
      pcempres IN NUMBER,
      psdevolu IN NUMBER,
      pfsoport IN DATE,
      pfcarga IN DATE,
      pdevoluciones OUT sys_refcursor,
      mensajes OUT t_iax_mensajes,
      pccobban IN NUMBER DEFAULT NULL,   -- 3.  0022086 / 0117715
      psperson IN NUMBER DEFAULT NULL,   -- 3.  0022086 / 0117715
      ptipo IN NUMBER DEFAULT NULL,   -- 3.  0022086 / 0117715
      pfcargaini IN DATE DEFAULT NULL,
      pfcargafin IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_get_consulta_Devol';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres : ' || pcempres || ', psdevolu : ' || psdevolu
            || ', pfsoport : ' || pfsoport || ' ,pfcarga : ' || pfcarga || ', pccobban : '
            || pccobban || ' ,psperson : ' || psperson || ', ptipo : ' || ptipo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_devoluciones.f_get_consulta_devol(pcempres, psdevolu, pfsoport,
                                                          pfcarga, pdevoluciones, mensajes,

                                                          -- 3.  0022086 / 0117715 - Inicio
                                                          pccobban, psperson, ptipo,
                                                          pfcargaini, pfcargafin
                                                                                -- 3.  0022086 / 0117715 - Fin
                );

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_consulta_devol;

   /*************************************************************************
        Función que se encargará de recuperar la información de un procseo de
        devolución.
        param in psedevolu    : nº proceso de devolución
        param out pdevoluciones  : ref cursor
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_datos_devolucion(
      psdevolu IN NUMBER,
      pdevoluciones OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_get_Datos_devolucion';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu :' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psdevolu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_devoluciones.f_get_datos_devolucion(psdevolu, pdevoluciones, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_datos_devolucion;

   /*************************************************************************
        Función que se encargará de devolver los recibos de una devolución
        param in psedevolu     : nº proceso de devolución
        param out plstrecibos  : ref cursor recibos de una devolución
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_datos_recibos_devol(
      psdevolu IN NUMBER,
      plstrecibos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_get_datos_recibos_devol';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu : ' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psdevolu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_devoluciones.f_get_datos_recibos_devol(psdevolu, plstrecibos, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_datos_recibos_devol;

   /*************************************************************************
        Función que se encargará guardar los parámetros de entrada en la colección
        param in pcempres     : codigo empresa
        param in psedevolu     : nº proceso de devolución
        param in pcdevsit     : codigo situación recibo devuelto
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_set_objeto_rec_revis(
      pnrecibo IN NUMBER,
      psdevolu IN NUMBER,
      pcdevsit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_set_Objeto_Rec_Revis';
      vparam         VARCHAR2(500)
         := 'parámetros - pnrecibo : ' || pnrecibo || ', psdevolu : ' || psdevolu
            || ', pcdevsit : ' || pcdevsit;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      trobat         BOOLEAN := FALSE;
      v_index        NUMBER;
   BEGIN
      IF psdevolu IS NULL
         OR pnrecibo IS NULL
         OR pcdevsit IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR i IN vsitrecdev.FIRST .. vsitrecdev.LAST LOOP
         IF vsitrecdev(i).nrecibo = pnrecibo THEN   -- Si el trobem, el modifiq
            vsitrecdev(i).sdevolu := psdevolu;
            vsitrecdev(i).nrecibo := pnrecibo;
            vsitrecdev(i).cdevsit := pcdevsit;
            trobat := TRUE;
         END IF;
      END LOOP;

      IF trobat = FALSE THEN
         vsitrecdev.EXTEND;
         v_index := vsitrecdev.LAST;
         vsitrecdev(v_index) := ob_iax_sitrecdev();
         vsitrecdev(v_index).sdevolu := psdevolu;
         vsitrecdev(v_index).nrecibo := pnrecibo;
         vsitrecdev(v_index).cdevsit := pcdevsit;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_objeto_rec_revis;

   /*************************************************************************
        Función que recuperará los recibos de un proceso de devolución y su estado de revisión
        del objeto persistente
        param IN psdevolu     : nº proceso de devolución
        param OUT ptsitrecdev : t_iax_sitrecdev,
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_rec_revis(
      psdevolu IN NUMBER,
      ptsitrecdev OUT t_iax_sitrecdev,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_get_Rec_Revis';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu : ' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      ptsitrecdev := vsitrecdev;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_rec_revis;

   /*************************************************************************
        Función que recuperará los recibos de un proceso de devolución y su estado de revisión
        inicializa el objeto persistente de bbdd
        param IN psdevolu     : nº proceso de devolución
        param OUT ptsitrecdev : t_iax_sitrecdev,
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_inicializar_rec_revis(
      psdevolu IN NUMBER,
      ptsitrecdev OUT t_iax_sitrecdev,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_get_Rec_Revis';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu : ' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_devoluciones.f_get_rec_revis(psdevolu, ptsitrecdev, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vsitrecdev := ptsitrecdev;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_inicializar_rec_revis;

   /*************************************************************************
        Función que recuperará los recibos de un proceso de devolución y su estado de revisión
        param IN psdevolu     : nº proceso de devolución
        param OUT ptsitrecdev : t_iax_sitrecdev,
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_set_rec_revis(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_set_Rec_Revis';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_devoluciones.f_set_rec_revis(vsitrecdev, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_rec_revis;

   /*************************************************************************
        Función que se encargará gde generar el listado de recibos devueltos para un proceso
        de devolución en concreto
        param in psedevolu     : nº proceso de devolución
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_listado_devol(
      psdevolu IN NUMBER,
      pnomfichero OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_get_listado_devol';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu : ' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psdevolu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_devoluciones.f_get_listado_devol(psdevolu, pnomfichero, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_listado_devol;

   /*************************************************************************
        Función que se encargará gde generar las cartas de devoluciones de recibos de un proceso de devolución
        de devolución en concreto
        param in psedevolu     : nº proceso de devolución
        param out pplantilla  : 0=No tiene plantillas, 1=Si tiene plantillas
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
        -- Bug 0022030 - 23/04/2012 - JMF
     *************************************************************************/
   FUNCTION f_get_cartas_devol(
      psdevolu IN NUMBER,
      pplantilla OUT NUMBER,
      pnomfichero OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_get_cartas_devol';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu : ' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psdevolu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_devoluciones.f_get_cartas_devol(psdevolu, pplantilla, pnomfichero,
                                                        mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_cartas_devol;

   /*************************************************************************
        Función que se encargará de cargar los recibos especificados en el fichero de devoluciones informado por param.
        de devolución en concreto
        param in pnomfitxer   : nombre del fichero de devolución
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_carga_fichero(
      pnomfitxer IN VARCHAR2,
      psproces OUT NUMBER,
      p_fich_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_get_carga_fichero';
      vparam         VARCHAR2(500) := 'parámetros - pnomfitxer : ' || pnomfitxer;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_devoluciones.f_get_carga_fichero(pac_iax_common.f_get_cxtempresa,
                                                         pnomfitxer, psproces, p_fich_out,
                                                         mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_carga_fichero;

   /*************************************************************************
        Función que realizará las devoluciones de los recibos especificados en el fichero y cargados en las
        tablas de devolución de recibos al hacer la carga previa del fichero.
        de devolución en concreto
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_exec_devolu(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_exec_devolu';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_devoluciones.f_exec_devolu(mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_exec_devolu;

   /*************************************************************************
          Función que seleccionará información sobre las cartas de devolución
          param in psgescarta     : Id. carta
          param in pnpoliza     : nº poliza
          param in pnrecibo     : nº recibo
          param in pcestimp     : estado de impresión de carta
          param in pfini        : fecha inicio solicitud impresión
          param in pffin        : fecha fin solicitud impresión
          param in pcempres      : codigo de la empresa
          param in pcramo      : codigo del ramo
          param in psproduc      : codigo del producto
          param in pcagente      : codigo del agente
          param in pcremban      : Número de remesa interna de la entidad bancaria
          param out mensajes    : mensajes de error
          return                : NUMBER 0 / 1
       *************************************************************************/
   -- Bug 22342 - APD - 11/06/2012 - se añaden los parametros pcempres, pcramo,
   -- psproduc, pcagente, pcremban
   FUNCTION f_get_consulta_cartas(
      psgescarta IN NUMBER,
      pnpoliza IN NUMBER,
      pnrecibo IN NUMBER,
      pcestimp IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pcremban IN NUMBER,
      pcartas OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_get_Consulta_Cartas';
      vparam         VARCHAR2(500)
         := 'parámetros - psgescarta : ' || psgescarta || ', pnpoliza : ' || pnpoliza
            || ', pnrecibo : ' || pnrecibo || ' ,pcestimp : ' || pcestimp || ' ,pfini : '
            || pfini || ', pffin' || pffin || ', pcempres' || pcempres || ', pcramo' || pcramo
            || ', psproduc' || psproduc || ', pcagente' || pcagente || ', pcremban'
            || pcremban;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_index        NUMBER;
   BEGIN
      vnumerr := pac_md_devoluciones.f_get_consulta_cartas(psgescarta, pnpoliza, pnrecibo,
                                                           pcestimp, pfini, pffin, pcempres,
                                                           pcramo, psproduc, pcagente,
                                                           pcremban, pcartas, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_consulta_cartas;

   /*************************************************************************
          Función que modificará el estado de impresión de una carta
          param in psgescarta     : Id. carta
          param in pcestimp     : estado de impresión de carta
          param out mensajes    : mensajes de error
          return                : NUMBER 0 / 1
       *************************************************************************/
   FUNCTION f_set_estimp_carta(
      psdevolu IN NUMBER,
      pnrecibo IN NUMBER,
      pcestimp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_devoluciones.f_set_estimp_carta';
      vparam         VARCHAR2(500)
                    := 'parámetros - psgescarta : ' || psdevolu || ' ,pcestimp : ' || pcestimp;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_index        NUMBER;
   BEGIN
      vnumerr := pac_md_devoluciones.f_set_estimp_carta(psdevolu, pnrecibo, pcestimp,
                                                        mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estimp_carta;

/*************************************************************************
      Recupera el código y la descripción del proceso de devolución
      param out pdevoluciones : ref cursor
      param out mensajes : mensajes de error
      return             : 0(OK!)/1(Error)

          18/05/2009   XPL                 Maps.  Bug: 8957
*************************************************************************/
   FUNCTION f_get_devoluciones(
      pcempres IN NUMBER,
      pdevoluciones OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(10) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES.f_get_motivosrehab';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_devoluciones.f_get_devoluciones(pcempres, pdevoluciones, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam,
                                           vnumerr);

         IF pdevoluciones%ISOPEN THEN
            CLOSE pdevoluciones;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF pdevoluciones%ISOPEN THEN
            CLOSE pdevoluciones;
         END IF;

         RETURN 1;
   END f_get_devoluciones;

   /***********************************************************************
      Recupera un path de directori
      param out ppath    : pàrametre carga valores
      param out mensajes : missatge d'error
      return             : 0/1 -> Tot OK/Error
   ***********************************************************************/
   FUNCTION f_get_directorio(ppath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.F_Get_Directorio';
      vparam         VARCHAR2(500) := 'parámetros';
      vpasexec       NUMBER(5) := 1;
      pparam_aux     VARCHAR2(10) := 'PATH_DEVOL';
      vnumerr        NUMBER(1) := 0;
   BEGIN
      vpasexec := 3;
      vnumerr := pac_md_devoluciones.f_get_directorio(pparam_aux, ppath, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_directorio;
END pac_iax_devoluciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DEVOLUCIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DEVOLUCIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DEVOLUCIONES" TO "PROGRAMADORESCSI";
