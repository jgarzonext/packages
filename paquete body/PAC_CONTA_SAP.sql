CREATE OR REPLACE PACKAGE BODY PAC_CONTA_SAP IS

  PROCEDURE GENERA_CODESCENARIO IS
  
    CURSOR MOV_CONTA(P_EVENTO VARCHAR2) IS
      SELECT A.NRECIBO,
             A.CAGENTE,
             A.NMOVIMI,
             A.SSEGURO,
             A.RAMO,
             A.CTIPCOA,
             A.CTIPREC
        FROM MOVCONTASAP A
       WHERE CODESCENARIO = 0
         AND ESTADO = 0
         AND EVENTO = P_EVENTO;
  
    X_RAMO    NUMBER;
    X_SPRODUC NUMBER;
    X_EVENTO  VARCHAR2(50) := 'PRODUCCION';
    --X_VALOR   NUMBER := 0;
    --X_TOTAL   NUMBER := 0;
    X_ESTADO_I NUMBER := 0;
    X_ESTADO   NUMBER := 1;
    X_CTIPCOM  NUMBER;
    X_CPOLCIA SEGUROS.CPOLCIA%TYPE;

  BEGIN
  
    /*
     IN ESTADO COLUMN
      0 --Inicio     -- WHEN TRIGGER INSERTS DATA IN MOVCONTASAP TABLE
      1 --Procesando -- WHEN GENERA_CODESCENARIO PRCEDURE STARTS PROCESSING
      2 --Generaron  -- WHEN GENERA_CODESCENARIO PRCEDURE FINSIH PROCESSING
    */
    FOR TEMP IN MOV_CONTA(X_EVENTO) LOOP
    
      UPDATE MOVCONTASAP M
         SET M.ESTADO = X_ESTADO
       WHERE M.CAGENTE = TEMP.CAGENTE
         AND M.NRECIBO = TEMP.NRECIBO
         AND M.ESTADO = X_ESTADO_I;
      COMMIT;
       
      SELECT A.CRAMO, A.SPRODUC, A.CTIPCOM, A.CPOLCIA
        INTO X_RAMO, X_SPRODUC, X_CTIPCOM, X_CPOLCIA
        FROM SEGUROS A
       WHERE A.SSEGURO = TEMP.SSEGURO;
    
      IF X_SPRODUC IN (80007, 80008) THEN
        X_RAMO := X_RAMO || X_SPRODUC;
      END IF;
    
      --PRIMAS DIRECTAS / COASEGURO CEDIDO
      IF TEMP.CTIPCOA IN (0, 1, 2) THEN
        IF TEMP.CTIPREC = '0000' THEN
          --PRODUCCION NUEVA
          PRIMAS_DIRECTAS(TEMP.NRECIBO,
                          TEMP.CAGENTE,
                          TEMP.NMOVIMI,
                          TEMP.SSEGURO,
                          X_RAMO,
                          TEMP.CTIPCOA,
                          TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC = '1010' THEN
          --SUPLEMENTO POSITIVO
          PRIMAS_DIRECTAS(TEMP.NRECIBO,
                          TEMP.CAGENTE,
                          TEMP.NMOVIMI,
                          TEMP.SSEGURO,
                          X_RAMO,
                          TEMP.CTIPCOA,
                          TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC = '9010' THEN
          --SUPLEMENTO NEGATIVO
          PRIMAS_DIRECTAS_SUPLEMENOS(TEMP.NRECIBO,
                                     TEMP.CAGENTE,
                                     TEMP.NMOVIMI,
                                     TEMP.SSEGURO,
                                     X_RAMO,
                                     TEMP.CTIPCOA,
                                     TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC IN ('1522', '9521', '9032', '9031') THEN
          --(1522)ANULACION SUPLEMENTO POSITIVO SIN RECAUDO -- (9521)ANULACION SUPLEMENTO POSITIVO CON RECAUDO -- (9032)ANULACION TOTAL SIN RECAUDO
          --(9031)ANULACION TOTAL CON RECAUDO
          ANULA_DIRECTAS_SUPLEMAS(TEMP.NRECIBO,
                                  TEMP.CAGENTE,
                                  TEMP.NMOVIMI,
                                  TEMP.SSEGURO,
                                  X_RAMO,
                                  X_CPOLCIA,
                                  TEMP.CTIPCOA,
                                  TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC IN ('9522', '1521') THEN
          --(9522)ANULACION SUPLEMENTO NEGATIVO SIN RECAUDO -- (1521)ANULACION SUPLEMENTO NEGATIVO CON RECAUDO -- (9032)ANULACION TOTAL SIN RECAUDO
          --(9031)ANULACION TOTAL CON RECAUDO
          ANULA_DIRECTAS_SUPLEMENOS(TEMP.NRECIBO,
                                    TEMP.CAGENTE,
                                    TEMP.NMOVIMI,
                                    TEMP.SSEGURO,
                                    X_RAMO,
                                    X_CPOLCIA,
                                    TEMP.CTIPCOA,
                                    TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC IN ('9532', '9531') THEN
          --(9532)CANCELACIONES SIN RECAUDO -- (9531)CANCELACIONES CON RECAUDO     
          CANCELA_DIRECTAS(TEMP.NRECIBO,
                           TEMP.CAGENTE,
                           TEMP.NMOVIMI,
                           TEMP.SSEGURO,
                           X_RAMO,
                           TEMP.CTIPCOA,
                           TEMP.CTIPREC);
        END IF;
      END IF;
      --PRIMAS DIRECTAS COASEGURO ACEPTADO
      IF TEMP.CTIPCOA IN (8, 9) THEN
        IF TEMP.CTIPREC = '0000' THEN
          --PRODUCCION NUEVA
          PRIMAS_COA_ACEPTADO(TEMP.NRECIBO,
                              TEMP.CAGENTE,
                              TEMP.NMOVIMI,
                              TEMP.SSEGURO,
                              X_RAMO,
                              TEMP.CTIPCOA,
                              TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC = '1010' THEN
          --SUPLEMENTO POSITIVO
          PRIMAS_COA_ACEPTADO(TEMP.NRECIBO,
                              TEMP.CAGENTE,
                              TEMP.NMOVIMI,
                              TEMP.SSEGURO,
                              X_RAMO,
                              TEMP.CTIPCOA,
                              TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC = '9010' THEN
          --SUPLEMENTO NEGATIVO
          COA_ACEPTADO_SUPLEMENOS(TEMP.NRECIBO,
                                  TEMP.CAGENTE,
                                  TEMP.NMOVIMI,
                                  TEMP.SSEGURO,
                                  X_RAMO,
                                  TEMP.CTIPCOA,
                                  TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC IN ('1522', '9521', '9032', '9031') THEN
          --(1522)ANULACION SUPLEMENTO POSITIVO SIN RECAUDO -- (9521)ANULACION SUPLEMENTO POSITIVO CON RECAUDO -- (9032)ANULACION TOTAL SIN RECAUDO
          --(9031)ANULACION TOTAL CON RECAUDO
          ANULA_COA_ACEPTADO_SUPLEMAS(TEMP.NRECIBO,
                                      TEMP.CAGENTE,
                                      TEMP.NMOVIMI,
                                      TEMP.SSEGURO,
                                      X_RAMO,
                                      X_CPOLCIA,
                                      TEMP.CTIPCOA,
                                      TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC IN ('9522', '1521') THEN
          --(9522)ANULACION SUPLEMENTO NEGATIVO SIN RECAUDO -- (1521)ANULACION SUPLEMENTO NEGATIVO CON RECAUDO -- (9032)ANULACION TOTAL SIN RECAUDO
          --(9031)ANULACION TOTAL CON RECAUDO
          ANULA_COA_ACEPTADO_SUPLEMENOS(TEMP.NRECIBO,
                                        TEMP.CAGENTE,
                                        TEMP.NMOVIMI,
                                        TEMP.SSEGURO,
                                        X_RAMO,
                                        X_CPOLCIA,
                                        TEMP.CTIPCOA,
                                        TEMP.CTIPREC);
        ELSIF TEMP.CTIPREC IN ('9532', '9531') THEN
          --(9532)CANCELACIONES SIN RECAUDO -- (9531)CANCELACIONES CON RECAUDO     
          CANCELA_DIRECTAS(TEMP.NRECIBO,
                           TEMP.CAGENTE,
                           TEMP.NMOVIMI,
                           TEMP.SSEGURO,
                           X_RAMO,
                           TEMP.CTIPCOA,
                           TEMP.CTIPREC);
        END IF;
      END IF;
    
      -- PURGA DE ESCENARIOS PARA EL CASO DE COMISION 0%
    
      IF X_CTIPCOM = 99 THEN
      
        ELIMINA_SCENARIO(TEMP.NRECIBO,
                         TEMP.CAGENTE,
                         TEMP.NMOVIMI,
                         TEMP.SSEGURO,
                         X_RAMO,
                         TEMP.CTIPCOA,
                         TEMP.CTIPREC);

      END IF;
      
      -- PURGA DE ESCENARIOS PARA EL CASO DE POLIZAS MIGRADAS
      
      IF TEMP.CTIPREC IN ('1522','9522','9032') AND X_CPOLCIA IS NOT NULL THEN 
          
         ELIMINA_SCENARIO_MIGRACION(TEMP.NRECIBO,
                                    TEMP.NMOVIMI,
                                    TEMP.SSEGURO,
                                    X_RAMO,
                                    TEMP.CTIPCOA,
                                    TEMP.CTIPREC);
      END IF;
    
    END LOOP;
  END GENERA_CODESCENARIO;

  PROCEDURE PRIMAS_DIRECTAS(X_RECIBO  NUMBER,
                            X_CAGENTE NUMBER,
                            X_NMOVIMI NUMBER,
                            X_SSEGURO NUMBER,
                            X_RAMO    NUMBER,
                            X_CTIPCOA NUMBER,
                            X_CTIPREC VARCHAR2) IS
  
    CURSOR C_AGE_CORRETAJE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CAGENTE
        FROM RECIBOS R, AGE_CORRETAJE AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND AC.NMOVIMI = R.NMOVIMI
         AND R.NRECIBO = C_NRECIBO;
  
    CURSOR C_COMPA_COASE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CCOMPAN
        FROM RECIBOS R, COACEDIDO AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND R.NRECIBO = C_NRECIBO;
  
    X_VALOR      NUMBER := 0;
    X_CODESC260  NUMBER := 260;
    X_CODESC255  NUMBER := 255;
    X_CODESC248  NUMBER := 248;
    X_CODESC256  NUMBER := 256;
    X_CODESC261  NUMBER := 261; --COASEGURO CEDIDO
    X_CODESC249  NUMBER := 249; --COASEGURO CEDIDO
    X_CODESC333  NUMBER := 333;
    X_CODESC335  NUMBER := 335;
    X_CODESC346  NUMBER := 346;
    X_FEMISIO    DATE;
    X_FEFECTO    DATE;
    X_VIGFUT     NUMBER := 0;
    X_CORRETAJE  NUMBER;
    X_TIPAGENTE  NUMBER;
    X_EVENTO     VARCHAR2(50) := 'PRODUCCION';
    X_ESTADO_OLD NUMBER := 1;
    X_ESTADO_NEW NUMBER := 2;
  
  BEGIN
  
    --VALIDACION VIGENCIA FURUTA
    SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM RECIBOS R
     WHERE SSEGURO = X_SSEGURO
       AND NRECIBO = X_RECIBO;

    IF X_FEFECTO > X_FEMISIO THEN
      X_VIGFUT := 1;
    ELSE
      X_VIGFUT := 0;
    END IF;
  
    IF X_VIGFUT = 0 THEN
      IF X_CTIPCOA = 0 THEN
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC260,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      ELSE
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC261,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      END IF;
    
      --VALIDA INTERMEDIACION
      X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
      IF X_CORRETAJE <> 0 THEN
        FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = AGEN.CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC255,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC256,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END IF;
        END LOOP;
        IF X_CTIPCOA IN (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPAN,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC249,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;
      ELSE
        SELECT CTIPAGE
          INTO X_TIPAGENTE
          FROM AGENTES
         WHERE CAGENTE = X_CAGENTE;
      
        IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC255,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        ELSIF X_TIPAGENTE = 4 THEN
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC256,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
          /*
          IF X_CTIPCOA = 1 THEN
               FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                     INSERT INTO MOVCONTASAP VALUES (X_RECIBO, X_CAGENTE, X_NMOVIMI, X_SSEGURO, X_RAMO, X_CTIPCOA, X_CTIPREC, X_CODESC249, X_VALOR, X_EVENTO);
                     COMMIT;       
               END LOOP;
           END IF;
           */
        END IF;
      END IF;
    
      IF X_CTIPCOA IN (1, 2) AND X_CORRETAJE = 0 THEN
        FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             COA.CCOMPAN,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC249,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END LOOP;
      END IF;
    ELSE
      --VF
      IF X_CTIPCOA = 0 THEN
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC333,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      ELSE
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC346,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      END IF;
    
      INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         RAMO,
         CTIPCOA,
         CTIPREC,
         CODESCENARIO,
         ESTADO,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (X_RECIBO,
         X_CAGENTE,
         X_NMOVIMI,
         X_SSEGURO,
         X_RAMO,
         X_CTIPCOA,
         X_CTIPREC,
         X_CODESC335,
         X_ESTADO_NEW,
         X_EVENTO,
         SYSDATE);
      /*INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         RAMO,
         CTIPCOA,
         CTIPREC,
         CODESCENARIO,
         ESTADO,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (X_RECIBO,
         X_CAGENTE,
         X_NMOVIMI,
         X_SSEGURO,
         X_RAMO,
         X_CTIPCOA,
         X_CTIPREC,
         X_CODESC248,
         X_ESTADO_NEW,
         X_EVENTO,
         SYSDATE);*/
      COMMIT;
    
      --VALIDA INTERMEDIACION
      X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
      IF X_CORRETAJE <> 0 THEN
        FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = AGEN.CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC255,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC248,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC256,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC248,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          
          END IF;
        END LOOP;
        IF X_CTIPCOA IN (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPAN,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC249,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;
      ELSE
        SELECT CTIPAGE
          INTO X_TIPAGENTE
          FROM AGENTES
         WHERE CAGENTE = X_CAGENTE;
      
        IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC255,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC248,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        ELSIF X_TIPAGENTE = 4 THEN
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC256,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC248,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
          IF X_CTIPCOA IN (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC249,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        END IF;
      END IF;

      /*IF X_CTIPCOA IN (1, 2) THEN
        FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             COA.CCOMPAN,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC249,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END LOOP;
      END IF;*/
    END IF;
  
  END PRIMAS_DIRECTAS;

  PROCEDURE PRIMAS_COA_ACEPTADO(X_RECIBO  NUMBER,
                                X_CAGENTE NUMBER,
                                X_NMOVIMI NUMBER,
                                X_SSEGURO NUMBER,
                                X_RAMO    NUMBER,
                                X_CTIPCOA NUMBER,
                                X_CTIPREC VARCHAR2) IS
  
    CURSOR C_AGE_CORRETAJE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CAGENTE
        FROM RECIBOS R, AGE_CORRETAJE AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND AC.NMOVIMI = R.NMOVIMI
         AND R.NRECIBO = C_NRECIBO;
  
    X_VALOR      NUMBER := 0;
    X_CODESC262  NUMBER := 262;
    X_CODESC257  NUMBER := 257;
    X_CODESC266  NUMBER := 266;
    X_CODESC351  NUMBER := 351;
    X_CODESC353  NUMBER := 353;
    X_FEMISIO    DATE;
    X_FEFECTO    DATE;
    X_VIGFUT     NUMBER := 0;
    X_CORRETAJE  NUMBER;
    X_EVENTO     VARCHAR2(50) := 'PRODUCCION';
    X_ESTADO_OLD NUMBER := 1;
    X_ESTADO_NEW NUMBER := 2;
  
  BEGIN
  
    --VALIDACION VIGENCIA FURUTA
    /*SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM SEGUROS A
     WHERE SSEGURO = X_SSEGURO;*/
     
    SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM RECIBOS R
     WHERE SSEGURO = X_SSEGURO
       AND NRECIBO = X_RECIBO;

    IF X_FEFECTO > X_FEMISIO THEN
      X_VIGFUT := 1;
    ELSE
      X_VIGFUT := 0;
    END IF;
  
    IF X_VIGFUT = 0 THEN
    
      UPDATE MOVCONTASAP A
         SET A.CODESCENARIO    = X_CODESC262,
             A.RAMO            = X_RAMO,
             A.FECHA_SOLICITUD = SYSDATE,
             A.ESTADO          = X_ESTADO_NEW
       WHERE A.NRECIBO = X_RECIBO
         AND A.CAGENTE = X_CAGENTE
         AND A.NMOVIMI = X_NMOVIMI
         AND A.SSEGURO = X_SSEGURO
         AND A.RAMO = X_VALOR
         AND A.CTIPCOA = X_CTIPCOA
         AND A.ESTADO = X_ESTADO_OLD
         AND A.CODESCENARIO = X_VALOR;
      COMMIT;
    
      --VALIDA INTERMEDIACION
      X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
      IF X_CORRETAJE <> 0 THEN
        FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             AGEN.CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC257,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END LOOP;
      ELSE
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC257,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      END IF;
    ELSE
      UPDATE MOVCONTASAP A
         SET A.CODESCENARIO    = X_CODESC351,
             A.RAMO            = X_RAMO,
             A.FECHA_SOLICITUD = SYSDATE,
             A.ESTADO          = X_ESTADO_NEW
       WHERE A.NRECIBO = X_RECIBO
         AND A.CAGENTE = X_CAGENTE
         AND A.NMOVIMI = X_NMOVIMI
         AND A.SSEGURO = X_SSEGURO
         AND A.RAMO = X_VALOR
         AND A.CTIPCOA = X_CTIPCOA
         AND A.ESTADO = X_ESTADO_OLD
         AND A.CODESCENARIO = X_VALOR;
      COMMIT;
    
      INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         RAMO,
         CTIPCOA,
         CTIPREC,
         CODESCENARIO,
         ESTADO,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (X_RECIBO,
         X_CAGENTE,
         X_NMOVIMI,
         X_SSEGURO,
         X_RAMO,
         X_CTIPCOA,
         X_CTIPREC,
         X_CODESC353,
         X_ESTADO_NEW,
         X_EVENTO,
         SYSDATE);
      INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         RAMO,
         CTIPCOA,
         CTIPREC,
         CODESCENARIO,
         ESTADO,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (X_RECIBO,
         X_CAGENTE,
         X_NMOVIMI,
         X_SSEGURO,
         X_RAMO,
         X_CTIPCOA,
         X_CTIPREC,
         X_CODESC266,
         X_ESTADO_NEW,
         X_EVENTO,
         SYSDATE);
    
      --VALIDA INTERMEDIACION
      X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
      IF X_CORRETAJE <> 0 THEN
        FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             AGEN.CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC257,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END LOOP;
      ELSE
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC257,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      END IF;
    END IF;
  
  END PRIMAS_COA_ACEPTADO;

  PROCEDURE PRIMAS_DIRECTAS_SUPLEMENOS(X_RECIBO  NUMBER,
                                       X_CAGENTE NUMBER,
                                       X_NMOVIMI NUMBER,
                                       X_SSEGURO NUMBER,
                                       X_RAMO    NUMBER,
                                       X_CTIPCOA NUMBER,
                                       X_CTIPREC VARCHAR2) IS
  
    CURSOR C_AGE_CORRETAJE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CAGENTE
        FROM RECIBOS R, AGE_CORRETAJE AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND AC.NMOVIMI = R.NMOVIMI
         AND R.NRECIBO = C_NRECIBO;
  
    CURSOR C_COMPA_COASE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CCOMPAN
        FROM RECIBOS R, COACEDIDO AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND R.NRECIBO = C_NRECIBO;
  
    X_VALOR     NUMBER := 0;
    X_CODESC258 NUMBER := 258;
    X_CODESC253 NUMBER := 253;
    X_CODESC263 NUMBER := 263;
    X_CODESC251 NUMBER := 251;
    X_CODESC259 NUMBER := 259; --COASEGURO CEDIDO
    --X_CODESC249 NUMBER := 249; --COASEGURO CEDIDO
    X_CODESC214  NUMBER := 214;
    X_CODESC334  NUMBER := 334;
    X_CODESC336  NUMBER := 336;
    X_CODESC345  NUMBER := 345;
    X_FEMISIO    DATE;
    X_FEFECTO    DATE;
    X_VIGFUT     NUMBER := 0;
    X_CORRETAJE  NUMBER;
    X_TIPAGENTE  NUMBER;
    X_EVENTO     VARCHAR2(50) := 'PRODUCCION';
    X_ESTADO_OLD NUMBER := 1;
    X_ESTADO_NEW NUMBER := 2;
  
  BEGIN
  
    --VALIDACION VIGENCIA FURUTA
   /* SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM SEGUROS A
     WHERE SSEGURO = X_SSEGURO;*/
     
    SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM RECIBOS R
     WHERE SSEGURO = X_SSEGURO
       AND NRECIBO = X_RECIBO;

    IF X_FEFECTO > X_FEMISIO THEN
      X_VIGFUT := 1;
    ELSE
      X_VIGFUT := 0;
    END IF;
  
    IF X_VIGFUT = 0 THEN
      IF X_CTIPCOA = 0 THEN
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC258,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      ELSE
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC259,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      END IF;
    
      --VALIDA INTERMEDIACION
      X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
      IF X_CORRETAJE <> 0 THEN
        FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = AGEN.CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC253,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /*            IF X_CTIPCOA = 1 THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   COA.CCOMPAN,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC214,
                   X_VALOR,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC251,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END IF;
        END LOOP;
        IF X_CTIPCOA IN (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPAN,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC214,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;
      ELSE
        SELECT CTIPAGE
          INTO X_TIPAGENTE
          FROM AGENTES
         WHERE CAGENTE = X_CAGENTE;
      
        IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC253,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
          IF X_CTIPCOA = 1 THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC214,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        ELSIF X_TIPAGENTE = 4 THEN
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC251,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
          IF X_CTIPCOA = 1 THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC214,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        END IF;
      END IF;
    
      /*      IF X_CTIPCOA = 1 THEN
        FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             COA.CCOMPAN,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC214,
             X_VALOR,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END LOOP;
      END IF;*/
    ELSE
      IF X_CTIPCOA = 0 THEN
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC334,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      ELSE
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC345,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      END IF;
    
      INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         RAMO,
         CTIPCOA,
         CTIPREC,
         CODESCENARIO,
         ESTADO,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (X_RECIBO,
         X_CAGENTE,
         X_NMOVIMI,
         X_SSEGURO,
         X_RAMO,
         X_CTIPCOA,
         X_CTIPREC,
         X_CODESC336,
         X_ESTADO_NEW,
         X_EVENTO,
         SYSDATE);
      /*INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         RAMO,
         CTIPCOA,
         CTIPREC,
         CODESCENARIO,
         ESTADO,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (X_RECIBO,
         X_CAGENTE,
         X_NMOVIMI,
         X_SSEGURO,
         X_RAMO,
         X_CTIPCOA,
         X_CTIPREC,
         X_CODESC263,
         X_ESTADO_NEW,
         X_EVENTO,
         SYSDATE);*/
      COMMIT;
    
      --VALIDA INTERMEDIACION
      X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
      IF X_CORRETAJE <> 0 THEN
        FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = AGEN.CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC253,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            INSERT INTO MOVCONTASAP -- 263
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC263,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            IF X_CTIPCOA IN (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   COA.CCOMPAN,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC214,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC251,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC263,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END IF;
        END LOOP;
        IF X_CTIPCOA IN (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPAN,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC214,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;
      ELSE
        SELECT CTIPAGE
          INTO X_TIPAGENTE
          FROM AGENTES
         WHERE CAGENTE = X_CAGENTE;
      
        IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC253,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC263,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
          /*          IF X_CTIPCOA = 1 THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC214,
                 X_VALOR,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;*/
        ELSIF X_TIPAGENTE = 4 THEN
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC251,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC263,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        
          IF X_CTIPCOA IN (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 X_CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC214,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        
        END IF;
      END IF;
    
      /*
      IF X_CTIPCOA = 1 THEN
        FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             COA.CCOMPAN,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC214,
             X_VALOR,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END LOOP;
      END IF;
      */
    END IF;
  
  END PRIMAS_DIRECTAS_SUPLEMENOS;

  PROCEDURE ANULA_DIRECTAS_SUPLEMAS(X_RECIBO  NUMBER,
                                    X_CAGENTE NUMBER,
                                    X_NMOVIMI NUMBER,
                                    X_SSEGURO NUMBER,
                                    X_RAMO    NUMBER,
                                    X_CPOLCIA VARCHAR2,
                                    X_CTIPCOA NUMBER,
                                    X_CTIPREC VARCHAR2) IS
  
    CURSOR C_AGE_CORRETAJE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CAGENTE
        FROM RECIBOS R, AGE_CORRETAJE AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND AC.NMOVIMI = R.NMOVIMI
         AND R.NRECIBO = C_NRECIBO;
  
    CURSOR C_COMPA_COASE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CCOMPAN
        FROM RECIBOS R, COACEDIDO AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND R.NRECIBO = C_NRECIBO;
  
    X_VALOR      NUMBER := 0;
    X_CODESC244  NUMBER := 244;
    X_CODESC239  NUMBER := 239;
    X_CODESC232  NUMBER := 232;
    X_CODESC240  NUMBER := 240;
    X_CODESC245  NUMBER := 245; --COASEGURO CEDIDO
    X_CODESC249  NUMBER := 249; --COASEGURO CEDIDO
    X_CODESC229  NUMBER := 229;
    X_CODESC250  NUMBER := 250;
    X_CODESC225  NUMBER := 225;
    X_CODESC233  NUMBER := 233;
    X_CODESC230  NUMBER := 230;
    X_CODESC337  NUMBER := 337;
    X_CODESC339  NUMBER := 339;
    X_CODESC341  NUMBER := 341;
    X_CODESC343  NUMBER := 343;
    X_CODESC218  NUMBER := 218;
    X_CODESC347  NUMBER := 347;
    X_FEMISIO    DATE;
    X_FEFECTO    DATE;
    X_VIGFUT     NUMBER := 0;
    X_CORRETAJE  NUMBER;
    X_TIPAGENTE  NUMBER;
    X_EVENTO     VARCHAR2(50) := 'PRODUCCION';
    X_ESTADO_OLD NUMBER := 1;
    X_ESTADO_NEW NUMBER := 2;
    X_VIGENCIA   VARCHAR2(2);

  BEGIN
  
    IF X_CTIPREC IN (1522, 9032) THEN
     
    /*VALIDACION DE VIGENCIA FUTURA Y ACTUAL*/ 
      X_VIGFUT := PAC_CONTA_SAP.F_TIPOVIGENCIA(X_RECIBO,X_SSEGURO,X_CPOLCIA,NULL);

      IF X_VIGFUT = 0 THEN
      
        IF X_CTIPCOA = 0 THEN
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC244,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        ELSE
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC245,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        END IF;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC239,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              --ESCENARIO CAUSA GASTO PARA POLIZA MIGRADA VF
              X_VIGENCIA := PAC_CONTA_SAP.F_CAUSAGASTO(X_RECIBO,X_SSEGURO); 
              IF X_VIGENCIA = 'SI' THEN
                INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
                VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC232,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
                COMMIT;
              END IF;
               COMMIT;
        
              /*IF X_CTIPCOA in (1, 2) THEN
                FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                  INSERT INTO MOVCONTASAP
                    (NRECIBO,
                     CAGENTE,
                     NMOVIMI,
                     SSEGURO,
                     RAMO,
                     CTIPCOA,
                     CTIPREC,
                     CODESCENARIO,
                     ESTADO,
                     EVENTO,
                     FECHA_SOLICITUD)
                  VALUES
                    (X_RECIBO,
                     AGEN.CAGENTE,
                     X_NMOVIMI,
                     X_SSEGURO,
                     X_RAMO,
                     X_CTIPCOA,
                     X_CTIPREC,
                     X_CODESC233,
                     X_ESTADO_NEW,
                     X_EVENTO,
                     SYSDATE);
                  COMMIT;
                END LOOP;
              END IF;*/
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC240,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              --ESCENARIO CAUSA GASTO PARA POLIZA MIGRADA VF
              X_VIGENCIA := PAC_CONTA_SAP.F_CAUSAGASTO(X_RECIBO,X_SSEGURO) ; 
              IF X_VIGENCIA = 'SI' THEN
                INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
                VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC232,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
                COMMIT;
              END IF;
              COMMIT;
            END IF;
          END LOOP;
          IF X_CTIPCOA in (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC233,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC239,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
           --ESCENARIO CAUSA GASTO PARA POLIZA MIGRADA VF  
            X_VIGENCIA := PAC_CONTA_SAP.F_CAUSAGASTO(X_RECIBO,X_SSEGURO); 
            IF X_VIGENCIA = 'SI' THEN
              INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
              VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC232,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
              COMMIT;
            END IF;
            COMMIT;
            /*IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC233,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC240,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /*IF X_CTIPCOA in (1 ,2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC233,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          END IF;
        END IF;
      
        /*IF X_CTIPCOA in (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPANI,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC233,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;*/
      ELSE
        IF X_CTIPCOA = 0 THEN
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC337,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        ELSE
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC347,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        END IF;
      
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC339,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        /*INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC232,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);*/
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC239,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC232,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              /*IF X_CTIPCOA in (1 ,2) THEN
                FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                  INSERT INTO MOVCONTASAP
                    (NRECIBO,
                     CAGENTE,
                     NMOVIMI,
                     SSEGURO,
                     RAMO,
                     CTIPCOA,
                     CTIPREC,
                     CODESCENARIO,
                     ESTADO,
                     EVENTO,
                     FECHA_SOLICITUD)
                  VALUES
                    (X_RECIBO,
                     COA.CCOMPAN,
                     X_NMOVIMI,
                     X_SSEGURO,
                     X_RAMO,
                     X_CTIPCOA,
                     X_CTIPREC,
                     X_CODESC233,
                     X_ESTADO_NEW,
                     X_EVENTO,
                     SYSDATE);
                  COMMIT;
                END LOOP;
              END IF; */
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC240,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC232,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END IF;
          END LOOP;
          IF X_CTIPCOA in (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC233,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC239,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC232,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            IF X_CTIPCOA in (1, 2) THEN
              -- New
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   COA.CCOMPAN,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC233,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC240,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
               
              INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC232,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          
            IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   COA.CCOMPAN, -- X_AGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC233,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;
          END IF;
        END IF;
      
        /* IF X_CTIPCOA in (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPANI,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC233,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;*/
      END IF;
    END IF;
  
    IF X_CTIPREC IN (9521, 9031) THEN
      --VALIDACION VIGENCIA FURUTA
      /*SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
        INTO X_FEMISIO, X_FEFECTO
        FROM SEGUROS A
       WHERE SSEGURO = X_SSEGURO;*/
       
    SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM RECIBOS R
     WHERE SSEGURO = X_SSEGURO
       AND NRECIBO = X_RECIBO;

      IF X_FEFECTO > X_FEMISIO THEN
        X_VIGFUT := 1;
      ELSE
        X_VIGFUT := 0;
      END IF;
    
      IF X_VIGFUT = 0 THEN
      
        IF X_CTIPCOA = 0 THEN
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC229,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        ELSE
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC230,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        END IF;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC250,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              IF X_CTIPCOA in (1, 2) THEN
                FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                  INSERT INTO MOVCONTASAP
                    (NRECIBO,
                     CAGENTE,
                     NMOVIMI,
                     SSEGURO,
                     RAMO,
                     CTIPCOA,
                     CTIPREC,
                     CODESCENARIO,
                     ESTADO,
                     EVENTO,
                     FECHA_SOLICITUD)
                  VALUES
                    (X_RECIBO,
                     COA.CCOMPAN,
                     X_NMOVIMI,
                     X_SSEGURO,
                     X_RAMO,
                     X_CTIPCOA,
                     X_CTIPREC,
                     X_CODESC233,
                     X_ESTADO_NEW,
                     X_EVENTO,
                     SYSDATE);
                  COMMIT;
                END LOOP;
              END IF;
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC225,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END IF;
          END LOOP;
          /* IF X_CTIPCOA in (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC233,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;*/
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC250,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /*IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC233,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC225,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /*IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC233,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          END IF;
        END IF;
      
        /*IF X_CTIPCOA in (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPANI,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC233,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;*/
      ELSE
        IF X_CTIPCOA = 0 THEN
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC341,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        ELSE
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC245,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        END IF;
      
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC343,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        /*INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC218,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);*/
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC250,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC218,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              /*IF X_CTIPCOA in (1, 2) THEN
                FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                  INSERT INTO MOVCONTASAP
                    (NRECIBO,
                     CAGENTE,
                     NMOVIMI,
                     SSEGURO,
                     RAMO,
                     CTIPCOA,
                     CTIPREC,
                     CODESCENARIO,
                     ESTADO,
                     EVENTO,
                     FECHA_SOLICITUD)
                  VALUES
                    (X_RECIBO,
                     AGEN.CAGENTE,
                     X_NMOVIMI,
                     X_SSEGURO,
                     X_RAMO,
                     X_CTIPCOA,
                     X_CTIPREC,
                     X_CODESC249,
                     X_ESTADO_NEW,
                     X_EVENTO,
                     SYSDATE);
                  COMMIT;
                END LOOP;
              END IF;*/
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC225,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC218,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END IF;
          END LOOP;
          IF X_CTIPCOA in (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC249,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC250,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /*IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC249,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC225,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            IF X_CTIPCOA IN (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC249,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;
          END IF;
        END IF;
      
        /*IF X_CTIPCOA in (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPANI,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC249,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;*/
      END IF;
    END IF;
  END ANULA_DIRECTAS_SUPLEMAS;

  PROCEDURE ANULA_DIRECTAS_SUPLEMENOS(X_RECIBO  NUMBER,
                                      X_CAGENTE NUMBER,
                                      X_NMOVIMI NUMBER,
                                      X_SSEGURO NUMBER,
                                      X_RAMO    NUMBER,
                                      X_CPOLCIA VARCHAR2,
                                      X_CTIPCOA NUMBER,
                                      X_CTIPREC VARCHAR2) IS
  
    CURSOR C_AGE_CORRETAJE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CAGENTE
        FROM RECIBOS R, AGE_CORRETAJE AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND AC.NMOVIMI = R.NMOVIMI
         AND R.NRECIBO = C_NRECIBO;
  
    CURSOR C_COMPA_COASE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CCOMPAN
        FROM RECIBOS R, COACEDIDO AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND R.NRECIBO = C_NRECIBO;
  
    X_VALOR     NUMBER := 0;
    X_CODESC242 NUMBER := 242;
    X_CODESC246 NUMBER := 246;
    X_CODESC235 NUMBER := 235;
    --X_CODESC232 NUMBER := 232;
    --X_CODESC243 NUMBER := 243; --COASEGURO CEDIDO
    --X_CODESC249 NUMBER := 249; --COASEGURO CEDIDO
    X_CODESC227  NUMBER := 227;
    X_CODESC215  NUMBER := 215;
    X_CODESC220  NUMBER := 220;
    X_CODESC238  NUMBER := 238;
    X_CODESC219  NUMBER := 219;
    X_CODESC223  NUMBER := 223;
    X_CODESC338  NUMBER := 338;
    X_CODESC340  NUMBER := 340;
    X_CODESC211  NUMBER := 211;
    X_CODESC342  NUMBER := 342;
    X_CODESC344  NUMBER := 344;
    X_CODESC210  NUMBER := 210;
    X_CODESC348  NUMBER := 348;
    X_CODESC350  NUMBER := 350;
    X_FEMISIO    DATE;
    X_FEFECTO    DATE;
    X_VIGFUT     NUMBER := 0;
    X_CORRETAJE  NUMBER;
    X_TIPAGENTE  NUMBER;
    X_EVENTO     VARCHAR2(50) := 'PRODUCCION';
    X_ESTADO_OLD NUMBER := 1;
    X_ESTADO_NEW NUMBER := 2;
    X_VIGENCIA VARCHAR2(2);

  BEGIN
  
    IF X_CTIPREC = 9522 THEN
      
      /*VALIDACION DE VIGENCIA FUTURA Y ACTUAL*/ 
      X_VIGFUT := PAC_CONTA_SAP.F_TIPOVIGENCIA(X_RECIBO,X_SSEGURO,X_CPOLCIA,NULL);

      IF X_VIGFUT = 0 THEN
        --VA
      
        IF X_CTIPCOA = 0 THEN
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC242,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        ELSE
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC238,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
        END IF;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC246,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              --ESCENARIO CAUSA GASTO PARA POLIZA MIGRADA VF
              X_VIGENCIA := PAC_CONTA_SAP.F_CAUSAGASTO(X_RECIBO,X_SSEGURO);
              IF X_VIGENCIA = 'SI' THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC211,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
               COMMIT;
               END IF;
              /*IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                 INSERT INTO MOVCONTASAP
                   (NRECIBO,
                    CAGENTE,
                    NMOVIMI,
                    SSEGURO,
                    RAMO,
                    CTIPCOA,
                    CTIPREC,
                    CODESCENARIO,
                    ESTADO,
                    EVENTO,
                    FECHA_SOLICITUD)
                 VALUES
                   (X_RECIBO,
                    AGEN.CAGENTE,
                    X_NMOVIMI,
                    X_SSEGURO,
                    X_RAMO,
                    X_CTIPCOA,
                    X_CTIPREC,
                    X_CODESC219,
                    X_ESTADO_NEW,
                    X_EVENTO,
                    SYSDATE);
                 COMMIT;
               END LOOP;
                 END IF;*/
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC235,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              --ESCENARIO CAUSA GASTO PARA POLIZA MIGRADA VF
              X_VIGENCIA := PAC_CONTA_SAP.F_CAUSAGASTO(X_RECIBO,X_SSEGURO);
              IF X_VIGENCIA = 'SI' THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC211,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
               COMMIT;
               END IF;
            END IF;
          END LOOP;
          IF X_CTIPCOA in (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC219,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC246,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /*IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC219,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC235,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /*IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC219,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          END IF;
        END IF;
      
        /*        IF X_CTIPCOA in (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPANI,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC219,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;*/
      ELSE
        IF X_CTIPCOA = 0 THEN
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC338,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        ELSE
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC348,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
        END IF;
      
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC340,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        /*INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD
           )
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC211,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);*/
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC246,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC211,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              /* IF X_CTIPCOA in (1, 2) THEN
                FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                  INSERT INTO MOVCONTASAP
                    (NRECIBO,
                     CAGENTE,
                     NMOVIMI,
                     SSEGURO,
                     RAMO,
                     CTIPCOA,
                     CTIPREC,
                     CODESCENARIO,
                     ESTADO,
                     EVENTO,
                     FECHA_SOLICITUD)
                  VALUES
                    (X_RECIBO,
                     AGEN.CAGENTE,
                     X_NMOVIMI,
                     X_SSEGURO,
                     X_RAMO,
                     X_CTIPCOA,
                     X_CTIPREC,
                     X_CODESC219,
                     X_ESTADO_NEW,
                     X_EVENTO,
                     SYSDATE);
                  COMMIT;
                END LOOP;
              END IF;*/
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC235,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC211,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END IF;
          END LOOP;
          IF X_CTIPCOA in (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC219,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC246,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /*IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC219,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC235,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            IF X_CTIPCOA IN (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC219,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;
          END IF;
        END IF;
      
        /*IF X_CTIPCOA in (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPANI,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC219,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;*/
      END IF;
    END IF;
  
    IF X_CTIPREC = 1521 THEN
      --VALIDACION VIGENCIA FURUTA
     /* SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
        INTO X_FEMISIO, X_FEFECTO
        FROM SEGUROS A
       WHERE SSEGURO = X_SSEGURO;*/
       
    SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM RECIBOS R
     WHERE SSEGURO = X_SSEGURO
       AND NRECIBO = X_RECIBO;

      IF X_FEFECTO > X_FEMISIO THEN
        X_VIGFUT := 1;
      ELSE
        X_VIGFUT := 0;
      END IF;
    
      IF X_VIGFUT = 0 THEN
      
        IF X_CTIPCOA = 0 THEN
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC227,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        ELSE
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC223,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
        END IF;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC215,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              /* IF X_CTIPCOA in (1, 2) THEN
                FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                  INSERT INTO MOVCONTASAP
                    (NRECIBO,
                     CAGENTE,
                     NMOVIMI,
                     SSEGURO,
                     RAMO,
                     CTIPCOA,
                     CTIPREC,
                     CODESCENARIO,
                     ESTADO,
                     EVENTO,
                     FECHA_SOLICITUD)
                  VALUES
                    (X_RECIBO,
                     AGEN.CAGENTE,
                     X_NMOVIMI,
                     X_SSEGURO,
                     X_RAMO,
                     X_CTIPCOA,
                     X_CTIPREC,
                     X_CODESC219,
                     X_ESTADO_NEW,
                     X_EVENTO,
                     SYSDATE);
                  COMMIT;
                END LOOP;
              END IF;*/
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC220,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END IF;
          END LOOP;
          IF X_CTIPCOA in (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC219,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC215,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /* IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC219,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC220,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /* IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC219,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          END IF;
        END IF;
      
        /*IF X_CTIPCOA in (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPANI,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC219,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;*/
      ELSE
        IF X_CTIPCOA = 0 THEN
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC342,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
          COMMIT;
        ELSE
          UPDATE MOVCONTASAP A
             SET A.CODESCENARIO    = X_CODESC350,
                 A.RAMO            = X_RAMO,
                 A.FECHA_SOLICITUD = SYSDATE,
                 A.ESTADO          = X_ESTADO_NEW
           WHERE A.NRECIBO = X_RECIBO
             AND A.CAGENTE = X_CAGENTE
             AND A.NMOVIMI = X_NMOVIMI
             AND A.SSEGURO = X_SSEGURO
             AND A.RAMO = X_VALOR
             AND A.CTIPCOA = X_CTIPCOA
             AND A.ESTADO = X_ESTADO_OLD
             AND A.CODESCENARIO = X_VALOR;
        END IF;
      
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC344,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC210,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC215,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
              /* IF X_CTIPCOA in (1, 2) THEN
                FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                  INSERT INTO MOVCONTASAP
                    (NRECIBO,
                     CAGENTE,
                     NMOVIMI,
                     SSEGURO,
                     RAMO,
                     CTIPCOA,
                     CTIPREC,
                     CODESCENARIO,
                     ESTADO,
                     EVENTO,
                     FECHA_SOLICITUD)
                  VALUES
                    (X_RECIBO,
                     AGEN.CAGENTE,
                     X_NMOVIMI,
                     X_SSEGURO,
                     X_RAMO,
                     X_CTIPCOA,
                     X_CTIPREC,
                     X_CODESC219,
                     X_ESTADO_NEW,
                     X_EVENTO,
                     SYSDATE);
                  COMMIT;
                END LOOP;
              END IF;*/
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC220,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC210,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END IF;
          END LOOP;
          IF X_CTIPCOA in (1, 2) THEN
            FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 COA.CCOMPAN,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC219,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END LOOP;
          END IF;
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC215,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
            /*IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC219,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;*/
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC220,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          
            IF X_CTIPCOA in (1, 2) THEN
              FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
                INSERT INTO MOVCONTASAP
                  (NRECIBO,
                   CAGENTE,
                   NMOVIMI,
                   SSEGURO,
                   RAMO,
                   CTIPCOA,
                   CTIPREC,
                   CODESCENARIO,
                   ESTADO,
                   EVENTO,
                   FECHA_SOLICITUD)
                VALUES
                  (X_RECIBO,
                   X_CAGENTE,
                   X_NMOVIMI,
                   X_SSEGURO,
                   X_RAMO,
                   X_CTIPCOA,
                   X_CTIPREC,
                   X_CODESC219,
                   X_ESTADO_NEW,
                   X_EVENTO,
                   SYSDATE);
                COMMIT;
              END LOOP;
            END IF;
          END IF;
        END IF;
      
        /*IF X_CTIPCOA in (1, 2) THEN
          FOR COA IN C_COMPA_COASE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               COA.CCOMPANI,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC219,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        END IF;*/
      END IF;
    END IF;
  END ANULA_DIRECTAS_SUPLEMENOS;

  PROCEDURE CANCELA_DIRECTAS(X_RECIBO  NUMBER,
                             X_CAGENTE NUMBER,
                             X_NMOVIMI NUMBER,
                             X_SSEGURO NUMBER,
                             X_RAMO    NUMBER,
                             X_CTIPCOA NUMBER,
                             X_CTIPREC VARCHAR2) IS
  
    CURSOR C_AGE_CORRETAJE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CAGENTE
        FROM RECIBOS R, AGE_CORRETAJE AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND AC.NMOVIMI = R.NMOVIMI
         AND R.NRECIBO = C_NRECIBO;
  
    CURSOR C_COMPA_COASE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CCOMPAN
        FROM RECIBOS R, COACEDIDO AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND R.NRECIBO = C_NRECIBO;
  
    X_VALOR     NUMBER := 0;
    X_CODESC216 NUMBER := 216;
    X_CODESC217 NUMBER := 217;
    X_CODESC202 NUMBER := 202;
    X_CODESC203 NUMBER := 203;
    X_CODESC204 NUMBER := 204;
    X_CODESC205 NUMBER := 205;
  
    X_FEMISIO    DATE;
    X_FEFECTO    DATE;
    X_VIGFUT     NUMBER := 0;
    X_CORRETAJE  NUMBER;
    X_TIPAGENTE  NUMBER;
    X_EVENTO     VARCHAR2(50) := 'PRODUCCION';
    X_ESTADO_OLD NUMBER := 1;
    X_ESTADO_NEW NUMBER := 2;
    --X_ESTADO_RECAUDO NUMBER := 0;
    --X_CON_RECAUDO    VARCHAR2(5) := 'NO';        
  
  BEGIN
  
    --VALIDACION VIGENCIA FURUTA
    SELECT TRUNC(NVL(FEMISIO, FMOVIMI)), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM MOVSEGURO M
     WHERE M.SSEGURO = X_SSEGURO
       AND M.CMOTMOV = 321;
  
    IF X_FEFECTO > X_FEMISIO THEN
      X_VIGFUT := 1;
    ELSE
      X_VIGFUT := 0;
    END IF;
  
    IF X_VIGFUT = 0 THEN
    
      /* X_ESTADO_RECAUDO := F_ESTREC(X_RECIBO);
      IF X_ESTADO_RECAUDO = 3 THEN
        IF (PAC_ADM_COBPARCIAL.F_GET_IMPORTE_COBRO_PARCIAL(X_RECIBO) > 0) THEN
          X_CON_RECAUDO := 'SI';
        ELSE
          X_CON_RECAUDO := 'NO';
        END IF;
      ELSIF X_ESTADO_RECAUDO = 1 THEN
        X_CON_RECAUDO := 'SI';
      END IF;*/
    
      IF X_CTIPREC = '9531' THEN
        -- SIN RECAUDO
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC217,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC216,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC203,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC202,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END IF;
          END LOOP;
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC203,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC202,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END IF;
        END IF;
      ELSE
        -- CON RECAUDO
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC204,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC205,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            SELECT CTIPAGE
              INTO X_TIPAGENTE
              FROM AGENTES
             WHERE CAGENTE = AGEN.CAGENTE;
          
            IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC203,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            ELSIF X_TIPAGENTE = 4 THEN
              INSERT INTO MOVCONTASAP
                (NRECIBO,
                 CAGENTE,
                 NMOVIMI,
                 SSEGURO,
                 RAMO,
                 CTIPCOA,
                 CTIPREC,
                 CODESCENARIO,
                 ESTADO,
                 EVENTO,
                 FECHA_SOLICITUD)
              VALUES
                (X_RECIBO,
                 AGEN.CAGENTE,
                 X_NMOVIMI,
                 X_SSEGURO,
                 X_RAMO,
                 X_CTIPCOA,
                 X_CTIPREC,
                 X_CODESC202,
                 X_ESTADO_NEW,
                 X_EVENTO,
                 SYSDATE);
              COMMIT;
            END IF;
          END LOOP;
        ELSE
          SELECT CTIPAGE
            INTO X_TIPAGENTE
            FROM AGENTES
           WHERE CAGENTE = X_CAGENTE;
        
          IF X_TIPAGENTE IN (3, 5, 6, 7) THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC203,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          ELSIF X_TIPAGENTE = 4 THEN
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               X_CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC202,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END IF;
        END IF;
      END IF;
    END IF; -- VA
  END CANCELA_DIRECTAS;

  PROCEDURE COA_ACEPTADO_SUPLEMENOS(X_RECIBO  NUMBER,
                                    X_CAGENTE NUMBER,
                                    X_NMOVIMI NUMBER,
                                    X_SSEGURO NUMBER,
                                    X_RAMO    NUMBER,
                                    X_CTIPCOA NUMBER,
                                    X_CTIPREC VARCHAR2) IS
  
    CURSOR C_AGE_CORRETAJE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CAGENTE
        FROM RECIBOS R, AGE_CORRETAJE AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND AC.NMOVIMI = R.NMOVIMI
         AND R.NRECIBO = C_NRECIBO;
  
    X_VALOR      NUMBER := 0;
    X_CODESC254  NUMBER := 254;
    X_CODESC252  NUMBER := 252;
    X_CODESC265  NUMBER := 265;
    X_CODESC352  NUMBER := 352;
    X_CODESC354  NUMBER := 354;
    X_FEMISIO    DATE;
    X_FEFECTO    DATE;
    X_VIGFUT     NUMBER := 0;
    X_CORRETAJE  NUMBER;
    X_EVENTO     VARCHAR2(50) := 'PRODUCCION';
    X_ESTADO_OLD NUMBER := 1;
    X_ESTADO_NEW NUMBER := 2;
  
  BEGIN
  
    --VALIDACION VIGENCIA FURUTA
    /*SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM SEGUROS A
     WHERE SSEGURO = X_SSEGURO;*/
     
    SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM RECIBOS R
     WHERE SSEGURO = X_SSEGURO
       AND NRECIBO = X_RECIBO;

    IF X_FEFECTO > X_FEMISIO THEN
      X_VIGFUT := 1;
    ELSE
      X_VIGFUT := 0;
    END IF;
  
    IF X_VIGFUT = 0 THEN
    
      UPDATE MOVCONTASAP A
         SET A.CODESCENARIO    = X_CODESC254,
             A.RAMO            = X_RAMO,
             A.FECHA_SOLICITUD = SYSDATE,
             A.ESTADO          = X_ESTADO_NEW
       WHERE A.NRECIBO = X_RECIBO
         AND A.CAGENTE = X_CAGENTE
         AND A.NMOVIMI = X_NMOVIMI
         AND A.SSEGURO = X_SSEGURO
         AND A.RAMO = X_VALOR
         AND A.CTIPCOA = X_CTIPCOA
         AND A.ESTADO = X_ESTADO_OLD
         AND A.CODESCENARIO = X_VALOR;
      COMMIT;
    
      --VALIDA INTERMEDIACION
      X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
      IF X_CORRETAJE <> 0 THEN
        FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             AGEN.CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC252,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END LOOP;
      ELSE
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC252,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      END IF;
    ELSE
      UPDATE MOVCONTASAP A
         SET A.CODESCENARIO    = X_CODESC352,
             A.RAMO            = X_RAMO,
             A.FECHA_SOLICITUD = SYSDATE,
             A.ESTADO          = X_ESTADO_NEW
       WHERE A.NRECIBO = X_RECIBO
         AND A.CAGENTE = X_CAGENTE
         AND A.NMOVIMI = X_NMOVIMI
         AND A.SSEGURO = X_SSEGURO
         AND A.RAMO = X_VALOR
         AND A.CTIPCOA = X_CTIPCOA
         AND A.ESTADO = X_ESTADO_OLD
         AND A.CODESCENARIO = X_VALOR;
      COMMIT;
    
      INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         RAMO,
         CTIPCOA,
         CTIPREC,
         CODESCENARIO,
         ESTADO,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (X_RECIBO,
         X_CAGENTE,
         X_NMOVIMI,
         X_SSEGURO,
         X_RAMO,
         X_CTIPCOA,
         X_CTIPREC,
         X_CODESC354,
         X_ESTADO_NEW,
         X_EVENTO,
         SYSDATE);
      INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         RAMO,
         CTIPCOA,
         CTIPREC,
         CODESCENARIO,
         ESTADO,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (X_RECIBO,
         X_CAGENTE,
         X_NMOVIMI,
         X_SSEGURO,
         X_RAMO,
         X_CTIPCOA,
         X_CTIPREC,
         X_CODESC265,
         X_ESTADO_NEW,
         X_EVENTO,
         SYSDATE);
      COMMIT;
    
      --VALIDA INTERMEDIACION
      X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
      IF X_CORRETAJE <> 0 THEN
        FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             AGEN.CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC252,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END LOOP;
      ELSE
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC252,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      END IF;
    END IF;
  END COA_ACEPTADO_SUPLEMENOS;

  PROCEDURE ANULA_COA_ACEPTADO_SUPLEMAS(X_RECIBO  NUMBER,
                                        X_CAGENTE NUMBER,
                                        X_NMOVIMI NUMBER,
                                        X_SSEGURO NUMBER,
                                        X_RAMO    NUMBER,
                                        X_CPOLCIA VARCHAR2,
                                        X_CTIPCOA NUMBER,
                                        X_CTIPREC VARCHAR2) IS
  
    CURSOR C_AGE_CORRETAJE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CAGENTE
        FROM RECIBOS R, AGE_CORRETAJE AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND AC.NMOVIMI = R.NMOVIMI
         AND R.NRECIBO = C_NRECIBO;
  
    X_VALOR     NUMBER := 0;
    X_CODESC247 NUMBER := 247;
    X_CODESC241 NUMBER := 241;
    --X_CODESC266 NUMBER := 266;
    X_CODESC213  NUMBER := 213;
    X_CODESC212  NUMBER := 212;
    X_CODESC359  NUMBER := 359;
    X_CODESC361  NUMBER := 361;
    X_CODESC209  NUMBER := 209;
    X_CODESC355  NUMBER := 355;
    X_CODESC357  NUMBER := 357;
    X_CODESC207  NUMBER := 207;
    X_FEMISIO    DATE;
    X_FEFECTO    DATE;
    X_VIGFUT     NUMBER := 0;
    X_CORRETAJE  NUMBER;
    X_EVENTO     VARCHAR2(50) := 'PRODUCCION';
    X_ESTADO_OLD NUMBER := 1;
    X_ESTADO_NEW NUMBER := 2;
    X_VIGENCIA   VARCHAR2(2);

  BEGIN
  
    IF X_CTIPREC IN (1522, 9032) THEN
      
      /*VALIDACION DE VIGENCIA FUTURA Y ACTUAL*/ 
      X_VIGFUT := PAC_CONTA_SAP.F_TIPOVIGENCIA(X_RECIBO,X_SSEGURO,X_CPOLCIA,NULL);

      IF X_VIGFUT = 0 THEN
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC247,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
        --ESCENARIO CAUSA GASTO PARA POLIZA MIGRADA VF
        X_VIGENCIA := PAC_CONTA_SAP.F_CAUSAGASTO(X_RECIBO,X_SSEGURO); 
        IF X_VIGENCIA = 'SI' THEN
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC209,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
         END IF;
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC241,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        ELSE
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC241,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END IF; --FIN VA
      ELSE 
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC359,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC361,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC209,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC241,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        ELSE
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC241,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END IF;
      END IF;
    END IF;
  
    IF X_CTIPREC IN (9521, 9031) THEN
      --VALIDACION VIGENCIA FURUTA
      /*SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
        INTO X_FEMISIO, X_FEFECTO
        FROM SEGUROS A
       WHERE SSEGURO = X_SSEGURO;*/
       
    SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM RECIBOS R
     WHERE SSEGURO = X_SSEGURO
       AND NRECIBO = X_RECIBO;

      IF X_FEFECTO > X_FEMISIO THEN
        X_VIGFUT := 1;
      ELSE
        X_VIGFUT := 0;
      END IF;

      IF X_VIGFUT = 0 THEN
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC213,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;

        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC212,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        ELSE
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC212,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END IF;
      ELSE
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC355,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;

        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC357,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC207,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;

        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC212,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        ELSE
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC212,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END IF;
      END IF;
    END IF;

  END ANULA_COA_ACEPTADO_SUPLEMAS;

  PROCEDURE ANULA_COA_ACEPTADO_SUPLEMENOS(X_RECIBO  NUMBER,
                                          X_CAGENTE NUMBER,
                                          X_NMOVIMI NUMBER,
                                          X_SSEGURO NUMBER,
                                          X_RAMO    NUMBER,
                                          X_CPOLCIA VARCHAR2,
                                          X_CTIPCOA NUMBER,
                                          X_CTIPREC VARCHAR2) IS
  
    CURSOR C_AGE_CORRETAJE(C_NRECIBO NUMBER) IS
      SELECT DISTINCT AC.CAGENTE
        FROM RECIBOS R, AGE_CORRETAJE AC
       WHERE AC.SSEGURO = R.SSEGURO
         AND AC.NMOVIMI = R.NMOVIMI
         AND R.NRECIBO = C_NRECIBO;
  
    X_VALOR     NUMBER := 0;
    X_CODESC237 NUMBER := 237;
    X_CODESC236 NUMBER := 236;
    --X_CODESC265 NUMBER := 265;
    X_CODESC222  NUMBER := 222;
    X_CODESC226  NUMBER := 226;
    X_CODESC360  NUMBER := 360;
    X_CODESC362  NUMBER := 362;
    X_CODESC208  NUMBER := 208;
    X_CODESC356  NUMBER := 356;
    X_CODESC358  NUMBER := 358;
    X_CODESC206  NUMBER := 206;
    X_FEMISIO    DATE;
    X_FEFECTO    DATE;
    X_VIGFUT     NUMBER := 0;
    X_CORRETAJE  NUMBER;
    X_EVENTO     VARCHAR2(50) := 'PRODUCCION';
    X_ESTADO_OLD NUMBER := 1;
    X_ESTADO_NEW NUMBER := 2;
    X_VIGENCIA   VARCHAR2(2);

  BEGIN
  
    IF X_CTIPREC = 9522 THEN

     /*VALIDACION DE VIGENCIA FUTURA Y ACTUAL*/ 
      X_VIGFUT := PAC_CONTA_SAP.F_TIPOVIGENCIA(X_RECIBO,X_SSEGURO,X_CPOLCIA,NULL);

      IF X_VIGFUT = 0 THEN
      
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC237,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
       --ESCENARIO CAUSA GASTO PARA POLIZA MIGRADA VF
        X_VIGENCIA := PAC_CONTA_SAP.F_CAUSAGASTO(X_RECIBO,X_SSEGURO); 
        IF X_VIGENCIA = 'SI' THEN
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC208,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
          COMMIT;
         END IF;
         
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC236,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        ELSE
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC236,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END IF;
      ELSE
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC360,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC362,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC208,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC236,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        ELSE
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC236,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END IF;
      END IF;
    END IF;
  
    IF X_CTIPREC = 1521 THEN
    
      --VALIDACION VIGENCIA FURUTA
      /*SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
        INTO X_FEMISIO, X_FEFECTO
        FROM SEGUROS A
       WHERE SSEGURO = X_SSEGURO;*/
       
    SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
      INTO X_FEMISIO, X_FEFECTO
      FROM RECIBOS R
     WHERE SSEGURO = X_SSEGURO
       AND NRECIBO = X_RECIBO;

      IF X_FEFECTO > X_FEMISIO THEN
        X_VIGFUT := 1;
      ELSE
        X_VIGFUT := 0;
      END IF;
    
      IF X_VIGFUT = 0 THEN
      
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC222,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC226,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        ELSE
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC226,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END IF;
      ELSE
        UPDATE MOVCONTASAP A
           SET A.CODESCENARIO    = X_CODESC356,
               A.RAMO            = X_RAMO,
               A.FECHA_SOLICITUD = SYSDATE,
               A.ESTADO          = X_ESTADO_NEW
         WHERE A.NRECIBO = X_RECIBO
           AND A.CAGENTE = X_CAGENTE
           AND A.NMOVIMI = X_NMOVIMI
           AND A.SSEGURO = X_SSEGURO
           AND A.RAMO = X_VALOR
           AND A.CTIPCOA = X_CTIPCOA
           AND A.ESTADO = X_ESTADO_OLD
           AND A.CODESCENARIO = X_VALOR;
        COMMIT;
      
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC358,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           RAMO,
           CTIPCOA,
           CTIPREC,
           CODESCENARIO,
           ESTADO,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (X_RECIBO,
           X_CAGENTE,
           X_NMOVIMI,
           X_SSEGURO,
           X_RAMO,
           X_CTIPCOA,
           X_CTIPREC,
           X_CODESC206,
           X_ESTADO_NEW,
           X_EVENTO,
           SYSDATE);
        COMMIT;
      
        --VALIDA INTERMEDIACION
        X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(X_RECIBO);
        IF X_CORRETAJE <> 0 THEN
          FOR AGEN IN C_AGE_CORRETAJE(X_RECIBO) LOOP
            INSERT INTO MOVCONTASAP
              (NRECIBO,
               CAGENTE,
               NMOVIMI,
               SSEGURO,
               RAMO,
               CTIPCOA,
               CTIPREC,
               CODESCENARIO,
               ESTADO,
               EVENTO,
               FECHA_SOLICITUD)
            VALUES
              (X_RECIBO,
               AGEN.CAGENTE,
               X_NMOVIMI,
               X_SSEGURO,
               X_RAMO,
               X_CTIPCOA,
               X_CTIPREC,
               X_CODESC226,
               X_ESTADO_NEW,
               X_EVENTO,
               SYSDATE);
            COMMIT;
          END LOOP;
        ELSE
          INSERT INTO MOVCONTASAP
            (NRECIBO,
             CAGENTE,
             NMOVIMI,
             SSEGURO,
             RAMO,
             CTIPCOA,
             CTIPREC,
             CODESCENARIO,
             ESTADO,
             EVENTO,
             FECHA_SOLICITUD)
          VALUES
            (X_RECIBO,
             X_CAGENTE,
             X_NMOVIMI,
             X_SSEGURO,
             X_RAMO,
             X_CTIPCOA,
             X_CTIPREC,
             X_CODESC226,
             X_ESTADO_NEW,
             X_EVENTO,
             SYSDATE);
          COMMIT;
        END IF;
      END IF;
    END IF;
  
  END ANULA_COA_ACEPTADO_SUPLEMENOS;

  PROCEDURE GENERA_INFO_CUENTAS IS
  
    CURSOR MOV_CONTA(P_EVENTO   VARCHAR2,
                     P_ESTADO_I NUMBER,
                     P_ESTADO_P NUMBER) IS
      SELECT A.NRECIBO,
             A.CAGENTE,
             A.NMOVIMI,
             A.SSEGURO,
             A.RAMO,
             A.CTIPCOA,
             A.CTIPREC,
             A.CODESCENARIO,
             A.SINTERF,
             A.NUM_INTENTO,
             A.ESTADO
        FROM MOVCONTASAP A
       WHERE A.ESTADO IN (P_ESTADO_I, P_ESTADO_P)
         AND A.EVENTO = P_EVENTO
       ORDER BY A.NRECIBO, A.CODESCENARIO DESC;
  
    CURSOR COACEDIDO(P_SSEGURO NUMBER, P_NCUACOA NUMBER) IS
      SELECT C.CCOMPAN
        FROM COACEDIDO C
       WHERE C.SSEGURO = P_SSEGURO
         AND C.NCUACOA = P_NCUACOA;
  
    CURSOR ESCENARIOS(P_ESCENARIO NUMBER, P_RAMO NUMBER) IS
      SELECT A.CODCUENTA, A.PRODUCTO
        FROM ESCENARIOSAP A
       WHERE A.CODESCENARIO = P_ESCENARIO
         AND A.PRODUCTO IN (0, 1, P_RAMO)
       ORDER BY A.CODCUENTA;
  
    CURSOR ESCENARIOSVF(P_ESCENARIO NUMBER, P_RAMO NUMBER) IS
      SELECT A.CODCUENTA, A.PRODUCTO
        FROM ESCENARIOSAPVF A
       WHERE A.CODESCENARIO = P_ESCENARIO
         AND A.PRODUCTO IN (0, 1, P_RAMO)
       ORDER BY A.CODCUENTA;
  
    X_EVENTO VARCHAR2(50) := 'PRODUCCION';
    --VTSELEC        VARCHAR2(32000);
    VCOLETILLA     VARCHAR2(100);
    VDESCRI        VARCHAR2(32000);
    IMPORTE        NUMBER;
    VOTROS         VARCHAR2(4000);
    VFADM          DATE;
    X_CUENTA       VARCHAR2(20);
    X_LINEA        NUMBER;
    X_VALOR        NUMBER := 1;
    VSINTERF       NUMBER;
    X_TIPPAG       NUMBER;
    X_ENLACE       NUMBER;
    X_LIBRO        VARCHAR2(20);
    X_TAPUNTE      VARCHAR2(20);
    X_GENERA       NUMBER := 0;
    X_IMPORTE      NUMBER := 0;
    V_VALIDA_ENVIO NUMBER := 0;
    X_PROCEDE      NUMBER := 0;
    /* CAMBIOS DE SWAPNIL : STARTS  */
    VLINEAINI   VARCHAR2(500);
    VRESULTADO  NUMBER(10);
    VINTERFICIE VARCHAR2(100);
    VEMPRESA    NUMBER := 24;
    VTERMINAL   VARCHAR2(100);
    VERROR      NUMBER(10);
    VACCION     NUMBER(10) := 1;
    X_FECDOC    DATE;
    X_FECONTA   DATE;
    X_FEMISIO   DATE;
    X_FEFECTO   DATE;
    X_VIGFUT    NUMBER := 0;
    VTIPPAG     CONTAB_ASIENT_INTERF.TTIPPAG%TYPE;
    VIDPAGO     CONTAB_ASIENT_INTERF.IDPAGO%TYPE;
    VIDMOV      CONTAB_ASIENT_INTERF.IDMOV%TYPE;
    VIDMOVSEQ   NUMBER;
    VRESULT     SYS_REFCURSOR;
  
    X_ESTADO_I NUMBER := 2;
    X_ESTADO_P NUMBER := 3;
    X_ESTADO_T NUMBER := 4;
  
    VNOMBREARCHIVO VARCHAR2(500);
    VLOGARCHIVO    UTL_FILE.FILE_TYPE;
    VLINEA         VARCHAR2(2000);
    VRUTA          VARCHAR2(200) := 'TABEXT';
  
    VSERVICIOESTADO SERVICIO_LOGS.ESTADO%TYPE := 2;
    VESTADOMOV      MOVCONTASAP.ESTADO%TYPE := 0;
  
    VCOUNTIMPORTE_ZERO NUMBER := 0;
    VCOUNTCUENTA       NUMBER := 0;
    VCOUNTERROR        NUMBER := 0;
  
    VCOUNTIM        NUMBER := 0;
    VCOUNTSL        NUMBER := 0;
    VCOUNTSL_ESTADO NUMBER := 2;
    VEXECUTAR       VARCHAR2(2) := 'NO';
    /* CAMBIOS DE SWAPNIL : ENDS  */
  
  BEGIN
    /*
     IN ESTADO COLUMN
      2 --Inicio     -- WHEN CUSRSOR TAKE RECORDS FOR GENERATE CUENTAS
      3 --Procesando -- WHEN GENERA_INFO_CUENTAS PRCEDURE STARTS PROCESSING
      4 --Generaron  -- WHEN GENERA_INFO_CUENTAS PRCEDURE FINISH PROCESSING
      5 --Error      -- WHEN GENERA_INFO_CUENTAS PRCEDURE FINISH WITH 3 RETRY
    */
  
    VNOMBREARCHIVO := 'CONTABLE_ERROR_' ||
                      TO_CHAR(F_SYSDATE, 'yyyymmdd_hh24miss') || '.txt';
    VLOGARCHIVO    := UTL_FILE.FOPEN(VRUTA, VNOMBREARCHIVO, 'w');
    VLINEA         := 'NRECIBO|CAGENTE|SSEGURO|CODESCENARIO|CUENTA|TIPPAG';
    UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
  
    FOR MOV IN MOV_CONTA(X_EVENTO, X_ESTADO_I, X_ESTADO_P) LOOP
      VSERVICIOESTADO := 2;
    
      /* set retry variable for first attempt */
      IF MOV.NUM_INTENTO IS NULL THEN
        UPDATE MOVCONTASAP M
           SET M.NUM_INTENTO = 1
         WHERE M.CAGENTE = MOV.CAGENTE
           AND M.CODESCENARIO = MOV.CODESCENARIO
           AND M.NRECIBO = MOV.NRECIBO
           AND M.CTIPREC = MOV.CTIPREC;
        COMMIT;
      END IF;
    
      /* Checking eligibility of ESTADO 3 before retry */
      IF MOV.SINTERF IS NOT NULL AND MOV.ESTADO = X_ESTADO_P THEN
        SELECT COUNT(*)
          INTO VCOUNTIM
          FROM INT_MENSAJES IM
         WHERE IM.SINTERF = MOV.SINTERF;
      
        SELECT COUNT(*)
          INTO VCOUNTSL
          FROM SERVICIO_LOGS SL
         WHERE SL.SINTERF = MOV.SINTERF;
      
        IF VCOUNTIM > 0 AND VCOUNTSL > 0 THEN
          BEGIN
            SELECT SL.ESTADO
              INTO VCOUNTSL_ESTADO
              FROM SERVICIO_LOGS SL
             WHERE SL.SINTERF = MOV.SINTERF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VCOUNTSL_ESTADO := X_ESTADO_I;
          END;
          IF VCOUNTSL_ESTADO = X_ESTADO_I THEN
            VEXECUTAR := 'SI';
            DELETE CONTAB_ASIENT_INTERF CAI
             WHERE CAI.IDPAGO = MOV.NRECIBO
               AND CAI.SINTERF = MOV.SINTERF;
            COMMIT;
          ELSE
            VEXECUTAR := 'NO';
			
			UPDATE MOVCONTASAP M
               SET M.ESTADO = X_ESTADO_T
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.CODESCENARIO = MOV.CODESCENARIO
               AND M.NRECIBO = MOV.NRECIBO
               AND M.CTIPREC = MOV.CTIPREC;
            COMMIT;
		 END IF;
        ELSE
            VEXECUTAR := 'SI';
        END IF;
		
		
      ELSIF MOV.ESTADO = X_ESTADO_I THEN
            VEXECUTAR := 'SI';
      END IF;
    
      IF VEXECUTAR = 'SI' THEN
        /* Change status once start processing 3*/
        UPDATE MOVCONTASAP M
           SET M.ESTADO = X_ESTADO_P, M.SINTERF = ''
         WHERE M.CAGENTE = MOV.CAGENTE
           AND M.CODESCENARIO = MOV.CODESCENARIO
           AND M.NRECIBO = MOV.NRECIBO
           AND M.CTIPREC = MOV.CTIPREC;
        COMMIT;
      
        PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
        VSINTERF       := PAC_INT_ONLINE.F_OBTENER_SINTERF;
        V_VALIDA_ENVIO := 0;
          
        /*VALIDACION DE VIGENCIA FUTURA Y ACTUAL*/ 
        X_VIGFUT := PAC_CONTA_SAP.F_TIPOVIGENCIA(MOV.NRECIBO,MOV.SSEGURO,PAC_CONTAB_CONF.F_ZZFIPOLIZA(MOV.SSEGURO),MOV.CODESCENARIO);
        
        SELECT SMOVREC.NEXTVAL INTO VIDMOVSEQ FROM DUAL;
      
        IF X_VIGFUT = 0 THEN
          VCOUNTCUENTA       := 0;
          VCOUNTIMPORTE_ZERO := 0;
          FOR ESC IN ESCENARIOS(MOV.CODESCENARIO, MOV.RAMO) LOOP
            VCOUNTCUENTA := VCOUNTCUENTA + 1;
            X_GENERA     := 0;
            X_IMPORTE    := 0;
            X_PROCEDE    := 0;
          
            IF (ESC.PRODUCTO = 0 OR ESC.PRODUCTO = MOV.RAMO) THEN
              SELECT A.CCUENTA, A.LINEA
                INTO X_CUENTA, X_LINEA
                FROM CUENTASSAP A
               WHERE A.CODCUENTA = ESC.CODCUENTA;
              X_GENERA := 1;
              IF X_CUENTA IN (1630400100) THEN
                IF MOV.CTIPCOA IN (0, 8, 9) THEN
                  X_GENERA := 0;
                END IF;
              END IF;
            ELSIF ESC.PRODUCTO = 1 THEN
              SELECT A.CCUENTA, A.LINEA
                INTO X_CUENTA, X_LINEA
                FROM CUENTASSAP A
               WHERE A.CODCUENTA = ESC.CODCUENTA;
              X_GENERA := 1;
              IF X_CUENTA IN (1684050200, 1684050300, 4195950190) THEN
                IF MOV.CTIPCOA IN (8, 9) THEN
                  X_GENERA := 0;
                END IF;
              END IF;
            END IF;
          
            IF X_GENERA = 1 THEN
              BEGIN
                SELECT C.TTIPPAG, C.TCUENTA, C.CLAENLACE, C.TLIBRO
                  INTO X_TIPPAG, X_TAPUNTE, X_ENLACE, X_LIBRO
                  FROM CUENTASSAP C
                 WHERE C.CCUENTA = X_CUENTA;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  X_PROCEDE := 1;
              END;
            
              IF X_PROCEDE = 0 THEN
                IF ESC.CODCUENTA IN (6, 12) AND MOV.CTIPCOA IN (1, 2) THEN
                  FOR COD IN COACEDIDO(MOV.SSEGURO, MOV.NMOVIMI) LOOP
                    BEGIN
                      GENERARTRAMA_COD(PI_RECIBO   => MOV.NRECIBO,
                                       PI_AGENTE   => MOV.CAGENTE,
                                       PI_SCENARIO => MOV.CODESCENARIO,
                                       PI_CUENTA   => X_CUENTA,
                                       PI_TIPPAG   => X_TIPPAG,
                                       PI_COMPAN   => COD.CCOMPAN,
                                       PO_RESULT   => VRESULT);
                      LOOP
                        FETCH VRESULT
                          INTO VCOLETILLA, VDESCRI, IMPORTE, VOTROS, VFADM;
                        EXIT WHEN VRESULT%NOTFOUND;
                      END LOOP;
                      CLOSE VRESULT;
                    EXCEPTION
                      WHEN OTHERS THEN
                        VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                                       MOV.SSEGURO || '|' ||
                                       MOV.CODESCENARIO || '|' || X_CUENTA || '|' ||
                                       X_TIPPAG;
                        VCOUNTERROR := VCOUNTERROR + 1;
                        P_TAB_ERROR(F_SYSDATE,
                                    F_USER,
                                    'GENERA_INFO_CUENTAS :VA:TRAMA_COD: I031',
                                    X_TIPPAG,
                                    'VSINTERF:' || VSINTERF,
                                    'VLINEA :' || VLINEA || ':' ||
                                    ':SQLERRM:' || SQLERRM);
                        UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                        CONTINUE;
                    END;
                  
                    IF IMPORTE <> 0 THEN
                      IF MOV.CTIPREC NOT IN (9531,9532,1522,9522,9032) THEN
                        
                       SELECT TRUNC(FEMISIO)
                          INTO X_FECONTA
                          FROM RECIBOS
                         WHERE NRECIBO = MOV.NRECIBO;
                      
                        SELECT TRUNC(MAX(FMOVDIA))
                          INTO X_FECDOC
                          FROM MOVRECIBO
                         WHERE NRECIBO = MOV.NRECIBO;
                      ELSE
                        SELECT TRUNC(MAX(FMOVDIA))
                          INTO X_FECONTA
                          FROM MOVRECIBO
                         WHERE NRECIBO = MOV.NRECIBO;
                      
                        SELECT TRUNC(MAX(FMOVDIA))
                          INTO X_FECDOC
                          FROM MOVRECIBO
                         WHERE NRECIBO = MOV.NRECIBO;
                      END IF;
                    
                      INSERT INTO CONTAB_ASIENT_INTERF
                        (SINTERF,
                         TTIPPAG,
                         IDPAGO,
                         FCONTA,
                         NASIENT,
                         NLINEA,
                         CCUENTA,
                         CCOLETILLA,
                         TAPUNTE,
                         IAPUNTE,
                         TDESCRI,
                         FEFEADM,
                         CENLACE,
                         TLIBRO,
                         OTROS,
                         IDMOV)
                      VALUES
                        (VSINTERF,
                         X_TIPPAG,
                         MOV.NRECIBO,
                         X_FECDOC,
                         X_VALOR,
                         X_LINEA,
                         SUBSTR(X_CUENTA, 1, 6),
                         SUBSTR(X_CUENTA, 7, 4),
                         X_TAPUNTE,
                         IMPORTE,
                         VDESCRI,
                         X_FECONTA,
                         X_ENLACE,
                         X_LIBRO,
                         VOTROS,
                         VIDMOVSEQ);
                    
                      UPDATE MOVCONTASAP M
                         SET M.SINTERF = VSINTERF
                       WHERE M.CAGENTE = MOV.CAGENTE
                         AND M.CODESCENARIO = MOV.CODESCENARIO
                         AND M.CTIPREC = MOV.CTIPREC
                         AND M.NRECIBO = MOV.NRECIBO;
                      COMMIT;
                      V_VALIDA_ENVIO := 1;
                    END IF;
                  END LOOP;
                ELSE
                  BEGIN
                    GENERARTRAMA(PI_RECIBO   => MOV.NRECIBO,
                                 PI_AGENTE   => MOV.CAGENTE,
                                 PI_SCENARIO => MOV.CODESCENARIO,
                                 PI_CUENTA   => X_CUENTA,
                                 PI_TIPPAG   => X_TIPPAG,
                                 PO_RESULT   => VRESULT);
                  
                    LOOP
                      FETCH VRESULT
                        INTO VCOLETILLA, VDESCRI, IMPORTE, VOTROS, VFADM;
                      EXIT WHEN VRESULT%NOTFOUND;
                    END LOOP;
                    CLOSE VRESULT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                                     MOV.SSEGURO || '|' || MOV.CODESCENARIO || '|' ||
                                     X_CUENTA || '|' || X_TIPPAG;
                      VCOUNTERROR := VCOUNTERROR + 1;
                      P_TAB_ERROR(F_SYSDATE,
                                  F_USER,
                                  'GENERA_INFO_CUENTAS :VA:TRAMA: I031',
                                  X_TIPPAG,
                                  'VSINTERF : ' || VSINTERF,
                                  'VLINEA :' || VLINEA || ':' ||
                                  ':SQLERRM:' || SQLERRM);
                      UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                      CONTINUE;
                  END;
                
                  IF IMPORTE <> 0 THEN
                    IF MOV.CTIPREC NOT IN (9531,9532,1522,9522,9032) THEN
                      
                       SELECT TRUNC(FEMISIO)
                          INTO X_FECONTA
                          FROM RECIBOS
                         WHERE NRECIBO = MOV.NRECIBO;
                     
                       /* SELECT TRUNC(FEFECTO)
                          INTO X_FECONTA
                          FROM RECIBOS
                         WHERE NRECIBO = MOV.NRECIBO;*/

                        SELECT TRUNC(MAX(FMOVDIA))
                          INTO X_FECDOC
                          FROM MOVRECIBO
                         WHERE NRECIBO = MOV.NRECIBO;
                    ELSE
                      SELECT TRUNC(MAX(FMOVDIA))
                        INTO X_FECONTA
                        FROM MOVRECIBO
                       WHERE NRECIBO = MOV.NRECIBO;
                    
                      SELECT TRUNC(MAX(FMOVDIA))
                        INTO X_FECDOC
                        FROM MOVRECIBO
                       WHERE NRECIBO = MOV.NRECIBO;
                    END IF;
                  
                    INSERT INTO CONTAB_ASIENT_INTERF
                      (SINTERF,
                       TTIPPAG,
                       IDPAGO,
                       FCONTA,
                       NASIENT,
                       NLINEA,
                       CCUENTA,
                       CCOLETILLA,
                       TAPUNTE,
                       IAPUNTE,
                       TDESCRI,
                       FEFEADM,
                       CENLACE,
                       TLIBRO,
                       OTROS,
                       IDMOV)
                    VALUES
                      (VSINTERF,
                       X_TIPPAG,
                       MOV.NRECIBO,
                       X_FECDOC,
                       X_VALOR,
                       X_LINEA,
                       SUBSTR(X_CUENTA, 1, 6),
                       SUBSTR(X_CUENTA, 7, 4),
                       X_TAPUNTE,
                       IMPORTE,
                       VDESCRI,
                       X_FECONTA,
                       X_ENLACE,
                       X_LIBRO,
                       VOTROS,
                       VIDMOVSEQ);
                  
                    UPDATE MOVCONTASAP M
                       SET M.SINTERF = VSINTERF
                     WHERE M.CAGENTE = MOV.CAGENTE
                       AND M.CODESCENARIO = MOV.CODESCENARIO
                       AND M.CTIPREC = MOV.CTIPREC
                       AND M.NRECIBO = MOV.NRECIBO;
                    COMMIT;
                    V_VALIDA_ENVIO := 1;
                  ELSE
                    VCOUNTIMPORTE_ZERO := VCOUNTIMPORTE_ZERO + 1;
                  END IF;
                END IF; -- COD                
              END IF;
            END IF;
          END LOOP;
        
          IF VCOUNTCUENTA = VCOUNTIMPORTE_ZERO THEN
            UPDATE MOVCONTASAP M
               SET M.SINTERF = VSINTERF, M.ESTADO = X_ESTADO_T
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.CODESCENARIO = MOV.CODESCENARIO
               AND M.CTIPREC = MOV.CTIPREC
               AND M.NRECIBO = MOV.NRECIBO;
            COMMIT;
          END IF;
        
          IF V_VALIDA_ENVIO = 1 THEN
            /* CAMBIOS DE SWAPNIL : STARTS  */
            VINTERFICIE := PAC_PARAMETROS.F_PAREMPRESA_T(VEMPRESA,
                                                         'INTERFICIE_ERP');
            VERROR      := PAC_USER.F_GET_TERMINAL(F_USER, VTERMINAL);
            BEGIN
              SELECT DISTINCT CAI.TTIPPAG, CAI.IDPAGO, CAI.IDMOV
                INTO VTIPPAG, VIDPAGO, VIDMOV
                FROM CONTAB_ASIENT_INTERF CAI
               WHERE CAI.SINTERF = VSINTERF
                 AND CAI.TTIPPAG = X_TIPPAG;
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                SELECT DISTINCT CAI.TTIPPAG, CAI.IDPAGO, CAI.IDMOV
                  INTO VTIPPAG, VIDPAGO, VIDMOV
                  FROM CONTAB_ASIENT_INTERF CAI
                 WHERE CAI.SINTERF = VSINTERF
                   AND ROWNUM = 1;
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'TESTING:DUP_VAL_ON_INDEX',
                            VTIPPAG,
                            VSINTERF,
                            'VSINTERF : ' || VSINTERF || ' :SQLERRM: ' ||
                            SQLERRM);
              WHEN NO_DATA_FOUND THEN
                VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                               MOV.SSEGURO || '|' || MOV.CODESCENARIO || '|' ||
                               X_CUENTA || '|' || X_TIPPAG;
                VCOUNTERROR := VCOUNTERROR + 1;
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'TESTING:NO_DATA_FOUND',
                            VTIPPAG,
                            'VSINTERF : ' || VSINTERF,
                            'VLINEA: ' || VLINEA || ' :SQLERRM: ' ||
                            SQLERRM);
              
                UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                CONTINUE;
            END;
            IF VTIPPAG = 10 THEN
              VLINEAINI := VEMPRESA || '|' || VTIPPAG || '|' || VACCION || '|' ||
                           VIDPAGO || '|' || VIDMOV || '|' || VTERMINAL || '|' ||
                           F_USER || '|' || '' /*PNUMEVENTO*/
                           || '|' || '' /*PCODERRORIN*/
                           || '|' || '' /*PDESCERRORIN*/
                           || '|' || '1' /*PPASOCUENTA*/
               ;
            ELSE
              VLINEAINI := VEMPRESA || '|' || VTIPPAG || '|' || VACCION || '|' ||
                           VIDPAGO || '|' || VIDMOV || '|' || VTERMINAL || '|' ||
                           F_USER || '|' || '' /*PNUMEVENTO*/
                           || '|' || '' /*PCODERRORIN*/
                           || '|' || '' /*PDESCERRORIN*/
                           || '|' || '' /*PPASOCUENTA*/
               ;
            END IF;
          
            P_TAB_ERROR(F_SYSDATE,
                        F_USER,
                        'Entrda VA : I031',
                        VACCION,
                        VSINTERF,
                        'VSINTERF : ' || VSINTERF || ' :VLINEAINI: ' ||
                        VLINEAINI || ' : X_CUENTA: ' || X_CUENTA);
          
            VRESULTADO := PAC_INT_ONLINE.F_INT(VEMPRESA,
                                               VSINTERF,
                                               VINTERFICIE,
                                               VLINEAINI);
            /* CAMBIOS DE SWAPNIL : ENDS  */
          END IF;
          -- FIN VIGENCIA ACTUAL
        ELSE
        
          VCOUNTCUENTA       := 0;
          VCOUNTIMPORTE_ZERO := 0;
          FOR ESC IN ESCENARIOSVF(MOV.CODESCENARIO, MOV.RAMO) LOOP
            VCOUNTCUENTA := VCOUNTCUENTA + 1;
            X_GENERA     := 0;
            X_IMPORTE    := 0;
            X_PROCEDE    := 0;
            IF (ESC.PRODUCTO = 0 OR ESC.PRODUCTO = MOV.RAMO) THEN
              SELECT A.CCUENTA, A.LINEA
                INTO X_CUENTA, X_LINEA
                FROM CUENTASSAP A
               WHERE A.CODCUENTA = ESC.CODCUENTA;
              X_GENERA := 1;
              IF X_CUENTA IN (1630400100) THEN
                IF MOV.CTIPCOA IN (0, 8, 9) THEN
                  X_GENERA := 0;
                END IF;
              END IF;
            ELSIF ESC.PRODUCTO = 1 THEN
              SELECT A.CCUENTA, A.LINEA
                INTO X_CUENTA, X_LINEA
                FROM CUENTASSAP A
               WHERE A.CODCUENTA = ESC.CODCUENTA;
              X_GENERA := 1;
              IF X_CUENTA IN (1684050200, 1684050300, 4195950190) THEN
                IF MOV.CTIPCOA IN (8, 9) THEN
                  X_GENERA := 0;
                END IF;
              END IF;
            END IF;
          
            IF X_GENERA = 1 THEN
              BEGIN
                SELECT C.TTIPPAG, C.TCUENTA, C.CLAENLACE, C.TLIBRO
                  INTO X_TIPPAG, X_TAPUNTE, X_ENLACE, X_LIBRO
                  FROM CUENTASSAP C
                 WHERE C.CCUENTA = X_CUENTA;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  X_PROCEDE := 1;
              END;
            
              IF X_PROCEDE = 0 THEN
                IF ESC.CODCUENTA IN (6, 12) AND MOV.CTIPCOA IN (1, 2) THEN
                  FOR COD IN COACEDIDO(MOV.SSEGURO, MOV.NMOVIMI) LOOP
                    BEGIN
                      GENERARTRAMA_COD(PI_RECIBO   => MOV.NRECIBO,
                                       PI_AGENTE   => MOV.CAGENTE,
                                       PI_SCENARIO => MOV.CODESCENARIO,
                                       PI_CUENTA   => X_CUENTA,
                                       PI_TIPPAG   => X_TIPPAG,
                                       PI_COMPAN   => COD.CCOMPAN,
                                       PO_RESULT   => VRESULT);
                      LOOP
                        FETCH VRESULT
                          INTO VCOLETILLA, VDESCRI, IMPORTE, VOTROS, VFADM;
                        EXIT WHEN VRESULT%NOTFOUND;
                      END LOOP;
                      CLOSE VRESULT;
                    EXCEPTION
                      WHEN OTHERS THEN
                        VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                                       MOV.SSEGURO || '|' ||
                                       MOV.CODESCENARIO || '|' || X_CUENTA || '|' ||
                                       X_TIPPAG;
                        VCOUNTERROR := VCOUNTERROR + 1;
                        P_TAB_ERROR(F_SYSDATE,
                                    F_USER,
                                    'TESTING VF:TRAMA_COD: I031',
                                    VACCION,
                                    'VSINTERF :' || VSINTERF,
                                    'VLINEA : ' || VLINEA || ' :SQLERRM: ' ||
                                    SQLERRM);
                        UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                        CONTINUE;
                    END;
                    IF IMPORTE <> 0 THEN
                      SELECT TRUNC(FEFECTO)
                        INTO X_FECONTA
                        FROM RECIBOS
                       WHERE NRECIBO = MOV.NRECIBO;
                    
                      SELECT TRUNC(MAX(FMOVDIA))
                        INTO X_FECDOC
                        FROM MOVRECIBO
                       WHERE NRECIBO = MOV.NRECIBO;
                    
                      INSERT INTO CONTAB_ASIENT_INTERF
                        (SINTERF,
                         TTIPPAG,
                         IDPAGO,
                         FCONTA,
                         NASIENT,
                         NLINEA,
                         CCUENTA,
                         CCOLETILLA,
                         TAPUNTE,
                         IAPUNTE,
                         TDESCRI,
                         FEFEADM,
                         CENLACE,
                         TLIBRO,
                         OTROS,
                         IDMOV)
                      VALUES
                        (VSINTERF,
                         X_TIPPAG,
                         MOV.NRECIBO,
                         X_FECDOC,
                         X_VALOR,
                         X_LINEA,
                         SUBSTR(X_CUENTA, 1, 6),
                         SUBSTR(X_CUENTA, 7, 4),
                         X_TAPUNTE,
                         IMPORTE,
                         VDESCRI,
                         X_FECONTA,
                         X_ENLACE,
                         X_LIBRO,
                         VOTROS,
                         VIDMOVSEQ);
                    
                      UPDATE MOVCONTASAP M
                         SET M.SINTERF = VSINTERF
                       WHERE M.CAGENTE = MOV.CAGENTE
                         AND M.CODESCENARIO = MOV.CODESCENARIO
                         AND M.CTIPREC = MOV.CTIPREC
                         AND M.NRECIBO = MOV.NRECIBO;
                    
                      COMMIT;
                      V_VALIDA_ENVIO := 1;
                    END IF;
                  END LOOP;
                ELSE
                  BEGIN
                    --DBMS_OUTPUT.PUT_LINE('MOV.NRECIBO :'||MOV.NRECIBO||':MOV.CAGENTE:'||MOV.CAGENTE||':MOV.CODESCENARIO:'||MOV.CODESCENARIO);                
                    GENERARTRAMA(PI_RECIBO   => MOV.NRECIBO,
                                 PI_AGENTE   => MOV.CAGENTE,
                                 PI_SCENARIO => MOV.CODESCENARIO,
                                 PI_CUENTA   => X_CUENTA,
                                 PI_TIPPAG   => X_TIPPAG,
                                 PO_RESULT   => VRESULT);
                  
                    LOOP
                      FETCH VRESULT
                        INTO VCOLETILLA, VDESCRI, IMPORTE, VOTROS, VFADM;
                      EXIT WHEN VRESULT%NOTFOUND;
                    END LOOP;
                    CLOSE VRESULT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                                     MOV.SSEGURO || '|' || MOV.CODESCENARIO || '|' ||
                                     X_CUENTA || '|' || X_TIPPAG;
                      VCOUNTERROR := VCOUNTERROR + 1;
                      P_TAB_ERROR(F_SYSDATE,
                                  F_USER,
                                  'TESTING VF TRAMA: I031',
                                  VACCION,
                                  'VSINTERF : ' || VSINTERF,
                                  'VLINEA : ' || VLINEA || ' :SQLERRM: ' ||
                                  SQLERRM);
                      UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                      CONTINUE;
                  END;
                  IF IMPORTE <> 0 THEN
                    SELECT TRUNC(FEFECTO)
                      INTO X_FECONTA
                      FROM RECIBOS
                     WHERE NRECIBO = MOV.NRECIBO;
                  
                    SELECT TRUNC(MAX(FMOVDIA))
                      INTO X_FECDOC
                      FROM MOVRECIBO
                     WHERE NRECIBO = MOV.NRECIBO;
                  
                    INSERT INTO CONTAB_ASIENT_INTERF
                      (SINTERF,
                       TTIPPAG,
                       IDPAGO,
                       FCONTA,
                       NASIENT,
                       NLINEA,
                       CCUENTA,
                       CCOLETILLA,
                       TAPUNTE,
                       IAPUNTE,
                       TDESCRI,
                       FEFEADM,
                       CENLACE,
                       TLIBRO,
                       OTROS,
                       IDMOV)
                    VALUES
                      (VSINTERF,
                       X_TIPPAG,
                       MOV.NRECIBO,
                       X_FECDOC,
                       X_VALOR,
                       X_LINEA,
                       SUBSTR(X_CUENTA, 1, 6),
                       SUBSTR(X_CUENTA, 7, 4),
                       X_TAPUNTE,
                       IMPORTE,
                       VDESCRI,
                       X_FECONTA,
                       X_ENLACE,
                       X_LIBRO,
                       VOTROS,
                       VIDMOVSEQ);
                  
                    UPDATE MOVCONTASAP M
                       SET M.SINTERF = VSINTERF
                     WHERE M.CAGENTE = MOV.CAGENTE
                       AND M.CODESCENARIO = MOV.CODESCENARIO
                       AND M.CTIPREC = MOV.CTIPREC
                       AND M.NRECIBO = MOV.NRECIBO;
                  
                    COMMIT;
                    V_VALIDA_ENVIO := 1;
                  ELSE
                    VCOUNTIMPORTE_ZERO := VCOUNTIMPORTE_ZERO + 1;
                  END IF;
                END IF; -- COD 
              END IF;
            END IF;
          END LOOP;
        
          IF VCOUNTCUENTA = VCOUNTIMPORTE_ZERO THEN
            UPDATE MOVCONTASAP M
               SET M.SINTERF = VSINTERF, M.ESTADO = X_ESTADO_T
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.CODESCENARIO = MOV.CODESCENARIO
               AND M.CTIPREC = MOV.CTIPREC
               AND M.NRECIBO = MOV.NRECIBO;
            COMMIT;
          END IF;
        
          IF V_VALIDA_ENVIO = 1 THEN
            /* CAMBIOS DE SWAPNIL : STARTS */
            VINTERFICIE := PAC_PARAMETROS.F_PAREMPRESA_T(VEMPRESA,
                                                         'INTERFICIE_ERP');
            VERROR      := PAC_USER.F_GET_TERMINAL(F_USER, VTERMINAL);
            BEGIN
              SELECT DISTINCT CAI.TTIPPAG, CAI.IDPAGO, CAI.IDMOV
                INTO VTIPPAG, VIDPAGO, VIDMOV
                FROM CONTAB_ASIENT_INTERF CAI
               WHERE CAI.SINTERF = VSINTERF;
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                SELECT DISTINCT CAI.TTIPPAG, CAI.IDPAGO, CAI.IDMOV
                  INTO VTIPPAG, VIDPAGO, VIDMOV
                  FROM CONTAB_ASIENT_INTERF CAI
                 WHERE CAI.SINTERF = VSINTERF
                   AND ROWNUM = 1;
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'Testing VF:DUP_VAL_ON_INDEX:I031',
                            VACCION,
                            VSINTERF,
                            'VSINTERF : ' || VSINTERF || ' :SQLERRM: ' ||
                            SQLERRM);
              WHEN NO_DATA_FOUND THEN
                VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                               MOV.SSEGURO || '|' || MOV.CODESCENARIO || '|' ||
                               X_CUENTA || '|' || X_TIPPAG;
                VCOUNTERROR := VCOUNTERROR + 1;
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'Testing VF:NO_DATA_FOUND:I031',
                            VACCION,
                            'VSINTERF :' || VSINTERF,
                            'VLINEA : ' || VLINEA || ' :SQLERRM: ' ||
                            SQLERRM);
                UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                CONTINUE;
            END;
            IF VTIPPAG = 10 THEN
              VLINEAINI := VEMPRESA || '|' || VTIPPAG || '|' || VACCION || '|' ||
                           VIDPAGO || '|' || VIDMOV || '|' || VTERMINAL || '|' ||
                           F_USER || '|' || '' /*PNUMEVENTO*/
                           || '|' || '' /*PCODERRORIN*/
                           || '|' || '' /*PDESCERRORIN*/
                           || '|' || '1' /*PPASOCUENTA*/
               ;
            ELSE
              VLINEAINI := VEMPRESA || '|' || VTIPPAG || '|' || VACCION || '|' ||
                           VIDPAGO || '|' || VIDMOV || '|' || VTERMINAL || '|' ||
                           F_USER || '|' || '' /*PNUMEVENTO*/
                           || '|' || '' /*PCODERRORIN*/
                           || '|' || '' /*PDESCERRORIN*/
                           || '|' || '' /*PPASOCUENTA*/
               ;
            END IF;
          
            P_TAB_ERROR(F_SYSDATE,
                        F_USER,
                        'ENTRDA VF:I031',
                        VACCION,
                        VSINTERF,
                        'VSINTERF : ' || VSINTERF || ' :VLINEAINI: ' ||
                        VLINEAINI || ' : ' || X_CUENTA);
          
            VRESULTADO := PAC_INT_ONLINE.F_INT(VEMPRESA,
                                               VSINTERF,
                                               VINTERFICIE,
                                               VLINEAINI);
            /* CAMBIOS DE SWAPNIL : ENDS  */
          END IF;
          -- FIN VIGENCIA FUTURA
        END IF;
      
      ELSE
        /* When not eligible : for estado 3 */
        CONTINUE;
      END IF;
    
    END LOOP;
    /* CERAR ARCHIVO */
    IF UTL_FILE.IS_OPEN(VLOGARCHIVO) THEN
      UTL_FILE.FCLOSE(VLOGARCHIVO);
    END IF;
  
    IF VCOUNTERROR = 0 THEN
      UTL_FILE.FREMOVE(VRUTA, VNOMBREARCHIVO);
    END IF;
  
    -- IAXIS 4504 AABC 08/08/2019 PROCEDIMIENTO DE GENERACION DE CONTABILIDAD SINIESTROS 
    -- PAC_CONTA_SAP.GENERA_INFO_CUENTAS_SIN();
  END GENERA_INFO_CUENTAS;

  PROCEDURE GENERA_INFO_CUENTAS_SIN IS
    --
    CURSOR MOV_CONTA(P_EVENTO VARCHAR2) IS
    --
      SELECT A.*
        FROM MOVCONTASAP A
       WHERE A.ESTADO IN (0,3)
         AND A.EVENTO = P_EVENTO;
    --
    CURSOR CUR(VSIDEPAG NUMBER, VNSINIES NUMBER) IS
    --
      SELECT P.CCONPAG,
             P.SIDEPAG,
             S.CRAMO,
             S.CEMPRES,
             X.NSINIES,
             P.ISINRET,
             S.CTIPCOA,
             P.CTIPPAG,
             P.CMONPAG,
             P.CTIPDES,
             SR.CSOLIDARIDAD,
             S.SSEGURO
        FROM SEGUROS             S,
             SIN_SINIESTRO       X,
             SIN_TRAMITA_PAGO    P,
             SIN_TRAMITA_RESERVA SR
       WHERE P.SIDEPAG = NVL(VSIDEPAG, 0)
         AND X.NSINIES = VNSINIES
         AND SR.NSINIES = X.NSINIES
         AND X.NSINIES = P.NSINIES
         AND S.SSEGURO = X.SSEGURO
         AND ROWNUM = 1;
    --
  
    X_EVENTO VARCHAR2(50) := 'SINIESTROS';
  
    /* CAMBIOS DE SWAPNIL : STARTS  */
  
    VTERMINAL VARCHAR2(100);
    VERROR    NUMBER(10);
    VSINTERF  NUMBER;
    VEMITIDO  NUMBER;
    PERROR    VARCHAR2(2000);
  
    /* CAMBIOS DE SWAPNIL : ENDS  */
    X_ESTADO_I NUMBER := 0;
    X_ESTADO_P NUMBER := 3;
    X_ESTADO_T NUMBER := 4;
    X_ESTADO_SL NUMBER := 2;
    VEXECUTAR       VARCHAR2(2) := 'NO';
    VCOUNTIM        NUMBER := 0;
    VCOUNTSL        NUMBER := 0;
    VCOUNTSL_ESTADO NUMBER := 2;	
  
  BEGIN
  
    FOR MOV IN MOV_CONTA(X_EVENTO) LOOP
      --
      FOR REG IN CUR(MOV.NRECIBO, MOV.NSINIES) LOOP
        --     
        IF MOV.NUM_INTENTO IS NULL THEN
          UPDATE MOVCONTASAP M
             SET M.NUM_INTENTO = 1
           WHERE M.CAGENTE = MOV.CAGENTE
             AND M.NRECIBO = MOV.NRECIBO
             AND M.NSINIES = MOV.NSINIES
             AND M.CCONCEP = MOV.CCONCEP
             AND M.CODESCENARIO = MOV.CODESCENARIO;
          COMMIT;
        END IF;

     /* Checking eligibility of ESTADO 3 before retry */
     IF MOV.SINTERF IS NOT NULL AND MOV.ESTADO = X_ESTADO_P THEN
        SELECT COUNT(*)
          INTO VCOUNTIM
          FROM INT_MENSAJES IM
         WHERE IM.SINTERF = MOV.SINTERF;

        SELECT COUNT(*)
          INTO VCOUNTSL
          FROM SERVICIO_LOGS SL
         WHERE SL.SINTERF = MOV.SINTERF;

        IF VCOUNTIM > 0 AND VCOUNTSL > 0 THEN
          BEGIN
            SELECT SL.ESTADO
              INTO VCOUNTSL_ESTADO
              FROM SERVICIO_LOGS SL
             WHERE SL.SINTERF = MOV.SINTERF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VCOUNTSL_ESTADO := X_ESTADO_SL;
          END;
          IF VCOUNTSL_ESTADO = X_ESTADO_SL THEN
            VEXECUTAR := 'SI';
            DELETE CONTAB_ASIENT_INTERF CAI
             WHERE CAI.IDPAGO  = MOV.NRECIBO
               AND CAI.SINTERF = MOV.SINTERF;
            COMMIT;
          ELSE
            VEXECUTAR := 'NO';
            UPDATE MOVCONTASAP M
               SET M.ESTADO = X_ESTADO_T
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.NRECIBO = MOV.NRECIBO
               AND M.NSINIES = MOV.NSINIES
               AND M.CCONCEP = MOV.CCONCEP
               AND M.CODESCENARIO = MOV.CODESCENARIO;            
            COMMIT;
          END IF;
        ELSE
            VEXECUTAR := 'SI';
        END IF;

      ELSIF MOV.ESTADO = X_ESTADO_I THEN
            VEXECUTAR := 'SI';
      END IF;      
      
      IF VEXECUTAR = 'SI' THEN
      /* Change status once start processing 3*/
        PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
        VSINTERF := PAC_INT_ONLINE.F_OBTENER_SINTERF;
        VERROR   := PAC_USER.F_GET_TERMINAL(PAC_MD_COMMON.F_GET_CXTUSUARIO,
                                            VTERMINAL);   
                                            
        UPDATE MOVCONTASAP M
             SET M.ESTADO  = X_ESTADO_P, 
                 M.SINTERF = VSINTERF
           WHERE M.CAGENTE = MOV.CAGENTE
             AND M.NRECIBO = MOV.NRECIBO
             AND M.NSINIES = MOV.NSINIES
             AND M.CCONCEP = MOV.CCONCEP
             AND M.CODESCENARIO = MOV.CODESCENARIO;
        COMMIT;                                               
                 
        VERROR := PAC_CON.F_CONTAB_SINIESTRO(REG.CEMPRES,                                             
                                             1,
                                             REG.CTIPPAG,
                                             REG.SIDEPAG,
                                             0,
                                             VTERMINAL,
                                             VEMITIDO,
                                             VSINTERF,
                                             PERROR,
                                             F_USER,
                                             NULL,
                                             NULL,
                                             NULL,
                                             1);
      END IF;                                             

      END LOOP;
      --    
    END LOOP;
    --
    PAC_CONTA_SAP.GENERA_INFO_CUENTAS_RES(1);
    --
  END GENERA_INFO_CUENTAS_SIN;
  ---------------------------
  -- Procedimiento para la contabilidad de siniestros reservas   
  ---------------------------  
  PROCEDURE GENERA_INFO_CUENTAS_RES (P_TIPO IN NUMBER) IS
    --
    CURSOR MOV_CONTA(P_EVENTO VARCHAR2) IS
    --
      SELECT A.*
        FROM MOVCONTASAP A
       WHERE A.ESTADO IN (0,3)
         AND A.EVENTO = P_EVENTO;
    --
  
    X_EVENTO VARCHAR2(50);
  
    /* CAMBIOS DE SWAPNIL : STARTS  */
  
    VTERMINAL VARCHAR2(100);
    VERROR    NUMBER(10);
    VSINTERF  NUMBER;
    VEMITIDO  NUMBER;
    PERROR    VARCHAR2(2000);
    VCCONPAG  NUMBER;
    VSIDEPAG  NUMBER;
    VCRAMO    NUMBER;
    VCEMPRES  NUMBER;
    VNSINIES  NUMBER;
    VISINRET  NUMBER;
    VCTIPCOA  NUMBER;
    VCTIPPAG  NUMBER;
    VCMONPAG  NUMBER;
    VCTIPDES  NUMBER;
    VCSOLIDA  NUMBER;
    VSSEGURO  NUMBER;
    VNTRAMIT  NUMBER;
    VCTPRES   NUMBER;
    VNMOVRES  NUMBER;
    VIDRES    NUMBER;
    VCMONRES  VARCHAR2(10);
    VNMONRES  NUMBER;
    /* CAMBIOS DE SWAPNIL : ENDS  */
    
    X_ESTADO_I NUMBER := 0;
    X_ESTADO_P NUMBER := 3;
    X_ESTADO_T NUMBER := 4;
    X_ESTADO_SL NUMBER := 2;
    VEXECUTAR       VARCHAR2(2) := 'NO';
    VCOUNTIM        NUMBER := 0;
    VCOUNTSL        NUMBER := 0;
    VCOUNTSL_ESTADO NUMBER := 2;	
  
  BEGIN
    --
    IF P_TIPO = 1 THEN 
      --
      X_EVENTO := 'RESERVA';
      --
    ELSIF P_TIPO = 2 THEN 
      --
      X_EVENTO := 'RESERCIERRE';
      --
    END IF;    
    --
    FOR MOV IN MOV_CONTA(X_EVENTO) LOOP
      --
      BEGIN
        --
        SELECT 0               CCONPAG,
               SR.SIDEPAG,
               S.CRAMO,
               S.CEMPRES,
               X.NSINIES,
               0               ISINRET,
               S.CTIPCOA,
               2               CTIPPAG,
               0               CMONPAG,
               0               CTIPDES,
               SR.CSOLIDARIDAD,
               S.SSEGURO,
               NTRAMIT,
               CTIPRES,
               NMOVRES,
               SR.IDRES
          INTO VCCONPAG,
               VSIDEPAG,
               VCRAMO,
               VCEMPRES,
               VNSINIES,
               VISINRET,
               VCTIPCOA,
               VCTIPPAG,
               VCMONPAG,
               VCTIPDES,
               VCSOLIDA,
               VSSEGURO,
               VNTRAMIT,
               VCTPRES,
               VNMOVRES,
               VIDRES
          FROM SEGUROS S, SIN_SINIESTRO X, SIN_TRAMITA_RESERVA_CONTA SR
         WHERE SR.NSINIES = MOV.NSINIES
           AND SR.NMOVRES = MOV.NMOVIMI
           AND X.NSINIES = MOV.NSINIES
           AND S.SSEGURO = X.SSEGURO
           AND SR.IDRES = MOV.CCONCEP
           AND ROWNUM = 1;
        --
      EXCEPTION
        WHEN OTHERS THEN
          --
          NULL;
          --  
      END;
      --
      BEGIN
        --
        SELECT CMONRES
          INTO VCMONRES
          FROM SIN_TRAMITA_RESERVADET
         WHERE NSINIES = MOV.NSINIES
           AND IDRES = MOV.CCONCEP
           AND NMOVRES = MOV.NMOVIMI
           AND NMOVRESDET = MOV.CTIPCOA;
        --   
      EXCEPTION
        WHEN OTHERS THEN
          --
          NULL;
          --
      END;
      --
      IF VCMONRES = 'COP' THEN
        --
        VNMONRES := 0;
        --
      ELSE
        --
        VNMONRES := 1;
        --
      END IF;
      --

     IF MOV.NUM_INTENTO IS NULL THEN
        UPDATE MOVCONTASAP M
           SET M.NUM_INTENTO = 1
         WHERE M.CAGENTE = MOV.CAGENTE
           AND M.NRECIBO = MOV.NRECIBO
           AND M.NSINIES = MOV.NSINIES
           AND M.NMOVIMI = MOV.NMOVIMI
           AND M.CTIPCOA = MOV.CTIPCOA
           AND M.CCONCEP = MOV.CCONCEP
           AND M.CODESCENARIO = MOV.CODESCENARIO;
        COMMIT;
     END IF;
    
          /* Checking eligibility of ESTADO 3 before retry */
     IF MOV.SINTERF IS NOT NULL AND MOV.ESTADO = X_ESTADO_P THEN
        SELECT COUNT(*)
          INTO VCOUNTIM
          FROM INT_MENSAJES IM
         WHERE IM.SINTERF = MOV.SINTERF;

        SELECT COUNT(*)
          INTO VCOUNTSL
          FROM SERVICIO_LOGS SL
         WHERE SL.SINTERF = MOV.SINTERF;

        IF VCOUNTIM > 0 AND VCOUNTSL > 0 THEN
          BEGIN
            SELECT SL.ESTADO
              INTO VCOUNTSL_ESTADO
              FROM SERVICIO_LOGS SL
             WHERE SL.SINTERF = MOV.SINTERF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VCOUNTSL_ESTADO := X_ESTADO_SL;
          END;
          IF VCOUNTSL_ESTADO = X_ESTADO_SL THEN
            VEXECUTAR := 'SI';
            DELETE CONTAB_ASIENT_INTERF CAI
             WHERE CAI.IDPAGO  = MOV.NRECIBO
               AND CAI.SINTERF = MOV.SINTERF;
            COMMIT;
          ELSE
            VEXECUTAR := 'NO';
            UPDATE MOVCONTASAP M
               SET M.ESTADO = X_ESTADO_T
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.NRECIBO = MOV.NRECIBO
               AND M.NSINIES = MOV.NSINIES
               AND M.NMOVIMI = MOV.NMOVIMI
               AND M.CTIPCOA = MOV.CTIPCOA
               AND M.CCONCEP = MOV.CCONCEP
               AND M.CODESCENARIO = MOV.CODESCENARIO;
            COMMIT;
          END IF;
        ELSE
            VEXECUTAR := 'SI';
        END IF;

      ELSIF MOV.ESTADO = X_ESTADO_I THEN
            VEXECUTAR := 'SI';
      END IF;
                
     IF VEXECUTAR = 'SI' THEN
     /* Change status once start processing 3*/
     
      PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
      VSINTERF := PAC_INT_ONLINE.F_OBTENER_SINTERF;
      VERROR   := PAC_USER.F_GET_TERMINAL(PAC_MD_COMMON.F_GET_CXTUSUARIO,
                                          VTERMINAL);
     
     UPDATE MOVCONTASAP M
           SET M.ESTADO  = X_ESTADO_P, 
               M.SINTERF = VSINTERF
         WHERE M.CAGENTE = MOV.CAGENTE
           AND M.NRECIBO = MOV.NRECIBO
           AND M.NSINIES = MOV.NSINIES
           AND M.NMOVIMI = MOV.NMOVIMI
           AND M.CTIPCOA = MOV.CTIPCOA
           AND M.CCONCEP = MOV.CCONCEP
           AND M.CODESCENARIO = MOV.CODESCENARIO;
        COMMIT;   

      VERROR := PAC_CON.F_CONTAB_SINIESTRO_RES(VCEMPRES,
                                               1,
                                               VCTIPPAG,
                                               MOV.NRECIBO, --REG.SIDEPAG,
                                               0,
                                               VTERMINAL,
                                               VEMITIDO,
                                               VSINTERF,
                                               PERROR,
                                               F_USER,
                                               NULL,
                                               NULL,
                                               NULL,
                                               1,
                                               VNSINIES,
                                               VNTRAMIT,
                                               VCTPRES,
                                               VNMOVRES,
                                               MOV.CTIPCOA,
                                               MOV.CTIPREC,
                                               VIDRES,
                                               VNMONRES);
      --  
      IF VERROR = 0 THEN
        --                                   
        UPDATE SIN_TRAMITA_RESERVA_CONTA
           SET CESTADO = 1
         WHERE NSINIES = VNSINIES
           AND NTRAMIT = VNTRAMIT
           AND CTIPRES = VCTPRES
           AND NMOVRES = VNMOVRES;
        COMMIT;
        --
      END IF;
                                          
     END IF;      
      --  
    END LOOP;
  
  END GENERA_INFO_CUENTAS_RES;

  FUNCTION GENERARUIDPARACOM(PI_RECIBO   IN NUMBER,
                             PI_SCENARIO IN NUMBER,
                             PI_SINTERF  IN NUMBER) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    --V_COUNT NUMBER :=0;  
    V_TYPESOLICITUD  VARCHAR2(1) := 'X';
    V_UNIQUE         VARCHAR2(50) := NULL;
    PO_RESULT        VARCHAR2(50) := NULL;
    V_UNIQUESCENARIO VARCHAR2(50) := NULL;
    V_ESCENARIO      NUMBER := 0;
    V_AGENTE_N       NUMBER := 0;
    V_AGENTE_A       NUMBER := 0;
    V_UNIQUES_A      VARCHAR2(50) := NULL;
    V_ACTUALIZA      VARCHAR2(2) := NULL;
  
    X_ESTADO_I NUMBER := 3;
    X_ESTADO_T NUMBER := 4;
  
    CURSOR DATOSPARASAP(P_RECIBO VARCHAR2) IS
      SELECT A.ROWID, A.NUMUNICO_SAP, A.CAGENTE
        FROM MOVCONTASAP A
       WHERE A.ESTADO = X_ESTADO_T
         AND A.NRECIBO = P_RECIBO;
  BEGIN
  
    IF PI_SCENARIO IN (255,
                       256,
                       250,
                       215,
                       225,
                       220,
                       212,
                       226,
                       253,
                       251,
                       218,
                       210,
                       207,
                       206,
                       248,
                       257,
                       252,
                       266,
                       265,
                       335,
                       336,
                       343,
                       344,
                       353,
                       354,
                       357,
                       358,
                       263,
                       249,
                       214,
                       219,
                       233) THEN
      V_TYPESOLICITUD := 'N'; /*NUEVAS*/
    ELSIF PI_SCENARIO IN (239,
                          246,
                          240,
                          235,
                          241,
                          236,
                          232,
                          211,
                          209,
                          208,
                          339,
                          340,
                          361,
                          362) THEN
      V_TYPESOLICITUD := 'A'; /*ANULACIONES*/
    ELSIF PI_SCENARIO IN (202, 203) THEN
      V_TYPESOLICITUD := 'C'; /*CANCELACIONES*/
    END IF;
  
    IF V_TYPESOLICITUD = 'N' THEN
      SELECT UPPER(SUBSTR(A.ROWID, -4, 4))
        INTO V_UNIQUE
        FROM MOVCONTASAP A
       WHERE A.ESTADO = X_ESTADO_I
         AND A.CODESCENARIO = PI_SCENARIO
         AND A.NRECIBO = PI_RECIBO
         AND A.SINTERF = PI_SINTERF;
    
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = V_UNIQUE || '|' || PI_SCENARIO || '|' ||
                              M.CAGENTE
       WHERE M.ESTADO = X_ESTADO_I
         AND M.CODESCENARIO = PI_SCENARIO
         AND M.NRECIBO = PI_RECIBO
         AND M.SINTERF = PI_SINTERF;
    
    ELSIF V_TYPESOLICITUD = 'A' THEN
    
      FOR MOV IN DATOSPARASAP(PI_RECIBO) LOOP
      
        SELECT REGEXP_SUBSTR(MOV.NUMUNICO_SAP, '[^|]+', 10, LEVEL) VALOR
          INTO V_AGENTE_N
          FROM DUAL
        CONNECT BY REGEXP_SUBSTR(MOV.NUMUNICO_SAP, '[^|]+', 10, LEVEL) IS NOT NULL;
      
        SELECT M.CAGENTE
          INTO V_AGENTE_A
          FROM MOVCONTASAP M
         WHERE M.SINTERF = PI_SINTERF;
      
        IF UPPER(SUBSTR(MOV.ROWID, -4, 4)) = SUBSTR(MOV.NUMUNICO_SAP, 1, 4) AND
           V_AGENTE_A = V_AGENTE_N THEN
        
          V_UNIQUE := MOV.NUMUNICO_SAP;
        
          SELECT SUBSTR(V_UNIQUE, 6, 3), SUBSTR(V_UNIQUE, 1, 4)
            INTO V_ESCENARIO, V_UNIQUESCENARIO -- 
            FROM DUAL;
        
          ANULA_SCENARIO(V_AGENTE_N, -- AGENTE PROD
                         V_ESCENARIO, -- ESCENARIO PROD
                         PI_SCENARIO, --ESCENARIO ANUL
                         PI_RECIBO, -- RECIBO 
                         V_UNIQUESCENARIO, -- RUID PROD
                         PI_SINTERF);
        
          SELECT M.NUMUNICO_SAP
            INTO V_UNIQUES_A
            FROM MOVCONTASAP M
           WHERE M.SINTERF = PI_SINTERF;
        
          IF V_UNIQUES_A = V_UNIQUESCENARIO THEN
            V_ACTUALIZA := 'SI';
          ELSE
            V_ACTUALIZA := 'NO';
          END IF;
        
          IF V_ACTUALIZA = 'SI' THEN
            EXIT;
          END IF;
        
        END IF;
      END LOOP;
    ELSIF V_TYPESOLICITUD = 'C' THEN
      FOR MOV IN DATOSPARASAP(PI_RECIBO) LOOP
      
        SELECT REGEXP_SUBSTR(MOV.NUMUNICO_SAP, '[^|]+', 10, LEVEL) VALOR
          INTO V_AGENTE_N
          FROM DUAL
        CONNECT BY REGEXP_SUBSTR(MOV.NUMUNICO_SAP, '[^|]+', 10, LEVEL) IS NOT NULL;
      
        SELECT M.CAGENTE
          INTO V_AGENTE_A
          FROM MOVCONTASAP M
         WHERE M.SINTERF = PI_SINTERF;
      
        IF UPPER(SUBSTR(MOV.ROWID, -4, 4)) = SUBSTR(MOV.NUMUNICO_SAP, 1, 4) AND
           V_AGENTE_A = V_AGENTE_N THEN
        
          V_UNIQUE := MOV.NUMUNICO_SAP;
        
          SELECT SUBSTR(V_UNIQUE, 6, 3), SUBSTR(V_UNIQUE, 1, 4)
            INTO V_ESCENARIO, V_UNIQUESCENARIO -- 
            FROM DUAL;
        
          CALCELACION_SCENARIO(V_AGENTE_N, -- AGENTE PROD
                               V_ESCENARIO, -- ESCENARIO PROD
                               PI_SCENARIO, -- ESCENARIO CANCELACION
                               PI_RECIBO, -- RECIBO 
                               V_UNIQUESCENARIO, -- RUID PROD
                               PI_SINTERF);
        
          SELECT M.NUMUNICO_SAP
            INTO V_UNIQUES_A
            FROM MOVCONTASAP M
           WHERE M.SINTERF = PI_SINTERF;
        
          IF V_UNIQUES_A = V_UNIQUESCENARIO THEN
            V_ACTUALIZA := 'SI';
          ELSE
            V_ACTUALIZA := 'NO';
          END IF;
        
          IF V_ACTUALIZA = 'SI' THEN
            EXIT;
          END IF;
        
        END IF;
      END LOOP;
    ELSE
      V_UNIQUE := NULL;
    END IF;
  
    IF V_UNIQUE IS NOT NULL AND V_TYPESOLICITUD = 'N' THEN
      PO_RESULT := PI_RECIBO || SUBSTR(V_UNIQUE, -2, 2);
    ELSIF V_UNIQUE IS NOT NULL AND V_TYPESOLICITUD = 'A' THEN
      PO_RESULT := PI_RECIBO || SUBSTR(V_UNIQUESCENARIO, -2, 2);
    ELSIF V_UNIQUE IS NOT NULL AND V_TYPESOLICITUD = 'C' THEN
      PO_RESULT := PI_RECIBO || SUBSTR(V_UNIQUESCENARIO, -2, 2);
    ELSE
      PO_RESULT := PI_RECIBO;
    END IF;
    COMMIT;
    RETURN PO_RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      PO_RESULT := PI_RECIBO;
      RETURN PO_RESULT;
  END GENERARUIDPARACOM;

  PROCEDURE GENERARTRAMA(PI_RECIBO   IN NUMBER,
                         PI_AGENTE   IN NUMBER,
                         PI_SCENARIO IN NUMBER,
                         PI_CUENTA   IN VARCHAR2,
                         PI_TIPPAG   IN NUMBER,
                         PO_RESULT   OUT SYS_REFCURSOR) AS
  
    CURSOR DATOSPARASAP(P_RECIBO   NUMBER,
                        P_AGENTE   NUMBER,
                        P_SCENARIO NUMBER) IS
      SELECT *
        FROM MOVCONTASAP M
       WHERE /*M.ESTADO = 3
              AND */
       M.CAGENTE = P_AGENTE
       AND M.CODESCENARIO = P_SCENARIO
       AND M.NRECIBO = P_RECIBO;
  
    --L_NOCOASEGURO   NUMBER :=0;
    --L_COASCEDIDO    NUMBER :=1;                            
    --L_COASACEPTADO  NUMBER :=8;  
    L_TIPO_IMPORTE CUENTASSAP.TIPO_IMPORTE%TYPE;
    L_DESCRIP      CUENTASSAP.DESCRIP%TYPE;
    L_IMPORTE      NUMBER := 0;
    L_ICEDNET      VDETRECIBOS_MONPOL.ICEDNET%TYPE;
    L_CCOMPAN      NUMBER := 0;
    L_CTIPREC      RECIBOS.CTIPREC%TYPE;
  
  BEGIN
    FOR MOV IN DATOSPARASAP(PI_RECIBO, PI_AGENTE, PI_SCENARIO) LOOP
      SELECT C.DESCRIP, C.TIPO_IMPORTE
        INTO L_DESCRIP, L_TIPO_IMPORTE
        FROM CUENTASSAP C
       WHERE C.CCUENTA = PI_CUENTA;
    
      BEGIN
        SELECT COUNT(*)
          INTO L_CCOMPAN
          FROM COACEDIDO C
         WHERE C.CCOMPAN = MOV.CAGENTE
           AND C.SSEGURO = MOV.SSEGURO;
        IF L_CCOMPAN > 0 THEN
          L_CCOMPAN := 1;
        ELSE
          L_CCOMPAN := 0;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_CCOMPAN := 0;
      END;
    
      BEGIN
        SELECT R.CTIPREC
          INTO L_CTIPREC
          FROM MOVSEGURO MS, RECIBOS R, MOVRECIBO MR
         WHERE MS.SSEGURO = R.SSEGURO
           AND R.NRECIBO = MR.NRECIBO
           AND R.NRECIBO = PI_RECIBO
           AND MS.CMOVSEG = 3
           AND MR.CESTREC = 0;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      IF MOV.CTIPREC NOT IN (9531, 9532) THEN
        IF MOV.CTIPCOA in (1, 2) AND L_CCOMPAN = 1 AND L_TIPO_IMPORTE <> 11 THEN
          /* COAS.CEDIDO */
          SELECT V.ICEDNET
            INTO L_ICEDNET
            FROM VDETRECIBOS_MONPOL V
           WHERE V.NRECIBO = PI_RECIBO;
          L_IMPORTE := NVL(PAC_COA.F_IMPCOA_CCOMP(MOV.SSEGURO,
                                                  MOV.CAGENTE,
                                                  F_SYSDATE,
                                                  L_ICEDNET),
                           0);
        ELSE
          L_IMPORTE := NVL(PAC_CONTA_SAP.F_IMPORTES_SAP(MOV.NRECIBO,
                                                        L_TIPO_IMPORTE,
                                                        PI_TIPPAG,
                                                        PI_AGENTE,
                                                        PI_CUENTA),
                           0);
        END IF;
      
        OPEN PO_RESULT FOR
          SELECT SUBSTR(PI_CUENTA, -4, 4) COLETILLA,
                 L_DESCRIP || '-' || PI_AGENTE DESCRIP,
                 L_IMPORTE IMPORTE,
                 LPAD(NVL(PI_SCENARIO, 0), 3, '0') || LPAD(1000, 4, '0') ||
                 LPAD('COP', 5, '0') || LPAD(0, 2, '0') || LPAD(0, 4, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_CONTAB_TRM(S.SSEGURO, NULL), 0),
                      15,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_CONTAB_TRM(S.SSEGURO, NULL), 0),
                      12,
                      '0') || LPAD(NVL(PAC_CONTAB_CONF.F_MONEDA(PAC_CONTAB_CONF.F_MON_POLIZA(S.SSEGURO)),
                                       0),
                                   12,
                                   '0') || LPAD('WIAXIS', 12, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_TIPO(PI_CUENTA), 'C'), 1, '0') ||
                 LPAD(NVL(PAC_CONTA_SAP.FF_BUSCASPERSON(PI_SCENARIO,
                                                        PI_CUENTA,
                                                        PI_RECIBO,
                                                        PI_AGENTE),
                          0),
                      10,
                      '0') --TERCERO
                 || LPAD(NVL(PAC_CONTAB_CONF.F_PAGADOR_ALT(S.SSEGURO), 0),
                         10,
                         '0') || LPAD(NVL(PAC_CONTA_SAP.F_INDICADOR_SAP(PI_CUENTA,
                                                                        L_TIPO_IMPORTE,
                                                                        L_IMPORTE,
                                                                        PI_RECIBO,
                                                                        PI_AGENTE),
                                          0),
                                      2,
                                      '0') || LPAD(0, 23, '0') ||
                 LPAD(0, 23, '0') || LPAD('Z001', 4, '0') ||
                 LPAD(TO_CHAR(R.FVENCIM, 'YYYY-MM-DD'), 10, '0') ||
                 LPAD(DECODE(LPAD(NVL(PAC_CONTAB_CONF.F_TIPO(PI_CUENTA),
                                      'C'),
                                  1,
                                  '0'),
                             'D',
                             'I',
                             'K',
                             'I',
                             '0'),
                      1,
                      '0') || LPAD(NVL(PAC_IMPUESTOS_CONF.F_INDICADOR_AGENTE(R.CAGENTE,
                                                                             1,
                                                                             SYSDATE),
                                       0),
                                   2,
                                   '0') || LPAD(0, 2, '0') ||
                 LPAD(0, 23, '0') || LPAD(0, 23, '0') ||
                 LPAD(R.NRECIBO, 18, '0') || LPAD(0, 10, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_SEGMENTO(S.SSEGURO), 0),
                      10,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_DIVISION(S.SSEGURO, S.CAGENTE),
                          0),
                      4,
                      '0') ||
                 LPAD(PAC_CONTAB_CONF.F_PERSONA(T.SPERSON, NULL, NULL, NULL),
                      12,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_ZZFIPOLIZA(S.SSEGURO), 0),
                      20,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_REGION(NULL, S.CAGENTE), 0),
                      2,
                      '0') ||
                 LPAD(NVL(FF_BUSCADATOSSAP(9, S.SSEGURO), 0), 18, '0') ||
                 LPAD(0, 15, '0') ||
                 LPAD(NVL(PAC_CONTA_SAP.F_CERTIFIC(S.SSEGURO, MOV.NMOVIMI),
                          0),
                      10,
                      '0') || LPAD(0, 1, '0') || LPAD(0, 17, '0') OTROS,
                 GREATEST(R.FEFECTO, TRUNC(M.FEFEADM)) FECHA
            FROM RECIBOS R, SEGUROS S, TOMADORES T, MOVRECIBO M
           WHERE T.SSEGURO = S.SSEGURO
             AND M.NRECIBO = R.NRECIBO
             AND M.CESTREC = 0
             AND M.CESTANT = 0
             AND S.SSEGURO = R.SSEGURO
             AND R.CTIPCOA = MOV.CTIPCOA
             AND R.CTIPREC = DECODE(SUBSTR(MOV.CTIPREC, -4, 4),
                                    9032,
                                    L_CTIPREC,
                                    SUBSTR(MOV.CTIPREC, -4, 1))
             AND R.NRECIBO = MOV.NRECIBO;
      
      ELSE
        -- Cancellation                             
        L_IMPORTE := PAC_CONTA_SAP.F_IMPORTES_CAN_SAP(MOV.NRECIBO,
                                                      L_TIPO_IMPORTE,
                                                      PI_SCENARIO,
                                                      PI_AGENTE,
                                                      PI_CUENTA);
      
        OPEN PO_RESULT FOR
          SELECT SUBSTR(PI_CUENTA, -4, 4) COLETILLA,
                 L_DESCRIP || '-' || PI_AGENTE DESCRIP,
                 L_IMPORTE IMPORTE,
                 LPAD(NVL(PI_SCENARIO, 0), 3, '0') || LPAD(1000, 4, '0') ||
                 LPAD('COP', 5, '0') || LPAD(0, 2, '0') || LPAD(0, 4, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_CONTAB_TRM(S.SSEGURO, NULL), 0),
                      15,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_CONTAB_TRM(S.SSEGURO, NULL), 0),
                      12,
                      '0') || LPAD(NVL(PAC_CONTAB_CONF.F_MONEDA(PAC_CONTAB_CONF.F_MON_POLIZA(S.SSEGURO)),
                                       0),
                                   12,
                                   '0') || LPAD('WIAXIS', 12, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_TIPO(PI_CUENTA), 'C'), 1, '0') ||
                 LPAD(NVL(PAC_CONTA_SAP.FF_BUSCASPERSON(PI_SCENARIO,
                                                        PI_CUENTA,
                                                        PI_RECIBO,
                                                        PI_AGENTE),
                          0),
                      10,
                      '0') --TERCERO
                 || LPAD(NVL(PAC_CONTAB_CONF.F_PAGADOR_ALT(S.SSEGURO), 0),
                         10,
                         '0') || LPAD(NVL(PAC_CONTA_SAP.F_INDICADOR_SAP(PI_CUENTA,
                                                                        L_TIPO_IMPORTE,
                                                                        L_IMPORTE,
                                                                        PI_RECIBO,
                                                                        PI_AGENTE),
                                          0),
                                      2,
                                      '0') || LPAD(0, 23, '0') ||
                 LPAD(0, 23, '0') || LPAD('Z001', 4, '0') ||
                 LPAD(TO_CHAR(R.FVENCIM, 'YYYY-MM-DD'), 10, '0') ||
                 LPAD(DECODE(LPAD(NVL(PAC_CONTAB_CONF.F_TIPO(PI_CUENTA),
                                      'C'),
                                  1,
                                  '0'),
                             'D',
                             'I',
                             'K',
                             'I',
                             '0'),
                      1,
                      '0') || LPAD(NVL(PAC_IMPUESTOS_CONF.F_INDICADOR_AGENTE(R.CAGENTE,
                                                                             1,
                                                                             SYSDATE),
                                       0),
                                   2,
                                   '0') || LPAD(0, 2, '0') ||
                 LPAD(0, 23, '0') || LPAD(0, 23, '0') ||
                 LPAD(R.NRECIBO, 18, '0') || LPAD(0, 10, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_SEGMENTO(S.SSEGURO), 0),
                      10,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_DIVISION(S.SSEGURO, S.CAGENTE),
                          0),
                      4,
                      '0') ||
                 LPAD(PAC_CONTAB_CONF.F_PERSONA(T.SPERSON, NULL, NULL, NULL),
                      12,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_ZZFIPOLIZA(S.SSEGURO), 0),
                      20,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_REGION(NULL, S.CAGENTE), 0),
                      2,
                      '0') ||
                 LPAD(NVL(FF_BUSCADATOSSAP(9, S.SSEGURO), 0), 18, '0') ||
                 LPAD(0, 15, '0') ||
                 LPAD(NVL(PAC_CONTA_SAP.F_CERTIFIC(S.SSEGURO, MOV.NMOVIMI),
                          0),
                      10,
                      '0') || LPAD(0, 1, '0') || LPAD(0, 17, '0') OTROS,
                 GREATEST(R.FEFECTO, TRUNC(M.FEFEADM)) FECHA
            FROM RECIBOS R, SEGUROS S, TOMADORES T, MOVRECIBO M
           WHERE T.SSEGURO = S.SSEGURO
             AND M.NRECIBO = R.NRECIBO
             AND M.CMOTMOV = 321
             AND M.CESTANT = 0
             AND S.SSEGURO = R.SSEGURO
             AND R.CTIPCOA = MOV.CTIPCOA
             AND R.NRECIBO = MOV.NRECIBO;
      END IF;
    END LOOP;
  
  END GENERARTRAMA;

  FUNCTION F_IMPORTES_SAP(PNRECIBO      NUMBER,
                          PTIPO_IMPORTE VARCHAR2,
                          PTTIPPAG      NUMBER,
                          PAGENTE       NUMBER,
                          PCUENTA       VARCHAR2) RETURN NUMBER IS
    V_RETORNO_1       NUMBER := 0;
    V_CALIMP_PRIMA    NUMBER := 0;
    V_CALIMP_IVA      NUMBER := 0;
    V_CALIMP_GASTO    NUMBER := 0;
    V_CALIMP_COMI     NUMBER := 0;
    V_CALIMP_COMI_IVA NUMBER := 0;
  
    V_IS_PRIMA    NUMBER := 0;
    V_IS_IVA      NUMBER := 0;
    V_IS_GASTO    NUMBER := 0;
    V_IS_COMI     NUMBER := 0;
    V_IS_COMI_IVA NUMBER := 0;
  
    /**************
      PRIMA = 0
      IMPUESTOS (IVA) = 4
      GASTOS = 8
      COMISIONES = 11
    *******/
    FUNCTION F_TIPO_IMPORTE(PTIPO_IMPORTE VARCHAR2) RETURN NUMBER IS
    
      CURSOR BUSCARTIPO(PTIPO_IMPORTE VARCHAR2) IS
        SELECT REGEXP_SUBSTR(PTIPO_IMPORTE, '[^|]+', 1, LEVEL) VALOR
          FROM DUAL
        CONNECT BY REGEXP_SUBSTR(PTIPO_IMPORTE, '[^|]+', 1, LEVEL) IS NOT NULL;
    
      CURSOR C1(W_NRECIBO RECIBOS.NRECIBO%TYPE) IS
        SELECT * FROM VDETRECIBOS_MONPOL V WHERE V.NRECIBO = W_NRECIBO;
      C1_R      C1%ROWTYPE;
      V_RETORNO NUMBER := 0;
    
    BEGIN
      OPEN C1(PNRECIBO);
      FETCH C1
        INTO C1_R;
      IF C1%NOTFOUND THEN
        -- V_RETORNO := 1000254;
        V_RETORNO := 0;
      END IF;
    
      FOR TIPO IN BUSCARTIPO(PTIPO_IMPORTE) LOOP
      
        IF TIPO.VALOR = 0 THEN
          /* PRIMA = 0 */
          V_CALIMP_PRIMA := C1_R.IPRINET;
          V_IS_PRIMA     := 1;
        ELSIF TIPO.VALOR = 4 THEN
          /* IMPUESTOS (IVA) = 4 */
          V_CALIMP_IVA := C1_R.ITOTIMP;
          V_IS_IVA     := 1;
        ELSIF TIPO.VALOR = 8 THEN
          /* GASTOS = 8 */
          V_CALIMP_GASTO := C1_R.ITOTREC;
          V_IS_GASTO     := 1;
        ELSIF TIPO.VALOR = 11 THEN
          /* COMISIONES = 11 */
          V_CALIMP_COMI := F_COMISION_SAP(PNRECIBO,
                                          PAGENTE,
                                          TIPO.VALOR,
                                          PCUENTA);
          V_IS_COMI     := 1;
        ELSIF TIPO.VALOR = 114 THEN
          /*IVA DE COMISIONES = 114 */
          V_CALIMP_COMI_IVA := F_COMISION_SAP(PNRECIBO,
                                              PAGENTE,
                                              TIPO.VALOR,
                                              PCUENTA);
          V_IS_COMI_IVA     := 1;
        END IF;
      END LOOP;
    
      IF V_IS_PRIMA = 1 AND V_IS_IVA = 0 AND V_IS_GASTO = 0 AND
         V_IS_COMI = 0 AND V_IS_COMI_IVA = 0 THEN
        V_RETORNO := V_CALIMP_PRIMA;
      ELSIF V_IS_PRIMA = 0 AND V_IS_IVA = 1 AND V_IS_GASTO = 0 AND
            V_IS_COMI = 0 AND V_IS_COMI_IVA = 0 THEN
        V_RETORNO := V_CALIMP_IVA;
      ELSIF V_IS_PRIMA = 0 AND V_IS_IVA = 0 AND V_IS_GASTO = 1 AND
            V_IS_COMI = 0 AND V_IS_COMI_IVA = 0 THEN
        V_RETORNO := V_CALIMP_GASTO;
      ELSIF V_IS_PRIMA = 0 AND V_IS_IVA = 0 AND V_IS_GASTO = 0 AND
            V_IS_COMI = 1 AND V_IS_COMI_IVA = 0 THEN
        V_RETORNO := V_CALIMP_COMI;
      ELSIF V_IS_PRIMA = 0 AND V_IS_IVA = 0 AND V_IS_GASTO = 0 AND
            V_IS_COMI = 0 AND V_IS_COMI_IVA = 1 THEN
        V_RETORNO := V_CALIMP_COMI_IVA;
      ELSIF V_IS_PRIMA = 1 AND V_IS_IVA = 0 AND V_IS_GASTO = 1 AND
            V_IS_COMI = 0 AND V_IS_COMI_IVA = 0 THEN
        V_RETORNO := V_CALIMP_PRIMA + V_CALIMP_GASTO;
      ELSIF V_IS_PRIMA = 0 AND V_IS_IVA = 0 AND V_IS_GASTO = 0 AND
            V_IS_COMI = 1 AND V_IS_COMI_IVA = 1 THEN
        V_RETORNO := V_CALIMP_COMI + V_CALIMP_COMI_IVA;
      END IF;
      IF C1%ISOPEN THEN
        CLOSE C1;
      END IF;
      RETURN V_RETORNO;
    END F_TIPO_IMPORTE;
  BEGIN
    -- ESCENARIO VF 963
    IF PTTIPPAG = 4 THEN
      -- RECIBOS
      V_RETORNO_1 := F_TIPO_IMPORTE(PTIPO_IMPORTE);
    ELSIF PTTIPPAG = 20 THEN
      -- LIQUIDACI?? CORTE DE CUENTA 
      V_RETORNO_1 := F_TIPO_IMPORTE(PTIPO_IMPORTE);
    ELSIF PTTIPPAG = 21 THEN
      -- CAUSACION COMISION
      V_RETORNO_1 := F_TIPO_IMPORTE(PTIPO_IMPORTE);
    END IF;
  
    RETURN V_RETORNO_1;
  END F_IMPORTES_SAP;

  FUNCTION FF_BUSCASPERSON(P_ESCENARIO IN NUMBER,
                           P_CUENTA    IN NUMBER,
                           P_NRECIBO   IN NUMBER,
                           P_AGENTE    IN NUMBER) RETURN VARCHAR2 IS
    --V_CUENTA VARCHAR2(20);
    V_TIPCUENTA  VARCHAR2(20);
    V_TIPLIQUIDA VARCHAR2(10);
    V_SPERSON    VARCHAR2(30);
    --V_ESCENARIO VARCHAR2(10);
  BEGIN
    -- CUENTA Y TIPO LIQUIDACION
    SELECT TIPO_CUENTA, TIPLIQ
      INTO V_TIPCUENTA, V_TIPLIQUIDA
      FROM TIPO_LIQUIDACION
     WHERE CUENTA = P_CUENTA;
  
    IF (V_TIPLIQUIDA != 41 AND
       P_ESCENARIO IN (213,
                        222,
                        223,
                        227,
                        229,
                        230,
                        237,
                        238,
                        242,
                        244,
                        245,
                        247,
                        254,
                        258,
                        259,
                        260,
                        261,
                        262,
                        333,
                        334,
                        335,
                        336,
                        337,
                        338,
                        339,
                        340,
                        341,
                        342,
                        343,
                        344,
                        345,
                        346,
                        347,
                        348,
                        349,
                        350,
                        351,
                        352,
                        353,
                        354,
                        355,
                        356,
                        357,
                        358,
                        359,
                        360,
                        361,
                        362,
                        217,
                        216)) THEN
      BEGIN
        SELECT DECODE(V_TIPCUENTA, 'D', P.SPERSON_DEUD, P.SPERSON_ACRE)
          INTO V_SPERSON
          FROM PER_PERSONAS P, RECIBOS R, TOMADORES T
         WHERE R.SSEGURO = T.SSEGURO
           AND P.SPERSON = T.SPERSON
           AND R.NRECIBO = P_NRECIBO;
      END;
    
    ELSIF (V_TIPLIQUIDA != 41 AND
          P_ESCENARIO IN (206,
                           207,
                           208,
                           209,
                           210,
                           211,
                           212,
                           215,
                           218,
                           220,
                           225,
                           226,
                           232,
                           235,
                           236,
                           239,
                           240,
                           241,
                           246,
                           248,
                           250,
                           251,
                           252,
                           253,
                           255,
                           255,
                           256,
                           257,
                           263,
                           265,
                           266,
                           205,
                           204,
                           203,
                           202)) THEN
      BEGIN
        SELECT DECODE(V_TIPCUENTA, 'D', P.SPERSON_DEUD, P.SPERSON_ACRE)
          INTO V_SPERSON
          FROM PER_PERSONAS P, AGENTES A, RECIBOS R
         WHERE P.SPERSON = A.SPERSON
           AND A.CAGENTE = P_AGENTE
           AND R.NRECIBO = P_NRECIBO;
      END;
    ELSIF (V_TIPLIQUIDA != 41 AND P_ESCENARIO IN (214, 219, 233, 249)) THEN
      BEGIN
        SELECT DISTINCT DECODE(V_TIPCUENTA,
                               'D',
                               P.SPERSON_DEUD,
                               P.SPERSON_ACRE)
          INTO V_SPERSON
          FROM COMPANIAS C, COACEDIDO B, PER_PERSONAS P, RECIBOS R
         WHERE P.SPERSON = C.SPERSON
           AND C.CCOMPANI = B.CCOMPAN
           AND B.SSEGURO = R.SSEGURO
           AND C.CCOMPANI = P_AGENTE
           AND R.NRECIBO = P_NRECIBO;
      END;
    ELSIF (V_TIPLIQUIDA = 41 AND
          P_ESCENARIO IN
          (223, 233, 230, 238, 245, 259, 261, 345, 346, 347, 348, 349, 350)) THEN
      BEGIN
        SELECT DISTINCT DECODE(V_TIPCUENTA,
                               'D',
                               P.SPERSON_DEUD,
                               P.SPERSON_ACRE)
          INTO V_SPERSON
          FROM COMPANIAS C, COACEDIDO B, PER_PERSONAS P, RECIBOS R
         WHERE P.SPERSON = C.SPERSON
           AND C.CCOMPANI = B.CCOMPAN
           AND B.SSEGURO = R.SSEGURO
           AND C.CCOMPANI = P_AGENTE
           AND R.NRECIBO = P_NRECIBO;
      END;
    END IF;
    RETURN(V_SPERSON);
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'Ff_BuscaSperson',
                  NULL,
                  NULL,
                  'Error Ff_BuscaSperson :P_CUENTA :' || P_CUENTA ||
                  ':P_ESCENARIO :' || P_ESCENARIO || ':P_NRECIBO:' ||
                  P_NRECIBO);
      RETURN(NULL);
  END FF_BUSCASPERSON;

  FUNCTION F_CERTIFIC(PI_SSEGURO IN SEGUROS.SSEGURO%TYPE,
                      PI_NMOVIMI IN NUMBER) RETURN VARCHAR2 IS
    V_CERTIFIC VARCHAR2(20);
    E_PARMS EXCEPTION;
  BEGIN
  
    IF PI_SSEGURO IS NULL OR PI_NMOVIMI IS NULL THEN
      RAISE E_PARMS;
    END IF;
  
    IF PI_SSEGURO IS NOT NULL AND PI_NMOVIMI IS NOT NULL
    
     THEN
    
      SELECT RDM.NCERTDIAN
        INTO V_CERTIFIC
        FROM RANGO_DIAN_MOVSEGURO RDM
       WHERE RDM.SSEGURO = PI_SSEGURO
         AND RDM.NMOVIMI = PI_NMOVIMI;
    
    END IF;
  
    RETURN V_CERTIFIC;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'F_CERTIFIC',
                  NULL,
                  NULL,
                  'Error F_CERTIFIC :');
      RETURN(NULL);
    
  END F_CERTIFIC;

  FUNCTION F_INDICADOR_SAP(PI_CUENTA       NUMBER,
                           PI_TIPO_IMPORTE VARCHAR2,
                           PI_VALOR_IVA    NUMBER,
                           PI_NRECIBO      IN NUMBER,
                           PI_AGENTE       IN NUMBER) RETURN VARCHAR2 IS
    L_APLI_IND    VARCHAR2(10) := NULL;
    L_CTIPIND     NUMBER;
    L_IVACOMISI   NUMBER;
    L_VALOR_IVA_P NUMBER;
    L_AGENTE      NUMBER := 0;
    L_COMPAN      NUMBER := 0;
    L_RESULT      VARCHAR2(10) := NULL;
  
    CURSOR BUSCARTIPO(PTIPO_IMPORTE VARCHAR2) IS
      SELECT REGEXP_SUBSTR(PTIPO_IMPORTE, '[^|]+', 1, LEVEL) VALOR
        FROM DUAL
      CONNECT BY REGEXP_SUBSTR(PTIPO_IMPORTE, '[^|]+', 1, LEVEL) IS NOT NULL;
  
  BEGIN
    SELECT COUNT(*)
      INTO L_AGENTE
      FROM COMRECIBO C
     WHERE C.NRECIBO = PI_NRECIBO
       AND C.CAGENTE = PI_AGENTE;
  
    IF L_AGENTE = 0 THEN
      SELECT COUNT(*)
        INTO L_COMPAN
        FROM COMRECIBO C
       WHERE C.NRECIBO = PI_NRECIBO
         AND C.CCOMPAN = PI_AGENTE;
    END IF;
  
    SELECT C.APLICABLE_INDICA, C.CTIPIND
      INTO L_APLI_IND, L_CTIPIND
      FROM CUENTASSAP C
     WHERE C.CCUENTA = PI_CUENTA;
  
    IF L_AGENTE > 0 THEN
      SELECT NVL(SUM(C.IVACOMISI), 0)
        INTO L_IVACOMISI
        FROM COMRECIBO C
       WHERE C.NRECIBO = PI_NRECIBO
         AND C.CAGENTE = PI_AGENTE
         AND C.CCOMPAN = 0;
    ELSIF L_COMPAN > 0 THEN
      SELECT NVL(SUM(C.IVACOMISI), 0)
        INTO L_IVACOMISI
        FROM COMRECIBO C
       WHERE C.NRECIBO = PI_NRECIBO
         AND C.CCOMPAN = PI_AGENTE;
    END IF;
  
    FOR TIPO IN BUSCARTIPO(PI_TIPO_IMPORTE) LOOP
      IF TIPO.VALOR = '4' AND PI_VALOR_IVA <> 0 THEN
        IF L_APLI_IND = 'SI' THEN
          SELECT T.CCINDID
            INTO L_RESULT
            FROM TIPOS_INDICADORES T
           WHERE T.CTIPIND = L_CTIPIND;
        END IF;
      ELSIF TIPO.VALOR = '11' OR TIPO.VALOR = '114' AND L_IVACOMISI <> 0 THEN
        -- ELSIF PI_TIPO_IMPORTE <> '4' THEN
        IF L_APLI_IND = 'SI' THEN
          SELECT T.CCINDID
            INTO L_RESULT
            FROM TIPOS_INDICADORES T
           WHERE T.CTIPIND = L_CTIPIND;
        END IF;
      ELSIF TIPO.VALOR NOT IN ('4', '11', '114') THEN
        SELECT ITOTIMP
          INTO L_VALOR_IVA_P
          FROM VDETRECIBOS_MONPOL
         WHERE NRECIBO = PI_NRECIBO;
      
        IF L_APLI_IND = 'SI' AND L_VALOR_IVA_P > 0 THEN
          SELECT T.CCINDID
            INTO L_RESULT
            FROM TIPOS_INDICADORES T
           WHERE T.CTIPIND = L_CTIPIND;
        END IF;
      END IF;
    END LOOP;
    RETURN L_RESULT;
  END F_INDICADOR_SAP;

  FUNCTION F_TIPO_AGENTE_SAP(PI_RECIBO NUMBER, PI_SINTERF NUMBER)
    RETURN NUMBER IS
    L_AGENTE  MOVCONTASAP.CAGENTE%TYPE;
    L_TIPOAGE NUMBER;
  BEGIN
    SELECT M.CAGENTE
      INTO L_AGENTE
      FROM MOVCONTASAP M
     WHERE M.SINTERF = PI_SINTERF
       AND M.NRECIBO = PI_RECIBO;
    BEGIN
      SELECT A.CTIPAGE
        INTO L_TIPOAGE
        FROM AGENTES A
       WHERE A.CAGENTE = L_AGENTE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_TIPOAGE := 100;
    END;
    RETURN L_TIPOAGE;
  END F_TIPO_AGENTE_SAP;

  FUNCTION F_INTERMEDIARIO_SAP(PI_RECIBO NUMBER, PI_SINTERF NUMBER)
    RETURN VARCHAR2 IS
    L_AGENTE    MOVCONTASAP.CAGENTE%TYPE;
    L_SEGURO    MOVCONTASAP.SSEGURO%TYPE;
    L_TIPOAGE   NUMBER;
    L_CORRETAJE NUMBER;
    --L_ROWCOUNT  NUMBER;
    L_RESULT VARCHAR2(10);
  BEGIN
    SELECT M.CAGENTE, M.SSEGURO
      INTO L_AGENTE, L_SEGURO
      FROM MOVCONTASAP M
     WHERE M.SINTERF = PI_SINTERF
       AND M.NRECIBO = PI_RECIBO;
  
    BEGIN
      SELECT A.CTIPAGE
        INTO L_TIPOAGE
        FROM AGENTES A
       WHERE A.CAGENTE = L_AGENTE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_TIPOAGE := 100;
    END;
  
    IF L_TIPOAGE IN (4, 5, 6, 7) THEN
      L_CORRETAJE := PAC_CORRETAJE.F_TIENE_CORRETAJE(L_SEGURO, NULL);
      IF L_CORRETAJE = 1 THEN
        L_RESULT := 'AC'; /*AGE_CORRETAJE*/
      ELSE
        L_RESULT := 'A'; /*AGENTE*/
      END IF;
    ELSE
      L_RESULT := 'NO';
    END IF;
    RETURN L_RESULT;
  END F_INTERMEDIARIO_SAP;

  FUNCTION F_AGENTECOM(PI_RECIBO NUMBER, PI_SINTERF NUMBER) RETURN NUMBER IS
    L_AGENTE  MOVCONTASAP.CAGENTE%TYPE;
    L_SEGURO  MOVCONTASAP.SSEGURO%TYPE;
    L_CCOMISI AGENTES.CCOMISI%TYPE;
    L_RAMO    SEGUROS.CRAMO%TYPE;
    L_PRODUCT SEGUROS.SPRODUC%TYPE;
    L_RESULT  COMISIONPROD.PCOMISI%TYPE;
  BEGIN
  
    SELECT M.CAGENTE, M.SSEGURO
      INTO L_AGENTE, L_SEGURO
      FROM MOVCONTASAP M
     WHERE M.SINTERF = PI_SINTERF
       AND M.NRECIBO = PI_RECIBO;
    BEGIN
      SELECT A.CCOMISI
        INTO L_CCOMISI
        FROM AGENTES A
       WHERE A.CAGENTE = L_AGENTE;
    
      SELECT S.CRAMO, S.SPRODUC
        INTO L_RAMO, L_PRODUCT
        FROM SEGUROS S
       WHERE S.SSEGURO = L_SEGURO;
    
      SELECT C.PCOMISI
        INTO L_RESULT
        FROM COMISIONPROD C
       WHERE C.SPRODUC = L_PRODUCT
         AND C.CRAMO = L_RAMO
         AND C.CCOMISI = L_CCOMISI
         AND C.FINIVIG = (SELECT MAX(C1.FINIVIG)
                            FROM COMISIONPROD C1
                           WHERE C1.CMODALI = C.CMODALI
                             AND C1.CCOLECT = C.CCOLECT
                             AND C1.CRAMO = C.CRAMO
                             AND C1.CTIPSEG = C.CTIPSEG
                             AND C1.CCOMISI = C.CCOMISI
                             AND C1.CMODCOM = C.CMODCOM
                             AND C1.NINIALT = C.NINIALT);
    EXCEPTION
      WHEN OTHERS THEN
        L_RESULT := 0;
    END;
    RETURN L_RESULT;
  END F_AGENTECOM;

  FUNCTION F_SUCURSAL_SAP(PI_CUENTA IN VARCHAR2) RETURN VARCHAR2 IS
    L_TIPOLIQ TIPO_LIQUIDACION.TIPLIQ%TYPE;
    --L_TIPOLIQPERMITO NUMBER := 44;
    V_TLIQUID TIPO_LIQUIDACION.TIPLIQ%TYPE;
    L_RESULT  VARCHAR2(2) := 'SI';
  BEGIN
  
    SELECT T.TIPLIQ
      INTO L_TIPOLIQ
      FROM TIPO_LIQUIDACION T
     WHERE T.CUENTA = PI_CUENTA;
    --IAxis 4504 AABC 06/09/2019 Se agrega subtabla con cuentas parametrizadas
    SELECT NVL(pac_subtablas.f_vsubtabla(pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24,
                                                                                                     'USER_BBDD')),
                                         9000022,
                                         3,
                                         1,
                                         PI_CUENTA),
               0)
      INTO V_TLIQUID
      from dual;
    --
    IF V_TLIQUID <> 0 THEN
      L_RESULT := 'SI';
    ELSE
      L_RESULT := 'NO';
    END IF;
    --
    /*IF L_TIPOLIQ = L_TIPOLIQPERMITO THEN
      L_RESULT := 'SI';
    ELSE
      L_RESULT := 'NO';
    END IF;*/
    --IAxis 4504 AABC 06/09/2019 Se agrega subtabla con cuentas parametrizadas
    RETURN L_RESULT;
  END F_SUCURSAL_SAP;

  FUNCTION F_COMISION_SAP(PI_RECIBO NUMBER,
                          PI_AGENTE NUMBER,
                          PI_TIPO   VARCHAR2,
                          PI_CUENTA VARCHAR2) RETURN NUMBER IS
    L_AGENTE   NUMBER := 0;
    L_COMPAN   NUMBER := 0;
    L_CTIPCOA  NUMBER := 0;
    L_COMISION NUMBER := 0;
    L_COM_IVA  NUMBER := 0;
    L_RESULT   NUMBER := 0;
    L_TIPOLIQ  TIPO_LIQUIDACION.TIPLIQ%TYPE;
  
  BEGIN
    SELECT T.TIPLIQ
      INTO L_TIPOLIQ
      FROM TIPO_LIQUIDACION T
     WHERE T.CUENTA = PI_CUENTA;
  
    SELECT COUNT(*)
      INTO L_AGENTE
      FROM COMRECIBO C
     WHERE C.NRECIBO = PI_RECIBO
       AND C.CAGENTE = PI_AGENTE;
  
    IF L_AGENTE = 0 THEN
      SELECT COUNT(*)
        INTO L_COMPAN
        FROM COMRECIBO C
       WHERE C.NRECIBO = PI_RECIBO
         AND C.CCOMPAN = PI_AGENTE;
    END IF;
  
    SELECT DISTINCT M.CTIPCOA
      INTO L_CTIPCOA
      FROM MOVCONTASAP M
     WHERE M.NRECIBO = PI_RECIBO
       AND M.CAGENTE = PI_AGENTE;
  
    IF PI_TIPO = 11 THEN
      /* COMISION */
      IF L_AGENTE > 0 THEN
        SELECT NVL(SUM(C.ICOMBRU_MONCIA), 0)
          INTO L_COMISION
          FROM COMRECIBO C
         WHERE C.NRECIBO = PI_RECIBO
           AND C.CAGENTE = PI_AGENTE
           AND C.CCOMPAN = 0;
      ELSIF L_COMPAN > 0 THEN
        SELECT NVL(SUM(C.ICOMBRU_MONCIA), 0)
          INTO L_COMISION
          FROM COMRECIBO C
         WHERE C.NRECIBO = PI_RECIBO
           AND C.CCOMPAN = PI_AGENTE;
      END IF;
      L_RESULT := L_COMISION;
    
    ELSIF PI_TIPO = 114 THEN
      /* IVA DE COMISION*/
    
      IF L_AGENTE > 0 THEN
        IF L_CTIPCOA IN (1, 2) THEN
          IF L_TIPOLIQ = 44 THEN
            SELECT NVL(SUM(C.IVACOMISI), 0)
              INTO L_COM_IVA
              FROM COMRECIBO C
             WHERE C.NRECIBO = PI_RECIBO
               AND C.CAGENTE = PI_AGENTE;
          
          ELSIF L_TIPOLIQ = 1 THEN
            SELECT NVL(SUM(C.IVACOMISI), 0)
              INTO L_COM_IVA
              FROM COMRECIBO C
             WHERE C.NRECIBO = PI_RECIBO
               AND C.CAGENTE = PI_AGENTE
               AND C.CCOMPAN <> 0;
          END IF;
        ELSE
          SELECT NVL(SUM(C.IVACOMISI), 0) /* NEED TO CHANGE COLUMN ONCE INFORMATION AVAILABLE : IVACOMISI */
            INTO L_COM_IVA
            FROM COMRECIBO C
           WHERE C.NRECIBO = PI_RECIBO
             AND C.CAGENTE = PI_AGENTE;
        END IF;
      ELSIF L_COMPAN > 0 THEN
      
        IF L_TIPOLIQ = 44 THEN
          SELECT NVL(SUM(C.IVACOMISI), 0)
            INTO L_COM_IVA
            FROM COMRECIBO C
           WHERE C.NRECIBO = PI_RECIBO;
        
        ELSIF L_TIPOLIQ = 1 THEN
          SELECT NVL(SUM(C.IVACOMISI), 0)
            INTO L_COM_IVA
            FROM COMRECIBO C
           WHERE C.NRECIBO = PI_RECIBO
             AND C.CCOMPAN <> 0;
        
        ELSE
          SELECT NVL(SUM(C.IVACOMISI), 0)
            INTO L_COM_IVA
            FROM COMRECIBO C
           WHERE C.NRECIBO = PI_RECIBO
             AND C.CCOMPAN = PI_AGENTE;
        END IF;
      
      END IF;
      L_RESULT := L_COM_IVA;
    END IF;
    RETURN L_RESULT;
  END F_COMISION_SAP;

  FUNCTION F_APLICA_BASERET_SAP(PI_CUENTA IN VARCHAR2) RETURN VARCHAR2 IS
    L_TIPOLIQ TIPO_LIQUIDACION.TIPLIQ%TYPE;
    L_RESULT  VARCHAR2(2);
  BEGIN
  
    SELECT T.TIPLIQ
      INTO L_TIPOLIQ
      FROM TIPO_LIQUIDACION T
     WHERE T.CUENTA = PI_CUENTA;
    --IAXIS 4504 AABC 19/09/2019 se ingresa nuevo tipliq 39 para siniestros
    IF L_TIPOLIQ IN (1, 44, 39) THEN
      --IAXIS 4504 AABC 19/09/2019 se ingresa nuevo tipliq 39 para siniestros
      L_RESULT := 'SI';
    ELSE
      L_RESULT := 'NO';
    END IF;
    RETURN L_RESULT;
  END F_APLICA_BASERET_SAP;

  FUNCTION F_BASERET_SAP(PI_RECIBO NUMBER, PI_SINTERF NUMBER, PI_CUENTA NUMBER) RETURN NUMBER IS
    L_AGENTE MOVCONTASAP.CAGENTE%TYPE;
    L_RESULT NUMBER;
    L_ESCENARIO NUMBER(4);
    L_TIPLIQ NUMBER(3);
    --IAXIS 4504 AABC 19/09/2019 se ingresa nuevo tipliq 39 para siniestros
    l_evento VARCHAR2(30);
    --IAXIS 4504 AABC 19/09/2019 se ingresa nuevo tipliq 39 para siniestros
  BEGIN
    --IAXIS 4504 AABC 19/09/2019 SE INGRESA NUEVO TIPLIQ 39 PARA SINIESTROS
    SELECT M.CAGENTE, M.EVENTO, M.CODESCENARIO
      INTO L_AGENTE, L_EVENTO, L_ESCENARIO
      FROM MOVCONTASAP M
     WHERE M.NRECIBO = PI_RECIBO
       AND M.SINTERF = PI_SINTERF;
  
    IF L_AGENTE IS NOT NULL AND l_evento = 'PRODUCCION' THEN
      BEGIN
        IF L_ESCENARIO IN (220,225,235,240,251,256) THEN
               
         SELECT DISTINCT T.TIPLIQ
           INTO L_TIPLIQ
           FROM ESCENARIOSAPVF E, CUENTASSAP C, TIPO_LIQUIDACION T, CONTAB_ASIENT_INTERF I
          WHERE E.CODCUENTA = C.CODCUENTA
            AND T.CUENTA = C.CCUENTA
            AND I.NLINEA = C.LINEA
            AND C.CCUENTA = PI_CUENTA -- RECIBIR COMO PARAMETRO
            AND I.IDPAGO = PI_RECIBO
            AND I.SINTERF = PI_SINTERF
            AND E.CODESCENARIO= L_ESCENARIO;                
        
          IF L_TIPLIQ = 1 THEN 
            
            SELECT SUM(C.ICOMBRU_MONCIA)
              INTO L_RESULT
              FROM COMRECIBO C
             WHERE C.NRECIBO = PI_RECIBO
               AND C.CAGENTE = L_AGENTE
               AND C.CCOMPAN <> 0;
          ELSE 
                
            SELECT SUM(C.ICOMBRU_MONCIA)
              INTO L_RESULT
              FROM COMRECIBO C
             WHERE C.NRECIBO = PI_RECIBO
               AND C.CAGENTE = L_AGENTE;
               
          END IF;              
                      
        ELSE
               
          SELECT SUM(C.ICOMBRU_MONCIA)
            INTO L_RESULT
            FROM COMRECIBO C
           WHERE C.NRECIBO = PI_RECIBO
             AND C.CAGENTE = L_AGENTE;
             
       END IF;
         
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_RESULT := 0;
      END;
    ELSE
      --IAXIS 4555 AABC 28/01/2020 CAMBIO DE PASE DE RETENCION ESCENARIOS 13 Y 38
      IF L_ESCENARIO IN (13 , 38) THEN
         --
         BEGIN
            --
            SELECT SUM(ipago) 
              INTO L_RESULT
              FROM sin_solidaridad_pago 
             WHERE sidepag = PI_RECIBO  
               AND tliquida = 95;
            --
         EXCEPTION WHEN no_data_found THEN
            --
            L_RESULT := 0;
            --   
         END;    
         --
      ELSE
        --   
      BEGIN
        --IAXIS-5194 AABC 13/02/2020 Adicion deducibles
        SELECT sp.isinretpag - nvl(sp.ifranqpag,0)
          INTO L_RESULT
          FROM sin_tramita_pago sp
         WHERE sp.sidepag = PI_RECIBO;
        --IAXIS-5194 AABC 13/02/2020 Adicion deducibles  
      EXCEPTION
        WHEN no_data_found THEN
          --
          L_RESULT := 0;
          --
      END;
         --
      END IF;   
      --IAXIS 4555 AABC 28/01/2020 CAMBIO DE PASE DE RETENCION ESCENARIOS 13 Y 38
    END IF;
    --IAXIS 4504 AABC 19/09/2019 se ingresa nuevo tipliq 39 para siniestros
    RETURN L_RESULT;
  END F_BASERET_SAP;
  --IAXIS 4504 26/09/2019 AABC Validacion de Divisa diferente a cop para siniestros 
  FUNCTION F_APLI_DIVISA_SAP(PI_RECIBO NUMBER) RETURN VARCHAR2 IS
    VCOUNT   NUMBER;
    L_RESULT VARCHAR2(2);
  BEGIN
    --
    SELECT COUNT(SP.SIDEPAG)
      INTO VCOUNT
      FROM SIN_TRAMITA_PAGO SP
     WHERE SP.SIDEPAG = PI_RECIBO;
    --
    IF VCOUNT = 0 THEN
      L_RESULT := 'SI';
    ELSE
      L_RESULT := 'NO';
    END IF;
    RETURN L_RESULT;
  END F_APLI_DIVISA_SAP;
  --IAXIS 4504 26/09/2019 AABC Validacion de Divisa diferente a cop para siniestros 
  PROCEDURE GENERARTRAMA_COD(PI_RECIBO   IN NUMBER,
                             PI_AGENTE   IN NUMBER,
                             PI_SCENARIO IN NUMBER,
                             PI_CUENTA   IN VARCHAR2,
                             PI_TIPPAG   IN NUMBER,
                             PI_COMPAN   IN NUMBER,
                             PO_RESULT   OUT SYS_REFCURSOR) AS
  
    CURSOR DATOSPARASAP(P_RECIBO   NUMBER,
                        P_AGENTE   NUMBER,
                        P_SCENARIO NUMBER) IS
      SELECT *
        FROM MOVCONTASAP M
       WHERE /*M.ESTADO  = 3
              AND*/
       M.CAGENTE = P_AGENTE
       AND M.CODESCENARIO = P_SCENARIO
       AND M.NRECIBO = P_RECIBO;
  
    --L_NOCOASEGURO   NUMBER :=0;
    --L_COASCEDIDO    NUMBER :=1;                            
    --L_COASACEPTADO  NUMBER :=8;  
    L_TIPO_IMPORTE CUENTASSAP.TIPO_IMPORTE%TYPE;
    L_DESCRIP      CUENTASSAP.DESCRIP%TYPE;
    L_IMPORTE      NUMBER := 0;
    L_ICEDNET      VDETRECIBOS_MONPOL.ICEDNET%TYPE;
    L_CCOMPAN      NUMBER := 0;
    L_CTIPREC      RECIBOS.CTIPREC%TYPE;
  
  BEGIN
  
    FOR MOV IN DATOSPARASAP(PI_RECIBO, PI_AGENTE, PI_SCENARIO) LOOP
    
      SELECT C.DESCRIP, C.TIPO_IMPORTE
        INTO L_DESCRIP, L_TIPO_IMPORTE
        FROM CUENTASSAP C
       WHERE C.CCUENTA = PI_CUENTA;
    
      BEGIN
        SELECT COUNT(*)
          INTO L_CCOMPAN
          FROM COACEDIDO C
         WHERE C.CCOMPAN = PI_COMPAN
           AND C.SSEGURO = MOV.SSEGURO;
        IF L_CCOMPAN > 0 THEN
          L_CCOMPAN := 1;
        ELSE
          L_CCOMPAN := 0;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_CCOMPAN := 0;
      END;
    
      BEGIN
        SELECT R.CTIPREC
          INTO L_CTIPREC
          FROM MOVSEGURO MS, RECIBOS R, MOVRECIBO MR
         WHERE MS.SSEGURO = R.SSEGURO
           AND R.NRECIBO = MR.NRECIBO
           AND R.NRECIBO = PI_RECIBO
           AND MS.CMOVSEG = 3
           AND MR.CESTREC = 0;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      IF MOV.CTIPREC NOT IN (9531, 9532) THEN
        IF MOV.CTIPCOA IN (1, 2) AND L_CCOMPAN = 1 THEN
          /* COAS.CEDIDO */
          SELECT V.ICEDNET
            INTO L_ICEDNET
            FROM VDETRECIBOS_MONPOL V
           WHERE V.NRECIBO = PI_RECIBO;
          L_IMPORTE := NVL(PAC_COA.F_IMPCOA_CCOMP(MOV.SSEGURO,
                                                  PI_COMPAN,
                                                  F_SYSDATE,
                                                  L_ICEDNET),
                           0);
        ELSE
          L_IMPORTE := NVL(PAC_CONTA_SAP.F_IMPORTES_SAP(MOV.NRECIBO,
                                                        L_TIPO_IMPORTE,
                                                        PI_TIPPAG,
                                                        PI_AGENTE,
                                                        PI_CUENTA),
                           0);
        END IF;
      
        OPEN PO_RESULT FOR
          SELECT SUBSTR(PI_CUENTA, -4, 4) COLETILLA,
                 L_DESCRIP || '-' || PI_COMPAN DESCRIP,
                 L_IMPORTE IMPORTE,
                 LPAD(NVL(PI_SCENARIO, 0), 3, '0') || LPAD(1000, 4, '0') ||
                 LPAD('COP', 5, '0') || LPAD(0, 2, '0') || LPAD(0, 4, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_CONTAB_TRM(S.SSEGURO, NULL), 0),
                      15,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_CONTAB_TRM(S.SSEGURO, NULL), 0),
                      12,
                      '0') || LPAD(NVL(PAC_CONTAB_CONF.F_MONEDA(PAC_CONTAB_CONF.F_MON_POLIZA(S.SSEGURO)),
                                       0),
                                   12,
                                   '0') || LPAD('WIAXIS', 12, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_TIPO(PI_CUENTA), 'C'), 1, '0') ||
                 LPAD(NVL(PAC_CONTA_SAP.FF_BUSCASPERSON(PI_SCENARIO,
                                                        PI_CUENTA,
                                                        PI_RECIBO,
                                                        PI_COMPAN),
                          0),
                      10,
                      '0') --TERCERO
                 || LPAD(NVL(PAC_CONTAB_CONF.F_PAGADOR_ALT(S.SSEGURO), 0),
                         10,
                         '0') || LPAD(NVL(PAC_CONTA_SAP.F_INDICADOR_SAP(PI_CUENTA,
                                                                        L_TIPO_IMPORTE,
                                                                        L_IMPORTE,
                                                                        PI_RECIBO,
                                                                        PI_COMPAN),
                                          0),
                                      2,
                                      '0') || LPAD(0, 23, '0') ||
                 LPAD(0, 23, '0') || LPAD('Z001', 4, '0') ||
                 LPAD(TO_CHAR(R.FVENCIM, 'YYYY-MM-DD'), 10, '0') ||
                 LPAD(DECODE(LPAD(NVL(PAC_CONTAB_CONF.F_TIPO(PI_CUENTA),
                                      'C'),
                                  1,
                                  '0'),
                             'D',
                             'I',
                             'K',
                             'I',
                             '0'),
                      1,
                      '0') || LPAD(NVL(PAC_IMPUESTOS_CONF.F_INDICADOR_AGENTE(R.CAGENTE,
                                                                             1,
                                                                             SYSDATE),
                                       0),
                                   2,
                                   '0') || LPAD(0, 2, '0') ||
                 LPAD(0, 23, '0') || LPAD(0, 23, '0') ||
                 LPAD(R.NRECIBO, 18, '0') || LPAD(0, 10, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_SEGMENTO(S.SSEGURO), 0),
                      10,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_DIVISION(S.SSEGURO, S.CAGENTE),
                          0),
                      4,
                      '0') ||
                 LPAD(PAC_CONTAB_CONF.F_PERSONA(T.SPERSON, NULL, NULL, NULL),
                      12,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_ZZFIPOLIZA(S.SSEGURO), 0),
                      20,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_REGION(NULL, S.CAGENTE), 0),
                      2,
                      '0') ||
                 LPAD(NVL(FF_BUSCADATOSSAP(9, S.SSEGURO), 0), 18, '0') ||
                 LPAD(0, 15, '0') ||
                 LPAD(NVL(PAC_CONTA_SAP.F_CERTIFIC(S.SSEGURO, MOV.NMOVIMI),
                          0),
                      10,
                      '0') || LPAD(0, 1, '0') || LPAD(0, 17, '0') OTROS,
                 GREATEST(R.FEFECTO, TRUNC(M.FEFEADM)) FECHA
            FROM RECIBOS R, SEGUROS S, TOMADORES T, MOVRECIBO M
           WHERE T.SSEGURO = S.SSEGURO
             AND M.NRECIBO = R.NRECIBO
             AND M.CESTREC = 0
             AND M.CESTANT = 0
             AND S.SSEGURO = R.SSEGURO
             AND R.CTIPCOA = MOV.CTIPCOA
             AND R.CTIPREC = DECODE(SUBSTR(MOV.CTIPREC, -4, 4),
                                    9032,
                                    L_CTIPREC,
                                    SUBSTR(MOV.CTIPREC, -4, 1))
             AND R.NRECIBO = MOV.NRECIBO;
      ELSE
        -- CANCELLATION                             
        L_IMPORTE := PAC_CONTA_SAP.F_IMPORTES_CAN_SAP(MOV.NRECIBO,
                                                      L_TIPO_IMPORTE,
                                                      PI_SCENARIO,
                                                      PI_AGENTE,
                                                      PI_CUENTA);
      
        OPEN PO_RESULT FOR
          SELECT SUBSTR(PI_CUENTA, -4, 4) COLETILLA,
                 L_DESCRIP || '-' || PI_AGENTE DESCRIP,
                 L_IMPORTE IMPORTE,
                 LPAD(NVL(PI_SCENARIO, 0), 3, '0') || LPAD(1000, 4, '0') ||
                 LPAD('COP', 5, '0') || LPAD(0, 2, '0') || LPAD(0, 4, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_CONTAB_TRM(S.SSEGURO, NULL), 0),
                      15,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_CONTAB_TRM(S.SSEGURO, NULL), 0),
                      12,
                      '0') || LPAD(NVL(PAC_CONTAB_CONF.F_MONEDA(PAC_CONTAB_CONF.F_MON_POLIZA(S.SSEGURO)),
                                       0),
                                   12,
                                   '0') || LPAD('WIAXIS', 12, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_TIPO(PI_CUENTA), 'C'), 1, '0') ||
                 LPAD(NVL(PAC_CONTA_SAP.FF_BUSCASPERSON(PI_SCENARIO,
                                                        PI_CUENTA,
                                                        PI_RECIBO,
                                                        PI_AGENTE),
                          0),
                      10,
                      '0') --TERCERO
                 || LPAD(NVL(PAC_CONTAB_CONF.F_PAGADOR_ALT(S.SSEGURO), 0),
                         10,
                         '0') || LPAD(NVL(PAC_CONTA_SAP.F_INDICADOR_SAP(PI_CUENTA,
                                                                        L_TIPO_IMPORTE,
                                                                        L_IMPORTE,
                                                                        PI_RECIBO,
                                                                        PI_AGENTE),
                                          0),
                                      2,
                                      '0') || LPAD(0, 23, '0') ||
                 LPAD(0, 23, '0') || LPAD('Z001', 4, '0') ||
                 LPAD(TO_CHAR(R.FVENCIM, 'YYYY-MM-DD'), 10, '0') ||
                 LPAD(DECODE(LPAD(NVL(PAC_CONTAB_CONF.F_TIPO(PI_CUENTA),
                                      'C'),
                                  1,
                                  '0'),
                             'D',
                             'I',
                             'K',
                             'I',
                             '0'),
                      1,
                      '0') || LPAD(NVL(PAC_IMPUESTOS_CONF.F_INDICADOR_AGENTE(R.CAGENTE,
                                                                             1,
                                                                             SYSDATE),
                                       0),
                                   2,
                                   '0') || LPAD(0, 2, '0') ||
                 LPAD(0, 23, '0') || LPAD(0, 23, '0') ||
                 LPAD(R.NRECIBO, 18, '0') || LPAD(0, 10, '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_SEGMENTO(S.SSEGURO), 0),
                      10,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_DIVISION(S.SSEGURO, S.CAGENTE),
                          0),
                      4,
                      '0') ||
                 LPAD(PAC_CONTAB_CONF.F_PERSONA(T.SPERSON, NULL, NULL, NULL),
                      12,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_ZZFIPOLIZA(S.SSEGURO), 0),
                      20,
                      '0') ||
                 LPAD(NVL(PAC_CONTAB_CONF.F_REGION(NULL, S.CAGENTE), 0),
                      2,
                      '0') ||
                 LPAD(NVL(FF_BUSCADATOSSAP(9, S.SSEGURO), 0), 18, '0') ||
                 LPAD(0, 15, '0') ||
                 LPAD(NVL(PAC_CONTA_SAP.F_CERTIFIC(S.SSEGURO, MOV.NMOVIMI),
                          0),
                      10,
                      '0') || LPAD(0, 1, '0') || LPAD(0, 17, '0') OTROS,
                 GREATEST(R.FEFECTO, TRUNC(M.FEFEADM)) FECHA
            FROM RECIBOS R, SEGUROS S, TOMADORES T, MOVRECIBO M
           WHERE T.SSEGURO = S.SSEGURO
             AND M.NRECIBO = R.NRECIBO
             AND M.CMOTMOV = 321
             AND M.CESTANT = 0
             AND S.SSEGURO = R.SSEGURO
             AND R.CTIPCOA = MOV.CTIPCOA
             AND R.NRECIBO = MOV.NRECIBO;
      END IF;
    END LOOP;
  
  END GENERARTRAMA_COD;

  FUNCTION F_DIVISON_SAP(PI_RECIBO NUMBER, PI_SINTERF NUMBER) RETURN VARCHAR2 IS
    L_AGENTE       MOVCONTASAP.CAGENTE%TYPE;
    L_AGENTE_PADRE AGE_PARAGENTES.CAGENTE%TYPE;
    L_RESULT       AGE_PARAGENTES.TVALPAR%TYPE;
    --Iaxis 4504 AABC 10/09/2019 Ajustes para la contabilidad diferente a Produccion 
    L_EVENTO  MOVCONTASAP.EVENTO%TYPE;
    V_EVENTO  VARCHAR2(30) := 'PRODUCCION';
    L_SSEGURO MOVCONTASAP.SSEGURO%TYPE;
    V_CAGENTE MOVCONTASAP.CAGENTE%TYPE;
    --Iaxis 4504 AABC 10/09/2019 Ajustes para la contabilidad diferente a Produccion 
  BEGIN
    SELECT M.CAGENTE, M.EVENTO, M.SSEGURO
      INTO L_AGENTE, L_EVENTO, L_SSEGURO
      FROM MOVCONTASAP M
     WHERE M.NRECIBO = PI_RECIBO
       AND M.SINTERF = PI_SINTERF;
    --Iaxis 4504 AABC 10/09/2019 Ajustes para la contabilidad diferente a Produccion   
    IF L_EVENTO = V_EVENTO THEN
      -- 
      SELECT NVL(PAC_REDCOMERCIAL.F_BUSCA_PADRE(24, CAGENTE, NULL, NULL), 0)
        INTO L_AGENTE_PADRE
        FROM AGENTES A
       WHERE A.CAGENTE = L_AGENTE;
      BEGIN
        -- 
        SELECT A.TVALPAR
          INTO L_RESULT
          FROM AGE_PARAGENTES A
         WHERE A.CAGENTE = L_AGENTE_PADRE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_RESULT := NULL;
      END;
    ELSE
      --
      SELECT S.CAGENTE
        INTO V_CAGENTE
        FROM SEGUROS S
       WHERE S.SSEGURO = L_SSEGURO;
      --  
      L_RESULT := pac_contab_conf.f_division(L_SSEGURO, V_CAGENTE);
      --
    END IF;
    --Iaxis 4504 AABC 10/09/2019 Ajustes para la contabilidad diferente a Produccion       
    RETURN L_RESULT;
  
  END F_DIVISON_SAP;

  PROCEDURE MOVCONTA_SCENARIO(PI_SSEGURO IN NUMBER, PI_CMOTMOV IN NUMBER) IS
    P_AGENTE      NUMBER;
    P_NMOVIMI     NUMBER;
    P_TIPCOA      NUMBER;
    P_TIPREC      NUMBER;
    P_EVENTO      VARCHAR2(20) := 'PRODUCCION';
    P_RECIBO      NUMBER;
    P_VALORTIPREC VARCHAR2(4);
    P_PASEXEC     NUMBER(8) := 0;
  
    X_ESTADO_RECAUDO NUMBER := 0;
    X_CON_RECAUDO    VARCHAR2(5) := 'NO';
    X_VAL_IMPORTE    NUMBER := 0;
  BEGIN
    P_PASEXEC := 1;
  
    BEGIN
      SELECT NRECIBO, CAGENTE, NMOVIMI, CTIPCOA, CTIPREC
        INTO P_RECIBO, P_AGENTE, P_NMOVIMI, P_TIPCOA, P_TIPREC
        FROM RECIBOS
       WHERE SSEGURO = PI_SSEGURO;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        SELECT NRECIBO, CAGENTE, NMOVIMI, CTIPCOA, CTIPREC
          INTO P_RECIBO, P_AGENTE, P_NMOVIMI, P_TIPCOA, P_TIPREC
          FROM RECIBOS
         WHERE SSEGURO = PI_SSEGURO
           AND NMOVIMI = 1;
    END;
    P_PASEXEC := 2;
  
    IF P_TIPCOA = 0 THEN
    
      X_ESTADO_RECAUDO := F_ESTREC(P_RECIBO);
    
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'X_ESTADO_RECAUDO:' || P_RECIBO,
                  X_ESTADO_RECAUDO,
                  SQLCODE,
                  SQLERRM);
    
      --IF X_ESTADO_RECAUDO = 0 THEN
    
      SELECT PAC_ADM_COBPARCIAL.F_GET_IMPORTE_COBRO_PARCIAL(P_RECIBO)
        INTO X_VAL_IMPORTE
        FROM DUAL;
    
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'X_VAL_IMPORTE:' || P_RECIBO,
                  X_VAL_IMPORTE,
                  SQLCODE,
                  SQLERRM);
    
      IF (X_VAL_IMPORTE > 0) THEN
        X_CON_RECAUDO := 'SI';
      ELSE
        X_CON_RECAUDO := 'NO';
      END IF;
      --END IF;
      P_PASEXEC := 3;
    
      IF X_CON_RECAUDO = 'SI' THEN
        P_VALORTIPREC := '9532'; -- CON RECAUDO
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           CTIPCOA,
           CTIPREC,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (P_RECIBO,
           P_AGENTE,
           P_NMOVIMI,
           PI_SSEGURO,
           P_TIPCOA,
           P_VALORTIPREC,
           P_EVENTO,
           SYSDATE);
      ELSE
        P_VALORTIPREC := '9531'; -- SIN RECAUDO
        INSERT INTO MOVCONTASAP
          (NRECIBO,
           CAGENTE,
           NMOVIMI,
           SSEGURO,
           CTIPCOA,
           CTIPREC,
           EVENTO,
           FECHA_SOLICITUD)
        VALUES
          (P_RECIBO,
           P_AGENTE,
           P_NMOVIMI,
           PI_SSEGURO,
           P_TIPCOA,
           P_VALORTIPREC,
           P_EVENTO,
           SYSDATE);
      END IF;
      P_PASEXEC := 4;
      COMMIT;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'TRG_INS_MOVCONTASAPDET:MOVCONTA_SCENARIO',
                  P_PASEXEC,
                  SQLCODE,
                  SQLERRM);
    
  END MOVCONTA_SCENARIO;

  PROCEDURE ANULA_SCENARIO(PI_CAGENTE    IN NUMBER,
                           PI_SCENARIO_N IN NUMBER,
                           PI_SCENARIO_A IN NUMBER,
                           PI_RECIBO     IN NUMBER,
                           PI_UNIQUE     VARCHAR2,
                           PI_SINTERF    IN NUMBER) IS
    X_ESTADO_P NUMBER := 3;
    P_PASEXEC  NUMBER(8) := 0;
  
  BEGIN
    P_PASEXEC := 1;
    IF PI_SCENARIO_N = 214 AND PI_SCENARIO_A = 219 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 2;
    ELSIF PI_SCENARIO_N = 251 AND PI_SCENARIO_A = 235 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE;
      COMMIT;
    
      P_PASEXEC := 3;
    ELSIF PI_SCENARIO_N = 252 AND PI_SCENARIO_A = 236 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 4;
    ELSIF PI_SCENARIO_N = 253 AND PI_SCENARIO_A = 246 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE;
      COMMIT;
    
      P_PASEXEC := 5;
    ELSIF PI_SCENARIO_N = 263 AND PI_SCENARIO_A = 211 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 6;
    ELSIF PI_SCENARIO_N = 265 AND PI_SCENARIO_A = 208 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 8;
    ELSIF PI_SCENARIO_N = 336 AND PI_SCENARIO_A = 340 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 9;
    ELSIF PI_SCENARIO_N = 354 AND PI_SCENARIO_A = 362 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 10;
    ELSIF PI_SCENARIO_N = 248 AND PI_SCENARIO_A = 232 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 11;
    ELSIF PI_SCENARIO_N = 249 AND PI_SCENARIO_A = 233 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 12;
    ELSIF PI_SCENARIO_N = 255 AND PI_SCENARIO_A = 239 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 13;
    ELSIF PI_SCENARIO_N = 256 AND PI_SCENARIO_A = 240 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 14;
    ELSIF PI_SCENARIO_N = 257 AND PI_SCENARIO_A = 241 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 15;
    ELSIF PI_SCENARIO_N = 266 AND PI_SCENARIO_A = 209 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 16;
    ELSIF PI_SCENARIO_N = 335 AND PI_SCENARIO_A = 339 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
      P_PASEXEC := 17;
    ELSIF PI_SCENARIO_N = 353 AND PI_SCENARIO_A = 361 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_A
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'ANULA_SCENARIO',
                  P_PASEXEC,
                  SQLCODE,
                  SQLERRM);
    
  END ANULA_SCENARIO;

  FUNCTION F_IMPORTES_CAN_SAP(PNRECIBO      NUMBER,
                              PTIPO_IMPORTE VARCHAR2,
                              PI_SCENARIO   NUMBER,
                              PAGENTE       NUMBER,
                              PCUENTA       VARCHAR2) RETURN NUMBER IS
  
    VIMPORTE      NUMBER;
    VPRIMA_OLD    VDETRECIBOS_MONPOL.IPRINET%TYPE := 0;
    VIVA_OLD      VDETRECIBOS_MONPOL.ITOTIMP%TYPE := 0;
    VGASTO_OLD    VDETRECIBOS_MONPOL.ITOTREC%TYPE := 0;
    VPRIMA_NEW    VDETRECIBOS_MONPOL.IPRINET%TYPE := 0;
    VIVA_NEW      VDETRECIBOS_MONPOL.ITOTIMP%TYPE := 0;
    VGASTO_NEW    VDETRECIBOS_MONPOL.ITOTREC%TYPE := 0;
    VCOMISION     COMRECIBO.ICOMDEV_MONCIA%TYPE := 0;
    VIVA_COMISION COMRECIBO.IVACOMISI%TYPE := 0;
  
    VPRIMA_CAL        VDETRECIBOS_MONPOL.IPRINET%TYPE := 0;
    VIVA_CAL          VDETRECIBOS_MONPOL.ITOTIMP%TYPE := 0;
    VGASTO_CAL        VDETRECIBOS_MONPOL.ITOTREC%TYPE := 0;
    VCOMISION_CAL     COMRECIBO.ICOMDEV_MONCIA%TYPE := 0;
    VIVA_COMISION_CAL COMRECIBO.IVACOMISI%TYPE := 0;
    VTIPOLIQ          tipo_liquidacion.tipliq%type;
  
    VOPTION_P   NUMBER := 0;
    VOPTION_I   NUMBER := 0;
    VOPTION_G   NUMBER := 0;
    VOPTION_C   NUMBER := 0;
    VOPTION_I_C NUMBER := 0;
  
    CURSOR BUSCAR_TIPO(PTIPO_IMPORTE VARCHAR2) IS
      SELECT REGEXP_SUBSTR(PTIPO_IMPORTE, '[^|]+', 1, LEVEL) VALOR
        FROM DUAL
      CONNECT BY REGEXP_SUBSTR(PTIPO_IMPORTE, '[^|]+', 1, LEVEL) IS NOT NULL;
  
  BEGIN
  
    SELECT T.TIPLIQ
      INTO VTIPOLIQ
      FROM TIPO_LIQUIDACION T
     WHERE T.CUENTA = PCUENTA;
  
    SELECT IPRINET, ITOTIMP, ITOTREC
      INTO VPRIMA_OLD, VIVA_OLD, VGASTO_OLD
      FROM VDETRECIBOS_MONPOL V
     WHERE V.NRECIBO = PNRECIBO;
  
    FOR TIPO IN BUSCAR_TIPO(PTIPO_IMPORTE) LOOP
      IF TIPO.VALOR = 0 THEN
        /*PRIMA*/
        VOPTION_P := 1;
        SELECT NVL(SUM(D.ICONCEP_MONPOL), 0)
          INTO VPRIMA_NEW
          FROM DETMOVRECIBO_PARCIAL D
         WHERE D.NRECIBO = PNRECIBO
           AND D.CCONCEP = TIPO.VALOR;
      ELSIF TIPO.VALOR = 4 THEN
        /*IMPUESTOS (IVA)*/
        VOPTION_I := 1;
        SELECT NVL(SUM(D.ICONCEP_MONPOL), 0)
          INTO VIVA_NEW
          FROM DETMOVRECIBO_PARCIAL D
         WHERE D.NRECIBO = PNRECIBO
           AND D.CCONCEP = TIPO.VALOR;
      ELSIF TIPO.VALOR = 8 THEN
        /*GASTOS*/
        VOPTION_G  := 1;
        VGASTO_NEW := 0;
      ELSIF TIPO.VALOR = 11 THEN
        /*COMISIONES*/
        VOPTION_C := 1;
        SELECT NVL(SUM(C.ICOMDEV_MONCIA), 0)
          INTO VCOMISION
          FROM COMRECIBO C
         WHERE C.NRECIBO = PNRECIBO
           AND C.CAGENTE = PAGENTE;
      
      ELSIF TIPO.VALOR = 114 THEN
        /*IVA DE COMISIONES*/
        VOPTION_I_C := 1;
        SELECT NVL(SUM(C.IVACOMISI), 0)
          INTO VIVA_COMISION
          FROM COMRECIBO C
         WHERE C.NRECIBO = PNRECIBO
           AND C.CAGENTE = PAGENTE;
      END IF;
    END LOOP;
  
    IF PI_SCENARIO IN (216) THEN
      IF VOPTION_P = 1 THEN
        VPRIMA_CAL := VPRIMA_OLD - VPRIMA_NEW;
      END IF;
      IF VOPTION_I = 1 THEN
        VIVA_CAL := VIVA_OLD - VIVA_NEW;
      END IF;
      IF VOPTION_G = 1 THEN
        VGASTO_CAL := VGASTO_OLD;
      END IF;
    ELSIF PI_SCENARIO IN (217, 205) THEN
      IF VOPTION_P = 1 THEN
        VPRIMA_CAL := VPRIMA_NEW;
      END IF;
      IF VOPTION_I = 1 THEN
        VIVA_CAL := VIVA_NEW;
      END IF;
      IF VOPTION_G = 1 THEN
        VGASTO_CAL := VGASTO_NEW; /* SIEMPRE ZERO */
      END IF;
    ELSIF PI_SCENARIO IN (202) THEN
      IF VOPTION_C = 1 THEN
        VCOMISION_CAL := VCOMISION;
      END IF;
      IF VOPTION_I_C = 1 THEN
        VIVA_COMISION_CAL := VIVA_COMISION;
      END IF;
    ELSIF PI_SCENARIO IN (203) THEN
      IF VOPTION_C = 1 THEN
        VCOMISION_CAL := VCOMISION;
      END IF;
      IF VOPTION_I_C = 1 THEN
        VIVA_COMISION_CAL := 0; /* SIEMPRE ZERO */
      END IF;
    ELSIF PI_SCENARIO IN (204) THEN
      /* Con Recaudo : Es casi igual de 216 pero vas a pruebar cuando funciona Con Recaudo */
      IF VOPTION_P = 1 THEN
        VPRIMA_CAL := VPRIMA_OLD - VPRIMA_NEW;
      END IF;
      IF VOPTION_I = 1 THEN
        VIVA_CAL := VIVA_OLD - VIVA_NEW;
      END IF;
      IF VOPTION_G = 1 THEN
        VGASTO_CAL := VGASTO_OLD;
      END IF;
    END IF;
  
    IF VOPTION_P = 1 AND VOPTION_I = 0 AND VOPTION_G = 0 AND VOPTION_C = 0 AND
       VOPTION_I_C = 0 THEN
      VIMPORTE := VPRIMA_CAL;
    ELSIF VOPTION_P = 0 AND VOPTION_I = 1 AND VOPTION_G = 0 AND
          VOPTION_C = 0 AND VOPTION_I_C = 0 THEN
      VIMPORTE := VIVA_CAL;
    ELSIF VOPTION_P = 0 AND VOPTION_I = 0 AND VOPTION_G = 1 AND
          VOPTION_C = 0 AND VOPTION_I_C = 0 THEN
      VIMPORTE := VGASTO_CAL;
    ELSIF VOPTION_P = 0 AND VOPTION_I = 0 AND VOPTION_G = 0 AND
          VOPTION_C = 1 AND VOPTION_I_C = 0 THEN
      VIMPORTE := VCOMISION_CAL;
    ELSIF VOPTION_P = 0 AND VOPTION_I = 0 AND VOPTION_G = 0 AND
          VOPTION_C = 0 AND VOPTION_I_C = 1 THEN
      VIMPORTE := VIVA_COMISION_CAL;
    ELSIF VOPTION_P = 1 AND VOPTION_I = 0 AND VOPTION_G = 1 AND
          VOPTION_C = 0 AND VOPTION_I_C = 0 THEN
      VIMPORTE := VPRIMA_CAL + VGASTO_CAL;
    ELSIF VOPTION_P = 0 AND VOPTION_I = 0 AND VOPTION_G = 0 AND
          VOPTION_C = 1 AND VOPTION_I_C = 1 THEN
      VIMPORTE := VCOMISION_CAL + VIVA_COMISION_CAL;
    END IF;
  
    RETURN VIMPORTE;
  END F_IMPORTES_CAN_SAP;

  PROCEDURE MOVCONTA_SCENARIO_ANULA(PI_NRECIBO IN NUMBER,
                                    PI_CMOTMOV IN NUMBER,
                                    PI_CESTREC IN NUMBER) IS
    P_AGENTE      NUMBER;
    P_NMOVIMI     NUMBER;
    P_SSEGURO     NUMBER;
    P_TIPCOA      NUMBER;
    P_TIPREC      NUMBER;
    P_EVENTO      VARCHAR2(20) := 'PRODUCCION';
    P_VALORTIPREC VARCHAR2(4);
    P_PASEXEC     NUMBER(8) := 0;
  
  BEGIN
    P_PASEXEC := 1;
    IF PI_CESTREC = 2 THEN
      SELECT CAGENTE, NMOVIMI, CTIPCOA, CTIPREC, SSEGURO
        INTO P_AGENTE, P_NMOVIMI, P_TIPCOA, P_TIPREC, P_SSEGURO
        FROM RECIBOS
       WHERE NRECIBO = PI_NRECIBO;
    
      IF PI_CMOTMOV = 52 THEN
        IF P_TIPREC = 1 THEN
          P_VALORTIPREC := '1522'; --ANULACION SUPLEMENTO POSITIVO SIN RECAUDO
          INSERT INTO MOVCONTASAP
            (NRECIBO, CAGENTE, NMOVIMI, SSEGURO, CTIPCOA, CTIPREC, EVENTO)
          VALUES
            (PI_NRECIBO,
             P_AGENTE,
             P_NMOVIMI,
             P_SSEGURO,
             P_TIPCOA,
             P_VALORTIPREC,
             P_EVENTO);
        
        ELSIF P_TIPREC = 9 THEN
          P_VALORTIPREC := '9522'; --ANULACION SUPLEMENTO NEGATIVO SIN RECAUDO
          INSERT INTO MOVCONTASAP
            (NRECIBO, CAGENTE, NMOVIMI, SSEGURO, CTIPCOA, CTIPREC, EVENTO)
          VALUES
            (PI_NRECIBO,
             P_AGENTE,
             P_NMOVIMI,
             P_SSEGURO,
             P_TIPCOA,
             P_VALORTIPREC,
             P_EVENTO);
        END IF;
        P_PASEXEC := 2;
      
      ELSIF PI_CMOTMOV = 306 THEN
        IF P_TIPREC = 0 THEN
          P_VALORTIPREC := '9032'; -- ANULACION TOTAL SIN RECAUDO
          INSERT INTO MOVCONTASAP
            (NRECIBO, CAGENTE, NMOVIMI, SSEGURO, CTIPCOA, CTIPREC, EVENTO)
          VALUES
            (PI_NRECIBO,
             P_AGENTE,
             P_NMOVIMI,
             P_SSEGURO,
             P_TIPCOA,
             P_VALORTIPREC,
             P_EVENTO);
        
        ELSIF P_TIPREC = 1 THEN
          P_VALORTIPREC := '1522'; --ANUL. SUPL. POSITIVO SIN RECAUDO CON BAJA AL EFECTO
          INSERT INTO MOVCONTASAP
            (NRECIBO, CAGENTE, NMOVIMI, SSEGURO, CTIPCOA, CTIPREC, EVENTO)
          VALUES
            (PI_NRECIBO,
             P_AGENTE,
             P_NMOVIMI,
             P_SSEGURO,
             P_TIPCOA,
             P_VALORTIPREC,
             P_EVENTO);
        
        ELSIF P_TIPREC = 9 THEN
          P_VALORTIPREC := '9522'; --ANUL. SUPL. NEGATIVO SIN RECAUDO CON BAJA AL EFECTO
          INSERT INTO MOVCONTASAP
            (NRECIBO, CAGENTE, NMOVIMI, SSEGURO, CTIPCOA, CTIPREC, EVENTO)
          VALUES
            (PI_NRECIBO,
             P_AGENTE,
             P_NMOVIMI,
             P_SSEGURO,
             P_TIPCOA,
             P_VALORTIPREC,
             P_EVENTO);
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'TRG_INS_MOVCONTASAP_ANULA:MOVCONTA',
                  P_PASEXEC,
                  SQLCODE,
                  SQLERRM);
  END MOVCONTA_SCENARIO_ANULA;

  PROCEDURE CALCELACION_SCENARIO(PI_CAGENTE    IN NUMBER,
                                 PI_SCENARIO_N IN NUMBER,
                                 PI_SCENARIO_C IN NUMBER,
                                 PI_RECIBO     IN NUMBER,
                                 PI_UNIQUE     VARCHAR2,
                                 PI_SINTERF    IN NUMBER) IS
    X_ESTADO_P NUMBER := 3;
    X_PASEXEC  NUMBER(8) := 0;
  
  BEGIN
    X_PASEXEC := 1;
    IF PI_SCENARIO_N = 255 AND PI_SCENARIO_C = 203 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_C
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
      X_PASEXEC := 2;
    ELSIF PI_SCENARIO_N = 256 AND PI_SCENARIO_C = 202 THEN
      UPDATE MOVCONTASAP M
         SET M.NUMUNICO_SAP = PI_UNIQUE
       WHERE M.ESTADO = X_ESTADO_P
         AND M.CODESCENARIO = PI_SCENARIO_C
         AND M.NRECIBO = PI_RECIBO
         AND M.CAGENTE = PI_CAGENTE
         AND M.SINTERF = PI_SINTERF;
      COMMIT;
    END IF;
    X_PASEXEC := 3;
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'CALCELACION_SCENARIO',
                  X_PASEXEC,
                  SQLCODE,
                  SQLERRM);
  END CALCELACION_SCENARIO;

  PROCEDURE MOVCONTASAP_ANULA_REC(PI_SSEGURO IN NUMBER,
                                  PI_NMOVIMI IN NUMBER) IS
    P_AGENTE      NUMBER;
    P_NMOVIMI     NUMBER;
    P_TIPCOA      NUMBER;
    P_TIPREC      NUMBER;
	P_CSUBTIPREC  NUMBER;
    P_EVENTO      VARCHAR2(20) := 'PRODUCCION';
    P_RECIBO      NUMBER;
    P_VALORTIPREC VARCHAR2(4);
    P_PASEXEC     NUMBER(8) := 0;
  
  BEGIN
    P_PASEXEC := 1;
  
    BEGIN
      SELECT NRECIBO, CAGENTE, NMOVIMI, CTIPCOA, CTIPREC, CSUBTIPREC 
        INTO P_RECIBO, P_AGENTE, P_NMOVIMI, P_TIPCOA, P_TIPREC, P_CSUBTIPREC
        FROM RECIBOS
       WHERE SSEGURO IN (PI_SSEGURO)
         AND NMOVIMI = PI_NMOVIMI
         AND FEMISIO IN (SELECT MAX(R.FEMISIO)
                           FROM RECIBOS R
                          WHERE R.SSEGURO IN (PI_SSEGURO)
                            AND R.NMOVIMI = PI_NMOVIMI);
    END;
    P_PASEXEC := 2;
  
    IF P_TIPREC = 9 AND P_CSUBTIPREC = 8 THEN
      P_VALORTIPREC := '9521'; -- CON NEGATIVO RECAUDO
      INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         CTIPCOA,
         CTIPREC,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (P_RECIBO,
         P_AGENTE,
         P_NMOVIMI,
         PI_SSEGURO,
         P_TIPCOA,
         P_VALORTIPREC,
         P_EVENTO,
         SYSDATE);
    
      P_PASEXEC := 3;
    ELSIF P_TIPREC = 1 AND P_CSUBTIPREC = 8 THEN
      P_VALORTIPREC := '1521'; -- CON RECAUDO POSITIVO
      INSERT INTO MOVCONTASAP
        (NRECIBO,
         CAGENTE,
         NMOVIMI,
         SSEGURO,
         CTIPCOA,
         CTIPREC,
         EVENTO,
         FECHA_SOLICITUD)
      VALUES
        (P_RECIBO,
         P_AGENTE,
         P_NMOVIMI,
         PI_SSEGURO,
         P_TIPCOA,
         P_VALORTIPREC,
         P_EVENTO,
         SYSDATE);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'TRG_INS_MOVCONTASAPDET_ANULA_REC:MOVCONTA',
                  P_PASEXEC,
                  'RECIBO :' || '' || P_RECIBO || '' || 'NMOVIMI :' || '' ||
                  P_NMOVIMI || '' || 'CTIPREC :' || '' || P_TIPREC,
                  SQLERRM);
    
  END MOVCONTASAP_ANULA_REC;

  PROCEDURE ELIMINA_SCENARIO(PI_RECIBO  IN NUMBER,
                             PI_CAGENTE IN NUMBER,
                             PI_NMOVIMI IN NUMBER,
                             PI_SSEGURO IN NUMBER,
                             PI_RAMO    IN NUMBER,
                             PI_CTIPCOA IN NUMBER,
                             PI_CTIPREC IN VARCHAR2) IS
  
    X_ESTADO_I NUMBER := 2;
    P_PASEXEC  NUMBER(8) := 0;
  
  BEGIN
  
    P_PASEXEC := 1;
  
    DELETE FROM MOVCONTASAP
     WHERE NRECIBO = PI_RECIBO
       AND CAGENTE = PI_CAGENTE
       AND NMOVIMI = PI_NMOVIMI
       AND SSEGURO = PI_SSEGURO
       AND RAMO = PI_RAMO
       AND CTIPCOA = PI_CTIPCOA
       AND CTIPREC = PI_CTIPREC
       AND ESTADO = X_ESTADO_I
       AND SINTERF IS NULL
       AND CODESCENARIO IN (206,
                            207,
                            208,
                            209,
                            210,
                            211,
                            212,
                            214,
                            215,
                            218,
                            219,
                            220,
                            225,
                            226,
                            232,
                            233,
                            235,
                            236,
                            239,
                            240,
                            241,
                            246,
                            248,
                            249,
                            250,
                            251,
                            252,
                            253,
                            255,
                            256,
                            257,
                            263,
                            265,
                            266);
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'ELIMINA_SCENARIO' || '-' || PI_RECIBO,
                  P_PASEXEC,
                  SQLCODE,
                  SQLERRM);
    
  END ELIMINA_SCENARIO;

  FUNCTION F_SUCURSAL_PROD(PI_CUENTA IN VARCHAR2) RETURN VARCHAR2 IS
    L_TIPOLIQ        TIPO_LIQUIDACION.TIPLIQ%TYPE;
    L_TIPOLIQPERMITO NUMBER := 44;
    --V_TLIQUID        TIPO_LIQUIDACION.TIPLIQ%TYPE;
    L_RESULT VARCHAR2(2) := 'SI';
  BEGIN
  
    SELECT T.TIPLIQ
      INTO L_TIPOLIQ
      FROM TIPO_LIQUIDACION T
     WHERE T.CUENTA = PI_CUENTA;
  
    IF L_TIPOLIQ = L_TIPOLIQPERMITO THEN
      L_RESULT := 'SI';
    ELSE
      L_RESULT := 'NO';
    END IF;
  
    RETURN L_RESULT;
  
  END F_SUCURSAL_PROD;

  FUNCTION F_DIVISA_PROD(PI_NRECIBO IN VARCHAR2,
                         PI_MONEDA_FINAL IN VARCHAR2,
                         PI_FEFEADM IN DATE) RETURN NUMBER IS
    L_CDIVISA NUMBER;
    L_CMONEDA_INICIAL VARCHAR2(4):= 'USD'; 
    V_SSEGURO SEGUROS.SSEGURO%TYPE; 
    L_RESULT  NUMBER;
    P_PASEXEC NUMBER(8) := 0;
  
  BEGIN
    
    SELECT SSEGURO 
      INTO V_SSEGURO
      FROM RECIBOS
     WHERE NRECIBO = PI_NRECIBO; 

    P_PASEXEC := 1;
    SELECT P.CDIVISA
      INTO L_CDIVISA
      FROM SEGUROS S, PRODUCTOS P ,CODIDIVISA C, MONEDAS M, ECO_CODMONEDAS EC
     WHERE P.SPRODUC = S.SPRODUC
       AND C.CDIVISA = P.CDIVISA
       AND M.CMONINT = EC.CMONEDA
       AND M.CMONEDA = C.CDIVISA 
       AND S.SSEGURO = V_SSEGURO 
       AND M.CIDIOMA = 8;
       
     P_PASEXEC := 2;
     IF L_CDIVISA IS NULL THEN
        L_RESULT := NULL;
     
     ELSIF L_CDIVISA = 8  THEN
        L_RESULT := NULL;
       
     P_PASEXEC := 3;
     ELSE
        L_RESULT := PAC_ECO_TIPOCAMBIO.F_CAMBIO(L_CMONEDA_INICIAL,PI_MONEDA_FINAL,PI_FEFEADM);
  
     END IF;
    RETURN L_RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      
       P_TAB_ERROR(F_SYSDATE,
            F_USER,
            'F_DIVISA_PROD',
            P_PASEXEC,
            'NRECIBO :'||'-'||PI_NRECIBO||'-'||PI_MONEDA_FINAL||'-'||PI_FEFEADM,
            SQLERRM);
            RETURN NULL;

  END F_DIVISA_PROD;
  
  FUNCTION F_POLIZA_MIGRADA(PI_NRECIBO IN NUMBER) RETURN VARCHAR2 IS
    
      L_RESULT  VARCHAR2(2) := 'NO';
      V_SSEGURO SEGUROS.SSEGURO%TYPE;
      V_CPOLCIA  SEGUROS.CPOLCIA%TYPE;
      V_NPOLIZA  SEGUROS.NPOLIZA%TYPE;
      P_PASEXEC NUMBER(8) := 0;
      
      BEGIN
        
        BEGIN 
       
           P_PASEXEC := 1; 
           SELECT SSEGURO 
             INTO V_SSEGURO
             FROM RECIBOS
            WHERE NRECIBO = PI_NRECIBO
              AND CRECCIA IS NOT NULL; 
              
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
             V_SSEGURO := NULL;
        END;
      
        IF V_SSEGURO IS NULL THEN
           L_RESULT := 'NO'; 
 
        ELSE 
          
         P_PASEXEC := 2;
         SELECT CPOLCIA
           INTO V_CPOLCIA
           FROM SEGUROS 
          WHERE SSEGURO = V_SSEGURO;
        
         IF V_CPOLCIA IS NULL THEN
             L_RESULT := 'NO';
           
          ELSE
             L_RESULT := 'SI';
         END IF;
         P_PASEXEC := 3;
         
        END IF;
          
       RETURN L_RESULT;
       
   EXCEPTION
    WHEN OTHERS THEN
      
       P_TAB_ERROR(F_SYSDATE,
            F_USER,
            'F_POLIZA_MIGRADA',
            P_PASEXEC,
            'NRECIBO :'||' '||PI_NRECIBO,
            SQLERRM);
            
       RETURN L_RESULT;
            
  END F_POLIZA_MIGRADA;
  
  FUNCTION F_BUSCA_NUMUNICO(PI_ESCENARIO IN NUMBER,
                            PI_NRECIBO IN NUMBER,
                            PI_SINTERF IN NUMBER)
    RETURN VARCHAR2  IS
    
          L_RESULT  RECIBOS.CRECCIA%TYPE:= NULL;
          V_AGENTE AGENTES.CAGENTE%TYPE;
          P_PASEXEC NUMBER(8) := 0;
                    
    BEGIN
        --
        P_PASEXEC := 1; 
         SELECT DISTINCT CAGENTE
           INTO V_AGENTE
           FROM MOVCONTASAP
          WHERE NRECIBO = PI_NRECIBO
            AND SINTERF = PI_SINTERF;
            
        P_PASEXEC := 2; 
    -- PRIMAS VF,VA
        IF PI_ESCENARIO IN (237,238,242,244,245,247,337,338,347,348,360,369,204,205,216,217) THEN
    
        SELECT (SELECT REGEXP_SUBSTR(CRECCIA, '[^|]+', 1, LEVEL) VALOR
                  FROM DUAL
               CONNECT BY REGEXP_SUBSTR(CRECCIA, '[^|]+', 1, LEVEL) IS NOT NULL
                   AND ROWNUM = 1)
          INTO L_RESULT
          FROM RECIBOS
         WHERE NRECIBO = PI_NRECIBO;
    
        P_PASEXEC := 3;   
    -- PRIMAS VF // CAUSA INGRESO
    ELSIF PI_ESCENARIO IN (339,340,361,362) THEN
    
      SELECT DISTINCT(SUBSTR(CRECCIA,INSTR(CRECCIA,'|')+1,LENGTH(CRECCIA)))
            INTO L_RESULT
            FROM RECIBOS 
           WHERE NRECIBO = PI_NRECIBO;
         
    P_PASEXEC := 4;
     -- COMISIONES VA,VF    
        ELSIF PI_ESCENARIO IN (235,236,239,240,241,246,202,203)THEN 
    
    SELECT DISTINCT(SELECT REGEXP_SUBSTR(CRECCIA, '[^|]+', 1, LEVEL) VALOR
                   FROM DUAL
                CONNECT BY REGEXP_SUBSTR(CRECCIA, '[^|]+', 1, LEVEL) IS NOT NULL
                    AND ROWNUM = 1)
      INTO L_RESULT
          FROM COMRECIBO
         WHERE NRECIBO = PI_NRECIBO
       AND CAGENTE = V_AGENTE;
       
      P_PASEXEC := 5; 
    -- COMISIONES VF // CAUSA GASTO  
      ELSIF PI_ESCENARIO IN (208,209,211,232)THEN 
    
      SELECT DISTINCT(SUBSTR(CRECCIA,INSTR(CRECCIA,'|')+1,LENGTH(CRECCIA)))
            INTO L_RESULT
            FROM COMRECIBO 
           WHERE NRECIBO = PI_NRECIBO
         AND CAGENTE = V_AGENTE;
    
        END IF;
        
        RETURN L_RESULT;
        
      EXCEPTION 
        WHEN OTHERS THEN
      
       P_TAB_ERROR(F_SYSDATE,
            F_USER,
            'F_BUSCA_NUMUNICO',
            P_PASEXEC,
            'NRECIBO : :'||' '||PI_NRECIBO,SQLERRM);
            
       RETURN L_RESULT;
             
  END F_BUSCA_NUMUNICO;
  
  PROCEDURE ELIMINA_SCENARIO_MIGRACION(PI_RECIBO IN  NUMBER,
                                       PI_NMOVIMI IN NUMBER,
                                       PI_SSEGURO IN NUMBER,
                                       PI_RAMO    IN NUMBER,
                                       PI_CTIPCOA IN NUMBER,
                                       PI_CTIPREC IN VARCHAR2) IS
 
  X_ESTADO_F NUMBER := 2;
  P_PASEXEC NUMBER(8) := 0;
  
  BEGIN 
  
   P_PASEXEC := 1;
   
   DELETE 
     FROM MOVCONTASAP 
    WHERE NRECIBO = PI_RECIBO
      AND NMOVIMI = PI_NMOVIMI
      AND SSEGURO = PI_SSEGURO
      AND RAMO = PI_RAMO
      AND CTIPCOA = PI_CTIPCOA
      AND CTIPREC = PI_CTIPREC
      AND ESTADO = X_ESTADO_F
      AND SINTERF IS NULL
      AND CODESCENARIO IN (233,219);            
    COMMIT;
     
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                 'ELIMINA_SCENARIO_MIGRACION'||'-'||PI_RECIBO,
                  P_PASEXEC,
                  SQLCODE,
                  SQLERRM);
  
  END ELIMINA_SCENARIO_MIGRACION;
  
  FUNCTION F_TIPOVIGENCIA(PI_NRECIBO IN NUMBER,
                          PI_SSEGURO IN NUMBER,
                          PI_CPOLCIA VARCHAR2,
                          PI_ESCENARIO IN NUMBER ) RETURN NUMBER IS

   X_VIGENCIA  NUMBER;
   X_FEFECTO DATE;
   X_FEMISIO DATE;
   X_CRECCIA RECIBOS.CRECCIA%TYPE;
   P_PASEXEC NUMBER(8) := 0;
  
   BEGIN
    
     P_PASEXEC := 1;
     SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
       INTO X_FEMISIO, X_FEFECTO
       FROM RECIBOS R
      WHERE SSEGURO = PI_SSEGURO
        AND NRECIBO = PI_NRECIBO;     

     P_PASEXEC := 2;
     IF X_FEFECTO > X_FEMISIO THEN
      
        IF PI_CPOLCIA IS NOT NULL THEN --VALIDACION  CASO ESPECIAL DE POLIZAS MIGRADAS EN VF
        
          P_PASEXEC := 3;
          SELECT COUNT(*)
            INTO X_CRECCIA 
            FROM (SELECT REGEXP_SUBSTR((SELECT R.CRECCIA
                                          FROM RECIBOS R 
                                         WHERE R.NRECIBO = PI_NRECIBO), '[^|]+', 1, LEVEL) VALOR
                                          FROM DUAL
              CONNECT BY REGEXP_SUBSTR((SELECT R.CRECCIA
                                          FROM RECIBOS R 
                                         WHERE R.NRECIBO = PI_NRECIBO), '[^|]+', 1, LEVEL) IS NOT NULL);
         P_PASEXEC := 4;
         IF PI_ESCENARIO IS NULL THEN --VALIDACION PARA GERACION DE ESCENARIOS
            
           IF X_CRECCIA > 1 THEN   
              X_VIGENCIA := 1; --VF  
            ELSE                   
              X_VIGENCIA := 0; --VA
           END IF;
           
         ELSIF PI_ESCENARIO IN (237,238,242,244,245,247) THEN --VALIDACION PARA GERACION DE CUENTAS
             X_VIGENCIA := 0;  
         ELSE 
             X_VIGENCIA := 1;   
         END IF; 
       ELSE
         X_VIGENCIA := 1; --VF
       END IF;
       P_PASEXEC := 5;
     
     ELSE
        X_VIGENCIA := 0; --VA
    
     END IF;
    RETURN X_VIGENCIA;
  
  EXCEPTION
    WHEN OTHERS THEN
      
       P_TAB_ERROR(F_SYSDATE,
            F_USER,
            'F_TIPOVIGENCIA',
            P_PASEXEC,
            'NRECIBO :'||'-'||PI_NRECIBO||'-'||PI_SSEGURO,SQLERRM);
            RETURN NULL;

  END F_TIPOVIGENCIA;
  
  FUNCTION F_CAUSAGASTO(PI_NRECIBO IN NUMBER,
                        PI_SSEGURO IN NUMBER) RETURN VARCHAR2 IS
    X_FEFECTO DATE;
    X_FEMISIO DATE;
    L_RESULT VARCHAR2(2);
  BEGIN
    --
     SELECT TRUNC(FEMISIO), TRUNC(FEFECTO)
       INTO X_FEMISIO, X_FEFECTO
       FROM RECIBOS R
      WHERE SSEGURO = PI_SSEGURO
        AND NRECIBO = PI_NRECIBO; 
    --
    IF X_FEFECTO > X_FEMISIO THEN
        L_RESULT := 'SI';
      ELSE
        L_RESULT := 'NO';
      END IF;
	  --
    RETURN L_RESULT;
  END F_CAUSAGASTO;
  
  PROCEDURE GENERA_REINTENTO_PRD (PI_SINTERF IN NUMBER) IS

    CURSOR MOV_CONTA(P_EVENTO   VARCHAR2,
                     X_ESTADO_F NUMBER) IS
      SELECT A.NRECIBO,
             A.CAGENTE,
             A.NMOVIMI,
             A.SSEGURO,
             A.RAMO,
             A.CTIPCOA,
             A.CTIPREC,
             A.CODESCENARIO,
             A.SINTERF,
             A.NUM_INTENTO,
             A.ESTADO
        FROM MOVCONTASAP A
       WHERE A.ESTADO IN (X_ESTADO_F)
         AND A.EVENTO = P_EVENTO
         AND A.SINTERF  = PI_SINTERF
       ORDER BY A.NRECIBO, A.CODESCENARIO DESC;

    CURSOR COACEDIDO(P_SSEGURO NUMBER, P_NCUACOA NUMBER) IS
      SELECT C.CCOMPAN
        FROM COACEDIDO C
       WHERE C.SSEGURO = P_SSEGURO
         AND C.NCUACOA = P_NCUACOA;

    CURSOR ESCENARIOS(P_ESCENARIO NUMBER, P_RAMO NUMBER) IS
      SELECT A.CODCUENTA, A.PRODUCTO
        FROM ESCENARIOSAP A
       WHERE A.CODESCENARIO = P_ESCENARIO
         AND A.PRODUCTO IN (0, 1, P_RAMO)
       ORDER BY A.CODCUENTA;

    CURSOR ESCENARIOSVF(P_ESCENARIO NUMBER, P_RAMO NUMBER) IS
      SELECT A.CODCUENTA, A.PRODUCTO
        FROM ESCENARIOSAPVF A
       WHERE A.CODESCENARIO = P_ESCENARIO
         AND A.PRODUCTO IN (0, 1, P_RAMO)
       ORDER BY A.CODCUENTA;

    X_EVENTO VARCHAR2(50) := 'PRODUCCION';
    --VTSELEC        VARCHAR2(32000);
    VCOLETILLA     VARCHAR2(100);
    VDESCRI        VARCHAR2(32000);
    IMPORTE        NUMBER;
    VOTROS         VARCHAR2(4000);
    VFADM          DATE;
    X_CUENTA       VARCHAR2(20);
    X_LINEA        NUMBER;
    X_VALOR        NUMBER := 1;
    VSINTERF       NUMBER;
    X_TIPPAG       NUMBER;
    X_ENLACE       NUMBER;
    X_LIBRO        VARCHAR2(20);
    X_TAPUNTE      VARCHAR2(20);
    X_GENERA       NUMBER := 0;
    X_IMPORTE      NUMBER := 0;
    V_VALIDA_ENVIO NUMBER := 0;
    X_PROCEDE      NUMBER := 0;
    /* CAMBIOS DE SWAPNIL : STARTS  */
    VLINEAINI   VARCHAR2(500);
    VRESULTADO  NUMBER(10);
    VINTERFICIE VARCHAR2(100);
    VEMPRESA    NUMBER := 24;
    VTERMINAL   VARCHAR2(100);
    VERROR      NUMBER(10);
    VACCION     NUMBER(10) := 1;
    X_FECDOC    DATE;
    X_FECONTA   DATE;
    --X_FEMISIO   DATE;
    --X_FEFECTO   DATE;
    X_VIGFUT    NUMBER := 0;
    VTIPPAG     CONTAB_ASIENT_INTERF.TTIPPAG%TYPE;
    VIDPAGO     CONTAB_ASIENT_INTERF.IDPAGO%TYPE;
    VIDMOV      CONTAB_ASIENT_INTERF.IDMOV%TYPE;
    VIDMOVSEQ   NUMBER;
    VRESULT     SYS_REFCURSOR;

    X_ESTADO_I NUMBER := 2;
    X_ESTADO_P NUMBER := 3;
    X_ESTADO_T NUMBER := 4;
    X_ESTADO_F NUMBER := 5;

    VNOMBREARCHIVO VARCHAR2(500);
    VLOGARCHIVO    UTL_FILE.FILE_TYPE;
    VLINEA         VARCHAR2(2000);
    VRUTA          VARCHAR2(200) := 'TABEXT';

    VSERVICIOESTADO SERVICIO_LOGS.ESTADO%TYPE := 2;
    --VESTADOMOV      MOVCONTASAP.ESTADO%TYPE := 0;

    VCOUNTIMPORTE_ZERO NUMBER := 0;
    VCOUNTCUENTA       NUMBER := 0;
    VCOUNTERROR        NUMBER := 0;

    VCOUNTIM        NUMBER := 0;
    VCOUNTSL        NUMBER := 0;
    VCOUNTSL_ESTADO NUMBER := 2;
    VEXECUTAR       VARCHAR2(2) := 'NO';
    /* CAMBIOS DE SWAPNIL : ENDS  */

  BEGIN
    /*
     IN ESTADO COLUMN
      2 --Inicio     -- WHEN CUSRSOR TAKE RECORDS FOR GENERATE CUENTAS
      3 --Procesando -- WHEN GENERA_INFO_CUENTAS PRCEDURE STARTS PROCESSING
      4 --Generaron  -- WHEN GENERA_INFO_CUENTAS PRCEDURE FINISH PROCESSING
      5 --Error      -- WHEN GENERA_INFO_CUENTAS PRCEDURE FINISH WITH 3 RETRY
    */

    VNOMBREARCHIVO := 'CONTABLE_ERROR_' ||
                      TO_CHAR(F_SYSDATE, 'yyyymmdd_hh24miss') || '.txt';
    VLOGARCHIVO    := UTL_FILE.FOPEN(VRUTA, VNOMBREARCHIVO, 'w');
    VLINEA         := 'NRECIBO|CAGENTE|SSEGURO|CODESCENARIO|CUENTA|TIPPAG';
    UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);

    FOR MOV IN MOV_CONTA(X_EVENTO,X_ESTADO_F) LOOP
      VSERVICIOESTADO := 2;

      /* set retry variable for first attempt */
     /* IF MOV.NUM_INTENTO IS NULL THEN
        UPDATE MOVCONTASAP M
           SET M.NUM_INTENTO = 1
         WHERE M.CAGENTE = MOV.CAGENTE
           AND M.CODESCENARIO = MOV.CODESCENARIO
           AND M.NRECIBO = MOV.NRECIBO
           AND M.CTIPREC = MOV.CTIPREC;
        COMMIT;
      END IF;*/

      /* Checking eligibility of ESTADO 3 before retry */
      IF MOV.SINTERF IS NOT NULL AND MOV.ESTADO = X_ESTADO_F AND MOV.NUM_INTENTO = 3 THEN
        SELECT COUNT(*)
          INTO VCOUNTIM
          FROM INT_MENSAJES IM
         WHERE IM.SINTERF = MOV.SINTERF;

        SELECT COUNT(*)
          INTO VCOUNTSL
          FROM SERVICIO_LOGS SL
         WHERE SL.SINTERF = MOV.SINTERF;

        IF VCOUNTIM > 0 AND VCOUNTSL > 0 THEN
          BEGIN
            SELECT SL.ESTADO
              INTO VCOUNTSL_ESTADO
              FROM SERVICIO_LOGS SL
             WHERE SL.SINTERF = MOV.SINTERF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VCOUNTSL_ESTADO := X_ESTADO_F;
          END;
          IF VCOUNTSL_ESTADO = X_ESTADO_I THEN
            VEXECUTAR := 'SI';
            DELETE CONTAB_ASIENT_INTERF CAI
             WHERE CAI.IDPAGO = MOV.NRECIBO
               AND CAI.SINTERF = MOV.SINTERF;
            COMMIT;
          ELSE
            VEXECUTAR := 'NO';

      UPDATE MOVCONTASAP M
               SET M.ESTADO = X_ESTADO_T
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.CODESCENARIO = MOV.CODESCENARIO
               AND M.NRECIBO = MOV.NRECIBO
               AND M.CTIPREC = MOV.CTIPREC;
            COMMIT;
     END IF;
        ELSE
            VEXECUTAR := 'SI';
        END IF; 
    END IF;

      IF VEXECUTAR = 'SI' THEN
        /* Change status once start processing 3*/
        UPDATE MOVCONTASAP M
           SET M.ESTADO = X_ESTADO_P, M.SINTERF = ''
         WHERE M.CAGENTE = MOV.CAGENTE
           AND M.CODESCENARIO = MOV.CODESCENARIO
           AND M.NRECIBO = MOV.NRECIBO
           AND M.CTIPREC = MOV.CTIPREC;
        COMMIT;

        PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
        VSINTERF       := PAC_INT_ONLINE.F_OBTENER_SINTERF;
        V_VALIDA_ENVIO := 0;

        /*VALIDACION DE VIGENCIA FUTURA Y ACTUAL*/ 
        X_VIGFUT := PAC_CONTA_SAP.F_TIPOVIGENCIA(MOV.NRECIBO,MOV.SSEGURO,PAC_CONTAB_CONF.F_ZZFIPOLIZA(MOV.SSEGURO),MOV.CODESCENARIO);

        SELECT SMOVREC.NEXTVAL INTO VIDMOVSEQ FROM DUAL;

        IF X_VIGFUT = 0 THEN
          VCOUNTCUENTA       := 0;
          VCOUNTIMPORTE_ZERO := 0;
          FOR ESC IN ESCENARIOS(MOV.CODESCENARIO, MOV.RAMO) LOOP
            VCOUNTCUENTA := VCOUNTCUENTA + 1;
            X_GENERA     := 0;
            X_IMPORTE    := 0;
            X_PROCEDE    := 0;

            IF (ESC.PRODUCTO = 0 OR ESC.PRODUCTO = MOV.RAMO) THEN
              SELECT A.CCUENTA, A.LINEA
                INTO X_CUENTA, X_LINEA
                FROM CUENTASSAP A
               WHERE A.CODCUENTA = ESC.CODCUENTA;
              X_GENERA := 1;
              IF X_CUENTA IN (1630400100) THEN
                IF MOV.CTIPCOA IN (0, 8, 9) THEN
                  X_GENERA := 0;
                END IF;
              END IF;
            ELSIF ESC.PRODUCTO = 1 THEN
              SELECT A.CCUENTA, A.LINEA
                INTO X_CUENTA, X_LINEA
                FROM CUENTASSAP A
               WHERE A.CODCUENTA = ESC.CODCUENTA;
              X_GENERA := 1;
              IF X_CUENTA IN (1684050200, 1684050300, 4195950190) THEN
                IF MOV.CTIPCOA IN (8, 9) THEN
                  X_GENERA := 0;
                END IF;
              END IF;
            END IF;

            IF X_GENERA = 1 THEN
              BEGIN
                SELECT C.TTIPPAG, C.TCUENTA, C.CLAENLACE, C.TLIBRO
                  INTO X_TIPPAG, X_TAPUNTE, X_ENLACE, X_LIBRO
                  FROM CUENTASSAP C
                 WHERE C.CCUENTA = X_CUENTA;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  X_PROCEDE := 1;
              END;

              IF X_PROCEDE = 0 THEN
                IF ESC.CODCUENTA IN (6, 12) AND MOV.CTIPCOA IN (1, 2) THEN
                  FOR COD IN COACEDIDO(MOV.SSEGURO, MOV.NMOVIMI) LOOP
                    BEGIN
                      GENERARTRAMA_COD(PI_RECIBO   => MOV.NRECIBO,
                                       PI_AGENTE   => MOV.CAGENTE,
                                       PI_SCENARIO => MOV.CODESCENARIO,
                                       PI_CUENTA   => X_CUENTA,
                                       PI_TIPPAG   => X_TIPPAG,
                                       PI_COMPAN   => COD.CCOMPAN,
                                       PO_RESULT   => VRESULT);
                      LOOP
                        FETCH VRESULT
                          INTO VCOLETILLA, VDESCRI, IMPORTE, VOTROS, VFADM;
                        EXIT WHEN VRESULT%NOTFOUND;
                      END LOOP;
                      CLOSE VRESULT;
                    EXCEPTION
                      WHEN OTHERS THEN
                        VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                                       MOV.SSEGURO || '|' ||
                                       MOV.CODESCENARIO || '|' || X_CUENTA || '|' ||
                                       X_TIPPAG;
                        VCOUNTERROR := VCOUNTERROR + 1;
                        P_TAB_ERROR(F_SYSDATE,
                                    F_USER,
                                    'GENERA_REINTENTO_PRD :VA:TRAMA_COD: I031',
                                    X_TIPPAG,
                                    'VSINTERF:' || VSINTERF,
                                    'VLINEA :' || VLINEA || ':' ||
                                    ':SQLERRM:' || SQLERRM);
                        UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                        CONTINUE;
                    END;

                    IF IMPORTE <> 0 THEN
                      IF MOV.CTIPREC NOT IN (9531,9532,1522,9522,9032) THEN

                       SELECT TRUNC(FEMISIO)
                          INTO X_FECONTA
                          FROM RECIBOS
                         WHERE NRECIBO = MOV.NRECIBO;

                        SELECT TRUNC(MAX(FMOVDIA))
                          INTO X_FECDOC
                          FROM MOVRECIBO
                         WHERE NRECIBO = MOV.NRECIBO;
                      ELSE
                        SELECT TRUNC(MAX(FMOVDIA))
                          INTO X_FECONTA
                          FROM MOVRECIBO
                         WHERE NRECIBO = MOV.NRECIBO;

                        SELECT TRUNC(MAX(FMOVDIA))
                          INTO X_FECDOC
                          FROM MOVRECIBO
                         WHERE NRECIBO = MOV.NRECIBO;
                      END IF;

                      INSERT INTO CONTAB_ASIENT_INTERF
                        (SINTERF,
                         TTIPPAG,
                         IDPAGO,
                         FCONTA,
                         NASIENT,
                         NLINEA,
                         CCUENTA,
                         CCOLETILLA,
                         TAPUNTE,
                         IAPUNTE,
                         TDESCRI,
                         FEFEADM,
                         CENLACE,
                         TLIBRO,
                         OTROS,
                         IDMOV)
                      VALUES
                        (VSINTERF,
                         X_TIPPAG,
                         MOV.NRECIBO,
                         X_FECDOC,
                         X_VALOR,
                         X_LINEA,
                         SUBSTR(X_CUENTA, 1, 6),
                         SUBSTR(X_CUENTA, 7, 4),
                         X_TAPUNTE,
                         IMPORTE,
                         VDESCRI,
                         X_FECONTA,
                         X_ENLACE,
                         X_LIBRO,
                         VOTROS,
                         VIDMOVSEQ);

                      UPDATE MOVCONTASAP M
                         SET M.SINTERF = VSINTERF
                       WHERE M.CAGENTE = MOV.CAGENTE
                         AND M.CODESCENARIO = MOV.CODESCENARIO
                         AND M.CTIPREC = MOV.CTIPREC
                         AND M.NRECIBO = MOV.NRECIBO;
                      COMMIT;
                      V_VALIDA_ENVIO := 1;
                    END IF;
                  END LOOP;
                ELSE
                  BEGIN
                    GENERARTRAMA(PI_RECIBO   => MOV.NRECIBO,
                                 PI_AGENTE   => MOV.CAGENTE,
                                 PI_SCENARIO => MOV.CODESCENARIO,
                                 PI_CUENTA   => X_CUENTA,
                                 PI_TIPPAG   => X_TIPPAG,
                                 PO_RESULT   => VRESULT);

                    LOOP
                      FETCH VRESULT
                        INTO VCOLETILLA, VDESCRI, IMPORTE, VOTROS, VFADM;
                      EXIT WHEN VRESULT%NOTFOUND;
                    END LOOP;
                    CLOSE VRESULT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                                     MOV.SSEGURO || '|' || MOV.CODESCENARIO || '|' ||
                                     X_CUENTA || '|' || X_TIPPAG;
                      VCOUNTERROR := VCOUNTERROR + 1;
                      P_TAB_ERROR(F_SYSDATE,
                                  F_USER,
                                  'GENERA_REINTENTO_PRD :VA:TRAMA: I031',
                                  X_TIPPAG,
                                  'VSINTERF : ' || VSINTERF,
                                  'VLINEA :' || VLINEA || ':' ||
                                  ':SQLERRM:' || SQLERRM);
                      UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                      CONTINUE;
                  END;

                  IF IMPORTE <> 0 THEN
                    IF MOV.CTIPREC NOT IN (9531,9532,1522,9522,9032) THEN

                       SELECT TRUNC(FEMISIO)
                          INTO X_FECONTA
                          FROM RECIBOS
                         WHERE NRECIBO = MOV.NRECIBO;

                       /* SELECT TRUNC(FEFECTO)
                          INTO X_FECONTA
                          FROM RECIBOS
                         WHERE NRECIBO = MOV.NRECIBO;*/

                        SELECT TRUNC(MAX(FMOVDIA))
                          INTO X_FECDOC
                          FROM MOVRECIBO
                         WHERE NRECIBO = MOV.NRECIBO;
                    ELSE
                      SELECT TRUNC(MAX(FMOVDIA))
                        INTO X_FECONTA
                        FROM MOVRECIBO
                       WHERE NRECIBO = MOV.NRECIBO;

                      SELECT TRUNC(MAX(FMOVDIA))
                        INTO X_FECDOC
                        FROM MOVRECIBO
                       WHERE NRECIBO = MOV.NRECIBO;
                    END IF;

                    INSERT INTO CONTAB_ASIENT_INTERF
                      (SINTERF,
                       TTIPPAG,
                       IDPAGO,
                       FCONTA,
                       NASIENT,
                       NLINEA,
                       CCUENTA,
                       CCOLETILLA,
                       TAPUNTE,
                       IAPUNTE,
                       TDESCRI,
                       FEFEADM,
                       CENLACE,
                       TLIBRO,
                       OTROS,
                       IDMOV)
                    VALUES
                      (VSINTERF,
                       X_TIPPAG,
                       MOV.NRECIBO,
                       X_FECDOC,
                       X_VALOR,
                       X_LINEA,
                       SUBSTR(X_CUENTA, 1, 6),
                       SUBSTR(X_CUENTA, 7, 4),
                       X_TAPUNTE,
                       IMPORTE,
                       VDESCRI,
                       X_FECONTA,
                       X_ENLACE,
                       X_LIBRO,
                       VOTROS,
                       VIDMOVSEQ);

                    UPDATE MOVCONTASAP M
                       SET M.SINTERF = VSINTERF
                     WHERE M.CAGENTE = MOV.CAGENTE
                       AND M.CODESCENARIO = MOV.CODESCENARIO
                       AND M.CTIPREC = MOV.CTIPREC
                       AND M.NRECIBO = MOV.NRECIBO;
                    COMMIT;
                    V_VALIDA_ENVIO := 1;
                  ELSE
                    VCOUNTIMPORTE_ZERO := VCOUNTIMPORTE_ZERO + 1;
                  END IF;
                END IF; -- COD                
              END IF;
            END IF;
          END LOOP;

          IF VCOUNTCUENTA = VCOUNTIMPORTE_ZERO THEN
            UPDATE MOVCONTASAP M
               SET M.SINTERF = VSINTERF, M.ESTADO = X_ESTADO_F
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.CODESCENARIO = MOV.CODESCENARIO
               AND M.CTIPREC = MOV.CTIPREC
               AND M.NRECIBO = MOV.NRECIBO;
            COMMIT;
          END IF;

          IF V_VALIDA_ENVIO = 1 THEN
            /* CAMBIOS DE SWAPNIL : STARTS  */
            VINTERFICIE := PAC_PARAMETROS.F_PAREMPRESA_T(VEMPRESA,
                                                         'INTERFICIE_ERP');
            VERROR      := PAC_USER.F_GET_TERMINAL(F_USER, VTERMINAL);
            BEGIN
              SELECT DISTINCT CAI.TTIPPAG, CAI.IDPAGO, CAI.IDMOV
                INTO VTIPPAG, VIDPAGO, VIDMOV
                FROM CONTAB_ASIENT_INTERF CAI
               WHERE CAI.SINTERF = VSINTERF
                 AND CAI.TTIPPAG = X_TIPPAG;
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                SELECT DISTINCT CAI.TTIPPAG, CAI.IDPAGO, CAI.IDMOV
                  INTO VTIPPAG, VIDPAGO, VIDMOV
                  FROM CONTAB_ASIENT_INTERF CAI
                 WHERE CAI.SINTERF = VSINTERF
                   AND ROWNUM = 1;
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'REINTENTO_PRD/TESTING:DUP_VAL_ON_INDEX',
                            VTIPPAG,
                            VSINTERF,
                            'VSINTERF : ' || VSINTERF || ' :SQLERRM: ' ||
                            SQLERRM);
              WHEN NO_DATA_FOUND THEN
                VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                               MOV.SSEGURO || '|' || MOV.CODESCENARIO || '|' ||
                               X_CUENTA || '|' || X_TIPPAG;
                VCOUNTERROR := VCOUNTERROR + 1;
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'REINTENTO_PRD/TESTING:NO_DATA_FOUND',
                            VTIPPAG,
                            'VSINTERF : ' || VSINTERF,
                            'VLINEA: ' || VLINEA || ' :SQLERRM: ' ||
                            SQLERRM);

                UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                CONTINUE;
            END;
            IF VTIPPAG = 10 THEN
              VLINEAINI := VEMPRESA || '|' || VTIPPAG || '|' || VACCION || '|' ||
                           VIDPAGO || '|' || VIDMOV || '|' || VTERMINAL || '|' ||
                           F_USER || '|' || '' /*PNUMEVENTO*/
                           || '|' || '' /*PCODERRORIN*/
                           || '|' || '' /*PDESCERRORIN*/
                           || '|' || '1' /*PPASOCUENTA*/
               ;
            ELSE
              VLINEAINI := VEMPRESA || '|' || VTIPPAG || '|' || VACCION || '|' ||
                           VIDPAGO || '|' || VIDMOV || '|' || VTERMINAL || '|' ||
                           F_USER || '|' || '' /*PNUMEVENTO*/
                           || '|' || '' /*PCODERRORIN*/
                           || '|' || '' /*PDESCERRORIN*/
                           || '|' || '' /*PPASOCUENTA*/
               ;
            END IF;

            P_TAB_ERROR(F_SYSDATE,
                        F_USER,
                        'REINTENTO_PRD/Entrda VA : I031',
                        VACCION,
                        VSINTERF,
                        'VSINTERF : ' || VSINTERF || ' :VLINEAINI: ' ||
                        VLINEAINI || ' : X_CUENTA: ' || X_CUENTA);

            VRESULTADO := PAC_INT_ONLINE.F_INT(VEMPRESA,
                                               VSINTERF,
                                               VINTERFICIE,
                                               VLINEAINI);
            /* CAMBIOS DE SWAPNIL : ENDS  */
          END IF;
          -- FIN VIGENCIA ACTUAL
        ELSE

          VCOUNTCUENTA       := 0;
          VCOUNTIMPORTE_ZERO := 0;
          FOR ESC IN ESCENARIOSVF(MOV.CODESCENARIO, MOV.RAMO) LOOP
            VCOUNTCUENTA := VCOUNTCUENTA + 1;
            X_GENERA     := 0;
            X_IMPORTE    := 0;
            X_PROCEDE    := 0;
            IF (ESC.PRODUCTO = 0 OR ESC.PRODUCTO = MOV.RAMO) THEN
              SELECT A.CCUENTA, A.LINEA
                INTO X_CUENTA, X_LINEA
                FROM CUENTASSAP A
               WHERE A.CODCUENTA = ESC.CODCUENTA;
              X_GENERA := 1;
              IF X_CUENTA IN (1630400100) THEN
                IF MOV.CTIPCOA IN (0, 8, 9) THEN
                  X_GENERA := 0;
                END IF;
              END IF;
            ELSIF ESC.PRODUCTO = 1 THEN
              SELECT A.CCUENTA, A.LINEA
                INTO X_CUENTA, X_LINEA
                FROM CUENTASSAP A
               WHERE A.CODCUENTA = ESC.CODCUENTA;
              X_GENERA := 1;
              IF X_CUENTA IN (1684050200, 1684050300, 4195950190) THEN
                IF MOV.CTIPCOA IN (8, 9) THEN
                  X_GENERA := 0;
                END IF;
              END IF;
            END IF;

            IF X_GENERA = 1 THEN
              BEGIN
                SELECT C.TTIPPAG, C.TCUENTA, C.CLAENLACE, C.TLIBRO
                  INTO X_TIPPAG, X_TAPUNTE, X_ENLACE, X_LIBRO
                  FROM CUENTASSAP C
                 WHERE C.CCUENTA = X_CUENTA;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  X_PROCEDE := 1;
              END;

              IF X_PROCEDE = 0 THEN
                IF ESC.CODCUENTA IN (6, 12) AND MOV.CTIPCOA IN (1, 2) THEN
                  FOR COD IN COACEDIDO(MOV.SSEGURO, MOV.NMOVIMI) LOOP
                    BEGIN
                      GENERARTRAMA_COD(PI_RECIBO   => MOV.NRECIBO,
                                       PI_AGENTE   => MOV.CAGENTE,
                                       PI_SCENARIO => MOV.CODESCENARIO,
                                       PI_CUENTA   => X_CUENTA,
                                       PI_TIPPAG   => X_TIPPAG,
                                       PI_COMPAN   => COD.CCOMPAN,
                                       PO_RESULT   => VRESULT);
                      LOOP
                        FETCH VRESULT
                          INTO VCOLETILLA, VDESCRI, IMPORTE, VOTROS, VFADM;
                        EXIT WHEN VRESULT%NOTFOUND;
                      END LOOP;
                      CLOSE VRESULT;
                    EXCEPTION
                      WHEN OTHERS THEN
                        VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                                       MOV.SSEGURO || '|' ||
                                       MOV.CODESCENARIO || '|' || X_CUENTA || '|' ||
                                       X_TIPPAG;
                        VCOUNTERROR := VCOUNTERROR + 1;
                        P_TAB_ERROR(F_SYSDATE,
                                    F_USER,
                                    'REINTENTO_PRD/TESTING VF:TRAMA_COD: I031',
                                    VACCION,
                                    'VSINTERF :' || VSINTERF,
                                    'VLINEA : ' || VLINEA || ' :SQLERRM: ' ||
                                    SQLERRM);
                        UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                        CONTINUE;
                    END;
                    IF IMPORTE <> 0 THEN
                      SELECT TRUNC(FEFECTO)
                        INTO X_FECONTA
                        FROM RECIBOS
                       WHERE NRECIBO = MOV.NRECIBO;

                      SELECT TRUNC(MAX(FMOVDIA))
                        INTO X_FECDOC
                        FROM MOVRECIBO
                       WHERE NRECIBO = MOV.NRECIBO;

                      INSERT INTO CONTAB_ASIENT_INTERF
                        (SINTERF,
                         TTIPPAG,
                         IDPAGO,
                         FCONTA,
                         NASIENT,
                         NLINEA,
                         CCUENTA,
                         CCOLETILLA,
                         TAPUNTE,
                         IAPUNTE,
                         TDESCRI,
                         FEFEADM,
                         CENLACE,
                         TLIBRO,
                         OTROS,
                         IDMOV)
                      VALUES
                        (VSINTERF,
                         X_TIPPAG,
                         MOV.NRECIBO,
                         X_FECDOC,
                         X_VALOR,
                         X_LINEA,
                         SUBSTR(X_CUENTA, 1, 6),
                         SUBSTR(X_CUENTA, 7, 4),
                         X_TAPUNTE,
                         IMPORTE,
                         VDESCRI,
                         X_FECONTA,
                         X_ENLACE,
                         X_LIBRO,
                         VOTROS,
                         VIDMOVSEQ);

                      UPDATE MOVCONTASAP M
                         SET M.SINTERF = VSINTERF
                       WHERE M.CAGENTE = MOV.CAGENTE
                         AND M.CODESCENARIO = MOV.CODESCENARIO
                         AND M.CTIPREC = MOV.CTIPREC
                         AND M.NRECIBO = MOV.NRECIBO;

                      COMMIT;
                      V_VALIDA_ENVIO := 1;
                    END IF;
                  END LOOP;
                ELSE
                  BEGIN
                    --DBMS_OUTPUT.PUT_LINE('MOV.NRECIBO :'||MOV.NRECIBO||':MOV.CAGENTE:'||MOV.CAGENTE||':MOV.CODESCENARIO:'||MOV.CODESCENARIO);                
                    GENERARTRAMA(PI_RECIBO   => MOV.NRECIBO,
                                 PI_AGENTE   => MOV.CAGENTE,
                                 PI_SCENARIO => MOV.CODESCENARIO,
                                 PI_CUENTA   => X_CUENTA,
                                 PI_TIPPAG   => X_TIPPAG,
                                 PO_RESULT   => VRESULT);

                    LOOP
                      FETCH VRESULT
                        INTO VCOLETILLA, VDESCRI, IMPORTE, VOTROS, VFADM;
                      EXIT WHEN VRESULT%NOTFOUND;
                    END LOOP;
                    CLOSE VRESULT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                                     MOV.SSEGURO || '|' || MOV.CODESCENARIO || '|' ||
                                     X_CUENTA || '|' || X_TIPPAG;
                      VCOUNTERROR := VCOUNTERROR + 1;
                      P_TAB_ERROR(F_SYSDATE,
                                  F_USER,
                                  'REINTENTO_PRD/TESTING VF TRAMA: I031',
                                  VACCION,
                                  'VSINTERF : ' || VSINTERF,
                                  'VLINEA : ' || VLINEA || ' :SQLERRM: ' ||
                                  SQLERRM);
                      UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                      CONTINUE;
                  END;
                  IF IMPORTE <> 0 THEN
                    SELECT TRUNC(FEFECTO)
                      INTO X_FECONTA
                      FROM RECIBOS
                     WHERE NRECIBO = MOV.NRECIBO;

                    SELECT TRUNC(MAX(FMOVDIA))
                      INTO X_FECDOC
                      FROM MOVRECIBO
                     WHERE NRECIBO = MOV.NRECIBO;

                    INSERT INTO CONTAB_ASIENT_INTERF
                      (SINTERF,
                       TTIPPAG,
                       IDPAGO,
                       FCONTA,
                       NASIENT,
                       NLINEA,
                       CCUENTA,
                       CCOLETILLA,
                       TAPUNTE,
                       IAPUNTE,
                       TDESCRI,
                       FEFEADM,
                       CENLACE,
                       TLIBRO,
                       OTROS,
                       IDMOV)
                    VALUES
                      (VSINTERF,
                       X_TIPPAG,
                       MOV.NRECIBO,
                       X_FECDOC,
                       X_VALOR,
                       X_LINEA,
                       SUBSTR(X_CUENTA, 1, 6),
                       SUBSTR(X_CUENTA, 7, 4),
                       X_TAPUNTE,
                       IMPORTE,
                       VDESCRI,
                       X_FECONTA,
                       X_ENLACE,
                       X_LIBRO,
                       VOTROS,
                       VIDMOVSEQ);

                    UPDATE MOVCONTASAP M
                       SET M.SINTERF = VSINTERF
                     WHERE M.CAGENTE = MOV.CAGENTE
                       AND M.CODESCENARIO = MOV.CODESCENARIO
                       AND M.CTIPREC = MOV.CTIPREC
                       AND M.NRECIBO = MOV.NRECIBO;

                    COMMIT;
                    V_VALIDA_ENVIO := 1;
                  ELSE
                    VCOUNTIMPORTE_ZERO := VCOUNTIMPORTE_ZERO + 1;
                  END IF;
                END IF; -- COD 
              END IF;
            END IF;
          END LOOP;

          IF VCOUNTCUENTA = VCOUNTIMPORTE_ZERO THEN
            UPDATE MOVCONTASAP M
               SET M.SINTERF = VSINTERF, M.ESTADO = X_ESTADO_F
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.CODESCENARIO = MOV.CODESCENARIO
               AND M.CTIPREC = MOV.CTIPREC
               AND M.NRECIBO = MOV.NRECIBO;
            COMMIT;
          END IF;

          IF V_VALIDA_ENVIO = 1 THEN
            /* CAMBIOS DE SWAPNIL : STARTS */
            VINTERFICIE := PAC_PARAMETROS.F_PAREMPRESA_T(VEMPRESA,
                                                         'INTERFICIE_ERP');
            VERROR      := PAC_USER.F_GET_TERMINAL(F_USER, VTERMINAL);
            BEGIN
              SELECT DISTINCT CAI.TTIPPAG, CAI.IDPAGO, CAI.IDMOV
                INTO VTIPPAG, VIDPAGO, VIDMOV
                FROM CONTAB_ASIENT_INTERF CAI
               WHERE CAI.SINTERF = VSINTERF;
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                SELECT DISTINCT CAI.TTIPPAG, CAI.IDPAGO, CAI.IDMOV
                  INTO VTIPPAG, VIDPAGO, VIDMOV
                  FROM CONTAB_ASIENT_INTERF CAI
                 WHERE CAI.SINTERF = VSINTERF
                   AND ROWNUM = 1;
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'REINTENTO_PRD/Testing VF:DUP_VAL_ON_INDEX:I031',
                            VACCION,
                            VSINTERF,
                            'VSINTERF : ' || VSINTERF || ' :SQLERRM: ' ||
                            SQLERRM);
              WHEN NO_DATA_FOUND THEN
                VLINEA      := MOV.NRECIBO || '|' || MOV.CAGENTE || '|' ||
                               MOV.SSEGURO || '|' || MOV.CODESCENARIO || '|' ||
                               X_CUENTA || '|' || X_TIPPAG;
                VCOUNTERROR := VCOUNTERROR + 1;
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'REINTENTO_PRD/Testing VF:NO_DATA_FOUND:I031',
                            VACCION,
                            'VSINTERF :' || VSINTERF,
                            'VLINEA : ' || VLINEA || ' :SQLERRM: ' ||
                            SQLERRM);
                UTL_FILE.PUT_LINE(VLOGARCHIVO, VLINEA);
                CONTINUE;
            END;
            IF VTIPPAG = 10 THEN
              VLINEAINI := VEMPRESA || '|' || VTIPPAG || '|' || VACCION || '|' ||
                           VIDPAGO || '|' || VIDMOV || '|' || VTERMINAL || '|' ||
                           F_USER || '|' || '' /*PNUMEVENTO*/
                           || '|' || '' /*PCODERRORIN*/
                           || '|' || '' /*PDESCERRORIN*/
                           || '|' || '1' /*PPASOCUENTA*/
               ;
            ELSE
              VLINEAINI := VEMPRESA || '|' || VTIPPAG || '|' || VACCION || '|' ||
                           VIDPAGO || '|' || VIDMOV || '|' || VTERMINAL || '|' ||
                           F_USER || '|' || '' /*PNUMEVENTO*/
                           || '|' || '' /*PCODERRORIN*/
                           || '|' || '' /*PDESCERRORIN*/
                           || '|' || '' /*PPASOCUENTA*/
               ;
            END IF;

            P_TAB_ERROR(F_SYSDATE,
                        F_USER,
                        'REINTENTO_PRD/ENTRDA VF:I031',
                        VACCION,
                        VSINTERF,
                        'VSINTERF : ' || VSINTERF || ' :VLINEAINI: ' ||
                        VLINEAINI || ' : ' || X_CUENTA);

            VRESULTADO := PAC_INT_ONLINE.F_INT(VEMPRESA,
                                               VSINTERF,
                                               VINTERFICIE,
                                               VLINEAINI);
            /* CAMBIOS DE SWAPNIL : ENDS  */
          END IF;
          -- FIN VIGENCIA FUTURA
          
        END IF;

      ELSE
        /* When not eligible : for estado 3 */
        CONTINUE;
      END IF;

    END LOOP;
    /* CERAR ARCHIVO */
    IF UTL_FILE.IS_OPEN(VLOGARCHIVO) THEN
      UTL_FILE.FCLOSE(VLOGARCHIVO);
    END IF;

    IF VCOUNTERROR = 0 THEN 
      UTL_FILE.FREMOVE(VRUTA, VNOMBREARCHIVO);
    END IF;

  END GENERA_REINTENTO_PRD;
  
  PROCEDURE GENERA_REINTENTO_SIN(PI_SINTERF IN NUMBER) IS
    --
    CURSOR MOV_CONTA(P_EVENTO VARCHAR2) IS
    --
      SELECT A.*
        FROM MOVCONTASAP A
       WHERE A.ESTADO IN  (5)
         AND A.EVENTO = P_EVENTO
         AND A.SINTERF = PI_SINTERF;
    --
    CURSOR CUR(VSIDEPAG NUMBER, VNSINIES NUMBER) IS
    --
      SELECT P.CCONPAG,
             P.SIDEPAG,
             S.CRAMO,
             S.CEMPRES,
             X.NSINIES,
             P.ISINRET,
             S.CTIPCOA,
             P.CTIPPAG,
             P.CMONPAG,
             P.CTIPDES,
             SR.CSOLIDARIDAD,
             S.SSEGURO
        FROM SEGUROS             S,
             SIN_SINIESTRO       X,
             SIN_TRAMITA_PAGO    P,
             SIN_TRAMITA_RESERVA SR
       WHERE P.SIDEPAG = NVL(VSIDEPAG, 0)
         AND X.NSINIES = VNSINIES
         AND SR.NSINIES = X.NSINIES
         AND SR.SIDEPAG = P.SIDEPAG
         AND X.NSINIES = P.NSINIES
         AND S.SSEGURO = X.SSEGURO
         AND ROWNUM = 1;
    --
  
    X_EVENTO VARCHAR2(50) := 'SINIESTROS';
  
    /* CAMBIOS DE SWAPNIL : STARTS  */
  
    VTERMINAL VARCHAR2(100);
    VERROR    NUMBER(10);
    VSINTERF  NUMBER;
    VEMITIDO  NUMBER;
    PERROR    VARCHAR2(2000);
  
    /* CAMBIOS DE SWAPNIL : ENDS  */
    X_ESTADO_I NUMBER := 0;
    X_ESTADO_P NUMBER := 3;
    X_ESTADO_T NUMBER := 4;
    X_ESTADO_SL NUMBER := 2;
    VEXECUTAR       VARCHAR2(2) := 'NO';
    VCOUNTIM        NUMBER := 0;
    VCOUNTSL        NUMBER := 0;
    VCOUNTSL_ESTADO NUMBER := 2;
    X_ESTADO_F NUMBER := 5;  
  
  BEGIN
  
    FOR MOV IN MOV_CONTA(X_EVENTO) LOOP
      --
      FOR REG IN CUR(MOV.NRECIBO, MOV.NSINIES) LOOP
        --     
       /* IF MOV.NUM_INTENTO IS NULL THEN
          UPDATE MOVCONTASAP M
             SET M.NUM_INTENTO = 1
           WHERE M.CAGENTE = MOV.CAGENTE
             AND M.NRECIBO = MOV.NRECIBO
             AND M.NSINIES = MOV.NSINIES
             AND M.CCONCEP = MOV.CCONCEP;
          COMMIT;
        END IF;*/

     /* Checking eligibility of ESTADO 3 before retry */
    -- IF MOV.SINTERF IS NOT NULL AND MOV.ESTADO = X_ESTADO_P THEN
      IF MOV.SINTERF IS NOT NULL AND MOV.ESTADO = X_ESTADO_F AND MOV.NUM_INTENTO = 3 THEN
        SELECT COUNT(*)
          INTO VCOUNTIM
          FROM INT_MENSAJES IM
         WHERE IM.SINTERF = MOV.SINTERF;

        SELECT COUNT(*)
          INTO VCOUNTSL
          FROM SERVICIO_LOGS SL
         WHERE SL.SINTERF = MOV.SINTERF;

        IF VCOUNTIM > 0 AND VCOUNTSL > 0 THEN
          BEGIN
            SELECT SL.ESTADO
              INTO VCOUNTSL_ESTADO
              FROM SERVICIO_LOGS SL
             WHERE SL.SINTERF = MOV.SINTERF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VCOUNTSL_ESTADO := X_ESTADO_SL;
          END;
          IF VCOUNTSL_ESTADO = X_ESTADO_SL THEN  
            VEXECUTAR := 'SI';
            DELETE CONTAB_ASIENT_INTERF CAI
             WHERE CAI.IDPAGO  = MOV.NRECIBO
               AND CAI.SINTERF = MOV.SINTERF;
            COMMIT; 
          ELSE
            VEXECUTAR := 'NO';
            UPDATE MOVCONTASAP M
               SET M.ESTADO = X_ESTADO_T
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.NRECIBO = MOV.NRECIBO
               AND M.NSINIES = MOV.NSINIES
               AND M.CCONCEP = MOV.CCONCEP;               
            COMMIT;
          END IF;
        ELSE
            VEXECUTAR := 'SI';
        END IF;

      ELSIF MOV.ESTADO = X_ESTADO_I THEN
            VEXECUTAR := 'SI';
      END IF;      
      
      IF VEXECUTAR = 'SI' THEN
      /* Change status once start processing 3*/
        PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
        VSINTERF := PAC_INT_ONLINE.F_OBTENER_SINTERF;
        VERROR   := PAC_USER.F_GET_TERMINAL(PAC_MD_COMMON.F_GET_CXTUSUARIO,
                                            VTERMINAL);   
                                            
        UPDATE MOVCONTASAP M
             SET M.ESTADO  = X_ESTADO_P, M.SINTERF = VSINTERF
           WHERE M.CAGENTE = MOV.CAGENTE
             AND M.NRECIBO = MOV.NRECIBO
             AND M.NSINIES = MOV.NSINIES
             AND M.CCONCEP = MOV.CCONCEP;
        COMMIT;                                               
                 
        VERROR := PAC_CON.F_CONTAB_SINIESTRO(REG.CEMPRES,                                             
                                             1,
                                             REG.CTIPPAG,
                                             REG.SIDEPAG,
                                             0,
                                             VTERMINAL,
                                             VEMITIDO,
                                             VSINTERF,
                                             PERROR,
                                             F_USER,
                                             NULL,
                                             NULL,
                                             NULL,
                                             1);
      END IF;                                             

      END LOOP;
      --    
    END LOOP;
    --
    --PAC_CONTA_SAP.GENERA_INFO_CUENTAS_RES;
    --
  END GENERA_REINTENTO_SIN;
  
  PROCEDURE GENERA_REINTENTO_RES(PI_SINTERF IN NUMBER) IS
    --
    CURSOR MOV_CONTA(P_EVENTO VARCHAR2) IS
    --
      SELECT A.*
        FROM MOVCONTASAP A
       WHERE A.ESTADO IN (5)
         AND A.EVENTO = P_EVENTO
         AND A.SINTERF = PI_SINTERF;
    --
  
    X_EVENTO VARCHAR2(50) := 'RESERVA';
  
    /* CAMBIOS DE SWAPNIL : STARTS  */
  
    VTERMINAL VARCHAR2(100);
    VERROR    NUMBER(10);
    VSINTERF  NUMBER;
    VEMITIDO  NUMBER;
    PERROR    VARCHAR2(2000);
    VCCONPAG  NUMBER;
    VSIDEPAG  NUMBER;
    VCRAMO    NUMBER;
    VCEMPRES  NUMBER;
    VNSINIES  NUMBER;
    VISINRET  NUMBER;
    VCTIPCOA  NUMBER;
    VCTIPPAG  NUMBER;
    VCMONPAG  NUMBER;
    VCTIPDES  NUMBER;
    VCSOLIDA  NUMBER;
    VSSEGURO  NUMBER;
    VNTRAMIT  NUMBER;
    VCTPRES   NUMBER;
    VNMOVRES  NUMBER;
    VIDRES    NUMBER;
    VCMONRES  VARCHAR2(10);
    VNMONRES  NUMBER;
    /* CAMBIOS DE SWAPNIL : ENDS  */
    
    X_ESTADO_I NUMBER := 0;
    X_ESTADO_P NUMBER := 3;
    X_ESTADO_T NUMBER := 4;
    X_ESTADO_SL NUMBER := 2;
    VEXECUTAR       VARCHAR2(2) := 'NO';
    VCOUNTIM        NUMBER := 0;
    VCOUNTSL        NUMBER := 0;
    VCOUNTSL_ESTADO NUMBER := 2;
    X_ESTADO_F NUMBER := 5;	
  
  BEGIN
  
    FOR MOV IN MOV_CONTA(X_EVENTO) LOOP
      --
      BEGIN
        --
        SELECT 0 CCONPAG,
               SR.SIDEPAG,
               S.CRAMO,
               S.CEMPRES,
               X.NSINIES,
               0 ISINRET,
               S.CTIPCOA,
               2 CTIPPAG,
               0 CMONPAG,
               0 CTIPDES,
               SR.CSOLIDARIDAD,
               S.SSEGURO,
               NTRAMIT,
               CTIPRES,
               NMOVRES,
               SR.IDRES
          INTO VCCONPAG,
               VSIDEPAG,
               VCRAMO,
               VCEMPRES,
               VNSINIES,
               VISINRET,
               VCTIPCOA,
               VCTIPPAG,
               VCMONPAG,
               VCTIPDES,
               VCSOLIDA,
               VSSEGURO,
               VNTRAMIT,
               VCTPRES,
               VNMOVRES,
               VIDRES
          FROM SEGUROS S, SIN_SINIESTRO X, SIN_TRAMITA_RESERVA_CONTA SR
         WHERE SR.NSINIES = MOV.NSINIES
           AND SR.NMOVRES = MOV.NMOVIMI
           AND X.NSINIES = MOV.NSINIES
           AND S.SSEGURO = X.SSEGURO
           AND SR.IDRES = MOV.CCONCEP
           AND ROWNUM = 1;
        --
      EXCEPTION
        WHEN OTHERS THEN
          --
          NULL;
          --  
      END;
      --
      BEGIN
        --
        SELECT CMONRES
          INTO VCMONRES
          FROM SIN_TRAMITA_RESERVADET
         WHERE NSINIES = MOV.NSINIES
           AND IDRES = MOV.CCONCEP
           AND NMOVRES = MOV.NMOVIMI
           AND NMOVRESDET = MOV.CTIPCOA;
        --   
      EXCEPTION
        WHEN OTHERS THEN
          --
          NULL;
          --
      END;
      --
      IF VCMONRES = 'COP' THEN
        --
        VNMONRES := 0;
        --
      ELSE
        --
        VNMONRES := 1;
        --
      END IF;
      --

     IF MOV.NUM_INTENTO IS NULL THEN
        UPDATE MOVCONTASAP M
           SET M.NUM_INTENTO = 1
         WHERE M.CAGENTE = MOV.CAGENTE
           AND M.NRECIBO = MOV.NRECIBO
           AND M.NSINIES = MOV.NSINIES
           AND M.NMOVIMI = MOV.NMOVIMI
           AND M.CTIPCOA = MOV.CTIPCOA
           AND M.CCONCEP = MOV.CCONCEP;
        COMMIT;
     END IF;
    
          /* Checking eligibility of ESTADO 3 before retry */
     IF MOV.SINTERF IS NOT NULL AND MOV.ESTADO = X_ESTADO_F AND MOV.NUM_INTENTO = 3 THEN
        SELECT COUNT(*)
          INTO VCOUNTIM
          FROM INT_MENSAJES IM
         WHERE IM.SINTERF = MOV.SINTERF;

        SELECT COUNT(*)
          INTO VCOUNTSL
          FROM SERVICIO_LOGS SL
         WHERE SL.SINTERF = MOV.SINTERF;

        IF VCOUNTIM > 0 AND VCOUNTSL > 0 THEN
          BEGIN
            SELECT SL.ESTADO
              INTO VCOUNTSL_ESTADO
              FROM SERVICIO_LOGS SL
             WHERE SL.SINTERF = MOV.SINTERF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VCOUNTSL_ESTADO := X_ESTADO_SL;
          END;
          IF VCOUNTSL_ESTADO = X_ESTADO_SL THEN
            VEXECUTAR := 'SI';
            DELETE CONTAB_ASIENT_INTERF CAI
             WHERE CAI.IDPAGO  = MOV.NRECIBO
               AND CAI.SINTERF = MOV.SINTERF;
            COMMIT;
          ELSE
            VEXECUTAR := 'NO';
            UPDATE MOVCONTASAP M
               SET M.ESTADO = X_ESTADO_T
             WHERE M.CAGENTE = MOV.CAGENTE
               AND M.NRECIBO = MOV.NRECIBO
               AND M.NSINIES = MOV.NSINIES
               AND M.NMOVIMI = MOV.NMOVIMI
               AND M.CTIPCOA = MOV.CTIPCOA
               AND M.CCONCEP = MOV.CCONCEP;
            COMMIT;
          END IF;
        ELSE
            VEXECUTAR := 'SI';
        END IF;

      ELSIF MOV.ESTADO = X_ESTADO_I THEN
            VEXECUTAR := 'SI';
      END IF;
                
     IF VEXECUTAR = 'SI' THEN
     /* Change status once start processing 3*/
     
      PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
      VSINTERF := PAC_INT_ONLINE.F_OBTENER_SINTERF;
      VERROR   := PAC_USER.F_GET_TERMINAL(PAC_MD_COMMON.F_GET_CXTUSUARIO,
                                          VTERMINAL);
     
     UPDATE MOVCONTASAP M
           SET M.ESTADO  = X_ESTADO_P, M.SINTERF = VSINTERF
         WHERE M.CAGENTE = MOV.CAGENTE
           AND M.NRECIBO = MOV.NRECIBO
           AND M.NSINIES = MOV.NSINIES
           AND M.NMOVIMI = MOV.NMOVIMI
           AND M.CTIPCOA = MOV.CTIPCOA
           AND M.CCONCEP = MOV.CCONCEP;
        COMMIT;   

      VERROR := PAC_CON.F_CONTAB_SINIESTRO_RES(VCEMPRES,
                                               1,
                                               VCTIPPAG,
                                               MOV.NRECIBO, --REG.SIDEPAG,
                                               0,
                                               VTERMINAL,
                                               VEMITIDO,
                                               VSINTERF,
                                               PERROR,
                                               F_USER,
                                               NULL,
                                               NULL,
                                               NULL,
                                               1,
                                               VNSINIES,
                                               VNTRAMIT,
                                               VCTPRES,
                                               VNMOVRES,
                                               MOV.CTIPCOA,
                                               MOV.CTIPREC,
                                               VIDRES,
                                               VNMONRES);
      --  
      IF VERROR = 0 THEN
        --                                   
        UPDATE SIN_TRAMITA_RESERVA_CONTA
           SET CESTADO = 1
         WHERE NSINIES = VNSINIES
           AND NTRAMIT = VNTRAMIT
           AND CTIPRES = VCTPRES
           AND NMOVRES = VNMOVRES;
        COMMIT;
        --
      END IF;
                                          
     END IF;      
      --  
    END LOOP;
  
  END GENERA_REINTENTO_RES;

END PAC_CONTA_SAP;
/
