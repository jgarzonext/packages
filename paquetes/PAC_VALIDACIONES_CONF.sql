--------------------------------------------------------
--  DDL for Package PAC_VALIDACIONES_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VALIDACIONES_CONF" IS
   /******************************************************************************
      NOMBRE:    pac_validaciones_conf
      PROPÓSITO: Funciones para validaciones

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creación del objeto.

   ******************************************************************************/
   --
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   --

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_1: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_1(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_2: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_2(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_3: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_3(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_4: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_4(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_5: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_5(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_6: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_6(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_7: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_7(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_8: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_8(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_9: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_9(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER;

END pac_validaciones_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES_CONF" TO "PROGRAMADORESCSI";
