--------------------------------------------------------
--  DDL for Package PAC_IAX_LISTADOS_WM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_LISTADOS_WM" IS
/******************************************************************************
   NOMBRE:       pac_iax_wm_listado
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
   FUNCTION f_listado_cartera(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_listadocartera_wm;

   /******************************************************************************
   p_LISTADO_POLIZAS - genera el listado de pólizas en vigor y prima anualizada emitidas en el rango de fechas listado,
                       filtrando las pólizas a las del agente si así se ha especificado
      p_finicar IN VARCHAR2,
      p_ffincar IN VARCHAR2,
      p_cagente IN NUMBER,
      p_tlistapolizas OUT t_iax_listadopolizas_wm)
   *******************************************************************************/
   FUNCTION f_listado_polizas(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_listadopolizas_wm;

   /******************************************************************************
   P_LISTADO_SINIESTROS - genera un listado de siniestros abiertos/reperturados/abiertos y cerrados en el rango de fechas listado,
                          filtrando las pólizas a las del agente si así se ha especificado
      p_finicar IN VARCHAR2,
      p_ffincar IN VARCHAR2,
      p_cagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes);
   ********************************************************************************/
   FUNCTION f_listado_siniestros(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_listadosiniestros_wm;
END pac_iax_listados_wm;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADOS_WM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADOS_WM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADOS_WM" TO "PROGRAMADORESCSI";
