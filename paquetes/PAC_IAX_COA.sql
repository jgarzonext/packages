--------------------------------------------------------
--  DDL for Package PAC_IAX_COA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_COA" IS
/******************************************************************************
 NAME: AXIS_D71.pac_iax_coa
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/05/2012                    1. Created this package body.
   2.0        29/05/2012    AVT             2. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
******************************************************************************/

   /*************************************************************************
   Funci¿n que actualiza el estado de movimiento concreto de una cuenta de coaseguro
   *************************************************************************/
   -- Bug 32034 - SHA - 18/08/2014 - se crea la funcion
   FUNCTION f_set_estado_ctacoa(
      pccompani IN NUMBER,
      pcompapr IN NUMBER,
      pctipcoa IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcmovimi IN NUMBER,
      pfcierre IN DATE,
      pestadonew IN NUMBER,
      pestadoold IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***************************************************************************************************
   Funci¿n que setea a Pendiente el estado de aquellos movimientos de cuenta de coaseguro con estado 4
   ****************************************************************************************************/
   -- Bug 32034 - SHA - 18/08/2014 - se crea la funcion
   FUNCTION f_reset_estado(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Funci¿n que devuelve el detalle por poliza de las cuentas t¿cnicas de coaseguro
     *************************************************************************/-- Bug 24462 - SHA - 14/01/2014 - se crea la funcion
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci¿n que devuelve las cuentas t¿cnicas de coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_ctacoaseguro(
      pcempres IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci¿n que devuelve la cabecera de la cuenta t¿cnica de coaseguro consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_cab_ctacoa(
      pcempres IN NUMBER,
      pccompapr IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci¿n que devuelve las cuentas t¿cnicas de la coaseguradora consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_mov_ctacoa(
      pcempres IN NUMBER,
      pccompapr IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pcestado IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pliquidable IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci¿n que elimina un movimiento manual de la cuenta t¿cnica del coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_del_mov_ctacoa(
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pnnumlin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci¿n que apunta en la tabla de liquidaci¿n los importes pendientes de la cuenta t¿cnica del coaseguro.
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Funci¿n que insertar¿ o modificar¿ un movimiento de cuenta t¿cnica en funci¿n del pmodo
   *************************************************************************/
   -- Bug 22076 - AVT - 25/05/2012 - se crea la funcion
   FUNCTION f_set_mov_ctacoa(
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
      pmodo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

         /*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta funci¿n nos devolver¿ el c¿digo de proceso real para la liquidaci¿n del coaseguro
    Par¿metros:
     Entrada :
       Pfperini NUMBER  : Fecha Inicio
       Pcempres NUMBER  : Empresa
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna : NUMBER con el n¿mero de proceso.
   ********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   FUNCTION f_registra_proceso(
      pfperfin IN DATE,
      pcempres IN NUMBER,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;


/*******************************************************************************
FUNCION F_GET_REMESA_DET
Esta funci¿n nos devolver¿ la consulta de remesas

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
Esta funci¿n nos devolver¿ la consulta de remesas

********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   function F_SET_REMESA_DET(    --ramiro
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

END pac_iax_coa;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COA" TO "PROGRAMADORESCSI";
