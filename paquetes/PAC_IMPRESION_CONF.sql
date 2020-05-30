--------------------------------------------------------
--  DDL for Package PAC_IMPRESION_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "PAC_IMPRESION_CONF" AS
   /****************************************************************************
     NOMBRE:    pac_impresion_conf
     PROPSITO: Funciones para validar si un documento se debe generar o no

     REVISIONES:
     Ver        Fecha       Autor            Descripcin
     ---------  ----------  ---------------  --------------------------------------
     1.0        10/10/2016  JTS
	 2.0        25/04/2019  ACL              IAXIS-3095 Se crean las funciones f_clausulado y f_val_consorcio
   ****************************************************************************/

   /*************************************************************************
      FUNCTION f_mov_recibo
      El movimiento tiene recibo?
      param in p_sproduc    : Cdigo del producto
      param in p_ctipo      : Tipo de impresion
      param in p_ccodplan   : Cdigo de plantilla
      param in p_fdesde     : Fecha de vigencia
      param in p_sseguro    : Cdigo de seguro
      return             : 1 se genera, 0 no se genera
   *************************************************************************/
   FUNCTION f_mov_recibo(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_coacedido
      El seguro tiene coaseeguro cedido?
      param in p_sproduc    : Cdigo del producto
      param in p_ctipo      : Tipo de impresion
      param in p_ccodplan   : Cdigo de plantilla
      param in p_fdesde     : Fecha de vigencia
      param in p_sseguro    : Cdigo de seguro
      return             : 1 se genera, 0 no se genera
   *************************************************************************/
   FUNCTION f_coacedido(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

  /*************************************************************************
      FUNCTION f_consorcio
      El tomador es un consorcio?
      param in p_sproduc    : Cdigo del producto
      param in p_ctipo      : Tipo de impresion
      param in p_ccodplan   : Cdigo de plantilla
      param in p_fdesde     : Fecha de vigencia
      param in p_sseguro    : Cdigo de seguro
      return             : 1 se genera, 0 no se genera
   *************************************************************************/
   FUNCTION f_consorcio(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

      /*************************************************************************
        FUNCTION f_garantias
        Garantias genrico
        param in p_sproduc    : Cdigo del producto
        param in p_ctipo      : Tipo de impresion
        param in p_ccodplan   : Cdigo de plantilla
        param in p_fdesde     : Fecha de vigencia
        param in p_sseguro    : Cdigo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_garantias(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

      /*************************************************************************
        FUNCTION f_gar_respcivil
        Garantias de RESPONSABILIDAD CIVIL CRUZADA
        param in p_sproduc    : Cdigo del producto
        param in p_ctipo      : Tipo de impresion
        param in p_ccodplan   : Cdigo de plantilla
        param in p_fdesde     : Fecha de vigencia
        param in p_sseguro    : Cdigo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_gar_respcivil(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

      /*************************************************************************
        FUNCTION f_regprivcontratacion
        Regimen privado de contratacin
        param in p_sproduc    : Cdigo del producto
        param in p_ctipo      : Tipo de impresion
        param in p_ccodplan   : Cdigo de plantilla
        param in p_fdesde     : Fecha de vigencia
        param in p_sseguro    : Cdigo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_regprivcontratacion(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
	  
	  
	  /*************************************************************************
        FUNCTION f_clausula_ecopetrol
        Regimen privado de contratacin
        param in p_sproduc    : Cdigo del producto
        param in p_ctipo      : Tipo de impresion
        param in p_ccodplan   : Cdigo de plantilla
        param in p_fdesde     : Fecha de vigencia
        param in p_sseguro    : Cdigo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
      FUNCTION f_clausula_ecopetrol(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
	  
	        /*************************************************************************
        FUNCTION f_clausula_ecopetrol
        Regimen privado de contratacin
        param in p_sproduc    : Cdigo del producto
        param in p_ctipo      : Tipo de impresion
        param in p_ccodplan   : Cdigo de plantilla
        param in p_fdesde     : Fecha de vigencia
        param in p_sseguro    : Cdigo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
      FUNCTION f_clausula_ecopetrol_gb(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
	        
    /*************************************************************************
        FUNCTION f_val_consorcio
        Valida la generacion del anexo de consorcios
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
     FUNCTION f_val_consorcio(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

     /*************************************************************************
        FUNCTION f_clausulado_ecop
        Clausulado producto Derivado de Contrato actividad Ecopetrol
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_ecop(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
      
    /*************************************************************************
        FUNCTION f_clausulado_part_zf
        Clausulado producto Derivado de Contrato actividad Particular Zona Franca
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_part_zf(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
      
    /*************************************************************************
        FUNCTION f_clausulado_part_p
        Clausulado producto Derivado de Contrato actividad Particular '.'
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_part_p(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
      
    /*************************************************************************
        FUNCTION f_clausulado_part_brep
        Clausulado producto Derivado de Contrato actividad Particular Banco de la Rep�blica
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_part_brep(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
      
    /*************************************************************************
        FUNCTION f_clausulado_gu_dec1082
        Clausulado producto Derivado de Contrato
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_gu_dec1082(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
      
    /*************************************************************************
        FUNCTION f_clausulado_gu_rpc
        Clausulado producto Derivado de Contrato
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_gu_rpc(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
      
    /*************************************************************************
        FUNCTION f_clausulado_gu_ani
        Clausulado producto Derivado de Contrato
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_gu_ani(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
      
     /*************************************************************************
        FUNCTION f_clausulado_sp
        Clausulado producto Derivado de Contrato
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_sp(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;	  
end pac_impresion_conf;

/
