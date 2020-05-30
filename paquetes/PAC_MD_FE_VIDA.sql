--------------------------------------------------------
--  DDL for Package PAC_MD_FE_VIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_FE_VIDA" AS
/******************************************************************************
   NOMBRE:       PAC_MD_SUPLEMENTOS
   PROPÓSITO:  Permite crear suplementos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/09/2010   ETM               1. Creación del package.--0015884: CEM - Fe de Vida. Nuevos paquetes PLSQL
                                            --Nuevo paquete que contiene todas las funciones y procedimientos directamente relacionados con el módulo de cartas de fe de vida en la capa MD.
   2.0        19/01/2011   APD              2. Bug 15289 : Cartas Fe de Vida
   ******************************************************************************/

   -- Bug 15289 - APD - 21/01/2011 - se crea la funcion
   /*************************************************************************
   Función  F_PERCEPTORES_RENTA
   Devuelve las personas que reciben la renta.
   Solo se mostraran aquellas personas a las cuales se les ha enviado la carta de
   fe de vida previamente y que aun no han confirmado su fe de vida
      param in psseguro: identificador del seguro
      param in out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_perceptores_renta(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*******************************************************************************
   FUNCION  F_GET_DATOS_FE_VIDA
   -función qdevolverá un REF CURSOR con las pólizas que deben enviar la carta de fe de vida.
   Parámetros:
    Entrada :
    1.    psproces. Identificador del proceso.
    2.    pcempres. Identificador de la empresa. Obligatorio.
    3.    pcramo. Identificador del ramo.
    4.    psproduc. Identificador del producto.
    5.    pcagente. Identificador del agente.
    6.    pnpoliza. Número de póliza.
    7.    pncertif. Número de certificado.
    8.    pfhasta. Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
    9.   pngenerar. Identificador de generación de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)
    10.  pnpantalla. Identificador de visualización o no del resultado de la select por pantalla. 0.-No se visualiza el resultado de la select por pantalla (el resultado de la select se utiliza en el map);1.-Sí se visualiza el resultado de la select por pantalla. Obligatorio (valor por defecto 0)

    Salida :
      Mensajes T_IAX_MENSAJES

   Retorna : REF CURSOR.
   ********************************************************************************/
   FUNCTION f_get_datos_fe_vida(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfhasta IN DATE,
      pngenerar IN NUMBER DEFAULT 0,
      pnpantalla IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*******************************************************************************
    FUNCION   F_GENERAR_FE_VIDA
    -función que genera el fichero con las pólizas a las cuales se les debe enviar la carta de fe de vida
        y crea un apunte en la Agenda de dichas pólizas indicando que se ha enviado la carta.
    -Llamará a la función PAC_MD_MAP.F_EJECUTA
    Parámetros:
     Entrada :
     1.    psproces IN. Identificador del proceso. Obligatorio si pngenerar = 1.
     2.    pcempres IN. Identificador de la empresa. Obligatorio.
     3.   pcramo IN. Identificador del ramo.
     4.   psproduc IN. Identificador del producto.
     5.   pcagente IN. Identificador del agente.
     6.   pnpoliza IN. Número de póliza.
     7.   pncertif IN. Número de certificado.
     8.   pfhasta. IN Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
     9.   pngenerar IN. Identificador de generación de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)


     Salida :
      10. sproces OUT. Identificador del proceso
       Mensajes T_IAX_MENSAJES

    Retorna : number 0 ok, 1 error
    ********************************************************************************/
   FUNCTION f_generar_fe_vida(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfhasta IN DATE,
      pngenerar IN NUMBER DEFAULT 0,
      sproces OUT NUMBER,
      pnomfich OUT VARCHAR2,
      vtimp OUT t_iax_impresion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*******************************************************************************
   FUNCION  F_GET_CONSULTA_FE_VIDA
   -función que devuelve las pólizas que tienen un apunte en la Agenda de tipo 31.-Envío de Cartas de Fe de vida que cumplan con los filtros seleccionados

   Parámetros:
    Entrada :
    1.   pcidioma. Identificador del idioma.
    2.   pcempres. Identificador de la empresa. Obligatorio.
    3.   psproduc. Identificador del producto.
    4.   pfinicial. Fecha inicio.
    5.   pffinal. Fecha final
    6.   pcramo. Identificador del ramo.
    7.   pcagente. Identificador del agente.
    8.   pcagrpro. Identificador de la agrupación de la póliza.

    Salida :
      Mensajes T_IAX_MENSAJES

   Retorna : REF CURSOR.
   ********************************************************************************/
   FUNCTION f_get_consulta_fe_vida(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*******************************************************************************
   FUNCION  F_GET_RENTAS_BLOQUEADAS
   -función que devuelve que devuelve las pólizas con rentas bloqueadas debido a que no se ha certificado todavía la fe de vida de los titulares del contrato
   Parámetros:
    Entrada :
       1.   pcidioma. Identificador del idioma.
        2.  pcempres. Identificador de la empresa. Obligatorio.
        3.  psproduc. Identificador del producto.
        4.  pfinicial. Fecha inicio.
        5.  pffinal. Fecha final
        6.  pcramo. Identificador del ramo.
        7.  pcagente. Identificador del agente.
        8.  pcagrpro. Identificador de la agrupación de la póliza.



    Salida :
      Mensajes T_IAX_MENSAJES

   Retorna : REF CURSOR.
   ********************************************************************************/
   FUNCTION f_get_rentas_bloqueadas(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*******************************************************************************
    FUNCION   F_CONFIRMAR_FE_VIDA
    -función que se encargará de validar y confirmar la certificación de fe de vida de los titulares de una póliza.
    -Llamará a la función función PAC_FE_DE_VIDA.F_CONFIRMAR_FE_VIDA
    Parámetros:
     Entrada :

         1.  pnpoliza. number Número de póliza.
         2.  pncertif. number Número de certificado.
         3.  ptlista : sperson de los perceptores que han presentado su fe de vida
     Salida :
       Mensajes T_IAX_MENSAJES

    Retorna : number 0 ok, 1 error
    ********************************************************************************/
   FUNCTION f_confirmar_fe_vida(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      ptlista IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_fe_vida;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FE_VIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FE_VIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FE_VIDA" TO "PROGRAMADORESCSI";
