--------------------------------------------------------
--  DDL for Package PAC_MNT_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MNT_PARAM" AUTHID CURRENT_USER IS
/*************************************************************************
  Devuelve la descripción del parámetro de entrada
  param in pcparam   : código de parámetro
  param in pcidioma  : código del idioma
  param in out pcdesc: descripción del parámetro
  return             : 0 si ha ido bien
                       1 si ha ido mal
*************************************************************************/
   FUNCTION f_get_descparam(pcparam IN VARCHAR2, pcidioma IN NUMBER, pcdesc OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_ins_parproductos
   Inserta en parproductos
   param in psproduc  : código del producto
   param in pcgaram   : código del parametro
   param in pcvalpar  : valor del parametro
   param in ptvalpar  : valor de texto del parametro
   param in pfvalpar  : valor de fecha del parametro
   return             : number
*************************************************************************/
   FUNCTION f_ins_parproductos(
      psproduc IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_del_parproductos
   Borra en parproductos
   param in psproduc  : código del producto
   param in pcparam   : código del parametro
   return             : number
*************************************************************************/
   FUNCTION f_del_parproductos(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_ins_paractividad
   Inserta en paractividad
   param in psproduc  : código del producto
   param in pcactivi   : código de la actividad
   param in pcgaram   : código del parametro
   param in pcvalpar  : valor del parametro
   param in ptvalpar  : valor de texto del parametro
   param in pfvalpar  : valor de fecha del parametro
   return             : number
*************************************************************************/
   FUNCTION f_ins_paractividad(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_ins_paractividad
   Borra en paractividad
   param in psproduc  : código del producto
   param in pcactivi   : código de la actividad
   param in pcgaram   : código del parametro
   return             : number
*************************************************************************/
   FUNCTION f_del_paractividad(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_ins_pargaranpro
   Inserta en pargaranpro
   param in psproduc  : código del producto
   param in pcactivi  : código de la actividad
   param in pcgarant  : código de la garantia
   param in pcgaram   : código del parametro
   param in pcvalpar  : valor del parametro
   param in ptvalpar  : valor de texto del parametro
   param in pfvalpar  : valor de fecha del parametro
   param in pcramo    : código del ramo
   param in pcmodali  : código de la modalidad
   param in pctipseg  : código tipo de seg.
   param in pccolect  : código del colectivo
   return             : number
*************************************************************************/
   FUNCTION f_ins_pargaranpro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      pcramo IN NUMBER DEFAULT NULL,
      pcmodali IN NUMBER DEFAULT NULL,
      pctipseg IN NUMBER DEFAULT NULL,
      pccolect IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_del_pargaranpro
   Borra en paractividad
   param in psproduc  : código del producto
   param in pcactivi  : código de la actividad
   param in pcgarant  : código de la garantia
   param in pcgaram   : código del parametro
   return             : number
*************************************************************************/
   FUNCTION f_del_pargaranpro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_ins_paractividad
   Inserta en parinstalacion
   param in pcparam   : código del parametro
   param in pcvalpar  : valor del parametro
   param in ptvalpar  : valor de texto del parametro
   param in pfvalpar  : valor de fecha del parametro
   return             : number
*************************************************************************/
   FUNCTION f_ins_parinstalacion(
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_del_parinstalacion
   Borra en parinstalacion
   param in pcparam   : código del parametro
   return             : number
*************************************************************************/
   FUNCTION f_del_parinstalacion(pcparam IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_ins_parempresas
   Inserta en parempresas
   param in pcempres  : código de la empresa
   param in pcparam   : código del parametro
   param in pcvalpar  : valor del parametro
   param in ptvalpar  : valor de texto del parametro
   param in pfvalpar  : valor de fecha del parametro
   return             : number
*************************************************************************/
   FUNCTION f_ins_parempresas(
      pcempres IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_del_parempresas
   Borra en parinstalacion
   param in pcempres  : código de la empresa
   param in pcparam   : código del parametro
   return             : number
*************************************************************************/
   FUNCTION f_del_parempresas(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_ins_parconexion
   Inserta en parconexion
   param in pcparam   : código del parametro
   param in pcvalpar  : valor del parametro
   param in ptvalpar  : valor de texto del parametro
   param in pfvalpar  : valor de fecha del parametro
   return             : number
*************************************************************************/
   FUNCTION f_ins_parconexion(
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_del_parconexion
   Inserta en parinstalacion
   param in pcparam   : código del parametro
   return             : number
*************************************************************************/
   FUNCTION f_del_parconexion(pcparam IN VARCHAR2)
      RETURN NUMBER;

-- Bug 8789 - 18/02/2009 - AMC - Se crean las funciones para Parámetros Movimiento

   /*************************************************************************
      FUNCTION f_get_movparam
      Devuelve el valor del parametro de movparam
      param in psproduc  : código del producto
      param in pcmotmov  : código del motivo del movimiento
      param out psquery  : select que devuelve el valor
      return             : number
   *************************************************************************/
   FUNCTION f_get_movparam(psproduc IN NUMBER, pcmotmov IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_del_parmotmov
   Borra de parmotmov
   param in psproduc  : código del producto
   param in pcmotmov  : código del motivo del movimiento
   param in pcparam   : código del parametro
   return             : number
*************************************************************************/
   FUNCTION f_del_parmotmov(psproduc IN NUMBER, pcmotmov IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_ins_parmotmov
   Inserta en parmotmov
   param in psproduc  : código del producto
   param in pcmotmov  : código del motivo del movimiento
   param in pcparam   : código del parametro
   param in pcvalpar  : valor del parametro
   param in ptvalpar  : valor de texto del parametro
   param in pfvalpar  : valor de fecha del parametro
   return             : number
*************************************************************************/
   FUNCTION f_ins_parmotmov(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER;
-- Fi Bug 8789 - 18/02/2009 - AMC - Se crean las funciones para Parámetros Movimiento
END pac_mnt_param;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MNT_PARAM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNT_PARAM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNT_PARAM" TO "PROGRAMADORESCSI";
