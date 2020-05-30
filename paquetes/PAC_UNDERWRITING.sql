--------------------------------------------------------
--  DDL for Package PAC_UNDERWRITING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_UNDERWRITING" AUTHID CURRENT_USER
IS
   /******************************************************************************
      NOMBRE:      pac_propio_accion_supl_msv
      PROPÓSITO:   Package propio para la validación dinámica de acciones y funciones
                   de validación existentes en la tabla PDS_SUPL_AUTOMATIC y
                   PDS_SUPL_ACCIONES (Suplementos automáticos y diferidos)


      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       13/03/2015  RSC               1. Creación del package
       1.1       29/07/2015  IGIL              2. Creacion de las funciones encargadas
                                                  de insertar , editar y eliminar citas medicas
   ******************************************************************************/
   FUNCTION f_get_caseproperties (
      psseguro   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_get_casedata (
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfefecto   IN   DATE,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributename (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributegender (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributeheight (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributeweight (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributeage (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pfefecto   IN   DATE,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributebmi (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pfefecto   IN   DATE,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributecountry (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributesmoker (
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributesmoker_last2 (
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributerisk_types (
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributeage_band (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pfefecto   IN   DATE,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_caseid (pcaseid IN NUMBER)
      RETURN XMLTYPE;

   FUNCTION f_get_case (
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfefecto   IN   DATE,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributechannel (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_get_entitytype
      RETURN XMLTYPE;

   FUNCTION f_get_entityinstance
      RETURN XMLTYPE;

   FUNCTION f_get_parameters
      RETURN XMLTYPE;

   FUNCTION f_get_reopencase
      RETURN XMLTYPE;

   FUNCTION f_get_function (pcaseid IN NUMBER, pxml IN XMLTYPE)
      RETURN XMLTYPE;

   FUNCTION f_get_disability_present (
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_get_risk_lifeinfo (
      pcempres    IN   NUMBER,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      picapital   IN   NUMBER,
      ptablas     IN   VARCHAR2 DEFAULT 'EST',
      plife       IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_risk_based_values (
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributebovtrustee (
      psseguro   IN   NUMBER,
      pfefecto   IN   DATE,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributeinspurpose (
      psseguro   IN   NUMBER,
      pfefecto   IN   DATE,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributeinterviewtype (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pfefecto   IN   DATE,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST',
      plife      IN   NUMBER DEFAULT 1
   )
      RETURN XMLTYPE;

   FUNCTION f_get_attributeendowment (
      psseguro   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_connect_undw_if01 (
      pcaseid    IN   NUMBER,
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfefecto   IN   DATE,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN ob_iax_underwrt_if01;

   FUNCTION f_get_locale
      RETURN XMLTYPE;

   FUNCTION f_get_function_if02 (pcaseid IN NUMBER, pxml IN XMLTYPE)
      RETURN XMLTYPE;

   FUNCTION f_connect_undw_if02 (
      pcaseid    IN   NUMBER,
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfefecto   IN   DATE,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN NUMBER;

   FUNCTION f_extract_questions_if02 (
      pcaseid    IN   NUMBER,
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      psinterf   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN NUMBER;

   FUNCTION f_extract_actions_if02 (
      pcaseid    IN   NUMBER,
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      psinterf   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN NUMBER;

   FUNCTION f_extract_exclusions_if02 (
      pcaseid    IN   NUMBER,
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      psinterf   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN NUMBER;

   FUNCTION f_extract_icd10codes_if02 (
      pcaseid    IN   NUMBER,
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      psinterf   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN NUMBER;

   FUNCTION f_setrechazo_icd10codes (
      psseguro   IN       seguros.sseguro%TYPE,
      pnmovimi   IN       movseguro.nmovimi%TYPE,
      pcindex    IN       t_iax_info,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_evidences (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_insert_citasmedicas (
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      psperaseg   IN       NUMBER,
      pspermed    IN       NUMBER,
      pceviden    IN       NUMBER,
      pfeviden    IN       DATE,
      pcestado    IN       NUMBER,
      ptablas     IN       VARCHAR2 DEFAULT 'EST',
      pieviden    IN       NUMBER,
      pcpago      IN       NUMBER,
      pnorden_r   OUT      NUMBER,
      pcais       IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_edit_citasmedicas (
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      psperaseg   IN       NUMBER,
      pspermed    IN       NUMBER,
      pceviden    IN       NUMBER,
      pfeviden    IN       DATE,
      pcestado    IN       NUMBER,
      ptablas     IN       VARCHAR2 DEFAULT 'EST',
      pieviden    IN       NUMBER,
      pcpago      IN       NUMBER,
      pnorden_r   IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_delete_citasmedicas (
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      psperaseg   IN       NUMBER,
      pceviden    IN       NUMBER,
      ptablas     IN       VARCHAR2 DEFAULT 'EST',
      pnorden_r   IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_extract_loadings_if02 (
      pcaseid    IN   NUMBER,
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      psinterf   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN NUMBER;

   FUNCTION f_get_attributesum_insured (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pfefecto   IN   DATE,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN XMLTYPE;

   FUNCTION f_initializes_appointments (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      -- 37574/213761 IGIL INI
      pnmovimi   IN   NUMBER,
      -- 37574/213761 IGIL FIN
      pcodevi    IN   VARCHAR,
      pentity    IN   NUMBER
   )
      RETURN NUMBER;
END pac_underwriting;

/

  GRANT EXECUTE ON "AXIS"."PAC_UNDERWRITING" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_UNDERWRITING" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_UNDERWRITING" TO "PROGRAMADORESCSI";
