--------------------------------------------------------
--  DDL for Package PAC_MD_PRODUCCION_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PRODUCCION_AHO" IS

/******************************************************************************
   NOMBRE:       PAC_MD_PRODUCCION_AHO
   PROPÓSITO: Funciones para contración  de productos financieros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/03/2008   JRH                1. Creación del package.
******************************************************************************/



/********************************************************************************************************************
   Función que graba el interés técnico de la póliza en ESTINTERTECSEG siempre y cuando haya interés técnico
   definido a nivel de producto.

   En el caso de que se informe el importe se han añadido los tramos para el caso de LRC (periodo anualidad) a los que se refiere el importe.

     Para ramos tipo LRC en el caso de que no se informe el importe se daran de alta en las tablas de intereses a nivel de póliza
     los intereses correspondientes a todas las anualidades del periodo seleccionado (parametrizados a nivel de producto).

   En el resto de casos si el parámetro PINTTEC es NULO, entonces se busca el interés parametrizado en el producto

    param in psproduc  : Número de producto
    param in psseguro  : Número de póliza
    param in pfefecto  : Fecha efecto
    param in PNMOVIMI  : Número de suplemento
    param in pinttec  : Interés (default null)
    param in ptablas  : Tablas (default 'EST')
    param in pvTramoIni  : De momento no informar (Tramos de LRC) (default null)
    param in pvTramoFin  : De momento no informar (Tramos de LRC) (default null)

********************************************************************************************************************/

 FUNCTION f_grabar_inttec(psproduc IN NUMBER, psseguro IN NUMBER, pfefecto IN DATE, PNMOVIMI IN NUMBER,
       pinttec IN NUMBER DEFAULT NULL, ptablas in varchar2 default 'EST',
       pvTramoIni IN NUMBER DEFAULT NULL, pvTramoFin IN NUMBER DEFAULT NULL,mensajes IN OUT T_IAX_MENSAJES)--JRH 09/2007 Tarea 2674: Intereses para LRC.Añadimos el tramo que queremos insertar este interés.
RETURN NUMBER;




/********************************************************************************************************************
   Función que graba la penalización para cada anualidad de la póliza en ESTPENALISEG,
   siempre y cuando haya penalización definida a nivel de producto

   pmodo = 1   modo alta
           2  modo renovación

    param in psproduc  : Número de producto
    param in psseguro  : Número de póliza
    param in pfefecto  : Fecha efecto
    param in PNMOVIMI  : Número de suplemento
    param in pinttec  : Interés (default null)
    param in ptablas  : Tablas (default 'EST')
    param in pvTramoIni  : De momento no informar (Tramos de LRC) (default null)
    param in pvTramoFin  : De momento no informar (Tramos de LRC) (default null)

 ********************************************************************************************************************/

FUNCTION f_grabar_penalizacion(pmodo IN NUMBER, psproduc IN NUMBER, psseguro IN NUMBER, pfefecto IN DATE,
   pnmovimi IN NUMBER DEFAULT 1, ptablas IN VARCHAR2 DEFAULT 'EST',mensajes IN OUT T_IAX_MENSAJES)
RETURN NUMBER;

/*


   FUNCTION ff_get_formapagoren (ptablas IN VARCHAR2, psseguro IN NUMBER)
     RETURN NUMBER ;
   */

END PAC_MD_PRODUCCION_AHO;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_AHO" TO "PROGRAMADORESCSI";
