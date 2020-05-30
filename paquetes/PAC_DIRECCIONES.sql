--------------------------------------------------------
--  DDL for Package PAC_DIRECCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DIRECCIONES" AS
   /******************************************************************************
      NOMBRE:       PAC_DIRECCIONES
      PROPÓSITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        19/03/2012   JMB                1. Creación del package.

   ******************************************************************************/
   FUNCTION f_get_busquedadirdirecciones(
      ptbusqueda IN NUMBER,
      pcpostal IN VARCHAR2,
      pctipvia IN NUMBER,
      pttipvia IN VARCHAR2,
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
      pidfinca IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_busquedaportales(pidfinca IN NUMBER, pidportal IN NUMBER)
      RETURN VARCHAR2;

    /*************************************************************************
     Retorna los domicilios de un portal
     param in pidfinca   : Codi de la finca
     param in pidportal  : Codi del portal
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_departamentos(pidfinca IN NUMBER, pidportal IN NUMBER, piddomici IN NUMBER)
      RETURN VARCHAR2;

    /*************************************************************************
     Retorna una finca
     param in pidfinca   : Codi de la finca
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_finca(pidfinca IN NUMBER)
      RETURN VARCHAR2;

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
      ptnoaseg IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
     Guarda una finca
     param in pidfinca
     param in pidlocal
     param in pccatast
     param in pctipfin
     param in pnanycon
     param in ptfinca
     param in pcnoaseg
     param in ptnoaseg
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 17/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_finca(
      pidfinca IN NUMBER,
      pidlocal IN NUMBER,
      pccatast IN VARCHAR2,
      pctipfin IN NUMBER,
      pnanycon IN NUMBER,
      ptfinca IN VARCHAR2,
      pcnoaseg IN NUMBER,
      ptnoaseg IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
     Guarda un portal
     param in pidfinca
     param in pidportal
     param in pcprincip
     param in pcnoaseg
     param in ptnoaseg
     param in pnanycon
     param in pndepart
     param in pnplsota
     param in pnplalto
     param in pnascens
     param in pnescale
     param in pnm2vivi
     param in pnm2come
     param in pnm2gara
     param in pnm2jard
     param in pnm2cons
     param in pnm2suel
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 17/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_portal(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pcprincip IN NUMBER,
      pcnoaseg IN NUMBER,
      ptnoaseg IN NUMBER,
      pnanycon IN NUMBER,
      pndepart IN NUMBER,
      pnplsota IN NUMBER,
      pnplalto IN NUMBER,
      pnascens IN NUMBER,
      pnescale IN NUMBER,
      pnm2vivi IN NUMBER,
      pnm2come IN NUMBER,
      pnm2gara IN NUMBER,
      pnm2jard IN NUMBER,
      pnm2cons IN NUMBER,
      pnm2suel IN NUMBER)
      RETURN NUMBER;

     /*************************************************************************
     Guarda en portaldirecciones
     param in pidfinca
     param in pidportal
     param in pidgeodir
     param in pcprincip
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 17/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_portalesdirecciones(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pidgeodir IN NUMBER,
      pcprincip IN NUMBER)
      RETURN NUMBER;

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
      viddomici IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Retorna si existe un domicilio
    param in pidlocal  : Codi de localidad
    param out ptlocali  : Descripcion de la localidad
    return              :  0 - OK,  Codi error - KO

    Bug 20893/111636 - 20/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_localidad(pidlocal IN NUMBER, ptlocali OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Retorna las siglas de una calle
    param in pctipiva  : Codi de tipo de via
    param out pcsiglas : Siglas
    return              :  0 - OK,  Codi error - KO

    Bug 20893/111636 - 23/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_siglas(pctipiva IN NUMBER, pcsiglas OUT VARCHAR2)
      RETURN NUMBER;

     /*************************************************************************
     Guarda en geodirecciones
     param in pidgeodir
     param in pidcalle
     param in pctipnum
     param in pndesde
     param in ptdesde
     param in pnhasta
     param in pthasta
     param in pcpostal
     param in pcgeox
     param in pcgeoy
     param in pcgeonum
     param in pcgeoid
     param in pcvaldir
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 24/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_dirgeodirecciones(
      pidgeodir IN NUMBER,
      pidcalle IN NUMBER,
      pctipnum IN NUMBER,
      pndesde IN NUMBER,
      ptdesde IN VARCHAR2,
      pnhasta IN NUMBER,
      pthasta IN VARCHAR2,
      pcpostal IN VARCHAR2,
      pcgeox IN VARCHAR2,
      pcgeoy IN VARCHAR2,
      pcgeonum IN NUMBER,
      pcgeoid IN VARCHAR2,
      pcvaldir IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
     Guarda en dir_calles
     param in pidcalle
     param in pidlocal
     param in ptcalle
     param in pctipvia
     param in pcfuente
     param in ptcalbus
     param in pcvalcal
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 24/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_dircalles(
      pidcalle IN NUMBER,
      pidlocal IN NUMBER,
      ptcalle IN VARCHAR2,
      pctipvia IN NUMBER,
      pcfuente IN NUMBER,
      ptcalbus IN VARCHAR2,
      pcvalcal IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
     Retorna las localidades
     param in pcprovin   : Codi de la provincia
     param in pcpoblac  : Codi de la poblaci�n
     return              : Consulta a ejecutar

     Bug 20893/111636 - 26/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_localidades(pcprovin IN NUMBER, pcpoblac IN NUMBER)
      RETURN VARCHAR2;

    /*************************************************************************
     Retorna un portal
     return              : Consulta a ejecutar

     Bug 20893/111636 - 17/05/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_busquedaportal(
      ptbusqueda IN NUMBER,
      pcpostal IN VARCHAR2,
      pctipvia IN NUMBER,
      pttipvia IN VARCHAR2,
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
      preferencia IN VARCHAR2)
      RETURN VARCHAR2;
END pac_direcciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_DIRECCIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DIRECCIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DIRECCIONES" TO "PROGRAMADORESCSI";
