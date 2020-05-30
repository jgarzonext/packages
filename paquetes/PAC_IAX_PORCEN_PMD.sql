--------------------------------------------------------
--  DDL for Package PAC_IAX_PORCEN_PMD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_PORCEN_PMD" AS
     /******************************************************************************
        NOMBRE:       PAC_IAX_PORCEN_PMD
        COMPANIAS
      PROP脫SITO: Funciones para gestionar PMD

      REVISIONES:
      Ver        Fecha        Autor       Descripci贸n
      ---------  ----------  ---------  ------------------------------------
      1.0        11/03/2014  AGG        1. Creaci贸n del package.
   ******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
      Nueva funci贸n que se encarga de borrar un registro de ctto_tramo_producto
      return              : 0 Ok. 1 Error
     *************************************************************************/
   FUNCTION f_del_ctto_tramo_producto(
      pid IN ctto_tramo_producto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Nueva funci贸n que se encarga de borrar un registro de porcen_tramo_ctto
      return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funci贸n que se encarga de insertar un registro de ctto_tramo_producto
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_ctto_tramo_producto(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pnversio IN ctto_tramo_producto.nversio%TYPE,
      pctramo IN ctto_tramo_producto.ctramo%TYPE,
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      pctto_tramo_producto_new OUT ctto_tramo_producto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funci贸n que se encarga de recuperar un registro de la tabla ctto_tramo_producto
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_ctto_tramo_producto(
      pid IN ctto_tramo_producto.ID%TYPE,
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_ctto_tramo_producto;

   /*************************************************************************
     Nueva funci贸n que se encarga de recuperar los registros de ctto_tramo_producto
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_cttostramosproductos(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pnversio IN NUMBER,
      pnramo IN NUMBER,
      pntramo IN NUMBER,
      pnproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_ctto_tramo_producto;

    /*************************************************************************
    Funci髇 que se encarga de recuperar el porcentaje de la cuota
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_porcen_tramo_ctto;

   /*************************************************************************
     Funci髇 que se encarga de recuperar los porcentajes de las cuotas
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_porcentajes_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_porcen_tramo_ctto;

   /*************************************************************************
    Funci髇 que se encarga de insertar un registro en porcen_tramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      pporcen IN porcen_tramo_ctto.porcen%TYPE,
      pfpago IN porcen_tramo_ctto.fpago%TYPE,
      pporcen_tramo_ctto_new OUT porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci髇 que se encarga de copiar la configuraci髇 de un contrato a partir de
    la configuraci髇 de otro del mismo ramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_copiar_config_producto(
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
    Funci髇 que se encarga de copiar la configuraci髇 de un contrato a partir de
    la configuraci髇 de otro del mismo ramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_replicar_cuotas(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pctramo IN ctto_tramo_producto.ctramo%TYPE,
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_porcen_pmd;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PORCEN_PMD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PORCEN_PMD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PORCEN_PMD" TO "PROGRAMADORESCSI";
