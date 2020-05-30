--------------------------------------------------------
--  DDL for Package PAC_LISTARESTRINGIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LISTARESTRINGIDA" 
IS
   /******************************************************************************
    NAME:        PAC_PROPIO_LRI
    PURPOSE:
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
     1.0        15/10/2012  JLB             1. Created this package body.
   */
   --  TYPE  lista_sperson IS TABLE OF number  INDEX BY BINARY_INTEGER;

   /*************************************************************************
                             FUNCTION f_set_seguro_listarestringida
        Función que inserta en la tabla lre_personas
        pspersonas in varchar2: Lista de personas
        pcclalis in number: Clase de lista
        pctiplis in number: Tipo de lista
        pcnotifi in number: Indicador de si hay que notificar o no la inserción en la lista.
        psperlre in number: Identificador de persona restringida
        pfexclus in date: Fecha de exclusión
        pfinclus in date: Fecha de inclusión
        pcinclus in number: Código motivo de inclusión
        return number: 0 -ok , otro valor ERROR
     *************************************************************************/
   FUNCTION f_set_listarestringida(
      psperson       IN       NUMBER,
      pcclalis       IN       NUMBER,
      pctiplis       IN       NUMBER,
      pcnotifi       IN       NUMBER,
      psperlre_out   OUT      NUMBER,
      psperlre       IN       NUMBER,
      pfexclus       IN       DATE,
      pfinclus       IN       DATE,
      pcinclus       IN       NUMBER,
      psseguro       IN       NUMBER,  -- Bug 31411/175020 - 16/05/2014 - AMC
      pnmovimi       IN       NUMBER,
      pnsinies       IN       NUMBER,
      pcaccion       IN       NUMBER,
      pnrecibo       IN       NUMBER,
      psmovrec       IN       NUMBER,
      psdevolu       IN       NUMBER,
      pfnacimi       IN       DATE,
      ptdescrip      IN       VARCHAR2, --Se incluye campo tdescrip, AMA-232
      ptobserv       IN       VARCHAR2,
      ptmotexc       IN       VARCHAR2
   )
      RETURN NUMBER;

   /*************************************************************************
                                FUNCTION f_valida_LISTARESTRINGIDA
        Función que recorrerá GARANPRO_VALIDACION y recuperará las funciones que de validación que se han definido
        para las garantías seleccionadas.
        psseguro in number: identificador del seguro
        pnmovimi in number: número de movimiento
        pmensa  out number: parámetro de entrada/salida
        return number: retorno de la función F_VALIDA_LRI
     *************************************************************************/
   FUNCTION f_valida_listarestringida(
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnsinies   IN   NUMBER,
      pcaccion   IN   NUMBER,
      pnrecibo   IN   NUMBER,          -- Bug 31411/175020 - 16/05/2014 - AMC
      psmovrec   IN   NUMBER,
      psdevolu   IN   NUMBER
   )
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION f_get_listarestringida
       Función que recupera las listas restringidas

       return lista de personas restringidas

       Bug 23824/124452 - 31/10/2012 - AMC
    *************************************************************************/
   FUNCTION f_get_listarestringida(
      pctipper        IN   NUMBER,
      pctipide        IN   NUMBER,
      pnnumide        IN   VARCHAR2,
      ptnomape        IN   VARCHAR2,
      pcclais         IN   NUMBER,
      pctiplis        IN   NUMBER,
      pfinclusdesde   IN   DATE,
      pfinclushasta   IN   DATE,
      pfexclusdesde   IN   DATE,
      pfexclushasta   IN   DATE,
      psperlre        IN   NUMBER,
      pcidioma        IN   NUMBER,
      pfnacimi        IN   DATE,
      ptdescrip       IN   VARCHAR2 --Se incluye campo tdescrip, AMA-232
   )
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_existepersona
      Función que recupera si existe una persona en la lista restringida

       return number: 0 -ok , otro valor ERROR

      Bug 23824/124452 - 06/11/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_existepersona(
      psperson   IN   NUMBER,
      pcclalis   IN   NUMBER,
      pctiplis   IN   NUMBER,
      pcinclus   IN   NUMBER
   )
      RETURN NUMBER;

   /*************************************************************************
     BUG 25965 - inicio FAC - 14/02/2013
     FUNCTION f_set_listarestringida_aut
      FunciÃ³n que inserta en la tabla lre_autos
      psmatric in varchar2: Lista de Placas
      pcodmotor IN VARCHAR2: codigo de motor
      pcchasis IN VARCHAR2,: codigo de chasis
      pnbastid IN VARCHAR2: codigo VIN o Nbastidor
      pcclalis in number: Clase de lista
      pctiplis in number: Tipo de lista
      pcnotifi in number: Indicador de si hay que notificar o no la inserciÃ³n en la lista.
      psmatrilre in number: Identificador de matricula restringida
      pfexclus in date: Fecha de exclusiÃ³n
      pfinclus in date: Fecha de inclusiÃ³n
      pcinclus in number: CÃ³digo motivo de inclusiÃ³n
      return number: 0 -ok , otro valor ERROR
   *************************************************************************/
   FUNCTION f_set_listarestringida_aut(
      psmatric          IN       VARCHAR2,
      pcodmotor         IN       VARCHAR2,
      pcchasis          IN       VARCHAR2,
      pnbastid          IN       VARCHAR2,
      pcclalis          IN       NUMBER,
      pctiplis          IN       NUMBER,
      pcnotifi          IN       NUMBER,
      psmatriclre_out   OUT      NUMBER,
      psmatriclre       IN       NUMBER,
      pfexclus          IN       DATE,
      pfinclus          IN       DATE,
      pcinclus          IN       NUMBER,
      psseguro          IN       NUMBER,
                                       -- Bug 31411/175020 - 16/05/2014 - AMC
      pnmovimi          IN       NUMBER,
      pnsinies          IN       NUMBER,
      pcaccion          IN       NUMBER,
      pnrecibo          IN       NUMBER,
      psmovrec          IN       NUMBER,
      psdevolu          IN       NUMBER
   )
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_listarestringida_aut
       Funcion que recupera las listas restringidas de autos
       return lista de autos restringidos
       Bug 26923/152307 - 10/09/2013 - AMC
    *************************************************************************/
   FUNCTION f_get_listarestringida_aut(
      pcmatric        IN   VARCHAR2,
      pcodmotor       IN   VARCHAR2,
      pcchasis        IN   VARCHAR2,
      pnbastid        IN   VARCHAR2,
      pcclalis        IN   NUMBER,
      pctiplis        IN   NUMBER,
      pfinclusdesde   IN   DATE,
      pfinclushasta   IN   DATE,
      pfexclusdesde   IN   DATE,
      pfexclushasta   IN   DATE,
      pcidioma        IN   NUMBER,
      psmatriclre     IN   NUMBER
   )
      RETURN VARCHAR2;

    /*************************************************************************
      FUNCTION f_get_existeauto
      Funcion que recupera si existe un auto en la lista restringida
      return number: 0 -ok , otro valor ERROR
      Bug 26923/152307 - 10/09/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_existeauto(
      pcmatric   IN   VARCHAR2,
      pcclalis   IN   NUMBER,
      pctiplis   IN   NUMBER,
      pcinclus   IN   NUMBER
   )
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION proc_accion_lre
      Procedimiento que recupera la acción activa
      return number: 0 -ok , otro valor ERROR
      Bug 38745/219383 - 04/12/2015 - YDA
   *************************************************************************/
   PROCEDURE proc_accion_lre(
      p_cempres       IN       NUMBER,
      p_cmotmov       IN       NUMBER,
      p_ctiplis       IN       NUMBER,
      p_email         OUT      BOOLEAN,
      p_underwriter   OUT      BOOLEAN,
      p_mlro          OUT      BOOLEAN,
      p_agenda        OUT      BOOLEAN,
      p_block         OUT      BOOLEAN
   );

   /*************************************************************************
      FUNCTION f_valida_accion_lre
      Procedimiento que recupera las listas activas de una persona
      return number: 0 -ok , otro valor ERROR
      Bug 38745/219383 - 04/12/2015 - YDA
   *************************************************************************/
   FUNCTION f_valida_accion_lre(
      p_cempres   IN   NUMBER,
      p_cidioma   IN   NUMBER,
      p_sseguro   IN   NUMBER,
      p_sperson   IN   NUMBER,
      p_cmotmov   IN   NUMBER,
      p_fecha     IN   DATE DEFAULT f_sysdate
   )
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_get_historico_persona
      Función que recupera los datos históricos de una persona en lista restringida
      return cursor
      Bug CONF-239 JAVENDANO 01/09/2016
   *************************************************************************/
    FUNCTION f_get_historico_persona(
      pnnumide    IN       VARCHAR2
    )
    RETURN SYS_REFCURSOR;
-- IGIL CONFCC-7 INI
  FUNCTION f_consultar_compliance(
    p_sperson IN NUMBER,
    p_nnumide IN VARCHAR2,--NUMBER,Inc 1887 CONF KJSC
    p_nombre IN VARCHAR2,
    p_ctipide IN NUMBER,
    p_ctipper IN NUMBER
  ) RETURN NUMBER;
  PROCEDURE parsear (p_clob IN CLOB, p_parser IN OUT xmlparser.parser);
-- IGIL CONFCC-7 FIN
END pac_listarestringida;

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTARESTRINGIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTARESTRINGIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTARESTRINGIDA" TO "PROGRAMADORESCSI";
