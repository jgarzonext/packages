CREATE OR REPLACE PACKAGE PAC_CONTA_SAP IS

  -- AUTHOR  : WJAIME
  -- CREATED : 7/4/2019 2:58:48 PM
  -- PURPOSE : REALIZA LAS VALIDACIONES PARA GENERAR EL CODIGO DE ESCENARIO A UTILIZAR Y GENERE LOS REGISTROS REQUERIDOS PARA EL ENVIO DE LAS COMISIONES A SAP

  PROCEDURE GENERA_CODESCENARIO;
  PROCEDURE PRIMAS_DIRECTAS(X_RECIBO  IN NUMBER,
                            X_CAGENTE IN NUMBER,
                            X_NMOVIMI IN NUMBER,
                            X_SSEGURO IN NUMBER,
                            X_RAMO    IN NUMBER,
                            X_CTIPCOA IN NUMBER,
                            X_CTIPREC IN VARCHAR2);
  PROCEDURE PRIMAS_COA_ACEPTADO(X_RECIBO  IN NUMBER,
                                X_CAGENTE IN NUMBER,
                                X_NMOVIMI IN NUMBER,
                                X_SSEGURO IN NUMBER,
                                X_RAMO    IN NUMBER,
                                X_CTIPCOA IN NUMBER,
                                X_CTIPREC IN VARCHAR2);
  PROCEDURE PRIMAS_DIRECTAS_SUPLEMENOS(X_RECIBO  IN NUMBER,
                                       X_CAGENTE IN NUMBER,
                                       X_NMOVIMI IN NUMBER,
                                       X_SSEGURO IN NUMBER,
                                       X_RAMO    IN NUMBER,
                                       X_CTIPCOA IN NUMBER,
                                       X_CTIPREC IN VARCHAR2);
  PROCEDURE ANULA_DIRECTAS_SUPLEMAS(X_RECIBO  IN NUMBER,
                                    X_CAGENTE IN NUMBER,
                                    X_NMOVIMI IN NUMBER,
                                    X_SSEGURO IN NUMBER,
                                    X_RAMO    IN NUMBER,
                                    X_CPOLCIA IN VARCHAR2,
                                    X_CTIPCOA IN NUMBER,
                                    X_CTIPREC IN VARCHAR2);
  PROCEDURE ANULA_DIRECTAS_SUPLEMENOS(X_RECIBO  IN NUMBER,
                                      X_CAGENTE IN NUMBER,
                                      X_NMOVIMI IN NUMBER,
                                      X_SSEGURO IN NUMBER,
                                      X_RAMO    IN NUMBER,
                                      X_CPOLCIA VARCHAR2,
                                      X_CTIPCOA IN NUMBER,
                                      X_CTIPREC IN VARCHAR2);
  PROCEDURE CANCELA_DIRECTAS(X_RECIBO  IN NUMBER,
                             X_CAGENTE IN NUMBER,
                             X_NMOVIMI IN NUMBER,
                             X_SSEGURO IN NUMBER,
                             X_RAMO    IN NUMBER,
                             X_CTIPCOA IN NUMBER,
                             X_CTIPREC IN VARCHAR2);
  PROCEDURE COA_ACEPTADO_SUPLEMENOS(X_RECIBO  IN NUMBER,
                                    X_CAGENTE IN NUMBER,
                                    X_NMOVIMI IN NUMBER,
                                    X_SSEGURO IN NUMBER,
                                    X_RAMO    IN NUMBER,
                                    X_CTIPCOA IN NUMBER,
                                    X_CTIPREC IN VARCHAR2);
  PROCEDURE ANULA_COA_ACEPTADO_SUPLEMAS(X_RECIBO  IN NUMBER,
                                        X_CAGENTE IN NUMBER,
                                        X_NMOVIMI IN NUMBER,
                                        X_SSEGURO IN NUMBER,
                                        X_RAMO    IN NUMBER,
                                        X_CPOLCIA IN VARCHAR2,
                                        X_CTIPCOA IN NUMBER,
                                        X_CTIPREC IN VARCHAR2);
  PROCEDURE ANULA_COA_ACEPTADO_SUPLEMENOS(X_RECIBO  IN NUMBER,
                                          X_CAGENTE IN NUMBER,
                                          X_NMOVIMI IN NUMBER,
                                          X_SSEGURO IN NUMBER,
                                          X_RAMO    IN NUMBER,
                                          X_CPOLCIA IN VARCHAR2,
                                          X_CTIPCOA IN NUMBER,
                                          X_CTIPREC IN VARCHAR2);
  /*
  PROCEDIMIENTO GENERA CONTABILIDAD SINIESTROS 
  IAXIS 4504 AABC 08/08/2019    
  */
  PROCEDURE GENERA_INFO_CUENTAS_SIN;
  /*
  PROCEDIMIENTO GENERA CONTABILIDAD SINIESTROS RESERVAS 
  IAXIS 5194 EA 06/09/2019    
  */
  PROCEDURE GENERA_INFO_CUENTAS_RES(P_TIPO IN NUMBER);
  PROCEDURE GENERA_INFO_CUENTAS;

  FUNCTION GENERARUIDPARACOM(PI_RECIBO   IN NUMBER,
                             PI_SCENARIO IN NUMBER,
                             PI_SINTERF  IN NUMBER) RETURN VARCHAR2;

  PROCEDURE GENERARTRAMA(PI_RECIBO   IN NUMBER,
                         PI_AGENTE   IN NUMBER,
                         PI_SCENARIO IN NUMBER,
                         PI_CUENTA   IN VARCHAR2,
                         PI_TIPPAG   IN NUMBER,
                         PO_RESULT   OUT SYS_REFCURSOR);

  FUNCTION F_IMPORTES_SAP(PNRECIBO      NUMBER,
                          PTIPO_IMPORTE VARCHAR2,
                          PTTIPPAG      NUMBER,
                          PAGENTE       NUMBER,
                          PCUENTA       VARCHAR2) RETURN NUMBER;

  /**************************************************************************************
   FF_BUSCASPERSON: FUNCIN QUE DADO UN ESCENARIO, NUMERO DE CUENTA Y  NUMERO DE RECIBO
                    DEVUELVE SPERSON_ACRE O/Y SPERSON_DEU PARA EL TOMADOR, AGENTE O COMPAIA.
   REVISIONES:
   VER        FECHA       AUTOR  DESCRIPCIN
   ---------  ----------  -----  ------------------------------------
     1.0        13/08/2019  JRV    PARAMETRIZACION CONTABLE CONF
  *************************************************************************************/
  FUNCTION FF_BUSCASPERSON(P_ESCENARIO IN NUMBER,
                           P_CUENTA    IN NUMBER,
                           P_NRECIBO   IN NUMBER,
                           P_AGENTE    IN NUMBER) RETURN VARCHAR2;
  /**************************************************************************************
    F_CERTIFIC: FUNCIN QUE DADO UN SSEGURO Y NUMERO DE MOVIMIENTO DEL RECIBO
                DEVUELVE EL NUMERO DE CERTIFICADO .
    REVISIONES:
      VER        FECHA       AUTOR  DESCRIPCIN
    ---------  ----------  -----  ------------------------------------
      1.0        27/08/2019  JRV    PARAMETRIZACION CONTABLE CONF
  **************************************************************************************/

  FUNCTION F_CERTIFIC(PI_SSEGURO IN SEGUROS.SSEGURO%TYPE,
                      PI_NMOVIMI IN NUMBER) RETURN VARCHAR2;

  FUNCTION F_INDICADOR_SAP(PI_CUENTA       NUMBER,
                           PI_TIPO_IMPORTE VARCHAR2,
                           PI_VALOR_IVA    NUMBER,
                           PI_NRECIBO      IN NUMBER,
                           PI_AGENTE       IN NUMBER) RETURN VARCHAR2;

  FUNCTION F_TIPO_AGENTE_SAP(PI_RECIBO NUMBER, PI_SINTERF NUMBER)
    RETURN NUMBER;

  FUNCTION F_INTERMEDIARIO_SAP(PI_RECIBO NUMBER, PI_SINTERF NUMBER)
    RETURN VARCHAR2;

  FUNCTION F_AGENTECOM(PI_RECIBO NUMBER, PI_SINTERF NUMBER) RETURN NUMBER;

  FUNCTION F_SUCURSAL_SAP(PI_CUENTA IN VARCHAR2) RETURN VARCHAR2;
  
  FUNCTION F_SUCURSAL_PROD(PI_CUENTA IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION F_DIVISA_PROD(PI_NRECIBO IN VARCHAR2,
                         PI_MONEDA_FINAL IN VARCHAR2,
                         PI_FEFEADM IN DATE) RETURN NUMBER;

  FUNCTION F_COMISION_SAP(PI_RECIBO NUMBER,
                          PI_AGENTE NUMBER,
                          PI_TIPO   VARCHAR2,
                          PI_CUENTA VARCHAR2) RETURN NUMBER;

  FUNCTION F_BASERET_SAP(PI_RECIBO NUMBER, PI_SINTERF NUMBER, PI_CUENTA NUMBER) RETURN NUMBER;

  PROCEDURE GENERARTRAMA_COD(PI_RECIBO   IN NUMBER,
                             PI_AGENTE   IN NUMBER,
                             PI_SCENARIO IN NUMBER,
                             PI_CUENTA   IN VARCHAR2,
                             PI_TIPPAG   IN NUMBER,
                             PI_COMPAN   IN NUMBER,
                             PO_RESULT   OUT SYS_REFCURSOR);

  FUNCTION F_DIVISON_SAP(PI_RECIBO NUMBER, PI_SINTERF NUMBER) RETURN VARCHAR2;
  FUNCTION F_APLICA_BASERET_SAP(PI_CUENTA IN VARCHAR2) RETURN VARCHAR2;

  --IAXIS 4504 26/09/2019 AABC validacion de divisa y moneda diferente a COP siniestros
  FUNCTION F_APLI_DIVISA_SAP(PI_RECIBO NUMBER) RETURN VARCHAR2;
  --IAXIS 4504 26/09/2019 AABC validacion de divisa y moneda diferente a COP siniestros  

  PROCEDURE MOVCONTA_SCENARIO(PI_SSEGURO IN NUMBER, PI_CMOTMOV IN NUMBER);


  PROCEDURE MOVCONTA_SCENARIO_ANULA(PI_NRECIBO IN NUMBER,
                                    PI_CMOTMOV IN NUMBER,
                                    PI_CESTREC IN NUMBER);
                  
  PROCEDURE MOVCONTASAP_ANULA_REC(PI_SSEGURO IN NUMBER, 
                                 PI_NMOVIMI IN NUMBER);

  PROCEDURE ANULA_SCENARIO(PI_CAGENTE    IN NUMBER,
                           PI_SCENARIO_N IN NUMBER,
                           PI_SCENARIO_A IN NUMBER,
                           PI_RECIBO     IN NUMBER,
                           PI_UNIQUE     VARCHAR2,
                           PI_SINTERF    IN NUMBER);

  FUNCTION F_IMPORTES_CAN_SAP(PNRECIBO      NUMBER,
                              PTIPO_IMPORTE VARCHAR2,
                              PI_SCENARIO   NUMBER,
                              PAGENTE       NUMBER,
                              PCUENTA       VARCHAR2) RETURN NUMBER;

  PROCEDURE CALCELACION_SCENARIO(PI_CAGENTE    IN NUMBER,
                                 PI_SCENARIO_N IN NUMBER,
                                 PI_SCENARIO_C IN NUMBER,
                                 PI_RECIBO     IN NUMBER,
                                 PI_UNIQUE     VARCHAR2,
                                 PI_SINTERF    IN NUMBER);
                                 
  PROCEDURE ELIMINA_SCENARIO(PI_RECIBO IN  NUMBER,
                             PI_CAGENTE IN NUMBER,
                             PI_NMOVIMI IN NUMBER,
                             PI_SSEGURO IN NUMBER,
                             PI_RAMO    IN NUMBER,
                             PI_CTIPCOA IN NUMBER,
                             PI_CTIPREC IN VARCHAR2);
                             
 FUNCTION F_POLIZA_MIGRADA(PI_NRECIBO IN NUMBER) RETURN VARCHAR2;
 
 FUNCTION F_BUSCA_NUMUNICO(PI_ESCENARIO IN NUMBER,
                           PI_NRECIBO IN NUMBER,
                           PI_SINTERF IN NUMBER) RETURN VARCHAR2;
                           
 PROCEDURE ELIMINA_SCENARIO_MIGRACION(PI_RECIBO IN  NUMBER,
                                       PI_NMOVIMI IN NUMBER,
                                       PI_SSEGURO IN NUMBER,
                                       PI_RAMO    IN NUMBER,
                                       PI_CTIPCOA IN NUMBER,
                                       PI_CTIPREC IN VARCHAR2);
FUNCTION F_TIPOVIGENCIA(PI_NRECIBO IN NUMBER,
                        PI_SSEGURO IN NUMBER,
                        PI_CPOLCIA VARCHAR2,
                        PI_ESCENARIO IN NUMBER ) RETURN NUMBER;

FUNCTION F_CAUSAGASTO(PI_NRECIBO IN NUMBER,
                       PI_SSEGURO IN NUMBER) RETURN VARCHAR2;
                       
PROCEDURE GENERA_REINTENTO_PRD(PI_SINTERF IN NUMBER);
PROCEDURE GENERA_REINTENTO_SIN(PI_SINTERF IN NUMBER);
PROCEDURE GENERA_REINTENTO_RES(PI_SINTERF IN NUMBER);                                             

END PAC_CONTA_SAP;
/
