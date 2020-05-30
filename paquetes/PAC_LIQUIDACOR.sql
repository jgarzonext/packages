--------------------------------------------------------
--  DDL for Package PAC_LIQUIDACOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LIQUIDACOR" IS
/******************************************************************************
   NOMBRE:       PAC_MD_LIQUIDACOR
   PROPÓSITO:    Contiene las funciones para la liquidación de comisiones de Correduria

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/11/2010   XPL                1. Creación del package. Bug 16310
******************************************************************************/

   /*************************************************************************
          Función que devolverá la query con los sproliq de la busqueda realizada
          param in p_cempres   : código de la empresa
          param in p_sproduc   : Producto
          param in p_npoliza   : Póliza
          param in p_cagente   : Agente
          param in p_femiini   : Fecha inicio emisión.
          param in p_femifin   : Fecha fin emisión.
          param in p_fefeini   : Fecha inicio efecto
          param in p_fefefin   : Fecha fin efecto
          param in p_fcobini   : Fecha inicio cobro
          param in p_fcobfin   : Fecha fin cobro.
          param in p_idioma    : Idioma
          return out psquery   : varchar2
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
      p_idioma IN NUMBER)
      RETURN CLOB;

   /*************************************************************************
          Función que devolverá la query con la información de la cabecera de la liquidacion(ob_iax_liquidacion)
          param in p_cempres   : código de la empresa
          param in p_sproliq   : código de la liquidación
          param in p_fliquida   : Fecha de la liquidacion
          param in p_idioma    : Idioma
          return out psquery   : CLOB
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_cabecera_liquida(
      p_cempres IN NUMBER,
      p_ccompani IN NUMBER,
      p_finiliq IN DATE,
      p_ffinliq IN DATE,
      p_sproliq IN NUMBER,
      p_fliquida IN DATE,
      p_idioma IN NUMBER)
      RETURN CLOB;

   /*************************************************************************
          Función que devolverá la query con la información del/los movimientos de la liquidacion(ob_iax_liquida_mov)
          param in p_sproliq   : código de la liquidación
          param in p_nmovliq   : Movimiento de la liquidacion
          param in p_cestliq   : Estado de la liquidacion
          param in p_cmonliq   : Moneda de la liquidacion
          param in p_idioma    : Idioma
          return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquidamov(
      p_sproliq IN NUMBER,
      p_nmovliq IN NUMBER,
      p_cestliq IN NUMBER,
      p_cmonliq IN VARCHAR2,
      p_idioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
          Función que devolverá la query con la información del/los recibos de la liquidacion(ob_iax_liquida_rec)
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
          return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquidarec(
      p_cempres IN NUMBER,
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
      p_idioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
          Función que nos comprueba si existen liquidaciones para un mes y año en concreto
      param in  p_mes   : Mes liquidacion
      param in  p_anyo   : Año liquidacion
      param in  p_ccompani: compañia que se liquida
          return NUMBER : 1/0
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_valida_propuesta(
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_ccompani IN NUMBER,
      psproces IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      Función que devolverá la query con la información del/los recibos de la liquidacion(ob_iax_liquida_rec)
      param in  p_cempres   : Empresa
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
      param in  p_mes   : Mes liquidacion
      param in  p_anyo   : Año liquidacion
      param in  p_idioma   : Idioma
      return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_recibos_propuestos(
      p_cempres IN NUMBER,
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
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_idioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Función que nos grabará en la tabla adm_liquida
      param in  p_sproliq   : Proceso liquidacion
      param in  p_cempres   : Empresa
      param in  pfliquida   : Fecha liquidación
      param in  ptliquida   : Observacion liquidación
      return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_set_liquida(
      psproliq IN NUMBER,
      pccompani IN NUMBER,
      pfiniliq IN DATE,
      pffinliq IN DATE,
      pcempres IN NUMBER,
      pfliquida IN DATE,
      pimport IN NUMBER,
      ptliquida IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Función que nos grabará en la tabla adm_liquida_mov
      param in  p_sproliq   : Proceso liquidacion
      param in  pnmovliq   : Movimiento liquidacion
      param in  pcestliq   : Estado liquidación
      param in  pcmonliq   : Moneda liquidación
      param in  pitotliq   : Importe liquidación
      return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_set_movliquida(
      psproliq IN NUMBER,
      pccompani IN NUMBER,
      pnmovliq IN NUMBER,
      pcestliq IN NUMBER,
      pcmonliq IN VARCHAR2,
      pitotliq IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Función que nos grabará en la tabla adm_liquida_rec
      param in  p_sproliq   : Proceso liquidacion
      param in  pnrecibo   : Recibo liquidacion
      param in  pccompani   : Compañia liquidación
      param in  pcagente   : Agente liquidación
      param in  pitotalr   : Importe total recibo
      param in  picomisi   : Comision liquidación
      param in  piretenc   : Importe retencion liquidación
      param in  piliquida   : Importe liquidación
      param in  pcmonliq   : Moneda liquidación
      param in  piliquidaliq   : Importe (moneda)liquidación
      param in  pfcambio   : Importe liquidación(moneda)
      param in  pcgescob   : codigo ges cob
      return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_set_recliquida(
      psproliq IN NUMBER,
      pnrecibo IN NUMBER,
      pccompani IN NUMBER,
      pcagente IN NUMBER,
      pcmonseg IN VARCHAR2,
      pitotalr IN NUMBER,
      picomisi IN NUMBER,
      piretenc IN NUMBER,
      piprinet IN NUMBER,
      piliquida IN NUMBER,
      pcmonliq IN VARCHAR2,
      piliquidaliq IN NUMBER,
      pfcambio IN DATE,
      pcgescob IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Función que nos eliminar un recibo de la liquidación
      param in  p_sproliq   : Proceso liquidacion
      param in  pnrecibo   : Recibo liquidacion

            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_del_recliquida(psproliq IN NUMBER, pccompani IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
          Función nos devuelve las liquidaciones en las cuales se encuentra el recibo
          param in  P_nrecibo   : Nº de recibo
          param out mensajes    : Mensajes de error
          return                : 0.-    OK
                                  1.-    KO
          03/06/2011#XPL#0018732
       *************************************************************************/
   FUNCTION f_get_liquida_rec(pnrecibo IN NUMBER, p_idioma IN NUMBER, vquery OUT VARCHAR2)
      RETURN NUMBER;
END pac_liquidacor;

/

  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDACOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDACOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDACOR" TO "PROGRAMADORESCSI";
