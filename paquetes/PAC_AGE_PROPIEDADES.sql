--------------------------------------------------------
--  DDL for Package PAC_AGE_PROPIEDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_AGE_PROPIEDADES" IS
   /******************************************************************************
      NOMBRE:       PAC_AGE_PROPIEDADES
      PROPÃ“SITO: Funciones para gestionar los parametros de los agentes

      REVISIONES:
      Ver        Fecha        Autor             DescripciÃ³n
      ---------  ----------  ---------------  ------------------------------------
      1.0        08/03/2012  AMC               1. Creación del package.

   ******************************************************************************/

   /*************************************************************************
   Inserta el paràmetre per agent
   param in psperson   : Codi agent
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
      pfvalpar IN DATE)
      RETURN NUMBER;

    /*************************************************************************
    Esborra el paràmetre per agent
    param in psperson   : Codi agent
    param in pcparam    : Codi parametre
    return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_paragente(pcagente IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Obté la select amb els paràmetres per agent
   param in pcagente   : Codi agent
   param in pidioma    : Codi idioma
   param in ptots      : 0.- Només retorna els paràmetres contestats
                         1.- Retorna tots els paràmetres
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_paragente(
      pcagente IN NUMBER,
      pidioma IN NUMBER,
      ptots IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Obté la select amb els paràmetres per agent
      pcparam IN NUMBER,
      pcidioma in number,
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_obparagente(pcparam IN VARCHAR2, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Funcio per comprobar si una propietat es visible per l'agent
      pcagente IN NUMBER,
      pcvisible in texto, funcion para comprobar la visivilidad

   return              : 0.- No visible, 1.- Visible
   *************************************************************************/
   FUNCTION f_get_compvisible(pcagente IN NUMBER, pcvisible IN VARCHAR2)
      RETURN NUMBER;
END pac_age_propiedades;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGE_PROPIEDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_PROPIEDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_PROPIEDADES" TO "PROGRAMADORESCSI";
