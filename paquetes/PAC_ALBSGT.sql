--------------------------------------------------------
--  DDL for Package PAC_ALBSGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ALBSGT" AUTHID CURRENT_USER IS
   /***************************************************************
       NAME:       PAC_ALBSGT
       PURPOSE:    Especificación del paquete de las funciones
       utilizadas para la generación de preguntas que posteriormente
       se utilizaran en el SGT
       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        ??/??/????  ???              1. Created this package.
       2.0        02/05/2011  SRA              2. 0018345: LCOL003 - Validación de garantías dependientes de respuestas u otros factores
       3.0        20/05/2011  APD              3. 0018362: LCOL003 - Parámetros en cláusulas y visualización cláusulas automáticas
       4.0        22/11/2012  MDS              4. 0024657: MDP_T001-Pruebas de Suplementos
   ***************************************************************/
   cerror         NUMBER;

   FUNCTION f_tprefor(
      ptprefor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      resultat OUT NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1,
      picapital IN NUMBER DEFAULT 0,
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

--**************************************************************************************
--Función para la validación de la formula para preguntas
-- BUG 7643
--**************************************************************************************
   FUNCTION f_tvalfor(
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2,
      ptvalfor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      resultat OUT NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1,
      picapital IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   -- FIN BUG 7643

   -- Ini bug 18345 - SRA - 02/05/2011
   /*************************************************************************
                     FUNCTION f_tvalfor
      Compone dinámicamente la llamada a la función que ha de realizar una validación sobre la garantía seleccionada,
      según se han definido estas validaciones en GARANPROVAL
      ptvalfor in varchar2: función/query que se va llamar
      ptablas  in varchar2: tipo de tablas (EST)
      psseguro in number: identificador del seguro
      pnriesgo in number: número del riesgo
      pnmovimi in number: número de movimiento
      pcgarant in number: código de la garantía
      pcactivi in number: código de la actividad
      resultat out number: resultado de la validación
      return       number: retorno de la función f_tvalfor
   *************************************************************************/
   FUNCTION f_tvalgar(
      ptvalfor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      resultat OUT NUMBER)
      RETURN NUMBER;

   -- Fi bug 18345 - SRA - 02/05/2011

   --**************************************************************************************
--Función para la validación de la formula para parametros de clausulas
-- BUG 18362
--**************************************************************************************
   FUNCTION f_tvalclau(
      ptvalclau IN VARCHAR2,
      psclagen IN NUMBER,
      pnparame IN NUMBER,
      ptvalor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      resultat OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
                         F_TVAL_DOCUREQ
       Devuelve el resultado de la ejecución dinámica de una función relacionada
       con la documentación requerida.
       param in ptfuncio                : función a ejecutar
       param in ptablas                 : tablas a consultar (temporales o definitivas)
       param in pcactivi                : código de actividad
       param in psseguro                : número secuencial de seguro
       param in pnmovimi                : número de movimiento
       param out presult                : resultado de la ejecución
       return                           : 0 todo correcto
                                          1 ha habido un error
       BUG 18351 - 11/05/2011 - JMP - Se añade la función
    *************************************************************************/
   FUNCTION f_tval_docureq(
      ptfuncio IN VARCHAR2,
      ptablas IN VARCHAR2,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      -- Ini Bug 24657 - MDS - 22/11/2012
      pnriesgo IN NUMBER,
      psperson IN NUMBER,
      -- Fin Bug 24657 - MDS - 22/11/2012
      presult OUT NUMBER)
      RETURN NUMBER;

   /***************************************************************************************
                  -- Función para la validación de la formula para listas restringidas
          param in ptvalfor                : función a ejecutar
          param in ptablas                 : tablas a consultar (temporales o definitivas)
          param in psseguro                : número secuencial de seguro
          param in pnmovimi                : número de movimiento
          param in psperson                : persona a evaluar candidata a lista restringida
          param out presult                : 0 - No se debe inclurir en lista restringida , 1 se debe incluir
          return                           : 0 todo correcto
                                             1 ha habido un error
   -- BUG 23823
   ******************************************************************************************/
   FUNCTION f_tvallre(
      ptvalfor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER,
      pnsinies IN NUMBER,
      resultat OUT VARCHAR2)
      RETURN NUMBER;
END pac_albsgt;

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT" TO "PROGRAMADORESCSI";
