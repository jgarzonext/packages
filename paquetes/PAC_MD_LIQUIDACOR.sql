--------------------------------------------------------
--  DDL for Package PAC_MD_LIQUIDACOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_LIQUIDACOR" AS
/******************************************************************************
   NOMBRE:       PAC_MD_LIQUIDACOR
   PROPÓSITO:    Contiene las funciones para la liquidación de comisiones de Correduria

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/11/2010   XPL                1. Creación del package. Bug 16310
******************************************************************************/
   /*************************************************************************
       Función que nos creará una nueva liquidación, pasándole el mes, año y descripción.
       Nos guardará en persistencia la liquidación inicializada
       param in  p_mes       : Mes de la liquidación
       param in  p_anyo      : Año de la liquidación
       param in  p_tliquida  : Observaciones
       param in out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
        25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_inicializa_liquidacion(
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_ccompani IN NUMBER,
      p_finiliq IN DATE,
      p_ffinliq IN DATE,
      p_importe IN NUMBER,
      p_tliquida IN VARCHAR2,
      pt_liquida OUT t_iax_liquidacion,
      p_sproces OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
       Función que modificara una  liquidación, pasándole el mes, año y descripción.
       Nos guardará en persistencia la liquidación inicializada
       param in  p_mes       : Mes de la liquidación
       param in  p_anyo      : Año de la liquidación
       param in  p_tliquida  : Observaciones
       param in out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
        25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_modifica_liquidacion(
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_ccompani IN NUMBER,
      p_finiliq IN DATE,
      p_ffinliq IN DATE,
      p_importe IN NUMBER,
      p_tliquida IN VARCHAR2,
      p_sproliq IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Función que cargará el  objecto liquidacion con sus movimientos y recibos buscados en la bd
      param in  P_cempres   : Empresa
      param in  P_sproduc   : Producto
      param in  p_sproliq   : Proceso liquidacion
      param in  p_mes       : Mes de la liquidación
      param in  p_anyo      : Año de la liquidación
      param in  p_cestado   : Estado de la liquidación(abierto, cerrado..)
      param in  P_npoliza   : Póliza
      param in  P_npolcia   : Póliza Compañia
      param in  p_nrecibo   : Recibo
      param in  p_creccia   : Recibo Compañia
      param in p_ccompani   : Compañia del seguro
      param in  P_cagente   : Agente
      param in  P_femiini   : Fecha inicio emisión
      param in  P_femifin   : Fecha fin emisión
      param in  P_fefeini   : Fecha inicio efecto
      param in  P_fefefin   : Fecha fin efecto
      param in  P_fcobini   : Fecha inicio cobro
      param in  P_fcobfin   : Fecha fin cobro
      param in out mensajes    : Mensajes de error
      param out pt_liquida  : Colección liquidación
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquida(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_sproliq IN NUMBER,
      p_nmes IN NUMBER,
      p_anyo IN NUMBER,
      p_cestado IN NUMBER,
      p_npoliza IN NUMBER,
      p_cpolcia IN VARCHAR2,
      p_nrecibo IN NUMBER,
      p_creccia IN VARCHAR2,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_femiini IN DATE,
      p_femifin IN DATE,
      p_fefeini IN DATE,
      p_fefefin IN DATE,
      p_fcobini IN DATE,
      p_fcobfin IN DATE,
      pt_liquida OUT t_iax_liquidacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      Función que cargará el  objecto liquidacion con sus movimientos buscados en la bd
      param in  P_cempres   : Empresa
      param in  P_sproduc   : Producto
      param in  p_sproliq   : Proceso liquidacion
      param in  p_mes       : Mes de la liquidación
      param in  p_anyo      : Año de la liquidación
      param in  p_cestado   : Estado de la liquidación(abierto, cerrado..)
      param in  P_npoliza   : Póliza
      param in  P_npolcia   : Póliza Compañia
      param in  p_nrecibo   : Recibo
      param in  p_creccia   : Recibo Compañia
      param in p_ccompani   : Compañia del seguro
      param in  P_cagente   : Agente
      param in  P_femiini   : Fecha inicio emisión
      param in  P_femifin   : Fecha fin emisión
      param in  P_fefeini   : Fecha inicio efecto
      param in  P_fefefin   : Fecha fin efecto
      param in  P_fcobini   : Fecha inicio cobro
      param in  P_fcobfin   : Fecha fin cobro
      param in out mensajes    : Mensajes de error
      param out pt_liquida  : Colección liquidación
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquida_cab(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_sproliq IN NUMBER,
      p_nmes IN NUMBER,
      p_anyo IN NUMBER,
      p_cestado IN NUMBER,
      p_npoliza IN NUMBER,
      p_cpolcia IN VARCHAR2,
      p_nrecibo IN NUMBER,
      p_creccia IN VARCHAR2,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_femiini IN DATE,
      p_femifin IN DATE,
      p_fefeini IN DATE,
      p_fefefin IN DATE,
      p_fcobini IN DATE,
      p_fcobfin IN DATE,
      pt_liquida OUT t_iax_liquidacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Función que devolverá la colección de movimientos de un proceso de liquidación concreto
      param in  p_sproliq   : Proceso liquidacion
      param in  p_nmovliq   : Movimiento liquidacion
      param in  p_cestliq   : Estado de la liquidación(abierto, cerrado..)
      param in  p_cmonliq   : Moneda liquidacion
      param in out mensajes    : Mensajes de error
      param out pt_movliquida  : Colección Movimientos
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_movliquida(
      p_sproliq IN NUMBER,
      p_nmovliq IN NUMBER,
      p_cestliq IN NUMBER,
      p_cmonliq IN VARCHAR2,
      pt_movliquida OUT t_iax_liquida_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
      Función que cargará los recibos de una liquidacion
      param in  p_sproliq   : Proceso liquidacion
      param in  p_nrecibo   : Movimiento liquidacion
      param in  p_ccompani   : Estado de la liquidación(abierto, cerrado..)
      param in  p_cagente   : Agente
      param in  p_cmonseg   : Moneda seguro
      param in  p_cmonliq   : Moneda liquidacion
      param in  p_cgescob   : ges cob
      param in  p_cramo   : ramo
      param in  p_sproduc   : producto
      param in  p_fefectoini   : fecha efecto inicial
      param in  p_fefectofin   : fecha efecto fin
      param out pt_recliquida : coleccion de recibos
      param in out mensajes    : Mensajes de error
      param out pt_recliquida  : Colección de recibos
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_recliquida(
      p_sproliq IN NUMBER,
      p_nrecibo IN NUMBER,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_cmonseg IN VARCHAR2,
      p_cmonliq IN VARCHAR2,
      p_cgescob IN NUMBER,
      p_cramo IN NUMBER,
      p_sproduc IN NUMBER,
      p_fefectoini IN DATE,
      p_fefectofin IN DATE,
      pt_recliquida OUT t_iax_liquida_rec,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
      Función que cargará los recibos propuestos para liquidar o los que filtremos por pantalla
      param in  p_sproliq   : Proceso liquidacion
      param in  p_nrecibo   : Movimiento liquidacion
      param in  p_ccompani   : Estado de la liquidación(abierto, cerrado..)
      param in  p_cagente   : Agente
      param in  p_cmonseg   : Moneda seguro
      param in  p_cmonliq   : Moneda liquidacion
      param in  p_cgescob   : ges cob
      param in  p_cramo   : ramo
      param in  p_sproduc   : producto
      param in  p_fefectoini   : fecha efecto inicial
      param in  p_fefectofin   : fecha efecto fin
      param out pt_recliquida : coleccion de recibos
      param in out mensajes    : Mensajes de error
      param out pt_recliquida  : Colección de recibos
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_recibos_propuestos(
      p_sproliq IN NUMBER,
      p_nrecibo IN NUMBER,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_cmonseg IN VARCHAR2,
      p_cmonliq IN VARCHAR2,
      p_cgescob IN NUMBER,
      p_cramo IN NUMBER,
      p_sproduc IN VARCHAR2,
      p_fefectoini IN DATE,
      p_fefectofin IN DATE,
      pt_recliquida OUT t_iax_liquida_rec,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que insertará los recibos que forman la liquidación
        param in  p_selrecliq : Objeto OB_IAX_LIQUIDACION
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
        25/11/2010#XPL#16310
    *************************************************************************/
   FUNCTION f_set_recliqui(p_selrecliq IN ob_iax_liquidacion, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función nos devuelve las liquidaciones en las cuales se encuentra el recibo
        param in  P_nrecibo   : Nº de recibo
        param out mensajes    : Mensajes de error
        return                : 0.-    OK
                                1.-    KO
        03/06/2011#XPL#0018732
     *************************************************************************/
   FUNCTION f_get_liquida_rec(
      p_nrecibo IN NUMBER,
      p_liquidarec OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_liquidacor;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACOR" TO "PROGRAMADORESCSI";
