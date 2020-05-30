--------------------------------------------------------
--  DDL for Package PAC_IAX_AGE_DATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_AGE_DATOS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_AGE_DATOS
   PROPÓSITO: Funciones para gestionar Más datos de agentes

   REVISIONES:
   Ver        Fecha        Autor       Descripción
   ---------  ----------  ---------  ------------------------------------
   1.0        13/03/2012  MDS        1. Creación del package.

******************************************************************************/

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Banco
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Banco
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      pctipbanco_orig IN age_bancos.ctipbanco%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      pctipentidadaseg_orig IN age_entidadesaseg.ctipentidadaseg%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Asociación
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Asociación
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      pnumcolegiado IN age_asociaciones.numcolegiado%TYPE,
      pctipasociacion_orig IN age_asociaciones.ctipasociacion%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Otra referencia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Otra referencia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      ptreferencia IN age_referencias.treferencia%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
    Nueva función que se encarga de recuperar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      poentidadaseg OUT ob_iax_age_entidadaseg,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
    Nueva función que se encarga de recuperar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      pnumcolegiado IN age_asociaciones.numcolegiado%TYPE,
      poasociacion OUT ob_iax_age_asociacion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
    Nueva función que se encarga de recuperar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      pobanco OUT ob_iax_age_banco,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
    Nueva función que se encarga de recuperar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      ptreferencia IN age_referencias.treferencia%TYPE,
      poreferencia OUT ob_iax_age_referencia,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de recuperar los registros de la tabla prod_usu
    return              : t_iax_prod_usu
   *************************************************************************/
   FUNCTION f_get_prod_usu(
      pcagente IN prod_usu.cdelega%TYPE,
      pcramo IN prod_usu.cramo%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_prod_usu;

   /*************************************************************************
     Nueva función que se encarga del mantenimiento de los registros de la tabla prod_usu
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_set_prod_usu(
      pseleccionado IN NUMBER,
      pcdelega IN prod_usu.cdelega%TYPE,
      pcramo IN prod_usu.cramo%TYPE,
      pcmodali IN prod_usu.cmodali%TYPE,
      pctipseg IN prod_usu.ctipseg%TYPE,
      pccolect IN prod_usu.ccolect%TYPE,
      pemitir IN prod_usu.emitir%TYPE,
      paccesible IN prod_usu.accesible%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_age_datos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_DATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_DATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_DATOS" TO "PROGRAMADORESCSI";
