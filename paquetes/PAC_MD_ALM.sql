--------------------------------------------------------
--  DDL for Package PAC_MD_ALM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_ALM" AS
/******************************************************************************
   NOMBRE:    pac_md_alm
   PROPÓSITO: Contiene el módulo de ALM-Asset Liability Management de la capa MD

   REVISIONES:

   Ver        Fecha        Autor  Descripción
   ---------  ----------  ------  ------------------------------------
     1        14/09/2010   JMF    1. 0015956 CEM - ALM
******************************************************************************/

   /*************************************************************************
       Función que consulta si existe detalle ALM para una fecha
       param p_cempres    in : empresa
       param p_fcalcul    in : fecha calculo
       param in out MENSAJES : mensajes de error
       retorno 0-No existe, 1-Si existe
   *************************************************************************/
   FUNCTION f_existe_detalle(
      p_cempres IN NUMBER,
      p_fcalcul IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que selecciona info sobre criterios alm.
       param p_cempres    in : empresa
       param p_rcriterio  OUT: cursor con informacion alm_criterio
       param in out MENSAJES : mensajes de error
       retorno 0-Correto, 1-Existen errores
   *************************************************************************/
   FUNCTION f_get_almcriterio(
      p_cempres IN NUMBER,
      p_rcriterio OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que selecciona info sobre el detalle alm.
       param p_cempres    in : empresa
       param p_sproduc    in : producto
       param p_nPOLIZA    in : póliza
       param p_nCERTIF    in : certificado
       param p_FVALORA    in : fecha valoracion
       param p_rcriterio  OUT: cursor con informacion alm_detalle
       param in out MENSAJES : mensajes de error
       retorno 0-Correto, 1-Existen errores
   *************************************************************************/
   FUNCTION f_get_almdetalle(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_npoliza IN NUMBER,
      p_ncertif IN NUMBER,
      p_fvalora IN DATE,
      p_cramo IN NUMBER,
      p_rcriterio OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que genera el proceso ALM
       param p_cempres    in : empresa
       param p_fcalcul    in : fecha calculo
       param p_sproduc    in : producto
       param p_pintfutdef in : Interés futuro defecto
       param p_pcredibdef in : Porcentaje de credibilidad defecto
       param in out MENSAJES : mensajes de error
       retorno 0-Correcto, 1-Código Error
   *************************************************************************/
   FUNCTION f_genera_alm(
      p_cempres IN NUMBER,
      p_fcalcul IN DATE,
      p_sproduc IN NUMBER,
      p_pintfutdef IN NUMBER,
      p_pcredibdef IN NUMBER,
      p_cramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que crea registro nuevo en ALM_CRITERIO
       si el parametro ORDEN no esta informado. Resto casos actualiza registro.
       param p_cempres    in : empresa
       param p_TCRITERIO  IN : Criterio
       param p_NORDEN     IN : Orden
       param p_PCREDIBI   IN : Porcentaje credibilidad
       param p_PINTFUT    IN : Porcentaje interes
       param in out MENSAJES : mensajes de error
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_almcriterio(
      p_cempres IN NUMBER,
      p_tcriterio IN VARCHAR2,
      p_norden IN NUMBER,
      p_pcredibi IN NUMBER,
      p_pintfut IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que borra registro de ALM_CRITERIO
       param p_cempres    in : empresa
       param p_NORDEN     IN : Orden
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_del_almcriterio(
      p_cempres IN NUMBER,
      p_norden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_alm;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ALM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ALM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ALM" TO "PROGRAMADORESCSI";
