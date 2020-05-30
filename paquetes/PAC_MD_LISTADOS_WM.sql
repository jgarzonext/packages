--------------------------------------------------------
--  DDL for Package PAC_MD_LISTADOS_WM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_LISTADOS_WM" IS
/******************************************************************************
   NOMBRE:       pac_md_wm_listado
   PROPÓSITO:    Contiene la generación de diversos listado por agente y rango de fechas.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/06/2010   SRA              1. Creación del package.
******************************************************************************//******************************************************************************
   P_LISTADO_CARTERA - genera el listado de cartera de recibos emitidos en el reango de fechas especificado,
                       filtrando las pólizas a las del agente si así se ha especificado
      p_finicar IN VARCHAR2,
      p_ffincar IN VARCHAR2,
      p_cagente IN NUMBER,
      p_tlistacartera OUT t_iax_listadocartera_wm)
   ********************************************************************************/
   PROCEDURE p_listado_cartera(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      p_tlistacartera OUT t_iax_listadocartera_wm,
      mensajes IN OUT t_iax_mensajes);

   /******************************************************************************
   p_LISTADO_POLIZAS - genera el listado de pólizas en vigor y prima anualizada emitidas en el rango de fechas listado,
                       filtrando las pólizas a las del agente si así se ha especificado
      p_finicar IN VARCHAR2,
      p_ffincar IN VARCHAR2,
      p_cagente IN NUMBER,
      p_tlistapolizas OUT t_iax_listadopolizas_wm)
   *******************************************************************************/
   PROCEDURE p_listado_polizas(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      p_tlistapolizas OUT t_iax_listadopolizas_wm,
      mensajes IN OUT t_iax_mensajes);

   /******************************************************************************
   P_LISTADO_SINIESTROS - genera un listado de siniestros abiertos/reperturados/abiertos y cerrados en el rango de fechas listado,
                          filtrando las pólizas a las del agente si así se ha especificado
      p_finicar IN VARCHAR2,
      p_ffincar IN VARCHAR2,
      p_cagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes);
   ********************************************************************************/
   PROCEDURE p_listado_siniestros(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      p_tlistasiniestros IN OUT t_iax_listadosiniestros_wm,
      mensajes IN OUT t_iax_mensajes);
END pac_md_listados_wm;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADOS_WM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADOS_WM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADOS_WM" TO "PROGRAMADORESCSI";
