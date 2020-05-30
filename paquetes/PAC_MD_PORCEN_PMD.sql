--------------------------------------------------------
--  DDL for Package PAC_MD_PORCEN_PMD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PORCEN_PMD" AS
      /******************************************************************************
        NOMBRE:       PAC_MD_PORCEN_PMD
        PROP¿¿SITO: Funciones para gestionar porcentajes de prima m¿nima de dep¿sito

      REVISIONES:
      Ver        Fecha        Autor       Descripci¿¿n
      ---------  ----------  ---------  ------------------------------------
      1.0        12/03/2014  AGG        1. Creaci¿¿n del package.

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Nueva funci¿¿n que se encarga de borrar un registro de ctto_tramo_producto
      return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_ctto_tramo_producto(
      pid IN ctto_tramo_producto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Nueva funci¿¿n que se encarga de borrar un registro de porcen_tramo_ctto
      return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funci¿¿n que se encarga de insertar un registro de ctto_tramo_producto
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_ctto_tramo_producto(
      pnid IN OUT ctto_tramo_producto.ID%TYPE,
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pnversio IN ctto_tramo_producto.nversio%TYPE,
      pctramo IN ctto_tramo_producto.ctramo%TYPE,
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funci¿¿n que se encarga de insertar un registro de ctto_tramo_producto
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      pporcen IN porcen_tramo_ctto.porcen%TYPE,
      pfpago IN porcen_tramo_ctto.fpago%TYPE,
      pnreplica IN VARCHAR2 DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funci¿¿n que se encarga de recuperar un registro de la tabla ctto_tramo_producto
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_ctto_tramo_producto(
      pid IN ctto_tramo_producto.ID%TYPE,
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_ctto_tramo_producto;

   /*************************************************************************
    Nueva funci¿¿n que se encarga de recuperar los registros de ctto_tramo_producto
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
    Funci¿n que se encarga de recuperar el porcentaje de la cuota
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_porcen_tramo_ctto;

   /*************************************************************************
    Funci¿n que se encarga de recuperar los porcentajes de las cuotas
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_porcentajes_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_porcen_tramo_ctto;

    /*************************************************************************
    Funci¿n que se encarga de copiar la configuraci¿n de un contrato a partir de
    la configuraci¿n de otro del mismo ramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_copiar_config_producto(
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci¿n que se encarga de replicar las cuotas para todos los productos configurados
    correspondientes a un mismo contrato, tramo y ramo
    la configuraci¿n de otro del mismo ramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_replicar_cuotas(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pctramo IN ctto_tramo_producto.ctramo%TYPE,
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_porcen_pmd;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PORCEN_PMD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PORCEN_PMD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PORCEN_PMD" TO "PROGRAMADORESCSI";
