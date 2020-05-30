--------------------------------------------------------
--  DDL for Package PAC_MD_UNDERWRITING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_UNDERWRITING" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_UNDERWRITING
      PROPÓSITO: Recupera la información de la poliza guardada en la base de datos
                 a un nivel independiente.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/06/2015    RSC                1. Creación del package.
      1.1        29/07/2015    IGIL               2. Creacion funciones para insertar , editar , eliminar
                                                     citas medicas y traer las evidencias medicas
   ******************************************************************************/
   FUNCTION f_connect_undw_if01(
      pcaseid IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_underwrt_if01;

   FUNCTION f_connect_undw_if02(
      pcaseid IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_activo_undw_if01(
      psproduc IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     funcion que retorna la lista de enfermedades relacionadas de Allfinanz
     param psseguro : codigo del seguro
     param pnmovimi : codigo del movimiento
     param mensajes : mensajes de error de la aplicacion
     return : SYS_REFCURSOR Cursor con la lista de enfermedades.
     Bug 36596 mnustes
   *************************************************************************/
   FUNCTION f_get_icd10codes(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
     funcion que guarda las enfermedades relacionadas al rechazar un seguro
     param psseguro : codigo del seguro
     param pnmovimi : codigo del movimiento
     param pcindex : indices de enfermedades
     param mensajes : mensajes de error de la aplicacion
     return : number
     Bug 36596 mnustes
   *************************************************************************/
   FUNCTION f_setrechazo_icd10codes(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      pcindex IN t_iax_info,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     funcion encargada de traer las evidencias medicas
     param out mensajes : mensajes de error de la aplicacion
     return : number
     Bug 36596 igil
   *************************************************************************/
   FUNCTION f_get_evidences(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
     funcion encargada de  insertar las citas medicas en las tablas reales y EST
     return : number
     Bug 36596 igil
   *************************************************************************/
   FUNCTION f_insert_citasmedicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psperaseg IN NUMBER,
      pspermed IN NUMBER,
      pceviden IN NUMBER,
      pfeviden IN DATE,
      pcestado IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pieviden IN NUMBER,
      pcpago IN NUMBER,
      pnorden_r OUT NUMBER,
      pcais IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     funcion encargada de editar las citas medicas en laS tablas reales y EST
     return : number
     Bug 36596 igil
   *************************************************************************/
   FUNCTION f_edit_citasmedicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psperaseg IN NUMBER,
      pspermed IN NUMBER,
      pceviden IN NUMBER,
      pfeviden IN DATE,
      pcestado IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pieviden IN NUMBER,
      pcpago IN NUMBER,
      pnorden_r IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     funcion encargada de eliminar las citas medicas en la stablas reales y EST
     return : number
     Bug 36596 igil
   *************************************************************************/
   FUNCTION f_delete_citasmedicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psperaseg IN NUMBER,
      pceviden IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pnorden_r IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_underwriting;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_UNDERWRITING" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_UNDERWRITING" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_UNDERWRITING" TO "PROGRAMADORESCSI";
