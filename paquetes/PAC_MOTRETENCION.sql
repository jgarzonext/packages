--------------------------------------------------------
--  DDL for Package PAC_MOTRETENCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MOTRETENCION" AS
/******************************************************************************
  Package para la gestión de retenidas
******************************************************************************/
   FUNCTION f_max_nmotrev(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotret IN NUMBER,
      pnmotret IN NUMBER,
      pfusuauto IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_desretener(psseguro IN NUMBER, pnmovimi IN NUMBER, pobserva IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_risc_retingut(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotret IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_estado_autorizacion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotret IN NUMBER,
      pnmotret IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_sit_reten(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER;

   FUNCTION f_retencion_provisional(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_esta_retenica_sin_resc(psseguro IN NUMBER, pfecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;

   /******************************************************************************************
     Autor: XVILA (09/01/2009)
     Descripció: Executa una consulta sobre els motius de retenció
     Paràmetres entrada: - psseguro -> número segur
                           pnriesgo -> número risc
                           pnmovimi -> número moviment
                           pcmotret -> codi motiu retenció
                           pnmotrev ->
     Paràmetres sortida  - cusuauto -> codi usuari
                           fusuauto -> data
                           cresulta -> resultats
                           tobserva -> observacions
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_get_datosauto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER,
      pnmotret IN NUMBER,
      pnmotrev IN NUMBER,
      pcusuauto OUT VARCHAR2,
      pfusuauto OUT DATE,
      pcresulta OUT NUMBER,
      ptobserva OUT VARCHAR2)
      RETURN NUMBER;

    /******************************************************************************************
     Autor: DCT (13/05/2009)
     Descripció: Funció que retorna si la pòlissa es editable o no
     Paràmetres entrada: - psseguro -> número segur
                           pcempres -> empresa
     Paràmetres sortida  - pcedit -> 0-No editable 1- Editable
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_editar_propuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcempres IN NUMBER,
      puser IN VARCHAR2,
      pcedit OUT NUMBER)
      RETURN NUMBER;

-- BUG 27642 - FAL - 24/04/2014
   FUNCTION f_set_retencion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER)
      RETURN NUMBER;
-- FI BUG 27642
END pac_motretencion;

/

  GRANT EXECUTE ON "AXIS"."PAC_MOTRETENCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MOTRETENCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MOTRETENCION" TO "PROGRAMADORESCSI";
