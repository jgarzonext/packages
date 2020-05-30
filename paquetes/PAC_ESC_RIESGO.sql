--------------------------------------------------------
--  DDL for Package PAC_ESC_RIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ESC_RIESGO" AS

  	/******************************************************************************
	  NOMBRE:     PAC_ESC_RIESGO
	  PROP¿SITO:  Package que contiene las funciones de Escala de riesgo

	  REVISIONES:
	  Ver        Fecha        Autor             Descripci¿n
	  ---------  ----------  ---------------  ------------------------------------
	  1.0        23/03/2017   ERH               1. Creaci¿n del package.

	******************************************************************************/


    /**********************************************************************
      FUNCTION F_GRABAR_ESCALA_RIESGO
      Funci¿n que almacena los datos de la escala de riesgo.
      Firma (Specification)
	  Param IN pcesrie: cesrie
      Param IN pndesde: ndesde
	  Param IN pnhasta: nhasta
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
      FUNCTION f_get_escala_riesgo
      RETURN sys_refcursor;


     /**********************************************************************
      FUNCTION F_GET_SCORING_GENERAL
      Funci¿n que retorna los datos de scoring por persona.
      Param IN    psperson : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_scoring_general(
        psperson IN NUMBER)
      RETURN sys_refcursor;


END PAC_ESC_RIESGO;

/

  GRANT EXECUTE ON "AXIS"."PAC_ESC_RIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ESC_RIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ESC_RIESGO" TO "PROGRAMADORESCSI";
