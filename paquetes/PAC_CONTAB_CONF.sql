--------------------------------------------------------
--  DDL for Package PAC_CONTAB_CONF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE PAC_CONTAB_CONF AS

/******************************************************************************
   NOMBRE:    PAC_CONTAB_CONF
   PROP?¡°SITO: Contiene funciones para la parametrizaci?3n contable

   REVISIONES:
   Ver        Fecha       Autor            Descripci?3n
   ---------  ----------  ---------------  ------------------------------------
   1.0        21/06/2017   RCM              1. Creaci?3n del package.
   2.0        27/10/2017  ABENAVIDES        Se crea la funcion f_importe_provision
                                            para que realiza el insert a la tabla de
                                            provisiones resumen con los valores acumulados.
   3.0        21/11/2017  ABENAVIDES        Se crean funciones para el cambio de cabecera
                                            de los documentos XML
   4.0        23/05/2019  ECP               IAXIS-3592.Proceso de terminaci¨®n por no pago
******************************************************************************/

/* TODO enter package declarations (types, exceptions, methods etc) here */
 /*************************************************************************
       NOMBRE              : f_contab_trm
       Funci?3n que trae el trm de la expedici?3n de la p?3liza
       param in  p_sseguro : sseguro
       param in  p_cagente : c?3digo del agente
       param out  v_trm    : valor del trm
    *************************************************************************/

   FUNCTION f_contab_trm(
      p_sseguro IN seguros.sseguro%TYPE,
        p_cagente IN seguros.cagente%TYPE)
      RETURN eco_tipocambio.itasa%TYPE;


 /*************************************************************************
       NOMBRE              : f_mon_poliza
       Funci?3n Trae la moneda correspondiente de una p?3liza
       param in  p_sseguro : sseguro
       param out  v_moneda : moneda de la p?3liza
    *************************************************************************/

   FUNCTION f_mon_poliza(
      p_sseguro IN seguros.sseguro%TYPE)
      RETURN monedas.cmonint%TYPE;

  FUNCTION f_moneda(
      p_cmonint IN monedas.cmonint%TYPE)
      RETURN monedas.cmonint%TYPE;

   /*************************************************************************
       NOMBRE              : f_tipo
       Funci?3n Trae el tipo de registro de cuentas
       param in  p_ctaniif : cuenta niif
       param out  v_tipo   : tipo de registro(K, D, A, C, I) seg?on la cuenta
    *************************************************************************/

   FUNCTION f_tipo(
      p_ctaniif IN cuentasniif_tipo.cta_niif%TYPE)
      RETURN cuentasniif_tipo.tipo%TYPE;

    /*************************************************************************
       NOMBRE              : f_libro
       Funci?3nn Trae el tipo de libro de cuentas
       param in  p_ctaniif : cuenta niif
       param out  v_libro   : tipo de libro(0L,1L,0L1L) seg??n la cuenta
    *************************************************************************/

   FUNCTION f_libro(
      p_ctaniif IN cuentasniif_tipo.cta_niif%TYPE)
      RETURN cuentasniif_tipo.libro%TYPE;

   /*************************************************************************
       NOMBRE              : f_division
       Funci?3n Trae la sucursal de un agente o un seguro
       param in  p_sseguro : sseguro, este par??metro no es siempre obligatorio, puede ser null
       param in  p_cagente : c?3digo del agente, este par??metro es obligatorio
       param out  v_moneda : moneda de la p?3liza
    *************************************************************************/

  FUNCTION f_division(
      p_sseguro IN seguros.sseguro%TYPE,
        p_cagente IN seguros.cagente%TYPE)
      RETURN agentes.cagente%TYPE;

 /*************************************************************************
       NOMBRE              : f_division_sin
       Funci?3n Trae la sucursal de un agente o un seguro
       param in  p_cagente : c?3digo del agente, este par??metro es obligatorio
       param out  v_moneda : moneda de la p?3liza
    *************************************************************************/

  FUNCTION f_division_sin(
     pnsinies IN sin_siniestro.nsinies%TYPE,
        psidepag  IN sin_tramita_pago.sidepag%TYPE,  --Iaxis 4504 AABC 09/09/2019
        p_cagente IN seguros.cagente%TYPE)
      RETURN agentes.cagente%TYPE;
   /*************************************************************************
       NOMBRE              : f_regi?3n
       Funci?3n Trae la regi?3n de un agente o un seguro
       param in  p_sseguro : sseguro, este par??metro no es siempre obligatorio, puede ser null
       param in  p_cagente : c?3digo del agente, este par??metro es obligatorio
       param out  v_moneda : moneda de la p?3liza
    *************************************************************************/

  FUNCTION f_region(
      p_sseguro IN seguros.sseguro%TYPE,
        p_cagente IN seguros.cagente%TYPE)
      RETURN agentes.cagente%TYPE;

  FUNCTION f_persona(
      p_sperson IN tomadores.sperson%TYPE,
      p_cagente IN agentes.cagente%TYPE,
      p_compania IN companias.ccompani%TYPE,
      p_ctipcom IN companias.ctipcom%TYPE)
      RETURN per_personas.nnumide%TYPE;


  FUNCTION f_pagador_alt(
      p_sseguro IN seguros.sseguro%TYPE)
      RETURN per_personas.nnumide%TYPE;


/*************************************************************************
IND_IMPUESTO:
se utiliza la funci?3n pac_impuestos_conf.f_indicador_agente
par??metros:
  cagente : c?3digo de agente
  pcimpret: tipo de retenci?3n, 1-IVA
  pfecha  : sysdate o null
--------------pac_impuestos_conf.f_indicador_agente(s.cagente, 1,f_sysdate)
*************************************************************************/


/*************************************************************************
RETENCIONTIPO:
se utiliza la funci?3n pac_impuestos_conf.f_indicador_agente, se substraen las dos primeras posiciones del resultado
par??metros:
  cagente : c?3digo de agente
  pcimpret: tipo de retenci?3n, 4-ReteICA
  pfecha  : sysdate o null
--------------substr(pac_impuestos_conf.f_indicador_agente(s.cagente, 4,f_sysdate),1,2)
*************************************************************************/


/*************************************************************************
IND_RETENCION:
se utiliza la funci?3n pac_impuestos_conf.f_indicador_agente, se substraen las dos ?oltimas posiciones del resultado
par??metros:
  cagente : c?3digo de agente
  pcimpret: tipo de retenci?3n, 4-ReteICA
  pfecha  : sysdate o null
--------------substr(pac_impuestos_conf.f_indicador_agente(s.cagente, 4,f_sysdate),1,2)
*************************************************************************/

   /*************************************************************************
       NOMBRE               : f_segmento
       Funci?3n Trae el ramo al que corresponde un seguro
       param in  p_sseguro  : sseguro, este par??metro es obligatorio
       param out v_segmento : c?3digo SAP que indica el ramo
    *************************************************************************/
 FUNCTION f_segmento(
      p_sseguro IN seguros.sseguro%TYPE)
      RETURN cnvproductos_ext.cnv_spr%TYPE;


   /*************************************************************************
       NOMBRE               : f_zzproducto
       Funci?3n Trae el producto al que corresponde un seguro
       param in  p_sseguro  : sseguro, este par??metro es obligatorio
       param out v_segmento : c?3digo SAP que indica el producto
    *************************************************************************/
 FUNCTION f_zzproducto(
      p_sseguro IN seguros.sseguro%TYPE)
      RETURN cnvproductos_ext.cnv_spr%TYPE;


FUNCTION F_ZZFIPOLIZA(
      P_SSEGURO IN SEGUROS.SSEGURO%TYPE)
      RETURN VARCHAR2;

  FUNCTION f_zzcertific(
      p_sseguro IN seguros.sseguro%TYPE)
      RETURN rango_dian_movseguro.ncertdian%TYPE;

   FUNCTION f_importe_base_iva(
      p_nrecibo IN recibos.nrecibo%TYPE,
      p_cagente IN ctactes.cagente%TYPE)
      RETURN vdetrecibos.iprinet%TYPE;
/*************************************************************************
IMPORTE_BASE_IVA:
se utiliza la funci?3n     pac_corretaje.f_impcor_agente
par??metros:
  iprinet   : prima neta
  pcagente  : c?3digo de agente
  psseguro  : sseguro
  pnmovimi  :
--------------substr(pac_impuestos_conf.f_indicador_agente(s.cagente, 4,f_sysdate),1,2)
/*************************************************************************
  NOMBRE: f_importe_provision
  Funci?3n Trae el valor base del importe dependiendo de los registros
  param in  p_sproces: Numero de proceso
  param in  p_tip_provisi :Tipo de Provision, 1 Prima Devengada, 2  Octavos.
  param in  p_fech_cierre :Fecha de cierre.
  param in  p_sucursal   :Sucursal de la provisi?3n.
  param out Error : Error
 *************************************************************************/
 --
 FUNCTION f_importe_provision(p_sproces     IN NUMBER,
                              p_tip_provisi IN NUMBER,
                              p_fech_cierre IN DATE,
                              p_sucursal    IN NUMBER)
 RETURN NUMBER;
 -- Version 3.0
/*************************************************************************
 NOMBRE              : f_catribu
 Funcion que obtine el catribu de la tabla detvalores para los nuevos
 ttippag creados.
*************************************************************************/
  FUNCTION f_catribu(p_cvalor  IN detvalores.cvalor%TYPE,
                     p_cidioma IN detvalores.cidioma%TYPE,
                     p_tatribu IN detvalores.tatribu%TYPE)
  RETURN NUMBER;
 --
/*************************************************************************
 NOMBRE              : f_sseguro_coretaje
 Funcion que obtine el catribu de la tabla detvalores para los nuevos
 ttippag creados.
*************************************************************************/
FUNCTION f_sseguro_coretaje(p_nrecibo IN recibos.nrecibo%TYPE)
RETURN NUMBER;
-- Version 3.0

--CONF-403
/*************************************************************************
 NOMBRE              : f_coa_por_garant
 Funcion que obtiene el valor proporcional por garant¨ªa para cada importe del coaseguro.
*************************************************************************/
--
FUNCTION f_coa_por_garant(
                    p_nrecibo IN recibos.nrecibo%TYPE,
                    p_cgarant  IN NUMBER,
                    p_import   IN NUMBER)
RETURN NUMBER;

/*************************************************************************
 NOMBRE              : f_comision_por_coa
 Funcion que obtiene el valor proporcional de la comisi¨®n para un agente, corredor, etc., en relaci¨®n al coaseguro.
*************************************************************************/
FUNCTION f_comision_por_coa(
                    p_sseguro IN NUMBER,
                    p_ccompani IN NUMBER,
                    p_iimport  IN NUMBER)
RETURN NUMBER;


-- Ini IAXIS- 3592 -- ECP -- 23/05/2019
/*************************************************************************
 NOMBRE              :  f_valor_cancel
 Funcion que obtiene el valor cancelado
*************************************************************************/
FUNCTION f_valor_cancel(p_nrecibo IN recibos.nrecibo%TYPE,p_cconcep IN detmovrecibo_parcial.cconcep%type)
RETURN NUMBER;
-- Fin IAXIS- 3592 -- ECP -- 23/05/2019

END PAC_CONTAB_CONF;

/