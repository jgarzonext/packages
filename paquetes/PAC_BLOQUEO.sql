--------------------------------------------------------
--  DDL for Package PAC_BLOQUEO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_BLOQUEO" AS
/******************************************************************************
   NOMBRE:    PAC_BLOQUEO
   PROP¿SITO: Funciones para el bloqueo/desbloqueo/pignoracion/despignoarcion de
              p¿lizas

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/05/2009   APD                1. Creaci¿n del package (Bug 9390)
******************************************************************************/

   /*************************************************************************
      Funcion que realiza la insercion de los movimientos bloqueo, desbloqueo,
      pignoracion y despignoracion de polizas
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfmovfin : fecha fin movimiento
      param in pttexto  : descripcion del movimiento de bloqueo/pignoracion
      param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
      param in pimporte : importe de pignoracion
      param in pcausa   : tipo de la causa
      return            : Error
   *************************************************************************/
   FUNCTION f_set_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
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
      pcausa IN NUMBER DEFAULT NULL,
      pbenefici OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que sirve para recuperar la descripcion del movimiento de
      desbloqueo o despignoracion
      param in psseguro  : id. de la poliza
      param in pcmotmov  : codigo motivo movimiento
      param in pnbloqueo : fecha inicio movimiento
      return            : descripcion del movimiento
   *************************************************************************/
   FUNCTION f_get_textdesbloq(psseguro IN NUMBER, pcmotmov IN NUMBER, pnbloqueo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Funcion que valida la situacion de una poliza para realizar un
      bloqueo/desbloqueo o pignoracion/despignoracion
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_crea_mov(psseguro IN NUMBER, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que realiza la validacion para la insercion de un movimiento de
      bloqueo, desbloqueo, pignoracion y despignoracion de la poliza
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfmovfin : fecha fin movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfmovini IN DATE,
      pfmovfin IN DATE,
      pimporte IN NUMBER,
      pmodo IN VARCHAR2)
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
   FUNCTION f_get_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      f_get_pignoradores
        Funcion que retornara la lista de personas que contienen el parametro en PER_PARPERSONAS
        con valor 0, mas los que ya existan en los bloqueos asociados a la poliza
        param in psperson : id. de persona
        param in pcmotmov : Motivo del movimiento
        param in pmodo    : Modo ALTA_BENEF / ELIMINAR_BENEF
        param in pnmovimi : Nzmero de movimiento
        param out pquery  : consulta a realizar construida en funcion de los
                          parametros
        return            : Error
      BUG - 27766
   *************************************************************************/
   FUNCTION f_get_pignoradores(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pmodo IN VARCHAR2,
      pnmovimi IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      f_get_bloqueos
        Funcion que retorna los registros de la tabla bloqueo que se encuentren vigentes
        param in psperson : id. de persona
        param out pquery  : consulta a realizar construida en funcion de los
                          parametros
        return            : Error
      BUG - 27766
   *************************************************************************/
   FUNCTION f_get_bloqueos(psseguro IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        f_valida_bloqueo_vigente
          Funcisn que Verifica la existencia de un bloqueo/pignoracisn vigente con el mismo nzmero de rango
          param in sseguro : id. de la poliza
          param in  pnrango: Nzmero de rango dentro de las pignoraciones
          return                : 0 (todo OK)
                                  <> 0 (ha habido algun error)
        BUG - 27766
     *************************************************************************/
   FUNCTION f_valida_bloqueo_vigente(
      psseguro IN NUMBER,
      pnrango IN NUMBER,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      f_valida_dest_pignoracion
        Funcisn que valida si la persona esta parametrizada para poder
        ser destinatario de una pignoracisn
        param in psperson : id. de persona
        return                : 0 (todo OK)
                                <> 0 (ha habido algun error)
      BUG - 27766
   *************************************************************************/
   FUNCTION f_valida_dest_pignoracion(psperson IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      Funcion que graba en la tabla detmovseguro la informaicon recibida por
      parametros

      param in sseguro : id. de la poliza
      param in nmovimi : id. del movimiento
      param in cmotmov : codigo motivo movimiento
      param in antes : valor antes del suplemento
      param in depues : valor despues del suplemento
      return            : Error
      BUG 27766
   *************************************************************************/
   FUNCTION f_detmovseguro(
      psseguro IN NUMBER,
      pnmovini IN NUMBER,
      pcmotmov IN NUMBER,
      pantes IN VARCHAR2,
      pdespues IN VARCHAR2)
      RETURN NUMBER;

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
      pfmovini_upd IN DATE)
      RETURN NUMBER;

-- NUEVO PLEDGIE FIN
   FUNCTION f_permitir_modificar(
      psseguro IN NUMBER,
      pfinicio IN DATE,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;
END pac_bloqueo;

/

  GRANT EXECUTE ON "AXIS"."PAC_BLOQUEO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BLOQUEO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BLOQUEO" TO "PROGRAMADORESCSI";
