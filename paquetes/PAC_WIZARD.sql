--------------------------------------------------------
--  DDL for Package PAC_WIZARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_WIZARD" 
	AUTHID CURRENT_USER
IS
/***************************************************************************
 PAC_Wizard: Package per treballar amb el wizard del TF
  01-12-03 CPM (CSI)
***************************************************************************/

   /*
    {Declaración de tipos}
   */
   TYPE campos_propiedad IS RECORD (
      tcampo      VARCHAR2 (50),
      tproperty   VARCHAR2 (50),
      tvalue      VARCHAR2 (50)
   );

   TYPE campos_modi IS TABLE OF campos_propiedad
      INDEX BY BINARY_INTEGER;

   FUNCTION f_consupl_form (
      pcconsupl   IN   VARCHAR2,
      ptform      IN   VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION f_codwizard (
      puser        IN       VARCHAR2,
      pform        IN       VARCHAR2,
      psproduc     IN       NUMBER,
      pcmodo                VARCHAR2,
      pform_sig    IN OUT   VARCHAR2,
      pform_ant    IN OUT   VARCHAR2,
      pniteracio   IN OUT   NUMBER,
      pcsituac     IN OUT   VARCHAR2,
      pccamptf     IN       VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION f_codwizard_ini (
      puser      IN       VARCHAR2,
      psproduc   IN       NUMBER,
      pcmodo              VARCHAR2,
      pform      IN OUT   VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION f_obtener_from (
      pcuser     IN   VARCHAR2,
      psproduc   IN   NUMBER,
      pmodo      IN   VARCHAR2,
      pform      IN   VARCHAR2,
      pccamptf   IN   VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION f_obtener_nsuplem (
      pcuser     IN   VARCHAR2,
      psproduc   IN   NUMBER,
      pmodo      IN   VARCHAR2,
      pform      IN   VARCHAR2,
      pccamptf   IN   VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION f_modificar_campos_supl (
      pcuser     IN       VARCHAR2,
      psproduc   IN       NUMBER,
      ptform     IN       VARCHAR2,
      psseguro   IN       NUMBER,
      pcmodo     IN       VARCHAR2,
      tcampos    IN OUT   campos_modi
   )
      RETURN NUMBER;

   FUNCTION f_modificar_campos (
      pcuser     IN       VARCHAR2,
      psproduc   IN       NUMBER,
      ptform     IN       VARCHAR2,
      pcmodo     IN       VARCHAR2,
      tcampos    IN OUT   campos_modi
   )
      RETURN NUMBER;

   FUNCTION f_supl_form_navegable (
      pcuser     IN   VARCHAR2,
      pcmotmov   IN   NUMBER,
      psproduc   IN   NUMBER,
      pcmodo     IN   VARCHAR2,
      ptform     IN   VARCHAR2
   )
      RETURN NUMBER;

   PROCEDURE p_borrar_visitado (
      psseguro   IN   NUMBER,
      ptform     IN   VARCHAR2
   );

   FUNCTION f_get_accion (
      pcuser     IN   VARCHAR2,
      pcaccion   IN   VARCHAR2,
      psproduc   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;
END pac_wizard;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_WIZARD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_WIZARD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_WIZARD" TO "PROGRAMADORESCSI";
