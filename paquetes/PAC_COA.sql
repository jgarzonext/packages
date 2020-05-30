--------------------------------------------------------
--  DDL for Package PAC_COA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_COA" IS
/******************************************************************************
   NAME:       pac_coa
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/05/2012                    1. Created this package body.
   2.0        29/05/2012    AVT             2. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
   3.0        14/02/2013    RDD             3. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2
   4.0        30/07/2014    DCT             4. 0032159: LCOL_A004-0013424: Siniestro Coaseguro Cedido No Muestra Constitución en Concepto Taller. Repuestos con IVA
******************************************************************************/

   /*************************************************************************
   Función que elimina un movimiento manual de la cuenta técnica del coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_del_mov_ctacoa(
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pnnumlin IN NUMBER)
      RETURN NUMBER;

   /*********************************************************************************
   Función que actualiza el estado de movimiento concreto de una cuenta de coaseguro
   *********************************************************************************/
   FUNCTION f_set_estado_ctacoa(
      pccompani IN NUMBER,
      pcompapr IN NUMBER,
      pctipcoa IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcmovimi IN NUMBER,
      pfcierre IN DATE DEFAULT NULL,
      pestadonew IN NUMBER,
      pestadoold IN NUMBER)
      RETURN NUMBER;

   /***************************************************************************************************
   Función que setea a Pendiente el estado de aquellos movimientos de cuenta de coaseguro con estado 4
   ****************************************************************************************************/
   FUNCTION f_reset_estado(pcempres IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Función que apunta en la tabla de liquidación los importes pendientes de la cuenta técnica del coaseguro.
   *************************************************************************/
   -- Bug 22076 - AVT - 24/05/2012 - se crea la funcion
   FUNCTION f_liquida_ctatec_coa(
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      pccompapr IN NUMBER,
      pfcierre IN DATE,
      pfcierredesde IN DATE,
      pfcierrehasta IN DATE,
      pctipcoa IN NUMBER,
      psproces_ant IN NUMBER,
      psproces_nou IN NUMBER,
      indice OUT NUMBER)
      RETURN NUMBER;

--   FUNCTION f_liquida_ctatec_coa(
--      pcempres IN NUMBER,
--      pccompani IN NUMBER,
--      pfcierre IN DATE,
--      pcidioma IN NUMBER,
--      psproces IN NUMBER,
--      psseguro IN NUMBER,
--      indice OUT NUMBER)
--      RETURN NUMBER;

   /*************************************************************************
       Función que insertará o modificará un movimiento de cuenta técnica en función del pmodo
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
      pcmovimi IN NUMBER,   -- vindrà informat sempre a les modificacions
      pcimport IN NUMBER,   -- sempre obligatori
      pimovimi IN NUMBER,
      pfcambio IN DATE,
      pcestado IN NUMBER,
      ptdescri IN VARCHAR2,
      ptdocume IN VARCHAR2,
      pmodo IN NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
                                                                                                                                                                                                                                                   FUNCION F_INICIALIZA_CARTERA
    Esta función devuelve el sproces con el que se realizará la liquidació del Coasseguro,
    para ello llamará a la función de f_procesini.
   Parámetros
    Entrada :
       Pfperini  DATE     : Fecha
       Pcempres  NUMBER   : Empresa
       Ptexto    VARCHAR2 :
    Salida :
       Psproces  NUMBER  : Numero proceso de cartera.
   Retorna :NUMBER con el número de proceso
   *********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   FUNCTION f_inicializa_liquida_coa(
      pfperini IN DATE,
      pcempres IN NUMBER,
      ptexto IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_reservas_sin_online(
      pcempres IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_impcoa_ccomp(
      psseguro IN NUMBER,
      pccompan IN NUMBER,
      pfinicoa IN DATE,
      pimporte IN NUMBER)
      return number;
 /*******************************************************************************
FUNCION F_SET_REMESA_DET
Esta función nos devolverá la consulta de remesas

********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   function F_SET_REMESA_CTACOA(    --ramiro
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
      psmvcoa in number)
      return NUMBER ;  --ramiro

 /*******************************************************************************
FUNCION F_SET_REMESA_DET
Esta función nos devolverá la consulta de remesas

********************************************************************************/

FUNCTION f_insctacoas_parcial(--RAMIRO
   pnrecibo IN NUMBER,
   pcestrec IN NUMBER,
   pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,   -- 23183 - AVT - 26/10/2012
   psmovrec IN NUMBER,
   PFMOVIMI in date)
   RETURN NUMBER;

END pac_coa;

/

  GRANT EXECUTE ON "AXIS"."PAC_COA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COA" TO "PROGRAMADORESCSI";
