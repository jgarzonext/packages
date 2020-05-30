--------------------------------------------------------
--  DDL for Package PAC_MD_LISTVALORES_REA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_LISTVALORES_REA" AS
/******************************************************************************
 NOMBRE: PAC_MD_LISTVALORES_REA
 PROPOSITO: Funciones para recuperar valores

 REVISIONES:
 Ver Fecha Autor Descripcion
 --------- ---------- --------------- ------------------------------------
 1.0                                  1. Creacion del Package
 2.0       07/10/2011 APD             2. 0019602: LCOL_A002-Correcciones en las pantallas de mantenimiento del reaseguro
 3.0       23/05/2012 AVT             3. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
 4.0       22/08/2013 DEV             4. 0026443: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 76 -XL capacidad prioridad dependiente del producto (Fase3)
 5.0       30/09/2013 RCL             5. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
 6.0       09/04/2014 AGG             6. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
 7.0       22/09/2014 MMM             7. 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales
 8.0       02/09/2016 HRE             8. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
******************************************************************************/

   /*************************************************************************
   Recupera los tipos de tramos proporcionales, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_prop(ctiprea NUMBER, mensajes IN OUT t_iax_mensajes)--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona ctiprea
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los tipos de tramos proporcionales, devuelve un SYS_REFCURSO
   param in p_tparam : parametros de filtro
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_prop_fil(p_tparam VARCHAR, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los tipos de tramos NO proporcionales, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_noprop(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los tipos de E/R cartera de primas, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_ercarteraprimas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera las base de calculo de la prima XL, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_basexl(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera el campo de aplicacion de la tasa, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_aplictasa(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los tipos de tasa, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipotasa(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los tipos de comision, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipocomision(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los tramos de comision, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tramosrea(pctipo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los contratos de proteccion, devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_contratoprot(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera las versiones (tabla CONTRATOS) de un contrato, devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param in pscontra: codigo del contrato
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_versionescontratoprot(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los tipos de prima XL, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipoprimaxl(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera las reposiciones, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_reposiciones(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los tipos de clausulas / tramos escalonados, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipoclautramescal(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los contratos (tabla CODICONTRATOS), devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   -- 7.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Inicio
   -- FUNCTION f_get_contratos(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
   FUNCTION f_get_contratos(
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pctipo IN NUMBER DEFAULT -1)
      -- 7.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Fin
   RETURN sys_refcursor;

   /*************************************************************************
   Recupera las versiones (tabla CONTRATOS), devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_versiones(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los brokers (tabla COMPANIAS), devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_broker(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera todos los tipos de tramos (NO proporcionales y Proporcionales),
   devuelve un SYS_REFCURSOR param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos(pscontra IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera todos los tipos de tramos (NO proporcionales y Proporcionales),
    devuelve un SYS_REFCURSOR param out : mensajes de error
    param in p_tparam : condicion de filtro
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_tipostramos_fil(p_tparam IN VARCHAR, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera la lista de valores del desplegable para el estado de la cuenta
   devuelve un SYS_REFCURSOR param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_estado_cta(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera la lista desplegable de conceptos de la cuenta tecnica del Reaseguro
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_tipo_movcta(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los identificadores de pagos asociados a un siniestro
      param in pnsinies: n¿mero del siniestro
      param out : mensajes de error
      return : ref cursor
   *************************************************************************/
   FUNCTION f_get_identif_pago_sin(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la versi¿n vigente de un contrato
      param in pcempres : empresa
      param in pscontra : contrato
      param out : mensajes de error
      return : ref cursor
   *************************************************************************/
   FUNCTION f_get_versionvigente_contrato(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los ramos de un contrato
      param in pcempres : empresa
      param in pscontra : contrato
      param out : mensajes de error
      return : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramos_contrato(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_md_listvalores_rea;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_REA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_REA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_REA" TO "PROGRAMADORESCSI";
