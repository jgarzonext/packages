--------------------------------------------------------
--  DDL for Package 
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_COMPANIAS" AS
    /******************************************************************************
   NOMBRE:       PAC_IAX_COMPANIAS
   PROPÃ“SITO: Funciones para gestionar compañias

   REVISIONES:
   Ver        Fecha        Autor       DescripciÃ³n
   ---------  ----------  ---------  ------------------------------------
   1.0        09/07/2012  JRB        1. CreaciÃ³n del package.
   2.0        03/05/2013  KBR        2. 25822 RSA003 Gestión de compañías reaseguradoras (Nota: 143771)
   4.0        08/05/2013  KBR        4. 25822: RSA003 Gestión de compañías reaseguradoras (Nota: 143961)
   5.0        05/02/2014  AGG
   6.0        31/01/2019  ACL        6. TCS_1569B: Se agrega la funcion f_get_indicador_comp.
   7.0        16/08/2019  FEPP       7. IAXIS-4823: Agregar campo tipo reasegurador  

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de borrar un registro de compañias
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_compania(pccompani IN companias.ccompani%TYPE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de insertar un registro de compañia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_compania(
      psperson IN companias.sperson%TYPE,
      pccompani IN companias.ccompani%TYPE,
      ptcompani IN companias.tcompani%TYPE,
      pcpais IN companias.cpais%TYPE,
      pctipiva IN companias.ctipiva%TYPE,
      pccomisi IN companias.ccomisi%TYPE,
      pcunespa IN companias.cunespa%TYPE,
      pffalta IN companias.ffalta%TYPE,
      pfbaja IN companias.fbaja%TYPE,
      pccontable IN companias.ccontable%TYPE,
      pctipcom IN companias.ctipcom%TYPE,
      pcafili IN companias.cafili%TYPE,
      pccasamat IN companias.ccasamat%TYPE,
      pcsuperfinan IN companias.csuperfinan%TYPE,
      pcdian IN companias.cdian%TYPE,
      pccalifi IN companias.ccalifi%TYPE,
      pcenticalifi IN companias.centicalifi%TYPE,
      pnanycalif IN companias.nanycalif%TYPE,
      pnpatrimonio IN companias.npatrimonio%TYPE,
      ppimpint IN companias.pimpint%TYPE,
      pctramtax IN companias.ctramtax%TYPE,   --25822 KBR 03052013 Se agrega campo CTRAMTAX
      pccompani_new OUT companias.ccompani%TYPE,
      pcinverfas IN companias.cinverfas%TYPE,   -- Bug 32034 - SHA - 11/08/2014
	  pcresidfisc IN par_companias_rea.cvalpar%TYPE,   --CONFCC-5
      pfresfini IN par_companias_rea.ffini%TYPE,   --CONFCC-5
      pfresffin IN par_companias_rea.ffini%TYPE,   --CONFCC-5
      pctiprea IN companias.ctiprea%TYPE,   --IAXIS-4823
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
    Nueva funciÃ³n que se encarga de recuperar la compañia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_compania(
      pccompani IN companias.ccompani%TYPE,
      psperson IN companias.sperson%TYPE,
      ptcompani IN companias.tcompani%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_companias;

/*************************************************************************
    Nueva funciÃ³n que se encarga de recuperar las compañias
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_companias(mensajes OUT t_iax_mensajes)
      RETURN t_iax_companias;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de insertar un registro de compañia calificadora
    return              : 0 Ok. -1 Error
   *************************************************************************/
   FUNCTION f_set_compania_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE,
      pccompani IN compcalificacion.ccompani%TYPE,
      pccalifi IN compcalificacion.ccalifi%TYPE,
      pprecargo IN compcalificacion.precargo%TYPE,
      pfefecto in compcalificacion.fefecto%type,
      pofc_repres in compcalificacion.ofc_repres%type,
      pcestado_califi in compcalificacion.cestado_califi%type,
      pfinscrip in compcalificacion.finscrip%type,
      panyoactualiz in compcalificacion.anyoactualiz%type,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de recuperar las compañias calificadoras
    o solo una.
    return              : Referencia al cursor con las compañías
   *************************************************************************/
   FUNCTION f_get_companias_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de borrar un registro de compañia calificadora
    return              : 0 Ok. -1 Error
   *************************************************************************/
   FUNCTION f_del_compania_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE,
      pfefecto IN compcalificacion.fefecto%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de validar si existen al menos dos calificaciones
    para la compañía
    return              : X nro de calificaciones. -1 Error
   *************************************************************************/
   FUNCTION f_val_companias_calif(
      psperson IN compcalificacion.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función que se encarga de recuperar el indicador de la compañía
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_indicador_cia(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pffinivig IN indicadores_cias.finivig%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_indicadores_cias;

   /*************************************************************************
     Función que se encarga de recuperar los indicadores de las compañias
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_indicadores_cias(
      pccompani IN indicadores_cias.ccompani%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_indicadores_cias;

   /*************************************************************************
    Función que se encarga de insertar un registro en indicadores de compañia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_indicador_cia(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pnvalor IN indicadores_cias.nvalor%TYPE,
      pfinivig IN indicadores_cias.finivig%TYPE,
      pffinvig IN indicadores_cias.ffinvig%TYPE,
      pcenviosap IN indicadores_cias.cenviosap%TYPE,
      pcaplica IN indicadores_cias.caplica%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_tindicadorescia
      Recupera los tipos de indicadores para las compañias
      param out mensajes : missatges d'error
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_tindicadorescia(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Ini TCS_1569B - ACL - 31/01/2019
	/*************************************************************************
    Funci¨®n que se encarga de recuperar el indicador de la compa?¨ªa
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_indicador_comp(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pffinivig IN indicadores_cias.finivig%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_indicadores_cias;
	  -- Fin TCS_1569B - ACL - 31/01/2019	  
	END pac_iax_companias;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMPANIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMPANIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMPANIAS" TO "PROGRAMADORESCSI";
