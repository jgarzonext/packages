--------------------------------------------------------
--  DDL for Package PAC_MD_COMPANIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_COMPANIAS" AS
      /******************************************************************************
        NOMBRE:       PAC_MD_COMPANIAS
        PROPOSITO: Funciones para gestionar compania

      REVISIONES:
      Ver        Fecha        Autor       Descripcion
      ---------  ----------  ---------  ------------------------------------
      1.0        09/07/2012  JRB        1. Creacion del package.
      2.0        08/08/2012  AVT        2. 22076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
      3.0        03/05/2013  KBR        3. 25822: RSA003 Gestion de companias reaseguradoras (Nota: 143771)
      4.0        07/05/2013  KBR        4. 25822: RSA003 Gestion de companias reaseguradoras (Nota: 143961)
      5.0        05/02/2014  AGG
      6.0        31/01/2019  ACL        6. TCS_1569B: Se agregan las funciones f_set_indicador_comp y f_get_indicador_comp.
      7.0        16/08/2019  FEPP       7. IAXIS-4823: Agregar campo tipo reasegurador  

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
    Nueva funcion que se encarga de borrar un registro de companias
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_compania(
      pccompani IN companias.ccompani%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de insertar un registro de compania
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_compania(
      psperson IN companias.sperson%TYPE,
      pccompani IN OUT companias.ccompani%TYPE,
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
      pctramtax IN companias.ctramtax%TYPE,   --25822 KBR Se agrega el parametro CTRAMTAX 03052013
      pcinverfas IN companias.cinverfas%TYPE,   -- Bug 32034 - SHA - 11/08/2014
	  pcresidfisc IN par_companias_rea.cvalpar%TYPE DEFAULT 0,   --CONFCC-5
      pfresfini IN par_companias_rea.ffini%TYPE DEFAULT NULL,   --CONFCC-5
      pfresffin IN par_companias_rea.ffini%TYPE DEFAULT NULL,   --CONFCC-5
      pctiprea IN companias.ctiprea%TYPE,   --IAXIS-4823
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de recuperar la compania
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_compania(
      pccompani IN companias.ccompani%TYPE,
      psperson IN companias.sperson%TYPE,
      ptcompani IN companias.tcompani%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_companias;

   /*************************************************************************
    Nueva funcion que se encarga de recuperar las companias
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_companias(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_companias;

   /*************************************************************************
    Nueva funcion que se encarga de insertar un registro de compania calificadora
    return              : 0 Ok. -1 Error
   *************************************************************************/
   FUNCTION f_set_compania_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE,
      pccompani IN compcalificacion.ccompani%TYPE,
      pccalifi IN compcalificacion.ccalifi%TYPE,
      pfefecto IN compcalificacion.fefecto%TYPE,
      pfvenci IN compcalificacion.fvenci%TYPE,
      pprecargo IN compcalificacion.precargo%TYPE,
      pfalta IN compcalificacion.falta%TYPE,
      pcusualta IN compcalificacion.cusualta%TYPE,
      pfultmod IN compcalificacion.fultmod%TYPE,
      pcusumod in compcalificacion.cusumod%type,
      pofc_repres in compcalificacion.ofc_repres%type,
      pcestado_califi in compcalificacion.cestado_califi%type,
      pfinscrip in compcalificacion.finscrip%type,
      panyoactualiz in compcalificacion.anyoactualiz%type,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de recuperar las companias calificadoras
    o solo una
    return              : Referencia al cursor con las companias
   *************************************************************************/
   FUNCTION f_get_companias_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Nueva funcion que se encarga de borrar un registro de compania calificadora
    return              : 0 Ok. -1 Error
   *************************************************************************/
   FUNCTION f_del_compania_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE,
      pfefecto IN compcalificacion.fefecto%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de validar si existen al menos dos calificaciones
    para la compania
    return              : X nro de calificaciones. -1 Error
   *************************************************************************/
   FUNCTION f_val_companias_calif(
      psperson IN compcalificacion.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funcion que se encarga de recuperar el indicador de la compania
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_indicador_cia(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pffinivig IN indicadores_cias.finivig%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_indicadores_cias;

   /*************************************************************************
     Funcion que se encarga de recuperar los indicadores de las companias
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_indicadores_cias(
      pccompani IN indicadores_cias.ccompani%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_indicadores_cias;

   /*************************************************************************
    Funcion que se encarga de insertar un registro en indicadores de companias
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_tindicadorescia
      Recupera los tipos de indicadores para las companias
      param out mensajes : missatges d'error
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_tindicadorescia(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

	-- Ini TCS_1569B - ACL - 31/01/2019
 /*************************************************************************
    Funcion que se encarga de insertar un registro en indicadores de compania
    return              : 0 Ok. 1 Error
   *************************************************************************/
      FUNCTION f_set_indicador_comp(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipcom IN companias.ctipcom%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
   /*************************************************************************
     Funcion que se encarga de recuperar los indicadores de las companias
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_indicador_comp(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pffinivig IN indicadores_cias.finivig%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_indicadores_cias;
	  -- Fin TCS_1569B - ACL - 31/01/2019
END pac_md_companias;
/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COMPANIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMPANIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMPANIAS" TO "PROGRAMADORESCSI";
