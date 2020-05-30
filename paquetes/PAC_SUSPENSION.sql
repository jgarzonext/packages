--------------------------------------------------------
--  DDL for Package PAC_SUSPENSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SUSPENSION" AS
/******************************************************************************
   NOMBRE:    pac_suspension
   PROP¿SITO: Funciones para la suspensi¿n/reinicio de p¿lizas

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/11/2012   FAL                1. Creaci¿¿n del package (Bug 0024450)
   2.0        02/12/2013   DCT                2. 0029229: LCOL_T010-LCOL - Revision incidencias qtracker (VIII)
******************************************************************************/
   TYPE rec_recibos IS RECORD(
      nrecibo        NUMBER,
      fmovini        DATE,
      fefecto        DATE,
      fvencim        DATE
   );
   -- CONF-274-25/11/2016-JLTS- Ini
   vcod_reinicio   NUMBER := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'COD_REINICIO'), 392);
   -- CONF-274-25/11/2016-JLTS- Fin

   TYPE rec_cob IS TABLE OF rec_recibos
      INDEX BY BINARY_INTEGER;

   /*************************************************************************
      Funcion que realiza la insercion de los movimientos suspensi¿n/reinicio de polizas
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfrenova : fecha nueva vigencia en reinicios
      param in pttexto  : descripcion del movimiento de suspensi¿n/reinicio
      param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
      --param in pimporte : importe de suspensi¿n/reinicio
      param in number default:  0- Suspende y No Trata Recibos, 1- Suspende y Trata Recibos y 2-No Suspende y Trata Recibos
      return            : Error
   *************************************************************************/
   FUNCTION f_set_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfmovini IN DATE,
      pfrenova IN DATE,
      pttexto IN VARCHAR2,
      pttexto2 IN VARCHAR2,
      ptratarec IN NUMBER DEFAULT 1,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que sirve para recuperar la descripcion del movimiento de suspensi¿n/reinicio
      param in psseguro  : id. de la poliza
      param in pcmotmov  : codigo motivo movimiento
      param in pnsuspens : fecha inicio movimiento
      return            : descripcion del movimiento
   *************************************************************************/
/*
   FUNCTION f_get_textdescsusp(psseguro IN NUMBER, pcmotmov IN NUMBER, pnsuspens IN NUMBER)
      RETURN VARCHAR2;
*/

   /*************************************************************************
      Funcion que valida la situacion de una poliza para realizar una suspensi¿n/reinicio
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_crea_mov(psseguro IN NUMBER, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que realiza la validacion para la insercion de un movimiento de
      suspensi¿n/reinicio de la poliza
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfrenova : fecha nueva vigencia en reinicios
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfmovini IN DATE,
      pfrenova IN DATE)
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
   FUNCTION f_get_mov(psseguro IN NUMBER, pcmotmov IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER;

   -- funcion para recuperar que boton ense¿ar
   FUNCTION f_get_prox_mov(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_mov_est(psseguro IN NUMBER, pnmovimi IN NUMBER, pcmotmov IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_tratar_certificados_reinicio(
      psseguro IN NUMBER,
      pfcarpro IN DATE,
      pfmovini IN DATE,
      pcmotmov IN NUMBER,
      pfrenova IN DATE,
      psproces IN NUMBER,
      plista IN OUT t_lista_id,
      pttexto IN VARCHAR2)
      RETURN NUMBER;

   --BUG27048 - INICIO - DCT - 11/11/2013
   FUNCTION f_genera_rec_prima_minima(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfcarpro IN DATE,
      pfmovini IN DATE,
      psproces IN NUMBER,
      pnrecibo OUT NUMBER)
      RETURN NUMBER;

--BUG27048 - FIN - DCT - 11/11/2013

   /*************************************************************************
        Funcion que realiza la insercion de los movimientos suspensi¿n/reinicio de polizas
        param in psseguro : id. de la poliza
        param in pcmotmov : codigo motivo movimiento
        param in pfmovini : fecha inicio movimiento
        param in pfrenova : fecha nueva vigencia en reinicios
        param in pttexto  : descripcion del movimiento de suspensi¿n/reinicio
        param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
        --param in pimporte : importe de suspensi¿n/reinicio
        param in number default:  0- Suspende y No Trata Recibos, 1- Suspende y Trata Recibos y 2-No Suspende y Trata Recibos
        return            : Error
     *************************************************************************/
   FUNCTION f_call_set_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfmovini IN DATE,
      pfrenova IN DATE,
      pttexto IN VARCHAR2,
      pttexto2 IN VARCHAR2,
      ptratarec IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   --BUG29229 - INICIO - DCT - 09/12/2013
   FUNCTION f_trata_recibo_suspende(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfecha IN DATE,
      pctiprec IN NUMBER)
      RETURN NUMBER;

--BUG29229 - FIN - DCT - 09/12/2013

   --BUG29229 - INICIO - DCT - 13/12/2013
   FUNCTION f_tratar_certifs_reini_norec(
      psseguro IN NUMBER,
      pfcarpro IN DATE,
      pfmovini IN DATE,
      pcmotmov IN NUMBER,
      pfrenova IN DATE,
      psproces IN NUMBER,
      plista IN OUT t_lista_id,
      pttexto IN VARCHAR2)
      RETURN NUMBER;
--BUG29229 - FIN - DCT - 13/12/2013
END pac_suspension;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUSPENSION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUSPENSION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUSPENSION" TO "PROGRAMADORESCSI";
