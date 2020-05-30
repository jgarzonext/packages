--------------------------------------------------------
--  DDL for Package PAC_IAX_BLOQUEO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_BLOQUEO" AS
/******************************************************************************
 NOMBRE: PAC_BLOQUEO
 PROPOSITO: Funciones para el bloqueo/desbloqueo/pignoracion/despignoarcion de
 polizas

 REVISIONES:
 Ver Fecha Autor Descripcion
 --------- ---------- --------------- ------------------------------------
 1.0 12/05/2009 APD 1. Creacion del package (Bug 9390)
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
   Funcion que realiza la insercion de los movimientos bloqueo, desbloqueo,
   pignoracion y despignoracion de polizas
   param in psseguro : id. de la poliza
   param in pcmotmov : codigo motivo movimiento
   param in pfmovini : fecha inicio movimiento
   param in pfmovfin : fecha fin movimiento
   param in pttexto : descripcion del movimiento de bloqueo/pignoracion
   param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
   param in pimporte : importe de pignoracion
   param in pcausa : tipo de la causa
   return : Error
   *************************************************************************/
   FUNCTION f_set_mov(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pfmovini IN DATE,
      pfmovfin IN DATE,
      pttexto IN VARCHAR2,
      pttexto2 IN VARCHAR2,
      pimporte IN NUMBER,
      psperson IN NUMBER,
      pcopcional IN NUMBER,
      pnrango IN NUMBER,
      pncolater IN NUMBER,
      pnmovimi IN NUMBER,
      pmodo IN VARCHAR2,
      pcausa IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que sirve para recuperar la descripcion del movimiento de
   desbloqueo o despignoracion
   param in psseguro : id. de la poliza
   param in pcmotmov : codigo motivo movimiento
   param in pnbloqueo : fecha inicio movimiento
   return : descripcion del movimiento
   *************************************************************************/
   FUNCTION f_get_textdesbloq(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pnbloqueo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
   Funcion que valida la situacion de una poliza para realizar un
   bloqueo/desbloqueo o pignoracion/despignoracion
   param in psseguro : id. de la poliza
   param in pcmotmov : codigo motivo movimiento
   return : Error
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
   param in pnmovimi : Nzmero de movimiento -- BUG 27766
   param out pquery : consulta a realizar construida en funcion de los
   parametros
   return : Error
   *************************************************************************/
   FUNCTION f_get_mov(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que devuelve el codigo del motivo de movimiento (bloqueo, desbloqueo,
   pignoracion, despignoracion)
   param in tmotmov : descripcion del codigo de movimiento
   return : Error
   *************************************************************************/
   FUNCTION f_get_cmotmov(tmotmov IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que retorna la lista de personas que contienen el parametro en PER_PARPERSONAS
   con el valor igual a 0, mas los existentes en los bloqueos asociados a la poliza
   param in psseguro : Codigo del seguro
   param in pcmotmov : Motivo del movimiento
   param in pmodo : Modo ALTA_BENEF / ELIMINAR_BENEF
   param in pnmovimi : Nzmero de movimiento
   return : Error
   bug 27766
   *************************************************************************/
   FUNCTION f_get_pignoradores(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pmodo IN VARCHAR2,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que retorna los registros de la tabla bloqueo que no se encuentran finalizados
   en el tiempo.
   param in psseguro : Codigo del seguro
   return : Error
   bug 27766
   *************************************************************************/
   FUNCTION f_get_bloqueos(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- NUEVO PLEDGIE INI
   FUNCTION f_update_pledged(
      psseguro IN NUMBER,
      pcmotmov IN VARCHAR2,
      pnmovimi IN NUMBER,
      pttexto_ant IN VARCHAR2,
      psperson_ant IN NUMBER,
      pnrango_ant IN NUMBER,
      pncolater_ant IN NUMBER,
      pfmovini_ant IN DATE,
      pttexto_upd IN VARCHAR2,
      psperson_upd IN NUMBER,
      pnrango_upd IN NUMBER,
      pncolater_upd IN NUMBER,
      pfmovini_upd IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
-- NUEVO PLEDGIE FIN
END pac_iax_bloqueo;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BLOQUEO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BLOQUEO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BLOQUEO" TO "PROGRAMADORESCSI";
