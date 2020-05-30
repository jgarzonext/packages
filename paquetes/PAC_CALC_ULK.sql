--------------------------------------------------------
--  DDL for Package PAC_CALC_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CALC_ULK" AUTHID CURRENT_USER IS

    type cursor_TYPE is ref cursor;

    /******************************************************************************
        RSC 12-07-2007
        Package público para calculos de pólizas de vida-indexados
    ******************************************************************************/

   /******************************************************************************
        RSC 12-07-2007
        Obtener los perfiles o modelos de inversión a partir del producto.
    ******************************************************************************/
    FUNCTION f_get_perfil (psproduc IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN cursor_TYPE;
   --FUNCTION f_get_perfiles_producto (psproduc IN NUMBER, pcidioma NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN SYS_REFCURSOR;


   /******************************************************************************
        RSC 12-07-2007
        Obtener el detalle de los perfiles o modelos de inversión a partir del
        producto i el modelo de inversion.

        RSC 15-10-2007 Modificación del nombre y tipo de retorno. Debe ser un REF_CURSOR.
    ******************************************************************************/
    FUNCTION f_get_detall_perfil (psproduc IN NUMBER, pcmodinv IN NUMBER, cidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
    RETURN cursor_TYPE;
   --FUNCTION f_getdet_inversion_prod (psproduc IN NUMBER, pcmodinv NUMBER) RETURN t_det_modinv;

   /******************************************************************************
        RSC 15-10-2007
        Obtiene el perfil de cartera de la póliza
    ******************************************************************************/
   FUNCTION f_get_perfil_poliza (psseguro IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN NUMBER;

   /******************************************************************************
        RSC 15-10-2007
        Retorna la distribución de cartera asociada a una póliza.
    ******************************************************************************/
   FUNCTION f_get_cartera_poliza (psseguro IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
   RETURN cursor_TYPE;

   /******************************************************************************
        RSC 15-10-2007
        Retorna el literal de un fondo
    ******************************************************************************/
    FUNCTION f_get_fons_desc (pcfons IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN VARCHAR2;

    /****************************************************************************************
        RSC 23-10-2007
        Obtener el detalle de los fondos relacionados con un producto.
    ****************************************************************************************/
    FUNCTION f_get_llistafons (psproduc IN NUMBER, cidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
    RETURN cursor_TYPE;
END Pac_Calc_Ulk;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_ULK" TO "PROGRAMADORESCSI";
