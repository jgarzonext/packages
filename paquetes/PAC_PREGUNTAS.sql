--------------------------------------------------------
--  DDL for Package PAC_PREGUNTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PREGUNTAS" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:       PAC_PREGUNTAS
      PROPÓSITO:    Funciones para realizar acciones sobre las tablas de PREGUNTAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        29/07/2009   RSC                1. Creación del package.
      2.0        20/11/2009   JMF                2. 0011914 CRE201 - Incidencia-ajuste en map PIAM Comú
      3.0        27/12/2010   APD                3. 0017105: Ajustes producto GROUPLIFE (III)
      4.0        09/12/2011   RSC                4. 0019312: LCOL_T004 - Parametrización Anulaciones
      5.0        13/01/2012   RSC                5. 0019715: LCOL: Migración de productos de Vida Individual
      6.0        01/02/2012   JRH                6.0020666: LCOL_T004-LCOL - UAT - TEC - Indicencias de Tarificaci?n
   ******************************************************************************/

   /*************************************************************************
     Función que devuelve el valor respuesta de una pregunta de garantía
     asociada a un contrato.

       param  in     psseguro : Id. seguro
       param  in     pcgarant : Id. garantía
       param  in     pnriesgo : Id. riesgo
       param  in     pcpregun : Id. de pregunta
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcrespue : Valor de la respuesta a la pregunta
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emisión
   FUNCTION f_get_pregungaranseg(
      psseguro IN seguros.sseguro%TYPE,
      pcgarant IN garanseg.cgarant%TYPE,
      pnriesgo IN garanseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      pcrespue OUT pregungaranseg.crespue%TYPE,
      -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
      psproces IN NUMBER DEFAULT NULL
                                     --  FiBUG 20666-  01/2012 - JRH
   )
      RETURN NUMBER;

-- Fin Bug 10757

   -- ini Bug 0011914 - 20/11/2009 - JMF
   /************************************************************************************
       FF_BUSCAPREGUNSEG: Busca respuesta de una pregunta de póliza
       Primero por fecha, sino por movimiento, sino busca el último mov.
       13/11/2009: JMF bug 0011914
   *************************************************************************************/
   FUNCTION ff_buscapregunseg(
      p_seg IN NUMBER,
      p_rie IN NUMBER,
      p_pre IN NUMBER,
      p_mov IN NUMBER,
      p_fec IN DATE DEFAULT NULL)
      RETURN VARCHAR2;

   -- fin Bug 0011914 - 20/11/2009 - JMF

   -- ini Bug 0011914 - 20/11/2009 - JMF
   /************************************************************************************
       FF_BUSCAPREGUNPOLSEG: Busca respuesta de una pregunta de póliza
       Primero por fecha, sino por movimiento, sino busca el último mov.
       27/08/2009: JMF bug 0010893
       13/11/2009: JMF bug 0011914
   *************************************************************************************/
   FUNCTION ff_buscapregunpolseg(
      p_seg IN NUMBER,
      p_pre IN NUMBER,
      p_mov IN NUMBER,
      p_fec IN DATE DEFAULT NULL,
      p_tablas IN VARCHAR2 DEFAULT 'POL')
      RETURN FLOAT;

-- fin Bug 0011914 - 20/11/2009 - JMF

   /*************************************************************************
     Función que devuelve el valor respuesta de una pregunta de poliza
     asociada a un contrato.

       param  in     psseguro : Id. seguro
       param  in     pcpregun : Id. de pregunta
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcrespue : Valor de la respuesta a la pregunta
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   -- Bug 17105 - APD- 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
   FUNCTION f_get_pregunpolseg(
      psseguro IN seguros.sseguro%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      pcrespue OUT pregunpolseg.crespue%TYPE)
      RETURN NUMBER;

-- Fin Bug 17105

   /*************************************************************************
     Función que devuelve el valor respuesta de una pregunta de riesgo
     asociada a un contrato.

       param  in     psseguro : Id. seguro
       param  in     pnriesgo : Id. riesgo
       param  in     pcpregun : Id. de pregunta
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcrespue : Valor de la respuesta a la pregunta
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   -- Bug 17105 - APD- 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
   FUNCTION f_get_pregunseg(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN pregunseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      pcrespue OUT pregunseg.crespue%TYPE)
      RETURN NUMBER;

-- Fin Bug 17105
   FUNCTION f_get_pregungaranseg_v(
      psseguro IN seguros.sseguro%TYPE,
      pcgarant IN garanseg.cgarant%TYPE,
      pnriesgo IN garanseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
      psproces IN NUMBER DEFAULT NULL
                                     --  FiBUG 20666-  01/2012 - JRH
   )
      RETURN NUMBER;

   /*************************************************************************
     Función que devuelve el valor respuesta de una pregunta de tipo texto de poliza
     asociada a un contrato.

       param  in     psseguro : Id. seguro
       param  in     pcpregun : Id. de pregunta
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcrespue : Valor de la respuesta a la pregunta
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migración de productos de Vida Individual
   FUNCTION f_get_pregunpolseg_t(
      psseguro IN seguros.sseguro%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      ptrespue OUT pregunpolseg.trespue%TYPE)
      RETURN NUMBER;

   FUNCTION f_get_pregunseg_t(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN pregunseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      ptrespue OUT pregunseg.trespue%TYPE)
      RETURN NUMBER;

   FUNCTION f_get_pregungaranseg_t(
      psseguro IN seguros.sseguro%TYPE,
      pcgarant IN garanseg.cgarant%TYPE,
      pnriesgo IN garanseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      ptrespue OUT pregungaranseg.trespue%TYPE,
      -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
      psproces IN NUMBER DEFAULT NULL
                                     --  FiBUG 20666-  01/2012 - JRH
   )
      RETURN NUMBER;

   /*************************************************************************
     Función que nos indica si una pregunta es de un plan

       param  in     pcpregun : Id. de pregunta
       param  in     psproduc  : ID del producto
       param  out    pesplan : 0- No pertenece 1 - pertenece
       return        : 0 todo OK
                       <> 0 algo KO

       Bug 27505/148732 - 19/07/2013 - AMC
   *************************************************************************/
   FUNCTION f_es_plan(
      pcpregun IN preguntas.cpregun%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pesplan OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        Función que nos devuelve las respuestas de las preguntas tipo tabla

          param  in     pcpregun : Id. de pregunta
          param  in     psseguro  : ID del seguro
          param  out    prespuestas: sys_refcursor con las respuestas
          return        : 0 todo OK
                          <> 0 algo KO

          Bug 27923/151007 - 27/08/2013 - AMC
      *************************************************************************/
   FUNCTION f_respuestas_pregtabla(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_traspaso_subtabs_seg(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pmodo IN VARCHAR2,
      pnlinea IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pcgarant IN NUMBER DEFAULT 0,
      pmens OUT NUMBER)
      RETURN NUMBER;
END pac_preguntas;

/

  GRANT EXECUTE ON "AXIS"."PAC_PREGUNTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PREGUNTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PREGUNTAS" TO "PROGRAMADORESCSI";
