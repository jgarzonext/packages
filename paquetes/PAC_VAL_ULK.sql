--------------------------------------------------------
--  DDL for Package PAC_VAL_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VAL_ULK" AUTHID CURRENT_USER IS

   /******************************************************************************
        RSC 12-07-2007
        Valida que el modelo de inversión configurado por el usuario és valido.
        Si Pmodinv es diferente de NULL nos indica que el usuario ha escogido el
        modelo de inversión Libre, y que por tanto debemos verificar su validez.

        La función retorna:
         0.- Si todo es correcto
         codigo error: - Si hay error o no cumple alguna validación
    ******************************************************************************/
   FUNCTION f_valida_cartera (psproduc IN NUMBER, pcperfil IN NUMBER, pcartera IN PAC_REF_CONTRATA_ULK.cartera, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN NUMBER;

   /******************************************************************************
        RSC 15-10-2007
        Valida si el perfil pasado por parámetro es editable o no.

        La función retorna:
         0.- Si todo es correcto
         codigo error: - Si hay error o no cumple alguna validación
    ******************************************************************************/
   FUNCTION f_valida_perfil_editable (psproduc IN NUMBER, pcperfil IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN NUMBER;

   /*******************************************************************************************
        RSC 01-08-2007
        Para un cesta dada almacena en "estado" el estado de la cesta consultando
        el estado que tienen los fondos asociados a la cesta. (Cerrado, Semicerrado y Abierto)
        Esta función es de uso interno del Package. (f_valida_ulk_abierto)

        La función retorna:
         0.- Si todo bien.
         codigo error: - Si hay error general
    *******************************************************************************************/
   FUNCTION f_valida_estado_cesta (cesta  IN NUMBER, v_fefecto IN DATE, estado OUT VARCHAR2) RETURN NUMBER;

      /******************************************************************************
        RSC 17-09-2007
        Valida si existen fondos de inversión con fecha la de efecto pasada por parámetro
        que estén en estado CERRADO.

        La función retorna:
         0.- Si no existen fondos en estado CERRADO.
         codigo error: - Si hay error o no cumple alguna validación
    ******************************************************************************/
   FUNCTION f_valida_ulk_abierto (psseguro IN NUMBER DEFAULT NULL, psproduc IN NUMBER DEFAULT NULL, pfecha IN DATE, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN NUMBER;

END Pac_Val_Ulk;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_VAL_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_ULK" TO "PROGRAMADORESCSI";
