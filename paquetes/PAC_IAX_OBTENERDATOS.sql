--------------------------------------------------------
--  DDL for Package PAC_IAX_OBTENERDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_OBTENERDATOS" 
IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_OBTENERDATOS
      PROPÓSITO: Recupera la información de la poliza guardada en la base de datos
                 a un nivel independiente.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        16/12/2009   RSC                1. Creación del package.
      2.0        27/01/2010   RSC                2. 0011735: APR - suplemento de modificación de capital /prima
      3.0        23/06/2010   RSC                3. 0014598: CEM800 - Información adicional en pantallas y documentos
      4.0        06/08/2010   PFA                4. 14598: CEM800 - Información adicional en pantallas y documentos
      6.0        21/05/2015   YDA                6. Se crea la función f_evoluprovmatseg_scen y se incluye el parametro pnscenario en f_leeevoluprovmatseg
      7.0        04/06/2015   YDA                7. Se crea la función f_evoluprovmatseg_minscen
      8.0        03/07/2015   YDA                8. 0036596: Se crea la función f_get_exclusiones
      9.0        05/08/2015   YDA                9. 0036596: Se crea la función f_lee_enfermedades
      10.0       10/08/2015   YDA                10.0036596: Se crea la función f_lee_preguntas
      11.0       12/08/2015   YDA                11.0036596: Se crea la función f_lee_acciones
   ******************************************************************************/

   /*************************************************************************
    Bug 10690 - Nueva seccion en la consulta de póliza. Provisiones por garantía.
      param IN sseguro : mesajes de error
      param out mensajes : mesajes de error
      return             : objeto detalle garantías
   *************************************************************************/
   -- Bug 10690 - 16/12/2009 - RSC - APR - Provisiones en productos de cartera (PORTFOLIO)
   FUNCTION f_leeprovisionesgar (
      psseguro   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_garantias;

   /*************************************************************************
    Bug 10690 - Nueva seccion en la consulta de póliza. Provision por póliza.
      param IN sseguro : mesajes de error
      param out mensajes : mesajes de error
      return             : objeto detalle garantías
   *************************************************************************/
   -- Bug 10690 - 16/12/2009 - RSC - APR - Provisiones en productos de cartera (PORTFOLIO)
   FUNCTION f_leeprovisionpol (psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_datoseconomicos;

   /*************************************************************************
      Recuperar la información de las garantias
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : objeto garantias
   *************************************************************************/
   -- Bug 11735 - RSC - 27/01/2010 - APR - suplemento de modificación de capital /prima
   FUNCTION f_leegarantias_supl (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_garantias;

-- Fin Bug 11735

   /*************************************************************************
      Recuperar la información de evoluprovmatseg
      param in sseguro   : número de seguro
      param in ptablas   : tablas a consultar
      param out mensajes : mesajes de error
      return             : objeto garantias
   *************************************************************************/
   -- Bug 14598 - RSC - 23/06/2010 - CEM800 - Información adicional en pantallas y documentos
   -- Bug 14598 - PFA - 06/08/2010 - añadir parametro ptablas
   FUNCTION f_leeevoluprovmatseg (
      psseguro     IN       NUMBER,
      ptablas      IN       VARCHAR2,
      pnscenario   IN       NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN t_iax_evoluprovmat;

-- Fin Bug 14598

   /*************************************************************************
      Devuelve el capital de una garantia
      param in psseguro   : numero de seguro
      param in pnriesgo   : numero de riesgo
      param in pcgarant   : codigo de la garantia
      param in ptablas    : tablas donde hay que ir a buscar la información
      param out mensajes : mesajes de error
      return             : Impporte del capital

      Bug 18342 - 24/05/2011 - AMC
   *************************************************************************/
   FUNCTION f_leecapital (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pcgarant   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   /*************************************************************************
     funcion que retorna los cuadros de amortizacion de un prestamo.
     param psseguro : codigo del seguro
     param mensajes : mensajes registrados en el proceso
     return : t_iax_prestcuadroseg tabla PL con objetos de cuadro de prestamo
     Bug 35712 mnustes
   *************************************************************************/
   FUNCTION f_lee_prestcuadroseg (
      psseguro   IN       seguros.sseguro%TYPE,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_prestcuadroseg;

   /*************************************************************************
          Recupera los escenarios de proyeccion de intereses
          param out mensajes : mensajes de error
          return : ref cursor

             11/05/2015   YDA                Mant. Pers. Bug: 34636/202063
   *************************************************************************/
   FUNCTION f_evoluprovmatseg_scen (
      psseguro   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera mínimo escenario de proyecciones de interes
      param out mensajes : mesajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_evoluprovmatseg_minscen (
      psseguro   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

   /*************************************************************************
      Devuelve las exclusiones de una póliza
      param in psseguro   : numero de seguro
      param in pnriesgo   : numero de riesgo
      param in ptablas    : tablas donde hay que ir a buscar la información
      param out mensajes  : mesajes de error
      return              : Tabla de exclusiones

      Bug 36596/208854 - YDA
   *************************************************************************/
   FUNCTION f_get_exclusiones (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_exclusiones;

   /*************************************************************************
      Recuperar la informacion de las enfermedades
   *************************************************************************/
   FUNCTION f_lee_enfermedades (
      psseguro   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_enfermedades_undw;

   /*************************************************************************
      Recupera la informacion de las preguntas base
   *************************************************************************/
   FUNCTION f_lee_preguntas (psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_basequestion_undw;

   /*************************************************************************
      Recupera la informacion de las acciones de los asegurados
   *************************************************************************/
   FUNCTION f_lee_acciones(
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes
   ) RETURN t_iax_actions_undw;
END pac_iax_obtenerdatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_OBTENERDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_OBTENERDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_OBTENERDATOS" TO "PROGRAMADORESCSI";
