--------------------------------------------------------
--  DDL for Package PAC_MNTPREGUNPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MNTPREGUNPROD" AS
/******************************************************************************
   NOMBRE:       PAC_MD_MNTPROD
   PROPÓSITO: Funciones para mantenimiento productos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/04/2010   AMC                1. Creación del package.
******************************************************************************/

   /*************************************************************************
      Recupera las posibles respuestas de una pregunta
      param in pcpregun : codigo de pregunta
      param in pcidioma : código de idioma

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_respuestas(pcpregun IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Busca preguntas por descripción
      param in ptpregun : texto de la pregunta
      param in pcidioma : código de idioma

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_preguntas(ptpregun IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera el tipo de respuesta de una pregunta
      param in pcpregun : codigo de la pregunta
      param out pctippre : codigo del tipo de pregunta

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_ctippre(pcpregun IN NUMBER, pctippre OUT NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      Recupera la lista con las diferentes respuestas
      param in pcpregun : codigo de la pregunta
      param in pcidioma : codigo de idioma

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_listrespue(pcpregun IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

    /*************************************************************************
      Asigna la pregunta a nivel de producto/actividad/garantia
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param in pcpretip : tipo respuesta
      param in pnpreord : orden de la pregunta
      param in ptprefor : formula para cálculo respuesta
      param in pcpreobl : Obligatoria u opcional
      param in pnpreimp : Orden de impresión
      param in pcresdef : Respuesta por defecto
      param in pcofersn : Aparece en ofertas
      param in ptvalfor : fórmula para validación respuesta
      param in pcmodo   : Modo
      param in pcnivel  : Nivel, poliza o riesgo
      param in pctarpol : Retarificar
      param in pcvisible : Pregunta visible
      param in pcesccero : Certificado cero
      param in pcvisiblecol : Visible colectivos
      param in pcvisiblecert : Visible certificados
      param in pcrecarg : Recarga de preguntas

      Bug 13953 - 14/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_set_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcpretip IN NUMBER,
      pnpreord IN NUMBER,
      ptprefor IN VARCHAR2,
      pcpreobl IN NUMBER,
      pnpreimp IN NUMBER,
      pcresdef IN NUMBER,
      pcofersn IN NUMBER,
      ptvalfor IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pcnivel IN VARCHAR2,
      pctarpol IN NUMBER,
      pcvisible IN NUMBER,
      pcesccero IN NUMBER,
      pcvisiblecol IN NUMBER,
      pcvisiblecert IN NUMBER,
      pcrecarg IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      Devuel los datos de una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param out pcpretip : tipo respuesta
      param out pnpreord : orden de la pregunta
      param out ptprefor : formula para cálculo respuesta
      param out pcpreobl : Obligatoria u opcional
      param out pnpreimp : Orden de impresión
      param out pcresdef : Respuesta por defecto
      param out pcofersn : Aparece en ofertas
      param out ptvalfor : fórmula para validación respuesta
      param out pcmodo   : Modo
      param out pcnivel  : Nivel, poliza o riesgo
      param out pctarpol : Retarificar
      param out pcvisible : Pregunta visible
      param out pcesccero : Certificado cero
      param out pcvisiblecol : Visible colectivos
      param out pcvisiblecert : Visible certificados
      param out pcrecarg : Recarga de preguntas

      Bug 13953 - 14/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcpretip OUT NUMBER,
      pnpreord OUT NUMBER,
      ptprefor OUT VARCHAR2,
      pcpreobl OUT NUMBER,
      pnpreimp OUT NUMBER,
      pcresdef OUT NUMBER,
      pcofersn OUT NUMBER,
      ptvalfor OUT VARCHAR2,
      pcmodo OUT VARCHAR2,
      pcnivel OUT VARCHAR2,
      pctarpol OUT NUMBER,
      pcvisible OUT NUMBER,
      pcesccero OUT NUMBER,
      pcvisiblecol OUT NUMBER,
      pcvisiblecert OUT NUMBER,
      pcrecarg OUT NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      Borrar una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia

      Bug 13953 - 19/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      Comprueba si se puede asignar una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia

      Bug 13953 - 23/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_asignar(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;
END pac_mntpregunprod;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNTPREGUNPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNTPREGUNPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNTPREGUNPROD" TO "PROGRAMADORESCSI";
