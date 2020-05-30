--------------------------------------------------------
--  DDL for Package PAC_IAX_CAJA_CHEQUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_CAJA_CHEQUE" AS
   /******************************************************************************
      NOMBRE:     pac_iax_caja_cheque
      PROPÓSITO:  Funciones que gestionan el módulo de CAJA

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        25/03/2013   AFM             1. Creación del package.
   ******************************************************************************/
/*************************************************************************
      Obtiene los cheques filtrados por ncheque o sperson
      param in sperson  : Codigo del Usuario
      param in ncheque : Numero d cheque
      param out mensajes : mensajes de error
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_lee_cheques(
      sperson IN NUMBER,
      ncheque IN VARCHAR2,
      pseqcaja IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

          /*************************************************************************
      Edita el estado y la fecha de los cheques
      param in pscaja : Codigo de cheque
      param in pestado: Estado del cheque
      param in pfecha: Fecha del cheque
      param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_set_estadocheques(
      pscaja IN NUMBER,
      pestado IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

         /*************************************************************************
      Devuelve un la cantidad de veces que este el seq que se le pase en pagos masivos
      param in pscaja : Codigo de cheque
      param out mensajes : mensajes de error
       return             : 0 si no existe en la tabla pagos_masivos
   *************************************************************************/
   FUNCTION f_protestado(pscaja IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
      Inserta registros en el historico de movimientos
      param in seqcaja : Secuencial del movimiento
      param in ncheque : Numero de cheque
      param in cstchq: Estado del cheque (0 pendiente, 1 Aceptado, 3 protestado)
      param in cstchq_ant : Estado del cheque Anterior (0 pendiente, 1 Aceptado, 3 protestado)
      param in festado : Estado del cheque anterior
      param in out mensajes : mensajes de error
       return             : 0 si no existe en la tabla pagos_masivos
   *************************************************************************/
   FUNCTION f_insert_historico(
      seqcaja NUMBER,
      ncheque VARCHAR2,
      cstchq NUMBER,
      cstchq_ant NUMBER,
      festado DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_genera_archivo_cheque(
      fini DATE,
      ffin DATE,
      pcregenera IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;
END pac_iax_caja_cheque;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CAJA_CHEQUE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CAJA_CHEQUE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CAJA_CHEQUE" TO "PROGRAMADORESCSI";
