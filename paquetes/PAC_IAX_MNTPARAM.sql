--------------------------------------------------------
--  DDL for Package PAC_IAX_MNTPARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_MNTPARAM" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_MNTPARAM
   PROPÓSITO:   Funciones para el mantenimiento de las tablas de parámetros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        01/04/2007   JAS               1. Creación del package.
   2.0        18/02/2009   AMC               2. Codificación funciones GET,SET por MOTIVO MOVIMIENTO
******************************************************************************/
   FUNCTION f_get_detparam(pcparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la descripción del parámetro de entrada
      param in pcparam   : código de parámetro
      param out mensajes : mensajes de error
      return             : descripción del parámetro -> Si ha ido bién
                           NULL -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_get_descparam(pcparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

-- ===========================================================================
--  P A R A M E T R O S  C O N E X I O N
-- ===========================================================================
   FUNCTION f_get_conparam(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_conparam(
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_elimconparam(pcparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- ===========================================================================
--  P A R A M E T R O S  I N S T A L A C I O N
-- ===========================================================================
   FUNCTION f_get_insparam(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_insparam(
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_eliminsparam(pcparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- ===========================================================================
--  P A R A M E T R O S  E M P R E S A
-- ===========================================================================
   FUNCTION f_get_empparam(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_empparam(
      pcempres IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_elimempparam(
      pcempres IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- ===========================================================================
--  P A R A M E T R O S  P R O D U C T O
-- ===========================================================================
   FUNCTION f_get_prodparam(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_prodparam(
      psproduc IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_elimprodparam(
      psproduc IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- ===========================================================================
--  P A R A M E T R O S  A C T I V I D A D
-- ===========================================================================
   FUNCTION f_get_actparam(psproduc IN NUMBER, pcactivi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_actparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_elimactparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_actprod(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_actividades;

-- ===========================================================================
--  P A R A M E T R O S  G A R A N T I A
-- ===========================================================================
   FUNCTION f_get_garparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_garparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_elimgarparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- ===========================================================================
--  P A R A M E T R O S  POR MOTIVO MOVIMIENTO
-- ===========================================================================
-- Bug 8789 - 18/02/2009 - AMC - Se crean las funciones para Parámetros Movimiento
   FUNCTION f_get_movparam(psproduc IN NUMBER, pcmotmov IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_elimmovparam(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      pcparmot IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_motmovparam(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
--Fi Bug 8789 - 18/02/2009 - AMC - Se crean las funciones para Parámetros Movimiento
END pac_iax_mntparam;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPARAM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPARAM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPARAM" TO "PROGRAMADORESCSI";
