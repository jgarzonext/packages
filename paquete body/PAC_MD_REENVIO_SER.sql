create or replace PACKAGE BODY PAC_MD_REENVIO_SER IS

  /******************************************************************************
     NOMBRE:    PAC_MD_REENVIO_SER
     PROPÓSITO: PACKAGE TO RETRY FAILED WEBSERVICE REQUESTS

     REVISIONES:
     VER        FECHA        AUTOR             DESCRIPCIÓN
     ---------  ----------  ---------------  ------------------------------------
      1.0       14/06/2019   SWAPNIL             CREACION
      2.0       25/06/2019   PK                 IAXIS-4191: Added procedures for getting data on screen.
      3.0       28/01/2020   JRVG               IAXIS-4704 - BUG 10574 Ajuste REENVIO PANTALLA  [axisadm200] Reenvío de Servicios
	  4.0		18/03/2020	 SP					Cambios de  tarea IAXIS-13044
  */

  PROCEDURE P_REINTENTAR_I017 (PI_SINTERF IN NUMBER,
                               PI_ESTADO  IN NUMBER,
                               PSINTERF OUT VARCHAR2,
                               mensajes OUT t_iax_mensajes) IS
    VOBJ   VARCHAR2(500) := 'PAC_MD_REENVIO_SER.P_REINTENTAR_I017';
    VTRAZA NUMBER := 0;
  BEGIN
    VTRAZA := 1;
    PAC_REENVIO_SER.P_REINTENTAR_I017 (PI_SINTERF, PI_ESTADO, PSINTERF, mensajes);
    --
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en llamar P_REINTENTAR_I017',
                  'Error :' || SQLERRM);

  END P_REINTENTAR_I017;

  PROCEDURE P_REINTENTAR_I031 (PI_SINTERF IN NUMBER,
                               PI_ESTADO  IN NUMBER,
                               PSINTERF OUT VARCHAR2,
    -- INICIO IAXIS-4704 - BUG 10574 - JRVG -  28/01/2020
                               PNUMINTENTO OUT NUMBER,
                               mensajes OUT t_iax_mensajes) IS
    VOBJ   VARCHAR2(500) := 'PAC_MD_REENVIO_SER.P_REINTENTAR_I031';
    VTRAZA NUMBER := 0;
  BEGIN
    VTRAZA := 1;
    PAC_REENVIO_SER.P_REINTENTAR_I031 (PI_SINTERF, PI_ESTADO, PSINTERF,PNUMINTENTO, mensajes);
    -- FIN IAXIS-4704 - BUG 10574 - JRVG -  28/01/2020
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en llamar P_REINTENTAR_I031',
                  'Error :' || SQLERRM);

  END P_REINTENTAR_I031;

  PROCEDURE P_BUSCAR_INTERFACE(PO_RESULT OUT SYS_REFCURSOR) IS
    VOBJ   VARCHAR2(500) := 'PAC_MD_REENVIO_SER.P_BUSCAR_INTERFACE';
    VTRAZA NUMBER := 0;
  BEGIN
    VTRAZA := 1;
    PAC_REENVIO_SER.P_BUSCAR_INTERFACE(PO_RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en llamar P_BUSCAR_INTERFACE',
                  'Error :' || SQLERRM);

  END P_BUSCAR_INTERFACE;
  
  PROCEDURE P_BUSCAR_SOLICITUD(PI_CINTERF IN VARCHAR2,
                               PI_ESTADO  IN NUMBER,
                               PO_RESULT  OUT SYS_REFCURSOR) IS
    VOBJ   VARCHAR2(500) := 'PAC_MD_REENVIO_SER.P_BUSCAR_SOLICITUD';
    VTRAZA NUMBER := 0;

  BEGIN

    VTRAZA := 1;
    PAC_REENVIO_SER.P_BUSCAR_SOLICITUD(PI_CINTERF, PI_ESTADO, PO_RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en llamar P_BUSCAR_SOLICITUD',
                  'Error :' || SQLERRM);
  END P_BUSCAR_SOLICITUD;

  PROCEDURE P_BUSCAR_ESTADO(PO_RESULT OUT SYS_REFCURSOR) IS
    VOBJ   VARCHAR2(500) := 'PAC_MD_REENVIO_SER.P_BUSCAR_ESTADO';
    VTRAZA NUMBER := 0;
  BEGIN
    VTRAZA := 1;
    PAC_REENVIO_SER.P_BUSCAR_ESTADO(PO_RESULT);
    
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en llamar P_BUSCAR_ESTADO',
                  'Error :' || SQLERRM);

  END P_BUSCAR_ESTADO;
  
  PROCEDURE P_GET_SERVICIO (PI_CINTERF VARCHAR2,
                            PI_ESTADO NUMBER,
                            PI_NNUMIDE VARCHAR2,
                            PI_FINICIO DATE,
                            PI_FFIN DATE,
                            PI_NUMPAGO VARCHAR2,
                            PO_RESULT OUT SYS_REFCURSOR) IS
    VOBJ   VARCHAR2(500) := 'PAC_MD_REENVIO_SER.P_GET_SERVICIO';
    VTRAZA NUMBER := 0;
  BEGIN
    VTRAZA := 1;
    PAC_REENVIO_SER.P_GET_SERVICIO(PI_CINTERF, PI_ESTADO, PI_NNUMIDE, PI_FINICIO, PI_FFIN, PI_NUMPAGO, PO_RESULT);
    --
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en llamar P_BUSCAR_ESTADO',
                  'Error :' || SQLERRM);
    --
  END P_GET_SERVICIO;
  
  /* Cambios de  tarea IAXIS-13044 : start */
  PROCEDURE P_GET_ENTSALIDA(PI_SINTERF IN NUMBER,
                            PI_ESTADO  IN NUMBER,
                            PI_CINTERF IN VARCHAR2,
                            PO_RESULT  OUT SYS_REFCURSOR) IS
    VOBJ   VARCHAR2(500) := 'PAC_MD_REENVIO_SER.P_GET_ENTSALIDA';
    VTRAZA NUMBER := 0;
    --
  BEGIN
    --
    VTRAZA := 1;
    PAC_REENVIO_SER.P_GET_ENTSALIDA(PI_SINTERF, PI_ESTADO, PI_CINTERF, PO_RESULT);
    --
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en llamar P_GET_ENTSALIDA',
                  'Error :' || SQLERRM);
  END P_GET_ENTSALIDA;

  PROCEDURE P_REINTENTAR_CONVI(PI_SINTERF IN NUMBER,
                               PI_NNUMIDE IN VARCHAR2) IS
    VOBJ   VARCHAR2(500) := 'PAC_MD_REENVIO_SER.P_REINTENTAR_CONVI';
    VTRAZA NUMBER := 0;
    --
  BEGIN
    --
    VTRAZA := 1;
    PAC_REENVIO_SER.P_REINTENTAR_CONVI(PI_SINTERF, PI_NNUMIDE);
    --
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en llamar P_REINTENTAR_CONVI',
                  'Error :' || SQLERRM);
  END P_REINTENTAR_CONVI;
/* Cambios de  tarea IAXIS-13044 : end */
  
END PAC_MD_REENVIO_SER;
/

GRANT EXECUTE ON "AXIS"."PAC_MD_REENVIO_SER" TO "R_AXIS";
GRANT EXECUTE ON "AXIS"."PAC_MD_REENVIO_SER" TO "CONF_DWH";
GRANT EXECUTE ON "AXIS"."PAC_MD_REENVIO_SER" TO "PROGRAMADORESCSI";
GRANT EXECUTE ON "AXIS"."PAC_MD_REENVIO_SER" TO "AXIS00";

create or replace synonym AXIS00.PAC_MD_REENVIO_SER for AXIS.PAC_MD_REENVIO_SER;