--------------------------------------------------------
--  DDL for Package PAC_SIN_IMP_SAP_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIN_IMP_SAP_CONF" AS
   /******************************************************************************
      NOMBRE:    PAC_SIN_IMP_SAP_CONF
      PROPÓSITO: Funciones para calculo de impuestos en siniestros

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  --------------------------------
      1.0       12/05/2017   JAEG             Creacion
   ******************************************************************************/

   /*************************************************************************
            Relaciona al profesional con el impuesto indicado
   *************************************************************************/
   FUNCTION f_set_impuesto_prof(psprofes IN NUMBER,
                                pccodimp IN NUMBER,
                                pctipind IN NUMBER) RETURN NUMBER;

   /*************************************************************************
         Recupera los impuestos/retenciones para un profesional dado
   *************************************************************************/
   FUNCTION f_get_indicador_prof(pcconpag IN NUMBER,
                                 psprofes IN NUMBER,
                                 pccodimp IN NUMBER,
                                 pfordpag IN DATE,
                                 pnsinies IN sin_tramita_localiza.nsinies%TYPE,
                                 pntramit IN sin_tramita_localiza.ntramit%TYPE,
                                 pnlocali IN sin_tramita_localiza.nlocali%TYPE,
                                 ptselect OUT VARCHAR2) RETURN NUMBER;
   --
END pac_sin_imp_sap_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_IMP_SAP_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_IMP_SAP_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_IMP_SAP_CONF" TO "PROGRAMADORESCSI";
