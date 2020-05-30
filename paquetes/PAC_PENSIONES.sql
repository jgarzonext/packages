--------------------------------------------------------
--  DDL for Package PAC_PENSIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PENSIONES" AS
   /******************************************************************************
     NOMBRE:     PAC_PENSIONES
     PROPÓSITO:  Package para gestionar los planes de pensiones

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        XX/XX/XXXX   XXX                1. Creación del package.
     2.0        10/01/2010   RSC                2. 0017223: Actualización lista ENTIDADES SNCE
     3.0        27/01/2011   DRA                3. 0017051: ENSA101 - Informes ISS: format PDF
   ******************************************************************************/
   FUNCTION f_get_planpensiones(
      coddgs IN VARCHAR2,
      fon_coddgs IN VARCHAR2,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      nnompla IN VARCHAR2,
      pcagente IN NUMBER,
      ccodpla IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER;

   FUNCTION f_get_fonpensiones(
      pccodfon IN NUMBER,
      pccodges IN NUMBER,
      pccoddep IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      nnomfon IN VARCHAR2,
      pcagente IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER;

   FUNCTION f_get_codgestoras(
      pccodges IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      nnomges IN VARCHAR2,
      pcagente IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER;

   FUNCTION f_get_pdepositarias(
      pccodfon IN NUMBER,
      pccodaseg IN NUMBER,
      pccoddep IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      nnomdep IN VARCHAR2,
      pcagente IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER;

   FUNCTION f_get_promotores(
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pccodpla IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER;

   FUNCTION f_del_promotores(pccodpla IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_planpensiones(pccodpla IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_fonpensiones(pccodfon IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_codgestoras(pccodges IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_pdepositarias(pccodaseg NUMBER, pccodfon NUMBER, pccoddep NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_planpensiones(
      pccodpla NUMBER,
      ptnompla VARCHAR2,
      pfaltare DATE,
      pfadmisi DATE,
      pcmodali NUMBER,
      pcsistem NUMBER,
      pccodfon NUMBER,
      pccomerc VARCHAR2,
      picomdep NUMBER,
      picomges NUMBER,
      pcmespag NUMBER,
      pctipren NUMBER,
      pcperiod NUMBER,
      pivalorl NUMBER,
      pclapla NUMBER,
      pnpartot NUMBER,
      pcoddgs VARCHAR2,
      pfbajare DATE,
      pclistblanc NUMBER,
      pccodpla_out OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_fonpensiones(
      pccodfon NUMBER,
      pfaltare DATE,
      psperson NUMBER,
      pspertit NUMBER,
      pfbajare DATE,
      pccomerc VARCHAR2,
      pccodges NUMBER,
      pclafon NUMBER,
      pcdivisa NUMBER,
      pcoddgs VARCHAR2,
      pcbancar VARCHAR2,
      pctipban NUMBER,
      pccodfon_out OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_codgestoras(
      pccodges NUMBER,
      pfalta DATE,
      pfbaja DATE,
      pcbanco NUMBER,
      pcoficin NUMBER,
      pcdc NUMBER,
      pncuenta VARCHAR2,
      psperson NUMBER,
      pspertit NUMBER,
      pcoddgs VARCHAR2,
      ptimeclose VARCHAR2,
      pccodges_out OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_pdepositarias(
      pccodaseg NUMBER,
      pccodfon NUMBER,
      pccoddep NUMBER,
      pfalta DATE,
      pfbaja DATE,
      psperson NUMBER,
      pcctipban NUMBER,
      pccbancar VARCHAR2,
      pcctrasp NUMBER,
      pcbanco NUMBER,
      modo VARCHAR2 DEFAULT 'alta')
      RETURN NUMBER;

   /**************************************************************
        Funcion para insertar o actualizar los promotores
        param in pccodpla : codigo del plan
        param in psperson : código de la persona
        param in pnpoliza : código de la poliza
        param in pcbancar : código de cuenta bancaria
        param in pnvalparsp : Importe valor participación Servicios Pasados
        param in pctipban : tipo de cuenta

       bug 12362 - 24/12/2009 - AMC
   **************************************************************/
   FUNCTION f_set_promotores(
      pccodpla IN NUMBER,
      psperson IN NUMBER,
      pnpoliza IN NUMBER,
      pcbancar IN VARCHAR2,
      pnvalparsp IN NUMBER,
      pctipban IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Función F_GET_CONSULTA_BENEFICIARIOS_FP
    Devuelve un VARCHAR2 con la select a ejecutar en el MAP

    Parametros
     1.   pformato. En CSV o en PDF
     2.   pscaumot. Tipo contingencia
     3.   panyo. Año
     4.   pcrelase. Relacion con el asegurado
          return             VARCHAR2
    *************************************************************************/
   FUNCTION f_get_consulta_benef_fp(
      pformato IN VARCHAR2,
      pscaumot IN NUMBER,
      panyo IN NUMBER,
      pcrelase IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_fonpension(pccodfon IN NUMBER, fonpension IN OUT ob_iax_fonpensiones)
      RETURN NUMBER;

   FUNCTION f_get_timeclose(pccodfon IN NUMBER, pccodges IN NUMBER)
      RETURN VARCHAR2;
END pac_pensiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_PENSIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PENSIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PENSIONES" TO "PROGRAMADORESCSI";
