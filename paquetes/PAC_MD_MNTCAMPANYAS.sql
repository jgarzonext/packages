--------------------------------------------------------
--  DDL for Package PAC_MD_MNTCAMPANYAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_MNTCAMPANYAS" IS
/******************************************************************************
    NOMBRE:      PAC_MD_MNTCAMPANYAS
    PROPÓSITO:   Funciones para la gestión de campañas

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        08/05/2013   AMC       1. Creación del package. Bug 26615/143210
******************************************************************************/

   /**********************************************************************************************
      Función para recuperar campañas
      param in pccampanya:    codigo campaña
      param in ptcampanya:    descripción de campaña
      param out campanyas:  t_iax_ campanyas,
      param out mensajes:     mensajes informativos


      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanyas(
      pccampanya IN NUMBER,   -- codigo campaña
      ptcampanya IN VARCHAR2,   -- Deripción de la campaña
      pcampanyas OUT t_iax_campanyas,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para recuperar una campanya
      param in pccampanya:    codigo campaña
      param in ptodo:         Recupera todos los idiomas o solo los informados
      param out campanyas:     t_iax_ campanyas,
      param out mensajes:        mensajes informativos


      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanya(
      pccampanya IN NUMBER,   -- codigo campaña
      ptodo IN NUMBER,
      pcampanya OUT t_iax_campanyas,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/**********************************************************************************************
      Función para recuperar campañas
      param in pccampanya:    codigo campaña
      param in ptcampanya:    descripción de campaña
      param in pcidioma: código de idioma
      param out mensajes:        mensajes informativos


      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_campanyas(
      pccampanya IN NUMBER,   -- codigo campaña
      ptcampanya IN VARCHAR2,   -- Deripción de la campaña
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**********************************************************************************************
      Función para borrar campanyas
      param in pccampanya:   codigo campaña
      param out mensajes:    mensajes informativos

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_campanya(
      pccampanya IN NUMBER,   -- codigo campaña
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para borrar una descriccion de la campanya
      param in pccampanya:   codigo campaña
      param in pcidioma: código de idioma
      param out mensajes:    mensajes informativos

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_campanya_lin(
      pccampanya IN NUMBER,   -- codigo campaña
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_mntcampanyas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTCAMPANYAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTCAMPANYAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTCAMPANYAS" TO "PROGRAMADORESCSI";
