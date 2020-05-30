--------------------------------------------------------
--  DDL for Package PAC_AGE_DATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_AGE_DATOS" AS
/******************************************************************************
   NOMBRE:       PAC_AGE_DATOS
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
      errores OUT t_ob_error)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Banco
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      pctipbanco_orig IN age_bancos.ctipbanco%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      pctipentidadaseg_orig IN age_entidadesaseg.ctipentidadaseg%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Asociación
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      errores OUT t_ob_error)
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
      errores OUT t_ob_error)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Otra referencia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Otra referencia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      ptreferencia IN age_referencias.treferencia%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER;
END pac_age_datos;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGE_DATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_DATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_DATOS" TO "PROGRAMADORESCSI";
