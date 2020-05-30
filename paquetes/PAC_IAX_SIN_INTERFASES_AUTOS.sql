--------------------------------------------------------
--  DDL for Package PAC_IAX_SIN_INTERFASES_AUTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_SIN_INTERFASES_AUTOS" AS
/******************************************************************************
   NOMBRE:    PAC_SIN_INTERFASES_AUTOS
   PROPÓSITO: Funciones para interfases en siniestros de autos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       08/04/2013   ASN             Creacion
******************************************************************************/
   FUNCTION f_ciudad(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramita_gestion.ntramit%TYPE,
      pnlocali IN sin_tramita_gestion.nlocali%TYPE)
      RETURN VARCHAR2;

   FUNCTION f_l021(
      ciudad IN VARCHAR2,
      fechaconsultaincialradicacion IN DATE,
      fechaconsultafinalradicacion IN DATE,
      siniestrospendientesvlr OUT t_iax_interfase_l021,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Devuelve los siniestros pendientes de valoracion
*************************************************************************/
   FUNCTION f_l022(
      numerosiniestro IN VARCHAR2,
      tipoconsulta IN VARCHAR2,
      repuestos OUT t_iax_interfase_l022,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Devuelve los repuestos pendientes de valoracion de un siniestro dado
*************************************************************************/
   FUNCTION f_l023(
      numerosiniestro IN VARCHAR2,
      codigo IN VARCHAR2,
      descripcion IN VARCHAR2,
      codigoespecifico IN VARCHAR2,
      descripcionespecifica IN VARCHAR2,
      referencia IN VARCHAR2,
      unidades IN NUMBER,
      imprevisto IN NUMBER,
      estado IN VARCHAR2,
      valorunitario IN NUMBER,
      tipodocumentoproveedor IN VARCHAR2,
      numerodocumentoproveedor IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Recibe la valoracion de un repuesto de un siniestro
*************************************************************************/
   FUNCTION consultarautoasegurado(
      pcmatric IN VARCHAR2,
      pfecha IN DATE,
      ob_auto OUT ob_iax_interfase_automovil,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Devuelve los datos de un vehiculo
*************************************************************************/
   FUNCTION notificartallerasignado(
      pctipide IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pdane IN VARCHAR2,
      pnumsede IN VARCHAR2,
      pcmatric IN VARCHAR2,
      pnsinies IN VARCHAR2,
      pccontra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Inserta una gestion Taller
*************************************************************************/
   FUNCTION notificarvaloressiniestro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      valoresperdidas IN t_iax_interfase_valores_per,
      valoresrc IN t_iax_interfase_valores_rc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
/*************************************************************************
   Inserta el detalle de la gestion Taller
*************************************************************************/
END pac_iax_sin_interfases_autos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_INTERFASES_AUTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_INTERFASES_AUTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_INTERFASES_AUTOS" TO "PROGRAMADORESCSI";
