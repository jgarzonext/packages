--------------------------------------------------------
--  DDL for Package Body PAC_MD_DEVOLUCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_DEVOLUCIONES" AS
/******************************************************************************
   NOMBRE:      PAC_MD_devoluciones
   PROPÓSITO: Funciones para la gestión de las devoluciones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/05/2009   XPL             1. Creación del package.
   2.0        23/04/2012   JMF             2. 0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
   3.0        01/06/2012   JMF             3. 0022206: CALI003 - Parametrització impagaments
   4.0        26/07/2012   JGR             4. 0022086: LCOL_A003-Devoluciones - Fase 2 - 0117715
   5.0        11/06/2012   APD             5. 0022342: MDP_A001-Devoluciones
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
      mensajes IN OUT t_iax_mensajes,
      pccobban IN NUMBER DEFAULT NULL,   -- 4.  0022086 / 0117715
      psperson IN NUMBER DEFAULT NULL,   -- 4.  0022086 / 0117715
      ptipo IN NUMBER DEFAULT NULL,   -- 4.  0022086 / 0117715
      pfcargaini IN DATE DEFAULT NULL,
      pfcargafin IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_get_consulta_Devol';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres : ' || pcempres || ', psdevolu : ' || psdevolu
            || ', pfsoport : ' || pfsoport || ' ,pfcarga : ' || pfcarga || ', pccobban : '
            || pccobban || ' ,psperson : ' || psperson || ', ptipo : ' || ptipo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(4000);
   BEGIN
      vnumerr := pac_devolu.f_get_consulta_devol(pcempres, psdevolu, pfsoport, pfcarga,

                                                 -- 4.  0022086 / 0117715 - Inicio
                                                 pccobban, psperson, ptipo, pfcargaini,
                                                 pfcargafin,
                                                 -- 4.  0022086 / 0117715 - Fin
                                                 vsquery);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_DEVOLUCIONES.f_get_consulta_devol', 2, 0,
                                    mensajes) <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pdevoluciones := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF pdevoluciones%ISOPEN THEN
            CLOSE pdevoluciones;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);

         IF pdevoluciones%ISOPEN THEN
            CLOSE pdevoluciones;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF pdevoluciones%ISOPEN THEN
            CLOSE pdevoluciones;
         END IF;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_get_Datos_devolucion';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu :' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(4000);
   BEGIN
      IF psdevolu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_devolu.f_get_datos_devolucion(psdevolu, vsquery);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_DEVOLUCIONES.f_get_datos_devolucion', 2,
                                    0, mensajes) <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pdevoluciones := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF pdevoluciones%ISOPEN THEN
            CLOSE pdevoluciones;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);

         IF pdevoluciones%ISOPEN THEN
            CLOSE pdevoluciones;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF pdevoluciones%ISOPEN THEN
            CLOSE pdevoluciones;
         END IF;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_get_datos_recibos_devol';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu : ' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(4000);
   BEGIN
      IF psdevolu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_devolu.f_get_datos_recibos_devol(psdevolu,
                                                      pac_md_common.f_get_cxtidioma(), vsquery);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_DEVOLUCIONES.f_get_datos_recibos_devol',
                                    2, 0, mensajes) <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      plstrecibos := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF plstrecibos%ISOPEN THEN
            CLOSE plstrecibos;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);

         IF plstrecibos%ISOPEN THEN
            CLOSE plstrecibos;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF plstrecibos%ISOPEN THEN
            CLOSE plstrecibos;
         END IF;

         RETURN 1;
   END f_get_datos_recibos_devol;

   /*************************************************************************
        Función que recuperará los recibos de un proceso de devolución y su estado de revisión
        param IN psdevolu     : nº proceso de devolución
        param OUT ptsitrecdev : t_iax_sitrecdev,
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_rec_revis(
      psdevolu IN NUMBER,
      ptsitrecdev OUT t_iax_sitrecdev,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_get_Rec_Revis';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu : ' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;

      CURSOR cur_recdev IS
         SELECT nrecibo, cdevsit
           FROM devbanrecibos
          WHERE sdevolu = psdevolu
            AND cdevsit <> 3;
   BEGIN
      ptsitrecdev := t_iax_sitrecdev();

      FOR reg IN cur_recdev LOOP
         ptsitrecdev.EXTEND;
         ptsitrecdev(ptsitrecdev.LAST) := ob_iax_sitrecdev();
         ptsitrecdev(ptsitrecdev.LAST).nrecibo := reg.nrecibo;
         ptsitrecdev(ptsitrecdev.LAST).cdevsit := reg.cdevsit;
         ptsitrecdev(ptsitrecdev.LAST).sdevolu := psdevolu;
      END LOOP;

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
        param IN psdevolu     : nº proceso de devolución
        param OUT ptsitrecdev : t_iax_sitrecdev,
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   /*************************************************************************
        Función que recuperará los recibos de un proceso de devolución y su estado de revisión
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_set_rec_revis(psitrecdev IN t_iax_sitrecdev, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_set_Rec_Revis';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psitrecdev IS NOT NULL
         AND psitrecdev.COUNT > 0 THEN
         FOR i IN psitrecdev.FIRST .. psitrecdev.LAST LOOP
            vnumerr := pac_devolu.f_set_rec_revis(psitrecdev(i).nrecibo,
                                                  psitrecdev(i).sdevolu,
                                                  psitrecdev(i).cdevsit);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END LOOP;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001726);   --tot ha anat OK!
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 102897);   --tot ha anat OK!
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_get_listado_devol';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu : ' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psdevolu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_devolu.f_get_listado_devol(psdevolu, pac_md_common.f_get_cxtidioma,
                                                pnomfichero);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 801280);   --Listado generado correctamente
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_get_cartas_devol';
      vparam         VARCHAR2(500) := 'parámetros - psdevolu : ' || psdevolu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psdevolu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_devolu.f_get_cartas_devol(psdevolu, pac_md_common.f_get_cxtidioma(),
                                               pplantilla, pnomfichero);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF vnumerr = 0
         AND pnomfichero IS NULL
         AND NVL(pplantilla, 0) = 0 THEN
         -- Bug 0022206 - 01/06/2012 - JMF
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9903759);   --No existen cartas parametrizadas.
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 140648);   --cartas impresas
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
        param in pcempres     : empresa
        param in pnomfitxer   : nombre del fichero de devolución
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_carga_fichero(
      pcempres IN NUMBER,
      pnomfitxer IN VARCHAR2,
      psproces OUT NUMBER,
      p_fich_out OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_get_carga_fichero';
      vparam         VARCHAR2(500) := 'parámetros - pnomfitxer : ' || pnomfitxer;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_devolu.f_get_carga_fichero(pcempres, pnomfitxer,
                                                pac_md_common.f_get_cxtidioma, psproces,
                                                p_fich_out);

      IF vnumerr <> 0 THEN
         IF vnumerr = -29283 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151544);   --error de lectura en el fichero
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         END IF;

         psproces := -1;
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);   --proceso finalizado correctamente.
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
   END f_get_carga_fichero;

   /*************************************************************************
        Función que realizará las devoluciones de los recibos especificados en el fichero y cargados en las
        tablas de devolución de recibos al hacer la carga previa del fichero.
        de devolución en concreto
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_exec_devolu(mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_exec_devolu';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_devolu.f_exec_devolu(pac_md_common.f_get_cxtidioma);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   --105026 , proceso finalizado con errores
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);   --proceso finalizado correctamente
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_get_Consulta_Cartas';
      vparam         VARCHAR2(500)
         := 'parámetros - psgescarta : ' || psgescarta || ', pnpoliza : ' || pnpoliza
            || ', pnrecibo : ' || pnrecibo || ' ,pcestimp : ' || pcestimp || ' ,pfini : '
            || pfini || ', pffin' || pffin || ', pcempres' || pcempres || ', pcramo' || pcramo
            || ', psproduc' || psproduc || ', pcagente' || pcagente || ', pcremban'
            || pcremban;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_index        NUMBER;
      vsquery        VARCHAR2(4000);
   BEGIN
      vnumerr := pac_devolu.f_get_consulta_cartas(psgescarta, pnpoliza, pnrecibo, pcestimp,
                                                  pfini, pffin, pac_md_common.f_get_cxtidioma,
                                                  pcempres, pcramo, psproduc, pcagente,
                                                  pcremban, vsquery);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_DEVOLUCIONES.f_get_consulta_cartas', 2,
                                    0, mensajes) <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pcartas := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF pcartas%ISOPEN THEN
            CLOSE pcartas;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);

         IF pcartas%ISOPEN THEN
            CLOSE pcartas;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF pcartas%ISOPEN THEN
            CLOSE pcartas;
         END IF;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_devoluciones.f_set_estimp_carta';
      vparam         VARCHAR2(500)
                    := 'parámetros - psgescarta : ' || psdevolu || ' ,pcestimp : ' || pcestimp;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_index        NUMBER;
   BEGIN
      IF psdevolu IS NULL
         OR pnrecibo IS NULL
         OR pcestimp IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_devolu.f_set_estimp_carta(psdevolu, pnrecibo, pcestimp);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9001646);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_devoluciones.F_Get_devoluciones';
      terror         VARCHAR2(200) := '';
      vsquery        VARCHAR2(2000);
      param          VARCHAR2(2000) := ' and 1=1';
   BEGIN
      IF pcempres IS NOT NULL THEN
         param := ' and cempres = ' || pcempres;
      END IF;

      vsquery :=
         'SELECT distinct sdevolu, sdevolu ||'' - ''|| tprenom as tprenom
            FROM devbanpresentadores
            where fsoport between add_months(f_sysdate,-2) and f_sysdate '
         || param || '
            ORDER BY sdevolu desc
            ';
      pdevoluciones := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF pdevoluciones%ISOPEN THEN
            CLOSE pdevoluciones;
         END IF;

         RETURN 1;
   END f_get_devoluciones;

   /***********************************************************************
       Recupera un path de directori
       param in pparam : valor de path
       param out ppath    : pàrametre PATH_VLIQ
       param out mensajes : missatge d'error
       return             : 0/1 -> Tot OK/Error
    ***********************************************************************/
   FUNCTION f_get_directorio(
      pparam IN VARCHAR2,
      ppath OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_DEVOLUCIONEs.F_Get_Directorio';
      vparam         VARCHAR2(500) := 'parámetros - pparam: ' || pparam;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(1) := 0;
   BEGIN
      ppath := f_parinstalacion_t(pparam);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_directorio;
END pac_md_devoluciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DEVOLUCIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DEVOLUCIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DEVOLUCIONES" TO "PROGRAMADORESCSI";
