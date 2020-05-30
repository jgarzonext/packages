--------------------------------------------------------
--  DDL for Package PAC_IAX_AGE_PROPIEDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_AGE_PROPIEDADES" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_AGE_PROPIEDADES
      PROPOSITO: Funciones para gestionar los parametros de los agentes

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        08/03/2012  AMC               1. Creaci�n del package.

   ******************************************************************************/
   paragentes     t_iax_par_agentes;

    /*************************************************************************
        Inserta el parametre per agent
        param in pcagente   : Codi agent
        param in pcparam    : Codi parametre
        param in pnvalpar   : Resposta numerica
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Inserta el parametre per agente
        param in pcagente   : Codi agent
        return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_grabar_paragente(pcagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Esborra el parametre per agent
        param in pcagente   : Codi agent
        param in pcparam    : Codi parametre
        return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_paragente(
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Obté la select amb els parametres per agente
     param in pcagente   : Codi agent
     param in ptots      : 0.- Només retorna els paràmetres contestats
                           1.- Retorna tots els paràmetres
     param out pcur      : Cursor
     return              : 0.- OK, 1.- KO
     *************************************************************************/
   FUNCTION f_get_paragente_ob(
      pcagente IN NUMBER,
      ptots IN NUMBER,
      pparage OUT t_iax_par_agentes,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Obté la select amb els paràmetres per agente
      param in pcagente   : Codi agent
      param in ptots      : 0.- Només retorna els paràmetres contestats
                            1.- Retorna tots els paràmetres
      param out pcur      : Cursor
      return              : 0.- OK, 1.- KO
      *************************************************************************/
   FUNCTION f_get_paragente(
      pcagente IN NUMBER,
      ptots IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_age_propiedades;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_PROPIEDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_PROPIEDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_PROPIEDADES" TO "PROGRAMADORESCSI";
