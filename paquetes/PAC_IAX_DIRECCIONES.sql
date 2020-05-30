--------------------------------------------------------
--  DDL for Package PAC_IAX_DIRECCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_DIRECCIONES" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_DIRECCIONES
      PROPÓSITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor   Descripción
     ---------  ----------  ------   ------------------------------------
      1.0        29/02/2012   JMB     1. Creación del package.

   ******************************************************************************/
   vfincas        t_iax_dir_fincas;

   FUNCTION f_get_tiposvias(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_busquedadirdirecciones(
      ptbusqueda IN NUMBER,
      pcpostal IN VARCHAR2,
      pctipvia IN NUMBER,
      ptnomvia IN VARCHAR2,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pcdesde IN VARCHAR2,
      pchasta IN VARCHAR2,
      ptipfinca IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcmunicipi IN NUMBER,
      pclocalidad IN NUMBER,
      paliasfinca IN VARCHAR2,
      pine IN VARCHAR2,
      pescalera IN NUMBER,
      ppiso IN NUMBER,
      ppuerta IN VARCHAR2,
      preferencia IN VARCHAR2,
      pidfinca IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_fincas;

   FUNCTION f_get_portales(pidfinca IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_portales;

    /*************************************************************************
     Retorna los domicilios de un portal
     param in pidfinca   : Codi de la finca
     param in pidportal  : Codi del portal
     param in mensajes   : Mensajes de error
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_departamentos(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_domicilios;

    /*************************************************************************
     Retorna una finca
     param in pidfinca   : Codi de la finca
     param in mensajes   : Mensajes de error
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_finca(pidfinca IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Retorna si existe un domicilio
    param in pidfinca   : Codi de finca
    param in pidportal  : Codi del portal
    param in piddomici  : Codi del domicilio
    param in pidgeodir  : Codi geodireccion
    param in pcescale   : Codi escalera
    param in pcplanta   : Codi de planta
    param in pcpuerta   : Codi puerta
    param in mensajes   : Mensajes de error
    return              :  0 - No existe , 1 - Existe

    Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_existe_domi(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      piddomici IN NUMBER,
      pidgeodir IN NUMBER,
      pcescale IN VARCHAR2,
      pcplanta IN VARCHAR2,
      pcpuerta IN VARCHAR2,
      vexiste OUT NUMBER,
      viddomici OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
     Guarda un domicilio
     param in pidfinca
     param in pidportal
     param in pidgeodir
     param in pcescale
     param in pcplanta
     param in pcpuerta
     param in pccatast
     param in pnm2cons
     param in pctipdpt
     param in ptalias
     param in pcnoaseg
     param in ptnoaseg
     return  0 - Ok,1 - KO

     Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_domici(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pidgeodir IN NUMBER,
      pcescale IN VARCHAR2,
      pcplanta IN VARCHAR2,
      pcpuerta IN VARCHAR2,
      pccatast IN VARCHAR2,
      pnm2cons IN NUMBER,
      pctipdpt IN NUMBER,
      ptalias IN VARCHAR2,
      pcnoaseg IN NUMBER,
      ptnoaseg IN NUMBER,
      piddomiciout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
     Retorna el domicilio solicitado
     param in piddomici: Codi del domicilio
     param in mensajes   : Mensajes de error
     return              : Domicilio

     Bug 20893/111636 - 18/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_departamento(
      piddomici IN NUMBER,
      pdomici OUT ob_iax_dir_domicilios,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
     Devuelve un portal
     param in pidfinca
     param in pidportal
     return  portal

     Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_portal(pidfinca IN NUMBER, pidportal IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_dir_portales;

   /*************************************************************************
     Guarda en BBDD las fincas
     param in pidfinca
     param in pidportal
     return  0 - OK , 1 - KO

     Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_fincasbd(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Retorna las localidades
     param in pcprovin   : Codi de la provincia
     param in pcpoblac  : Codi de la poblaci�n
     return              : Listado de localidades

     Bug 20893/111636 - 26/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_localidades(
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Retorna si existe un domicilio
    param in pidlocal  : Codi de localidad
    param out ptlocali  : Descripcion de la localidad
    return              :  0 - OK,  Codi error - KO

    Bug 20893/111636 - 26/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_localidad(
      pidlocal IN NUMBER,
      ptlocali OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera un portal
      param in pidfinca : identificador de la finca
      param in pidportal : identificador del portal
      param out portal
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_busquedaportal(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pportal OUT ob_iax_dir_portales,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Recupera un portal de memoria
       param in pidfinca : identificador de la finca
       param out mensajes : mensajes de error
       return             : finca
    *************************************************************************/
   FUNCTION f_get_fincamen(pidfinca IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_dir_fincas;

   /*************************************************************************
       Asignamos un nuevo portal a la finca
       param in pidfinca : identificador de la finca
       param out mensajes : mensajes de error
       return             : finca
    *************************************************************************/
   FUNCTION f_set_nuevoportal(
      pidfinca IN NUMBER,
      ptbusqueda IN NUMBER,
      pcpostal IN VARCHAR2,
      pctipvia IN NUMBER,
      ptnomvia IN VARCHAR2,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pcdesde IN VARCHAR2,
      pchasta IN VARCHAR2,
      ptipfinca IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcmunicipi IN NUMBER,
      pclocalidad IN NUMBER,
      paliasfinca IN VARCHAR2,
      pine IN VARCHAR2,
      pescalera IN NUMBER,
      ppiso IN NUMBER,
      ppuerta IN VARCHAR2,
      preferencia IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_fincas;

   /*************************************************************************
        Recupera les fincas de memoria
        param out mensajes : mensajes de error
        return             : finca
     *************************************************************************/
   FUNCTION f_get_fincasmen(mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_fincas;
END pac_iax_direcciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DIRECCIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DIRECCIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DIRECCIONES" TO "PROGRAMADORESCSI";
