--------------------------------------------------------
--  DDL for Package PAC_MD_COA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_COA" IS
/******************************************************************************
 NAME: AXIS_D71.pac_md_coa
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/05/2012                    1. Created this package body.
   2.0        29/05/2012    AVT             2. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
******************************************************************************/

   /*************************************************************************
   Función que devuelve el detalle por poliza de las cuentas técnicas de coaseguro
   *************************************************************************/
   -- Bug 24462 - SHA - 14/01/2014 - se crea la funcion
   FUNCTION f_get_ctacoaseguro_det(
      pccompani IN NUMBER,
      pfcierre IN DATE,
      pciaprop IN NUMBER,
      ptipocoaseguro IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcestado IN NUMBER,
      psseguro IN NUMBER,
      pcinverfas IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pliquidable IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
   Función que actualiza el estado de movimiento concreto de una cuenta de coaseguro
   *************************************************************************/
   -- Bug 32034 - SHA - 18/08/2014 - se crea la funcion
   FUNCTION f_set_estado_ctacoa(
      pccompani IN NUMBER,
      pcompapr IN NUMBER,
      pctipcoa IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcmovimi IN NUMBER,
      pfcierre IN DATE DEFAULT NULL,
      pestadonew IN NUMBER,
      pestadoold IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /***************************************************************************************************
   Función que setea a Pendiente el estado de aquellos movimientos de cuenta de coaseguro con estado 4
   ****************************************************************************************************/
   FUNCTION f_reset_estado(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Función que devuelve las cuentas técnicas de coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_ctacoaseguro(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompani IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfcierre IN DATE,
      psseguro IN NUMBER,
      pcestado IN NUMBER,
      pciaprop IN NUMBER,
      ptipocoaseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcinverfas IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pfcierredesde IN DATE,
      pfcierrehasta IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Función que devuelve la cabecera de la cuenta técnica de coaseguro consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_cab_ctacoa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompapr IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Función que devuelve las cuentas técnicas de la coaseguradora consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_mov_ctacoa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompapr IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pcestado IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pliquidable IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Función que elimina un movimiento manual de la cuenta técnica del coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_del_mov_ctacoa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pnnumlin IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Función que apunta en la tabla de liquidación los importes pendientes de la cuenta técnica del coaseguro.
   *************************************************************************/
   -- Bug 22076 - AVT - 24/05/2012 - se crea la funcion
   FUNCTION f_liquida_ctatec_coa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompani IN NUMBER,
      pccompapr IN NUMBER,
      pfcierre IN DATE,
      pfcierredesde IN DATE,
      pfcierrehasta IN DATE,
      pctipcoa IN NUMBER,
      psproces_ant IN NUMBER,
      psproces_nou IN NUMBER,
      indice OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--   FUNCTION f_liquida_ctatec_coa(
--      psproces IN NUMBER,
--      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
--      pccompani IN NUMBER,
--      pfcierre IN DATE,
--      psseguro IN NUMBER,
--      indice OUT NUMBER,
--      mensajes IN OUT t_iax_mensajes)
--      RETURN NUMBER;

   /*************************************************************************
       Función que insertará o modificará un movimiento de cuenta técnica en función del pmodo
   *************************************************************************/
   -- Bug 22076 - AVT - 25/05/2012 - se crea la funcion
   FUNCTION f_set_mov_ctacoa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompani IN NUMBER,
      pnnumlin IN NUMBER,
      pctipcoa IN NUMBER,
      pcdebhab IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psidepag IN NUMBER,
      pfcierre IN DATE,
      pcmovimi IN NUMBER,
      pcimport IN NUMBER,
      pimovimi IN NUMBER,
      pfcambio IN DATE,
      pcestado IN NUMBER,
      ptdescri IN VARCHAR2,
      ptdocume IN VARCHAR2,
      pmodo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

           /*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta función deberá realizar una llamada a la función de la capa de negocio pac_coa.f_inicializa_liquida_coa
    Parámetros
     Entrada :
       Pfperini NUMBER : Fecha inicio
       Pcempres NUMBER : Empresa

     Salida :
       Mensajes   T_IAX_MENSAJES

    Retorna : NUMBER con el número de proceso.
   ********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   FUNCTION f_registra_proceso(
      pfperini IN DATE,
      pcempres IN NUMBER,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*******************************************************************************
FUNCION F_GET_REMESA_DET
Esta función nos devolverá la consulta de remesas

********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   function F_GET_REMESA_DET(    --ramiro
      PCCOMPANI  in number,
      PCSUCURSAL in number,
      PFCIERRE  in date,
      PCIAPROP in number,
      PCTIPCOA in number,
      PCEMPRES in number,
      PCRAMO in number,
      PSPRODUC in number,
      PNPOLCIA in number,
      PCESTADO in number,
      PSSEGURO in number,
      PSMOVCOA IN NUMBER,
      MENSAJES OUT T_IAX_MENSAJES)
      return sys_refcursor ;  --ramiro

 /*******************************************************************************
FUNCION F_SET_REMESA_DET
Esta función nos devolverá la consulta de remesas

********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   function f_set_remesa_ctacoa(    --ramiro
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      pnnumlin IN NUMBER,
      pctipcoa IN NUMBER,
      pcdebhab IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psidepag IN NUMBER,
      pfcierre IN DATE,
      pcmovimi IN NUMBER,
      pcimport IN NUMBER,
      pimovimi IN NUMBER,
      pfcambio IN DATE,
      pcestado IN NUMBER,
      ptdescri IN VARCHAR2,
      ptdocume IN VARCHAR2,
      PMODO in number,
      PNPOLCIA in number,
      PCSUCURSAL in number,
      PMONEDA in number,
      psmvcoa in number,
      mensajes OUT t_iax_mensajes)
      return NUMBER ;  --ramiro


END pac_md_coa;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COA" TO "PROGRAMADORESCSI";
