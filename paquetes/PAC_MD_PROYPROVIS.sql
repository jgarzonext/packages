--------------------------------------------------------
--  DDL for Package PAC_MD_PROYPROVIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PROYPROVIS" AS
   /*************************************************************************
          Function f_calculo_proyprovis
          funcion que calcula la proyección de la reserva para una póliza/certificado y garantía a una fecha
          ptablas in number: Código idioma
          psseguro: sseguro
          RETURN varchar2 lista de sperson que desempeña el Rol Persona indicado
     *************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/**************************************************************************/
   FUNCTION f_calculo_proyprovis(
      psproces IN NUMBER,
      pperiodicidad IN NUMBER,
      pfechaini IN DATE,
      pfechafin IN DATE,
      psproduc IN NUMBER DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL,
      pncertif IN NUMBER DEFAULT NULL,
      pmodo IN VARCHAR2 DEFAULT 'R',
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_inicializa_proceso(
      pmes IN NUMBER,
      panyo IN NUMBER,
      pcempres IN NUMBER,
      pfinicio IN DATE,
      pnproceso OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_consul_param_mto_pos(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_md_proyprovis;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROYPROVIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROYPROVIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROYPROVIS" TO "PROGRAMADORESCSI";
