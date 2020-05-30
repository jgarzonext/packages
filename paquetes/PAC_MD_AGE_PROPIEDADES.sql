--------------------------------------------------------
--  DDL for Package PAC_MD_AGE_PROPIEDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_AGE_PROPIEDADES" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_AGE_PROPIEDADES
      PROPOSITO: Funciones para gestionar los parametros de los agentes

      REVISIONES:
      Ver        Fecha        Autor             DescripciÃ³n
      ---------  ----------  ---------------  ------------------------------------
      1.0        08/03/2012  AMC               1. Creación del package.

   ******************************************************************************/

   /*************************************************************************
     Inserta el parà metre per agent
     param in pcagente  : Codi agent
     param in pcparam    : Codi parametre
     param in pnvalpar   : Resposta numérica
     param in ptvalpar   : Resposta text
     param in pfvalpar   : Resposta data
     return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_paragente(
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
        Esborra el parà metre per persona
        param in pcagente   : Codi agent
        param in pcparam    : Codi parametre
        return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_paragente(
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Obté la select amb els parà metres per agent
      param in pcagente    : Codi agent
      param in ptots      : 0.- Només retorna els parà metres contestats
                            1.- Retorna tots els parà metres
      param out pcur      : Cursor
      return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_paragente(
      pcagente IN NUMBER,
      ptots IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Obté la select amb els parà metres per agente
        pcparam IN NUMBER,
        param out pobparagente
        return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_get_obparagente(
      pcparam IN VARCHAR2,
      pobparagente OUT ob_iax_par_agentes,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
   Funcio per comprobar si una propietat es visible per l'agent
      pcagente IN NUMBER,
      pcvisible in texto, funcion para comprobar la visivilidad

   return              : 0.- No visible, 1.- Visible
   *************************************************************************/
   FUNCTION f_get_compvisible(
      pcagente IN NUMBER,
      pcvisible IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_age_propiedades;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_PROPIEDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_PROPIEDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_PROPIEDADES" TO "PROGRAMADORESCSI";
