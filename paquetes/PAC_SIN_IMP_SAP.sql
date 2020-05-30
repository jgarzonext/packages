CREATE OR REPLACE PACKAGE pac_sin_imp_sap AS
/******************************************************************************
   NOMBRE:    pac_sin_imp_sap
   PROP¿SITO: Funciones para calculo de impuestos en siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
    2.0       18/01/2019   WAJ            Insertar codigo impuesto segun tipo de vinculacion
******************************************************************************/
   FUNCTION f_get_lstimpuestos(pcempres IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Devuelve los tipos de indicador para el impuesto indicado
   *************************************************************************/
   FUNCTION f_get_tipos_indicador(
      pccodimp IN NUMBER,
	  pcarea IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;
--IAXIS 7655 AABC Conceptos tiquetes aereos 
   /*************************************************************************
    Devuelve los tipos de conceptos de tiquetes aereos
   *************************************************************************/
   FUNCTION f_get_concep_pago(
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;      
--IAXIS 7655 AABC Conceptos tiquetes aereos 
/*************************************************************************
         Relaciona al profesional con el impuesto indicado
*************************************************************************/
   FUNCTION f_set_impuesto_prof(psprofes IN NUMBER, pccodimp IN NUMBER, pctipind IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
         Elimina la relaci¿n del profesional con el impuesto indicado
*************************************************************************/
   FUNCTION f_del_impuesto_prof(psprofes IN NUMBER, pctipind IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
      Recupera los impuestos/retenciones para un profesional dado
*************************************************************************/
   FUNCTION f_get_indicador_prof(
      pcconpag IN NUMBER,
      psprofes IN NUMBER,
      pccodimp IN NUMBER,
      pfordpag IN DATE,
      pnsinies IN sin_tramita_localiza.nsinies%TYPE,
      pntramit IN sin_tramita_localiza.ntramit%TYPE,
      pnlocali IN sin_tramita_localiza.nlocali%TYPE,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;
  --INI--WAJ
/*************************************************************************
         Relaciona el vinculo de la persona con el impuesto indicado
*************************************************************************/
   FUNCTION f_set_impuesto_per(
     pccodvin IN NUMBER,
     pccatribu IN NUMBER,
     pctipind IN NUMBER,
     psperson IN NUMBER)
      RETURN NUMBER;
    --FIN--WAJ
END pac_sin_imp_sap;

/

