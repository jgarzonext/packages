--------------------------------------------------------
--  DDL for Package PAC_MD_VALIDACIONES_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_VALIDACIONES_AHO" AS
/******************************************************************************
   NOMBRE:       PAC_MD_VALIDACIONES_AHO
   PROPÓSITO:  Funciones de validaciones para productos financieros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   JRH                1. Creación del package.
******************************************************************************/


     --JRH 03/2008
    /*************************************************************************
       Valida la forma de pago de la renta según la parametrización del producto
       param in psproduc  : código de producto
       param in pforpagren  : código de forma de pago de la renta
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
    FUNCTION f_valida_forma_pago_renta(psproduc IN SEGUROS.SPRODUC%TYPE,
                                       pforpagren IN NUMBER,
                                       mensajes IN OUT T_IAX_MENSAJES) RETURN NUMBER;


    --JRH 03/2008
   /*************************************************************************
       Valida el % de reversión de la renta según la parametrización del producto
       param in psproduc  : código de producto
       param in prevers  : % Reversión
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
    FUNCTION f_valida_pct_revers(psproduc IN SEGUROS.SPRODUC%TYPE,
                                 prevers IN NUMBER,
                                 mensajes IN OUT T_IAX_MENSAJES) RETURN NUMBER;


     --JRH 03/2008
    /*************************************************************************
     Valida el % de reserva fallec. de la renta según la parametrización del producto
     param in psproduc  : código de producto
     param in pfallec  : % fallecimiento
     param out mensajes : mensajes de error
     return             : 0 todo correcto
                          1 ha habido un error
  *************************************************************************/
    FUNCTION f_valida_percreservcap(psproduc IN SEGUROS.SPRODUC%TYPE,
                                    pfallec IN NUMBER,
                                    mensajes IN OUT T_IAX_MENSAJES) RETURN NUMBER;


   --JRH 03/2008
   /*************************************************************************
       Valida todos los datos de gestión financieros de golpe
       param in psproduc  : código de producto
       param in gestion  : objeto OB_IAX_GESTION
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
    FUNCTION f_valida_datosGest(psproduc IN SEGUROS.SPRODUC%TYPE,
                                gestion IN OB_IAX_GESTION,
                                mensajes IN OUT T_IAX_MENSAJES) RETURN NUMBER;


--JRH 03/2008
  /*************************************************************************
       Valida varios parámetros de capitales de garantías
       param in psproduc  : código de producto
       param in pcgarant  : garantía
       param in picapital  : capital
       param in ptipo  : 1 para Nueva Producción.
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
    FUNCTION f_valida_capitales_gar(psproduc IN SEGUROS.SPRODUC%TYPE,
                                    pcgarant IN NUMBER,
                                    picapital IN NUMBER,
                                    ptipo IN NUMBER,
                                    PFECHA in date,
                                    porigen in number default 2,
                                    mensajes IN OUT T_IAX_MENSAJES) RETURN NUMBER;


  --JRH 03/2008
  /*************************************************************************
       Valida las rentas irregulares
       param in nriesgo  : Número de riesgo
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION F_Valida_RentaIrreg(nriesgo number, mensajes IN OUT T_IAX_MENSAJES)
   RETURN NUMBER;


   --JRH 03/2008
   /*************************************************************************
       Valida el % periodo de revisión
       param in psproduc  : código de producto
       param in pduracion  : duración póliza
       param in pperiodo  :periodo de revisión
       param in pfefecto  :fecha efecto
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
    FUNCTION f_valida_periodo(psproduc IN SEGUROS.SPRODUC%TYPE,
                              pduracion IN NUMBER,
                              pperiodo IN NUMBER,
                              pfefecto IN DATE,
                              mensajes IN OUT T_IAX_MENSAJES) RETURN NUMBER ;
END PAC_MD_VALIDACIONES_AHO;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AHO" TO "PROGRAMADORESCSI";
