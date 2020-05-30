--------------------------------------------------------
--  DDL for Package PAC_MD_ESC_RIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_ESC_RIESGO" AS
/******************************************************************************
   NOMBRE:     pac_md_esc_riesgo
   PROP¿SITO:  Funciones para realizar una conexi¿n
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/03/2017   ERH               1. Creaci¿n del package.
   2.0        11/03/2019   DFR               2. IAXIS-2016: Scoring
******************************************************************************/
	 /**********************************************************************
      FUNCTION F_GRABAR_ESCALA_RIESGO
      Funci¿n que almacena los datos de la escala de riesgo.
      Firma (Specification)
      Param IN pcescrie: cescrie
      Param IN  pndesde: ndesde
	    Param IN  pnhasta: nhasta
      Param IN pindicad: indicad
      Param OUT mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
      FUNCTION f_grabar_escala_riesgo(
         pcescrie IN NUMBER,
          pndesde IN NUMBER,
		      pnhasta IN NUMBER,
         pindicad IN VARCHAR2,
          mensajes IN OUT T_IAX_MENSAJES )
          RETURN NUMBER;


	 /**********************************************************************
      FUNCTION F_GET_ESCALA_RIESGO
      Funci¿n que retorna los datos de la escala de riesgo
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_escala_riesgo(
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;

   -- Inicio IAXIS-2016: Scoring 11/03/2019
   /**********************************************************************
      FUNCTION F_CALCULA_MODELO
      Funci¿n que genera el calculo modelo de SCORING
      Firma (Specification):
      Param IN  psperson: sperson
      Param IN  psproduc: sproduc
      Param IN   pccanal: ccanal
     **********************************************************************/
       FUNCTION f_calcula_modelo(
        psperson IN NUMBER,
        psproduc IN NUMBER,
        pcagente IN NUMBER,
        pcdomici IN NUMBER,
        mensajes IN OUT T_IAX_MENSAJES )
       RETURN NUMBER;
    -- Fin IAXIS-2016: Scoring 11/03/2019
     /**********************************************************************
      FUNCTION F_GET_SCORING_GENERAL
      Funci¿n que retorna los datos de scoring por persona.
      Param IN    psperson : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_scoring_general(
          psperson IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;

       -- Pasa de t_ob_errores a T_IAX_MENSAJES
   FUNCTION f_traspasar_errores_mensajes(errores IN t_ob_error)
      RETURN t_iax_mensajes;

END pac_md_esc_riesgo;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ESC_RIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ESC_RIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ESC_RIESGO" TO "PROGRAMADORESCSI";
