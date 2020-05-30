--------------------------------------------------------
--  DDL for Package PAC_MARCAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MARCAS" AS
  /******************************************************************************
        NOMBRE:       PAC_IAX_MARCAS
        PROP¿SITO:  Funciones para gestionar las marcas

        REVISIONES:
        Ver        Fecha        Autor   Descripci¿n
       ---------  ----------  ------   ------------------------------------
        1.0        01/08/2016   HRE     1. Creaci¿n del package.
		2.0        05/03/2019   CJMR    2. Se agrega función para validación de marcas
  ******************************************************************************/
  /*************************************************************************
    FUNCTION f_set_marcas_per
    Permite asociar marcas a la persona de forma manual
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param in pparam    : parametros de roles
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_set_marcas_per(pcempres IN NUMBER,
                            psperson IN NUMBER,
                            t_marcas   IN T_IAX_MARCAS)
    RETURN NUMBER;
/*************************************************************************
    FUNCTION f_set_marca_automatica
    Permite asociar	 marcas a la persona en procesos del Sistema
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param in pparam    : parametros de roles
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_set_marca_automatica(pcempres IN NUMBER,
                                  psperson IN NUMBER,
                                  pcmarca  IN VARCHAR2)
    RETURN NUMBER;
/*************************************************************************
    FUNCTION f_del_marca_automatica
    Permite desactivar marcas a la persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_del_marca_automatica(pcempres IN NUMBER,
                                  psperson IN NUMBER,
                                  pcmarca  IN VARCHAR2)
    RETURN NUMBER;
--
/*************************************************************************
    FUNCTION f_ins_log_marcaspoliza
    Inserta informacion de personas que tienen marcas activas
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_ins_log_marcaspoliza(pcempres  IN NUMBER,
                                  psproces  IN NUMBER,
                                  psperson  IN NUMBER,
                                  pcmarca   IN VARCHAR2,
                                  psseguro  IN NUMBER)
    RETURN NUMBER;

   -- INI CJMR 05/03/2019
/*************************************************************************
    FUNCTION f_marcas_validacion
    Valida si una persona tiene una marca tipo validación en un vinculo específico
    param in psperson  : código de la persona
    param in ptipvin   : Tipo vinculación: 1-Tomador, 2-Asegurado
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_marcas_validacion(psperson  IN NUMBER,
                               ptipvin IN NUMBER,
                               mensajes   IN OUT t_iax_mensajes)
    RETURN NUMBER;
   -- FIN CJMR 05/03/2019
   
         /*************************************************************************
    FUNCTION f_get_tipo_marca
    Permite buscar todos as marcas que a persona tienes
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param out mensajes : mesajes de error
    return             : varchar2
  *************************************************************************/ 

FUNCTION f_get_tipo_marca(pcempres IN NUMBER,
                            psperson IN NUMBER)
    RETURN VARCHAR2;
    -- FIN F_GET_MARCA 06/06/2019 

END pac_marcas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MARCAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MARCAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MARCAS" TO "PROGRAMADORESCSI";
