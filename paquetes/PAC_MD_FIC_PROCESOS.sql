--------------------------------------------------------
--  DDL for Package PAC_MD_FIC_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_FIC_PROCESOS" AS
/******************************************************************************
   NOMBRE:       PAC_MD_FIC_PROCESOS
   PROPÓSITO: Nuevo paquete de la capa IAX que tendrá las funciones para la gestión de procesos del gestor de informes.
              Controlar todos posibles errores con PAC_IOBJ_MNSAJES.P_TRATARMENSAJE


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/06/2009   JMG                1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*F_get_Ficprocesos
Nueva función de la capa MD que devolverá los procesos del gestor de informes

Parámetros

1. pcempres IN NUMBER
2. psproces IN NUMBER
3. ptgestor IN VARCHAR2
4. ptformat IN VARCHAR2
5. ptanio   IN VARCHAR2
6. ptmes    IN VARCHAR2
7. ptdiasem IN VARCHAR2
8. pcusuari IN VARCHAR2
9. pfproini IN DATE
10. mensajes OUT T_IAX_MENSAJES

*/
   FUNCTION f_get_ficprocesos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      ptgestor IN VARCHAR2,
      ptformat IN VARCHAR2,
      ptanio IN VARCHAR2,
      ptmes IN VARCHAR2,
      ptdiasem IN VARCHAR2,
      pnerror IN NUMBER,
      pcusuari IN VARCHAR2,
      pfproini IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*f_get_ficprocesosdet
Nueva función de la capa MD que devolverá los detalles de procesos del gestor de informes

Parámetros

1. psproces IN NUMBER
2. mensajes OUT T_IAX_MENSAJES

*/
   FUNCTION f_get_ficprocesosdet(psproces IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_fic_procesosdet;
END pac_md_fic_procesos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FIC_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FIC_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FIC_PROCESOS" TO "PROGRAMADORESCSI";
