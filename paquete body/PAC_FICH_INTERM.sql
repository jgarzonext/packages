CREATE OR REPLACE PACKAGE BODY "PAC_FICH_INTERM" AS
  /******************************************************************************
     NOMBRE:      PAC_FICH_INTERM
     PROP¿¿SITO:   ESTE PAQUETE TIENE LA FINALIDAD DE REALIZAR LA CONSOLIDACI¿¿N (CIERRE) DE TODOS LOS DATOS CORRESPONDIENTES A UN INTERMEDIARIO DENTRO DE UN RANGO DE FECHAS CORRESPONDIENTE.
  
     REVISIONES:
     VER        FECHA        AUTOR             DESCRIPCI¿¿N
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/06/2016   FORREGO              1. CREACION
     2.0        26/07/2019   KK                   2. IAXIS-3152:FICHA FINANCIERA INTERMEDIARIO - VERIFICACIÓN DATOS
     3.0        30/09/2019   SWAPNIL              3. IAXIS-3152: DEFECT FIX
  ******************************************************************************/

  /*************************************************************************
      PROCEDURE PROCESO_BATCH_CIERRE:
  *************************************************************************/
  PROCEDURE PROCESO_BATCH_CIERRE(PMODO    IN NUMBER,
                                 PCEMPRES IN NUMBER,
                                 PMONEDA  IN NUMBER,
                                 PCIDIOMA IN NUMBER,
                                 PFPERINI IN DATE,
                                 PFPERFIN IN DATE,
                                 PFCIERRE IN DATE,
                                 PCERROR  OUT NUMBER,
                                 PSPROCES OUT NUMBER,
                                 PFPROCES OUT DATE) IS
  
    V_TOBJETO VARCHAR2(100) := 'PAC_FICH_INTERM.PROCESO_BATCH_CIERRE';
    V_TPARAM  VARCHAR2(1000) := ' pmodo=' || PMODO || ' pcempres=' ||
                                PCEMPRES || ' pmoneda=' || PMONEDA ||
                                ' Pfperini=' || PFPERINI || ' Pfperfin=' ||
                                PFPERFIN || ' Pfcierre=' || PFCIERRE;
    V_NTRAZA  NUMBER := 0;
  
    NUM_ERR    NUMBER;
    V_TITULO   VARCHAR2(100);
    TEXT_ERROR VARCHAR2(500) := 0;
    PNNUMLIN   NUMBER;
    TEXTO      VARCHAR2(400);
    CONTA_ERR  NUMBER := 0;
    XMODO      VARCHAR2(1);
    XMETODO    NUMBER(1) := 0;
  
    CURSOR C_AGENTES IS
      SELECT CAGENTE FROM AGENTES WHERE CTIPAGE IN (4, 5);
  
  BEGIN
  
    /*IF PMODO = 1 THEN
      V_TITULO := 'CIERRE INTERMEDIARIO PREVIO';
    ELSE
      V_TITULO := 'CIERRE INTERMEDIARIO REAL';
    END IF;*/
  
    IF PMODO = 1 THEN
      V_TITULO := 'Proceso Cierre Diario (empresa ' || PCEMPRES || ')';
      XMODO    := 'P';
      /* CAMBIOS DE SWAPNIL : START 
      DELETE FROM FICHA_AGENTE_PREV
       WHERE FCALCUL = NVL(PFPROCES, F_SYSDATE);
         CAMBIOS DE SWAPNIL : END          
       */
      /* CAMBIOS DE SWAPNIL : START */
      DELETE FROM FICHA_AGENTE_PREV;
      COMMIT;
      /* CAMBIOS DE SWAPNIL : END */
    ELSE
      V_TITULO := 'Proceso Cierre Mensual';
      XMODO    := 'R';
      /* CAMBIOS DE SWAPNIL : START */
      DELETE FROM FICHA_AGENTE;
      COMMIT;
      /* CAMBIOS DE SWAPNIL : END */
    END IF;
  
    --INSERTAMOS EN LA TABLA PROCESOSCAB EL REGISTRO IDENTIFICATIVO DE PROCESO -----
    NUM_ERR := F_PROCESINI(F_USER,
                           PCEMPRES,
                           'INTERMEDIARIO',
                           V_TITULO,
                           PSPROCES);
    COMMIT;
  
    IF NUM_ERR <> 0 THEN
      PCERROR   := 1;
      CONTA_ERR := CONTA_ERR + 1;
      TEXTO     := F_AXIS_LITERALES(NUM_ERR, PCIDIOMA);
      PNNUMLIN  := NULL;
      NUM_ERR   := F_PROCESLIN(PSPROCES,
                               SUBSTR('INTERMEDIARIO ' || TEXTO || ' ' ||
                                      TEXT_ERROR,
                                      1,
                                      120),
                               0,
                               PNNUMLIN);
      COMMIT;
    ELSE
      FOR VAR IN C_AGENTES LOOP
        NUM_ERR := PAC_FICH_INTERM.F_GRABAR_REGISTRO(VAR.CAGENTE,
                                                     PMODO,
                                                     PSPROCES,
                                                     PFPERINI,
                                                     PFPERFIN);
      END LOOP;
      PCERROR := 0;
    END IF;
    NUM_ERR := F_PROCESFIN(PSPROCES, PCERROR);
    IF NUM_ERR <> 0 THEN
      ROLLBACK;
    ELSE
    
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  V_TOBJETO,
                  V_NTRAZA,
                  V_TPARAM || ': Error' || SQLCODE,
                  SQLERRM);
  END PROCESO_BATCH_CIERRE;

  /**************************************************************************
       F_GET_POLIZA
       FUNCI¿¿N PARA SELECCIONAR TODAS LAS P¿¿LIZAS VIGENTES DENTRO DEL RANGO DE TIEMPO ESTABLECIDO, ESTO CON EL FIN DE REALIZAR UN CONTEO DE ¿¿STAS, SUMATORIA DE SUS PRIMAS.
  *************************************************************************/
  FUNCTION F_GET_POLIZA(PCAGENTE IN AGENTES.CAGENTE%TYPE,
                        PFPERINI IN DATE,
                        PFPERFIN IN DATE,
                        PTIPO    IN NUMBER) RETURN NUMBER IS
  
    /* CAMBIOS DE SWAPNIL : START
       CURSOR C_POLI1 IS
          SELECT COUNT(1) NUMERO, SUM(IPRIANU)FROM SEGUROS S
             WHERE F_VIGENTE(S.SSEGURO, NULL, F_SYSDATE) = 0
             AND CAGENTE = PCAGENTE;
    
       CURSOR C_POLI2 IS
          SELECT COUNT(1), SUM(IPRIANU) FROM SEGUROS S
             WHERE F_VIGENTE(S.SSEGURO, NULL, F_SYSDATE) = 0
             AND CAGENTE = PCAGENTE
              AND (FEFECTO BETWEEN  PFPERINI  AND PFPERFIN
                 OR FVENCIM BETWEEN PFPERINI  AND PFPERFIN);
    CAMBIOS DE SWAPNIL : END */
  
    /* CAMBIOS DE SWAPNIL : START */
    CURSOR C_POLI1 IS
      SELECT COUNT(1) NUMERO, SUM(S.IPRIANU)
        FROM RECIBOS R, MOVRECIBO M, SEGUROS S
       WHERE R.NRECIBO = M.NRECIBO
         AND M.SMOVREC = (SELECT MAX(SMOVREC)
                            FROM MOVRECIBO MV
                           WHERE MV.NRECIBO = R.NRECIBO)
         AND M.CESTREC = 0
         AND S.SSEGURO = R.SSEGURO
         AND S.CAGENTE = PCAGENTE;
  
    CURSOR C_POLI2 IS
      SELECT COUNT(1) NUMERO, SUM(S.IPRIANU)
        FROM RECIBOS R, MOVRECIBO M, SEGUROS S
       WHERE R.NRECIBO = M.NRECIBO
         AND M.SMOVREC = (SELECT MAX(SMOVREC)
                            FROM MOVRECIBO MV
                           WHERE MV.NRECIBO = R.NRECIBO)
         AND M.CESTREC = 0
         AND S.SSEGURO = R.SSEGURO
         AND S.CAGENTE = PCAGENTE
         AND GREATEST(R.FEFECTO, S.FEFECTO) BETWEEN PFPERINI AND PFPERFIN;
    /* CAMBIOS DE SWAPNIL : END */
  
    VOBJECTNAME VARCHAR2(500);
    VPARAM      VARCHAR2(500);
    VPASEXEC    NUMBER := 1;
    NUMPOLIZAS  NUMBER;
    SUMPRIMA    NUMBER;
  BEGIN
  
    IF PTIPO = 1 OR PTIPO = 3 THEN
      OPEN C_POLI1;
      FETCH C_POLI1
        INTO NUMPOLIZAS, SUMPRIMA;
      CLOSE C_POLI1;
    ELSIF PTIPO = 2 OR PTIPO = 4 THEN
      OPEN C_POLI2;
      FETCH C_POLI2
        INTO NUMPOLIZAS, SUMPRIMA;
      CLOSE C_POLI2;
    END IF;
  
    IF PTIPO = 1 OR PTIPO = 2 THEN
      RETURN NUMPOLIZAS;
    ELSE
      RETURN SUMPRIMA;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NUMPOLIZAS;
  END F_GET_POLIZA;

  /**************************************************************************
       F_GRABAR_REGISTRO
       CON LA INFORMACI¿¿N DEL CURSOR RECIBIDO SE PROCESAR¿¿ CADA REGISTRO Y  DEBEN TOMAR LOS DATOS CORRESPONDIENTES E INSERTARLOS EN LA TABLA FICHA_AGENTE CUANDO SE TRATA DE UN CIERRE REAL, EN CASO CONTRARIO, CIERRE PREVIO,  SE INSERTAR¿¿ EN LA TABLA FICHA_AGENTE_PREVIO FUNCI¿¿N PARA SELECCIONAR TODAS LAS P¿¿LIZAS VIGENTES DENTRO DEL RANGO DE TIEMPO ESTABLECIDO, ESTO CON EL FIN DE REALIZAR UN CONTEO DE ¿¿STAS, SUMATORIA DE SUS PRIMAS.
  *************************************************************************/
  FUNCTION F_GRABAR_REGISTRO(PCAGENTE IN AGENTES.CAGENTE%TYPE,
                             PMODO    IN NUMBER,
                             PSPROCES IN NUMBER,
                             PFPERINI IN DATE,
                             PFPERFIN IN DATE) RETURN NUMBER IS
    VOBJECTNAME   VARCHAR2(500);
    VPARAM        VARCHAR2(500);
    VPASEXEC      NUMBER := 1;
    C_SEGUROS     SEGUROS%ROWTYPE;
    V_NSINIESTROS NUMBER := 0;
    V_RESERVAS    NUMBER := 0;
    V_PAGOS       NUMBER := 0;
    V_NTRAMITESJ  NUMBER := 0;
    V_PTRAMITESJ  NUMBER := 0;
    V_IRECSIN     NUMBER := 0;
  
    V_TOBJETO VARCHAR2(100) := 'PAC_FICH_INTERM.f_grabar_registro';
    V_TPARAM  VARCHAR2(1000) := ' pmodo=' || PMODO;
  
    NUM_ERR NUMBER;
  
    V_NTRAZA NUMBER;
  
    CURSOR C_NSINIESTROS IS
      SELECT COUNT(1) FROM SIN_SINIESTRO WHERE CAGENTE = CAGENTE;
  
    CURSOR C_RESERVAS IS
      SELECT SUM(R.IRESERVA)
        FROM SIN_SINIESTRO          S,
             SIN_TRAMITA_RESERVA    R,
             SIN_TRAMITA_MOVIMIENTO M
       WHERE R.NSINIES = M.NSINIES
         AND R.NTRAMIT = M.NTRAMIT
         AND M.CESTTRA = 0
         AND R.NSINIES = S.NSINIES
         AND S.CAGENTE = CAGENTE;
  
    CURSOR C_PAGOS IS
      SELECT ISINRET
        FROM SIN_TRAMITA_PAGO P, SIN_SINIESTRO S
       WHERE P.NSINIES = S.NSINIES
         AND S.CAGENTE = PCAGENTE;
  
    CURSOR C_TRAMITACION IS
      SELECT COUNT(1), SUM(P.ISINRET)
        FROM SIN_TRAMITACION T, SIN_SINIESTRO S, SIN_TRAMITA_PAGO P
       WHERE T.CTRAMIT = 20
         AND T.NSINIES = S.NSINIES
         AND P.NSINIES = S.NSINIES
         AND P.NTRAMIT = T.NTRAMIT
         AND S.CAGENTE = PCAGENTE;
  
    CURSOR C_RECOBROS IS
      SELECT SUM(ISINRET)
        FROM SIN_TRAMITA_PAGO
       WHERE CCONPAG = 358
         AND CAGENTE = PCAGENTE;
  
  BEGIN
  
    OPEN C_NSINIESTROS;
    FETCH C_NSINIESTROS
      INTO V_NSINIESTROS;
    CLOSE C_NSINIESTROS;
  
    OPEN C_RECOBROS;
    FETCH C_RECOBROS
      INTO V_IRECSIN;
    CLOSE C_RECOBROS;
  
    OPEN C_RESERVAS;
    FETCH C_RESERVAS
      INTO V_RESERVAS;
    CLOSE C_RESERVAS;
  
    OPEN C_PAGOS;
    FETCH C_PAGOS
      INTO V_PAGOS;
    CLOSE C_PAGOS;
  
    OPEN C_TRAMITACION;
    FETCH C_TRAMITACION
      INTO V_NTRAMITESJ, V_PTRAMITESJ;
    CLOSE C_TRAMITACION;
  
    IF PMODO = 0 THEN
      INSERT INTO FICHA_AGENTE
        (CAGENTE,
         SPROCES,
         FDESDE,
         FHASTA,
         FCALCUL,
         NPOLFECHA,
         NPOLIZAS,
         ISUMPRI,
         ISUMPRIA,
         ICANTIDAD30,
         ICANTIDAD60,
         ICANTIDAD90,
         ICANTIDADMAS90,
         ICARTERA,
         NNUMFORM,
         NNUMINF,
         NNUMPAG,
         NAVISIN,
         IRESSIN,
         IPAGSIN,
         IRECSIN,
         IPAGREC,
         NNUMPROJUD,
         IPAGINCJUD,
         IRETPOLVIG,
         TTIPCANAL)
      VALUES
        (PCAGENTE,
         PSPROCES,
         PFPERINI,
         PFPERFIN,
         F_SYSDATE,
         NVL(PAC_FICH_INTERM.F_GET_POLIZA(PCAGENTE, PFPERINI, PFPERFIN, 1),
             0),
         NVL(PAC_FICH_INTERM.F_GET_POLIZA(PCAGENTE, PFPERINI, PFPERFIN, 2),
             0),
         NVL(PAC_FICH_INTERM.F_GET_POLIZA(PCAGENTE, PFPERINI, PFPERFIN, 3),
             0),
         NVL(PAC_FICH_INTERM.F_GET_POLIZA(PCAGENTE, PFPERINI, PFPERFIN, 4),
             0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 1), 0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 2), 0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 3), 0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 4), 0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 5), 0),
         0,
         0,
         0,
         NVL(V_NSINIESTROS, 0),
         NVL(V_RESERVAS, 0),
         NVL(V_PAGOS, 0),
         NVL(V_IRECSIN, 0),
         0,
         NVL(V_NTRAMITESJ, 0),
         NVL(V_PTRAMITESJ, 0),
         0,
         'CONFIRED ');
    ELSE
      INSERT INTO FICHA_AGENTE_PREV
        (CAGENTE,
         SPROCES,
         FDESDE,
         FHASTA,
         FCALCUL,
         NPOLFECHA,
         NPOLIZAS,
         ISUMPRI,
         ISUMPRIA,
         ICANTIDAD30,
         ICANTIDAD60,
         ICANTIDAD90,
         ICANTIDADMAS90,
         ICARTERA,
         NNUMFORM,
         NNUMINF,
         NNUMPAG,
         NAVISIN,
         IRESSIN,
         IPAGSIN,
         IRECSIN,
         IPAGREC,
         NNUMPROJUD,
         IPAGINCJUD,
         IRETPOLVIG,
         TTIPCANAL)
      VALUES
        (PCAGENTE,
         PSPROCES,
         PFPERINI,
         PFPERFIN,
         F_SYSDATE,
         NVL(PAC_FICH_INTERM.F_GET_POLIZA(PCAGENTE, PFPERINI, PFPERFIN, 1),
             0),
         NVL(PAC_FICH_INTERM.F_GET_POLIZA(PCAGENTE, PFPERINI, PFPERFIN, 2),
             0),
         NVL(PAC_FICH_INTERM.F_GET_POLIZA(PCAGENTE, PFPERINI, PFPERFIN, 3),
             0),
         NVL(PAC_FICH_INTERM.F_GET_POLIZA(PCAGENTE, PFPERINI, PFPERFIN, 4),
             0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 1), 0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 2), 0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 3), 0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 4), 0),
         NVL(PAC_FICH_INTERM.F_GET_CARTERAVEN(PCAGENTE, 5), 0),
         0,
         0,
         0,
         NVL(V_NSINIESTROS, 0),
         NVL(V_RESERVAS, 0),
         NVL(V_PAGOS, 0),
         0,
         0,
         NVL(V_NTRAMITESJ, 0),
         NVL(V_PTRAMITESJ, 0),
         0,
         'CONFIRED ');
    END IF;
  
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  V_TOBJETO,
                  V_NTRAZA,
                  V_TPARAM || ': Error' || SQLCODE,
                  SQLERRM);
      RETURN 1;
  END F_GRABAR_REGISTRO;

  /**************************************************************************
        F_GET_CARTERAVEN
  *************************************************************************/
  FUNCTION F_GET_CARTERAVEN(PCAGENTE IN AGENTES.CAGENTE%TYPE,
                            PTIPO    IN NUMBER) RETURN NUMBER IS
  
    CURSOR C_POLI IS
      SELECT R.NRECIBO,
             R.SSEGURO,
             GREATEST(R.FEFECTO, S.FEFECTO) FEFECTO,
             S.IPRIANU
        FROM RECIBOS R, MOVRECIBO M, SEGUROS S
       WHERE R.NRECIBO = M.NRECIBO
         AND M.SMOVREC = (SELECT MAX(SMOVREC)
                            FROM MOVRECIBO MV
                           WHERE MV.NRECIBO = R.NRECIBO)
         AND M.CESTREC = 0
         AND S.SSEGURO = R.SSEGURO
         AND S.CAGENTE = PCAGENTE;
  
    VOBJECTNAME    VARCHAR2(500);
    VPARAM         VARCHAR2(500);
    VPASEXEC       NUMBER := 1;
    ICANTIDAD30    NUMBER := 0;
    ICANTIDAD60    NUMBER := 0;
    ICANTIDAD90    NUMBER := 0;
    ICANTIDADMAS90 NUMBER := 0;
    SUMACARTER     NUMBER := 0;
    DIAS           NUMBER := 0;
    SQUERY         VARCHAR(2000);
  BEGIN
  
    /* CAMBIOS DE SWAPNIL : START
    FOR VAR IN C_POLI LOOP
    
      DIAS := ROUND(F_SYSDATE - VAR.FEFECTO);
    
      IF DIAS BETWEEN 1 AND 30 THEN
          ICANTIDAD30 := ICANTIDAD30 + VAR.IPRIANU; --IAXIS-3152
      ELSIF DIAS BETWEEN 31 AND 60 THEN
          ICANTIDAD60 := ICANTIDAD60 + VAR.IPRIANU;--IAXIS-3152
      ELSIF DIAS BETWEEN 61 AND 90 THEN
          ICANTIDAD90 := ICANTIDAD90 + VAR.IPRIANU;--IAXIS-3152
      ELSIF DIAS > 90 THEN
          ICANTIDADMAS90 := ICANTIDADMAS90 + VAR.IPRIANU;--IAXIS-3152
      END IF;
    
      SUMACARTER := SUMACARTER + VAR.IPRIANU;
    END LOOP;
    
      IF PTIPO = 1 THEN
        RETURN ICANTIDAD30;
      ELSIF PTIPO = 2 THEN
        RETURN ICANTIDAD60;
      ELSIF PTIPO = 3 THEN
        RETURN ICANTIDAD90;
      ELSIF PTIPO = 4 THEN
        RETURN ICANTIDADMAS90;
      ELSIF PTIPO = 5 THEN
        RETURN SUMACARTER;
      END IF;
      CAMBIOS DE SWAPNIL : END */
  
    /* CAMBIOS DE SWAPNIL : START */
    SQUERY := 'SELECT SUM(S.IPRIANU)
             FROM RECIBOS   R,
                  MOVRECIBO M,
                  SEGUROS   S
            WHERE R.NRECIBO = M.NRECIBO
              AND M.SMOVREC = (SELECT MAX(SMOVREC) FROM MOVRECIBO MV WHERE MV.NRECIBO = R.NRECIBO)
              AND M.CESTREC = 0
              AND S.SSEGURO = R.SSEGURO
              AND S.CAGENTE = ' || PCAGENTE;
  
    IF PTIPO = 1 THEN
      SQUERY := SQUERY ||
                ' AND ROUND(F_SYSDATE - GREATEST(R.FEFECTO, S.FEFECTO)) BETWEEN 1 AND 30';
    ELSIF PTIPO = 2 THEN
      SQUERY := SQUERY ||
                ' AND ROUND(F_SYSDATE - GREATEST(R.FEFECTO, S.FEFECTO)) BETWEEN 31 AND 60';
    ELSIF PTIPO = 3 THEN
      SQUERY := SQUERY ||
                ' AND ROUND(F_SYSDATE - GREATEST(R.FEFECTO, S.FEFECTO)) BETWEEN 61 AND 90';
    ELSIF PTIPO = 4 THEN
      SQUERY := SQUERY ||
                ' AND ROUND(F_SYSDATE - GREATEST(R.FEFECTO, S.FEFECTO)) > 90';
    ELSIF PTIPO = 5 THEN
      SQUERY := SQUERY ||
                'AND ROUND(F_SYSDATE - GREATEST(R.FEFECTO, S.FEFECTO)) >= 1';
    END IF;
  
    EXECUTE IMMEDIATE SQUERY
      INTO SUMACARTER;
    RETURN SUMACARTER;
    /* CAMBIOS DE SWAPNIL : END */
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END F_GET_CARTERAVEN;

END PAC_FICH_INTERM;
/
