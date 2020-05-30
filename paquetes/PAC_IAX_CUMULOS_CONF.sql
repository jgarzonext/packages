--------------------------------------------------------
--  DDL for Package PAC_IAX_CUMULOS_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_CUMULOS_CONF" AS
  /******************************************************************************
        NOMBRE:       PAC_IAX_CUMULOS_CONF
        PROP¿SITO:  Funciones para gestionar los cumulos

        REVISIONES:
        Ver        Fecha        Autor   Descripci¿n
       ---------  ----------  ------   ------------------------------------
        1.0        25/01/2017   HRE     1. Creaci¿n del package.
   /*************************************************************************
   FUNCTION f_get_tipcum
   Devuelve el tipo de cumulo del tomador principal de la poliza
   param out mensajes : mensajes de error
   return             : objeto tomador
   *************************************************************************/
   FUNCTION f_get_tipcum(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
   /*************************************************************************
   FUNCTION f_get_tomador
   Devuelve el tomador de la poliza que se esta emitiendo
   param out mensajes : mensajes de error
   return             : objeto tomador
   *************************************************************************/
   FUNCTION f_get_tomador(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
  /*************************************************************************
    FUNCTION f_get_cum_tomador
    Permite obtener los cumulos del tomador
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_tomador(pfcorte        IN     DATE,
                              ptcumulo       IN     VARCHAR2,
                              pnnumide       IN     VARCHAR2,
                              mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR;

/*************************************************************************
    FUNCTION f_get_cum_consorcio
    Permite obtener los cumulos de los integrantes de un consorcio o del tomador,
    en caso de no ser consorcio.
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del consorcio/tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_consorcio(pfcorte        IN     DATE,
                                ptcumulo       IN     VARCHAR2,
                                pnnumide       IN     VARCHAR2,
                                mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR;
   /*************************************************************************
    FUNCTION f_get_com_futuros
    Permite obtener las polizas con compromisos futuros de un tomador a
    una fecha de corte.
    param in pfcorte        : Fecha de corte
    param in pnnumide       : Documento del consorcio/tomador
    param in ptipcomp       : Tipo de compromiso 1-Contractual, 2-PostContractual
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_com_futuros(pfcorte        IN     DATE,
                              pnnumide       IN     VARCHAR2,
                              ptipcomp       IN     NUMBER,
                              psperson       IN     NUMBER,
                              mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR;
/*************************************************************************
    FUNCTION f_get_detcom_futuros
    Permite obtener el detalle de los compromisos futuros de una poliza
    param in psseguro       : numero del seguro
    param in ptipcomp       : Tipo de compromiso 1-Contractual, 2-PostContractual
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_detcom_futuros(psseguro       IN     NUMBER,
                                 ptipcomp       IN     NUMBER,
                                 pfcorte        IN     DATE,
                                 psperson       IN     NUMBER,
                                 mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR;
/*************************************************************************
    FUNCTION f_get_pinta_contratos
    Permite identificar cuales cuotas se pintan o no en el java.
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del consorcio/tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_pinta_contratos(pfcorte        IN     DATE,
                                  ptcumulo       IN     VARCHAR2,
                                  pnnumide       IN     VARCHAR2,
                                  mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR;

   /*************************************************************************
    FUNCTION f_get_cum_tomador_serie
    Permite obtener los cumulos del tomador por anio/serie
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_tomador_serie(pfcorte        IN     DATE,
                                    ptcumulo       IN     VARCHAR2,
                                    pnnumide       IN     VARCHAR2,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR;

   /*************************************************************************
    FUNCTION f_get_cum_tomador_pol
    Permite obtener los cumulos del tomador por poliza
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_tomador_pol(pfcorte        IN     DATE,
                                    ptcumulo       IN     VARCHAR2,
                                    pnnumide       IN     VARCHAR2,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR;
   /*************************************************************************
    FUNCTION f_set_depuracion_manual
    Permite generar el registro de depuracion manual
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_set_depuracion_manual(psseguro       IN     NUMBER,
                                    pcgenera       IN     NUMBER,
                                    pcgarant       IN     NUMBER,
                                    pindicad       IN     VARCHAR2,
                                    pvalor         IN     NUMBER,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN NUMBER ;
/*************************************************************************
    FUNCTION f_get_depuracion_manual
    Permite obtener las depuraciones manuales de un tomador
    param in pfcorte        : fecha de corte
    param in pnnumide       : numero de documento
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_depuracion_manual(pfcorte        IN     DATE,
                                    pnnumide       IN     VARCHAR2,
                                    psperson       IN     NUMBER,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR;
/*************************************************************************
    FUNCTION f_get_depuracion_manual_serie
    Permite obtener las depuraciones manuales de un tomador por serie/anio
    param in pfcorte        : fecha de corte
    param in pnnumide       : numero de documento
    param in pserie         : serie/anio
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_depuracion_manual_serie(pfcorte        IN     DATE,
                                          pnnumide       IN     VARCHAR2,
                                          pserie         IN     NUMBER,
                                          psperson       IN     NUMBER,
                                          mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR;

END pac_iax_cumulos_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CUMULOS_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CUMULOS_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CUMULOS_CONF" TO "PROGRAMADORESCSI";
