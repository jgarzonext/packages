--------------------------------------------------------
--  DDL for Package PAC_MD_LISTASRESTRINGIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_LISTASRESTRINGIDA" IS
   /******************************************************************************
    NOMBRE:      PAC_MD_LISTASRESTRINGIDA
    PROP真SITO:   Funciones para las listas restringidas

    REVISIONES:
    Ver        Fecha        Autor             Descripci真n
    ---------  ----------  ---------------  ------------------------------------
    1.0        31/10/2012  AMC               1. Creaci真n del package.
   ******************************************************************************/

   /*************************************************************************
       FUNCTION f_get_listarestringida
       Funci真n que recupera las listas restringidas

       return lista de personas restringidas

       Bug 23824/124452 - 31/10/2012 - AMC
    *************************************************************************/
   FUNCTION f_get_listarestringida(
      pctipper IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnomape IN VARCHAR2,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pfinclusdesde IN DATE,
      pfinclushasta IN DATE,
      pfexclusdesde IN DATE,
      pfexclushasta IN DATE,
      psperlre IN NUMBER,
      pfnacimi IN DATE,
      ptdescrip IN VARCHAR2, --Se incluye campo tdescrip, AMA-232
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      FUNCTION f_set_listarestringida
      Funci真n que inserta en la tabla lre_personas
      pspersonas in varchar2: Lista de personas
      pcclalis in number: Clase de lista
      pctiplis in number: Tipo de lista
      pcnotifi in number: Indicador de si hay que notificar o no la inserci真n en la lista.
      psperlre in number: Identificador de persona restringida
      pfexclus in date: Fecha de exclusi真n
      pfinclus in date: Fecha de inclusi真n
      pcinclus in number: C真digo motivo de inclusi真n
      mensajes in out : Mensajes de error
      return number: 0 -ok , otro valor ERROR
   *************************************************************************/
   FUNCTION f_set_listarestringida(
      psperson IN NUMBER,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pcnotifi IN NUMBER,
      psperlre IN NUMBER,
      pfexclus IN DATE,
      pfinclus IN DATE,
      pcinclus IN NUMBER,
      pfnacimi IN DATE,
      ptdescrip IN VARCHAR2, --Se incluye campo tdescrip, AMA-232
      ptobserv IN VARCHAR2,
      ptmotexc IN VARCHAR2,
      psperlre_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes
      )
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_listarestringida_aut
      Funci真n que recupera las listas restringidas de autos

      return lista de autos restringidos

      Bug 26923/152307 - 10/09/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_listarestringida_aut(
      pcmatric IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pfinclusdesde IN DATE,
      pfinclushasta IN DATE,
      pfexclusdesde IN DATE,
      pfexclushasta IN DATE,
      psmatriclre IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      FUNCTION f_set_listarestringida_aut
       Funcion que inserta en la tabla lre_autos
       psmatric in varchar2: Lista de Placas
       pcodmotor IN VARCHAR2: codigo de motor
       pcchasis IN VARCHAR2,: codigo de chasis
       pnbastid IN VARCHAR2: codigo VIN o Nbastidor
       pcclalis in number: Clase de lista
       pctiplis in number: Tipo de lista
       pcnotifi in number: Indicador de si hay que notificar o no la inserci真真n en la lista.
       psmatrilre in number: Identificador de matricula restringida
       pfexclus in date: Fecha de exclusi真真n
       pfinclus in date: Fecha de inclusi真真n
       pcinclus in number: C真真digo motivo de inclusi真真n
       return number: 0 -ok , otro valor ERROR

       Bug 26923/152307 - 10/09/2013 - AMC
    *************************************************************************/
   FUNCTION f_set_listarestringida_aut(
      psmatric IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pcnotifi IN NUMBER,
      psmatriclre IN NUMBER,
      pfexclus IN DATE,
      pfinclus IN DATE,
      pcinclus IN NUMBER,
      psmatriclre_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_get_historico_persona
      Funci真n que recupera los datos hist真ricos de una persona en lista restringida
      return cursor
      Bug CONF-239 JAVENDANO 01/09/2016
   *************************************************************************/
    FUNCTION f_get_historico_persona(
      pnnumide    IN       VARCHAR2,
      mensajes    OUT	   T_IAX_MENSAJES
    )
    RETURN SYS_REFCURSOR;
END pac_md_listasrestringida;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTASRESTRINGIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTASRESTRINGIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTASRESTRINGIDA" TO "PROGRAMADORESCSI";
