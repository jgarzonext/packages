--------------------------------------------------------
--  DDL for Package Body PAC_MD_AGENSEGU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_AGENSEGU" AS
   /******************************************************************************
      NOMBRE:       pac_md_agensegu
      PROPÓSITO:  Gestión de los apuntes de la agenda de una póliza

      REVISIONES:
      Ver        Fecha        Autor      Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        05/03/2009   JSP        1. Creación del package.
      2.0        09/07/2009   DCT        2. Modificacion funciones. Añadir nuevo parametro pncertif
      3.0        25/09/2009   NMM        3. 11177: CRE - Agenda de póliza.Canvi long. vparam.
   ******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
   Función F_GET_ConsultaApuntes
   Obtiene la información sobre apuntes de la agenda dependiendo de los parámetros de entrada
   param in Pctipreg   : concepto de apunte
   param in Pnpoliza   : nº de póliza relacionada al apunte
   param in pncertif   : nº de certificado de la póliza
   param in pncertif   : nº de certificado de la póliza
   param in pnlinea    : nº de apunte relacionado a la póliza
   param in Pcestado   : estado del apunte (0:Automático, 1:Manual)
   param in Pfapunte   : fecha alta del apunte
   param in Pcusuari   : usuario que realiza el alta del apunte
   param in Psseguro   : id. del seguro relacionado al apunte
   param out mensajes  : mensajes de error
   return              : sys_Refcursor
   *************************************************************************/
   FUNCTION f_get_consultaapuntes(
      pctipreg IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnlinea IN NUMBER,
      pcestado IN NUMBER,
      pfapunte IN DATE,
      pcusuari IN VARCHAR2,
      psseguro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vnumerr        NUMBER;
      vsquery        VARCHAR2(4000);
      vobject        VARCHAR2(500) := 'PAC_MD_AGENSEGU.F_GET_CONSULTAAPUNTES';
      vparam         VARCHAR2(5000)   -- Bug 11177.NMM.25/09/2009.
         := 'parámetros - ctipreg:' || pctipreg || ' ,npoliza:' || pnpoliza || ' ,ncertif:'
            || pncertif || ' ,nlinea:' || pnlinea || ' ,cestado:' || pcestado || ' ,fapunte:'
            || pfapunte || ' , cusuari:' || pcusuari || ' , sseguro:' || psseguro;
      vpasexec       NUMBER := 10;
   BEGIN
      -- Validaciones iniciales. Algun parametro (que no sea pnlinea) debe estar informado
      vpasexec := 20;
      vnumerr := pac_agensegu.f_get_consultaapuntes(pctipreg, pnpoliza, pncertif, pnlinea,
                                                    pac_md_common.f_get_cxtidioma(), pcestado,
                                                    pfapunte, pcusuari, psseguro, vsquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 30;
      cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 40;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);

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
   END f_get_consultaapuntes;

    /*************************************************************************
   Función F_GET_DatosApunte
   Recupera la información de un apunte de la agenda en concreto en función de los parámetros de entrada psseguro y pnlinea
   param in Psseguro: id. del seguro relacionado al apunte
   param in Pnlinea: nº de apunte relacionado a la póliza
   param out mensajes   : mensajes de error
          return              : ob_iax_agensegu
    *************************************************************************/
   FUNCTION f_get_datosapunte(
      psseguro IN NUMBER,
      pnlinea IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_agensegu IS
      cur            sys_refcursor;
      objeto_agensegu ob_iax_agensegu := ob_iax_agensegu();
      vnumerr        NUMBER;
      vsquery        VARCHAR2(4000);
      vobject        VARCHAR2(500) := 'PAC_MD_AGENSEGU.F_GET_DATOSAPUNTE';
      vparam         VARCHAR2(500)
                            := 'parámetros - sseguro:' || psseguro || ' , nlinea:' || pnlinea;
      vpasexec       NUMBER := 10;
   BEGIN
      -- Validaciones iniciales. Algun parametro (que no sea pnlinea) debe estar informado
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 20;
      vnumerr := pac_agensegu.f_get_datosapunte(psseguro, pnlinea,
                                                pac_md_common.f_get_cxtidioma(), vsquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 30;
      cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 40;

      FETCH cur
       INTO objeto_agensegu.npoliza, objeto_agensegu.ncertif,   -- Bug 11177.NMM.
                                                             objeto_agensegu.nlinea,
            objeto_agensegu.ttitulo, objeto_agensegu.ttextos, objeto_agensegu.cestado,
            objeto_agensegu.testado, objeto_agensegu.ctipreg, objeto_agensegu.ttipreg,
            objeto_agensegu.falta, objeto_agensegu.cusualt, objeto_agensegu.fmodifi,
            objeto_agensegu.cusumod, objeto_agensegu.ffinali, objeto_agensegu.sseguro,
            objeto_agensegu.cmanual, objeto_agensegu.tmanual;

      -- BUG -21546_108724- 14/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF cur%ISOPEN THEN
         CLOSE cur;
      END IF;

      RETURN objeto_agensegu;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);

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
   END f_get_datosapunte;

    /*************************************************************************
   Función F_GET_ApuntesPendientes
   Valida si existen apuntes pendientes en la agenda para el usuario a día de hoy.
      param out mensajes   : mensajes de error
          return              : Numero de apuntes pendientes
    *************************************************************************/
   FUNCTION f_get_apuntespendientes(mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
   BEGIN
      RETURN pac_agensegu.f_get_apuntespendientes();
   END f_get_apuntespendientes;

   /*************************************************************************
   Función F_SET_DatosApunte
   Inserta o modifica la información de un apunte manual en la agenda de pólizas en función del parámetro de entrada pmodo
   param in Pnpoliza: nº de póliza relacionada al apunte
   param in Psseguro: id. del seguro relacionado al apunte
   param in Pnlinea: nº de apunte relacionado a la póliza
   param in Pttitulo: Título del apunte en la agenda
   param in Pttextos: Texto del apunte en la agenda
   param in Pctipreg: concepto del apunte
   param in Pcestado: estado del apunte (0:Pendiente, 1:Finalizado, 2:Anulado). Por defecto 0.
   param in Pfapunte: fecha alta del apunte. Por defecto f_sysdate.
   param in Pffinali: fecha finalización del apunte. Por defecto NULL
   param in Pmodo in NUMBER: modo de acceso a la función (0:Alta, 1:Modificación)
   param out mensajes   : mensajes de error
          return              : 0 si ha ido bien
                                numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_datosapunte(
      pnpoliza IN NUMBER,
      psseguro IN NUMBER,
      pnlinea IN NUMBER,
      pttitulo IN VARCHAR2,
      pttextos IN VARCHAR2,
      pctipreg IN NUMBER,
      pcestado IN NUMBER,
      pfapunte IN DATE,
      pffinali IN DATE,
      pmodo IN NUMBER,
      pmode IN VARCHAR2 DEFAULT 'POL',
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(5000)   -- Bug 11177.NMM.25/09/2009.
         := 'npoliza:' || pnpoliza || ' ,psseguro:' || psseguro || ' ,nlinea:' || pnlinea
            || ' , ttitulo:' || pttitulo || ' , ttextos:' || pttextos || ' , ctipreg:'
            || pctipreg || ' ,cestado:' || pcestado || ' ,fapunte:' || pfapunte
            || ' ,ffinali:' || pffinali || ' , modo:' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_MD_AGENSEGU.F_SET_DATOSAPUNTE';
   --
   BEGIN
      IF pmodo IS NULL THEN
         vpasexec := 2;
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pmodo = 0 THEN
         vpasexec := 4;

         -- Alta agenda
         IF pnpoliza IS NULL
            OR pttitulo IS NULL
            OR pctipreg IS NULL
            OR pfapunte IS NULL THEN
            vpasexec := 5;
            RAISE e_param_error;
         END IF;
      ELSIF pmodo = 1 THEN
         vpasexec := 6;

         -- Modificació agenda
         IF psseguro IS NULL
            OR pnlinea IS NULL
            OR pttitulo IS NULL
            OR pcestado IS NULL
            OR pctipreg IS NULL THEN
            vpasexec := 7;
            RAISE e_param_error;
         END IF;
      END IF;

      vpasexec := 8;
      vnumerr := pac_agensegu.f_set_datosapunte(pnpoliza, psseguro, pnlinea, pttitulo,
                                                pttextos, pctipreg, pcestado, pfapunte,
                                                pffinali, pmodo => pmodo, pmode => pmode);
      vpasexec := 9;

      IF vnumerr <> 0 THEN
         vpasexec := 10;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         vpasexec := 11;
         RAISE e_object_error;
      END IF;

      vpasexec := 12;
      COMMIT;
      vpasexec := 13;
      RETURN(vnumerr);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           f_axis_literales(9000642,
                                                            pac_md_common.f_get_cxtidioma),
                                           9001768, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_datosapunte;

   /*************************************************************************
   Función F_Anula_Apunte
   Realiza la baja lógica de un apunte manual en la agenda de pólizas en función de los parámetros de entrada psseguro y pnlinea
   param in Psseguro: id. del seguro relacionado al apunte
   param in pnlinea : nº de apunte relacionado a la póliza
      param out mensajes   : mensajes de error
          return              : 0 si ha ido bien
                                numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_anula_apunte(
      psseguro IN NUMBER,
      pnlinea IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := ' psseguro:' || psseguro || ' ,nlinea:' || pnlinea;
      vobject        VARCHAR2(200) := 'PAC_MD_AGENSEGU.F_ANULA_APUNTE';
   BEGIN
      IF psseguro IS NULL
         OR pnlinea IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_agensegu.f_anula_apunte(psseguro, pnlinea);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_anula_apunte;
END pac_md_agensegu;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AGENSEGU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGENSEGU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGENSEGU" TO "PROGRAMADORESCSI";
