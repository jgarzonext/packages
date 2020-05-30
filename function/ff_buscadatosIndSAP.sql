CREATE OR REPLACE FUNCTION FF_BUSCADATOSINDSAP(
   SAP_BUSCA IN NUMBER,
   SAP_CUENTA IN VARCHAR2)
RETURN VARCHAR2  IS
/*****************************************************************
   FF_BUSCADATOSSAP:  RETORNA LOS VALORES REQUERIDOS SEGUN CUENTA PARA LA CONTABILIZACION EN SAP
   AUTOR:                      WILSON ANDRES JAIME
   FECHA:                      14/05/2019
*****************************************************************/
X_TIPO_LIQUIDACION NUMBER;
X_SPRODUC NUMBER;
X_INDICADOR VARCHAR2(50);
X_AGENTE VARCHAR2(20);
X_CUENTA VARCHAR2(20);
X_TIPCUENTA VARCHAR2(20); 
X_TIPLIQUIDA VARCHAR2(20);
X_ESCENARIO VARCHAR2(10);
X_COMISION NUMBER;
X_GASTOS NUMBER;
X_TIPCOA NUMBER;
X_CTIPCOM NUMBER;
X_FEMISIO DATE;
X_FEFECTO DATE;
X_LONG NUMBER;
X_EXIST NUMBER:=0;

X_SSEGURO  number;
X_NMOVIMI    number;
V_COUNT  number:=0;

BEGIN

     X_LONG := LENGTH(SAP_BUSCA);
   --VALIDACION INDICADOR DE IVA
     IF SAP_BUSCA = 1 THEN
        SELECT CRESPUE
         INTO X_SPRODUC
      FROM PREGUNSEG
      WHERE SSEGURO = SAP_CUENTA
       AND CPREGUN = 2886
       AND ROWNUM = 1;

     IF SUBSTR(X_SPRODUC, 1, 2) IN (88, 91) THEN
        SELECT CCINDID
         INTO X_INDICADOR
      FROM TIPOS_INDICADORES
      WHERE CAREA = 4
         AND CTIPREG = 1
         AND CIMPRET = 1
         AND CTIPIND = 63;
     ELSE
         X_INDICADOR := 'K8';
     END IF;
   END IF;

    --VALIDACION DE CORRETAJE
   IF SAP_BUSCA = 2 THEN
      SELECT COUNT(*)
         INTO X_TIPO_LIQUIDACION
      FROM AGE_CORRETAJE
      WHERE SSEGURO = SAP_CUENTA;

      IF X_TIPO_LIQUIDACION = 0 THEN

           X_INDICADOR := 0;
        ELSE 
           X_INDICADOR := 1;
      END IF;
   END IF;

    --VALIDACION DE COMISION DE POLIZA
   IF SAP_BUSCA = 3 THEN

    SELECT REGEXP_SUBSTR(SAP_CUENTA, '[^|]+') "SSEGURO"
      INTO X_SSEGURO
      FROM DUAL;

    SELECT (SUBSTR(SAP_CUENTA,
                   INSTR(SAP_CUENTA, '|') + 1,
                   LENGTH(SAP_CUENTA))) "NMOVIMI"
      INTO X_NMOVIMI
      FROM DUAL;

       SELECT CAGENTE, SPRODUC, CTIPCOA, CTIPCOM
              INTO X_AGENTE, X_SPRODUC, X_TIPCOA, X_CTIPCOM
       FROM SEGUROS 
       WHERE SSEGURO = X_SSEGURO;
       
       BEGIN   -- VALIDACION COMISION ESPECIAL
         SELECT COUNT(*)
           INTO V_COUNT
           FROM COMISIONSEGU 
          WHERE SSEGURO IN (SELECT SSEGURO
                              FROM RECIBOS 
                             WHERE SSEGURO = X_SSEGURO
                               AND NMOVIMI = X_NMOVIMI)
            AND NMOVIMI = X_NMOVIMI ;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            V_COUNT := 0;
         END;

       BEGIN

         IF X_CTIPCOM = 0 THEN            -- DEPENDE DEL PRODUCTO
           IF V_COUNT = 0 THEN
            SELECT C.PCOMISI
              INTO X_COMISION
              FROM COMISIONPROD C, AGENTES A
             WHERE C.CCOMISI = A.CCOMISI
               AND A.CAGENTE = X_AGENTE
               AND C.SPRODUC = X_SPRODUC
               AND C.FINIVIG = (SELECT MAX(FINIVIG)
                                        FROM COMISIONVIG V
                                        WHERE V.CCOMISI = A.CCOMISI);
           ELSE
               BEGIN
                  SELECT DISTINCT PCOMISI 
                    INTO X_COMISION
                    FROM COMISIONSEGU
                   WHERE SSEGURO = X_SSEGURO
                     AND NMOVIMI = X_NMOVIMI;
                  EXCEPTION WHEN NO_DATA_FOUND THEN
                  
                  SELECT DISTINCT PCOMISI
                    INTO X_COMISION
                    FROM COMISIONSEGU
                   WHERE SSEGURO = X_SSEGURO
                     AND NMOVIMI =(SELECT MAX(COM1.NMOVIMI)
                                     FROM COMISIONSEGU COM1
                                    WHERE COM1.SSEGURO = X_SSEGURO);
               END;
             END IF;

         ELSIF X_CTIPCOM IN (90,92)  THEN  -- COMISIONSEG 
           BEGIN
            SELECT DISTINCT PCOMISI
            INTO X_COMISION
            FROM COMISIONSEGU
             WHERE SSEGURO = X_SSEGURO
             AND NMOVIMI = X_NMOVIMI;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
           
           SELECT C.PCOMISI
              INTO X_COMISION
              FROM COMISIONPROD C, AGENTES A
             WHERE C.CCOMISI = A.CCOMISI
               AND A.CAGENTE = X_AGENTE
               AND C.SPRODUC = X_SPRODUC
               AND C.FINIVIG = (SELECT MAX(FINIVIG)
                                        FROM COMISIONVIG V
                                        WHERE V.CCOMISI = A.CCOMISI);
            
            END;
         ELSIF X_CTIPCOM = 99 THEN        -- NO TIENE COMISION
            X_COMISION := 0;

         END IF;   
       END;                                                

       IF X_TIPCOA = 0 THEN            
          X_GASTOS := 0;
       END IF;
       IF X_TIPCOA = 8 THEN            
          X_GASTOS := 2;
       END IF;
       IF X_TIPCOA = 1 THEN
          SELECT MAX(PCOMGAS)
             INTO X_GASTOS
          FROM COACEDIDO
          WHERE SSEGURO = X_SSEGURO
          AND ROWNUM = 1;
       END IF;   

       IF X_GASTOS = 0 THEN

             IF X_COMISION = 0 THEN
                    X_COMISION := NULL;
                    X_INDICADOR := X_COMISION;  

              ELSIF X_COMISION <> 0 THEN
                    X_INDICADOR := X_COMISION||'|'||''; 

            END IF; 

        ELSE
          IF X_COMISION = 0 THEN
                    X_COMISION := NULL;
                    X_INDICADOR := X_COMISION||'|'||X_GASTOS;  

              ELSIF X_COMISION <> 0 THEN
                   X_INDICADOR := X_COMISION||'|'||X_GASTOS; 

            END IF;
        END IF;           
   END IF;  

   --VALIDACION COLETILLA JUDICIALES

    IF SAP_BUSCA = 4 THEN
       SELECT SPRODUC
              INTO X_SPRODUC
       FROM SEGUROS 
       WHERE SSEGURO = SAP_CUENTA;

       IF X_SPRODUC IN (80007, 80008) THEN
         X_INDICADOR := '0102';
       ELSE
         X_INDICADOR := '0101';
       END IF;
    END IF;   

   --VALIDACION DE COASEGUROS DE POLIZA
   IF SAP_BUSCA = 5 THEN
       SELECT CTIPCOA
              INTO X_TIPCOA
       FROM SEGUROS 
       WHERE SSEGURO = SAP_CUENTA;

       IF X_TIPCOA = 1 THEN
          X_INDICADOR := 1; 
       END IF;   

       IF X_TIPCOA = 8 THEN
          X_INDICADOR := 8;  
        END IF;   

   END IF;  

   --VALIDACION TIPO AGENTE
   IF SAP_BUSCA = 6 THEN
         SELECT CAGENTE
              INTO X_AGENTE
       FROM SEGUROS 
       WHERE SSEGURO = SAP_CUENTA;

       SELECT CTIPAGE
              INTO X_TIPCOA
       FROM AGENTES
       WHERE CAGENTE = X_AGENTE;

      IF X_TIPCOA IN (3,5,6,7) THEN
        X_INDICADOR := 1;
      ELSE 
        X_INDICADOR := 0;
      END IF;
   END IF;

   --GENERACION ROWID PARA COMISIONES
   IF SAP_BUSCA = 7 THEN   
   SELECT COUNT(*) INTO X_EXIST FROM MOVCONTASAP A 
     WHERE A.NRECIBO = SAP_CUENTA
       AND A.CODESCENARIO IN (255,256,250,215,225,220,212,226,253,251,218,210,207,206,248,257,252,266,265);  



     SELECT SUBSTR(A.ROWID, -2,2 )
        INTO X_AGENTE
     FROM MOVCONTASAP A 
     WHERE A.NRECIBO = SAP_CUENTA
        AND CODESCENARIO IN (255,256/*,250,215,225,220,212,226,253,251,218,210,207,206,248,257,252,266,265*/);

     X_INDICADOR := X_AGENTE;

   END IF;

   --VALIDACION FECHA FUTURA
   IF SAP_BUSCA = 8 THEN 
        SELECT TRUNC(FEMISIO),  TRUNC(FEFECTO) 
             INTO X_FEMISIO, X_FEFECTO
          FROM SEGUROS A
          WHERE SSEGURO = SAP_CUENTA;

        IF X_FEFECTO > X_FEMISIO THEN
               X_INDICADOR := 1;
        ELSE
               X_INDICADOR := 0;
        END IF;

    END IF;   

    --VALIDACION CUENTA 192515 PARA GENERAR UN SOLO REGISTRO CUANDO ES VF
    IF SAP_BUSCA = 9 THEN
      SELECT COUNT(*) 
         INTO X_SPRODUC
      FROM CONTAB_ASIENT_INTERF
      WHERE IDPAGO = SAP_CUENTA
         AND CCUENTA = '192515';

      IF X_SPRODUC = 0 THEN
         X_INDICADOR := 0;
      ELSE 
        X_INDICADOR := 1;
      END IF;

    END IF;

      --VALIDACION CUENTA 515210 PARA GENERAR UN SOLO REGISTRO CUANDO ES VF
    IF SAP_BUSCA = 10 THEN
      SELECT COUNT(*) 
         INTO X_SPRODUC
      FROM CONTAB_ASIENT_INTERF
      WHERE IDPAGO = SAP_CUENTA
         AND CCUENTA = '515210';

      IF X_SPRODUC = 0 THEN
         X_INDICADOR := 0;
      ELSE 
        X_INDICADOR := 1;
      END IF;

    END IF;

      --VALIDACION CUENTA 282005 PARA GENERAR UN SOLO REGISTRO CUANDO ES VF
    IF SAP_BUSCA = 11 THEN

     -- INSERT INTO CUENTAS_SAP VALUES ('282005', 1);
     -- COMMIT;

      SELECT COUNT(*) 
         INTO X_SPRODUC
      FROM CUENTAS_SAP
      WHERE CUENTA = '282005';

      IF X_SPRODUC < 1 THEN
         X_INDICADOR := 0;
      ELSE 
        X_INDICADOR := 1;
      END IF;
    /*  
      IF X_SPRODUC >= 2 THEN
          DELETE CUENTAS_SAP 
          WHERE CUENTA = '282005';
          COMMIT;
      END IF;    
*/
    END IF;

    --VALIDACION FECHAS CONTABLES
      IF SAP_BUSCA = 12 THEN
        IF SAP_CUENTA IN (333,334,337,338,341,342,346,345,347,348,349,350,351,352,359,360,355,356,255,253,239,246,250,215,257,
                                                                                     252,241,236,212,226,256,251,240,235,225,220) THEN
                      X_INDICADOR := 0;
        ELSE
           X_INDICADOR := 1;
        END IF;
      END IF;

   IF X_LONG > 3 THEN
      BEGIN
        SELECT TIPO_CUENTA
           INTO  X_AGENTE
        FROM  TIPO_LIQUIDACION
        WHERE CUENTA = SAP_BUSCA;
        EXCEPTION WHEN NO_DATA_FOUND THEN
              BEGIN
                    SELECT SPERSON 
                      INTO X_INDICADOR
                    FROM PER_PERSONAS
                    WHERE NNUMIDE = SAP_CUENTA;
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                         X_INDICADOR := SAP_CUENTA;
                END;
       END;           

      IF X_AGENTE = 'D' THEN
         BEGIN
                    SELECT SPERSON_DEUD
                      INTO X_INDICADOR
                    FROM PER_PERSONAS
                    WHERE NNUMIDE = SAP_CUENTA;
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                         X_INDICADOR := SAP_CUENTA;
           END;
      ELSE
              BEGIN
                    SELECT SPERSON_ACRE
                      INTO X_INDICADOR
                    FROM PER_PERSONAS
                    WHERE NNUMIDE = SAP_CUENTA;
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                         X_INDICADOR := SAP_CUENTA;
           END;
      END IF; 

    -- VALIDACION DE INTERMEDIARIO JVELOSA 07-08-2019
     BEGIN 

      SELECT SUBSTR(SAP_BUSCA,0,10),SUBSTR(SAP_BUSCA,11)
        INTO X_CUENTA,X_ESCENARIO 
        FROM DUAL; 

        SELECT TIPO_CUENTA,TIPLIQ 
          INTO X_TIPCUENTA,X_TIPLIQUIDA
          FROM TIPO_LIQUIDACION 
         WHERE CUENTA = X_CUENTA;

        --PERSONAS  / ENVIAR : P.SPERSON
        IF (X_TIPLIQUIDA != 41 AND X_ESCENARIO IN (213,222,223,227,229,230,237,238,242,244,245,247,254,258,259,260,261,262,333,334,335,
                                                   336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,
                                                   358,359,360,361,362)) 
           THEN
             BEGIN 
               SELECT DECODE(X_TIPCUENTA,'D',P.SPERSON_DEUD,P.SPERSON_ACRE)
                 INTO X_INDICADOR
                 FROM PER_PERSONAS P
                WHERE P.SPERSON = SAP_CUENTA;   
             END;

        -- AGENTES / ENVIAR : C.CAGENTE
        ELSIF (X_TIPLIQUIDA != 41 AND X_ESCENARIO IN (206,207,208,209,210,211,212,215,218,220,225,226,232,235,236,239,240,241,246,248,250,
                                                      251,252,253,255,255,256,257,263,265,266)) 
          THEN 
           BEGIN 
             SELECT DECODE(X_TIPCUENTA,'D',P.SPERSON_DEUD,P.SPERSON_ACRE)
               INTO X_INDICADOR
               FROM PER_PERSONAS P , AGENTES A
              WHERE P.SPERSON =  A.SPERSON
                AND A.CAGENTE = SAP_CUENTA;
           END;

         -- COMPANIAS / ENVIAR : C.SPERSON
        ELSIF (X_TIPLIQUIDA != 41 AND X_ESCENARIO IN (214,219,233,249,261))  
          THEN 
           BEGIN 
             SELECT DECODE(X_TIPCUENTA,'D',P.SPERSON_DEUD,P.SPERSON_ACRE)
               INTO X_INDICADOR
               FROM PER_PERSONAS P , COMPANIAS C
              WHERE P.SPERSON =  C.SPERSON
                AND C.SPERSON = SAP_CUENTA;
           END;

        -- COASEGURO C.SPERSON
        ELSIF (X_TIPLIQUIDA = 41 AND X_ESCENARIO IN (233,230,238,245,259,261,345,346,347,348,349,350)) 
          THEN 
           BEGIN 
             SELECT DECODE(X_TIPCUENTA,'D',P.SPERSON_DEUD,P.SPERSON_ACRE)
               INTO X_INDICADOR
               FROM PER_PERSONAS P , COMPANIAS C
              WHERE P.SPERSON =  C.SPERSON
                AND C.SPERSON = SAP_CUENTA;
           END;

        END IF;

      END;

   END IF;  


    RETURN (X_INDICADOR);

END;
/