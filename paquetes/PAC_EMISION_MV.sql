--------------------------------------------------------
--  DDL for Package PAC_EMISION_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_EMISION_MV" AUTHID CURRENT_USER IS
/****************************************************************************
   NOMBRE:       PAC_EMISION_MV
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        ********    **               1. Creación del package.
   2.0        13/03/2009  DRA              0009448: IAX - Retenció de pòlisses al realitzar un suplement d'augment de capital si preguntes afirmatives qüestionari
   3.0        30/03/2009  DRA              0009640: IAX - Modificar missatge de retenció de pòlisses pendents de facultatiu
****************************************************************************/
   PROCEDURE p_control_antes_emision(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pnmovimi IN NUMBER,
      pcreteni OUT NUMBER,
      perror OUT NUMBER,
      terror OUT VARCHAR);

   FUNCTION p_cobro_recibo(
      pnrecibo IN NUMBER,
      ptipocobro IN NUMBER,
      pcbancar IN VARCHAR2,
      poficina IN NUMBER,
      pusuario IN VARCHAR2,
      paut IN OUT NUMBER,
      phost OUT NUMBER,
      terror OUT VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_retener_poliza(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER,
      pcreteni IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER;

   -- BUG9448:13/03/2009:DRA
   /*************************************************************************
      Analiza si queda retenida por aumento de capital con preguntas afirmativas
      param in psseguro     : codigo del seguro
      param in pnmovimi     : numero de movimiento
      param in pfecha       : Fecha
      param out pnerror     : indica si hay error
      param out pterror     : devuelve el texto de error
      param out papto       : indica si es apto o no
      return NUMBER         : 0 todo ha ido bien;  1 han habido errores
   *************************************************************************/
   FUNCTION f_control_capital_respuesta(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      pfecha IN DATE,
      pnerror OUT NUMBER,
      pterror OUT VARCHAR2,
      papto OUT NUMBER)
      RETURN NUMBER;

   -- BUG9640:30/03/2009:DRA
   /*************************************************************************
      Analitza els error al emitir i retorna el motiu de retenció i el literal a mostrar
      param in  p_sseguro     : id. del seguro
      param in  p_sproduc     : id. del producto
      param in  p_indice      : indicador de la emision
      param in  p_indice_e    : indicador de error en la emision
      param in  p_cmotret     : codigo del motivo de retencion
      param in  p_cidioma     : codigo del idioma
      param out p_tmotret     : mensaje del error
      return NUMBER           : 0 --> OK   1 --> KO
   *************************************************************************/
   FUNCTION f_texto_emision(
      p_sseguro IN NUMBER,
      p_indice IN NUMBER,
      p_indice_e IN NUMBER,
      p_cmotret IN NUMBER,
      p_cidioma IN NUMBER,
      p_tmensaje OUT VARCHAR2)
      RETURN NUMBER;
END pac_emision_mv;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_EMISION_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_EMISION_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_EMISION_MV" TO "PROGRAMADORESCSI";
