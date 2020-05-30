--------------------------------------------------------
--  DDL for Package PAC_MD_COMISI_APR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_COMISI_APR" AS
   FUNCTION f_obtener_polizas(
      p_cagente IN NUMBER,
      p_tagente IN VARCHAR,
      p_npoliza IN NUMBER,
      p_ncertif IN NUMBER,
      p_desde IN DATE,
      p_hasta IN DATE,
      p_refcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_obtener_total_comis(
      p_sseguro IN NUMBER,
      p_npoliza OUT NUMBER,
      p_fefecto OUT DATE,
      p_vto OUT DATE,
      p_totcom OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_obtener_comisiones(
      p_sseguro IN NUMBER,
      p_refcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_comisi_apr;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISI_APR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISI_APR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISI_APR" TO "PROGRAMADORESCSI";
