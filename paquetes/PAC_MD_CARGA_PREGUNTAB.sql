--------------------------------------------------------
--  DDL for Package PAC_MD_CARGA_PREGUNTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_CARGA_PREGUNTAB" IS
/*******************************************************************************
   NOMBRE:       pac_md_carga_preguntab
   PROP¿SITO: Funciones para la carga de preguntas de tipo tabla

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ----------  ------------------------------------
   1.0        13/2/2015   AMC                1. Creaci¿n del package.
*******************************************************************************/

   /***********************************************************************
      Recupera los datos del riesgo (preguntas)
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in psimul    : indicador de simulacion
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_preguntab_rie(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2,
      psproduc IN NUMBER,
      psproces_out IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntastab;

   /***************************************************************************
        procedimiento que ejecuta una carga
        param in p_nombre   : Nombre fichero
        param in  out psproces   : N¿mero proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
     **************************************************************************/
   FUNCTION f_ejecutar_carga_preguntab(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_cpregun IN NUMBER,
      p_nmovimi IN NUMBER,
      ptablas IN VARCHAR2,
      psproces IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_borrar_carga(
      psseguro IN NUMBER,
      pcpregun IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_validar_carga(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_cargas_validadas(
      psseguro IN NUMBER,
      pemitir IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_carga_preguntab;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_PREGUNTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_PREGUNTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_PREGUNTAB" TO "PROGRAMADORESCSI";
