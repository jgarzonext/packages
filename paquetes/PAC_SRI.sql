--------------------------------------------------------
--  DDL for Package PAC_SRI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SRI" IS
    /******************************************************************************
      NOMBRE:      PAC_SRI
      PROP¿SITO:   Preparaci¿n para env¿o de datos al SRI
      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.1        27/04/2016    jdelrio          1. Creaci¿n del package.
   ******************************************************************************/
   --------------------------------------------------------------------------------------Funcion que calcula el d¿gito de verificaci¿n
   FUNCTION f_digito_verificacion(pcadena IN VARCHAR2)
      RETURN NUMBER;

   --------------------------------------------------------------------------------------Funcion que llena la informaci¿n para enviar el xml al sri
   FUNCTION p_envio_sri(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctipocomprobante IN NUMBER)
      RETURN NUMBER;

   PROCEDURE p_reproceso_sri;

   PROCEDURE p_continuar_sri;

   FUNCTION f_comprobar_sri(psseguro IN NUMBER)
      RETURN NUMBER;

       /*************************************************************************
    FUNCTION f_detalle_primas
    Funci¿n que se utilizar¿ para obtener el importe detallado de las primas.
    param in NMOVIMI   : N¿mero de movimiento
    param in P_TIPO    : 1 ¿ 1er Columna desc. de garant¿as,  textos 2- 2¿ columna,Capitales asegurados, primas,etc
    param in P_TABLAS    : C¿digo de seguro
    return                : Tablas de donde se obtienen los datos, por defecto POL.
    *************************************************************************/
    FUNCTION f_detalle_primas(
             p_sseguro    IN    NUMBER,
             p_nmovimi    IN    NUMBER,
             p_tipo    IN    NUMBER,
             p_tablas    IN    VARCHAR2 DEFAULT 'POL'
    )   RETURN VARCHAR2;

   FUNCTION f_ride_sri(pclave IN VARCHAR2, psinterf IN NUMBER)
      RETURN NUMBER;

FUNCTION f_xml_sri (pl_clob IN CLOB, ptfilename in VARCHAR2, pdirpdfgdx IN VARCHAR2)
   RETURN NUMBER;

END pac_sri;

/

  GRANT EXECUTE ON "AXIS"."PAC_SRI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SRI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SRI" TO "PROGRAMADORESCSI";
