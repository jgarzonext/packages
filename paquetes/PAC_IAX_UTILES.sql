--------------------------------------------------------
--  DDL for Package PAC_IAX_UTILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_UTILES" IS
   /******************************************************************************
      NOMBRE:    PAC_IAX_UTILES
      PROP真SITO: Funciones con utilidades transversales

      REVISIONES:
      Ver        Fecha        Autor             Descripci真n
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/10/2016  JAE              1. Creaci真n del objeto.

   ******************************************************************************/

   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Retorna el importe aplicando la tasa de cambio
      param in  p_moneda_inicial : Moneda origen
      param in  p_moneda_final   : Moneda destino
      param in  p_fecha          : Fecha de cambio
      param in  p_importe        : Valor
      param in  p_redondear      : Redondear. Defecto 1
      param out p_cambio         : Tasa de cambio
      param out mensajes         : mensajes de error
      return                     : Importe aplicando tasa de cambio
   *************************************************************************/
   FUNCTION f_importe_cambio(p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
                             p_moneda_final   IN OUT eco_tipocambio.cmondes%TYPE,
                             p_fecha          IN eco_tipocambio.fcambio%TYPE,
                             p_importe        IN NUMBER,
                             p_cambio         OUT NUMBER,
                             mensajes         OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_user_comp: Retorna la informaci真n usu_datos

      param in pscontgar : Agente
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_user_comp(pcuser   IN VARCHAR2,
                            mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /*************************************************************************
      FUNCTION f_get_hisprocesosrea: Retorna la informaci真n de hisprocesosrea

      param in pcnomtabla   : Nombre tabla
      param in pcnomcampo   : Nombre campo
      param in pcusuariomod : Usuario modifica
      param in pfmodifi_ini : Fecha inicio
      param in pfmodifi_fin :  Fecha fin
      param in mensajes     : t_iax_mensajes
      return                : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_hisprocesosrea(pcnomtabla   IN VARCHAR2,
                                 pcnomcampo   IN VARCHAR2,
                                 pcusuariomod IN VARCHAR2,
                                 pfmodifi_ini DATE,
                                 pfmodifi_fin DATE,
                                 mensajes     OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

  FUNCTION f_set_acuerdo_prima(
          pnnumide IN VARCHAR2,
          ptomador IN VARCHAR2,
          pcodsucursal IN NUMBER,
          psucursal IN VARCHAR2,
          pdireccion IN VARCHAR2,
          ptelefono_fijo IN VARCHAR2,
          ptelefono_celular IN VARCHAR2,
          pnnumide_rep IN VARCHAR2,
          prepresentante IN VARCHAR2,
          pvalor IN NUMBER,
          plugar IN VARCHAR2,
          pfecha IN DATE,
          pnro_cuotas IN NUMBER,
          pcrepresentante IN NUMBER,
          pidacuerdo out number,
          pcusuario IN VARCHAR2,  --JRVG 5319 REPORTE ACUERDOS DE PAGO
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER;

  FUNCTION f_set_det_acuerdo_prima(
          pidacuerdo IN NUMBER,
          pnro_cuota IN NUMBER,
          pporcentaje IN NUMBER,
          pvalor IN NUMBER,
          pfecha_pago IN DATE,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER;

   FUNCTION f_set_polizas_acuerdo_prima(
          pidacuerdo IN NUMBER,
          npoliza IN VARCHAR2,
          nrecibo IN VARCHAR2, --SGM 4134 REPORTE CUOTAS ACUERDOS DE PAGO
          nsaldo IN NUMBER, --SGM 4134 REPORTE CUOTAS ACUERDOS DE PAGO
          pvalor IN NUMBER,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER;
		
	FUNCTION f_get_tipiva(
          psseguro IN NUMBER,
          pnriesgo IN NUMBER,
          vtipiva out number,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER; 	
		
	FUNCTION f_get_ultmov(
          psseguro IN NUMBER,
          ptipo IN NUMBER,
          vultmov out number,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER;     	


END pac_iax_utiles;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_UTILES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_UTILES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_UTILES" TO "PROGRAMADORESCSI";
