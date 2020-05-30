--------------------------------------------------------
--  DDL for Package PAC_IAX_MARCAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_MARCAS" AS
  /******************************************************************************
        NOMBRE:       PAC_IAX_MARCAS
        PROP¿SITO:  Funciones para gestionar las marcas

        REVISIONES:
        Ver        Fecha        Autor   Descripci¿n
       ---------  ----------  ------   ------------------------------------
        1.0        01/08/2016   HRE     1. Creaci¿n del package.
  ******************************************************************************/
  /*************************************************************************
    FUNCTION f_get_marcas
    Permite obtener la informacion de las marcas
    param in pcempres  : codigo de la empresa
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor;

  FUNCTION f_obtiene_marcas(pcempres IN NUMBER,
                            psperson IN NUMBER,
                            mensajes IN OUT t_iax_mensajes)
  RETURN t_iax_marcas;

  /*************************************************************************
    FUNCTION f_get_marcas_per
    Permite obtener la informacion de las marcas asociadas a una persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas_per(pcempres IN NUMBER,
                            psperson IN NUMBER,
                            mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor;
  /*************************************************************************
    FUNCTION f_get_marcas_perhistorico
    Permite obtener la informacion de todos los movimientos de una marca
    asociada a la persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas_perhistorico(pcempres IN NUMBER,
                                     psperson IN NUMBER,
                                     pcmarca  IN VARCHAR2,
                                     mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor;
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
                            t_marcas   IN T_IAX_MARCAS,
                            mensajes IN OUT t_iax_mensajes)
    RETURN NUMBER;

   /* FUNCTION f_set_marcas(pcempres IN NUMBER,
                            psperson IN NUMBER,
                            t_marcas   IN T_IAX_MARCAS,
                            mensajes IN OUT t_iax_mensajes)
    RETURN NUMBER;*/

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
                                  pcmarca  IN VARCHAR2,
                                  mensajes IN OUT t_iax_mensajes)
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
                                  pcmarca  IN VARCHAR2,
                                  mensajes IN OUT t_iax_mensajes)
    RETURN NUMBER;
--
  /*************************************************************************
    FUNCTION f_get_marcas_poliza
    Permite obtener la informacion de las marcas asociadas a una persona
    param in pcempres  : codigo de la empresa
    param in psseguro  : codigo del seguro
    param in ptablas  : EST o POL
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas_poliza(pcempres IN NUMBER,
                               psseguro IN NUMBER,
                               ptablas  IN VARCHAR2,
                               mensajes IN OUT t_iax_mensajes)
  RETURN sys_refcursor;

  /*************************************************************************
    FUNCTION f_get_accion_poliza
    Permite obtener la maxima accion de las marcas asociadas a tomadores,
    asegurados o beneficiarios de una poliza
    param in pcempres  : codigo de la empresa
    param in psseguro  : codigo del seguro
    param in ptablas  : EST o POL
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_get_accion_poliza(pcempres IN NUMBER,
                               psseguro IN NUMBER,
                               ptablas  IN VARCHAR2,
                               mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER;
END pac_iax_marcas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MARCAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MARCAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MARCAS" TO "PROGRAMADORESCSI";
