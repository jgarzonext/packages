--------------------------------------------------------
--  DDL for Package PAC_FE_VIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FE_VIDA" IS
/******************************************************************************
   NOMBRE:       PAC_FE_DE_VIDA
   PROPÓSITO: Funcions per gestionar Cartes de Fe de Vida

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/09/2010   ETM                1. Creación del package.
   2.0        20/01/2011   APD                2. Bug 15289: Cartas Fe de Vida
   3.0        28/01/2013   MDS                3. 0024743: (POSDE600)-Desarrollo-GAPS Tecnico-Id 146 - Modif listados para regional sucursal
   4.0        02/05/2013   JMF                4. 0025623 (POSDE200)-Desarrollo-GAPS - Comercial - Id 56
******************************************************************************/

   /*************************************************************************
   GLOBALS
*************************************************************************/
   poliza         ob_iax_poliza;   --Objecte pòlisa
   asegurado      ob_iax_asegurados;   --Objecte assegurat
   accesorios     ob_iax_autaccesorios;   --Objecte accesori
   taccesorios    t_iax_autaccesorios;   --Objecte col·lecció accesoris
   gidioma        NUMBER := pac_iax_common.f_get_cxtidioma();   --Código idioma

   FUNCTION f_valor_substr(pstr IN VARCHAR2, pttexto IN VARCHAR2, pseparador IN VARCHAR2)
      RETURN VARCHAR2;

   -- Bug 15289 - APD - 20/01/2011 - se crea la funcion
   /*************************************************************************
   Función  F_PERCEPTORES_RENTA
   Devuelve las personas que reciben la renta.
   Solo se mostraran aquellas personas a las cuales se les ha enviado la carta de
   fe de vida previamente y que aun no han confirmado su fe de vida
      param in psseguro: identificador del seguro
         Retorno: v_squery:Devuelve la select de los perceptores de la renta
   *************************************************************************/
   FUNCTION f_perceptores_renta(psseguro IN NUMBER)
      RETURN VARCHAR2;

   -- Fin Bug 15289 - APD - 20/01/2011

   /*************************************************************************
   Función  F_APUNTE_AGENDA
   FUNCION que inserta un apunte en la agenda de aquellas pólizas que deben enviar la carta de fe de vida .
     Se buscan las pólizas que deben enviar la carta de fe de vida y que cumplan con los requisitos (pólizas que devuelve el ref cursor de la función pac_propio.f_get_datos_apunte_fe_vida).
    Para cada una de éstas pólizas se realiza un apunte en la agenda (pac_agensegu.f_set_datos_apunte).

    1.    psproces IN. Identificador del proceso.
    2.    pcempres IN. Identificador de la empresa. Obligatorio.
    3.    pcramo IN. Identificador del ramo.
    4.    psproduc IN. Identificador del producto.
    5.    pcagente IN. Identificador del agente.
    6.   pnpoliza IN. Número de póliza.
    7.   pncertif IN. Número de certificado.
    8.   pfhasta IN. Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
    9.   pngenerar IN. Identificador de generación de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)
    10.  sproces OUT. Identificador del proceso.

   param in out mensajes   : mensajes de error
          return              : sys_Refcursor
   *************************************************************************/
   FUNCTION f_apunte_agenda(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfhasta IN DATE,
      pngenerar IN NUMBER DEFAULT 0,
      sproces OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Función F_GET_CONSULTA_FE_VIDA
    Devuelved un VARCHAR2 con la select de las pólizas que tienen un apunte en la Agenda de tipo 31.-Envío de Cartas de Fe de Vida
    Nota: Se puede realizar la consulta de aquellos contratos a los cuales se les ha enviado la Carta de Fe de Vida. Dichos contratos deben cumplir los requisitos siguientes:
    Contratos vigentes y no retenidos por siniestro o rescate (csituac = 0 y pac_motretenction.f_esta_retenica_sin_resc = 0)
     Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida; agensegu.ctipreg = 31).
    El apunte en la agenda se debe de haber realizado entre las fechas inicial y final seleccionadas (agensegu.falta >=pfinicial y agensegu.falta <= pffinal)

    Parametros
     1.   pcidioma. Identificador del idioma.
     2.   pcempres. Identificador de la empresa. Obligatorio.
     3.   psproduc. Identificador del producto.
     4.   pfinicial. Fecha inicio.
     5.   pffinal. Fecha final
     6.   pcramo. Identificador del ramo.
     7.   pcagente. Identificador del agente.
     8.   pcagrpro. Identificador de la agrupación de la póliza.
    param in out mensajes   : mensajes de error
          return             VARCHAR2
    *************************************************************************/
   FUNCTION f_get_consulta_fe_vida(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     Función  F_GET_RENTAS_BLOQUEADAS
     función que devolverá un VARCHAR2 con la select de las pólizas con rentas bloqueadas debido a que no se ha certificado todavía la fe de vida de los titulares del contrato
     Nota: Se puede realizar la consulta de aquellos contratos a los cuales se les ha enviado la Carta de Fe de Vida. Dichos contratos deben cumplir los requisitos siguientes:
          Contratos vigentes y no retenidos por siniestro o rescate (csituac = 0 y pac_motretenction.f_esta_retenica_sin_resc = 0)
          Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida; agensegu.ctipreg = 31).
          El apunte en la agenda se debe de haber realizado entre las fechas inicial y final seleccionadas (agensegu.falta >=pfinicial y agensegu.falta <= pffinal)
          La póliza está bloqueada (pagosrenta.cblopag = 5.-Bloqueada)

      parametros
      1.   pcidioma. Identificador del idioma.
      2.   pcempres. Identificador de la empresa. Obligatorio.
      3.   psproduc. Identificador del producto.
      4.   pfinicial. Fecha inicio.
      5.   pffinal. Fecha final
      6.   pcramo. Identificador del ramo.
      7.   pcagente. Identificador del agente.
      8.   pcagrpro. Identificador de la agrupación de la póliza.
     param in out mensajes   : mensajes de error
           return             VARCHAR2
     *************************************************************************/
   FUNCTION f_get_rentas_bloqueadas(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
   Función  F_CONFIRMAR_FE_VIDA
   función que se encargará de validar y confirmar la certificación de fe de vida de los titulares de una póliza
     param in psseguro : nº de seguro
           in ptlista : sperson de los perceptores que han presentado su fe de vida
         Retorno: 0.-Todo Ok; código error.-si ha habido algún error
   *************************************************************************/
   FUNCTION f_confirmar_fe_vida(psseguro IN NUMBER, ptlista IN VARCHAR2)
      RETURN NUMBER;

   /************************************************************************************************************************************
        funcion P_PROCESO_CERTIFICA_FE_VIDA
         nota:
        Se crea un proceso de certificación de fe de vida, que se debe lanzar diariamente, para controlar
        si se bloquea una póliza en caso de que se haya enviado a los titulares del contrato la solicitud
        de Fe de Vida y pasados dos meses (según parametrización) desde su envío no se hayan aún personado o presentado su
        certificado médico que justifique su fe de vida en su oficina.

          param in psproces : nº de proceso
          param in psseguro : nº de seguro
           Retorno: numero de proceso
        ******************************************************************************************************************************************/
   PROCEDURE p_proceso_certifica_fe_vida(
      psseguro IN NUMBER DEFAULT NULL,
      psproces IN OUT NUMBER);

-- BUG 24743 - MDS - 28/01/2013
-- versión ampliada de F_GET_RENTAS_BLOQUEADAS, que incluye los campos Regional y Sucursal para el map 641 de POS
-- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
   /*************************************************************************
     Función  F_GET_RENTAS_BLOQUEADAS2
     función que devolverá un VARCHAR2 con la select de las pólizas con rentas bloqueadas debido a que no se ha certificado todavía la fe de vida de los titulares del contrato
     Nota: Se puede realizar la consulta de aquellos contratos a los cuales se les ha enviado la Carta de Fe de Vida. Dichos contratos deben cumplir los requisitos siguientes:
          Contratos vigentes y no retenidos por siniestro o rescate (csituac = 0 y pac_motretenction.f_esta_retenica_sin_resc = 0)
          Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida; agensegu.ctipreg = 31).
          El apunte en la agenda se debe de haber realizado entre las fechas inicial y final seleccionadas (agensegu.falta >=pfinicial y agensegu.falta <= pffinal)
          La póliza está bloqueada (pagosrenta.cblopag = 5.-Bloqueada)

      parametros
      1.   pcidioma. Identificador del idioma.
      2.   pcempres. Identificador de la empresa. Obligatorio.
      3.   psproduc. Identificador del producto.
      4.   pfinicial. Fecha inicio.
      5.   pffinal. Fecha final
      6.   pcramo. Identificador del ramo.
      7.   pcagente. Identificador del agente.
      8.   pcagrpro. Identificador de la agrupación de la póliza.
      9.   pperage   sperson del agente
     param in out mensajes   : mensajes de error
           return             VARCHAR2
     *************************************************************************/
   FUNCTION f_get_rentas_bloqueadas2(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      pperage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

-- BUG 24743 - MDS - 28/01/2013
-- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
-- versión ampliada de F_GET_CONSULTA_FE_VIDA, que incluye los campos Regional y Sucursal para el map 642 de POS
   /*************************************************************************
    Función F_GET_CONSULTA_FE_VIDA2
    Devuelved un VARCHAR2 con la select de las pólizas que tienen un apunte en la Agenda de tipo 31.-Envío de Cartas de Fe de Vida
    Nota: Se puede realizar la consulta de aquellos contratos a los cuales se les ha enviado la Carta de Fe de Vida. Dichos contratos deben cumplir los requisitos siguientes:
    Contratos vigentes y no retenidos por siniestro o rescate (csituac = 0 y pac_motretenction.f_esta_retenica_sin_resc = 0)
     Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida; agensegu.ctipreg = 31).
    El apunte en la agenda se debe de haber realizado entre las fechas inicial y final seleccionadas (agensegu.falta >=pfinicial y agensegu.falta <= pffinal)

    Parametros
     1.   pcidioma. Identificador del idioma.
     2.   pcempres. Identificador de la empresa. Obligatorio.
     3.   psproduc. Identificador del producto.
     4.   pfinicial. Fecha inicio.
     5.   pffinal. Fecha final
     6.   pcramo. Identificador del ramo.
     7.   pcagente. Identificador del agente.
     8.   pcagrpro. Identificador de la agrupación de la póliza.
     9.   pperage   sperson del agente
    param in out mensajes   : mensajes de error
          return             VARCHAR2
    *************************************************************************/
   FUNCTION f_get_consulta_fe_vida2(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      pperage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;
END pac_fe_vida;

/

  GRANT EXECUTE ON "AXIS"."PAC_FE_VIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FE_VIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FE_VIDA" TO "PROGRAMADORESCSI";
