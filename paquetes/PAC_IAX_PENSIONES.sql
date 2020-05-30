--------------------------------------------------------
--  DDL for Package PAC_IAX_PENSIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_PENSIONES" AS
   FUNCTION f_get_planpensiones(
      coddgs IN VARCHAR2,
      fon_coddgs IN VARCHAR2,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnompla IN VARCHAR2,
      ccodpla IN NUMBER,
      planpensiones OUT t_iax_planpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_fonpensiones(
      ccodfon IN NUMBER,
      ccodges IN NUMBER,
      ccoddep IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnomfon IN VARCHAR2,
      fonpensiones OUT t_iax_fonpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_codgestoras(
      ccodges IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnomges IN VARCHAR2,
      codgestoras OUT t_iax_gestoras,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_pdepositarias(
      ccodfon IN NUMBER,
      ccodaseg IN NUMBER,
      ccoddep IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnomdep IN VARCHAR2,
      pdepositarias OUT t_iax_pdepositarias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_promotores(
      cramo IN NUMBER,
      sproduc IN NUMBER,
      npoliza IN NUMBER,
      ccodpla IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      sperson IN NUMBER,
      promotores OUT t_iax_promotores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ob_pdepositarias(
      ccoddep IN NUMBER,
      pdepositarias OUT ob_iax_pdepositarias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ob_codgestoras(
      ccodges IN NUMBER,
      codgestoras OUT ob_iax_gestoras,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ob_fonpensiones(
      ccodfon IN NUMBER,
      fonpensiones OUT ob_iax_fonpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ob_planpensiones(
      ccodpla IN NUMBER,
      planpensiones OUT ob_iax_planpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ob_promotores(
      ccodpla IN NUMBER,
      sperson IN NUMBER,
      promotores OUT ob_iax_promotores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_promotores(ccodpla IN NUMBER, sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_planpensiones(ccodpla IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_fonpensiones(ccodfon IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_codgestoras(ccodges IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_pdepositarias(
      pccodaseg NUMBER,
      pccodfon NUMBER,
      pccoddep NUMBER,
      mensajes OUT t_iax_mensajes)
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
      modo VARCHAR2 DEFAULT 'alta',
      mensajes OUT t_iax_mensajes)
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
      pccodges_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
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
      pccodfon_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
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
      pccodpla_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************
        Funcion para insertar o actualizar los promotores
        param in pccodpla : codigo del plan
        param in psperson : código de la persona
        param in pnpoliza : código de la poliza
        param in pcbancar : código de cuenta bancaria
        param in pnvalparsp : Importe valor participación Servicios Pasados
        param in pctipban : tipo de cuenta
        param out mensajes : mensajes de error

       bug 12362 - 24/12/2009 - AMC
   **************************************************************/
   FUNCTION f_set_promotores(
      pccodpla IN NUMBER,
      psperson IN NUMBER,
      pnpoliza IN NUMBER,
      pcbancar IN VARCHAR2,
      pnvalparsp IN NUMBER,
      pctipban IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ccodfon(
      pccodfon_dgs IN VARCHAR2,
      pccodfon OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ccodges(
      pccodges_dgs IN VARCHAR2,
      pccodges OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_fonpension(
      ccodfon IN NUMBER,
      fonpension OUT ob_iax_fonpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_pensiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PENSIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PENSIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PENSIONES" TO "PROGRAMADORESCSI";
