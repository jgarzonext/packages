--------------------------------------------------------
--  DDL for Package Body PAC_MD_FIC_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_FIC_PROCESOS" AS
        /******************************************************************************
          NOMBRE:       PAC_MD_FIC_PROCESOS
     PROPÓSITO: Nuevo paquete de la capa MD que tendrá las funciones para la gestión de procesos del gestor de informes.
                Controlar todos posibles errores con PAC_IOBJ_MNSAJES.P_TRATARMENSAJE


     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        16/06/2009   JMG                1. Creación del package.
   ******************************************************************************/

   /*******************************************************************************
         F_get_Ficprocesos
   Nueva función de la capa MD que devolverá los procesos del gestor de informes

   Parámetros

   1. pcempres IN NUMBER
   2. psproces IN NUMBER
   3. ptgestor IN VARCHAR2
   4. ptformat IN VARCHAR2
   5. ptanio   IN VARCHAR2
   6. ptmes    IN VARCHAR2
   7. ptdiasem IN VARCHAR2
   8. pcusuari IN VARCHAR2
   9. pfproini IN DATE
   10. mensajes OUT T_IAX_MENSAJES


         Retorna : REF CURSOR.
         ********************************************************************************/
   FUNCTION f_get_ficprocesos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      ptgestor IN VARCHAR2,
      ptformat IN VARCHAR2,
      ptanio IN VARCHAR2,
      ptmes IN VARCHAR2,
      ptdiasem IN VARCHAR2,
      pnerror IN NUMBER,
      pcusuari IN VARCHAR2,
      pfproini IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'Pcempres=' || pcempres || ' Psproces=' || psproces || ' ptgestor=' || ptgestor
            || ' ptformat=' || ptformat || ' ptanio=' || ptanio || ' ptmes=' || ptmes
            || ' ptdiasem=' || ptdiasem || ' pcusuari=' || pcusuari || ' pfproini='
            || pfproini;
      vobject        VARCHAR2(200) := 'PAC_MD_FIC_PROCESOS.F_get_Ficprocesos';
      vquery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      v_result       sys_refcursor;
      vidioma        NUMBER(1);
   BEGIN
      -- Control parametros entrada
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vidioma := pac_md_common.f_get_cxtidioma;

      IF vidioma != 0 THEN
         --Esta  función deberá seleccionar aquellos procesos a partir de criterios de busquema
         vnumerr := pac_fic_procesos.f_get_ficprocesos(pcempres, psproces, ptgestor, ptformat,
                                                       ptanio, ptmes, ptdiasem, pnerror,
                                                       pcusuari, pfproini, vidioma, vquery);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
            RAISE e_object_error;
         END IF;

         v_result := pac_md_listvalores.f_opencursor(vquery, mensajes);
         RETURN v_result;
      ELSE
         RETURN NULL;
      END IF;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_ficprocesos;

/*******************************************************************************
           f_get_ficprocesosdet
     Nueva función de la capa MD que devolverá el detalle de los procesos del gestor de informes

     Parámetros

     2. psproces IN NUMBER
     3. mensajes OUT T_IAX_MENSAJES

           Retorna : objeto type t_iax_procesoslin.
********************************************************************************/
   FUNCTION f_get_ficprocesosdet(psproces IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_fic_procesosdet IS
      cur            sys_refcursor;
      procesoss      t_iax_fic_procesosdet := t_iax_fic_procesosdet();
      procesos       ob_iax_fic_procesosdet := ob_iax_fic_procesosdet();
      squery         VARCHAR2(2000);
      verror         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(250) := 'param: - SPROCES : ' || psproces;
      vobject        VARCHAR2(200) := 'PAC_MD_FIC_PROCESOS.F_get_ficprocesosdet';
   BEGIN
      verror := pac_fic_procesos.f_get_ficprocesosdet(psproces, squery);

      IF verror = 0 THEN
         cur := pac_iax_listvalores.f_opencursor(squery, mensajes);

         LOOP
            FETCH cur
             INTO procesos.sproces, procesos.nprolin, procesos.tpathfi, procesos.fprolin,
                  procesos.ctiplin, procesos.ttiplin, procesos.tfprolin;

            EXIT WHEN cur%NOTFOUND;
            procesoss.EXTEND;
            procesoss(procesoss.LAST) := procesos;
            procesos := ob_iax_fic_procesosdet();
         END LOOP;

         CLOSE cur;
      END IF;

      RETURN procesoss;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_ficprocesosdet;
END pac_md_fic_procesos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FIC_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FIC_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FIC_PROCESOS" TO "PROGRAMADORESCSI";
