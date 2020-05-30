--------------------------------------------------------
--  DDL for Package Body PAC_IAX_AGENSEGU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_AGENSEGU" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_AGENSEGU
      PROPÓSITO:  Gestión de los apuntes de la agenda de una póliza

      REVISIONES:
      Ver        Fecha        Autor      Descripción
      ---------  ----------  ---------  ------------------------------------
      1.0        07/02/2008   ACC         1. Creación del package.
      2.0        09/07/2009   DCT         2. Modificacion funciones. Añadir nuevo parametro pncertif
      3.0        25/09/2009   NMM         3. 11177: CRE - Agenda de póliza.Canvi long. vparam.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
   Función F_GET_ConsultaApuntes
   Obtiene la información sobre apuntes de la agenda dependiendo de los parámetros de entrada
   param in Pctipreg : concepto de apunte
   param in Pnpoliza : nº de póliza relacionada al apunte
   param in pncertif : nº de certificado de la póliza
   param in pnlinea : nº de apunte relacionado a la póliza
   param in Pcestado: estado del apunte (0:Automático, 1:Manual)
   param in Pfapunte: fecha alta del apunte
   param in Pcusuari: usuario que realiza el alta del apunte
   param in Psseguro: id. del seguro relacionado al apunte
   param out mensajes   : mensajes de error
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'ctipreg:' || pctipreg || ' ,npoliza:' || pnpoliza || ', ncertif:' || pncertif
            || ', nlinea:' || pnlinea || ' ,cestado:' || pcestado || ' ,fapunte:' || pfapunte
            || ', cusuari:' || pcusuari || ' ,sseguro:' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGENSEGU.F_GET_CONSULTAAPUNTES';
   BEGIN
      cur := pac_md_agensegu.f_get_consultaapuntes(pctipreg, pnpoliza, pncertif, pnlinea,
                                                   pcestado, pfapunte, pcusuari, psseguro,
                                                   mensajes);
      RETURN cur;
   EXCEPTION
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
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_agensegu IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := ' sseguro:' || psseguro || ' , nlinea:' || pnlinea;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGENSEGU.F_GET_DATOSAPUNTE';
   BEGIN
      -- Validaciones iniciales. Algun parametro (que no sea pnlinea) debe estar informado
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_agensegu.f_get_datosapunte(psseguro, pnlinea, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datosapunte;

    /*************************************************************************
   Función F_GET_ApuntesPendientes
   Valida si existen apuntes pendientes en la agenda para el usuario a día de hoy.
      param out mensajes   : mensajes de error
          return              : Numero de apuntes pendientes
    *************************************************************************/
   FUNCTION f_get_apuntespendientes(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
   BEGIN
      RETURN pac_md_agensegu.f_get_apuntespendientes(mensajes);
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
      -- JLTS
      pmode IN VARCHAR2 DEFAULT 'POL',
      -- JLTS
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGENSEGU.f_set_datosapunte';
      vparam         VARCHAR2(5000)   -- Bug 11177.NMM.25/09/2009.
         := 'pnpoliza: ' || pnpoliza || 'psseguro: ' || psseguro || 'pnlinea: ' || pnlinea
            || 'pttitulo: ' || pttitulo || 'pttextos: ' || pttextos || 'pctipreg: '
            || pctipreg || 'pcestado: ' || pcestado || 'pfapunte: ' || pfapunte
            || 'pffinali: ' || pffinali;
      vnumerr        NUMBER(10);

   BEGIN
      IF pmodo IS NULL THEN
         vpasexec := 2;
         RAISE e_param_error;
      END IF;

	vpasexec := 3;

      vnumerr := pac_md_agensegu.f_set_datosapunte(pnpoliza, psseguro, pnlinea, pttitulo,
                                                   pttextos, pctipreg, pcestado, pfapunte,
                                                   pffinali, pmodo, pmode, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      COMMIT;
      vpasexec := 6;
      RETURN(0);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 9001768, vpasexec, vparam);
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
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
   FUNCTION f_anula_apunte(psseguro IN NUMBER, pnlinea IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
   BEGIN
      RETURN pac_md_agensegu.f_anula_apunte(psseguro, pnlinea, mensajes);
   END f_anula_apunte;
END pac_iax_agensegu;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGENSEGU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGENSEGU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGENSEGU" TO "PROGRAMADORESCSI";
