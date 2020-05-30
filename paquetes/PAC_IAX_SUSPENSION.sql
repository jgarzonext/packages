--------------------------------------------------------
--  DDL for Package PAC_IAX_SUSPENSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_SUSPENSION" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_SUSPENSION
   PROP¿¿SITO: Funciones para la suspensi¿n/reinicio de p¿lizas

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/11/2012   FAL                1. Creaci¿¿n del package (Bug 0024450)
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
      Funcion que realiza la insercion de los movimientos suspensi¿n/reinicio de polizas
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfrenova : fecha nueva vigencia en reinicios
      param in pttexto  : descripcion del movimiento de suspensi¿n/reinicio
      param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
      return            : Error
   *************************************************************************/
   FUNCTION f_set_mov(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pfmovini IN DATE,
      pfrenova IN DATE,
      pttexto IN VARCHAR2,
      pttexto2 IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que sirve para recuperar la descripcion del movimiento de suspensi¿n/reinicio
      param in psseguro  : id. de la poliza
      param in pcmotmov  : codigo motivo movimiento
      param in pnsuspens : fecha inicio movimiento
      return            : descripcion del movimiento
   *************************************************************************/
/*
   FUNCTION f_get_textdescsusp(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pnsuspens IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;
*/

   /*************************************************************************
      Funcion que valida la situacion de una poliza para realizar una suspensi¿n/reinicio
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_crea_mov(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que inicializa los campos de pantalla en funcion de los
      parametros de entrada
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param out pquery  : consulta a realizar construida en funcion de los
                          parametros
      return            : Error
   *************************************************************************/
   FUNCTION f_get_mov(psseguro IN NUMBER, ptmotmov IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Funcion que devuelve el codigo del motivo de movimiento suspensi¿n/reinicio
      param in tmotmov : descripcion del codigo de movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_get_cmotmov(tmotmov IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- funcion para recuperar que boton ense¿ar
   FUNCTION f_get_prox_mov(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_suspension;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SUSPENSION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SUSPENSION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SUSPENSION" TO "PROGRAMADORESCSI";
