--------------------------------------------------------
--  DDL for Package PAC_MD_EMPLEADOS_REPRESENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_EMPLEADOS_REPRESENT" IS
/******************************************************************************
   NOMBRE:       PAC_MD_EMPLEADOS_REPRESENT
   PROPÓSITO:    Funciones para gestionar empleados y representantes

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/10/2012  MDS              1. Creación del package. 0022266: LCOL_P001 - PER - Mantenimiento de promotores, gestores, empleados, coordinador
   2.0        04/10/2013  JDS              2. 0028395: LCOL - PER - No aparece el campo “Compañía” al seleccionar la opción “Externo”

******************************************************************************/

   /*************************************************************************
     Función que obtiene la lista de empleados
     param out pcur      : sys_refcursor
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_get_empleados(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      pccargo IN NUMBER,
      pccanal IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
     Función que obtiene un empleado
     ...
     param out mensajes  : t_iax_mensajes
     return              : ob_iax_empleado
    *************************************************************************/
   FUNCTION f_get_empleado(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_empleado;

   /*************************************************************************
     Función que inserta/modifica un registro de empleado
     ...
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_set_empleado(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      pcargo IN NUMBER,
      pccanal IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Función que borra un registro de empleado
     ...
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_del_empleado(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Función que obtiene la lista de representantes
     param out mensajes  : t_iax_mensajes
     return              : sys_refcursor
    *************************************************************************/
   FUNCTION f_get_representantes(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      ptcompania IN VARCHAR2,
      ptpuntoventa IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
     Función que obtiene un representante
     ...
     param out mensajes  : t_iax_mensajes
     return              : ob_iax_representante
    *************************************************************************/
   FUNCTION f_get_representante(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_representante;

   /*************************************************************************
     Función que inserta/modifica un registro de representante
     ...
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_set_representante(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      ptcompania IN VARCHAR2,
      ptpuntoventa IN VARCHAR2,
      pspercoord IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Función que borra un registro de representante
     ...
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_del_representante(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_empleados_represent;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_EMPLEADOS_REPRESENT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_EMPLEADOS_REPRESENT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_EMPLEADOS_REPRESENT" TO "PROGRAMADORESCSI";
