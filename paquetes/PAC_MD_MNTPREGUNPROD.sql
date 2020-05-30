--------------------------------------------------------
--  DDL for Package PAC_MD_MNTPREGUNPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_MNTPREGUNPROD" AS
/******************************************************************************
   NNOMBRE:       PAC_MD_MNTPREGUNPROD
   PROPÓSITO: Funciones para mantenimiento preguntas por productos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/04/2010   AMC              1. Creación del package.

******************************************************************************/

   /*************************************************************************
        Busca preguntas por descripción
        param in ptpregun : texto de la pregunta
        param in pcidioma : código de idioma
        param out mensajes
        return : ref cursor

        Bug 13953 - 07/04/2010 - AMC
     *************************************************************************/
   FUNCTION f_get_preguntas(
      ptpregun IN VARCHAR2,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera el texto de una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param in pcidioma : código de idioma
      param out pctipre : codigo tipo de respuesta
      param out pdescpreg : descripcion de la pregunta
      param out mensajes
      return : Código de error (0: operación correcta sino 1)

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_descpregun(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcidioma IN NUMBER,
      pctippre OUT NUMBER,
      pdescpreg OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera la lista con las diferentes respuestas
      param in pcpregun : codigo de la pregunta
      param in pctippre : codigo tipo de pregunta
      param in pcidioma : codigo de idioma
      param out mensajes : mensajes de error

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_listrespue(
      pcpregun IN NUMBER,
      pctippre IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      param out mensajes : mensajes de error

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
      pcmodo IN NUMBER,
      pcnivel IN NUMBER,
      pctarpol IN NUMBER,
      pcvisible IN NUMBER,
      pcesccero IN NUMBER,
      pcvisiblecol IN NUMBER,
      pcvisiblecert IN NUMBER,
      pcrecarg IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuel los datos de una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param out propreguntas: preguntas producto
      param out actpreguntas: preguntas actividad
      param out garpreguntas: preguntas garantia
      param out mensajes: mensajes de error

      Bug 13953 - 14/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      propreguntas OUT ob_iax_prodpreguntas,
      pactpreguntas OUT ob_iax_prodpregunacti,
      pgarpreguntas OUT ob_iax_prodpregunprogaran,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Borrar una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param out mensajes: mensajes de error

      Bug 13953 - 19/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_mntpregunprod;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTPREGUNPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTPREGUNPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTPREGUNPROD" TO "PROGRAMADORESCSI";
