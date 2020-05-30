--------------------------------------------------------
--  DDL for Package PAC_MD_DIRECCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_DIRECCIONES" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_DIRECCIONES
      PROPÃ“SITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor             DescripciÃ³n
      ---------  ----------  ---------------  ------------------------------------
      1.0        19/03/2012   JMB                1. CreaciÃ³n del package.

   ******************************************************************************/
   FUNCTION f_get_tiposvias(mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_dir_fincas;

   /*************************************************************************
      Recupera el listado de portales de acuerdo a la direccion
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_busquedaportales(pidfinca IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera un portal
      param in pidfinca : identificador de la finca
      param in pidportal : identificador del portal
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_busquedaportal(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pportal OUT ob_iax_dir_portales,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
     Retorna una finca
     param in piddomici   : Codi del domicilio
     param in mensajes   : Mensajes de error
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_finca(pidfinca IN NUMBER, mensajes IN OUT t_iax_mensajes)
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
      vexiste IN OUT NUMBER,
      viddomici IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
     Guarda una finca
     param in finca
     return  0 - Ok,1 - KO

     Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_finca(pfinca IN ob_iax_dir_fincas, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
     Guarda un domicilio
     param in piddomici
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
      piddomici IN NUMBER,
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
      pvdomici IN OUT ob_iax_dir_domicilios,
      mensajes IN OUT t_iax_mensajes)
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
      pdomici IN OUT ob_iax_dir_domicilios,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
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
      ptlocali IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
     Retorna un portal
     return              : Consulta a ejecutar

     Bug 20893/111636 - 17/05/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_portal(
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
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_dir_portales;
END pac_md_direcciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DIRECCIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DIRECCIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DIRECCIONES" TO "PROGRAMADORESCSI";
