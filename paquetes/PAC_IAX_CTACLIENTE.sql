--------------------------------------------------------
--  DDL for Package PAC_IAX_CTACLIENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_CTACLIENTE" AS
/******************************************************************************
   NOMBRE:     PAC_IAX_CTACLIENTE
   PROPÓSITO:  Funciones de obtención de datos de CTACLIENTE

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/02/2013   AFM             1. Creación del package.
   3.0        28/04/2015   YDA             3. Se crea la función f_crea_rec_gasto
   4.0        06/05/2015   YDA             4. Se crean las funciones f_get_nroreembolsos y f_actualiza_nroreembol
******************************************************************************/

   /*************************************************************************
       Obtiene los registros de movimientos en CTACLIENTE
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fechaIni     : fecha Inicio movimientos
       param in fechaFin    : fecha Final movimientos
       DatCtaseg out T_IAX_CTACLIENTE : Collection con datos CTACLIENTE
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_obtenermovimientos(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfechaini IN DATE,
      pfechafin IN DATE,
      pcmovimi IN NUMBER,
      pcmedmov IN NUMBER,
      pimporte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Obtiene las polizas asociadas a un cliente
      param in sperson  : Codigo de persona
      param out mensajes : mensajes de error
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_obtenerpolizas(sperson per_personas.sperson%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

           /*************************************************************************
      Obtiene las personas asociadas a una poliza que hayan generado movimientos en la misma
      param in sperson  : Codigo de persona
      param out mensajes : mensajes de error
      return             : referencia de cursor con el listado de personas asociadas
   *************************************************************************/
   FUNCTION f_obtenerpersonas(psseguro seguros.sseguro%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --BUG: 33886/199827
   FUNCTION f_transferible_spl(psseguro NUMBER, mensajes OUT t_iax_mensajes)
      --RDD 22/04/2015
   RETURN NUMBER;

   -- 33886/199825  ACL 23/04/2015
   FUNCTION f_apunte_pago_spl(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pimporte IN NUMBER,
      pncheque IN VARCHAR2 DEFAULT NULL,
      pcestchq IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pccc IN VARCHAR2 DEFAULT NULL,
      pctiptar IN NUMBER DEFAULT NULL,
      pntarget IN NUMBER DEFAULT NULL,
      pfcadtar IN VARCHAR2 DEFAULT NULL,
      pcmedmov IN NUMBER DEFAULT NULL,
      pcmoneop IN NUMBER DEFAULT 1,
      pnrefdeposito IN NUMBER DEFAULT NULL,
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL,
      pdsbanco IN VARCHAR2 DEFAULT NULL,
      pctipche IN NUMBER DEFAULT NULL,
      pctipched IN NUMBER DEFAULT NULL,
      pcrazon IN NUMBER DEFAULT NULL,
      pdsmop IN VARCHAR2 DEFAULT NULL,
      pfautori IN DATE DEFAULT NULL,
      pcestado IN NUMBER DEFAULT NULL,
      psseguro_d IN NUMBER DEFAULT NULL,
      pseqcaja_o IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --Bug 33886/199825  ACL
   /******************************************************************************
      NOMBRE:     f_lee_ult_re
      PROPÓSITO:  Cursor que leerá el último registro en la tabla ctacliente para
                  la póliza que se envíe de parámetro
   *************************************************************************/
   FUNCTION f_lee_ult_re(pnpoliza IN seguros.npoliza%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --Bug 33886/202377
   /******************************************************************************
      NOMBRE:     f_crea_rec_gasto
      PROPÓSITO:  Funcion que genera un recibo de gasto cuando se supere el max No de devoluciones
    *************************************************************************/
   FUNCTION f_crea_rec_gasto(
      psseguro IN seguros.sseguro%TYPE,
      pimonto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    --Bug 33886/199825    ACL
   /******************************************************************************
     NOMBRE:     f_upd_nre
     PROPÓSITO:  Realiza un update al campo NREEMBO en la tabla ctacliente
                 definido por los parámetros recibidos
   *************************************************************************/
   FUNCTION f_upd_nre(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pnreembo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 33886/202377
   -- Función que recupera el numero de reembolsos de una poliza
   FUNCTION f_get_nroreembolsos(
      psseguro IN caja_datmedio.sseguro%TYPE,
      pnumreembo OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 33886/202377
   -- Función que actualiza el numero de reembolsos de una poliza
   FUNCTION f_actualiza_nroreembol(
      psseguro IN caja_datmedio.sseguro%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_obtener_movimientos_cmovimi6(pseqcaja IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_iax_ctacliente;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CTACLIENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CTACLIENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CTACLIENTE" TO "PROGRAMADORESCSI";
