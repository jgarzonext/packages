--------------------------------------------------------
--  DDL for Package PAC_IAX_UNDERWRITING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_UNDERWRITING" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_UNDERWRITING
      PROPÓSITO: Recupera la información de la poliza guardada en la base de datos
                 a un nivel independiente.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/06/2015    RSC                1. Creación del package.
      1.1        21/07/2015    mnustes            2. Creación funcion f_get_icd10codes
      1.2        29/07/2015    IGIL               3. Creacion funcion f_get_evidences
   ******************************************************************************/
   FUNCTION f_activo_undw_if01(
      psproduc IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes OUT t_iax_mensajes)
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
      pcindex IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     funcion encargada de traer las evidencias medicas
     param out mensajes : mensajes de error de la aplicacion
     return : number
     Bug 36596 igil
   *************************************************************************/
   FUNCTION f_get_evidences(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_iax_underwriting;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_UNDERWRITING" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_UNDERWRITING" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_UNDERWRITING" TO "PROGRAMADORESCSI";
