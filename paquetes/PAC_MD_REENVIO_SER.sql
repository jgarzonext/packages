create or replace PACKAGE PAC_MD_REENVIO_SER IS

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
                               mensajes OUT t_iax_mensajes);

  PROCEDURE P_REINTENTAR_I031 (PI_SINTERF IN NUMBER,
                               PI_ESTADO  IN NUMBER,
                               PSINTERF OUT VARCHAR2,
                               PNUMINTENTO OUT NUMBER,
                               mensajes OUT t_iax_mensajes);

  PROCEDURE P_BUSCAR_INTERFACE(PO_RESULT OUT SYS_REFCURSOR);
  
  PROCEDURE P_BUSCAR_SOLICITUD(PI_CINTERF IN VARCHAR2,
                               PI_ESTADO  IN NUMBER,
                               PO_RESULT  OUT SYS_REFCURSOR);
  
  PROCEDURE P_BUSCAR_ESTADO(PO_RESULT OUT SYS_REFCURSOR);
  
  PROCEDURE P_GET_SERVICIO (PI_CINTERF VARCHAR2,
                            PI_ESTADO NUMBER,
                            PI_NNUMIDE VARCHAR2,
                            PI_FINICIO DATE,
                            PI_FFIN DATE,
                            PI_NUMPAGO VARCHAR2,
                            PO_RESULT OUT SYS_REFCURSOR);
  /* Cambios de  tarea IAXIS-13044 : start */
  PROCEDURE P_GET_ENTSALIDA(PI_SINTERF IN NUMBER,
                            PI_ESTADO  IN NUMBER,
                            PI_CINTERF IN VARCHAR2,
                            PO_RESULT  OUT SYS_REFCURSOR);
                            
  PROCEDURE P_REINTENTAR_CONVI(PI_SINTERF IN NUMBER,
                               PI_NNUMIDE IN VARCHAR2);                            

  /* Cambios de  tarea IAXIS-13044 : end */								

END PAC_MD_REENVIO_SER;
/

GRANT EXECUTE ON "AXIS"."PAC_MD_REENVIO_SER" TO "R_AXIS";
GRANT EXECUTE ON "AXIS"."PAC_MD_REENVIO_SER" TO "CONF_DWH";
GRANT EXECUTE ON "AXIS"."PAC_MD_REENVIO_SER" TO "PROGRAMADORESCSI";