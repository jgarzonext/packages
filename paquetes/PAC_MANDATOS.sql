--------------------------------------------------------
--  DDL for Package PAC_MANDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MANDATOS" AUTHID CURRENT_USER IS
      /*******************************************************************************
    FUNCION f_set_mandatos
         -- Descripcion
   Parámetros:
    Entrada :
      psperson: Identificador de la persona
      pcnordban: Código unico consecutivo que identifica la cuenta bancaria de la persona
      pctipban: Tipo cuenta bancaria
      pcbancar: Cuenta bancaria
      pccobban: Código de cobrador bancario
      pvencim: Fecha vencimiento
      pseguri: Codigo de seguridad

     Retorna un valor numérico: 0 si ha grabado el mandato y 1 si se ha producido algún error.

   */
   FUNCTION f_set_mandatos(
      pmode IN VARCHAR2,
      psperson IN mandatos.sperson%TYPE,
      pcnordban IN mandatos.cnordban%TYPE,
      pctipban IN mandatos.ctipban%TYPE,
      pcbancar IN mandatos.cbancar%TYPE,
      pccobban IN mandatos.ccobban%TYPE,
      pcestado IN mandatos.cestado%TYPE,
      pvencim IN mandatos.fvencim%TYPE DEFAULT NULL,
      pseguri IN mandatos.tseguri%TYPE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_existe_pers_mandato(
      psperson IN mandatos.sperson%TYPE,
      pcnordban IN mandatos.cnordban%TYPE,
      pmode IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_anular_mandato(
      psperson IN mandatos.sperson%TYPE,
      pcnordban IN mandatos.cnordban%TYPE,
      pmode IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_mandato(
      psperson IN estmandatos.sperson%TYPE,
      pcbancar IN estmandatos.cbancar%TYPE,
      pcmandato OUT estmandatos.cmandato%TYPE)
      RETURN NUMBER;

   FUNCTION f_descbanco(pcbancar IN VARCHAR2, pctipban IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_desccobradorbanc(p_ccobban IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_desctipotarjeta(pctipban IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_codtipotarjeta(pctipban IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_rut(psperson IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_nombre(psseguro IN NUMBER, pperson IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_contactos(psseguro IN NUMBER, pperson IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_numfolio(pcmandato IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_codbanco(pcbancar IN VARCHAR2, pctipban IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_getultaccionmandato(pnumfolio IN mandatos_gestion.numfolio%TYPE)
      RETURN NUMBER;

   FUNCTION f_getultestadomandato(pnumfolio IN mandatos_estados.numfolio%TYPE)
      RETURN VARCHAR2;

   FUNCTION f_getcodultestadomandato(pnumfolio IN mandatos_estados.numfolio%TYPE)
      RETURN NUMBER;

   FUNCTION f_set_mandatos_gestion(
      pnumfolio IN mandatos_gestion.numfolio%TYPE,
      paccion IN mandatos_gestion.accion%TYPE,
      pfproxaviso IN mandatos_gestion.fproxaviso%TYPE,
      pmotrechazo IN mandatos_gestion.motrechazo%TYPE DEFAULT NULL,
      pcomentario IN mandatos_gestion.comentario%TYPE DEFAULT NULL,
      psmandoc_rechazo IN mandatos_gestion.smandoc_rechazo%TYPE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_set_estado_mandato(
      pnumfolio IN mandatos_estados.numfolio%TYPE,
      pcestado IN mandatos_estados.cestado%TYPE)
      RETURN NUMBER;

   FUNCTION f_getmot_rechazo(pnumfolio IN mandatos_gestion.numfolio%TYPE)
      RETURN NUMBER;

   FUNCTION f_getult_nomina(pnumfolio IN mandatos_masiva.numfolio%TYPE)
      RETURN NUMBER;

   FUNCTION f_set_mandatos_masiva(
      pnomina IN mandatos_masiva.nomina%TYPE,
      pnumfolio IN mandatos_masiva.numfolio%TYPE,
      paccion IN mandatos_masiva.accion%TYPE,
      prownum IN NUMBER,
      pcarta IN mandatos_masiva.ncarta%TYPE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_mandato_editable(
      pnominaselec IN mandatos_masiva.nomina%TYPE,
      pnominaultima IN mandatos_masiva.nomina%TYPE,
      psituacion IN mandatos_estados.cestado%TYPE)
      RETURN NUMBER;

   FUNCTION f_get_nomina_mandato(pnumfolio IN mandatos_masiva.numfolio%TYPE)
      RETURN NUMBER;

   PROCEDURE traspaso_tablas_estmandatos(
      psperson IN estmandatos.sperson%TYPE,
      mens OUT VARCHAR2);

   PROCEDURE traspaso_mandatos_seguros(
      psseguro IN NUMBER,
      pssegpol IN NUMBER,
      mens OUT VARCHAR2);

   FUNCTION f_get_estado_mandato(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_mandatos_documentos(piddocgedox IN NUMBER, pnumfolio IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_existe_mandato(pcmandato IN mandatos.cmandato%TYPE, pmode IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_existe_folio(pnumfolio IN mandatos_seguros.numfolio%TYPE)
      RETURN NUMBER;

   FUNCTION f_getcuentabancformateada(ptipban IN NUMBER, pbancar IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_getrolusuari(pcusuari VARCHAR2)
      RETURN VARCHAR2;

-- Inicio Bug 32676 - 20141016 - MMS
/*******************************************************************************
    FUNCION f_vigencia_mandato
         -- Descripcion
   Parámetros:
    Entrada :
      psseguro: Identificador del seguro

     Retorna un 1 cuando el mandato esté vigente.
*/
   FUNCTION f_vigencia_mandato(psseguro NUMBER)
      RETURN NUMBER;
-- Fin Bug 32676 - 20141016 - MMS
END pac_mandatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MANDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MANDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MANDATOS" TO "PROGRAMADORESCSI";
